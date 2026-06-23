delete from "mst_coop_layout_detail" where "ctl_no" in (-701000010,-701000009,-701000008,-701000007,-701000006,-701000005,-701000004,-701000003,-701000002,-701000001);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-701000010, 'NEC-iS', 'profile', 'R', '一過性感染症', 'all', 'NEC-iS 患者属性連携', '患者属性連携(受信)', '1', '<TransientInfectionContent ID="">
  <MasterCode>col:$journal.detail.pat_main_2.infect_info.infection_cd</MasterCode>
  <MasterCodeGen></MasterCodeGen>
  <MasterName></MasterName>
  <Result>col:$journal.detail.pat_main_2.infect_info.infect</Result>
  <ResultName></ResultName>
  <CollectionDateTime>col:$journal.detail.pat_main_2.infect_info.exam_date</CollectionDateTime>
</TransientInfectionContent>', '{}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-701000009, 'NEC-iS', 'profile', 'R', '慢性持続感染症', 'all', 'NEC-iS 患者属性連携', '患者属性連携(受信)', '1', '<ChronicConstantInfectionContent ID="">
  <MasterCode>col:$journal.detail.pat_main_2.infect_info.infection_cd</MasterCode>
  <MasterCodeGen></MasterCodeGen>
  <MasterName></MasterName>
  <Result>col:$journal.detail.pat_main_2.infect_info.infect</Result>
  <ResultName></ResultName>
  <CollectionDateTime>col:$journal.detail.pat_main_2.infect_info.exam_date</CollectionDateTime>
</ChronicConstantInfectionContent>', '{}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-701000008, 'NEC-iS', 'profile', 'R', '皮内テスト禁忌', 'all', 'NEC-iS 患者属性連携', '患者属性連携(受信)', '1', '<IntradermalTestContent ID="">
  <Name>col:$journal.detail.pat_main.taboo_allergy_info.content</Name>
  <Result>col:$journal.detail.pat_main.taboo_allergy_info.result</Result>
  <ResultName></ResultName>
  <memo>col:$journal.detail.pat_main.taboo_allergy_info.memo,const:【分類】皮内テスト</memo>
</IntradermalTestContent>', '{}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-701000007, 'NEC-iS', 'profile', 'R', '薬剤禁忌', 'all', 'NEC-iS 患者属性連携', '患者属性連携(受信)', '1', '<ContraindicationMedicineContent ID="">
  <MasterCode>col:$journal.detail.pat_main_1.taboo_allergy_info.taboo_allergy_cd</MasterCode>
  <MasterCodeGen></MasterCodeGen>
  <MasterName>col:$journal.detail.pat_main_1.taboo_allergy_info.content</MasterName>
  <TabooComment></TabooComment>
  <Comment></Comment>
  <memo>col:$journal.detail.pat_main_1.taboo_allergy_info.memo,const:【分類】薬剤禁忌</memo>
</ContraindicationMedicineContent>', '{}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-701000006, 'NEC-iS', 'profile', 'R', '成分禁忌', 'all', 'NEC-iS 患者属性連携', '患者属性連携(受信)', '1', '<ContraindicationIngredientContent ID="">
  <MasterCode></MasterCode>
  <MasterCodeGen></MasterCodeGen>
  <MasterName>col:$journal.detail.pat_main.taboo_allergy_info.content</MasterName>
  <Result>col:$journal.detail.pat_main.taboo_allergy_info.result</Result>
  <ResultName></ResultName>
  <Comment></Comment>
  <memo>col:$journal.detail.pat_main.taboo_allergy_info.memo,const:【分類】成分禁忌</memo>
</ContraindicationIngredientContent>', '{}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-701000005, 'NEC-iS', 'profile', 'R', '食物禁忌', 'all', 'NEC-iS 患者属性連携', '患者属性連携(受信)', '1', '<FoodTabooContent ID="">
  <MasterCode></MasterCode>
  <MasterCodeGen></MasterCodeGen>
  <MasterName>col:$journal.detail.pat_main.taboo_allergy_info.content</MasterName>
  <Result>col:$journal.detail.pat_main.taboo_allergy_info.result,const:1</Result>
  <ResultName></ResultName>
  <Comment></Comment>
  <memo>col:$journal.detail.pat_main.taboo_allergy_info.memo,const:【分類】食物禁忌</memo>
</FoodTabooContent>', '{}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-701000004, 'NEC-iS', 'profile', 'R', '体内金属禁忌', 'all', 'NEC-iS 患者属性連携', '患者属性連携(受信)', '1', '<InBodyMetalContent ID="">
  <MasterCode></MasterCode>
  <MasterCodeGen></MasterCodeGen>
  <MasterName>col:$journal.detail.pat_main.taboo_allergy_info.content</MasterName>
  <Result>col:$journal.detail.pat_main.taboo_allergy_info.result</Result>
  <ResultName></ResultName>
  <Comment></Comment>
  <memo>col:$journal.detail.pat_main.taboo_allergy_info.memo,const:【分類】体内金属</memo>
</InBodyMetalContent>', '{}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-701000003, 'NEC-iS', 'profile', 'R', '造影剤禁忌', 'all', 'NEC-iS 患者属性連携', '患者属性連携(受信)', '1', '<ContrastMediumContraindicationContent ID="">
  <MasterCode></MasterCode>
  <MasterCodeGen></MasterCodeGen>
  <MasterName>col:$journal.detail.pat_main.taboo_allergy_info.content</MasterName>
  <Result>col:$journal.detail.pat_main.taboo_allergy_info.result</Result>
  <ResultName></ResultName>
  <Comment></Comment>
  <memo>col:$journal.detail.pat_main.taboo_allergy_info.memo,const:【分類】造影剤禁忌</memo>
</ContrastMediumContraindicationContent>', '{}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-701000002, 'NEC-iS', 'profile', 'R', 'アレルギー禁忌', 'all', 'NEC-iS 患者属性連携', '患者属性連携(受信)', '1', '<AllergyContent ID="">
  <MasterCode></MasterCode>
  <MasterCodeGen></MasterCodeGen>
  <MasterName>col:$journal.detail.pat_main.taboo_allergy_info.content</MasterName>
  <Result>col:$journal.detail.pat_main.taboo_allergy_info.result</Result>
  <ResultName></ResultName>
  <Comment></Comment>
  <memo>col:$journal.detail.pat_main.taboo_allergy_info.memo,const:【分類】アレルギー</memo>
</AllergyContent>', '{}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-701000001, 'NEC-iS', 'profile', 'R', '患者住所情報', 'all', 'NEC-iS 患者属性連携', '患者属性連携(受信)', '1', '<AddressContent ID="">
  <AddressMasterCode>col:$journal.detail.pat_personal_main.contact_info.kbn</AddressMasterCode>
  <AddressCode></AddressCode>
  <InputAddress1>col:$journal.detail.pat_personal_main.contact_info.address1</InputAddress1>
  <InputAddress2>col:$journal.detail.pat_personal_main.contact_info.address2</InputAddress2>
  <PostatlCode>col:$journal.detail.pat_personal_main.contact_info.zip_cd</PostatlCode>
  <TelephoneNumber>col:$journal.detail.pat_personal_main.contact_info.tel</TelephoneNumber>
</AddressContent>', '{}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
