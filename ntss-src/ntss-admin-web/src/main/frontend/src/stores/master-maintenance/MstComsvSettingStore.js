/**
 * 通信サーバーマスタメンテナンスStore.
 */
import {
  sendRequestGetMstMachineComboListFacility,
  sendRequestSynchroMstComSvSetting
} from "@/apis/mst-comsv-setting-maintenance";
import {
  sendRequestGetMstFacility
} from "@/apis/mst-user-maintenance";

export default {
  strict: true,
  namespaced: true,
  state: {
    // 型式マスタ
    machineType: [],
    // デバイスエッジマスタ
    deviceEdge: [],
    // 施設リスト
    facilityList: [],
    // 選択施設
    selectFacility: "",
    // 編集前のレコード
    initEditRecord: {},
  },
  mutations: {
    /**
     * 型式マスタ情報登録
     * @param {*} state
     * @param {*} machineType 型式マスタ情報
     */
    setMachineType(state, machineType) {
      state.machineType = machineType;
    },
    /**
     * デバイスエッジマスタ情報登録
     * @param {*} state
     * @param {*} deviceEdge デバイスエッジマスタ情報
     */
    setDeviceEdge(state, deviceEdge) {
      state.deviceEdge = deviceEdge;
    },

    // 施設情報を設定
    setFacilityList(state, facilityList) {
      state.facilityList = facilityList;
    },

    // 選択施設を設定
    setSelectFacility(state, selectFacility){
      state.selectFacility = selectFacility;
    },
    setInitEditRecord(state, initEditRecord) {
      state.initEditRecord = initEditRecord;
    }

  },
  actions: {
    /**
     * コンボボックスのための各マスタ一覧を取得
     */
    getComboRecordList({ commit }, facilityCd) {
      commit("setMachineType", []);
      commit("setDeviceEdge", []);

      // 型式、デバイスエッジマスタ取得
      return sendRequestGetMstMachineComboListFacility(facilityCd).then(response => {
        // ソート関数
        const compare = (a, b) => {
          if (a.value < b.value) {
            return -1;
          }
          if (a.value > b.Value) {
            return 1;
          }
          return 0;
        };

        // 型式
        const machineTypeList = new Array();
        response.data.machineTypeList.forEach(data => {
          machineTypeList.push({
            value: data.machineTypeCd,
            text: data.machineType
          });
        });
        // 型式コードでソート実施し格納
        machineTypeList.sort(compare);
        commit("setMachineType", machineTypeList);

        // デバイスエッジ
        const deviceEdgeList = new Array();
        response.data.deviceEdgeList.forEach(data => {
          deviceEdgeList.push({
            value: data.deviceEdgeNo,
            text: data.deviceName,
            //add #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される start
            del: data.isDel
            //add #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される end
          });
        });
        // デバイスエッジ番号でソート実施し格納
        deviceEdgeList.sort(compare);
        commit("setDeviceEdge", deviceEdgeList);

        return Promise.resolve(response);
      });
    },
    /**
     * マスタ同期(通信サーバー設定マスタ)
     */
    synchroMstComSvSetting(context, { facilityCd, deviceEdgeNo }) {
      return sendRequestSynchroMstComSvSetting(facilityCd, deviceEdgeNo).then(
        response => {
          return Promise.resolve(response);
        }
      );
    },
    /**
     * 施設データ一覧を取得
     */
    facilityList({ commit }) {
      commit("setFacilityList", []);
      return sendRequestGetMstFacility().then(response => {
        commit("setFacilityList", response.data);
      });
    },
    // 施設情報を設定
    setFacilityList({ commit }, facilityList) {
      commit("setFacilityList", facilityList);
    },

    // 選択施設を設定
    setSelectFacility({ commit }, selectFacility){
      commit("setSelectFacility", selectFacility);
    },
    setInitEditRecord({ commit }, payload) {
      commit("setInitEditRecord", payload);
    },
  },
  getters: {
    getMachineTypeList(state) {
      return state.machineType;
    },
    getDeviceEdgeList(state) {
      return state.deviceEdge;
    },
    getFacilityList(state) {
      return state.facilityList;
    },
    getSelectFacility(state){
      return state.selectFacility;
    },
    getInitEditRecord(state) {
      return state.initEditRecord;
    }
  }
};
