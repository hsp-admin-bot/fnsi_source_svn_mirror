/**
 * 施設系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 使用可能機能取得.
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetUseFunctions(facilityCd) {
  return ApiHelper.get(`/facilities/${facilityCd}/use-functions`);
}

/**
 * 個人設定タブ定義取得.
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetPersonalTabDefine(facilityCd) {
  return ApiHelper.get(`/facilities/${facilityCd}/personal-setting/tab/define`);
}

/**
 * 医師リスト取得.
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetDoctorsAtFacility(facilityCd) {
  return ApiHelper.get(`/facilities/${facilityCd}/personal-user/job/doctor`);
}

// add #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc start
/**
 * 医師リスト取得.
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetDoctorsAtFacilityIncludeDel(facilityCd) {
  return ApiHelper.get(`/facilities/${facilityCd}/personal-user/job/doctorIncludeDel`);
}
// add #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc end

/**
 * 指定IDの施設マスタ取得.
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetMstFacilityByCd(facilityCd) {
  return ApiHelper.get(`/mstInfo/mstFacility/${facilityCd}`);
}

/**
 * 指定施設コードハッシュ値に該当する施設の、施設設定：2要素認証失敗許容回数を取得.
 * @param {string} hash 施設コードハッシュ値
 */
export function sendRequestGetOtpFailureCntByHash(hash) {
  const params = { hashValue: hash };
  return ApiHelper.get("/facilities/MstFacilityHash/OtpFailureCnt/hash", params);
}

