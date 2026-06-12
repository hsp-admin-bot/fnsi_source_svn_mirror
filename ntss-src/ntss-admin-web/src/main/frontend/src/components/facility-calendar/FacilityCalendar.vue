<template>
  <div class="facility-calendar" :class="facilityCalendarTop">
    <!--mod 障害票一覧_施設カレンダー 修正 chen start-->
    <!--mod 障害票一覧_5024 修正 全 start-->
 <!-- mod FNSI-改修内容5361修正 関　start -->
     <!-- <kendo-dropdownlist style="width: 106px"
      ref="dropdown"
      :data-source="layoutMst"
      v-model="defaultValue"
      data-text-field="layoutName"
      data-value-field="layoutCd"
      filter="contains"
      @select="selectLayout"
    />-->
     <div class="dropdownlistWrap">
      <kendo-dropdownlist
        ref="dropdown"
        :data-source="layoutMst"
        v-model="defaultValue"
        data-text-field="layoutName"
        data-value-field="layoutCd"
        filter="contains"
        @select="selectLayout"
        class="list-width-style"
        @open="onLayoutDropdownOpen"
      />
    </div>
  <!-- mod FNSI-改修内容5361修正 関　end -->
    <!--mod 障害票一覧_5024 修正 全 end-->
<!--    <kendo-dropdownlist-->
<!--      ref="dropdown"-->
<!--      :data-source="layoutMst"-->
<!--      v-model="defaultValue"-->
<!--      data-text-field="layoutName"-->
<!--      data-value-field="layoutCd"-->
<!--      filter="contafacility"-->
<!--      @select="selectLayout"-->
<!--    />-->
    <!--mod 障害票一覧_施設カレンダー 修正 chen end-->
    <FacilityContentsCalendar
      :class="facilityCalendarContents"
      :contents="calendarContents"
      v-model:base-date="currentDate"
      :center-week-mode="true"
      :view-mode="viewMode"
      :searched-bbs-list="searchedBbsList"
      :loaded-date-range="loadedDateRange"
      @content-clicked="moveToLink"
      @request-clear-loaded-date-range="clearLoadedDateRange"
    />

    <v-ons-popover
      v-if="popoverVisible"
      v-model:visible="popoverVisible"
      :target="popoverTarget"
      cancelable
      :class="[fontSizeSet, 'content-popover custom-content-popover']"
      :key="`pat_list_${patListKey}`"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <v-ons-row class="custom-ons-row custom-col-header">
        <v-ons-col class="custom-search-input">
          <v-ons-input v-model="dataSearchId"></v-ons-input>
        </v-ons-col>
        <v-ons-col class="custom-ons-button">
          <v-ons-button class="btn3-normal" @click="searchData(dataSearchId)">検索</v-ons-button>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="custom-ons-row">
        <div class="grid">
          <table style="position: relative;" class="ntss-list custom-ntss-list">
            <thead>
              <tr>
                <th class="ntss-list-header-th-sticky custom-header-width-40">患者ID</th>
                <th class="ntss-list-header-th-sticky custom-header-width-60">患者名</th>
              </tr>
            </thead>
            <tbody>
            <tr
              v-for="(pat, idx) in popoverContent"
              :key="`pat_${idx}`"
              class="ntss-list-body-tr"
              @click="moveToPatInfo(pat.pat_id)"
            >
              <td class="ntss-list-body-td">{{pat.hosp_pat_id}}</td>
              <!-- mod 9251 NKK連携 profile（標準）（拡張） 姓名を分割して保存していたデータが、姓の欄に結合して更新されてしまう。 zhou start -->
              <td class="ntss-list-body-td">{{`${pat.pat_last_name == null ? "" : pat.pat_last_name} ${pat.pat_first_name == null ? "" :  pat.pat_first_name}`}}</td>
              <!-- mod 9251 NKK連携 profile（標準）（拡張） 姓名を分割して保存していたデータが、姓の欄に結合して更新されてしまう。 zhou end -->
            </tr>
            </tbody>
          </table>
        </div>
      </v-ons-row>
    </v-ons-popover>
  </div>
</template>

<script>
import dayjs from "@/compat/date/dayjs";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import FacilityContentsCalendar from "@/components/common/contents-calendar/FacilityContentsCalendar.vue";
import { ROUTERLINK_DAILY_CHECK, ROUTERLINK_EXAM_REQUEST, ROUTERLINK_FACILITY_CALENDAR, ROUTERLINK_FACILITY_CALENDAR_DETAIL, ROUTERLINK_OPERATION_VIEWER_GENERAL_MACHINES, ROUTERLINK_PATINFO, ROUTERLINK_PAT_EVENT, ROUTERLINK_PERIODIC_INSPECTION, ROUTERLINK_RAD_REQUEST, ROUTERLINK_SCHEDULE_LIST, ROUTERLINK_WATER_QUALITY_SURVEY } from "@/components/facility-calendar/Definitions";
import { FUNC_FACILITY_CALENDAR_JPN_NAME } from "@/constants/function-code";
import { HISTORY_KEY_FACILITY_CALENDAR_LIST } from "@/router/facility-calendar/HistoryKeyConstants";
import {
  createCalendarContentsForMasterLayout,
  createCalendarContentsForCalendar,
  getCalendarLayoutData,
  getFacilityCalendarMasterLayout,
  getPatList,
  formattedDate,
  getDateRangeForSearchCondition
} from "@/components/facility-calendar/Functions.js";
import PopoverMixin from "@/components/PopoverMixin";
/**
* 治療状況マップベッドレイアウト系API
*/
import { ApiHelper } from "@/apis/AxiosHelper";
//  mod 6216 施設イベントの表示条件の不正 zhao start
// import { searchBbsCalendarList } from "@/functions/BbsInfoFunctions.js";
import { searchBbsCalendarList , searchBbsCalendarListEvent} from "@/functions/BbsInfoFunctions.js";
//  mod 6216 施設イベントの表示条件の不正 zhao end
import { EventBus } from "@/compat/vue/event-bus.js";
import { FACILITY_CALENDAR } from "@/constants/defaultSettingConstants";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
import { getScopedWindow } from "@/functions/common/LayoutMeasureHelper";

// 利用者情報
const uriUserInfo = "bbsInfo/getUserAuthentication";

export default {
  mixins: [PopoverMixin],

  components: {
    FacilityContentsCalendar
  },

  data() {
    return {
      calendarContents: [],
      mstList: null,
      selectedLayout: null,
      currentDate: null,
      indInfoRaw: null,
      layoutMst: [],
      isLoading: false,
      searchedBbsList: [],
      newSearchRequest: false,
      // 吹き出し表示フラグ
      popoverVisible: false,
      // 吹き出し位置※左右
      popoverTarget: null,
      // 吹き出し位置※下に表示
      popoverDirection: "right",
      popoverContent: [],
      patListKey: 0,
      defaultValue: null,
      tempDataTable: null,
      dataSearchId: null,
      //add FutreNetWeb+SI課題管理No4035対応 于 start
      loginUserId: null,
      //add FutreNetWeb+SI課題管理No4035対応 于 end
      item: [],
      dateLink: null,
      /**
       * データ読込済み期間
       * カレンダー内容の読込済み期間を保持し、スクロール等による無駄な読込を減らす目的で判定に使用する。
       * 例：{ start: "20260101", end: "20260331" }
       */
      loadedDateRange: {
        start: null,
        end: null
      },
      pendingViewMode: null,
      searchViewModeOverride: null,
    };
  },

  computed: {
    ...mapGetters("pat-info", {
      patId: "selectedPatId",
      patInfoRaw: "selectedPat"
    }),
    // ※検索条件はログイン中保持するため、ストア管理
    ...mapGetters("facility-calendar", [
      "viewMode",
      "getSelectedLayoutFacility",
      "userId",
      "getCalendarSearchDate"
    ]),
    ...mapGetters("facility-calendar", {
      selectedCondition: "selectedCondition"
    }),
    ...mapGetters("user", {
      facilityCd: "getFacilityCd",
      dispUserId: "getDispUserId"
    }),
    ...mapGetters("account-edit", {
      defaultSetting: "getDefaultSetting"
    }),
    ...mapGetters("window-size", {
      sidebarWidth: "getSidebarWidth"
    }),
    ...mapGetters("bbs-info", [
      "selectedBbs",
    ]),
    facilityCalendarTop() {
      if (this.viewMode === 3) {
        return this.sidebarWidth === 0 ? "close-class-m" : "open-class-m";
      } else {
        return this.sidebarWidth === 0 ? "close-class-wd" : "open-class-wd";
      }
    },
    facilityCalendarContents() {
      if (this.viewMode === 3) {
        return this.sidebarWidth === 0 ? "close-class-m-for-calendar" : "open-class-m-for-calendar";
      } else {
        return this.sidebarWidth === 0 ? "close-class-wd-for-calendar" : "open-class-wd-for-calendar";
      }
    }
  },

  watch: {
    async currentDate(newDate, oldDate) {
      if (!newDate || !oldDate) {
        return;
      }
      if (newDate.isSame?.(oldDate, "day")) {
        return;
      }
      if (this.viewMode === 3 && !newDate.isSame(oldDate, "month")) {
        // add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 start
        this.setLoadingScreenVisible(true);
        // add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 end
        try {
          await this.createCalendarContentsForMasterLayoutSearch(undefined, { skipApplyStoredDate: true });
        } finally {
          // add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 start
          this.setLoadingScreenVisible(false);
          // add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 end
        }
      }
    },

    async selectedCondition() {
      this.newSearchRequest = true;
      // add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 start
      this.setLoadingScreenVisible(true);
      // add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 end
      try {
        await this.$nextTick();
        await this.createCalendarContentsForMasterLayoutSearch();
      } finally {
        // add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 start
        this.setLoadingScreenVisible(false);
        // add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 end
      }
    },
  },

  async created() {
    // add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 start
    this.setLoadingScreenMessage("処理中...");
    // add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 end
    // add カレンダー指定での指定日ジャンプに対応 陳 start
    if (this.viewMode === null || this.viewMode === "") {
      this.setViewMode(3);
    }
    // add カレンダー指定での指定日ジャンプに対応 陳 end
    const today = dayjs();
    this.currentDate = today;
    const todayStr = today.format("YYYY-MM-DD");
    const stored = this.getCalendarSearchDate;
    const storedDay = stored ? dayjs(stored, ["YYYY-MM-DD", "YYYYMMDD"], true) : null;
    if (!storedDay?.isValid() || !storedDay.isSame(today, "day")) {
      this.setCalendarSearchDate(todayStr);
    }
    // add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 start
    this.setLoadingScreenVisible(true);
    // add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 end
	/*  add FNSI-437 改修内容 施設イベントの施設カレンダー背景色指定の色調整掲示板への色反映 趙立強 start*/
    // del FNSI5415-カレンダー内のセルの表示に時間がかかる 周 start
    //this.searchedBbsList = await this.createCalendarContentsForMasterLayoutSearch();
    // del FNSI5415-カレンダー内のセルの表示に時間がかかる 周 end
	/*  add FNSI-437 改修内容 施設イベントの施設カレンダー背景色指定の色調整掲示板への色反映 趙立強 end*/
    this.mstList = await getFacilityCalendarMasterLayout();
    this.layoutMst = this.mstList.data.map(
      ({ facilityCalendarLayoutCd, facilityCalendarLayoutName, dispItemInfo }) => ({
        layoutCd: facilityCalendarLayoutCd,
        layoutName: facilityCalendarLayoutName,
        layoutInfo: JSON.parse(dispItemInfo)
      }));

    const [
      // user_id取得
      responseUserInfo,
    ] = await Promise.all([
      ApiHelper.get(`${uriUserInfo}/${this.facilityCd}`, {
        disp_user_id: this.dispUserId
      }),
    ]).catch((error) => {
      //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
      getErrorMessage('FacilityCalendar.vue', 'created', error);
      //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
      // console.log(`API:"[PatBbsContent.vue]created(): DB取得失敗"`);
      // console.log(error);
    });
    // 既未読状態を一覧に表示するため、ログインユーザーと掲示板登録情報を紐づける
    const userId = responseUserInfo.data.userId;
    //add FutreNetWeb+SI課題管理No4035対応 于 start
    this.loginUserId = userId;
    //add FutreNetWeb+SI課題管理No4035対応 于 end

    // 掲示板一覧画面同様、詳細画面でもログインユーザーと掲示板登録情報を紐づけるためstoreに格納
    this.setUserId(userId);
    // カレンダーのユーザーが別のページに移動してから戻ってきた場合
    if (this.newSearchRequest) {
      await this.createCalendarContentsForMasterLayoutSearch();
    }
    // add 性能改善メモリ不足 shan start
    EventBus.$off("customRefreshPage", this.createCalendarContentsForMasterLayoutSearch);
    EventBus.$off("updateDateFollowScreen", this.updateDataScreenMode);
    // add 性能改善メモリ不足 shan end
    EventBus.$on("customRefreshPage", this.createCalendarContentsForMasterLayoutSearch);
    this.$nextTick(async () => {
      if (this.getSelectedLayoutFacility) {
        await this.setDefaultSelectedLayout(this.getSelectedLayoutFacility);
      } else {
        const defaultSetting = this.defaultSetting && this.defaultSetting[FACILITY_CALENDAR.KEY_NAME];
        const defaultSettingLayoutCd = defaultSetting && defaultSetting[FACILITY_CALENDAR.KEY_NAME_LAYOUT_CD];
        const layout = defaultSettingLayoutCd && this.layoutMst.find(el => el.layoutCd === defaultSettingLayoutCd);
        await this.setDefaultSelectedLayout(layout || this.layoutMst[0]);
      }
    });
    EventBus.$on("updateDateFollowScreen", this.updateDataScreenMode);
    EventBus.$on("facilityCalendarQueueViewMode", this.queueViewModeAfterSearch);

    // add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 start
    this.setLoadingScreenVisible(false);
    // add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 end
  },
  mounted() {
    getScopedWindow(this.$el || this)?.addEventListener("resize", this.onResize);
  },
  methods: {
    // add 10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない yangqingzhe start
    ...mapActions("schedule-list", {
      setDispUserTime: "setDispUserTime",
    }),
    // add 10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない yangqingzhe end
// add FNSI-改修内容 自己診断結果：合格xx台、不合格xx台、未実施xx台 dou start
    ...mapActions("operation-viewer/machine", ["setFacilityCd"]),
// add FNSI-改修内容 自己診断結果：合格xx台、不合格xx台、未実施xx台 dou end
    ...mapActions("facility-viewer", ["setTreatBaseDate"]),
    ...mapActions("personal-setting", ["getPersonalSettings"]),
    ...mapActions("bbs-info", [
      "setUserId",
      "setSelectedBbsInfo",
      "setSearchedBbsList",
      "setRegFuncClass",
      "setHTMLContent",
    ]),
    ...mapActions("pat-info", ["selectPat"]),
    ...mapActions("facility-calendar", [
      "setScheduleListDayView",
      "setWaterQualityDayView",
      "setSelectedLayoutFacility",
      "setViewMode",
      "setCalendarSearchDate",
    ]),
    // add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 start
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage"
    }),
    ...mapActions("bread-crumb", ["resetKeepHistory", "addKeepHistory", "setKeepHistory"]),
    // add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 end
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,

    queueViewModeAfterSearch(viewMode) {
      if (this.pendingViewMode === viewMode || this.searchViewModeOverride === viewMode) {
        return;
      }
      this.pendingViewMode = viewMode;
    },
    takePendingViewModeForSearch() {
      if (this.pendingViewMode == null) {
        return null;
      }
      const mode = this.pendingViewMode;
      this.pendingViewMode = null;
      this.searchViewModeOverride = mode;
      return mode;
    },
    applyPendingViewModeAfterSearch(mode) {
      if (mode == null) {
        return;
      }
      this.pendingViewMode = null;
      this.setViewMode(mode);
      this.searchViewModeOverride = null;
      EventBus.$emit("facilityCalendarViewModeApplyDone");
    },

    setDefaultSelectedLayout(selectedLayout) {
      if (selectedLayout) {
        this.selectedLayout = selectedLayout;
        this.defaultValue = +selectedLayout.layoutCd;
        this.$nextTick(async () => {
          // del FNSI5415-カレンダー内のセルの表示に時間がかかる 周 start
          //await this.createCalendarContentsForMasterLayoutSearch();
          // del FNSI5415-カレンダー内のセルの表示に時間がかかる 周 end
          this.setSelectedLayoutFacility(selectedLayout);
          EventBus.$emit("searchConditionFacilityCalendar");
        });
      }
    },

    clearLayoutDropdownFilter(sender) {
      const widget = sender?.sender || sender || this.$refs.dropdown?.kendoWidget?.();
      if (widget?.vm) {
        widget.vm.filter = "";
      }
    },

    // mod FNSI5415-カレンダー内のセルの表示に時間がかかる 周
    //selectLayout(e) {
    async selectLayout(e) {
    // mod FNSI5415-カレンダー内のセルの表示に時間がかかる 周 end
      this.clearLayoutDropdownFilter(e?.sender);
      this.selectedLayout = this.layoutMst.find(
        el => el.layoutCd === e.dataItem.layoutCd);
      // mod FNSI5415-カレンダー内のセルの表示に時間がかかる 周 start
      this.setLoadingScreenVisible(true);
      //await this.createCalendarContentsForMasterLayoutSearch();
      // mod FNSI5415-カレンダー内のセルの表示に時間がかかる 周 end
      this.setSelectedLayoutFacility(this.selectedLayout);
      EventBus.$emit("searchConditionFacilityCalendar");
      // add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 start
      this.setLoadingScreenVisible(false);
      // add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 end
    },

    /**
     * カレンダーで選択中の日付を検索基準日として currentDate に反映する
     */
    applyCalendarQueryDate() {
      const stored = this.getCalendarSearchDate;
      if (!stored) {
        return this.currentDate ? dayjs(this.currentDate) : dayjs();
      }
      const parsed = dayjs(stored, ["YYYY-MM-DD", "YYYYMMDD"], true);
      if (!parsed.isValid()) {
        return this.currentDate ? dayjs(this.currentDate) : dayjs();
      }
      if (!this.currentDate || !parsed.isSame(this.currentDate, "day")) {
        this.currentDate = parsed;
      }
      return parsed;
    },

    /**
     * @description カレンダー内容作成
     */
    async createCalendarContentsForMasterLayoutSearch(direction, options = {}) {
      const pendingViewMode = this.takePendingViewModeForSearch();
      if (!options.skipApplyStoredDate) {
        this.applyCalendarQueryDate();
      }
      // #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start
      this.setLoadingScreenMessage("処理中...");
      this.setLoadingScreenVisible(true);
      // #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end
      let tempContents = [];
      this.indInfoRaw = await getCalendarLayoutData(this.selectedLayout, this.selectedCondition, this.currentDate);
      if (this.indInfoRaw) {
        tempContents = await createCalendarContentsForMasterLayout(this.indInfoRaw, this.currentDate);
      }
      // add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 start
      await this.search(tempContents, this.selectedCondition, direction);
      this.applyPendingViewModeAfterSearch(pendingViewMode);
      // add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 end
      // #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start
      this.setLoadingScreenVisible(false);
      // #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end
    },

    updateDataScreenMode(paramEvent) {
      let tempCurrentDate = dayjs(this.currentDate);
      // mod FNSI5415-カレンダー内のセルの表示に時間がかかる 周 start
      if (this.viewMode === 1) {
        if (paramEvent === "previous") {
          tempCurrentDate = tempCurrentDate.subtract(1, 'day');
        } else if (paramEvent === "next") {
          tempCurrentDate = tempCurrentDate.add(1, 'day');
        } else {
          tempCurrentDate = dayjs();
        }
      }
      if (this.viewMode === 2) {
        if (paramEvent === "previous") {
          tempCurrentDate = tempCurrentDate.subtract(7, 'day');
        } else if (paramEvent === "next") {
          tempCurrentDate = tempCurrentDate.add(7, 'day');
        } else {
          tempCurrentDate = dayjs();
        }
      }
      // mod FNSI5415-カレンダー内のセルの表示に時間がかかる 周 end
      this.currentDate = tempCurrentDate;
      EventBus.$emit("searchConditionFacilityCalendar");
    },

    /**
     * @description ページ遷移
     */
    async moveToLink({ item, date, event }) {
      // add #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 start
      const obj = { name: item.routerLink };
      // add #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 end
      switch (item.routerLink) {
        case ROUTERLINK_FACILITY_CALENDAR_DETAIL:
          await this.setSelectedBbsInfo({
            bbsCtlNo: item.bbsCtlNo,
            selectedPatId: this.patId
          });
          // 登録元機能の設定
          this.setRegFuncClass(this.selectedBbs.reg_func_class);
          // HTMLContentの設定
          this.setHTMLContent(this.selectedBbs.html_content);
          break;
        case ROUTERLINK_PATINFO:
        case ROUTERLINK_PAT_EVENT:
          this.popoverContent = await getPatList(item.itemName, date);
          this.tempDataTable = await getPatList(item.itemName, date);
          this.showPopover(event, item, date);
          return;
        case ROUTERLINK_SCHEDULE_LIST:
          // add #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 start
          var newDate = typeof date.content === "undefined" ? date : date.content.date;
          // add #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 end
          this.setScheduleListDayView(newDate);
          // add #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 start
          obj.params = { startDate: newDate };
          // add #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 end
          break;
        case ROUTERLINK_WATER_QUALITY_SURVEY:
          this.setWaterQualityDayView(date);
          break;
        case ROUTERLINK_DAILY_CHECK:
          obj.params = { fromFacilityCalendar: { date } };
          break;
        case ROUTERLINK_PERIODIC_INSPECTION:
          obj.params = { fromFacilityCalendar: { date } };
          break;
        case ROUTERLINK_EXAM_REQUEST:
          obj.params = { fromFacilityCalendar: { date } };
          break;
        case ROUTERLINK_RAD_REQUEST:
          obj.params = { fromFacilityCalendar: { date } };
          break;
        // add FNSI-改修内容 自己診断結果：合格xx台、不合格xx台、未実施xx台 dou start
        case ROUTERLINK_OPERATION_VIEWER_GENERAL_MACHINES:
          this.setFacilityCd(this.facilityCd);
          break;
        // add FNSI-改修内容 自己診断結果：合格xx台、不合格xx台、未実施xx台 dou end
      }
      // mod #10388 施設カレンダから掲示板へ遷移時のみ、パンくず親（施設カレンダー）を keep に確定
      if (obj.name === "bbs-info") {
        const facilityCalendarKeep = {
          depth: 1,
          title: FUNC_FACILITY_CALENDAR_JPN_NAME,
          routerName: ROUTERLINK_FACILITY_CALENDAR,
          historyKey: HISTORY_KEY_FACILITY_CALENDAR_LIST
        };
        await this.resetKeepHistory();
        await this.addKeepHistory(facilityCalendarKeep);
        await this.$router.push(obj);
        const resolved = this.$router.resolve(obj);
        if (resolved?.meta?.depth) {
          await this.setKeepHistory([
            facilityCalendarKeep,
            {
              depth: resolved.meta.depth,
              title: resolved.meta.title,
              routerName: resolved.name,
              historyKey: resolved.meta.historyKey
            }
          ]);
        }
      } else {
        this.$router.push({ name: "facility-calendar", params: { footer: null } });
        // mod #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 start
        this.$router.push(obj);
      }
      //add 10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない yqz start
      this.setDispUserTime(typeof date.content === "undefined" ? date : date.content.date);
      //add 10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない yqz end
      // mod #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 end
    },

    async moveToPatInfo(selectedPatId) {
      // add #10371 編集権限について、対応する。 dengshen start
      this.popoverVisible = false;
      // add #10371 編集権限について、対応する。 dengshen end
      await this.selectPat(selectedPatId).then(() => {
        switch (this.item.routerLink) {
          case ROUTERLINK_PATINFO:
            // 患者情報へ遷移
            this.$router.push({ name: ROUTERLINK_PATINFO });
            break;
          case ROUTERLINK_PAT_EVENT:
            // 患者イベントへ遷移
            var model = {
              type: ROUTERLINK_PAT_EVENT,
              eventStartDate: this.dateLink,
              eventEndDate: this.dateLink,
              subCategoryName: this.item.subCategoryName,
              categoryName: this.item.categoryName,
            }
            this.$router.push({ name: ROUTERLINK_PAT_EVENT, params: { condition: model }});
            break;
        }
      }).catch(() => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('FacilityCalendar.vue', 'created', '患者選択失敗');
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        // TODO: エラー処理検討
        throw new Error("[FacilityCalendar.vue]setSelectedPat(): 患者選択失敗");
      });
    },

    /**
     * @description 検索
     */
    async search(calendarContents, searchCondition, direction) {
      if (!calendarContents) {
        calendarContents = [];
      }
      let condition = JSON.parse(JSON.stringify(searchCondition));
      condition.noticeStartDate = formattedDate(condition?.noticeStartDate);
      condition.noticeEndDate = formattedDate(condition?.noticeEndDate);
      condition.dialysisDate = formattedDate(condition?.dialysisDate);
      // 検索開始日、終了日が定義されていない場合の制限時間
      const searchViewMode = this.searchViewModeOverride || this.viewMode;
      let dateRange = getDateRangeForSearchCondition(this.currentDate, condition.noticeStartDate, condition.noticeEndDate, searchViewMode);
      condition.noticeStartDate = dateRange?.start;
      condition.noticeEndDate = dateRange?.end;
      // 検索結果の掲示板、患者名をstoreに設定
       //  mod 6216 施設イベントの表示条件の不正 zhao start
      // let searchedBbsListTmp = await searchBbsCalendarList(
      //   condition,
      //   this.facilityCd
      //);
      let searchedBbsListTmp;
      if(this.selectedLayout){
      searchedBbsListTmp = await searchBbsCalendarListEvent(
        condition,
        this.facilityCd,
        this.selectedLayout.layoutCd)
      }else{
      searchedBbsListTmp = await searchBbsCalendarList(
        condition,
        this.facilityCd);
      }
      //  mod 6216 施設イベントの表示条件の不正 zhao end
      // add 障害票一覧_施設カレンダー 修正 chen start
      let noticeEndDateTmp = dayjs(this.currentDate).add(1, 'months').endOf("month").format("YYYYMMDD");
      searchedBbsListTmp.forEach(item => {
        if (item.notice_fac_cal_start_date !== null && item.notice_fac_cal_start_date !== "" &&
            (item.notice_fac_cal_end_date === null || item.notice_fac_cal_end_date === "")) {
          item.notice_fac_cal_end_date = noticeEndDateTmp;
        }
      });
      //add FutreNetWeb+SI課題管理No4035対応 于 start
      searchedBbsListTmp = searchedBbsListTmp.filter(item =>{
        let staffInfo = item.staff_info;
        let staffInfoObj = JSON.parse(staffInfo);
        let targets = staffInfoObj.target;
        if(staffInfoObj.target!=0){
          return targets.indexOf(this.loginUserId) > -1;
        }else{
          return item;
        }
      });
      //add FutreNetWeb+SI課題管理No4035対応 于 end
      let tmpCalendarContents = [];
      if (searchedBbsListTmp && searchedBbsListTmp.length > 0) {
        tmpCalendarContents = await createCalendarContentsForCalendar(calendarContents, searchedBbsListTmp);
      } else {
        if (condition) {
          this.newSearchRequest = false;
          tmpCalendarContents = await createCalendarContentsForCalendar(calendarContents, searchedBbsListTmp);
        }
      }
      // add 障害票一覧_施設カレンダー 修正 chen end

      // currentDateを基準として、データ取得対象期間を取得(calendarContentsはこの範囲に対しデータ取得されている)
      const calendarContentsDateRange = getDateRangeForSearchCondition(this.currentDate, null, null);
      // データ取得対象期間のデータのみを抽出する(searchedBbsListがデータ取得対象期間範囲外まで取得してしまう実装上の都合で、この対応をする)
      tmpCalendarContents = tmpCalendarContents.filter(
        v => v.date >= calendarContentsDateRange.start && v.date <= calendarContentsDateRange.end
      );

      // データ読込済み期間と今回取得した期間の間に1日以上の空白があるか
      const isDateRangeSeparated = this.isRangeSeparated(this.loadedDateRange, calendarContentsDateRange);

      // 未来方向への追加読み込み、かつデータ読込済み期間と今回取得した期間期間が空白無く連続している、または重なっている場合
      this.searchedBbsList = searchedBbsListTmp;
      if (direction === true && !isDateRangeSeparated) {
        // データ読込済み期間の終了日を、今回取得した期間の終了日で更新する
          this.loadedDateRange.end = calendarContentsDateRange.end;

        // 今回取得したデータをthis.calendarContents末尾に追加する(重複期間は除去)
        const existDates = new Set(this.calendarContents.map(v => v.date));
        this.calendarContents = this.calendarContents.concat(
          tmpCalendarContents.filter(v => !existDates.has(v.date))
        );

      // 過去方向への追加読み込み、かつデータ読込済み期間と今回取得した期間期間が空白無く連続している、または重なっている場合
      } else if (direction === false && !isDateRangeSeparated) {
        // データ読込済み期間の開始日を、今回取得した期間の開始日で更新する
        this.loadedDateRange.start = calendarContentsDateRange.start;

        // 今回取得したデータをthis.calendarContents先頭側に追加する(重複期間は除去)
        const existDates = new Set(this.calendarContents.map(v => v.date));
        this.calendarContents = tmpCalendarContents
          .filter(v => !existDates.has(v.date))
          .concat(this.calendarContents);

      // 上記いずれにも該当しない場合、データ読込済み期間とcalendarContentsを再設定する
      } else {
        // データ読込済み期間を、今回取得した期間(calendarContentsDateRange)で上書きする
        this.loadedDateRange = {
          start: calendarContentsDateRange.start,
          end: calendarContentsDateRange.end
        };
        // calendarContentsを今回取得したデータで上書きする
        this.calendarContents = tmpCalendarContents;
      }

      // 掲示板一覧の作成
      const searchedBbsList = this.createSearchedBbsList();
      // 掲示板一覧の設定
      this.setSearchedBbsList(searchedBbsList);
    },
    onLayoutDropdownOpen() {
      requestAnimationFrame(() => {
        this.$nextTick(() => {
          const ddl = this.$refs.dropdown;
          const listContent = ddl?.popupRootEl?.()?.querySelector('.k-list-content');
          listContent?.classList.add('me1');
        });
      });
    },
    showPopover(event, item, date) {
      this.popoverTarget = event;
      this.popoverVisible = true;
      this.dataSearchId = null;
      this.item = item;
      this.dateLink = date.format("YYYYMMDD");
    },

    async searchData(dataSearch) {
      this.popoverContent = this.tempDataTable;
      const textSearchInput = dataSearch.toString().trim();
      if (textSearchInput) {
        this.popoverContent = this.popoverContent.filter(
          item =>
            `${item.hosp_pat_id} ${item.pat_last_name} ${item.pat_first_name}`
              .toLowerCase()
              .includes(textSearchInput.toLowerCase()));
      }
    },

    // 掲示板一覧の作成
    createSearchedBbsList() {
      // 配列
      let searchedBbsList = [];
      let existBbsCtlNoList = [];
      // カレンダーコンテンツのソート
      const sortedCalendarContents = this.calendarContents.sort((x, y) => (x.date) - (y.date));
      // 掲示板詳細一覧の作成
      sortedCalendarContents.forEach(content => {
        const bbsDetailList = content.items.filter(function(item) {
          return item.routerLink === "facility-calendar-detail";
        });
        if (bbsDetailList.length > 0) {
          bbsDetailList.forEach(item => {
            if (!existBbsCtlNoList.includes(item.bbsCtlNo)) {
              const val = {
                bbs_ctl_no: item.bbsCtlNo
              };
              searchedBbsList.push(val);
            }
            existBbsCtlNoList.push(item.bbsCtlNo);
          });
        }
      });
      return searchedBbsList;
    },

    /**
     * 画面リサイズ時の処理
     */
    async onResize() {
      // 患者選択吹き出し表示位置がリセットされ、表示位置がおかしくなるため表示中の場合は非表示とする
      if (this.popoverVisible) {
        this.popoverVisible = false;
      }
    },

    /**
     * データ読込済み期間をクリアする
     */
    clearLoadedDateRange() {
      this.loadedDateRange = {
        start: null,
        end: null
      };
    },

    /**
     * 2つの期間の間に1日以上の空白があるか判定する
     * 期間が重なっている場合、または1日の空白もなく連続している場合はfalseを返す。
     * 期間が重なっておらず、かつ連続もしていない場合はtrueを返す。
     *
     * @param {{ start: string, end: string }} range1 比較対象の期間1(YYYYMMDDフォーマット)
     * @param {{ start: string, end: string }} range2 比較対象の期間2(YYYYMMDDフォーマット)
     * @returns {boolean} 期間の間に空白がある場合はtrue、無い場合はfalse
     */
    isRangeSeparated(range1, range2) {
      if (!range1.start || !range1.end || !range2.start || !range2.end) {
        // 引数のstart/endどれか一つでも未設定の場合、「1日以上の空白がある」としtrueを返す
        return true;
      }

      const start1 = dayjs(range1.start, "YYYYMMDD");
      const end1 = dayjs(range1.end, "YYYYMMDD");
      const start2 = dayjs(range2.start, "YYYYMMDD");
      const end2 = dayjs(range2.end, "YYYYMMDD");

      // 2つの開始日のうち「より未来の日付(遅い日付)」を取得
      const laterStart = dayjs.max(start1, start2);
      // 2つの終了日のうち「より過去の日付(早い日付)」を取得
      const earlierEnd = dayjs.min(end1, end2);

      // laterStart-earlierEndの日数差が2以上なら期間の間に「1日以上の空白がある」としtrueを返す
      return laterStart.diff(earlierEnd, "days") > 1;
    },
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    EventBus.$off("customRefreshPage", this.createCalendarContentsForMasterLayoutSearch);
    EventBus.$off("updateDateFollowScreen", this.updateDataScreenMode);
    EventBus.$off("facilityCalendarQueueViewMode", this.queueViewModeAfterSearch);
    getScopedWindow(this.$el || this)?.removeEventListener("resize", this.onResize);

    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
  // add 性能改善メモリ不足 shan end
};
</script>

<style scoped>
.facility-calendar :deep(.k-dropdown-wrap) {
  background-color: var(--main-background-color) !important;
  color: var(--ntss-list-body-color) !important;
}
.dropdownlistWrap{
  position: absolute;
   z-index: 2;
}
.dropdownlistWrap :deep(.k-input-value-text) {
  color: var(--ntss-list-body-color) !important;
}
.facility-calendar :deep(.k-picker),
.facility-calendar :deep(.k-input-inner) {
  background-color: var(--main-background-color) !important;
  color: var(--ntss-list-body-color) !important;
}
/* 週、日表示時、画面幅が狭くなった時にはの時は absolute を外して折り返し表示とする */
@media screen and (min-width: 550px) {
  /* .close-class-wd :deep(.k-dropdown) {
    position: absolute;
    z-index: 2;
  } */
  .close-class-wd-for-calendar :deep(.facility-calendar-area) {
    width: 250px;
  }
  .close-class-wd-for-calendar :deep(.left-margin-area) {
    min-width: 115px;
    width: calc((100vw / 2) - 125px) !important;
  }
}

@media screen and (max-width: 550px) {
  .close-class-wd-for-calendar :deep(.facility-full-calendar) {
    height: calc(100% - 2em) !important;
  }
  .close-class-wd-for-calendar :deep(.left-margin-area) {
    width: calc((82vw / 2) - 125px) !important;
  }
}

@media screen and (min-width: 850px) {
  /* .open-class-wd :deep(.k-dropdown) {
    position: absolute;
    z-index: 2;
  } */
  .open-class-wd-for-calendar :deep(.facility-calendar-area) {
    width: 250px;
  }
  .open-class-wd-for-calendar :deep(.left-margin-area) {
    min-width: 115px;
    width: calc(((100vw - 300px) / 2) - 125px) !important;
  }
}

@media screen and (max-width: 850px) {
  .open-class-wd-for-calendar :deep(.facility-full-calendar) {
    height: calc(100% - 2em) !important;
  }
  .open-class-wd-for-calendar :deep(.left-margin-area) {
    width: calc(((93vw - 300px) / 2) - 125px) !important;
  }
}

/* .open-class-m :deep(.k-dropdown),
.close-class-m :deep(.k-dropdown) {
  position: absolute;
  z-index: 2;
} */

.facility-calendar :deep(.k-input) {
  height: auto;
}

.facility-calendar {
  height: 100%;
  margin-left: 5px;
}

.custom-content-popover .custom-ons-row {
  height: auto;
}

.custom-ons-button :deep(.button) {
  font-size: 1.5em;
}

.custom-ons-row:last-of-type {
  margin-top: 7px;
}

.custom-content-popover :deep(.popover__content) {
  width: 450px;
  padding: 7px;
  z-index: 20002;
}

.custom-content-popover :deep(.popover__arrow) {
  z-index: -1;
}

.custom-col-header .custom-search-input {
  max-width: 66.5%;
  flex: 0 0 66.5%;
}

.custom-col-header .custom-ons-button {
  max-width: 31.7%;
  flex: 0 0 31.7%;
  margin-left: 7px;
}

.custom-header-width-40 {
  flex: 0 0 40%;
  width: 40%;
}

.custom-header-width-60 {
  flex: 0 0 60%;
  width: 60%;
}

.custom-ntss-list {
  overflow: auto;
  word-break: break-all;
}

.custom-ntss-list .ntss-list-body-td,
.custom-ntss-list .ntss-list-header-th-sticky{
  word-break: break-all;
}

.grid {
  overflow: auto;
  width: 100%;
}
 
/* 月表示(サイドバーの開閉状態にかかわらず共通)時のスタイル */
.open-class-m-for-calendar :deep(.calnendar-header),
.close-class-m-for-calendar :deep(.calnendar-header) {
  display: flex;
  flex-flow: nowrap;
}

.open-class-m-for-calendar :deep(.left-margin-area),
.close-class-m-for-calendar :deep(.left-margin-area) {
  min-width: 115px;
  width: 100%;
}

.open-class-m-for-calendar :deep(.right-margin-area),
.close-class-m-for-calendar :deep(.right-margin-area) {
  width: 100%;
}

 
/* 週、日表示(サイドバーが閉じている)時のスタイル */
.open-class-wd-for-calendar :deep(.calnendar-header),
.close-class-wd-for-calendar :deep(.calnendar-header) {
  display: flex;
  position: absolute;
}

.open-class-wd-for-calendar :deep(.right-margin-area),
.close-class-wd-for-calendar :deep(.right-margin-area) {
  width: unset !important;
}

@media screen and (max-width: 600px) {
  .custom-col-header .custom-search-input {
    max-width: 100%;
    flex: 0 0 100%;
  }

  .custom-col-header .custom-ons-button {
    max-width: 100%;
    flex: 0 0 100%;
    margin-left: 0;
    margin-top: 7px;
  }
}

@media screen and (min-height:700px) {
  .custom-content-popover :deep(.popover__content) {
    max-height: 600px !important;
  }
}

@media screen and (max-width: 800px) {
  .close-class-m :deep(.k-dropdown) {
    width: 110px;
  }
}

@media screen and (min-width: 550px) and (max-width: 800px) {
  .close-class-wd :deep(.k-dropdown) {
    width: 110px;
  }
}

@media screen and (max-width: 1100px) {
  .open-class-m :deep(.k-dropdown) {
    width: 110px;
  }
}

@media screen and (min-width: 850px) and (max-width: 1100px) {
  .open-class-wd :deep(.k-dropdown) {
    width: 110px;
  }
}

</style>
