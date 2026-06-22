<template>
  <modal-base @onClose="cancel">
    <template #header>
      <component :is="header"></component>
    </template>

    <template #body>
      <div :class="['body', modalMessageSize]" style="height: 100%">
      <v-ons-row>
        <v-ons-col>
          <com-textarea
            class="com-textarea"
            :content="dumpPath"
            cssClass="dumpPath-textare textarea-custom-text-font textarea-resize-vertical"
            idTextarea="com-textarea-external-coop-dump-path"
            rows="30"
            defaultHeight="99%"
            :disabled="!isMasterUser"
            @set-content-data="setContentData"
          />
        </v-ons-col>
      </v-ons-row>
      </div>
    </template>

    <template #footer>
      <div class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <button class="button denial-btn btn2-cancel" @click="cancel">
          キャンセル
        </button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <button
          class="button registration-btn btn3-normal"
          @click="save"
          :disabled="!isEdited"
          v-if="isMasterUser"
        >
          確定
        </button>
      </div>
      </div>
    </template>
  </modal-base>
</template>

<script>
import { EventBus } from "@/compat/vue/event-bus.js";
import ModalBase from "@/components/modals/ModalBase";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import CommonTextArea from "@/components/common/CommonTextArea";
// mod #6107 2023/03/22 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/22 メッセージボックス全調整 張博 end

export default {
  name: "external-coop-dump-path-modal",
  components: {
    "modal-base": ModalBase,
    "com-textarea": CommonTextArea
  },
  data() {
    return {
      header: "",
      dumpPath: "",
      isEdited: false
    };
  },
  computed: {
    ...mapGetters("window-size", { getFontSize: "getFontSize" }),
    ...mapGetters("external-coop", ["getExternalCoopList", "getEditRecord"]),
    ...mapGetters("account-edit", {
      userAccountInfo: "getStateUserAccountInfo",
      getFontSize: "getFontSize"
    }),
    isMasterUser() {
      return this.userAccountInfo.userType === 1;
    },
    modalMessageSize() {
      switch (+this.getFontSize) {
        case 0:
          return "small";
        case 1:
          return "medium";
        case 2:
          return "big";
        case 3:
          return "xbig";
        default:
          return "";
      }
    }
  },
  methods: {
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("external-coop", ["setEditRecord"]),
    loadData() {
      if (this.getEditRecord) {
        this.dumpPath = this.getEditRecord.dumpPath;
      }
    },
    save() {
      this.setEditRecord({
        ...this.getEditRecord,
        dumpPath: this.dumpPath
      });
      let param = {
        dumpPath: this.dumpPath,
        ctlNo: this.getEditRecord.ctlNo
      };
      EventBus.$emit("dumpPath-event", param);
      this.hideModal();
    },
    updateDumpPath() {
      this.isEdited = true;
    },
    cancel() {
      if (this.isEdited) {
        this.$ons.notification.confirm({
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
          // title: "内容破棄",
          title: DIALOG_MESSAGES[13000040].title,
          // message: "変更をキャンセルしますか?",
          message: messageFormat(DIALOG_MESSAGES[13000040].message),
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
          callback: ok => {
            if (ok) {
              this.hideModal();
            }
          }
        });
      } else {
        this.hideModal();
      }
    },

    setContentData(newValue) {
      this.dumpPath = newValue;
      this.updateDumpPath();
    }
  },
  created() {
    this.loadData();
  }
};
</script>

<style scoped>
div :deep(.dumpPath-textare) {
  box-sizing: border-box;
  padding: 5px;
  word-wrap: break-word;
  width: 99.9%;
}
.com-textarea {
  height: 100%;
}

.body {
  overflow-y: auto;
}

.body.small {
  max-height: calc(100% - 18px);
}

.body.medium {
  max-height: calc(100% - 2px);
}

.body.big {
  max-height: 100%;
}

.body.xbig {
  max-height: 100%;
}
</style>
