<template>
  <base-tare-offwater
    v-if="selectedDeviceSetType === 'tare'"
    header-title="風袋"
    :show-button="false"
    :resolve-editor-component="resolveActiveTareOffwaterEditor"
    @hide-modal="hideModal()"
  >
    <tare ref="tareEditor" v-bind="tareOffwaterProps" />
  </base-tare-offwater>
  <base-tare-offwater
    v-else-if="selectedDeviceSetType === 'offwater'"
    header-title="除水補正"
    :show-button="false"
    :resolve-editor-component="resolveActiveTareOffwaterEditor"
    @hide-modal="hideModal()"
  >
    <offwater ref="offwaterEditor" v-bind="tareOffwaterProps" />
  </base-tare-offwater>
  <base-tare-offwater
    v-else-if="selectedDeviceSetType === 'hostNotice'"
    header-title="ホスト報知"
    :show-button="false"
    :resolve-editor-component="resolveActiveTareOffwaterEditor"
    @hide-modal="hideModal()"
  >
    <host-notice ref="hostNoticeEditor" v-bind="hostNoticeProps" />
  </base-tare-offwater>
  <modal-base v-else @onClose="cancelConfirm" class="custom-modal">
    <template #body>
      <component
        :is="selectedDeviceSetType"
        ref="deviceSetInfo"
        v-bind="deviceProps"
        @close="hideModal()"
      />
    </template>

    <template #footer>
      <v-ons-row class="button-area">
      <v-ons-col class="button-cancel">
        <v-ons-button
          class="btn2-cancel common-style-cancel-button"
          @click="cancelConfirm()"
        >
          {{ isTreat ?  "閉じる" : "キャンセル"}}
        </v-ons-button>
      </v-ons-col>
      <v-ons-col class="button-ok" v-if="!isTreat">
        <!-- mod FNSI-改修内容 権限関連 趙慧敏 start -->
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <v-ons-button class="btn1-execute common-style-ok-button" -->
        <!-- :disabled="!(hasDevicesetInfoAuthority && isDeviceSetInfoChanged)" -->
        <!-- @click="save()"> -->
        <v-ons-button
          class="btn1-execute common-style-ok-button"
          :disabled="!(getItemAuthorized('DevicesetInfo', 'default_authority') && isDeviceSetInfoChanged)"
          @click="save()">
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
          保存
        </v-ons-button>
        <!-- mod FNSI-改修内容 権限関連 趙慧敏 end -->
      </v-ons-col>
      </v-ons-row>
    </template>
  </modal-base>
</template>

<script>
  // add #10359 編集権限の動作不正 dengshen start
  import { getAuthorized } from "@/functions/common/CommonFunctions.js";
  // add #10359 編集権限の動作不正 dengshen end
  import {mapGetters} from "@/compat/vue/vuex";
  import {
    DATA_SOURCE_TYPE_MST,
    DATA_SOURCE_TYPE_PAT,
    DATA_SOURCE_TYPE_TREAT
  } from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
  import baseDeviceSetInfoList from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoList.vue";
  import MultiModalMixin from "@/components/modals/MultiModalMixin";
  import ModalBase from "@/components/modals/ModalBase";
  // add FNSI-改修内容 権限関連 趙慧敏 start
  // del #10359 編集権限の動作不正 dengshen start
  // import {AUTHORITY_CODES} from "@/constants/userAuthority";
  // import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
  // del #10359 編集権限の動作不正 dengshen end
  // add FNSI-改修内容 権限関連 趙慧敏 end
  // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
  import { EventBus } from "@/compat/vue/event-bus.js";
  // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
export default {
  components: {
    ModalBase
  },
  // mod FNSI-改修内容 権限関連 趙慧敏 start
  // mod #10359 編集権限の動作不正 dengshen start
  // mixins: [MultiModalMixin, baseDeviceSetInfoList,ComponentGuardMixin],
  mixins: [MultiModalMixin, baseDeviceSetInfoList],
  // mod #10359 編集権限の動作不正 dengshen end
  // mod FNSI-改修内容 権限関連 趙慧敏 end
  data() {
    return {
      isTreat: false,
      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
      isDeviceSetInfoChanged: false,
      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
      // add FNSI-改修内容 権限関連 趙慧敏 start
      isPat: false,
      // del #10359 編集権限の動作不正 dengshen start
      // authorityCds: [
      //   AUTHORITY_CODES.PAT_DEVSET_PEDIT,  // 患者別装置設定-代行編集
      //   AUTHORITY_CODES.PAT_DEVSET_EDIT    // 患者別装置設定-編集
      // ],
      // hasDevicesetInfoAuthority: false
      // del #10359 編集権限の動作不正 dengshen end
      // add FNSI-改修内容 権限関連 趙慧敏 end
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
        getFacilitySwitch: "getFacilitySwitch"
      }),
    ...mapGetters("user", {
      facilityCd: "getFacilityCd"
    }),
    ...mapGetters("pat-info", { patId: "selectedPatId" }),
    ...mapGetters("device-set-info-modal", {
      selectedDeviceSetType: "getSelectedDeviceSetType",
      selectedDeviceSetSrcType: "getSelectedDeviceSetSrcType"
    }),

    tareOffwaterProps() {
      const propsObj = {};

      switch (this.selectedDeviceSetSrcType) {
        case DATA_SOURCE_TYPE_MST:
          propsObj.propsTableFlag = 0;
          // mod マスタ一覧 1･施設切替を可能とする 孔s start
          // propsObj.propsFacilityCd = this.facilityCd;
          propsObj.propsFacilityCd = this.getFacilitySwitch;
          // mod マスタ一覧 1･施設切替を可能とする 孔s end
          break;
        case DATA_SOURCE_TYPE_PAT:
          propsObj.propsTableFlag = 1;
          propsObj.propsPatId = this.patId;
          break;
      }
      return propsObj;
    },

    hostNoticeProps() {
      const propsObj = {};
      switch (this.selectedDeviceSetSrcType) {
        case DATA_SOURCE_TYPE_MST:
          propsObj.dataSourceType = DATA_SOURCE_TYPE_MST;
          //#10380：ホスト報知のデフォルトデータ修正 Start
          propsObj.propsFacilityCd = this.getFacilitySwitch;
          //#10380：ホスト報知のデフォルトデータ修正 End
          break;
        case DATA_SOURCE_TYPE_PAT:
          propsObj.dataSourceType = DATA_SOURCE_TYPE_PAT;
          propsObj.propsPatId = this.patId;
          propsObj.propsFacilityCd = this.facilityCd;
          break;
      }
      return propsObj;
    },

    deviceProps() {
      const propsObj = { showButton: false };

      switch (this.selectedDeviceSetSrcType) {
        case DATA_SOURCE_TYPE_MST:
          propsObj.dataSourceType = DATA_SOURCE_TYPE_MST;
          // mod マスタ一覧 1･施設切替を可能とする 孔s start
          // propsObj.facilityCd = this.facilityCd;
          propsObj.facilityCd = this.getFacilitySwitch;
          // mod マスタ一覧 1･施設切替を可能とする 孔s end
          break;
        case DATA_SOURCE_TYPE_PAT:
          propsObj.dataSourceType = DATA_SOURCE_TYPE_PAT;
          propsObj.patId = this.patId;
          propsObj.facilityCd = this.facilityCd;
          break;
        case DATA_SOURCE_TYPE_TREAT:
          propsObj.dataSourceType = DATA_SOURCE_TYPE_TREAT;
          propsObj.patId = this.patId;
          propsObj.facilityCd = this.facilityCd;
          break;
      }

      return propsObj;
    }
  },

  // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
  // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end

  methods: {
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    /**
     * @description キャンセル確認
     */
    cancelConfirm() {
      this.$refs.deviceSetInfo.cancelConfirm();
    },

    resolveActiveTareOffwaterEditor() {
      switch (this.selectedDeviceSetType) {
        case "tare":
          return this.$refs.tareEditor || null;
        case "offwater":
          return this.$refs.offwaterEditor || null;
        case "hostNotice":
          return this.$refs.hostNoticeEditor || null;
        default:
          return null;
      }
    },

    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定 20231227 ztc start
    // setSaveBtnEnable() {
    setSaveBtnEnable(editFlg) {
      // this.isDeviceSetInfoChanged = true;
      if(editFlg === undefined || editFlg === null){
        editFlg = true;
      }
      this.isDeviceSetInfoChanged = editFlg;
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定 20231227 ztc end
    },

    checkDeviceSetInfoChange() {
      console.log(`selectedDeviceSetType(${this.selectedDeviceSetType})`);
      if(null !== this.$refs.deviceSetInfo && this.$refs.deviceSetInfo.isEdited()) {
        this.setSaveBtnEnable();
      }
    },
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end

    /**
     * @description 保存ボタン処理
     */
    async save() {
      this.deviceType = this.selectedDeviceSetType;
      await this.$refs.deviceSetInfo.saveConfirm();
    },

    // del #10359 編集権限の動作不正 dengshen start
    // // add FNSI-改修内容 権限関連 趙慧敏 start
    // getDevicesetInfoAuthority() {
    //   return this.hasAuthorityByCd(AUTHORITY_CODES.PAT_DEVSET_PEDIT) || this.hasAuthorityByCd(AUTHORITY_CODES.PAT_DEVSET_EDIT);
    // }
    // // add FNSI-改修内容 権限関連 趙慧敏 end
    // del #10359 編集権限の動作不正 dengshen end
  },
  created() {
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    EventBus.$off("deviceSetChanged", this.setSaveBtnEnable);
    EventBus.$off("checkDeviceSetInfoChange", this.checkDeviceSetInfoChange);
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
    if (this.selectedDeviceSetSrcType === DATA_SOURCE_TYPE_TREAT)
      this.isTreat = true;
    // add FNSI-改修内容 権限関連 趙慧敏 start
    if (this.selectedDeviceSetSrcType === DATA_SOURCE_TYPE_PAT){
      this.isPat = true;
    }
    // del #10359 編集権限の動作不正 dengshen start
    // this.hasDevicesetInfoAuthority = this.getDevicesetInfoAuthority();
    // del #10359 編集権限の動作不正 dengshen end
    // add FNSI-改修内容 権限関連 趙慧敏 end
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    EventBus.$on("deviceSetChanged", this.setSaveBtnEnable);
    EventBus.$on("checkDeviceSetInfoChange", this.checkDeviceSetInfoChange);
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
  },
  beforeUnmount() {
    EventBus.$off("deviceSetChanged", this.setSaveBtnEnable);
    EventBus.$off("checkDeviceSetInfoChange", this.checkDeviceSetInfoChange);
  }
};
</script>

<style
  src="@/components/deviceset-info/base-modules/BeseDeviceSetInfoStyle.css"
  scoped
></style>

<style scoped>
/* TODO: 共通スタイル(modal.css)に定義 */
div :deep(.modal-header .toolbar) {
  background-color: var(--ntss-header-background-color);
}

div :deep(.modal-header .toolbar__title.toolbar__left) {
  color: var(--ntss-header-color) !important;
}

div :deep(.modal-search),
div :deep(.modal-body),
div :deep(.modal-footer),
div :deep(.modal-footer .bottom-bar) {
  background-color: var(--ntss-base-background-color);
  color: var(--ntss-base-color);
}
div :deep(.modal-footer ons-bottom-toolbar) {
  height: auto;
}
</style>
