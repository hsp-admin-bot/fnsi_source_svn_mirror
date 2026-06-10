<template>
  <div class="vertical-div">
    <!--mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start-->
    <!--<div class="disp-item-area">
      <label class="title ntss-pat-event-label">{{ getInputFieldName }}&emsp;</label>-->
    <div class="disp-item-area topTitle" style="float: left;width: calc(100% / 4)">
      <div class="borderRight">
        <label class="title ntss-pat-event-label changeRow">{{ getInputFieldName }}&emsp;</label>
      </div>
      <!--mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end-->
    </div>
    <div class="disp-item-area text-area" v-if="getViewMode || getIsOtherFacility || getIsOtherFacilitys">
      <label class="text-area-view ntss-pat-event-label">{{ inputText }}&nbsp;</label>
    </div>
    <div 
      class="disp-item-area text-area"
      v-else
    >
      <!-- mod FNSI-共有を追加 王 20200921 start -->
      <!-- mod #10359 編集権限の動作不正 start -->
      <!-- <v-ons-button class="button-import" @click="dataImport()" v-if="isSelectSourceField" :disabled="!isShared">取得</v-ons-button> -->
      <v-ons-button
        class="button-import"
        @click="dataImport()"
        v-if="isSelectSourceField"
        :disabled="
          !isShared ||
          !getItemAuthorized('PatEvent', 'default_authority')
        "
        >取得</v-ons-button
      >
      <!-- mod #10359 編集権限の動作不正 end -->
     <!-- mod FNSI-改修内容5682修正 関 start -->
     <!-- <v-ons-input
        class="content-textarea"
        v-model="valueInput"
        :disabled="!isShared"
		:class="classObject"
        @blur="editContent($event.target.value)"
		v-on="$listeners"
		@focus="addFocusCss($event)"
      ></v-ons-input> -->
      <!-- mod #10359 編集権限の動作不正 start -->
      <!-- <v-ons-input
        class="content-textarea v-ons-input-patevent"
        v-model="valueInput"
        :disabled="!isShared||disabled"
        :class="classObject"
        @blur="editContent($event.target.value)"
        v-on="$listeners"
        @focus="addFocusCss($event)"
      ></v-ons-input> -->
      <v-ons-input
        class="content-textarea v-ons-input-patevent"
        v-model="valueInput"
        :disabled="
          !isShared ||
          !getItemAuthorized('PatEvent', 'default_authority')
        "
        :class="classObject"
        @blur="editContent($event.target.value)"
        v-on="$listeners"
        @focus="addFocusCss($event)"
      ></v-ons-input>
      <!-- mod #10359 編集権限の動作不正 end -->
    <!-- mod FNSI-改修内容5682修正 関　end -->
      <!-- mod FNSI-共有を追加 王 20200921 end -->
    </div>
    <div class="disp-item-area text-area" v-if="getViewMode">
      <label class="text-area-view ntss-pat-event-label">{{inputText}}&nbsp;</label>
    </div>
  </div>
</template>

<script>
  import {mapActions, mapGetters} from "vuex";
  import BaseCustomInputTextStatus from '@/components/common/custom-form-tags/BaseCustomInputTextStatus';
  // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
  import { messageFormat } from '@/functions/common/MessageFormat';
  import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
  // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
// add #10359 編集権限の動作不正 start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 end
  export default {
  name: "PatEventText",
  mixins:[BaseCustomInputTextStatus],
  props: ["propsIndex"],
  data() {
    return {
      inputText: "",
      // add 6757 観察記録の新規登録時、カテゴリ選択を切り替えると入力欄の初期値が正しく表示されない 関 start
      // del 8336 【デグレ】患者イベント編集画面を開くと、テキストボックスの既存値が表示されない 関 start
      // valueInput: null
      // del 8336 【デグレ】患者イベント編集画面を開くと、テキストボックスの既存値が表示されない 関  end
      // add 6757 観察記録の新規登録時、カテゴリ選択を切り替えると入力欄の初期値が正しく表示されない 関  end
    };
  },
  computed: {
    // mod FNSI-共有を追加 王 20200921 start
    ...mapGetters("pat-event/detail", [
      "getPatEventInputParams",
      "getPatEventResultParams",
      "getPatEventRecord",
      "getViewMode"
    ]),
    // mod FNSI-共有を追加 王 20200921 end
    ...mapGetters("pat-event/list", ["getUpdateMode", "getIsOtherFacility"]),
    // add FNSI-共有を追加 王 20200921 start
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("treatment-record/common", ["getSharedFacilityCd"]),
    ...mapGetters("observe-record/list", ["getIsOtherFacilitys"]),
    isShared() {
      if(this.getPatEventRecord.isComRec){
        return this.getFacilityCd === this.getSharedFacilityCd;
      }
      return true;
    },
    // add FNSI-共有を追加 王 20200921 end
    getInputFieldName() {
      const flag = this.getPatEventInputParams[this.propsIndex]
        .is_field_display;
      if (flag === "1") {
        return this.getPatEventInputParams[this.propsIndex].field_name;
      } else {
        return "";
      }
    },
    isSelectSourceField() {
      const input = this.getPatEventInputParams[this.propsIndex].item_json;
      // add 6757 観察記録の新規登録時、カテゴリ選択を切り替えると入力欄の初期値が正しく表示されない 関 start
      this.getResultContentText;
      // add 6757 観察記録の新規登録時、カテゴリ選択を切り替えると入力欄の初期値が正しく表示されない 関  end
      return input.sql_cd && String(input.sql_cd).length > 0;
    },
    getInputDefaultValue() {
      const input = this.getPatEventInputParams[this.propsIndex].item_json;
      // add 6757 観察記録の新規登録時、カテゴリ選択を切り替えると入力欄の初期値が正しく表示されない 関 start
      this.valueInput = input.default_value;
      // add 6757 観察記録の新規登録時、カテゴリ選択を切り替えると入力欄の初期値が正しく表示されない 関  end
      return input.default_value;
    },
    getInputMaxLength() {
      const input = this.getPatEventInputParams[this.propsIndex].item_json;
      return input.max_length;
    },
    getResultHtmlText() {
      const result = this.getPatEventResultParams[this.propsIndex].result_value;
      return result;
    },
    getResultContentText() {
      /*mod FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 start*/
      /*if (this.getResultHtmlText !== "") {*/
      if (this.getResultHtmlText !== "" && this.getResultHtmlText !== undefined) {
        /*mod FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 end*/
        return this.getResultHtmlText;
      } else {
        if (this.getInputDefaultValue !== "") {
          return this.getInputDefaultValue;
        }
      }
      return "";
    }
  },

  watch: {},
  
  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  destroyed() { },

  created() {},

  mounted() {
    this.inputText = this.getResultContentText;
    this.editContent(this.inputText);
  },

  methods: {
    ...mapActions("pat-event/detail", ["setPatEventResultParamsUpdate"]),
    async editContent(value) {
	  this.delFocusCss();
      const result = this.getPatEventResultParams[this.propsIndex];
      const values = {
        format_class: result.format_class,
        result_value: value
      };
      await this.setPatEventResultParamsUpdate({
        item: values,
        index: this.propsIndex
      });
    },
    // add #10359 編集権限の動作不正 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 end

    /**
     * 入力データの検証チェック
     */
    validateData() {
      const input = this.getPatEventInputParams[this.propsIndex];
      const result = this.getPatEventResultParams[this.propsIndex];
      let textValid = true;
      let count = 0;
      count = Number(input.item_json.max_length);
      if (result.result_value.length > count) {
        textValid = false;
      }
      return {
        textValid: textValid
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
      // メッセージ組み立て
      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
      // const title = "チェックエラー";
      const title = DIALOG_MESSAGES[12000310].title;
      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      const message = `
          ${
            !validationResult.textValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "文字数が入力可能文字数を超えてます。<br>"
              ? messageFormat(DIALOG_MESSAGES[12000310].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
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
    dataImport() {
      const input = this.getPatEventInputParams[this.propsIndex].item_json;
      this.$emit("patEventImport", {
        index: this.propsIndex,
        sqlCd: input.sql_cd
      });
    },
    dataImportResult(dataList) {
      const field = this.getPatEventInputParams[this.propsIndex].item_json
        .source_field;
      let values = [];
      for (const data of dataList) {
        values.push(data[field]);
      }
      this.editContent(values.join("\n"));
      this.inputText = values.join("\n");
    }
  }
};
</script>

<style scoped>
  /*mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start*/
  /*.vertical-div {
    display: flex;
    flex-direction: column;
    align-content: flex-start;
    font-size: 1em;
  }
  .horizontal-div {
    display: flex;
    flex-direction: row;
    align-content: center;
    font-size: 1em;
  }
  .disp-item-area {
    width: 100%;
    border-collapse: collapse;
  }*/
.vertical-div {
  display: flex;
  align-content: flex-start;
  font-size: 1em;
  border-bottom: #595959 solid 1.5px;
  align-items: center;
  padding-bottom: 10px;
}
.horizontal-div {
  display: flex;
  flex-direction: row;
  align-content: center;
  font-size: 1em;
}
.disp-item-area {
  /*width: 100%;*/
  border-collapse: collapse;
}
  /*mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end*/
.disp-item-area tr {
  height: 50px;
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
.onscol {
  padding-top: 10px;
}
.title {
  padding: 10px;
}
.text-area {
  padding: 10px;
  /*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start*/
  width: 75%;
  /*border-left: #595959 solid 1px;*/
  /*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end*/
}
/* 暗背景テーマのテキストエリアの文字色が見えない 5569 shan start */
.text-area-view {
  /* background-color: #FAFAFA; */
  font-size: 1em;
  display: block;
}
/* 暗背景テーマのテキストエリアの文字色が見えない 5569 shan end */
/* 取得ボタン */
.button-import {
  width: 4em;
}
  /*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start*/
/*.topTitle {*/
/*  white-space: nowrap;*/
/*}*/
  .changeRow {
    overflow: hidden;
    word-spacing: normal;
    word-break: break-all;
  }
  /*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end*/
  /* add FNSI-改修内容5682修正 関 start */
  .v-ons-input-patevent >>> .text-input {
     background-color: #F7F7F7 !important;
     color: black  !important;
  }
   /* add FNSI-改修内容5682修正 関　end */
</style>
