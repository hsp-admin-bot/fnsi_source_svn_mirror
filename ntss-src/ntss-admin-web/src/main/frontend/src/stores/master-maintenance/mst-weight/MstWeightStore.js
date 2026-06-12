//@ts-check

// @ts-ignore
import MstWeightCheckStore from "@/stores/master-maintenance/mst-weight/MstWeightCheckStore";
// @ts-ignore
import MstWeightPrintingStore from "@/stores/master-maintenance/mst-weight/MstWeightPrintingStore";
// @ts-ignore
import MstWeightScaleBedStore from "@/stores/master-maintenance/mst-weight/MstWeightScaleBedStore";

import {sendRequestPostMstMntSynchro, sendRequestPostMstMntSynchroByFacilityCd, sendRequestMstChangedNotify} from "@/apis/mst-weight-maintenance";

export default {
  // @ts-ignore
  strict: !import.meta.env.PROD,
  namespaced: true,
  modules: {
    check: MstWeightCheckStore,
    print: MstWeightPrintingStore,
    scale_bed: MstWeightScaleBedStore
  },
  state: {
    // 同一画面内共通編集フラグ
    isGridEditing: false,
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 start   
    isChangedMstWeight:true,
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 end
  },
  getters: {
    // 編集フラグ
    getIsGridEditing: state => state.isGridEditing,
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 start   
    getIsChangedMstWeight :state =>state.isChangedMstWeight
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 end
  },
  actions: {
    // -----------------------------------------
    // 体重計マスタメイン画面用
    // -----------------------------------------
    /**
     * @param {{commit: function}} context
     * @param {Boolean} isEditing
     */
    setIsGridEditing({ commit }, isEditing) {
      commit("setIsGridEditing", isEditing);
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 start   
    /**
     * @param {{commit: function}} context
     * @param {Boolean} isChangedMstWeight
     */
    setIsChangedMstWeight({ commit }, isChangedMstWeight) {
      commit("setIsChangedMstWeight", isChangedMstWeight);
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 end
    /**
     * 体重計マスタから体重計状態テーブルへの登録
     */
    requestMst2MntTable() {
      return sendRequestPostMstMntSynchro();
    },
    // #11987 2026.05.08 add 体重計マスタの変更をアプリに通知 TDC片口 start
    requestMstChangedNotify(_, param) {
      return sendRequestMstChangedNotify(param.facilityCd, param.weightNoList);
    },
    // #11987 2026.05.08 add 体重計マスタの変更をアプリに通知 TDC片口 end
    // add マスタ一覧 1･施設切替を可能とする 孔s start
    requestMst2MntTableByFacilityCd(tmp, facilityCd) {
      return sendRequestPostMstMntSynchroByFacilityCd(facilityCd);
    }
    // add マスタ一覧 1･施設切替を可能とする 孔s end
  },
  mutations: {
    // -----------------------------------------
    // 体重計設定用
    // -----------------------------------------
    /**
     * @param {{ isGridEditing: boolean; }} state
     * @param {boolean} isEditing
     */
    setIsGridEditing(state, isEditing) {
      state.isGridEditing = isEditing;
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 start 
    setIsChangedMstWeight(state, isChangedMstWeight) {
      state.isChangedMstWeight = isChangedMstWeight
    }
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 end
  }
};
