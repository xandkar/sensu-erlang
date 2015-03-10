# sensu-erlang
Erlang API to send check result to Sensu client.

### Example
```erlang
-include_lib("sensu/include/sensu_check_result.hrl").
-include_lib("sensu/include/sensu_io_params.hrl").

CheckResult =
    #sensu_check_result
    { name   = <<"lord.business.sanity_check">>
    , output = <<"Everything is awesome!">>
    , status = ok
    },
{ok, ok} = sensu:send(CheckResult, #sensu_io_params{})
```
