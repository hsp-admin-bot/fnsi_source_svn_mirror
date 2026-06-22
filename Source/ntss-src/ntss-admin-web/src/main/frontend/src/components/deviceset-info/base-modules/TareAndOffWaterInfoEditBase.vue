/** 風袋・除水補正 */
/** ホスト報知ダイアログも同様の処理の為利用 */
<template>
  <modal-base @onClose="hideModal">
    <template #body>
      <div class="table-content">
      <div v-if="showButton" class="header-style color-header">
        <label>{{ headerTitle }}</label>
      </div>

      <div><slot></slot></div>

      <div v-if="messageDialogInfo.isDialogVisible">
        <message-dialog
          v-model:visible="messageDialogInfo.isDialogVisible"
          :message-cd="messageDialogInfo.messageCd"
          :type="messageDialogInfo.type"
          :string-params="messageDialogInfo.stringParams"
          @confirm="confirmResult"
        />
      </div>
      </div>
    </template>

    <template #footer>
      <v-ons-row class="button-area">
      <v-ons-col>
        <v-ons-button
          class="btn2-cancel common-style-cancel-button"
          style="float: left;"
          @click="hideModal"
        >
          <template v-if="isTreat">
            閉じる
          </template>
          <template v-else>
            キャンセル
          </template>
        </v-ons-button>
      </v-ons-col>
      <v-ons-col>
        <!-- mod FNSI-改修内容 権限関連 趙慧敏 start -->
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <v-ons-button -->
        <!--   v-if="!isTreat" -->
        <!--   class="btn1-execute common-style-ok-button" -->
        <!--   style="float: right;" -->
        <!--   :disabled="!(hasDevicesetInfoAuthority && isDeviceSetChanged)" -->
        <!--   @click="updateInfo" -->
        <!-- > -->
        <!-- mod #10359_NG対応 編集権限の動作不正 dengshen start -->
        <!-- <v-ons-button -->
        <!--   v-if="!isTreat" -->
        <!--   class="btn1-execute common-style-ok-button" -->
        <!--   style="float: right;" -->
        <!--   :disabled="!(getItemAuthorized('DevicesetInfo', 'default_authority') && isDeviceSetChanged)" -->
        <!--   @click="updateInfo" -->
        <!-- > -->
        <v-ons-button
          v-if="!isTreat"
          class="btn1-execute common-style-ok-button"
          style="float: right;"
          :disabled="!(getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') && isDeviceSetChanged)"
          @click="updateInfo"
        >
        <!-- mod #10359_NG対応 編集権限の動作不正 dengshen end -->
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
import { resolveDefaultSlotComponent } from "@/compat/vue/slots";
  // add #10359 編集権限の動作不正 dengshen start
  import { getAuthorized } from "@/functions/common/CommonFunctions.js";
  // add #10359 編集権限の動作不正 dengshen end
  import messageDialog from "@/components/common/message-dialog/MessageDialog";
  import ModalBase from "@/components/modals/ModalBase";
  // add FNSI-改修内容 権限関連 趙慧敏 start
  import {mapActions, mapGetters} from "@/compat/vue/vuex";
  // del #10359 編集権限の動作不正 dengshen start
  // import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
  // del #10359 編集権限の動作不正 dengshen end
  import {DATA_SOURCE_TYPE_PAT} from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
  // add FNSI-改修内容 権限関連 趙慧敏 end
  // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
  import { EventBus } from "@/compat/vue/event-bus.js";
  // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end

export default {
  components: {
    "message-dialog": messageDialog,
    ModalBase
  },

  props: {
    headerTitle: {
      required: true,
      type: String
    },

    isTreat: {
      type: Boolean,
      default: false
    },

    // キャンセル・保存ボタン表示用
    showButton: {
      type: Boolean,
      default: true
    },

    resolveEditorComponent: {
      type: Function,
      default: null
    }
  },
  // del #10359 編集権限の動作不正 dengshen start
  // // add FNSI-改修内容 権限関連 趙慧敏 start
  // mixins: [ComponentGuardMixin],
  // // add FNSI-改修内容 権限関連 趙慧敏 end
  // del #10359 編集権限の動作不正 dengshen end

  data() {
    return {
      // メッセージダイアログ情報
      messageDialogInfo: {
        isDialogVisible: false,
        messageCd: null,
        type: null,
        stringParams: [],
        targetName: null,
      },
      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
      isDeviceSetChanged: false,
      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
      // add FNSI-改修内容 権限関連 趙慧敏 start
      // del #10359 編集権限の動作不正 dengshen start
      // authorityCds: [
      //   AUTHORITY_CODES.PAT_PEDIT,  // 患者情報-代行編集
      //   AUTHORITY_CODES.PAT_EDIT    // 患者情報-編集
      // ],
      // hasDevicesetInfoAuthority: false,
      // del #10359 編集権限の動作不正 dengshen end
      isPat: false
      // add FNSI-改修内容 権限関連 趙慧敏 end
    };
  },
  // add FNSI-改修内容 権限関連 趙慧敏 start
  computed: {
    ...mapGetters("device-set-info-modal", {
      selectedDeviceSetSrcType: "getSelectedDeviceSetSrcType"
    }),
  },

  async created() {
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    EventBus.$off("deviceSetChanged", this.setDeviceSetChanged);
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
    // del #10359 編集権限の動作不正 dengshen start
    // this.hasDevicesetInfoAuthority = this.getDevicesetInfoAuthority();
    // del #10359 編集権限の動作不正 dengshen end
    if (this.selectedDeviceSetSrcType === DATA_SOURCE_TYPE_PAT){
       this.isPat = true;
    }

    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    EventBus.$on("deviceSetChanged", this.setDeviceSetChanged);
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
  },
  // add FNSI-改修内容 権限関連 趙慧敏 end

  methods: {
    getDefaultSlotComponent() {
      const resolvedEditor = typeof this.resolveEditorComponent === "function"
        ? this.resolveEditorComponent()
        : null;
      return resolvedEditor || resolveDefaultSlotComponent(this);
    },
    /*add FNSI-改修内容6025 任 start*/
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage"
    }),
    /*add FNSI-改修内容6025 任 end*/
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定 20231227 ztc start
    // setDeviceSetChanged() {
    setDeviceSetChanged(editFlg) {
      if(editFlg === null || editFlg === undefined){
        editFlg = true;
      }
      // this.isDeviceSetChanged = true;
      this.isDeviceSetChanged = editFlg;
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定 20231227 ztc end
    },
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
    /**
     * モーダルを閉じる
     */
    hideModal() {
      // 変更箇所があればメッセージ表示
      const editorComponent = this.getDefaultSlotComponent();
      if (editorComponent?.checkEdit?.(1)) {
        return;
      }
      this.$emit("hide-modal");
    },

    /**
     * 更新処理
     */
    updateInfo() {
      const editorComponent = this.getDefaultSlotComponent();
      editorComponent?.updateInfo?.();
    },

    /**
     * メッセージダイアログ確認結果
     */
    async confirmResult(answer) {
      switch (this.messageDialogInfo.messageCd) {
        // メッセージ内容「編集中の情報が破棄されます キャンセルしてよろしいですか？」
        case 20010001:
          if ("OK" === answer) {
            // モーダルを閉じる
            this.$emit("hide-modal");
          }
          break;

        // 装置設定デフォルトマスタの風袋・除水補正を変更後、患者情報にも反映をするどうか
        case 13010003:
        case 13010004:
          if ("No" === answer) {
            // 患者情報に反映
            this.getDefaultSlotComponent()?.reflectPatInfo?.();
          }
          // モーダルを閉じる
          this.$emit("hide-modal");
          break;

        // 装置設定デフォルトマスタのホスト報知設定を変更後、患者情報にも反映をするどうか
        case 13010005:
          if ("No" === answer) {
            // 患者情報に反映
            this.getDefaultSlotComponent()?.reflectPatInfo?.();
          }
          // モーダルを閉じる
          this.$emit("hide-modal");
          break;

        case 13010001:
          switch (this.messageDialogInfo.targetName) {
            // 未来指示へ反映するか確認時
            case "FUTURE_ORD_MAIN":
              if ("OK" === answer) {
                /*add FNSI-改修内容6025 任 start*/
                this.setLoadingScreenMessage();
                this.setLoadingScreenVisible(true);
                /*add FNSI-改修内容6025 任 end*/
                // 未来指示への反映処理
                // mod #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao start
                await this.getDefaultSlotComponent()?.reflectFutureOrdMain?.();
                // mod #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao end
                // 反映対象治療情報への反映確認メッセージ表示
                this.getDefaultSlotComponent()?.showReflectIndInfoMessage?.();
                // mod #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao start
                // /*add FNSI-改修内容6025 任 start*/
                // setTimeout(() => {
                //   this.setLoadingScreenVisible(false);
                // },1000)
                // /*add FNSI-改修内容6025 任 end*/
                this.setLoadingScreenVisible(false);
                // mod #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao end
              } else {
                // 反映対象治療情報への更新処理
                this.getDefaultSlotComponent()?.showReflectIndInfoMessage?.();
                // del #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao start
                // // add FNSI 1006 No.538 外部連携APIを呼び出 陳 start
                // this.getDefaultSlotComponent().doCreateJournal();
                // // add FNSI 1006 No.538 外部連携APIを呼び出 陳 end
                // del #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao end
              }
              break;

            // 更新対象の治療情報に反映をするか確認時
            case "TARGET_ORD_MAIN":
              if ("OK" === answer) {
                // 更新対象への反映処理
                this.getDefaultSlotComponent()?.reflectIndInfo?.();
                // 警告メッセージ表示
                this.getDefaultSlotComponent()?.showAlertIndInfoMessage?.();
              } else {
                // 警告メッセージ表示
                this.getDefaultSlotComponent()?.showAlertIndInfoMessage?.();
              }
              break;

            default:
              break;
          }
          // add #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao start
          // モーダルを閉じる
          this.$emit("hide-modal");
          // add #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao end
          break;

        case 23010002:
          // モーダルを閉じる
          this.hideModal();
          break;

        default:
          break;
      }
    },
    // add FNSI-改修内容 権限関連 趙慧敏 start
    // del #10359 編集権限の動作不正 dengshen start
    // getDevicesetInfoAuthority() {
    //   return this.hasAuthorityByCd(AUTHORITY_CODES.PAT_PEDIT) || this.hasAuthorityByCd(AUTHORITY_CODES.PAT_EDIT);
    // }
    // del #10359 編集権限の動作不正 dengshen end
    // add FNSI-改修内容 権限関連 趙慧敏 end
  }
};
</script>

<style scoped>
.table-content {
  padding: 2%;
  width: 100%;
  margin: auto;
  box-sizing: border-box;
  padding: 5px;
  background: var(--ntss-base-background-color);
  text-align: left;
}

.header-style {
  text-align: left;
  padding: 3px;
  font-size: 15px;
}

.button-area {
  padding: 10px;
}
</style>
