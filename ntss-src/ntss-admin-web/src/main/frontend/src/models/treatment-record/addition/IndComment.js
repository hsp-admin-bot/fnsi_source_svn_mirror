import { CODES } from "@/constants/TreatmentRecord";

/**
 * 指示コメント画面の指示コメントを表現するクラス
 */
export class IndComment {
  constructor(
    no = null,
    inputClass = null,
    comment = null,
    isEditable = false
  ) {
    this.isDel = false;
    this.no = no;
    this.inputClass = inputClass;
    this.comment = comment;
    this.isEditable = isEditable;
  }

  /**
   * 登録区分を表示用名称に変換して返す.
   */
  get displayInputClass() {
    const inputClasses = CODES.COMMENT_INPUT_CLASS;
    for (let key in inputClasses) {
      if (inputClasses[key].cd === this.inputClass) {
        return inputClasses[key].text;
      }
    }
    return "";
  }
}
