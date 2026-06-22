/**
 * 患者イベント詳細Store.
 */
import {
  sendRequestGetOrdMainRecord,
  sendRequestGetOrdMainRecordList,
  sendRequestPostPatEventRecord,
  sendRequestPostPatEventRecordDelete,
  sendRequestPutPatEventBbsCtlNo,
  sendRequestPutPatEventRecord,
  sendRequestPutPatEventResultParams
} from "@/apis/pat-event";
//add #9208 患者イベントの実績リンクでの選択肢が不正 関 start
import { sendRequestGetKur } from "@/apis/status-list";
import { bedSelector } from "@/functions/mst/MstGetters.js";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//add #9208 患者イベントの実績リンクでの選択肢が不正 関 end

const ORD_MAIN_DATE_PATTERN = /^\d{8}$/;

function isValidOrdMainDate(value) {
  return typeof value === "string" && ORD_MAIN_DATE_PATTERN.test(value);
}

export default {
  strict: true,
  namespaced: true,
  state: {
    // 患者イベントレコード
    patEventRecord: null,
    initPatEventRecord: null,
    // 患者イベント予定作成パラメータ
    patPlansParams: {},
    // ビューモード
    viewMode: false,
    comboOrdMain: [],
    /*add FNSI-改修内容患者イベント患者情報共有より改修 任 start*/
    facilityName: null,
    /*add FNSI-改修内容患者イベント患者情報共有より改修 任 end*/
    /*add FNSI-改修内容患者イベント画面で作成された掲示板データのイベント開始、終了日が設定されない。任 start*/
    patEventList: null,
    /*add FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 start*/
    templateShow: false,
    /*add FNSI-改修内容添付ファイル修正 任 start*/
    showFile: true,
    /*add FNSI-改修内容添付ファイル修正 任 end*/
    /*add FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 end*/
    /*add FNSI-改修内容患者イベント画面で作成された掲示板データのイベント開始、終了日が設定されない。任 end*/
    /*add FNSI-改修内容5570 任 start*/
    bbsInfoNew: null,
    /*add FNSI-改修内容5570 任 end*/
    isMainList: false,
    // add 8337 【デグレ】掲示板リンクを含んだ患者イベントの編集→保存ができない 関 start
    isNotificationFlg: null,
    // add 8337 【デグレ】掲示板リンクを含んだ患者イベントの編集→保存ができない 関  end
    // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 start
    skipRoute: false,
    // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 end
    //add #9208 患者イベントの実績リンクでの選択肢が不正 関 start
    mstKurList: [],
    mstBedSelector: [],
    //add #9208 患者イベントの実績リンクでの選択肢が不正 関 end
  },
  mutations: {
    /**
     *  ビューモード
     * @param {*} state
     * @param {*} value
     */
    setViewMode(state, value) {
      state.viewMode = value;
    },
    /*add FNSI-改修内容患者イベント患者情報共有より改修 任 start*/
    setFacilityName(state, value) {
        state.facilityName = value;
    },
    /*add FNSI-改修内容患者イベント患者情報共有より改修 任 end*/
    /**
     *  ビューモード
     * @param {*} state
     * @param {*} value
     */
    setIsMainList(state, value) {
      state.isMainList = value;
    },
    /**
     *  患者イベント予定作成パラメータ
     * @param {*} state
     * @param {*} rec
     */
    setPatPlansParams(state, rec) {
      state.patPlansParams = rec;
    },
    /*add FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 start*/
    setTemplateShow(state, templateShow) {
      state.templateShow = templateShow;
    },
    /*add FNSI-改修内容添付ファイル修正 任 start*/
    setShowFile(state, showFile) {
      state.showFile = showFile;
    },
    /*add FNSI-改修内容添付ファイル修正 任 end*/
    /*add FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 end*/
    /*add FNSI-改修内容患者イベント画面で作成された掲示板データのイベント開始、終了日が設定されない。任 start*/
    setPatEventList(state, rec) {
      state.patEventList = rec;
    },
    /*add FNSI-改修内容患者イベント画面で作成された掲示板データのイベント開始、終了日が設定されない。任 end*/
    /**
     * 患者イベント
     * @param {*} state
     * @param {*} rec
     */
    setPatEventRecord(state, rec) {
      if (rec === null) {
        state.patEventRecord = rec;
      } else {
        state.patEventRecord = rec;
        state.patEventRecord.inputParams = rec.inputParams ? JSON.parse(rec.inputParams) : null;
        state.patEventRecord.resultParams = rec.resultParams ? JSON.parse(rec.resultParams) : null;
        state.patEventRecord.regStaffInfo = rec.regStaffInfo ? JSON.parse(rec.regStaffInfo) : null;
        state.patEventRecord.upStaffInfo = rec.upStaffInfo ? JSON.parse(rec.upStaffInfo) : null;
      }
    },
    setInitPatEventRecord(state, value) {
      state.initPatEventRecord = value;
    },
    /**
     * 患者イベント
     * @param {*} state
     * @param {*} param1
     */
    setPatEventResultParamsUpdate(state, { item, index }) {
      state.patEventRecord.resultParams[index] = item;
      state.patEventRecord.resultParams = [...state.patEventRecord.resultParams];
    },
    /*add FNSI-改修内容5570 任 start*/
    setBbsInfoNew(state, vaue) {
      state.bbsInfoNew = vaue;
    },
    /*add FNSI-改修内容5570 任 end*/
    /*add FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 start*/
    setPatEventInputParams(state,inputParams) {
      state.patEventRecord.inputParams = inputParams ? JSON.parse(inputParams) : null;
    },
    /*add FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 end*/
    clearComboOrdMain(state) {
      state.comboOrdMain = null;
    },
    setComboOrdMain(state, ordMain) {
      state.comboOrdMain = ordMain;
    },
    /*add FNSI-改修内容redmain #6003 周 start*/
    /* 日付、予定・実績、クール、ベッドの順で表示する */
    sortComboOrdMain(state) {
      // add FNSi5791患者イベントが２件に分かれて患者カレンダーに表示される 周 start
      if(undefined !== state && null !== state && undefined !== state.comboOrdMain && null !== state.comboOrdMain && state.comboOrdMain.length > 1) {
      //mod #9208 患者イベントの実績リンクでの選択肢が不正 関 start
      // add FNSi5791患者イベントが２件に分かれて患者カレンダーに表示される 周 end
      // state.comboOrdMain.sort(function(a,b){
      //   return (a.rstDialysisState === null || a.rstDialysisState === 0)
      //   ? ((b.rstDialysisState === null || b.rstDialysisState === 0) ? (a.indBedCd - b.indBedCd) : (a.indBedCd - b.rstBedCd))
      //   : ((b.rstDialysisState === null || b.rstDialysisState === 0) ? (a.rstBedCd - b.indBedCd) : (a.rstBedCd - b.rstBedCd))
      // });
      // state.comboOrdMain.sort(function(a,b){
      //   return (a.rstDialysisState === null || a.rstDialysisState === 0)
      //   ? ((b.rstDialysisState === null || b.rstDialysisState === 0) ? (a.indKurCd - b.indKurCd) : (a.indKurCd - b.rstKurCd))
      //   : ((b.rstDialysisState === null || b.rstDialysisState === 0) ? (a.rstKurCd - b.indKurCd) : (a.rstKurCd - b.rstKurCd))
      // });
      // state.comboOrdMain.sort(function(a,b){
      //   return a.rstDialysisState - b.rstDialysisState
      // });
      // state.comboOrdMain.sort(function(a,b){
      //   return a.viewTreatDate === null
      //   ? (b.viewTreatDate === null ? (a.treatDate.localeCompare(b.treatDate)) : (a.treatDate.slice(0,4).concat("/").concat(a.treatDate.slice(4,6)).concat("/").concat(a.treatDate.slice(6)).localeCompare(b.viewTreatDate)))
      //   : (b.viewTreatDate === null ? (a.viewTreatDate.localeCompare(b.treatDate.slice(0,4).concat("/").concat(b.treatDate.slice(4,6)).concat("/").concat(b.treatDate.slice(6)))) : (a.viewTreatDate.localeCompare(b.viewTreatDate)))
      //   });
      // add FNSi5791患者イベントが２件に分かれて患者カレンダーに表示される 周 start
      state.comboOrdMain.sort(function(a,b){
        let aDate = "";
        let bDate = "";
        if (a.treatDate) {
          aDate = a.treatDate.slice(0,4).concat("/").concat(a.treatDate.slice(4,6)).concat("/").concat(a.treatDate.slice(6));
        }
        if (b.treatDate) {
          bDate = b.treatDate.slice(0,4).concat("/").concat(b.treatDate.slice(4,6)).concat("/").concat(b.treatDate.slice(6));
        }
        if (aDate !== bDate) {
          return aDate.localeCompare(bDate);
        }
        let aKurCd;
        let bKurCd;
        let aBedCd;
        let bBedCd;
        if (a.rstDialysisState === "0") {
          aKurCd = a.indKurCd
          aBedCd = a.indBedCd
        } else {
          aKurCd = a.rstKurCd
          aBedCd = a.rstBedCd
        }
        if (b.rstDialysisState === "0") {
          bKurCd = b.indKurCd
          bBedCd = b.indBedCd
        } else {
          bKurCd = b.rstKurCd
          bBedCd = b.rstBedCd
        }
        if (aKurCd !== bKurCd) {
          if (state.mstKurList != null && state.mstKurList != undefined && state.mstKurList.length > 0) {
            const sorted = state.mstKurList.sort((a, b) => new Date(a.kurStandardStartTime) - new Date(b.kurStandardStartTime));
            const kurList = sorted.map(item => (item.kurCd));
            for (let i = 0; i < kurList.length - 1; i++) {
              if (kurList[i] == aKurCd) {
                return -1
              }
              if (kurList[i] == bKurCd) {
                return 1
              }
            }
          }
        }

        if (aBedCd !== bBedCd) {
          if (state.mstBedSelector != null && state.mstBedSelector != undefined && state.mstBedSelector.length > 0) {
            const bedList = state.mstBedSelector.map(item => (item.code));
            for (let i = 0; i < bedList.length - 1; i++) {
              if (bedList[i] == aBedCd) {
                return -1
              }
              if (bedList[i] == bBedCd) {
                return 1
              }
            }
          }
        }
        return 0
        });
        //mod #9208 患者イベントの実績リンクでの選択肢が不正 関 end
      }
      // add FNSi5791患者イベントが２件に分かれて患者カレンダーに表示される 周 end
    },
    /*add FNSI-改修内容redmain #6003 周 end*/
    setComboOrdMainByOrdNo(state, ordMain) {
      if(undefined !== state.comboOrdMain && null !== state.comboOrdMain){
        for (const record of ordMain) {
          if(state.comboOrdMain.length > 0 ) {
            const foundData = state.comboOrdMain.find(
              dataSrc => dataSrc.ordNo === record.ordNo
            );
            if (!foundData) {
              state.comboOrdMain.push(record);
            }
          }
        }
      }else{
        state.comboOrdMain = ordMain;
      }
    },
    // add 8337 【デグレ】掲示板リンクを含んだ患者イベントの編集→保存ができない 関 start
    setIsNotificationFlg(state, value) {
      state.isNotificationFlg = value;
    },
    // add 8337 【デグレ】掲示板リンクを含んだ患者イベントの編集→保存ができない 関  end
    // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 start
    setSkipRoute(state, value) {
      state.skipRoute = value;
    },
    // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 end
    //add #9208 患者イベントの実績リンクでの選択肢が不正 関 start
    setMstKurList(state, value) {
      state.mstKurList = value;
    },
    setMstBedSelector(state, value) {
      state.mstBedSelector = value;
    },
    //add #9208 患者イベントの実績リンクでの選択肢が不正 関 end
  },
  actions: {
    /**
     * ビューモード
     * @param {*} param0
     * @param {*} rec
     */
    async setViewMode({ commit }, value) {
      commit("setViewMode", value);
    },
    /*add FNSI-改修内容患者イベント患者情報共有より改修 任 start*/
    async setFacilityName({ commit }, value) {
      commit("setFacilityName", value);
    },
    /*add FNSI-改修内容患者イベント患者情報共有より改修 任 end*/
    /**
     * リストパネル開閉モード
     * @param {*} param0
     * @param {*} rec
     */
    async setIsMainList({ commit }, value) {
      commit("setIsMainList", value);
    },
    /**
     * 患者イベント
     * @param {*} param0
     * @param {*} rec
     */
    async setPatPlansParams({ commit }, rec) {
      commit("setPatPlansParams", rec);
    },
    /*add FNSI-改修内容患者イベント画面で作成された掲示板データのイベント開始、終了日が設定されない。任 start*/
    async setPatEventList({ commit }, rec) {
      commit("setPatEventList", rec);
    },
    /*add FNSI-改修内容患者イベント画面で作成された掲示板データのイベント開始、終了日が設定されない。任 end*/
    /**
     *
     * @param {*} param0
     * @param {*} param1
     */
    async setPatEventResultParamsUpdate({ commit }, { item, index }) {
      commit("setPatEventResultParamsUpdate", { item, index });
    },
    /*add FNSI-改修内容5570 任 start*/
    async setBbsInfoNew({ commit }, value) {
      commit("setBbsInfoNew", value);
    },
    /*add FNSI-改修内容5570 任 end*/
    /*add FNSI-改修内容添付ファイル修正 任 start*/
    async setShowFile({ commit },value) {
      commit("setShowFile",value);
    },
    /*add FNSI-改修内容添付ファイル修正 任 end*/
    /*add FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 start*/
    async setPatEventInputParams({ commit },value) {
      commit("setPatEventInputParams",value);
    },
    /*add FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 end*/
    /**
     * 患者イベント
     * @param {*} param0
     * @param {*} rec
     */
    async setPatEventRecord({ commit }, rec) {
      commit("setPatEventRecord", rec);
    },
    setInitPatEventRecord({commit}, value) {
      commit("setInitPatEventRecord", value);
    },
    /**
     *
     * @param {*} context
     * @param {*} info
     */
    async setPatEventCreate({ state }, param) {
      let interval = 0;
      if (state.patPlansParams.interval !== null) {
        interval = state.patPlansParams.interval;
      }
      const params = {
        mode: state.patPlansParams.mode,
        startDate: state.patPlansParams.startDate,
        endDate: state.patPlansParams.endDate,
        interval: interval,
        intervalClass: state.patPlansParams.intervalClass,
        startTime: state.patPlansParams.startTime,
        dateClass: state.patPlansParams.dateClass,
        endTime: state.patPlansParams.endTime,
        patEventParam: param.rec,
        isNotification: param.isNotification
      };
      const response = await sendRequestPostPatEventRecord(params);
      if (response.status === 200) {
        /*mod FNSI-改修内容患者イベント画面で作成された掲示板データのイベント開始、終了日が設定されない。任 start*/
        /*if (response.data === 0) {*/
        if (response.data[0].patEventCd === 0) {
          /*mod FNSI-改修内容患者イベント画面で作成された掲示板データのイベント開始、終了日が設定されない。任 end*/
          return "NG002";
        } else {
          return response.data;
        }
      } else {
        return "NG001";
      }
    },
    /**
     *
     * @param {*} context
     * @param {*} info
     */
    async setPatEventUpdate(context, param) {
      const params = {
        patEventParam: param.rec,
        isNotification: param.isNotification
      };
      const response = await sendRequestPutPatEventRecord(params);
      if (response.status === 200) {
        return true;
      } else {
        return false;
      }
    },
    /**
     *
     * @param {*} context
     * @param {*} info
     */
    async setPatEventUpdateResultParamas(context, rec) {
      const response = await sendRequestPutPatEventResultParams(rec);
      if (response.status === 200) {
        return true;
      } else {
        return false;
      }
    },

    /**
     *
     * @param {*} context
     * @param {*} info
     */
    async setPatEventUpdateBbsCtlNo(context, rec) {
      const response = await sendRequestPutPatEventBbsCtlNo(rec);
      if (response.status === 200) {
        return true;
      } else {
        return false;
      }
    },

    /**
     *
     * @param {*} context
     * @param {*} info
     */
    async setPatEventDelete(context, info) {
      const response = await sendRequestPostPatEventRecordDelete(info)
      if (response.status === 200) {
        return true;
      } else {
        return false;
      }
    },
    /**
     *
     * @param {*} context
     * @param {*} info
     */
    async setComboOrdMain({ commit }, info) {
      await commit("clearComboOrdMain");
      await commit("setComboOrdMain", info);
    },
    /*add FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 start*/
    async setTemplateShow({commit}, info) {
      await commit("setTemplateShow",info);
    },
    /*add FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 end*/
    /**
     * 患者の実績オーダー取得
     * @param {Object} context
     * @param {Object} param
     * @param {Number} param.patId
     * @param {Number} param.ordMain
     */
    async fetchOrdMainRecord(context, param) {
      return sendRequestGetOrdMainRecord(param);
    },
    /**日治療情
     * 患者別当報の取得
     * @param {*} param
     */
    async fetchOrdMain({ commit }, { patId, treatStartDate, treatEndDate, patEventCd }) {
      await commit("clearComboOrdMain");
      if (!patId || !isValidOrdMainDate(treatStartDate) || !isValidOrdMainDate(treatEndDate)) {
        return;
      }
      // 治療開始
      const response1 = await sendRequestGetOrdMainRecordList({
        patId: patId,
        treatStartDate: treatStartDate,
        treatEndDate: treatEndDate,
        patEventCd: patEventCd,
        getClass: 1
      });
      if (response1.data.length > 0 && response1.data[0] !== null) {
        await commit("setComboOrdMain", response1.data);
      }
      // 未治療
      const response2 = await sendRequestGetOrdMainRecordList({
        patId: patId,
        treatStartDate: treatStartDate,
        treatEndDate: treatEndDate,
        patEventCd: patEventCd,
        getClass: 2
      });
      if (response2.data.length > 0 && response2.data[0] !== null) {
        await commit("setComboOrdMainByOrdNo", response2.data);
      }
      // 治療終了
      const response3 = await sendRequestGetOrdMainRecordList({
        patId: patId,
        treatStartDate: treatStartDate,
        treatEndDate: treatEndDate,
        patEventCd: patEventCd,
        getClass: 3
      });
      if (response3.data.length > 0 && response3.data[0] !== null) {
        await commit("setComboOrdMainByOrdNo", response3.data);
      }
      /*add FNSI-改修内容redmain #6003 周 start*/
      await commit("sortComboOrdMain");
      /*add FNSI-改修内容redmain #6003 周 end*/
    },
    // add 8337 【デグレ】掲示板リンクを含んだ患者イベントの編集→保存ができない 関 start
    setIsNotificationFlg({commit}, value) {
      commit("setIsNotificationFlg", value);
    },
    // add 8337 【デグレ】掲示板リンクを含んだ患者イベントの編集→保存ができない 関  end
    // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 start
    setSkipRoute({ commit }, value) {
      commit("setSkipRoute", value);
    },
    // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 end

    //add #9208 患者イベントの実績リンクでの選択肢が不正 関 start
    async getMst({ commit }, payload) {
      const facilityCd = payload && typeof payload === "object" ? payload.facilityCd : payload;
      const selectedPatId = payload && typeof payload === "object" ? payload.selectedPatId : undefined;
      await sendRequestGetKur(facilityCd, selectedPatId)
        .then(response => {
          commit("setMstKurList", response.data);
        })
        .catch(err => {
          console.error(err);
        });

        const [
          mstBedSelector,
        ] = await Promise.all([
          bedSelector(facilityCd),
        ]).catch(error => {
          getErrorMessage("PatEventDetailStore.js", "getMst", error);
          throw new Error(error);
        });
        commit("setMstBedSelector", mstBedSelector);
    },
      //add #9208 患者イベントの実績リンクでの選択肢が不正 関 end
  },
  getters: {
    /**
     *
     * @param {*} state
     */
    getViewMode(state) {
      return state.viewMode;
    },
    /*add FNSI-改修内容患者イベント患者情報共有より改修 任 start*/
    getFacilityName(state) {
      return state.facilityName;
    },
    /*add FNSI-改修内容患者イベント患者情報共有より改修 任 end*/
    /**
     *
     * @param {*} state
     */
    getIsMainList(state) {
      return state.isMainList;
    },
    /**
     * 患者イベント予定作成パラメータ
     * @param {*} state
     */
    getPatPlansParams(state) {
      return state.patPlansParams;
    },
    /*add FNSI-改修内容患者イベント画面で作成された掲示板データのイベント開始、終了日が設定されない。任 start*/
    getPatEventList(state) {
      return state.patEventList;
    },
    /*add FNSI-改修内容患者イベント画面で作成された掲示板データのイベント開始、終了日が設定されない。任 end*/
    /**
     * 患者イベント
     * @param {*} state
     */
    getPatEventRecord(state) {
      return state.patEventRecord;
    },
    getInitPatEventRecord(state) {
      return state.initPatEventRecord;
    },
    /*add FNSI-改修内容添付ファイル修正 任 start*/
    getShowFile(state) {
      return state.showFile;
    },
    /*add FNSI-改修内容添付ファイル修正 任 end*/
    /**
     * 患者イベント
     * @param {*} state
     */
    getPatEventInputParams(state) {
      if (state.patEventRecord === null) {
        return [];
      } else {
        return state.patEventRecord.inputParams;
      }
    },
    /**
     * 患者イベント
     * @param {*} state
     */
    getPatEventResultParams(state) {
      if (state.patEventRecord === null) {
        return [];
      } else {
        return state.patEventRecord.resultParams;
      }
    },
    /**
     * 患者イベント
     * @param {*} state
     */
    getPatEventRegStaffInfo(state) {
      if (state.patEventRecord === null) {
        return [];
      } else {
        return state.patEventRecord.regStaffInfo;
      }
    },
    /**
     * 患者イベント
     * @param {*} state
     */
    getPatEventUpStaffInfo(state) {
      if (state.patEventRecord === null) {
        return [];
      } else {
        return state.patEventRecord.upStaffInfo;
      }
    },
    /*add FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 start*/
    getTemplateShow(state){
      return state.templateShow;
    },
    /*add FNSI-改修内容5570 任 start*/
    getBbsInfoNew(state){
      return state.bbsInfoNew;
    },
    /*add FNSI-改修内容5570 任 end*/
    /*add FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 end*/
    getComboOrdMain(state) {
      return state.comboOrdMain;
    },
    // add 8337 【デグレ】掲示板リンクを含んだ患者イベントの編集→保存ができない 関 start
    getIsNotificationFlg(state) {
      return state.isNotificationFlg;
    },
    // add 8337 【デグレ】掲示板リンクを含んだ患者イベントの編集→保存ができない 関  end
    // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 start
    getSkipRoute(state) {
      return state.skipRoute;
    },
    // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 end
    },
};
