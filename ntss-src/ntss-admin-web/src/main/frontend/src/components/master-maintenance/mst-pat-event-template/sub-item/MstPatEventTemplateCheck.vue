<template>
  <div class="vertical-div">
    <div class="disp-item-area wrap-block">
      <v-ons-button class="btn3-normal button-add" @click="addRow()">追加</v-ons-button>
    </div>
    <table class="disp-item-area list">
      <thead>
        <th class="ntss-list-header-th-sticky list-name" scope="col">リスト名</th>
        <th class="ntss-list-header-th-sticky list-score" scope="col" v-if="isViewScore">スコア</th>
        <th class="ntss-list-header-th-sticky list-del" scope="col"/>
      </thead>
      <tbody>
        <tr v-for="(item,index) in getJson.item_json.values" :key="index">
          <td class="ntss-list-body-td list-name">
            <v-ons-input
              :class="'pat-event-input input-required name'+propsIndex +index"
              :name="'name'+propsIndex +index"
              v-model="item.name"
              @input="setNameCss($event)"
              @blur="setName($event.target.value, index)"
            />
          </td>
          <td class="ntss-list-body-td list-score" v-if="isViewScore">
            <extended-custom-input-number
              :value="itemScoreRecordList[index]"
              step="any"
              :wheel-step="1"
              :min-value="min"
              :max-value="max"
              :digits="3"
              :decimal-digits="getDecimalDigits(index)"
              :name="'itemScore'+propsIndex+index"
              :loop-flg="true"
              :initial-value-lock="true"
              class="pat-event-input score-check"
              @keydown="keyEventCheck($event,$event.target.value, index)"
              @beforeinput="preChangedValueCheck($event)"
              @input="setScoreInput($event,$event.target.value, index)"
              @blur="setScore($event,$event.target.value, index)"
              @focus="initColor($event)"
            />
          </td>
          <td class="ntss-list-body-td list-del">
            <button class="ntss-btn-outset delete-button" @click="deleteRow(index)">
              <v-ons-icon icon="fa-trash"/>
            </button>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
<script>
import { mapGetters, mapActions } from "vuex";
import { ADVANCED_SETTINGS } from "@/constants/advancedSettings";
import {EventBus} from "@/eventBus";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
export default {
  name: "MstPatEventTemplateCheck",
  props: ["propsIndex"],
  data() {
    return {
      inputModel: { values: [] },
      regExp: {
        numeric: /^[0-9０-９]+$/
      },
      dataErrList: [],
      min:0,
      max:999,
      preChangedValue: null,
      itemScoreRecordList: [],
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
    ...mapGetters("user", {
      advancedSettings: "getAdvancedSettings"
    }),
    getJson() {
      this.getStore();
      return this.getInputParams[this.propsIndex];
    },
    isViewScore() {
      return this.advancedSettings.func_advcds.some(
        setting => setting.func_advcd === ADVANCED_SETTINGS.PATEVENT_SCORE_CALC
      );
    }
  },
  watch: {},
  created() {
    //フィールド追加時にcreatedイベントが起動
    //モーダルウィンドウ起動時の入力値を取得
    const initInputParam = this.getInitInputParams.filter(rec => rec._uniqueId == this.getInputParams[this.propsIndex]._uniqueId);
    //スコアの値の設定(初期値:モーダルウィンドウ起動時の入力値、編集後の値:現在の入力値)
    if(initInputParam && initInputParam.length === 1){
      for(let index = 0;index <= this.getJson.item_json.values.length - 1;index++){
        const decimalDigitsArray = String(parseFloat(String(this.getJson.item_json.values[index].score))).split(".");
        const decimalDigits = decimalDigitsArray[1] ? decimalDigitsArray[1].length : 0;
        this.itemScoreRecordList.push({
          initValue: initInputParam[0].item_json.values[index] ? initInputParam[0].item_json.values[index].score : null,
          editValue: this.getJson.item_json.values[index].score,
          decimalDigits: decimalDigits
        });
      }
    } else {
      //スコアの値の設定(初期値:null、編集後の値:現在の入力値)
      this.getJson.item_json.values.forEach(item => {
        if(item.score){
          const decimalDigitsArray = String(parseFloat(String(item.score))).split(".");
          const decimalDigits = decimalDigitsArray[1] ? decimalDigitsArray[1].length : 0;
          this.itemScoreRecordList.push({ initValue: null, editValue: item.score , decimalDigits: decimalDigits});
        } else {
          this.itemScoreRecordList.push({ initValue: null, editValue: null , decimalDigits: 0});
        }
      })
    }
  },
  mounted() {},
  methods: {
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

    /**
     * スコアの小数点以下の桁数の取得
     */
    getDecimalDigits(index){
      let decimalDigits = 0;
      //小数点以下の桁数が増加している場合
      if(this.decimalDigitsIncreaseFlg){
        decimalDigits = this.itemScoreRecordList[index].decimalDigits;
      //小数点以下の桁数が増加していない場合
      } else {
        decimalDigits = this.getDecimalDigitsByValueLength(index);
      }
      return decimalDigits;
    },
    /**
     * スコアの小数点以下の桁数の取得(現在の入力値から取得)
     */
    getDecimalDigitsByValueLength(index){
      const decimalDigitsArray = String(parseFloat(String(this.itemScoreRecordList[index].editValue))).split(".");
      const decimalDigits = decimalDigitsArray[1] ? decimalDigitsArray[1].length : 0;
      return decimalDigits;
    },
    
    updateEditRecord(key, value) {
      this.editRecord[key] = value;
      this.setEditRecord(this.editRecord);
      //[確認]ボタンの状態の変更をトリガーします
     this.changeButton();
    },
    /**
     * フィールド追加ボタンクリックイベント
     */
    addRow() {
      if (!this.isViewScore) {
        this.inputModel.values.push({ name: "", score: 0 });
        this.itemScoreRecordList.push({ initValue: 0, editValue: 0 , decimalDigits: 0});
      } else {
        this.inputModel.values.push({ name: "", score: "" });
        this.itemScoreRecordList.push({ initValue: null, editValue: null , decimalDigits: 0});
      }
      this.setStore();
    },
    /**
     * 明細行の削除ボタンクリックイベント
     */
    deleteRow(index) {
      this.inputModel.values.splice(index, 1);
      this.itemScoreRecordList.splice(index, 1);
      this.setStore();
    },
    //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    /**
     * リスト名
     */
    setName(value, index) {
      this.inputModel.values[index].name = value;
      if (this.inputModel.values[index].score === undefined) {
        this.inputModel.values[index].score = "";
      }
      if (!this.isViewScore) {
        this.inputModel.values[index].score = 0;
      }
      this.setStore();
    },
    setNameCss(e){
      if(e.target.value && document.getElementsByClassName(e.target.name)[0])
      document.getElementsByClassName(e.target.name)[0].classList.remove("input-invalid");
    },
    /**
     * スコアのキー入力イベント
     */
    keyEventCheck(e,value, index){
      //上矢印キーを入力した場合
      if(e.key === "ArrowUp"){
        this.decimalDigitsIncreaseFlg = false;
        const currentDecimalDigitsArray = String(e.target.value).split(".");
        //小数点以下の桁を含む場合
        if(currentDecimalDigitsArray[1]){
          e.target.value = Math.floor(Number(e.target.value) + 1);
          this.getJson.item_json.values[index].score = e.target.value;
          this.itemScoreRecordList[index].editValue = this.getJson.item_json.values[index].score;
        }
      //下矢印キーを入力した場合
      } else if(e.key === "ArrowDown"){
        this.decimalDigitsIncreaseFlg = false;
        const currentDecimalDigitsArray = String(e.target.value).split(".");
        //小数点以下の桁を含む場合
        if(currentDecimalDigitsArray[1]){
          e.target.value = Math.floor(e.target.value);
          this.getJson.item_json.values[index].score = e.target.value;
          this.itemScoreRecordList[index].editValue = this.getJson.item_json.values[index].score;
        }
      }
    },
    /**
     * スコアの入力イベント発生前のイベント
     */
    preChangedValueCheck(e){
      //入力イベント発生前のスコアの取得
      this.preChangedValue = e.target.value;
    },
    /**
     * スコアの入力イベント
     */
    setScoreInput(e,value, index){
      this.decimalDigitsIncreaseFlg = false;
      //スコアの小数点以下の桁数の取得
      const currentDecimalDigitsArray = String(e.target.value).split(".");
      //スピンボタン押下時処理
      if (!e.inputType) {
        if(currentDecimalDigitsArray[1] && this.preChangedValue < e.target.value){
          e.target.value = Math.floor(Number(this.preChangedValue) + 1);
        } else if(currentDecimalDigitsArray[1] && this.preChangedValue > e.target.value){
          e.target.value = Math.floor(this.preChangedValue);
        }
        this.getJson.item_json.values[index].score = e.target.value;
        this.itemScoreRecordList[index].editValue = this.getJson.item_json.values[index].score;
      //スピンボタン押下時以外の処理
      } else {
        const previousDecimalDigitsArray = String(this.itemScoreRecordList[index].editValue).split(".");
        const previousDecimalDigits = previousDecimalDigitsArray[1] ? previousDecimalDigitsArray[1].length : 0;
        const currentDecimalDigits = currentDecimalDigitsArray[1] ? currentDecimalDigitsArray[1].length : 0;
        //小数点以下の桁数が増加した場合
        if(previousDecimalDigits < currentDecimalDigits){
          this.decimalDigitsIncreaseFlg = true;
          this.itemScoreRecordList[index].decimalDigits = currentDecimalDigits;
          this.getJson.item_json.values[index].score = e.target.value;
          this.itemScoreRecordList[index].editValue = this.getJson.item_json.values[index].score;
        }
      }
    },
    /**
     * スコア
     */
    setScore(e,value, index) {
      this.decimalDigitsIncreaseFlg = false;

      /* MODIFY カスタムフィールドデフォルト修正 楊 START */
      let name = "[" + this.getJson.field_name + "]";
      for (let i = 0; i < this.getInputParams.length; i++) {
        if (this.getInputParams[i].format_class === 8 && this.getInputParams[i].item_json.calc) {
          if(this.getInputParams[i].item_json.calc.search(name) > 0 && value === ""){
            e.target.children[0].style = "background:red";
          }
        }
      }

      if (isNaN(value)) {
        this.inputModel.values[index].score = 0;
      } else if(value === "") {
        this.inputModel.values[index].score = value;
      } else {
        this.inputModel.values[index].score = Number(value);
      }
      /* MODIFY カスタムフィールドデフォルト修正 楊 END */
      if (this.inputModel.values[index].name === undefined) {
        this.inputModel.values[index].name = "";
      }
      if (value < 0) {
        this.inputModel.values[index].score = 0;
      }
      if (value > 999) {
        this.inputModel.values[index].score = 999;
      }
      this.setStore();
      const currentDecimalDigitsArray = String(parseFloat(String(e.target.value))).split(".");
      const currentDecimalDigits = currentDecimalDigitsArray[1] ? currentDecimalDigitsArray[1].length : 0;
      this.itemScoreRecordList[index].decimalDigits = currentDecimalDigits;
    },

    /*  ADD カスタムフィールドデフォルト修正 楊 START */
    initColor(e){
      e.target.children[0].style = "background:#F7F7F7";
    },
    /*  ADD カスタムフィールドデフォルト修正 楊 END */

    getStore() {
      const inputParam = this.getInputParams[this.propsIndex];
      const contact = inputParam.item_json.values;
      if (contact === undefined) {
        return;
      }
      if (contact.length > 0) {
        this.inputModel = { values: [] };
        for (let i = 0; i < contact.length; i++) {
          this.inputModel.values.push({
            name: contact[i].name,
            score: contact[i].score
          });
        }
      }
    },

    setStore() {
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
      this.dataErrList = []
      const values = this.getInputParams[this.propsIndex].item_json.values;
      let valueslength = 0;
      let nameValid = true;
      let fieldNameValid = true;
      if (values !== undefined) {
        valueslength = values.length;
        if (valueslength > 0) {
          for (let i = 0; i < values.length; i++) {
            if (values[i].name === null || values[i].name === "") {
              nameValid = false;
              this.dataErrList.push(i);
            }
          }
        }
      }
      const fieldName = this.getInputParams[this.propsIndex].field_name;
      fieldNameValid = fieldName !== null && fieldName !== "";
      const formatClass = this.getInputParams[this.propsIndex].format_class;
      return {
        maxLengthValid: 0 < valueslength,
        nameValid: nameValid,
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
        document.getElementsByClassName("required"+this.propsIndex)[0]?.classList?.add("input-invalid");
      }
      if(!validationResult.nameValid) {
        this.dataErrList.forEach(element => {
          document.getElementsByClassName("name"+this.propsIndex+element)[0]?.classList?.add("input-invalid");
        });
      }
      // メッセージ組み立て
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
      // const title = "チェックのチェックエラー";
      const title = DIALOG_MESSAGES['00200130'].title;
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
              ? messageFormat(DIALOG_MESSAGES['00200130'].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.maxLengthValid
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "リストの明細ありません。入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200079'].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.nameValid
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "リスト名を入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200080'].message)
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
.input-required >>> input{
  color: black;
  background-color: #ffff99;
}
.input-invalid >>> input{
  color: black;
  background-color: rgba(255, 0, 0, 1);
}
.item-data {
  padding: 5px;
}

.item-label {
  white-space: nowrap;
}

/* 追加ボタン */
.button-add {
  position: relative;
  bottom: 5px;
  width: 140px;
  margin-left: auto;
}

.wrap-block {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
}

.vertical-div {
  display: flex;
  flex-direction: column;
  align-content: flex-start;
  width: 98%;
  font-size: 1em;
}

.delete-button {
  display: block;
  margin: auto;
}

table.list .list-del {
  min-width: 3em;
}
table.list .list-score {
  min-width: 10em;
}
table.list .list-score >>> input {
  background-color: #F7F7F7;
  color: #1f1f21;
}
table.list .list-name {
  width: 100%;
  min-width: 10em;
}
</style>
