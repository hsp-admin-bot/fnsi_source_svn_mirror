SELECT
    A.ord_no,
    A.pat_id,
    A.treat_date,
    A.treat_week,
    A.facility_cd,
    A.ind_treatment_cd,
    A.ind_kur_cd,
    A.ind_bed_cd,
    --//add #10412 次患者更新関連全体見直し対応 朴 start
    A.ind_cond_info,
    A.ind_medi_info,
    A.ind_equip_info,
    A.rst_dialysis_state,
    --//add #10412 次患者更新関連全体見直し対応 朴 end
    A.up_ind_user_id,
    A.up_user_id
FROM
    ord_main A
WHERE
        A.facility_cd = /*facilityCd*/'000000'
/*%if null != treats*/
  AND
        A.ind_treatment_cd = /*treats*/'0'
/*%end*/
/*%if isNotSent*/
  and
        A.rst_dialysis_state = '0'
/*%end*/
  AND A.treat_date >= to_char(now(), 'YYYYMMDD')
ORDER BY A.treat_date, A.ord_no
