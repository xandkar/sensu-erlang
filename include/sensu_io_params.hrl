-record(sensu_io_params,
    { host     = "localhost"             :: inet:hostname() | inet:ip_address()
    , port     = 3030                    :: inet:port_number()
    , protocol = {udp, {udp_port, 3031}} :: sensu:io_protocol()
    }).
