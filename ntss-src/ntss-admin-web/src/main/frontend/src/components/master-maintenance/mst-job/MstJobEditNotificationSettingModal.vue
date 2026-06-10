/**
 * 職種マスタ用デフォルト通知設定ページ
 */
<template>
  <modal-base @onClose="cancel">
    <div slot="body" class="personal-settings-body tab-contents-area">
      <!-- すでにある個人設定タブ - 通知設定タブのコンポーネントを流用 -->
      <NotificationSettingComponent ref="notificationSettingComponentRef"  :showFooter="false" :mstJobEditMode="true" :mstJobData="initData"/>
    </div>
    <div slot="footer" class="flex-container common-tab-footer">
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="btn2-cancel button denial-btn" @click="cancel">キャンセル</v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <v-ons-button class="common-style-select-button button registration-btn" :disabled="!isNotificationSettingChanged" @click="registration">確定</v-ons-button>
      </div>
    </div>
  </modal-base>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import { EventBus } from "@/eventBus.js";
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import PopoverMixin from "@/components/PopoverMixin";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
import cloneDeep from "lodash/cloneDeep";
import NotificationSettingComponent from "@/components/modals/notification-setting/NotificationSettingComponent.vue";
import { TAB_DEFINE_CD_NOTIFICATION_SETTING } from "@/constants/PersonalSettingConstants";

export default {
  name: "MstJobEditNotificationSettingModal",
  mixins: [MultiModalMixin, PopoverMixin],
  components: {
    "NotificationSettingComponent": NotificationSettingComponent,
    "modal-base": ModalBase
  },
  data() {
    return {
      isNotificationSettingChanged : false,
      initData : null
    };
  },
  computed: {
    ...mapGetters("master-maintenance", [
      "getEditRecord",
    ]),
  },
  methods: {
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("master-maintenance", [
      "setEditRecord"
    ]),
    ...mapActions("mst-job", [
      "setIsDefaultNotificationSettings"
    ]),
    ...mapActions("personal-setting", [
      "setSelectedTabDefineCd"
    ]),
    /**
     * 確定処理
     */
    registration() {
      // 編集中マスタを更新
      const editRecord = cloneDeep(this.getEditRecord);
      const editNotificationSetting = this.$refs.notificationSettingComponentRef.getSaveParam();
      if(!editNotificationSetting){
        return;
      }
      // 個人設定登録時の構造と合わせるため不足しているキーを初期値で追加
      editNotificationSetting['setting_important'] = []
      // 重要設定がundefinedの場合があり登録時に構造がかわるため明示的にnullにする
      for (const item of editNotificationSetting.values) {
        if(item.setting_important === undefined){
          item.setting_important = null;
        }
      }

      editRecord.defaultNotificationSettings = JSON.stringify(editNotificationSetting);
      this.setEditRecord(editRecord);

      // デフォルト通知設定フラグを立てる
      this.setIsDefaultNotificationSettings(true);
      // モーダル画面を閉じる
      this.closeModalWindow();
    },
    /**
     * キャンセル処理
     */
    cancel() {
      // 変更がある場合はメッセージを表示
      if (this.isNotificationSettingChanged) {
        this.$ons.notification.confirm({
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: answer => {
            if (answer == 1) {
              //OK
              this.closeModalWindow();
            }
          }
        });
      } else {
        this.closeModalWindow();
      }
    },
    /**
     * モーダル画面を閉じる処理
     */
    closeModalWindow() {
      this.hideModal();
      EventBus.$emit("onCloseMasterEditModal");
    },
  },
  created() {
    // 通知設定のタブ定義コードを設定
    // - 通知設定コンポーネントの初期表示に必要
    this.setSelectedTabDefineCd(TAB_DEFINE_CD_NOTIFICATION_SETTING);

    // 初期値をセット
    this.initData = cloneDeep(this.getEditRecord.defaultNotificationSettings);
  },
  mounted(){
    // 子コンポーネントの変更をwatch
    this.$nextTick(() => {
      this.$watch(
        () => this.$refs.notificationSettingComponentRef.isChanged,
        (newValue) => {
          this.isNotificationSettingChanged =  newValue;
        }
      );
    });
  },
  beforeDestroy() {
  }
};
</script>

<style scoped>
.personal-settings-body {
  height: calc(100% - 6px);
  /*add FNSI-改修内容4503 任 start*/
  overflow-y: hidden;
  /*add FNSI-改修内容4503 任 end*/
  color: var(--ntss-base-color);
}
.tab-contents-area {
  height: 100%;
}
</style>
