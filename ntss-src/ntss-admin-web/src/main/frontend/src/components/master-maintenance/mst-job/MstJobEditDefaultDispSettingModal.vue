/**
 * 職種マスタ用デフォルト表示設定ページ
 */
<template>
  <modal-base @onClose="cancel">
    <div slot="body" class="personal-settings-body tab-contents-area">
      <!-- すでにある個人設定タブ - デフォルト設定タブのコンポーネントを流用 -->
      <DefaultSettingComponent ref="defaultSettingComponentRef"  :showFooter="false"/>
    </div>
    <div slot="footer" class="flex-container common-tab-footer">
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="btn2-cancel button denial-btn" @click="cancel">キャンセル</v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <v-ons-button class="common-style-select-button button registration-btn" :disabled="!isDefaultSettingChanged" @click="registration">確定</v-ons-button>
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
import DefaultSettingComponent from "@/components/modals/default-setting/DefaultSettingComponent";

export default {
  name: "MstJobEditDefaultDispSettingModal",
  mixins: [MultiModalMixin, PopoverMixin],
  components: {
    "DefaultSettingComponent": DefaultSettingComponent,
    "modal-base": ModalBase
  },
  data() {
    return {
      tmpDefaultDispSettings : null,
      tmpAuthorizedFunctions: [],
      isDefaultSettingChanged : false,
      tmpUserFacilityCd: ""
    };
  },
  computed: {
    ...mapGetters("master-maintenance", [
      "getFacilitySwitch",
      "getFacilitySwitchUseFunction",
      "getEditRecord",
    ]),
    ...mapGetters("account-edit", [
      "getAuthorizedFunctions",
      "getDefaultSetting",
      ]),
    ...mapGetters("user", ["getFacilityCd"]),
  },
  methods: {
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("master-maintenance", [
      "setEditRecord",
      // "editRecordBeEmpty",
      "setMasterRecordList"
    ]),
    ...mapActions("account-edit", ["setDefaultSetting","setAuthorizedFunctions"]),
    ...mapActions("mst-job", [
      "setIsDefaultDispSettings"
    ]),
    ...mapActions("user", ["setFacilityCd"]),
    /**
     * 確定処理
     */
    registration() {
      // 編集中マスタを更新
      const editRecord = cloneDeep(this.getEditRecord);
      const editDefaultSettingStr = this.$refs.defaultSettingComponentRef.getDefaultSettingStr();
      if(!editDefaultSettingStr){
        return;
      }
      editRecord.defaultDispSettings = JSON.stringify(editDefaultSettingStr);
      this.setEditRecord(editRecord);

      // デフォルト表示設定フラグを立てる
      this.setIsDefaultDispSettings(true);
      // モーダル画面を閉じる
      this.closeModalWindow();
    },
    /**
     * キャンセル処理
     */
    cancel() {
      // 変更がある場合はメッセージを表示
      if (this.isDefaultSettingChanged) {
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
      // state.editRecordを空にする
      // this.editRecordBeEmpty();
      this.hideModal();
      EventBus.$emit("onCloseMasterEditModal");
    },
    /**
     * モーダル画面破棄時処理
     */
    closedModal(e){
      // 一時保存したアカウント・ユーザー情報の設定を戻す
      this.setAuthorizedFunctions(this.tmpAuthorizedFunctions);
      this.setDefaultSetting(this.tmpDefaultDispSettings);
      this.setFacilityCd(this.tmpUserFacilityCd);
    }
  },
  created() {
    // アカウント情報のデフォルト設定・権限設定、ユーザーの施設コードを一時保存
    this.tmpAuthorizedFunctions = cloneDeep(this.getAuthorizedFunctions);
    this.tmpDefaultDispSettings = cloneDeep(this.getDefaultSetting);
    this.tmpUserFacilityCd = cloneDeep(this.getFacilityCd);

    // 初期値をセット
    // - アカウント情報のデフォルト設定を職種マスタの設定で書き換えるので、画面を閉じる直前で戻す必要あり
    let saveDefaultDispSettings = cloneDeep(this.getEditRecord.defaultDispSettings);
    if(saveDefaultDispSettings === null){
      // 既存データでnullの場合があるため初期値を設定
      saveDefaultDispSettings = "{}"
    }
    this.setDefaultSetting(JSON.parse(saveDefaultDispSettings));
    // 施設に対して許可された機能を取得して設定
    // - アカウント情報の使用可能施設設定を施設マスタの設定で書き換えるので、画面を閉じる直前で戻す必要あり
    this.setAuthorizedFunctions(this.getFacilitySwitchUseFunction);
    // ユーザーの施設コードを編集対象の施設コードに一時的に上書き設定
    // 日機装施設の場合編集対象施設が切り替えられるためユーザーの施設を一時的に切り替える
    // - ユーザー情報の施設コード設定を編集対象施設コードで書き換えるので、画面を閉じる直前で戻す必要あり
    this.setFacilityCd(this.getFacilitySwitch);
  },
  mounted(){
    // 子コンポーネントの変更をwatch
    this.$nextTick(() => {
      this.$watch(
        () => this.$refs.defaultSettingComponentRef.isChanged,
        (newValue) => {
          this.isDefaultSettingChanged =  newValue;
        }
      );
    });
    // 破棄時イベント設定
    // - 確実に一時保存情報を戻すためリロードやタブごと閉じた場合でも情報を戻す
    window.addEventListener('beforeunload', this.closedModal);
  },
  beforeDestroy() {
    // 一時保存した設定を戻す
    this.closedModal();
    // コンポーネント破棄時にイベント解除
    window.removeEventListener('beforeunload', this.closedModal);
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
