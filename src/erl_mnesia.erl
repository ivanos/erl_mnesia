-module(erl_mnesia).
-behaviour(gen_server).

%% ------------------------------------------------------------------
%% API Function Exports
%% ------------------------------------------------------------------

-export([start_link/0,
         tables/1]).

%% ------------------------------------------------------------------
%% gen_server Function Exports
%% ------------------------------------------------------------------

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

%% ------------------------------------------------------------------
%% API Function Definitions
%% ------------------------------------------------------------------

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

tables(TableDefs) ->
    gen_server:call(?MODULE, {tables, TableDefs}).

%% ------------------------------------------------------------------
%% gen_server Function Definitions
%% ------------------------------------------------------------------

init(_) ->
    Options = application:get_env(erl_mnesia, options, []),
    gen_server:cast(self(), start),
    {ok, #{options => options(Options)}}.

handle_call({tables, TableDefs}, _From, State) ->
    ok = maybe_tables(TableDefs),
    {reply, ok, State};
handle_call(Request, _From, State) ->
    {stop, {unimplemented, call, Request}, State}.

handle_cast(start, State = #{options := Options}) ->
    ok = maybe_persistent(Options, disc_schema()),
    {noreply, State};
handle_cast(Msg, State) ->
    {stop, {unimplemented, cast, Msg}, State}.

handle_info(Info, State) ->
    {stop, {unimplemented, info, Info}, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% ------------------------------------------------------------------
%% Internal Function Definitions
%% ------------------------------------------------------------------

options(Options) ->
    options(Options, #{persistent => false}).

options([], OptionMap) ->
    OptionMap;
options([persistent | Rest], OptionMap) ->
    options(Rest, OptionMap#{persistent := true}).

maybe_persistent(#{persistent := false}, _) ->
    ok;
maybe_persistent(#{persistent := true}, true) ->
    ok;
maybe_persistent(#{persistent := true}, false) ->
    % Schema is not on disk.  Assume this is the initial setup
    % and move the schema to disk.
    {atomic, ok} = mnesia:change_table_copy_type(schema, node(), disc_copies),
    ok.

disc_schema() ->
    case mnesia:table_info(schema, disc_copies) of
        [] -> false;
        _ -> true
    end.

maybe_tables(TableDefs) ->
    ExistingTables = mnesia:system_info(tables),
    IsTable = fun(N) -> lists:member(N, ExistingTables) end,
    lists:foreach(
        fun({Name, Def}) ->
            ok = maybe_table(Name, Def, IsTable(Name))
        end, TableDefs).

maybe_table(_, _, true) ->
    % table exists already, no need to create it
    ok;
maybe_table(Name, Def, false) ->
    {atomic, ok} = mnesia:create_table(Name, Def),
    ok.
