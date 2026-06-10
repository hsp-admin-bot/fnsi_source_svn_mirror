DELETE FROM mst_coop_layout
WHERE facility_cd = 'F_h002';

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
) values ('F_h002','ini_dial','','R','pre','text     ','富士通想定透析初回申し込み','Egmain-GX','テスト用','1','
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
) values ('F_h002','ini_dial','','R','cre','text     ','富士通想定透析初回申し込み','Egmain-GX','テスト用','1','
<root name="透析初回申し込み">
  <item name="電文種別" len="2" type="string"/>
  <item name="レコード継続指示" len="1" type="string"/>
  <item name="送信先システムコード" len="2" type="string"/>
  <item name="発信元システムコード" len="2" type="string"/>
  <item name="処理情報.処理年月日" len="8" type="string"/>
  <item name="処理情報.処理時刻" len="6" type="string"/>
  <item name="端末名" len="8" type="string"/>
  <item name="利用者番号" len="8" type="string"/>
  <item name="処理区分" len="2" />

<item name="姓" len="0" type="string" value="const:あああ" col="pat_personal_main.pat_last_name"/>
<item name="名" len="0" type="string" value="const:いいい" col="pat_personal_main.pat_first_name"/>

<item name="患者情報.患者番号" len="0" col="pat_personal_main.hosp_pat_id" type="string" value="const:1111111112"/>
<item len="0" col="pat_personal_main.is_del" value="const:0" />

</root>
  ','{}','1','0','4126','2019/12/13 5:44:54','2019/12/13 5:44:54');
