/**
 * 複数画面に対応したモーダル用のstore
 */
const state = {
  modalName: "",
  modalTitle: "",
  modalAuthorityCds: null,
  modalInitValues:{}
};

const mutations = {
  setModal(state, name) {
    state.modalName = name;
  },
  hideModal(state) {
    state.modalName = "";
    state.modalAuthorityCds = null;
  },
  setTitle(state, title) {
    state.modalTitle = title;
  },
  setAuthorityCds(state, authorityCds) {
    state.modalAuthorityCds = authorityCds;
  },
  setInitValues(state, initValues) {
    if(initValues) {
      state.modalInitValues = initValues;
    }
  }
};

const actions = {
  // モーダル化した画面はこのstoreで画面名を設定するactionを作る
  showAccountEdit({ commit }) {
    commit("setModal", "AccountEdit");
    commit("setTitle", "アカウント編集");
  },
  showMenuBarEdit({ commit }) {
    commit("setModal", "MenuBarEdit");
    commit("setTitle", "メニューバー設定");
  },
  showStaffFacility({ commit }) {
    commit("setModal", "StaffFacility");
    commit("setTitle", "担当施設設定");
  },
  showMstSynchro({ commit }) {
    commit("setModal", "MstSynchro");
    commit("setTitle", "マスタ同期");
  },
  showMasterEdit({ commit }) {
    commit("setModal", "MasterEdit");
    commit("setTitle", "マスタ編集");
  },
  showExternalCoopModal({ commit }) {
    commit("setModal", "ExternalCoopModal");
    commit("setTitle", "電文詳細");
  },
  showExternalCoopMessageModal({ commit }) {
    commit("setModal", "ExternalCoopMessageModal");
    commit("setTitle", "メッセージ");
  },
  showExternalCoopDumpPathModal({ commit }) {
    commit("setModal", "ExternalCoopDumpPathModal");
    commit("setTitle", "ファイル名編集");
  },
  showMstComplaintEdit({ commit }) {
    commit("setModal", "MstComplaintEdit");
    commit("setTitle", "愁訴マスタ詳細");
  },
  showMstCompTreatmentEdit({ commit }) {
    commit("setModal", "MstCompTreatmentEdit");
    commit("setTitle", "処置マスタ詳細");
  },
  showOxygen({ commit }) {
    commit("setModal", "Oxygen");
    commit("setTitle", "酸素吸入");
  },
  showComplaintEdit({ commit }) {
    commit("setModal", "ComplaintEdit");
    commit("setTitle", "愁訴処置編集");
  },
  showComplaintCreate({ commit }) {
    commit("setModal", "ComplaintCreate");
    commit("setTitle", "愁訴処置登録");
  },
  showBvmsGraphCommentCreate({ commit }) {
    commit("setModal", "BvmsGraphCommentCreate");
    commit("setTitle", "再循環率コメント入力");
  },
  showPatSearch({ commit }) {
    commit("setModal", "PatSearch");
    commit("setTitle", "患者選択");
  },
  showShrPatEdit({ commit }, payload) {
    if (payload) {
      commit("setInitValues", payload.initValues);
      commit("setTitle", payload.title);
    }
    commit("setModal", "ShrPatEdit");
  },
  showTareWaterEdit({ commit }, title) {
    commit("setModal", "TareWaterEdit");
    commit("setTitle", title);
  },
  showChecklistEdit({ commit }, title) {
    commit("setModal", "ChecklistEdit");
    commit("setTitle", title);
  },
  showChecklist({ commit }, title) {
    commit("setModal", "Checklist");
    commit("setTitle", title);
  },
  showMedicine({ commit }) {
    commit("setModal", "Medicine");
    commit("setTitle", "投与薬剤");
  },
  showMeasureHistoryModal({ commit }) {
    commit("setModal", "MeasureHistory");
    commit("setTitle", "測定履歴");
  },
  showMstWeightCheckEdit({ commit }) {
    commit("setModal", "MstWeightCheckEdit");
    commit("setTitle", "チェック項目編集");
  },
  showTreatmentRecordWeightInput({ commit }, { title }) {
    commit("setModal", "TreatmentRecordWeightInput");
    commit("setTitle", title);
  },
  showSchedule({ commit }, { title }) {
    commit("setModal", "ScheduleAssignment");
    commit("setTitle", title);
  },
  async showNotAssignedSchedule({ commit }) {
    await commit("setModal", "NotAssignedSchedule");
    await commit("setTitle", "スケジュール割り当て");
  },
  showTreatmentRecordAdditionInput({ commit }) {
    commit("setModal", "TreatmentRecordAdditionInput");
    commit("setTitle", "指示コメント編集");
  },
  showUserMasterIdReset({ commit }) {
    commit("setModal", "UserMasterIdReset");
    commit("setTitle", "");
  },
  showPersonalSettings({ commit }) {
    commit("setModal", "PersonalSettings");
    commit("setTitle", "個人設定");
  },
  showExamRecordModal({ commit }) {
    commit("setModal", "ExamRecordEdit");
    commit("setTitle", "検査結果記録");
  },
  showExamRecordGraphModal({ commit }) {
    commit("setModal", "ExamRecordGraph");
    commit("setTitle", "検査結果グラフ");
  },
  showUserMasterAuthFunction({ commit }) {
    commit("setModal", "UserMasterAuthFunction");
    commit("setTitle", "使用許可機能");
  },
  showFacilityMasterAdvancedSettings({ commit }) {
    commit("setModal", "FacilityMasterAdvancedSettings");
    commit("setTitle", "施設拡張機能設定");
  },
  showFacilityMasterAuthFunction({ commit }) {
    commit("setModal", "FacilityMasterAuthFunction");
    commit("setTitle", "施設使用機能設定");
  },
  showResultMerge({ commit }) {
    commit("setModal", "ResultMerge");
    commit("setTitle", "実績マージ");
  },
// add 治療記録_変更履歴 追加 陳 start
  showChangeLog({ commit }) {
    commit("setModal", "ChangeLog");
    commit("setTitle", "変更履歴");
  },
// add 治療記録_変更履歴 追加 陳 end
  showNotificationMessage({ commit }) {
    commit("setModal", "NotificationMessage");
    commit("setTitle", "通知一覧");
  },
  showReleaseInfo({ commit }) {
    commit("setModal", "ReleaseInfo");
    commit("setTitle", "リリース情報");
  },
  showMakerNotice({ commit }) {
    commit("setModal", "MakerNotice");
    commit("setTitle", "メーカー通知登録");
  },
  showPrintPreview({ commit }) {
    commit("setModal", "PrintPreview");
    commit("setTitle", "印刷プレビュー");
  },
  showBVMSPrintPreview({ commit }) {
    commit("setModal", "BVMSPrintPreview");
    commit("setTitle", "印刷プレビュー");
  },
  showUserMasterEditAuthority({ commit }) {
    commit("setModal", "UserMasterEditAuthority");
    commit("setTitle", "編集権限");
  },
  showJobMasterEditAuthority({ commit }) {
    commit("setModal", "JobMasterEditAuthority");
    commit("setTitle", "編集権限");
  },
  showMstJobEditDefaultSettingModal({ commit }) {
    commit("setModal", "MstJobEditDefaultDispSettingModal");
    commit("setTitle", "デフォルト表示設定");
  },
  showMstJobEditNotificationSettingModal({ commit }) {
    commit("setModal", "MstJobEditNotificationSettingModal");
    commit("setTitle", "デフォルト通知設定");
  },
  showAddressSearchModal({ commit }, initValues) {
    commit("setModal", "AddressSearch");
    commit("setTitle", "住所検索");
    commit("setInitValues", initValues);
  },
  showPhysicalInfoAddEdit({ commit }) {
    commit("setModal", "PhysicalInfoAddEdit");
    commit("setTitle", "身体情報");
  },
  showPhysicalInfoAddEditForPatInfo({ commit }) {
    commit("setModal", "PhysicalInfoAddEditForPatInfo");
    commit("setTitle", "身体情報");
  },
  showInsuranceInfoAddEditModal({ commit }) {
    commit("setModal", "InsuranceInfoAddEditModal");
    commit("setTitle", "保険詳細");
  },
  showIndHistoryModal({ commit }) {
    commit("setModal", "IndHistory");
    commit("setTitle", "指示履歴");
  },
  showIndSupportModal({ commit }) {
    commit("setModal", "IndSupport");
    commit("setTitle", "投薬支援");
  },
  showIndMedicineModal({ commit }, dispDataItem) {
    commit("setModal", "IndMedicine");
    commit("setTitle", "投与薬剤補助画面");
    commit("setInitValues", dispDataItem);
  },
  showDetailedSearchModal({ commit }) {
    commit("setModal", "DetailedSearch");
    commit("setTitle", "患者詳細検索");
  },
  showDetailedSearchModalo({ commit }) {
    commit("setModal", "DetailedSearch2");
    commit("setTitle", "患者詳細検索");
  },
  showDeviceSetInfoModal({ commit }, title) {
    commit("setModal", "DeviceSetInfoModal");
    commit("setTitle", title);
  },
  showIndEditModal({ commit }, title) {
    commit("setModal", "IndEditModal");
    commit("setTitle", title);
  },
  showMultiCalendar({ commit }, title) {
    if (!title) {
      title = "年間複数日選択"
    }
    commit("setModal", "MultiCalendar");
    commit("setTitle", title);
  },
  showHomeDialysisInstrConfirmModal({ commit }) {
    commit("setModal", "HomeDialysisInstrConfirmModal");
    commit("setTitle", "透析指示書");
  },
  showFacilityCalendarModal({ commit }) {
    commit("setModal", "FacilityCalendarModal");
    commit("setTitle", "施設カレンダー");
  },
  showMstFavoriteFacilityModal({ commit }) {
    commit("setModal", "MstFavoriteFacilityModal");
    commit("setTitle", "施設選択");
  },
  showPrescriptionConf({ commit }) {
    commit("setModal", "PrescriptionConfModal");
    commit("setTitle", "一括確定保存");
  },
  showPrescriptionOrder({ commit }) {
    commit("setModal", "PrescriptionOrderModal");
    commit("setTitle", "一括処方オーダー");
  },
  showPatPrescriptionSelectDrug({ commit }) {
    commit("setModal", "PatPrescriptionSelectDrugModal");
    commit("setTitle", "処方薬剤選択");
  },
  showItemSettingModal({ commit }) {
    commit("setModal", "ItemSettingModal");
    commit("setTitle", "項目設定モーダル");
  },
  showWaterResultModal({ commit }) {
    commit("setModal", "WaterResultModal");
    commit("setTitle", "水質検査結果登録");
  },
  showWaterChartModal({ commit }){
    commit("setModal", "WaterChartModal");
    commit("setTitle", "水質管理経過グラフ");
  },
  hideModal({ commit }) {
    commit("hideModal");
  },
  showDailyModal({ commit }) {
    commit("setModal", "showDailyModal");
    commit("setTitle", "点検項目入力");
  },
  showMachineModal({ commit }) {
    commit("setModal", "showMachineModal");
    commit("setTitle", "部品の運転／交換時間");
  },
  showHistoryModal({ commit }) {
    commit("setModal", "showHistoryModal");
    commit("setTitle", "定期点検履歴");
  },
  showPeriodicModal({ commit }) {
    commit("setModal", "showPeriodicModal");
    commit("setTitle", "定期点検結果登録");
  },
  showPeriodicCalendar({ commit }) {
    commit("setModal", "PeriodicCalendarModal");
    commit("setTitle", "点検予定日選択");
  },
  showReportList({ commit }) {
    commit("setModal", "ReportListModal");
    commit("setTitle", "レポート選択");
  },
  showIndicationsDiffModal({ commit }) {
    commit("setModal", "indicationDiffForStatusMap");
    commit("setTitle", "指示変更内容");
  },
  showIndicationsHistoryModal({ commit }, title) {
    commit("setModal", "IndicationsHistoryModal");
    commit("setTitle", title);
  },
  showElectrocardiogram({ commit }) {
    commit("setModal", "Electrocardiogram");
    commit("setTitle", "心電図");
  },
  showAralmDetail({ commit }) {
    commit("setModal", "StatusMapAlarmDetailModal");
    commit("setTitle", "警報報知");
  },
  showKurDoctorComponent({ commit }) {
    commit("setModal", "KurDoctorComponent");
    commit("setTitle", "医師シフト設定");
  },
  showMultiDeviceEdgeManageModal({ commit }) {
    commit("setModal", "MultiDeviceEdgeManageModal");
    commit("setTitle", "デバイスエッジ一括管理");
  },
  showMntFindMachineModal({ commit }) {
    commit("setModal", "MntFindMachineModal");
    commit("setTitle", "装置検索登録");
  },
  showMstSelfMeasureResultMainModal({ commit }) {
    commit("setModal", "MstSelfMeasureResultMainModal");
    commit("setTitle", "自己診断判定マスタ詳細");
  },
  showMstExamItemRecManagementModal({ commit }) {
    commit("setModal", "MstExamItemRecManagementModal");
    commit("setTitle", "再検査計算管理");
  },
  showMstExamItemRecBookingModal({ commit }) {
    commit("setModal", "MstExamItemRecBookingModal");
    commit("setTitle", "再検査計算予約");
  },
};

const getters = {
  isModalOpened: state => {
    return state.modalName !== "";
  },
  getModalName: state => {
    return state.modalName;
  },
  getModalTitle: state => {
    return state.modalTitle;
  },
  getAuthorityCds: state => {
    return state.modalAuthorityCds;
  },
  getInitValues: state => {
    return state.modalInitValues;
  }
};

export default {
  namespaced: true,
  state,
  mutations,
  actions,
  getters
};
