/**
 * 装置マスタメンテナンスStore.
 */
import {
  sendRequestGetMstMachineComboListFacility,
  sendRequestSynchroMstMachine,
  sendRequestUpdateMstOfflineMachine,
  sendRequestGetMntFindMachineByFacility,
  sendRequestPostNotificationMachine,
  sendRequestGetDialysisState,
  sendRequestUpdateChangeMachine
} from "@/apis/mst-machine-maintenance";
import { sendRequestGetMstFacility } from "@/apis/mst-user-maintenance";

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
    // 通信種別
    comType: [],
    // 選択中の施設コード
    selectedFacilityCd: "",
    // 装置自動登録処理用ワークテーブル
    mntFindMachineList: [],
    // メッセージリスト
    messageList: [],
    // 選択施設のシステム利用
    facilitySysUseSetting: null,
    // 選択施設のエントリー済み装置
    entryMachineList: [],
    // 作業中装置番号
    editCode: null
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
    /**
     * 通信種別情報登録
     * @param {*} state
     * @param {*} comType 通信種別情報
     */
    setComType(state, comType) {
      state.comType = comType;
    },
    /**
     * 選択中の施設コード登録
     * @param {*} state
     * @param {*} selectedFacilityCd 選択中の施設コード
     */
    setSelectedFacilityCd(state, selectedFacilityCd) {
      state.selectedFacilityCd = selectedFacilityCd;
    },
    setMntFindMachineList(state, mntFindMachineList){
      state.mntFindMachineList = mntFindMachineList;
    },
    setMessageList(state, messageList) {
      state.messageList = messageList;
    },
    // 選択施設のシステム利用設定
    setFacilitySysUseSetting(state, facilitySysUseSetting) {
      state.facilitySysUseSetting = facilitySysUseSetting;
    },
    // 選択施設のエントリー済み装置設定
    setEntryMachineList(state, machineList) {
      state.entryMachineList = machineList;
    },
    // 作業中装置番号設定
    setEditCode(state, code) {
      state.editCode = code;
    }
  },
  actions: {
    /**
     * コンボボックスのための各マスタ一覧を取得
     */
    getComboRecordList({ commit }, facilityCd) {
      commit("setMachineType", []);
      commit("setDeviceEdge", []);
      commit("setComType", []);

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
        // モーダル化に伴いvalue,text以外のデータも取得
        const machinetTypeList = new Array();
        let comTypeList = new Array();
        response.data.machineTypeList.forEach(data => {
          machinetTypeList.push({
            value: data.machineTypeCd,
            text: data.machineType,
            model: data.model,
            com_type: data.comType,
            treat_mode: data.treatMode
          });
          if (data.comType !== null) {
            // 通信種別リストへの追加
            let comType = JSON.parse(data.comType);
            for (let type of comType) {
              const filteredComTypeList = comTypeList.filter(item => item.value === type.value);
              if (filteredComTypeList.length == 0) {
                comTypeList = comTypeList.concat(type);
              } else {
                for (const format of type.com_format_cd) {
                  const filteredComFormatCd = filteredComTypeList[0].com_format_cd.filter(item => item.value === format.value);
                  if (filteredComFormatCd.length == 0) {
                    filteredComTypeList[0].com_format_cd = filteredComTypeList[0].com_format_cd.concat(format);
                  }
                }
              }
            }
          }
        });
        // 型式コードでソート実施し格納
        machinetTypeList.sort(compare);
        commit("setMachineType", machinetTypeList);

        // 通信種別でソート実施し格納
        comTypeList.sort(compare);
        commit("setComType", comTypeList);

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
        //9871 delデバイスエッジが並び順の通りに表示しない zhao start
        //deviceEdgeList.sort(compare);
        //9871 delデバイスエッジが並び順の通りに表示しない zhao end
        commit("setDeviceEdge", deviceEdgeList);

        return Promise.resolve(response);
      });
    },
    /**
     * マスタ同期(装置マスタのみ)
     */
    synchroMstMachine(context, { deviceEdgeNo, facilityCd }) {
      return sendRequestSynchroMstMachine(deviceEdgeNo, facilityCd).then(response => {
        return Promise.resolve(response);
      });
    },
    /**
     * オフライン/オンラインを切り替えた装置状態更新
     */
    updateSwitchOfflineMachineState(context, { facilityCd, offline, online }) {
      return sendRequestUpdateMstOfflineMachine(facilityCd, offline, online).then(response => {
        return Promise.resolve(response);
      }).catch(err => {
        // 装置状態更新失敗でもマスタ更新自体は成功している
        return Promise.resolve(err);
      });
    },
    /**
     * 主キーや通信種別を切り替えた装置状態更新
     */
    updateChangeMachineState(context, { facilityCd, newOfflineAndCommonCodeList, changeMachineCodeList }) {
      return sendRequestUpdateChangeMachine(
        facilityCd,
        newOfflineAndCommonCodeList,
        changeMachineCodeList
      ).then(response => {
        return Promise.resolve(response);
      }).catch(err => {
        // 装置状態更新失敗でもマスタ更新自体は成功している
        return Promise.resolve(err);
      });
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
    /**
     * 施設情報を設定
     */
    setFacilityList({ commit }, facilityList) {
      commit("setFacilityList", facilityList);
    },
    /**
     * 装置自動登録処理用ワークテーブル
     * @param {*} param0
     * @param {*} facilityCd
     */
    getMntFindMachineListByFacility({ commit }, facilityCd) {
      commit("setMntFindMachineList", []);
      return sendRequestGetMntFindMachineByFacility(facilityCd).then(response => {
        commit("setMntFindMachineList", response.data);
        return Promise.resolve(response);
      });
    },
    /**
     * メッセージリストの保存
     * @param {Object} context
     * @param {String[]} messageList メッセージリスト
     */
    setMessageList({ commit }, messageList) {
      commit("setMessageList", messageList);
    },
    /**
     *
     * @param {*} context
     * @param {*} param1
     */
    notificationMachine(context, { procMode, facilityCd }) {
      return sendRequestPostNotificationMachine(procMode, facilityCd).then(response => {
        return Promise.resolve(response);
      });
    },
    //選択施設のシステム利用設定を格納
    setFacilitySysUseSetting({ commit }, facilitySysUseSetting) {
      commit("setFacilitySysUseSetting", facilitySysUseSetting);
    },
    /**
     * 条件送信済み～治療中の装置を取得
     * @param {any} context
     * @param {String} facilityCd
     */
    sendRequestGetDialysisState(context, facilityCd) {
      return sendRequestGetDialysisState(facilityCd);
    },
    /**
     * 条件送信済み～治療中の装置コードをstateに保存
     * @param {any} context
     * @param {String} facilityCd
     */
    setEntryMachineList({ commit }, machineList) {
      commit("setEntryMachineList", machineList);
    },
    /**
     * 作業中装置番号設定
     * @param {*} context
     * @param {*} code
     */
    setEditCode({commit}, code) {
      commit("setEditCode", code);
    }
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
    getComTypeList(state) {
      return state.comType;
    },
    getSelectedFacilityCd(state) {
      return state.selectedFacilityCd;
    },
    getMntFindMachineList(state) {
      return state.mntFindMachineList;
    },
    getMessageList(state){
      return state.messageList;
    },
    // 選択施設のシステム利用設定を取得
    getFacilitySysUseSetting(state) {
      return state.facilitySysUseSetting;
    },
    // 条件送信済み～治療中の装置リスト
    getEntryMachineList: state => state.entryMachineList,
    getIsEditingCode: state => state.editCode
  }
};
