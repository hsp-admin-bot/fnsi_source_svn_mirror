/**
 * @description 必須入力欄のCSSクラス制御用オブジェクトを生成する
 * @param {boolean} required 必須状態の初期値
 * @returns {Object} CSSクラス制御用オブジェクト
 * 使用しているクラス"input-style-required","input-style-invalid"は
 * ntss-admin-web\src\main\frontend\public\css\ntss.css
 * で定義しているので、
 * このオブジェクトで制御しようとするコンポーネントに対応したセレクタを
 * その定義に追加して、コンポーネントの:classにclassObjectを設定する
 */
export const makeRequiredClassConrtoller = (required) => {
  const makeClassObject = (required, invalid) => ({
    "input-style-required": !invalid && required,
    "input-style-invalid": invalid,
  });
  const updateClassObject = (current, required, invalid) => {
    const newObject = makeClassObject(required, invalid);
    if (
      current["input-style-required"] === newObject["input-style-required"]
      && current["input-style-invalid"] === newObject["input-style-required"]
    ) {
      return current;
    }
    return newObject;
  };
  const controller = {
    /** 対象のコンポーネントの:classに設定するオブジェクト */
    classObject: makeClassObject(required, false),
    /** 必須状態を設定する */
    setRequired: (newValue) => {
      controller.classObject = updateClassObject(controller.classObject, newValue, false);
    },
    /** 入力エラー状態を設定する */
    setInvalid: (newValue) => {
      controller.classObject = updateClassObject(controller.classObject, controller.classObject["input-style-required"] || controller.classObject["input-style-invalid"], newValue);
    },
    destroy: () => {
      // オブジェクト内の循環参照を解除する
      delete controller.setRequired;
      delete controller.setInvalid;
    },
  };
  return controller;
};
