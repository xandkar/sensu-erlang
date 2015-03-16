-record(sensu_io_params,
    { dst_host = "localhost"                 :: inet:hostname() | inet:ip_address()
    , dst_port = 3030                        :: inet:port_number()
    , protocol = {udp, {udp_src_port, 3031}} :: sensu:io_protocol()
    }).
