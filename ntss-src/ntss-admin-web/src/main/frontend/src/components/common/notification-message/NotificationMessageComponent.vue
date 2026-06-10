/**
 * 通知メッセージ表示コンポーネント
 */
<template>
  <notifications
    group="message"
    position="top right"
    animation-name="notification-animation"
    v-if="isLoggedIn && !isWeightMode"
  >
    <template slot="body" slot-scope="props">
      <!-- mod FNSI-bug #4115「重要通知トーストのレイアウト不正」の不具合修正 start-->
      <!-- <div class="notification-message"> -->
      <div :class="props.item.data.message.isImportant ? 'important-message' : 'notification-message'">
      <!-- mod FNSI-bug #4115「重要通知トーストのレイアウト不正」の不具合修正 end-->
        <div class="content-area" @click="showNotificationMessage(), props.close()">
          <!-- FNSI-「通知トーストに重要通知である旨が表示されない」の不具合修正 江 start -->
          <!-- <div>{{ props.item.data.message.displayRegDate }}</div> -->
          <div>{{ props.item.data.message.displayRegDate }}&nbsp;&nbsp;<i v-if="props.item.data.message.isImportant" class="important-i">重要</i>
            <!-- add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 江 start -->
            <img v-if="props.item.data.message.isSame" class='same-icon' :src="image_src_same" />
            <!-- add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 江 end -->
          </div>
          <!-- FNSI-「通知トーストに重要通知である旨が表示されない」の不具合修正 江 end -->
          <div>
            <p>
              <template v-for="(item, index) in props.item.text">
                <span :key="index">
                  {{ item + (index === 2 && props.item.text.length > 3 ? " ..." : "") }}
                  <br>
                </span>
              </template>
            </p>
          </div>
        </div>
        <div class="button-area">
          <!-- mod FNSi6960通知の件数が残ったままになる chen start -->
          <!-- <div @click="props.close"> -->
          <div @click="onClose(props.item.data.message, props)">
          <!-- mod FNSi6960通知の件数が残ったままになる chen end -->
          <!-- #9190 通知の閉じるアイコンと、機能遷移アイコンが存在しない。start 訾浩 -->
            <i class="icon ion-ios-close"></i>
          </div>
          <div
            v-show="props.item.data.message.additionalInfo"
            @click="onForward(props.item.data.message, props.close)"
          >
            <i class="icon ion-ios-redo"></i>
            <!--#9190 通知の閉じるアイコンと、機能遷移アイコンが存在しない。end 訾浩 -->
          </div>
        </div>
      </div>
    </template>
  </notifications>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import NotificationMessageMixin from "@/components/common/notification-message/NotificationMessageMixin";
import { NOTIFY_TOPIC_NOTIFICATION_MESSAGE, NOTIFY_TOPIC_FORCE_SIGNOUT } from "@/constants/websocketNotifyTopic";
import { LOCAL_STORAGE_KEY } from "@/constants/localStorageConstants";
// add FNSI-コードをマージ 江 start
import { WS_RECONNECT_INTERVAL, READYSTATE } from "@/constants/websocketConstants";
// add FNSI-コードをマージ 江 end

export default {
  mixins: [NotificationMessageMixin],
  data() {
    return {
      notifyTopic: NOTIFY_TOPIC_NOTIFICATION_MESSAGE,
      notifyValue: [],
      forceSignoutValue: [],
      enableWsConnect: false,
      // add FNSI-コードをマージ 江 start
      // WebSocket接続管理用setInterval
      webSocketConnectionManageProc: null,
      // 内部接続処理中flg
      connectingFlg: false,
      // add FNSI-コードをマージ 江 end
      // add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 江 start
      // 同姓同名アイコン
      image_src_same: require('../../../assets/name_duplication3.png'),
      // add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 江 end
    };
  },
  computed: {
    ...mapGetters("notification-message", ["getNewMessages"]),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("user", ["getFacilityCd", "getUserId"]),
    // add FNSI-体重計測定レイアウト調整 徐博 start
    ...mapGetters("send-condition/weight", ["getWeightMode"]),
    // add FNSI-体重計測定レイアウト調整 徐博 end
    // mod FNSI-コードをマージ 江 start
    // ...mapGetters("websocket", ["getSocketIsConnected"]),
    ...mapGetters("websocket", ["getUrl", "getSocket", "getToastDuration"]),
    // mod FNSI-コードをマージ 江 end
    isLoggedIn() {
      // add 7071 【デグレ】通知がされない 関俊楠 start
      if (this.getStateUserAccountInfo !== null) {
        clearInterval(this.webSocketConnectionManageProc);
        this.connectingFlg = true;
        this.webSocketConnect();
        // 初回接続後にWebSocketの接続/切断を監視する
        this.webSocketConnectionManageProc = setInterval(() => {
          // サインイン画面以外且つ、サインイン済み
          if (!(this.$router.currentRoute.name === "signin" || this.$router.currentRoute.name === "signinhome") && this.isLoggedIn) {
            // WebSocket切断状態且つ、接続処理中でない場合
            if (!this.getSocket && !this.connectingFlg) {
              // 接続処理開始
              this.connectingFlg = true;
              setTimeout(() => {
                if (!this.getUrl) {
                  // リロードされた場合は、WebSocket接続先URLが消える為、URL取得から開始する
                  this.webSocketConnect();
                } else {
                  this.connect();
                  this.connectingFlg = false;
                }
              }, WS_RECONNECT_INTERVAL - 1000);
            }
          } else if (this.$router.currentRoute.name === "signin" || this.$router.currentRoute.name === "signinhome") {
            // サインイン画面表示時、WebSocket接続中の場合は切断する
            if (this.getSocket && this.getSocket.readyState === READYSTATE.OPEN) {
              this.close();
            }
          }
        }, 1000);
        // add 7071 【デグレ】通知がされない 関俊楠 start
      }
      // ユーザ情報取得未済の場合、falseを返す
      return this.getStateUserAccountInfo !== null;
    },
    isWeightMode() {
      return this.getWeightMode.isWeightMode;
    }
  },
  watch: {
    /**
     * 新着メッセージ監視.
     */
    getNewMessages(messages) {
      this.$nextTick(() => {
        messages.forEach(message => {
          // メッセージ本文が4行以上の場合は先頭3行に丸める
          const lines = message.content.trim().split("\n");
          // const content =
          //   lines.slice(0, 3).join("<br>") + (lines.length > 3 ? " ..." : "");

          this.$notify({
            group: "message",
            text: lines,
            data: {
              message: message
            },
            speed: 200,
            duration: this.getToastDuration * 1000 // NOTE: 「秒⇒ミリ秒」変換
          });
        });
      });
    },
    /**
     * サインイン/サインアウト監視.
     */
    isLoggedIn(newValue) {
      if (newValue) {
        // add FNSI-コードをマージ 江 start
        clearInterval(this.webSocketConnectionManageProc);
        this.connectingFlg = true;
        // add FNSI-コードをマージ 江 end
        // WebSocket接続
        // mod FNSI-コードをマージ 江 start
        // this.fetchConnectUrl().then(r => {
        //   this.init({ url: r.data, facilityCd: this.getFacilityCd });
        //   this.enableWsConnect = true;
        //   this.connect();

        //   this.notifyTopic = `${NOTIFY_TOPIC_NOTIFICATION_MESSAGE}/${this.getFacilityCd}`;
        //   this.addWatchTopics({
        //     topic: this.notifyTopic,
        //     obj: this.notifyValue
        //   });
        // });
        this.webSocketConnect();
        // 初回接続後にWebSocketの接続/切断を監視する
        this.webSocketConnectionManageProc = setInterval(() => {
          // サインイン画面以外且つ、サインイン済み
          if (!(this.$router.currentRoute.name === "signin" || this.$router.currentRoute.name === "signinhome") && this.isLoggedIn) {
            // WebSocket切断状態且つ、接続処理中でない場合
            if (!this.getSocket && !this.connectingFlg) {
              // 接続処理開始
              this.connectingFlg = true;
              setTimeout(() => {
                if (!this.getUrl) {
                  // リロードされた場合は、WebSocket接続先URLが消える為、URL取得から開始する
                  this.webSocketConnect();
                } else {
                  this.connect();
                  this.connectingFlg = false;
                }
              }, WS_RECONNECT_INTERVAL - 1000);
            }
          } else if (this.$router.currentRoute.name === "signin" || this.$router.currentRoute.name === "signinhome") {
            // サインイン画面表示時、WebSocket接続中の場合は切断する
            if (this.getSocket && this.getSocket.readyState === READYSTATE.OPEN) {
              this.close();
            }
          }
        }, 1000);
        // mod FNSI-コードをマージ 江 end
      } else {
        // WebSocket切断
        // add FNSI-コードをマージ 江 start
        // console.log("NotificationMessageComponent WebSocket接続切断 %o", new Date());
        // add FNSI-コードをマージ 江 end
        this.enableWsConnect = false;
        this.close();

        this.removeWatchTopics(this.notifyTopic);
      }
    },
    // del FNSI-コードをマージ 江 start
    // /**
    //  * WebSocket接続監視
    //  */
    // getSocketIsConnected(newValue) {
    //   if (!newValue && this.enableWsConnect) {
    //     // 切断された場合、再接続
    //     this.connect();
    //   }
    // },
    // del FNSI-コードをマージ 江 end
    /**
     * WebSocket通知監視
     */
    "notifyValue.length"(newValue) {
      if (newValue > 0) {
        this.dequeueMessage(this.notifyTopic);

        // 新着通知取得
        this.getNotificationMessage();
      }
    },
    /**
     * 強制サインアウト通知監視
     * payload形式:
     *   "userId"                    → 権限縮小による強制サインアウト（全ブラウザ退出）
     *   "userId:terminalUniqueString" → 複数ブラウザ同時サインイン禁止による強制サインアウト（当該ブラウザのみ退出）
     */
    "forceSignoutValue.length"(newValue) {
      if (newValue > 0) {
        this.dequeueMessage(NOTIFY_TOPIC_FORCE_SIGNOUT).then(msg => {
          if (msg === null) return;
          const parts = String(msg).trim().split(":");
          const msgUserId = parts[0];
          if (msgUserId !== String(this.getUserId)) return;
          let shouldSignOut = false;
          if (parts.length === 1) {
            // 権限縮小 → 全ブラウザを退出させる
            shouldSignOut = true;
          } else {
            // 複数ブラウザ同時サインイン禁止 → terminalUniqueString が一致するブラウザのみ退出させる
            shouldSignOut = parts[1] === localStorage.getItem(LOCAL_STORAGE_KEY.TERMINAL_UNIQUE_STRING);
          }
          if (shouldSignOut) {
            // サインアウト理由ダイアログを表示するためにAPIエラー情報を設定する
            this.setApiResult({
              status: 401,
              message: "以下のいずれかの理由によりサインアウトしました。<br>" +
                "・設定時間操作がないことによるタイムアウト<br>" +
                "・複数端末同時サインイン制限<br>" +
                "・サインイン連続失敗によるアカウントロック<br>" +
                "・アカウントの権限変更<br>" +
                "・アカウント削除"
            });
            this.signOutForAuthFailed();
          }
        });
      }
    }
  },
  methods: {
    ...mapActions("multi-modal", ["showNotificationMessage"]),
    ...mapActions("notification-message", ["getNotificationMessage"]),
    ...mapActions("websocket", [
      "fetchConnectUrl",
      "init",
      "connect",
      "close",
      "dequeueMessage",
      "addWatchTopics",
      "removeWatchTopics"
    ]),
    ...mapActions("user", ["signOutForAuthFailed"]),
    ...mapActions("app", ["setApiResult"]),
    // add FNSi6960通知の件数が残ったままになる 周 start
    ...mapActions("notification-message", ["updateNotificationMessageStatus"]),
    // add FNSi6960通知の件数が残ったままになる 周 end
    /**
     * ジャンプボタンクリックイベントハンドラ.
     * @param {Object} message 通知メッセージ情報
     * @param {function} close 通知を閉じる関数オブジェクト
     */
    onForward(message, close) {
      if (this.jump(message)) {
        close();
      }
    },
    // add FNSi6960通知の件数が残ったままになる chen start
    onClose(message, props) {
      console.log(message.no);
      this.updateNotificationMessageStatus({
        notification_message_nos: [message.no],
        is_read: "1"
      })
      props.close();
    },
    // add FNSi6960通知の件数が残ったままになる chen end
    // add FNSI-コードをマージ 江 start
    /**
     * URL取得からTOPICの登録まで含むWebSocket接続
     */
    webSocketConnect() {
      //施設切替 補充する start
      if(!this.getFacilityCd){return;}
      //施設切替 補充する end
      // WebSocket接続
      this.fetchConnectUrl(this.getFacilityCd).then(r => {
        this.init({ url: r.data, facilityCd: this.getFacilityCd });
        this.enableWsConnect = true;
        // console.log("NotificationMessageComponent WebSocket接続処理 %o", new Date());
        this.connect();
        this.connectingFlg = false;

        this.notifyTopic = `${NOTIFY_TOPIC_NOTIFICATION_MESSAGE}/${this.getFacilityCd}`;
        this.addWatchTopics({
          topic: this.notifyTopic,
          obj: this.notifyValue
        });
        this.addWatchTopics({
          topic: NOTIFY_TOPIC_FORCE_SIGNOUT,
          obj: this.forceSignoutValue
        });
      });
    }
  },
  beforeDestroy() {
    clearInterval(this.webSocketConnectionManageProc);
  }
    // add FNSI-コードをマージ 江 end
};
</script>

<style scoped lang="scss">
.notifications {
  width: 40em !important;
  max-width: 100vw !important;
  // add FNSI-#595(起票):モーダルを表示中に通知のトーストが裏に表示する対応 韓 start
  z-index: 9999999999;
  // add FNSI-#595(起票):モーダルを表示中に通知のトーストが裏に表示する対応 韓 end
}
.notification-message {
  display: flex;
  flex-direction: row;
  flex-wrap: nowrap;
  text-align: left;
  font-size: 1.5em;
  margin: 5px;

  background-color: var(--notification-message-background-color);
  border: 2px solid var(--notification-message-border-color);
  color: var(--notification-message-color);

  &,
  & > div {
    box-sizing: border-box;
  }

  .content-area {
    width: 90%;
    padding: 10px;
    flex: 1 0 auto;
    cursor: pointer;
  }

  .button-area {
    flex: 0 0 auto;
    display: flex;
    flex-direction: column;
    justify-content: space-between;

    & > div {
      flex: 0 1 auto;
      margin: 8px;
      font-size: 1.5em;
      cursor: pointer;
    }
  }
}
// add FNSI-「通知トーストに重要通知である旨が表示されない」の不具合修正 江 start
.important-i{
  //mod FNSI-bug #4115「重要通知トーストのレイアウト不正」の不具合修正 start
  // background-color: #ff3366;
  // color: white;
  background-color: #ff0000;
  color: #ffffff;
  padding: 4px;
  margin-left: 8px;
  //mod FNSI-bug #4115「重要通知トーストのレイアウト不正」の不具合修正 end
}
// add FNSI-「通知トーストに重要通知である旨が表示されない」の不具合修正 江 end
//add FNSI-bug #4115「重要通知トーストのレイアウト不正」の不具合修正 start
.important-message{
  background-color: #f9e8e8;
  display: flex;
  flex-direction: row;
  flex-wrap: nowrap;
  text-align: left;
  font-size: 1.5em;
  margin: 5px;
  border: 2px solid #f9e8e8;
  color: var(--notification-message-color);

  &,
  & > div {
    box-sizing: border-box;
  }

  .content-area {
    width: 90%;
    padding: 10px;
    flex: 1 0 auto;
    cursor: pointer;
  }

  .button-area {
    flex: 0 0 auto;
    display: flex;
    flex-direction: column;
    justify-content: space-between;

    & > div {
      flex: 0 1 auto;
      margin: 8px;
      font-size: 1.5em;
      cursor: pointer;
    }
  }
}
//add FNSI-bug #4115「重要通知トーストのレイアウト不正」の不具合修正 end
// add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 江 start
.same-icon{
  height: 1.0em;
  display: inline-block;
  margin-left: 0.5em;
}
// #9190 通知の閉じるアイコンと、機能遷移アイコンが存在しない。start 訾浩
.ion-ios-close {
  font-size: 1.7em;
}
// #9190 通知の閉じるアイコンと、機能遷移アイコンが存在しない。end 訾浩
// add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 江 end
</style>
