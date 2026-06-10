/**
 * 治療状況リスト大画面表示用ストア
 */

import { sendRequestGetEntryList } from "@/apis/status-list";
import { sendRequestGetMstFacilitySettingValue } from "@/apis/facility-setting";
import moment from "moment";
import { DISP_CHARGE1_NOTSET, DISP_CHARGE2_NOTSET } from "@/constants/facilitySetting";

// state
const state = {
  patListBeforeTreat: [],
  patListNowTreat: [],
  patListAfterTreat: [],
  cntPuncWait: 0,
  cntReturnWait: 0,
  info: [],
  isDispCharge1NotSet: true,
  isDispCharge2NotSet: true,
  // 強制サインアウトフラグ (0:自動サインアウトする、1:自動サインアウトしない)
  forceSignOutFlag: 0,
};

// actions
const actions = {
  fetchEntryList(context, param) {
    return sendRequestGetEntryList(param);
  },
  setDispData({ commit }, param) {
    // 表示一覧データの共通部分作成
    const makePatName = item => {
      const lastName = (item.patLastName && item.patLastName.trim() !== "") ? item.patLastName : " ";
      const firstName = (item.patFirstName && item.patFirstName.trim() !== "") ? item.patFirstName : " ";
      return `${lastName} ${firstName}`;
    };
    const setCommonValue = item => {
      item.patName = item.patId ? makePatName(item) : "？？？？";
      item.examScheDispFlg = item.hasExamSche ? "block" : "none";
      item.mediDoneDispFlg = item.isMediDone ? "none" : "block";
      item.isHospitalization = item.inOutClass == 1 ? "block" : "none";
      item.bpMeasureNotDone = !item.isBpMeasure;
      item.isBefore = false;
      item.isNow = false;
      item.isAfter = false;
    };
    const formatDispTime = value => value ? moment(value).format("H:mm") : "--:--";

    // 透析前
    const beforeRtnList = [];
    for (const item of param.patList_mode0) {
      setCommonValue(item);
      item.dispTime = formatDispTime(item.weightBeforeDate);
      item.mode = 0;
      item.isBefore = true;
      item.indicator1 = item.isPunc1Done;
      item.indicator2 = item.isPunc2Done;
      beforeRtnList.push(item);
    }

    // 透析中
    const nowRtnList = [];
    for (const item of param.patList_mode1) {
      setCommonValue(item);
      item.dispTime = formatDispTime(item.endDatePlan);
      item.mode = 1;
      item.isNow = true;
      item.indicator1 = false;
      item.indicator2 = false;
      nowRtnList.push(item);
    }

    // 透析後
    const afterRtnList = [];
    for (const item of param.patList_mode2) {
      setCommonValue(item);
      item.dispTime = formatDispTime(item.endDate);
      item.mode = 2;
      item.isAfter = true;
      item.indicator1 = item.isReturn1Done;
      item.indicator2 = item.isReturn2Done;
      afterRtnList.push(item);
    }

    commit("receiveDispData", {
      patList_mode0: beforeRtnList,
      patList_mode1: nowRtnList,
      patList_mode2: afterRtnList,
      cntPuncWait: param.cntPuncWait,
      cntReturnWait: param.cntReturnWait,
      info: param.info,
    });
  },  
  setIsDispCharge1NotSet({ commit }, facilityCd) {
    return sendRequestGetMstFacilitySettingValue(
      facilityCd,
      DISP_CHARGE1_NOTSET
    ).then(response => {
      commit("setIsDispCharge1NotSet", response.data === 1);
    });
  },
  setIsDispCharge2NotSet({ commit }, facilityCd) {
    return sendRequestGetMstFacilitySettingValue(
      facilityCd,
      DISP_CHARGE2_NOTSET
    ).then(response => {
      commit("setIsDispCharge2NotSet", response.data === 1);
    });
  },
  // -----------------------------------------
  // 強制サインアウトフラグ設定
  // -----------------------------------------
  setForceSignOutFlag({ commit }, forceSignOutFlag) {
    commit("setForceSignOutFlag", forceSignOutFlag);
  },
};

// mutations
const mutations = {
  receiveDispData(state, payload) {
    state.patListBeforeTreat = payload.patList_mode0;
    state.patListNowTreat = payload.patList_mode1;
    state.patListAfterTreat = payload.patList_mode2;
    state.cntPuncWait = payload.cntPuncWait;
    state.cntReturnWait = payload.cntReturnWait;
    state.info = payload.info;
  },
  // ナビゲーションバー担当者１未入力表示を格納
  setIsDispCharge1NotSet(state, isDispCharge1NotSet) {
    state.isDispCharge1NotSet = isDispCharge1NotSet;
  },
  // ナビゲーションバー担当者２未入力表示を格納
  setIsDispCharge2NotSet(state, isDispCharge2NotSet) {
    state.isDispCharge2NotSet = isDispCharge2NotSet;
  },
  setForceSignOutFlag(state, forceSignOutFlag) {
    state.forceSignOutFlag = forceSignOutFlag;
  },
};
// getters
const getters = {
  beforeTreatList: state => state.patListBeforeTreat,
  nowTreatList: state => state.patListNowTreat,
  afterTreatList: state => state.patListAfterTreat,
  cntPuncWait: state => state.cntPuncWait,
  cntReturnWait: state => state.cntReturnWait,
  getInfo: state => state.info,
  getIsDispCharge1NotSet: state => state.isDispCharge1NotSet,
  getIsDispCharge2NotSet: state => state.isDispCharge2NotSet,
  getForceSignOutFlag: state => state.forceSignOutFlag,
};

export default {
  namespaced: true,
  state,
  actions,
  mutations,
  getters
};
