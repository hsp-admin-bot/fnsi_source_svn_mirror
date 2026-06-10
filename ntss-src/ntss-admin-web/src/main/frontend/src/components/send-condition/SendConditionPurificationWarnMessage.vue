/**
 * 条件送信用メッセージ画面---特殊浄化
 */
<template>
  <div class="ntss-send-condition-main-message-area">
    <div class="message-list">
      <v-ons-row
        v-for="(msg, msgKey) in shownMsgList"
        :key="msgKey"
        :class="'message-list-body-tr'"
      >
        <v-ons-col
          v-if="!msg.isError && msg.isWarn && !msg.isChecked"
          class="message-list-body-td-warn"
        >{{ msg.message }}</v-ons-col>
        <v-ons-col
          v-if="!msg.isError && msg.isWarn && !msg.isChecked"
          width="4em"
          class="message-list-body-td-warn"
        >
          <div class="print-box">
            <label class="left">
              <v-ons-checkbox v-model="msg.isChecked" :input-id="'send-check-on-' + msgKey" style="vertical-align: middle; line-height: 30px;" />
            </label>
            <label class="center" :for="'send-check-on-' + msgKey">許可</label>
          </div>
        </v-ons-col>
        <v-ons-col
          v-if="!msg.isError && msg.isWarn && msg.isChecked"
          class="message-list-body-td"
        >{{ msg.message }}</v-ons-col>
        <v-ons-col
          v-if="!msg.isError && msg.isWarn && msg.isChecked"
          width="4em"
          class="message-list-body-td"
        >
          <div class="print-box">
            <label class="left">
              <v-ons-checkbox v-model="msg.isChecked" :input-id="'send-check-off-' + msgKey" style="vertical-align: middle; line-height: 30px;" />
            </label>
            <label class="center" :for="'send-check-off-' + msgKey">許可2222</label>
          </div>
        </v-ons-col>
      </v-ons-row>
    </div>
  </div>
</template>

<script>
import { mapGetters } from "vuex";

export default {
  props: {},
  components: {},
  data() {
    return {
      msgList: []
    };
  },
  computed: {
    ...mapGetters("send-condition/scale/message", [
      "getPurificationWarnmessageList"
    ]),
    shownMsgList() {
      return this.msgList.filter(elm => {
        if (elm.isDisp) {
          return true;
        }
      });
    }
  },
  methods: {},
  watch: {
    getPurificationWarnmessageList() {
      this.msgList = this.getPurificationWarnmessageList;
    }
  },
  created() {},
  mounted() {},
  destroyed() { }
};
</script>
<style scoped>

.print-box {
  display: flex;
  align-items: center;
}

.print-box label {
  margin-left: 5px;
}

.message-list {
  width: 100%;
}

.message-list-header {
  display: none;
}
</style>
