import { getMstUrlLinkRegister } from "@/functions/mst/MstGetters.js";

export default {
  strict: true,
  namespaced: true,
  state: {
    urlRegistList: [],
  },
  getters: {
    getUrlRegisterList(state) {
      return state.urlRegistList;
    },
  },
  actions: {
    async getUrlRegisterList({ commit }, facilityCd) {
      const mstUrlLink = await getMstUrlLinkRegister(facilityCd);
      mstUrlLink.forEach(url => {
        url.urlInfo = JSON.parse(url.urlInfo);
      })
      commit("setUrlRegisterList", mstUrlLink);
    }
  },
  mutations: {
    setUrlRegisterList(state, urlRegistList) {
      state.urlRegistList = urlRegistList;
    }
  }
};
