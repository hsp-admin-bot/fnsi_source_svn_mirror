<template>
  <div v-if="baseDate !== null" class="calendar">
    <!-- 表示年月日、今日ボタン、新規登録ボタン エリア -->
    <div class="calnendar-header">
      <div class="common-calendar-area" :style="{marginLeft: commonCalendarAreaLeft + 'px', marginTop: commonCalendarAreaTop + 'px', flexWrap: calendarInputFlexWrap}" style="display: flex; flex-flow: nowrap; align-items: center;">
        <div class="calendar-content-input">
          <date-input
            v-model="dateToday"
            :classes="'input-area ntss-input-date ntss-custom-input'"
            isRequired
          />
          <common-calendar v-model="dateToday" style="height:30px"/>
        </div>
        <div class="current-month-button">
          <v-ons-button @click="moveToday" id="button-today" class="btn3-normal" style="min-width: 3.5em;">今日</v-ons-button>
          <div style="position: relative; margin-left: 5px;">
            <v-ons-button class="btn3-normal" style="min-width: 5em;"
                          :disabled="patEventViewPermissionOnly || !selectedIdAndPatEventPermission" @click="createNewFromNewBtn">新規登録</v-ons-button>
          </div>
        </div>
    <!-- add カレンダー指定での指定日ジャンプに対応 江 start -->
      </div>
      <div class="right-margin-area" style="width: 100%;"></div>
    <!-- add カレンダー指定での指定日ジャンプに対応 江 end -->
    </div>
    <!-- カレンダー表示エリア -->
    <div ref="calendarBody" style="height: calc(100% - 2.2em); overflow: auto;" @scroll="scrollHandler">
      <table class="calendar-body">
        <thead ref="thead">
          <tr>
            <th
              v-for="weekday in weekdays"
              :key="weekday"
              class="calendar-weekday"
            >
              {{ weekday }}
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="(week, i) in calendarArray"
            :id="week[0].dateObj.format('YYYYMMDD')"
            :key="i"
          >
            <td
              v-for="({ dateObj, content }, j) in week"
              :key="`week${i}date${j}`"
            >
              <div class="calendar-container">
                <!-- 日付 -->
                <div
                  style="display: flex; align-items: center; justify-content: center;"
                  :class="calendarDate(dateObj)"
                  @click="handleChangeDateExpandFlg(dateObj)"
                >
                  <div class="date-date" @click.stop="createNewFromCalendar(dateObj)">
                    {{ dateFormatter(dateObj) }}
                  </div>
                </div>
                
                <!-- 項目表示 -->
                <div class="calendar-content">
                  <template v-if="content && content.type === 'items'">
                    <div v-for="(category) in content.items" :key="category.layoutCategoryKey">
                      <!-- 親要素 category.isDispGroupがtrueの場合は表示 -->
                      <span 
                        v-if="category.isDispGroup && category.expandFlg" 
                        class="triangles" 
                        :class="[{
                          'calendar-content-parent-other': !isRstClass(category),
                          'calendar-content-parent-rst': isRstClass(category)
                        }]"
                      >
                        <span @click="handleChangeTriangleDirection(category.layoutCategoryKey, content.date)">
                          <span class="categoryTriangles" v-if="category.triangleDirection == 'top'" >▼</span>
                          <span class="categoryTriangles" v-else>▶</span>
                          <span>{{category.layoutCategoryTitle}}</span>
                        </span>
                      </span>
                      <!-- 子要素 -->
                      <template v-for="(item, k) in category.children" :key="k">
                        <p
                          v-if="category.expandFlg && (item.type == undefined || item.type != 'rstChart')"
                          v-show="category.triangleDirection === 'top' && !item.isDummy"
                         
                          :class="[{
                            'calendar-content-item': 1,
                            'calendar-content-parent-other': isOtherParentClass(category),
                            'calendar-content-item-other': !isRstClass(category),
                            'calendar-content-item-rst': isRstClass(category),
                            'calendar-content-item-other-facility': item.facility_cd !== facilityCd
                          }]"
                          @click="getfCd(item);onClickLink(item, dateObj)"
                        >
                          <span
                            class="line-3-limit"
                            :class="[{
                              'indent-child': category.isDispGroup,
                              'prefix-content-red': hasPrefix(item) && !isRstClass(category)
                            }]"
                            v-if="item.content"
                          >
                            <template v-if="item.routerLink">
                              <span 
                                class="calendar-content-item-link calendar-content-category-item" 
                                :class="[{
                                  'prefix-content-color': hasPrefix(item) && !isRstClass(category)
                                }]"
                                :style="styleObject"
                              >
                                {{ item.content }}
                              </span>
                            </template>
                            <template v-else>
                              <span class="calendar-content-category-item">
                                {{ item.content }}
                              </span>
                            </template>
                          </span>
                        </p>
                        <!-- バイタル・モニタグラフ -->
                        <div
                          class="pat-calendar-chart-cell"
                          v-if="item.type == 'rstChart' && category.expandFlg"
                          v-show="category.triangleDirection === 'top'"
                          :key="item.key"
                          @click="getfCd(item);onClickLink(item, dateObj)">
                          <RstChart
                            :key="Math.random()"
                            :chart-data="item.chartData"
                            :x-axis-min="item.chartXAxisMin"
                            :x-axis-max="item.chartXAxisMax"
                            :disp-data-item="item.itemName"
                            :yAxis="item.yAxis"
                          />
                        </div>
                      </template>
                    </div>
                  </template>
                </div>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

  </div>
</template>

<script>
import { EventBus } from "@/compat/vue/event-bus.js";
// mod 編集権限の適用  劉全航 start
//mod FNSI-患者カレンダに表示する予定の不足情報を追加する 江 start
// import { mapGetters} from "@/compat/vue/vuex";
import { mapGetters, mapActions} from "@/compat/vue/vuex";
import RstChartForPatClendar from "@/components/pat-calendar/RstChartForPatClendar";
//mod FNSI-患者カレンダに表示する予定の不足情報を追加する 江 end
import { FUNC_PAT_CALENDAR, FUNC_PAT_EVENT } from "@/constants/function-code.js";
// mod 編集権限の適用  劉全航 end
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import dayjs from "@/compat/date/dayjs";
import { getScopedElementById, getScopedElementsByClassName } from "@/functions/common/LayoutMeasureHelper";
import { Chart } from "@/compat/charts/highcharts";
import {
  createCalendarMonth,
  createCalendarWeek,
  splitCalendarArrayByWeek
} from "@/components/common/contents-calendar/Functions.js";
import PopoverMixin from "@/components/PopoverMixin";
// add カレンダー指定での指定日ジャンプに対応 江 start
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
// add カレンダー指定での指定日ジャンプに対応 江 end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
// add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 start
import { LAYOUT_CATEGORY_EXAMREQUEST, LAYOUT_CATEGORY_EXAMRESULT, LAYOUT_CATEGORY_RADREQUEST } from "@/components/pat-calendar/Definitions.js";
import {deepCopy} from "@/functions/common/CommonFunctions";

// #9620 文字サイズを大きくすると部品がかさなる linjunfeng end
import DateInput from "@/components/common/DateInput";
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";


/**
 * @description カレンダーコンポーネント
 * @summary カレンダー表示内容(イベント)を各発生日に表示する
 * @property contents {Array} イベントオブジェクト配列
 *   [
 *     {
 *       date {String} イベント発生日文字列(YYYYMMDD),
 *       type {String} イベント表示形式(items/graph),
 *       // type === 'items' ↓
 *       items {Array} イベント内容オブジェクト配列
 *         [
 *           {
 *             content {String} イベント内容,
 *             routerLink {String} 内容クリック時の遷移先ページ名,
 *           },
 *           ...
 *         ],
 *       // type === 'chart' ↓
 *       chartOptions {Object} Highcharts表示用オブジェクト
 *     }
 *   ]
 * @property baseDate {Moment} 基準日moment
 * @property centerWeekMode {Boolean} 基準日を第3週にずらして表示するか
 */
export default {
  mixins: [PopoverMixin],

  components: {
    Chart,
    // add カレンダー指定での指定日ジャンプに対応 江 start
    "common-calendar": commonCalender,
    // add カレンダー指定での指定日ジャンプに対応 江 end
    //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 start
    RstChart:RstChartForPatClendar,
    //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 end
    "date-input": DateInput,
  },

  props: {
    contents: {
      type: Array,
      default: () => []
    },

    baseDate: {
      type: Object,
      default: dayjs()
      // default: ()=>{ return {} }
    },

    centerWeekMode: {
      type: Boolean,
      default: false
    },
    // 患者ID
    patId: {
      type: Number,
      default: null
    },
    // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 start
    expandFlg: {
      type: Boolean,
      default: true
    },
    expandStyle: {
      type: Object,
      default: {}
    },
    // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 end
    // データ読込期間 例：{ start: "20260101", end: "20260331" }
    loadedDateRange: {
      type: Object,
      default: () => ({
        start: null,
        end: null
      })
    }
  },

  data() {
    const data = {
      weekdays: ["月", "火", "水", "木", "金", "土", "日"],
      popoverTarget: null,
      popoverContent: null,
      calendarArray: null,
      // mod 編集権限の適用  劉全航 start
      isAuthorized: null,
      styleObject: {
        // mod FNSI-NO.390 配色デザイン調整 関 start
        // color: '#000000'
        color: 'var(--ntss-base-color)'
        // mod FNSI-NO.390 配色デザイン調整 関 end
      },
      // mod 編集権限の適用  劉全航 end
      // add カレンダー指定での指定日ジャンプに対応 江 start
      dateToday: null,
      // add カレンダー指定での指定日ジャンプに対応 江 end,
      commonCalendarAreaTop: 0,
      commonCalendarAreaLeft: 500,
      calendarInputFlexWrap: 'nowrap',
      observer: null,
      pendingMoveCurrentMonthForDate: false,
      isBootstrappingDateToday: false,
      // add #9562 患者カレンダーの表示が遅い 20240523 ztc start
      scrollListeningFlag: true,
      // add #9562 患者カレンダーの表示が遅い 20240523 ztc end
      fCd:''
    };
    return data;
  },

  watch: {
    // add カレンダー指定での指定日ジャンプに対応 江 start
    dateToday(value) {
        if (!value || this.isBootstrappingDateToday) {
          return;
        }
        this.handleDateTodayChange();
        this.bootstrapCalendarForDate(value, {
          emitBaseDate: true,
          appendWeeks: true,
          requestMove: true
        });
    },
    // add カレンダー指定での指定日ジャンプに対応 江 end
    contents() {
      this.$nextTick(() => {
        this.createCalendarContents();
      });
      this.requestCalendarForceUpdate("watch:contents");
    },
    // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 start
    expandFlg() {
      this.handleChangeAllTriangleDirection();
      // add #8091 2023/04/06 3/1を基準日設定する、日付表示不全 林峻峰 start
      this.requestMoveCurrentMonthForDate();
      // add #8091 2023/04/06 3/1を基準日設定する、日付表示不全 林峻峰 end
      this.requestCalendarForceUpdate("watch:expandFlg");
    }
    // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 end
  },

  created() {
    // 編集権限の取得
    this.isAuthorized = Array.isArray(this.getAuthorizedFunctions) && this.getAuthorizedFunctions.includes(FUNC_PAT_CALENDAR);
    const calendarArray = createCalendarMonth(this.baseDate);
    this.calendarArray = splitCalendarArrayByWeek(calendarArray);

    // 休日マスタの休日を取得
    this.fetchHolidays(this.facilityCd);

    // add FNSI-NO429初期表示スクロール位置を制御する。 関 start
    let calendarArrayFromThisWeek = [];
    let isSelectWeek = 0;
    this.calendarArray.forEach(everyArr => {
      if (isSelectWeek == 0) {
        everyArr.forEach(everyDay => {
          if (parseInt(everyDay.format("YYMMDD")) >= parseInt(dayjs().format("YYMMDD"))) {
            isSelectWeek = 1;
          }
        });
      }
      if (isSelectWeek == 1) {
        calendarArrayFromThisWeek.push(everyArr);
      }
    });
    this.calendarArray = calendarArrayFromThisWeek;
    this.normalizeCalendarArrayDays(this.calendarArray);
    // FNSi-9947-患者カレンダーの展開動作がされていない zhoubin add start
    this.setDateExpandFlg(this.calendarArray);
    // FNSi-9947-患者カレンダーの展開動作がされていない zhoubin add end
    // add FNSI-NO429初期表示スクロール位置を制御する。 関 end
  	// add カレンダー指定での指定日ジャンプに対応 江 start
    this.isBootstrappingDateToday = true;
    this.dateToday = dayjs(new Date()).format("YYYY-MM-DD");
    this.handleDateTodayChange();
    this.bootstrapCalendarForDate(this.dateToday, {
      emitBaseDate: false,
      appendWeeks: true,
      requestMove: false
    });
    this.isBootstrappingDateToday = false;
    this.pendingMoveCurrentMonthForDate = true;
  	// add カレンダー指定での指定日ジャンプに対応 江 end
    // #9620 文字サイズを大きくすると部品がかさなる linjunfeng start
    EventBus.$off("switchSidebar", this.handleSwitchSidebar);
    EventBus.$on("switchSidebar", this.handleSwitchSidebar);
    // #9620 文字サイズを大きくすると部品がかさなる linjunfeng end
  },

  mounted() {
    // mod 編集権限の適用  劉全航 start
    this.isAuthorized = Array.isArray(this.getAuthorizedFunctions) && this.getAuthorizedFunctions.includes(FUNC_PAT_CALENDAR);
    if(this.isAuthorized === false){
       this.styleObject.color = "#666666";
    }
    // mod 編集権限の適用  劉全航 end
    const element = getScopedElementById("main-id", this.$el || null)
    this.observer  = new ResizeObserver(entries => {
      const { width } = entries[0].contentRect;
      this.handleResizeWindow(width);
    });
    if (element) {
      this.observer.observe(element);
      this.handleResizeWindow(element.clientWidth);
    }
    this.$nextTick(() => {
      this.flushPendingMoveCurrentMonthForDate();
    });

  },
  // mod 編集権限の適用  劉全航 start

  beforeUnmount() {
    this.clearHolidays(); // storeの休日マスタをクリア
    // #9620 文字サイズを大きくすると部品がかさなる linjunfeng start
    EventBus.$off("switchSidebar", this.handleSwitchSidebar);
    // #9620 文字サイズを大きくすると部品がかさなる linjunfeng end
    // #9947 患者カレンダーの展開動作がされていない、他の画面に遷移する時、ResizeObserverを実行しないようにする xugj mod start
    // const element = getScopedElementById("main-id", this.$el || null)
    // if (this.observer && element) {
    //   this.observer.unobserve(element)
    // }
    if (this.observer != null) {
      this.observer.disconnect();
      this.observer = null;
    }
    // #9947 患者カレンダーの展開動作がされていない、他の画面に遷移する時、ResizeObserverを実行しないようにする  xugj mod end
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  computed:{
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("account-edit", {
      getAuthorizedFunctions: "getAuthorizedFunctions"
    }),
    ...mapGetters("pat-viewer", ["getTreatmentData"]),
    ...mapGetters("mst-holiday", ["getHolidays"]),
    formatedDisplay() {
      return dayjs(this.dateToday).format('YYYY/MM/DD');
    },
    // 患者IDが選択済み、且つ患者イベントの表示権限があるか
    selectedIdAndPatEventPermission() {
      return this.patId && Array.isArray(this.getAuthorizedFunctions) && this.getAuthorizedFunctions.includes(FUNC_PAT_EVENT);
    },
    // 権限が患者イベントの表示権限のみか
    patEventViewPermissionOnly() {
      return Array.isArray(this.getAuthorizedFunctions) && this.getAuthorizedFunctions.includes(FUNC_PAT_EVENT) &&
             !(this.getUserAuthorityCds().includes(AUTHORITY_CODES.PAT_EVENT_EDIT) ||
               this.getUserAuthorityCds().includes(AUTHORITY_CODES.PAT_EVENT_PEDIT))
    },
    /** データを読み込めている範囲の新古末端月を取得 */
    contentsMonthRange() {
      if (!this.loadedDateRange?.start || !this.loadedDateRange?.end) {
        return null;
      }
      return {
        minMonth: dayjs(this.loadedDateRange.start, "YYYYMMDD").startOf("month"),
        maxMonth: dayjs(this.loadedDateRange.end, "YYYYMMDD").startOf("month")
      };
    }
  },
  // mod 編集権限の適用  劉全航 end
  methods: {
    //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 start
    ...mapActions("exam-record/list", [
      "setCondition"
    ]),
    ...mapActions("exam-request/list", [
      "updateStartToEndDate",
      "setCalendarCheckedDate"
    ]),
    ...mapActions("rad-request/list", {
      radRequestUpdate: "updateStartToEndDate",
      radRequestsetCalendar: "setCalendarCheckedDate"
    }),
    ...mapActions("pat-prescription", [
      "setInfoFromCalendar"
    ]),
    ...mapActions("facility-calendar", [
      "setCalendarSearchDate"
    ]),
    //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 end
    ...mapGetters("user", ["getUserAuthorityCds"]),
    ...mapActions("mst-holiday", [
      "fetchHolidays",
      "clearHolidays"
    ]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    
    /** 表示年月日を日付IF、今日ボタンから変更したことを親に通知 */
    handleDateTodayChange() {
      this.$emit("date-today-changed");
    },

    // #9620 文字サイズを大きくすると部品がかさなる linjunfeng start
    requestCalendarForceUpdate(context) {
      if (this.$?.isMounted) {
        this.$forceUpdate();
      }
    },
    handleSwitchSidebar() {
      this.handleResizeWindow(Number(getScopedElementById("main-id", this.$el || null)?.clientWidth || 0));
    },
    getCalendarBodyElement() {
      return this.$refs?.calendarBody || null;
    },
    getCalendarHeaderHeight(calendarBody = null) {
      const body = calendarBody || this.getCalendarBodyElement();
      return body?.querySelector("thead")?.clientHeight || 0;
    },
    getCalendarRowHeight(calendarBody = null) {
      const body = calendarBody || this.getCalendarBodyElement();
      return body?.querySelector("tbody tr")?.clientHeight || 0;
    },
    bootstrapCalendarForDate(dateValue, options = {}) {
      const {
        emitBaseDate = true,
        appendWeeks = true,
        requestMove = true
      } = options;
      const nextDate = dayjs(dateValue, "YYYY-MM-DD");
      const nextCalendarArray = splitCalendarArrayByWeek(
        createCalendarMonth(nextDate)
      );
      this.normalizeCalendarArrayDays(nextCalendarArray);
      this.calendarArray = nextCalendarArray;
      this.setDateExpandFlg(this.calendarArray);
      this.createCalendarContents();
      if (emitBaseDate && this.baseDateNow) {
        this.$emit("update:baseDate", this.baseDateNow);
      }
      if (appendWeeks) {
        this.addWeeksToCalendar(3);
      }
      if (requestMove) {
        this.requestMoveCurrentMonthForDate();
      }
    },
    normalizeCalendarArrayDays(calendarArray) {
      if (!Array.isArray(calendarArray)) {
        return;
      }
      calendarArray.forEach((week, weekIndex) => {
        if (!Array.isArray(week)) {
          return;
        }
        week.forEach((day, dayIndex) => {
          if (day && !day.dateObj) {
            day.dateObj = day;
          }
          if (day && day.content == null) {
            day.content = { items: [] };
          }
        });
      });
    },
    requestMoveCurrentMonthForDate() {
      this.pendingMoveCurrentMonthForDate = true;
      this.$nextTick(() => {
        this.flushPendingMoveCurrentMonthForDate();
      });
    },
    flushPendingMoveCurrentMonthForDate() {
      if (!this.pendingMoveCurrentMonthForDate) {
        return;
      }
      const calendarBody = this.$refs?.calendarBody;
      if (!calendarBody) {
        return;
      }
      this.pendingMoveCurrentMonthForDate = false;
      this.moveCurrentMonthForDate();
    },
    handleResizeWindow(width) {
      /** レイアウト選択 + 展開チェック(header)、日付IF・今日ボタン・新規登録ボタン(中央要素) の配置を追従 */
      let expandStyle = {};
      const dropdownlistWidth = getScopedElementsByClassName('k-widget k-dropdown variable_width', this.$el || null)[0]?.clientWidth;
      const expandWidth = getScopedElementsByClassName('expand', this.$el || null)[0]?.clientWidth;
      const commonCalendarAreaWidth = getScopedElementsByClassName('common-calendar-area', this.$el || null)[0]?.clientWidth;
      // プルダウンの高さを取得（中央要素折り返し時に下へ配置するため）
      const dropdownHeight = getScopedElementsByClassName('k-widget k-dropdown variable_width', this.$el || null)[0]?.clientHeight || 0;
      // レイアウト選択 + 展開チェック の横幅合計 ※40=余白
      const baseWidth = dropdownlistWidth + expandWidth + 40;
      // 「header右端 + カレンダー幅」
      // ＝ 横並びにするために必要な最低画面幅
      const totalWidth = baseWidth + commonCalendarAreaWidth;
      
      if (width > totalWidth) {
        // 画面幅に余裕がある → 横並び表示
      
        // 上に配置
        this.commonCalendarAreaTop = 0;
        // 中央寄せを基本にするが、
        // header右端より左に入り込まないように Math.max で制御
        this.commonCalendarAreaLeft = Math.max(
          (width - commonCalendarAreaWidth) / 2,  // 画面中央位置
          baseWidth                               // header右端の位置
        );
 
      } else {
        // 横並びできない → 下に折り返す、画面中央配置
        
        // プルダウンの下に配置
        this.commonCalendarAreaTop = dropdownHeight + 5;
        // 左端から表示
        this.commonCalendarAreaLeft = (width - commonCalendarAreaWidth) / 2;
      }
      if (width <= baseWidth) {
        // 展開チェック → 下に折り返す
        this.commonCalendarAreaTop = (getScopedElementsByClassName('k-widget k-dropdown variable_width', this.$el || null)[0]?.clientHeight || 0) + (getScopedElementsByClassName('expand', this.$el || null)[0]?.clientHeight || 0) + 10;
        this.commonCalendarAreaLeft = 0;
        this.calendarInputFlexWrap = 'wrap';
        expandStyle.left = 5;
        expandStyle.top = (getScopedElementsByClassName('k-widget k-dropdown variable_width', this.$el || null)[0]?.clientHeight || 0) + 7;
      } else {
        // 展開チェック → 横並び表示
        this.calendarInputFlexWrap = 'nowrap';
        expandStyle.left = (getScopedElementsByClassName('k-widget k-dropdown variable_width', this.$el || null)[0]?.clientWidth || 0) + 15;
        expandStyle.top = 4;
      }
      this.requestCalendarForceUpdate("handleResizeWindow")
      this.$emit('backChangeExpandStyle', expandStyle)
    },
    // #9620 文字サイズを大きくすると部品がかさなる linjunfeng end
    moveCurrentMonthForDate() {
      const calendarBody = this.getCalendarBodyElement();
      if (!calendarBody) {
        this.pendingMoveCurrentMonthForDate = true;
        return;
      }
      if (calendarBody.scrollTop === 1) return;
      const currentDate = dayjs(this.dateToday, "YYYY-MM-DD");
      if (!currentDate?.isValid?.()) {
        return;
      }
      const isoWeekTmp = currentDate.isoWeek();
      const isoWeekStart = currentDate.isoWeekday(1).format('YYYY-MM-DD');
      const yearTmp = dayjs(isoWeekStart, "YYYY-MM-DD").isoWeekYear();

      this.$nextTick(() => {
        // 当月の第1週を取得
        const week = [...calendarBody.querySelectorAll("[id]")].find(
          i => dayjs(i.id, "YYYYMMDD").isoWeek() === isoWeekTmp &&
            dayjs(i.id, "YYYYMMDD").isoWeekYear() === yearTmp);
        if (week) {
          // add #9562 患者カレンダーの表示が遅い 20240523 ztc start
          this.scrollListeningFlag = false;
          // add #9562 患者カレンダーの表示が遅い 20240523 ztc end
          week.scrollIntoView();
          calendarBody.scrollTop -= this.getCalendarHeaderHeight(calendarBody);
          this.$emit("update:baseDate", currentDate);
        }
      });
    },
    moveToMonth(date) {
      this.$emit("update:baseDate", dayjs(date, "YYYYMMDD"));
    },

    movePrevMonth() {
      this.$emit(
        "update:baseDate",
        dayjs(this.baseDate).subtract(1, "months"));
    },

    moveNextMonth() {
      this.$emit("update:baseDate", dayjs(this.baseDate).add(1, "months"));
    },
    // add FNSI-NO547本日に移動できない 関 start
    moveToday() {
      // add カレンダー指定での指定日ジャンプに対応 江 start
      const calendarBody = this.getCalendarBodyElement();
      const today = dayjs();
      this.dateToday = today.format("YYYY-MM-DD");
      if (!calendarBody) {
        this.requestMoveCurrentMonthForDate();
        return;
      }
      const isoWeekTmp = today.isoWeek();
      const isoWeekStart = today.weekday(1).format('YYYY-MM-DD');
      const yearTmp = dayjs(isoWeekStart, "YYYY-MM-DD").year();
      // add カレンダー指定での指定日ジャンプに対応 江 end
      const week = [...calendarBody.querySelectorAll("[id]")].find(
        i =>
          // mod カレンダー指定での指定日ジャンプに対応 江 start
          // dayjs(i.id, "YYYYMMDD").isoWeek() ===
          //   dayjs().isoWeek() && dayjs(i.id, "YYYYMMDD").year() === dayjs().year()
          dayjs(i.id, "YYYYMMDD").isoWeek() === isoWeekTmp &&
          dayjs(i.id, "YYYYMMDD").year() === yearTmp
          // mod カレンダー指定での指定日ジャンプに対応 江 end
      );
      if (week) {
        // add #9562 患者カレンダーの表示が遅い 20240523 ztc start
        this.scrollListeningFlag = false;
        // add #9562 患者カレンダーの表示が遅い 20240523 ztc end
        week.scrollIntoView();
        calendarBody.scrollTop -= this.getCalendarHeaderHeight(calendarBody);
        this.$emit("update:baseDate", today);
        // 表示年月日を今日ボタンから変更したことを親に通知
        this.handleDateTodayChange();
      }
    },
    // add FNSI-NO547本日に移動できない 関 end
    moveCurrentMonth() {
      const calendarBody = this.getCalendarBodyElement();
      if (!calendarBody) {
        this.requestMoveCurrentMonthForDate();
        return;
      }
      if (calendarBody.scrollTop === 1) return;

      // 当月の第1週を取得
      const currentMonth = dayjs().startOf("month");
      const week = [...calendarBody.querySelectorAll("[id]")].find(
        i => dayjs(i.id, "YYYYMMDD").isoWeek() === currentMonth.isoWeek() &&
          dayjs(i.id, "YYYYMMDD").year() === dayjs().year());
      if (week) {
        // add #9562 患者カレンダーの表示が遅い 20240523 ztc start
        this.scrollListeningFlag = false;
        // add #9562 患者カレンダーの表示が遅い 20240523 ztc end
        week.scrollIntoView();
        calendarBody.scrollTop -= this.getCalendarHeaderHeight(calendarBody);
        this.$emit("update:baseDate", dayjs());
      }
    },

    calendarDate(date) {
      const className = "calendar-date";
      const today = dayjs();
      var checkHoliday = this.getHolidays;
      let ret = [className];
      const formatDate = date.format("YYYY-MM-DD");

      if (today.format("YYYY-MM-DD") == formatDate) {
        ret.push(className + "-Today");
        //add FNSI-redmin bug #3835 【休日マスタの祝日とそれ以外を区別する】を修正 江 start
        if(checkHoliday[formatDate] != null){
          ret.push(className + "-Holiday");
        }
        //add FNSI-redmin bug #3835 【休日マスタの祝日とそれ以外を区別する】を修正 江 end
      }else if (checkHoliday[formatDate] != null) {
        ret.push(className + "-Holiday");
        //add FNSI-redmin bug #3835 【休日マスタの祝日とそれ以外を区別する】を修正 江 start
        if(date.month()%2){
          ret.push(className + "-OtherMonth");
        }
        //add FNSI-redmin bug #3835 【休日マスタの祝日とそれ以外を区別する】を修正 江 end
      }else if(date.month()%2){
        ret.push(className + "-OtherMonth");
      }
      if(date.day() === 6){
        ret.push(className + "-Saturday");
      }
      if(date.day() === 0){
        ret.push(className + "-Sunday");
      }
      
      // 指定日(画面上部の日付IF指定日)：青枠
      if (this.dateToday == formatDate) {
        ret.push("calendar-date-baseday");
      }
      
      return ret;
    },

    dateFormatter(date) {
      // mod #7732 【休日マスタで設定した名称を表示させる必要は無い。】start
      //mod FNSI-redmin bug #3835 【休日マスタの祝日とそれ以外を区別する】を修正 江 start
      return date.date() === 1 ? date.format("YYYY/M/D") : date.format("M/D");
      // let holidayName = "";
      // this.holidays.forEach(everyHoliday => {
      //   let holidayJson = JSON.parse(everyHoliday.holiday);
      //   holidayJson.forEach(everyDay => {
      //     if(everyDay.date == date.format("YYYY/MM/DD") && everyDay.name != undefined && everyDay.name != ""){
      //       holidayName = "("+everyDay.name+")";
      //     }
      //   });
      // });
      // return date.date() === 1 ? date.format("M/D") + holidayName : date.date() + holidayName;
      //mod FNSI-redmin bug #3835 【休日マスタの祝日とそれ以外を区別する】を修正 江 end
      // mod #7732 【休日マスタで設定した名称を表示させる必要は無い。】end
    },

    getfCd(item){
      if (item && item.facility_cd) {
        this.fCd = item.facility_cd
      }
    },
    onClickLink(item, date) {
      const { routerLink, readOnly, content, categoryCd } = item;
      const formatDate = dayjs(date).format("YYYY-MM-DD");

      //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 start
      var startDate = dayjs(date).add(-3, "months").format("YYYY-MM-DD");
      var endDate = dayjs(date).add(3, "months").format("YYYY-MM-DD");
      //mod FutreNetWeb+SI課題管理 no.5574 劉全航 start
      if(routerLink === "pat-event"){
        startDate = formatDate;
        endDate = formatDate;
      }
      //mod FutreNetWeb+SI課題管理 no.5574 劉全航 end
      if(routerLink === "facility-calendar"){
        this.setCalendarSearchDate(formatDate);
      }
      var checkedDate = date.format("YYYY/MM/DD");
      // 処方 抽出条件 store設定
      if (content != undefined) {
        if (content.indexOf("院内処方") != -1) {
          this.setInfoFromCalendar({
            checkedDate: checkedDate,
            checkedInOroutFlg: "2",
            inOroutFlg: "on"
          });
        }
        else if (content.indexOf("院外処方") != -1) {
          this.setInfoFromCalendar({
            checkedDate: checkedDate,
            checkedInOroutFlg: "1",
            inOroutFlg: "on"
          });
        }
      }
      this.setCondition(
      {
        examSetCd: -1,
        examDate: date.format("MM/DD"),
        examDateSt: startDate,
        examDateEd: endDate,
        viewPatId: true,
        viewExamDate: true
      });
      this.setCalendarCheckedDate(checkedDate);
      this.radRequestsetCalendar(checkedDate);
      this.updateStartToEndDate({"showStartDate": startDate.replace(/-/g, ""), "showEndDate": endDate.replace(/-/g, "")});
      this.radRequestUpdate({"showStartDate": startDate.replace(/-/g, ""), "showEndDate": endDate.replace(/-/g, "")});
      //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 end
      // mod 編集権限の適用  劉全航 start
      if(this.isAuthorized === false){
        return false;
      }
      // mod 編集権限の適用  劉全航 end
      if(readOnly && !this.fCd){
        return;
      }
      // 患者イベントが２件に分かれて患者カレンダーに表示される  5791  shan  start
      this.$emit("content-clicked", { item, date, createNew:false, fCd: this.fCd });
      // 患者イベントが２件に分かれて患者カレンダーに表示される  5791  shan  end
    },

    /**
     * @description カレンダー内容作成
     */
    createCalendarContents(contents) {
      const newContents = contents ? contents : this.contents
      this.normalizeCalendarArrayDays(this.calendarArray);
      this.calendarArray.forEach((week, weekIndex) => {
        week.forEach((day, dayIndex) => {
          let skip = false;
          if (!day.dateObj) day.dateObj = day;
          if (this.contents.length > 0) {
            const contentsArr = newContents.find(
            ({ date }) => date === day.dateObj.format("YYYYMMDD"))
            // 既に読み込んだデータは展開折畳を維持するため上書かない
            if (!day.content || !day.content.items || day.content.items.length === 0) {
              day.content = contentsArr ? deepCopy(contentsArr) : { items: [] };
            } else {
              skip = true;
            }
          // add #11313 【たくしより】患者カレンダーの表示が更新されない linjunfeng start
          } else {
            day.content = { items: [] };
          }
          // add #11313 【たくしより】患者カレンダーの表示が更新されない linjunfeng end
          if (day.content && !skip) {
            day.content.items = this.getCategoryData(day.content.items);
          }
        });
      });
      // FNSi-9947-患者カレンダーの展開動作がされていない zhoubin add start
      this.setDateExpandFlg(this.calendarArray);
      // FNSi-9947-患者カレンダーの展開動作がされていない zhoubin add end
    },

    /** 表示項目を親子の塊にする */
    getCategoryData(data) {
      if (!data) {
        return []
      }
      
      let categoryData = data.map(item => {
        const obj = {
          layoutCategoryKey: item.layoutCategoryKey,
          layoutCategoryTitle: item.layoutCategoryTitle,
          isDispGroup: item.isDispGroup // 親表示有無
        };
        // セルの展開折畳フラグ
        if (item.triangleDirection !== undefined) {
          obj.triangleDirection = item.triangleDirection;
        }
        return obj;
      });
      
      // categoryDataから重複除去
      const seen = new Set();
      categoryData = categoryData
        .filter(item => {
          if (seen.has(item.layoutCategoryKey)) return false;
          seen.add(item.layoutCategoryKey);
          return true;
        })
        .map(item => {
          const obj = {
            layoutCategoryKey: item.layoutCategoryKey,
            layoutCategoryTitle: item.layoutCategoryTitle,
            isDispGroup: item.isDispGroup
          };
          // セルの展開折畳フラグ
          if (item.triangleDirection !== undefined) {
            obj.triangleDirection = item.triangleDirection;
          }
          return obj;
        });

      const expandFalseArr = [
        LAYOUT_CATEGORY_EXAMRESULT.key,
        LAYOUT_CATEGORY_RADREQUEST.key,
      ];
      
      // 親子構造構築
      categoryData.forEach((item) => {
        let children = [];
      
        data.forEach((dataItem) => {
          if (!dataItem.children && dataItem.layoutCategoryKey === item.layoutCategoryKey) {
            children.push(dataItem);
          } else if (dataItem.children) {
            children = deepCopy(dataItem.children);
          }
        });
        
        // 親が検査予定で子なしの場合は展開折畳がなしで平打ち
        if (
          item.layoutCategoryKey === LAYOUT_CATEGORY_EXAMREQUEST.key && !item.isDispGroup) {
          expandFalseArr.push(LAYOUT_CATEGORY_EXAMREQUEST.key);
        }
      
        // 日付セルの展開折畳状態を維持
        if (item.triangleDirection === undefined) {
          item.triangleDirection = item.isDispGroup && !this.expandFlg ? "bottom" : "top";
        }
        // 親要素なしで子要素のみの場合は展開折畳がなしで平打ち
        item.expandFlg = !item.isDispGroup || !expandFalseArr.includes(item.layoutCategoryKey);
        item.children = children;
      });
      
      return categoryData.filter(item => item.children.length > 0)
    },

    /**
     * @description スクロールイベントにより、月の切り替えを行う
     */
    scrollHandler() {
      // add #9562 患者カレンダーの表示が遅い 20240523 ztc start
      if (!this.scrollListeningFlag) {
        this.scrollListeningFlag = true;
        return;
      }
      // add #9562 患者カレンダーの表示が遅い 20240523 ztc end
      const e = this.$refs.calendarBody;
      const isScrolledTop = e?.scrollTop === 0;
      // 患者カレンダーのスクロールによる読み込み不正 6423  shan start
      const isScrolledBottom =  Math.abs(e.scrollTop + e.clientHeight - e.scrollHeight) < 4;
      // 患者カレンダーのスクロールによる読み込み不正 6423  shan end
            
      // 15日が属する週の行の中央がスクロール領域に入ったらtrueを返す
      const isScrolledIntoView = elem => {
        const parentTop = e.scrollTop;
        const parentBottom = parentTop + e.clientHeight;
        const elemCenter = elem.offsetTop + elem.clientHeight / 2;
      
        return elemCenter >= parentTop && elemCenter <= parentBottom;
      };

      // スクロール位置チェック
      if (isScrolledTop) {
        this.addWeeksToCalendar(-1);
        // mod #8091 2023/04/06 3/1を基準日設定する、日付表示不全 林峻峰 start
        // e.scrollTop = e.querySelector("tbody tr").clientHeight;
        this.$nextTick(() => {
          e.scrollTop = e.querySelector("tbody tr").clientHeight;
        })
        // mod #8091 2023/04/06 3/1を基準日設定する、日付表示不全 林峻峰 start
      } else if (isScrolledBottom) {
        this.addWeeksToCalendar(1);
      }
      
      // 患者未選択の場合、以降の処理は行わない
      if (!this.patId) return;

      // querySelectorAllからのNodeList配列を普通の並列へ
      // 読み込めている範囲の新古末端月の月半ば(15日)になったら、月を切り替える
      const currentMonthElem = [...e.querySelectorAll("[id]")].find(
        i =>
          dayjs(i.id, "YYYYMMDD").isoWeek() ===
            dayjs(i.id, "YYYYMMDD")
              .date(15)
              .isoWeek() && isScrolledIntoView(i));
            
      if (currentMonthElem) {
        // 読み込めている範囲の新古末端月を取得
        const monthRange = this.contentsMonthRange;
        if (!monthRange || !monthRange.minMonth || !monthRange.maxMonth) {
          return;
        }
        const { minMonth, maxMonth } = monthRange;
        const hitMonth = dayjs(currentMonthElem.id, "YYYYMMDD").startOf("month");

        if (!hitMonth.isValid()) {
          return;
        }

        const diffMin = hitMonth.diff(minMonth, "months");
        const diffMax = hitMonth.diff(maxMonth, "months");

        // 読み込めている範囲の新古末端月の15日を含む週なら切り替える
        if (diffMin <= 0 || diffMax >= 0) {
          this.moveToMonth(currentMonthElem.id);
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
        ? dayjs(
            this.calendarArray[this.calendarArray.length - 1][0].dateObj).add(1, "week")
        : dayjs(this.calendarArray[0][0].dateObj).add(numWeeks, "week");

      const newWeek = createCalendarWeek(baseDate, numWeeks);
      const calendarWeeksArray = splitCalendarArrayByWeek(newWeek);
      this.normalizeCalendarArrayDays(calendarWeeksArray);
      if (isAddToEndOfCalendar) {
        this.calendarArray.push(...calendarWeeksArray);
      } else {
        this.calendarArray.unshift(...calendarWeeksArray);
      }
      this.createCalendarContents();
    },

    isRstClass(category) {
      return category.children?.some(
        child => child.indRstClass === "rst" || child.type === "rstChart") ?? false;
    },
    /** 検査結果、検査予定(子なし)、一般撮影検査予定は親のスタイル適用 */
    isOtherParentClass(category) {
      if (category.children?.length !== 1) return false;
    
      const child = category.children[0];
      return ["検査結果 あり", "検査予定 あり", "一般撮影検査予定 あり"]
        .some(prefix => child.content.startsWith(prefix));
    },
    
    /** 接頭辞有無判定 */
    hasPrefix(item) {
      if (!item.content) return false;
  
      const prefix = [
        "【分類不一致】",
        "【削除済み】",
        "【削除済み含む】",
        "【期限切れ】",
        "【禁忌】",
        "【ｱﾚﾙｷﾞｰ】",
        "【禁忌・ｱﾚﾙｷﾞｰ】"
      ];
  
      return prefix.some(k => item.content.includes(k));
    },
    
    // カレンダーの日付から患者イベント画面(新規作成)に遷移
    createNewFromCalendar(momentObj) {
      if (!this.selectedIdAndPatEventPermission) {
        // add #10359、#10331 編集権限について、対応する。 dengshen start
        if (!(Array.isArray(this.getAuthorizedFunctions) && this.getAuthorizedFunctions.includes(FUNC_PAT_EVENT))) {
          this.$ons.notification.alert({
            // title: "権限エラー",
            // message: functionName+"を操作する権限がありません。管理者に確認してください。"
            title: DIALOG_MESSAGES[12000315].title,
            message: messageFormat(DIALOG_MESSAGES[12000315].message, "患者イベント")
          });
        }
        // add #10359、#10331 編集権限について、対応する。 dengshen end
        // 患者ID未選択、又は表示権限がない
        return;
      }
      if (this.getUserAuthorityCds().includes(AUTHORITY_CODES.PAT_EVENT_EDIT) ||
        this.getUserAuthorityCds().includes(AUTHORITY_CODES.PAT_EVENT_PEDIT)) {
          // 患者イベントの編集権限有り
          const routerLink = "pat-event";
          const date = momentObj;
          const createNew = true;
          this.$emit("content-clicked", { item: { routerLink }, date, createNew });
      } else {
        // 患者イベントの編集権限無し
        this.$ons.notification.alert({
          // mod #6107 2023/03/23 メッセージボックス全調整 林峻峰 start
          // title: "権限エラー",
          // message: "患者イベントを編集する権限がありません。"
          title: DIALOG_MESSAGES['00200003'].title,
          message: DIALOG_MESSAGES['00200003'].message
          // mod #6107 2023/03/23 メッセージボックス全調整 林峻峰 end
        });
      }
    },
    // 新規作成ボタンから患者イベント画面(新規作成)に遷移
    createNewFromNewBtn() {
      // 患者イベントの編集権限有り
      const routerLink = "pat-event";
      // 隣の日付欄から日付を取得する
      const date = dayjs(this.dateToday);
      const createNew = true;
      this.$emit("content-clicked", { item: { routerLink }, date, createNew });
    },
    // FNSi-9947-患者カレンダーの展開動作がされていない add start
    setDateExpandFlg(calendarArray) {

      let expandFlg = this.expandFlg ? '1' : '0';
      calendarArray.forEach(everyArr => {
        everyArr.forEach(everyDay => {
          everyDay.expandFlg = expandFlg;
        });
      });

      this.requestCalendarForceUpdate("handleChangeDateExpandFlg");
    },

    /** 日付 展開折畳制御 */
    handleChangeDateExpandFlg(dateObj) {
      if('0' === dateObj.expandFlg) {
        dateObj.expandFlg = '1';
        if(dateObj.content && 'items' === dateObj.content.type) {
          for(let item of dateObj.content.items) {
            item.triangleDirection = 'top';
          }
        }
      } else {
        dateObj.expandFlg = '0';
        if(dateObj.content && 'items' === dateObj.content.type) {
          dateObj.content.items
            .filter(item => item.isDispGroup)
            .forEach(item => {
              // 親要素ありの場合のみ展開折畳を制御
              item.triangleDirection = 'bottom';
            });
        }
      }

      this.requestCalendarForceUpdate("handleChangeDateExpandFlg");
    },
    // FNSi-9947-患者カレンダーの展開動作がされていない add end
    // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 start
    /** 親要素 展開折畳制御 */
    handleChangeTriangleDirection(layoutCategoryKey, date){
      this.calendarArray.forEach((week) => {
        week.forEach((day) => {
          if (day.content) {
            day.content.items
              .filter(item => item.isDispGroup)
              .forEach(item => {
                // 親要素ありの場合のみ展開折畳を制御
                if (item.layoutCategoryKey === layoutCategoryKey && day.content.date === date) {
                  item.triangleDirection = item.triangleDirection === 'top' ? 'bottom' : 'top';
                  this.requestCalendarForceUpdate("handleChangeTriangleDirection");
                }
              });
          }
        });
      });
    },
    /** 展開する 展開折畳制御 */
    handleChangeAllTriangleDirection(){
      this.calendarArray.forEach((week) => {
        week.forEach((day) => {
          // FNSi-9947-患者カレンダーの展開動作がされていない zhoubin add start
          day.expandFlg = this.expandFlg ? '1' : '0';
          // FNSi-9947-患者カレンダーの展開動作がされていない zhoubin add end
          if (day.content) {
            day.content.items
              .filter(item => item.isDispGroup)
              .forEach(item => {
                // 親要素ありの場合のみ展開折畳を制御
                item.triangleDirection = this.expandFlg ? 'top' : 'bottom';
              });
          }
        });
      });
    }
    // add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 end
  }
};
</script>

<style lang="scss" scoped>
.calendar {
  display: flex;
  flex-direction: column;
  height: 100%;
  box-sizing: border-box;
}
// mod FutreNetWeb+SI課題管理 no.5025 劉全航 start
@media screen and (max-width: 500px) {
  thead,tbody {
    tr {
      width: 350% !important;
    }
  }
}
// mod FutreNetWeb+SI課題管理 no.5025 劉全航 end
.calnendar-header {
  display: flex;
  flex-flow: nowrap;
  user-select: none;
  span {
    cursor: pointer;
  }
}
.current-month-button {
  display: flex;
  margin: 0 0 2px 5px;
}

.calendar-body {
  border-collapse: collapse;
  td {
    border: solid 1px rgba(64, 64, 66, 0.12);
    padding: 0;
  }
}



.calendar-weekday {
  // mod FNSI-色変更 関 start
  // color: white;
  color: #e4e4e4;
  // mod FNSI-色変更 関 end
  //mod FNSI-NO390 透過をなくす 刘全航 start
  // mod FNSI-色変更 関 start
  // background-color: rgba(65, 65, 65, 1.0);
  background-color: #414141;
  // mod FNSI-色変更 関 end
  text-align: center;
  border-right: 1px solid rgba(255, 255, 255, 0.4);
  &:nth-of-type(7n-1) {
    // mod FNSI-色変更 関 start
    // background-color: rgba(0, 60, 255, 1.0);
    color: var(--ntss-saturday-color);
    // mod FNSI-色変更 関 end
  }
  &:nth-of-type(7n) {
    // mod FNSI-色変更 関 start
    // background-color: rgba(255, 0, 0, 1.0);
    color: var(--ntss-sunday-color);
    // mod FNSI-色変更 関 end
  }
  //mod FNSI-NO390 透過をなくす 刘全航 end
}

.calendar-date {
  padding: 0.25em 0;
  text-align: center;
  // mod FNSI-色変更 関 start
  // background-color: rgba(0, 195, 255, 0.3);
  background-color:#666666;
  // mod FNSI-色変更 関 end
  //add FNSI-redmin bug #3835 【休日マスタの祝日とそれ以外を区別する】を修正 江 start
  color:#ffffff;
  height: 1.5em;
  //add FNSI-redmin bug #3835 【休日マスタの祝日とそれ以外を区別する】を修正 江 end
  &-Today {
    // mod FNSI-色変更 関 start
    // background-color: rgba(83, 255, 40, 0.3);
    background-color: #2ca06f;
    // mod FNSI-色変更 関 end
  }
  //mod FNSI-NO390 配色デザイン調整、月ごとの日付の色、本日、休日 刘全航 start
  &-Holiday {
    // mod FNSI-色変更 関 start
    // background-color: rgba(255, 0, 0, 0.3);
    //mod FNSI-redmin bug #3835 【休日マスタの祝日とそれ以外を区別する】を修正 江 start
    // background-color: #e48282;
    color: var(--ntss-holiday-color) !important;
    //mod FNSI-redmin bug #3835 【休日マスタの祝日とそれ以外を区別する】を修正 江 end
    // mod FNSI-色変更 関 end
  }
  //mod FNSI-NO390 配色デザイン調整、月ごとの日付の色、本日、休日 刘全航 end
  &-OtherMonth {
    // mod FNSI-色変更 関 start
    // background-color: rgba(255, 216, 40, 0.3);
    background-color: #444444;
    // mod FNSI-色変更 関 end
  }
  background-image: none !important;
  &-Saturday {
    color: var(--ntss-saturday-color);
  }
  &-Sunday {
    color: var(--ntss-sunday-color);
  }
}

.pat-calendar-chart-cell {
  overflow: hidden;
  margin: 0;
  padding: 0;
  line-height: 0;
}

.calendar-content {
  text-align: left;
  overflow-y: auto;
  color: var(--ntss-base-color);
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
  padding: 0.5px 0;
  margin: 0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  cursor: pointer;

  /* add #9846 start */
  padding: .25em 0;
  /* add #9846 end */
  &-link {
    // mod FNSI-テーマ：黒い場合、文字見えないの修正 江 start
    // color: gray;
    color: var(--ntss-base-color);
    // mod FNSI-テーマ：黒い場合、文字見えないの修正 江 end
    line-height: 20px;
    margin-left: 3px;
  }
}

// 実績項目に適用する背景色
.calendar-content-parent-rst {
  background-color: var(--pat-calendar-parent-rst);
}
.calendar-content-item-rst {
  &:nth-of-type(odd) {
    background-color: var(--pat-calendar-odd-rst);
  }
  &:nth-of-type(even) {
    background-color: var(--pat-calendar-even-rst);
  }
  &:hover {
    background-color: rgba(25, 150, 252, 0.301);
  }
}

// その他項目に適用する背景色
.calendar-content-parent-other {
  background-color: var(--pat-calendar-parent-other)!important;
}
.calendar-content-item-other {
  &:nth-of-type(odd) {
    background-color: var(--pat-calendar-odd-other);
  }
  &:nth-of-type(even) {
    background-color: var(--pat-calendar-even-other);
  }
  &:hover {
    background-color: rgba(25, 150, 252, 0.301);
  }
}

// 他施設項目に適用する背景色
.calendar-content-item-other-facility {
  &:nth-of-type(odd) {
    background-color: rgba(47, 255, 47, 0.2);
  }
  &:nth-of-type(even) {
    background-color: rgba(96, 255, 96, 0.2);
  }
  &:hover {
    background-color: rgba(0, 255, 0, 0.2);
  }
}

// add FNSI-穿刺針と治療提案の情報表示を最適化します 関 start
.line-3-limit {
  white-space: normal;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  /* add #6462 文字サイズ：特大のときに指示コメントが見切れる。 xiaosonglei start */
  max-height: 65px;
  overflow: hidden;
  /* add #6462 文字サイズ：特大のときに指示コメントが見切れる。 xiaosonglei end */

  /* add #9846 start */
  /* padding: .25em 0;*/
  /* add #9846 end */
  
}
// add FNSI-穿刺針と治療提案の情報表示を最適化します 関 end
// add FNSI-関test start
.prefix-content-red {
  background-color: var(--ntss-has-prefix-background-color)!important;
}
.prefix-content-color {
  color: var(--ntss-has-prefix-color)!important;
}
// add FNSI-関test end
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
// カレンダー内のセルの表示に時間がかかる・スクロールによる追加読み込みがされない shan start
thead {
  position: sticky;
  top: 0;
  // mod #8091 2023/04/13 患者カレンダー/患者カレンダーレイアウトマスタの動作不正  mstではグラフを設定するのに、患カレには表示されなかった。林峻峰 start
  z-index: 99999999;
  // mod #8091 2023/04/13 患者カレンダー/患者カレンダーレイアウトマスタの動作不正  mstではグラフを設定するのに、患カレには表示されなかった。林峻峰 end
}
// カレンダー内のセルの表示に時間がかかる・スクロールによる追加読み込みがされない shan end
</style>

<style scoped>
.content-popover :deep(.popover__content) {
  width: 300px;
  max-height: 200px;
  font-size: 1.5em;
  padding: 5px;
  overflow-y: auto;
}

.content-popover-content {
  margin: 5px;
}

/* add FNSI-NO544-日付ヘッダクリック時の吹き出し表示で日付と曜日の表示が必要 関 start */
.fnsi-border-bottom {
  border-bottom: 1px solid var(--ntss-base-color);
  color: var(--ntss-base-color);
}
/* add FNSI-NO544-日付ヘッダクリック時の吹き出し表示で日付と曜日の表示が必要 関 end */
/* add FNSI-redmine #4027[文字サイズを特大にすると基準日の日付が見切れてしまう]を修正 江 start */
.input-date{
  font-size: 1em;
  height: 1.6em!important;
}
/* add FNSI-redmine #4027[文字サイズを特大にすると基準日の日付が見切れてしまう]を修正 江 end */
/*  add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 start */
.triangles{
  /* #8091 2023/04/06 黒背景で「展開する」、プルダウンの文字列が背景と同化して見えなくなる。 start */
  /* color: black; */
  color: var(--ntss-base-color);
  /* #8091 2023/04/06 黒背景で「展開する」、プルダウンの文字列が背景と同化して見えなくなる。 end */
  cursor: pointer;
  display: block;
}
.common-calendar-area {
  margin: 0 auto;
  display: flex;
  align-items: center;
  min-width: 300px; 
}
.calendar-content-input{
  display: flex;
  justify-items: center;
}
/*  add #8091 2023/03/14 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 end */
/* FNSi-9947-患者カレンダーの展開動作がされていない zhoubin add start */
.date-date{
  display: inline-block;
}
.calendar-content-category-item{
  margin-left: 0;
}
.categoryTriangles{
  width: 15px;
}
/* FNSi-9947-患者カレンダーの展開動作がされていない zhoubin add end */
.indent-child {
  padding-left: 15px;
}
.calendar-date-baseday {
  outline: 3px solid #1a71cc;
  outline-offset: -4px;
}
@media print {
  .calendar-body {
    border-collapse: separate;
    border-spacing: 0;
    position: absolute;
  }
  .calendar-weekday {
    border-inline: 1px solid rgba(255, 255, 255, 0.4);
  }
  .calendar-content {
    min-height: 2em;
  }
  .common-calendar-area {
    margin-left: 45% !important;
  }
  .right-margin-area {
    display: none;
  }
}
</style>
