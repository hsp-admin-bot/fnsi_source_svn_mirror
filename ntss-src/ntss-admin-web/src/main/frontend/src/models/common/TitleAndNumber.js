/**
 * タイトルと数値を表現するクラス
 */

export class TitleAndNumber {
  constructor(title = "", value = null) {
    this.title = title;
    this.value = value;
  }

  /**
   * クローンする.
   */
  clone() {
    return new TitleAndNumber(this.title, this.value);
  }
}
