/* eslint-disable */

import { ApiHelper } from '@/apis/AxiosHelper';

const apiPath = '/mstInfo/mstMedicine';

export default {
  namespaced: true,
  strict: true,

  state: {
    storeData: null,
  },

  mutations: {
    // DBレコード取得後stateを変更
    loadStore: (state, data) => (state.storeData = data),
  },

  getters: {
    storeData: state => state.storeData,
  },

  actions: {
    /**
     * DBレコード取得
     * @return {array} DBレコード
     */
    async getDb() {
      //console.log('@mstMedicineStore: getDb start');
      const response = await ApiHelper.get(apiPath);
      // TODO:エラー処理必要
      //console.log('@mstMedicineStore: getDb end');
      //console.log(response.data)
      return response.data;
    },

    /**
     * ストアへのDBレコードを読み込み
     * @param {string} patId: 患者ID
     * @return {object} DBレコード
     */
    async loadStore({ commit, dispatch }) {
      await dispatch('getDb').then(data => commit('loadStore', data));
    },
  },
};
