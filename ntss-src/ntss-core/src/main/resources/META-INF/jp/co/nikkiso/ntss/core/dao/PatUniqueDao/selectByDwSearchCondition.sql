 SELECT DISTINCT om.pat_id, om.ord_no
FROM ord_main om
JOIN pat_unique pu ON om.facility_cd in /* facilityCdList */(null)
 /*%if patIdList.size() > 0 */
 and om.pat_id in /* patIdList */(null)
 /*%end */
 and om.pat_id = pu.pat_id
 and pu.is_del = '0'
LEFT JOIN LATERAL (
    SELECT (elem->>'dw')::numeric AS dw, pu.pat_id as latest_pat_id
    FROM jsonb_array_elements(pu.physical_info) AS elem
    WHERE
    to_char(to_timestamp((elem->>'exam_date'), 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"')::timestamp AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Tokyo', 'YYYYMMDD') <= to_char(om.treat_date::date, 'YYYYMMDD') AND (elem->>'dw')::text IS NOT NULL
    ORDER BY (elem->>'exam_date')::timestamp DESC
    LIMIT 1
) AS latest_dw ON pu.pat_id = latest_dw.latest_pat_id
WHERE
    om.facility_cd in /* facilityCdList */(null)
    /*%if patIdList.size() > 0 */
    and om.pat_id in /* patIdList */(null)
    /*%end */
    AND (
        (om.rst_dialysis_state <> '0'
 /*%if conditions.dialysisConditionRangeValueList != null && conditions.dialysisConditionRangeValueList.size() > 0 */
  /*%for range : conditions.dialysisConditionRangeValueList */
  /*%if range.conditionId == "39"*/
  and (
    /*%if range.comparisonType == 1*/
    --- 比較方式が「一致」の場合
  om.ind_dw ::decimal = /* range.value1 */null
    /*%else */
    --- 比較方式が「範囲」の場合
      /*%if range.value1 != null */
      --- 左辺が指定されている場合
        /*%if range.inequalitySign1 == 1 */
        --- 不等号が「<」の場合
   om.ind_dw ::decimal > /* range.value1 */null
        /*%else */
        --- 不等号が「≦」の場合
    om.ind_dw ::decimal >= /* range.value1 */null
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
    om.ind_dw ::decimal < /* range.value2 */null
        /*%else */
        --- 不等号が「≦」の場合
    om.ind_dw ::decimal <= /* range.value2 */null
        /*%end*/
    /*%end*/
    /*%end */
    )
    /*%end */
  /*%end */
/*%end */)
        OR
        (om.rst_dialysis_state = '0'
 /*%if conditions.dialysisConditionRangeValueList != null && conditions.dialysisConditionRangeValueList.size() > 0 */
  /*%for range : conditions.dialysisConditionRangeValueList */
  /*%if range.conditionId == "39"*/
  and (
    /*%if range.comparisonType == 1*/
    --- 比較方式が「一致」の場合
  latest_dw.dw::decimal = /* range.value1 */null
    /*%else */
    --- 比較方式が「範囲」の場合
      /*%if range.value1 != null */
      --- 左辺が指定されている場合
        /*%if range.inequalitySign1 == 1 */
        --- 不等号が「<」の場合
   latest_dw.dw::decimal > /* range.value1 */null
        /*%else */
        --- 不等号が「≦」の場合
    latest_dw.dw::decimal >= /* range.value1 */null
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
    latest_dw.dw::decimal < /* range.value2 */null
        /*%else */
        --- 不等号が「≦」の場合
    latest_dw.dw::decimal <= /* range.value2 */null
        /*%end*/
    /*%end*/
    /*%end */
    )
    /*%end */
  /*%end */
/*%end */)
    );
