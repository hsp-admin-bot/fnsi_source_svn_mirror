<template>
  <div>
    <table class="disp-item-area">
      <tr class="category-area">
        <td class="item-title">カテゴリ</td>
        <!-- mod redmine 5074 スマホ、縦画面の際に表示が見切れる 宋qy start -->
        <td style="width: 55%;">
        <!-- mod redmine 5074 スマホ、縦画面の際に表示が見切れる 宋qy end -->
          <v-ons-select v-model="selectedKindNo" class="input-select">
            <option
              v-for="(mst, mstIndex) in getKindList"
              :key="mstIndex"
              :value="mst.kindNo"
            >{{ mst.kindName }}</option>
          </v-ons-select>
        </td>
        <td></td>
      </tr>
    </table>
  </div>
</template>
<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { ApiHelper } from "@/apis/AxiosHelper";

import {EventBus} from "@/compat/vue/event-bus.js";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start

import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import { messageFormat } from "@/functions/common/MessageFormat";
import dayjs from "@/compat/date/dayjs";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end

const uriBbsKind = `/mstInfo/mstBbsKind`;
export default {
  name: "MstPatEventTemplateText",
  props: ["propsIndex"],
  data() {
    return {
      inputModel: {
        kind_no: 0
      },
      mstBbsKind: [],
      // ADD 患者イベントテンプレートマスタ画面修正 孔s
      initValue: {
        kind_no: 0,
        field_name: ""
      }
    };
  },
  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("master-maintenance", {
      getFacilitySwitch: "getFacilitySwitch",
      masterName: "getMasterName",
      schema: "getSchema",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord"
    }),
    ...mapGetters("mst-pat-event-template", {
      getInputParams: "getInputParams"
    }),
    getKindList() {
      return this.mstBbsKind;
    },
    selectedKindNo: {
      get() {
        return this.getInputParams[this.propsIndex].item_json.kind_no;
      },
      set(value) {
        this.inputModel.kind_no = value;
        const item = JSON.stringify(this.inputModel);
        this.setInputParamsUpdate({
          item: item,
          index: this.propsIndex
        });
        const inputParams = this.getInputParams;
        this.updateEditRecord("inputParams", JSON.stringify(inputParams));
      }
    }
  },
  async created() {
    // ADD 患者イベントテンプレートマスタ画面修正 孔s start
    this.initValue.kind_no = this.getInputParams[this.propsIndex].item_json.kind_no;
    this.initValue.field_name = this.getInputParams[this.propsIndex].field_name;
    // ADD 患者イベントテンプレートマスタ画面修正 孔s end
    // 患者イベントテンプレートマスタ画面修正
    // mod マスタ一覧 1･施設切替を可能とする 孔s start
    // const responseBbsKind = await ApiHelper.get(uriBbsKind, {
    //   facilityCd: this.facilityCd
    // });
    const responseBbsKind = await ApiHelper.get(uriBbsKind, {
      facilityCd: this.getFacilitySwitch
    });
    // mod マスタ一覧 1･施設切替を可能とする 孔s end
    // カテゴリ掲示板選択肢
    this.mstBbsKind = responseBbsKind.data;

    /*  ADD カスタムフィールドデフォルト修正 楊 START */
    if (this.mstBbsKind.length != 0 && !this.selectedKindNo) {
      this.selectedKindNo = this.mstBbsKind[0].kindNo;
    }
    /*  ADD カスタムフィールドデフォルト修正 楊 END */
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
    /**
     * 入力データの検証チェック
     */
    validateData() {
      let fieldNameValid = true;
      const kindNo = this.getInputParams[this.propsIndex].item_json.kind_no;
      const formatClass = this.getInputParams[this.propsIndex].format_class;
      // MOD 患者イベントテンプレートマスタ画面修正 孔s start
      // this.setFieldName(
      //     `bbs${this.propsIndex}${dayjs().format("YYYYMMDDHHmmss")}`,
      //     this.propsIndex
      // );
      let fieldNametemp = `bbs${this.propsIndex}${dayjs().format("YYYYMMDDHHmmss")}`
      if (
          this.initValue.kind_no === kindNo &&
          this.initValue.field_name !== "" &&
          this.initValue.field_name === this.getInputParams[this.propsIndex].field_name
      ) fieldNametemp = this.initValue.field_name
      this.setFieldName(fieldNametemp, this.propsIndex);
      // MOD 患者イベントテンプレートマスタ画面修正 孔s end
      const fieldName = this.getInputParams[this.propsIndex].field_name;
      fieldNameValid = fieldName !== null && fieldName !== "";
      return {
        kindValid: kindNo !== null && kindNo !== "" && kindNo !== undefined,
        formatClassValid: 0 <= formatClass,
        fieldNameValid: fieldNameValid
      };
    },
      //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },    
    setFieldName(value, index) {
      let inputParams = this.getInputParams;
      inputParams[index].field_name = value;
      inputParams[index].is_field_display = "0";
      this.setInputParams(JSON.stringify(inputParams));
      this.updateEditRecord("inputParams", JSON.stringify(inputParams));
    },
    /**
     * 入力データの検証チェック
     */
    validateOnRegistration() {
      const validationResult = this.validateData();
      if (Object.values(validationResult).every(v => v === true)) {
        return true;
      }
      // メッセージ組み立て
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
      // const title = "掲示板リンクのチェックエラー";
      const title = DIALOG_MESSAGES['00200129'].title;
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
              ? messageFormat(DIALOG_MESSAGES['00200129'].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.kindValid
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "カテゴリを選択する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200128'].message)
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
