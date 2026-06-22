-- del #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 高 start
-- select
--   bio_moni_ctl_no,
--   ord_no,
--   occur_date,
--   elapsed_time,
--   remaining_time_removal,
--   remaining_time_dialysis
-- from  (
--     select mni_monitor.*,
--     to_number(mni_monitor.monitor_data::json->>'1', '9999') AS elapsed_time
--     , to_number(mni_monitor.monitor_data::json->>'3', '9999') AS remaining_time_removal
--     , to_number(mni_monitor.monitor_data::json->>'4', '9999') AS remaining_time_dialysis
--     from mni_monitor
--     where ord_no = /* ordNo */0
-- --     add #9577 「？？？？」患者は表示されません（複数患者帳票）。 2024/03/18 高 start
--     and facility_cd = /*facilityCd*/null
-- --     add #9577 「？？？？」患者は表示されません（複数患者帳票）。 2024/03/18 高 end
--     order by up_date desc
--     limit 1
-- ) a inner join ord_main b on b.ord_no = a.ord_no
--
-- del #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 高 end

-- add #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 高 start
WITH b AS (
select ord_main.* from ord_main
     where facility_cd = /*facilityCd*/null
 and rst_dialysis_state between '1' and '5'
       and
       pat_id is not null
       and
       treat_date between to_char(date_trunc('day', ( /*fromDate*/null

         )::timestamp), 'yyyymmdd') and to_char(date_trunc('day', ( /*toDate*/null

         )::timestamp) + '1 days - 1 milliseconds', 'yyyymmdd')
       and
         is_del = '0'
       and pat_id = /* patId */0
--      add #11009 カテゴリ「印刷情報」の仕様調整 高 start
       and ord_no = /* ordNo */0
--      add #11009 カテゴリ「印刷情報」の仕様調整 高 end
), d AS (
    select b.ord_no
    , data_type
    , MAX(bio_moni_ctl_no) AS bio_moni_ctl_no
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no)
        where mni_monitor.facility_cd = /*facilityCd*/null
    group by b.ord_no
    , mni_monitor.data_type
  LIMIT 1
),e AS (
    select mni_monitor.*,
    to_number(mni_monitor.monitor_data::json->>'1', '9999') AS 経過時間
    , to_number(mni_monitor.monitor_data::json->>'3', '9999') AS 残り時間_除水完了
    , to_number(mni_monitor.monitor_data::json->>'4', '9999') AS 残り時間_透析完了
    , to_number(mni_monitor.monitor_data::json->>'78', '9999') AS 残り時間_補液完了
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 1 AND mni_monitor.facility_cd = /*facilityCd*/null
),
--  mod #12206 【デグレード】帳票画面で透析予測でのソートが機能しない 高 start
q as (
select
  e.bio_moni_ctl_no,
  e.occur_date,
  e.ord_no,
  to_number(mnt_machine_state.monitor_data::json->>'1', '9999') AS 経過時間,
  to_number(mnt_machine_state.monitor_data::json->>'3', '9999') AS 残り時間_除水完了,
  to_number(mnt_machine_state.monitor_data::json->>'4', '9999') AS 残り時間_透析完了,
  to_number(mnt_machine_state.monitor_data::json->>'78', '9999') AS 残り時間_補液完了
from e
  inner join mnt_machine_state on
  e.facility_cd = mnt_machine_state.facility_cd and
  e.machine_type_cd = mnt_machine_state.machine_type_cd and
  e.machine_serial = mnt_machine_state.machine_serial and
  e.ord_no = mnt_machine_state.ord_no and
  e.pat_id = mnt_machine_state.pat_id
),
f AS (
select q.*
  , COALESCE(q.経過時間,0) + COALESCE(q.残り時間_除水完了,0) AS 予測時間_除水
  , COALESCE(q.経過時間,0) + COALESCE(q.残り時間_透析完了,0) AS 予測時間_透析
  , COALESCE(q.経過時間,0) + COALESCE(q.残り時間_補液完了,0) AS 予測時間_補液
from q

)
--   f AS (
-- select e.*
--   , COALESCE(e.経過時間,0) + COALESCE(e.残り時間_除水完了,0) AS 予測時間_除水
--   , COALESCE(e.経過時間,0) + COALESCE(e.残り時間_透析完了,0) AS 予測時間_透析
--   , COALESCE(e.経過時間,0) + COALESCE(e.残り時間_補液完了,0) AS 予測時間_補液
-- from e
-- where ord_no = /* ordNo */0
--   and facility_cd = /*facilityCd*/null
-- order by up_date desc
--   LIMIT 1
--   )
--  mod #12206 【デグレード】帳票画面で透析予測でのソートが機能しない 高 end

select
    b.rst_start_date + to_number(b.rst_cond_info#>>'{1, value}', '9999') * interval '1 minute' AS  ind_end_date,
  CASE WHEN b.rst_dialysis_state < '3' THEN null
  WHEN b.rst_dialysis_state > '3' THEN b.rst_end_date
  WHEN f.残り時間_除水完了 > f.残り時間_透析完了 AND f.残り時間_除水完了 > f.残り時間_補液完了 THEN b.rst_start_date + f.予測時間_除水 * interval '1 minute'
  WHEN f.残り時間_透析完了 > f.残り時間_補液完了 THEN b.rst_start_date +f.予測時間_透析 * interval '1 minute'
  ELSE b.rst_start_date + f.予測時間_補液 * interval '1 minute'
END AS ind_end_date_time
  ,bio_moni_ctl_no,
  f.ord_no,
  occur_date,
  経過時間 as elapsed_time,
  残り時間_除水完了 as remaining_time_removal,
  残り時間_透析完了 as remaining_time_dialysis
from  b left join f ON b.ord_no = f.ord_no
-- add #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 高 end
