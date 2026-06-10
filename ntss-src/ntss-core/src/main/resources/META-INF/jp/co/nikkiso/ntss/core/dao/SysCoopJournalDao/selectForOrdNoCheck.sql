--mod #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi start
with check_for_7 as (SELECT (CASE
                                 WHEN A.facility_setting_no IS NULL THEN B.default_value
                                 ELSE A.value END) As value
                     FROM ntss.mst_facility_setting A
                              RIGHT OUTER JOIN ntss.sys_facility_setting B
                                               ON A.facility_setting_no = B.facility_setting_no AND
                                                  A.facility_cd = /*facilityCd*/'999999'
                     where B.facility_setting_no = '1007'
                     ORDER BY B.disp_order),
     check_for_8 as (SELECT (CASE
                                 WHEN A.facility_setting_no IS NULL THEN B.default_value
                                 ELSE A.value END) As value
                     FROM ntss.mst_facility_setting A
                              RIGHT OUTER JOIN ntss.sys_facility_setting B
                                               ON A.facility_setting_no = B.facility_setting_no AND
                                                  A.facility_cd = /*facilityCd*/'999999'
                     where B.facility_setting_no = '1008'
                     ORDER BY B.disp_order)
select table_name
     , coop_cd
     , facility_cd
     , base_date
     , ord_no
     , pat_id
     , user_id
     , reg_order_class
from (SELECT 'ord_main'     as table_name
           , 'ind_dial'     as coop_cd
           , facility_cd    as facility_cd
           , treat_date     as base_date
           , ord_no         as ord_no
           , pat_id
           , up_ind_user_id as user_id
           , null           as reg_order_class
      FROM ord_main om
      WHERE facility_cd = /*facilityCd*/'999999'
        AND pat_id = /* patId */''
        AND is_del = '0'
      union
      SELECT 'pat_exam_main'                    as table_name
           , 'exam_ord'                         as coop_cd
           , facility_cd                        as facility_cd
           , TO_CHAR(reg_exam_date, 'YYYYMMDD') as base_date
           , exam_main_cd                       as ord_no
           , pat_id
           , ind_user_id                        as user_id
           , reg_order_class                    as reg_order_class
      FROM pat_exam_main pem
      WHERE phy_ord_class <> '1'
        AND facility_cd = /*facilityCd*/'999999'
        AND pat_id = /* patId */''
        AND is_del = '0'
        and exam_status = '0'
      union
      SELECT 'pat_exam_main'                    as table_name
           , 'phy_ord'                          as coop_cd
           , facility_cd                        as facility_cd
           , TO_CHAR(reg_exam_date, 'YYYYMMDD') as base_date
           , exam_main_cd                       as ord_no
           , pat_id
           , ind_user_id                        as user_id
           , reg_order_class                    as reg_order_class
      FROM pat_exam_main pem
      WHERE phy_ord_class = '1'
        AND facility_cd = /*facilityCd*/'999999'
        AND pat_id = /* patId */''
        AND is_del = '0'
        and exam_status = '0'
      union
      SELECT 'pat_rad_main'                    as table_name
           , 'rad_ord'                         as coop_cd
           , facility_cd                       as facility_cd
           , TO_CHAR(reg_rad_date, 'YYYYMMDD') as base_date
           , rad_result_cd                     as ord_no
           , pat_id
           , ind_user_id                       as user_id
           , reg_order_class                   as reg_order_class
      FROM pat_rad_main prm
      WHERE facility_cd = /*facilityCd*/'999999'
        AND pat_id = /* patId */''
        AND is_del = '0'
        and rad_status = '0') as t0,
     check_for_7,
     check_for_8
where ((t0.table_name = 'pat_exam_main' and check_for_7.value <> '3') or
       ((t0.table_name = 'pat_rad_main' and check_for_8.value <> '3')) or t0.table_name = 'ord_main')
  AND t0.base_date >= TO_CHAR(TO_DATE(/* dieDate */'', 'YYYY-MM-DD HH24:MI:SS'), 'YYYYMMDD')
  AND t0.base_date not in (select treat_date
                           FROM ord_main
                           WHERE is_del = '0'
                             AND rst_edition = 0
                             AND pat_id = /* patId */''
                             AND facility_cd = /*facilityCd*/'999999'
                             AND treat_date >= TO_CHAR(TO_DATE(/* dieDate */'', 'YYYY-MM-DD HH24:MI:SS'), 'YYYYMMDD')
                             AND rst_dialysis_state > '0')
--mod #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi end
