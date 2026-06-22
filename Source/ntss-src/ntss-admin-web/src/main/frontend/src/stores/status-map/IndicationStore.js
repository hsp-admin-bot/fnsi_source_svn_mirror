import { sendRequestPutCheckForMap } from "@/apis/status-map";

export default {
  strict: true,
  namespaced: true,
  state: {
    ordNo: null
  },
  getters: {
    getOrdNo: state => state.ordNo
  },
  mutations: {
    setOrdNo(state, ordNo) {
      state.ordNo = ordNo;
    }
  },
  actions: {
    setOrdNo({ commit }, ordNo) {
      commit("setOrdNo", ordNo);
    },
    checkForMap(context, params) {
      return sendRequestPutCheckForMap(params.ordNo, {
        content: params.content
      });
    }
  }
};
