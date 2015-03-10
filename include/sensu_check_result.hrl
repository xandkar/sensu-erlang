-record(sensu_check_result,
    { name              :: binary()
    , output            :: binary()
    , status            :: sensu:check_status()
    , extra_params = [] :: sensu_json:object()
    }).
