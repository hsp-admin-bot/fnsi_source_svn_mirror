
<template>
  <router-view></router-view>
</template>

<script>
/**
 * WebSocket受信待ち受け処理サンプル
 */
import { mapGetters, mapActions } from "vuex";
/**
 * 取得するメッセージのトピックを登録
 */
import {
  NOTIFY_TOPIC_WEIGHT_CARD_READ,
  NOTIFY_TOPIC_WEIGHT_SCALE_VALUE,
  NOTIFY_TOPIC_WEIGHT_CARD_WRITE_RESULT,
  NOTIFY_TOPIC_WEIGHT_CONNECT,
  NOTIFY_TOPIC_SEND_CONDITION_RESULT
} from "@/constants/websocketNotifyTopic";
import { EventBus } from "@/eventBus.js";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import SendConditionMixin from "@/components/send-condition/SendConditionMixin";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

export default {
  mixins: [NextTransitionMixin, SendConditionMixin],
  data() {
    return {
      notifyTopic: {
        cardRead: NOTIFY_TOPIC_WEIGHT_CARD_READ,
        scaleValue: NOTIFY_TOPIC_WEIGHT_SCALE_VALUE,
        cardWriteResult: NOTIFY_TOPIC_WEIGHT_CARD_WRITE_RESULT,
        weightConnect: NOTIFY_TOPIC_WEIGHT_CONNECT,
        sendConditionResult: NOTIFY_TOPIC_SEND_CONDITION_RESULT
      },
      notifyValue: {
        cardRead: [],
        scaleValue: [],
        cardWriteResult: [],
        weightConnect: [],
        sendConditionResult: []
      },
      enableWsConnect: false
    };
  },
  computed: {
    ...mapGetters("app", ["getQueryParameters"]),
    ...mapGetters("websocket", [
      "getSocketIsConnected",
      "getSocketIsError",
      "getSocketReconnectError",
      "getSocketEventInfo",
      "getSocketMessages",
      "getSocketMessageLength"
    ]),
    ...mapGetters("send-condition/weight", ["getSelectedMstWeight"]),
    ...mapGetters("send-condition/state", [
      "getWeightIsConnect",
      "getWeightScaleValue",
      "getWeightBarcodeValue",
      "getWeightCardReadValue",
      "getWeightCardWriteResult"
    ]),
    ...mapGetters("send-condition/scale", [
      "getSendConditionResponseCd",
      "getInputPatId",
      "getScaleMode"
    ]),
    ...mapGetters("send-condition/scale/setting", [
      "getWeightConfigInfo",
      "getWeightScaleConfigInfo",
      "getWeightAudioSetting",
      "getWeightCheckSetting",
      "getWeightColorSetting",
      "getWeightPrintSetting",
      "getWheelChairList"
    ]),
    ...mapGetters("user", {
      facilityCd: "getFacilityCd"
    }),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    selectedMstWeightCd: function() {
      if (this.getSelectedMstWeight !== null) {
        return this.getSelectedMstWeight.weightCd;
      }
      return null;
    }
  },
  methods: {
    ...mapActions("app", ["setQueryParameters"]),
    ...mapActions("websocket", [
      "fetchConnectUrl",
      "init",
      "connect",
      "close",
      "dequeueMessage",
      "addWatchTopics",
      "removeWatchTopics",
      "removeMessage",
      "getSocketAllMessages"
    ]),
    ...mapActions("send-condition/scale/setting", [
      "setWeightConfigInfo",
      "clearWeightConfigInfo"
    ]),
    ...mapActions("send-condition/state", [
      "fetchWeightState",
      "setWeightState"
    ]),
    ...mapActions("send-condition/weight", [
      "setWeightMode",
      "setMstWeightSelectIdx"
    ]),
    ...mapActions("send-condition/scale", [
      "fetchSendConditionResult",
      "removeSendConditionResponseCd"
    ])
  },
  beforeDestroy() {
    this.stopDelayAudioAll();
    this.removeWatchTopics(this.notifyTopic.sendConditionResult);
    // add 2020-11/04 FNSI-改修内容No311 ブラウザまで値が到達しないケースが多い 孫 start
    this.removeWatchTopics(this.notifyTopic.scaleValue);
    // add 2020-11/04 FNSI-改修内容No311 ブラウザまで値が到達しないケースが多い 孫 end
    // add 患者カード読み込みが不可になる 徐 start
    this.removeWatchTopics(this.notifyTopic.cardRead);
    this.removeWatchTopics(this.notifyTopic.cardWriteResult);
    this.removeWatchTopics(this.notifyTopic.weightConnect);
    // add 患者カード読み込みが不可になる 徐 end

    // dataの初期化
    Object.assign(this.$data, this.$options.data());
    // 他機能に遷移した時点で体重計選択は「体重計接続なし」とする。
    this.setMstWeightSelectIdx(-1);
    let queryParameters = this.getQueryParameters;
    queryParameters.WEIGHTNO = undefined;
    queryParameters.MODE = undefined;
    this.setQueryParameters(queryParameters);
    this.clearWeightConfigInfo();
    // 体重計モード削除
    this.setWeightMode({
      isWeightMode: false,
      defaultDispMenu: null
    });
    const cssLink = document.head.querySelectorAll(
      "link[href='./css/ntss_weight_mode.css']"
    );
    for (const link of cssLink) {
      document.head.removeChild(link);
    }
  },
  watch: {
    getSocketIsConnected(value, oldValue) {
      if (value === false && oldValue) {
        // 切断された
        if (this.enableWsConnect) {
          // 再接続
          this.connect();
        }
      }
    },
    getSelectedMstWeight(value, oldValue) {
      // 接続体重計が変化した場合、選択中体重計を更新
      if (value !== undefined && value !== null) {
        this.setWeightConfigInfo(value);
      } else {
        this.clearWeightConfigInfo();
      }

      // 接続体重計が変更した場合、体重計からの通知の監視対象を変更する
      if (oldValue !== undefined && oldValue !== null) {
        const oldTopic = [
          `${NOTIFY_TOPIC_WEIGHT_CARD_READ}/${this.facilityCd}/${oldValue.weightNo}`,
          `${NOTIFY_TOPIC_WEIGHT_SCALE_VALUE}/${this.facilityCd}/${oldValue.weightNo}`,
          `${NOTIFY_TOPIC_WEIGHT_CARD_WRITE_RESULT}/${this.facilityCd}/${oldValue.weightNo}`,
          `${NOTIFY_TOPIC_WEIGHT_CONNECT}/${this.facilityCd}/${oldValue.weightNo}`
        ];
        oldTopic.forEach(v => {
          this.removeWatchTopics(v);
        });
      }
      if (value !== undefined && value !== null) {
        this.notifyTopic.cardRead = `${NOTIFY_TOPIC_WEIGHT_CARD_READ}/${this.facilityCd}/${value.weightNo}`;
        this.notifyTopic.scaleValue = `${NOTIFY_TOPIC_WEIGHT_SCALE_VALUE}/${this.facilityCd}/${value.weightNo}`;
        this.notifyTopic.cardWriteResult = `${NOTIFY_TOPIC_WEIGHT_CARD_WRITE_RESULT}/${this.facilityCd}/${value.weightNo}`;
        this.notifyTopic.weightConnect = `${NOTIFY_TOPIC_WEIGHT_CONNECT}/${this.facilityCd}/${value.weightNo}`;
        this.addWatchTopics({
          topic: this.notifyTopic.cardRead,
          obj: this.notifyValue.cardRead
        });
        this.addWatchTopics({
          topic: this.notifyTopic.scaleValue,
          obj: this.notifyValue.scaleValue
        });
        this.addWatchTopics({
          topic: this.notifyTopic.cardWriteResult,
          obj: this.notifyValue.cardWriteResult
        });
        this.addWatchTopics({
          topic: this.notifyTopic.weightConnect,
          obj: this.notifyValue.weightConnect
        });
      }
    },
    "notifyValue.cardRead.length"(value) {
      if (value > 0) {
        this.dequeueMessage(this.notifyTopic.cardRead).then(weightCd => {
          this.fetchWeightState(weightCd)
            .then(r => {
              this.setWeightState(r.data);
              // カード読取値受信
              const cardValue = JSON.parse(r.data.cardReadValue);
              if (cardValue.id === undefined || cardValue.id === null) {
                cardValue.id = "";
              }
              cardValue.id = String(cardValue.id).trim();
              // add FNSI-患者カード無効の追加 徐 start
              if (cardValue.cardCheckValue === undefined || cardValue.cardCheckValue === null) {
                cardValue.cardCheckValue = "";
              }
              cardValue.cardCheckValue = String(cardValue.cardCheckValue).trim();
              if (cardValue.cardCheckValue === "1") {
                this.$ons.notification.alert({
                      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                      // title: "",
                      // message: "患者カード無効です。"
                      title: DIALOG_MESSAGES[12000230].title,
                      message: messageFormat(DIALOG_MESSAGES[12000230].message)
                      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                    }).then(() => {
                      EventBus.$emit("weightModeFocusPatId");
                    });
              } else if (cardValue.cardCheckValue === "0") {
                // if (
                //   this.$route.fullPath === "/weight" ||
                //   this.$route.fullPath === "/weight/"
                // ) {
                if (
                  this.$route.fullPath === "/weight-mode" ||
                  this.$route.fullPath === "/weight-mode/"
                ) {
                  // 体重計患者選択画面
                  EventBus.$emit("searchHospPatIdSchedule", {
                  hospPatId: cardValue.id
                  });
                // } else if (this.$route.fullPath === "/weight/scale") {
                } else if (this.$route.fullPath === "/weight-mode/scale") {
                  // 条件送信画面
                  if (this.getInputPatId !== null) {
                    // 患者選択済み
                    if (String(this.getInputPatId) !== String(cardValue.id)) {
                      // 患者が異なる
                      this.$ons.notification.confirm({
                        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
                        // title: "カード読取",
                        title: DIALOG_MESSAGES[13000128].title,
                        // message: "患者を切り替えますか？",
                        message: messageFormat(DIALOG_MESSAGES[13000128].message),
                        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
                        callback: answer => {
                          if (answer == 1) {
                            //OK
                            EventBus.$emit("searchHospPatIdSchedule", {
                              hospPatId: cardValue.id
                            });
                          }
                        }
                      });
                    }
                  } else {
                    EventBus.$emit("searchHospPatIdSchedule", {
                    hospPatId: cardValue.id
                    });
                  }
                } else {
                // 車いすマスタ編集の画面などではなにもしない
                }
              }
              // add FNSI-患者カード無効の追加 徐 end
            })
            .catch(e => {
              //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
              getErrorMessage('WeightModeMainFrameComponent.vue', 'getSelectedMstWeight', e);
              //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
              if (e.response.status === 400) {
                // 状態取得失敗
              }
            });
        });
      }
    },
    "notifyValue.scaleValue.length"(value) {
      if (value > 0) {
        // add FNSI-田中衡機の追加 徐 start
        let deviceClass = null;
        if (this.getWeightConfigInfo !== undefined && this.getWeightConfigInfo !== null) {
          deviceClass = this.getWeightConfigInfo.deviceClass;
        }
        // add FNSI-田中衡機の追加 徐 end
        this.dequeueMessage(this.notifyTopic.scaleValue).then(weightCd => {
          // 測定値受信
          this.fetchWeightState(weightCd)
            .then(r => {
              // add FNSI-田中衡機の追加 徐 start
              this.setWeightState(r.data);
              if (String(deviceClass) === "1") {
                EventBus.$emit("onReceiveMeasureValue", r.data.scaleValueList);
              } else {
                EventBus.$emit("onReceiveMeasureValue", r.data.scaleValue);
              }
              this.playAudio(this.getWeightAudioSetting).receiveWeight();
              // add FNSI-田中衡機の追加 徐 end
            })
            .catch(e => {
              //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
              getErrorMessage('WeightModeMainFrameComponent.vue', 'getSelectedMstWeight', e);
              //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
              if (e.response.status === 400) {
                // 状態取得失敗
              }
            });
        });
      }
    },
    "notifyValue.cardWriteResult.length"(value) {
      if (value > 0) {
        this.dequeueMessage(this.notifyTopic.cardWriteResult).then(weightCd => {
          // TODO:カード書き込み結果受信
          this.fetchWeightState(weightCd)
            .then(r => {
              this.setWeightState(r.data);
              if (this.getWeightCardWriteResult === 1) {
                // 書き込み成功
              } else if (this.getWeightCardWriteResult === -1) {
                // 書き込み失敗
              }
            })
            .catch(e => {
              //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
              getErrorMessage('WeightModeMainFrameComponent.vue', 'getSelectedMstWeight', e);
              //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
              if (e.response.status === 400) {
                // 状態取得失敗
              }
            });
        });
      }
    },
    "notifyValue.weightConnect.length"(value) {
      if (value > 0) {
        this.dequeueMessage(this.notifyTopic.weightConnect).then(weightCd => {
          // 体重計アプリ接続状態受信
          this.fetchWeightState(weightCd)
            .then(r => {
              this.setWeightState(r.data);
              if (r.data.isConnect === "1") {
                this.$ons.notification.alert({
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // title: "装置接続",
                  // message: `${this.getSelectedMstWeight.weightName} との通信が確立しました`
                  title: DIALOG_MESSAGES[12000231].title,
                  message: messageFormat(DIALOG_MESSAGES[12000231].message, this.getSelectedMstWeight.weightName)
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                });
              } else {
                this.$ons.notification.alert({
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // title: "装置切断",
                  // message: `${this.getSelectedMstWeight.weightName} との通信が切断しました`
                  title: DIALOG_MESSAGES[12000232].title,
                  message: messageFormat(DIALOG_MESSAGES[12000232].message, this.getSelectedMstWeight.weightName)
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                });
              }
            })
            .catch(e => {
              //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
              getErrorMessage('WeightModeMainFrameComponent.vue', 'getSelectedMstWeight', e);
              //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
              if (e.response.status === 400) {
                // 状態取得失敗k
              }
            });
        });
      }
    }
  }
};
</script>
