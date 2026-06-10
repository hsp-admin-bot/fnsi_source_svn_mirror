/**
 * 参照型コンボAPI
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import store from "@/stores";

/**
 * 参照型コンボのデータ取得
 * @param {*} masterPhysicalName マスタ物理名
 * @param {*} textColumnPhysicalName コンボに出すテキストの物理カラム名
 * @param {*} cdColumnPhysicalName 主キーの物理カラム名
 */
export function sendRequestGetComboList(
  masterPhysicalName,
  textColumnPhysicalName,
  cdColumnPhysicalName
) {
  store.dispatch("loading-screen/startLoadingScreen");
  return ApiHelper.get(
    `/combo/${masterPhysicalName}/${textColumnPhysicalName}/${cdColumnPhysicalName}`
  ).finally(() => {
    store.dispatch("loading-screen/finishLoadingScreen");
  });
}
// add マスタ一覧 1･施設切替を可能とする 孔s start
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
// add マスタ一覧 1･施設切替を可能とする 孔s end
