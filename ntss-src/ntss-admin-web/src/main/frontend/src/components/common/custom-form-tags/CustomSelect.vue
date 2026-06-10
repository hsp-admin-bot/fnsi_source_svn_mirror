<template>
  <v-ons-select
    v-model="selectedValue"
    :class="classObject"
    :disabled="disabled"
    v-on="$listeners"
    @blur="delFocusCss($event)"
    @focus="addFocusCss($event)"
  >
    <!-- #10266 スケジュール親/子ヘッダー押下　NG linjunfeng start -->
    <!-- <option
      v-for="(option, index) in options"
      :key="index"
      :value="option.value"
    > -->
    <option
      v-for="(option, index) in options"
      :key="index"
      :value="option.value"
      v-show="option.isShow !== false"
    >
    <!-- #10266 スケジュール親/子ヘッダー押下　NG linjunfeng end -->
      {{ option.displayValue }}
    </option>
  </v-ons-select>
</template>

<script>
import _ from "underscore";
// 共通タグ用ベースコンポーネント
import baseCustomForm from "@/components/common/custom-form-tags/BaseCustomForm";

/**
 * @description 共通プルダウンメニュータグ
 * @summary
 *   ■props
 *     options(必須): 項目オブジェクトの配列([{ value(実際の値), displayValue(表示する値) }, ...])
 * @example
 *   <custom-select
 *     :value="{ initValue, editValue }"
 *     :options="[
 *       { value: 1, displayValue: '項目1' },
 *       { value: 2, displayValue: '項目2' },
 *     ]"
 *   />
 *
 *   ⇒ 項目1、または項目2を選択可能なプルダウンメニュー
 */
export default {
  mixins: [baseCustomForm],

  props: {
    options: {
      type: Array,
      required: true,
      validator: options => {
        return options.every(
          option =>
            // #10266 スケジュール親/子ヘッダー押下　NG linjunfeng start
            // _.keys(option).length === 2 &&
            _.keys(option).length >= 2 &&
            // #10266 スケジュール親/子ヘッダー押下　NG linjunfeng end
            _.has(option, "value") &&
            _.has(option, "displayValue")
        );
      }
    },
    disabled: {
      default: false
    }
  },

  computed: {
    // v-modelでないとoptionのvalueが文字列になってしまうのでそれ用のプロパティを定義
    selectedValue: {
      get() {
        return this.editValue;
      },

      set(value) {
        this.editValue = value;
      }
    },

    classObject() {
      return {
        // 常に適用されるclass
        "custom-select": true,
        // disabled時に適用されるclass
        "custom-select-disabled": this.disabled,
        // 編集時に適用されるclass
        "custom-select-edited": this.isEdited,
        // 必須項目に適用されるclass
        "custom-select-required": this.isRequired,
        // データ不正時に適用されるclass
        "custom-select-invalid": !this.isValid
      };
    }
  },

  methods:{
    addFocusCss(event){
      let element = event.target;
      element?.classList?.add("custom-select-edited");
    },
    delFocusCss(event){
      if(!this.isEdited){
        let element = event.target;
        element.classList.remove("custom-select-edited");
      }
    }
  }
};
</script>

<style scoped>
select {
  color: var(--ntss-list-body-color);
  background-color: var(--ntss-list-background-color);
}

.custom-select-disabled {
  background-color: silver;
  cursor: not-allowed; /* 禁止カーソル */
  border-radius : 5px;
}
</style>
