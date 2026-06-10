/** * マスタ選択 */

<template>
  <v-ons-popover
    :target="targetPositionElement"
    :visible="popoverVisible"
    :direction="popoverDisplayDirection"
    :class="[fontSizeSet, 'popover-style']"
    cancelable
    @posthide="closePopover(); popoverPosthide()"
    @preshow="popoverPreShow"
    @postshow="popoverPostShow"
  >
    <div>
      <v-ons-row>
        <h2 class="popover-header-style">{{ popoverTitleHeader }}</h2>
      </v-ons-row>
      <hr />

      <v-ons-row class="div-style">
        <v-ons-col width="9em">
           <label class="label-style">グラフ縦軸上限値</label>
        </v-ons-col>
        <v-ons-col>
          <keep-alive>
            <component
              :is="'custom-input-number-pro'"
              class="search-style"
              :step="0.01"
              :value="tempMax"
              :key="targetInfo.categoryNo + '_' + targetInfo.subCategoryNo"
              :min="min"
              :max="max"
              @handlerInput="
                (val) => {
                  tempMax = val;
                }
              "
              @blur="handleBlur($event, 1, 0)"
            />
          </keep-alive>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="div-style">
        <v-ons-col width="9em">
          <label class="label-style">グラフ縦軸下限値</label>
        </v-ons-col>
        <v-ons-col>
          <keep-alive>
            <component
              :is="'custom-input-number-pro'"
              class="search-style"
              :step="0.01"
              :value="tempMin"
              :key="targetInfo.categoryNo + '_' + targetInfo.subCategoryNo"
              :min="min"
              :max="max"
              @handlerInput="
                (val) => {
                  tempMin = val;
                }
              "
              @blur="handleBlur($event, 2, 1)"
            />
          </keep-alive>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row>
        <v-ons-col width="9em">
          <label class="label-style">対象薬剤</label>
        </v-ons-col>
        <v-ons-col>
          <div style="width: 100%; min-width: 200px; display: flex; align-items: center;">
            <v-ons-radio
              modifier="round"
              v-model="dosOrPre"
              :value="'0'"
              name="aaa"
            />
            <label class="label-style" style="margin-right: 1em;">投薬</label>
            <v-ons-radio
              modifier="round"
              v-model="dosOrPre"
              :value="'1'"
              name="aaa"
            />
            <label class="label-style">処方</label>
          </div>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row>
        <v-ons-col width="9em">
          <label class="label-style">薬剤状態</label>
        </v-ons-col>
        <v-ons-col>
          <div style="width: 100%; min-width: 200px; display: flex; align-items: center;">
            <v-ons-radio
              modifier="round"
              v-model="drugStatus"
              :value="'指示'"
              name="drugStatusSName"
            />
            <label class="label-style" style="margin-right: 1em;">指示</label>
            <v-ons-radio
              modifier="round"
              v-model="drugStatus"
              :value="'実績'"
              name="drugStatusSName"
            />
            <label class="label-style" style="margin-right: 1em;">実績</label>
            <v-ons-radio v-if="medicatioSupport"
              modifier="round"
              v-model="drugStatus"
              :value="'投薬支援'"
              name="drugStatusSName"
            />
            <label class="label-style" v-if="medicatioSupport">投薬支援</label>
          </div>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row
        v-for="filter in popoverFilter"
        :key="filter.popoverFilterLabel"
        class="div-style"
      >
        <v-ons-col width="9em">
          <label class="label-style">{{ filter.popoverFilterLabel }}</label>
        </v-ons-col>
        <v-ons-col>
<!--          mod 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start-->
          <v-ons-select
            v-if="filter.popoverFilterLabel === '薬剤分類'"
            v-model="popoverFilterSelectedItem[filter.popoverFilterLabel]"
            :disabled="popoverFilterDisabled || !investmentSupport || categoryFlg"
            class="select-filter-style select-font-inherit"
            @change="filterChange($event, filter.popoverFilterLabel)"
          >
            <option
              v-for="data in filter.popoverFilterDataset"
              :key="data.id"
              :value="data.value"
            >
              {{ data.text }}
            </option>
          </v-ons-select>
          <v-ons-select v-else
            v-model="popoverFilterSelectedItem[filter.popoverFilterLabel]"
            :disabled="popoverFilterDisabled || !investmentSupport"
            class="select-filter-style select-font-inherit"
            @change="filterChange($event, filter.popoverFilterLabel)"
          >
<!--           mod 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end-->
            <option
              v-for="data in filter.popoverFilterDataset"
              :key="data.id"
              :value="data.value"
            >
              {{ data.text }}
            </option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="div-style">
        <v-ons-col width="9em">
          <label class="label-style">フリーワード</label>
        </v-ons-col>
        <v-ons-col>
          <input
            v-model="popoverSearchQuery"
            class="search-style"
            style="min-width: 200px;"
            type="search"
            placeholder="検索"
          />
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="div-style">
        <v-ons-col width="9em">
          <label class="label-style">{{ popoverContentLabel }}</label>
        </v-ons-col>
        <v-ons-col class="mult-selector" style="margin-bottom: 10px;margin-top: 5px; min-width: 200px;">
          <div
            v-for="content in popoverFilteredContent"
            :key="content.id"
            :class="beginStatue(content.value)"
            :value="content.value"
            @click="selectedMedi(content.value)"
          >
            <!--mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start-->
            <!--{{ content.text }}-->
            {{content.isDispflag == 1 ? content.text : content.isDispflag == 0 && content.isDisp == 1 ?"【削除済み】"+ content.text : ""}}
            <!--mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end-->
          </div>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row v-if="isDisplayNeedleOption">
        <v-ons-col width="9em" />
        <v-ons-col>
          <label class="label-style">
            <input
              v-model="needleValue"
              :disabled="isDisabledNeedleA"
              type="radio"
              name="mstSelNeedleType"
              value="1"
            />
            <span>A針</span>
          </label>
          <label class="label-style">
            <input
              v-model="needleValue"
              :disabled="isDisabledNeedleV"
              type="radio"
              name="mstSelNeedleType"
              value="2"
            />
            <span>V針</span>
          </label>
          <label class="label-style">
            <input
              v-model="needleValue"
              :disabled="isDisabledNeedleSN"
              type="radio"
              name="mstSelNeedleType"
              value="3"
            />
            <span>SN</span>
          </label>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col>
          <v-ons-button
            class="common-style-cancel-button button-cancel btn2-cancel"
            @click="closePopover"
          >
            キャンセル
          </v-ons-button>
        </v-ons-col>
        <v-ons-col>
          <v-ons-button
            class="common-style-ok-button button-confirm btn1-execute"
            @click="saveChanges"
          >
            OK
          </v-ons-button>
        </v-ons-col>
      </v-ons-row>
    </div>
  </v-ons-popover>
</template>

<script>
import _ from "underscore";
import PopoverMixin from "@/components/PopoverMixin";
import {mapGetters} from "vuex";
import { ADVANCED_SETTINGS } from "@/constants/advancedSettings";
import {sendRequestGetMstFacilityByCd} from "@/apis/facility";
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
import CustomInputNumberPro from "@/components/common/custom-form-tags/CustomInputNumberPro";
//#10176:ポップアップのフリーワード検索の動作不正 Start
const MEDICINE_MIX_TAG = 'MEDICINE_MIX';
//#10176:ポップアップのフリーワード検索の動作不正 End
export default {
  mixins: [PopoverMixin],
  components: {"custom-input-number-pro": CustomInputNumberPro},
  props: {
    /**
     * @description ポップオーバー表示非表示
     */
    popoverVisible: {
      type: Boolean,
      default: false
    },

    /**
     * @description ポップオーバーヘッダーテキスト
     */
    popoverTitleHeader: {
      type: String,
      default: ""
    },

    /**
     * @description 抽出条件
     *              ※ 何も渡さないと抽出条件の入力フィルドが表示されない
     *              ※ 配列の中身: { popoverFilterLabel: '', popoverFilterDataset: [] }
     */
    popoverFilter: {
      type: Array,
      default: () => []
    },

    /**
     * @description 抽出条件の選択有効無効
     */
    popoverFilterDisabled: {
      type: Boolean,
      default: false
    },

    popoverSelector: {
      type: Array,
      default: () => []
    },

    popoverSelectorDisabled: {
      type: Boolean,
      default: false
    },

    /**
     * @description 抽出結果のラベル
     */
    popoverContentLabel: {
      type: String,
      default: ""
    },

    drugStatus: {
      type: String,
      default: "'指示'"
    },

    graphMin: {
      type: Number,
      default: 0
    },

    graphMax: {
      type: Number,
      default: 0
    },

    /**
     * @description 抽出する選択肢
     *              ※ 抽出結果は計算プロパティ「popoverFilteredContent」に定義されている
     */
    popoverContentDataset: {
      type: Array,
      default: () => []
    },

    /**
     * @description 抽出結果の選択項目
     */
    popoverContentSelected: {
      type: Object,
      default: () => {
        return {
          value: "",
          fnValue: {},
          text: ""
        };
      }
    },

    /**
     * @description ポップオーバーの呼び出し元(DOMオブジェクト)
     */
    targetPositionElement: {
      type: [Object, HTMLElement],
      default() {
        return this.$parent;
      }
    },

    /**
     * @description 「未登録」選択の有無
     */
    hasUnregisteredOption: {
      type: Boolean,
      default: true
    },

    /**
     * @description 「穿刺針」選択区分(固定定義の場合)
     */
    needleType: {
      type: Number,
      default: null
    },
    
    /**
     * @description ポップオーバー対象項目
     */
    targetInfo: {
      type: Object,
      default: () => {
        return {
          categoryNo: null,
          subCategoryNo: null
        };
      }
    },
    
  },

  data() {
    return {
      /**
       * @description 各抽出条件の選択項目
       *              ※ popoverContentDatasetから抽出条件によって絞り込む結果
       *              ※ key:「popoverFilter」の「popoverFilterLabel」
       *              ※ value:「popoverFilter」の「popoverFilterDataset」からの項目
       */
      popoverFilterSelectedItem: {},

      /**
       * @description 抽出結果の選択項目
       */
      popoverContentSelectedItem: this.popoverContentSelected.value,

      /**
       * @description フリーワードによる抽出結果
       */
      popoverSearchDataset: [],

      /**
       * @description フリーワード入力値
       */
      popoverSearchQuery: "",

      /**
       * @description 表示方向
       */
      popoverDirection: "",

      /**
       * @description 「穿刺針」選択有無
       */
      isDisplayNeedleOption: false,

      /**
       * @description 「穿刺針」選択項目
       */
      needleValue: this.popoverContentSelected.needle,

      /**
       * @description 「A針」選択有効無効
       */
      isDisabledNeedleA: false,

      /**
       * @description 「V針」選択有効無効
       */
      isDisabledNeedleV: false,

      /**
       * @description 「SN針」選択有効無効
       */
      isDisabledNeedleSN: false,

      /**
       * @description 画面の高さ(レスポンシブ対応)
       */
      windowHeight: window.innerHeight,

      /**
       * @description 画面の幅(レスポンシブ対応)
       */
      windowWidth: window.innerWidth,

       /**
       * モニタグラフ設定
       */
      selectedSetting: {
        min: {
          initValue: 0,
          editValue: 0
        },
        max: {
          initValue: 0,
          editValue: 0
        }
      },

      /**
       * 対象薬剤
       */
      dosOrPre: '0',

      /**
       * 薬剤状態
       */
      dosage: [
        {
          "text": "薬剤グループ",
          "value": "0"
        },
        {
          "text": "通常薬剤",
          "value": "1"
        //#10176:ポップアップのフリーワード検索の動作不正 Start  
        },
        {
          "text": "調整薬剤",
          "value": "11"
        }
        //#10176:ポップアップのフリーワード検索の動作不正 End
      ],

      prescription: [
        {
          "text": "薬剤グループ ",
          "value": "2"
        },
        {
          "text": "通常薬剤",
          "value": "3"
        },
        {
          "text": "一般名処方",
          "value": "4"
        },
      ],
      medicationSupportFlag: false,

      tempMax: "",
      tempMin: "",

      investmentSupport: true,
      //add 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
      categoryFlg: false,
      //add 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
      min:-99999.99,
      max:99999.99,
      blurFlg:false,
      focusFlg:[false,false],

    };
  },
  async created() {
    const responseFacility = await sendRequestGetMstFacilityByCd(this.getFacilityCd)
    let advanced = JSON.parse(responseFacility.data.advancedSettings)
    if (advanced !== null) {
      this.medicationSupportFlag = advanced.func_advcds.findIndex(item => item.func_advcd === ADVANCED_SETTINGS.MEDICATION_SUPPORT) >= 0;
    }

  },
  computed: {
    ...mapGetters("user", ["getFacilityCd", "getAdvancedSettings"]),

    medicatioSupport() {
      return this.medicationSupportFlag;
    },
    /**
     * @description 表示方向
     */
    popoverDisplayDirection() {
      if (!this.popoverVisible) return null;

      const elemPosition = this.targetPositionElement.$el
        ? this.targetPositionElement.$el.getBoundingClientRect()
        : this.targetPositionElement.getBoundingClientRect();
      let direction = "right";

      if (this.windowHeight <= 420) {
        // heightが狭い(スマホ横とか)ときは上下じゃ途切れるので右か左に表示
        if (elemPosition.right < this.windowWidth / 2) {
          direction = "right";
        } else {
          direction = "left";
        }
      } else if (this.windowWidth - elemPosition.right < 500) {
        if (elemPosition.top < this.windowHeight / 2) {
          direction = "down";
        } else {
          direction = "up";
        }
      }

      this.setPopoverDirection(direction);

      return "left";
    },

    /**
     * @description 抽出結果
     *              ※ popoverContentDatasetから抽出条件によって絞り込む結果
     */
    popoverFilteredContent() {
      //#10176:ポップアップのフリーワード検索の動作不正 Start
      const Const_popoverSearchDataset = this.popoverSearchDataset ? this.popoverSearchDataset : [];
      const refArr = this.popoverSearchQuery
        ? Const_popoverSearchDataset
        : this.popoverContentDataset;
      //#10176:ポップアップのフリーワード検索の動作不正 End
      let retArr = [];

      if (this.popoverSearchQuery) {
        const q = new RegExp(this.popoverSearchQuery, "gi");

        retArr = refArr.filter(item => {
          return item.text.search(q) > -1;
        });
      } else {
        retArr = refArr.filter(item => {
          // 各フィルタに対して抽出結果を比較
          for (let i = 0; i <= this.popoverFilter.length; i++) {

            if (this.drugStatus !== '投薬支援' && (item.value === "target_investment1" || item.value === "target_investment2")) {
              return false;
            }

            if (this.drugStatus === '投薬支援') {
              if (this.dosOrPre === "0") {
                return item.value === "target_investment1" && item.category === '0';
              } else if (this.dosOrPre === "1") {
                return item.value === "target_investment2" && item.category === '4';
              } else {
                return false;
              }
            }

            // 全フィルタ(且条件)が満たされる
            if (i === this.popoverFilter.length) {
              return true;
            }

            const filterVal = this.popoverFilterSelectedItem[
              this.popoverFilter[i].popoverFilterLabel
            ];
            const searchVal =
              item.fnValue[this.popoverFilter[i].popoverFilterLabel];
            //#10176:ポップアップのフリーワード検索の動作不正 Start
            //通常薬剤/調整薬剤
            if (filterVal === '1' || filterVal === '11') {
                if ( filterVal ==='1' &&  String(item.value).includes(MEDICINE_MIX_TAG))  { 
                  return false;
                }
                if ( filterVal ==='11' &&  !String(item.value).includes(MEDICINE_MIX_TAG))  { 
                  return false;
                }
            }
            //#10176:ポップアップのフリーワード検索の動作不正 End
            // 1件のフィルタ(且条件)に満たされないため、抽出結果に加えない
            if (filterVal === 0) {
              continue;
            //#10176:ポップアップのフリーワード検索の動作不正 Start  
            } else if (filterVal == '11') {
              if (searchVal != '1' ) {
                return false;
              }
            //#10176:ポップアップのフリーワード検索の動作不正 End
            } else if (filterVal !== searchVal) {
              return false;
            }
          }
        });

        this.setPopoverSearchDataset(retArr);
      }

      if (this.hasUnregisteredOption) {
        retArr.unshift({ text: "未登録", value: null });
      }

      return retArr;
    }
  },

  watch: {
    //add 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
    popoverFilter:{
      handler(){
        if (this.popoverFilter[0].popoverFilterLabel === '薬剤区分') {
      this.popoverFilter[1].popoverFilterDataset[0].text = "すべて";
      this.categoryFlg = true;
    }
      },
      deep: true
    },
    //add 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
    dosOrPre:{
      handler(data){
        if (data === '0'){
          this.popoverFilter[0].popoverFilterDataset = this.dosage
          this.popoverFilterSelectedItem.薬剤区分 = "0";
        } else if (data === '1'){
          this.popoverFilter[0].popoverFilterDataset = this.prescription
          this.popoverFilterSelectedItem.薬剤区分 = "2";
        }
        this.clearSearch();
        this.checkNeedleOptionDisplay();
      }
    },
    popoverVisible(visible) {
      if (visible) {
        this.initializeFilterSelected();
      }
    },
    drugStatus: {
      handler(data) {
        if (data !== "投薬支援") {
          this.investmentSupport = true;
          this.popoverFilter[0].popoverFilterDataset[0].text = "薬剤グループ";
          this.popoverFilter[1].popoverFilterDataset[0].text = "薬剤グループ";
        } else {
          this.investmentSupport = false;
          this.popoverFilter[0].popoverFilterDataset[0].text = "すべて";
          this.popoverFilter[1].popoverFilterDataset[0].text = "すべて";
        }
      }
    }
  },

  mounted() {
    window.addEventListener("resize", this.resize);
    //add 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
    this.$nextTick(() => {
      // 患者経過総合ビューアレイアウトmst,按追加→詳細按钮显示typeerror，一直显示处理中 linjunfeng start
      // if (this.popoverFilter[0].popoverFilterLabel === '薬剤区分') {
      if (this.popoverFilter[0]?.popoverFilterLabel === '薬剤区分') {
      // 患者経過総合ビューアレイアウトmst,按追加→詳細按钮显示typeerror，一直显示处理中 linjunfeng end
        this.popoverFilter[1].popoverFilterDataset[0].text = "すべて";
        this.categoryFlg = true;
      }
    })
    //add 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
  },

  methods: {
    // add by shiyw for 6119
    resize(){
      this.windowHeight = window.innerHeight;
      this.windowWidth = window.innerWidth;
    },
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    selectedMedi(value){
      let a = this.popoverContentDataset.find(item => item.value === value);
      let num = this.popoverContentDataset.filter(item => item.isDisp === true).length;
      if (a.isDisp === false && num >= 5) return
      a.isDisp = !a.isDisp;
    },
    beginStatue(value){
      let obj = {
        "selected-color": false,
        "dis-selected-color": false,
      };
      let isSelected = false;
      for (const item of this.popoverContentDataset) {
        if (value == item.value){
          if (item.isDisp){
            isSelected = true;
          }
        }
      }
      obj["selected-color"] = isSelected;
      obj["dis-selected-color"] = !isSelected;
      return obj;
    },
    /**
     * @description ポップオーバー非表示
     */
    closePopover() {
      this.$emit("popover-close", false);
      this.popoverDirection = "";
    },

    /**
     * @description 抽出条件の初期化
     *              ※ 「popoverContentSelected」は指定されている場合、抽出結果に強調して、各抽出条件を指定する
     *              ※ 「popoverContentSelected」は指定されてない場合、各抽出条件を先頭の項目を指定する
     */
    initializeFilterSelected() {
      this.tempMax = this.graphMax;
      this.tempMin = this.graphMin;
      if (!_.isEmpty(this.popoverContentSelected.fnValue)) {
        for (const key in this.popoverContentSelected.fnValue) {
          this.popoverFilterSelectedItem = {
            ...this.popoverFilterSelectedItem,
            [key]: this.popoverContentSelected.fnValue[key]
          };
        }

        this.popoverContentSelectedItem = this.popoverContentSelected.value;
      } else {
        this.popoverFilter.forEach(item => {
          this.popoverFilterSelectedItem = {
            ...this.popoverFilterSelectedItem,
            [item.popoverFilterLabel]: item.popoverFilterDataset[0].value
          };
        });
      }

      this.checkNeedleOptionDisplay();

      if (this.dosOrPre === '0'){
        this.popoverFilter[0].popoverFilterDataset = this.dosage
      } else if (this.dosOrPre === '1'){
        this.popoverFilter[0].popoverFilterDataset = this.prescription
      }
    },

    /**
     * @description フリーワード入力クリア
     */
    clearSearch() {
      this.popoverSearchQuery = "";
      this.popoverSearchDataset = [];
    },

    /**
     * @description 選択項目を呼出元に返す
     */
    saveChanges() {
      let retVal = [];
      for (const item of this.popoverContentDataset) {
        if (item.isDisp === true){
          let temp = item;
          let category = "";
          if (temp.fnValue.薬剤区分 === "0" || temp.fnValue.薬剤区分 === "1"){
            category = {グラフ: "投薬"};
          } else {
            category = {グラフ: "処方"};
          }
          temp = { ...temp, ...{ selector: category } };
          if (this.needleValue) {
            const needle = this.createNeedleValue();
            temp = { ...temp, ...{ needle: parseInt(needle) } };
          }
          temp.max = this.tempMax;
          temp.min = this.tempMin;
          //mod 8065 患者経過総合ビューアの薬剤グラフおよび複合グラフの薬剤がグラフ化されない。 張 start
          // temp.drugStatusS = this.medicatioSupport ? this.drugStatus: null;
          temp.drugStatusS = this.drugStatus;
          //mod 8065 患者経過総合ビューアの薬剤グラフおよび複合グラフの薬剤がグラフ化されない。 張 end
          retVal.push(temp);
        }
      }
      this.$emit("popover-return", retVal);
      this.closePopover();
    },

    /**
     * @description 表示方向設定
     */
    setPopoverDirection(direction) {
      this.popoverDirection = direction;
    },

    /**
     * @description フリーワード用データセット設定
     */
    setPopoverSearchDataset(dataset) {
      this.popoverSearchDataset = dataset;
    },

    /**
     * @description 「穿刺針」選択有無処理
     */
    checkNeedleOptionDisplay() {
      for (const key in this.popoverFilterSelectedItem) {
        const filter = this.popoverFilter.find(item => {
          return item.popoverFilterLabel === key;
        });
        const filterItem = filter.popoverFilterDataset.find(item => {
          return item.value === this.popoverFilterSelectedItem[key];
        });

        if (filterItem.needle) {
          this.isDisplayNeedleOption = true;
          this.isDisabledNeedleA = true;
          this.isDisabledNeedleV = true;
          this.isDisabledNeedleSN = true;

          if (this.needleType) {
            this.needleValue = this.needleType;
            switch (this.needleValue) {
              case 1:
                this.isDisabledNeedleA = false;
                break;
              case 2:
                this.isDisabledNeedleV = false;
                break;
              case 3:
                this.isDisabledNeedleSN = false;
                break;
              default:
                break;
            }
          } else {
            if (filterItem.needle === 3) {
              this.needleValue = 3;
              this.isDisabledNeedleSN = false;
            } else if (filterItem.needle === 2) {
              this.needleValue =
                this.popoverContentSelected.needle &&
                this.popoverContentSelected.needle !== 3
                  ? this.popoverContentSelected.needle
                  : 1;
              this.isDisabledNeedleA = false;
              this.isDisabledNeedleV = false;
            }
          }
          break;
        } else {
          this.isDisplayNeedleOption = false;
          this.needleValue = null;
        }
      }
    },

    /**
     * @description 「穿刺針」の値を計算
     */
    createNeedleValue() {
      if (this.popoverContentSelected.needle) {
        const selectedItem = this.popoverContentDataset.find(item => {
          return item.value === this.popoverContentSelectedItem;
        });
        if (!selectedItem) {
          return null;
        }
        for (const key in this.popoverFilterSelectedItem) {
          const filter = this.popoverFilter.find(item => {
            return item.popoverFilterLabel === key;
          });
          const filterItem = filter.popoverFilterDataset.find(item => {
            return item.value === this.popoverFilterSelectedItem[key];
          });
          if (selectedItem.fnValue[key] !== filterItem.value) {
            return this.popoverContentSelected.needle;
          } else {
            return this.needleValue;
          }
        }
      } else {
        return this.needleValue;
      }
    },

    /**
     * @description 抽出条件の選択項目が変わる時のコールバック
     */
    //mod 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
    // filterChange() {
    filterChange(e, key) {
      this.clearSearch();
      this.checkNeedleOptionDisplay();
      //#10176:ポップアップのフリーワード検索の動作不正 Start
      this.categoryFlg = this.targetdrugchkrescategoryflg(key, e.target.value);
      //#10176:ポップアップのフリーワード検索の動作不正 End
      //mod 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
    },
    inputNumber(e,flag){
        // 数値範囲内かどうかの確認
        if (flag===1) {
          if (this.min !== undefined && this.max !== undefined) {
          if (e.target.value > this.max) {
            this.tempMax = this.min;
            this.blurFlg=true;
          } else if (e.target.value < this.min) {
            this.tempMax = this.max;
            this.blurFlg=true;
          }else{
            this.blurFlg=false;
          }
        }
        }else if(flag===2){
          if (this.min !== undefined && this.max !== undefined) {
          if (e.target.value > this.max) {
            this.tempMin = this.min;
            this.blurFlg=true;
          } else if (e.target.value < this.min) {
            this.tempMin = this.max;
            this.blurFlg=true;
          }else{
            this.blurFlg=false;
          }
        }
        }
    },
    stopScrollFun(e,flag,key){
          if (!this.focusFlg[key]) {
            return;
          }
      let delta = (e.wheelDelta && (e.wheelDelta > 0 ? 1 : -1)) ||
                      (e.detail && (e.wheelDelta > 0 ? -1 : 1))
      if (!e.target.value) {
        e.target.value = 0
      }
      let value = parseFloat(e.target.value);
      const parameterStep = 0.01;
      if (delta > 0) {
        // 滑ります
        value += parameterStep
      } else {
        // 下がります
        value -= parameterStep
      }
      // 数値範囲内かどうかの確認
      if (flag===1) {
        if (value > this.max) {
          value = this.min;
        }
        if(value < this.min) {
          value = this.max;
        }
        this.tempMax = value.toFixed(2);
      }else if (flag===2) {
        if (value > this.max) {
          value = this.min;
        }
        if(value < this.min) {
          value = this.max;
        }
        this.tempMin = value.toFixed(2);
      }
    },
    handleFocus(key){
        this.focusFlg[key]=true;
    },
    handleBlur(event,flag,key) {
           if (flag===1) {
              let value = event.target.value;
             if (value == this.max && this.blurFlg) {
                this.tempMax = this.min;
                this.blurFlg = false;
             }else if (value == this.min && this.blurFlg) {
                this.tempMax = this.max;
                this.blurFlg = false;
             }
           }else if(flag===2){
             let value = event.target.value;
             if (value == this.max && this.blurFlg) {
                this.tempMin = this.min;
                this.blurFlg = false;
             }else if (value == this.min && this.blurFlg) {
                this.tempMin = this.max;
                this.blurFlg = false;
             }
           }
           this.focusFlg[key]=false;
    },
    //#10176:ポップアップのフリーワード検索の動作不正 Start
    /**
    * 薬剤分類活性化判定 戻り値 :true　:false
    * @param key, data
    */
    targetdrugchkrescategoryflg(key, data) {
      if (key === "薬剤区分" && (data === "0" || data === "4"))
        return true;
      else return false; 
    },
    //#10176:ポップアップのフリーワード検索の動作不正 End 
  },
  beforeDestroy() {
         window.removeEventListener("resize", this.resize);
     },
   }
</script>

<style scoped>
.popover-style >>> .popover--top,
.popover-style >>> .popover--right,
.popover-style >>> .popover--left,
.popover-style >>> .popover--bottom {
  width: initial;
}

.popover-header-style {
  margin: 0px;
}

.select-filter-style,
.search-style {
  width: 100%;
}

.select-content-style {
  width: 100%;
  height: 100%;
  background-color: var(--ntss-list-background-color);
  color: var(--ntss-list-body-color);
}

.label-style {
  font-size: 15px;
}

.button-cancel {
  float: left;
}

.button-confirm {
  float: right;
}

.popover-footer-style {
  margin-top: 15px;
}

.select-has-size {
  font-size: 13.3333px;
}

/* スマホ対応 */
@media screen and (max-width: 420px) {
  .popover-style >>> .popover__content {
    width: auto;
    padding: 10px;
  }

  .label-style {
    font-size: 12px;
  }

  .popover-header-style {
    font-size: 18px;
  }
}

@media screen and (max-height: 420px) {
  .popover-style >>> .popover__content {
    width: 350px;
    padding: 5px;
  }

  .label-style {
    font-size: 12px;
  }

  .popover-header-style {
    font-size: 18px;
  }
}

ons-select, ons-input {
  font-size: 13.3333px;
}
.selected-color {
  background-color: #1E90FF;
  color: white;
  width: max-content;
  min-width: 100%;
}
.dis-selected-color:hover {
  background-color: #dddddd;
}

.dis-selected-color{
  white-space: nowrap;
}

.mult-selector {
  overflow-y: auto;
  max-height: 300px;
  min-height: 100px;
  border: solid 1px #bbbbbb;
}
</style>
