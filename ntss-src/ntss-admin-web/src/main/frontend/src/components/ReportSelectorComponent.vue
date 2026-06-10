/**
 * 印刷選択ポップオーバー
 */
<template>
  <v-ons-popover
    :class="[fontSizeSet, 'user-menu-item-popover report-list-popover']"
    :visible="popoverVisible"
    :target="popoverTarget"
    direction="left"
  >
    <div class="report-list">
      <div
        v-for="(item, index) in getMstReports"
        :key="item.reportCd"
        :value="item.reportCd"
        :class="getItemClass(item.reportCd)"
        @click="onReportClick(index)"
      >
        <label>{{ item.reportName }}</label>
      </div>
    </div>
    <!-- mod #12107 帳票印刷失敗通知が行われない limingzhe 20251114 start -->
    <!--  <v-ons-select
      v-show="hasPrinter"
      v-model="selectedPrinter"
      data-non-authorize="true"
      class="printer-selection"
    > -->
    <v-ons-select
      :disabled="!hasPrinter"
      v-model="selectedPrinter"
      data-non-authorize="true"
      class="printer-selection"
    >
      <!-- mod #12107 帳票印刷失敗通知が行われない limingzhe 20251114 end -->
      <option v-for="item in getMstPrinters" :key="item.printerCd" :value="item.printerCd">{{ item.dispPrinterName }}</option>
    </v-ons-select>
    <div class="button-area flex-container">
      <div class="registration-btn-area">
        <button class="button registration-btn btn3-normal" @click="onPrint(true)">プレビュー</button>
      </div>
      <div class="registration-btn-area">
        <button
          class="button registration-btn btn3-normal"
          :disabled="!hasPrinter"
          @click="onPrint(false)">印刷</button>
      </div>
    </div>
    </v-ons-popover>
</template>

<script>
import { mapGetters, mapActions } from "vuex";
import { getCurrentFunctionCd } from "@/router/routing-helper";
import { EventBus } from "@/eventBus.js";
import { HISTORY_KEY_TREATMENT_RECORD_BVMS } from "@/router/treatment-record/HistoryKeyConstants";
import PopoverMixin from "@/components/PopoverMixin";
// import {formatDatetime} from "@/functions/common/CommonFunctions.js";
import {ApiHelper} from "@/apis/AxiosHelper";
// import {
//   sendRequestGetReportInfoByOrdNoWithLoader
// } from "@/apis/treatment-record";

export default {
  mixins: [PopoverMixin],
  props: {
    popoverVisible: {
      type: Boolean,
      default: false
    },
    popoverTarget: {
      type: HTMLElement,
      default: null
    }
  },

  data() {
    return {
      /**
       * 選択された帳票情報
       */
      selectedReport: null,
      /**
       * 選択されたプリンタ情報
       */
      selectedPrinter: null,
      /**
       * デフォルト帳票のプリンタ情報
       */
      defaultPrinter: null,
// add 6410 デグレ：機能帳票から「治療経過表」が消えている 吉 start
      dataKey: {
        ordNo: "",
        patId: ""
      },
      //add 6410 デグレ：機能帳票から「治療経過表」が消えている 吉 end
    };
  },
  watch: {
    // mod #12107 帳票印刷失敗通知が行われない limingzhe start
    //popoverVisible(visible) {
    async popoverVisible(visible) {
    // mod #12107 帳票印刷失敗通知が行われない limingzhe end
      if (visible) {
        this.selectedReport = null;
        this.selectedPrinter = null;
        // add #12107 帳票印刷失敗通知が行われない limingzhe start
        await this.getDefaultPrinter();
        // add #12107 帳票印刷失敗通知が行われない limingzhe end
        if (this.getMstReports.length > 0) {
          this.onReportClick(0);
        }
      }
    }
  },
  computed: {
    ...mapGetters("report", [
      "getMstReports",
      "getMstPrinters",
      "isPreview",
      "getDataKey"
    ]),
    ...mapGetters("treatment-record/common", ["getOrdNo"]),
    ...mapGetters("bread-crumb", ["getHistory"]),
    ...mapGetters("periodic-inspection", ["getStorSimlpSearchQurey"]),
    ...mapGetters("pat-info", ["searchedPatList", "selectedPat"]),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    /**
     * プリンターが登録されているか.
     *
     * @returns true : プリンタが登録されている場合
     *          false : プリンタが登録されていない場合
     */
    hasPrinter() {
      return this.getMstPrinters.length > 0;
    }
  },
  methods: {
    ...mapActions("report", [
      "getReportHTMLByReportCd",
      "setCreateReportParam",
      "setTargetPrinter",
      "setIsPreview"
    ]),
    ...mapActions("multi-modal", ["showPrintPreview", "showBVMSPrintPreview"]),

    /**
     * 帳票を出力する.
     *
     * @param mstReport 選択帳票情報
     * @param targetPrinter 出力先プリンタ情報
     */
    outputReport(mstReport, targetPrinter) {
      // ユーザーメニューを閉じる
      EventBus.$emit("closeUserMenu");
      // del #12569 BVMS画面からの機能帳票出力でエラー  吉 start
      //   EventBus.$emit("requestReportParams", getCurrentFunctionCd());
      // if (!this.isBvms()) {
      // del #12569 BVMS画面からの機能帳票出力でエラー  吉 end
        // add 各画面のプレビューと印刷の初期化対応 夏 start
        // add 6410 デグレ：機能帳票から「治療経過表」が消えている 吉 start
        this.dataKey.ordNo = this.getOrdNo;
        // add 6410 デグレ：機能帳票から「治療経過表」が消えている 吉 end
        this.setCreateReportParam({
          reportCd: this.selectedReport,
          reportParam: {
            dataKey: this.dataKey,
            targetPrinter: this.selectedPrinter
          }
        });
        // add 各画面のプレビューと印刷の初期化対応 夏 end
        // プリンタ登録
        this.setTargetPrinter(targetPrinter);
        // 印刷パラメータ要求
        EventBus.$emit("requestReportParams", getCurrentFunctionCd());
      // del #12569 BVMS画面からの機能帳票出力でエラー  吉 start
      // } else {

      //   // 帳票印刷2を呼び出し
      //   this.outputReport2(null);
      // }
      // del #12569 BVMS画面からの機能帳票出力でエラー  吉 end
    },
    // mod #11232 #10515で入れた制限の見直し 房 start
    /**
     * 帳票を出力する.
     *
     * @param dataKey 帳票出力する為のデータキー
     */
    async outputReport2(dataKey) {
    // del #12569 BVMS画面からの機能帳票出力でエラー  吉 start
      // if (!this.isBvms()) {
      // del #12569 BVMS画面からの機能帳票出力でエラー  吉 end
        this.setCreateReportParam({
          reportCd: this.selectedReport,
          reportParam: {
            dataKey: dataKey,
            targetPrinter: this.selectedPrinter
          }
        });
        // del #12569 BVMS画面からの機能帳票出力でエラー  吉 start
      // }
      // del #12569 BVMS画面からの機能帳票出力でエラー  吉 end
      // mod #12569 BVMS画面からの機能帳票出力でエラー  高 start
      // this.showPrintPreview();
      if (this.isPreview) {
        this.showPrintPreview();
      }else{
        this.getReportHTMLByReportCd(false);
      }
      // mod #12569 BVMS画面からの機能帳票出力でエラー  高 end
      // del #12569 BVMS画面からの機能帳票出力でエラー  吉 start
      // if (this.isPreview) {
      //   this.isBvms()
      //     ? this.showBVMSPrintPreview()
      //     : this.showPrintPreview();
      // } else {
      //   // this.isBvms()
      //   //   ? this.getReportHTMLForBVMS(this.getOrdNo)
      //   //   : this.getReportHTMLByReportCd(false);
      //   if(this.isBvms()) {
      //     this.getReportHTMLForBVMS(this.getOrdNo);
      //   } else {
      //     this.getReportHTMLByReportCd(false);
      //   }
      // }
      // del #12569 BVMS画面からの機能帳票出力でエラー  吉 end
    },
    // mod #11232 #10515で入れた制限の見直し 房 end
    /**
     * BVMSか否かを判断する.
     * 判断はルータ名が"bvms"か否かで判断する.
     *
     * @returns true : ルータ名に"bvms"が含まれている場合
     *          false : 含まればい場合
     */
    isBvms() {
      // 履歴取得
      const history = this.getHistory;
      // ルータ名
      const routerName =
        history.length > 0 ? history[history.length - 1].routerName : "";
      // bvmsのヒストリーキー取得(小文字化済)
      const historyKeyBvms = HISTORY_KEY_TREATMENT_RECORD_BVMS.toLowerCase();
      return routerName.toLowerCase().includes(historyKeyBvms);
    },
    /**
     * 帳票リストアイテムのクラスを取得する.
     *
     * @param reportCd 帳票コード
     */
    getItemClass(reportCd) {
      return [
        "report-item",
        reportCd == this.selectedReport ? "selected-item" : null
      ];
    },
    // add #12107 帳票印刷失敗通知が行われない limingzhe start
    async getDefaultPrinter(){
      const defaultPrinterResponse = await ApiHelper.get(`/facilitySetting/getFacilitySettingValue/${this.facilityCd}/1018`);
      const defaultPrinterInfo = defaultPrinterResponse.data;
      if (defaultPrinterInfo && defaultPrinterInfo != "-1") {
        this.defaultPrinter = defaultPrinterInfo;
      } else {
        this.defaultPrinter = this.getMstPrinters[0]?.printerCd;
      }
    },
    // add #12107 帳票印刷失敗通知が行われない limingzhe end
    /**
     * 帳票リストアイテムクリック時ハンドラ.
     *
     * @param index 選択インデックス
     */
    // mod #9320 自動印刷を行うプリンター及び、画面上で印刷指示を行う際のデフォルトプリンタの不正 liumx start
    async onReportClick(index) {
      // mod #9320 自動印刷を行うプリンター及び、画面上で印刷指示を行う際のデフォルトプリンタの不正 liumx end
      const mstReport = this.getMstReports[index];
      // del #12107 帳票印刷失敗通知が行われない limingzhe start
      // const mstPrinter = this.getMstPrinters.find(
      //   e => e.printerCd === mstReport.defaultPrinter
      // );
      // del #12107 帳票印刷失敗通知が行われない limingzhe end

      this.selectedReport = mstReport.reportCd;

      if (this.getMstPrinters.length > 0) {
        // mod #9320 自動印刷を行うプリンター及び、画面上で印刷指示を行う際のデフォルトプリンタの不正 liumx start
        // this.selectedPrinter = mstPrinter
        //   ? mstPrinter.printerCd
        //   : this.defaultPrinter;
        // add #12107 帳票印刷失敗通知が行われない limingzhe start
        var mstPrinter;
        if (mstReport.defaultPrinter !== "" && mstReport.defaultPrinter !== null) {
          mstPrinter = this.getMstPrinters.find(
            e => e.printerCd === mstReport.defaultPrinter
          );
        }
        // add #12107 帳票印刷失敗通知が行われない limingzhe end
        if (mstPrinter) {
          this.selectedPrinter = mstPrinter.printerCd;
        } else {
          // mod #12107 帳票印刷失敗通知が行われない limingzhe start
          // const defaultReportResponse = await ApiHelper.get(`/facilitySetting/getFacilitySettingValue/${this.facilityCd}/1018`);
          // const defaultReportID = defaultReportResponse.data;
          // if (defaultReportID && defaultReportID != "-1") {
          //   this.selectedPrinter = defaultReportID;
          // } else {
          //   this.selectedPrinter = null;
          // }
          if(this.defaultPrinter !== "" && this.defaultPrinter !== null) {
            this.selectedPrinter = this.defaultPrinter;
          }
          else {
            this.selectedPrinter = null;
          }
          // mod #12107 帳票印刷失敗通知が行われない limingzhe end
        }
        // mod #9320 自動印刷を行うプリンター及び、画面上で印刷指示を行う際のデフォルトプリンタの不正 liumx end
      }
    },
    /**
     * プレビュー、印刷ボタンクリック時ハンドラ.
     *
     * @param {boolean} isPreview true : プレビューボタン押下時
     *                            false : 印刷ボタン押下時
     */
    async onPrint(isPreview) {
      //del 5970 治療記録画面での機能帳票について 吉 start
      // var flag = true;
      // if(this.$route.path == "/treatment-record/list"){
      //   await sendRequestGetReportInfoByOrdNoWithLoader(this.getOrdNo).then(res => {
      //     if (res.data.reportId != this.selectedReport) {
      //       flag =false;
      //       this.$ons.notification.alert({
      //         title: "",
      //         message: "選択された帳票は治療法マスタに設定されていません。"
      //       })
      //
      //     }
      //   })
      // }else{
      //   const report = this.getMstReports.find(e => e.reportCd === this.selectedReport);
      //   if(report.reportClass == 1){
      //     const uriDetailed = "/patInfo/checkIsPrint";
      //     const sendData = {};
      //     sendData.facility_cd = this.selectedPat.pat_main.facility_cd;
      //     sendData.pat_id = this.selectedPat.pat_main.pat_id;
      //     sendData.treatDate = formatDatetime(this.getStorSimlpSearchQurey.treatDate, "YYYYMMDD");
      //     sendData.reportCd =report.reportCd;
      //     const resDetailed =await ApiHelper.get(
      //       uriDetailed,
      //       sendData
      //     ).catch(() => {
      //     });
      //     if(resDetailed.data == 0){
      //       flag =false;
      //       this.$ons.notification.alert({
      //         title: "",
      //         message: "選択された帳票は治療法マスタに設定されていません。"
      //       })
      //
      //     }
      //   }
      // }
      // プレビュー表示フラグをstoreに設定.
      // if(flag){
      //del 5970 治療記録画面での機能帳票について 吉 end
        this.setIsPreview(isPreview);
        // 帳票出力する.
        this.outputReport(
          this.getMstReports.find(e => e.reportCd === this.selectedReport),
          this.selectedPrinter
        );
        //del 5970 治療記録画面での機能帳票について 吉 start
      // }
      //del 5970 治療記録画面での機能帳票について 吉 end
    },
    /**
     * キャンセルボタンクリック時ハンドラ.
     */
    onCancel() {
      this.$emit("popover-close", null);
    }
  },
  async created() {
    // 印刷パラメータ受信して印刷を設定
    EventBus.$on("sendReportParams", this.outputReport2);
    // del #12107 帳票印刷失敗通知が行われない limingzhe start
    // // デフォルト帳票IDを取得
    // const defaultReportResponse = await ApiHelper.get(`/facilitySetting/getFacilitySettingValue/${this.facilityCd}/3004`);
    // const defaultReportID = defaultReportResponse.data;
    // // mod #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy start
    // // const mstReport = await ApiHelper.get("/report/getMstReportByFacilityCd/" + this.facilityCd);
    // const mstReport = await ApiHelper.get("/report/getMstReportByFacilityCdNoIsDisp/" + this.facilityCd);
    // // mod #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy end
    // const defaultReport = mstReport.data.find(
    //     e => e.reportCd === defaultReportID
    // );
    // if (defaultReport && defaultReport.defaultPrinter !== "" && defaultReport.defaultPrinter !== null) {
    //   this.defaultPrinter = defaultReport.defaultPrinter;
    // } else {
    //   //#9925:プリンター登録なしだとエラーが発生する。Start  #9590 再修正 start
    //   this.defaultPrinter = this.getMstPrinters[0]?.printerCd;
    //   //#9925:プリンター登録なしだとエラーが発生する。End  #9590 再修正 end
    // }
    // del #12107 帳票印刷失敗通知が行われない limingzhe end
  },
  beforeDestroy() {
    // 印刷パラメータ受信して印刷を解除
    EventBus.$off("sendReportParams", this.outputReport2);
  }
};
</script>

<style scoped>
.report-list-popover >>> .popover__content {
  width: 300px;
  min-height: 50px;
}
.report-list {
  width: 280px;
  height: 9em;
  font-size: 15px;
  margin: 8px;
  border: 1px solid #000000;
  overflow-y: auto;
}
.report-item {
  padding: 2px;
  line-height: 1.5;
}
.selected-item {
  background-color: #0090ff;
  color: #ffffff;
}
.printer-selection {
  width: 280px;
  margin-left: 8px;
}
.report-list-popover >>> .select-input {
  margin: 0px 2px;
}
.button-area {
  margin: 10px;
  height: auto;
}
/*  */
.registration-btn-area {
  background: none;
  margin-right: initial;
}
</style>
