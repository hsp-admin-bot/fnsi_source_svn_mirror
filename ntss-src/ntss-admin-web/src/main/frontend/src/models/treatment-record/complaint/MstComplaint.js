/**
 * 愁訴選択ポップオーバー用のモデルクラス
 */
export class MstComplaint {
  constructor(cd = null, name = "") {
    this.cd = cd;
    this.name = name;
  }

  // 入力されているかどうかを返す
  isEmpty() {
    return this.cd === null && !this.name;
  }

  /**
   * 検索用文字列取得.
   */
  get searchText() {
    return this.name;
  }
}
