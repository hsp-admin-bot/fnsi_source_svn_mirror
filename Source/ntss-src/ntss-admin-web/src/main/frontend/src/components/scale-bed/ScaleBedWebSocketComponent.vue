<template>
  <div></div>
</template>
<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { sendRequestGetScaleBedKeyList } from "@/apis/scale-bed";
/**
 * 取得するメッセージのトピックを登録
 */
import {
  NOTIFY_TOPIC_WEIGHT_SCALE_VALUE,
  NOTIFY_TOPIC_WEIGHT_CONNECT,
  NOTIFY_TOPIC_SEND_CONDITION_RESULT,
} from "@/constants/websocketNotifyTopic";

export default {
  data() {
    return {
      unwatch: [],
      notify: {
        /** @type {Array<{topic: string, buffer: string[]}>} */
        scaleValues: [],
        /** @type {Array<{topic: string, buffer: string[]}>} */
        weightConnects: [],
        /** @type {Array<{topic: string, buffer: string[]}>} */
        sendConditionResults: [],
      },
      enableWsConnect: false,
    };
  },
  computed: {
    ...mapGetters("scale-bed/list", ["getNotifyTargetKeyInfo"]),
    ...mapGetters("websocket", [
      "getSocketIsConnected",
      "getSocketIsError",
      "getSocketReconnectError",
      "getSocketEventInfo",
      "getSocketMessages",
      "getSocketMessageLength",
    ]),
    ...mapGetters("user", {
      facilityCd: "getFacilityCd",
    }),
  },
  methods: {
    ...mapActions("scale-bed/list", [
      "setNotifyTargetKeyInfo",
      "resetNotifyTargetKeyInfo",
    ]),
    ...mapActions("websocket", [
      "fetchConnectUrl",
      "init",
      "connect",
      "close",
      "dequeueMessage",
      "addWatchTopics",
      "removeWatchTopics",
      "removeMessage",
      "getSocketAllMessages",
    ]),
    async fetchMasterData() {
      // マスタデータ取得処理
      const response = await sendRequestGetScaleBedKeyList();
      if (response && response.data) {
        this.setNotifyTargetKeyInfo(response.data);
      }
    },
    removeWebSocketWatchTopics() {
      // WebSocketの監視トピック登録解除
      for (const setting of this.notify.sendConditionResults) {
        this.removeWatchTopics(setting.topic);
      }
      for (const setting of this.notify.scaleValues) {
        this.removeWatchTopics(setting.topic);
      }
      for (const setting of this.notify.weightConnects) {
        this.removeWatchTopics(setting.topic);
      }
      this.unwatch.forEach((unwatch) => unwatch());
      this.unwatch = [];
      this.notify.sendConditionResults = [];
      this.notify.weightConnects = [];
      this.notify.scaleValues = [];
    },
    changeWebSocketWatchTopics() {
      // WebSocketの監視トピック登録解除
      this.removeWebSocketWatchTopics();
      // WebSocketの監視トピック登録
      for (const keyInfo of this.getNotifyTargetKeyInfo) {
        // 体重値トピック登録
        const scaleValueTopic = `${NOTIFY_TOPIC_WEIGHT_SCALE_VALUE}/${this.facilityCd}/${keyInfo.weightNo}`;
        const scaleValueTopicSet = { topic: scaleValueTopic, buffer: [] };
        this.notify.scaleValues.push(scaleValueTopicSet);
        const scaleValueLastIndex = this.notify.scaleValues.length - 1;
        this.addWatchTopics({
          topic: this.notify.scaleValues[scaleValueLastIndex].topic,
          obj: this.notify.scaleValues[scaleValueLastIndex].buffer,
        });
        // 接続状態トピック登録
        const weightConnectTopic = `${NOTIFY_TOPIC_WEIGHT_CONNECT}/${this.facilityCd}/${keyInfo.weightNo}`;
        const weightConnectTopicSet = { topic: weightConnectTopic, buffer: [] };
        this.notify.weightConnects.push(weightConnectTopicSet);
        const weightConnectLastIndex = this.notify.weightConnects.length - 1;
        this.addWatchTopics({
          topic: this.notify.weightConnects[weightConnectLastIndex].topic,
          obj: this.notify.weightConnects[weightConnectLastIndex].buffer,
        });

        this.unwatch.push(
          this.$watch(
            () => this.notify.scaleValues[scaleValueLastIndex].buffer.length,
            async (newValue) => {
              if (newValue > 0) {
                const weightCd = await this.dequeueMessage(
                  this.notify.scaleValues[scaleValueLastIndex].topic
                );
                // 測定値受信
                this.$emit("onReceiveMeasureValue", weightCd);
              }
            }
          )
        );
        this.unwatch.push(
          this.$watch(
            () =>
              this.notify.weightConnects[weightConnectLastIndex].buffer.length,
            async (newValue) => {
              if (newValue > 0) {
                const weightCd = await this.dequeueMessage(
                  this.notify.weightConnects[weightConnectLastIndex].topic
                );
                // 接続状態受信
                this.$emit("onReceiveConnectStatus", weightCd);
              }
            }
          )
        );
      }
      // 条件送信結果トピック登録
      const sendConditionResultTopic = `${NOTIFY_TOPIC_SEND_CONDITION_RESULT}/${this.facilityCd}`;
      const sendConditionResultTopicSet = {
        topic: sendConditionResultTopic,
        buffer: [],
      };
      this.notify.sendConditionResults.push(sendConditionResultTopicSet);
      const sendConditionResultsLastIndex =
        this.notify.sendConditionResults.length - 1;
      this.addWatchTopics({
        topic:
          this.notify.sendConditionResults[sendConditionResultsLastIndex].topic,
        obj: this.notify.sendConditionResults[sendConditionResultsLastIndex]
          .buffer,
      });

      this.unwatch.push(
        this.$watch(
          () =>
            this.notify.sendConditionResults[sendConditionResultsLastIndex]
              .buffer.length,
          async (newValue) => {
            if (newValue > 0) {
              const weightScaleNo = await this.dequeueMessage(
                this.notify.sendConditionResults[sendConditionResultsLastIndex]
                  .topic
              );
              // 条件送信完了受信
              this.$emit("onReceiveSendConditionResults", weightScaleNo);
            }
          }
        )
      );
    },
  },
  created() {
    this.fetchMasterData().then(() => {
      // WebSocketの監視トピック登録
      this.changeWebSocketWatchTopics();
    });
  },
  beforeUnmount() {
    this.removeWebSocketWatchTopics();
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
  },
};
</script>
