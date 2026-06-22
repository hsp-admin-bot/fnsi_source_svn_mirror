//@ts-check
/**
 * 条件送信用ストア
 */
import {
  sendRequestGetKurSelector,
  sendRequestGetSchedule,
  sendRequestGetScheduleByHospPatId,
  sendRequestGetPatId,
  sendRequestGetMeasuredValue
  // @ts-ignore
} from "@/apis/send-condition";
// @ts-ignore
import { validateID } from "@/functions/common/CommonValidators";
import { addPatNameSortToList } from "@/functions/SortFunctions";


export default {
  strict: !import.meta.env.PROD,
  namespaced: true,
  state: {
    // 体重計モード
    filteringHospPatId: null, // 入力院内患者ID
    scheduleList: null, // 患者検索画面表示用のスケジュール一覧
    // 患者検索モーダル用
    // クール一覧情報
    mstKurSelector: null,
    // ベッドグループ一覧情報
    mstBedGroupList: null
  },
  getters: {
    // 入力患者IDを取得
    getFilteringHospPatId: state => state.filteringHospPatId,
    // 予定一覧を取得
    getScheduleList: state => state.scheduleList,
    // 患者検索モーダル用クール一覧取得
    getMstKurSelector: state => state.mstKurSelector,
    // 患者検索モーダル用ベッドグループ一覧取得
    getMstBedGroupList: state => state.mstBedGroupList
  },
  actions: {
    /**
     * 抽出用の院内患者IDセット
     * @param {Object} context
     * @param {String} id
     */
    setFilteringHospPatId({ commit }, id) {
      // 患者情報セット
      commit("setFilteringHospPatId", { filteringHospPatId: id });
    },
    /**
     * 院内患者IDから患者ID
     * @param {Object} context
     * @param {Object} params
     * @param {String} params.hospPatId
     */
    findPatId(context, params) {
      // 患者情報セット
      return sendRequestGetPatId({
        hospPatId: params.hospPatId
      });
    },
    // add FNSI-次回同じ患者を検索する場合測定値保存する 徐 start
    /**
     * 患者IDから患者体重測定値取得
     * @param {Object} context
     * @param {Object} params
     * @param {Number} params.patId
     */
    findMeasuredValue(context, params) {
      return sendRequestGetMeasuredValue({
        patId: params.patId
      });
    },
    // add FNSI-次回同じ患者を検索する場合測定値保存する 徐 end
    /**
     * 患者検索用 患者情報一覧セット
     */
    setScheduleList({ commit }, data) {
      // 患者情報セット
      commit("setScheduleList", { scheduleList: data });
    },

    /**
     * クールとベッドの一覧取得
     */
    fetchKurBedGroup() {
      // クールとベッドの一覧取得
      return sendRequestGetKurSelector();
    },
    setKurBedGroup({ commit }, response) {
      // 取得したクール一覧情報をセット
      commit("setKurSelector", {
        mstKurSelector: response.data.kurSelector
      });

      const dataList = response.data.bedGroupList.copyWithin(0, 0);
      dataList.forEach((value, index, array) => {
        // ベッドリスト
        array[index].bedList = JSON.parse(array[index].bedList);
      });

      // 取得したベッドグループ一覧情報をセット
      commit("setBedGroupList", { mstBedGroupList: dataList });
    },

    /**
     * 指定患者のスケジュール取得
     * condition{ facilityCd: 施設コード, hospPatId: 院内患者コード, treatDate: 治療日 }
     * @param {Object} context
     * @param {Object} condition
     * @param {Number} condition.hospPatId 院内患者コード
     * @param {String} condition.treatDate 治療日 YYYYMMDD
     * @param {boolean} condition.isPast 過去日フラグ
     */
    fetchScheduleByHospPatId(context, condition) {
      if (validateID(condition.hospPatId) === "") {
        // 指定患者のスケジュール取得
        return sendRequestGetScheduleByHospPatId(condition);
      } else {
        // エラー文字列あり…半角英数字以外の文字列が院内IDに指定されている
        console.error("患者IDに不正な文字が指定されています");
        return null;
      }
    },

    /**
     * 本日のスケジュール取得
     * condition{ facilityCd: 施設コード, treatDate: 治療日 }
     * @param {Object} context
     * @param {Object} condition
     * @param {String} condition.treatDate 治療日 YYYYMMDD
     * @param {boolean} condition.isPast 過去日フラグ
     */
    searchWeightSchedule(context, condition) {
      // 指定患者のスケジュール取得
      return sendRequestGetSchedule(condition);
    }
  },
  mutations: {
    setFilteringHospPatId: (state, payload) => {
      state.filteringHospPatId = payload.filteringHospPatId;
    },
    setKurSelector: (state, payload) => {
      state.mstKurSelector = payload.mstKurSelector;
    },
    setBedGroupList: (state, payload) => {
      state.mstBedGroupList = payload.mstBedGroupList;
    },
    setScheduleList: (state, payload) => {
      state.scheduleList = addPatNameSortToList(payload.scheduleList);
    }
  }
};
