/* eslint-disable */

import { ApiHelper } from '@/apis/AxiosHelper';

const apiPath = '/mstInfo/mstInfection';

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
      const response = await ApiHelper.get(apiPath);
      return response.data;
    },

    /**
     * ストアへのDBレコードを読み込み
     * @return {object} DBレコード
     */
    async loadStore({ commit, dispatch }) {
      await dispatch('getDb')
        .then(data => commit('loadStore', data))
        .catch();
      //.catch(data => console.log('API： "' + apiPath + '" の実行に失敗しました。'));
    },
  },
};
