/** * 治療情報系の表示項目の親コンポーネント */
<template>
  <div>
    <div
      v-for="(treatmentData, treatmentDataListIndex) in treatmentDataList"
      :key="treatmentDataListIndex"
      :class="setClassObject(treatmentDataListIndex)"
    >
      <!-- 治療条件や投与薬剤などの中項目でループ -->
      <div
        v-for="(subCategory, subCategoryIndex) in categoryItem"
        :key="subCategoryIndex"
      >
        <component
          :is="subCategory.component"
          :row-index="treatmentDataListIndex"
          :row-index-max="treatmentDataList.length"
          :selected-layout-cd="selectedLayoutCd"
          :sub-category="subCategory"
        />
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from "vuex";

/**
 * 治療情報関連
 */
// 治療予定作成
import TreatPlan from "@/components/pat-viewer/contents/treatment/TreatPlan";
// スケジュール
import Schedule from "@/components/pat-viewer/contents/treatment/Schedule";
// 治療方法
import TreatMethod from "@/components/pat-viewer/contents/treatment/TreatMethod";
// 治療条件
import TreatCond from "@/components/pat-viewer/contents/treatment/TreatCond";
// 投与薬剤
import Medicine from "@/components/pat-viewer/contents/treatment/Medicine";
// 医療材料
import Equipment from "@/components/pat-viewer/contents/treatment/Equipment";
// 指示コメント
import IndComment from "@/components/pat-viewer/contents/treatment/IndComment";
// 風袋
import TareInfo from "@/components/pat-viewer/contents/treatment/TareInfo";
// 除水補正
import OffWaterInfo from "@/components/pat-viewer/contents/treatment/OffWaterInfo";
// UFRプログラム
import UFRProgram from "@/components/pat-viewer/contents/treatment/UFRProgram";
// Naプログラム
import NaProgram from "@/components/pat-viewer/contents/treatment/NaProgram";
// Dialysateプログラム
import DialysateProgram from "@/components/pat-viewer/contents/treatment/DialysateProgram";
// 透析量プログラム
import DiaysisProgram from "@/components/pat-viewer/contents/treatment/DiaysisProgram";
// Qbqdプログラム
import QbqdProgram from "@/components/pat-viewer/contents/treatment/QbqdProgram";
// IHdfプログラム
import IHdfProgram from "@/components/pat-viewer/contents/treatment/IHdfProgram";
// BV-UFC
import BvUfc from "@/components/pat-viewer/contents/treatment/BvUfc";
// 実績情報
import RstInfo from "@/components/pat-viewer/contents/treatment/RstInfo";

// del FNSI-放射線検査の表示の修正 楊 start
//// 検査依頼・結果
//import ExamInfo from "@/components/pat-viewer/contents/treatment/ExamInfo";
//// 放射線検査依頼
//import RadInfo from "@/components/pat-viewer/contents/treatment/RadInfo";
// del FNSI-放射線検査の表示の修正 楊 end

// バイタル
import Vital from "@/components/pat-viewer/contents/treatment/Vital";

export default {
  components: {
    "treat-plan": TreatPlan,
    "treat-cond": TreatCond,
    equipment: Equipment,
    medicine: Medicine,
    schedule: Schedule,
    "ind-comment": IndComment,
    "treat-method": TreatMethod,
    "tare-info": TareInfo,
    "off-water-info": OffWaterInfo,
    "ufr-program": UFRProgram,
    "na-program": NaProgram,
    "dialysate-program": DialysateProgram,
    "diaysis-program": DiaysisProgram,
    "qbqd-program": QbqdProgram,
    "i-hdf": IHdfProgram,
    "bv-ufc": BvUfc,
    "rst-info": RstInfo,
    // del FNSI-放射線検査の表示の修正 楊 start
    //"exam-info": ExamInfo,
    //"rad-info": RadInfo,
    // del FNSI-放射線検査の表示の修正 楊 end
    vital: Vital
  },

  props: {
    /**
     * 患者経過総合ビューアレイアウトマスタの選択レイアウトコード
     */
    selectedLayoutCd: {
      type: Number,
      default: -1,
      required: true
    },

    /**
     *患者経過総合ビューアレイアウトマスタの表示中項目リスト
     */
    categoryItem: {
      type: Array,
      default: () => [],
      required: true
    }
  },

  data() {
    return {};
  },

  computed: {
    ...mapGetters("pat-viewer", ["getTreatmentData"]),

    treatmentDataList() {
      return this.getTreatmentData;
    },

    /**
     * 治療方法の数だけクラスを定義
     * @description 1番目、2番目、3番目で背景色を変更
     */
    classObject() {
      const arr = [];
      for (const index in this.getTreatmentData) {
        let i = Number(index);
        let obj = {};
        // 要素番号が2より大きい場合
        if (2 < Number(index)) {
          while (2 < i) {
            i -= 3;
          }
          obj = this.setClassStyle(i, obj);
        } else {
          obj = this.setClassStyle(i, obj);
        }
        arr.push(obj);
      }
      return arr;
    }
  },

  created() {},

  methods: {
    /**
     * 指定された要素番号の治療予定に対しクラスのスタイル適用
     * @param num index番号
     */
    setClassObject(num) {
      const obj = this.classObject[num];
      obj[`status${num}`] = true;
      return obj;
    },

    /**
     * 要素番号に応じてクラスのフラグを変更する
     */
    setClassStyle(index, obj) {
      switch (index) {
        case 0:
          obj["list-content-2rd"] = false;
          obj["list-content-3rd"] = false;
          break;

        case 1:
          obj["list-content-2rd"] = true;
          obj["list-content-3rd"] = false;
          break;

        case 2:
          obj["list-content-2rd"] = false;
          obj["list-content-3rd"] = true;
          break;

        default:
          break;
      }
      return obj;
    }
  }
};
</script>

<style scoped lang="scss">
/* 患者経過総合ビューア共通スタイル定義 */
@import "../css/style.scss";
</style>
