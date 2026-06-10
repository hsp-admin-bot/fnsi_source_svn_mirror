<template>
  <div
    v-if="deviceSetInfo !== null"
    :class="showButton ? 'device-info-container' : null"
  >
    <div class="device-info-content" :class="isUnderIndModal">
      <div class="device-info-content-area">
        <!-- ヘッダ -->
        <v-ons-row
          v-if="showButton"
          class="common-style-header device-info-main-title"
        >
          <!-- add FNSI-FutreNetWeb+SI課題管理No.5246 李 start -->
          <!-- ＢＶ‐ＵＦＣ -->
          BV‐UFC
          <!-- add FNSI-FutreNetWeb+SI課題管理No.5246 李 end -->
        </v-ons-row>
        <v-ons-row v-else class="device-info-main-title" />
        <div class="device-info-main-content">
          <div class="margin-area">
            <div class="scroll-area">
              <div class="display-area">
                <!-- 項目 -->
                <v-ons-row class="bv-ufc-row">
                  <v-ons-col>
                    {{ devA[196].formLabel }}
                  </v-ons-col>
                  <v-ons-col>
                    <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
                    <!-- <device-radio
                      ref="radio1"
                      :device-info="devA[196]"
                      :disabled="isTreatRecord"
                      @change="changeButton(false)"
                    /> -->
                    <!-- mod #10359 編集権限の動作不正 dengshen start -->
                    <!-- <device-radio -->
                    <!--   ref="radio1" -->
                    <!--   :device-info="devA[196]" -->
                    <!--   :disabled="isTreatRecord" -->
                    <!-- /> -->
                    <device-radio
                      ref="radio1"
                      :device-info="devA[196]"
                      :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                    />
                    <!-- mod #10359 編集権限の動作不正 dengshenend -->
                    <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
                  </v-ons-col>
                </v-ons-row>

                <v-ons-row class="bv-ufc-row">
                  <v-ons-col
                    v-for="(dispLabel, index) in timeInfoLabel"
                    :key="index"
                  >
                    <div
                      class="bv-ufc-time-label"
                      :style="dispLabeltimeInfoLabelColor(index)"
                    >
                      {{ dispLabel }}
                    </div>
                  </v-ons-col>
                </v-ons-row>

                <v-ons-row class="bv-ufc-row bv-ufc-time-row">
                  <v-ons-col>
                    時間
                  </v-ons-col>
                  <v-ons-col v-for="(eleInfo, index) in timeInfo" :key="index" style="text-align: left;">
                    <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
                    <!-- <device-input-number
                      v-if="2 !== index"
                      :ref="`required_${index}`"
                      :device-info="eleInfo"
                      :disabled="isTreatRecord"
                      style="margin-left: 0.7em;"
                      @change="changeButton(false)"
                      @input="setInputNumberChange"
                      @wheel.prevent="setInputNumberChange"
                      @keydown.up.prevent="setInputNumberChange"
                      @keydown.down.prevent="setInputNumberChange"
                    /> -->
                    <!-- mod #10359 編集権限の動作不正 dengshen start -->
                    <!-- <device-input-number -->
                    <!--   v-if="2 !== index" -->
                    <!--   :ref="`required_${index}`" -->
                    <!--   :device-info="eleInfo" -->
                    <!--   :disabled="isTreatRecord" -->
                    <!--   style="margin-left: 0.7em;" -->
                    <!--   @input="setInputNumberChange" -->
                    <!--   @wheel.prevent="setInputNumberChange" -->
                    <!--   @keydown.up.prevent="setInputNumberChange" -->
                    <!--   @keydown.down.prevent="setInputNumberChange" -->
                    <!-- /> -->
                    <device-input-number
                      v-if="2 !== index"
                      :ref="`required_${index}`"
                      :device-info="eleInfo"
                      :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                      style="margin-left: 0.7em;"
                      @input="setInputNumberChange"
                      @wheel.prevent="setInputNumberChange"
                      @keydown.up.prevent="setInputNumberChange"
                      @keydown.down.prevent="setInputNumberChange"
                    />
                    <!-- mod #10359 編集権限の動作不正 dengshenend -->
                    <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
                    <label style="margin-left: 0.7em;" v-else>
                      {{ eleInfo }}
                    </label>
                  </v-ons-col>
                </v-ons-row>

                <!-- mod FNSI-FutreNetWeb+SI課題管理No.5246 李 start -->
                    <v-ons-row class="bv-ufc-row">
                      <!-- <v-ons-col /> -->
                      <v-ons-col></v-ons-col>
                      <v-ons-col
                        v-for="(diameterInfo, index) in speedDiameterInfo"
                        :key="index"
                        style="text-align: left;"
                      >
                        <label v-if="1 >= index">×</label>
                        <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
                        <!-- <device-input-number
                          v-if="3 !== index"
                          :ref="`required_${index + timeInfo.length}`"
                          :device-info="diameterInfo"
                          :disabled="isTreatRecord"
                          :style="1 < index ? { 'margin-left': '0.7em' } : ''"
                          @change="changeButton(false)"
                          @input="setInputNumberChange"
                          @wheel.prevent="setInputNumberChange"
                          @keydown.up.prevent="setInputNumberChange"
                          @keydown.down.prevent="setInputNumberChange"
                        /> -->
                        <!-- mod #10359 編集権限の動作不正 dengshen start -->
                        <!-- <device-input-number -->
                        <!--   v-if="3 !== index" -->
                        <!--   :ref="`required_${index + timeInfo.length}`" -->
                        <!--   :device-info="diameterInfo" -->
                        <!--   :disabled="isTreatRecord" -->
                        <!--   :style="1 < index ? { 'margin-left': '0.7em' } : ''" -->
                        <!--   @input="setInputNumberChange" -->
                        <!--   @wheel.prevent="setInputNumberChange" -->
                        <!--   @keydown.up.prevent="setInputNumberChange" -->
                        <!--   @keydown.down.prevent="setInputNumberChange" -->
                        <!-- /> -->
                        <device-input-number
                          v-if="3 !== index"
                          :ref="`required_${index + timeInfo.length}`"
                          :device-info="diameterInfo"
                          :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                          :style="1 < index ? { 'margin-left': '0.7em' } : ''"
                          @input="setInputNumberChange"
                          @wheel.prevent="setInputNumberChange"
                          @keydown.up.prevent="setInputNumberChange"
                          @keydown.down.prevent="setInputNumberChange"
                        />
                        <!-- mod #10359 編集権限の動作不正 dengshenend -->
                        <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
                        <label v-else>
                          {{ diameterInfo }}
                        </label>
                      </v-ons-col>
                    </v-ons-row>
                    <label style="margin-left: 6%">除水速度</label>
                    <!-- 一時的にコメントアウト TODO: いらなくなる可能性大 -->
                    <!-- <v-ons-row class="bv-ufc-row">
                      <v-ons-col>除水速度</v-ons-col>
                      <v-ons-col>1.00L/h</v-ons-col>
                      <v-ons-col>1.50L/h</v-ons-col>
                      <v-ons-col>1.10L/h</v-ons-col>
                      <v-ons-col>---</v-ons-col>
                    </v-ons-row> -->
                    <v-ons-row class="bv-ufc-row bv-ufc-time-rowcopy" >
                      <v-ons-col></v-ons-col>
                      <v-ons-col
                        v-for="(eleInfo, index) in lowerSpeedDiameterInfo"
                        :key="index"
                        style="text-align: left;"
                      >
                        <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
                        <!-- <device-input-number
                          v-if="'' !== eleInfo"
                          :ref="
                            `required_${timeInfo.length + speedDiameterInfo.length}`
                          "
                          :device-info="eleInfo"
                          :disabled="isTreatRecord"
                          style="margin-left: 0.7em;"
                          @change="changeButton(false)"
                          @input="setInputNumberChange"
                          @wheel.prevent="setInputNumberChange"
                          @keydown.up.prevent="setInputNumberChange"
                          @keydown.down.prevent="setInputNumberChange"
                        /> -->
                        <!-- mod #10359 編集権限の動作不正 dengshen start -->
                        <!-- <device-input-number -->
                        <!--   v-if="'' !== eleInfo" -->
                        <!--   :ref=" -->
                        <!--     `required_${timeInfo.length + speedDiameterInfo.length}` -->
                        <!--   " -->
                        <!--   :device-info="eleInfo" -->
                        <!--   :disabled="isTreatRecord" -->
                        <!--   style="margin-left: 0.7em;" -->
                        <!--   @input="setInputNumberChange" -->
                        <!--   @wheel.prevent="setInputNumberChange" -->
                        <!--   @keydown.up.prevent="setInputNumberChange" -->
                        <!--   @keydown.down.prevent="setInputNumberChange" -->
                        <!-- /> -->
                        <device-input-number
                          v-if="'' !== eleInfo"
                          :ref="
                            `required_${timeInfo.length + speedDiameterInfo.length}`
                          "
                          :device-info="eleInfo"
                          :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                          style="margin-left: 0.7em;"
                          @input="setInputNumberChange"
                          @wheel.prevent="setInputNumberChange"
                          @keydown.up.prevent="setInputNumberChange"
                          @keydown.down.prevent="setInputNumberChange"
                        />
                        <!-- mod #10359 編集権限の動作不正 dengshenend -->
                        <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
                        <label v-else>{{ eleInfo }}</label>
                      </v-ons-col>
                    </v-ons-row>
                <!-- mod FNSI-FutreNetWeb+SI課題管理No.5246 李 end -->

                <!-- 一時的にコメントアウト TODO: いらなくなる可能性大 -->
                <!-- <v-ons-row>
            <v-ons-col>
              除水量
            </v-ons-col>
            <v-ons-col>
              3.00 / 4.00 L
            </v-ons-col>
          </v-ons-row> -->
                <v-ons-row>
                  <v-ons-col
                    v-for="(dispLabel, index) in bvBaseInfoLabel"
                    :key="index"
                  >
                    {{ dispLabel }}
                  </v-ons-col>
                </v-ons-row>

                 <v-ons-row>
                  <v-ons-col
                    v-for="(eleInfo, index) in bvBaseInfo"
                    :key="index"
                  >
                    <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
                    <!-- <device-input-number
                      :ref="
                        `required_${index +
                          timeInfo.length +
                          speedDiameterInfo.length +
                          endCondInfo.length +
                          1}`
                      "
                      :device-info="eleInfo"
                      :disabled="isTreatRecord"
                      @change="changeButton(false)"
                      @input="setInputNumberChange"
                      @wheel.prevent="setInputNumberChange"
                      @keydown.up.prevent="setInputNumberChange"
                      @keydown.down.prevent="setInputNumberChange"
                    /> -->
                    <!-- mod #10359 編集権限の動作不正 dengshen start -->
                    <!-- <device-input-number -->
                    <!--   :ref=" -->
                    <!--     `required_${index + -->
                    <!--       timeInfo.length + -->
                    <!--       speedDiameterInfo.length + -->
                    <!--       endCondInfo.length + -->
                    <!--       1}` -->
                    <!--   " -->
                    <!--   :device-info="eleInfo" -->
                    <!--   :disabled="isTreatRecord" -->
                    <!--   @input="setInputNumberChange" -->
                    <!--   @wheel.prevent="setInputNumberChange" -->
                    <!--   @keydown.up.prevent="setInputNumberChange" -->
                    <!--   @keydown.down.prevent="setInputNumberChange" -->
                    <!-- /> -->
                    <device-input-number
                      :ref="
                        `required_${index +
                          timeInfo.length +
                          speedDiameterInfo.length +
                          endCondInfo.length +
                          1}`
                      "
                      :device-info="eleInfo"
                      :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                      @input="setInputNumberChange"
                      @wheel.prevent="setInputNumberChange"
                      @keydown.up.prevent="setInputNumberChange"
                      @keydown.down.prevent="setInputNumberChange"
                    />
                    <!-- mod #10359 編集権限の動作不正 dengshenend -->
                    <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
                  </v-ons-col>
                </v-ons-row>
                <div class="end-cond-info">
                  <v-ons-row class="bv-ufc-row">
                    <v-ons-col>固定倍率除水終了条件</v-ons-col>
                  </v-ons-row>
                  <v-ons-row>
                    <v-ons-col
                      v-for="(dispLabel, index) in endCondInfoLabel"
                      :key="index"
                    >
                      {{ dispLabel }}
                    </v-ons-col>
                  </v-ons-row>

                  <v-ons-row>
                    <v-ons-col
                      v-for="(eleInfo, index) in endCondInfo"
                      :key="index"
                    >
                    <!-- mod FNSI-6783 劉全航 start -->
                      <span class="device-input-number" v-if="eleInfo.formName.includes('ΔBV')">
                        <!-- mod #5589 2023/04/19 数値IFのスタイル全不正 林峻峰 start -->
                        <!-- <v-ons-input
                          type="number"
                          v-model="eleInfo.value.editValue"
                          @blur="inputValidValue($event,eleInfo)"
                          :disabled="isTreatRecord"
                          @change="changeButton(false)"
                          :class="classObject(eleInfo)"
                          @input="setInputNumberChange"
                          @wheel.prevent="setInputNumberChange"
                          @keydown.up.prevent="setInputNumberChange"
                          @keydown.down.prevent="setInputNumberChange"
                        /> -->
                        <!-- mod #10359 編集権限の動作不正 dengshen start -->
                        <!-- <v-ons-input -->
                        <!--   type="number" -->
                        <!--   :step="eleInfo.step" -->
                        <!--   v-model="eleInfo.value.editValue" -->
                        <!--   @blur="inputValidValue($event,eleInfo)" -->
                        <!--   :disabled="isTreatRecord" -->
                        <!--   @change="inputNumber($event,eleInfo)" -->
                        <!--   :class="classObject(eleInfo)" -->
                        <!--   @input="setInputNumberChange" -->
                        <!--   @wheel.prevent="onMouseWheel($event,eleInfo)" -->
                        <!--   @keydown.up.prevent="setInputNumberChange" -->
                        <!--   @keydown.down.prevent="setInputNumberChange" -->
                        <!-- /> -->
                        <!--mod #11120 I-HDF設定内の破棄確認メッセージ不正 張玲 start-->
                        <!-- <v-ons-input
                          type="number"
                          :step="eleInfo.step"
                          v-model="eleInfo.value.editValue"
                          @blur="inputValidValue($event,eleInfo)"
                          :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority')"
                          @change="inputNumber($event,eleInfo)"
                          :class="classObject(eleInfo)"
                          @input="setInputNumberChange"
                          @wheel.prevent="onMouseWheel($event,eleInfo)"
                          @keydown.up.prevent="setInputNumberChange"
                          @keydown.down.prevent="setInputNumberChange"
                        />
                          {{eleInfo.unitName}}
                        -->
                        <device-input-number
                          :ref="
                          `required_${index +
                            timeInfo.length +
                            speedDiameterInfo.length +
                            1}`
                          "
                          :device-info="eleInfo"
                          :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                          @input="setInputNumberChange"
                        />
                        <!--mod #11120 I-HDF設定内の破棄確認メッセージ不正 張玲 end-->
                        <!-- mod #10359 編集権限の動作不正 dengshenend -->
                        <!-- mod #5589 2023/04/19 数値IFのスタイル全不正 林峻峰 end -->
                      </span>
                      <!-- mod FNSI-6783 劉全航 end -->
                      <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
                      <!-- <device-input-number
                        v-else
                        :ref="
                          `required_${index +
                            timeInfo.length +
                            speedDiameterInfo.length +
                            1}`
                        "
                        :device-info="eleInfo"
                        :disabled="isTreatRecord"
                        @change="changeButton(false)"
                        @input="setInputNumberChange"
                        @wheel.prevent="setInputNumberChange"
                        @keydown.up.prevent="setInputNumberChange"
                        @keydown.down.prevent="setInputNumberChange"
                      /> -->
                      <!-- mod #10359 編集権限の動作不正 dengshen start -->
                      <!-- <device-input-number -->
                      <!--   v-else -->
                      <!--   :ref=" -->
                      <!--     `required_${index + -->
                      <!--       timeInfo.length + -->
                      <!--       speedDiameterInfo.length + -->
                      <!--       1}` -->
                      <!--   " -->
                      <!--   :device-info="eleInfo" -->
                      <!--   :disabled="isTreatRecord" -->
                      <!--   @input="setInputNumberChange" -->
                      <!--   @wheel.prevent="setInputNumberChange" -->
                      <!--   @keydown.up.prevent="setInputNumberChange" -->
                      <!--   @keydown.down.prevent="setInputNumberChange" -->
                      <!-- /> -->
                      <device-input-number
                        v-else
                        :ref="
                          `required_${index +
                            timeInfo.length +
                            speedDiameterInfo.length +
                            1}`
                        "
                        :device-info="eleInfo"
                        :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                        @input="setInputNumberChange"
                        @wheel.prevent="setInputNumberChange"
                        @keydown.up.prevent="setInputNumberChange"
                        @keydown.down.prevent="setInputNumberChange"
                      />
                      <!-- mod #10359 編集権限の動作不正 dengshenend -->
                      <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
                    </v-ons-col>
                  </v-ons-row>
                  <!-- 一時的にコメントアウト TODO: いらなくなる可能性大 -->
                  <!-- <v-ons-row>
              <v-ons-col>
                時間
              </v-ons-col>
              <v-ons-col>60分</v-ons-col>
              <v-ons-col>-11.0 %</v-ons-col>
            </v-ons-row> -->
                </div>
              </div>
            </div>
          </div>
        </div>

        <v-ons-row v-if="showButton" class="button-area">
          <v-ons-col class="button-cancel">
            <v-ons-button
              class="common-style-cancel-button"
              @click="cancelConfirm()"
            >
              {{ cancelButtonLabel }}
            </v-ons-button>
          </v-ons-col>
          <v-ons-col class="button-ok">
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <v-ons-button -->
            <!--   v-if="!isTreatRecord" -->
            <!--   class="common-style-ok-button" -->
            <!--   @click="save()" -->
            <!-- > -->
            <v-ons-button
              v-if="!isTreatRecord"
              class="common-style-ok-button"
              @click="save()"
              :disabled="!getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
            >
            <!-- mod #10359 編集権限の動作不正 dengshenend -->
              {{ saveButtonLabel }}
            </v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>

      <message-dialog
        :visible.sync="isDialogVisble"
        v-bind="dialogProps"
        type="1"
        @confirm="saveEdit"
      />
      <message-dialog
        :visible.sync="isCancelDialogVisble"
        v-bind="dialogProps"
        type="2"
        @confirm="cancelEdit"
      />
    </div>
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import {deepCopy, getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
/**
 * Vue関連
 */
import { mapActions, mapGetters } from "vuex";
import _ from "underscore";
import {
  DEVICE_TYPE_BVUFC,
  DATA_SOURCE_TYPE_ORD
} from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
import baseEditor from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoEditor.vue";
import { ApiHelper } from "@/apis/AxiosHelper";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import {EventBus} from "@/eventBus";
//add #10246  message change zrx start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
//add #10246  message change zrx start

/**
 * @description BV-UFC設定値編集画面
 */
export default {
  mixins: [baseEditor],

  props: {
    // add #10359 編集権限の動作不正 dengshen start
    isMst: {
      type: Boolean,
      default: false
    },
    // add #10359 編集権限の動作不正 dengshen end
    // キャンセル・保存ボタン表示用
    showButton: {
      type: Boolean,
      default: true
    }
  },

  data() {
    return {
      deviceType: DEVICE_TYPE_BVUFC,
      /**
       * UFC期間
       */
      ufcPeriod: null,
      /**
       * 治療日
       */
      treatDate: null,
      /**
       * 治療時間
       */
      treatTime: null,
      /**
       * 表示用データ
       */
      dispValue: {
        devA_199: {
          value: {
            initValue: null,
            editValue: null
          }
        },
        devA_207: {
          value: {
            initValue: null,
            editValue: null
          }
        },
        devA_249: {
          value: {
            initValue: null,
            editValue: null
          }
        }
      },
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、fang add start
      initModelValue:undefined,
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、fang add end
      //mod FNSI-6783 劉全航 start
      isBVEdited: false,
      BVOutOfLimits: false,
      //mod FNSI-6783 劉全航 end
      // mod #5589 2023/04/19 数値IFのスタイル全不正 林峻峰 start
      blurFlg: false
      // mod #5589 2023/04/19 数値IFのスタイル全不正 林峻峰 end
    };
  },

  computed: {
    ...mapGetters("pat-viewer", ["getTreatmentData"]),
    ...mapGetters("pat-viewer-modal", ["getSettingIndChildData"]),

    // mod redmine 6055 BV-UFCの設定画面で表示枠から単位が飛び出ている 宋qy start
    ...mapGetters("account-edit", ["getFontSize"]),
    // mod redmine 6055 BV-UFCの設定画面で表示枠から単位が飛び出ている 宋qy end

    ...mapGetters("master-maintenance", {
      masterPhysicalName: "getMasterName",
    }),
    ...mapGetters("user", ["getFacilityCd"]),
    /**
     * 時間情報ラベル
     */
    timeInfoLabel() {
      return ["", "開始", "定倍除水", "UFC期間", "終了前"];
    },

    /**
     * 時間情報
     */
    timeInfo() {
      return [
        this.dispValue.devA_199,
        this.dispValue.devA_207,
        this.ufcPeriod,
        this.dispValue.devA_249
      ];
    },

    /**
     * 除水速度倍率情報
     */
    speedDiameterInfo() {
      return [this.devA[206], this.devA[208], this.devA[197], ""];
    },

    /**
     * UFC期間除水速度下限
     */
    lowerSpeedDiameterInfo() {
      // mod FNSI-FutreNetWeb+SI課題管理No.5246 李 start
      return ["", "", this.devA[198], ""];
      // mod FNSI-FutreNetWeb+SI課題管理No.5246 李 end
    },

    /**
     * 固定倍率除水終了条件ラベル
     */
    endCondInfoLabel() {
      return ["最高血圧", "脈拍", "△BV"];
    },

    /**
     * 固定倍率除水終了条件
     */
    endCondInfo() {
      return [this.devA[209], this.devA[210], this.devA[248]];
    },

    /**
     * BV基準値ラベル
     */
    bvBaseInfoLabel() {
      return ["開始時△BV", "指数1", "指数2", "指数3", "終了時"];
    },

    /**
     * BV基準値
     */
    bvBaseInfo() {
      return [
        this.devA[271],
        this.devA[272],
        this.devA[273],
        this.devA[274],
        this.devA[275]
      ];
    },
    /**
     * 患者経過総合ビューアで表示している時は、画面が小さい時のスタイル用classを付与する
     */
    isUnderIndModal() {
      let indObj = document.getElementsByClassName("indInfo-style-modal-container");
      if (indObj.length > 0) {
        return "ind-style-media-query";
      }
      return "";
    },
  },
  //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、fang add start
  created() {
    this.setLoadingScreenVisible(true);
    this.$parent.$parent.isDialogType9 = true;
  },
  //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、fang add end
  // mod redmine 6055 BV-UFCの設定画面で表示枠から単位が飛び出ている 宋qy start
  mounted() {
    setTimeout(() => {
      console.log(this.masterPhysicalName)
      this.changeButton(true);
      this.setLoadingScreenVisible(false);
    },300)
  },
  // mod redmine 6055 BV-UFCの設定画面で表示枠から単位が飛び出ている 宋qy end
  watch: {
    /**
     * @description 装置設定値
     * @summary ミックスインのcreatedでdeviceSetInfoに選択された各装置設定データが設定される
     */
    deviceSetInfo() {
      // 「開始期間 時間」を表示用データに格納
      this.dispValue.devA_199 = this.devA[199];
      // 「固定倍率除水期間 時間」を表示用データに格納
      this.dispValue.devA_207 = this.devA[207];
      // 「終了前期間 時間」を表示用データに格納
      this.dispValue.devA_249 = this.devA[249];

      // 初期状態:指示装置設定画面のみ透析予定・治療時間を参照する
      if (this.dataSourceType === DATA_SOURCE_TYPE_ORD) {
        // 親のスタイル修正
        this.$parent.styleObj = { "max-width": "580px", width: "100%" };

        // オーダー番号が格納されていない場合処理終了
        if (null === this.ordNo) {
          return;
        }
        // 選択した日付
        const selectedDate = this.getSettingIndChildData.treatDate;
        // 日付が選択されていない場合処理終了
        if (!selectedDate) {
          return;
        }
        // 治療情報格納
        let ordInfo = null;
        // 治療情報リストからオーダー番号が一致するものを格納
        this.getTreatmentData.forEach(eleInfo => {
          // 対象日付けに治療予定が存在しない場合次のループへ
          if (null === eleInfo[selectedDate]) {
            return;
          }
          // オーダー番号が一致するものを取得
          ordInfo =
            eleInfo[selectedDate].ordNo === this.ordNo
              ? eleInfo[selectedDate]
              : ordInfo;
        });
        // 治療条件情報が存在する場合、治療条件情報を格納
        const indCondInfo = _.has(ordInfo, "indCondInfo")
          ? JSON.parse(ordInfo.indCondInfo)
          : null;
        // 治療条件情報に治療時間が存在すれば値を格納
        if (_.has(indCondInfo, "1")) {
          this.treatTime = indCondInfo["1"].value;
        }
      }
      // UFC期間の計算処理
      this.calculateUfcPeriod();
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、fang add start
      this.initModelValue = JSON.parse(JSON.stringify(this.devA));
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、fang add end
    },

    /**
     * 開始期間 時間
     */
    "dispValue.devA_199.value.editValue"() {
      // 開始期間 時間をもとの装置設定情報に格納し直す
      this.devA[199] = this.dispValue.devA_199;
      // UFR期間の計算
      this.calculateUfcPeriod();
    },

    /**
     * 固定倍率除水期間 時間
     */
    "dispValue.devA_207.value.editValue"() {
      // 固定倍率除水期間 時間をもとの装置設定情報に格納し直す
      this.devA[207] = this.dispValue.devA_207;
      // UFR期間の計算
      this.calculateUfcPeriod();
    },

    /**
     * 終了前期間 時間
     */
    "dispValue.devA_249.value.editValue"() {
      // 終了前期間 時間をもとの装置設定情報に格納し直す
      this.devA[249] = this.dispValue.devA_249;
      // UFR期間の計算
      this.calculateUfcPeriod();
    },
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start
    devA : {
      handler(newVal) {
        if (JSON.stringify(this.initModelValue) === JSON.stringify(newVal)) {
          this.changeButton(true);
        } else {
          this.changeButton(false);
        }
      },
      deep: true
    },
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end
  },

  methods: {
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "startLoadingScreen",
      "finishLoadingScreen"
    ]),
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return this.isMst || (this.isMst != true && getAuthorized(pageCd, itemCd));
    },
    // add #10359 編集権限の動作不正 dengshen end

    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    setInputNumberChange() {
      EventBus.$emit("deviceSetChanged");
    },
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end

    /**
     * @description 保存時のバリデーション処理
     * @returns {Object}
     *   成功時: null
     *   失敗時: メッセージダイアログ用オブジェクト { messageCd, stringParams }
     */
    validateBeforeUpdating() {
      let errMessage = null;
      /*
       * UFC期間除水速度 入力範囲チェック
       */
      // UFC期間除水速度下限 ≧ 上限 ？
      if (this.devA[197].value.editValue < this.devA[198].value.editValue) {
        errMessage = {
          messageCd: 50000001,
          //add #10246  message change zrx start
          title: DIALOG_MESSAGES[50000001].title,
          //add #10246  message change zrx end
          stringParams: ["UFC期間除水速度"]
        };
      } else if (
        // 0< UFC期間除水速度< 0.10 ?
        (0 < this.devA[197].value.editValue &&
          this.devA[197].value.editValue < 0.1) ||
        (0 < this.devA[198].value.editValue &&
          this.devA[198].value.editValue < 0.1)
      ) {
        errMessage = {
          messageCd: 50000002,
          //add #10246  message change zrx start
          title: DIALOG_MESSAGES[50000002].title,
          //add #10246  message change zrx end
          stringParams: ["UFC期間除水速度", "0.10"]
        };
      }

      /*
       * 固定倍率除水終了条件 入力範囲チェック
       */
      // 0 < 最高血圧< 60 ?
      else if (
        0 < this.devA[209].value.editValue &&
        this.devA[209].value.editValue < 60
      ) {
        errMessage = {
          messageCd: 50000002,
          //add #10246  message change zrx start
          title: DIALOG_MESSAGES[50000002].title,
          //add #10246  message change zrx end
          stringParams: ["固定倍率除水終了条件 最高血圧", "60"]
        };
        // 0 < 脈拍< 40 ?
      } else if (
        0 < this.devA[210].value.editValue &&
        this.devA[210].value.editValue < 40
      ) {
        errMessage = {
          messageCd: 50000002,
          //add #10246  message change zrx start
          title: DIALOG_MESSAGES[50000002].title,
          //add #10246  message change zrx end
          stringParams: ["固定倍率除水終了条件 脈拍", "40"]
        };
      }
      return errMessage;
    },

    /**
     * UFC期間の計算
     * @description
     * 治療時間から「開始期間 時間」,「固定倍率除水期間 時間」,「終了前期間 時間」を
     * 引いた値を格納する
     * 治療開始時間が存在しない場合はUFC期間を---と表記
     */
    calculateUfcPeriod() {
      // 治療開始時刻が格納されていればUFC期間の計算を行う
      if (this.treatTime) {
        // 治療時間を格納
        let caluculatedUfcPeriod = this.treatTime;
        // 「開始期間 時間」を引く
        caluculatedUfcPeriod = this.devA[199].value.editValue
          ? caluculatedUfcPeriod - this.devA[199].value.editValue
          : caluculatedUfcPeriod;

        // 「固定倍率除水期間 時間」を引く
        caluculatedUfcPeriod = this.devA[207].value.editValue
          ? caluculatedUfcPeriod - this.devA[207].value.editValue
          : caluculatedUfcPeriod;
        // 「終了前期間 時間」を引く
        caluculatedUfcPeriod = this.devA[249].value.editValue
          ? caluculatedUfcPeriod - this.devA[249].value.editValue
          : caluculatedUfcPeriod;
        this.ufcPeriod = `${caluculatedUfcPeriod}分`;
      } else {
        this.ufcPeriod = "---";
      }
    },

    /**
     * 時間情報ラベルカラー
     * @description
     *  「開始期間 時間」:水色
     *  「固定倍率除水期間 時間」:ピング
     *  「UFC期間 時間」:黄緑
     *  「終了前期間 時間」:黄土色
     */
    dispLabeltimeInfoLabelColor(index) {
      switch (index) {
        case 1:
          return { "background-color": "aqua" };

        case 2:
          return { "background-color": "hotpink" };

        case 3:
          return { "background-color": "palegreen" };

        case 4:
          return { "background-color": "khaki" };

        default:
          break;
      }
    },

    /**
     * @description 編集有無確認
     * @returns {Boolean}
     *   成功: モーダル表示
     *   失敗: モーダル非表示
     */
    checkEdit(num) {
      if (num === 1) {
        // キャンセルボタンクリック時チェック
        this.cancelConfirm();
        // cancelConfirm関数(子)でモーダルの表示非表示を行うため、ベース(親)では何も処理しない
        return true;
      }
    },

    /**
     * 更新処理(指示)
     * @description 親からこの関数を呼んで更新処理を行う
     */
    updateIndInfo(structData) {
      console.log("BvUfcEditor.vue updateIndInfo this.startLoadingScreen();");
      this.startLoadingScreen();
      // 治療情報更新
      if (this.getSettingIndChildData.isAllSave) {
        // 一括更新
        this.save(structData);
      } else {
        this.ordMainAllSave(structData);
      }
      console.log("BvUfcEditor.vue updateIndInfo this.finishLoadingScreen();");
      this.finishLoadingScreen();
    },

    /**
     * @description 未編集通知ダイアログ後保存ボタンを活性へ(指示画面のみ)
     */
    saveEdit() {
      if (this.dataSourceType === DATA_SOURCE_TYPE_ORD) {
        this.$parent.$parent.updateDisable = false;
      }
    },
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、fang add start
    async resetComponentIndData(structData){
      if (this.isEdit()) {
        this.$parent.$parent.messageDialogInfo.messageCd = 70000028;
        /* mod FNSI-4212 更新対象変更時のウインドウが不正 liumx start */
        this.$parent.$parent.messageDialogInfo.type = "9";
        /* mod FNSI-4212 更新対象変更時のウインドウが不正 liumx end */
        this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
        return;
      } else {
        this.getComponentData(structData, 2);
      }
    },
    isEdit() {
      const treatCondItems = this.$refs;
      let editCount = 0;
      Object.keys(treatCondItems).forEach(key => {
        if ((treatCondItems[key] && treatCondItems[key].isEdited)
          || (treatCondItems[key][0] && treatCondItems[key][0].isEdited)) {

          // 変更箇所数格納
          editCount += 1;
        }
      });
      // ΔBVが変更された場合
      if (this.isBVEdited) {
        editCount += 1;
      }
      if (0 === editCount) {
        return false;
      }
      return true;
    },
    async getComponentData(structData, answer) {

      if (answer == 1) {
        return;
      }

      let indWeeks = [
        {
          text: "全",
          done: true,
          value: 0
        },
        {
          text: "月",
          done: true,
          value: 1
        },
        {
          text: "火",
          done: true,
          value: 2
        },
        {
          text: "水",
          done: true,
          value: 3
        },
        {
          text: "木",
          done: true,
          value: 4
        },
        {
          text: "金",
          done: true,
          value: 5
        },
        {
          text: "土",
          done: true,
          value: 6
        },
        {
          text: "日",
          done: true,
          value: 7
        }
      ];
      const paramJson = {};
      // 施設情報
      paramJson.facility_cd = structData.facilityCd;
      // 患者情報
      paramJson.pat_id = structData.patId;
      // 治療開始日時
      paramJson.start_date = structData.indStartDate;
      // 治療終了日時
      paramJson.end_date = "";
      // クール
      paramJson.ind_kur_cd = JSON.stringify(structData.selectedKur);
      // 治療方法
      paramJson.ind_treatment_cd = JSON.stringify(structData.selectedTreat);
      // 曜日パターン
      paramJson.weeks = JSON.stringify(indWeeks);

      // 対象日時の治療情報取得(開始日付・治療方法・クールで絞り込み)
      let response = await ApiHelper.post(
        "/mainData/getOrdMainDataInfo",
        paramJson
      ).catch(error => {
        getErrorMessage('BvUfcEditor.vue', 'getComponentData', error);
        throw error;
      });
      let ordMainData = response.data[0];
      if (ordMainData.indDeviceSetInfo != null && ordMainData.indDeviceSetInfo != undefined) {
        let tempData = JSON.parse(ordMainData.indDeviceSetInfo);
        if (tempData != null && tempData != undefined) {
          // 初期値保持
          const initData = deepCopy(tempData);
          if (answer == 3) {
            for (let key in this.devA) {
              if (this.devA[key].value.editValue != this.initModelValue[key].value.initValue) {
                tempData.bvufc.dev.A[key] = this.devA[key].value.editValue;
              }
            }
          }
          for (let key in this.devA) {
            this.devA[key].value.initValue = initData.bvufc.dev.A[key];
            this.devA[key].value.editValue = tempData.bvufc.dev.A[key];
          }
        }
      }
      this.initModelValue = JSON.parse(JSON.stringify(this.devA));
    },
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、fang add end
    changeButton(val) {
      EventBus.$emit( "mstTreatmentSetRegistered", val);
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start
      // if(false === val) {
      //   EventBus.$emit("deviceSetChanged");
      // }
      EventBus.$emit("deviceSetChanged", !val);
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end
    },
    //mod FNSI-6783 劉全航 start
    inputValidValue(e,value) {
      // 必須項目が焦点を失って空の場合は初期値となります。
      if (e.target.value === '') {
        e.target.value =  this.endCondInfo[2].value.initValue;
      }
      value.value.editValue = Number(e.target.value);
      if(value.value.editValue >value.maxValue || value.value.editValue < value.minValue){
        this.BVOutOfLimits = true;
      }else{
        this.BVOutOfLimits = false;
      }
      // mod #5589 2023/04/19 数値IFのスタイル全不正 林峻峰 start
      if (e.target.value == value.maxValue && this.blurFlg) {
        value.value.editValue = value.minValue;
        this.blurFlg = false
      }else if (e.target.value == value.minValue && this.blurFlg) {
        value.value.editValue = value.maxValue;
        this.blurFlg = false
      }
      // mod #5589 2023/04/19 数値IFのスタイル全不正 林峻峰 end
    },
    // mod #5589 2023/04/19 数値IFのスタイル全不正 林峻峰 start
    inputNumber(e, eleInfo) {
      console.log('eleInfo', eleInfo)
      let value = e.target.value
      // 数値範囲内かどうかの確認
      if (value > eleInfo.maxValue) {
        eleInfo.value.editValue = eleInfo.minValue;
        this.blurFlg = true;
      } else if (value < eleInfo.minValue) {
        eleInfo.value.editValue = eleInfo.maxValue;
        this.blurFlg = true;
      } else {
        this.blurFlg = false;
      }
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start
      // this.changeButton(true);
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end
    },
    onMouseWheel(e,eleInfo){
      let delta = (e.wheelDelta && (e.wheelDelta > 0 ? 1 : -1)) ||
                      (e.detail && (e.wheelDelta > 0 ? -1 : 1))
      if (!e.target.value) {
        e.target.value = 0
      }
      let value = parseFloat(e.target.value);
      const parameterStep = eleInfo.step;
      if (delta > 0) {
        // 滑ります
        value += parameterStep
      } else {
        // 下がります
        value -= parameterStep
      }
      // 数値範囲内かどうかの確認
      if (value > eleInfo.maxValue) {
        value = eleInfo.minValue;
      }
      if(value < eleInfo.minValue) {
        value = eleInfo.maxValue;
      }
      eleInfo.value.editValue = parseFloat(value.toFixed(this.getDecimalPointLength(parameterStep)))
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start
      // this.changeButton(true);
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end
    },
    getDecimalPointLength(number){
      var numbers = String(number).split('.');
      return (numbers[1]) ? numbers[1].length : 0;
    },
    // mod #5589 2023/04/19 数値IFのスタイル全不正 林峻峰 end
    classObject(value) {
      if(value.value.editValue === value.value.initValue){
        this.isBVEdited = false;
        return {
          // 常に適用されるclass
          "custom-input-number": true,
          // 編集時に適用されるclass
          "custom-input-number-edited": false,
          "custom-input-number-required": true,
        };
      }else{
        this.isBVEdited = true;
        return {
          // 常に適用されるclass
          "custom-input-number": true,
          // 編集時に適用されるclass
          "custom-input-number-edited": true,
          "custom-input-number-required": true,
        };
      }
    },
    //mod FNSI-6783 劉全航 end
    /**
   * @description 該当行が他院情報かどうかを判定
   * @returns {Boolean} true = 他施設のデータは参照のみ
   */
    isOtherFacilityRow() {
      if (!this.getSettingIndChildData) {
        return false
      }
      return this.getSettingIndChildData.facilityCd ? this.getSettingIndChildData.facilityCd !== this.getFacilityCd : false
    },
  },
};
</script>

<style src="../base-modules/BeseDeviceSetInfoStyle.css" scoped></style>

<style scoped>
@media print {
  .margin-area{
    max-width: unset !important;
    min-width: unset !important;
    width: unset!important;
    margin: unset !important;
}
}
/** iPhone X/8/7/6 or Android(M,L) */
/** Device Width:360-480           */
/** ボックス要素-スクロール制御 */
@media only screen and (min-device-width:360px) and (max-device-width:480px) {
  .device-info-main-title {
    height: fit-content;
  }
  .ind-style-media-query {
    overflow-x: auto;
    overflow-y: auto;
    -webkit-overflow-scrolling:auto;
    overscroll-behavior-y: auto;
  }
  .device-info-content-area {
    height:340px;
  }
}

.bv-ufc-time-label {
  padding: 1px;
  border-radius: 0.5em;
  width: 80%;
  margin: auto;
  color: black;
}

.end-cond-info {
  border: 1px solid var(--ntss-border-color);
  border-radius: 0.5em;
  /* mod redmine 6055 BV-UFCの設定画面で表示枠から単位が飛び出ている 宋qy start */
  width: 450px;
  /* mod redmine 6055 BV-UFCの設定画面で表示枠から単位が飛び出ている 宋qy end */
  padding: 5px;
  margin-right:5px;
  margin-top:5px;
  margin-bottom: 5px;
}

.bv-ufc-row {
  text-align: center;
  padding: 5px;
  height: 50%;
}

.bv-ufc-time-row {
  border-bottom: 1px solid var(--ntss-border-color);
  border-top: 1px solid var(--ntss-border-color);
}
.bv-ufc-time-rowcopy {
  border-bottom: 1px solid var(--ntss-border-color);
}
.device-info-main-content {
  border: 1px solid var(--ntss-border-color);
  border-top: none;
}

.margin-area {
  margin: auto;
  min-width: 640px;
  width: 80%;
  max-width: 40em;
}

.display-area {
  width: 100%;
}

device-input-number {
  line-height: 2em;
}

custom-input-number-required {
  color: black;
  background-color: #ffff99;
  width: 100%;
}
</style>
