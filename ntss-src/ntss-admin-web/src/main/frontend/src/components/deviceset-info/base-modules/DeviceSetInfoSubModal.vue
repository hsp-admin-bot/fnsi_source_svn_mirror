<template>
  <base-tare-offwater v-if="selectedDeviceSetType === 'tare'" header-title="風袋" :show-button="false"
    @hide-modal="hideModal()">
    <tare v-bind="tareOffwaterProps" />
  </base-tare-offwater>
  <base-tare-offwater v-else-if="selectedDeviceSetType === 'offwater'" header-title="除水" :show-button="false"
    @hide-modal="hideModal()">
    <offwater v-bind="tareOffwaterProps" />
  </base-tare-offwater>
  <modal-base v-else @onClose="cancelConfirm">
    <!-- mod #10359 編集権限の動作不正 dengshen start -->
    <!-- <component :is="selectedDeviceSetType" slot="body" ref="deviceSetInfo" v-bind="deviceProps" @close="hideModal()" /> -->
    <component :is="selectedDeviceSetType" slot="body" :is-mst="true" ref="deviceSetInfo" v-bind="deviceProps" @close="hideModal()" />
    <!-- mod #10359 編集権限の動作不正 dengshen end -->

    <v-ons-row slot="footer" class="button-area">
      <v-ons-col class="button-cancel">
        <v-ons-button class="btn2-cancel common-style-cancel-button" @click="cancelConfirm()">
          キャンセル
        </v-ons-button>
      </v-ons-col>
      <v-ons-col class="button-ok">
        <v-ons-button :disabled="saveButton" class="btn1-execute common-style-ok-button" @click="save()">
          確定
        </v-ons-button>
      </v-ons-col>
    </v-ons-row>
  </modal-base>
</template>

<script>
  import {
    mapGetters,
    mapActions
  } from "vuex";
  import {
    DATA_SOURCE_TYPE_MST,
    DATA_SOURCE_TYPE_PAT,
    DATA_SOURCE_TYPE_MST_EDIT_RECORD
  } from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
  import baseDeviceSetInfoList from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoList.vue";
  import MultiModalMixin from "@/components/modals/MultiSubModalMixin";
  import ModalBase from "@/components/modals/SubModalBase";
  import {
    EventBus
  } from "@/eventBus";
  // add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
  import { messageFormat } from '@/functions/common/MessageFormat';
  import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
  // add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end

  export default {
    components: {
      ModalBase
    },
    data() {
      return {
        saveButton: true
      }
    },

    mixins: [MultiModalMixin, baseDeviceSetInfoList],

    computed: {
      ...mapGetters("master-maintenance", {
        getFacilitySwitch: "getFacilitySwitch"
      }),
      ...mapGetters("user", {
        facilityCd: "getFacilityCd"
      }),
      ...mapGetters("pat-info", {
        patId: "selectedPatId"
      }),
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
          case DATA_SOURCE_TYPE_MST_EDIT_RECORD:
            propsObj.propsTableFlag = 0;
            // mod マスタ一覧 1･施設切替を可能とする 孔s start
            // propsObj.propsFacilityCd = this.facilityCd;
            propsObj.propsFacilityCd = this.getFacilitySwitch;
            // mod マスタ一覧 1･施設切替を可能とする 孔s end
            break;
        }

        return propsObj;
      },

      deviceProps() {
        const propsObj = {
          showButton: false
        };

        switch (this.selectedDeviceSetSrcType) {
          case DATA_SOURCE_TYPE_MST:
            propsObj.dataSourceType = DATA_SOURCE_TYPE_MST;
            // mod マスタ一覧 1･施設切替を可能とする 孔s start
            // propsObj.facilityCd = this.facilityCd;
            propsObj.facilityCd = this.getFacilitySwitch;
            // mod マスタ一覧 1･施設切替を可能とする 孔s start
            break;
          case DATA_SOURCE_TYPE_PAT:
            propsObj.dataSourceType = DATA_SOURCE_TYPE_PAT;
            propsObj.patId = this.patId;
            propsObj.facilityCd = this.facilityCd;
            break;
          case DATA_SOURCE_TYPE_MST_EDIT_RECORD:
            propsObj.dataSourceType = DATA_SOURCE_TYPE_MST_EDIT_RECORD;
            // mod マスタ一覧 1･施設切替を可能とする 孔s start
            // propsObj.facilityCd = this.facilityCd;
            propsObj.facilityCd = this.getFacilitySwitch;
            // mod マスタ一覧 1･施設切替を可能とする 孔s end
            break;
        }

        return propsObj;
      }
    },

    methods: {
      // add #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 start
      ...mapActions("device-set-info-modal", ["setSelectedDeviceSetInfoState"]),
      // add #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 end
      /**
       * @description キャンセル確認
       */
      cancelConfirm() {
        this.$refs.deviceSetInfo.cancelConfirm();
      },

      /**
       * @description 保存ボタン処理
       */
      async save() {
        EventBus.$emit("mstHolidayRegistered", false);
        this.deviceType = this.selectedDeviceSetType;
        //除水プログラムをONにして、BV-UFCを使用するに設定して保存ができる。注意喚起メッセージは表示する #7295 xiemj start
        // mod #10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
        let conform = true;
        if (this.deviceType === this.DEVICE_TYPE_BVUFC) {
          if ((this.$refs.deviceSetInfo.deviceSetInfoRaw.ufr.dev.A[290] === '1' || this.$refs.deviceSetInfo.deviceSetInfoRaw.ufr.dev.A[290] === '2') && this.$refs.deviceSetInfo.devA[196].value.editValue === '1') {
            conform = false;
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "",
              // message: `<div style="text-align:left;">除水プログラムとBV-UFCは併用できません。<br> </div>`
              title: DIALOG_MESSAGES[12000031].title,
              message: messageFormat(`<div style="text-align:left;">${DIALOG_MESSAGES[12000031].message}</div>`),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              callback: async answer => {
                if (answer == 0) {
                  //OK
                  // モーダルを閉じる
                  if (
                      this.deviceType === this.DEVICE_TYPE_UFR ||
                      this.deviceType === this.DEVICE_TYPE_NA ||
                      this.deviceType === this.DEVICE_TYPE_DC ||
                      this.deviceType === this.DEVICE_TYPE_IHDF ||
                      this.deviceType === this.DEVICE_TYPE_BVUFC ||
                      this.deviceType === this.DEVICE_TYPE_DIA ||
                      this.deviceType === this.DEVICE_TYPE_QBQD
                  ) {
                    await this.$refs.deviceSetInfo.save();
                  } else {
                    await this.$refs.deviceSetInfo.saveConfirm();
                  }
                }
              }
              // return;
            });
          }
        }
        if (this.deviceType === this.DEVICE_TYPE_UFR) {
          if ((this.$refs.deviceSetInfo.devA[290].value.editValue === "1" || this.$refs.deviceSetInfo.devA[290].value.editValue === "2") && this.$refs.deviceSetInfo.deviceSetInfoRaw.bvufc.dev.A[196] === "1") {
            conform = false;
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "",
              // message: `<div style="text-align:left;">除水プログラムとBV-UFCは併用できません。<br> </div>`
              title: DIALOG_MESSAGES[12000031].title,
              message: messageFormat(`<div style="text-align:left;">${DIALOG_MESSAGES[12000031].message}</div>`),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              callback: async answer => {
                if (answer == 0) {
                  //OK
                  // モーダルを閉じる
                  if (
                      this.deviceType === this.DEVICE_TYPE_UFR ||
                      this.deviceType === this.DEVICE_TYPE_NA ||
                      this.deviceType === this.DEVICE_TYPE_DC ||
                      this.deviceType === this.DEVICE_TYPE_IHDF ||
                      this.deviceType === this.DEVICE_TYPE_BVUFC ||
                      this.deviceType === this.DEVICE_TYPE_DIA ||
                      this.deviceType === this.DEVICE_TYPE_QBQD
                  ) {
                    await this.$refs.deviceSetInfo.save();
                  } else {
                    await this.$refs.deviceSetInfo.saveConfirm();
                  }
                }
              }
              // return;
            });
          }
        }
        if (conform) {
          if (
              this.deviceType === this.DEVICE_TYPE_UFR ||
              this.deviceType === this.DEVICE_TYPE_NA ||
              this.deviceType === this.DEVICE_TYPE_DC ||
              this.deviceType === this.DEVICE_TYPE_IHDF ||
              this.deviceType === this.DEVICE_TYPE_BVUFC ||
              this.deviceType === this.DEVICE_TYPE_DIA ||
              this.deviceType === this.DEVICE_TYPE_QBQD
          ) {
            await this.$refs.deviceSetInfo.save();
          } else {
            await this.$refs.deviceSetInfo.saveConfirm();
          }
        }
        // mod #10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
        //除水プログラムをONにして、BV-UFCを使用するに設定して保存ができる。注意喚起メッセージは表示する #7295 xiemj end
        /* del by chamaojia 2023-11-09 [9414] コード位置追加エラー、BaseDeviceSetInfoEditor.vueへの移行  --start */
        // // add #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 start
        // if (this.deviceType === 'ufr') {
        //   await this.setSelectedDeviceSetInfoState({ deviceState: this.$refs.deviceSetInfo.devA[290].value.editValue })
        // } else if (this.deviceType === 'na') {
        //   await this.setSelectedDeviceSetInfoState({ deviceState: this.$refs.deviceSetInfo.devA[315].value.editValue })
        // } else if (this.deviceType === 'dc') {
        //   await this.setSelectedDeviceSetInfoState({ deviceState: this.$refs.deviceSetInfo.devA[340].value.editValue })
        // } else if (this.deviceType === 'qbqd') {
        //   await this.setSelectedDeviceSetInfoState(
        //     { deviceState: { 430: this.$refs.deviceSetInfo.devA[430].value.editValue, 431: this.$refs.deviceSetInfo.devA[431].value.editValue } }
        //   )
        // } else if (this.deviceType === 'bvufc') {
        //   await this.setSelectedDeviceSetInfoState({ deviceState: this.$refs.deviceSetInfo.devA[196].value.editValue })
        // } else if (this.deviceType === 'dia') {
        //   await this.setSelectedDeviceSetInfoState({ deviceState: this.$refs.deviceSetInfo.devA[282].value.editValue })
        // } else if (this.deviceType === 'ihdf') {
        //   await this.setSelectedDeviceSetInfoState({ deviceState: this.$refs.deviceSetInfo.devA[432].value.editValue })
        // }
        // // this.$refs.deviceSetInfo
        // // add #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 end
        /* del by chamaojia 2023-11-09 [9414] コード位置追加エラー、BaseDeviceSetInfoEditor.vueへの移行  --end */
      },
      modRegisteredFlag(val) {
        this.saveButton = val;
      }
    },

    created() {
      EventBus.$on("mstTreatmentSetRegistered", this.modRegisteredFlag);
    },

    beforeDestroy() {
      EventBus.$off("mstTreatmentSetRegistered", null);
    }
  };
</script>

<style src="@/components/deviceset-info/base-modules/BeseDeviceSetInfoStyle.css" scoped></style>

<style scoped>
  /* TODO: 共通スタイル(modal.css)に定義 */
  div>>>.sub-modal-header .toolbar {
    background-color: var(--ntss-header-background-color);
  }

  div>>>.sub-modal-header .toolbar__title.toolbar__left {
    color: var(--ntss-header-color) !important;
  }

  div>>>.sub-modal-search,
  div>>>.sub-modal-body,
  div>>>.sub-modal-footer,
  div>>>.sub-modal-footer .bottom-bar {
    background-color: var(--ntss-base-background-color);
    color: var(--ntss-base-color);
  }

  @media only screen and (max-width:667px) {
    div>>>.sub-modal-footer {
      bottom: -11px;
    }
  }
</style>
