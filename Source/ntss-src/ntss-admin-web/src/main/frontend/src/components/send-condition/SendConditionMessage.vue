/**
 * 条件送信用メッセージ画面
 */
<template>
  <div class="ntss-send-condition-main-message-area">
    <div v-if="getIsLocalMessage" class="message-list">
      <v-ons-row
        v-for="(msg, msgKey) in getLocalMessageList"
        :key="msgKey"
        :class="'message-list-body-tr'"
      >
        <v-ons-col
          v-if="msg.isError"
          width="100%"
          class="message-list-body-td-error"
        >{{ msg.message }}</v-ons-col>
        <v-ons-col
          v-else-if="msg.isWarn"
          width="100%"
          class="message-list-body-td-warn"
        >{{ msg.message }}</v-ons-col>
        <v-ons-col
          v-else
          width="100%"
          class="message-list-body-td"
        >{{ msg.message }}</v-ons-col>
      </v-ons-row>
    </div>
    <div v-if="getIsListMessage && getIsCheckView" class="message-list">
      <v-ons-row
        v-for="(msg, msgKey) in shownMsgList"
        :key="msgKey"
        :class="'message-list-body-tr'"
      >
        <v-ons-col
          v-if="msg.isError"
          width="100%"
          class="message-list-body-td-error"
        >{{ msg.message }}</v-ons-col>
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
            <label class="center" :for="'send-check-off-' + msgKey">許可</label>
          </div>
        </v-ons-col>
        <v-ons-col
          v-if="!msg.isError && !msg.isWarn && msg.isWarnValue"
          width="100%"
          class="message-list-body-td-warn"
        >{{ msg.message }}</v-ons-col>
        <v-ons-col
          v-if="!msg.isError && !msg.isWarn && !msg.isWarnValue"
          width="100%"
          class="message-list-body-td"
        >{{ msg.message }}</v-ons-col>
      </v-ons-row>
    </div>
  </div>
</template>

<script>
import { mapGetters } from "@/compat/vue/vuex";

export default {

  data() {
    return {
      msgList: []
    };
  },
  computed: {
    ...mapGetters("send-condition/scale/message", [
      "getLocalMessageList",
      "getIsLocalMessage",
      "getIsListMessage",
      "getCheckMessageList",
      "getIsCheckView"
    ]),
    shownMsgList() {
      return this.msgList.filter(elm => {
        if (elm.isDisp) {
          return true;
        }
      });
    }
  },
  watch: {
    getCheckMessageList() {
      this.msgList = this.getCheckMessageList;
    }
  },

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
