/**
 * よく使う施設マスタ画面用Store
 */
// mod FNSI-よく使う施設の変更(変更をキャンセル) 関 start
// import { sendRequestGetFavoriteFacility } from "@/apis/mst-favorite-facility";
// mod FNSI-よく使う施設の変更(変更をキャンセル) 関 end
import { sendRequestGetMstFacilityByCd } from "@/apis/facility";

export default {
  strict: true,
  namespaced: true,
  state: {
    // 検索条件
    condition: {
      freeWord: "",
      prefCd: "",
    },
  },
  getters: {
    condition: state => {
      return state.condition;
    },
  },
  mutations: {
    conditionFreeWord(state, payload) {
      state.condition.freeWord = payload;
    },
    conditionPrefCd(state, payload) {
      state.condition.prefCd = payload;
    },
  },
  actions: {
    setConditionFreeWord(context, payload) {
      context.commit("conditionFreeWord", payload);
    },
    setConditionPrefCd(context, payload) {
      context.commit("conditionPrefCd", payload);
    },
    conditionsClear(context) {
      context.commit("conditionFreeWord", "");
      context.commit("conditionPrefCd", "");
    },
    
    /**
     * 施設情報取得
     */
    async getMstFacilityByCd(context, facilityCd) {
      return sendRequestGetMstFacilityByCd(facilityCd);
    }
  }
};
