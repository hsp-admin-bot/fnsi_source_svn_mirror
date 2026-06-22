import {
  sendRequestGetEdgeState,
  // add FNSI-連携情報を追加 李 start
  searchConIntelligenceState,
  // add FNSI-連携情報を追加 李 end
  updateSysCoopJournal,
  sendRequestIconStartStop,
  sendRequestGetExternalCoop,
  // add 5615 IFエッジコマンド実行 関 start
  sendRequestCommandKeyCoop,
  sendRequestGetEdgeCommandState
  // add 5615 IFエッジコマンド実行 関 end
  // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
  ,sendRequestGetIfEdgeConn
  // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
  ,sendRequestResetEdgeStatus
  //add 6085 施設がIFエッジある施設であるかの判断 ljx start
  ,sendRequestGetHasIfEdge
  //add 6085 施設がIFエッジある施設であるかの判断 ljx end
} from "@/apis/external-coop";
import { addPatNameSortToList } from "@/functions/SortFunctions";

//add #9523 患者連携情報の表示内容について zrx start
/** pat_coop_detail.save1～save10 の生文字列を表示用オブジェクトへ */
const CON_INTELLIGENCE_SAVE_KEYS = [
  "save1",
  "save2",
  "save3",
  "save4",
  "save5",
  "save6",
  "save7",
  "save8",
  "save9",
  "save10"
];
function parseConIntelligenceSave(raw) {
  if (raw == null || raw === "") {
    return {};
  }
  try {
    const p = JSON.parse(raw);
    if (p !== null && typeof p === "object" && !Array.isArray(p)) {
      return p;
    }
    if (Array.isArray(p)) {
      return p.reduce((acc, v, i) => {
        acc[String(i)] = v;
        return acc;
      }, {});
    }
    return { _: p };
  } catch (e) {
    return { _raw: String(raw) };
  }
}
//add #9523 患者連携情報の表示内容について zrx end

export default {
  namespaced: true,
  strict: !import.meta.env.PROD,
  state: {
    toFacilityCd: null,
    dataSearch: [],
// add 5615 IFエッジコマンド実行 関 start
    commandData: [],
// add 5615 IFエッジコマンド実行 関 end
    comparisonRecordModel: "",
    changeFlg: false,
    editRecord: {},
    edgeState: {},
    healthmonFacilityConn: [],
    healthmonServerConn: {},
    // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
    mntIfEdgeClineConn: [],
    versionCoop:"",
    // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
    cloudInfo: {
      aliveStatus: "", // 死活監視
      pendingCase: 0, // 処理待ち件数
      errorCase: 0, // エラー件数
      outRegDate: "", // 最終処理日時
      outAnaDate: "" //最終通信日時
    },
    // add FNSI-連携情報を追加 李 start
    conIntelligenceList: [],
    // add FNSI-連携情報を追加 李 end
    //add 6085 施設がIFエッジある施設であるかの判断 ljx start
    hasIfEdge: false,
    //add 6085 施設がIFエッジある施設であるかの判断 ljx end
    condition: null,
    // add 9583 by kangjie 20240403 start 通知一覧の連携エラー通知の遷移不正
    jumpCoopCondition: {}
    // add 9583 by kangjie 20240403 end 通知一覧の連携エラー通知の遷移不正
  },
  getters: {
    // add 9583 by kangjie 20240402 start 通知一覧の連携エラー通知の遷移不正
    getJumpChangeCoopState(state) {
      return state.jumpCoopCondition;
    },
    // add 9583 by kangjie 20240402 end 通知一覧の連携エラー通知の遷移不正
    getToFacilityCd: state => state.toFacilityCd,
    getCondition(state) {
      return state.condition;
    },
    getExternalCoopList(state) {
      return state.dataSearch;
    },
    getChangeFlg(state) {
      return state.changeFlg;
    },
    getEditRecord(state) {
      return state.editRecord;
    },
    // add 5615 IFエッジコマンド実行 関 start
    getEdgeCommand(state) {
      return state.commandData;
    },
    // add 5615 IFエッジコマンド実行 関 end
    getEdgeState(state) {
      return state.edgeState;
    },
    getHealthmonFacilityConn(state) {
      return state.healthmonFacilityConn;
    },
    getHealthmonServerConn(state) {
      return state.healthmonServerConn;
    },
    // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
    getMntIfEdgeConn(state) {
      return state.mntIfEdgeClineConn;
    },
    // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
    getCloudInfo(state) {
      return state.cloudInfo;
    },
    // add FNSI-連携情報を追加 李 start
    getConIntelligenceList(state) {
      return state.conIntelligenceList;
    },
    // add FNSI-連携情報を追加 李 end
    //add 6085 施設がIFエッジある施設であるかの判断 ljx start
    getHasIfEdge(state){
      return state.hasIfEdge;
    }
    //add 6085 施設がIFエッジある施設であるかの判断 ljx end
  },
  actions: {
    setEditRecord({ commit }, value) {
      commit("setEditRecord", value);
    },
    setToFacilityCd({ commit }, value) {
      commit("setToFacilityCd", value);
    },
    //add 6085 施設がIFエッジある施設であるかの判断 ljx start
    setHasIfEdge({ commit }, value) {
      commit("setHasIfEdge", value);
    },
    //add 6085 施設がIFエッジある施設であるかの判断 ljx end
    async searchExternalCoopList({ commit }, payload) {
      if(payload.facilityCd && payload.params) {
        await sendRequestGetExternalCoop(payload.facilityCd, payload.params)
        .then(response => {
          commit("setExternalCoopList", response.data);
        })
        .catch(e => {
          commit("setCloudInfo", {
            aliveStatus: "NG",
            pendingCase: 0,
            errorCase: 0,
            outRegDate: 0,
            outAnaDate: 0
          });
          throw e;
        });
      }
    },
    setChangeFlg({ commit }, value) {
      commit("setChangeFlg", value);
    },
    async sendRequestGetEdgeState({ commit }, payload) {
      try {
        const response = await sendRequestGetEdgeState(payload.facilityCd);
        // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
        const mntIfEdgeConn = await sendRequestGetIfEdgeConn(payload.facilityCd);
        // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
        let healthmonFacilityConn = [];
        let healthmonServerConn = {};
        if (response.data.length > 0) {
          for(var i = 0 ; i<response.data.length; i++){
            healthmonFacilityConn.push(response.data[i].healthmonFacilityConn && JSON.parse(
              response.data[i].healthmonFacilityConn)
            );
          }
          healthmonServerConn = response.data[0].healthmonServerConn && JSON.parse(
            response.data[0].healthmonServerConn
            );
        }
        let facilityConnArr = [];
        if (response.data) {
          for (var key in healthmonFacilityConn) {
            if (Object.prototype.hasOwnProperty.call(healthmonFacilityConn, key)) {
              healthmonFacilityConn[key].key = key;
              facilityConnArr.push(healthmonFacilityConn[key]);
            }
          }
        }
        commit("setHealthmonFacilityConn", facilityConnArr);
        commit("setHealthmonServerConn", healthmonServerConn);
        // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
        commit("setMntIfEdgeConn", mntIfEdgeConn.data);
        // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
      } catch (e) {
        throw new Error(e?.message ?? "", { cause: e });
      }
    },
    // add FNSI-連携情報を追加 李 start
    async searchConIntelligenceState({ commit }, payload) {
      try {

        // 連携情報取得
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//         const response = await searchConIntelligenceState(payload.facilityCd, payload.selectedPatId);
        const response = await searchConIntelligenceState(payload.facilityCd, payload.coopVersion, payload.selectedPatId);
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        //mod #9523 患者連携情報の表示内容について zrx start
        // 連携情報：save1～10 の JSON をオブジェクトのまま保持（キー／値表示用）
        const rows = response && response.data;
        if (Array.isArray(rows) && rows.length > 0 && rows[0] != null) {
          const row = rows[0];
          const list = CON_INTELLIGENCE_SAVE_KEYS.map(k =>
            parseConIntelligenceSave(row[k])
          );
          commit("setConIntelligenceList", list);
        } else {
          commit("setConIntelligenceList", []);
        }

      } catch (e) {
        commit("setConIntelligenceList", []);
        //mod #9523 患者連携情報の表示内容について zrx end
      }
    },
    // add FNSI-連携情報を追加 李 end
    // add 9583 by kangjie 20240402 start 通知一覧の連携エラー通知の遷移不正
    setJumpCoopCondition({ commit }, jumpCoopCondition) {
      commit("setJumpCoopCondition",jumpCoopCondition);
    },
    clearJumpCoopCondition({ commit }) {
      commit("clearJumpCoopCondition");
    },
    // add 9583 by kangjie 20240402 end 通知一覧の連携エラー通知の遷移不正
    setCondition({ commit }, condition) {
      commit("setCondition", condition);
    },
    updateSysCoopJournal(context, payload) {
      try {
        const response = updateSysCoopJournal(payload.updateList);
        return response;
      } catch (e) {
        throw new Error(e?.message ?? "", { cause: e });
      }
    },
    sendRequestIconStartStop(context, payload) {
      try {
        const response = sendRequestIconStartStop(payload);
        return response;
      } catch (e) {
        throw new Error(e?.message ?? "", { cause: e });
      }
    },
    // add 5615 IFエッジコマンド実行 関 start
    sendRequestCommandKeyCoop(context, payload) {
      try {
        const response = sendRequestCommandKeyCoop(payload);
        return response;
      } catch (e) {
        throw new Error(e?.message ?? "", { cause: e });
      }
    },
    async sendRequestGetEdgeCommandState({ commit }, payload) {
      try {
         await sendRequestGetEdgeCommandState(payload).then(response => {
          commit("setEdgeCommand", response.data);
        });
      } catch (e) {
        throw new Error(e?.message ?? "", { cause: e });
      }
    },
    // add 5615 IFエッジコマンド実行 関 end
    sendRequestResetEdgeStatus(context, payload) {
      try {
        const response = sendRequestResetEdgeStatus(payload);
        return response;
      } catch (e) {
        throw new Error(e?.message ?? "", { cause: e });
      }
    },
    // add 5615 IFエッジコマンド実行 関 end
    //add 6085 施設がIFエッジある施設であるかの判断 ljx start
    async sendRequestGetHasIfEdge({ commit }, payload) {
      try {
        await sendRequestGetHasIfEdge(payload.facilityCd).then(response => {
          if (response.data.length > 0 && null !== response.data[0]) {
            commit("setHasIfEdge", true);
          }else{
            commit("setHasIfEdge", false);
          }
        });
      } catch (e) {
        throw new Error(e?.message ?? "", { cause: e });
      }
    },
    //add 6085 施設がIFエッジある施設であるかの判断 ljx end
  },

  mutations: {
    // add 9583 by kangjie 20240401 start
    setJumpCoopCondition(state,jumpCoopCondition) {
      state.jumpCoopCondition = jumpCoopCondition;
    },
    clearJumpCoopCondition(state) {
      state.jumpCoopCondition = {};
    },
    // add 9583 by kangjie 20240401 end
    setToFacilityCd: (state, value) => {
      state.toFacilityCd = value;
    },
    setCondition(state, condition) {
      state.condition = condition;
    },
    //add 6085 施設がIFエッジある施設であるかの判断 ljx start
    setHasIfEdge(state, hasIfEdge) {
      state.hasIfEdge = hasIfEdge;
    },
    //add 6085 施設がIFエッジある施設であるかの判断 ljx end
    setExternalCoopList(state, value) {
      // システム共通患者名ソート用(フリガナ優先文字列)を追加
      state.dataSearch = addPatNameSortToList(JSON.parse(JSON.stringify(value)));
    },
    clearState: state => {
      state.toFacilityCd = null;
    },
    setChangeFlg(state, flg) {
      state.changeFlg = flg;
    },
    setComparisonRecordModel(state) {
      state.comparisonRecordModel = JSON.stringify(state.dataSearch.data);
    },
    setEditRecord(state, payload) {
      state.editRecord = payload;
    },
    // add 5615 IFエッジコマンド実行 関 start
    setEdgeCommand(state, value) {
      state.commandData = JSON.parse(JSON.stringify(value));
    },
    // add 5615 IFエッジコマンド実行 関 end
    edit(state, editInfo) {
      const editRecord = editInfo.editRecord;
      const isSortMode = editInfo.isSortMode;

      const foundData = state.dataSearch.data.find(e => {
        return e.code === editRecord.code;
      });
      const index = state.dataSearch.data.indexOf(foundData);

      if (index < 0) {
        editRecord.operation = 1;
        state.dataSearch.data.splice(0, 0, editRecord);
      } else {
        if (editRecord.operation != 1 && !isSortMode) {
          editRecord.operation = 2;
        }
        if (isSortMode) {
          editRecord.sortInputTime = Date.now();
        }
        state.dataSearch.data.splice(index, 1, editRecord);
      }
    },
    setEdgeState(state, payload) {
      return (state.edgeState = payload);
    },
    setHealthmonFacilityConn(state, payload) {
      return (state.healthmonFacilityConn = JSON.parse(JSON.stringify(payload)));
    },
    setHealthmonServerConn(state, payload) {
      return (state.healthmonServerConn = JSON.parse(JSON.stringify(payload)));
    },
    setVersionCoop(state, payload) {
      return (state.versionCoop = payload);
    },
    // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
    setMntIfEdgeConn(state, payload) {
      return (state.mntIfEdgeClineConn = JSON.parse(JSON.stringify(payload)));
    },
    // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
    setCloudInfo(state, payload) {
      return (state.cloudInfo = payload);
    },
    // add FNSI-連携情報を追加 李 start
    setConIntelligenceList(state, payload) {
      return (state.conIntelligenceList = payload);
    }
  }
};
