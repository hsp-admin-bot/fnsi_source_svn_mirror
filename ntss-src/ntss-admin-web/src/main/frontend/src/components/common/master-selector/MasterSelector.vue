/** * マスタ選択 */

<template>
  <v-ons-popover
    v-if="popoverVisible"
    :target="targetPositionElement"
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
            v-model="inputSearchQuery"
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
        <v-ons-col>
          <v-ons-select
            v-model="popoverContentSelectedItem"
            class="select-content-style select-has-size select-font-inherit"
            size="10"
            @dblclick="saveChanges"
          >
            <option
              v-for="content in popoverFilteredContent"
              :key="content.id"
              :value="content.value"
              :class="setListClassOne(content)"
            >
              {{ content.text }}
            </option>
          </v-ons-select>
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
            class="btn2-cancel common-style-cancel-button button-cancel btn2-cancel"
            @click="closePopover"
          >
            キャンセル
          </v-ons-button>
        </v-ons-col>
        <v-ons-col>
          <!--#11872 add 利用者指定IFのデフォルト選択状態 v-if-else isUsedUserInfoID==true  disabled==false -->
          <v-ons-button
            v-if="isUsedUserInfoID"
            class="btn1-execute common-style-ok-button button-confirm btn3-normal"
            @click="saveChanges"
          >
           {{ exeLableName }}
          </v-ons-button>
          <v-ons-button
            v-else
            class="btn1-execute common-style-ok-button button-confirm btn3-normal"
            @click="saveChanges"
            :disabled="this.popoverContentSelectedItem === undefined || isChanged"
          >
            {{ exeLableName }}
          </v-ons-button>
        </v-ons-col>
      </v-ons-row>
    </div>
  </v-ons-popover>
</template>

<script>
import PopoverMixin from "@/components/PopoverMixin";
import {mapGetters} from "vuex"; // add 鞠 マスタを取得するために
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
import { EventBus } from "@/eventBus.js";

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

    /**
     * @description 条件送信画面判定フラグ
     */
    fromSendConditionFlg: {
      type: Boolean,
      default: false
    },

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

    // add FNSI-改修内容 保険マスタから選択する機能の改修 趙 start
    /**
     * @description フリーワード
     */
    popoverSearchQuery: {
      type: String,
      default: ""
    },
    // add FNSI-改修内容 保険マスタから選択する機能の改修 趙 end

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

    exeLableName: {
      type: String,
      default: "OK"
    },
    // #8710 画面をリサイズすると、ポップアップ画面の表示が不正。 林峻峰 start
    treatItemCd: {
      type: String,
      default: null
    },
    // #8710 画面をリサイズすると、ポップアップ画面の表示が不正。 林峻峰 end

    //#11872 liyanze-z add ログインID ? start
    isUsedUserInfoID: {
      type: Boolean,
      default: false
    },
    //liyanze-z add  end
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

      // del FNSI-改修内容 保険マスタから選択する機能の改修 趙 start
      /**
       * @description フリーワード入力値
       */
      // add start 馬 #10097
      inputSearchQuery: this.popoverSearchQuery,
      // add end 馬 #10097
      // del FNSI-改修内容 保険マスタから選択する機能の改修 趙 end

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

      isChanged: false ,// add #6512 患者情報画面の分の修正 劉
      // 内部 患者情報:保険の場合、選択ボタンをクリックした後、ポップアップページを開きます。start
      initName: null
      // 内部 患者情報:保険の場合、選択ボタンをクリックした後、ポップアップページを開きます。end
    };
  },

  computed: {
    /**
     * add 鞠 マスタを取得するために
     */
    ...mapGetters("master-maintenance", {
      masterPhysicalName: "getMasterName",
    }),

    /**
     * @description 表示方向
     */
    popoverDisplayDirection() {
      if (!this.popoverVisible) return null;
      // #8710 画面をリサイズすると、ポップアップ画面の表示が不正。 林峻峰 start
      const rightHeader = ['2', '5', '6', '7', '8', '9', '10', '13', '15', '19', '25'];
      if (rightHeader.includes(this.treatItemCd)) {
        return 'right';
      }
      // #8710 画面をリサイズすると、ポップアップ画面の表示が不正。 林峻峰 end
      const elemPosition = this.targetPositionElement.$el
        ? this.targetPositionElement.$el.getBoundingClientRect()
        : this.targetPositionElement.getBoundingClientRect();
      let direction = "right";
      let defaultHeight =  420;
      if(this.masterPhysicalName == "mst_treatment_set" ) {
        defaultHeight = 700;
      }
      if (this.windowHeight <= defaultHeight) {
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
      // modify start 馬 #10097
      //#10176:ポップアップのフリーワード検索の動作不正 Start
      const Const_popoverSearchDataset = this.popoverSearchDataset ? this.popoverSearchDataset : [];
      const refArr = this.inputSearchQuery
        ? Const_popoverSearchDataset
        : this.popoverContentDataset;
       //#10176:ポップアップのフリーワード検索の動作不正 End
      let retArr = [];
      if (this.inputSearchQuery) {
        const q = new RegExp(this.inputSearchQuery, "gi");

        retArr = refArr.filter(item => {
          return item.text.search(q) > -1;
        });
      } else {
        if (this.popoverTitleHeader === '診断医') {
          const label = this.popoverFilter[0].popoverFilterLabel;
          if (this.popoverFilterSelectedItem[label]) {
            retArr = refArr.filter((item) => {
              return item.jobCd === this.popoverFilterSelectedItem[label];
            })
          } else {
            retArr = refArr;
          }
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
              /* modify by chamaojia 2024-07-12 [10266] filterVal !== searchVal -> filterVal != searchVal --start */
              if (filterVal === 0 || filterVal === 'all') {
                continue;
              } else if (filterVal != searchVal) {
                return false;
              }
              /* modify by chamaojia 2024-07-12 [10266] filterVal !== searchVal -> filterVal != searchVal --end */
            }
          });
        }
        this.setPopoverSearchDataset(retArr);
      }
      /* mod スタッフ追加の複数追加と空欄追加 楊 start */
      if (this.hasUnregisteredOption && this.popoverBlankLine) {
        retArr.unshift({text: "", value: null});
      } else if (this.hasUnregisteredOption && (retArr?.[0]?.value || retArr?.length === 0)) {
        retArr.unshift({text: "未登録", value: null});
      }
      /* mod スタッフ追加の複数追加と空欄追加 楊 end */
      return retArr;
      // modify end 馬 #10097
    },
    // add #6512 患者情報画面の分の修正 劉 start
    isPatInfoFlg() {
      if (this.popoverTitleHeader === "国籍"
        || this.popoverTitleHeader === "保険選択"
        || this.popoverTitleHeader === "患者"
        || this.popoverTitleHeader === "続柄"
        || this.popoverTitleHeader === "診療科"
        || this.popoverTitleHeader === "透析実施科"
        || this.popoverTitleHeader === "病棟"
        || this.popoverTitleHeader === "重症度"
        || this.popoverTitleHeader === "搬送"
        || this.popoverTitleHeader === "担当者"
        || this.popoverTitleHeader === "禁忌・アレルギー"
        || this.popoverTitleHeader === "インプラント"
        || this.popoverTitleHeader === "担当医"
        || this.popoverTitleHeader === "診断医"
        || this.popoverTitleHeader === "病名"
        || this.popoverTitleHeader === "スタッフ"
        || this.popoverTitleHeader === "車いす"
      ) {
        return true
      } else {
        return false
      }
    }
    // add #6512 患者情報画面の分の修正 劉 end
  },

  watch: {
    popoverVisible(visible) {
      if (visible) {
        this.initializeFilterSelected();
      }
    },
    // add #6512 患者情報画面の分の修正 劉 start
    popoverContentSelectedItem: {
      handler(value) {
        if (this.isPatInfoFlg) {
          this.isChanged = value === this.popoverContentSelected.value? true : false
        }
      },
      immediate: true
    }
    // add #6512 患者情報画面の分の修正 劉 end
  },

  mounted() {
    // 内部 患者情報:保険の場合、選択ボタンをクリックした後、ポップアップページを開きます。start
    EventBus.$on("getInsuranceInfo", data => {
      this.initName = data.editValue
    })
    // 内部 患者情報:保険の場合、選択ボタンをクリックした後、ポップアップページを開きます。end
    window.addEventListener("resize",this.resizeEventListener);
  },
  methods: {
    // modify by 史 for 6119 ブラウザがOut of Memoryのエラーが発生する
    resizeEventListener(){
      this.windowHeight = window.innerHeight;
      this.windowWidth = window.innerWidth;
    },
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    // add 投薬支援マスタ 薬剤名css 鞠
    // 内部 患者情報:保険の場合、選択ボタンをクリックした後、ポップアップページを開きます。start
    setListClassOne(content) {
      const cd = content.value;
      const cdName = content.text;
      // 内部 患者情報:保険の場合、選択ボタンをクリックした後、ポップアップページを開きます。end
      const selectedList = this.popoverContentSelectedItem ? this.popoverContentSelectedItem : [];
      const obj = {
        "selected-color": false,
        "dis-selected-color": false,
        "turn-red": false,
      };
      // 選択状態フラグを格納
      let isSelected = false;
      isSelected = selectedList === cd ? true : isSelected;
      // 内部 患者情報:保険の場合、選択ボタンをクリックした後、ポップアップページを開きます。start
      if (selectedList.length === 0) {
        isSelected = this.initName === cdName ? true : isSelected;
      }
      // 内部 患者情報:保険の場合、選択ボタンをクリックした後、ポップアップページを開きます。end
      // // 選択中クラスを付与
      obj["selected-color"] = isSelected;
      // 未選択中クラスを付与
      obj["dis-selected-color"] = !isSelected;

      /**
       * 条件送信画面から来ていた場合 かつ 校正切れチェックカラムが設定されている場合
       * 校正切れチェック結果に応じて文字色設定
       */
      if (this.fromSendConditionFlg && content.calibrationCheck != undefined) {
        obj["turn-red"] = !content.calibrationCheck;
      }
      return obj;
    },
    //add end

    /* add 投薬支援マスタ 薬効換算の場合,薬剤分類なし 孔 start */
    /**
     * @description 投薬支援マスタ 薬効換算の場合,薬剤分類なし
     */
    checkMachineSupport(filter) {
      if (this.mstMachineSupportFlg &&
        filter === "薬剤分類" &&
        this.popoverFilterSelectedItem["薬剤区分"] === 3
      ) {
        this.popoverFilterSelectedItem["薬剤分類"] = 0
        return true
      } else {
        return false
      }
    },
    /* add 投薬支援マスタ 薬効換算の場合,薬剤分類なし 孔 end */

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
      // add #6512 患者情報画面の分の修正 劉 start
      if (this.isPatInfoFlg) {
        this.isChanged = true
      }else {
        this.isChanged = false
      }
      // add #6512 患者情報画面の分の修正 劉 end
      // 投薬支援マスタ 薬剤分類と薬剤名の連動 add start 鞠
      if("mst_medicine_support" === this.masterPhysicalName && this.popoverFilter.length != 0){
        let classCd = 0;
        const selectedItem = this.popoverContentDataset.find(item => item.value === this.popoverContentSelectedItem);
        if (!(selectedItem === undefined || selectedItem.fnValue.薬剤分類 === -1 || selectedItem.fnValue.薬剤分類 === undefined)) {
          classCd= selectedItem.fnValue.薬剤分類;
        }

        //#10176:ポップアップのフリーワード検索の動作不正(関連修正) Start
        let filterItem = this.popoverFilter.find(item =>item.popoverFilterLabel === "薬剤分類");
        if (filterItem != undefined && filterItem != null ) {    
            filterItem = filterItem.popoverFilterDataset.find(item => item.value === classCd);
            this.popoverFilter.forEach(item => {
              this.popoverFilterSelectedItem = {
                ...this.popoverFilterSelectedItem,
                [item.popoverFilterLabel]: item.popoverFilterLabel === "薬剤分類"?filterItem.value:item.popoverFilterDataset[0].value
              };
            });
        } else {
          this.popoverFilter.forEach(item => {
            this.popoverFilterSelectedItem = {
              ...this.popoverFilterSelectedItem,
              [item.popoverFilterLabel]: item.popoverFilterDataset[0].value
            };
          });
        }
        //#10176:ポップアップのフリーワード検索の動作不正(関連修正) End
        // 投薬支援マスタ 薬剤分類と薬剤名の連動 add end 鞠
      }else{
        this.popoverFilter.forEach(item => {
          this.popoverFilterSelectedItem = {
            ...this.popoverFilterSelectedItem,
            [item.popoverFilterLabel]: item.popoverFilterDataset[0].value
          };
        });
      }

      this.checkNeedleOptionDisplay();
    },

    /**
     * @description フリーワード入力クリア
     */
    clearSearch() {
      this.inputSearchQuery = "";
      this.popoverSearchDataset = [];
    },

    /**
     * @description 選択項目を呼出元に返す
     */
    saveChanges() {
      let retVal =
        this.popoverContentSelectedItem === null
          ? { text: "", value: null }
          : this.popoverContentDataset.find(item => {
              return item.value === this.popoverContentSelectedItem;
            });

      if (this.needleValue) {
        const needle = this.createNeedleValue();
        retVal = { ...retVal, ...{ needle: parseInt(needle) } };
      }

      this.$emit("popover-return", retVal);
      // #10266 投与薬剤編集モーダル選択ボタンを押下しOK押下　NGエラー発生 linjunfeng start
      // this.popoverContentSelectedItem = retVal.value
      this.popoverContentSelectedItem = retVal?.value || null
      // #10266 投与薬剤編集モーダル選択ボタンを押下しOK押下　NGエラー発生 linjunfeng end
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
      this.checkNeedleOptionDisplay();
    }
  },
  beforeDestroy() {
    // 内部 患者情報:保険の場合、選択ボタンをクリックした後、ポップアップページを開きます。start
    EventBus.$off('getInsuranceInfo');
    // 内部 患者情報:保険の場合、選択ボタンをクリックした後、ポップアップページを開きます。end
    window.removeEventListener("resize", this.resizeEventListener);
  }
};
</script>

<style scoped>
.popover-style >>> .popover--top,
.popover-style >>> .popover--right,
.popover-style >>> .popover--left,
.popover-style >>> .popover--bottom {
  width: initial;
}

.popover-style >>> .popover__content {
  width: 500px;
  height: auto;
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
  .popover-style >>> .popover__content {
    width: auto;
    padding: 10px;
  }
}

@media screen and (max-height: 420px) {
  .popover-style >>> .popover__content {
    width: 350px;
    padding: 5px;
  }
}
/* add start 鞠*/
.selected-color {
  background-color: #0076ff !important;
  color: white;
  width: max-content;
  min-width: 100%;
}
.dis-selected-color:hover {
  background-color: #dddddd;
}
/* add end 鞠*/
.turn-red {
  color: #FF6666 !important;
}
</style>
