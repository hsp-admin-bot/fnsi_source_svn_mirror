with date_all as(
select DIALYSIS_NO, OCCUR_DATE, to_char(OCCUR_DATE,'YYYYMMDDHH24MI')as ctl_date from RST_DIALYSIS_COMPLAINT t WHERE t.DEL_FLG = '0'
union all
select DIALYSIS_NO, OCCUR_DATE, to_char(OCCUR_DATE,'YYYYMMDDHH24MI')as ctl_date from RST_DIALYSIS_TREATMENT t WHERE t.DEL_FLG = '0'
union all
select DIALYSIS_NO, OCCUR_DATE, to_char(OCCUR_DATE,'YYYYMMDDHH24MI')as ctl_date from RST_DIALYSIS_TREAT_PERSON t WHERE t.DEL_FLG = '0'
order by DIALYSIS_NO, OCCUR_DATE
)
,ctl_no_list as (select DIALYSIS_NO, ctl_date ,row_number() over(partition by DIALYSIS_NO order by ctl_date) as CTL_NO from(select distinct DIALYSIS_NO, ctl_date from date_all order by DIALYSIS_NO, ctl_date ))
select
    RD.DIALYSIS_NO,
    c.CTL_NO as RESULT_NO,
   row_number() over(partition by RD.DIALYSIS_NO, c.CTL_NO ORDER BY RD.DIALYSIS_NO,rdt.OCCUR_DATE,c.CTL_NO,decode(rdt.ROW_NO,0,9999,rdt.ROW_NO),rdt.RESULT_NO) as ROW_NO,
   CASE  rdt.INPUT_CLASS
    	WHEN  '0' THEN '0'
		WHEN  '1' THEN '1'
		WHEN  '2' THEN '1'
		WHEN  '3' THEN '2'
        ELSE  rdt.INPUT_CLASS END INPUT_CLASS,
    TO_CHAR(rdt.OCCUR_DATE,'yyyy/mm/dd hh24:mi') as OCCUR_DATE,
    rdt.TREAT_PERSON_CD,
    rdt.TREAT_PERSON_NAME,
    rdt.COP_ORDER_NUMBER,
    rdt.EDITABLE_FLG,
    1 AS CHECK_FLAG
from
    RST_DIALYSIS RD
    , RST_DIALYSIS_TREAT_PERSON rdt 
    , ctl_no_list c 
where
    RD.DIALYSIS_NO = rdt.DIALYSIS_NO 
    and {0}
    and rdt.DIALYSIS_NO = c.DIALYSIS_NO and to_char(rdt.OCCUR_DATE,'YYYYMMDDHH24MI') = c.ctl_date
    AND rdt.DEL_FLG = '0'
order by
    RD.DIALYSIS_NO,rdt.OCCUR_DATE,decode(rdt.ROW_NO,0,9999,rdt.ROW_NO),rdt.RESULT_NO desc