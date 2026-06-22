<template>
  <modal-base @onClose="cancel" class="custom-modal">
    <template #body>
      <div class="body-content">
      <div class="search-item">
        <div class="display_box0">
          <label style="font-size: 1.5em;" class="header_padding">基準日</label>
          <date-input
            class="input-time ntss-input-date ntss-custom-input start-date"
            max="9999-12-31"
            :isRequired="true"
            v-model="getParamsCalendar.date"
            @blur="applyParamsDate"
          />
          <common-calendar
            class="calender start-date-comment"
            v-model="getParamsCalendar.date"
            @blur="applyParamsDate"
            @todayButtonClick="applyParamsDate"
          />
        </div>

        <div class="display_box1">
          <label id="lbl-select" style="font-size: 1.5em;">点検項目</label>
          <v-ons-select
            v-model="getParamsCalendar.layoutGroupCd"
            class="select-item"
            :disabled="getParamsCalendar.isModify"
          >
            <option
              v-for="item in listLayoutGroup"
              :key="item.mainteLayoutGroupCd"
              :value="item.mainteLayoutGroupCd"
            >{{ item.groupName }}</option>
          </v-ons-select>
        </div>
      </div>
      <div class="periodic-calendar-picker-wrap">
      <vc-date-picker
        :key="calendarRenderKey"
        class="ntss-theme-screen periodic-calendar-picker"
        :columns="$screens({ default: 1, md: 2, lg: 3, xl: 4 })"
        :rows="$screens({ default: 12, md: 6, lg: 4, xl: 3 })"
        :is-expanded="true"
        transition="none"
        :initial-page="initialPage"
        :max-date="canSelectMaxDate"
        :attributes="calendarDisplayAttributes"
        color="orange"
        mode="date"
        :model-value="null"
        is-inline
        @update:model-value="onPickerModelValueUpdate"
        @dayclick="onCalendarDayClick"
        @did-move="onCalendarDidMove"
        @transition-end="transitionEnded"
      >
        <template #header-prev-button><span class="periodic-calendar-nav-icon">‹</span></template>
        <template #header-next-button><span class="periodic-calendar-nav-icon">›</span></template>
        <template #header-title="page">
          <div class="periodic-calendar-header-title" style="color: white;">{{ getLegacyCalendarHeaderTitle(page) || page.title }}</div>
        </template>
      </vc-date-picker>
      </div>
    </div>
    </template>
    <template #footer>
      <div class="flex-container">
      <div class="denial-btn-area" style="background: none;">
        <button
          class="btn2-cancel button denial-btn"
          @click="cancel"
        >キャンセル</button>
      </div>
      <div class="registration-btn-area" style="background: none;">
        <button
          class="btn1-execute button registration-btn"
          :disabled="!isChanged"
          @click="registration"
        >保存</button>
      </div>
    </div>
    </template>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import moment from "@/compat/date/dayjs";
import { normalizeMenteDate } from "@/functions/periodic-inspection/PeriodicInspectionDateUtil";
import { EventBus } from "@/compat/vue/event-bus.js";
import { sendRequestGetResultByDateSpan } from "@/apis/periodic-inspection";
import { InvalidLayoutGroupCd } from "@/constants/mainteConstants";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import { deepCopy, hasEqualValues } from "@/functions/common/CommonFunctions";
import {
  confirmIsOkByKey,
  alertByKey,
} from "@/functions/common/OnsenFunctions";
import DateInput from "@/components/common/DateInput";

export default {
  name: "multi-calender",
  mixins: [MultiModalMixin],
  components: {
    "common-calendar": commonCalender,
    "modal-base": ModalBase,
    "date-input": DateInput,
  },
  data() {
    return {
      selectedDateList: [],
      // システム日付の10年後までを選択可能範囲とする（過去日は制限なし）
      canSelectMaxDate: moment().add(10, "years").toDate(),
      initialPage: null,
      calendarRenderKey: 0,
      lastShowPage: null,
      oldDate: "",
      resultData: [],
      lastChangedPage: null,
    };
  },
  computed: {
    ...mapGetters("periodic-inspection", [
      "getLayoutGroupListByMachineType",
      "getListMachine",
      "getMachineSelected",
      "getParamsCalendar",
      "getDataTemp",
    ]),
    selectedMachines() {
      return this.getListMachine.filter(
        x => this.getMachineSelected.includes(x.machineNo)
      );
    },
    listLayoutGroup() {
      // 点検レイアウトグループの選択肢を
      // 選択されているすべての装置の型式が対象のもののみに絞り込む
      const listLayoutGroup = [];
      this.getLayoutGroupListByMachineType.forEach(({
        typeInfo,
        mainteLayoutGroupCd,
        groupName,
      }) => {
        const includesEveryMachine = this.selectedMachines.every(
          item => typeInfo.includes(item.machineTypeCd)
        );
        if (includesEveryMachine) {
          listLayoutGroup.push({ mainteLayoutGroupCd, groupName });
        }
      });
      return listLayoutGroup;
    },
    isChanged() {
      // この画面では画面開始時には常に日付選択されていない状態になっているので
      // 日付が1件以上選択されている場合はtrueを返す
      return !!this.selectedDateList.length;
    },
    plannedDateKeys() {
      const keys = new Set();
      this.resultData.forEach(item => {
        const dateKey = normalizeMenteDate(item.menteDate);
        if (dateKey) {
          keys.add(dateKey);
        }
      });
      return keys;
    },
    selectedDateKeys() {
      return new Set(
        this.selectedDateList.map(date => this.toSelectedDateKey(date)).filter(Boolean)
      );
    },
    calendarDisplayAttributes() {
      const dates = this.selectedDateList
        .map(date => this.toSelectedDate(date))
        .filter(Boolean);
      if (!dates.length) {
        return [];
      }
      return [{
        key: "periodic-selected-dates",
        highlight: {
          color: "orange",
          fillMode: "solid",
        },
        dates,
        pinPage: true,
      }];
    },
  },
  methods: {
    getLegacyCalendarHeaderTitle(page = {}) {
      const monthLabels = [
        "一月", "二月", "三月", "四月", "五月", "六月",
        "七月", "八月", "九月", "十月", "十一月", "十二月",
      ];
      const englishMonthIndex = {
        jan: 1, january: 1, feb: 2, february: 2, mar: 3, march: 3,
        apr: 4, april: 4, may: 5, jun: 6, june: 6, jul: 7, july: 7,
        aug: 8, august: 8, sep: 9, sept: 9, september: 9, oct: 10,
        october: 10, nov: 11, november: 11, dec: 12, december: 12,
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
    ...mapActions("periodic-inspection", ["sendRequestCreateMenteTemp"]),
    ...mapActions("loading-screen", ["executeWithLoadingScreen"]),

    toSelectedDate(value) {
      const normalized = normalizeMenteDate(value);
      if (normalized) {
        return moment(normalized, "YYYY-MM-DD").toDate();
      }
      if (value instanceof Date && !Number.isNaN(value.getTime())) {
        return value;
      }
      const parsed = moment(value);
      return parsed.isValid() ? parsed.toDate() : null;
    },
    toSelectedDateKey(value) {
      const date = this.toSelectedDate(value);
      return date ? moment(date).format("YYYY-MM-DD") : "";
    },
    toggleSelectedDate(rawDate) {
      const nextDate = this.toSelectedDate(rawDate);
      if (!nextDate) {
        return;
      }
      const dateKey = this.toSelectedDateKey(nextDate);
      const exists = this.selectedDateList.some(
        date => this.toSelectedDateKey(date) === dateKey
      );
      this.selectedDateList = exists
        ? this.selectedDateList.filter(date => this.toSelectedDateKey(date) !== dateKey)
        : [...this.selectedDateList, nextDate].sort(
          (left, right) => left.getTime() - right.getTime()
        );
    },
    onPickerModelValueUpdate() {
      // v-calendar v3 は単日選択の model 更新を出す。多選は dayclick のみで制御する。
    },
    onCalendarDayClick(day) {
      const rawDate = day?.date || day?.startDate;
      if (!rawDate) {
        return;
      }
      this.toggleSelectedDate(rawDate);
    },
    async cancel() {
      if (this.isChanged) {
        // title: "内容破棄",
        // message: "編集中の情報が破棄されます\nキャンセルしてよろしいですか？",
        const isOk = await confirmIsOkByKey(13000117);
        if (!isOk) {
          // 破棄確認でキャンセルされた場合は処理を中断する
          return;
        }
      }
      // （破棄確認でキャンセルされなかった場合は）この画面を閉じる
      this.close();
    },
    async registration() {
      const { layoutGroupCd: layoutGroupId, isModify } = this.getParamsCalendar;
      if (layoutGroupId === InvalidLayoutGroupCd) {
        // 点検項目（レイアウトグループ）が未選択の場合
        // title: "点検項目未選択",
        // message: "点検項目を選択してください。"
        alertByKey("00200120");
        return;
      }
      // #11961対応時のメモ：
      // 点検項目（レイアウトグループ）が選択されている場合は
      // this.getParamsCalendar.layoutGroupCd には
      // リストの選択肢のvalue値として
      // レイアウトグループコードを文字列にしたものが入っている
      // （ただし予定移動の場合は数値のままのレイアウトグループコードが入っている）

      await this.executeWithLoadingScreen(async () => {
        const machineInfoList = this.selectedMachines.map(item => ({
          machineNo: String(item.machineNo),
          machineTypeCd: item.machineTypeCd,
        }));
        const menteDateList = this.selectedDateList
          .map(dt => normalizeMenteDate(dt) || this.toSelectedDateKey(dt))
          .filter(Boolean);
        // 予定移動の場合は移動元の日付の情報を設定する
        const oldDate = [isModify ? this.oldDate : null];
        await this.sendRequestCreateMenteTemp({
          layoutGroupId,
          body: {
            machineInfoList,
            menteDateList,
            oldDate,
          },
        });
      });
      if (this.getDataTemp.length) {
        // 装置＋日付＋レイアウトグループコードが重複する既存レコードが存在した場合
        const { machineNo, menteDate } = this.getDataTemp[0];
        const machineName = this.selectedMachines.find(
          x => x.machineNo === machineNo
        )?.machineName || "";
        // title: "チェックエラー",
        // message: "装置「{machineName}」が{menteDate}に同じレイアウト予約があるので保存できません。",
        alertByKey(12000323, machineName, menteDate);
        return;
      }

      // 追加成功時はこの画面を閉じる
      this.close();
    },
    close() {
      // 親画面の表示更新を行う
      EventBus.$emit("postUpdate");
      this.hideModal();
    },
    onCalendarDidMove(pages) {
      const page = pages?.[0];
      if (!page) {
        return;
      }
      // v-calendar v3: 表示開始月（ページ切替後の先頭月）
      this.lastChangedPage = {
        year: page.year,
        month: page.month,
      };
      // 翻页数据在 did-move 后拉取，不使用全屏 loading，避免闪屏
      this.getResultData(this.lastChangedPage).then(() => {
        this.$nextTick(() => this.setDayContentStyle());
      });
    },
    buildInitialPageFromBaseDate() {
      const normalized = normalizeMenteDate(this.getParamsCalendar.date);
      const baseDate = normalized
        ? moment(normalized, "YYYY-MM-DD")
        : moment();
      const validBase = baseDate.isValid() ? baseDate : moment();
      const startMonth = validBase.clone().startOf("month");
      const maxMonth = moment(this.canSelectMaxDate).startOf("month");
      const visibleMonthCount = 12;
      const windowEnd = startMonth.clone().add(visibleMonthCount - 1, "months");
      // 基準月から12か月が選択上限を超える場合のみ、表示開始月を繰り下げる
      const fromDate = windowEnd.isAfter(maxMonth, "month")
        ? maxMonth.clone().subtract(visibleMonthCount - 1, "months")
        : startMonth;
      return {
        year: fromDate.year(),
        month: fromDate.month() + 1,
      };
    },
    transitionEnded() {
      this.$nextTick(() => this.setDayContentStyle());
    },
    applyParamsDate() {
      const normalized = normalizeMenteDate(this.getParamsCalendar.date);
      if (normalized && this.getParamsCalendar.date !== normalized) {
        this.getParamsCalendar.date = normalized;
        return;
      }
      const newInitialPage = this.buildInitialPageFromBaseDate();
      if (hasEqualValues(this.initialPage, newInitialPage)) {
        return;
      }
      this.initialPage = newInitialPage;
      this.lastChangedPage = newInitialPage;
      this.lastShowPage = null;
      // v-calendar v3 は initialPage の変更を監視しないため再描画する
      this.calendarRenderKey += 1;
      this.$nextTick(() => {
        this.executeWithLoadingScreen(
          this.getResultData(newInitialPage).then(this.setDayContentStyle)
        );
      });
    },
    async getResultData(page) {
      // 点検結果を取得済みの期間から変化がない場合はAPIの呼び出しは行わない
      if (hasEqualValues(this.lastShowPage, page)) return;
      this.lastShowPage = null;

      // pageの月から12か月分の点検結果データを取得する
      const aMoment = moment(new Date(page.year, page.month - 1, 1));
      const startDate = aMoment.format("YYYY-MM-DD");
      aMoment.add(11, "months").endOf("month");
      const endDate = aMoment.format("YYYY-MM-DD");
      const resultRes = await sendRequestGetResultByDateSpan(startDate, endDate);
      // 選択中の装置のデータのみに絞り込む
      const resultData = resultRes.data.filter(
        item => this.getMachineSelected.includes(item.machineNo)
      );
      this.resultData.splice(0, Infinity, ...resultData);
      this.lastShowPage = deepCopy(page);
    },
    setDayContentStyle() {
      const root = this.$el;
      if (!root) {
        return;
      }
      const todayKey = moment().format("YYYY-MM-DD");
      const dayElements = root.querySelectorAll(".periodic-calendar-picker .vc-day");

      dayElements.forEach(dayEl => {
        const content = dayEl.querySelector(".vc-day-content");
        if (!content) {
          return;
        }
        const idClass = Array.from(dayEl.classList).find(className => (
          className.startsWith("id-")
        ));
        if (!idClass) {
          return;
        }
        const dateKey = idClass.slice(3);
        content.classList.remove("periodic-day-today", "periodic-day-planned");
        content.removeAttribute("style");

        // 選択中（オレンジ）は attributes で表示。ここでは既存予定色のみ付与する。
        if (this.selectedDateKeys.has(dateKey)) {
          return;
        }
        if (this.plannedDateKeys.has(dateKey)) {
          content.classList.add("periodic-day-planned");
          return;
        }
        if (dateKey === todayKey) {
          content.classList.add("periodic-day-today");
        }
      });
    },
  },
  created() {
    // 予定移動時の移動元日付の保持
    this.oldDate = this.getParamsCalendar.date;
    const normalized = normalizeMenteDate(this.getParamsCalendar.date);
    if (normalized) {
      this.getParamsCalendar.date = normalized;
    }
    this.applyParamsDate();
  },
  mounted() {
    // 選択された装置に対する有効な点検レイアウトグループの選択肢が
    // 存在しない場合は以降の処理を中断する
    // （アラートメッセージを閉じるとこの画面も閉じられる）
    if (!this.listLayoutGroup.length) {
      // title: "定期点検レイアウト",
      // message: "選択したすべての装置に対応する定期点検レイアウトが存在しません。\n対象装置を変更するか、マスタをご確認ください。",
      alertByKey("00200159").then(this.close);
      return;
    }

    // 点検結果データの取得の完了を待って日付のDOM要素のスタイル設定を行う
    this.executeWithLoadingScreen(
      this.getResultData(this.initialPage).then(this.setDayContentStyle)
    );
  },
  watch: {
    "getParamsCalendar.date"(value, oldValue) {
      if (normalizeMenteDate(value) === normalizeMenteDate(oldValue)) {
        return;
      }
      this.applyParamsDate();
    },
    selectedDateList() {
      this.$nextTick(this.setDayContentStyle);
    },
    resultData() {
      this.$nextTick(this.setDayContentStyle);
    },
  },
};
</script>

<style scoped>
.body-content {
  padding: 10px;
}
.body-content :deep(.vc-reset) {
  border: none;
}
.body-content :deep(.vc-weeks) {
  padding: 0px;
}
.body-content :deep(.weekday-1) {
  color: red;
}
.body-content :deep(.weekday-7) {
  color: blue;
}
.search-item {
  display: flex;
  flex-wrap: wrap;
  width: 100%;
  margin-bottom: 20px;
}
.select-item {
  width: 200px;
  margin-left: 20px;
  height: 2em;
  font-size: 1.5em;
}
.input-time {
  font-size: 1.7em;
  margin-left: 20px;
}
@media only screen and (max-width: 750px) {
  .input-time {
    width: 66%;
    font-size: 1.7em;
  }
  #lbl-select {
    margin-left: 0px !important;
  }
  .select-item {
    width: 70%;
    margin-left: 16px;
    height: 2em;
    font-size: 1.5em;
  }
  .display_box1 {
    width: 95%;
    display: flex;
    align-items: center;
    margin-top: 5px;
  }
  .display_box0 {
    width: 90%;
    display: flex;
    align-items: center;
  }
  .header_padding {
    padding-left: 0px !important;
  }
}
@media only screen and (max-width: 360px) {
  .input-time {
    width: 60%;
    font-size: 1.7em;
    padding-left: 10px;
  }
  #lbl-select {
    margin-left: 0px !important;
  }
  .select-item {
    width: 65%;
    margin-left: 16px;
    height: 2em;
    font-size: 1.5em;
    margin-top: 8px;
  }
  .header_padding {
    padding-left: 0px !important;
  }
}

@media print {
  /* モーダル全般 */
  .modal-mask :deep(.modal-container) {
    width: 99%;
  }

  /* ページわかれるのを防止 */
  .modal-mask :deep(.modal-wrapper) {
    width: 100%;
  }
  .body-content :deep(.vc-reset) {
    margin-left: -10px;
  }
  /* 各月のpaneの余白調整 */
  .body-content :deep(.vc-pane) {
    margin-left: 5px !important;
    margin-right: 5px !important;
    break-inside: avoid;
  }
}
</style>
<style>
  .vc-text-lg {
    font-size: 18px;
    pointer-events: none;
  }
  .item-number {
    background-color: #00BFFF;
    color: #fff
  }
  .display_box1 {
    width: 50%;
    display: flex;
    align-items: center;
  }
  .display_box0 {
    width: 50%;
    display: flex;
    align-items: center;
  }
  .header_padding {
    padding-left: 15px;
  }
  .periodic-calendar-picker-wrap {
    position: relative;
    width: 100%;
    overflow-x: hidden;
    overflow-y: visible;
  }
  .periodic-calendar-picker .vc-day-content.periodic-day-today {
    background-color: #ffb6c1 !important;
    color: #fff !important;
    border-radius: 999px !important;
  }
  .periodic-calendar-picker .vc-day-content.periodic-day-planned {
    background-color: #00bfff !important;
    color: #fff !important;
    border-radius: 999px !important;
  }
  .periodic-calendar-picker .vc-highlight-content-solid {
    color: #fff !important;
    border-radius: 999px !important;
  }
  .periodic-calendar-picker .vc-pane-header-wrapper {
    position: absolute !important;
    top: 0 !important;
    left: 0 !important;
    right: 0 !important;
    bottom: auto !important;
    width: 100% !important;
    height: auto !important;
    margin: 0 !important;
    pointer-events: none !important;
    z-index: 5;
    background: transparent !important;
  }
  .periodic-calendar-picker .vc-pane-header-wrapper > .vc-header {
    display: flex !important;
    justify-content: space-between !important;
    align-items: flex-start !important;
    height: auto !important;
    min-height: 0 !important;
    margin: 0 !important;
    padding: 6px 8px 0 !important;
    background: transparent !important;
  }
  /* 箭头常显；仅按钮背景在悬停时显示 */
  .periodic-calendar-picker {
    --vc-header-arrow-color: #808080;
    --vc-header-arrow-hover-bg: rgba(250, 249, 246, 0.65);
  }
  .periodic-calendar-picker .vc-pane-header-wrapper .vc-arrow svg,
  .periodic-calendar-picker .vc-pane-header-wrapper .vc-arrow .k-svg-icon {
    display: none !important;
  }
  .periodic-calendar-picker .periodic-calendar-nav-icon {
    display: block !important;
    visibility: visible !important;
    opacity: 1 !important;
    color: #808080 !important;
    font-size: 40px !important;
    font-weight: 700;
    line-height: 0.85;
  }
  .periodic-calendar-picker .vc-pane-header-wrapper .vc-arrow {
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
    pointer-events: auto !important;
    width: 32px !important;
    height: 32px !important;
    overflow: visible !important;
    margin: 0 !important;
    padding: 0 !important;
    border: none !important;
    border-radius: 4px !important;
    background: transparent !important;
    background-color: transparent !important;
    box-shadow: none !important;
    color: #808080 !important;
    opacity: 1 !important;
    transition: background-color 0.15s ease;
  }
  .periodic-calendar-picker .vc-pane-header-wrapper .vc-arrow:hover:not(:disabled) {
    background: rgba(250, 249, 246, 0.65) !important;
    background-color: rgba(250, 249, 246, 0.65) !important;
    box-shadow: none !important;
  }
  .periodic-calendar-picker .vc-pane-header-wrapper .vc-arrow:disabled {
    cursor: default !important;
  }
  .periodic-calendar-picker .vc-pane-header-wrapper .vc-arrow:disabled .periodic-calendar-nav-icon {
    opacity: 0.35;
  }
  .periodic-calendar-picker .vc-pane > .vc-header {
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
  .periodic-calendar-picker .vc-pane {
    min-width: 0 !important;
    overflow: hidden !important;
    border: solid 1px rgb(190, 190, 190) !important;
    border-radius: 10px !important;
    margin: 0 8px 16px !important;
    background: #fff !important;
    box-sizing: border-box !important;
  }
  .periodic-calendar-picker .vc-weekday,
  .periodic-calendar-picker .vc-weekdays .weekday-1,
  .periodic-calendar-picker .vc-weekdays .weekday-7,
  .periodic-calendar-picker .vc-weekdays .vc-weekday-1,
  .periodic-calendar-picker .vc-weekdays .vc-weekday-7 {
    box-sizing: border-box !important;
    min-height: 28px !important;
    line-height: 28px !important;
    padding: 2px 0 !important;
    background-color: #77a0ed !important;
    color: #fff !important;
    font-weight: 700 !important;
  }
  .periodic-calendar-picker .vc-pane > .vc-header .vc-title,
  .periodic-calendar-picker .vc-pane > .vc-header button.vc-title,
  .periodic-calendar-picker .vc-title,
  .periodic-calendar-picker .periodic-calendar-header-title {
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
  .periodic-calendar-picker .vc-nav-popover-container,
  .periodic-calendar-picker .vc-popover-content-wrapper {
    display: none !important;
  }
  .periodic-calendar-picker .vc-day:not(.weekday-1):not(.weekday-7) .vc-day-content:not(.vc-disabled):not([disabled]):not(.vc-highlight-content-solid):not(.vc-highlight-content-light):not(.vc-highlight-content-outline):not(.periodic-day-today):not(.periodic-day-planned),
  .periodic-calendar-picker .vc-day.weekday-2 .vc-day-content:not(.vc-disabled):not([disabled]):not(.vc-highlight-content-solid):not(.vc-highlight-content-light):not(.vc-highlight-content-outline):not(.periodic-day-today):not(.periodic-day-planned),
  .periodic-calendar-picker .vc-day.weekday-3 .vc-day-content:not(.vc-disabled):not([disabled]):not(.vc-highlight-content-solid):not(.vc-highlight-content-light):not(.vc-highlight-content-outline):not(.periodic-day-today):not(.periodic-day-planned),
  .periodic-calendar-picker .vc-day.weekday-4 .vc-day-content:not(.vc-disabled):not([disabled]):not(.vc-highlight-content-solid):not(.vc-highlight-content-light):not(.vc-highlight-content-outline):not(.periodic-day-today):not(.periodic-day-planned),
  .periodic-calendar-picker .vc-day.weekday-5 .vc-day-content:not(.vc-disabled):not([disabled]):not(.vc-highlight-content-solid):not(.vc-highlight-content-light):not(.vc-highlight-content-outline):not(.periodic-day-today):not(.periodic-day-planned),
  .periodic-calendar-picker .vc-day.weekday-6 .vc-day-content:not(.vc-disabled):not([disabled]):not(.vc-highlight-content-solid):not(.vc-highlight-content-light):not(.vc-highlight-content-outline):not(.periodic-day-today):not(.periodic-day-planned) {
    color: #000 !important;
  }
  .periodic-calendar-picker .vc-day.weekday-1 .vc-day-content.periodic-day-today,
  .periodic-calendar-picker .vc-day.weekday-7 .vc-day-content.periodic-day-today,
  .periodic-calendar-picker .vc-day.weekday-1 .vc-day-content.periodic-day-planned,
  .periodic-calendar-picker .vc-day.weekday-7 .vc-day-content.periodic-day-planned {
    color: #fff !important;
  }
  .periodic-calendar-picker .vc-day.is-disabled .vc-day-content,
  .periodic-calendar-picker .vc-day-content.vc-disabled,
  .periodic-calendar-picker .vc-day-content[disabled] {
    color: #999;
  }
</style>
