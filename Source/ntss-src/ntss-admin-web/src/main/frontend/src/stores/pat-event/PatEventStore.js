/**
 * 患者イベントStore.
 */
import {
  sendRequestGetPatEventMaster,
  sendRequestGetPatEventRecord,
  sendRequestGetPatIntroLetter,
  sendRequestGetPatEventRecordList
} from "@/apis/pat-event";
import { DATE_CHOICES } from "@/constants/defaultSettingConstants";
import { calcTargetDate } from "@/functions/modals/default-setting/defaultSettingUtils"
import dayjs from "@/compat/date/dayjs";
import { deepCopy } from "@/functions/common/CommonFunctions";

const DefaultHistoryInfoPatEvent = {
  startDate: null,
  endDate: null,
  relationCategoryCd: [],
};
const DefaultHistoryInfoPatIntroLetter = deepCopy(DefaultHistoryInfoPatEvent);

export default {
  strict: true,
  namespaced: true,
  state: {
    patEventRecords: [],
    patEventRecord: [],
    patIntroLetter: [],
    mstTemplateRecords: [],
    mstCategoryRecords: [],
    mstSubCategoryRecords: [],
    historyInfo: {
      patEvent: deepCopy(DefaultHistoryInfoPatEvent),
      patIntroLetter: deepCopy(DefaultHistoryInfoPatIntroLetter),
    },
    /*add FNSI-改修内容カテゴリ、サブカテゴリ、テンプレートが削除された或いは修正された場合、患者イベントの履歴の内容がもともとの内容で表示するように修正 任 start*/
    mstAllTemplateRecords: [],
    mstAllCategoryRecords: [],
    mstAllSubCategoryRecords: [],
    /*add FNSI-改修内容カテゴリ、サブカテゴリ、テンプレートが削除された或いは修正された場合、患者イベントの履歴の内容がもともとの内容で表示するように修正 任 end*/
    condition: {},
    updateMode: true,
    /*add FNSI-改修内容転入時の紹介状取込ができない 任 start*/
    reportFlag: true,
    showUpload: false,
    displayTwo: false,
    isOtherFacility: false,
    /*add FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 start*/
    subCategoryCd: null,
    /*add FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 end*/
    /*add FNSI-改修内容転入時の紹介状取込ができない 任 end*/
    isEdit: false,
    // add FNSI-コントロールの削除 徐 start
    // 治療記録から患者イベントに移るのフラグ
    patEventFlg: false,
    // add FNSI-コントロールの削除 徐 end
    /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start*/
    treatBaseDate: [],
    /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end*/
    eventStartDate: null
  },
  mutations: {
    // add FNSI-コントロールの削除 徐 start
    /**
     *  治療記録から患者イベントに移るのフラグ
     * @param {*} state
     * @param {*} value
     */
    setPatEventFlg(state, value) {
      state.patEventFlg = value;
    },
    // add FNSI-コントロールの削除 徐 end
    /**
     * 処理モード
     * @param {*} state
     * @param {*} rec
     */
    setUpdateMode(state, updateMode) {
      state.updateMode = updateMode;
    },
    /*add FNSI-改修内容転入時の紹介状取込ができない 任 start*/
    setReportFlag(state, reportFlag) {
      state.reportFlag = reportFlag;
    },
    setShowUpload(state, showUpload){
      state.showUpload = showUpload;
    },
    setSelectInfo(state, historyInfo) {
      if (!historyInfo) return;

      if (historyInfo.patEvent) {
        state.historyInfo.patEvent = historyInfo.patEvent;
      }
      if (historyInfo.patIntroLetter) {
        state.historyInfo.patIntroLetter = historyInfo.patIntroLetter;
      }
    },
    /*add FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 start*/
    setSubCategoryCd(state,subCategoryCd){
      state.subCategoryCd = subCategoryCd;
    },
    /*add FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 end*/
    setDisplayTwo(state,displayTwo){
      state.displayTwo = displayTwo;
    },
    setIsOtherFacility(state, isOtherFacility) {
      state.isOtherFacility = isOtherFacility;
    },
    resetIsOtherFacility(state) {
      state.isOtherFacility = false;
    },
    /*add FNSI-改修内容転入時の紹介状取込ができない 任 end*/
    /**
     * 処理モード
     * @param {*} state
     * @param {*} rec
     */
    setIsEdit(state, isEdit) {
      state.isEdit = isEdit;
    },
    /**
     * 患者イベントリストのクリア
     * @param {*} state
     */
    setConditionDate(state, condition) {
      state.condition = condition;
    },
    /**
     * 患者イベントリストのクリア
     * @param {*} state
     */
    clearPatEventRecords(state) {
      state.patEventRecords.splice(0, state.patEventRecords.length);
    },
    /**
     * 患者イベントのクリア(展開用)
     * @param {*} state
     */
    clearPatEventRecord(state) {
      state.patEventRecord.splice(0, state.patEventRecord.length);
    },
    /**
     * 患者イベントリストの取得
     * @param {*} state
     * @param {*} mstCategoryRecords
     */
    setPatEventRecords(state, patEventRecords) {
      state.patEventRecords = [];
      patEventRecords.forEach(e => {
        state.patEventRecords.push(e);
      });
    },
    /**
     * 患者イベントリストの取得
     * @param {*} state
     * @param {*} mstCategoryRecords
     */
    async setPatEventRecord(state, patEventRecord) {
      state.patEventRecord = [];
      patEventRecord.forEach(e => {
        state.patEventRecord.push(e);
      });
    },
    /**
     * 患者イベント(紹介状)の取得
     * @param {*} state
     * @param {*} mstCategoryRecords
     */
    async setPatIntroLetter(state, patIntroLetter) {
      state.patIntroLetter = [];
      patIntroLetter.forEach(e => {
        state.patIntroLetter.push(e);
      });
    },
    /**
     * カテゴリマスタ
     * @param {*} state
     * @param {*} mstCategoryRecords
     */
    setMstCategoryRecords(state, mstCategoryRecords) {
      state.mstCategoryRecords = [];
      mstCategoryRecords.forEach(e => {
        state.mstCategoryRecords.push(e);
      });
    },
    /*add FNSI-改修内容カテゴリ、サブカテゴリ、テンプレートが削除された或いは修正された場合、患者イベントの履歴の内容がもともとの内容で表示するように修正 任 start*/
    setMstAllCategoryRecords(state, mstAllCategoryRecords) {
      state.mstAllCategoryRecords = [];
      mstAllCategoryRecords.forEach(e => {
        state.mstAllCategoryRecords.push(e);
      });
    },
    /*add FNSI-改修内容カテゴリ、サブカテゴリ、テンプレートが削除された或いは修正された場合、患者イベントの履歴の内容がもともとの内容で表示するように修正 任 end*/
    /**
     * テンプレートマスタ
     * @param {*} state
     * @param {*} mstTemplateRecords
     */
    setMstTemplateRecords(state, mstTemplateRecords) {
      state.mstTemplateRecords = [];
      state.mstTemplateRecords.push({
        facilityCd: null,
        inputParams: "[]",
        isDel: "0",
        isDisp: "1",
        operatorId: null,
        regDate: null,
        targetFacilityCd: null,
        templateCd: null,
        templateName: "",
        upDate: null
      });
      mstTemplateRecords.forEach(e => {
        state.mstTemplateRecords.push(e);
      });
    },
    /*add FNSI-改修内容カテゴリ、サブカテゴリ、テンプレートが削除された或いは修正された場合、患者イベントの履歴の内容がもともとの内容で表示するように修正 任 start*/
    setMstAllTemplateRecords(state, mstAllTemplateRecords) {
      state.mstAllTemplateRecords = [];
      state.mstAllTemplateRecords.push({
        facilityCd: null,
        inputParams: "[]",
        isDel: "0",
        isDisp: "1",
        operatorId: null,
        regDate: null,
        targetFacilityCd: null,
        templateCd: null,
        templateName: "",
        upDate: null
      });
      mstAllTemplateRecords.forEach(e => {
        state.mstAllTemplateRecords.push(e);
      });
    },
    /*add FNSI-改修内容カテゴリ、サブカテゴリ、テンプレートが削除された或いは修正された場合、患者イベントの履歴の内容がもともとの内容で表示するように修正 任 end*/
    /**
     * サブカテゴリマスタ
     * @param {*} state
     * @param {*} mstSubCategoryRecords
     */
    setMstSubCategoryRecords(state, mstSubCategoryRecords) {
      state.mstSubCategoryRecords = [];
      mstSubCategoryRecords.forEach(e => {
        state.mstSubCategoryRecords.push(e);
      });
    },
    /*add FNSI-改修内容カテゴリ、サブカテゴリ、テンプレートが削除された或いは修正された場合、患者イベントの履歴の内容がもともとの内容で表示するように修正 任 start*/
    setMstAllSubCategoryRecords(state, mstAllSubCategoryRecords) {
      state.mstAllSubCategoryRecords = [];
      mstAllSubCategoryRecords.forEach(e => {
        state.mstAllSubCategoryRecords.push(e);
      });
    },
    /*add FNSI-改修内容カテゴリ、サブカテゴリ、テンプレートが削除された或いは修正された場合、患者イベントの履歴の内容がもともとの内容で表示するように修正 任 end*/
    /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start*/
    setTreatBaseDate(state, treatBaseDate) {
      state.treatBaseDate = treatBaseDate;
    },
    /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end*/
    setEventStartDate(state, eventStartDate) {
      state.eventStartDate = eventStartDate;
    }
  },
  actions: {
    // add FNSI-コントロールの削除 徐 start
    /**
     *  治療記録から患者イベントに移るのフラグ
     * @param {*} state
     * @param {*} value
     */
    async setPatEventFlg({ commit }, value) {
      commit("setPatEventFlg", value);
    },
    // add FNSI-コントロールの削除 徐 end
    async fetchPatEventMaster({ commit } ,payload = undefined) {
      const facilityCd = payload && typeof payload === "object" ? payload.facilityCd : payload;
      const selectedPatId = payload && typeof payload === "object" ? payload.selectedPatId : undefined;
      const response = await sendRequestGetPatEventMaster(facilityCd, selectedPatId);
      /*mod FNSI-改修内容カテゴリ、サブカテゴリ、テンプレートが削除された或いは修正された場合、患者イベントの履歴の内容がもともとの内容で表示するように修正 任 start*/
      /*if (response.data.template.length > 0) {
        commit("setMstTemplateRecords", response.data.template);
      }
      if (response.data.category.length > 0) {
        commit("setMstCategoryRecords", response.data.category);
      }
      if (response.data.subCategory.length > 0) {
        commit("setMstSubCategoryRecords", response.data.subCategory);
      }*/
      commit("setMstTemplateRecords", response.data.template);
      commit("setMstCategoryRecords", response.data.category);
      commit("setMstSubCategoryRecords", response.data.subCategory);
      if (response.data.allTemplate.length > 0) {
        commit("setMstAllTemplateRecords", response.data.allTemplate);
      }
      if (response.data.allCategory.length > 0) {
        commit("setMstAllCategoryRecords", response.data.allCategory);
      }
      if (response.data.allSubCategory.length > 0) {
        commit("setMstAllSubCategoryRecords", response.data.allSubCategory);
      }
      /*mod FNSI-改修内容カテゴリ、サブカテゴリ、テンプレートが削除された或いは修正された場合、患者イベントの履歴の内容がもともとの内容で表示するように修正 任 end*/
    },
    setUpdateMode({ commit }, value) {
      commit("setUpdateMode", value);
    },
    /*add FNSI-改修内容転入時の紹介状取込ができない 任 start*/
    setReportFlag({ commit }, value) {
      commit("setReportFlag", value);
    },
    setShowUpload({ commit }, value) {
      commit("setShowUpload", value);
    },
    /*add FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 start*/
    setSubCategoryCd({ commit },value) {
      commit("setSubCategoryCd",value);
    },
    /*add FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 end*/
    setSelectInfo({ commit }, value) {
      commit("setSelectInfo", value);
    },
    setDisplayTwo({ commit }, value){
      commit("setDisplayTwo", value);
    },
    setIsOtherFacility({ commit }, value) {
      commit("setIsOtherFacility", value);
    },
    resetIsOtherFacility({ commit }) {
      commit("resetIsOtherFacility");
    },
    /*add FNSI-改修内容転入時の紹介状取込ができない 任 end*/
    setIsEdit({ commit }, value) {
      commit("setIsEdit", value);
    },
    setConditionDate({ commit, getters }, info) {
      const params = (info.startDate !== null || info.endDate !== null) ? {
        startDate: info.startDate,
        endDate: info.endDate,
      } : getters.getSystemDefaultConditionDate;
      commit("setConditionDate", params);
    },
    clearPatEventRecords({ commit }) {
      commit("clearPatEventRecords");
    },
    /**
     *
     * @param {*} param0
     */
    async fetchPatEventRecords({ commit }, info) {
      commit("clearPatEventRecords");
      const response = await sendRequestGetPatEventRecordList(info);
      if (response.data[0] !== null) {
        const patEventRecords = response.data;
        if (patEventRecords.length > 0) {
          if (info.isIntroLetter) {
            const letterRecords = patEventRecords.filter(rec => {
              return rec.useType === 3;
            });
            commit("setPatEventRecords", letterRecords);
          } else {
            commit("setPatEventRecords", patEventRecords);
          }
        }
      }
    },
    /**
     *
     * @param {*} param0
     * @param {*} info
     */
    async findPatEventByCd({ commit, rootGetters }, info) {
      const params = info[0];
      commit("clearPatEventRecord");
      const response = await sendRequestGetPatEventRecord(params, params.selectedPatId);
      if (response.data[0] !== null) {
        const patEventRecord = response.data;
        if (patEventRecord.length > 0) {
          commit("setPatEventRecord", patEventRecord);
          const userFacilityCd = rootGetters["user/getFacilityCd"];
          const recordFacilityCd = patEventRecord[0].facilityCd;
          commit("setIsOtherFacility", userFacilityCd !== recordFacilityCd);
        }
      }
    },
    /**
     *
     * @param {*} param0
     * @param {*} info
     */
    async findPatIntroLetterByCd({ commit }, payload) {
      const patEventCd = payload && typeof payload === "object" ? payload.patEventCd : payload;
      const selectedPatId = payload && typeof payload === "object" ? payload.selectedPatId : undefined;
      const response = await sendRequestGetPatIntroLetter(patEventCd, selectedPatId);
      if (response.data[0] !== null) {
        const patIntroLetter = response.data;
        if (patIntroLetter.length > 0) {
          commit("setPatIntroLetter", patIntroLetter);
        }
      }
    },
    setMstSubCategoryRecords({ commit }, records) {
      commit("setMstSubCategoryRecords", records);
      /*add FNSI-改修内容カテゴリ、サブカテゴリ、テンプレートが削除された或いは修正された場合、患者イベントの履歴の内容がもともとの内容で表示するように修正 任 start*/
    },
    setMstAllSubCategoryRecords({ commit }, records) {
      commit("setMstAllSubCategoryRecords", records);
      /*add FNSI-改修内容カテゴリ、サブカテゴリ、テンプレートが削除された或いは修正された場合、患者イベントの履歴の内容がもともとの内容で表示するように修正 任 end*/
    },
    /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start*/
    setTreatBaseDate({ commit }, treatBaseDate) {
      commit("setTreatBaseDate", treatBaseDate);
    },
    /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end*/
    setEventStartDate({ commit }, eventStartDate) {
      commit("setEventStartDate", eventStartDate);
    }
  },
  getters: {
    // add FNSI-コントロールの削除 徐 start
    /**
     *  治療記録から患者イベントに移るのフラグ
     * @param {*} state
     *
     */
    getPatEventFlg(state) {
      return state.patEventFlg;
    },
    // add FNSI-コントロールの削除 徐 end
    /**
     *
     * @param {*} state
     */
    getUpdateMode(state) {
      return state.updateMode;
    },
    /*add FNSI-改修内容転入時の紹介状取込ができない 任 start*/
    getReportFlag(state) {
      return state.reportFlag;
    },
    getShowUpload(state){
      return state.showUpload;
    },
    getDisplayTwo(state){
      return state.displayTwo;
    },
    getIsOtherFacility(state) {
      return state.isOtherFacility;
    },
    /*add FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 start*/
    getSubCategoryCd(state){
      return state.subCategoryCd;
    },
    /*add FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 end*/
    /*add FNSI-改修内容転入時の紹介状取込ができない 任 end*/
    /**
     *
     * @param {*} state
     */
    getIsEdit(state) {
      return state.isEdit;
    },
    /**
     *
     * @param {*} state
     */
    getPatEventRecords(state) {
      return state.patEventRecords;
    },
    /**
     *
     * @param {*} state
     */
    getPatEventRecord(state) {
      return state.patEventRecord;
    },
    /**
     *
     * @param {*} state
     */
    getPatIntroLetter(state) {
      return state.patIntroLetter;
    },
    /**
     *
     * @param {*} state
     */
    getConditionDate(state) {
      return state.condition;
    },
    getSystemDefaultConditionDate() {
      const dateFromSetting = (choice) => dayjs(calcTargetDate(choice.value)).toDate();
      return {
        startDate: dateFromSetting(DATE_CHOICES.BEFORE_ONE_WEEK),
        endDate: dateFromSetting(DATE_CHOICES.TODAY),
      };
    },
    /**
     *
     * @param {*} state
     */
    getMstTemplateRecords(state) {
      return state.mstTemplateRecords;
    },
    /**
     *
     * @param {*} state
     */
    getMstCategoryRecords(state) {
      return state.mstCategoryRecords;
    },
    /**
     *
     * @param {*} state
     */
    getMstSubCategoryRecords(state) {
      return state.mstSubCategoryRecords;
    },
    /*add FNSI-改修内容カテゴリ、サブカテゴリ、テンプレートが削除された或いは修正された場合、患者イベントの履歴の内容がもともとの内容で表示するように修正 任 start*/
    getMstAllTemplateRecords(state) {
      return state.mstAllTemplateRecords;
    },
    getMstAllCategoryRecords(state) {
      return state.mstAllCategoryRecords;
    },
    getMstAllSubCategoryRecords(state) {
      return state.mstAllSubCategoryRecords;
    },
    getSelectInfo(state) {
      return state.historyInfo;
    },
    /*add FNSI-改修内容カテゴリ、サブカテゴリ、テンプレートが削除された或いは修正された場合、患者イベントの履歴の内容がもともとの内容で表示するように修正 任 end*/
    /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start*/
    getTreatBaseDate(state) {
      return state.treatBaseDate;
    },
    /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end*/
    getEventStartDate(state) {
      return state.eventStartDate;
    }
  },
};
