/**
 * 体重計測定記録用ストア
 */
import { sendRequestGetMeasureHistory } from "@/apis/measure-history";
import { sendRequestGetMstPersonalUser } from "@/apis/check-list";
import {
  sendRequestGetKurSelector
} from "@/apis/send-condition";
import dayjs from "@/compat/date/dayjs";
import BigNumber from "@/compat/number/bignumber";

export default {
  strict: true,
  namespaced: true,
  state: {
    // クール一覧情報
    mstKurSelector: null,
    // ベッドグループ一覧情報
    mstBedGroupList: null,
    // measureHistoryList: null,
    measureHistoryList: [],
    // 体重測定状況リスト
    weightScaleStatusList: [
      { no: 0, statusName: "測定済み" },
      { no: 1, statusName: "条件送信指示中" },
      { no: 2, statusName: "待機" },
      { no: 3, statusName: "条件送信成功" },
      { no: 4, statusName: "条件送信失敗" }
    ],
    // 抽出条件
    condition: {
      measureDate: "",
      clearflag: false
    },
    // 画面更新指示
    filterSignal: false
  },
  getters: {
    getMstKurSelector(state) {
      return state.mstKurSelector;
    },
    getMstBedGroupList(state) {
      return state.mstBedGroupList;
    },
    getWeightScaleStatusList(state) {
      return state.weightScaleStatusList;
    },
    getMeasureHistoryList(state) {
      return state.measureHistoryList;
    },
    getCondition: state => {
      return state.condition;
    },
    getFilterSignal: state => {
      return state.filterSignal;
    }
  },
  actions: {
    /**
     * クールとベッドの一覧取得
     */
    async fetchKurBedGroup({ commit }) {
      // クールとベッドの一覧取得
      try {
        //mod 8646 【デグレ】スケジュール表のベッドグループの表示が不正 張 start
        // let response = await sendRequestGetKurSelector(1);
        let response = await sendRequestGetKurSelector();
        //mod 8646 【デグレ】スケジュール表のベッドグループの表示が不正 張 end
        // 取得したクール一覧情報をセット
        commit("setKurSelector", { mstKurSelector: response.data.kurSelector });

        const dataList = response.data.bedGroupList.copyWithin(0, 0);
        dataList.forEach((value, index, array) => {
          // ベッドリスト
          array[index].bedList = JSON.parse(array[index].bedList);
        });

        // 取得したベッドグループ一覧情報をセット
        commit("setBedGroupList", { mstBedGroupList: dataList });
        return true;
      } catch (err) {
        console.error(err);
        return false;
      }
    },

    /**
     * 体重計測定記録一覧情報取得
     * facilityCd: 施設コード
     * startDate: 開始日
     * endDate: 開始日
     */
    async getOrderMeasureHistoryList({ commit }, info) {
      let params = info[0];
      if (params.isClear) {
        // クリア
        commit("clearmeasureHistoryList");
      }
      // 体重計測定記録一覧情報取得
      const response = await sendRequestGetMeasureHistory(params);
      if (response.data[0] !== null) {
        // スタッフ情報取得
        const staffresponse = await sendRequestGetMstPersonalUser(
          params.FacilityCd
        );
        const staffdataList = staffresponse.data.copyWithin(0, 0);
        // 日付フォーマット用
        const dateformat = "YYYY/MM/DD HH:mm:ss";

        // 取得データの変換
        const dataList = response.data.copyWithin(0, 0);
        dataList.forEach((value, index, array) => {
          // 測定日時
          const momentDate = dayjs(array[index].measureDate);
          array[index].measureDate = momentDate.format(dateformat);

          // 車いす情報
          if (array[index].wheelChairWeight !== null) {
            array[index].wheelChairWeight = new BigNumber(
              Math.floor(
                new BigNumber(array[index].wheelChairWeight).div(10).toNumber()
              )
            ).div(100);
          }

          // 風袋情報
          array[index].rstTare = 0;
          if (array[index].rstTareInfo !== null) {
            array[index].rstTareInfo = JSON.parse(array[index].rstTareInfo);
            array[index].rstTareTotal =
              Number(array[index].rstTareInfo.weight_1) +
              Number(array[index].rstTareInfo.weight_2) +
              Number(array[index].rstTareInfo.weight_3) +
              Number(array[index].rstTareInfo.weight_4) +
              Number(array[index].rstTareInfo.weight_5);
            array[index].rstTare = new BigNumber(
              Math.floor(
                new BigNumber(array[index].rstTareTotal).div(10).toNumber()
              )
            ).div(100);
          }
          // 除水補正情報
          array[index].rstOffWater = 0;
          if (array[index].rstOffWaterInfo !== null) {
            array[index].rstOffWaterInfo = JSON.parse(
              array[index].rstOffWaterInfo
            );
            array[index].rstOffWaterTotal =
              Number(array[index].rstOffWaterInfo.weight_1) +
              Number(array[index].rstOffWaterInfo.weight_2) +
              Number(array[index].rstOffWaterInfo.weight_3) +
              Number(array[index].rstOffWaterInfo.weight_4) +
              Number(array[index].rstOffWaterInfo.weight_5);
          }
          array[index].rstOffWater = new BigNumber(
            Math.ceil(
              new BigNumber(array[index].rstOffWaterTotal).div(10).toNumber()
            )
          ).div(100);
        });

        // スタッフ名
        for (let i = 0; i < dataList.length; i++) {
          let resuserid = dataList[i].userId;
          for (let j = 0; j < staffdataList.length; j++) {
            let userid = staffdataList[j].userId;
            if (resuserid == userid) {
              dataList[i].staffName = staffdataList[j].userName;
            }
          }
        }
        // 取得したベ体重計測定記録一覧情報をセット
        if (dataList.length > 0) {
          commit("setMeasureHistoryList", { measureHistoryList: dataList });
        }
      }
    },
    /**
     * 観察記録一覧クリア
     */
    clearmeasureHistoryList({ commit }) {
      commit("clearmeasureHistoryList");
    },
    // -----------------------------------------
    // 抽出条件設定
    // -----------------------------------------
    conditionSet({ commit }, condition) {
      commit("conditionSet", condition);
    },
    /**
     * 更新指示
     * @param {*} state state
     * @param {boolean} signal 更新する際にシグナルを立てる
     */
    setFilterSignal({ commit }, signal) {
      commit("setFilterSignal", signal);
    }
  },
  mutations: {
    setKurSelector(state, payload) {
      state.mstKurSelector = payload.mstKurSelector;
    },
    setBedGroupList(state, payload) {
      state.mstBedGroupList = payload.mstBedGroupList;
    },
    setMeasureHistoryList(state, payload) {
      // state.measureHistoryList = payload.measureHistoryList;
      payload.measureHistoryList.forEach(e => {
        state.measureHistoryList.push(e);
      });
    },
    /**
     * 更新指示
     * @param {*} state state
     * @param {boolean} signal 更新する際にシグナルを立てる
     */
    setFilterSignal(state, signal) {
      state.filterSignal = signal;
    },
    /**
     * クリア
     */
    clearmeasureHistoryList(state) {
      state.measureHistoryList.splice(0, state.measureHistoryList.length);
    },
    // -----------------------------------------
    // 抽出条件設定
    // -----------------------------------------
    conditionSet(state, getcondition) {
      state.condition = getcondition;
    }
  }
};
