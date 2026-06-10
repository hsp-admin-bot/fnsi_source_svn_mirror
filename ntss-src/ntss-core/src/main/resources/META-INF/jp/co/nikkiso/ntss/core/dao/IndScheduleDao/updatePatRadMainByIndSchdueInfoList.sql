WITH updates AS (
  SELECT facility_cd, pat_id, rad_result_cd, treat_date, old_treat_date
  FROM
    (
      VALUES
      (null, 0, 0, null, null)
      /*%for isl : indScheduleInfoList */
        /*%for islrrcd : isl.connectedRadResultCdList */
        ,(
        /*isl.facilityCd*/null,
        /*isl.patId*/0,
        /*islrrcd*/0,
        /*isl.treatDate*/null,
        /*isl.oldTreatDate*/null
        )
        /*%end*/
      /*%end*/
    ) AS t(facility_cd, pat_id, rad_result_cd, treat_date, old_treat_date) WHERE t.treat_date != t.old_treat_date
),
  moved_data AS (
    SELECT pat_rad_main.* ,
           updates.treat_date as treat_date,
           (pat_rad_main.facility_cd || pat_rad_main.pat_id || updates.treat_date || pat_rad_main.reg_order_class) as primary_key_column
    FROM pat_rad_main, updates
    WHERE
      pat_rad_main.facility_cd = /*facilityCd*/null AND
      pat_rad_main.facility_cd = updates.facility_cd AND
      pat_rad_main.pat_id = updates.pat_id AND
      pat_rad_main.rad_result_cd = updates.rad_result_cd AND
      pat_rad_main.reg_order_class in ('1', '2') AND
      TO_CHAR(pat_rad_main.reg_rad_date, 'YYYYMMDD') = updates.old_treat_date
    union all
    SELECT pat_rad_main.* ,
           updates.treat_date as treat_date,
           pat_rad_main.rad_result_cd::text as primary_key_column
    FROM pat_rad_main, updates
    WHERE
      pat_rad_main.facility_cd = /*facilityCd*/null AND
      pat_rad_main.facility_cd = updates.facility_cd AND
      pat_rad_main.pat_id = updates.pat_id AND
      pat_rad_main.reg_order_class = '0' AND
      TO_CHAR(pat_rad_main.reg_rad_date, 'YYYYMMDD') = updates.old_treat_date
),
  existing_data AS (
    SELECT pat_rad_main.*,
           (pat_rad_main.facility_cd || pat_rad_main.pat_id || updates.treat_date || pat_rad_main.reg_order_class) as primary_key_column
    FROM pat_rad_main, updates
    WHERE
      pat_rad_main.facility_cd = /*facilityCd*/null AND
      pat_rad_main.facility_cd = updates.facility_cd AND
      pat_rad_main.pat_id = updates.pat_id AND
      pat_rad_main.reg_order_class in ('1', '2') AND
      TO_CHAR(pat_rad_main.reg_rad_date, 'YYYYMMDD') = updates.treat_date
  ),
  merged_data AS (
    SELECT
      existing_data.*,
      COALESCE(existing_data.order_rad_set_info || moved_data.order_rad_set_info, existing_data.order_rad_set_info, moved_data.order_rad_set_info) AS merged_order_rad_set_info
    FROM existing_data
    LEFT JOIN moved_data ON existing_data.primary_key_column = moved_data.primary_key_column
  )
UPDATE pat_rad_main
SET
  order_rad_set_info = merged_order_rad_set_info,
  up_date = transaction_timestamp()
  FROM merged_data
WHERE pat_rad_main.rad_result_cd = merged_data.rad_result_cd
RETURNING pat_rad_main.*

