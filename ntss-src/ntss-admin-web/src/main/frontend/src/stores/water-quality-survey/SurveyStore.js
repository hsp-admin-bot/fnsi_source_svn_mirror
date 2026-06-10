/**
 * 水質調査機能 WaterQualitySurveyStore
 */

export default {
  strict: process.env.NODE_ENV !== "production",
  namespaced: true,
  state: {
    displayConditionFlag: true,
    condition: null,
    defaultCondition: null,
    selectedSurveyList: [],
    mstSurveyPoint: [],
    mstSurveyType: [],
    mstMachine: [],
    mstUser: [],
    mntWaterSurvey: [],
    selectedList: [],
    chartData: [],
    resultText: null,
    listBedGroup: [],
    itemDateFromCalendar: null
  },
  getters: {
    // 抽出条件
    getCondition(state) {
      return state.condition;
    },
    // 初期抽出条件
    getDefaultCondition(state) {
      return state.defaultCondition;
    },
    displayConditionFlag(state) {
      return state.displayConditionFlag;
    },
    selectedSurveyList(state) {
      return state.selectedSurveyList;
    },
    getRangeDate(state) {
      if (!state.condition.fromDate) {
        return null;
      }
      return {
        fromDate: state.condition.fromDate,
        toDate: state.condition.toDate
      };
    },
    getSelectedList(state) {
      return state.selectedList;
    },
    mstSurveyPoint(state) {
      return state.mstSurveyPoint;
    },
    mstSurveyType(state) {
      return state.mstSurveyType;
    },
    mstMachine(state) {
      return state.mstMachine;
    },
    mntWaterSurvey(state) {
      return state.mntWaterSurvey;
    },
    mstUser(state) {
      return state.mstUser;
    },
    getChartData(state) {
      return state.chartData;
    },
    getResultText(state) {
      return state.resultText;
    },
    getListBedGroup(state) {
      return state.listBedGroup;
    },
    getItemDateFromCalendar(state) {
      return state.itemDateFromCalendar;
    }
  },
  actions: {
    // 抽出条件
    setCondition({ commit }, condition) {
      // 抽出条件セット
      commit("setCondition", JSON.parse(JSON.stringify(condition)));
    },
    // 初期抽出条件
    setDefaultCondition({ commit }, defaultCondition) {
      // 初期抽出条件セット
      commit("setDefaultCondition", JSON.parse(JSON.stringify(defaultCondition)));
    },
    // 表示条件切替フラグ変更
    changeDisplayConditionFlag({ commit }, flg) {
      commit("changeDisplayConditionFlag", flg);
    },
    setSelectedSurveyList({ commit }, selectedSurveyList) {
      commit("setSelectedSurveyList", selectedSurveyList);
    },
    setSelectedList({ commit }, selectedList) {
      commit("setSelectedList", selectedList);
    },
    setMstSurveyPoint({ commit }, mstSurveyPoint) {
      commit("setMstSurveyPoint", mstSurveyPoint);
    },
    setMstSurveyType({ commit }, mstSurveyType) {
      commit("setMstSurveyType", mstSurveyType);
    },
    setMstMachine({ commit }, mstMachine) {
      commit("setMstMachine", mstMachine);
    },
    setMntWaterSurvey({ commit }, mntWaterSurvey) {
      commit("setMntWaterSurvey", mntWaterSurvey);
    },
    setMstUser({ commit }, mstUser) {
      commit("setMstUser", mstUser);
    },
    setChartData({ commit }, chartData) {
      commit("setChartData", chartData);
    },
    setResultText({ commit }, resultText) {
      commit("setResultText", resultText);
    },
    setListBedGroup({ commit }, listBedGroup) {
      commit("setListBedGroup", listBedGroup);
    },
    setItemDateFromCalendar({ commit }, itemDateFromCalendar) {
      commit("setItemDateFromCalendar", itemDateFromCalendar);
    }
  },
  mutations: {
    // 抽出条件
    setCondition(state, condition) {
      state.condition = condition;
    },
    // 抽出条件
    setDefaultCondition(state, defaultCondition) {
      state.defaultCondition = defaultCondition;
    },
    // 表示切替フラグ変更
    changeDisplayConditionFlag(state, displayConditionFlag) {
      state.displayConditionFlag = displayConditionFlag;
    },

    setSelectedSurveyList(state, selectedSurveyList) {
      state.selectedSurveyList = selectedSurveyList;
    },
    setMstSurveyPoint(state, mstSurveyPoint) {
      state.mstSurveyPoint = mstSurveyPoint;
    },
    setMstSurveyType(state, mstSurveyType) {
      state.mstSurveyType = mstSurveyType;
    },
    setMstMachine(state, mstMachine) {
      state.mstMachine = mstMachine;
    },
    setMntWaterSurvey(state, mntWaterSurvey) {
      state.mntWaterSurvey = [...mntWaterSurvey];
    },
    setMstUser(state, mstUser) {
      state.mstUser = mstUser;
    },
    setSelectedList(state, selectedList) {
      state.selectedList = selectedList;
    },
    setChartData(state, chartData) {
      state.chartData = chartData;
    },
    setResultText(state, resultText) {
      state.resultText = resultText;
    },
    setListBedGroup(state, listBedGroup) {
      state.listBedGroup = listBedGroup;
    },
    setItemDateFromCalendar(state, itemDateFromCalendar) {
      state.itemDateFromCalendar = itemDateFromCalendar;
    }
  }
};
