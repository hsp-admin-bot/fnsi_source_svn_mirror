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
)  values ('F_hN10','ini_dial','R','ini_dial_meisai','pre','富士通想定透析初回申込-申込詳細','For test','1','
<root name="アレルギー">
    <item name="明細.項目コード" len="8" type="string" />
    <item name="明細.項目属性" len="2" key="shori_kbn" />
</root>
','{"key": {"shori_kbn": {"01":"富士通", "02":"NEC", "03":"パナソニック"}}}',
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
)  values ('F_hN10','ini_dial','R','ini_dial_meisai','富士通','富士通想定透析初回申込-申込詳細','For test','1','
<root name="透析申込詳細">
    <item name="明細.項目コード" len="8" type="string"
      col="pat_main.taboo_allergy_info.taboo_allergy_cd" />
    <item name="アレルギークラス" len="0" type="string"
      col="pat_main.taboo_allergy_info.taboo_allergy_class" value="const;00" />
    <item name="アレルギー補足" len="0" type="string"
      col="pat_main.taboo_allergy_info.taboo_allergy_aux_Fujitsu" value="const;51" />
    <item name="明細.項目属性" len="2" key="shori_kbn" />
</root>
','{}',
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
)  values ('F_hN10','ini_dial','R','ini_dial_meisai','NEC','富士通想定透析初回申込-申込詳細','For test','1','
<root name="透析申込詳細">
    <item name="明細.項目コード" len="8" type="string"
      col="pat_main.taboo_allergy_info.taboo_allergy_cd" />
    <item name="アレルギークラス" len="0" type="string"
      col="pat_main.taboo_allergy_info.taboo_allergy_class" value="const;01" />
    <item name="アレルギー補足" len="0" type="string"
      col="pat_main.taboo_allergy_info.taboo_allergy_aux_NEC" value="const;52" />
    <item name="明細.項目属性" len="2" key="shori_kbn" />
</root>
','{}',
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
)  values ('F_hN10','ini_dial','R','ini_dial_meisai','パナソニック','富士通想定透析初回申込-申込詳細','For test','1','
<root name="透析申込詳細">
    <item name="明細.項目コード" len="8" type="string"
      col="pat_main.taboo_allergy_info.taboo_allergy_cd" />
    <item name="アレルギークラス" len="0" type="string"
      col="pat_main.taboo_allergy_info.taboo_allergy_class" value="const;02" />
    <item name="アレルギー補足" len="0" type="string"
      col="pat_main.taboo_allergy_info.taboo_allergy_aux_Panasonic" value="const;53" />
    <item name="明細.項目属性" len="2" key="shori_kbn" />
</root>
','{}',
'1','0','4126','2019/12/13 6:16:24','2019/12/13 6:16:24');