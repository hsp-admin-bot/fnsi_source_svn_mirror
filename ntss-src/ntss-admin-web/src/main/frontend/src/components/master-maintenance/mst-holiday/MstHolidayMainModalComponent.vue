/**
 * 休日マスタモーダル
 * MstHolidayMainModalComponent
 */
<template>
  <div>
    <div class="holiday-header">
      <!-- <ul class="h-text">
        <li><a @click="prevYear" :class="{ 'disabled': isEdited }"><i class="zmdi zmdi-chevron-left"></i></a></li>
        <li>{{getEditRecord.year}}年</li>
        <li><a @click="nextYear" :class="{ 'disabled': isEdited }"><i class="zmdi zmdi-chevron-right"></i></a></li>
      </ul> -->
      <v-ons-select
       v-model="getEditRecord.year"
       @change="nextYear()"
      >
        <template v-for="item in yearList" :key="item">
          <option :value="item">{{ item }}年</option>
        </template>
      </v-ons-select>
    </div>
    <div id="mst-holiday">
      <div class="holiday-content print-height-auto" :style="heightStyles" style="min-width: 60%;" v-if="reRender">
        <div class="account-edit multi-calendar-picker-wrap">
          <vc-date-picker
            :columns="$screens({ default: 1, md: 2, lg: 2 ,xl: 3})"
            :rows="$screens({ default: 12, md: 6,  lg: 6, xl: 4 })"
            :is-expanded='true'
            :disable-page-swipe="true"
            :min-date="canSelectMinDate"
            :max-date="canSelectMaxDate"
            :attributes="calendarDisplayAttributes"
            class="ntss-theme-screen multi-calendar-picker"
            color="orange"
            mode="date"
            :model-value="null"
            :select-attribute="pickerSelectAttribute"
            @update:model-value="onPickerModelValueUpdate"
            @dayclick="onCalendarDayClick"
            is-inline>
            <template #header-title="page">
              <div style="color:white">
              {{ formatCalendarHeaderTitle(page) }}
              </div>
            </template>
          </vc-date-picker>
        </div>
      </div>
      <div class="selected-table print-height-auto" :style="heightStyles">
        <table>
          <thead>
            <th class="ntss-list-header-th-sticky" style="width: 25%">日</th>
            <th class="ntss-list-header-th-sticky" style="width: 45%">名称</th>
            <th class="ntss-list-header-th-sticky" style="width: 30%">区分</th>
          </thead>
          <tbody>
            <tr v-for="(item, key) in filterHolidayJson" v-bind:key="key">
              <td>{{item.date}}</td>
              <!-- 名称、区分 -->
              <!-- 日機装施設-祝日 権限有りの場合は編集可 -->
              <!-- 日機装施設-施設固有 常に編集可 -->
              <!-- 顧客施設-祝日、施設固有 常に編集可 -->
              <td>
                <input type="text" v-if="isNkk && item.class === '1'" v-model="item.name" />
                <input type="text" v-else-if="isNkk" v-model="item.name" :disabled="!(isUserHolidayAuthorityCds && isAdmin)" />
                <input type="text" v-else v-model="item.name" :disabled="item.nkk" />
              </td>
              <td>
                <v-ons-select v-if="item.nkk" class="holiday-class" v-model="item.holidayClass" :disabled="!(isUserHolidayAuthorityCds && isAdmin)">
                  <option value="0">祝日</option>
                  <option value="1">施設固有日</option>
                </v-ons-select>
                <v-ons-select v-if="!item.nkk" class="holiday-class" v-model="item.class">
                  <option value="0" v-if="(isNkk && isUserHolidayAuthorityCds && isAdmin) || !isNkk">祝日</option>
                  <option value="1">施設固有日</option>
                </v-ons-select>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { formatDatetime } from "@/functions/common/CommonFunctions";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import {EventBus} from "@/compat/vue/event-bus.js";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import { getModalContainerElement, getModalToolbarElement, getModalFooterElement } from '@/functions/common/LayoutMeasureHelper';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end

export default {
  mixins: [MasterMaintenanceMixin],
  name: "mstHolidayMainModal",
  data() {
    return {
      selectedDateList: [],
      dsplayState: false,
      canSelectMinDate: null,
      canSelectMaxDate: null,
      contentsAreaHeight: 400,
      reRender: true,
      holidayJson: [],
      yearList:[],
      nkkHolidayJson: [],
      isEdited: false,
      pickerSelectAttribute: {
        highlight: {
          fillMode: "outline",
          style: {
            backgroundColor: "transparent",
            border: "none",
            boxShadow: "none",
          },
        },
      },
    };
  },
  computed: {
    ...mapGetters("account-edit", ["getStateUserAccountInfo", "getFontSize"]),
    ...mapGetters("master-maintenance", ["getEditRecord", "getFilteredMasterRecordList", "getMasterRecordList", "getFacilitySwitch"]),
    ...mapGetters("user",["getUserAuthorityCds"]), // ADD 休日マスタ編集権限の対応 劉
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    heightStyles() {
      return { height: `${this.contentsAreaHeight}px` };
    },
    // -----------------------------------------
    // 日機装ユーザーか否か
    // 日機装ユーザーの場合、trueを返します。
    // -----------------------------------------
    isNkk() {
      return this.getStateUserAccountInfo.facilityCd == "nkknkk" && this.getFacilitySwitch === "nkknkk" ? true : false;
    },
    // add 休日マスタ編集権限の対応 劉 start
    isUserHolidayAuthorityCds(){
      // 顧客施設の場合、祝日権限は設定不可なので常にOFF
      return (this.getUserAuthorityCds.filter(rows => rows === "123")).length > 0 && this.isNkk
    },
    isAdmin() {
      return this.getStateUserAccountInfo.administrator === 1 ? true : false;
    },
    // add 休日マスタ編集権限の対応 劉 end
    filterHolidayJson() {
      return this.holidayJson.filter(rec => {
        return rec.date.substring(0,4) == this.getEditRecord.year;
      })
    },
    calendarDisplayAttributes() {
      const attrs = [];
      if (this.nkkHolidayJson.length > 0) {
        const nkkList = this.nkkHolidayJson
          .map(l => {
            const date = this.parseHolidayDate(l.date);
            if (!date) {
              return null;
            }
            return new Date(
              date.getFullYear(),
              date.getMonth(),
              date.getDate(),
              12, 0, 0, 0
            );
          })
          .filter(Boolean);
        attrs.push({
          key: "mst-holiday-nkk",
          highlight: "red",
          dates: nkkList,
          pinPage: true,
        });
      }
      const selectedDates = this.selectedDateList
        .map(date => this.toSelectedDate(date))
        .filter(Boolean);
      if (selectedDates.length) {
        attrs.push({
          key: "mst-holiday-selected",
          highlight: {
            color: "orange",
            fillMode: "solid",
          },
          dates: selectedDates,
          pinPage: true,
        });
      }
      return attrs;
    },
    selectedDateKeys() {
      return new Set(
        this.selectedDateList.map(date => this.toSelectedDateKey(date)).filter(Boolean)
      );
    },
    nkkDateKeys() {
      return new Set(
        this.nkkHolidayJson
          .map(item => this.normalizeHolidayDateKey(item.date))
          .filter(Boolean)
      );
    },
  },
  watch: {
    windowHeight() {
      this.calculateGridHeight();
    },
    getFontSize() {
      this.calculateGridHeight();
    },
    filterHolidayJson: {
      handler(newValue, oldValue) {
        this.modRegisteredFlag(false);
      },
      deep: true
    },
    selectedDateList: {
      handler() {
        this.syncHolidayJsonFromSelectedDates();
        this.scheduleDayContentStyleRefresh();
      },
      deep: true,
    },
    nkkHolidayJson() {
      this.scheduleDayContentStyleRefresh();
    },
  },
  methods: {
    getCalendarHeaderMonthNumber(page = {}) {
      const month = Number(page.month ?? page.monthNumber ?? page?.month?.month);
      if (month >= 1 && month <= 12) {
        return month;
      }
      const title = String(page.title || "").trim();
      const numericFromTitle = title.match(/年\s*(\d{1,2})\s*月/)?.[1]
        || title.match(/(?:^|\D)(\d{1,2})\s*月/)?.[1];
      if (numericFromTitle) {
        const parsed = Number(numericFromTitle);
        if (parsed >= 1 && parsed <= 12) {
          return parsed;
        }
      }
      const japaneseMonths = [
        "一月", "二月", "三月", "四月", "五月", "六月",
        "七月", "八月", "九月", "十月", "十一月", "十二月",
      ];
      const monthLabel = String(page.monthLabel || "").trim();
      const japaneseIndex = japaneseMonths.indexOf(monthLabel);
      if (japaneseIndex >= 0) {
        return japaneseIndex + 1;
      }
      return null;
    },
    formatCalendarHeaderTitle(page = {}) {
      const title = String(page.title || "").trim();
      const yearLabel = page.yearLabel
        || page.year
        || page?.month?.year
        || title.match(/(\d{4})/)?.[1]
        || "";
      const monthNumber = this.getCalendarHeaderMonthNumber(page);
      if (!yearLabel && monthNumber == null) {
        return title;
      }
      return `${yearLabel}年${monthNumber ?? ""}月`;
    },
    toSelectedDate(value) {
      if (value instanceof Date && !Number.isNaN(value.getTime())) {
        return new Date(value.getFullYear(), value.getMonth(), value.getDate(), 0, 0, 0, 0);
      }
      const dateStr = typeof value === "string" ? value : "";
      const parts = dateStr.match(/^(\d{4})-(\d{2})-(\d{2})/);
      if (parts) {
        return new Date(+parts[1], +parts[2] - 1, +parts[3], 0, 0, 0, 0);
      }
      const parsed = new Date(value);
      if (Number.isNaN(parsed.getTime())) {
        return null;
      }
      return new Date(parsed.getFullYear(), parsed.getMonth(), parsed.getDate(), 0, 0, 0, 0);
    },
    toSelectedDateKey(value) {
      const date = this.toSelectedDate(value);
      return date ? this.formatDate(date) : "";
    },
    normalizeHolidayDateKey(dateStr) {
      if (dateStr == null || dateStr === "") {
        return "";
      }
      const raw = String(dateStr).trim();
      if (/^\d{4}-\d{2}-\d{2}/.test(raw)) {
        return raw.substring(0, 10);
      }
      return this.formatDate(dateStr) || "";
    },
    parseHolidayDate(dateStr) {
      const key = this.normalizeHolidayDateKey(dateStr);
      if (!key) {
        return null;
      }
      const parts = key.match(/^(\d{4})-(\d{2})-(\d{2})$/);
      if (!parts) {
        return null;
      }
      return new Date(+parts[1], +parts[2] - 1, +parts[3], 0, 0, 0, 0);
    },
    toggleSelectedDate(rawDate) {
      const nextDate = this.toSelectedDate(rawDate);
      if (!nextDate) {
        return;
      }
      const dateKey = this.toSelectedDateKey(nextDate);
      const exists = this.selectedDateKeys.has(dateKey);
      this.selectedDateList = exists
        ? this.selectedDateList.filter(date => this.toSelectedDateKey(date) !== dateKey)
        : [...this.selectedDateList, nextDate].sort(
          (left, right) => left.getTime() - right.getTime()
        );
      this.scheduleDayContentStyleRefresh();
    },
    scheduleDayContentStyleRefresh() {
      this.$nextTick(() => {
        this.setDayContentStyle();
        this.$nextTick(() => this.setDayContentStyle());
      });
    },
    getDefaultDayTextColor(dayEl, dateKey) {
      if (this.nkkDateKeys.has(dateKey)) {
        return "red";
      }
      if (dayEl.classList.contains("weekday-1") || dayEl.classList.contains("vc-weekday-1")) {
        return "red";
      }
      if (dayEl.classList.contains("weekday-7") || dayEl.classList.contains("vc-weekday-7")) {
        return "blue";
      }
      return "var(--ntss-list-body-color)";
    },
    setDayContentStyle() {
      const root = this.$el;
      if (!root) {
        return;
      }
      root.querySelectorAll(".multi-calendar-picker .vc-day").forEach(dayEl => {
        const content = dayEl.querySelector(".vc-day-content");
        if (!content) {
          return;
        }
        const idClass = Array.from(dayEl.classList).find(className => className.startsWith("id-"));
        if (!idClass) {
          return;
        }
        const dateKey = idClass.slice(3);
        const textColor = this.selectedDateKeys.has(dateKey)
          ? "#fff"
          : this.getDefaultDayTextColor(dayEl, dateKey);
        content.style.setProperty("color", textColor, "important");
      });
    },
    onPickerModelValueUpdate() {
      // v-calendar v3 は単日 model を更新する。多選は dayclick + attributes のみで制御する。
      this.scheduleDayContentStyleRefresh();
    },
    onCalendarDayClick(day) {
      const rawDate = day?.date || day?.startDate;
      if (!rawDate) {
        return;
      }
      this.toggleSelectedDate(rawDate);
    },
    syncHolidayJsonFromSelectedDates() {
      const nkkCompareList = this.nkkHolidayJson.map(e => this.normalizeHolidayDateKey(e.date));
      const compareList = this.holidayJson
        .filter(e => !e.nkk)
        .map(e => this.normalizeHolidayDateKey(e.date));
      const selectedArr = [];

      this.selectedDateList.forEach(date => {
        const dateStr = this.toSelectedDateKey(date);
        if (!dateStr) {
          return;
        }
        const newItem = {
          date: dateStr,
          name: "",
          class: "",
        };
        if (nkkCompareList.includes(dateStr)) {
          if (this.countItem(this.holidayJson, dateStr) == 1) {
            this.holidayJson.push(newItem);
          }
        } else if (!compareList.includes(dateStr)) {
          this.holidayJson.push({
            date: dateStr,
            name: "",
            class: this.isNkk ? "" : "1",
          });
        }
        selectedArr.push(dateStr);
      });

      this.holidayJson = this.holidayJson.filter(
        item => item.nkk || selectedArr.includes(this.normalizeHolidayDateKey(item.date))
      );

      this.holidayJson.sort(this.sortByProperty("date"));
    },
    getCurrentModalContainer() {
      return getModalContainerElement(this.$el) || null;
    },
    getCurrentModalToolbar() {
      return getModalToolbarElement(this.$el) || null;
    },
    getCurrentModalFooter() {
      return getModalFooterElement(this.$el) || null;
    },
    getHolidayElement(selector) {
      return this.getCurrentModalContainer()?.querySelector?.(selector) || this.$el?.querySelector?.(selector);
    },
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    ...mapActions("user",["fetchUserAuthorityCds"]), // ADD 休日マスタ編集権限の対応 劉
    updateEditRecord(key, value) {
      this.getEditRecord[key] = value;
      this.setEditRecord(this.getEditRecord);
    },
    isMobile() {
      const ownerWindow = this.$el?.ownerDocument?.defaultView || window;
      return ownerWindow.matchMedia("only screen and (max-width: 760px)").matches;
    },
    countItem(arr, item) {
      const target = this.normalizeHolidayDateKey(item);
      let count = 0;
      arr.forEach(e => {
        if (this.normalizeHolidayDateKey(e.date) === target) {
          count++;
        }
      });
      return count;
    },
    /**
     * ソートする
     *
     * @param property
     * @returns {Function}
     */
    sortByProperty(property) {
      return function (x, y) {
          return ((x[property] === y[property]) ? 0 : ((x[property] > y[property]) ? 1 : -1));
      };
    },
    calculateGridHeight() {
      const modal = this.getCurrentModalContainer();
      const modalHeight = modal?.clientHeight || 0;
      const modalHeaderHeight = this.getCurrentModalToolbar()?.clientHeight || 0;
      const modalFooterHeight = this.getCurrentModalFooter()?.clientHeight || modal?.lastElementChild?.clientHeight || 0;
      const holidayHeader = this.getHolidayElement('.holiday-header')?.clientHeight || 0;
      this.contentsAreaHeight = modalHeight - modalHeaderHeight - modalFooterHeight - holidayHeader - 10; // -10は余白の微調整
    },
    validateOnRegistration() {
      // add 休日マスタ編集権限の対応 劉 start
      if (this.isNkk && !(this.isUserHolidayAuthorityCds && this.isAdmin)){
        this.holidayJson = JSON.parse(JSON.stringify(this.holidayJson.map(rec => {
          delete rec.nkk;
          return rec;
        })).replace(/holidayClass/g,"class"));
      }
      // add 休日マスタ編集権限の対応 劉 end
      const list = this.holidayJson.filter(
        item => item.nkk != true
          && +item.date.substring(0,4) == this.getEditRecord.year
      );
      this.getEditRecord.holiday = JSON.stringify(list);

      let existFlg = false;
      const mstData = this.getMasterRecordList.data;
      if(mstData) {
        mstData.forEach(element => {
          if(element.code !== this.getEditRecord.code &&
              this.getEditRecord.regDate == "" &&
              element.year == this.getEditRecord.year && element.isDisp == "1" && element.class=="0"
            ) {
            existFlg = true;
          }
        });
      }
      if(existFlg) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "選択情報（年）が重複しています。",
          title: DIALOG_MESSAGES['00200060'].title,
          message: messageFormat(DIALOG_MESSAGES['00200060'].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        this.updateEditRecord("holiday", "");
        return false;
      }

      this.setEditRecord(this.getEditRecord);
      return true;
    },
    convertSelectedDateList(dateList){
      const dtList = [];
      dateList.forEach(dt => {
        const y = dt.getFullYear();
        const m = ("00" + (dt.getMonth()+1)).slice(-2);
        const d = ("00" + dt.getDate()).slice(-2);
        dtList.push(y + "-" + m + "-" + d);
      });
      return dtList;
    },
    formatToSelectedDate() {
      let currList = this.holidayJson.filter(rec => {
        return !rec.nkk;
      });
      if(this.getEditRecord.holiday) {
        currList = JSON.parse(this.getEditRecord.holiday);
      }
      if (this.isNkk) {
        let holidays = []
        const nkkHolidays = this.nkkHolidayJson.map(e => this.normalizeHolidayDateKey(e.date));
        currList.forEach(e => {
          if (!nkkHolidays.includes(this.normalizeHolidayDateKey(e.date))) {
            holidays.push(e);
          }
        });
        currList = holidays;
      }
      this.holidayJson = currList.concat(this.nkkHolidayJson);
      return currList
        .map(l => this.parseHolidayDate(l.date))
        .filter(Boolean);
    },
    async prevYear() {
      this.setLoadingScreenVisible(true);
      const currentYear = this.getEditRecord.year;
      const prevYear = String(parseInt(currentYear) - 1);
      this.getEditRecord.year = prevYear;
      await ApiHelper.get("/mstInfo/mstHoliday/nkk", {
        holidayY : prevYear
      }).then(response => {
        if(response.status == 200) {
          // mod 休日マスタ編集権限の対応 劉 start
          // this.nkkHolidayJson = response.data;
          this.nkkHolidayJson = response.data.filter(date =>  date.holidayClass === "0");
          // mod 休日マスタ編集権限の対応 劉 end
        }
      }).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstHolidayMainModalComponent.vue', 'prevYear', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        this.setLoadingScreenVisible(false);
      });
      this.selectedDateList = this.formatToSelectedDate();
      this.setPickerDate(prevYear);
      this.reRender = false;
      this.setLoadingScreenVisible(false);
      this.$nextTick(() => {
        this.reRender = true;
        this.$nextTick(() => this.setDayContentStyle());
      });
    },
    async nextYear() {
      this.setLoadingScreenVisible(true);
      const currentYear = this.getEditRecord.year;
      const nextYear = String(parseInt(currentYear));
      this.getEditRecord.year = nextYear;
      await ApiHelper.get("/mstInfo/mstHoliday/nkk", {
        holidayY : nextYear
      }).then(response => {
        if(response.status == 200) {
          // mod 休日マスタ編集権限の対応 劉 start
          // this.nkkHolidayJson = response.data;
          this.nkkHolidayJson = response.data.filter(date =>  date.holidayClass === "0");
          // mod 休日マスタ編集権限の対応 劉 end
        }
      }).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstHolidayMainModalComponent.vue', 'nextYear', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        this.setLoadingScreenVisible(false);
      });
      this.selectedDateList = this.formatToSelectedDate();
      this.setPickerDate(nextYear);
      this.reRender = false;
      this.setLoadingScreenVisible(false);
      this.$nextTick(() => {
        this.reRender = true;
        this.$nextTick(() => this.setDayContentStyle());
      });
    },
    setPickerDate(year) {
      const minDate = new Date(year, 0, 1);
      const maxDate = new Date(minDate.getFullYear(), 11, 31);
      this.canSelectMinDate = minDate;
      this.canSelectMaxDate = maxDate;
      this.reRender = false;

      this.$nextTick(() => {
        this.reRender = true;
        this.$nextTick(() => this.setDayContentStyle());
      });
    },
    /**
     * @description フォーマット変更
     */
    formatDate(value) {
      if (value === null || value === "") {
        return null;
      }
      return formatDatetime(value, "YYYY-MM-DD");
    },
    modRegisteredFlag(flag) {
      EventBus.$emit("mstHolidayRegistered", flag);
    }
  },
  async created() {
    this.setLoadingScreenVisible(true);
    let self = this;
    if(self.getEditRecord.regDate != ""){
      self.isEdited = true;
    }
    let oldYearList = [];
    const mstData = this.getMasterRecordList.data;
      if(mstData) {
        mstData.forEach(element => {
          if(element.year != this.getEditRecord.year && element.isDisp == "1" && element.class=="0" && element.year !=""
            ) {
            oldYearList.push(parseInt(element.year))
          }
        });
      }
    if (!self.getEditRecord.year) {
      self.getEditRecord.year = String(new Date().getFullYear());
    }
    self.fetchUserAuthorityCds; // add 休日マスタ編集権限の対応 劉
    if(!(self.isUserHolidayAuthorityCds && this.isAdmin)){
      await ApiHelper.get("/mstInfo/mstHoliday/nkk", {
        holidayY : self.getEditRecord.year
      }).then(response => {
        if(response.status == 200) {
          // mod 休日マスタ編集権限の対応 劉 start
          // this.nkkHolidayJson = response.data;
          this.nkkHolidayJson = response.data.filter(date =>  date.holidayClass === "0");
          // mod 休日マスタ編集権限の対応 劉 end
        }
      }).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstHolidayMainModalComponent.vue', 'created', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        this.setLoadingScreenVisible(false);
      });
    }
    let newYearList = Object.keys(Array.apply(null, {length:201})).map(function(item){
      return (1899+parseInt(item)+1);
    })
    this.yearList = newYearList.filter(e => !oldYearList.includes(e));
    while(this.yearList.filter(e=> e == parseInt(this.getEditRecord.year)).length == 0) {
      this.getEditRecord.year = parseInt(this.getEditRecord.year) +1;
    }
    self.dsplayState = true;
    self.selectedDateList = self.formatToSelectedDate();
    self.setPickerDate(self.getEditRecord.year);
  },
  mounted() {
    this.$nextTick(() => {
      this.calculateGridHeight();
    });
    setTimeout(() => {
      this.modRegisteredFlag(true);
      this.setLoadingScreenVisible(false);
      this.$nextTick(() => this.setDayContentStyle());
    }, 800);

  }
};
</script>

<style scoped>
@media print{
  .print-height-auto, .holiday-content{
    height: auto !important;
  }
}
#mst-holiday {
  display: flex;
}
.holiday-content {
  flex: 1;
  overflow: auto;
}
.selected-table {
  overflow: auto;
  min-width: calc(30% - 20px);
}
.selected-table th {
  text-align: left;
}
.selected-table table {
  position: relative;
  width: auto;
  min-width: 100%;
}
.selected-table table tbody tr {
  line-height: 30px;
}
.selected-table table td {
  padding: 2px;
}
.selected-table input[type="text"] {
  width: calc(100% - 10px);
  margin: 2px 2px;
  line-height: 18px;
  padding-left: 4px;
}
ons-select :deep(.select-input) {
  margin: 2px 2px;
  line-height: 20px;
  padding-left: 4px;
}
/* .selected-table .holiday-class {
  height: 24px;
} */
.selected-table select {
  width: 100%;
}
ul.h-text li {
  display: inline;
  font-weight: 600;
  padding: 0 22px;
}
.holiday-header {
  text-align: center;
}

a {
  color: black;
}

a.disabled {
  pointer-events: none;
  cursor: default;
  color: gray;
  opacity: 0.5;
}

th.ntss-list-header-th-sticky {
  z-index: 1;
}

@media screen and (min-width:650px) and (max-width: 850px) {
  .input-item-converted{
    max-width: 15%;
    min-width: 15%;
  }
  .input-item-converted-label{
    max-width: 20%;
    min-width: 20%;
  }
}

@media screen and (max-width: 650px) {
  .input-item-name {
    text-align: left;
    font-weight: bold;
    margin-bottom: 5px;
    min-width: 95%;
  }
  .input-item-txt {
    min-width: 90%;
  }
  .input-item-txt-long {
    text-align: left;
    min-width: 90%;
  }
  .input-item-txt-short {
    min-width: 90%;
  }
  .input-item-button {
    text-align: left;
    min-width: 90%;
  }
  .input-item-radio {
    min-width: 6.5em;
  }
  .input-item-check {
    min-width: 90%;
  }
  .input-item-date{
    text-align: left;
  }
  .input-item-symbol{
    min-width: 90%;
    text-align: left;
  }
  .input-item-converted{
    text-align: left;
    min-width: 30%;
    max-width: 30%;
  }
  .input-item-converted-label{
    text-align: left;
    min-width: 35%;
    max-width: 35%;
  }
  .input-item-converted-equal{
    text-align: center;
    min-width: 10%;
    max-width: 10%;
  }
  .input-newline{
    min-width:90%;
    max-width:90%;
  }
}
</style>

<style>
/* v-calendar 3 多 pane（休日マスタ）— 非 scoped，作用于库内部 .vc-* DOM */
#mst-holiday .multi-calendar-picker.vc-container,
#mst-holiday .multi-calendar-picker .vc-container {
  width: 100% !important;
  max-width: none !important;
  border: none !important;
  background: transparent !important;
}
#mst-holiday .multi-calendar-picker .vc-pane-container,
#mst-holiday .multi-calendar-picker .vc-pane-layout {
  width: 100% !important;
  max-width: none !important;
}
#mst-holiday .multi-calendar-picker .vc-pane-layout {
  display: grid !important;
  grid-template-columns: repeat(1, minmax(0, 1fr)) !important;
  align-items: start !important;
}
@media (min-width: 768px) {
  #mst-holiday .multi-calendar-picker .vc-pane-layout {
    grid-template-columns: repeat(2, minmax(0, 1fr)) !important;
  }
}
@media (min-width: 992px) {
  #mst-holiday .multi-calendar-picker .vc-pane-layout {
    grid-template-columns: repeat(2, minmax(0, 1fr)) !important;
  }
}
@media (min-width: 1200px) {
  #mst-holiday .multi-calendar-picker .vc-pane-layout {
    grid-template-columns: repeat(3, minmax(0, 1fr)) !important;
  }
}
#mst-holiday .multi-calendar-picker .vc-pane {
  width: auto !important;
  min-width: 0 !important;
  max-width: none !important;
  box-sizing: border-box !important;
}
#mst-holiday .multi-calendar-picker .vc-pane-header-wrapper {
  display: none !important;
  height: 0 !important;
  overflow: hidden !important;
}
#mst-holiday .multi-calendar-picker .vc-pane > .vc-header {
  display: flex !important;
  justify-content: center !important;
  align-items: center !important;
  grid-template-columns: 1fr !important;
  min-height: 26px !important;
  margin: 0 !important;
  padding: 0 !important;
  border-top-left-radius: 9px !important;
  border-top-right-radius: 9px !important;
  background-color: #4781ed !important;
  color: #fff !important;
}
#mst-holiday .multi-calendar-picker .vc-pane > .vc-header .vc-title-wrapper,
#mst-holiday .multi-calendar-picker .vc-pane > .vc-header button.vc-title {
  width: 100% !important;
  display: flex !important;
  justify-content: center !important;
  align-items: center !important;
  margin: 0 auto !important;
}
#mst-holiday .multi-calendar-picker .vc-pane {
  min-width: 0 !important;
  overflow: hidden !important;
  border: solid 1px rgb(190, 190, 190) !important;
  border-radius: 10px !important;
  margin: 0 15px 20px !important;
  background: var(--ntss-base-background-color) !important;
  color: var(--ntss-list-body-color) !important;
  box-sizing: border-box !important;
}
#mst-holiday .multi-calendar-picker .vc-weekdays {
  min-height: 28px !important;
}
#mst-holiday .multi-calendar-picker .vc-weekday,
#mst-holiday .multi-calendar-picker .vc-weekdays .weekday-1,
#mst-holiday .multi-calendar-picker .vc-weekdays .weekday-7,
#mst-holiday .multi-calendar-picker .vc-weekdays .vc-weekday-1,
#mst-holiday .multi-calendar-picker .vc-weekdays .vc-weekday-7 {
  box-sizing: border-box !important;
  min-height: 28px !important;
  line-height: 28px !important;
  padding: 2px 0 !important;
  background-color: #77a0ed !important;
  color: #fff !important;
  font-weight: 700 !important;
}
#mst-holiday .multi-calendar-picker-wrap {
  width: 100%;
  overflow-x: hidden;
  overflow-y: visible;
  box-sizing: border-box;
}
#mst-holiday .multi-calendar-picker .vc-header .vc-arrow,
#mst-holiday .multi-calendar-picker .vc-header button[aria-label*="Previous"],
#mst-holiday .multi-calendar-picker .vc-header button[aria-label*="Next"],
#mst-holiday .multi-calendar-picker .vc-header button[aria-label*="前"],
#mst-holiday .multi-calendar-picker .vc-header button[aria-label*="次"] {
  display: none !important;
  pointer-events: none !important;
}
#mst-holiday .multi-calendar-picker .vc-pane > .vc-header .vc-title,
#mst-holiday .multi-calendar-picker .vc-pane > .vc-header button.vc-title,
#mst-holiday .multi-calendar-picker .vc-title,
#mst-holiday .multi-calendar-picker .multi-calendar-header-title {
  pointer-events: none !important;
  cursor: default !important;
  background: transparent !important;
  border: none !important;
  color: white !important;
  font-size: 18px !important;
  line-height: 26px !important;
  width: 100% !important;
  text-align: center !important;
}
#mst-holiday .multi-calendar-picker .vc-nav-popover-container,
#mst-holiday .multi-calendar-picker .vc-popover-content-wrapper {
  display: none !important;
}
#mst-holiday .multi-calendar-picker .vc-day-content.vc-highlight-content-solid,
#mst-holiday .multi-calendar-picker .vc-highlight-content-solid.vc-day-content {
  color: #fff !important;
}
#mst-holiday .multi-calendar-picker .vc-day.weekday-1 .vc-day-content:not(.vc-disabled):not([disabled]):not(.vc-highlight-content-solid):not(.vc-highlight-content-light):not(.vc-highlight-content-outline) {
  color: red !important;
}
#mst-holiday .multi-calendar-picker .vc-day.weekday-7 .vc-day-content:not(.vc-disabled):not([disabled]):not(.vc-highlight-content-solid):not(.vc-highlight-content-light):not(.vc-highlight-content-outline) {
  color: blue !important;
}
#mst-holiday .multi-calendar-picker .vc-day.weekday-2 .vc-day-content:not(.vc-disabled):not([disabled]):not(.vc-highlight-content-solid):not(.vc-highlight-content-light):not(.vc-highlight-content-outline),
#mst-holiday .multi-calendar-picker .vc-day.weekday-3 .vc-day-content:not(.vc-disabled):not([disabled]):not(.vc-highlight-content-solid):not(.vc-highlight-content-light):not(.vc-highlight-content-outline),
#mst-holiday .multi-calendar-picker .vc-day.weekday-4 .vc-day-content:not(.vc-disabled):not([disabled]):not(.vc-highlight-content-solid):not(.vc-highlight-content-light):not(.vc-highlight-content-outline),
#mst-holiday .multi-calendar-picker .vc-day.weekday-5 .vc-day-content:not(.vc-disabled):not([disabled]):not(.vc-highlight-content-solid):not(.vc-highlight-content-light):not(.vc-highlight-content-outline),
#mst-holiday .multi-calendar-picker .vc-day.weekday-6 .vc-day-content:not(.vc-disabled):not([disabled]):not(.vc-highlight-content-solid):not(.vc-highlight-content-light):not(.vc-highlight-content-outline) {
  color: var(--ntss-list-body-color) !important;
}
#mst-holiday .multi-calendar-picker .vc-day.is-disabled .vc-day-content,
#mst-holiday .multi-calendar-picker .vc-day-content.vc-disabled,
#mst-holiday .multi-calendar-picker .vc-day-content[disabled] {
  color: #999 !important;
}
</style>
