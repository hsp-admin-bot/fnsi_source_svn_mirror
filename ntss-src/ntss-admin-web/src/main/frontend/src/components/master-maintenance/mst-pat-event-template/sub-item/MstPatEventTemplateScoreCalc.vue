<template>
  <div class="vertical-div">
    <table class="disp-item-area">
      <tr>
        <td class="item-title">計算</td>
        <td style="width: 30%;padding-right: 4px;">
        <!-- mod 8125 【デグレ】患者イベント＞スコア計算、日付の不正 関 start -->
          <!-- <com-textarea
            :content="textCalc"
            refProp="clac"
            cssClass="textarea textarea-custom-text-font textarea-resize-vertical"
            :class="'input-required textarea'+propsIndex"
            idTextarea="com-textarea-event-score-calc"
            defaultHeight="170px"
            @input="setTextareaCss($event)"
            @set-content-data="setContentData"
            @blur="isValid"
            @change="changeButton()"
          /> -->
          <com-textarea
            :content="textCalc"
            refProp="clac"
            cssClass="textarea textarea-custom-text-font textarea-resize-vertical"
            :class="'input-required textarea'+propsIndex"
            :idTextarea="'com-textarea-event-score-calc' + propsIndex"
            defaultHeight="170px"
            @input="setTextareaCss($event)"
            @set-content-data="setContentData"
            @blur="isValid"
            @change="changeButton()"
          />
         <!-- mod 8125 【デグレ】患者イベント＞スコア計算、日付の不正 関  end -->
        </td>
        <td style="width: 5%;">
          <!-- <v-ons-button @click="onSelected()">⇒</v-ons-button> -->
          <v-ons-button class="btn3-normal" @click="onSelected()">⇐</v-ons-button>
          <br />
          <br />
          <v-ons-button class="btn3-normal" @click="isCheck()">チェック</v-ons-button>
        </td>
        <td class="item-title" style="width: 33%">
          <div class="nowrap-block" style="align-items: flex-end;">
            <v-ons-select style="width: 80%" class="select select-font-inherit" v-model="selected">
              <option
                v-for="(item, idx) in getListScore"
                :key="idx"
                :value="item.name"
              >{{ item.name }}</option>
               <!-- <option
                v-for="(item, idx) in testScore"
                :key="idx"
                :value="item.name"
              >{{ item.name }}</option> -->
            </v-ons-select>
          </div>
        </td>
      </tr>
    </table>
    <table class="disp-item-area">
      <tr>
        <td class="item-title">単位</td>
        <td style="width: 70%;">
<!--          add 患者イベント計算テンプレートに【単位】が保存されていない 20230612 ztc start-->
          <v-ons-input class="pat-event-input" v-model="textUint" @change="changeUnitValue()"/>
<!--          add 患者イベント計算テンプレートに【単位】が保存されていない 20230612 ztc end-->
        </td>
      </tr>
    </table>
  </div>
</template>
<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import BigEval from "@/functions/BigEvalEx";
import CommonTextArea from "@/components/common/CommonTextArea";
import {EventBus} from "@/compat/vue/event-bus.js";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import { getScopedElementsByClassName, queryScopedSelector, queryScopedSelectorAll } from "@/functions/common/LayoutMeasureHelper";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
export default {
  name: "MstPatEventTemplateText",
  components: {
    "com-textarea": CommonTextArea
  },
  props: ["propsIndex"],
  data() {
    return {
      inputModel: {
        calc: "",
        unit: ""
      },
      selected: ""
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
      getListScore: "getListScore"
    }),
    textUint: {
      get() {
        return this.getInputParams[this.propsIndex].item_json.unit;
      },
      // add 患者イベント計算テンプレートに【単位】が保存されていない 20230612 ztc start
      set(value) {
        this.getInputParams[this.propsIndex].item_json.unit = value;
      },
      // add 患者イベント計算テンプレートに【単位】が保存されていない 20230612 ztc end
    },
    textCalc: {
      get() {
        return this.getInputParams[this.propsIndex].item_json.calc;
      },
    }
  },

  mounted() {
    this.$nextTick(() => {
      const elements = this.queryTemplateSelectorAll('[id^="com-textarea-event-score-calc"]');
      this.resizeTextarea(elements);
    });
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
    checkScoreEmpty(){
      let flag = false;
      const listScoreFormatClass = new Map().set(3,'score-list').set(4,'score-radio').set(6,'score-check');
      let textCalc = new Set(this.textCalc.replace(/\[|\]|\+|-|\*|\\|\//g, " ").split(' '));
      textCalc.delete("");

      for(const item of this.getInputParams){
        if(listScoreFormatClass.has(item.format_class)){
          for(const value of item.item_json.values) {
            if(textCalc.has(item.field_name) && value.score === ""){
              this.changecolor(listScoreFormatClass.get(item.format_class),false);
              flag = true;
              continue;
            }else{
              this.changecolor(listScoreFormatClass.get(item.format_class),true);
            }
          }
        }
      }
      return flag;
    },
    setTextareaCss (e) {
      if(e.target.value && this.getTemplateElementsByClassName("textarea" +this.propsIndex)[0])
      this.getTemplateElementsByClassName("textarea" +this.propsIndex)[0].classList.remove("input-invalid");
    },
    changecolor(className,inIt){
      for(let item of this.getTemplateElementsByClassName(className)){
        if(inIt){
          item.firstElementChild.style.backgroundColor = '#F7F7F7';
        }else if(item.value === ""){
          item.firstElementChild.style.backgroundColor = 'red';
        }
      }
    },

      //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    // add 患者イベント計算テンプレートに【単位】が保存されていない 20230612 ztc start
    changeUnitValue() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    // add 患者イベント計算テンプレートに【単位】が保存されていない 20230612 ztc end
    onSelected() {
      if (this.selected !== "") {
        const contact = this.getInputParams[this.propsIndex].item_json;
        if (contact.unit !== undefined) {
          this.inputModel.unit = contact.unit;
        } else {
          this.inputModel.unit = "";
        }
        if (contact.calc !== undefined) {
          this.inputModel.calc = contact.calc;
        } else {
          this.inputModel.calc = "";
        }
        this.inputModel.calc += "[" + this.selected + "]";
        this.updateStore();
      }
    },
    isCheck() {
      const matches = this.isValid();
      if (matches.length > 0) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: `<div style="text-align:left;">以下の項目がありませんでした。<br> ${matches.join(
          //   ""
          // )}</div>`
          title: DIALOG_MESSAGES['00200085'].title,
          message: `<div style="text-align:left;">${messageFormat(DIALOG_MESSAGES['00200085'].message)}<br> ${matches.join(
            ""
          )}</div>`
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      if (this.checkScoreEmpty()) {
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "チェックエラー",
            // message: `<div style="text-align:left;">スコアは空にできません。<br> </div>`
            title: DIALOG_MESSAGES['00200086'].title,
            message: `<div style="text-align:left;">${messageFormat(DIALOG_MESSAGES['00200086'].message)}<br> </div>`
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });
          return;
        }
      if (!this.isEval()) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェック",
          // message: "<計算失敗>"
          title: DIALOG_MESSAGES['00200087'].title,
          message: messageFormat(DIALOG_MESSAGES['00200087'].message)
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
      } else {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェック",
          // message: "<計算成功>"
          title: DIALOG_MESSAGES['00100015'].title,
          message: messageFormat(DIALOG_MESSAGES['00100015'].message)
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
      }
    },
    isEval() {
      if (this.textCalc === undefined) {
        return false;
      }
      const val = this.textCalc.replace(/\[.*?\]/g, " 1 ");
      const bigEval = new BigEval();
      const calcAnswer = bigEval.exec(val);
      if (typeof calcAnswer === "object") {
        return true;
      } else {
        return false;
      }
    },
    isValid() {
      let match = [];
      let matches = [];
      if (this.textCalc === undefined) {
        return matches;
      }
      const reg = new RegExp(/\[.*?\]/g);
      const value = this.textCalc;
      while ((match = reg.exec(value)) !== null) {
        let isFound = false;
        for (const item of this.getListScore) {
          const value1 = match[0].replace("]", "").replace("[", "");
          if (value1 === item.name) {
            isFound = true;
          }
        }
        if (!isFound) {
          matches.push(match[0]);
        }
      }
      return matches;
    },
    updateStore() {
      const item = JSON.stringify(this.inputModel);
      this.setInputParamsUpdate({
        item: item,
        index: this.propsIndex
      });
      const inputParams = this.getInputParams;
      this.updateEditRecord("inputParams", JSON.stringify(inputParams));
    },
    /**
     *
     */
    validateData() {
      const formatClass = this.getInputParams[this.propsIndex].format_class;
      const calcValid = this.getInputParams[this.propsIndex].item_json.calc;
      const matches = this.isValid();
      let calcIsValid = true;
      let calcIsEval = true;
      if (calcValid !== null && calcValid !== "" && calcValid !== undefined) {
        if (0 === matches.length) {
          calcIsEval = this.isEval();
        } else {
          calcIsValid = false;
        }
      } else {
        calcIsValid = true;
        calcIsEval = true;
      }
      let fieldNameValid = true;
      const fieldName = this.getInputParams[this.propsIndex].field_name;
      fieldNameValid = fieldName !== null && fieldName !== "";
      return {
        formatClassValid: 0 <= formatClass,
        fieldNameValid: fieldNameValid,
        calcValid:
          calcValid !== null && calcValid !== "" && calcValid !== undefined,
        calcIsValid: calcIsValid,
        calcIsEval: calcIsEval
      };
    },
    /**
     *
     */
    validateOnRegistration() {
      const validationResult = this.validateData();
      if (Object.values(validationResult).every(v => v === true)) {
        return true;
      }
      if(!validationResult.calcValid || !validationResult.calcIsEval) {
        this.getTemplateElementsByClassName("textarea"+this.propsIndex)[0]?.classList?.add("input-invalid");
      }
      if(!validationResult.fieldNameValid) {
        this.getTemplateElementsByClassName("required"+this.propsIndex)[0]?.classList?.add("input-invalid");
      }
      // メッセージ組み立て
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
      // const title = "スコア計算のチェックエラー";
      const title = DIALOG_MESSAGES['00200136'].title;
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
              ? messageFormat(DIALOG_MESSAGES['00200136'].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.calcValid
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "計算を入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200088'].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.calcIsValid
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "選択項目がありません。チェックボタンを押下して内容を確認ください。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200089'].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.calcIsEval
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "計算に失敗しました。計算式の内容を確認ください。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200090'].message)
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
    },
    setContentData(newValue) {
      this.getInputParams[this.propsIndex].item_json.calc = newValue;
    },

    resizeTextarea(els) {
      els.forEach(function(el) {
        el.style.height = `${el.scrollHeight + 5}px`;
      });
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
.disp-item-area tr th:first-child,
.disp-item-area tr th:nth-child(2) {
  width: 30%;
}
.disp-item-area tr td:first-child,
.disp-item-area tr td:nth-child(2),
.disp-item-area tr td:nth-child(3) {
  text-align: left;
}
.wrap-block {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  margin-top: 1em;
}
.nowrap-block {
  display: flex;
  overflow: hidden;
  flex-direction: row;
  flex-wrap: nowrap;
}
.pat-event-input {
  width: 100%;
}
.input-required :deep(textarea){
  color: black;
  background-color: #ffff99 !important;
}
.input-invalid :deep(textarea){
  color: black;
  background-color: rgba(255, 0, 0, 1) !important;
}
.item-title {
  padding-left: 5px;
  width: 12em;
}
.item-data {
  padding: 5px;
}
.item-label {
  white-space: nowrap;
}
.select {
  font-size: 1em;
  height: 100%;
}
div :deep(.textarea) {
  box-sizing: border-box;
  width: 100%;
  height: 170px;
  background-color: white;
  font-size: 1em;
}
/*
add FNSI-改修内容計算項目選択レイアウトを変更 任 start
*/
/* div :deep(.select-input){
  height: 177px;
} */
/*
add FNSI-改修内容計算項目選択レイアウトを変更 任 end
*/
</style>
