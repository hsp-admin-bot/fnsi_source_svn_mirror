<template>
  <label :class="classObject">
    <!-- FNSI-治療方法説明文の表示を修正 周 mod start -->
    <!-- <v-ons-radio
      modifier="round"
      :name="name"
      :value="radioValue"
      v-model="editValue"
      :disabled="disabled"
      @change="changeValue()"
      v-on="$listeners"
    >
    </v-ons-radio> -->
    <v-ons-radio
      modifier="round"
      :input-id="inputId"
      :name="name"
      :value="radioValue"
      v-model="editValue"
      :disabled="disabled"
      @change="changeValue()"
      v-on="$listeners"
    >
    </v-ons-radio>
    <!-- FNSI-治療方法説明文の表示を修正 周 mod end -->
    <span> <slot></slot> </span>
  </label>
</template>

<script>
// 共通タグ用ベースコンポーネント
import baseCustomForm from "@/components/common/custom-form-tags/BaseCustomForm";

/**
 * @description 共通ラジオボタンタグ
 * @summary
 *   ■props
 *     name(必須): name属性
 *     radioValue(必須): チェック状態の値
 *   ■slot
 *     項目名
 * @example
 *   <custom-radio
 *     :value="{ initValue, editValue }"
 *     name="item"
 *     :radio-value="1">
 *     項目1
 *   </custom-radio>
 *   <custom-radio
 *     :value="{ initValue, editValue }"
 *     name="item"
 *     :radio-value="2">
 *     項目2
 *   </custom-radio>
 *
 *   ⇒ 項目1、または項目2を選択可能なラジオボタン
 */
export default {
  mixins: [baseCustomForm],

  props: {
    // FNSI-治療方法説明文の表示を修正 周 add start
    inputId: {
      type: String
    },
    // FNSI-治療方法説明文の表示を修正 周 add end

    name: {
      type: String,
      required: true
    },

    radioValue: {
      required: true
    },

    disabled: {
      type: Boolean,
      default: false
    }
  },

  computed: {
    // FNSI-治療方法説明文の表示を修正 周 add start
    // チェックフラグ
    isChecked() {
      return this.radioValue === this.editValue;
    },
    // FNSI-治療方法説明文の表示を修正 周 add end
    classObject() {
      return {
        // 常に適用されるclass
        "custom-radio": true,
        // 編集時に適用されるclass
        "custom-radio-edited": this.isEdited,
        // FNSI-治療方法説明文の表示を修正 周 add start
        "custom-radio-checked": this.isChecked,
        // FNSI-治療方法説明文の表示を修正 周 add end
        // add FNSI-画面部品デザイン じょはく start
        "custom-radio-required": this.isRequired,
        "custom-radio-invalid": !this.isValid
        // add FNSI-画面部品デザイン じょはく end
      };
    }
  },
  watch: {
    editValue() {
      this.editValue = this.changeString(this.editValue);
    },
    initValue() {
      this.initValue = this.changeString(this.initValue);
    }
  },
  created() {
    this.editValue = this.changeString(this.editValue);
    this.initValue = this.changeString(this.initValue);
  },
  methods: {
    changeValue() {
      this.editValue = this.radioValue.toString();
    },
    changeString(value) {
      if (
        typeof value === "number" ||
        typeof value === "string" ||
        typeof value === "boolean"
      ) {
        return value.toString();
      } else if (value === null) {
        return "";
      } else {
        return value;
      }
    }
  },
};
</script>

<style scoped>
.custom-radio-edited {
  color: green;
  font-weight: bold;
}

/*add FNSI-画面部品デザイン じょはく start*/
.custom-radio-required {
  color: black;
  background-color: #ffff99;
}

.custom-radio-invalid {
  color: black;
  background-color: rgba(255, 0, 0, 0.5);
}
/*add FNSI-画面部品デザイン じょはく end*/
</style>
