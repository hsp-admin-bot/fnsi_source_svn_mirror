import { ApiHelper } from "@/apis/AxiosHelper";

export default {
  namespaced: true,
  strict: process.env.NODE_ENV !== "production",
  state: {
    mstPersonalUser: [],
    mstJob: []
  },
  getters: {
    mstPersonalUser({ mstPersonalUser }) {
      return mstPersonalUser;
    },
    mstJob({ mstJob }) {
      return mstJob;
    }
  },
  actions: {
    async getMst({ commit, rootGetters }) {
      const facilityCd = rootGetters["user/getFacilityCd"];
      await Promise.all([
        getMstPersonalUser(commit, facilityCd),
        getMstJob(commit, facilityCd)
      ]);
    },
    /**
     * add by maxueqiang
     * bug:4309
     * @param {}} param0
     */
    async getMstJobData({commit, rootGetters}){
      const facilityCd = rootGetters["user/getFacilityCd"];
      await getMstJob(commit, facilityCd)
    }
  },
  mutations: {
    setMstPersonalUser(state, mstPersonalUser) {
      state.mstPersonalUser = mstPersonalUser;
    },
    setMstJob(state, mstJob) {
      state.mstJob = mstJob;
    }
  }
};

async function getMstPersonalUser(commit, facilityCd) {
  const responseUser = await ApiHelper.get(`/mstInfo/mstPersonalUser`, {
    facility_cd: facilityCd
  });
  commit("setMstPersonalUser", responseUser.data);
}

async function getMstJob(commit, facilityCd) {
  const responseJob = await ApiHelper.get(
    `/master_maintenance/mst_user/mst_job/${facilityCd}`
  );
  commit("setMstJob", responseJob.data);
}
