<template>
  <v-ons-select
    v-model="selectedValue"
    :class="classObject"
    :disabled="disabled"
    v-bind="$attrs"
  >
    <option :value="null"></option>
    <option
      v-for="(option, index) in options"
      :key="index"
      :value="option.value"
    >
      {{ option.displayValue }}
    </option>
  </v-ons-select>
</template>

<script>
// 共通タグ用ベースコンポーネント
import baseCustomForm from "@/components/common/custom-form-tags/BaseCustomForm";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

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
  inheritAttrs: false,
  mixins: [baseCustomForm],

  props: {
    options: {
      type: Array,
      required: true,
      validator: options => {
        return options.every(
          option =>
            Object.keys(option).length === 2 &&
            Object.prototype.hasOwnProperty.call(option, "value") &&
            Object.prototype.hasOwnProperty.call(option, "displayValue")
        );
      }
    },
    disabled: {
      default: false
    },
    name: {
      type: String
    },
    json: {
      type: Object
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
    
  watch: {
    selectedValue(value) {
      if (value && this.name !== "insu_cd") {
        let tempData = [];
        ["insu_pub1_cd", "insu_pub2_cd", "insu_pub3_cd", "insu_pub4_cd"].map(key => {
          tempData.push(this.json.insu_set_info[key].editValue)
        })
        let count = 0;
        for (var i = 0; i < tempData.length; i++) {
          if (tempData[i] == value) {
            count ++;
            if (count == 2) {
              this.$ons.notification.alert({
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // title: "",
                // message: "一つのセットに同じ公費が選択できません。"
                title: DIALOG_MESSAGES[12000195].title,
                message: messageFormat(DIALOG_MESSAGES[12000195].message)
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              });
              this.editValue = null;
              this.$nextTick(() => {
                const selectEl = this.$el;

                if (selectEl) {
                  selectEl.selectedIndex = 0;
                  selectEl.value = "";
                }
              });
              break; // stop the loop
            }
          }
        }
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

.custom-select-edited {
  color: green;
  font-weight: bold;
}

.custom-select-required {
  background-color: #ffff99;
}

.custom-select-invalid {
  background-color: rgba(255, 0, 0, 0.5);
}

.custom-select-disabled {
  background-color: silver;
  cursor: not-allowed; /* 禁止カーソル */
  border-radius : 5px;
}

.custom-select {
  max-width: 400px;
}
</style>
