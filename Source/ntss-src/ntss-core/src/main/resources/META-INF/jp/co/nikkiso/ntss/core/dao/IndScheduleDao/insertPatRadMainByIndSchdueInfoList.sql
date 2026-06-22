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
           (pat_rad_main.facility_cd || pat_rad_main.pat_id || updates.treat_date || (TO_TIMESTAMP(updates.treat_date || substring(CAST(pat_rad_main.reg_rad_date AS VARCHAR) FROM 11), 'yyyyMMdd hh24:mi:ss'))::timestamp || (pat_rad_main.order_rad_set_info -> 0 ->> 'rad_set_cd')::text ) as primary_key_column
    FROM pat_rad_main, updates
    WHERE
      pat_rad_main.facility_cd = /*facilityCd*/null AND
      pat_rad_main.facility_cd = updates.facility_cd AND
      pat_rad_main.pat_id = updates.pat_id AND
      pat_rad_main.rad_result_cd = updates.rad_result_cd AND
      --pat_rad_main.reg_order_class in ('1', '2') AND
      TO_CHAR(pat_rad_main.reg_rad_date, 'YYYYMMDD') = updates.old_treat_date AND
      pat_rad_main.is_del = '0'
--     union all
--     SELECT DISTINCT pat_rad_main.* ,
--            updates.treat_date as treat_date,
--            pat_rad_main.rad_result_cd::text as primary_key_column
--     FROM pat_rad_main, updates
--     WHERE
--       pat_rad_main.facility_cd = /*facilityCd*/null AND
--       pat_rad_main.facility_cd = updates.facility_cd AND
--       pat_rad_main.pat_id = updates.pat_id AND
--       pat_rad_main.reg_order_class = '0' AND
--       TO_CHAR(pat_rad_main.reg_rad_date, 'YYYYMMDD') = updates.old_treat_date
),
  existing_data AS (
    SELECT DISTINCT pat_rad_main.*,
           (pat_rad_main.facility_cd || pat_rad_main.pat_id || updates.treat_date || pat_rad_main.reg_rad_date || (pat_rad_main.order_rad_set_info -> 0 ->> 'rad_set_cd')::text) as primary_key_column
    FROM pat_rad_main, updates
    WHERE
      pat_rad_main.facility_cd = /*facilityCd*/null AND
      pat_rad_main.facility_cd = updates.facility_cd AND
      pat_rad_main.pat_id = updates.pat_id AND
      --pat_rad_main.reg_order_class in ('1', '2') AND
      TO_CHAR(pat_rad_main.reg_rad_date, 'YYYYMMDD') = updates.treat_date AND
      pat_rad_main.is_del = '0'
  )
INSERT INTO pat_rad_main (
                          pat_id
                        ,facility_cd
                        ,fn_pat_id
                        ,reg_rad_date
                        ,reg_order_class
                        ,rad_status
                        ,order_rad_set_info
                        ,cop_order_no1
                        ,cop_order_no2
                        ,is_lock
                        ,ind_user_id
                        ,is_del
                        ,reg_date
                        ,reg_staff
                        ,up_date
                        ,up_staff)
SELECT
      md.pat_id
     ,md.facility_cd
     ,md.fn_pat_id
     ,TO_TIMESTAMP(md.treat_date || substring(CAST(md.reg_rad_date AS VARCHAR) FROM 11), 'yyyyMMdd hh24:mi:ss')
     ,md.reg_order_class
     ,md.rad_status
     ,md.order_rad_set_info
     ,md.cop_order_no1
     ,md.cop_order_no2
     ,md.is_lock
     ,md.ind_user_id
     ,'0'
     ,transaction_timestamp()
     ,md.reg_staff
     ,transaction_timestamp()
     ,md.up_staff
FROM moved_data md
       LEFT JOIN existing_data ON md.primary_key_column = existing_data.primary_key_column
WHERE existing_data.primary_key_column IS NULL
RETURNING pat_rad_main.*
