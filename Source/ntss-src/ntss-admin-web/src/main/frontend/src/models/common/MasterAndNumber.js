/**
 * マスタ選択値と数値を表現するクラス
 */

export class MasterAndNumber {
  constructor(cd = null, name = "", value = null) {
    this.cd = cd;
    this.name = name;
    this.value = value;
  }

  /**
   * クローンする.
   */
  clone() {
    return new MasterAndNumber(this.cd, this.name, this.value);
  }

  // 入力されていないかどうかを返す
  isEmpty() {
    return this.cd === null && this.name === "" && this.value === null;
  }
}
