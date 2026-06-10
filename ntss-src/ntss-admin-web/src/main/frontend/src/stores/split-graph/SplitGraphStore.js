export default {
  strict: true,
  namespaced: true,
  state: {
    condition: {
      startDate: "",
      endDate: "",
    },
    graphType: "blank",
    sumaryArea: false,
    selectedAreas: [],
    selectedPatient: null,
    examRecordDate: null,
    validGraphSetting: true,
	  //add 63449分割グラフの経過画面から治療記録に遷移し、パンくずリストで９分割グラフ画面に戻ると経過ではなく分布画面が表示される zhao start
    selPatient:null,
    selType:null,
	  //add 63449分割グラフの経過画面から治療記録に遷移し、パンくずリストで９分割グラフ画面に戻ると経過ではなく分布画面が表示される zhao end
    //add 7297 初回リリース対象外の機能とその関連機能を隠す 姜 start
    selPat:null,
    selectPat:null
    //add 7297 初回リリース対象外の機能とその関連機能を隠す 姜 end
  },

  getters: {
    getCondition: state => state.condition,
    getGraphType: state => state.graphType,
    sumaryArea: state => state.sumaryArea,
    getSelectedAreas: state => state.selectedAreas,
    getSelectedPatient: state => state.selectedPatient,
    getExamRecordDate: state => state.examRecordDate,
    getValidGraphSettingStatus: state => state.validGraphSetting,
    //add 63449分割グラフの経過画面から治療記録に遷移し、パンくずリストで９分割グラフ画面に戻ると経過ではなく分布画面が表示される zhao start
    getSelPatient: state =>  state.selPatient,
    getSelType: state => state.selType,
    //add 63449分割グラフの経過画面から治療記録に遷移し、パンくずリストで９分割グラフ画面に戻ると経過ではなく分布画面が表示される zhao end
    //add 7297 初回リリース対象外の機能とその関連機能を隠す 姜 start
    getSelPat: state =>  state.selPat,
    getSelectPat: state =>  state.selectPat
    //add 7297 初回リリース対象外の機能とその関連機能を隠す 姜 end
  },

  mutations: {
    setCondition: (state, condition) => {
      state.condition = condition;
    },
    setGraphType: (state, graphType) => {
      state.graphType = graphType;
    },
    setSumaryArea: (state) => {
      state.sumaryArea = !state.sumaryArea;
    },
    setSelectedAreas: (state, selectedAreas) => {
      state.selectedAreas = selectedAreas;
    },
    setSelectedPatient: (state, selectedPatient) => {
      state.selectedPatient = selectedPatient;
    },
    setExamRecordDate: (state, examRecordDate) => {
      state.examRecordDate = examRecordDate;
    },
    setValidGraphSettingStatus: (state, validGraphSetting) => {
      state.validGraphSetting = validGraphSetting;
    },
    //add 63449分割グラフの経過画面から治療記録に遷移し、パンくずリストで９分割グラフ画面に戻ると経過ではなく分布画面が表示される zhao start
    setSelPatient: (state,selPatient) => {
      state.selPatient = selPatient;
    },
    setSelType: (state,selType) => {
      state.selType = selType;
    },
    //add 63449分割グラフの経過画面から治療記録に遷移し、パンくずリストで９分割グラフ画面に戻ると経過ではなく分布画面が表示される zhao end
    //add 7297 初回リリース対象外の機能とその関連機能を隠す 姜 start
    setSelPat: (state,selPat) => {
      state.selPat = selPat;
    },
    setSelectPat: (state,selectPat) => {
      state.selectPat = selectPat;
    }
    //add 7297 初回リリース対象外の機能とその関連機能を隠す 姜 end
  },

  actions: {
    setCondition: ({ commit }, condition) => {
      commit("setCondition", condition);
    },
    setGraphType: ({ commit }, graphType) => {
      commit("setGraphType", graphType);
    },
    setSumaryArea: ({ commit }) => {
      commit("setSumaryArea");
    },
    setSelectedAreas: ({ commit }, selectedAreas) => {
      commit("setSelectedAreas", selectedAreas);
    },
    setSelectedPatient: ({ commit }, selectedPatient) => {
      commit("setSelectedPatient", selectedPatient);
    },
    setExamRecordDate: ({ commit }, examRecordDate) => {
      commit("setExamRecordDate", examRecordDate);
    },
    setValidGraphSettingStatus: ({ commit }, validGraphSetting) => {
      commit("setValidGraphSettingStatus", validGraphSetting);
    },
    //add 63449分割グラフの経過画面から治療記録に遷移し、パンくずリストで９分割グラフ画面に戻ると経過ではなく分布画面が表示される zhao start
    setSelPatient: ({ commit }, selPatient) => {
      commit("setSelPatient", selPatient);
    },
    setSelType: ({ commit }, selType) => {
      commit("setSelType", selType);
    },
   //add 63449分割グラフの経過画面から治療記録に遷移し、パンくずリストで９分割グラフ画面に戻ると経過ではなく分布画面が表示される zhao end
    //add 7297 初回リリース対象外の機能とその関連機能を隠す 姜 start
    setSelPat: ({ commit }, selPat) => {
      commit("setSelPat", selPat);
    },
    setSelectPat: ({ commit }, selectPat) => {
      commit("setSelectPat", selectPat);
    }
    //add 7297 初回リリース対象外の機能とその関連機能を隠す 姜 end
  }
};
