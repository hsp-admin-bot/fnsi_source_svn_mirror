/** 患者経過総合ビューア 曜日パターン変更 */
<template>
  <div class="flex-overflow-auto">
    <div class="left-title">
      <table border="0" cellspacing="0" cellpadding="0" style="width: 4.5em">
        <tr>
          <td class="div-style left-title-td"></td>
        </tr>
        <tr>
          <td class="div-style left-title-td">変更前</td>
        </tr>
        <tr v-if="changeFlg">
          <td class="div-style left-title-td">変更後</td>
        </tr>
      </table>
    </div>
    <div class="main">
      <table border="0" cellspacing="0" cellpadding="0" width="100%" class="table-main">
        <tr>
          <td
            class="div-style height-1-94"
            :class="getStyle(date)"
            v-for="(date, index) in dateList"
            :key="index"
          >
            <div>
              &nbsp;&nbsp;{{ dateFormat(date) }}&nbsp;&nbsp;
            </div>
          </td>
        </tr>
        <tr>
          <!-- 内部remine 5840  mod ljx start-->
<!--          <td
            class="div-style-black height-1-92"
            :class="duringPeriodClass(date)"
            v-for="(date, index) in dateList"
            :key="index"
          >-->
          <td
            class="div-style-black height-1-92"
            :class="duringPeriodClass(date)"
            v-for="(date, index) in dateList"
            :key="index"
            :id="'before'+index"
            @click="showDetail(isBeforeScheduleDate(date),'before',date)"
          >
            <div>
              {{ dataFormatFir(date) }}
            </div>
          </td>
        </tr>
        <tr v-if="changeFlg">
<!--          <td
            class="div-style-black height-1-92"
            v-for="(date, index) in dateList"
            :key="index"
          >-->
          <td
            class="div-style-black height-1-92"
            v-for="(date, index) in dateList"
            :key="index"
            :id="'after'+index"
            @click="showDetail(isAfterScheduleDate(date),'after',date)"
          >
            <!-- 内部remine 5840  mod ljx end-->
            <div>
              {{ dataFormatBeh(date) }}
            </div>
          </td>
        </tr>
      </table>
    </div>
  </div>
</template>

<script>
// 日付操作
import moment from "moment";
import { mapGetters } from "vuex";
//内部remine 5840  ljx add start
import {EventBus} from "@/eventBus";
//内部remine 5840  ljx add end
import { getHolidayStyle } from "@/functions/common/CommonFunctions";
import PrintMixin from "@/components/PrintMixin";

export default {
  mixins: [PrintMixin],
  props: {
    // add #9273 施設設定マスタのNo105の設定どおり動かない。張玲 start
    indTreatStartDate: {
      type: String,
      default:""
    },
    // add #9273 施設設定マスタのNo105の設定どおり動かない。張玲 end
    changeFlg: {
      type: Boolean,
      required: true
    },
    //内部remine 5840  ljx del start
    arrowInfo: {
      type: Array,
      required: true
    },
    //内部remine 5840  ljx del start
  //add #6829 ljg start
   maxdate: {
   type: String,
   required: true
    }
  },
  //add #6829 ljg end
  data() {
    return {
      treatmentData: [],
      // add #9273 施設設定マスタのNo105の設定どおり動かない。張玲 start
      indTreatStartDateParent:'',
      // add #9273 施設設定マスタのNo105の設定どおり動かない。張玲 end
      scrollQuerySelector: ".flex-overflow-auto",
      addClassTargetQuerySelector: [".table-main"],
    };
  },

  mounted() {
  },

  computed: {
    ...mapGetters("pat-viewer", [
      "getDateList",
      //内部remine 5840  ljx add start
      "getTreatmentDataOfPeriodTmp",
      //内部remine 5840  ljx add end
      "getPriorToChangeList",
      "getAfterToChangeList"
    ]),

    /**
     * 変更日時の取得
     */
    dateList() {
      // 変更日時がなしの場合
      if (!this.getPriorToChangeList) return [];
      return this.getPriorToChangeList;
    },
  },

  watch: {
    //内部remine 5840  ljx add start
    getTreatmentDataOfPeriodTmp(){
      this.treatmentData = this.getTreatmentDataOfPeriodTmp;
    },
    // add #9273 施設設定マスタのNo105の設定どおり動かない。張玲 start
    indTreatStartDate: {
      handler(val){
        this.indTreatStartDateParent = val
      },
      deep:true,
      immediate:true,
    }
    // add #9273 施設設定マスタのNo105の設定どおり動かない。張玲 end
  },

  created() {
    //内部remine 5840  ljx mod start
    if (this.getTreatmentDataOfPeriodTmp) {
      this.treatmentData = this.getTreatmentDataOfPeriodTmp;
    }
    //内部remine 5840  ljx mod start
  },

  methods: {
    dateFormat(date) {
      if (!date) return null;
      return moment(date).format("M/D");
    },
    dataFormatFir(date) {
      // 治療予定のデータがなしの場合、処理中止
      if (!this.treatmentData) return null;

      // 同じ時間のデータを取得する
      let sameDateList = null;
      if (this.treatmentData[date]) {
        sameDateList = this.treatmentData[date];
      }

      if (!sameDateList) return null;

      // 設定画面はデータを表示する(〇：rst_dialysis_state＝0、●：rst_dialysis_state＞1)
      return sameDateList.rstDialysisState == '0' ? '〇' : '●';
    },

    dataFormatBeh(date) {
      // 治療予定のデータがなしの場合、処理中止
      if (!this.treatmentData) return null;

      // 同じ時間のデータを取得する
      let sameDateList = null;
      if (this.treatmentData[date]) {
        sameDateList = this.treatmentData[date];
      }

      // 条件配信後の場合、●を表示する
      if (sameDateList && sameDateList.rstDialysisState != '0') return '●';

      // 変更後の日付で取得しますがなしの場合、処理中止
      if (!this.getAfterToChangeList) return null;

      //  変更後の日付の場合、〇を表示する
      const findDate = this.getAfterToChangeList.find(itemDate => itemDate == date);
      //add #6829 ljg start
      let enddate=this._props.maxdate;
      enddate = enddate.replace(/-/g,"");
      //add #6829 ljg end
      if(findDate){
      //add #6829 ljg start
      //mod #9273 施設設定マスタのNo105の設定どおり動かない。張玲 start
      if(findDate <= enddate && date >= moment(this.indTreatStartDateParent).format('YYYYMMDD')) return '〇';
      //mod #9273 施設設定マスタのNo105の設定どおり動かない。張玲 end
      //add #6829 ljg end
      else null;
      }
    },
    //内部remine 5840  ljx add start
    //該当日付が変更後の日付であるかの判断
    isAfterScheduleDate(date) {
      if (!this.treatmentData) return false;
      let sameDateList = false;
      if (this.treatmentData[date]) {
        sameDateList = this.treatmentData[date];
      }
      if (sameDateList && sameDateList.rstDialysisState != '0') return true;
      if (!this.getAfterToChangeList) return false;
      const findDate = this.getAfterToChangeList.find(itemDate => itemDate == date);
      if (findDate) return true;
      else false;
    },
    //該当日付が変更前の日付であるかの判断
    isBeforeScheduleDate(date) {
      if (!this.treatmentData) return false;
      let sameDateList = null;
      if (this.treatmentData[date]) {
        sameDateList = this.treatmentData[date];
      }
      if (!sameDateList) return false;
      return true;
    },
    //内部remine 5840  ljx add end

    duringPeriodClass(date) {
      if (!this.getDateList) return [];
      let cssString = '';

      const findDate = this.getDateList.find(itemDate => {
        return itemDate == date;
      });

      if (findDate) cssString = 'background-color-DDF2FF';

      return cssString;
    },
    //内部remine 5840  ljx add start
    //該当日付の治療情報を表示
    showDetail(isScheduleFlag,flag,date){
      if(!isScheduleFlag){
        return;
      }
      if(flag == 'before'){
        EventBus.$emit("showBeforeTreatmentDetail", date);
      }else if(flag == 'after'){
        EventBus.$emit("showAfterTreatmentDetail", date);
      }

    },
    addClickClass(flag,indexArray){
      const addClass = "background-color-clicked";
      indexArray.forEach(index => {
        const tdDiv = document.getElementById(
          flag+index
        );
        tdDiv?.classList?.add(addClass);
      });
    },
    clearClickClass(){
      Array.from(document.getElementsByClassName("background-color-clicked")).forEach(element => {
        element.classList.remove("background-color-clicked");
      });
    },
    //内部remine 5840  ljx add start
    /**
     * 休日のスタイル取得
     */
    getStyle(date) {
      return getHolidayStyle(date);
    }
  },

  destroyed() {
    this.treatmentData = null;
  }
};
</script>

<style scoped>
.flex-overflow-auto {
  display: flex;
  overflow: auto;
}

.div-style {
  background-color: #333333;
  color: white;
  border-bottom: 0.5px solid #cccccc;
  border-right: 0.5px solid #cccccc;
  text-align: center;
}

.div-style-black {
  border-bottom: 0.5px solid #cccccc;
  border-right: 0.5px solid #cccccc;
  text-align: center;
}

.main {
  height: 6em;
  width: 100%;
}

.left-title {
  height: 6em;
  width: 4.5em;
  position: sticky;
  left: 0em;
  z-index: 999;
}

.left-title-td {
  height: 1.94em;
  width: 4.5em;
}

.height-1-94 {
  height: 1.94em;
}

.height-1-92 {
  height: 1.92em;
}

.list-header-saturday {
  color: #87ceeb;
}

.list-header-sunday {
  color: #ff6666;
}

.find-size {
  font-size: 30px !important;
}

/* mod #10281 曜日パターン変更画面のスタイル、レイアウト不正 宮崎 start */
.background-color-DDF2FF {
  background-color:#DDF2FF;
  color: black;
}
.background-color-clicked {
  background-color: yellow;
  color: black;
}
/* mod #10281 曜日パターン変更画面のスタイル、レイアウト不正 宮崎 end */
@media print {
  .flex-overflow-auto{
    overflow: hidden !important;
  }
  .main{
    width: 80vw !important;
  }
}
</style>
