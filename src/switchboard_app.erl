%%------------------------------------------------------------------------------
%% All rights reserved.
%%
%% Redistribution and use in source and binary forms, with or without
%% modification, are permitted provided that the following conditions are met:
%%
%% 1. Redistributions of source code must retain the above copyright notice, this
%% list of conditions and the following disclaimer.
%%
%% 2. Redistributions in binary form must reproduce the above copyright notice,
%% this list of conditions and the following disclaimer in the documentation
%% and/or other materials provided with the distribution.
%%
%% 3. Neither the name of the copyright holder nor the names of its contributors
%% may be used to endorse or promote products derived from this software without
%% specific prior written permission.
%%
%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
%% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
%% THE POSSIBILITY OF SUCH DAMAGE.
%%
%% @author Thomas Moulia <jtmoulia@pocketknife.io>
%% @copyright Copyright (c) 2014, ThusFresh, Inc.
%% @end
%%------------------------------------------------------------------------------

%% @private
%% @doc This module implements the application behavior and starts the
%% top level switchboard supervisor.

-module(switchboard_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

-define(BASE_ROUTES,
        [{<<"/static/[...]">>, cowboy_static,
          {priv_dir, switchboard, "static"}},
         {<<"/jsclient">>, cowboy_static,
          {priv_file, switchboard, "switchboardclient.html"}},
         {<<"/workers">>, switchboard_workers, []},
         {<<"/clients">>, switchboard_jmap, []}]).


%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile(
                 [{'_', get_cowboy_routes()}]),
    Port = case application:get_env(cowboy_port) of
               undefined     -> 8080;
               {ok, EnvPort} -> EnvPort
           end,
    {ok, _}  = cowboy:start_http(switchboard_cowboy, 100,
                                 [{port, Port}],
                                 [{env, [{dispatch, Dispatch}]}]),
    switchboard_sup:start_link().

stop(_State) ->
    ok.


%% ===================================================================
%% Internal
%% ===================================================================

%% @private
%% @equiv get_cowboy_routes(?BASE_ROUTES).
get_cowboy_routes() ->
    get_cowboy_routes(?BASE_ROUTES).

%% @private
%% @doc Returns the cowboy dispatch data structure, including OAuth if configured.
get_cowboy_routes(BaseRoutes) ->
    case application:get_env(oauth_providers) of
        undefined ->
            BaseRoutes;
        {ok, OAuthProviders} ->
            [{"/auth/:provider/:action", cowboy_social, OAuthProviders} | BaseRoutes]
    end.
