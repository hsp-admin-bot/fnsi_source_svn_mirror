<template>
  <div :style="getDefaultHeight()">
    <!-- #9287 テキストエリアの入力で予測変換が保存不可 keyupをblurに変更しました linjunfeng start-->
    <custom-textarea
      :id="idTextarea"
      :maxlength="propMaxlength"
      :value="commentContent"
      :class="cssClass"
      :disabled="disabled"
      :model-event="modelEvent"
      :ref="refProp"
      :rows="rows"
      :cols="cols"
      :defaultHeight="defaultHeight"
      :isRisize="isRisize"
      @dragstart="whenDragStart"
      @touchstart="onDblTap"
      @touchend="endLongTouch"
      @mousedown="checkCommentLongPress($event, 1)"
      @mouseup="checkCommentLongPress($event, 0)"
      @dblclick="showPopover"
      @input="setContent"
      @mousemove="whenMouseMouve"
      @mouseout="whenMouseOut"
      v-on="$listeners"
    />
    <!-- #9287 テキストエリアの入力で予測変換が保存不可 keyupをblurに変更しました linjunfeng end-->
    <pop-over-fixed-phrase
      v-if="popoverData.popoverVisible"
      v-bind="popoverData"
      :target-position-element="popoverTargetElement(refProp)"
      @popover-close="closePopover"
      @popover-return="selectPhrase"
    />
  </div>
</template>

<script>
// import MasterSelectorFixedPhrase from "@/components/common/master-selector/MasterSelectorFixedPhrase";
import customTextarea from "@/components/common/custom-form-tags/CustomTextarea";
import $$ from "jquery";
import { mapGetters } from "vuex";

export default {
  components: {
    "pop-over-fixed-phrase": () => import("@/components/common/master-selector/MasterSelectorFixedPhrase"),
    "custom-textarea": customTextarea
  },

  props: {
    cssClass: {
      type: [Array, String],
      default: () => []
    },
    idTextarea: {
      type: String,
      default: ""
    },
    content: {
      type: [Object, String, Array],
      default: () => []
    },
    propMaxlength: {
      type: String,
      default: ""
    },
    modelEvent: {
      type: String,
      default: ""
    },
    disabled: {
      type: Boolean,
      default: false
    },
    rows: {
      type: String,
      default: ""
    },

    cols: {
      type: String,
      default: ""
    },

    refProp: {
      type: String,
      default: "commentRef"
    },

    defaultHeight: {
      type: String,
      default: null
    },
    isRisize: {
      type: Boolean,
      default: true
    }
  },

  data() {
    return {
      // 指示コメント内容
      commentContentCustomTextArea: {
        initValue: null,
        editValue: null
      },
      // 定型文情報
      popoverData: {
        popoverVisible: false,
        popoverDisplayDirection: "right"
      },

      /**
       * @description 「共通定型文」マスタ選択用タイマー(長押し機能)
       */
      commentTimer: 0,
      tapedTwice: false,
      isSetStyleHeight: false
    };
  },

  computed: {
    ...mapGetters("account-edit", ["getFontSize"]),
    commentContent() {
      this.setValueTextArea();
      return this.commentContentCustomTextArea;
    }
    //mod FNSI-5639 劉全航 start
    ,isEdited(){
      return this.content.editValue != this.content.initValue;
    }
    //mod FNSI-5639 劉全航 end
  },
  methods: {
    /**
     * 定型文ポップオーバー表示
     */
    showPopover() {
      //#9819 mod 利用者マスタの患者情報編集権限をOFFにした際に患者情報画面で入外区分の編集/保存ができる 2023-11-01 卓 start
      if (this.disabled) {
        return
      }
        this.popoverData.popoverVisible = true;
      //#9819 mod 利用者マスタの患者情報編集権限をOFFにした際に患者情報画面で入外区分の編集/保存ができる 2023-11-01 卓  end
    },

    /**
     * 定型文ポップオーバー非表示
     */
    closePopover() {
      this.popoverData.popoverVisible = false;
    },
    /**
     * 定型文の挿入
     */
    selectPhrase(data) {

      let element = document.getElementById(this.idTextarea);
      const currentPos = element.selectionStart;
      //挿入する文字列
      const strInsert = data.text;
      const strOriginal = element.value;
      // カーソル位置より左の文字列
      const leftPart = strOriginal.substr(0, currentPos);
      // カーソル位置より右の文字列
      const rightPart = strOriginal.substr(currentPos,strOriginal.length);
      // 文字列を結合
      const newValue = leftPart + strInsert + rightPart;

      element.value = newValue;
      this.commentContentCustomTextArea.editValue = newValue;
      this.$emit("set-content-data", newValue);
    },

    /**
     * @description 「コメント」テキストエリアの長押しウォッチャー
     */
    checkCommentLongPress(event, isMouseDown) {
      if (isMouseDown && !this.checkMoveToScrollBar(event)) {
        this.commentTimer = setTimeout(() => {
          this.showPopover();
        }, 500);
      } else {
        clearTimeout(this.commentTimer);
      }
    },

    setContent() {
      const element = document.getElementById(this.idTextarea);
      this.$emit("set-content-data", element.value);
    },

    whenMouseMouve() {
      clearTimeout(this.commentTimer);
    },

    whenMouseOut() {
      clearTimeout(this.commentTimer);
    },

    checkMoveToScrollBar(data) {
      const element = data.target;
      const elemPosition = element.$el ? element.$el.getBoundingClientRect() : element.getBoundingClientRect();
      const scrollRigthPos = elemPosition.right - 20;
      const scrollBottomPos = elemPosition.bottom - 20;

      return ((element.scrollHeight  > element.clientHeight && data.clientX >= scrollRigthPos) ||
          (element.scrollWidth > element.clientWidth && data.clientY >= scrollBottomPos))
    },

    whenDragStart() {
      const dragHandler = () => {
        return function(e) {
          e.stopPropagation();
        };
      };

      const element = $$('#' + this.idTextarea);
      element.on("dragstart", dragHandler());
      this.setContent();
    },

    popoverTargetElement(refName) {
      return this.$refs[`${refName}`];
    },

    onDblTap(event) {
      if (event.touches.length > 1) {
        // 2本以上同時にタップされた場合の処理(長押し処理を発火)
        this.setShowPopover = setTimeout(function() {
          this.showPopover();
        }.bind(this), 500);
      }
      // ダブルタップの処理
      if(!this.tapedTwice) {
        this.tapedTwice = true;
        setTimeout( () => { this.tapedTwice = false; }, 300 );
        return false;
      }
      event.preventDefault();
      this.showPopover();
    },

    endLongTouch(event) {
      if (event.touches.length < 1) {
        // 全ての指が離れたら長押し処理を解除
        clearTimeout(this.setShowPopover);
      }
    },

    getDefaultHeight() {
      this.$nextTick(() => {
        if (this.defaultHeight !== null && (this.commentContentCustomTextArea.initValue === null || this.commentContentCustomTextArea.initValue === "" ||
          this.commentContentCustomTextArea.editValue === null || this.commentContentCustomTextArea.editValue === "") ||
          this.isSetStyleHeight) {
          this.isSetStyleHeight = true;
          return 'height: 100% !important';
        } else {
          return '';
        }
      });
    },
    setValueTextArea() {
      if (this.content !== null) {
        if (typeof(this.content) === "object") {
          if (this.content.length > 0) {
            this.commentContentCustomTextArea.initValue = this.content[0] !== "" ? this.content[0] : null;
            this.commentContentCustomTextArea.editValue = this.content[0] !== "" ? this.content[0] : null;
          } else {
            this.commentContentCustomTextArea.initValue = this.content.initValue !== "" ? this.content.initValue : null;
            this.commentContentCustomTextArea.editValue = this.content.editValue !== "" ? this.content.editValue : null;
          }
        }else {
          this.commentContentCustomTextArea.initValue = this.content !== "" ? this.content : null;
          this.commentContentCustomTextArea.editValue = this.content !== "" ? this.content : null;
        }
      } else {
        this.commentContentCustomTextArea.initValue = null;
        this.commentContentCustomTextArea.editValue = null;
      }
    }
  },

  watch: {
    content() {
      this.setValueTextArea();
    },

    getFontSize() {
      if (this.isRisize) {
        const element = document.getElementById(this.idTextarea);
        element.style.height = "0px";
        element.style.height = `${element.scrollHeight + 5}px`;
      }
    }
  }
};
</script>

<style scoped>
.custom-textarea {
  width: 100%;
}

.textarea-resize-both {
  resize: both;
}

.textarea-resize-vertical {
  resize: vertical;
}

.textarea-resize-horizontal {
  resize: horizontal;
}

.textarea-custom-text-font {
  font-family: inherit;
  font-size: inherit;
}
</style>
