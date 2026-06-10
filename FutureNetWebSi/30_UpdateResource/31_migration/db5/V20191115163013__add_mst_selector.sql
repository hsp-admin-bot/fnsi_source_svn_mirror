/* 職種マスタ デフォルト職種の追加に伴うmst_selectorへの追加 */

DELETE FROM mst_selector WHERE master_physical_name = 'mst_job';

INSERT INTO mst_selector (facility_cd, master_physical_name, order_settings, reg_date, up_date)
SELECT
  MF.facility_cd,
  'mst_job' AS master_physical_name,
  json_build_object(
    'items', json_build_array(job_doctor.doctor, job_nurse.nurse, jbo_engineer.engineer)
  ) AS order_settings,
  current_timestamp AS reg_date,
  current_timestamp AS up_date
FROM mst_facility MF
     LEFT JOIN (
       SELECT
         T01A.facility_cd,
         json_build_object(
           'code', T01B.job_cd,
           'name', T01B.job_name
         ) AS doctor
       FROM mst_facility T01A, mst_job T01B
       WHERE
         T01A.facility_cd = T01B.facility_cd
       AND
         T01B.job_name = '医師'
     ) job_doctor
     ON MF.facility_cd = job_doctor.facility_cd
     LEFT JOIN (
       SELECT
         T02A.facility_cd,
         json_build_object(
           'code', T02B.job_cd,
           'name', T02B.job_name
         ) AS nurse
       FROM mst_facility T02A, mst_job T02B
       WHERE
         T02A.facility_cd = T02B.facility_cd
       AND
         T02B.job_name = '看護師'
     ) job_nurse
     ON MF.facility_cd = job_nurse.facility_cd
     LEFT JOIN (
       SELECT
         T03A.facility_cd,
         json_build_object(
           'code', T03B.job_cd,
           'name', T03B.job_name
         ) AS engineer
       FROM mst_facility T03A, mst_job T03B
       WHERE
         T03A.facility_cd = T03B.facility_cd
       AND
         T03B.job_name = '臨床工学技士'
     ) jbo_engineer
     ON MF.facility_cd = jbo_engineer.facility_cd
