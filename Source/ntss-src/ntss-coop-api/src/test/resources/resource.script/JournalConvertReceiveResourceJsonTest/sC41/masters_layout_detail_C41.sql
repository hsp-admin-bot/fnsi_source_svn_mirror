DELETE FROM mst_coop_layout_detail
WHERE facility_cd = 'F_hC41';

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
)  values ('F_hC41','ini_dial','R','ini_dial_meisai','pre','富士通想定透析初回申込-申込詳細','For test','1','
<root name="透析申込詳細">
    <item name="明細.項目コード" len="8"/>
    <item name="明細.項目属性" len="3" key="shori_kbn"/>
    <item name="明細.項目名称" len="50"/>
    <item name="明細.数量" len="11"/>
    <item name="明細.選択単位フラグ" len="1"/>
    <item name="明細.単位コード" len="3"/>
    <item name="明細.単位名称" len="4"/>
    <item name="明細.第２単位コード" len="3"/>
    <item name="明細.第２単位名称" len="4"/>
    <item name="明細.単位換算量" len="11"/>

</root>
  ','{"key": {"shori_kbn": {"VA2":"VA2", "VA3":"VA3", "VA4":"VA4", "VA5":"VA5", "VA6":"VA6", "VA7":"VA7", "VA8":"VA8", "VD1":"VD1", "VAB": "障害者加算", "VB1": "原疾患", "VC1": "治療方法", "VF3": "明細", "XXX": "コメント"}}}',
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
)  values ('F_hC41','ini_dial','R','ini_dial_meisai','原疾患','富士通想定透析初回申込-申込詳細','For test','1','
<root name="透析申込詳細">"
<item name="明細.項目コード" len="8" col="pat_unique.medical_hst_info.disease_cd" type="string"/>
<item name="明細.項目属性" len="3" type="string"/>
<item name="明細.項目名称" len="50" type="string"/>
<item name="明細.数量" len="11" type="string"/>
<item name="明細.選択単位フラグ" len="1" type="string"/>
<item name="明細.単位コード" len="3" type="string"/>
<item name="明細.単位名称" len="4" type="string"/>
<item name="明細.第２単位コード" len="3" type="string"/>
<item name="明細.第２単位名称" len="4" type="string"/>
<item name="明細.単位換算量" len="11" type="string"/>

</root>
  ','{}','1','0','4126','2019/12/13 9:30:47','2019/12/13 9:30:47');
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
)  values ('F_hC41','ini_dial','R','ini_dial_meisai','障害者加算','富士通想定透析初回申込-申込詳細','For test','1','
<root name="透析申込詳細">"
<item name="明細.項目コード" len="8" col="pat_personal_main.dial_diff_com_info.dial_diff_com_info" type="string"/>
<item name="明細.項目属性" len="3" type="string"/>
<item name="明細.項目名称" len="50" type="string"/>
<item name="明細.数量" len="11" type="string"/>
<item name="明細.選択単位フラグ" len="1" type="string"/>
<item name="明細.単位コード" len="3" type="string"/>
<item name="明細.単位名称" len="4" type="string"/>
<item name="明細.第２単位コード" len="3" type="string"/>
<item name="明細.第２単位名称" len="4" type="string"/>
<item name="明細.単位換算量" len="11" type="string"/>
</root>

  ','{}','1','0','4126','2019/12/13 9:31:33','2019/12/13 9:31:33');
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
)  values ('F_hC41','ini_dial','R','ini_dial_meisai','コメント','富士通想定透析初回申込-申込詳細','For test','1','
<root name="透析申込詳細">
<item name="明細.項目コード" len="8" type="string"/>
<item name="明細.項目属性" len="3" type="string"/>
<item name="明細.項目名称" len="50" type="string"/>
<item name="明細.数量" len="11" type="string"/>
<item name="明細.選択単位フラグ" len="1" type="string"/>
<item name="明細.単位コード" len="3" type="string"/>
<item name="明細.単位名称" len="4" type="string"/>
<item name="明細.第２単位コード" len="3" type="string"/>
<item name="明細.第２単位名称" len="4" type="string"/>
<item name="明細.単位換算量" len="11" type="string"/>
</root>

  ','{}','1','0','4126','2019/12/13 9:32:15','2019/12/13 9:32:15');
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
)  values ('F_hC41','ini_dial','R','ini_dial_meisai','治療方法','富士通想定透析初回申込-申込詳細','For test','1','
<root name="透析申込詳細">"
<item name="明細.項目コード" len="8" col="pat_order_data.vender_1_info.treat_cd" type="string"/>
<item name="明細.項目属性" len="3" type="string"/>
<item name="明細.項目名称" len="50" col="pat_order_data.vender_1_info.treat_name" type="string"/>
<item name="明細.数量" len="11" type="string"/>
<item name="明細.選択単位フラグ" len="1" type="string"/>
<item name="明細.単位コード" len="3" type="string"/>
<item name="明細.単位名称" len="4" type="string"/>
<item name="明細.第２単位コード" len="3" type="string"/>
<item name="明細.第２単位名称" len="4" type="string"/>
<item name="明細.単位換算量" len="11" type="string"/>
</root>

  ','{}','1','0','4126','2019/12/13 9:32:52','2019/12/13 9:32:52');
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
)  values ('F_hC41','ini_dial','R','ini_dial_meisai','明細','富士通想定透析初回申込-申込詳細','For test','1','
<root name="透析申込詳細">
<item name="明細.項目コード" len="8" col="pat_order_data.vender_1_info.treat_cd" type="string"/>
<item name="明細.項目属性" len="3" type="string"/>
<item name="明細.項目名称" len="50" col="pat_order_data.vender_1_info.treat_name" type="string"/>
<item name="明細.数量" len="11" type="string"/>
<item name="明細.選択単位フラグ" len="1" type="string"/>
<item name="明細.単位コード" len="3" type="string"/>
<item name="明細.単位名称" len="4" type="string"/>
<item name="明細.第２単位コード" len="3" type="string"/>
<item name="明細.第２単位名称" len="4" type="string"/>
<item name="明細.単位換算量" len="11" type="string"/>
</root>
  ','{}','1','0','4126','2019/12/13 9:34:15','2019/12/13 9:34:15');
