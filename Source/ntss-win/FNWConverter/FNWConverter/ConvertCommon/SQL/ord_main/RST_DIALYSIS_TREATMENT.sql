with date_all as(
select DIALYSIS_NO, OCCUR_DATE, to_char(OCCUR_DATE,'YYYYMMDDHH24MI')as ctl_date from RST_DIALYSIS_COMPLAINT t WHERE t.DEL_FLG = '0'
union all
select DIALYSIS_NO, OCCUR_DATE, to_char(OCCUR_DATE,'YYYYMMDDHH24MI')as ctl_date from RST_DIALYSIS_TREATMENT t WHERE t.DEL_FLG = '0'
union all
select DIALYSIS_NO, OCCUR_DATE, to_char(OCCUR_DATE,'YYYYMMDDHH24MI')as ctl_date from RST_DIALYSIS_TREAT_PERSON t WHERE t.DEL_FLG = '0'
order by DIALYSIS_NO, OCCUR_DATE
)
,ctl_no_list as (select DIALYSIS_NO, ctl_date ,row_number() over(partition by DIALYSIS_NO order by ctl_date) as CTL_NO from(select distinct DIALYSIS_NO, ctl_date from date_all order by DIALYSIS_NO, ctl_date ))
,RESULT_ROW_TMP as (
    select
        RD.DIALYSIS_NO,
        c.CTL_NO,
        row_number() over(partition by RD.DIALYSIS_NO,c.CTL_NO ORDER BY RD.DIALYSIS_NO,t.OCCUR_DATE,c.CTL_NO,decode(t.ROW_NO,0,9999,t.ROW_NO),t.RESULT_NO) as ROW_NO,
        T.UP_DATE,
        T.TREAT_CLASS,
        T.OXYGEN_START
    from RST_DIALYSIS RD
        INNER JOIN RST_DIALYSIS_TREATMENT t
            ON RD.DIALYSIS_NO = t.DIALYSIS_NO 
        INNER JOIN ctl_no_list c 
            ON t.DIALYSIS_NO = c.DIALYSIS_NO
        AND to_char(t.OCCUR_DATE,'YYYYMMDDHH24MI') = c.ctl_date
    WHERE {0} and t.DEL_FLG = '0'
)
,OXYGEN_CTL_TMP as (
    SELECT 
        DIALYSIS_NO
        ,OXYGEN_START
        ,CTL_NO
        ,ROW_NO
        ,LAG ( CTL_NO, 1, NULL ) OVER (PARTITION BY DIALYSIS_NO ORDER BY DIALYSIS_NO, CTL_NO ASC ) AS SATRT_CTL_NO
    FROM RESULT_ROW_TMP
    where TREAT_CLASS = '3'
)
select
    TMP.*
    ,OCT.SATRT_CTL_NO AS LINKSTARTDATE
from (
    select
        RD.DIALYSIS_NO,
        c.CTL_NO as RESULT_NO,
        row_number() over(partition by RD.DIALYSIS_NO,c.CTL_NO ORDER BY RD.DIALYSIS_NO,t.OCCUR_DATE,c.CTL_NO,decode(t.ROW_NO,0,9999,t.ROW_NO),t.RESULT_NO) as ROW_NO,
        TO_CHAR(t.OCCUR_DATE,'yyyy/mm/dd hh24:mi') as OCCUR_DATE,
        CASE WHEN t.TREAT_CLASS = 'u' THEN '2' ELSE t.TREAT_CLASS END AS TREAT_CLASS,
        t.TREAT_CD,
        t.TREAT_NAME,
         case t.TREAT_CLASS
		      when '1'	 then MEDICINE_CD
			    when '0' then TREAT_MEDICINE_CD end  MEDICINE_CD,		
			     case t.TREAT_CLASS
		      when '1'	 then MEDICINE_NAME
			    when '0' then TREAT_MEDICINE_NAME end  MEDICINE_NAME,
        t.AMOUNT,
        t.UNIT,
        t.PROCEDURE_CD,
        t.PROCEDURE_NAME,
        t.OXYGEN_START,
        t.OXYGEN_TIME,
        t.OXYGEN_AMOUNT,
        t.OXYGEN_SPEED,
         CASE  t.INPUT_CLASS
    	    WHEN  '0' THEN '0'
		    WHEN  '1' THEN '1'
		    WHEN  '2' THEN '1'
		    WHEN  '3' THEN '2'
		    ELSE  t.INPUT_CLASS END INPUT_CLASS,
        t.COP_ORDER_NUMBER,
        t.EDITABLE_FLG,
        t.ELECTROCARDIOGRAM_TYPE,
        1 AS CHECK_FLAG,
        CASE t.TREAT_CLASS WHEN '0' THEN '2' WHEN '1' THEN '1' ELSE NULL END AS MEDICINE_TYPE,
        NULL AS OVER_TIME,
        NULL AS ELECTROCARDIOGRAM_START
from
    RST_DIALYSIS RD
    , RST_DIALYSIS_TREATMENT t   
    , ctl_no_list c 
where
    RD.DIALYSIS_NO = t.DIALYSIS_NO 
    and {0}
    and t.DIALYSIS_NO = c.DIALYSIS_NO and to_char(t.OCCUR_DATE,'YYYYMMDDHH24MI') = c.ctl_date
    AND t.DEL_FLG = '0'
) TMP
    INNER JOIN RESULT_ROW_TMP RRT
        ON RRT.DIALYSIS_NO = TMP.DIALYSIS_NO
		AND RRT.CTL_NO = TMP.RESULT_NO
		AND RRT.ROW_NO = TMP.ROW_NO
    LEFT JOIN OXYGEN_CTL_TMP OCT 
        ON TMP.DIALYSIS_NO = OCT.DIALYSIS_NO
        AND TMP.RESULT_NO = OCT.CTL_NO
        AND RRT.ROW_NO = OCT.ROW_NO
        AND OCT.OXYGEN_START IS NULL
order by
    TMP.DIALYSIS_NO,TMP.OCCUR_DATE,decode(TMP.ROW_NO,0,9999,TMP.ROW_NO),TMP.RESULT_NO