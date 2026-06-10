<template>
  <div
    v-if="deviceSetInfo !== null"
    :class="showButton ? 'device-info-container' : null"
  >
    <div>
      <div class="device-info-content" :class="isUnderIndModal">
        <div class="device-info-content-area">
          <!-- ヘッダ -->
          <v-ons-row
            v-if="showButton"
            class="common-style-header device-info-main-title"
          >
            <!-- mod FNSI-UFRプログラムの修正 楊 start -->
            <!-- UFRプログラム -->
            除水プログラム
            <!-- mod FNSI-UFRプログラムの修正 楊 end -->
          </v-ons-row>
          <v-ons-row v-else class="device-info-main-title" />
          <div class="device-info-main-content">
            <!-- 項目 -->
            <v-ons-row class="device-info-cell device-info-left">
              <v-ons-col class="device-info-cell-value">
                <!-- mod FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 start -->
                <!--
                 <device-select
                  ref="select1"
                  :device-info="devA[290]"
                  :disabled="isTreatRecord"
                />
                -->
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
                <!-- <device-select
                  id="ufrId"
                  ref="select1"
                  :device-info="devA[290]"
                  :disabled="isTreatRecord"
                  @change="changeButton(false)"
                /> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-select -->
                <!--   id="ufrId" -->
                <!--   ref="select1" -->
                <!--   :device-info="devA[290]" -->
                <!--   :disabled="isTreatRecord" -->
                <!-- /> -->
                <device-select
                  id="ufrId"
                  ref="select1"
                  :device-info="devA[290]"
                  :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
                <!-- mod FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 end -->
              </v-ons-col>
              <v-ons-col class="device-info-cell-value device-info-cell-rigth">
                最終工程
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
                <!-- <device-input-number
                  ref="required_number1"
                  :device-info="devA[311]"
                  :disabled="isTreatRecord"
                  @change="changeButton(false)"
                  @input="setInputNumberChange"
                  @wheel.prevent="setInputNumberChange"
                  @keydown.up.prevent="setInputNumberChange"
                  @keydown.down.prevent="setInputNumberChange"
                /> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_number1" -->
                <!--   :device-info="devA[311]" -->
                <!--   :disabled="isTreatRecord" -->
                <!--   @input="setInputNumberChange" -->
                <!--   @wheel.prevent="setInputNumberChange" -->
                <!--   @keydown.up.prevent="setInputNumberChange" -->
                <!--   @keydown.down.prevent="setInputNumberChange" -->
                <!-- /> -->
                <device-input-number
                  ref="required_number1"
                  :device-info="devA[311]"
                  :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                  @input="setInputNumberChange"
                  @wheel.prevent="setInputNumberChange"
                  @keydown.up.prevent="setInputNumberChange"
                  @keydown.down.prevent="setInputNumberChange"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
              </v-ons-col>
            </v-ons-row>
            <v-ons-row class="device-info-cell">
              <v-ons-col class="device-info-cell-value device-info-cell-rigth">
                コース
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
                <!-- <device-input-number
                  ref="required_number2"
                  :device-info="devA[312]"
                  :disabled="isTreatRecord"
                  @change="changeButton(false)"
                  @input="setInputNumberChange"
                  @wheel.prevent="setInputNumberChange"
                  @keydown.up.prevent="setInputNumberChange"
                  @keydown.down.prevent="setInputNumberChange"
                /> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_number2" -->
                <!--   :device-info="devA[312]" -->
                <!--   :disabled="isTreatRecord" -->
                <!--   @input="setInputNumberChange" -->
                <!--   @wheel.prevent="setInputNumberChange" -->
                <!--   @keydown.up.prevent="setInputNumberChange" -->
                <!--   @keydown.down.prevent="setInputNumberChange" -->
                <!-- /> -->
                <device-input-number
                  ref="required_number2"
                  :device-info="devA[312]"
                  :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                  @input="setInputNumberChange"
                  @wheel.prevent="setInputNumberChange"
                  @keydown.up.prevent="setInputNumberChange"
                  @keydown.down.prevent="setInputNumberChange"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
              </v-ons-col>
            </v-ons-row>
            <v-ons-row
              class="device-info-cell device-info-center charts-info-cell"
              id="ufrHdEucm"
            >
              <v-ons-col
                v-for="(device, index) in treatmentMethodValue"
                :key="`key1_${index}`"
                class="device-info-cell-value"
              >
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
                <!-- <device-select
                  :ref="`required1_${index}`"
                  :device-info="device"
                  class="device-input-charts"
                  :disabled="isTreatRecord"
                  @change="changeButton(false)"
                /> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-select -->
                <!--   :ref="`required1_${index}`" -->
                <!--   :device-info="device" -->
                <!--   class="device-input-charts" -->
                <!--   :disabled="isTreatRecord" -->
                <!-- /> -->
                <device-select
                  :ref="`required1_${index}`"
                  :device-info="device"
                  class="device-input-charts"
                  :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
              </v-ons-col>
            </v-ons-row>

            <!-- グラフ -->
            <v-ons-row class="device-info-cell">
              <v-ons-col>
                <ufr-program-chart
                  :mode="chartData.mode"
                  :data="chartData"
                  :class="isUnderSubModal"
                  :height="200"
                  :width="800"
                />
              </v-ons-col>
            </v-ons-row>

            <!-- 項目 -->
            <!-- mod FNSI-UFRプログラムの修正 楊 start -->
            <!-- <v-ons-row class="device-info-cell charts-info-cell"> -->
             <!-- <v-ons-col
                v-for="(device, index) in stepUpperValue"
                :key="`key_${index}`"
                class="device-info-cell-value"
              >
                <device-input-number
                  :ref="`required2_${index}`"
                  :device-info="device"
                  class="device-input-charts device-input-disabled"
                  :disabled="true"
                />
              </v-ons-col>
            </v-ons-row> -->
            <!-- mod FNSI-UFRプログラムの修正 楊 end -->
            <v-ons-row class="device-info-cell charts-info-cell">
              <v-ons-col
                v-for="(device, index) in stepLowerValue"
                :key="`key3_${index}`"
                class="device-info-cell-value"
              >
                <device-input-number
                  :ref="`required3_${index}`"
                  :device-info="device"
                  class="device-input-charts"
                  :disabled="isTreatRecord || devA[290].value.editValue === '2' || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                  @input="setStepUpperValueChange(device.value.editValue, index)"
                  @wheel.prevent="setStepUpperValueChange(device.value.editValue, index)"
                  @keydown.up.prevent="
                    setStepUpperValueChange(device.value.editValue, index)
                  "
                  @keydown.down.prevent="
                    setStepUpperValueChange(device.value.editValue, index)
                  "
                />
              </v-ons-col>
            </v-ons-row>

            <v-ons-row class="device-info-cell device-info-left">
              <v-ons-col class="device-info-cell-value">
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
                <!-- <device-input-number
                  ref="required_number3"
                  :device-info="devA[313]"
                  :disabled="isTreatRecord || devA[290].value.editValue === '1'"
                  @change="changeButton(false)"
                  @input="setInputNumberChange"
                  @wheel.prevent="setInputNumberChange"
                  @keydown.up.prevent="setInputNumberChange"
                  @keydown.down.prevent="setInputNumberChange"
                /> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_number3" -->
                <!--   :device-info="devA[313]" -->
                <!--   :disabled="isTreatRecord || devA[290].value.editValue === '1'" -->
                <!--   @input="setInputNumberChange" -->
                <!--   @wheel.prevent="setInputNumberChange" -->
                <!--   @keydown.up.prevent="setInputNumberChange" -->
                <!--   @keydown.down.prevent="setInputNumberChange" -->
                <!-- /> -->
                <device-input-number
                  ref="required_number3"
                  :device-info="devA[313]"
                  :disabled="isTreatRecord || devA[290].value.editValue === '1' || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                  @input="setInputNumberChange"
                  @wheel.prevent="setInputNumberChange"
                  @keydown.up.prevent="setInputNumberChange"
                  @keydown.down.prevent="setInputNumberChange"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
                開始
              </v-ons-col>
              <v-ons-col class="device-info-cell-value device-info-cell-rigth">
                終了
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
                <!-- <device-input-number
                  ref="required_number4"
                  :device-info="devA[314]"
                  :disabled="isTreatRecord || devA[290].value.editValue === '1'"
                  @change="changeButton(false)"
                  @input="setInputNumberChange"
                  @wheel.prevent="setInputNumberChange"
                  @keydown.up.prevent="setInputNumberChange"
                  @keydown.down.prevent="setInputNumberChange"
                /> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <device-input-number -->
                <!--   ref="required_number4" -->
                <!--   :device-info="devA[314]" -->
                <!--   :disabled="isTreatRecord || devA[290].value.editValue === '1'" -->
                <!--   @input="setInputNumberChange" -->
                <!--   @wheel.prevent="setInputNumberChange" -->
                <!--   @keydown.up.prevent="setInputNumberChange" -->
                <!--   @keydown.down.prevent="setInputNumberChange" -->
                <!-- /> -->
                <device-input-number
                  ref="required_number4"
                  :device-info="devA[314]"
                  :disabled="isTreatRecord || devA[290].value.editValue === '1' || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                  @input="setInputNumberChange"
                  @wheel.prevent="setInputNumberChange"
                  @keydown.up.prevent="setInputNumberChange"
                  @keydown.down.prevent="setInputNumberChange"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
              </v-ons-col>
            </v-ons-row>
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
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import {deepCopy, getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { mapActions, mapGetters } from "vuex";
import {
  DEVICE_TYPE_UFR,
  DATA_SOURCE_TYPE_ORD
} from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
import baseEditor from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoEditor.vue";
import UfrProgramChart from "@/components/deviceset-info/ufr-program/UfrProgramChart";
// add FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 start
import { EventBus } from "@/eventBus.js";
// add FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 end
//FNSI-修正【患者経過総合ビューア】#4859 横展開対応、fan add start
import { ApiHelper } from "@/apis/AxiosHelper";
//FNSI-修正【患者経過総合ビューア】#4859 横展開対応、fan add end



/**
 * @description Na注入プログラム設定値編集画面
 */
export default {
  components: {
    "ufr-program-chart": UfrProgramChart
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
      deviceType: DEVICE_TYPE_UFR,
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
      initModelValueDevA:undefined,
      initModelValueDevB:undefined,
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start
      devADefault: {},
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end
    };
  },

  computed: {
    // mod FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 start
    // ...mapGetters("pat-viewer-modal", ["getSettingIndChildData"]),
    ...mapGetters("pat-viewer-modal", ["getSettingIndChildData", "getIsShowUfrProgramModal"]),
    // mod FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 end
    ...mapGetters("user", ["getFacilityCd"]),
    chartData() {
      let mode = 0;

      switch (parseInt(this.devA[290].value.editValue)) {
        case 1:
          mode = "ufr-step";
          break;
        case 2:
          mode = "ufr-course";
          break;
        default:
          break;
      }

      return {
        mode,
        courseValue: this.devA[312].value.editValue,
        courseStartValue: this.devA[313].value.editValue,
        courseEndValue: this.devA[314].value.editValue,
        courseMinValue: this.devA[313].minValue,
        courseMaxValue: this.devA[313].maxValue,
        stepValues: this.stepValues
      };
    },
    /**
     * @description グラフ編集値
     * @returns {Array} 入力項目テキストボックスタイプNumber
     */
    treatmentMethodValue() {
      return [
        this.devA[291],
        this.devA[292],
        this.devA[293],
        this.devA[294],
        this.devA[295],
        this.devA[296],
        this.devA[297],
        this.devA[298],
        this.devA[299],
        this.devA[300]
      ];
    },

    stepUpperValue() {
      return [
        this.devB[0],
        this.devB[1],
        this.devB[2],
        this.devB[3],
        this.devB[4],
        this.devB[5],
        this.devB[6],
        this.devB[7],
        this.devB[8],
        this.devB[9]
      ];
    },

    stepLowerValue() {
      return [
        this.devA[301],
        this.devA[302],
        this.devA[303],
        this.devA[304],
        this.devA[305],
        this.devA[306],
        this.devA[307],
        this.devA[308],
        this.devA[309],
        this.devA[310]
      ];
    },

    stepValues() {
      const stepNumber = this.devA[311].value.editValue;
      // mod FNSI-UFRプログラムの修正 楊 start
      // return this.stepUpperValue.map((device, index) => {
      //   // グラフを動的にさせるために0を設定
      //   return index < stepNumber ? device.value.editValue : 0;
      // });

      // 下部データを取得
      return this.stepLowerValue.map((device, index) => {
        // グラフを動的にさせるために0を設定
        return index < stepNumber ? parseInt(device.value.editValue) : 0;
      });
      // mod FNSI-UFRプログラムの修正 楊 end
    },

    // 患者経過総合ビューアから表示されている場合はclassを付与する
    isUnderIndModal() {
      let indObj = document.getElementsByClassName("indInfo-style-modal-container");
      if (indObj.length > 0) {
        return "ind-style-media-query";
      }
      return "";
    },

    // SubModal上で表示されていた場合にclassを付与する
    isUnderSubModal() {
      let subModalObj = document.getElementsByClassName("sub-modal-body");
      if (subModalObj.length > 0) {
        return "is-under-sub-modal";
      }
      return "";
    },
  },

  watch: {
    // UFRプログラム各指数設定
    deviceSetInfo() {
      this.stepLowerValue.forEach((item, index) => {
        this.setStepUpperValue(item.value.editValue, index);
      });

      if (this.dataSourceType === DATA_SOURCE_TYPE_ORD) {
        // 親のスタイル修正
        this.$parent.styleObj = { "max-width": "850px", width: "100%" };
      }

      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
      this.initModelValueDevA = JSON.parse(JSON.stringify(this.devA));
      this.initModelValueDevB = JSON.parse(JSON.stringify(this.devB));
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start
      this.devADefault = JSON.parse(JSON.stringify(this.devA));
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end
    },
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start
    devA : {
      handler(newVal) {
        if (JSON.stringify(this.devADefault) === JSON.stringify(newVal)) {
          this.changeButton(true);
        } else {
          this.changeButton(false);
        }
      },
      deep: true
    }
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end
  },
  // add FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 start
  mounted() {
    // add 性能改善メモリ不足 shan start
    EventBus.$off("ihdf-modal")
    // add 性能改善メモリ不足 shan end
    EventBus.$on("ihdf-modal", data => {
      if (this.getIsShowUfrProgramModal && data) {
        // 切りに設定する
        this.setEditValue();
        const contentTreat = document.getElementById("ufrId")
        if (null !== contentTreat) {
          contentTreat.children[0].disabled = true;
        }
      }
    });
    setTimeout(() => {
      this.decimalModi();
      this.changeButton(true);
      this.setLoadingScreenVisible(false);
    },500);
  },
  // add FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 end

  // add FNSI-性能を最適化する 李 start
  beforeDestroy() {
    EventBus.$off("ihdf-modal", data => {
      if (this.getIsShowUfrProgramModal && data) {
        // 切りに設定する
        this.setEditValue();
        const contentTreat = document.getElementById("ufrId")
        if (null !== contentTreat) {
          contentTreat.children[0].disabled = true;
        }
      }
    })
  },
  // add FNSI-性能を最適化する 李 end

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

    // add FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 start
    /**
     * @description 濃度プログラムを[切り]を設定
     */
    setEditValue() {
      // 濃度プログラムを[切り]を設定する。
      this.devA[290].value.editValue = "0";
      this.devA[290].value.initValue = "0";
    },
    // add FNSI-治療モードをI-HDFへ変更した際、電源をOFFにする 楊 end
    setStepUpperValue(value, index) {
      this.stepUpperValue[index].value.editValue = Math.round(value / 4);
    },

    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    setStepUpperValueChange(value, index) {
      this.setStepUpperValue(value, index);
      EventBus.$emit("deviceSetChanged");
    },

    setInputNumberChange() {
      EventBus.$emit("deviceSetChanged");
    },
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end

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
      console.log("UfrProgramEditor.vue updateIndInfo this.startLoadingScreen();");
      this.startLoadingScreen();
      // 治療情報更新
      if (this.getSettingIndChildData.isAllSave) {
        // 一括更新
        this.save(structData);
      } else {
        this.ordMainAllSave(structData);
      }
      console.log("IndTreatMethod.vue updateIndInfo this.finishLoadingScreen();");
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
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、fan add start
    async resetComponentIndData(structData){
      if (this.isEdit()) {
        this.$parent.$parent.messageDialogInfo.messageCd = 70000028;
        /* mod FNSI-4212 更新対象変更時のウインドウが不正 liumx start */
        this.$parent.$parent.messageDialogInfo.type = "9";
        /* mod FNSI-4212 更新対象変更時のウインドウが不正 liumx end */
        this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
        return;
      } else {
        this.getComponentData(structData,2);
      }

    },
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、fan add end

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
        getErrorMessage('IndActionChart.vue', 'resetComponentData', error);
        throw error;
      });
      let ordMainData = response.data;
      if(ordMainData && ordMainData.length > 0) {
        ordMainData = ordMainData[0];
      } else {
        return;
      }

      // 最新の検索結果すべてを画面に設定する
      if (ordMainData.indDeviceSetInfo != null && ordMainData.indDeviceSetInfo != undefined) {
        let tempData = JSON.parse(ordMainData.indDeviceSetInfo);
        if (tempData != null && tempData != undefined) {
          // 初期値保持
          const initData = deepCopy(tempData);
          if (answer == 3) {
            for (let key in this.devA) {
              if (this.devA[key].value.editValue != this.initModelValueDevA[key].value.initValue) {
                tempData.ufr.dev.A[key] = this.devA[key].value.editValue;
              }

            }
            for (let key in this.devB) {
              if (this.devB[key].value.editValue != this.initModelValueDevB[key].value.initValue) {
                tempData.ufr.dev.B[key] = this.devB[key].value.editValue;
              }

            }
          }
          for (let key in this.devA) {
            this.devA[key].value.initValue = initData.ufr.dev.A[key];
            this.devA[key].value.editValue = tempData.ufr.dev.A[key];
          }
          for (let key in this.devB) {
            this.devB[key].value.initValue = initData.ufr.dev.B[key];
            this.devB[key].value.editValue = tempData.ufr.dev.B[key];
          }
        }
      }
      this.initModelValueDevA = JSON.parse(JSON.stringify(this.devA));
      this.initModelValueDevB = JSON.parse(JSON.stringify(this.devB));
    },
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end
    decimalModi() {
      let textInputs = document.getElementsByClassName("text-input");
      for (let i = 0; i < textInputs.length; i++) {
        if (textInputs[i].value !== "" && textInputs[i].value !== null && textInputs[i].type === "number") {
          let temp = textInputs[i].value + "";
          if (temp.indexOf(".") > -1) {
            let decimal = temp.split(".")[1];
            let num = 1;
            for (let j = 0; j < decimal.length; j++) {
              num /= 10;
            }
            textInputs[i].step = num;
          } else {
            textInputs[i].step = 1;
          }
        }
      }
    },
    changeButton(val) {
      EventBus.$emit( "mstTreatmentSetRegistered", val);
     // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start
      // if(false === val) {
      //   EventBus.$emit("deviceSetChanged");
      // }
      EventBus.$emit("deviceSetChanged", !val);
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end
    },
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

  //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、fan add start
  async created() {
    this.setLoadingScreenVisible(true);
    this.$parent.$parent.isDialogType9 = true;
  }
  //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、fan add end
};
</script>

<style src="../base-modules/BeseDeviceSetInfoStyle.css" scoped></style>

<style scoped>
.device-info-main-content {
  border: solid 1px var(--ntss-border-color);
  border-top: none;
}

.device-info-cell {
  border: none;
}

.device-input-charts >>> .custom-input-number,
.device-input-charts >>> .custom-select {
  width: 100%;
}

.charts-info-cell {
  text-align: center;
  /* グラフのY軸ラベルに合わせる */
  padding: 3px 2.8em 3px 2.5em;
}

.device-info-cell-value {
  padding: 0;
  margin: 4px;
}

.device-input-charts >>> .custom-input-number {
  padding: 0;
  margin: 0;
}

.device-input-charts >>> .select-input {
  padding-right: 1em;
}

.device-info-cell-rigth {
  text-align: right;
}

.device-info-content {
  max-width: 830px;
  max-height: 460px;
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
    min-width:620px;
    height:400px;
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

/* SubModal配下では、通常のModalのcssが当たらないので補正する */
.is-under-sub-modal {
  font-size: 1em;
}

.is-under-sub-modal >>> * {
  font-size: inherit !important;
}

.device-info-left {
  text-align: left;
}

.device-info-center {
  text-align: center;
}

.device-input-disabled >>> .custom-input-number {
  background-color: rgb(235, 235, 228);
}
</style>
