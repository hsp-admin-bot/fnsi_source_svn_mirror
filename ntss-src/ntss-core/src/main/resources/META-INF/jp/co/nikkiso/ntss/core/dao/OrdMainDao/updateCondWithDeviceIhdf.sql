UPDATE
  ord_main
SET
  ind_cond_info = jsonb_merge_recursive(ind_cond_info::jsonb, tmp.indCondInfo::jsonb),
  up_date = CURRENT_TIMESTAMP FROM
(VALUES
    /*%for ucs : updateCondInfoList */
        (
            /*ucs.ordNo*/4268305,
            /*ucs.indCondInfo*/null,
            /*ucs.indTreatmentCd*/37,
            /*ucs.facilityCd*/'NKKSBR'
        )
    /*%if ucs_has_next */
/*# "," */
    /*%end */
/*%end*/
) AS tmp (ordNo,indCondInfo,indTreatmentCd,facilityCd)

WHERE
  ord_no = tmp.ordNo
  and exists(select 1 from mst_treatment mt where mt.facility_cd = tmp.facilityCd and mt.treatment_cd = tmp.indTreatmentCd and device_mode = 10)
;
