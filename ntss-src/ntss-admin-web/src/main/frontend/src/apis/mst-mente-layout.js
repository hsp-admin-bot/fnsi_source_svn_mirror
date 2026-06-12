/**
 * 点検レイアウトマスタ（mente-layout）系 API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/** レイアウトクラス（日常点検レイアウト一覧用） */
const LAYOUT_CLASS_DAILY = 2;

/**
 * 型式マスタ全件取得
 */
export function sendRequestGetMachineTypeList() {
  return ApiHelper.get("mente-main/getMachineTypeList");
}

/**
 * 施設に紐づく装置型式一覧取得
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetAllMachineByFacilityCd(facilityCd) {
  return ApiHelper.get(`mente-layout/machine-types/all/data/${facilityCd}`);
}

/**
 * 施設に紐づく点検カテゴリ一覧取得
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetAllCategoryByFacilityCd(facilityCd) {
  return ApiHelper.get(`mente-category/getAll/data/${facilityCd}`);
}

/**
 * レイアウトクラス・施設に応じたレイアウト一覧取得
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetListLayoutByLayoutClassAndFacilityCd(facilityCd) {
  return ApiHelper.get(
    `mente-layout/${LAYOUT_CLASS_DAILY}/data/${facilityCd}`
  );
}


/** @deprecated 旧名のタイポ互換。{@link sendRequestGetListLayoutByLayoutClassAndFacilityCd} を使用 */
export const senRequestGetListLayoutByLayoutClassAndFacilityCd = sendRequestGetListLayoutByLayoutClassAndFacilityCd;
