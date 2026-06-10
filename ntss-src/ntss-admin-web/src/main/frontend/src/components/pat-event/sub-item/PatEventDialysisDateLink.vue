<template>
  <div class="vertical-div">
    <!--mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start-->
    <!--<div class="disp-item-area">
      <label class="title ntss-pat-event-label">{{ getTemplateFieldName }}</label>
    </div>
    <div v-if="getViewMode">
      <label class="ntss-pat-event-label ntss-pat-event-view">{{ selectedOrderText }}</label>
    </div>
    <div class="select-area"  v-else>-->
    <div class="disp-item-area" style="float: left;width: calc(100% / 4)">
      <div class="borderRight">
      <label class="title ntss-pat-event-label changeRow">{{ getTemplateFieldName }}</label>
      </div>
    </div>
    <div v-if="getViewMode || getIsOtherFacilitys" class="buttomTitle">
      <label class="ntss-pat-event-label ntss-pat-event-view">{{ selectedOrderText }}</label>
    </div>
    <div class="select-area buttomTitle"  v-else>
      <!--mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end-->
      <!-- mod FNSI-共有を追加 王 20200921 start -->
      <!-- mod #10359 編集権限の動作不正 start -->
      <!-- <v-ons-select
        float
        id="kind"
        v-model="inputModel.selectedOrdNo"
        class="ntss-pat-event-label"
        :disabled="getViewMode || !isShared"
        @change="onChangeLinkData()"
      > -->
      <!-- mod #12462 患者情報共有 20260312 start -->
      <v-ons-select
        float
        id="kind"
        v-model="inputModel.selectedOrdNo"
        class="ntss-pat-event-label"
        :disabled="
          getViewMode ||
          !isShared ||
          !getItemAuthorized('PatEvent', 'default_authority') ||
          getIsOtherFacilitys
        "
        @change="onChangeLinkData()"
      >
      <!-- mod #12462 患者情報共有 20260312 end -->
        <!-- mod #10359 編集権限の動作不正 end -->
      <!-- mod FNSI-共有を追加 王 20200921 end -->
        <option :value="0">(治療実績未選択)</option>
        <template v-if="!getEditingOrdNo">
          <option
            v-for="(ordMain, idxOrdMain) in getComboOrdMain"
            :key="idxOrdMain"
            :value="ordMain.ordNo"
          >{{ makeOrdMainComboText(ordMain) }}</option>
        </template>
        <template v-else>
          <option
            v-for="(ordMain, idxOrdMain) in ordMains"
            :key="idxOrdMain"
            :value="ordMain.ordNo"
          >{{ makeOrdMainComboText(ordMain) }}</option>
        </template>
      </v-ons-select>
    </div>
  </div>
</template>

<script>
  import {mapActions, mapGetters} from "vuex";
  import {deepCopy} from "@/functions/common/CommonFunctions";
  import moment from "moment";
// add #10359 編集権限の動作不正 start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 end

  export default {
  name: "PatEventDialysisDateLink",
  props: ["propsIndex"],
  components: {},
  data() {
    return {
      selectedOrdNoOld: 0,
      inputModel: {
        dialysisDataLinkFlag: false,
        selectedOrdNo: 0
      },
      selectedOrderText: "(治療実績未選択)",
      ordMains: []
    };
  },
  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("pat-event/detail", [
      "getPatEventInputParams",
      "getPatEventResultParams",
      "getPatEventRegStaffInfo",
      "getPatEventUpStaffInfo",
      "getViewMode",
      "getComboOrdMain",
      "getPatEventRecord"
    ]),
    ...mapGetters("observe-record/list", [
      "getEditingOrdNo",
      // add #12462 患者情報共有 20260312 start
      "getIsOtherFacilitys"
      // add #12462 患者情報共有 20260312 end
    ]),
    // add FNSi5673-治療実績リンクの選択肢に実績のない日が表示される 周 start
    ...mapGetters("bread-crumb", {keepHistories: "getKeepHistory"}),
    // add FNSi5673-治療実績リンクの選択肢に実績のない日が表示される 周 end
    ...mapGetters("pat-event/list", ["getUpdateMode","getPatEventFlg"]),
    // add FNSI-共有を追加 王 20200921 start
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("treatment-record/common", ["getSharedFacilityCd"]),
    // add #12462 患者情報共有 20260312 start
    ...mapGetters("pat-info", ["selectedPatId"]),
    // add #12462 患者情報共有 20260312 end
    isShared() {
      if(this.getPatEventRecord.isComRec){
        return this.getFacilityCd === this.getSharedFacilityCd;
      }
      return true;
    },
    // add FNSI-共有を追加 王 20200921 end
    getTemplateFieldName() {
      const flag = this.getPatEventInputParams[this.propsIndex]
        .is_field_display;
      if (flag === "1") {
        return this.getPatEventInputParams[this.propsIndex].field_name;
      } else {
        return "";
      }
    }
  },
  watch: {
    /*add FNSI-改修内容redmain5673 任 start*/
    "inputModel.selectedOrdNo"() {
      if(this.selectedOrdNoOld !== this.inputModel.selectedOrdNo){
        if(document.getElementById("kind") !== null){
          document.getElementById("kind")?.classList?.add("custom-select-edited");
        }
      }else{
        if(document.getElementById("kind") !== null){
          document.getElementById("kind").classList.remove("custom-select-edited");
        }
      }

    },
    getComboOrdMain(){
      // add FNSi5791患者イベントが２件に分かれて患者カレンダーに表示される 周 start
      if(undefined === this.getComboOrdMain || null === this.getComboOrdMain) {return;}
      // add FNSi5791患者イベントが２件に分かれて患者カレンダーに表示される 周 end
      if(this.getComboOrdMain !== null){
        const ordMain = this.getComboOrdMain.find(item => this.inputModel.selectedOrdNo === item.ordNo)
        if(!ordMain){
          this.inputModel.selectedOrdNo = 0;
        }
      }
      // mod FNSi5673-治療実績リンクの選択肢に実績のない日が表示される 周 start
      //if(this.getPatEventFlg){
      //del #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
      // if(this.keepHistories[0].routerName !== "pat-event") {
      // // mod FNSi5673-治療実績リンクの選択肢に実績のない日が表示される 周 end
      //     let length = this.getComboOrdMain.length;
      //     const startDate = this.getUpdateMode ? this.$parent.$refs.tab.eventStartDate : this.$parent.$refs.tab.inputModel.dayStartDate;
      //     for(let i = 0;i < length;i++){
      //       const viewDate = this.getComboOrdMain[i].viewTreatDate === null ? moment(this.getComboOrdMain[i].treatDate).format("YYYY-MM-DD") : moment(this.getComboOrdMain[i].viewTreatDate).format("YYYY-MM-DD")
      //       if(startDate !== viewDate){
      //         this.getComboOrdMain.splice(i,1);
      //         length -= 1;
      //         i -= 1;
      //       }
      //     }
      //   }
      //del #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc end
    }
    /*add FNSI-改修内容redmain5673 任 end*/
  },
  // del 6757 観察記録の新規登録時、カテゴリ選択を切り替えると入力欄の初期値が正しく表示されない 関 start
  // destroyed() {
  //   this.setEditingOrdNo(0);
  // },
  // del 6757 観察記録の新規登録時、カテゴリ選択を切り替えると入力欄の初期値が正しく表示されない 関  end
  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  created() {},
  mounted() {
    // del 9954 観察記録における実績リンクが編集済み表示となる 関 start
    // this.selectedOrdNoOld = this.inputModel.selectedOrdNo;
    // del 9954 観察記録における実績リンクが編集済み表示となる 関 end
    if (this.getUpdateMode || this.getViewMode) {
      this.findSelectedOrderMain();
      this.selectComboOrdMain();
    }
    if (this.getEditingOrdNo) {
      this.getComboOrdMain2();
    }
  },
  methods: {
    ...mapActions("pat-event/detail", [
      "setPatEventResultParamsUpdate",
      "setPatEventRecord",
      "fetchOrdMain",
      "setComboOrdMain",
      "fetchOrdMainRecord"
    ]),
    ...mapActions("observe-record/list", [
      "setEditingOrdNo"
    ]),
    /*add FNSI-改修内容redmain5673 任 start*/
    getOrdMain(){
      // add FNSi5791患者イベントが２件に分かれて患者カレンダーに表示される 周 start
      // add FNSi5673-治療実績リンクの選択肢に実績のない日が表示される 周 start
      if(this.keepHistories[0].routerName !== "pat-event") {
      // add FNSi5673-治療実績リンクの選択肢に実績のない日が表示される 周 end
      if(undefined !== this.getComboOrdMain && null !== this.getComboOrdMain) {
      // add FNSi5791患者イベントが２件に分かれて患者カレンダーに表示される 周 end
          let length = this.getComboOrdMain.length;
          const startDate = this.getUpdateMode ? this.$parent.$refs.tab.eventStartDate : this.$parent.$refs.tab.inputModel.dayStartDate;
          for(let i = 0;i < length;i++){
            const viewDate = this.getComboOrdMain[i].viewTreatDate === null ? moment(this.getComboOrdMain[i].treatDate).format("YYYY-MM-DD") : moment(this.getComboOrdMain[i].viewTreatDate).format("YYYY-MM-DD")
            if(startDate !== viewDate){
              this.getComboOrdMain.splice(i,1);
              length -= 1;
              i -= 1;
            }
          }
      // add FNSi5791患者イベントが２件に分かれて患者カレンダーに表示される 周 start
      }
      // add FNSi5673-治療実績リンクの選択肢に実績のない日が表示される 周 start
      }
      // add FNSi5673-治療実績リンクの選択肢に実績のない日が表示される 周 end
      // add FNSi5791患者イベントが２件に分かれて患者カレンダーに表示される 周 end
    },
    /*add FNSI-改修内容redmain5673 任 end*/
    
    // add #10359 編集権限の動作不正 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 end
    async onChangeLinkData() {
      const rec = this.getEditPatEvent();
      rec.ordNo = this.inputModel.selectedOrdNo;
      if (rec.ordNo === 0) {
        rec.ordNo = null;
      }
      await this.setPatEventRecord(rec);
    },
    getComboOrdMain2() {
      // 取得済みオーダー
      const rec = this.getPatEventRecord;
      // mod #12462 患者情報共有 20260312 start
      // const patId = rec.patId;
      const patId = this.selectedPatId;
      // mod #12462 患者情報共有 20260312 end
      this.ordMains = [];
      if (this.getEditingOrdNo) {
        // オーダーしていあり
        this.fetchOrdMainRecord({
          patId: patId,
          ordNo: this.getEditingOrdNo
        }).then(res => {
          let ord;
          if (res.data) {
            ord = res.data;
          } else {
            ord = {
              viewTreatDate: -1
            };
          }
          this.ordMains.push(ord);
          // add 9954 観察記録における実績リンクが編集済み表示となる 関 start
           this.selectedOrdNoOld = ord.ordNo;
          // add 9954 観察記録における実績リンクが編集済み表示となる 関 end
          this.inputModel.selectedOrdNo = ord.ordNo;
          this.onChangeLinkData();
        });
      }
    },
    getEditPatEvent() {
      const rec = deepCopy(this.getPatEventRecord);
      // mod #11445 【たくしん会】pat_eventのinput_params「null」によるクエリエラー問題　V1.0B 高 start
      if (this.getPatEventInputParams) {
        rec.inputParams = JSON.stringify(this.getPatEventInputParams);
      } else {
        rec.inputParams = null;
      }
      // rec.inputParams = JSON.stringify(this.getPatEventInputParams);
      // mod #11445 【たくしん会】pat_eventのinput_params「null」によるクエリエラー問題　V1.0B 高 end
      rec.resultParams = JSON.stringify(this.getPatEventResultParams);
      rec.regStaffInfo = JSON.stringify(this.getPatEventRegStaffInfo);
      rec.upStaffInfo = JSON.stringify(this.getPatEventUpStaffInfo);
      return rec;
    },
    findSelectedOrderMain() {
      // 取得済みオーダー
      const rec = this.getPatEventRecord;
      // mod #12462 患者情報共有 20260312 start
      // const patId = rec.patId;
      const patId = this.selectedPatId;
      // mod #12462 患者情報共有 20260312 end
      if (rec.ordNo) {
        // オーダーしていあり
        this.fetchOrdMainRecord({
          patId: patId,
          ordNo: rec.ordNo
        }).then(res => {
          let ord;
          if (res.data) {
            ord = res.data;
          } else {
            ord = {
              viewTreatDate: -1
            };
          }
          this.selectedOrderText = this.makeOrdMainComboText(ord);
        });
      }
    },
    async searchOrdMain() {
      // オーダ検索処理
      const rec = this.getPatEventRecord;
      // mod #12462 患者情報共有 20260312 start
      // const patId = rec.patId;
      const eventCd = rec.patEventCd;
      const patId = this.selectedPatId;
      // mod #12462 患者情報共有 20260312 end
      /*mod FNSI-改修内容患者event bug 任 start*/
      /*let sdt = new Date(rec.eventDate);*/
      let sdt = new Date(rec.eventStartDate);
      /*mod FNSI-改修内容患者event bug 任 end*/
      let edt = new Date(rec.eventEndDate);
      const startDate = this.formatterYMd(sdt);
      const endDate = this.formatterYMd(edt);
      await this.fetchOrdMain({
        patId: patId,
        treatStartDate: startDate,
        treatEndDate: endDate,
        patEventCd: eventCd,
      });
      let ordNo = rec.ordNo;
      if (ordNo === null) {
        ordNo = 0;
      }
      // add 9954 観察記録における実績リンクが編集済み表示となる 関 start
      this.selectedOrdNoOld = ordNo;
      // add 9954 観察記録における実績リンクが編集済み表示となる 関 end
      this.inputModel.selectedOrdNo = ordNo;
    },
    makeOrdMainComboText(ordMain) {
      let ret = "";
      if (String(ordMain.viewTreatDate) === "-1") {
        return "削除";
      }
      if (ordMain.rstDialysisState === "0") {

        ret =
          `${ordMain.viewTreatDate === null ? moment(ordMain.treatDate).format("YYYY/MM/DD") : ordMain.viewTreatDate}` +
          " 予定 " +
          `${ordMain.indKurName === null ? "-" : ordMain.indKurName} ${ordMain.indBedName === null ? "-" : ordMain.indBedName} ${ordMain.indTreatmentName === null ? "-" : ordMain.indTreatmentName}`;
      } else {
        // mod 5673 デグレ：治療実績リンクの選択肢に実績のない日が表示される 関 start
        //  ret =
        //   `${ordMain.viewTreatDate === null ? moment(ordMain.treatDate).format("YYYY/MM/DD") : ordMain.viewTreatDate}` +
        //   " 実績 " +
        //   `${ordMain.rstKurName === null ? "-" : ordMain.rstKurName} ${ordMain.rstBedName === null ? "-" : ordMain.rstBedName} ${ordMain.rstTreatmentName === null ? "-" : ordMain.rstTreatmentName}`;
        ret =
          `${moment(ordMain.treatDate).format("YYYY/MM/DD")}` +
          " 実績 " +
          `${ordMain.rstKurName === null ? "-" : ordMain.rstKurName} ${ordMain.rstBedName === null ? "-" : ordMain.rstBedName} ${ordMain.rstTreatmentName === null ? "-" : ordMain.rstTreatmentName}`;
          // mod 5673 デグレ：治療実績リンクの選択肢に実績のない日が表示される 関 end
      }
      return ret;

    },
    formatterYMd(value) {
      return moment(value, "YYYY-MM-DD").format("YYYYMMDD");
    },
    async selectComboOrdMain() {
      await this.searchOrdMain();
      // オーダ検索処理
      const rec = this.getPatEventRecord;
      // getComboOrdMainがnullの場合は[]として処理する
      const ordMain = this.getComboOrdMain || [];
      let ordBase = [];
      if (rec.ordNo) {
        const target = ordMain.find(c => c.ordNo === rec.ordNo);
        if (!target) {
          ordBase.push({
            ordNo: rec.ordNo,
            treatDate: 0,
            indTreatmentCd: 0,
            indTreatmentName: "",
            indKurCd: 0,
            indKurName: "",
            indKurName_1: "",
            indBedCd: 0,
            indBedName: "",
            rstKurCd: 0,
            rstKurName: "",
            rstBedCd: 0,
            rstBedName: "",
            rstTreatmentCd: 0,
            rstTreatmentName: "",
            rstDialysisState: 0,
            viewTreatDate: "-1"
          });
        }
      }
      const data = ordBase.concat(ordMain);
      this.setComboOrdMain(data);
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
  /*white-space: nowrap;*/
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
.title {
  margin-left: 10px;
  margin-top: 10px;
}
.input {
  max-width: 30em;
  background-color: white;
}
/* 患者イベントのテキストエリアの文字サイズが大きい  6095  shan   start */
.ntss-pat-event-view {
  font-size: 1em;
  margin-left: 10px;
  margin-top: 10px;
}
/* 患者イベントのテキストエリアの文字サイズが大きい  6095  shan   end */
.select >>> .select-input {
  opacity: 1;
}
  /*mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start*/
  /*.select-area {
    margin-left: 10px;
    margin-top: 10px;
  }*/
.select-area {
  margin-left: 10px;
  margin-bottom: 10px;
}
.buttomTitle {
  width: 75%;
  display: -webkit-box;
  align-items: center;
  margin-bottom: 10px;
  /*border-left: #595959 solid 1px;
  padding-left: 10px;*/
}
.borderRight {
  margin-bottom: 10px;
  padding-right: 10px;
}
.changeRow {
  overflow: hidden;
  word-spacing: normal;
  word-break: break-all;
}
  /*mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end*/
</style>
