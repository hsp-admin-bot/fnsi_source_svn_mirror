/**
 * 治療状況レイアウトマスタメンテナンスStore.
 */
import { sendRequestGetDispItemList } from "@/apis/status-list";

export default {
  strict: true,
  namespaced: true,
  state: {
    settingDataDcs: [],
    settingDataDab: [],
    settingDataDad: [],
    settingDataDro: [],
    // 装置ごとのコンボボックス選択項目リスト
    comboItems: {
      DCS: [],
      DAB: [],
      DAD: [],
      DRO: []
    },
    currentData: [],
    tabSelectedId: 1,
    kendoGridHeight: 300,
    columns: [
      {
        field: "order_no",
        title: "表示順",
        hidden: false,
        editable: () => true,
        values: null,
        width: 80
      },
      {
        field: "title",
        title: "表示名",
        hidden: false,
        editable: () => true,
        values: null,
        width: 190
      },
      {
        field: "data_class",
        title: "表示項目",
        hidden: false,
        editable: () => true,
        values: [{ value: 1, text: "a" }, { value: 2, text: "b" }],
        width: 200
      },
      {
        field: "width",
        title: "列幅",
        hidden: false,
        editable: () => true,
        values: null,
        width: 100
      },
      {
        field: "delBtn",
        title: "　",
        hidden: false,
        editable: () => false,
        values: null,
        width: 70
      },
      {
        field: "table_name",
        title: "テーブル名",
        hidden: true,
        editable: () => true,
        values: null
      },
      {
        field: "column_name",
        title: "フィールド名",
        hidden: true,
        editable: () => true,
        values: null
      },
      {
        field: "key_name",
        title: "JSONキー名",
        hidden: true,
        editable: () => true,
        values: null
      },
      {
        field: "data_class",
        title: "データ種別",
        hidden: true,
        editable: () => true,
        values: null
      }
    ]
  },
  mutations: {
    setSettingDataDcs(state, jsonData) {
      state.settingDataDcs = jsonData;
    },
    setSettingDataDab(state, jsonData) {
      state.settingDataDab = jsonData;
    },
    setSettingDataDad(state, jsonData) {
      state.settingDataDad = jsonData;
    },
    setSettingDataDro(state, jsonData) {
      state.settingDataDro = jsonData;
    },
    setCurrentSettingData(state, jsonData) {
      state.currentData = jsonData;
    },
    setTabSelectedId(state, index) {
      state.tabSelectedId = index;
    },
    setComboItemList(state, itemList) {
      state.comboItems = itemList;
    },
    setComboColumnValues(state, itemList) {
      const columns = state.columns;
      columns.forEach(column => {
        if (column.field == "data_class") {
          column.values = itemList;
        }
      });
      // state.columns["data_class"].values = itemList;
    },
    clearSettingData(state) {
      state.settingDataDcs = [];
      state.settingDataDab = [];
      state.settingDataDad = [];
      state.settingDataDro = [];
      state.currentData = [];
    }
  },
  actions: {
    fetchDispItemList() {
      return sendRequestGetDispItemList();
    },
    setColumnDispItemList({ commit }, itemList) {
      commit("setComboColumnValues", itemList);
    },
    setSettingData({ commit }, jsonData) {
      // 装置設定JSONデータをstateにセット
      commit("setSettingDataDcs", jsonData.dcs);
      commit("setSettingDataDab", jsonData.dab);
      commit("setSettingDataDad", jsonData.dad);
      commit("setSettingDataDro", jsonData.dro);
    },
    changeCurrentData({ getters, state, commit }, selectedId) {
      let buf = getters.getCurrentData;
      let bufItemList = [];
      switch (selectedId) {
        case 1:
          buf = state.settingDataDcs;
          bufItemList = state.comboItems.DCS;
          break;
        case 2:
          buf = state.settingDataDab;
          bufItemList = state.comboItems.DAB;
          break;
        case 3:
          buf = state.settingDataDad;
          bufItemList = state.comboItems.DAD;
          break;
        case 4:
          buf = state.settingDataDro;
          bufItemList = state.comboItems.DRO;
          break;
      }
      commit("setCurrentSettingData", buf);
      commit("setComboColumnValues", bufItemList);
      commit("setTabSelectedId", selectedId);
    },
    setCurrentData({ getters, commit }, jsonData) {
      commit("setCurrentSettingData", jsonData);
      const selectedId = getters.getSelectedIndex;
      switch (selectedId) {
        case 1:
          commit("setSettingDataDcs", jsonData);
          break;
        case 2:
          commit("setSettingDataDab", jsonData);
          break;
        case 3:
          commit("setSettingDataDad", jsonData);
          break;
        case 4:
          commit("setSettingDataDro", jsonData);
          break;
      }
    },
    setComboItemList_Act({ commit }, itemList) {
      commit("setComboItemList", itemList);
    },
    remountCurrentData({ getters, commit }) {
      const buf = getters.getCurrentData;
      commit("setCurrentSettingData", buf);
    },
    deleteRow() {
      console.lod("store no deleteRow");
    },
    clearData({ commit }) {
      commit("clearSettingData");
    }
  },
  getters: {
    getSettingDataDcs: state => state.settingDataDcs,
    getSettingDataDab: state => state.settingDataDab,
    getSettingDataDad: state => state.settingDataDad,
    getSettingDataDro: state => state.settingDataDro,
    getCurrentData: state => state.currentData,
    getTabSelectedId: state => state.tabSelectedId,
    getColumns: state => state.columns,
    getSelectedIndex: state => state.tabSelectedId
  }
};
