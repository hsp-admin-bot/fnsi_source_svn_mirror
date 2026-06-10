UPDATE
    ord_main
SET
    ind_device_set_info = jsonb_merge_recursive(ind_device_set_info::jsonb, tmp.indDeviceSetInfo::jsonb),
    -- add 10196 by kangjie 20240124 start
    up_ind_user_id = tmp.upIndUserId,
    up_user_id = tmp.upUserId,
    -- add 10196 by kangjie 20240124 end
    up_date             = CURRENT_TIMESTAMP FROM
(VALUES
    /*%for uds : updateDeviceSetInfoList */
        (
            /*uds.ordNo*/1,
            /*uds.indDeviceSetInfo*/null,
          /*uds.upIndUserId*/0,
          /*uds.upUserId*/0
        )
    /*%if uds_has_next */
/*# "," */
    /*%end */
/*%end*/
) AS tmp (ordNo,indDeviceSetInfo,
  upIndUserId,upUserId
  )

WHERE
    ord_no = tmp.ordNo
;
