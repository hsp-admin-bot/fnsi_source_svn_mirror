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
           pat_exam_main.exam_main_cd::text as primary_key_column
    FROM pat_exam_main, updates
    WHERE
      pat_exam_main.facility_cd = /*facilityCd*/null AND
      pat_exam_main.facility_cd = updates.facility_cd AND
      pat_exam_main.pat_id = updates.pat_id AND
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
--       mod 10601 スケジュール表動作不正 関  start
      TO_CHAR(pat_exam_main.reg_exam_date, 'YYYYMMDD') = updates.treat_date AND
      pat_exam_main.is_order = '1' AND
      pat_exam_main.is_del = '0'
--       mod 10601 スケジュール表動作不正 関  end
  ),
  merged_data AS (
	SELECT
		existing_data.*,
		(
		SELECT
			jsonb_agg ( DISTINCT elem )
		FROM
			( SELECT jsonb_array_elements ( COALESCE ( existing_data.order_exam_set_info || moved_data.order_exam_set_info, existing_data.order_exam_set_info, moved_data.order_exam_set_info ) ) AS elem ) AS subquery
		) AS merged_order_exam_set_info,
		(
		SELECT
			jsonb_agg ( DISTINCT elem )
		FROM
			( SELECT jsonb_array_elements ( COALESCE ( existing_data.exam_order_info || moved_data.exam_order_info, existing_data.exam_order_info, moved_data.exam_order_info ) ) AS elem ) AS subquery
		) AS merged_exam_order_info,
		(
		SELECT
			jsonb_agg ( DISTINCT elem )
		FROM
			( SELECT jsonb_array_elements ( COALESCE ( existing_data.order_label_info || moved_data.order_label_info, existing_data.order_label_info, moved_data.order_label_info ) ) AS elem ) AS subquery
		) AS merged_order_label_info
	FROM
		existing_data
		LEFT JOIN moved_data ON existing_data.primary_key_column = moved_data.primary_key_column
-- 		add 10553 連携イベント発生部分不正 関 start
		where moved_data.primary_key_column is not null
-- 		add 10553 連携イベント発生部分不正 関 end
	)
-- 	mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関  end
select pat_exam_main.*
  FROM pat_exam_main, merged_data
WHERE pat_exam_main.exam_main_cd = merged_data.exam_main_cd AND pat_exam_main.is_del = '0'

