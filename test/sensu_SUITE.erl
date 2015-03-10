-module(sensu_SUITE).

-include("sensu_check_result.hrl").
-include("sensu_io_params.hrl").

%% Callbacks
-export(
    [ all/0
    , groups/0
    ]).

%% Test cases
-export(
    [ t_send_udp/1
    ]).

-define(GROUP, sensu).


%% ============================================================================
%% Common Test callbacks
%% ============================================================================

all() ->
    [ {group, ?GROUP}
    ].

groups() ->
    Tests =
        [ t_send_udp
        ],
    [ {?GROUP, [], Tests}
    ].


%% =============================================================================
%%  Test cases
%% =============================================================================

t_send_udp(_Cfg) ->
    Name      = <<"foo">>,
    Output    = <<"bar">>,
    Status    = warning,
    StatusInt = 1,
    DstHost   = "localhost",
    DstPort   = 3030,
    SrcPort   = 3031,
    CheckResult =
        #sensu_check_result
        { name   = Name
        , output = Output
        , status = Status
        },
    ClientInfo =
        #sensu_io_params
        { host     = DstHost
        , port     = DstPort
        , protocol = {udp, {port, SrcPort}}
        },
    {ok, Socket} = gen_udp:open(DstPort, [binary, {active, false}]),
    {ok, ok} = sensu:send(CheckResult, ClientInfo), 
    ResultOfReceive = gen_udp:recv(Socket, 64000),
    ok = gen_udp:close(Socket),
    {ok, {_, _, Data}} = ResultOfReceive,
    Params = jsx:decode(Data),
    P1 = Params,
    {{some, Name}     , P2} = hope_kv_list:pop(P1, <<"name">>),
    {{some, Output}   , P3} = hope_kv_list:pop(P2, <<"output">>),
    {{some, StatusInt}, []} = hope_kv_list:pop(P3, <<"status">>).
