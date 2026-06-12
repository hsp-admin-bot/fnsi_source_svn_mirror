<template>
  <modal-base @onClose="close">
    <template #header>
      <component :is="header"></component>
    </template>

    <template #body>
      <div :class="['body', modalMessageSize]" style="overflow: auto;">
      <table style="table-layout: fixed;width: 100%;">
        <tbody>
          <tr>
            <td>
              <textarea
            id="com-textarea-external-coop"
            :value="dump"
            readonly
            class="com-textarea"
              />
            </td>
          </tr>
      
        </tbody>
      </table>
    </div>
    </template>

    <template #footer>
      <div class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <button class="button btn2-cancel" @click="close">
          閉じる
        </button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <button class="button registration-btn btn3-normal" @click="copy">
          コピー
        </button>
      </div>
      </div>
    </template>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { getModalContainerElement, queryScopedSelector, getScopedWindow } from "@/functions/common/LayoutMeasureHelper";

export default {
  name: "external-coop-modal",
  components: {
    "modal-base": ModalBase
  },
  data() {
    return {
      header: "",
      dump: ""
    };
  },
  computed: {
    ...mapGetters("window-size", { getFontSize: "getFontSize" }),
    ...mapGetters("external-coop", ["getExternalCoopList", "getEditRecord"]),
    ...mapGetters("account-edit", {
      getFontSize: "getFontSize"
    }),
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
    utf8ToB64(str) {
      return getScopedWindow(this.$el || this)?.btoa?.(unescape(encodeURIComponent(str))) || "";
    },
    b64ToUtf8(str) {
      return decodeURIComponent(escape(getScopedWindow(this.$el || this)?.atob?.(str) || ""));
    },
    loadData() {
      if (this.getEditRecord) {
        if (this.getEditRecord.dump) {
          this.dump = this.b64ToUtf8(this.getEditRecord.dump);
        }
      } else {
        this.dump = "";
      }
    },
    copy() {
      const element = queryScopedSelector("#com-textarea-external-coop", this.$el || this);
      getScopedWindow(this.$el || this)?.navigator?.clipboard?.writeText?.(element?.value || "");
    },
    close() {
      this.hideModal();
    }
  },
  created() {
    this.loadData();
  },
  mounted() {
    const modal = getModalContainerElement(this.$el || this);
    const modalHeight = modal?.clientHeight || 0;
    const modalHeaderHeight = modal?.firstElementChild?.scrollHeight || 0;
    const modalFooterHeight = modal?.lastElementChild?.scrollHeight || 0;
    const element = queryScopedSelector("#com-textarea-external-coop", this.$el || modal || this);
    if (element) {
      element.style.height = modalHeight - modalHeaderHeight - modalFooterHeight + 8 + "px";
    }
  }
};
</script>
<style scoped>
.com-textarea {
  font-family: helvetica, arial, "hiragino kaku gothic pro", meiryo, "ms pgothic", sans-serif;
  min-height: 40px;
  max-height: 80vh;
  background-color: #F7F7F7;
  padding: 5px !important;
  word-wrap: break-word;
  width: 99.9%;
  box-sizing: border-box;
  font-size: 1.0em;
  padding: 5px;
}
.body {
  overflow-x: hidden;
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
@media print {
  /** テキストエリアのページ跨ぎを可能とする */
  div :deep(.modal-wrapper){
    display: inline-block !important;
  }
  div :deep(.com-textarea){
    width: 100% !important;
  }
}
</style>
