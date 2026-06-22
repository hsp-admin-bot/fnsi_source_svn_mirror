class LayoutDefinition {
  constructor(
    logicalColumnName,
    physicalColumnName,
    isEditable = true,
    isDropdown = false
  ) {
    this.logicalColumnName = logicalColumnName;
    this.physicalColumnName = physicalColumnName;
    this.isEditable = isEditable;
    this.isDropdown = isDropdown;
  }
}

export default {
  person_info: {
    category_title: "本人情報",
    items: {
      pat_name_kana: new LayoutDefinition(
        "患者名(カナ)",
        "pat_last_name_kana$pat_first_name_kana",
        false
      ),
      pat_name_alpha: new LayoutDefinition(
        "患者名(英語)",
        "pat_last_name_alpha$pat_first_name_alpha",
        false
      ),
      in_out_class: new LayoutDefinition("入外", "in_out_class", false),
      pat_birthday: new LayoutDefinition("生年月日", "pat_birthday"),
      pat_sex: new LayoutDefinition("性別", "pat_sex", true, true),
      pat_blood_type_abo: new LayoutDefinition(
        "血液型(ABO)",
        "pat_blood_type_abo",
        true,
        true
      ),
      pat_blood_type_rh: new LayoutDefinition(
        "血液型(Rh)",
        "pat_blood_type_rh",
        true,
        true
      ),
      pat_blood_type_serovar: new LayoutDefinition(
        "血液型(亜型)",
        "pat_blood_type_serovar",
        true,
        true
      ),
      nationality: new LayoutDefinition("国籍", "nationality", true, true),
      zip_cd: new LayoutDefinition("郵便番号", "zip_cd"),
      address: new LayoutDefinition("住所", "address"),
      tel1: new LayoutDefinition("電話番号", "tel1"),
      tel2: new LayoutDefinition("電話番号2", "tel2"),
      fax: new LayoutDefinition("FAX", "fax"),
      e_mail: new LayoutDefinition("Email", "e_mail"),
      memo1: new LayoutDefinition("メモ1", "memo1"),
      memo2: new LayoutDefinition("メモ2", "memo2")
    }
  },

  other_contact_info: {
    category_title: "連絡先1",
    items: {
      last_name: new LayoutDefinition(
        "氏名(姓)",
        "other_contact_info$last_name"
      ),
      first_name: new LayoutDefinition(
        "氏名(名)",
        "other_contact_info$first_name"
      ),
      relation_name: new LayoutDefinition(
        "続柄",
        "other_contact_info$relation_name",
        true,
        true
      ),
      zip_cd: new LayoutDefinition("郵便番号", "other_contact_info$zip_cd"),
      address: new LayoutDefinition("住所", "other_contact_info$address"),
      tel1: new LayoutDefinition("電話番号", "other_contact_info$tel1"),
      tel2: new LayoutDefinition("電話番号2", "other_contact_info$tel2"),
      fax: new LayoutDefinition("FAX", "other_contact_info$fax"),
      e_mail: new LayoutDefinition("Email", "other_contact_info$e_mail"),
      work_name: new LayoutDefinition("勤務先", "other_contact_info$work_name"),
      work_tel: new LayoutDefinition(
        "勤務先電話番号",
        "other_contact_info$work_tel"
      ),
      memo1: new LayoutDefinition("メモ1", "other_contact_info$memo1"),
      memo2: new LayoutDefinition("メモ2", "other_contact_info$memo2")
    }
  },

  vendor_contact_info: {
    category_title: "連絡先(業者)1",
    items: {
      company_name: new LayoutDefinition(
        "会社名",
        "vendor_contact_info$company_name"
      ),
      zip_cd: new LayoutDefinition("郵便番号", "vendor_contact_info$zip_cd"),
      address: new LayoutDefinition("住所", "vendor_contact_info$address"),
      company_tel: new LayoutDefinition(
        "代表電話番号",
        "vendor_contact_info$company_tel"
      ),
      fax: new LayoutDefinition("代表Fax", "vendor_contact_info$fax"),
      worker_last_name: new LayoutDefinition(
        "担当者名(姓)",
        "vendor_contact_info$worker_last_name"
      ),
      worker_first_name: new LayoutDefinition(
        "担当者名(名)",
        "vendor_contact_info$worker_first_name"
      ),
      worker_tel: new LayoutDefinition(
        "電話番号",
        "vendor_contact_info$worker_tel"
      ),
      worker_e_mail: new LayoutDefinition(
        "Email",
        "vendor_contact_info$worker_e_mail"
      ),
      memo1: new LayoutDefinition("メモ1", "vendor_contact_info$memo1"),
      memo2: new LayoutDefinition("メモ2", "vendor_contact_info$memo2")
    }
  },

  pat_memo_info: {
    category_title: "患者メモ",
    items: {
      title_1: new LayoutDefinition("タイトル1", "pat_memo_info$title_1"),
      content_1: new LayoutDefinition("内容1", "pat_memo_info$content_1"),
      title_2: new LayoutDefinition("タイトル2", "pat_memo_info$title_2"),
      content_2: new LayoutDefinition("内容2", "pat_memo_info$content_2"),
      title_3: new LayoutDefinition("タイトル3", "pat_memo_info$title_3"),
      content_3: new LayoutDefinition("内容3", "pat_memo_info$content_3"),
      title_4: new LayoutDefinition("タイトル4", "pat_memo_info$title_4"),
      content_4: new LayoutDefinition("内容4", "pat_memo_info$content_4"),
      title_5: new LayoutDefinition("タイトル5", "pat_memo_info$title_5"),
      content_5: new LayoutDefinition("内容5", "pat_memo_info$content_5"),
      title_6: new LayoutDefinition("タイトル6", "pat_memo_info$title_6"),
      content_6: new LayoutDefinition("内容6", "pat_memo_info$content_6"),
      title_7: new LayoutDefinition("タイトル7", "pat_memo_info$title_7"),
      content_7: new LayoutDefinition("内容7", "pat_memo_info$content_7"),
      title_8: new LayoutDefinition("タイトル8", "pat_memo_info$title_8"),
      content_8: new LayoutDefinition("内容8", "pat_memo_info$content_8"),
      title_9: new LayoutDefinition("タイトル9", "pat_memo_info$title_9"),
      content_9: new LayoutDefinition("内容9", "pat_memo_info$content_9"),
      title_10: new LayoutDefinition("タイトル10", "pat_memo_info$title_10"),
      content_10: new LayoutDefinition("内容10", "pat_memo_info$content_10"),
      title_11: new LayoutDefinition("タイトル11", "pat_memo_info$title_11"),
      content_11: new LayoutDefinition("内容11", "pat_memo_info$content_11"),
      title_12: new LayoutDefinition("タイトル12", "pat_memo_info$title_12"),
      content_12: new LayoutDefinition("内容12", "pat_memo_info$content_12"),
      title_13: new LayoutDefinition("タイトル13", "pat_memo_info$title_13"),
      content_13: new LayoutDefinition("内容13", "pat_memo_info$content_13"),
      title_14: new LayoutDefinition("タイトル14", "pat_memo_info$title_14"),
      content_14: new LayoutDefinition("内容14", "pat_memo_info$content_14"),
      title_15: new LayoutDefinition("タイトル15", "pat_memo_info$title_15"),
      content_15: new LayoutDefinition("内容15", "pat_memo_info$content_15"),
      title_16: new LayoutDefinition("タイトル16", "pat_memo_info$title_16"),
      content_16: new LayoutDefinition("内容16", "pat_memo_info$content_16"),
      title_17: new LayoutDefinition("タイトル17", "pat_memo_info$title_17"),
      content_17: new LayoutDefinition("内容17", "pat_memo_info$content_17"),
      title_18: new LayoutDefinition("タイトル18", "pat_memo_info$title_18"),
      content_18: new LayoutDefinition("内容18", "pat_memo_info$content_18"),
      title_19: new LayoutDefinition("タイトル19", "pat_memo_info$title_19"),
      content_19: new LayoutDefinition("内容19", "pat_memo_info$content_19"),
      title_20: new LayoutDefinition("タイトル20", "pat_memo_info$title_20"),
      content_20: new LayoutDefinition("内容20", "pat_memo_info$content_20")
    }
  },

  medical_care_info: {
    category_title: "診療情報",
    items: {
      main_course_cd: new LayoutDefinition(
        "診療科",
        "medical_care_info$main_course_cd",
        true,
        true
      ),
      dialysis_course_cd: new LayoutDefinition(
        "透析実施科",
        "medical_care_info$dialysis_course_cd",
        true,
        true
      ),
      ward_cd: new LayoutDefinition(
        "病棟",
        "medical_care_info$ward_cd",
        true,
        true
      ),
      dialysis_count: new LayoutDefinition(
        "自施設通算透析回数",
        "medical_care_info$dialysis_count"
      ),
      purification_count: new LayoutDefinition(
        "自施設通算特殊浄化回数",
        "medical_care_info$purification_count"
      ),
      dialysis_start_date: new LayoutDefinition(
        "導入日",
        "medical_care_info$dialysis_start_date"
      ),
      dial_hst_year_month: new LayoutDefinition(
        "透析歴",
        "medical_care_info$dial_hst_year_month",
        false
      )
    }
  },

  charge_staff_info: {
    category_title: "担当者",
    items: {
      is_main: new LayoutDefinition(
        "主治医",
        "charge_staff_info$is_main",
        true,
        true
      ),
      is_charge_1: new LayoutDefinition(
        "担当1",
        "charge_staff_info$is_charge$1",
        true,
        true
      ),
      is_charge_2: new LayoutDefinition(
        "担当2",
        "charge_staff_info$is_charge$2",
        true,
        true
      ),
      is_puncture_1: new LayoutDefinition(
        "穿刺1",
        "charge_staff_info$is_puncture$1",
        true,
        true
      ),
      is_puncture_2: new LayoutDefinition(
        "穿刺2",
        "charge_staff_info$is_puncture$2",
        true,
        true
      )
    }
  },

  dialysis_is_main: {
    category_title: "透析困難(主)",
    items: {
      dialysis_is_main: new LayoutDefinition(" ", "dialysis_is_main", false)
    }
  },

  severity_cd: {
    category_title: "重症度",
    items: {
      severity_cd: new LayoutDefinition(" ", "severity_cd", true, true)
    }
  },

  transport_cd: {
    category_title: "搬送区分",
    items: {
      transport_cd: new LayoutDefinition(" ", "transport_cd", true, true)
    }
  }
};
