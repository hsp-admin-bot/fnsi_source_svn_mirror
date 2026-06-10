/**
 * マスタメンテナンスStore.
 */
import {
  sendRequestFindMasterList,
  sendRequestFindRecordList,
  sendRequestFindRecordListByFacilityCd,
  sendRequestFindRecordListByFacilityCdWithSql,
  sendRequestFindColumnInfo,
  sendRequestUpdateRecordList,
  sendRequestUpdateRecordListByFacilityCd
  ,sendequestUpdateIndCondInfoByTreatmentCd
} from "@/apis/master-maintenance";
import {
  sendRequestGetMstFacilitySettingValue
} from "@/apis/facility-setting";
import {
  sendRequestMstDeviceEdgeNo,
  sendRequestMstExamItemSync,
  sendRequestMstDeviceEdgeNoByFacilityCd
} from "@/apis/device-edge-order";
import Vue from "vue";
import {
  sendRequestGetMstFacility
} from "@/apis/mst-user-maintenance";
import { deepCopy } from "@/functions/common/CommonFunctions";
import {EventBus} from "@/eventBus";
import moment from "moment";
/**
 * 該当レコードを検索し、追加かつ編集済(operation=1&&edited=true)、
 * または、編集済み(operation=2)であればtrueを返す.
 *
 * @param {Array} list マスタの全レコード
 * @param {Integer} code チェック対象のコード
 * @return {Boolean} 編集中の場合にはtrueを返す.
 */
function isEdited(list, code) {

  let index = list && list.findIndex(e => {
    return e.code == code;
  });
  if (!list) return false;
  const r = list[index];
  return (
    index > -1 && ((r.operation === 1 && r.edited) || r.operation === 2)
  );
}

export default {
  strict: true,
  namespaced: true,
  state: {
    // マスタ一覧 施設切替
    facilitySwitch:"",
    // 施設リスト
    facilityList: [],
    scrollToTop : 0,
    // 検索に入力したマスタ名
    searchMasterName: "",
    // 選択されたマスタ
    selectedMasterName: "",
    // 選択されたマスタ名
    selectedLogicalMasterName: "",
    // マスタレコード
    masterRecordList: [],
    // 修正済み判定用情報
    comparisonRecordModel: "",
    // ヘッダ検索条件
    condition: {
      recordName: "",
      includeDeleted: false
    },
    // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 start
    virtualCondition: {
      value: "",
      fields: [],
      includeDeleted: false
    },
    // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 end
    // 編集中のレコード
    editRecord: {},
    // スキーマ情報
    schema: {},
    // カラム情報
    columns: [],
    // カラム定義情報（sys_master_defineのcolumn_infoの情報）
    columnInfo: [],
    // 患者情報共有解除する施設コードリスト
    cancelFacilityCd: [],
    searchName:"",
    // mod 障害票一覧_ログイン画面 修正 xie start
    userCondition: [{
      "userId": "",
      "methodName": ""
    }],
    // mod 障害票一覧_ログイン画面 修正 xie end
    // add #6217 全施設マスタ画面が遅い guanhao start
    initFlag: false,
    // add #6217 全施設マスタ画面が遅い guanhao end
    gridData: [],
    schemaModel: {},
    mstFavoriteFacilityAddRows: [],
    // #9976 マスタ画面で保存を行うとスクロール位置が先頭になる start
    // 縦スクロール位置
    scrollTopPosition: 0,
    // 横クロール位置
    scrollLeftPosition: 0,
    // #9976 マスタ画面で保存を行うとスクロール位置が先頭になる end
  },
  mutations: {
    // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 start
    setMstFavoriteFacilityAddRows(state, mstFavoriteFacilityAddRows) {
      state.mstFavoriteFacilityAddRows = mstFavoriteFacilityAddRows;
    },
    setGridData(state, gridData) {
      state.gridData = gridData;
    },
    setSchemaModel(state, schemaModel) {
      state.schemaModel = schemaModel;
    },
    setVirtualCondition(state, virtualCondition) {
      state.virtualCondition = virtualCondition;
    },
    resetVirtualCondition(state) {
      state.virtualCondition = {
        value: "",
        fields: [],
        includeDeleted: false
      };
    },
    // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 end
    // add #6217 全施設マスタ画面が遅い guanhao start
    setInitFlag(state, initFlag) {
      state.initFlag = initFlag;
    },
    // add #6217 全施設マスタ画面が遅い guanhao end
    // マスタ一覧 施設切替
    setFacilitySwitch(state, facilitySwitch) {
      state.facilitySwitch = facilitySwitch;
    },
    // 施設情報を設定
    setFacilityList(state, facilityList) {
      state.facilityList = facilityList;
    },
    setScrollToTop(state, scrollToTop) {
      state.scrollToTop = scrollToTop;
    },
    // #9976 マスタ画面で保存を行うとスクロール位置が先頭になる start
    setScrollTopPosition(state, scrollTopPosition) {
      state.scrollTopPosition = scrollTopPosition;
    },
    setScrollLeftPosition(state, scrollLeftPosition) {
      state.scrollLeftPosition = scrollLeftPosition;
    },
    // #9976 マスタ画面で保存を行うとスクロール位置が先頭になる end
    setSearchMasterName(state, searchMasterName) {
      state.searchMasterName = searchMasterName;
    },
    // mod 障害票一覧_ログイン画面 修正 xie start
    setUserCondition(state, userCondition) {
      state.userCondition = userCondition;
    },
    // mod 障害票一覧_ログイン画面 修正 xie end
    setMasterName(state, selectedMasterName) {
      state.selectedMasterName = selectedMasterName;
    },
    setSearchName(state, searchName) {
      state.searchName = searchName;
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
      let index
      index = state.masterRecordList.data.findIndex(e => {
        return e.code === editRecord.code;
      });
      if (index < 0) {
        if (
          state.selectedMasterName === "mst_device_edge" ||
          state.selectedMasterName === "mst_facility"
          // del start 鞠 全施設マスタの並び順4490
          // state.selectedMasterName === "sys_facility"
          // del end 鞠 全施設マスタの並び順4490
        ) {
          // デバイスエッジマスタと施設マスタと全施設マスタはcodeが文字列であり採番できない
          editRecord.code = `new_record_${state.masterRecordList.data.length}`;
        } else {
          // 該当レコードがなければ追加
          // 行番号を最大値＋１で自動採番
          const maxCode = state.masterRecordList.data.reduce(
            (a, b) => (a > +b.code ? a : +b.code),
            0
          );
          if(!(state.selectedMasterName == "mst_holiday" && editRecord.code)) {
            editRecord.code = maxCode + 1;
          }
        }
        // operation = 1:追加、2:編集
        if(!editInfo.isHolidayNkk){
          editRecord.operation = 1;
        }
        // add マスタ一覧 新規項目欄についてはフィルタの対象外とするよう変更願います 孔 start
        editRecord.skipSearch = true
        // add マスタ一覧 新規項目欄についてはフィルタの対象外とするよう変更願います 孔 end
        state.masterRecordList.data.push(editRecord);
        if(
          state.selectedMasterName == "mst_holiday" &&
          ((editInfo.isHolidayNkk || !editRecord.year) || isNaN(editRecord.regDate)) &&
          editRecord.class =="0"
        ) {
          if (isNaN(editRecord.regDate)) {
            editRecord.holiday = "";
            editRecord.facilityCd = "";
            editRecord.regDate = "";
            editRecord.upDate = "";
          }
          let newEditRecord = deepCopy(editRecord);
          newEditRecord.code = editRecord.code +1;
          newEditRecord.class = "1";
          newEditRecord.isDisp = "1";
          editRecord.isDisp = "1";
          state.masterRecordList.data.push(newEditRecord);
          let newMasterRecordList = state.masterRecordList;
          state.masterRecordList = null;
          state.masterRecordList = newMasterRecordList;
        }
      } else {
        // 該当レコードがあれば編集内容を反映
        if (editRecord.operation != 1 && !isSortMode) {
          editRecord.operation = 2;
        }
        if (isSortMode) {
          editRecord.sortInputTime = Date.now();
        }
        Vue.set(state.masterRecordList.data, index, editRecord);
      }
    },
    setCondition(state, condition) {
      state.condition = condition;
      // add #6217 全施設マスタ画面が遅い guanhao start
      if (state.selectedMasterName == 'sys_facility' && condition.recordName != '') {
        state.initFlag = true;
        EventBus.$emit("sysFacilityDataPage", condition.recordName);
      } else if (state.selectedMasterName == 'sys_facility' && state.initFlag) {
        state.initFlag = false;
        EventBus.$emit("loadGridData");
      }else {
      // add #6217 全施設マスタ画面が遅い guanhao end
        // add マスタ一覧 新規項目欄についてはフィルタの対象外とするよう変更願います 孔 start
        if (state.masterRecordList.data) state.masterRecordList.data.filter(p => "skipSearch" in p).forEach(p => delete p.skipSearch)
        // add マスタ一覧 新規項目欄についてはフィルタの対象外とするよう変更願います 孔 end
      }
    },
    setSchema(state, schema) {
      state.schema = schema;
    },
    setColumns(state, columns) {
      state.columns = columns;
    },
    setColumnInfo(state, columnInfo) {
      state.columnInfo = columnInfo;
    },
    setEditRecord(state, editRecord) {
      state.editRecord = editRecord;
    },
    setisPreservation(state, isPreservation) {
      state.isPreservation = isPreservation;
    },
    clearComparisonRecordModel(state) {
      state.comparisonRecordModel = "[]";
    },
    setComparisonRecordModel(state) {
      if (state.selectedMasterName === "mst_alarm_notification") {
        // 警報通知マスタ(mst_alarm_notification)は保持データ対応と競合する為、同マスタの場合は処理をスキップする
        state.comparisonRecordModel = JSON.stringify(state.masterRecordList.data);
        return;
      }
      // add redmine_#3946_編集を行っていない場合でも内容破棄確認モーダルが表示されるを修正 孔 start
      // #9863 TypeError: Cannot read properties of undefined (reading 'model') 横展開2 linjunfeng start
      // const fields = state.masterRecordList.schema.model.fields
      const fields = state.masterRecordList.schema?.model.fields
      // #9863 TypeError: Cannot read properties of undefined (reading 'model') 横展開2 linjunfeng end
      const stringKey = []
      const numberKey = []
      for (const fieldsKey in fields) {
        if (fieldsKey === "name") continue
        if (fieldsKey === "code") continue
        if (fieldsKey === "isDisp") continue
        if (fieldsKey === "isDel") continue
        if (fieldsKey === "sortRank") continue
        if (fieldsKey === "sortInputTime") continue
        if (fields.hasOwnProperty(fieldsKey)) {
          if (fields[fieldsKey].type && fields[fieldsKey].type === "string") stringKey.push(fieldsKey)
          if (fields[fieldsKey].type && fields[fieldsKey].type === "number") numberKey.push(fieldsKey)
        }
      }
      // #9863 Error in callback for watcher "getMasterHashRecordList": "TypeError: Cannot read properties of undefined (reading 'forEach')" 横展開2 linjunfeng start
      // state.masterRecordList.data.forEach(item => {
      state.masterRecordList.data && state.masterRecordList.data.forEach(item => {
      // #9863 TError in callback for watcher "getMasterHashRecordList": "TypeError: Cannot read properties of undefined (reading 'forEach')" 横展開2 linjunfeng end

        stringKey.forEach(key => {
          if (typeof item[key] == "undefined" || item[key] === null) {
            item[key] = null
          } else {
            item[key] = item[key] + ""
          }
        })

        numberKey.forEach(key => {
          if (typeof item[key] == "undefined" || item[key] === "null" || item[key] === null) {
            item[key] = null
          } else {
            item[key] = Number(item[key])
          }
        })

      })
      // add redmine_#3946_編集を行っていない場合でも内容破棄確認モーダルが表示されるを修正 孔 end

      state.comparisonRecordModel = JSON.stringify(state.masterRecordList.data);
    },
    setCancelFacilityCd(state, cancelFacilityCd) {
      state.cancelFacilityCd = cancelFacilityCd;
    },
  },
  actions: {
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
    setFacilitySwitch({ commit }, facilitySwitch) {
      commit("setFacilitySwitch", facilitySwitch);
    },
    // -----------------------------------------
    // マスタ一覧を取得
    // -----------------------------------------
    findMasterList() {
      return sendRequestFindMasterList();
    },
    // -----------------------------------------
    // データ一覧を取得
    // -----------------------------------------
    findRecordList({ commit, state }) {
      // データのカラム数により前のデータ内容が残る場合があるため領域を初期化
      // APIからの読込だけではデータが残る場合があるため事前に初期化
      // 対応方法については検討の余地あり (#2482)
      commit("clearComparisonRecordModel");
      commit("setMasterRecordList", []);
      commit("setSchema", []);
      commit("setColumns", []);
      return sendRequestFindRecordList(state.selectedMasterName).then(
        response => {
          // 警報通知マスタ(mst_alarm_notification)は保持データが大きくなりすぎる為、制限する
          if (state.selectedMasterName === "mst_alarm_notification") {
            let tmpObj = response.data.localDataSource.data;
            let tmpToObj = [];
            tmpObj.forEach(e => {
              tmpToObj.push({
                code: e.code,
                name: e.name,
                destinationFacilityCd: e.destinationFacilityCd,
                isDisp: e.isDisp,
                isDel: e.isDel,
                sortInputTime: e.sortInputTime,
                sortRank: e.sortRank
              });
            });
            response.data.localDataSource.data = tmpToObj;
          }
          // add 10378 by kangjie 20240524 start 空列表示と空を空白にする互換性があります
          if (state.selectedMasterName === "mst_facility") {
            response.data.localDataSource.data.forEach(item => {
              if (item.isSchextException == null || item.isSchextException == "") {
                item.isSchextException = '0';
              }
            });
          }
          // add 10378 by kangjie 20240524 end
          commit("setMasterRecordList", response.data.localDataSource);
          commit("setSchema", response.data.localDataSource.schema);
          commit("setColumns", response.data.columns);
          return Promise.resolve(response);
        }
      );
    },
    // -----------------------------------------
    // データ一覧を取得（指定施設コードのデータ）
    // -----------------------------------------
    findRecordListByFacilityCd({ commit, state }, facilityCd) {
      // データのカラム数により前のデータ内容が残る場合があるため領域を初期化
      // APIからの読込だけではデータが残る場合があるため事前に初期化
      // 対応方法については検討の余地あり (#2482)
      commit("clearComparisonRecordModel");
      commit("setMasterRecordList", []);
      commit("setSchema", []);
      commit("setColumns", []);
      return sendRequestFindRecordListByFacilityCd(state.selectedMasterName, facilityCd).then(
        response => {
          // 警報通知マスタ(mst_alarm_notification)は保持データが大きくなりすぎる為、制限する
          if (state.selectedMasterName === "mst_alarm_notification") {
            let tmpObj = response.data.localDataSource.data;
            let tmpToObj = [];
            tmpObj.forEach(e => {
              tmpToObj.push({
                code: e.code,
                name: e.name,
                destinationFacilityCd: e.destinationFacilityCd,
                isDisp: e.isDisp,
                isDel: e.isDel,
                sortInputTime: e.sortInputTime,
                sortRank: e.sortRank
              });
            });
            response.data.localDataSource.data = tmpToObj;
          }
          commit("setMasterRecordList", response.data.localDataSource);
          commit("setSchema", response.data.localDataSource.schema);
          commit("setColumns", response.data.columns);
          return Promise.resolve(response);
        }
      );
    },

    // -----------------------------------------
    // データ一覧を取得（SQL指定）
    // -----------------------------------------
    findRecordListByFacilityCdWithSql({ commit, state }, facilityCd) {
      // データのカラム数により前のデータ内容が残る場合があるため領域を初期化
      // APIからの読込だけではデータが残る場合があるため事前に初期化
      // 対応方法については検討の余地あり (#2482)
      commit("setMasterRecordList", []);
      commit("setSchema", []);
      commit("setColumns", []);
      return sendRequestFindRecordListByFacilityCdWithSql(state.selectedMasterName, facilityCd).then(
        response => {
          commit("setMasterRecordList", response.data.localDataSource);
          commit("setSchema", response.data.localDataSource.schema);
          commit("setColumns", response.data.columns);
          return Promise.resolve(response);
        }
      );
    },

    // -----------------------------------------
    // カラム定義情報を取得
    // -----------------------------------------
    findColumnInfo({ commit, state }) {
      return sendRequestFindColumnInfo(state.selectedMasterName).then(
        response => {
          commit("setColumnInfo", response.data);
          return Promise.resolve(response);
        }
      );
    },

    // -----------------------------------------
    // 施設設定マスタ情報を取得
    // -----------------------------------------
    /* eslint-disable no-unused-vars */
    async findFacilitySettingInfo({commit},requestInfo) {
      /* eslint-enable no-unused-vars */
      return sendRequestGetMstFacilitySettingValue(requestInfo.facilityCd,requestInfo.settingNo);
    },
    // -----------------------------------------
    // データ一覧を更新
    // -----------------------------------------
    /* eslint-disable no-unused-vars */
    async updateRecordList({ commit, state }, request) {
      return sendRequestUpdateRecordList(state.selectedMasterName, request);
    },
    async updateRecordListByFacilityCd({ commit, state }, objArgs) {
      // add マスタ一覧 新規項目欄についてはフィルタの対象外とするよう変更願います 孔 start
      if (objArgs.request) objArgs.request.filter(p => "skipSearch" in p).forEach(p => delete p.skipSearch)
      // add マスタ一覧 新規項目欄についてはフィルタの対象外とするよう変更願います 孔 end
      return sendRequestUpdateRecordListByFacilityCd(state.selectedMasterName, objArgs.facilityCd, objArgs.request);
    },
    setScrollToTop({ commit }, scrollToTop) {
      commit("setScrollToTop", scrollToTop);
    },
    setSearchMasterName({ commit }, searchMasterName) {
      commit("setSearchMasterName", searchMasterName);
    },
    // mod 障害票一覧_ログイン画面 修正 xie start
    setUserCondition({ commit }, userCondition) {
      commit("setUserCondition", userCondition);
    },
    // mod 障害票一覧_ログイン画面 修正 xie end
    setMasterName({ commit }, selectedMasterName) {
      commit("setMasterName", selectedMasterName);
    },
    setisPreservation({ commit }, isPreservation) {
      commit("setMasterName", isPreservation);
    },
    setSearchName({ commit }, searchName) {
      commit("setSearchName", searchName);
    },
    setLogicalMasterName({ commit }, selectedLogicalMasterName) {
      commit("setLogicalMasterName", selectedLogicalMasterName);
    },
    setMasterRecordList({ commit }, masterRecordList) {
      commit("setMasterRecordList", masterRecordList);
    },
    edit({ commit }, editInfo) {
      commit("edit", editInfo);
    },
    setCondition({ commit }, condition) {
      commit("setCondition", condition);
    },
    setEditRecord({ commit }, payload) {
      commit("setEditRecord", payload);
    },
    editRecordBeEmpty({ commit }) {
      commit("setEditRecord", {});
    },
    clearComparisonRecordModel({ commit }) {
      commit("clearComparisonRecordModel");
    },
    setComparisonRecordModel({ commit }) {
      commit("setComparisonRecordModel");
    },
    getDeviceEdgeNoList() {
      return sendRequestMstDeviceEdgeNo();
    },
    // ADD 検査項目マスタ-別施設のデバイスエッジとの同期ができなかったと表示される cuifc START
    getMasterDeviceEdgeNoListByFacilityCd(tmp, facilityCd) {
      return sendRequestMstDeviceEdgeNoByFacilityCd(facilityCd);
    },
    // ADD 検査項目マスタ-別施設のデバイスエッジとの同期ができなかったと表示される cuifc END
    /**
     * @param {*} context
     * @param {Object} params
     * @param {String} params.facilityCd
     * @param {number} params.deviceEdgeNo
     */
    mstSyncDeviceEdge(context, params) {
      return sendRequestMstExamItemSync({
        facilityCd: params.facilityCd,
        deviceEdgeNo: params.deviceEdgeNo
      });
    },
    setCancelFacilityCd({ commit }, cancelFacilityCd) {
      commit("setCancelFacilityCd", cancelFacilityCd);
    },
    clearCancelFacilityCd({ commit }) {
      commit("setCancelFacilityCd", []);
    }
    // add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s start
    ,async updateIndCondInfo({ commit , state }, facilityCd) {
      return sendequestUpdateIndCondInfoByTreatmentCd(facilityCd, state.masterRecordList.data);
    },
    // add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s start
    // #9863 unknown local action type: setColumns, global type: master-maintenance/setColumns 横展開2 linjunfeng start
    setColumns({ commit }, columns) {
      commit("setColumns", columns);
    },
    // #9863 unknown local action type: setColumns, global type: master-maintenance/setColumns 横展開2 linjunfeng end
  },
  getters: {
    // add マスタ一覧 1･施設切替を可能とする 孔s start
    getFacilitySwitchAdvancedSettings(state) {
      const facilitySwitchDetail = state.facilityList.find(item => item.facilityCd === state.facilitySwitch)
      const advancedSettings = facilitySwitchDetail.advancedSettings
      if (advancedSettings && advancedSettings.length > 0) {
        const advSettingsObj = JSON.parse(advancedSettings);
        const funcList = advSettingsObj.func_advcds.map(element => {
          return element.func_advcd;
        });
        return funcList
      }
      return []
    },
    getFacilitySwitchUseFunction(state) {
      const facilitySwitchDetail = state.facilityList.find(item => item.facilityCd === state.facilitySwitch)
      const useFunction = facilitySwitchDetail.useFunction
      if (useFunction && useFunction.length > 0) {
        const useFuncObj = JSON.parse(useFunction);
        const funcList = useFuncObj.func_cds.map(element => {
          return element.func_cd;
        });
        return funcList
      }
      return []
    },
    // add #6217 全施設マスタ画面が遅い guanhao start
    getInitflg(state) {
      return state.initFlag;
    },
    // add #6217 全施設マスタ画面が遅い guanhao end
    getFacilitySwitch(state) {
      return state.facilitySwitch;
    },
    // add マスタ一覧 1･施設切替を可能とする 孔s end
    getFacilityList(state) {
      return state.facilityList;
    },
    getScrollToTop(state) {
      return state.scrollToTop;
    },
    // #9976 マスタ画面で保存を行うとスクロール位置が先頭になる start
    getScrollTopPosition(state) {
      return state.scrollTopPosition;
    },
    getScrollLeftPosition(state) {
      return state.scrollLeftPosition;
    },
    // #9976 マスタ画面で保存を行うとスクロール位置が先頭になる end
    getSearchMasterName(state) {
      return state.searchMasterName;
    },
    // mod 障害票一覧_ログイン画面 修正 xie start
    getUserCondition(state) {
      return state.userCondition;
    },
    // mod 障害票一覧_ログイン画面 修正 xie end
    getMasterName(state) {
      return state.selectedMasterName;
    },
    getSearchName(state) {
      return state.searchName;
    },
    getLogicalMasterName(state) {
      return state.selectedLogicalMasterName;
    },
    getFilteredMasterRecordList(state) {
      // データから条件に合致したデータをフィルタリング
      const filterData = function(data, column, param, returnData) {
        if (typeof data[column] !== "undefined") {
          returnData = returnData.filter(e =>
            e[column] !== param || isEdited(returnData, e["code"]));
        }
        return returnData;
      };

      // データ件数が0件の場合、そのまま返却
      if (
        !state.masterRecordList.data ||
        state.masterRecordList.data.length === 0
      )
        return state.masterRecordList;

      // データ件数が1件以上の場合、条件を適用
      let returnData = state.masterRecordList.data;
      // data内にDEL_FLGが存在すれば1のデータを除外
      returnData = filterData(
        state.masterRecordList.data[0],
        "isDel",
        "1",
        returnData
      );
      // 条件にマスタ名が設定されている場合は名前で抽出
      if (state.condition.recordName != "") {
        const parseString = data => (data ? String(data) : "");
        const recordName = parseString(state.condition.recordName);
        const includesRecordName = data =>{
          const res = parseString(data).indexOf(recordName) !== -1;
          return res
        }

        let filterKeys = ["name"];

        switch (state.selectedMasterName) {
          case "mst_addition":
            filterKeys = filterKeys.concat(["additionName", "additionShortName"]);
            break;
          case "mst_device_edge":
            filterKeys = filterKeys.concat(["facilityCd", "facilityName", "serialNo"]);
            break;
          case "mst_self_measure_result":
            filterKeys = ["dispMachineName"];
            break;
          // ADD 日常・定期点検項目マスタ 障害対応183 検索機能が効かない 孔 start
          case "mst_mainte_detail":
            // MOD FNSI-7365 劉全航 start
            // filterKeys = ["mainteContent1","mainteContent2","mainteContent3"];
            filterKeys = ["mainteContent1","mainteContent2","mainteContent3","iniText"];
            // MOD FNSI-7365 劉全航 end
            break;
          // ADD 日常・定期点検項目マスタ 障害対応183 検索機能が効かない 孔 end
          // ADD 日常・定期点検レイアウトマスタ  検索機能が効かない Du start
          case "mst_mainte_layout":
            filterKeys = ["layoutName"];
            break;
          // ADD 日常・定期点検レイアウトマスタ  検索機能が効かない Du end
          // ADD 定期点検機種別レイアウトマスタ 障害対応No206  検索機能が効かない 孔 start
          case "mst_mainte_layout_group":
            filterKeys = ["groupName"];
            break;
          // ADD 定期点検機種別レイアウトマスタ 障害対応No206  検索機能が効かない 孔 end
          case "mst_holiday":
            filterKeys = ["year"];
            break;
          case "sys_medicine":
            filterKeys = ["name"];
            break;
          case "mst_machine": // 装置マスタ
            filterKeys = ["name", "machineSerial", "comFormatCd", "ipAddress", "port", "version"];
            break;
          case "mst_pat_memo": // 患者メモマスタ
            filterKeys = ["code", "name", "content"];
            break;
          case "mst_disease": // 病名マスタ
            filterKeys = ["name", "diseaseShortName", "standardDiseaseCd", 'pDiseaseBiopsyNoneCd', 'pDiseaseBiopsyExistCd', "dieConfirmedDiagnosisNoneCd", "dieConfirmedDiagnosisExistCd", "inHospitalCd1"];
            break;
          case "mst_insurance": // 保険マスタ
            filterKeys = ["name", "insuName"];
            break;
          case "mst_medicine": // 薬剤マスタ
            filterKeys = ["name", "medicineShortName"];
            break;
          case "mst_medicine_mix": // 調整薬剤マスタ
            filterKeys = ["name", "medicineMixShortName"];
            break;
          case "mst_medicine_set": // 薬剤セットマスタ
            filterKeys = ["name", 'medicineSetShortName'];
            break;
          case "mst_dialyzer": // ダイアライザマスタ
            filterKeys = ["name", 'maker', 'functionClass'];
            break;
          case "mst_equipment": // 医療材料マスタ
            filterKeys = ["name", 'equipmentShortName'];
            break;
          case "mst_equipment_set": // 医療材料セットマスタ
            filterKeys = ["name", 'equipmentSetShortName'];
            break;
          case "mst_exam_set": // 検査セットマスタ
            filterKeys = ["name", 'shortname'];
            break;
          case "mst_rad_set": // 一般撮影検査マスタ
            filterKeys = ["name", "radSetAbbName"];
            break;
          case "mst_bbs_kind": // 施設イベントカテゴリマスタ
            filterKeys = ["name", 'defaultTitle', 'defaultContents'];
            break;
        }

        // add 装置通信・仮想端末マスタ 障害対応 No218 start
        let comboFilterKey = "";
        switch (state.selectedMasterName) {
          case "mst_function_report": // 機能帳票マスタ
            comboFilterKey = ["functionCd", "reportCd"];
            break;
          case "mst_comsv_setting":
            comboFilterKey = "deviceEdgeNo";
            break;
        }
        // add 装置通信・仮想端末マスタ 障害対応 No218 end
        // add マスタ障害対応 No189 王 start
          // mod 装置通信・仮想端末マスタ 障害対応 No218 start
          // if (state.selectedMasterName === "mst_function_report"){

        if (comboFilterKey){
          if (state.selectedMasterName === "mst_function_report") {
            const temp = []
            comboFilterKey && comboFilterKey.forEach((item) => {
              // #9863 Cannot read properties of undefined (reading 'find')" 横展開2 linjunfeng start
              // const values = state.columns.find(e => e.field === item).values
              const values = state.columns?.find(e => e.field === item).values
              // #9863 Cannot read properties of undefined (reading 'find')" 横展開2 linjunfeng start
              const filterArr = values && values.filter(
                e => { return includesRecordName(e["text"]) }
              );
              filterArr && temp.push(...filterArr)
            })
            returnData = returnData.filter((item) => {
              return temp.some(t => (t.value === item['functionCd']) || (t.value === item['reportCd']))
            })
          } else {
            const values = state.columns?.find(e => e.field === comboFilterKey).values
            const temp = values && values.filter(
              e => { return includesRecordName(e["text"]) }
            );
            returnData = returnData.filter(
              // mod マスタ一覧 新規項目欄についてはフィルタの対象外とするよう変更願います 孔 start
              // e => temp.find(t => t.value == e.functionCd)
              // e => temp.find(t => t.value == e[comboFilterKey])
              e => temp?.find(t => t.value == e[comboFilterKey]) || e.skipSearch
              // mod マスタ一覧 新規項目欄についてはフィルタの対象外とするよう変更願います 孔 end
            )
            // mod 装置通信・仮想端末マスタ 障害対応 No218 end
          }
        } else {
          const dataList = [];
          for(const column of state.columns){
            if(column.dataType !== undefined){
              if(column.dataType == "combo1" || column.dataType == "combo2"){
                if(column.values){
                  for(const value of column.values){
                    var text = value.text;
                    if(String(text).indexOf(recordName) !== -1){
                      var field = column.field;
                      var val =  value.value;
                      for( const data of state.masterRecordList.data){
                        if(data[field] == val){
                          dataList.push(data);
                        }
                      }
                    }
                  }
                }
              }
            }
          }
          for(const d of dataList){
            var data = returnData?.find(o => o.code == d.code);
            if(!data){
              returnData.push(d);
            }
          }
          returnData = returnData.filter(e => filterKeys.some(key => includesRecordName(e[key])) || e.skipSearch);
        }
        // add マスタ障害対応 No189 王 end

      }
      // 削除を表示が設定されていない場合は非表示を除外
      if (state.condition.includeDeleted == false) {
        returnData = filterData(
          state.masterRecordList.data[0],
          "isDisp",
          "0",
          returnData
        );
      }

      // 必須入力項目のvalidationMessageを登録する
      Object.keys(state.masterRecordList.schema.model.fields).forEach(field => {
        let targetField = state.masterRecordList.schema.model.fields[field];

        if (targetField.validation && targetField.validation.required) {
          const targetColumn = state.columns?.find(e => e.field && e.field === field);
          if (targetColumn && targetColumn.title) {
            targetField.validation.validationMessage = targetColumn.title + "は必須入力です。";
          }
        }
      });

      return {
        schema: state.masterRecordList.schema,
        data: returnData
      };
    },
    getMasterRecordList(state) {
      return state.masterRecordList;
    },
    getComparisonRecordModel(state) {
      return state.comparisonRecordModel;
    },
    getUpdateRecordList(state) {
      // add マスタ一覧 新規項目欄についてはフィルタの対象外とするよう変更願います 孔 start
      if (state.masterRecordList.data) state.masterRecordList.data.filter(p => "skipSearch" in p).forEach(p => delete p.skipSearch)
      // add マスタ一覧 新規項目欄についてはフィルタの対象外とするよう変更願います 孔 end
      // 選択肢マスタを更新するため全件データを返却
      return state.masterRecordList.data;
    },
    isEdited: state => code => {
      return isEdited(state.masterRecordList.data, code);
    },
    hasValueColumn: state => (code, column) => {
      // 該当レコードを検索し、該当カラムがNull・空文字でなければtrueを返す
      // add 病名マスタ 更新できません 孔 start
      if (code === "") return false;
      // add 病名マスタ 更新できません 孔 end
      const index = state.masterRecordList && state.masterRecordList.data && state.masterRecordList.data.findIndex(e => {
        return e.code == code;
      });
      return (
        index > -1 &&
        state.masterRecordList.data[index][column] !== null &&
        state.masterRecordList.data[index][column] !== ""
      );
    },
    getSchema(state) {
      return state.schema;
    },
    getColumns(state) {
      return state.columns;
    },
    getColumnInfo(state) {
      return state.columnInfo;
    },
    getEditRecord(state) {
      return state.editRecord;
    },
    getisPreservation(state) {
      return state.isPreservation;
    },
    isRecordModified(state) {
      // 内部 背景色と保存ボタンの状態が異常です start
      // add error発生を対応する。 dengshen start
      if (!state.comparisonRecordModel){
        return;
      }
      //  add error発生を対応する。 dengshen end
      //mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
      // let arr = state && state.comparisonRecordModel ? JSON.parse(state.comparisonRecordModel) : []
      let comparisonArr = state && state.comparisonRecordModel ? JSON.parse(JSON.stringify(state.comparisonRecordModel)) : [];
      let comparisonData = state.masterRecordList && state.masterRecordList.data && JSON.parse(JSON.stringify(state.masterRecordList.data));
      let arr = JSON.parse(comparisonArr);
      //mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc end
      arr && arr.forEach((item, index) => {
        if (state.masterRecordList.data && Number(state.masterRecordList.data[index]?.wheelChairWeight) == item?.wheelChairWeight) {
          item.wheelChairWeight = state.masterRecordList.data[index].wheelChairWeight
        }
        //add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
        delete item.upDate;
        delete item.operation;
        //add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc end
        // add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231108 ztc start
        delete item.sortInputTime;
        // add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231108 ztc end
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_ベッドグループ・透析室マスタ 20240110 linjunfeng start
        if (state.selectedMasterName == "mst_room_bed_group") {
          item.inHospitalCd1 = item.inHospitalCd1 ? item.inHospitalCd1 : null;
          item.inHospitalCd2 = item.inHospitalCd2 ? item.inHospitalCd2 : null;
          item.inHospitalCd3 = item.inHospitalCd3 ? item.inHospitalCd3 : null;
        }
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_ベッドグループ・透析室マスタ 20240110 linjunfeng end
        // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240110 linjunfeng start
        if (state.selectedMasterName == "mst_treatment") {
          item.inHospAStartdate = moment(item.inHospAStartdate).format("YYYYMMDD");
          item.inHospBStartdate = moment(item.inHospBStartdate).format("YYYYMMDD");
          item.inHospitalCdA1 = item.inHospitalCdA1 ? item.inHospitalCdA1 : null;
          item.inHospitalCdA2 = item.inHospitalCdA2 ? item.inHospitalCdA2 : null;
          item.inHospitalCdA3 = item.inHospitalCdA3 ? item.inHospitalCdA3 : null;
          item.inHospitalCdA4 = item.inHospitalCdA4 ? item.inHospitalCdA4 : null;
          item.inHospitalCdB1 = item.inHospitalCdB1 ? item.inHospitalCdB1 : null;
          item.inHospitalCdB2 = item.inHospitalCdB2 ? item.inHospitalCdB2 : null;
          item.inHospitalCdB3 = item.inHospitalCdB3 ? item.inHospitalCdB3 : null;
          item.inHospitalCdB4 = item.inHospitalCdB4 ? item.inHospitalCdB4 : null;
        }
        // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240110 linjunfeng end
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 20240119 linjunfeng start
        if (state.selectedMasterName == "mst_medicine_set") {
          item.inHospitalCd1 = item.inHospitalCd1 ? item.inHospitalCd1 : null;
          item.inHospitalCd2 = item.inHospitalCd2 ? item.inHospitalCd2 : null;
          item.medicineSetShortName = item.medicineSetShortName ? item.medicineSetShortName : null;
        }
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 20240119 linjunfeng end
        // del #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng start
        if (state.selectedMasterName == "mst_facility") {
          item.cancelDate = moment(item.cancelDate).format("YYYYMMDD");
        }
        // del #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng end

        // 患者イベントサブカテゴリマスタ
        if (state.selectedMasterName == "mst_pat_event_sub_category") {
          if (item.useType == '3' && typeof item.templateCd === 'string' && item.templateCd.startsWith('a')) {
            // 利用種別(useType)が3:紹介状の場合、画面制御用に付与されている文字列"a"を比較前に取り除く
            item.templateCd = item.templateCd.slice(1);
          }
        }
      })
      //mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
      // state.masterRecordList && state.masterRecordList.data && state.masterRecordList.data.forEach((item, index) => {
      comparisonData && comparisonData.forEach((item, index) => {
      //mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
        if (item.operation && arr[index]) {
          // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231108 ztc start
          // arr[index].operation = item.operation
          // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231106 ztc end
          arr[index].scaleUserId = item.scaleUserId
        }
        if (item.scaleDate && arr[index]) {
          arr[index].scaleDate = item.scaleDate
        }
        //del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
        // if (item.scaleDate && arr[index]) {
        //   arr[index].upDate = item.upDate
        // }
        //del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc end
        // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc start
        // if (item.patId && arr[index]) {
        //   arr[index].patId = item.patId
        // }
        // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc end
        //add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
        delete item.upDate;
        delete item.operation;
        //add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc end
        // add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231108 ztc start
        delete item.sortInputTime;
        // add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231108 ztc end
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_ベッドグループ・透析室マスタ 20240110 linjunfeng start
        if (state.selectedMasterName == "mst_room_bed_group") {
          item.inHospitalCd1 = item.inHospitalCd1 ? item.inHospitalCd1 : null;
          item.inHospitalCd2 = item.inHospitalCd2 ? item.inHospitalCd2 : null;
          item.inHospitalCd3 = item.inHospitalCd3 ? item.inHospitalCd3 : null;
        }
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_ベッドグループ・透析室マスタ 20240110 linjunfeng end
        // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240110 linjunfeng start
        if (state.selectedMasterName == "mst_treatment") {
          item.inHospAStartdate = moment(item.inHospAStartdate).format("YYYYMMDD");
          item.inHospBStartdate = moment(item.inHospBStartdate).format("YYYYMMDD");
          item.inHospitalCdA1 = item.inHospitalCdA1 ? item.inHospitalCdA1 : null;
          item.inHospitalCdA2 = item.inHospitalCdA2 ? item.inHospitalCdA2 : null;
          item.inHospitalCdA3 = item.inHospitalCdA3 ? item.inHospitalCdA3 : null;
          item.inHospitalCdA4 = item.inHospitalCdA4 ? item.inHospitalCdA4 : null;
          item.inHospitalCdB1 = item.inHospitalCdB1 ? item.inHospitalCdB1 : null;
          item.inHospitalCdB2 = item.inHospitalCdB2 ? item.inHospitalCdB2 : null;
          item.inHospitalCdB3 = item.inHospitalCdB3 ? item.inHospitalCdB3 : null;
          item.inHospitalCdB4 = item.inHospitalCdB4 ? item.inHospitalCdB4 : null;
        }
        // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法マスタ 20240110 linjunfeng end
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 20240119 linjunfeng start
        if (state.selectedMasterName == "mst_medicine_set") {
          item.inHospitalCd1 = item.inHospitalCd1 ? item.inHospitalCd1 : null;
          item.inHospitalCd2 = item.inHospitalCd2 ? item.inHospitalCd2 : null;
          item.medicineSetShortName = item.medicineSetShortName ? item.medicineSetShortName : null;
        }
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬剤セットマスタ 20240119 linjunfeng end
        // del #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng start
        if (state.selectedMasterName == "mst_facility") {
          item.cancelDate = moment(item.cancelDate).format("YYYYMMDD");
        }
        // del #10438 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる linjunfeng end

        // 患者イベントサブカテゴリマスタ
        if (state.selectedMasterName == "mst_pat_event_sub_category") {
          if (item.useType == '3' && typeof item.templateCd === 'string' && item.templateCd.startsWith('a')) {
            // 利用種別(useType)が3:紹介状の場合、画面制御用に付与されている文字列"a"を比較前に取り除く
            item.templateCd = item.templateCd.slice(1);
          }
        }
      })
      // 内部 背景色と保存ボタンの状態が異常です end

      // ISO8601形式のUTC日時(省略記号'Z'表記)にマッチするパターン (例："2025-08-25T15:00:00Z"、"2025-08-25T15:00:00.000Z")
      const ISO8601_DATETIME_Z_REGEX = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{3})?Z$/;
      /**
       * JSON.stringify用のreplacer
       * 1：日付項目のUTC'Z'表記(UTCの省略記号)を'+00:00'(UTCの数値オフセット表記)に置換し、UTC表記の揺れを吸収する。
       * 2：...(今後差分比較用のJSON.stringifyで置換などの対応が必要になった場合はここに追加して利用してください)
       *
       * @param   key   - 現在処理中のプロパティ名
       * @param   value - 現在処理中の値
       * @returns       - 変換後の値(対象外なら元の値)
       */
      const jsonReplacer = (key, value) => {
        if (typeof value === 'string' && ISO8601_DATETIME_Z_REGEX.test(value)) {
          // 文字列がUTC日時パターンにマッチする場合、末尾の'Z'(UTCの省略記号)を'+00:00'(UTCの数値オフセット表記)に置換
          return value.replace('Z', '+00:00');
        }
        return value;
      };

      // ストアのデータが読み込み時から編集されてないかをチェック
      // 共同マスターBUG修正 Du start
      //mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
      // return JSON.stringify(state.masterRecordList.data) && (
      //   (JSON.stringify(arr)) !==
      //   JSON.stringify(state.masterRecordList.data))
      return JSON.stringify(comparisonData) && (
          (JSON.stringify(arr, jsonReplacer).replace(/\s/g, '')) !==
          JSON.stringify(comparisonData, jsonReplacer).replace(/\s/g, ''))
      //mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc end
      // 共同マスターBUG修正 Du end
    },
    getCancelFacilityCd(state) {
      return state.cancelFacilityCd;
    },
  }
};
