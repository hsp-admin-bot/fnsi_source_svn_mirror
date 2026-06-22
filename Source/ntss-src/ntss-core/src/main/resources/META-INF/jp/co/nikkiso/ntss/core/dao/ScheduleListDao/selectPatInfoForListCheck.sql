  SELECT
     sche.facility_cd
    ,sche.ord_no
    ,sche.treat_date
    ,sche.kur_cd
    ,sche.bed_cd
    ,sche.pat_id
    ,sche.is_dummy
    ,sche.up_date
    ,sche.treat_week
    ,sche.reg_date
    ,ord.rst_dialysis_state --治療状況
    ,va.va_direct           --シャント方向
    ,pat.is_infect          --感染症有無
    ,treat.device_mode      --装置モード
    ,pat.is_same            --同姓同名
    ,case
      when
           replace((((ord.ind_cond_info::jsonb->'1')::jsonb->'value')::text),'"','') = 'null'
           then
             0
           else
             replace((((ord.ind_cond_info::jsonb->'1')::jsonb->'value')::text),'"','')::Int
    end as minute --治療時間(分)
  FROM
    ord_schedule sche,
    ord_main as ord LEFT JOIN mst_va as va ON ord.ind_va_cd = va.va_cd and ord.facility_cd = va.facility_cd,
    pat_main pat,
    mst_treatment treat
  WHERE
    sche.ord_no in (
	/*%for ordNo : ordNoList */
		/* ordNo */-1
	/*%if ordNo_has_next */
    ,
    /*%end */
	/*%end */
	)
   and
    sche.ord_no = ord.ord_no
   and
    sche.facility_cd = ord.facility_cd
   and
    sche.pat_id = pat.pat_id
   and
    sche.facility_cd = pat.facility_cd
   and
    ord.ind_treatment_cd = treat.treatment_cd
   and
    ord.facility_cd = treat.facility_cd
