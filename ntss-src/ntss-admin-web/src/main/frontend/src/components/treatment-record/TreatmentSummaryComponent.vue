/** * 治療記録の治療概要ページ */
<template>
  <div class="treatment-summary">
    <!-- 治療記録子機能ボタンエリア開閉ボタン -->
    <ons-icon
      class="ons-icon ion-navicon ons-icon--ion treatment-summary-openclose-icon"
      :class="{ 'icon-opacity': isOpen }"
      icon="ion-ios-menu"
      @click="change"
    ></ons-icon>
    <v-touch tag="span" class="v-touch" @swipeleft="next" @swiperight="prev">
      <v-ons-icon
        icon="fa-chevron-left"
        :class="['prev', { disabled: !prevOrd }]"
        @click="prev"
      />
      <custom-span-calendar
        v-model="model.date_handle"
        :disabled-not-exist-dates="disabledNotExistDates"
        :selected-dates="disabledNotExistDates"
        :date-show-input="model.treatment_date"
        :disablefacility="disablefacility"
        :classes="getStyle(model.treatment_date)"
        @inputCalendar="reloadTreatmentRecord"
        @spanCalendarOpen="spanCalendarOpen"
        @spanCalendarClose="spanCalendarClose"
      />
      <v-ons-icon
        icon="fa-chevron-right"
        :class="['next', { disabled: !nextOrd }]"
        @click="next"
      />&emsp;
    </v-touch>
    <span
      ref="displayPos"
      @mousedown="checkOrdNoLongPress(1)"
      @mouseup="checkOrdNoLongPress(0)"
      @touchstart="checkOrdNoLongPress(1)"
      @touchend="checkOrdNoLongPress(0)"
    >
      <span>{{ model.kur_name }}&emsp;</span>
      <span>{{ model.bed_name }}&emsp;</span>
      <span>{{ model.treatment_name }}</span>
      <span>{{ facilityName }}</span>
    </span>
    <v-ons-popover
      :target="popoverTarget"
      :visible.sync="popoverVisible"
      :class="[fontSizeSet, 'popover-style', 'popover-elem']"
      direction="down"
      cancelable
    >
      <p style="text-align: center">透析番号： {{ selOrdNo }}</p>
    </v-ons-popover>
  </div>
</template>

<script>
import { EventBus } from "@/eventBus.js";
import { mapGetters, mapActions, mapMutations, mapState } from "vuex";
import { getOrdNoListWithShared } from "@/apis/ord-main";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import CustomSpanCalendar from "@/components/common/custom-span-calendar/CustomSpanCalendar.vue";
import moment from "moment";
import PopoverMixin from "@/components/PopoverMixin";
import { cloneDeep } from "lodash";
//add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
//add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 end
import { getHolidayStyle } from "@/functions/common/CommonFunctions";
export default {
  mixins: [PopoverMixin],
  components: {
    "custom-span-calendar": CustomSpanCalendar,
  },
  props: {
    isOpen: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      treatmentPatListMap: [],
      model: {
        treatment_date: null,
        bed_name: null,
        kur_name: null,
        treatment_name: null,
        date_handle: null,
      },
      blowTimer: 0,
      popoverTarget: null,
      popoverVisible: false,
      selOrdNo: "",
      ordNoDataSources: [],
      disabledNotExistDates: [],
      ordNodisabledNotExistDates: {},
      offset: 1,
      //FNSI-修正 #6656、6526、検出件数の制御をしないように xugj modify start
      limit: 5000,
      //FNSI-修正 #6656、6526、検出件数の制御をしないように xugj modify end
      calendarOpenFlg: false,
      // add FNSI-修正 共有設定 房 start
      facilityName: null,
      dataofday: [],
      facilityOfDay: [],
      disablefacility: {},
      // add FNSI-修正 共有設定 房 end
      nextOrd: null,
      prevOrd: null,
      curOrd: null
    };
  },
  watch: {
    // add start 馬 #9559
    ordNoDataSourcesState: {
      handler(val) {
        if (this.selectedPatId) {
          this.ordNoDataSources = cloneDeep(val);
          this.initOrdNoList();
          this.refresh();
        }
      },
      deep: true,
      immediate: true
    },
    "model.date_handle": {
      handler() {
        if (!this.getOrdNo) {
          return;
        }
        this.prevOrd = null;
        this.nextOrd = null;
        this.curOrd = null;
        if (this.ordNoDataSources?.length) {
          const index = this.ordNoDataSources.findIndex((item) => {
            return item.ordNo === this.getOrdNo;
          });
          this.curOrd = this.ordNoDataSources?.[index];
          this.prevOrd = index < this.ordNoDataSources.length - 1 ? this.ordNoDataSources[index + 1] : null;
          this.nextOrd = index > 0 ? this.ordNoDataSources[index - 1] : null;
        }
      },
      deep: true
    },
    getOrdNo(val) {
      if (val) {
      	// mod #12462 患者情報共有 Ji start
        // const currentOrdIndex = this.ordNoDataSources.findIndex(
        //   (data) => data.ordNo === val
        // );
        // if (currentOrdIndex > 0) {
        //   this.setSharedFacilityCd(
        //     this.ordNoDataSources[currentOrdIndex].facilityCd
        //   );
        // }
        // if (currentOrdIndex === 0) {
        //   this.updateOrdList();
        // }
        // this.refresh();
        const current = this.ordNoDataSources.find(
          (data) => data.ordNo === val
        );
        if (!current) return;
        this.setSharedFacilityCd(current.facilityCd);
        if (current.facilityCd === this.getFacilityCd) {
	// mod #12462 患者情報共有 Ji end
          this.updateOrdList();
        }
        this.refresh();
      }
    },
    selectedPatId() {
      if (this.srcFuncName) {
        const ordNoDataSources = this.treatmentPatListMap.filter((ordinfo) => {
          return ordinfo.patId === this.selectedPatId;
        });
        let ordNoDataSourcesSorted = ordNoDataSources.sort((a, b) => {
          if (a.rstDialysisState === b.rstDialysisState) {
            return b.treatDate - a.treatDate;
          }
          return a.rstDialysisState - b.rstDialysisState;
        });
        this.ordNoDataSources = ordNoDataSourcesSorted;
        this.initOrdNoList();
      }
    },
    // add end 馬 #9559
    /**
     * 治療記録概要欄の情報を監視
     */
    getTreatmentUpdate() {
      this.refresh();
    },
    //共有設定
    getSharedFlag() {
      this.initOrdNoList();
    },
    // add #12462 患者情報共有 Ji start
    async getPatientShareMode() {
      await this.awaitDataReady();
      if (!this.ordNoDataSources?.length) {
        this.refresh();
        return;
      }
      const isShared = this.getPatientShareMode == 0;
      const current = this.ordNoDataSources.find(
        item => item.ordNo === this.getOrdNo
      );
      const isCurrentValid = current && (
        isShared || current.facilityCd === this.getFacilityCd
      );
      if (isCurrentValid) {
        this.refresh();
        return;
      }
      let targetList;
      if (isShared) {
        // 他施設含む
        targetList = this.ordNoDataSources;
      } else {
        // 自施設のみ
        targetList = this.ordNoDataSources.filter(
          item => item.facilityCd === this.getFacilityCd
        );
      }
      if (!targetList.length) {
        this.setOrdNo(null);
        this.refresh();
        return;
      }
      const latest = targetList[0];
      this.setOrdNo(latest.ordNo);
      this.setSharedFacilityCd(latest.facilityCd);
      this.refresh();
    },
    async getPatientShareFacilityCdMode() {
      await this.awaitDataReady();
      if (!this.ordNoDataSources?.length) {
        this.refresh();
        return;
      }
      const selectedFacilityCd = this.getPatientShareFacilityCdMode;
      const isOtherSelected =
        selectedFacilityCd !== null &&
        selectedFacilityCd !== this.getFacilityCd;
      const current = this.ordNoDataSources.find(
        item => item.ordNo === this.getOrdNo
      );
      const isCurrentValid = current && (
        (isOtherSelected
          ? current.facilityCd === this.getFacilityCd
          : true)
      );
      if (isCurrentValid) {
        this.refresh();
        return;
      }
      let targetList;
      if (isOtherSelected) {
        targetList = this.ordNoDataSources.filter(
          item => item.facilityCd === this.getFacilityCd
        );
      } else {
        targetList = this.ordNoDataSources;
      }
      if (!targetList.length) {
        this.setOrdNo(null);
        this.refresh();
        return;
      }
      const latest = targetList[0];
      this.setOrdNo(latest.ordNo);
      this.setSharedFacilityCd(latest.facilityCd);
      this.refresh();
    },
    // add #12462 患者情報共有 Ji end
  },
  computed: {
    ...mapGetters("pat-info", [
      "selectedPatId",
      "selectedPatName",
      "srcFuncName",
      "isNullPat",
      "selectedPat",
      "treatmentPatList",
      //add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 start
      "isPatInfoChaned",
      //add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 end
      // add #12462 患者情報共有 Ji start
      "getIsOtherFacility", 
      "getOtherFacilityCd"
      // add #12462 患者情報共有 Ji end
    ]),
    ...mapGetters("treatment-record/common", [
      "getOrdNo",
      "getTreatmentUpdate",
      "getDialysisState",
      "getTreatDate",
      "getOrdNoForSideBarRecord",
      "getSharedFacilityCd",
    ]),
    ...mapGetters("user", ["getFacilityCd"]),
    // add FNSI-修正 共有設定 房 start
    ...mapGetters("mst-user", { getSharedFlag: "getIsRegisteredShared" }),
    // add FNSI-修正 共有設定 房 end
    // mod #12462 患者情報共有 Ji start
    ...mapState("treatment-record/common", ["ordNoDataSourcesState", "ordNoDataSourceForOtherPage", "ordNoDataReady"]),
    ...mapGetters("account-edit", [
      "getPatientShareMode",
      "getPatientShareFacilityCdMode"
    ]),
    // mod #12462 患者情報共有 Ji end
  },
  methods: {
    ...mapActions("treatment-record/common", [
      "getSummary",
      "setOrdNo",
      "setOrd",
      "getFacilityName",
      "setTreatDate",
      "setOrdNoForSideBarRecord"
    ]),
    ...mapActions("multi-modal", ["showIndicationResult"]),
    ...mapGetters("user", ["getUserAuthorityCds"]),
    // mod #12462 患者情報共有 Ji start
    ...mapMutations("treatment-record/common", ["setSharedFacilityCd", "setOrdNoDataSources"]),
    // mod #12462 患者情報共有 Ji end
      //add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 start
    ...mapMutations("pat-info", ["setIsPatInfoChaned"]),
      //add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 end
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
    }),
    // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 start
    ...mapActions("pat-event/detail", ["setSkipRoute"]),
    ...mapActions("observe-record/list", {setObserveRecord: "setOrdNo"}),
    ...mapActions("treatment-record/roundsInfo", [
      "setRstRoundsInfoToCompare",
      "setRstRoundsInfoInProgress",
      "setSelectedRoundType",
    ]),
    // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 end
    ...mapActions("mst-holiday", [
      "fetchHolidays",
      "clearHolidays"
    ]),
    // add #12462 患者情報共有 Ji start
    awaitDataReady() {
      return new Promise(resolve => {
        if (this.ordNoDataReady) {
          resolve();
        } else {
          const unwatch = this.$watch('ordNoDataReady', (newVal) => {
            if (newVal === true) {
              unwatch();
              resolve();
            }
          });
        }
      });
    },
    async getOrdNoList() {
      const sharedFlag = (this.getIsOtherFacility === false || (this.getOtherFacilityCd !== null && this.getOtherFacilityCd !== this.facilityCd))
        ? 0 
        : (this.getPatientShareMode == 0 ? 1 : 0);
      try {
        const response = await getOrdNoListWithShared(
          this.selectedPatId,
          this.offset,
          this.limit,
          sharedFlag
        );

        let ordNoDataSources = response.data.sort((a, b) => {
          if (a.rstDialysisState === b.rstDialysisState) {
            return b.treatDate - a.treatDate;
          }
          return a.rstDialysisState - b.rstDialysisState;
        });
        this.ordNoDataSources = ordNoDataSources;
        this.setOrdNoDataSources(ordNoDataSources);
      } catch (e) {
        console.log(e);
      }
    },
    // add #12462 患者情報共有 Ji end
    /**
     * 概要を再表示する.
     */
    refresh(flag) {

      // 休日マスタの休日を取得
      this.fetchHolidays(this.getFacilityCd);

      if (!this.getOrdNo) {
        // 指定日がある場合は日付を設定してカレンダーを表示できるようにする
        let tDate = null;
        if (this.getTreatDate) {
          const mObj = moment(this.getTreatDate);
          tDate =
            mObj.format("YYYY/MM/DD") +
            "(" +
            ["日", "月", "火", "水", "木", "金", "土"][mObj.day()] +
            ")";
        }
        const temp = {
          treatment_date: tDate,
          bed_name: null,
          kur_name: null,
          treatment_name: null,
          date_handle: null,
        }
        const dialysisStateArr = this.getDialysisState == "6" ? ["6"] : ["1", "2", "3", "4", "5"];
        const hasEqualDialsysState = this.ordNoDataSources?.some((item) => dialysisStateArr.includes(item.rstDialysisState));
        this.prevOrd = null;
        this.nextOrd = null;
        this.curOrd = null;
        if (!this.ordNoDataSources?.length) {
          this.model = temp;
          return;
        }
        if (flag === "cancelSendCond") {
          temp.treatment_date = "治療前・治療中・未確定";
          temp.date_handle = moment(this.getTreatDate).format("YYYY/MM/DD")
          this.model = temp;
          return;
        }
        if (this.getTreatDate && this.ordNoDataSources?.some((item) => item.treatDate === this.getTreatDate) && hasEqualDialsysState) {
          temp.date_handle = moment(this.getTreatDate).format("YYYY/MM/DD")
        } else if (this.ordNoDataSources?.length && (hasEqualDialsysState || this.getDialysisState == "6")) {
          temp.date_handle = moment(this.getTreatDate ?? this.ordNoDataSources[0].treatDate).format("YYYY/MM/DD");
        } else if (this.selectedPatId) {
          temp.treatment_date = "治療前・治療中・未確定";
        }
        this.$set(this, "model", temp);
        // this.model = temp;

        if (this.getDialysisState == "6") {
          // 日付の降順
          const rstDialysisState6 = this.ordNoDataSources.filter((item) => item.rstDialysisState === "6");
          if (rstDialysisState6.length) {
            // 現在の日付に最も近い前の日付を検索します
            const preIndex = rstDialysisState6.findIndex((item) => {
              return this.getTreatDate > item.treatDate;
            });
            const nextIndex = rstDialysisState6.findIndex((item) => {
              return this.getTreatDate < item.treatDate;
            });
            let ordNo = null;
            if (preIndex === -1 && nextIndex === 0) { // 現在の日付が最後の日付の場合
              ordNo = rstDialysisState6[rstDialysisState6.length - 1].ordNo;
              this.prevOrd = null;
              this.nextOrd = this.ordNoDataSources[this.ordNoDataSources.length - 1];
            } else {
              ordNo = rstDialysisState6[preIndex].ordNo;
              const index = this.ordNoDataSources.findIndex((item) => {
                return item.ordNo === ordNo;
              });
              this.prevOrd = this.ordNoDataSources[index];
              this.nextOrd = this.ordNoDataSources[index - 1];
            }
            return;
          }
          this.prevOrd = null;
          this.nextOrd = this.ordNoDataSources[0];
        } else {
          // 現在、確定実績以外の治療データを持たない患者に切替
          // 治療前、治療中データはありませんの表示で＜のみ活性化
          // ＜ボタンをクリック
          // 最新の実績を表示
          this.prevOrd = this.ordNoDataSources[0];
          this.nextOrd = null;
        }
        return;
      }
      this.getSummary(this.getOrdNo).then((response) => {
        response.data.date_handle = response.data.treatment_date.slice(0, 10);
        this.model = response.data;
        // ベッド・クール・治療方法未登録の場合（実績削除後のデータ）
        if (
          (!response.data.bed_name || response.data.bed_name === "未登録") &&
          response.data.kur_name === "未登録" &&
          response.data.treatment_name === "未登録"
        ) {
          const currentOrdInfo = this.ordNoDataSources?.find((item) => {
            return item.ordNo === this.getOrdNo;
          });
          const currentRstDialysisState = currentOrdInfo?.rstDialysisState;
          if (currentRstDialysisState && ["1", "2"].includes(currentRstDialysisState)) {
            this.model.treatment_date = "治療前・治療中・未確定";
          }
          this.model.bed_name = null;
          this.model.kur_name = null;
          this.model.treatment_name = null;
          this.$router.push({ path: "/treatment-record/" });
        }
      });
      if (this.getSharedFlag === 1) {
        this.getFacilityName(this.getSharedFacilityCd).then((response) => {
          this.facilityName =
            this.model.treatment_name != null
              ? "　" + response.data
              : response.data;
        });
      }
    },
    prev() {
      const tempPrev = this.prevOrd;
      if (!tempPrev) {
        return;
      }
      // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 start
      // if (this.srcFuncName) {
      //   this.setOrdNoForSideBarRecord(tempPrev.ordNo);
      // }
      // this.setOrdNo(tempPrev.ordNo);
      // this.setOrd(tempPrev);
      // this.setSharedFacilityCd(tempPrev.facilityCd);
      // if (this.getSharedFlag === 1) {
      //   this.getFacilityName(tempPrev.facilityCd).then((response) => {
      //     this.facilityName =
      //       this.model.treatment_name != null
      //         ? "　" + response.data
      //         : response.data;
      //   });
      // }
      // mod #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 start
      if (this.$route.name === 'treatment-observe-detail') {
        if (!this.$parent.$refs.subComponent.$refs.mainComponent.isChanged) {
          this.preOrNextMethod(tempPrev)
        } else {
          this.$ons.notification.confirm({
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer === 1) {
                this.setSkipRoute(true);
                this.setIsPatInfoChaned(false);
                this.preOrNextMethod(tempPrev);
              }
            }
          });
        }
      } else {
        if (!this.isPatInfoChaned) {
          this.preOrNextMethod(tempPrev)
        } else {
          this.$ons.notification.confirm({
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer === 1) {
                this.setIsPatInfoChaned(false);
                this.preOrNextMethod(tempPrev);
              }
            }
          });
        }
      }
      this.setRstRoundsInfoToCompare(null);
      this.setRstRoundsInfoInProgress(null);
      this.setSelectedRoundType(-1);
      // mod #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 end
      // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 end
      // this.refresh();
      // this.$router.push({ name: "treatment-record" });
    },
    next() {
      const tempNext = this.nextOrd;
      if (!tempNext) {
        return;
      }
      //mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 start
      // if (this.srcFuncName) {
      //   this.setOrdNoForSideBarRecord(tempNext.ordNo);
      // }
      // this.setOrdNo(tempNext.ordNo);
      // this.setOrd(tempNext);
      // this.setSharedFacilityCd(tempNext.facilityCd);
      // if (this.getSharedFlag === 1) {
      //   this.getFacilityName(tempNext.facilityCd).then((response) => {
      //     this.facilityName =
      //       this.model.treatment_name != null
      //         ? "　" + response.data
      //         : response.data;
      //   });
      // }
      // mod #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 start
      if (this.$route.name === 'treatment-observe-detail') {
        if (!this.$parent.$refs.subComponent.$refs.mainComponent.isChanged) {
          this.preOrNextMethod(tempNext)
        } else {
          this.$ons.notification.confirm({
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer === 1) {
                this.setSkipRoute(true);
                this.setIsPatInfoChaned(false);
                this.preOrNextMethod(tempNext)
              }
            }
          });
        }
      } else {
        if (!this.isPatInfoChaned) {
          this.preOrNextMethod(tempNext)
        } else {
          this.$ons.notification.confirm({
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer === 1) {
                this.setIsPatInfoChaned(false);
                this.preOrNextMethod(tempNext)
              }
            }
          });
        }
      }
      this.setRstRoundsInfoToCompare(null);
      this.setRstRoundsInfoInProgress(null);
      this.setSelectedRoundType(-1);
      // mod #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 end
      //mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 end
      // this.refresh();
      // this.$router.push({ name: "treatment-record" });
    },
    //add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 start
    // mod #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 start
    // preOrNextMethod(tempNext) {
    async preOrNextMethod(tempNext) {
      // mod #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 end
      // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 start
      if(this.$route.name === 'treatment-observe-detail'){
        await this.$router.push({ name: "treatment-record-observation" , params: { ignoreWatchGetOrdNo: '1' }});
      }
      // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 end
      if (this.srcFuncName) {
        this.setOrdNoForSideBarRecord(tempNext.ordNo);
      }
      this.setOrdNo(tempNext.ordNo);
      this.setTreatDate(tempNext.treatDate);
      // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 start
      this.setObserveRecord(tempNext.ordNo);
      // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 end
      this.setOrd(tempNext);
      this.setSharedFacilityCd(tempNext.facilityCd);
      if (this.getSharedFlag === 1) {
        this.getFacilityName(tempNext.facilityCd).then((response) => {
          this.facilityName =
            this.model.treatment_name != null
              ? "　" + response.data
              : response.data;
        });
      }
    },
    //add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 end
    /**
     * オーダー番号表示吹き出し 長押しウォッチャー
     */
    checkOrdNoLongPress(isMouseDown) {
      if (isMouseDown) {
        this.blowTimer = setTimeout(() => {
          this.showSearchPopover();
        }, 500);
      } else {
        clearTimeout(this.blowTimer);
      }
    },
    /**
     * オーダー番号表示用関数
     */
    showSearchPopover() {
      this.popoverTarget = this.$refs.displayPos;
      this.popoverVisible = true;
      this.selOrdNo = this.getOrdNo;
    },
    /**
     * 選択中の患者のオーダ番号のリストの初期処理.
     */
    async initOrdNoList() {
      if (this.getFacilityCd && this.selectedPatId) {
        this.offset = 1;
        this.disabledNotExistDates = [];
        this.ordNodisabledNotExistDates = {};
        this.disablefacility = {};
        this.dataofday = [];
        // this.listKurStartTime = {};
        this.ordNoDataSources?.forEach((item) => {
          if (this.ordNodisabledNotExistDates.hasOwnProperty(item.treatDate)) {
            this.ordNodisabledNotExistDates[item.treatDate][
              this.ordNodisabledNotExistDates[item.treatDate].length
            ] = item.ordNo;
            this.disablefacility[item.treatDate][
              this.disablefacility[item.treatDate].length
            ] = item.facilityCd;
          } else {
            this.dataofday = [];
            this.dataofday[0] = item.ordNo;
            this.facilityOfDay = [];
            this.facilityOfDay[0] = item.facilityCd;
            this.ordNodisabledNotExistDates[item.treatDate] = this.dataofday;
            this.disablefacility[item.treatDate] = this.facilityOfDay;
          }
          this.disabledNotExistDates.push(item.treatDate);
        });
      } else if (this.isNullPat) {
        // ？？？？患者表示時の処理
        this.ordNoDataSources = [];
        this.offset = 1;
        this.disabledNotExistDates = [];
        this.ordNodisabledNotExistDates = {};

        // ordNoから治療日を取得する
        this.getSummary(this.getOrdNoForSideBarRecord).then((response) => {
          const treatmentDate = response.data.treatment_date
            .slice(0, 10)
            .replace(/\//g, "");
          this.disabledNotExistDates.push(treatmentDate);
          if (this.ordNodisabledNotExistDates[treatmentDate] != undefined) {
            this.ordNodisabledNotExistDates[treatmentDate][
              this.ordNodisabledNotExistDates[treatmentDate].length
            ] = this.getOrdNoForSideBarRecord;
          }
        });
      }
    },

    // カレンダーを開いた時にフラグをオンにする
    spanCalendarOpen() {
      this.calendarOpenFlg = true;
    },

    // カレンダーを閉じた時にフラグをオフにする
    spanCalendarClose() {
      this.calendarOpenFlg = false;
    },

    reloadTreatmentRecord(value) {
      if (!this.calendarOpenFlg) {
        // データをセットしている為、カレンダーを開こうとしたタイミングでも発火する為、処理タイミングをフラグで管理
        return;
      }
      if (value) {
        //mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 start
        // const convertValue = moment(value).format("YYYYMMDD");
        // const ordNos = this.ordNodisabledNotExistDates[convertValue];
        // let currentOrdIndex = ordNos.findIndex(
        //   (data) => data === this.getOrdNo
        // );
        // if (currentOrdIndex === ordNos.length - 1) {
        //   currentOrdIndex = 0;
        // } else {
        //   if (currentOrdIndex === undefined) {
        //     currentOrdIndex = 0;
        //   } else {
        //     currentOrdIndex = currentOrdIndex + 1;
        //   }
        // }
        // if (this.srcFuncName) {
        //   this.setOrdNoForSideBarRecord(ordNos[currentOrdIndex]);
        // }
        // this.setOrdNo(ordNos[currentOrdIndex]);
        // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 start
        if (this.$route.name === 'treatment-observe-detail') {
          if (!this.$parent.$refs.subComponent.$refs.mainComponent.isChanged) {
            this.clickDate(value)
          } else {
            this.$ons.notification.confirm({
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
              // title: "内容破棄",
              title: DIALOG_MESSAGES[13000004].title,
              // message: "編集内容が破棄されます。</br>よろしいですか？",
              message: messageFormat(DIALOG_MESSAGES[13000004].message),
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
              callback: answer => {
                if (answer === 1) {
                  this.setSkipRoute(true);
                  this.setIsPatInfoChaned(false);
                  this.clickDate(value)
                }
              }
            });
          }
        } else {
          // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 end
          if (!this.isPatInfoChaned) {
            this.clickDate(value)
          } else {
            this.$ons.notification.confirm({
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
              // title: "内容破棄",
              title: DIALOG_MESSAGES[13000004].title,
              // message: "編集内容が破棄されます。</br>よろしいですか？",
              message: messageFormat(DIALOG_MESSAGES[13000004].message),
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
              callback: answer => {
                if (answer === 1) {
                  this.setIsPatInfoChaned(false);
                  this.clickDate(value);
                }
              }
            });
          }
        }
        this.setRstRoundsInfoToCompare(null);
        this.setRstRoundsInfoInProgress(null);
        this.setSelectedRoundType(-1);
        //mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 end
      }
    },
    //add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 start
    // mod #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 start
    // clickDate(value){
    async clickDate(value){
      // mod #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 end
      // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 start
      if(this.$route.name === 'treatment-observe-detail'){
        await this.$router.push({ name: "treatment-record-observation" , params: { ignoreWatchGetOrdNo: '1' }});
      }
      // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 end
      const convertValue = moment(value).format("YYYYMMDD");
        const ordNos = this.ordNodisabledNotExistDates[convertValue];
        let currentOrdIndex = ordNos.findIndex(
          (data) => data === this.getOrdNo
        );
        if (currentOrdIndex === ordNos.length - 1) {
          currentOrdIndex = 0;
        } else {
          if (currentOrdIndex === undefined) {
            currentOrdIndex = 0;
          } else {
            currentOrdIndex = currentOrdIndex + 1;
          }
        }
        if (this.srcFuncName) {
          this.setOrdNoForSideBarRecord(ordNos[currentOrdIndex]);
        }
        this.setOrdNo(ordNos[currentOrdIndex]);
        this.setTreatDate(convertValue);
        // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 start
        this.setObserveRecord(ordNos[currentOrdIndex]);
        // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 end
    },
    //add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 end

    async updateOrdList() {
      if (this.getFacilityCd && this.selectedPatId) {
        this.offset = this.offset + 1;
        // mod FNSI-修正 共有設定 房 start
        // add FNSI-修正 redmine3916 房 start
        this.setLoadingScreenVisible(true);
        // add FNSI-修正 redmine3916 房 end
	// add #12462 患者情報共有 Ji start
        const sharedFlag = (this.getIsOtherFacility === false || (this.getOtherFacilityCd !== null && this.getOtherFacilityCd !== this.getFacilityCd))
        ? 0 
        : (this.getPatientShareMode == 0 ? 1 : 0);
	// mod #12462 患者情報共有 Ji end
        const res = await getOrdNoListWithShared(
          this.selectedPatId,
          this.offset,
          this.limit,
          // this.getSharedFlag == 0 ? 0 : 1,
	  // add #12462 患者情報共有 Ji start
          sharedFlag
	  // add #12462 患者情報共有 Ji end
        );
        // add FNSI-修正 redmine3916 房 start
        this.setLoadingScreenVisible(false);
        // add FNSI-修正 redmine3916 房 end
        // mod FNSI-修正 共有設定 房 end
        res.data.forEach((item) => {
          this.ordNoDataSources.unshift(item);
        });
      }
    },
    /**
     * 子機能ボタンエリア開閉ボタンクリック時に呼ばれる関数
     * ※親コンポーネントの関数を呼びだす.
     */
    change() {
      this.$emit("change");
    },
    /**
     * サインイン者が治療記録の編集若しくは代行編集を保有するか否かを判断する.
     *
     * @returns {Boolean} サインイン者が編集若しくは代行編集権限を保有している場合はtrueを返す.
     */
    hasAuthority() {
      return (
        this.getUserAuthorityCds().includes(AUTHORITY_CODES.RST_EDIT) ||
        this.getUserAuthorityCds().includes(AUTHORITY_CODES.RST_PEDIT)
      );
    },
    /**
     * 休日のスタイル取得
     */
    getStyle(date) {
      return getHolidayStyle(date, true);
    }
  },
  mounted() {
    // オーダー番号の設定状況により再表示させる
    this.refresh();
    // ？？？？患者選択時にもリフレッシュが発火するようにする
    EventBus.$on("initOrdNoList", this.initOrdNoList);
    // 破棄操作後のリフレッシュ
    EventBus.$on("refreshSummary", this.refresh);
  },
  async created() {
    // add FNSI-修正 処理中複数回表示の対応 xie start
    this.setLoadingScreenMessage("処理中...");
    this.setLoadingScreenVisible(true);
    // add #12462 患者情報共有 Ji start
    if (this.selectedPatId) {
      await this.getOrdNoList()
    }
    if(this.ordNoDataSources){
      const current = this.ordNoDataSources.find(
        (data) => data.ordNo === this.getOrdNo
      );
      if (current) {
        this.setSharedFacilityCd(current.facilityCd);
      }
    }
    // add #12462 患者情報共有 Ji end
    // add FNSI-修正 処理中複数回表示の対応 xie end
    await this.initOrdNoList();

    // add FNSI-修正 処理中複数回表示の対応 xie start
    this.setLoadingScreenVisible(false);
    // add FNSI-修正 処理中複数回表示の対応 xie end
  },
  beforeDestroy() {
    this.clearHolidays(); // storeの休日マスタをクリア
    this.curOrd = null;
    this.prevOrd = null;
    this.nextOrd = null;
    EventBus.$off("initOrdNoList");
    EventBus.$off("refreshSummary");

    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
};
</script>

<style scoped>
.treatment-summary {
  display: table-cell;
  padding-left: 5px;
}

.treatment-summary > span {
  color: var(--treatment-record-text-color);
}

.treatment-summary > div > span {
  color: var(--treatment-record-text-color);
}

.treatment-summary > div > span > span {
  color: var(--treatment-record-text-color);
}

.treatment-summary > span.v-touch {
  display: inline-block;
}

.treatment-summary > span.v-touch > span {
  display: inline-block;
}

.ons-icon.prev,
.ons-icon.next {
  cursor: pointer;
}

.ons-icon.prev.disabled,
.ons-icon.next.disabled {
  opacity: 0.3;
  cursor: not-allowed;
}

.popover-style >>> .popover__content {
  font-size: 1em;
  min-height: 2em;
  width: 250px;
}

/** 子機能開閉ボタン */
.treatment-summary-openclose-icon {
  font-size: 2em;
  margin-right: 15px;
  margin-left: 5px;
  color: var(--treatment-record-text-color);
}

.icon-opacity {
  opacity: 0.2;
}
</style>
