<template>
  <modal-base @onClose="close">
    <template #header>
      <component :is="header"></component>
    </template>

    <template #body>
      <div :class="['modal-message', modalMessageSize]">
        {{ detaiMessage }}
      </div>
    </template>

    <template #footer>
      <div class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <button class="button btn2-cancel" @click="close">
          閉じる
        </button>
      </div>
      </div>
    </template>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { queryScopedSelector } from "@/functions/common/LayoutMeasureHelper";

export default {
  name: "external-coop-modal",
  components: {
    "modal-base": ModalBase
  },
  data() {
    return {
      header: "",
      detaiMessage: "",
      isEdited: false
    };
  },
  computed: {
    ...mapGetters("external-coop", ["getEditRecord"]),
    ...mapGetters("account-edit", ["getFontSize"]),
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
    close() {
      this.hideModal();
    }
  },
  mounted() {
    const detailMessage = queryScopedSelector(".modal-message", this.$el || this);
    if (detailMessage) {
      detailMessage.innerHTML = detailMessage.innerHTML.replace(/^\s+/, "");
    }
  },
  created() {
    this.detaiMessage = this.getEditRecord.message;
  }
};
</script>

<style scoped>
.modal-message {
  white-space: pre-line;
  padding: 5px;
  overflow-y: auto;
}

.modal-message.small {
  height: calc(100% - 28px);
}

.modal-message.medium {
  height: calc(100% - 15px);
}

.modal-message.big {
  height: calc(100% - 11px);
}

.modal-message.xbig {
  height: calc(100% - 9.95px);
}
</style>
