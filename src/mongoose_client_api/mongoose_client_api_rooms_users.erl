-module(mongoose_client_api_rooms_users).
-behaviour(cowboy_rest).

-export([trails/0]).

-export([init/2]).
-export([content_types_provided/2]).
-export([content_types_accepted/2]).
-export([is_authorized/2]).
-export([allowed_methods/2]).
-export([resource_exists/2]).
-export([allow_missing_post/2]).

-export([from_json/2]).
-export([delete_resource/2]).

-ignore_xref([from_json/2, trails/0]).

-include("mongoose.hrl").
-include("jlib.hrl").
-include_lib("exml/include/exml.hrl").

trails() ->
    mongoose_client_api_rooms_users_doc:trails().

init(Req, Opts) ->
    mongoose_client_api:init(Req, Opts).

is_authorized(Req, State) ->
    mongoose_client_api:is_authorized(Req, State).

content_types_provided(Req, State) ->
    mongoose_client_api_rooms:content_types_provided(Req, State).

content_types_accepted(Req, State) ->
    mongoose_client_api_rooms:content_types_accepted(Req, State).

allowed_methods(Req, State) ->
    {[<<"OPTIONS">>, <<"POST">>, <<"DELETE">>], Req, State}.

resource_exists(Req, State) ->
    mongoose_client_api_rooms:resource_exists(Req, State).

allow_missing_post(Req, State) ->
    {false, Req, State}.

from_json(Req, #{role_in_room := owner,
                 jid := UserJID,
                 room := #{jid := RoomJID}} = State) ->
    {ok, Body, Req2} = cowboy_req:read_body(Req),
    case mongoose_client_api:json_to_map(Body) of
        {ok, #{<<"user">> := UserToInvite}} when is_binary(UserToInvite) ->
            mod_muc_light_api:change_affiliation(RoomJID, UserJID,
                                                 jid:from_binary(UserToInvite), <<"member">>),
            {true, Req2, State};
        _ ->
            {false, Req, State}
    end;
from_json(Req, State) ->
    mongoose_client_api:forbidden_request(Req, State).

delete_resource(Req, #{role_in_room := none} = State) ->
    mongoose_client_api:forbidden_request(Req, State);
delete_resource(Req, #{role_in_room := owner} = State) ->
    UserToRemove = cowboy_req:binding(user, Req),
    remove_user_from_room(UserToRemove, Req, State);
delete_resource(Req, #{user := User} = State) ->
    UserToRemove = cowboy_req:binding(user, Req),
    case UserToRemove of
        User ->
            remove_user_from_room(User, Req, State);
        _ ->
            mongoose_client_api:forbidden_request(Req, State)
    end.

remove_user_from_room(Target, Req,
                      #{jid := UserJID, room := #{jid := RoomJID}} = State) ->
    mod_muc_light_api:change_affiliation(RoomJID, UserJID, jid:from_binary(Target), <<"none">>),
    {true, Req, State}.
