// 印字設定用データ
const presetPrintItemList = [
  {
    cd: 0,
    category: [true, true, true, true],
    item_name: "（空行）",
    data_type: 2,
    print_format: "　",
    default_format: "",
    default_before_word: "",
    default_after_word: ""
  },
  {
    cd: 1,
    category: [true, true, true, true],
    item_name: "現在日時",
    data_type: 1,
    print_format: "@data",
    default_format: "YYYY/MM/DD HH:mm:ss",
    default_before_word: "",
    default_after_word: ""
  },
  {
    cd: 2,
    category: [true, true, true, false],
    item_name: "ベッド名",
    data_type: 2,
    print_format: "ベッド名: @data",
    default_format: "xxxxx",
    default_before_word: "ベッド名:",
    default_after_word: ""
  },
  {
    cd: 3,
    category: [true, true, true, false],
    item_name: "患者ID",
    data_type: 2,
    print_format: "ID: @data",
    default_format: "xxxxxxxxxxxx",
    default_before_word: "ID:",
    default_after_word: ""
  },
  {
    cd: 4,
    category: [true, true, true, false],
    item_name: "患者名",
    data_type: 2,
    print_format: "@data 様",
    default_format: "xxxxxxxxxx",
    default_before_word: "",
    default_after_word: " 様"
  },
  {
    cd: 5,
    category: [true, true, false, false],
    item_name: "透析時間",
    data_type: 1,
    print_format: "透析時間:@data",
    default_format: "HH:mm",
    default_before_word: "透析時間:",
    default_after_word: ""
  },
  {
    cd: 6,
    category: [true, true, true, false],
    item_name: "DW",
    data_type: 0,
    print_format: "DW: @data kg",
    default_format: "3.2",
    default_before_word: "DW:",
    default_after_word: "kg"
  },
  {
    cd: 7,
    category: [true, true, false, false],
    item_name: "目標体重",
    data_type: 0,
    print_format: "目標体重: @data kg",
    default_format: "3.2",
    default_before_word: "目標体重:",
    default_after_word: "kg"
  },
  {
    cd: 8,
    category: [true, true, true, true],
    item_name: "測定値",
    data_type: 0,
    print_format: "測定値: @data kg",
    default_format: "3.2",
    default_before_word: "測定値:",
    default_after_word: "kg"
  },
  {
    cd: 9,
    category: [true, true, true, false],
    item_name: "透析【前】体重",
    data_type: 0,
    print_format: "【前】体重: @data kg",
    default_format: "3.2",
    default_before_word: "【前】体重:",
    default_after_word: "kg"
  },
  {
    cd: 10,
    category: [false, true, false, false],
    item_name: "透析【後】体重",
    data_type: 0,
    print_format: "【後】体重: @data kg",
    default_format: "3.2",
    default_before_word: "【後】体重:",
    default_after_word: "kg"
  },
  {
    cd: 11,
    category: [true, true, true, false],
    item_name: "前回透析【後】体重",
    data_type: 0,
    print_format: "前回【後】: @data kg",
    default_format: "3.2",
    default_before_word: "前回【後】:",
    default_after_word: "kg"
  },
  {
    cd: 12,
    category: [true, true, true, false],
    item_name: "透析【前】/DW",
    data_type: 0,
    print_format: "【前】体重/DW: @data kg",
    default_format: "3.2",
    default_before_word: "【前】体重/DW:",
    // mode #9920 体重計マスタの印字タブの項目を正しくに修正 蔡 start
    // default_after_word: "kg"
    default_after_word: "%"
    // mode #9920 体重計マスタの印字タブの項目を正しくに修正 蔡 end
  },
  {
    cd: 13,
    category: [false, true, false, false],
    item_name: "透析【後】/DW",
    data_type: 0,
    print_format: "【後】体重/DW: @data kg",
    default_format: "3.2",
    default_before_word: "【後】体重/DW:",
    // mode #9920 体重計マスタの印字タブの項目を正しくに修正 蔡 start
    // default_after_word: "kg"
    default_after_word: "%"
    // mode #9920 体重計マスタの印字タブの項目を正しくに修正 蔡 end
  },
  {
    cd: 14,
    category: [true, true, true, false],
    item_name: "体重増減",
    data_type: 0,
    print_format: "体重増減: @data kg",
    default_format: "3.2",
    default_before_word: "体重増減:",
    default_after_word: "kg"
  },
  {
    cd: 15,
    category: [false, true, true, false],
    item_name: "体重前後差",
    data_type: 0,
    print_format: "体重前後差: @data kg",
    default_format: "3.2",
    default_before_word: "体重前後差:",
    default_after_word: "kg"
  },
  {
    cd: 16,
    category: [true, true, false, false],
    item_name: "除水目標値",
    data_type: 0,
    print_format: "除水目標: @data kg",
    default_format: "3.2",
    default_before_word: "除水目標:",
    default_after_word: "kg"
  },
  {
    cd: 17,
    category: [true, true, false, false],
    item_name: "除水制限",
    data_type: 0,
    print_format: "除水制限: @data kg",
    default_format: "3.2",
    default_before_word: "除水制限:",
    default_after_word: "L"
  },
  {
    cd: 18,
    category: [true, true, false, false],
    item_name: "引き残し",
    data_type: 0,
    print_format: "引き残し: @data kg",
    default_format: "3.2",
    default_before_word: "引き残し:",
    default_after_word: "kg"
  },
  {
    cd: 19,
    category: [true, true, true, false],
    item_name: "風袋補正値",
    data_type: 0,
    print_format: "風袋補正: @data kg",
    default_format: "3.2",
    default_before_word: "風袋補正:",
    default_after_word: "kg"
  },
  {
    cd: 20,
    category: [true, true, true, false],
    item_name: "除水補正値",
    data_type: 0,
    print_format: "除水補正: @data kg",
    default_format: "3.2",
    default_before_word: "除水補正:",
    default_after_word: "kg"
  },
  {
    cd: 21,
    category: [true, true, true, false],
    item_name: "DWから",
    data_type: 0,
    print_format: "DWから: @data kg",
    default_format: "3.2",
    default_before_word: "DWから:",
    default_after_word: "kg"
  },
  {
    cd: 22,
    category: [true, true, true, false],
    item_name: "DWから割合",
    data_type: 0,
    print_format: "DWから: @data %",
    default_format: "3.2",
    default_before_word: "DWから:",
    default_after_word: "%"
  },
  {
    cd: 23,
    category: [true, true, false, false],
    item_name: "目標体重から",
    data_type: 0,
    print_format: "目標体重から: @data kg",
    default_format: "3.2",
    default_before_word: "目標体重から:",
    default_after_word: "kg"
  },
  {
    cd: 24,
    category: [true, true, false, false],
    item_name: "目標体重から割合",
    data_type: 0,
    print_format: "目標体重から: @data %",
    default_format: "3.2",
    default_before_word: "目標体重から:",
    default_after_word: "%"
  },
  {
    cd: 25,
    category: [true, true, true, false],
    item_name: "前回から",
    data_type: 0,
    print_format: "前回から: @data kg",
    default_format: "3.2",
    default_before_word: "前回から:",
    default_after_word: "kg"
  },
  {
    cd: 26,
    category: [true, true, true, false],
    item_name: "前回から割合",
    data_type: 0,
    print_format: "前回から: @data %",
    default_format: "3.2",
    default_before_word: "前回から:",
    default_after_word: "%"
  },
  {
    cd: 27,
    category: [true, true, true, false],
    item_name: "BMI",
    data_type: 0,
    print_format: "BMI: @data kg/m2",
    default_format: "3.1",
    default_before_word: "BMI:",
    default_after_word: "kg/m2"
  },
  {
    cd: 28,
    category: [true, true, true, true],
    item_name: "フリーテキスト",
    data_type: 2,
    print_format: "",
    default_format: "",
    default_before_word: "",
    default_after_word: ""
  },
  {
    cd: 29,
    category: [true, true, true, true],
    item_name: "罫線",
    data_type: 2,
    print_format: "",
    default_format: "",
    default_before_word: "-------------------",
    default_after_word: ""
  },
  {
    cd: 30,
    category: [true, true, true, false],
    item_name: "バーコード（NW-7）",
    data_type: 2,
    print_format: "@data",
    default_format: "バーコード（NW-7）",
    default_before_word: "",
    default_after_word: ""
  },
  {
    cd: 31,
    category: [true, true, true, false],
    item_name: "バーコード（JAN13）",
    data_type: 2,
    print_format: "@data",
    default_format: "バーコード（JAN13）",
    default_before_word: "",
    default_after_word: ""
  },
  {
    cd: 32,
    category: [true, true, true, false],
    item_name: "次回予定日",
    data_type: 1,
    print_format: "次回予定: @data",
    default_format: "MM/DD HH:mm",
    default_before_word: "次回予定:",
    default_after_word: ""
  },
  {
    cd: 33,
    category: [true, true, true, true],
    item_name: "施設名称",
    data_type: 2,
    print_format: "@data",
    default_format: "xxxxxxxx",
    default_before_word: "",
    default_after_word: ""
  },
  {
    cd: 34,
    category: [true, true, true, true],
    item_name: "用紙カット",
    data_type: 2,
    print_format: "＜用紙カットする＞",
    default_format: "",
    default_before_word: "",
    default_after_word: ""
  }
];

const itemList2 = [
  {
    cd: 0,
    category: [true, true, true, true],
    item_name: "検査項目1",
    data_type: 2,
    print_format: "　",
    default_format: "",
    default_before_word: "",
    default_after_word: ""
  },
  {
    cd: 1,
    category: [true, true, true, true],
    item_name: "検査項目2",
    data_type: 1,
    print_format: "@data",
    default_format: "YYYY/MM/DD HH:mm:ss",
    default_before_word: "",
    default_after_word: ""
  },
  {
    cd: 2,
    category: [true, true, true, true],
    item_name: "検査項目3",
    data_type: 3,
    print_format: "@data",
    default_format: "YYYY/MM/DD HH:mm:ss",
    default_before_word: "",
    default_after_word: ""
  }
];

const categoryIdx = {
  before: 0,
  after: 1,
  no_schedule: 2,
  no_pat: 3
};

import { deepCopy } from "@/functions/common/CommonFunctions";
import {sendRequestGetMstExamItem, sendRequestGetMstExamItemByFacilityCd} from "@/apis/mst-weight-maintenance";

export default {
  strict: !import.meta.env.PROD,
  namespaced: true,
  state: {
    // -----------------------------------------
    // 印字設定用
    // -----------------------------------------
    // 選択中の印字設定番号[1:前体重, 2:後体重, 3:スケジュールなし, 4:患者未登録]
    selectTabIndex: 1,
    // 印字設定の項目リスト
    itemList: [itemList2],
    // 前体重用設定
    settingDataBefore: [],
    // 後体重用設定
    settingDataAfter: [],
    // スケジュールなし患者用設定
    settingDataNoSchedule: [],
    // 重量測定用設定
    settingDataNoPat: [],
    // 現在設定
    currentData: [],
    // 現在行設定
    currentRowData: {},
    // 検査マスタ
    examItemList: []
  },
  getters: {
    getCategoryIndex: () => categoryIdx,
    getSelectedIndex: state => state.selectTabIndex,
    getCurrentData: state => state.currentData,
    getCurrentRowData: state => state.currentRowData,
    getPresetPrintItemListAll: () => presetPrintItemList,
    getPresetPrintItemList: () => idx => {
      let list = deepCopy(presetPrintItemList);
      return list.filter(el => el.category[idx]);
    },
    getPresetPrintItem: () => cd => {
      let list = deepCopy(presetPrintItemList);
      return list.find(el => el.cd === cd);
    },
    getExamItemList: state => state.examItemList
  },
  actions: {
    setSettingData({ commit }, jsonData) {
      // 設定JSONデータをstateにセット
      commit("setSettingDataBefore", jsonData.before);
      commit("setSettingDataAfter", jsonData.after);
      commit("setSettingDataNoSchedule", jsonData.no_schedule);
      commit("settingDataNoPat", jsonData.no_pat);
    },
    changeCurrentData({ getters, state, commit }, selectedId) {
      let buf = getters.getCurrentData;
      switch (selectedId) {
        case 0:
          buf = state.settingDataBefore;
          break;
        case 1:
          buf = state.settingDataAfter;
          break;
        case 2:
          buf = state.settingDataNoSchedule;
          break;
        case 3:
          buf = state.settingDataNoPat;
          break;
      }
      commit("setCurrentSettingData", buf);
      commit("setTabSelectedId", selectedId);
    },
    setCurrentData({ getters, commit }, jsonData) {
      commit("setCurrentSettingData", jsonData);
      const selectedId = getters.getSelectedIndex;
      switch (selectedId) {
        case 0:
          commit("setSettingDataBefore", jsonData);
          break;
        case 1:
          commit("setSettingDataAfter", jsonData);
          break;
        case 2:
          commit("setSettingDataNoSchedule", jsonData);
          break;
        case 3:
          commit("settingDataNoPat", jsonData);
          break;
      }
    },
    remountCurrentData({ getters, commit }) {
      const buf = getters.getCurrentData;
      commit("setCurrentSettingData", buf);
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
    applyEditingRow({ getters, commit, state }) {
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

      const selectedId = getters.getSelectedIndex;
      let buf = getters.getCurrentData;
      switch (selectedId) {
        case 0:
          buf = state.settingDataBefore;
          break;
        case 1:
          buf = state.settingDataAfter;
          break;
        case 2:
          buf = state.settingDataNoSchedule;
          break;
        case 3:
          buf = state.settingDataNoPat;
          break;
      }
      let editRow = state.currentRowData;
      if (editRow.ctl_no == -1) {
        // 新規行
        editRow.ctl_no = getMaxId(buf);
        editRow.disp_order = getMaxDispNo(buf);
        commit("addRowToSettingData", editRow);
      } else {
        // 更新
        const idx = buf.findIndex(r => r.ctl_no === editRow.ctl_no);
        commit("spliceRowToSettingData", { idx: idx, row: editRow });
      }
      commit("setCurrentRowData", null);
    },
    fetchExamItemList() {
      return sendRequestGetMstExamItem();
    },
    // add マスタ一覧 1･施設切替を可能とする 孔s start
    fetchExamItemListByFacilityCd(tmp, facilityCd) {
      return sendRequestGetMstExamItemByFacilityCd(facilityCd);
    },
    // add マスタ一覧 1･施設切替を可能とする 孔s end
    setExamItemList({ commit }, examItemList) {
      let examSource = [];
      if (examItemList) {
        for (const exam of examItemList) {
          examSource.push({
            cd: exam.cd,
            category: [true, true, true, false],
            item_name: exam.name,
            data_type: 3,
            print_format: "YYYY/MM/DD",
            default_format: "YYYY/MM/DD",
            default_before_word: exam.name + ":",
            default_after_word: exam.unit,
            date_position: 0
          });
        }
      }
      commit("setExamItemList", examSource);
    }
  },
  mutations: {
    setTabSelectedId(state, id) {
      state.selectTabIndex = id;
    },
    setExamItemList(state, list) {
      state.examItemList = list;
    },
    setSettingDataBefore(state, jsonArrayData) {
      state.settingDataBefore = jsonArrayData;
    },
    setSettingDataAfter(state, jsonArrayData) {
      state.settingDataAfter = jsonArrayData;
    },
    setSettingDataNoSchedule(state, jsonArrayData) {
      state.settingDataNoSchedule = jsonArrayData;
    },
    settingDataNoPat(state, jsonArrayData) {
      state.settingDataNoPat = jsonArrayData;
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
    clearSettingData(state) {
      state.currentRowData = null;
      state.settingDataCheck = [];
      state.currentData = [];
    }
  }
};
