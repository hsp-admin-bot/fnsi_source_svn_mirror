
export default {
  namespaced: true,
  strict: true,

  state: {

    /**
     * @description 治療日
     * @type {Date}
     */
    treatDate: [],
    // mod 9283 印刷順が保存されない帳票がある　吉 start
    // sortTemp: [],
    sortTempDay: null,
    sortTempReg: null,
    // mod 9283 印刷順が保存されない帳票がある　吉 end
},

  getters: {
    getTreatDate: state => {
      if (state.treatDate === null) {
        return null;
      }
      return state.treatDate;
    },
    // mod 9283 印刷順が保存されない帳票がある　吉 start
    // getSortTemp(state){
    //   return state.sortTemp;
    // },
    getSortTempDay(state){
      return state.sortTempDay;
    },
    getSortTempReg(state){
      return state.sortTempReg;
    },
    // mod 9283 印刷順が保存されない帳票がある　吉 end
  },
  mutations: {
    /**
     * @description 治療日
     * @param {Object} treatDate
     */
    setSelectedTreatDate: (state, treatDate) => {
      state.treatDate = treatDate;
    },
    // mod 9283 印刷順が保存されない帳票がある　吉 start
    // setSortTemp: (state, sortTemp) => {
    //   state.sortTemp = sortTemp;
    // },
    setSortTempDay: (state, sortTempDay) => {
      state.sortTempDay = sortTempDay;
    },
    setSortTempReg: (state, sortTempReg) => {
      state.sortTempReg = sortTempReg;
    },
    // mod 9283 印刷順が保存されない帳票がある　吉 end
  }
};
