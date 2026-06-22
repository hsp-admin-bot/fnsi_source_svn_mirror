import store from "@/stores";
import { getScopedWindow } from "@/functions/common/LayoutMeasureHelper";

/** 外部リンクメニューマスタのURLに入れるパラメータ項目のenum */
export const URL_PARAMS = {
  PAT_ID: "患者ID",
  USER_ID: "ユーザーID",
};

const nameToText = (name) => `【${name}】`;
const makeItem = (name) => ({
  name,
  text: nameToText(name),
});

/** 外部リンクメニューマスタのURLに入れるパラメータ項目の名称と置き換え用文字列の配列 */
export const UrlLinkParameters = Object.values(URL_PARAMS).map(makeItem);

const getPatientId = () => {
  const selectedPat = store.getters["pat-info/selectedPat"];
  return selectedPat ? selectedPat.pat_personal_main.hosp_pat_id : "";
};
const getUserId = () => {
  const userAccountInfo = store.getters["account-edit/getStateUserAccountInfo"];
  return userAccountInfo.dispUserId;
};

/**
 * @description 外部リンクメニューのURLを生成するasync関数
 * 外部リンクメニューマスタで登録したURLの
 * パラメータ項目を最終的な値に置き換えたURLを返す
 * @param {string} linkUrl 外部リンクメニューマスタで登録したURL
 * @returns {Promise<string>} パラメータ項目を最終的な値に置き換えたURLを返すPromise
 */
export const replacePrameters = async (linkUrl) => {
  // 置き換える項目と値の設定配列
  // 項目としてはURL_PARAMSの要素を利用する
  // 値としては最終的な値を返す関数やPromise、Promiseを返す関数も設定可能
  // （getValueによって関数やPromise以外の値が取得されるまで再帰処理される）
  // 最終的な値を返す関数を設定する形にしておくことで
  // そのパラメータが使われている場合にのみ値を取得する処理が実行されるようになり、
  // 値を取得する処理コストの無駄をなくすことができる
  const infoTable = [
    [URL_PARAMS.PAT_ID, getPatientId],
    [URL_PARAMS.USER_ID, getUserId],
  ];
  while (infoTable.length) {
    const [name, getter] = infoTable.shift();
    const text = nameToText(name);
    if (linkUrl.indexOf(text) < 0) continue;
    const value = await getValue(getter);
    linkUrl = linkUrl.replaceAll(text, value);
  }
  return linkUrl;
};
const getValue = async (getter) => {
  if (typeof getter === "function") {
    return await getValue(getter());
  }
  if (getter instanceof Promise) {
    return await getValue(await getter);
  }
  return getter;
};

function openScopedUrlWindow(replacedLinkUrl, windowName, root = null) {
  const scopedWindow = getScopedWindow(root);
  const openedWindow = scopedWindow?.open?.("", windowName, "width=800,height=400") || null;
  if (openedWindow?.location) {
    openedWindow.location.href = replacedLinkUrl;
  }
  return openedWindow;
}

const staticData = {
  /** openUrlLinkTestで開いたwindow */
  urlLinkTest: null,
  /** openUrlLinkRegisterで開いたwindow */
  urlLinkRegister: null,
};

/**
 * @description 外部リンクメニューのブラウザウィンドウを開く関数（マスタメンテでのテスト用）
 * （外部リンクメニューマスタのテスト機能で）
 * パラメータ項目を最終的な値に置き換えたURLを渡して
 * ブラウザウィンドウを開く
 * @param {string} replacedLinkUrl パラメータ項目を最終的な値に置き換えたURL
 */
export const openUrlLinkTest = (replacedLinkUrl, root = null) => {
  if (staticData.urlLinkRegister) {
    staticData.urlLinkRegister.close();
    staticData.urlLinkRegister = null;
  }
  staticData.urlLinkTest = openScopedUrlWindow(replacedLinkUrl, "myWindowLinkTest", root);
};
/**
 * @description 外部リンクメニューのブラウザウィンドウを開くasync関数（フッターメニューボタン用）
 * 外部リンクメニューマスタで登録したURLを渡して
 * パラメータ項目を最終的な値に置き換えたURLでブラウザウィンドウを開く
 * @param {string} linkUrl 外部リンクメニューマスタで登録したURL
 * @returns {Promise<void>} ブラウザウィンドウを開くPromise
 */
export const openUrlLinkRegister = async (linkUrl, root = null) => {
  if (staticData.urlLinkTest) {
    staticData.urlLinkTest.close();
    staticData.urlLinkTest = null;
  }
  const replacedLinkUrl = await replacePrameters(linkUrl);
  staticData.urlLinkRegister = openScopedUrlWindow(replacedLinkUrl, "myWindowLinkRegister", root);
};
