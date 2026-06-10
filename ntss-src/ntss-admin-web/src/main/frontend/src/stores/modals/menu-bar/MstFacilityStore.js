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
    /* eslint-disable no-unused-vars */
    getUseFunctions({ commit }, facilityCd) {
      /* eslint-enable no-unused-vars */
      return sendRequestGetUseFunctions(facilityCd);
    }
  }
};
