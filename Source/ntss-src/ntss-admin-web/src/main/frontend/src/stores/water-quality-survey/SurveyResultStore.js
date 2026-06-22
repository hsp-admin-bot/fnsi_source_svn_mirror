/**
 * 結果登録 
 */

export default {
  strict: process.env.NODE_ENV !== "production",
  namespaced: true,
  state: {
    modalVisible: false,
    selectTabId: 0,
    controlDisp: {
      isDispPlan: true,
      isDispResult: true,
      isDispDel: true,
      isDisableDate: false,
      isToggleShowObject: true
    },
    inspectionDate: null,
    surveyRecord: [],
    // add FNSI-水質検査結果登録で備考欄を追加する 周 start
    surveyRecordForMemo: {
      memo: "",
      index: -1
    },
    // add FNSI-水質検査結果登録で備考欄を追加する 周 end
    pickerCd: -1,
    inspectorCd: -1,
    surveyRecordDb: [],
    // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
    surveyResultList: [],
    // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
  },
  getters: {
    resultModalVisible: state => {
      return state.modalVisible;
    },
    selectTabId: state => {
      return state.selectTabId;
    },
    controlDisp: state => {
      return state.controlDisp;
    },
    inspectionDate: state => {
      return state.inspectionDate;
    },
    surveyRecord: state => {
      return state.surveyRecord;
    },
    // add FNSI-水質検査結果登録で備考欄を追加する 周 start
    surveyRecordForMemo: state => {
      return state.surveyRecordForMemo;
    },
    // add FNSI-水質検査結果登録で備考欄を追加する 周 end
    getInspectorCd(state) {
      return state.inspectorCd;
    },
    getPickerCd(state) {
      return state.pickerCd;
    },
    surveyRecordDb(state) {
      return state.surveyRecordDb;
    },
    // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
    getSurveyResultList(state) {
      return state.surveyResultList;
    },
    // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
  },
  actions: {
    setResultModalVisible: ({ commit }, modalVisible) => {
      commit("setResultModalVisible", modalVisible);
    },
    setSelectTabId: ({ commit }, selectTabId) => {
      commit("setSelectTabId", selectTabId);
    },
    setControlDisp: ({ commit }, controlDisp) => {
      commit("setControlDisp", controlDisp);
    },
    setInspectionDate: ({ commit }, inspectionDate) => {
      commit("setInspectionDate", inspectionDate);
    },
    setSurveyRecord: ({ commit }, surveyRecord) => {
      commit("setSurveyRecord", surveyRecord);
    },
    // add FNSI-水質検査結果登録で備考欄を追加する 周 start
    setSurveyRecordForMemo: ({ commit }, surveyRecordForMemo) => {
      commit("setSurveyRecordForMemo", surveyRecordForMemo);
    },
    // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start
    setSurveyRecordBySurveyMemo: ({ commit }, surveyMemo) => {
      commit("setSurveyRecordBySurveyMemo", surveyMemo);
    },
    // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end
    // add FNSI-水質検査結果登録で備考欄を追加する 周 end
    setInspectorCd({ commit }, inspectorCd) {
      commit("setInspectorCd", inspectorCd);
    },
    setPickerCd({ commit }, pickerCd) {
      commit("setPickerCd", pickerCd);
    },
    setSurveyRecordDb({ commit }, surveyRecordDb) {
      commit("setSurveyRecordDb", surveyRecordDb);
    }
  },
  mutations: {
    setResultModalVisible: (state, modalVisible) => {
      state.modalVisible = modalVisible;
    },
    setControlDisp: (state, controlDisp) => {
      state.controlDisp = JSON.parse(JSON.stringify(controlDisp));
    },
    setSelectTabId: (state, selectTabId) => {
      state.selectTabId = selectTabId;
    },
    setInspectionDate: (state, inspectionDate) => {
      state.inspectionDate = JSON.parse(JSON.stringify(inspectionDate));
    },
    setSurveyRecord: (state, surveyRecord) => {
      state.surveyRecord = JSON.parse(JSON.stringify(surveyRecord));
    },
    // add FNSI-水質検査結果登録で備考欄を追加する 周 start
    setSurveyRecordForMemo: (state, surveyRecordForMemo) => {
      state.surveyRecordForMemo = JSON.parse(JSON.stringify(surveyRecordForMemo));
    },
    // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start
    setSurveyRecordBySurveyMemo: (state, surveyMemo) => {
      state.surveyRecord[surveyMemo.index].surveyData.memo = JSON.parse(JSON.stringify(surveyMemo.memo));
    },
    // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end
    // add FNSI-水質検査結果登録で備考欄を追加する 周 end
    setInspectorCd(state, inspectorCd) {
      state.inspectorCd = inspectorCd;
    },
    setPickerCd(state, pickerCd) {
      state.pickerCd = pickerCd;
    },
    setSurveyRecordDb(state, surveyRecordDb) {
      state.surveyRecordDb = surveyRecordDb;
    },
    // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
    setSurveyResultList(state, list) {
      state.surveyResultList = list;
    },
    // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
  }
};
