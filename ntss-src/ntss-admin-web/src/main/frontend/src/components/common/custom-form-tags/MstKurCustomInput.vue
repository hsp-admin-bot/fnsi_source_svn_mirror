<template>
  <!-- mod FNSI-inputの色 鄭 start -->
  <!-- <v-ons-input
    type="text"
    class="ntss-custom-input"
    v-model="valueInput"
    :class="classObject"
    :disabled="disabled"
    @blur="validate()"
    v-bind="$attrs"
  /> -->
  <v-ons-input
    type="text"
    v-model="valueInput"
    :class="classObject"
    :disabled="disabled"
    v-bind="$attrs"
  />
  <!-- mod FNSI-inputの色 鄭 end -->
</template>

<script>
// 共通タグ用ベースコンポーネント
import baseCustomForm from "@/components/common/custom-form-tags/BaseCustomForm";

/**
 * @description 共通テキスト入力タグ
 * @summary
 *   ■props
 *     displayString(任意): value属性に与えた値の代わりに表示したい文字列
 *       ※たぶんマスタ選択と一緒に使うときくらいしか使い道ない
 * @example
 *   <custom-input
 *     :value="{ initValue, editValue: マスタのコード }"
 *     :display-string="マスタの名称" />
 */
export default {
  inheritAttrs: false,
  mixins: [baseCustomForm],

  props: {
    displayString: {
      type: String,
      default: null
    },
    disabled: {
      default: false
    }
  },

  computed: {
    // 入力欄に表示する値
    valueInput: {
      get() {
        let value;
        if (this.displayString === null) {
          value = this.editValue;
        } else {
          value = this.displayString;
        }
        return value;
      },
      set(value) {
        if (value === "") {
          value = null;
        }
        this.editValue = value;
      }
    },

    classObject() {
      return {
        // ※属性セレクタ[disabled]で指定すると他のスタイルより優先されてしまうので作成
        "custom-input-disabled": this.disabled,
        // 必須項目に適用されるclass
        "custom-input-required": this.isRequired,
        // データ不正時に適用されるclass
        "custom-input-invalid": !this.isValid
      };
    }
  },

  // add FNSI-inputの色 鄭 start
  methods:{
    // addFocusCss(event){
    //   let element = event.target;
    //   element?.classList?.add("custom-input-edited");
    // },
    // delFocusCss(event){
    //   if(!this.isEdited){
    //     let element = event.target;
    //     element.classList.remove("custom-input-edited");
    //   }
    // }
  }
  // add FNSI-inputの色 鄭 end
};
</script>

<style scoped>
/* input {
  color: var(--ntss-list-body-color);
  background-color: var(--ntss-list-background-color);
} */

/* .custom-input-edited {
  border: 2px green solid;
  outline: 0;
} */

.custom-input-required {
  color: black;
  background-color: #ffff99;
}

.custom-input-invalid {
  color: black;
  background-color: rgba(255, 0, 0, 0.5);
}
</style>
