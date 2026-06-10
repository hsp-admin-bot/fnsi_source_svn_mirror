update ntss.sys_data_set set "sql"='SELECT
 opp.insu_no, --保険者番号
 opp.insu_pat_mark, --被保険者証記号
 opp.insu_pat_no, --被保険者証番号
 opp.insu_pub_no, --公費負担者番号
 opp.insu_pub_pat_no, --公費負担受給者番号
 opp.insu_kbn,--保険区分
 opp.remarks, --備考欄情報
 opp.insu_dr_id, --保険医ID
 personal_info_decrypt(opp.insu_dr_name) as insu_dr_name,--保険医名称
 personal_info_decrypt(opp.insu_dr_sign) as insu_dr_sign,--保険医署名
 mpu.anesthesiologist_license_no,--麻薬施用者番号
 pi.insu_name --保険名称
FROM
 ord_personal_prescription opp
 LEFT JOIN mst_personal_user mpu ON opp.insu_dr_id = mpu.user_id and mpu.is_del =''0'' and mpu.is_disp =''1''
 LEFT JOIN pat_insurance pi ON opp.insurance_cd = pi.insurance_cd  and pi.is_del =''0'' and pi.is_disp =''1''
WHERE
opp.is_del =''0'' and opp.is_disp =''1''  
-- and (opp.ord_prescription_no in (@ordPrescriptionNos)  or 0 in (@ordPrescriptionNos))
and opp.ord_prescription_no = @ordPrescriptionNo
 ',db_class=3,detail='[{"preview": "123456789", "can_calc": "0", "data_code": "insu_no", "data_name": "保険者番号", "data_type": "string", "conv_table": [], "data_class": "処方", "field_name": "insu_no", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12345678", "can_calc": "0", "data_code": "insu_pat_mark", "data_name": "被保険者証記号", "data_type": "string", "conv_table": [], "data_class": "処方", "field_name": "insu_pat_mark", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "insu_pat_no", "data_name": "被保険者証番号", "data_type": "string", "conv_table": [], "data_class": "処方", "field_name": "insu_pat_no", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxxxx", "can_calc": "0", "data_code": "insu_pub_no", "data_name": "公費負担者番号", "data_type": "string", "conv_table": [], "data_class": "処方", "field_name": "insu_pub_no", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub_pat_no", "data_name": "公費負担受給者番号", "data_type": "string", "conv_table": [], "data_class": "処方", "field_name": "insu_pub_pat_no", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "被保険者", "can_calc": "0", "data_code": "insu_kbn", "data_name": "保険区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "被保険者", "item": "被保険者"}, {"code": "1", "disp": "被扶養者", "item": "被扶養者"}], "data_class": "処方", "field_name": "insu_kbn", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "なし", "can_calc": "0", "data_code": "remarks", "data_name": "備考欄情報", "data_type": "string", "conv_table": [], "data_class": "処方", "field_name": "remarks", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxxx", "can_calc": "0", "data_code": "insu_dr_id", "data_name": "保険医ID", "data_type": "string", "conv_table": [], "data_class": "処方", "field_name": "insu_dr_id", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装　太郎", "can_calc": "0", "data_code": "insu_dr_name", "data_name": "保険医名称", "data_type": "string", "conv_table": [], "data_class": "処方", "field_name": "insu_dr_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装　太郎", "can_calc": "0", "data_code": "insu_dr_sign", "data_name": "保険医署名", "data_type": "string", "conv_table": [], "data_class": "処方", "field_name": "insu_dr_sign", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxxxxx", "can_calc": "0", "data_code": "anesthesiologist_license_no", "data_name": "麻薬施用者番号", "data_type": "string", "conv_table": [], "data_class": "処方", "field_name": "anesthesiologist_license_no", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxx保険", "can_calc": "0", "data_code": "insu_name", "data_name": "保険名称", "data_type": "string", "conv_table": [], "data_class": "処方", "field_name": "insu_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}]',can_repeat='0',use_application='{"applications": [1]}',report_class='{"classes": [2]}',memo='処方：@facilityCd @patId @ordPrescriptionNo  使用',reg_date='2021-02-16T13:42:00',up_date='2021-02-16T13:42:00',pre_sql_info=null where sql_cd=137;
update ntss.sys_data_set set "sql"=' SELECT
 ( o ->> ''Rp'' ) AS rp, --RP番号
 ( o ->> ''unchg'' ) AS unchg, --unchg
 ( o ->> ''type'' ) AS type, --type
 ( o ->> ''F1'' ) AS f1, --F1
 ( o ->> ''F2'' ) AS f2, --F2
 ( o ->> ''F3'' ) AS f3, --F3
 ( o ->> ''F4'' ) AS f4, --F4
 ( o ->> ''F5'' ) AS f5, --量
 ( o ->> ''F6'' ) AS f6, --単位 
 ( o ->> ''R'' ) AS r,   --薬剤名称
 to_date(op.issue_date, ''YYYYMMDD'') issue_date,--交付日
 to_date(op.expiration_date, ''YYYYMMDD'') expiration_date, --使用期限
 op.issue_state AS issue_state, --交付状態
 op.ord_prescription_no  AS ord_prescription_no --処方オーダー番号
FROM
 ord_prescription AS op,
 jsonb_array_elements (prescription_detail) AS o 
WHERE
 op.facility_cd = @facilityCd
 AND
 op.pat_id = @patId
 AND op.is_del=''0''
 -- and (op.ord_prescription_no in (@ordPrescriptionNos)  or 0 in (@ordPrescriptionNos))
 and op.ord_prescription_no = @ordPrescriptionNo
 order by op asc ,type asc',db_class=2,detail='[{"preview": "123456", "can_calc": "0", "data_code": "Rp", "data_name": "RP番号", "data_type": "string", "conv_table": [], "data_class": "簡易処方", "field_name": "rp", "disp_format": "", "data_category": "簡易処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤１", "can_calc": "0", "data_code": "R", "data_name": "薬剤名称", "data_type": "string", "conv_table": [], "data_class": "簡易処方", "field_name": "r", "disp_format": "", "data_category": "簡易処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "内服", "can_calc": "0", "data_code": "type", "data_name": "タグ", "data_type": "string", "conv_table": [{"code": "1", "disp": "薬剤", "item": "薬剤"}, {"code": "2", "disp": "内服", "item": "内服"}, {"code": "3", "disp": "外用", "item": "外用"}, {"code": "4", "disp": "頓服内服", "item": "頓服内服"}, {"code": "5", "disp": "頓服外用", "item": "頓服外用"}, {"code": "6", "disp": "コメント", "item": "コメント"}, {"code": "E", "disp": "最終行", "item": "最終行"}], "data_class": "簡易処方", "field_name": "type", "disp_format": "", "data_category": "簡易処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "×", "can_calc": "0", "data_code": "unchg", "data_name": "unchg", "data_type": "string", "conv_table": [], "data_class": "簡易処方", "field_name": "unchg", "disp_format": "", "data_category": "簡易処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤名", "can_calc": "0", "data_code": "F1", "data_name": "薬剤名/用法", "data_type": "string", "conv_table": [], "data_class": "簡易処方", "field_name": "f1", "disp_format": "", "data_category": "簡易処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "調剤指示名", "can_calc": "0", "data_code": "F2", "data_name": "調剤指示名/用法詳細", "data_type": "string", "conv_table": [], "data_class": "簡易処方", "field_name": "f2", "disp_format": "", "data_category": "簡易処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "舌下", "can_calc": "0", "data_code": "F3", "data_name": "部位", "data_type": "string", "conv_table": [], "data_class": "簡易処方", "field_name": "f3", "disp_format": "", "data_category": "簡易処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "F4", "data_name": "左右", "data_type": "string", "conv_table": [], "data_class": "簡易処方", "field_name": "f4", "disp_format": "", "data_category": "簡易処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "F5", "data_name": "用量", "data_type": "string", "conv_table": [], "data_class": "簡易処方", "field_name": "f5", "disp_format": "", "data_category": "簡易処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日分", "can_calc": "0", "data_code": "F6", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "簡易処方", "field_name": "f6", "disp_format": "", "data_category": "簡易処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2018/01/02", "can_calc": "0", "data_code": "issue_date", "data_name": "交付日", "data_type": "DateTime", "conv_table": [], "data_class": "簡易処方", "field_name": "issue_date", "disp_format": "yyyy/mm/dd", "data_category": "簡易処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2018/02/03", "can_calc": "0", "data_code": "expiration_date", "data_name": "使用期限", "data_type": "DateTime", "conv_table": [], "data_class": "簡易処方", "field_name": "expiration_date", "disp_format": "yyyy/mm/dd", "data_category": "簡易処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "未交付", "can_calc": "0", "data_code": "issue_state", "data_name": "交付状態", "data_type": "string", "conv_table": [{"code": "0", "disp": "未交付", "item": "未交付"}, {"code": "1", "disp": "交付済み", "item": "交付済み"}], "data_class": "簡易処方", "field_name": "issue_state", "disp_format": "", "data_category": "簡易処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456", "can_calc": "0", "data_code": "ord_prescription_no", "data_name": "処方オーダー番号", "data_type": "string", "conv_table": [], "data_class": "簡易処方", "field_name": "ord_prescription_no", "disp_format": "", "data_category": "簡易処方", "facility_table": "", "facility_filter_type": "0"}]',can_repeat='1',use_application='{"applications": [1]}',report_class='{"classes": [2]}',memo='処方：@facilityCd @patId @ordPrescriptionNo  使用',reg_date='2021-02-16T13:42:00',up_date='2021-02-16T13:42:00',pre_sql_info=null where sql_cd=138;

update ntss.sys_data_set set "sql"='with machine_tbl as (
  select
    mm.*,
    mmt.machine_type
  from
    mst_machine as mm
      left join mst_machine_type as mmt on mm.machine_type_cd = mmt.machine_type_cd
  where
    machine_no = @machineNo
  and
    is_disp =''1''
  and
    is_del = ''0''

-- 予定

), mainte_layout_tbl as (
  select
    *
  from
    mst_mainte_layout
  where
    facility_cd = (select facility_cd from machine_tbl)
  and
    layout_class = ''1''
  and
    is_disp = ''1''
  and
    is_del = ''0''

), mainte_plan_tbl as (
  select
    generate_series as mainte_date
  from
    generate_series(@fromDate::timestamp, @toDate::timestamp, ''1 day'')

), mainte_tbl as (
  select
    0 as mainte_no,
    mt.facility_cd,
    ''1''::text as mainte_class,
    mt.machine_no,
    null::integer as rec_no,
    mpt.mainte_date,
    mlt.mainte_layout_cd,
    mlt.edition_no as mainte_layout_edition,
    null::text as checker_id_1,
    null::text as checker_id_2,
    null::text as mainte_ans_1,
    null::text as mainte_ans_2,
    to_char(mpt.mainte_date, ''YYYY/MM/DD'') as up_date,    

    mt.machine_serial,
    mt.machine_type,

    mlt.layout_name

  from
      mainte_plan_tbl as mpt,
      machine_tbl as mt,
      mainte_layout_tbl as mlt

-- 実績
), mainte_layout_hst as (
  select
    *
  from
    mst_mainte_layout_hst
  where
    facility_cd = (select facility_cd from machine_tbl)
  and
    layout_class = ''1''
  and
    is_disp = ''1''
  and
    is_del = ''0''


), mainte_work as (
  select
    *

  from
    mnt_mainte_main
  where
    mainte_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
  and
    mainte_class = ''1''
  and
    is_disp = ''1''
  and
    is_del = ''0''


), mainte_hst as (
  select
    mw.mainte_no,
    mw.facility_cd,
    mw.mainte_class,
    mw.machine_no,
    mw.rec_no,
    mw.mainte_date,
    mw.mainte_layout_cd,
    mw.mainte_layout_edition,
    mw.checker_id_1,
    mw.checker_id_2,
    mw.mainte_ans_1,
    mw.mainte_ans_2,
    to_char(mw.up_date, ''YYYY/MM/DD'') as up_date,

    mt.machine_serial,
    mt.machine_type,

    mlh.layout_name

  from
    mainte_work mw
      inner join machine_tbl as mt
        on mw.machine_no = mt.machine_no
      inner join mainte_layout_hst as mlh
        on mw.mainte_layout_cd = mlh.mainte_layout_cd and mw.mainte_layout_edition = mlh.edition_no

)
select
  *
from
  mainte_hst
union all
select
  *
from
  mainte_tbl
where
  mainte_layout_cd || '','' || mainte_date not in (select mainte_layout_cd || '','' || mainte_date from mainte_hst)
order by
  mainte_date, layout_name
;',db_class=2,detail='[{"preview": "1", "can_calc": "0", "data_code": "machine_no", "data_name": "装置番号", "data_type": "string", "conv_table": [], "data_class": "日常点検", "field_name": "machine_no", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "I7012104", "can_calc": "0", "data_code": "machine_com_format_serial", "data_name": "製造番号", "data_type": "string", "conv_table": [], "data_class": "日常点検", "field_name": "machine_serial", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-27", "can_calc": "0", "data_code": "machine_type", "data_name": "型式", "data_type": "string", "conv_table": [], "data_class": "日常点検", "field_name": "machine_type", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-100NX_113", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "日常点検", "field_name": "machine_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "mainte_date", "data_name": "点検日", "data_type": "DateTime", "conv_table": [], "data_class": "日常点検", "field_name": "mainte_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "mainte_ans_1", "data_name": "総合判定", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "点検途中", "item": "点検途中"}, {"code": "3", "disp": "不合格", "item": "不合格"}], "data_class": "日常点検", "field_name": "mainte_ans_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウトグループ名", "can_calc": "0", "data_code": "group_name", "data_name": "レイアウトグループ名", "data_type": "string", "conv_table": [], "data_class": "日常点検", "field_name": "group_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウト名", "can_calc": "0", "data_code": "layout_name", "data_name": "レイアウト名", "data_type": "string", "conv_table": [], "data_class": "日常点検", "field_name": "layout_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_1", "data_name": "実施者", "data_type": "string", "conv_table": [], "data_class": "日常点検", "field_name": "checker_id_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "up_date", "data_name": "更新日", "data_type": "string", "conv_table": [], "data_class": "日常点検", "field_name": "up_date", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]',can_repeat='1',use_application='{"applications": [1]}',report_class='{"classes": [7]}',memo='装置保守：日常点検　@machineNo @fromDate @toDate使用',reg_date='2020-03-31T17:35:00',up_date='2020-04-24T00:00:00',pre_sql_info=null where sql_cd=108;
update ntss.sys_data_set set "sql"='with machine_tbl as (
  select
    mm.*,
    mmt.machine_type
  from
    mst_machine as mm
      left join mst_machine_type as mmt on mm.machine_type_cd = mmt.machine_type_cd
  where
    machine_no = @machineNo
  and
    is_disp =''1''
  and
    is_del = ''0''


-- 予定
), mainte_layout_tbl as (
  select
    *
  from
    mst_mainte_layout
  where
    facility_cd = (select facility_cd from machine_tbl)
  and
    layout_class = ''1''
  and
    is_disp = ''1''
  and
    is_del = ''0''

), mainte_layout_work as (
  select
    mainte_category_idx,
    mainte_category_cd,
    mainte_layout_tbl.mainte_layout_cd,
    mainte_layout_tbl.edition_no
  from
    mainte_layout_tbl
      cross join lateral jsonb_array_elements_text(detail_info_1)
        with ordinality as tmp(mainte_category_cd, mainte_category_idx)

), mainte_category_tbl as (
  select
    *
  from
    mst_mainte_category
  where
    facility_cd = (select facility_cd from machine_tbl)
  and
    is_disp = ''1''
  and
    is_del = ''0''

), mainte_category_work as (
  select
    mainte_detail_idx,
    mainte_detail_cd,
    mainte_category_tbl.mainte_category_cd,
    mainte_category_tbl.edition_no,
    mainte_category_tbl.category_name
  from
    mainte_category_tbl
      cross join lateral jsonb_array_elements_text(detail)
        with ordinality as tmp(mainte_detail_cd, mainte_detail_idx)

), mainte_detail_tbl as (
  select
    mmd.*,

    mcw.edition_no as mainte_category_edition,
    mcw.category_name,

    mlw.mainte_category_idx,
    mcw.mainte_detail_idx,
    mlw.mainte_layout_cd,
    mlw.edition_no as mainte_layout_edition


  from
    mst_mainte_detail as mmd
      inner join mainte_category_work as mcw
        on (mcw.mainte_detail_cd::json->>''code'')::text = mmd.mainte_detail_cd::text

      inner join mainte_layout_work as mlw
        on (mlw.mainte_category_cd::json->>''cd'')::text = mcw.mainte_category_cd::text

  where
    mmd.facility_cd = (select facility_cd from machine_tbl)
  and
    mmd.is_disp = ''1''
  and
    mmd.is_del = ''0''


), mainte_plan_tbl as (
  select
    generate_series as mainte_date
  from
    generate_series(@fromDate::timestamp, @toDate::timestamp, ''1 day'')


), mainte_tbl as (
  select
    0 as mainte_no,
    mt.facility_cd,
    ''1''::text as mainte_class,
    mt.machine_no,
    null::integer as rec_no,
    mpt.mainte_date,
    mlt.mainte_layout_cd,
    mlt.edition_no as mainte_layout_edition,
    null::text as checker_id_1,
    null::text as checker_id_2,
    null::text as mainte_ans_1,
    null::text as mainte_ans_2,

    mt.com_format_cd || mt.machine_serial as machine_com_format_serial,
    mt.machine_serial,
    mt.machine_type,

    mlt.layout_name,
    mt.machine_name,
    mdt.mainte_detail_cd::text,
    mdt.edition_no::text as mainte_detail_edition,
    null::text as answer,
    null::text as comment,
    null::text as chekerId,
    null::text as regDate,
    mdt.mainte_category_cd,
    mdt.mainte_content_1,
    mdt.mainte_content_2,
    mdt.mainte_content_3,
    mdt.mainte_category_edition,
    mdt.category_name,

    mdt.mainte_category_idx,
    mdt.mainte_detail_idx

  from
      mainte_plan_tbl as mpt,
      machine_tbl as mt,
      mainte_layout_tbl as mlt,
      mainte_detail_tbl as mdt
  where 
     mlt.edition_no = mdt.mainte_layout_edition and 
     mlt.mainte_layout_cd = mdt.mainte_layout_cd


-- 実績
), mainte_layout_hst as (
  select
    *
  from
    mst_mainte_layout_hst
  where
    facility_cd = (select facility_cd from machine_tbl)
  and
    layout_class = ''1''
  and
    is_disp = ''1''
  and
    is_del = ''0''

), mainte_category_hst as (
  select
    *
  from
    mst_mainte_category_hst
  where
    facility_cd = (select facility_cd from machine_tbl)
  and
    is_disp = ''1''
  and
    is_del = ''0''

), mainte_detail_hst as (
  select
    *
  from
    mst_mainte_detail_hst
  where
    facility_cd = (select facility_cd from machine_tbl)
  and
    is_disp = ''1''
  and
    is_del = ''0''



), mainte_work as (
  select
    *

  from
    mnt_mainte_main
  where
     facility_cd = (select facility_cd from machine_tbl)
  and    
     machine_no = @machineNo
  and    
    mainte_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
  and
    mainte_class = ''1''
  and
    is_disp = ''1''
  and
    is_del = ''0''

), mainte_main_detail_hst as (
  select
    mainte_no,
    json_idx as mainte_detail_idx,
    info->>''detail_cd'' as detail_cd,
    info->>''detail_edi'' as edition,
    info->>''judge'' as judge,
    info->>''comment'' as comment,
    info->>''user_id'' as user_id,
    info->>''date'' as date,
    info->>''cate_cd'' as cate_cd,
    info->>''cate_edi'' as cate_edi

  from
    mainte_work as mt
      cross join lateral jsonb_array_elements(detail)
        with ordinality as tmp(info, json_idx)

), mainte_main_category_hst as (
  select
    mainte_no,
    json_idx as mainte_category_idx,
    info->>''mainteCategoryCd'' as category_cd,
    info->>''editionNo'' as edition

  from
    mainte_work as mt
      cross join lateral jsonb_array_elements(mainte_category_cd)
        with ordinality as tmp(info, json_idx)


), mainte_hst as (
  select
    mw.mainte_no,
    mw.facility_cd,
    mw.mainte_class,
    mw.machine_no,
    mw.rec_no,
    mw.mainte_date,
    mw.mainte_layout_cd,
    mw.mainte_layout_edition,
    mw.checker_id_1,
    mw.checker_id_2,
    mw.mainte_ans_1,
    mw.mainte_ans_2,

    mt.com_format_cd || mt.machine_serial as machine_com_format_serial,
    mt.machine_serial,
    mt.machine_type,

    mlh.layout_name,
    mt.machine_name,
    mmdh.detail_cd as mainte_detail_cd,
    mmdh.edition as mainte_detail_edition,
    mmdh.judge,
    mmdh.comment,
    mmdh.user_id,
    mmdh.date,

    mdh.mainte_category_cd,
    mdh.mainte_content_1,
    mdh.mainte_content_2,
    mdh.mainte_content_3,

    mch.edition_no as mainte_category_edition,
    mch.category_name,

    mmch.mainte_category_idx,
    mmdh.mainte_detail_idx


  from
    mainte_work mw
      inner join machine_tbl as mt
        on mw.machine_no = mt.machine_no
      inner join mainte_layout_hst as mlh
        on mw.mainte_layout_cd = mlh.mainte_layout_cd and mw.mainte_layout_edition = mlh.edition_no
      inner join mainte_main_detail_hst as mmdh
        on mw.mainte_no = mmdh.mainte_no
      inner join mainte_detail_hst as mdh
        on mmdh.detail_cd = mdh.mainte_detail_cd::text and mmdh.edition = mdh.edition_no::text
      inner join mainte_category_hst as mch
        on mmdh.cate_cd = mch.mainte_category_cd::text and mmdh.cate_edi = mch.edition_no::text
      inner join mainte_main_category_hst as mmch
        on mmdh.mainte_no = mmch.mainte_no
        and mmdh.cate_cd = mmch.category_cd::text and mmdh.cate_edi = mmch.edition::text
)
select
  *
from
  mainte_hst
union all
select
  *
from
  mainte_tbl
where
  mainte_layout_cd || '','' || mainte_date not in (select mainte_layout_cd || '','' || mainte_date from mainte_hst)

order by
  mainte_date, layout_name, mainte_category_idx, mainte_detail_idx;',db_class=2,detail='[{"preview": "1", "can_calc": "0", "data_code": "machine_no", "data_name": "装置番号", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "machine_no", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "I7012104", "can_calc": "0", "data_code": "machine_com_format_serial", "data_name": "製造番号", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "machine_com_format_serial", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-27", "can_calc": "0", "data_code": "machine_type", "data_name": "型式", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "machine_type", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-100NX_113", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "machine_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "mainte_date", "data_name": "点検日", "data_type": "DateTime", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "mainte_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "mainte_ans_1", "data_name": "総合判定", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "点検途中", "item": "点検途中"}, {"code": "3", "disp": "不合格", "item": "不合格"}], "data_class": "日常点検（詳細含む）", "field_name": "mainte_ans_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウトグループ名", "can_calc": "0", "data_code": "group_name", "data_name": "レイアウトグループ名", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "group_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウト名", "can_calc": "0", "data_code": "layout_name", "data_name": "レイアウト名", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "layout_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "judge", "data_name": "合否", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "点検途中", "item": "点検途中"}, {"code": "3", "disp": "不合格", "item": "不合格"}], "data_class": "日常点検（詳細含む）", "field_name": "judge", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "問題なしです。", "can_calc": "0", "data_code": "comment", "data_name": "点検コメント", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "comment", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_detail_cd", "data_name": "点検項目番号", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "mainte_detail_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検見出し", "can_calc": "0", "data_code": "category_name", "data_name": "点検見出し", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "category_name", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検対象", "can_calc": "0", "data_code": "mainte_content_1", "data_name": "点検対象", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "mainte_content_1", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検基準", "can_calc": "0", "data_code": "mainte_content_2", "data_name": "点検基準", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "mainte_content_2", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検者", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "user_id", "data_name": "点検者", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "user_id", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/17", "can_calc": "0", "data_code": "date", "data_name": "個別点検日", "data_type": "DateTime", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]',can_repeat='1',use_application='{"applications": [1]}',report_class='{"classes": [7]}',memo='装置保守：日常点検詳細　@machineNo @fromDate @toDate使用',reg_date='2020-03-31T17:35:00',up_date='2020-04-24T00:00:00',pre_sql_info=null where sql_cd=109;
update ntss.sys_data_set set "sql"='with machine_tbl as (
select
mm.*,
mmt.machine_type
from
mst_machine as mm
left join mst_machine_type as mmt on mm.machine_type_cd = mmt.machine_type_cd
where 
machine_no = @machineNo
and
is_disp =''1''
and
is_del = ''0''

-- 予定
), mainte_layout_group_tbl as (
select
*
from
mst_mainte_layout_group
where
facility_cd = (select facility_cd from machine_tbl)
and
is_disp = ''1''
and
is_del = ''0''

), mainte_layout_tbl as (
select
*
from
mst_mainte_layout
where
facility_cd = (select facility_cd from machine_tbl)
and
layout_class = ''2''
and
(select machine_type_cd from machine_tbl)::text  in
(SELECT json_array_elements_text(
(SELECT to_json(type_info)))::text)
and
is_disp = ''1''
and
is_del = ''0''

), mainte_work as (
select
*
from
mnt_mainte_main
where 
machine_no = @machineNo
and
mainte_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
and
mainte_class = ''2''
and
mainte_layout_edition is null
and
is_disp = ''1''
and
is_del = ''0''


), mainte_tbl as (
select
mw.mainte_no,
mw.facility_cd,
mw.mainte_class,
mw.machine_no,
mw.rec_no,
mw.mainte_date,
mw.mainte_layout_group_cd,
mw.mainte_layout_group_edition,
mlt.mainte_layout_cd,
mw.mainte_layout_edition,
mw.checker_id_1,
mw.checker_id_2,
mw.mainte_ans_1,
mw.mainte_ans_2,

mt.machine_serial,
mt.machine_type,

mlgt.group_name,

mlt.layout_name,
mt.machine_name,
mw.mainte_comment_1,
mw.mainte_comment_2,
mw.up_date

from
mainte_work as mw
inner join machine_tbl as mt
on mw.machine_no = mt.machine_no
inner join mainte_layout_group_tbl as mlgt
on mw.mainte_layout_group_cd = mlgt.mainte_layout_group_cd
inner join mainte_layout_tbl as mlt
on (mlt.mainte_layout_cd::text  in (SELECT json_array_elements_text(
(SELECT to_json(mlgt.layout_list)))::text))

-- 実績
), mainte_layout_group_hst as (
select
*
from
mst_mainte_layout_group_hst
where
facility_cd = (select facility_cd from machine_tbl)
and
is_disp = ''1''
and
is_del = ''0''

), mainte_layout_hst as (
select
*
from
mst_mainte_layout_hst
where
facility_cd = (select facility_cd from machine_tbl)
and
is_disp = ''1''
and
is_del = ''0''


), mainte_hst_work as (
select
*

from
mnt_mainte_main
where 

facility_cd = (select facility_cd from machine_tbl)
and
machine_no = @machineNo
and
mainte_date between date_trunc(''day'',@fromDate ::timestamp ) and date_trunc(''day'',@toDate ::timestamp) + ''1 days - 1 milliseconds''
and
mainte_class = ''2''
and
mainte_layout_edition is not null
and
is_disp = ''1''
and
is_del = ''0''


), mainte_hst as (
select
mhw.mainte_no,
mhw.facility_cd,
mhw.mainte_class,
mhw.machine_no,
mhw.rec_no,
mhw.mainte_date,
mhw.mainte_layout_group_cd,
mhw.mainte_layout_group_edition,
mlh.mainte_layout_cd,
mhw.mainte_layout_edition,
mhw.checker_id_1,
mhw.checker_id_2,
mhw.mainte_ans_1,
mhw.mainte_ans_2,

mt.machine_serial,
mt.machine_type,

mlgh.group_name,

mlh.layout_name,
mt.machine_name,
mhw.mainte_comment_1,
mhw.mainte_comment_2,
mhw.up_date

from
mainte_hst_work mhw
inner join machine_tbl as mt
on mhw.machine_no = mt.machine_no
inner join mainte_layout_group_hst as mlgh
on mhw.mainte_layout_group_cd = mlgh.mainte_layout_group_cd and mhw.mainte_layout_group_edition = mlgh.edition_no
inner join mainte_layout_hst as mlh
on mlh.mainte_layout_cd ::text in
(SELECT json_array_elements_text(
(SELECT to_json(mlgh.layout_list)))::text) and mhw.mainte_layout_edition = mlh.edition_no
)
select
*
from
mainte_tbl
union all
select
*
from
mainte_hst

order by
mainte_date, layout_name',db_class=2,detail='[{"preview": "1", "can_calc": "0", "data_code": "machine_no", "data_name": "装置番号", "data_type": "string", "conv_table": [], "data_class": "定期点検", "field_name": "machine_no", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "I7012104", "can_calc": "0", "data_code": "machine_com_format_serial", "data_name": "製造番号", "data_type": "string", "conv_table": [], "data_class": "定期点検", "field_name": "machine_serial", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-27", "can_calc": "0", "data_code": "machine_type", "data_name": "型式", "data_type": "string", "conv_table": [], "data_class": "定期点検", "field_name": "machine_type", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-100NX_113", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "定期点検", "field_name": "machine_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "mainte_date", "data_name": "点検日", "data_type": "DateTime", "conv_table": [], "data_class": "定期点検", "field_name": "mainte_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウトグループ名", "can_calc": "0", "data_code": "group_name", "data_name": "レイアウトグループ名", "data_type": "string", "conv_table": [], "data_class": "定期点検", "field_name": "group_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウト名", "can_calc": "0", "data_code": "layout_name", "data_name": "レイアウト名", "data_type": "string", "conv_table": [], "data_class": "定期点検", "field_name": "layout_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "mainte_ans_1", "data_name": "定期点検記録総合判定", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "定期点検", "field_name": "mainte_ans_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "mainte_ans_2", "data_name": "定期交換部品記録総合判定", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "定期点検", "field_name": "mainte_ans_2", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_1", "data_name": "実施者", "data_type": "string", "conv_table": [], "data_class": "定期点検", "field_name": "checker_id_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_2", "data_name": "確認者", "data_type": "string", "conv_table": [], "data_class": "定期点検", "field_name": "checker_id_2", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "定期検査記録コメント：問題なしです。", "can_calc": "0", "data_code": "mainte_comment_1", "data_name": "定期検査記録コメント", "data_type": "string", "conv_table": [], "data_class": "定期点検", "field_name": "mainte_comment_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "定期交換部品記録コメント：問題なしです。", "can_calc": "0", "data_code": "mainte_comment_2", "data_name": "定期交換部品記録コメント", "data_type": "string", "conv_table": [], "data_class": "定期点検", "field_name": "mainte_comment_2", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "up_date", "data_name": "更新日", "data_type": "DateTime", "conv_table": [], "data_class": "定期点検", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]',can_repeat='1',use_application='{"applications": [1]}',report_class='{"classes": [7]}',memo='装置保守：定期点検　@machineNo @fromDate @toDate使用',reg_date='2020-03-31T17:35:00',up_date='2020-04-25T00:00:00',pre_sql_info=null where sql_cd=110;
update ntss.sys_data_set set "sql"='with machine_tbl as (
select
mm.*,
mmt.machine_type
from
mst_machine as mm
left join mst_machine_type as mmt on mm.machine_type_cd = mmt.machine_type_cd
where
machine_no = @machineNo

and
is_disp =''1''
and
is_del = ''0''

-- 予定
), mainte_layout_group_tbl as (
select
*
from
mst_mainte_layout_group
where
facility_cd = (select facility_cd from machine_tbl)
and
is_disp = ''1''
and
is_del = ''0''

), mainte_layout_tbl as (
select
*
from
mst_mainte_layout
where
facility_cd = (select facility_cd from machine_tbl)
and
layout_class = ''2''
and
( SELECT machine_type_cd FROM machine_tbl ) :: TEXT IN ( SELECT json_array_elements_text ( ( SELECT to_json ( type_info ) ) ) :: TEXT ) 
and
is_disp = ''1''
and
is_del = ''0''

), mainte_layout_work1 as (
select
''1''::text as tabIndex,
mainte_category_idx,
mainte_category_cd,
mainte_layout_cd,
edition_no
from
mainte_layout_tbl
cross join lateral jsonb_array_elements_text(detail_info_1)
with ordinality as tmp(mainte_category_cd, mainte_category_idx)

), mainte_layout_work2 as (
select
''2''::text as tabIndex,
mainte_category_idx,
mainte_category_cd,
mainte_layout_cd,
edition_no
from
mainte_layout_tbl
cross join lateral jsonb_array_elements_text(detail_info_2)
with ordinality as tmp(mainte_category_cd, mainte_category_idx)

), mainte_layout_work as (
select
*
from
mainte_layout_work1
union all
select
*
from
mainte_layout_work2

), mainte_category_tbl as (
select
*
from
mst_mainte_category
where
facility_cd = (select facility_cd from machine_tbl)
and
is_disp = ''1''
and
is_del = ''0''

), mainte_category_work as (
select
mainte_detail_idx,
mainte_detail_cd,
mainte_category_tbl.mainte_category_cd,
mainte_category_tbl.edition_no,
mainte_category_tbl.category_name
from
mainte_category_tbl
cross join lateral jsonb_array_elements_text(detail)
with ordinality as tmp(mainte_detail_cd, mainte_detail_idx)

),mainte_detail_tbl as (
select
mmd.*,

mlw.tabIndex,

mct.edition_no as mainte_category_edition,
mct.category_name,

mlw.mainte_category_idx,
mct.mainte_detail_idx,
mlw.mainte_layout_cd,
mlw.edition_no as mainte_layout_edition
from
mst_mainte_detail as mmd
inner join mainte_category_work as mct on (mct.mainte_detail_cd::json->>''code'')::text = mmd.mainte_detail_cd::text
and (mct.mainte_detail_cd::json->>''isDisp'')::text = ''1''
inner join mainte_layout_work as mlw
on (mlw.mainte_category_cd::json->>''cd'')::text = mct.mainte_category_cd::text
and (mlw.mainte_category_cd::json->>''isDisp'')::text = ''true''
where
mmd.facility_cd = (select facility_cd from machine_tbl)
and
mmd.is_disp = ''1''
and
mmd.is_del = ''0''

), mainte_work as (
select
*

from
mnt_mainte_main
where
machine_no = @machineNo

and
mainte_date between date_trunc(''day'', @fromDate
::timestamp ) and date_trunc(''day'', @toDate
::timestamp) + ''1 days - 1 milliseconds''
and
mainte_class = ''2''
and
is_disp = ''1''
and
is_del = ''0''

), mainte_tbl as (
select
mw.mainte_no,
mw.facility_cd,
''2''::text as mainte_class,
mw.machine_no,
mw.rec_no,
mw.mainte_date,
mw.mainte_layout_group_cd,
mw.mainte_layout_group_edition,
mw.mainte_layout_cd,
mw.mainte_layout_edition,
mw.checker_id_1,
mw.checker_id_2,
mw.mainte_ans_1,
mw.mainte_ans_2,

mt.com_format_cd || mt.machine_serial as machine_com_format_serial,
mt.machine_serial,
mt.machine_type,

mlgt.group_name,

mlt.layout_name,
mdt.mainte_detail_cd::bigint as mainte_detail_cd,
mdt.edition_no::integer as mainte_detail_edition,
null::text as judge,
null::text as comment,
null::text as user_id,
null::text as date,
mdt.tabIndex,
mdt.mainte_category_cd,
mdt.mainte_content_1,
mdt.mainte_content_2,
mdt.mainte_content_3,
mdt.mainte_category_edition::text as mainte_category_edition,
mdt.category_name,
mdt.mainte_detail_idx

from
mainte_work as mw
, machine_tbl as mt
, mainte_layout_group_tbl as mlgt
, mainte_layout_tbl as mlt
, mainte_detail_tbl as mdt
where
mlt.edition_no = mdt.mainte_layout_edition and
mlt.mainte_layout_cd = mdt.mainte_layout_cd
-- 実績
), mainte_layout_group_hst as (
select
*
from
mst_mainte_layout_group_hst
where
facility_cd = (select facility_cd from machine_tbl)
and
is_disp = ''1''
and
is_del = ''0''

), mainte_layout_hst as (
select
*
from
mst_mainte_layout_hst
where
facility_cd = (select facility_cd from machine_tbl)
and
is_disp = ''1''
and
is_del = ''0''

), mainte_category_hst as (
select
*
from
mst_mainte_category_hst
where
facility_cd = (select facility_cd from machine_tbl)
and
is_disp = ''1''
and
is_del = ''0''

), mainte_detail_hst as (
select
*
from
mst_mainte_detail_hst as mmdh
where
facility_cd = (select facility_cd from machine_tbl)
and
is_disp = ''1''
and
is_del = ''0''


), mainte_hst_work as (
select
*
from
mnt_mainte_main
where

facility_cd = (select facility_cd from machine_tbl)
and    
machine_no = @machineNo

and
mainte_date between date_trunc(''day'', @fromDate
::timestamp ) and date_trunc(''day'', @toDate
::timestamp) + ''1 days - 1 milliseconds''
and
mainte_class = ''2''
and
is_disp = ''1''
and
is_del = ''0''

), mainte_main_detail_hst_1 as (
select
mainte_no,
details
from
mainte_hst_work as mhw
cross join lateral jsonb_array_elements(detail)
with ordinality as tmp(details, json_idx)

), mainte_main_detail_hst as (
select
mainte_no,
json_idx as mainte_detail_idx,                                                
info->>''detail_cd'' as detail_cd,                                                
info->>''edition'' as edition,                                                
info->>''judge'' as judge,                                                
info->>''comment'' as comment,                                                
info->>''user_id'' as user_id,                                                
info->>''date'' as date,                                                
info->>''cate_cd'' as cate_cd,                                                
info->>''cate_edi'' as cate_edi,    
info->>''tableIndex'' as tabIndex    
from
mainte_main_detail_hst_1 as mhw
cross join lateral jsonb_array_elements(mhw.details)
with ordinality as tmp(info, json_idx)

)
, mainte_hst as
(
select
mhw.mainte_no,
mhw.facility_cd,
mhw.mainte_class::text as mainte_class,
mhw.machine_no,
mhw.rec_no,
mhw.mainte_date,
mhw.mainte_layout_group_cd,
mhw.mainte_layout_group_edition,
mhw.mainte_layout_cd,
mhw.mainte_layout_edition,
mhw.checker_id_1,
mhw.checker_id_2,
mhw.mainte_ans_1 as mainte_ans1,
mhw.mainte_ans_2 as mainte_ans2,

mt.com_format_cd || mt.machine_serial as machine_com_format_serial,
mt.machine_serial,
mt.machine_type,

mlgh.group_name,

mlh.layout_name,

mmdh.detail_cd::bigint as mainte_detail_cd,
mmdh.edition::integer as mainte_detail_edition,
mmdh.judge::text as judge,
mmdh.comment::text as mainte_comment_1,
mmdh.user_id::text as user_id,
mmdh.date::text as date,
mmdh.tabIndex,
mdh.mainte_category_cd,
mdh.mainte_content_1 as ment_content_1,
mdh.mainte_content_2,
mdh.mainte_content_3,
mmdh.cate_edi as mainte_category_edition,
mch.category_name,
mmdh.mainte_detail_idx


from
mainte_hst_work mhw
inner join machine_tbl as mt
on mhw.machine_no = mt.machine_no
inner join mainte_layout_group_hst as mlgh
on mhw.mainte_layout_group_cd = mlgh.mainte_layout_group_cd and mhw.mainte_layout_group_edition = mlgh.edition_no
inner join mainte_layout_hst as mlh
on mhw.mainte_layout_cd = mlh.mainte_layout_cd and mhw.mainte_layout_edition = mlh.edition_no
inner join mainte_main_detail_hst as mmdh                                                
on mhw.mainte_no = mmdh.mainte_no
inner join mainte_detail_hst as mdh
on mmdh.detail_cd = mdh.mainte_detail_cd::text and mmdh.edition = mdh.edition_no::text

inner join mainte_category_hst as mch
on mmdh.cate_cd = mch.mainte_category_cd::text and mmdh.cate_edi = mch.edition_no::text

)

select                                    
*                                    
from                                    
mainte_hst                                    
union all                                    
select                                    
*                                    
from                                    
mainte_tbl        

where                                    
mainte_layout_cd || '','' || mainte_date not in (select mainte_layout_cd || '','' || mainte_date from mainte_hst)                                    

order by                                    
mainte_date, layout_name, mainte_detail_idx',db_class=2,detail='[{"preview": "1", "can_calc": "0", "data_code": "machine_no", "data_name": "装置番号", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "machine_no", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "I7012104", "can_calc": "0", "data_code": "machine_com_format_serial", "data_name": "製造番号", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "machine_com_format_serial", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-27", "can_calc": "0", "data_code": "machine_type", "data_name": "型式", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "machine_type", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-100NX_113", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "machine_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "mainte_date", "data_name": "点検日", "data_type": "DateTime", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "mainte_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウトグループ名", "can_calc": "0", "data_code": "group_name", "data_name": "レイアウトグループ名", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "group_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウト名", "can_calc": "0", "data_code": "layout_name", "data_name": "レイアウト名", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "layout_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "mainte_ans1", "data_name": "定期点検詳細記録総合判定", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "定期点検（詳細含む）", "field_name": "mainte_ans1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "mainte_ans2", "data_name": "定期交換部品記録総合判定", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "定期点検（詳細含む）", "field_name": "mainte_ans2", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_1", "data_name": "実施者", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "checker_id_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_2", "data_name": "確認者", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "checker_id_2", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "定期検査記録コメント：問題なしです。", "can_calc": "0", "data_code": "mainte_comment_1", "data_name": "定期検査記録コメント", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "mainte_comment_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "定期交換部品記録コメント：問題なしです。", "can_calc": "0", "data_code": "mainte_comment_1", "data_name": "定期交換部品記録コメント", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "mainte_comment_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "未", "can_calc": "0", "data_code": "judge", "data_name": "確認", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "レ", "item": "レ"}, {"code": "2", "disp": "〇", "item": "〇"}, {"code": "3", "disp": "?", "item": "?"}, {"code": "4", "disp": "A", "item": "A"}, {"code": "5", "disp": "T", "item": "T"}, {"code": "6", "disp": "C", "item": "C"}], "data_class": "定期点検（詳細含む）", "field_name": "judge", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "問題なしです。", "can_calc": "0", "data_code": "comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "comment", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_detail_cd", "data_name": "点検項目番号", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "mainte_detail_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検見出し", "can_calc": "0", "data_code": "category_name", "data_name": "点検見出し", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "category_name", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検対象", "can_calc": "0", "data_code": "ment_content_1", "data_name": "点検対象", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "ment_content_1", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検基準/交換部品", "can_calc": "0", "data_code": "mainte_content_2", "data_name": "点検基準/交換部品", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "mainte_content_2", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1500", "can_calc": "0", "data_code": "mainte_content_3", "data_name": "交換推奨時間", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "mainte_content_3", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]',can_repeat='1',use_application='{"applications": [1]}',report_class='{"classes": [7]}',memo='装置保守：定期点検詳細　@machineNo @fromDate @toDate使用',reg_date=now(),up_date=now(),pre_sql_info=null where sql_cd=111;
