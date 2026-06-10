--検査セット
  select
      /*%expand "A" */*
  from
    mst_exam_set A   --テーブル名
         ,(
                 select
                         mss.facility_cd, ms.*, row_number() over() as index
                 from
                         mst_selector mss
                 cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
                 (
                         code bigint,
                         name text
                 )
                 where
    /*%if params.facilityCd != null */
                         facility_cd = /* params.facilityCd*/'0'
                 and
    /*%end */
                         master_physical_name = 'mst_exam_set' --テーブル名
         ) ms
      where
             A.facility_cd = ms.facility_cd
       and
             A.exam_set_cd = ms.code --コードのカラム
       and (case when (select
	count(1)
from
	mst_facility F,
	jsonb_array_elements(F.advanced_settings->'func_advcds') func
where
	F.facility_cd = /* params.facilityCd*/'999998'
	and func->>'func_advcd'= 'A12')='0'
	then A.exam_set_class !='3'
    else  (A.exam_set_class ='0' or A.exam_set_class ='1' or A.exam_set_class ='2'
or A.exam_set_class ='3')
end)
      order by
             ms.index
;
