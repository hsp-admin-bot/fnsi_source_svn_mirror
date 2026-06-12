<template>
  <div>
    <table class="disp-item-area">
      <tr>
        <td class="item-title">画像数</td>
        <td class="item-data">
          <custom-input-number
            :value="textImageNumRecord"
            :step="1"
            :min-value="min"
            :max-value="max"
            :digits="1"
            :loop-flg="true"
            :initial-value-lock="true"
            :class="'pat-event-input input-required textImageNum'+propsIndex"
            :name="'textImageNum'+propsIndex"
            @change="setTextImageNumCss($event, 'textImageNum')"
            @focus="handleFocus(0)"
            @mousewheel.prevent="onMouseWheel($event, 'textImageNum', 0)"
            @blur="checkImageNum($event, 'textImageNum', 0)"
          />
        </td>
        <td class="item-title">画像列数</td>
        <td class="item-data">
          <custom-input-number
            :value="textImageColNumRecord"
            :step="1"
            :min-value="min"
            :max-value="max"
            :digits="1"
            :loop-flg="true"
            :initial-value-lock="true"
            :class="'pat-event-input input-required textImageColNum'+propsIndex"
            :name="'textImageColNum'+propsIndex"
            @change="setTextImageNumCss($event, 'textImageColNum')"
            @focus="handleFocus(1)"
            @mousewheel.prevent="onMouseWheel($event, 'textImageColNum', 1)"
            @blur="checkImageNum($event, 'textImageColNum', 1)"
          />
        </td>
      </tr>
    </table>
    <br />
    <table class="disp-item-area">
      <thead>
        <!-- ADD カスタムフィールドデフォルト修正 楊 START -->
        <th class="ntss-list-header-th-sticky list-name" scope="col">No.</th>
        <!-- ADD カスタムフィールドデフォルト修正 楊 END -->
        <th class="ntss-list-header-th-sticky list-name" scope="col">画像名</th>
      </thead>
      <tbody>
        <tr v-for="(item,index) in getInputParam.item_json.values" :key="index">
          <!-- ADD カスタムフィールドデフォルト修正 楊 START -->
          <td style="padding-left: 5px;" v-if="item.name !== undefined">
            {{ index+1 }}
          </td>
          <!-- ADD カスタムフィールドデフォルト修正 楊 END -->
          <td class="ntss-list-body-td list-name" v-if="item.name !== undefined">
            <v-ons-input
              class="pat-event-input"
              v-model="item.name"
              @blur="setListName($event.target.value, index)"
            />
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import {EventBus} from "@/compat/vue/event-bus.js";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start

import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
import CustomInputNumber from "@/components/common/custom-form-tags/CustomInputNumber";
import { getScopedElementsByClassName, queryScopedSelector, queryScopedSelectorAll } from "@/functions/common/LayoutMeasureHelper";
import { messageFormat } from "@/functions/common/MessageFormat";
export default {
  name: "MstPatEventTemplateList",
  props: ["propsIndex"],
  components: {
    "custom-input-number": CustomInputNumber,
  },
  data() {
    return {
      inputModel: { values: [] },
      // mod #5589 2023/04/11 数値IFのスタイル全不正 張博 start
      min:0,
      max:9,
      blurFlg:false,
      focusFlg:[false,false],
      // mod #5589 2023/04/11 数値IFのスタイル全不正 張博 end
      textImageNumRecord: { initValue: null, editValue: null },
      textImageColNumRecord: { initValue: null, editValue: null }
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
      getInitInputParams: "getInitInputParams",
      getInputParams: "getInputParams"
    }),
    textImageNum: {
      get() {
        return this.getInputParams[this.propsIndex].item_json.image_num;
      },
      set(value) {
        if (!isNaN(value)) {
          this.inputModel.image_num = value;
        } else {
          this.inputModel.image_num = 0;
        }
        this.setImageList();
      }
    },
    textImageColNum: {
      get() {
        return this.getInputParams[this.propsIndex].item_json.image_col_num;
      },
      set(value) {
        if (!isNaN(value)) {
          this.inputModel.image_col_num = value;
        } else {
          this.inputModel.image_col_num = 0;
        }
        this.setImageList();
      }
    },
    getInputParam() {
      return this.getImageList();
    }
  },
  created() {
    //フィールド追加時にcreatedイベントが起動
    if (this.isEmptyValue(this.textImageNum)) {
      this.textImageNum = 1;
      this.textImageColNum = 1;
      this.addRow();
    }
    //モーダルウィンドウ起動時の入力値を取得
    const initInputParam = this.getInitInputParams.filter(rec => rec._uniqueId == this.getInputParams[this.propsIndex]._uniqueId);
    //画像数、画像列数の値の設定(初期値:モーダルウィンドウ起動時の入力値、編集後の値:現在の入力値)
    if(initInputParam && initInputParam.length === 1){
      this.textImageNumRecord.initValue = initInputParam[0].item_json.image_num;
      this.textImageNumRecord.editValue = this.textImageNum;
      this.textImageColNumRecord.initValue = initInputParam[0].item_json.image_col_num;
      this.textImageColNumRecord.editValue = this.textImageColNum;
    } else {
      //画像数、画像列数の値の設定(初期値:1、編集後の値:現在の入力値)
      if(this.textImageNum || this.textImageColNum){
        this.textImageNumRecord.initValue = 1;
        this.textImageNumRecord.editValue = this.textImageNum;
        this.textImageColNumRecord.initValue = 1;
        this.textImageColNumRecord.editValue = this.textImageColNum;
      } else {
        this.textImageNumRecord.initValue = 1;
        this.textImageNumRecord.editValue = null;
        this.textImageColNumRecord.initValue = 1;
        this.textImageColNumRecord.editValue = null;
      }
    }
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
    isEmptyValue(value) {
      return value === null || value === undefined || value === "";
    },

    updateEditRecord(key, value) {
      this.editRecord[key] = value;
      this.setEditRecord(this.editRecord);
      //[確認]ボタンの状態の変更をトリガーします
     this.changeButton();
    },
    // mod #5589 2023/04/12 数値IFのスタイル全不正 張博 start
    checkImageNum(event, key, index) {
      this.focusFlg[index]=false;
      if (key === 'textImageNum') {
        this.addRow();
      }
    },
    // mod #5589 2023/04/12 数値IFのスタイル全不正 張博 end
    setTextImageNumCss (e, key) {
      if(e.target.value && this.getTemplateElementsByClassName(e.target.name)[0])
      this.getTemplateElementsByClassName(e.target.name)[0].classList.remove("input-invalid");
      if(key === "textImageNum"){
        //画像数の値の設定
        this.textImageNum = e.target.value;
        this.textImageNumRecord.editValue = this.textImageNum;
      } else if(key === "textImageColNum"){
        //画像列数の値の設定
        this.textImageColNum = e.target.value;
        this.textImageColNumRecord.editValue = this.textImageColNum;
      }
    },
    onMouseWheel(e, key, index){
      if (!this.focusFlg[index]) {
        return;
      }
      let delta = (e.wheelDelta && (e.wheelDelta > 0 ? 1 : -1)) ||
                      (e.detail && (e.wheelDelta > 0 ? -1 : 1))
      let value = parseFloat(e.target.value);
      const parameterStep = 1;
      if (delta > 0) {
        // 滑ります
        value += parameterStep
      } else {
        // 下がります
        value -= parameterStep
      }
      this[key] = value
      if (value > this.max) {
        this[key] = this.min;
      }
      if(value < this.min) {
        this[key] = this.max;
      }
    },
    handleFocus(index){
        this.focusFlg[index]=true;
    },
    // mod #5589 2023/04/01 数値IFのスタイル全不正 張博 end
    checkImageColNum(value) {
      if (value < 0) {
        this.textImageColNum = 0;
      }
      if (value > 9) {
        this.textImageColNum = 9;
      }
    },
    /**
     * フィールド追加ボタンクリックイベント
     */
    addRow() {
      for (let i = 0; i <= this.inputModel.length - 1; i++) {
        if (this.inputModel.values[i].name === undefined) {
          this.inputModel.values[i].name = "";
        }
      }
      const imageNum = this.inputModel.image_num;
      const count = imageNum - this.inputModel.values.length;
      if (count > 0) {
        for (let j = 0; j <= count - 1; j++) {
          this.inputModel.values.push({ name: "" });
        }
      } else {
        for (let j = this.inputModel.values.length - 1; j >= imageNum; j--) {
          if (j === 0) {
            this.inputModel.values = undefined;
          } else {
            this.inputModel.values.splice(j, 1);
          }
        }
      }
      this.setImageList();
    },
    //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    /**
     * リスト名
     */
    setListName(value, index) {
      this.inputModel.values[index].name = value;
      if (this.inputModel.values[index].name === undefined) {
        this.inputModel.values[index].name = "";
      }
      this.setImageList();
    },
    /**
     * ストアの取得処理
     */
    getImageList() {
      const inputParam = this.getInputParams[this.propsIndex];
      const contact = inputParam.item_json.values;
      this.inputModel = { image_num: 0, image_col_num: 0, values: [] };
      if (contact === undefined || inputParam.item_json.image_num === "0") {
        this.inputModel.image_col_num = inputParam.item_json.image_col_num;
        return inputParam;
      }
      this.inputModel.image_num = inputParam.item_json.image_num;
      this.inputModel.image_col_num = inputParam.item_json.image_col_num;
      if (contact.length > 0) {
        for (let i = 0; i < contact.length; i++) {
          this.inputModel.values.push({
            name: contact[i].name
          });
        }
      }
      return inputParam;
    },
    /**
     * ストアの更新処理
     */
    setImageList() {
      const item = JSON.stringify(this.inputModel);
      this.setInputParamsUpdate({
        item: item,
        index: this.propsIndex
      });
      const inputParams = this.getInputParams;
      this.updateEditRecord("inputParams", JSON.stringify(inputParams));
    },
    /**
     * 入力データの検証チェック
     */
    validateData() {
      let fieldNameValid = true;
      let imageColNum = 0;
      const contact = this.getInputParams[this.propsIndex].item_json;
      if (contact.image_col_num !== undefined) {
        imageColNum = contact.image_col_num;
      }
      let imageNum = 0;
      if (contact.image_num !== undefined) {
        imageNum = contact.image_num;
      }
      let valueslength = 0;
      if (contact.values !== undefined) {
        const values = contact.values;
        valueslength = values.length;
      }
      const hasImageNum = !this.isEmptyValue(imageNum);
      const hasImageColNum = !this.isEmptyValue(imageColNum);
      const formatClass = this.getInputParams[this.propsIndex].format_class;
      const fieldName = this.getInputParams[this.propsIndex].field_name;
      fieldNameValid = fieldName !== null && fieldName !== "";
      return {
        imageColNum: hasImageColNum,
        imageNum: hasImageNum,
        valueslength: Number(imageNum) === 0 || 0 < valueslength,
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
      if(!validationResult.imageNum) {
        this.getTemplateElementsByClassName("textImageNum"+this.propsIndex)[0]?.classList?.add("input-invalid");
      }
      if(!validationResult.imageColNum) {
        this.getTemplateElementsByClassName("textImageColNum"+this.propsIndex)[0]?.classList?.add("input-invalid");
      }
      // メッセージ組み立て
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
      // const title = "画像形式のチェックエラー";
      const title = DIALOG_MESSAGES['00200133'].title;
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
              ? messageFormat(DIALOG_MESSAGES['00200133'].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.imageNum
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "画像数を入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200082'].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.imageColNum
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "画像列数を入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200083'].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.valueslength
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "画像名の明細ありません。入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200084'].message)
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
  width: 98%;
  border-collapse: collapse;
}

.disp-item-area tr {
  height: 2em;
}
.input-required :deep(input){
  color: black;
  background-color: #ffff99;
}
.input-invalid :deep(input){
  color: black;
  background-color: rgba(255, 0, 0, 1);
}
.disp-item-area tr th {
  text-align: left;
}

/*
.disp-item-area tr th:first-child,
.disp-item-area tr th:nth-child(2) {
  width: 30%;
}
*/

.disp-item-area tr td:first-child,
.disp-item-area tr td:nth-child(2),
.disp-item-area tr td:nth-child(3) {
  text-align: left;
}

.pat-event-input {
  width: 100%;
}

.item-title {
  padding-left: 5px;
  width: 12em;
}

.item-data {
  padding: 10px;
}

.item-label {
  white-space: nowrap;
}

/* 追加ボタン */
.button-add {
  position: relative;
  bottom: 5px;
  width: 180px;
  margin-left: auto;
}

.wrap-block {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
}

.nowrap-block {
  display: flex;
  flex-direction: row;
  flex-wrap: nowrap;
}

.vertical-div {
  display: flex;
  flex-direction: column;
  align-content: flex-start;
  width: 98%;
  font-size: 1em;
}

.delete-button {
  padding: 2px 0px 2px 0px;
}

table.list .list-del {
  min-width: 3em;
}
table.list .list-score {
  min-width: 10em;
}
table.list .list-name {
  width: 100%;
  min-width: 10em;
}
.ntss-list-header-th-sticky{
  position: relative;
}
</style>
