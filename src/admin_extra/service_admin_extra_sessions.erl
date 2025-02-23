%%%-------------------------------------------------------------------
%%% File    : service_admin_extra_sessions.erl
%%% Author  : Badlop <badlop@process-one.net>, Piotr Nosek <piotr.nosek@erlang-solutions.com>
%%% Purpose : Contributed administrative functions and commands
%%% Created : 10 Aug 2008 by Badlop <badlop@process-one.net>
%%%
%%%
%%% ejabberd, Copyright (C) 2002-2008   ProcessOne
%%%
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License as
%%% published by the Free Software Foundation; either version 2 of the
%%% License, or (at your option) any later version.
%%%
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%%% General Public License for more details.
%%%
%%% You should have received a copy of the GNU General Public License
%%% along with this program; if not, write to the Free Software
%%% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
%%%
%%%-------------------------------------------------------------------

-module(service_admin_extra_sessions).
-author('badlop@process-one.net').

-export([
    commands/0,

    num_resources/2,
    resource_num/3,
    kick_session/2,
    kick_session/4,
    status_num/2, status_num/1,
    status_list/2, status_list/1,
    connected_users_info/0,
    connected_users_info/1,
    set_presence/7,
    user_sessions_info/2
    ]).

-ignore_xref([
    commands/0, num_resources/2, resource_num/3, kick_session/2, kick_session/4,
    status_num/2, status_num/1, status_list/2, status_list/1,
    connected_users_info/0, connected_users_info/1, set_presence/7,
    user_sessions_info/2
]).

-include("ejabberd_commands.hrl").

-type status() :: mongoose_session_api:status().

%%%
%%% Register commands
%%%

-spec commands() -> [ejabberd_commands:cmd(), ...].
commands() ->
    SessionDisplay = {list,
                      {sessions, {tuple,
                                  [{jid, string},
                                   {connection, string},
                                   {ip, string},
                                   {port, integer},
                                   {priority, integer},
                                   {node, string},
                                   {uptime, integer}
                                  ]}}
                     },

    [
        #ejabberd_commands{name = num_resources, tags = [session],
                           desc = "Get the number of resources of a user",
                           module = ?MODULE, function = num_resources,
                           args = [{user, binary}, {host, binary}],
                           result = {resources, integer}},
        #ejabberd_commands{name = resource_num, tags = [session],
                           desc = "Resource string of a session number",
                           module = ?MODULE, function = resource_num,
                           args = [{user, binary}, {host, binary}, {num, integer}],
                           result = {res, restuple}},
        #ejabberd_commands{name = kick_session, tags = [session],
                           desc = "Kick a user session",
                           module = ?MODULE, function = kick_session,
                           args = [{user, binary}, {host, binary},
                                   {resource, binary}, {reason, binary}],
                           result = {res, restuple}},
        #ejabberd_commands{name = status_num_host, tags = [session, stats],
                           desc = "Number of logged users with this status in host",
                           module = ?MODULE, function = status_num,
                           args = [{host, binary}, {status, binary}],
                           result = {users, integer}},
        #ejabberd_commands{name = status_num, tags = [session, stats],
                           desc = "Number of logged users with this status",
                           module = ?MODULE, function = status_num,
                           args = [{status, binary}],
                           result = {users, integer}},
        #ejabberd_commands{name = status_list_host, tags = [session],
                           desc = "List of users logged in host with their statuses",
                           module = ?MODULE, function = status_list,
                           args = [{host, binary}, {status, binary}],
                           result = {users, {list,
                                             {userstatus, {tuple, [
                                {user, string},
                                {host, string},
                                {resource, string},
                                {priority, integer},
                                {status, string}
                                ]}}
                                            }}},
        #ejabberd_commands{name = status_list, tags = [session],
                           desc = "List of logged users with this status",
                           module = ?MODULE, function = status_list,
                           args = [{status, binary}],
                           result = {users, {list,
                                             {userstatus, {tuple, [
                                {user, string},
                                {host, string},
                                {resource, string},
                                {priority, integer},
                                {status, string}
                                ]}}
                                            }}},
        #ejabberd_commands{name = connected_users_info,
                           tags = [session],
                           desc = "List all established sessions and their information",
                           module = ?MODULE, function = connected_users_info,
                           args = [],
                           result = {connected_users_info, SessionDisplay}},
        #ejabberd_commands{name = connected_users_vhost,
                           tags = [session],
                           desc = "Get the list of established sessions in a vhost",
                           module = ?MODULE, function = connected_users_info,
                           args = [{host, binary}],
                           result = {connected_users_vhost, SessionDisplay}},
        #ejabberd_commands{name = user_sessions_info,
                           tags = [session],
                           desc = "Get information about all sessions of a user",
                           module = ?MODULE, function = user_sessions_info,
                           args = [{user, binary}, {host, binary}],
                           result = {user_sessions_info, SessionDisplay}},

        #ejabberd_commands{name = set_presence,
                           tags = [session],
                           desc = "Set presence of a session",
                           module = ?MODULE, function = set_presence,
                           args = [{user, binary}, {host, binary},
                                   {resource, binary}, {type, binary},
                                   {show, binary}, {status, binary},
                                   {priority, binary}],
                           result = {res, rescode}}
        ].

%%%
%%% Sessions
%%%

-spec num_resources(jid:user(), jid:server()) -> non_neg_integer().
num_resources(User, Host) ->
    mongoose_session_api:num_resources(User, Host).

-spec resource_num(jid:user(), jid:server(), integer()) -> mongoose_session_api:res_number_result().
resource_num(User, Host, Num) ->
    mongoose_session_api:get_user_resource(User, Host, Num).

-spec kick_session(jid:jid(), binary()) -> mongoose_session_api:kick_session_result().
kick_session(JID, ReasonText) ->
    mongoose_session_api:kick_session(JID, ReasonText).

-spec kick_session(jid:user(), jid:server(), jid:resource(), binary()) ->
    mongoose_session_api:kick_session_result().
kick_session(User, Server, Resource, ReasonText) ->
    mongoose_session_api:kick_session(User, Server, Resource, ReasonText).

-spec status_num(jid:server(), status()) -> non_neg_integer().
status_num(Host, Status) ->
    mongoose_session_api:num_status_users(Host, Status).

-spec status_num(status()) -> non_neg_integer().
status_num(Status) ->
    mongoose_session_api:num_status_users(Status).

-spec status_list(jid:server(), status()) -> [mongoose_session_api:status_user_info()].
status_list(Host, Status) ->
    mongoose_session_api:list_status_users(Host, Status).

-spec status_list(binary()) -> [mongoose_session_api:status_user_info()].
status_list(Status) ->
    mongoose_session_api:list_status_users(Status).

-spec connected_users_info() -> mongoose_session_api:list_sessions_result().
connected_users_info() ->
    mongoose_session_api:list_sessions().

-spec connected_users_info(jid:server()) -> mongoose_session_api:list_sessions_result().
connected_users_info(Host) ->
    mongoose_session_api:list_sessions(Host).

-spec set_presence(jid:user(), jid:server(), jid:resource(),
        Type :: binary(), Show :: binary(), Status :: binary(),
        Prio :: binary()) -> ok.
set_presence(User, Host, Resource, Type, Show, Status, Priority) ->
    mongoose_session_api:set_presence(User, Host, Resource, Type, Show, Status, Priority),
    ok.

-spec user_sessions_info(jid:user(), jid:server()) -> [mongoose_session_api:session_info()].
user_sessions_info(User, Host) ->
    mongoose_session_api:list_user_sessions(User, Host).
