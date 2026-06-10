/** * 治療条件ー治療時間 */

<template>
  <v-ons-row>
    <v-ons-col class="action-condition-column">治療時間</v-ons-col>
<!-- mod FNSI-【1006】最新の改修対象一覧の667対応 韓 start -->
 <!--
    <v-ons-col class="action-condition-data-column">
      <custom-input-time-special
        :value="displayInputValue"
        class="action-condition-input"
      />
    </v-ons-col>
   -->
    <!--//FNSI-修正 #5658 横展開対応、xugj del start-->
      <!--
      <div v-show="mstTreatmentSetDayDisplay" >
        <v-ons-select
          v-model="mstTreatmentSetDay"
          class="input-select d-inline-flex"
          @change="setMstTreatmentSet($event.target.value)"
        >
          <option
            v-for="(mst, index) in [0,1,2]"
            :key="index"
            :value="mst"
          >{{ mst }}</option>
        </v-ons-select>
        <span> 天</span>
      </div>
      -->
    <!--//FNSI-修正 #5658 横展開対応、xugj del end-->
    <v-ons-col class="action-condition-data-column treat-time">
      <!--//FNSI-修正 #5658 横展開対応、xugj del start-->
        <!-- mod FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.59(外結)対応 韓 start -->
        <!--
        <v-ons-input
          style="width: auto;"
          type="time"
          v-model="conTreatTime"
          @change="onChangeInputData"
          />
          -->
        <!--
        <v-ons-input
          style="width: auto;white-space: initial"
          type="time"
          v-model="conTreatTime"
          @change="onChangeInputData"
          @focus="addFocusCss($event)"
          @blur="formatValue($event)"
          />
          -->
        <!-- mod FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.59(外結)対応 韓 end -->
      <!--//FNSI-修正 #5658 横展開対応、xugj del end-->
      <!--//FNSI-修正 #5658 横展開対応、xugj add start-->
      <custom-input-time-special
        :value="displayInputValue"
        @change="onChangeInputData"
        class="action-condition-input ntss-custom-input-cond"
      />
      <!--//FNSI-修正 #5658 横展開対応、xugj add end-->
    </v-ons-col>
<!-- mod FNSI-【1006】最新の改修対象一覧の667対応 韓 end -->
  </v-ons-row>
</template>

<script>
import { mapMutations } from "vuex";
import IndTreatCondBase from "@/components/indication/IndTreatCondBase";
// add FNSI-【1006】最新の改修対象一覧の667対応 韓 start
import { dateFormat } from "@/functions/common/DateTimeUtils";
// add FNSI-【1006】最新の改修対象一覧の667対応 韓 end

export default {
  mixins: [IndTreatCondBase],
  props: ['mstTreatmentSetDay','mstTreatmentSetDayDisplay'],

  watch: {
    displayInputValue: {
      handler(data) {
        this.setTreatTime(data.editValue);
      },
      deep: true
    },
    mstTreatmentSetDay: {
      // eslint-disable-next-line no-unused-vars
      handler: newVal => {},
      deep: true
    },
    mstTreatmentSetDayDisplay: {
      // eslint-disable-next-line no-unused-vars
      handler: newVal => {},
      deep: true
    }
  },

  mounted() {
    this.treatItemCd = "1";
  },

// add FNSI-【1006】最新の改修対象一覧の667対応 韓 start
  created() {
    if(this.displayInputValue.editValue > 1440){
      this.conTreatTime  = dateFormat.mChar2time(Number(this.displayInputValue.editValue%1440));
      this.setMstTreatmentSet(parseInt(this.displayInputValue.editValue/1440))
    }else{
    this.conTreatTime = dateFormat.mChar2time(this.displayInputValue.editValue);
      this.setMstTreatmentSet(0)
    }
  },
// add FNSI-【1006】最新の改修対象一覧の667対応 韓 end

  methods: {
    ...mapMutations("pat-viewer-treat-cond", ["setTreatTime"]),
    setMstTreatmentSet(day){
      this.$emit('mstTreatmentSetDay',{
        mstTreatmentSetDay:day,
        conTreatTime:dateFormat.time2MChar(this.conTreatTime)
      });
    },
// add FNSI-【1006】最新の改修対象一覧の667対応 韓 start
    onChangeInputData() {
      this.displayInputValue.editValue=dateFormat.time2MChar(this.conTreatTime);
// add FNSI-【1006】最新の改修対象一覧の667対応 韓 end
    },

    // add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.59(外結)対応 韓 start
    addFocusCss(event){
      let element = event.target;
      element?.classList?.add("custom-input-time-edited");
    },

    formatValue(event) {
      if (this.displayInputValue.initValue === dateFormat.time2MChar(this.conTreatTime)) {
        let element = event.target;
        element.classList.remove("custom-input-time-edited");
      }
    }
    // add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.59(外結)対応 韓 end
  }
};
</script>

<style>
  /*FNSI-修正 #5658 横展開対応、xugj add start*/
  /*!* add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.59(外結)対応 韓 start *!*/
  /*.custom-input-time-edited > input[type="time"] {*/
  /*  border: 2px green solid !important;*/
  /*}*/
  /*!* add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.59(外結)対応 韓 end *!*/
.action-condition-input {
  width: 138px;
  margin: 0px 5px 0px 0px;
}
.action-condition-column {
  flex: 0 0 9%;
  max-width: 30%;
  white-space: normal;
  margin: auto;
}
.action-condition-data-column {
  margin: auto;
  padding-left: 10px;
  margin-right: 5px;
}
.treat-time > .ntss-custom-input-cond {
  margin: 0;
}
.treat-time > .ntss-custom-input-cond > input[type="number"] {
  width: 40px;
  border: none !important;
}
.treat-time > .ntss-custom-input-cond > .time-span {
  width: 50px;
  padding: 2px;
}
  /*FNSI-修正 #5658 横展開対応、xugj add end*/
</style>
