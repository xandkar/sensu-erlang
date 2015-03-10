-module(sensu_json).

-export_type(
    [ t/0
    , array/0
    , object/0
    , property/0
    ]).

-export(
    [ to_bin/1
    ]).

-type array() ::
    [t()].

-type property() ::
    {binary(), t()}.

-type object() ::
    [property()].

-type t() ::
      null
    | boolean()
    | integer()
    | float()
    | binary()
    | array()
    | object()
    .

-spec to_bin(t()) ->
    binary().
to_bin(T) ->
    jsx:encode(T).
