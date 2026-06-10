/** * クールヘッダーコンポーネント */
<template>
  <div :id="divId" class="cls-cmp-kurheader">
    <div class="cls-kur-disp cls-over-text"><span>{{ kurname }}</span></div>
    <div class="cls-kur-disp"> <!-- cls-kur-dispはDOM操作用。CSS定義なし。 -->
      <!-- add FNSI-集計数の修正 徐 start -->
      <!-- <span>{{ outpatnum }}/{{ inpatnum }}/{{ inpatnum + outpatnum }}件</span> -->
      <span>{{ outpatnum }}/{{ inpatnum }}/{{ inpatnum + outpatnum + notOutAndInpatnum}}件</span>
      <!-- add FNSI-集計数の修正 徐 end -->
      <span v-if="undecidednum > 0"  class="cls-kur-disp undecided-cnt-kurheader">({{ undecidednum }})</span>
    </div>
  </div>
</template>

<script>
import moment from "moment";
import {
  BACKGROUND_HEADER_PAST_DAY, } from "@/components/schedule-list/Definitions.js";
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
    propsTreatDate: {
      type: Object,
      required: false,
      default: () => ({})
    }
  },

  data() {
    return {
      thisElem: null,
      inpatnum: 0,
      outpatnum: 0,
      undecidednum: 0,
      kurname: "",
      // add FNSI-集計数の修正 徐 start
      notOutAndInpatnum: 0
      // add FNSI-集計数の修正 徐 end
    };
  },
  computed: {
    divId() {
      return `id_kurheader${this.propsId}`;
    }
  },
  watch: {
    divId() {},
    propsJson() {
      // 日付設定のメソッドを呼び出す
      this.buildDispStyle(this.propsTreatDate.date);

      //クール名の格納
      this.kurname = this.propsJson.kurname;
      this.inpatnum = 0;
      this.outpatnum = 0;
      this.undecidednum = 0;
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
  created() {},
  mounted() {
    this.thisElem = document.getElementById(this.divId);
  },
  updated() {},
  methods: {
    /**
     *   表示データ組み立て処理
     *      a/b/c
     * @param inpatnum 入院患者数
     * @param outpatnum 外来患者数
     */
    buildDispNum(inpatnum, outpatnum) {
      //入外総計
      const totalNum = inpatnum + outpatnum;
      //出力の組み立て a/b/c a:入院 b:外来 c:総計
      const outStr = `${inpatnum}/${outpatnum}/${totalNum}`;

      return outStr;
    },
    /**
     * 表示スタイルの設定.
     * 与えられた日付が本日日付より過去の場合に、`this.thisElem`のbackgroundを変更する.
     *
     * @param treatDate  入力日付(YYYYMMDD)
     */
    buildDispStyle(treatDate) {
      this.thisElem.style.background = "";
      // 現在日付を取得する
      const currentDate = moment(new Date()).format("YYYYMMDD");

      // 過去日の設定
      if (moment(treatDate).format("YYYYMMDD") < currentDate) {
        this.thisElem.style.background = BACKGROUND_HEADER_PAST_DAY;
      }
    }
  }
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.cls-cmp-kurheader {
  text-align: center;
  background: transparent;
  font-size: 1em;
  width: 100%;
  height: 100%;
  color: white;
  box-sizing: border-box;
}

.cls_move_block .cls-cmp-kurheader {
  background: #333
}

.cls-over-text {
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
}

.undecided-cnt-kurheader {
  color: orange;
}
</style>
