WITH updatesAll AS (
  SELECT facility_cd, rad_result_cd, treat_date, old_treat_date
  FROM (
     VALUES
       (null, 0, null, null)
       /*%for isl : indScheduleInfoList */
         /*%for islrrcd : isl.connectedRadResultCdList */
         ,(
           /*isl.facilityCd*/null,
           /*islrrcd*/0,
         /*isl.treatDate*/null,
         /*isl.oldTreatDate*/null
         )
         /*%end*/
      /*%end*/
   ) AS t(facility_cd, rad_result_cd, treat_date, old_treat_date)
),
  updates AS (SELECT DISTINCT facility_cd, rad_result_cd, treat_date, old_treat_date FROM updatesAll),
  inserted_data AS (
  INSERT INTO pat_rad_main_hst (
                            rad_result_cd
                           ,pat_id
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
     prm.rad_result_cd
    ,prm.pat_id
    ,prm.facility_cd
    ,prm.fn_pat_id
    ,prm.reg_rad_date
    ,prm.reg_order_class
    ,prm.rad_status
    ,prm.order_rad_set_info
    ,prm.cop_order_no1
    ,prm.cop_order_no2
    ,prm.is_lock
    ,prm.ind_user_id
    ,prm.is_del
    ,prm.reg_date
    ,prm.reg_staff
    ,prm.up_date
    ,prm.up_staff
  FROM pat_rad_main prm, updates AS u
  WHERE
      prm.facility_cd = /*facilityCd*/null AND
      prm.facility_cd = u.facility_cd AND
      prm.rad_result_cd = u.rad_result_cd AND
      prm.is_del = '0' AND
--       mod 10553 連携イベント発生部分不正 関  start
--       u.treat_date != u.old_treat_date
      ( u.treat_date != u.old_treat_date or u.old_treat_date is null)
--       mod 10553 連携イベント発生部分不正 関  end
)
DELETE FROM pat_rad_main
  USING updates u
WHERE
    pat_rad_main.facility_cd = /*facilityCd*/null AND
    pat_rad_main.facility_cd = u.facility_cd AND
    pat_rad_main.rad_result_cd = u.rad_result_cd AND
    pat_rad_main.is_del = '0' AND
--     mod 10553 検査予定に関する連携イベント作成不備 関 start
--     u.treat_date != u.old_treat_date
    ( u.treat_date != u.old_treat_date or u.old_treat_date is null)
--     mod 10553 検査予定に関する連携イベント作成不備 関 end
RETURNING pat_rad_main.*
