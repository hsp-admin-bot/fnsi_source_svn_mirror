WITH ord as (
SELECT om.pat_id, om.ord_no, om.rst_dialysis_state, om.treat_date, om.ind_cond_info, om.ind_dw
FROM ord_main om
WHERE om.facility_cd in /* facilityCdList */(null)
/*%if patIdList.size() > 0 */
AND om.pat_id in /* patIdList */(null)
/*%end */
AND om.is_del = '0'
),
ord_ind_dw as (
SELECT pat_id, ord_no, treat_date
FROM ord
WHERE rst_dialysis_state = '0'
AND ind_cond_info_value(ord.ind_cond_info, '3') = '-1'
),
ord_ind_target_weight as (
SELECT pat_id, ord_no, treat_date, ind_cond_info_value(ind_cond_info, '3') as target_weight
FROM ord
WHERE rst_dialysis_state = '0'
AND ind_cond_info_value(ord.ind_cond_info, '3') <> '-1'
),
ord_rst_dw as (
SELECT pat_id, ord_no, ind_dw
FROM ord
WHERE rst_dialysis_state <> '0'
AND ind_cond_info_value(ord.ind_cond_info, '3') = '-1'
),
ord_rst_target_weight as (
SELECT pat_id, ord_no, ind_dw, ind_cond_info_value(ind_cond_info, '3') as target_weight
FROM ord
WHERE rst_dialysis_state <> '0'
AND ind_cond_info_value(ord.ind_cond_info, '3') <> '-1'
),
ord_info_dw as (
SELECT oidw.pat_id, oidw.ord_no, latest_dw.dw::decimal as dw, latest_dw.dw::decimal as target_weight
FROM ord_ind_dw oidw JOIN pat_unique pu ON oidw.pat_id = pu.pat_id
 and pu.is_del = '0'
LEFT JOIN LATERAL (
    SELECT (elem->>'dw')::numeric AS dw, pu.pat_id as latest_pat_id
    FROM jsonb_array_elements(pu.physical_info) AS elem
    WHERE
    to_char(to_timestamp((elem->>'exam_date'), 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"')::timestamp AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Tokyo', 'YYYYMMDD') <= to_char(oidw.treat_date::date, 'YYYYMMDD') AND (elem->>'dw')::text IS NOT NULL
    ORDER BY (elem->>'exam_date')::timestamp DESC
    LIMIT 1
) AS latest_dw ON pu.pat_id = latest_dw.latest_pat_id
UNION ALL
SELECT oitw.pat_id, oitw.ord_no, latest_dw.dw::decimal as dw, oitw.target_weight::decimal as target_weight
FROM ord_ind_target_weight oitw JOIN pat_unique pu ON oitw.pat_id = pu.pat_id
 and pu.is_del = '0'
LEFT JOIN LATERAL (
    SELECT (elem->>'dw')::numeric AS dw, pu.pat_id as latest_pat_id
    FROM jsonb_array_elements(pu.physical_info) AS elem
    WHERE
    to_char(to_timestamp((elem->>'exam_date'), 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"')::timestamp AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Tokyo', 'YYYYMMDD') <= to_char(oitw.treat_date::date, 'YYYYMMDD') AND (elem->>'dw')::text IS NOT NULL
    ORDER BY (elem->>'exam_date')::timestamp DESC
    LIMIT 1
) AS latest_dw ON pu.pat_id = latest_dw.latest_pat_id
UNION ALL
SELECT ordw.pat_id, ordw.ord_no, ordw.ind_dw::decimal as dw, ordw.ind_dw::decimal as target_weight
FROM ord_rst_dw ordw
UNION ALL
SELECT ortw.pat_id, ortw.ord_no, ortw.ind_dw::decimal as dw, ortw.target_weight::decimal as target_weight
FROM ord_rst_target_weight ortw
)
SELECT pat_id, ord_no
FROM ord_info_dw
WHERE
1 = 1
/*%if conditions.dialysisConditionRangeValueList != null && conditions.dialysisConditionRangeValueList.size() > 0 */
  /*%for range : conditions.dialysisConditionRangeValueList */
  /*%if range.conditionId == "39"*/
   and (
    /*%if range.comparisonType == 1*/
    --- 比較方式が「一致」の場合
  dw = /* range.value1 */null
    /*%else */
    --- 比較方式が「範囲」の場合
      /*%if range.value1 != null */
      --- 左辺が指定されている場合
        /*%if range.inequalitySign1 == 1 */
        --- 不等号が「<」の場合
   dw > /* range.value1 */null
        /*%else */
        --- 不等号が「≦」の場合
    dw >= /* range.value1 */null
        /*%end*/
      /*%end*/
      /*%if range.value2 != null */
      --- 右辺が指定されている場合
        /*%if range.value1 != null */
        --- 左辺が指定されている場合
    and
        /*%end*/
        /*%if range.inequalitySign2 == 1 */
        --- 不等号が「<」の場合
    dw < /* range.value2 */null
        /*%else */
        --- 不等号が「≦」の場合
    dw <= /* range.value2 */null
        /*%end*/
    /*%end*/
    /*%end */
    )
    /*%end */
  /*%end */
/*%end */
/*%if conditions.dialysisConditionRangeValueList != null && conditions.dialysisConditionRangeValueList.size() > 0 */
  /*%for range : conditions.dialysisConditionRangeValueList */
  /*%if range.conditionId == "3"*/
   and(
    /*%if range.comparisonType == 1*/
    --- 比較方式が「一致」の場合
  target_weight = /* range.value1 */null
    /*%else */
    --- 比較方式が「範囲」の場合
      /*%if range.value1 != null */
      --- 左辺が指定されている場合
        /*%if range.inequalitySign1 == 1 */
        --- 不等号が「<」の場合
   target_weight > /* range.value1 */null
        /*%else */
        --- 不等号が「≦」の場合
   target_weight >= /* range.value1 */null
        /*%end*/
      /*%end*/
      /*%if range.value2 != null */
      --- 右辺が指定されている場合
        /*%if range.value1 != null */
        --- 左辺が指定されている場合
    and
        /*%end*/
        /*%if range.inequalitySign2 == 1 */
        --- 不等号が「<」の場合
    target_weight < /* range.value2 */null
        /*%else */
        --- 不等号が「≦」の場合
    target_weight <= /* range.value2 */null
        /*%end*/
    /*%end*/
    /*%end */
    )
    /*%end */
  /*%end */
/*%end */
