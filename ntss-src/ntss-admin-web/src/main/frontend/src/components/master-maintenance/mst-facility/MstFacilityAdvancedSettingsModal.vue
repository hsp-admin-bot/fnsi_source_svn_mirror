<template>
  <modal-base @onClose="cancel">
    <div slot="body">
      <div class="advanced-settings d-flex flex-column">
        <div
          class="setting d-flex flex-column"
          v-for="setting in sysAdvancedSettings"
          :key="setting.functionAdvCd"
        >
          <div class="d-flex align-items-center">
            <v-ons-switch
              :disabled="!isAdminUser"
              :input-id="setting.functionAdvCd"
              v-model="editingSettings[setting.functionAdvCd]"
            />
            <label :for="setting.functionAdvCd">
              {{ setting.functionAdvName }}
            </label>
          </div>
        </div>
      </div>
    </div>

    <!-- Actions -->
    <div slot="footer" class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="button btn2-cancel denial-btn" @click="cancel">キャンセル</v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <v-ons-button class="button common-style-select-button registration-btn" @click="save">
          確定
        </v-ons-button>
      </div>
    </div>
    <!-- Actions -->
  </modal-base>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import _ from "underscore";
import ModalBase from "@/components/modals/ModalBase";
import { EventBus } from "@/eventBus.js";
import { ApiHelper } from "@/apis/AxiosHelper";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end

export default {
  name: "MstFacilityAdvancedSettingsModal",
  components: {
    "modal-base": ModalBase
  },
  data() {
    return {
      sysAdvancedSettings: [],
      facilityAdvanceSettings: [],
      originalSettings: {},
      editingSettings: {}
    };
  },
  computed: {
    ...mapGetters("master-maintenance", [
      "getEditRecord",
      "getMasterRecordList"
    ]),
    ...mapGetters("account-edit", [
      "getStateUserAccountInfo"
    ]),
    isAdminUser() {
      //管理者ならtrue/それ以外はfalse
      return 1 === this.getStateUserAccountInfo.administrator;
    }
  },
  async created() {
    // 施設コード、システム利用設定を取得
    const editFacilityCd = this.getEditRecord.facilityCd;
    const systemUseSetting = this.getEditRecord.systemUseSetting;

    this.sysAdvancedSettings = (
      await ApiHelper.get("/mstInfo/sysFunctionAdvanced")
    ).data;

    // 日機装施設の場合
    if (editFacilityCd === "nkknkk") {
      // システム利用設定がReMSの場合
      if (systemUseSetting === "1") {
        // メニューの並びを設定する
        this.sysAdvancedSettings = this.sysAdvancedSettings.filter(item => {
          return item.systemUseDisp === "0" || item.systemUseDisp === "1";
        })
      } else if (systemUseSetting === "2") {
        // システム利用設定がFNSiの場合、メニューの並びを設定する
        this.sysAdvancedSettings = this.sysAdvancedSettings.filter(item => {
          return item.systemUseDisp === "0" || item.systemUseDisp === "2";
        })
      } else {
        // システム利用設定がReMS+FNSiの場合、メニューの並びを設定する
        this.sysAdvancedSettings = this.sysAdvancedSettings.filter(item => {
          return item.systemUseDisp === "0" || item.systemUseDisp === "1" || item.systemUseDisp === "2";
        })
      }
    } else {
      // 日機装施設以外の場合、メニューの並びを設定する
      this.sysAdvancedSettings = this.sysAdvancedSettings.filter(item => {
        return item.isNkk == "0";
      })
      // システム利用設定がReMSの場合
      if (systemUseSetting === "1") {
        // メニューの並びを設定する
        this.sysAdvancedSettings = this.sysAdvancedSettings.filter(item => {
          return item.systemUseDisp === "0" || item.systemUseDisp === "1";
        })
      } else if (systemUseSetting === "2") {
        // システム利用設定がFNSiの場合、メニューの並びを設定する
        this.sysAdvancedSettings = this.sysAdvancedSettings.filter(item => {
          return item.systemUseDisp === "0" || item.systemUseDisp === "2";
        })
      } else {
        // システム利用設定がReMS+FNSiの場合、メニューの並びを設定する
        this.sysAdvancedSettings = this.sysAdvancedSettings.filter(item => {
          return item.systemUseDisp === "0" || item.systemUseDisp === "1" || item.systemUseDisp === "2";
        })
      }
    }

    if (this.getEditRecord.advancedSettings) {
      try {
        this.facilityAdvanceSettings = JSON.parse(
          this.getEditRecord.advancedSettings
        );
      } catch(error) {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstFacilityAdvancedSettingsModal.vue', 'created', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        this.facilityAdvanceSettings = {};
      }
    }

    if (!this.facilityAdvanceSettings.func_advcds) {
      this.facilityAdvanceSettings.func_advcds = [];
    }

    const settingsStatus = this.sysAdvancedSettings.reduce(
      (acc, { functionAdvCd }) => {
        acc[functionAdvCd] = this.facilityAdvanceSettings.func_advcds.some(
          s => s.func_advcd === functionAdvCd
        );
        return acc;
      },
      {}
    );

    this.originalSettings = this.clone(settingsStatus);
    this.editingSettings = this.clone(settingsStatus);
  },
  methods: {
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("master-maintenance", [
      "setEditRecord",
      "editRecordBeEmpty",
      "setMasterRecordList"
    ]),
    cancel() {
      if (this.isContentChanged()) {
        this.$ons.notification.confirm({
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: ok => {
            if (ok) this.closeModal();
          }
        });
      } else {
        this.closeModal();
      }
    },
    save() {
      // 管理者権限がない場合、保存せずに閉じる
      if (!this.isContentChanged() || !this.isAdminUser) {
        this.closeModal();
        return;
      }

      this.originalSettings = this.clone(this.editingSettings);

      let editRecord = Object.keys(this.editingSettings).reduce(
        (acc, code) => {
          if (this.editingSettings[code]) {
            acc.func_advcds.push({ func_advcd: code });
          }

          return acc;
        },
        { func_advcds: [] }
      );

      this.setEditRecord({
        ...this.getEditRecord,
        advancedSettings: JSON.stringify(editRecord)
      });
      editRecord = this.getEditRecord;
      // operationがないときは編集とみなす
      if (!editRecord.operation) {
        editRecord.operation = 2;
      } else if (editRecord.operation === 1) {
        // "追加"の場合は、"編集済"フラグを立てる
        editRecord.edited = true;
      }

      const masterRecordList = this.getMasterRecordList;
      const index = masterRecordList.data.findIndex(
        masterRecord => masterRecord.code === editRecord.code
      );
      masterRecordList.data[index] = editRecord;

      this.setMasterRecordList(undefined);
      this.setMasterRecordList(masterRecordList);
      this.closeModal();
    },
    isContentChanged() {
      return !_.isEqual(this.originalSettings, this.editingSettings);
    },
    closeModal() {
      this.editRecordBeEmpty();
      this.hideModal();
      EventBus.$emit("onCloseMasterEditModal");
    },
    clone(obj) {
      return JSON.parse(JSON.stringify(obj));
    }
  }
};
</script>

<style scoped>
.advanced-settings {
  padding: 10px;
}

.setting {
  padding-top: 5px;
  padding-bottom: 5px;
}

.setting label {
  min-width: 160px;
  line-height: 1;
  margin-left: 5px;
}

.insurance-sub-settings {
  margin-left: 51px;
}

.insurance-sub-settings > div {
  margin-bottom: 5px;
}

.insurance-sub-settings > div:last-child {
  margin-bottom: 0;
}

.setting_label {
  margin-left: 1em;
}
</style>
