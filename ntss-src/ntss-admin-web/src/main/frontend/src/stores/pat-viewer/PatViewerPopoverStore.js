/**
 * 日付操作
 */
import moment from "moment";

export default {
  namespaced: true,
  strict: true,

  state: {
    /**
     * オーダー番号
     */
    ordNo: null,

    /**
     * 治療日
     */
    treatDate: null,

    /**
     * 治療予定状態(true: 治療予定あり、 false: 治療予定なし)
     */
    isTreatPlan: false,

    /**
     * セルの値
     */
    cellValue: null,

    /**
     * 治療予定メニューポップオーバー表示／非表示切替
     */
    isShowTreatPlanMenuPopover: false,

    /**
     * 治療予定メニューポップオーバー表示処理箇所のイベント情報
     */
    targetTreatPlanMenuPopover: null,

    /**
     * 治療予定メニューポップオーバー表示位置("up"、"down"、"left"、"right")
     */
    directionTreatPlanMenuPopover: "down",

    /**
     * 治療予定メニューポップオーバー「オーダー番号」表示/非表示切り替え
     */
    isShowTreatPlanMenuPopoverDisplayOrdNo: false,

    /**
     * 治療予定メニューポップオーバー「治療予定作成」ボタン 表示/非表示切り替え
     */
    isShowTreatPlanMenuPopoverCreateButton: false,

    /**
     * 治療予定メニューポップオーバー「治療予定コピー」ボタン 表示/非表示切り替え
     */
    isShowTreatPlanMenuPopoverCopyButton: false,

    /**
     * 治療予定メニューポップオーバー「治療予定移動」ボタン 表示/非表示切り替え
     */
    isShowTreatPlanMenuPopoverMoveButton: false,

    /**
     * 治療予定メニューポップオーバー「治療予定中止」ボタン 表示/非表示切り替え
     */
    isShowTreatPlanMenuPopoverDeleteButton: false,

    /**
     * 治療予定メニューポップオーバー「曜日パターン変更」ボタン 表示/非表示切り替え
     */
    isShowTreatPlanMenuPopoverWeekPatternButton: false,

    /**
     * 治療予定メニューポップオーバー「手動実績作成」ボタン 表示/非表示切り替え
     */
    isShowTreatPlanMenuPopoverRstCreateButton: false,

    /**
     * 治療予定コピーフラグ 0->コピー元、1->コピー先となる
     */
    copyFlag: "0",
    /**
     * モーダルに渡す情報
     */
    modalInfo: {
      ordNo: null,
      treatDate: null,
      isOneDay: false,
      dialysisState: null
    },
    
    treatmentData: null,

    /**
     * 物品系マスタの使用期限判定の為に開始日を格納
     * (指示ダイアログの値を下位部品で参照する為の一時保存場所)
     */
    indStartDate: ""
  },

  getters: {
    /**
     * オーダー番号の取得
     */
    getOrdNo(state) {
      return state.ordNo;
    },

    /**
     * 治療日の取得
     */
    getTreatDate(state) {
      return state.treatDate;
    },

    /**
     * 治療予定状態
     */
    getIsTreatPlan(state) {
      return state.isTreatPlan;
    },

    /**
     * 治療状況
     */
    getCellValue(state) {
      return state.cellValue;
    },

    /**
     * 治療予定メニューポップオーバー表示／非表示切替を取得
     */
    getIsShowTreatPlanMenuPopover(state) {
      return state.isShowTreatPlanMenuPopover;
    },

    /**
     * 治療予定メニューポップオーバー表示処理箇所のイベント情報を取得
     */
    getTargetTreatPlanMenuPopover(state) {
      return state.targetTreatPlanMenuPopover;
    },

    /**
     * 治療予定メニューポップオーバー表示位置("up"、"down"、"left"、"right")を取得
     */
    getDirectionTreatPlanMenuPopover(state) {
      return state.directionTreatPlanMenuPopover;
    },

    /**
     * 治療予定メニューポップオーバー「オーダー番号」表示/非表示切り替え
     */
    getIsShowTreatPlanMenuPopoverDisplayOrdNo(state) {
      return state.isShowTreatPlanMenuPopoverDisplayOrdNo;
    },

    /**
     * 治療予定メニューポップオーバー「治療予定作成」表示／非表示切替を取得
     */
    getIsShowTreatPlanMenuPopoverCreateButton(state) {
      return state.isShowTreatPlanMenuPopoverCreateButton;
    },

    /**
     * 治療予定メニューポップオーバー「治療予定コピー」表示／非表示切替を取得
     */
    getIsShowTreatPlanMenuPopoverCopyButton(state) {
      return state.isShowTreatPlanMenuPopoverCopyButton;
    },

    /**
     * 治療予定メニューポップオーバー「治療予定移動」表示／非表示切替を取得
     */
    getIsShowTreatPlanMenuPopoverMoveButton(state) {
      return state.isShowTreatPlanMenuPopoverMoveButton;
    },

    /**
     * 治療予定メニューポップオーバー「治療予定中止」表示／非表示切替を取得
     */
    getIsShowTreatPlanMenuPopoverDeleteButton(state) {
      return state.isShowTreatPlanMenuPopoverDeleteButton;
    },

    /**
     * 治療予定メニューポップオーバー「曜日パターン変更」表示／非表示切替を取得
     */
    getIsShowTreatPlanMenuPopoverWeekPatternButton(state) {
      return state.isShowTreatPlanMenuPopoverWeekPatternButton;
    },

    /**
     * 治療予定メニューポップオーバー「手動実績作成」表示／非表示切替を取得
     */
    getIsShowTreatPlanMenuPopoverRstCreateButton(state) {
      return state.isShowTreatPlanMenuPopoverRstCreateButton;
    },

    /**
     * 治療予定コピーフラグ
     * state参照
     */
    getCopyFlag(state) {
      return state.copyFlag;
    },
    /**
     * 治療予定メニュー情報
     */
    getModalInfo(state) {
      return state.modalInfo;
    },

    getTreatmentData(state) {
      return state.treatmentData;
    },

    /**
     * 開始日を取得
     */
    getIndStartDate(state) {
      return state.indStartDate;
    }
  },

  mutations: {
    /**
     * オーダー番号を格納
     */
    commitOrdNo(state, ordNo) {
      state.ordNo = ordNo;
    },

    /**
     * 治療日を格納
     */
    commitTreatDate(state, treatDate) {
      state.treatDate = treatDate;
    },

    /**
     * 治療予定状態を格納
     */
    commitIsTreatPlan(state, isTreatPlan) {
      state.isTreatPlan = isTreatPlan;
    },

    /**
     * 治療状況を格納
     */
    commitCellValue(state, cellValue) {
      state.cellValue = cellValue;
    },

    /**
     * 治療予定メニューポップオーバー表示／非表示切替を格納
     * @param {Boolean} isShowTreatPlanMenuPopover true：表示、false：非表示
     */
    commitIsShowTreatPlanMenuPopover(state, isShowTreatPlanMenuPopover) {
      state.isShowTreatPlanMenuPopover = isShowTreatPlanMenuPopover;
    },

    /**
     * 治療予定メニューポップオーバー表示処理箇所のイベント情報を格納
     * @param {event} targetTreatPlanMenuPopover イベント情報
     */
    commitTargetTreatPlanMenuPopover(state, targetTreatPlanMenuPopover) {
      state.targetTreatPlanMenuPopover = targetTreatPlanMenuPopover;
    },

    /**
     * 治療予定メニューポップオーバー表示位置を格納
     * @param {String} directionTreatPlanMenuPopover ポップオーバー表示位置("up"、"down"、"left"、"right")
     */
    commitDirectionTreatPlanMenuPopover(state, directionTreatPlanMenuPopover) {
      state.directionTreatPlanMenuPopover = directionTreatPlanMenuPopover;
    },

    /**
     * 治療予定メニューポップオーバー「オーダー番号」 表示／非表示切替を格納
     * @param {Boolean} isShowTreatPlanMenuPopoverDisplayOrdNo true：表示、false：非表示
     */
    commitIsShowTreatPlanMenuPopoverDisplayOrdNo(
      state,
      isShowTreatPlanMenuPopoverDisplayOrdNo
    ) {
      state.isShowTreatPlanMenuPopoverDisplayOrdNo = isShowTreatPlanMenuPopoverDisplayOrdNo;
    },

    /**
     * 治療予定メニューポップオーバー「治療予定作成」ボタン 表示／非表示切替を格納
     * @param {Boolean} isShowTreatPlanMenuPopoverCreateButton true：表示、false：非表示
     */
    commitIsShowTreatPlanMenuPopoverCreateButton(
      state,
      isShowTreatPlanMenuPopoverCreateButton
    ) {
      state.isShowTreatPlanMenuPopoverCreateButton = isShowTreatPlanMenuPopoverCreateButton;
    },

    /**
     * 治療予定メニューポップオーバー「治療予定コピー」ボタン 表示／非表示切替を格納
     * @param {Boolean} isShowTreatPlanMenuPopoverCopyButton true：表示、false：非表示
     */
    commitIsShowTreatPlanMenuPopoverCopyButton(
      state,
      isShowTreatPlanMenuPopoverCopyButton
    ) {
      state.isShowTreatPlanMenuPopoverCopyButton = isShowTreatPlanMenuPopoverCopyButton;
    },

    /**
     * 治療予定メニューポップオーバー「治療予定移動」ボタン 表示／非表示切替を格納
     * @param {Boolean} isShowTreatPlanMenuPopoverMoveButton true：表示、false：非表示
     */
    commitIsShowTreatPlanMenuPopoverMoveButton(
      state,
      isShowTreatPlanMenuPopoverMoveButton
    ) {
      state.isShowTreatPlanMenuPopoverMoveButton = isShowTreatPlanMenuPopoverMoveButton;
    },

    /**
     * 治療予定メニューポップオーバー「治療予定中止」ボタン 表示／非表示切替を格納
     * @param {Boolean} isShowTreatPlanMenuPopoverDeleteButton true：表示、false：非表示
     */
    commitIsShowTreatPlanMenuPopoverDeleteButton(
      state,
      isShowTreatPlanMenuPopoverDeleteButton
    ) {
      state.isShowTreatPlanMenuPopoverDeleteButton = isShowTreatPlanMenuPopoverDeleteButton;
    },

    /**
     * 治療予定メニューポップオーバー「曜日パターン変更」ボタン 表示／非表示切替を格納
     * @param {Boolean} isShowTreatPlanMenuPopoverWeekPatternButton true：表示、false：非表示
     */
    commitIsShowTreatPlanMenuPopoverWeekPatternButton(
      state,
      isShowTreatPlanMenuPopoverWeekPatternButton
    ) {
      state.isShowTreatPlanMenuPopoverWeekPatternButton = isShowTreatPlanMenuPopoverWeekPatternButton;
    },

    /**
     * 治療予定メニューポップオーバー「手動実績作成」ボタン 表示／非表示切替を格納
     * @param {Boolean} isShowTreatPlanMenuPopoverRstCreateButton true：表示、false：非表示
     */
    commitIsShowTreatPlanMenuPopoverRstButton(
      state,
      isShowTreatPlanMenuPopoverRstCreateButton
    ) {
      state.isShowTreatPlanMenuPopoverRstCreateButton = isShowTreatPlanMenuPopoverRstCreateButton;
    },

    /**
     * コピーフラグを格納
     * state参照
     */
    commitCopyFlag(state, copyFlag) {
      state.copyFlag = copyFlag;
    },

    /**
     * モーダル情報を格納
     * states何章
     */
    commitModalInfo(state, modalInfo) {
      state.modalInfo = modalInfo;
    },

    setTreatmentData(state, treatmentData) {
      state.treatmentData = treatmentData;
    },

    /**
     * 開始日を格納
     */
    setIndStartDate(state, indStartDate) {
      if (indStartDate) {
        state.indStartDate = indStartDate;
      }
    }
  },

  actions: {
    /**
     * クリックしたセル情報の格納
     */
    setCellInfo({ commit }, { cellInfo }) {
      commit("commitOrdNo", cellInfo.ordNo);
      commit("commitTreatDate", cellInfo.treatDate);
      const istreatPlan = null !== cellInfo.ordNo ? true : false;
      commit("commitIsTreatPlan", istreatPlan);
      commit("commitCellValue", cellInfo.value1);
    },

    /**
     * クリックした日付情報の格納
     */
    setTreatDate({ commit }, { treatDate }) {
      commit("commitTreatDate", treatDate);
    },

    /**
     * 治療予定メニューポップオーバーを非表示
     */
    setHideTreatPlanMenuPopover({ commit }) {
      // セル情報初期化
      commit("commitOrdNo", null);
      commit("commitTreatDate", null);
      commit("commitIsTreatPlan", false);
      // ポップオーバー・ポップオーバー内のボタンを非表示
      commit("commitIsShowTreatPlanMenuPopover", false);
      commit("commitIsShowTreatPlanMenuPopoverDisplayOrdNo", false);
      commit("commitIsShowTreatPlanMenuPopoverCreateButton", false);
      commit("commitIsShowTreatPlanMenuPopoverCopyButton", false);
      commit("commitIsShowTreatPlanMenuPopoverMoveButton", false);
      commit("commitIsShowTreatPlanMenuPopoverDeleteButton", false);
      commit("commitIsShowTreatPlanMenuPopoverWeekPatternButton", false);
      commit("commitIsShowTreatPlanMenuPopoverRstButton", false);
    },

    /**
     * 治療予定メニューポップオーバー表示設定
     * @param buttonInfo {Object} 表示情報
     */
    setShowTreatPlanMenuPopover({ commit }, { menuInfo }) {
      // 治療日格納
      const treatDate = menuInfo.treatDate
        ? moment(menuInfo.treatDate).format("YYYY-MM-DD")
        : "";
      commit("commitTreatDate", treatDate);
      // オーダー番号格納
      commit("commitOrdNo", menuInfo.ordNo);
      // モダール情報を格納
      const modalInfo = {};
      // オーダー番号を格納
      modalInfo.ordNo = menuInfo.ordNo;
      // 治療日を格納
      modalInfo.treatDate = treatDate;
      // 1日限定フラグを格納
      modalInfo.isOneDay = menuInfo.isOneDay;
      // モーダルにわたす情報を格納
      commit("commitModalInfo", modalInfo);
      // オーダー番号表示設定
      commit(
        "commitIsShowTreatPlanMenuPopoverDisplayOrdNo",
        true === menuInfo.isShowOrdNo
      );
      // 治療予定作成ボタン表示設定
      commit(
        "commitIsShowTreatPlanMenuPopoverCreateButton",
        true === menuInfo.isShowCreate
      );
      // 予定コピーボタン表示設定
      commit(
        "commitIsShowTreatPlanMenuPopoverCopyButton",
        true === menuInfo.isShowCopy
      );
      // 予定移動ボタン表示設定
      commit(
        "commitIsShowTreatPlanMenuPopoverMoveButton",
        true === menuInfo.isShowMove
      );
      // 予定中止ボタン表示設定
      commit(
        "commitIsShowTreatPlanMenuPopoverDeleteButton",
        true === menuInfo.isShowDelete
      );
      // 曜日パターン変更ボタン表示設定
      commit(
        "commitIsShowTreatPlanMenuPopoverWeekPatternButton",
        true === menuInfo.isShowWeekPattern
      );
      // 手動実績作成ボタン表示設定
      commit(
        "commitIsShowTreatPlanMenuPopoverRstButton",
        true === menuInfo.isShowRst
      );
      // 治療予定メニューポップオーバーターゲット設定
      commit("commitTargetTreatPlanMenuPopover", menuInfo.target);
      // 治療予定メニューポップオーバー表示方向の設定
      commit("commitDirectionTreatPlanMenuPopover", menuInfo.direction);
      commit("setTreatmentData", menuInfo.treatmentData);
      // 治療予定メニューポップオーバー表示設定
      commit("commitIsShowTreatPlanMenuPopover", true);
    },

    /**
     * 治療予定コピーフラグ格納
     * state参照
     */
    setCopyFlag({ commit }, { copyFlag }) {
      commit("commitCopyFlag", copyFlag);
    }
  }
};
