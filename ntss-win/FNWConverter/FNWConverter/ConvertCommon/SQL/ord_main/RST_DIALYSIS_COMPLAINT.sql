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
    n.CTL_NO as RESULT_NO,
    CASE   c.INPUT_CLASS
		WHEN  '0' THEN '0'
		WHEN  '1' THEN '1'
		WHEN  '2' THEN '1'
		WHEN  '3' THEN '2'
		ELSE  c.INPUT_CLASS END INPUT_CLASS,
    row_number() over(partition by  RD.DIALYSIS_NO,n.CTL_NO ORDER BY RD.DIALYSIS_NO,c.OCCUR_DATE,n.CTL_NO,c.ROW_NO,c.RESULT_NO) as ROW_NO,
    TO_CHAR(c.OCCUR_DATE,'yyyy/mm/dd hh24:mi') as OCCUR_DATE,
    c.COMP_TREAT_CD,
    c.COMPLAINT,
    1 AS CHECK_FLAG
from
    RST_DIALYSIS RD
    , RST_DIALYSIS_COMPLAINT c 
    , ctl_no_list n
where
    RD.DIALYSIS_NO = c.DIALYSIS_NO 
    and {0}
and c.DIALYSIS_NO = n.DIALYSIS_NO and to_char(c.OCCUR_DATE,'YYYYMMDDHH24MI') = n.ctl_date
AND c.DEL_FLG = '0'
order by
    c.OCCUR_DATE,c.ROW_NO,RD.DIALYSIS_NO,c.RESULT_NO
