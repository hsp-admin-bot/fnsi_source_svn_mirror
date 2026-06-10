<template>
  <div class="vertical-div">
    <!--mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start-->
    <!--<div class="disp-item-area">
      <div class="label-area">
        <label class="ntss-pat-event-label">{{ getTemplateFieldName }}&emsp;</label>
      </div>
    </div>
    <div class="btn-area">
      &lt;!&ndash; mod FNSI-共有を追加 王 20200921 start &ndash;&gt;
      <button class="button registration-btn" :disabled="getViewMode || !isShared" @click="onCalc">再計算</button>
      &lt;!&ndash; mod FNSI-共有を追加 王 20200921 end &ndash;&gt;
      <label class="title ntss-pat-event-label">{{ calcResult }}&emsp;</label>
      <label class="title ntss-pat-event-label">{{ unit }}&emsp;</label>-->
    <div class="borderRight " style="width: calc(100% / 4)">
      <div class="disp-item-area topTitle" style="float: left;">
          <label class="ntss-pat-event-label changeRow">{{ getTemplateFieldName }}&emsp;</label>
      </div>
    </div>
    <div class="titleRight">
      <!-- <div class="btn-area"> -->
        <label class="ntss-pat-event-label">{{ calcResult }}&emsp;</label>
        <label class="ntss-pat-event-label">{{ unit }}&emsp;</label>
      <!-- mod #10359 編集権限の動作不正 start -->
      <!-- <button class="button btn3-normal" :disabled="getViewMode || !isShared" @click="onCalc" v-show="!getViewMode">計算</button> -->
      <button
        class="button btn3-normal"
        :disabled="
          getViewMode ||
          !isShared ||
          !getItemAuthorized('PatEvent', 'default_authority')
        "
        @click="onCalc"
        v-show="!getViewMode && !getIsOtherFacilitys"
      >
        計算
      </button>
      <!-- mod #10359 編集権限の動作不正 end -->
      <!-- </div> -->
      <!--mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end-->
    </div>
    <br />
  </div>
</template>

<script>
  import {mapActions, mapGetters} from "vuex";
  import BigEval from "@/functions/BigEvalEx";
// add #10359 編集権限の動作不正 start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 end

  export default {
  props: ["propsIndex"],
  components: {},
  data() {
    return {
      inputModel: {
        date: null
      },
      unit: null,
      calc: null,
      calcResult: null
    };
  },

  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("pat-event/detail", [
      "getPatEventInputParams",
      "getPatEventResultParams",
      "getPatEventRecord",
      "getPatEventRegStaffInfo",
      "getPatEventUpStaffInfo",
      "getViewMode"
    ]),
    // add FNSI-共有を追加 王 20200921 start
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("treatment-record/common", ["getSharedFacilityCd"]),
    // add #12462 患者情報共有 wangchao 20260323 start
    ...mapGetters("pat-event/list", ["getIsOtherFacility"]),
    ...mapGetters("observe-record/list", ["getIsOtherFacilitys"]),
    // add #12462 患者情報共有 wangchao 20260323 end
    isShared() {
      if(this.getPatEventRecord.isComRec){
        return this.getFacilityCd === this.getSharedFacilityCd;
      }
      return true;
    },
    // add FNSI-共有を追加 王 20200921 end
    getMstTemplateJson() {
      return this.getPatEventInputParams[this.propsIndex].item_json;
    },
    getTemplateFieldName() {
      const flag = this.getPatEventInputParams[this.propsIndex]
        .is_field_display;
      if (flag === "1") {
        return this.getPatEventInputParams[this.propsIndex].field_name;
      } else {
        return "";
      }
    }
  },
  watch: {},
  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  destroyed() { },
  created() {},
  mounted() {
    const result = this.getPatEventResultParams[this.propsIndex];
    const templateJson = this.getMstTemplateJson;
    this.calc = templateJson.calc;
    this.unit =
      result && result.result_value && result.result_value.unit
        ? result.result_value.unit
        : templateJson.unit;
    this.calcResult =
      result && result.result_value && result.result_value.score
        ? result.result_value.score
        : null;
  },
  methods: {
    ...mapActions("pat-event/detail", [
      "setPatEventRecord",
      "setPatEventResultParamsUpdate"
    ]),
    // add #10359 編集権限の動作不正 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 end
    async onCalc() {
      if (this.calc === undefined) {
        return;
      }
      this.validateOnRegistration();
    },

    /**
     * 入力データの検証チェック
     */
    async validateData() {
      let idx = 0;
      let arScore = [];
      const resultParams = this.getPatEventResultParams;
      const inputParams = this.getPatEventInputParams;
      this.calcResult = 0;
      for (const item of resultParams) {
        let fldName = null;
        let value = 0;
        switch (item.format_class) {
          case 3: //リスト
          case 4: //ラジオ
            if (item.result_value.length !== 0) {
              fldName = inputParams[idx].field_name;
              value = item.result_value.score;
              arScore.push({ fldName: fldName, value: value });
            }
            break;
          case 6: //チェック
            if (item.result_value.length !== 0) {
              fldName = inputParams[idx].field_name;
              for (const itm of item.result_value) {
                // 患者イベントテンプレートマスタメンテの不具合により
                // マスタから取得したスコア値が文字列になっている場合があるため、
                // スコア値を数値化した値を合計して数式の計算に使用されるようにする
                value = value + Number(itm.score);
              }
              arScore.push({ fldName: fldName, value: value });
            }
            break;
          default:
            break;
        }
        idx++;
      }
      let calculation = this.calc;
      for (const score of arScore) {
        calculation = calculation.replace(
          "[" + score.fldName + "]",
          score.value
        );
      }
      calculation = calculation.replace(/\[.*?\]/g, 0);
      if (calculation !== this.calc) {
        const bigEval = new BigEval();
        const calcAnswer = bigEval.exec(calculation);
        if (typeof calcAnswer === "object") {
          const ans = calcAnswer.toNumber();
          this.calcResult = ans.toFixed(0);
        }
        if (!Number.isFinite(Number(this.calcResult))) {
          this.calcResult = 0;
        }

        const result = resultParams[this.propsIndex];
        const value = {
          format_class: result.format_class,
          result_value: {
            //upd #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
            // score: this.calcResult,
            unit: this.unit,
            score: this.calcResult
            //upd #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc end
          }
        };
        await this.setPatEventResultParamsUpdate({
          item: value,
          index: this.propsIndex
        });
      }
    },
    /**
     * 入力データの検証チェック
     */
    async validateOnRegistration() {
      this.validateData();
      return true;
    }
  }
};
</script>

<style scoped>
  /*mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start*/
  /*.vertical-div {*/
  /*  display: flex;*/
  /*  flex-direction: column;*/
  /*  align-content: flex-start;*/
  /*  font-size: 1em;*/
  /*}*/
  /*.disp-item-area {*/
  /*  width: 100%;*/
  /*  border-collapse: collapse;*/
  /*}  */
.vertical-div {
  display: flex;
  /* align-content: flex-start; */
  align-items: center;
  padding-bottom: 10px;
  font-size: 1em;
  border-bottom: #595959 solid 1.5px;
}
.disp-item-area {
  width: 100%;
  border-collapse: collapse;
  display: flex;
  align-items: center;
}
  /*mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end*/
.disp-item-area tr {
  height: 50px;
}
.disp-item-area tr th {
  text-align: left;
}
.disp-item-area tr th:first-child,
.disp-item-area tr th:nth-child(2) {
  width: 30%;
}
.disp-item-area tr td:first-child,
.disp-item-area tr td:nth-child(2),
.disp-item-area tr td:nth-child(3) {
  text-align: left;
}
.title {
  margin-left: 10px;
  margin-top: 10px;
}
  /*mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start*/
  /*.label-area{
    margin-left: 10px;
  }
  .btn-area{
    margin-left: 10px;
    margin-top: 10px;
  }*/
.btn-area{
  margin-left: 10px;
  margin-top: 10px;
}
.topTitle {
  height: 100%;
  margin-right: 10px;
  display: flex;
  align-items: center;
  flex-wrap: wrap;
}
.titleRight {
  width: 75%;
}
.borderRight {
  margin-left: 10px;
  /*border-right: #595959 solid 1px;*/
  /*padding-left: 10px;*/
}
.changeRow {
  overflow: hidden;
  word-spacing: normal;
  word-break: break-all;
}
  /*mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end*/
</style>
