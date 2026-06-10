<!--I-HDFプログラム-->
<template>
  <div v-if="deviceSetInfo !== null">
    <!-- 項目 isEditedプロパティ参照用に削除せず非表示とする-->
    <v-ons-row class="device-info-cell device-info-left" v-show="false">
      <v-ons-col class="device-info-cell-name">
        Ｉ‐ＨＤＦプログラム使用選択
      </v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <device-radio
          ref="radio1"
          :device-info="programUse"
          :disabled="isTreatRecord"
          @change="changeButton(false)"
        />
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="device-info-cell device-info-main-content">
      <div class="device-info-cell-content">
        <div class="ihdf-button-area">
          <input
            type="radio"
            style="display: none;"
            class="identification"
            name="identification"
            value="1"
            id="input-ihdf-setting-common"
            @click="changeIsIHdfCommonSetting(true)"
            :checked="isIHdfCommonSetting"
          />
          <label for="input-ihdf-setting-common" class="label group-label first-of-type">基本設定</label>
          <input
            type="radio"
            style="display: none;"
            class="identification"
            name="identification"
            value="2"
            id="input-ihdf-setting-pg"
            @click="changeIsIHdfCommonSetting(false);"
            :checked="!isIHdfCommonSetting"
          />
          <label for="input-ihdf-setting-pg" class="label group-label last-of-type">プログラム設定</label>
        </div>
        <div>
          <div v-show="isIHdfCommonSetting" class="device-info-img-content">
            <img :src="IHdfImg" alt="I-HDF図2" class="i-hdf-img" />

            <!-- mod FNSI-FutreNetWeb+SI課題管理No.5254 李 start -->
            <!-- <device-input-number
              v-for="(device, index) in deviceSetInfoList"
              :key="`key1_${index}`"
              :ref="`required1_${index}`"
              :device-info="device"
              :class="`deviceSetInfo-input device${index}`"
              :disabled="isTreatRecord"
            /> -->
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <device-input-number -->
            <!--   v-for="(device, index) in deviceSetInfoList" -->
            <!--   :key="`key1_${index}`" -->
            <!--   :ref="`required1_${index}`" -->
            <!--   :device-info="device" -->
            <!--   :class="`deviceSetInfo-input device${index}`" -->
            <!--   style="margin-left: -12px;" -->
            <!--   :disabled="isTreatRecord" -->
            <!--   @change="changeButton(false)" -->
            <!--   @input="setInputNumberChange" -->
            <!--       @wheel.prevent="setInputNumberChange" -->
            <!--       @keydown.up.prevent="setInputNumberChange" -->
            <!--       @keydown.down.prevent="setInputNumberChange" -->
            <!-- /> -->
            <device-input-number
              v-for="(device, index) in deviceSetInfoList"
              :key="`key1_${index}`"
              :ref="`required1_${index}`"
              :device-info="device"
              :class="`deviceSetInfo-input device${index}`"
              style="margin-left: -12px;"
              :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
              @change="changeButton(false)"
              @input="setInputNumberChange"
              @wheel.prevent="setInputNumberChange"
              @keydown.up.prevent="setInputNumberChange"
              @keydown.down.prevent="setInputNumberChange"
            />
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
            <!-- mod FNSI-FutreNetWeb+SI課題管理No.5254 李 end -->
          </div>

          <div v-show="isIHdfCommonSetting === false" class="chart-content">
            <v-ons-row>
              <v-ons-col class="chart-area">
                <div class="chart-main-area">
                  <v-ons-row class="deviceSetInfo-chart-row">
                    <v-ons-col>
                      <div>
                        バランス
                      </div>
                    </v-ons-col>
                    <v-ons-col
                      v-for="(device, index) in balancedList"
                      :key="`key2_${index}`"
                      class="balance-input"
                    >
                      <span
                        v-show="
                          index < countScheduleSupplyLiquid.value.editValue
                        "
                      >
                        {{ device }}
                      </span>
                    </v-ons-col>
                  </v-ons-row>
                  <v-ons-row class="deviceSetInfo-chart-row fixed-width">
                    <v-ons-col>
                      <div class="deviceSetInfo-chart-title">
                        補液量
                      </div>
                    </v-ons-col>
                    <v-ons-col
                      v-for="(device, index) in supplyLiquid"
                      :key="`key3_${index}`"
                    >
                      <!-- mod #10359 編集権限の動作不正 dengshen start -->
                      <!-- <device-input-number -->
                      <!--   :ref="`required2_${index}`" -->
                      <!--   :device-info="device" -->
                      <!--   :disabled=" -->
                      <!--     isTreatRecord || -->
                      <!--       !(index < countScheduleSupplyLiquid.value.editValue) -->
                      <!--   " -->
                      <!--   class="device-input-chart" -->
                      <!--   @change="changeButton(false)" -->
                      <!--   @input="setInputNumberChange" -->
                      <!--   @wheel.prevent="setInputNumberChange" -->
                      <!--   @keydown.up.prevent="setInputNumberChange" -->
                      <!--   @keydown.down.prevent="setInputNumberChange" -->
                      <!-- /> -->
                      <device-input-number
                        :ref="`required2_${index}`"
                        :device-info="device"
                        :disabled="
                          isTreatRecord ||
                          !(index < countScheduleSupplyLiquid.value.editValue)
                          || !getItemAuthorized('Indication', 'default_authority')
                          || isOtherFacilityRow()
                        "
                        class="device-input-chart"
                        @change="changeButton(false)"
                        @input="setInputNumberChange"
                        @wheel.prevent="setInputNumberChange"
                        @keydown.up.prevent="setInputNumberChange"
                        @keydown.down.prevent="setInputNumberChange"
                      />
                      <!-- mod #10359 編集権限の動作不正 dengshen end -->
                    </v-ons-col>
                  </v-ons-row>
                  <v-ons-row class="deviceSetInfo-chart-row fixed-width">
                    <v-ons-col>
                      <div class="deviceSetInfo-chart-title">
                        回収量
                      </div>
                    </v-ons-col>
                    <v-ons-col
                      v-for="(device, index) in recoveredAmount"
                      :key="`key4_${index}`"
                    >
                      <!-- mod #10359 編集権限の動作不正 dengshen start -->
                      <!-- <device-input-number -->
                      <!--   :ref="`required3_${index}`" -->
                      <!--   :device-info="device" -->
                      <!--   :disabled=" -->
                      <!--     isTreatRecord || -->
                      <!--       !(index < countScheduleSupplyLiquid.value.editValue) -->
                      <!--   " -->
                      <!--   class="device-input-chart" -->
                      <!--   @change="changeButton(false)" -->
                      <!--   @input="setInputNumberChange" -->
                      <!--   @wheel.prevent="setInputNumberChange" -->
                      <!--   @keydown.up.prevent="setInputNumberChange" -->
                      <!--   @keydown.down.prevent="setInputNumberChange" -->
                      <!-- /> -->
                      <device-input-number
                        :ref="`required3_${index}`"
                        :device-info="device"
                        :disabled="
                          isTreatRecord ||
                          !(index < countScheduleSupplyLiquid.value.editValue)
                          || !getItemAuthorized('Indication', 'default_authority')
                          || isOtherFacilityRow()
                        "
                        class="device-input-chart"
                        @change="changeButton(false)"
                        @input="setInputNumberChange"
                        @wheel.prevent="setInputNumberChange"
                        @keydown.up.prevent="setInputNumberChange"
                        @keydown.down.prevent="setInputNumberChange"
                      />
                      <!-- mod #10359 編集権限の動作不正 dengshen end -->
                    </v-ons-col>
                  </v-ons-row>
                  <v-ons-row class="deviceSetInfo-chart-row">
                    <v-ons-col>
                      <highcharts :options="chartOptions" ref="refIHdfProgramChart"/>
                    </v-ons-col>
                  </v-ons-row>
                </div>
              </v-ons-col>
              <v-ons-col class="prospect-area">
                <!-- 補液バランス制限 -->
                <div class="prospect-area-limit prospect-area-item">
                  <div class="lable-limit lable-botton">補液バランス制限</div>
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <device-input-number -->
                  <!--   ref="required1" -->
                  <!--   :device-info="supplyLiquidBalanceRestriction" -->
                  <!--   :disabled="isTreatRecord" -->
                  <!--   @change="changeButton(false)" -->
                  <!--   @input="setInputNumberChange" -->
                  <!-- @wheel.prevent="setInputNumberChange" -->
                  <!-- @keydown.up.prevent="setInputNumberChange" -->
                  <!-- @keydown.down.prevent="setInputNumberChange" -->
                  <!--   /> -->
                  <device-input-number
                    ref="required1"
                    :device-info="supplyLiquidBalanceRestriction"
                    :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                    @change="changeButton(false)"
                    @input="setInputNumberChange"
                    @wheel.prevent="setInputNumberChange"
                    @keydown.up.prevent="setInputNumberChange"
                    @keydown.down.prevent="setInputNumberChange"
                  />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </div>
                <div class="prospect-area-item lable-volume">
                  <v-ons-row>
                    予想補液量
                  </v-ons-row>
                  <v-ons-row>
                    {{ prospectSupplyLiquid }}
                  </v-ons-row>
                  <v-ons-row>
                    mL
                  </v-ons-row>
                </div>
                <div class="prospect-area-item">
                  <v-ons-row>
                    予想回収量
                  </v-ons-row>
                  <v-ons-row>
                    {{ prospectRecoveredAmount }}
                  </v-ons-row>
                  <v-ons-row>
                    mL
                  </v-ons-row>
                </div>
              </v-ons-col>
            </v-ons-row>
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
import { Chart } from "highcharts-vue";
import {
  DEVICE_TYPE_IHDF,
  DATA_SOURCE_TYPE_ORD
} from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
import baseEditor from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoEditor.vue";
import IHdfImg from "@/../public/img/deviceset-info/BackGroundImage.png";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import { ApiHelper } from "@/apis/AxiosHelper";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { mapActions, mapGetters } from "vuex";
import { EventBus } from "@/eventBus";
//add #10246  message change zrx start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
//add #10246  message change zrx start

/** * I-HDFプログラム */
export default {
  components: {
    highcharts: Chart,
    "message-dialog": messageDialog
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
      IHdfImg,
      isIHdfCommonSetting: true,
      restrictedBalanceMessage: false,
      boundsFluidReplacement: false,
      // 画面切り替えフラグ
      isChangeDisplayDialogVisble: false,
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
      initModelValue:undefined,
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end
    };
  },

  computed: {
    ...mapGetters("account-edit", {
      fontSize: "getFontSize",
    }),
    // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start
    ...mapGetters("pat-viewer-modal", {
      getIhdfAnswerThreeDevA: "getIhdfAnswerThreeDevA",
    }),
    // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end
    // add #12462 患者情報共有 Ji start
    ...mapGetters("user", ["getFacilityCd"]),
    // add #12462 患者情報共有 Ji end

    /**
     * @description 補液速度
     */
    supplyLiquidSpeed() {
      return this.devA[201];
    },

    /**
     * @description 補液開始時間
     */
    supplyLiquidStartTime() {
      return this.devA[203];
    },

    /**
     * @description 除水再開時間
     */
    removeWaterRestartTime() {
      return this.devA[204];
    },

    /**
     * @description 補液周期
     */
    supplyLiquidCycle() {
      return this.devA[202];
    },

    /**
     * @description 予定補液回数
     */
    countScheduleSupplyLiquid() {
      return this.devA[433];
    },

    /**
     * @description 補液バランス制限
     */
    supplyLiquidBalanceRestriction() {
      return this.devA[434];
    },

    /**
     * @description 総補液量上限
     */
    totalSupplyLiquidUpperLimit() {
      return this.devA[205];
    },

    /**
     * @description プログラム使用選択
     */
    programUse() {
      return this.devA[432];
    },

    // 補液量
    supplyLiquid() {
      return [
        this.devA[435],
        this.devA[436],
        this.devA[437],
        this.devA[438],
        this.devA[439],
        this.devA[440],
        this.devA[441],
        this.devA[442],
        this.devA[443],
        this.devA[444],
        this.devA[445],
        this.devA[446],
        this.devA[447],
        this.devA[448],
        this.devA[449],
        this.devA[450]
      ];
    },

    // // 回収量
    recoveredAmount() {
      return [
        this.devA[451],
        this.devA[452],
        this.devA[453],
        this.devA[454],
        this.devA[455],
        this.devA[456],
        this.devA[457],
        this.devA[458],
        this.devA[459],
        this.devA[460],
        this.devA[461],
        this.devA[462],
        this.devA[463],
        this.devA[464],
        this.devA[465],
        this.devA[466]
      ];
    },

    /**
     * @description 値
     * @returns {Array}
     */
    deviceSetInfoList() {
      return [
        // 補液速度
        this.supplyLiquidSpeed,
        // 補液開始時間
        this.supplyLiquidStartTime,
        // 予定補液回数
        this.countScheduleSupplyLiquid,
        // 除水再開時間
        this.removeWaterRestartTime,
        // 補液周期
        this.supplyLiquidCycle,
        // 総補液量上限
        this.totalSupplyLiquidUpperLimit
      ];
    },

    /**
     * @description バランス
     * @summary
     * @returns {Array}
     */
    balancedList() {
      const balancedList = [];
      let sum = 0;
      for (let i = 0; i < this.supplyLiquid.length; i++) {
        if (i !== 0) {
          // 現ステップまでの合計値
          sum +=
            this.supplyLiquid[i - 1].value.editValue -
            this.recoveredAmount[i - 1].value.editValue;
        }
        balancedList.push(
          // バランス = 現在ステップまでの補液量の合計 - 現在ステップまでの回収量の合計
          // バランス = 現ステップの補液量の回収量合計 + 現ステップまでの補液量・回収量の合計※実装の関係でこちらを採用
          this.supplyLiquid[i].value.editValue -
            this.recoveredAmount[i].value.editValue +
            sum
        );
      }
      return balancedList;
    },

    /**
     * @description バランス制限有無
     * @summary
     * @returns {Boolean}
     */
    isRestrictedBalance() {
      // 予定補液回数値のバランス値と補液バランス上限を比較
      const index = this.countScheduleSupplyLiquid.value.editValue - 1;
      return (
        Math.abs(this.balancedList[index])  >
        this.supplyLiquidBalanceRestriction.value.editValue
      );
    },

    /**
     * @description 総補液量上限制御有無(メッセージ表示用)
     * @summary
     * @returns {Boolean}
     */
    isTotalSupplyLiquidUpperLimit() {
      // 予定補液量・予想回収量と総補液量上限を比較
      const totalSupplyLiquidUpperLimit = this.totalSupplyLiquidUpperLimit.value
        .editValue;

      // 単位変換 mL → L
      const prospectSupplyLiquid = this.prospectSupplyLiquid / 1000;
      const prospectRecoveredAmount = this.prospectRecoveredAmount / 1000;

      return (
        prospectSupplyLiquid > totalSupplyLiquidUpperLimit ||
        prospectRecoveredAmount > totalSupplyLiquidUpperLimit
      );
    },

    /**
     * @description 予想補液量
     * @returns {Number}
     */
    prospectSupplyLiquid() {
      // 補液量の合計
      let sum = 0;
      for (const item of this.supplyLiquid) {
        //mod #11120 I-HDF設定内の破棄確認メッセージ不正 張玲 start
        // sum += item.value.editValue;
        sum += Number(item.value.editValue);
        //mod #11120 I-HDF設定内の破棄確認メッセージ不正 張玲 end
      }
      return sum;
    },

    /**
     * @description 予想回収量
     * @returns {Number}
     */
    prospectRecoveredAmount() {
      // 回収量の合計
      let sum = 0;
      for (const item of this.recoveredAmount) {
        //mod #11120 I-HDF設定内の破棄確認メッセージ不正 張玲 start
        // sum += item.value.editValue;
        sum += Number(item.value.editValue);
        //mod #11120 I-HDF設定内の破棄確認メッセージ不正 張玲 end
      }
      return sum;
    },

    /**
     * @description オプション設定(ハイチャート必須項目)
     * @summary
     * @returns {Object}
     */
    chartOptions() {
      const stepNumber = this.countScheduleSupplyLiquid.value.editValue;
      const supplyLiquid = {
        // 各グラフ表示データ
        data: this.supplyLiquid.map((item, index) => {
          // ステップ数以降は0を設定：非表示
          return index < stepNumber ? parseFloat(item.value.editValue) : 0;
        })
      };

      const recoveredAmount = {
        // 各グラフ表示データ
        data: this.recoveredAmount.map((item, index) => {
          // ステップ数以降は0を設定：非表示
          // 負数変換
          return index < stepNumber ? parseFloat(item.value.editValue) * -1 : 0;
        })
      };

      return {
        chart: {
          height: "300",
          // グラフバックカラー
          backgroundColor: "#FFF",
          // グラフ外枠線
          borderWidth: 1,
          // グラフ外枠線色
          borderColor: "#999",
          // グラフ種類
          type: "column",
          events: {
            load() {
              // 初期ロード時にスクロールバー有無によってチャートがちゃんと描画されてないことがあるため
              // 描画された直後、1秒待機をして強制的リサイズをする
              // setTimeout(() => {
                this.reflow();
              // }, 1000);
            }
          },
          marginTop: 25
        },
        // ラベル表示
        credits: {
          enabled: false
        },
        // 凡例表示
        legend: {
          enabled: false
        },
        // マーカー表示
        plotOptions: {
          spline: {
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
        },
        // グラフx軸
        xAxis: [
          {
            // 軸等を表示
            visible: true,
            // 軸の目盛りを表示
            labels: {
              enabled: false
            },
            // メモリ間隔
            tickInterval: 0,
            // 主目盛のピクセル幅
            tickWidth: 0
          }
        ],
        // グラフy軸
        yAxis: [
          {
            // y軸の目盛り
            tickPositions: [
              -500,
              -400,
              -300,
              -200,
              -100,
              0,
              100,
              200,
              300,
              400,
              500
            ],
            title: {
              // y軸タイトル表示※text：タイトル名
              enabled: false
            },
            // y軸目盛りを反対側(右側)へ表示
            opposite: false,
            // 軸等を表示
            visible: true,
            labels: {
                y:5
              },
          }
        ],
        exporting: [
          {
             enabled:false
          }
        ],
        // グラフタイトル
        title: {
          // タイトル名(非表示はundefinedを設定)※デフォルト値はundefined
          text: undefined
        },
        // グラフ各データ
        series: [supplyLiquid, recoveredAmount],
        // ツールチップ表示
        tooltip: {
          enabled: false
        }
      };
    }
  },

  watch: {
    /**
     * @description 装置設定値
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
        // 初期動作フラグ
        this.$emit("update:isProgramUseChacked", true);
      }
      this.$nextTick(() => {
        // 画面から変数を変更できなくしたため手動変更
        this.programUse.value.editValue = "1";
        // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start
        if (this.getIhdfAnswerThreeDevA) {
          let devA = this.getIhdfAnswerThreeDevA;
          for (let key in this.devA) {
            if (devA[key]) {
              this.devA[key].value.editValue = devA[key];
            }
          }
        }
        // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end
      });

      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
      this.initModelValue = JSON.parse(JSON.stringify(this.devA));
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end
    },
    /**
     * @description 文字サイズ
     */
    fontSize() {
      // グラフのリサイズ
      this.$refs.refIHdfProgramChart.chart.reflow();
    }
  },

  methods: {
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start
    ...mapActions('pat-viewer-modal', ["setIhdfAnswerThreeDevA"]),
    // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return this.isMst || (this.isMst != true && getAuthorized(pageCd, itemCd));
    },
    // add #10359 編集権限の動作不正 dengshen end
    /**
     * @description 保存時のバリデーション処理
     * @returns {Object}
     *   成功時: null
     *   失敗時: メッセージダイアログ用オブジェクト { messageCd, stringParams }
     */
    validateBeforeUpdating() {
      if (this.isRestrictedBalance) {
        // 補液バランス制限
        //mod #10246  message change zrx start
        // return { messageCd: 23020005 };
        return { messageCd: 23020005, title: DIALOG_MESSAGES[23020005].title };
        //mod #10246  message change zrx end
      }
      //mod #10246  message change zrx start
      // if (this.isTotalSupplyLiquidUpperLimit) {
      //   // 総補液量上限
      //   return { messageCd: 23020006 };
      // } else {
      //   // 成功
      //   return null;
      // }
      // 成功
      return null;
      //mod #10246  message change zrx end
    },

    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    setInputNumberChange() {
      // #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start
      // EventBus.$emit("deviceSetChanged");
      this.$nextTick(()=>{
        this.changeButton();
      })
      // #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end
    },
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end

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
        this.$emit("update:isIhdfMain", true);
      } else {
        // 親コンポーネントのラジオボタン状態を操作
        this.$emit("change-radio", true);
      }
      this.isChangeDisplayDialogVisble = false;
    },

    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
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
        getErrorMessage('IHdfProgramEditor.vue', 'getComponentData', error);
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
            for (let key in this.devA) {
              if (this.devA[key].value.editValue != this.initModelValue[key].value.editValue) {
                tempData.ihdf.dev.A[key] = this.devA[key].value.editValue;
              }
            }
          }
          for (let key in this.devA) {
            this.devA[key].value.editValue = tempData.ihdf.dev.A[key];
            // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start
            if (answer == 2) {
              this.devA[key].value.initValue = this.devA[key].value.editValue;
            }
            // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end
          }
          // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start
          if (tempData?.ihdf?.dev?.A) {
            this.$emit("change-start-date", tempData.ihdf.dev.A, answer);
          }
          // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end
        }
      }

      this.initModelValue = JSON.parse(JSON.stringify(this.devA));
    },
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end
    changeButton(val) {
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定 20240220 ztc start
      EventBus.$emit( "mstTreatmentSetRegistered", !this.isEdit());
      this.$parent.$parent.$parent.ihdfChangeFlag = this.isEdit();
      // if(false === val) {
      //   EventBus.$emit("deviceSetChanged");
      // }
      EventBus.$emit("deviceSetChanged", this.isEdit());
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定 20240220 ztc end
    },
    changeIsIHdfCommonSetting(val) {
      this.isIHdfCommonSetting = val;
      let mainAreaObj = document.getElementsByClassName("device-info-content-area");
      if (mainAreaObj.length > 0) {
        // グラフ表示の時は、幅を変更する
        mainAreaObj[0].style.minWidth = this.isIHdfCommonSetting ? "58em" : "84em";
        if (!this.isIHdfCommonSetting) {
          // グラフのリサイズ
          this.$nextTick(() => {
            this.$refs.refIHdfProgramChart.chart.reflow();
          });
        }
      }
      this.changeButton();
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
  mounted() {
    setTimeout(() => {
      // let mainAreaObj = document.getElementsByClassName("device-info-content-area");
      // if (mainAreaObj.length > 0) {
      //   // 初期表示時の幅調整
      //   mainAreaObj[0].style.minWidth = "53em";
      // }
      this.setLoadingScreenVisible(false);
    },500)
  },
  beforeDestroy() {
    // let mainAreaObj = document.getElementsByClassName("device-info-content-area");
    // if (mainAreaObj.length > 0) {
    //   // 非表示時、幅を戻す
    //   mainAreaObj[0].style.minWidth = "71em";
    // }
    const chartRef = this.$refs.refIHdfProgramChart;
    if (chartRef?.chart) {
      if (typeof chartRef.chart.destroy === 'function') {
        chartRef.chart.destroy();
      }
      chartRef.chart = null;
    }
  }
};
</script>

<style src="../base-modules/BeseDeviceSetInfoStyle.css" scoped></style>
<style scoped>
.device-info-main-content {
  max-height: none;
  overflow: none;
}

.i-hdf-img,
.chart-content {
  width: 100%;
  height: 100%;
}

.chart-area{
   margin: auto;
}

.chart-main-area {
  padding-left: 15px;
}

/* 画面配置 */

.device-info-cell-content {
  width: 100%;
  margin: auto;
}

.device-info-img-content {
  position: relative;
  /* TODO width: 58em; */
  width: calc(58em - 2px);
  margin: auto;
}

.deviceSetInfo-input {
  position: absolute;
}

.balance-input {
  width: 45px;
  font-size:0.9em;
}

.device-input-chart >>> .custom-input-number {
  width: 100%;
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
  top: 90%;
  left: 12%;
}

.device3 {
  top: 34%;
  left: 41%;
}

.device4 {
  top: 14%;
  left: 47%;
}

.device5 {
  top: 90%;
  left: 45%;
}

.dev_A_0434 {
  top: 90%;
  left: 31%;
}

.chart-area {
  min-width: 0;
}

.prospect-area {
  padding: 0px 0px 0px 15px;
  flex: 0;
}

.deviceSetInfo-chart-title {
  width: 100px;
}

.deviceSetInfo-chart-title {
  width: 55px;
  font-size:0.95em;
}

.device-info-left {
  text-align: left;
}

.ihdf-button-area {
  height: 2.3em;
}

.first-of-type {
  border-radius: 10px 0 0 10px;
}

.last-of-type {
  border-radius: 0 10px 10px 0;
}

.group-label {
  display: block; /* ブロックレベル要素化する */
  width: 8em;
  float: left; /* 要素の左寄せ・回り込を指定する */
  height: 2em; /* ボックスの高さを指定する */
  padding-left: 5px; /* ボックス内左側の余白を指定する */
  padding-right: 5px; /* ボックス内御右側の余白を指定する */
  color: #ffffff; /* フォントの色を指定する */
  text-align: center; /* テキストのセンタリングを指定する */
  line-height: 2em; /* 行の高さを指定する */
  cursor: pointer; /* マウスカーソルの形（リンクカーソル）を指定する */
  white-space: nowrap;
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
  .calculation-area >>> * {
    font-size: 0.8em !important;
  }

  .calculation-disclaimer{
    font-size: 0.8em !important;
  }
}
.prospect-area-limit {
  margin: 42px 0;
}
.lable-botton {
  margin-bottom: 2px;
}
.lable-volume {
  margin-top: 35px;
}
@media screen and (max-width: 768px) {
  .lable-limit {
    margin-bottom: 0.7em;
  }
}
@media print {
  .device-info-img-content {
    width: 100% !important;
  }
  
  /* グラフの数値IF 幅 */
  .chart-content >>> .custom-input-number input[type="number"] {
    min-width: 50px;
  }
}
/* 縦向き印刷時のみ */
@media print and (orientation: portrait) {
  /* 画像の数値IF 幅高さ */
  .device-info-img-content >>> .custom-input-number {
    width: 3.5em !important;
  }
  .device-info-img-content >>> .custom-input-number input[type="number"] {
    height: 1.3em !important;
  }
  
  /* グラフの数値IF 幅 */
  .chart-content >>> .custom-input-number input[type="number"] {
    min-width: 45px;
  }
  .chart-content >>> .deviceSetInfo-chart-row.fixed-width > ons-col {
    flex: 0 0 45px;
    max-width: 45px;
  }
  /* タイトル列 */
  .chart-content >>> .deviceSetInfo-chart-row.fixed-width > ons-col:first-child {
    flex: 0 0 100% !important;
    max-width: 100% !important;
  }
  /* 入力列 */
  .chart-content >>> .deviceSetInfo-chart-row.fixed-width > ons-col:not(:first-child) {
    flex: 0 0 auto !important;
  }
}
</style>
