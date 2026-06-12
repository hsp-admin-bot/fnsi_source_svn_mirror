/**
 * 警報通知マスタ画面用Store
 */
import { deepCopy } from "@/functions/common/CommonFunctions";
import { sendRequestFetchStaffFacilities } from "@/apis/staff-facility";
import { sendRequestGetMachineRecord } from "@/apis/machine-record";
import { sendRequestGetDestinationGroupName } from "@/apis/destination-group";
import { MachineRecord } from "@/stores/master-maintenance/mst-alarm-notification/MachineRecord";

export default {
  strict: true,
  namespaced: true,
  state: {
    // 検索条件
    condition: {
      machineRecord: "",
      onlySendEmail: false,
      isDefault: "1",
      logClass: "0",
      targetModel: "0"
    },
    // 全装置記録
    allMachineRecords: []
  },
  getters: {
    condition: state => {
      return state.condition;
    },
    recordsByCondition: state => {
      const _machineRecord = state.condition.machineRecord;
      const _onlySendEmail = state.condition.onlySendEmail;
      const _isDefault = state.condition.isDefault;
      const _logClass = state.condition.logClass;
      const _targetModel = state.condition.targetModel;

      return state.allMachineRecords
        .filter(record => record.recordContent.indexOf(_machineRecord) > -1)
        .filter(record => {
          return _onlySendEmail ? record.beSendEmail : true;
        })
        .filter(
          record => (_isDefault === "0" ? true : record.isDefault === "1")
        )
        .filter(
          record => (_logClass === "0" ? true : record.logClass === _logClass)
        )
        .filter(
          record =>
            _targetModel === "0" ? true : record.targetModel === _targetModel
        )
        .sort((a, b) => {
          const cdA = a.cd.toUpperCase(); // 大文字と小文字を無視する
          const cdB = b.cd.toUpperCase(); // 大文字と小文字を無視する
          if (cdA < cdB) {
            return -1;
          }
          if (cdA > cdB) {
            return 1;
          }
          return 0;
        });
    }
  },
  mutations: {
    // 装置記録全件を格納
    saveRecords(state, payload) {
      const machineRecordsAll = payload.machineRecordsAll;
      const selectedMachineRecordCds = payload.selectedMachineRecords.cds.map(
        r => r.machine_record_cd
      );
      state.allMachineRecords = machineRecordsAll.map(
        record =>
          new MachineRecord(
            record.code,
            record.message,
            record.is_default,
            record.log_class,
            record.target_model,
            selectedMachineRecordCds.find(r => r === record.code)
          )
      );
    },
    // 検索条件(テキスト)を格納
    conditionMachineRecord(state, payload) {
      state.condition.machineRecord = payload;
    },
    // 検索条件(チェックONのみ)を格納
    conditionOnlySendEmail(state, payload) {
      state.condition.onlySendEmail = payload;
    },
    // 検索条件(推奨項目)を格納
    conditionIsDefault(state, payload) {
      state.condition.isDefault = payload;
    },
    // 検索条件(ログ分類)を格納
    conditionLogClass(state, payload) {
      state.condition.logClass = payload;
    },
    // 検索条件(対象機種)を格納
    conditionTargetModel(state, payload) {
      state.condition.targetModel = payload;
    },
    // 装置記録1件を格納
    saveRecord(state, payload) {
      const index = state.allMachineRecords.findIndex(
        _record => _record.cd === payload.cd
      );
      state.allMachineRecords[index] = payload;
    },
    setCollectMachineRecords(state, payload) {
      state.allMachineRecords = payload;
    }
  },
  actions: {
    // 装置記録全件を格納
    async fetchAllRecords(context, payload) {
      const response = await sendRequestGetMachineRecord(payload.facility);
      const selectedMachineRecords = payload.payload;
      context.commit("saveRecords", {
        machineRecordsAll: response.data.machineRecords,
        selectedMachineRecords
      });
    },
    // 担当施設一覧を取得
    fetchStaffFacilities(context, payload) {
      return sendRequestFetchStaffFacilities(payload);
    },
    // 送信先グループ名称を取得
    findGroupName(context, payload) {
      return sendRequestGetDestinationGroupName(payload);
    },
    // 検索条件(テキスト)を格納
    setConditionMachineRecord(context, payload) {
      context.commit("conditionMachineRecord", payload);
    },
    // 検索条件(チェックONのみ)を格納
    setConditionOnlySendEmail(context, payload) {
      context.commit("conditionOnlySendEmail", payload);
    },
    // 検索条件(推奨項目)を格納
    setConditionIsDefault(context, payload) {
      context.commit("conditionIsDefault", payload);
    },
    // 検索条件(ログ分類)を格納
    setConditionLogClass(context, payload) {
      context.commit("conditionLogClass", payload);
    },
    // 検索条件(対象機種)を格納
    setConditionTargetModel(context, payload) {
      context.commit("conditionTargetModel", payload);
    },
    // 検索条件クリア
    conditionsClear(context) {
      context.commit("conditionMachineRecord", "");
      context.commit("conditionOnlySendEmail", false);
      context.commit("conditionIsDefault", "0");
      context.commit("conditionLogClass", "0");
      context.commit("conditionTargetModel", "0");
    },
    // 装置記録1件を格納
    saveRecord(context, payload) {
      context.commit("saveRecord", payload);
    },
    // 装置記録をまとめて格納
    setCollectMachineRecords(context, payload) {
      let tmp = deepCopy(context.state.allMachineRecords);
      for (let i = 0; i < payload.length; i++) {
        const index = tmp.findIndex(
          _record => _record.cd === payload[i].cd
        );
        tmp[index] = payload[i];
      }
      context.commit("setCollectMachineRecords", tmp);
    }
  }
};
