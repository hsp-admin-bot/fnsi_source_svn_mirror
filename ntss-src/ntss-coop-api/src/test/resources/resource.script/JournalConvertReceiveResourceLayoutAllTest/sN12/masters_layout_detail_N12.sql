DELETE FROM mst_coop_layout_detail;

insert into ntss.mst_coop_layout_detail(
  facility_cd
  , coop_cd
  , direction
  , coop_cd_detail
  , coop_cd_detail_sub
  , coop_name
  , description
  , is_editable
  , coop_setting
  , coop_ext_setting
  , is_disp
  , is_del
  , user_id
  , reg_date
  , up_date
)  values ('F_hN12','ini_dial','R','キシロカインアレルギー','all','富士通想定透析初回申込-申込詳細','For test','1','
<root name="キシロカインアレルギー">
  <item name="明細.項目コード" len="1" type="string"
    col="pat_main.taboo_allergy_info.taboo_allergy_cd" value="json:allergy_cd" />
  <item name="アレルギークラス" len="0" type="string"
    col="pat_main.taboo_allergy_info.taboo_allergy_class" value="const:2" />
  <item name="アレルギー補足" len="0" type="string"
    col="pat_main.taboo_allergy_info.category_class" value="const:0" />
</root>
','{"json-key": {"allergy_cd": {"1":"LID", "_DEFAULT":""}}}',
'1','0','4126','2019/12/13 6:16:24','2019/12/13 6:16:24');

insert into ntss.mst_coop_layout_detail(
  facility_cd
  , coop_cd
  , direction
  , coop_cd_detail
  , coop_cd_detail_sub
  , coop_name
  , description
  , is_editable
  , coop_setting
  , coop_ext_setting
  , is_disp
  , is_del
  , user_id
  , reg_date
  , up_date
)  values ('F_hN12','ini_dial','R','ヨードアレルギー','all','富士通想定透析初回申込-申込詳細','For test','1','
<root name="ヨードアレルギー">
  <item name="明細.項目コード" len="1" type="string"
    col="pat_main.taboo_allergy_info.taboo_allergy_cd" value="json:allergy_cd" />
  <item name="アレルギークラス" len="0" type="string"
    col="pat_main.taboo_allergy_info.taboo_allergy_class" value="const:2" />
  <item name="アレルギー補足" len="0" type="string"
    col="pat_main.taboo_allergy_info.category_class" value="const:1" />
</root>
','{"json-key": {"allergy_cd": {"1":"IOD", "_DEFAULT":""}}}',
'1','0','4126','2019/12/13 6:16:24','2019/12/13 6:16:24');

insert into ntss.mst_coop_layout_detail(
  facility_cd
  , coop_cd
  , direction
  , coop_cd_detail
  , coop_cd_detail_sub
  , coop_name
  , description
  , is_editable
  , coop_setting
  , coop_ext_setting
  , is_disp
  , is_del
  , user_id
  , reg_date
  , up_date
)  values ('F_hN12','ini_dial','R','感染:HBs','all','富士通想定透析初回申込-申込詳細','For test','1','
<root name="感染:HBs">
  <item name="感染症コード" len="1" type="string"
    col="pat_main.infect_info.infect" value="json:infection_key" />
  <item name="感染症コード" len="0" type="string" value="const:311"
    col="pat_main.infect_info.infection_cd" />
</root>
','{"json-key": {"infection_key": { "?":"0", "+":"2", "-": "1", "_DEFAULT": ""}}}',
'1','0','4126','2019/12/13 6:16:24','2019/12/13 6:16:24');

insert into ntss.mst_coop_layout_detail(
  facility_cd
  , coop_cd
  , direction
  , coop_cd_detail
  , coop_cd_detail_sub
  , coop_name
  , description
  , is_editable
  , coop_setting
  , coop_ext_setting
  , is_disp
  , is_del
  , user_id
  , reg_date
  , up_date
)  values ('F_hN12','ini_dial','R','感染:HBe','all','富士通想定透析初回申込-申込詳細','For test','1','
<root name="感染:HBe">
  <item name="感染症コード" len="1" type="string"
    col="pat_main.infect_info.infect" value="json:infection_key" />
  <item name="感染症コード" len="0" type="string" value="const:312"
    col="pat_main.infect_info.infection_cd" />
</root>
','{"json-key": {"infection_key": { "?":"0", "+":"2", "-": "1", "_DEFAULT": ""}}}',
'1','0','4126','2019/12/13 6:16:24','2019/12/13 6:16:24');
