DELETE FROM mst_coop_layout
WHERE facility_cd = 'F_hC10';

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
) values ('F_hC10','ini_dial','','R','pre','text     ','富士通想定透析初回申し込み','Egmain-GX','テスト用','1','
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
) values ('F_hC10','ini_dial','','R','cre','text     ','富士通想定透析初回申し込み','Egmain-GX','テスト用','1','
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

<occ repeat="1">
  <item name="ダミーpat_main" len="0" col="pat_main.pat_memo_info.title" value="const:content11" />
  <item name="ダミーpat_main" len="0" col="pat_main.pat_memo_info.content" value="const:content_content" />
</occ>

<occ repeat="1">
  <item name="ダミーpat_main" len="0" col="pat_main.charge_staff_info.ctl_no" value="const:11" />
  <item name="ダミーpat_main" len="0" col="pat_main.charge_staff_info.disp_order" value="const:12" />
  <item name="ダミーpat_main" len="0" col="pat_main.charge_staff_info.staff_cd" value="const:EGMAIN00" />
  <item name="ダミーpat_main" len="0" col="pat_main.charge_staff_info.is_main" value="const:1" />
  <item name="ダミーpat_main" len="0" col="pat_main.charge_staff_info.is_charge" value="const:0" />
  <item name="ダミーpat_main" len="0" col="pat_main.charge_staff_info.is_puncture" value="const:1" />
</occ>

<occ repeat="1">
  <item name="ダミーpat_main" len="0" col="pat_main.taboo_allergy_info.ctl_no" value="const:101" />
  <item name="ダミーpat_main" len="0" col="pat_main.taboo_allergy_info.disp_order" value="const:102" />
  <item name="ダミーpat_main" len="0" col="pat_main.taboo_allergy_info.content" value="const:アレルギー" />
  <item name="ダミーpat_main" len="0" col="pat_main.taboo_allergy_info.memo" value="const:バラ科果実全般禁忌" />
  <item name="ダミーpat_main" len="0" col="pat_main.taboo_allergy_info.category_class" value="const:0" />
  <item name="ダミーpat_main" len="0" col="pat_main.taboo_allergy_info.taboo_allergy_class" value="const:1" />
  <item name="ダミーpat_main" len="0" col="pat_main.taboo_allergy_info.taboo_allergy_cd" value="const:1" />
</occ>

<occ repeat="1">
  <item name="ダミーpat_main" len="0" col="pat_main.infect_info.ctl_no" value="const:111" />
  <item name="ダミーpat_main" len="0" col="pat_main.infect_info.infection_cd" value="const:112" />
  <item name="ダミーpat_main" len="0" col="pat_main.infect_info.infect" value="const:1" />
  <item name="ダミーpat_main" len="0" col="pat_main.infect_info.exam_date" value="const:2020-04-09" />
  <item name="ダミーpat_main" len="0" col="pat_main.infect_info.up_date" value="const:2020-04-09" />
</occ>

<occ repeat="1">
  <item name="ダミーpat_main" len="0" col="pat_main.implant_info.ctl_no" value="const:121" />
  <item name="ダミーpat_main" len="0" col="pat_main.implant_info.disp_order" value="const:122" />
  <item name="ダミーpat_main" len="0" col="pat_main.implant_info.implant_cd" value="const:201" />
  <item name="ダミーpat_main" len="0" col="pat_main.implant_info.reg_date" value="const:2020-01-10" />
  <item name="ダミーpat_main" len="0" col="pat_main.implant_info.remove_date" value="const:9999-12-31" />
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
