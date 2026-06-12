<template>
  <textarea
    rows="1"
    v-bind="$attrs"
    :value="valueInput"
    :class="classObject"
    @input="inputValue($event)"
    @focus="resizeTextareaEv"
    @blur="validate()"
    @keydown.enter.prevent
  ></textarea>
</template>

<script>
/**
 * @description 共通部品：簡易テキストエリアタグ(typeB：BaseCustomFormを継承する)
 * ・関連付けられる値が { initValue:値, editValue：値 } 形式の場合に使用する部品です。
 * ・<input type="text"/> 部品を、入力内容が入りきらない場合に改行して表示可能とする為の置き換え用部品です。
 *   <input type="text"/> は折り返し表示ができない為、部品を分けています。
 * ・@keydown.enter.prevent：enterキーで改行しないようする為の定義です。
 * 
 * @summary
 *   ■ props
 *     displayString: value属性に与えた値の代わりに表示したい文字列
 */

// 共通タグ用ベースコンポーネント
import baseCustomForm from "@/components/common/custom-form-tags/BaseCustomForm";
import { mapGetters } from "@/compat/vue/vuex";

export default {
  inheritAttrs: false,
  mixins: [baseCustomForm],

  props: {
    displayString: {
      type: String,
      default: null
    }
  },


  computed: {
    ...mapGetters("account-edit", { fontSize: "getFontSize" }),
    ...mapGetters("window-size", {
      windowWidth: "getWindowWidth",
      sidebarWidth: "getSidebarWidth"
    }),

    valueInput() {
      let value;
      if (this.displayString === null) {
        value = this.editValue;
      } else {
        value = this.displayString;
      }
       return value;
    },

    classObject() {
      return {
        // 常に適用されるclass
        "custom-textarea": true,
        // 編集時に適用されるclass
        "custom-textarea-edited": this.isEdited,
        // 必須項目に適用されるclass
        "custom-textarea-required": this.isRequired,
        // データ不正時に適用されるclass
        "custom-textarea-invalid": !this.isValid,
        // 拡張無効class
        "custom-textarea-disabled-resize": true
      };
    }
  },

  watch: {
    valueInput() {
      this.isValid = true;
      this.resizeTextarea(this.$el);
    },

    fontSize() {
      this.resizeTextarea(this.$el);
    },

    windowWidth() {
      this.resizeTextarea(this.$el);
    },
    
    sidebarWidth() {
      this.resizeTextarea(this.$el);
    }
  },

  methods: {
    inputValue(event) {
      this.editValue = event.target.value;
    },

    resizeTextareaEv(e) {
      setTimeout(() => {
        e.target.style.height = "auto";
        e.target.style.height = ( e.target.scrollHeight + 4 ) + "px";
      }, 0);
    },

    resizeTextarea(el) {
      setTimeout(() => {
        el.style.height = "auto";
        el.style.height = ( el.scrollHeight + 4 ) + "px";
      }, 0);
    }
  },

  mounted() {
    this.resizeTextarea(this.$el);
  }
};
</script>

<style scoped>
textarea {
  font-family: inherit;
  min-height: 2em;
  max-height: 30vh;
  line-height: 1.5em;
  word-break: break-all;
}

.custom-textarea-edited {
  border: 2px green solid;
  outline: 0;
}

/* テキストエリア拡張禁止 */
.custom-textarea-disabled-resize {
  resize: none;
}

.custom-textarea-required {
  background-color: #ffff99;
}

.custom-textarea::-webkit-scrollbar {
  display: none;
}

/* disabled 状態になった際のスタイル */
textarea[disabled] {
  pointer-events: none;
}
</style>