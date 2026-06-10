/** * 日付カレンダー */

<template>
  <!-- modify by chamaojia 2023-05-04 [8560] 焦点のないイベントの追加  start -->
  <button
    class="ntss-btn-outset calendar"
    ref="button"
    onfocus="(function(e){e.stopImmediatePropagation()})(event)"
    @click="toggleDatePickerVisibility($event)"
    @blur="handleBlur"
  >
    <v-ons-icon icon="fa-calendar" />
  </button>
  <!-- modify by chamaojia 2023-05-04 [8560] 焦点のないイベントの追加  end -->
</template>

<script>
import Pikaday from "pikaday";
import moment from "moment";
import { EventBus } from "@/eventBus.js";

export default {
  props: {
    /**
     * @description 選択された日付
     */
    value: {
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
        //add 6686 張 start
    /**
     * @description 表示したい月
     * @summary パラメータ形式 YYYY-MM-DD
     */
    toMonth: {
      type: String,
      default: ""
    },
    //add 6686 張 end
    /**
     * @description 表示のみモード(選択不可)
     */
    viewMode: {
      type: Boolean,
      default: false
    }
    // add 7778 limingyang start
    ,
    cardDiff: {
      type: Boolean,
      default: false
    }
    // add 7778 limingyang end
    // add 10266 by kangjie 20240712 start
    ,activeDate:{
      type: Boolean,
      default: false
    }
    // add 10266 by kangjie 20240712 end
  },

  data() {
    return {
      // add 10266 by kangjie 20240712 start
      isActiveDate:this.activeDate,
      // add 10266 by kangjie 20240712 end
      // add 7778 limingyang start
       isCardDiff:this.cardDiff,
      // add 7778 limingyang end
      /**
       * @description pikadayオブジェクト
       */
      datePicker: {},

      /**
       * @description 画面の高さ(レスポンシブ対応)
       */
      windowHeight: window.innerHeight,

      /**
       * @description 画面の幅(レスポンシブ対応)
       */
      windowWidth: window.innerWidth,
      editCell: null,
      /* add by chamaojia 2023-05-04 [8560] 初期値変数の追加  --start */
      initValue : null,
      /* add by chamaojia 2023-05-04 [8560] 初期値変数の追加  --end */
      preTarget : null
    };
  },

  computed: {
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
        yearRange: [new Date().getFullYear() - 100, new Date().getFullYear() + 100],
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
              // modify 10266 by kangjie 20240712 start
            // this.disabledDates.includes(date) ||
            (!this.isActiveDate? this.disabledDates.includes(date) : !this.selectedDates.includes(date)) ||
            // modify 10266 by kangjie 20240712 end
            (this.isDisabledPastDates && date < today) ||
            (this.disableDatesBefore && date < this.disableDatesBefore) ||
            (this.disableDatesAfter && date > this.disableDatesAfter)
          );
        }
      };
    }
  },

  watch: {
    /**
     * @description 値の変更に応じたカレンダー日付選択
     * @summary 患者切り替え時はmountedが動作しないためwatchで対応
     */
    value(value) {
      if (this.birthdayMode && value === null) {
        // 生年月日モードかつ日付が未入力で開かれた場合

        // 変更前の日付が75年前の今月だった場合日付選択状態を引き継いでしまうので一旦リセット
        this.datePicker.setDate(null);
        // 75年前の今日を表示
        this.datePicker.gotoDate(
          moment()
            .subtract(75, "years")
            .toDate()
        );
      } else {
        // それ以外は入力されている日付を選択
        this.datePicker.setDate(value);
      }
    },
      //add 6686 張 start
    toMonth:{
      handler(newValue) {
      if ( newValue != "") {
        this.datePicker.gotoDate(new Date(moment(newValue).year(),moment(newValue).month()))
      }
      },
      deep:true
    },
    //add 6686 張 end
    datePickerOptions() {
      this.instantiateDatePicker();
    }
  },

  mounted() {
    this.editCell =  document.getElementsByClassName("k-edit-cell")[0];
    this.instantiateDatePicker();
    // add 6119 ブラウザがOut of Memoryのエラーが発生する 史
    window.addEventListener("resize", this.addWindowResizeEvent );
    if (this.birthdayMode && this.value === null) {
      // 生年月日モードかつ日付が未入力で開かれたとき75年前の今日を表示
      this.datePicker.gotoDate(
        moment()
          .subtract(75, "years")
          .toDate()
      );
    } else {
      // それ以外は入力されている日付を選択
      this.datePicker.setDate(this.value, true);
    }
    document.addEventListener("pointerdown", this.addPointerdownEvent);
  },

  methods: {
    /* add by chamaojia 2023-05-04 [8560] 焦点を失ったイベント関数の追加  --start */
    handleBlur (event) {
      if (this.initValue !== this.value) {
        this.$emit('blur', event)
      }
    },
    /* add by chamaojia 2023-05-04 [8560] 焦点を失ったイベント関数の追加  --end */
    /**
     * @description pikaday(日付カレンダー)インスタンスを作成
     */
    instantiateDatePicker() {
      this.datePicker?.el?.removeEventListener("wheel", this.addScrollEvent, { passive: false });
      this.datePicker.destroy && this.datePicker.destroy();
      this.datePicker = new Pikaday({
        field: this.$refs.button,
        onSelect: () => {
          if(this.editCell) this.editCell.click();
          // mod 8380 【デグレ】患者情報の生年月日が保存ができない 周安寧　start
          // mod 7778 limingyang start
          //if(!this.isCardDiff){
          if(this.isCardDiff != undefined && !this.isCardDiff){
          // mod 8380 【デグレ】患者情報の生年月日が保存ができない 周安寧　end
            let res = {isDatePicker:true};
            EventBus.$emit("calendarFlag", res);
          }
          // mod 7778 limingyang end
          this.$emit("input", this.datePicker.toString());
        },
        onOpen: () => {
          this.datePickerVisible = true;
        },
        onClose: () => {
          this.datePickerVisible = false;
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
      // add じょはく start
      let s = e.target.parentNode.previousSibling;
      //s.classList.remove("custom-input-date-invalid");
      if(undefined !== s && null !== s && s.classList) {
        s.classList.remove("custom-input-date-invalid");
      }
      // add じょはく end
      // pikadayにある「onclick」イベントが呼び出されないように
      e.stopImmediatePropagation();

      // 配置の調整
      if (this.datePicker.isVisible()) {
        this.datePicker.hide();
      } else {
        this.datePicker.show();
        /* add by chamaojia 2023-05-04 [8560] コントロール表示では初期値の割り当て  --start */
        this.initValue = this.value
        /* add by chamaojia 2023-05-04 [8560] コントロール表示では初期値の割り当て  --end */

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
        this.disabledWeekdays.includes(moment(new Date()).isoWeekday())
      ) {
        node.setAttribute("class", "pika-goto-today disabled");
      } else {
        node.setAttribute("class", "pika-goto-today");
        node.onclick = () => {
          this.datePicker.gotoToday();
          this.datePicker.setDate(new Date());
          this.$emit('todayButtonClick');
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
    addWindowResizeEvent() {
      this.windowHeight = window.innerHeight;
      this.windowWidth = window.innerWidth;
      this.datePicker.hide();
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
     * @description pointerdownイベントウォッチャー生成
     *
     */
    addPointerdownEvent(e) {
      // pointerdownがカレンダー内かどうかを取得
      var isInsideCalendar = e.target.closest('[class^="pika-"]');
      // pointerdownがカレンダー内、且つ、カレンダーボタンの連続クリックでない場合はカレンダー非表示
      // カレンダーボタンの連続クリックの際の表示/非表示はtoggleDatePickerVisibility()で実施
      if (!isInsideCalendar && (this.preTarget && this.preTarget !== e.target)) {
          this.datePicker.hide();
      }

      this.preTarget = e.target;
    },

    /**
     * @description カスタムイベント(pikadayのevents以外)に背景色をつける
     */
    addCustomSelectedDates() {
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
    },

    setSilently(value) {
      this.datePicker.setDate(value, true);
    }
  },
  beforeDestroy() {
    this.datePicker?.el?.removeEventListener("wheel", this.addScrollEvent, { passive: false });
    this.datePicker.destroy && this.datePicker.destroy();
    this.datePicker = null
    window.removeEventListener("resize", this.addWindowResizeEvent);
    // mod 8380 【デグレ】患者情報の生年月日が保存ができない 周安寧　start
    //EventBus.$off("calendarFlag");
    // mod 8380 【デグレ】患者情報の生年月日が保存ができない 周安寧　end
    document.removeEventListener("pointerdown", this.addPointerdownEvent);
  }
};
</script>

<style scoped>
@import "~pikaday/css/pikaday.css";
button.calendar {
  font-size: 1em;
}
</style>
