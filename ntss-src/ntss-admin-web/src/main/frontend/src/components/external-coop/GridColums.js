export const COOP_LIST = [
  {
    value: "ini_dial",
    text: "浄化申し込み・初回指示"
  },
  {
    value: "is_death",
    text: "死亡退院"
  },
  {
    value: "profile",
    text: "患者プロファイル"
  },
  {
    value: "ind_dial",
    text: "透析予約 "
  },
  {
    value: "ord_dial",
    text: "オーダ受け"
  },
  {
    value: "accept",
    text: "受付情報"
  },
  {
    value: "rst_dial",
    text: "透析実績"
  },
  {
    value: "rep_dial",
    text: "透析レポート"
  },
  {
    value: "exam_rst",
    text: "検査結果"
  },
  {
    value: "exam_ord",
    text: "検査オーダ"
  },
  {
    value: "rad_ord",
    text: "放射線検査オーダ"
  },
  {
    value: "phy_ord",
    text: "心電図検査オーダ"
  },
  {
    value: "shot_ord",
    text: "透析注射連携"
  },
  {
    value: "pre_ord",
    text: "処方情報連携 "
  },
  {
    value: "staff_mst",
    text: "スタッフマスタ連携"
  },
  {
    value: "vit_cop",
    text: "バイタル連携"
  },
  {
    value: "karte_ord",
    text: "カルテ記載連携"
  }
]
export const GRID_COLUMNS = [
  {
    field: "ctlNo",
    title: "No",
    editable: () => false,
    width: "100px",
    values: null
  },
  {
    field: "hospPatId",
    title: "患者ID",
    editable: () => false,
    width: "200px",
    values: null
  },
  {
    field: "patId",
    title: "保守患者ID",
    editable: () => false,
    width: "200px",
    values: null
  },
  {
    field: "patName",
    title: "患者名",
    editable: () => false,
    width: "200px",
    values: null
  },
  {
    field: "baseDate",
    title: "データ日",
    type:"datetime",
    template: "#=  (baseDate == null)? '' : kendo.toString(kendo.parseDate(baseDate), 'yyyy/MM/dd') #",
    editable: () => false,
    width: "250px",
    values: ""
  },
  {
    field: "ordNo",
    title: "透析番号",
    editable: () => false,
    width: "200px",
    values: null
  },
  {
    field: "regDate",
    title: "イベント発生日時",
    type:"datetime",
    template: "#=  (regDate == null)? '' : kendo.toString(kendo.parseDate(regDate), 'yyyy/MM/dd HH:mm:ss') #",
    editable: () => false,
    width: "200px",
    values: null
  },
  {
    field: "opeCd",
    title: "操作CD",
    editable: () => false,
    width: "200px",
    values: null
  },
  {
    field: "coopVersion",
    title: "連携名",
    editable: () => false,
    width: "200px",
    values: null
  },
  {
    field: "coopCd",
    title: "連携種別",
    editable: () => false,
    width: "250px",
    values: [
      {
        value: "",
        text: "全て"
      },
      {
        value: "ini_dial",
        text: "浄化申し込み・初回指示"
      },
      {
        value: "is_death",
        text: "死亡退院"
      },
      {
        value: "profile",
        text: "患者プロファイル"
      },
      {
        value: "ind_dial",
        text: "透析予約 "
      },
      {
        value: "ord_dial",
        text: "オーダ受け"
      },
      {
        value: "accept",
        text: "受付情報"
      },
      {
        value: "rst_dial",
        text: "透析実績"
      },
      {
        value: "rep_dial",
        text: "透析レポート"
      },
      {
        value: "exam_rst",
        text: "検査結果"
      },
      {
        value: "exam_ord",
        text: "検査オーダ"
      },
      {
        value: "rad_ord",
        text: "放射線検査オーダ"
      },
      {
        value: "phy_ord",
        text: "心電図検査オーダ"
      },
      {
        value: "shot_ord",
        text: "透析注射連携"
      },
      {
        value: "pre_ord",
        text: "処方情報連携 "
      },
      {
        value: "staff_mst",
        text: "スタッフマスタ連携"
      },
      {
        value: "vit_cop",
        text: "バイタル連携"
      },
      {
        value: "karte_ord",
        text: "カルテ記載連携"
      }
    ]
  },
  {
    field: "coopCdIndex",
    title: "連携種別詳細",
    editable: () => true,
    width: "200px",
    values: null
  },
  {
    field: "direction",
    title: "方向",
    editable: () => false,
    width: "90px",
    values: [
      { value: "S", text: "送信" },
      { value: "R", text: "受信" },
    ]
  },
  {
    field: "crud",
    title: "処理区分",
    editable: () => false,
    width: "120px",
    values: [
      {
        value: "C",
        text: "新規"
      },
      {
        value: "U",
        text: "更新"
      },
      {
        value: "D",
        text: "削除"
      }
    ]
  },
  {
    field: "coopOrdNo",
    title: "連携オーダNo",
    editable: () => false,
    width: "200px",
    values: null
  },
  {
    field: "anaResult",
    title: "処理結果",
    editable: () => true,
    width: "200px",
    values: [
      { value: "0", text: "未処理" },
      { value: "1", text: "処理中" },
      { value: "9", text: "処理完了" },
      { value: "S", text: "スキップ" },
      { value: "E1", text: "内部エラー" },
      { value: "E2", text: "外部エラー" },
      { value: "H", text: "保留" }
    ]
  },
  {
    field: "coopResult",
    title: "通信結果",
    editable: () => true,
    width: "200px",
    values: [
      { value: "0", text: "未処理" },
      { value: "1", text: "処理中" },
      { value: "8", text: "応答待ち" },
      { value: "9", text: "処理完了" },
      { value: "R", text: "リトライ"},
      { value: "S", text: "スキップ" },
      { value: "E1", text: "内部エラー" },
      { value: "E2", text: "外部エラー" }
    ]
  },
  {
    field: "message",
    title: "エラー詳細",
    editable: () => false,
    width: "200px",
    values: null
  },
  {
    field: "retryCnt",
    title: "再送回数",
    editable: () => false,
    width: "200px",
    values: null
  },
  {
    field: "dump",
    title: "電文",
    editable: () => false,
    width: "200px",
    values: null
  },
  {
    field: "dumpPath",
    title: "電文ファイル名",
    editable: () => false,
    width: "200px",
    values: null
  },
  {
    field: "conIntelligence",
    title: "浄化申込情報",
    editable: () => false,
    width: "200px",
    values: null
  },
  {
    field: "inAnaDate",
    title: "処理開始日時",
    type:"datetime",
    template: "#=  (inAnaDate == null)? '' : kendo.toString(kendo.parseDate(inAnaDate), 'yyyy/MM/dd HH:mm:ss') #",
    editable: () => false,
    width: "250px",
    values: null
  },
  {
    field: "outAnaDate",
    title: "処理完了日時",
    type:"datetime",
    template: "#=  (outAnaDate == null)? '' : kendo.toString(kendo.parseDate(outAnaDate), 'yyyy/MM/dd HH:mm:ss') #",
    editable: () => false,
    width: "250px",
    values: null
  },
  {
    field: "inRegDate",
    title: "通信開始日時",
    type:"datetime",
    template: "#=  (inRegDate == null)? '' : kendo.toString(kendo.parseDate(inRegDate), 'yyyy/MM/dd HH:mm:ss') #",
    editable: () => false,
    width: "250px",
    values: null
  },
  {
    field: "outRegDate",
    title: "通信完了日時",
    type:"datetime",
    template: "#=  (outRegDate == null)? '' : kendo.toString(kendo.parseDate(outRegDate), 'yyyy/MM/dd HH:mm:ss') #",
    editable: () => false,
    width: "250px",
    values: null
  },
];

export const ANA_RESULT_LIST = [
  {
    value: "0",
    text: "未処理"
  },
  {
    value: "1",
    text: "処理中"
  },
  {
    value: "9",
    text: "処理完了"
  },
  {
    value: "S",
    text: "スキップ"
  },
  {
    value: "E1",
    text: "内部エラー"
  },
  {
    value: "E2",
    text: "外部エラー"
  },
  // add 8298 稼働ビューアで検索条件に保留が選択できない 関 start
  {
    value: "H",
    text: "保留"
  },
  // add 8298 稼働ビューアで検索条件に保留が選択できない 関  end
];

export const COOP_RESULT_LIST = [
  {
    value: "0",
    text: "未処理"
  },
  {
    value: "1",
    text: "処理中"
  },
  {
    value: "8",
    text: "応答待ち"
  },
  {
    value: "9",
    text: "処理完了"
  },
  {
    value: "R",
    text: "リトライ"
  },
  {
    value: "S",
    text: "スキップ"
  },
  {
    value: "E1",
    text: "内部エラー"
  },
  {
    value: "E2",
    text: "外部エラー"
  }
];

/* add FNSI COOP_CDS_LISTを追加 start */
export const COOP_CDS_LIST = [
 { value: "ini_dial", text: "浄化申し込み・初回指示" },
 { value: "is_death", text: "死亡退院" },
 { value: "profile", text: "患者プロファイル" },
 { value: "ind_dial", text: "透析予約" },
 { value: "ord_dial", text: "オーダ受け" },
 { value: "accept", text: "受付情報" },
 { value: "rst_dial", text: "透析実績" },
 { value: "rep_dial", text: "透析レポート" },
 { value: "exam_rst", text: "検査結果" },
 { value: "exam_ord", text: "検査オーダ" },
 { value: "rad_ord", text: "放射線検査オーダ" },
 { value: "phy_ord", text: "心電図検査オーダ" },
 { value: "shot_ord", text: "透析注射連携" },
 { value: "pre_ord", text: "処方情報連携" },
 { value: "staff_mst", text: "スタッフマスタ連携" },
 { value: "vit_cop", text: "バイタル連携" },
 { value: "karte_ord", text: "カルテ記載連携" }
];
/* add FNSI COOP_CDS_LISTを追加 end */

export const DIRECTION_LIST = [
  { value: "S", text: "送信" },
  { value: "R", text: "受信" },
];

export const valueToText = (value, list) => {
  const target = list.find(item => item.value === value);
  return target ? target.text : "";
};
export const valuesToString = (values, list, separator) => {
  if (separator === undefined) {
    separator = "、";
  }
  return values.map(value => valueToText(value, list)).join(separator)
};
