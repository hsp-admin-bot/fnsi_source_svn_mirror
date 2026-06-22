export default {
  strict: true,
  namespaced: true,
  state: {
    compareViewImgs: [],
    /*add FNSI-改修内容比較中の画像について、編集しても、最新の画像で適用されない 任 start*/
    isTrue: null
    /*add FNSI-改修内容比較中の画像について、編集しても、最新の画像で適用されない 任 end*/
  },
  mutations: {
    setCompareViewImgs(state, value) {
      state.compareViewImgs.push(value);
    },
    /*add FNSI-改修内容比較中の画像について、編集しても、最新の画像で適用されない 任 start*/
    setCompareViewImgsTrue(state) {
      state.compareViewImgs.forEach((item,index) => {
        if(item.isEdit === true){
          state.compareViewImgs[index].isEdit = false;
        }
        if(item.isDel === true){
          state.compareViewImgs[index].isDel = false;
        }
      })
    },
    setCompareViewImgsRemove(state, value) {
      state.compareViewImgs[value].isDel = true;
    },
    setCompareViewImgsMsg(state, value) {
      state.compareViewImgs.forEach((item,index) => {
        if(value.patEventCd === item.patEventCd){
          state.compareViewImgs[index].eventStartDate = value.eventStartDate;
          state.compareViewImgs[index].eventEndTime = value.eventEndTime;
          state.compareViewImgs[index].eventStartTime = value.eventStartTime;
          state.compareViewImgs[index].eventEndDate = value.eventEndDate;
        }
      })
    },
    setCompareViewImgsDelete(state, value) {
      state.compareViewImgs.splice(value,1);
    },
    setCompareViewImgsReplace(state, value) {
      state.compareViewImgs[value].isEdit = true;
    },
    setCompareViewImgsReplaceSrc(state, value) {
      state.compareViewImgs.forEach((item,index) => {
        if(value.patEventCd === item.patEventCd && value.targetId === item.targetId){
          state.compareViewImgs[index].data = value.data;
          state.compareViewImgs[index].isEdit = false;
          state.compareViewImgs[index].isDel = false;
        }
      })
    },
    setTarget(state, value) {
      state.isTrue = value;
    },
    /*add FNSI-改修内容比較中の画像について、編集しても、最新の画像で適用されない 任 end*/
    clearCompareViewImgs(state) {
      state.compareViewImgs = [];
    },
  },
  actions: {
    async setCompareViewImgs({ commit }, value) {
      commit("setCompareViewImgs", value);
    },
    /*add FNSI-改修内容比較中の画像について、編集しても、最新の画像で適用されない 任 start*/
    async setCompareViewImgsTrue({ commit }) {
      commit("setCompareViewImgsTrue");
    },
    async setCompareViewImgsMsg({ commit }, value) {
      commit("setCompareViewImgsMsg", value);
    },
    async setCompareViewImgsRemove({ commit }, value) {
      commit("setCompareViewImgsRemove", value);
    },
    async setCompareViewImgsDelete({ commit }, value) {
      commit("setCompareViewImgsDelete", value);
    },
    async setCompareViewImgsReplace({ commit }, value) {
      commit("setCompareViewImgsReplace", value);
    },
    async setCompareViewImgsReplaceSrc({ commit }, value) {
      commit("setCompareViewImgsReplaceSrc", value);
    },
    setTarget({ commit }, value) {
      commit("setTarget", value);
    },
    /*add FNSI-改修内容比較中の画像について、編集しても、最新の画像で適用されない 任 end*/
    async clearCompareViewImgs({ commit }) {
      commit("clearCompareViewImgs");
    },
  },
  getters: {
    getCompareViewImgs(state) {
      return state.compareViewImgs;
    },
    /*add FNSI-改修内容比較中の画像について、編集しても、最新の画像で適用されない 任 start*/
    getTarget(state) {
      return state.isTrue;
    },
    /*add FNSI-改修内容比較中の画像について、編集しても、最新の画像で適用されない 任 end*/
  },
};
