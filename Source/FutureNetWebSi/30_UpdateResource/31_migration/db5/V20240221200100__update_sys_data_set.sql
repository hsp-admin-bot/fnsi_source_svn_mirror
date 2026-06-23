DELETE FROM "ntss"."sys_data_set" where sql_cd in (1705, 1706, 1716);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1705, e'WITH in_out_class AS (SELECT (CASE
                                  WHEN \'@inOutClass\' = \'1\'
                                      THEN \'1\'
                                  ELSE \'0\'
    END) AS in_out)
   , data_new_info AS (SELECT null                                                                   AS ctl_no,
                              in_out                                                                 AS in_out,
                              null                                                                   AS reason,
                              null                                                                   AS to_course,
                              null                                                                   AS to_doctor,
                              0                                                                      AS disp_order,
                              null                                                                   AS period_end,
                              \'@facilityCd\'                                                          AS facility_cd,
                              null                                                                   AS from_course,
                              null                                                                   AS from_doctor,
                              (CASE in_out WHEN \'0\' THEN \'6\' WHEN \'1\' THEN \'4\' ELSE \'6\' END) :: TEXT AS move_in_out,
                              null                                                                   AS to_facility,
                              to_char(CURRENT_TIMESTAMP, \'YYYYMMDD\')                                 AS period_start,
                              null                                                                   AS from_facility,
                              \'0\'                                                                    AS course_is_free,
                              \'0\'                                                                    AS doctor_is_free,
                              null                                                                   AS period_end_day,
                              null                                                                   AS period_end_year,
                              \'0\'                                                                    AS facility_is_free,
                              null                                                                   AS period_end_month,
                              SUBSTR(to_char(CURRENT_TIMESTAMP, \'YYYYMMDD\'), 7, 2)                   AS period_start_day,
                              to_char(CURRENT_TIMESTAMP, \'YYYYMMDD\')                                 AS period_start_date,
                              SUBSTR(to_char(CURRENT_TIMESTAMP, \'YYYYMMDD\'), 1, 4)                   AS period_start_year,
                              SUBSTR(to_char(CURRENT_TIMESTAMP, \'YYYYMMDD\'), 5, 2)                   AS period_start_month,
                              \'0\'                                                                    AS period_end_input_free,
                              \'0\'                                                                    AS period_start_input_free,
                              null                                                                   AS to_medicalInstitutionCd,
                              null                                                                   AS from_medicalInstitutionCd
                       from in_out_class)
   -- 当日を含む過去の最新データを取得する
   , current_new_data AS (SELECT info ->> \'in_out\'       AS in_out
                               , info ->> \'period_start\' AS period_start
                               , info ->> \'ctl_no\'       AS ctl_no
                          FROM pat_unique patu
                                   CROSS JOIN LATERAL jsonb_array_elements(in_out_visit_history_info) AS info
                          WHERE pat_id = @patId
                            AND facility_cd = \'@facilityCd\'
                            AND is_del = \'0\'
                            AND info ->> \'period_start\' IS NOT NULL
                          ORDER BY info ->> \'period_start\' DESC, ((info ->> \'ctl_no\') :: INTEGER) DESC
                          LIMIT 1)
   , data_exists_info AS (SELECT 1   AS order_no
                               , \'1\' AS exists_flag
                          FROM current_new_data cnd,
                               in_out_class ioc
                          WHERE cnd.in_out = ioc.in_out
                          UNION
                          SELECT 2   AS order_no
                               , \'0\' AS exists_flag
                          ORDER BY order_no
                          LIMIT 1)
   , json_data AS (SELECT jsonb_build_object(
                                  \'ctl_no\', row_number() over (order by ctl_no),
                                  \'in_out\', in_out::integer,
                                  \'reason\', reason,
                                  \'to_course\', to_course,
                                  \'to_doctor\', to_doctor,
                                  \'disp_order\', disp_order,
                                  \'period_end\', period_end,
                                  \'facility_cd\', facility_cd,
                                  \'from_course\', from_course,
                                  \'from_doctor\', from_doctor,
                                  \'move_in_out\', move_in_out,
                                  \'to_facility\', to_facility,
                                  \'period_start\', period_start,
                                  \'from_facility\', from_facility,
                                  \'course_is_free\', course_is_free,
                                  \'doctor_is_free\', doctor_is_free,
                                  \'period_end_day\', period_end_day,
                                  \'period_end_year\', period_end_year,
                                  \'facility_is_free\', facility_is_free,
                                  \'period_end_month\', period_end_month,
                                  \'period_start_day\', period_start_day,
                                  \'period_start_date\', period_start_date,
                                  \'period_start_year\', period_start_year,
                                  \'period_start_month\', period_start_month,
                                  \'period_end_input_free\', period_end_input_free,
                                  \'period_start_input_free\', period_start_input_free,
                                  \'to_medicalInstitutionCd\', to_medicalInstitutionCd,
                                  \'from_medicalInstitutionCd\', from_medicalInstitutionCd) AS new_data
                   FROM data_new_info)
UPDATE pat_unique
SET in_out_visit_history_info = in_out_visit_history_info || new_data
  , up_date                   = CURRENT_TIMESTAMP
from json_data,
     data_exists_info
WHERE pat_id = @patId
  AND facility_cd = \'@facilityCd\'
  AND is_del = \'0\'
  AND \'@isDie\' <> \'1\'
  AND \'@inOutClass\' <> \'\'
	AND exists_flag = \'0\'', 2, '[{}]', '0', '{"applications": [4]}', null, '(受信用)富士通の患者プロファイル_固有情報_入外・転入出情報(死亡以外)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1706, e'WITH data_new_info AS (SELECT null                                                                   AS ctl_no,
                              2                                                                      AS in_out,
                              null                                                                   AS reason,
                              null                                                                   AS to_course,
                              null                                                                   AS to_doctor,
                              0                                                                      AS disp_order,
                              null                                                                   AS period_end,
                              NULLIF(\'@facilityCd\', \'\')                                              AS facility_cd,
                              null                                                                   AS from_course,
                              null                                                                   AS from_doctor,
                              \'11\' :: TEXT                                                           AS move_in_out,
                              null                                                                   AS to_facility,
                              TO_CHAR(TO_DATE(\'@dieDate_Date\', \'YYYY-MM-DD HH24:MI:SS\'), \'YYYYMMDD\') AS period_start,
                              null                                                                   AS from_facility,
                              \'0\'                                                                    AS course_is_free,
                              \'0\'                                                                    AS doctor_is_free,
                              null                                                                   AS period_end_day,
                              null                                                                   AS period_end_year,
                              \'0\'                                                                    AS facility_is_free,
                              null                                                                   AS period_end_month,
                              TO_CHAR(TO_DATE(\'@dieDate_Date\', \'YYYY-MM-DD HH24:MI:SS\'), \'DD\')       AS period_start_day,
                              null                                                                   AS period_start_date,
                              TO_CHAR(TO_DATE(\'@dieDate_Date\', \'YYYY-MM-DD HH24:MI:SS\'), \'YYYY\')     AS period_start_year,
                              TO_CHAR(TO_DATE(\'@dieDate_Date\', \'YYYY-MM-DD HH24:MI:SS\'), \'MM\')       AS period_start_month,
                              \'0\'                                                                    AS period_end_input_free,
                              \'0\'                                                                    AS period_start_input_free,
                              null                                                                   AS to_medicalInstitutionCd,
                              null                                                                   AS from_medicalInstitutionCd)
   , data_exists_info AS (SELECT 1   AS order_no
                               , \'1\' AS exists_flag
                          FROM pat_unique
                                   CROSS JOIN LATERAL jsonb_array_elements(in_out_visit_history_info) AS info
                          WHERE pat_id = @patId
                            AND facility_cd = \'@facilityCd\'
                            AND is_del = \'0\'
                            AND ((info ->> \'in_out\')::TEXT) = \'2\'
                            AND info ->> \'period_start\' =
                                TO_CHAR(TO_DATE(\'@dieDate_Date\', \'YYYY-MM-DD HH24:MI:SS\'), \'YYYYMMDD\')
                          UNION
                          SELECT 2   AS order_no
                               , \'0\' AS exists_flag
                          ORDER BY order_no
                          LIMIT 1)
   , json_data AS (SELECT jsonb_build_object(
                                  \'ctl_no\', row_number() over (order by ctl_no),
                                  \'in_out\', in_out,
                                  \'reason\', reason,
                                  \'to_course\', to_course,
                                  \'to_doctor\', to_doctor,
                                  \'disp_order\', disp_order,
                                  \'period_end\', period_end,
                                  \'facility_cd\', facility_cd,
                                  \'from_course\', from_course,
                                  \'from_doctor\', from_doctor,
                                  \'move_in_out\', move_in_out,
                                  \'to_facility\', to_facility,
                                  \'period_start\', period_start,
                                  \'from_facility\', from_facility,
                                  \'course_is_free\', course_is_free,
                                  \'doctor_is_free\', doctor_is_free,
                                  \'period_end_day\', period_end_day,
                                  \'period_end_year\', period_end_year,
                                  \'facility_is_free\', facility_is_free,
                                  \'period_end_month\', period_end_month,
                                  \'period_start_day\', period_start_day,
                                  \'period_start_date\', period_start_date,
                                  \'period_start_year\', period_start_year,
                                  \'period_start_month\', period_start_month,
                                  \'period_end_input_free\', period_end_input_free,
                                  \'period_start_input_free\', period_start_input_free,
                                  \'to_medicalInstitutionCd\', to_medicalInstitutionCd,
                                  \'from_medicalInstitutionCd\', from_medicalInstitutionCd) AS new_data
                   FROM data_new_info)
UPDATE pat_unique
SET in_out_visit_history_info = in_out_visit_history_info || new_data
  , up_date                   = CURRENT_TIMESTAMP
from json_data,
     data_exists_info
WHERE pat_id = @patId
  AND facility_cd = \'@facilityCd\'
  AND is_del = \'0\'
	AND exists_flag = \'0\'', 2, '[{}]', '0', '{"applications": [4]}', null, '(受信用)富士通の患者プロファイル_固有情報_入外・転入出情報(死亡)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1716, e'WITH isDie AS (SELECT CASE
                          WHEN \'@isDie\' <> \'1\'
                              THEN 0
                          ELSE 1
                          END AS is_die)
   , inOutClass AS (SELECT (CASE
                                WHEN \'@inOutClass\' = \'1\'
                                    THEN \'1\'
                                ELSE \'0\'
    END) AS inOut)
   -- 既存データの日付は存在するかどうか
   , date_exist_info AS ((SELECT 1 AS exist_flg
                          FROM pat_unique patu
                                   CROSS JOIN LATERAL jsonb_array_elements(patu.in_out_visit_history_info) AS info
                          WHERE pat_id = @patId
                            AND facility_cd = \'@facilityCd\'
                            AND is_del = \'0\'
                            AND info ->> \'move_in_out\' = \'1\'
                            AND info ->> \'period_start\' = replace(\'@syoriDate\', \'/\', \'\'))
                         UNION
                         (SELECT 0 AS exist_flg)
                         ORDER BY exist_flg DESC
                         LIMIT 1)
   -- 既存データの日付は取り込む日付より大きいデータを取得する
   , max_date_info AS ((SELECT 1                       AS num,
                               info ->> \'period_start\' AS max_date
                        FROM pat_unique patu
                                 CROSS JOIN LATERAL jsonb_array_elements(patu.in_out_visit_history_info) AS info
                        WHERE pat_id = @patId
                          AND facility_cd = \'@facilityCd\'
                          AND is_del = \'0\'
                        ORDER BY info ->> \'period_start\' DESC, ((info ->> \'ctl_no\') :: INTEGER) DESC
                        LIMIT 1)
                       UNION
                       (SELECT 2          AS num,
                               \'00000000\' AS max_date)
                       ORDER BY num
                       LIMIT 1)
   -- 既存データの日付は取り込む日付より小さいデータを取得する
   , min_date_info AS ((SELECT 1                       AS num,
                               info ->> \'period_start\' AS min_date
                        FROM pat_unique patu
                                 CROSS JOIN LATERAL jsonb_array_elements(patu.in_out_visit_history_info) AS info
                        WHERE pat_id = @patId
                          AND facility_cd = \'@facilityCd\'
                          AND is_del = \'0\'
                        ORDER BY info ->> \'period_start\', ((info ->> \'ctl_no\') :: INTEGER)
                        LIMIT 1)
                       UNION
                       (SELECT 2          AS num,
                               \'00000000\' AS min_date)
                       ORDER BY num
                       LIMIT 1)
   , data_new_info AS (SELECT null                                         AS ctl_no,
                              (CASE (replace(\'@syoriDate\', \'/\', \'\') < mind.min_date OR
                                     replace(\'@syoriDate\', \'/\', \'\') > maxd.max_date)
                                   WHEN true
                                       THEN io.inOut
                                   ELSE (SELECT info ->> \'in_out\' AS in_out
                                         FROM pat_unique patu
                                                  CROSS JOIN LATERAL jsonb_array_elements(patu.in_out_visit_history_info) AS info
                                         WHERE pat_id = @patId
                                           AND facility_cd = \'@facilityCd\'
                                           AND is_del = \'0\'
                                           AND info ->> \'period_start\' <= replace(\'@syoriDate\', \'/\', \'\')
                                         ORDER BY info ->> \'period_start\' DESC, ((info ->> \'ctl_no\') :: INTEGER) DESC
                                         LIMIT 1)
                                  END) :: TEXT                             AS in_out,
                              null                                         AS reason,
                              null                                         AS to_course,
                              null                                         AS to_doctor,
                              0                                            AS disp_order,
                              null                                         AS period_end,
                              NULLIF(\'@facilityCd\', \'\')                    AS facility_cd,
                              null                                         AS from_course,
                              null                                         AS from_doctor,
                              \'1\' :: TEXT                                  AS move_in_out,
                              null                                         AS to_facility,
                              replace(\'@syoriDate\', \'/\', \'\')               AS period_start,
                              null                                         AS from_facility,
                              \'0\'                                          AS course_is_free,
                              \'0\'                                          AS doctor_is_free,
                              null                                         AS period_end_day,
                              null                                         AS period_end_year,
                              \'0\'                                          AS facility_is_free,
                              null                                         AS period_end_month,
                              SUBSTR(replace(\'@syoriDate\', \'/\', \'\'), 7, 2) AS period_start_day,
                              replace(\'@syoriDate\', \'/\', \'\')               AS period_start_date,
                              SUBSTR(replace(\'@syoriDate\', \'/\', \'\'), 1, 4) AS period_start_year,
                              SUBSTR(replace(\'@syoriDate\', \'/\', \'\'), 5, 2) AS period_start_month,
                              \'0\'                                          AS period_end_input_free,
                              \'0\'                                          AS period_start_input_free,
                              null                                         AS to_medicalInstitutionCd,
                              null                                         AS from_medicalInstitutionCd
                       from inOutClass io,
                            max_date_info maxd,
                            min_date_info mind)
   , json_data AS (SELECT jsonb_build_object(
                                  \'ctl_no\', row_number() over (order by ctl_no),
                                  \'in_out\', in_out::integer,
                                  \'reason\', reason,
                                  \'to_course\', to_course,
                                  \'to_doctor\', to_doctor,
                                  \'disp_order\', disp_order,
                                  \'period_end\', period_end,
                                  \'facility_cd\', facility_cd,
                                  \'from_course\', from_course,
                                  \'from_doctor\', from_doctor,
                                  \'move_in_out\', move_in_out,
                                  \'to_facility\', to_facility,
                                  \'period_start\', period_start,
                                  \'from_facility\', from_facility,
                                  \'course_is_free\', course_is_free,
                                  \'doctor_is_free\', doctor_is_free,
                                  \'period_end_day\', period_end_day,
                                  \'period_end_year\', period_end_year,
                                  \'facility_is_free\', facility_is_free,
                                  \'period_end_month\', period_end_month,
                                  \'period_start_day\', period_start_day,
                                  \'period_start_date\', period_start_date,
                                  \'period_start_year\', period_start_year,
                                  \'period_start_month\', period_start_month,
                                  \'period_end_input_free\', period_end_input_free,
                                  \'period_start_input_free\', period_start_input_free,
                                  \'to_medicalInstitutionCd\', to_medicalInstitutionCd,
                                  \'from_medicalInstitutionCd\', from_medicalInstitutionCd) AS new_data
                   FROM data_new_info)
UPDATE pat_unique
SET in_out_visit_history_info = in_out_visit_history_info || new_data
  , up_date                   = CURRENT_TIMESTAMP
from json_data, date_exist_info
WHERE pat_id = @patId
  AND facility_cd = \'@facilityCd\'
  AND is_del = \'0\'
  AND (SELECT is_die FROM isDie) <> 1
	AND exist_flg = \'0\'', 2, '[{}]', '0', '{"applications": [4]}', null, '(受信用)日機装の患者プロファイル_固有情報_入外・転入出情報(死亡以外)・導入', '2022-06-22 08:26:30.149', CURRENT_TIMESTAMP, null);
