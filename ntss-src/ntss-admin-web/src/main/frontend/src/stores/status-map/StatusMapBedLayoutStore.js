/**
 * 治療状況マップ用ストア
 */
import {
  sendRequestGetBedLayout,
  sendRequestGetMstBed,
  sendRequestGetBedLayoutList,
  sendRequestGetMstMachine,
  sendRequestUpdateBedLayout,
  sendRequestInsertBedLayout,
  sendRequestGetMachineType
} from "@/apis/mst-bedLayout";

export default {
  strict: true,
  namespaced: true,
  state: {
    // 選択中のベッドレイアウト
    selectedBedLayout: null,
    // ベッドレイアウト一覧
    bedLayoutList: null,
    // ベッド一覧
    bedList: null,
    // 装置一覧
    machineList: null,
    // 型式マスタ一覧
    machineTypeList: null
  },
  mutations: {
    setBedLayoutList(state, bedLayoutList) {
      state.bedLayoutList = bedLayoutList;
    },
    setBedList(state, bedList) {
      state.bedList = bedList;
    },
    setMachineList(state, machineList) {
      state.machineList = machineList;
    },
    setBedLayout(state, bedLayout) {
      state.selectedBedLayout = bedLayout;
    },
    setMachineTypeList(state, machineTypeList) {
      state.machineTypeList = machineTypeList;
    }
  },
  actions: {
    /**
     * stateを初期化
     * @param {*} param
     * @param {*} facilityCd
     */
    async stateInitialize({ dispatch, commit }, facilityCd) {
      await dispatch("fetchMachineList", facilityCd);
      await dispatch("fetchBedList", facilityCd);
      await dispatch("fetchBedLayoutList", facilityCd);
      await dispatch("fetchMachineTypeList");
      await commit("setBedLayout", null);
    },
    /**
     * ベッドレイアウト一覧をサーバーから取得
     * @param {*} param
     * @param {*} facilityCd
     */
    async fetchBedLayoutList({ commit }, facilityCd) {
      const response = await sendRequestGetBedLayoutList(facilityCd);

      if (response.status === 200 && response.data[0] !== null) {
        await commit("setBedLayoutList", response.data);
      }
    },
    /**
     * ベッド一覧をサーバーから取得
     * @param {*} param
     * @param {*} facilityCd
     */
    async fetchBedList({ commit }, facilityCd) {
      const response = await sendRequestGetMstBed(facilityCd);
      if (response.status === 200 && response.data[0] !== null) {
        await commit("setBedList", response.data);
      }
    },
    /**
     * 装置マスタ一覧をサーバーから取得
     * @param {*} param
     * @param {*} facilityCd
     */
    async fetchMachineList({ commit }, facilityCd) {
      const response = await sendRequestGetMstMachine(facilityCd);
      if (response.status === 200 && response.data[0] !== null) {
        await commit("setMachineList", response.data);
      }
    },
    async fetchMachineTypeList({ commit }) {
      const response = await sendRequestGetMachineType();
      if (response.status === 200 && response.data[0] !== null) {
        await commit("setMachineTypeList", response.data);
      }
    },
    /**
     * ベッドレイアウトを選ぶ
     * @param {*} param0
     * @param {*} param1
     */
    async selectBedLayout(
      { dispatch, commit, state },
      { facilityCd, layoutId }
    ) {
      await commit("setBedLayout", null);
      await dispatch("stateInitialize", facilityCd);
      const bedLayout = await state.bedLayoutList.find(
        dat => dat.layoutId === layoutId
      );
      if (bedLayout) {
        await commit("setBedLayout", bedLayout);
      }
    },
    /**
     * データ登録
     * @param {*} param0
     * @param {*} bedLayout
     */
    async registrationBedLayout({ state, dispatch }, bedLayout) {
      if (state.selectedBedLayout !== null) {
        // 更新
        bedLayout.layoutId = state.selectedBedLayout.layoutId;
        bedLayout.regDate = state.selectedBedLayout.regDate;
        bedLayout.upDate = state.selectedBedLayout.upDate;

        const oldData = await sendRequestGetBedLayout(
          bedLayout.facilityCd,
          bedLayout.layoutId
        );
        if (oldData.status === 200) {
          if (oldData.data.upDate === state.selectedBedLayout.upDate) {
            const response = await sendRequestUpdateBedLayout(bedLayout);
            if (response.status === 200) {
              await dispatch("stateInitialize", bedLayout.facilityCd);
              await dispatch("selectBedLayout", {
                facilityCd: bedLayout.facilityCd,
                layoutId: bedLayout.layoutId
              });
              return 0;
            } else {
              return -2;
            }
          } else {
            return -1;
          }
        }
      } else {
        // 新規登録
        const response = await sendRequestInsertBedLayout(bedLayout);
        // console.log(response);
        if (response.status === 200) {
          await dispatch("stateInitialize", bedLayout.facilityCd);
          await dispatch("selectBedLayout", {
            facilityCd: bedLayout.facilityCd,
            layoutId: response.data
          });
          return 1;
        } else {
          return -2;
        }
      }
    },
    /**
     * データ削除
     * @param {*} param0
     * @param {*} bedLayout
     */
    async deleteBedLayout({ state }) {
      if (state.selectedBedLayout !== null) {
        const oldData = await sendRequestGetBedLayout(
          state.selectedBedLayout.facilityCd,
          state.selectedBedLayout.layoutId
        );
        if (oldData.status === 200) {
          if (oldData.data.upDate === state.selectedBedLayout.upDate) {
            oldData.data.isDel = "1";
            const response = await sendRequestUpdateBedLayout(oldData.data);
            if (response.status === 200) {
              return 0;
            } else {
              return -2;
            }
          } else {
            return -1;
          }
        }
      } else {
        return -2;
      }
    }
  },
  getters: {
    getMachineAndBedList(state) {
      const bedList = state.bedList.filter(
        bed => bed.isDel === "0" && bed.isDisp === "1"
      );
      // 装置一覧とベッド一覧をmachineNoでマージ
      // 無い側のコードは-1で埋める。
      return state.machineList
        .filter(machine => machine.isDel === "0" && machine.isDisp === "1")
        .map(machine => {
          const bed = bedList.find(
            bed => machine.machineNo === (bed.machineNo ? bed.machineNo : -1)
          );
          return {
            machineNo: machine.machineNo,
            bedCd: bed ? bed.bedCd : -1,
            name: bed ? bed.bedName : machine.machineName
          };
        })
        .concat(
          bedList
            .filter(
              bed =>
                state.machineList.findIndex(
                  machine => machine.machineNo === bed.machineNo
                ) < 0
            )
            .map(bed => {
              return {
                machineNo: -1,
                bedCd: bed.bedCd,
                name: bed.bedName
              };
            })
        );
    },
    /**
     * 装置マスタ一覧を取得
     * @param {*} state
     */
    getMachineList(state) {
      return state.machineList;
    },
    /**
     * 選択中のベッドレイアウトを取得
     * @param {*} state
     */
    getBedLayout(state) {
      return state.selectedBedLayout;
    },
    /**
     * ベッドレイアウトリストを取得
     * @param {*} state
     */
    getBedLayoutList(state) {
      if (state.bedLayoutList !== null) {
        return state.bedLayoutList.filter(dat => dat.isDel !== "1");
      } else {
        return [];
      }
    },
    /**
     * 型式マスタからmodelを取得
     */
    getModel(state) {
      return machineTypeCd => {
        if (state.machineTypeList !== null) {
          const machineType = state.machineTypeList.find(
            dat => dat.machineTypeCd === machineTypeCd
          );
          return machineType !== null ? machineType.model : null;
        } else {
          return null;
        }
      };
    }
  }
};
