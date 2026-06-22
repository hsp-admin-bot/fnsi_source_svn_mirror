<template>
  <div>
    <textarea
      :value="editValue"
      :class="classObject"
      @input="inputValue"
      @focus="inputValue"
      @blur="validate()"
      @mousedown="checkLongPress(1)"
      @mouseup="checkLongPress(0)"
      @mouseleave="checkLongPress(0)"
      @touchstart="checkLongPress(1)"
      @touchend="checkLongPress(0)"
      v-bind="$attrs"
      ref="popoverTarget"
    ></textarea>
    <pop-over-fixed-phrase
      v-if="popoverData.popoverVisible"
      v-bind="popoverData"
      :target-position-element="popoverTargetElement"
      @popover-close="popoverData.popoverVisible = false"
      @popover-return="insertPhrase"
    />
  </div>
</template>

<script>
// 共通タグ用ベースコンポーネント
import baseCustomForm from "@/components/common/custom-form-tags/BaseCustomForm";
// 個人用/共通定型文選択用セレクター
import MasterSelectorFixedPhrase from "@/components/common/master-selector/MasterSelectorFixedPhrase";

/**
 * @description 共通テキストエリアタグ
 */
export default {
  inheritAttrs: false,
  data() {
    return {
      popoverData: {
        popoverVisible: false,
        popoverDisplayDirection: "right"
      },
      blowTimer: 0,
      popoverTargetElement: null
    }
  },

  components: {
    "pop-over-fixed-phrase": MasterSelectorFixedPhrase
  },

  mixins: [baseCustomForm],

  computed: {
    classObject() {
      return {
        // 常に適用されるclass
        "custom-textarea-with-fixed-phrase": true,
        // 編集時に適用されるclass
        "custom-textarea-edited": this.isEdited
      };
    }
  },

  mounted() {
    // 吹き出し表示の対象を設定
    this.popoverTargetElement = this.$refs.popoverTarget;
  },

  methods: {
    inputValue(event) {
      let value = event.target.value;
      if (value === "") {
        value = null;
      }
      this.editValue = value;
      this.resizeTextarea(event.target);
    },

    resizeTextarea(el) {
      el.style.height = `${el.scrollHeight}px`;
    },

    /**
     * @description テキストエリア内の文字と定型メモの結合
     * @param data 挿入する定型文
     */
    insertPhrase(data) {
      // 定型文をテキストエリアに反映
      const target = this.$refs.popoverTarget;
      target?.focus?.();
      target?.ownerDocument?.execCommand?.('insertText', false, data.text);
    },

    /**
     * 定型文選択 長押しウォッチャー
     */
    checkLongPress(isMouseDown) {
      if (isMouseDown) {
        this.blowTimer = setTimeout(() => {
          this.popoverData.popoverVisible = true;
        }, 2000);
      } else {
        clearTimeout(this.blowTimer);
      }
    },
  }

};
</script>

<style scoped>
textarea {
  font-family: helvetica, arial, "hiragino kaku gothic pro", meiryo,
    "ms pgothic", sans-serif;
  overflow-y: hidden;
  color: var(--ntss-list-body-color);
  background-color: var(--ntss-list-background-color);
  resize: vertical;
  font-size: inherit;
  display: inline-block;
  width: 100%;
  box-sizing: border-box;
}

.custom-textarea-edited {
  border: 2px green solid;
  outline: 0;
}

</style>
