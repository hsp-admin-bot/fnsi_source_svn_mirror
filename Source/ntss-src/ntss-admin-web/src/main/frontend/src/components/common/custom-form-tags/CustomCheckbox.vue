<template>
  <label :class="classObject">
    <v-ons-checkbox
      v-model="checked"
      :value="editValue"
      :disabled="disabled"
      @change="changeValue"
      v-bind="$attrs"
    />
    <span> <slot></slot> </span>
  </label>
</template>

<script>
// 共通タグ用ベースコンポーネント
import baseCustomForm from "@/components/common/custom-form-tags/BaseCustomForm";

/**
 * @description 共通チェックボックスタグ
 * @summary
 *   ■props
 *     checkedValue(必須): チェック状態の値
 *     uncheckedValue(必須): 未チェック状態の値
 * @example
 *   <custom-checkbox
 *     :value="{ initValue, editValue }"
 *     :checked-value="1"
 *     :unchecked-value="0" />
 *
 *   ⇒ editValueの値はチェック時に1、未チェック時に0となる
 */
export default {
  inheritAttrs: false,
  mixins: [baseCustomForm],

  props: {
    checkedValue: {
      type: [Number, String],
      required: true
    },

    uncheckedValue: {
      type: [Number, String],
      required: true
    },

    disabled: {
      type: Boolean,
      default: false
    }
  },

  data() {
    return {
      checked: false
    };
  },

  computed: {
    classObject() {
      return {
        // 常に適用されるclass
        "custom-checkbox": true,
        // 編集時に適用されるclass
        "custom-checkbox-edited": this.isEdited,
        // 文字選択無効class
        "custom-checkbox-select-disabled": true,
        "disabled-opacity": this.disabled
      };
    }
  },

  watch: {
    editValue() {
      // ons-checkboxチェック処理
      this.checked = this.editValue === this.checkedValue;
    }
  },

  created() {
    // ons-checkboxの初期チェック処理
    if (this.editValue === this.checkedValue) {
      this.checked = true;
    }
  },

  methods: {
    changeValue(event) {
      const value = event.target.checked
        ? this.checkedValue
        : this.uncheckedValue;
      this.editValue = value;
      // change発生直後のevent.target.valueはチェックを切り替える前の値なので書き換えた値を拾えるようにする
      event.target.value = value;
    }
  }
};
</script>

<style scoped>
.custom-checkbox-edited {
  color: green;
  font-weight: bold;
}

.custom-checkbox-select-disabled {
  user-select: none;
}

.disabled-opacity :deep(ons-checkbox) {
  /* 非活性時の不透明度を上げる(onsenのデフォルトだと見づらい) */
  opacity: 1;
}
</style>
