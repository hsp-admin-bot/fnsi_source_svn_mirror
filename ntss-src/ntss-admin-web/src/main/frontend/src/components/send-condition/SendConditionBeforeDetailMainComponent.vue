
/**
 * 条件送信前体重詳細画面
 */
<template>
  <div class="sub-content-area ntss-send-condition-text">
    <!-- 上エリア -->
    <div class="send-condition-before-measure-value-block main-block">
      <div class="send-condition-before-measure-value-main-block">
        <!-- 1行目 -->
        <v-ons-row class="measure-value-row">
          <!-- 1-1 測定値 -->
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-before-detail-lbl">測定値</label>
            <!-- 治療中または条件確認後？ -->
            <template v-if="isDialysisNow">
              <label class="send-condition-before-value-label">{{getMeasuredInfo.text}}</label>
            </template>
            <!-- 体重/体重+車いす -->
            <template v-else-if="!isWheelChairMode">
              <div>
                <v-ons-input
                  id="bedeweightID"
                  class="send-condition-before-input"
                  type="number"
                  :step="numberStep"
                  v-model.number="editMeasuredValue"
                  @blur="changeMeasureVal(editMeasuredValue, $event, false)"
                  @keydown.enter="moveFocus($event)"
                  @keydown="onKeyDown"
                  @input="checkLoop"
                  readonly="readonly"
                ></v-ons-input>
                <label class="send-condition-unit send-condition-before-unit"> kg
                  <img height="26px" :src="image_src" @click="show"/>
                </label>
              </div>
            </template>
            <!-- 車いす -->
            <template v-else>
              <label class="send-condition-before-value-label" :style="unmeasuredAlign(getMeasuredInfo.text)">{{getMeasuredInfo.text}}</label>
            </template>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center">
            <h4 class="send-condition-before-symbol">－</h4>
          </v-ons-col>

          <!-- 1-2 風袋 -->
          <v-ons-col :width="labelWidth" class="vertical-div">
            <v-ons-button class="send-condition-before-detail-btn btn3-normal" @click="showModal(1)">風袋</v-ons-button>
            <label class="send-condition-before-value-label">{{taraValue}}</label>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center" v-show="getIsWheelchair">
            <h4 class="send-condition-before-symbol">－</h4>
          </v-ons-col>

          <!-- 1-3 車いす -->
          <v-ons-col :width="labelWidth" class="vertical-div" v-show="getIsWheelchair">
            <v-ons-button
              :class="wheelChairButtonClass"
              ref="wheelChairButton"
              @click="showWheelChairPopover"
            ><span class="weight-mode-mst-weight-button-text">
              {{getSelectWheelchair.name}}
            </span></v-ons-button>
            <template v-if="isWheelChairMode">
              <div>
                <v-ons-input
                  id="bedeCarID"
                  class="send-condition-before-input"
                  type="number"
                  :step="numberStep"
                  v-model.number="editMeasuredValue"
                  @blur="changeMeasureVal(editMeasuredValue, $event, false)"
                  @keydown.enter="moveFocus($event)"
                  @keydown="onKeyDown"
                  @input="checkLoop"
                  readonly="readonly"
                ></v-ons-input>
                <label class="send-condition-unit send-condition-before-unit"> kg
                  <img height="26px" :src="image_src" @click="show"/>
                </label>
              </div>
            </template>
            <template v-else>
              <label class="send-condition-before-value-label" :style="unmeasuredAlign(getSelectWheelchairWeight)">{{getSelectWheelchairWeight}}</label>
            </template>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center">
            <h4 class="send-condition-before-symbol">＝</h4>
          </v-ons-col>

          <!-- 1-4 前体重 -->
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-before-detail-lbl">前体重</label>
            <label class="send-condition-before-value-label">{{beforeWeightValue}}</label>
          </v-ons-col>
          <v-ons-col />
        </v-ons-row>

        <!-- 1行目 電卓ボタン -->
        <div>
          <v-ons-popover
            cancelable
            id="bedeweightPopOver"
            :visible.sync="cavisible"
            :target="popoverTarget"
            direction="down"
            class="popoverClass"
            @posthide="tenkeyClose">
            <vue-touch-keyboard :options="options" :layout="layout" :next="next" :cancel="cancel" :accept="accept" :input="input"/>
          </v-ons-popover>
        </div>
        <div>
          <v-ons-popover
            cancelable
            id="bedeCarPopOver"
            :visible.sync="cavisibleCar"
            :target="popoverTarget"
            direction="down"
            class="popoverClass"
            @posthide="tenkeyClose">
            <vue-touch-keyboard :options="options" :layout="layout" :next="next" :cancel="cancel" :accept="accept" :input="input" style="float:right"/>
          </v-ons-popover>
        </div>

        <!-- 2行目 -->
        <v-ons-row class="send-condition-before-value-label-row">
          <!-- 2-1 前体重 -->
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-before-detail-lbl">前体重</label>
            <label class="send-condition-before-value-label">{{beforeWeightValue}}</label>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center">
            <h4 class="send-condition-before-symbol">＋</h4>
          </v-ons-col>

          <!-- 2-2 除水補正 -->
          <v-ons-col :width="labelWidth" class="vertical-div">
            <v-ons-button class="send-condition-before-detail-btn btn3-normal" @click="showModal(0)">除水補正</v-ons-button>
            <label class="send-condition-before-value-label">{{waterValue}}</label>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center">
            <h4 class="send-condition-before-symbol">－</h4>
          </v-ons-col>

          <!-- 2-3 目標体重 -->
          <v-ons-col :width="labelWidth" class="vertical-div">
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <v-ons-button -->
            <!--   class="send-condition-before-detail-btn btn3-normal" -->
            <!--   :disabled="!canChangeOrder" -->
            <!--   @click="showChgOrderModal(0)" -->
            <!-- >目標体重</v-ons-button> -->
            <v-ons-button
              class="send-condition-before-detail-btn btn3-normal"
              :disabled="!getItemAuthorized('SendConditionMainComponent', 'item_target_weight') && !canChangeOrder"
              @click="showChgOrderModal(0)"
            >目標体重</v-ons-button>
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
            <label class="send-condition-before-value-label" :style="unsettingAlign(getIndTargetWeight.text)">{{getIndTargetWeight.text}}</label>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center">
            <h4 class="send-condition-before-symbol">：</h4>
          </v-ons-col>

          <!-- 2-4 除水制限 -->
          <v-ons-col :width="labelWidth" class="vertical-div">
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <v-ons-button -->
            <!--   class="send-condition-before-detail-btn btn3-normal" -->
            <!--   :disabled="!canChangeOrder" -->
            <!--   @click="showChgOrderModal(1)" -->
            <!-- >除水制限</v-ons-button> -->
            <v-ons-button
              class="send-condition-before-detail-btn btn3-normal"
              :disabled="!getItemAuthorized('SendConditionMainComponent', 'item_water_removal_limit') && !canChangeOrder"
              @click="showChgOrderModal(1)"
            >除水制限</v-ons-button>
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
            <label class="send-condition-before-value-label">{{getIndWaterRemovalLimit.text}}</label>
          </v-ons-col>

          <!-- 2-5 目標除水量 -->
          <v-ons-col width="15.5em" class="wrapper-water-removal-target">
            <div class="water-removal-target">
              <v-ons-col :width="symbolWidth">
                <h4 class="send-condition-before-symbol">＝</h4>
              </v-ons-col>
            </div>
            <v-ons-col :width="labelWidth" class="vertical-div">
              <label class="send-condition-before-detail-lbl">目標除水量</label>
              <label class="send-condition-before-value-label">{{waterRemovalTarget}}</label>
            </v-ons-col>
          </v-ons-col>
        </v-ons-row>
      </div>
    </div>

    <!-- 下エリア -->
    <div class="send-condition-before-measure-value-block">
      <div class="send-condition-before-measure-value-sub-block" :class="[deviceFlg ? 'streaming-mode' : '']">
        <v-ons-row class="measure-value-row measure-value-row-border">
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-before-detail-lbl">前体重</label>
            <label class="send-condition-before-value-label">{{beforeWeightValue}}</label>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center">
            <h4 class="send-condition-before-symbol">－</h4>
          </v-ons-col>
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-before-detail-lbl">前回後</label>
            <label class="send-condition-before-value-label" :style="unmeasuredAlign(lastTimeWeight)">{{lastTimeWeight}}</label>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center">
            <h4 class="send-condition-before-symbol">＝</h4>
          </v-ons-col>
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-before-detail-lbl">増減1</label>
            <label class="send-condition-before-value-label">{{increase1}}</label>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row class="measure-value-row">
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-before-detail-lbl">前体重</label>
            <label class="send-condition-before-value-label">{{beforeWeightValue}}</label>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center">
            <h4 class="send-condition-before-symbol">－</h4>
          </v-ons-col>
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-before-detail-lbl">目標体重</label>
            <label class="send-condition-before-value-label" :style="unsettingAlign(getIndTargetWeight.text)">{{getIndTargetWeight.text}}</label>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center">
            <h4 class="send-condition-before-symbol">＝</h4>
          </v-ons-col>
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-before-detail-lbl">増減2</label>
            <label class="send-condition-before-value-label">{{increase2}}</label>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row class="measure-value-row">
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-before-detail-lbl">前体重</label>
            <label class="send-condition-before-value-label">{{beforeWeightValue}}</label>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center">
            <h4 class="send-condition-before-symbol">－</h4>
          </v-ons-col>
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-before-detail-lbl">DW</label>
            <label class="send-condition-before-value-label" :style="unsettingAlign(getIndDryWeight.text)">{{getIndDryWeight.text}}</label>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center">
            <h4 class="send-condition-before-symbol">＝</h4>
          </v-ons-col>
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-before-detail-lbl">増減3</label>
            <label class="send-condition-before-value-label">{{increase3}}</label>
          </v-ons-col>
        </v-ons-row>
      </div>
    </div>

    <pop-over
      v-bind="popoverData"
      :target-position-element="$refs.wheelChairButton"
      :fromSendConditionFlg=true
      @popover-close="closePopover"
      @popover-return="returnPopover"
    />
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { mapGetters, mapActions } from "vuex";
import { EventBus } from "@/eventBus.js";
import BigNumber from "bignumber.js";
// add FNSI-特殊浄化の場合、除水量制限不要 徐 start
// import { weightScaleMode, dialysisState } from "@/constants/weightDefine";
import { weightScaleMode, dialysisState, deviceModeConstant } from "@/constants/weightDefine";
// add FNSI-特殊浄化の場合、除水量制限不要 徐 end
import MasterSelector from "@/components/common/master-selector/MasterSelector";
// add FNSI-体重計モードテンキーの追加 徐 start
import VueTouchKeyboard from "vue-touch-keyboard/dist/vue-touch-keyboard";
import "./../../../public/css/vue-touch-keyboard.css";
// add FNSI-体重計モードテンキーの追加 徐 end
// add #6107 2023/03/24 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/24 メッセージボックス全調整 林峻峰 end
export default {
  props: {},
  components: {
    "pop-over": MasterSelector,
    // add FNSI-体重計モードテンキーの追加 徐 start
    "vue-touch-keyboard":VueTouchKeyboard.component
    // add FNSI-体重計モードテンキーの追加 徐 end
  },
  data() {
    return {
      popoverData: {
        popoverVisible: false,
        popoverDisplayDirection: "down",
        popoverTitleHeader: "",
        popoverFilterLabel: "",
        popoverFilterDataset: [],
        popoverContentLabel: "",
        popoverContentDataset: []
      },
      measureValue: 0,
      // add FNSI-体重計モードテンキーの追加 徐 start
      cavisible: false,
      cavisibleCar: false,
      layout: null,
      input: null,
      options: {
        useKbEvents: false,
        preventClickEvent: false
      },
      image_src: require("@/../public/img/keyboard/keyboard.png"),
      // add FNSI-体重計画面 徐 start
      breadMode: true,
      // add FNSI-体重計画面 徐 end
      popoverTarget: null,
      // add FNSI-体重計モードテンキーの追加 徐 end
      // mod #8160 2022/12/06 体重測定の測定値が見切れる dou start
      // labelWidth: "12.4em", // ラベル部の長さ
      labelWidth: "13.5em", // ラベル部の長さ
      // mod #8160 2022/12/06 体重測定の測定値が見切れる dou end
      symbolWidth: "2em", // 記号部の長さ
      numberStep: 0.01,
      numberMax: 300.00,
      numberMin: 0.00,
      doClearTwice: false,
      isAndroid: false,
      isIOS: false,
      deviceFlg: false,
    };
  },
  computed: {
    ...mapGetters("send-condition/scale", [
      "getIsWheelchair",
      "getScaleMode",
      "getMeasuredValue",
      "getMeasuredInfo",
      "getSelectWheelchair",
      "getSelectWheelchairWeight",
      "getTareWeight",
      "getBodyWeightValue",
      "getBodyWeightInfo",
      "getIndTargetWeight",
      "getIndDryWeight",
      "getLastTimeWeight",
      "getIndWaterRemovalLimit",
      "getOffWaterWeight",
      "getWaterRemovalTarget",
      "getSelectedOrdNo",
      "getIsCurrentDialysisStateEqualDialysisState"
    ]),
    ...mapGetters("send-condition/scale/setting", ["getWheelChairList", "getWeightConfigInfo"]),
    ...mapGetters("pat-info", ["selectedPatId", "selectedPatName"]),
    // add FNSI-体重計モードテンキーの追加 徐 start
    ...mapGetters("send-condition/weight", ["getWeightMode"]),
    // add FNSI-体重計画面 徐 start
    ...mapGetters("app", ["getQueryParameters"]),
    // add FNSI-体重計画面 徐 end
    // add FNSI-体重計モードテンキーの追加 徐 end
    isWheelChairMode: {
      get() {
        // add FNSI-体重計モードテンキーの追加 徐 start
        // eslint-disable-next-line vue/no-side-effects-in-computed-properties
        this.cavisible = false;
        // eslint-disable-next-line vue/no-side-effects-in-computed-properties
        this.cavisibleCar = false;
        // add FNSI-体重計モードテンキーの追加 徐 end
        setTimeout(() => {
          this.addWheelEvent();
        }, 500);
        return this.getScaleMode === weightScaleMode.wheelChair;
      }
    },
    // 指示変更ボタン有効フラグ
    canChangeOrder: {
      get() {
        if (this.getSelectedOrdNo.ordNo === null) {
          // 指示なしならば変更不可
          return false;
        }
        // add FNSI-特殊浄化の場合、除水量制限不要 徐 start
        // if (
        //   this.getIsCurrentDialysisStateEqualDialysisState(
        //     dialysisState.dialysis
        //   ) ||
        //   this.getIsCurrentDialysisStateEqualDialysisState(
        //     dialysisState.checkedSendCondition
        //   )
        // ) {
          if (
          this.getIsCurrentDialysisStateEqualDialysisState(
            dialysisState.dialysis
          ) ||
          this.getIsCurrentDialysisStateEqualDialysisState(
            dialysisState.checkedSendCondition
          ) ||
          this.getIsCurrentDialysisStateEqualDialysisState(
            deviceModeConstant.PURIFICATION
          )
        ) {
          // add FNSI-特殊浄化の場合、除水量制限不要 徐 end
          // 治療中または条件送信確認済みならば変更不可
          return false;
        }
        return true;
      }
    },
    // 治療中、または条件確認後の状態であるならばtrue
    isDialysisNow: {
      get() {
        return this.getIsCurrentDialysisStateEqualDialysisState(
          dialysisState.dialysis
        );
      }
    },
    // 測定値
    editMeasuredValue: {
      get() {
        let retval = this.adjustDigits();
        if (this.doClearTwice) {
          // クリア処理の2回目を時間差で行う
          setTimeout(() => {
            this.clearValue();
            this.moveCursor();
          }, 10);
          this.doClearTwice = false;
        }
        return retval;
      },
      set(val) {
        if(this.cavisible || this.cavisibleCar) {
          return;
        }
        this.measureValue = val;
      }
    },
    // 風袋
    taraValue: {
      get() {
        // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 start
        // return this.getTareWeight;
        if (
          this.getTareWeight !== null
        ) {
          let value = Number(this.getTareWeight);
          if (value < 0) {
            return `－${(value * -1).toFixed(2)} kg`;
          } else {
            return `${value.toFixed(2)} kg`;
          }
        } else {
          return "";
        }
        // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 end
      }
    },
    // 前体重
    beforeWeightValue: {
      get() {
        let value = Number(this.getBodyWeightInfo.value);
        if (value < 0) {
          return `－${(value * -1).toFixed(2)} kg`;
        } else {
          return `${value.toFixed(2)} kg`;
        }
      }
    },
    // add FNSI-体重計画面 徐 start
    getSelectWheelchairName: {
      get() {
        if (this.getSelectWheelchair.name.length > 6) {
          return this.getSelectWheelchair.name.substring(0, 4) + "...";
        } else {
          return this.getSelectWheelchair.name;
        }
      }
    },
    // add FNSI-体重計画面 徐 end
    // 除水補正
    waterValue: {
      get() {
        // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 start
        // return this.getOffWaterWeight;
        if (
          this.getOffWaterWeight !== null
        ) {
          let value = Number(this.getOffWaterWeight);
          if (value < 0) {
            return `－${(value * -1).toFixed(2)} kg`;
          } else {
            return `${value.toFixed(2)} kg`;
          }
        } else {
          return "";
        }
        // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 end
      }
    },
    // 目標値[前体重 + 除水 - 目標体重 < 除水制限]
    waterRemovalTarget: {
      get() {
        if (this.getWaterRemovalTarget !== null) {
          // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 start
          // return Number(this.getWaterRemovalTarget) + "kg";
          return Number(this.getWaterRemovalTarget).toFixed(2) + "kg";
          // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 end
        }
        return "";
      }
    },
    // 前回後
    lastTimeWeight: {
      get() {
        if (this.getLastTimeWeight !== null) {
          // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 start
          // return Number(this.getLastTimeWeight) + "kg";
          let value = Number(this.getLastTimeWeight);
          if (value < 0) {
            return `－${(value * -1).toFixed(2)} kg`;
          } else {
            return `${value.toFixed(2)} kg`;
          }
          // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 end
        }
        return "未測定";
      }
    },
    // 増減1[前体重 - 前回後]
    increase1: {
      get() {
        if (
          this.getLastTimeWeight !== null &&
          this.getBodyWeightInfo.value !== null
        ) {
          let value = Number(new BigNumber(this.getBodyWeightInfo.value).minus(this.getLastTimeWeight));
          if (value < 0) {
            return `－${(value * -1).toFixed(2)} kg`;
          } else {
            return `${value.toFixed(2)} kg`;
          }

          // return (
          //   // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 start
          //   // Number(
          //   //   new BigNumber(this.getBodyWeightInfo.value).minus(
          //   //     this.getLastTimeWeight
          //   //   )
          //   // ) + "kg"
          //   Number(
          //     new BigNumber(this.getBodyWeightInfo.value).minus(
          //       this.getLastTimeWeight
          //     )
          //   ).toFixed(2) + "kg"
          //   // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 end
          // );
        }
        return "";
      }
    },
    // 増減2[前体重 - 目標体重]
    increase2: {
      get() {
        if (
          this.getIndTargetWeight.value !== null &&
          this.getBodyWeightInfo.value !== null
        ) {
          // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 start
          // return `${Number(
          //   new BigNumber(this.getBodyWeightInfo.value).minus(
          //     this.getIndTargetWeight.value
          //   )
          // )} kg`;

          let value = Number(new BigNumber(this.getBodyWeightInfo.value).minus(this.getIndTargetWeight.value));
          if (value < 0) {
            return `－${(value * -1).toFixed(2)} kg`;
          } else {
            return `${value.toFixed(2)} kg`;
          }

          // return `${Number(
          //   new BigNumber(this.getBodyWeightInfo.value).minus(
          //     this.getIndTargetWeight.value
          //   )
          // ).toFixed(2)} kg`;
          // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 end
        } else {
          return null;
        }
      }
    },
    // 増減2[前体重 - DW]
    increase3: {
      get() {
        if (
          this.getIndDryWeight.value !== null &&
          this.getBodyWeightInfo.value !== null
        ) {
          // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 start
          // return `${Number(
          //   new BigNumber(this.getBodyWeightInfo.value).minus(
          //     this.getIndDryWeight.value
          //   )
          // )} kg`;

          let value = Number(new BigNumber(this.getBodyWeightInfo.value).minus(this.getIndDryWeight.value));
          if (value < 0) {
            return `－${(value * -1).toFixed(2)} kg`;
          } else {
            return `${value.toFixed(2)} kg`;
          }

          // return `${Number(
          //   new BigNumber(this.getBodyWeightInfo.value).minus(
          //     this.getIndDryWeight.value
          //   )
          // ).toFixed(2)} kg`;
          // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 end
        } else {
          return null;
        }
      }
    },
    wheelChairButtonClass() {
      const calibrationCheck = this.getSelectWheelchair.calibrationCheck;

      if (calibrationCheck) {
        return [
          "send-condition-before-detail-btn",
          "btn3-normal"
        ];
      } else {
        return [
          "send-condition-before-detail-btn",
          "btn4-alert"
        ];
      }
    },
  },
  methods: {
    ...mapActions("multi-modal", ["showTareWaterEdit"]),
    ...mapActions("send-condition/scale", [
      "setMeasuredValue",
      "setWeightValue",
      "setEditModalData",
      "calcWeightValue",
      "setSelectWheelChair",
      "changeWheelChairWeightValue",
      "setMeasuring",
      "preSaveCheckDBChanged"
    ]),
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    // 車いす選択ポップアップ
    showWheelChairPopover() {
      //
      this.popoverData.popoverTitleHeader = "車いす選択";
      this.popoverData.popoverContentLabel = "車いす";
      this.popoverData.popoverContentDataset = this.createPopoverContentData(
        this.getWheelChairList.filter(elm => elm.wheelChairWeight !== null),
        "wheelChairCd",
        "wheelChairName",
        "calibrationCheck"
      );
      this.popoverData.popoverVisible = true;
    },
    createPopoverContentData(mstData, objCd, objName, calibrationCheck) {
      const retArr = [];
      for (let i = 0; i < mstData.length; i++) {
        if (
          this.selectedPatId === mstData[i].patId ||
          mstData[i].isPersonal === "0"
        ) {
          retArr.push({
            value: mstData[i][objCd],
            text: mstData[i][objName],
            calibrationCheck: mstData[i][calibrationCheck],
          });
        }
      }
      return retArr;
    },

    closePopover() {
      this.popoverData.popoverVisible = false;
    },
    returnPopover(selectData) {
      this.setSelectWheelChair(selectData.value);
    },
    // 測定値変更時
    changeMeasureVal(oldVal, e, isPostHide) {
      if ((this.cavisible || this.cavisibleCar) && !isPostHide) {
        return;
      }
      // 入力制限
      // add FNSI-体重計モードテンキーの追加 徐 start
      // const re = new RegExp(e.target.pattern);
      // const result = re.exec(e.target.value);
      // e.target.value = result ? result.input : oldVal;
        let pattern = "^([0-9][0-9]{0,2}|0)(.[0-9]{1,2})?$";
        const re = new RegExp(pattern);
        const result = re.exec(e.target.value);
        if (result) {
          if (result.input > this.numberMax) {
            e.target.value = Number(oldVal).toFixed(2);
          } else {
            e.target.value = Number(result.input).toFixed(2);
          }
        } else {
          if (this.getWeightMode.isWeightMode) {
            if (e.target.value === null || e.target.value === "") {
              e.target.value = "";
            } else {
              let valueSplit = String(e.target.value).split(".");
              if (valueSplit.length === 2) {
                if (valueSplit[0].length > 3) {
                  e.target.value = Number(oldVal).toFixed(2);
                } else if (valueSplit[1].length > 2) {
                  e.target.value = Number(oldVal).toFixed(2);
                } else if (valueSplit[0].length === 0 && valueSplit[1].length === 0) {
                  e.target.value = null;
                }
              }
            }
          } else {
            e.target.value = Number(oldVal).toFixed(2);
          }
        }
      // add FNSI-体重計モードテンキーの追加 徐 end
      if (this.isWheelChairMode) {
        this.changeWheelChairWeightValue(e.target.value).then(() => {
          // 体重値計算
          this.calcWeightValue();
        });
      } else {
        this.setMeasuredValue(e.target.value).then(() => {
          // 体重値計算
          this.calcWeightValue();
        });
      }
    },
    // 風袋・除水補正モーダル表示
    showModal(mode) {
      // 風袋・除水補正モーダル表示
      this.preChangeOrderBtnClick(this.showTareAndWaterEditModal, mode);
    },
    showTareAndWaterEditModal(mode) {
      // 編集対象データセット
      this.setEditModalData(mode);

      // 除水補正の場合
      let title = "除水補正";

      // 風袋の場合
      if (mode === 1) {
        title = "風袋";
      }

      // 風袋・除水補正モーダル表示
      this.showTareWaterEdit(title);
    },
    // 除水制限、目標体重モーダルを表示
    showChgOrderModal(category) {
      this.preChangeOrderBtnClick(this.showChangeOrderModal, category);
    },
    // 除水制限、目標体重モーダルを表示
    showChangeOrderModal(category) {
      this.$emit("click-show-treat-cond", category);
    },

    preChangeOrderBtnClick(func, arg) {
      // 指示が外部で変更されていないかどうかチェック
      this.preSaveCheckDBChanged(0).then(
        /** @param {boolean} r*/
        r => {
          if (r) {
            // ボタンに対応するアクションを実行
            func(arg);
          } else {
            this.$ons.notification.confirm({
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
              // title: "外部変更あり",
              title: DIALOG_MESSAGES[13000123].title,
              // message: "治療情報の変更がありました。再取得します。",
              message: messageFormat(DIALOG_MESSAGES[13000123].message),
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
              callback: answer => {
                if (answer == 1) {
                  //OK
                  EventBus.$emit("refresh");
                }
              }
            });
          }
        }
      );
    },

    // 入力欄の桁数自動調整
    adjustDigits() {
      if (this.isWheelChairMode) {
        // add #12236 体重測定の動作不正 linjunfeng start
        if (isNaN(this.getSelectWheelchair.weight)) {
          return '0.00';
        }
        // add #12236 体重測定の動作不正 linjunfeng end
        return Number(this.getSelectWheelchair.weight).toFixed(2);
      } else {
        return Number(this.getMeasuredValue).toFixed(2);
      }
    },

    // 入力欄のフォーカス移動
    moveFocus(event) {
      event.target.blur();
    },

    // 入力欄のマウスホイールイベント設定
    addWheelEvent() {
      let bedeweightIdElem = document.getElementById("bedeweightID");
      if (bedeweightIdElem) {
        // 数値入力欄に'wheel'のイベントリスナーを設定することで
        // ホイールを使ったマウスホイールによる数値変更が可能。
        // 関数の内容は問わないため何もしない関数を指定。
        bedeweightIdElem.addEventListener('wheel', () => {});
        if (this.isIOS || this.isAndroid) {
          bedeweightIdElem?.classList?.add('input-mobile');
        }
      }
      let bedeCarIdElem = document.getElementById("bedeCarID");
      if (bedeCarIdElem) {
        bedeCarIdElem.addEventListener('wheel', () => {});
        if (this.isIOS || this.isAndroid) {
          bedeCarIdElem?.classList?.add('input-mobile');
        }
      }
    },

    // テンキー表示時にキー入力無効化
    onKeyDown(event) {
      if (this.cavisible || this.cavisibleCar) {
        event.preventDefault();
      }
    },

    // 数値範囲内ループチェック
    checkLoop(event) {
      // テキスト入力の場合は除外
      if (event.inputType && event.inputType === "insertText") {
        return;
      }

      // テンキー入力の場合は除外
      if (this.cavisible || this.cavisibleCar) {
        return;
      }

      // 数値範囲内かどうかの確認
      if (event.target.value > this.numberMax) {
        event.target.value = this.numberMin;
      } else if (event.target.value < this.numberMin) {
        event.target.value = this.numberMax;
      }
    },

    // add FNSI-体重計モードテンキーの追加 徐 start
    show() {
      if (this.isWheelChairMode) {
        let bedeCarIDElem = document.getElementById("bedeCarID");
        bedeCarIDElem.setAttribute("type", "text");
        this.input = bedeCarIDElem.firstElementChild;
        this.input.setAttribute("readonly", "readonly");

        this.selectAllInput(this.input);

        this.popoverTarget = this.input;
        this.cavisibleCar = !this.cavisibleCar;
      } else {
        let bedeweightIDElem = document.getElementById("bedeweightID");
        bedeweightIDElem.setAttribute("type", "text");
        this.input = bedeweightIDElem.firstElementChild;
        this.input.setAttribute("readonly", "readonly");

        this.selectAllInput(this.input);

        this.popoverTarget = this.input;
        this.cavisible = !this.cavisible;
      }
      let name = ["{reverse} {clr} {backspace}", "7 8 9", "4 5 6", "1 2 3", "{zero} . {cancel}"];
      let meta = {
        "reverse": { func: "next", text: "＋/－"},
        "clr": { func: "accept", text: "CLR", classes: "control"},
        "backspace": { func: "backspace", classes: "control"},
        "zero": { key: "0"},
        "cancel": { func: "cancel", text: "確定", classes: "featured"}
      };
      let layoutparam = {default: name, _meta: meta};
      this.layout = layoutparam;
    },

    // テンキー用関数 accept: 全文字クリア
    accept() {
      if (this.isWheelChairMode) {
        // 入力前の値が"0.00"以外の場合、全文字クリア処理を2回行う
        if (document.getElementById("bedeCarID").value !== "0.00") this.doClearTwice = true;
      } else {
        // 入力前の値が"0.00"以外の場合、全文字クリア処理を2回行う
        if (document.getElementById("bedeweightID").value !== "0.00") this.doClearTwice = true;
      }

      this.clearValue();
      this.moveCursor();
    },

    // テンキー用関数 cancel: 画面テンキーを閉じる
    cancel() {
      if (this.isWheelChairMode) {
        document.getElementById("bedeCarPopOver").hide();
        this.cavisibleCar = false;
      } else {
        document.getElementById("bedeweightPopOver").hide();
        this.cavisible = false;
      }
    },

    // テンキー用関数 next: 正負反転
    next() {
      let reverseVal = 0;

      if (this.isWheelChairMode) {
        reverseVal = Number(document.getElementById("bedeCarID").value) * (-1);
        document.getElementById("bedeCarID").value = reverseVal.toFixed(2);
      } else {
        reverseVal = Number(document.getElementById("bedeweightID").value) * (-1);
        document.getElementById("bedeweightID").value = reverseVal.toFixed(2);
      }

      this.editMeasuredValue = reverseVal.toFixed(2);
      this.moveCursor();
    },

    // テンキー用関数 tenkeyClose: 画面テンキーを閉じた際の内部処理
    tenkeyClose() {
      const isPostHide = true;

      if (this.isWheelChairMode) {
        // 入力を番号に戻す
        document.getElementById("bedeCarID").setAttribute("type", "number");
        // 異常データの場合の初期化
        this.changeMeasureVal(this.editMeasuredValue, {target: document.getElementById("bedeCarID")}, isPostHide);
      } else {
        // 入力を番号に戻す
        document.getElementById("bedeweightID").setAttribute("type", "number");
        // 異常データの場合の初期化
        this.changeMeasureVal(this.editMeasuredValue, {target: document.getElementById("bedeweightID")}, isPostHide);
      }

      this.input = null;
    },

    // テンキー用内部関数 moveCursor: カーソル位置を右端にセットする
    moveCursor() {
      this.input.focus();
      this.input.setSelectionRange(10, 10);
    },
    // テンキー用内部関数 selectAllInput: 入力内容を全選択状態にする
    selectAllInput(inputElement) {
      inputElement.focus();
      inputElement.setSelectionRange(0, inputElement.value.length);
    },

    // テンキー用内部関数 clearValue: 測定値をクリアする
    clearValue() {
      this.input.value = null;
      this.editMeasuredValue = 0.00;
      if (this.isWheelChairMode) {
        this.changeWheelChairWeightValue(null).then(() => {
          // 体重値計算
          this.calcWeightValue();
        });
      } else {
        this.setMeasuredValue(null).then(() => {
          // 体重値計算
          this.calcWeightValue();
        });
      }
    },

    // add FNSI-体重計モードテンキーの追加 徐 end
    // テキストが未測定のときのみ中央揃え
    unmeasuredAlign(text) {
      if (text === "未測定") {
        return "text-align: center;";
      } else {
        return "";
      }
    },
    // テキストが未設定のときのみ中央揃え
    unsettingAlign(text) {
      if (text === "未設定") {
        return "text-align: center;";
      } else {
        return "";
      }
    },
  },
  watch: {},
  created() {
    // add FNSI-体重計画面 徐 start
    const queryParameters = this.getQueryParameters;
    if (Number(queryParameters.WEIGHTNO) > 0) {
      if (Number(queryParameters.MODE) == 1) {
        this.breadMode = false;
      }
    }
    // add FNSI-体重計画面 徐 end
    // 端末判別
    const ua = navigator.userAgent;
    if (ua.match(/Android/)) {
      this.isAndroid = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.isIOS = true;
    }

    // ストリーミングモード判定
    let deviceClass = null;
    if (this.getWeightConfigInfo !== undefined && this.getWeightConfigInfo !== null) {
        deviceClass = this.getWeightConfigInfo.deviceClass;
    }
    if (String(deviceClass) === "1") {
      this.deviceFlg = true;
    }
  },
  mounted() {
    // 体重値計算
    this.calcWeightValue();
    setTimeout(() => {
      this.addWheelEvent();
    }, 1000);
  },
  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  destroyed() { }
};
</script>
<style scoped>
.sub-content-area {
  display: flex;
  flex-direction: column;
  width: calc (100% - 110px);
  padding-left: 55px;
  margin-right: 55px;
}
.measure-value-row {
  text-align: center;
  justify-content: flex-start;
  margin-bottom: 5px;
}
.measure-value-row-border {
  border-top: 1px solid var(--ntss-border-color); 
}
.send-condition-before-value-label-row {
  text-align: center;
  justify-content: flex-start;
  margin-bottom: 5px;
}
.vertical-div {
  display: flex;
  flex-direction: column;
  align-content: flex-start;
}
/* add FNSI-体重計モードテンキーの追加 徐 start */
ons-input >>> .text-input {
  text-align: right;
  color: var(--send-cond-font-color) !important;
  background-color: var(--ntss-base-background-color) !important;
  opacity: 1 !important;
  height: 1.6em !important;
}
ons-input >>> input[type="text"] {
  padding-right: 15px;
}
.input-mobile >>> input[type="text"] {
  padding-right: 0px !important;
}
.popoverClass >>> .popover--top {
  width: auto;
}
/* add FNSI-体重計画面 徐 start */
.send-condition-lbl {
  font-weight: bold;
  font-size: 1.5em;
}
.line-dashed {
  width: 70px;
  height: 0px;
  line-height: 30px;
  background-color: rgb(255, 255, 255);
  color: rgb(0, 0, 0);
  position: relative;
  top: -35px;
  left: 30px;
  font-size: 1em;
  font-weight: bold;
}
.line-table {
  font-size: 1em;
  font-weight: bold;
}
td {
  white-space: nowrap;
}
.wrapper-water-removal-target {
  display: flex;
}
.water-removal-target {
  display: flex;
  align-items: center;
}
/* add FNSI-体重計画面 徐 end */
/* add FNSI-体重計モードテンキーの追加 徐 end */
@media print {
  .send-condition-before-measure-value-block{
    min-width: 0 !important;
  }
}
</style>
