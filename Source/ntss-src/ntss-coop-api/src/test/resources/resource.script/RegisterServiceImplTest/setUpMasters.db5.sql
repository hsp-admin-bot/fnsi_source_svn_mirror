-- mst_dialysis_difficulty
DELETE FROM mst_dialysis_difficulty;
INSERT INTO mst_dialysis_difficulty VALUES (1001,'TK2019',NULL,'血糖値異常（低）','1111',NULL,'1','0',NULL,NULL);
INSERT INTO mst_dialysis_difficulty VALUES (1002,'TK2019',NULL,'血糖値異常（高）','1112',NULL,'1','0',NULL,NULL);
INSERT INTO mst_dialysis_difficulty VALUES (1003,'TK2019',NULL,'血圧異常（低）','1113',NULL,'1','0',NULL,NULL);
INSERT INTO mst_dialysis_difficulty VALUES (1004,'TK2019',NULL,'血圧異常（高）','1114',NULL,'1','0',NULL,NULL);
INSERT INTO mst_dialysis_difficulty VALUES (1005,'TK2019',NULL,'電解質異常（低カリウム）','1115',NULL,'1','0',NULL,NULL);

-- mst_disease
DELETE FROM mst_disease;
INSERT INTO mst_disease VALUES (0,'TK2019','0','',NULL,NULL,NULL,NULL,NULL,NULL,'0','1','0',NULL,NULL);
INSERT INTO mst_disease VALUES (1001,'TK2019','1','ネフローゼ',NULL,NULL,NULL,NULL,NULL,NULL,'1111','1','0',NULL,NULL);
INSERT INTO mst_disease VALUES (1002,'TK2019','2','腎盂炎',NULL,NULL,NULL,NULL,NULL,NULL,'1112','1','0',NULL,NULL);
INSERT INTO mst_disease VALUES (1003,'TK2019','3','副腎炎',NULL,NULL,NULL,NULL,NULL,NULL,'1113','1','0',NULL,NULL);
INSERT INTO mst_disease VALUES (1004,'TK2019','4','心筋梗塞',NULL,NULL,NULL,NULL,NULL,NULL,'1114','1','0',NULL,NULL);
INSERT INTO mst_disease VALUES (1005,'TK2020','5','心筋梗塞',NULL,NULL,NULL,NULL,NULL,NULL,'1001','1','0',NULL,NULL);

-- mst_implant
DELETE FROM mst_implant;
INSERT INTO mst_implant VALUES (1001,'TK2019','ペースメーカー',NULL,'1111','1','0',NULL,NULL);
INSERT INTO mst_implant VALUES (1002,'TK2019','骨ボルト',NULL,'1112','1','0',NULL,NULL);

-- mst_infection
DELETE FROM mst_infection;
INSERT INTO mst_infection VALUES (1001,'TK2019',NULL,'流行性感冒',NULL,'1111','1','0',NULL,NULL);
INSERT INTO mst_infection VALUES (1002,'TK2019',NULL,'インフルエンザ',NULL,'1112','1','0',NULL,NULL);
INSERT INTO mst_infection VALUES (1003,'TK2019',NULL,'発疹チフス',NULL,'1113','1','0',NULL,NULL);

-- mst_severity
DELETE FROM mst_severity;
INSERT INTO mst_severity VALUES (1000,'TK2019','0','','2','1','0',NULL,NULL);
INSERT INTO mst_severity VALUES (1001,'TK2019','1','危篤','1111','1','0',NULL,NULL);
INSERT INTO mst_severity VALUES (1015,'TK2019','2','重症','1112','1','0',NULL,NULL);
INSERT INTO mst_severity VALUES (1003,'TK2019','3','軽傷','1113','1','0',NULL,NULL);
INSERT INTO mst_severity VALUES (1020,'TK2020','4','軽傷','1001','1','0',NULL,NULL);

-- mst_taboo_allergy
DELETE FROM mst_taboo_allergy;
INSERT INTO mst_taboo_allergy VALUES (1001,'TK2019','1','鶏卵',NULL,'1111',NULL,'1','0',NULL,NULL);
INSERT INTO mst_taboo_allergy VALUES (1002,'TK2019','2','エタノール',NULL,'1112',NULL,'1','0',NULL,NULL);
INSERT INTO mst_taboo_allergy VALUES (1003,'TK2019','3','アセトアミノフェン',NULL,'1113',NULL,'1','0',NULL,NULL);
INSERT INTO mst_taboo_allergy VALUES (1004,'TK2019','4','トマト',NULL,'1114',NULL,'1','0',NULL,NULL);

-- mst_transport
DELETE FROM mst_transport;
INSERT INTO mst_transport VALUES (1000,'TK2019','0','','1','1','0',NULL,NULL);
INSERT INTO mst_transport VALUES (1001,'TK2019','1','緊急搬送','1111','1','0',NULL,NULL);
INSERT INTO mst_transport VALUES (1009,'TK2019','2','通常搬送（転院）','1112','1','0',NULL,NULL);
INSERT INTO mst_transport VALUES (1003,'TK2019','3','タクシー','1113','1','0',NULL,NULL);
INSERT INTO mst_transport VALUES (1004,'TK2019','4','自家用車','1114','1','0',NULL,NULL);
INSERT INTO mst_transport VALUES (1005,'TK2019','5','ウォークイン','1115','1','0',NULL,NULL);
INSERT INTO mst_transport VALUES (1006,'TK2020','5','公共交通機関','1001','1','0',NULL,NULL);

-- mst_relationship
DELETE FROM mst_relationship;
INSERT INTO mst_relationship VALUES (0,'TK2019','本人','2000','1','0',NULL,NULL);
INSERT INTO mst_relationship VALUES (1,'TK2019','配偶者','2001','1','0',NULL,NULL);
INSERT INTO mst_relationship VALUES (2,'TK2019','親','2002','1','0',NULL,NULL);
INSERT INTO mst_relationship VALUES (3,'TK2019','兄弟姉妹','2003','1','0',NULL,NULL);
INSERT INTO mst_relationship VALUES (4,'TK2019','子','2004','1','0',NULL,NULL);
INSERT INTO mst_relationship VALUES (5,'TK2019','祖父母','2005','1','0',NULL,NULL);
INSERT INTO mst_relationship VALUES (6,'TK2019','孫','2006','1','0',NULL,NULL);
INSERT INTO mst_relationship VALUES (7,'TK2019','三親等以遠','2007','1','0',NULL,NULL);
INSERT INTO mst_relationship VALUES (8,'TK2019','血縁関係なし（友人、知人）','2008','1','0',NULL,NULL);
INSERT INTO mst_relationship VALUES (9,'TK2020','本人','1001','1','0',NULL,NULL);

-- mst_facility
DELETE FROM mst_device_set_info_default;
DELETE FROM mst_facility;
INSERT INTO mst_facility VALUES ('TK2019','ジャーナル-テーブル登録テストデータ',NULL,'01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

-- mst_device_set_info_default
INSERT INTO mst_device_set_info_default VALUES ('TK2019',
'{"device": "setting"}',
'{"name_1": "項目1名称", "name_2": "項目2名称", "name_3": "項目3名称", "name_4": "項目4名称", "name_5": "項目5名称", "weight_1": 500, "weight_2": 400, "weight_3": 300, "weight_4": 200, "weight_5": 100}',
'{"name_1": "項目1名称", "name_2": "項目2名称", "name_3": "項目3名称", "name_4": "項目4名称", "name_5": "項目5名称", "weight_1": 90000, "weight_2": 80000, "weight_3": 70000, "weight_4": 60000, "weight_5": 50000}',
NULL,NULL);

-- mst_coop_layout
DELETE FROM mst_coop_layout
WHERE ctl_no between 500 and 510;

INSERT INTO mst_coop_layout  (
ctl_no
, facility_cd
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
) VALUES (500,'TK2019','1','1', 'R','pre','text','サンプル1','TEX-SOL','動作確認用(pre)','0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="変換レイアウトサンプル">
  <item name="処理区分" len="2" key="shori_kbn" />
  <!-- pat_personal_main -->
  <item name="" len="4" col="pat_personal_main.hosp_pat_id" />
  <item name="患者氏名_姓" len="8" col="pat_personal_main.pat_last_name" />
  <item name="患者氏名_名" len="8" col="pat_personal_main.pat_first_name" />
  <item name="患者氏名_カタカナ姓" len="8" col="pat_personal_main.pat_last_name_kana" />
  <item name="患者氏名_カタカナ名" len="8" col="pat_personal_main.pat_first_name_kana" />
  <item name="生年月日" len="8" col="pat_personal_main.pat_birthday" />
  <item name="性別" len="1" col="pat_personal_main.pat_sex"
    key="sex" />
  <item name="国籍" len="2" col="pat_personal_main.nationality" />
  <item name="血液型_ABO" len="1" col="pat_personal_main.pat_blood_type_abo"
    key="blood_type_abo" />
  <item name="血液型_RH" len="1" col="pat_personal_main.pat_blood_type_rh"
    key="blood_type_rh" />
  <item name="血液型_亜型" len="2" col="pat_personal_main.pat_blood_type_serovar"
    key="blood_type_serovar" />
  <item name="入外区分" len="1" col="pat_personal_main.in_out_class"
    key="in_out_class" />
  <item name="死亡患者" len="1" col="pat_personal_main.is_die"
    key="is_die" />
  <item name="死因コード" len="4" col="pat_personal_main.die_cd" type="number" />
  <item name="死亡日" len="10" col="pat_personal_main.die_date" />

  <item name="透析困難情報_管理番号" len="5" col="pat_personal_main.dial_diff_com_info.ctl_no" />
  <item name="透析困難情報_透析困難コード" len="2" col="pat_personal_main.dial_diff_com_info.dial_diff_cd" />
  <item name="透析困難情報_主たる透析困難フラグ" len="1" col="pat_personal_main.dial_diff_com_info.is_main" />
  <item name="透析困難情報_透析困難フラグ" len="1" col="pat_personal_main.dial_diff_com_info.is_dial_diff" />
  <item name="透析困難情報_登録日時" len="10" col="pat_personal_main.dial_diff_com_info.reg_date" />

  <item name="重症度コード" len="4" col="pat_personal_main.severity_cd" />
  <item name="搬送区分コード" len="4" col="pat_personal_main.transport_cd" />

  <item name="本人連絡先情報_郵便番号" len="7" col="pat_personal_main.pat_contact_info.zip_cd" />
  <item name="本人連絡先情報_住所" len="20" col="pat_personal_main.pat_contact_info.address" />
  <item name="本人連絡先情報_電話番号1" len="15" col="pat_personal_main.pat_contact_info.tel1" />
  <item name="本人連絡先情報_メールアドレス" len="30" col="pat_personal_main.pat_contact_info.e_mail" />
  <item name="本人連絡先情報_勤務先名" len="30" col="pat_personal_main.pat_contact_info.work_name" />
  <item name="本人連絡先情報_メモ1" len="4" col="pat_personal_main.pat_contact_info.memo1" />

  <item name="連絡先情報_管理番号" len="4" col="pat_personal_main.other_contact_info.ctl_no" />
  <item name="連絡先情報_表示順" len="4" col="pat_personal_main.other_contact_info.disp_order" />
  <item name="連絡先情報_キーパーソン" len="1" col="pat_personal_main.other_contact_info.is_key_person" />
  <item name="連絡先情報_患者ID" len="4" col="pat_personal_main.other_contact_info.pat_id" />
  <item name="連絡先情報_姓" len="4" col="pat_personal_main.other_contact_info.last_name" />
  <item name="連絡先情報_名" len="4" col="pat_personal_main.other_contact_info.first_name" />
  <item name="連絡先情報_続柄コード" len="4" col="pat_personal_main.other_contact_info.relation_cd" />
  <item name="連絡先情報_続柄名" len="4" col="pat_personal_main.other_contact_info.relation_name" />
  <item name="連絡先情報_郵便番号" len="7" col="pat_personal_main.other_contact_info.zip_cd" />
  <item name="連絡先情報_メモ1" len="4" col="pat_personal_main.other_contact_info.memo1" />

  <item name="削除フラグ" len="1" col="pat_personal_main.is_del" />

  <item name="原疾患コード" len="4" col="pat_personal_main.primary_disease_cd" />

  <!-- pat_main -->
  <item name="同姓同名" len="1" col="pat_main.is_same" />
  <item name="インプラント有無" len="1" col="pat_main.is_implant" />
  <item name="感染症有無" len="1" col="pat_main.is_infect" />
  <item name="糖尿病患者扱い" len="1" col="pat_main.is_diabetes" />
  <item name="血糖検査有無" len="1" col="pat_main.is_blood_suger_exam" />

  <item name="患者メモ情報_管理番号" len="4" col="pat_main.pat_memo_info.ctl_no" type="number" />
  <item name="患者メモ情報_タイトル" len="10" col="pat_main.pat_memo_info.title" />
  <item name="患者メモ情報_内容" len="20" col="pat_main.pat_memo_info.content" />

  <item name="担当スタッフ情報_管理番号" len="4" col="pat_main.charge_staff_info.ctl_no" type="number" />
  <item name="担当スタッフ情報_表示順" len="4" col="pat_main.charge_staff_info.disp_order" type="number" />
  <item name="担当スタッフ情報_スタッフコード" len="7" col="pat_main.charge_staff_info.staff_cd" type="number" />
  <item name="担当スタッフ情報_主治医" len="1" col="pat_main.charge_staff_info.is_main" />
  <item name="担当スタッフ情報_受持ち" len="1" col="pat_main.charge_staff_info.is_charge" />
  <item name="担当スタッフ情報_穿刺" len="1" col="pat_main.charge_staff_info.is_puncture" />

  <item name="禁忌・アレルギー情報_管理番号" len="4" col="pat_main.taboo_allergy_info.ctl_no" />
  <item name="禁忌・アレルギー情報_表示順" len="4" col="pat_main.taboo_allergy_info.disp_order" />
  <item name="禁忌・アレルギー情報_内容" len="10" col="pat_main.taboo_allergy_info.content" />
  <item name="禁忌・アレルギー情報_備考" len="10" col="pat_main.taboo_allergy_info.memo" />
  <item name="禁忌・アレルギー情報_対象区分" len="1" col="pat_main.taboo_allergy_info.category_class"
    key="taboo_allergy_info.category_class" />
  <item name="禁忌・アレルギー情報_禁忌・アレルギークラス" len="1" col="pat_main.taboo_allergy_info.taboo_allergy_class"
    key="taboo_allergy_class" />
  <item name="禁忌・アレルギー情報_禁忌・アレルギーコード" len="1" col="pat_main.taboo_allergy_info.taboo_allergy_cd" />
  <item name="感染症情報_管理番号" len="4" col="pat_main.infect_info.ctl_no" type="number" />
  <item name="感染症情報_感染症コード" len="4" col="pat_main.infect_info.infection_cd" type="number" />
  <item name="感染症情報_結果コード" len="1" col="pat_main.infect_info.infect" />
  <item name="感染症情報_検査日" len="10" col="pat_main.infect_info.exam_date" />
  <item name="感染症情報_更新日時" len="10" col="pat_main.infect_info.up_date" />

  <item name="インプラント情報_管理番号" len="4" col="pat_main.implant_info.ctl_no" type="number" />
  <item name="インプラント情報_表示順" len="4" col="pat_main.implant_info.disp_order" type="number" />
  <item name="インプラント情報_インプラントコード" len="4" col="pat_main.implant_info.implant_cd" type="number" />
  <item name="インプラント情報_導入日" len="10" col="pat_main.implant_info.start_date" />

  <item name="削除フラグ" len="1" col="pat_main.is_del" />

</root>
'),'{
  "key": {
    "shori_kbn": {
       "01":"cre",
       "02":"upd",
       "03":"del"
    },

    "sex": {
      "0": "0",
      "1": "1",
      "2": "2"
    },

    "blood_type_abo": {
      "0": "0",
      "1": "1",
      "2": "2",
      "3": "3",
      "4": "4"
    },

    "blood_type_rh": {
      "0": "0",
      "1": "1",
      "2": "2"
    },

    "blood_type_serovar": {
      "00": "00",
      "11": "11",
      "12": "12",
      "13": "13",
      "14": "14",
      "15": "15",
      "16": "16",
      "17": "17",
      "18": "18",
      "21": "21",
      "22": "22",
      "23": "23",
      "24": "24",
      "25": "25",
      "26": "26",
      "27": "27",
      "28": "28"
    },

    "in_out_class": {
      "0": "0",
      "1": "1",
      "2": "2",
      "3": "3",
      "4": "4",
      "5": "5"
    },

    "is_die": {
      "0": "0",
      "1": "1"
    },

    "taboo_allergy_info.category_class": {
      "0": "0",
      "1": "1",
      "2": "2",
      "3": "3",
      "4": "4",
      "5": "5"
    },

    "taboo_allergy_class": {
      "1": "1",
      "2": "2"
    }
  }
}
','1','0',12345,'2019-11-18 00:00:00','2019-11-18 00:00:00');

INSERT INTO mst_coop_layout  (
ctl_no
, facility_cd
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
) VALUES (501, 'TK2019','1','1', 'R','cre','text      ','サンプル1','TEX-SOL','動作確認用(cre)','0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="変換レイアウトサンプル">
  <!-- pat_personal_main -->
  <item name="処理区分" len="2" />
  <item name="" len="4" col="pat_personal_main.hosp_pat_id" />
  <item name="患者氏名_姓" len="8" col="pat_personal_main.pat_last_name" />
  <item name="患者氏名_名" len="8" col="pat_personal_main.pat_first_name" />
  <item name="患者氏名_カタカナ姓" len="8" col="pat_personal_main.pat_last_name_kana" />
  <item name="患者氏名_カタカナ名" len="8" col="pat_personal_main.pat_first_name_kana" />
  <item name="生年月日" len="8" col="pat_personal_main.pat_birthday" />
  <item name="性別" len="1" col="pat_personal_main.pat_sex"
    key="sex" />
  <item name="国籍" len="2" col="pat_personal_main.nationality" />
  <item name="血液型_ABO" len="1" col="pat_personal_main.pat_blood_type_abo"
    key="blood_type_abo" />
  <item name="血液型_RH" len="1" col="pat_personal_main.pat_blood_type_rh"
    key="blood_type_rh" />
  <item name="血液型_亜型" len="2" col="pat_personal_main.pat_blood_type_serovar"
    key="blood_type_serovar" />
  <item name="入外区分" len="1" col="pat_personal_main.in_out_class"
    key="in_out_class" />
  <item name="死亡患者" len="1" col="pat_personal_main.is_die"
    key="is_die" />
  <item name="死因コード" len="4" col="pat_personal_main.die_cd" type="number" />
  <item name="死亡日" len="10" col="pat_personal_main.die_date" />

  <item name="透析困難情報_管理番号" len="5" col="pat_personal_main.dial_diff_com_info.ctl_no" />
  <item name="透析困難情報_透析困難コード" len="2" col="pat_personal_main.dial_diff_com_info.dial_diff_cd" />
  <item name="透析困難情報_主たる透析困難フラグ" len="1" col="pat_personal_main.dial_diff_com_info.is_main" />
  <item name="透析困難情報_透析困難フラグ" len="1" col="pat_personal_main.dial_diff_com_info.is_dial_diff" />
  <item name="透析困難情報_登録日時" len="10" col="pat_personal_main.dial_diff_com_info.reg_date" />

  <item name="重症度コード" len="4" col="pat_personal_main.severity_cd" />
  <item name="搬送区分コード" len="4" col="pat_personal_main.transport_cd" />

  <item name="本人連絡先情報_郵便番号" len="7" col="pat_personal_main.pat_contact_info.zip_cd" />
  <item name="本人連絡先情報_住所" len="20" col="pat_personal_main.pat_contact_info.address" />
  <item name="本人連絡先情報_電話番号1" len="15" col="pat_personal_main.pat_contact_info.tel1" />
  <item name="本人連絡先情報_メールアドレス" len="30" col="pat_personal_main.pat_contact_info.e_mail" />
  <item name="本人連絡先情報_勤務先名" len="30" col="pat_personal_main.pat_contact_info.work_name" />
  <item name="本人連絡先情報_メモ1" len="4" col="pat_personal_main.pat_contact_info.memo1" />

  <item name="連絡先情報_管理番号" len="4" col="pat_personal_main.other_contact_info.ctl_no" />
  <item name="連絡先情報_表示順" len="4" col="pat_personal_main.other_contact_info.disp_order" />
  <item name="連絡先情報_キーパーソン" len="1" col="pat_personal_main.other_contact_info.is_key_person" />
  <item name="連絡先情報_患者ID" len="4" col="pat_personal_main.other_contact_info.pat_id" />
  <item name="連絡先情報_姓" len="4" col="pat_personal_main.other_contact_info.last_name" />
  <item name="連絡先情報_名" len="4" col="pat_personal_main.other_contact_info.first_name" />
  <item name="連絡先情報_続柄コード" len="4" col="pat_personal_main.other_contact_info.relation_cd" />
  <item name="連絡先情報_続柄名" len="4" col="pat_personal_main.other_contact_info.relation_name" />
  <item name="連絡先情報_郵便番号" len="7" col="pat_personal_main.other_contact_info.zip_cd" />
  <item name="連絡先情報_メモ1" len="4" col="pat_personal_main.other_contact_info.memo1" />

  <item name="削除フラグ" len="1" col="pat_personal_main.is_del" />

  <item name="原疾患コード" len="4" col="pat_personal_main.primary_disease_cd" />

  <!-- pat_main -->
  <item name="同姓同名" len="1" col="pat_main.is_same" />
  <item name="インプラント有無" len="1" col="pat_main.is_implant" />
  <item name="感染症有無" len="1" col="pat_main.is_infect" />
  <item name="糖尿病患者扱い" len="1" col="pat_main.is_diabetes" />
  <item name="血糖検査有無" len="1" col="pat_main.is_blood_suger_exam" />

  <item name="患者メモ情報_管理番号" len="4" col="pat_main.pat_memo_info.ctl_no" type="number" />
  <item name="患者メモ情報_タイトル" len="10" col="pat_main.pat_memo_info.title" />
  <item name="患者メモ情報_内容" len="20" col="pat_main.pat_memo_info.content" />

  <item name="担当スタッフ情報_管理番号" len="4" col="pat_main.charge_staff_info.ctl_no" type="number" />
  <item name="担当スタッフ情報_表示順" len="4" col="pat_main.charge_staff_info.disp_order" type="number" />
  <item name="担当スタッフ情報_スタッフコード" len="7" col="pat_main.charge_staff_info.staff_cd" type="number" />
  <item name="担当スタッフ情報_主治医" len="1" col="pat_main.charge_staff_info.is_main" />
  <item name="担当スタッフ情報_受持ち" len="1" col="pat_main.charge_staff_info.is_charge" />
  <item name="担当スタッフ情報_穿刺" len="1" col="pat_main.charge_staff_info.is_puncture" />

  <item name="禁忌・アレルギー情報_管理番号" len="4" col="pat_main.taboo_allergy_info.ctl_no" />
  <item name="禁忌・アレルギー情報_表示順" len="4" col="pat_main.taboo_allergy_info.disp_order" />
  <item name="禁忌・アレルギー情報_内容" len="10" col="pat_main.taboo_allergy_info.content" />
  <item name="禁忌・アレルギー情報_備考" len="10" col="pat_main.taboo_allergy_info.memo" />
  <item name="禁忌・アレルギー情報_対象区分" len="1" col="pat_main.taboo_allergy_info.category_class"
    key="taboo_allergy_info.category_class" />
  <item name="禁忌・アレルギー情報_禁忌・アレルギークラス" len="1" col="pat_main.taboo_allergy_info.taboo_allergy_class"
    key="taboo_allergy_class" />
  <item name="禁忌・アレルギー情報_禁忌・アレルギーコード" len="1" col="pat_main.taboo_allergy_info.taboo_allergy_cd" />
  <item name="感染症情報_管理番号" len="4" col="pat_main.infect_info.ctl_no" type="number" />
  <item name="感染症情報_感染症コード" len="4" col="pat_main.infect_info.infection_cd" type="number" />
  <item name="感染症情報_結果コード" len="1" col="pat_main.infect_info.infect" />
  <item name="感染症情報_検査日" len="10" col="pat_main.infect_info.exam_date" />
  <item name="感染症情報_更新日時" len="10" col="pat_main.infect_info.up_date" />

  <item name="インプラント情報_管理番号" len="4" col="pat_main.implant_info.ctl_no" type="number" />
  <item name="インプラント情報_表示順" len="4" col="pat_main.implant_info.disp_order" type="number" />
  <item name="インプラント情報_インプラントコード" len="4" col="pat_main.implant_info.implant_cd" type="number" />
  <item name="インプラント情報_導入日" len="10" col="pat_main.implant_info.start_date" />

  <item name="削除フラグ" len="1" col="pat_main.is_del" />

</root>
'),'{
  "key": {
    "sex": {
      "0": "0",
      "1": "1",
      "2": "2"
    },

    "blood_type_abo": {
      "0": "0",
      "1": "1",
      "2": "2",
      "3": "3",
      "4": "4"
    },

    "blood_type_rh": {
      "0": "0",
      "1": "1",
      "2": "2"
    },

    "blood_type_serovar": {
      "00": "00",
      "11": "11",
      "12": "12",
      "13": "13",
      "14": "14",
      "15": "15",
      "16": "16",
      "17": "17",
      "18": "18",
      "21": "21",
      "22": "22",
      "23": "23",
      "24": "24",
      "25": "25",
      "26": "26",
      "27": "27",
      "28": "28"
    },

    "in_out_class": {
      "0": "0",
      "1": "1",
      "2": "2",
      "3": "3",
      "4": "4",
      "5": "5"
    },

    "is_die": {
      "0": "0",
      "1": "1"
    },

    "taboo_allergy_info.category_class": {
      "0": "0",
      "1": "1",
      "2": "2",
      "3": "3",
      "4": "4",
      "5": "5"
    },

    "taboo_allergy_class": {
      "1": "1",
      "2": "2"
    }
  }
}
','1','0',12345,'2019-11-18 00:00:00','2019-11-18 00:00:00');
