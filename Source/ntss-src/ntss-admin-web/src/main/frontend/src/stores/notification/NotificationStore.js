/**
 * Push通知用ストア
 */
import { ApiHelper } from "@/apis/AxiosHelper";

export default {
  namespaced: true,
  strict: true,

  state: {
    // 通知の登録状況
    isRegisteredNotification: false
  },

  mutations: {
    // 通知の登録状況を格納
    setIsRegisteredNotification(state, isRegisteredNotification) {
      state.isRegisteredNotification = isRegisteredNotification;
    }
  },

  getters: {
    // 通知の登録状況取得
    getIsRegisteredNotification(state) {
      return state.isRegisteredNotification;
    }
  },

  actions: {
    // DBから取得したデータを元に通知の登録状況をセット
    // sys_notification_listにレコードがあれば通知可
        async setIsRegisteredNotificationFromDb({ commit, rootGetters }, payload) {
      const terminalUniqueString =
        typeof payload === "string" ? payload : payload?.terminalUniqueString;

      if (!terminalUniqueString) {
        commit("setIsRegisteredNotification", false);
        return;
      }

      // 端末固有IDを指定して宛先情報が存在しているか確認
      await ApiHelper.put(`/send-push/pushSearch/${terminalUniqueString}`)
        .then(response => {
          const flag = response.data.length >= 1;
          commit("setIsRegisteredNotification", flag);
        })
        .catch(error => {
          commit("setIsRegisteredNotification", false);
          throw error;
        });
    }
  }
};
