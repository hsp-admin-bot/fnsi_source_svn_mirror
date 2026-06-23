DELETE FROM ntss.mst_coop_ini
WHERE coop_ini_cd = -401
;


INSERT INTO ntss.mst_coop_ini(
  coop_ini_cd,
  facility_cd,
  coop_ini_memo,
  coop_ini_info,
  is_disp,
  is_del,
  reg_date,
  up_date,
  key_mapping
)
VALUES(
  -401,
  'P_hosp',
  'Medicom',
  '
[
  {
    "key0": "MED",
    "key1": "ALARM",
    "key2": "ENDPOINT",
    "value": "9051",
    "comment": "ポート(DBSERVERと同様の設定)",
    "default_v": "9051",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "ALARM",
    "key2": "LOCALENDPOINT",
    "value": "9052",
    "comment": "ポート(DBSERVERと同様の設定)",
    "default_v": "9052",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "ALARM",
    "key2": "OUTPUT",
    "value": "1",
    "comment": "出力する：1、出力しない:0",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "ALARM",
    "key2": "SENDIP",
    "value": "224.0.1.1",
    "comment": "マルチキャストIP(DBSERVERと同様の設定)",
    "default_v": "224.0.1.1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "1",
    "value": "0",
    "comment": "A",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "2",
    "value": "1",
    "comment": "B",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "3",
    "value": "3",
    "comment": "AB",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "4",
    "value": "2",
    "comment": "O",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "6",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "7",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "8",
    "value": "3",
    "comment": "",
    "default_v": "3",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "9",
    "value": "2",
    "comment": "",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "?",
    "value": "-",
    "comment": "不明",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "A",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "AB",
    "value": "2",
    "comment": "",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "B",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "O",
    "value": "3",
    "comment": "",
    "default_v": "3",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "Ａ",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "ＡＢ",
    "value": "2",
    "comment": "",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "Ｂ",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "Ｏ",
    "value": "3",
    "comment": "",
    "default_v": "3",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_RH_TO_FNW",
    "key2": "(+)",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_RH_TO_FNW",
    "key2": "(-)",
    "value": "2",
    "comment": "",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_RH_TO_FNW",
    "key2": "(＋)",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_RH_TO_FNW",
    "key2": "(－)",
    "value": "2",
    "comment": "",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_RH_TO_FNW",
    "key2": "+",
    "value": "0",
    "comment": "RH+",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_RH_TO_FNW",
    "key2": "-",
    "value": "2",
    "comment": "RH-",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_RH_TO_FNW",
    "key2": "?",
    "value": "-",
    "comment": "不明",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_RH_TO_FNW",
    "key2": "（+）",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_RH_TO_FNW",
    "key2": "（-）",
    "value": "2",
    "comment": "",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_RH_TO_FNW",
    "key2": "（＋）",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_BLOOD_RH_TO_FNW",
    "key2": "（－）",
    "value": "2",
    "comment": "",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_CLASS_NAME",
    "key2": "ESA製剤",
    "value": "ESA製剤",
    "comment": "分類名称の読み替え情報",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_CLASS_NAME",
    "key2": "テープ",
    "value": "テープ",
    "comment": "分類名称の読み替え情報",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_CLASS_NAME",
    "key2": "吸着カラム",
    "value": "吸着カラム",
    "comment": "分類名称の読み替え情報",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_CLASS_NAME",
    "key2": "吸着器",
    "value": "吸着器",
    "comment": "分類名称の読み替え情報",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_CLASS_NAME",
    "key2": "血液回路",
    "value": "血液回路",
    "comment": "分類名称の読み替え情報",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_CLASS_NAME",
    "key2": "抗凝固剤",
    "value": "抗凝固剤",
    "comment": "分類名称の読み替え情報",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_CLASS_NAME",
    "key2": "消毒剤",
    "value": "消毒剤",
    "comment": "分類名称の読み替え情報",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_CLASS_NAME",
    "key2": "生理食塩液",
    "value": "生理食塩液",
    "comment": "分類名称の読み替え情報",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_CLASS_NAME",
    "key2": "穿刺針",
    "value": "穿刺針",
    "comment": "分類名称の読み替え情報",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_CLASS_NAME",
    "key2": "透析液",
    "value": "透析液",
    "comment": "分類名称の読み替え情報",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_CLASS_NAME",
    "key2": "分離器",
    "value": "分離器",
    "comment": "分類名称の読み替え情報",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_CLASS_NAME",
    "key2": "補液",
    "value": "補液",
    "comment": "分類名称の読み替え情報",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_EXAMIN_ORDER_CLASS_TO_FNW",
    "key2": "03",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_EXAMIN_ORDER_CLASS_TO_FNW",
    "key2": "05",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_EXAMIN_ORDER_CLASS_TO_FNW",
    "key2": "Z1",
    "value": "IRAI05",
    "comment": "透析前",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_EXAMIN_ORDER_CLASS_TO_FNW",
    "key2": "Z2",
    "value": "IRAI06",
    "comment": "透析後",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_EXAMIN_ORDER_CLASS_TO_FNW",
    "key2": "０３",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_EXAMIN_ORDER_CLASS_TO_FNW",
    "key2": "０５",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_EXAMIN_ORDER_CLASS_TO_KARTE",
    "key2": "0",
    "value": "IRAI04",
    "comment": "透析前",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_EXAMIN_ORDER_CLASS_TO_KARTE",
    "key2": "1",
    "value": "IRAI06",
    "comment": "透析後",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_EXAMIN_ORDER_CLASS_TO_KARTE",
    "key2": "2",
    "value": "-",
    "comment": "その他",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "(+)",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "(-)",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "(1+)",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "(1＋)",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "(2+)",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "(2＋)",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "(3+)",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "(3＋)",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "(4+)",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "(4＋)",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "(＋)",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "(－)",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "(±)",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "(１+)",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "(２+)",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "(３+)",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "(４+)",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "+",
    "value": "1",
    "comment": "（＋）",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "-",
    "value": "0",
    "comment": "（－）",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "?",
    "value": "-",
    "comment": "不明",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "（+）",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "（-）",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "（1+）",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "（1＋）",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "（2+）",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "（2＋）",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "（3+）",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "（3＋）",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "（4+）",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "（4＋）",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "（＋）",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "（－）",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "（±）",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "（１+）",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "（１＋）",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "（２+）",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "（２＋）",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "（３+）",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INFECTION_TO_FNW",
    "key2": "（３＋）",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INOUT_TO_FNW",
    "key2": "1",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INOUT_TO_FNW",
    "key2": "2",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INOUT_TO_FNW",
    "key2": "3",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INOUT_TO_FNW",
    "key2": "G",
    "value": "0",
    "comment": "外来",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_INOUT_TO_FNW",
    "key2": "N",
    "value": "1",
    "comment": "入院",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_SEX_TO_FNW",
    "key2": "0",
    "value": "0",
    "comment": "男",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_SEX_TO_FNW",
    "key2": "1",
    "value": "1",
    "comment": "女",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_SEX_TO_FNW",
    "key2": "2",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_SEX_TO_FNW",
    "key2": "3",
    "value": "-",
    "comment": "",
    "default_v": "-",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_SEX_TO_KARTE",
    "key2": "-",
    "value": "-",
    "comment": "性別変換項目(FNW→電子カルテ)。INI_KEYにFNW側の値を指定し、電子カルテ側の値(INI_VALUE)を取得します。送信時に使います。",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_SEX_TO_KARTE",
    "key2": "0",
    "value": "1",
    "comment": "性別変換項目(FNW→電子カルテ)",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CONV_SEX_TO_KARTE",
    "key2": "1",
    "value": "2",
    "comment": "性別変換項目(FNW→電子カルテ)",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "COOPERATIONEVENT",
    "key2": "GENEVENT_DEL_TIME",
    "value": "5:00:00",
    "comment": "HH24:MI",
    "default_v": "05:00",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "COOPERATIONEVENT",
    "key2": "GENEVENT_KEEP_DAYS",
    "value": "90",
    "comment": "",
    "default_v": "90",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "COOPERATIONEVENT",
    "key2": "GENRESULT_DEL_TIME",
    "value": "5:30:00",
    "comment": "HH24:MI",
    "default_v": "05:30",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "COOPERATIONEVENT",
    "key2": "GENRESULT_KEEP_DAYS",
    "value": "90",
    "comment": "",
    "default_v": "90",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "COOPERATIONEVENT",
    "key2": "POLLING_DELAY",
    "value": "15",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "COOPERATIONEVENT",
    "key2": "POLLING_INTERVAL",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "COOP_CONFIG",
    "key2": "SCH_START_TIME",
    "value": "",
    "comment": "予定開始時刻の取得先を設定する。0:クールマスタの標準開始時刻、1:スケジュールの透析開始時刻",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "DELETE_IND",
    "key2": "GENEVENT_REG_FLG",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "EXAM_MARGIN_TIME",
    "key2": "DIAL_AFTER",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "EXAM_MARGIN_TIME",
    "key2": "DIAL_BEFORE",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "LOG",
    "key2": "DMP_INTERVAL",
    "value": "3",
    "comment": "nヶ月前の月のファイルを削除",
    "default_v": "3",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "LOG",
    "key2": "DMP_OUTPUT_FILENAME",
    "value": "DMP",
    "comment": "ダンプファイル名",
    "default_v": "DMP",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "LOG",
    "key2": "DMP_OUTPUT_PATH",
    "value": "D:/FNW/LOG/DUMP",
    "comment": "ダンプ出力先",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "LOG",
    "key2": "MIN_OUTPUT_LEVEL",
    "value": "4",
    "comment": "ログ出力レベル。最低DEBUG以上、最大ERROR以上",
    "default_v": "4",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "NET_FOLDER",
    "key2": "CERTIFY",
    "value": "1",
    "comment": "0：認証しない　1：認証する",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "NET_FOLDER",
    "key2": "PASSWORD_1",
    "value": "fnw",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "NET_FOLDER",
    "key2": "PASSWORD_2",
    "value": "",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "NET_FOLDER",
    "key2": "PASSWORD_3",
    "value": "",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "NET_FOLDER",
    "key2": "PASSWORD_4",
    "value": "",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "NET_FOLDER",
    "key2": "PASSWORD_5",
    "value": "",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "NET_FOLDER",
    "key2": "PATH_1",
    "value": "//FN-SRV01/DIALYSIS_REPORT_PDF",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "NET_FOLDER",
    "key2": "PATH_2",
    "value": "",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "NET_FOLDER",
    "key2": "PATH_3",
    "value": "",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "NET_FOLDER",
    "key2": "PATH_4",
    "value": "",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "NET_FOLDER",
    "key2": "PATH_5",
    "value": "",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "NET_FOLDER",
    "key2": "USER_1",
    "value": "administrator",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "NET_FOLDER",
    "key2": "USER_2",
    "value": "",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "NET_FOLDER",
    "key2": "USER_3",
    "value": "",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "NET_FOLDER",
    "key2": "USER_4",
    "value": "",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "NET_FOLDER",
    "key2": "USER_5",
    "value": "",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "REPORT_INFO",
    "key2": "CREATE",
    "value": "1",
    "comment": "0：作成しない　1：作成する",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "REPORT_INFO",
    "key2": "PLUGIN_DLL_NAME",
    "value": "CSICoopDialysisReportSendStd.dll",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "REPORT_INFO",
    "key2": "REPORT_OUTPUT_FORDER",
    "value": "//FN-SRV01/DIALYSIS_REPORT_PDF",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "REPORT_INFO",
    "key2": "REPORT_STORE_DLL_NAME",
    "value": "CoopComReportStore.dll",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "REPORT_INFO",
    "key2": "REPORT_STORE_FORDER",
    "value": "D:/FNW/NKKCOOPERATIONSERVER/STORED_REPORT_PDF",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "REPORT_INFO",
    "key2": "SEND",
    "value": "1",
    "comment": "0：送信しない　1：送信する",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "REPORT_INFO",
    "key2": "USE_REPORT_STORE",
    "value": "1",
    "comment": "0：使用しない　1：使用する",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "SERIES",
    "key2": "COOP_SERVER",
    "value": "001",
    "comment": "連携サーバが稼動する施設の系列施設コードを設定する。複数存在する場合は、系列施設コードをカンマ“,”区切りで設定する。",
    "default_v": "001",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "SERIES",
    "key2": "KARTE_SERVER",
    "value": "001",
    "comment": "カルテサーバが稼動する施設の系列施設コードを設定する。複数存在する場合は、系列施設コードをカンマ“,”区切りで設定する。",
    "default_v": "001",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "SWITCH",
    "key2": "DISP_FLG_EXAM",
    "value": "",
    "comment": "検査セットを展開する際、検査項目マスタの表示フラグ(DISP_FLG)設定を参照するかどうか　0：参照しない　1：参照する",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "SWITCH",
    "key2": "DISP_FLG_MEDI",
    "value": "",
    "comment": "セット薬剤を展開する際、薬剤マスタの表示フラグ(DISP_FLG)設定を参照するかどうか　0：参照しない　1：参照する",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_COMMON",
    "key2": "CONNECT_TYPE",
    "value": "0",
    "comment": "0：電子カルテ　1：オーダリング",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_COMMON",
    "key2": "DB_NETSERVICE",
    "value": "ORD0",
    "comment": "",
    "default_v": "ORD0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_COMMON",
    "key2": "DB_PASSWORD",
    "value": "mirai",
    "comment": "",
    "default_v": "PARTS_USER",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_COMMON",
    "key2": "DB_USER",
    "value": "mirai",
    "comment": "",
    "default_v": "PARTS_USER",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_COMMON",
    "key2": "DEFAULT_STAFF_CODE",
    "value": "D100",
    "comment": "担当医が空値の場合、指示医に設定するデフォルトスタッフ",
    "default_v": "D100",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_COMMON",
    "key2": "INDICATOR_FLG",
    "value": "1",
    "comment": "0:担当医を送信、1:指示医を送信",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_COMMON",
    "key2": "LIBRARY_TYPE",
    "value": "0",
    "comment": "0:PARTS 1:JMS",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_COMMON",
    "key2": "POPUP_NOTICE",
    "value": "0",
    "comment": "0：通知しない、1：通知する",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_COMMON",
    "key2": "SEND_PATID_FIGURES",
    "value": "8",
    "comment": "送信患者ID桁数",
    "default_v": "8",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISREPORTSND",
    "key2": "PDF_SERVER_FOLDER",
    "value": "D:/FNW/NKKWEB/dia_rep",
    "comment": "表示用WEBアプリの参照パスとあわせる",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSCHESND",
    "key2": "APPACTIONCODE",
    "value": "000001",
    "comment": "6桁ゼロパディング。シーエスアイ殿に現地設定を照会すること",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSCHESND",
    "key2": "APPCODE",
    "value": "00001",
    "comment": "5桁ゼロパディング。シーエスアイ殿に現地設定を照会すること",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSCHESND",
    "key2": "DEPTCODE",
    "value": "42",
    "comment": "2桁ゼロパディング。シーエスアイ殿に現地設定を照会すること",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSCHESND",
    "key2": "SCHE_DEL_STAFF_CODE",
    "value": "D100",
    "comment": "シーエスアイ殿に現地設定を照会すること",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSCHESND",
    "key2": "SPEC_APPACTIONCODE",
    "value": "150020",
    "comment": "6桁ゼロパディング。シーエスアイ殿に現地設定を照会すること",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSCHESND",
    "key2": "SPEC_APPCODE",
    "value": "15020",
    "comment": "5桁ゼロパディング。シーエスアイ殿に現地設定を照会すること",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSCHESND",
    "key2": "TERMINALNAME",
    "value": "FN-SRV02",
    "comment": "シーエスアイ殿に現地設定を照会すること",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSND",
    "key2": "DAPARTMENT",
    "value": "42",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSND",
    "key2": "DRUGBAG_FLG",
    "value": "0",
    "comment": "0:Ｉ/Ｆ出力しない 1:Ｉ/Ｆ出力する",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSND",
    "key2": "EQUIP_CLASS_CODES",
    "value": "",
    "comment": "処置材料として扱う分類コード。カンマ区切りで複数設定可能",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSND",
    "key2": "ORDER_WARD",
    "value": "TN",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSND",
    "key2": "OXYGENACTION_CODE",
    "value": "123456",
    "comment": "MIRAIs行為コード6桁",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSND",
    "key2": "OXYGENACTION_SEND_FLAG",
    "value": "1",
    "comment": "0：送信しない　1：送信する",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSND",
    "key2": "OXYGEN_INHALATION",
    "value": "999003",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSND",
    "key2": "REPLENISH_SEND_FLAG",
    "value": "1",
    "comment": "0:補液を送信しない 1:補液を送信する",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSND",
    "key2": "SAME_PROCEDURE_FLG",
    "value": "0",
    "comment": "0:まとめて送信 1:まとめずに送信",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSND",
    "key2": "STRANTICOAGULANT_METHOD_CODE",
    "value": "101",
    "comment": "抗凝固剤用手技コードの連携コード２",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSND",
    "key2": "STRANTICOAGULANT_PROCEDURE_CODE",
    "value": "202",
    "comment": "抗凝固剤を「注射薬」で送る場合の手技マスタ．手技コード（※汎用オーダで送る場合はダミー値をセット）",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSND",
    "key2": "STRANTICOAGULANT_ROUTE_CODE",
    "value": "200",
    "comment": "抗凝固剤用手技コードの連携コード１",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSND",
    "key2": "STRHEMODIALYSIS_METHOD_CODE",
    "value": "101",
    "comment": "透析液用手技コードの連携コード２",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSND",
    "key2": "STRHEMODIALYSIS_PROCEDURE_CODE",
    "value": "202",
    "comment": "透析液を「注射薬」で送る場合の手技マスタ．手技コード（※汎用オーダで送る場合はダミー値をセット）",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSND",
    "key2": "STRHEMODIALYSIS_ROUTE_CODE",
    "value": "200",
    "comment": "透析液用手技コードの連携コード１",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSND",
    "key2": "STRREPLENISH_METHOD_CODE",
    "value": "101",
    "comment": "補液用手技コードの連携コード２",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSND",
    "key2": "STRREPLENISH_PROCEDURE_CODE",
    "value": "202",
    "comment": "補液を「注射薬」で送る場合の手技マスタ．手技コード（※汎用オーダで送る場合はダミー値をセット）",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSND",
    "key2": "STRREPLENISH_ROUTE_CODE",
    "value": "200",
    "comment": "補液用手技コードの連携コード１",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSND",
    "key2": "TREATMENTACTION_MEDICINE_CODES",
    "value": "",
    "comment": "FNW薬剤コード。カンマ区切りで20件まで設定可。それ以上切捨て",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSND",
    "key2": "TREATMENTACTION_SEND_FLAG",
    "value": "1",
    "comment": "0：送信しない　1：送信する",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSND",
    "key2": "TREATMENTACTION_SEND_TYPE",
    "value": "0",
    "comment": "0:連携設定と一致する薬剤を処置行為とする、1:連携コード２に値が設定されている薬剤を処置行為とする",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSND",
    "key2": "TREATMENTACTION_UNITE_FLAG",
    "value": "1",
    "comment": "0:まとめて送信、1:まとめずに送信",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_DIALYSISSND",
    "key2": "UPDATE_TERMINAL",
    "value": "FN-SRV02",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_EXAMINRCV",
    "key2": "COMMENT_SEPARATE",
    "value": ",",
    "comment": "",
    "default_v": ",",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_EXAMINRCV",
    "key2": "EXECUTE_TIME",
    "value": "06:30",
    "comment": "日次処理の実施時刻を設定",
    "default_v": "06:30",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_EXAMINSCHESEND",
    "key2": "COMMENT_NAME_DIAL_AFTER",
    "value": "透析後",
    "comment": "シーエスアイ殿に現地設定を照会すること",
    "default_v": "透析後",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_EXAMINSCHESEND",
    "key2": "COMMENT_NAME_DIAL_BEFORE",
    "value": "透析前",
    "comment": "シーエスアイ殿に現地設定を照会すること",
    "default_v": "透析前",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_EXAMINSCHESEND",
    "key2": "COMMENT_NAME_OTHER",
    "value": "その他",
    "comment": "シーエスアイ殿に現地設定を照会すること",
    "default_v": "その他",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_EXAMINSCHESEND",
    "key2": "DAPARTMENT",
    "value": "15",
    "comment": "シーエスアイ殿に現地設定を照会すること",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_EXAMINSCHESEND",
    "key2": "SCHE_DEL_STAFF_CODE",
    "value": "D100",
    "comment": "シーエスアイ殿に現地設定を照会すること",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_EXAMINSCHESEND",
    "key2": "UPDATE_TERMINAL",
    "value": "FN-SRV02",
    "comment": "シーエスアイ殿に現地設定を照会すること",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_EXAMINSCHESEND",
    "key2": "WARD",
    "value": "AD",
    "comment": "シーエスアイ殿に現地設定を照会すること",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_GROUPCD",
    "key2": "PAT_GROUP_FLG",
    "value": "1",
    "comment": "0：利用しない　1：利用する",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_PATIENTRCV",
    "key2": "PATIENTRCV_DLL_NAME",
    "value": "CSICoopPatientRcvStd.dll",
    "comment": "",
    "default_v": "CSICoopPatientRcvStd.dll",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "CSI_PATIENTRCV",
    "key2": "PATIENTRCV_UPDATE_TIME",
    "value": "06:00",
    "comment": "日次処理の実施時刻を設定",
    "default_v": "06:00",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "PDF_DIALYSISREPORTSND",
    "key2": "PDF_NAMING_CONVENTION",
    "value": "①~00~②_③_④_⑤_⑥~透析記録~RSB.pdf",
    "comment": "①：患者ID(12桁)、②：YYYY、③：MM、④：DD、⑤：HH、⑥：MI ※日付は透析開始日時",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "PDF_DIALYSISREPORTSND",
    "key2": "PDF_OUTPUT_FOLDER",
    "value": "//GATEWAY/HDPDF",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "PDF_DIALYSISREPORTSND",
    "key2": "PDF_OUTPUT_FOLDER2",
    "value": "",
    "comment": "ファイル移動先フォルダ１に出力できない場合の出力先フォルダパス",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "PDF_DIALYSISREPORTSND",
    "key2": "PDF_PATID_PADLEFT",
    "value": "0",
    "comment": "患者IDを名称とする格納先フォルダ名の作成方法　0：0パディングなし　1：0パディングあり(12桁)",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "PDF_DIALYSISREPORTSND",
    "key2": "PDF_RESEND_FOLDER",
    "value": "",
    "comment": "ファイル移動先フォルダ１、２に送信できなかったファイルを格納するフォルダパス",
    "default_v": "D:/FNW/Wait",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "PDF_DIALYSISREPORTSND",
    "key2": "PDF_RESEND_INTERVAL",
    "value": "",
    "comment": "再送ファイル格納フォルダを監視する周期",
    "default_v": "60",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "PDF_DIALYSISREPORTSND",
    "key2": "PDF_SERVER_FOLDER",
    "value": "D:/FNW/NKKWEB/dia_rep",
    "comment": "表示用WEBアプリの参照パスとあわせる",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "PDF_DIALYSISREPORTSND",
    "key2": "SEND_PATID_LENGTH",
    "value": "",
    "comment": "PDFファイル名の患者ID桁数",
    "default_v": "12",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "PDF_DIALYSISREPORTSND",
    "key2": "SEND_STAFFID_LENGTH",
    "value": "",
    "comment": "PDFファイル名のスタッフID桁数",
    "default_v": "10",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "PDF_DIALYSISREPORTSND",
    "key2": "SYSTEM_TYPE",
    "value": "0",
    "comment": "0：標準、1：拡張、2：標準＋拡張",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "ACCEPT_SEND",
    "key2": "DOCTOR_CLASSIFICATION",
    "value": "0",
    "comment": "0：患者の担当医１(未設定時は担当医２)（取得できない場合は固定医師コード1）1：固定医師コード１2：固定医師コード２3：空白",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "ACCEPT_SEND",
    "key2": "PERSONAL_USER",
    "value": "1",
    "comment": "利用者マスタの連携コード参照用連携設定。1：in_hospital_cd_1;2：in_hospital_cd_2",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "ACCEPT_SEND",
    "key2": "FIXED_DOCTOR_CODE1",
    "value": "001",
    "comment": "固定医師コード1",
    "default_v": "001",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "ACCEPT_SEND",
    "key2": "FIXED_DOCTOR_CODE2",
    "value": "002",
    "comment": "固定医師コード2",
    "default_v": "002",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "ACCEPT_SEND",
    "key2": "COURES_CLASSIFICATION",
    "value": "0",
    "comment": "0：透析実績．診療科コードより診療科マスタ．連携コード（取得できない場合は固定診療科コード）1：固定診療科コード",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "ACCEPT_SEND",
    "key2": "FIXED_COURES_CODE1",
    "value": "001",
    "comment": "透析実績より診療科が取得できない場合にセット。固定診療科コード ",
    "default_v": "001",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "ACCEPT_SEND",
    "key2": "DAY_SENDING_FLAG",
    "value": "0",
    "comment": "処理時に、前体重測定日時が当日のもののみを送信するかを選択。",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "ACCEPT_SEND",
    "key2": "IN_HOSPTIAL_REASON",
    "value": "23",
    "comment": "投薬：1　注射：2　処置：3　検査：4　画像：5　理学：6　その他：9　診察：0 診察以外での来院理由を記録、複数指定可、左詰空白埋め",
    "default_v": "23",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "ACCEPT_SEND",
    "key2": "RECONNECTION",
    "value": "S1",
    "comment": "S1：再受機1 ～S5：再受機5",
    "default_v": "S1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "ACCEPT_SEND",
    "key2": "FILENAME_NUMBER",
    "value": "1",
    "comment": "再来受付連携 ファイル名フォーマットの項目No。1：固定値",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "PAT_SCOPE",
    "key2": "PAT_SCOPE_STATUS",
    "value": "1",
    "comment": "0:登録済患者（初期値）1:プロファイル連携済患者のみ　2:特殊（富士通・NEC)",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "EXAM_ORD",
    "key2": "SEQUENCE_DIGIT",
    "value": "4",
    "comment": "検査オーダ連携出力ファイル名の連番桁数",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "EXAM_ORD",
    "key2": "EXAM_INSTITUTION_CD",
    "value": "000001",
    "comment": "検査機関コード",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "EXAM_ORD",
    "key2": "FACILITY_NO",
    "value": "000002",
    "comment": "施設NO",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "MST",
    "key2": "EXAM_ITEM",
    "value": "1",
    "comment": "検査項目マスタの使用連携コード番号 1：in_hospital_cd_1;2：in_hospital_cd_2;3：in_hospital_cd_3",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "MST",
    "key2": "EXAM_SET",
    "value": "1",
    "comment": "検査セットマスタの使用連携コード番号 1：in_hospital_cd_1;2：in_hospital_cd_2;3：in_hospital_cd_3",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "EXAM_ORD",
    "key2": "OUTPUT_ITEM",
    "value": "0",
    "comment": "項目コード出力設定 0：検査セット/検査項目両方出力;1：検査セットのみ出力;2：検査項目のみ出力",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "EXAM_ORD",
    "key2": "OUTPUT_IN_OUT",
    "value": "0",
    "comment": "院内/院外出力設定 0：院内/院外両方出力;1：院内のみ出力;2：院外のみ出力",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "EXAM_ORD",
    "key2": "UNSET_DEFAULT_NAME",
    "value": "ﾄｳﾛｸﾅｼ",
    "comment": "未設定時のデフォルト氏名フリガナ",
    "default_v": "ﾄｳﾛｸﾅｼ",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "EXAM_ORD",
    "key2": "OUTSIDE_TERMS_DEFAULT_NAME",
    "value": "ｷﾔｸｶﾞｲ",
    "comment": "規約外時のデフォルト氏名フリガナ",
    "default_v": "ｷﾔｸｶﾞｲ",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "EXAM_ORD",
    "key2": "DEFAULT_DOCTOR",
    "value": "111",
    "comment": "デフォルト担当医",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "EXAM_ORD",
    "key2": "DEFAULT_COURSE",
    "value": "222",
    "comment": "デフォルト科コード",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "EXAM_ORD",
    "key2": "DEFAULT_WARD",
    "value": "333",
    "comment": "デフォルト病棟コード",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "EXAM_ORD",
    "key2": "DEFAULT_SEX",
    "value": "1",
    "comment": "デフォルト性別 1：男性;2：女性",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "EXAM_ORD",
    "key2": "PAT_ID_DIGIT",
    "value": "10",
    "comment": "患者IDの有効桁数",
    "default_v": "10",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "EXAM_ORD",
    "key2": "PAT_ID_PADDING",
    "value": "2",
    "comment": "患者IDの0詰め設定 0：左0埋め;1：右0埋め;2：0埋め無し",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "EXAM_ORD",
    "key2": "BEFORE_MARGIN",
    "value": "100",
    "comment": "透析前マージン時間",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "EXAM_ORD",
    "key2": "AFTER_MARGIN",
    "value": "200",
    "comment": "透析後マージン時間",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "EXAM_ORD",
    "key2": "OUTPUT_BED_NO",
    "value": "1",
    "comment": "ベッド番号の出力設定 0：出力しない;1：出力する",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "MST",
    "key2": "EXAM_ITEM_COST",
    "value": "3",
    "comment": "コスト計算用検査項目マスタの使用連携コード番号 1：in_hospital_cd_1;2：in_hospital_cd_2;3：in_hospital_cd_3",
    "default_v": "3",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "MST",
    "key2": "BED_CODE_CONV",
    "value": "1",
    "comment": "ベッドマスタの使用連携コード番号 1：in_hospital_cd_1;2：in_hospital_cd_2",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "EXAM_ORD",
    "key2": "COOP_UPDATE",
    "value": "0",
    "comment": "検査オーダ連携で連携済みのord_noの更新データを連携するか 0：連携しない;1：連携する",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "ADMISSION_SUPPORTED",
    "value": "0",
    "comment": "入院対応使用有無　0:使用しない 1:使用する",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "ELAPSED_DATA_OUTPUT",
    "value": "0",
    "comment": "入院患者経過データ出力有無　0:経過データを送信しない 1:経過データを送信する",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "DEVICE_IDENTIFICATION_NAME",
    "value": "FUTURENET",
    "comment": "機器識別文字",
    "default_v": "FUTURENET",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "MEDICAL_NAME",
    "value": "0",
    "comment": "診療科名設定区分 0:治療情報．実績：診療科コードから診療科マスタの診療科名 1:固定診療科名",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "FIXED_MEDICAL_NAME",
    "value": "透析科",
    "comment": "固定診療科名(治療情報．実績：診療科名より診療科が取得できなかった場合にセット)",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "DOCTOR_NAME_CLASSIFICATION",
    "value": "0",
    "comment": "医師名区分",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "PUNCTURE_USER_CLASSIFICATION",
    "value": "0",
    "comment": "穿刺者設定区分",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "RECOVERY_USER_CLASSIFICATION",
    "value": "0",
    "comment": "回収者設定区分",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "CHARGE_USER_CLASSIFICATION",
    "value": "0",
    "comment": "担当者設定区分",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "DR1_NAME_CLASSIFICATION",
    "value": "0",
    "comment": "Dr1設定区分",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "DR2_NAME_CLASSIFICATION",
    "value": "0",
    "comment": "Dr2設定区分",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "DR3_NAME_CLASSIFICATION",
    "value": "0",
    "comment": "Dr3設定区分",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "DR4_NAME_CLASSIFICATION",
    "value": "0",
    "comment": "Dr4設定区分",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "DR5_NAME_CLASSIFICATION",
    "value": "0",
    "comment": "Dr5設定区分",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "NS1_NAME_CLASSIFICATION",
    "value": "0",
    "comment": "担当Ns1設定区分",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "NS2_NAME_CLASSIFICATION",
    "value": "0",
    "comment": "担当Ns2設定区分",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "NS3_NAME_CLASSIFICATION",
    "value": "0",
    "comment": "担当Ns3設定区分",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "NS4_NAME_CLASSIFICATION",
    "value": "0",
    "comment": "担当Ns4設定区分",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "NS5_NAME_CLASSIFICATION",
    "value": "0",
    "comment": "担当Ns5設定区分",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "FIXED_DOCTOR_NAME1",
    "value": "医師１",
    "comment": "固定医師名1",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "FIXED_DOCTOR_NAME2",
    "value": "医師２",
    "comment": "固定医師名2",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "FIXED_NURSE_NAME1",
    "value": "看護師１",
    "comment": "固定担当看護師名1",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "FIXED_NURSE_NAME2",
    "value": "看護師２",
    "comment": "固定担当看護師名2",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "COMMENT",
    "value": "透析経過データ連携",
    "comment": "入力内容を表すコメント",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "MEDICAL_INTERVIEWS_INPUT_DATA_FILE_INFO_ID",
    "value": "0",
    "comment": "問診入力データファイル情報ＩＤ",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "DESCRIBED_CONTENT_TYPE",
    "value": "FactInputData",
    "comment": "記載内容種別",
    "default_v": "FactInputData",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "BLOOD_TYPE_A",
    "value": "A",
    "comment": "血液型（A）",
    "default_v": "A",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "BLOOD_TYPE_B",
    "value": "B",
    "comment": "血液型（B）",
    "default_v": "B",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "BLOOD_TYPE_AB",
    "value": "AB",
    "comment": "血液型（AB）",
    "default_v": "AB",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "BLOOD_TYPE_O",
    "value": "O",
    "comment": "血液型（O）",
    "default_v": "O",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "BLOOD_TYPE_RH+",
    "value": "RH+",
    "comment": "血液型（RH+）",
    "default_v": "RH+",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "BLOOD_TYPE_RH-",
    "value": "RH-",
    "comment": "血液型（RH-）",
    "default_v": "RH-",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "KARTE_ORD_SEND",
    "key2": "BLOOD_TYPE_UNKNOWN",
    "value": "不明",
    "comment": "血液型（不明）",
    "default_v": "不明",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "SEND_COMMENT",
    "key2": "CATEGORY",
    "value": "観察記録",
    "comment": "送信対象の患者イベントカテゴリ(SOAP)",
    "default_v": "観察記録",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "SEND_COMMENT",
    "key2": "SUB_CATEGORY",
    "value": "SOAP",
    "comment": "送信対象の患者イベントサブカテゴリ(SOAP)",
    "default_v": "SOAP",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "SEND_COMMENT",
    "key2": "S_FIELD",
    "value": "S",
    "comment": "Sとして送信するフィールド名(SOAP)",
    "default_v": "S",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "SEND_COMMENT",
    "key2": "O_FIELD",
    "value": "O",
    "comment": "Oとして送信するフィールド名(SOAP)",
    "default_v": "O",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "SEND_COMMENT",
    "key2": "A_FIELD",
    "value": "A",
    "comment": "Aとして送信するフィールド名(SOAP)",
    "default_v": "A",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "SEND_COMMENT",
    "key2": "P_FIELD",
    "value": "P",
    "comment": "Pとして送信するフィールド名(SOAP)",
    "default_v": "P",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "SEND_COMMENT2",
    "key2": "CATEGORY",
    "value": "観察記録",
    "comment": "送信対象の患者イベントカテゴリ(看護メモ)",
    "default_v": "観察記録",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "SEND_COMMENT2",
    "key2": "SUB_CATEGORY",
    "value": "看護メモ",
    "comment": "送信対象の患者イベントサブカテゴリ(看護メモ)",
    "default_v": "看護メモ",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "SEND_COMMENT2",
    "key2": "FIELD",
    "value": "TEXT",
    "comment": "送信するフィールド名(看護メモ)",
    "default_v": "TEXT",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "SEND_COMMENT3",
    "key2": "CATEGORY",
    "value": "観察記録",
    "comment": "送信対象の患者イベントカテゴリ(問診記録)",
    "default_v": "観察記録",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "SEND_COMMENT3",
    "key2": "SUB_CATEGORY",
    "value": "問診記録",
    "comment": "送信対象の患者イベントサブカテゴリ(問診記録)",
    "default_v": "問診記録",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "SEND_COMMENT3",
    "key2": "FIELD",
    "value": "TEXT",
    "comment": "送信するフィールド名(問診記録)",
    "default_v": "TEXT",
    "is_effect": "1"
  },
  {
    "key0": "MED",
    "key1": "EXAMIN_INFO",
    "key2": "IND_SEND_MODE",
    "value": "1",
    "comment": "当日送信済みの透析予定がない場合に検査オーダを連携するか 0：連携しない;1：連携する",
    "default_v": "1",
    "is_effect": "1"
  }
]'::jsonb,
  '1',
  '0',
  '2021-06-25 14:57:40.000',
  CURRENT_TIMESTAMP,
  NULL
)
;