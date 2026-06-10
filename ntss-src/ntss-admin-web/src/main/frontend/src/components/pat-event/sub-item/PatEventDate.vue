<template>
  <div class="vertical-div">
    <!--mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start-->
   <!--<div class="disp-item-area">-->
    <div class="disp-item-area paddingBottom" style="float: left;width: calc(100% / 4)">
      <!--mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end-->
      <!--mod FNSI-改修内容日付のチェックの追加対応。 任 start-->
     <!-- <label class="title ntss-pat-event-label">{{getInputFieldName}}&emsp;</label>-->
     <!-- mod 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 start -->
      <!-- <label id="input-model-file-name" class="title ntss-pat-event-label" style="white-space: break-spaces">{{getInputFieldName}}&emsp;</label> -->
      <label id="input-model-file-name" class="title ntss-pat-event-label pat-event-date" style="white-space: break-spaces">{{getInputFieldName}}&emsp;</label>
      <!-- mod 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 end -->
      <!--mod FNSI-改修内容日付のチェックの追加対応。 任 end-->
    </div>
    <!-- mod #12462 患者情報共有 20260326 start -->
    <div class="input-date flex-align-center" v-if="getViewMode || getIsOtherFacility || getIsOtherFacilitys">
      <label class="ntss-pat-event-label">{{ showDate }}</label>
    </div>
    <!-- <div class="input-date flex-align-center" v-if="!getViewMode"> -->
    <div class="input-date flex-align-center" v-else>
      <!-- mod FNSI-共有を追加 王 20200921 start -->
      <!--mod FNSI-改修内容日付のチェックの追加対応。 任 start-->
      <!--<input
        type="date"
        v-model="inputModel.date"
        :disabled="getViewMode || !isShared"
        class="input ntss-input-date"
        @blur="changeDate()"
      />-->
	  <!-- mod No.18 付 20210127 start -->
	  <!-- v-model="inputModel.date" => v-model="valueInput" -->
	  <!-- add :class="classObject" -->
	  <!-- add @focus="addFocusCss($event)" -->
    <!-- mod 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 start -->
      <!-- <input
        ref="myInput"
        type="date"
        max="9999-12-31"
        v-model="valueInput"
        :class="classObject"
        :disabled="getViewMode || !isShared"
        class="input ntss-input-date input-model-date"
        @blur="changeDate()"
		@focus="addFocusCss($event)"
      /> -->
      <!-- mod #10359 編集権限の動作不正 start -->
      <!-- <date-input
        ref="myInput"
        type="date"
        max="9999-12-31"
        v-model="valueInput"
        :class="classObject"
        :disabled="getViewMode || !isShared || dateClassTheDay"
        class="input ntss-input-date input-model-date"
        @blur="changeDate()"
        @focus="addFocusCss($event)"
        @handleClearInput='clearDate()'
      /> -->
      <date-input
        ref="myInput"
        type="date"
        max="9999-12-31"
        v-model="valueInput"
        :class="classObject"
        :disabled="
          getViewMode ||
          !isShared || 
	  dateClassTheDay ||
          !getItemAuthorized('PatEvent', 'default_authority') ||
        getIsOtherFacility ||
        getIsOtherFacilitys
        "
        class="input ntss-input-date input-model-date"
        @blur="changeDate()"
        @focus="addFocusCss($event)"
        @handleClearInput="clearDate()"
      />
	  <!-- mod #10359 編集権限の動作不正 end -->
      <!-- mod 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 end -->
	  <!-- mod No.18 付 20210127 end -->
      <!--mod FNSI-改修内容日付のチェックの追加対応。 任 end-->
      <!-- mod #10359 編集権限の動作不正 start -->
      <!-- <common-calendar v-model="inputModel.date" :disabled="getViewMode || !isShared || dateClassTheDay" @input="changeDate()" /> -->
      <common-calendar
        v-model="inputModel.date"
        :disabled="
          getViewMode ||
          !isShared  ||
	  dateClassTheDay ||
          !getItemAuthorized('PatEvent', 'default_authority') ||
        getIsOtherFacility ||
        getIsOtherFacilitys
        "
        @input="changeDate()"
      />
      <!-- mod #10359 編集権限の動作不正 end -->
      <!-- mod FNSI-共有を追加 王 20200921 end -->
      <!-- mod #12462 患者情報共有 20260312 end -->
    </div>
  </div>
</template>

<script>
  import {mapActions, mapGetters} from "vuex";
  import {DATE_FORMAT, dateFormat} from "@/functions/common/DateTimeUtils.js";
  import moment from "moment";
  import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
  // add No.18 付 20210127 start
  import BaseCustomInputStatus from '@/components/common/custom-form-tags/BaseCustomInputStatus'
  // add No.18 付 20210127 end
  // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
  import { messageFormat } from '@/functions/common/MessageFormat';
  import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
  // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
  // add 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 start
  import DateInput from "@/components/common/DateInput.vue";
  // add 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 end
// add #10359 編集権限の動作不正 start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 end
export default {
  name: "PatEventDate",
  // add No.18 付 20210127 start
  mixins:[BaseCustomInputStatus],
  // add No.18 付 20210127 end
  props: ["propsIndex", "propsIniDate"],
  components: {
    "common-calendar": commonCalender,
    // add 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 start
    "date-input":DateInput,
    // add 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 end
  },
  data() {
    return {
      inputModel: {
        date: ""
      },
      // del 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 start
      // 内部 【観察記録】 観察記録画面日期显示不正 start
      // refreshDate: null,
      // count: 0
      // 内部 【観察記録】 観察記録画面日期显示不正 end
      // del 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 end
    };
  },

  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    // mod FNSI-共有を追加 王 20200921 start
    ...mapGetters("pat-event/detail", [
      "getPatEventInputParams",
      "getPatEventResultParams",
      "getPatEventRecord",
      "getViewMode",
      // add 8147 デフォルト値：当日 の日付の項目が、患者イベント開始日を変更しても更新されない 関 start
      "getPatPlansParams",
      // add 8147 デフォルト値：当日 の日付の項目が、患者イベント開始日を変更しても更新されない 関  end
    ]),
    // mod FNSI-共有を追加 王 20200921 end
    // add FNSI-共有を追加 王 20200921 start
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("treatment-record/common", ["getSharedFacilityCd"]),
    // add #12462 患者情報共有 20260312 start
    ...mapGetters("pat-event/list", ["getIsOtherFacility"]),
    ...mapGetters("observe-record/list", ["getIsOtherFacilitys"]),
    // add #12462 患者情報共有 20260312 end
    isShared() {
      if(this.getPatEventRecord.isComRec){
        return this.getFacilityCd === this.getSharedFacilityCd;
      }
      return true;
    },
    // add FNSI-共有を追加 王 20200921 end
    getResultDate() {
      return this.getPatEventResultParams[this.propsIndex].result_value;
    },
    getInputDateClass() {
      return this.getPatEventInputParams[this.propsIndex].item_json.date_class;
    },
    getInputFieldName() {
      const flag = this.getPatEventInputParams[this.propsIndex]
        .is_field_display;
      if (flag === "1") {
        return this.getPatEventInputParams[this.propsIndex].field_name;
      } else {
        return "";
      }
    },
    showDate() {
      // add 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 start
      // return moment(this.valueInput).format("YYYY/MM/DD");
      return this.valueInput? moment(this.valueInput).format("YYYY/MM/DD") : "";
      // add 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 end
    },
    dateClassTheDay() {
      return this.getInputDateClass === "1";
    },
  },

  watch: {
    // mod 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 start
    // add 8147 デフォルト値：当日 の日付の項目が、患者イベント開始日を変更しても更新されない 関 start
    // async getPatPlansParams() {
    'getPatPlansParams.startDate'(){
      // mod 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 end
      const classdate = this.getInputDateClass;
      if (classdate === "1") {
        this.inputModel.date = this.getPatPlansParams.startDate;
      }
    }
    // add 8147 デフォルト値：当日 の日付の項目が、患者イベント開始日を変更しても更新されない 関  end
  },
  
  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  destroyed() { },

  created() {},

  mounted() {
    // mod 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 start
    // if (this.getResultDate === "") {
    //   let today = new Date();
    //   if (this.propsIniDate) {
    //     today = new Date(this.propsIniDate.replace(/-/g, "/"));
    //   }
    //   // 日付初期値設定
    //   const classdate = this.getInputDateClass;
    //   // mod 8125 【デグレ】患者イベント＞スコア計算、日付の不正 関 start
    //   // if (classdate !== "0") {
    //   //   this.inputModel.date = dateFormat.format(
    //   //     new Date(today.getFullYear(), today.getMonth(), today.getDate()),
    //   //     DATE_FORMAT
    //   //   );
    //   //   this.changeDate();
    //   // }
    //   if (classdate === "1") {
    //     this.inputModel.date = dateFormat.format(
    //       new Date(today.getFullYear(), today.getMonth(), today.getDate()),
    //       DATE_FORMAT
    //     );
    //     this.changeDate();
    //   } else if (classdate === "2") {
    //     this.inputModel.date = dateFormat.format(
    //       new Date(today.getFullYear(), today.getMonth(), today.getDate()),
    //       DATE_FORMAT
    //     );
    //     this.changeDate();
    //   } else if (classdate === "3") {
    //      this.inputModel.date = dateFormat.format(
    //       new Date(today.getFullYear(), today.getMonth(), today.getDate()+1),
    //       DATE_FORMAT
    //     );
    //     this.changeDate();
    //   } else if (classdate === "4") {
    //     this.inputModel.date = dateFormat.format(
    //       new Date(today.getFullYear(), today.getMonth(), today.getDate()+2),
    //       DATE_FORMAT
    //     );
    //     this.changeDate();
    //   } else if (classdate === "5") {
    //     this.inputModel.date = dateFormat.format(
    //       new Date(today.getFullYear(), today.getMonth(), today.getDate()-1),
    //       DATE_FORMAT
    //     );
    //     this.changeDate();
    //   } else if (classdate === "6") {
    //     this.inputModel.date = dateFormat.format(
    //       new Date(today.getFullYear(), today.getMonth(), today.getDate()-2),
    //       DATE_FORMAT
    //     );
    //     this.changeDate();
    //   } else {
    //      this.inputModel.date = dateFormat.format(
    //       new Date(today.getFullYear(), today.getMonth(), today.getDate()),
    //       DATE_FORMAT
    //     );
    //     this.changeDate();
    //   }
    // } else {
    //   const today = new Date(this.getResultDate);
    //   this.inputModel.date = dateFormat.format(
    //     new Date(today.getFullYear(), today.getMonth(), today.getDate()),
    //     DATE_FORMAT
    //   );
    //   // mod 8125 【デグレ】患者イベント＞スコア計算、日付の不正 関  end
    // }
    if (this.getResultDate != null && this.getResultDate != "") {
      const today = new Date(this.getResultDate);
      this.inputModel.date = dateFormat.format(
        new Date(today.getFullYear(), today.getMonth(), today.getDate()),
        DATE_FORMAT
      );
    }
    // mod 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 end
  },

  methods: {
    // del 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 start
    // 内部 【観察記録】 観察記録画面日期显示不正 start
    // addFocusCss (val) {
    //   this.count++
    //   // this.$emit("addFocusCss", this.inputModel.date)
    //   if (this.count === 1) {
    //     this.refreshDate = this.inputModel.date
    //   }
    // },
    // 内部 【観察記録】 観察記録画面日期显示不正 end
    // del 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 end
    ...mapActions("pat-event/detail", ["setPatEventResultParamsUpdate"]),
    async changeDate() {
	  // add No.18 付 20210127 start
	  //this.delFocusCss();
	  // add No.18 付 20210127 end
      const result = this.getPatEventResultParams[this.propsIndex];
      const values = {
        format_class: result.format_class,
        result_value: this.inputModel.date
      };
      await this.setPatEventResultParamsUpdate({
        item: values,
        index: this.propsIndex
      });
      // this.$emit("changeDate", this.inputModel.date)
      // del 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 start
      // 内部 【観察記録】 観察記録画面日期显示不正 start
      // if (!this.inputModel.date) {
      //    this.$ons.notification.confirm({
      //     // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
      //     // mod bug #6506 修正 chen start
      //     // title: "確認"
      //     title: DIALOG_MESSAGES[13000162].title,
      //     buttonLabels: ["キャンセル", "OK"],
      //     // title: "動作確認",
      //     // mod bug #6506 修正 chen end
      //     // message: "現在集計処理中です。</br>集計がキャンセルされますがよろしいですか？",
      //     message: messageFormat(DIALOG_MESSAGES[13000162].message),
      //     // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
      //     callback: answer => {
      //       if (answer == 1) {
      //        this.inputModel.date = this.refreshDate
      //       } else {
      //         this.$refs.myInput.focus();
      //       }
      //     }
      //   });
      // }
      // 内部 【観察記録】 観察記録画面日期显示不正 end
      // del 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 end
    },
    /**
     * 入力データの検証チェック
     */
    // del 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 start
    // validateData() {
    //   let dateValid = true;
    //   const result = this.getPatEventResultParams[this.propsIndex];
    //   if (result.result_value !== "") {
    //     if (!moment(result.result_value, "YYYY-MM-DD", true).isValid()) {
    //       dateValid = false;
    //     }
    //   }
    //   return {
    //     dateValid: dateValid
    //   };
    // },
    // del 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 end
    // add #10359 編集権限の動作不正 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 end

    /**
     * 入力データの検証チェック
     */
    validateOnRegistration() {
      // mod 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 start
      // const validationResult = this.validateData();
      // if (Object.values(validationResult).every(v => v === true)) {
      //   return true;
      // }
      // // メッセージ組み立て
      // // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
      // // const title = "チェックエラー";
      // // const message = `
      // //     ${!validationResult.dateValid ? "日付が正しくありません。<br>" : ""}
      // //   `;
      // const title = DIALOG_MESSAGES[12000189].title;
      // const message = `
      //     ${!validationResult.dateValid ? messageFormat(DIALOG_MESSAGES[12000189].message) : ""}
      //   `;
      // // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      // // ダイアログ表示
      // this.$ons.notification.alert({
      //   title: title,
      //   message: message
      // });
      // return false;
      let dateValid = true;
      let message = null;
      for (let index = 0; index < document.getElementsByClassName("input-model-date").length; index++) {
        if (document.getElementsByClassName("input-model-date")[index].children.DateInput.validationMessage) {
          dateValid = false;
          const dateName = document.getElementsByClassName("pat-event-date")[index].innerText;
          message = `${dateName+messageFormat(DIALOG_MESSAGES[12000189].message)}`+'\n'+(message ? message : "");
        }
      }
      if (message) {
        const title = DIALOG_MESSAGES[12000189].title;
        // ダイアログ表示
        this.$ons.notification.alert({
            title: title,
            message: message
        });
      }
      return dateValid;
      // mod 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 end
    },
    // add 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 start
    clearDate() {
      this.valueInput = "";
      this.changeDate();
    },
    // add 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 end
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
}
.disp-item-area {
  border-collapse: collapse;
  white-space: nowrap;
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
  /*mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start*/
  /*.title {
    padding: 10px;
  }
  .title2 {
    padding: 10px;
    float: left;
  }
  .input {
    max-width: 30em;
    background-color: white;
    font-size: 1.5em;
  }
  .input-date {
    padding: 10px;
  }*/
.title {
  padding-bottom: 10px;
  padding-left: 10px;
  overflow: hidden;
  word-spacing: normal;
  word-break: break-all;
}
.title2 {
  padding: 10px;
  float: left;
}
.input {
  max-width: 30em;
  background-color: white;
  /* font-size: 1.5em; */
}
.input-date {
  /*width: 100%;*/
  margin-bottom: 10px;
  padding-left: 10px;
  /*border-left: #595959 solid 1px*/
}
.paddingBottom {
  padding-bottom: 10px;
}
  /*mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end*/
/* add No.18 付 20210127 start */
.custom-input-edited {
	border: 2px green solid;
	outline: 0;
}

.custom-input-required {
	color: black;
	background-color: #ffff99;
}

.custom-input-invalid {
	color: black;
	background-color: rgba(255, 0, 0, 0.5);
}
/* add No.18 付 20210127 end */
</style>
