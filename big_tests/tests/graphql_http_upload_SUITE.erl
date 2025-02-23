-module(graphql_http_upload_SUITE).

-compile([export_all, nowarn_export_all]).

-import(distributed_helper, [mim/0, require_rpc_nodes/1]).
-import(domain_helper, [host_type/0, domain/0]).
-import(graphql_helper, [execute_user_command/5, execute_command/4, get_ok_value/2,
                         get_err_msg/1, get_err_code/1]).

-include_lib("eunit/include/eunit.hrl").

-define(S3_HOSTNAME, <<"http://bucket.s3-eu-east-25.example.com">>).

suite() ->
    require_rpc_nodes([mim]) ++ escalus:suite().

all() ->
    [{group, user},
     {group, admin_http},
     {group, admin_cli}].

groups() ->
    [{user, [], user_groups()},
     {admin_http, [], admin_groups()},
     {admin_cli, [], admin_groups()},
     {user_http_upload, [], user_http_upload_tests()},
     {user_http_upload_not_configured, [], user_http_upload_not_configured_tests()},
     {admin_http_upload, [], admin_http_upload_tests()},
     {admin_http_upload_not_configured, [], admin_http_upload_not_configured_tests()}].

user_groups() ->
    [{group, user_http_upload},
     {group, user_http_upload_not_configured}].

admin_groups() ->
    [{group, admin_http_upload},
     {group, admin_http_upload_not_configured}].

user_http_upload_tests() ->
    [user_get_url_test,
     user_get_url_zero_size,
     user_get_url_too_large_size,
     user_get_url_zero_timeout].

user_http_upload_not_configured_tests() ->
    [user_http_upload_not_configured].

admin_http_upload_tests() ->
    [admin_get_url_test,
     admin_get_url_zero_size,
     admin_get_url_too_large_size,
     admin_get_url_zero_timeout,
     admin_get_url_no_domain].

admin_http_upload_not_configured_tests() ->
    [admin_http_upload_not_configured].

init_per_suite(Config) ->
    Config1 = dynamic_modules:save_modules(host_type(), Config),
    Config2 = ejabberd_node_utils:init(mim(), Config1),
    escalus:init_per_suite(Config2).

end_per_suite(Config) ->
    dynamic_modules:restore_modules(Config),
    escalus:end_per_suite(Config).

init_per_group(user, Config) ->
    graphql_helper:init_user(Config);
init_per_group(admin_http, Config) ->
    graphql_helper:init_admin_handler(Config);
init_per_group(admin_cli, Config) ->
    graphql_helper:init_admin_cli(Config);
init_per_group(user_http_upload, Config) ->
    dynamic_modules:ensure_modules(host_type(),
        [{mod_http_upload, create_opts(?S3_HOSTNAME, true)}]),
    Config;
init_per_group(user_http_upload_not_configured, Config) ->
    dynamic_modules:ensure_modules(host_type(), [{mod_http_upload, stopped}]),
    Config;
init_per_group(admin_http_upload, Config) ->
    dynamic_modules:ensure_modules(host_type(),
        [{mod_http_upload, create_opts(?S3_HOSTNAME, true)}]),
    Config;
init_per_group(admin_http_upload_not_configured, Config) ->
    dynamic_modules:ensure_modules(host_type(), [{mod_http_upload, stopped}]),
    Config.

end_per_group(GroupName, _Config) when GroupName =:= user;
                                       GroupName =:= admin_http;
                                       GroupName =:= admin_cli ->
    graphql_helper:clean();
end_per_group(_, _Config) ->
    escalus_fresh:clean().

init_per_testcase(CaseName, Config) ->
    escalus:init_per_testcase(CaseName, Config).

end_per_testcase(CaseName, Config) ->
    escalus:end_per_testcase(CaseName, Config).

create_opts(Host, AddAcl) ->
    config_parser_helper:mod_config(mod_http_upload,
        #{
            max_file_size => 1234,
            s3 => #{
                bucket_url => Host,
                add_acl => AddAcl,
                region => <<"eu-east-25">>,
                access_key_id => <<"AKIAIAOAONIULXQGMOUA">>,
                secret_access_key => <<"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">>
            }
        }).

% User test cases

user_get_url_test(Config) ->
    escalus:fresh_story_with_config(Config, [{alice, 1}],
                                    fun user_get_url_test/2).

user_get_url_test(Config, Alice) ->
    Result = user_get_url(<<"test">>, 123, <<"Test">>, 123, Alice, Config),
    ParsedResult = get_ok_value([data, httpUpload, getUrl], Result),
    #{<<"PutUrl">> := PutURL, <<"GetUrl">> := GetURL, <<"Header">> := _Headers} = ParsedResult,
    ?assertMatch({_, _}, binary:match(PutURL, [?S3_HOSTNAME])),
    ?assertMatch({_, _}, binary:match(GetURL, [?S3_HOSTNAME])).

user_get_url_zero_size(Config) ->
    escalus:fresh_story_with_config(Config, [{alice, 1}],
                                    fun user_get_url_zero_size/2).

user_get_url_zero_size(Config, Alice) ->
    Result = user_get_url(<<"test">>, 0, <<"Test">>, 123, Alice, Config),
    ?assertEqual(<<"size_error">>, get_err_code(Result)),
    ?assertEqual(<<"size must be positive integer">>, get_err_msg(Result)).

user_get_url_too_large_size(Config) ->
    escalus:fresh_story_with_config(Config, [{alice, 1}],
                                    fun user_get_url_too_large_size/2).

user_get_url_too_large_size(Config, Alice) ->
    Result = user_get_url(<<"test">>, 100000, <<"Test">>, 123, Alice, Config),
    ?assertEqual(<<"file_too_large_error">>, get_err_code(Result)),
    ?assertMatch(<<"Declared file size exceeds", _/bits>>, get_err_msg(Result)).

user_get_url_zero_timeout(Config) ->
    escalus:fresh_story_with_config(Config, [{alice, 1}],
                                    fun user_get_url_zero_timeout/2).

user_get_url_zero_timeout(Config, Alice) ->
    Result = user_get_url(<<"test">>, 123, <<"Test">>, 0, Alice, Config),
    ?assertEqual(<<"timeout_error">>, get_err_code(Result)),
    ?assertEqual(<<"timeout must be positive integer">>, get_err_msg(Result)).

user_http_upload_not_configured(Config) ->
    escalus:fresh_story_with_config(Config, [{alice, 1}],
                                    fun user_http_upload_not_configured/2).

user_http_upload_not_configured(Config, Alice) ->
    Result = user_get_url(<<"test">>, 123, <<"Test">>, 123, Alice, Config),
    ?assertEqual(<<"module_not_loaded_error">>, get_err_code(Result)),
    ?assertEqual(<<"mod_http_upload is not loaded for this host">>, get_err_msg(Result)).

% Admin test cases

admin_get_url_test(Config) ->
    Result = admin_get_url(domain(), <<"test">>, 123, <<"Test">>, 123, Config),
    ParsedResult = get_ok_value([data, httpUpload, getUrl], Result),
    #{<<"PutUrl">> := PutURL, <<"GetUrl">> := GetURL, <<"Header">> := _Headers} = ParsedResult,
    ?assertMatch({_, _}, binary:match(PutURL, [?S3_HOSTNAME])),
    ?assertMatch({_, _}, binary:match(GetURL, [?S3_HOSTNAME])).

admin_get_url_zero_size(Config) ->
    Result = admin_get_url(domain(), <<"test">>, 0, <<"Test">>, 123, Config),
    ?assertEqual(<<"size_error">>, get_err_code(Result)),
    ?assertEqual(<<"size must be positive integer">>, get_err_msg(Result)).

admin_get_url_too_large_size(Config) ->
    Result = admin_get_url(domain(), <<"test">>, 100000, <<"Test">>, 123, Config),
    ?assertEqual(<<"file_too_large_error">>, get_err_code(Result)),
    ?assertMatch(<<"Declared file size exceeds", _/bits>>, get_err_msg(Result)).

admin_get_url_zero_timeout(Config) ->
    Result = admin_get_url(domain(), <<"test">>, 123, <<"Test">>, 0, Config),
    ?assertEqual(<<"timeout_error">>, get_err_code(Result)),
    ?assertEqual(<<"timeout must be positive integer">>, get_err_msg(Result)).

admin_get_url_no_domain(Config) ->
    Result = admin_get_url(<<"AAAAA">>, <<"test">>, 123, <<"Test">>, 123, Config),
    ?assertEqual(<<"domain_not_found">>, get_err_code(Result)),
    ?assertEqual(<<"domain does not exist">>, get_err_msg(Result)).

admin_http_upload_not_configured(Config) ->
    Result = admin_get_url(domain(), <<"test">>, 123, <<"Test">>, 123, Config),
    ?assertEqual(<<"module_not_loaded_error">>, get_err_code(Result)),
    ?assertEqual(<<"mod_http_upload is not loaded for this host">>, get_err_msg(Result)).

% Helpers

user_get_url(FileName, Size, ContentType, Timeout, User, Config) ->
    Vars = #{<<"filename">> => FileName, <<"size">> => Size,
             <<"contentType">> => ContentType, <<"timeout">> => Timeout},
    execute_user_command(<<"httpUpload">>, <<"getUrl">>, User, Vars, Config).

admin_get_url(Domain, FileName, Size, ContentType, Timeout, Config) ->
    Vars = #{<<"domain">> => Domain, <<"filename">> => FileName, <<"size">> => Size,
             <<"contentType">> => ContentType, <<"timeout">> => Timeout},
    execute_command(<<"httpUpload">>, <<"getUrl">>, Vars, Config).
