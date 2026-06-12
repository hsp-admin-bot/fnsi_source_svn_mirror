/**
 * 治療記録 共通ストア.
 */
import {
  sendRequestGetLatestOrdNo,
  sendRequestGetTreatmentRecordSummary,
  sendRequestUpdateTreatmentRecordConfirm,
  sendRequestCancelCondition,
  sendRequestGetMstMachineByOrdNoRst,
  sendRequestGetMntMachineState,
  sendRequestGetIsPurification,
  // sendRequestDeleteTreatmentRecordRst,
  sendRequestTreatingOrdNo,
  sendGetNoticeMedi,
  // #9315 2024.02.14 add オフライン治療開始後画面リロード処理 TDC片口 start
  sendRequestGetTreatmentRecordCurrentRstDialysisState,
  // #9315 2024.02.14 add オフライン治療開始後画面リロード処理 TDC片口 end
} from "@/apis/treatment-record";
import {
  sendRequestStartOfflineTreating,
  sendRequestEndOfflineTreating,
  sendRequestSendNextPatInfoRst,
  //FNSI-修正 #5525 横展開対応、xugj add start
  sendRequestSendNextPatInfoRstViewer,
  //FNSI-修正 #5525 横展開対応、xugj add end
  sendRequestSendReportUpdateInfoRst,
  sendRequestSendEndDateUpdateInfoRst,
  //FNSI-修正 #7870 ljx add start
  sendRequestChangeTreatTime,
  //FNSI-修正 #7870 ljx add end
  // #10518 2024.04.19 add 対象患者が現患者のベッドに対して「実績確定・削除時装置レポート画像更新」通知を行うREST-API呼び出しメソッドを追加 TDC米沢 start
  sendRequestAllReportUpdateByPatId,
  // #10518 2024.04.19 add 対象患者が現患者のベッドに対して「実績確定・削除時装置レポート画像更新」通知を行うREST-API呼び出しメソッドを追加 TDC米沢 end
} from "@/apis/device-edge-order";
import { sendRequestGetFacilityNameByCd } from "@/apis/pat-prescription";

export default {
  strict: true,
  namespaced: true,
  state: {
    /**
     * 患者ヘッダーで選択された患者の最新の治療記録レコードのオーダ番号.
     */
    ordNo: null,

    /**
     * サイドバー(別画面からの遷移時のリスト)から選択されたレコードのオーダ番号.
     */
    ordNoForSideBarRecord: null,

    /**
     * 治療記録更日時
     */
    treatmentUpdate: null,

    /**
     * ボタンメニューの開閉有無
     */
    isMenuOpen: true,

    /**
     * 治療状況
     */
    dialysisState: null,

    /**
     * 治療日時
     */
    treatDate: null,
    
    /**
     * 初版確定日時
     */
    rstEditionDate: null,
    
    /**
     * 治療開始日時
     */
    rstStartDate: null,
    
    /**
     * 治療終了日時
     */
    rstEndDate: null,
    
    /**
     * 別施設から受理したデータ場合は編集不可になり
     */
    ord: null,

    /**
     * 共有施設コード
     */
    shared_facility_cd: null,
    ordNoDataSourcesState: null,

    /**
     * 実績：治療条件情報
     */
    rstCondInfo: null,
    
    /**
     * レポートレイアウトの状態
     */
    layoutState: {
      // スライダーの倍率
      sliderVal: 0
    },
    ordNoDataReady: false
  },
  mutations: {
    setOrdNoDataSources(state, ordNoDataSources) {
      state.ordNoDataSourcesState = ordNoDataSources;
    },
    setOrdNoDataReady(state, flag) {
      state.ordNoDataReady = flag;
    },
    /**
     * オーダ番号を設定する.
     * @param {*} state STATEオブジェクト
     * @param {*} ordNo オーダ番号
     */
    setOrdNo(state, ordNo) {
      state.ordNo = ordNo;
    },

    /**
     * サイドバーから選択されたレコードのオーダ番号を設定する.
     * @param {*} state STATEオブジェクト
     * @param {*} ordNo オーダ番号
     */
    setOrdNoForSideBarRecord(state, ordNo) {
      state.ordNoForSideBarRecord = ordNo;
    },

    /**
     * 治療記録更新日時を設定する.
     * @param {*} state STATEオブジェクト
     * @param {Date} treatmentUpdate 治療記録更新日時
     */
    setTreatmentUpdate(state, treatmentUpdate) {
      state.treatmentUpdate = treatmentUpdate;
    },

    /**
     * ボタンメニューの開閉有無を設定する.
     * @param {*} state STATEオブジェクト
     * @param {*} isMenuOpen ボタンメニューの開閉有無
     */
    setIsMenuOpen(state, isMenuOpen) {
      state.isMenuOpen = isMenuOpen;
    },

    /**
     * 治療状況を設定する.
     * @param {*} state STATEオブジェクト
     * @param {Integer} dialysisState 治療状況
     */
    setDialysisState(state, dialysisState) {
      state.dialysisState = dialysisState;
    },

    /**
     * 治療日時を設定する.
     * @param {*} state STATEオブジェクト
     * @param {Integer} treatDate 治療日時
     */
    setTreatDate(state, treatDate) {
      state.treatDate = treatDate;
    },
    
    /**
     * 初版確定日時を設定する.
     * @param {*} state STATEオブジェクト
     * @param {Integer} rstEditionDate 初版確定日時
     */
    setRstEditionDate(state, rstEditionDate) {
      state.rstEditionDate = rstEditionDate;
    },
    
    /**
     * 治療開始日時を設定する.
     * @param {*} state STATEオブジェクト
     * @param {Integer} rstStartDate 治療開始日時
     */
    setRstStartDate(state, rstStartDate) {
      state.rstStartDate = rstStartDate;
    },
    
    /**
     * 治療終了日時を設定する.
     * @param {*} state STATEオブジェクト
     * @param {Integer} rstEndDate 治療終了日時
     */
    setRstEndDate(state, rstEndDate) {
      state.rstEndDate = rstEndDate;
    },

    /**
     * 透析をセット
     */
    setOrd(state, ord) {
      state.ord = ord;
    },

    /**
     * 施設コードを設定する.
     * @param {*} state STATEオブジェクト
     * @param {*} ordNo 施設コード
     */
    setSharedFacilityCd(state, shared_facility_cd) {
      state.shared_facility_cd = shared_facility_cd;
    },

    /**
     * 実績：治療条件情報の格納
     * @param {*} state       STATEオブジェクト
     * @param {*} rstCondInfo 実績：治療条件情報
     */
    setRstCondInfo(state, rstCondInfo) {
      state.rstCondInfo = rstCondInfo;
    },
    /**
     * レポートレイアウトの状態を設定
     * @param {*} state
     * @param {Object} layoutState レポートレイアウトの状態
     */
    setLayoutState(state, layoutState) {
      state.layoutState = layoutState;
    }
  },
  actions: {
    /**
     * 指定された患者IDから治療記録レコードの最新のオーダ番号を取得する.
     * @param {*} commit COMMITオブジェクト
     * @param {*} patId 患者ID
     */
    getLatestOrdNo({ commit }, patId) {
      return sendRequestGetLatestOrdNo(patId);
    },
    /**
     * 指定されたオーダ番号から治療記録レコードの治療概要を取得する.
     * @param {*} commit COMMITオブジェクト
     * @param {*} ordNo オーダ番号
     */
    getSummary({ commit }, payload) {
      const ordNo = payload && typeof payload === "object" ? payload.ordNo : payload;
      const selectedPatId = payload && typeof payload === "object" ? payload.selectedPatId : undefined;
      return sendRequestGetTreatmentRecordSummary(ordNo, selectedPatId);
    },
    /**
     * オーダ番号を設定する.
     * @param {*} commit COMMITオブジェクト
     * @param {*} ordNo オーダ番号
     */
    setOrdNo({ commit }, ordNo) {
      commit("setOrdNo", ordNo);
    },
    /**
     * サイドバーから選択されたレコードのオーダ番号を設定する.
     * @param {*} commit COMMITオブジェクト
     * @param {*} ordNo オーダ番号
     */
    setOrdNoForSideBarRecord({ commit }, ordNo) {
      commit("setOrdNoForSideBarRecord", ordNo);
    },
    /**
     * 治療記録更新日時を設定する.
     * @param {*} commit COMMITオブジェクト
     * @param {Date} treatmentUpdate 治療記録更新日時
     */
    setTreatmentUpdate({commit}, treatmentUpdate) {
      commit("setTreatmentUpdate", treatmentUpdate);
    },

    /**
     * ボタンメニューの開閉有無を設定する.
     * @param {*} commit COMMITオブジェクト
     * @param {*} isMenuOpen ボタンメニューの開閉有無
     */
    setIsMenuOpen({ commit }, isMenuOpen) {
      commit("setIsMenuOpen", isMenuOpen);
    },

    /**
     * 治療状況を設定する.
     * @param {*} commit COMMITオブジェクト
     * @param {Integer} dialysisState 治療状況
     */
    setDialysisState({ commit }, dialysisState) {
      commit("setDialysisState", dialysisState);
    },

    /**
     * 治療日時を設定する.
     * @param {*} commit COMMITオブジェクト
     * @param {Integer} treatDate 治療日時
     */
    setTreatDate({ commit }, treatDate) {
      commit("setTreatDate", treatDate);
    },
    
    /**
     * 初版確定日時を設定する.
     * @param {*} commit COMMITオブジェクト
     * @param {Integer} rstEditionDate 初版確定日時
     */
    setRstEditionDate({ commit }, rstEditionDate) {
      commit("setRstEditionDate", rstEditionDate);
    },
    
    /**
     * 治療開始日時を設定する.
     * @param {*} commit COMMITオブジェクト
     * @param {Integer} rstStartDate 治療開始日時
     */
    setRstStartDate({ commit }, rstStartDate) {
      commit("setRstStartDate", rstStartDate);
    },
    
    /**
     * 治療終了日時を設定する.
     * @param {*} commit COMMITオブジェクト
     * @param {Integer} rstEndDate 治療終了日時
     */
    setRstEndDate({ commit }, rstEndDate) {
      commit("setRstEndDate", rstEndDate);
    },

    /**
     * 版確定を行う.
     * @param {*} commit COMMITオブジェクト
     * @param {*} ordNo オーダ番号
     */
    //mod FNSI-7531 劉全航 start
    // dialysisConfirm({commit}, ordNo) {
    //   /* eslint-enable no-unused-vars */
    //   return sendRequestUpdateTreatmentRecordConfirm(ordNo);
    // },
    dialysisConfirm({commit}, param) {
      return sendRequestUpdateTreatmentRecordConfirm(param.ordNo, param.userId);
    },
    //mod FNSI-7531 劉全航 end

    /**
     * 条件送信破棄を実行する.
     * @param {*} commit COMMITオブジェクト
     * @param {*} params パラメータ
     */
    sendCancelCondition({ commit }, params) {
      return sendRequestCancelCondition(params);
    },
    /**
     * 指定されたオーダ番号から装置マスタを取得する.
     * @param {*} commit COMMITオブジェクト
     * @param {*} ordNo オーダ番号
     */
    getMstMachineByOrdNoRst({ commit }, payload) {
      const ordNo = payload && typeof payload === "object" ? payload.ordNo : payload;
      const selectedPatId = payload && typeof payload === "object" ? payload.selectedPatId : undefined;
      return sendRequestGetMstMachineByOrdNoRst(ordNo, selectedPatId);
    },
    /**
     * 指定されたオーダ番号から装置状態を取得する.
     * @param {*} commit COMMITオブジェクト
     * @param {*} facilityCd 施設コード
     * @param {*} ordNo オーダ番号
     */
    getMntMachineState({ commit },params) {
      return sendRequestGetMntMachineState(params.facilityCd, params.ordNo, params.selectedPatId);
    },
    /**
     * オフライン運転開始
     * @param {object} context
    * @param {object} params
    * @param {number} params.ordNo オーダー番号
    * @param {number} params.machineNo 装置マスタ.装置番号
    * @param {number} params.deviceEdgeNo デバイスエッジ番号
    * @param {string} params.facilityCd 施設コード
     */
    sendStartOfflineTreat(context, params) {
      return sendRequestStartOfflineTreating(params);
    },
    /**
     * オフライン運転終了
     * @param {object} context
     * @param {object} params
     * @param {number} params.ordNo オーダー番号
     * @param {number} params.machineNo 装置マスタ.装置番号
     * @param {number} params.deviceEdgeNo デバイスエッジ番号
     * @param {string} params.facilityCd 施設コード
     */
    sendEndOfflineTreat(context, params) {
      return sendRequestEndOfflineTreating(params);
    },
    /**
     * 特殊浄化フラグの取得
     * @param {object}} context
     * @param {Number} treatmentCd
     */
    getIsPurification(context,payload) {
      const treatmentCd = payload && typeof payload === "object" ? payload.treatmentCd : payload;
      const selectedPatId = payload && typeof payload === "object" ? payload.selectedPatId : undefined;
      return sendRequestGetIsPurification(treatmentCd, selectedPatId);
    },
    /**
     * 透析情報をセット
     * @param {*} ord 透析オブジェクト
     */
    setOrd({ commit }, ord) {
      commit("setOrd", ord);
    },

    /**
     * 実績を削除する.
     * @param {*} commit commitオブジェクト
     * @param {*} ordNo オーダ番号
     */
    // async deleteDialysis({commit}, ordNo) {
    //   /* eslint-enable no-unused-vars */
    //   return sendRequestDeleteTreatmentRecordRst(ordNo);
    // },
    // add FNSI-修正 共有設定 房 start
    /**
     * 指定されたfacilityCd番号から施設名を取得する。
     * @param {*} commit COMMITオブジェクト
     * @param {*} facilityCd 施設番号
     */
    getFacilityName(context, payload) {
      const facilityCd = payload && typeof payload === "object" ? payload.facilityCd : payload;
      const selectedPatId = payload && typeof payload === "object" ? payload.selectedPatId : undefined;
      return sendRequestGetFacilityNameByCd(facilityCd, selectedPatId);
    },
    // add FNSI-修正 共有設定 房 end

    //add 次患者情報更新の追加 房 start
    /**
     * 次患者情報を更新する.
     * @param {*} commit commitオブジェクト
     * @param {*} ordNo オーダ番号
     */
    sendNextPatInfo(context, params) {
      return sendRequestSendNextPatInfoRst(params);
    },

    //FNSI-修正 #5525 横展開対応、xugj add
    /**
     * 次患者情報を更新する(患者経過総合ビューア).
     * @param {*} commit commitオブジェクト
     * @param {*} ordNo オーダ番号
     */
    sendNextPatInfoViewer(context, params) {
      return sendRequestSendNextPatInfoRstViewer(params);
    },

    /**
     * レポートを更新する.
     * @param {*} commit commitオブジェクト
     * @param {*} ordNo オーダ番号
     */
    sendReportUpdateInfo(context, params) {
      return sendRequestSendReportUpdateInfoRst(params);
    },
    //add 次患者情報更新の追加 房 end
    //add FNSI内容修正 外部Api調用 房 start
    sendTreatingOrdNo(context, payload) {
      const ordNo = payload && typeof payload === "object" ? payload.ordNo : payload;
      const selectedPatId = payload && typeof payload === "object" ? payload.selectedPatId : undefined;
      return sendRequestTreatingOrdNo(ordNo, selectedPatId);
    },

    sendEndDateUpdateInfo(context, params) {
      return sendRequestSendEndDateUpdateInfoRst(params);
    },

    sendGetNoticeMedi(context, payload){
      const ordNo = payload && typeof payload === "object" ? payload.ordNo : payload;
      const selectedPatId = payload && typeof payload === "object" ? payload.selectedPatId : undefined;
      return sendGetNoticeMedi(ordNo, selectedPatId);
    },
    //add FNSI内容修正 外部Api調用 房 end
    //add FNSI内容修正 外部Api調用(装置へ治療時間変更の通知) ljx start
    /**
     * お知らせを送信する.
     * @param {*} commit commitオブジェクト
     * @param {*} ordNo オーダ番号
     */
    sendRequestChangeTreatTime(context, params) {
      return sendRequestChangeTreatTime(params);
    },
    //add FNSI内容修正 外部Api調用 ljx end
    // #9315 2024.02.14 add オフライン治療開始後画面リロード処理 TDC片口 start
    sendRequestGetTreatmentRecordCurrentRstDialysisState(context, payload) {
      const ordNo = payload && typeof payload === "object" ? payload.ordNo : payload;
      const selectedPatId = payload && typeof payload === "object" ? payload.selectedPatId : undefined;
      return sendRequestGetTreatmentRecordCurrentRstDialysisState(ordNo, selectedPatId);
    },
    // #9315 2024.02.14 add オフライン治療開始後画面リロード処理 TDC片口 end

    // #10518 2024.04.19 add 対象患者が現患者のベッドに対して「実績確定・削除時装置レポート画像更新」通知を行うアクションを追加 TDC米沢 start
    /**
     * 実績確定・削除時装置レポート画像更新
     * @param {*} context contextオブジェクト
     * @param {*} params パラメータ
     * @returns
     */
    sendAllReportUpdateByPatId(context, params) {
      return sendRequestAllReportUpdateByPatId(params);
    },
    // #10518 2024.04.19 add 対象患者が現患者のベッドに対して「実績確定・削除時装置レポート画像更新」通知を行うアクションを追加 TDC米沢 end

    /**
     * 実績：治療条件情報のコミット
     * @param {*} commit      COMMITオブジェクト
     * @param {*} rstCondInfo 実績：治療条件情報
     */
    setRstCondInfo({ commit }, rstCondInfo) {
      commit("setRstCondInfo", rstCondInfo);
    },
    /**
     * レポートレイアウトの状態を設定
     * @param {*} commit
     * @param {*} layoutState レポートレイアウトの状態
     */
    setLayoutState({ commit }, layoutState) {
      commit("setLayoutState", layoutState);
    }
  },
  getters: {
    /**
     * オーダ番号を取得する.
     * @param {*} state STATEオブジェクト
     */
    getOrdNo(state) {
      return state.ordNo;
    },
    /**
     * サイドバーから選択されたレコードのオーダ番号を取得する.
     * @param {*} state STATEオブジェクト
     */
    getOrdNoForSideBarRecord(state) {
      return state.ordNoForSideBarRecord;
    },

    /**
     * 治療記録更新日時を取得する.
     * @param {*} state STATEオブジェクト
     * @returns 治療記録更新日時
     */
    getTreatmentUpdate(state) {
      return state.treatmentUpdate;
    },

    /**
     * ボタンメニューの開閉有無を取得する.
     * @param {*} state STATEオブジェクト
     */
    getIsMenuOpen(state) {
      return state.isMenuOpen;
    },

    /**
     * 治療状況を取得する.
     * @param {*}} state STATEオブジェクト
     */
    getDialysisState(state) {
      return state.dialysisState;
    },

    /**
     * 治療日時を取得する.
     * @param {*}} state STATEオブジェクト
     */
    getTreatDate(state) {
      return state.treatDate;
    },
    
    /**
     * 初版確定日時を取得する.
     * @param {*}} state STATEオブジェクト
     */
    getRstEditionDate(state) {
      return state.rstEditionDate;
    },
    
    /**
     * 治療開始日時を取得する.
     * @param {*}} state STATEオブジェクト
     */
    getRstStartDate(state) {
      return state.rstStartDate;
    },
    
    /**
     * 治療終了日時を取得する.
     * @param {*}} state STATEオブジェクト
     */
    getRstEndDate(state) {
      return state.rstEndDate;
    },

    /**
     * 透析情報を取得する.
     * @param {*}} state STATEオブジェクト
     */
    getOrd(state) {
      return state.ord;
    },

    /**
     * 施設コードを取得する.
     * @param {*} state STATEオブジェクト
     * @param {*} ordNo 施設コード
     */
    getSharedFacilityCd(state) {
      return state.shared_facility_cd;
    },

    /**
     * 実績：治療条件情報の取得
     * @param {*} state STATEオブジェクト
     */
    getRstCondInfo(state) {
      return state.rstCondInfo;
    },
  },
};
