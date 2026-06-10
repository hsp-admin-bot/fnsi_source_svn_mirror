/**
 * 通知一覧用ストア
 */
import {
  sendRequestGetNotificationMessage,
  sendRequestGetNotificationMessageAll,
  // add FNSI redmine 4893 修正 鄧シン start
  sendRequestGetNotificationMessageForLogin,
  // del #10110 通知一覧から既読にした通知以外も消える dengshen start
  // sendRequestGetNotificationMessageAllAfterChange,
  // del #10110 通知一覧から既読にした通知以外も消える dengshen end
  // add FNSI redmine 4893 修正 鄧シン end
  sendRequestUpdateNotificationMessageStatus,
  // add FNSI-通知既読更新を修正 江 start
  sendRequestUpdateAllNotificationMessageisRead,
  // add FNSI-通知既読更新を修正 江 end
  sendRequestRegisterNotificationMessage
} from "@/apis/notification-message.js";
import { NotificationMessage } from "@/models/notification-message/NotificationMessage";

// 通知メッセージジャンプで既読：しない
const READ_ON_JUMP_NO = "0";
// 通知メッセージジャンプで既読：する
const READ_ON_JUMP_YES = "1";

export default {
  strict: true,
  namespaced: true,
  state: {
    /**
     * 新着メッセージ.
     */
    newMessages: [],
    /**
     * 未読件数.
     */
    unreadCount: 0,
    /**
     * 通知メッセージジャンプで既読.
     */
    readOnJump: READ_ON_JUMP_NO
  },
  mutations: {
    /**
     * 新着メッセージを設定する.
     * @param {*} state
     * @param {*} messages
     */
    setNewMessages(state, newMessages) {
      state.newMessages = newMessages;
    },
    /**
     * 未読件数を設定する.
     * @param {*} state stateオブジェクト
     * @param {Number} unreadCount 未読件数
     */
    setUnreadCount(state, unreadCount) {
      state.unreadCount = unreadCount;
    },
    /**
     * 通知メッセージジャンプで既読を設定する.
     * @param {*} state stateオブジェクト
     * @param {*} readOnJump 通知メッセージジャンプで既読
     */
    setReadOnJump(state, readOnJump) {
      state.readOnJump = readOnJump;
    }
  },
  actions: {
    /**
     * 通知取得（未通知）.
     *
     * @param {*} commit commitオブジェクト
     */
    getNotificationMessage({ commit }) {
      return sendRequestGetNotificationMessage().then(response => {
        commit("setUnreadCount", response.data.unread_cnt);
        commit("setReadOnJump", response.data.read_on_jump);
        commit(
          "setNewMessages",
          response.data.notification_list.map(e => new NotificationMessage(e))
        );
      });
    },
    // add bug 6531 修正 chen start
    /**
     * 通知取得（未通知）.
     *
     * @param {*} commit commitオブジェクト
     */
    getNotificationMessageForLogin({ commit }) {
      return sendRequestGetNotificationMessageForLogin().then(response => {
        commit("setUnreadCount", response.data.unread_cnt);
        commit("setReadOnJump", response.data.read_on_jump);
        commit(
          "setNewMessages",
          response.data.notification_list.map(e => new NotificationMessage(e))
        );
      });
    },
    // add bug 6531 修正 chen end
    /**
     * 通知取得（全件）.
     *
     * @param {*} commit commitオブジェクト
     */
    // mod FNSI-通知表示が遅いを修正 江 start
    // getNotificationMessageAll({ commit }) {
    getNotificationMessageAll({ commit }, payload) {
    // mod FNSI-通知表示が遅いを修正 江 end
      // mod FNSI-通知表示が遅いを修正 江 start
      // return sendRequestGetNotificationMessageAll().then(response => {
      return sendRequestGetNotificationMessageAll(payload).then(response => {
      // mod FNSI-通知表示が遅いを修正 江 end
        commit("setUnreadCount", response.data.unread_cnt);
        commit("setReadOnJump", response.data.read_on_jump);
        return response.data.notification_list.map(
          e => new NotificationMessage(e)
        );
      });
    },
    // del #10110 通知一覧から既読にした通知以外も消える dengshen start
    // // add FNSI redmine 4893 修正 鄧シン start
    // getNotificationMessageAllAfterChange({ commit }, payload) {
    //   return sendRequestGetNotificationMessageAllAfterChange(payload).then(response => {
    //     commit("setUnreadCount", response.data.unread_cnt);
    //     commit("setReadOnJump", response.data.read_on_jump);
    //     return response.data.notification_list.map(
    //       e => new NotificationMessage(e)
    //     );
    //   });
    // },
    // // add FNSI redmine 4893 修正 鄧シン end
    // del #10110 通知一覧から既読にした通知以外も消える dengshen end
    /**
     * 既読更新.
     *
     * @param {*} commit commitオブジェクト
     */
    updateAllNotificationMessageisRead({ commit }) {
      return sendRequestUpdateAllNotificationMessageisRead().then(
        response => {
          commit("setUnreadCount", response.data.unread_cnt);
          return response.data.unread_cnt;
        }
      );
    },
  	// add FNSI-通知既読更新を修正 江 end
    /**
     * 未読/既読更新.
     *
     * @param {*} commit commitオブジェクト
     * @param {*} payload 未読/既読情報
     */
    updateNotificationMessageStatus({ commit }, payload) {
      return sendRequestUpdateNotificationMessageStatus(payload).then(
        response => {
          commit("setUnreadCount", response.data.unread_cnt);
          return response.data.unread_cnt;
        }
      );
    },
    /**
     * 通知メッセージ登録.
     *
     * @param {*} commit commitオブジェクト
     * @param {*} payload 通知メッセージ情報
     */
    // TODO: 局所的なeslintの設定を削除する
    /* eslint-disable no-unused-vars */
    registerNotificationMessage({ commit }, payload) {
      return sendRequestRegisterNotificationMessage(payload);
    }
  },
  getters: {
    /**
     * 新着メッセージを取得する.
     * @param {*} state stateオブジェクト
     */
    getNewMessages(state) {
      return state.newMessages;
    },
    /**
     * 未読件数を取得する.
     * @param {*} state stateオブジェクト
     */
    getUnreadCount(state) {
      return state.unreadCount;
    },
    /**
     * 通知メッセージジャンプで既読を取得する.(true/false)
     * @param {*} state stateオブジェクト
     */
    isReadOnJump(state) {
      // add FNSI-画面遷移時通知既読 関 start
      if (state.readOnJump == "true") {
        state.readOnJump = "1";
      }
      else {
        state.readOnJump = "0";
      }
      // add FNSI-画面遷移時通知既読 関 end
      return state.readOnJump === READ_ON_JUMP_YES;
    }
  }
};
