const defaultColumns = [
  {
    field: "disp_order",
    title: "表示順",
    hidden: false,
    editable: () => true,
    values: null,
    //#9411: 体重計マスタ＞詳細＞測定値チェックの列幅修正 Start
    //width: "100px"
    width: "90px"
    //#9411: 体重計マスタ＞詳細＞測定値チェックの列幅修正 End
  },
  {
    field: "ctl_no",
    title: "ctl_no",
    hidden: true,
    editable: () => false,
    values: null,
    width: "60px"
  },
  {
    field: "is_disable",
    title: "チェック<br>動作",
    hidden: false,
    editable: () => true,
    values: [{ value: "0", text: "有効" }, { value: "1", text: "無効" }],
    width: "110px"
  },
  {
    field: "name",
    title: "タイトル",
    hidden: false,
    editable: () => false,
    values: null,
    //#9411: 体重計マスタ＞詳細＞測定値チェックの列幅修正 Start
    //width: "100px"
    width: "220px"
    //#9411: 体重計マスタ＞詳細＞測定値チェックの列幅修正 End
  },
  {
    field: "modal",
    title: "詳細",
    hidden: false,
    editable: () => false,
    values: null,
    //#9411: 詳細ボタンが狭幅で縦に積まれる／重複見えを避けるために幅を確保
    width: "104px"
  },
  {
    field: "before_word",
    title: "前表示文字",
    hidden: false,
    editable: () => false,
    values: null,
    //#9411: 体重計マスタ＞詳細＞測定値チェックの列幅修正 Start
    //width: "100px"
    width: "220px"
    //#9411: 体重計マスタ＞詳細＞測定値チェックの列幅修正 End
  },
  {
    field: "calculate",
    title: "計算式",
    hidden: false,
    editable: () => false,
    values: null,
    //#9411: 体重計マスタ＞詳細＞測定値チェックの列幅修正 Start
    //width: "100px"
    width: "220px"
    //#9411: 体重計マスタ＞詳細＞測定値チェックの列幅修正 End
  },
  {
    field: "after_word",
    title: "後表示文字",
    hidden: false,
    editable: () => false,
    values: null,
    width: "100px"
  },
  {
    field: "decimal_point",
    title: "小数点",
    hidden: false,
    editable: () => false,
    values: null,
    width: "100px"
  },
  {
    field: "use_condition",
    title: "表示条件",
    hidden: false,
    editable: () => false,
    values: [
      { value: 0, text: "常に表示" },
      { value: 1, text: "満たす場合に表示" },
      { value: 2, text: "満たさない場合に表示" }
    ],
    //#9411: 体重計マスタ＞詳細＞測定値チェックの列幅修正 Start
    //width: "100px"
    width: "180px"
    //#9411: 体重計マスタ＞詳細＞測定値チェックの列幅修正 End
  },
  {
    field: "condition_left",
    title: "条件左辺",
    hidden: false,
    editable: () => false,
    values: null,
    //#9411: 体重計マスタ＞詳細＞測定値チェックの列幅修正 Start
    //width: "100px"
    width: "220px"
    //#9411: 体重計マスタ＞詳細＞測定値チェックの列幅修正 End
  },
  {
    field: "condition_ineq",
    title: "条件<br>比較式",
    hidden: false,
    editable: () => false,
    values: [
      { value: null, text: "" },
      { value: 0, text: "＞" },
      { value: 1, text: "≧" },
      { value: 2, text: "＝" },
      { value: 3, text: "≠" },
      { value: 4, text: "≦" },
      { value: 5, text: "＜" }
    ],
    width: "100px"
  },
  {
    field: "condition_right",
    title: "条件右辺",
    hidden: false,
    editable: () => false,
    values: null,
    width: "100px"
  },
  {
    field: "is_check_warn",
    title: "正常範囲<br>チェック",
    hidden: false,
    editable: () => false,
    values: [{ value: false, text: "しない" }, { value: true, text: "する" }],
    width: "100px"
  },
  {
    field: "min_warn",
    title: "最小<br>警告値",
    hidden: false,
    editable: () => false,
    values: null,
    width: "100px"
  },
  {
    field: "max_warn",
    title: "最大<br>警告値",
    hidden: false,
    editable: () => false,
    values: null,
    width: "100px"
  },
  {
    field: "is_disp_before",
    title: "前体重<br>画面表示",
    hidden: false,
    editable: () => false,
    values: [{ value: false, text: "なし" }, { value: true, text: "あり" }],
    width: "100px"
  },
  {
    field: "is_disp_after",
    title: "後体重<br>画面表示",
    hidden: false,
    editable: () => false,
    values: [{ value: false, text: "なし" }, { value: true, text: "あり" }],
    width: "100px"
  },
  {
    field: "sendable",
    title: "条件送信制限",
    hidden: false,
    editable: () => false,
    values: [
      { value: 0, text: "制限なし" },
      { value: 1, text: "正常範囲外確認チェック" },
      { value: 2, text: "正常範囲外送信不可" },
      { value: 3, text: "表示時確認チェック" },
      { value: 4, text: "表示時送信不可" }
    ],
    //#9411: 体重計マスタ＞詳細＞測定値チェックの列幅修正 Start
    //width: "120px"
    width: "180px"
    //#9411: 体重計マスタ＞詳細＞測定値チェックの列幅修正 End
  },
  {
    field: "is_print[0]",
    title: "前体重<br>印刷",
    hidden: false,
    editable: () => false,
    values: [
      { value: false, text: "印刷しない" },
      { value: true, text: "印刷する" }
    ],
    width: "100px"
  },
  {
    field: "is_print[1]",
    title: "後体重<br>印刷",
    hidden: false,
    editable: () => false,
    values: [
      { value: false, text: "印刷しない" },
      { value: true, text: "印刷する" }
    ],
    width: "100px"
  },
  {
    field: "is_print[2]",
    title: "スケジュールなし<br>印刷",
    hidden: false,
    editable: () => false,
    values: [
      { value: false, text: "印刷しない" },
      { value: true, text: "印刷する" }
    ],
    width: "150px"
  },
  {
    field: "is_print[3]",
    title: "患者未登録<br>印刷",
    hidden: false,
    editable: () => false,
    values: [
      { value: false, text: "印刷しない" },
      { value: true, text: "印刷する" }
    ],
    width: "100px"
  },
  {
    field: "print_datatype",
    title: "印字時の<br>データタイプ",
    hidden: true,
    editable: () => false,
    values: [
      { value: 0, text: "数値" },
      { value: 1, text: "日付" },
      { value: 2, text: "テキスト" }
    ],
    width: "100px"
  },
  {
    field: "print_default_format",
    title: "印字時の初期<br>フォーマット",
    hidden: true,
    editable: () => false,
    values: null,
    width: "120px"
  },
  {
    field: "delBtn",
    title: "　",
    hidden: false,
    editable: () => false,
    values: null,
    width: "70px"
  }
];

const defaultSettings = {
  ctl_no: -1,
  disp_order: -1,
  is_disable: "0",
  name: "",
  is_print: [false, false, false, false],
  max_warn: 0,
  min_warn: 0,
  sendable: 0,
  calculate: "",
  after_word: "",
  before_word: "",
  decimal_point: 2,
  is_check_warn: false,
  is_disp_before: false,
  is_disp_after: false,
  use_condition: 0,
  condition_ineq: 0,
  condition_left: "",
  print_datatype: 2,
  condition_right: "",
  print_default_format: ""
};

import { deepCopy } from "@/functions/common/CommonFunctions";

export default {
  strict: !import.meta.env.PROD,
  namespaced: true,
  state: {
    columns: defaultColumns,
    settingDataCheck: [],
    currentData: [],
    currentRowData: {}
  },
  getters: {
    getColumns: state => state.columns,
    getSettingDataCheck: state => state.settingDataCheck,
    getCurrentData: state => state.currentData,
    getCurrentRowData: state => state.currentRowData
  },
  actions: {
    setSettingData({ commit }, jsonData) {
      // 設定済みの値に存在しないキーがある場合は初期値をセット
      for (const checkJson of jsonData.check) {
        for (const key of Object.keys(defaultSettings)) {
          if (checkJson[key] === undefined) {
            checkJson[key] = defaultSettings[key];
          }
        }
      }
      // 装置設定JSONデータをstateにセット
      commit("setSettingDataCheck", jsonData.check);
    },
    setCurrentData({ commit }, jsonData) {
      commit("setCurrentSettingData", jsonData);
      commit("setSettingDataCheck", jsonData);
    },
    setCurrentRowData({ commit }, jsonData) {
      commit("setCurrentRowData", jsonData);
    },
    setCurrentNewRowData({ commit }) {
      commit("setCurrentNewRowData");
    },
    clearData({ commit }) {
      commit("clearSettingData");
    },
    applyEditingRow({ commit, state }) {
      // 編集中の行データを反映
      // idの最大値を返す
      const getMaxId = settings => {
        let maxId = 0;

        if (settings !== null) {
          // 測定値チェック設定情報一覧から
          for (const row of settings) {
            if (row.ctl_no > maxId) {
              maxId = row.ctl_no;
            }
          }
          maxId++;
        }
        return maxId;
      };
      // disp_order の最大値を返す
      const getMaxDispNo = settings => {
        let maxNo = 0;

        if (settings !== null) {
          // 測定値チェック設定情報一覧から
          for (const row of settings) {
            if (row.disp_order > maxNo) {
              maxNo = row.disp_order;
            }
          }
          maxNo++;
        }
        return maxNo;
      };

      let editRow = state.currentRowData;
      if (editRow.ctl_no == -1) {
        // 新規行
        editRow.ctl_no = getMaxId(state.settingDataCheck);
        editRow.disp_order = getMaxDispNo(state.settingDataCheck);
        commit("addRowToSettingData", editRow);
      } else {
        // 更新
        const idx = state.settingDataCheck.findIndex(
          r => r.ctl_no === editRow.ctl_no
        );
        commit("spliceRowToSettingData", { idx: idx, row: editRow });
      }
      commit("setCurrentRowData", null);
    }
  },
  mutations: {
    setSettingDataCheck(state, jsonArrayData) {
      state.settingDataCheck = jsonArrayData;
    },
    addRowToSettingData(state, jsonData) {
      state.settingDataCheck.push(jsonData);
    },
    spliceRowToSettingData(state, payload) {
      state.settingDataCheck.splice(payload.idx, 1, payload.row);
    },
    setCurrentSettingData(state, jsonArrayData) {
      state.currentData = jsonArrayData;
    },
    setCurrentRowData(state, jsonData) {
      state.currentRowData = jsonData;
    },
    setCurrentNewRowData(state) {
      state.currentRowData = deepCopy(defaultSettings);
    },
    clearSettingData(state) {
      state.currentRowData = null;
      state.settingDataCheck = [];
      state.currentData = [];
    }
  }
};
