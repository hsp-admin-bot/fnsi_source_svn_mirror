<!--Na注入プログラム-->
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
          Na注入プログラム
        </v-ons-row>
        <v-ons-row v-else class="device-info-main-title" />
        <div class="device-info-main-content">
          <!-- 項目 -->
          <v-ons-row class="device-info-cell device-info-left">
            <v-ons-col class="device-info-cell-value">
              <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
              <!-- <device-select
                ref="select1"
                :device-info="devA[315]"
                :disabled="isTreatRecord"
                @change="changeButton(false)"
              /> -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-select -->
              <!--   ref="select1" -->
              <!--   :device-info="devA[315]" -->
              <!--   :disabled="isTreatRecord" -->
              <!-- /> -->
              <device-select
                ref="select1"
                :device-info="devA[315]"
                :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
            </v-ons-col>
            <v-ons-col class="device-info-cell-value device-info-cell-rigth">
              <!-- mod FNSI-FutreNetWeb+SI課題管理No.5249 李 start -->
              <!-- 工数切替時間 -->
              工程切替時間
              <!-- mod FNSI-FutreNetWeb+SI課題管理No.5249 李 end -->
              <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
              <!-- <device-input-number
                ref="required_number1"
                :device-info="devA[326]"
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
              <!--   :device-info="devA[326]" -->
              <!--   :disabled="isTreatRecord" -->
              <!--   @input="setInputNumberChange" -->
              <!--   @wheel.prevent="setInputNumberChange" -->
              <!--   @keydown.up.prevent="setInputNumberChange" -->
              <!--   @keydown.down.prevent="setInputNumberChange" -->
              <!-- /> -->
              <device-input-number
                ref="required_number1"
                :device-info="devA[326]"
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
                :device-info="devA[328]"
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
              <!--   :device-info="devA[328]" -->
              <!--   :disabled="isTreatRecord" -->
              <!--   @input="setInputNumberChange" -->
              <!--   @wheel.prevent="setInputNumberChange" -->
              <!--   @keydown.up.prevent="setInputNumberChange" -->
              <!--   @keydown.down.prevent="setInputNumberChange" -->
              <!-- /> -->
              <device-input-number
                ref="required_number2"
                :device-info="devA[328]"
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
              ＵＦＲプロ連動
              <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
              <!-- <device-radio
                ref="radio1"
                :device-info="devA[327]"
                :disabled="isTreatRecord"
                @change="changeButton(false)"
              /> -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-radio -->
              <!--   ref="radio1" -->
              <!--   :device-info="devA[327]" -->
              <!--   :disabled="isTreatRecord" -->
              <!-- /> -->
              <device-radio
                ref="radio1"
                :device-info="devA[327]"
                :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
            </v-ons-col>
          </v-ons-row>

          <!-- グラフ -->
          <v-ons-row class="device-info-cell">
            <v-ons-col>
              <highcharts :options="chartOptions" class="high-charts" :class="isUnderSubModal" ref="refNaProgramChart" />
            </v-ons-col>
          </v-ons-row>

          <!-- 項目 -->
          <v-ons-row class="device-info-cell device-setting-area">
            <v-ons-col
              v-for="(device, index) in deviceInfoGraphList"
              :key="index"
              class="device-info-cell-value"
            >
            <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
              <!-- <device-input-number
                :ref="`required_${index}`"
                :device-info="device"
                class="device-input-charts"
                :disabled="isTreatRecord || devA[315].value.editValue === '2'"
                @change="changeButton(false)"
                @input="setInputNumberChange"
                @wheel.prevent="setInputNumberChange"
                @keydown.up.prevent="setInputNumberChange"
                @keydown.down.prevent="setInputNumberChange"
              /> -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   :ref="`required_${index}`" -->
              <!--   :device-info="device" -->
              <!--   class="device-input-charts" -->
              <!--   :disabled="isTreatRecord || devA[315].value.editValue === '2'" -->
              <!--   @input="setInputNumberChange" -->
              <!--   @wheel.prevent="setInputNumberChange" -->
              <!--   @keydown.up.prevent="setInputNumberChange" -->
              <!--   @keydown.down.prevent="setInputNumberChange" -->
              <!-- /> -->
              <device-input-number
                :ref="`required_${index}`"
                :device-info="device"
                class="device-input-charts"
                :disabled="isTreatRecord || devA[315].value.editValue === '2' || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                @input="setInputNumberChange"
                @wheel.prevent="setInputNumberChange"
                @keydown.up.prevent="setInputNumberChange"
                @keydown.down.prevent="setInputNumberChange"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="device-info-cell device-info-left">
            <v-ons-col class="device-info-cell-value">
              <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
              <!-- <device-input-number
                ref="required_number3"
                :device-info="devA[329]"
                :disabled="isTreatRecord || devA[315].value.editValue === '1'"
                @change="changeButton(false)"
                @input="setInputNumberChange"
                @wheel.prevent="setInputNumberChange"
                @keydown.up.prevent="setInputNumberChange"
                @keydown.down.prevent="setInputNumberChange"
              /> -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   ref="required_number3" -->
              <!--   :device-info="devA[329]" -->
              <!--   :disabled="isTreatRecord || devA[315].value.editValue === '1'" -->
              <!--   @input="setInputNumberChange" -->
              <!--   @wheel.prevent="setInputNumberChange" -->
              <!--   @keydown.up.prevent="setInputNumberChange" -->
              <!--   @keydown.down.prevent="setInputNumberChange" -->
              <!-- /> -->
              <device-input-number
                ref="required_number3"
                :device-info="devA[329]"
                :disabled="isTreatRecord || devA[315].value.editValue === '1' || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
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
                :device-info="devA[330]"
                :disabled="isTreatRecord || devA[315].value.editValue === '1'"
                @change="changeButton(false)"
                @input="setInputNumberChange"
                @wheel.prevent="setInputNumberChange"
                @keydown.up.prevent="setInputNumberChange"
                @keydown.down.prevent="setInputNumberChange"
              /> -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   ref="required_number4" -->
              <!--   :device-info="devA[330]" -->
              <!--   :disabled="isTreatRecord || devA[315].value.editValue === '1'" -->
              <!--   @input="setInputNumberChange" -->
              <!--   @wheel.prevent="setInputNumberChange" -->
              <!--   @keydown.up.prevent="setInputNumberChange" -->
              <!--   @keydown.down.prevent="setInputNumberChange" -->
              <!-- /> -->
              <device-input-number
                ref="required_number4"
                :device-info="devA[330]"
                :disabled="isTreatRecord || devA[315].value.editValue === '1' || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
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
            <v-ons-col class="device-info-cell-value device-info-left">
              Na注入濃度最大値
              <!-- mod redmine 6052 Na注入プログラムの設定濃度がNa注入濃度最大値を超えて設定できてしまう 宋qy start -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   ref="required_number5" -->
              <!--   :device-info="devA[184]" -->
              <!--   :disabled="isTreatRecord" -->
              <!--   @change="changeNaMax($event)" -->
              <!--   @input="setInputNumberChange" -->
              <!--   @wheel.prevent="setInputNumberChange" -->
              <!--   @keydown.up.prevent="setInputNumberChange" -->
              <!--   @keydown.down.prevent="setInputNumberChange" -->
              <!-- /> -->
              <device-input-number
                ref="required_number5"
                :device-info="devA[184]"
                :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                @change="changeNaMax($event)"
                @input="setInputNumberChange"
                @wheel.prevent="setInputNumberChange"
                @keydown.up.prevent="setInputNumberChange"
                @keydown.down.prevent="setInputNumberChange"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- mod redmine 6052 Na注入プログラムの設定濃度がNa注入濃度最大値を超えて設定できてしまう 宋qy start -->
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
        v-model:visible="isDialogVisble"
        v-bind="dialogProps"
        type="1"
        @confirm="saveEdit"
      />
      <message-dialog
        v-model:visible="isCancelDialogVisble"
        v-bind="dialogProps"
        type="2"
        @confirm="cancelEdit"
      />
    </div>
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { deepCopy, getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { Chart } from "@/compat/charts/highcharts";
import {
  DEVICE_TYPE_NA,
  DATA_SOURCE_TYPE_ORD
} from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
import baseEditor from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoEditor.vue";
//FNSI-修正【患者経過総合ビューア】#4859 横展開対応、fan add start
import { ApiHelper } from "@/apis/AxiosHelper";
//FNSI-修正【患者経過総合ビューア】#4859 横展開対応、fan add end
import {EventBus} from "@/compat/vue/event-bus.js";

import DeviceSetOwnerMixin from '@/components/deviceset-info/base-modules/DeviceSetOwnerMixin';
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
/**
 * @description Na注入プログラム設定値編集画面
 */
export default {
  components: {
    highcharts: Chart
  },

  mixins: [DeviceSetOwnerMixin, baseEditor],

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
      deviceType: DEVICE_TYPE_NA,

      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
      initModelValueDevA:undefined,
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start
      devADefault: {},
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end
    };
  },

  computed: {
    ...mapGetters("pat-viewer-modal", ["getSettingIndChildData"]),
    ...mapGetters("account-edit", {
      fontSize: "getFontSize",
    }),
    ...mapGetters("user", ["getFacilityCd"]),

    /**
     * @description グラフ編集値
     * @returns {Array} 入力項目テキストボックスタイプNumber
     */
    deviceInfoGraphList() {
      return [
        this.devA[316],
        this.devA[317],
        this.devA[318],
        this.devA[319],
        this.devA[320],
        this.devA[321],
        this.devA[322],
        this.devA[323],
        this.devA[324],
        this.devA[325]
      ];
    },

    /**
     * @description オプション設定(ハイチャート必須項目)
     * @summary
     * @returns {Object}
     */
    chartOptions() {
      let chartType;
      const chartData = [];
      // 数字または文字列の1と2をサポートするため、文字列に変換
      const editValue = String(this.devA[315].value.editValue);
      switch (editValue) {
        case "1":
          chartType = "column";
          this.deviceInfoGraphList.forEach(item => {
            chartData.push(parseInt(item.value.editValue));
          });
          //mod FutureNetWeb+Si no.5899 劉全航 start
          var URFFlag = this.devA[327].value.initValue;
          if(URFFlag === "1"){
            if(this.deviceSetInfoRaw.ufr){
              let finalProgram = this.deviceSetInfoRaw.ufr.dev.A["311"];
              let ufrState = this.deviceSetInfoRaw.ufr.dev.A["290"];
              if(ufrState === "1" && finalProgram < 10){
                for(let i = finalProgram; i < 10 ; i ++){
                  chartData[i] = 0;
                }
              }
            }
          }
          //mod FutureNetWeb+Si no.5899 劉全航 end
          break;

        case "2":
          // TODO: ハイチャートでエラー発生対策不明※一時的に保留
          chartType = "spline";
          for (let i = 1; i < 11; i++) {
            const CourseUFR = parseFloat(this.devA[328].value.editValue);
            const CourseStartUFR = parseFloat(this.devA[329].value.editValue);
            const CourseEndUFR = parseFloat(this.devA[330].value.editValue);

            const Ts = (480 / 10) * (i - 1);
            const X = -0.5 * (CourseUFR - 1) * (CourseUFR - 4) * (1 - Ts / 480);
            const Exp = Math.exp(X);

            const In =
              ((CourseEndUFR - CourseStartUFR) / 480) * Ts * Exp +
              parseFloat(CourseStartUFR);

            chartData.push(parseFloat(In));
          }
          break;
        default:
      }
      return {
        chart: {
          height: "175",
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
            },
            render: function () {
              const chart = this;
              // 重複作成を防止
              if (chart.customBorder) {
                  chart.customBorder.destroy();
              }
              const left = chart.plotLeft;
              const top = chart.plotTop;
              const width = chart.plotWidth;
              const height = chart.plotHeight;
              // インスタンスを保存
              chart.customBorder = chart.renderer
                  .rect(left,top,width,height,0)
                  .attr({
                      stroke: '#e1e1e1',
                      'stroke-width': 2,
                      fill: 'transparent',
                      zIndex: 10
                  })
                  .add();
            }
          },
          marginTop: 25,
          marginBottom: 10
        },
        // ラベル表示
        credits: {
          enabled: false
        },
        // 凡例表示
        legend: {
          enabled: false
        },
        // グラフx軸
        xAxis: [
          {
            // メモリ間隔
            tickInterval: 0,
            // 主目盛のピクセル幅
            tickWidth: 0,
            // 軸等を表示
            visible: false
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
            max: 50,
            // 目盛りの数※目盛りの間隔は自動で平均を設定される
            tickAmount: 6,
            // y軸タイトル表示※text：タイトル名
            title: {
              enabled: false
            },
            // 軸等を表示
            visible: true
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
            data: chartData,
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
        },
        plotOptions: {
          series: {
            // 棒グラフ幅
            // pointWidth: 30,
            // 棒グラフ間の幅
            // pointPadding: 0
          },
          // column: {
          //   pointPlacement: "between"
          // }
          column: {
            animation: false
          }
        }
      };
    },

    /**
     * @description 患者経過総合ビューアで表示している時は、画面が小さい時のスタイル用classを付与する
     * @returns {String} class
     */
    isUnderIndModal() {
      const indObj = this._deviceSetClosestOrScopedElement(".indInfo-style-modal-container");
      if (indObj) {
        return "ind-style-media-query";
      }
      return "";
    },

    /**
     * @description sub-modal 配下に表示している際のフォントサイズ設定割り当て用class
     * @returns {String} class
     */
    isUnderSubModal() {
      const subModalObj = this._deviceSetClosestOrScopedElement(".sub-modal-body");
      if (subModalObj) {
        return "is-under-sub-modal";
      }
      return "";
    }
  },

  watch: {
    deviceSetInfo() {
      if (this.dataSourceType === DATA_SOURCE_TYPE_ORD) {
        // 親のスタイル修正
        this._deviceSetDialogOwner().styleObj = { "max-width": "640px", width: "100%" };
      }

      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
      this.initModelValueDevA = JSON.parse(JSON.stringify(this.devA));
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end
      // add #9857、Na注入プログラム最大値の制限が適用されずに編集可能の修正 limf start
      this.changeMaxValue();
      // add #9857、Na注入プログラム最大値の制限が適用されずに編集可能の修正 limf end
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start
      this.devADefault = JSON.parse(JSON.stringify(this.devA));
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end
    },
    fontSize() {
      // グラフのリサイズ
      this.$refs.refNaProgramChart.chart.reflow();
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

  methods: {
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "startLoadingScreen",
      "finishLoadingScreen"
    ]),
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return this.isMst || (this.isMst != true && !this.isOtherFacilityRow() && getAuthorized(pageCd, itemCd));
    },
    /**
     * @description 該当行が他院情報かどうかを判定
     * @returns {Boolean} true = 他施設のデータは参照のみ
     */
    isOtherFacilityRow() {
      const facilityCd = this.getSettingIndChildData?.facilityCd;
      return facilityCd ? facilityCd !== this.getFacilityCd : false;
    },
    // add #10359 編集権限の動作不正 dengshen end
    /**
     * @description 保存前のバリデーション処理
     * @returns {Object}
     *   成功時: null
     *   失敗時: メッセージダイアログ用オブジェクト { messageCd, stringParams }
     */
    validateBeforeUpdating() {
      return null;
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
      console.log("NaProgramEditor.vue updateIndInfo this.startLoadingScreen();");
      this.startLoadingScreen();
      // 治療情報更新
      if (this.getSettingIndChildData.isAllSave) {
        // 一括更新
        this.save(structData);
      } else {
        this.ordMainAllSave(structData);
      }
      console.log("NaProgramEditor.vue updateIndInfo this.finishLoadingScreen();");
      this.finishLoadingScreen();
    },
    /**
     * @description 未編集通知ダイアログ後保存ボタンを活性へ(指示画面のみ)
     */
    saveEdit() {
      if (this.dataSourceType === DATA_SOURCE_TYPE_ORD) {
        this._deviceSetDialogOwner().updateDisable = false;
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
        this._deviceSetDialogOwner().messageDialogInfo.messageCd = 70000028;
        /* mod FNSI-4212 更新対象変更時のウインドウが不正 liumx start */
        this._deviceSetDialogOwner().messageDialogInfo.type = "9";
        /* mod FNSI-4212 更新対象変更時のウインドウが不正 liumx end */
        this._deviceSetDialogOwner().messageDialogInfo.isDialogVisible = true;
        return;
      } else {
        return this.getComponentData(structData,2);
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
        paramJson).catch(error => {
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
                tempData.na.dev.A[key] = this.devA[key].value.editValue;
              }

            }
          }
          for (let key in this.devA) {
            this.devA[key].value.initValue = initData.na.dev.A[key];
            this.devA[key].value.editValue = tempData.na.dev.A[key];
          }
        }
      }
      this.initModelValueDevA = JSON.parse(JSON.stringify(this.devA));
    },
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end
    // add redmine 6052 Na注入プログラムの設定濃度がNa注入濃度最大値を超えて設定できてしまう 宋qy start
    changeNaMax(event){
      let naMax = 0;
      if ((parseInt(event.target.value) > 0 && parseInt(event.target.value) < 50)) {
        naMax = parseInt(event.target.value);
        // mod #9857、判定範囲の修正 linjunfeng start
      } else if (parseInt(event.target.value) >= 50) {
        naMax = 50;
      }
      // mod #9857、判定範囲の修正 linjunfeng end
      // mod #9857、判定範囲の修正 limf start
      // if (parseInt(event.target.value) > 50) {
      //   naMax = 50;
      // }
      this.setMaxValue(naMax);
      // mod #9857、コーディング最適化 limf end
      for (let i = 316; i < 326 ; i++) {
        this.devA[i].maxValue = naMax;
        if (this.devA[i].value.editValue > naMax) {
          this.devA[i].value.editValue = naMax;
        }
      }
      this.devA[329].maxValue = naMax;
      if (this.devA[329].value.editValue > naMax) {
        this.devA[329].value.editValue = naMax;
      }
      this.devA[330].maxValue = naMax;
      if (this.devA[330].value.editValue > naMax) {
        this.devA[330].value.editValue = naMax;
      }
      this.changeButton(false);
    },
    // add #9857、Na注入プログラム最大値の制限が適用されずに編集可能の修正 limf start
    // パラメータにより、各項目の最大値を設定する
    setMaxValue(naMax){
      for (let i = 316; i < 326 ; i++) {
        this.devA[i].maxValue = naMax;
        if (this.devA[i].value.editValue > naMax) {
          this.devA[i].value.editValue = naMax;
        }
      }
      this.devA[329].maxValue = naMax;
      if (this.devA[329].value.editValue > naMax) {
        this.devA[329].value.editValue = naMax;
      }
      this.devA[330].maxValue = naMax;
      if (this.devA[330].value.editValue > naMax) {
        this.devA[330].value.editValue = naMax;
      }
    },
    // 「Na注入濃度最大値」を取得して、各項目の最大値を設定する
    changeMaxValue(){
      let naMax = this.devA[184].value.editValue;
      this.setMaxValue(naMax);
    },
    // add #9857、Na注入プログラム最大値の制限が適用されずに編集可能の修正 limf end
    // add redmine 6052 Na注入プログラムの設定濃度がNa注入濃度最大値を超えて設定できてしまう 宋qy end
    decimalModi() {
      const textInputs = this._deviceSetElementsByClassName("text-input");
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
    }
  },

  //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、fan add start
  async created() {
    this.setLoadingScreenVisible(true);
    this._deviceSetDialogOwner().isDialogType9 = true;
  },
  //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、fan add end
  mounted() {
    setTimeout(() => {
      this.decimalModi();
      this.changeButton(true);
      this.setLoadingScreenVisible(false);
    },500);
  },
  beforeUnmount() {
    const chartRef = this.$refs.refNaProgramChart;
    if (chartRef?.chart) {
      if (typeof chartRef.chart.destroy === 'function') {
        chartRef.chart.destroy();
      }
      chartRef.chart = null;
    }
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
};
</script>

<style src="../base-modules/BeseDeviceSetInfoStyle.css" scoped></style>

<style scoped>
/** iPhone X/8/7/6 or Android(M,L) */
/** Device Width:360-480           */
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
    min-width:500px;
    height:370px;
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
}

.device-info-cell {
  border: none;
}

.device-info-cell-value {
  padding: 0;
  margin: 4px;
}

.device-input-charts :deep(.custom-input-number) {
  width: 100%;
  padding: 0;
  margin: 0;
}

.device-info-cell-rigth {
  text-align: right;
}

.high-charts {
  margin: auto;
}

/* SubModal配下では、通常のModalのcssが当たらないので補正する */
.is-under-sub-modal {
  font-size: 1em;
}

.is-under-sub-modal :deep(*) {
  font-size: inherit !important;
}

.device-setting-area {
  /* グラフのY軸ラベルに合わせる */
  padding: 3px 10px 3px 35px;
}

.device-info-left {
  text-align: left;
}
</style>
