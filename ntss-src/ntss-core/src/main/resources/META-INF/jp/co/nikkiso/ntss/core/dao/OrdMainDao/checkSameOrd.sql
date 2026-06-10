-- 同患者，同日，同クールでの治療は，透析＋特殊浄化または特殊浄化＋特殊浄化のみ許可している。透析＋透析は許可していない。
SELECT COUNT(ord.ord_no) AS ordCount
  FROM ord_main ord
 INNER JOIN mst_treatment mst
    ON ord.facility_cd      = mst.facility_cd
   AND ord.ind_treatment_cd = mst.treatment_cd
   AND mst.device_mode      <> '9'                -- 9:特殊浄化
 WHERE ord.is_del           = '0'
   AND ord.pat_id           = /*patId*/null
   AND ord.treat_date       = /*treatDate*/null
   AND ord.ind_kur_cd       = /*kurCd*/null
;
