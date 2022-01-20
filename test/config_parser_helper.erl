%% @doc Expected parsed and processed options for TOML parser tests

-module(config_parser_helper).

-compile([export_all, nowarn_export_all]).

%% Expected configuration options for predefined configurations.
%% For each clause there is a corresponding TOML file in config_parser_SUITE_data.
options("host_types") ->
    [{all_metrics_are_global, false},
     {default_server_domain, <<"localhost">>},
     {hide_service_name, false},
     {host_types,
      [<<"this is host type">>, <<"some host type">>,
       <<"another host type">>, <<"yet another host type">>]},
     {hosts, [<<"localhost">>]},
     {language, <<"en">>},
     {listen, []},
     {loglevel, warning},
     {mongooseimctl_access_commands, []},
     {rdbms_server_type, generic},
     {registration_timeout, 600},
     {routing_modules, mongoose_router:default_routing_modules()},
     {sm_backend, {mnesia, []}},
     {{auth, <<"another host type">>}, auth_with_methods(#{})},
     {{auth, <<"localhost">>},
      auth_with_methods(#{rdbms => #{users_number_estimate => false}})},
     {{auth, <<"some host type">>},
      auth_with_methods(#{http => #{}})},
     {{auth, <<"this is host type">>},
      auth_with_methods(#{external => #{instances => 1,
                                        program => "/usr/bin/bash"}})},
     {{auth, <<"yet another host type">>},
      auth_with_methods(#{external => #{instances => 1,
                                        program => "/usr/bin/bash"},
                          http => #{}})},
     {{modules, <<"another host type">>}, #{mod_offline => []}},
     {{modules, <<"localhost">>}, #{mod_vcard => []}},
     {{modules, <<"some host type">>}, #{}},
     {{modules, <<"this is host type">>}, #{}},
     {{modules, <<"yet another host type">>}, #{mod_amp => []}},
     {{replaced_wait_timeout, <<"another host type">>}, 2000},
     {{replaced_wait_timeout, <<"localhost">>}, 2000},
     {{replaced_wait_timeout, <<"some host type">>}, 2000},
     {{replaced_wait_timeout, <<"this is host type">>}, 2000},
     {{replaced_wait_timeout, <<"yet another host type">>}, 2000}];
options("miscellaneous") ->
    [{all_metrics_are_global, false},
     {cowboy_server_name, "Apache"},
     {default_server_domain, <<"localhost">>},
     {hide_service_name, true},
     {host_types, []},
     {hosts, [<<"localhost">>, <<"anonymous.localhost">>]},
     {language, <<"en">>},
     {listen,
      [#{ip_address => "0",
         ip_tuple => {0, 0, 0, 0},
         ip_version => 4, module => ejabberd_cowboy,
         modules =>
             [{"_", "/ws-xmpp", mod_websockets,
               [{ejabberd_service, [{access, all},
                                   {max_fsm_queue, 1000},
                                   {password, "secret"},
                                   {shaper_rule, fast}]}]}],
         port => 5280, proto => tcp,
         transport_options => [{max_connections, 1024}, {num_acceptors, 10}]}]},
     {loglevel, warning},
     {mongooseimctl_access_commands,
      [{local, ["join_cluster"], [{node, "mongooseim@prime"}]}]},
     {rdbms_server_type, mssql},
     {registration_timeout, 600},
     {routing_modules,
      [mongoose_router_global, mongoose_router_localdomain]},
     {services,
      [{service_mongoose_system_metrics,
        [{initial_report, 300000},
         {periodic_report, 10800000},
         report,
         {tracking_id, "UA-123456789"}]}]},
     {sm_backend, {mnesia, []}},
     {{auth, <<"anonymous.localhost">>}, custom_auth()},
     {{auth, <<"localhost">>}, custom_auth()},
     {{modules, <<"anonymous.localhost">>}, #{}},
     {{modules, <<"localhost">>}, #{}},
     {{replaced_wait_timeout, <<"anonymous.localhost">>}, 2000},
     {{replaced_wait_timeout, <<"localhost">>}, 2000},
     {{route_subdomains, <<"anonymous.localhost">>}, s2s},
     {{route_subdomains, <<"localhost">>}, s2s}];
options("modules") ->
    [{all_metrics_are_global, false},
     {default_server_domain, <<"localhost">>},
     {hide_service_name, false},
     {host_types, []},
     {hosts, [<<"localhost">>, <<"dummy_host">>]},
     {language, <<"en">>},
     {listen, []},
     {loglevel, warning},
     {mongooseimctl_access_commands, []},
     {rdbms_server_type, generic},
     {registration_timeout, 600},
     {routing_modules, mongoose_router:default_routing_modules()},
     {sm_backend, {mnesia, []}},
     {{auth, <<"dummy_host">>}, default_auth()},
     {{auth, <<"localhost">>}, default_auth()},
     {{modules, <<"dummy_host">>}, all_modules()},
     {{modules, <<"localhost">>}, all_modules()},
     {{replaced_wait_timeout, <<"dummy_host">>}, 2000},
     {{replaced_wait_timeout, <<"localhost">>}, 2000}];
options("mongooseim-pgsql") ->
    [{all_metrics_are_global, false},
     {default_server_domain, <<"localhost">>},
     {hide_service_name, false},
     {host_types, []},
     {hosts,
      [<<"localhost">>, <<"anonymous.localhost">>, <<"localhost.bis">>]},
     {language, <<"en">>},
     {listen,
      [#{access => c2s, ip_address => "0",
         ip_tuple => {0, 0, 0, 0},
         ip_version => 4, max_stanza_size => 65536, module => ejabberd_c2s,
         port => 5222, proto => tcp, shaper => c2s_shaper,
         tls => [{certfile, "priv/dc1.pem"}, {dhfile, "priv/dh.pem"}, starttls],
         zlib => 10000},
       #{access => c2s, ip_address => "0",
         ip_tuple => {0, 0, 0, 0},
         ip_version => 4, max_stanza_size => 65536, module => ejabberd_c2s,
         port => 5223, proto => tcp, shaper => c2s_shaper, zlib => 4096},
       #{ip_address => "0",
         ip_tuple => {0, 0, 0, 0},
         ip_version => 4, module => ejabberd_cowboy,
         modules =>
             [{"_", "/http-bind", mod_bosh, []},
              {"_", "/ws-xmpp", mod_websockets,
               [{ejabberd_service, [{access, all},
                                   {password, "secret"},
                                   {shaper_rule, fast}]}]}],
         port => 5280, proto => tcp,
         transport_options => [{max_connections, 1024}, {num_acceptors, 10}]},
       #{ip_address => "0",
         ip_tuple => {0, 0, 0, 0},
         ip_version => 4, module => ejabberd_cowboy,
         modules =>
             [{"_", "/http-bind", mod_bosh, []},
              {"_", "/ws-xmpp", mod_websockets,
               [{max_stanza_size, 100},
                {ping_rate, 120000},
                {timeout, infinity}]},
              {"localhost", "/api", mongoose_api_admin,
               [{auth, {<<"ala">>, <<"makotaipsa">>}}]},
              {"localhost", "/api/contacts/{:jid}", mongoose_api_client, []}],
         port => 5285, proto => tcp,
         ssl =>
             [{certfile, "priv/cert.pem"},
              {keyfile, "priv/dc1.pem"},
              {password, []}],
         transport_options => [{max_connections, 1024}, {num_acceptors, 10}]},
       #{ip_address => "127.0.0.1",
         ip_tuple => {127, 0, 0, 1},
         ip_version => 4, module => ejabberd_cowboy,
         modules => [{"localhost", "/api", mongoose_api_admin, []}],
         port => 8088, proto => tcp,
         transport_options => [{max_connections, 1024}, {num_acceptors, 10}]},
       #{ip_address => "0",
         ip_tuple => {0, 0, 0, 0},
         ip_version => 4, module => ejabberd_cowboy,
         modules =>
             [{"_", "/api-docs/[...]", cowboy_static,
               {priv_dir, cowboy_swagger, "swagger",
                [{mimetypes, cow_mimetypes, all}]}},
              {"_", "/api-docs/swagger.json", cowboy_swagger_json_handler, #{}},
              {"_", "/api-docs", cowboy_swagger_redirect_handler, #{}},
              {"_", "/api/sse", lasse_handler, [mongoose_client_api_sse]},
              {"_", "/api/contacts/[:jid]", mongoose_client_api_contacts, []},
              {"_", "/api/messages/[:with]", mongoose_client_api_messages, []},
              {"_", "/api/rooms/[:id]", mongoose_client_api_rooms, []},
              {"_", "/api/rooms/[:id]/config",
               mongoose_client_api_rooms_config, []},
              {"_", "/api/rooms/[:id]/messages",
               mongoose_client_api_rooms_messages, []},
              {"_", "/api/rooms/:id/users/[:user]",
               mongoose_client_api_rooms_users, []}],
         port => 8089, proto => tcp,
         protocol_options => [{compress, true}],
         ssl =>
             [{certfile, "priv/cert.pem"},
              {keyfile, "priv/dc1.pem"},
              {password, []}],
         transport_options => [{max_connections, 1024}, {num_acceptors, 10}]},
       #{ip_address => "127.0.0.1",
         ip_tuple => {127, 0, 0, 1},
         ip_version => 4, module => ejabberd_cowboy,
         modules =>
             [{"localhost", "/api", mongoose_api,
               [{handlers, [mongoose_api_metrics, mongoose_api_users]}]}],
         port => 5288, proto => tcp,
         transport_options => [{max_connections, 1024}, {num_acceptors, 10}]},
       #{ip_address => "0",
         ip_tuple => {0, 0, 0, 0},
         ip_version => 4, max_stanza_size => 131072,
         module => ejabberd_s2s_in, port => 5269, proto => tcp,
         shaper => s2s_shaper,
         tls => [{dhfile, "priv/dh.pem"}]},
       #{access => all, ip_address => "127.0.0.1",
         ip_tuple => {127, 0, 0, 1},
         ip_version => 4, module => ejabberd_service, password => "secret",
         port => 8888, proto => tcp, shaper_rule => fast},
       #{access => all, conflict_behaviour => kick_old,
         ip_address => "127.0.0.1",
         ip_tuple => {127, 0, 0, 1},
         ip_version => 4, module => ejabberd_service, password => "secret",
         port => 8666, proto => tcp, shaper_rule => fast},
       #{access => all, hidden_components => true, ip_address => "127.0.0.1",
         ip_tuple => {127, 0, 0, 1},
         ip_version => 4, module => ejabberd_service, password => "secret",
         port => 8189, proto => tcp, shaper_rule => fast}]},
     {loglevel, warning},
     {max_fsm_queue, 1000},
     {mongooseimctl_access_commands, []},
     {outgoing_pools,
      [{rdbms, global, default,
        [{workers, 5}],
        [{server,
          {pgsql, "localhost", "ejabberd", "ejabberd", "mongooseim_secret",
           [{ssl, required},
            {ssl_opts,
             [{cacertfile, "priv/ca.pem"},
              {server_name_indication, disable},
              {verify, verify_peer}]}]}}]},
       {redis, <<"localhost">>, global_distrib, [{workers, 10}], []}]},
     {outgoing_s2s_port, 5299},
     {rdbms_server_type, generic},
     {registration_timeout, infinity},
     {routing_modules, mongoose_router:default_routing_modules()},
     {s2s_certfile, "tools/ssl/mongooseim/server.pem"},
     {s2s_use_starttls, optional},
     {services,
      [{service_admin_extra,
        [{submods,
          [node, accounts, sessions, vcard, gdpr, upload, roster, last, private,
           stanza, stats]}]},
       {service_mongoose_system_metrics,
        [{initial_report, 300000}, {periodic_report, 10800000}]}]},
     {sm_backend, {mnesia, []}},
     {{auth, <<"anonymous.localhost">>},
      (default_auth())#{anonymous => #{allow_multiple_connections => true,
                                       protocol => both},
                        methods => [anonymous]}},
     {{auth, <<"localhost">>},
      (default_auth())#{methods => [rdbms],
                        password => #{format => scram,
                                      hash => [sha256],
                                      scram_iterations => 64},
                        rdbms => #{users_number_estimate => false}}},
     {{auth, <<"localhost.bis">>},
      (default_auth())#{methods => [rdbms],
                        password => #{format => scram,
                                      hash => [sha256],
                                      scram_iterations => 64},
                        rdbms => #{users_number_estimate => false}}},
     {{modules, <<"anonymous.localhost">>}, pgsql_modules()},
     {{modules, <<"localhost">>}, pgsql_modules()},
     {{modules, <<"localhost.bis">>}, pgsql_modules()},
     {{replaced_wait_timeout, <<"anonymous.localhost">>}, 2000},
     {{replaced_wait_timeout, <<"localhost">>}, 2000},
     {{replaced_wait_timeout, <<"localhost.bis">>}, 2000},
     {s2s_address, #{<<"fed1">> => "127.0.0.1"}},
     {{s2s_default_policy, <<"anonymous.localhost">>}, allow},
     {{s2s_default_policy, <<"localhost">>}, allow},
     {{s2s_default_policy, <<"localhost.bis">>}, allow},
     {{access, c2s, global}, [{deny, blocked}, {allow, all}]},
     {{access, c2s_shaper, global}, [{none, admin}, {normal, all}]},
     {{access, local, global}, [{allow, local}]},
     {{access, mam_get_prefs, global}, [{default, all}]},
     {{access, mam_get_prefs_global_shaper, global},
      [{mam_global_shaper, all}]},
     {{access, mam_get_prefs_shaper, global}, [{mam_shaper, all}]},
     {{access, mam_lookup_messages, global}, [{default, all}]},
     {{access, mam_lookup_messages_global_shaper, global},
      [{mam_global_shaper, all}]},
     {{access, mam_lookup_messages_shaper, global}, [{mam_shaper, all}]},
     {{access, mam_set_prefs, global}, [{default, all}]},
     {{access, mam_set_prefs_global_shaper, global},
      [{mam_global_shaper, all}]},
     {{access, mam_set_prefs_shaper, global}, [{mam_shaper, all}]},
     {{access, max_user_offline_messages, global},
      [{5000, admin}, {100, all}]},
     {{access, max_user_sessions, global}, [{10, all}]},
     {{access, muc, global}, [{allow, all}]},
     {{access, muc_admin, global}, [{allow, admin}]},
     {{access, muc_create, global}, [{allow, local}]},
     {{access, register, global}, [{allow, all}]},
     {{access, s2s_shaper, global}, [{fast, all}]},
     {{acl, local, global}, [#{user_regexp => <<>>, match => current_domain}]},
     {{shaper, fast, global}, {maxrate, 50000}},
     {{shaper, mam_global_shaper, global}, {maxrate, 1000}},
     {{shaper, mam_shaper, global}, {maxrate, 1}},
     {{shaper, normal, global}, {maxrate, 1000}}];
options("outgoing_pools") ->
    [{all_metrics_are_global, false},
     {default_server_domain, <<"localhost">>},
     {hide_service_name, false},
     {host_types, []},
     {hosts,
      [<<"localhost">>, <<"anonymous.localhost">>, <<"localhost.bis">>]},
     {language, <<"en">>},
     {listen, []},
     {loglevel, warning},
     {mongooseimctl_access_commands, []},
     {outgoing_pools,
      [{cassandra, global, default, [],
        [{keyspace, "big_mongooseim"},
         {servers,
          [{"cassandra_server1.example.com", 9042},
           {"cassandra_server2.example.com", 9042}]}]},
       {elastic, global, default, [], [{host, "localhost"}]},
       {http, global, mongoose_push_http,
        [{workers, 50}],
        [{server, "https://localhost:8443"},
         {path_prefix, "/"},
         {request_timeout, 2000}]},
       {ldap, host, default,
        [{workers, 5}],
        [{password, "ldap-admin-password"},
         {rootdn, "cn=admin,dc=example,dc=com"},
         {servers, ["ldap-server.example.com"]}]},
       {rabbit, host, event_pusher,
        [{workers, 20}],
        [{amqp_host, "localhost"},
         {amqp_password, "guest"},
         {amqp_port, 5672},
         {amqp_username, "guest"},
         {confirms_enabled, true},
         {max_worker_queue_len, 100}]},
       {rdbms, global, default,
        [{workers, 5}],
        [{server,
          {pgsql, "localhost", "ejabberd", "ejabberd", "mongooseim_secret",
           [{ssl, required},
            {ssl_opts,
             [{cacertfile, "priv/ca.pem"},
              {server_name_indication, disable},
              {verify, verify_peer}]}]}},
         {keepalive_interval, 30}]},
       {redis, <<"localhost">>, global_distrib, [{workers, 10}], []},
       {riak, global, default,
        [{strategy, next_worker}, {workers, 20}],
        [{address, "127.0.0.1"},
         {credentials, "username", "pass"},
         {port, 8087},
         {ssl_opts,
          [{certfile, "path/to/cert.pem"},
           {keyfile, "path/to/key.pem"},
           {verify, verify_peer}]},
         {cacertfile, "path/to/cacert.pem"}]}]},
     {rdbms_server_type, generic},
     {registration_timeout, 600},
     {routing_modules, mongoose_router:default_routing_modules()},
     {sm_backend, {mnesia, []}},
     {{auth, <<"anonymous.localhost">>}, default_auth()},
     {{auth, <<"localhost">>}, default_auth()},
     {{auth, <<"localhost.bis">>}, default_auth()},
     {{modules, <<"anonymous.localhost">>}, #{}},
     {{modules, <<"localhost">>}, #{}},
     {{modules, <<"localhost.bis">>}, #{}},
     {{replaced_wait_timeout, <<"anonymous.localhost">>}, 2000},
     {{replaced_wait_timeout, <<"localhost">>}, 2000},
     {{replaced_wait_timeout, <<"localhost.bis">>}, 2000}];
options("s2s_only") ->
    [{all_metrics_are_global, false},
     {default_server_domain, <<"localhost">>},
     {hide_service_name, false},
     {host_types, []},
     {hosts, [<<"localhost">>, <<"dummy_host">>]},
     {language, <<"en">>},
     {listen, []},
     {loglevel, warning},
     {mongooseimctl_access_commands, []},
     {outgoing_s2s_families, [ipv4, ipv6]},
     {outgoing_s2s_port, 5299},
     {outgoing_s2s_timeout, 10000},
     {rdbms_server_type, generic},
     {registration_timeout, 600},
     {routing_modules, mongoose_router:default_routing_modules()},
     {s2s_certfile, "tools/ssl/mongooseim/server.pem"},
     {s2s_ciphers, "TLSv1.2:TLSv1.3"},
     {s2s_dns_options, [{retries, 1}, {timeout, 30}]},
     {s2s_use_starttls, optional},
     {sm_backend, {mnesia, []}},
     {domain_certfile, #{<<"example.com">> => "/path/to/example_com.pem",
                        <<"example.org">> => "/path/to/example_org.pem"}},
     {{auth, <<"dummy_host">>}, default_auth()},
     {{auth, <<"localhost">>}, default_auth()},
     {{modules, <<"dummy_host">>}, #{}},
     {{modules, <<"localhost">>}, #{}},
     {{replaced_wait_timeout, <<"dummy_host">>}, 2000},
     {{replaced_wait_timeout, <<"localhost">>}, 2000},
     {s2s_address, #{<<"fed1">> => "127.0.0.1",
                    <<"fed2">> => {"127.0.0.1", 8765}}},
     {{s2s_default_policy, <<"dummy_host">>}, allow},
     {{s2s_default_policy, <<"localhost">>}, allow},
     {{s2s_max_retry_delay, <<"dummy_host">>}, 30},
     {{s2s_max_retry_delay, <<"localhost">>}, 30},
     {{s2s_shared, <<"dummy_host">>}, <<"shared secret">>},
     {{s2s_shared, <<"localhost">>}, <<"shared secret">>},
     {{s2s_host_policy, <<"dummy_host">>}, #{<<"fed1">> => allow,
                                           <<"reg1">> => deny}},
     {{s2s_host_policy, <<"localhost">>}, #{<<"fed1">> => allow,
                                          <<"reg1">> => deny}}].

all_modules() ->
    #{mod_mam_rdbms_user => [{muc, true}, {pm, true}],
      mod_event_pusher_hook_translator => [],
      mod_mam_muc =>
          [{archive_chat_markers, true},
           {async_writer, [{enabled, false}]},
           {full_text_search, true},
           {host, {fqdn, <<"muc.example.com">>}},
           {is_archivable_message, mod_mam_utils}],
      mod_caps => [{cache_life_time, 86}, {cache_size, 1000}],
      mod_mam_cache_user => [{muc, true}, {pm, true}],
      mod_offline =>
          [{access_max_user_messages, max_user_offline_messages},
           {backend, riak},
           {bucket_type, <<"offline">>}],
      mod_ping =>
          [{ping_interval, 60000},
           {ping_req_timeout, 32000},
           {send_pings, true},
           {timeout_action, none}],
      mod_event_pusher =>
          [{backends,
            [{http,
              [{callback_module, mod_event_pusher_http_defaults},
               {path, "/notifications"},
               {pool_name, http_pool}]},
             {push,
              [{backend, mnesia},
               {plugin_module, mod_event_pusher_push_plugin_defaults},
               {virtual_pubsub_hosts,
                [{fqdn, <<"host1">>}, {fqdn, <<"host2">>}]},
               {wpool, [{workers, 200}]}]},
             {rabbit,
              [{chat_msg_exchange,
                [{name, <<"chat_msg">>},
                 {recv_topic, <<"chat_msg_recv">>},
                 {sent_topic, <<"chat_msg_sent">>}]},
               {groupchat_msg_exchange,
                [{name, <<"groupchat_msg">>},
                 {recv_topic, <<"groupchat_msg_recv">>},
                 {sent_topic, <<"groupchat_msg_sent">>}]},
               {presence_exchange,
                [{name, <<"presence">>}, {type, <<"topic">>}]}]},
             {sns,
              [{access_key_id, "AKIAIOSFODNN7EXAMPLE"},
               {account_id, "123456789012"},
               {muc_messages_topic, "user_messagegroup_sent"},
               {plugin_module, mod_event_pusher_sns_defaults},
               {pm_messages_topic, "user_message_sent"},
               {pool_size, 100},
               {presence_updates_topic, "user_presence_updated"},
               {publish_retry_count, 2},
               {publish_retry_time_ms, 50},
               {region, "eu-west-1"},
               {secret_access_key,
                "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"},
               {sns_host, "sns.eu-west-1.amazonaws.com"}]}]}],
      mod_event_pusher_push =>
          [{backend, mnesia},
           {plugin_module, mod_event_pusher_push_plugin_defaults},
           {virtual_pubsub_hosts, [{fqdn, <<"host1">>}, {fqdn, <<"host2">>}]},
           {wpool, [{workers, 200}]}],
      mod_adhoc => [{iqdisc, one_queue}, {report_commands_node, true}],
      mod_mam_rdbms_arch_async => [{pm, []}],
      mod_keystore =>
          [{keys,
            [{access_secret, ram},
             {access_psk, {file, "priv/access_psk"}},
             {provision_psk, {file, "priv/provision_psk"}}]},
           {ram_key_size, 1000}],
      mod_global_distrib =>
          [{bounce, [{max_retries, 3}, {resend_after_ms, 300}]},
           {cache, [{domain_lifetime_seconds, 60}]},
           {connections,
            [{advertised_endpoints, [{"172.16.0.2", 5555}]},
             {connections_per_endpoint, 30},
             {endpoints, [{"172.16.0.2", 5555}]},
             {tls_opts, [{cafile, "priv/ca.pem"}, {certfile, "priv/dc1.pem"}]}]},
           {global_host, "example.com"},
           {local_host, "datacenter1.example.com"},
           {redis, [{pool, global_distrib}]}],
      mod_pubsub =>
          [{access_createnode, pubsub_createnode},
           {backend, rdbms},
           {ignore_pep_from_offline, false},
           {last_item_cache, mnesia},
           {max_items_node, 1000},
           {pep_mapping, [{<<"urn:xmpp:microblog:0">>, <<"mb">>}]},
           {plugins, [<<"flat">>, <<"pep">>]}],
      mod_version => [{os_info, true}],
      mod_auth_token =>
          [{{validity_period, access}, {13, minutes}},
           {{validity_period, refresh}, {13, days}}],
      mod_carboncopy => [{iqdisc, no_queue}],
      mod_mam =>
          [{archive_chat_markers, true},
           {full_text_search, false},
           {is_archivable_message, mod_mam_utils},
           {no_stanzaid_element, true}],
      mod_disco =>
          [{extra_domains, [<<"some_domain">>, <<"another_domain">>]},
           {iqdisc, one_queue},
           {server_info,
            [[{name, <<"abuse-address">>}, {urls, [<<"admin@example.com">>]}],
             [{modules, [mod_muc, mod_disco]},
              {name, <<"friendly-spirits">>},
              {urls, [<<"spirit1@localhost">>, <<"spirit2@localhost">>]}]]},
           {users_can_see_hidden_services, true}],
      mod_last => [{backend, mnesia}, {iqdisc, {queues, 10}}],
      mod_shared_roster_ldap =>
          [{ldap_base, "ou=Users,dc=ejd,dc=com"},
           {ldap_filter, "(objectClass=inetOrgPerson)"},
           {ldap_group_cache_validity, 1},
           {ldap_groupattr, "ou"},
           {ldap_memberattr, "cn"},
           {ldap_rfilter, "(objectClass=inetOrgPerson)"},
           {ldap_user_cache_validity, 1},
           {ldap_userdesc, "cn"}],
      mod_mam_mnesia_prefs => [{muc, true}],
      mod_jingle_sip =>
          [{listen_port, 5600},
           {local_host, "localhost"},
           {proxy_host, "localhost"},
           {proxy_port, 5600},
           {sdp_origin, "127.0.0.1"}],
      mod_mam_rdbms_prefs => [{pm, true}],
      mod_extdisco =>
          [[{host, "stun1"},
            {password, "password"},
            {port, 3478},
            {transport, "udp"},
            {type, stun},
            {username, "username"}],
           [{host, "stun2"},
            {password, "password"},
            {port, 2222},
            {transport, "tcp"},
            {type, stun},
            {username, "username"}],
           [{host, "192.168.0.1"}, {type, turn}]],
      mod_csi => [{buffer_max, 40}],
      mod_muc_log =>
          [{access_log, muc},
           {cssfile, <<"path/to/css/file">>},
           {outdir, "www/muc"},
           {top_link, {"/", "Home"}}],
      mod_http_upload =>
          [{backend, s3},
           {expiration_time, 120},
           {host, {prefix, <<"upload.">>}},
           {s3, [{access_key_id, "AKIAIOSFODNN7EXAMPLE"},
                {add_acl, true},
                {bucket_url, "https://s3-eu-west-1.amazonaws.com/mybucket"},
                {region, "eu-west-1"},
                {secret_access_key, "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"}]}],
      mod_muc_light =>
          [{rooms_per_user, 10},
           {rooms_per_page, 5},
           {rooms_in_rosters, true},
           {max_occupants, 50},
           {legacy_mode, true},
           {host, {fqdn, <<"muclight.example.com">>}},
           {equal_occupants, true},
           {config_schema,
            [{<<"display-lines">>, 30, display_lines, integer},
             {<<"roomname">>, <<"The Room">>, roomname, binary}]},
           {blocking, false},
           {all_can_invite, true},
           {all_can_configure, true}],
      mod_push_service_mongoosepush =>
          [{api_version, "v3"},
           {max_http_connections, 100},
           {pool_name, mongoose_push_http}],
      mod_event_pusher_sns =>
          [{access_key_id, "AKIAIOSFODNN7EXAMPLE"},
           {account_id, "123456789012"},
           {muc_messages_topic, "user_messagegroup_sent"},
           {plugin_module, mod_event_pusher_sns_defaults},
           {pm_messages_topic, "user_message_sent"},
           {pool_size, 100},
           {presence_updates_topic, "user_presence_updated"},
           {publish_retry_count, 2},
           {publish_retry_time_ms, 50},
           {region, "eu-west-1"},
           {secret_access_key, "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"},
           {sns_host, "sns.eu-west-1.amazonaws.com"}],
      mod_roster => [{store_current_id, true}, {versioning, true}],
      mod_event_pusher_http =>
          [{configs,
            [[{callback_module, mod_event_pusher_http_defaults},
              {path, "/notifications"},
              {pool_name, http_pool}]]}],
      mod_inbox =>
          [{aff_changes, true},
           {groupchat, [muclight]},
           {remove_on_kicked, true},
           {reset_markers, [<<"displayed">>]}],
      mod_mam_meta =>
          [{archive_chat_markers, true},
           {backend, rdbms},
           {full_text_search, true},
           {is_archivable_message, mod_mam_utils},
           {muc,
            [{async_writer, [{enabled, false}]},
             {host, {fqdn, <<"muc.example.com">>}},
             {rdbms_message_format, simple},
             {user_prefs_store, mnesia}]},
           {no_stanzaid_element, true},
           {pm, [{full_text_search, false}, {user_prefs_store, rdbms}]}],
      mod_register =>
          [{access, all},
           {password_strength, 32},
           {registration_watchers, [<<"JID1">>, <<"JID2">>]},
           {welcome_message, {"Subject", "Body"}}],
      mod_mam_rdbms_arch => [{no_writer, true}, {pm, true}],
      mod_event_pusher_rabbit =>
          [{chat_msg_exchange,
            [{name, <<"chat_msg">>},
             {recv_topic, <<"chat_msg_recv">>},
             {sent_topic, <<"chat_msg_sent">>}]},
           {groupchat_msg_exchange,
            [{name, <<"groupchat_msg">>},
             {recv_topic, <<"groupchat_msg_recv">>},
             {sent_topic, <<"groupchat_msg_sent">>}]},
           {presence_exchange, [{name, <<"presence">>}, {type, <<"topic">>}]}],
      mod_bosh =>
          [{inactivity, 20}, {maxpause, 120}, {max_wait, infinity}, {server_acks, true}],
      mod_muc =>
          [{access, muc},
           {access_create, muc_create},
           {default_room_options,
            [{affiliations,
              [{{<<"alice">>, <<"localhost">>, <<"resource1">>}, member},
               {{<<"bob">>, <<"localhost">>, <<"resource2">>}, owner}]},
             {password_protected, true}]},
           {host, {fqdn, <<"muc.example.com">>}},
           {http_auth_pool, my_auth_pool}],
      mod_vcard =>
          [{host, {fqdn, <<"directory.example.com">>}},
           {ldap_search_fields,
            [{<<"User">>, <<"%u">>}, {<<"Full Name">>, <<"displayName">>}]},
           {ldap_search_reported,
            [{<<"Full Name">>, <<"FN">>}, {<<"Given Name">>, <<"FIRST">>}]},
           {ldap_vcard_map,
            [{<<"FAMILY">>, <<"%s">>, [<<"sn">>]},
             {<<"FN">>, <<"%s">>, [<<"displayName">>]}]},
           {matches, 1},
           {search, true}],
      mod_mam_muc_rdbms_arch =>
          [{muc, true}, {db_jid_format, mam_jid_rfc}, {db_message_format, mam_message_xml}],
      mod_stream_management =>
          [{ack_freq, 1},
           {buffer_max, 30},
           {resume_timeout, 600},
           {stale_h,
            [{enabled, true},
             {stale_h_geriatric, 3600},
             {stale_h_repeat_after, 1800}]}]}.

pgsql_modules() ->
    #{mod_adhoc => [], mod_amp => [], mod_blocking => [], mod_bosh => [],
      mod_carboncopy => [], mod_commands => [],
      mod_disco => [{users_can_see_hidden_services, false}],
      mod_last => [{backend, rdbms}],
      mod_muc_commands => [], mod_muc_light_commands => [],
      mod_offline => [{backend, rdbms}],
      mod_privacy => [{backend, rdbms}],
      mod_private => [{backend, rdbms}],
      mod_register =>
          [{access, register},
           {ip_access, [{allow, "127.0.0.0/8"}, {deny, "0.0.0.0/0"}]},
           {welcome_message, {"Hello", "I am MongooseIM"}}],
      mod_roster => [{backend, rdbms}],
      mod_sic => [], mod_stream_management => [],
      mod_vcard => [{backend, rdbms}, {host, {prefix, <<"vjud.">>}}]}.

auth_with_methods(Methods) ->
    maps:merge(default_auth(), Methods#{methods => lists:sort(maps:keys(Methods))}).

custom_auth() ->
    maps:merge(default_auth(), extra_auth()).

extra_auth() ->
    #{anonymous => #{allow_multiple_connections => true,
                     protocol => sasl_anon},
      http => #{basic_auth => "admin:admin"},
      external => #{instances => 1,
                    program => "/usr/bin/authenticator"},
      jwt => #{algorithm => <<"RS256">>,
               secret => {value, "secret123"},
               username_key => user},
      ldap => #{base => <<"ou=Users,dc=esl,dc=com">>,
                bind_pool_tag => bind,
                deref => never,
                dn_filter => {<<"(&(name=%s)(owner=%D)(user=%u@%d))">>, [<<"sn">>]},
                filter => <<"(&(objectClass=shadowAccount)(memberOf=Jabber Users))">>,
                local_filter => {equal, {"accountStatus", ["enabled"]}},
                pool_tag => default,
                uids => [<<"uid">>, {<<"uid2">>, <<"%u">>}]},
      methods => [anonymous, external, http, jwt, ldap, rdbms, riak],
      rdbms => #{users_number_estimate => true},
      riak => #{bucket_type => <<"user_bucket">>}}.

default_auth() ->
    #{methods => [],
      password => #{format => scram,
                    scram_iterations => 10000},
      sasl_external => [standard],
      sasl_mechanisms => cyrsasl:default_modules()}.