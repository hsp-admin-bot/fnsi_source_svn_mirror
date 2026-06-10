<!--血流量・透析液流量プログラム-->
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
          血流量・透析液流量プログラム
        </v-ons-row>
        <v-ons-row v-else class="device-info-main-title" />
        <v-ons-row class="device-info-main-content">
          <v-ons-col class="chart-area">
            <!-- グラフ -->
            <v-ons-row class="device-info-cell">
              <v-ons-col>
                <highcharts :options="chartOptions" class="high-charts" ref="refQbqdChart" :class="isUnderSubModal" />
              </v-ons-col>
            </v-ons-row>
            <!-- 9446 QB・QDプログラム画面が不正 関俊楠 start -->
            <!-- 項目:血流量 -->
            <v-ons-row class="device-info-cell">
              <v-ons-col style="flex: 0 0 100px">
                <div class="device-info-cell-title">
                  血流量<br />
                  mL/min
                </div>
              </v-ons-col>
              <v-ons-row style="flex: 1;">
                <v-ons-col
                  v-for="(device, index) in bloodFlow"
                  :key="index"
                  class="device-info-cell-value device-info-cell-center"
                >
                  <!-- mod FNSI-5993 劉全航 start -->
                  <!-- <device-input-number
                    :ref="`required2_${index}`"
                    :device-info="device"
                    :disabled="
                      isTreatRecord || index >= devA[429].value.editValue
                    "
                    class="device-input-charts"
                    @change="bloodFlowChangeButton(device, false)"
                  /> -->
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   :ref="`required2_${index}`" -->
                  <!--   :device-info="device" -->
                  <!--   :disabled=" -->
                  <!--   isTreatRecord || index >= devA[429].value.editValue -->
                  <!-- " -->
                  <!--   class="device-input-charts" -->
                  <!--   @input="setInputNumberChange" -->
                  <!--   @wheel.prevent="setInputNumberChange" -->
                  <!--   @keydown.up.prevent="setInputNumberChange" -->
                  <!--   @keydown.down.prevent="setInputNumberChange" -->
                  <!-- /> -->
                  <device-input-number
                    :ref="`required2_${index}`"
                    :device-info="device"
                    :disabled="isTreatRecord || index >= devA[429].value.editValue || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                    class="device-input-charts"
                    @input="setInputNumberChange"
                    @wheel.prevent="setInputNumberChange"
                    @keydown.up.prevent="setInputNumberChange"
                    @keydown.down.prevent="setInputNumberChange"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <!-- mod FNSI-5993 劉全航 end -->
                </v-ons-col>
              </v-ons-row>
            </v-ons-row>
            <!-- 項目:透析液流量 -->
            <v-ons-row class="device-info-cell">
              <v-ons-col style="flex: 0 0 100px">
                <div class="device-info-cell-title">
                透析液流量<br />
                mL/min
                </div>
              </v-ons-col>
              <v-ons-row style="flex: 1;">
              <v-ons-col
                v-for="(device, index) in dialysisfluidFlow"
                :key="index"
                class="device-info-cell-value device-info-cell-center"
              >
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
                <!-- <device-input-number
                  :ref="`required1_${index}`"
                  :device-info="device"
                  :disabled="
                    isTreatRecord || index >= devA[429].value.editValue
                  "
                  class="device-input-charts"
                  @change="changeButton(false)"
                  @input="setInputNumberChange"
                  @wheel.prevent="setInputNumberChange"
                  @keydown.up.prevent="setInputNumberChange"
                  @keydown.down.prevent="setInputNumberChange"
                /> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   :ref="`required1_${index}`" -->
                <!--   :device-info="device" -->
                <!--   :disabled=" -->
                <!--     isTreatRecord || index >= devA[429].value.editValue -->
                <!--   " -->
                <!--   class="device-input-charts" -->
                <!--   @input="setInputNumberChange" -->
                <!--   @wheel.prevent="setInputNumberChange" -->
                <!--   @keydown.up.prevent="setInputNumberChange" -->
                <!--   @keydown.down.prevent="setInputNumberChange" -->
                <!-- /> -->
                <device-input-number
                  :ref="`required1_${index}`"
                  :device-info="device"
                  :disabled="isTreatRecord || index >= devA[429].value.editValue || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                  class="device-input-charts"
                  @input="setInputNumberChange"
                  @wheel.prevent="setInputNumberChange"
                  @keydown.up.prevent="setInputNumberChange"
                  @keydown.down.prevent="setInputNumberChange"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
              </v-ons-col>
            </v-ons-row>
            </v-ons-row>
            <!-- 9446 QB・QDプログラム画面が不正 関俊楠 end -->

            <!-- 項目:切替 -->
            <v-ons-row class="device-info-cell">
              <v-ons-col style="flex: 0 0 100px">
                <div class="device-info-cell-title">
                切替時間<br />
                 [分]
                </div>
              <!-- 中央寄席にする -->

              </v-ons-col>
              <v-ons-row style="flex: 1;">
                  <v-ons-col
                    v-for="(device, index) in changeoverTime"
                    :key="index"
                    class="device-info-cell-value  device-info-cell-center"
                  >
                    <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
                    <!-- <device-input-number
                      :ref="`required3_${index}`"
                      :device-info="device"
                      :disabled="
                        isTreatRecord || index >= devA[429].value.editValue - 1
                      "
                      class="device-input-charts"
                      @change="changeButton(false)"
                      @input="setInputNumberChange"
                      @wheel.prevent="setInputNumberChange"
                      @keydown.up.prevent="setInputNumberChange"
                      @keydown.down.prevent="setInputNumberChange"
                    /> -->
                    <!-- mod #10359 編集権限の動作不正 dengshen start -->
                    <!-- <device-input-number -->
                    <!--   :ref="`required3_${index}`" -->
                    <!--   :device-info="device" -->
                    <!--   :disabled=" -->
                    <!--     isTreatRecord || index >= devA[429].value.editValue - 1 -->
                    <!--   " -->
                    <!--   class="device-input-charts" -->
                    <!--   @input="setInputNumberChange" -->
                    <!--   @wheel.prevent="setInputNumberChange" -->
                    <!--   @keydown.up.prevent="setInputNumberChange" -->
                    <!--   @keydown.down.prevent="setInputNumberChange" -->
                    <!-- /> -->
                    <device-input-number
                      :ref="`required3_${index}`"
                      :device-info="device"
                      :disabled="isTreatRecord || index >= devA[429].value.editValue - 1 || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                      class="device-input-charts"
                      @input="setInputNumberChange"
                      @wheel.prevent="setInputNumberChange"
                      @keydown.up.prevent="setInputNumberChange"
                      @keydown.down.prevent="setInputNumberChange"
                    />
                    <!-- mod #10359 編集権限の動作不正 dengshen end -->
                    <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
                  </v-ons-col>
              </v-ons-row>
            </v-ons-row>
          </v-ons-col>
          <v-ons-col class="sub-area">
            <v-ons-row>
              <!-- 9446 QB・QDプログラム画面が不正 start -->
              <v-ons-col class="sub-area-item">
                <div>
                  {{ devA[430].formLabel }}
                </div>
                <!--add FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 start-->
                <!--
                 <div class="device-info-cell-rigth">
                  <device-radio
                    ref="radio2"
                    :device-info="devA[430]"
                    :disabled="isTreatRecord"
                  />
                -->
                <div class="device-info-cell-rigth">
                  <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
                  <!-- <device-radio
                    ref="radio2"
                    :device-info="devA[430]"
                    :disabled="isTreatRecord || isIhdf"
                    @change="changeButton(false)"
                  /> -->
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-radio -->
                  <!--   ref="radio2" -->
                  <!--   :device-info="devA[430]" -->
                  <!--   :disabled="isTreatRecord || isIhdf" -->
                  <!-- /> -->
                  <device-radio
                    ref="radio2"
                    :device-info="devA[430]"
                    :disabled="isTreatRecord || isIhdf || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
                  <!--add FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 end-->
                </div>
                <div>
                  <span v-show="devA[430].value.editValue === '1'">
                    <div>
                      平均流量
                    </div>
                    <div class="device-info-cell-rigth">
                      {{ averageFlowQB }}mL/min
                    </div>
                  </span>
                </div>
              </v-ons-col>
              <v-ons-col class="sub-area-item">
                <div>
                  {{ devA[431].formLabel }}
                </div>
                <!--add FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 start-->
                <!--
                 <div class="device-info-cell-rigth">
                  <device-radio
                    ref="radio1"
                    :device-info="devA[431]"
                    :disabled="isTreatRecord"
                  />
                -->
                <div class="device-info-cell-rigth">
                  <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
                  <!-- <device-radio
                    ref="radio1"
                    :device-info="devA[431]"
                    :disabled="isTreatRecord || isIhdf"
                    @ihdf-modal="setEditValue"
                    @change="changeButton(false)"
                  /> -->
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-radio -->
                  <!--   ref="radio1" -->
                  <!--   :device-info="devA[431]" -->
                  <!--   :disabled="isTreatRecord || isIhdf" -->
                  <!--   @ihdf-modal="setEditValue" -->
                  <!-- /> -->
                  <device-radio
                    ref="radio1"
                    :device-info="devA[431]"
                    :disabled="isTreatRecord || isIhdf || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                    @ihdf-modal="setEditValue"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
                  <!--add FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 end-->
                </div>
                <div>
                  <span v-show="devA[431].value.editValue === '1'">
                    <div>
                      平均流量
                    </div>
                    <div class="device-info-cell-rigth">
                      {{ averageFlowQD }}mL/min
                    </div>
                  </span>
                </div>
              </v-ons-col>
              <!-- 9446 QB・QDプログラム画面が不正 end -->
              <v-ons-col class="sub-area-item">
                <div>
                  計算用透析時間
                </div>
                <div class="device-info-cell-rigth">
                  <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start -->
                  <!-- <input
                    :value="dialysisDisplayTime"
                    type="time"
                    class="device-info-cell-rigth"
                    :disabled="isTreatRecord"
                    @input="inputValue($event.target)"
                    @change="changeButton(false)"
                  /> -->
                  <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
                  <!-- <time-input
                    :value="dialysisDisplayTime"
                    type="time"
                    class="time-span"
                    :class="{'time-span-edited': timeEditFlg}"
                    :disabled="isTreatRecord"
                    @input="inputValue"
                    @change="changeTime()"
                    @handleClearInput="dialysisDisplayTime = null;changeButton(false)"
                  /> -->
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <time-input -->
                  <!--   :value="dialysisDisplayTime" -->
                  <!--   :disabled="isTreatRecord" -->
                  <!--   max="10:00" -->
                  <!--   default-time="00:00" -->
                  <!--   @input="inputValue" -->
                  <!--   @change="changeTime()" -->
                  <!--   @handleClearInput="dialysisDisplayTime = null" -->
                  <!-- /> -->
                  <time-input
                    :value="dialysisDisplayTime"
                    :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                    max="09:59"
                    default-time="00:00"
                    @input="inputValue"
                    @change="changeTime()"
                    @handleClearInput="dialysisDisplayTime = null; inputValue(null)"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
                  <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end -->
                </div>
                <div v-if="isDialysisDay" class="calculation-disclaimer-day">
                  <span class="calculation-disclaimer">
                    {{ dialysisDay }}
                  </span>
                </div>
                <div class="calculation-disclaimer">
                  計算用の透析時間であり、<br />
                  本入力では透析時間指示の<br />
                  変更は実施されません
                </div>
              </v-ons-col>
              <!-- ステップ数 -->
              <v-ons-col class="sub-area-item">
                {{ devA[429].formLabel }}
                <div class="device-info-cell-rigth">
                  <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
                  <!-- <device-input-number
                    :ref="`required1`"
                    :device-info="devA[429]"
                    :disabled="isTreatRecord"
                    @change="changeButton(false)"
                    @input="setInputNumberChange"
                    @wheel.prevent="setInputNumberChange"
                    @keydown.up.prevent="setInputNumberChange"
                    @keydown.down.prevent="setInputNumberChange"
                  /> -->
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   :ref="`required1`" -->
                  <!--   :device-info="devA[429]" -->
                  <!--   :disabled="isTreatRecord" -->
                  <!--   @input="setInputNumberChange" -->
                  <!--   @wheel.prevent="setInputNumberChange" -->
                  <!--   @keydown.up.prevent="setInputNumberChange" -->
                  <!--   @keydown.down.prevent="setInputNumberChange" -->
                  <!-- /> -->
                  <device-input-number
                    :ref="`required1`"
                    :device-info="devA[429]"
                    :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                    @input="setInputNumberChange"
                    @wheel.prevent="setInputNumberChange"
                    @keydown.up.prevent="setInputNumberChange"
                    @keydown.down.prevent="setInputNumberChange"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
                </div>
              </v-ons-col>
            </v-ons-row>
          </v-ons-col>
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
import _ from "underscore";
import moment from "moment";
import { mapActions, mapGetters } from "vuex";
import { Chart } from "highcharts-vue";
import {
  DATA_SOURCE_TYPE_ORD,
  DATA_SOURCE_TYPE_TREAT,
  DEVICE_TYPE_QBQD
} from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
import baseEditor from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoEditor.vue";
// add FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 start
import { EventBus } from "@/eventBus.js";
// add FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 end
import { ApiHelper } from "@/apis/AxiosHelper";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { getDeviceSetInfoMst } from "@/components/deviceset-info/base-modules/DeviceSetInfoFunctions.js";
// #5590 2023/04/20 ×を常に表示するように修正 林峻峰 start
import TimeInput from "@/components/common/TimeInput.vue";
// #5590 2023/04/20 ×を常に表示するように修正 林峻峰 end

// グラフx軸変換関数
const formatter = function(value) {
  if (value < 1) {
    // 0.5 → "00:30"へ変換
    return moment(value * 60, "s").format("mm:ss");
  }
  // 1 → "01:00"へ変換
  return moment(value, "m").format("mm:ss");
};

/**
 * @description Na注入プログラム設定値編集画面
 */
export default {
  components: {
    highcharts: Chart,
    // #5590 2023/04/20 ×を常に表示するように修正 林峻峰 start
    TimeInput,
    // #5590 2023/04/20 ×を常に表示するように修正 林峻峰 end
  },

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
      deviceType: DEVICE_TYPE_QBQD,
      // 透析日の表示有無
      isDialysisDay: false,
      // 透析日
      dialysisDate: null,
      // 計算用透析時間:画面表示用 指示以外は初期値を「00：00」
      dialysisDisplayTime: "00:00",
      // mod FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 start
      // 治療モードをI-HDFの場合
      isIhdf: false,
      // mod FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 start
      // 計算用透析時間:処理用
      dialysisTime: 0,

      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、yuqizheng add start
      initModelValue:undefined,
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、yuqizheng add end

      deviceSetInfoMst: [],
      // #6765 計画-血流量・透析液流量プログラム：修正時、修正していないが保存ボタンが有効になってしまっている 林峻峰 start
      dialysisDisplayTimeInit: "",
      timeEditFlg: false,
      // #6765 計画-血流量・透析液流量プログラム：修正時、修正していないが保存ボタンが有効になってしまっている 林峻峰 end
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start
      devADefault: {},
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end
      // 計算用透析時間のMAX値 09:59
      MAX_DIALYSIS_TIME: 599
    };
  },

  computed: {
    // add #7994 2022/10/10 【デグレ】血流量・透析液流量プログラムの計算用透析時間が0のまま dou start
    ...mapGetters("pat-viewer-treat-cond", {treatTime: "getTreatTime"}),
    // add #7994 2022/10/10 【デグレ】血流量・透析液流量プログラムの計算用透析時間が0のまま dou end
    // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
    // ...mapGetters("pat-viewer", ["getTreatmentData"]),
    ...mapGetters("pat-viewer", ["getTreatmentData", "getRecentTreatmentDate"]),
    // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
    // mod FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 start
    // ...mapGetters("pat-viewer-modal", ["getSettingIndChildData"]),
    ...mapGetters("pat-viewer-modal", ["getSettingIndChildData", "getIsShowQbqdProgramModal"]),
    // mod FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 end
    ...mapGetters("master-maintenance", {getFacilitySwitch: "getFacilitySwitch"}),
    ...mapGetters("account-edit", {
      fontSize: "getFontSize",
    }),
    ...mapGetters("treatment-record/common", [
      "getTreatDate",
      "getRstCondInfo"
    ]),
    ...mapGetters("user", ["getFacilityCd"]),
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
     * @description QD平均流量
     * @returns {Array} 入力項目テキストボックスタイプNumber
     */
    averageFlowQD() {
      // 「計算用透析時間"00:00"」, 「ゼロ除算」:"---"
      if (
        this.dialysisDisplayTime === "00:00" ||
        this.dialysisTime === 0 ||
        this.dialysisTime === null
      ) {
        return "---";
      }
      // 小数点切り捨て
      return Math.floor(this.getAverageFlow(this.dialysisfluidFlow));
    },

    /**
     * @description QB平均流量
     * @returns {Array} 入力項目テキストボックスタイプNumber
     */
    averageFlowQB() {
      if (
        this.dialysisDisplayTime === "00:00" ||
        this.dialysisTime === 0 ||
        this.dialysisTime === null
      ) {
        return "---";
      }
      // 小数点切り捨て
      return Math.floor(this.getAverageFlow(this.bloodFlow));
    },

    /**
     * @description 透析液流量
     * @returns {Array}
     */
    dialysisfluidFlow() {
      return [
        this.devA[410],
        this.devA[411],
        this.devA[412],
        this.devA[413],
        this.devA[414],
        this.devA[415],
        this.devA[416],
        this.devA[417],
        this.devA[418],
        this.devA[419]
      ];
    },

    /**
     * @description 血流量
     * @returns {Array}
     */
    bloodFlow() {
      return [
        this.devA[400],
        this.devA[401],
        this.devA[402],
        this.devA[403],
        this.devA[404],
        this.devA[405],
        this.devA[406],
        this.devA[407],
        this.devA[408],
        this.devA[409]
      ];
    },

    /**
     * @description 切替時間
     * @returns {Array}
     */
    changeoverTime() {
      return [
        this.devA[420],
        this.devA[421],
        this.devA[422],
        this.devA[423],
        this.devA[424],
        this.devA[425],
        this.devA[426],
        this.devA[427],
        this.devA[428]
      ];
    },

    /**
     * @description オプション設定(ハイチャート必須項目)
     * @summary
     * @returns {Object}
     */
    chartOptions() {
      const chartType = "line";
      const chartDataQD = [];
      const chartDataQB = [];
      let yAxisMax = 700;
      let yTickPositions = [0, 100, 200, 300, 400, 500, 600, 700];
      let xTickPositions = null;
      // mod 9446 QB・QDプログラム画面が不正 関俊楠 start
      if (this.devA[431].value.editValue === "1") {
        // QDプログラム「1:入り」
        this.setChartData(chartDataQD, this.dialysisfluidFlow);
        yAxisMax = this.yAxisMax(chartDataQD);
        yAxisMax = (yAxisMax + 100) - ((yAxisMax / 10 % 10) * 10) + (yAxisMax % 10);
        yAxisMax = yAxisMax - (yAxisMax % 10);
      } else {
        // 「透析時間："00:00"」x軸を"04:00"まで表示
        for (let i = 0; i < 5; i++) {
          chartDataQD.push(null);
        }
      }
      if (this.devA[430].value.editValue === "1") {
        // QBプログラム「1:入り」
        this.setChartData(chartDataQB, this.bloodFlow);
        if (chartDataQD[0] === null || yAxisMax < this.yAxisMax(chartDataQB)) {
          // QDが「切」かQB最大y値がQDより大きい場合
          yAxisMax = this.yAxisMax(chartDataQB);
          yAxisMax = (yAxisMax + 100) - ((yAxisMax / 10 % 10) * 10) + (yAxisMax % 10);
          yAxisMax = yAxisMax - (yAxisMax % 10);
          // mod 9446 QB・QDプログラム画面が不正 関俊楠 end
        }
      } else {
        // 「透析時間："00:00"」x軸を"04:00"まで表示
        for (let i = 0; i < 5; i++) {
          chartDataQB.push(null);
        }
      }

      // 最大y軸値から間隔設定
      yTickPositions = this.yTickPositions(yAxisMax);

      // 最大y軸値から間隔設定
      if (
        this.dialysisDisplayTime < "01:00" &&
        this.dialysisDisplayTime !== "00:00" &&
        this.dialysisDisplayTime !== ""
      ) {
        xTickPositions = this.xTickPositions();
      }

      // 2分30秒 → 2.5変換
      const time = Number(
        moment(this.dialysisDisplayTime, "HH:mm").format("HH")
      );
      const minutes =
        Number(moment(this.dialysisDisplayTime, "HH:mm").format("mm")) / 60;
      let maxXAxis = time + minutes;

      // ※0なら初期表示へ
      if (
        this.dialysisDisplayTime === "00:00" ||
        this.dialysisDisplayTime === ""
      ) {
        maxXAxis = null;
      }

      return {
        chart: {
          height: "240",
          // グラフバックカラー
          backgroundColor: "#FFF",
          // グラフ外枠線
          borderWidth: 1,
          // グラフ外枠線色
          borderColor: "#999",
          events: {
            load() {
              // 初期ロード時にスクロールバー有無によってチャートがちゃんと描画されてないことがあるため
              // 描画された直後、1秒待機をして強制的リサイズをする
              // setTimeout(() => {
                this.reflow();
//              }, 1000);
            }
          },
          marginTop: 25,
          marginRight: 20,
          marginBottom: 30
        },
        // ラベル表示
        credits: {
          enabled: false
        },
        // 凡例表示
        legend: {
          enabled: false
        },
        plotOptions: {
          line: {
            animation: false
          }
        },
        // グラフx軸
        xAxis: [
          {
            // x軸最大値
            max: maxXAxis,
            // 軸等を表示
            visible: true,
            tickInterval: 1,
            tickPositions: xTickPositions,
            // 主目盛のピクセル幅
            tickWidth: 0,
            labels: {
              enabled: true,
              // x軸表示変換
              formatter() {
                return formatter(this.value);
              }
            }
          }
        ],
        exporting: [
          {
             enabled:false
          }
        ],
        // グラフy軸
        yAxis: [
          {
            // y軸目盛り最小
            min: 0,
            // y軸目盛り最大
            max: yAxisMax,
            // 目盛りの数※目盛りの間隔を設定
            tickPositions: yTickPositions,

            // y軸タイトル表示※text：タイトル名
            title: {
              enabled: false
            },
            // 軸等を表示
            visible: true,
            labels: {
              formatter() {
                if (this.value === yAxisMax && this.value % 100 !== 0) {
                  return;
                }
                return this.value;
              }
            }
          }
        ],

        // グラフタイトル
        title: {
          // タイトル名(非表示はundefinedを設定)※デフォルト値はundefined
          text: ""
        },
        // グラフ各データ
        series: [
          {
            // グラフ種類
            type: chartType,
            // グラフ各値
            data: chartDataQD,
            // グラフ色
            color: "blue",
            // マーカー(●)を各グラフに表示
            marker: {
              enabled: false,
              states: {
                // カーソルをグラフに置くとマーカーを強調表示
                hover: {
                  enabled: false
                }
              }
            }
          },
          {
            // グラフ種類
            type: chartType,
            // グラフ各値
            data: chartDataQB,
            // グラフ色
            color: "red",
            // マーカー(●)を各グラフに表示
            marker: {
              enabled: false,
              states: {
                // カーソルをグラフに置くとマーカーを強調表示
                hover: {
                  enabled: false
                }
              }
            }
          }
        ],
        // ツールチップ表示
        tooltip: {
          enabled: false
        }
      };
    },

    /**
     * @description 患者経過総合ビューアで表示している時は、画面が小さい時のスタイル用classを付与する
     * @returns {String} class
     */
    isUnderIndModal() {
      let indObj = document.getElementsByClassName("indInfo-style-modal-container");
      if (indObj.length > 0) {
        return "ind-style-media-query";
      }
      return "";
    },

    /**
     * @description sub-modal 配下に表示している際のフォントサイズ設定割り当て用class
     * @returns {String} class
     */
    isUnderSubModal() {
      let subModalObj = document.getElementsByClassName("sub-modal-body");
      if (subModalObj.length > 0) {
        return "is-under-sub-modal";
      }
      return "";
    },
  },

  //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、yuqizheng add start
  async created() {
    this.setLoadingScreenVisible(true);
    this.deviceSetInfoMst = await getDeviceSetInfoMst(
      this.getFacilitySwitch
    )
    this.$parent.$parent.isDialogType9 = true;
  },
  //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、yuqizheng add end
  watch: {
    /**
     * @description 装置設定値
     * @summary ミックスインのcreatedでdeviceSetInfoに選択された各装置設定データが設定される
     */
    deviceSetInfo() {
      // 初期状態：指示装置設定画面のみ透析予定・透析時間は参照する。
      if (this.dataSourceType === DATA_SOURCE_TYPE_ORD) {
        // 親のスタイル修正
        this.$parent.styleObj = { "max-width": "930px", width: "100%" };

        // 初期値データ指示画面の透析時間参照
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
          // del #7994 2022/10/10 【デグレ】血流量・透析液流量プログラムの計算用透析時間が0のまま dou start
          // // 時間形式に変換
          // const time = String(Math.floor(this.dialysisTime / 60));
          // const minutes = String(this.dialysisTime % 60);
          // // 透析時間："HH:mm"設定
          // this.dialysisDisplayTime = moment(
          //   `${time}:${minutes}`,
          //   "HH:mm"
          // ).format("HH:mm");
          // del #7994 2022/10/10 【デグレ】血流量・透析液流量プログラムの計算用透析時間が0のまま dou end
          // 透析日表示フラグ
          this.isDialysisDay = true;
        }
      } else if (this.dataSourceType === DATA_SOURCE_TYPE_TREAT) {
        // -----治療記録 > 装置設定 > QBQD-----
        if (this.deviceType === DEVICE_TYPE_QBQD) {
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
              // 透析日表示フラグ
              this.isDialysisDay = true;
            }
          }
        }
      }
      // add #7994 2022/10/10 【デグレ】血流量・透析液流量プログラムの計算用透析時間が0のまま dou start
      if (this.dialysisTime == 0 || this.dialysisTime === null) {
        // 透析時間(分)設定
        this.dialysisTime = this.correctDialysisTime(this.treatTime);
      }
      if (!!this.dialysisTime && this.dialysisTime != 0) {
        // 時間形式に変換
        const time = String(Math.floor(this.dialysisTime / 60));
        const minutes = String(this.dialysisTime % 60);
        // 透析時間："HH:mm"設定
        this.dialysisDisplayTime = moment(
          `${time}:${minutes}`,
          "HH:mm"
        ).format("HH:mm");
        // #6765 計画-血流量・透析液流量プログラム：修正時、修正していないが保存ボタンが有効になってしまっている 林峻峰 start
        this.dialysisDisplayTimeInit = this.dialysisDisplayTime;
        // #6765 計画-血流量・透析液流量プログラム：修正時、修正していないが保存ボタンが有効になってしまっている 林峻峰 end
      }
      // add #7994 2022/10/10 【デグレ】血流量・透析液流量プログラムの計算用透析時間が0のまま dou end
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、yuqizheng add start
      this.initModelValue = JSON.parse(JSON.stringify(this.devA));
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、yuqizheng add end
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start
      this.devADefault = JSON.parse(JSON.stringify(this.devA));
      this.dialysisDisplayTimeDefault = this.dialysisDisplayTime;
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end
    },
    fontSize() {
      // グラフのリサイズ
      this.$refs.refQbqdChart.chart.reflow();
    },
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start
    devA : {
      handler(newVal) {
        // mod #10237 装置設定デフォルトマスタの計算用透析時間を編集すると保存ボタンが活性化する 20240218 ztc start
        // if (this.dialysisDisplayTimeDefault === this.dialysisDisplayTime && JSON.stringify(this.devADefault) === JSON.stringify(newVal)) {
        if (JSON.stringify(this.devADefault) === JSON.stringify(newVal)) {
        // mod #10237 装置設定デフォルトマスタの計算用透析時間を編集すると保存ボタンが活性化する 20240218 ztc end
          this.changeButton(true);
        } else {
          this.changeButton(false);
        }
      },
      deep: true
    },
    // del #10237 装置設定デフォルトマスタの計算用透析時間を編集すると保存ボタンが活性化する 20240218 ztc start
    // dialysisDisplayTime(newVal) {
    //   if (this.dialysisDisplayTimeDefault === newVal && JSON.stringify(this.devADefault) === JSON.stringify(this.devA)) {
    //     this.changeButton(true);
    //     this.isTimeEdited = false;
    //   } else {
    //     this.changeButton(false);
    //     this.isTimeEdited = true;
    //   }
    // }
    // del #10237 装置設定デフォルトマスタの計算用透析時間を編集すると保存ボタンが活性化する 20240218 ztc end
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end
  },
  // add FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 start
  mounted() {
    EventBus.$on("ihdf-modal", this.handleIhdfModal);
    setTimeout(() => {
      this.changeButton(true);
      this.setLoadingScreenVisible(false);
    },500)
  },
  // add FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 end

  // add FNSI-性能を最適化する 李 start
  beforeDestroy() {
    EventBus.$off("ihdf-modal", this.handleIhdfModal);
    const chartRef = this.$refs.refQbqdChart;
    if (chartRef?.chart) {
      if (typeof chartRef.chart.destroy === 'function') {
        chartRef.chart.destroy();
      }
      chartRef.chart = null;
    }

    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  // add FNSI-性能を最適化する 李 end

  methods: {
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "startLoadingScreen",
      "finishLoadingScreen"
    ]),
    handleIhdfModal(data) {
      if (this.getIsShowQbqdProgramModal && data) {
        // 切りに設定する
        this.setEditValue();
        this.isIhdf = true;
      }
    },
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return this.isMst || (this.isMst != true && getAuthorized(pageCd, itemCd))
    },
    // add #10359 編集権限の動作不正 dengshen end
    // add FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 start
    /**
     * @description 濃度プログラムを[切り]を設定
     */
    setEditValue() {
      // 濃度プログラムを[切り]を設定する。
      this.devA[430].value.editValue = "0";
      this.devA[430].value.initValue = "0";
      this.devA[431].value.editValue = "0";
      this.devA[431].value.initValue = "0";
    },
    // add FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 end

    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    setInputNumberChange() {
      EventBus.$emit("deviceSetChanged");
    },
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end

    /**
     * @description 計算用透析時間
     * @param {String} value 時間
     */
    // mod #5590 2023/04/20 ×を常に表示するように修正 林峻峰 start
    // inputValue(target) {
    inputValue(value) {
      // 時間を分に変換
      // if (target.value === "") {
      if (value === null || value === "") {
        this.dialysisTime = null;
      } else {
        // 空欄でなければ時間を分に変換
        // const time = moment(target.value, "HH:mm").format("HH");
        const time = moment(value, "HH:mm").format("HH");
        // const minutes = moment(target.value, "HH:mm").format("mm");
        const minutes = moment(value, "HH:mm").format("mm");
        this.dialysisTime = Number(time) * 60 + Number(minutes);
      }
      // 表示変更の為、値設定
      // this.dialysisDisplayTime = target.value;
      this.dialysisDisplayTime = value;
      // 変更時,参照した透析日を非表示とする。
      this.isDialysisDay = false;
      // del #10237 装置設定デフォルトマスタの計算用透析時間を編集すると保存ボタンが活性化する 20240218 ztc start
      // EventBus.$emit("deviceSetChanged");
      // delD #10237 装置設定デフォルトマスタの計算用透析時間を編集すると保存ボタンが活性化する 20240218 ztc end
    },
    // mod #5590 2023/04/20 ×を常に表示するように修正 林峻峰 end

    /**
     * @description 平均流量計算結果
     * @summary 計算式： {[流量1×切替時間1]＋[流量2×切替時間2]＋・・・[流量最終×(透析時間－切替時間合計)]} / 透析時間
     * @param {Array} values 各流量
     * @returns {Number}
     */
    getAverageFlow(flowArray) {
      // 経過流量合計：[流量1×切替時間1]＋[流量2×切替時間2]＋・・・
      let progressFlowSum = 0;
      // 切替時間合計
      let changeoverTimeSum = 0;
      // 最終流量
      let lastFlow = null;
      // ステップ数と配列要素数を合わせるためマイナス1
      const stepNumber = this.devA[429].value.editValue - 1;

      // 経過流量合計と最終流量と切替時間合計を設定
      for (let i = 0; i < flowArray.length; i++) {
        if (i < stepNumber) {
          // ステップ数を超えるまで流量と切替時間を設定
          const flow = flowArray[i].value.editValue;
          const changeoverTime = this.changeoverTime[i].value.editValue;

          if (changeoverTimeSum < this.dialysisTime) {
            // 透析時間を超えるまで経過流量合計と切替時間合計を計算
            progressFlowSum += flow * changeoverTime;
            changeoverTimeSum += changeoverTime;
          } else if (changeoverTimeSum === this.dialysisTime) {
            // 切替時間合計と透析時間が同じ場合：最終流量
            lastFlow = flow;
            break;
          } else {
            // 切替時間合計が透析時間を超えた場合：1つ前が最終流量
            lastFlow = flowArray[i - 1].value.editValue;
            break;
          }
        } else if (i === stepNumber) {
          if (changeoverTimeSum >= this.dialysisTime) {
            // 切替時間合計が透析時間以上だった場合：1つ前が最終流量
            lastFlow = flowArray[i - 1].value.editValue;
          } else {
            // ステップ数が最終流量
            lastFlow = flowArray[i].value.editValue;
          }
        }
      }

      // 計算式： {経過流量合計＋[流量最終×(透析時間－切替時間合計)]} / 透析時間
      const averageFlow =
        (progressFlowSum + lastFlow * (this.dialysisTime - changeoverTimeSum)) /
        this.dialysisTime;

      return averageFlow;
    },

    /**
     * @description グラフデータ設定
     * @param {Array} chartData 表示グラフ
     * @param {Array} flowArray 各流量
     */
    setChartData(chartData, flowArray) {
      // グラフx軸設定
      if (
        this.dialysisDisplayTime === "00:00" ||
        this.dialysisDisplayTime === ""
      ) {
        // 「透析時間："00:00"」x軸を"04:00"まで表示
        for (let i = 0; i < 5; i++) {
          // ※5固定値："04:00"までグラフ空で表示
          chartData.push(null);
        }
      } else {
        // x軸
        let xAxis = 0;
        // 次のx軸：※階段グラフ用
        let stepsXAxis = 0;

        let isLastFlow = false;

        // グラフ値設定
        flowArray.forEach((item, index) => {
          // y軸：流量値
          let setData = parseInt(item.value.editValue);

          // ステップ数：ステップ数は1から連番、配列要素数は0から連番
          const stepNumber = this.devA[429].value.editValue - 1;

          // グラフ表示用y軸値設定：ステップ数以降の流量値をステップ数の流量値に設定
          if (index >= stepNumber) {
            // ステップ数以降の流量値
            setData = parseInt(flowArray[stepNumber].value.editValue);
          }

          // x軸値設定：切替時間を設定※経過を表示するため次のx軸を設定
          xAxis = stepsXAxis;

          // 次のx軸(階段グラフ用)を設定：切替時間値を設定
          if (index < this.changeoverTime.length) {
            // 配列要素数がある場合
            const changeoverTime =
              this.changeoverTime[index].value.editValue / 60;
            // 次のx軸：※階段グラフ用を設定
            stepsXAxis += changeoverTime;
          } else {
            // 配列要素数がない場合
            const maxDialysisDisplayTime = 10;
            // x軸を最大10時間になるよう値を設定
            if (stepsXAxis <= maxDialysisDisplayTime) {
              // x軸値が最大10時間を超えていない場合
              stepsXAxis = maxDialysisDisplayTime;
            }
            isLastFlow = true;
          }

          // 階段グラフ表示用データ
          const stepsChartData = flowArray.map(() => [stepsXAxis, setData]);

          chartData.push([xAxis, setData], stepsChartData[index]);

          if (this.dialysisDisplayTime > "10:00" && isLastFlow) {
            const hour = moment(this.dialysisDisplayTime, "HH:mm").format("HH");
            // 10時以降：＋1ずつ設定
            for (let i = 10; i <= hour; i++) {
              chartData.push([i + 1, setData]);
            }
            isLastFlow = false;
          }
        });
      }
    },

    /**
     * @description グラフ高さ設定
     * @param {Array} flowArray 各流量
     * @returns {Number}
     */
    yAxisMax(chartData) {
      if (
        this.dialysisDisplayTime === "00:00" ||
        this.dialysisDisplayTime === ""
      ) {
        // 透析時間が"00:00"は最大値を700固定
        return 700;
      }

      // x軸
      const xAxis = 0;
      // y軸 配列要素番号奇数：DB登録用の値、配列要素番号偶数：表示のみの値
      const yAxis = 1;
      const yAxisMax = _.max(chartData, (item, index) => {
        if (index % 2 === 0) {
          // 流量配列の値を取得するため、偶数番号のみ実行
          // 流量配列要素数を取得するためchartData配列要素数割る2※chartDataは階段グラフのため配列要素数を2倍にしている
          const chartIndex = index / 2;

          const time = this.dialysisDisplayTime;
          const hour = moment(time, "HH:mm").format("HH");
          const minutes = moment(time, "HH:mm").format("mm");
          // 分へ変換 "01:30" → 90分
          const formatTime = Number(hour) * 60 + Number(minutes);

          // y軸最大値設定
          if (
            item[xAxis] * 60 <= formatTime &&
            chartIndex < this.devA[429].value.editValue
          ) {
            // 透析時間とステップ数以下のステップ番号y値を最大値へ設定
            return item[yAxis];
          }
        }
      });

      return yAxisMax[yAxis];
    },

    /**
     * @description グラフ高さ間隔設定
     * @param {Number} value y軸最大値
     * @returns {Array}
     */
    yTickPositions(value) {
      const yTickPositions = [];
      for (let i = 0; i <= value; i += 100) {
        yTickPositions.push(i);
      }
      // 最大値を表示
      if (!yTickPositions.includes(value)) {
        // 軸に最大値がなければ設定
        yTickPositions.push(value);
      }
      return yTickPositions;
    },

    /**
     * @description グラフx軸間隔設定
     * @returns {Array}
     */
    xTickPositions() {
      // 30秒 → 0.5へ変換
      const minutes =
        Number(moment(this.dialysisDisplayTime, "HH:mm").format("mm")) / 60;
      return [0, minutes];
    },

    /**
     * @description 保存前のバリデーション処理
     * @returns {Object}
     *   成功時: null
     *   失敗時: メッセージダイアログ用オブジェクト { messageCd, stringParams }
     */
    validateBeforeUpdating() {
      return null;
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
      console.log("QbqdEditor.vue updateIndInfo this.startLoadingScreen();");
      this.startLoadingScreen();
      // 治療情報更新
      if (this.getSettingIndChildData.isAllSave) {
        // 一括更新
        this.save(structData);
      } else {
        this.ordMainAllSave(structData);
      }
      console.log("QbqdEditor.vue updateIndInfo this.finishLoadingScreen();");
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
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、yuqizheng add start
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
        getErrorMessage('IndActionChart.vue', 'resetComponentData', error);
        throw error;
      });
      let ordMainData = response.data[0];
      if (ordMainData.indDeviceSetInfo != null && ordMainData.indDeviceSetInfo != undefined) {
        // 編集破棄の場合は計算用透析時間再設定を実施
        if (answer == 2) {
          this.setNewDialysisDisplayTime(ordMainData);
        }
        let tempData = JSON.parse(ordMainData.indDeviceSetInfo);
        if (tempData != null && tempData != undefined) {
          // 初期値保持
          const initData = deepCopy(tempData);
          if (answer == 3) {
            for (let key in this.devA) {
              if (this.devA[key].value.editValue != this.initModelValue[key].value.initValue) {
                tempData.qbqd.dev.A[key] = this.devA[key].value.editValue;
              }

            }
          }
          for (let key in this.devA) {
            this.devA[key].value.initValue = initData.qbqd.dev.A[key];
            this.devA[key].value.editValue = tempData.qbqd.dev.A[key];
          }
        }
      }
      this.initModelValue = JSON.parse(JSON.stringify(this.devA));
    },
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、yuqizheng add end
    async changeButton(val) {
      // if (dev.maxValue !== undefined) {
      //   dev.maxValue = this.deviceSetInfoMst.pat.ope.dev.A[179];
      // }
      EventBus.$emit("mstTreatmentSetRegistered", val);
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start
      // if(false === val) {
      //   EventBus.$emit("deviceSetChanged");
      // }
      EventBus.$emit("deviceSetChanged", !val);
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end
    },
    // #6765 計画-血流量・透析液流量プログラム：修正時、修正していないが保存ボタンが有効になってしまっている 林峻峰 start
    changeTime() {
      this.timeEditFlg = this.dialysisDisplayTimeInit !== this.dialysisDisplayTime;
    },
    // #6765 計画-血流量・透析液流量プログラム：修正時、修正していないが保存ボタンが有効になってしまっている 林峻峰 end
    //mod FNSI-5993 劉全航 start
    // bloodFlowChangeButton(dev, val) {
    //   if (dev.maxValue !== undefined) {
    //     dev.maxValue = this.deviceSetInfoMst.pat.ope.dev.A[179];
    //   }
    //   EventBus.$emit("mstTreatmentSetRegistered", val);
    // },
    //mod FNSI-5993 劉全航 end
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
    },
    // add #12462 患者情報共有 Ji end
    /**
     * 計算用透析時間再設定
     */
    setNewDialysisDisplayTime(ordMainData){

      let indCondInfo = ordMainData?.indCondInfo;
      if (!indCondInfo) {
        indCondInfo = ordMainData?.indCondInfo;
      }

      const dialysisTime = JSON.parse(indCondInfo)["1"].value;

      if (dialysisTime !== null) {
        // 選択された日付に透析時間が設定されている場合
        this.dialysisDate = ordMainData.treatDate;

        // 透析時間(分)設定
        this.dialysisTime = this.correctDialysisTime(Number(dialysisTime));

        this.isDialysisDay = true;
      }

      if (this.dialysisTime == 0 || this.dialysisTime === null) {
        // 透析時間(分)設定
        this.dialysisTime = this.correctDialysisTime(this.treatTime);
      }
      if (!!this.dialysisTime && this.dialysisTime != 0) {
        // 時間形式に変換
        const time = String(Math.floor(this.dialysisTime / 60));
        const minutes = String(this.dialysisTime % 60);
        // 透析時間："HH:mm"設定
        this.dialysisDisplayTime = moment(
          `${time}:${minutes}`,
          "HH:mm"
        ).format("HH:mm");
        this.dialysisDisplayTimeInit = this.dialysisDisplayTime;
      }
    }
  }
};
</script>

<style src="../base-modules/BeseDeviceSetInfoStyle.css" scoped></style>

<style scoped>
@media print {
  .device-info-cell-value{
    min-width: 50px;
    max-width: 50px;
  }
  .calculation-disclaimer {
    width: 185px !important;
  }
}
.device-info-cell-value{
    min-width: 50px;
    max-width: 50px;
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
    min-width:550px;
    height:480px;
  }
}

@media only screen and (max-height:530px) {
  .ind-style-media-query {
    overflow-x: auto;
    overflow-y: auto;
    -webkit-overflow-scrolling:auto;
    overscroll-behavior-y: auto;
  }
}

.device-info-main-content {
  border: solid 1px var(--ntss-border-color);
  border-top: none;
  max-height: none;
  overflow: none;
}

.device-info-cell {
  border: none;
}

.device-info-cell-value {
  padding: 0;
  margin: 4px;
}

.device-input-charts >>> .custom-input-number {
  width: 100%;
  padding: 0;
  margin: 0;
}

.setting-area {
  display: block;
}

.high-charts {
  margin: auto;
}

/* SubModal配下では、通常のModalのcssが当たらないので補正する */
.is-under-sub-modal {
  font-size: 1em;
}

.is-under-sub-modal >>> * {
  /* TODOD font-size: inherit !important; */
  font-size: inherit;
}

/* 計算エリア */
.calculation-disclaimer {
  font-weight: initial;
  text-align: initial;
  border: 1px solid;
  width: 145px;
}

.calculation-disclaimer-day {
  min-height: 20px;
}

.chart-area >>> ons-row {
  height: auto;
}

.chart-area {
  min-width: 0;
}

.sub-area {
  margin-left: 20px;
  flex: 0 0 150px;
}

.sub-area-item {
  flex: 0 0 100%;
}

.device-info-cell-rigth {
  text-align: right;
}

.device-info-cell-center {
  text-align: center;
}

.device-info-cell-title {
  width: 100px;
  text-align: right;
}
</style>
