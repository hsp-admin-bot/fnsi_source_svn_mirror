with
query1 as (
  select
    row_number() over(partition by sch.treat_date,sch.kur_cd order by sch.ord_no) as rowno,
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
     treat_date,
     facility_cd,
     is_dummy,
     bed_cd,         --ベッドコード
     kur_cd,         --クールコード
     pat_id,         --患者ID
     ord_no
     from ord_schedule where
         treat_date between /*startDate*/'20231120' and /*endDate*/'20231206'
        and facility_cd = /*facilityCd*/'0' and bed_cd = 0) sch,
    (select
     kur_name,
     kur_cd,
     facility_cd from mst_kur where is_del = '0' order by kur_start_time) kur,
    ord_main as ord LEFT JOIN mst_va as va ON ord.ind_va_cd = va.va_cd,
    pat_main pat,
    mst_treatment treat
  where
    sch.kur_cd = kur.kur_cd
  and
    sch.ord_no = ord.ord_no
  and
    sch.pat_id = pat.pat_id
  and
    ord.ind_treatment_cd = treat.treatment_cd
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
  query2.rem_exam_date      		,		            --登録時検査日時
  query2.exam_status									--状況区分
from
  query1
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
  query1.treat_date,kur_cd,query1.rowno
;
