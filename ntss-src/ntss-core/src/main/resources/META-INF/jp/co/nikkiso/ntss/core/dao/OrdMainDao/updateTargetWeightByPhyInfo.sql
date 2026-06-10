--mod #12096 データリストにてDWおよび目標体重を登録するとサーバダウン zrx start
-- update
--   ord_main om
-- set
--   ind_cond_info = jsonb_set( om.ind_cond_info, '{"3", "value"}',	to_jsonb(tmp.target_weight) ),
--   up_ind_user_id = cast(tmp.upIndUserId as bigint),
--   up_user_id = cast(tmp.upUserId as bigint),
--   up_date = current_timestamp
--   from
--   (values
--     /*%for utw : updTargetWeight */
--     (
--       /*utw.ordNo*/0,
--     	/*utw.targetWeight*/0,
--     	/*utw.indicatorCd*/0,
--     	/*utw.changerCd*/0
--     )
--       /*%if utw_has_next */
--         /*# "," */
--       /*%end */
--     /*%end*/
--   ) as tmp (ord_no, target_weight, upIndUserId, upUserId)
-- where
--   om.ord_no = tmp.ord_no;
update ord_main om
set
    ind_cond_info =
        jsonb_set(
                jsonb_set(
                        jsonb_set(
                                jsonb_set(
                                        jsonb_set(
                                                jsonb_set(
                                                        jsonb_set(
                                                                om.ind_cond_info,
                                                                '{3,value}',
                                                                to_jsonb(tmp.target_weight),
                                                                true
                                                            ),
                                                        '{3,ind_user_id}',
                                                        to_jsonb(cast(tmp.upIndUserId as bigint)),
                                                        true
                                                    ),
                                                '{3,upd_user_id}',
                                                to_jsonb(cast(tmp.upUserId as bigint)),
                                                true
                                            ),
                                        '{3,ind_user_last_name}',
                                        to_jsonb(tmp.indUserLastName),
                                        true
                                    ),
                                '{3,ind_user_first_name}',
                                to_jsonb(tmp.indUserFirstName),
                                true
                            ),
                        '{3,upd_user_last_name}',
                        to_jsonb(tmp.updUserLastName),
                        true
                    ),
                '{3,upd_user_first_name}',
                to_jsonb(tmp.updUserFirstName),
                true
            ),
    up_ind_user_id = cast(tmp.upIndUserId as bigint),
    up_user_id     = cast(tmp.upUserId as bigint),
    up_date        = current_timestamp
from (
  values
    /*%for utw : updTargetWeight */
    (
      /*utw.ordNo*/0,
      /*utw.targetWeight*/0,
      /*utw.indicatorCd*/0,
      /*utw.changerCd*/0,
      /*utw.indUserLastName*/'',
      /*utw.indUserFirstName*/'',
      /*utw.updUserLastName*/'',
      /*utw.updUserFirstName*/''
    )
    /*%if utw_has_next */
      /*# "," */
    /*%end */
    /*%end*/
) as tmp (ord_no, target_weight, upIndUserId, upUserId, indUserLastName, indUserFirstName, updUserLastName, updUserFirstName)
where om.ord_no = tmp.ord_no;
--mod #12096 データリストにてDWおよび目標体重を登録するとサーバダウン zrx zrx end
