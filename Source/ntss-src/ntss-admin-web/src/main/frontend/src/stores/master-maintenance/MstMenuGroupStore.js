import { getMstMenuGroup } from "@/functions/mst/MstGetters.js";

export default {
  strict: true,
  namespaced: true,
  state: {
    menuGroupList: [],
  },
  getters: {
    getMenuGroupList(state) {
      return state.menuGroupList;
    },
  },
  actions: {
    async getMenuGroupList({ commit }, facilityCd) {
      const mstMenuGroup = await getMstMenuGroup(facilityCd);
      mstMenuGroup.forEach(group => {
        group.menuList = JSON.parse(group.menuList);
        group.iconInfo = JSON.parse(group.iconInfo);
      })
      commit("setMenuGroupList", mstMenuGroup);
    },
  },
  mutations: {
    setMenuGroupList(state, menuGroupList) {
      state.menuGroupList = menuGroupList;
    }
  }
};
