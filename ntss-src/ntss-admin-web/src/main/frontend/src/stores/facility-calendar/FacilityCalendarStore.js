import dayjs from "@/compat/date/dayjs";

/**
 * 施設カレンダー用ストア
 */
export default {
  namespaced: true,
  strict: true,
  state: {
    // 検索条件一覧
    selectedCondition: {
      viewTotal: null,
      // フリーワード
      freeWord: "", // 初期値設定:未入力
      // 掲載開始日
      noticeStartDate: dayjs().format("YYYY-MM-DD"), // 初期値設定:本日
      // 掲載終了日
      noticeEndDate: dayjs().format("YYYY-MM-DD"), // 初期値設定:本日,
      // 透析日
      dialysisDate: null, // 初期値設定:未入力
      // クール
      kur: null, // 初期値設定:すべて
      // ベッドグループ
      roomBedGroup: { bedGroupCd: null, bedCdList: [] } // 初期値設定:すべて
    },
    viewMode: null,
    scheduleListDayView: null,
    waterQualityDayView: null,
    selectedLayoutFacility: null,
    isSelectedCondition: false,
    defaultCondition: null,
    calendarSearchDate: null, //カレンダー表示の日付
  },

  getters: {
    /**
     * @description 検索条件
     */
    selectedCondition(state) {
      return state.selectedCondition;
    },

    viewMode: state => state.viewMode,

    scheduleListDayView: state => state.scheduleListDayView,

    getWaterQualityDayView: state => state.waterQualityDayView,

    getSelectedLayoutFacility: state => state.selectedLayoutFacility,

    isSelectedCondition: state => state.isSelectedCondition,
    getDefaultCondition(state) {
      return state.defaultCondition;
    },
    getCalendarSearchDate: state => state.calendarSearchDate,
  },

  mutations: {
    setSelectedCondition(state, selectedCondition) {
      state.selectedCondition = selectedCondition;
    },

    setViewMode: (state, b) => {
      state.viewMode = b;
    },

    setScheduleListDayView: (state, scheduleListDayView) => {
      state.scheduleListDayView = scheduleListDayView;
    },

    setWaterQualityDayView: (state, waterQualityDayView) => {
      state.waterQualityDayView = waterQualityDayView;
    },

    setSelectedLayoutFacility: (state, selectedLayoutFacility) => {
      state.selectedLayoutFacility = selectedLayoutFacility;
    },

    setIsSelectedCondition:(state,isSelectedCondition) =>{
      state.isSelectedCondition = isSelectedCondition;
    },
    setDefaultCondition(state, defaultCondition) {
      state.defaultCondition = defaultCondition;
    },
    
    setCalendarSearchDate: (state, calendarSearchDate) => {
      state.calendarSearchDate = calendarSearchDate;
    },
  },

  actions: {
    /**
     * @description 検索条件の設定
     * @param {Object} selectedCondition
     */

    setSelectedCondition({ commit }, selectedCondition) {
      commit("setSelectedCondition", selectedCondition);
    },

    setViewMode: ({ commit }, viewMode) => {
      commit("setViewMode", viewMode);
    },

    setScheduleListDayView: ({ commit }, setScheduleListDayView) => {
      commit("setScheduleListDayView", setScheduleListDayView);
    },

    setWaterQualityDayView: ({ commit }, waterQualityDayView) => {
      commit("setWaterQualityDayView", waterQualityDayView);
    },

    setSelectedLayoutFacility: ({ commit }, selectedLayoutFacility) => {
      commit("setSelectedLayoutFacility", selectedLayoutFacility);
    },

    setIsSelectedCondition: ({ commit }, isSelectedCondition) => {
      commit("setIsSelectedCondition", isSelectedCondition);
    },
    setDefaultCondition({ commit }, defaultCondition) {
      commit("setDefaultCondition", defaultCondition);
    },
    
    setCalendarSearchDate({ commit }, calendarSearchDate) {
      commit("setCalendarSearchDate", calendarSearchDate);
    },
  }
};
