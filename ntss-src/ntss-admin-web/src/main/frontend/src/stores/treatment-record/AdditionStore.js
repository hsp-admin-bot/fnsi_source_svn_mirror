/**
 * 治療記録 指示コメントストア
 */
import {
  sendRequestGetTreatmentRecordAddition,
  sendRequestUpdateTreatmentRecordAddition
} from "@/apis/treatment-record";
import { sendUpdateIndComment } from "@/apis/ord-main";

export default {
  strict: true,
  namespaced: true,
  state: {
    /**
     * 指示コメントEntity情報.
     */
    commentInfo: null,
    /**
     * 指示コメント情報(Parse済)
     */
    rstIndCommentInfo: null,
    /**
     * 対象の指示コメント番号.
     */
    targetNo: null,
    /**
     * 更新日時.
     */
    upDate: null
  },
  mutations: {
    /**
     * 指示コメントEntity情報を設定する.
     * @param {*} state stateオブジェクト
     * @param {Object} commentInfo 指示コメントEntity情報
     */
    setCommentInfo(state, commentInfo) {
      state.commentInfo = commentInfo;
      /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --start */
      // const rstIndCommentInfo = JSON.parse(commentInfo.rst_ind_comment_info);
      // state.rstIndCommentInfo = rstIndCommentInfo ? rstIndCommentInfo : [];
      state.rstIndCommentInfo = (commentInfo && commentInfo.rst_ind_comment_info)
          ? JSON.parse(commentInfo.rst_ind_comment_info) : [];
      /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --end */
    },
    /**
     * 指示コメント番号を設定する.
     * @param {*} state stateオブジェクト
     * @param {Number} targetNo 指示コメント番号
     */
    setTargetNo(state, targetNo) {
      state.targetNo = targetNo;
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
     * 指示コメントEntity情報を設定する.
     * @param {*} commit commitオブジェクト
     * @param {Object} commentInfo 指示コメントEntity情報
     */
    setCommentInfo({ commit }, commentInfo) {
      commit("setCommentInfo", commentInfo);
    },
    /**
     * 指示コメント番号を設定する.
     * @param {*} commit commitオブジェクト
     * @param {Number} targetNo 指示コメント番号
     */
    setTargetNo({ commit }, targetNo) {
      commit("setTargetNo", targetNo);
    },
    /**
     * 指示コメント取得.
     *
     * @param {*} commit commitオブジェクト
     * @param {*} ordNo オーダ番号
     */
    // TODO: 局所的なeslintの設定を削除する
    /* eslint-disable no-unused-vars */
    getTreatmentRecordAddition({ commit }, ordNo) {
      return sendRequestGetTreatmentRecordAddition(ordNo).then(response => {
        commit("setUpDate", response.data.up_date);
        return response;
      });
    },
    /**
     * 実績：指示コメント更新.
     *
     * @param {*} commit commitオブジェクト
     * @param {*} state stateオブジェクト
     * @param {*} ordNo オーダ番号
     * @param {*} payload 指示コメント情報
     */
    // TODO: 局所的なeslintの設定を削除する
    /* eslint-disable no-unused-vars */
    updateTreatmentRecordAddition({ commit, state }, { ordNo, payload }) {
      return sendRequestUpdateTreatmentRecordAddition(
        ordNo,
        {
          ...payload,
          up_date: state.upDate
        }
      );
    },
    /**
     * 指示：指示コメント更新.
     *
     * @param {*} commit commitオブジェクト
     * @param {*} payload 指示コメント情報
     */
    // TODO: 局所的なeslintの設定を削除する
    /* eslint-disable no-unused-vars */
    updateIndComment({ commit }, payload) {
      return sendUpdateIndComment(payload);
    }
  },
  getters: {
    /**
     * 入力対象が新規なのか、編集なのかを判定する.
     * @param {*} state stateオブジェクト
     */
    isNew(state) {
      return state.targetNo === null;
    },
    /**
     * 指示コメントEntity情報を取得する.
     * @param {*} state stateオブジェクト
     */
    getCommentInfo(state) {
      return state.commentInfo;
    },
    /**
     * 指示コメント情報を取得する.
     * @param {*} state stateオブジェクト
     */
    getRstIndCommentInfo(state) {
      return state.rstIndCommentInfo;
    },
    /**
     * 指示コメント番号を取得する.
     * @param {*} state stateオブジェクト
     */
    getTargetNo(state) {
      return state.targetNo;
    },
    /**
     * 未使用のコメント番号リストを取得する.
     * @param {*} state stateオブジェクト
     */
    getUnusedCommentNoList(state) {
      // #10777 患者経過総合ビューアでの指示コメント追加時指示コメント番号に101以上の番号が設定可能 linjunfeng start
      // const baseList = [...Array(100).keys()].map(i => ++i);
      const baseList = [...Array(99).keys()].map(i => ++i);
      // #10777 患者経過総合ビューアでの指示コメント追加時指示コメント番号に101以上の番号が設定可能 linjunfeng end
      const usedNoList = state.rstIndCommentInfo.map(e => e.no);
      return baseList.filter(e => !usedNoList.includes(e));
    }
  }
};
