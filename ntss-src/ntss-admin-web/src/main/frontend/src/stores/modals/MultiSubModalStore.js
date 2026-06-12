
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
  showDeviceSetInfoSubModal({ commit }, title) {
    commit("setModal", "DeviceSetInfoSubModal");
    commit("setTitle", title);
  },
  showComplaintCreate({ commit }, initValues) {
    commit("setModal", "ComplaintCreate");
    commit("setTitle", "愁訴処置登録");
    commit("setInitValues", initValues);
  },
  showAddressSearchModal({ commit }, initValues) {
    commit("setModal", "AddressSearch");
    commit("setTitle", "住所検索");
    commit("setInitValues", initValues);
  },
  showShrPatSearch({ commit }) {
    commit("setModal", "ShrPatSearch");
    commit("setTitle", "共有患者選択");
  },
  hideModal({ commit }) {
    commit("hideModal");
  },
  // add FNSI-水質検査結果登録で備考欄を追加する 周 start
  /**
   * 水質検査結果備考登録モーダル画面を表示する.
   *
   * @param {*} commit commitオブジェクト
   */
  showWaterResultMemoEditSubModal({ commit }) {
    commit("setModal", "WaterResultMemoEditSubModal");
    commit("setTitle", "水質検査結果備考登録");
  },
  // add FNSI-水質検査結果登録で備考欄を追加する 周 end
  /**
   * 標準医薬品マスタ検索モーダル画面を表示する.
   *
   * @param {*} commit commitオブジェクト
   */
  showSysMedicineSearchSubModal({commit}) {
    commit("setModal", "SysMedicineSearchSubModal");
    commit("setTitle", "標準医薬品マスタ検索");
  },
  // add IES 臨床検査マスタ検索追加する Du start
    /**
   * 標準医薬品マスタ検索モーダル画面を表示する.
   *
   * @param {*} commit commitオブジェクト
   */

    showMstExamMatomeSearchSubModal({commit}) {
    commit("setModal", "MstExamMatomeSearchSubModal");
    commit("setTitle", "臨床検査マスタ検索");
  },
  // add IES 臨床検査マスタ検索追加する Du end
  /**
   * 帳票グラフ設定モーダル画面を表示する.
   *
   * @param {*} commit commitオブジェクト
   */
  showReportGraphSettingSubModal({ commit }) {
    commit("setModal", "ReportGraphSettingSubModal");
    commit("setTitle", "帳票グラフ設定");
  },
  //add FNSI修正486改修 房 start
  showResultMergePatSearchModal({ commit }){
    commit("setModal", "ResultMergePatSearchModal");
    commit("setTitle", "実績マージデータ選択");
  },
  //add FNSI修正486改修 房 end
  // FNSI-add 除外期間の追加 徐 start
  showPatExcludedPeriod({ commit }) {
    commit("setModal", "PatExcludedPeriod");
    commit("setTitle", "除外期間");
  },
  // FNSI-add 除外期間の追加 徐 end
  showPatPrescriptionSelectDrugSub({ commit }) {
    commit("setModal", "PatPrescriptionSelectDrugModal");
    commit("setTitle", "処方薬剤選択");
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
