/**
 * 利用者（mst_personal_user）を表現するクラス
 */
export class PersonalUser {
  constructor(userId, lastName, firstName, hasEmailAddress1, hasEmailAddress2) {
    this.userId = userId;
    this.lastName = lastName;
    this.firstName = firstName;
    this.hasEmailAddress1 = hasEmailAddress1;
    this.hasEmailAddress2 = hasEmailAddress2;

    // メールアドレス1にメールを送るかどうか
    this._beSendEmailAddress1 = false;
    // メールアドレス2にメールを送るかどうか
    this._beSendEmailAddress2 = false;
  }

  get fullName() {
    return `${this.lastName}${this.firstName}`;
  }

  get isSendEmailAddress() {
    return this._beSendEmailAddress1 || this._beSendEmailAddress2;
  }

  get beSendEmailAddress1() {
    return this._beSendEmailAddress1;
  }

  get beSendEmailAddress2() {
    return this._beSendEmailAddress2;
  }

  set beSendEmailAddress1(beSend) {
    this._beSendEmailAddress1 = beSend;
  }

  set beSendEmailAddress2(beSend) {
    this._beSendEmailAddress2 = beSend;
  }
}
