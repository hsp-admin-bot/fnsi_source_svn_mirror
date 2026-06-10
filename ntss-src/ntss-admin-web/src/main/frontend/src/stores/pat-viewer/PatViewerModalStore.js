import { deepCopy } from "@/functions/common/CommonFunctions";
import MODAL_TITLE from "@/components/common/ModalTitleContrast.js";

/**
 * 指示系モーダルへ渡す必要があるデータの雛型
 */
const defaultSettingIndData = {
  // ヘッダーに表示するタイトル
  headerTitle: "",
  // 表示対象の患者ID
  patId: null,
  // 施設コード
  facilityCd: null,
  // 開始日
  startDate: null,
  // 終了日
  endDate: null,
  // 通常予定 or 隔日予定 or 隔週予定で登録するかを切り替えるボタンのラベル
  segmentLabel1: "通常",
  segmentLabel2: "隔日",
  segmentLabel5: "隔週",
  // 編集時に表示した際、編集を行うか中止を行うかを切り替えるボタンのラベル
  segmentLabel3: "編集",
  segmentLabel4: "中止",
  // 【通常】【隔日】切替ボタンの表示／非表示
  showSegment: false,
  // 【編集】【中止】切替ボタンの表示／非表示
  // 本値が false、かつ、showDelete が false の場合、個別保存ボタンが表示される
  showNewEdit: false,
  // 個別中止ボタンの表示／非表示
  showDelete: false,
  // 曜日ボタンの表示／非表示
  showWeeks: false,
  // 各曜日の選択状態(true：選択、false：未選択)
  monday: false,
  tuesday: false,
  wednesday: false,
  thursday: false,
  friday: false,
  saturday: false,
  sunday: false,
  // 治療方法選択の表示／非表示
  showTreat: false,
  // クール選択の表示／非表示
  showKur: false,
  // IndEditBase の<slot>に表示するコンポーネントの上下に表示する区切り線の表示／非表示
  hrOnder: false,
  hrUnder: false
};

export default {
  namespaced: true,
  strict: true,

  state: {
    /**
     * モーダル表示するコンポーネントID
     */
    dispComponentId: null,

    /**
     * 指示系モーダル表示／非表示切替
     */
    isShowIndModal: false,

    /**
     * 治療予定コピーモーダル表示/非表示
     */
    isShowPlanCopyModal: false,

    /**
     * 治療予定移動モーダル表示/非表示
     */
    isShowPlanMoveModal: false,

    /**
     * 曜日パターン変更モーダル表示/非表示
     */
    isShowWeekPatternModal: false,

    /**
     * 手動実績作成モーダル表示/非表示
     */
    isShowRstCreateModal: false,

    /**
     * 投与薬剤新規登録モーダル表示/非表示
     */
    // isShowIndMediBaseModal: false,
    isShowMediCreateModal: false,

    /**
     * 投与薬剤編集モーダル表示/非表示
     */
    isShowMediEditModal: false,

    /**
     * UFRプログラム編集モーダル表示/非表示
     */
    isShowUfrProgramModal: false,

    /**
     * Naプログラム編集モーダル表示/非表示
     */
    isShowNaProgramModal: false,

    /**
     * 透析液濃度プログラム編集モーダル表示/非表示
     */
    isShowDialysateProgramModal: false,

    /**
     * QbQdプログラム編集モーダル表示/非表示
     */
    isShowQbqdProgramModal: false,

    /**
     * IHdfプログラム編集モーダル表示/非表示
     */
    isShowIHdfProgramModal: false,

    /**
     * 透析量プログラム編集モーダル表示/非表示
     */
    isShowDiaysisProgramModal: false,

    /**
     * BV-Ufc編集モーダル表示/非表示
     */
    isShowBvUfcModal: false,

    /**
     * DW編集モーダル表示/非表示
     */
    isShowDwModal: false,

    /**
     * 指示系モーダルへ渡す必要があるデータ
     */
    settingIndData: {},

    /**
     * 指示系モーダル子コンポーネントに渡すデータ
     */
    settingIndChildData: {},

    /**
     * メッセージダイアログ表示/非表示
     */
    isShowMessageDialog: false,

    /**
     * 基準日
     */
    baseDate: null,
    // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start
    /**
     * ihdf 編集維持DevA
     */
    ihdfAnswerThreeDevA: null,
    // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end

    /**
     * 計算用透析時間保持用
     */
    dialysisTimeData:null
  },

  getters: {
    /**
     * モーダル表示するコンポーネントIDを取得
     */
    getDispComponentId(state) {
      return state.dispComponentId;
    },

    /**
     * 指示系モーダル表示／非表示切替を取得
     */
    getIsShowIndModal(state) {
      return state.isShowIndModal;
    },

    /**
     * 治療予定コピー表示/非表示切替を取得
     */
    getIsShowPlanCopyModal(state) {
      return state.isShowPlanCopyModal;
    },

    /**
     * 治療予定移動表示/非表示切替を取得
     */
    getIsShowPlanMoveModal(state) {
      return state.isShowPlanMoveModal;
    },

    /**
     * 曜日パターン変更表示/非表示切替を取得
     */
    getIsShowWeekPatternModal(state) {
      return state.isShowWeekPatternModal;
    },

    /**
     * 手動実績作成表示/非表示切替を取得
     */
    getIsShowRstCreateModal(state) {
      return state.isShowRstCreateModal;
    },

    /**
     * 投与薬剤新規モーダル表示/非表示切替を取得
     */
    getIsShowMediCreateModal(state) {
      return state.isShowMediCreateModal;
    },

    /**
     * 投与薬剤編集モーダル表示/非表示切替を取得
     */
    getIsShowMediEditModal(state) {
      return state.isShowMediEditModal;
    },

    /**
     * UFRプログラム編集モーダル表示/非表示切替を取得
     */
    getIsShowUfrProgramModal(state) {
      return state.isShowUfrProgramModal;
    },

    /**
     * Naプログラム編集モーダル表示/非表示切替を取得
     */
    getIsShowNaProgramModal(state) {
      return state.isShowNaProgramModal;
    },

    /**
     * 透析液濃度プログラム編集モーダル表示/非表示切替を取得
     */
    getIsShowDialysateProgramModal(state) {
      return state.isShowDialysateProgramModal;
    },

    /**
     * QbQdプログラム編集モーダル表示/非表示切替を取得
     */
    getIsShowQbqdProgramModal(state) {
      return state.isShowQbqdProgramModal;
    },

    /**
     * IHdfプログラム編集モーダル表示/非表示切替を取得
     */
    getIsShowIHdfProgramModal(state) {
      return state.isShowIHdfProgramModal;
    },

    /**
     * 透析量プログラム編集モーダル表示/非表示切替を取得
     */
    getIsShowDiaysisProgramModal(state) {
      return state.isShowDiaysisProgramModal;
    },

    /**
     * BV-UFC編集モーダル表示/非表示切替を取得
     */
    getIsShowBvUfcModal(state) {
      return state.isShowBvUfcModal;
    },

    /**
     * Dw編集モーダル表示/非表示切替を取得
     */
    getIsShowDwModal(state) {
      return state.isShowDwModal;
    },

    /**
     * 指示系モーダルへ渡す必要があるデータを取得
     */
    getSettingIndData(state) {
      return state.settingIndData;
    },

    /**
     * 指示系モーダル子コンポーネントへ渡す必要があるデータ取得
     */
    getSettingIndChildData(state) {
      return state.settingIndChildData;
    },

    /**
     * 指示系モーダルへ渡す必要があるデータを取得(※雛型)
     */
    getDefaultSettingIndData() {
      return deepCopy(defaultSettingIndData);
    },

    /**
     * 治療予定モーダル(予定作成)に渡すデータを取得(※雛型)
     */
    getDefaultSettingIndPlanCreateNewData() {
      // 雛型をコピー
      const settingData = deepCopy(defaultSettingIndData);

      // モーダルのヘッダータイトル
      settingData.headerTitle = MODAL_TITLE["予定作成"];
      // 【通常】【隔日】切替ボタン-表示
      settingData.showSegment = true;
      // 【編集】【中止】切替ボタン-非表示
      settingData.showNewEdit = false;
      // 中止ボタン-非表示
      settingData.showDelete = false;
      // 曜日ボタン-表示
      settingData.showWeeks = true;
      // 各曜日-未選択
      settingData.allWeek = true;
      settingData.monday = true;
      settingData.tuesday = true;
      settingData.wednesday = true;
      settingData.thursday = true;
      settingData.friday = true;
      settingData.saturday = true;
      settingData.sunday = true;
      // 治療方法選択-非表示
      settingData.showTreat = false;
      // クール選択-非表示
      settingData.showKur = false;
      // 上下区切り線-表示
      settingData.hrOnder = true;
      settingData.hrUnder = false;

      return settingData;
    },

    /**
     * 治療予定モーダル(中止)に渡すデータを取得(※雛型)
     */
    getDefaultSettingIndPlanCreateDeleteData() {
      // 雛型をコピー
      const settingData = deepCopy(defaultSettingIndData);

      // モーダルのヘッダータイトル
      settingData.headerTitle = MODAL_TITLE["予定中止"];
      // 【通常】【隔日】切替ボタン-非表示
      settingData.showSegment = false;
      // 【編集】【中止】切替ボタン-非表示
      settingData.showNewEdit = false;
      // 中止ボタン-表示
      settingData.showDelete = true;
      // 曜日ボタン-表示
      settingData.showWeeks = false;
      // 各曜日-選択
      settingData.allWeek = false;
      settingData.monday = true;
      settingData.tuesday = true;
      settingData.wednesday = true;
      settingData.thursday = true;
      settingData.friday = true;
      settingData.saturday = true;
      settingData.sunday = true;
      // 治療方法選択-表示
      settingData.showTreat = true;
      // クール選択-表示
      settingData.showKur = true;
      // 上区切り線-非表示
      settingData.hrOnder = true;
      // 下区切り線-表示
      settingData.hrUnder = false;

      return settingData;
    },

    /**
     * 治療方法に渡すデータ取得(※ひな形)
     */
    getDefaultSettingIndTreatMethodData() {
      // 雛形をコピー
      const settingData = deepCopy(defaultSettingIndData);
      // モーダルのヘッダータイトル
      settingData.headerTitle = MODAL_TITLE["治療方法編集"];
      // 【通常】【隔日】切替ボタン-非表示
      settingData.showSegment = false;
      // 中止ボタン-非表示
      settingData.showDelete = false;
      // 曜日ボタン-表示
      settingData.showWeeks = true;
      // 各曜日-選択
      settingData.allWeek = true;
      settingData.monday = true;
      settingData.tuesday = true;
      settingData.wednesday = true;
      settingData.thursday = true;
      settingData.friday = true;
      settingData.saturday = true;
      settingData.sunday = true;
      // 治療方法選択-表示
      settingData.showTreat = true;
      // クール選択-表示
      settingData.showKur = true;
      // 上区切り線-非表示
      settingData.hrOnder = true;
      // 下区切り線-表示
      settingData.hrUnder = false;

      return settingData;
    },

    /**
     * スケジュールにわたすデータ取得(※ひな形)
     */
    getDefaultSettingIndScheduleData() {
      // 雛形をコピー
      const settingData = deepCopy(defaultSettingIndData);

      // モーダルのヘッダータイトル
      settingData.headerTitle = MODAL_TITLE["スケジュール編集"];
      // 【通常】【隔日】切替ボタン-非表示
      settingData.showSegment = false;
      // 中止ボタン-非表示
      settingData.showDelete = false;
      // 曜日ボタン-表示
      settingData.showWeeks = true;
      // 各曜日-選択
      settingData.allWeek = true;
      settingData.monday = true;
      settingData.tuesday = true;
      settingData.wednesday = true;
      settingData.thursday = true;
      settingData.friday = true;
      settingData.saturday = true;
      settingData.sunday = true;
      // 治療方法選択-表示
      settingData.showTreat = true;
      // クール選択-表示
      settingData.showKur = true;
      // 上区切り線-非表示
      settingData.hrOnder = true;
      // 下区切り線-表示
      settingData.hrUnder = false;

      return settingData;
    },

    /**
     * 治療条件に渡すデータを取得(雛形)
     */
    getDefaultSettingIndConditionData() {
      // 雛形をコピー
      const settingData = deepCopy(defaultSettingIndData);

      // モーダルのヘッダータイトル
      settingData.headerTitle = MODAL_TITLE["治療条件編集"];
      // 【通常】【隔日】切替ボタン-非表示
      settingData.showSegment = false;
      // 中止ボタン-非表示
      settingData.showDelete = false;
      // 曜日ボタン-表示
      settingData.showWeeks = true;
      // 各曜日-選択
      settingData.allWeek = true;
      settingData.monday = true;
      settingData.tuesday = true;
      settingData.wednesday = true;
      settingData.thursday = true;
      settingData.friday = true;
      settingData.saturday = true;
      settingData.sunday = true;
      // 治療方法選択-表示
      settingData.showTreat = true;
      // クール選択-表示
      settingData.showKur = true;
      // 上区切り線-非表示
      settingData.hrOnder = true;
      // 下区切り線-表示
      settingData.hrUnder = false;

      return settingData;
    },

    /**
     * 投与薬剤に渡すデータを取得()
     */
    getDefaultSettingMedicineData() {
      // 雛形をコピー
      const settingData = deepCopy(defaultSettingIndData);

      // モーダルのヘッダータイトル
      settingData.headerTitle = MODAL_TITLE["投与薬剤編集"];
      // 【通常】【隔日】切替ボタン-非表示
      settingData.showSegment = false;
      // 中止ボタン-非表示
      settingData.showDelete = false;
      // 曜日ボタン-表示
      settingData.showWeeks = true;
      // 各曜日-選択
      settingData.allWeek = true;
      settingData.monday = true;
      settingData.tuesday = true;
      settingData.wednesday = true;
      settingData.thursday = true;
      settingData.friday = true;
      settingData.saturday = true;
      settingData.sunday = true;
      // 治療方法選択-表示
      settingData.showTreat = true;
      // クール選択-表示
      settingData.showKur = true;
      // 上区切り線-非表示
      settingData.hrOnder = true;
      // 下区切り線-表示
      settingData.hrUnder = false;

      return settingData;
    },

    /**
     * 医療材料に渡すデータを取得(※雛形)
     */
    getDefaultSettingIndEquipmentData() {
      // 雛形をコピー
      const settingData = deepCopy(defaultSettingIndData);

      // モーダルのヘッダータイトル
      settingData.headerTitle = MODAL_TITLE["医療材料編集"];
      // 【通常】【隔日】切替ボタン-非表示
      settingData.showSegment = false;
      // 編集フラグ-未設定
      settingData.showNewEdit = false;
      // 中止ボタン-非表示
      settingData.showDelete = false;
      // 曜日ボタン-表示
      settingData.showWeeks = true;
      // 各曜日-選択
      settingData.allWeek = true;
      settingData.monday = true;
      settingData.tuesday = true;
      settingData.wednesday = true;
      settingData.thursday = true;
      settingData.friday = true;
      settingData.saturday = true;
      settingData.sunday = true;
      // 治療方法選択-表示
      settingData.showTreat = true;
      // クール選択-表示
      settingData.showKur = true;
      // 上区切り線-非表示
      settingData.hrOnder = true;
      // 下区切り線-表示
      settingData.hrUnder = false;

      return settingData;
    },

    /**
     * 指示コメントに渡すデータを取得(※雛型)
     */
    getDefaultSettingIndCommentData() {
      // 雛型をコピー
      const settingData = deepCopy(defaultSettingIndData);

      // モーダルのヘッダータイトル
      settingData.headerTitle = MODAL_TITLE["指示コメント編集"];
      // 【通常】【隔日】切替ボタン-非表示
      settingData.showSegment = false;
      // 中止ボタン-非表示
      settingData.showDelete = false;
      // 曜日ボタン-表示
      settingData.showWeeks = true;
      // 各曜日-選択
      settingData.allWeek = true;
      settingData.monday = true;
      settingData.tuesday = true;
      settingData.wednesday = true;
      settingData.thursday = true;
      settingData.friday = true;
      settingData.saturday = true;
      settingData.sunday = true;
      // 治療方法選択-表示
      settingData.showTreat = true;
      // クール選択-表示
      settingData.showKur = true;
      // 上区切り線-非表示
      settingData.hrOnder = true;
      // 下区切り線-表示
      settingData.hrUnder = false;

      return settingData;
    },

    /**
     * 風袋に渡すデータを取得
     */
    getDefaultSettingTareInfoData() {
      // 雛型をコピー
      const settingData = deepCopy(defaultSettingIndData);

      // モーダルのヘッダータイトル
      settingData.headerTitle = MODAL_TITLE["風袋編集"];
      // 【通常】【隔日】切替ボタン-非表示
      settingData.showSegment = false;
      // 中止ボタン-非表示
      settingData.showDelete = false;
      // 曜日ボタン-表示
      settingData.showWeeks = true;
      // 各曜日-選択
      settingData.allWeek = true;
      settingData.monday = true;
      settingData.tuesday = true;
      settingData.wednesday = true;
      settingData.thursday = true;
      settingData.friday = true;
      settingData.saturday = true;
      settingData.sunday = true;
      // 治療方法選択-表示
      settingData.showTreat = true;
      // クール選択-表示
      settingData.showKur = true;
      // 上区切り線-非表示
      settingData.hrOnder = true;
      // 下区切り線-表示
      settingData.hrUnder = false;
      // 指示者選択不可フラグ
      settingData.disIndUserEdit = true;

      return settingData;
    },

    /**
     * 除水補正に渡すデータを取得
     */
    getDefaultSettingOffWaterInfoData() {
      // 雛型をコピー
      const settingData = deepCopy(defaultSettingIndData);

      // モーダルのヘッダータイトル
      settingData.headerTitle = MODAL_TITLE["除水補正編集"];
      // 【通常】【隔日】切替ボタン-非表示
      settingData.showSegment = false;
      // 中止ボタン-非表示
      settingData.showDelete = false;
      // 曜日ボタン-表示
      settingData.showWeeks = true;
      // 各曜日-選択
      settingData.allWeek = true;
      settingData.monday = true;
      settingData.tuesday = true;
      settingData.wednesday = true;
      settingData.thursday = true;
      settingData.friday = true;
      settingData.saturday = true;
      settingData.sunday = true;
      // 治療方法選択-表示
      settingData.showTreat = true;
      // クール選択-表示
      settingData.showKur = true;
      // 上区切り線-非表示
      settingData.hrOnder = true;
      // 下区切り線-表示
      settingData.hrUnder = false;
      // 指示者選択不可フラグ
      settingData.disIndUserEdit = true;

      return settingData;
    },

    /**
     * 操作不可メッセージの表示/非表示切替
     */
    getIsShowMessageDialog(state) {
      return state.isShowMessageDialog;
    },

    /**
     * 基準日取得
     */
    getBaseDate(state) {
      return state.baseDate;
    },
    // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start
    getIhdfAnswerThreeDevA(state) {
      return state.ihdfAnswerThreeDevA;
    },
    // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end

    /**
     * 計算用透析時間取得
     */
    getDialysisTimeData(state) {
      return state.dialysisTimeData;
    },
  },

  mutations: {
    /**
     * モーダル表示するコンポーネントIDを格納
     * @param {String} dispComponentId コンポーネントID
     */
    commitDispComponentId(state, dispComponentId) {
      state.dispComponentId = dispComponentId;
    },

    /**
     * 指示系モーダル表示／非表示切替を格納
     * @param {Boolean} isShowIndModal true：表示、false：非表示
     */
    commitIsShowIndModal(state, isShowIndModal) {
      state.isShowIndModal = isShowIndModal;
    },

    /**
     * 治療予定コピーモーダル表示/表示切替を格納
     * @param {Boolean} isShowPlanCopyModal true：表示、false：非表示
     */
    commitIsShowPlanCopyModal(state, isShowPlanCopyModal) {
      state.isShowPlanCopyModal = isShowPlanCopyModal;
    },

    /**
     * 治療予定移動モーダル表示/表示切替を格納
     * @param {Boolean} isShowPlanMoveModal true：表示、false：非表示
     */
    commitIsShowPlanMoveModal(state, isShowPlanMoveModal) {
      state.isShowPlanMoveModal = isShowPlanMoveModal;
    },

    /**
     * 曜日パターン変更モーダル表示/表示切替を格納
     * @param {Boolean} isShowWeekPatternModal true：表示、false：非表示
     */
    commitIsShowWeekPatternModal(state, isShowWeekPatternModal) {
      state.isShowWeekPatternModal = isShowWeekPatternModal;
    },

    /**
     * 投与薬剤新規モーダル表示/表示切替を格納
     * @param {Boolean} isShowIndMediBaseModal true:表示、false:非表示
     */
    // commitIsShowIndMedicineModal(state, isShowMediCreateModal) {
    commitIsShowMediCreateModal(state, isShowMediCreateModal) {
      state.isShowMediCreateModal = isShowMediCreateModal;
    },

    /**
     * 投与薬剤編集モーダル表示/非表示切替を格納
     */
    commitIsShowMediEditModal(state, isShowMediEditModal) {
      state.isShowMediEditModal = isShowMediEditModal;
    },

    /**
     * UFRプログラム編集モーダル表示/非表示切替を格納
     */
    commitIsShowUfrProgramModal(state, isShowUfrProgramModal) {
      state.isShowUfrProgramModal = isShowUfrProgramModal;
    },

    /**
     * Naプログラム編集モーダル表示/非表示切替を格納
     */
    commitIsShowNaProgramModal(state, isShowNaProgramModal) {
      state.isShowNaProgramModal = isShowNaProgramModal;
    },

    /**
     * 透析液濃度プログラム編集モーダル表示/非表示切替を格納
     */
    commitIsShowDialysateProgramModal(state, isShowDialysateProgramModal) {
      state.isShowDialysateProgramModal = isShowDialysateProgramModal;
    },

    /**
     * QbQdプログラム編集モーダル表示/非表示切替を格納
     */
    commitIsShowQbqdProgramModal(state, isShowQbqdProgramModal) {
      state.isShowQbqdProgramModal = isShowQbqdProgramModal;
    },

    /**
     * IHdfプログラム編集モーダル表示/非表示切替を格納
     */
    commitIsShowIHdfProgramModal(state, isShowIHdfProgramModal) {
      state.isShowIHdfProgramModal = isShowIHdfProgramModal;
    },

    /**
     * 透析量プログラム編集モーダル表示/非表示切替を格納
     */
    commitIsShowDiaysisProgramModal(state, isShowDiaysisProgramModal) {
      state.isShowDiaysisProgramModal = isShowDiaysisProgramModal;
    },

    /**
     * BV-UFC編集モーダル表示/非表示切替を格納
     */
    commitIsShowBvUfcModal(state, isShowBvUfcModal) {
      state.isShowBvUfcModal = isShowBvUfcModal;
    },

    /**
     * DW編集モーダル表示/非表示切替を格納
     */
    commitIsShowDwModal(state, isShowDwModal) {
      state.isShowDwModal = isShowDwModal;
    },

    /**
     * 指示系モーダルへ渡す必要があるデータを格納
     * @param {Object} settingIndData 構造は state を参照
     */
    commitSettingIndData(state, settingIndData) {
      state.settingIndData = settingIndData;
    },

    /**
     * 指示系モーダル
     */
    commitSettingIndChildData(state, settingIndChildData) {
      state.settingIndChildData = settingIndChildData;
    },

    /**
     * 操作不可メッセージ表示/非表示切替を格納
     */
    commitIsShowMessageDialog(state, isShowMessageDialog) {
      state.isShowMessageDialog = isShowMessageDialog;
    },

    /**
     * 基準日を格納
     */
    commmitBaseDate(state, baseDate) {
      state.baseDate = baseDate;
    },
    // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start
    commmitIhdfAnswerThreeDevA(state, ihdfAnswerThreeDevA) {
      state.ihdfAnswerThreeDevA = ihdfAnswerThreeDevA;
    },
    // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end

    /**
     * 計算用透析時間を格納
     * @param {Object} dialysisTimeData
     */
    commitDialysisTimeData(state, dialysisTimeData) {
      state.dialysisTimeData = dialysisTimeData;
    },
  },

  actions: {
    /**
     * モーダル表示するコンポーネントIDを設定
     * @param {String} dispComponentId コンポーネントID
     */
    setDispComponentId({ commit }, { dispComponentId }) {
      commit("commitDispComponentId", dispComponentId);
    },

    /**
     * 指示系モーダル表示／非表示切替を設定
     * @param {Boolean} isShowIndModal true：表示、false：非表示
     * @param modalId モーダルID 0->IndEditBase, 1->治療予定コピー 2->治療予定移動, 3->曜日パターン変更
     */
    setIsShowIndModal({ commit }, { isShowIndModal, modalId }) {
      switch (modalId) {

        case -1:
          // DW編集
          commit(
            "commitIsShowDwModal",
            !isShowIndModal ? false : isShowIndModal
          );
          break;

        case 0:
          // 治療ベース
          commit(
            "commitIsShowIndModal",
            !isShowIndModal ? false : isShowIndModal
          );
          break;

        case 1:
          // 治療予定コピー
          commit(
            "commitIsShowPlanCopyModal",
            !isShowIndModal ? false : isShowIndModal
          );
          break;

        case 2:
          // 治療予定移動
          commit(
            "commitIsShowPlanMoveModal",
            !isShowIndModal ? false : isShowIndModal
          );
          break;

        case 3:
          // 曜日パターン変更
          commit(
            "commitIsShowWeekPatternModal",
            !isShowIndModal ? false : isShowIndModal
          );
          break;

        case 4:
          // 手動実績作成
          break;

        case 5:
          // 投与薬剤新規作成
          commit(
            "commitIsShowMediCreateModal",
            !isShowIndModal ? false : isShowIndModal
          );
          break;

        case 6:
          // 投与薬剤編集
          commit(
            "commitIsShowMediEditModal",
            !isShowIndModal ? false : isShowIndModal
          );
          break;

        case 7:
          // UFRプログラム編集
          commit(
            "commitIsShowUfrProgramModal",
            !isShowIndModal ? false : isShowIndModal
          );
          break;

        case 8:
          // Naプログラム編集
          commit(
            "commitIsShowNaProgramModal",
            !isShowIndModal ? false : isShowIndModal
          );
          break;

        case 9:
          // 透析液濃度プログラム編集
          commit(
            "commitIsShowDialysateProgramModal",
            !isShowIndModal ? false : isShowIndModal
          );
          break;

        case 10:
          // QbQdプログラム編集
          commit(
            "commitIsShowQbqdProgramModal",
            !isShowIndModal ? false : isShowIndModal
          );
          break;

        case 11:
          // IHdfプログラム編集
          commit(
            "commitIsShowIHdfProgramModal",
            !isShowIndModal ? false : isShowIndModal
          );
          break;

        case 12:
          // 透析量プログラム編集
          commit(
            "commitIsShowDiaysisProgramModal",
            !isShowIndModal ? false : isShowIndModal
          );
          break;

        case 13:
          // 透析量プログラム編集
          commit(
            "commitIsShowBvUfcModal",
            !isShowIndModal ? false : isShowIndModal
          );
          break;

        default:
          break;
      }
    },

    /**
     * 指示系モーダルへ渡す必要があるデータを設定
     * @param {Object} settingIndData 構造は state を参照
     */
    setSettingIndData({ commit }, { settingIndData }) {
      commit("commitSettingIndData", settingIndData);
    },

    /**
     * 指示系モーダル子コンポーネントへ渡す必要があるデータを設定
     */
    setSettingIndChildData({ commit }, { settingIndChildData }) {
      commit("commitSettingIndChildData", settingIndChildData);
    },

    /**
     * 指示系モーダルを非表示
     */
    hideIndModal({ dispatch }) {
      dispatch("setIsShowIndModal", { isShowIndModal: false, modalId: -1 });
      dispatch("setIsShowIndModal", { isShowIndModal: false, modalId: 0 });
      dispatch("setIsShowIndModal", { isShowIndModal: false, modalId: 1 });
      dispatch("setIsShowIndModal", { isShowIndModal: false, modalId: 2 });
      dispatch("setIsShowIndModal", { isShowIndModal: false, modalId: 3 });
      dispatch("setIsShowIndModal", { isShowIndModal: false, modalId: 4 });
      dispatch("setIsShowIndModal", { isShowIndModal: false, modalId: 5 });
      dispatch("setIsShowIndModal", { isShowIndModal: false, modalId: 6 });
      dispatch("setIsShowIndModal", { isShowIndModal: false, modalId: 7 });
      dispatch("setIsShowIndModal", { isShowIndModal: false, modalId: 8 });
      dispatch("setIsShowIndModal", { isShowIndModal: false, modalId: 9 });
      dispatch("setIsShowIndModal", { isShowIndModal: false, modalId: 10 });
      dispatch("setIsShowIndModal", { isShowIndModal: false, modalId: 11 });
      dispatch("setIsShowIndModal", { isShowIndModal: false, modalId: 12 });
      dispatch("setIsShowIndModal", { isShowIndModal: false, modalId: 13 });
    },

    /**
     * 指示系モーダルを表示
     * @param {String} dispComponentId コンポーネントID
     * @param {Object} settingIndData 構造は state を参照
     */
    showIndModal(
      { dispatch },
      { dispComponentId, settingIndData, settingIndChildData }
    ) {
      // 表示するコンポーネントIDを格納
      dispatch("setDispComponentId", { dispComponentId });

      // 指示系モーダルへ渡す必要があるデータを格納
      dispatch("setSettingIndData", { settingIndData });
      // 指示系モーダル子コンポーネントへ渡す必要があるデータを格納
      dispatch("setSettingIndChildData", { settingIndChildData });

      // モーダルを表示
      dispatch("setIsShowIndModal", { isShowIndModal: true, modalId: 0 });
    },

    /**
     * 治療予定コピーモーダル表示
     */
    showPlanCopyModal({ dispatch }, { settingIndData }) {
      // 指示系モーダルへ渡す必要があるデータを格納
      dispatch("setSettingIndData", { settingIndData });

      // モーダルを表示
      dispatch("setIsShowIndModal", { isShowIndModal: true, modalId: 1 });
    },

    /**
     * 治療予定移動モーダル表示
     */
    showPlanMoveModal({ dispatch }, { settingIndData }) {
      // 指示系モーダルへ渡す必要があるデータを格納
      dispatch("setSettingIndData", { settingIndData });

      // モーダルを表示
      dispatch("setIsShowIndModal", { isShowIndModal: true, modalId: 2 });
    },

    /**
     * 曜日パターン変更表示
     */
    showWeekPatternModal({ dispatch }, { settingIndData }) {
      // 指示系モーダルへ渡す必要があるデータを格納
      dispatch("setSettingIndData", { settingIndData });

      // モーダルを表示
      dispatch("setIsShowIndModal", { isShowIndModal: true, modalId: 3 });
    },

    /**
     * 手動実績作成
     */
    showRstCreateModal({ dispatch }, { settingIndData }) {
      // 指示系モーダルへ渡す必要があるデータを格納
      dispatch("setSettingIndData", { settingIndData });

      // モーダルを表示
      dispatch("setIsShowIndModal", { isShowIndModal: true, modalId: 4 });
    },

    /**
     * 投与薬剤新規モーダルを表示
     * @param {String} dispComponentId コンポーネントID
     * @param {Object} settingIndData 構造は state を参照
     */
    showMediCreateModal(
      { dispatch },
      { dispComponentId, settingIndData, settingIndChildData }
    ) {
      // 表示するコンポーネントIDを格納
      dispatch("setDispComponentId", { dispComponentId });

      // 指示系モーダルへ渡す必要があるデータを格納
      dispatch("setSettingIndData", { settingIndData });
      // 指示系モーダル子コンポーネントへ渡す必要があるデータを格納
      dispatch("setSettingIndChildData", { settingIndChildData });

      // モーダルを表示
      dispatch("setIsShowIndModal", { isShowIndModal: true, modalId: 5 });
    },

    /**
     * 投与薬剤編集モーダルを表示
     */
    showMediEditModal({ dispatch }, { settingIndData }) {
      // 指示系モーダルへ渡す必要があるデータを格納
      dispatch("setSettingIndData", { settingIndData });
      // モーダルを表示
      dispatch("setIsShowIndModal", { isShowIndModal: true, modalId: 6 });
    },

    /**
     * UFRプログラム編集モーダルを表示
     */
    showUfrProgramEditModal(
      { dispatch },
      { dispComponentId, settingIndData, settingIndChildData }
    ) {
      // 表示するコンポーネントIDを格納
      dispatch("setDispComponentId", { dispComponentId });
      // 指示系モーダルへ渡す必要があるデータを格納
      dispatch("setSettingIndData", { settingIndData });
      // 指示系モーダル子コンポーネントへ渡す必要があるデータを格納
      dispatch("setSettingIndChildData", { settingIndChildData });

      // モーダルを表示
      dispatch("setIsShowIndModal", { isShowIndModal: true, modalId: 7 });
    },

    /**
     * Naプログラム編集モーダルを表示
     */
    showNaProgramEditModal(
      { dispatch },
      { dispComponentId, settingIndData, settingIndChildData }
    ) {
      // 表示するコンポーネントIDを格納
      dispatch("setDispComponentId", { dispComponentId });
      // 指示系モーダルへ渡す必要があるデータを格納
      dispatch("setSettingIndData", { settingIndData });
      // 指示系モーダル子コンポーネントへ渡す必要があるデータを格納
      dispatch("setSettingIndChildData", { settingIndChildData });

      // モーダルを表示
      dispatch("setIsShowIndModal", { isShowIndModal: true, modalId: 8 });
    },

    /**
     * 透析液濃度プログラム編集モーダルを表示
     */
    showDialysateProgramEditModal(
      { dispatch },
      { dispComponentId, settingIndData, settingIndChildData }
    ) {
      // 表示するコンポーネントIDを格納
      dispatch("setDispComponentId", { dispComponentId });
      // 指示系モーダルへ渡す必要があるデータを格納
      dispatch("setSettingIndData", { settingIndData });
      // 指示系モーダル子コンポーネントへ渡す必要があるデータを格納
      dispatch("setSettingIndChildData", { settingIndChildData });

      // モーダルを表示
      dispatch("setIsShowIndModal", { isShowIndModal: true, modalId: 9 });
    },

    /**
     * QbQdプログラム編集モーダルを表示
     */
    showQbqdProgramEditModal(
      { dispatch },
      { dispComponentId, settingIndData, settingIndChildData }
    ) {
      // 表示するコンポーネントIDを格納
      dispatch("setDispComponentId", { dispComponentId });
      // 指示系モーダルへ渡す必要があるデータを格納
      dispatch("setSettingIndData", { settingIndData });
      // 指示系モーダル子コンポーネントへ渡す必要があるデータを格納
      dispatch("setSettingIndChildData", { settingIndChildData });

      // モーダルを表示
      dispatch("setIsShowIndModal", { isShowIndModal: true, modalId: 10 });
    },

    /**
     * IHdfプログラム編集モーダルを表示
     */
    showIHdfProgramEditModal(
      { dispatch },
      { dispComponentId, settingIndData, settingIndChildData }
    ) {
      // 表示するコンポーネントIDを格納
      dispatch("setDispComponentId", { dispComponentId });
      // 指示系モーダルへ渡す必要があるデータを格納
      dispatch("setSettingIndData", { settingIndData });
      // 指示系モーダル子コンポーネントへ渡す必要があるデータを格納
      dispatch("setSettingIndChildData", { settingIndChildData });

      // モーダルを表示
      dispatch("setIsShowIndModal", { isShowIndModal: true, modalId: 11 });
    },

    /**
     * 透析量プログラム編集モーダルを表示
     */
    showDiaysisProgramEditModal(
      { dispatch },
      { dispComponentId, settingIndData, settingIndChildData }
    ) {
      // 表示するコンポーネントIDを格納
      dispatch("setDispComponentId", { dispComponentId });
      // 指示系モーダルへ渡す必要があるデータを格納
      dispatch("setSettingIndData", { settingIndData });
      // 指示系モーダル子コンポーネントへ渡す必要があるデータを格納
      dispatch("setSettingIndChildData", { settingIndChildData });

      // モーダルを表示
      dispatch("setIsShowIndModal", { isShowIndModal: true, modalId: 12 });
    },

    /**
     * BV-UFC編集モーダルを表示
     */
    showBvUfcEditModal(
      { dispatch },
      { dispComponentId, settingIndData, settingIndChildData }
    ) {
      // 表示するコンポーネントIDを格納
      dispatch("setDispComponentId", { dispComponentId });
      // 指示系モーダルへ渡す必要があるデータを格納
      dispatch("setSettingIndData", { settingIndData });
      // 指示系モーダル子コンポーネントへ渡す必要があるデータを格納
      dispatch("setSettingIndChildData", { settingIndChildData });

      // モーダルを表示
      dispatch("setIsShowIndModal", { isShowIndModal: true, modalId: 13 });
    },

    /**
     * DW編集モーダルを表示
     */
    showDwModal({ dispatch }, { dispComponentId, settingIndData, settingIndChildData }) {
      // 表示するコンポーネントIDを格納
      dispatch("setDispComponentId", { dispComponentId });
      // 指示系モーダルへ渡す必要があるデータを格納
      dispatch("setSettingIndData", { settingIndData });
      // 指示系モーダル子コンポーネントへ渡す必要があるデータを格納
      dispatch("setSettingIndChildData", { settingIndChildData });

      // モーダルを表示
      dispatch("setIsShowIndModal", { isShowIndModal: true, modalId: -1 });
    },

    /**
     * 操作不可メッセージ表示/非表示
     */
    showMessageDialog({ commit }, { isShowMessageDialog }) {
      commit("commitIsShowMessageDialog", isShowMessageDialog);
    },

    /**
     * 基準日を設定
     */
    setBaseDate({ commit }, { baseDate }) {
      commit("commmitBaseDate", baseDate);
    },
    // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start
    setIhdfAnswerThreeDevA({ commit }, ihdfAnswerThreeDevA) {
      commit("commmitIhdfAnswerThreeDevA", ihdfAnswerThreeDevA);
    },
    // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end
    /**
     * 計算用透析時間を設定
     * @param {Object} dialysisTimeData
     */
    setDialysisTimeData({ commit },  dialysisTimeData ) {
      commit("commitDialysisTimeData", dialysisTimeData);
    },
  }
};
