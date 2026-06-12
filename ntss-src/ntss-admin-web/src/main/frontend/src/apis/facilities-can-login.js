/**
 * 施設系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

export function getCanLoginFacilities(facilityCd) {
  return ApiHelper.get(`/user/getCanLoginFacilities/${facilityCd}`);
}

export function getInfoRetrieve(data) {
  return ApiHelper.post("/authentication/check_login", data);
}

export function getInfoOPT(data) {
  return ApiHelper.put(
    `/authentication/check_otp/${data.opt}/${data.secretKey}?facilityHash=${data.facilityHash}`
  );
}
