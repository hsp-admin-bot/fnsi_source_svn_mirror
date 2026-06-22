/** 点検項目の用途 */
export const MainteClass = Object.freeze({
  /** 日常点検 */
  Daily: "1",
  /** 定期点検 */
  Periodic: "2",
});

/** 用途の選択肢リスト */
export const MainteClassList = Object.freeze([
  { text: "日常点検", value: MainteClass.Daily },
  { text: "定期点検", value: MainteClass.Periodic },
]);

/** 点検結果の値 */
export const Answer = Object.freeze({
  /** ダミー値（対象外） */
  Dummy: "-1",
  /** 未実施（DB格納時のnull値） */
  NotDateForDb: null,
  /** 未実施 */
  NotDate: "",
  /** 合格 */
  Good: "1",
  /** 点検途中 */
  Running: "2",
  /** 不合格 */
  NotGood: "3",
});
/** 点検結果の表示文字列 */
export const StatusText = Object.freeze({
  /** 未実施 */
  NotDate: "",
  /** 合格 */
  Good: "合格",
  /** 点検途中 */
  Running: "点検途中",
  /** 不合格 */
  NotGood: "不合格",
});

/** 定期点検のレイアウトグループコードのダミー値 */
export const InvalidLayoutGroupCd = 0;
