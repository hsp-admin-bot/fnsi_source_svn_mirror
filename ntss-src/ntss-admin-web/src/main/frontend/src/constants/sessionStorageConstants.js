
/* add by chamaojia 2022-12-06 [5958] SessionStorage用の定数ファイル --start */
/**
 * SessionStorage用の定数ファイル
 */
export const SESSION_STORAGE_KEY = {
  /**
   * リフレッシュ判定フラグ
   * リフレッシュ前の変更:1 更新後の変更:9
   */
  REFRESH_FLAG: "refresh-flag",
  /**
   * Storeクリアフラグ
   * LoginViewの開始時にStore状態のクリアが必要:"1" それ以外:""
   */
  NEEDS_CLEAN_STORE_BEFORE_SIGN_IN: "needs-clean-store-before-sign-in",
  /**
   * 背景色のカラーコード
  */
  BACKGROUND_COLOR_CODE: "background-color-code",
};
/* add by chamaojia 2022-12-06 [5958] SessionStorage用の定数ファイル --end */
export const SESSION_STORAGE_VALUE = {
  NEEDS_CLEAN_STORE_BEFORE_SIGN_IN: {
    TRUE: "1",
    FALSE: "",
  },
};
