DELETE FROM mst_coop_layout
WHERE facility_cd = 'F_hM00';

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
) values ('F_hM00','ini_dial','','R','pre','text     ','富士通想定透析初回申し込み','Egmain-GX','テスト用','1','
<root name="透析初回申し込み" multi="true:CR">
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
) values ('F_hM00','ini_dial','','R','cre','text     ','富士通想定透析初回申し込み','Egmain-GX','テスト用','1','
<root name="透析初回申し込み">
  <item name="電文種別" len="2" type="string"/>
  <item name="レコード継続指示" len="1" type="string"/>
  <item name="送信先システムコード" len="2" type="string"/>
  <item name="発信元システムコード" len="2" type="string"/>
  <item name="処理情報.処理年月日" len="8" type="string"/>
  <item name="処理情報.処理時刻" len="6" type="string"/>
  <item name="端末名" len="8" type="string"/>
  <item name="利用者番号" len="8" type="string"/>
  <item name="処理区分" len="2" col="pat_personal_main.PROCTYPE" type="string" value="json:proc_type"/>
  <item name="応答種別" len="2" type="string"/>
  <item name="電文長" len="6" type="string"/>
  <item name="エラーコード" len="5" type="string"/>
  <item name="予備" len="12" type="string"/>
<item name="姓" len="0" type="string" value="const:あああ" col="pat_personal_main.pat_last_name"/>
<item name="名" len="0" type="string" value="const:いいい" col="pat_personal_main.pat_first_name"/>

<occ repeat="1">
  <item name="ダミーdial_diff_com_info" col="pat_personal_main.dial_diff_com_info.ctl_no" len="0" value="const:1" />
  <item name="ダミーdial_diff_com_info" col="pat_personal_main.dial_diff_com_info.dial_diff_com_info" len="0" value="const:VAB004" />
  <item name="ダミーdial_diff_com_info" col="pat_personal_main.dial_diff_com_info.is_main" len="0" value="const:1" />
</occ>

<occ repeat="1">
  <item name="ダミーpat_contact_info" col="pat_personal_main.pat_contact_info.zip_cd" len="0" value="const:001-0001" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.pat_contact_info.address" len="0" value="const:東京都千代田区" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.pat_contact_info.tel1" len="0" value="const:03-0000-0000" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.pat_contact_info.tel2" len="0" value="const:03-1111-1111" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.pat_contact_info.fax" len="0" value="const:03-5555-5555" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.pat_contact_info.email" len="0" value="const:test@example.com" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.pat_contact_info.work_name" len="0" value="const:国防省" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.pat_contact_info.work_tel" len="0" value="const:03-9999-9999" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.pat_contact_info.memo1" len="0" value="const:メモその1" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.pat_contact_info.memo2" len="0" value="const:メモその2" />
</occ>

<occ repeat="1">
  <item name="ダミーpat_contact_info" col="pat_personal_main.other_contact_info.ctl_no" len="0" value="const:3" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.other_contact_info.disp_order" len="0" value="const:3" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.other_contact_info.is_key_person" len="0" value="const:0" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.other_contact_info.pat_id" len="0" value="const:132435" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.other_contact_info.last_name" len="0" value="const:へのへの" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.other_contact_info.first_name" len="0" value="const:もへじ" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.other_contact_info.last_name_kana" len="0" value="const:ﾍﾉﾍﾉ" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.other_contact_info.first_name_kana" len="0" value="const:ﾓﾍｼﾞ" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.other_contact_info.relation_cd" len="0" value="const:5" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.other_contact_info.relation_name" len="0" value="const:兄弟姉妹" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.other_contact_info.zip_cd" len="0" value="const:987-9876" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.other_contact_info.address" len="0" value="const:鹿児島県" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.other_contact_info.tel1" len="0" value="const:099-9876-4321" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.other_contact_info.tel2" len="0" value="const:099-8642-1357" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.other_contact_info.fax" len="0" value="const:099-7766-2211" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.other_contact_info.e_mail" len="0" value="const:test999@example.com" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.other_contact_info.work_name" len="0" value="const:第拾伍東京市農水省" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.other_contact_info.work_tel" len="0" value="const:099-9898-7676" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.other_contact_info.memo1" len="0" value="const:メモメモメモ1" />
  <item name="ダミーpat_contact_info" col="pat_personal_main.other_contact_info.memo2" len="0" value="const:メモメモメモ2" />
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
  <item name="伝票情報.依頼医利用者番号" len="8" col="pat_main.charge_staff_info.staff_cd" type="string"/>
  <item name="伝票情報.依頼医名" len="20" type="string"/>
  <item name="伝票情報.伝票種別" len="1" type="string"/>
  <item name="伝票情報.伝票コード" len="4" type="string"/>
  <occ name="明細行数" len="4" detail="ini_dial_meisai"/>
  <item name="新規変更の区分" len="0"/>
</root>
  ','{"json-key": {"proc_type":{"01":"C", "02":"U", "03":"D"}}}','1','0','4126','2019/12/13 5:44:54','2019/12/13 5:44:54');
