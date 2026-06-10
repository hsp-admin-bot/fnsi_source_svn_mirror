/**
 * 治療記録 投与薬剤情報ストア
 */
import {
  sendRequestGetTreatmentRecordMediInfo,
  sendRequestUpdateTreatmentRecordMediInfo
} from "@/apis/treatment-record";
import {
  sendRequestChangeIndMediInfoRst,
} from "@/apis/device-edge-order";

export default {
  strict: true,
  namespaced: true,
  state: {
    /**
     * 更新日時.
     */
    upDate: null
  },
  mutations: {
    /**
     * 更新日時を設定する.
     * @param {*} state stateオブジェクト
     * @param {*} upDate 更新日時
     */
    setUpDate(state, upDate) {
      state.upDate = upDate;
    }
  },
  actions: {
    // -----------------------------------------
    // 投与薬剤情報取得
    // -----------------------------------------
    // TODO: 局所的なeslintの設定を削除する
    /* eslint-disable no-unused-vars */
    getTreatmentRecordMediInfo({ commit }, ordNo) {
      return sendRequestGetTreatmentRecordMediInfo(ordNo).then(response => {
        commit("setUpDate", response.data.up_date);
        return response;
      });
    },
    // -----------------------------------------
    // 投与薬剤情報更新
    // -----------------------------------------
    updateTreatmentRecordMediInfo({ commit, state }, payload) {
      return sendRequestUpdateTreatmentRecordMediInfo(
        payload.ordNo,
        {
          ...payload.treatmentRecordMediInfo,
          up_date: state.upDate
        }
      );
    },
    //add FNSI内容修正 外部Api調用 房 start
    /**
     * お知らせを送信する.
     * @param {*} commit commitオブジェクト
     * @param {*} ordNo オーダ番号
     */
    sendRequestChangeIndMediIn(context, params) {
      return sendRequestChangeIndMediInfoRst(params);
    }
    //add FNSI内容修正 外部Api調用 房 end
  }
};
