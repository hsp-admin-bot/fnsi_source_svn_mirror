/**
 * 装置設定用Store.
 */

export default {
  strict: true,
  namespaced: true,
  state: {
    /**
     * @description 装置種類名称
     */
    selectedDeviceSetType: null,
    /**
     * @description 装置設定値取得元
     */
    selectedDeviceSetSrcType: null,
    // add #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 start
    /**
     * @description 装置設定状态
     */
    selectedDeviceSetState: null,
    // add #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 end
  },
  mutations: {
    setSelectedDeviceSetType(state, selectedDeviceSetType) {
      state.selectedDeviceSetType = selectedDeviceSetType;
    },
    setSelectedDeviceSetSrcType(state, selectedDeviceSetSrcType) {
      state.selectedDeviceSetSrcType = selectedDeviceSetSrcType;
    },
    // add #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 start
    setSelectedDeviceSetState (state, selectedDeviceSetState) {
      state.selectedDeviceSetState = selectedDeviceSetState
    }
    // add #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 end
  },
  actions: {
    setDeviceSetInfo({ commit }, { deviceType, deviceSourceType }) {
      commit("setSelectedDeviceSetType", deviceType);
      commit("setSelectedDeviceSetSrcType", deviceSourceType);
    },
    // add #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 start
    setSelectedDeviceSetInfoState ({ commit }, { deviceState }) {
      commit("setSelectedDeviceSetState", deviceState)
    }
    // add #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 end
  },
  getters: {
    getSelectedDeviceSetType(state) {
      return state.selectedDeviceSetType;
    },
    getSelectedDeviceSetSrcType(state) {
      return state.selectedDeviceSetSrcType;
    },
    // add #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 start
    getSelectedDeviceSetState (state) {
      return state.selectedDeviceSetState;
    }
    // add #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 end
  }
};
