/**
 * 治療方法マスタの定数クラス.
 */
/**
 * 装置モード定義
 */
export const DEVICEMODE = {
  UNKNOWN: -1,
  HD: 0,
  ECUM: 1,
  HDF: 2,
  HF: 3,
  HD_AND_REPLACEMENT: 4,
  ECUM_AND_REPLACEMENT: 5,
  AFBF: 6,
  OHDF: 7,
  OHF: 8,
  SPECIAL: 9,
  I_HDF: 10
};

/**
 * カテゴリNo定義
 */
export const CATEGORY_NO = {
  COND_BASE: 1,
  WEIGHT: 2,
  DIALYSISFLUID: 3,
  REPLENISHER: 4,
  ANTICOAGULANT: 5,
  IP_CONFIG: 6,
  SINGLE_NEEDLE: 7
};

class categoryInfo {
  constructor(no, name) {
    this.no = no;
    this.name = name;
  }
}

/**
 * 透析条件設定カテゴリ一覧
 */
export const categoryNameList = [
  new categoryInfo(CATEGORY_NO.COND_BASE, "基本条件"),
  new categoryInfo(CATEGORY_NO.WEIGHT, "体重"),
  new categoryInfo(CATEGORY_NO.DIALYSISFLUID, "透析液"),
  new categoryInfo(CATEGORY_NO.REPLENISHER, "補液"),
  new categoryInfo(CATEGORY_NO.ANTICOAGULANT, "抗凝固剤"),
  new categoryInfo(CATEGORY_NO.IP_CONFIG, "IP設定"),
  new categoryInfo(CATEGORY_NO.SINGLE_NEEDLE, "穿刺針")
];

/**
 * 治療項目マスタ透析条件設定の項目定義
 * @summary
 *  category: 大項目
 *  items: 小項目
 */
export const mstTreatmentCondSettingDefine = [
  // del 治療方法マスタ 再依赖 治療条件設定の並び順不正 孔 start
  // {
  //   category_no: 1,
  //   items: [
  //     { ctl_no: "2", is_use: "1" },
  //     { ctl_no: "5", is_use: "1" },
  //     { ctl_no: "6", is_use: "1" },
  //     { ctl_no: "7", is_use: "1" },
  //     { ctl_no: "8", is_use: "1" },
  //     { ctl_no: "13", is_use: "1" },
  //     { ctl_no: "14", is_use: "1" }
  //   ]
  // },
  // del 治療方法マスタ 再依赖 治療条件設定の並び順不正 孔 end
  {
    category_no: 2,
    items: [
      // 治療方法マスタ 再依赖 DWを追加する 孔 start
      // { ctl_no: "4", is_use: "1" },
      // { ctl_no: "3", is_use: "1" }
      { ctl_no: "39", is_use: "1" },
      { ctl_no: "3", is_use: "1" },
      { ctl_no: "4", is_use: "1" }
      // 治療方法マスタ 再依赖 DWを追加する 孔 start
    ]
  },
  // add 治療方法マスタ 再依赖 治療条件設定の並び順不正 孔 start
  {
    category_no: 1,
    items: [
      { ctl_no: "2", is_use: "1" },
      { ctl_no: "5", is_use: "1" },
      { ctl_no: "6", is_use: "1" },
      { ctl_no: "7", is_use: "1" },
      { ctl_no: "8", is_use: "1" },
      { ctl_no: "13", is_use: "1" },
      { ctl_no: "14", is_use: "1" }
    ]
  },
  {
    category_no: 7,
    items: [
      { ctl_no: "12", is_use: "1" },
      { ctl_no: "9", is_use: "1" },
      { ctl_no: "10", is_use: "1" },
      { ctl_no: "11", is_use: "1" }
    ]
  },
  // add 治療方法マスタ 再依赖 治療条件設定の並び順不正 孔 end
  {
    category_no: 3,
    items: [
      { ctl_no: "15", is_use: "1" },
      { ctl_no: "16", is_use: "1" },
      { ctl_no: "17", is_use: "1" },
      { ctl_no: "18", is_use: "1" }
    ]
  },
  {
    category_no: 4,
    items: [
      { ctl_no: "19", is_use: "0" },
      { ctl_no: "20", is_use: "0" },
      { ctl_no: "21", is_use: "0" },
      { ctl_no: "22", is_use: "0" },
      { ctl_no: "23", is_use: "0" },
      { ctl_no: "24", is_use: "0" }
    ]
  },
  {
    category_no: 5,
    items: [
      { ctl_no: "25", is_use: "1" },
      { ctl_no: "26", is_use: "1" },
      { ctl_no: "27", is_use: "1" },
      { ctl_no: "28", is_use: "1" }
    ]
  },
  {
    category_no: 6,
    items: [
      { ctl_no: "29", is_use: "1" },
      { ctl_no: "30", is_use: "1" },
      { ctl_no: "32", is_use: "1" },
      { ctl_no: "33", is_use: "1" },
      { ctl_no: "34", is_use: "1" },
      { ctl_no: "31", is_use: "1" },
      { ctl_no: "35", is_use: "1" },
      { ctl_no: "36", is_use: "1" },
      { ctl_no: "37", is_use: "1" },
      { ctl_no: "38", is_use: "1" }
    ]
  },
  // del 治療方法マスタ 再依赖 治療条件設定の並び順不正 孔 start
  // {
  //   category_no: 7,
  //   items: [
  //     { ctl_no: "12", is_use: "1" },
  //     { ctl_no: "9", is_use: "1" },
  //     { ctl_no: "10", is_use: "1" },
  //     { ctl_no: "11", is_use: "1" }
  //   ]
  // }
  // del 治療方法マスタ 再依赖 治療条件設定の並び順不正 孔 end
];

/**
 * 帳票グラフ設定に関する定数
 */
export const REPORT_GRAPH = {
  /**
       * 最大登録件数
       * ※バイタルを除いた最大項目数
       */
  MAX_ITEM_COUNT: 5,
  /**
   * モニタタイプとモニタ項目コードの区切り文字
   * ※sys_monitor_itemとmst_add_monitorのコードが重複する為、
   *   区分けする為の文字です.
   */
  MONITOR_ITEM_CD_PREFIX: "@",
  /**
   * 血圧情報のモニタ項目コード
   * ※バイタルの最高血圧(90)、最低血圧(91)、平均血圧(92) は固定で表示する為、除外する.
   */
  BP_MONITOR_ITEM: ["90", "91", "92"],
  /**
   * 選択肢から除外するデータ種別
   *  0 : 文字列
   *  3 : 時間・時刻
   */
  EXCLUSION_MONITOR_DATA_TYPE: [0, 3],
  /**
   * 線種の選択肢
   */
  SELECT_ITEM_LINE_TYPE:[
    {text:"実線", value:"Solid"},
    {text:"破線", value:"Dash"},
    {text:"点線", value:"Dot"}
  ],
  /**
   * プロット形状の選択肢
   */
  SELECT_ITEM_PLOT_TYPE: [
    {text:"△", value: "triangle"},
    {text:"▲", value: "triangle-b"},
    {text:"▽", value: "triangle-down"},
    {text:"▼", value: "triangle-down-b"},
    {text:"□", value: "square"},
    {text:"■", value: "square-b"},
    {text:"◇", value: "diamond"},
    {text:"◆", value: "diamond-b"},
    {text:"○", value: "circle"},
    {text:"●", value: "circle-b"},
    {text:"◎", value: "double-circle"}
  ],
  /**
   * 未選択時の選択肢
   */
  UN_SELECT_ITEM: {
    value: "-",
    text: "未登録"
  },
  /**
   * モニタ項目の識別用
   *  1 : sys_monitor_item のモニタ項目
   *  2 : mst_add_monitor のモニタ項目
   */
  MONITOR_TYPE: {
    /**
     * sys_monitor_itemのモニタ項目
     */
    SYS_MONITOR_ITEM: 1,
    /**
     * mst_add_monitorのモニタ項目
     */
    MST_ADD_MONITOR: 2
  },
  /**
   * 帳票グラフ設定が未登録時の初期値
   */
  DEFAULT_JSON_DATA: [
    {
      is_bp: true,
      cd: "90",
      type: 1,
      plot_type: "triangle-down-b",
      plot_color: "#999999",
      plot_size: 5,
      line_type: "Solid",
      line_color: "#999999",
      line_thickness: 2,
      max: 250,
      min: 0,
      // add 11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする zkm start
      show_check: true
      // add 11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする zkm end
    },
    {
      is_bp: true,
      cd: "92",
      type: 1,
      plot_type: "circle",
      plot_color: "#999999",
      plot_size: 5,
      line_type: "Solid",
      line_color: "#999999",
      line_thickness: 2,
      max: 250,
      min: 0,
      // add 11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする zkm start
      show_check: true
      // add 11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする zkm end
    },
    {
      is_bp: true,
      cd: "91",
      type: 1,
      plot_type: "triangle-b",
      plot_color: "#999999",
      plot_size: 5,
      line_type: "Solid",
      line_color: "#999999",
      line_thickness: 2,
      max: 250,
      min: 0,
      // add 11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする zkm start
      show_check: true
      // add 11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする zkm end
    }
  ]
};
