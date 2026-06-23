delete from "mst_coop_layout_detail" where "facility_cd" = 'nkknkk' and "coop_cd" = 'profile';
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-103000013, 'nkknkk', 'profile', 'R', '担当スタッフ情報', 'all', '日機装標準', '患者情報（XML)', '1', '<Nurse info="担当スタッフ" Code="col:$journal.detail.pat_main.charge_staff_info.staff_cd"  IsMain="col:$journal.detail.pat_main.charge_staff_info.is_main,const:0" IsCharge="col:$journal.detail.pat_main.charge_staff_info.is_charge,const:1"></Nurse>', '{}', '1', '0', 4, '2020-05-21 18:36:58.999', '2020-05-21 18:37:02.649');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-103000012, 'nkknkk', 'profile', 'R', '担当医情報', 'all', '日機装標準', '患者情報（XML)', '1', '<Doctor info="担当医" Code="col:$journal.detail.pat_main.charge_staff_info.staff_cd" IsMain="col:$journal.detail.pat_main.charge_staff_info.is_main,const:1" IsCharge="col:$journal.detail.pat_main.charge_staff_info.is_charge,const:0"></Doctor>', '{}', '1', '0', 4, '2020-05-21 18:36:58.999', '2020-05-21 18:37:02.649');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-103000011, 'nkknkk', 'profile', 'R', '詳細項目', '感染症', '日機装標準', '患者情報（XML)', '1', '<DetailInfo Function="1" SEQ="" info="感染症">
  <Item Code="col:$journal.detail.pat_main_2.infect_info.infection_cd"></Item>
  <Contents>col:$journal.detail.pat_main_2.infect_info.infect</Contents>
  <Date>col:$journal.detail.pat_main_2.infect_info.exam_date</Date>
</DetailInfo>', '{}', '1', '0', 4, '2020-05-21 18:36:58.999', '2020-05-21 18:37:02.649');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-103000010, 'nkknkk', 'profile', 'R', '詳細項目', '原疾患', '日機装標準', '患者情報（XML)', '1', '<DetailInfo Function="2" SEQ="" info="原疾患">
  <Item Code="col:$journal.detail.pat_unique_1.medical_hst_info.disease_cd"></Item>
  <Contents></Contents>
  <Date>col:$journal.detail.pat_unique_1.medical_hst_info.disease_date</Date>
</DetailInfo>', '{}', '1', '0', 4, '2020-05-21 18:36:58.999', '2020-05-21 18:37:02.649');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-103000009, 'nkknkk', 'profile', 'R', '詳細項目', 'アレルギー', '日機装標準', '患者情報（XML)', '1', '<DetailInfo Function="3,4,5,6,7" SEQ="" info="アレルギー">
  <Item Code="col:$journal.detail.pat_main_4.taboo_allergy_info.taboo_allergy_cd">col:$journal.detail.pat_main_4.taboo_allergy_info.content</Item>
  <Contents>col:$journal.detail.pat_main_4.taboo_allergy_info.memo</Contents>
  <Date></Date>
</DetailInfo>', '{}', '1', '0', 4, '2020-05-21 18:36:58.999', '2020-05-21 18:37:02.649');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-103000008, 'nkknkk', 'profile', 'R', '詳細項目', 'インプラント', '日機装標準', '患者情報（XML)', '1', '<DetailInfo Function="8" SEQ="" info="インプラント">
  <Item Code="col:$journal.detail.pat_main_1.implant_info.implant_cd"></Item>
  <Contents></Contents>
  <Date>col:$journal.detail.pat_main_1.implant_info.reg_date</Date>
</DetailInfo>', '{}', '1', '0', 4, '2020-05-21 18:36:58.999', '2020-05-21 18:37:02.649');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-103000007, 'nkknkk', 'profile', 'R', '詳細項目', '障害者加算', '日機装標準', '患者情報（XML)', '1', '<DetailInfo Function="9" SEQ="" info="障害者加算">
  <Item Code="col:$journal.detail.pat_personal_main_1.dial_diff_com_info.dial_diff_cd"></Item>
  <Contents></Contents>
  <Date>col:$journal.detail.pat_personal_main_1.dial_diff_com_info.reg_date</Date>
</DetailInfo>', '{}', '1', '0', 4, '2020-05-21 18:36:58.999', '2020-05-21 18:37:02.649');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-103000006, 'nkknkk', 'profile', 'R', '詳細項目', '患者メモ', '日機装標準', '患者情報（XML)', '1', '<DetailInfo Function="10" SEQ="" info="患者メモ">
  <Item Code="">col:$journal.detail.pat_main_3.pat_memo_info.title</Item>
  <Contents>col:$journal.detail.pat_main_3.pat_memo_info.content</Contents>
  <Date></Date>
</DetailInfo>', '{}', '1', '0', 4, '2020-05-21 18:36:58.999', '2020-05-21 18:37:02.649');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-103000005, 'nkknkk', 'profile', 'R', '詳細項目', '患者フリーコメント', '日機装標準', '患者情報（XML)', '1', '<DetailInfo Function="11" SEQ="" info="患者フリーコメント">
  <Item Code="">col:$journal.detail.pat_main_3.pat_memo_info.title</Item>
  <Contents>col:$journal.detail.pat_main_3.pat_memo_info.content</Contents>
  <Date></Date>
</DetailInfo>', '{}', '1', '0', 4, '2020-05-21 18:36:58.999', '2020-05-21 18:37:02.649');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-103000004, 'nkknkk', 'profile', 'R', '詳細項目', '生存情報', '日機装標準', '患者情報（XML)', '1', '<DetailInfo Function="12" SEQ="" info="生存情報">
  <Item Code=""></Item>
  <Contents>col:$journal.pat_personal_main.is_die</Contents>
  <Date>col:$journal.pat_personal_main.die_date</Date>
</DetailInfo>', '{}', '1', '0', 4, '2020-05-21 18:36:58.999', '2020-05-21 18:37:02.649');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-103000003, 'nkknkk', 'profile', 'R', '詳細項目', '搬送区分', '日機装標準', '患者情報（XML)', '1', '<DetailInfo Function="13" SEQ="" info="搬送区分">
  <!-- テストデータの電文内容が「IntensiveCare」です。int型ではなく、一時的に削除します。 -->
  <!-- Item Code="col:$journal.pat_personal_main.transport_cd"-->
  <Item Code=""></Item>
  <Contents></Contents>
  <Date></Date>
</DetailInfo>', '{}', '1', '0', 4, '2020-05-21 18:36:58.999', '2020-05-21 18:37:02.649');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-103000002, 'nkknkk', 'profile', 'R', '詳細項目', '重症度', '日機装標準', '患者情報（XML)', '1', '<DetailInfo Function="14" SEQ="" info="重症度">
  <!-- テストデータの電文内容が「InRoom」です。int型ではなく、一時的に削除します。 -->
  <!-- Item Code="col:$journal.pat_personal_main.severity_cd"-->
  <Item Code=""></Item>
  <Contents></Contents>
  <Date></Date>
</DetailInfo>', '{}', '1', '0', 4, '2020-05-21 18:36:58.999', '2020-05-21 18:37:02.649');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-103000001, 'nkknkk', 'profile', 'R', '住所詳細', 'all', '日機装標準', '患者情報（XML)', '1', '<Contact SEQ="col:$journal.detail.pat_personal_main.other_contact_info.ctl_no">
  <Name RelationShip="col:$journal.detail.pat_personal_main.other_contact_info.relation_name">col:$journal.detail.pat_personal_main.other_contact_info.last_name</Name>
  <Address ZipCode="col:$journal.detail.pat_personal_main.other_contact_info.zip_cd">col:$journal.detail.pat_personal_main.other_contact_info.address</Address>
  <TelephoneNumber1>col:$journal.detail.pat_personal_main.other_contact_info.tel1</TelephoneNumber1>
  <TelephoneNumber2>col:$journal.detail.pat_personal_main.other_contact_info.tel2</TelephoneNumber2>
</Contact>', '{}', '1', '0', 4, '2020-05-25 16:27:48.164', '2020-05-25 16:27:55.526');
