// add 検索条件の日付が保存できません。 start
import {deepCopy} from "@/functions/common/CommonFunctions";
// add 検索条件の日付が保存できません。 end

export default {
  namespaced: true,
  strict: true,
  state: {
    condition: {
      noticeStartDate: null,
      noticeEndDate: null,
      noticeStartTime: null,
      noticeEndTime: null,
      duration: 0,
      facilityCd: [],
      moduleName: [],
      logClass: [],
      logType: [],
      userId: [],
      patId: [],
      keySearch: "",
      serviceName: [],
      typeSearch: null
    },
    savedConditionList: [],
    selectedSavedCondition: null,

    searchRequest: true,
    defaultCondition: null,
    lastCondition: null,
    tabData: [],
    // add/ #9603 ログ参照画面の表示項目の内容保持されていない。 tianqidong start
    selectedItemList: [],
    selectedItem: false,
    // add/ #9603 ログ参照画面の表示項目の内容保持されていない。 tianqidong end
  },

  getters: {
    getSearchRequest: state => state.searchRequest,
    getCondition: state => state.condition,
    getSavedConditionLists: state => state.savedConditionList,
    getSelectedSavedCondition: state => state.selectedSavedCondition,
    getDefaultCondition: state => state.defaultCondition,
    getLastCondition: state => state.lastCondition,
    getTabData: state => state.tabData,
    // add/ #9603 ログ参照画面の表示項目の内容保持されていない。 tianqidong start
    getSelectedItemList: state => state.selectedItemList,
    getSelectedItem: state => state.selectedItem,
    // add/ #9603 ログ参照画面の表示項目の内容保持されていない。 tianqidong end
  },

  mutations: {
    setSearchRequest: (state) => {
      state.searchRequest = !state.searchRequest;
    },
    setCondition: (state, condition) => {
// mod 検索条件の日付が保存できません。 start
//      state.condition = condition;
//      state.lastCondition = condition;
      state.condition = deepCopy(condition);
      state.lastCondition = deepCopy(condition);
// mod 検索条件の日付が保存できません。 end
    },
    setSavedConditionList: (state, condition) => {
      if (state.savedConditionList.length > 10) {
        state.savedConditionList.shift();
      }
      state.savedConditionList.push(condition);
    },
    setSelectedSavedCondition: (state, condition) => {
      state.selectedSavedCondition = condition;
    },
    setDefaultCondition: (state, condition) => {
      state.defaultCondition = condition;
    },
    setTabData: (state, tab) => {
      state.tabData.push(tab);
    },
    resetTab: (state) => {
      state.tabData = [];
    },
    syncTabLocalToStore: (state, tabs) => {
      state.tabData = tabs;
    },
    // add/ #9603 ログ参照画面の表示項目の内容保持されていない。 tianqidong start
    setSelectedItemList: (state, tabs) => {
      state.selectedItemList = tabs;
    },
    setSelectedItem: (state, tabs) => {
      state.selectedItem = tabs;
    },
    // add/ #9603 ログ参照画面の表示項目の内容保持されていない。 tianqidong end
  },

  actions: {
    setSearchRequest: ({ commit }) => {
      commit("setSearchRequest");
    },
    setCondition: ({ commit }, condition) => {
      commit("setCondition", condition);
    },
    setSavedConditionList: ({ commit }, condition) => {
      commit("setSavedConditionList", condition);
    },
    setSelectedSavedCondition: ({ commit }, condition) => {
      commit("setSelectedSavedCondition", condition);
    },
    clearCondition: ({ commit }) => {
      commit("clearCondition");
    },
    setDefaultCondition: ({ commit }, condition) => {
      commit("setDefaultCondition", condition);
    },
    setTabData: ({ commit }, tab) => {
      commit("setTabData", tab);
    },
    resetTab: ({ commit }) => {
      commit("resetTab");
    },
    syncTabLocalToStore: ({ commit }, tabs) => {
      commit("syncTabLocalToStore", tabs);
    },
    // add/ #9603 ログ参照画面の表示項目の内容保持されていない。 tianqidong start
    setSelectedItemList: ({ commit }, tabs) => {
      commit("setSelectedItemList", tabs);
    },
    setSelectedItem: ({ commit }, tabs) => {
      commit("setSelectedItem", tabs);
    },
    // add/ #9603 ログ参照画面の表示項目の内容保持されていない。 tianqidong end
  }
};
