<template>
  <div v-if="baseDate !== null" class="calendarthis">
    <div class="calnendar-header">
      <div class="left-margin-area"></div>
      <div class="facility-calendar-area" style="display: flex; justify-content: center; flex-wrap: nowrap; align-items: center;">
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
    <div v-if="viewMode !== 3" class="facility-full-calendar" style="height: 100%; overflow: auto">
      <kendo-scheduler ref="fullCalendar"
                       :selectable="true"
                       :editable="false"
                       :footer-command="false"
                       :data-source="showEvent"
                       :current-time-marker="false"
                       :allDayEventTemplate="allDayEventTemplate"
                       :eventTemplate="eventTemplate"
                       :dateHeaderTemplate="dateHeaderTemplate"
                       :major-time-header-template="timeHeaderTemplate"
                       :workWeekStart="1"
                       :workWeekEnd="7"
                       :workDayStart="new Date('2013/1/1 12:00 AM')"
                       :workDayEnd="new Date('2013/1/1 11:59 PM')"
                       :resources="resourceData"
                       :dataBound="onDataBound"
                       @navigate="onNavigate"
      >
        <kendo-scheduler-view type="day" :selected="viewMode===1"></kendo-scheduler-view>
        <kendo-scheduler-view type="week" :selected="viewMode===2"></kendo-scheduler-view>
      </kendo-scheduler>
      <script id="date-header-template" type="text/x-kendo-template">
        #if(date.getDate() === 1){#
        <ul class="k-date-header-template" onclick="window.calendarDateClick('#=kendo.toString(date,'yyyy-MM-dd')#')">
          <li date="#:date#" class="calendar-date-title">
            #:kendo.toString(date, 'ddd')#
          </li>
          #if(kendo.toString(date, 'yyyy-MM-dd') === calendarSearchDateValue){#
            <li if date="#:date#" class="calendar-date-number calendar-date-baseday">
              #:kendo.toString(date, 'yyyy/M/d')#
            </li>
          #}else{#
            <li if date="#:date#" class="calendar-date-number">
              #:kendo.toString(date, 'yyyy/M/d')#
            </li>
          #}#
        </ul>
        #}else{#
        <ul class="k-date-header-template" onclick="window.calendarDateClick('#=kendo.toString(date,'yyyy-MM-dd')#')">
          <li date="#:date#" class="calendar-date-title">
            #:kendo.toString(date, 'ddd')#
          </li>
          #if(kendo.toString(date, 'yyyy-MM-dd') === calendarSearchDateValue){#
            <li date="#:date#" class="calendar-date-number calendar-date-baseday">
              #:kendo.toString(date, 'M/d')#
            </li>
          #}else{#
            <li date="#:date#" class="calendar-date-number">
              #:kendo.toString(date, 'M/d')#
            </li>
          #}#
        </ul>
        #}#
      </script>
      <!-- 終日予定エリアのカスタムTemplate -->
      <script id="allday-event-template" type="text/x-kendo-template">
        <div style="overflow: hidden;height: fit-content;"
             #if(typeof description != 'undefined'){#
               class="#:description#"
             #}#>
          <div
            title="#:title#"
            class="k-event-template"
            data-event='{
              "title": "#:title#",
              "start": "#:start#",
              "routerLink": #if (typeof routerLink !== "undefined") {# "#:routerLink#" #} else {# null #} #,
              "color": "#:color#",
              "id": "#:id#",
              "categoryName": #if (typeof categoryName !== "undefined") {# "#:categoryName#" #} else {# null #} #,
              "subCategoryName": #if (typeof subCategoryName !== "undefined") {# "#:subCategoryName#" #} else {# null #} #,
              "itemName": #if (typeof itemName !== "undefined") {# "#:itemName#" #} else {# null #} #
            }'>
            #:title#
          </div>
        </div>
      </script>
      <!-- #9838 mod 20260427 yangxuewang start -->
      <script id="event-template" type="text/x-kendo-template">
        <div
           title="#:title#"
           class="event-item"
           data-event='{
             "title": "#:title#",
             "start": "#:start#",
             "routerLink": #if (typeof routerLink !== "undefined") {# "#:routerLink#" #} else {# null #} #,
             "color": "#:color#",
             "id": "#:id#",
             "categoryName": #if (typeof categoryName !== "undefined") {# "#:categoryName#" #} else {# null #} #,
             "subCategoryName": #if (typeof subCategoryName !== "undefined") {# "#:subCategoryName#" #} else {# null #} #,
             "itemName": #if (typeof itemName !== "undefined") {# "#:itemName#" #} else {# null #} #
           }'>
          #:title#
        </div>
        <style>
          .event-item {
            word-break:break-all;
          }
        </style>
      </script>
       <!-- #9838 mod 20260427 yangxuewang end -->

      <script id="time-header-template" type="text/x-kendo-template">
        #:kendo.toString(date, 'H:mm')#
      </script>

    </div>
    <v-ons-popover
      v-if="isPopoverVisible"
      :visible.sync="isPopoverVisible"
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
import moment from "moment";
import { EventBus } from "@/eventBus.js";
import {mapActions, mapGetters} from "vuex";
import PopoverMixin from "@/components/PopoverMixin";
import VueTouch from "vue-touch";
import {
  createCalendarMonth,
  createCalendarWeek,
  splitCalendarArrayByWeek,
} from "@/components/common/contents-calendar/Functions.js";
import { SchedulerInstaller } from '@progress/kendo-scheduler-vue-wrapper'
import '@progress/kendo-ui/js/cultures/kendo.culture.ja-JP.js'
import Kendo from "@progress/kendo-ui";
import Vue from "vue";
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
import DateInput from "@/components/common/DateInput";

Kendo.culture("ja-JP");
Kendo.culture().calendar.firstDay = 1;
Vue.use(VueTouch);
Vue.use(SchedulerInstaller)

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

    /**
     * 親コンポーネントで保持しているデータ読込済み期間
     * 例：{ start: "20260101", end: "20260331" }
     */
    loadedDateRange: {
      type: Object,
      default: () => ({
        start: null,
        end: null
      })
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
      baseDate: moment(),
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
      eventExistsList: []
    };
  },

  watch: {
    calendarSearchDate(value) {
      if (!value) {
        return;
      }
      window.calendarSearchDateValue = this.calendarSearchDate;
      if (this.stopWatchFlg) {
        this.stopWatchFlg = false;
        return;
      }
      if (this.viewMode === 3) {
        // 月
        this.calendarArray = splitCalendarArrayByWeek(
          createCalendarMonth(moment(this.calendarSearchDate, "YYYY-MM-DD"))
        );
        this.createCalendarContents();
        this.baseDate = moment(this.calendarSearchDate, "YYYY-MM-DD");
        this.addWeeksToCalendar(3);

        // 読込済みのデータをリセットする為に、データ読込済み期間をクリアする
        this.requestClearLoadedDateRange();

        this.moveCurrentMonthForDate();

      } else if (this.viewMode === 2 || this.viewMode === 1) {
        const kendoFullCalendar = this.$refs.fullCalendar.kendoWidget();
        kendoFullCalendar.date(new Date(this.calendarSearchDate));
        this.onNavigate({ action: "changeDate" });
      }
      EventBus.$emit("getSelectedDate", this.calendarSearchDate);
    },
    contents() {
      this.createCalendarContents();
      this.baseDate = moment(this.calendarSearchDate, "YYYY-MM-DD");
      this.$forceUpdate();
    },
    viewMode(value) {
      // 日付が初期化される為、当日を表示日付に設定
      this.stopWatchFlg = true;
      if(this.getCalendarSearchDate){
        this.calendarSearchDate = this.getCalendarSearchDate;
      } else {
        this.calendarSearchDate = moment(new Date(), "YYYY-MM-DD").format("YYYY-MM-DD");
      }
      this.$nextTick(() => {
        // 同日の場合、watch処理が動作せず、stopWatchFlgフラグが true のままになるので戻しておく
        this.stopWatchFlg = false;
      });
      if (this.$refs.fullCalendar) {
        const kendoFullCalendar = this.$refs.fullCalendar.kendoWidget();
        if (value === 1) {
          kendoFullCalendar.view('day');
          kendoFullCalendar.date(new Date(this.baseDate));
        }
        if (value === 2) {
          kendoFullCalendar.view('week');
          kendoFullCalendar.date(new Date(this.baseDate));
        }
      }
      // add/  #12614 施設カレンダーでデータが出ない tianqidong start
      this.moveToMonth(this.calendarSearchDate)
      // add/  #12614 施設カレンダーでデータが出ない tianqidong end
      //月タブ選択時に施設カレンダー生成
      this.initLayout();
      this.baseDate = moment(this.calendarSearchDate, "YYYY-MM-DD");
      EventBus.$emit("getSelectedDate", this.calendarSearchDate);
    },
    searchedBbsList(newHoge, oldHoge) {
      if (this.viewMode === 2 || this.viewMode === 1) {
        // 週、日表示時のみ、初期表示時にresourcesデータが反映されない為、再読み込みを実施する
        let scheduler = this.$refs.fullCalendar.kendoWidget();
        scheduler.resources[0].dataSource.data(this.resourceData[0].dataSource);
        scheduler.view(scheduler.view().name);
      }
    }

  },

  async created() {
    this.setLoadingScreenMessage("処理中...");
    this.setLoadingScreenVisible(true);
    this.hasTreatmentRecordAuthority = this.getTreatmentRecordAuthority();
    for (let i = 0; i < 24; i++) {
      this.hours.push(i);
    }
    await sendRequestGetPatEventCateMst().then(res => {
      getDataPatEventCateMst(
        res.data.localDataSource.data.filter(item => +item.isDisp)
      );
    });
    await sendRequestGetPatSubEventCateMst().then(res => {
      getDataPatSubEventCateMst(
        res.data.localDataSource.data.filter(item => +item.isDisp)
      );
    });
    if(this.getCalendarSearchDate){
      this.calendarSearchDate = this.getCalendarSearchDate;
      this.baseDate = moment(this.calendarSearchDate, "YYYY-MM-DD");
    } else {
      this.calendarSearchDate = moment(new Date(), "YYYY-MM-DD").format("YYYY-MM-DD");
      this.baseDate = moment();
    }

    // 休日マスタの休日を取得
    await this.fetchHolidays(this.facilityCd);

    EventBus.$on("updateConfigCurrentDate", this.updateCurrentDate);
    window.calendarDateClick = this.calendarDateClick;
    this.setLoadingScreenVisible(false);
  },

  async mounted() {
    //月タブ選択時に施設カレンダー生成
    await this.initLayout();
    //施設カレンダーのサイズ調整
    this.updateSizeTable();

    window.addEventListener("beforeprint", this.handleBeforePrint);
    window.addEventListener("afterprint", this.handleAfterPrint);
  },

  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
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

    showEvent() {
      const vStart = moment(this.calendarSearchDate, "YYYY-MM-DD").isoWeekday(1);
      let clonevStart = null;
      let dummyMatrix = [[0,0,0,0,0,0,0]];
      // 日付の範囲から配列番号を格納
      let seqNumList = [];
      seqNumList[vStart.format("YYYY-MM-DD")] = 0;
      for(let i = 1; i < 7; i++) {
        clonevStart = vStart.clone();
        seqNumList[clonevStart.add(i, "days").format("YYYY-MM-DD")] = i;
      }
      const listEvent = [];
      this.searchedBbsList.forEach(list => {
        /*  mod FNSI-434 改修内容 施設カレンダのみに表示 趙立強 start*/
        const startTime = list.notice_fac_cal_start_time.slice(0,2) + ":" + list.notice_fac_cal_start_time.slice(2);
        const endTime =list.notice_fac_cal_end_time.slice(0,2) + ":" + list.notice_fac_cal_end_time.slice(2);
        // const startTime = moment(list.notice_fac_cal_start_date).format('YYYY-MM-DD');
        // const endTime = moment(list.notice_fac_cal_end_date).format('YYYY-MM-DD');
        const startDateObj = moment(list.notice_fac_cal_start_date);
        const endDateObj = moment(list.notice_fac_cal_end_date);
        const startTitleDate = startDateObj.format('YYYY/MM/DD');
        const endTitleDate = endDateObj.format('YYYY/MM/DD');
        // 複数日のイベントの場合は、開始日を00:00:00に設定して、並び順を上に寄せる
        const startDate = endDateObj.diff(startDateObj, "days") > 0 ? startDateObj.format('YYYY-MM-DD') + " 00:00:00" : startDateObj.format('YYYY-MM-DD') + " " +startTime + ":00";
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
        listEvent.push(eventItem);

        // ダミー作成の為、表示位置を配列に格納する(週表示時のみ実施)
        if(endDateObj.diff(startDateObj, "days") > 0 && this.viewMode === 2) {
          let dispDays = 0;
          let stNum = 0;
          if (vStart.isAfter(startDateObj) && vStart.isSameOrBefore(endDateObj)) {
            // 表示期間前から開始されるイベントの格納処理
            dispDays = endDateObj.diff(vStart, "days");
            stNum = seqNumList[vStart.format("YYYY-MM-DD")];
            dummyMatrix = this.addDummyMatrix(dispDays, stNum, dummyMatrix);
          } else if (vStart.isSameOrBefore(startDateObj)) {
            // 表示期間中に開始されるイベントの格納処理
            dispDays = endDateObj.diff(startDateObj, "days");
            stNum = seqNumList[startDateObj.format("YYYY-MM-DD")];
            dummyMatrix = this.addDummyMatrix(dispDays, stNum, dummyMatrix);
          }
        }
      });

      // 並び順制御用のダミーイベントを追加する
      let dummyList = [];
      dummyMatrix.forEach(line => {
        if (line.indexOf(1) == -1) {
          // イベントが存在しない行の為処理をスキップする
          return;
        }
        for(let add = 0; add < line.length; add++) {
          if (line[add] < 1) {
            // 空いている部分(0)の日付をリストに格納する
            clonevStart = vStart.clone()
            // TODO dummyList.push(clonevStart.add(add, "days").format("YYYY-MM-DD"));
            dummyList.push(clonevStart.add(add, "days").format("YYYY/MM/DD"));
          }
        }
      });
      dummyList.forEach(dm => {
        listEvent.push({
          color: "#ffffff",
          // TODO start: new Date(dm + " 00:00:00"),
          start: new Date(dm),
          end: new Date(dm),
          isAllDay: true,
          title: "",
          description: "dummy-obj-hidden"
        });
      });

      this.contents.forEach((item, indexItem) => {
        // YYYY-MM-DDフォーマットで new Dateすると、09:00:00 の時刻になってしまう為、フォーマットを修正
        const date = moment(item.date).format('YYYY/MM/DD');
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
          let date = moment(eventItem.start).format('YYYY/MM/DD');
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
      if(this.calendarSearchDate){
        const d = new Date(this.calendarSearchDate);
        const day = d.getDay();
        const monday = d.getDate() - (day === 0 ? 6 : (day - 1));
        d.setDate(monday);
        let targetDate = moment(d).format("YYYY/MM/DD");
        let eventExistsList = [];
        for(let index = 0;index <= 6;index++){
          if(groupByDateMap[targetDate]){
            eventExistsList.push(index);
          }
          const currentDate = new Date(targetDate);
          currentDate.setDate(currentDate.getDate() + 1);
          targetDate = moment(currentDate).format("YYYY/MM/DD");
        }
        this.eventExistsList = eventExistsList;
      }
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
        return moment(this.calendarSearchDate).format('YYYY/MM/DD');
      }
      return "";
    },
    /**
     * データ読込済み期間を返す
     * 親コンポーネントが保持しているデータ読込済み期間(loadedDateRange)があればその期間を返却し、
     * 無ければthis.baseDateから算出した期間を返却する。
     *
     * @return {{ minMonth: データ読込済み期間の最古月の月初(moment), maxMonth: データ読込済み期間の最新月の月初(moment) }}
     */
    contentsMonthRange() {
      // データ読込済み期間が取得できない場合、
      if (!this.loadedDateRange?.start || !this.loadedDateRange?.end) {
        // this.baseDateからデータ読込済み期間を算出
        const range = getDateRangeForSearchCondition(this.baseDate, null, null);
        return {
          minMonth: moment(range.start, "YYYYMMDD").startOf("month"),
          maxMonth: moment(range.end, "YYYYMMDD").startOf("month")
        };
      }

      return {
        minMonth: moment(this.loadedDateRange.start, "YYYYMMDD").startOf("month"),
        maxMonth: moment(this.loadedDateRange.end, "YYYYMMDD").startOf("month")
      };
    },
  },
  methods: {
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
      const scheduler = this.$refs.fullCalendar?.kendoWidget();
      if (!scheduler) return;

      const el = this.$refs.fullCalendar.$el;

      // 元の幅を退避
      this._originalWidth = el.style.width;
      // 週の場合は固定幅で位置再計算
      el.style.width = "1024px";
      if (scheduler.view().name !== "day") {
        scheduler.resize();
      }
    },

    handleAfterPrint() {
      const scheduler = this.$refs.fullCalendar?.kendoWidget();
      if (!scheduler) return;

      const el = this.$refs.fullCalendar.$el;

      // 元に戻す
      el.style.width = this._originalWidth || "";
      if (scheduler.view().name !== "day") {
        scheduler.resize();
      }
    },

    updateCurrentDate(viewMode) {
      this.$nextTick(async () => {
        if (this.$refs.fullCalendar) {
          const kendoFullCalendar = this.$refs.fullCalendar.kendoWidget();
          if (viewMode === 1) {
            await kendoFullCalendar.date(new Date(this.baseDate));
          }
          if (viewMode === 2) {
            await kendoFullCalendar.date(new Date(this.baseDate));
          }
        }
      })
    },
    onNavigate(params) {
      // 表示日付の更新処理
      if (typeof params.date !== "undefined" && (this.viewMode === 1 ||  this.viewMode === 2) && params.action != "changeDate") {
        this.stopWatchFlg = true;
        this.calendarSearchDate = moment(params.date).format("YYYY-MM-DD");
        this.$nextTick(() => {
          this.stopWatchFlg = false;
          this.saveInputDate();
        });
      }
      EventBus.$emit("updateDateFollowScreen", params.action);
    },
    async initLayout() {
      if (this.viewMode === 3) { // 月
        if(this.getCalendarSearchDate){
          this.calendarSearchDate = this.getCalendarSearchDate;
          this.calendarArray = splitCalendarArrayByWeek(
            createCalendarMonth(moment(this.calendarSearchDate, "YYYY-MM-DD"))
          );
          await this.createCalendarContents();
          this.addWeeksToCalendar(3);
          this.moveCurrentMonthForDate();
        } else {
          this.calendarArray = splitCalendarArrayByWeek(
            createCalendarMonth(moment())
          );
          await this.createCalendarContents();
          this.addWeeksToCalendar(3);
          this.moveCurrentMonth();
        }
      }
    },
    moveToMonth(date) {
      this.$emit("update:baseDate", moment(date, "YYYYMMDD"));
    },

    moveCurrentMonth() {
      if (this.viewMode === 3) {
        // 月表示時
        this.calendarSearchDate = moment().startOf("month").format("YYYY-MM-DD");

        // 当月の第1週を取得
        const week = [...this.$refs.calendarBody.querySelectorAll("[id]")].find(
          i =>
            moment(i.id, "YYYYMMDD").isoWeek() ===
            moment()
              .startOf("month")
              .isoWeek() && moment(i.id, "YYYYMMDD").year() === moment().year()
        );
        if (week) {
          week.scrollIntoView();
          this.$refs.calendarBody.scrollTop -= this.$refs.calendarBody.querySelector(
            "thead"
          ).clientHeight;
          this.$emit("update:baseDate", moment());
        }
      } else {
        this.calendarSearchDate = moment().format("YYYY-MM-DD");
      }
    },
    moveCurrentMonthForDate() {
      if (this.$refs.calendarBody.scrollTop === 1) return;
      let isoWeekTmp = moment(this.calendarSearchDate, "YYYY-MM-DD").isoWeek();
      let isoWeekStart = moment(this.calendarSearchDate, "YYYY-MM-DD").isoWeekday(1).format('YYYY-MM-DD');
      let yearTmp = moment(isoWeekStart, "YYYY-MM-DD").isoWeekYear();

      this.$nextTick(() => {

        // 当月の第1週を取得
        const week = [...this.$refs.calendarBody.querySelectorAll("[id]")].find(
          i => moment(i.id, "YYYYMMDD").isoWeek() === isoWeekTmp &&
            moment(i.id, "YYYYMMDD").isoWeekYear() === yearTmp
        );
        if (week) {
          week.scrollIntoView();
          this.$refs.calendarBody.scrollTop -= this.$refs.calendarBody.querySelector(
            "thead"
          ).clientHeight;
          this.$emit("update:baseDate", moment(this.calendarSearchDate, "YYYY-MM-DD"));
        }
      });
    },

    calendarDate(date) {
      const className = "calendar-date";
      const today = moment().startOf("date");
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
      // #9838 mod 20260427 yangxuewang start
      const eventElement = targetElement.querySelector(".k-event-template, .event-item");
      // #9838 mod 20260427 yangxuewang end
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
      this.onClickLink(eventItem, moment(eventData.start), eventElement);
    },

    /**
     * @description カレンダーの各日付押下時の処理
     * @param {String} date 日付(YYYY-MM-DD形式)
     */
    calendarDateClick(date){
      EventBus.$emit("createEvent", date);
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
              ({ date }) => date === day.dateObj.format("YYYYMMDD")
            );
          });
        });
      }
    },

    /**
     * @description スクロールイベントにより、月の切り替えを行う
     */
    scrollHandler() {
      const e = this.$refs.calendarBody;
      const isScrolledTop = e.scrollTop === 0;
      const isScrolledBottom =
        Math.abs(e.scrollTop + e.clientHeight - e.scrollHeight) < 4;
      // 要素(DOMオブジェクト)全体が表示されているかチェック
      const isScrolledIntoMonth = elem => {
        const parentTop = e.scrollTop;
        const parentBottom = parentTop + e.clientHeight;
        const elemTop = elem.offsetTop;
        const elemBottom = elemTop + elem.clientHeight;
        return elemBottom <= parentBottom && elemTop >= parentTop;
      };

      if (this.viewMode === 3) {
        // 週/月カレンダー
        // スクロール位置チェック
        if (isScrolledTop) {
          this.addWeeksToCalendar(-1);
          e.scrollTop = e.querySelector("tbody tr").clientHeight;
        } else if (isScrolledBottom) {
          this.addWeeksToCalendar(1);
        }
      }

      // 月半ば(15日)が見えるようになる時、月を切り替える
      if (this.viewMode === 3) {
        let currentMonthElem = [...e.querySelectorAll("[id]")].find(
          i =>
            moment(i.id, "YYYYMMDD").isoWeek() ===
            moment(i.id, "YYYYMMDD")
              .date(15)
              .isoWeek() && isScrolledIntoMonth(i)
        );

        if (currentMonthElem) {
          // データ読込済み期間の最古月・最新月を取得
          const { minMonth, maxMonth } = this.contentsMonthRange;
          // 判定対象の月初を取得
          const hitMonth = moment(currentMonthElem.id, "YYYYMMDD").startOf("month");

          // 最古月・最新月との差分(月)を取得
          const diffMin = hitMonth.diff(minMonth, "months");
          const diffMax = hitMonth.diff(maxMonth, "months");

          // 判定対象がデータ読込済み期間の最古月以前または最新月以後なら表示月を切替える(月切替によりデータ読込が発火する)
          if (diffMin <= 0 || diffMax >= 0) {
            // 親のcurrentDateを更新し、月を切り替える
            this.moveToMonth(currentMonthElem.id);
          }
        }
      }
    },

    /**
     * @description ○週間をカレンダーに追加
     * @param {Number} numWeeks 週数
     */
    addWeeksToCalendar(numWeeks) {
      const isAddToEndOfCalendar = numWeeks > 0;
      const baseDate = isAddToEndOfCalendar
        ? moment(
          this.calendarArray[this.calendarArray.length - 1][0].dateObj
        ).add(1, "week")
        : moment(this.calendarArray[0][0].dateObj).add(numWeeks, "week");

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
        : moment(date).format("YYYYMMDD");
    },

    /**
     * @description 日付の文字列取得(YYYY-MM-DD形式)
     * @param {Date} date 日付
     */
    revertDate(date) {
      return date === null || date === ""
        ? null
        : moment(date).format("YYYY-MM-DD");
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
      // 月表示で「今月」ボタン押下の場合
      if (this.viewMode === 3) {
        // 読込済みのデータをリセットする為に、データ読込済み期間をクリアする
        this.requestClearLoadedDateRange();
      }

      this.moveCurrentMonth();
      this.saveInputDate();
    },
    /**
     * @description カレンダー表示の日付の保存
     */
    saveInputDate() {
      this.setCalendarSearchDate(this.calendarSearchDate);
    },
    eventTemplate: function(e) {
      const template = Kendo.template(Kendo.jQuery('#event-template').html())
      return template(e);
    },

    dateHeaderTemplate: function(e) {
      const template = Kendo.template(Kendo.jQuery('#date-header-template').html())
      return template(e);
    },

    allDayEventTemplate: function(e) {
      const template = Kendo.template(Kendo.jQuery('#allday-event-template').html())
      return template(e);
    },

    // #9569 掲示板の時刻表示が不正 zhou.tao Add Start
    timeHeaderTemplate: function(e) {
      const template = Kendo.template(Kendo.jQuery('#time-header-template').html());
      return template(e);
    },
    // #9569 掲示板の時刻表示が不正 zhou.tao Add End

    onDataBound() {
      // 今週のものの色と高さを変更する
      const weekDays = document.getElementsByClassName("calendar-date-title");
      if (weekDays && weekDays.length > 0) {
        let addClass = "calendar-workingday";
        for (let i = 0; i < weekDays.length; i++) {
          let textToday = weekDays[i];
          if (textToday.textContent.includes("土")) {
            addClass = "calendar-sat";
          }
          if (textToday.textContent.includes("日")) {
            addClass = "calendar-sun";
          }
          textToday?.classList?.add(addClass);
        }
      }
      // 奇数月/偶数月の色を設定します
      const dateNumbers = document.getElementsByClassName("calendar-date-number");
      if (dateNumbers && dateNumbers.length > 0) {
        var checkHoliday = this.getHolidays;
        for (let i = 0; i < dateNumbers.length; i++) {
          let textToday = dateNumbers[i];
          let dateAttr = textToday.getAttribute("date");
          let momentDate = moment(new Date(dateAttr));
          if (momentDate.month() % 2) {
            textToday?.classList?.add("calendar-date-OtherMonth");
          }
          if (momentDate.day() === 6) {
            textToday?.classList?.add("calendar-date-Saturday");
          }
          if (momentDate.day() === 0) {
            textToday?.classList?.add("calendar-date-Sunday");
          }
          if(checkHoliday[momentDate.format("YYYY-MM-DD")] != null){
            textToday?.classList?.add("calendar-date-Holiday");
          }
        }
      }
      // [今日]ボタンの英語を日本語に変更する
      const btnToday = document.getElementsByClassName("k-nav-today")[0];
      if (btnToday) {
        btnToday.getElementsByTagName("a")[0].innerHTML = this.titleCurrentDayButton;
        btnToday.getElementsByTagName("a")[0].title = "";
        btnToday?.classList?.add("today-button");
      }
      const btnPrev = document.getElementsByClassName("k-nav-prev")[0];
      if (btnPrev) {
        btnPrev.getElementsByTagName("a")[0].title = "前";
      }
      const btnNext = document.getElementsByClassName("k-nav-next")[0];
      if (btnNext) {
        btnNext.getElementsByTagName("a")[0].title = "次";
      }

      const allDaySlot = document.getElementsByClassName("k-scheduler-times-all-day")[0];
      if (allDaySlot) {
        allDaySlot.innerHTML = "";
      }
      // 日を短くする
      const titleDay = document.getElementsByClassName("k-lg-date-format")[0];
      // mod カレンダー指定での指定日ジャンプに対応 陳 start
      // if (titleDay && this.viewMode === 2) {
      //   const titleDaySplit = titleDay.textContent.split("月");
      //   titleDay.innerHTML = `${titleDaySplit[0]}月`;
      // }
      if (titleDay && this.viewMode === 2) {
        const titleDaySplit = titleDay.textContent.split("月");
        titleDay.innerHTML = `${titleDaySplit[0]}月`;
        const selecttd = document.getElementsByClassName("k-state-hover k-state-selected k-state-focused")[0];
        if (selecttd) {
          titleDay.innerHTML = selecttd.firstElementChild.title;
        } else {
          // add カレンダー指定での指定日ジャンプに対応 陳 start
          if (this.baseDate) {
            titleDay.innerHTML = this.baseDate.format("YYYY年M月D日");
          }
          // add カレンダー指定での指定日ジャンプに対応 陳 start
        }
      }
      // mod カレンダー指定での指定日ジャンプに対応 陳 end

      // 終日ツールチップイベントを削除
      const allDayEvent = document.querySelectorAll(".k-scheduler-header-wrap .k-event");
      if (allDayEvent) {
        for (let i = 0, length = allDayEvent.length; i < length; i++) {
          const event = allDayEvent[i];
          if (event) {
            /*  add FNSI-437 改修内容 施設イベントの施設カレンダー背景色指定の色調整掲示板への色反映 趙立強 start*/
            this.searchedBbsList.forEach(list => {
              const startTitleDate = moment(list.notice_fac_cal_start_date).format('YYYY/MM/DD');
              const endTitleDate = moment(list.notice_fac_cal_end_date).format('YYYY/MM/DD');
              const startTime = list.notice_fac_cal_start_time.slice(0,2) + ":" + list.notice_fac_cal_start_time.slice(2);
              const endTime =list.notice_fac_cal_end_time.slice(0,2) + ":" + list.notice_fac_cal_end_time.slice(2);
              const eventItem = {
                title: `${startTime} - ${startTitleDate} ～ ${endTitleDate} ${list.kindName}: ${list.title || "タイトルなし"} - ${endTime}`,
                color: list.color,
                font_color: list.font_color
              };
              if(eventItem.title === event.textContent.replace(/\r?\n/g, '').trim()){

                event.style.color = eventItem.font_color;
              }

            });
            /*  add FNSI-437 改修内容 施設イベントの施設カレンダー背景色指定の色調整掲示板への色反映 趙立強 end*/
            event.querySelector("div").removeAttribute("title");
            // 並び順調整用のダミーイベントを非表示にする
            const dummyObj = event.querySelector(".dummy-obj-hidden");
            if (dummyObj) {
              event.style.visibility = "hidden";
            }
          }
        }
      }

      const schedulerContent = document.querySelectorAll(".k-scheduler-content")[0];
      if (schedulerContent) {
        const eventArr = schedulerContent.querySelectorAll(".k-event");
        if (eventArr && eventArr.length) {
          for (let i = 0, length = eventArr.length; i < length; i++) {
            const title = eventArr[i].querySelector("div").getAttribute("title");
            eventArr[i].setAttribute('title', title);
            /*  add FNSI-437 改修内容 施設イベントの施設カレンダー背景色指定の色調整掲示板への色反映 趙立強 start*/
            this.searchedBbsList.forEach(list => {
              const startTitleDate = moment(list.notice_fac_cal_start_date).format('YYYY/MM/DD');
              const endTitleDate = moment(list.notice_fac_cal_end_date).format('YYYY/MM/DD');
              const startTime = list.notice_fac_cal_start_time.slice(0,2) + ":" + list.notice_fac_cal_start_time.slice(2);
              const endTime =list.notice_fac_cal_end_time.slice(0,2) + ":" + list.notice_fac_cal_end_time.slice(2);
              const eventItem = {
                title: `${startTime} - ${startTitleDate} ～ ${endTitleDate} ${list.kindName}: ${list.title || "タイトルなし"} - ${endTime}`,
                color: list.color,
                font_color: list.font_color
              };
              if(eventItem.title === title){

                eventArr[i].style.color = eventItem.font_color;
              }

            });
            /*  add FNSI-437 改修内容 施設イベントの施設カレンダー背景色指定の色調整掲示板への色反映 趙立強 start*/
            eventArr[i].querySelector("div").removeAttribute("title");
          }
        }

      }
      // add  FNSI redmine 5383修正 関 start
      const eventInverse = document.getElementsByClassName("k-event");
      for (let i = 0; i < eventInverse.length; i++){
        eventInverse[i].style.width = `${eventInverse[i].clientWidth + 7}px`;
        eventInverse[i].style.left = `${eventInverse[i].offsetLeft - 2}px`;
        //  add 6932 【デグレ】週表示と日表示の時間表示と遷移が不正 関 start
        eventInverse[i].style.height = `${eventInverse[i].clientHeight + 4}px`;
        //  add 6932 【デグレ】週表示と日表示の時間表示と遷移が不正 関  end
      }
      // add  FNSI redmine 5383修正 関　end

      // DOMのネイティブpointerdownイベントリスナー追加
      // kendo schedulerの組み込みイベント(change)が優先されclickイベントが機能しないためイベントリスナーにpointerdownを追加する
      // kendo schedulerのchangeイベントだと集計イベントクリック以外の時も実行されるためpointerdownイベントで処理する
      document.querySelectorAll(".k-event").forEach(element => {
        element.removeEventListener("pointerdown", this.onClickEvent);
        element.addEventListener("pointerdown", (event) => {
          // マウスの場合は左クリックのみ処理
          if (event.button === 0) {
            this.onClickEvent(event);
          }
        });
      });
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
    updateSizeTable() {
      this.updateSizeTableProc = setInterval(() => {
        const widthContentDetail = document.getElementsByClassName(
          "k-scheduler-header-all-day"
        );
        const widthTableHeader = document.getElementsByClassName(
          "k-scheduler-table"
        );
        const marginTopContentDetail = document.getElementsByClassName(
          "k-scheduler-header-wrap"
        );
        if (
          widthContentDetail.length > 0 &&
          widthTableHeader.length > 0 &&
          marginTopContentDetail.length > 0
        ) {
          const arrEvent = marginTopContentDetail[0].getElementsByClassName("k-event");
          widthTableHeader[1].style.width = `${widthContentDetail[0].clientWidth}px`;
          marginTopContentDetail[0].children[1].style.marginTop = `${marginTopContentDetail[0].children[0].clientHeight}px`;
          const itemGroup = this.groupEventItems([...arrEvent], "offsetTop");
          //画面上の左端のエリアの要素の取得
          const objA = document.getElementsByClassName("k-scheduler-times-all-day");
          //イベント要素の表示エリアの要素の取得
          const objB = document.getElementsByClassName("k-scheduler-header-all-day");
          const headerElement = marginTopContentDetail[0].getElementsByClassName("k-scheduler-table");
          //高さ調整後の各イベント要素間の隙間の高さ(0.08em)
          const eventSpaceHeight = 0.08 * parseFloat(getComputedStyle(objA[0]).fontSize);
          // mod/  #12614 施設カレンダーでデータが出ない tianqidong start
          /*let headerTemplateElement = Array.from(headerElement[0].getElementsByClassName("k-date-header-template")).filter((item,index) => {
            return this.eventExistsList.includes(index);
          });
          Object.keys(itemGroup).forEach((key, index) => {
            let columnIndex = -1;
            itemGroup[key].forEach(obj => {
              columnIndex++;
              //obj.style.left = parseFloat(headerTemplateElement[columnIndex].getBoundingClientRect().left)
              //- parseFloat(objA[0].parentElement.previousElementSibling.getBoundingClientRect().right) + "px";
              //obj.style.width = parseFloat(headerTemplateElement[columnIndex].getBoundingClientRect().width) + "px";
              /*if(index > 0 && parseFloat(getComputedStyle(obj).marginTop) === 0){
                //週/日の施設イベント間の隙間の高さ調整(デフォルトの各イベント要素間の隙間の高さ - 高さ調整後の各イベント要素間の隙間の高さ)
                obj.style.marginTop = - index * (Number(Object.keys(itemGroup)[1]) - Number(itemGroup[0][0].offsetHeight) - eventSpaceHeight) + "px";
              }
            });
          });*/
          // mod/  #12614 施設カレンダーでデータが出ない tianqidong end
          let areaHeight = 0;
          // 週/日の上部予定表示時エリアの高さ調整
          if (Object.keys(itemGroup).length > 0) {
            // 予定部品の高さ
            const itemHeight = itemGroup[0][0].offsetHeight;
            const len = Object.keys(itemGroup).length;
            const lastTop = Object.keys(itemGroup)[len - 1];
            // エリアに設定する高さ(一番下の要素の開始位置 + イベント要素の高さ + 各イベント要素間の隙間の高さ)
            areaHeight = Number(lastTop) + Number(itemHeight) + eventSpaceHeight;
          } else{
            // 予定部品の高さ
            const itemHeight = 29;
            // エリアに設定する高さ(イベント要素の高さ + 各イベント要素間の隙間の高さ)
            areaHeight = Number(itemHeight) + eventSpaceHeight;
          }
          //画面上の左端のエリアの高さの調整
          if (objA.length) {
            objA[0].parentElement.style.height = areaHeight + "px";
            objA[0].parentElement.previousElementSibling.style.height = headerElement[0].offsetHeight + "px";
          }
          //イベント要素の表示エリアの高さの調整
          if (objB.length) {
            objB[0].getElementsByTagName("tr")[0].style.height = areaHeight + "px";
          }
        }
      }, 300);
    },
    // add FNSI-改修内容 権限関連 趙立強 start
    getTreatmentRecordAuthority() {
      return this.hasAuthority();
    },
    // add FNSI-改修内容 権限関連 趙立強 end
    addDummyMatrix(dispDays, stNum, dummyMatrix) {
      let addLineFlg = true;
      for (let line = 0; line < dummyMatrix.length; line++) {
        let fitInFlg = true;
        // lineに格納可能か確認
        for (let ia = 0; ia <= dispDays; ia++) {
          if (stNum + ia > 6) {
            // 表示期間外になるので、処理を抜ける
            break;
          }
          if (dummyMatrix[line][stNum + ia] == 1) {
            fitInFlg = false;
          }
        }
        // 格納可能な場合は、格納して処理を抜ける
        if (fitInFlg) {
          for (let ib = 0; ib <= dispDays; ib++) {
            if (stNum + ib > 6) {
              // 表示期間外になるので、処理を抜ける
              break;
            }
            dummyMatrix[line][stNum + ib] = 1;
          }
          addLineFlg = false;
          break;
        }
      }
      if (addLineFlg) {
        // どのlineにも収まらなかった場合は、新しくlineを追加してそこに格納する
        dummyMatrix[dummyMatrix.length] = [0,0,0,0,0,0,0];
        for (let ic = 0; ic <= dispDays; ic++) {
          if (stNum + ic > 6) {
            // 表示期間外になるので、処理を抜ける
            break;
          }
          dummyMatrix[dummyMatrix.length - 1][stNum + ic] = 1;
        }
      }
      return dummyMatrix;
    },
    /**
     * データ読込済み期間のクリア要求を親に通知する
     */
    requestClearLoadedDateRange() {
      // 親コンポーネントにクリア要求を通知
      this.$emit("request-clear-loaded-date-range");
    },
  },

  beforeDestroy() {
    EventBus.$off("updateConfigCurrentDate", this.updateCurrentDate);
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
    window.calendarDateClick = null;
    //施設カレンダー以外の画面に画面遷移する場合、ストアに保存されたカレンダー表示の日付をクリア
    if(!this.$router.currentRoute.fullPath.startsWith("/facility-calendar/")){
      this.setCalendarSearchDate(null);
      window.calendarSearchDateValue = null;
    }

    window.removeEventListener("beforeprint", this.handleBeforePrint);
    window.removeEventListener("afterprint", this.handleAfterPrint);
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

.content-popover >>> .popover__content {
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

.current-month-button >>> .button {
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
.facility-full-calendar /deep/ {
  z-index: 0;
  overflow: auto;
  height: 100%;

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
    position: sticky;
    top: 0;
    z-index: 9;
    padding: 2px !important;
  }
  .k-nav-prev {
    right: 36px !important;
    left: unset !important;
  }
  .k-nav-next {
    right: 0 !important;
    left: unset !important;
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
  .k-scheduler-layout,
  .k-scheduler-header,
  .k-scheduler-header-wrap {
    background-color: var(--main-background-color);
    color: var(--ntss-base-color);
  }
  .k-scheduler-layout td.k-state-selected {
    background-color: unset;
  }
  /*add FNSI-改修内容黒系レイアウトの際に日付、時刻の枠が見えない。 全 start*/
  .k-scheduler table, .k-scheduler thead, .k-scheduler tfoot, .k-scheduler tbody, .k-scheduler tr, .k-scheduler th, .k-scheduler td, .k-scheduler div, .k-scheduler>* {
    border-color: #CCCCCC;
  }
  /*add FNSI-改修内容黒系レイアウトの際に日付、時刻の枠が見えない。 全 end*/
  .k-scheduler-dayview,
  .k-scheduler-weekview {
    .k-scheduler-header {
      > .k-scheduler-header-wrap {
        .calendar-date-number {
          background-color: #666666 !important;
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
          background-color: rgba(0, 195, 255, 0.3)
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
          background-color: #444444 !important;
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
  .k-event-actions {
    visibility: unset;
    opacity: 1;
  }
  .k-event {
    border: thin solid  var(--master-maintenance-kgrid-border-color) !important;
    color: var(--ntss-base-color);
    padding-right: 0;
    display: flex;
    flex-direction: row;
    // del #9625 deng start
    // align-items: center;
    // del #9625 deng end
    // del 6932 【デグレ】週表示と日表示の時間表示と遷移が不正 関 start
    // height: auto !important;
    // del 6932 【デグレ】週表示と日表示の時間表示と遷移が不正 関  end
    cursor: pointer;
  }
  .k-event.k-state-selected {
    box-shadow: unset;
  }
  .k-event.k-event-inverse:hover {
    background-color: rgba(25, 150, 252, 0.301) !important;
  }
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
    .k-scheduler-views {
      display: none;
    }
    .k-scheduler-navigation {
      height: 2em;
      display: flex;
      justify-content: center;
      align-items: center;
      position: relative;
      .k-nav-today {
        order: 2;
        border-radius: .25rem;
      }
      .k-nav-prev {
        border-radius: .25rem 0 0 .25rem;
        position: absolute;
        left: 0;
      }
      .k-nav-next {
        position: absolute;
        left: 36px;
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
  .k-date-header-template {
    padding: 0;
    margin: 0;
    list-style: none;
  }
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
  .facility-full-calendar /deep/ {
    > div > table > tbody > tr:nth-child(1) > td:nth-child(2) > div > div > .k-scheduler-table {
      position: relative;
      width: 100% !important;
    }
    > div > table > tbody > tr:nth-child(1) > td:nth-child(2) > div > div > div {
      margin-top: 0 !important;
    }
    .k-scheduler-toolbar {
      top: 0;
      position: absolute;
    }

    /* スクロール解除 */
    .k-scheduler-content,
    .k-scheduler-layout {
      width: 100%;
      overflow: visible !important;
      height: auto !important;
    }
    .k-scheduler-table {
      width: 100% !important;
    }
    .k-scheduler-table td,
    .k-event {
      height: auto !important;
      overflow: hidden !important;
    }
    /** 日のみ */
    .k-scheduler-dayview .k-event {
      width: 91vw !important;
    }
    /* flex崩れ防止 週のみ */
    .k-scheduler-weekview .k-event:not(.k-event-inverse) {
      width: 100% !important;
    }
    /* 文字省略対策 週のみ */
    .k-scheduler-weekview .k-event.k-event-inverse .k-event-template {
      width: 11.5vw;
      min-width: 0;
      display: block !important;
      overflow: hidden !important; /* 横はみ出し隠す */
    }
    .k-scheduler-weekview .k-event.k-event-inverse {
      max-width: 100% !important;
    }

  }
  /** 表示年月日を中央に配置 */
  .close-class-wd-for-calendar .calnendar-header {
    width: 100%;
    top: 0;
  }
  .close-class-wd-for-calendar .left-margin-area {
    width: 45%;
  }
}
</style>

<style scoped>
.facility-calendar-area >>> button.calendar {
  box-shadow: unset;
}
</style>
