SELECT
A.rad_set_cd,
A.facility_cd,
A.fn_exam_set_cd,
A.rad_set_name,
A.rad_set_abb_name,
A.rad_item_info,
A.in_hospital_cd1,
A.sbt_cd1,
A.in_hospital_cd2,
A.sbt_cd2,
A.in_hospital_cd3,
A.sbt_cd3,
A.is_disp,
A.is_del,
A.reg_date,
A.up_date
FROM mst_rad_set A
-- add 6485 一般撮影検査マスタの並び順に表示されない 周安寧 start
INNER JOIN (
        SELECT
              MSS.facility_cd,
              MS.*,
              row_number() over() as index
        FROM
              mst_selector MSS
        CROSS JOIN lateral jsonb_to_recordset(mss.order_settings->'items') as MS
        (
              code int,
              name text
       )
       WHERE
             MSS.facility_cd =/* facilityCd */null
       AND
             MSS.master_physical_name = 'mst_rad_set'
    ) B
       on A.rad_set_cd = B.code
       and A.facility_cd = B.facility_cd
-- add 6485 一般撮影検査マスタの並び順に表示されない 周安寧 end
WHERE
/*%if null != facilityCd */
  A.facility_cd = /* facilityCd */null
/*%end */
and A.is_disp = '1' and A.is_del = '0'
-- add 6485 一般撮影検査マスタの並び順に表示されない 周安寧 start
order by B.INDEX
-- add 6485 一般撮影検査マスタの並び順に表示されない 周安寧 end
;
