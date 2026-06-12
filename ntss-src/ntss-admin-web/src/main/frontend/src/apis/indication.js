import { ApiHelper } from "@/apis/AxiosHelper";

export async function list(condition = {}) {
  const res = await ApiHelper.post("/mainData/getOrdSearchResult", condition);
  return res.data;
}

export async function getIndicationDetail(ordNo) {
  const [ordMainRes, patIndApproveRes] = await Promise.all([
    ApiHelper.get(`/mainData/getOrdMainByOrdNo/${ordNo}`),
    ApiHelper.get(`/patIndApprove/${ordNo}`)
  ]);

  return [
    ordMainRes.data,
    //#10407:変更なしでも画面を表示させる Start
    patIndApproveRes.data.pat_ind_approve != undefined
      ? JSON.parse(patIndApproveRes.data.pat_ind_approve)
      : null
    //#10407:変更なしでも画面を表示させる End
  ];
}

export function check(ordNo, { checker1Id, checker2Id, checkContent }) {
  return ApiHelper.put(`/patIndApprove/check/${ordNo}`, {
    pat_ind_approve: JSON.stringify({
      check_user1_cd: checker1Id,
      check_user2_cd: checker2Id,
      check_content: checkContent
    })
  });
}

export function check1(param) {
  return ApiHelper.put(`/patIndApprove/check1`, {
    pat_ind_approve: JSON.stringify(param)
  });
}

export function check2(param) {
  return ApiHelper.put(`/patIndApprove/check2`, {
    pat_ind_approve: JSON.stringify(param)
  });
}

export function approve(ordNo, { approver1Id, approver2Id, approveContent }) {
  return ApiHelper.put(`/patIndApprove/approve/${ordNo}`, {
    pat_ind_approve: JSON.stringify({
      approve_user1_cd: approver1Id,
      approve_user2_cd: approver2Id,
      approve_content: approveContent
    })
  });
}

export function approve1(param) {
  return ApiHelper.put(`/patIndApprove/approve1`, {
    pat_ind_approve: JSON.stringify(param)
  });
}

export function approve2(param) {
  return ApiHelper.put(`/patIndApprove/approve2`, {
    pat_ind_approve: JSON.stringify(param)
  });
}


export function uncheck1(ordNo) {
  return ApiHelper.put(`/patIndApprove/uncheck1/${ordNo}`);
}

export function uncheck2(ordNo) {
  return ApiHelper.put(`/patIndApprove/uncheck2/${ordNo}`);
}

export function unapprove1(ordNo) {
  return ApiHelper.put(`/patIndApprove/unapprove1/${ordNo}`);
}

export function unapprove2(ordNo) {
  return ApiHelper.put(`/patIndApprove/unapprove2/${ordNo}`);
}

export async function searchList(condition = {}) {
  const res = await ApiHelper.post("/indHistory/searchList", condition);
  return res.data;
}

export async function updIndHistoryList(param = {}) {
  const res = await ApiHelper.post("/indHistory/updIndHistoryList", param);
  return res.data;
}

export async function searchDetail(param = {}) {
  const res = await ApiHelper.post("/indHistory/searchDetail", param);
  return res.data;
}

export async function updIndHistoryDetail(param = {}) {
  const res = await ApiHelper.post("/indHistory/updIndHistoryDetail", param);
  return res.data;
}

export async function insertPatIndApproveHistory(param = {}) {
  const res = await ApiHelper.post("/patIndApproveHistory", param);
  return res.data;
}

export async function bulkCheckOrApprove(param = {}) {
  const res = await ApiHelper.post("/patIndApprove/bulkCheckOrApprove", param);
  return res.data;
}

// add FNSI-改修内容 治療単位の治療方法マスタの有効項目に応じた表示 dou start
export async function getTreatmentConditionSetting(facilityCd, treatMethodName) {
  const treatmentConditionSetting = await ApiHelper.get(
    `/indication-result/getTreatmentConditionSetting/${facilityCd}/${treatMethodName}`
  );
  return treatmentConditionSetting.data;
}
// add FNSI-改修内容 治療単位の治療方法マスタの有効項目に応じた表示 dou end

const indicationApi = {
  list,
  getIndicationDetail,
  check,
  check1,
  check2,
  approve,
  approve1,
  approve2,
  uncheck1,
  uncheck2,
  unapprove1,
  unapprove2,
  searchList,
  updIndHistoryList,
  searchDetail,
  updIndHistoryDetail,
  insertPatIndApproveHistory,
  bulkCheckOrApprove,
  getTreatmentConditionSetting
};

export default indicationApi;
