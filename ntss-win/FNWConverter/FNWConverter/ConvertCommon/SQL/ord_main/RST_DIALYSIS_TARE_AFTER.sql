select
     RD.DIALYSIS_NO
    ,RD.ORDER_CLASS
    ,max(case RD.seq when 1 then RD.CTL_NO else null end) as CTL_NO1
    ,max(case RD.seq when 1 then RD.REVISE_NAME else null end) as REVISE_NAME1
    ,max(case RD.seq when 1 then RD.REVISE_WEIGHT else null end) as REVISE_WEIGHT1
    ,max(case RD.seq when 2 then RD.CTL_NO else null end) as CTL_NO2
    ,max(case RD.seq when 2 then RD.REVISE_NAME else null end) as REVISE_NAME2
    ,max(case RD.seq when 2 then RD.REVISE_WEIGHT else null end) as REVISE_WEIGHT2
    ,max(case RD.seq when 3 then RD.CTL_NO else null end) as CTL_NO3
    ,max(case RD.seq when 3 then RD.REVISE_NAME else null end) as REVISE_NAME3
    ,max(case RD.seq when 3 then RD.REVISE_WEIGHT else null end) as REVISE_WEIGHT3
    ,max(case RD.seq when 4 then RD.CTL_NO else null end) as CTL_NO4
    ,max(case RD.seq when 4 then RD.REVISE_NAME else null end) as REVISE_NAME4
    ,max(case RD.seq when 4 then RD.REVISE_WEIGHT else null end) as REVISE_WEIGHT4
    ,max(case RD.seq when 5 then RD.CTL_NO else null end) as CTL_NO5
    ,max(case RD.seq when 5 then RD.REVISE_NAME else null end) as REVISE_NAME5
    ,max(case RD.seq when 5 then RD.REVISE_WEIGHT else null end) as REVISE_WEIGHT5
    ,max(case RD.seq when 6 then RD.HOSP_WHEELCHAIR_CD else null end) as WHEEL_CHAIR_CD
    ,max(case RD.seq when 6 then RD.REVISE_NAME else null end) as WHEEL_CHAIR_NAME
    ,max(case RD.seq when 6 then RD.REVISE_WEIGHT else null end) as WHEEL_CHAIR_WEIGHT
from
(
    select
         DIALYSIS_NO
        ,CTL_NO
        ,ORDER_CLASS
        ,REVISE_NAME
        ,REVISE_WEIGHT
		,HOSP_WHEELCHAIR_CD
        ,row_number() over (partition by DIALYSIS_NO,ORDER_CLASS ORDER BY DIALYSIS_NO,ORDER_CLASS,CTL_NO) as seq
    from
        RST_DIALYSIS_TARE
	where
		ORDER_CLASS = '1'
) RD
where {0}
group by
    RD.DIALYSIS_NO, RD.ORDER_CLASS