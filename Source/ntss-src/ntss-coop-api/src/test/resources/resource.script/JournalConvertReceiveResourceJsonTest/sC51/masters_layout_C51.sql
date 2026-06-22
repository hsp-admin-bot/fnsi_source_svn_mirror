DELETE FROM mst_coop_layout
WHERE facility_cd = 'F_hC51';

insert into ntss.mst_coop_layout (
  facility_cd
  , coop_cd
  , coop_cd_index
  , direction
  , coop_cd_sub
  , coop_format
  , coop_name
  , coop_vender
  , description
  , is_editable
  , coop_setting
  , coop_ext_setting
  , is_disp
  , is_del
  , user_id
  , reg_date
  , up_date
) values ('F_hC51','ini_dial','','R','pre','text     ','富士通想定透析初回申し込み','Egmain-GX','テスト用','1','
<root name="透析初回申し込み">
    <item name="電文種別" len="2" key="電文種別" type="string"/>
    <item name="レコード継続指示" len="1" type="string"/>
    <item name="送信先システムコード" len="2"  type="string"/>
    <item name="発信元システムコード" len="2"  type="string"/>
    <item name="処理情報.処理年月日" len="8"  type="string"/>
    <item name="処理情報.処理時刻" len="6"  type="string"/>
    <item name="端末名" len="8"  type="string"/>
    <item name="利用者番号" len="8"  type="string"/>
    <item name="処理区分" len="2"  type="string" key="shori_kbn" />
    <item name="応答種別" len="2"  type="string"/>
    <item name="電文長" len="6"  type="string"/>
    <item name="エラーコード" len="5"  type="string"/>
    <item name="予備" len="12"  type="string"/>
    <item name="患者情報.患者番号" len="10"  type="string"/>
    <item name="伝票情報.オーダ番号" len="8"  type="string"/>
    <item name="伝票情報.親文書番号" len="30" type="string"/>
    <item name="伝票情報.文書番号" len="30" type="string"/>
    <item name="伝票情報.文書版数" len="2" type="string"/>
    <item name="伝票情報.関連オーダ番号" len="8" type="string"/>
    <item name="伝票情報.実施番号" len="8" type="string"/>
    <item name="伝票情報.更新後実施日時.実施日" len="8" type="string"/>
    <item name="伝票情報.更新後実施日時.実施時間" len="6" type="string"/>
    <item name="伝票情報.更新前実施日時.実施日" len="8" type="string"/>
    <item name="伝票情報.更新前実施日時.実施日実施時間" len="6" type="string"/>
    <item name="伝票情報.終了日時.終了日付" len="8" type="string"/>
    <item name="伝票情報.終了日時.終了日付終了時間" len="6" type="string"/>
    <item name="伝票情報.オーダ作成日.オーダ日付" len="8" type="string"/>
    <item name="伝票情報.オーダ作成日.オーダ時間" len="6" type="string"/>
    <item name="伝票情報.保険パターン番号" len="2" type="string"/>
    <item name="伝票情報.入外区分" len="1" type="string"/>
    <item name="伝票情報.診療科コード" len="3" type="string"/>
    <item name="伝票情報.診療科名称" len="32" type="string"/>
    <item name="伝票情報.病棟コード" len="3" type="string"/>
    <item name="伝票情報.病棟名称" len="32" type="string"/>
    <item name="伝票情報.オーダ発行利用者番号" len="8" type="string"/>
    <item name="伝票情報.オーダ発行利用者名" len="20" type="string"/>
    <item name="伝票情報.依頼医利用者番号" len="8" type="string"/>
    <item name="伝票情報.依頼医名" len="20" type="string"/>
    <item name="伝票情報.伝票種別" len="1" type="string"/>
    <item name="伝票情報.伝票コード" len="4" type="string"/>
    <occ name="明細行数" len="4" detail="ini_dial_meisai"/>
    <item name="終端" len="1" term="true"/>
    <item name="新規変更の区分" len="0"/>
</root>
  ','{"key": {"電文種別" : {"VI" : "ini_dial"}, "shori_kbn": {"01":"cre"}}}','1','0','4126','2019/12/13 5:44:54','2019/12/13 5:44:54');

insert into ntss.mst_coop_layout (
  facility_cd
  , coop_cd
  , coop_cd_index
  , direction
  , coop_cd_sub
  , coop_format
  , coop_name
  , coop_vender
  , description
  , is_editable
  , coop_setting
  , coop_ext_setting
  , is_disp
  , is_del
  , user_id
  , reg_date
  , up_date
) values ('F_hC51','ini_dial','','R','cre','text     ','富士通想定透析初回申し込み','Egmain-GX','テスト用','1','
<root name="透析初回申し込み">
  <item name="電文種別" len="2" type="string"/>
  <item name="レコード継続指示" len="1" type="string"/>
  <item name="送信先システムコード" len="2" type="string"/>
  <item name="発信元システムコード" len="2" type="string"/>
  <item name="処理情報.処理年月日" len="8" type="string"/>
  <item name="処理情報.処理時刻" len="6" type="string"/>
  <item name="端末名" len="8" type="string"/>
  <item name="利用者番号" len="8" type="string"/>
  <item name="処理区分" len="2" col="pat_personal_main.PROCTYPE" type="string" value="json:PROCTYPE"/>
  <item name="応答種別" len="2" type="string"/>
  <item name="電文長" len="6" type="string"/>
  <item name="エラーコード" len="5" type="string"/>
  <item name="予備" len="12" type="string"/>
<item name="姓" len="0" type="string" value="const:あああ" col="pat_personal_main.pat_last_name"/>
<item name="名" len="0" type="string" value="const:いいい" col="pat_personal_main.pat_first_name"/>

<occ repeat="8">
  <item name="ダミーpat_unique" len="0" col="pat_unique.medical_hst_info.ctl_no" value="const:11" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.medical_hst_info.disp_order" value="const:101" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.medical_hst_info.facility_cd" value="const:F_hC51" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.medical_hst_info.is_primary_illness" value="const:0" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.medical_hst_info.is_main_disease" value="const:1" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.medical_hst_info.is_notice" value="const:0" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.medical_hst_info.disease_date" value="const:1991-01-01" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.medical_hst_info.disease_cd" value="const:VB199999" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.medical_hst_info.out_come" value="const:3" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.medical_hst_info.out_come_date" value="const:9999-12-31" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.medical_hst_info.diagnostician_cd" value="const:01" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.medical_hst_info.memo" value="const:メモ" />

  <item name="ダミーpat_unique" len="0" col="pat_unique.medical_hst_info.diagnosis_year" value="const:1995" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.medical_hst_info.diagnosis_month" value="const:08" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.medical_hst_info.diagnosis_day" value="const:01" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.medical_hst_info.diagnosis_facility_cd" value="const:F_hC51" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.medical_hst_info.course_cd" value="const:1" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.medical_hst_info.is_confirmation_biopsy" value="const:0" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.medical_hst_info.is_diagnosed" value="const:0" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.medical_hst_info.is_dialysis_underlying_disease" value="const:0" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.medical_hst_info.disease_year" value="const:1994" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.medical_hst_info.disease_month" value="const:12" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.medical_hst_info.disease_day" value="const:15" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.medical_hst_info.course_is_free" value="const:0" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.medical_hst_info.diagnostician_is_free" value="const:0" />
</occ>
<occ repeat="8">
  <item name="ダミーpat_unique" len="0" col="pat_unique.physical_info.ctl_no" value="const:12" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.physical_info.exam_date" value="const:2020-04-13" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.physical_info.order_class" value="const:1" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.physical_info.height" value="const:170" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.physical_info.ctr_weight" value="const:80" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.physical_info.breast_dia" value="const:6.5" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.physical_info.chest_dia" value="const:42.0" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.physical_info.ctr" value="const:1" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.physical_info.dw" value="const:1" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.physical_info.target_weight" value="const:72" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.physical_info.indicator_cd" value="const:1" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.physical_info.indicator_start_date" value="const:2020-04-10" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.physical_info.memo" value="const:メモ" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.physical_info.pre_scale_upper" value="const:85" />
  <item name="ダミーpat_unique" len="0" col="pat_unique.physical_info.pre_scale_lower" value="const:70" />
</occ>

  <item name="患者情報.患者番号" len="10" col="pat_personal_main.hosp_pat_id" type="string"/>
  <item name="伝票情報.オーダ番号" len="8" col="pat_order_data.vender_1_info.cop_ord_no1" type="string"/>
  <item name="伝票情報.親文書番号" len="30" col="pat_order_data.vender_1_info.cop_ord_no2" type="string"/>
  <item name="伝票情報.文書番号" len="30" col="pat_order_data.vender_1_info.cop_ord_no3" type="string"/>
  <item name="伝票情報.文書版数" len="2" type="string"/>
  <item name="伝票情報.関連オーダ番号" len="8" type="string"/>
  <item name="伝票情報.実施番号" len="8" type="string"/>
  <item name="伝票情報.更新後実施日時.実施日" len="8" type="string"/>
  <item name="伝票情報.更新後実施日時.実施時間" len="6" type="string"/>
  <item name="伝票情報.更新前実施日時.実施日" len="8" type="string"/>
  <item name="伝票情報.更新前実施日時.実施日実施時間" len="6" type="string"/>
  <item name="伝票情報.終了日時.終了日付" len="8" type="string"/>
  <item name="伝票情報.終了日時.終了日付終了時間" len="6" type="string"/>
  <item name="伝票情報.オーダ作成日.オーダ日付" len="8" col="pat_order_data.vender_1_info.red_date" type="string" append="true"/>
  <item name="伝票情報.オーダ作成日.オーダ時間" len="6" col="pat_order_data.vender_1_info.red_date" type="string" append="true"/>
  <item name="伝票情報.保険パターン番号" len="2" col="pat_coop_detail.vender_1_info.insu_no" type="string"/>
  <item name="伝票情報.入外区分" len="1" type="string"/>
  <item name="伝票情報.診療科コード" len="3" col="pat_unique.medical_care_info.main_course_cd" type="string"/>
  <item name="伝票情報.診療科名称" len="32" type="string"/>
  <item name="伝票情報.病棟コード" len="3" col="pat_unique.medical_care_info.ward_cd" type="string"/>
  <item name="伝票情報.病棟名称" len="32" type="string"/>
  <item name="伝票情報.オーダ発行利用者番号" len="8" type="string"/>
  <item name="伝票情報.オーダ発行利用者名" len="20" type="string"/>
  <item name="伝票情報.依頼医利用者番号" len="8" type="string"/>
  <item name="伝票情報.依頼医名" len="20" type="string"/>
  <item name="伝票情報.伝票種別" len="1" type="string"/>
  <item name="伝票情報.伝票コード" len="4" type="string"/>
  <occ name="明細行数" len="4" detail="ini_dial_meisai"/>
  <item name="終端" len="1" term="true"/>
  <item name="新規変更の区分" len="0"/>
</root>
  ','{"json-key":{"PROCTYPE":{"01":"C","02":"R","03":"D"}}}','1','0','4126','2019/12/13 5:44:54','2019/12/13 5:44:54');
