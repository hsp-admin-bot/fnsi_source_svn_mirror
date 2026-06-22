DELETE FROM mst_coop_layout
WHERE facility_cd = 'F_hA11';

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
) values ('F_hA11','ini_dial','','R','pre','text     ','富士通想定透析初回申し込み','Egmain-GX','テスト用','1','
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
) values ('F_hA11','ini_dial','','R','cre','text     ','富士通想定透析初回申し込み','Egmain-GX','テスト用','1','
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

<item name="削除フラグ" len="0" value="const:0" col="pat_personal_main.is_del" />

  <item name="患者情報.患者番号" len="10" col="pat_personal_main.hosp_pat_id" type="string"/>
  <item name="伝票情報.オーダ番号" len="8" type="string"/>
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
  <item name="伝票情報.オーダ作成日.オーダ日付" len="8" type="string" append="true"/>
  <item name="伝票情報.オーダ作成日.オーダ時間" len="6" type="string" append="true"/>
  <item name="伝票情報.保険パターン番号" len="2" type="string"/>
  <item name="伝票情報.入外区分" len="1" type="string"/>
  <item name="伝票情報.診療科コード" len="3" type="string"/>
  <item name="伝票情報.診療科名称" len="32" type="string"/>
  <item name="伝票情報.病棟コード" len="3" type="string"/>
  <item name="伝票情報.病棟名称" len="32" type="string"/>
  <item name="伝票情報.オーダ発行利用者番号" len="8" type="string"/>
  <item name="伝票情報.オーダ発行利用者名" len="20" type="string"/>
  <item name="伝票情報.依頼医利用者番号" len="8" col="pat_main.charge_staff_info.staff_cd" type="string"/>
  <item name="伝票情報.依頼医名" len="20" col="pat_main.charge_staff_info.staff_name" type="string"/>
  <item name="伝票情報.伝票種別" len="1" type="string"/>
  <item name="伝票情報.伝票コード" len="4" type="string"/>
  <occ name="明細行数" len="4" detail="ini_dial_meisai"/>
  <item name="終端" len="1" term="true"/>
  <item name="新規変更の区分" len="0"/>
</root>
  ','{"json-key":{"PROCTYPE":{"01":"C","02":"R","03":"D"}}}','1','0','4126','2019/12/13 5:44:54','2019/12/13 5:44:54');
