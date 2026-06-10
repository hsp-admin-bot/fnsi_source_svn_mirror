<template>
  <div v-if="deviceSetInfo !== null" class="device-info-container">
    <div class="device-info-content">
      <div class="device-info-content-area">
        <!-- ヘッダ -->
        <v-ons-row
          v-if="showButton"
          class="common-style-header device-info-main-title"
        >
          Ｄ‐Ｆａｓ
        </v-ons-row>
        <div class="device-info-main-content">
          <!-- タイトル -->
          <!-- mod FNSI修正 装置設定バッグ改修 房 start -->
          <v-ons-row class="common-style-header device-info-cell-title" v-if="patB[1] != undefined">
            <!-- mod FNSI修正 装置設定バッグ改修 房 end -->
            使用選択
          </v-ons-row>
          <!-- 項目 -->
          <!-- mod FNSI修正 装置設定バッグ改修 房 start -->
          <v-ons-row class="device-info-cell" v-if="patB[1] != undefined">
            <!-- mod FNSI修正 装置設定バッグ改修 房 end -->
            <v-ons-col class="device-info-cell-name">
              {{ patB[1].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-radio -->
              <!--   ref="radio1" -->
              <!--   :device-info="patB[1]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @change="setDeviceInfoChange('IPプライミング')" -->
              <!-- /> -->
              <device-radio
                ref="radio1"
                :device-info="patB[1]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @change="setDeviceInfoChange('IPプライミング')"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>

          <!-- タイトル -->
          <!-- mod FNSI修正 装置設定バッグ改修 房 start -->
          <v-ons-row class="common-style-header device-info-cell-title" v-if="hasValue(hollowFiberTypePrimingList) > 0">
            <!-- mod FNSI修正 装置設定バッグ改修 房 end -->
            プライミング(中空糸型)
          </v-ons-row>
          <v-ons-row
            v-for="(device, index) in hollowFiberTypePrimingList"
            :key="`プライミング(中空糸型)${index}`"
            class="device-info-cell"
          >
            <!-- mod FNSI修正 装置設定バッグ改修 房 start -->
            <v-ons-col class="device-info-cell-name" v-if="device != undefined">
              <!-- mod FNSI修正 装置設定バッグ改修 房 end -->
              {{ device.formLabel }}
            </v-ons-col>
            <!-- mod FNSI修正 装置設定バッグ改修 房 start -->
            <v-ons-col class="device-info-cell-value" v-if="device != undefined">
              <!-- mod FNSI修正 装置設定バッグ改修 房 end -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   :ref="`required1_${index}`" -->
              <!--   :device-info="device" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange(`動脈充填`)" -->
              <!-- /> -->
              <device-input-number
                :ref="`required1_${index}`"
                :device-info="device"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange(`動脈充填`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>

          <!-- タイトル -->
          <!-- mod FNSI修正 装置設定バッグ改修 房 start -->
          <v-ons-row class="common-style-header device-info-cell-title" v-if="hasValue(hierarchicalTypePrimingList) > 0">
            <!-- mod FNSI修正 装置設定バッグ改修 房 end -->
            プライミング(積層型)
          </v-ons-row>
          <!-- 項目 -->
          <v-ons-row
            v-for="(device, index) in hierarchicalTypePrimingList"
            :key="`プライミング(積層型)${index}`"
            class="device-info-cell"
          >
            <!-- mod FNSI修正 装置設定バッグ改修 房 start -->
            <v-ons-col class="device-info-cell-name" v-if="device != undefined">
              <!-- mod FNSI修正 装置設定バッグ改修 房 end -->
              {{ device.formLabel }}
            </v-ons-col>
            <!-- mod FNSI修正 装置設定バッグ改修 房 start -->
            <v-ons-col class="device-info-cell-value" v-if="device != undefined">
              <!-- mod FNSI修正 装置設定バッグ改修 房 end -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   :ref="`required2_${index}`" -->
              <!--   :device-info="device" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange(`動脈充填`)" -->
              <!-- /> -->
              <device-input-number
                :ref="`required2_${index}`"
                :device-info="device"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange(`動脈充填`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>

          <!-- タイトル -->
          <v-ons-row class="common-style-header device-info-cell-title">
            脱血
          </v-ons-row>
          <!-- 項目 -->
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[339].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-select -->
              <!--   ref="select1" -->
              <!--   :device-info="devA[339]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @change="setDeviceInfoChange(`${ devA[339].formLabel }`)" -->
              <!-- /> -->
              <device-select
                ref="select1"
                :device-info="devA[339]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @change="setDeviceInfoChange(`${ devA[339].formLabel }`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>
          <v-ons-row
            v-for="(device, index) in bloodRemovalList"
            :key="`脱血${index}`"
            class="device-info-cell"
          >
            <v-ons-col class="device-info-cell-name">
              {{ device.formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   :ref="`required3_${index}`" -->
              <!--   :device-info="device" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange(`動脈充填`)" -->
              <!-- /> -->
              <device-input-number
                :ref="`required3_${index}`"
                :device-info="device"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange(`動脈充填`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>

          <!-- タイトル -->
          <v-ons-row class="common-style-header device-info-cell-title">
            治療
          </v-ons-row>
          <!-- 項目 -->
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devB[36].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-radio -->
              <!--   ref="radio2" -->
              <!--   :device-info="devB[36]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @change="setDeviceInfoChange(`${ devB[36].formLabel }`)" -->
              <!-- /> -->
              <device-radio
                ref="radio2"
                :device-info="devB[36]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @change="setDeviceInfoChange(`${ devB[36].formLabel }`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>

          <!-- タイトル -->
          <v-ons-row class="common-style-header device-info-cell-title">
            返血
          </v-ons-row>
          <!-- 項目 -->
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[373].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   ref="required_number1" -->
              <!--   :device-info="devA[373]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange(`動脈充填`)" -->
              <!-- /> -->
              <device-input-number
                ref="required_number1"
                :device-info="devA[373]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange(`動脈充填`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[374].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   ref="required_number2" -->
              <!--   :device-info="devA[374]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange(`動脈充填`)" -->
              <!-- /> -->
              <device-input-number
                ref="required_number2"
                :device-info="devA[374]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange(`動脈充填`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[377].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-radio -->
              <!--   ref="radio3" -->
              <!--   :device-info="devA[377]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @change="setDeviceInfoChange(`${ devA[377].formLabel }`)" -->
              <!-- /> -->
              <device-radio
                ref="radio3"
                :device-info="devA[377]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @change="setDeviceInfoChange(`${ devA[377].formLabel }`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[270].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-radio -->
              <!--   ref="radio4" -->
              <!--   :device-info="devA[270]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @change="setDeviceInfoChange(`${ devA[270].formLabel }`)" -->
              <!-- /> -->
              <device-radio
                ref="radio4"
                :device-info="devA[270]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @change="setDeviceInfoChange(`${ devA[270].formLabel }`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[376].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   ref="required_number3" -->
              <!--   :device-info="devA[376]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange(`動脈充填`)" -->
              <!-- /> -->
              <device-input-number
                ref="required_number3"
                :device-info="devA[376]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange(`動脈充填`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[378].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-radio -->
              <!--   ref="radio5" -->
              <!--   :device-info="devA[378]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @change="setDeviceInfoChange(`${ devA[378].formLabel }`)" -->
              <!-- /> -->
              <device-radio
                ref="radio5"
                :device-info="devA[378]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @change="setDeviceInfoChange(`${ devA[378].formLabel }`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
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
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { DEVICE_TYPE_DFAS } from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
import baseEditor from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoEditor.vue";
import {getDeviceSetInfoMst} from "@/components/deviceset-info/base-modules/DeviceSetInfoFunctions";
import {mapGetters} from "vuex";
// add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
import { EventBus } from "@/eventBus.js";
// add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end

/**
 * @description D-Fas設定値編集画面
 */
export default {
  mixins: [baseEditor],

  data() {
    return {
      deviceType: DEVICE_TYPE_DFAS,
      deviceSetInfoMst: [],
    };
  },

  computed: {
    ...mapGetters("master-maintenance", {getFacilitySwitch: "getFacilitySwitch"}),
    ...mapGetters("pat-info", ["getIsOtherFacility", "getOtherFacilityCd"]),
    /**
     * @description BV編集値
     * @returns {Array} 入力項目テキストボックスタイプNumber
     */
    hollowFiberTypePrimingList() {
      return [
        this.patB[5],
        this.patB[7],
        this.patB[8],
        this.patB[9],
        this.patB[10]
      ];
    },

    /**
     * @description BV編集値
     * @returns {Array} 入力項目テキストボックスタイプNumber
     */
    hierarchicalTypePrimingList() {
      return [
        this.patB[59],
        this.patB[54],
        this.patB[55],
        this.patB[56],
        this.patB[57],
        this.patB[58]
      ];
    },

    /**
     * @description BV編集値
     * @returns {Array} 入力項目テキストボックスタイプNumber
     */
    bloodRemovalList() {
      return [
        this.devA[333],
        this.devA[331],
        this.devA[334],
        this.devA[338],
        this.devA[332]
      ];
    }
  },
  //add FNSI修正 装置設定バッグ改修 房 start
  methods: {
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    setDeviceInfoChange(itemName) {
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定 20231227 ztc start
      // EventBus.$emit("deviceSetChanged");
      EventBus.$emit("deviceSetChanged", this.isEdited());
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定 20231227 ztc end
    },
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end

    hasValue(list){
      let flag = false;
      if (list != undefined && list != null && list.length > 0) {
        list.forEach(element => {
          if (element != undefined) {
            flag = true;
          }
        })
      }
      return flag;
    },
    bloodFlowLimit(dev, ind) {
      if (ind === 0) {
        if (dev.maxValue !== undefined) {
          dev.maxValue = this.deviceSetInfoMst.pat.ope.dev.A[179];
        }
      }
    }
  },
  //add FNSI修正 装置設定バッグ改修 房 end
  async created() {
    this.deviceSetInfoMst = await getDeviceSetInfoMst(
      this.getFacilitySwitch
    )
  },
  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
};
</script>

<style src="../base-modules/BeseDeviceSetInfoStyle.css" scoped></style>
<style scoped>
.device-info-content {
  max-height: 630px;
}

@media screen and (max-width: 410px) {
  .device-info-cell-name {
    flex: 0 0 35%;
  }
  .device-info-cell-value >>> .custom-radio {
    display: block;
  }
}
</style>
