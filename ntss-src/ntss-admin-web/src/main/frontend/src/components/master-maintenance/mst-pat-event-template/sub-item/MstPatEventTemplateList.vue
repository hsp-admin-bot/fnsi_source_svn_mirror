<template>
  <div class="vertical-div">
    <table class="disp-item-area">
      <tr>
        <td class="item-title">データ取得元</td>
        <td class="import-area">
          <v-ons-select v-model="selectSourceName">
            <option v-for="(item, idx) in groupSelector" :key="idx" :value="item.cd">{{ item.name }}</option>
          </v-ons-select>
          <label>&nbsp;</label>
          <v-ons-select v-model="selectSourceField">
            <option
              v-for="(item, idx) in itemSelector"
              :key="idx"
              :value="item.field"
            >{{ item.name }}</option>
          </v-ons-select>
          <v-ons-button
            class="btn3-normal button-import"
            @click="dataImport()"
            :disabled="!selectSourceField"
          >取得</v-ons-button>
        </td>
      </tr>
    </table>
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
              class="pat-event-input score-list"
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
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { ADVANCED_SETTINGS } from "@/constants/advancedSettings";
import { sendRequestMstGetJobs } from "@/apis/user-selector-popover"
import { sendRequestGetMstUserData } from "@/apis/mst-user-maintenance"
import {EventBus} from "@/compat/vue/event-bus.js";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start

import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import { getScopedElementsByClassName, queryScopedSelector, queryScopedSelectorAll } from "@/functions/common/LayoutMeasureHelper";
import { messageFormat } from "@/functions/common/MessageFormat";
import ExtendedCustomInputNumber from "@/components/master-maintenance/mst-pat-event-template/sub-item/ExtendedCustomInputNumber";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
export default {
  name: "MstPatEventTemplateList",
  components: {
    "extended-custom-input-number": ExtendedCustomInputNumber
  },
  props: ["propsIndex"],
  data() {
    return {
      inputModel: {
        sql_cd: null,
        source_field: null,
        values: [],
        dataErrList: []
      },
      regExp: {
        numeric: /^[0-9０-９]+$/
      },
      selectSourceNameValue: null,
      min:0,
      max:999,
      blurFlg:false,
      focusFlg:[],
      preChangedValue: null,
      itemScoreRecordList: [],
      decimalDigitsIncreaseFlg: false
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      getFacilitySwitchAdvancedSettings: "getFacilitySwitchAdvancedSettings",
      getFacilitySwitch: "getFacilitySwitch",
      masterName: "getMasterName",
      schema: "getSchema",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord"
    }),
    ...mapGetters("mst-pat-event-template", {
      getInitInputParams: "getInitInputParams",
      getInputParams: "getInputParams",
      // mod #6776 20230704 患者イベントテンプレートマスタ：テキストボックスのデータ　表示未指定　表示未指定、プルダウンフレーム内容なしです　孟堅　start
      /* mod 患者イベントテンプレートマスタ データ取得元修正 楊 start */
      //getSysDataSet: "getSysListDataSet",
      getSysDataSet: "getSysDataSet",
      /* mod 患者イベントテンプレートマスタ データ取得元修正 楊 end */
      // mod #6776 20230704 患者イベントテンプレートマスタ：テキストボックスのデータ　表示未指定　表示未指定、プルダウンフレーム内容なしです　孟堅　start
      getListScore: "getListScore",
      getInputParamsList: "getInputParamsList"
    }),
    ...mapGetters("user", {
      advancedSettings: "getAdvancedSettings",
      facilityCd: "getFacilityCd"
    }),
    getJson() {
      this.getStore();
      return this.getInputParams[this.propsIndex];
    },
    groupSelector() {
      const defaultSelector = { name: "未指定", cd: null };
      if (this.getSysDataSet.list.groupList) {
        return [defaultSelector].concat(
          deepCopy(this.getSysDataSet.list).groupList
        );
      } else {
        return [defaultSelector];
      }
    },
    itemSelector() {
      if (this.getSysDataSet.list.itemList) {
        return deepCopy(this.getSysDataSet.list).itemList.filter(
          item => item.group === this.selectSourceNameValue
        );
      } else {
        return [];
      }
    },
    isViewScore() {
      // add マスタ一覧 1･施設切替を可能とする 孔s start
      // return this.advancedSettings.func_advcds.some(
      //   setting => setting.func_advcd === ADVANCED_SETTINGS.PATEVENT_SCORE_CALC
      // );
      return this.getFacilitySwitchAdvancedSettings.some(
        setting => setting === ADVANCED_SETTINGS.PATEVENT_SCORE_CALC
      );
      // add マスタ一覧 1･施設切替を可能とする 孔s end
    },
    selectSourceName: {
      get() {
        const sqlCd = this.getInputParams[this.propsIndex].item_json.sql_cd;
        if (this.getSysDataSet.list.itemList) {
          const items = deepCopy(this.getSysDataSet.list).itemList.filter(
            m => m.cd === sqlCd && m.field === this.selectSourceField
          );
          if (items && items.length > 0) {
            return items[0].group;
          } else {
            return this.groupSelector.length > 0
              ? this.groupSelector[0].cd
              : null;
          }
        } else {
          return null;
        }
      },
      set(value) {
        this.selectSourceNameValue = value;
        const items = deepCopy(this.getSysDataSet.list).itemList.filter(
          item => item.group === value
        );
        if (items.length > 0) {
          this.selectSourceField = items && items[0].field;
        } else {
          this.selectSourceField = null;
        }
      }
    },
    selectSourceField: {
      get() {
        return this.getInputParams[this.propsIndex].item_json.source_field;
      },
      set(value) {
        if(value !== undefined){
          const item = this.itemSelector.find(m => m.field === value);
        if(this.getInputParams[this.propsIndex].item_json.source_field !== undefined && this.getInputParams[this.propsIndex].item_json.source_field !== null){
          this.setInputParamsList({
            key: this.getInputParams[this.propsIndex].item_json.source_field.concat(this.editRecord.code),
            inputParams: this.getInputParams[this.propsIndex].item_json.values
          });
        }
        // #9863  Error in v-on handler: "TypeError: Cannot read properties of undefined (reading 'field')" linjunfeng 横展開2 start
        // if(!this.getInputParamsList.has(item.field.concat(this.editRecord.code))) {
          if(!this.getInputParamsList.has(item?.field.concat(this.editRecord.code))) {
        // #9863  Error in v-on handler: "TypeError: Cannot read properties of undefined (reading 'field')" linjunfeng 横展開2 end
          this.getInputParams[this.propsIndex].item_json.values = [];
        } else {
          this.getInputParams[this.propsIndex].item_json.values = this.getInputParamsList.get(item.field.concat(this.editRecord.code));
        }
        const contact = this.getInputParams[this.propsIndex].item_json;
        this.inputModel.values = contact.values;
        this.inputModel.source_field = item ? item.field : null;
        this.inputModel.sql_cd = item ? item.cd : null;
        this.rebuildItemScoreRecordList();
        this.setStore();
        }
      }
    }
  },
  watch: {
    selectSourceName(value) {
      this.selectSourceNameValue = value;
    }
  },
  created() {
    //フィールド追加時にcreatedイベントが起動
    this.setInputParamsList({
      key: null,
      inputParams: null
    });
    //モーダルウィンドウ起動時の入力値を取得
    const initInputParam = this.getInitInputParams.filter(rec => rec._uniqueId == this.getInputParams[this.propsIndex]._uniqueId);
    //スコアの値の設定(初期値:モーダルウィンドウ起動時の入力値、編集後の値:現在の入力値)
    if(initInputParam && initInputParam.length === 1){
      for(let index = 0;index <= this.getJson.item_json.values.length - 1;index++){
        const decimalDigitsArray = String(parseFloat(String(this.getJson.item_json.values[index].score))).split(".");
        const decimalDigits = decimalDigitsArray[1] ? decimalDigitsArray[1].length : 0;
        this.itemScoreRecordList.push({
          initValue: initInputParam[0].item_json.values?.[index] ? initInputParam[0].item_json.values[index].score : null,
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
  mounted() {
    this.$nextTick(() => {
      this.selectSourceNameValue = this.selectSourceName;
    });
  },
  /* add リストボックス->データ取得元修正 楊 start */
  unmounted() {
    this.clearInputParamsList();
  },
  /* add リストボックス->データ取得元修正 楊 end */
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
      "sendRequestGetSysDataSetResultByFacilityCd",
      "setInputParamsUpdate",
      "sendRequestGetSysDataSetResult",
      "setInputParamsList",
      "clearInputParamsList"
    ]),
    // mod #5589 2023/03/31 数値IFのスタイル全不正 張博 start
    inputNumber(e){
        // 数値範囲内かどうかの確認
        if (this.min !== undefined && this.max !== undefined) {
          if (e.target.value > this.max) {
            e.target.value = this.min;
            this.blurFlg=true;
          } else if (e.target.value < this.min) {
            e.target.value = this.max;
            this.blurFlg=true;
          }else{
            this.blurFlg=false;
          }
        }
        this.setStore();
    },
    onMouseWheel(e,index){
      if (!this.focusFlg[index]) {
        return;
      }
      let delta = (e.wheelDelta && (e.wheelDelta > 0 ? 1 : -1)) ||
                      (e.detail && (e.wheelDelta > 0 ? -1 : 1))
      if (!e.target.value) {
        e.target.value = this.min - 1;
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
      e.target.value = value
      if (value > this.max) {
        e.target.value = this.min;
      }
      if(value < this.min) {
        e.target.value = this.max;
      }
      this.setStore();
    },
    formatValue(event,index){
            // 限界値判定
      let value = event.target.value;
      if (value == this.max && this.blurFlg) {
        event.target.value = this.min;
        this.blurFlg = false;
      }else if (value == this.min && this.blurFlg) {
        event.target.value = this.max;
        this.blurFlg = false;
      }
      this.focusFlg[index]=false;
    },
    // mod #5589 2023/03/31 数値IFのスタイル全不正 張博 end
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
      const contact = this.getInputParams[this.propsIndex].item_json;
      this.inputModel.source_field = contact.source_field;
      this.inputModel.sql_cd = contact.sql_cd;
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
      const contact = this.getInputParams[this.propsIndex].item_json;
      this.inputModel.source_field = contact.source_field;
      this.inputModel.sql_cd = contact.sql_cd;
      this.inputModel.values.splice(index, 1);
      this.itemScoreRecordList.splice(index, 1);
      this.setStore();
    },
    /**
     * リスト名
     */
    setName(value, index) {
      const contact = this.getInputParams[this.propsIndex].item_json;
      this.inputModel.source_field = contact.source_field;
      this.inputModel.sql_cd = contact.sql_cd;
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
      if(e.target.value && this.getTemplateElementsByClassName(e.target.name)[0])
      this.getTemplateElementsByClassName(e.target.name)[0].classList.remove("input-invalid");
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
            e.target.style.background = "red";
          }
        }
      }
      const contact = this.getInputParams[this.propsIndex].item_json;
      this.inputModel.source_field = contact.source_field;
      this.inputModel.sql_cd = contact.sql_cd;
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
    initColor(e,index){
      e.target.style = "background:#F7F7F7";
      this.focusFlg[index]=true;
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
            /* add リストボックス->データ取得元修正 楊 start */
            code: contact[i].code,
            /* add リストボックス->データ取得元修正 楊 end */
            name: contact[i].name,
            score: contact[i].score
          });
        }
      }
    },

    rebuildItemScoreRecordList() {
      const values = this.getInputParams[this.propsIndex]?.item_json?.values ?? [];
      this.itemScoreRecordList = [];
      const initInputParam = this.getInitInputParams.filter(
        rec => rec._uniqueId === this.getInputParams[this.propsIndex]._uniqueId
      );
      values.forEach((item, index) => {
        const initValue =
          initInputParam.length === 1 && initInputParam[0].item_json.values?.[index]
            ? initInputParam[0].item_json.values[index].score
            : null;
        if (item.score !== undefined && item.score !== null && item.score !== "") {
          const decimalDigitsArray = String(parseFloat(String(item.score))).split(".");
          const decimalDigits = decimalDigitsArray[1] ? decimalDigitsArray[1].length : 0;
          this.itemScoreRecordList.push({
            initValue,
            editValue: item.score,
            decimalDigits
          });
        } else {
          this.itemScoreRecordList.push({ initValue, editValue: null, decimalDigits: 0 });
        }
      });
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
      const formatClass = this.getInputParams[this.propsIndex].format_class;
      const fieldName = this.getInputParams[this.propsIndex].field_name;
      fieldNameValid = fieldName !== null && fieldName !== "";
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
        this.getTemplateElementsByClassName("required"+this.propsIndex)[0]?.classList?.add("input-invalid");
      }
      if(!validationResult.nameValid) {
        this.dataErrList.forEach(element => {
          this.getTemplateElementsByClassName("name"+this.propsIndex+element)[0]?.classList?.add("input-invalid");
        });
      }
      // メッセージ組み立て
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
      // const title = "リストから選択のチェックエラー";
      const title = DIALOG_MESSAGES['00200134'].title;
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
              ? messageFormat(DIALOG_MESSAGES['00200134'].message)
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
    },
  //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    dataImport() {
      const contact = this.getInputParams[this.propsIndex].item_json;
      const sqlCd = contact.sql_cd;
      const field = contact.source_field;
      /* add リストボックス->データ取得元修正 楊 start */
      let doctorFlag = false;
      let tempInputModel = [];
      let mstJob= new Map();  // key jobCd
      let mstPersonalUser = new Map();  // key userId
      let mstselectorUser = new Map(); // key userId

      if(field.substring(0,3) !== "mst"){
        return;
      }

      if(field === "mst_user_doctor" || field === "mst_user_doctor_other" || field === "mst_user"){
        doctorFlag = true;
      }

      if(doctorFlag) {
        // mod マスタ一覧 1･施設切替を可能とする 孔s facilityCd => getFacilitySwitch
          // sendRequestMstGetJobs(this.facilityCd).then( res => {
          sendRequestMstGetJobs(this.getFacilitySwitch).then( res => {
            res.data.map( data => {
              if(data.isDisp === "1" && data.isDel ==="0") {
                if(field === "mst_user_doctor" && data.isDoctor === "1") {
                  mstJob.set(data.jobCd.toString(),data);
                }
                if(field === "mst_user_doctor_other" && data.isDoctor !== "1") {
                  mstJob.set(data.jobCd.toString(),data);
                }
                if(field === "mst_user") {
                  mstJob.set(data.jobCd.toString(),data);
                }
              }
            });
        });
        // mod マスタ一覧 1･施設切替を可能とする 孔s facilityCd => getFacilitySwitch
        // sendRequestGetMstUserData(this.facilityCd).then( res => {
        sendRequestGetMstUserData(this.getFacilitySwitch).then( res => {
          res.data.localDataSource.data.map( data => {
            if(mstJob.has(data.jobCd)) {
              mstPersonalUser.set(data.userId,data);
            }});
            this.inputModel.values.map( data => {
              if(mstPersonalUser.has(data.code)) {
                tempInputModel.push({ code: data.code,name: mstPersonalUser.get(data.code).userName, score: data.score });
              }
            });
          this.inputModel.source_field = field;
          this.inputModel.sql_cd = sqlCd;
          this.inputModel.values = tempInputModel;
          this.setStore();
        });
      }
      /* add リストボックス->データ取得元修正 楊 end */
      if (sqlCd) {
        // mod マスタ一覧 1･施設切替を可能とする 孔s sendRequestGetSysDataSetResult => sendRequestGetSysDataSetResultByFacilityCd
        // this.sendRequestGetSysDataSetResult({ cd: sqlCd, mstName: doctorFlag?"mst_user":field }).then(res => {
        this.sendRequestGetSysDataSetResultByFacilityCd({ cd: sqlCd, mstName: doctorFlag?"mst_user":field, facilityCd: this.getFacilitySwitch}).then(res => {
          const dataList = res.data;
          this.inputModel.source_field = field;
          this.inputModel.sql_cd = sqlCd;
          /* add リストボックス->データ取得元修正 楊 start */
          const inputModel = this.inputModel.values;
          this.inputModel.values = [];
          let inputModelMap = new Map();
          for(const item of inputModel){
            inputModelMap.set(item.code,item.score);
          }
          this.itemScoreRecordList = [];
          let initValueList = [];
          //モーダルウィンドウ起動時の入力値を取得
          const initInputParam = this.getInitInputParams.filter(rec => rec._uniqueId == this.getInputParams[this.propsIndex]._uniqueId);
          if(initInputParam && initInputParam.length === 1){
            for(let index = 0;index <= this.getJson.item_json.values.length - 1;index++){
              let initValue = initInputParam[0].item_json.values[index] ? initInputParam[0].item_json.values[index].score : null;
              initValueList.push(initValue);
            }
          }
          if(!field.substring(0,3) === "mst"){
            let index = 0;
            for (const data of dataList) {
              if (!this.isViewScore) {
                this.inputModel.values.push({ code: null,name: data[field], score: 0 });
                this.itemScoreRecordList.push({ initValue: initValueList[index] ? initValueList[index] : 0, editValue: 0 , decimalDigits: 0});
              } else {
                this.inputModel.values.push({ code: null,name: data[field], score: "" });
                this.itemScoreRecordList.push({ initValue: initValueList[index] ? initValueList[index] : null, editValue: null , decimalDigits: 0});
              }
              index++;
            }
          }else if(dataList.length !== 0){
            let index = 0;
            for (const data of JSON.parse(dataList[0].masterdata.value)) {
              mstselectorUser.set(data.code,data);
              if(inputModelMap.has(data.code)) {
                  this.inputModel.values.push({ code: data.code,name: data.name, score: inputModelMap.get(data.code)});
                  let decimalDigitsArray = [];
                  let decimalDigits = 0;
                  if(inputModelMap.get(data.code)){
                    decimalDigitsArray = String(parseFloat(String(inputModelMap.get(data.code)))).split(".");
                    decimalDigits = decimalDigitsArray[1] ? decimalDigitsArray[1].length : 0;
                  }
                  this.itemScoreRecordList.push({ initValue: initValueList[index] ? initValueList[index] : null, editValue: inputModelMap.get(data.code) , decimalDigits: decimalDigits});
              }else {
                if (!this.isViewScore) {
                  this.inputModel.values.push({ code: data.code,name: data.name, score: 0 });
                  this.itemScoreRecordList.push({ initValue: initValueList[index] ? initValueList[index] : 0, editValue: 0 , decimalDigits: 0});
                } else {
                  this.inputModel.values.push({ code: data.code,name: data.name, score: "" });
                  this.itemScoreRecordList.push({ initValue: initValueList[index] ? initValueList[index] : null, editValue: null , decimalDigits: 0});
                }
              }
              index++;
            }
          /* add リストボックス->データ取得元修正 楊 end */
          }
          this.setStore();
        });
      }
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

.input-required :deep(input){
  color: black;
  background-color: #ffff99;
}
.input-invalid :deep(input){
  color: black;
  background-color: rgba(255, 0, 0, 1);
}
.pat-event-input {
  width: 100%;
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

.import-area {
  align-items: center;
  display: flex;
}
/* 取得ボタン */
.button-import {
  width: 140px;
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
table.list .list-score :deep(input) {
  background-color: #F7F7F7;
  color: #1f1f21;
}
table.list .list-name {
  width: 100%;
  min-width: 10em;
}
</style>
