-module(sensu_socket).

-include("sensu_io_params.hrl").

-export_type(
    [ t/0
    , io_error/0
    ]).

-export(
    [ open_if_not_provided/1
    , send_and_close_if_opened_by_us/2
    ]).

-record(udp_destination,
    { socket  :: gen_udp:socket()
    , address :: inet:hostname() | inet:ip_address()
    , port    :: inet:port_number()
    }).

-type udp_destination() ::
    #udp_destination{}.

-type origin() ::
      opened_by_us
    | provided_by_user
    .

-type t() ::
      {udp, origin(), udp_destination()}
    | {tcp, origin(), gen_tcp:socket()}
    .

-type io_error() ::
    {sensu_io_error, term()}.

-spec open_if_not_provided(sensu:io_params()) ->
    hope_result:t(t(), io_error()).
open_if_not_provided(#sensu_io_params
    { dst_host = Host
    , dst_port = Port
    , protocol = Protocol
    }
) ->
    case Protocol
    of  {udp, SocketOrPort} ->
            case open_udp(SocketOrPort)
            of  {ok, {LifeSpan, Socket}} ->
                    UDPDst =
                        #udp_destination
                        { socket  = Socket
                        , address = Host
                        , port    = Port
                        },
                    {ok, {udp, LifeSpan, UDPDst}}
            ;   {error, _}=Error ->
                    Error
            end
    ;   {tcp, {tcp_socket, Socket}} ->
            {ok, {tcp, provided_by_user, Socket}}
    ;   {tcp, {tcp_timeout, Timeout}} ->
            Options = [],
            case gen_tcp:connect(Host, Port, Options, Timeout)
            of  {ok, Socket} ->
                    {ok, {tcp, opened_by_us, Socket}}
            ;   {error, Reason} ->
                    io_error_return(Reason)
            end
    end.

open_udp({udp_socket, Socket}) ->
    {ok, {provided_by_user, Socket}};
open_udp({udp_src_port, Port}) ->
    case gen_udp:open(Port)
    of  {ok, Socket} ->
            {ok, {opened_by_us, Socket}}
    ;   {error, Reason} ->
            io_error_return(Reason)
    end.

-spec send_and_close_if_opened_by_us(t(), binary()) ->
    hope_result:t({}, io_error()).
send_and_close_if_opened_by_us(T, Packet) ->
    {M, A} =
        case T
        of  {udp, _, #udp_destination{socket=Sock, address=Adrr, port=Port}} ->
                {gen_udp, [Sock, Adrr, Port, Packet]}
        ;   {tcp, _, Socket} ->
                {gen_tcp, [Socket, Packet]}
        end,
    Result =
        case erlang:apply(M, send, A)
        of  ok              -> {ok, {}}
        ;   {error, Reason} -> io_error_return(Reason)
        end,
    ok = close_if_opened_by_us(T),
    Result.

-spec close_if_opened_by_us(t()) ->
    ok.
close_if_opened_by_us({tcp, provided_by_user, _}) ->
    ok;
close_if_opened_by_us({tcp, opened_by_us, Socket}) ->
    ok = gen_tcp:close(Socket);
close_if_opened_by_us({udp, provided_by_user, _}) ->
    ok;
close_if_opened_by_us({udp, opened_by_us, #udp_destination{socket=S}}) ->
    ok = gen_udp:close(S).

-spec io_error_return(term()) ->
    {error, io_error()}.
io_error_return(Reason) ->
    {error, {sensu_io_error, Reason}}.
