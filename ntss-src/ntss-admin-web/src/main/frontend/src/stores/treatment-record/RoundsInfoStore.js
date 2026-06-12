/**
 * 治療記録 回診記録情報ストア
 */
import {
  sendRequestGetTreatmentRecordRstRoundsInfo
  , sendRequestUpdateTreatmentRecordRstRoundsInfo
} from "@/apis/treatment-record";

import { sendRequestGetRoundTypeNameAndContent } from "@/apis/round-type";

import { sendRequestGetDoctorsAtFacility } from "@/apis/facility";

import { sendRequestGetFixedPhrase } from "@/apis/mst-com-fixed-phrase";

import { sendUpdateIndComment } from "@/apis/ord-main";

export default {
  strict: true,
  namespaced: true,
  state: {
    roundTypes: [], // 種別
    selectedRoundType: null, // 選択された種別
    rstRoundsInfo: {
      toCompare: null, // 編集前
      inProgress: null // 編集中
    },
    rstIndComments: [], // 実績：指示コメント
    upDate: null  // 更新日時
  },
  getters: {
    roundTypes(state) {
      return state.roundTypes;
    },
    selectedRoundType(state) {
      return state.selectedRoundType;
    },
    rstRoundsInfoToCompare(state) {
      return state.rstRoundsInfo.toCompare;
    },
    rstRoundsInfoInProgress(state) {
      return state.rstRoundsInfo.inProgress;
    },
    isNewRoundInfo(state) {
      // add 9553 by kangjie 20230914 start
      if (state.rstRoundsInfo.toCompare == null){
        return !state.rstRoundsInfo.toCompare;
      }
      return !state.rstRoundsInfo.toCompare.updated_at || !state.rstRoundsInfo.toCompare.created_at;
      // add 9553 by kangjie 20230914 end
    },
    rstIndComments(state) {
      return state.rstIndComments;
    },
    unusedRstIndCommentNo(state) {
      // #10777 患者経過総合ビューアでの指示コメント追加時指示コメント番号に101以上の番号が設定可能 linjunfeng start
      // const baseList = [...Array(100).keys()].map(i => ++i);
      const baseList = [...Array(99).keys()].map(i => ++i);
      // #10777 患者経過総合ビューアでの指示コメント追加時指示コメント番号に101以上の番号が設定可能 linjunfeng end
      const usedNoList = state.rstIndComments.map(e => e.no);
      return baseList.filter(e => !usedNoList.includes(e));
    }
  },
  mutations: {
    /**
     * roundTypesを保存する。
     * @param {*} state ステートオブジェクト
     * @param {*} payload
     */
    saveRoundTypes(state, payload) {
      state.roundTypes = payload.roundTypes;
    },
    //add 9724-⑤ ljx start
    /**
     * roundTypesを保存する。
     * @param {*} state ステートオブジェクト
     * @param {*} payload
     */
    setRoundTypes(state, payload) {
      state.roundTypes = payload;
    },
    //add 9724-⑤ ljx end
    /**
     * selectedRoundTypeを保存する。
     * @param {*} state ステートオブジェクト
     * @param {*} payload
     */
    saveSelectedRoundType(state, payload) {
      state.selectedRoundType = payload.selectedRoundType;
    },
    /**
     * 比較用の実績：回診記録情報を保存する
     * @param {*} state 
     * @param {*} payload 
     */
    saveRstRoundsInfoToCompare(state, payload) {
      state.rstRoundsInfo.toCompare = payload;
    },
    /**
     * 入力用の実績：回診記録情報を保存する
     * @param {*} state 
     * @param {*} payload 
     */
    saveRstRoundsInfoInProgress(state, payload) {
      state.rstRoundsInfo.inProgress = payload;
    },
    /**
     * 実績：指示コメント情報を保存する
     * @param {*} state 
     * @param {*} payload 
     */
    saveRstIndComments(state, payload) {
      state.rstIndComments = payload.rstIndComments;
    },
    /**
     * 作成者と更新者を更新する
     * @param {*} state 
     * @param {*} payload 
     */
    saveCreatedAndUpdatedAndIndUser(state, payload) {
      state.rstRoundsInfo.inProgress.setCreatedAndUpdatedAndIndUser(
        payload.userId,
        payload.userFirstName,
        payload.userLastName
      );
    },
    /**
     * 更新日時を設定する.
     * @param {*} state stateオブジェクト
     * @param {*} upDate 更新日時
     */
    setUpDate(state, upDate) {
      state.upDate = upDate;
    }
  },
  actions: {
    /**
     * 実績：回診記録情報取得.
     *
     * @param {*} commit commitオブジェクト
     * @param {*} ordNo オーダ番号
     */
    // TODO: 局所的なeslintの設定を削除する
    getTreatmentRecordRstRoundsInfo({ commit }, payload) {
      const ordNo = payload && typeof payload === "object" ? payload.ordNo : payload;
      const selectedPatId = payload && typeof payload === "object" ? payload.selectedPatId : undefined;
      return sendRequestGetTreatmentRecordRstRoundsInfo(ordNo, selectedPatId).then(response => {
        commit("setUpDate", response.data.up_date);
        return response;
      });
    },
    /**
     * 実績：回診記録情報更新.
     *
     * @param {*} commit commitオブジェクト
     * @param {*} state stateオブジェクト
     * @param {*} ordNo オーダ番号
     */
    // TODO: 局所的なeslintの設定を削除する
    updateTreatmentRecordRstRoundsInfo({ commit, state }, payload) {
      return sendRequestUpdateTreatmentRecordRstRoundsInfo(
        payload.ordNo,
        {
          rst_rounds_info: payload.rstRoundsInfo,
          up_date: state.upDate
        }
      );
    },
    /**
     * 種別取得.
     *
     * @param {*} commit commitオブジェクト
     * @param {*} facilityCd 施設コード
     */
    // TODO: 局所的なeslintの設定を削除する
    getRoundTypeNameAndContent({ commit }, payload) {
      const facilityCd = payload && typeof payload === "object" ? payload.facilityCd : payload;
      const patId = payload && typeof payload === "object" ? payload.patId : undefined;
      const selectedPatId = payload && typeof payload === "object" ? payload.selectedPatId : undefined;
      return sendRequestGetRoundTypeNameAndContent(facilityCd, patId, selectedPatId);
    },
    /**
     * 医師取得.
     *
     * @param {*} commit commitオブジェクト
     * @param {*} facilityCd 施設コード
     */
    // TODO: 局所的なeslintの設定を削除する
    getDoctorsAtFacility({ commit }, payload) {
      const facilityCd = payload && typeof payload === "object" ? payload.facilityCd : payload;
      const selectedPatId = payload && typeof payload === "object" ? payload.selectedPatId : undefined;
      return sendRequestGetDoctorsAtFacility(facilityCd, selectedPatId);
    },
    /**
     * 定型文取得.
     *
     * @param {*} commit commitオブジェクト
     * @param {*} facilityCd 施設コード
     */
    // TODO: 局所的なeslintの設定を削除する
    getFixedPhrase({ commit }, payload) {
      const facilityCd = payload && typeof payload === "object" ? payload.facilityCd : payload;
      const selectedPatId = payload && typeof payload === "object" ? payload.selectedPatId : undefined;
      return sendRequestGetFixedPhrase(facilityCd, selectedPatId);
    },
    /**
     * 種別を取得し、Storeに保存する
     */
    async fetchRoundTypes({ commit }, payload) {
      const response = await sendRequestGetRoundTypeNameAndContent(
        payload.facilityCd,
        payload.patId,
        payload.selectedPatId
      );
      commit("saveRoundTypes", {
        roundTypes: response.data
      });
    },
    //add 9724-⑤ ljx start
    /**
     * roundTypesを保存する。
     * @param {*} commit commitオブジェクト
     * @param {*} payload
     */
    setRoundTypes({ commit }, payload) {
      commit("setRoundTypes", payload);
    },
    //add 9724-⑤ ljx end
    /**
     * 選択された種別をStoreに保存する
     */
    setSelectedRoundType({ commit }, payload) {
      commit("saveSelectedRoundType", payload);
    },
    /**
     * 比較用の実績：回診記録情報をStoreに保存する
     */
    setRstRoundsInfoToCompare({ commit }, payload) {
      commit("saveRstRoundsInfoToCompare", payload);
    },
    /**
     * 入力用の実績：回診記録情報をStoreに保存する
     */
    setRstRoundsInfoInProgress({ commit }, payload) {
      commit("saveRstRoundsInfoInProgress", payload);
    },
    /**
     * 実績：指示コメント情報をStoreに保存する
     */
    setRstIndComments({ commit }, payload) {
      commit("saveRstIndComments", payload);
    },
    /**
     * 指示：指示コメント更新(YED製API呼出し).
     *
     * @param {*} commit commitオブジェクト
     * @param {*} payload 指示コメント情報
     */
    updateIndComment({ commit }, payload) {
      return sendUpdateIndComment(payload);
    },
    /**
     * 作成者と更新者を更新する.
     */
    setCreatedAndUpdatedAndIndUserInProgress({ commit }, payload) {
      commit("saveCreatedAndUpdatedAndIndUser", payload);
    }
  }
};
