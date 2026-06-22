import { ApiHelper } from "@/apis/AxiosHelper";

function withSelectedPatId(params, selectedPatId) {
  if (selectedPatId === null || selectedPatId === undefined || selectedPatId === "") {
    return params;
  }
  return {
    ...params,
    selectedPatId
  };
}

export function list(facilityCd, selectedPatId) {
  return ApiHelper.get("/pat_group", withSelectedPatId({ facility_cd: facilityCd }, selectedPatId));
}

export function get({ facilityCd, patGroupCd }) {
  return ApiHelper.get("/pat_group/pat_group", {
    facility_cd: facilityCd,
    pat_group_cd: patGroupCd
  });
}

export function create({ facilityCd, patGroupName, patIds }) {
  return ApiHelper.post("/pat_group/create", {
    pat_group: JSON.stringify({
      facilityCd,
      patGroupName
    }),
    pat_list_detail: JSON.stringify({
      patList: patIds
    })
  });
}

export function update({ patGroupCd, facilityCd, patGroupName, patIds }) {
  return ApiHelper.put(`/pat_group/pat_group_id/${patGroupCd}`, {
    pat_group: JSON.stringify({
      facilityCd,
      patGroupName
    }),
    pat_list_detail: JSON.stringify({
      patList: patIds
    })
  });
}

export function remove(patGroupCd) {
  return ApiHelper.put(`/pat_group/pat_group_d/${patGroupCd}`);
}

export function getByPatId(patId) {
  return ApiHelper.get("/pat_group/pat", {
    pat_id: patId
  });
}

export function updateByPatId({ patId, patGroupCds }) {
  return ApiHelper.put(`/pat_group/pat_group_pat_id/${patId}`, {
    pat_group_detail: JSON.stringify({
      patGroupList: patGroupCds
    })
  });
}

export function updateMstSelector(facilityCd, patGroupList) {
  return ApiHelper.put(`/pat_group/mst_selector/${facilityCd}`, patGroupList);
}

export function updatePatGroupList(facilityCd, patGroupList) {
  return ApiHelper.put(`/pat_group/pat_group_list/${facilityCd}`, patGroupList);
}

const patGroupApi = {
  list,
  get,
  create,
  update,
  remove,
  getByPatId,
  updateByPatId,
  updateMstSelector,
  updatePatGroupList
};

export default patGroupApi;
