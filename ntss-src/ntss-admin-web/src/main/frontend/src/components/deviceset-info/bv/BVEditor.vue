<template>
  <div v-if="deviceSetInfo !== null" class="device-info-container">
    <div class="device-info-content">
      <div class="device-info-content-area">
        <!-- ヘッダ -->
        <v-ons-row
          v-if="showButton"
          class="common-style-header device-info-main-title"
        >
          ＢＶ計
        </v-ons-row>
        <div class="device-info-main-content">
          <!-- タイトル -->
          <v-ons-row class="common-style-header device-info-cell-title">
            ＢＶ
          </v-ons-row>
          <!-- 項目 -->
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ bvUse.formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-radio -->
              <!--   ref="radio1" -->
              <!--   :device-info="bvUse" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @change="setDeviceInfoChange(`${bvUse.formLabel}`)" -->
              <!-- /> -->
              <device-radio
                ref="radio1"
                :device-info="bvUse"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @change="setDeviceInfoChange(`${bvUse.formLabel}`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>
          <v-ons-row
            v-for="(devInfo, index) in deltaBVList"
            :key="`deltaBV_${index}`"
            class="device-info-cell"
          >
            <v-ons-col class="device-info-cell-name">
              {{ devInfo.formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   :ref="`required_deltaBV${index}`" -->
              <!--   :device-info="devInfo" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange('最高血圧上限')" -->
              <!-- /> -->
              <device-input-number
                :ref="`required_deltaBV${index}`"
                :device-info="devInfo"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange('最高血圧上限')"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="common-style-header device-info-cell-title">
            アクセス再循環率測定
          </v-ons-row>
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ accessUse.formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-radio -->
              <!--   ref="radio2" -->
              <!--   :device-info="accessUse" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @change="setDeviceInfoChange(`${accessUse.formLabel}`)" -->
              <!-- /> -->
              <device-radio
                ref="radio2"
                :device-info="accessUse"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @change="setDeviceInfoChange(`${accessUse.formLabel}`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>

          <v-ons-row
            v-for="(devInfo, index) in autoMeasurementList"
            :key="`autoMeasurement_${index}`"
            class="device-info-cell"
          >
            <v-ons-col class="device-info-cell-name">
              {{ devInfo.formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-time -->
              <!--   :ref="`required_autoMeasurement${index}`" -->
              <!--   :device-info="devInfo" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   default-time="00:00" -->
              <!--   @change="setDeviceInfoChange(`${devInfo.formLabel}`)" -->
              <!--   isRequired -->
              <!-- /> -->
              <device-input-time
                :ref="`required_autoMeasurement${index}`"
                :device-info="devInfo"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                default-time="00:00"
                @change="setDeviceInfoChange(`${devInfo.formLabel}`)"
                isRequired
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ recylcleReport.formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod FNSI-改修内容 横展開対応 趙 start -->
              <!-- <device-input-number
                ref="ref1"
                :device-info="recylcleReport"
                :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)"
              /> -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   ref="required_ref1" -->
              <!--   :device-info="recylcleReport" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange('最高血圧上限')" -->
              <!-- /> -->
              <device-input-number
                ref="required_ref1"
                :device-info="recylcleReport"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange('最高血圧上限')"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- mod FNSI-改修内容 横展開対応 趙 end -->
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
            <!--   @click="saveConfirm()" -->
            <!-- > -->
            <v-ons-button
              v-if="!isTreatRecord"
              class="common-style-ok-button"
              @click="saveConfirm()"
              :disabled="!getItemAuthorized('DevicesetInfo', 'default_authority')"
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
      />
      <message-dialog
        :visible.sync="isCancelDialogVisble"
        v-bind="dialogProps"
        type="2"
        @confirm="cancelEdit"
      />
      <message-dialog
        :visible.sync="isUpdateAllPatDialogVisble"
        v-bind="dialogProps"
        type="5"
        @confirm="setUpdateAllPatFlg"
      />
    </div>
  </div>
</template>

<script>
// #11124 2025.08.26 add 酸素飽和度対応 TDC高村 start
import { getMachineSo2OptCount } from "@/apis/mst-machine-maintenance";
// #11124 2025.08.26 add 酸素飽和度対応 TDC高村 end
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { DEVICE_TYPE_BV } from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
import baseEditor from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoEditor.vue";
// add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
import { EventBus } from "@/eventBus.js";
// add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
import { mapGetters } from "vuex";

/**
 * @description BV設定値編集画面
 */
export default {
  mixins: [baseEditor],

  // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 start
  data() {
    return {
      deviceType: DEVICE_TYPE_BV,
      so2Count: 0
    };
  },
  async mounted() {
    // apiをコールしてΔSO2を使用する装置件数を取得
    await getMachineSo2OptCount(this.facilityCd).then(
      (response) => {
        this.so2Count = response.data;
      }
    );
  },
  // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 end

  computed: {
    ...mapGetters("pat-info", ["getIsOtherFacility", "getOtherFacilityCd"]),
    /**
     * @description 警報点1
     */
    deltaLowWarning1() {
      return this.devA[260];
    },

    /**
     * @description 警報点2
     */
    deltaLowWarning2() {
      return this.devA[261];
    },

    /**
     * @description BV使用
     */
    bvUse() {
      return this.devA[267];
    },

    /**
     * @description アクセス使用
     */
    accessUse() {
      return this.devA[258];
    },

    /**
     * @description 再循環率報知
     */
    recylcleReport() {
      return this.devA[281];
    },

    /**
     * @description △BVのリスト
     */
    deltaBVList() {
      // #11124 2025.08.26 mod 酸素飽和度対応 TDC高村 start
      /*
      return [
        this.deltaLowWarning1,
        this.deltaLowWarning2,
        this.devA[262],
        this.devA[277],
        this.devA[278]
      ];
      */
      const bvList = [
        this.deltaLowWarning1,
        this.deltaLowWarning2,
        this.devA[262],
        this.devA[277],
        this.devA[278]
      ];

      if ( this.so2Count != 0 ) {
        bvList.push(this.devA[476]);
      }
      return bvList;
      // #11124 2025.08.26 mod 酸素飽和度対応 TDC高村 end
    },

    /**
     * @description 自動測定のリスト
     */
    autoMeasurementList() {
      return [
        this.devA[259],
        this.devA[263],
        this.devA[264],
        this.devA[265],
        this.devA[266]
      ];
    }
  },

  methods: {
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    setDeviceInfoChange(itemName) {
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定 20231227 ztc start
      // EventBus.$emit("deviceSetChanged");
      EventBus.$emit("deviceSetChanged", this.isEdited());
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定 20231227 ztc end
    },
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end

    /**
     * @description 保存前のバリデーション処理
     * @returns {Object}
     *   成功時: null
     *   失敗時: メッセージダイアログ用オブジェクト { messageCd, stringParams }
     */
    validateBeforeUpdating() {
      const messageCd = 50000002;

      // 警報点1 ≧ 警報点2 ？
      if (
        this.deltaLowWarning1.value.editValue <
        this.deltaLowWarning2.value.editValue
      ) {
        return {
          messageCd,
          stringParams: [
            this.deltaLowWarning1.formName,
            this.deltaLowWarning2.formName
          ]
        };
      }

      /////////////////////////////
      // 自動測定n < 自動測定n+1 ？
      /////////////////////////////
      // 比較基準値の要素番号
      let comparisonBaseIndex = -1;
      for (let i = 0; i < 5; i++) {
        if (this.autoMeasurementList[i].value.editValue === 0) {
          // 00:00(0分)は比較対象外
          continue;
        }

        if (comparisonBaseIndex === -1) {
          // 比較基準値の要素番号が未設定の場合は設定して次の要素へ
          comparisonBaseIndex = i;
          continue;
        }

        if (
          this.autoMeasurementList[comparisonBaseIndex].value.editValue <
          this.autoMeasurementList[i].value.editValue
        ) {
          // 上下関係が正しい場合は基準を再設定して次の要素へ
          comparisonBaseIndex = i;
        } else {
          return {
            messageCd,
            stringParams: [
              this.autoMeasurementList[i].formName,
              this.autoMeasurementList[comparisonBaseIndex].formName
            ]
          };
        }
      }

      return null;
    }
  }
};
</script>

<style src="../base-modules/BeseDeviceSetInfoStyle.css" scoped></style>
<style scoped>
.device-info-content {
  max-height: 550px;
}

@media screen and (max-width: 530px) {
  .device-info-cell-value >>> .custom-radio {
    display: block;
  }
}
</style>
