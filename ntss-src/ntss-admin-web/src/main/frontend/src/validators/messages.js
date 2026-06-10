// vee-validatorのメッセージを上書きする必要がある場合はこちらに記載してください

export default {
  locale: "ja",
  dictionary: {
    ja: {
      // デフォルトのメッセージを変えたい場合は、こちらに追加してください。
      messages: {
        max: (field, [length]) => `${length}文字以内で入力してください。`,
        required: () => `必須項目が入力されていません。`,
        regex: () => `入力形式に誤りがあります。`,
        date_format: () => `入力形式に誤りがあります。`,
        numeric: () => `入力形式に誤りがあります。`,
        confirmed: field => `${field}が一致しません。`
      },
      custom: {
        // 入力項目ごとに変えたい場合は、こちらに追加してください。
        // #sample
        // id: {
        //   required: 'IDは必須です',
        //   regex: 'IDが間違っています',
        // },
      }
    }
  }
};
