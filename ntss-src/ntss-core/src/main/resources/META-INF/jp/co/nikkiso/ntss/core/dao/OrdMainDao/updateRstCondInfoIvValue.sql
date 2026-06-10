UPDATE ord_main
SET rst_cond_info = jsonb_set (
  jsonb_set (
    rst_cond_info,
    '{20, "value"}'
    , /*amount*/'"666"'
    , TRUE ),
  '{24,"value"}'
  , /*speed*/'"777"'
  , TRUE )
WHERE
  ord_no =  /*ordNo*/0
;
