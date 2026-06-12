/**
 * 治療記録で使用するコード定数定義
 */
export const CODES = {
  /**
   * 入外区分
   */
  IN_OUT_CLASS: {
    OUTPATIENT_SERVICE: {
      cd: "0",
      text: "外来"
    },
    HOSPITALIZATION: {
      cd: "1",
      text: "入院"
    }
  },

  /**
   * 治療状況
   */
  DIALYSIS_STATE: {
    BEFORE_SEND_CONDITION: {
      cd: "0",
      text: "条件送信前"
    },
    AFTER_SEND_CONDITION: {
      cd: "1",
      text: "条件送信後"
    },
    CONFIRMED_SEND_CONDITION: {
      cd: "2",
      text: "条件送信確認済み"
    },
    DURING_TREATMENT: {
      cd: "3",
      text: "治療中"
    },
    AFTER_DRAINAGE: {
      cd: "4",
      text: "排液済"
    },
    AFTER_WEIGHT_MEASURING: {
      cd: "5",
      text: "後体重測定済み(実績未確定)"
    },
    CONFIRMED_WEIGHT_MEASURING: {
      cd: "6",
      text: "後体重確認済み(過去実績)"
    }
  },

  /**
   * 薬剤分類コード
   */
  MEDICINE_CLASS: {
    ANTI_COAGULANT: {
      classType: 1,
      text: "抗凝固剤"
    },
    DIALYSATE: {
      classType: 2,
      text: "透析液"
    },
    REPLACEMENT: {
      classType: 3,
      text: "補液"
    }
  },

  /**
   * 医療材料分類コード.
   */
  EQUIPMENT_CLASS: {
    BLOOD_CIRCUIT: {
      classType: 1,
      text: "血液回路"
    },
    PUNCTURE_NEEDLE: {
      classType: 2,
      text: "穿刺針(SN以外)"
    },
    PUNCTURE_NEEDLE_SN: {
      classType: 3,
      text: "穿刺針(SN)"
    },
    ADSORPTION_COLUMN: {
      classType: 4,
      text: "吸着カラム"
    },
    ADSORBER: {
      classType: 5,
      text: "吸着器"
    },
    SEPARATOR: {
      classType: 6,
      text: "分離器"
    }
  },

  /**
   * 補液選択
   */
  FLUID_REPLACEMENT_TIMING: {
    BEFORE: {
      cd: "1",
      text: "前補液"
    },
    AFTER: {
      cd: "0",
      text: "後補液"
    }
  },

  /**
   * シングルニードル
   */
  SINGLE_NEEDLE: {
    YES: {
      cd: "1",
      text: "使用する"
    },
    NO: {
      cd: "0",
      text: "使用しない"
    }
  },

  /**
   * IP使用選択
   */
  IP: {
    USE: {
      cd: "1",
      text: "使用する"
    },
    NO_USE: {
      cd: "0",
      text: "使用しない"
    }
  },

  /**
   * IPスタート
   */
  IP_START: {
    MANUAL: {
      cd: "0",
      text: "手動"
    },
    AUTO: {
      cd: "1",
      text: "自動"
    }
  },

  /**
   * IPワンショットスタート
   */
  AUTO_ONE_SHOT: {
    NO_USE: {
      cd: "0",
      text: "手動"
    },
    USE: {
      cd: "1",
      text: "自動"
    }
  },

  /**
   * 電源自動切り
   */
  AUTO_POWER_OFF: {
    ON: {
      cd: "1",
      text: "入"
    },
    OFF: {
      cd: "0",
      text: "切"
    }
  },

  /**
   * 治療条件項目
   */
  TREATMENT_CONDITION_ITEM: {
    TREATMENT_TIME: {
      cd: "1",
      text: "治療時間"
    },
    VA: {
      cd: "2",
      text: "VA"
    },
    TARGET_WEIGHT: {
      cd: "3",
      text: "目標体重"
    },
    WATER_REMOVAL_AMOUNT_LIMIT: {
      cd: "4",
      text: "除水量制限"
    },
    DIALYZER: {
      cd: "5",
      text: "ダイアライザ"
    },
    ADSORPTION_COLUMN: {
      cd: "6",
      text: "吸着カラム"
    },
    PRIMARY_FILM: {
      cd: "7",
      text: "1次膜"
    },
    SECONDARY_FILM: {
      cd: "8",
      text: "2次膜"
    },
    PUNCTURE_NEEDLE_A: {
      cd: "9",
      text: "穿刺針(A針)"
    },
    PUNCTURE_NEEDLE_V: {
      cd: "10",
      text: "穿刺針(V針)"
    },
    PUNCTURE_NEEDLE_SN: {
      cd: "11",
      text: "穿刺針(SN)"
    },
    SINGLE_NEEDLE: {
      cd: "12",
      text: "シングルニードル使用"
    },
    BLOOD_CIRCUIT: {
      cd: "13",
      text: "血液回路"
    },
    BLOOD_FLOW: {
      cd: "14",
      text: "血流量"
    },
    DIALYSATE: {
      cd: "15",
      text: "透析液"
    },
    DIALYSATE_FLOW_RATE: {
      cd: "16",
      text: "透析液流量"
    },
    DIALYSATE_AMOUNT: {
      cd: "17",
      text: "透析液使用数"
    },
    DIALYSATE_TEMPERATURE: {
      cd: "18",
      text: "透析液温度"
    },
    FLUID_REPLACEMENT: {
      cd: "19",
      text: "補液"
    },
    FLUID_REPLACEMENT_AMOUNT: {
      cd: "20",
      text: "補液量"
    },
    FLUID_REPLACEMENT_TIMING: {
      cd: "21",
      text: "補液選択"
    },
    FLUID_REPLACEMENT_USE_COUNT: {
      cd: "22",
      text: "補液使用数"
    },
    FLUID_REPLACEMENT_TEMPERATURE: {
      cd: "23",
      text: "補液温度"
    },
    FLUID_REPLACEMENT_SPEED: {
      cd: "24",
      text: "補液速度"
    },
    ANTI_COAGULANT: {
      cd: "25",
      text: "抗凝固剤"
    },
    ANTI_COAGULANT_ONE_SHOT_AMOUNT: {
      cd: "26",
      text: "抗凝固剤ワンショット量"
    },
    ANTI_COAGULANT_SPEED: {
      cd: "27",
      text: "抗凝固剤持続速度"
    },
    ANTI_COAGULANT_TOTAL_AMOUNT: {
      cd: "28",
      text: "抗凝固剤持続総量"
    },
    IP: {
      cd: "29",
      text: "IP使用選択"
    },
    IP_START: {
      cd: "30",
      text: "IPスタート"
    },
    IP_ONE_SHOT_AMOUNT: {
      cd: "31",
      text: "IPワンショット量"
    },
    IP_SPEED: {
      cd: "32",
      text: "IP速度"
    },
    IP_SPEED_MAX: {
      cd: "33",
      text: "IP速度最大値"
    },
    AUTO_ONE_SHOT: {
      cd: "34",
      text: "IPワンショットスタート"
    },
    IP_AUTO_OFF: {
      cd: "35",
      text: "IP電源自動切り"
    },
    IP_AUTO_OFF_TIME: {
      cd: "36",
      text: "IP電源自動切り時間"
    },
    IP_MONITOR_AUTO_OFF: {
      cd: "37",
      text: "IP電源OKモニタ切り"
    },
    IP_MONITOR_AUTO_OFF_TIME: {
      cd: "38",
      text: "IP電源OKモニタ切り時間"
    }
  },

  /**
   * 重量単位
   */
  UNIT_TYPE: {
    GRAM: {
      cd: 0,
      text: "g"
    },
    KILO_GRAM: {
      cd: 1,
      text: "kg"
    }
  },

  /**
   * 登録区分
   */
  COMMENT_INPUT_CLASS: {
    IND: {
      cd: 1,
      text: "指"
    },
    COOPERATION: {
      cd: 2,
      text: "連"
    },
    OTHER: {
      cd: 3,
      text: "他"
    },
    RST: {
      cd: 4,
      text: "治"
    }
  },
  /**
   * 指示コメント更新：指示コメントフラグ
   */
  COMMENT_FLAG: {
    NEW: {
      cd: 1,
      text: "新規"
    },
    EDIT: {
      cd: 2,
      text: "編集"
    },
    DELETE: {
      cd: 3,
      text: "削除"
    }
  },
  /**
   * 装置モニタデータ（バイタル情報）キー
   */
  VITAL_MONITOR_KEY: {
    BP_MAX: {
      cd: "90",
      text: "最高血圧"
    },
    BP_MIN: {
      cd: "91",
      text: "最低血圧"
    },
    BP_AVE: {
      cd: "92",
      text: "平均血圧"
    },
    PULSE: {
      cd: "93",
      text: "脈拍"
    },
    TEMPERATURE: {
      cd: "94",
      text: "体温"
    },
    BLOOD_SUGAR: {
      cd:"-1",
      text: "血糖値"
    }
  },
  /**
   * 装置モニタデータ種別
   */
  VITAL_DATA_TYPE: {
    UNKNOWN: {
      cd: 0,
      text: "不明"
    },
    MONITOR: {
      cd: 1,
      text: "モニタ"
    },
    BP_UNDER_DIALYSIS: {
      cd: 2,
      text: "透析中血圧"
    },
    RECIRCULATION_RATE: {
      cd: 3,
      text: "再循環率"
    },
    TEMPERATURE: {
      cd: 4,
      text: "体温測定"
    },
    BP_BEFORE_DIALYSIS: {
      cd: 5,
      text: "透析前血圧"
    },
    BP_AFTER_DIALYSIS: {
      cd: 6,
      text: "透析後血圧"
    }
  },
  /**
   * 血圧区分
   */
  BP_CLASS: {
    NONE: {
      cd: "2",
      text: ""
    },
    BEFORE: {
      cd: "5",
      text: "前血圧"
    },
    AFTER: {
      cd: "6",
      text: "後血圧"
    }
  },
  /**
   * グラフのスケール
   */
  CHART_SCALE: {
    TIME: {
      cd: "0",
      text: "時刻"
    },
    TIME_SERIES: {
      cd: "1",
      text: "時系列"
    }
  },
  /**
   * 転記区分初期値
   */
  POSTING_CLASS: {
    CONTINUE: {
      cd: "0",
      text: "継続"
    },
    TODAY: {
      cd: "1",
      text: "当日のみ"
    }
  },
  /**
   * 愁訴処置区分
   */
  COMPLAINT_TREAT_CLASS: {
    OXYGEN: {
      // mod #10158 コンバートされた酸素吸入が画面に表示されない dou start
      // cd: "3",
      cd: 3,
      // mod #10158 コンバートされた酸素吸入が画面に表示されない dou end
      text: "酸素吸入"
    },
    // add FNSI-改修内容 心電図追加 房 start
    ELECTRO:{
      // mod #10158 コンバートされた酸素吸入が画面に表示されない dou start
      // cd: "4",
      cd: 4,
      // mod #10158 コンバートされた酸素吸入が画面に表示されない dou end
      text: "心電図"
    }
    // add FNSI-改修内容 心電図追加 房 end
  },
  /**
   * 表示フラグ.
   */
  IS_DISP: {
    HIDDEN: {
      cd: "0",
      text: "非表示"
    },
    DISPLAY: {
      cd: "1",
      text: "表示"
    }
  },

  /**
   * 削除フラグ
   */
  IS_DEL: {
    /**
     * 未削除
     */
    NOT_DELETE: {
      cd: "0"
    },
    /**
     * 削除
     */
    DELETE: {
      cd: "1"
    }
  },

  /**
   * 確定フラグ
   */
  IS_CONFIRM: {
    /**
     * 未確定
     */
    PENDING: {
      cd: "0"
    },
    /**
     * 確定済
     */
    CONFIRM: {
      cd: "1"
    }
  },

  /**
   * 通信フォーマット
   */
  COM_FORMAT_CD: {
    /**
     * オフライン
     */
    OFFLINE: {
      cd: "F"
    },
  },

  /**
   * 通信種別
   */
  COM_TYPE: {
    /**
     * 通信なし
     */
    NOT: {
      cd: 0
    },
  },

  /**
   * 行程状態
   */
  PROCESS_STATE: {
    /**
     * 通信異常、電源OFF、異常
     */
    ABNORMAL: {
      cd: "99"
    },
  },

  /**
   * ラジオ、チェックボックス状態
   */
  CHECK: {
    OFF: {
      cd: "0",
    },
    ON: {
      cd: "1",
    }
  },

  /**
   * 治療モード
   * cd  : Integer
   * text: String
   */
  DEVICE_MODE: {
    HD: {
      cd: 0,
      text: "HD"
    },
    ECUM: {
     cd: 1,
     text: "ECUM"
    },
    HDF: {
      cd: 2,
      text: "HDF"
    },
    HF: {
      cd: 3,
      text: "HF"
    },
    HD_HO: {
      cd: 4,
      text: "HD+補液"
    },
    ECUM_HO: {
      cd: 5,
      text: "ECUM+補液"
    },
    AFBF: {
      cd: 6,
      text: "AFBF"
    },
    OHDF: {
      cd: 7,
      text: "OHDF"
    },
    OHF: {
      cd: 8,
      text: "OHF"
    },
    PURIFICATION: {
      cd: 9,
      text: "特殊浄化"
    },
    IHDF: {
      cd: 10,
      text: "I-HDF"
    },
    UNKNOWN: {
      cd: -1,
      text: "不明"
    }
  },

  /**
   * 薬剤区分
   */
  MEDICINE_TYPE: {
    ALL: {
      cd: 0,
      text: "すべて"
    },
    NORMAL: {
      // MOD 6984【試験T】【結合テスター】治療記録抗凝固剤は通常薬剤Vを選択できなかった START
      //cd: "1",
      cd: 1,
      // MOD 6984【試験T】【結合テスター】治療記録抗凝固剤は通常薬剤Vを選択できなかった END
      text: "通常薬剤"
    },
    MIX: {
      // MOD 6984【試験T】【結合テスター】治療記録抗凝固剤は通常薬剤Vを選択できなかった START
      //cd: "2",
      cd: 2,
      // MOD 6984【試験T】【結合テスター】治療記録抗凝固剤は通常薬剤Vを選択できなかった END
      text: "調製薬剤"
    }
  },

  /**
   * モニタでの表示形式制御
   */
  MONITOR_DISP_FORMAT: {
    PART: {
      cd: "0",
      text: "一部"
    },
    ALL: {
      cd: "1",
      text: "すべて表示"
    }
  },

  /**
   * バイタル・モニタ区分
   */
  VITAL_MONITOR_CLASS: {
    /**
     * バイタル
     */
    VITAL: {
      cd: "1",
      text: "バイタル"
    },
    /**
     * モニタ
     */
    MONITOR: {
      cd: "2",
      text: "モニタ"
    }
  },

  /**
   * モニタデータ種別
   * ※sys_monitor_itemからデータを取得する際に指定する.
   */
  MONI_DATA_TYPE: {
    /**
     * 透析装置
     */
    MACHINE: {
      cd: null,
      text: "透析装置"
    },
    /**
     * DAB
     */
    DAB: {
      cd: "A",
      text: "DAB"
    },
    /**
     * DAD
     */
    DAD: {
      cd: "D",
      text: "DAD"
    },
    /**
     * DRO
     */
    DRO: {
      cd: "R",
      text: "DRO"
    },
    /**
     * 特殊浄化
     */
    PURIFICATION: {
      cd: "Z",
      text: "特殊浄化"
    }
  },

  /**
   * 処置区分
   */
  TREATMENT_CLASS: {
    /**
     * 調製薬剤
     */
    MIX: {
      //9844 mod ljx start
      //cd: "0",
      cd: 0,
      text: "調製薬剤"
    },
    /**
     * 通常薬剤
     */
    NORMAL: {
      //cd: "1",
      cd: 1,
      text: "通常薬剤"
    },
    /**
     * 処置
     */
    TREAT: {
      //cd: "2",
      cd: 2,
      text: "処置"
      //9844 mod ljx end
    }
  },

  /**
   * 愁訴処置の入力区分
   */
  COMP_TREAT_INPUT_CLASS: {
    /**
     * 通信サーバ
     */
    COM_SERVER: {
      cd: 0,
    },
    /**
     * クライアント
     */
    CLIENT: {
      cd: 1,
    },
    /**
     * 外部連携
     */
    COOP: {
      cd: 2,
    }
  },

  /**
   * 編集可否フラグ
   */
  IS_EDITABLE: {
    /**
     * 編集不可
     */
    IMPOSSIBLE: {
      cd: "0"
    },
    /**
     * 編集可能
     */
    POSSIBLE: {
      cd: "1"
    }
  },

  /**
   * 治療条件情報の入力区分
   */
  CONDITION_INPUT_CLASS: {
    /**
     * クライアント
     */
    CLIENT: {
      cd: 1,
    },
    /**
     * 外部連携
     */
    COOP: {
      cd: 2,
    }
  },
};

/**
 * 治療記録変更時のメッセージ
 */
const TREATMENT_CHANGE_MESSAGE = {
  /**
   * メッセージ
   */
  MESSAGE_TYPE: {
    /**
     * 特殊浄化以外から特殊浄化以外に変更した時のメッセージ
     */
    TYPE_1: "治療方法を変更したため、<br>補液情報を更新しますがよろしいですか？",
    /**
     * 特殊浄化から特殊浄化以外、特殊浄化以外から特殊浄化に変更した時のメッセージ
     */
    TYPE_2: "治療方法を変更したため、<br>治療条件を更新しますがよろしいですか？"
  },
}

/**
 * 治療方法変更の処理
 */
export const TREATMENT_CHANGE_PROCESS = {
  /**
   * 処理タイプ
   */
  PROCESS_TYPE: {
    // なにもしない
    PROCESS_NONE: 0,
    // 補液に透析液をセット
    PROCESS_1: 1,
    // 治療方法マスタの条件設定に応じて対象外のものをnullにする
    PROCESS_2: 2,
    // 補液関連を全てnullにする
    PROCESS_3: 3,
    // 補液、補液量、補液使用数、補液速度をnullにする
    PROCESS_4: 4,
    // 補液、補液量、補液使用数、補液速度をnullにする
    // (補液温度と補液選択は設定されているままとする)
    PROCESS_5: 5,
  }
}

/**
 * 治療方法変更
 */
export const TREATMENT_MESSAGES = {
  TREATMENT_MAP: [
    //----------------------------------------------
    // HD -> XXXX
    //----------------------------------------------
    // HD -> HDF
    {
      key: `${CODES.DEVICE_MODE.HD.cd}:${CODES.DEVICE_MODE.HDF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_NONE}`,
    },
    // HD -> HF
    {
      key: `${CODES.DEVICE_MODE.HD.cd}:${CODES.DEVICE_MODE.HF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_NONE}`,
    },
    // HD -> OHDF
    {
      key: `${CODES.DEVICE_MODE.HD.cd}:${CODES.DEVICE_MODE.OHDF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_1}`,
    },
    // HD -> OHF
    {
      key: `${CODES.DEVICE_MODE.HD.cd}:${CODES.DEVICE_MODE.OHF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_1}`,
    },
    // HD -> 特殊浄化
    {
      key: `${CODES.DEVICE_MODE.HD.cd}:${CODES.DEVICE_MODE.PURIFICATION.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_2}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_2}`,
    },
    // HD -> I-HDF
    {
      key: `${CODES.DEVICE_MODE.HD.cd}:${CODES.DEVICE_MODE.IHDF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_1}`,
    },
    // HD -> AFBF
    {
      key: `${CODES.DEVICE_MODE.HD.cd}:${CODES.DEVICE_MODE.AFBF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_NONE}`,
    },
    //----------------------------------------------
    // ECUM -> XXXX
    //----------------------------------------------
    // ECUM -> HDF
    {
      key: `${CODES.DEVICE_MODE.ECUM.cd}:${CODES.DEVICE_MODE.HDF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_NONE}`,
    },
    // ECUM -> HF
    {
      key: `${CODES.DEVICE_MODE.ECUM.cd}:${CODES.DEVICE_MODE.HF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_NONE}`,
    },
    // ECUM -> OHDF
    {
      key: `${CODES.DEVICE_MODE.ECUM.cd}:${CODES.DEVICE_MODE.OHDF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_1}`,
    },
    // ECUM -> OHF
    {
      key: `${CODES.DEVICE_MODE.ECUM.cd}:${CODES.DEVICE_MODE.OHF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_1}`,
    },
    // ECUM -> 特殊浄化
    {
      key: `${CODES.DEVICE_MODE.ECUM.cd}:${CODES.DEVICE_MODE.PURIFICATION.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_2}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_2}`,
    },
    // ECUM -> I-HDF
    {
      key: `${CODES.DEVICE_MODE.ECUM.cd}:${CODES.DEVICE_MODE.IHDF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_1}`,
    },
    // ECUM -> AFBF
    {
      key: `${CODES.DEVICE_MODE.ECUM.cd}:${CODES.DEVICE_MODE.AFBF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_NONE}`,
    },
    //----------------------------------------------
    // HDF -> XXXX
    //----------------------------------------------
    // HDF -> HD
    {
      key: `${CODES.DEVICE_MODE.HDF.cd}:${CODES.DEVICE_MODE.HD.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_3}`,
    },
    // HDF -> ECUM
    {
      key: `${CODES.DEVICE_MODE.HDF.cd}:${CODES.DEVICE_MODE.ECUM.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_3}`,
    },
    // HDF -> OHDF
    {
      key: `${CODES.DEVICE_MODE.HDF.cd}:${CODES.DEVICE_MODE.OHDF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_4}`,
    },
    // HDF -> OHF
    {
      key: `${CODES.DEVICE_MODE.HDF.cd}:${CODES.DEVICE_MODE.OHF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_4}`,
    },
    // HDF -> 特殊浄化
    {
      key: `${CODES.DEVICE_MODE.HDF.cd}:${CODES.DEVICE_MODE.PURIFICATION.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_2}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_2}`,
    },
    // HDF -> I-HDF
    {
      key: `${CODES.DEVICE_MODE.HDF.cd}:${CODES.DEVICE_MODE.IHDF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_4}`,
    },
    //----------------------------------------------
    // HF -> XXXX
    //----------------------------------------------
    // HF -> HD
    {
      key: `${CODES.DEVICE_MODE.HF.cd}:${CODES.DEVICE_MODE.HD.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_3}`,
    },
    // HF -> ECUM
    {
      key: `${CODES.DEVICE_MODE.HF.cd}:${CODES.DEVICE_MODE.ECUM.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_3}`,
    },
    // HF -> OHDF
    {
      key: `${CODES.DEVICE_MODE.HF.cd}:${CODES.DEVICE_MODE.OHDF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_4}`,
    },
    // HF -> OHF
    {
      key: `${CODES.DEVICE_MODE.HF.cd}:${CODES.DEVICE_MODE.OHF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_4}`,
    },
    // HF -> 特殊浄化
    {
      key: `${CODES.DEVICE_MODE.HF.cd}:${CODES.DEVICE_MODE.PURIFICATION.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_2}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_2}`,
    },
    // HF -> I-HDF
    {
      key: `${CODES.DEVICE_MODE.HF.cd}:${CODES.DEVICE_MODE.IHDF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_4}`,
    },
    //----------------------------------------------
    // OHDF -> XXXX
    //----------------------------------------------
    // OHDF -> HD
    {
      key: `${CODES.DEVICE_MODE.OHDF.cd}:${CODES.DEVICE_MODE.HD.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_3}`,
    },
    // OHDF -> ECUM
    {
      key: `${CODES.DEVICE_MODE.OHDF.cd}:${CODES.DEVICE_MODE.ECUM.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_3}`,
    },
    // OHDF -> HDF
    {
      key: `${CODES.DEVICE_MODE.OHDF.cd}:${CODES.DEVICE_MODE.HDF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_5}`,
    },
    // OHDF -> HF
    {
      key: `${CODES.DEVICE_MODE.OHDF.cd}:${CODES.DEVICE_MODE.HF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_5}`,
    },
    // OHDF -> AFBF
    {
      key: `${CODES.DEVICE_MODE.OHDF.cd}:${CODES.DEVICE_MODE.AFBF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_5}`,
    },
    // OHDF -> 特殊浄化
    {
      key: `${CODES.DEVICE_MODE.OHDF.cd}:${CODES.DEVICE_MODE.PURIFICATION.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_2}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_2}`,
    },
    //----------------------------------------------
    // OHF -> XXXX
    //----------------------------------------------
    // OHF -> HD
    {
      key: `${CODES.DEVICE_MODE.OHF.cd}:${CODES.DEVICE_MODE.HD.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_3}`,
    },
    // OHF -> ECUM
    {
      key: `${CODES.DEVICE_MODE.OHF.cd}:${CODES.DEVICE_MODE.ECUM.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_3}`,
    },
    // OHF -> HDF
    {
      key: `${CODES.DEVICE_MODE.OHF.cd}:${CODES.DEVICE_MODE.HDF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_5}`,
    },
    // OHF -> HF
    {
      key: `${CODES.DEVICE_MODE.OHF.cd}:${CODES.DEVICE_MODE.HF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_5}`,
    },
    // OHF -> AFBF
    {
      key: `${CODES.DEVICE_MODE.OHF.cd}:${CODES.DEVICE_MODE.AFBF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_5}`,
    },
    // OHF -> 特殊浄化
    {
      key: `${CODES.DEVICE_MODE.OHF.cd}:${CODES.DEVICE_MODE.PURIFICATION.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_2}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_2}`,
    },
    //----------------------------------------------
    // 特殊浄化 -> XXXX
    //----------------------------------------------
    // 特殊浄化 -> HD
    {
      key: `${CODES.DEVICE_MODE.PURIFICATION.cd}:${CODES.DEVICE_MODE.HD.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_2}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_3}`,
    },
    // 特殊浄化 -> ECUM
    {
      key: `${CODES.DEVICE_MODE.PURIFICATION.cd}:${CODES.DEVICE_MODE.ECUM.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_2}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_3}`,
    },
    // 特殊浄化 -> HDF
    {
      key: `${CODES.DEVICE_MODE.PURIFICATION.cd}:${CODES.DEVICE_MODE.HDF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_2}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_NONE}`,
    },
    // 特殊浄化 -> HF
    {
      key: `${CODES.DEVICE_MODE.PURIFICATION.cd}:${CODES.DEVICE_MODE.HF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_2}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_NONE}`,
    },
    // 特殊浄化 -> AFBF
    {
      key: `${CODES.DEVICE_MODE.PURIFICATION.cd}:${CODES.DEVICE_MODE.AFBF.cd}`,
      // message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_2}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_NONE}`,
    },
    // 特殊浄化 -> OHDF
    {
      key: `${CODES.DEVICE_MODE.PURIFICATION.cd}:${CODES.DEVICE_MODE.OHDF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_2}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_4}`,
    },
    // 特殊浄化 -> OHF
    {
      key: `${CODES.DEVICE_MODE.PURIFICATION.cd}:${CODES.DEVICE_MODE.OHF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_2}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_4}`,
    },
    // 特殊浄化 -> I-HDF
    {
      key: `${CODES.DEVICE_MODE.PURIFICATION.cd}:${CODES.DEVICE_MODE.IHDF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_2}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_4}`,
    },
    //----------------------------------------------
    // I-HDF -> XXXX
    //----------------------------------------------
    // I-HDF -> HD
    {
      key: `${CODES.DEVICE_MODE.IHDF.cd}:${CODES.DEVICE_MODE.HD.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_3}`,
    },
    // I-HDF -> ECUM
    {
      key: `${CODES.DEVICE_MODE.IHDF.cd}:${CODES.DEVICE_MODE.ECUM.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_3}`,
    },
    // I-HDF -> HDF
    {
      key: `${CODES.DEVICE_MODE.IHDF.cd}:${CODES.DEVICE_MODE.HDF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_5}`,
    },
    // I-HDF -> HF
    {
      key: `${CODES.DEVICE_MODE.IHDF.cd}:${CODES.DEVICE_MODE.HF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_5}`,
    },
    // I-HDF -> AFBF
    {
      key: `${CODES.DEVICE_MODE.IHDF.cd}:${CODES.DEVICE_MODE.AFBF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_5}`,
    },
    // I-HDF -> 特殊浄化
    {
      key: `${CODES.DEVICE_MODE.IHDF.cd}:${CODES.DEVICE_MODE.PURIFICATION.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_2}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_2}`,
    },
    //----------------------------------------------
    // AFBF -> XXXX
    //----------------------------------------------
    // AFBF -> HD
    {
      key: `${CODES.DEVICE_MODE.AFBF.cd}:${CODES.DEVICE_MODE.HD.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_3}`,
    },
    // AFBF -> ECUM
    {
      key: `${CODES.DEVICE_MODE.AFBF.cd}:${CODES.DEVICE_MODE.ECUM.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_3}`,
    },
    // AFBF -> OHDF
    {
      key: `${CODES.DEVICE_MODE.AFBF.cd}:${CODES.DEVICE_MODE.OHDF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_4}`,
    },
    // AFBF -> OHF
    {
      key: `${CODES.DEVICE_MODE.AFBF.cd}:${CODES.DEVICE_MODE.OHF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_4}`,
    },
    // AFBF -> 特殊浄化
    {
      key: `${CODES.DEVICE_MODE.AFBF.cd}:${CODES.DEVICE_MODE.PURIFICATION.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_2}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_2}`,
    },
    // AFBF -> I-HDF
    {
      key: `${CODES.DEVICE_MODE.AFBF.cd}:${CODES.DEVICE_MODE.IHDF.cd}`,
      message: `${TREATMENT_CHANGE_MESSAGE.MESSAGE_TYPE.TYPE_1}`,
      process: `${TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_4}`,
    },
  ]
};

/**
 * マスタ削除表示
 */
export const MASTER_DELETE_DISPLAY = {
  DELETED : "【削除済み】",
  INCLUDE_DELETED : "【削除済み含む】"
}

export const MASTER_TERM_CUT = {
  CUT : "【期限切れ】",
  //#8484 医療材料選択IFのリスト不正 Start
  CUT_PART : "【期限切れ", // 日付を伴う期限切れ接頭辞の定型接頭辞パーツ
  //#8484 医療材料選択IFのリスト不正 End
  INCLUDE_DELETED : "【期限切れ含む】"
}
