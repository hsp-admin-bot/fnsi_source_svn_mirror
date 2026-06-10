with
query3 as ( --基本レコード:ベッドマスタの絞込みと並べ替えと番号付け
  select row_number() over() as rowno,
    -- mst_bed.*
    mst_bed.bed_cd,
    mst_bed.bed_name,
    mst_bed.facility_cd,
    mst_bed.is_disp,
    mst_bed.is_del
  from
  (
    --mst_selectorから並び順取得
    with selector as (
      with sel_query1 as (
        select
          (jsonb_array_elements(order_settings->'items')->'code'->>0)::numeric as code,
          jsonb_array_elements(order_settings->'items')->'name'->>0 as name
        from
          mst_selector
        where
          master_physical_name = 'mst_bed'
        and
          facility_cd=/*facilityCd*/'0'
      )
      select
        row_number() over(),
        *
      from
        sel_query1
      order by
        row_number
    )
    select
      -- bed.*
      bed.bed_cd,
      bed.bed_name,
      bed.facility_cd,
      bed.is_disp,
      bed.is_del
    from
      mst_bed bed,selector sel,mst_machine mac
    where
      bed.facility_cd=/*facilityCd*/1
    and
      bed.is_disp='1'
    and
--     add 10601 スケジュール表動作不正 関  start
      bed.is_del ='0'
    and
--     add 10601 スケジュール表動作不正 関  end
      bed.machine_no = mac.machine_no
    and
      bed.facility_cd = mac.facility_cd
    and
      bed.bed_cd = sel.code
    order by
     sel.row_number
  ) mst_bed
),
query2 as (    --治療日の絞込みクエリ
  SELECT
      -- sche.*
      sche.pat_id             ,        --患者ID
      sche.ord_no             , --オーダー番号
      sche.kur_cd,
      sche.bed_cd,
      sche.is_dummy        --ダミーフラグ(0:メイン 1:ダミー)
    ,ord.rst_dialysis_state --治療状況
    ,va.va_direct           --シャント方向
    ,pat.is_infect          --感染症有無
    ,treat.device_mode      --装置モード
    ,pat.is_same            --同姓同名
    ,sche.treat_date        --治療日
    ,case
      when
        replace((((ord.ind_cond_info::jsonb->'1')::jsonb->'value')::text),'"','') = 'null'
        then
          0
        else
          replace((((ord.ind_cond_info::jsonb->'1')::jsonb->'value')::text),'"','')::Int
      end as minute --治療時間(分)
  FROM
    ord_schedule sche,
    ord_main as ord LEFT JOIN mst_va va ON ord.ind_va_cd = va.va_cd and va.facility_cd=/*facilityCd*/'0',
    pat_main pat,
    mst_treatment treat
  WHERE
-- // FNSI-修正、パフォーマンス改善、#5559、#5768、#6050、xugj mod start
--    sche.treat_date in /*treatDateList*/('19990909')
    sche.treat_date between /*startDate*/'20231120' and /*endDate*/'20231206'
-- // FNSI-修正、パフォーマンス改善、#5559、#5768、#6050、xugj mod end
  and
    sche.facility_cd=/*facilityCd*/'0'
  and
    sche.ord_no = ord.ord_no
--   and
--     sche.facility_cd = ord.facility_cd
  and
    sche.pat_id = pat.pat_id
--   and
--     sche.facility_cd = pat.facility_cd
  and
    ord.ind_treatment_cd = treat.treatment_cd
--   and
--     ord.facility_cd = treat.facility_cd
  and
    ord.is_del = '0'
  -- add #10601 スケジュール表動作不正 start
  order by sche.bed_cd, sche.kur_cd, sche.treat_date
  -- add #10601 スケジュール表動作不正 end
),
query1 as (     --当該施設での存在ベッドとクールの組み合わせのベースクエリ(存在ベッドに対してクール数分のレコードを作成)
  SELECT
  mst_bed.rowno,
  mst_bed.bed_cd,
  mst_bed.bed_name,
  mst_bed.facility_cd,
  mst_kur.kur_name,
  mst_kur.kur_cd,
  mst_kur.kur_start_time
  FROM
   query3 mst_bed ,mst_kur
  WHERE
    mst_bed.facility_cd = mst_kur.facility_cd
  and
    mst_bed.is_disp = '1'
  and
    mst_bed.is_del = '0'
  and
    mst_kur.is_del = '0'
  ORDER BY
    mst_kur.kur_start_time
)
SELECT                          --メインクエリ
  query1.rowno              as "No",           --番号
  ''                        as "title",        --タイトル
  query1.bed_cd             ,        --ベッドコード
  query1.kur_name           ,      --クール名
  query1.kur_cd             ,        --クールコード
  query2.pat_id             ,        --患者ID
  query2.rst_dialysis_state as "dialysisState", --実績：治療状況
  query2.ord_no             as "ordNo", --オーダー番号
-- // FNSI-修正、パフォーマンス改善、#5559、#5768、#6050、xugj mod start
--   cast(/*treatDate*/'' as varchar)         as "treatDate", --治療日
  query2.treat_date         as "treatDate", --治療日
-- // FNSI-修正、パフォーマンス改善、#5559、#5768、#6050、xugj mod end
  query2.va_direct          as "vaDirect",    --シャント方向
  query2.is_infect          as "isInfect",    --感染症フラグ
  query2.is_same            as "isSame",      --同姓同名フラグ
  query2.device_mode        as "deviceMode",   --装置モード
  query2.minute             as "treatTime",   --治療時間(分)
  query2.is_dummy           as "isDummy"        --ダミーフラグ(0:メイン 1:ダミー)
FROM
(
  query1 LEFT JOIN query2 ON (query1.kur_cd = query2.kur_cd) AND (query1.bed_cd = query2.bed_cd)
)
ORDER BY
  -- mod #10601 スケジュール表動作不正 start
  query1.kur_start_time,query1.rowno,query2.treat_date
  -- mod #10601 スケジュール表動作不正 end
