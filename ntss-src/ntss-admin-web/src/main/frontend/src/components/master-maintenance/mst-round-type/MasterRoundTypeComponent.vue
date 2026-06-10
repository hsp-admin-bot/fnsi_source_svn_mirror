<template>
  <com-textarea
    :content="text"
    idTextarea="com-textarea-round"
    propMaxlength="2048"
    defaultHeight="98%"
    :class="['textarea-popover', modalMessageSize]"
    cssClass="textarea-custom-text-font"
    @set-content-data="setContentData"
  />
</template>

<script>
import { mapGetters, mapActions } from "vuex";
import CommonTextArea from "@/components/common/CommonTextArea";

/**
 * @description 内容テンプレートモーダルコンポーネント
 */
export default {
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
    this.text = this.getEditRecord["content"];
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    commitText() {
      // 編集中マスタを更新
      this.setEditRecord({
        ...this.getEditRecord,
        content: this.text
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
div >>> textarea {
  box-sizing: border-box;
  width: 100%;
  /*// add マスタ障害対応 No279 王 start*/
  /*height: 250px;*/
  height: auto;
  /*// add マスタ障害対応 No279 王 start*/
}

.textarea-popover {
  box-sizing: border-box;
  width: 99.9%;
  overflow-y: auto;
  height: 100%;
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
