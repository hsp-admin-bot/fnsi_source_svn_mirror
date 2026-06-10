<template>
  <!--mod FNSI-画面部品デザイン じょはく start-->
  <textarea
    :value="editValue"
    :class="classObject"
    @input="inputValue($event)"
    @focus="inputValue"
    @blur="validate()"
    v-on="$listeners"
  ></textarea>
  <!--mod FNSI-画面部品デザイン じょはく end-->
</template>

<script>
import { EventBus } from "@/eventBus.js";
// 共通タグ用ベースコンポーネント
import baseCustomForm from "@/components/common/custom-form-tags/BaseCustomForm";

/**
 * @description 共通テキストエリアタグ
 */
// TODO: 初期表示時に文字列の長さでrows属性が固定されるので、例えば2行から1行になっても高さが2行分になってしまう
export default {
  mixins: [baseCustomForm],
  props: {
    isRisize: {
      type: Boolean,
      default: true
    }
  },

  computed: {
    classObject() {
      return {
        // 常に適用されるclass
        "custom-textarea": true,
        // 編集時に適用されるclass
        "custom-textarea-edited": this.isEdited,
        // 拡張無効class
        "custom-textarea-disabled-resize": true
      };
    }
  },
  data() {
    return {
      // 高低差
      differenceHeight: 0
    };
  },
  watch: {
    editValue() {
      this.isValid = true;
    }
  },
  methods: {
    inputValue(event) {
      let value = event.target.value;

      // リサイズ処理
      if (this.isRisize) {
        // 高さ計算
        const getHeight = (textarea) => {
          const style = getComputedStyle(textarea);
          return parseFloat(textarea.scrollHeight) + 
                  parseFloat(style.borderTopWidth) + 
                  parseFloat(style.borderBottomWidth);
        }

        // 内部要素の高さが、外部要素を超えた場合、高さを更新
        let height = getHeight(event.target);
        if (event.target.offsetHeight < Math.floor(height)) {
          // 高さを計算値と完全に同じにした場合、scroll判定を受ける場合がある為"0.5"加算
          event.target.style.height = height + 0.5 + "px";
        }
      }

      // 値の反映
      this.editValue = value;
    },

    resizeTextarea(el) {
      if (!this.initValue || !this.editValue) {
        el.style.height = this.defaultHeight || "40px";
      } else {
        if (el.scrollHeight < 40) {
          el.style.height = "40px";
        } else {
          el.style.height = `${el.scrollHeight + 5}px`;
        }
      }
    }
  },

  mounted() {
    this.resizeTextarea(this.$el);
    EventBus.$on('updateDifferenceHeight',()=>{
      this.differenceHeight = 0;
    })
  },
  // add 6119 ブラウザがOut of Memoryのエラーが発生する 史
  beforeDestroy() {
    EventBus.$off('updateDifferenceHeight');
  }
};
</script>

<style scoped>
textarea {
  font-family: helvetica, arial, "hiragino kaku gothic pro", meiryo,
    "ms pgothic", sans-serif;
  /*mod FNSI-画面部品デザイン じょはく start*/
  /*overflow-y: auto;*/
  min-height: 40px;
  max-height: 80vh;
  /*mod FNSI-画面部品デザイン じょはく end*/
  background-color: #F7F7F7;
  padding: 5px !important;
}

.custom-textarea-edited {
  border: 2px green solid;
  outline: 0;
}

/* テキストエリア拡張禁止 */
.custom-textarea-disabled-resize {
  resize: none;
}
</style>
