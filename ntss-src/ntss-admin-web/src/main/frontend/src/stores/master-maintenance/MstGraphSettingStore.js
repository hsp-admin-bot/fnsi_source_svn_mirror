/**
 * P-Ca9分割グラフ設定マスタメンテナンスStore.
 */
import {
  sendRequestGetMstFacility,
  sendRequestGetValueSignInByFacilityCd
} from "@/apis/mst-facility-setting-maintenance";
import {
  sendRequestGetMstGraphSettingData
} from "@/apis/mst-graph-setting-maintenance";
import { sendRequestGetDoctorsAtFacility } from "@/apis/facility";
import Vue from "vue";

export default {
  strict: true,
  namespaced: true,
  state: {
    // 選択されたマスタ
    selectedMasterName: "",
    // 選択されたマスタ名
    selectedLogicalMasterName: "",
    // マスタレコード
    masterRecordList: [],
    // ヘッダ検索条件
    condition: {
      recordName: ""
    },
    // スキーマ情報
    schema: {},
    // カラム情報
    columns: [],
    // モーダル画面に表示する情報
    userInfoModal: null,
    // 施設リスト
    facilityList: [],
    // 編集中のレコード
    editRecord: {},
    // 表示権限ユーザー
    userType: "",

    valueSignIn: ""
  },
  mutations: {
    setMasterName(state, selectedMasterName) {
      state.selectedMasterName = selectedMasterName;
    },
    setLogicalMasterName(state, selectedLogicalMasterName) {
      state.selectedLogicalMasterName = selectedLogicalMasterName;
    },
    setMasterRecordList(state, masterRecordList) {
      state.masterRecordList = masterRecordList;
    },

    // -----------------------------------------
    // 画面編集内容をstoreに反映
    // -----------------------------------------
    edit(state, editInfo) {
      const editRecord = editInfo.editRecord;
      const isSortMode = editInfo.isSortMode;

      // 該当レコードがあれば内容を更新、なければ追加
      const foundData = state.masterRecordList.data.find(e => {
        return e.dispOrder === editRecord.dispOrder;
      });
      const index = state.masterRecordList.data.indexOf(foundData);

      // 該当レコードがあれば編集内容を反映
      if (editRecord.operation != 1 && !isSortMode) {
        editRecord.operation = 2;
      }
      if (isSortMode) {
        editRecord.sortInputTime = Date.now();
      }

      Vue.set(state.masterRecordList.data, index, editRecord);
    },

    setCondition(state, condition) {
      state.condition = condition;
    },
    setSchema(state, schema) {
      state.schema = schema;
    },
    setColumns(state, columns) {
      state.columns = columns;
    },
    // ユーザ情報を設定
    setUserInfoModal(state, userData) {
      state.userInfoModal = userData;
    },
    // 施設情報を設定
    setFacilityList(state, facilityList) {
      state.facilityList = facilityList;
    },
    // 入力対象Editの情報を設定
    setEditRecord(state, editRecord) {
      state.editRecord = editRecord;
    },
    //表示権限のユーザータイプを設定
    setUserType(state, userType) {
      state.userType = userType;
    },

    setValueSignIn(state, valueSignIn) {
      state.valueSignIn = valueSignIn;
    },
  },
  actions: {
    // -----------------------------------------
    // P-Ca9分割グラフ設定データ一覧を取得
    // -----------------------------------------
    getGraphSettingDataList({ commit }, facilityCd) {
      commit("setMasterRecordList", []);
      commit("setSchema", []);
      commit("setColumns", []);

      return sendRequestGetMstGraphSettingData(facilityCd).then(response => {
        commit("setMasterRecordList", response.data.localDataSource);
        commit("setSchema", response.data.localDataSource.schema);
        commit("setColumns", response.data.columns);

        return Promise.resolve(response);
      });
    },
    // -----------------------------------------
    // 施設データ一覧を取得
    // -----------------------------------------
    facilityList({ commit }) {
      commit("setFacilityList", []);
      return sendRequestGetMstFacility().then(response => {
        commit("setFacilityList", response.data);
      });
    },

    // -----------------------------------------
    // 施設担当医師一覧を取得
    getDoctorsAtFacility(context, facilityCd) {
      return sendRequestGetDoctorsAtFacility(facilityCd);
    },
    // -----------------------------------------
    // データ一覧を更新
    // -----------------------------------------
    setMasterName({ commit }, selectedMasterName) {
      commit("setMasterName", selectedMasterName);
    },
    setLogicalMasterName({ commit }, selectedLogicalMasterName) {
      commit("setLogicalMasterName", selectedLogicalMasterName);
    },
    setMasterRecordList({ commit }, masterRecordList) {
      commit("setMasterRecordList", masterRecordList);
    },
    setCondition({ commit }, condition) {
      commit("setCondition", condition);
    },
    // 施設情報を設定
    setFacilityList({ commit }, facilityList) {
      commit("setFacilityList", facilityList);
    },
    // モーダル画面表示用のユーザ情報を設定
    setUserData({ commit }, userData) {
      commit("setUserInfoModal", userData);
    },
    edit({ commit }, editInfo) {
      commit("edit", editInfo);
    },
    setEditRecord({ commit }, payload) {
      commit("setEditRecord", payload);
    },
    // 表示権限のユーザータイプを設定
    setUserType({ commit }, userType) {
      commit("setUserType", userType);
    },

    async sendRequestGetValueSignInByFacilityCd({ commit }, facilityCd){
      const valueSignIn = await sendRequestGetValueSignInByFacilityCd(facilityCd);
      commit("setValueSignIn", valueSignIn.data);
    }
  },
  getters: {
    getFacilityList(state) {
      return state.facilityList;
    },
    getFilteredMasterRecordList(state) {
      const NIKKISO = "1";
      // データ件数が0件の場合、そのまま返却
      if (
        !state.masterRecordList.data ||
        state.masterRecordList.data.length === 0
      )
        return state.masterRecordList;

      // データ件数が1件以上の場合、条件を適用
      let returnData = state.masterRecordList.data;

      // 条件に機能名や設定名が設定されている場合は名前で抽出
      if (state.condition.recordName != "") {
        returnData = returnData.filter(
          e => e.functionName.indexOf(state.condition.recordName) !== -1 
          // MOD FNSI-7365 劉全航 start
          || e.description.indexOf(state.condition.recordName) !== -1
          // MOD FNSI-7365 劉全航 end
        );
      }
      // 日機装ユーザ以外は設定可能項目に制約をかける
      if (state.userType != NIKKISO) {
        returnData = returnData.filter(
          e => e.makerSetting === 0
        );
      }
      
      return {
        schema: state.masterRecordList.schema,
        data: returnData
      };
    },
    getMasterRecordList(state) {
      // mod #10198 検索した状態で保存すると保存が完了しない 宮崎 start
      let returnData = state.masterRecordList.data;
      return {
        schema: state.masterRecordList.schema,
        data: returnData
      };
      // mod #10198 検索した状態で保存すると保存が完了しない 宮崎 end
    },
    getEditRecord(state) {
      return state.editRecord;
    },
    getUpdateRecordList(state) {
      return state.masterRecordList.data;
    },
    getValueSignIn(state) {
      return state.valueSignIn;
    }
  }
};
