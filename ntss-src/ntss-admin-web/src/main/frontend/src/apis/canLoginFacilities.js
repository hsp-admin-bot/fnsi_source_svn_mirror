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
  return ApiHelper.put(`/authentication/check_otp/${data.opt}/${data.secretKey}`);
}

export function sendRequestInsertPatExamMainOneOrder(setParam) {
  return ApiHelper.post(`${URL_BASE}/examMain/insertOneOrder`, {
    patId: setParam.patId,
    facilityCd: setParam.facilityCd,
    regExamDate: setParam.regExamDate,
    regOrderClass: setParam.regOrderClass,
    ordNo: setParam.ordNo,
    resultExamDate: setParam.resultExamDate,
    examResultInfo: setParam.examResultInfo,
    regStaff: setParam.staff,
    updStaff: setParam.staff
  });
}
