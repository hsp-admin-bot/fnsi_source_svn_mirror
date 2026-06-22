/**
 * 測定区分
 */
export const weightScaleClass = {
  /**
   * 前体重
   */
  before: 0,
  /**
   * 後体重
   */
  after: 1,
  /**
   * 重量測定
   */
  scale: 2,
  /**
   * 治療中（条件送信不可）
   */
  dialysis: 3,
  /**
   * スケジュールなし患者
   */
  noSchedule: 4,
  /**
   * 実績確定後（後体重測定不可）
   */
  pastDialysis: 5,
};
/**
 * 測定モード
 */
export const weightScaleMode = {
  /**
   * 体重
   */
  weight: 0,
  /**
   * 体重車いす
   */
  weightAndChair: 1,
  /**
   * 車いす
   */
  wheelChair: 2,
};
/**
 * 測定記録状況
 */
export const weightScaleState = {
  /**
   * 測定済み
   */
  measured: 0,
  /**
   * 条件送信指示中
   */
  order: 1,
  /**
   * 待機
   */
  wait: 2,
  /**
   * 条件送信成功
   */
  sendSuccess: 3,
  /**
   * 条件送信失敗
   */
  sendFailure: 4,
};
/**
 * 治療状況
 */
export const dialysisState = {
  /**
   * 条件送信前
   */
  beforeSendCondition: "0",
  /**
   * 条件送信済
   */
  afterSendCondition: "1",
  /**
   * 条件送信確認済み
   */
  checkedSendCondition: "2",
  /**
   * 治療中
   */
  dialysis: "3",
  /**
   * 排液済
   */
  afterDialysis: "4",
  /**
   * 後体重測定済み(実績未確定)
   */
  afterWeight: "5",
  /**
   * 後体重確認済み(過去実績)
   */
  afterPastRecord: "6",
};

/**
 * 装置側の条件送信可能状態
 */
export const machineSendable = {
  /**
   * 条件送信可能
   */
  sendable: "0",
  /**
   * 患者条件確定済み確認メッセージ必要
   */
  patVerified: "1",
  /**
   * 通信エラーなどで送信不可
   */
  notSendable: "2",
};

// 治療種別コード
export const deviceModeConstant = {
  //装置モード:不明("-1")
  UNKNOWN: -1,
  //装置モード:HD("0")
  HD: 0,
  //装置モード:ECUM("1")
  ECUM: 1,
  //装置モード:HDF("2")
  HDF: 2,
  //装置モード:HF("3")
  HF: 3,
  //装置モード:HD＋補液("4")
  HD_REP_LIQ: 4,
  //装置モード:ECUM+補液("5")
  ECUM_REP_LIQ: 5,
  //装置モード:AFBF("6")
  AFBF: 6,
  //装置モード:OHDF("7")
  OHDF: 7,
  //装置モード:OHF("8")
  OHF: 8,
  //装置モード:特殊浄化("9")
  PURIFICATION: 9,
  //装置モード:I-HDF("10")
  PRO_REP_LIQ: 10,
};
/**
 * チェック項目設定
 */
export const operateLegendData = {
  legends: [
    { id: 0, value_name: "DW", code: "[dw]", sample_value: 60, type: "number" },
    {
      id: 1,
      value_name: "目標体重",
      code: "[tw]",
      sample_value: 61,
      type: "number",
    },
    {
      id: 2,
      value_name: "測定値",
      code: "[mv]",
      sample_value: 70,
      type: "number",
    },
    {
      id: 3,
      value_name: "透析【前】体重",
      code: "[bw]",
      sample_value: 65.8,
      type: "number",
    },
    {
      id: 4,
      value_name: "透析【後】体重",
      code: "[aw]",
      sample_value: 61,
      type: "number",
    },
    {
      id: 5,
      value_name: "前回透析【後】体重",
      code: "[lw]",
      sample_value: 60,
      type: "number",
    },
    // #10290 2024.03.01 add 測定チェック項目[bwmx/bwmn]を追加 TDC米沢 start
    {
      id: 15,
      value_name: "前体重許容上限",
      code: "[bwmx]",
      sample_value: 10,
      type: "number",
    },
    {
      id: 16,
      value_name: "前体重許容下限",
      code: "[bwmn]",
      sample_value: 5,
      type: "number",
    },
    // #10290 2024.03.01 add 測定チェック項目[bwmx/bwmn]を追加 TDC米沢 end
    {
      id: 6,
      value_name: "除水目標値",
      code: "[twat]",
      sample_value: 4.8,
      type: "number",
    },
    {
      id: 7,
      value_name: "除水制限",
      code: "[lwat]",
      sample_value: 6,
      type: "number",
    },
    {
      id: 8,
      value_name: "風袋補正値",
      code: "[tare]",
      sample_value: 5.2,
      type: "number",
    },
    {
      id: 9,
      value_name: "除水補正値",
      code: "[wat]",
      sample_value: 3.0,
      type: "number",
    },
    {
      id: 10,
      value_name: "実績除水量",
      code: "[rwat]",
      sample_value: 4.78,
      type: "number",
    },
    {
      id: 11,
      value_name: "次回透析予定日<br>(MM/DD)",
      code: "[nd1]",
      sample_value: "MM/DD",
      type: "date",
    },
    {
      id: 12,
      value_name: "次回透析予定日<br>(YYYY/MM/DD)",
      code: "[nd2]",
      sample_value: "YYYY/MM/DD",
      type: "date",
    },
    {
      id: 13,
      value_name: "BMI",
      code: "[bmi]",
      sample_value: 22.5,
      type: "number",
    },
    {
      id: 14,
      value_name: "I-HDF 引き残し量",
      code: "[pg]",
      sample_value: 1.5,
      type: "number",
    },
  ],
};

/**
 * チェック項目設定の定数
 */
export const checkContent = {
  use_condition: {
    /**
     * 常に表示
     */
    always: 0,
    /**
     * 満たす場合に表示
     */
    isTrueView: 1,
    /**
     * 満たさない場合に表示
     */
    isFalseView: 2,
  },
  condition_ineq: {
    /**
     * >
     */
    more: 0,
    /**
     * >=
     */
    moreEqual: 1,
    /**
     * ==
     */
    equal: 2,
    /**
     * !=
     */
    notEqual: 3,
    /**
     * <=
     */
    lessEqual: 4,
    /**
     * <
     */
    less: 5,
  },
  sendable: {
    /**
     * 条件送信可能
     */
    ok: 0,
    /**
     * 正常範囲外確認チェック
     */
    checkWarn: 1,
    /**
     * 正常範囲外送信不可
     */
    checkError: 2,
    /**
     * 表示時確認チェック
     */
    viewWarn: 3,
    /**
     * 表示時送信不可
     */
    viewError: 4,
  },
};
