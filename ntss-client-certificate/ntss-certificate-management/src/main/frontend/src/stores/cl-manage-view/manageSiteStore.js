export default {
  namespaced: true,
  state: {
    facilityArray: [],
    facilitySearch: "",//施設の検索名
    filterFacilityKey:"",//データのフィルタリングに使用
    showFacility: true, // 施設表を表示
    showUser: false, // ユーザーテーブルを表示
    selectfilterList :"prefecturesCd",
    page: 1,
    sort: null,
  },
  getters: {
    getFacilityArray(state){
      return state.facilityArray;
    },
    getFacilitySearch(state){
      return state.facilitySearch;
    },
    getFilterFacilityKey(state){
      return state.filterFacilityKey;
    },
    getShowFacility(state){
      return state.showFacility;
    },
    getShowUser(state){
      return state.showUser;
    },
    getSelectfilterList(state){
      return state.selectfilterList;
    },
    getPage(state){
      return state.page;
    },
    getSort(state){
      return state.sort;
    },
  },
  actions: {
    setFacilityArray({commit}, facilityArray){
      commit("setFacilityArray", facilityArray);
    },
    setFacilitySearch({commit}, facilitySearch){
      commit("setFacilitySearch", facilitySearch);
    },
    setFilterFacilityKey({commit}, filterFacilityKey){
      commit("setFilterFacilityKey", filterFacilityKey);
    },
    setShowFacility({commit}, showFacility){
      commit("setShowFacility", showFacility);
    },
    setShowUser({commit}, showUser){
      commit("setShowUser", showUser);
    },
    setSelectfilterList({commit}, selectfilterList){
      commit("setSelectfilterList", selectfilterList);
    },
    setPage({commit}, page){
      commit("setPage", page);
    },
    setSort({commit}, sort){
      commit("setSort", sort);
    },
  },
  mutations: {
    setFacilityArray(state, facilityArray) {
      state.facilityArray = facilityArray;
    },
    setFacilitySearch(state, facilitySearch) {
      state.facilitySearch = facilitySearch;
    },
    setFilterFacilityKey(state, filterFacilityKey) {
      state.filterFacilityKey = filterFacilityKey;
    },
    setShowFacility(state, showFacility) {
      state.showFacility = showFacility;
    },
    setShowUser(state, showUser) {
      state.showUser = showUser;
    },
    setSelectfilterList(state, selectfilterList) {
      state.selectfilterList = selectfilterList;
    },
    setPage(state, page) {
      state.page = page;
    },
    setSort(state, sort) {
      state.sort = sort;
    },
    addFacilityToArray(state, data) {
      var val = data.model[data.field];
      var facilityCd = data.model['facilityCd'];
      var facilityName = data.model['facilityName'];

      var arrIndex = 0;
      var isExists = false;
      for (var i = 0; i < state.facilityArray.length; i++) {
        if (state.facilityArray[i]['facilityCd'] === facilityCd) {
          isExists = true;
          arrIndex = i;
          break;
        }
      }

      if (isExists) {
        state.facilityArray[arrIndex]['facilityCd'] = facilityCd;
        state.facilityArray[arrIndex]['facilityName'] = facilityName;
        state.facilityArray[arrIndex]['type'] = val;
      } else {
        let facilityJson = {
          "type": val,
          "facilityCd": facilityCd,
          "facilityName": facilityName
        };
        state.facilityArray.push(facilityJson);
      }
    },
    removeFacilityFromArrayItem(state, index){
      state.facilityArray.splice(index, 1);
    }
  }
};
