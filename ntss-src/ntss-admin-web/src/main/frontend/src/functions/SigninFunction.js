import {LOCAL_STORAGE_KEY} from "@/constants/localStorageConstants";
import {sendRequestDeleteSignin} from "@/apis/User";
import {FAVICON_PATH} from "@/constants/sysUseConstants";

/**
 * 端末固有文字列を作成し、LocalStorageに格納し返却する.
 * 既に端末固有文字列が登録済の場合、LocalStorageには登録せず、
 * 登録されている端末固有文字列を返却する.
 *
 * @returns string
 */
export function createTerminalUniqueString() {
  // LocalStorageから
  let terminalUniqueString =
    localStorage.getItem(LOCAL_STORAGE_KEY.TERMINAL_UNIQUE_STRING);

  if (terminalUniqueString === null) {
    // 未保存時は端末固有文字列を生成し、ローカルストレージにセットしてその後の処理を実行
    terminalUniqueString = new Date().getTime().toString(16) + Math.floor(1000 * Math.random()).toString(16);
    localStorage.setItem(LOCAL_STORAGE_KEY.TERMINAL_UNIQUE_STRING, terminalUniqueString);
  }
  return terminalUniqueString;
}

/**
 * サインイン管理から削除.
 * ※LocalStorageに格納されているサインイン回数が0以下の場合に削除する.
 */
export const deleteSignin = async () => {
  // LocalStorageからサインインカウントを取得
  const signInCount = localStorage.getItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT);
  // サインインカウントが0より大きい場合は何もしない
  // ※サインインされていると判断
  if (signInCount > 0) {
    return;
  }
  // サインインカウントが0以下若しくは登録されていない場合、
  // サインイン管理テーブルから端末固有文字列をキーに削除
  await sendRequestDeleteSignin(createTerminalUniqueString());
}

/**
 * システム利用設定別のfaviconをセットする
 */
export function updateFavicons(systemUseSetting) {
  const sizes = ["32x32", "16x16"];
  
  sizes.forEach(size => {
    let favicon = document.querySelector(`link[rel="icon"][sizes="${size}"]`);
    if (!favicon) {
      favicon = document.createElement("link");
      favicon.rel = "icon";
      favicon.sizes = size;
      document.head.appendChild(favicon);
    }
    favicon.href = FAVICON_PATH[systemUseSetting];
  });
}
