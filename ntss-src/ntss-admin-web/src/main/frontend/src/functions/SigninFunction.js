import {LOCAL_STORAGE_KEY} from "@/constants/localStorageConstants";
import {sendRequestDeleteSignin} from "@/apis/User";
import {FAVICON_PATH} from "@/constants/sysUseConstants";
import { publicAssetPath } from "@/compat/assets/public-path";
import { ensureHeadLink } from "@/compat/assets/head";
import { getScopedLocalStorage } from "@/functions/common/LayoutMeasureHelper";

const DEFAULT_SYSTEM_USE_SETTING = 0;
const FAVICON_SIZES = ["32x32", "16x16"];

/**
 * 端末固有文字列を作成し、LocalStorageに格納し返却する.
 * 既に端末固有文字列が登録済の場合、LocalStorageには登録せず、
 * 登録されている端末固有文字列を返却する.
 *
 * @returns string
 */
export function createTerminalUniqueString(root = null) {
  const scopedLocalStorage = getScopedLocalStorage(root);
  // LocalStorageから
  let terminalUniqueString =
    scopedLocalStorage.getItem(LOCAL_STORAGE_KEY.TERMINAL_UNIQUE_STRING);

  if (terminalUniqueString === null) {
    // 未保存時は端末固有文字列を生成し、ローカルストレージにセットしてその後の処理を実行
    terminalUniqueString = new Date().getTime().toString(16) + Math.floor(1000 * Math.random()).toString(16);
    scopedLocalStorage.setItem(LOCAL_STORAGE_KEY.TERMINAL_UNIQUE_STRING, terminalUniqueString);
  }
  return terminalUniqueString;
}

/**
 * サインイン管理から削除.
 * ※LocalStorageに格納されているサインイン回数が0以下の場合に削除する.
 */
export const deleteSignin = async (root = null) => {
  const scopedLocalStorage = getScopedLocalStorage(root);
  // LocalStorageからサインインカウントを取得
  const signInCount = scopedLocalStorage.getItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT);
  // サインインカウントが0より大きい場合は何もしない
  // ※サインインされていると判断
  if (signInCount > 0) {
    return;
  }
  // サインインカウントが0以下若しくは登録されていない場合、
  // サインイン管理テーブルから端末固有文字列をキーに削除
  await sendRequestDeleteSignin(createTerminalUniqueString(root));
}

function resolveSystemUseSetting(systemUseSetting) {
  return Object.prototype.hasOwnProperty.call(FAVICON_PATH, systemUseSetting)
    ? systemUseSetting
    : DEFAULT_SYSTEM_USE_SETTING;
}

function getFaviconPath(systemUseSetting) {
  const resolvedSystemUseSetting = resolveSystemUseSetting(systemUseSetting);
  return publicAssetPath(FAVICON_PATH[resolvedSystemUseSetting] || FAVICON_PATH[DEFAULT_SYSTEM_USE_SETTING]);
}

/**
 * システム利用設定別のfaviconをセットする
 */
export function updateFavicons(systemUseSetting, root = null) {
  const faviconPath = getFaviconPath(systemUseSetting);

  FAVICON_SIZES.forEach(size => {
    ensureHeadLink({ rel: "icon", sizes: size, href: faviconPath, root });
  });
}
