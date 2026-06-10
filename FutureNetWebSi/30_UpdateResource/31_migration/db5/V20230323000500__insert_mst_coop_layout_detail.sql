DELETE FROM "ntss"."mst_coop_layout_detail" WHERE ctl_no IN (12859);
INSERT INTO "ntss"."mst_coop_layout_detail" ("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (12859, 'F_hosp', 'pre_ord', 'R', '処方情報詳細', 'all', '処方情報受信', '処方情報受信', '1', '<root name="処方明細">
  <item name="項目コード" len="8" type="string" col="$journal.detail.ord_prescription.prescription_detail.code"/>
  <item name="項目属性" len="3" type="string" col="$journal.detail.ord_prescription.prescription_detail.attr"/>
  <item name="項目名称" len="50" type="string" col="$journal.detail.ord_prescription.prescription_detail.name"/>
  <item name="数量" len="11" type="string" col="$journal.detail.ord_prescription.prescription_detail.quantity"/>
  <item name="選択単位フラグ" len="1" type="string" col="$journal.detail.ord_prescription.prescription_detail.unit_flg"/>
  <item name="選択単位コード" len="3" type="string" col="$journal.detail.ord_prescription.prescription_detail.unit_code"/>
  <item name="選択単位名称" len="4" type="string" col="$journal.detail.ord_prescription.prescription_detail.unit_name"/>
  <item name="第２単位コード" len="3" type="string" col="$journal.detail.ord_prescription.prescription_detail.unit2_code"/>
  <item name="第２単位名称" len="4" type="string" col="$journal.detail.ord_prescription.prescription_detail.unit2_name"/>
  <item name="極量フラグ" len="1" type="string" col="$journal.detail.ord_prescription.prescription_detail.extremeQuantity_flg"/>
  <item name="項目行日" len="8" type="string"/>
  <item name="項目行時間" len="6" type="string"/>
  <item name="付帯コード" len="20" type="string"/>
</root>', '{}', '1', '0', 4126, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
