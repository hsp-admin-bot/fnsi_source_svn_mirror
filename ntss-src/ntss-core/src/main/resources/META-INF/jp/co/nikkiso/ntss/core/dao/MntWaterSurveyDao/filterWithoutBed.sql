
SELECT ws.survey_record_no,
       ws.facility_cd,
       ws.inspection_date,
       array_to_json(array_agg(elem)) AS survey_data,
       ws.is_disp,
       ws.is_del,
       ws.reg_date,
       ws.up_date
FROM mnt_water_survey AS ws,
     jsonb_array_elements(ws.survey_data) AS elem,
     mst_water_survey_point mp
WHERE ws.facility_cd = /*facilityCd*/NULL /*%if null != startDate*/
  AND date(ws.inspection_date) >= /*startDate*/NULL /*%end*/ /*%if null != endDate*/
  AND date(ws.inspection_date) <= /*endDate*/NULL /*%end*/
  /*%if listSurveyTypeCd.size() != 0 */
  AND mp.survey_type_cd IN /*listSurveyTypeCd*/(NULL)/*%end*/
  AND elem ->> 'point_cd' = mp.survey_point_cd::text
  AND ws.is_disp = '1'
  AND ws.is_del = '0'
-- #8434 upd  2023-05-25 発生しない日付列の結果セット表示の検出 修正 by ztc --start
  AND mp.is_disp = '1'
-- #8434 upd  2023-05-25 発生しない日付列の結果セット表示の検出 修正 by ztc --end
GROUP BY ws.survey_record_no,
         ws.facility_cd,
         ws.inspection_date
ORDER BY ws.survey_record_no
