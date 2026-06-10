import { ApiHelper } from "@/apis/AxiosHelper";

export default {
  namespaced: true,
  strict: process.env.NODE_ENV !== "production",
  state: {
    facilitySetting: {
      passwordMin: null,
      lockCount: null
    },
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    isProvisional : null,
    facilityCd : null
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
  },
  getters: {
    getFacilitySetting(state) {
      return state.facilitySetting;
    },
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    getProvisional(state) {
      return state.isProvisional;
    },
    getFacilityCd(state) {
      return state.facilityCd;
    },
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
  },

  actions: {
    setFacilitySetting({ commit }) {
      ApiHelper.get("/cl-facility/getFacilitySetting")
        .then(res => {
          commit("setFacilitySetting", res.data);
        });
    },
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    setProvisional({ commit } ,value) {
      commit("setProvisional",value);
    },

    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
  },
  mutations: {
    setFacilitySetting(state, value) {
      state.facilitySetting = value;
    },
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    setProvisional(state, value) {
      state.isProvisional = value.isProvisional;
      state.facilityCd = value.facilityCd;
    },
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
  }
};
