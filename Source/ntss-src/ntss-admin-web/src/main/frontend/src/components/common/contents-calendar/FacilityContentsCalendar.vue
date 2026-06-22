<template>
  <div v-if="baseDate !== null" class="calendarthis">
    <div class="calnendar-header">
      <div class="left-margin-area"></div>
      <div class="facility-calendar-area" style="min-width: 220px; display: flex; justify-content: center; flex-wrap: nowrap; align-items: center;">
        <date-input
          v-model="calendarSearchDate"
          :classes="'input-area ntss-input-date ntss-custom-input'"
          isRequired
          @blur="saveInputDate"
        />
        <common-calendar
          v-model="calendarSearchDate"
          @blur="saveInputDate"
          @todayButtonClick="saveInputDate"
        />

        <div class="current-month-button">
          <v-ons-button class="btn3-normal common-style-select-button" style="width: 3em !important;" @click="currentDayButtonClick">{{titleCurrentDayButton}}</v-ons-button>
        </div>
      </div>
      <div class="right-margin-area"></div>
    </div>
    <!-- 月カレンダー -->
    <div v-if="viewMode === 3" ref="calendarBody" style="height: calc(100% - 2.2em); overflow: auto;" @scroll="scrollHandler">
      <table class="calendar-body">
        <thead class="scroll-thead">
        <tr>
          <th v-for="weekday in weekdays" :key="`calendar-weekday_${weekday}`" class="calendar-weekday">{{ weekday }}</th>
        </tr>
        </thead>
        <tbody class="scroll-tbody">
        <tr
          v-for="(week, i) in calendarArray"
          :id="week[0].dateObj.format('YYYYMMDD')"
          :key="`calendar-content-week_${i}`"
        >
          <td v-for="({ dateObj, content }, j) in week" :key="`week${i}date${j}`">
            <div class="calendar-container">
              <div
                id="calendarDateHeader"
                :class="calendarDate(dateObj)"
                @click="showContentPopover($event.target, content)">
                <div
                  style="width:fit-content;"
                  @click="calendarDateClick(revertDate(dateObj))"
                  >{{ dateFormatter(dateObj) }}
                </div>
              </div>
              <div class="calendar-content">
                <template v-if="content && content.type === 'items'">
                  <p
                    v-for="(item, k) in content.items"
                    :key="`calendar-content-item_${k}`"
                    class="calendar-content-item"
                    @click="onClickLink(item, dateObj, $event)"
                    :style="itemCalendarStyle(item)"
                  >
                    {{ item.content }}
                  </p>
                </template>
              </div>
            </div>
          </td>
        </tr>
        </tbody>
      </table>
    </div>

    <!-- 週/日カレンダー -->
    <div v-if="viewMode !== 3" ref="schedulerContainer" class="facility-full-calendar" style="height: 100%; overflow: auto">
      <div class="scrollTopFixed">
        <button type="button" class="scheduler-fixed-nav-button scheduler-fixed-nav-prev" title="前" @click.stop="clickSchedulerNavigation('previous')"></button>
        <button type="button" class="scheduler-fixed-nav-button scheduler-fixed-nav-next" title="次" @click.stop="clickSchedulerNavigation('next')"></button>
      </div>
      <kendo-scheduler ref="fullCalendar"
                       :selectable="false"
                       :editable="false"
                       :footer-command="false"
                       :data-source="showEvent"
                       :current-time-marker="false"
                       :allDayEventTemplate="allDayEventTemplate"
                       :eventTemplate="eventTemplate"
                       :dateHeaderTemplate="dateHeaderTemplate"
                       :major-time-header-template="timeHeaderTemplate"
                       :workWeekStart="1"
                       :workWeekEnd="0"
                       :workDayStart="new Date('2013/1/1 12:00 AM')"
                       :workDayEnd="new Date('2013/1/1 11:59 PM')"
                       :resources="resourceData"
                       :dataBound="onDataBound"
                       @navigate="onNavigate"
      >
        <kendo-scheduler-view type="day" :selected="viewMode===1"></kendo-scheduler-view>
        <kendo-scheduler-view
          type="workWeek"
          :work-week-start="1"
          :work-week-end="0"
          :selected="viewMode===2"
        ></kendo-scheduler-view>
      </kendo-scheduler>
    </div>
    <v-ons-popover
      v-if="isPopoverVisible"
      v-model:visible="isPopoverVisible"
      :target="popoverTarget"
      cancelable
      :class="[fontSizeSet, 'content-popover']"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div
        v-for="(content, i) in popoverContent"
        :key="`content-popover-content${i}`"
        class="content-popover-content"
      >{{ content }}</div>
    </v-ons-popover>

    <v-ons-modal :visible="isLoadingBbs">
      <p class="loading-modal">
        {{ message }}
        <v-ons-icon icon="fa-spinner" spin />
      </p>
    </v-ons-modal>
  </div>
</template>

<script>
import dayjs from "@/compat/date/dayjs";
import { EventBus } from "@/compat/vue/event-bus.js";
import {mapActions, mapGetters} from "@/compat/vue/vuex";
import PopoverMixin from "@/components/PopoverMixin";
import {
  createCalendarMonth,
  createCalendarWeek,
  splitCalendarArrayByWeek,
} from "@/components/common/contents-calendar/Functions.js";
import {
  sendRequestGetPatEventCateMst,
  sendRequestGetPatSubEventCateMst
} from "@/apis/facility-calendar";
import {
  getDataPatEventCateMst,
  getDataPatSubEventCateMst,
  getDateRangeForSearchCondition
} from "@/components/facility-calendar/Functions.js";
// add カレンダー指定での指定日ジャンプに対応 陳 start
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
// add カレンダー指定での指定日ジャンプに対応 陳 end
// add FNSI-改修内容 権限関連 趙立強 start
import {AUTHORITY_CODES} from "@/constants/userAuthority";
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
// add FNSI-改修内容 権限関連 趙立強 end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
import { getScopedWindow } from "@/functions/common/LayoutMeasureHelper";
import DateInput from "@/components/common/DateInput";

export default {
  // mod FNSI-改修内容 権限関連 趙立強 start
  // mixins: [PopoverMixin],
  mixins: [PopoverMixin,ComponentGuardMixin],
  // mod FNSI-改修内容 権限関連 趙立強 end
  components: {
    // add カレンダー指定での指定日ジャンプに対応 陳 start
    "common-calendar": commonCalender,
    // add カレンダー指定での指定日ジャンプに対応 陳 end
    "date-input":DateInput,
  },

  props: {
    contents: {
      type: Array,
      default: () => []
    },

    loadedDateRange: {
      type: Object,
      default: () => ({ start: null, end: null })
    },

    // del FNSI5415-カレンダー内のセルの表示に時間がかかる 周 start
    // baseDate: {
    //   type: Object,
    //   default: () => dayjs()
    // },
    // del FNSI5415-カレンダー内のセルの表示に時間がかかる 周 end

    // add カレンダー指定での指定日ジャンプに対応 陳 start
    // baseDateNow: {
    //   type: Object,
    //   default: dayjs()
    // },
    // del FNSI5415-カレンダー内のセルの表示に時間がかかる 周 start
    // baseDateNow: {
    //   type: Object,
    //   default: () => dayjs()
    // },
    // del FNSI5415-カレンダー内のセルの表示に時間がかかる 周 end
    // add カレンダー指定での指定日ジャンプに対応 陳 start

    centerWeekMode: {
      type: Boolean,
      default: false
    },

    viewMode: {
      type: Number,
      default: 3
    },

    searchedBbsList: {
      type: Array,
      default: () => []
    },
  },

  data() {
    return {
      weekdays: ["月", "火", "水", "木", "金", "土", "日"],
      nochanges: [],
      nochangesday: [],
      isPopoverVisible: false,
      popoverTarget: null,
      popoverContent: null,
      calendarArray: null,
      hours: [],
      baseDate: dayjs(),
      currentViewDay: null,
      // リロード
      isLoadingBbs: false,
      message: null,
      paddingNumber: 0,
      calendarSearchDate: null,
      hasTreatmentRecordAuthority: false,
      authorityCds: [
        AUTHORITY_CODES.SCHE_MOVE
      ],
      updateSizeTableProc: null,
      // calendarSearchDate に値を入れるにあたって Watch 監視を一時的に止めたい場合のフラグ
      stopWatchFlg: false,
      lastSyncedParentBaseDate: null,
      pendingMoveCurrentMonthForDate: false,
      // 同一 tick 内の initializeScheduler 重複呼び出しを 1 回の $nextTick にまとめる
      dayWeekSchedulerInitQueued: false,
      // 月スクロール時の同一月 moveToMonth 重複抑止
      lastScrollLoadMonthKey: null
    };
  },

  watch: {
    calendarSearchDate(value) {
      if (!value) {
        return;
      }
      this.setFacilityCalendarWindowValue("calendarSearchDateValue", this.calendarSearchDate);
      if (this.stopWatchFlg) {
        this.stopWatchFlg = false;
        this.syncParentBaseDate();
        return;
      }
      if (this.viewMode === 3) {
        // 月
        this.calendarArray = splitCalendarArrayByWeek(
          createCalendarMonth(dayjs(this.calendarSearchDate, "YYYY-MM-DD")));
        this.createCalendarContents();
        this.baseDate = dayjs(this.calendarSearchDate, "YYYY-MM-DD");
        this.addWeeksToCalendar(3);
        this.requestClearLoadedDateRange();
        this.requestMoveCurrentMonthForDate();
        this.syncParentBaseDate();
      } else if (this.viewMode === 2 || this.viewMode === 1) {
        this.setSchedulerDate(this.calendarSearchDate);
      }
      this.syncParentBaseDate();
      EventBus.$emit("getSelectedDate", this.calendarSearchDate);
    },
    contents() {
      // 日/週は showEvent（searchedBbsList）で Scheduler が描画される。forceUpdate は月グリッド専用
      if (this.viewMode !== 3) {
        return;
      }
      this.createCalendarContents();
      this.baseDate = dayjs(this.calendarSearchDate, "YYYY-MM-DD");
      this.requestCalendarForceUpdate();
    },
    viewMode(value) {
      // 日付が初期化される為、当日を表示日付に設定
      this.stopWatchFlg = true;
      if(this.getCalendarSearchDate){
        this.calendarSearchDate = this.getCalendarSearchDate;
      } else {
        this.calendarSearchDate = dayjs(new Date()).format("YYYY-MM-DD");
      }
      this.$nextTick(() => {
        // 同日の場合、watch処理が動作せず、stopWatchFlgフラグが true のままになるので戻しておく
        this.stopWatchFlg = false;
      });
      //月タブ選択時に施設カレンダー生成
      this.initLayout();
      this.syncParentBaseDate();
      EventBus.$emit("getSelectedDate", this.calendarSearchDate);
      if (value === 1 || value === 2) {
        this.scheduleInitializeSchedulerForDayWeekView();
      }
    },
  },

  async created() {
    this.setLoadingScreenMessage("処理中...");
    this.setLoadingScreenVisible(true);
    this.hasTreatmentRecordAuthority = this.getTreatmentRecordAuthority();
    for (let i = 0; i < 24; i++) {
      this.hours.push(i);
    }
    await sendRequestGetPatEventCateMst(this.selectedPatId).then(res => {
      getDataPatEventCateMst(
        res.data.localDataSource.data.filter(item => +item.isDisp));
    });
    await sendRequestGetPatSubEventCateMst(this.selectedPatId).then(res => {
      getDataPatSubEventCateMst(
        res.data.localDataSource.data.filter(item => +item.isDisp));
    });
    const today = dayjs();
    const todayStr = today.format("YYYY-MM-DD");
    const storedParsed = this.parseCalendarSearchDate(this.getCalendarSearchDate);
    // ストアの日付はログイン中保持するが、別日の古い日付は「今日」に戻す（月初1日の残留対策）
    if (storedParsed && storedParsed.isSame(today, "day")) {
      this.calendarSearchDate = todayStr;
      this.baseDate = storedParsed;
    } else {
      this.calendarSearchDate = todayStr;
      this.baseDate = today;
      this.setCalendarSearchDate(todayStr);
    }
    
    // 休日マスタの休日を取得
    await this.fetchHolidays(this.facilityCd);

    EventBus.$on("updateConfigCurrentDate", this.updateCurrentDate);
    this.setFacilityCalendarWindowValue("calendarDateClick", this.calendarDateClick);
    this.setLoadingScreenVisible(false);
  },
  
  async mounted() {
    this.setFacilityCalendarWindowValue("calendarDateClick", this.calendarDateClick);
    this.setFacilityCalendarWindowValue("calendarSearchDateValue", this.calendarSearchDate);
    //月タブ選択時に施設カレンダー生成
    await this.initLayout();
    //施設カレンダーのサイズ調整
    this.updateSizeTable();
    this.$nextTick(() => {
      this.requestMoveCurrentMonthForDate();
    });
    window.addEventListener("beforeprint", this.handleBeforePrint);
    window.addEventListener("afterprint", this.handleAfterPrint);

    //add #9846 start
    EventBus.$on("onResize", this.onResize);
    //add #9846 end
  },
  
  computed: {
    schedulerViews() {
      return [
        { type: "day", selected: this.viewMode === 1 },
        { type: "workWeek", selected: this.viewMode === 2 }
      ];
    },
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("facility-calendar", {
      selectedCondition: "selectedCondition",
      getCalendarSearchDate: "getCalendarSearchDate"
    }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
    }),
    //mod 4034 そして、ユーザー名：伊藤 彗でサインインし、対象スタッフ一覧モーダルを表示したところ、自身の名前が表示されなかった  吉 start
    // ...mapGetters("account-edit", ["getFontSize"]),
    ...mapGetters("account-edit", ["getFontSize","getUserName"]),
    //mod 4034 そして、ユーザー名：伊藤 彗でサインインし、対象スタッフ一覧モーダルを表示したところ、自身の名前が表示されなかった  吉 end
    ...mapGetters("mst-holiday", ["getHolidays"]),
    titleCurrentDayButton() {
      let title = "今月";
      switch (this.viewMode) {
        case 1:
          title = "今日";
          break;
        case 2:
          title = "今週";
          break;
      }
      return title;
    },

    contentsMonthRange() {
      if (!this.loadedDateRange?.start || !this.loadedDateRange?.end) {
        const range = getDateRangeForSearchCondition(this.baseDate, null, null);
        return {
          minMonth: dayjs(range.start, "YYYYMMDD").startOf("month"),
          maxMonth: dayjs(range.end, "YYYYMMDD").startOf("month")
        };
      }

      return {
        minMonth: dayjs(this.loadedDateRange.start, "YYYYMMDD").startOf("month"),
        maxMonth: dayjs(this.loadedDateRange.end, "YYYYMMDD").startOf("month")
      };
    },

    showEvent() {
      const listEvent = [];
      this.searchedBbsList.forEach(list => {
        /*  mod FNSI-434 改修内容 施設カレンダのみに表示 趙立強 start*/
        const startTime = list.notice_fac_cal_start_time.slice(0,2) + ":" + list.notice_fac_cal_start_time.slice(2);
        const endTime =list.notice_fac_cal_end_time.slice(0,2) + ":" + list.notice_fac_cal_end_time.slice(2);
        // const startTime = dayjs(list.notice_fac_cal_start_date).format('YYYY-MM-DD');
        // const endTime = dayjs(list.notice_fac_cal_end_date).format('YYYY-MM-DD');
        const startDateObj = dayjs(list.notice_fac_cal_start_date);
        const endDateObj = dayjs(list.notice_fac_cal_end_date);
        const startTitleDate = startDateObj.format('YYYY/MM/DD');
        const endTitleDate = endDateObj.format('YYYY/MM/DD');
        const dayDiff = endDateObj.diff(startDateObj, "days");
        // 複数日のイベントの場合は、開始日を00:00:00に設定して、並び順を上に寄せる
        const startDate = dayDiff > 0 ? startDateObj.format('YYYY-MM-DD') + " 00:00:00" : startDateObj.format('YYYY-MM-DD') + " " +startTime + ":00";
        const endDate = endDateObj.format('YYYY-MM-DD') + " " + endTime + ":00";
        /*  mod FNSI-434 改修内容 施設カレンダのみに表示 趙立強 end*/
        const eventItem = {
          id: list.bbs_ctl_no,
          /*  mod FNSI-434 改修内容 施設カレンダのみに表示 趙立強 start*/
          // start: new Date(list.notice_fac_cal_start_date),
          // end: new Date(list.notice_fac_cal_end_date),
          start: new Date(startDate),
          end: new Date(endDate),
          /*  mod FNSI-434 改修内容 施設カレンダのみに表示 趙立強 end*/
          title: `${startTime} - ${startTitleDate} ～ ${endTitleDate} ${list.kindName}: ${list.title || "タイトルなし"} - ${endTime}`,
          color: list.color
        };
        // 跨日イベントは all-day 行に表示（同日イベントは時間軸に表示）
        if (dayDiff > 0) {
          eventItem.isAllDay = true;
          eventItem.start = startDateObj.startOf("day").toDate();
          // 終了日当日まで表示（翌日 0 時だと Kendo が終了日を含めて描画する）
          eventItem.end = endDateObj.endOf("day").toDate();
        }
        listEvent.push(eventItem);

      });

      this.contents.forEach((item, indexItem) => {
        // YYYY-MM-DDフォーマットで new Dateすると、09:00:00 の時刻になってしまう為、フォーマットを修正
        const date = dayjs(item.date).format('YYYY/MM/DD');
        item.items.forEach((data, indexData) => {
          if (typeof(data.bbsCtlNo) === 'undefined') {
            const layoutEvent = {
              start: new Date(date),
              end: new Date(date),
              id: indexItem + indexData,
              title: data.content || '',
              isAllDay: true,
              isAlternateDisplayColor: true, // 2色を交互に表示 flag
              routerLink: data.routerLink,
              categoryName: data.categoryName,      // 患者イベント遷移時に使用
              subCategoryName: data.subCategoryName,// 患者イベント遷移時に使用
              itemName: data.itemName               // 患者イベント遷移時に使用
            }
            listEvent.push(layoutEvent);
          }
        })
      });
      // dayでグループ化 --start
      const groupByDateMap = {};
      listEvent.forEach((eventItem) => {
        if(eventItem.isAlternateDisplayColor){ // 2色を交互に表示 flag
          let date = dayjs(eventItem.start).format('YYYY/MM/DD');
          if(!groupByDateMap[date]){
            groupByDateMap[date] = [];
          }
          groupByDateMap[date].push(eventItem);
        }
      });
      // dayでグループ化 --end
      // eventItemに異なる背景色を交互に設定する --start
      for(let dateKey in groupByDateMap){
        let idx = 1;
        groupByDateMap[dateKey].forEach((eventItem) => {
          eventItem.color = (idx%2==0? 10:11);
          idx++;
        });
      }
      // eventItemに異なる背景色を交互に設定する --end
      return listEvent;
    },
    resourceData() {
      /*  add FNSI-437 改修内容 施設イベントの施設カレンダー背景色指定の色調整掲示板への色反映 趙立強 start*/
      const colorList = [];
      let tmpColorList = [];
      this.searchedBbsList.forEach(list => {
        if (tmpColorList.indexOf(list.color) == -1) {
          tmpColorList.push(list.color);
        }
      });
      tmpColorList.forEach(colorStr => {
        colorList.push({ value: colorStr, color: colorStr },);
      });

      // 月別の集計イベントと同じ背景色
      colorList.push({ value: 10, color: "rgba(76, 172, 252, 0.2)" },);
      colorList.push({ value: 11, color: "rgba(177, 219, 253, 0.2)" },); //背景色定義を追加する（異なる背景色を交互に表示する）
      /*  add FNSI-437 改修内容 施設イベントの施設カレンダー背景色指定の色調整掲示板への色反映 趙立強 end*/
      const data = {
        field: "color",
        /*  mod FNSI-437 改修内容 施設イベントの施設カレンダー背景色指定の色調整掲示板への色反映 趙立強 start*/
        //dataSource:
        // [
        //     { value: '#ffffff', color: "#ffffff" },
        //     { value: "#dbdd31", color: "#dbdd31" },
        //     { value: "#ddd0d0", color: "#ddd0d0" },
        //     { value: "#FFF33F", color: "#FFF33F" },
        //     { value: "#00A95F", color: "#00A95F" },
        //     { value: "#187FC4", color: "#187FC4" },
        //     { value: "#A64A97", color: "#A64A97" },
        //     { value: "#EE87B4", color: "#EE87B4" },
        //     { value: "#D0CECE", color: "#D0CECE" },
        //     { value: 10, color: "rgba(25, 150, 252, 0.301)" },
        // ]
        dataSource: colorList
        /*  add FNSI-437 改修内容 施設イベントの施設カレンダー背景色指定の色調整掲示板への色反映 趙立強 end*/
      };
      return [data];
    },
    formatedDisplay() {
      if (this.calendarSearchDate) {
        return dayjs(this.calendarSearchDate).format('YYYY/MM/DD');
      }
      return "";
    }
  },
  methods: {
    //#9846 start
    onResize(){
      const getTooBar = document.querySelector(".k-scheduler-toolbar.k-toolbar");
      if(getTooBar){
        const topFixed = document.querySelector(".scrollTopFixed");
        let toobarHeight = getTooBar.offsetHeight;
        topFixed.style.height = toobarHeight + 'px'
        topFixed.style.marginBottom = -toobarHeight + 'px'; 
        //button
        const btnPrev = document.querySelector(".scheduler-fixed-nav-prev")
        const btnNext = document.querySelector(".scheduler-fixed-nav-next")
        btnPrev.style.width = toobarHeight + 'px'
        btnPrev.style.height = toobarHeight + 'px'
        btnNext.style.width = toobarHeight + 'px'
        btnNext.style.height = toobarHeight + 'px'
      }
    },
    //#9846 start
    getFacilityCalendarOwnerWindow() {
      return getScopedWindow(this.$el || this);
    },
    setFacilityCalendarWindowValue(key, value) {
      const ownerWindow = this.getFacilityCalendarOwnerWindow();
      if (ownerWindow) {
        ownerWindow[key] = value;
      }
    },
    clearFacilityCalendarWindowValue(key, value) {
      const ownerWindow = this.getFacilityCalendarOwnerWindow();
      if (ownerWindow && (typeof value === "undefined" || ownerWindow[key] === value)) {
        ownerWindow[key] = null;
      }
    },
    requestCalendarForceUpdate() {
      if (this.$?.isMounted) {
        this.$forceUpdate();
      }
    },
    getCalendarBodyElement() {
      return this.$refs?.calendarBody || null;
    },
    getCalendarRowHeight(calendarBody = null) {
      const body = calendarBody || this.getCalendarBodyElement();
      return body?.querySelector("tbody tr")?.clientHeight || 0;
    },
    ...mapActions("bbs-info", [
      "setUserName",
    ]),
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage"
    }),
    ...mapActions("mst-holiday", [
      "fetchHolidays",
      "clearHolidays"
    ]),
    ...mapActions("facility-calendar", [
      "setCalendarSearchDate"
    ]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,

    handleBeforePrint() {
      const schedulerRef = this.getSchedulerRef();
      const scheduler = schedulerRef?.kendoWidget?.();
      const element = schedulerRef?.$el;
      if (!scheduler || !element) {
        return;
      }
      this.clearSchedulerTimeAxisRowStyles();
      this._originalPrintWidth = element.style.width;
      element.style.width = "1024px";
      if (scheduler.view?.()?.name !== "day") {
        scheduler.resize?.();
      }
      this.syncSchedulerTimeAxisRows();
    },
    handleAfterPrint() {
      const schedulerRef = this.getSchedulerRef();
      const scheduler = schedulerRef?.kendoWidget?.();
      const element = schedulerRef?.$el;
      if (!scheduler || !element) {
        return;
      }
      element.style.width = this._originalPrintWidth || "";
      if (scheduler.view?.()?.name !== "day") {
        scheduler.resize?.();
      }
      this.$nextTick(() => {
        this.syncSchedulerTimeAxisRows();
      });
    },

    getSchedulerRef() {
      return this.$refs.fullCalendar || null;
    },
    getSchedulerRoot() {
      const schedulerRef = this.getSchedulerRef();
      return schedulerRef?.schedulerRootEl?.()
        || schedulerRef?.$el
        || this.$refs.schedulerContainer
        || null;
    },
    getSchedulerToolbarEl() {
      return this.getSchedulerRef()?.schedulerToolbarEl?.() || null;
    },
    getSchedulerHeaderWrapEl() {
      return this.getSchedulerRef()?.schedulerHeaderWrapEl?.() || null;
    },
    getSchedulerHeaderAllDayEl() {
      return this.getSchedulerRef()?.schedulerHeaderAllDayEl?.() || null;
    },
    getSchedulerContentEl() {
      return this.getSchedulerRef()?.schedulerContentEl?.() || null;
    },
    getSchedulerTimesEl() {
      return this.queryScheduler(".k-scheduler-body .k-scheduler-times");
    },
    getSchedulerAllDayEl() {
      return this.getSchedulerRef()?.schedulerAllDayEl?.() || null;
    },
    getSchedulerTitleEl() {
      return this.getSchedulerRef()?.schedulerTitleEl?.() || null;
    },
    getSchedulerTableEls() {
      return this.getSchedulerRef()?.schedulerTableEls?.() || [];
    },
    getSchedulerEventEls(selector = null) {
      return this.getSchedulerRef()?.schedulerEventEls?.(selector) || [];
    },
    getSchedulerAllDayEventEls() {
      const headerWrap = this.getSchedulerHeaderWrapEl();
      if (!headerWrap) {
        return [];
      }
      return this.getSchedulerEventEls().filter((eventElement) => headerWrap.contains(eventElement));
    },
    getSchedulerTimedEventEls() {
      const contentEl = this.getSchedulerContentEl();
      if (!contentEl) {
        return [];
      }
      return this.getSchedulerEventEls().filter((eventElement) => contentEl.contains(eventElement));
    },
    getSchedulerNavTodayEl() {
      return this.getSchedulerRef()?.schedulerNavTodayEl?.() || null;
    },
    getSchedulerNavPrevEl() {
      return this.getSchedulerRef()?.schedulerNavPrevEl?.() || null;
    },
    getSchedulerNavNextEl() {
      return this.getSchedulerRef()?.schedulerNavNextEl?.() || null;
    },
    clickSchedulerNavigation(direction) {
      const currentDate = this.parseCalendarSearchDate(this.calendarSearchDate);
      if (!currentDate || (direction !== "previous" && direction !== "next")) {
        return;
      }
      const amount = direction === "previous" ? -1 : 1;
      const unit = this.viewMode === 1 ? "day" : "week";
      this.calendarSearchDate = currentDate.add(amount, unit).format("YYYY-MM-DD");
      EventBus.$emit("updateDateFollowScreen", direction);
    },
    queryScheduler(selector) {
      if (!selector) {
        return null;
      }
      return this.getSchedulerRef()?.queryScheduler?.(selector) || null;
    },
    querySchedulerAll(selector) {
      if (!selector) {
        return [];
      }
      return this.getSchedulerRef()?.querySchedulerAll?.(selector) || [];
    },
    syncSchedulerTimeAxisRows() {
      const content = this.getSchedulerContentEl();
      const times = this.getSchedulerTimesEl();
      if (!content || !times) {
        return;
      }
      const contentRows = [...content.querySelectorAll(".k-scheduler-table tbody tr")];
      const timeRows = [...times.querySelectorAll(".k-scheduler-table tbody tr")];
      const rowCount = Math.min(contentRows.length, timeRows.length);
      for (let i = 0; i < rowCount; i++) {
        const height = contentRows[i].getBoundingClientRect().height;
        if (!height) {
          continue;
        }
        timeRows[i].style.height = `${height}px`;
        [...timeRows[i].children].forEach((cell) => {
          cell.style.height = `${height}px`;
          cell.style.lineHeight = `${height}px`;
          cell.style.textAlign = "center";
          cell.style.verticalAlign = "middle";
          cell.style.paddingTop = "0";
          cell.style.paddingBottom = "0";
        });
      }
    },
    clearSchedulerTimeAxisRowStyles() {
      const times = this.getSchedulerTimesEl();
      if (!times) {
        return;
      }
      [...times.querySelectorAll(".k-scheduler-table tbody tr")].forEach((row) => {
        row.style.height = "";
        [...row.children].forEach((cell) => {
          cell.style.height = "";
          cell.style.lineHeight = "";
        });
      });
    },
    /**
     * 週表示時、Kendo workWeek は日曜を渡すと翌週の月曜から表示されるため、
     * 選択日を含む週の月曜（ISO）に揃えてから Scheduler に渡す。
     */
    resolveSchedulerAnchorDate(dateValue) {
      const parsed = dayjs(dateValue);
      if (!parsed.isValid()) {
        return null;
      }
      if (this.viewMode === 2) {
        return parsed.isoWeekday(1);
      }
      return parsed;
    },
    setSchedulerDate(dateValue = null) {
      if (!dateValue) {
        return null;
      }
      const anchor = this.resolveSchedulerAnchorDate(dateValue);
      if (!anchor) {
        return null;
      }
      const schedulerRef = this.getSchedulerRef();
      const currentDate = schedulerRef?.kendoWidget?.()?.date?.();
      if (currentDate && dayjs(currentDate).isSame(anchor, "day")) {
        return currentDate;
      }
      return schedulerRef?.setSchedulerDate?.(anchor.toDate()) || null;
    },
    setSchedulerView(viewName, dateValue = null) {
      this.getSchedulerRef()?.setSchedulerView?.(viewName);
      if (dateValue) {
        this.setSchedulerDate(dateValue);
      }
    },
    scheduleInitializeSchedulerForDayWeekView() {
      if (this.viewMode !== 1 && this.viewMode !== 2) {
        return;
      }
      if (this.dayWeekSchedulerInitQueued) {
        return;
      }
      this.dayWeekSchedulerInitQueued = true;
      this.$nextTick(() => {
        this.dayWeekSchedulerInitQueued = false;
        this.initializeSchedulerForDayWeekView();
      });
    },
    initializeSchedulerForDayWeekView(retryCount = 0) {
      if (this.viewMode !== 1 && this.viewMode !== 2) {
        return;
      }
      const parsed = this.parseCalendarSearchDate(this.calendarSearchDate);
      if (!parsed) {
        return;
      }
      if (!this.getSchedulerRef()) {
        if (retryCount < 3) {
          this.$nextTick(() => this.initializeSchedulerForDayWeekView(retryCount + 1));
        }
        return;
      }
      const viewName = this.viewMode === 1 ? "day" : "workWeek";
      this.setSchedulerView(viewName, parsed);
      if (this.resourceData?.[0]) {
        this.$refs.fullCalendar?.setSchedulerResourceData?.(0, this.resourceData[0].dataSource);
      }
      //#9846 start
      this.$nextTick(()=> {
        this.onResize();
      })
      //#9846 end
    },
    escapeSchedulerHtml(value) {
      return String(value ?? "")
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;");
    },
    serializeSchedulerEventData(payload) {
      return this.escapeSchedulerHtml(JSON.stringify(payload));
    },
    /*  add FNSI-437 改修内容 施設イベントの施設カレンダー背景色指定の色調整掲示板への色反映 趙立強 start*/
    // Vue2 版の onDataBound 内ループで構築していた font_color マップを共通関数化。
    // タイトル文字列をキーにした styleMap を返し、allDayEvent / 本文領域イベント 双方で再利用する。
    getSchedulerEventStyleMap() {
      const styleMap = new Map();
      this.searchedBbsList.forEach((list) => {
        const startTitleDate = dayjs(list.notice_fac_cal_start_date).format("YYYY/MM/DD");
        const endTitleDate = dayjs(list.notice_fac_cal_end_date).format("YYYY/MM/DD");
        const startTime = list.notice_fac_cal_start_time.slice(0, 2) + ":" + list.notice_fac_cal_start_time.slice(2);
        const endTime = list.notice_fac_cal_end_time.slice(0, 2) + ":" + list.notice_fac_cal_end_time.slice(2);
        const title = `${startTime} - ${startTitleDate} ～ ${endTitleDate} ${list.kindName}: ${list.title || "タイトルなし"} - ${endTime}`;
        styleMap.set(title, {
          color: list.color,
          fontColor: list.font_color
        });
      });
      return styleMap;
    },
    /*  add FNSI-437 改修内容 施設イベントの施設カレンダー背景色指定の色調整掲示板への色反映 趙立強 end*/
    getSchedulerSelectedCell() {
      return this.queryScheduler(
        ".k-state-hover.k-state-selected.k-state-focused, .k-state-selected.k-state-focused, .k-state-selected");
    },
    getSchedulerEventContentElement(eventElement) {
      return eventElement?.querySelector?.('[data-ntss-role="event-content"], .k-event-template, div[title], div') || null;
    },
    getSchedulerEventTitle(eventElement, useTextFallback = false) {
      const contentElement = this.getSchedulerEventContentElement(eventElement);
      const attrTitle = contentElement?.getAttribute?.("title");
      if (attrTitle) {
        return attrTitle;
      }
      if (useTextFallback) {
        return eventElement?.textContent?.replace(/\r?\n/g, "").trim() || "";
      }
      return contentElement?.textContent?.replace(/\r?\n/g, "").trim() || "";
    },
    /*  add FNSI-437 改修内容 施設イベントの施設カレンダー背景色指定の色調整掲示板への色反映 趙立強 start*/
    // Vue2 版 onDataBound 内で allDayEvent/通常イベントに対して行っていた font_color 適用・タイトル再設定を共通化。
    applySchedulerEventVisual(eventElement, styleMap, options = {}) {
      if (!eventElement) {
        return;
      }
      const { useTextFallback = false, hideDummy = false } = options;
      const contentElement = this.getSchedulerEventContentElement(eventElement);
      const title = this.getSchedulerEventTitle(eventElement, useTextFallback);
      if (title) {
        eventElement.setAttribute("title", title);
      }
      const styleInfo = styleMap.get(title);
      if (styleInfo?.fontColor) {
        eventElement.style.color = styleInfo.fontColor;
      }
      if (contentElement) {
        contentElement.removeAttribute("title");
      }
      if (hideDummy && eventElement.querySelector(".dummy-obj-hidden")) {
        eventElement.style.visibility = "hidden";
      }
    },
    /*  add FNSI-437 改修内容 施設イベントの施設カレンダー背景色指定の色調整掲示板への色反映 趙立強 end*/
    renderSchedulerDateHeader(dateValue) {
      const date = dayjs(dateValue);
      const dateText = date.date() === 1 ? date.format("YYYY/M/D") : date.format("M/D");
      const dateClass = date.format("YYYY-MM-DD") === this.calendarSearchDate
        ? "calendar-date-number calendar-date-baseday"
        : "calendar-date-number";
      const dateKey = this.escapeSchedulerHtml(date.format("YYYY-MM-DD"));
      return `
        <ul class="k-date-header-template" data-ntss-role="date-header" onclick="this.ownerDocument.defaultView.calendarDateClick('${date.format("YYYY-MM-DD")}')">
          <li date="${dateKey}" data-ntss-role="date-title" class="calendar-date-title">
            ${this.escapeSchedulerHtml(date.format("ddd"))}
          </li>
          <li date="${dateKey}" data-ntss-role="date-number" class="${dateClass}">
            ${this.escapeSchedulerHtml(dateText)}
          </li>
        </ul>
      `;
    },
    buildSchedulerEventPayload(eventData) {
      return {
        title: eventData?.title || "",
        start: eventData?.start || "",
        routerLink: eventData?.routerLink ?? null,
        color: eventData?.color || "",
        id: eventData?.id || "",
        isAlternateDisplayColor: !!eventData?.isAlternateDisplayColor,
        categoryName: eventData?.categoryName ?? null,
        subCategoryName: eventData?.subCategoryName ?? null,
        itemName: eventData?.itemName ?? null
      };
    },
    renderSchedulerTimedEvent(eventData) {
      const payload = this.buildSchedulerEventPayload(eventData);
      const title = this.escapeSchedulerHtml(payload.title);
      return `
        <div
          title="${title}"
          data-ntss-role="event-content"
          class="event-item"
          data-event='${this.serializeSchedulerEventData(payload)}'>
          ${title}
        </div>
        <style>
          .event-item {
            word-break:break-all;
          }
        </style>
      `;
    },
    renderSchedulerAllDayEvent(eventData) {
      const payload = this.buildSchedulerEventPayload(eventData);
      const descriptionClass = eventData?.description ? ` ${this.escapeSchedulerHtml(eventData.description)}` : "";
      const title = this.escapeSchedulerHtml(eventData?.title || "");
      return `
        <div data-ntss-role="all-day-event-wrapper" style="overflow: hidden;height: fit-content;" class="${descriptionClass.trim()}">
          <div
            title="${title}"
            data-ntss-role="event-content"
            class="scheduler-event-template"
            data-event='${this.serializeSchedulerEventData(payload)}'>
            ${title}
          </div>
        </div>
      `;
    },
    bindSchedulerEventPointerdown() {
      this.getSchedulerEventEls().forEach((element) => {
        if (element.__ntssPointerDownHandler) {
          element.removeEventListener("pointerdown", element.__ntssPointerDownHandler);
        }
        const handler = (event) => {
          if (event.button === undefined || event.button === 0) {
            this.onClickEvent(event);
          }
        };
        element.__ntssPointerDownHandler = handler;
        element.addEventListener("pointerdown", handler);
      });
    },
    updateCurrentDate(viewMode) {
      this.$nextTick(() => {
        if (viewMode === 1 || viewMode === 2) {
          this.setSchedulerDate(this.baseDate);
        }
      });
    },
    onNavigate(params) {
      // if(this.stopWatchFlg == true){
      //   return
      // }
      //liyanze
      if(params.action == 'changeDate'){
        this.$nextTick(() => {
          this.stopWatchFlg = false;
          this.saveInputDate();
        });
      }else{
        this.stopWatchFlg = true;
        if(this.viewMode === 1){
          this.$nextTick(() => {
            const actualDate = this.$refs.fullCalendar?.kendoWidget?.()?.date?.();
            let showDate = dayjs(actualDate).format("YYYY-MM-DD");
            this.calendarSearchDate = showDate;
            // 表示日付の更新処理
            if (typeof params.date !== "undefined" && (this.viewMode === 1 ||  this.viewMode === 2) && params.action != "changeDate") {
              this.$nextTick(() => {
                this.stopWatchFlg = false;
                this.saveInputDate();
              });
            }
          });
        }
        if (this.viewMode === 2) {
          const baseDate = new Date(this.calendarSearchDate);
          let targetDate = new Date(baseDate);
          if (params.action === "next") {
            // +7
            targetDate.setDate(targetDate.getDate() + 7);
            const day = targetDate.getDay();
            const diff = (day === 0 ? -6 : 1 - day);
            targetDate.setDate(targetDate.getDate() + diff);
          }
          if (params.action === "previous") {
            function getLastSunday(dateStr) {
              const d = new Date(dateStr);
              d.setDate(d.getDate() - 1);
              const day = d.getDay();
              d.setDate(d.getDate() - day);
              return d;
            }
            targetDate = getLastSunday(baseDate);
          }
          const showDate = dayjs(targetDate).format("YYYY-MM-DD");
          this.calendarSearchDate = showDate;
          // 表示日付の更新処理
            if (typeof params.date !== "undefined" && (this.viewMode === 1 ||  this.viewMode === 2) && params.action != "changeDate") {
              this.$nextTick(() => {
                this.stopWatchFlg = false;
                this.saveInputDate();
              });
            }
        }
      }
      if (params.action !== "changeDate") {
        EventBus.$emit("updateDateFollowScreen", params.action);
      }
    },
    async initLayout() {
      if (this.viewMode === 3) { // 月
        if(this.getCalendarSearchDate){
          this.calendarSearchDate = this.getCalendarSearchDate;
          this.calendarArray = splitCalendarArrayByWeek(
            createCalendarMonth(dayjs(this.calendarSearchDate, "YYYY-MM-DD")));
          await this.createCalendarContents();
          this.addWeeksToCalendar(3);
          this.moveCurrentMonthForDate();
        } else {
          this.calendarArray = splitCalendarArrayByWeek(
            createCalendarMonth(dayjs()));
          await this.createCalendarContents();
          this.addWeeksToCalendar(3);
          this.moveCurrentMonth();
        }
      }
    },
    parseCalendarSearchDate(date) {
      if (!date) {
        return null;
      }
      const parsed = dayjs(date, ["YYYY-MM-DD", "YYYYMMDD"], true);
      return parsed.isValid() ? parsed : null;
    },
    syncParentBaseDate() {
      const parsed = this.parseCalendarSearchDate(this.calendarSearchDate);
      if (!parsed) {
        return;
      }
      const formattedDate = parsed.format("YYYY-MM-DD");
      if (this.lastSyncedParentBaseDate === formattedDate) {
        return;
      }
      this.lastSyncedParentBaseDate = formattedDate;
      this.setCalendarSearchDate(formattedDate);
      this.baseDate = parsed;
      this.$emit("update:baseDate", parsed);
    },
    moveToMonth(date) {
      const parsed = this.parseCalendarSearchDate(date);
      if (!parsed) {
        return;
      }
      if (this.baseDate?.isSame?.(parsed, "month")) {
        return;
      }
      this.baseDate = parsed;
      this.$emit("update:baseDate", parsed);
    },

    moveCurrentMonth() {
      if (this.viewMode === 3) {
        // 月表示時：スクロールは当月へ。ヘッダー表示日は「今日」（月初1日にしない）
        this.calendarSearchDate = dayjs().format("YYYY-MM-DD");

        const calendarBody = this.$refs?.calendarBody;
        if (!calendarBody) {
          this.pendingMoveCurrentMonthForDate = true;
          return;
        }

        // 当月の第1週を取得
        const week = [...calendarBody.querySelectorAll("[id]")].find(
          i =>
            dayjs(i.id, "YYYYMMDD").isoWeek() ===
            dayjs()
              .startOf("month")
              .isoWeek() && dayjs(i.id, "YYYYMMDD").year() === dayjs().year());
        if (week) {
          week.scrollIntoView();
          calendarBody.scrollTop -= calendarBody.querySelector(
            "thead")?.clientHeight || 0;
          this.$emit("update:baseDate", dayjs());
        }
      } else {
        this.calendarSearchDate = dayjs().format("YYYY-MM-DD");
      }
    },
    requestMoveCurrentMonthForDate() {
      if (this.viewMode !== 3) {
        return;
      }
      const calendarBody = this.$refs?.calendarBody;
      if (!calendarBody) {
        this.pendingMoveCurrentMonthForDate = true;
        return;
      }
      this.pendingMoveCurrentMonthForDate = false;
      this.moveCurrentMonthForDate();
    },

    moveCurrentMonthForDate() {
      const calendarBody = this.$refs?.calendarBody;
      if (!calendarBody) {
        this.pendingMoveCurrentMonthForDate = true;
        return;
      }
      if (calendarBody.scrollTop === 1) return;
      let isoWeekTmp = dayjs(this.calendarSearchDate, "YYYY-MM-DD").isoWeek();
      let isoWeekStart = dayjs(this.calendarSearchDate, "YYYY-MM-DD").isoWeekday(1).format('YYYY-MM-DD');
      let yearTmp = dayjs(isoWeekStart, "YYYY-MM-DD").isoWeekYear();

      this.$nextTick(() => {
        const nextCalendarBody = this.$refs?.calendarBody;
        if (!nextCalendarBody) {
          this.pendingMoveCurrentMonthForDate = true;
          return;
        }

        // 当月の第1週を取得
        const week = [...nextCalendarBody.querySelectorAll("[id]")].find(
          i => dayjs(i.id, "YYYYMMDD").isoWeek() === isoWeekTmp &&
            dayjs(i.id, "YYYYMMDD").isoWeekYear() === yearTmp);
        if (week) {
          week.scrollIntoView();
          nextCalendarBody.scrollTop -= nextCalendarBody.querySelector(
            "thead").clientHeight;
        }
      });
    },

    calendarDate(date) {
      const className = "calendar-date";
      const today = dayjs().startOf("date");
      var checkHoliday = this.getHolidays;
      let ret = [className];

      if (today.format("YYYY/MM/DD") == date.format("YYYY/MM/DD")) {
        ret.push(className + "-Today");
        if(checkHoliday[date.format("YYYY-MM-DD")] != null){
          ret.push(className + "-Holiday");
        }
      }else if (checkHoliday[date.format("YYYY-MM-DD")] != null) {
        ret.push(className + "-Holiday");
        if(date.month()%2){
          ret.push(className + "-OtherMonth");
        }
      }else if(date.month()%2){
        ret.push(className + "-OtherMonth");
      }
      if(date.day() === 6){
        ret.push(className + "-Saturday");
      }
      if(date.day() === 0){
        ret.push(className + "-Sunday");
      }
      if(date.format("YYYY-MM-DD") === this.calendarSearchDate){
        ret.push(className + "-baseday");
      }
      return ret;
    },

    calendarWeekDay(date) {
      const className = "calendar";
      return [
        className,
        {
          [`${className}-workingday`]: date.day() < 6
        },
        {
          [`${className}-sat`]: date.day() === 6
        },
        {
          [`${className}-sun`]: date.day() === 0
        }
      ];
    },

    dateFormatter(date) {
      return date.date() === 1 ? date.format("YYYY/M/D") : date.format("M/D");
    },

    weekDayFormatter(date) {
      let currentWeekDay = date.day() - 1;
      if (currentWeekDay === -1) {
        currentWeekDay = 6;
      }
      return this.weekdays[currentWeekDay];
    },

    onClickLink(item, date, event) {
      // mod FNSI-改修内容 権限関連 趙立強 start
      // this.$emit("content-clicked", { item, date, event });
      this.setUserName(this.getUserName);
      // mod #10359、#10331 編集権限について、対応する。 dengshen start
      // if (!this.hasTreatmentRecordAuthority) {
      //
      //   if(item.routerLink === "facility-calendar-detail"){
      //     this.$emit("content-clicked", { item, date, event });
      //   }else{
      //     return true;
      //   }
      // }else{
      //   this.$emit("content-clicked", { item, date, event });
      // }
      this.$emit("content-clicked", { item, date, event });
      // mod #10359、#10331 編集権限について、対応する。 dengshen end
      // mod FNSI-改修内容 権限関連 趙立強 end
    },
    /**
     * 集計イベント押下時の処理
     * @param {*} event
     */
    onClickEvent(event) {
      // data-event属性から値を取得
      const targetElement = event.currentTarget;
      const eventElement = targetElement.querySelector("[data-ntss-role=\"event-content\"], .k-event-template") || targetElement.closest?.("[data-ntss-role=\"event-content\"], .k-event-template") || targetElement;
      const eventDataAttr = eventElement?.getAttribute("data-event");
      const eventData = eventDataAttr ? JSON.parse(eventDataAttr) : null;
      if (eventData === null) {
        return;
      }

      if (eventData.routerLink === null) {
        // routerLinkが未設定の場合は施設イベント詳細へ遷移
        eventData.routerLink = "facility-calendar-detail";
      }
      const eventItem = {
        content: eventData.title,
        routerLink: eventData.routerLink,
        color: eventData.color,
        bbsCtlNo: eventData.id,
        categoryName: eventData.categoryName,       // 患者イベント遷移時に使用
        subCategoryName: eventData.subCategoryName, // 患者イベント遷移時に使用
        itemName: eventData.itemName                // 患者イベント遷移時に使用
      };
      // 第3引数：templateElement 患者一覧の吹き出し（onsen ui popover）に渡す吹き出し表示対象のelement
      this.onClickLink(eventItem, dayjs(eventData.start), eventElement);
    },
    
    /**
     * @description カレンダーの各日付押下時の処理
     * @param {String} date 日付(YYYY-MM-DD形式)
     */
    calendarDateClick(date){
      EventBus.$emit("createEvent", date);
    },

    requestClearLoadedDateRange() {
      this.lastScrollLoadMonthKey = null;
      this.$emit("request-clear-loaded-date-range");
    },

    showContentPopover(target, content) {
      if (!content || !content.items || !content.items.length || target.id !== "calendarDateHeader") {
        return null;
      }
      let filteredList = this.selectedCondition.viewTotal ? content.items : content.items.filter(i => i.bbsCtlNo);
      this.popoverContent = filteredList.map(item => item.content);
      this.popoverTarget = target;
      this.isPopoverVisible = true;
    },

    /**
     * @description カレンダー内容作成
     */
    createCalendarContents() {
      if (this.viewMode === 3) {
        this.calendarArray.forEach(week => {
          week.forEach(day => {
            if (!day.dateObj) day.dateObj = day;
            day.content = this.contents.find(
              ({ date }) => date === day.dateObj.format("YYYYMMDD"));
          });
        });
      }
    },

    /**
     * @description スクロールイベントにより、月の切り替えを行う
     */
    scrollHandler() {
      const e = this.getCalendarBodyElement();
      if (!e) {
        return;
      }
      const isScrolledTop = e.scrollTop === 0;
      const isScrolledBottom = Math.abs(e.scrollTop + e.clientHeight - e.scrollHeight) < 4;
      const isScrolledIntoMonth = elem => {
        if (!elem) {
          return false;
        }
        const parentTop = e.scrollTop;
        const parentBottom = parentTop + e.clientHeight;
        const elemTop = elem.offsetTop;
        const elemBottom = elemTop + elem.clientHeight;
        return elemBottom <= parentBottom && elemTop >= parentTop;
      };

      if (this.viewMode === 3) {
        if (isScrolledTop) {
          this.addWeeksToCalendar(-1);
          const rowHeight = this.getCalendarRowHeight(e);
          if (rowHeight > 0) {
            e.scrollTop = rowHeight;
          }
        } else if (isScrolledBottom) {
          this.addWeeksToCalendar(1);
        }
      }

      if (this.viewMode === 3) {
        const currentMonthElem = [...e.querySelectorAll("[id]")].find(
          i => dayjs(i.id, "YYYYMMDD").isoWeek() === dayjs(i.id, "YYYYMMDD").date(15).isoWeek() &&
            isScrolledIntoMonth(i)
        );
        if (currentMonthElem) {
          const { minMonth, maxMonth } = this.contentsMonthRange;
          const hitMonth = dayjs(currentMonthElem.id, "YYYYMMDD").startOf("month");
          const diffMin = hitMonth.diff(minMonth, "months");
          const diffMax = hitMonth.diff(maxMonth, "months");
          if (diffMin <= 0 || diffMax >= 0) {
            const monthKey = hitMonth.format("YYYY-MM");
            if (this.lastScrollLoadMonthKey === monthKey) {
              return;
            }
            this.lastScrollLoadMonthKey = monthKey;
            this.moveToMonth(currentMonthElem.id);
          } else {
            this.lastScrollLoadMonthKey = null;
          }
        }
      }
    },

    /**
     * @description ○週間をカレンダーに追加
     * @param {Number} numWeeks 週数
     */
    addWeeksToCalendar(numWeeks) {
      if (!Array.isArray(this.calendarArray) || this.calendarArray.length === 0) {
        return;
      }
      const firstWeek = this.calendarArray[0];
      const lastWeek = this.calendarArray[this.calendarArray.length - 1];
      const firstDate = firstWeek?.[0]?.dateObj || firstWeek?.[0] || null;
      const lastDate = lastWeek?.[0]?.dateObj || lastWeek?.[0] || null;
      const isAddToEndOfCalendar = numWeeks > 0;
      const seedDate = isAddToEndOfCalendar ? lastDate : firstDate;
      if (!seedDate) {
        return;
      }
      const baseDate = isAddToEndOfCalendar
        ? dayjs(seedDate).add(1, "week")
        : dayjs(seedDate).add(numWeeks, "week");

      const newWeek = createCalendarWeek(baseDate, numWeeks);
      const calendarWeeksArray = splitCalendarArrayByWeek(newWeek);
      if (isAddToEndOfCalendar) {
        this.calendarArray.push(...calendarWeeksArray);
      } else {
        this.calendarArray.unshift(...calendarWeeksArray);
      }
      this.createCalendarContents();
    },

    /**
     * @description 検索用に変更
     */
    formattedDate(date) {
      return date === null || date === ""
        ? null
        : dayjs(date).format("YYYYMMDD");
    },
    
    /**
     * @description 日付の文字列取得(YYYY-MM-DD形式)
     * @param {Date} date 日付
     */
    revertDate(date) {
      return date === null || date === ""
        ? null
        : dayjs(date).format("YYYY-MM-DD");
    },

    itemCalendarStyle(item) {
      let isDisplay = "";
      // イベントに検索期間外のものを含む複数の日がある場合、検索時間外の日付を非表示にします
      if (!item.bbsCtlNo && !this.selectedCondition.viewTotal) {
        isDisplay = "none";
      }
      // mod 障害票一覧_施設カレンダー 修正 chen start
      if (item.color && item.color !== '#ffffff') {
        return {
          background: item.color,
          display: isDisplay,
          /*  add FNSI-437 改修内容 施設イベントの施設カレンダー背景色指定の色調整掲示板への色反映 趙立強 start*/
          color: item.font_color && item.font_color !== '#000000' ? item.font_color : 'var(--ntss-base-color)',
          /*  add FNSI-437 改修内容 施設イベントの施設カレンダー背景色指定の色調整掲示板への色反映 趙立強 end*/
        };
      } else {
        return {
          display: isDisplay,
          /*  add FNSI-437 改修内容 施設イベントの施設カレンダー背景色指定の色調整掲示板への色反映 趙立強 start*/
          color: item.font_color && item.font_color !== '#000000' ? item.font_color : 'var(--ntss-base-color)',
          /*  add FNSI-437 改修内容 施設イベントの施設カレンダー背景色指定の色調整掲示板への色反映 趙立強 end*/
        };
      }
      // mod 障害票一覧_施設カレンダー 修正 chen end
    },
    /**
     * @description 今日/今週/今月ボタンのクリックイベント
     */
    currentDayButtonClick() {
      if (this.viewMode === 3) {
        this.requestClearLoadedDateRange();
      }
      this.moveCurrentMonth();
      this.saveInputDate();
    },
    /**
     * @description カレンダー表示の日付の保存
     */
    saveInputDate() {
      this.syncParentBaseDate();
    },
    eventTemplate(e) {
      return this.renderSchedulerTimedEvent(e);
    },

    dateHeaderTemplate(e) {
      return this.renderSchedulerDateHeader(e?.date);
    },

    allDayEventTemplate(e) {
      return this.renderSchedulerAllDayEvent(e);
    },

    // #9569 掲示板の時刻表示が不正 zhou.tao Add Start
    timeHeaderTemplate(e) {
      return this.escapeSchedulerHtml(dayjs(e?.date).format("H:mm"));
    },
    // #9569 掲示板の時刻表示が不正 zhou.tao Add End

    onDataBound() {
      const weekDays = this.querySchedulerAll('[data-ntss-role="date-title"], .calendar-date-title');
      if (weekDays.length > 0) {
        weekDays.forEach((textToday) => {
          let addClass = "calendar-workingday";
          if (textToday.textContent.includes("土")) {
            addClass = "calendar-sat";
          }
          if (textToday.textContent.includes("日")) {
            addClass = "calendar-sun";
          }
          textToday?.classList?.add(addClass);
        });
      }

      const dateNumbers = this.querySchedulerAll('[data-ntss-role="date-number"], .calendar-date-number');
      if (dateNumbers.length > 0) {
        const checkHoliday = this.getHolidays;
        dateNumbers.forEach((textToday) => {
          const dateAttr = textToday.getAttribute("date");
          const momentDate = dayjs(dateAttr, "YYYY-MM-DD", true).isValid()
            ? dayjs(dateAttr, "YYYY-MM-DD")
            : dayjs(dateAttr);
          if (momentDate.month() % 2) {
            textToday?.classList?.add("calendar-date-OtherMonth");
          }
          if (momentDate.day() === 6) {
            textToday?.classList?.add("calendar-date-Saturday");
          }
          if (momentDate.day() === 0) {
            textToday?.classList?.add("calendar-date-Sunday");
          }
          if (checkHoliday[momentDate.format("YYYY-MM-DD")] != null) {
            textToday?.classList?.add("calendar-date-Holiday");
          }
        });
      }

      const btnToday = this.getSchedulerNavTodayEl();
      if (btnToday) {
        const anchor = btnToday.getElementsByTagName("a")[0];
        if (anchor) {
          anchor.innerHTML = this.titleCurrentDayButton;
          anchor.title = "";
        }
        btnToday?.classList?.add("today-button");
      }
      const btnPrev = this.getSchedulerNavPrevEl();
      if (btnPrev?.getElementsByTagName("a")?.[0]) {
        btnPrev.getElementsByTagName("a")[0].title = "前";
      }
      const btnNext = this.getSchedulerNavNextEl();
      if (btnNext?.getElementsByTagName("a")?.[0]) {
        btnNext.getElementsByTagName("a")[0].title = "次";
      }

      const allDaySlot = this.getSchedulerAllDayEl();
      if (allDaySlot) {
        allDaySlot.textContent = "";
      }

      // 日を短くする
      const titleDay = this.getSchedulerTitleEl();
      // mod カレンダー指定での指定日ジャンプに対応 陳 start
      // if (titleDay && this.viewMode === 2) {
      //   const titleDaySplit = titleDay.textContent.split("月");
      //   titleDay.innerHTML = `${titleDaySplit[0]}月`;
      // }
      if (titleDay && this.viewMode === 2) {
        const titleDaySplit = titleDay.textContent.split("月");
        titleDay.innerHTML = `${titleDaySplit[0]}月`;
        const selecttd = this.getSchedulerSelectedCell();
        if (selecttd?.firstElementChild?.title) {
          titleDay.innerHTML = selecttd.firstElementChild.title;
        } else if (this.baseDate) {
          // add カレンダー指定での指定日ジャンプに対応 陳 start
          titleDay.innerHTML = this.baseDate.format("YYYY年M月D日");
          // add カレンダー指定での指定日ジャンプに対応 陳 start
        }
      }
      // mod カレンダー指定での指定日ジャンプに対応 陳 end

      const styleMap = this.getSchedulerEventStyleMap();
      this.getSchedulerEventEls().filter((eventElement) => this.getSchedulerHeaderWrapEl()?.contains?.(eventElement)).forEach((eventElement) => {
        this.applySchedulerEventVisual(eventElement, styleMap, {
          useTextFallback: true,
          hideDummy: true
        });
      });

      this.getSchedulerEventEls().filter((eventElement) => this.getSchedulerContentEl()?.contains?.(eventElement)).forEach((eventElement) => {
        this.applySchedulerEventVisual(eventElement, styleMap);
      });

      this.$nextTick(() => {
        this.syncSchedulerTimeAxisRows();
        this.layoutAllDayEvents();

        //#9846 start
        this.onResize()
        //#9846 end
      });

      // DOMのネイティブpointerdownイベントリスナー追加
      // kendo schedulerの組み込みイベント(change)が優先されclickイベントが機能しないためイベントリスナーにpointerdownを追加する
      // kendo schedulerのchangeイベントだと集計イベントクリック以外の時も実行されるためpointerdownイベントで処理する
      this.bindSchedulerEventPointerdown();
    },
    groupEventItems(objectArray, property) {
      return objectArray.reduce((acc, obj) => {
        let key = obj[property];
        if (!acc[key]) {
          acc[key] = [];
        }
        acc[key].push(obj);
        return acc
      }, {})
    },
    parseSchedulerEventPayload(eventElement) {
      const contentElement = eventElement.querySelector('[data-event], [data-ntss-role="event-content"]');
      if (!contentElement) {
        return null;
      }
      const raw = contentElement.getAttribute("data-event");
      if (!raw) {
        return null;
      }
      try {
        return JSON.parse(raw);
      } catch (error) {
        return null;
      }
    },
    getAllDayEventSpaceHeight() {
      const allDayLabel = this.getSchedulerAllDayEl();
      if (!allDayLabel) {
        return 0;
      }
      const fontSize = parseFloat(getComputedStyle(allDayLabel).fontSize);
      return Number.isFinite(fontSize) ? 0.08 * fontSize : 0;
    },
    adjustAllDayEventElement(eventElement) {
      if (!eventElement || eventElement.dataset.ntssAllDaySized === "1") {
        return;
      }
      const width = eventElement.clientWidth;
      const left = eventElement.offsetLeft;
      const height = eventElement.clientHeight;
      eventElement.style.width = `${width + 7}px`;
      eventElement.style.left = `${left - 2}px`;
      eventElement.style.height = `${height + 4}px`;
      eventElement.dataset.ntssAllDaySized = "1";
    },
    adjustAllDayEventSizes(allDayEvents) {
      allDayEvents
        .filter((eventElement) => !eventElement.querySelector(".dummy-obj-hidden"))
        .forEach((eventElement) => this.adjustAllDayEventElement(eventElement));
    },
    clusterAllDayEventsByRow(allDayEvents) {
      const visibleEvents = allDayEvents.filter((eventElement) => {
        if (eventElement.querySelector(".dummy-obj-hidden")) {
          return false;
        }
        const payload = this.parseSchedulerEventPayload(eventElement);
        return !payload?.isAlternateDisplayColor;
      });
      if (!visibleEvents.length) {
        return [];
      }
      const sorted = [...visibleEvents].sort((a, b) => a.offsetTop - b.offsetTop);
      const rows = [];
      sorted.forEach((eventElement) => {
        const lastRow = rows[rows.length - 1];
        if (!lastRow || Math.abs(eventElement.offsetTop - lastRow.referenceTop) > 3) {
          rows.push({ referenceTop: eventElement.offsetTop, events: [eventElement] });
          return;
        }
        lastRow.events.push(eventElement);
      });
      return rows;
    },
    relayoutAllDayEventStack(allDayEvents, eventSpaceHeight) {
      this.adjustAllDayEventSizes(allDayEvents);
      const rows = this.clusterAllDayEventsByRow(allDayEvents);
      if (!rows.length) {
        return 0;
      }
      let currentTop = 0;
      let maxBottom = 0;
      rows.forEach(({ events }) => {
        const rowHeight = Math.max(
          ...events.map((eventElement) => eventElement.offsetHeight || 29)
        );
        events.forEach((eventElement) => {
          eventElement.style.marginTop = "0";
          eventElement.style.top = `${currentTop}px`;
        });
        maxBottom = Math.max(maxBottom, currentTop + rowHeight);
        currentTop += rowHeight + eventSpaceHeight;
      });
      return maxBottom > 0 ? maxBottom + eventSpaceHeight : 0;
    },
    layoutAllDayEvents() {
      if (this.viewMode !== 1 && this.viewMode !== 2) {
        return 0;
      }
      const allDayEvents = this.getSchedulerAllDayEventEls();
      if (!allDayEvents.length) {
        return 0;
      }
      return this.relayoutAllDayEventStack(
        allDayEvents,
        this.getAllDayEventSpaceHeight()
      );
    },
    computeAllDayLayoutMetrics() {
      if (this.viewMode !== 1 && this.viewMode !== 2) {
        return null;
      }
      const columnCount = this.viewMode === 1 ? 1 : 7;
      const vStart = dayjs(this.calendarSearchDate, "YYYY-MM-DD").isoWeekday(1);
      const seqNumList = {};
      seqNumList[vStart.format("YYYY-MM-DD")] = 0;
      for (let i = 1; i < 7; i++) {
        seqNumList[vStart.clone().add(i, "days").format("YYYY-MM-DD")] = i;
      }
      return {
        columnCount,
        seqNumList
      };
    },
    resolveLayoutEventColumnIndex(payload, metrics) {
      if (!payload?.start) {
        return -1;
      }
      const startDate = dayjs(payload.start);
      if (this.viewMode === 1) {
        return 0;
      }
      const dateKey = startDate.format("YYYY-MM-DD");
      if (metrics.seqNumList[dateKey] !== undefined) {
        return metrics.seqNumList[dateKey];
      }
      const vStart = dayjs(this.calendarSearchDate, "YYYY-MM-DD").isoWeekday(1);
      if (startDate.isBefore(vStart, "day")) {
        return 0;
      }
      return 6;
    },
    applySingleColumnAllDayLayout(eventElement, headerTemplateElement, anchorRight, col) {
      const headerCell = headerTemplateElement[col];
      if (!headerCell) {
        return;
      }
      const left = headerCell.getBoundingClientRect().left - anchorRight;
      eventElement.style.left = `${left}px`;
      eventElement.style.width = `${headerCell.getBoundingClientRect().width}px`;
    },
    applyLayoutCountEventPositions(allDayEvents, headerTemplateElement, objA, metrics, eventSpaceHeight) {
      if (!metrics) {
        return 0;
      }
      let crossDayBottom = 0;
      let sampleCrossDayHeight = 0;
      allDayEvents.forEach((eventElement) => {
        if (eventElement.querySelector(".dummy-obj-hidden")) {
          return;
        }
        const payload = this.parseSchedulerEventPayload(eventElement);
        if (payload?.isAlternateDisplayColor) {
          return;
        }
        crossDayBottom = Math.max(
          crossDayBottom,
          eventElement.offsetTop + eventElement.offsetHeight
        );
        if (!sampleCrossDayHeight && eventElement.offsetHeight) {
          sampleCrossDayHeight = eventElement.offsetHeight;
        }
      });
      const vaRowStep = (sampleCrossDayHeight || 29) + eventSpaceHeight;
      const anchorRight =
        objA?.parentElement?.previousElementSibling?.getBoundingClientRect()?.right ?? 0;
      const vaCountByCol = new Array(metrics.columnCount).fill(0);
      let contentBottom = crossDayBottom;
      allDayEvents.forEach((eventElement) => {
        if (eventElement.querySelector(".dummy-obj-hidden")) {
          return;
        }
        const payload = this.parseSchedulerEventPayload(eventElement);
        if (!payload?.isAlternateDisplayColor) {
          return;
        }
        const col = this.resolveLayoutEventColumnIndex(payload, metrics);
        if (col < 0 || col >= metrics.columnCount) {
          return;
        }
        const vaIndex = vaCountByCol[col]++;
        const targetTop = crossDayBottom + vaIndex * vaRowStep;
        this.applySingleColumnAllDayLayout(
          eventElement,
          headerTemplateElement,
          anchorRight,
          col
        );
        eventElement.style.marginTop = "0";
        eventElement.style.top = `${targetTop}px`;
        contentBottom = Math.max(
          contentBottom,
          targetTop + eventElement.offsetHeight
        );
      });
      return contentBottom > 0 ? contentBottom + eventSpaceHeight : 0;
    },
    updateSizeTable() {
      if (this.updateSizeTableProc) {
        clearInterval(this.updateSizeTableProc);
      }
      this.updateSizeTableProc = setInterval(() => {
        const schedulerRoot = this.getSchedulerRoot();
        if (!schedulerRoot) return;
        const widthContentDetail = this.getSchedulerHeaderAllDayEl();
        const marginTopContentDetail = this.getSchedulerHeaderWrapEl();
        const widthTableHeader = this.getSchedulerTableEls();
        if (
          !widthContentDetail ||
          !marginTopContentDetail ||
          widthTableHeader.length === 0
        ) {
          return;
        }
        const allDayEvents = this.getSchedulerAllDayEventEls();
        const widthTargetTable =
          widthTableHeader.find(Boolean) || widthTableHeader[0];
        if (widthTargetTable) {
          widthTargetTable.style.width = `${widthContentDetail.clientWidth}px`;
        }
        const headerChildren = marginTopContentDetail.children;
        if (headerChildren && headerChildren.length > 1) {
          headerChildren[1].style.marginTop =
            `${headerChildren[0].clientHeight}px`;
        }
        const objA = this.getSchedulerAllDayEl();
        const objB = this.getSchedulerHeaderAllDayEl();
        const headerTables = this.getSchedulerTableEls();
        if (!objA || !objB || !headerTables.length) {
          return;
        }
        const eventSpaceHeight = this.getAllDayEventSpaceHeight();
        const headerElement = headerTables[0];
        const headerTemplateElement = Array.from(
          headerElement.querySelectorAll(
            '.k-date-header-template, [data-ntss-role="date-header"]'
          )
        );
        const layoutMetrics = this.computeAllDayLayoutMetrics();
        const stackBottom = this.relayoutAllDayEventStack(
          allDayEvents,
          eventSpaceHeight
        );
        const vaContentBottom = this.applyLayoutCountEventPositions(
          allDayEvents,
          headerTemplateElement,
          objA,
          layoutMetrics,
          eventSpaceHeight
        );
        const areaHeight = Math.max(
          stackBottom,
          vaContentBottom,
          29 + eventSpaceHeight
        );
        if (objA.parentElement) {
          objA.parentElement.style.height = `${areaHeight}px`;
          if (objA.parentElement.previousElementSibling) {
            objA.parentElement.previousElementSibling.style.height =
              `${headerElement.offsetHeight}px`;
          }
        }
        if (objB) {
          const row = objB.querySelector?.('tr');
          if (row) {
            row.style.height = `${areaHeight}px`;
          }
        }
      }, 300);
    },
    // add FNSI-改修内容 権限関連 趙立強 start
    getTreatmentRecordAuthority() {
      return this.hasAuthority();
    },
    // add FNSI-改修内容 権限関連 趙立強 end
  },

  beforeUnmount() {
    EventBus.$off("updateConfigCurrentDate", this.updateCurrentDate);
    window.removeEventListener("beforeprint", this.handleBeforePrint);
    window.removeEventListener("afterprint", this.handleAfterPrint);
    this.clearHolidays(); // storeの休日マスタをクリア
    this.weekdays = null;
    this.nochanges = null;
    this.nochangesday = null;
    this.isPopoverVisible = null;
    this.popoverTarget = null;
    this.popoverContent = null;
    this.calendarArray = null;
    this.hours = null;
    this.currentViewDay = null;
    this.isLoadingBbs = null;
    this.message = null;
    this.paddingNumber = null;
    this.calendarSearchDate = null;
    this.hasTreatmentRecordAuthority = null;
    this.authorityCds = null;
    if (this.updateSizeTableProc) {
      clearInterval(this.updateSizeTableProc);
    }
    this.clearFacilityCalendarWindowValue("calendarDateClick", this.calendarDateClick);
    //施設カレンダー以外の画面に画面遷移する場合、ストアに保存されたカレンダー表示の日付をクリア
    if(!this.$route.fullPath.startsWith("/facility-calendar/")){
      this.setCalendarSearchDate(null);
      this.clearFacilityCalendarWindowValue("calendarSearchDateValue");
    }
    //#9846 start
    // 画面を閉じたときにイベントを除去
    EventBus.$off("onResize", this.onResize);
    //#9846 end
  }
};
</script>

<style lang="scss" scoped>
.calendarthis {
  display: flex;
  flex-direction: column;
  height: 100%;
  box-sizing: border-box;
}

.calnendar-header {
  user-select: none;
  z-index: 1;
  span {
    cursor: pointer;
  }
}

.current-month-button {
  display: inline-block;
  margin: 0 0 2px 5px;
}

.calendar-body {
  border-collapse: collapse;
  td {
    border: solid 1px rgba(64, 64, 66, 0.12);
    padding: 0;
  }
}

.calendar-workingday {
  // mod 障害票一覧_施設カレンダー 修正 chen start
  color: #e4e4e4;
  background-color: #414141;
  //color: white;
  //background-color: rgba(65, 65, 65, 0.6);
  // mod 障害票一覧_施設カレンダー 修正 chen end
  text-align: center;
  border-right: 1px solid rgba(255, 255, 255, 0.4);
}

.calendar-sat {
  // mod 障害票一覧_施設カレンダー 修正 chen start
  //color: white;
  //background-color: rgba(0, 60, 255, 0.5);
  color: var(--ntss-saturday-color);
  background-color: #414141;
  // mod 障害票一覧_施設カレンダー 修正 chen end
  text-align: center;
  border-right: 1px solid rgba(255, 255, 255, 0.4);
}

.calendar-sun {
  // mod 障害票一覧_施設カレンダー 修正 chen start
  //color: white;
  //background-color: rgba(255, 0, 0, 0.3);
  color: var(--ntss-sunday-color);
  background-color: #414141;
  // mod 障害票一覧_施設カレンダー 修正 chen end
  text-align: center;
  border-right: 1px solid rgba(255, 255, 255, 0.4);
}

.calendar-weekday {
  // mod 障害票一覧_施設カレンダー 修正 chen start
  color: #e4e4e4;
  background-color: #414141;
  text-align: center;
  border-right: 1px solid rgba(255, 255, 255, 0.4);
  &:nth-of-type(7n-1) {
    color: var(--ntss-saturday-color);
  }
  &:nth-of-type(7n) {
    color: var(--ntss-sunday-color);
  }
  //color: white;
  //background-color: rgba(65, 65, 65, 0.6);
  //text-align: center;
  //border-right: 1px solid rgba(255, 255, 255, 0.4);
  //&:nth-of-type(7n-1) {
  //  background-color: rgba(0, 60, 255, 0.5);
  //}
  //&:nth-of-type(7n) {
  //  background-color: rgba(255, 0, 0, 0.3);
  //}
  // mod 障害票一覧_施設カレンダー 修正 chen start
}

.calendar-date {
  // mod 施設イベントの施設カレンダー背景色 修正 chen start
  color:#ffffff;
  padding: 0.25em 0;
  display: flex;
  justify-content: center;
  align-items: center;
  //background-color: rgba(0, 195, 255, 0.3);
  background-color:#666666;
  &-Today {
    //background-color: rgba(83, 255, 40, 0.3);
    background-color: #2ca06f;
  }
  &-OtherMonth {
    //background-color: rgba(255, 216, 40, 0.3);
    background-color: #444444;
  }
  // mod 施設イベントの施設カレンダー背景色 修正 chen end

  background-image: none !important;
  &-Saturday {
    color: var(--ntss-saturday-color);
  }
  &-Sunday {
    color: var(--ntss-sunday-color);
  }
  &-Holiday {
    color: var(--ntss-holiday-color);
  }
}

.calendar-content-week {
  min-height: 80vh;
}

.calendar-content {
  text-align: left;
  overflow-y: auto;
  p {
    &:nth-of-type(odd) {
      background-color: rgba(76, 172, 252, 0.2);
    }
    &:nth-of-type(even) {
      background-color: rgba(177, 219, 253, 0.2);
    }
    &:hover {
      background-color: rgba(25, 150, 252, 0.301);
    }
  }
  @media screen and (min-height: 813px) {
    min-height: 120px;
    &::-webkit-scrollbar {
      width: 8px;
    }
    &::-webkit-scrollbar-track {
      background: rgba(255, 255, 255, 0.4);
      border: none;
      border-radius: 10px;
      box-shadow: inset 0 0 2px #777;
    }
    &::-webkit-scrollbar-thumb {
      background: #ccc;
      border-radius: 10px;
      box-shadow: none;
    }
  }
  @media screen and (max-height: 812px) {
    min-height: 60px;
  }
  @media screen and (max-height: 568px) {
    min-height: 40px;
  }
}

.calendar-content-item {
  padding: 0.25em 0;
  margin: 0;
  // del FNSI-改修内容 施設カレンダー バグ 1行で表示されるべきものが複数行に分かれる  dou start
  // white-space: nowrap;
  // del FNSI-改修内容 施設カレンダー バグ 1行で表示されるべきものが複数行に分かれる  dou end
  overflow-x: hidden;
  // mod 一行で表示しきれない文字列は折り返す 陳 start
  //text-overflow: ellipsis;
  word-break: break-all;
  // mod 一行で表示しきれない文字列は折り返す 陳 end
  border-radius: 0.25rem;
  border: thin solid  var(--master-maintenance-kgrid-border-color) !important;
  margin-bottom: 1px;
  cursor: pointer;
  &-link {
    // mod 障害票一覧_施設カレンダー 修正 chen start
    //color: black;
    color: var(--ntss-base-color);
    // mod 障害票一覧_施設カレンダー 修正 chen start
    line-height: 20px;
    margin-left: 3px;
  }
}

thead,
tbody {
  display: block;
  vertical-align: top;

  tr {
    display: table;
    width: calc(100% - 2px);
    table-layout: fixed;
  }
}

.time {
  width: 60px;
  height: 50px;
  white-space: nowrap;
  text-align: center;
  float: left;
  display: flex;
  justify-content: center;
  align-items: center;
  border: solid 1px rgba(64, 64, 66, 0.12);
  border-bottom: 0;
  border-right: 0;
}

.scheduleContent {
  width: calc(100% - 61px);
  float: left;
}

.scheduleContent div {
  min-width: 100%;
  min-height: 25px;
  border: solid 1px rgba(64, 64, 66, 0.12);
  border-bottom: 0;
}

thead {
  position: sticky;
  top: 0;
}

.content-popover :deep(.popover__content) {
  width: 300px;
  height: 200px;
  font-size: 1.5em;
  padding: 5px;
  overflow-y: auto;
}

.content-popover-content {
  margin: 5px;
  font-size: 1.2em;
}

.current-month-button :deep(.button) {
  padding: 0 10px;
  font-size: 1em;
}

.nested-content,
.nested-day {
  color: royalblue;
  background-color: var(--ntss-list-background-color);
  white-space: pre-line;
}

.nested-day {
  padding-left: 62px;
  white-space: normal !important;
  border-bottom: thin solid var(--master-maintenance-kgrid-border-color);
}

.a {
  position: relative;
}

.scheduleContent p{
  position: absolute;
  top: calc(1273 / 24 * 2px);
  height: calc(1273 / 24 * 4px);
  width: calc(1844/7 * 1px) !important;
  margin-left: calc((1844/7*0) * 1px);
  width: 100%;
  padding: 0;
  margin: 0;
}

.calendar-date-baseday {
  outline: 3px solid #1a71cc;
  outline-offset: -3px;
}

/* 週間カレンダー用のスタイル */
.facility-full-calendar {
  z-index: 0;
  overflow: auto;
  height: 100%;
}
/* .facility-full-calendar 配下の kendo-scheduler の内部 DOM に対するスタイルは scoped を貫通させる */
.facility-full-calendar :deep() {
  tr:first-of-type .k-scheduler-times-all-day table.k-scheduler-table tr:first-of-type th,
  tr:first-of-type .k-scheduler-times table.k-scheduler-table tr:first-of-type th {
    font-size: 0.2em;
  }

  table.k-scheduler-table th {
    background-image: unset;
  }
  > div > table > tbody > tr:nth-child(1) > td:nth-child(2) > div > div > .k-scheduler-table {
    position: fixed;
    width: calc(100% - 4em);
    z-index: 100;
  }
  > div > table > tbody > tr:nth-child(1) > td:nth-child(2) > div > div > div {
    position: relative;
  }
  // del カレンダー指定での指定日ジャンプに対応 陳 start
  //.k-nav-current {
  //  pointer-events: none;
  //}
  // kendo-scheduler の日付表示とボタンを非表示にする
  .k-nav-current,
  .k-nav-today {
    display: none;
  }
  // del カレンダー指定での指定日ジャンプに対応 陳 start
  .k-widget {
    border-width: 0px !important;
    font-size: unset;
  }
  .k-scheduler-toolbar {
    position: sticky !important;
    top: 0 !important;
    z-index: 10000 !important;
    padding: 2px !important;
    min-height: 2.4em;
    background-color: var(--main-background-color) !important;
    overflow: visible !important;
    isolation: isolate;
  }
  .k-scheduler-navigation {
    position: absolute;
    right: 0;
    top: 2px;
    display: flex !important;
    z-index: 10001 !important;
  }
  .k-nav-prev {
    right: unset !important;
    left: unset !important;
  }
  .k-nav-next {
    right: unset !important;
    left: unset !important;
  }
  .k-scheduler-navigation .k-nav-prev,
  .k-scheduler-navigation .k-nav-next {
    position: static !important;
    display: inline-flex !important;
    align-items: center;
    justify-content: center;
    width: 36px;
    min-width: 36px;
    height: 2em;
    padding: 0 !important;
    color: var(--ntss-base-color) !important;
    visibility: visible !important;
    opacity: 1 !important;
  }
  .k-scheduler-navigation .k-nav-prev .k-svg-icon,
  .k-scheduler-navigation .k-nav-next .k-svg-icon,
  .k-scheduler-navigation .k-nav-prev svg,
  .k-scheduler-navigation .k-nav-next svg {
    display: block !important;
    width: 1em !important;
    height: 1em !important;
    fill: currentColor !important;
    color: inherit !important;
  }
  .today-button,
  .today-button:hover {
    background-color: #4291B9;
    color: white;
    border: none;
    // add FutreNetWeb+SI課題管理 4023 修正 chen start
    margin-left: 5px;
    // add FutreNetWeb+SI課題管理 4023 修正 chen end
  }
  .k-scheduler,
  .k-scheduler-layout,
  .k-scheduler-header,
  .k-scheduler-header-wrap {
    background-color: var(--main-background-color);
    color: var(--ntss-base-color);
  }
  .k-scheduler > .k-scheduler-layout {
    position: relative;
    z-index: 1;
  }
  .k-scheduler-toolbar,
  .k-scheduler-toolbar .k-toolbar,
  .k-scheduler-header,
  .k-scheduler-header-wrap,
  .k-scheduler-times-all-day,
  .k-scheduler-times-all-day .k-scheduler-table,
  .k-scheduler-header-wrap .k-scheduler-table {
    min-height: 0;
  }
  .k-scheduler-times,
  .k-scheduler-times-all-day {
    width: 63px;
    min-width: 63px;
    max-width: 63px;
  }
  .k-scheduler-times .k-scheduler-table,
  .k-scheduler-times-all-day .k-scheduler-table {
    width: 63px;
  }
  .k-scheduler-times th,
  .k-scheduler-times-all-day th {
    width: 63px;
    min-width: 63px;
    max-width: 63px;
    padding-left: 0;
    padding-right: 0;
  }
  .k-date-header-template,
  [data-ntss-role="date-header"] {
    line-height: 19.5px;
  }
  .k-date-header-template li,
  [data-ntss-role="date-header"] li,
  .calendar-date-title,
  .calendar-date-number {
    height: 19.5px;
    min-height: 19.5px;
    line-height: 19.5px;
    padding: 0;
    box-sizing: border-box;
  }
  .calendar-workingday,
  .calendar-sat,
  .calendar-sun {
    padding: 0;
    background-color: #414141;
    text-align: center;
    border-right: 1px solid rgba(255, 255, 255, 0.4);
  }
  .calendar-workingday {
    color: #e4e4e4;
  }
  .calendar-sat {
    color: var(--ntss-saturday-color);
  }
  .calendar-sun {
    color: var(--ntss-sunday-color);
  }
  .calendar-date-number {
    font-weight: normal;
    background-color: #414141;
  }
  .k-scheduler-layout td.k-state-selected {
    background-color: unset;
  }
  /*add FNSI-改修内容黒系レイアウトの際に日付、時刻の枠が見えない。 全 start*/
  .k-scheduler table, .k-scheduler thead, .k-scheduler tfoot, .k-scheduler tbody, .k-scheduler tr, .k-scheduler th, .k-scheduler td, .k-scheduler div, .k-scheduler > * {
    border-color: #CCCCCC;
  }
  /*add FNSI-改修内容黒系レイアウトの際に日付、時刻の枠が見えない。 全 end*/
  .k-scheduler.k-scheduler-dayview,
  .k-scheduler.k-scheduler-weekview,
  .k-scheduler.k-scheduler-workWeekview {
    .k-scheduler-header {
      > .k-scheduler-header-wrap {
        .calendar-date-number {
          background-color: #414141 !important;
          color:#ffffff;
        }
        .k-scheduler-table > tbody > tr > td {
          padding: 0;
        }
        .k-scheduler-table > tbody > tr > th {
          padding: 0;
        }
        .k-scheduler-table > tbody > tr > th > ul > li:last-child {
          font-weight: normal;
          background-color: #414141;
        }
        .k-scheduler-table > tbody > tr > .k-today > ul > li:last-child{
          background-color: #2ca06f !important;

        }
        .calendar-workingday {
          padding: 0;
          // mod 障害票一覧_施設カレンダー 修正 chen start
          //color: white;
          //background-color: rgba(65, 65, 65, 0.6);
          // mod 障害票一覧_施設カレンダー 修正 chen end
          color: #e4e4e4;
          background-color: #414141;
          text-align: center;
          border-right: 1px solid rgba(255, 255, 255, 0.4);
        }

        .calendar-sat {
          padding: 0;
          // mod 障害票一覧_施設カレンダー 修正 chen start
          //color: white;
          //background-color: rgba(0, 60, 255, 0.5);
          // mod 障害票一覧_施設カレンダー 修正 chen end
          color: var(--ntss-saturday-color);
          background-color: #414141;
          text-align: center;
          border-right: 1px solid rgba(255, 255, 255, 0.4);
        }

        .calendar-sun {
          padding: 0;
          // mod 障害票一覧_施設カレンダー 修正 chen start
          //color: white;
          //background-color: rgba(255, 0, 0, 0.3);
          // mod 障害票一覧_施設カレンダー 修正 chen end
          color: var(--ntss-sunday-color);
          background-color: #414141;
          text-align: center;
          border-right: 1px solid rgba(255, 255, 255, 0.4);
        }
        .calendar-date-OtherMonth {
          background-color: #414141 !important;
        }
        .calendar-date-Saturday {
          color: var(--ntss-saturday-color) !important;
        }
        .calendar-date-Sunday {
          color: var(--ntss-sunday-color) !important;
        }
        .calendar-date-Holiday {
          color: var(--ntss-holiday-color) !important;
        }
        .calendar-date-baseday {
          outline: 3px solid #1a71cc;
          outline-offset: -3px;
        }
      }
    }
    .k-scheduler-content {
      .k-event-top-actions {
        top: 0 ;
        position: absolute;
        width: 100%;
        text-align: center;
      }

      .k-event-bottom-actions {
        position: absolute;
        width: 100%;
        text-align: center;
        top: auto;
        bottom: 0;
      }
    }
    .k-scheduler-times-all-day,
    .k-scheduler-times {
      .k-scheduler-table > tbody > tr:nth-child(2) > th {
        height: calc(4px + 0.08em);
      }
    }
    .k-scheduler-content {
      .k-scheduler-table > tbody > tr:nth-child(1) > td {
        height: calc(4px + 0.08em);
      }
    }
    tbody > tr:nth-child(1) > td:nth-child(2) {
      height: calc(29px + 0.08em);
    }
  }
  .k-event .k-event-actions:first-child {
    margin: unset;
  }
  .k-event .k-event-actions {
    visibility: unset;
    opacity: 1;
  }
  .k-event {
    border: thin solid  var(--master-maintenance-kgrid-border-color) !important;
    color: var(--ntss-base-color);
    padding-right: 0;
    display: flex;
    flex-direction: row;
    cursor: pointer;
  }
  .k-scheduler-header-wrap .k-event {
    align-items: center;
  }
  .k-scheduler-header-wrap [data-ntss-role="all-day-event-wrapper"] {
    flex: 1 1 auto;
    min-width: 0;
    overflow: hidden;
  }
  .k-scheduler-header-wrap .k-event .k-event-actions:last-child {
    position: relative;
    inset: unset;
    flex-shrink: 0;
  }
  .k-event.k-state-selected {
    box-shadow: unset;
  }
  .k-event.k-event-inverse:hover {
    background-color: rgba(25, 150, 252, 0.301) !important;
  }
  .scheduler-event-template,
  .k-event-template {
    white-space: nowrap;
    overflow-x: hidden;
    text-overflow: ellipsis;
    font-size: unset;
  }
  .k-scheduler-toolbar {
    background-color: var(--main-background-color);
    border-color: var(--master-maintenance-kgrid-border-color);
    color: var(--master-maintenance-kgrid-body-color);
    position: sticky !important;
    top: 0 !important;
    z-index: 10000 !important;
    min-height: 2.4em;
    overflow: visible !important;
    isolation: isolate;
    .k-scheduler-views {
      display: none;
    }
    .k-scheduler-navigation {
      height: 2em;
      display: flex;
      justify-content: center;
      align-items: center;
      position: absolute !important;
      right: 0 !important;
      top: 0;
      z-index: 10001 !important;
      .k-nav-today {
        order: 2;
        border-radius: .25rem;
      }
      .k-nav-prev {
        border-radius: .25rem 0 0 .25rem;
        position: static;
        left: unset;
      }
      .k-nav-next {
        position: static;
        left: unset;
      }
    }
  }
  .k-sm-date-format,
  .k-icon.k-i-calendar {
    display: none;

  }
  .k-lg-date-format {
    display: block;
    font-size: 1.2em;
    text-align: center;
    -webkit-user-select: none;
    -moz-user-select: none;
    -ms-user-select: none;
    user-select: none;
    color: gray;;
  }
  [data-ntss-role="date-header"],
  .k-date-header-template {
    padding: 0;
    margin: 0;
    list-style: none;
  }
  [data-ntss-role="date-header"] li,
  .k-date-header-template li {
    min-height: 19.5px;
  }
  .k-scheduler-footer {
    display: none;
  }
}

// ユーザーがモバイルを使用するときに「kendo scheduler」ライブラリの編集に影響しないようにスクロールバーをカスタマイズする
/* width */
// del 4150 スクロールバーが他の画面と異なり、細い。他の画面との統一をお願いします。 吉 start-->
/*::-webkit-scrollbar {*/
/*  width: 8px;*/
/*}*/
// del 4150 スクロールバーが他の画面と異なり、細い。他の画面との統一をお願いします。 吉 end-->

/* Track */
::-webkit-scrollbar-track {
  background: #f1f1f1;
}

/* Handle */
::-webkit-scrollbar-thumb {
  background: #888;
}
/* Handle on hover */
::-webkit-scrollbar-thumb:hover {
  background: #555;
}
/*add FNSI-改修内容redmain5059 范 start*/
@media screen and (max-width: 600px){
  .scroll-thead{
    width: 600px;
  }
  .scroll-tbody{
    width: 600px;
  }
}
/*add FNSI-改修内容redmain5059 范 end*/

@media print {
  /** 月 */
  .scroll-thead {
    position: relative;
  }

  /** 週、日 */
  .facility-full-calendar {
    height: auto !important;
    overflow: visible !important;
  }
  .facility-full-calendar :deep() {
    > div > table > tbody > tr:nth-child(1) > td:nth-child(2) > div > div > .k-scheduler-table {
      position: relative !important;
      width: 100% !important;
    }
    > div > table > tbody > tr:nth-child(1) > td:nth-child(2) > div > div > div {
      margin-top: 0 !important;
    }
  }
  .facility-full-calendar :deep(.k-scheduler-header-wrap .k-scheduler-table) {
    position: relative !important;
    width: 100% !important;
  }
  .facility-full-calendar :deep(.k-scheduler-header-wrap) {
    margin-top: 0 !important;
  }
  .facility-full-calendar :deep(.k-scheduler-toolbar) {
    display: none !important;
  }
  .facility-full-calendar :deep(.k-scheduler-content),
  .facility-full-calendar :deep(.k-scheduler-layout) {
    width: 100%;
    overflow: visible !important;
    height: auto !important;
  }
  .facility-full-calendar :deep(.k-scheduler-table) {
    width: 100% !important;
  }
  .facility-full-calendar :deep(.k-event) {
    height: auto !important;
    overflow: hidden !important;
  }
  .facility-full-calendar :deep(.k-scheduler-dayview .k-event) {
    width: 91vw !important;
  }
  .facility-full-calendar :deep(.k-scheduler-weekview .k-event:not(.k-event-inverse)),
  .facility-full-calendar :deep(.k-scheduler-workWeekview .k-event:not(.k-event-inverse)) {
    width: 100% !important;
  }
  .facility-full-calendar :deep(.k-scheduler-weekview .k-event.k-event-inverse .k-event-template),
  .facility-full-calendar :deep(.k-scheduler-workWeekview .k-event.k-event-inverse .k-event-template) {
    width: 11.5vw;
    min-width: 0;
    display: block !important;
    overflow: hidden !important;
  }
  .facility-full-calendar :deep(.k-scheduler-weekview .k-event.k-event-inverse),
  .facility-full-calendar :deep(.k-scheduler-workWeekview .k-event.k-event-inverse) {
    max-width: 100% !important;
  }
  .scrollTopFixed {
    display: none !important;
  }

  /** 表示年月日を中央に配置 */
  .calnendar-header {
    position: relative !important;
    display: flex;
    width: 100%;
    top: 0;
  }
  .left-margin-area {
    width: 45%;
  }
}
</style>

<style scoped>
.facility-calendar-area :deep(button.calendar) {
  box-shadow: unset;
}

:deep(.k-scheduler-cell){
  padding:0!important;
}
:deep(.k-scheduler-header-wrap .k-scheduler-cell){
  /* padding:0!important; */
  padding-top:0!important;
  padding-bottom:0!important;
  padding-inline:unset!important;
}



:deep(.k-scheduler-cell  .calendar-date-number){
	/*background-color: #414141 !important;*/
  background-color: #666 !important;
  color:#fff!important;
}
:deep(.k-scheduler-cell  .calendar-date-OtherMonth){
	background-color: #414141 !important;
  color:#fff!important;
}




:deep(.k-scheduler-cell .calendar-date-Saturday){
  color: var(--ntss-saturday-color)!important;
}
:deep(.k-scheduler-cell .calendar-date-Sunday){
  color: var(--ntss-sunday-color)!important;
}


:deep(.k-today .calendar-date-number){
	background-color: #2ca06f !important;
}

:deep(.calendar-date-baseday){
	outline: 3px solid #1a71cc;
  outline-offset: -3px;
}




:deep(.k-scheduler-table .k-scheduler-cell li){
  min-height: 22.5px!important;
  line-height: 22.5px!important;
}



.scrollTopFixed{
  position: sticky;
  height: 36px;
  background: var(--main-background-color);
  top: 0;
  width: 100%;
  z-index: 10002;
  display: flex;
  justify-content: flex-end;
  margin-bottom: -36px;
  pointer-events: none;
}
.scheduler-fixed-nav-button {
  width: 36px;
  height: 36px;
  border: 1px solid #dfe3e7;
  border-radius: 0;
  background: #e4e7eb;
  box-shadow: none;
  pointer-events: auto;
  position: relative;
  padding: 0;
}
.scheduler-fixed-nav-button:hover {
  background: #d8dde3;
}
.scheduler-fixed-nav-button::before {
  content: "";
  position: absolute;
  top: 50%;
  left: 50%;
  width: 0;
  height: 0;
  transform: translate(-50%, -50%);
  border-top: 4px solid transparent;
  border-bottom: 4px solid transparent;
}
.scheduler-fixed-nav-prev::before {
  border-right: 6px solid #111;
}
.scheduler-fixed-nav-next::before {
  border-left: 6px solid #111;
}
.facility-full-calendar :deep(.k-scheduler-navigation){
  display: none !important;
}
.facility-full-calendar :deep(.k-scheduler-navigation button){
  background: #e4e7eb!important;
  box-shadow: none!important;
  border-radius:2px;
}


:deep(.k-scheduler-body .k-scheduler-content .k-scheduler-cell){
  height: calc(2.5px + 3em);
}
:deep(.k-scheduler-body .k-scheduler-times .k-scheduler-cell){
  text-align: center !important;
  vertical-align: middle !important;
  color:#333333;
  font-weight: bold!important;
  padding-top: 0 !important;
  padding-bottom: 0 !important;
  padding-right: 0 !important;
}


:deep(.k-scheduler-table td, .k-scheduler-table th){
  padding-top:0!important;
  padding-bottom:0!important;
  padding-inline:unset!important;
}
:deep(.k-scheduler-body .k-scheduler-content){
  overflow: hidden;
}

:deep(.k-scheduler-layout td.k-selected, .k-scheduler-layout .k-scheduler-cell.k-selected){
  background: none!important;
}
:deep(.k-scheduler-body .k-scheduler-content .k-svg-i-caret-alt-up){
  display: none!important;
}
:deep(.k-scheduler-body .k-scheduler-content .k-svg-i-caret-alt-down){
  display: none!important;
}





</style>
