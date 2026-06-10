/**
 * 治療条件画面の各マスタの名称とコードを表現するクラス
 */

export class Master {
  constructor(cd = null, name = "") {
    this.cd = cd;
    this.name = name;
  }

  // 入力されていないかどうかを返す
  isEmpty() {
    return this.cd === null && this.name === "";
  }
}
