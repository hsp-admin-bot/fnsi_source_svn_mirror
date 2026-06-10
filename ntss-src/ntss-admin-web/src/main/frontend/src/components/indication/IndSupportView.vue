/* 投薬支援 */
<template>
  <!-- mod FNSI-投薬支援242の対応 徐 start -->
  <!-- <modal-base @onClose="hideModal" style="opacity:1" id="modalBase"> -->
  <modal-base
    :onClose="hideModal"
    style="opacity:1"
    id="modalBase"
    class="ind-support-view"
    :setting="settingMedicineSupport"
    :title="'投薬支援'"
  >
    <!-- mod FNSI-投薬支援242の対応 徐 end -->
    <div slot="body" class="width-style ind-sp-flex-nowrap-center" :class="fontSizeSet" style="justify-content: space-between;">
      <div class="ind-sp-flex-nowrap-center">
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <v-ons-select class="result-select" -->
        <!--     :id = "'support'" -->
        <!--     @change="changeSelected()" -->
        <!--     v-model="support" -->
        <!--     style="width: 10em;"> -->
        <v-ons-select class="result-select"
            :id = "'support'"
            @change="changeSelected()"
            v-model="support"
            :disabled="!getItemAuthorized('Indication', 'default_authority')"
            style="width: 10em;">
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <option
            v-for="(value, index) in getSupport()"
            :key="index"
            :value="value.cd"
          >{{value.text}}</option>
        </v-ons-select>
        <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
        <!-- <v-ons-button style="margin-left: 3em;margin-top: 0.5em;width: 100px" @click="showPatExcludedPeriod()">除外設定</v-ons-button> -->
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <v-ons-button class="btn3-normal width-padding" style="margin-left: 1em; width: 5em" @click="showPatExcludedPeriod()">除外設定</v-ons-button> -->
        <v-ons-button
          class="btn3-normal width-padding"
          style="margin-left: 1em; width: 5em"
          :disabled="!getItemAuthorized('Indication', 'default_authority')"
          @click="showPatExcludedPeriod()">除外設定</v-ons-button>
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
      </div>
      <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
      <v-ons-range v-model="windowRange" v-on:input="changeWindow()" min='1' max='10' style="margin-left: 1em; min-width: 5em;"></v-ons-range>
    </div>
    <div slot="body" style="margin-top: 0.5em;" :class="fontSizeSet"><hr class="width-style"/></div>
    <!-- cycling -->
    <!-- mod FNSI-投薬支援242の対応 徐 start -->
    <!-- <div slot="body" class="modal-container-custom width-style" id="cycling" width="100%"> -->
    <div slot="body" :class="fontSizeSet" class="modal-container-custom width-style" id="cycling" width="100%">
    <!-- mod FNSI-投薬支援242の対応 徐 end -->
      <div>Cycling：</div>
      <table class="tabledate" width="100%">
        <thead width="100%">
          <tr width="100%">
            <td class="tddata-title ind-sp-tb-gradation" width="15%"></td>
            <td class="tddata-title ind-sp-tb-gradation" width="17%">年間{{lastYearBegin}} ～ {{lastYearEnd}}</td>
            <td class="tddata-title ind-sp-tb-gradation" width="17%">年間{{nowYearBegin}} ～ {{nowYearEnd}}</td>
            <td width="51%"></td>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td class="tddata-title">⊿</td>
            <td class="tddata tddata-1">{{lastRest}}</td>
            <td class="tddata tddata-1">{{nowRest}}</td>
          </tr>
          <tr>
            <td class="tddata-title">最大</td>
            <td class="tddata tddata-2">{{lastMax}}</td>
            <td class="tddata tddata-2">{{nowMax}}</td>
          </tr>
          <tr>
            <td class="tddata-title">最小</td>
            <td class="tddata tddata-1">{{lastMin}}</td>
            <td class="tddata tddata-1">{{nowMin}}</td>
          </tr>
          <tr>
            <td class="tddata-title">偏差</td>
            <td class="tddata tddata-2">{{lastDeviation}}</td>
            <td class="tddata tddata-2">{{nowDeviation}}</td>
          </tr>
          <tr>
            <td class="tddata-title">回数</td>
            <td class="tddata tddata-1">{{lastFrequency}}</td>
            <td class="tddata tddata-1">{{nowFrequency}}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div slot="body" style="margin-top: 0.5em;" :class="fontSizeSet"><hr class="width-style"/></div>
    <!--検査平均値 -->
    <!-- mod FNSI-投薬支援242の対応 徐 start -->
    <!-- <div slot="body" class="modal-container-custom width-style" id="checkAvg"> -->
    <div slot="body" class="modal-container-custom width-style" :class="fontSizeSet" id="checkAvg">
    <!-- mod FNSI-投薬支援242の対応 徐 end -->
      <div style="display: flex;">
        検査平均値：
        <div class="ind-sp-flex-nowrap-center" style="margin-right: 0.5em;">
          <v-ons-radio
            modifier="round"
            name="checkAvgTime"
            value="1"
            input-id="check-three-month"
            v-model="checkAvgTime"
            @change="changeCheckAvgTime(1)"
          />
          <label for="check-three-month">12週</label>
        </div>
        <div class="ind-sp-flex-nowrap-center" style="margin-right: 0.5em;">
          <v-ons-radio
            modifier="round"
            name="checkAvgTime"
            value="2"
            input-id="check-six-month"
            v-model="checkAvgTime"
            @change="changeCheckAvgTime(2)"
          />
          <label for="check-six-month">6ヶ月</label>
        </div>
        <div class="ind-sp-flex-nowrap-center" style="margin-right: 0.5em;">
          <v-ons-radio
            modifier="round"
            name="checkAvgTime"
            value="3"
            input-id="check-one-year"
            v-model="checkAvgTime"
            @change="changeCheckAvgTime(3)"
          />
          <label for="check-one-year">1年</label>
        </div>
        <div class="ind-sp-flex-nowrap-center">
          <v-ons-radio
            modifier="round"
            name="checkAvgTime"
            value="4"
            input-id="check-three-year"
            v-model="checkAvgTime"
            @change="changeCheckAvgTime(4)"
          />
          <label for="check-three-year">3年</label>
        </div>
      </div>
      <table class="tabledate" width="100%">
        <thead width="100%">
          <tr width="100%">
            <td class="tddata-title ind-sp-tb-gradation" width="15%">検査項目</td>
            <td class="tddata-title ind-sp-tb-gradation" width="17%">平均値</td>
            <td class="tddata-title ind-sp-tb-gradation" width="17%">最大値</td>
            <td class="tddata-title ind-sp-tb-gradation" width="17%">最小値</td>
            <td class="tddata-title ind-sp-tb-gradation" width="17%">最新値</td>
            <td class="tddata-title ind-sp-tb-gradation" width="17%">最終検査日</td>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(avgItem,index) in avgItemList" :key="index">
            <td class="tddata-title" style="word-break: break-all;">{{avgItem[0]}}&#8195;</td>
            <td class="tddata" :class="getBackground(index)">{{avgItem[1]}}</td>
            <td class="tddata" :class="getBackground(index)">{{avgItem[2]}}</td>
            <td class="tddata" :class="getBackground(index)">{{avgItem[3]}}</td>
            <td class="tddata" :class="getBackground(index)">{{avgItem[4]}}</td>
            <td class="tddata" :class="getBackground(index)">{{avgItem[5]}}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div slot="body" style="margin-top: 0.5em;" :class="fontSizeSet"><hr class="width-style"/></div>
    <!--薬剤平均投与量 -->
    <!-- mod FNSI-投薬支援242の対応 徐 start -->
    <!-- <div slot="body" class="modal-container-custom width-style" id="avgInvest"> -->
    <div slot="body" class="modal-container-custom width-style" :class="fontSizeSet" id="avgInvest">
    <!-- mod FNSI-投薬支援242の対応 徐 end -->
      <div style="display: flex;">
        薬剤平均投与量：
        <div class="ind-sp-flex-nowrap-center" style="margin-right: 0.5em;">
          <v-ons-radio
            modifier="round"
            name="avgInvestTime"
            value="1"
            input-id="invest-three-month"
            v-model="avgInvestTime"
            @change="changeAvgInvestTime(1)"
          />
          <label for="invest-three-month">12週</label>
        </div>
        <div class="ind-sp-flex-nowrap-center" style="margin-right: 0.5em;">
          <v-ons-radio
            modifier="round"
            name="avgInvestTime"
            value="2"
            input-id="invest-six-month"
            v-model="avgInvestTime"
            @change="changeAvgInvestTime(2)"
          />
          <label for="invest-six-month">6ヶ月</label>
        </div>
        <div class="ind-sp-flex-nowrap-center" style="margin-right: 0.5em;">
          <v-ons-radio
            modifier="round"
            name="avgInvestTime"
            value="3"
            input-id="invest-one-year"
            v-model="avgInvestTime"
            @change="changeAvgInvestTime(3)"
          />
          <label for="invest-one-year">1年</label>
        </div>
        <div class="ind-sp-flex-nowrap-center">
          <v-ons-radio
            modifier="round"
            name="avgInvestTime"
            value="4"
            input-id="invest-three-year"
            v-model="avgInvestTime"
            @change="changeAvgInvestTime(4)"
          />
          <label for="invest-three-year">3年</label>
        </div>
      </div>
      <div>({{nowYearBeginMed}}～{{nowYearEnd}})</div>
      <table class="tabledate" width="100%">
        <thead width="100%">
          <tr width="100%">
            <td class="tddata-title ind-sp-tb-gradation" width="15%"></td>
            <td class="tddata-title ind-sp-tb-gradation" width="17%">週平均値</td>
            <td class="tddata-title ind-sp-tb-gradation" width="17%">平均{{cyclingName}}</td>
            <td class="tddata-title ind-sp-tb-gradation" width="17%">年間投与数</td>
            <td class="tddata-title ind-sp-tb-gradation" width="17%">投与指示数</td>
            <td width="17%"></td>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(avgInvest,index) in avgInvestBodylength" :key="index">
            <td class="tddata-title" width="15%">
              <div>{{getAvgInvestBodyList(index, 0)}}</div>
              <div style="margin-left: 2em;">{{getAvgInvestBodyList(index, 1)}}</div>
            </td>
            <td class="tddata" :class="getBackground(index)" width="17%">{{getAvgInvestBodyList(index, 2)}}</td>
            <td class="tddata" :class="getBackground(index)" width="17%">{{getAvgInvestBodyList(index, 3)}}</td>
            <td class="tddata" :class="getBackground(index)" width="17%">{{getAvgInvestBodyList(index, 4)}}</td>
            <td class="tddata" :class="getBackground(index)" width="17%">{{getAvgInvestBodyList(index, 5)}}</td>
            <td width="17%" style="visibility: hidden;"></td>
          </tr>
        </tbody>
      </table>
    </div>
    <div slot="body" style="margin-top: 0.5em;" :class="fontSizeSet"><hr class="width-style"/></div>
    <!-- 投薬支援 -->
    <!-- mod FNSI-投薬支援242の対応 徐 start -->
    <!-- <div slot="body" class="modal-container-custom width-style" id="investmentSupport" width="100%"> -->
    <div slot="body" class="modal-container-custom width-style" :class="fontSizeSet" id="investmentSupport" width="100%">
    <!-- mod FNSI-投薬支援242の対応 徐 end -->
      <div>投薬支援：</div>
      <table class="tabledate" width="100%">
        <thead width="100%">
          <tr width="100%">
            <td class="tddata-title ind-sp-tb-gradation" width="15%"> </td>
            <td class="tddata-title ind-sp-tb-gradation" width="17%"> </td>
            <td class="tddata-title ind-sp-tb-gradation" width="17%"> </td>
            <td class="tddata-title ind-sp-tb-gradation" width="17%">単位</td>
            <td width="34%"></td>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(cyclingItem,index) in cyclingList" :key="index">
            <td class="tddata-title">{{cyclingItem[0]}}<div v-if="index >= 4 && index <= 6">{{cyclingItem[4]}}</div></td>
            <td class="tddata" :class="getBackground(index)">{{cyclingItem[1]}}</td>
            <td class="tddata" :class="getBackground(index)">{{cyclingItem[2]}}</td>
            <td class="tddata" :class="getBackground(index)">{{cyclingItem[3]}}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <!-- mod FNSI-投薬支援242の対応 徐 start -->
    <!-- <div slot="footer" class="modal-footer-custom width-style"> -->
    <div slot="footer" :class="fontSizeSet" class="modal-footer-custom width-style">
    <!-- mod FNSI-投薬支援242の対応 徐 end -->
      <v-ons-row>
        <v-ons-col>
          <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
          <!-- <v-ons-button class="common-style-cancel-button" style="float:left;" @click="hideModal">
            閉じる
          </v-ons-button> -->
          <v-ons-button class="btn2-cancel width-padding" style="float:left;" @click="hideModal">
            閉じる
          </v-ons-button>
          <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
        </v-ons-col>
        <v-ons-col>
          <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
          <!-- <v-ons-button class="common-style-ok-button" style="float:right;" @click="save">
            保存
          </v-ons-button> -->
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-button class="btn1-execute width-padding" style="float:right;" @click="save"> -->
          <v-ons-button
            class="btn1-execute width-padding"
            style="float:right;"
            :disabled="!getItemAuthorized('Indication', 'default_authority')"
            @click="save">
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
            保存
          </v-ons-button>
          <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
        </v-ons-col>
      </v-ons-row>
    </div>
  </modal-base>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { mapGetters, mapActions} from "vuex";
// mod FNSI-投薬支援242の対応 徐 start
// import ModalBase from "@/components/modals/ModalBase";
import ModalBase from "@/components/modals/WindowBase";
// mod FNSI-投薬支援242の対応 徐 end
import CustomCalendar from "@/components/common/custom-calendar/CustomCalendar";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import commonSearchArea from "@/components/common/CommonSearchArea";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import PopoverMixin from "@/components/PopoverMixin";
import { sendRequestGetMstSupportSettingData as getMstSupportSettingData } from "@/apis/mst-support-setting-maintenance";
import { sendRequestGetMasterData as getMasterData } from "@/apis/mst-support-setting-maintenance";
import { sendRequestGetCheckAvgData as getCheckAvgData } from "@/apis/mst-support-setting-maintenance";
import { sendRequestGetRange as getRange } from "@/apis/mst-support-setting-maintenance";
import { sendRequestGetAvgInvestData as getAvgInvestData } from "@/apis/mst-support-setting-maintenance";
import { sendRequestGetInvestmentSupport as getInvestmentSupport } from "@/apis/mst-support-setting-maintenance";
import { sendRequestSaveRecord as saveRecord } from "@/apis/mst-support-setting-maintenance";
import moment from "moment";
//FNSI-修正 #5660子ページのデータが保存すると、親ページが更新する lijiaxing add start
import { EventBus } from "@/eventBus.js";
//FNSI-修正 #5660子ページのデータが保存すると、親ページが更新する lijiaxing add end
//ADD 5527 投薬支援画面の表示不正 張 start
import { ApiHelper } from "@/apis/AxiosHelper";
//ADD 5527 投薬支援画面の表示不正 張 end
export default {
  components: {
    "custom-calendar": CustomCalendar,
    "message-dialog": messageDialog,
    ModalBase,
    "common-searcharea": commonSearchArea
  },

  mixins: [MultiModalMixin, PopoverMixin],

  data() {
    return {
      support: 0,
      supportList: [],
      avgItemList: [],
      cyclingName:"",
      baseDate:"",
      lastYearBegin: "",
      lastYearEnd: "",
      nowYearBegin: "",
      nowYearEnd: "",
      nowYearBeginMed: "",
      lastRest: "",
      nowRest: "",
      lastMax: "",
      nowMax: "",
      lastMin: "",
      nowMin: "",
      lastDeviation: "",
      nowDeviation: "",
      lastFrequency: "",
      nowFrequency: "",
      avgInvestHeadList: [],
      avgInvestBodyList: [],
      cyclingList: [],
      windowRange: 10,
      avgInvestTime: "1",
      checkAvgTime: "1",
      nowYMDBegin: "",
      nowYMDEnd: "",
      lastYMDBegin: "",
      lastYMDEnd: "",
      avgInvestBodylength: 0
    };
  },

  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("pat-info", { patId: "selectedPatId" }),
    ...mapGetters("pat-viewer",["getCondition","getSelectedCondition"]),
    // mod FNSI-投薬支援242の対応 徐 start
    settingMedicineSupport() {
      var medicineSupportList = "";
      if (document.cookie.length > 0) {
        var arr = document.cookie.trim().split(';');
        for (var i = 0; i < arr.length; i++) {
          var arr2 = arr[i].trim().split(':');
          if (arr2[0] == 'medicineSupportList') {
            medicineSupportList = arr2[1];
          }
        }
      }
      var listTrim = medicineSupportList.trim().split(',');
      if (listTrim.length == 8) {
        return {
          left: Number(listTrim[0]),
          top: Number(listTrim[1]),
          width: Number(listTrim[2]),
          height: Number(listTrim[3]),
          zoom: [Number(listTrim[4]), Number(listTrim[5]), Number(listTrim[6]), Number(listTrim[7])]
        };
      } else {
        //mod FutreNetWeb+SI課題管理No3757対応 于 start
        return {
          left: 0,
          top: 89,
          width: 300,
          height: 806,
          zoom: [1, 1, 1, 1]
        };
        //mod FutreNetWeb+SI課題管理No3757対応 于 end
      }
    },
    // mod FNSI-投薬支援242の対応 徐 end
  },
  // add FNSI-投薬支援242の対応 徐 start
  destroyed() {
    var medicineSupportList = this.settingMedicineSupport.left;
    medicineSupportList = medicineSupportList + "," + this.settingMedicineSupport.top;
    medicineSupportList = medicineSupportList + "," + this.settingMedicineSupport.width;
    medicineSupportList = medicineSupportList + "," + this.settingMedicineSupport.height;
    medicineSupportList = medicineSupportList + "," + this.settingMedicineSupport.zoom[0];
    medicineSupportList = medicineSupportList + "," + this.settingMedicineSupport.zoom[1];
    medicineSupportList = medicineSupportList + "," + this.settingMedicineSupport.zoom[2];
    medicineSupportList = medicineSupportList + "," + this.settingMedicineSupport.zoom[3];
    window.document.cookie = "medicineSupportList:" + medicineSupportList;
    EventBus.$off("refreshdata");
  },
  // add FNSI-投薬支援242の対応 徐 end
  methods: {
    ...mapActions("multi-sub-modal", ["showPatExcludedPeriod"]),
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    async setCycling(cd) {
      // 「検査項目(cycling・予測値)」の項目名
      this.cyclingName = this.supportList[cd].cyclingText;
      const cycLingParameter = [this.facilityCd, this.patId, this.nowYMDBegin, this.nowYMDEnd, this.lastYMDBegin, this.lastYMDEnd, this.supportList[cd].cd];
      var getResultValueList = await getMasterData(cycLingParameter);
      if (getResultValueList.data != null) {
        if (getResultValueList.data[0] != null) {
          this.nowMax = getResultValueList.data[0].maxValue;
          this.nowMin = getResultValueList.data[0].minValue;
          this.nowDeviation = getResultValueList.data[0].deviationValue;
          this.nowFrequency = getResultValueList.data[0].nowFrequency;
        } else {
          this.nowMax = "";
          this.nowMin = "";
          this.nowDeviation = "";
          this.nowFrequency = "";
        }
        if (getResultValueList.data[1] != null) {
          this.lastMax = getResultValueList.data[1].maxValue;
          this.lastMin = getResultValueList.data[1].minValue;
          this.lastDeviation = getResultValueList.data[1].deviationValue;
          this.lastFrequency = getResultValueList.data[1].lastFrequency;
        } else {
          this.lastMax = "";
          this.lastMin = "";
          this.lastDeviation = "";
          this.lastFrequency = "";
        }
      }

      // 減算
      if (this.lastMax != "") {
        //mod FNSI-6551 劉全航 start
        // this.lastRest = Number(this.lastMax) - Number(this.lastMin);
        this.lastRest = (Number(this.lastMax) - Number(this.lastMin)).toFixed(2);
         //mod FNSI-6551 劉全航 end
      } else {
        this.lastRest = "";
      }
      if (this.nowMax != "") {
        //mod FNSI-6551 劉全航 start
        // this.nowRest = Number(this.nowMax) - Number(this.nowMin);
        this.nowRest = (Number(this.nowMax) - Number(this.nowMin)).toFixed(2);
        //mod FNSI-6551 劉全航 end
      } else {
        this.nowRest = "";
      }
    },
    async setCheckAvg(flg, indexCd) {
      this.avgItemList = [];

      var startDate = this.getStartData(flg);
      const checkAvgParameter = [];
      checkAvgParameter.push(this.facilityCd);
      checkAvgParameter.push(this.patId);
      checkAvgParameter.push(startDate);
      //FNSI-修正 #6557 終了日を修正（基準日は終了日ではない）add start
      // checkAvgParameter.push(this.baseDate);
      let endDate = this.getEndData();
      checkAvgParameter.push(endDate);
      //FNSI-修正 #6557 終了日を修正（基準日は終了日ではない）add end
      checkAvgParameter.push(indexCd);
      var getCheckAvgDataList = await getCheckAvgData(checkAvgParameter);
      if (getCheckAvgDataList != null) {
        var checkAvgList = getCheckAvgDataList.data;
        for (var i = 0; i < checkAvgList.length; i++) {
          var checkAvgItem = checkAvgList[i];
          var regDate = checkAvgItem.regExamDate;
          if (regDate != null && regDate != "") {
            regDate = regDate.substring(0,11);
            regDate = regDate.replace(new RegExp("-",("gm")),"/");
          } else {
            regDate = "";
          }
          const avgItem = [
            checkAvgItem.itemName,
            checkAvgItem.avgResultValue,
            checkAvgItem.maxResultValue,
            checkAvgItem.minResultValue,
            checkAvgItem.resultValue,
            regDate
          ];
          this.avgItemList.push(avgItem);
          console.log("checkAvgItem is :",JSON.stringify(avgItem))
        }
      }
      // del 7745 投与支援の検査項目で空白行が表示される 周安寧 start
      // for (var i0 = this.avgItemList.length; i0 < 5; i0++) {
      //   const avgItem = ["", "", "", "", "", ""];
      //   this.avgItemList.push(avgItem);
      // }
      // del 7745 投与支援の検査項目で空白行が表示される 周安寧 end
    },
    async setAvgInvest(flg, indexCd, cyclingCd) {

      var startDate = this.getStartData(flg);
      var endDate = this.getEndData();
      var lastSunday = this.getLastSunday();
       //FNSI-修正 #6557 薬剤平均値の期間を変更すると、開始月が変更する ljx add start
      this.nowYearBeginMed = startDate.substr(0,4)+"/"+startDate.substr(4,2);
       //FNSI-修正 #6557 薬剤平均値の期間を変更すると、開始月が変更する ljx add end
      const avgInvestParameter = [];
      avgInvestParameter.push(this.facilityCd);
      avgInvestParameter.push(this.patId);
      avgInvestParameter.push(indexCd);
      avgInvestParameter.push(startDate);
      //FNSI-修正 #6557 終了日を修正（基準日は終了日ではない）add start
      //avgInvestParameter.push(this.baseDate);
      avgInvestParameter.push(endDate);
      //FNSI-修正 #6557 終了日を修正（基準日は終了日ではない）add end
      // avgInvestParameter.push("平均" + this.cyclingName); modify by maxueqiang bug:5307
      avgInvestParameter.push(cyclingCd);
      avgInvestParameter.push(this.baseDate);
      avgInvestParameter.push(lastSunday);
      var getAvgInvestDataList = await getAvgInvestData(avgInvestParameter);

      this.avgInvestBodyList = [];

      if (getAvgInvestDataList != null) {
        this.avgInvestBodyList = getAvgInvestDataList.data;
      }
      this.avgInvestBodylength = this.avgInvestBodyList.length;
    },
    async setInvestmentSupport(cd) {
      this.cyclingList = [];
      const investmentSupportParameter = [];
      investmentSupportParameter.push(this.supportList[cd].cyclingCd);
      investmentSupportParameter.push(this.supportList[cd].esaCd);
      investmentSupportParameter.push(this.supportList[cd].esaType);
      investmentSupportParameter.push(this.getEndData());
      investmentSupportParameter.push(this.facilityCd);
      investmentSupportParameter.push(this.patId);
      investmentSupportParameter.push(this.getStartData(3));
      // add #7746 投与支援で薬剤に薬効換算マスタの薬剤グループを設定すると算出できない 鄭爽 start
      investmentSupportParameter.push(this.baseDate);
      // add #7746 投与支援で薬剤に薬効換算マスタの薬剤グループを設定すると算出できない 鄭爽 end
      var response = await getInvestmentSupport(investmentSupportParameter);
      var itemUnit = "";
      var esaUnit = "";
      var weekAvg = 0;
      var weekCycling = 1.0;
      if (response.data != null) {
        itemUnit = response.data.itemUnit;
        esaUnit = response.data.esaUnit;
        weekAvg = parseFloat(response.data.weekAvg);
        weekCycling = response.data.weekCycling;
        if (weekCycling == null || weekCycling == "") {
          weekCycling = 1.0;
        }
      }
      weekCycling = (weekAvg / weekCycling).toFixed(2);

      // 予測値
      const item = [];
      item.push("予測値");
      item.push(this.supportList[cd].cyclingText);
      item.push((weekAvg * weekCycling).toFixed(2));
      item.push(itemUnit);
      item.push("");
      this.cyclingList.push(item);
      // 現在投与量（週）
      const item2 = [];
      item2.push("現在投与量（週）");
      item2.push(this.supportList[cd].esaText);
      item2.push(weekAvg.toFixed(2));
      item2.push(esaUnit);
      item2.push("");
      this.cyclingList.push(item2);
      // 目標値
      const item3 = [];
      item3.push("目標値");
      //mod FNSI-6458 劉全航 start
      // item3.push(this.supportList[cd].text);
      item3.push(this.supportList[cd].cyclingText);
      //mod FNSI-6458 劉全航 end
      item3.push(this.supportList[cd].target.toFixed(2));
      item3.push(itemUnit);
      item3.push("");
      this.cyclingList.push(item3);
      // 目標投与量（週）
      const item4 = [];
      item4.push("目標投与量（週）");
      item4.push(this.supportList[cd].esaText);
      item4.push((this.supportList[cd].target * weekCycling).toFixed(2));
      item4.push(esaUnit);
      item4.push("");
      this.cyclingList.push(item4);
      // 投与方法案 1回/週
      const item5 = [];
      item5.push("投与方法案");
      item5.push(this.supportList[cd].esaText);
      item5.push((this.supportList[cd].target * weekCycling).toFixed(2));
      item5.push(esaUnit);
      item5.push("1回/週");
      this.cyclingList.push(item5);
      // 投与方法案 1回/2週
      const item6 = [];
      item6.push("投与方法案");
      item6.push(this.supportList[cd].esaText);
      item6.push((this.supportList[cd].target * weekCycling * 2).toFixed(2));
      item6.push(esaUnit);
      item6.push("1回/2週");
      this.cyclingList.push(item6);
      // 投与方法案 1回/4週
      const item7 = [];
      item7.push("投与方法案");
      item7.push(this.supportList[cd].esaText);
      item7.push((this.supportList[cd].target * weekCycling * 4).toFixed(2));
      item7.push(esaUnit);
      item7.push("1回/4週");
      this.cyclingList.push(item7);
      // 「１」＋ 投薬支援マスタ：「検査項目(cycling・予測値)」の項目名 ＋ 「あたりの投与量」
      const item8 = [];
      item8.push("１" + this.cyclingName + "あたりの投与量");
      item8.push(this.supportList[cd].esaText);
      item8.push(parseFloat(weekCycling).toFixed(2));
      item8.push(esaUnit);
      item8.push("");
      this.cyclingList.push(item8);

    },
    getAvgInvestBodyList(index, num) {
      if (this.avgInvestBodyList.length > index) {
        return this.avgInvestBodyList[index][num];
      } else {
        return "";
      }
    },
    async changeSelected() {
      var cd = document.getElementById('support').selectedIndex;

      var rangeMap = await getRange(this.supportList[cd].cd);
      if (rangeMap.data.initialrangemedicine != "" && rangeMap.data.initialrangemedicine != null) {
        this.avgInvestTime = rangeMap.data.initialrangemedicine;
      } else {
        this.avgInvestTime = "1";
      }
      if (rangeMap.data.initialrangeexam != "" && rangeMap.data.initialrangeexam != null) {
        this.checkAvgTime = rangeMap.data.initialrangeexam;
      } else {
        this.checkAvgTime = "1";
      }

      this.setCycling(cd);
      this.setCheckAvg(this.checkAvgTime, this.supportList[cd].cd);
      this.setAvgInvest(this.avgInvestTime, this.supportList[cd].cd, this.supportList[cd].cyclingCd);
      this.setInvestmentSupport(cd);
    },
    getSupport() {
      return this.supportList;
    },
    getBackground(index) {
      if (index % 2 == 0) {
        return ["tddata-1"];
      } else {
        return ["tddata-2"];
      }
    },
    changeCheckAvgTime(flg) {
      var cd = document.getElementById('support').selectedIndex;
      this.setCheckAvg(flg, this.supportList[cd].cd);
    },
    changeAvgInvestTime(flg) {
      var cd = document.getElementById('support').selectedIndex;
      this.setAvgInvest(flg, this.supportList[cd].cd, this.supportList[cd].cyclingCd);
    },
    async save() {
      var cd = document.getElementById('support').selectedIndex;

      const saveParameter = [];
      // 施設コード
      saveParameter.push(this.facilityCd);
      // 患者ID
      saveParameter.push(this.patId);
      // 基準日
      saveParameter.push(this.baseDate);
      // 対象の薬剤コード（ESA投与支援）
      saveParameter.push(this.supportList[cd].esaCd);
      // 対象の検査項目コード(cycling・予測値)
      saveParameter.push(this.supportList[cd].cyclingCd);
      // 目標投与量（週）
      saveParameter.push(this.cyclingList[3][2]);
      // 予測値
      saveParameter.push(this.cyclingList[0][2]);

      await saveRecord(saveParameter);
      this.hideModal();
    },
    changeWindow() {
      setTimeout(() => {
        var range = this.windowRange / 10.0;
        document.getElementById("modalBase").style.opacity = range;
      }, 50);
    },
    getStartData(flg) {
      var startDay = "";
      var baseDay = moment(this.baseDate).format("YYYY-MM-DD");
      // 表示期間を計算、設定
      flg = Number(flg);
      //FNSI-修正 #6557 終了日を修正（基準日は終了日ではない） mod start
      switch (flg) {
        case 1:
          // 12週
          // 月曜からスタート
          startDay = moment(baseDay)
            //.add(-12, "weeks")
            .add(-94, "days")
            .startOf("isoWeek")
            .add(7, "days")
            .format("YYYYMMDD");
          break;

        case 2:
          // 6ヶ月
          startDay = moment(baseDay)
            //.add(-6, "months")
            .add(-185, "days")
            .startOf("isoWeek")
            .add(7, "days")
            .format("YYYYMMDD");
          break;

        case 3:
          // 1年
          startDay = moment(baseDay)
            //.add(-1, "years")
             .add(-366, "days")
            .startOf("isoWeek")
            .add(7, "days")
            .format("YYYYMMDD");
          break;

        case 4:
          // 3年
          startDay = moment(baseDay)
            //.add(-3, "years")
            .add(-1096, "days")
            .startOf("isoWeek")
            .add(7, "days")
            .format("YYYYMMDD");
          break;
      }
      //FNSI-修正 #6557 終了日を修正（基準日は終了日ではない） mod end
      return startDay;
    },
    getEndData() {
          var endDay = "";
          var baseDay = moment(this.baseDate).format("YYYY-MM-DD");
          endDay = moment(baseDay)
            .startOf("isoWeek")
            .add(6, "days")
            .format("YYYYMMDD");
          return endDay;
        },
    getLastSunday() {
      var lastSunday = "";
      var baseDay = moment(this.baseDate).format("YYYY-MM-DD");
      lastSunday = moment(baseDay)
        .startOf("isoWeek")
        .add(-1, "days")
        .format("YYYYMMDD");
      return lastSunday;
    },
  //FNSI-修正 #5660子ページのデータが保存すると、親ページが更新する lijiaxing add start
  // mod  5527 除外期間が適用されていない。張 start
  // refreshdata() {
  async refreshdata() {
  // mod  5527 除外期間が適用されていない。張 end
    this.setCycling(0);
    // add  5527 除外期間が適用されていない。張 start
     await this.setCheckAvg(this.checkAvgTime, this.supportList[0].cd);
     await this.setAvgInvest(this.avgInvestTime, this.supportList[0].cd, this.supportList[0].cyclingCd);
      this.setInvestmentSupport(0);
    // add  5527 除外期間が適用されていない。張 end
    }
  //FNSI-修正 #5660子ページのデータが保存すると、親ページが更新する lijiaxing add end
  //mod FNSI-6884 劉全航 start
    ,async changeDate(){
      var cd = document.getElementById('support').selectedIndex;
      var baseDay = new Date(this.getSelectedCondition.baseDay);
      var year = baseDay.getFullYear();
      var month = baseDay.getMonth() + 1;
      var day = baseDay.getDate();
      var lastYear = year - 1;
      var beforeLastYear = year - 2;
      var nextMonth = month + 1;
      if (month == 12) {
        lastYear = year;
        beforeLastYear = year - 1;
        nextMonth = 1;
      }
      if (month < 10) {
        month = "0" + month;
      }
      if (nextMonth < 10) {
        nextMonth = "0" + nextMonth;
      }
      // 本年分
      this.nowYearBegin = lastYear.toString() + "/" + nextMonth;
      this.nowYearEnd = year.toString() + "/" + month;
      // 昨年分
      this.lastYearBegin = beforeLastYear.toString() + "/" + nextMonth;
      this.lastYearEnd = (year - 1).toString() + "/" + month;

      // 開始日
      this.nowYMDBegin = lastYear.toString();
      this.lastYMDBegin = beforeLastYear.toString();
      this.nowYMDBegin = this.nowYMDBegin + nextMonth + "01";
      this.lastYMDBegin = this.lastYMDBegin + nextMonth + "01";

      // 終了日
      this.nowYMDEnd = year.toString();
      this.lastYMDEnd = (year - 1).toString();
      var curMonthDays = new Date(year,month,0).getDate();
      this.nowYMDEnd = this.nowYMDEnd + month + curMonthDays;
      this.lastYMDEnd = this.lastYMDEnd + month + curMonthDays;
      this.baseDate = year.toString() + month;

      if (day < 10) {
        this.baseDate = this.baseDate + "0" + day;
      } else {
        this.baseDate = this.baseDate + day;
      }
      var getCycLingRerurnList = await getMstSupportSettingData(this.facilityCd);
      //mod FNSI-5527 劉全航 start
      getCycLingRerurnList.data = getCycLingRerurnList.data.filter(function(o){
        return o.isDisp === "1";
        });
      //mod FNSI-5527 劉全航 end
      var rangeMap = await getRange(this.supportList[cd].cd);
      if (rangeMap.data.initialrangemedicine != "" && rangeMap.data.initialrangemedicine != null) {
        this.avgInvestTime = rangeMap.data.initialrangemedicine;
      } else {
        this.avgInvestTime = "1";
      }
      if (rangeMap.data.initialrangeexam != "" && rangeMap.data.initialrangeexam != null) {
        this.checkAvgTime = rangeMap.data.initialrangeexam;
      } else {
        this.checkAvgTime = "1";
      }
      this.setCycling(cd);
      this.setCheckAvg(this.checkAvgTime, this.supportList[cd].cd);
      this.setAvgInvest(this.avgInvestTime, this.supportList[cd].cd, this.supportList[cd].cyclingCd);
    }
    //mod FNSI-6884 劉全航 end
  },

  watch:{
    //mod FNSI-6884 劉全航 start
    getSelectedCondition : {
      handler: 'changeDate',
      deep : true
    }
    //mod FNSI-6884 劉全航 end
  },
//mod 5527 投薬支援画面の表示不正 張 start
// async created(){
  created() {
//mod 5527 投薬支援画面の表示不正 張 end
    //FNSI-修正 #5660子ページのデータが保存すると、親ページが更新する lijiaxing add start
    EventBus.$on("refreshdata", this.refreshdata);
    //FNSI-修正 #5660子ページのデータが保存すると、親ページが更新する lijiaxing add end
    // 基準日
    var baseDay = new Date(window.parent.baseDay.value);
    var year = baseDay.getFullYear();
    var month = baseDay.getMonth() + 1;
    var day = baseDay.getDate();
    var lastYear = year - 1;
    var beforeLastYear = year - 2;
    var nextMonth = month + 1;
    if (month == 12) {
      lastYear = year;
      beforeLastYear = year - 1;
      nextMonth = 1;
    }
    if (month < 10) {
      month = "0" + month;
    }
    if (nextMonth < 10) {
      nextMonth = "0" + nextMonth;
    }
    // 本年分
    this.nowYearBegin = lastYear.toString() + "/" + nextMonth;
    this.nowYearEnd = year.toString() + "/" + month;
    // 昨年分
    this.lastYearBegin = beforeLastYear.toString() + "/" + nextMonth;
    this.lastYearEnd = (year - 1).toString() + "/" + month;

    // 開始日
    this.nowYMDBegin = lastYear.toString();
    this.lastYMDBegin = beforeLastYear.toString();
    this.nowYMDBegin = this.nowYMDBegin + nextMonth + "01";
    this.lastYMDBegin = this.lastYMDBegin + nextMonth + "01";

    // 終了日
    this.nowYMDEnd = year.toString();
    this.lastYMDEnd = (year - 1).toString();
    var curMonthDays = new Date(year,month,0).getDate();
    this.nowYMDEnd = this.nowYMDEnd + month + curMonthDays;
    this.lastYMDEnd = this.lastYMDEnd + month + curMonthDays;
    this.baseDate = year.toString() + month;

    if (day < 10) {
      this.baseDate = this.baseDate + "0" + day;
    } else {
      this.baseDate = this.baseDate + day;
    }
    //mod 5527 投薬支援画面の表示不正 張 start
    // var getCycLingRerurnList = await getMstSupportSettingData(this.facilityCd);
     ApiHelper.get(`/master_maintenance/mst_support_setting/${this.facilityCd}`).then(response => {
        var getCycLingRerurnList =response
    //mod 5527 投薬支援画面の表示不正 張 end
    //mod FNSI-5527 劉全航 start
    getCycLingRerurnList.data = getCycLingRerurnList.data.filter(function(o){
      return o.isDisp === "1";
      });
    //mod FNSI-5527 劉全航 end
    if (getCycLingRerurnList != null) {
      for (var i = 0; i < getCycLingRerurnList.data.length; i++) {
        var cyclingText = "";
        var cyclingCd =  "";
        var esaText = "";
        var esaCd = "";
        var esaType =  "";

        if (JSON.parse(getCycLingRerurnList.data[i].detailInfo) != null) {
          if (JSON.parse(getCycLingRerurnList.data[i].detailInfo).examItemCycling != null && JSON.parse(getCycLingRerurnList.data[i].detailInfo).examItemCycling.length > 0) {
            cyclingText = JSON.parse(getCycLingRerurnList.data[i].detailInfo).examItemCycling[0].text;
            cyclingCd = JSON.parse(getCycLingRerurnList.data[i].detailInfo).examItemCycling[0].value;
          }
          if (JSON.parse(getCycLingRerurnList.data[i].detailInfo).medicineESA != null && JSON.parse(getCycLingRerurnList.data[i].detailInfo).medicineESA.length > 0) {
            esaText = JSON.parse(getCycLingRerurnList.data[i].detailInfo).medicineESA[0].text;
            esaCd = JSON.parse(getCycLingRerurnList.data[i].detailInfo).medicineESA[0].value;
            esaType = JSON.parse(getCycLingRerurnList.data[i].detailInfo).medicineESA[0].type;
          }
        }

        const item = {
          cd: getCycLingRerurnList.data[i].medicineSupportCd,
          text: getCycLingRerurnList.data[i].medicineSupportName,
          cyclingText: cyclingText,
          cyclingCd: cyclingCd,
          esaText: esaText,
          esaCd: esaCd,
          esaType: esaType,
          target: getCycLingRerurnList.data[i].targetInspection
        };
        this.supportList.push(item);
        if (i == 0) {
          this.support = getCycLingRerurnList.data[i].medicineSupportCd;
        }
      }
    }
    //mod 5527 投薬支援画面の表示不正 張 start
    // var rangeMap = await getRange(this.supportList[0].cd);
     ApiHelper.get(`/master_maintenance/mst_support_range_value/${this.supportList[0].cd}`).then(response => {
        var rangeMap =response
    //mod 5527 投薬支援画面の表示不正 張 end
    if (rangeMap.data.initialrangemedicine != "" && rangeMap.data.initialrangemedicine != null) {
      this.avgInvestTime = rangeMap.data.initialrangemedicine;
    } else {
      this.avgInvestTime = "1";
    }
    if (rangeMap.data.initialrangeexam != "" && rangeMap.data.initialrangeexam != null) {
      this.checkAvgTime = rangeMap.data.initialrangeexam;
    } else {
      this.checkAvgTime = "1";
    }

    this.setCycling(0);
    this.setCheckAvg(this.checkAvgTime, this.supportList[0].cd);
    this.setAvgInvest(this.avgInvestTime, this.supportList[0].cd, this.supportList[0].cyclingCd);
    this.setInvestmentSupport(0);
    });
    });

  },
};
</script>

<style scoped>
div >>> .erd_scroll_detection_container {
  display: none !important;
}

.modal-container-custom >>> .k-grid {
  width: 100%;
  font-size: 1em;
}
.modal-container-custom >>> .k-grid-content {
  height: 50vh;
  background-color: var(--grid-background-color);
}

.modal-container-custom {
  height: auto;
  color: var(--ntss-base-color);
}

.modal-footer-custom {
  padding: 10px 0px;
  text-align: center;
}

.tabledate{
  /* mod FNSI-投薬支援242の対応 徐 start */
  /* border: 2px solid rgb(255, 255, 255); */
  border: 2px solid rgba(255, 255, 255, 0);
  /* mod FNSI-投薬支援242の対応 徐 end */
  width: 100%;
  border-collapse:collapse;
  z-index: 1;
  white-space: unset;
  top: -1px;
}
.tabledate tr:nth-child(2n) {
  background-color: var(--ntss-list-content-2nd-background-color);
}

.tddata{
  /* mod FutreNetWeb+SI課題管理 NO.5060 劉全航 start */
  /* border: 2px solid rgb(255, 255, 255); */
  height: 2em;
  color: var(--ntss-list-body-color);
  /* mod FutreNetWeb+SI課題管理 NO.5060 劉全航 start */
}
.tddata-1{
  /* mod FutreNetWeb+SI課題管理 NO.5060 劉全航 start */
  /* background-color: #d3d6f1; */
  height: 2em;
  border: solid 1px var(--ntss-list-border-color);
  /* mod FutreNetWeb+SI課題管理 NO.5060 劉全航 end */
}
.tddata-2{
  /* mod FutreNetWeb+SI課題管理 NO.5060 劉全航 start */
  /* background-color: #bbc1f5; */
  height: 2em;
  border: solid 1px var(--ntss-list-border-color);
  /* mod FutreNetWeb+SI課題管理 NO.5060 劉全航 end */
}
.tddata-title{
  /* mod FutreNetWeb+SI課題管理 NO.2 劉全航 start */
  height: 2em;
  /* border: 2px solid rgb(255, 255, 255); */
  border: solid 1px var(--ntss-list-border-color);
  /* background-color: #515bb3; */
  background-color: var(--ntss-header-background-color);
  color: var(--ntss-header-color);
  /* mod FutreNetWeb+SI課題管理 NO.2 劉全航 end */
  padding: 0px 4px;
}
.width-style {
  min-width: 31em;
}
/* add FNSI-患者経過総合ビューア 画面デザイン 李 start */
.width-padding {
  width: 80px;
  padding-top: 8px;
}
/* add FNSI-患者経過総合ビューア 画面デザイン 李 end */
.ind-sp-tb-gradation {
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
}
.ind-sp-flex-nowrap-center {
  display: flex;
  flex-wrap: nowrap;
  align-items: center;
}
.btn2-cancel {
   width: 100px !important;
}

@media print {
  #modalBase {
    display: block;
  }
  #modalBase >>> .k-window {
    display: inline-block;
  }
  /** スクロールコンテナ */
  #modalBase >>> .k-window-content {
    overflow: hidden !important;
  }
}
</style>
