
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
     mst_water_survey_point mp /*%if listBedCd.size() != 0*/ ,
  -- modify by zhaohan 2022-10-31 [7090] システムを停止しないDBバージョンアップができない。 --start
  -- (SELECT *
  (SELECT machine_no
  -- modify by zhaohan 2022-10-31 [7090] システムを停止しないDBバージョンアップができない。 --end
   FROM mst_bed
   WHERE bed_cd IN /*listBedCd*/(NULL)) AS bed /*%end*/
WHERE ws.facility_cd = /*facilityCd*/NULL /*%if null != startDate*/
  AND date(ws.inspection_date) >= /*startDate*/NULL /*%end*/ /*%if null != endDate*/
  AND date(ws.inspection_date) <= /*endDate*/NULL /*%end*/ /*%if listBedCd.size() != 0*/
  AND mp.machine_no = bed.machine_no /*%end*/ /*%if listSurveyTypeCd.size() != 0 */
  AND mp.survey_type_cd IN /*listSurveyTypeCd*/(NULL)/*%end*/
  AND elem ->> 'point_cd' = mp.survey_point_cd::text
  AND ws.is_disp = '1'
  AND ws.is_del = '0'
  -- FNSI-修正 マスタ削除の対応 徐 add start
  AND mp.is_del = '0'
  -- FNSI-修正 マスタ削除の対応 徐 add end
GROUP BY ws.survey_record_no,
         ws.facility_cd,
         ws.inspection_date
ORDER BY ws.survey_record_no
