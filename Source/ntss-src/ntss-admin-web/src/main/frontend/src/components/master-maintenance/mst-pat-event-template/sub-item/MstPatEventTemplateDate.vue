<template>
<div>
  <table class="disp-item-area">
    <tr>
      <td class="item-title">デフォルト値</td>
      <td style="width: 15%;">
         <v-ons-select v-model="selectdateno">
          <option v-for="(item, index) in listDate" :key="index" :value="item.dateNo">
            {{ item.dateName }}
          </option>
        </v-ons-select>
      </td>
      <td>
      </td>
    </tr>
  </table>
</div>
</template>
<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
//import { ApiHelper } from "@/apis/AxiosHelper";
import {EventBus} from "@/compat/vue/event-bus.js";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start

import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import { getScopedElementsByClassName, queryScopedSelector, queryScopedSelectorAll } from "@/functions/common/LayoutMeasureHelper";
import { messageFormat } from "@/functions/common/MessageFormat";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
export default {
  name: "MstPatEventTemplateText",
  props: ["propsIndex"],
  data() {
    return {
      inputModel:{
        date_class: "0"
      },
      listDate:[
          {
            dateNo: "0",
            dateName: ""
          },
          {
            dateNo: "1",
            dateName: "当日"
          },

          /*  ADD カスタムフィールドデフォルト修正 楊 START */

          {
            dateNo: "2",
            dateName: "今日"
          },
          {
            dateNo: "3",
            dateName: "明日"
          },
          {
            dateNo: "4",
            dateName: "明後日"
          },
          {
            dateNo: "5",
            dateName: "昨日"
          },
          {
            dateNo: "6",
            dateName: "一昨日"
          }
          /*  ADD カスタムフィールドデフォルト修正 楊 END */
      ],
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      masterName: "getMasterName",
      schema: "getSchema",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord"
    }),
    ...mapGetters("mst-pat-event-template", {
      getInputParams: "getInputParams",
    }),
    selectdateno: {
      get() {
        return this.getInputParams[this.propsIndex].item_json.date_class;
      },
      set(value) {
        this.inputModel.date_class = value;
        const item = JSON.stringify(this.inputModel);
        this.setInputParamsUpdate({
          item: item,
          index: this.propsIndex
        });
        const inputParams = this.getInputParams;
        this.updateEditRecord("inputParams", JSON.stringify(inputParams));
      },
    },
  },

  methods: {
    getTemplateElementsByClassName(className) {
      return getScopedElementsByClassName(className, this.$el || this);
    },
    queryTemplateSelector(selector) {
      return queryScopedSelector(selector, this.$el || this);
    },
    queryTemplateSelectorAll(selector) {
      return queryScopedSelectorAll(selector, this.$el || this);
    },
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("mst-pat-event-template", [
      "setInputParams",
      "setInputParamsUpdate"
    ]),

    getValueByField(field) {
      return this.editRecord[field];
    },

    getSchemaByField(field) {
      return this.schema.model.fields[field];
    },

    updateEditRecord(key, value) {
      this.editRecord[key] = value;
      this.setEditRecord(this.editRecord);
      //[確認]ボタンの状態の変更をトリガーします
       this.changeButton();
    },
    //[確認]ボタンの状態の変更をトリガーします
     changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    /**
     * 入力データの検証チェック
     */
    validateData() {
      let fieldNameValid = true;
      const formatClass = this.getInputParams[this.propsIndex].format_class;
      const fieldName = this.getInputParams[this.propsIndex].field_name;
      fieldNameValid = fieldName !== null && fieldName !== "";
      return {
        formatClassValid: 0 <= formatClass,
        fieldNameValid: fieldNameValid
      };
    },
    /**
     * 入力データの検証チェック
     */
    validateOnRegistration() {
      const validationResult = this.validateData();
      if (Object.values(validationResult).every(v => v === true)) {
        return true;
      }
      if(!validationResult.fieldNameValid) {
        this.getTemplateElementsByClassName("required"+this.propsIndex)[0]?.classList?.add("input-invalid");
      }
      // メッセージ組み立て
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
      // const title = "日付のチェックエラー";
      const title = DIALOG_MESSAGES['00200131'].title;
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      const message = `
          ${
            !validationResult.formatClassValid
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "形式名を選択する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200078'].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.fieldNameValid
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "フィールド名を入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200131'].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              : ""
          }
        `;
      // ダイアログ表示
      this.$ons.notification.alert({
        title: title,
        message: message
      });
      return false;
    }
  }
};
</script>

<style scoped>
.disp-period {
  vertical-align: middle;
}

.disp-item-area {
  width: 100%;
  border-collapse: collapse;
}

.disp-item-area tr {
  height: 2em;
}

.disp-item-area tr th {
  text-align: left;
}
.input-required :deep(input){
  color: black;
  background-color: #ffff99;
}
.input-invalid :deep(input){
  color: black;
  background-color: rgba(255, 0, 0, 1);
}

.disp-item-area tr th:first-child,
.disp-item-area tr th:nth-child(2) {
  width: 30%;
}

.disp-item-area tr td:first-child,
.disp-item-area tr td:nth-child(2),
.disp-item-area tr td:nth-child(3) {
  text-align: left;
}

.pat-event-input {
  width: 100%;
}

/* 項目名 */
.item-title {
  padding-left: 5px;
  width: 12em;
}

/* 項目内容 */
.item-data {
  padding: 2px;
}
</style>
