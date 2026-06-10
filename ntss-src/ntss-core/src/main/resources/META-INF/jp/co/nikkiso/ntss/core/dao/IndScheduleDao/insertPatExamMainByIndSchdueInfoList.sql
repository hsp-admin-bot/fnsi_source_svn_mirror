WITH updates AS (
  SELECT facility_cd, pat_id, exam_main_cd, treat_date, old_treat_date
  FROM
    (
      VALUES
      (null, 0, 0, null, null)
      /*%for isl : indScheduleInfoList */
        /*%for islemcd : isl.connectedExamMainCdList */
        ,(
        /*isl.facilityCd*/null,
        /*isl.patId*/0,
        /*islemcd*/0,
        /*isl.treatDate*/null,
        /*isl.oldTreatDate*/null
        )
        /*%end*/
      /*%end*/
    ) AS t(facility_cd, pat_id, exam_main_cd, treat_date, old_treat_date) WHERE t.treat_date != t.old_treat_date
),
  moved_data AS (
    SELECT pat_exam_main.* ,
           updates.treat_date as treat_date,
           (pat_exam_main.facility_cd || pat_exam_main.pat_id || updates.treat_date || pat_exam_main.reg_order_class) as primary_key_column
    FROM pat_exam_main, updates
    WHERE
      pat_exam_main.facility_cd = /*facilityCd*/null AND
      pat_exam_main.facility_cd = updates.facility_cd AND
      pat_exam_main.pat_id = updates.pat_id AND
      pat_exam_main.exam_main_cd = updates.exam_main_cd AND
      pat_exam_main.reg_order_class in ('1', '2') AND (pat_exam_main.phy_ord_class != '1' OR pat_exam_main.phy_ord_class IS NULL) AND
      TO_CHAR(pat_exam_main.reg_exam_date, 'YYYYMMDD') = updates.old_treat_date AND
      pat_exam_main.is_del = '0'
    union all
    SELECT DISTINCT pat_exam_main.* ,
           updates.treat_date as treat_date,
           (pat_exam_main.facility_cd || pat_exam_main.pat_id || updates.treat_date || pat_exam_main.reg_order_class || (pat_exam_main.order_exam_set_info -> 0 ->> 'set_cd')::text) as primary_key_column
    FROM pat_exam_main, updates
    WHERE
      pat_exam_main.facility_cd = /*facilityCd*/null AND
      pat_exam_main.facility_cd = updates.facility_cd AND
      pat_exam_main.pat_id = updates.pat_id AND
      pat_exam_main.exam_main_cd = updates.exam_main_cd AND
      (pat_exam_main.reg_order_class = '0' OR pat_exam_main.phy_ord_class = '1') AND
      TO_CHAR(pat_exam_main.reg_exam_date, 'YYYYMMDD') = updates.old_treat_date AND
      pat_exam_main.is_del = '0'
),
  existing_data AS (
    SELECT DISTINCT pat_exam_main.*,
           (pat_exam_main.facility_cd || pat_exam_main.pat_id || updates.treat_date || pat_exam_main.reg_order_class) as primary_key_column
    FROM pat_exam_main, updates
    WHERE
      pat_exam_main.facility_cd = /*facilityCd*/null AND
      pat_exam_main.facility_cd = updates.facility_cd AND
      pat_exam_main.pat_id = updates.pat_id AND
      pat_exam_main.reg_order_class in ('1', '2') AND (pat_exam_main.phy_ord_class != '1' OR pat_exam_main.phy_ord_class IS NULL) AND
      TO_CHAR(pat_exam_main.reg_exam_date, 'YYYYMMDD') = updates.treat_date AND
--       mod 10601 スケジュール表動作不正 関  start
      pat_exam_main.exam_main_cd not in (select exam_main_cd from updates) AND
      pat_exam_main.is_order = '1' AND
--       mod 10601 スケジュール表動作不正 関  end
      pat_exam_main.is_del = '0'
  ),
  existing_data2 AS (
      SELECT DISTINCT pat_exam_main.*,
                      (pat_exam_main.facility_cd || pat_exam_main.pat_id || updates.treat_date || pat_exam_main.reg_order_class || (pat_exam_main.order_exam_set_info -> 0 ->> 'set_cd')::text) as primary_key_column
      FROM pat_exam_main, updates
      WHERE
              pat_exam_main.facility_cd = /*facilityCd*/null AND
              pat_exam_main.facility_cd = updates.facility_cd AND
              pat_exam_main.pat_id = updates.pat_id AND
              (pat_exam_main.reg_order_class = '0' OR pat_exam_main.phy_ord_class = '1') AND
              TO_CHAR(pat_exam_main.reg_exam_date, 'YYYYMMDD') = updates.treat_date AND
--               mod 10601 スケジュール表動作不正 関  start
              pat_exam_main.exam_main_cd not in (select exam_main_cd from updates) AND
              pat_exam_main.is_order = '1' AND
--               mod 10601 スケジュール表動作不正 関  end
              pat_exam_main.is_del = '0'
  )
INSERT INTO pat_exam_main (
                           pat_id
                         ,facility_cd
                         ,ord_no
                         ,fn_pat_id
                         ,reg_exam_date
                         ,reg_order_class
                         ,exam_status
                         ,order_comment
                         ,order_exam_set_info
                         ,exam_order_info
                         ,order_label_info
                         ,data_gen_class
                         ,result_exam_date
                         ,result_comment
                         ,exam_result_info
                         ,cop_order_no1
                         ,cop_order_no2
                         ,is_lock
                         ,ind_user_id
                         ,is_del
                         ,reg_date
                         ,reg_staff
                         ,up_date
                         ,up_staff
                         ,is_order
                         ,phy_ord_class)
SELECT
  md.pat_id
     ,md.facility_cd
     ,md.ord_no
     ,md.fn_pat_id
     ,TO_TIMESTAMP(md.treat_date, 'yyyyMMdd')
     ,md.reg_order_class
     ,md.exam_status
     ,md.order_comment
     ,md.order_exam_set_info
     ,md.exam_order_info
     ,md.order_label_info
     ,md.data_gen_class
     ,md.result_exam_date
     ,md.result_comment
     ,md.exam_result_info
     ,md.cop_order_no1
     ,md.cop_order_no2
     ,md.is_lock
     ,md.ind_user_id
     ,'0'
     ,transaction_timestamp()
     ,md.reg_staff
     ,transaction_timestamp()
     ,md.up_staff
     ,md.is_order
     ,md.phy_ord_class
FROM moved_data md
       LEFT JOIN existing_data ON md.primary_key_column = existing_data.primary_key_column
       LEFT JOIN existing_data2 ON md.primary_key_column = existing_data2.primary_key_column
WHERE existing_data.primary_key_column IS NULL AND existing_data2.primary_key_column IS NULL
  RETURNING *

