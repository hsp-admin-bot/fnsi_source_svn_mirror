DELETE FROM ntss.mst_coop_ini
WHERE coop_ini_cd in(-301);

INSERT INTO ntss.mst_coop_ini
(coop_ini_cd, facility_cd, coop_ini_memo, coop_ini_info, is_disp, is_del, reg_date, up_date, key_mapping)
VALUES(-301, 'N_hosp', 'NEC標準(MegaOakHR)', '
[
  {
    "key0": "HR",
    "key1": "EXAMIN_RECV",
    "key2": "COMMENT_POSITION",
    "value": "C1",
    "comment": "※変更可 コメント１：C1 コメント２：C2",
    "default_v": "C1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "EXAMIN_RECV",
    "key2": "EXAMINCODE_POSITION",
    "value": "IN_HOSPITAL_CD",
    "comment": "※変更可 検査項目コード:EXAM_ITEM_CD 院内コード１:IN_HOSPITAL_CD 院内コード2:IN_HOSPITAL_CD2 院内コード3:IN_HOSPITAL_CD3",
    "default_v": "IN_HOSPITAL_CD",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_SEX_TO_FNW",
    "key2": "0",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_SEX_TO_FNW",
    "key2": "1",
    "value": "2",
    "comment": "",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_SEX_TO_FNW",
    "key2": "2",
    "value": "3",
    "comment": "",
    "default_v": "3",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "1",
    "value": "1",
    "comment": "INI_KEYに電子カルテ側の値を指定し、FNW側の定義に変換された値(INI_VALUE)を取得します。受信時に使います。",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "2",
    "value": "2",
    "comment": "",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "3",
    "value": "3",
    "comment": "",
    "default_v": "3",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "4",
    "value": "4",
    "comment": "",
    "default_v": "4",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "6",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "7",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "8",
    "value": "3",
    "comment": "",
    "default_v": "3",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "9",
    "value": "2",
    "comment": "",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "A",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "AB",
    "value": "2",
    "comment": "",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "B",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "O",
    "value": "3",
    "comment": "",
    "default_v": "3",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "Ａ",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "ＡＢ",
    "value": "2",
    "comment": "",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "Ｂ",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "Ｏ",
    "value": "3",
    "comment": "",
    "default_v": "3",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_RH_TO_FNW",
    "key2": "(+)",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_RH_TO_FNW",
    "key2": "(-)",
    "value": "2",
    "comment": "",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_RH_TO_FNW",
    "key2": "(＋)",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_RH_TO_FNW",
    "key2": "(－)",
    "value": "2",
    "comment": "",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_RH_TO_FNW",
    "key2": "+",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_RH_TO_FNW",
    "key2": "-",
    "value": "2",
    "comment": "",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_RH_TO_FNW",
    "key2": "（+）",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_RH_TO_FNW",
    "key2": "（-）",
    "value": "2",
    "comment": "",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_RH_TO_FNW",
    "key2": "（＋）",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_RH_TO_FNW",
    "key2": "（－）",
    "value": "2",
    "comment": "",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_EXAMIN_ORDER_CLASS_TO_FNW",
    "key2": "3",
    "value": "2",
    "comment": "",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_EXAMIN_ORDER_CLASS_TO_FNW",
    "key2": "5",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_EXAMIN_ORDER_CLASS_TO_FNW",
    "key2": "3",
    "value": "2",
    "comment": "",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_EXAMIN_ORDER_CLASS_TO_FNW",
    "key2": "5",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_EXAMIN_ORDER_CLASS_TO_FNW",
    "key2": "3",
    "value": "2",
    "comment": "",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_EXAMIN_ORDER_CLASS_TO_FNW",
    "key2": "5",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "1",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "2",
    "value": "2",
    "comment": "",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "3",
    "value": "3",
    "comment": "",
    "default_v": "3",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_ABO_TO_FNW",
    "key2": "4",
    "value": "4",
    "comment": "",
    "default_v": "4",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_RH_TO_FNW",
    "key2": "-",
    "value": "2",
    "comment": "",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_BLOOD_RH_TO_FNW",
    "key2": "+",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_SEX_TO_FNW",
    "key2": "0",
    "value": "1",
    "comment": "",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_SEX_TO_FNW",
    "key2": "1",
    "value": "2",
    "comment": "",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "CONV_SEX_TO_FNW",
    "key2": "2",
    "value": "3",
    "comment": "",
    "default_v": "3",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "TABOO_15",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "TABOO_16",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "TABOO_17",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "TABOO_18",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "TABOO_19",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "TABOO_20",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "INTRODUCTION_DATE_FLG",
    "value": "0",
    "comment": "0:取込まない、1:取込む",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "INDICATION_FLG",
    "value": "0",
    "comment": "0:取り込まない。1:患者イベントに取込む。",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "SUB_CATEGORIES",
    "value": "A1-1,A1-2",
    "comment": "患者イベント登録時の対象サブカテゴリ連携コード(カンマ区切りで複数設定可)",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NUM_AUTO_CALC",
    "key2": "AUTO_CALC_FLG",
    "value": "0",
    "comment": "0:自動計算しない 1:自動計算する",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NUM_AUTO_CALC",
    "key2": "院内コードサンプル",
    "value": "0:0.3/180:0.4/240:0.5/300:0.6",
    "comment": "INI_KEYに院内コード、INI_VALUEに透析時間(分):数量を/区切りで記載。※透析時間は左から小さい順に記載する。",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "GET_COURSE",
    "value": "1",
    "comment": "指示科に設定する値の切り替えフラグ 0：透析申込オーダ．指示科 / 1：患者情報．診療科 / 2：ベッド番号に紐づく科コード",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "DEF_COURSE",
    "value": "25",
    "comment": "指示科のデフォルト設定",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "GET_DOCTOR",
    "value": "1",
    "comment": "指示医に設定する値の切り替えフラグ 0：透析申込オーダ．指示医 / 1：患者情報．担当医 / 2：最新指示の指示者",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "DEF_DOCTOR",
    "value": "7005",
    "comment": "指示医のデフォルト設定",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "DEF_UPDATE_TERMINAL",
    "value": "chuint05",
    "comment": "更新端末のデフォト設定",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "OWN_EXPENSE_MEDICINE_CODE",
    "value": "0",
    "comment": "自費として扱う薬剤の薬剤コードを設定（※カンマ区切り複数設定可）",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTSTAFFRCV",
    "key2": "STAFF_NAME_EMPTY",
    "value": "1",
    "comment": "0：空欄指定を許可する(空欄の場合職員コードをスタッフ名として登録する) 1：空欄指定を許可しない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTSTAFFRCV",
    "key2": "STAFF_PASSWORD_EMPTY",
    "value": "0",
    "comment": "0：空欄指定を許可する(空欄の場合職員コードをパスワードとして登録する) 1：空欄指定を許可しない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTSTAFFRCV",
    "key2": "PROTECT_STAFF",
    "value": "A,B",
    "comment": "複数のスタッフを登録する場合はカンマ(,)で区切る。標準で変更対象外とするスタッフ [9900000081][9999999999][9999999901]",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTSTAFFRCV",
    "key2": "UPDATE_STAFF_CLASS",
    "value": "1",
    "comment": "0：更新しない 1：更新する",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTSTAFFRCV",
    "key2": "DEFAULT_STAFF_JOB_CD",
    "value": "",
    "comment": "職種のデフォルト設定",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "ORDERREQSEND_START_END_FLG",
    "value": "1",
    "comment": "削除の詳細指示電文に開始日・終了日を設定するかどうかを指定します。  0：設定しない（空白）  1：設定する",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "TABOO_CTL_NO",
    "value": "0",
    "comment": "患者禁忌情報の登録時の管理番号(表示順)を指定する。",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "KAIKEI_COMMENT_FLG",
    "value": "0",
    "comment": "透析コメントに会計コメント（開始、終了、時間）を出力するかどうかを設定 0：出力しない、1：出力する",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "ORDERREQSEND_BED_PERIOD_EXTEND",
    "value": "0",
    "comment": "詳細指示電文「ベッド予約時間帯」に設定する値の拡張設定。0：拡張しない(クール名から設定)、1：拡張する(クールコードから設定)",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_PERIOD_CONV",
    "key2": "1",
    "value": "1",
    "comment": "クールコードに対応するベッド予約時間帯を設定。",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_PERIOD_CONV",
    "key2": "2",
    "value": "2",
    "comment": "クールコードに対応するベッド予約時間帯を設定。",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_PERIOD_CONV",
    "key2": "3",
    "value": "3",
    "comment": "クールコードに対応するベッド予約時間帯を設定。",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_PERIOD_CONV",
    "key2": "4",
    "value": "",
    "comment": "クールコードに対応するベッド予約時間帯を設定。",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_PERIOD_CONV",
    "key2": "5",
    "value": "",
    "comment": "クールコードに対応するベッド予約時間帯を設定。",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_PERIOD_CONV",
    "key2": "6",
    "value": "",
    "comment": "クールコードに対応するベッド予約時間帯を設定。",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "BP_MAX_VAITAL_CD",
    "value": "101",
    "comment": "血圧上のバイタル項目コードを設定。未設定の場合は電文の送信対象に含めない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "BP_MIN_VAITAL_CD",
    "value": "102",
    "comment": "血圧下のバイタル項目コードを設定。未設定の場合は電文の送信対象に含めない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "PULSE_VAITAL_CD",
    "value": "103",
    "comment": "脈拍のバイタル項目コードを設定。未設定の場合は電文の送信対象に含めない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "TEMPERATURE_VAITAL_CD",
    "value": "104",
    "comment": "体温のバイタル項目コードを設定。未設定の場合は電文の送信対象に含めない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "WEIGHT_BEFORE_VAITAL_CD",
    "value": "105",
    "comment": "前体重のバイタル項目コードを設定。未設定の場合は電文の送信対象に含めない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "WEIGHT_AFTER_VAITAL_CD",
    "value": "106",
    "comment": "後体重のバイタル項目コードを設定。未設定の場合は電文の送信対象に含めない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "ELAPSED_TIME_VAITAL_CD",
    "value": "107",
    "comment": "経過時間のバイタル項目コードを設定。未設定の場合は電文の送信対象に含めない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "TREAT_MODE_VAITAL_CD",
    "value": "108",
    "comment": "治療モードのバイタル項目コードを設定。未設定の場合は電文の送信対象に含めない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "BLOOD_FLOW_VAITAL_CD",
    "value": "109",
    "comment": "血流量設定値のバイタル項目コードを設定。未設定の場合は電文の送信対象に含めない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "OFFWATER_SPEED_VAITAL_CD",
    "value": "110",
    "comment": "除水速度設定値のバイタル項目コードを設定。未設定の場合は電文の送信対象に含めない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "OFFWATER_ADD_VAITAL_CD",
    "value": "111",
    "comment": "除水積算値のバイタル項目コードを設定。未設定の場合は電文の送信対象に含めない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "OFFWATER_TERGET_VAITAL_CD",
    "value": "112",
    "comment": "除水目標値のバイタル項目コードを設定。未設定の場合は電文の送信対象に含めない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "VENOUS_PRESSURE_VAITAL_CD",
    "value": "113",
    "comment": "静脈圧のバイタル項目コードを設定。未設定の場合は電文の送信対象に含めない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "DIALYSATE_PRESSURE_VAITAL_CD",
    "value": "114",
    "comment": "透析液圧のバイタル項目コードを設定。未設定の場合は電文の送信対象に含めない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "TMP_VAITAL_CD",
    "value": "115",
    "comment": "ＴＭＰのバイタル項目コードを設定。未設定の場合は電文の送信対象に含めない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "IP_TOTAL_AMOUNT_VAITAL_CD",
    "value": "116",
    "comment": "ＩＰ総量のバイタル項目コードを設定。未設定の場合は電文の送信対象に含めない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "IP_SPEED_VAITAL_CD",
    "value": "117",
    "comment": "ＩＰ速度設定のバイタル項目コードを設定。未設定の場合は電文の送信対象に含めない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "DIALYSATE_TEMPERATURE_VAITAL_CD",
    "value": "118",
    "comment": "透析液温度のバイタル項目コードを設定。未設定の場合は電文の送信対象に含めない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "NA_CONCENTRATION_VAITAL_CD",
    "value": "119",
    "comment": "Ｎａ濃度のバイタル項目コードを設定。未設定の場合は電文の送信対象に含めない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "DIALYSATE_FLOW_VAITAL_CD",
    "value": "120",
    "comment": "透析液流量のバイタル項目コードを設定。未設定の場合は電文の送信対象に含めない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "REPLENISH_SPEED_VAITAL_CD",
    "value": "121",
    "comment": "補液速度設定値のバイタル項目コードを設定。未設定の場合は電文の送信対象に含めない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "REPLENISH_VALUE_VAITAL_CD",
    "value": "122",
    "comment": "補液量現在値のバイタル項目コードを設定。未設定の場合は電文の送信対象に含めない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "REPLENISH_TEMPERATURE_VAITAL_CD",
    "value": "123",
    "comment": "補液温度のバイタル項目コードを設定。未設定の場合は電文の送信対象に含めない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "DELTA_BV_VAITAL_CD",
    "value": "124",
    "comment": "ΔBVのバイタル項目コードを設定。未設定の場合は電文の送信対象に含めない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "DELTA_BV_CHANGE_RATE_CD",
    "value": "125",
    "comment": "ΔＢＶ変化率のバイタル項目コードを設定。未設定の場合は電文の送信対象に含めない",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "PATID_PATIDFIG",
    "value": "8",
    "comment": "患者ID桁数　(最大１0)（桁不足分は、先頭０パディング）",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_MSTVAITALSEND",
    "key2": "TREND_INTERVAL",
    "value": "30",
    "comment": "モニタデータの抽出間隔を設定",
    "default_v": "15",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "1",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "2",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "3",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "4",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "5",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "6",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "7",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "8",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "9",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "10",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "11",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "12",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "13",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "14",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "15",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "16",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "17",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "18",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "19",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "20",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "21",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "22",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "23",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "24",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "25",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "26",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "27",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "28",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "29",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "30",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "31",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "32",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "33",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "34",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "35",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "36",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "37",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "38",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "39",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "40",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "41",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "42",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "43",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "44",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "45",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "46",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "47",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "48",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "49",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "50",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "51",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "52",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "53",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "54",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "55",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "56",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "57",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "58",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "59",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "60",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "61",
    "value": "25001",
    "comment": "人工透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "1",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "2",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "3",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "4",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "5",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "6",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "7",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "8",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "9",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "10",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "11",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "12",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "13",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "14",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "15",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "16",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "17",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "18",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "19",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "20",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "21",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "22",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "23",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "24",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "25",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "26",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "27",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "28",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "29",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "30",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "31",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "32",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "33",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "34",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "FUNC_ADDITION",
    "value": "20",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "FUNC_ANEEDLE",
    "value": "28",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "FUNC_ANOTHER_ADD",
    "value": "30",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "FUNC_BLOODACCESS",
    "value": "21",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "FUNC_CONSUMPTION",
    "value": "29",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "FUNC_DIALYSIS_COMMENT",
    "value": "3A",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "FUNC_DIALYSIS_COMMENT2",
    "value": "3B",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "FUNC_DIALYSIS_COMMENT3",
    "value": "3C",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "FUNC_DIALYZER",
    "value": "25",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "FUNC_ITEM_COMMENT",
    "value": "32",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "FUNC_KOUCOAGULANT",
    "value": "26",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "FUNC_MEDICINE",
    "value": "27",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "FUNC_OTHER_ITEM",
    "value": "31",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "FUNC_TREAT",
    "value": "24",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "IND_ORDER_NO_HEADER",
    "value": "95",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "INFECT_1",
    "value": "960000",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "INFECT_10",
    "value": "960009",
    "comment": "未使用",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "INFECT_11",
    "value": "960010",
    "comment": "未使用",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "INFECT_12",
    "value": "960011",
    "comment": "未使用",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "INFECT_13",
    "value": "960012",
    "comment": "未使用",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "INFECT_14",
    "value": "960013",
    "comment": "未使用",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "INFECT_15",
    "value": "960014",
    "comment": "未使用",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "INFECT_16",
    "value": "960015",
    "comment": "未使用",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "INFECT_17",
    "value": "960016",
    "comment": "未使用",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "INFECT_18",
    "value": "960017",
    "comment": "未使用",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "INFECT_19",
    "value": "960018",
    "comment": "未使用",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "INFECT_2",
    "value": "960001",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "INFECT_20",
    "value": "960019",
    "comment": "未使用",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "INFECT_3",
    "value": "960002",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "INFECT_4",
    "value": "960003",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "INFECT_5",
    "value": "960004",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "INFECT_6",
    "value": "960005",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "INFECT_7",
    "value": "960006",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "INFECT_8",
    "value": "8",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "INFECT_9",
    "value": "960008",
    "comment": "未使用",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "OTHER_DIALYSIS_TIME",
    "value": "310003",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "OTHER_DIALYSIS_UNIT",
    "value": "HN",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "OTHER_DIALYZER_UNIT",
    "value": "HO",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "OTHER_KOUCOAGULANT_SPEED_UNIT",
    "value": "",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "OTHER_OFF_WATER",
    "value": "310010",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "OTHER_OFF_WATER_UNIT",
    "value": "L",
    "comment": "ADDMED_CODExx : ADDMED_CODExx=時間外薬剤コード",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "OXYGEN_CODE",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "OXYGEN_USED_UNIT",
    "value": "L",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "PATID_PATIDFIG",
    "value": "",
    "comment": "",
    "default_v": "10",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "SENDMSG_GEN",
    "value": "0",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "XMLGEN_CONTENT_NUMBER",
    "value": "1",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "XMLGEN_CONTENT_TYPE",
    "value": "application/pdf",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "XMLGEN_EXTENT_NAME",
    "value": "pdf",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "XMLGEN_FS_DISP",
    "value": "○",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "XMLGEN_HOSP_CODE",
    "value": "1",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "XMLGEN_OBJ_TYP",
    "value": "FNW",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "XMLGEN_SYSTEM_CODE",
    "value": "FNW",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "XMLGEN_TITLE_CODE",
    "value": "FNW",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "XMLGEN_TITLE_NAME",
    "value": "血液透析記録",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "XMLGEN_DEVICE_NAME",
    "value": "FutureNetWeb+Si",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "XMLGEN_IP_ADDRESS",
    "value": "192.168.10.52",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "TABOO_1",
    "value": "T01",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "TABOO_2",
    "value": "TT02",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "TABOO_3",
    "value": "T03",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "TABOO_4",
    "value": "T04",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "TABOO_5",
    "value": "T05",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "TABOO_6",
    "value": "T06",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "TABOO_7",
    "value": "T07",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "TABOO_8",
    "value": "T08",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "TABOO_9",
    "value": "T09",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "TABOO_10",
    "value": "T10",
    "comment": "",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "TABOO_11",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "TABOO_12",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "TABOO_13",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "TABOO_14",
    "value": "0",
    "comment": "",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "35",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "36",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "37",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "38",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "39",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "40",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "41",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "42",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "43",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "44",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "45",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "46",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "47",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "48",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "49",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "50",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "51",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "52",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "53",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "54",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "55",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "56",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "57",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "58",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "59",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC_BED_COURSE",
    "key2": "60",
    "value": "25",
    "comment": "透析センター",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "PAT_SCOPE",
    "key2": "ind_dial",
    "value": "2",
    "comment": "0:登録済患者（初期値）1:プロファイル連携済患者のみ　2:特殊（富士通・NEC)",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "PAT_SCOPE",
    "key2": "rst_dial",
    "value": "2",
    "comment": "0:登録済患者（初期値）1:プロファイル連携済患者のみ　2:特殊（富士通・NEC)",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "PAT_SCOPE",
    "key2": "rep_dial",
    "value": "2",
    "comment": "0:登録済患者（初期値）1:プロファイル連携済患者のみ　2:特殊（富士通・NEC)",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "PAT_SCOPE",
    "key2": "vit_cop",
    "value": "2",
    "comment": "0:登録済患者（初期値）1:プロファイル連携済患者のみ　2:特殊（富士通・NEC)",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "TREATMENT_COOP_CD_NO",
    "value": "1",
    "comment": "NEC連携の治療方法の連携コードとして使用する連携コード番号設定",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "TREATMENT_FUNC_CD_NO",
    "value": "2",
    "comment": "NEC連携の治療方法の機能コードとして使用する連携コード番号設定",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "VA_COOP_CD_NO",
    "value": "1",
    "comment": "NEC連携のVAの連携コードとして使用する連携コード番号設定",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "VA_FUNC_CD_NO",
    "value": "2",
    "comment": "NEC連携のVAの機能コードとして使用する連携コード番号設定",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "DIALYZER_COOP_CD_NO",
    "value": "1",
    "comment": "NEC連携のダイアライザの連携コードとして使用する連携コード番号設定",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "DIALYZER_FUNC_CD_NO",
    "value": "2",
    "comment": "NEC連携のダイアライザの機能コードとして使用する連携コード番号設定",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "MEDICINE_COOP_CD_NO",
    "value": "1",
    "comment": "NEC連携の薬剤の連携コードとして使用する連携コード番号設定",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "MEDICINE_FUNC_CD_NO",
    "value": "2",
    "comment": "NEC連携の薬剤の機能コードとして使用する連携コード番号設定",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "EQUIPMENT_COOP_CD_NO",
    "value": "1",
    "comment": "NEC連携の医療材料の連携コードとして使用する連携コード番号設定",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "EQUIPMENT_FUNC_CD_NO",
    "value": "2",
    "comment": "NEC連携の医療材料の機能コードとして使用する連携コード番号設定",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "DIFFICULT_COOP_CD_NO",
    "value": "1",
    "comment": "NEC連携の透析困難の連携コードとして使用する連携コード番号設定",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "DIFFICULT_FUNC_CD_NO",
    "value": "2",
    "comment": "NEC連携の透析困難の機能コードとして使用する連携コード番号設定",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "ADDITION_COOP_CD_NO",
    "value": "1",
    "comment": "NEC連携の加算の連携コードとして使用する連携コード番号設定",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "ADDITION_FUNC_CD_NO",
    "value": "2",
    "comment": "NEC連携の加算の機能コードとして使用する連携コード番号設定",
    "default_v": "2",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "COOP_CONFIG",
    "key2": "SCH_START_TIME",
    "value": "1",
    "comment": "予定開始時刻の取得先を設定する。0:クールマスタの標準開始時刻、1:スケジュールの透析開始時刻",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "MST",
    "key2": "PAT_EVENT_SUB_CATEGORY",
    "value": "1",
    "comment": "患者イベントサブカテゴリマスタの使用連携コード番号 1：in_hospital_cd_1;2：in_hospital_cd_2;3：in_hospital_cd_3;4：in_hospital_cd_4",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "BED_CODE_CONV",
    "value": "1",
    "comment": "ベッドマスタの使用連携コード番号 1：in_hospital_cd_1;2：in_hospital_cd_2",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "VA_SUB_CATEGORIES",
    "value": "A1-3,A1-4",
    "comment": "VAイベント登録時の対象サブカテゴリ連携コード(カンマ区切りで複数設定可)",
    "default_v": "",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "TABOO_REG_VERSION",
    "value": "0",
    "comment": "禁忌登録処理方法 0:FNSi方式（設定値の禁忌・アレルギーマスタの連携コードに紐づく禁忌を登録） 1:FNW方式（設定値の禁忌名称を一つの文字列にして登録）",
    "default_v": "0",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "DIALYSISSEND",
    "key2": "KOU_COAG_RESOLVE_MODE",
    "value": "",
    "comment": "",
    "default_v": "",
    "is_effect": ""
  },
  {
    "key0": "HR",
    "key1": "NEC",
    "key2": "MEDICINE_ADDMED_CODE",
    "value": "",
    "comment": "",
    "default_v": "",
    "is_effect": ""
  },
  {
    "key0": "HR",
    "key1": "DIALYSISSEND",
    "key2": "MODIFY_SEND_CLASS",
    "value": "1",
    "comment": "変更区分送信設定0:削除データを送信しない(変更で送信する)1：削除データを送信する(削除新規で送信する)",
    "default_v": "1",
    "is_effect": "1"
  },
  {
    "key0": "HR",
    "key1": "DIALYSISSCHESEND",
    "key2": "MODIFY_SEND_CLASS",
    "value": "2",
    "comment": "0：削除・新規イベントの切り替えはしない(変更イベントのまま)1：スケジュールの変更(クール・ベッド・治療開始時刻)を削除・新規イベントに切替2：治療開始時刻・治療条件・医材・投薬の変更を含めてすべて削除・新規イベントに切替",
    "default_v": "0",
    "is_effect": "1"
  },
    {
    "key0": "HR",
    "key1": "DIALYSISSCHESEND",
    "key2": "MODIFY_SEND_CLASS_1LIST",
    "value": "004005,004040,004041,004042,004043,004063,004098,004100,004101,004102,004106,004107,004108,004109,004110,004111,009002,009004,009005,009006,012002,012004,012005,012006,013003,013008,013009,013010,013011,013024,013025,013026",
    "comment": "MODIFY_SEND_CLASSが1の場合にcrud DとCの電文を作成するope_cdの配列",
    "default_v": "004005,004040,004041,004042,004043,004063,004098,004100,004101,004102,004106,004107,004108,004109,004110,004111,009002,009004,009005,009006,012002,012004,012005,012006,013003,013008,013009,013010,013011,013024,013025,013026",
    "is_effect": "1"
  }
]'::jsonb, '1', '0', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
