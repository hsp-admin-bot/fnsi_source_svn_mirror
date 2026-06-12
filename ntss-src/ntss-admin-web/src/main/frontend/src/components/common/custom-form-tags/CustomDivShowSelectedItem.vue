<template>
  <div class="custom-div-show-selected-item" :class="chkEdited" :style="bgColor">{{selectedItem}}</div>
</template>

<script>
/**
 * @description 共通部品：選択アイテム表示項目
 * @summary
 *   ■props
 *     propInitValue：選択アイテム名(初期値)
 *     propEditValue(必須): 選択アイテム名(変更後の値)
 *     propBackgroundColor: 項目の背景色 ( 無効色、必須色等 )
 * @example
 *   <show-selected-item
 *     :propSelectedItem="選択アイテム"
 *     :propBackgroundColor="#ebebe4" />
 */
export default {
  props: {
    // 初期値
    propInitValue: {
      type: String,
      default: ""
    },
    // 変更後の値
    propEditValue: {
      type: String,
      default: ""
    },
    propBackgroundColor: {
      type: String,
      default: "#fafafa"
    }
  },

  data() {
    return {
      initValue: null
    };
  },

  computed: {
    selectedItem() {
      return this.propEditValue;
    },
    chkEdited() {
      // mod #10937 20260428 Ji start
      const init = this.initValue ?? "";
      const edit = this.selectedItem ?? "";
      // if (this.initValue !== this.selectedItem) {
      if (init !== edit) {
        return "custom-div-show-selected-item-edited";
      } else {
        return "";
      }
      // mod #10937 20260428 Ji end
    },
    bgColor() {
      return { "background-color": this.propBackgroundColor };
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc start
    isEdited() {
      return this.initValue != this.selectedItem;
    }
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc end
  },

  watch: {
    propInitValue() {
      // 初期値の変動があった場合に反映
      this.initValue = this.propInitValue;
    }
  },

  created() {
    // mod #10937 20260428 Ji start
    // 初期値の指定がなかった場合は、propEditValue の値を設定しておく
    // if (this.propInitValue === "") {
    //   this.initValue = this.propEditValue;
    // } else {
    //   this.initValue = this.propInitValue;
    // }
    this.initValue = this.propInitValue;
    // mod #10937 20260428 Ji end
  },

};
</script>

<style scoped>
.custom-div-show-selected-item {
  height: auto;
  min-height: 2em;
  display: flex;
  align-items: center;
  color: #1f1f21;
  border-width: 2px;
  border-radius: 5px;
  border-style: inset;
  box-sizing: border-box;
  word-break: break-all;
}
.custom-div-show-selected-item-edited {
  border: 2px green solid;
  outline: 0;
}
</style>
