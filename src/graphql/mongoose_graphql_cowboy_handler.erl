%% @doc A cowboy handler for graphql listeners. It supports both admin and user
%% schemas. The `schema_endpoint' config option must be set to decide which
%% schema to use.
%%
%% The graphql request is authorized, processed and then passed for execution.
%% @end
-module(mongoose_graphql_cowboy_handler).

-behaviour(mongoose_http_handler).
-behavior(cowboy_rest).

%% mongoose_http_handler callbacks
-export([config_spec/0]).

%% config processing callbacks
-export([process_config/1]).

%% Cowboy Handler Interface
-export([init/2]).

%% REST callbacks
-export([allowed_methods/2,
         resource_exists/2,
         content_types_provided/2,
         content_types_accepted/2,
         charsets_provided/2,
         is_authorized/2]).

%% Data input/output callbacks
-export([from_json/2,
         to_json/2,
         to_html/2]).

-ignore_xref([from_json/2, to_html/2, to_json/2]).

-include("mongoose_config_spec.hrl").

%% mongoose_http_handler callbacks

-spec config_spec() -> mongoose_config_spec:config_section().
config_spec() ->
    #section{
       items = #{<<"username">> => #option{type = binary},
                 <<"password">> => #option{type = binary},
                 <<"schema_endpoint">> => #option{type = atom,
                                                  validate = {enum, [admin, domain_admin, user]}}
                },
        format_items = map,
        required = [<<"schema_endpoint">>],
        process = fun ?MODULE:process_config/1}.

process_config(Opts) ->
    case maps:is_key(username, Opts) =:= maps:is_key(password, Opts) of
        true ->
            Opts;
        false ->
            error(#{what => both_username_and_password_required, opts => Opts})
    end.

%% cowboy_rest callbacks

init(Req, Opts) ->
    IndexLocation = {priv_file, mongooseim, "graphql/wsite/index.html"},
    {cowboy_rest,
     Req,
     Opts#{index_location => IndexLocation}
    }.

allowed_methods(Req, State) ->
    {[<<"GET">>, <<"POST">>], Req, State}.

content_types_accepted(Req, State) ->
    {[
        {{<<"application">>, <<"json">>, []}, from_json}
    ], Req, State}.

content_types_provided(Req, State) ->
    {[
        {{<<"application">>, <<"json">>, []}, to_json},
        {{<<"text">>, <<"html">>, []}, to_html}
    ], Req, State}.

charsets_provided(Req, State) ->
    {[<<"utf-8">>], Req, State}.

is_authorized(Req, State) ->
    try cowboy_req:parse_header(<<"authorization">>, Req) of
        Auth ->
            case check_auth(Auth, State) of
                {ok, State2} ->
                    {true, Req, State2};
                error ->
                    Msg = make_error(authorize, wrong_credentials),
                    reply_error(Msg, Req, State)
            end
    catch
        exit:Err ->
            reply_error(make_error(authorize, Err), Req, State)
    end.

resource_exists(#{method := <<"GET">>} = Req, State) ->
    {true, Req, State};
resource_exists(#{method := <<"POST">>} = Req, State) ->
    {false, Req, State}.

to_html(Req, #{index_location := {priv_file, App, FileLocation}} = State) ->
    Filename = filename:join(code:priv_dir(App), FileLocation),
    {ok, Data} = file:read_file(Filename),
    {Data, Req, State}.

json_request(Req, State) ->
    case gather(Req) of
        {error, Reason} ->
            reply_error(Reason, Req, State);
        {ok, Req2, Decoded} ->
            run_request(Decoded, Req2, State)
    end.

from_json(Req, State) -> json_request(Req, State).
to_json(Req, State) -> json_request(Req, State).

%% Internal

check_auth(Auth, #{schema_endpoint := domain_admin} = State) ->
    auth_domain_admin(Auth, State);
check_auth(Auth, #{schema_endpoint := admin} = State) ->
    auth_admin(Auth, State);
check_auth(Auth, #{schema_endpoint := user} = State) ->
    auth_user(Auth, State).

auth_user({basic, User, Password}, State) ->
    JID = jid:from_binary(User),
    case mongoose_api_common:check_password(JID, Password) of
        {true, _} -> {ok, State#{authorized => true,
                                 authorized_as => user,
                                 schema_ctx => #{user => JID}}};
        _ -> error
    end;
auth_user(_, State) ->
    {ok, State#{authorized => false}}.

auth_admin({basic, Username, Password}, #{username := Username, password := Password} = State) ->
    {ok, State#{authorized => true,
                schema_ctx => #{authorized_as => admin}
               }};
auth_admin({basic, _, _}, _) ->
    error;
auth_admin(_, #{username := _, password := _} = State) ->
    {ok, State#{authorized => false}};
auth_admin(_, State) ->
    % auth credentials not provided in config
    {ok, State#{authorized => true,
                schema_ctx => #{authorized_as => admin}}}.

auth_domain_admin({basic, Username, Password}, State) ->
    case jid:to_lus(jid:from_binary(Username)) of
        {<<"admin">>, Domain} ->
            case mongoose_domain_api:check_domain_password(Domain, Password) of
                ok ->
                    {ok, State#{authorized => true,
                                schema_ctx => #{authorized_as => domain_admin,
                                                admin => jid:from_binary(Username)}}};
                {error, _} ->
                    error
            end;
        _ ->
            error
    end;
auth_domain_admin(_, State) ->
    {ok, State#{authorized => false}}.

run_request(#{document := undefined}, Req, State) ->
    reply_error(make_error(decode, no_query_supplied), Req, State);
run_request(#{} = ReqCtx, Req, #{schema_endpoint := EpName,
                                 authorized := AuthStatus} = State) ->
    Ep = mongoose_graphql:get_endpoint(EpName),
    Ctx = maps:get(schema_ctx, State, #{}),
    ReqCtx2 = ReqCtx#{authorized => AuthStatus, ctx => Ctx},
    case mongoose_graphql:execute(Ep, ReqCtx2) of
        {ok, Response} ->
            ResponseBody = mongoose_graphql_response:term_to_json(Response),
            Req2 = cowboy_req:set_resp_body(ResponseBody, Req),
            Reply = cowboy_req:reply(200, Req2),
            {stop, Reply, State};
        {error, Reason} ->
            reply_error(Reason, Req, State)
    end.

gather(Req) ->
    {ok, Body, Req2} = cowboy_req:read_body(Req),
    Bindings = cowboy_req:bindings(Req2),
    try jiffy:decode(Body, [return_maps]) of
        JSON ->
            gather(Req2, JSON, Bindings)
    catch
        _:_ ->
            {error, make_error(decode, invalid_json_body)}
    end.

gather(Req, Body, Params) ->
    QueryDocument = document([Params, Body]),
    case variables([Params, Body]) of
        {ok, Vars} ->
            Operation = operation_name([Params, Body]),
            {ok, Req, #{document => QueryDocument,
                         vars => Vars,
                         operation_name => Operation}};
        {error, Reason} ->
            {error, Reason}
    end.

document([#{<<"query">> := Q}|_]) -> Q;
document([_|Next]) -> document(Next);
document([]) -> undefined.

variables([#{<<"variables">> := Vars} | _]) ->
  if
      is_binary(Vars) ->
          try jiffy:decode(Vars, [return_maps]) of
              null -> {ok, #{}};
              JSON when is_map(JSON) -> {ok, JSON};
              _ -> {error, make_error(decode, variables_invalid_json)}
          catch
              _:_ ->
                  {error, make_error(decode, variables_invalid_json)}
          end;
      is_map(Vars) ->
          {ok, Vars};
      Vars == null ->
          {ok, #{}}
  end;
variables([_ | Next]) ->
    variables(Next);
variables([]) ->
    {ok, #{}}.

operation_name([#{<<"operationName">> := OpName} | _]) ->
    OpName;
operation_name([_ | Next]) ->
    operation_name(Next);
operation_name([]) ->
    undefined.

make_error(Phase, Term) ->
    #{error_term => Term, phase => Phase}.

reply_error(Msg, Req, State) ->
    {Code, Error} = mongoose_graphql_errors:format_error(Msg),
    Body = jiffy:encode(#{errors => [Error]}),
    Req2 = cowboy_req:set_resp_body(Body, Req),
    Reply = cowboy_req:reply(Code, Req2),
    {stop, Reply, State}.
