/**
 * 個人設定ページ
 */
<template>
  <modal-base @onClose="cancel" :showFooter="false">
    <template #body>
      <div class="personal-settings-body">
      <div v-if="isTabDefineEmpty" class="empty-message">タブの情報がありません。</div>
      <div v-if="!isTabDefineEmpty" class="tab-and-contents-wrapper">
        <!-- タブ領域 -->
        <div class="tab-area">
          <div class="tab-button-wrapper" v-for="(define, index) in tabDefine" :key="index">
            <button class="tab-button" :style="activeStyles(define)" @click="showContents(define)">
              <span>{{ define.displayName }}</span>
            </button>
          </div>
        </div>
        <!-- 中身領域 -->
        <div class="tab-contents-area">
          <main-component v-if="isCommonMode" ref="mainComponent" />
          <component v-else :is="main" ref="mainComponent" />
        </div>
      </div>
      </div>
    </template>
  </modal-base>
</template>

<script>
  import { defineAsyncComponent } from "@/compat/vue/runtime";
  import {mapActions, mapGetters} from "@/compat/vue/vuex";
  import ModalBase from "@/components/modals/ModalBase";
  import MultiModalMixin from "@/components/modals/MultiModalMixin";
  import MainComponent from "@/components/modals/PersonalSettingComponent";
  import NotificationSettingComponent from "@/components/modals/notification-setting/NotificationSettingComponent";
  import DefaultSettingComponent from "@/components/modals/default-setting/DefaultSettingComponent";
  // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';

// mod #6107 2023/03/23 メッセージボックス全調整 張博 end

  export default {
  name: "personalSettings",
  components: {
    "modal-base": ModalBase,
    "main-component": MainComponent,
    "notification-setting": NotificationSettingComponent, // import
    "fixed-phrase": defineAsyncComponent(() =>
      import("@/components/modals/fixed-phrase/FixedPhraseComponent")), // import
    "default-setting": DefaultSettingComponent, // import
  },
  mixins: [MultiModalMixin],
  data() {
    return {
      main: "",
      mode: "",
      define: {},
      tabDefine: []
    };
  },
  computed: {
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("personal-setting", {tabDefineCd: "getSelectedTabDefineCd"}),
    /**
     * タブ定義が空かどうか.
     */
    isTabDefineEmpty() {
      return this.tabDefine.length === 0;
    },
    /**
     * タブ定義が共通設定モードかどうか.
     */
    isCommonMode() {
      return this.mode === "1";
    }
  },
  methods: {
    ...mapActions("personal-setting", [
      "getPersonalTabDefine",
      "setSelectedTabDefineCd"
    ]),
    /**
     * モーダルを閉じる.
     */
    cancel() {
      // 編集破棄確認
      this.discardConfirm(this.hideModal);
    },
    /**
     * 選択した定義のコンテンツを表示する.
     * @param define 定義情報
     */
    showContents(define) {
      this.define = define;
      // 編集破棄確認
      this.discardConfirm(() => {
        this.main = this.define.contentsId;
        this.mode = this.define.mode;
        this.setSelectedTabDefineCd(this.define.tabDefineCd);
      });
    },
    /**
     * 編集中である場合に、編集破棄確認を行う.
     * @param execFunction 実行するコールバック関数
     */
    discardConfirm(execFunction) {
      if (this.$refs.mainComponent && this.$refs.mainComponent.isChanged) {
        this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "内容破棄",
          title: DIALOG_MESSAGES[13000004].title,
          // message: "編集内容が破棄されます。</br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer === 1) {
              execFunction();
            }
          }
        });
      } else {
        execFunction();
      }
    },
    /**
     * アクティブタブのスタイル設定を行う.
     * @param define 定義情報
     */
    activeStyles(define) {
      const isActive = this.tabDefineCd === define.tabDefineCd;
      return isActive ? {
        backgroundColor: "#2ca06f",
        color: "#fafafa"
      } : {};
    }
  },
  async created() {
    const response = await this.getPersonalTabDefine(this.getFacilityCd);
    this.tabDefine = response.data;

    this.main = this.tabDefine[0] ? this.tabDefine[0].contentsId : "";
    this.mode = this.tabDefine[0] ? this.tabDefine[0].mode : "";
    if (this.tabDefine[0]) {
      this.setSelectedTabDefineCd(this.tabDefine[0].tabDefineCd);
    }
  }
};
</script>

<style scoped>
.empty-message {
  margin-left: 2%;
}
.personal-settings-body {
  height: calc(100% - 6px);
   
  overflow-y: hidden;
   
  color: var(--ntss-base-color);
}
/*add FNSI-改修内容4503 任 start*/
/*add FNSI-改修内容4503 任 end*/
.personal-settings-body :deep(.list-header) {
  font-size: inherit;
  display: flex;
  align-items: center;
}
.tab-and-contents-wrapper {
  height: inherit;
  display: grid;
  grid-template-columns: 20% 80%;
  grid-template-rows: 100%;
}
.tab-area {
  float: left;
  border-top: 1px solid #ccc;
  border-right: 1px solid #ccc;
  width: 100%;
  height: 100%;
  overflow-y: auto;
}
.tab-contents-area {
  height: 100%;
}
.tab-button-wrapper {
  border-bottom: 1px solid #ccc;
}
.tab-button {
  display: block;
  background-color: inherit;
  color: var(--ntss-base-color);
  padding: 5px;
  width: 100%;
  height: auto;
  min-height: 5em;
  border: none;
  outline: none;
  text-align: left;
  cursor: pointer;
  transition: 0.3s;
  font-size: unset;
  border-radius: 0;
}
@media screen and (max-width: 480px) {
  .tab-area {
    height: inherit;
  }
  .tab-button-wrapper {
    height: 16em;
  }
  .tab-and-contents-wrapper {
    grid-template-rows: 95%;
  }
}
.tab-area .tab-button-wrapper button:hover {
  background-color: #ddd;
  color: black;
  opacity: 0.75;
}
.tab-area .tab-button-wrapper button.active {
  background-color: #ccc;
}
@media print {
  div :deep(.modal-wrapper){
    display: inline-block !important;
    width: 100%;
  }
}
</style>
