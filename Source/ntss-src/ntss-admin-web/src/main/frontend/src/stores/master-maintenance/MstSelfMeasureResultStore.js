/**
 * 自己診断判定マスタ用ストア
 */
import {
  sendRequestGetMachineType
} from "@/apis/mst-bedLayout";

export default {
  strict: true,
  namespaced: true,
  state: {
    // 型式マスタ一覧
    machineTypeList: null
  },
  mutations: {
    setMachineTypeList(state, machineTypeList) {
      state.machineTypeList = machineTypeList;
    }
  },
  actions: {
    async fetchMachineTypeList({ commit }) {
      // ソート関数
      const compare = (a, b) => {
        if (a.machineTypeCd < b.machineTypeCd) {
          return -1;
        }
        if (a.machineTypeCd > b.machineTypeCd) {
          return 1;
        }
        return 0;
      };

      const response = await sendRequestGetMachineType();
      if (response.status === 200 && response.data[0] !== null) {
        // 型式コードでソート実施し格納
        const machinetTypeList = response.data;
        machinetTypeList.sort(compare);
        await commit("setMachineTypeList", machinetTypeList);
      }
    }
  },
  getters: {
    getMachineTypeList(state) {
      return state.machineTypeList;
    }
  }
};
