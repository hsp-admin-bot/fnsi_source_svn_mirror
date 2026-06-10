<template>
  <div v-if="deviceSetInfo !== null" class="device-info-container">
    <div class="device-info-content">
      <div class="device-info-content-area">
        <!-- ヘッダ -->
        <v-ons-row
          v-if="showButton"
          class="common-style-header device-info-main-title"
        >
          静的静脈圧
        </v-ons-row>
        <div class="device-info-main-content">
          <!-- タイトル -->
          <v-ons-row class="common-style-header device-info-cell-title">
            静的静脈圧
          </v-ons-row>
          <!-- VA確認報知基準値(静的静脈圧) -->
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[468].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   ref="required468" -->
              <!--   :device-info="devA[468]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange(`動脈充填`)" -->
              <!-- /> -->
              <device-input-number
                ref="required468"
                :device-info="devA[468]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange(`動脈充填`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>

          <!-- VA確認報知基準値(アクセス内圧力比率) -->
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[469].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-input-number -->
              <!--   ref="required469" -->
              <!--   :device-info="devA[469]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @input="setDeviceInfoChange(`血流量`)" -->
              <!--   @wheel.prevent="setDeviceInfoChange(`血流量`)" -->
              <!--   @change="setDeviceInfoChange(`静的静脈圧`)" -->
              <!-- /> -->
              <device-input-number
                ref="required469"
                :device-info="devA[469]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @input="setDeviceInfoChange(`血流量`)"
                @wheel.prevent="setDeviceInfoChange(`血流量`)"
                @change="setDeviceInfoChange(`静的静脈圧`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>

          <!-- 静的静脈圧記録 自動実施選択 -->
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[470].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <device-radio -->
              <!--   ref="radio470" -->
              <!--   :device-info="devA[470]" -->
              <!--   :disabled="isTreatRecord || (isPatRecord && !ishasDevicesetInfoAuthority)" -->
              <!--   @change="setDeviceInfoChange(`静的静脈圧`)" -->
              <!-- /> -->
              <device-radio
                ref="radio470"
                :device-info="devA[470]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @change="setDeviceInfoChange(`静的静脈圧`)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>

          <!-- 血圧測定 自動実施選択 -->
          <v-ons-row class="device-info-cell">
            <v-ons-col class="device-info-cell-name">
              {{ devA[471].formLabel }}
            </v-ons-col>
            <v-ons-col class="device-info-cell-value">
              <device-radio
                ref="radio471"
                :device-info="devA[471]"
                :disabled="isTreatRecord || (isPatRecord && !getItemAuthorized('DevicesetInfo', 'default_authority')) || getIsOtherFacility"
                @change="setDeviceInfoChange(`静的静脈圧`)"
              />
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
import { DEVICE_TYPE_IAP } from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
import baseEditor from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoEditor.vue";
// add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
import { EventBus } from "@/eventBus.js";
// add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
import { mapGetters } from "vuex";

/**
 * @description 静的静脈圧編集画面
 */
export default {
  mixins: [baseEditor],

  data() {
    return {
      deviceType: DEVICE_TYPE_IAP
    };
  },

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

    /**
     * @description 編集有無確認
     * @returns {Boolean}
     *   成功: モーダル表示
     *   失敗: モーダル非表示
     */
    /*
    checkEdit(num) {
      if (num === 1) {
        // キャンセルボタンクリック時チェック
        this.cancelConfirm();
        // cancelConfirm関数(子)でモーダルの表示非表示を行うため、ベース(親)では何も処理しない
        return true;
      }
    }*/
  },
  computed: {
    ...mapGetters("pat-info", ["getIsOtherFacility", "getOtherFacilityCd"]),
  },
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
