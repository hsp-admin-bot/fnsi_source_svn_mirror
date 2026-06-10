<template>
  <div v-if="deviceSetInfo !== null">
    <!-- 項目 isEditedプロパティ参照用に削除せず非表示とする-->
    <v-ons-row class="device-info-cell device-info-left" v-show="false">
      <v-ons-col class="device-info-cell-name">
        Ｉ‐ＨＤＦプログラム使用選択
      </v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <device-radio -->
        <!--   ref="radio1" -->
        <!--   :device-info="programUse" -->
        <!--   :disabled="isTreatRecord" -->
        <!--   @change="changeButton()" -->
        <!-- /> -->
        <device-radio
          ref="radio1"
          :device-info="programUse"
          :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
          @change="changeButton()"
        />
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
      </v-ons-col>
    </v-ons-row>
    <!--mod FNSI-画面部品デザイン じょはく start-->
    <!--<v-ons-row class="device-info-cell device-info-main-content back-color">-->
    <!--<div class="device-info-cell-content">-->
    <v-ons-row class="device-info-cell device-info-main-content" :class="imgSizeSet">
      <div class="device-info-cell-content" :class="sizeSet">
        <!--mod FNSI-画面部品デザイン じょはく end-->
        <div class="device-info-img-content">
          <img :src="iHdfImg" alt="I-HDF図1" class="i-hdf-img" />
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <device-input-number -->
          <!--   v-for="(device, index) in deviceValueNumberList" -->
          <!--   :key="index" -->
          <!--   :ref="`required_${index}`" -->
          <!--   :device-info="device" -->
          <!--   :class="`deviceSetInfo-input device${index}`" -->
          <!--   :disabled="isTreatRecord" -->
          <!--   @change="changeButton()" -->
          <!--   @input="setInputNumberChange" -->
          <!--   @wheel.prevent="setInputNumberChange" -->
          <!--   @keydown.up.prevent="setInputNumberChange" -->
          <!--   @keydown.down.prevent="setInputNumberChange" -->
          <!-- /> -->
          <device-input-number
            v-for="(device, index) in deviceValueNumberList"
            :key="index"
            :ref="`required_${index}`"
            :device-info="device"
            :class="`deviceSetInfo-input device${index}`"
            :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
            @change="changeButton()"
            @input="setInputNumberChange"
            @wheel.prevent="setInputNumberChange"
            @keydown.up.prevent="setInputNumberChange"
            @keydown.down.prevent="setInputNumberChange"
          />
          <!-- mod #10359 編集権限の動作不正 dengshen end -->

          <!-- 濾液速度:固定値「-.--」 -->
          <span class="deviceSetInfo-input device-filtrate">-.--</span>

          <!-- 未登録データ -->
          <span class="device-blanks1">-.--</span>
          <span class="device-blanks2">-.--</span>
          <!-- 補液分除水速度 -->
          <span class="removing-water-speed">
            {{ replenisherRemovalWaterSpeed }}
          </span>
        </div>
          <!--mod FNSI-画面部品デザイン じょはく start-->
          <!--<div class="calculation-area">-->
          <div class="calculation-area" :class="calculationSizeSet">
            <!--mod FNSI-画面部品デザイン じょはく end-->

            <!-- add FNSI-FutreNetWeb+SI課題管理No.5255 李 start -->
            <!--#7241 ,mod zhangrx 2023-02-27 治療記録>装置設定>I-HDF画面が開く事を確認 非活性にする事  start-->
            <div>
              TMPゼロ補正開始時間<br />
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- mod #11166 I-HDFが保存できない 情 start -->
              <!-- <device-input-number -->
              <!--   :device-info="tmpStartTime" -->
              <!--   class="deviceSetInfo-input" -->
              <!--   ref="startTime" -->
              <!--   :disabled="isTreatRecord || !(enabledCalculationTMP == 'true')" -->
              <!--   @change="changeButton()" -->
              <!--   @input="setInputNumberChange" -->
              <!--   @wheel.prevent="setInputNumberChange" -->
              <!--   @keydown.up.prevent="setInputNumberChange" -->
              <!--   @keydown.down.prevent="setInputNumberChange" -->
              <!-- /> -->
              <!-- <device-input-number
                :device-info="tmpStartTime"
                class="deviceSetInfo-input"
                ref="startTime"
                :disabled="isTreatRecord || !(enabledCalculationTMP == 'true') || !getItemAuthorized('Indication', 'default_authority')"
                @change="changeButton()"
                @input="setInputNumberChange"
                @wheel.prevent="setInputNumberChange"
                @keydown.up.prevent="setInputNumberChange"
                @keydown.down.prevent="setInputNumberChange"
              /> -->
              <!-- mod #11166 I-HDFが保存できない zhangyue start -->
              <!-- <device-input-number
                :device-info="tmpStartTime"
                class="deviceSetInfo-input"
                ref="required-startTime"
                :disabled="isTreatRecord || !(enabledCalculationTMP == 'true') || !getItemAuthorized('Indication', 'default_authority')"
                @change="changeButton()"
                @input="setInputNumberChange"
                @wheel.prevent="setInputNumberChange"
                @keydown.up.prevent="setInputNumberChange"
                @keydown.down.prevent="setInputNumberChange"
              /> -->
              <device-input-number
                :device-info="tmpStartTime"
                class="deviceSetInfo-input"
                ref="required-startTime"
                :required="dataSourceType === 1? true : false"
                :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                @change="dataSourceType === 1? changeButton() : null"
                @input="dataSourceType === 1? setInputNumberChange() : null"
                @wheel.prevent="dataSourceType === 1? setInputNumberChange() : null"
                @keydown.up.prevent="dataSourceType === 1? setInputNumberChange() : null"
                @keydown.down.prevent="dataSourceType === 1? setInputNumberChange() : null"
              />
              <!-- mod #11166 I-HDFが保存できない zhangyue end -->
              <!-- mod #11166 I-HDFが保存できない 情 end -->
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              分
            </div>
            <!-- add FNSI-FutreNetWeb+SI課題管理No.5255 李 end -->

            <div>
              計算用TMPゼロ補正<br />
              <label>
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <v-ons-radio -->
                <!--   name="TMP" -->
                <!--   :disabled="isTreatRecord" -->
                <!--   value="true" -->
                <!--   v-model="enabledCalculationTMP" -->
                <!--   @click="enabledCalculationTMP = 'true';changeButton()" -->
                <!--   modifier="round" -->
                <!-- ></v-ons-radio> -->
                <v-ons-radio
                  name="TMP"
                  :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                  value="true"
                  v-model="enabledCalculationTMP"
                  @click="enabledCalculationTMP = 'true';changeButton()"
                  modifier="round"
                ></v-ons-radio>
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                あり
              </label>
              <label>
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <v-ons-radio -->
                <!--   name="TMP" -->
                <!--   :disabled="isTreatRecord" -->
                <!--   value="false" -->
                <!--   v-model="enabledCalculationTMP" -->
                <!--   @click="enabledCalculationTMP = 'false';changeButton()" -->
                <!--   modifier="round" -->
                <!-- ></v-ons-radio> -->
                <v-ons-radio
                  name="TMP"
                  :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                  value="false"
                  v-model="enabledCalculationTMP"
                  @click="enabledCalculationTMP = 'false';changeButton()"
                  modifier="round"
                ></v-ons-radio>
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                なし
              </label>
            </div>
            <div>
              TMPゼロ補正時間<br />
              <!-- mod FNSI-FutreNetWeb+SI課題管理No.5255 李 start -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   :device-info="tmpTime" -->
              <!--   ref="tmpTime" -->
              <!--   class="deviceSetInfo-input" -->
              <!--   :disabled="isTreatRecord || !(enabledCalculationTMP == 'true')" -->
              <!--   @change="changeButton()" -->
              <!--   @input="setInputNumberChange" -->
              <!--   @wheel.prevent="setInputNumberChange" -->
              <!--   @keydown.up.prevent="setInputNumberChange" -->
              <!--   @keydown.down.prevent="setInputNumberChange" -->
              <!-- /> -->
              <!-- mod #11166 I-HDFが保存できない 情 start -->
              <!-- <device-input-number
                :device-info="tmpTime"
                ref="tmpTime"
                class="deviceSetInfo-input"
                :disabled="isTreatRecord || !(enabledCalculationTMP == 'true') || !getItemAuthorized('Indication', 'default_authority')"
                @change="changeButton()"
                @input="setInputNumberChange"
                @wheel.prevent="setInputNumberChange"
                @keydown.up.prevent="setInputNumberChange"
                @keydown.down.prevent="setInputNumberChange"
              /> -->
              <!-- mod #11166 I-HDFが保存できない zhangyue start -->
              <!-- <device-input-number
                :device-info="tmpTime"
                ref="required-tmpTime"
                class="deviceSetInfo-input"
                :disabled="isTreatRecord || !(enabledCalculationTMP == 'true') || !getItemAuthorized('Indication', 'default_authority')"
                @change="changeButton()"
                @input="setInputNumberChange"
                @wheel.prevent="setInputNumberChange"
                @keydown.up.prevent="setInputNumberChange"
                @keydown.down.prevent="setInputNumberChange"
              /> -->
              <device-input-number
                :device-info="tmpTime"
                ref="required-tmpTime"
                class="deviceSetInfo-input"
                :required="dataSourceType === 1? true : false"
                :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                @change="dataSourceType === 1? changeButton() : null"
                @input="dataSourceType === 1? setInputNumberChange() : null"
                @wheel.prevent="dataSourceType === 1? setInputNumberChange() : null"
                @keydown.up.prevent="dataSourceType === 1? setInputNumberChange() : null"
                @keydown.down.prevent="dataSourceType === 1? setInputNumberChange() : null"
              />
              <!-- mod #11166 I-HDFが保存できない zhangyue end-->
              <!-- mod #11166 I-HDFが保存できない 情 end -->
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!--#7241 ,mod zhangrx 2023-02-27 治療記録>装置設定>I-HDF画面が開く事を確認 非活性にする事  end-->
              <!--mod FNSI-画面デザイン【患者経過総合ビューア.xlsx】数値入力対応 韓 start-->
              <!--
              <input
                :value="TMPTime"
                class="deviceSetInfo-input"
                type="number"
                :min="minTMPTime"
                :max="maxTMPTime"
                :disabled="!(enabledCalculationTMP == 'true')"
                @blur="inputTMPTimeValue($event.target.value)"
              />
              -->
              <!-- <custom-input-number
                :value="TMPTime"
                style="width:50%"
                :digits="10"
                :min-value="minTMPTime"
                :max-value="maxTMPTime"
                :disabled="!(enabledCalculationTMP == 'true')"
                @blur="inputTMPTimeValue($event.target.value)"
              /> -->
              <!--mod FNSI-画面デザイン【患者経過総合ビューア.xlsx】数値入力対応 韓 start-->
              <!-- mod FNSI-FutreNetWeb+SI課題管理No.5255 李 end -->
              秒
            </div>
            <div>
              総補液量上限<br />
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   ref="required1" -->
              <!--   :device-info="totalReplenisherUpperLimit" -->
              <!--   class="deviceSetInfo-input" -->
              <!--   :disabled="isTreatRecord" -->
              <!--   @change="changeButton()" -->
              <!--   @input="setInputNumberChange" -->
              <!--   @wheel.prevent="setInputNumberChange" -->
              <!--   @keydown.up.prevent="setInputNumberChange" -->
              <!--   @keydown.down.prevent="setInputNumberChange" -->
              <!-- /> -->
              <device-input-number
                ref="required1"
                :device-info="totalReplenisherUpperLimit"
                class="deviceSetInfo-input"
                :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                @change="changeButton()"
                @input="setInputNumberChange"
                @wheel.prevent="setInputNumberChange"
                @keydown.up.prevent="setInputNumberChange"
                @keydown.down.prevent="setInputNumberChange"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </div>
            <div>
              計算用透析時間<br />
              <!-- TODO: time：safari未対応の為、代用必須 (47時間まで入力可能)-->
<!--              mod #10237 装置設定デフォルトマスタの計算用透析時間を編集すると保存ボタンが活性化する 20240218 ztc start-->
<!--              <input-->
<!--                :value="dialysisDisplayTime"-->
<!--                type="time"-->
<!--                :disabled="isTreatRecord"-->
<!--                @input="inputValue($event.target.value)"-->
<!--                @change="changeButton()"-->
<!--                @wheel.prevent="setInputNumberChange"-->
<!--                @keydown.up.prevent="setInputNumberChange"-->
<!--                @keydown.down.prevent="setInputNumberChange"-->
<!--              />-->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <time-input -->
              <!--   :value="dialysisDisplayTime" -->
              <!--   :disabled="isTreatRecord" -->
              <!--   max="10:00" -->
              <!--   default-time="00:00" -->
              <!--   @input="inputValue" -->
              <!--   @handleClearInput="dialysisDisplayTime = null; inputValue(null)" -->
              <!-- /> -->
              <time-input
                :value="dialysisDisplayTime"
                :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                max="09:59"
                default-time="00:00"
                @input="inputValue"
                @handleClearInput="dialysisDisplayTime = null; inputValue(null)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
<!--              mod #10237 装置設定デフォルトマスタの計算用透析時間を編集すると保存ボタンが活性化する 20240218 ztc end-->
              <!--mod FNSI-画面部品デザイン じょはく start-->
              <!--<div class="calculation-disclaimer-day">-->
              <div class="calculation-disclaimer-day" style="margin-top: 0.3em;">
              <!--mod FNSI-画面部品デザイン じょはく end-->
                <span v-show="isDialysisDay" class="calculation-disclaimer">
                  {{ dialysisDay }}
                </span>
              </div>
              <!--mod FNSI-画面部品デザイン じょはく start-->
              <!--<div class="calculation-disclaimer">-->
              <div class="calculation-disclaimer" style="margin-top: 0.6em;">
              <!--mod FNSI-画面部品デザイン じょはく end-->
                計算用の透析時間であり、<br />
                本入力では透析時間指示の<br />
                変更は実施されません
              </div>
            </div>
            <div>
              補液回数<br />
              {{ countReplenisher }} 回
            </div>
            <!-- add FNSI-I-HDF時間の追加 楊 start -->
            <div>
              <!-- add FNSI-FutreNetWeb+SI課題管理No.5255 李 start -->
              <!-- del #11166 I-HDFが保存できない zhangyue start -->
              <!-- <device-input-number
                v-show="false"
                :device-info="iHdeTime"
                class="deviceSetInfo-input"
                @input="setInputNumberChange"
                  @wheel.prevent="setInputNumberChange"
                  @keydown.up.prevent="setInputNumberChange"
                  @keydown.down.prevent="setInputNumberChange"
              /> -->
              <!-- del #11166 I-HDFが保存できない zhangyue end -->
              <!-- add FNSI-FutreNetWeb+SI課題管理No.5255 李 end -->
              I-HDF時間<br />
              {{ timeReplenisher }} 分
            </div>
            <!-- add FNSI-I-HDF時間の追加 楊 end -->
            <div>
              予定補液量<br />
              {{ prospectReplenisher }} L
            </div>
          </div>
      </div>
    </v-ons-row>

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
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
          {{ saveButtonLabel }}
        </v-ons-button>
      </v-ons-col>
    </v-ons-row>

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
    <message-dialog
      :visible.sync="isChangeDisplayDialogVisble"
      v-bind="dialogProps"
      type="2"
      @confirm="changeDisplayEdit"
    />
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { mapActions, mapGetters } from "vuex";
import moment from "moment";
import {
  DATA_SOURCE_TYPE_MST,
  // add #11166 I-HDFが保存できない zhangyue start
  DATA_SOURCE_TYPE_MST_EDIT_RECORD,
  // add #11166 I-HDFが保存できない zhangyue end
  DATA_SOURCE_TYPE_ORD,
  DATA_SOURCE_TYPE_TREAT,
  DEVICE_TYPE_IHDF
} from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
import baseEditor from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoEditor.vue";
import iHdfImg from "@/../public/img/deviceset-info/ProgramReplenish.png";
import {
  DEVICE_TYPE_OPE,
  DEVICE_TYPE_WAR,
  valueInfoWar,
  valueInfoOpe
} from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
import { ApiHelper } from "@/apis/AxiosHelper";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import {EventBus} from "@/eventBus";
import TimeInput from "@/components/common/TimeInput.vue";

/** * I-HDFメイン */
export default {
  components: {
    TimeInput
  },

  mixins: [baseEditor],

  props: {
    // add #10359 編集権限の動作不正 dengshen start
    isMst: {
      type: Boolean,
      default: false
    },
    // add #10359 編集権限の動作不正 dengshen end
    dataSourceType: {
      type: Number,
      required: true
    },

    isIhdfMain: {
      type: Boolean,
      required: true
    },

    isProgramUseChacked: {
      type: Boolean,
      required: true
    },

    // キャンセル・保存ボタン表示用
    showButton: {
      type: Boolean,
      default: true
    }
  },
  data() {
    return {
      deviceType: DEVICE_TYPE_IHDF,
      // 画像
      iHdfImg,
      // 透析日の表示有無
      isDialysisDay: false,
      // TMPゼロ補正時間使用有無
      // mod redmine 6192 I-HDFの初期値が異なる 宋qy start
      enabledCalculationTMP: "true",
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
      initEnabledCalculationTMP: "true",
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
      // mod redmine 6192 I-HDFの初期値が異なる 宋qy end
      // TMPゼロ補正時間
      // del FNSI-FutreNetWeb+SI課題管理No.5255 李 start
      // // mod FNSI-画面デザイン【患者経過総合ビューア.xlsx】数値入力対応 韓 start
      // // TMPTime: null,
      // TMPTime: {
      //   initValue: null,
      //   editValue: null
      // },
      // // mod FNSI-画面デザイン【患者経過総合ビューア.xlsx】数値入力対応 韓 end
      // del FNSI-FutreNetWeb+SI課題管理No.5255 李 end
      // TMPゼロ補正最小時間
      minTMPTime: null,
      // TMPゼロ補正最大時間
      maxTMPTime: null,
      // mod #11166 I-HDFが保存できない zhangyue start
      // 計算用透析時間:画面表示用 指示以外は初期値を「04：00」
      dialysisDisplayTime: "04:00",
      // 計算用透析時間:処理用
      dialysisTime: 240,
      // mod #11166 I-HDFが保存できない zhangyue end
      // 透析日
      dialysisDate: null,
      // 画面切り替えフラグ
      isChangeDisplayDialogVisble: false,
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
      initModelValue:undefined,
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア_I-HDF設定 20240123 ztc start
      isTMPEdited: false,
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア_I-HDF設定 20240123 ztc end
      // 計算用透析時間のMAX値 09:59
      MAX_DIALYSIS_TIME: 599,
      tmpStartTimeObj: {
        decimalDigits: 0,
        digits : 2,
        formLabel : '',
        formName : 'TMPゼロ補正開始時間',
        maxValue : 30,
        minValue : 0,
        unitName : '',
        // mod redmine 6192 HDFの初期値が異なる 宋qy start
        value: {editValue : 10, initValue : 10}
        // mod redmine 6192 HDFの初期値が異なる 宋qy end
      },
      tmpTimeObj: {
        decimalDigits: 0,
        digits : 10,
        formLabel : '',
        formName : 'TMPゼロ補正時間',
        maxValue : 600,
        minValue : 120,
        unitName : '',
        // mod redmine 6192 HDFの初期値が異なる 宋qy start
        value: {editValue : 190, initValue : 190}
        // mod redmine 6192 HDFの初期値が異なる 宋qy end
      }
    };
  },

  computed: {
    ...mapGetters("pat-info", ["selectedPat"]),
    // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
    // ...mapGetters("pat-viewer", ["getTreatmentData", "getMstTreatmentData"]),
    ...mapGetters("pat-viewer", ["getTreatmentData", "getMstTreatmentData", "getRecentTreatmentDate"]),
    // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
    // #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start
    // ...mapGetters("pat-viewer-modal", ["getSettingIndChildData"]),
    ...mapGetters("pat-viewer-modal", ["getSettingIndChildData", "getIhdfAnswerThreeDevA","getDialysisTimeData"]),
    // #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end
    // add FNSI-画面部品デザイン じょはく start
    ...mapGetters("account-edit", ["getFontSize"]),
    ...mapGetters("master-maintenance", [
      "getEditRecord",
      "getMasterName",
    ]),
    ...mapGetters("treatment-record/common", [
      "getTreatDate",
      "getRstCondInfo"
    ]),
    ...mapGetters("user", ["getFacilityCd"]),
    sizeSet() {
      const names = ["small", "medium", "large", "x-large"];
      return "size-set-" + names[this.getFontSize];
    },
    imgSizeSet() {
      const names = ["small", "medium", "large", "x-large"];
      return "img-size-set-" + names[this.getFontSize];
    },
    calculationSizeSet() {
      const names = ["small", "medium", "large", "x-large"];
      return "calculation-size-set-" + names[this.getFontSize];
    },
    // add FNSI-画面部品デザイン じょはく end
    /**
     * @description 補液速度
     */
    replenisherSpeed() {
      return this.devA[201];
    },

    /**
     * @description 補液開始時間
     */
    replenisherStartTime() {
      return this.devA[203];
    },

    /**
     * @description 補液量設定
     */
    replenisherAmountSetting() {
      return this.devA[200];
    },

    /**
     * @description 除水再開時間
     */
    removalWaterRestartTime() {
      return this.devA[204];
    },

    /**
     * @description 補液周期
     */
    replenisherCycle() {
      return this.devA[202];
    },

    /**
     * @description 総補液量上限
     */
    totalReplenisherUpperLimit() {
      return this.devA[205];
    },

    /**
     * @description プログラム使用選択
     */
    programUse() {
      return this.devA[432];
    },

    // add FNSI-FutreNetWeb+SI課題管理No.5255 李 start
    /**
     * @description TMPゼロ補正開始時間
     */
    tmpStartTime() {
      // mod #11166 I-HDFが保存できない zhangyue start
      // if (!this.devA[467]) {
      //   const tmpStartTimeObj =  {
      //     decimalDigits: 0,
      //     digits : 2,
      //     formLabel : '',
      //     formName : 'TMPゼロ補正開始時間',
      //     maxValue : 30,
      //     minValue : 0,
      //     unitName : '',
      //     // mod redmine 6192 HDFの初期値が異なる 宋qy start
      //     value: {editValue : 10, initValue : 10}
      //     // mod redmine 6192 HDFの初期値が異なる 宋qy end
      //   }
        /*mod #7241 zhangruixue 編集していないにも関わらず、TMPゼロ補正開始時間とTMPゼロ補正時間が緑枠となっている,→枠を未編集のものに修正 start*/
        // if(this.isTreatRecord){
        //   tmpStartTimeObj.value.initValue = 10
        // }
        /*mod #7241 zhangruixue 編集していないにも関わらず、TMPゼロ補正開始時間とTMPゼロ補正時間が緑枠となっている,→枠を未編集のものに修正 end*/
        // this.devA[467] = tmpStartTimeObj;
      // }
      // return this.devA[467];
      return !this.devA[1001] ? this.tmpStartTimeObj : this.devA[1001];
      // mod #11166 I-HDFが保存できない zhangyue end
    },

    /**
     * @description TMPゼロ補正時間
     */
     tmpTime() {
      // mod #11166 I-HDFが保存できない zhangyue start
      // if (!this.devA[468]) {
        // const tmpTimeObj =  {
        //   decimalDigits: 0,
        //   digits : 10,
        //   formLabel : '',
        //   formName : 'TMPゼロ補正時間',
        //   maxValue : 600,
        //   minValue : 120,
        //   unitName : '',
        //   // mod redmine 6192 HDFの初期値が異なる 宋qy start
        //   value: {editValue : 190, initValue : 190}
        //   // mod redmine 6192 HDFの初期値が異なる 宋qy end
        // }
        /*mod #7241 zhangruixue 編集していないにも関わらず、TMPゼロ補正開始時間とTMPゼロ補正時間が緑枠となっている,→枠を未編集のものに修正 start*/
        // if(this.isTreatRecord){
        //   tmpTimeObj.value.initValue = 190
        // }
        /*mod #7241 zhangruixue 編集していないにも関わらず、TMPゼロ補正開始時間とTMPゼロ補正時間が緑枠となっている,→枠を未編集のものに修正 end*/
        // this.devA[468] = tmpTimeObj;
      // }
      // return this.devA[468];
      return !this.devA[1002]? this.tmpTimeObj : this.devA[1002];
      // mod #11166 I-HDFが保存できない zhangyue end
    },

    /**
     * @description 計算用I-HDF時間
     */
    //  del #11166 I-HDFが保存できない zhangyue start
    // iHdeTime() {
    //   if (!this.devA[469]) {
    //     const tmpTimeObj =  {
    //       decimalDigits: 0,
    //       digits : 0,
    //       formLabel : '',
    //       formName : '計算用I-HDF時間',
    //       maxValue : 0,
    //       minValue : 0,
    //       unitName : '',
    //       value: {editValue : 0, initValue : 0}
    //     }
    //     this.devA[469] = tmpTimeObj;
    //   }
    //   return this.devA[469];
    // },
    //  del #11166 I-HDFが保存できない zhangyue end
    // add FNSI-FutreNetWeb+SI課題管理No.5255 李 end

    /**
     * @description I-HDF編集値
     * @returns {Array} 入力項目テキストボックスタイプNumber
     */
    deviceValueNumberList() {
      return [
        this.replenisherSpeed,
        this.replenisherStartTime,
        this.replenisherAmountSetting,
        this.removalWaterRestartTime,
        this.replenisherCycle
      ];
    },

    /**
     * @description 参照透析日
     * @summary
     * @returns {String}
     */
    dialysisDay() {
      if (this.dialysisDate === null) {
        return `透析時間参照なし`;
      }
      const day = moment(this.dialysisDate, "YYYYMMDD").format("MM/DD");
      return `(${day}の透析時間参照)`;
    },

    /**
     * @description 補液回数
     * @summary
     * @returns {any}
     */
    countReplenisher() {
      if (
        this.isCountReplenisherData ||
        this.replenisherRemovalWaterSpeed === "-.--"
      ) {
        // 計算対象項目が未入力の場合、「-(ハイフン)」表示とする(透析時間・補液開始時間・補液周期)
        return "-";
      }
      // add #11166 I-HDFが保存できない zhangyue start
      if (this.enabledCalculationTMP == "true") {
          // TMPゼロ補正開始時間
          if (this.tmpStartTime.value.editValue === '' ||
            this.tmpStartTime.value.editValue === null ||
            // TMPゼロ補正時間
            this.tmpTime.value.editValue === '' ||
            this.tmpTime.value.editValue === null) {
            return '-'
          }
      }
      // add #11166 I-HDFが保存できない zhangyue end
      // 予想補液量が総補液量上限を超えていない場合の補液回数
      let countReplenisher = this.normalCountReplenisher;

      if (this.isMaxProspectReplenisher) {
        // 予想補液量が総補液量上限を超えた場合、超えないよう調整した補液回数
        countReplenisher = this.maxCountReplenisher;
      }

      countReplenisher = Math.floor(countReplenisher);
      // 小数点以下切り捨てとする。

      if (countReplenisher < 0) {
        // 0以下は0表示
        countReplenisher = 0;
      }
      // add #11166 I-HDFが保存できない zhangyue start
      if (isNaN(countReplenisher)) {
        countReplenisher = '-'
      }
      // add #11166 I-HDFが保存できない zhangyue end
      return countReplenisher;
    },

    /**
     * @description 予想補液量が総補液量上限を超えていない場合の補液回数
     * @summary
     * @returns {Number}
     */
    normalCountReplenisher() {
      // TMPゼロ補正なしの場合:補液回数 = (透析時間(min) - 補液開始時間(min)) / 補液周期(min)
      /* modify by chamaojia 2023-07-11 ページエラー訂正  --start */
      let countReplenisher;
      countReplenisher = (countReplenisher =
        (this.dialysisTime - this.replenisherStartTime.value.editValue) /
        this.replenisherCycle.value.editValue);
      /* modify by chamaojia 2023-07-11 ページエラー訂正  --end */
      if (this.enabledCalculationTMP == "true") {
        // del #11166 I-HDFが保存できない zhangyue start
        // TMPゼロ補正ありの場合:補液回数 = (透析時間(min) - 補液開始時間(min) - TMPゼロ補正時間(min)) / 補液周期(min)
        // countReplenisher =
        //   (this.dialysisTime -
        //     this.replenisherStartTime.value.editValue -
        //     // mod FNSI-FutreNetWeb+SI課題管理No.5255 李 start
        //     // mod FNSI-画面デザイン【患者経過総合ビューア.xlsx】数値入力対応 韓 start
        //     // this.TMPTime / 60) /
        //     // this.TMPTime.editValue / 60) /
        //     parseInt(this.tmpTime['value'].editValue) / 60) /
        //     // mod FNSI-画面デザイン【患者経過総合ビューア.xlsx】数値入力対応 韓 end
        //     // mod FNSI-FutreNetWeb+SI課題管理No.5255 李 end
        //   this.replenisherCycle.value.editValue;
        // del #11166 I-HDFが保存できない zhangyue end

        // add #11166 I-HDFが保存できない zhangyue start
        // max値 = 補液開始時間(min) > TMPゼロ補正開始時間(min) + (TMPゼロ補正時間 / 60)  ?
        //         補液開始時間(min) : TMPゼロ補正開始時間(min) + (TMPゼロ補正時間 / 60)
        let maxValue = this.replenisherStartTime.value.editValue > parseInt(this.tmpStartTime.value.editValue) + (parseInt(this.tmpTime.value.editValue) / 60) ?
                       this.replenisherStartTime.value.editValue : parseInt(this.tmpStartTime.value.editValue) + (parseInt(this.tmpTime.value.editValue) / 60)
        // 補液回数 = (透析時間(min) - max値) / 補液周期(min)
        countReplenisher = (this.dialysisTime - maxValue) / this.replenisherCycle.value.editValue;
        // add #11166 I-HDFが保存できない zhangyue end
      }
      return countReplenisher;
    },

    /**
     * @description 予想補液量が総補液量上限を超えた場合の補液回数
     * @summary
     * @returns {Number}
     */
    maxCountReplenisher() {
      // 予想補液量が総補液量上限を超えないように補液回数を調整する。
      // 総補液量上限(L)
      const maxFluidReplacement = this.totalReplenisherUpperLimit.value
        .editValue;
      // 補液回数 = 総補液量上限(L) / (補液量(mL) / 1000)
      const countReplenisher =
        maxFluidReplacement /
        (this.replenisherAmountSetting.value.editValue / 1000);

      return countReplenisher;
    },

    /**
     * @description 補液回数計算対象項目有無
     * @returns {Boolean}
     */
    isCountReplenisherData() {
      return (
        // mod #11166 I-HDFが保存できない zhangyue start
        // 補液開始時間
        this.replenisherStartTime.value.editValue === null ||
        this.replenisherStartTime.value.editValue === '' ||
        // 補液周期
        this.replenisherCycle.value.editValue === null ||
        this.replenisherCycle.value.editValue === '' ||
        // 透析時間
        this.dialysisTime === null ||
        this.dialysisTime === ''
        // mod #11166 I-HDFが保存できない zhangyue end
      );
    },

    /**
     * @description 予想補液量
     * @summary
     * @returns {any}
     */
    prospectReplenisher() {
      if (
        this.isProspectReplenisherData ||
        this.replenisherRemovalWaterSpeed === "-.--"
      ) {
        // 計算対象項目が未入力の場合、「-.-- (ハイフン)」表示とする。
        return "-.--";
      }

      // 予想補液量(L) = 調整補液回数 × 補液量(mL) / 1000
      let prospectReplenisher =
        (this.countReplenisher *
          this.replenisherAmountSetting.value.editValue) /
        1000;
      // 少数第2に切り捨てる
      prospectReplenisher = Math.floor(prospectReplenisher * 100) / 100;

      if (prospectReplenisher < 0) {
        // 0以下は0表示
        prospectReplenisher = 0;
      }

      return prospectReplenisher;
    },

    // add FNSI-I-HDF時間の追加 楊 start
    /**
     * @description I-HDF時間
     * @summary I-HDF時間
     * @returns {Number}
     */
    timeReplenisher() {
      //mod FNSI-FutreNetWeb+SI課題管理 no.6195 張start
      // mod FNSI-FutreNetWeb+SI課題管理No.5255 李 start
      if (this.countReplenisher!='-' && this.replenisherStartTime && this.replenisherStartTime['value'] && this.replenisherCycle && this.replenisherCycle['value']) {
        //mod FNSI-FutreNetWeb+SI課題管理 no.6195 start
        // 計算用透析時間
        // const hourMintue = this.dialysisDisplayTime.split(':');
        // const hour = parseInt(hourMintue[0]) * 60;
        // const mintue = parseInt(hourMintue[1]);

        // 計算用透析時間 - TMPゼロ補正開始時間 - TMPゼロ補正時間[秒]/60
        // const iHdeTimeValue = (hour + mintue) - (parseInt(this.tmpStartTime['value'].editValue)) - Math.ceil(parseInt(this.tmpTime['value'].editValue) / 60);
        // this.iHdeTime['value'].initValue = iHdeTimeValue;
        // this.iHdeTime['value'].editValue = iHdeTimeValue;

        // 計算用透析時間 - TMPゼロ補正開始時間 - TMPゼロ補正時間[秒]/60
        // var iHdeTimeValue = (parseInt(this.tmpStartTime['value'].editValue)) + (parseInt(this.replenisherCycle['value'].editValue)) * this.countReplenisher;
        // var iHdeTimeValue = (parseInt(this.replenisherStartTime['value'].editValue)) + (parseInt(this.replenisherCycle['value'].editValue)) * this.countReplenisher;
        // mod #11166 I-HDFが保存できない zhangyue start
        // I-HDF時間 = 補液周期 × 補液回数
        var iHdeTimeValue = parseInt(this.replenisherCycle['value'].editValue) * this.countReplenisher;
        // mod #11166 I-HDFが保存できない zhangyue end
        //mod FNSI-FutreNetWeb+SI課題管理 no.6195 end
        //mod FNSI-FutreNetWeb+SI課題管理 no.6195 張 end
        return iHdeTimeValue;
      } else {
        // this.iHdeTime['value'].initValue = '-';
        // this.iHdeTime['value'].editValue = '-';
        return "-";
      }

      // if (
      //   this.isCountReplenisherData ||
      //   this.replenisherRemovalWaterSpeed === "-.--"
      // ) {
      //   // 計算対象項目が未入力の場合、「-(ハイフン)」表示とする(透析時間・補液開始時間・補液周期)
      //   return "-";
      // }
      // // 補液開始時間＋補液周期×予定補液回数
      // return (
      //   this.replenisherStartTime.value.editValue +
      //   (this.countReplenisher *
      //     this.replenisherCycle.value.editValue)
      // );
      // mod FNSI-FutreNetWeb+SI課題管理No.5255 李 end
    },
    // add FNSI-I-HDF時間の追加 楊 end

    /**
     * @description 通常予想補液量
     * @summary 通常補液回数の予想補液量
     * @returns {Number}
     */
    normalProspectReplenisher() {
      // 予想補液量(L) = 補液回数 × (補液量(mL) / 1000)
      return (
        (this.normalCountReplenisher *
          this.replenisherAmountSetting.value.editValue) /
        1000
      );
    },

    /**
     * @description 通常予想補液量が総補液量上限を超えたかの有無
     * @summary
     * @returns {Boolean}
     */
    isMaxProspectReplenisher() {
      return (
        this.normalProspectReplenisher >
        this.totalReplenisherUpperLimit.value.editValue
      );
    },

    /**
     * @description 予想補液量計算対象項目有無
     * @returns {Boolean}
     */
    isProspectReplenisherData() {
      return (
        // 補液回数
        this.countReplenisher === "-" ||
        // 補液量
        this.replenisherAmountSetting.value.editValue === null
      );
    },

    /**
     * @description 補液分除水速度
     * @summary
     * @returns {any}
     */
    replenisherRemovalWaterSpeed() {
      // 計算対象項目が未入力の場合、「-.--（ハイフン)」表示とする
      if (this.isReplenisherRemovalWaterSpeed) {
        return "-.--";
      }
      // 補液量
      const replenisher = this.replenisherAmountSetting.value.editValue;

      // 補液分除水速度(L/h) = ( 補液量(mL) × 3.6 ) / 除水時間(sec)
      let replenisherRemovalWaterSpeed =
        (replenisher * 3.6) / this.removalWaterTime;

      // 補液分除水速度は小数第5位以下切捨て後、小数第２位に切り上げる
      replenisherRemovalWaterSpeed =
        Math.floor(replenisherRemovalWaterSpeed * 10000) / 10000;

      replenisherRemovalWaterSpeed =
        Math.ceil(replenisherRemovalWaterSpeed * 100) / 100;

      if (replenisherRemovalWaterSpeed < 0) {
        // 負数なら「-.--（ハイフン)」表示とする
        return "-.--";
      }

      return replenisherRemovalWaterSpeed;
    },

    /**
     * @description 補液時間
     * @summary
     * @returns {Number}
     */
    replenisherTime() {
      // 補液量
      const replenisher = this.replenisherAmountSetting.value.editValue;
      // 補液速度
      const replenisherSpeed = this.replenisherSpeed.value.editValue;
      // 補液時間(sec) = ( 補液量(mL) × 60  / 補液速度(mL/min)) + 4(sec) ※4secを足している意味:補液時にプライミングクランプ開閉の待ち時間が4秒
      return (replenisher * 60) / replenisherSpeed + 4;
    },

    /**
     * @description 除水時間
     * @summary
     * @returns {Number}
     */
    removalWaterTime() {
      // 除水再開時間
      const removalWaterTime = this.removalWaterRestartTime.value.editValue;
      // 補液周期
      const replenisherCycle = this.replenisherCycle.value.editValue;
      // 除水時間(sec) = (補液周期(min) ×60) - 補液時間(sec) - (除水再開時間(min) × 60)
      return (
        replenisherCycle * 60 - this.replenisherTime - removalWaterTime * 60
      );
    },

    /**
     * @description 補液分除水速度計算対象項目
     * @returns {Boolean}
     */
    isReplenisherRemovalWaterSpeed() {
      return (
        // 補液量
        this.replenisherAmountSetting.value.editValue === null ||
        // 補液速度
        this.replenisherSpeed.value.editValue === null ||
        // 補液周期
        this.replenisherCycle.value.editValue === null ||
        // 除水再開時間
        this.removalWaterRestartTime.value.editValue === null
      );
    }
  },

  watch: {
    /**
     * @description 装置設定値
     * @summary ミックスインのcreatedでdeviceSetInfoに選択された各装置設定データが設定される
     */
    deviceSetInfo() {
      // 初期画面切替
      if (!this.isProgramUseChacked) {
        // 使用選択:"0"使用しない
        this.$emit(
          "update:isIhdfMain",
          this.programUse.value.editValue === "0"
        );
        // 親画面の状態を初期化
        const isUseProgram = !(this.programUse.value.editValue === "0");
        this.$emit("init-radio", {
          initVal: isUseProgram,
          editVal: isUseProgram,
          isTreatRecord: this.isTreatRecord
        } );
        // 選択状態確認フラグ
        this.$emit("update:isProgramUseChacked", true);
      }
      this.$nextTick(() => {
        // 画面から変数を変更できなくしたため手動変更
        this.programUse.value.editValue = "0";
      });

      // TMP監視モード:初期表示設定
      let warTMPMonitoring = valueInfoWar.dev.A[240].initValue;
      // TMPゼロ補正：初期表示設定
      let opeTMPZeroCorrection = valueInfoOpe.dev.A[241].initValue;
      // 警報点・操作範囲の装置設定値があればそれを設定する
      // mod #11166 I-HDFが保存できない zhangyue start
      // if(this.selectedPat != null){
        // const devInfo =
        //   this.dataSourceType === DATA_SOURCE_TYPE_MST
        //     ? this.deviceSetInfoRaw.pat
        //     : JSON.parse(this.selectedPat.pat_main.device_set_info);
        let devInfo;
        switch (this.dataSourceType) {
          case DATA_SOURCE_TYPE_MST:
            devInfo = this.deviceSetInfoRaw.pat;
            break;
          case DATA_SOURCE_TYPE_ORD:
            devInfo = this.deviceSetInfoRaw;
            break;
          case DATA_SOURCE_TYPE_MST_EDIT_RECORD:
            devInfo = this.deviceSetInfoMst?.pat;
            let devInfoOrd = this.deviceSetInfoMst?.ord;
            this.tmpStartTimeObj.value.editValue = devInfoOrd?.ihdf?.dev?.A[1001];
            this.tmpTimeObj.value.editValue = devInfoOrd?.ihdf?.dev?.A[1002];
            break;
          case DATA_SOURCE_TYPE_TREAT:
            devInfo = JSON.parse(this.deviceSetInfoRaw);
            break;
          default:
            devInfo = JSON.parse(this.selectedPat.pat_main.device_set_info);
            break;
        }
        if (
          devInfo &&
          devInfo[DEVICE_TYPE_WAR] &&
          devInfo[DEVICE_TYPE_WAR].dev.A[240]
        ) {
          warTMPMonitoring = devInfo[DEVICE_TYPE_WAR].dev.A[240];
        }
        if (
          devInfo &&
          devInfo[DEVICE_TYPE_OPE] &&
          devInfo[DEVICE_TYPE_OPE].dev.A[241]
        ) {
          opeTMPZeroCorrection = devInfo[DEVICE_TYPE_OPE].dev.A[241];
        }
      // }

      // 計算用TMPゼロ補正の有効判定
      // ※警報devA[0240] 0：TMP自動追従、1：TMP自動設定 ※操作devA[0241] 0：あり
      if (
        opeTMPZeroCorrection == "0"
        // warTMPMonitoring === "0" ||
        // (warTMPMonitoring === "1" && opeTMPZeroCorrection === "0")
      ) {
        // 警報点画面のTMP監視モードが「0:TMP自動追従」,
        // または警報点画面のTMP監視モードが「TMP自動設定」かつ操作範囲画面のTMPゼロ補正の選択が「あり」
        this.enabledCalculationTMP = "true";
      } else {
        this.enabledCalculationTMP = "false";
      }
      // mod #11166 I-HDFが保存できない zhangyue end
      // TODO:初期状態：システム設定(ID:127)の値 未参照
      // 固定値TMPゼロ補正時間
      // del FNSI-FutreNetWeb+SI課題管理No.5255 李 start
      // mod FNSI-画面デザイン【患者経過総合ビューア.xlsx】数値入力対応 韓 start
      // this.TMPTime = 120;
      // this.TMPTime.initValue = 120;
      // this.TMPTime.editValue = 120;
      // mod FNSI-画面デザイン【患者経過総合ビューア.xlsx】数値入力対応 韓 start
      // del FNSI-FutreNetWeb+SI課題管理No.5255 李 end
      this.minTMPTime = 120;
      this.maxTMPTime = 600;

      // 初期状態：指示装置設定画面のみ透析予定・透析時間は参照する。
      if (this.dataSourceType === DATA_SOURCE_TYPE_ORD) {
        // 保存した再検索時の計算用透析時間を取得
        const dialysisTimeData = this.getDialysisTimeData
        if(dialysisTimeData){
            // 選択された日付に透析時間が設定されている場合
            this.dialysisDate = dialysisTimeData.dialysisDate;
            // 透析時間(分)設定
            this.dialysisTime = dialysisTimeData.dialysisTime;
            // 透析時間："HH:mm"設定
            this.dialysisDisplayTime = dialysisTimeData.dialysisDisplayTime;
            // 透析日表示フラグ
            this.isDialysisDay = true;
        }else{
          // 選択した日付
          const selectedDate = this.getSettingIndChildData.treatDate;

          // 指示番号設定
          const listIndex = this.getSettingIndChildData.listIndex;
          // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
          // const indCondInfo = this.getTreatmentData[listIndex][selectedDate]
          //   .indCondInfo;
          let indCondInfo = this.getTreatmentData[listIndex][selectedDate]?.indCondInfo;
          if (!indCondInfo) {
            indCondInfo = this.getRecentTreatmentDate[listIndex][selectedDate]?.indCondInfo;
          }
          // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
          const dialysisTime = JSON.parse(indCondInfo)["1"].value;

          if (dialysisTime !== null) {
            // 選択された日付に透析時間が設定されている場合
            this.dialysisDate = selectedDate;

            // 透析時間(分)設定
            this.dialysisTime = this.correctDialysisTime(Number(dialysisTime));
            // 時間形式に変換
            const time = String(Math.floor(this.dialysisTime / 60));
            const minutes = String(this.dialysisTime % 60);
            // 透析時間："HH:mm"設定
            this.dialysisDisplayTime = moment(
              `${time}:${minutes}`,
              "HH:mm"
            ).format("HH:mm");

            // 透析日表示フラグ
            this.isDialysisDay = true;
          }
        }
      } else if (this.dataSourceType === DATA_SOURCE_TYPE_TREAT) {
        // -----治療記録 > 装置設定 > I-HDF-----
        if (this.deviceType === DEVICE_TYPE_IHDF) {
          // 実績：治療条件情報の取得
          const rstCondInfo = this.getRstCondInfo;
          // 実績：治療条件情報有の場合
          if (rstCondInfo != null) {
            // 透析時間の取得
            const dialysisTime = JSON.parse(rstCondInfo)["1"].value;
            // 透析時間有の場合
            if (dialysisTime != null) {
              // 治療日時の格納
              this.dialysisDate = this.getTreatDate;
              // 透析時間の取得
              this.dialysisTime = this.correctDialysisTime(Number(dialysisTime));
              // 透析時間(時)の算出
              const time = String(Math.floor(this.dialysisTime / 60));
              // 透析時間(分)の算出
              const minutes = String(this.dialysisTime % 60);
              // 透析時間(HH:mm)の作成
              this.dialysisDisplayTime = moment(`${time}:${minutes}`, "HH:mm").format("HH:mm");
              // 透析日表示フラグ
              this.isDialysisDay = true;
            }
          }
        }
      }
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
      this.initModelValue = JSON.parse(JSON.stringify(this.devA));
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end
      // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start
      this.$nextTick(()=>{
        if (this.getIhdfAnswerThreeDevA) {
          let devA = this.getIhdfAnswerThreeDevA;
          for (let key in this.devA) {
            if (devA[key]) {
              this.devA[key].value.editValue = devA[key];
            }
          }
        }
      })
      // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end
    }
  },

  methods: {
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start
    ...mapActions('pat-viewer-modal', ["setIhdfAnswerThreeDevA","setDialysisTimeData"]),
    // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return this.isMst || (this.isMst != true && getAuthorized(pageCd, itemCd));
    },
    // add #10359 編集権限の動作不正 dengshen end
    /**
     * @description 計算用透析時間
     * @param {String} value 時間
     */
    inputValue(value) {
      // 設定値が空欄か判定
      if (value === null || value === "") {
        this.dialysisTime = null;
      } else {
        // 空欄でなければ時間を分に変換
        const time = moment(value, "HH:mm").format("HH");
        const minutes = moment(value, "HH:mm").format("mm");
        this.dialysisTime = Number(time) * 60 + Number(minutes);
      }
      // 表示変更の為、値設定
      this.dialysisDisplayTime = value;
      // 変更時,参照した透析日を非表示とする。
      this.isDialysisDay = false;
    },

    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    setInputNumberChange() {
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア_I-HDF設定 20240123 ztc start
      // EventBus.$emit("deviceSetChanged");
      // #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start
      // this.changeButton();
      this.$nextTick(()=>{
        this.changeButton();
      })
      // #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア_I-HDF設定 20240123 ztc end
    },
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end

    /**
     * @description TMPゼロ補正時間上下限設定
     * @param {String} value 時間
     */
    inputTMPTimeValue(value) {
      // 上下限範囲内にいない場合は上下限を設定させる
      if (value < this.minTMPTime) {
        // mod FNSI-画面デザイン【患者経過総合ビューア.xlsx】数値入力対応 韓 start
        // this.TMPTime = this.minTMPTime;
        this.TMPTime.editValue = this.minTMPTime;
        // mod FNSI-画面デザイン【患者経過総合ビューア.xlsx】数値入力対応 韓 end
      } else if (value > this.maxTMPTime) {
        // mod FNSI-画面デザイン【患者経過総合ビューア.xlsx】数値入力対応 韓 start
        // this.TMPTime = this.maxTMPTime;
        this.TMPTime.editValue = this.maxTMPTime;
        // mod FNSI-画面デザイン【患者経過総合ビューア.xlsx】数値入力対応 韓 end
      }
    },

    /**
     * @description 未編集通知ダイアログ後保存ボタンを活性へ(指示画面のみ)
     */
    saveEdit() {
      if (this.dataSourceType === DATA_SOURCE_TYPE_ORD) {
        this.$emit("save-edit");
      }
    },

    /**
     * @description キャンセル確認ダイアログ表示
     */
    showChangeDisplayDialog() {
      this.isChangeDisplayDialogVisble = true;
      // ダイアログに与えるprops作成
      this.dialogProps = { messageCd: 20010001 };
    },

    /**
     * @description 編集キャンセル
     */
    changeDisplayEdit(answer) {
      if (answer === "OK") {
        this.$emit("update:isIhdfMain", false);
      } else {
        // 親コンポーネントのラジオボタン状態を操作
        this.$emit("change-radio", false);
      }
      this.isChangeDisplayDialogVisble = false;
    },

    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
    isEdit() {
      const treatCondItems = this.$refs;
      let editCount = 0;
      Object.keys(treatCondItems).forEach(key => {
        // add #11166 I-HDFが保存できない zhangyue start
        if (this.dataSourceType !== DATA_SOURCE_TYPE_MST) {
          if (key === 'required-startTime') {
            return false;
          } else if(key === 'required-tmpTime') {
            return false;
          }
        }
        // add #11166 I-HDFが保存できない zhangyue end
        if ((treatCondItems[key] && treatCondItems[key].isEdited)
          || (treatCondItems[key][0] && treatCondItems[key][0].isEdited)) {

          // 変更箇所数格納
          editCount += 1;
        }
      });
      // del #11166 I-HDFが保存できない zhangyue start
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
      // if(this.initEnabledCalculationTMP !== JSON.stringify(this.enabledCalculationTMP)){
      //   editCount += 1;
      // }
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
      // del #11166 I-HDFが保存できない zhangyue end
      if (0 === editCount) {
        return false;
      }
      return true;
    },
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end

    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
    async resetComponentIndData(structData){
      if (this.isEdit()) {
        this.$parent.$parent.$parent.messageDialogInfo.messageCd = 70000028;
        /* mod FNSI-4212 更新対象変更時のウインドウが不正 liumx start */
        this.$parent.$parent.$parent.messageDialogInfo.type = "9";
        /* mod FNSI-4212 更新対象変更時のウインドウが不正 liumx end */
        this.$parent.$parent.$parent.messageDialogInfo.isDialogVisible = true;
        return;
      } else {
        this.getComponentData(structData,2);
      }

    },
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end

    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
    async getComponentData(structData,answer) {
      if (answer === 1) {
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
        getErrorMessage('IHdfEditor.vue', 'getComponentData', error);
        throw error;
      });
      let ordMainData = response.data;
      if(ordMainData && ordMainData.length > 0) {
        ordMainData = ordMainData[0];
      } else {
        return;
      }

      if (ordMainData.indDeviceSetInfo != null && ordMainData.indDeviceSetInfo != undefined) {
        let tempData = JSON.parse(ordMainData.indDeviceSetInfo);
        if (tempData != null && tempData != undefined) {
          if (answer == 3) {
            for (let key in this.initModelValue) {
              if (this.devA[key].value.editValue != this.initModelValue[key].value.editValue) {
                tempData.ihdf.dev.A[key] = this.devA[key].value.editValue;
              }
            }
          }
          for (let key in this.devA) {
            // mod #11166 I-HDFが保存できない zhangyue start
            if (this.devA[key].hasOwnProperty('step') && this.devA[key].hasOwnProperty('decimalDigits')) {
              // #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start
              // this.devA[key].value.editValue = tempData.ihdf.dev.A[key]?.toFixed(this.devA[key].decimalDigits);
              this.devA[key].value.editValue = tempData.ihdf.dev.A[key] != null ? Number(tempData.ihdf.dev.A[key])?.toFixed(this.devA[key].decimalDigits) : null;
              // #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end
            } else {
              this.devA[key].value.editValue = tempData.ihdf.dev.A[key];
            }
            // mod #11166 I-HDFが保存できない zhangyue end
            // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start
            if (key == 1001) {
              this.devA[key].value.editValue = this.devA[key].value.editValue ?? this.deviceSetInfoRaw.ihdf.dev.A[1001];
            }
            if (key == 1002) {
              this.devA[key].value.editValue = this.devA[key].value.editValue ?? this.deviceSetInfoRaw.ihdf.dev.A[1002];
            }
            this.devA[key].value.initValue = this.devA[key].value.editValue;
            // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end
          }
          // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start
          if (tempData?.ihdf?.dev?.A) {
            this.$emit("change-start-date", tempData.ihdf.dev.A, answer);
          }
          // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end
        }
      }
      // add #11166 I-HDFが保存できない zhangyue start
      // 編集破棄時
      if (answer == 2 && ordMainData.indCondInfo !== null && ordMainData.indCondInfo !== undefined) {
        // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
        // const indCondInfo = this.getTreatmentData[listIndex][selectedDate]
        //   .indCondInfo;
        let indCondInfo = ordMainData.indCondInfo;
        // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
        const dialysisTime = JSON.parse(indCondInfo)["1"].value;

        if (dialysisTime !== null) {
          // 選択された日付に透析時間が設定されている場合
          this.dialysisDate = ordMainData.treatDate;

          // 透析時間(分)設定
          this.dialysisTime = this.correctDialysisTime(Number(dialysisTime));
          // 時間形式に変換
          const time = String(Math.floor(this.dialysisTime / 60));
          const minutes = String(this.dialysisTime % 60);
          // 透析時間："HH:mm"設定
          this.dialysisDisplayTime = moment(
            `${time}:${minutes}`,
            "HH:mm"
          ).format("HH:mm");

          // 透析日表示フラグ
          this.isDialysisDay = true;
        }
        // 取得した計算用透析時間を保持
        const dialysisTimeData = {
          dialysisDate : this.dialysisDate,
          dialysisTime : this.dialysisTime,
          dialysisDisplayTime : this.dialysisDisplayTime,
        }
        this.setDialysisTimeData(dialysisTimeData);
      }
      // add #11166 I-HDFが保存できない zhangyue end
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
      this.initModelValue = JSON.parse(JSON.stringify(this.devA));
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end
    },
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end
    mstSetTime() {
      if ("mst_treatment_set" === this.getMasterName && this.getEditRecord.indCondInfo !== undefined) {
        let temp = JSON.parse(this.getEditRecord.indCondInfo)[1].value;
        let hour = parseInt(temp/60);
        let min = parseInt(temp%60);
        let str = "";
        if (hour < 10) {
          str += "0" + hour;
        } else {
          str += hour;
        }
        str += ":";
        if (min < 10) {
          str += "0" + min;
        } else {
          str += min;
        }
        this.dialysisDisplayTime = str;
        this.inputValue(this.dialysisDisplayTime);
      }
    },
    changeButton() {
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア_I-HDF設定 20240123 ztc start
      // EventBus.$emit( "mstTreatmentSetRegistered", val);
      EventBus.$emit("mstTreatmentSetRegistered", !this.isEdit());
      this.$parent.$parent.$parent.ihdfChangeFlag = this.isEdit();
      // if(false === val) {
      //   EventBus.$emit("deviceSetChanged");
      // }
      EventBus.$emit("deviceSetChanged", this.isEdit());
      this.isTMPEdited = this.initEnabledCalculationTMP !== JSON.stringify(this.enabledCalculationTMP);
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア_I-HDF設定 20240123 ztc end
    },
    /**
     * 計算用透析時間＞09:59 09:59で補正
     */
    correctDialysisTime(dialysisTime){
      if(dialysisTime > this.MAX_DIALYSIS_TIME){
        return this.MAX_DIALYSIS_TIME;
      }
      return dialysisTime;
    },
   // add #12462 患者情報共有 Ji start
  /**
   * @description 該当行が他院情報かどうかを判定
   * @returns {Boolean} true = 他施設のデータは参照のみ
   */
    isOtherFacilityRow() {
      if (!this.getSettingIndChildData) {
        return false
      }
      return this.getSettingIndChildData.facilityCd ? this.getSettingIndChildData.facilityCd !== this.getFacilityCd : false
    }
    // add #12462 患者情報共有 Ji end
  },

  //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
  async created() {
    this.setLoadingScreenVisible(true);
    this.$parent.$parent.$parent.isDialogType9_ihdf = true;
  },
  //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end
  // add redmine 6190 I-HDFプログラム使用選択の使用する／しないを切り替えると画面が崩れる 宋qy start
  mounted() {
    setTimeout(() => {
      this.mstSetTime();
      this.setLoadingScreenVisible(false);
    },500);
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
    this.initEnabledCalculationTMP = JSON.stringify(this.enabledCalculationTMP)
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
  }
  // add redmine 6190 I-HDFプログラム使用選択の使用する／しないを切り替えると画面が崩れる 宋qy end
};
</script>

<style src="../base-modules/BeseDeviceSetInfoStyle.css" scoped></style>
<style scoped>
/*add FNSI-画面部品デザイン じょはく start*/
.calculation-size-set-small {
  left: 70em;
}
.calculation-size-set-medium {
  left: 54em;
}
.calculation-size-set-large {
  left: 49em;
}
.calculation-size-set-x-large {
  left: 42em;
}
/*add FNSI-画面部品デザイン じょはく end*/
.device-info-main-content {
  max-height: none;
  overflow: none;
}

.i-hdf-img {
  width: 58.5em;
}

/* 画面配置 */
/*mod FNSI-画面部品デザイン じょはく start*/
.device-info-cell-content {
  width: 100%;
  /* add FNSI redmine #4542修正 鄧シン start */
  height: 100%;
  /* add FNSI redmine #4542修正 鄧シン end */
  /*margin: auto;*/
  display: flex;
  flex-flow: nowrap;
  justify-content: center;
}
/*mod FNSI-画面部品デザイン じょはく end*/

.device-info-img-content {
  position: relative;
  color: black;
}

.deviceSetInfo-input {
  position: absolute;
}

.device0 {
  top: 34%;
  left: 2%;
}

.device1 {
  top: 34%;
  left: 15%;
}

.device2 {
  top: 34%;
  left: 27%;
}

.device3 {
  top: 34%;
  left: 41%;
}

.device4 {
  top: 14%;
  left: 47%;
}

.device-filtrate {
  top: 73%;
  left: 3%;
}

/* 計算エリア */
.calculation-disclaimer {
  font-weight: initial;
  text-align: initial;
  border: 1px solid;
}

.calculation-area .deviceSetInfo-input {
  position: initial;
}

.removing-water-speed {
  top: 87%;
  right: 35%;
}

.device-blanks1 {
  top: 59%;
  right: 35%;
}

.device-blanks2 {
  top: 73%;
  right: 35%;
}

.removing-water-speed,
.device-blanks1,
.device-blanks2 {
  width: 70px;
  position: absolute;
}

.calculation-disclaimer-day {
  height: 20px;
}

.device-info-left {
  text-align: left;
}

/** iPhone X/8/7/6 or Android(M,L) */
/** Device Width:360-480           */
/** ボックス要素-スクロール制御 */
@media only screen and (min-device-width:360px) and (max-device-width:480px) {
  .device-info-img-content >>> .custom-input-number {
  height: 1.0em !important;
  font-size: 0.92em !important;
  width: 10vw !important;
  }
}

.device-input-number >>> .custom-input-number {
  width: 5.5em;
}

@media print {
  .device-info-img-content {
    height: fit-content !important;
  }
  .i-hdf-img{
    width: 100% !important;
  }
  .device4{
    left: 44% !important;
  }
}
/* 縦向き印刷時のみ */
@media print and (orientation: portrait) {
  .device-info-img-content >>> .custom-input-number {
    width: 3.5em !important;
  }
  .device-info-img-content >>> .custom-input-number input[type="number"] {
    height: 1.3em !important;
  }
}
</style>
