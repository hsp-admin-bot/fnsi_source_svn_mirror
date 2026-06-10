/**
 * 治療記録 愁訴処置ストア
 */
import {
  sendRequestGetTreatmentRecordComplaint,
  sendRequestUpdateTreatmentRecordComplaint,
  sendRequestGetMstComplaint,
  sendRequestGetMstCompTreatment,
  //add FNSI修正401改修 房 start
  sendRequestgetMonitorMsgRecord,
  sendRequestUpdMonitorMsgRecord
  //add FNSI修正401改修 房 end
} from "@/apis/treatment-record";

export default {
  strict: true,
  namespaced: true,
  state: {
    /**
     * 愁訴処置データ.
     */
    complaintData: [],
    /**
     * 編集する愁訴処置情報の時刻.
     * (hh:mm形式文字列)
     */
    editingTime: null,
    /**
     * 酸素吸入モーダルで表示する情報を格納するモデル.
     */
    oxygenModal: null,
    /**
     * 更新日時.
     */
    upDate: null,
    /**
     * 編集対象データの愁訴処置日時
     */
    editOccurDate: null,
    /**
     * 編集する愁訴処置情報
     */
    editCompAndTreat: null,
    /**
     * 編集から登録画面を呼びだした時に登録画面で選択された愁訴処置情報
     */
    editSelectedCompAndTreat: null,
    // add FNSI-改修内容 心電図追加 房 start
    /**
     * 心電図
     */
    electrocardiogramModal:null,
    // add FNSI-改修内容 心電図追加 房 end
    //add FNSI修正内容 愁訴処置の登録および表示修正 房 start
    ctlNo: 0,
    //add FNSI修正内容 愁訴処置の登録および表示修正 房 end
    //add FNSI改修内容 愁訴処置編集修正 房 start
    editingCtlNo: 0,
    //add FNSI改修内容 愁訴処置編集修正 房 end
  },
  mutations: {
    /**
     * 愁訴処置データを設定する.
     * @param {*} state STATEオブジェクト
     * @param {*} complaintData 愁訴処置データ
     */
    setComplaintData(state, complaintData) {
      state.complaintData = complaintData;
    },
    /**
     * 編集する愁訴処置情報の時刻を設定する.
     * @param {*} state STATEオブジェクト
     * @param {*} editingTime 編集する愁訴処置情報の時刻
     */
    setEditingTime(state, editingTime) {
      state.editingTime = editingTime;
    },
    /**
     * 酸素吸入モデル（モーダル用）を設定する.
     * @param {*} state STATEオブジェクト
     * @param {*} oxygenModal 酸素吸入モデル（モーダル用）
     */
    setOxygenModal(state, oxygenModal) {
      state.oxygenModal = oxygenModal;
    },
    /**
     * 更新日時を設定する.
     * @param {*} state stateオブジェクト
     * @param {*} upDate 更新日時
     */
    setUpDate(state, upDate) {
      state.upDate = upDate;
    },
    /**
     * 編集対象の愁訴処置日時を設定する.
     * @param {*} state stateオブジェクト
     * @param {*} editOccurDate 編集対象の愁訴処置日時
     */
    setEditOccurDate(state, editOccurDate) {
      state.editOccurDate = editOccurDate;
    },
    /**
     * 編集対象の愁訴処置情報を設定する.
     * @param {*} state stateオブジェクト
     * @param {*} editCompAndTreat 編集対象の愁訴処置情報
     */
    setEditCompAndTreat(state, editCompAndTreat) {
      state.editCompAndTreat = editCompAndTreat;
    },
    /**
     * 編集画面から表示された新規登録画面で選択された愁訴処置情報を設定する.
     * @param {*} state stateオブジェクト
     * @param {*} editSelectedCompAndTreat 新規登録画面で選択された愁訴処置情報
     */
    setEditSelectedCompAndTreat(state, editSelectedCompAndTreat) {
      state.editSelectedCompAndTreat = editSelectedCompAndTreat;
    },
    // add FNSI-改修内容 心電図追加 房 start
    /**
     * 心電図モデル（モーダル用）を設定する.
     * @param {*} state STATEオブジェクト
     * @param {*} electrocardiogramModal 心電図モデル（モーダル用）
     */
    setElectrocardiogramModal(state, electrocardiogramModal) {
      state.electrocardiogramModal = electrocardiogramModal;
    },
    // add FNSI-改修内容 心電図追加 房 end
    //add FNSI修正内容 愁訴処置の登録および表示修正 房 start
    setTempCtlNo(state, ctlNo) {
      state.ctlNo = ctlNo;
    },
    //add FNSI修正内容 愁訴処置の登録および表示修正 房 end
    //add FNSI改修内容 愁訴処置編集修正 房 start
    setEditingCtlNo(state, editingCtlNo) {
      state.editingCtlNo = editingCtlNo;
    },
    //add FNSI改修内容 愁訴処置編集修正 房 end
  },
  actions: {
    /**
     * 愁訴処置データを設定する.
     * @param {*} commit COMMITオブジェクト
     * @param {*} complaintData 愁訴処置データ
     */
    setComplaintData({ commit }, complaintData) {
      commit("setComplaintData", complaintData);
    },
    /**
     * 編集する愁訴処置情報の時刻を設定する.
     * @param {*} commit COMMITオブジェクト
     * @param {*} editingTime 編集する愁訴処置情報の時刻
     */
    setEditingTime({ commit }, editingTime) {
      commit("setEditingTime", editingTime);
    },
    /**
     * モーダル表示に必要な情報を設定する.
     * @param {*} commit COMMITオブジェクト
     * @param {*} oxygenModal 酸素吸入モデル（モーダル用）
     */
    setOxygenModal({ commit }, oxygenModal) {
      commit("setOxygenModal", oxygenModal);
    },
    /**
     * 愁訴処置情報取得.
     * @param {*} commit commitオブジェクト
     * @param {*} ordNo オーダ番号
     */
    // TODO: 局所的なeslintの設定を削除する
    /* eslint-disable no-unused-vars */
    getTreatmentRecordComplaint({ commit }, ordNo) {
      return sendRequestGetTreatmentRecordComplaint(ordNo).then(response => {
        commit("setUpDate", response.data.up_date);
        return response;
      });
    },
    /**
     * 愁訴処置情報保存.
     * @param {*} commit commitオブジェクト
     * @param {*} ordNo オーダ番号
     * @param {*} payload 愁訴処置情報
     */
    // TODO: 局所的なeslintの設定を削除する
    /* eslint-disable no-unused-vars */
    updateTreatmentRecordComplaint({ commit, state }, { ordNo, forcedChangeFlag, payload }) {
      return sendRequestUpdateTreatmentRecordComplaint(
        ordNo,
        forcedChangeFlag,
        {
          ...payload,
          up_date: state.upDate
        }
      );
    },
    /**
     * 愁訴マスタ取得.
     * @param {*} commit commitオブジェクト
     */
    getMstComplaint({ commit }) {
      return sendRequestGetMstComplaint();
    },
    /**
     * 処置マスタ取得.
     * @param {*} commit commitオブジェクト
     */
    getMstCompTreatment({ commit }) {
      return sendRequestGetMstCompTreatment();
    },
    /**
     *
     * @param {*} commit commitオブジェクト
     * @param {*} editOccurDate
     */
    setEditOccurDate({commit}, editOccurDate) {
      commit("setEditOccurDate", editOccurDate);
    },
    /**
     *
     * @param {*} commit commitオブジェクト
     * @param {*} editCompAndTreat
     */
    setEditCompAndTreat({commit}, editCompAndTreat) {
      commit("setEditCompAndTreat", editCompAndTreat);
    },
    /**
     *
     * @param {*} commit commitオブジェクト
     * @param {*} editSelectedCompAndTreat
     */
    setEditSelectedCompAndTreat({commit}, editSelectedCompAndTreat) {
      commit("setEditSelectedCompAndTreat", editSelectedCompAndTreat);
    },
    // add FNSI-改修内容 心電図追加 房 start
    /**
     * モーダル表示に必要な情報を設定する.
     * @param {*} commit COMMITオブジェクト
     * @param {*} oxygenModal 心電図モデル（モーダル用）
     */
    setElectrocardiogramModal({ commit }, electrocardiogramModal) {
      commit("setElectrocardiogramModal", electrocardiogramModal);
    },
    // add FNSI-改修内容 心電図追加 房 end
    //add FNSI改修内容 愁訴処置編集修正 房 start
    setEditingCtlNo({ commit }, editingCtlNo) {
      commit("setEditingCtlNo", editingCtlNo);
    },
    //add FNSI改修内容 愁訴処置編集修正 房 end
    //add FNSI修正401改修 房 start
    // mod #12462 患者情報共有 Ji start
    getMonitorMsgRecord({ commit }, { ordNo, facilityCd }) {
      return sendRequestgetMonitorMsgRecord(ordNo, facilityCd).then(response => {
    // mod #12462 患者情報共有 Ji end
        return response;
      });
    },
    updMonitorMsgRecord({ commit }, MntMonitorMsgRecord){
      return sendRequestUpdMonitorMsgRecord(MntMonitorMsgRecord);
    },
    //add FNSI修正401改修 房 end
  },
  getters: {
    /**
     * 愁訴処置データを取得する.
     * @param {*} state STATEオブジェクト
     */
    getComplaintData(state) {
      return state.complaintData;
    },
    /**
     * 編集する愁訴処置情報の時刻を取得する.
     * @param {*} state STATEオブジェクト
     */
    getEditingTime(state) {
      return state.editingTime;
    },
    /**
     * 酸素吸入モデル（モーダル用）を取得する.
     * @param {*} state STATEオブジェクト
     */
    getOxygenModal(state) {
      return state.oxygenModal;
    },
    /**
     * 編集対象の愁訴処置日時を取得する.
     * @param {*} state STATEオブジェクト
     * @returns {*} 編集対象の愁訴処置日時
     */
    getEditOccurDate(state) {
      return state.editOccurDate;
    },
    /**
     * 編集対象の愁訴処置データを取得する.
     * @param {*} state STATEオブジェクト
     * @return {ComplaintEdit} 編集対象の愁訴処置データ
     */
    getEditCompAndTreat(state) {
      return state.editCompAndTreat;
    },
    /**
     *
     * @param {*} state STATEオブジェクト
     */
    getEditSelectedCompAndTreat(state) {
      return state.editSelectedCompAndTreat;
    },
    // add FNSI-改修内容 心電図追加 房 start
    /**
     * 酸素吸入モデル（モーダル用）を取得する.
     * @param {*} state STATEオブジェクト
     */
    getElectrocardiogramModal(state) {
      return state.electrocardiogramModal;
    },

    // add FNSI-改修内容 心電図追加 房 end
    //add FNSI修正内容 愁訴処置の登録および表示修正 房 start
    getTempCtlNo(state) {
      return state.ctlNo;
    },
    //add FNSI修正内容 愁訴処置の登録および表示修正 房 end
    //add FNSI改修内容 愁訴処置編集修正 房 start
    /**
     * 編集中ctlNo取得
     * @param state
     * @returns {number}
     */
    getEditingCtlNo(state) {
      return state.editingCtlNo;
    },
    //add FNSI改修内容 愁訴処置編集修正 房 end
  }
};
