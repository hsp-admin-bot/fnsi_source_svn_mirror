/**
 * マルチカレンダー
 */
<template>
  <modal-base @onClose="cancel" class="custom-modal">
    <template #body>
      <div class='account-edit'>
      <div class="monthPicker" v-show="getModalTitle === '水質検査予定作成'">
        <label style="margin-right:20px;">指定年月</label>
        <input
          type="month"
          v-model="selectedMonth"
          max="2099-12"
          :min="sysMonth"
          @change="onChangeMonth($event)"
          v-month-wheel
        />
      </div>
      <div class="multi-calendar-picker-wrap">
      <vc-date-picker
        :key="calendarKey"
        class="ntss-theme-screen multi-calendar-picker"
        :columns="$screens({ default: 1, md: 2, lg: 3, xl: 4 })"
        :rows="$screens({ default: 12, md: 6, lg: 4, xl: 3 })"
        :is-expanded="true"
        :disable-page-swipe="true"
        :min-date="canSelectMinDate"
        :max-date="canSelectMaxDate"
        color="orange"
        mode="multiple"
        v-model="selectedDateList"
        is-inline
      >
        <template #header-prev-button></template>
        <template #header-next-button></template>
        <template #nav-prev-button></template>
        <template #nav-next-button></template>
        <template #header-title="page">
          <div class="multi-calendar-header-title">{{ getLegacyCalendarHeaderTitle(page) || page.title }}</div>
        </template>
      </vc-date-picker>
      </div>
      </div>
    </template>
    <template #footer>
      <div class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <!-- mod 画面スタイル(ボタン)対応 徐 start -->
        <!-- <button class="button denial-btn" @click="cancel">キャンセル</button> -->
        <button class="button btn2-cancel" @click="cancel">キャンセル</button>
        <!-- mod 画面スタイル(ボタン)対応 徐 end -->
      </div>
      <div class="registration-btn-area" style="background:none">
        <!--mod FNSI-改修内容「水質管理の表示」を「修正」に変更 江 start-->
        <!-- <button class="button registration-btn" @click="registration" >確定</button> -->
        <!-- mod 画面スタイル(ボタン)対応 徐 start -->
        <!-- <button class="button registration-btn" @click="registration" >保存</button> -->
        <span v-if="getModalTitle === '水質検査予定作成'">
<!--          mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start-->
<!--          <button class="button registration-btn btn1-execute" @click="registration" >保存</button>  -->
          <button class="button registration-btn btn1-execute" :disabled="!isChanged" @click="registration" >保存</button>
<!--          mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end-->
        </span>
        <span v-else>
          <button class="button registration-btn btn1-execute" @click="registration" >確定</button>
        </span>
        <!-- mod 画面スタイル(ボタン)対応 徐 end -->
        <!--mod FNSI-改修内容「水質管理の表示」を「修正」に変更 江 end-->
      </div>
      </div>
    </template>
  </modal-base>
</template>

<script>
import { getScopedElementsByClassName } from "@/functions/common/LayoutMeasureHelper";

import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import dayjs from "@/compat/date/dayjs";
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end

export default {
  name: "multi-calender",
  mixins: [MultiModalMixin],
  components: {
    "modal-base": ModalBase
  },
  data() {
    return {
      //選択済の日付リスト
      selectedDateList: [],
      // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start
      initSelectedDateList: [],
      // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end
      //最小選択可能日付
      canSelectMinDate: null,
      //最大選択可能日付
      canSelectMaxDate: null,
      //指定年月
      selectedMonth: null,
      //現在年月
      sysMonth: null,
      //カレンダーキー
      calendarKey: 1
    };
  },
  computed: {
    ...mapGetters("multi-calendar", [
      "getSelectedDateList",
      "getDisplaySelectedDateList"
    ]),
    ...mapGetters("multi-modal", ["getModalTitle"]),
    // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start
    isChanged() {
      let copySelectedDateList = JSON.parse(JSON.stringify(this.selectedDateList));
      if(copySelectedDateList === null || copySelectedDateList === ''){
        copySelectedDateList = [];
      }
      return JSON.stringify(this.initSelectedDateList) !== JSON.stringify(copySelectedDateList)
    }
    // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end
  },
  methods: {
    getLegacyCalendarHeaderTitle(page = {}) {
      const monthLabels = [
        "一月",
        "二月",
        "三月",
        "四月",
        "五月",
        "六月",
        "七月",
        "八月",
        "九月",
        "十月",
        "十一月",
        "十二月",
      ];
      const englishMonthIndex = {
        jan: 1,
        january: 1,
        feb: 2,
        february: 2,
        mar: 3,
        march: 3,
        apr: 4,
        april: 4,
        may: 5,
        jun: 6,
        june: 6,
        jul: 7,
        july: 7,
        aug: 8,
        august: 8,
        sep: 9,
        sept: 9,
        september: 9,
        oct: 10,
        october: 10,
        nov: 11,
        november: 11,
        dec: 12,
        december: 12,
      };
      const toMonthLabel = value => {
        const month = Number(value);
        if (!Number.isFinite(month) || month < 1 || month > 12) return "";
        return monthLabels[month - 1];
      };
      const title = String(page.title || "").trim();
      const yearLabel = page.yearLabel
        || page.year
        || page?.month?.year
        || title.match(/(\d{4})/)?.[1]
        || "";
      let monthLabel = page.monthLabel
        || toMonthLabel(page.month)
        || toMonthLabel(page.monthNumber)
        || toMonthLabel(page?.month?.month);

      if (!monthLabel) {
        monthLabel = title.match(/年\s*([一二三四五六七八九十]+月)/)?.[1]
          || title.match(/([一二三四五六七八九十]+月)/)?.[1]
          || "";
      }
      if (!monthLabel) {
        monthLabel = toMonthLabel(title.match(/年\s*(\d{1,2})\s*月/)?.[1]
          || title.match(/(?:^|\D)(\d{1,2})\s*月/)?.[1]);
      }
      if (!monthLabel) {
        const englishMonthKey = title.match(/([A-Za-z]+)/)?.[1]?.toLowerCase();
        monthLabel = toMonthLabel(englishMonthIndex[englishMonthKey]);
      }

      if (!yearLabel && !monthLabel) return title;
      return `${yearLabel}年${monthLabel}`;
    },
    ...mapActions("multi-calendar", [
      "setSelectedDateList",
      "setDisplaySelectedDateList",
      "setDsplayState"
    ]),
    /**
     * キャンセル処理
     */
    cancel() {
      const storeList = this.getDisplaySelectedDateList;
      const inputList = this.selectedDateList;
      // 変更の有無を判断
      var isChange = false;
      if (storeList.length != inputList.length){
        isChange = true;
      }else{
        for (let i = 0, n = storeList.length; i < n; ++i) {
          if (storeList[i] !== inputList[i]) isChange = true;
        }
      }
      // 変更がある場合はメッセージを表示
      if (isChange) {
        this.$ons.notification.confirm({
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
              // title: "内容破棄",
              title: DIALOG_MESSAGES[13000004].title,
              // message: "編集内容が破棄されます。</br>よろしいですか？",
              message: messageFormat(DIALOG_MESSAGES[13000004].message),
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer == 1) {
              //OK
              this.close();
            }
          }
        });
      } else {
        this.close();
      }
    },
    /**
     * 確定処理
     */
    registration() {
      this.setDisplaySelectedDateList(this.selectedDateList);
      this.setSelectedDateList(this.convertSelectedDateList());
      this.close();
      EventBus.$emit("onCloseMultiCalendarModal");
      EventBus.$emit("createBulkPlan");
    },
    /**
     * 選択済の日付をyyyy-mm-ddに変換
     */
    convertSelectedDateList(){
      const dtList = [];
      this.selectedDateList.forEach(dt => {
        const y = dt.getFullYear();
        const m = ("00" + (dt.getMonth()+1)).slice(-2);
        const d = ("00" + dt.getDate()).slice(-2);

        dtList.push(y + "-" + m + "-" + d);
      });
      return dtList;
    },
    /**
     * ダイアログを閉じる
     */
    close(){
      this.hideModal();
      this.setDsplayState(false);
    },
    /**
     * 指定年月選択時の処理
     */
    onChangeMonth(e) {
      this.calendarKey = e.target.value;
      const sysDate = new Date();
      const selectMonth = new Date(e.target.value);

      if (e.target.value > this.sysMonth) {
        //未来の年月を指定した場合、指定年月から計算して最小日付・最大日付を更新する
        this.canSelectMinDate = dayjs(selectMonth).format("YYYY-MM-DD");
        this.canSelectMaxDate = dayjs(new Date(selectMonth.getFullYear(), selectMonth.getMonth() + 12, 0)).format("YYYY-MM-DD");
      } else {
        //現在年月を指定した場合、現在日付から計算して最小日付・最大日付を更新する
        this.canSelectMinDate = dayjs(sysDate).format("YYYY-MM-DD");
        this.canSelectMaxDate = dayjs(new Date(sysDate.getFullYear(), sysDate.getMonth() + 12, 0)).format("YYYY-MM-DD");
      }

      this.$nextTick(() => {
        this.reStyleCalendar();
      })
    },
    /**
     * カレンダーのスタイル設定(DOMでクラス設定ができない為ここでクラスを付与する)
     */
    reStyleCalendar() {
      let elemReset = getScopedElementsByClassName('vc-reset', this.$el || this);
      elemReset = Array.from( elemReset ) ;
      elemReset.forEach(obj => obj.style.border = "none");

      let elemsWeeks = getScopedElementsByClassName('vc-weeks', this.$el || this);
      elemsWeeks = Array.from( elemsWeeks ) ;
      elemsWeeks.forEach(obj => obj.style.padding = "0px");
    }
  },
  created() {
    //表示状態を更新
    this.setDsplayState(true);
    //選択済日付リストの設定
    this.selectedDateList = Array.from(this.getDisplaySelectedDateList);
    //最小選択可能日付の設定（システム日付）
    const minDay = new Date();
    this.canSelectMinDate = minDay;
    //最大選択可能日付の設定（11か月後の月末）
    const maxDt = new Date(minDay.getFullYear(), minDay.getMonth() + 12, 0);
    this.canSelectMaxDate = maxDt;
    //現在年月
    this.sysMonth = dayjs(new Date()).format("YYYY-MM");
    //指定年月
    this.selectedMonth = this.sysMonth;
  },
  mounted() {
    this.reStyleCalendar();
    // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start
    this.initSelectedDateList = JSON.parse(JSON.stringify(this.selectedDateList))
    // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end
  }
};
</script>

<style scoped>
.monthPicker {
  margin: 5px 20px 20px 20px;
  text-align: left;
}
</style>

<style>
  .multi-calendar-picker.vc-container,
  .multi-calendar-picker .vc-container {
    width: 100% !important;
    max-width: none !important;
    border: none !important;
    background: transparent !important;
  }
  .multi-calendar-picker .vc-pane-container,
  .multi-calendar-picker .vc-pane-layout {
    width: 100% !important;
    max-width: none !important;
  }
  .multi-calendar-picker .vc-pane-layout {
    display: grid !important;
    grid-template-columns: repeat(1, minmax(0, 1fr)) !important;
    align-items: start !important;
  }
  @media (min-width: 768px) {
    .multi-calendar-picker .vc-pane-layout {
      grid-template-columns: repeat(2, minmax(0, 1fr)) !important;
    }
  }
  @media (min-width: 992px) {
    .multi-calendar-picker .vc-pane-layout {
      grid-template-columns: repeat(3, minmax(0, 1fr)) !important;
    }
  }
  @media (min-width: 1200px) {
    .multi-calendar-picker .vc-pane-layout {
      grid-template-columns: repeat(4, minmax(0, 1fr)) !important;
    }
  }
  .multi-calendar-picker .vc-pane {
    width: auto !important;
    min-width: 0 !important;
    max-width: none !important;
    box-sizing: border-box !important;
  }
  .multi-calendar-picker .vc-pane-header-wrapper {
    display: none !important;
    height: 0 !important;
    overflow: hidden !important;
  }
  .multi-calendar-picker .vc-pane > .vc-header {
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
  .multi-calendar-picker .vc-pane > .vc-header .vc-title-wrapper,
  .multi-calendar-picker .vc-pane > .vc-header button.vc-title {
    width: 100% !important;
    display: flex !important;
    justify-content: center !important;
    align-items: center !important;
    margin: 0 auto !important;
  }
  .multi-calendar-picker .vc-pane {
    min-width: 0 !important;
    overflow: hidden !important;
    border: solid 1px rgb(190, 190, 190) !important;
    border-radius: 10px !important;
    margin: 0 8px 16px !important;
    background: #fff !important;
    box-sizing: border-box !important;
  }
  .multi-calendar-picker .vc-weekdays {
    min-height: 28px !important;
  }
  .multi-calendar-picker .vc-weekday,
  .multi-calendar-picker .vc-weekdays .weekday-1,
  .multi-calendar-picker .vc-weekdays .weekday-7,
  .multi-calendar-picker .vc-weekdays .vc-weekday-1,
  .multi-calendar-picker .vc-weekdays .vc-weekday-7 {
    box-sizing: border-box !important;
    min-height: 28px !important;
    line-height: 28px !important;
    padding: 2px 0 !important;
    background-color: #77a0ed !important;
    color: #fff !important;
    font-weight: 700 !important;
  }
  .multi-calendar-picker-wrap {
    width: 100%;
    overflow-x: hidden;
    overflow-y: visible;
  }
  .multi-calendar-picker .vc-header .vc-arrow,
  .multi-calendar-picker .vc-header button[aria-label*="Previous"],
  .multi-calendar-picker .vc-header button[aria-label*="Next"],
  .multi-calendar-picker .vc-header button[aria-label*="前"],
  .multi-calendar-picker .vc-header button[aria-label*="次"] {
    display: none !important;
    pointer-events: none !important;
  }
  .multi-calendar-picker .vc-pane > .vc-header .vc-title,
  .multi-calendar-picker .vc-pane > .vc-header button.vc-title,
  .multi-calendar-picker .vc-title,
  .multi-calendar-picker .multi-calendar-header-title {
    pointer-events: none !important;
    cursor: default !important;
    background: transparent !important;
    border: none !important;
    color: white !important;
    font-size: 15px !important;
    line-height: 26px !important;
    width: 100% !important;
    text-align: center !important;
  }
  .multi-calendar-picker .vc-nav-popover-container,
  .multi-calendar-picker .vc-popover-content-wrapper {
    display: none !important;
  }
  .multi-calendar-picker .vc-day:not(.weekday-1):not(.weekday-7) .vc-day-content:not(.vc-disabled):not([disabled]):not(.vc-highlight-content-solid):not(.vc-highlight-content-light):not(.vc-highlight-content-outline) {
    color: #000;
  }
  .multi-calendar-picker .vc-day.weekday-2 .vc-day-content:not(.vc-disabled):not([disabled]):not(.vc-highlight-content-solid):not(.vc-highlight-content-light):not(.vc-highlight-content-outline),
  .multi-calendar-picker .vc-day.weekday-3 .vc-day-content:not(.vc-disabled):not([disabled]):not(.vc-highlight-content-solid):not(.vc-highlight-content-light):not(.vc-highlight-content-outline),
  .multi-calendar-picker .vc-day.weekday-4 .vc-day-content:not(.vc-disabled):not([disabled]):not(.vc-highlight-content-solid):not(.vc-highlight-content-light):not(.vc-highlight-content-outline),
  .multi-calendar-picker .vc-day.weekday-5 .vc-day-content:not(.vc-disabled):not([disabled]):not(.vc-highlight-content-solid):not(.vc-highlight-content-light):not(.vc-highlight-content-outline),
  .multi-calendar-picker .vc-day.weekday-6 .vc-day-content:not(.vc-disabled):not([disabled]):not(.vc-highlight-content-solid):not(.vc-highlight-content-light):not(.vc-highlight-content-outline) {
    color: #000 !important;
  }
  .multi-calendar-picker .vc-day.is-disabled .vc-day-content,
  .multi-calendar-picker .vc-day-content.vc-disabled,
  .multi-calendar-picker .vc-day-content[disabled] {
    color: #999;
  }

@media print {
  /* モーダル全般 */
  .modal-mask .modal-container {
    width: 99%;
  }

  /* ページわかれるのを防止 */
  .modal-mask .modal-wrapper {
    width: 100%;
  }
  .account-edit .vc-reset {
    margin-left: -10px;
  }
  /* 各月のpaneの余白調整 */
  .account-edit .vc-pane {
    margin-left: 5px !important;
    margin-right: 5px !important;
    break-inside: avoid;
  }
}
</style>
