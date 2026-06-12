
/**
 * 条件送信後体重詳細画面
 */
<template>
  <div class="sub-content-area ntss-send-condition-text">
    <div class="send-condition-after-measure-value-block main-block" :class="[deviceFlg ? 'streaming-mode' : '']">
      <div class="send-condition-after-measure-value-main-block">
        <!-- 1行目 -->
        <v-ons-row class="measure-value-row">
          <!-- 1-1 測定値 -->
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-after-detail-lbl">測定値</label>
            <!-- 体重/体重+車いす -->
            <template v-if="!isWheelChairMode">
              <div>
                <CustomInputNumberPro
                  id="afdeweightID"
                  ref="afdeweightInputRef"
                  class="send-condition-after-input"
                  :empty-val="null"
                  :value-modifiers="{ lazy: true }"
                  :value="editMeasuredValue"
                  :min="numberMin"
                  :max="numberMax"
                  :step="numberStep"
                  :roll-flag="true"
                  @handler-input="onAfdeweightHandlerInput"
                  @blur="onAfdeweightBlur"
                />
                <label class="send-condition-unit send-condition-after-unit"> kg
                  <img height="26px" :src="image_src" @click="show"/>
                </label>
              </div>
            </template>
            <!-- 車いす -->
            <template v-else>
              <label class="send-condition-after-value-label" :style="unmeasuredAlign(getMeasuredInfo.text)">{{getMeasuredInfo.text}}</label>
            </template>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center">
            <h4 class="send-condition-after-symbol">－</h4>
          </v-ons-col>

          <!-- 1-2 風袋 -->
          <v-ons-col :width="labelWidth" class="vertical-div">
            <v-ons-button class="send-condition-after-detail-btn btn3-normal" @click="showModal(1)">風袋</v-ons-button>
            <label class="send-condition-after-value-label">{{taraValue}}</label>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center" v-show="getIsWheelchair">
            <h4 class="send-condition-after-symbol">－</h4>
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
                <CustomInputNumberPro
                  id="afdeCarID"
                  ref="afdeCarInputRef"
                  class="send-condition-after-input"
                  :empty-val="null"
                  :value-modifiers="{ lazy: true }"
                  :value="editMeasuredValue"
                  :min="numberMin"
                  :max="numberMax"
                  :step="numberStep"
                  :roll-flag="true"
                  @handler-input="onAfdeweightHandlerInput"
                  @blur="onAfdeweightBlur"
                />
                <label class="send-condition-unit send-condition-after-unit"> kg
                  <img height="26px" :src="image_src" @click="show"/>
                </label>
              </div>
            </template>
            <template v-else>
              <label class="send-condition-after-value-label" :style="unmeasuredAlign(getSelectWheelchairWeight)">{{getSelectWheelchairWeight}}</label>
            </template>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center">
            <h4 class="send-condition-after-symbol">＝</h4>
          </v-ons-col>

          <!-- 1-4 後体重 -->
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-after-detail-lbl">後体重</label>
            <label class="send-condition-after-value-label">{{afterWeightValue}}</label>
          </v-ons-col>
          <v-ons-col />
        </v-ons-row>

        <!-- 1行目 電卓ボタン -->
        <div>
          <v-ons-popover
            cancelable
            id="afdeweightPopOver"
            v-model:visible="cavisible"
            :target="popoverTarget"
            direction="down"
            class="popoverClass"
            @posthide="tenkeyClose">
            <vue-touch-keyboard :options="options" :layout="layout" :next="next" :cancel="cancel" :accept="accept" :input="input" :change="change"/>
          </v-ons-popover>
        </div>
        <div>
          <v-ons-popover
            cancelable
            id="afdeCarPopOver"
            v-model:visible="cavisibleCar"
            :target="popoverTarget"
            direction="down"
            class="popoverClass"
            @posthide="tenkeyClose">
            <vue-touch-keyboard :options="options" :layout="layout" :next="next" :cancel="cancel" :accept="accept" :input="input" :change="change" style="float:right"/>
          </v-ons-popover>
        </div>

        <!-- 2行目 -->
        <v-ons-row class="weight-value-row">
          <!-- 2-1 前体重 -->
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-after-detail-lbl">前体重</label>
            <label class="send-condition-after-value-label">{{getBeforeWeightValue.text}}</label>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center">
            <h4 class="send-condition-after-symbol">－</h4>
          </v-ons-col>

          <!-- 2-2 後体重 -->
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-after-detail-lbl">後体重</label>
            <label class="send-condition-after-value-label">{{afterWeightValue}}</label>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center">
            <h4 class="send-condition-after-symbol">＝</h4>
          </v-ons-col>

          <!-- 2-3 除水量 -->
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-after-detail-lbl">除水量</label>
            <label class="send-condition-after-value-label">{{waterRemoval}}</label>
          </v-ons-col>
          <v-ons-col />
        </v-ons-row>
      </div>
    </div>

    <div class="send-condition-after-measure-value-block" :class="[deviceFlg ? 'streaming-mode' : '']">
      <div class="send-condition-after-measure-value-sub-block" :class="[deviceFlg ? 'streaming-mode' : '']">
        <v-ons-row class="measure-value-row measure-value-row-border">
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-after-detail-lbl">前体重</label>
            <label class="send-condition-after-value-label">{{getBeforeWeightValue.text}}</label>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center">
            <h4 class="send-condition-after-symbol">＋</h4>
          </v-ons-col>
          <v-ons-col :width="labelWidth" class="vertical-div vertical-div-margin">
            <v-ons-button class="send-condition-after-detail-btn btn3-normal" @click="showModal(0)">除水補正</v-ons-button>
            <label class="send-condition-after-value-label">{{waterValue}}</label>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center">
            <h4 class="send-condition-after-symbol">－</h4>
          </v-ons-col>
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-after-detail-lbl">後体重</label>
            <label class="send-condition-after-value-label">{{afterWeightValue}}</label>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center">
            <h4 class="send-condition-after-symbol">－</h4>
          </v-ons-col>
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-after-detail-lbl">除水積算</label>
            <label class="send-condition-after-value-label">{{getDewateringIntegration.text}}</label>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center">
            <h4 class="send-condition-after-symbol">＝</h4>
          </v-ons-col>
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-after-detail-lbl">誤差</label>
            <label class="send-condition-after-value-label">{{errorWeight}}</label>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row class="measure-value-row">
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-after-detail-lbl">後体重</label>
            <label class="send-condition-after-value-label">{{afterWeightValue}}</label>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center">
            <h4 class="send-condition-after-symbol">－</h4>
          </v-ons-col>
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-after-detail-lbl">目標体重</label>
            <label class="send-condition-after-value-label" :style="unsettingAlign(getIndTargetWeight.text)">{{getIndTargetWeight.text}}</label>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center">
            <h4 class="send-condition-after-symbol">＝</h4>
          </v-ons-col>
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-after-detail-lbl">引き残し</label>
            <label class="send-condition-after-value-label">{{leaveBehind1}}</label>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center"></v-ons-col>
          <v-ons-col :width="labelWidth" class="vertical-div ihdf-dev" v-if="getPullLeaveAmount.show">
            <label class="send-condition-after-detail-lbl">I-HDF残</label>
            <label class="send-condition-after-value-label">{{ihdfPullLeaveValue}} kg</label>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row class="measure-value-row">
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-after-detail-lbl">後体重</label>
            <label class="send-condition-after-value-label">{{afterWeightValue}}</label>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center">
            <h4 class="send-condition-after-symbol">－</h4>
          </v-ons-col>
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-after-detail-lbl">DW</label>
            <label class="send-condition-after-value-label" :style="unsettingAlign(getIndDryWeight.text)">{{getIndDryWeight.text}}</label>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center">
            <h4 class="send-condition-after-symbol">＝</h4>
          </v-ons-col>
          <v-ons-col :width="labelWidth" class="vertical-div">
            <label class="send-condition-after-detail-lbl">引き残し</label>
            <label class="send-condition-after-value-label">{{leaveBehind2}}</label>
          </v-ons-col>
          <v-ons-col :width="symbolWidth" vertical-align="center"></v-ons-col>
          <v-ons-col :width="labelWidth" class="vertical-div ihdf-dev" v-if="getPullLeaveAmount.show">
            <label class="send-condition-after-detail-lbl">I-HDF残</label>
            <label class="send-condition-after-value-label">{{ihdfPullLeaveValue}} kg</label>
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
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import BigNumber from "@/compat/number/bignumber";
import { weightScaleMode } from "@/constants/weightDefine";
import MasterSelector from "@/components/common/master-selector/MasterSelector";
// add FNSI-体重計モードテンキーの追加 徐 start
// add FNSI-体重計モードテンキーの追加 徐 end
// add 画面印刷プレビューと印刷の実現 陳 start
import { getCurrentFunctionCd } from "@/router/routing-helper";
// add 画面印刷プレビューと印刷の実現 陳 end
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
import TouchKeyboard from "@/compat/keyboard/TouchKeyboard.vue";
import CustomInputNumberPro from "@/components/common/custom-form-tags/CustomInputNumberPro.vue";
import { getScopedElementById, getScopedUserAgent } from "@/functions/common/LayoutMeasureHelper";
import { publicAssetPath } from "@/compat/assets/public-path";
import dayjs from "@/compat/date/dayjs";
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end

export default {

  components: {
    "pop-over": MasterSelector,
    // add FNSI-体重計モードテンキーの追加 徐 start
    "vue-touch-keyboard": TouchKeyboard,
    CustomInputNumberPro
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
      image_src: publicAssetPath("img/keyboard/keyboard.png"),
      popoverTarget: null,
      // add FNSI-体重計モードテンキーの追加 徐 end
      // mod #8160 2022/12/06 体重測定の測定値が見切れる dou start
      // labelWidth: "12.5em", // ラベル部の長さ
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
      "getBeforeWeightValue",
      "getIndTargetWeight",
      "getIndDryWeight",
      "getDewateringIntegration",
      "getOffWaterWeight",
      "getPullLeaveAmount"
    ]),
    ...mapGetters("send-condition/scale/setting", ["getWheelChairList", "getWeightConfigInfo"]),
    ...mapGetters("pat-info", ["selectedPatId", "selectedPatName"]),
    // add FNSI-体重計モードテンキーの追加 徐 start
    ...mapGetters("send-condition/weight", ["getWeightMode"]),
    // add FNSI-体重計モードテンキーの追加 徐 end
    isWheelChairMode: {
      get() {
        // add FNSI-体重計モードテンキーの追加 徐 start
        this.cavisible = false;
        this.cavisibleCar = false;
        // add FNSI-体重計モードテンキーの追加 徐 end
        setTimeout(() => {
          this.addWheelEvent();
        }, 500);
        return this.getScaleMode === weightScaleMode.wheelChair;
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
    // 前体重
    afterWeightValue: {
      get() {
        let value = Number(this.getBodyWeightInfo.value);
        if (value < 0) {
          return `－${(value * -1).toFixed(2)} kg`;
        } else {
          return `${value.toFixed(2)} kg`;
        }
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
    // 除水量[前体重 - 後体重]
    waterRemoval: {
      get() {
        if (
          this.getBeforeWeightValue.value !== null &&
          this.getBodyWeightInfo.value !== null
        ) {
          let value = Number(new BigNumber(this.getBeforeWeightValue.value).minus(this.getBodyWeightInfo.value));
          console.log("除水量[前体重: %o - 後体重: %o] = %o", this.getBeforeWeightValue.value, this.getBodyWeightInfo.value, value);
          if (Number.isNaN(value)) {
            return null;
          }
          if (value < 0) {
            return `－${(value * -1).toFixed(2)} kg`;
          } else {
            return `${value.toFixed(2)} kg`;
          }
          // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 start
          // return `${Number(
          //   new BigNumber(this.getBeforeWeightValue).minus(
          //     this.getBodyWeightInfo.value
          //   )
          // )} kg`;
          // return `${Number(
          //   new BigNumber(this.getBeforeWeightValue).minus(
          //     this.getBodyWeightInfo.value
          //   )
          // ).toFixed(2)} kg`;
          // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 end
        } else {
          return null;
        }
      }
    },
    // 誤差[前体重 + 除水補正 - 後体重 - 除水積算]
    errorWeight: {
      get() {
        let retVal = this.getOffWaterWeight;
        retVal = Number(new BigNumber(this.getBeforeWeightValue.value).plus(retVal));
        retVal = Number(
          new BigNumber(retVal).minus(this.getBodyWeightInfo.value)
        );
        const returnValue = Number(
          new BigNumber(retVal).minus(this.getDewateringIntegration.value)
        );
        console.log(
          "誤差[前体重: %o + 除水補正: %o - 後体重: %o - 除水積算: %o] = %o",
          this.getBeforeWeightValue.value,
          this.getOffWaterWeight,
          this.getBodyWeightInfo.value,
          this.getDewateringIntegration.value,
          returnValue);
        if (isNaN(returnValue)) {
          return null;
        }
        if (returnValue < 0) {
          return `－${(returnValue * -1).toFixed(2)} kg`;
        } else {
          return `${returnValue.toFixed(2)} kg`;
        }
        // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 start
        // return `${returnValue} kg`;
        // return `${Number(returnValue).toFixed(2)} kg`;
        // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 end
      }
    },
    // 引き残し1[後体重 - 目標体重]
    leaveBehind1: {
      get() {
        if (
          this.getIndTargetWeight.value !== null &&
          this.getBodyWeightInfo.value !== null
        ) {
          let value = Number(new BigNumber(this.getBodyWeightInfo.value).minus(this.getIndTargetWeight.value));
          if (value < 0) {
            return `－${(value * -1).toFixed(2)} kg`;
          } else {
            return `${value.toFixed(2)} kg`;
          }
          // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 start
          // return `${Number(
          //   new BigNumber(this.getBodyWeightInfo.value).minus(
          //     this.getIndTargetWeight.value
          //   )
          // )} kg`;
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
    // 引き残し[後体重 - DW]
    leaveBehind2: {
      get() {
        if (
          this.getIndDryWeight.value !== null &&
          this.getBodyWeightInfo.value !== null
        ) {
          let value = Number(new BigNumber(this.getBodyWeightInfo.value).minus(this.getIndDryWeight.value));
          if (value < 0) {
            return `－${(value * -1).toFixed(2)} kg`;
          } else {
            return `${value.toFixed(2)} kg`;
          }
          // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 start
          // return `${Number(
          //   new BigNumber(this.getBodyWeightInfo.value).minus(
          //     this.getIndDryWeight.value
          //   )
          // )} kg`;
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
    // I-HDF引き残し
    ihdfPullLeaveValue: {
      get() {
        return Number(this.getPullLeaveAmount.value).toFixed(2);
      }
    },
    wheelChairButtonClass() {
      const calibrationCheck = this.getSelectWheelchair.calibrationCheck;

      if (calibrationCheck) {
        return [
          "send-condition-after-detail-btn",
          "btn3-normal",
          "button"
        ];
      } else {
        return [
          "send-condition-after-detail-btn",
          "btn4-alert",
          "button"
        ];
      }
    },
  },
  methods: {
    getSendConditionElementById(id) {
      return getScopedElementById(id, this.$el || null);
    },
    resolveMeasureInputElement(id) {
      const refById = {
        afdeweightID: "afdeweightInputRef",
        afdeCarID: "afdeCarInputRef",
      };
      const refName = refById[id];
      const fromRef = refName ? this.$refs[refName]?.$refs?.input : null;
      const element = fromRef || this.getSendConditionElementById(id);
      if (!element) {
        return null;
      }
      const tagName = element.tagName?.toUpperCase?.() || "";
      if (tagName === "INPUT" || tagName === "TEXTAREA") {
        return element;
      }
      return element.querySelector?.("input, textarea") || element.firstElementChild || element;
    },
    onAfdeweightHandlerInput(val) {
      this.editMeasuredValue = val;
    },
    onAfdeweightBlur(event) {
      this.changeMeasureVal(this.editMeasuredValue, event, false);
    },

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
    // add 画面印刷プレビューと印刷の実現 陳 start
    requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        // 機能一致
        // 印刷パラメータを応答
        const param = {
          facilityCd: this.getFacilityCd,
          patId: this.selectedPatId,
          date: dayjs(Date.now()).format("YYYY/MM/DD")
        };
        EventBus.$emit("sendReportParams", param);
      }
    },
    // add 画面印刷プレビューと印刷の実現 陳 end
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
      let afdeweightIdElem = this.resolveMeasureInputElement("afdeweightID");
      if (afdeweightIdElem) {
        // 数値入力欄に'wheel'のイベントリスナーを設定することで
        // ホイールを使ったマウスホイールによる数値変更が可能。
        // 関数の内容は問わないため何もしない関数を指定。
        afdeweightIdElem.addEventListener('wheel', () => {});
        if (this.isIOS || this.isAndroid) {
          afdeweightIdElem?.classList?.add('input-mobile');
        }
    }
      let afdeCarIdElem = this.resolveMeasureInputElement("afdeCarID");
      if (afdeCarIdElem) {
        afdeCarIdElem.addEventListener('wheel', () => {});
        if (this.isIOS || this.isAndroid) {
          afdeCarIdElem?.classList?.add('input-mobile');
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
        let afdeCarIDElem = this.resolveMeasureInputElement("afdeCarID");
        if (!afdeCarIDElem) {
          return;
        }
        afdeCarIDElem.setAttribute("type", "text");
        this.input = afdeCarIDElem;
        this.input.setAttribute("readonly", "readonly");

        this.selectAllInput(this.input);

        this.popoverTarget = this.input;
        this.cavisibleCar = !this.cavisibleCar;
      } else {
        let afdeweightIDElem = this.resolveMeasureInputElement("afdeweightID");
        if (!afdeweightIDElem) {
          return;
        }
        afdeweightIDElem.setAttribute("type", "text");
        this.input = afdeweightIDElem;
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
        if (this.resolveMeasureInputElement("afdeCarID")?.value !== "0.00") this.doClearTwice = true;
      } else {
        // 入力前の値が"0.00"以外の場合、全文字クリア処理を2回行う
        if (this.resolveMeasureInputElement("afdeweightID")?.value !== "0.00") this.doClearTwice = true;
      }

      this.clearValue();
      this.moveCursor();
    },

    // テンキー用関数 cancel: 画面テンキーを閉じる
    cancel() {
      if (this.isWheelChairMode) {
        this.getSendConditionElementById("afdeCarPopOver")?.hide?.();
        this.cavisibleCar = false;
      } else {
        this.getSendConditionElementById("afdeweightPopOver")?.hide?.();
        this.cavisible = false;
      }
    },

    // テンキー用関数 next: 正負反転
    next() {
      let reverseVal = 0;

      if (this.isWheelChairMode) {
        const afdeCarInput = this.resolveMeasureInputElement("afdeCarID");
        reverseVal = Number(afdeCarInput?.value) * (-1);
        if (afdeCarInput) {
          afdeCarInput.value = reverseVal.toFixed(2);
        }
      } else {
        const afdeweightInput = this.resolveMeasureInputElement("afdeweightID");
        reverseVal = Number(afdeweightInput?.value) * (-1);
        if (afdeweightInput) {
          afdeweightInput.value = reverseVal.toFixed(2);
        }
      }

      this.editMeasuredValue = reverseVal.toFixed(2);
      this.moveCursor();
    },

    // テンキー用関数 tenkeyClose: 画面テンキーを閉じた際の内部処理
    tenkeyClose() {
      const isPostHide = true;

      if (this.isWheelChairMode) {
        // 入力を番号に戻す
        const afdeCarInput = this.resolveMeasureInputElement("afdeCarID");
        afdeCarInput?.setAttribute("type", "number");
        // 異常データの場合の初期化
        this.changeMeasureVal(this.editMeasuredValue, {target: afdeCarInput}, isPostHide);
      } else {
        // 入力を番号に戻す
        const afdeweightInput = this.resolveMeasureInputElement("afdeweightID");
        afdeweightInput?.setAttribute("type", "number");
        // 異常データの場合の初期化
        this.changeMeasureVal(this.editMeasuredValue, {target: afdeweightInput}, isPostHide);
      }

      this.input = null;
    },

    // テンキー用内部関数 moveCursor: カーソル位置を右端にセットする
    moveCursor() {
      this.input.focus();
      this.input.setSelectionRange(10, 10);

      let s = this.input.selectionStart;
      let e = this.input.selectionEnd;
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
  created() {
    // add 画面印刷プレビューと印刷の実現 陳 start
    // 印刷パラメータ要求
    // add 性能改善メモリ不足 shan start
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // add 性能改善メモリ不足 shan end
    EventBus.$on("requestReportParams", this.requestrReportParams);
    // add 画面印刷プレビューと印刷の実現 陳 end
    // 端末判別
    const ua = getScopedUserAgent(this.$el || null);
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
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    EventBus.$off("requestReportParams", this.requestrReportParams);
    
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
  // add 性能改善メモリ不足 shan end
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
.weight-value-row {
  text-align: center;
  justify-content: flex-start;
  margin-bottom: 5px;
}
.vertical-div {
  display: flex;
  flex-direction: column;
  align-content: flex-start;
}
.vertical-div-margin {
  margin-top: 5px;
}
 
/* add FNSI-体重計モードテンキーの追加 徐 start */
ons-input :deep(.text-input) {
  text-align: right;
  color: var(--send-cond-font-color) !important;
  background-color: var(--ntss-base-background-color) !important;
  opacity: 1 !important;
  height: 1.6em !important;
}
ons-input :deep(input[type="text"]) {
  padding-right: 15px;
}
.input-mobile :deep(input[type="text"]) {
  padding-right: 0px !important;
}
.popoverClass :deep(.popover--top) {
  width: auto;
}
/* add FNSI-体重計モードテンキーの追加 徐 end */
@media print {
  .send-condition-after-measure-value-block{
    min-width: 0 !important;
  }
}
</style>
