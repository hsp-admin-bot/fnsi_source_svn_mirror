import { ApiHelper } from "@/apis/AxiosHelper";

const LAYOUTCLASS = 2;

/**
 * 型式マスタ全件取得
 */
export function sendRequestGetMachineTypeList() {
  return ApiHelper.get("mente-main/getMachineTypeList");
}

/**
 * 装置マスタで設定されているもののみに絞った
 * 型式マスタリストの取得
 */
export function sendRequestGetAllMachineByFacilityCd(facilityCd) {
  return ApiHelper.get(`mente-layout/machine-types/all/data/${facilityCd}`);
}

export function sendRequestGetAllCategoryByFacilityCd(facilityCd) {
  return ApiHelper.get(`mente-category/getAll/data/${facilityCd}`);
}

export function senRequestGetListLayoutByLayoutClassAndFacilityCd(facilityCd) {
  return ApiHelper.get(`mente-layout/${LAYOUTCLASS}/data/${facilityCd}`);
}
