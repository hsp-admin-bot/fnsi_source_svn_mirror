<template>
  <div v-if="deviceSetInfo !== null" class="device-info-container">
    <div class="device-info-content">
      <div class="device-info-content-area">
        <!-- ヘッダ -->
        <v-ons-row
          v-if="showButton"
          class="common-style-header device-info-main-title"
        >
          ECUM設定
        </v-ons-row>
        <div class="device-info-main-content">
          <!-- 項目 -->
          <v-ons-row class="device-info-cell top-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[16].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-radio -->
              <!--   ref="radio1" -->
              <!--   :device-info="devA[16]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @change="setEcumChange('ECUM選択')" -->
              <!-- /> -->
              <device-radio
                ref="radio1"
                :device-info="devA[16]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @change="setEcumChange('ECUM選択')"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[17].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #5589 2023/04/04 数値IFのスタイル全不正 張博 start -->
              <!-- <device-input-number
                :ref="`required1`"
                :device-info="devA[17]"
                :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)"
                @blur="setEcumChange('ECUM量')"
                @change="setEcumChange('ECUM量')"
              /> -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   :ref="`required1`" -->
              <!--   :device-info="devA[17]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @blur="setEcumChange('ECUM量')" -->
              <!--   @wheel.prevent="setEcumChange('ECUM量')" -->
              <!--   @change="setEcumChange('ECUM量')" -->
              <!-- /> -->
              <device-input-number
                :ref="`required1`"
                :device-info="devA[17]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @blur="setEcumChange('ECUM量')"
                @wheel.prevent="setEcumChange('ECUM量')"
                @change="setEcumChange('ECUM量')"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- mod #5589 2023/04/04 数値IFのスタイル全不正 張博 end-->
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[18].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-time -->
              <!--   :ref="`required2`" -->
              <!--   :device-info="devA[18]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   default-time="00:30" -->
              <!--   @change="setEcumChange('ECUM時間')" -->
              <!--   isRequired -->
              <!-- /> -->
              <device-input-time
                :ref="`required2`"
                :device-info="devA[18]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                default-time="00:30"
                @change="setEcumChange('ECUM時間')"
                isRequired
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[19].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-radio -->
              <!--   ref="radio2" -->
              <!--   :device-info="devA[19]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @change="setEcumChange('ECUM時間カウント選択')" -->
              <!-- /> -->
              <device-radio
                ref="radio2"
                :device-info="devA[19]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @change="setEcumChange('ECUM時間カウント選択')"
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
              :disabled="!getItemAuthorized('DevicesetInfo', 'default_authority') || getIsOtherFacility"
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
      />
      <message-dialog
        v-model:visible="isCancelDialogVisble"
        v-bind="dialogProps"
        type="2"
        @confirm="cancelEdit"
      />
      <message-dialog
        v-model:visible="isUpdateAllPatDialogVisble"
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
import { DEVICE_TYPE_ECUM } from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
import baseEditor from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoEditor.vue";
// add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
import { EventBus } from "@/compat/vue/event-bus.js";
// add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end

/**
 * @description ECUM専用設定設定値編集画面
 */
export default {
  mixins: [baseEditor],

  data() {
    return {
      deviceType: DEVICE_TYPE_ECUM
    };
  },

  // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
  methods: {
    setEcumChange(name) {
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定 20231227 ztc start
      // EventBus.$emit("deviceSetChanged");
      EventBus.$emit("deviceSetChanged", this.isEdited());
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定 20231227 ztc end
    },
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return !this.getIsOtherFacility && getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
  },
  // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
};


</script>

<style src="../base-modules/BeseDeviceSetInfoStyle.css" scoped></style>
<style scoped>
.device-info-content {
  max-height: 200px;
}

.top-cell {
  border-top: solid 1px var(--ntss-border-color);
}

@media screen and (max-width: 590px) {
  .device-info-cell-value :deep(.custom-radio) {
    display: block;
  }
}
 
/* add FNSI redmine 6412修正 関 start */
.device-input-time :deep(.custom-input-time) {
    min-width: 76px;
    width: auto;
    max-width: 90px;
}
/* add FNSI redmine 6412修正 関　end */
.device-info-cell-value :deep(.custom-common-number-input-pro) {
  width: 6em;
}
</style>
