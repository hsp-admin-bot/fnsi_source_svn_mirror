// ユーザーID用の英字/数字/記号のバリデーションルール
export default {
  getMessage: () => `入力形式に誤りがあります。`,
  validate: value => {
    const regex = new RegExp("^[a-zA-Z0-9&%$#@_-]+$");
    return regex.test(value);
  }
};
