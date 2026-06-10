import {
  sendRequestGetMachineTypeList,
  sendRequestGetAllMachineByFacilityCd,
  sendRequestGetAllCategoryByFacilityCd,
  senRequestGetListLayoutByLayoutClassAndFacilityCd
} from "@/apis/mst-mente-layout";

export default {
  namespaced: true,
  strict: true,
  state: {
    // 型式マスタリスト（全件）
    machineTypeList: [],
    listMachine: [],
    categoryList: [],
    layoutGroupList: [],
  },
  getters: {
    getMachineTypeList(state) {
      return state.machineTypeList;
    },
    getListMachine(state) {
      return state.listMachine;
    },
    getCategoryList(state) {
      return state.categoryList;
    },
    getLayoutGroupList(state) {
      return state.layoutGroupList;
    },
  },
  actions: {
    async sendRequestGetMachineTypeList({ commit }) {
      await sendRequestGetMachineTypeList().then(res => {
        commit("setMachineTypeList", res.data);
      });
    },
    async sendRequestGetAllMachineByFacilityCd({ commit }, facilityCd) {
      await sendRequestGetAllMachineByFacilityCd(facilityCd).then(res => {
        commit("setListMachine", res.data);
      });
    },
    async sendRequestGetAllCategoryByFacilityCd({ commit }, facilityCd) {
      await sendRequestGetAllCategoryByFacilityCd(facilityCd).then(res => {
        const data = Array.from(res.data).map(item => ({
          ...item,
          detailList: JSON.parse(item.details || "[]")
        }));
        commit("setCategoryList", data);
      });
    },
    async senRequestGetListLayoutByLayoutClassAndFacilityCd({ commit }, facilityCd) {
      await senRequestGetListLayoutByLayoutClassAndFacilityCd(facilityCd).then(res => {
        commit("setLayoutGroupList", res.data);
      });
    },
  },
  mutations: {
    setMachineTypeList(state, data) {
      state.machineTypeList = data;
    },
    setListMachine(state, data) {
      state.listMachine = data;
    },
    setCategoryList(state, data) {
      state.categoryList = data;
    },
    setLayoutGroupList(state, data) {
      state.layoutGroupList = data;
    },
  },
};
