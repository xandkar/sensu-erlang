[![Build Status](https://travis-ci.org/ibnfirnas/sensu-erlang.svg?branch=master)](https://travis-ci.org/ibnfirnas/sensu-erlang)

# sensu-erlang
Erlang API to send check result to Sensu client.

### Defaults

- host: `"localhost"`
- port: `3030`
- protocol: `{udp, {udp_port, 3031}}`

### Examples

Default IO parameters (see `include/sensu_io_params.hrl`):
```erlang
-include_lib("sensu/include/sensu_check_result.hrl").

CheckResult =
    #sensu_check_result
    { name   = <<"lord.business.sanity_check">>
    , output = <<"Everything is awesome!">>
    , status = ok
    },
{ok, ok} = sensu:send(CheckResult)
```

Custom host and UDP ports:
```erlang
-include_lib("sensu/include/sensu_check_result.hrl").
-include_lib("sensu/include/sensu_io_params.hrl").

CheckResult =
    #sensu_check_result
    { name   = <<"lord.business.sanity_check">>
    , output = <<"Everything is awesome!">>
    , status = ok
    },
IOParams =
    #sensu_io_params
    { host = "example.local"
    , port = 4000
    , protocol = {udp, {udp_port, 5000}}
    },
{ok, ok} = sensu:send(CheckResult, IOParams)
```

TCP with default port and host:
```erlang
-include_lib("sensu/include/sensu_check_result.hrl").
-include_lib("sensu/include/sensu_io_params.hrl").

CheckResult =
    #sensu_check_result
    { name   = <<"lord.business.sanity_check">>
    , output = <<"Everything is awesome!">>
    , status = ok
    },
{ok, ok} = sensu:send(CheckResult, #sensu_io_params{protocol = {tcp, {tcp_timeout, 5000}}})
```
