<template>
  <div
    v-if="deviceSetInfo !== null"
    :class="showButton ? 'device-info-container' : null"
  >
    <div class="device-info-content">
      <div class="device-info-content-area">
        <!-- ヘッダ -->
        <v-ons-row
          v-if="showButton"
          class="common-style-header device-info-main-title"
        >
          透析量プログラム
        </v-ons-row>
        <v-ons-row v-else class="device-info-main-title" />
        <div class="device-info-main-content">
          <!-- 項目 -->
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[282].formName }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
              <!-- <device-radio
                ref="radio2"
                :device-info="devA[282]"
                :disabled="isTreatRecord || disable"
                @change="changeButton(false)"
              /> -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-radio -->
              <!--   ref="radio2" -->
              <!--   :device-info="devA[282]" -->
              <!--   :disabled="isTreatRecord || disable" -->
              <!-- /> -->
              <device-radio
                ref="radio2"
                :device-info="devA[282]"
                :disabled="isTreatRecord || disable || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
            </v-ons-col>
          </v-ons-row>
          <div v-if="!isTreatRecord">
            <!-- タイトル -->
            <v-ons-row class="common-style-header device-info-cell-title">
              体液量＋補正量
            </v-ons-row>
            <!-- 項目 -->
          <v-ons-row v-if="isDataSourceTypeOrd" class="device-info-cell">
              <v-ons-col class="device-info-cell-name">
              {{ selectedRegExamDate.formLabel }}
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!--mod FNSI-検査日入力不可変更 楊 start -->
                <!--               <device-date
                ref="required_date"
                class="input-date custom-input-date"
                :device-info="selectedRegExamDate"
                />-->
              <device-date
                id="deviceDate"
                :disabled="true"
                ref="required_date"
                class="input-date custom-input-date custom-input"
                :callBackFunc="dateInput"
                :device-info="selectedRegExamDate"
                />
                <!--mod FNSI-検査日入力不可変更 楊 end -->
              </v-ons-col>
            </v-ons-row>
          <v-ons-row v-else class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              検査日
            </v-ons-col>
            <v-ons-col class="device-info-cell-value" />
          </v-ons-row>
            <!-- TODO: 検査結果ＤＢテーブルがないため参照ができない。テーブル構成精査中 -->
            <v-ons-row class="device-info-cell">
              <v-ons-col class="device-info-cell-name">
                検査日後体重
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
              <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
              <!-- <input
                class="input-text"
                type="text"
                :value="BWa"
                :disabled="true"
                @change="changeButton(false)"
              /> -->
              <input
                class="input-text"
                type="text"
                :value="BWa"
                :disabled="true"
              />
              <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
              kg
              </v-ons-col>
            </v-ons-row>
            <v-ons-row class="device-info-cell">
              <v-ons-col class="device-info-cell-name">
                透析時間
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!--mod FNSI-透析時間表示不全 楊 start -->
                <!--<input
                  class="input-time"
                  type="time"
                  :value="dialysisDisplayTime"
                  :disabled="true"
                /> -->
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
                <!-- <input
                  class="input-time"
                  type="text"
                  :value="dialysisDisplayTime"
                  :disabled="true"
                  @change="changeButton(false)"
                /> -->
                <input
                  class="input-time"
                  type="text"
                  :value="dialysisDisplayTime"
                  :disabled="true"
                />
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
                <!--mod FNSI-透析時間表示不全 楊 end -->
              </v-ons-col>
            </v-ons-row>

            <v-ons-row
              v-for="(device, index) in deviceList1"
              :key="`key1_${index}`"
              class="device-info-cell"
            >
              <v-ons-col class="device-info-cell-name">
                {{ device.formLabel }}
              </v-ons-col>
              <v-ons-col class="device-info-cell-value">
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
                <!-- <input
                  class="input-text"
                  type="text"
                  :value="device.value"
                  :disabled="true"
                  @change="changeButton(false)"
                /> -->
                <input
                  class="input-text"
                  type="text"
                  :value="device.value"
                  :disabled="true"
                />
                <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
                {{ device.unit }}
              </v-ons-col>
            </v-ons-row>
          </div>
          <!-- タイトル -->
          <v-ons-row class="common-style-header device-info-cell-title">
            透析量プログラム設定
          </v-ons-row>
          <!-- 項目 -->
          <v-ons-row
            v-for="(device, index) in deviceList2"
            :key="`key2_${index}`"
            class="device-info-cell"
          >
            <v-ons-col class="device-info-cell-name">
              {{ device.formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
              <!-- <input
                class="input-text"
                type="text"
                :value="device.value"
                :disabled="true"
                @change="changeButton(false)"
              /> -->
              <input
                class="input-text"
                type="text"
                :value="device.value"
                :disabled="true"
              />
              <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
              {{ device.unit }}
            </v-ons-col>
          </v-ons-row>

          <!-- 目標Kt/V -->
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[288].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value device-info-border-right">
              <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
              <!-- <device-input-number
                ref="required"
                :device-info="devA[288]"
                :disabled="isTreatRecord"
                @change="changeButton(false)"
                @input="setInputNumberChange"
                @wheel.prevent="setInputNumberChange"
                @keydown.up.prevent="setInputNumberChange"
                @keydown.down.prevent="setInputNumberChange"
              /> -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   ref="required" -->
              <!--   :device-info="devA[288]" -->
              <!--   :disabled="isTreatRecord" -->
              <!--   @input="setInputNumberChange" -->
              <!--   @wheel.prevent="setInputNumberChange" -->
              <!--   @keydown.up.prevent="setInputNumberChange" -->
              <!--   @keydown.down.prevent="setInputNumberChange" -->
              <!-- /> -->
              <!-- mod #11120 I-HDF設定内の破棄確認メッセージ不正 2024/09/12 情 start -->
              <!-- <device-input-number
                ref="required"
                :device-info="devA[288]"
                :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority')"
                @input="setInputNumberChange"
                @wheel.prevent="setInputNumberChange"
                @keydown.up.prevent="setInputNumberChange"
                @keydown.down.prevent="setInputNumberChange"
              /> -->
              <device-input-number
                class="diaysis-program-input-number-pro"
                ref="setInputNumberChange"
                :device-info="devA[288]"
                :required="false"
                :disabled="isTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
                @input="setInputNumberChange"
                @wheel.prevent="setInputNumberChange"
                @keydown.up.prevent="setInputNumberChange"
                @keydown.down.prevent="setInputNumberChange"
              />
              <!-- mod #11120 I-HDF設定内の破棄確認メッセージ不正 2024/09/12 情 end -->
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              <span>Kt/V上限</span>
            </v-ons-col>
            <v-ons-col class="device-info-cell-value device-info-border-right">
              <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
              <!-- <input
                class="input-text"
                type="text"
                :value="maxCalKtv"
                :disabled="true"
                @change="changeButton(false)"
              /> -->
              <input
                class="input-text"
                type="text"
                :value="maxCalKtv"
                :disabled="true"
              />
              <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end -->
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              <span>Kt/V下限</span>
            </v-ons-col>
            <v-ons-col class="device-info-cell-value device-info-border-right">
              <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start -->
              <!-- <input
                class="input-text"
                type="text"
                :value="minCalKtv"
                :disabled="true"
                @change="changeButton(false)"
              /> -->
              <input
                class="input-text"
                type="text"
                :value="minCalKtv"
                :disabled="true"
              />
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
import {deepCopy, getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import dayjs from "@/compat/date/dayjs";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import {
  DEVICE_TYPE_DIA,
  DATA_SOURCE_TYPE_ORD
} from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
import { dialyzer } from "@/functions/mst/MstGetters.js";
import baseEditor from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoEditor.vue";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
import {EventBus} from "@/compat/vue/event-bus.js";

import DeviceSetOwnerMixin from '@/components/deviceset-info/base-modules/DeviceSetOwnerMixin';
/**
 * @description 透析量プログラム設定値編集画面
 */
export default {
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
      selectedRegExamDate: {
        formName: "検査日",
        formLabel: "検査日",
        value: {
          initValue: null,
          editValue: null
        },
        selectedDates: {
          custom: [],
          default: []
        },
        disabledDates: [],
        disableDatesBefore: null,
        disableDatesAfter: null
      },
      deviceType: DEVICE_TYPE_DIA,
      dialysisDisplayTime: null,
      mstRegExamDateList: [],
      mstTreatDateList: [],
      // 体液量計算値
      calValue: null,
      // KtV目標値上限
      maxCalKtv: null,
      // KtV目標値下限
      minCalKtv: null,
      // 可能なKtV上限値※固定値
      maxKtv: 700,
      // 可能なKtV下限値※固定値
      minKtv: 300,
      // 体液量計算時の後体重
      BW: null,
      // 透析時間
      TX: null,
      // 透析前
      BUN1: null,
      // 透析後
      BUN2: null,
      // 除水
      DBWX: null,
      // 血液量
      QB: null,
      // 透析液流量
      QD: null,
      // add 10196 by kangjie 20240202 start del rst_device_set_info
      // 平均血液量
      // aveQB: null,
      // 透析液流量
      // aveQD: null,
      // add 10196 by kangjie 20240202 end del rst_device_set_info
      // KoA
      KOA0: null,
      // 再循環率※固定値
      RR: 0,
      // 透析後体重
      BWa: null,
      // 目標透析終了時体重
      BW2: null,

      regExamDateList: {
        default: [],
        custom: []
      },
      ordMainList: [],

      mstDialyzer: [],

      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
      initModelValue: null,
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start
      devADefault: {},
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end
    };
  },

  computed: {
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("user", ["getFacilityCd"]),
    // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
    // ...mapGetters("pat-viewer", ["getTreatmentData"]),
    ...mapGetters("pat-viewer", ["getTreatmentData", "getRecentTreatmentDate"]),
    // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
    ...mapGetters("pat-viewer-modal", ["getSettingIndChildData"]),
    ...mapGetters("user", ["getFacilityCd"]),
    //mod FNSI-6925 劉全航 start
    ...mapGetters("pat-viewer", ["getMstTreatmentData"]),
    //mod FNSI-6925 劉全航 end

    /**
     * @description
     */
    deviceList1() {
      return [
        { formLabel: "透析前ＢＵＮ", value: this.BUN1, unit: "mg/dL" },
        { formLabel: "透析後ＢＵＮ", value: this.BUN2, unit: "mg/dL" },
        { formLabel: "除水積算", value: this.DBWX, unit: "L" },
        { formLabel: "血流量", value: this.QB, unit: "mL/min" }
      ];
    },

    /**
     * @description
     * @returns
     */
    deviceList2() {
      return [
        { formLabel: "体液量＋補正値", value: this.calValue, unit: "L" },
        { formLabel: "体液量計算時の後体重", value: this.BW, unit: "kg" },
        { formLabel: "目標体重", value: this.BW2, unit: "kg" },
        { formLabel: "血流量", value: this.QB, unit: "mL/min" },
        { formLabel: "KoA", value: this.KOA0, unit: "" }
      ];
    },

    isDataSourceTypeOrd() {
      return this.dataSourceType === DATA_SOURCE_TYPE_ORD;
    }
    //mod FNSI-6925 劉全航 start
    ,disable(){
       if(this.isDataSourceTypeOrd && this.ordNo){
         let treatmentList = Object.values(this.getTreatmentData[0]);
         let ordMian = treatmentList?.find(o => {
           return o?.ordNo === this.ordNo;
         });
        // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
        if (!ordMian) {
          treatmentList = Object.values(this.getRecentTreatmentDate[0]);
          ordMian = treatmentList?.find(o => {
           return o?.ordNo === this.ordNo;
         });
        }
        // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
        let treatmentCd = ordMian.indTreatmentCd;
        let treatmentMethod = this.getMstTreatmentData.find(o=>{
          return o.treatmentCd === treatmentCd;
        })
        let deviceMode = treatmentMethod.deviceMode;
         if(deviceMode == 0 || deviceMode == 1){
           return false;
         }else{
           return true;
         }
       }else{
         return true;
       }
    }
    //mod FNSI-6925 劉全航 end
  },

  watch: {
    /**
     * @description 装置設定値
     * @summary ミックスインのcreatedでdeviceSetInfoに選択された各装置設定データが設定される
     */
    deviceSetInfo() {
      // 指示装置設定画面のみ透析日を参照する。
      if (this.dataSourceType === DATA_SOURCE_TYPE_ORD) {
        // 親のスタイル修正
        this._deviceSetDialogOwner().styleObj = { "max-width": "550px", width: "100%" };
      }
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
      this.initModelValue = JSON.parse(JSON.stringify(this.devA));
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start
      this.devADefault = JSON.parse(JSON.stringify(this.devA));
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end
    },

    "selectedRegExamDate.value.editValue"(date) {
      const selectedDate = dayjs(date, "YYYY-MM-DD").format("YYYYMMDD");
      const selectedOrdMainList = this.ordMainList.filter(
        ord => ord.treatDate === selectedDate);
      let selectedOrdMain = null;
      if (selectedOrdMainList.length > 0) {
        // 同じ日が複数ある場合は一番後ろ
        selectedOrdMain = selectedOrdMainList[selectedOrdMainList.length - 1];
        this.setOrdNo(selectedOrdMain.ordNo);
      } else {
        // mod FNSI-ord_no入力変更 楊 start
        // this.setOrdNo(null);
        this.setOrdNo("");
        // mod FNSI-ord_no入力変更 楊 end
      }
      this.setDiaysisProgramDate(selectedOrdMain);
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
    },
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end
  },

  async created() {
    this.setLoadingScreenVisible(true);
    const RegExamDateParamJson = {
      // 施設コード
      facility_cd: this.getFacilityCd,
      // 患者ID
      pat_id: String(this.selectedPatId),
      // 治療開始日(3ヶ月間前から当日まで)
      ind_start_date: dayjs()
        .subtract(3, "months")
        .format("YYYYMMDD"),
      // 治療終了日
      ind_end_date: dayjs().format("YYYYMMDD"),
      // 曜日パターン
      week_pattern: "[{'text': '全','done': false,'value': 0}]",
      // 登録時検査区分(透析前・後)
      reg_order_class: ["1", "2"]
    };

    const paramJson = {
      // 施設コード
      facility_cd: this.getFacilityCd,
      // 患者ID
      pat_id: String(this.selectedPatId),
      // 治療開始日
      ind_start_date: dayjs()
        .subtract(3, "months")
        .format("YYYYMMDD"),
      // 治療終了日
      ind_end_date: dayjs().format("YYYYMMDD"),
      // 曜日パターン
      week_pattern: "[{'text': '全','done': false,'value': 0}]"
    };

    const [responseDialyzer] = await Promise.all([
      dialyzer(this.getFacilityCd)
    ]).catch(error => {
      //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
      getErrorMessage('DiaysisProgramEditor.vue', 'created', error);
      //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
      // console.log(error);
    });
    this.mstDialyzer = responseDialyzer;

    if (this.isDataSourceTypeOrd) {
      const [
        responseRegExamDateList,
        responseTreatDateList
      ] = await Promise.all([
        ApiHelper.post(
          `/mainData/getOrdMainRegExamDateList`,
          RegExamDateParamJson),
        ApiHelper.post(`/mainData/TreatDateList`, paramJson)
      ]).catch(error => {
      //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
      getErrorMessage('DiaysisProgramEditor.vue', 'created', error);
      //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        // console.log(error);
      });
      if (!this.deviceSetInfo) {
        await new Promise(resolve => {
          const unwatch = this.$watch(
            () => this.deviceSetInfo,
            val => {
              if (val) {
                unwatch();
                resolve();
              }
            },
            { immediate: true }
          );
        });
      }
      if (this.devA && !Object.prototype.hasOwnProperty.call(this.devA, "ord_no")) {
        this.devA.ord_no = {
          value: {
            // mod FNSI-ord_no入力変更 楊 start
            // initValue: null,
            // editValue: null
            initValue: "",
            editValue: ""
            // mod FNSI-ord_no入力変更 楊 end
          }
        };
      }

      // add FNSI-検査日入力不可変更 楊 start
      const deviceDate = this._deviceSetElementById("deviceDate");
      let elem2 = deviceDate?.children?.[0]?.children[1];
      // 検査日入力不可
      if (elem2) {
        elem2.disabled = false;
      }
      // add FNSI-検査日入力不可変更 楊 end

      const selectedOrdNo = this.devA?.ord_no?.value?.initValue ?? "";
      let selectedOrdMain = null;
      // 検査日設定
      this.mstRegExamDateList = responseRegExamDateList.data;
      if (this.mstRegExamDateList.length > 0) {
        this.ordMainList = this.mstRegExamDateList;
        this.regExamDateList.default = responseRegExamDateList.data.map(
          //mod FNSI-6842 劉全航 start
          // ord => ord.treatDate
          ord => ord.strExamDate
          //mod FNSI-6842 劉全航 start
        );
        selectedOrdMain = this.ordMainList.find(
          ord => ord.ordNo === selectedOrdNo);
      }
      // 治療日設定
      this.mstTreatDateList = responseTreatDateList.data;
      const treatDateList = this.mstTreatDateList.map(ord => ord.treatDate);
      this.regExamDateList.custom = treatDateList.filter(
        data => !this.regExamDateList.default.includes(data));
      this.setRegExamDateList(this.regExamDateList);
      const threeMonthsDateLsit = [];
      for (let i = 0; i < 100; i++) {
        threeMonthsDateLsit.push(
          dayjs()
            .subtract(i, "days")
            .format("YYYYMMDD"));
      }
      const deleteDateLsit = threeMonthsDateLsit.filter(
        data => !this.regExamDateList.default.includes(data));
      this.selectedRegExamDate.disabledDates = deleteDateLsit;
      this.selectedRegExamDate.disableDatesBefore = dayjs()
        .subtract(3, "months")
        .format("YYYYMMDD");
      this.selectedRegExamDate.disableDatesAfter = dayjs().format("YYYYMMDD");

      if (selectedOrdMain) {
        this.setInitRegExamDate(selectedOrdMain.treatDate);
        this.setDiaysisProgramDate(selectedOrdMain);
        // add FNSI-検査日入力不可変更 楊 start
        if (elem2) {
          elem2.style.backgroundColor = "#EBEBE4";
        }
        // add FNSI-検査日入力不可変更 楊 end
      }
    }
    // add start #9444
    this.setLoadingScreenVisible(false);
    // add end #9444

    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
    this._deviceSetDialogOwner().isDialogType9 = true;
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end
  },

  methods: {
    ...mapActions('loading-screen', [
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
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    setInputNumberChange() {
      EventBus.$emit("deviceSetChanged");
    },
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end

    /**
     * @description 体液量＋補正
     * @summary 計算式※現行システムFNW
     * @param {} BW： 透析後体重(kg)
     * @param {} TX： 透析時間(min)
     * @param {} BUN1： 透析前 BUN(mg/dL)
     * @param {} BUN2： 透析後 BUN(mg/dL)
     * @param {} DBWX： 除水の総量(L)
     * @param {} QB： 血液量(ml/min)
     * @param {} QD： 透析液流量(ml/min)
     * @param {} KOA0： KoA(ml/min)
     * @param {} RR： 再循環率(%)※固定値
     */
    setBodyVolume(BW, TX, BUN1, BUN2, DBWX, QB, QD, KOA0, RR) {
      this.calValue = 0;

      let calRound = 0;

      const R = BUN2 / BUN1;
      const KOA = (-1.1985 + 0.81572 * 0.4343 * Math.log(QD)) * KOA0;
      RR = RR / 100;
      const KTVU =
        -Math.log(R - (0.008 * TX) / 60) + ((4 - 3.5 * R) * DBWX) / BW;
      const K1 = KTVU / TX;
      let VW = BW * 400;

      for (;;) {
        // 無限ループ防止のため最大計算回数で制限
        const MAX_CALC_ROUND = 100000;
        if (MAX_CALC_ROUND < ++calRound) {
          // 失敗
          return false;
        }

        const DBW = DBWX / VW;
        const P1 =
          0.8306 * Math.pow(10, 10) * Math.pow(DBW, 2) -
          0.1118 * Math.pow(10, 7) * DBW -
          0.0834 * Math.pow(10, 4);
        const P2 =
          -2.2858 * Math.pow(10, 8) * Math.pow(DBW, 2) +
          1.09 * Math.pow(10, 5) * DBW +
          0.2607 * Math.pow(10, 2);
        const P3 =
          0.96 * Math.pow(10, 6) * Math.pow(DBW, 2) -
          1.2556 * Math.pow(10, 3) * DBW -
          0.1732;
        const P4 =
          0.1248 * Math.pow(10, 4) * Math.pow(DBW, 2) -
          0.0728 * 10 * DBW -
          0.0076 * Math.pow(10, -2);
        const K2 =
          K1 + P1 * Math.pow(K1, 3) + P2 * Math.pow(K1, 2) + P3 * K1 + P4;
        const K21 = K2 * VW;
        const K22 = ((1 - RR) * K21) / (1 - RR - (RR * K21) / QB);
        const AA = 1 - Math.exp(KOA * (1 / QB - 1 / QD));
        const BB = 1 / QD - (1 / QB) * Math.exp(KOA * (1 / QB - 1 / QD));
        const K = AA / BB;
        const D = K22 - K;

        if (D >= 0) {
          this.calValue = VW;
          return true;
        }

        VW = VW + 20;
        continue;
      }
    },

    /**
     * @description Kt/V上限
     * @summary 計算式※現行システムFNW
     * @param {} QD： 可能なKtV上限値
     * @param {} TX： 透析時間(min)
     * @param {} QB： 血液量(ml/min)
     * @param {} RR： 再循環率(%)※固定値
     * @param {} KOA0： KoA(ml/min)
     * @param {} VWa： 体液量 補正値(ml)
     * @param {} BWa： 透析後体重(kg)
     * @param {} BW2： 目標透析終了時体重(kg)
     * @param {} DBWX： 除水量(kg)
     */
    setMaxCalKtv(QD, TX, QB, RR, KOA0, VWa, BWa, BW2, DBWX) {
      this.maxCalKtv = 0;

      let calRound = 0;

      let DD = 0;
      let N = 0;

      RR = RR / 100;

      const VWX = VWa + (BW2 - BWa) * 1000;
      const DBW = DBWX / VWX;

      if (QB === QD) {
        QD = QB + 10;
      }

      const KOA = (-1.1985 + 0.81572 * 0.4343 * Math.log(QD)) * KOA0;
      const AA = 1 - Math.exp(KOA * (1 / QB - 1 / QD));
      const BB = 1 / QD - (1 / QB) * Math.exp(KOA * (1 / QB - 1 / QD));
      const K22 = AA / BB;
      const K21 = (K22 * (1 - RR - (RR * K22) / QB)) / (1 - RR);
      const K2 = K21 / VWX;
      let KTVX = 1.5;

      for (;;) {
        // goto360:
        // 無限ループ防止のため最大計算回数で制限
        const MAX_CALC_ROUND = 100000;
        if (MAX_CALC_ROUND < ++calRound) {
          // 失敗
          return false;
        }

        const K1X = KTVX / TX;
        const P1 =
          0.8306 * Math.pow(10, 10) * Math.pow(DBW, 2) -
          0.1118 * Math.pow(10, 7) * DBW -
          0.0834 * Math.pow(10, 4);
        const P2 =
          -2.2858 * Math.pow(10, 8) * Math.pow(DBW, 2) +
          1.09 * Math.pow(10, 5) * DBW +
          0.2607 * Math.pow(10, 2);
        const P3 =
          0.96 * Math.pow(10, 6) * Math.pow(DBW, 2) -
          1.2556 * Math.pow(10, 3) * DBW -
          0.1732;
        const P4 =
          0.1248 * Math.pow(10, 4) * Math.pow(DBW, 2) -
          0.0728 * 10 * DBW -
          0.0076 * Math.pow(10, -2);
        const K2X =
          K1X + P1 * Math.pow(K1X, 3) + P2 * Math.pow(K1X, 2) + P3 * K1X + P4;

        if (N !== 99999) {
          DD = K2 - K2X;
          N = 99999;
        }

        const D = K2 - K2X;
        if (DD > 0) {
          if (D < 0) {
            this.maxCalKtv = KTVX - 0.01;
            return true;
          }

          KTVX = KTVX + 0.01;
          continue;
        } else if (DD < 0) {
          if (D > 0) {
            this.maxCalKtv = KTVX - 0.01;
            return true;
          }

          KTVX = KTVX - 0.01;
          continue;
        } else if (DD === 0) {
          this.maxCalKtv = KTVX - 0.01;
          return true;
        }

        if (D < 0) {
          this.maxCalKtv = KTVX - 0.01;
          return true;
        }

        KTVX = KTVX + 0.01;
        continue;
      }
    },

    /**
     * @description Kt/V下限
     * @summary 計算式※現行システムFNW
     * @param {} QD： 可能なKtV下限値
     * @param {} TX： 透析時間(min)
     * @param {} QB： 血液量(ml/min)
     * @param {} RR： 再循環率(%)※固定値
     * @param {} KOA0： KoA(ml/min)
     * @param {} VWa： 体液量 補正値(ml)
     * @param {} BWa： 透析後体重(kg)
     * @param {} BW2： 目標透析終了時体重(kg)
     * @param {} DBWX： 除水量(kg)
     */
    setMinCalKtv(QD, TX, QB, RR, KOA0, VWa, BWa, BW2, DBWX) {
      this.minCalKtv = 0;

      let calRound = 0;
      let DD = 0;
      let N = 0;

      RR = RR / 100;

      const VWX = VWa + (BW2 - BWa) * 1000;
      const DBW = DBWX / VWX;
      if (QB === QD) {
        QD = QB + 10;
      }

      const KOA = (-1.1985 + 0.81572 * 0.4343 * Math.log(QD)) * KOA0;
      const AA = 1 - Math.exp(KOA * (1 / QB - 1 / QD));
      const BB = 1 / QD - (1 / QB) * Math.exp(KOA * (1 / QB - 1 / QD));
      const K22 = AA / BB;
      const K21 = (K22 * (1 - RR - (RR * K22) / QB)) / (1 - RR);
      const K2 = K21 / VWX;
      let KTVX = 1.2;

      for (;;) {
        // 無限ループ防止のため最大計算回数で制限
        const MAX_CALC_ROUND = 100000;
        if (MAX_CALC_ROUND < ++calRound) {
          // 失敗
          return false;
        }

        const K1X = KTVX / TX;
        const P1 =
          0.8306 * Math.pow(10, 10) * Math.pow(DBW, 2) -
          0.1118 * Math.pow(10, 7) * DBW -
          0.0834 * Math.pow(10, 4);
        const P2 =
          -2.2858 * Math.pow(10, 8) * Math.pow(DBW, 2) +
          1.09 * Math.pow(10, 5) * DBW +
          0.2607 * Math.pow(10, 2);
        const P3 =
          0.96 * Math.pow(10, 6) * Math.pow(DBW, 2) -
          1.2556 * Math.pow(10, 3) * DBW -
          0.1732;
        const P4 =
          0.1248 * Math.pow(10, 4) * Math.pow(DBW, 2) -
          0.0728 * 10 * DBW -
          0.0076 * Math.pow(10, -2);
        const K2X =
          K1X + P1 * Math.pow(K1X, 3) + P2 * Math.pow(K1X, 2) + P3 * K1X + P4;

        if (N !== 99999) {
          DD = K2 - K2X;
          N = 99999;
        }

        const D = K2 - K2X;
        if (DD > 0) {
          if (D < 0) {
            this.minCalKtv = KTVX + 0.01;
            return true;
          }

          KTVX = KTVX + 0.01;
          continue;
        } else if (DD < 0) {
          if (D > 0) {
            this.minCalKtv = KTVX + 0.01;
            return true;
          }

          KTVX = KTVX - 0.01;
          continue;
        } else if (DD === 0) {
          this.minCalKtv = KTVX + 0.01;
          return true;
        }

        if (D < 0) {
          this.minCalKtv = KTVX + 0.01;
          return true;
        }

        KTVX = KTVX + 0.01;
        continue;
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
      console.log("DiaysisProgramEditor.vue updateIndInfo this.startLoadingScreen();");
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
        this._deviceSetDialogOwner().updateDisable = false;
      }
    },

    setOrdMainValue(ordMain) {
      // 透析後体重設定
      // 除水の総量(L)
      if (ordMain.rstWeightInfo) {
        const rstWeightInfo = JSON.parse(ordMain.rstWeightInfo);
        const weightAfter = rstWeightInfo.weight_after;
        this.BW = weightAfter;
        this.BWa = weightAfter;
        const addTotal = rstWeightInfo.add_total;
        this.DBWX = addTotal;
      }

      // 透析時間設定
      // KoA設定
      // 血液量(ml/min)
      // 目標透析終了時体重(kg)
      if (ordMain.rstCondInfo) {
        const rstCondInfo = JSON.parse(ordMain.rstCondInfo);
        if (rstCondInfo != null && Object.prototype.hasOwnProperty.call(rstCondInfo, "1")) {
          const timeMinute = rstCondInfo["1"].value;
          this.TX = timeMinute;
          if (timeMinute !== null && timeMinute !== "") {
            const timeHour = timeMinute / 60;
            const settingHour = Math.floor(timeHour);
            const minute = settingHour * 60;
            const settingMinute = timeMinute - minute;
            const time = `${settingHour}:${settingMinute}`;
            this.dialysisDisplayTime = dayjs(time, "HH:mm").format("HH:mm");
          }
        }
        if (rstCondInfo != null && Object.prototype.hasOwnProperty.call(rstCondInfo, "3")) {
          let targetWeight = rstCondInfo["3"].value;
          // mod #9973 shiyw start
          //if (targetWeight === -1) {
          if (targetWeight == -1) {
            // mod #9973 shiyw end
            // DWと同じ場合
            targetWeight = ordMain.rstDw;
          }
          this.BW2 = targetWeight;
        }
        if (rstCondInfo != null && Object.prototype.hasOwnProperty.call(rstCondInfo, "5")) {
          const dialyzerCd = rstCondInfo["5"].value;
          const selectedDialyzer = this.mstDialyzer.find(
              // mod #9973 shiyw start
            //mst => mst.dialyzerCd === dialyzerCd
            mst => mst.dialyzerCd == dialyzerCd
              // mod #9973 shiyw end
              );
          if (selectedDialyzer) {
            this.KOA0 = selectedDialyzer.koa;
          }
        }
        if (rstCondInfo != null && Object.prototype.hasOwnProperty.call(rstCondInfo, "14")) {
          this.QB = rstCondInfo["14"].value;
        }
        if (rstCondInfo != null && Object.prototype.hasOwnProperty.call(rstCondInfo, "16")) {
          this.QD = rstCondInfo["16"].value;
        }
      }
      // add 10196 by kangjie 20240202 start del rst_device_set_info
      // 平均血液量(ml/min)
      // 平均透析液流量(ml/min)
      // if (ordMain.rstDeviceSetInfo && this.TX !== null) {
      //   const rstDeviceSetInfo = JSON.parse(ordMain.rstDeviceSetInfo);
      //   const changeoverTimeList = [];
      //   for (let i = 420; i <= 428; i++) {
      //     const time = rstDeviceSetInfo.qbqd.dev.A[i];
      //     changeoverTimeList.push(time);
      //   }
      //
      //   const QBList = [];
      //   for (let i = 400; i <= 409; i++) {
      //     const QB = rstDeviceSetInfo.qbqd.dev.A[i];
      //     QBList.push(QB);
      //   }
      //   const QDList = [];
      //   for (let i = 410; i <= 419; i++) {
      //     const QD = rstDeviceSetInfo.qbqd.dev.A[i];
      //     QDList.push(QD);
      //   }
      //   const maxStep = rstDeviceSetInfo.qbqd.dev.A["429"];
      //   this.aveQB = this.getAverageFlow(
      //     QBList,
      //     changeoverTimeList,
      //     maxStep,
      //     this.TX
      //);
      //   this.aveQD = this.getAverageFlow(
      //     QDList,
      //     changeoverTimeList,
      //     maxStep,
      //     this.TX
      //);
      // }
      // add 10196 by kangjie 20240202 end del rst_device_set_info
      /*
      TODO: 計算式テスト値※消す
      // 体液量計算時の後体重
      this.BW = 41;
      // 透析後体重(kg)
      this.BWa = 41;
      // 目標透析終了時体重(kg)
      this.BW2 = 41;
      // 透析時間(min)
      this.TX = 243;
      // 透析前 BUN(mg/dL)
      this.BUN1 = 54;
      // 透析後 BUN(mg/dL)
      this.BUN2 = 18;
      // 血液量(ml/min)
      this.QB = 170;
      // 透析液流量(ml/min)
      this.QD = 500;
      // 除水の総量(L)
      this.DBWX = 3;
      // KoA(ml/min)
      this.KOA0 = 955;
      */

      // TODO:
      // TODO:
      // TODO:
      // TODO:
      // TODO:
      // TODO: DBが存在しないため、担当者はBUN1、BUN2を取得後設定して下さい。
      // 透析前 BUN(mg/dL)
      this.BUN1 = 54;
      // 透析後 BUN(mg/dL)
      this.BUN2 = 18;
    },

    setDiaysisProgramDate(ordMain) {
      this.clearValue();
      if (ordMain) {
        this.setOrdMainValue(ordMain);
        // 体液量＋補正設定
        const isBodyVolume = this.setBodyVolume(
          // 透析後体重(kg)
          this.BW,
          // 透析時間(min)
          this.TX,
          // 透析前 BUN(mg/dL)
          this.BUN1,
          // 透析後 BUN(mg/dL)
          this.BUN2,
          // 除水の総量(L)
          this.DBWX,
          // 血液量(ml/min)
          this.QB,
          // 透析液流量(ml/min)
          this.QD,
          // KoA(ml/min)
          this.KOA0,
          // 再循環率(%)※固定値
          this.RR);
        if (!isBodyVolume) {
          this.calValue = null;
          return;
        }

        // KtV上限値設定
        const isMaxCalKtv = this.setMaxCalKtv(
          // 可能なKtV上限値※固定値
          this.maxKtv,
          // 透析時間(min)
          this.TX,
          // 血液量(ml/min)
          this.QB,
          // 再循環率(%)※固定値
          this.RR,
          // KoA(ml/min)
          this.KOA0,
          // 体液量 補正値(ml)
          this.calValue,
          // 透析後体重(kg)
          this.BWa,
          // 目標透析終了時体重(kg)
          this.BW2,
          // 除水量(kg)
          this.DBWX);
        if (!isMaxCalKtv) {
          // mod FNSI-KtV上下限値設定変更 楊 start
          // this.maxCalKtv = null;
          this.maxCalKtv = 0;
          // mod FNSI-KtV上下限値設定変更 楊 end
        } else {
          this.maxCalKtv = Math.floor(this.maxCalKtv * 100) / 100;
        }
        this.devA[288].maxValue = this.maxCalKtv;

        // KtV下限値設定
        const isMinCalKtv = this.setMinCalKtv(
          // 可能なKtV下限値※固定値
          this.minKtv,
          // 透析時間(min)
          this.TX,
          // 血液量(ml/min)
          this.QB,
          // 再循環率(%)※固定値
          this.RR,
          // KoA(ml/min)
          this.KOA0,
          // 体液量 補正値(ml)
          this.calValue,
          // 透析後体重(kg)
          this.BWa,
          // 目標透析終了時体重(kg)
          this.BW2,
          // 除水量(kg)
          this.DBWX);
        if (!isMinCalKtv) {
          // mod FNSI-KtV上下限値設定変更 楊 start
          // this.minCalKtv = null;
          this.minCalKtv = 0;
          // mod FNSI-KtV上下限値設定変更 楊 end
        } else {
          this.minCalKtv = Math.floor(this.minCalKtv * 100) / 100;
        }
        this.devA[288].minValue = this.minCalKtv;

        if (isBodyVolume) {
          // mL→ L
          this.calValue = this.calValue / 1000;
        }
      }
    },

    /**
     * @description 平均流量計算結果
     * @summary 計算式： {[流量1×切替時間1]＋[流量2×切替時間2]＋・・・[流量最終×(透析時間－切替時間合計)]} / 透析時間
     * @param {Array} values 各流量
     * @returns {Number}
     */
    getAverageFlow(flowArray, changeoverTimeList, maxStep, dialysisTime) {
      // 経過流量合計：[流量1×切替時間1]＋[流量2×切替時間2]＋・・・
      let progressFlowSum = 0;
      // 切替時間合計
      let changeoverTimeSum = 0;
      // 最終流量
      let lastFlow = null;
      // 最終ステップ数を取得
      const stepNumber = maxStep - 1;

      // 経過流量合計と最終流量と切替時間合計を設定
      for (let i = 0; i < flowArray.length; i++) {
        if (i < stepNumber) {
          // ステップ数を超えるまで流量と切替時間を設定
          const flow = flowArray[i];
          const changeoverTime = changeoverTimeList[i];

          if (changeoverTimeSum < dialysisTime) {
            // 透析時間を超えるまで経過流量合計と切替時間合計を計算
            progressFlowSum += flow * changeoverTime;
            changeoverTimeSum += changeoverTime;
            // mod #9973 shiyw start
          // } else if (changeoverTimeSum === dialysisTime) {
          } else if (changeoverTimeSum == dialysisTime) {
            // mod #9973 shiyw end
            // 切替時間合計と透析時間が同じ場合：最終流量
            lastFlow = flow;
            break;
          } else {
            // 切替時間合計が透析時間を超えた場合：1つ前が最終流量
            lastFlow = flowArray[i - 1];
            break;
          }
        } else if (i === stepNumber) {
          if (changeoverTimeSum >= dialysisTime) {
            // 切替時間合計が透析時間以上だった場合：1つ前が最終流量
            lastFlow = flowArray[i - 1];
          } else {
            // ステップ数が最終流量
            lastFlow = flowArray[i];
          }
        }
      }

      // 計算式： {経過流量合計＋[流量最終×(透析時間－切替時間合計)]} / 透析時間
      const averageFlow =
        (progressFlowSum + lastFlow * (dialysisTime - changeoverTimeSum)) /
        dialysisTime;

      return averageFlow;
    },

    clearValue() {
      this.dialysisDisplayTime = null;
      this.calValue = null;
      this.maxCalKtv = null;
      this.minCalKtv = null;
      this.BW = null;
      this.TX = null;
      this.BUN1 = null;
      this.BUN2 = null;
      this.DBWX = null;
      this.QB = null;
      this.QD = null;
      // add 10196 by kangjie 20240202 start del rst_device_set_info
      // this.aveQB = null;
      // this.aveQD = null;
      // add 10196 by kangjie 20240202 end del rst_device_set_info
      this.KOA0 = null;
      this.BWa = null;
      this.BW2 = null;
    },

    setRegExamDateList(value) {
      this.selectedRegExamDate.selectedDates = value;
    },

    setOrdNo(selectedOrdNo) {
      this.devA.ord_no.value.editValue = selectedOrdNo;
    },

    setInitRegExamDate(initDate) {
      if (this.dataSourceType === DATA_SOURCE_TYPE_ORD) {
        // 選択された日付
        this.selectedRegExamDate.value.editValue = initDate;
        this.selectedRegExamDate.value.initValue = initDate;
      }
    },
    // add FNSI-検査日入力不可変更 楊 start
    dateInput(){
      const deviceDate = this._deviceSetElementById("deviceDate");
      let elem2 = deviceDate.children[0].children[0];
      if (this.selectedRegExamDate.value.initValue === this.selectedRegExamDate.value.editValue){
        elem2.style.backgroundColor = "#EBEBE4";
      } else {
        elem2.style.backgroundColor = "yellow";
      }
    },
    // add FNSI-検査日入力不可変更 楊 end

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
        this._deviceSetDialogOwner().messageDialogInfo.messageCd = 70000028;
        /* mod FNSI-4212 更新対象変更時のウインドウが不正 liumx start */
        this._deviceSetDialogOwner().messageDialogInfo.type = "9";
        /* mod FNSI-4212 更新対象変更時のウインドウが不正 liumx end */
        this._deviceSetDialogOwner().messageDialogInfo.isDialogVisible = true;
        return;
      } else {
        return this.getComponentData(structData, 2);
      }
    },
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end

    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
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
        paramJson).catch(error => {
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
                tempData.dia.dev.A[key] = this.devA[key].value.editValue;
              }
            }
          }
          for (let key in this.devA) {
            this.devA[key].value.initValue = initData.dia.dev.A[key];
            this.devA[key].value.editValue = tempData.dia.dev.A[key];
          }
        }
      }
      this.initModelValue = JSON.parse(JSON.stringify(this.devA));
    },
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end
    changeButton(val) {
      EventBus.$emit( "mstTreatmentSetRegistered", val);
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng start
      // if(false === val) {
      //   EventBus.$emit("deviceSetChanged");
      // }
      EventBus.$emit("deviceSetChanged", !val);
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240118 linjunfeng end
    },
  },

  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  mounted() {
    setTimeout(() => {
      this.changeButton(true);
    },300)
  }
};
</script>

<style src="../base-modules/BeseDeviceSetInfoStyle.css" scoped></style>
<style scoped>
.device-info-content {
  max-height: 630px;
  max-width: 500px;
}

.device-info-cell-name {
  flex: 0 0 50%;
}

.device-info-border-right {
  border-right: solid 1px var(--ntss-border-color);
}

.device-info-cell-name,
.device-info-cell-value {
  text-align: left;
}

.input-text,
.input-time ,
/* add #11120 I-HDF設定内の破棄確認メッセージ不正 2024/09/12 情 start */
.diaysis-program-input-number-pro :deep(.custom-common-number-input-pro)
/* add #11120 I-HDF設定内の破棄確認メッセージ不正 2024/09/12 情 end */
{
  width: 70px;
}

.custom-input-date::-webkit-calendar-picker-indicator {
  display: none;
}

@media screen and (max-width: 600px) {
  .input-date {
    width: 110px;
  }
  .device-info-cell-name {
    flex: 0 0 45%;
  }
  .device-info-cell-value :deep(.custom-radio) {
    display: block;
  }
}
</style>
