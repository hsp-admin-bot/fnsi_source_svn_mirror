const defaultSettings = {
  ctl_no: -1,
  disp_order: -1,
  item_name: "",
  item_bed_cd: 0,
  item_ip: "000.000.000.000",
  item_port: 0,
};

import { sendRequestGetMstBedByFacilityCd } from "@/apis/mst-weight-maintenance";

export default {
  strict: process.env.NODE_ENV !== "production",
  namespaced: true,
  state: {
    // セッティングデータ
    ScaleBedSettingData: [],
    // 現在設定
    currentData: [],
    // 現在行設定
    currentRowData: {},
    // ベッドマスタ
    bedList: [],
  },
  getters: {
    getScaleBedSettingData: (state) => state.ScaleBedSettingData,
    getCurrentData: (state) => state.currentData,
    getCurrentRowData: (state) => state.currentRowData,
    getBedList: (state) => state.bedList,
  },
  actions: {
    /**
     * @param {{ctl_no: number, disp_order: number, item_name: string, item_bed_cd: number, item_ip: string, item_port: number}[]} jsonData
     */
    setScaleBedSettingData({ commit }, jsonData) {
      // 設定済みの値に存在しないキーがある場合は初期値をセット
      for (const scaleBedJson of jsonData) {
        for (const key of Object.keys(defaultSettings)) {
          if (scaleBedJson[key] === undefined) {
            scaleBedJson[key] = defaultSettings[key];
          }
        }
      }
      // 装置設定JSONデータをstateにセット
      commit("setScaleBedSettingDataSet", jsonData);
    },
    setCurrentData({ commit }, jsonData) {
      commit("setCurrentSettingData", jsonData);
      commit("setScaleBedSettingDataSet", jsonData);
    },
    remountCurrentData({ getters, commit }) {
      const buf = getters.getCurrentData;
      commit("setCurrentSettingData", buf);
    },
    setCurrentRowData({ commit }, jsonData) {
      commit("setCurrentRowData", jsonData);
    },
    clearData({ commit }) {
      commit("clearSettingData");
    },
    applyEditingRow({ getters, commit, state }) {
      // 編集中の行データを反映
      // idの最大値を返す
      const getMaxId = (settings) => {
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
      const getMaxDispNo = (settings) => {
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

      let buf = getters.getCurrentData;
      buf = state.ScaleBedSettingData;

      let editRow = state.currentRowData;
      if (editRow.ctl_no == -1) {
        // 新規行
        editRow.ctl_no = getMaxId(buf);
        editRow.disp_order = getMaxDispNo(buf);
        commit("addRowToSettingData", editRow);
      } else {
        // 更新
        const idx = buf.findIndex((r) => r.ctl_no === editRow.ctl_no);
        commit("spliceRowToSettingData", { idx: idx, row: editRow });
      }
      commit("setCurrentRowData", null);
    },

    fetchBedItemListByFacilityCd(tmp, facilityCd) {
      return sendRequestGetMstBedByFacilityCd(facilityCd);
    },
    setBedList({ commit }, BedList) {
      let bedSource = [];
      if (BedList) {
        for (const bed of BedList) {
          if (bed.isDel === "0" && bed.isDisp === "1") {
            bedSource.push({
              item_bed_cd: bed.code,
              item_name: bed.name,
            });
          }
        }
        commit("setBedItemList", bedSource);
      }
    },
  },
  mutations: {
    setBedItemList(state, list) {
      state.bedList = list;
    },

    setScaleBedSettingDataSet(state, jsonArrayData) {
      state.ScaleBedSettingData = jsonArrayData;
    },
    addRowToSettingData(state, jsonData) {
      state.ScaleBedSettingData.push(jsonData);
    },
    spliceRowToSettingData(state, payload) {
      state.ScaleBedSettingData.splice(payload.idx, 1, payload.row);
    },
    setCurrentSettingData(state, jsonArrayData) {
      state.currentData = jsonArrayData;
    },
    setCurrentRowData(state, jsonData) {
      state.currentRowData = jsonData;
    },
    clearSettingData(state) {
      state.currentRowData = null;
      state.ScaleBedSettingData = [];
      state.currentData = [];
    },
  },
};
