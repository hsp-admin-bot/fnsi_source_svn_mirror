update ord_main
set
    ind_va_cd =
        case
            when tmp.ind_cond_info::json->'2' is not null then
      (tmp.ind_cond_info::json#>>'{2,value}')::integer
    else
      ind_va_cd
end,
    ind_dw =
    case
    when tmp.ind_cond_info::json->'39' is not null then
      (tmp.ind_cond_info::json#>>'{39,value}')::float
    else
      ind_dw
end,
  ind_cond_info = ord_main.ind_cond_info::jsonb || tmp.ind_cond_info::jsonb,
  ind_device_set_info =
    case
    when tmp.ind_device_set_info::jsonb is not null then
      ord_main.ind_device_set_info::jsonb || tmp.ind_device_set_info::jsonb
    else
      ord_main.ind_device_set_info
    end,
  up_date = CURRENT_TIMESTAMP FROM
(VALUES
   /*%for omi : updateOrdMainInfoList */
        (
            /*omi.indCondInfo*/'{}',
            /*omi.indDeviceSetInfo*/'{}',
            /*omi.ordNo*/-1
        )
    /*%if omi_has_next */
/*# "," */
    /*%end */
/*%end*/
) AS tmp (ind_cond_info, ind_device_set_info, ord_no)
where
  ord_main.ord_no = tmp.ord_no;

