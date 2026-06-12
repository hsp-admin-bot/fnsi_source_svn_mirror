/** * マスタ選択 */

<template>
  <v-ons-popover
    v-if="popoverVisible"
    :target="resolvedTargetPositionElement"
    :visible="popoverVisible"
    :direction="popoverDisplayDirection"
    :class="[fontSizeSet, 'popover-style']"
    cancelable
    @preshow="popoverPreShow"
    @postshow="popoverPostShow"
    @posthide="closePopover(); popoverPosthide()"
  >
    <div>
      <v-ons-row>
        <h2 class="popover-header-style">{{ popoverTitleHeader }}</h2>
      </v-ons-row>
      <hr />
      <v-ons-row
        v-for="filter in popoverFilter"
        :key="filter.popoverFilterLabel"
        class="div-style"
      >
        <v-ons-col width="30%">
          <label class="label-style">{{ filter.popoverFilterLabel }}</label>
        </v-ons-col>
        <v-ons-col>
          <v-ons-select
            v-model="popoverFilterSelectedItem[filter.popoverFilterLabel]"
            :disabled="popoverFilterDisabled || checkMachineSupport(filter.popoverFilterLabel)"
            class="select-filter-style"
            @change="filterChange"
          >
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
        <v-ons-col width="30%">
          <label class="label-style">フリーワード</label>
        </v-ons-col>
        <v-ons-col>
          <input
            v-model="popoverSearchQuery"
            class="search-style"
            type="search"
            placeholder="検索"
          />
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="div-style">
        <v-ons-col width="30%">
          <label class="label-style">{{ popoverContentLabel }}</label>
        </v-ons-col>
        <v-ons-col width="70%"><!-- mod #10223 禁忌・アレルギーマスタの詳細>追加popoverに不正な文字が混入している 宮崎 -->
          <!-- <select
            v-model="popoverContentSelectedItem"
            class="select-content-style select-has-size select-font-inherit"
            size="10"
            @dblclick="saveChanges"
            @onmousedown="onMouseDown"
            @click="onClick"
            multiple="multiple"
          >
            <option
              v-for="content in popoverFilteredContent"
              :key="content.id"
              :value="content.value"
            >
              {{ content.text }}
            </option>
          </select> -->
          <div class="mult-selector">
            <div
                v-for="(selectedInfo, index) in popoverFilteredContent"
                :key="index"
                :class="setListClass(selectedInfo.value)"
                class="select-label-style select-font-inherit"
                @click="storageInfo(selectedInfo)"
              >
                <span class="graphF select-has-size">{{ selectedInfo.text }}</span>
              </div>
          </div>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row v-if="isDisplayNeedleOption" class="needle-hidden">
        <v-ons-col width="30%" />
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
            class="btn2-cancel common-style-cancel-button button-cancel"
            @click="closePopover"
          >
            キャンセル
          </v-ons-button>
        </v-ons-col>
        <v-ons-col>
          <v-ons-button
            class="btn1-execute common-style-ok-button button-confirm"
            @click="saveChanges"
            :disabled="this.popoverContentSelectedItem === undefined"
          >
            OK
          </v-ons-button>
        </v-ons-col>
      </v-ons-row>
    </div>
  </v-ons-popover>
</template>

<script>
import PopoverMixin from "@/components/PopoverMixin";
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
import { getViewportHeight, getViewportWidth } from "@/functions/common/LayoutMeasureHelper";
import { resolveOnsPopoverTargetElement } from "@/functions/common/OnsenFunctions";

export default {
  mixins: [PopoverMixin],

  props: {
    /* add 投薬支援マスタ 薬効換算の場合,薬剤分類なし 孔 start */
    /**
     * @description 投薬支援マスタ
     */
    mstMachineSupportFlg: {
      type: Boolean,
      default: false
    },
    /* add 投薬支援マスタ 薬効換算の場合,薬剤分類なし 孔 end */

    /* add 最大選択数を増やす 孔 start */
    /**
     * 最大選択数
     * @summary null設定時は、制限なし
     */
    maxSelectedItems: {
      type: Number,
      default: null
    },
    /* add 最大選択数を増やす 孔 start */

    /* add スタッフ追加の複数追加と空欄追加 楊 start */
    popoverBlankLine: {
      type: Boolean,
      default: false
    },
    /* add スタッフ追加の複数追加と空欄追加 楊 end */
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

    /**
     * @description 抽出結果のラベル
     */
    popoverContentLabel: {
      type: String,
      default: ""
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
          value: [],
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
      default: null
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
    }
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
      windowHeight: getViewportHeight(),

      /**
       * @description 画面の幅(レスポンシブ対応)
       */
      windowWidth: getViewportWidth()
    };
  },

  computed: {
    resolvedTargetPositionElement() {
      return resolveOnsPopoverTargetElement(this.targetPositionElement, this);
    },
    resolvedTargetRectElement() {
      return this.resolvedTargetPositionElement;
    },
    /**
     * @description 表示方向
     */
    popoverDisplayDirection() {
      if (!this.popoverVisible) return null;

      const targetElement = this.resolvedTargetRectElement;
      if (!targetElement?.getBoundingClientRect) return null;
      const elemPosition = targetElement.getBoundingClientRect();
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

      return direction;
    },

    /**
     * @description 抽出結果
     *              ※ popoverContentDatasetから抽出条件によって絞り込む結果
     */
    popoverFilteredContent() {
      // mod redmine 6286 一般名処方マスタからの薬剤追加ができなくなる 宋qy start
      //const refArr = this.popoverContentDataset;
      // mod redmine 6286 一般名処方マスタからの薬剤追加ができなくなる 宋qy end
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
            // 全フィルタ(且条件)が満たされる
            if (i === this.popoverFilter.length) {
              return true;
            }

            const filterVal = this.popoverFilterSelectedItem[
              this.popoverFilter[i].popoverFilterLabel
            ];
            const searchVal =
              item.fnValue[this.popoverFilter[i].popoverFilterLabel];

            // 選択値が配列の場合、含有判定
            if (Array.isArray(filterVal)){
              if (filterVal.indexOf(searchVal) >= 0){
                continue;
              } else {
                return false;
              }
            }

            // 1件のフィルタ(且条件)に満たされないため、抽出結果に加えない
            if (filterVal === 0) {
              continue;
            } else if (filterVal !== searchVal) {
              return false;
            }
          }
        });

        this.setPopoverSearchDataset(retArr);
      }
      /* mod スタッフ追加の複数追加と空欄追加 楊 start */
      if (this.hasUnregisteredOption && this.popoverBlankLine) {
        retArr.unshift({text: "", value: null});
      } else if (this.hasUnregisteredOption) {
        retArr.unshift({text: "未登録", value: null});
      }
      /* mod スタッフ追加の複数追加と空欄追加 楊 end */

      return retArr;
    }
  },

  watch: {
    popoverVisible(visible) {
      if (visible) {
        this.initializeFilterSelected();
      }
    }
  },

  mounted() {
    (this.$el?.ownerDocument?.defaultView || window).addEventListener("resize", this.onResize);
  },

  beforeUnmount() {
    // 画面を閉じたときにイベントを除去
    (this.$el?.ownerDocument?.defaultView || window).removeEventListener("resize", this.onResize);
  },

  methods: {
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    /* add 投薬支援マスタ 薬効換算の場合,薬剤分類なし 孔 start */
    /**
     * @description 投薬支援マスタ 薬効換算の場合,薬剤分類なし
     */
    isMachineSupportMedicineClassDisabled() {
      return this.mstMachineSupportFlg &&
        this.popoverFilterSelectedItem["薬剤区分"] === 3;
    },
    normalizeMachineSupportFilter() {
      if (this.isMachineSupportMedicineClassDisabled() &&
        this.popoverFilterSelectedItem["薬剤分類"] !== 0) {
        this.popoverFilterSelectedItem = {
          ...this.popoverFilterSelectedItem,
          "薬剤分類": 0
        };
      }
    },
    checkMachineSupport(filter) {
      return filter === "薬剤分類" && this.isMachineSupportMedicineClassDisabled();
    },
    /* add 投薬支援マスタ 薬効換算の場合,薬剤分類なし 孔 end */

    /**
     * 選択情報を格納
     */
    storageInfo(info) {
      const selectedList = this.popoverContentSelectedItem ? this.popoverContentSelectedItem : this.popoverContentSelectedItem=[];
      const index= selectedList.indexOf(info.value)
      // 格納先にない場合
      if (index == -1) {
        /* add 最大選択数を増やす 孔 start */
        if (this.maxSelectedItems && selectedList.length >= this.maxSelectedItems) return
        /* add 最大選択数を増やす 孔 start */
        // 選択情報を格納
        // 格納されている選択情報(左+右)が5つ以下の場合小項目情報を格納
        selectedList.push(info.value);
      } else {
        // すでに格納されている選択情報ある場合削除
        selectedList.splice(index, 1);
      }
    },
    setListClass(cd) {
      const selectedList = this.popoverContentSelectedItem ? this.popoverContentSelectedItem : [];
      const obj = {
        "selected-color": false,
        "dis-selected-color": false,
      };
      // 選択状態フラグを格納
      let isSelected = false;
      // 格納された選択肢情報をループ
      selectedList.forEach((ele) => {
        // 格納された選択状態リストと対象のコードが一致した場合true
        isSelected = ele === cd ? true : isSelected;
      });
      // 選択中クラスを付与
      obj["selected-color"] = isSelected;
      // 未選択中クラスを付与
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
      this.popoverContentSelectedItem = this.popoverContentSelected.value;
      this.popoverFilter.forEach(item => {
        this.popoverFilterSelectedItem = {
          ...this.popoverFilterSelectedItem,
          [item.popoverFilterLabel]: item.popoverFilterDataset[0].value
        };
      });

      this.normalizeMachineSupportFilter();
      this.checkNeedleOptionDisplay();
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
      if(!this.popoverContentSelectedItem || this.popoverContentSelectedItem === null){
        this.popoverContentSelectedItem={ text: "", value: null }
      }else{
        let temp = []
        this.popoverContentSelectedItem.forEach(
          item=>{
            /* add スタッフ追加の複数追加と空欄追加 楊 start */
            if(item === null && this.popoverBlankLine){
              temp.push({
                text: "",
                value: null
              })
              return;
            }
            /* add スタッフ追加の複数追加と空欄追加 楊 end */
              temp.push(
                this.popoverContentDataset.find(item2 => {
                return item2.value === item}))
          })
        this.popoverContentSelectedItem=temp
      }
      let retVal = this.popoverContentSelectedItem;

      if (this.needleValue) {
        const needle = this.createNeedleValue();
        retVal = { ...retVal, ...{ needle: parseInt(needle) } };
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
    filterChange() {
      this.clearSearch();
      this.normalizeMachineSupportFilter();
      this.checkNeedleOptionDisplay();
    },

    onResize() {
      this.windowHeight = getViewportHeight();
      this.windowWidth = getViewportWidth();
    }
  }
};
</script>

<style scoped>
.popover-style :deep(.popover--top),
.popover-style :deep(.popover--right),
.popover-style :deep(.popover--left),
.popover-style :deep(.popover--bottom) {
  width: initial;
}

.popover-style :deep(.popover__content) {
  width: 500px;
  height: 100%;
  padding: 25px;
  border: solid 1px var(--preventive-checked-border-color);
  margin: 3px;
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

.button-cancel {
  float: left;
}

.button-confirm {
  float: right;
}

.popover-footer-style {
  margin-top: 15px;
}

.needle-hidden {
  visibility: hidden;
  height: 0px;
}

.select-has-size {
  font-size: 13.3333px;
}

/* スマホ対応 */
@media screen and (max-width: 420px) {
  .popover-style :deep(.popover__content) {
    width: auto;
    padding: 10px;
  }
}

@media screen and (max-height: 420px) {
  .popover-style :deep(.popover__content) {
    width: 350px;
    padding: 5px;
  }
}
.select-label-style {
  padding: 0px 2px 1px;
  white-space: nowrap;
  box-sizing: border-box;
}
.graphF {
  /* width: 100px; */
  display: -moz-inline-box;
  display: inline-block;
}
.selected-color {
  background-color: #0076ff !important;
  color: white;
  width: max-content;
  min-width: 100%;
}
.dis-selected-color:hover {
  background-color: #dddddd;
}
.mult-selector {
  background-color: #F7F7F7;
  color: #1f1f21;
  overflow-y: auto;
  max-height: 300px;
  min-height: 300px;
  border: solid 1px #bbbbbb;
}
/* スマホ対応 */
@media screen and (max-height: 740px) {
  .mult-selector {
    max-height: 8em;
    min-height: 8em;
  }
}
</style>
