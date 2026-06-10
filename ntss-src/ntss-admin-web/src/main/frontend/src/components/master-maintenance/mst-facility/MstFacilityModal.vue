<template>
  <com-textarea
    :content="text"
    idTextarea = "com-textarea-facility"
    propMaxlength="2048"
    defaultHeight="680px"
    :class="['textarea-popover', modalMessageSize]"
    cssClass="textarea-resize-vertical"
    @set-content-data="setContentData"
  />
</template>

<script>
import { mapGetters, mapActions } from "vuex";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import CommonTextArea from "@/components/common/CommonTextArea";

/**
 * @description 緊急発砲テンプレートモーダルコンポーネント
 */
export default {
  mixins: [MasterMaintenanceMixin],
  components: {
    "com-textarea": CommonTextArea
  },
  data() {
    return {
      text: ""
    };
  },

  computed: {
    ...mapGetters("master-maintenance", ["getEditRecord"]),
    ...mapGetters("account-edit", ["getFontSize"]),
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

  created() {
    this.text = this.getEditRecord.mNoticeMailTemplate;
  },

  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),

    commitText() {
      // 編集中マスタを更新
      this.setEditRecord({
        ...this.getEditRecord,
        mNoticeMailTemplate: this.text
      });
    },

    setContentData(newValue) {
      this.text = newValue;
      this.commitText();
    }
  }
};
</script>

<style scoped>
.textarea-popover {
  box-sizing: border-box;
  width: 99.9%;
  overflow-y: auto;
  font-size: 1em;
}
.textarea-popover.small {
  max-height: calc(100% - 15px);
}

.textarea-popover.medium {
  max-height: calc(100% - 5px);
}

.textarea-popover.big {
  max-height: calc(100% - 2px);
}

.textarea-popover.xbig {
  max-height: calc(100% + 7px);
}
</style>
