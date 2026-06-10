<template>
  <!-- /** * 日付ヘッダーコンポーネント */ -->
  <div :id="divId" class="cls-cmp-dayheader">
    <span class="cls-day-disp" :style="{'color': titlecolor}">{{ dayname }}</span> <!-- cls-day-dispはDOM操作用。CSS定義なし。 -->
    <!-- add FNSI-集計数の修正 徐 start -->
    <!-- <span class="cls-day-disp cnt-dayheader">外来{{ outpatnum }}/入院{{ inpatnum }}/全{{ inpatnum + outpatnum }}件</span> -->
    <span class="cls-day-disp cnt-dayheader">外来{{ outpatnum }}/入院{{ inpatnum }}/全{{ inpatnum + outpatnum + notOutAndInpatnum }}件</span>
    <!-- add FNSI-集計数の修正 徐 end -->
    <span v-if="undecidednum > 0"  class="cls-day-disp undecided-cnt-dayheader">(未{{ undecidednum }}件)</span>
  </div>
</template>

<script>
//日付扱い用
import moment from "moment";
//定義
import { BACKGROUND_HEADER_PAST_DAY, BACKGROUND_HEADER_TODAY } from "@/components/schedule-list/Definitions.js";
export default {
  props: {
    propsId: {
      type: String,
      required: false,
      default: ""
    },
    propsJson: {
      type: Object,
      required: false,
      default: () => ({})
    },
    propsHoliday: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  data() {
    return {
      thisElem: null,
      dayname: "",
      inpatnum: 0,
      outpatnum: 0,
      undecidednum: 0,
      titlecolor: "white",
      // add FNSI-集計数の修正 徐 start
      notOutAndInpatnum: 0
      // add FNSI-集計数の修正 徐 end
    };
  },
  computed: {
    divId() {
      return `id_dayheader${this.propsId}`;
    }
  },
  watch: {
    divId() {},
    propsJson() {
      this.dayname = this.buildDispDate(this.propsJson.date);

      this.inpatnum = 0; //入院患者数(inpatnum NOT typo of inputnum:means in patient num)
      this.outpatnum = 0; //外来患者数(outpatnum NOT typo of outputnum:means out patient num)
      this.undecidednum = 0; // ベッド未登録、クール未登録合計数
      // add FNSI-集計数の修正 徐 start
      this.notOutAndInpatnum = 0; // 不明患者数
      // 不明患者数の設定
      if (
        typeof this.propsJson.notOutAndInpatnum !== "undefined" &&
        this.propsJson.notOutAndInpatnum !== ""
      ) {
        this.notOutAndInpatnum = this.propsJson.notOutAndInpatnum;
      }
      // add FNSI-集計数の修正 徐 end

      //入院患者数の設定
      if (
        typeof this.propsJson.inpatnum !== "undefined" &&
        this.propsJson.inpatnum !== ""
      ) {
        this.inpatnum = this.propsJson.inpatnum;
      }

      //外来患者数の設定
      if (
        typeof this.propsJson.outpatnum !== "undefined" &&
        this.propsJson.outpatnum !== ""
      ) {
        this.outpatnum = this.propsJson.outpatnum;
      }

      // ベッド未登録、クール未登録合計数の設定
      if (
        typeof this.propsJson.undecidednum !== "undefined" &&
        this.propsJson.undecidednum !== ""
      ) {
        this.undecidednum = this.propsJson.undecidednum;
      }
    }
  },
  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  created() {},
  mounted() {
    this.thisElem = document.getElementById(this.divId);
  },
  updated() {},
  methods: {
    /**
     *   表示データ組み立て処理
     *      yyyy年m月d日(曜日)
     * @param targetDate  入力日付(yyyy/mm/dd)
     */
    buildDispDate(targetDate) {

      const selectedDate = moment(targetDate);
      this.thisElem.style.background = "";

      //月、日、曜日を取得
      const month = selectedDate.month() + 1;
      const day = selectedDate.date();
      const weekday = selectedDate.day();

      //曜日を日本語化
      const weekdayStr = "日月火水木金土".charAt(weekday);

      this.titlecolor = "white";
      if (!this.propsHoliday) {
        this.titlecolor = "var(--ntss-sunday-color)";
      } else if (weekday === 0) {
        this.titlecolor = "var(--ntss-sunday-color)";
      } else if (weekday === 6) {
        this.titlecolor = "var(--ntss-saturday-color)";
      }
      if (selectedDate.isSame(moment(this.propsJson.startDate), "day")) {
        this.thisElem.style.border = 'solid';
        this.thisElem.style.borderColor = '#1a71cc';
        this.thisElem.style.borderWidth = '3px';
        this.thisElem.style.padding = "0px";
      } else {
        if (selectedDate.isBefore(moment(), "day")){
          this.thisElem.style.background = BACKGROUND_HEADER_PAST_DAY;
        }
        this.thisElem.style.border = 'none';
        this.thisElem.style.padding = '3px';
      }
      if (selectedDate.isSame(moment(), "day")){
        this.thisElem.style.background = BACKGROUND_HEADER_TODAY;
      }

      //出力の組み立て 月/日(曜日)
      const outStr = `${month}/${day}(${weekdayStr})`;

      return outStr;
    }
  }
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.cls-cmp-dayheader {
  text-align: center;
  background: transparent;
  /* FNSI-add redmine 4018 start */
  /* height: 100%; */
  height: 80%;
  /* FNSI-add redmine 4018 end */
}

.cls_move_block .cls-cmp-dayheader {
  background-image: linear-gradient(
    rgba(255, 255, 255, 0.3) 0%,
    transparent 50%,
    transparent 50%,
    rgba(0, 0, 0, 0.1) 100%
  ) !important;
  background-color: var(--ntss-list-header-background-color) !important;
}

.cnt-dayheader {
  color: white;
}
.undecided-cnt-dayheader {
  color: orange;
}
</style>
