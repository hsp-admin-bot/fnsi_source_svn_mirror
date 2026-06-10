/**
 * 標準医薬品マスタ検索用のストア
 * 検索モーダルで選択された標準医薬品マスタの情報は本ストア経由で呼出元に返却する.
 * モーダルにて【キャンセル】ボタンをクリックした場合、選択された標準医薬品マスタにはnullが設定される.
 */

import {
  sendRequestGetSysMedicineAll  
} from "@/apis/sys-medicine";

export default {
  strict: true,
  namespaced: true,
  state: {
    /**
     * 選択した標準医薬品マスタ
     */
    selectedSysMedicine: null,
    /**
     * 呼出元で選択されている個別医薬品コード(YJコード)
     */
    selectedStandardMedicineCd: null
  },
  mutations: {
    /**
     * 選択した標準医薬品マスタを設定する.
     * @param {*} state stateオブジェクト
     * @param {*} sysMedicine 選択された標準医薬品マスタ
     */
    setSelectedSysMedicine(state, sysMedicine) {
      state.selectedSysMedicine = sysMedicine;
    },
    /**
     * 呼出元で選択されている個別医薬品コード(YJコード)を設定する.
     * @param {*} state stateオブジェクト
     * @param {*} selectedStandardMedicineCd 呼出元で選択されている個別医薬品コード(YJコード)
     */
    selectedStandardMedicineCd(state, selectedStandardMedicineCd) {
      this.selectedStandardMedicineCd = selectedStandardMedicineCd;
    }
  },
  actions: {
    /**
     * 標準医薬品マスタを全件取得する.
     * @param {*} commit COMMITオブジェクト
     */
    /* eslint-disable no-unused-vars */
    getSysMedicineAll({commit}) {
      /* eslint-disable no-unused-vars */
      return sendRequestGetSysMedicineAll();
    },
    /**
     * 選択した標準医薬品マスタを設定する.
     * @param {*} commit stateオブジェクト
     * @param {*} sysMedicine 選択された標準医薬品マスタ
     */
    setSelectedSysMedicine({ commit }, sysMedicine) {
      commit("setSelectedSysMedicine", sysMedicine);
    },
    /**
     * 呼出元で選択されている個別医薬品コード(YJコード)を設定する.
     * @param {*} commit stateオブジェクト
     * @param {*} selectedStandardMedicineCd 個別医薬品コード(YJコード) 
     */
    setSelectedStandardMedicineCd({commit}, selectedStandardMedicineCd) {
      commit("setSelectedStandardMedicineCd", selectedStandardMedicineCd);
    }
  },
  getters: {
    /**
     * 選択した標準医薬品マスタを取得する.
     * @param {*} state stateオブジェクト
     * @returns 選択された標準医薬品マスタ(未選択の場合、nullが設定されている.)
     */
    getSelectedSysMedicine(state) {
      return state.selectedSysMedicine;
    }
  }
};
