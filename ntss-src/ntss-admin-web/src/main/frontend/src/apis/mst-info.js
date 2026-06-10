import { ApiHelper } from "@/apis/AxiosHelper";
import store from "@/stores";
export function getMstInfo({ reqMstNamesArr }) {
  const facilityCd = store.state.user.facilityCd;
  store.dispatch("loading-screen/startLoadingScreen");
  return ApiHelper.get(`mstInfo/getMstInfo`, {
    facilityCd: facilityCd,
    reqMstNames: reqMstNamesArr.join(",")
  }).finally(() => {
    store.dispatch("loading-screen/finishLoadingScreen");
  }).catch(() => {
    store.dispatch("loading-screen/finishLoadingScreen");
  });
}


//liyanze-z #12462 add api start
export function getMstOtherInfo(reqMstNamesArr,patId) {
  const facilityCd = store.state.user.facilityCd;
  store.dispatch("loading-screen/startLoadingScreen");
  return ApiHelper.get(`mstInfo/getShrMstInfoByPatId`, {
    facilityCd: facilityCd,
    reqMstNames: reqMstNamesArr.join(","),
    patId:patId
  }).finally(() => {
    store.dispatch("loading-screen/finishLoadingScreen");
  }).catch(() => {
    store.dispatch("loading-screen/finishLoadingScreen");
  });
}
//liyanze-z #12462 add api end

/* add by chamaojia 2026-02-11 [11893] キャッシュ軽減対応 --start */
export function getMstInfoByPatId({ patId }) {
  const facilityCd = store.state.user.facilityCd;
  store.dispatch("loading-screen/startLoadingScreen");
  return ApiHelper.get(`mstInfo/getMstInfoByPatId`, {
    facilityCd: facilityCd,
    patId: patId
  }).finally(() => {
    store.dispatch("loading-screen/finishLoadingScreen");
  }).catch(() => {
    store.dispatch("loading-screen/finishLoadingScreen");
  });
}
/* add by chamaojia 2026-02-11 [11893] キャッシュ軽減対応 --end */
