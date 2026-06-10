update ord_main
set
/*%if null != ordMainUptSchInfoVoList.indKurCd */
    ind_kur_cd             = /*ordMainUptSchInfoVoList.indKurCd*/0,
    ind_kur_name           = /*ordMainUptSchInfoVoList.indKurName*/null,
/*%end*/
    ind_treat_start_time   = /*ordMainUptSchInfoVoList.indTreatStartTime*/'0000',
/*%if null != ordMainUptSchInfoVoList.indBedCd */
    ind_bed_cd             = /*ordMainUptSchInfoVoList.indBedCd*/0,
    ind_bed_name           = /*ordMainUptSchInfoVoList.indBedName*/null,
/*%end*/
    up_ind_user_id         = /*ordMainUptSchInfoVoList.indUserId*/null,
    up_user_id             = /*ordMainUptSchInfoVoList.updUserid*/null,
    ind_schedule_user_info = ind_schedule_user_info ||
                             jsonb_build_object('ind_user_first_name', /*ordMainUptSchInfoVoList.indUserFirstName*/'null'::text,
                                                'ind_user_last_name', /*ordMainUptSchInfoVoList.indUserLastName*/' '::text,
                                                'ind_user_id', /*ordMainUptSchInfoVoList.indUserId*/null,
                                                'upd_user_id', /*ordMainUptSchInfoVoList.updUserid*/null
                                 ),
    up_date                = CURRENT_TIMESTAMP
where ord_no = /*ordMainUptSchInfoVoList.ordNo*/1
;
