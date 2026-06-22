<template>
  <div class="table-style">
    <div class="item-table-style">
      <div class="item-style">
        <v-ons-row class="hader-item-stlye">
          <v-ons-col />
        </v-ons-row>

        <v-ons-row>
          <v-ons-col
            :class="`category-cell-style ${addClass}treatment-category`"
            style="white-space: nowrap"
          >
            治療方法
          </v-ons-col>
        </v-ons-row>

        <!-- スケジュール -->
        <v-ons-row>
          <v-ons-col :class="`vertical-header-style ${addClass}sch-category`">
            スケジュール
          </v-ons-col>
          <v-ons-col class="item-coloumn-style">
            <v-ons-row
              v-for="(schItem, index) in schInfoItem"
              :key="index"
              class="item-table-row-style"
              :class="`${addClass}schItem_${index}`"
            >
              <v-ons-col class="item-col-cell">
                {{ schItem.label }}
              </v-ons-col>
            </v-ons-row>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row>
          <v-ons-col :class="`vertical-header-style ${addClass}cond-category`">
            治療条件
          </v-ons-col>
          <v-ons-col class="item-coloumn-style">
            <v-ons-row
              v-for="(condItem, index) in condInfoItem"
              :key="index"
              class="item-table-row-style"
              :class="`${addClass}condItem_${index}`"
            >
              <v-ons-col class="item-col-cell">
                {{condItem.label}}
              </v-ons-col>
            </v-ons-row>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row>
          <v-ons-col
            :class="`vertical-header-style ${addClass}medi-category`"
            :style="categoryStyle(mediInfoItem, 'no')"
          >
            投与薬剤
          </v-ons-col>
          <v-ons-col class="item-coloumn-style">
            <v-ons-row
              v-for="(mediInfo, index) in mediInfoItem"
              :key="index"
              class="item-table-row-style"
              :class="`${addClass}mediItem_${index}`"
            >
              <v-ons-col>
                <v-ons-row
                  v-for="(itemLabel, eleIndex) in mediInfo.label"
                  :key="eleIndex"
                  class="ele-item-table-row-style"
                  :class="`${addClass}ele_mediInfo_${index}_${eleIndex}`"
                >
                  <v-ons-col class="item-col-cell">
                    {{ itemLabel }}
                  </v-ons-col>
                </v-ons-row>
              </v-ons-col>
            </v-ons-row>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row>
          <v-ons-col
            :class="`vertical-header-style ${addClass}equip-category`"
            :style="categoryStyle(equipInfoItem, 'cd')"
          >
            医療材料
          </v-ons-col>
          <v-ons-col class="item-coloumn-style">
            <v-ons-row
              v-for="(equipInfo, index) in equipInfoItem"
              :key="index"
              class="item-table-row-style"
              :class="`${addClass}equipItem_${index}`"
            >
              <v-ons-col>
                <v-ons-row
                  v-for="(itemLabel, eleIndex) in equipInfo.label"
                  :key="eleIndex"
                  class="ele-item-table-row-style"
                  :class="`${addClass}ele_equipInfo_${index}_${eleIndex}`"
                >
                  <v-ons-col class="item-col-cell">
                    {{ itemLabel }}
                  </v-ons-col>
                </v-ons-row>
              </v-ons-col>
            </v-ons-row>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row>
          <v-ons-col
            :class="`vertical-header-style ${addClass}ind-comment-category`"
            :style="categoryStyle(indCommentInfoItem, 'no')"
          >
            指示コメント
          </v-ons-col>
          <v-ons-col class="item-coloumn-style">
            <v-ons-row
              v-for="(commentInfo, index) in indCommentInfoItem"
              :key="index"
              class="item-table-row-style"
              :class="`${addClass}indCommentItem_${index}`"
            >
              <v-ons-col class="item-col-cell">
                {{ commentInfo.label }}
              </v-ons-col>
            </v-ons-row>
          </v-ons-col>
        </v-ons-row>
      </div>

      <div class="data-style">
        <v-ons-row class="hader-item-stlye">
            <v-ons-col>
            <v-ons-row>
              <v-ons-col>
                <span :class="getStyle(beforeDate)">{{ beforeDate }}</span>
                <span v-if="afterDates.length > 0"> → </span>
                <template v-for="(date, index) in afterDates">
                  <span :class="getStyle(date)">{{ date }}</span>
                  <span v-if="index < afterDates.length - 1">、</span>
                </template>
              </v-ons-col>
            </v-ons-row>
          </v-ons-col>
        </v-ons-row>

        <!-- 治療方法表示データ -->
        <v-ons-row>
          <v-ons-col class="item-table-col-style"
            v-for="(treatMethod, index) in dispTreatmentMethod"
            :key="index"
          >
            <v-ons-row
              class="item-table-row-style data-cell-style"
              :class="`${addClass}treatment_${index}`"
            >
              <v-ons-col class="data-col-cell">
                {{ treatMethod }}
              </v-ons-col>
            </v-ons-row>
          </v-ons-col>
        </v-ons-row>

        <!-- スケジュール表示データ -->
        <v-ons-row>
          <v-ons-col class="item-table-col-style"
          v-for="(schInfo, index) in dispSchInfo" :key="index">
            <v-ons-row
              v-for="(eleSchInfo, eleIndex) in schInfo"
              :key="eleIndex"
              class="item-table-row-style data-cell-style"
              :class="`${addClass}sch_${index}_${eleIndex}`"
            >
              <v-ons-col class="data-col-cell">
                {{ eleSchInfo.value }}
              </v-ons-col>
            </v-ons-row>
          </v-ons-col>
        </v-ons-row>

        <!-- 治療条件表示データ -->
        <v-ons-row>
          <v-ons-col class="item-table-col-style"
          v-for="(condInfo, index) in dispCondInfo" :key="index">
            <v-ons-row
              v-for="(eleCondInfo, eleIndex) in condInfo"
              :key="eleIndex"
              class="item-table-row-style data-cell-style"
              :class="[
                { 'cell-disabled': eleCondInfo.isDisabled },
                { 'taboo-allergy': eleCondInfo.isTabooAllergy },
                `${addClass}cond_${index}_${eleIndex}`
              ]"
            >
              <v-ons-col class="data-col-cell">
                {{ eleCondInfo.value }}
              </v-ons-col>
            </v-ons-row>
          </v-ons-col>
        </v-ons-row>

        <!-- 投与薬剤表示データ -->
        <v-ons-row>
          <v-ons-col class="item-table-col-style"
          v-for="(mediInfo, index) in dispMediInfo" :key="index">
            <v-ons-row
              v-for="(eleMediInfo, eleIndex) in mediInfo"
              :key="eleIndex"
              class="item-table-row-style data-cell-style"
              :class="`${addClass}medi_${index}_${eleIndex}`"
            >
              <v-ons-col>
                <v-ons-row
                  v-for="(eleValue, valueIndex) in eleMediInfo.value"
                  :key="valueIndex"
                  class="ele-item-table-row-style data-cell-style"
                  :class="[
                    { 'taboo-allergy': eleMediInfo.isTabooAllergy },
                    `${addClass}medi_value_${index}_${eleIndex}_${valueIndex}`
                  ]"
                >
                  <v-ons-col class="data-col-cell">
                    {{ eleValue }}
                  </v-ons-col>
                </v-ons-row>
              </v-ons-col>
            </v-ons-row>
          </v-ons-col>
        </v-ons-row>

        <!-- 医療材料表示データ -->
        <v-ons-row>
          <v-ons-col class="item-table-col-style"
          v-for="(equipInfo, index) in dispEquipInfo" :key="index">
            <v-ons-row
              v-for="(eleEquipInfo, eleIndex) in equipInfo"
              :key="eleIndex"
              class="item-table-row-style data-cell-style"
              :class="`${addClass}equip_${index}_${eleIndex}`"
            >
              <v-ons-col>
                <v-ons-row
                  v-for="(eleValue, valueIndex) in eleEquipInfo.value"
                  :key="valueIndex"
                  class="ele-item-table-row-style data-cell-style"
                  :class="[
                    { 'taboo-allergy': eleEquipInfo.isTabooAllergy },
                    `${addClass}equip_value_${index}_${eleIndex}_${valueIndex}`
                  ]"
                >
                  <v-ons-col class="data-col-cell">
                    {{ eleValue }}
                  </v-ons-col>
                </v-ons-row>
              </v-ons-col>
            </v-ons-row>
          </v-ons-col>
        </v-ons-row>

        <!-- 指示コメント表示データ -->
        <v-ons-row>
          <v-ons-col class="item-table-col-style"
            v-for="(commentInfo, index) in dispIndCommentInfo"
            :key="index"
          >
            <v-ons-row
              v-for="(eleCommentInfo, eleIndex) in commentInfo"
              :key="eleIndex"
              class="item-table-row-style data-cell-style"
              :class="`${addClass}indComment_${index}_${eleIndex}`"
            >
              <v-ons-col class="data-col-cell">
                {{ eleCommentInfo.value }}
              </v-ons-col>
            </v-ons-row>
          </v-ons-col>
        </v-ons-row>
      </div>
    </div>
  </div>
</template>

<script>
// import { ApiHelper } from "@/apis/AxiosHelper";
import { mapGetters } from "@/compat/vue/vuex";
import { deepCopy, getHolidayStyle } from "@/functions/common/CommonFunctions";
import BigNumber from "@/compat/number/bignumber";
import $ from "@/compat/jquery";
import { getScopedJQuery } from "@/functions/common/LayoutMeasureHelper";
/**
 * オブジェクト、配列操作
 */
/**
 * jQuery
 */

/**
 * 日付操作
 */
import dayjs from "@/compat/date/dayjs";
import IndicationOwnerMixin from '@/components/indication/IndicationOwnerMixin';
export default {
  mixins: [IndicationOwnerMixin],
  props: {
    /**
     * 表示する情報
     */
    dispInfo: {
      type: Array,
      required: true
    },
    /**
     * 曜日情報の横幅
     */
    weekWidth: {
      type: Number,
      default: 34
    },
    /**
     * 治療方法表示テキスト
     */
    dispTreatment: {
      type: String,
      required: true
    },
    /**
     * マスタ情報
     */
    mstInfo: {
      type: Object,
      required: true
    },
    /**
     * 現在・新規フラグ
     * 0->現在・1->新規
     */
    dispType: {
      type: Number,
      required: true
    }
  },

  data() {
    return {
      /**
       * 詳細情報
       */
      dispDetailInfo: this.dispInfo,
      /**
       * 治療方法表示情報
       */
      dispTreatmentMethod: [],
      //内部remine 5840  mod ljx start
      dispMoveDateInfo:"",
      //内部remine 5840  mod ljx end
      /**
       * スケジュール項目
       */
      schInfoItem: [
        { no: 1, label: "クール", value: null },
        { no: 2, label: "治療開始時刻", value: null },
        { no: 3, label: "ベッド", value: null }
      ],
      /**
       * スケジュール表示情報
       */
      dispSchInfo: [],
      /**
       * 治療条件表示情報
       */
      dispCondInfo: [],
      /**
       * 治療条件項目
       */
      condInfoItem: [
        { condId: "1", label: "治療時間", value: null },
        { condId: "2", label: "VA", value: null },
        // add 10443 身体情報・DW・目標体重バグ 関  start
        { condId: "39", label: "DW", value: null },
        // add 10443 身体情報・DW・目標体重バグ 関  end
        { condId: "3", label: "目標体重", value: null },
        { condId: "4", label: "除水量制限", value: null },
        { condId: "5", label: "ダイアライザ", value: null },
        { condId: "6", label: "吸着カラム", value: null },
        { condId: "7", label: "1次膜", value: null },
        { condId: "8", label: "2次膜", value: null },
        { condId: "9", label: "穿刺針(A針)", value: null },
        { condId: "10", label: "穿刺針(V針)", value: null },
        { condId: "11", label: "穿刺針(SN)", value: null },
        { condId: "12", label: "シングルニードル使用", value: null },
        { condId: "13", label: "血液回路", value: null },
        { condId: "14", label: "血液量", value: null },
        { condId: "15", label: "透析液", value: null },
        { condId: "16", label: "透析液流量", value: null },
        { condId: "17", label: "透析液使用数", value: null },
        { condId: "18", label: "透析液温度", value: null },
        { condId: "19", label: "補液", value: null },
        { condId: "20", label: "補液量", value: null },
        { condId: "21", label: "補液選択", value: null },
        { condId: "22", label: "補液使用数", value: null },
        { condId: "23", label: "補液温度", value: null },
        { condId: "24", label: "補液速度", value: null },
        { condId: "25", label: "抗凝固剤", value: null },
        { condId: "26", label: "抗凝固剤ワンショット量", value: null },
        { condId: "27", label: "抗凝固剤持続速度", value: null },
        { condId: "28", label: "抗凝固剤持続総量", value: null },
        { condId: "29", label: "IP使用選択", value: null },
        { condId: "30", label: "IPスタート", value: null },
        { condId: "32", label: "IP速度", value: null },
        { condId: "33", label: "IP速度最大値", value: null },
        { condId: "34", label: "IPワンショットスタート", value: null },
        { condId: "31", label: "IPワンショット量", value: null },
        { condId: "35", label: "IP電源自動切り", value: null },
        { condId: "36", label: "IP電源自動切り時間", value: null },
        { condId: "37", label: "IP電源OKモニタ切り", value: null },
        { condId: "38", label: "IP電源OKモニタ切り時間", value: null }
      ],
      /**
       * 投与薬剤表示情報
       */
      dispMediInfo: [],
      /**
       * 投与薬剤項目
       */
      mediInfoItem: [],
      /**
       * 医療材料表示情報
       */
      dispEquipInfo: [],
      /**
       * 医療材料項目
       */
      equipInfoItem: [],
      /**
       * 指示コメント表示情報
       */
      dispIndCommentInfo: [],
      /**
       * 指示コメント項目
       */
      indCommentInfoItem: [],
      /**
       * 曜日情報リスト
       */
      weekInfoList: [],
      // add 10443 身体情報・DW・目標体重バグ 関  start
      selectDate: null,
      // add 10443 身体情報・DW・目標体重バグ 関  end
    };
  },

  computed: {
    ...mapGetters("pat-info", ["selectedPat"]),
    // add 10443 身体情報・DW・目標体重バグ 関  start
    ...mapGetters("pat-viewer", ["getPhysicalInfo"]),
    // add 10443 身体情報・DW・目標体重バグ 関  end

    /**
     * 表示曜日
     */
    dispWeek() {
      const arr = new Array();
      if (0 !== this.weekInfoList.length) {
        this.weekInfoList.forEach(weekNum => {
          arr.push(this.convertWeekName(weekNum));
        });
      }
      return arr;
    },

    /**
     * 表示データの横幅設定
     */
    dispDataWidth() {
      // 現在治療パターンの曜日数
      const weekLen = this.weekInfoList.length;
      // 一つの曜日列幅
      let w = this.weekWidth;
      if (weekLen > 0) {
        if (weekLen >= 3) {
          w = (w * 7) / 3 + 4;
        } else {
          w = (w * 7) / weekLen + (7 - weekLen);
        }
      }
      return { width: `${w * weekLen + weekLen + 1}px` };
    },

    /**
     * スクロールの設定
     */
    isScroll() {
      let scrollStr = "scroll";
      // 表示する曜日数が3つ以下の場合、横スクロールを非活性
      if (3 >= this.weekInfoList.length) {
        scrollStr = "hidden";
      }
      return { "overflow-x": scrollStr };
    },

    /**
     * クラス名の追加
     * @description 現在の指示展開情報か、新規の指示展開情報かを区別
     */
    addClass() {
      return 0 === this.dispType ? "current_" : "new_";
    },
    /**
     * 変更前 日付(曜日)
     */
    beforeDate() {
      if (this.dispMoveDateInfo) {
        const match = this.dispMoveDateInfo.match(/^(\d{4}\/\d{2}\/\d{2} \(.+?\))/);
        return match ? match[1] : "";
      }
      return "";
    },
    /**
     * 変更後 日付(曜日)の配列
     */
    afterDates() {
      if (this.dispMoveDateInfo) {
        // "→" の後の部分を取得
        const rightSide = this.dispMoveDateInfo.split("→")[1];
        if (rightSide) {
          const matches = rightSide.match(/\d{4}\/\d{2}\/\d{2} \(.+?\)|削除/g) || [];    
          // 日付順にソート
        return matches
          .sort((a, b) => {
            const dateA = a.match(/\d{4}\/\d{2}\/\d{2}/)[0];
            const dateB = b.match(/\d{4}\/\d{2}\/\d{2}/)[0];
            return dateA.localeCompare(dateB); // 文字列として比較（昇順）
          });
        }
      }
      return [];
    },
  },

  async created() {
    // 詳細情報作成操作
    await this.createInfoDetailProc();
  },

  methods: {
    scopedJQuery(selector, context) {
      const jq = getScopedJQuery(this.$el || this, $);
      return (jq || $)(selector, context);
    },
    /**
     * 詳細情報作成操作
     * @description 親から変数を呼ばれて、引数が渡されてきた場合は作り直す
     */
    // mod 10443 身体情報・DW・目標体重バグ 関  start
    // async createInfoDetailProc(detailInfo) {
    async createInfoDetailProc(detailInfo, date) {
      this.selectDate = date;
      // mod 10443 身体情報・DW・目標体重バグ 関  end
      // 引数があればそれを格納する
      if (detailInfo) {
        this.dispDetailInfo = detailInfo;
      }
      // 「目標体重」
      this.createTargetWeightDWInfo();
      // 曜日情報リストの作成
      await this.createWeekInfoList();
      // 表示情報の作成
      await this.createDetailInfo();
      // 項目高さ設定
      this.setHeight();
    },

    /**
     * 行の高さ設定
     */
    setHeight() {
      // 治療方法の高さ設定
      this.setTreatmentAndKurHeight("treatment");
      // スケジュールの高さ設定
      this.setIndRowHeight(
        "sch-category",
        "schItem_",
        "sch_",
        this.dispSchInfo
      );
      // 治療条件高さ設定
      this.setIndRowHeight(
        "cond-category",
        "condItem_",
        "cond_",
        this.dispCondInfo
      );
      // 投与薬剤項目の高さ設定
      this.setMediAndEquipHeigth("medi");
      // 投与薬剤の高さ設定
      this.setSubCategoryHeight(
        "medi-category",
        "mediItem_",
        "medi_",
        this.dispMediInfo,
        this.mediInfoItem,
        "no"
      );
      // 医療材料項目の高さ設定
      this.setMediAndEquipHeigth("equip");
      // 医療材料の高さ設定
      this.setSubCategoryHeight(
        "equip-category",
        "equipItem_",
        "equip_",
        this.dispEquipInfo,
        this.equipInfoItem,
        "cd"
      );
      // 指示コメントの高さ設定
      this.setIndRowHeight(
        "ind-comment-category",
        "indCommentItem_",
        "indComment_",
        this.dispIndCommentInfo
      );
    },

    /**
     * 治療方法・クールの高さ設定
     * @param itemName 治療方法(treatment) or クール(kur)
     */
    setTreatmentAndKurHeight(itemName) {
      // 最大高さの初期値として大項目の高さを格納
      let maxH = this.scopedJQuery(`.${this.addClass}${itemName}-category`).height();
      this.dispTreatmentMethod.forEach((item, index) => {
        // データセルの高さ取得
        const dataCellH = this.scopedJQuery(`.${this.addClass}${itemName}_${index}`).height();
        // 現在格納されている最大高さより大きい場合、高さを格納
        maxH = dataCellH > maxH ? dataCellH : maxH;
      });
      // 大項目に最大高さを設定
      this.scopedJQuery(`.${this.addClass}${itemName}-category`).height(maxH);
      this.dispTreatmentMethod.forEach((item, index) => {
        // データセルに最大高さを設定
        this.scopedJQuery(`.${this.addClass}${itemName}_${index}`).height(maxH);
      });
    },

    /**
     * 指示項目高さ設定
     * @description
     * 中項目、データセルの高さで最大の高さを適用し、
     * すべての行の合計の高さが大項目より低い場合は
     * それぞれの行に倍率をかけて調整する。
     * @param categoryClass 大項目クラス
     * @param subCategoryClass 中項目クラス
     * @param dataCellClass データセルクラス
     * @param dispItem 表示情報
     */
    setIndRowHeight(categoryClass, subCategoryClass, dataCellClass, dispItem) {
      // 大項目高さ
      const categoryH = this.scopedJQuery(`.${this.addClass}${categoryClass}`).outerHeight(
        true
      );
      const sumSubCategoryH = new Array();
      const sumDataCellH = new Array();
      dispItem.forEach((item, index) => {
        // サブカテゴリの高さリストを作成
        const eleSumSubCategoryH = new Array();
        // データセルの高さリストを作成
        const eleSumDataCellH = new Array();
        for (let i = 0; i < item.length; i++) {
          // サブカテゴリーの高さを格納
          const subCategoryH = this.scopedJQuery(
            `.${this.addClass}${subCategoryClass}${i}`
          ).outerHeight();
          eleSumSubCategoryH.push(subCategoryH);
          // データセルの高さを格納
          const dataCellH = this.scopedJQuery(
            `.${this.addClass}${dataCellClass}${index}_${i}`
          ).outerHeight();
          eleSumDataCellH.push(dataCellH);
        }
        sumSubCategoryH.push(eleSumSubCategoryH);
        sumDataCellH.push(eleSumDataCellH);
      });

      const maxSubHObj = new Object();
      // サブカテゴリの最大高さリストを作成
      sumSubCategoryH.forEach(heightlist => {
        heightlist.forEach((height, index) => {
          if (!Object.prototype.hasOwnProperty.call(maxSubHObj, String(index))) {
            ((maxSubHObj)[String(index)] = height);
          }
          // 現在格納されている高さより高い場合、オブジェクトに格納
          if (height > maxSubHObj[String(index)]) {
            ((maxSubHObj)[String(index)] = height);
          }
        });
      });

      const maxCellHObj = new Object();
      // データセル内の最大高さリストを作成
      sumDataCellH.forEach(heightlist => {
        heightlist.forEach((height, index) => {
          if (!Object.prototype.hasOwnProperty.call(maxCellHObj, String(index))) {
            ((maxCellHObj)[String(index)] = height);
          }
          if (height > maxCellHObj[String(index)]) {
            ((maxCellHObj)[String(index)] = height);
          }
        });
      });

      // サブカテゴリ、データセル内の高さの最大値リストを作成
      const maxHList = new Array();
      let maxHeight = 0;
      for (const k in maxCellHObj) {
        const maxH =
          maxSubHObj[k] > maxCellHObj[k] ? maxSubHObj[k] : maxCellHObj[k];
        maxHList.push(maxH);
        maxHeight += maxH;
      }
      // 倍率格納用
      let mag = 1;
      if (categoryH > maxHeight) {
        // 倍率を設定
        mag = categoryH / maxHeight;
      }
      // 適用高さリスト
      const applyHList = new Array();
      maxHList.forEach(height => {
        applyHList.push(height * mag);
      });
      // 高さを適用する
      dispItem.forEach((item, index) => {
        for (let i = 0; i < item.length; i++) {
          // 中項目行に設定
          this.scopedJQuery(`.${this.addClass}${subCategoryClass}${i}`).outerHeight(
            applyHList[i]
          );
          // データセル行に設定
          this.scopedJQuery(`.${this.addClass}${dataCellClass}${index}_${i}`).outerHeight(
            applyHList[i]
          );
        }
      });
    },

    /**
     * 高さをサブカテゴリーの高さに設定
     * @description
     * 投与薬剤、医療材料、指示コメントでデータセルが1つもない場合に適用
     * データセルが存在すれば高さ計算処理を呼び出す
     */
    setSubCategoryHeight(
      categoryClass,
      subCategoryClass,
      dataCellClass,
      dispItem,
      itemInfo,
      keyCd
    ) {
      //
      if(itemInfo[0]){
        if (0 === itemInfo[0][keyCd]) {
          // サブカテゴリーの高さを設定する
          dispItem.forEach((item, index) => {
            for (let i = 0; i < item.length; i++) {
              const height = this.scopedJQuery(
                `.${this.addClass}${subCategoryClass}${i}`
              ).height();
              this.scopedJQuery(`.${this.addClass}${dataCellClass}${index}_${i}`).height(height);
            }
          });
        } else {
          // 高さ計算を実施
          this.setIndRowHeight(
            categoryClass,
            subCategoryClass,
            dataCellClass,
            dispItem
          );
        }
      }
    },

    /**
     * 投与薬剤・医療材料項目の高さ設定
     * @param className 投与薬剤(medi) or 医療材料(equip)
     */
    setMediAndEquipHeigth(className) {
      // データセルクラス名
      const dataCellName =
        "medi" === className ? "medi_value_" : "equip_value_";
      // 項目セルクラス名
      const itemCellName =
        "medi" === className ? "ele_mediInfo_" : "ele_equipInfo_";
      const itemInfo =
        "medi" === className ? this.dispMediInfo : this.dispEquipInfo;
      const o = new Object();
      for (let i = 0; i < itemInfo.length; i++) {
        for (let j = 0; j < itemInfo[i].length; j++) {
          for (let k = 0; k < itemInfo[i][j].label.length; k++) {
            // データセルの高さ
            const dataCellH = this.scopedJQuery(
              `.${this.addClass}${dataCellName}${i}_${j}_${k}`
            ).height();
            // 項目セルの高さ
            const itemCellH = this.scopedJQuery(
              `.${this.addClass}${itemCellName}${j}_${k}`
            ).height();
            // データセルと項目セルで高い方を採用
            let height;
            if (dataCellH) {
              height = dataCellH > itemCellH ? dataCellH : itemCellH;
            } else {
              height = itemCellH;
            }
            // 格納されていない場合、オブジェクトを追加
            if (!Object.prototype.hasOwnProperty.call(o, String(j))) {
              ((o)[String(j)] = new Object());
            }
            // 現在格納されている高さの最大値より大きいまたは、まだ格納されていない場合、高さを格納
            if (
              undefined === o[String(j)][String(k)] ||
              height > o[String(j)][String(k)]
            ) {
              ((o[String(j)])[String(k)] = height);
            }
          }
        }
      }

      // 最大値の高さを格納
      for (let i = 0; i < itemInfo.length; i++) {
        for (let j = 0; j < itemInfo[i].length; j++) {
          for (let k = 0; k < itemInfo[i][j].label.length; k++) {
            this.scopedJQuery(`.${this.addClass}${dataCellName}${i}_${j}_${k}`).height(
              o[String(j)][String(k)]
            );
            this.scopedJQuery(`.${this.addClass}${itemCellName}${j}_${k}`).height(
              o[String(j)][String(k)]
            );
          }
        }
      }
    },

    /**
     * 曜日情報リスト作成
     */
    createWeekInfoList() {
      // 受け取った情報が空の場合処理終了
      if (0 === this.dispDetailInfo.length) {
        return [];
      }
      // 表示曜日の初期化
      this.weekInfoList = new Array();
      this.dispDetailInfo.forEach(item => {
        this.weekInfoList.push(item.treatWeek);
      });
      // 曜日をソート
      this.weekInfoList = this.weekInfoList.sort((a, b) => {
        return a - b;
      });
    },
    /**
     * 詳細情報の作成
     */
    createDetailInfo() {
      // 表示情報が0の場合処理終了
      if (0 === this.dispDetailInfo.length) {
        return;
      }
      // 曜日の順番にソート
      // this.dispDetailInfo.sort((a, b) => {
      //   return a.treatWeek - b.treatWeek;
      // });
      // 治療方法表示情報の初期化
      this.dispTreatmentMethod = new Array();
      // クール表示情報の初期化
      this.dispSchInfo = new Array();
      // 治療条件表示情報の初期化
      this.dispCondInfo = new Array();
      // 投与薬剤項目の初期化
      this.mediInfoItem = new Array();
      // 投与薬剤情報の初期化
      this.dispMediInfo = new Array();
      // 医療材料項目の初期化
      this.equipInfoItem = new Array();
      // 医療材料情報の初期化
      this.dispEquipInfo = new Array();
      // 指示コメント項目の初期化
      this.indCommentInfoItem = new Array();
      // 指示コメント情報の初期化
      this.dispIndCommentInfo = new Array();
      // 表示項目作成ループ
      this.dispDetailInfo.forEach((item, index) => {
        // 投与薬剤項目の設定
        this.mediInfoItem = this.setItemList(
          item.indMediInfo,
          this.mediInfoItem,
          this.dispDetailInfo.length === index + 1,
          "投与薬剤",
          1,
          "no"
        );
        // 医療材料項目の設定
        this.equipInfoItem = this.setItemList(
          item.indEquipInfo,
          this.equipInfoItem,
          this.dispDetailInfo.length === index + 1,
          "医療材料",
          2,
          "cd"
        );
        // 指示コメント項目の設定
        this.indCommentInfoItem = this.setItemList(
          item.indIndCommentInfo,
          this.indCommentInfoItem,
          this.dispDetailInfo.length === index + 1,
          "指示コメント",
          3,
          "no"
        );
      });

      // 表示データ作成ループ
      this.dispDetailInfo.forEach(item => {
        // 治療方法表示情報設定
        this.dispTreatmentMethod.push(this.dispTreatment);
        // スケジュール情報表示情報設定
        //内部remine 5840  mod ljx start
        //this.dispSchInfo.push(this.setSchInfo(item.indKurCd, item.indSchInfo));
        this.dispSchInfo.push(this.setSchInfo(item.indKurCd, item.indBedCd,item.indTreatStartTime));
        //内部remine 5840  mod ljx end
        // 治療条件表示情報設定
        this.dispCondInfo.push(this.setTreatCond(item.indCondInfo));
        // 投与薬剤表示情報作成
        this.dispMediInfo.push(
          this.setIndInfoList(item.indMediInfo, this.mediInfoItem, 1, "no")
        );
        this.dispEquipInfo.push(
          this.setIndInfoList(item.indEquipInfo, this.equipInfoItem, 2, "cd")
        );
        // 指示コメント表示情報作成
        this.dispIndCommentInfo.push(
          this.setIndInfoList(
            item.indIndCommentInfo,
            this.indCommentInfoItem,
            3,
            "no"
          )
        );
      });
    },
    //内部remine 5840  add ljx start
    clearDetailInfo() {
      this.dispMoveDateInfo = "";
      // 治療方法表示情報の初期化
      this.dispTreatmentMethod = new Array();
      // クール表示情報の初期化
      this.dispSchInfo = new Array();
      // 治療条件表示情報の初期化
      this.dispCondInfo = new Array();
      // 投与薬剤項目の初期化
      this.mediInfoItem = new Array();
      // 投与薬剤情報の初期化
      this.dispMediInfo = new Array();
      // 医療材料項目の初期化
      this.equipInfoItem = new Array();
      // 医療材料情報の初期化
      this.dispEquipInfo = new Array();
      // 指示コメント項目の初期化
      this.indCommentInfoItem = new Array();
      // 指示コメント情報の初期化
      this.dispIndCommentInfo = new Array();
    },
    showMoveInfo(info){
      this.dispMoveDateInfo = info;
    },
    //内部remine 5840  add ljx end

    /**
     * スケジュール表示情報を設定
     * @param kurCd クールコード
     */
    //内部remine 5840  mod ljx start
    // setSchInfo(kurCd, schInfo) {
    //   // スケジュール情報格納用
    //   const data = deepCopy(this.schInfoItem);
    //   const findKur = this.mstInfo.mstKurInfo.find(item => {
    //     return (
    //       item.kurCd === kurCd &&
    //       this.$parent.$parent.facilityCd === item.facilityCd &&
    //       "0" === item.isDel
    //     );
    //   });
    //   // クール名
    //   let kurName;
    //   if (findKur) {
    //     kurName = findKur.kurName;
    //   } else {
    //     kurName = 0 !== kurCd ? "削除済み" : "未登録";
    //   }
    //   // スケジュール情報
    //   const schData = "" === schInfo ? {} : JSON.parse(schInfo);
    //   // ベッド名
    //   let bedName;
    //   const findBed = this.mstInfo.mstBedInfo.find(
    //     ({ bedCd }) => bedCd === Number(schData.ind_bed_cd)
    //   );
    //   if (findBed) {
    //     bedName = findBed.bedName;
    //   } else {
    //     bedName = schData.ind_bed_cd ? "未登録" : "削除済み";
    //   }
    //   // 治療開始時刻
    //   const treatStartTime = schData.ind_treat_start_time
    //     ? dayjs(schData.ind_treat_start_time, "HHmm").format("HH:mm")
    //     : "未登録";
    //
    //   data[0].value = kurName;
    //   data[1].value = treatStartTime;
    //   data[2].value = bedName;
    //   return data;
    // },
    setSchInfo(kurCd, bedCd, startTime) {
      // スケジュール情報格納用
      const data = deepCopy(this.schInfoItem);
      const findKur = this.mstInfo.mstKurInfo.find(item => {
        return (
          item.kurCd === kurCd &&
          this._indicationFlowOwner().facilityCd === item.facilityCd &&
          "0" === item.isDel
        );
      });
      // クール名
      let kurName;
      if (findKur) {
        kurName = findKur.kurName;
      } else {
        kurName = 0 !== kurCd ? "削除済み" : "未登録";
      }
      // ベッド名
      let bedName;
      const findBed = this.mstInfo.mstBedInfo.find(item => {
        return (
          item.bedCd === bedCd &&
          this._indicationFlowOwner().facilityCd === item.facilityCd &&
          "0" === item.isDel
        );
      });
      if (findBed) {
        bedName = findBed.bedName;
      } else {
        bedName = 0 !== bedCd ? "削除済み" : "未登録";
      }
      // 治療開始時刻
      const treatStartTime = startTime
        ? dayjs(startTime, "HHmm").format("HH:mm")
        : "未登録";

      data[0].value = kurName;
      data[1].value = treatStartTime;
      data[2].value = bedName;
      return data;
    },
    //内部remine 5840  mod ljx end

    /**
     * 治療条件項目を設定
     * @param condInfo OrdMainに格納されている治療条件情報
     */
    setTreatCond(condInfo) {
      // 治療条件情報格納用
      const data = deepCopy(this.condInfoItem);

      // 文字列の治療条件情報をObjectに変換する
      // mod 10705 【身体情報関連】②指示履歴、指示受け指示承認、治療状況リストマップ＞指示変更 張玲 start
      const o = condInfo === null ? JSON.parse('{}') :JSON.parse(condInfo);
      // mod 10705 【身体情報関連】②指示履歴、指示受け指示承認、治療状況リストマップ＞指示変更 張玲 end

      for (const cd in o) {
        // 治療条件コードの下に値を格納

        // condId(= cd)で対象行を特定する
        const target = data.find(item => item.condId === String(cd));
        if (!target) {
          continue;
        }

        let medicineType = null;
        if (Object.prototype.hasOwnProperty.call(o[cd], "medicine_type")) {
          medicineType = o[cd].medicine_type;
        }

        target.value = this.convertIndCond(cd, o[cd].value, o, medicineType);
        target.isTabooAllergy = this.checkTabooAllergy(cd, o[cd].value, medicineType, target.value);
        target.isDisabled = false;
      }

      // add 10443 身体情報・DW・目標体重バグ 関  start
      // 目標日最近の日付DW取得
      const tDate = dayjs(this.selectDate, "YYYYMMDD").add(1,"day");
      let examDate = "";
      let ctlNo = "";
      let indValue = "";
      this.getPhysicalInfo.forEach(pInfo => {
        if (pInfo.exam_date && dayjs(pInfo.exam_date).isBefore(dayjs(tDate).format("YYYY-MM-DD"))
          &&pInfo.dw !== undefined && pInfo.dw !== null) {
          if (examDate === "" || dayjs(pInfo.exam_date).isAfter(examDate)) {
            examDate = pInfo.exam_date;
            indValue = pInfo.dw;
            ctlNo = pInfo.ctl_no;
          }else if(dayjs(pInfo.exam_date).isSame(examDate)){
            if (ctlNo && pInfo.ctl_no > ctlNo) {
              examDate = pInfo.exam_date;
              indValue = pInfo.dw;
              ctlNo = pInfo.ctl_no;
            }
          }
        }
      });
      // DW
        if (indValue != "") {
          indValue = indValue + " kg";
        }else{
          indValue = "未登録"
        }
      data.forEach(item => {
        if (item.condId === "39" && item.label === "DW") {
          item.value = indValue;
          return;
        }
      })
      // add 10443 身体情報・DW・目標体重バグ 関  end
      // ord_mainに登録されていない治療条件(JSONキーなし)の場合はisDisabledをtrueに設定。セルをグレーアウトする
      // mod 10443 身体情報・DW・目標体重バグ 関  start
      const notInOrdMain = data.filter(item => !(item.condId in o) && item.condId != "39");
      // mod 10443 身体情報・DW・目標体重バグ 関  end
      notInOrdMain.forEach(item => {
        item.isDisabled = true;
        item.value = ""; // 値クリア
      });
      // add 10705 【身体情報関連】②指示履歴、指示受け指示承認、治療状況リストマップ＞指示変更 張玲 start
      if (notInOrdMain.findIndex(item => item.condId === "3") > -1) {
        data.find(item => item.condId === "39").isDisabled = notInOrdMain[notInOrdMain.findIndex(item => item.condId === "3")].isDisabled;
        data.find(item => item.condId === "39").value = ""
      } else {
        data.find(item => item.condId === "39").isDisabled = false;
      }
      // add 10705 【身体情報関連】②指示履歴、指示受け指示承認、治療状況リストマップ＞指示変更 張玲 end
      return data;
    },

    /**
     * 禁忌・アレルギーチェック
     * @param cd 治療条件識別情報
     * @param value 変換する値
     * @param medicineType 薬剤区分
     * @param dispName 表示する物品名
     */
    checkTabooAllergy(cd, value, medicineType, dispName) {
      let returnValue = false;
      let findObj = null;
      let mstDataInfo = "mstMedicineInfo";
      let mstCd = "medicineCd";
      let mstName = "medicineName";
      switch (parseInt(cd)) {
        // ダイアライザ
        case 5:
          findObj = this.mstInfo.mstDialyzerInfo.find(item => {
            return item.dialyzerCd == value;// mod #9973 value Number→文字列  shiyw
          });
          if (findObj) {
            returnValue = findObj.modelNumber !== dispName;
          } else {
            return false;
          }
          return returnValue;

        // 吸着カラム
        // 1次膜
        // 2次膜
        // 穿刺針(A針)
        // 穿刺針(V針)
        // 穿刺針(SN)
        // 血液回路
        case 6:
        case 7:
        case 8:
        case 9:
        case 10:
        case 11:
        case 13:
          // 医療材料マスタから検索
          findObj = this.mstInfo.mstEquipmentInfo.find(item => {
            return item.equipmentCd == value;// mod #9973 value Number→文字列  shiyw
          });
          if (findObj) {
            returnValue = findObj.equipmentName !== dispName;
          } else {
            return false;
          }
          return returnValue;

        // 透析液
        // 補液
        // 抗凝固剤
        case 15:
        case 19:
        case 25:
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
          //if (medicineType === "2") {
          if (medicineType == 2) {
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
            // 調製薬剤なら
            mstDataInfo = "mstMedicineMixInfo";
            mstCd = "medicineMixCd";
            mstName = "medicineMixName";
          }
          // 薬剤マスタから検索
          findObj = this.mstInfo[mstDataInfo].find(item => {
            return item[mstCd] == value;// mod #9973 value Number→文字列  shiyw
          });
          if (findObj) {
            returnValue = findObj[mstName] !== dispName;
          } else {
            return false;
          }
          return returnValue;

        default:
          return false;
      }

    },

    /**
     * 治療条件値変換
     * @param cd 治療条件識別情報
     * @param value 変換する値
     * @param indCondInfo 治療条件情報
     * @param medicineType 薬剤区分
     */
    convertIndCond(cd, value, indCondInfo, medicineType) {
      const v = parseInt(value);
      let hour = null;
      let min = null;
      let returnValue = null;
      let findObj = null;
      let mstDataInfo = "mstMedicineTabooAllergyInfo";
      let mstCd = "medicineCd";
      let mstName = "medicineName";
      let numbers = null;
      let decPoint = null;

      // value=nullの場合は"未登録"を表示
      if (value === null) {
        return "未登録";
      }
      switch (parseInt(cd)) {
        // 治療時間
        case 1:
          hour = String(Math.floor(value / 60));
          hour = hour.padStart(2, "0");
          min = String(value % 60);
          min = min.padStart(2, "0");
          return `${hour}:${min}`;

        // VA
        case 2:
          findObj = this.mstInfo.mstVaInfo.find(item => {
            return item.vaCd == value;// mod #9973 value Number→文字列  shiyw
          });
          if (findObj) {
            returnValue = findObj.vaName;
          } else {
            returnValue = "削除済み";
          }
          return returnValue;

        // 目標体重
        case 3:
          return null === value || '-1' == value ? "DWと同じ" : `${value} kg`;// mod #9973 value Number→文字列  shiyw

        // 除水量制限
        // 補液量
        case 4:
        case 20:
          return null === value ? "" : `${Number(value).toFixed(2)} L`;

        // ダイアライザ
        case 5:
          findObj = this.mstInfo.mstDialyzerTabooAllergyInfo.find(item => {
            return item.dialyzerCd == value;// mod #9973 value Number→文字列  shiyw
          });
          if (findObj) {
            returnValue = findObj.modelNumber;
          } else {
            returnValue = "削除済み";
          }
          return returnValue;

        // 吸着カラム
        // 1次膜
        // 2次膜
        // 穿刺針(A針)
        // 穿刺針(V針)
        // 穿刺針(SN)
        // 血液回路
        case 6:
        case 7:
        case 8:
        case 9:
        case 10:
        case 11:
        case 13:
          // 医療材料マスタから検索
          findObj = this.mstInfo.mstEquipmentTabooAllergyInfo.find(item => {
            // mod #9973 value Number→文字列 張玲 start
            // return item.equipmentCd === value;
            return item.equipmentCd == value;
            // mod #9973 value Number→文字列 張玲 end
          });
          if (findObj) {
            returnValue = findObj.equipmentName;
          } else {
            returnValue = null === value ? "" : "削除済み";
          }
          return returnValue;

        // SN使用
        // IP使用選択
        case 12:
        case 29:
          return 1 === v ? "使用する" : 0 === v ? "使用しない" : "未登録";

        // 血流量
        // 透析液流量
        case 14:
        case 16:
          return null === value ? "" : `${value} mL/min`;

        // 透析液
        // 補液
        // 抗凝固剤
        case 15:
        case 19:
        case 25:
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
          //if (medicineType === "2") {
          if (medicineType == 2) {
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
            // 調製薬剤なら
            mstDataInfo = "mstMedicineMixTabooAllergyInfo";
            mstCd = "medicineMixCd";
            mstName = "medicineMixName";
          }
          // 薬剤マスタから検索
          findObj = this.mstInfo[mstDataInfo].find(item => {
            // mod #9973 value Number→文字列 張玲 start
            // return item[mstCd] === value;
            return item[mstCd] == value;
            // mod #9973 value Number→文字列 張玲 end
          });
          if (findObj) {
            returnValue = findObj[mstName];
          } else {
            returnValue = "削除済み";
          }
          return returnValue;

        // 透析液使用数
        case 17:
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
          //if (medicineType === "2") {
          if (medicineType == 2) {
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
            // 調製薬剤なら
            mstDataInfo = "mstMedicineMixInfo";
            mstCd = "medicineMixCd";
          }

          // 薬剤マスタから検索 ※透析液薬剤の単位を付与
          findObj = this.mstInfo[mstDataInfo].find(item => {
            // 透析液値
            const indCondInfo_15 = indCondInfo["15"].value;
            //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240424 start
            return item[mstCd] == indCondInfo_15;
            //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240424 end
          });
          returnValue = value;
          if (findObj) {
            // 数値項目への小数点対応
            //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240424 start
            numbers = String(BigNumber(value).toFixed()).split('.');
            //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240424 end
            decPoint = (numbers[1]) ? numbers[1].length : 0;
            if(decPoint > findObj.unitDecimalPointSecond){
              returnValue = BigNumber(1 * value).toFixed();
            }else{
              returnValue = BigNumber(1 * value).toFixed(findObj.unitDecimalPointSecond);
            }
            if (null !== findObj.unitSecond) {
              // 単位設定あり時のみ追加
              returnValue = `${returnValue} ${findObj.unitSecond}`;
            }
          }
          return null === value ? "" : returnValue;

        // 透析温度
        // 補液温度
        case 18:
        case 23:
          return null === value ? "" : `${Number(value).toFixed(1)} ℃`;

        // 補液選択
        case 21:
          return 0 === v ? "後補液" : 1 === v ? "前補液" : "未登録";

        // 補液使用数
        case 22:
          if (
            Object.prototype.hasOwnProperty.call(indCondInfo["19"], "medicine_type") &&
            // mod #9973 shiyw start
            //indCondInfo["19"].medicine_type === "2"
            indCondInfo["19"].medicine_type == 2
            // mod #9973 shiyw end
          ) {
            // 調製薬剤なら
            mstDataInfo = "mstMedicineMixInfo";
            mstCd = "medicineMixCd";
          }

          // 補液の薬剤の単位を付与
          findObj = this.mstInfo[mstDataInfo].find(item => {
            // 補液値
            const indCondInfo_19 = indCondInfo["19"].value;
            //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240424 start
            return item[mstCd] == indCondInfo_19;
            //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240424 end
          });
          returnValue = value;
          if (findObj) {
            // 数値項目への小数点対応
            //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240424 start
            numbers = String(BigNumber(value).toFixed()).split('.');
            //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240424 end
            decPoint = (numbers[1]) ? numbers[1].length : 0;
            if(decPoint > findObj.unitDecimalPointSecond){
              returnValue = BigNumber(1 * value).toFixed();
            }else{
              returnValue = BigNumber(1 * value).toFixed(findObj.unitDecimalPointSecond);
            }
            if (null !== findObj.unitSecond) {
              // 単位設定あり時のみ追加
              returnValue = `${returnValue} ${findObj.unitSecond}`;
            }
          }
          return null === value ? "" : returnValue;

        // 補液速度
        case 24:
          return null === value ? "" : `${Number(value).toFixed(2)} L/h`;

        // 抗凝固剤ワンショット量
        // 抗凝固剤持続速度
        // 抗凝固剤持続速度
        case 26:
        case 27:
        case 28:
          if (
            Object.prototype.hasOwnProperty.call(indCondInfo["25"], "medicine_type") &&
            // mod #9973 shiyw start
            //indCondInfo["25"].medicine_type === "2"
            indCondInfo["25"].medicine_type == 2
            // mod #9973 shiyw end
          ) {
            // 調製薬剤なら
            mstDataInfo = "mstMedicineMixInfo";
            mstCd = "medicineMixCd";
          }

          // 抗凝固剤の薬剤の単位を付与
          findObj = this.mstInfo[mstDataInfo].find(item => {
            // 抗凝固剤値
            const indCondInfo_25 = indCondInfo["25"].value;
            //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240424 start
            return item[mstCd] == indCondInfo_25;
            //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240424 end
          });
          returnValue = value;
          if (findObj) {
            // 数値項目への小数点対応
            //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240424 start
            numbers = String(BigNumber(value).toFixed()).split('.');
            //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240424 end
            decPoint = (numbers[1]) ? numbers[1].length : 0;
            if(decPoint > findObj.unitDecimalPoint){
              returnValue = BigNumber(1 * value).toFixed();
            }else{
              returnValue = BigNumber(1 * value).toFixed(findObj.unitDecimalPoint);
            }
            if (null !== findObj.unit) {
               switch (parseInt(cd)) {
                case 26:
                case 28:
                  returnValue = `${returnValue} ${findObj.unit}`;
                  break;

                case 27:
                  returnValue = `${returnValue} ${findObj.unit}/h`;
                  break;
              }
            }
          }
          return null === value ? "" : returnValue;

        // IPスタート
        // IPワンショットスタート
        case 30:
        case 34:
          return 0 === v ? "手動" : 1 === v ? "自動" : "未登録";

        // IPワンショット量
        case 31:
          return null === value ? "" : `${value} mL`;

        // IP速度
        // IP速度最大値
        case 32:
        case 33:
          return null === value ? "" : `${value} mL/h`;

        // IP電源自動切り
        // IP電源OKモニタ切り
        case 35:
        case 37:
          return 0 === v ? "切" : 1 === v ? "入" : "未登録";

        // IP電源自動切り時間
        // IP電源OKモニタ切り時間
        case 36:
        case 38:
          return null === value ? "" : `${value} 分`;

        default:
          return value;
      }
    },

    /**
     * 指示項目作成
     * @param currentInfo 編集をする情報
     * @param tagetInfo   格納元
     * @param isEnd       格納が最後かどうか
     * @param itemName    項目名
     * @param itemClass       項目クラス
     *                    1->投与薬剤、2->医療次亜量、3->指示コメント
     * @param keyCd       取得するシーケンス番号のキー名
     * @param keyValue    取得する値のキー名
     */
    setItemList(currentInfo, tagetInfo, isEnd, itemName, itemClass, keyCd) {
      // 指示項目情報格納
      /* modify by chamaojia 2024-04-03 [10196] add null judgment processing  --start */
      // let itemInfoList = JSON.parse(currentInfo);
      let itemInfoList = currentInfo ? JSON.parse(currentInfo) : [];
      /* modify by chamaojia 2024-04-03 [10196] add null judgment processing  --end */
      itemInfoList = "" === itemInfoList ? new Array() : itemInfoList;
      // 指示コメントが1つも格納されていない場合が「指示コメント」を返す
      if (0 === itemInfoList.length && 0 === tagetInfo.length && isEnd) {
        const o = new Object();
        ((o)["label"] = 3 === parseInt(itemClass) ? itemName : [itemName]);
        ((o)[keyCd] = 0);
        return [o];
      }
      let arr = deepCopy(tagetInfo);
      itemInfoList.forEach(item => {
        const findO = arr.find(eleItem => {
          return eleItem[keyCd] === item[keyCd];
        });
        // 指示コメントが格納されているかチェックする
        if (!findO) {
          const o = new Object();
          // シーケンス番号格納
          ((o)[keyCd] = item[keyCd]);
          // 項目名格納用
          let label = null;
          switch (parseInt(itemClass)) {
            // 投与薬剤
            case 1:
              label = ["薬剤", "投与間隔", "数量", "手技", "投与タイミング"];
              break;

            // 医療材料
            case 2:
              label = ["医療材料", "数量"];
              break;

            // 指示コメント
            case 3:
              label = `コメント${item[keyCd]}`;
              break;

            default:
              break;
          }
          ((o)["label"] = label);
          arr.push(o);
        }
      });
      // 指示コメントを番号でソート
      arr = arr.sort((a, b) => {
        return a[keyCd] - b[keyCd];
      });
      return arr;
    },

    /**
     * 指示表示データリスト設定
     * @param currentInfo 編集をする情報
     * @param itemInfo 項目情報
     * @param itemClass クラス
     *   1->投与薬剤 2->医療材料 3->指示コメント
     */
    setIndInfoList(currentInfo, itemInfo, itemClass, keyCd) {
      const arr = new Array();
      /* modify by chamaojia 2024-04-03 [10196] add null judgment processing  --start */
      // let itemInfoList = JSON.parse(currentInfo);
      let itemInfoList = currentInfo ? JSON.parse(currentInfo) : [];
      /* modify by chamaojia 2024-04-03 [10196] add null judgment processing  --end */
      itemInfoList = "" === itemInfoList ? new Array() : itemInfoList;
      // 作成した項目分ループ
      itemInfo.forEach(item => {
        const o = deepCopy(item);
        const findO = itemInfoList.find(eleItem => {
          return o[keyCd] === eleItem[keyCd];
        });
        if (findO) {
          // 表示値格納用
          let value = null;
          let isTabooAllergy = false;
          switch (itemClass) {
            // 投与薬剤
            case 1:
              value = this.setMediInfo(findO);
              isTabooAllergy = this.checkMediTabooAllergy(findO, value[0]);
              break;

            // 医療材料
            case 2:
              value = this.setEquipInfo(findO);
              isTabooAllergy = this.checkEquipTabooAllergy(findO, value[0]);
              break;

            // 指示コメント
            case 3:
              value = findO.content;
              break;

            default:
              break;
          }
          ((o)["value"] = value);
          ((o)["isTabooAllergy"] = isTabooAllergy);
        } else {
          ((o)["value"] = null);
          ((o)["isTabooAllergy"] = false);
        }
        arr.push(o);
      });
      return arr;
    },

    /**
     * 投与薬剤情報設定
     * @description
     * 投与薬剤コードを元に、
     * 薬剤・投与間隔・数量・手技・投与タイミングを設定する
     */
    setMediInfo(mediInfo) {
      let mstData = "mstMedicineTabooAllergyInfo";
      let mstCd = "medicineCd";
      let mstName = "medicineName";
      // mod #9973 shiyw start
      //if (mediInfo.medicine_type === "2") {
      if (mediInfo.medicine_type == 2) {
        // mod #9973 shiyw end
        // 調製薬剤なら
        mstData = "mstMedicineMixTabooAllergyInfo";
        mstCd = "medicineMixCd";
        mstName = "medicineMixName";
      }

      // 薬剤・調製薬剤マスタから検索
      const findMedi = this.mstInfo[mstData].find(item => {
        return item[mstCd] === mediInfo.cd;
      });

      let returnValue = mediInfo.amount;
      if (findMedi) {
        //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 start
        // 数値項目への小数点対応
        let numbers = String(BigNumber(mediInfo.amount).toFixed()).split('.');
        //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 end
        let decPoint = (numbers[1]) ? numbers[1].length : 0;
        if(decPoint > findMedi.unitDecimalPoint){
          returnValue = BigNumber(1 * mediInfo.amount).toFixed();
        }else{
          returnValue = BigNumber(1 * mediInfo.amount).toFixed(findMedi.unitDecimalPoint);
        }
      }

      // 薬剤名 ※初期値は削除済みとする
      let mediName = "削除済み";
      // 単位
      let unit = "";
      if (findMedi) {
        mediName = findMedi[mstName];
        unit = null !== findMedi.unit ? ` ${findMedi.unit}` : "";
      }
      // 手技名
      let procedureName = "";
      // 手技マスタから検索
      const findProcedure = this.mstInfo.mstProcedureInfo.find(item => {
        return item.procedureCd === mediInfo.procedure_cd;
      });
      if (findProcedure) {
        procedureName = findProcedure.pricedureName;
      }
      // タイミング名
      let timingName = "";
      const findTiming = this.mstInfo.mstMedicateTimingInfo.find(item => {
        return item.medicateTimingCd === mediInfo.timing_cd;
      });
      if (findTiming) {
        timingName = findTiming.medicateTimingName;
      }
      return [
        mediName,
        "毎回",
        mediInfo.amount ? returnValue + unit : unit,
        procedureName,
        timingName
      ];
    },

    /**
     * 投与薬剤 禁忌・アレルギーチェック
     * @param mediInfo 項目情報
     * @param dispName 表示する物品名
     */
    checkMediTabooAllergy(mediInfo, dispName) {
      let returnValue = false;
      let mstData = "mstMedicineInfo";
      let mstCd = "medicineCd";
      let mstName = "medicineName";
      // mod #9973 shiyw start
      //if (mediInfo.medicine_type === "2") {
      if (mediInfo.medicine_type == 2) {
        // mod #9973  shiyw end
        // 調製薬剤なら
        mstData = "mstMedicineMixInfo";
        mstCd = "medicineMixCd";
        mstName = "medicineMixName";
      }
      // 薬剤・調製薬剤マスタから検索
      const findMedi = this.mstInfo[mstData].find(item => {
        return item[mstCd] === mediInfo.cd;
      });
      if (findMedi) {
        returnValue = findMedi[mstName] !== dispName;
      } else {
        return false;
      }
      return returnValue;

    },

    /**
     * 医療材料情報設定
     */
    setEquipInfo(equipInfo) {
      // 医療材料マスタから検索
      const findEquip = this.mstInfo.mstEquipmentTabooAllergyInfo.find(item => {
        return item.equipmentCd === equipInfo.cd;
      });
      // 医療材料名 ※初期値は削除済みとする
      let equipName = "削除済み";
      // 単位
      let unit = "";
      if (findEquip) {
        equipName = findEquip.equipmentName;
        unit = null !== findEquip.unit ? ` ${findEquip.unit}` : "";
      }
      return [equipName, equipInfo.amount + unit];
    },

    /**
     * 投与薬剤 禁忌・アレルギーチェック
     * @param equipInfo 項目情報
     * @param dispName 表示する物品名
     */
    checkEquipTabooAllergy(equipInfo, dispName) {
      let returnValue = false;
      // 医療材料マスタから検索
      const findEquip = this.mstInfo.mstEquipmentInfo.find(item => {
        return item.equipmentCd === equipInfo.cd;
      });
      if (findEquip) {
        returnValue = findEquip.equipmentName !== dispName;
      } else {
        return false;
      }
      return returnValue;

    },

    /**
     * データ表示列スタイル
     * @description
     * 曜日Boxの幅に合わせる
     * 4つ以上ある場合は、3つまでの時の幅で設定する
     */
    dispDataColumnStyle() {
      // 曜日情報スタイル
      const weekLen = this.weekInfoList.length;
      let w = this.weekWidth;
      if (weekLen > 0) {
        if (weekLen >= 3) {
          w = (w * 7) / 3 + 4;
        } else {
          w = (w * 7) / weekLen + (7 - weekLen);
        }
      }
      return { width: `${w}px`, "max-width": `${w}px` };
    },

    /**
     * 大項目スタイル
     * @description
     * 投与薬剤、医療材料、指示コメントで表示項目がない場合、
     * 大項目の表示をなくす
     */
    categoryStyle(itemInfo, keyCd) {
      const o = new Object();
      if (itemInfo[0]) {
        if (0 === itemInfo[0][keyCd]) {
          o.display = "none";
        }
      }
      return o;
    },

    /**
     * 曜日日本語表記
     */
    convertWeekName(weekCd) {
      switch (Number(weekCd)) {
        case 1:
          return "月";
        case 2:
          return "火";
        case 3:
          return "水";
        case 4:
          return "木";
        case 5:
          return "金";
        case 6:
          return "土";
        case 7:
          return "日";
        default:
          break;
      }
    },

    /**
     * 「目標体重」行にDWの最新情報を表示する
     */
    createTargetWeightDWInfo() {
      const targetWeight = this.condInfoItem.find(
        ({ condId }) => condId === "3"
      );

      // 「目標体重」
      if (targetWeight) {
        targetWeight.label = "目標体重";
      }
    },
    
    /**
     * 休日のスタイル取得
     */
    getStyle(date) {
      return getHolidayStyle(date);
    }
  }
};
</script>

<style scoped>
.item-table-style {
  font-size:1.0em;
}

.vertical-header-style {
  writing-mode: vertical-lr;
  padding: 3px 0;
  color: #fafafa;
  background-color: #333333;
  border-right: 0.5px solid #cccccc;
  border-bottom: 0.5px solid #cccccc;
  word-break: break-all;
  white-space: nowrap;
  width: 20px;
  max-width: 27px;
  text-align: left;
}

.hader-item-stlye {
  border-bottom: 0.5px solid #cccccc;
  border-right: 0.5px solid #cccccc;
  text-align: center;
  max-height: 25px;
  min-height: 25px;
  background-color: #333333;
  color: white;
}

.item-label-style {
  border-right: 0.5px solid #cccccc;
}
/* mod #10281 曜日パターン変更画面のスタイル、レイアウト不正 宮崎 start */
.item-table-row-style {
  border-bottom: 0.5px solid #cccccc;
  border-right: 0.5px solid #cccccc;
  height: auto;
  text-align: left;
  white-space: normal;
  padding: 3px;
}
/* mod #10281 曜日パターン変更画面のスタイル、レイアウト不正 宮崎 end */
.item-coloumn-style {
  width: 130px;
  max-width: 150px;
  color: #fafafa;
  background-color: #333333;
  word-break: break-all;
}

.left-column-style {
  width: 100px;
  max-width: 100px;
}

.item-style {
  width: 150px;
  max-width: 150px;
  float: left;
  position: sticky;
  left: 0;
}

.data-style {
  overflow-x: auto;
  overflow-y: hidden;
}

.inline-block-style {
  display: inline-block;
}

.data-cell-style {
  text-align: center !important;
  white-space: normal;
  margin: auto;
}
/* mod #10281 曜日パターン変更画面のスタイル、レイアウト不正 宮崎 start */
.category-cell-style {
  color: #fafafa;
  background-color: #333333;
  width: 100px;
  border-right: 0.5px solid #cccccc;
  border-bottom: 0.5px solid #cccccc;
  text-align: left;
  padding: 3px;
  word-break: break-all;
  white-space: pre-wrap;
  height: auto;
}
/* mod #10281 曜日パターン変更画面のスタイル、レイアウト不正 宮崎 end */
.week-header-style {
  border-right: 0.5px solid #faf1f1;
}
/* mod #10281 曜日パターン変更画面のスタイル、レイアウト不正 宮崎 start */
.ele-item-table-row-style {
  height: auto;
  text-align: left;
  white-space: normal;
}
/* mod #10281 曜日パターン変更画面のスタイル、レイアウト不正 宮崎 end */
.data-col-cell {
  margin: auto;
}

.item-col-cell {
  margin: auto 0;
}
.taboo-allergy {
  color: red;
}

.cell-disabled {
  background-color: var(--pat-viewer-ind-cond-info-disabled);
}
/** iPhone X/8/7/6 or Android(M,L) */
/** Device Width:360-480           */
/** ボックス要素-スクロール制御 */
@media only screen and (min-device-width:360px) and (max-device-width:480px) {
  .table-style{
    overflow-x: auto;
    overflow-y: auto;
    -webkit-overflow-scrolling:auto;
    overscroll-behavior-y: auto;
    text-align: center;
    max-width:650px;
    max-height:150px;
  }
  .item-table-style{
    min-width:650px;
  }

  .item-style {
    width: 120px;
    float: left;
    left: 0;
  }
  .data-style {
    overflow-x: auto;
    overflow-y: hidden;
    min-width:190px;
    max-width:650px;
  }
  .week-header-style {
    min-width:70px;
    max-width:180px;
  }
  .item-table-col-style{
    min-width:70px;
    max-width:180px;
  }
}
@media print {
  .item-table-style{
    display: inline-flex !important;
    width: 100% !important;
  }
  .data-style{
    width: 100% !important;
  }
}
</style>
