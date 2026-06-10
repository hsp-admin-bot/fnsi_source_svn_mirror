<template>
  <modal-base @onClose="close">
    <div slot="header">
      <component :is="header"></component>
    </div>

    <div :class="['body', modalMessageSize]" slot="body" style="overflow: auto;">
      <table style="table-layout: fixed;width: 100%;">
        <tr>
          <textarea
            id="com-textarea-external-coop"
            :value="dump"
            readonly
            class="com-textarea"
          />
        </tr>
      </table>
    </div>

    <div slot="footer" class="flex-container">
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
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import { mapGetters, mapActions } from "vuex";

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
      return window.btoa(unescape(encodeURIComponent(str)));
    },
    b64ToUtf8(str) {
      return decodeURIComponent(escape(window.atob(str)));
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
      let element = document.querySelector("#com-textarea-external-coop");
      navigator.clipboard.writeText(element.value);
    },
    close() {
      this.hideModal();
    }
  },
  created() {
    this.loadData();
  },
  mounted() {
    const modal = document.getElementsByClassName("modal-container")[0];
    const modalHeight = modal.clientHeight;
    const modalHeaderHeight = modal.firstElementChild.scrollHeight;
    const modalFooterHeight = modal.lastElementChild.scrollHeight;
    let element = document.querySelector("#com-textarea-external-coop");
    element.style.height = modalHeight - modalHeaderHeight - modalFooterHeight + 8 + "px";
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
  div >>> .modal-wrapper {
    display: inline-block !important;
  }
  div >>> .com-textarea {
    width: 100% !important;
  }
}
</style>
