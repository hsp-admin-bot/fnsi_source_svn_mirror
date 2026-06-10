import { facilityByCd } from "@/functions/mst/MstGetters.js";

export default {
  namespaced: true,
  strict: process.env.NODE_ENV !== "production",
  state: {
    useFunction: []
  },
  getters: {
    useFunction({ useFunction }) {
      return useFunction;
    },
    isUseFunction: state => functionCd => {
      return state.useFunction.indexOf(functionCd) >= 0;
    }
  },
  actions: {
    setUseFunction({ commit }, useFunction) {
      if(useFunction && useFunction.length > 0) {
        const useFuncObj =  JSON.parse(useFunction);
        const funcList =  useFuncObj.func_cds.map(element => {
          return element.func_cd;
        });
        commit("setUseFunction", funcList);
      }
    },

    async getUseFuncByFacilityCd({dispatch, rootGetters}) {
      const facilityCd = rootGetters["user/getFacilityCd"];
      await facilityByCd(facilityCd).then( response => {
        if(response && response.useFunction) {
          dispatch("setUseFunction", response.useFunction);
        }
      });
    }
  },
  mutations: {
    setUseFunction(state, useFunction) {
      state.useFunction = useFunction;
    },
  }
};
