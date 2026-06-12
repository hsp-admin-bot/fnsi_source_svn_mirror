export default {
  strict: true,
  namespaced: true,
  state: {
    /* add EOL対応内部 #6921 by ztc 2023-07-08 --start */
    loopFlag: false,
    doctorList: [],
    doctorName: "",
    doctorId: null
    /* add EOL対応内部 #6921 by ztc 2023-07-08 --end */
  },
  mutations: {
    setLoopFlag(state, loopFlag) {
      state.loopFlag = loopFlag;
    },
    /* add EOL対応内部 #6921 by ztc 2023-07-08 --start */
    setDoctorList(state, doctorList) {
      state.doctorList = doctorList;
    },
    setDoctorName(state, doctorName) {
      state.doctorName = doctorName;
    },
    setDoctorId(state, doctorId) {
      state.doctorId = doctorId;
    },
    /* add EOL対応内部 #6921 by ztc 2023-07-08 --end */
  },

  getters: {
    getLoopFlag(state) {
      return state.loopFlag;
    },
    /* add EOL対応内部 #6921 by ztc 2023-07-08 --start */
    getDoctorList(state) {
      return state.doctorList;
    },
    getDoctorName(state) {
      return state.doctorName;
    },
    getDoctorId(state) {
      return state.doctorId;
    },
    /* add EOL対応内部 #6921 by ztc 2023-07-08 --end */
  }
};
