//@ts-check

/**
 * WebSocket通知受信用Store
 * 0. fetchConnectUrl() で接続先URLを取得しておく
 * 1. init({url:接続先, facilityCd: 施設コード}) で初期設定する
 * 2. connect() で接続する
 * 3. addWatchTopics({topic: 取得するトピック文字列, obj: 格納先となるarrayオブジェクト}) で監視対象を登録する
 * 4. 格納先のlengthなどを監視し、受信を検知したら各々が処理をする
 *    その際、dequeueMessage(トピック文字列) を使用すると格納先arrayから先頭の1件を返し、格納先から削除する
 * 5. removeWatchTopics(トピック文字列) で監視を終了する
 * 6. close() を呼ぶと接続を終了する
 */

import {
  sendRequestGetWebsocketCert,
  sendRequestGetWebsocketUrl
// @ts-ignore
} from "@/apis/websocket-cert";
import Vue from "vue";
import { LOCAL_STORAGE_KEY } from "@/constants/localStorageConstants";
import { READYSTATE } from "@/constants/websocketConstants";

export default {
  strict: true,
  namespaced: true,
  state: {
    url: "",
    facilityCd: "",
    socket: null,
    socketInfo: {
      isConnected: false,
      messages: [],
      reconnectError: false,
      isError: false,
      eventInfo: null
    },
    timerAction: null,
    dtLastReceived: new Date(),
    watchTopics: [],
    notifyMessages: {},
    toastDuration: 10,
  },
  getters: {
    /**
     * ソケット接続先URL
     */
    getUrl: state => state.url,
    /**
     * ソケット
     */
    getSocket: state => state.socket,
    /**
     * ソケット接続状態
     */
    getSocketIsConnected: state => state.socketInfo.isConnected,
    /**
     * 受信メッセージオブジェクト
     */
    getSocketMessages: state => state.notifyMessages,
    /**
     * ソケットエラー有無
     */
    getSocketIsError: state => state.socketInfo.isError,
    /**
     * 再接続処理エラー
     */
    getSocketReconnectError: state => state.socketInfo.reconnectError,
    /**
     * 接続中WebSocketの発生イベント情報
     */
    getSocketEventInfo: state => state.socketInfo.eventInfo,
    /**
     * 特定のキー情報の受信済みデータサイズを取得
     */
    getSocketMessageLength: state => key => {
      if (
        state.notifyMessages[key] !== undefined &&
        state.notifyMessages[key] !== null
      ) {
        return state.notifyMessages[key].length;
      }
      return -1;
    },
    /**
     * トースト通知表示時間
     */
    getToastDuration: state => state.toastDuration,
  },
  actions: {
    /**
     * 接続先URL取得
     */
    fetchConnectUrl({state, commit}, facilityCd) {
      return sendRequestGetWebsocketUrl(facilityCd);
    },

    /**
     * 接続先設定
     * @param {Object} context
     * @param {Object} payload
     * @param {String} payload.url 接続先url
     * @param {String} payload.facilityCd 施設コード
     */
    init({ state, commit }, payload) {
      if (state.socket === null && state.url === "") {
        commit("SOCKET_INIT", payload);
      }
    },
    /**
     * WebSocket接続処理
     * @param {Object} context
     */
    connect({ state, commit }) {
      if (state.socket === null) {
        const socket = new WebSocket(state.url);
        socket.onopen = event => {
          commit("SOCKET_ONOPEN", { socket: socket, event: event });
        };
        socket.onclose = event => {
          commit("SOCKET_ONCLOSE", event);
        };
        socket.onmessage = event => {
          commit("SOCKET_ONMESSAGE", event.data);
        };
        socket.onerror = event => {
          commit("SOCKET_ONERROR", event);
        };
        commit("setSocketObj", socket);
      }
    },
    /**
     * WebSocket切断処理
     * @param {Object} context
     */
    close({ state }) {
      if (state.socketInfo.isConnected) {
        state.socket.close();
      }
    },
    /**
     * 取得するトピックを追加
     * @param {Object} context
     * @param {Object} payload
     * @param {Array} payload.obj 受信データの格納先
     * @param {String} payload.topic 取得トピック
     */
    addWatchTopics({ state, commit }, payload) {
      if (state.watchTopics.find(e => e === payload.topic) === undefined) {
        commit("ADD_TOPIC", payload);
      }
    },
    /**
     * 取得するトピックを削除
     * @param {Object} context
     * @param {String} topic 取得トピック
     */
    removeWatchTopics({ state, commit }, topic) {
      if (state.watchTopics.find(e => e === topic) !== undefined) {
        commit("REMOVE_TOPIC", topic);
      }
    },
    /**
     * 指定したトピックの受信キューから先頭を取得
     * @param {Object} context
     * @param {String} topic 取得トピック
     */
    dequeueMessage({ state, commit }, topic) {
      let msg = null;
      if (
        state.notifyMessages[topic] !== undefined &&
        state.notifyMessages[topic] !== null &&
        state.notifyMessages[topic].length > 0
      ) {
        msg = state.notifyMessages[topic][0];
        commit("SOCKET_DEQUEUE_MESSAGE", topic);
      }
      return msg;
    },
    /**
     * キューから特定の値を削除
     * 同じ値が複数あるとすべて消えるので注意
     * @param {Object} context
     * @param {Array} payload.value 削除したい値
     * @param {String} payload.topic 取得トピック
     */
    removeMessage({ commit }, payload) {
      commit("SOCKET_REMOVE_MESSAGE", payload);
    },
    /**
     * 指定したトピックの受信キューからすべて取得
     * @param {Object} context
     * @param {String} topic 取得トピック
     */
    getSocketAllMessages({ state }, topic) {
      if (
        state.notifyMessages[topic] !== undefined &&
        state.notifyMessages[topic] !== null
      ) {
        return state.notifyMessages[topic];
      }
      return [];
    }
  },
  mutations: {
    SOCKET_INIT(state, payload) {
      state.url = payload.url;
      state.facilityCd = payload.facilityCd;
    },
    SOCKET_ONOPEN(state, payload) {
      // 接続状態が異常でもONOPENが発火する場合がある為、接続状態を確認してから以降の処理を実施する
      if (payload.socket.readyState !== READYSTATE.OPEN) {
        return;
      }
      state.socketInfo.isConnected = true;
      state.socketInfo.isError = false;
      state.socketInfo.eventInfo = payload.event;
      state.socket = payload.socket;
      state.dtLastReceived = new Date();
      // console.log("socket isConnected");

      // セキュリティ認証キーの取得と登録
      sendRequestGetWebsocketCert({ facilityCd: state.facilityCd }).then(r => {
        // console.log("WebSocket認証キー取得 %o", `NTSS@${r.data}BROWSER${localStorage.getItem(LOCAL_STORAGE_KEY.TERMINAL_UNIQUE_STRING)}`);
        state.socket.send(`NTSS@${r.data}BROWSER${localStorage.getItem(LOCAL_STORAGE_KEY.TERMINAL_UNIQUE_STRING)}`);

        // 30秒ごとに死活監視用の空文字を通知する
        state.timerAction = setInterval(() => {
          try {
            // 接続確認確認実施
            state.socket.send(" ");
          } catch (e) {
            state.socket.close();
          }
          // 現在日時取得
          /** @type {Date} */
          let now = new Date();

          // 最終受信日時からの秒数算出
          let sec = (now - state.dtLastReceived) / 1000;
          // 60秒間受信がない場合
          if (60 <= sec) {
            // エラーと判断してWebSocketを切断する

            // タイマー終了
            clearInterval(state.timerAction);

            // 切断実施
            state.socket.close();
          }
        }, 30000);
      })
      .catch(() => {
        // 認証キー取得に失敗した場合はWebScoket接続をcloseする
        state.socket.close();
      });
    },
    SOCKET_ONCLOSE(state, event) {
      state.socketInfo.isConnected = false;
      state.socketInfo.isError = false;
      state.socketInfo.eventInfo = event;
      state.socket = null;
      // タイマー終了
      clearInterval(state.timerAction);
    },
    SOCKET_ONERROR(state, event) {
      // WebSocket接続が、データの一部が送信できなかったなどのエラーのために「閉じた」場合に呼ばれる
      state.socketInfo.isError = true;
      state.socketInfo.eventInfo = event;
    },
    ADD_TOPIC(state, param) {
      state.watchTopics.push(param.topic);
      Vue.set(state.notifyMessages, param.topic, param.obj);
    },
    REMOVE_TOPIC(state, topic) {
      const newArray = state.watchTopics.filter(e => e !== topic);
      state.watchTopics = newArray;
      Vue.set(state.notifyMessages, topic, []);
    },
    SOCKET_REMOVE_MESSAGE(state, payload) {
      const newArray = state.notifyMessages[payload.topic].filter(
        e => e !== payload.value
      );
      Vue.set(state.notifyMessages, payload.topic, newArray);
    },
    SOCKET_DEQUEUE_MESSAGE(state, topic) {
      state.notifyMessages[topic].shift();
    },
    SOCKET_ONMESSAGE(state, message) {
      state.dtLastReceived = new Date();

      // 受信メッセージをタブ区切りする
      const splitMsg = message.split("\t");
      if (splitMsg.length > 1) {
        // 受信対象トピックならば受信メッセージキューに格納する
        state.watchTopics.forEach(value => {
          if (splitMsg[0].startsWith(value)) {
            if (state.notifyMessages[value] === undefined) {
              state.notifyMessages[value] = [];
            }
            state.notifyMessages[value].push(splitMsg[1]);
          }
        });
      }
    },
    setSocketObj(state, socket) {
      state.socket = socket;
    },
    setToastDuration(state, toastDuration) {
      state.toastDuration = toastDuration;
    },
  }
};
