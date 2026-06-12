import { normalizeMenteDate } from "@/functions/periodic-inspection/PeriodicInspectionDateUtil";
import {
  sendRequestGetMachineSearchResult,
  sendRequestCreateMentePlan,
  sendRequestCreateMenteTemp,
  sendRequestGetAllLayout,
  sendRequestGetAllLayoutGroup,
  sendRequestLayoutGroupByMachineType,
  sendRequestGetAllUserInforMation,
  sendRequestGetDetailForMaster,
  sendRequestGetDetailGetDetailResult,
  sendRequestUpdateMente,
} from "@/apis/periodic-inspection";
import { deepCopy } from "@/functions/common/CommonFunctions";

export default {
  namespaced: true,
  strict: true,
  state: {
    isReadyToSearchByParam: false,
    layoutList: [],
    layoutGroupList: [],
    layoutGroupListByMachineType: [],
    listListPeriodic: [],
    listMachine: [],
    listMachineSelect: [],
    listDataMaster: [],
    listDataTemp: [],
    paramsGetDetail: null,
    listUser: [],
    dataForShowDetail: {
      inspectInfor: {
        recNo: 0,
      },
      machineInfor: {
        machineType: "",
      },
    },
    machine: {
      facilityCd: null,
      machineTypeCd: null,
      machineSerial: null,
    },
    beforeModel:{
      name: null,
      data: {},
    },
    paramsCalendar: {},
    periodicResultDetail: null,
    paramOpenFirstPeriodic: null,
    selectedCondition: null,
    searchedMachineList: [],
    historyParams: {},
    simlpSearchQurey: {},
    // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
    isOpenBySubView: false,
    isOpenByHistoryView: false,
    // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
  },
  getters: {
    getSelectedCondition(state) {
      return state.selectedCondition;
    },
    getSearchedMachineList(state) {
      return state.searchedMachineList;
    },
    getLayoutGroupList(state) {
      return state.layoutGroupList;
    },
    getLayoutList(state) {
      return state.layoutList;
    },
    // 対象機種のレイアウトグループ情報取得
    getLayoutGroupListByMachineType(state) {
      return state.layoutGroupListByMachineType;
    },
    getListPeriodic(state) {
      return state.listListPeriodic;
    },
    getListMachine(state) {
      return state.listMachine;
    },
    getMachineSelected(state) {
      return state.listMachineSelect;
    },
    getListDataMaster(state) {
      return state.listDataMaster;
    },
    getDataTemp(state) {
      return state.listDataTemp;
    },
    getParamsGetDetail(state) {
      return state.paramsGetDetail;
    },
    getAllUser(state) {
      return state.listUser;
    },
    getDetailData(state) {
      return state.dataForShowDetail;
    },
    getParamsCalendar(state) {
      return state.paramsCalendar;
    },
    getPeriodicResultDetail(state) {
      return state.periodicResultDetail;
    },
    getMachine(state) {
      return state.machine;
    },
    getBeforeModel(state) {
      return state.beforeModel;
    },
    getOpenFirstPeriodic(state) {
      return state.paramOpenFirstPeriodic;
    },
    getHistoryParams(state) {
      return state.historyParams;
    },
    getStorSimlpSearchQurey(state) {
      return state.simlpSearchQurey;
    },
    // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
    getIsOpenBySubView(state) {
      return state.isOpenBySubView;
    },
    getIsOpenByHistoryView(state) {
      return state.isOpenByHistoryView;
    },
    // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
  },
  actions: {
    resetReadyToSearchByParamState({ commit }) {
      commit("setReadyToSearchByParamState", false);
    },
    onReadyToSearchByParam({ commit, state }) {
      if (!state.isReadyToSearchByParam) {
        commit("setReadyToSearchByParamState", true);
      }
    },
    async waitReadyToSearchByParam({ state }) {
      const IntervalMs = 50;
      const WaitLimitMs = 1000;
      const RetryLimit = WaitLimitMs / IntervalMs;

      let retryCount = 0;
      while (!state.isReadyToSearchByParam) {
        retryCount++;
        if (RetryLimit <= retryCount) {
          throw new Error("waitReadyToSearchByParam timeout");
        }
        await new Promise(resolve => {
          setTimeout(resolve, IntervalMs);
        });
      }
    },

    async sendRequestGetAllLayoutGroup({ commit }) {
      await sendRequestGetAllLayoutGroup().then(res => {
        commit("setLayoutGroupList", res.data);
      });
    },
    async sendRequestLayoutGroupByMachineType({ commit }) {
      await sendRequestLayoutGroupByMachineType().then(res => {
        commit("setLayoutGroupListByMachineType", res.data);
      });
    },
    async sendRequestGetAllLayout({ commit }) {
      await sendRequestGetAllLayout().then(res => {
        commit("setLayoutList", res.data);
      });
    },
    setListMachine({ commit }, data) {
      commit("setListMachine", data);
    },
    setHistoryParams({ commit }, params) {
      commit("setHistoryParams", params);
    },
    setStorSimlpSearchQurey({ commit }, params) {
      commit("setStorSimlpSearchQurey", params);
    },
    async sendRequestCreateMenteTemp({ commit }, params) {
      await sendRequestCreateMenteTemp(params).then(res => {
        const fomatData = Array.from(res.data).map(item => ({
          machineNo: item.machineNo,
          menteDate: normalizeMenteDate(item.menteDate),
          menteLayoutGroupCd: item.menteLayoutGroupCd,
          menteLayoutCd: item.menteLayoutCd
        }));
        commit("setDataTemp", fomatData);
        // 既存データとの重複がない場合は res.data は "" になっているので
        // Array.from("") の結果として [] になり、 fomatData も [] となる
      });
    },

    async sendRequestGetDetail({ commit }, params) {
      let paramforGet = params.devMenteNo
        ? {
          devMenteNo: params.devMenteNo
        }
        : {
          menteLayoutGroupCd: params.menteLayoutGroupCd,
          machineTypeCd: params.machineTypeCd
        };
      let listUser = [];
      let resultMaster = null;
      let resultDetail = null;
      await sendRequestGetDetailForMaster(paramforGet).then(res => {
        resultMaster = res.data;
      });
      paramforGet = params.devMenteNo
        ? {
          devMenteNo: params.devMenteNo
        }
        : {
          menteLayoutGroupCd: params.menteLayoutGroupCd,
          machineNo: params.machineNo
        };
      await sendRequestGetDetailGetDetailResult(paramforGet).then(res => {
        resultDetail = res.data;
        commit("setPeriodicResultDetail", res.data);
      });
      await sendRequestGetAllUserInforMation(params.facilityCd).then(res => {
        listUser = Array.from(res.data).map(item => ({
          user_id: item.userId,
          checkerFullName: `${item.userLastName} ${item.userFirstName}`
        }));
        commit("setAllUser", listUser);
      });
      let dataFomat = {
        inspectInfor: null,
        layoutName: resultDetail.layoutName,
        table1: [],
        table2: [],
        machineInfor: resultDetail.machine_info
      };
      let detailOfResult = [];
      if (null != params.flagInfo && null != params.flagInfo.item && "" != params.flagInfo.item) {
        resultDetail.result=params.flagInfo.item;
      }
      if (resultDetail.result && resultDetail.result.detail) {
        detailOfResult = JSON.parse(resultDetail.result.detail) || 0;
      }
      if (resultDetail.result) {
        dataFomat.inspectInfor = {
          detail: resultDetail.result.detail || "[]",
          menteLayoutGroupCd: params.menteLayoutGroupCd,
          menteLayoutCd: resultDetail.result.menteLayoutCd,
          menteLayoutNo:resultDetail.result.mainteLayoutEdition,
          recNo: resultDetail.result.recNo,
          devMenteNo: resultDetail.result.devMenteNo,
          checkerId1: resultDetail.result.checkerId1,
          checkerId2: resultDetail.result.checkerId2,
          menteDate: normalizeMenteDate(
            resultDetail.result.menteDate ? resultDetail.result.menteDate : params.menteDate
          ),
          menteComment1: resultDetail.result.menteComment1,
          menteComment2: "",
          menteAns2: "",
          menteAns1: resultDetail.result.menteAns1 || "",
          menteAnsHeader1: null,
          menteAnsHeader2: false
        };
      } else {
        dataFomat.inspectInfor = {
          detail: "[]",
          menteLayoutGroupCd: params.menteLayoutGroupCd,
          menteLayoutCd: resultMaster.menteLayoutCd,
          recNo: "",
          devMenteNo: "",
          checkerId1: "",
          checkerId2: "",
          menteDate: normalizeMenteDate(params.menteDate),
          menteComment1: "",
          menteComment2: "",
          menteAns2: "",
          menteAns1: "",
          menteAnsHeader1: null,
          menteAnsHeader2: false,
        };
      }
      if (resultMaster && resultMaster.table1) {
        let categoryList = [];
        Array.from(resultMaster.table1).forEach(category => {
          let detailItems = [];
          Array.from(JSON.parse(category.detail)).forEach(ceteDetail => {
            let detailOfResultItem = detailOfResult.find(
              x => x.detail_cd === ceteDetail.menteDetailCd && x.tableIndex == 1  && ceteDetail.menteCategoryCd == x.cate_cd
            );
            const detailInfor = detailOfResultItem
              ? (() => {
                let checker = listUser.find(
                  user => user.user_id === detailOfResultItem.user_id
                );
                return {
                  ...ceteDetail,
                  edition: ceteDetail.editionNo,
                  cate_cd:ceteDetail.menteCategoryCd,
                  cate_edi:ceteDetail.cate_edi,
                  isCmt:ceteDetail.isCmt,
                  detail_cd: ceteDetail.menteDetailCd,
                  comment: detailOfResultItem.comment,
                  judge: detailOfResultItem.judge,
                  date: detailOfResultItem.regDate,
                  ...checker
                };
              })()
              : {
                ...ceteDetail,
                edition: ceteDetail.editionNo,
                cate_cd:ceteDetail.menteCategoryCd,
                cate_edi:ceteDetail.cate_edi,
                detail_cd: ceteDetail.menteDetailCd,
                comment: ceteDetail.iniText,
                isCmt:ceteDetail.isCmt,
                judge: "",
                date: "",
                user_id: 0,
                checkerFullName: ""
              };
            delete detailInfor.menteDetailCd;
            delete detailInfor.editionNo;
            detailItems.push(detailInfor);
          });
          categoryList.push({
            catelogyName: category.categoryName,
            detailItems: detailItems
          });
        });
        dataFomat.table1 = categoryList;
      }
      if (resultMaster && resultMaster.table2) {
        let categoryList = [];
        Array.from(resultMaster.table2).forEach(item => {
          let detailItems = [];
          Array.from(JSON.parse(item.detail)).forEach(ceteDetail => {
            let detailOfResultItem = detailOfResult.find(
              x => x.detail_cd === ceteDetail.menteDetailCd && x.tableIndex == 2 && ceteDetail.menteCategoryCd == x.cate_cd
            );
            const detailInfor = detailOfResultItem
              ? (() => {
                let checker = listUser.find(
                  user => user.user_id === detailOfResultItem.user_id
                );
                return {
                  ...ceteDetail,
                  edition: ceteDetail.editionNo,
                  cate_cd:ceteDetail.menteCategoryCd,
                  cate_edi:ceteDetail.cate_edi,
                  detail_edi: ceteDetail.detail_edi,
                  isCmt:ceteDetail.isCmt,
                  detail_cd: ceteDetail.menteDetailCd,
                  comment: detailOfResultItem.comment,
                  judge: detailOfResultItem.judge == '1'? true : false,
                  date: detailOfResultItem.regDate,
                  ...checker
                };
              })()
              : {
                ...ceteDetail,
                edition: ceteDetail.editionNo,
                cate_cd:ceteDetail.menteCategoryCd,
                cate_edi:ceteDetail.cate_edi,
                isCmt:ceteDetail.isCmt,
                detail_cd: ceteDetail.menteDetailCd,
                comment: ceteDetail.iniText,
                judge: "",
                date: "",
                user_id: 0,
                checkerFullName: ""
              };
            delete detailInfor.menteDetailCd;
            delete detailInfor.editionNo;
            detailItems.push(detailInfor);
          });
          categoryList.push({
            catelogyName: item.categoryName,
            detailItems: detailItems
          });
        });
        dataFomat.table2 = categoryList;
      }
      commit("setDetailData", dataFomat);
    },
    sendRequestCreateMentePlan(_ctx, body) {
      return sendRequestCreateMentePlan(body);
    },
    sendRequestUpdateMente(_ctx, body) {
      return sendRequestUpdateMente(body);
    },
    setMachine({ commit }, params) {
      commit("setMachine", params);
    },
    setOpenFirstPeriodic({ commit }, params) {
      commit("setOpenFirstPeriodic", params);
    },
    /**
     * @description 検索結果を一覧として格納
     */
    async setSearchedList({ commit }, condition) {
      const response = await sendRequestGetMachineSearchResult(condition);
      const searchedMachineList = response.data.map(machine => ({
        machineNo: machine.machineNo,
        machineName: machine.machineName,
        machineType: machine.machineType,
        bedName: machine.bedName,
        machineTypeCd: machine.machineTypeCd,
      }));
      commit("setSearchedMachineList", searchedMachineList);
    },
  },
  mutations: {
    setReadyToSearchByParamState(state, value) {
      state.isReadyToSearchByParam = value;
    },
    setSelectedCondition(state, selectedCondition) {
      state.selectedCondition = deepCopy(selectedCondition);
    },
    setSearchedMachineList(state, searchedMachineList) {
      state.searchedMachineList = searchedMachineList;
    },
    setLayoutGroupList(state, data) {
      state.layoutGroupList = data;
    },
    setLayoutList(state, data) {
      state.layoutList = data;
    },
    // 対象機種のレイアウトグループ情報取得
    setLayoutGroupListByMachineType(state, data) {
      state.layoutGroupListByMachineType = data;
    },
    setListPeriodic(state, data) {
      state.listListPeriodic = data;
    },
    setListMachine(state, data) {
      state.listMachine = data;
    },
    setMachineSelected(state, data) {
      state.listMachineSelect = data;
    },
    setListDataMaster(state, data) {
      state.listDataMaster = data;
    },
    setDataTemp(state, data) {
      state.listDataTemp = data;
    },
    setParamsGetDetail(state, data) {
      state.paramsGetDetail = data;
    },
    setAllUser(state, data) {
      state.listUser = data;
    },
    setDetailData(state, data) {
      state.dataForShowDetail = data;
    },
    setParamsCalendar(state, data) {
      state.paramsCalendar = data;
    },
    setPeriodicResultDetail(state, data) {
      state.periodicResultDetail = data;
    },
    setMachine(state, data) {
      state.machine.facilityCd = data.facilityCd;
      state.machine.machineTypeCd = data.machineTypeCd;
      state.machine.machineSerial = data.machineSerial;
    },
    setBeforeModel(state, data) {
      state.beforeModel.name = data.name;
      state.beforeModel.data = data.data;
    },
    setOpenFirstPeriodic(state, data) {
      state.paramOpenFirstPeriodic = data;
    },
    setHistoryParams(state, data) {
      state.historyParams = data;
    },
    setStorSimlpSearchQurey(state, data) {
      state.simlpSearchQurey = data;
    },
    // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
    setIsOpenBySubView(state, data) {
      state.isOpenBySubView = data;
    },
    setIsOpenByHistoryView(state, data) {
      state.isOpenByHistoryView = data;
    },
    // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
  },
};
