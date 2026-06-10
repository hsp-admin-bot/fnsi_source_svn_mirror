/**
 * 観察記録詳細用ストア
 */
import {
  sendRequestGetObserveRecord,
  sendRequestPostObserveRecord,
  sendRequestPutObserveRecord,
  sendRequestGetOrdMainRecordList
} from "@/apis/observe-record";

export default {
  strict: true,
  namespaced: true,
  state: {
    updateMode: false,
    /**
     * 選択中データ
     */
    selectedData: {
      patObsRec: null,
      bbs: null // テーブル名を知らない、仮称。
    },
    dummyPatObsRec: {
      obsRecNo: null,
      patId: null,
      facilityCd: null,
      upCnt: null,
      kindInfo: null,
      regStaffInfo: null,
      upStaffInfo: null,
      obsRecInfo: null,
      bbsCtlNo: null,
      ordNo: null,
      isNewest: false,
      isDel: false,
      fnSeqId: null,
      regDate: "",
      upDate: ""
    },
    dummyBBS: {
      bbsCode: "hogera"
    },
    comboOrdMain: null,
    refreshCondition: null
  },
  mutations: {
    /**
     * 選択データを変更
     */
    setSelectedData(state, { patObsRec, bbs }) {
      state.updateMode = true;
      state.selectedData.patObsRec = patObsRec;
      state.selectedData.bbs = bbs;
    },
    clearSelectedData(state) {
      state.updateMode = false;
      state.selectedData.patObsRec = null;
      state.selectedData.bbs = null;
    },
    setRefreshCondition(state, refreshCondition) {
      state.refreshCondition = refreshCondition;
    },
    clearComboOrdMain(state) {
      state.comboOrdMain = null;
    },
    setComboOrdMain(state, ordMain) {
      state.comboOrdMain = ordMain;
    },
    /*add FNSI-改修内容redmain #6003 周 start*/
    /* 日付、予定・実績、クール、ベッドの順で表示する */
    sortComboOrdMain(state) {
      state.comboOrdMain.sort(function(a,b){
        return (a.rstDialysisState === null || a.rstDialysisState === 0) 
        ? ((b.rstDialysisState === null || b.rstDialysisState === 0) ? (a.indBedCd - b.indBedCd) : (a.indBedCd - b.rstBedCd)) 
        : ((b.rstDialysisState === null || b.rstDialysisState === 0) ? (a.rstBedCd - b.indBedCd) : (a.rstBedCd - b.rstBedCd))
      });
      state.comboOrdMain.sort(function(a,b){
        return (a.rstDialysisState === null || a.rstDialysisState === 0) 
        ? ((b.rstDialysisState === null || b.rstDialysisState === 0) ? (a.indKurCd - b.indKurCd) : (a.indKurCd - b.rstKurCd)) 
        : ((b.rstDialysisState === null || b.rstDialysisState === 0) ? (a.rstKurCd - b.indKurCd) : (a.rstKurCd - b.rstKurCd))
      });
      state.comboOrdMain.sort(function(a,b){
        return a.rstDialysisState - b.rstDialysisState
      });
      state.comboOrdMain.sort(function(a,b){
        return a.viewTreatDate === null 
        ? (b.viewTreatDate === null ? (a.treatDate.localeCompare(b.treatDate)) : (a.treatDate.slice(0,4).concat("/").concat(a.treatDate.slice(4,6)).concat("/").concat(a.treatDate.slice(6)).localeCompare(b.viewTreatDate))) 
        : (b.viewTreatDate === null ? (a.viewTreatDate.localeCompare(b.treatDate.slice(0,4).concat("/").concat(b.treatDate.slice(4,6)).concat("/").concat(b.treatDate.slice(6)))) : (a.viewTreatDate.localeCompare(b.viewTreatDate)))
        });
    },
    /*add FNSI-改修内容redmain #6003 周 end*/
    setComboOrdMainByOrdNo(state, ordMain) {
      for (const record of ordMain) {
        const foundData = state.comboOrdMain.find(
          dataSrc => dataSrc.ordNo === record.ordNo
        );
        if (!foundData) {
          state.comboOrdMain.push(record);
        }
      }
    }
  },
  actions: {
    /**
     *
     */
    setRefreshCondition({ commit }, refreshCondition) {
      commit("setRefreshCondition", refreshCondition);
    },
    /**
     * データ取得
     */
    async getData({ commit, dispatch }, { patId, obsRecNo }) {
      const patObsRec = await dispatch("getPatObsRec", { patId, obsRecNo });
      const dt = new Date(patObsRec.recDate);
      if (patObsRec.isNewest === "1" && patObsRec.isDel !== "1") {
        commit("setSelectedData", { patObsRec, bbs: null });
        // console.log(patObsRec.recDate);
        await dispatch("fetchOrdMain", {
          patId: patObsRec.patId,
          treatDate: `${dt.getFullYear()}${(
            "00" + (dt.getMonth() + 1).toString()
          ).slice(-2)}${("00" + dt.getDate().toString()).slice(-2)}`,
          ordNo: patObsRec.ordNo
        });
      }
    },
    resetSelectedData({ commit }) {
      commit("clearSelectedData");
    },
    /**
     * 観察記録データの新規登録
     */
    async insertPatObsRec(context, dat) {
      await sendRequestPostObserveRecord(dat);
    },
    /**
     * 掲示板データの新規登録
     */
    async insertBBS(dat) {
      // TODO:掲示板データの新規登録を実装する
      // eslint-disable-next-line no-console
      console.log(`insertBBS:${dat}`);
    },
    async deletePatObsRec({ dispatch, state }) {
      //  変更前データの取得
      const patObsRec = await dispatch("getPatObsRec", {
        patId: state.selectedData.patObsRec.patId,
        obsRecNo: state.selectedData.patObsRec.obsRecNo
      });

      if (patObsRec === null || patObsRec === undefined) {
        // 比較用のデータが返らない
        return -1;
      } else if (patObsRec.isNewest === "1" && patObsRec.isDel !== "1") {
        // データに変更が無い
        state.selectedData.patObsRec.isDel = "1";
        await sendRequestPutObserveRecord(
          state.selectedData.patObsRec.obsRecNo,
          state.selectedData.patObsRec
        );
        return 0;
      } else {
        // データが変更されている
        return -2;
      }
    },
    /**
     * 観察記録データの更新登録
     */
    async updatePatObsRec({ state, dispatch }, dat) {
      //  同データの取得
      //  upDateの比較
      //    手元のデータとupDateが異なれば更新を中止する
      //    手元のデータを同じであれば更新を行う
      let result = -1;
      const patObsRec = await dispatch("getPatObsRec", {
        patId: state.selectedData.patObsRec.patId,
        obsRecNo: state.selectedData.patObsRec.obsRecNo
      });
      if (patObsRec === null || patObsRec === undefined) {
        result = -1;
      } else if (patObsRec.isNewest === "1" && patObsRec.isDel !== "1") {
        state.selectedData.patObsRec.isNewest = "0";
        await sendRequestPutObserveRecord(
          state.selectedData.patObsRec.obsRecNo,
          state.selectedData.patObsRec
        );
        await dispatch("insertPatObsRec", dat);
        result = 0;
      } else {
        result = -2;
      }
      return result;
    },
    /**
     * 掲示板データの更新登録
     */
    async updateBBS(dat) {
      // TODO:掲示板データの更新登録を実装する
      // eslint-disable-next-line no-console
      console.log(`updateBBS:${dat}`);
    },
    /**
     * 観察記録データの取得
     */
    async getPatObsRec(context, { patId, obsRecNo }) {
      const param = { patId, obsRecNo };
      const response = await sendRequestGetObserveRecord(param);
      if (response.data[0] !== null) {
        // iPadでこの書式の時差が未対応なので変更
        response.data[0].recDate = response.data[0].recDate.replace(
          "+0000",
          "Z"
        );
        return response.data[0];
      }
      return null;
    },
    /**
     * 掲示板データの取得
     */
    async getBBS({ state }) {
      // TODO:掲示板データの取得を実装する
      return state.dummyBBS;
    },
    /**
     * 患者別当日治療情報の取得
     * @param {*} param
     */
    async fetchOrdMain({ commit }, { patId, treatDate, ordNo }) {
      await commit("clearComboOrdMain");
      const response1 = await sendRequestGetOrdMainRecordList({
        patId,
        treatDate,
        ordNo: null
      });
      if (response1.data[0] !== null) {
        await commit("setComboOrdMain", response1.data);
      }
      const response2 = await sendRequestGetOrdMainRecordList({
        patId: null,
        treatDate: null,
        ordNo
      });
      if (response2.data[0] !== null) {
        await commit("setComboOrdMainByOrdNo", response2.data);
      }
      /*add FNSI-改修内容redmain #6003 周 start*/
      await commit("sortComboOrdMain");
      /*add FNSI-改修内容redmain #6003 周 end*/
    }
  },
  getters: {
    getObserveRecords(state) {
      return state.observeRecords;
    },
    getUpdatemode(state) {
      return state.updateMode;
    },
    getSelectedData(state) {
      return state.selectedData;
    },
    getRefreshCondition(state) {
      return state.refreshCondition;
    },
    getComboOrdMain(state) {
      return state.comboOrdMain;
    }
  }
};
