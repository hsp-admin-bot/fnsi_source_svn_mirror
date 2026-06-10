/**
 * 休日マスタメンテナンスStore.
 */
import {
  sendRequestFindRecordListByFacilityCd
} from "@/apis/master-maintenance";

export default {
  strict: true,
  namespaced: true,
  state: {
    // 休日マスタの休日
    holidays: {},
  },
  mutations: {
    /**
     * 休日マスタの休日を設定
     * @param {*} state
     * @param {Object} holidays 休日マスタの休日
     */
    setHolidays(state, holidays) {
      state.holidays = holidays;
    },
  },
  actions: {
    /**
     * 休日マスタの休日を設定
     * @param {*} commit
     * @param {*} holidays 休日リスト
     */
    setHolidays({ commit }, holidays) {
      commit("setHolidays", holidays);
    },
    /**
     * 休日マスタの休日をクリア
     * @param {*} commit
     */
    clearHolidays({ commit }) {
      commit("setHolidays", {});
    },
    /**
     * 休日マスタの休日リスト取得（日機装施設、サインイン施設）
     * @param {*} commit
     * @param {*} paramFacilityCd
     */
    async fetchHolidays({ commit }, paramFacilityCd) {
      await Promise.all(["nkknkk", paramFacilityCd].map(facilityCd =>
        sendRequestFindRecordListByFacilityCd("mst_holiday", facilityCd)
          .then(res => ({ facilityCd, res }))
      ))
      .then(results => {
        const holidayList = [];
        const ret = {};
        results.forEach(({ facilityCd, res }) => {
          if (res.status === 200) {
            // 日機装施設祝日、自施設固有日、自施設祝日を取得
            const filteredData = res.data.localDataSource.data.filter(day =>
              facilityCd === "nkknkk" ? day.isDisp === "1" && day.class === "0" : day.isDisp === "1"
            );
            holidayList.push(...filteredData);
          }
        });
        holidayList.forEach(everyHoliday => {
          let holidayJson = JSON.parse(everyHoliday.holiday);
          holidayJson.forEach(everyDay => {
            ret[everyDay.date] = true;
          });
        });
        commit("setHolidays", ret);
      });
    },
  },
  getters: {
    /**
     * 休日マスタの休日を取得
     * @param {*} state STATEオブジェクト
     */
    getHolidays(state) {
      return state.holidays;
    },
  }
};
