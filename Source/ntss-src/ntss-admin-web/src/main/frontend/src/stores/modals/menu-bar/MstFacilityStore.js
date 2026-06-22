/**
 * 施設系ストア
 */
import { sendRequestGetUseFunctions } from "@/apis/facility.js";

export default {
  strict: true,
  namespaced: true,
  state: {},
  mutations: {},
  actions: {
    /**
     * 使用可能機能取得.
     * @param {*} commit COMMITオブジェクト
     * @param {string} facilityCd 施設コード
     */
    getUseFunctions({ commit }, facilityCd) {
      return sendRequestGetUseFunctions(facilityCd);
    }
  }
};
