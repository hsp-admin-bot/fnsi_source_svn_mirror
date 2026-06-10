<template>
  <div v-if="autoWidth">
    <textarea
      ref="main"
      rows="1"
      :class="classList"
      v-on="listeners"
      :value="value"
      :disabled="disabled"
      @focus="onFocus()"
      @blur="onBlur($event)"
      @keydown.enter="onEnter"
    ></textarea>
    <textarea
      ref="shadow"
      rows="1"
      class="auto-width-shadow"
      :class="classList"
      :value="value"
      :disabled="disabled"
    ></textarea>
  </div>
  <textarea
    v-else
    ref="main"
    rows="1"
    :class="classList"
    v-on="listeners"
    :value="value"
    :disabled="disabled"
    @focus="onFocus()"
    @blur="onBlur($event)"
    @keydown.enter="onEnter"
  ></textarea>
</template>

<script>
/**
 * @description 共通部品：簡易テキストエリアタグ(typeB：BaseCustomFormを継承しない)
 * ・関連付けられる値が { initValue:値, editValue：値 } 形式の場合は、typeA を使用してください。
 * ・<input type="text"/> 部品を、入力内容が入りきらない場合に改行して表示可能とする為の置き換え用部品です。
 *   <input type="text"/> は折り返し表示ができない為、部品を分けています。
 * ・@keydown.enter.prevent：enterキーで改行しないようする為の定義です。
 *
 * @summary
 *   ■ props
 *     value：入力データ
 *     disabled：無効状態
 * @example
 *   <custom-simple-textarea-b
 *     v-model="value"
 *     :disabled="disabled" (必要に応じて)
 *   />
 *   ※ v-model は、:value="value" @input="value = value(戻り値)" と同じ動作をします。
 *   ※ v-on="listeners" の定義によりイベントが伝番する為、@blur等のイベントはそのまま使用可能です。
 */

import { mapGetters } from "vuex";

export default {
  props: {
    value: {
      type: String,
      default: ""
    },
    disabled: {
      type: Boolean,
      default: false
    },
    autoWidth: {
      type: Boolean,
      default: false
    },
    lineBreakabled: {
      type: Boolean,
      default: false
    },
    // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start
    initValue: {
      type: String,
      default: ""
    },
    isEdit: {
      type: Boolean,
      default: false
    },
    // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end
  },

  data() {
    return {
      resizeFlg: false,
      // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start
      isOnFocus: false,
      // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end
      resizeObserver: null,
    };
  },
  computed: {
    ...mapGetters("account-edit", {
      fontSize: "getFontSize",
    }),
    ...mapGetters("window-size", {
      windowWidth: "getWindowWidth",
      sidebarWidth: "getSidebarWidth",
    }),

    /* v-on="$listeners" により応答される @input の応答データ補正処理です */
    listeners() {
      return {
        ...this.$listeners,
        input: event => this.$emit('input', event.target.value),
      };
    },
    // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start
    classList() {
      let isChanged = true;
      if ((this.value === this.initValue) || (!this.value && !this.initValue)) {
        if (this.isOnFocus) {
          isChanged = true;
        } else {
          isChanged = false;
        }
      }
      return {
        "cs-textarea-typeb": true,
        "auto-width": this.autoWidth,
        "custom-textarea-edited": isChanged && this.isEdit,
      };
    },
    // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end
  },

  watch: {
    value() {
      this.resizeTextarea();
    },
    fontSize() {
      this.resizeTextarea();
    },
    windowWidth() {
      this.resizeTextarea();
    },
    sidebarWidth() {
      this.resizeTextarea();
    },
    resizeFlg() {
      // value と 戻りが異なる場合や、変更を検知しないで動作している箇所の対応
      this.resizeTextarea();
    },
    autoWidth() {
      this.$nextTick(() => {
        this.startStopResizeObserver();
      });
    },
  },

  methods: {
    resizeTextarea() {
      const el = this.$refs.main;
      setTimeout(() => {
        el.style.height = "auto";
        // mod 8499 ljx start
        //el.style.height = ( el.scrollHeight + 4 ) + "px";
        el.style.height = ( el.scrollHeight === 0?30:el.scrollHeight + 4 ) + "px";
        // add 8499 ljx end
        if (this.autoWidth) {
          this.updateWidth();
        }
      }, 0);
    },
    updateWidth() {
      const el = this.$refs.main;
      const shadow = this.$refs.shadow;
      const computedStyle = getComputedStyle(shadow);
      const borderWidth = Math.ceil(
        parseFloat(computedStyle.borderLeftWidth)
        + parseFloat(computedStyle.borderRightWidth)
        + parseFloat(computedStyle.paddingInlineStart)
        + parseFloat(computedStyle.paddingInlineEnd)
      );
      // 入力内容が現在のwidth設定より短くなる場合にもscrollWidthに反映させるために
      // 一度width指定をautoにする
      shadow.style.width = "auto";
      shadow.style.minWidth = "auto";
      const newWidth = shadow.scrollWidth + borderWidth;
      // 幅を広げる場合以外は親要素などにあわせて縮むように
      // shadow.style.width は auto のままにしておく
      if (newWidth > parseFloat(computedStyle.width)) {
        el.style.width = shadow.style.width = `${newWidth}px`;
      }
    },
    startStopResizeObserver() {
      if (this.autoWidth) {
        this.startResizeObserver();
      } else {
        this.stopResizeObserver();
      }
    },
    startResizeObserver() {
      if (!this.resizeObserver) {
        this.resizeObserver = new ResizeObserver(this.onResize);
        this.resizeObserver.observe(this.$refs.main);
      }
    },
    stopResizeObserver() {
      if (this.resizeObserver) {
        this.resizeObserver.disconnect();
        this.resizeObserver = null;
      }
    },
    onResize() {
      if (this.autoWidth) {
        this.resizeTextarea();
      }
    },
    onEnter(event) {
      if (!this.lineBreakabled) {
        event.preventDefault();
      }
    },
    // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start
    onBlur(event) {
      this.isOnFocus = false;
      this.$emit("blur", event);
    },
    onFocus() {
      this.isOnFocus = true;
    },
    // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end
  },

  mounted() {
    this.startStopResizeObserver();
    this.resizeTextarea();
  },
  beforeDestroy() {
    this.stopResizeObserver();
  },
};
</script>

<style scoped>
.cs-textarea-typeb {
  box-sizing: border-box;
  font-style: inherit;
  font-weight: inherit;
  font-size: inherit;
  line-height: 1.5em;
  font-family: inherit;
  letter-spacing: inherit;
  resize: none;
  word-break: break-all;
  color: var(--time-input-color);
  background-color: var(--time-input-background-color);
  /* 縦幅の最大を、表示領域の30%に指定 */
  max-height: 30vh;
}

/* スクロールバー領域の除去(スクロールは可能) */
.cs-textarea-typeb::-webkit-scrollbar {
  display: none;
}

.auto-width {
  width: auto;
  white-space: nowrap;
}
.auto-width-shadow {
  position: fixed;
  visibility: hidden;
}

/* disabled 状態になった際のスタイル */
textarea[disabled] {
  pointer-events: none;
  cursor: default;
  color: #a6a6a2;
  background-color: #ebebe4;
}
/* add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start */
.custom-textarea-edited {
  border: 2px green solid !important;
  outline: 0 !important;;
}
/* add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end */
</style>
