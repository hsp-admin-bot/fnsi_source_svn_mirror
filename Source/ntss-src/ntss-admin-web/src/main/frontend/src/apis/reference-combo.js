/**
 * コンボボックス用マスタ取得API
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import store from "@/stores";

const URL_BASE = "/reference_combo";

function withSelectedPatId(params = undefined, selectedPatId) {
  if (selectedPatId === null || selectedPatId === undefined || selectedPatId === "") {
    return params;
  }
  return {
    ...(params || {}),
    selectedPatId
  };
}

/**
 * コンボボックス用マスタを取得
 * @param {string} facilityCd 施設コード
 * @param {string} classCd クラスコード
 */
export function sendRequestGetReferenceCombo(facilityCd, classCd) {
  return ApiHelper.get(`${URL_BASE}/${facilityCd}/${classCd}`);
}

/**
 * 参照型コンボのデータ取得（vue2 / ReferenceComboStore 互換）
 * @param {string} masterPhysicalName マスタ物理名
 * @param {string} textColumnPhysicalName コンボに出すテキストの物理カラム名
 * @param {string} cdColumnPhysicalName 主キーの物理カラム名
 */
export function sendRequestGetComboList(
  masterPhysicalName,
  textColumnPhysicalName,
  cdColumnPhysicalName,
  selectedPatId
) {
  store.dispatch("loading-screen/startLoadingScreen");
  return ApiHelper.get(
    `/combo/${masterPhysicalName}/${textColumnPhysicalName}/${cdColumnPhysicalName}`,
    withSelectedPatId(undefined, selectedPatId)
  ).finally(() => {
    store.dispatch("loading-screen/finishLoadingScreen");
  });
}

/**
 * 参照型コンボのデータ取得（施設コード指定・vue2 互換）
 */
export function sendRequestGetComboListByFacilityCd(
  masterPhysicalName,
  textColumnPhysicalName,
  cdColumnPhysicalName,
  facilityCd
) {
  return ApiHelper.get(
    `/combo/${masterPhysicalName}/${textColumnPhysicalName}/${cdColumnPhysicalName}/${facilityCd}`
  );
}
