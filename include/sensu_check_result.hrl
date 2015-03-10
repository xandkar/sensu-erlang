-record(sensu_check_result,
    { name              :: binary()
    , output            :: binary()
    , status            :: sensu_check_status:t()
    , extra_params = [] :: sensu_json:object()
    }).
