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
) values ('F_hN00','ini_dial','','R','all','text','富士通想定透析初回申し込み','Egmain-GX','テスト用','1','
<root name="透析初回申し込み">
    <item name="電文種別" len="2" key="電文種別" type="string"/>
    <item name="レコード継続指示" len="1" type="string"/>
    <item name="送信先システムコード" len="2"  type="string"/>
    <item name="発信元システムコード" len="2"  type="string"/>
    <item name="処理情報.処理年月日" len="8"  type="string"/>
    <item name="処理情報.処理時刻" len="6"  type="string"/>
    <item name="端末名" len="8"  type="string"/>
    <item name="利用者番号" len="8"  type="string"/>
    <item name="処理区分" len="2"  type="string" key="shori_kbn"
       col="pat_personal_main.PROCTYPE" value="json;{&quot;01&quot;:&quot;C&quot;,&quot;02&quot;:&quot;R&quot;,&quot;03&quot;:&quot;D&quot;}"/>
    <item name="応答種別" len="2"  type="string"/>
    <item name="電文長" len="6"  type="string"/>
    <item name="エラーコード" len="5"  type="string"/>
    <item name="予備" len="12"  type="string"/>

<item name="姓" len="0" type="string" value="const;あああ" col="pat_personal_main.pat_last_name"/>
<item name="名" len="0" type="string" value="const;いいい" col="pat_personal_main.pat_first_name"/>
<item name="原疾患コード" len="0" type="string" value="const;0001100011" col="pat_personal_main.primary_disease_cd"/>
<item name="ダミー:既往歴" len="0" type="string" value="const;0001100011" col="pat_unique.medical_hst_info.disease_cd" />
<item name="ダミー:既往歴" len="0" type="string" value="const;ABCDE" col="pat_unique.medical_hst_info.foo" />
<item name="ダミー:既往歴" len="0" type="string" value="const;FGHIJ" col="pat_unique.medical_hst_info.bar" />
<item name="ダミー:身体情報" len="0" type="string" value="const;あいうえお" col="pat_unique.physical_info.baz" />
<item name="ダミー:身体情報" len="0" type="string" value="const;20200204" col="pat_unique.physical_info.exam_date" />
<item name="ダミー:患者観察記録情報" len="0" type="string" value="const;11" col="pat_obs_rec.kind_info.kind_no" />
<item name="ダミー:患者観察記録情報" len="0" type="string" value="const;かきくけこ" col="pat_obs_rec.kind_info.kind_name" />
<item name="ダミー:患者観察記録情報" len="0" type="string" value="const;20200210160000" col="pat_obs_rec.kind_info.kind_update" />
<item name="ダミー:患者観察記録情報" len="0" type="string" value="const;11" col="pat_obs_rec.reg_staff_info.reg_staff_cd" />
<item name="ダミー:患者観察記録情報" len="0" type="string" value="const;さしすせそ" col="pat_obs_rec.reg_staff_info.reg_staff_name" />
<item name="ダミー:患者観察記録情報" len="0" type="string" value="const;20200210161000" col="pat_obs_rec.reg_staff_info.reg_staff_update" />
<item name="ダミー:患者観察記録情報" len="0" type="string" value="const;EGMAIN00" col="pat_obs_rec.up_staff_info.up_staff_cd" />
<item name="ダミー:患者観察記録情報" len="0" type="string" value="const;たちつてと" col="pat_obs_rec.up_staff_info.up_staff_name" />
<item name="ダミー:患者観察記録情報" len="0" type="string" value="const;20200210162000" col="pat_obs_rec.up_staff_info.up_staff_update" />

<item name="ダミー:保険情報" len="0" type="string" value="const;ABCDEFGHIJKL" col="pat_insurance.insu_info.insu_no" />
<item name="ダミー:保険情報" len="0" type="string" value="const;ああああ" col="pat_insurance.insu_info.insu_name" />
<item name="ダミー:保険情報" len="0" type="string" value="const;9876543210" col="pat_insurance.insu_info.insu_pat_no" />
<item name="ダミー:保険情報" len="0" type="string" value="const;9876543210" col="pat_insurance.insu_pub_info.insu_pub_no" />
<item name="ダミー:保険情報" len="0" type="string" value="const;24689" col="pat_insurance.insu_set_info.insu_cd" />

<item name="ダミー:患者連携情報" len="0" type="string" value="const;20200210162000" col="pat_coop_detail.save1.key_01" />
<item name="ダミー:患者連携情報" len="0" type="string" value="const;あうあう" col="pat_coop_detail.save1.key_02" />
<item name="ダミー:患者連携情報" len="0" type="string" value="const;walk in来院" col="pat_coop_detail.save6.key_05" />

    <item name="患者情報.患者番号" len="10" type="string"
      col="pat_personal_main.hosp_pat_id" />
    <item name="伝票情報.オーダ番号" len="8" type="string"
      col="pat_order_data.vender_1_info.cop_ord_no1 "/>
    <item name="伝票情報.親文書番号" len="30" type="string"
      col="pat_order_data.vender_1_info.cop_ord_no2" />
    <item name="伝票情報.文書番号" len="30" type="string"
      col="pat_order_data.vender_1_info.cop_ord_no3" />
    <item name="伝票情報.文書版数" len="2" type="string"/>
    <item name="伝票情報.関連オーダ番号" len="8" type="string"/>
    <item name="伝票情報.実施番号" len="8" type="string"/>
    <item name="伝票情報.更新後実施日時.実施日" len="8" type="string"/>
    <item name="伝票情報.更新後実施日時.実施時間" len="6" type="string"/>
    <item name="伝票情報.更新前実施日時.実施日" len="8" type="string"/>
    <item name="伝票情報.更新前実施日時.実施日実施時間" len="6" type="string"/>
    <item name="伝票情報.終了日時.終了日付" len="8" type="string"/>
    <item name="伝票情報.終了日時.終了日付終了時間" len="6" type="string"/>
    <item name="伝票情報.オーダ作成日.オーダ日付" len="8" type="string"
      col="pat_order_data.vender_1_info.red_date" append="true" />
    <item name="伝票情報.オーダ作成日.オーダ時間" len="6" type="string"
      col="pat_order_data.vender_1_info.red_date" append="true" />
    <item name="伝票情報.保険パターン番号" len="2" type="string"
      col="pat_coop_detail.vender_1_info.insu_no" />
    <item name="伝票情報.入外区分" len="1" type="string"/>
    <item name="伝票情報.診療科コード" len="3" type="string"
      col="pat_unique.medical_care_info.main_course_cd" />
    <item name="伝票情報.診療科名称" len="32" type="string"/>
    <item name="伝票情報.病棟コード" len="3" type="string"
      col="pat_unique.medical_care_info.ward_cd" />
    <item name="伝票情報.病棟名称" len="32" type="string"/>
    <item name="伝票情報.オーダ発行利用者番号" len="8" type="string"/>
    <item name="伝票情報.オーダ発行利用者名" len="20" type="string"/>
    <item name="伝票情報.依頼医利用者番号" len="8" type="string"
      col="pat_main.charge_staff_info.staff_cd" />
    <item name="伝票情報.依頼医名" len="20" type="string"/>
    <item name="伝票情報.伝票種別" len="1" type="string"/>
    <item name="伝票情報.伝票コード" len="4" type="string"/>
    <occ name="明細行数" len="4" detail="ini_dial_meisai"/>
    <item name="終端" len="1" term="true"/>
    <item name="新規変更の区分" len="0"/>
</root>
','{"key": {"電文種別" : {"VI" : "ini_dial"}, "shori_kbn": {"01":"cre"}}}','1','0','4126','2019/12/13 5:44:54','2019/12/13 5:44:54');
