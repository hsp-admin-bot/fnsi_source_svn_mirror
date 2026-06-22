DELETE FROM mst_coop_layout
WHERE ctl_no > 0;

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
) values ('F_hN10','ini_dial','','R','all','text','富士通想定透析初回申し込み','Egmain-GX','テスト用','1','
<root name="透析初回申し込み">
  <item name="電文種別" len="2" key="shori_kbn" />
  <item name="患者情報.患者番号" len="10" type="string"
    col="pat_personal_main.hosp_pat_id" />
  <occ repeat="1" detail="ini_dial_meisai" />
</root>
','{"key": {"電文種別" : {"VI" : "ini_dial"}, "shori_kbn": {"01":"cre"}}}','1','0','4126','2019/12/13 5:44:54','2019/12/13 5:44:54');
