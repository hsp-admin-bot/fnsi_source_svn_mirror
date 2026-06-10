import { ApiHelper } from "@/apis/AxiosHelper";

export default {
  list(facilityCd) {
    return ApiHelper.get("/pat_group", { facility_cd: facilityCd });
  },
  get({ facilityCd, patGroupCd }) {
    return ApiHelper.get("/pat_group/pat_group", {
      facility_cd: facilityCd,
      pat_group_cd: patGroupCd
    });
  },
  create({ facilityCd, patGroupName, patIds }) {
    return ApiHelper.post("/pat_group/create", {
      pat_group: JSON.stringify({
        facilityCd,
        patGroupName
      }),
      pat_list_detail: JSON.stringify({
        patList: patIds
      })
    });
  },
  update({ patGroupCd, facilityCd, patGroupName, patIds }) {
    return ApiHelper.put(`/pat_group/pat_group_id/${patGroupCd}`, {
      pat_group: JSON.stringify({
        facilityCd,
        patGroupName
      }),
      pat_list_detail: JSON.stringify({
        patList: patIds
      })
    });
  },
  remove(patGroupCd) {
    return ApiHelper.put(`/pat_group/pat_group_d/${patGroupCd}`);
  },
  getByPatId(patId) {
    return ApiHelper.get("/pat_group/pat", {
      pat_id: patId
    });
  },
  updateByPatId({ patId, patGroupCds }) {
    return ApiHelper.put(`/pat_group/pat_group_pat_id/${patId}`, {
      pat_group_detail: JSON.stringify({
        patGroupList: patGroupCds
      })
    });
  },
  updateMstSelector(facilityCd, patGroupList) {
    return ApiHelper.put(`/pat_group/mst_selector/${facilityCd}`, patGroupList);
  },
  // 患者グループ一覧の更新
  updatePatGroupList(facilityCd, patGroupList) {
    return ApiHelper.put(`/pat_group/pat_group_list/${facilityCd}`, patGroupList);
  }
};
