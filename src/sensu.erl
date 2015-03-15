-module(sensu).

-include("sensu_check_result.hrl").
-include("sensu_io_params.hrl").

-export_type(
    [ check_status/0
    , check_result/0
    , io_protocol/0
    , io_params/0
    , io_error/0
    ]).

-export(
    [ send/1
    , send/2
    ]).

-type check_status() ::
      ok
    | warning
    | critical
    .

-type udp_socket_or_port() ::
      {udp_port  , inet:port_number()}
    | {udp_socket, gen_udp:socket()}
    .

-type tcp_socket_or_timeout() ::
      {tcp_timeout , timeout()}
    | {tcp_socket  , gen_tcp:socket()}
    .

-type io_protocol() ::
      {udp, udp_socket_or_port()}
    | {tcp, tcp_socket_or_timeout()}
    .

-type check_result() ::
    #sensu_check_result{}.

-type io_params() ::
    #sensu_io_params{}.

-type io_error() ::
    sensu_socket:io_error().

-spec send(check_result()) ->
    hope_result:t(ok, io_error()).
send(#sensu_check_result{}=CheckResult) ->
    send(CheckResult, #sensu_io_params{}).

-spec send(check_result(), io_params()) ->
    hope_result:t(ok, io_error()).
send(#sensu_check_result{}=CheckResult, #sensu_io_params{}=IOParams) ->
    Connect =
        fun ({}) -> sensu_socket:open_if_not_provided(IOParams) end,
    Send =
        fun (Socket) ->
            CheckResultBin = check_result_to_bin(CheckResult),
            sensu_socket:send_and_close_if_opened_by_us(Socket, CheckResultBin)
        end,
    hope_result:pipe([Connect, Send], {}).

-spec check_result_to_bin(check_result()) ->
    binary().
check_result_to_bin(CheckResult) ->
    Json = check_result_to_json(CheckResult),
    sensu_json:to_bin(Json).

-spec check_result_to_json(check_result()) ->
    sensu_json:t().
check_result_to_json(#sensu_check_result
    { name         = <<Name/binary>>
    , output       = <<Output/binary>>
    , status       = Status
    , extra_params = ExtraParams
    }
) ->
    [ {<<"name">>   , Name}
    , {<<"output">> , Output}
    , {<<"status">> , check_status_to_integer(Status)}
    | ExtraParams
    ].

-spec check_status_to_integer(check_status()) ->
    non_neg_integer().
check_status_to_integer(ok)       -> 0;
check_status_to_integer(warning)  -> 1;
check_status_to_integer(critical) -> 2.
