// del FNSI-4200ポートを使用している 孫 start
//const URL = "ws://localhost:4200";
// del FNSI-4200ポートを使用している 孫 end
import { getScopedLocalStorage, getScopedWindow } from "@/functions/common/LayoutMeasureHelper";


export default {
  strict: true,
  namespaced: true,
  state: {
    // add FNSI-4200ポートを使用している 孫 start
    port: "",
    cardAppPort: null,
    // add FNSI-4200ポートを使用している 孫 end
    facilityCd: "",
    socket: null,
    socketInfo: {
      isConnected: null,
      messages: [],
      reconnectError: false,
      isError: false,
      eventInfo: null
    },
    timerAction: null,
    dtLastReceived: new Date(),
    notifyMessages: null,
    // mod FNSI-4200ポートを使用している 孫 start
    // cardDeviceStatus: false
    cardDeviceStatus: null
    // mod FNSI-4200ポートを使用している 孫 end
  },
  getters: {
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

    getCardDeviceStatus: state => state.cardDeviceStatus
  },
  actions: {
    // add FNSI-4200ポートを使用している 孫 start
    /**
     * 接続先設定
     * @param {Object} context
     * @param {Object} payload
     * @param {String} payload.port 接続先port
     * @param {String} payload.facilityCd 施設コード
     */
    init({ state, commit }, payload) {
      if (state.socket === null) {
        commit("SOCKET_INIT", payload);
      }
    },
    // mod FNSI-4200ポートを使用している 孫 end
    /**
     * WebSocket接続処理
     * @param {Object} context
     */
    connect({ state, commit }) {
      if (state.socket === null) {
        // mod FNSI-4200ポートを使用している 孫 start
          //const socket = new WebSocket(URL);

        let url = "ws://localhost:" + state.cardAppPort;
        // CARD APP PORTが無し場合
        if (state.cardAppPort === null) {
          url = "ws://localhost:" + state.port;
        }
        const scopedWindow = getScopedWindow();
        const WebSocketCtor = scopedWindow?.WebSocket || WebSocket;
        const socket = new WebSocketCtor(url);
        // mod FNSI-4200ポートを使用している 孫 end
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
    sendSocketMessage({ state }, content) {
      var strSplit = content.split("-");
      if (state.socketInfo.isConnected) {
        state.socket.send("BROWSER\t" + strSplit[0] + "\t" + strSplit[1] + "-" + strSplit[2]);
      }
    },
    clearSocketMessage({ state }) {
      state.notifyMessages = null;
    }
  },
  mutations: {
    // add FNSI-4200ポートを使用している 孫 start
    SOCKET_INIT(state, payload) {
      state.port = payload.port;
      state.facilityCd = payload.facilityCd;
    },
    // add FNSI-4200ポートを使用している 孫 end
    SOCKET_ONOPEN(state, payload) {
      state.socketInfo.isConnected = true;
      state.socketInfo.isError = false;
      state.socketInfo.eventInfo = payload.event;
      state.socket = payload.socket;
      state.dtLastReceived = new Date();

      state.socket.send("BROWSER\tCARD_READER_STATUS");
      // del FNSI-4200ポートを使用している 孫 start
      // 30秒ごとに死活監視用の空文字を通知する
      // state.timerAction = setInterval(() => {
      //   try {
      //     // 接続確認確認実施
      //     state.socket.send(" ");
      //   } catch (e) {
      //     state.socket.close();
      //   }
      //   // 現在日時取得
      //   /** @type {Date} */
      //   let now = new Date();
      //
      //   // 最終受信日時からの秒数算出
      //   let sec = (now - state.dtLastReceived) / 1000;
      //   // 60秒間受信がない場合
      //   if (60 <= sec) {
      //     // エラーと判断してWebSocketを切断する
      //
      //     // タイマー終了
      //     clearInterval(state.timerAction);
      //
      //     // 切断実施
      //     state.socket.close();
      //   }
      // }, 30000);
      // del FNSI-4200ポートを使用している 孫 end

    },
    SOCKET_ONCLOSE(state, event) {
      state.socketInfo.isConnected = false;
      state.socketInfo.eventInfo = event;
      state.notifyMessages = null;
      state.socket = null;
      // タイマー終了
      const scopedWindow = getScopedWindow();
      (scopedWindow?.clearInterval || clearInterval)(state.timerAction);
    },
    SOCKET_ONERROR(state, event) {
      state.socketInfo.isError = true;
      state.socketInfo.eventInfo = event;
    },
    SOCKET_ONMESSAGE(state, message) {
      state.dtLastReceived = new Date();
      state.notifyMessages = message;
      if (message == null) return;

      const splitMsg = message.split("\t");
      if (splitMsg.length > 1) {
        if (splitMsg[0] == "CARD_CLIENT") {
          if (splitMsg[1] == "CARD_READER_STATUS") {
              // add FNSI-4200ポートを使用している 孫 start
              // localStorageにportを設定する
              state.cardAppPort = splitMsg[3];
              getScopedLocalStorage().setItem("CARD_APP_PORT", splitMsg[3]);
              // add FNSI-4200ポートを使用している 孫 end
              state.cardDeviceStatus = JSON.parse(
                splitMsg[2].toLowerCase()
              );
          }
        }
      }
    }
  }
};
