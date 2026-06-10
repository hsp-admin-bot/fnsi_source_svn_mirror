/**
 * 施設設定マスタメンテナンスStore.
 */
import {
  sendRequestGetMstFacilitySettingData,
  sendRequestGetMstFacility,
  sendRequestGetValueSignInByFacilityCd
} from "@/apis/mst-facility-setting-maintenance";
import {
  sendRequestGetDoctorsAtFacility,
  // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc start
  sendRequestGetDoctorsAtFacilityIncludeDel
  // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc end
} from "@/apis/facility";
import Vue from "vue";
import { SYS_USE_TYPE, SYS_USE_DISP } from "@/constants/sysUseConstants";
import { FUNC_SCALE_BED } from "@/constants/function-code";

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

    valueSignIn: "",
    // 選択施設のシステム利用設定
    facilitySysUseSetting: ""
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
    setUserType(state, userType){
      state.userType = userType;
    },

    setValueSignIn(state, valueSignIn){
      state.valueSignIn = valueSignIn;
    },
    // 選択施設のシステム利用設定を設定
    setFacilitySysUseSetting(state, facilitySysUseSetting){
      state.facilitySysUseSetting = facilitySysUseSetting;
    }
  },
  actions: {
    // -----------------------------------------
    // 施設設定データ一覧を取得
    // -----------------------------------------
    getFacilitySettingDataList({ commit }, facilityCd) {
      commit("setMasterRecordList", []);
      commit("setSchema", []);
      commit("setColumns", []);

      return sendRequestGetMstFacilitySettingData(facilityCd).then(response => {
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
    // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc start
    getDoctorsAtFacilityIncludeDel(context, facilityCd) {
      return sendRequestGetDoctorsAtFacilityIncludeDel(facilityCd);
    },
    // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc end
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
    },
    // 選択施設のシステム利用設定を設定
    setFacilitySysUseSetting({ commit }, facilitySysUseSetting) {
      commit("setFacilitySysUseSetting", facilitySysUseSetting);
    }
  },
  getters: {
    getFacilityList(state) {
      return state.facilityList;
    },
    getFilteredMasterRecordList(state, getters, rootState) {
      const NIKKISO = "1";
      // データ件数が0件の場合、そのまま返却
      if (
        !state.masterRecordList.data ||
        state.masterRecordList.data.length === 0
      )
        return state.masterRecordList;

      // データ件数が1件以上の場合、条件を適用
      let returnData = state.masterRecordList.data;

      // 操作権限可否の確認。makerSetting=2の場合、user_typeの設定内容に関わらず、非表示とする
      returnData = returnData.filter(e => e.makerSetting !== 2);
      // 条件に機能名や設定名が設定されている場合は名前で抽出
      if (state.condition.recordName != "") {
        returnData = returnData.filter(
          e => e.settingName && e.settingName.indexOf(state.condition.recordName) !== -1 ||
          e.functionName && e.functionName.indexOf(state.condition.recordName) !== -1 ||
          e.dispValue && e.dispValue.includes(state.condition.recordName) ||
          e.description && e.description.includes(state.condition.recordName)
        );
      }
      // 日機装ユーザ以外は設定可能項目に制約をかける
      if(state.userType != NIKKISO){
        returnData = returnData.filter(
          e => e.makerSetting === 0
        );
      }

      returnData = returnData.filter(item => {
        switch(state.facilitySysUseSetting) {
          case SYS_USE_TYPE.REMS_ONLY :
            // ReMSの場合、システム利用表示区分が1:ReMS,3:共通の項目のみ表示
            return SYS_USE_DISP.REMS_ONLY.some(type => type === item.systemUseDisp)
          case SYS_USE_TYPE.FNSI_ONLY :
            // FNSiの場合、システム利用表示区分が2:FNSi,3:共通の項目のみ表示
            return SYS_USE_DISP.FNSI_ONLY.some(type => type === item.systemUseDisp)
          case SYS_USE_TYPE.REMS_AND_FNSI :
            // ReMS+FNSiの場合、システム利用表示区分が1:ReMS,2:FNSi,3:共通の項目を表示
            return SYS_USE_DISP.REMS_AND_FNSI.some(type => type === item.systemUseDisp)
          default:
            return false;
        }
      });

      // #11987 2026.01.05 add スケールベッド機能が無効な場合、スケールベッドの設定項目を非表示にする TDC伊東 start
      // スケールベッド機能が有効な場合のみスケールベッドの設定項目を表示
      // useFunctionはrootState.facility.useFunctionに格納されている
      const useFunction = rootState?.facility?.useFunction || [];
      if (!useFunction.includes(FUNC_SCALE_BED)) {
        returnData = returnData.filter(e => e.functionName !== "スケールベッド");
      }
      // #11987 2026.01.05 add スケールベッド機能が無効な場合、スケールベッドの設定項目を非表示にする TDC伊東 end

      return {
        schema: state.masterRecordList.schema,
        data: returnData
      };
    },
    getMasterRecordList(state) {
      return state.masterRecordList;
    },
    getEditRecord(state) {
      return state.editRecord;
    },
    getUpdateRecordList(state){
      return state.masterRecordList.data;
    },
    getValueSignIn(state){
      return state.valueSignIn;
    }
  }
};
