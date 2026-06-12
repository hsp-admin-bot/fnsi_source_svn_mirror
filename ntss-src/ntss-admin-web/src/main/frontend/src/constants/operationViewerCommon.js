import dayjs from "@/compat/date/dayjs";

// --------------------------------------
// 工程に関する設定(json)
// 工程コードをkeyとして、process_state_info内に以下の情報を保持
// process_name : 工程名称
// short_name : 工程略称
// color : 工程文字色(RGB指定) ※未使用
// class : class(cssでの配色指定する為に使用)
// --------------------------------------
const processStateInfos = [
  {
    process_state: "01",
    process_name: "プリセット",
    short_name: "プ",
    color: "#000000",
    class: "process-state-1"
  },
  {
    process_state: "02",
    process_name: "洗浄",
    short_name: "洗",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "03",
    process_name: "酸洗",
    short_name: "酸",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "04",
    process_name: "消毒",
    short_name: "消",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "05",
    process_name: "滞留",
    short_name: "滞",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "06",
    process_name: "液置換",
    short_name: "液",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "07",
    process_name: "透析準備",
    short_name: "準",
    color: "#000000",
    class: "process-state-1"
  },
  {
    process_state: "08",
    process_name: "ガスパージ",
    short_name: "ガ",
    color: "#000000",
    class: "process-state-1"
  },
  {
    process_state: "09",
    process_name: "排液",
    short_name: "排",
    color: "#000000",
    class: "process-state-1"
  },
  {
    process_state: "10",
    process_name: "停止",
    short_name: "停",
    color: "#008000",
    class: "process-state-3"
  },
  {
    process_state: "11",
    process_name: "運転",
    short_name: "運",
    color: "#008000",
    class: "process-state-3"
  },
  {
    process_state: "20",
    process_name: "プリセット",
    short_name: "プ",
    color: "#000000",
    class: "process-state-1"
  },
  {
    process_state: "21",
    process_name: "透析",
    short_name: "透",
    color: "#008000",
    class: "process-state-3"
  },
  {
    process_state: "22",
    process_name: "予備透析",
    short_name: "予",
    color: "#008000",
    class: "process-state-3"
  },
  {
    process_state: "23",
    process_name: "液置換",
    short_name: "液",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "24",
    process_name: "薬液消毒",
    short_name: "消",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "25",
    process_name: "滞留消毒",
    short_name: "滞",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "26",
    process_name: "熱水消毒",
    short_name: "熱",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "27",
    process_name: "酸洗浄",
    short_name: "酸",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "28",
    process_name: "洗浄",
    short_name: "洗",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "29",
    process_name: "排液",
    short_name: "排",
    color: "#000000",
    class: "process-state-1"
  },
  {
    process_state: "40",
    process_name: "休止",
    short_name: "休",
    color: "#000000",
    class: "process-state-1"
  },
  {
    process_state: "41",
    process_name: "洗消準備",
    short_name: "準",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "42",
    process_name: "洗消",
    short_name: "洗",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "43",
    process_name: "溶解準備",
    short_name: "準",
    color: "#008000",
    class: "process-state-3"
  },
  {
    process_state: "44",
    process_name: "溶解",
    short_name: "溶",
    color: "#008000",
    class: "process-state-3"
  },
  {
    process_state: "45",
    process_name: "原点復帰",
    short_name: "原",
    color: "#000000",
    class: "process-state-1"
  },
  {
    process_state: "46",
    process_name: "手動操作",
    short_name: "手",
    color: "#000000",
    class: "process-state-1"
  },
  {
    process_state: "47",
    process_name: "調整",
    short_name: "調",
    color: "#000000",
    class: "process-state-1"
  },
  {
    process_state: "60",
    process_name: "通常運転",
    short_name: "運",
    color: "#008000",
    class: "process-state-3"
  },
  {
    process_state: "61",
    process_name: "夜間運転",
    short_name: "夜",
    color: "#000000",
    class: "process-state-1"
  },
  {
    process_state: "62",
    process_name: "熱水消毒運転",
    short_name: "熱",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "63",
    process_name: "薬液消毒運転",
    short_name: "消",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "64",
    process_name: "強制冷却待機中",
    short_name: "冷",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "65",
    process_name: "強制洗出し待機中",
    short_name: "洗",
    color: "#00FFFF",
    class: "process-state-2"
  },

  // DRY-50A
  {
    process_state: "A0",
    process_name: "プリセット",
    short_name: "プ",
    color: "#000000",
    class: "process-state-1"
  },
  {
    process_state: "A1",
    process_name: "準備溶解",
    short_name: "準",
    color: "#008000",
    class: "process-state-3"
  },
  {
    process_state: "A2",
    process_name: "溶解",
    short_name: "溶",
    color: "#008000",
    class: "process-state-3"
  },
  {
    process_state: "A3",
    process_name: "追加溶解",
    short_name: "追",
    color: "#008000",
    class: "process-state-3"
  },
  {
    process_state: "A4",
    process_name: "溶解停止",
    short_name: "停",
    color: "#008000",
    class: "process-state-3"
  },
  {
    process_state: "A5",
    process_name: "全排液",
    short_name: "排",
    color: "#000000",
    class: "process-state-1"
  },
  {
    process_state: "A6",
    process_name: "排液溶解槽1",
    short_name: "排",
    color: "#000000",
    class: "process-state-1"
  },
  {
    process_state: "A7",
    process_name: "排液溶解槽2",
    short_name: "排",
    color: "#000000",
    class: "process-state-1"
  },
  {
    process_state: "A8",
    process_name: "全洗浄",
    short_name: "洗",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "A9",
    process_name: "洗浄溶解槽1",
    short_name: "洗",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "AA",
    process_name: "洗浄溶解槽2",
    short_name: "洗",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "AB",
    process_name: "給水管熱水洗浄",
    short_name: "熱",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "AC",
    process_name: "全消毒",
    short_name: "消",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "AD",
    process_name: "消毒溶解槽2",
    short_name: "消",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "AE",
    process_name: "調整",
    short_name: "調",
    color: "#000000",
    class: "process-state-1"
  },

  // DRY-50B
  {
    process_state: "B0",
    process_name: "プリセット",
    short_name: "プ",
    color: "#000000",
    class: "process-state-1"
  },
  {
    process_state: "B1",
    process_name: "全消毒",
    short_name: "消",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "B2",
    process_name: "全洗浄",
    short_name: "洗",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "B3",
    process_name: "溶解",
    short_name: "溶",
    color: "#008000",
    class: "process-state-3"
  },
  {
    process_state: "B4",
    process_name: "準備溶解",
    short_name: "準",
    color: "#008000",
    class: "process-state-3"
  },
  {
    process_state: "B5",
    process_name: "溶解停止",
    short_name: "停",
    color: "#008000",
    class: "process-state-3"
  },
  {
    process_state: "B6",
    process_name: "消毒溶解槽",
    short_name: "消",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "B7",
    process_name: "消毒サブタンク",
    short_name: "消",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "B8",
    process_name: "全排液",
    short_name: "排",
    color: "#000000",
    class: "process-state-1"
  },
  {
    process_state: "B9",
    process_name: "洗浄溶解槽",
    short_name: "洗",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "BA",
    process_name: "給水管熱水洗浄",
    short_name: "熱",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "BB",
    process_name: "洗浄サブタンク",
    short_name: "洗",
    color: "#00FFFF",
    class: "process-state-2"
  },
  {
    process_state: "BC",
    process_name: "調整",
    short_name: "調",
    color: "#000000",
    class: "process-state-1"
  },


  {
    process_state: "99",
    process_name: "通信異常",
    short_name: "―",
    color: "#111111",
    class: "process-state-4"
  },
  {
    process_state: "default",
    process_name: "",
    short_name: "",
    color: "#000000",
    class: "process-state-default"
  }
];
// --------------------------------------
// 自己診断結果情報の定義
// self_measure_result : 自己診断結果
// self_measure_name   : 自己診断結果名称
// short_name          : 自己診断結果略称
// --------------------------------------
//mod #10063 by zhangruixue 2024-04-08 --start
const selfMeasureResultInfos = [
  {
    self_measure_result: "G100",
    // self_measure_result: "- ",
    self_measure_name: "合格",
    short_name: "合",
    class: "self-measure-result-default"
  },
  {
    self_measure_result: "G102",
    // self_measure_result: "-  ",
    self_measure_name: "合格(注意)",
    short_name: "注",
    class: "self-measure-result-default"
  },
  {
    self_measure_result: "G101",
    // self_measure_result: "-   ",
    self_measure_name: "不合格",
    short_name: "不",
    class: "self-measure-result-default"
  },
  {
    self_measure_result: "default",
    self_measure_name: "未実施",
    short_name: "未",
    class: "self-measure-result-default"
  }
];
//mod #10063 by zhangruixue 2024-04-08 --end

export default {
  // ------------------------------------------------------------------
  // 処理：工程コード(processType)に該当する略称を取得
  //       ※工程コードに該当する情報がない場合にはデフォルトの工程情報を返却する
  // 引数：processState : 工程コード
  // 戻り値：工程に関する情報(prcessStateInfosの工程コードが一致する情報)
  // ------------------------------------------------------------------
  getProcessStateInfo(processState) {
    for (let idx = 0; idx < processStateInfos.length; idx++) {
      if (processState === processStateInfos[idx].process_state) {
        return processStateInfos[idx];
      }
    }
    return processStateInfos[processStateInfos.length - 1];
  },
  // ------------------------------------------------------------------
  // 処理：自己診断結果情報の取得
  // 引数：selfMeasureResult(自己診断結果)
  // 戻値：selfMeasureResultInfos(自己診断結果情報)該当の情報
  // 備考：selfMeasureResultInfos(自己診断結果情報)該当の情報無しの場合、デフォルト(未実施)返却
  // ------------------------------------------------------------------
  getSelfMeasureResultInfo(selfMeasureResult) {
    for (let idx = 0; idx < selfMeasureResultInfos.length; idx++) {
      if (selfMeasureResult === selfMeasureResultInfos[idx].self_measure_result) {
        return selfMeasureResultInfos[idx];
      }
    }
    return selfMeasureResultInfos[selfMeasureResultInfos.length - 1];
  },
  /**
   * 与えられたキーでのソート関数
   *
   * @param {*} a 比較対象1
   * @param {*} b 比較対象2
   * @param {String} key ソートキー
   * @param {Boolean} isAsc 昇順の場合trueを指定(デフォルト)
   * @param {Boolean} nullLast null値を後ろにソート
   */
  compareKey(a, b, key, isAsc = true, nullLast = false ) {
    a = a[key];
    b = b[key];

    let sortItem1;
    let sortItem2;

    if (a === b) {
      sortItem1 = 0;
    } else if (a > b) {
      sortItem1 = 1;
    } else {
      sortItem1 = -1;
    }
    if (isAsc) {
      sortItem2 = 1;
    } else {
      sortItem2 = -1;
    }
    if (nullLast && (a === null || b === null)) {
      return sortItem1 * sortItem2 * -1;
    } else {
      return sortItem1 * sortItem2;
    }
  },
  /**
   * 与えられたキーでのソート関数(時刻データ)
   *
   * @param {*} a 比較対象1
   * @param {*} b 比較対象2
   * @param {String} key ソートキー
   * @param {Boolean} isAsc 昇順の場合trueを指定(デフォルト)
   */
  compareTimeKey(a, b, key, isAsc = true ) {
    const timeA = dayjs(new Date(a[key]));
    const timeB = dayjs(new Date(b[key]));

    let sortItem1;
    let sortItem2;

    if (timeA.isSame(timeB)) {
      sortItem1 = 0;
    } else if (timeA.isAfter(timeB)) {
      sortItem1 = 1;
    } else {
      sortItem1 = -1;
    }
    if (isAsc) {
      sortItem2 = 1;
    } else {
      sortItem2 = -1;
    }
    return sortItem1 * sortItem2;
  }
};

/**
 * サービス対応区分情報
 *  cd : {String} サービス対応区分
 *  text : {String} ボタン表示名
 *  class: {String} 付与するクラス名
 *  dispName: {Boolean} 更新者を表示するか否か
 *                      ※更新日時の表示するか否かも兼ねる.
 */
export const SERVICE_SUPPORT = {
  // 未受付
  NOT_ACCEPTED: {
    cd: "0",
    text: "未受付",
    class: "deal-not",
    dispName: false
  },
  // 1次対応済み
  FIRST_ORDER_SUPPORTED: {
    cd: "1",
    text: "1次対応済み",
    class: "deal-not",
    dispName: true
  },
  // サービス対応済み
  SERVICE_SUPPORTED: {
    cd: "2",
    text: "サービス対応済み",
    class: "deal-already",
    dispName: true
  },
  // サービス対象外
  OUT_OF_SERVICE: {
    cd: "3",
    text: "サービス対象外",
    class: "out-of-support",
    dispName: true
  }
};

/**
 * 警報通知発生降順にソートに関する情報
 */
export const IS_ALARM_TEXT = "警報通知発生降順にソート";

