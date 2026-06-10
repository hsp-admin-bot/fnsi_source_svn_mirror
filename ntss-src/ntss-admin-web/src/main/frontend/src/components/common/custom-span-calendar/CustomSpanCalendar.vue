/** * 日付カレンダー */

<template>
  <span
    class="treatment-summary"
    :class="computedClasses"
    ref="button"
    onfocus="(function(e){e.stopImmediatePropagation()})(event)"
    @click="toggleDatePickerVisibility($event)"
  >
    {{ valueInput }}
  </span>
</template>

<script>
import Pikaday from "pikaday";
import moment from "moment";
import {mapGetters,mapState} from "vuex";

export default {
  props: {
    /**
     * @description 選択された日付
     */
    value: {
      type: String,
      default: ""
    },

    dateShowInput: {
      type: String,
      default: ""
    },

    /**
     * @description 無効日付
     */
    disabledDates: {
      type: Array,
      default: () => []
    },

    /**
     * @description 無効日付
     */
    disabledNotExistDates: {
      type: Array,
      default: () => []
    },

    /**
     * @description 無効曜日(該当する日付を無効)
     */
    disabledWeekdays: {
      type: Array,
      default: () => []
    },

    /**
     * @description 何個の月を表示する
     */
    numberOfMonths: {
      type: Number,
      default: 1
    },

    /**
     * @description イベントあり日付
     */
    selectedDates: {
      type: [Array, Object],
      default: () => []
    },

    /**
     * @description 過去日の有効無効
     */
    isDisabledPastDates: {
      type: Boolean,
      default: false
    },

    /**
     * @description 指定日までの日付を無効
     */
    disableDatesBefore: {
      type: String,
      default: ""
    },

    /**
     * @description 指定日からの日付を無効
     */
    disableDatesAfter: {
      type: String,
      default: ""
    },

    /**
     * @description 生年月日モード
     * @summary 初期値を75年前にする用
     */
    birthdayMode: {
      type: Boolean,
      default: false
    },

    /**
     * @description 表示のみモード(選択不可)
     */
    viewMode: {
      type: Boolean,
      default: false
    },
    disablefacility:{
      // 下記で定義しているdefault値は、Object型の為、Arrayと異なるというエラーがブラウザのコンソールに出ていた為修正
      type: Object,
      // mod FNSI-修正 共有設定 房 start
      // default: () => []
      default: () => {}
      // mod FNSI-修正 共有設定 房 end
    },
    
    /**
     * @description 入力要素に適用するカスタムCSSクラス
     */
    classes: {
      type: String,
      default: ""
    },
  },

  data() {
    return {
      /**
       * @description pikadayオブジェクト
       */
      datePicker: {},
      valueInput: "",

      /**
       * @description 画面の高さ(レスポンシブ対応)
       */
      windowHeight: window.innerHeight,

      /**
       * @description 画面の幅(レスポンシブ対応)
       */
      windowWidth: window.innerWidth
    };
  },

  computed: {
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapState("treatment-record/common", ["ordNoDataSourcesState"]),
    selectedDatesComputed() {
      return Array.isArray(this.selectedDates)
        ? { default: this.selectedDates }
        : this.selectedDates;
    },

    /**
     * @description pikaday設定
     */
    datePickerOptions() {
      return {
        firstDay: 1,
        format: "YYYY-MM-DD",
        i18n: {
          previousMonth: "前",
          nextMonth: "次",
          months: [
            "1月",
            "2月",
            "3月",
            "4月",
            "5月",
            "6月",
            "7月",
            "8月",
            "9月",
            "10月",
            "11月",
            "12月"
          ],
          weekdays: [
            "日曜日",
            "月曜日",
            "火曜日",
            "水曜日",
            "木曜日",
            "金曜日",
            "土曜日"
          ],
          weekdaysShort: ["日", "月", "火", "水", "木", "金", "土"]
        },
        position: "bottom right",
        yearSuffix: "年",
        yearRange: [
          new Date().getFullYear() - 100,
          new Date().getFullYear() + 100
        ],
        showMonthAfterYear: true,
        showDaysInNextAndPreviousMonths: true,
        numberOfMonths: this.numberOfMonths,
        events: this.selectedDatesComputed.default.map(item => {
          return moment(item, "YYYYMMDD", "en").format("ddd MMM DD YYYY");
        }),
        disableDayFn: d => {
          const date = moment(d).format("YYYYMMDD");
          const today = moment().format("YYYYMMDD");

          return (
            this.viewMode ||
            this.disabledWeekdays.includes(moment(d).isoWeekday()) ||
            this.disabledDates.includes(date) ||
            !this.disabledNotExistDates.includes(date) ||
            (this.isDisabledPastDates && date < today) ||
            (this.disableDatesBefore && date < this.disableDatesBefore) ||
            (this.disableDatesAfter && date > this.disableDatesAfter)
          );
        }
      };
    },
    computedClasses() {
      const classList = [];
      if (this.classes !== "") {
        classList.push(...this.classes.split(" "));
      }
      return classList;
    }
  },

  watch: {
    dateShowInput() {
      if (this.dateShowInput) {
        this.valueInput = this.dateShowInput.replace(/-/g, "/");
      } else {
        this.valueInput = "";
      }
    },

    datePickerOptions() {
      this.instantiateDatePicker();
    }
  },

  mounted() {
    this.instantiateDatePicker();
    // modify by 史 for 6119 ブラウザがOut of Memoryのエラーが発生する
    this.windowHeight = window.innerHeight;
    window.addEventListener("resize",this.windowResizeEvent);
    if (this.birthdayMode && this.value === null) {
      // 生年月日モードかつ日付が未入力で開かれたとき75年前の今日を表示
      this.datePicker.gotoDate(
        moment()
          .subtract(75, "years")
          .toDate()
      );
    } else {
      // それ以外は入力されている日付を選択
      this.datePicker.setDate(this.value);
      if (this.dateShowInput)
        this.valueInput = this.dateShowInput.replace(/-/g, "/");
      else {
        this.valueInput = "";
      }
    }
  },

  methods: {
    /**
     * @description pikaday(日付カレンダー)インスタンスを作成
     */
    instantiateDatePicker() {
      this.datePicker?.el?.removeEventListener("wheel", this.addScrollEvent, { passive: false });
      this.datePicker.destroy && this.datePicker.destroy();
      this.datePicker = new Pikaday({
        field: this.$refs.button,
        onSelect: (val) => {
          if (this.value) {
            this.$emit("inputCalendar", this.datePicker.toString());
          } else {
            this.$emit("inputCalendar", moment(val).format("YYYY-MM-DD"));
          }
        },
        onOpen: () => {
          this.datePickerVisible = true;
          this.$emit("spanCalendarOpen");
        },
        onClose: () => {
          this.datePickerVisible = false;
          this.$emit("spanCalendarClose");
        },
        onDraw: () => {
          !this.viewMode && this.addGotoToday();
          this.addCustomSelectedDates();
        },
        ...this.datePickerOptions
      });
      this.datePicker.el.addEventListener("wheel", this.addScrollEvent, { passive: false });
    },

    /**
     * @description 日付カレンダーの表示・非表示処理
     */
    toggleDatePickerVisibility(e) {
      // pikadayにある「onclick」イベントが呼び出されないように
      e.stopImmediatePropagation();

      // 配置の調整
      if (this.datePicker.isVisible()) {
        this.datePicker.hide();
      } else {
        this.datePicker.setDate(this.dateShowInput);
        this.datePicker.show();

        const parentPos = this.$refs.button.getBoundingClientRect();
        const datePickPos = this.datePicker.el.getBoundingClientRect();

        if (this.numberOfMonths > 1) {
          this.datePicker.el.style.top = `${parentPos.top -
            datePickPos.height / 2}px`;
          this.datePicker.el.style.left = `${parentPos.right}px`;

          if (datePickPos.bottom > this.windowHeight) {
            const offset = (datePickPos.bottom = this.windowHeight);
            const currentHeight = parseInt(this.datePicker.el.style.top);

            this.datePicker.el.style.top = `${currentHeight - offset}px`;
          }
        } else if (this.windowWidth - parentPos.right > datePickPos.width) {
          if (
            Math.abs(parentPos.top - datePickPos.top) <
            Math.abs(parentPos.top - datePickPos.bottom)
          ) {
            this.datePicker.el.style.top = `${datePickPos.top -
              parentPos.height}px`;
          } else {
            this.datePicker.el.style.top = `${datePickPos.top +
              parentPos.height}px`;
          }

          this.datePicker.el.style.left = `${parentPos.right}px`;
        }
      }
    },

    /**
     * @description 「今日」ボタンのインスタンスを作成
     */
    addGotoToday() {
      // 凡例・goto機能をpikadayのDOMオブジェクトに加える
      const node = document.createElement("button");
      node.innerHTML = "今日";
      if (
        this.disabledDates.includes(moment(new Date()).format("YYYYMMDD")) ||
        !this.disabledNotExistDates.includes(
          moment(new Date()).format("YYYYMMDD")
        ) ||
        this.disabledWeekdays.includes(moment(new Date()).isoWeekday())
      ) {
        node.setAttribute("class", "pika-goto-today disabled");
      } else {
        node.setAttribute("class", "pika-goto-today");
        node.onclick = () => {
          this.datePicker.gotoToday();
          this.datePicker.setDate(new Date());
        };
      }

      const node2 = document.createElement("div");
      node2.setAttribute("class", "pika-footer");
      node2.appendChild(node);

      this.datePicker.el.appendChild(node2);
    },

    /**
     * @description resizeイベントウォッチャー生成
     */

    windowResizeEvent() {
      this.windowWidth = window.innerWidth;
    },

    /**
     * @description mousescrollイベントウォッチャー生成
     */
    addScrollEvent(e) {
      if (e.deltaY > 0) {
        this.datePicker.nextMonth();
      } else {
        this.datePicker.prevMonth();
      }
      // 上位要素へのイベント伝播対策として、ホイールイベント標準動作を防止
      e.preventDefault();
      // 上位要素へのイベント伝播対策として、親へのイベント伝播を止める
      e.stopPropagation();
    },

    /**
     * @description カスタムイベント(pikadayのevents以外)に背景色をつける
     */
    addCustomSelectedDates() {
      if (this.selectedDatesComputed.default) {
        const dateElems = [
          ...this.datePicker.el.getElementsByClassName("has-event")
        ];
        dateElems.forEach(elem => {
          elem?.classList?.add("custom-span-selected");
        });
        // add FNSI-修正 共有設定 房 start
        let tempMonth = this.datePicker.calendars[0].month + 1;
        const tempYear = this.datePicker.calendars[0].year;
        if (tempMonth < 10) {
          tempMonth = "0" + tempMonth;
        }
        this.selectedDatesComputed.default.forEach(elem => {
          let dates = this.selectedDatesComputed.default.filter(e => e === elem);
          if (dates.length > 1) {
            dateElems.forEach(eachElem => {
              let compareDate = tempYear + "" + tempMonth;
              if (eachElem.innerText < 10) {
                compareDate = compareDate + "0" + eachElem.innerText;
              } else {
                compareDate = compareDate + "" + eachElem.innerText;
              }
              if (compareDate === dates[0]) {
                let cnt = this.disablefacility[compareDate]?.filter(otherFacility => otherFacility !== this.getFacilityCd).length;
                if (cnt > 0) {
                  if (eachElem.classList.contains("custom-span-selected")) {
                    eachElem.classList.remove("custom-span-selected");
                  }
                  eachElem?.classList?.add("custom-span-double-selected");
                }
              }
            });
          }
        });
        // add FNSI-修正 共有設定 房 end
        dateElems.forEach(eachElem => {
          let compareDate = tempYear + "" + tempMonth;
          if (eachElem.innerText < 10) {
            compareDate += "0" + eachElem.innerText;
          } else {
            compareDate += eachElem.innerText;
          }
          const hasOtherFacility = this.ordNoDataSourcesState?.some(item =>
            item.treatDate === compareDate &&
            item.facilityCd !== this.getFacilityCd
          );
          if (hasOtherFacility) {
            eachElem.classList.add("custom-span-double-selected");
          }
        });
      }
      if (!this.selectedDatesComputed.custom) return;

      const dateElems = [
        ...this.datePicker.el.getElementsByClassName("pika-day")
      ];
      dateElems.forEach(elem => {
        const date = moment(
          new Date(
            elem.getAttribute("data-pika-year"),
            elem.getAttribute("data-pika-month"),
            elem.getAttribute("data-pika-day")
          )
        );
        const hasCustomEvent = this.selectedDatesComputed.custom.find(
          d => d === date.format("YYYYMMDD")
        );

        if (hasCustomEvent) {
          elem?.classList?.add("has-custom-event");
        }
      });
    }
  },
  beforeDestroy() {
    this.datePicker?.el?.removeEventListener("wheel", this.addScrollEvent, { passive: false });
    this.datePicker.destroy && this.datePicker.destroy();
    this.datePicker = null
    window.removeEventListener("resize", this.windowResizeEvent);
  }
};
</script>

<style scoped>
@import "~pikaday/css/pikaday.css";

button {
  padding: 0px;
  border: none;
}
</style>
