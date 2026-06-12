<template>
  <div>
    <table class="disp-item-area">
      <tr>
        <td class="item-title">最大サイズ</td>
        <td style="width: 60%;">
          <extended-custom-input-number
            :value="textMaxValueRecord"
            step="any"
            :wheel-step="1"
            :min-value="min"
            :max-value="max"
            :digits="5"
            :decimal-digits="getDecimalDigits()"
            :name="'textMaxValue'+propsIndex"
            :loop-flg="true"
            :initial-value-lock="true"
            :class="'pat-event-input input-required textMaxValue'+propsIndex"
            @keydown="keyEventCheck($event)"
            @beforeinput="preChangedValueCheck($event)"
            @input="setTextMaxValueCss($event)"
            @blur="updateRecord($event)"
          />
        </td>
        <td class="disp-period">
          <label>KB</label>
        </td>
      </tr>
    </table>
  </div>
</template>
<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import {EventBus} from "@/compat/vue/event-bus.js";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start

import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import { getScopedElementsByClassName, queryScopedSelector, queryScopedSelectorAll } from "@/functions/common/LayoutMeasureHelper";
import { messageFormat } from "@/functions/common/MessageFormat";
import ExtendedCustomInputNumber from "@/components/master-maintenance/mst-pat-event-template/sub-item/ExtendedCustomInputNumber";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
export default {
  name: "MstPatEventTemplateFile",
  components: {
    "extended-custom-input-number": ExtendedCustomInputNumber
  },
  props: ["propsIndex"],
  data() {
    return {
      inputModel: {
        max_size: 0
      },
      min:0,
      // mod #10894 患者イベントレイアウトマスタのファイル貼付サイズ上限がFNWより小さい 張玲 start
      // max:10240,
      max:20480,
      // mod #10894 患者イベントレイアウトマスタのファイル貼付サイズ上限がFNWより小さい 張玲 end
      blurFlg: false,
      preChangedValue: null,
      textMaxValueRecord: { initValue: null, editValue: null },
      decimalDigits: 0,
      decimalDigitsIncreaseFlg: false
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
    textMaxValue: {
      get() {
        return this.getInputParams[this.propsIndex].item_json.max_size;
      },
      set(value) {
        if (!isNaN(value)) {
          this.inputModel.max_size = value;
        } else {
          this.inputModel.max_size = 0;
        }
        this.updateStore();
      }
    }
  },
  created() {
    //フィールド追加時にcreatedイベントが起動
    //モーダルウィンドウ起動時の入力値を取得
    const initInputParam = this.getInitInputParams.filter(rec => rec._uniqueId == this.getInputParams[this.propsIndex]._uniqueId);
    //最大サイズの値の設定(初期値:モーダルウィンドウ起動時の入力値、編集後の値:現在の入力値)
    if(initInputParam && initInputParam.length === 1){
      this.textMaxValueRecord.initValue = initInputParam[0].item_json.max_size;
      this.textMaxValueRecord.editValue = this.textMaxValue;
    } else {
      //最大サイズの値の設定(初期値:null、編集後の値:現在の入力値)
      if(this.textMaxValue){
        this.textMaxValueRecord.initValue = null;
        this.textMaxValueRecord.editValue = this.textMaxValue;
      } else {
        this.textMaxValueRecord.initValue = null;
        this.textMaxValueRecord.editValue = null;
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
    
    /**
     * 最大サイズの小数点以下の桁数の取得
     */
    getDecimalDigits(){
      let decimalDigits = 0;
      //小数点以下の桁数が増加している場合
      if(this.decimalDigitsIncreaseFlg){
        decimalDigits = this.decimalDigits;
      //小数点以下の桁数が増加していない場合
      } else {
        decimalDigits = this.getDecimalDigitsByValueLength();
      }
      return decimalDigits;
    },
    /**
     * 最大サイズの小数点以下の桁数の取得(現在の入力値から取得)
     */
    getDecimalDigitsByValueLength(){
      const decimalDigitsArray = String(parseFloat(String(this.textMaxValueRecord.editValue))).split(".");
      const decimalDigits = decimalDigitsArray[1] ? decimalDigitsArray[1].length : 0;
      return decimalDigits;
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
    updateStore() {
      const item = JSON.stringify(this.inputModel);
      this.setInputParamsUpdate({
        item: item,
        index: this.propsIndex
      });
      const inputParams = this.getInputParams;
      this.updateEditRecord("inputParams", JSON.stringify(inputParams));
    },

    checkTextMaxValue(event) {
      if (Number(event.target.value) === this.max && this.blurFlg) {
        this.textMaxValue = this.min;
         this.blurFlg = false;
      }else if (Number(event.target.value) === this.min && this.blurFlg) {
        this.textMaxValue = this.max;
        this.blurFlg = false;
      }
       this.focusFlg=false;
    },
    /**
     * 最大サイズのキー入力イベント
     */
    keyEventCheck(e){
      //上矢印キーを入力した場合
      if(e.key === "ArrowUp"){
        this.decimalDigitsIncreaseFlg = false;
        const currentDecimalDigitsArray = String(e.target.value).split(".");
        //小数点以下の桁を含む場合
        if(currentDecimalDigitsArray[1]){
          e.target.value = Math.floor(Number(e.target.value) + 1);
          this.textMaxValue = e.target.value;
          this.textMaxValueRecord.editValue = this.textMaxValue;
        }
      //下矢印キーを入力した場合
      } else if(e.key === "ArrowDown"){
        this.decimalDigitsIncreaseFlg = false;
        const currentDecimalDigitsArray = String(e.target.value).split(".");
        //小数点以下の桁を含む場合
        if(currentDecimalDigitsArray[1]){
          e.target.value = Math.floor(e.target.value);
          this.textMaxValue = e.target.value;
          this.textMaxValueRecord.editValue = this.textMaxValue;
        }
      }
    },
    /**
     * 最大サイズの入力イベント発生前のイベント
     */
    preChangedValueCheck(e){
      //入力イベント発生前の最大サイズの取得
      this.preChangedValue = e.target.value;
    },
    /**
     * 最大サイズの入力イベント
     */
    setTextMaxValueCss(e) {
      this.decimalDigitsIncreaseFlg = false;
      //最大サイズの小数点以下の桁数の取得
      const currentDecimalDigitsArray = String(e.target.value).split(".");
      //スピンボタン押下時処理
      if (!e.inputType) {
        if(currentDecimalDigitsArray[1] && this.preChangedValue < e.target.value){
          e.target.value = Math.floor(Number(this.preChangedValue) + 1);
        } else if(currentDecimalDigitsArray[1] && this.preChangedValue > e.target.value){
          e.target.value = Math.floor(this.preChangedValue);
        }
        this.textMaxValue = e.target.value;
        this.textMaxValueRecord.editValue = this.textMaxValue;
      //スピンボタン押下時以外の処理
      } else {
        const previousDecimalDigitsArray = String(this.textMaxValueRecord.editValue).split(".");
        const previousDecimalDigits = previousDecimalDigitsArray[1] ? previousDecimalDigitsArray[1].length : 0;
        const currentDecimalDigits = currentDecimalDigitsArray[1] ? currentDecimalDigitsArray[1].length : 0;
        //小数点以下の桁数が増加した場合
        if(previousDecimalDigits < currentDecimalDigits){
          this.decimalDigitsIncreaseFlg = true;
          this.decimalDigits = currentDecimalDigits;
          this.textMaxValue = e.target.value;
          this.textMaxValueRecord.editValue = this.textMaxValue;
        }
      }
      if(e.target.value && this.getTemplateElementsByClassName(e.target.name)[0])
      this.getTemplateElementsByClassName(e.target.name)[0].classList.remove("input-invalid");
    },
    updateRecord(e){
      this.decimalDigitsIncreaseFlg = false;
      const currentDecimalDigitsArray = String(parseFloat(String(e.target.value))).split(".");
      const currentDecimalDigits = currentDecimalDigitsArray[1] ? currentDecimalDigitsArray[1].length : 0;
      this.decimalDigits = currentDecimalDigits;
      this.textMaxValue = e.target.value !== "" ? e.target.value : null;
      this.textMaxValueRecord.editValue = this.textMaxValue;
    },
    changeNumber(e){
       // 数値範囲内かどうかの確認
        if (this.min !== undefined && this.max !== undefined) {
          if (e.target.value > this.max) {
            this.textMaxValue = this.min;
             this.blurFlg = true;
          } else if (e.target.value < this.min) {
            this.textMaxValue = this.max;
             this.blurFlg = true;
          }else{
             this.blurFlg = false;
          }
        }
    },
    mouseWheelNumber(e){
      let delta = (e.wheelDelta && (e.wheelDelta > 0 ? 1 : -1)) ||
                      (e.detail && (e.wheelDelta > 0 ? -1 : 1))
      if (!e.target.value) {
        e.target.value = 0
      }
      let value = parseFloat(e.target.value);
       const parameterStep = 1;
      if (delta > 0) {
        // 滑ります
        value += parameterStep
      } else {
        // 下がります
        value -= parameterStep
      }
      // 数値範囲内かどうかの確認
      if (value > this.max) {
        value = this.min;
      }
      if(value < this.min) {
        value = this.max;
      }
      this.textMaxValue = value
    },
    /**
     * 入力データの検証チェック
     */
    validateData() {
      let fieldNameValid = true;
      const maxSize = this.getInputParams[this.propsIndex].item_json.max_size;
      const formatClass = this.getInputParams[this.propsIndex].format_class;
      const fieldName = this.getInputParams[this.propsIndex].field_name;
      fieldNameValid = fieldName !== null && fieldName !== "";
      return {
        maxSize: !this.isEmptyValue(maxSize) && !isNaN(maxSize) && 0 <= Number(maxSize),
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
      if(!validationResult.maxSize) {
        this.getTemplateElementsByClassName("textMaxValue"+this.propsIndex)[0]?.classList?.add("input-invalid");
      }
      if(!validationResult.fieldNameValid) {
        this.getTemplateElementsByClassName("required"+this.propsIndex)[0]?.classList?.add("input-invalid");
      }
      // メッセージ組み立て
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
      // const title = "添付ファイルのチェックエラー";
      const title = DIALOG_MESSAGES['00200132'].title;
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
              ? messageFormat(DIALOG_MESSAGES['00200132'].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.maxSize
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "最大サイズを入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200081'].message)
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

.input-required :deep(input){
  color: black;
  background-color: #ffff99;
}
.input-invalid :deep(input){
  color: black;
  background-color: rgba(255, 0, 0, 1);
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

.pat-event-input {
  width: 100%;
}

.item-title {
  padding-left: 5px;
  width: 12em;
}

.item-label {
  white-space: nowrap;
}
</style>
