[![Build Status](https://travis-ci.org/ibnfirnas/sensu-erlang.svg?branch=master)](https://travis-ci.org/ibnfirnas/sensu-erlang)

# sensu-erlang
Erlang API to send external check result to Sensu client

### Defaults

- host: `"localhost"`
- port: `3030`
- protocol: `{udp, {udp_src_port, 3031}}`

### Examples

Note that, in order to not pollute your namespace, public records are
fully-qualified and placed in dedicated include files.

```erlang
-include_lib("sensu/include/sensu_check_result.hrl").
-include_lib("sensu/include/sensu_io_params.hrl").

CheckResult =
    #sensu_check_result
    { name   = <<"lord.business.sanity_check">>
    , output = <<"Everything is awesome!">>
    , status = ok
    },

% Default IO parameters (see `include/sensu_io_params.hrl`):
{ok, {}} = sensu:send(CheckResult)

% Custom host and UDP ports:
IOParams =
    #sensu_io_params
    { dst_host = "example.local"
    , dst_port = 4000
    , protocol = {udp, {udp_src_port, 5000}}
    },
{ok, {}} = sensu:send(CheckResult, IOParams)

% TCP with default port and host:
{ok, {}} = sensu:send(CheckResult, #sensu_io_params{protocol = {tcp, {tcp_timeout, 5000}}})

% TCP with existing socket:
{ok, {}} = sensu:send(CheckResult, #sensu_io_params{protocol = {tcp, {tcp_socket, Socket}}})
```
