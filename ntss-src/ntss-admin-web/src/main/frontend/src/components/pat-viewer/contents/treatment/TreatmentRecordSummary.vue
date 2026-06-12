/** * 患者経過総合ビュア治療記録集計 */
<template>
    <base-content
    :func-name="funcName"
    :disp-data-list="itemDataList"/>
</template>

<script>
import { mapState, mapGetters, mapActions } from "@/compat/vue/vuex";
// このコンポーネントへ表示する情報を渡す
import baseContent from "@/components/pat-viewer/contents/base/BaseContent";

export default {
  components: {
    "base-content": baseContent
  },

  props: {
    // 患者経過総合ビューアレイアウトマスタ選択情報
    layout: {
      type: Object,
      default: () => {}
    }
  },

  data() {
    return {
      //表示するデータのリスト,親コンポーネントに渡す情報
      itemDataList: []
    };
  },

  computed: {
    // mod #12462 患者情報共有->患者経過総合ビューア fang start
    ...mapGetters("pat-info", {
      patId: "selectedPatId",
      // facilityCd: "selectedPatFacilityCd"
    }),
    ...mapGetters("user", {facilityCd: "getFacilityCd"}),
    // mod #12462 患者情報共有->患者経過総合ビューア fang end
    ...mapGetters("pat-viewer",
    ["getDateList",
    "getSelectedPeriod",
    "getMstTreatmentData"]),
    ...mapState("pat-viewer", ["treatDateList"]),

    //一覧に表示するデータのリスト
    dateList() {
      return this.getDateList;
    },

    // 一覧上の期間切替
    selectedPeriod() {
      return this.getSelectedPeriod;
    },

    // 治疗方法マスタデータ
    mstTreatmentData() {
      return this.getMstTreatmentData;
    },

    funcName() {
      let name = "";
      switch (this.layout.component) {
        case "treatment":
          name = "治療記録集計"
          break;
      }
      return name;
    }
  },
  async created() {
    this.startLoadingScreen();
    this.convertDrugInfo().then(itemDataList => {
      this.itemDataList = itemDataList;
    }).finally(() => {
      this.finishLoadingScreen();
    });
  },
  beforeUnmount() {
    Object.assign(this.$data, this.$options.data());
  },
  methods: {
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
    ]),
    async convertDrugInfo() {
      const treatDateList = this.treatDateList;
      let treatDateListData = [];
      if (treatDateList) {
        treatDateListData = treatDateList.data;
      }
      // 加工した表示用データ格納用
      const convertData = [];
      //レイアウトのサブアイテム取得（横方向のタイトル）
      // mod #12462 患者情報共有->患者経過総合ビューア fang start
      let tempTreatmentData = this.mstTreatmentData;
      if(tempTreatmentData) {
        tempTreatmentData = tempTreatmentData.filter(el => el.facilityCd === this.facilityCd)
      }
      const subItem = tempTreatmentData;
      // mod #12462 患者情報共有->患者経過総合ビューア fang end
      var tempDrug;
      subItem.forEach(item =>{
          tempDrug = {
          data: [],
          itemName: item.treatmentName ,
          itemNo: item.treatmentCd
          };
        for (let i=0; i<this.dateList.length; i++){
          let startDt =  this.dateList[i];
          let endDt = (i<(this.dateList.length -1)) ? this.dateList[i+1]:"99999999";
          const itemData = treatDateListData.filter(data =>
            "0" != data.rstDialysisState &&
             endDt > data.treatDate &&
             startDt<= data.treatDate && data.indTreatmentCd === item.treatmentCd
           );
          let sumValue = 0;
          itemData.forEach(subiItemData =>{
              sumValue += 1;
          });
          sumValue = sumValue.toFixed().replace(/\d{1,3}(?=(\d{3})+(\.\d*)?$)/g, '$&,');
          tempDrug.data.push({
            treatDate: null,
            ordNo: null,
            value1: (Number(sumValue) === 0) ? 0+ " 件" : sumValue+ " 件" ,
            value2: null,
            isNotClickable: true,
            colorFlg: 0,
            deviceMode: -1,
            treatMethodCd: 0,
            isRstRoundsFlg: false,
            type :"cf"
          });
        }
        convertData.push(tempDrug);
      });
      return convertData;
    }
  }
};
</script>

<style scoped lang="scss">
@use "../../css/style.scss" as *;

/* 患者経過総合ビューア共通スタイル定義 */
div :deep(.list-content-col) {
  width: 0px;
}
</style>
