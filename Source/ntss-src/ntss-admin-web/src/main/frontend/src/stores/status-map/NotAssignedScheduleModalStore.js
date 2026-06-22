/**
 * スケジュール/患者割当モーダル用ストア
 */
import { sendRequestGetNotAssignedOrdMain } from "@/apis/status-map";

export default {
  strict: true,
  namespaced: true,
  state: {
    // 選択中のord_no（ord_main）
    findFacilityCd: null,
    // 選択中の治療日付
    findTreatDate: null,
    // 選択中のベッドコード
    findBedCd: null,
    // 選択中のベッド名
    findBedName: null,
    // 選択中のord_main（スケジュール）
    selectOrdMain: null,
    // 未割当データリスト
    notAssignedOrdMainList: null
  },
  getters: {
    getNotAssignedOrdMainList(state) {
      return state.notAssignedOrdMainList;
    },
    getFindState(state) {
      return {
        facilityCd: state.findFacilityCd,
        treatDate: `${state.findTreatDate.substr(
          0,
          4
        )}/${state.findTreatDate.substr(4, 2)}/${state.findTreatDate.substr(
          6,
          2
        )}`,
        bedCd: state.findBedCd,
        bedName: state.findBedName
      };
    },
    getSelectedOrdMain(state) {
      if (state.selectOrdMain) {
        return state.selectOrdMain;
      } else {
        return null;
      }
    }
  },
  actions: {
    /**
     * ord_no指定
     * ord_main情報取得
     */
    async getOrderMainList({ commit, state }) {
      // console.log("getOrderMainList");

      // 未割当データ初期化
      await commit("setNotAssignedOrdMain", null);

      // 未割当データ取得
      const response = await sendRequestGetNotAssignedOrdMain(
        state.findFacilityCd,
        state.findTreatDate,
        state.findBedCd
      );

      if (
        response.status === 200 &&
        response.data.length > 0 &&
        response.data[0] !== null
      ) {
        const weeklist = ["", "月", "火", "水", "木", "金", "土", "日"];
        const ordMainList = response.data
          .map(dat => {
            // 治療日+曜日の設定
            dat.viewTreatDate = `${dat.treatDate.substr(
              0,
              4
            )}/${dat.treatDate.substr(4, 2)}/${dat.treatDate.substr(6, 2)}(${
              weeklist[dat.treatWeek]
              })`;

            return dat;
          });
        // const ordMainList = response.data;
        // console.log("getOrderMainList/ ordMainList is %o.", ordMainList);
        // 取得したord_main情報をセット
        await commit("setNotAssignedOrdMain", ordMainList);
      }
    },
    async setFindCondition({ commit, dispatch }, { facilityCd, treatDate, bedCd, bedName }) {
      // console.log("setFindCondition");
      await dispatch("setSelectOrdNo", -1);
      await commit("setFindCondition", { facilityCd, treatDate, bedCd, bedName });
    },
    async setSelectOrdNo({ commit }, ordNo) {
      await commit("setSelectOrdMain", ordNo);
    }
  },
  mutations: {
    setFindCondition(state, payload) {
      state.findFacilityCd = payload.facilityCd;
      state.findTreatDate = payload.treatDate;
      state.findBedCd = payload.bedCd;
      state.findBedName = payload.bedName;
    },
    // ord_main
    setNotAssignedOrdMain(state, payload) {
      state.notAssignedOrdMainList = payload;
    },
    setSelectOrdMain(state, ordNo) {
      if (state.notAssignedOrdMainList) {
        state.selectOrdMain = state.notAssignedOrdMainList.find(
          dat => dat.ordNo === ordNo
        );
      } else {
        state.selectOrdMain = null;
      }
    }
  }
};
