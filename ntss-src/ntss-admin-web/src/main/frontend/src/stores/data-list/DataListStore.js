export default {
  namespaced: true,
  strict: true,

  state: {
    requestExportCSV: 0,
    requestExportExcel: 0,
    selectedLayout: null,
    initflg: true,
    selectedDynamicLayout: null,
    dayObj: [],
    patListLayoutCd: 0,
    // add #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang start
    loadFlag: false,
    // add #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang end
    // 変更フラグ
    isDataChanged: false
  },

  getters: {
    getRequestExportCSV: state => state.requestExportCSV,
    getRequestExportExcel: state => state.requestExportExcel,
    getSelectedLayout(state) {
      return state.selectedLayout;
    },
    getInitflg(state) {
      return state.initflg;
    },
    getSelectedDynamicLayout(state) {
      return state.selectedDynamicLayout;
    },
    getRangeDate(state) {
      return state.dayObj;
    },
    getPatListLayoutCd(state) {
      return state.patListLayoutCd;
    },
    // add #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang start
    getLoadFlag(state) {
      return state.loadFlag;
    },
    // add #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang end
    getIsDataChanged(state) {
      return state.isDataChanged;
    },
  },
  mutations: {
    setSelectedLayout: (state, selectedLayout) => {
      state.selectedLayout = selectedLayout;
    },
    setInitflg: (state, initflg) => {
      state.initflg = initflg;
    },
    setRequestExportCSV: (state) => {
      state.requestExportCSV++;
    },
    setRequestExportExcel: (state) => {
      state.requestExportExcel++;
    },
    setSelectedDynamicLayout(state, selectedDynamicLayout) {
      state.selectedDynamicLayout = selectedDynamicLayout;
    },
    setRangeDate(state, dayObj) {
      state.dayObj = dayObj;
    },
    setPatListLayoutCd(state, patListLayoutCd) {
      state.patListLayoutCd = patListLayoutCd;
    },
    // add #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang start
    setLoadFlag(state, loadFlag) {
      state.loadFlag = loadFlag;
    },
    // add #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang end
    // 変更フラグ
    setIsDataChanged(state, isDataChanged) {
      state.isDataChanged = isDataChanged;
    },
  },
  actions: {
    setRequestExportCSV({commit}) {
      commit("setRequestExportCSV");
    },
    setRequestExportExcel({commit}) {
      commit("setRequestExportExcel");
    },
    setSelectedLayout({commit}, payload) {
      commit("setSelectedLayout", payload);
    },
    setInitflg({commit}, payload) {
      commit("setInitflg", payload);
    },
    setSelectedDynamicLayout({ commit }, selectedDynamicLayout) {
      commit("setSelectedDynamicLayout", selectedDynamicLayout);
    },
    setRangeDate({ commit }, dayObj) {
      commit("setRangeDate", dayObj);
    },
    setPatListLayoutCd({ commit }, patListLayoutCd) {
      commit("setPatListLayoutCd", patListLayoutCd);
    },
    // add #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang start
    setLoadFlag({ commit }, loadFlag) {
      commit("setLoadFlag", loadFlag);
    },
    // add #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang end
    setIsDataChanged({ commit }, isDataChanged) {
      commit("setIsDataChanged", isDataChanged);
    },   
  }
};
