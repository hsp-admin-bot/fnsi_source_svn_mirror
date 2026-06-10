/**
 * 体重計施設マスタメンテナンスStore.
 */
import {
  sendRequestGetMstWeightScaleEdit,
  sendRequestPutMstWeightScaleEdit,
  sendRequestGetMstWeightScaleEditByFacilityCd,
  sendRequestPutMstWeightScaleEditByFacilityCd
} from "@/apis/mst-weight-maintenance";

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
    // 修正済み判定用情報
    comparisonRecordModel: "",
    // ヘッダ検索条件
    condition: {
      recordName: "",
      includeDeleted: false
    },
    // 編集中のレコード
    editRecord: {},
    // スキーマ情報
    schema: {},
    // カラム情報
    columns: []
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
        return e.code === editRecord.code;
      });
      const index = state.masterRecordList.data.indexOf(foundData);

      if (index < 0) {
        if (
          state.selectedMasterName === "mst_device_edge" ||
          state.selectedMasterName === "mst_facility"
        ) {
          // デバイスエッジマスタと施設マスタはcodeが文字列であり採番できない
          editRecord.code = `new_record_${state.masterRecordList.data.length}`;
        } else {
          // 該当レコードがなければ追加
          // 行番号を最大値＋１で自動採番
          const maxCode = state.masterRecordList.data.reduce(
            (a, b) => (a > +b.code ? a : +b.code),
            0
          );
          editRecord.code = maxCode + 1;
        }
        // operation = 1:追加、2:編集
        editRecord.operation = 1;
        state.masterRecordList.data.splice(0, 0, editRecord);
      } else {
        // 該当レコードがあれば編集内容を反映
        if (editRecord.operation != 1 && !isSortMode) {
          editRecord.operation = 2;
        }
        if (isSortMode) {
          editRecord.sortInputTime = Date.now();
        }
        state.masterRecordList.data.splice(index, 1, editRecord);
      }
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
    setEditRecord(state, editRecord) {
      state.editRecord = editRecord;
    },
    setComparisonRecordModel(state) {
      state.comparisonRecordModel = JSON.stringify(state.masterRecordList.data);
    }
  },
  actions: {
    // add マスタ一覧 1･施設切替を可能とする 孔 start
    findRecordListByFacilityCd({ commit }, facilityCd) {
      commit("setMasterRecordList", []);
      commit("setSchema", []);
      commit("setColumns", []);
      return sendRequestGetMstWeightScaleEditByFacilityCd({facilityCd: facilityCd}).then(response => {
        commit("setMasterRecordList", response.data.localDataSource);
        commit("setSchema", response.data.localDataSource.schema);
        commit("setColumns", response.data.columns);
        return Promise.resolve(response);
      });
    },
    // add マスタ一覧 1･施設切替を可能とする 孔 end
    // -----------------------------------------
    // データ一覧を取得
    // -----------------------------------------
    findRecordList({ commit }) {
      commit("setMasterRecordList", []);
      commit("setSchema", []);
      commit("setColumns", []);
      return sendRequestGetMstWeightScaleEdit().then(response => {
        commit("setMasterRecordList", response.data.localDataSource);
        commit("setSchema", response.data.localDataSource.schema);
        commit("setColumns", response.data.columns);
        return Promise.resolve(response);
      });
    },
    // -----------------------------------------
    // データ一覧を更新
    // -----------------------------------------
    async updateRecordList(context, request) {
      return sendRequestPutMstWeightScaleEdit(request);
    },
    // add マスタ一覧 1･施設切替を可能とする 孔 start
    async updateRecordListByFacilityCd(context, params) {
      return sendRequestPutMstWeightScaleEditByFacilityCd(params.request, params.facilityCd);
    },
    // add マスタ一覧 1･施設切替を可能とする 孔 end
    setMasterName({ commit }, selectedMasterName) {
      commit("setMasterName", selectedMasterName);
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
    setComparisonRecordModel({ commit }) {
      commit("setComparisonRecordModel");
    }
  },
  getters: {
    getMasterName(state) {
      return state.selectedMasterName;
    },
    getLogicalMasterName(state) {
      return state.selectedLogicalMasterName;
    },
    getFilteredMasterRecordList(state) {
      // データから条件に合致したデータをフィルタリング
      const filterData = function(data, column, param, returnData) {
        if (typeof data[column] !== "undefined") {
          returnData = returnData.filter(e => e[column] !== param);
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
        returnData = returnData.filter(
          e => e.name.indexOf(state.condition.recordName) !== -1
        );
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
      return {
        schema: state.masterRecordList.schema,
        data: returnData
      };
    },
    getMasterRecordList(state) {
      return state.masterRecordList;
    },
    getUpdateRecordList(state) {
      // 選択肢マスタを更新するため全件データを返却
      return state.masterRecordList.data;
    },
    isEdited: state => code => {
      // 該当レコードを検索し、追加かつ編集済(operation=1&&edited=true)、または、編集済み(operation=2)であればtrueを返す
      const index = state.masterRecordList.data.findIndex(e => {
        return e.code == code;
      });
      const r = state.masterRecordList.data[index];
      return (
        index > -1 && ((r.operation === 1 && r.edited) || r.operation === 2)
      );
    },
    hasValueColumn: state => (code, column) => {
      // 該当レコードを検索し、該当カラムがNull・空文字でなければtrueを返す
      const index = state.masterRecordList.data.findIndex(e => {
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
    getEditRecord(state) {
      return state.editRecord;
    },
    isRecordModified(state) {
      // ストアのデータが読み込み時から編集されてないかをチェック
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240119 linjunfeng start
      const newValue = state.masterRecordList.data ? JSON.parse(JSON.stringify(state.masterRecordList.data)) : [];
      newValue.forEach(element => {
        if(element.operation) delete element.operation;
      });
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240119 linjunfeng end
      return (
        state.comparisonRecordModel !==
        // #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240119 linjunfeng start
        // JSON.stringify(state.masterRecordList.data)
        JSON.stringify(newValue)
        // #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240119 linjunfeng end
      );
    }
  }
};
