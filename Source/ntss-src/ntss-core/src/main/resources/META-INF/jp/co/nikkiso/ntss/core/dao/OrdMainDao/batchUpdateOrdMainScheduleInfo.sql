update ord_main
set ind_kur_cd             = CASE WHEN tmp.indKurCd IS NULL THEN ind_kur_cd ELSE CAST(tmp.indKurCd AS numeric) END,
    ind_kur_name           = CASE WHEN tmp.indKurCd IS NULL THEN ind_kur_name ELSE tmp.ind_kur_name END,
    ind_treat_start_time   = CASE
                                 WHEN tmp.indTreatStartTime IS NULL THEN ind_treat_start_time
                                 ELSE tmp.indTreatStartTime END,
    ind_bed_cd             = CASE WHEN tmp.indBedCd IS NULL THEN ind_bed_cd ELSE CAST(tmp.indBedCd AS numeric) END,
    ind_bed_name           = CASE WHEN tmp.indBedCd IS NULL THEN ind_bed_name ELSE tmp.indBedName END,
    up_ind_user_id         = tmp.indUserId,
    up_user_id             = tmp.updUserid,
--     ind_schedule_user_info = jsonb_merge_recursive(jsonb_merge_recursive(jsonb_merge_recursive(jsonb_merge_recursive(
--                                                                                                        ind_schedule_user_info,
--                                                                                                        jsonb_build_object('ind_user_first_name', tmp.userFirstName::text)),
--                                                                                                jsonb_build_object('ind_user_last_name', tmp.userLastName::text)),
--                                                                          jsonb_build_object('ind_user_id', tmp.indUserId)),
--                                                    jsonb_build_object('upd_user_id', tmp.updUserid)),
    ind_schedule_user_info = ind_schedule_user_info ||
                             jsonb_build_object('ind_user_first_name', tmp.userFirstName::text,
                                                'ind_user_last_name', tmp.userLastName::text,
                                                'ind_user_id', tmp.indUserId,
                                                'upd_user_id', tmp.updUserid
                                 ),
    up_date                = CURRENT_TIMESTAMP FROM
    (VALUES
    /*%for pat : ordMainUptSchInfoVoList */
    (
    /*pat.ordNo*/null,
    /*pat.indKurCd*/null,
    /*pat.indKurName*/null,
    /*pat.indTreatStartTime*/null,
    /*pat.indBedCd*/null,
    /*pat.indBedName*/null,
    /*pat.indUserId*/null,
    /*pat.updUserid*/null,
    /*pat.userLastName*/' ',
    /*pat.userFirstName*/null,
    /*pat.updateMode*/null,
    /*pat.rstUpdFlg*/null
    )
/*%if pat_has_next */
/*# "," */
/*%end */
/*%end*/
    ) AS tmp(ordNo,indKurCd,indKurName,indTreatStartTime,indBedCd,indBedName,indUserId,updUserid,userLastName,
    userFirstName,updateMode,rstUpdFlg)
where ord_no = tmp.ordNo
;
