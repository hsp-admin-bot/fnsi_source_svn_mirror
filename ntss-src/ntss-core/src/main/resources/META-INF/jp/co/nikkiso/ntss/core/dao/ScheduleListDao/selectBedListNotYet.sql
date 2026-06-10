with
-- add FNSI 1006 No.425 start --- Sanjingye Sun 20210111
-- del 12433 DB高負荷① zkm start
-- query2 as (
--   SELECT
--     pem.pat_id,
--     red.rem_exam_date,
--     pem.exam_status
--   FROM pat_exam_main pem
--          INNER JOIN (
--     SELECT
--       MAX(pem.exam_main_cd) exam_main_cd,
--       pat_id,
--       to_char(pem.reg_exam_date,'YYYYMMDD') rem_exam_date
--     FROM pat_exam_main pem
--     WHERE
--       pem.facility_cd = /*facilityCd*/'999998'
--       AND pem.is_del = '0'
--     GROUP BY
--       pem.pat_id,
--       to_char(pem.reg_exam_date,'YYYYMMDD')
--   ) red
-- ON red.exam_main_cd = pem.exam_main_cd
-- ),
-- del 12433 DB高負荷① zkm end
-- add FNSI 1006 No.425 end --- Sanjingye Sun 20210111
query1 as (
  select
-- mod 12433 DB高負荷① zkm start
--     row_number() over(partition by sch.treat_date) as rowno,
    row_number() over(partition by sch.treat_date order by sch.ord_no) as rowno,
-- mod 12433 DB高負荷① zkm end
    -- sch.*,
    sch.treat_date,
    sch.is_dummy,
    sch.bed_cd,         --ベッドコード
    sch.kur_cd,         --クールコード
    sch.pat_id,         --患者ID
    sch.ord_no,         --オーダー番号
    kur.kur_name
    ,ord.rst_dialysis_state --治療状況
    ,va.va_direct           --シャント方向
    ,pat.is_infect          --感染症有無
    ,pat.is_same            --同姓同名
    ,treat.device_mode      --装置モード
    ,case
      when
        replace((((ord.ind_cond_info::jsonb->'1')::jsonb->'value')::text),'"','') = 'null'
        then
          0
        else
          replace((((ord.ind_cond_info::jsonb->'1')::jsonb->'value')::text),'"','')::Int
      end as minute --治療時間(分)
  from
    (select
     -- *
     treat_date,
     facility_cd,
     is_dummy,
     bed_cd,         --ベッドコード
     kur_cd,         --クールコード
     pat_id,         --患者ID
     ord_no
--      // FNSI-修正、パフォーマンス改善、#5559、#5768、#6050、xugj mod start
     from ord_schedule where
        --treat_date in /*treatDateList*/('20010203')
         treat_date between /*startDate*/'20231120' and /*endDate*/'20231206'
        and facility_cd = /*facilityCd*/'0' and bed_cd = 0) sch,
--      // FNSI-修正、パフォーマンス改善、#5559、#5768、#6050、xugj mod end
    (select
     --*
     kur_name,
     kur_cd,
     facility_cd from mst_kur where is_del = '0' order by kur_start_time) kur,
-- mod 12433 DB高負荷① zkm start
--     ord_main as ord LEFT JOIN mst_va as va ON ord.ind_va_cd = va.va_cd and va.facility_cd = /*facilityCd*/'0',
    ord_main as ord LEFT JOIN mst_va as va ON ord.ind_va_cd = va.va_cd,
-- mod 12433 DB高負荷① zkm end
    pat_main pat,
    mst_treatment treat
  where
-- del 12433 DB高負荷① zkm start
--     sch.facility_cd = kur.facility_cd
--   and
-- del 12433 DB高負荷① zkm end
    sch.kur_cd = kur.kur_cd
  and
    sch.ord_no = ord.ord_no
-- del 12433 DB高負荷① zkm start
--   and
--     sch.facility_cd = ord.facility_cd
-- del 12433 DB高負荷① zkm end
  and
    sch.pat_id = pat.pat_id
-- del 12433 DB高負荷① zkm start
--   and
--     sch.facility_cd = pat.facility_cd
-- del 12433 DB高負荷① zkm end
  and
    ord.ind_treatment_cd = treat.treatment_cd
-- del 12433 DB高負荷① zkm start
--   and
--     ord.facility_cd = treat.facility_cd
-- del 12433 DB高負荷① zkm end
  and
    ord.is_del = '0'
)
select
  query1.rowno as "No",                                 --番号
  '' as "title",                                        --タイトル
  query1.bed_cd,                                        --ベッドコード
  query1.kur_name,                                      --クール名
  query1.kur_cd,                                        --クールコード
  query1.pat_id,                                        --患者ID
  query1.ord_no                     as "ordNo",         --オーダー番号
  query1.treat_date                 as "treatDate",     --治療日
  query1.rst_dialysis_state         as "dialysisState", --治療状況
  query1.va_direct                  as "vaDirect",      --シャント方向
  query1.is_infect                  as "isInfect",      --感染症有無
  query1.is_same                    as "isSame",        --同姓同名
  query1.minute                     as "treatTime",     --治療時間(分)
  query1.device_mode                as "deviceMode",    --装置モード
  query1.is_dummy                   as "isDummy",       --ダミーフラグ(0:メイン 1:ダミー)
  -- add FNSI 1006 No.425 start --- Sanjingye Sun 20210111
  query2.rem_exam_date      		,		            --登録時検査日時
  query2.exam_status									--状況区分
  -- add FNSI 1006 No.425 end --- Sanjingye Sun 20210111
from
  query1
  -- add FNSI 1006 No.425 start --- Sanjingye Sun 20210111
-- mod 12433 DB高負荷① zkm start
--   LEFT JOIN query2
-- 	ON query2.pat_id = query1.pat_id
-- -- 	// FNSI-修正、パフォーマンス改善、#5559、#5768、#6050、xugj mod start
-- --     AND query2.rem_exam_date = /*treatDate*/'20210111'
--     AND query2.rem_exam_date = query1.treat_date
-- --  // FNSI-修正、パフォーマンス改善、#5559、#5768、#6050、xugj mod end
-- -- add FNSI 1006 No.425 end --- Sanjingye Sun 20210111
-- order by
-- kur_cd
    LEFT JOIN LATERAL (
      SELECT
        to_char(reg_exam_date,'YYYYMMDD') AS rem_exam_date,
        exam_status
      FROM pat_exam_main pem
      WHERE
        pem.pat_id = query1.pat_id
        AND pem.is_del = '0'
        AND pem.reg_exam_date >= to_date(query1.treat_date,'YYYYMMDD')
        AND pem.reg_exam_date <  to_date(query1.treat_date,'YYYYMMDD') + INTERVAL '1 day'
      ORDER BY
        pem.exam_main_cd DESC
        LIMIT 1
  ) query2 ON true
order by
  kur_cd
-- mod 12433 DB高負荷① zkm end
;
