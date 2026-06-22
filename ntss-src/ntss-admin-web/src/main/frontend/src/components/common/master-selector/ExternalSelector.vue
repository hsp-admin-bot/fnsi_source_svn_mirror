/** * 連携稼働ビューア コマンド実行 */
<template>
  <v-ons-popover
    :target="resolvedTargetPositionElement"
    :visible="popoverVisible"
    :direction="popoverDisplayDirection"
    :class="[fontSizeSet, 'popover-style']"
    cancelable
    @preshow="popoverPreShow"
    @postshow="popoverPostShow"
    @posthide="
      closePopover();
      popoverPosthide();
    "
  >
    <div>
      <v-ons-row>
        <h2 class="popover-header-style">{{ popoverTitleHeader }}</h2>
      </v-ons-row>
      <hr />
      <v-ons-row class="condition-row">
        <v-ons-col width="25%" vertical-align="center" class="pop-title">
          <label style="white-space: nowrap">施設選択</label>
        </v-ons-col>
        <v-ons-col vertical-align="center" class="external-selector-facility-ms">
          <kendo-multiselect
            class="external-selector-facility-multiselect"
            style="min-width: 17em"
            v-model="searchCondition.facilityCd"
            :data-source="facilityInfo"
            data-text-field="facilityName"
            data-value-field="facilityCd"
          />
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="div-style">
        <v-ons-col>
          <div class="exam-set-list-frame">
            <table class="list-wrapper">
              <thead>
                <tr>
                  <th class="list-header-th">処理詳細</th>
                  <th class="list-header-th">実行</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="set in getEdgeCommand.listEdgeCommand" :key="set.commandKey">
                  <td class="detail-cell">{{ set.processing }} : {{ set.processing_detail }}</td>
                  <td class="action-cell">
                    <v-ons-button class="btn3-normal" @click="addImplement(set.commandKey)">実行</v-ons-button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col>
          <v-ons-button
          v-if="isAdmin&&isNkkStaff&&isMasterUser"
          class="button-clear button"
          @click="clearStatus"
          >処理中停止の初期化
          </v-ons-button>
        </v-ons-col>
        <v-ons-col>
          <v-ons-button
            class="
              btn2-cancel
              common-style-cancel-button
              button-cancel
              btn2-cancel
            "
            @click="closePopover"
          >
            閉じる
          </v-ons-button>
        </v-ons-col>
      </v-ons-row>
    </div>
    <!--add 8482 リモートコマンド実行後のローダーを表示 ljx start-->
    <v-ons-modal v-if="isVisible" :visible="isVisible">
      <p class="loading-modal">
        処理中...
        <v-ons-icon icon="fa-spinner" spin />
      </p>
    </v-ons-modal>
    <!--add 8482 リモートコマンド実行後のローダーを表示 ljx end-->
  </v-ons-popover>
</template>

<script>
import PopoverMixin from "@/components/PopoverMixin";
import { ApiHelper } from "@/apis/AxiosHelper.js";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";

// add #6107 2023/03/08 メッセージボックス全調整 林峻峰 start
import { getViewportHeight, getViewportWidth } from "@/functions/common/LayoutMeasureHelper";
import { resolveOnsPopoverTargetElement } from "@/functions/common/OnsenFunctions";
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";

// add #6107 2023/03/08 メッセージボックス全調整 林峻峰 end
const uriFunctionFacility = "/mstInfo/mstFacility";

export default {
  mixins: [PopoverMixin],

  props: {
    /* add 投薬支援マスタ 薬効換算の場合,薬剤分類なし 孔 start */
    /**
     * @description 投薬支援マスタ
     */
    mstMachineSupportFlg: {
      type: Boolean,
      default: false,
    },
    /* add 投薬支援マスタ 薬効換算の場合,薬剤分類なし 孔 end */

    /* add スタッフ追加の複数追加と空欄追加 楊 start */
    popoverBlankLine: {
      type: Boolean,
      default: false,
    },
    /* add スタッフ追加の複数追加と空欄追加 楊 end */
    /**
     * @description ポップオーバー表示非表示
     */
    popoverVisible: {
      type: Boolean,
      default: false,
    },

    /**
     * @description ポップオーバーヘッダーテキスト
     */
    popoverTitleHeader: {
      type: String,
      default: "",
    },

    // add FNSI-改修内容 保険マスタから選択する機能の改修 趙 start
    /**
     * @description フリーワード
     */
    popoverSearchQuery: {
      type: String,
      default: "",
    },
    // add FNSI-改修内容 保険マスタから選択する機能の改修 趙 end

    /**
     * @description 抽出条件
     *              ※ 何も渡さないと抽出条件の入力フィルドが表示されない
     *              ※ 配列の中身: { popoverFilterLabel: '', popoverFilterDataset: [] }
     */
    popoverFilter: {
      type: Array,
      default: () => [],
    },

    /**
     * @description 抽出条件の選択有効無効
     */
    popoverFilterDisabled: {
      type: Boolean,
      default: false,
    },

    /**
     * @description 抽出結果のラベル
     */
    popoverContentLabel: {
      type: String,
      default: "",
    },

    /**
     * @description 抽出する選択肢
     *              ※ 抽出結果は計算プロパティ「popoverFilteredContent」に定義されている
     */
    popoverContentDataset: {
      type: Array,
      default: () => [],
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
          text: "",
        };
      },
    },

    /**
     * @description ポップオーバーの呼び出し元(DOMオブジェクト)
     */
    targetPositionElement: {
      type: [Object, HTMLElement],
      default: null,
    },

    /**
     * @description 「未登録」選択の有無
     */
    hasUnregisteredOption: {
      type: Boolean,
      default: true,
    },

    /**
     * @description 「穿刺針」選択区分(固定定義の場合)
     */
    needleType: {
      type: Number,
      default: null,
    },

    exeLableName: {
      type: String,
      default: "OK",
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

      // del FNSI-改修内容 保険マスタから選択する機能の改修 趙 start
      /**
       * @description フリーワード入力値
       */
      // popoverSearchQuery: "",
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
      windowHeight: getViewportHeight(),

      /**
       * @description 画面の幅(レスポンシブ対応)
       */
      windowWidth: getViewportWidth(),

      isChanged: false, // add #6512 患者情報画面の分の修正 劉
      // 施設
      facilityInfo: [],
      searchCondition: {
        facilityCd: [],
      },
      // add 8482 リモートコマンド実行後のローダーを表示 ljx start
      isLoadingVisible:false,
      // add 8482 リモートコマンド実行後のローダーを表示 ljx end
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
     * add 鞠 マスタを取得するために
     */
    ...mapGetters("master-maintenance", {
      masterPhysicalName: "getMasterName",
    }),
    ...mapGetters("external-coop", ["getEdgeCommand", "getToFacilityCd"]),
    /**
     * @description 表示方向
     */
    popoverDisplayDirection() {
      if (!this.popoverVisible) return null;

      const targetElement = this.resolvedTargetRectElement;
      if (!targetElement?.getBoundingClientRect) return null;
      const elemPosition = targetElement.getBoundingClientRect();
      let direction = "right";
      let defaultHeight = 420;
      if (this.masterPhysicalName == "mst_treatment_set") {
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
    // add 8482 リモートコマンド実行後のローダーを表示 ljx start
    isVisible() {
      return this.isLoadingVisible;
    },
    // add 8482 リモートコマンド実行後のローダーを表示 ljx end
    /**
     * @description 抽出結果
     *              ※ popoverContentDatasetから抽出条件によって絞り込む結果
     */
    popoverFilteredContent() {
      const refArr = this.popoverSearchQuery
        ? this.popoverSearchDataset
        : this.popoverContentDataset;
      let retArr = [];

      if (this.popoverSearchQuery) {
        const q = new RegExp(this.popoverSearchQuery, "gi");

        retArr = refArr.filter((item) => {
          return item.text.search(q) > -1;
        });
      } else {
        retArr = refArr.filter((item) => {
          // 各フィルタに対して抽出結果を比較
          for (let i = 0; i <= this.popoverFilter.length; i++) {
            // 全フィルタ(且条件)が満たされる
            if (i === this.popoverFilter.length) {
              return true;
            }

            const filterVal =
              this.popoverFilterSelectedItem[
                this.popoverFilter[i].popoverFilterLabel
              ];
            const searchVal =
              item.fnValue[this.popoverFilter[i].popoverFilterLabel];

            // 選択値が配列の場合、含有判定
            if (Array.isArray(filterVal)) {
              if (filterVal.indexOf(searchVal) >= 0) {
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
        retArr.unshift({ text: "", value: null });
      } else if (this.hasUnregisteredOption) {
        retArr.unshift({ text: "未登録", value: null });
      }
      /* mod スタッフ追加の複数追加と空欄追加 楊 end */

      return retArr;
    },
    // add #6512 患者情報画面の分の修正 劉 start
    isPatInfoFlg() {
      if (
        this.popoverTitleHeader === "国籍" ||
        this.popoverTitleHeader === "保険選択" ||
        this.popoverTitleHeader === "患者" ||
        this.popoverTitleHeader === "続柄" ||
        this.popoverTitleHeader === "診療科" ||
        this.popoverTitleHeader === "透析実施科" ||
        this.popoverTitleHeader === "病棟" ||
        this.popoverTitleHeader === "重症度" ||
        this.popoverTitleHeader === "搬送" ||
        this.popoverTitleHeader === "担当者" ||
        this.popoverTitleHeader === "禁忌・アレルギー" ||
        this.popoverTitleHeader === "インプラント" ||
        this.popoverTitleHeader === "担当医" ||
        this.popoverTitleHeader === "診断医" ||
        this.popoverTitleHeader === "病名" ||
        this.popoverTitleHeader === "スタッフ") {
        return true;
      } else {
        return false;
      }
    },
    // add #6512 患者情報画面の分の修正 劉 end

    ...mapGetters("account-edit", {
      userAccountInfo: "getStateUserAccountInfo"
    }),
    isAdmin() {
      return this.userAccountInfo.administrator === 1 ? true : false;
    },
    isMasterUser() {
      return this.userAccountInfo.userType === 1 ? true : false;
    },
    isNkkStaff() {
      return this.userAccountInfo.facilityCd === "nkknkk";
    }
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
          this.isChanged =
            value === this.popoverContentSelected.value ? true : false;
        }
      },
      immediate: true,
    },
    // add #6512 患者情報画面の分の修正 劉 end
    /** 連携稼働ビューアのヘッダで選択中の施設CDを監視 */
    getToFacilityCd: {
      handler(value) {
        this.searchCondition.facilityCd = Array.isArray(value) ? value : (value ? [value] : []);
      },
      immediate: true,
    },
  },

  mounted() {
    // modify by 史 for 6119 ブラウザがOut of Memoryのエラーが発生する
    (this.$el?.ownerDocument?.defaultView || window).addEventListener("resize",this.resizeEventListener);
  },
  async created() {
    await this.getSearchData();
  },
  methods: {
    // modify by 史 for 6119 ブラウザがOut of Memoryのエラーが発生する
    resizeEventListener(){
      this.windowHeight = getViewportHeight();
      this.windowWidth = getViewportWidth();
    },
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    // add 投薬支援マスタ 薬剤名css 鞠
    setListClassOne(cd) {
      const selectedList = this.popoverContentSelectedItem
        ? this.popoverContentSelectedItem
        : [];
      const obj = {
        "selected-color": false,
        "dis-selected-color": false,
      };
      // 選択状態フラグを格納
      let isSelected = false;
      isSelected = selectedList === cd ? true : isSelected;
      // // 選択中クラスを付与
      obj["selected-color"] = isSelected;
      // 未選択中クラスを付与
      obj["dis-selected-color"] = !isSelected;
      return obj;
    },
    //add end
    ...mapActions("external-coop", ["sendRequestCommandKeyCoop", "sendRequestResetEdgeStatus"]),
    /* add 投薬支援マスタ 薬効換算の場合,薬剤分類なし 孔 start */
    /**
     * @description 投薬支援マスタ 薬効換算の場合,薬剤分類なし
     */
    checkMachineSupport(filter) {
      if (
        this.mstMachineSupportFlg &&
        filter === "薬剤分類" &&
        this.popoverFilterSelectedItem["薬剤区分"] === 3) {
        this.popoverFilterSelectedItem["薬剤分類"] = 0;
        return true;
      } else {
        return false;
      }
    },
    /* add 投薬支援マスタ 薬効換算の場合,薬剤分類なし 孔 end */

    /**
     * @description ポップオーバー非表示
     */
    closePopover() {
      const value = this.getToFacilityCd;
      this.searchCondition.facilityCd = Array.isArray(value) ? value : (value ? [value] : []);
      this.$emit("popover-close", false);
      this.popoverDirection = "";
    },

    /**
     * @description 連携エッジ制御指示管理のステータスをリセットする
     */
    async clearStatus() {
      // 必須チェック
      if(this.searchCondition.facilityCd.length === 0)
      {
        this.$ons.notification.alert({
            title: DIALOG_MESSAGES['00200157'].title,
            message: messageFormat(DIALOG_MESSAGES['00200157'].message)
          });
        return;
      }

      const param = {
              facility_cds: this.searchCondition.facilityCd
            };
      const response = await this.sendRequestResetEdgeStatus(param).catch(
        (error) => {
          this.$ons.notification.alert({
            // mod #6107 2023/03/08 メッセージボックス全調整 林峻峰 start
            // title: "",
            // message: "実行失敗"
            title: DIALOG_MESSAGES['00200001'].title,
            message: messageFormat(DIALOG_MESSAGES['00200001'].message)
            // mod #6107 2023/03/08 メッセージボックス全調整 林峻峰 end
          });
        });

      if (200 === response.status) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/08 メッセージボックス全調整 林峻峰 start
          // title: "",
          // message: "実行成功"
          title: DIALOG_MESSAGES['00100001'].title,
          message: messageFormat(DIALOG_MESSAGES['00100001'].message)
          // mod #6107 2023/03/08 メッセージボックス全調整 林峻峰 end
        });
      }
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
        this.isChanged = true;
      } else {
        this.isChanged = false;
      }
      // add #6512 患者情報画面の分の修正 劉 end
      // 投薬支援マスタ 薬剤分類と薬剤名の連動 add start 鞠
      if (
        "mst_medicine_support" === this.masterPhysicalName &&
        this.popoverFilter.length != 0) {
        let classCd = 0;
        const selectedItem = this.popoverContentDataset.find(
          (item) => item.value === this.popoverContentSelectedItem);
        if (
          !(
            selectedItem === undefined ||
            selectedItem.fnValue.薬剤分類 === -1 ||
            selectedItem.fnValue.薬剤分類 === undefined)) {
          classCd = selectedItem.fnValue.薬剤分類;
        }

        const filterItem = this.popoverFilter
          .find((item) => item.popoverFilterLabel === "薬剤分類")
          .popoverFilterDataset.find((item) => item.value === classCd);
        this.popoverFilter.forEach((item) => {
          this.popoverFilterSelectedItem = {
            ...this.popoverFilterSelectedItem,
            [item.popoverFilterLabel]:
              item.popoverFilterLabel === "薬剤分類"
                ? filterItem.value
                : item.popoverFilterDataset[0].value,
          };
        });
        // 投薬支援マスタ 薬剤分類と薬剤名の連動 add end 鞠
      } else {
        this.popoverFilter.forEach((item) => {
          this.popoverFilterSelectedItem = {
            ...this.popoverFilterSelectedItem,
            [item.popoverFilterLabel]: item.popoverFilterDataset[0].value,
          };
        });
      }

      this.checkNeedleOptionDisplayq();
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
      let retVal =
        this.popoverContentSelectedItem === null
          ? { text: "", value: null }
          : this.popoverContentDataset.find((item) => {
              return item.value === this.popoverContentSelectedItem;
            });

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
    checkNeedleOptionDisplayq() {
      for (const key in this.popoverFilterSelectedItem) {
        const filter = this.popoverFilter.find((item) => {
          return item.popoverFilterLabel === key;
        });
        const filterItem = filter.popoverFilterDataset.find((item) => {
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
    async addImplement(commandKey) {
      // 必須チェック
      if(this.searchCondition.facilityCd.length === 0)
      {
        this.$ons.notification.alert({
            title: DIALOG_MESSAGES['00200157'].title,
            message: messageFormat(DIALOG_MESSAGES['00200157'].message)
          });
        return;
      }

      // add 8482 リモートコマンド実行後のローダーを表示 ljx start
        this.isLoadingVisible = true;
      // add 8482 リモートコマンド実行後のローダーを表示 ljx end
            const param = {
              type: "command",
              command: commandKey,
              dir_path: "",
              facility_cd: this.searchCondition.facilityCd,
              serial_no: "",
            };
            const response = await this.sendRequestCommandKeyCoop(param).catch(
              (error) => {
                // add 8482 リモートコマンド実行後のローダーを表示 ljx start
                this.isLoadingVisible = false;
                // add 8482 リモートコマンド実行後のローダーを表示 ljx end
                if (400 === error.response.status) {
                  this.$ons.notification.alert({
                    title: DIALOG_MESSAGES['00200004'].title,
                    message: messageFormat(DIALOG_MESSAGES['00200004'].message),
                  });
                }
              });
            // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
            if("restart" != commandKey){
              this.$emit('refresh-change',true);
            }
            if("restart" == commandKey){
              setTimeout(() => {
                this.$emit('refresh-change',true);
              }, 6000);
            }
            // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
            //mod 8482 デベロッパーツールのエラーの処理 ljx start
            if(response !=null && response != undefined){
              if (200 === response.status && 0 !== response.data.length) {
                // add 8482 リモートコマンド実行後のローダーを表示 ljx start
                this.isLoadingVisible = false;
                // add 8482 リモートコマンド実行後のローダーを表示 ljx end
                this.$ons.notification.alert({
                  // mod #6107 2023/03/08 メッセージボックス全調整 林峻峰 start
                  // title: "",
                  // message: "実行成功",
                  title: DIALOG_MESSAGES['00100023'].title,
                  message: messageFormat(DIALOG_MESSAGES['00100023'].message),
                  // mod #6107 2023/03/08 メッセージボックス全調整 林峻峰 end
                });
            }
            //mod 8482 デベロッパーツールのエラーの処理 ljx end
              // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
              // del 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
              // this.$emit('refresh-change',true);
              // del 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
              // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
            }

    },
    /**
     * @description 「穿刺針」の値を計算
     */
    createNeedleValue() {
      if (this.popoverContentSelected.needle) {
        const selectedItem = this.popoverContentDataset.find((item) => {
          return item.value === this.popoverContentSelectedItem;
        });

        if (!selectedItem) {
          return null;
        }

        for (const key in this.popoverFilterSelectedItem) {
          const filter = this.popoverFilter.find((item) => {
            return item.popoverFilterLabel === key;
          });
          const filterItem = filter.popoverFilterDataset.find((item) => {
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
      this.checkNeedleOptionDisplayq();
    },
    async getSearchData() {
      const responseFacility = await ApiHelper.get(uriFunctionFacility);
      // 施設選択
      const facilityInfo = responseFacility.data;
      this.facilityInfo = facilityInfo.map((facility) => {
        return {
          facilityCd: facility.facilityCd,
          facilityName: `${facility.facilityCd}_${facility.facilityName}`,
        };
      });
    },
  },
  beforeUnmount() {
    (this.$el?.ownerDocument?.defaultView || window).removeEventListener("resize",this.resizeEventListener);
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
  width: 600px;
  height: 510px;
  max-height: none !important; /* NOTE: windowSizeを変更すると[Onsen UI]の制御が走り、縮むため[Onsen UI]の制御を無効化 */
  padding: 25px;
  border: solid 1px var(--preventive-checked-border-color);
  margin: 3px;
  margin-top: -50px;
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
  float: right;
  top: 10px;
}

.button-clear {
  background:  var(--btn3-normal-color);
  color: #ffffff;
  border-bottom: solid 3px var(--btn-common-border-color);
  float: left;
  width: 10em;
  top: 10px;
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
.exam-set-list-frame {
  display: flex;
  flex-wrap: wrap;
  flex-direction: column;
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
.set-name {
  width: 3em;
  float: left;
}
.set-detail {
  margin-left: 5em;
  width: 4em;
  float: left;
}
.set-implement {
  margin-right: 1em;
  float: right;
}
.exam-e {
  align-content: flex-end;
}
.popover-style :deep(.popover-mask) {
  z-index: 1999 !important;
}
.popover-style :deep(.popover) {
  z-index: 10001 !important;
}
/* add 8482 リモートコマンド実行後のローダーを表示 ljx start*/
.loading-modal {
  text-align: center;
  font-size: 30px;
}
/* add 8482 リモートコマンド実行後のローダーを表示 ljx end*/
.list-wrapper {
  border-collapse: collapse;
  margin: 0 auto;
  width: -webkit-fill-available;
  background-color: var(--ntss-list-background-color);
}
.list-wrapper tr:nth-child(2n) {
  background-color: var(--ntss-list-content-2nd-background-color);
}
.list-wrapper tr {
  background-color: var(--ntss-list-item-background-color);
  border-color: 1px solid var(--master-maintenance-kgrid-border-color);
}
.list-wrapper tr:hover {
  background-color: var(--master-maintenance-kgrid-item-hover-background-color);
}
.list-header-th {
  color: #fff;
  background-color: var(--ntss-list-header-background-color);
  font-weight: unset;
  padding: 4px;
  border: solid 1px var(--ntss-list-border-color);
  border-top: none;
  white-space: pre;
  text-align: left;
  top: 0px;
}
.detail-cell {
  width: auto;
  border: solid 1px var(--ntss-list-border-color);
}
.action-cell {
  width: 3em;
  padding: 6px 8px;
  text-align: center;
  border: solid 1px var(--ntss-list-border-color);
}

/* 施設 MultiSelect: 入力枠は白 */
.popover-style .external-selector-facility-ms :deep(.k-legacy-multiselect.k-multiselect),
.popover-style .external-selector-facility-ms :deep(.k-widget.k-multiselect.k-legacy-multiselect) {
  background-color: #fff !important;
  min-height: 0 !important;
}

/* 施設 MultiSelect: theme.css の :before 空行占位を抑え、chip/input を同一 flex 流で折り返す */
.popover-style .external-selector-facility-ms :deep(.k-legacy-multiselect > .k-input-values.k-multiselect-wrap::before) {
  content: none !important;
  display: none !important;
  height: 0 !important;
  float: none !important;
}

.popover-style .external-selector-facility-ms :deep(.k-input-values.k-multiselect-wrap) {
  display: flex !important;
  flex-wrap: wrap !important;
  align-items: center !important;
  align-content: flex-start !important;
  gap: 0 !important;
  min-height: 0 !important;
  height: auto !important;
}

.popover-style .external-selector-facility-ms :deep(.k-chip-list.k-reset),
.popover-style .external-selector-facility-ms :deep(.k-selection-multiple.k-reset),
.popover-style .external-selector-facility-ms :deep(.k-multiselect-wrap > ul.k-reset) {
  display: contents !important;
}

.popover-style .external-selector-facility-ms :deep(.k-chip.k-button),
.popover-style .external-selector-facility-ms :deep(.k-multiselect-wrap > ul.k-reset > li.k-button) {
  flex: 0 0 auto !important;
}

.popover-style .external-selector-facility-ms :deep(.k-input-inner.k-input),
.popover-style .external-selector-facility-ms :deep(input.k-input) {
  flex: 0 1 20px !important;
  width: auto !important;
  min-width: 20px !important;
  max-width: 100% !important;
}

/* 施設選択：各タグ上の×は常時表示 */
.popover-style .external-selector-facility-ms :deep(.k-chip-remove-action.k-select),
.popover-style .external-selector-facility-ms :deep(.k-multiselect-wrap > ul.k-reset > li.k-button > .k-select) {
  opacity: 1 !important;
  pointer-events: auto !important;
  transform: translateY(4px);
}

/* preshow 中（.popover が visibility:hidden）× だけ先に見えるのを防ぐ */
.popover-style :deep(.popover[style*="visibility: hidden"] .external-selector-facility-ms .k-clear-value),
.popover-style :deep(.popover[style*="visibility: hidden"] .external-selector-facility-ms .k-chip-remove-action) {
  visibility: hidden !important;
  opacity: 0 !important;
  pointer-events: none !important;
}

.popover-style .external-selector-facility-ms :deep(.k-chip-remove-action .k-icon::before),
.popover-style .external-selector-facility-ms :deep(.k-chip-remove-action .k-svg-icon::before) {
  font-size: 22px !important;
  font-weight: normal !important;
  line-height: 1 !important;
}

/* 右端一括クリア：ホバー/フォーカス時のみ表示 */
.popover-style .external-selector-facility-ms :deep(.k-legacy-multiselect .k-clear-value),
.popover-style .external-selector-facility-ms :deep(.k-widget.k-multiselect .k-clear-value) {
  opacity: 0 !important;
  pointer-events: none !important;
  transition: opacity 0.12s ease;
}

.popover-style .external-selector-facility-ms:hover :deep(.k-legacy-multiselect .k-clear-value),
.popover-style .external-selector-facility-ms:focus-within :deep(.k-legacy-multiselect .k-clear-value),
.popover-style .external-selector-facility-ms :deep(.k-legacy-multiselect.k-multiselect:hover .k-clear-value),
.popover-style .external-selector-facility-ms :deep(.k-legacy-multiselect.k-multiselect:focus-within .k-clear-value),
.popover-style .external-selector-facility-ms:hover :deep(.k-widget.k-multiselect .k-clear-value),
.popover-style .external-selector-facility-ms:focus-within :deep(.k-widget.k-multiselect .k-clear-value),
.popover-style .external-selector-facility-ms :deep(.k-widget.k-multiselect.k-legacy-multiselect:hover .k-clear-value),
.popover-style .external-selector-facility-ms :deep(.k-widget.k-multiselect.k-legacy-multiselect:focus-within .k-clear-value) {
  opacity: 1 !important;
  pointer-events: auto !important;
}
</style>
