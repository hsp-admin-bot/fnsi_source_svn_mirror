DELETE FROM mst_coop_layout_detail
WHERE facility_cd = 'XML010';

insert into ntss.mst_coop_layout_detail(
  ctl_no
  , facility_cd
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
)  values (10000100,'XML010','ini_dial','R','ini_dial_meisai','pre','富士通想定透析初回申込-申込詳細','For test','1','
<root name="透析申込詳細">
  <element name="SsiData" attr="Type" value="PAT_INF">
    <element name="Occ1">
      <element name="TreatmentDiv">
        <item name="処理区分" key="shori_kbn" />
      </element>
    </element>
  </element>
</root>
  ','{"key": {"shori_kbn": {"VA2":"VA2", "VA3":"VA3", "VA4":"VA4", "VA5":"VA5", "VA6":"VA6", "VA7":"VA7", "VA8":"VA8", "VD1":"VD1", "VAB": "障害者加算", "VB1": "原疾患", "VC1": "治療方法", "VF3": "明細", "XXX": "コメント"}}}',
  '1','0','4126','2019/12/13 6:16:24','2019/12/13 6:16:24');

  insert into ntss.mst_coop_layout_detail(
  ctl_no
  , facility_cd
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
)  values (10000101,'XML010','ini_dial','R','ini_dial_meisai','VA2','富士通想定透析初回申込-申込詳細','For test','1','
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
  ','{}',
  '1','0','4126','2019/12/13 6:16:24','2019/12/13 6:16:24');
