/**
 * 治療条件画面の各マスタの名称とコードを表現するクラス
 */

/**
 * 「未登録」状態かどうか（CommonMasterSelector は text: "未登録" を返す）
 * @param {Object} master
 * @returns {Boolean}
 */
export function isUnregisteredMaster(master) {
  if (!master) return false;
  const cd = master.cd;
  if (cd != null && cd !== "") return false;
  const name = master.name;
  return name === "" || name === "未登録" || name == null;
}

export class Master {
  constructor(cd = null, name = "") {
    this.cd = cd;
    this.name = name;
  }

  // 入力されていないかどうかを返す
  isEmpty() {
    return isUnregisteredMaster(this);
  }
}
