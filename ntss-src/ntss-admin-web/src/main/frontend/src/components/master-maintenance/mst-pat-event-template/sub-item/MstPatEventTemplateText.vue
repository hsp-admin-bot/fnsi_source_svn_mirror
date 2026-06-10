<template>
  <div>
    <table class="disp-item-area">
      <tr>
        <td class="item-title">最大文字数</td>
        <td style="width: 70px;">
          <custom-input-number
            :value="textMaxValueRecord"
            :step="1"
            :min-value="min"
            :max-value="max"
            :digits="4"
            :loop-flg="true"
            :initial-value-lock="true"
            :class="'pat-event-input textMaxValue'+propsIndex"
            :name="'textMaxValue'+propsIndex"
            @change="setTextMaxValueCss($event)"
            @blur="checkTextMaxValue($event)"
            @focus="handleFocus"
          />
        </td>
        <td class="disp-period">
          <label>文字</label>
        </td>
      </tr>
    </table>
    <table class="disp-item-area">
      <tr>
        <td class="item-title">デフォルト値</td>
        <td style="width: 60%;">
          <v-ons-input class="pat-event-input" :maxlength="textMaxValue" v-model="textDefaultValue"/>
        </td>
        <td></td>
      </tr>
    </table>
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
        </td>
      </tr>
    </table>
  </div>
</template>
<script>
import { mapGetters, mapActions } from "vuex";
import {EventBus} from "@/eventBus";
import { deepCopy } from "@/functions/common/CommonFunctions";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
import CustomInputNumber from "@/components/common/custom-form-tags/CustomInputNumber";
export default {
  name: "MstPatEventTemplateText",
  props: ["propsIndex"],
  components: {
    "custom-input-number": CustomInputNumber,
  },
  data() {
    return {
      inputModel: {
        sql_cd: null,
        max_length: 0,
        source_field: null,
        default_value: "",
      },
      selectSourceNameValue: null,
      min:0,
      max:9999,
      blurFlg:false,
      focusFlg:false,
      textMaxValueRecord: { initValue: null, editValue: null }
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
      getInputParams: "getInputParams",
      getSysDataSet: "getSysDataSet"
    }),
    groupSelector() {
      const defaultSelector = { name: "未指定", cd: null };
      if (this.getSysDataSet.text.groupList) {
        return [defaultSelector].concat(
          deepCopy(this.getSysDataSet.text).groupList
        );
      } else {
        return [defaultSelector];
      }
    },
    itemSelector() {
      if (this.getSysDataSet.text.itemList) {
        return deepCopy(this.getSysDataSet.text).itemList.filter(
          item => item.group === this.selectSourceNameValue
        );
      } else {
        return [];
      }
    },
    selectSourceName: {
      get() {
        if (this.getSysDataSet.text.itemList && this.getInputParams.length > 0) {
          const sqlCd = this.getInputParams[this.propsIndex].item_json.sql_cd;
          const items = deepCopy(this.getSysDataSet.text).itemList.filter(
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
        const items = deepCopy(this.getSysDataSet.text).itemList.filter(
          item => item.group === value
        );
        if (items.length > 0) {
          this.selectSourceField = items[0].field;
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
        const contact = this.getInputParams[this.propsIndex].item_json;
        this.inputModel.default_value = contact.default_value;
        this.inputModel.max_length = contact.max_length;
        const item = this.itemSelector.find(m => m.field === value);
        this.inputModel.source_field = item ? item.field : null;
        this.inputModel.sql_cd = item ? item.cd : null;
        this.updateStore();
      }
    },
    textMaxValue: {
      get() {
        return this.getInputParams[this.propsIndex].item_json.max_length;
      },
      set(value) {
        const contact = this.getInputParams[this.propsIndex].item_json;
        if (!isNaN(value)) {
          this.inputModel.max_length = value;
        } else {
          this.inputModel.max_length = 0;
        }
        this.inputModel.default_value = contact.default_value;
        this.inputModel.sql_cd = contact.sql_cd;
        this.inputModel.source_field = contact.source_field;
        this.updateStore();
      }
    },
    textDefaultValue: {
      get() {
        return this.getInputParams[this.propsIndex].item_json.default_value;
      },
      set(value) {
        const contact = this.getInputParams[this.propsIndex].item_json;
        this.inputModel.max_length = contact.max_length;
        this.inputModel.default_value = value;
        this.inputModel.sql_cd = contact.sql_cd;
        this.inputModel.source_field = contact.source_field;
        this.updateStore();
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
    //モーダルウィンドウ起動時の入力値を取得
    const initInputParam = this.getInitInputParams.filter(rec => rec._uniqueId == this.getInputParams[this.propsIndex]._uniqueId);
    //最大文字数の値の設定(初期値:モーダルウィンドウ起動時の入力値、編集後の値:現在の入力値)
    if(initInputParam && initInputParam.length === 1){
      this.textMaxValueRecord.initValue = initInputParam[0].item_json.max_length;
      this.textMaxValueRecord.editValue = this.textMaxValue;
    } else {
      //最大文字数の値の設定(初期値:null、編集後の値:現在の入力値)
      if(this.textMaxValue){
        this.textMaxValueRecord.initValue = null;
        this.textMaxValueRecord.editValue = this.textMaxValue;
      } else {
        this.textMaxValueRecord.initValue = null;
        this.textMaxValueRecord.editValue = null;
      }
    }
  },
  mounted() {
    this.$nextTick(() => {
      this.selectSourceNameValue = this.selectSourceName;
    });
  },
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
    updateEditRecord(key, value) {
      this.editRecord[key] = value;
      this.setEditRecord(this.editRecord);
     //[確認]ボタンの状態の変更をトリガーします
     this.changeButton();
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
      let value = event.target.value;
      this.focusFlg=false;
      if(this.textDefaultValue){
        this.textDefaultValue  = this.textDefaultValue.toString().substring(0,value)
      }else{
        this.textDefaultValue = ''
      }
    },
    handleFocus(){
      this.focusFlg=true;
    },
    setTextMaxValueCss(e) {
      if(e.target.value && document.getElementsByClassName(e.target.name)[0])
      document.getElementsByClassName(e.target.name)[0].classList.remove("input-invalid");
      this.textMaxValue = e.target.value;
      this.textMaxValueRecord.editValue = this.textMaxValue;
    },
    onMouseWheel(e){
      if (!this.focusFlg) {
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
      e.target.value = value;
      if (value > this.max) {
        e.target.value = this.min;
      }
      if(value < this.min) {
        e.target.value = this.max;
      }
      this.textMaxValue = e.target.value;
    },
    // mod #5589 2023/04/11 数値IFのスタイル全不正 張博 end
    /**
     *
     */
    validateData() {
      let fieldNameValid = true;
      const contact = this.getInputParams[this.propsIndex].item_json;
      if (contact.default_value === undefined) {
        this.inputModel.default_value = "";
      } else {
        this.inputModel.default_value = contact.default_value;
      }
      if (contact.max_length === undefined) {
        this.inputModel.max_length = 0;
      } else {
        this.inputModel.max_length = contact.max_length;
      }
      if (contact.default_value === undefined) {
        this.inputModel.default_value = "";
      } else {
        this.inputModel.default_value = contact.default_value;
      }
      if (contact.sql_cd === undefined) {
        this.inputModel.sql_cd = "";
      } else {
        this.inputModel.sql_cd = contact.sql_cd;
      }
      if (contact.source_field === undefined) {
        this.inputModel.source_field = 0;
      } else {
        this.inputModel.source_field = contact.source_field;
      }
      this.updateStore();

      const formatClass = this.getInputParams[this.propsIndex].format_class;
      const fieldName = this.getInputParams[this.propsIndex].field_name;
      fieldNameValid = fieldName !== null && fieldName !== "";
      return {
        formatClassValid: 0 <= formatClass,
        fieldNameValid: fieldNameValid
      };
    },
    //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    /**
     *
     */
    validateOnRegistration() {
      const validationResult = this.validateData();
      if (Object.values(validationResult).every(v => v === true)) {
        return true;
      }
      if(!validationResult.fieldNameValid) {
        document.getElementsByClassName("required"+this.propsIndex)[0]?.classList?.add("input-invalid");
      }
      // メッセージ組み立て
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
      // const title = "テキストのチェックエラー";
      const title = DIALOG_MESSAGES['00200137'].title;
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
              ? messageFormat(DIALOG_MESSAGES['00200137'].message)
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
.input-required >>> input{
  color: black;
  background-color: #ffff99;
}
.input-invalid >>> input{
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

.item-title {
  padding-left: 5px;
  width: 12em;
}

.item-label {
  white-space: nowrap;
}
</style>
