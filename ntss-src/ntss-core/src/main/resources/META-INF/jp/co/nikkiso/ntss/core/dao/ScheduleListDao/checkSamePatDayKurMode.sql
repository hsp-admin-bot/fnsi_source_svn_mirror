with query1 as (
select
  ord.ord_no,
  ord.facility_cd,
  ord.pat_id,
  treat.device_mode
from
  ord_main ord,mst_treatment treat
where
  ord.facility_cd = treat.facility_cd
  and
  ord.ind_treatment_cd = treat.treatment_cd
  and
  ord.ord_no = /*ordNo*/null
)
select EXISTS
(
	select
	  *
	from
	  ord_main ord,mst_treatment treat,query1 q
	where
	  ord.facility_cd = treat.facility_cd
	  and
	  ord.ind_treatment_cd = treat.treatment_cd
	  and
	  ord.facility_cd = q.facility_cd
	  and
	  ord.pat_id = q.pat_id  --同一患者
    and
    ord.ord_no <> q.ord_no  --異なるオーダー番号(自分自身を除く)
    and
    ord.is_del = '0'
    and
    treat.device_mode = q.device_mode  --同一治療方法
	  and
	  (ord.treat_date, ord.ind_kur_cd, q.ord_no) 
	     in
	  (
	     (/*treatDate*/null,/*kurCd*/null,/*ordNo*/null)
	  )
)
;

