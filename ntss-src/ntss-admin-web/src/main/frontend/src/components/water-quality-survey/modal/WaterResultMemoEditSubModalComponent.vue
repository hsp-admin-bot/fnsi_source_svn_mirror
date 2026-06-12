/**
 * 水質検査結果備考登録モーダル
 */
<template>
  <modal-base @onClose="cancel">
    <template #body>
      <div id="water-modal-content" class="main-content">
      <div class="water-option">
        <v-ons-row class="input-row">
          <v-ons-col class="input-item-name">
            <label>メモ</label>
          </v-ons-col>
          <v-ons-col class="input-item-txt">
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="input-row">
          <v-ons-col class="input-item-textarea">
            <!-- mod  FNSI-権限 徐 start -->
            <!-- <com-textarea
              cssClass="water-textare textarea textarea--transparent textarea-resize-vertical"
              propMaxlength="256"
              idTextarea="com-textarea-memo"
              :content="this.surveyRecordForMemo.memo"
              @set-content-data="setContentData"
            /> -->
            <!-- mod FNSI-改修内容6512修正 xuty start -->
            <!-- <com-textarea
              cssClass="water-textare textarea textarea--transparent textarea-resize-vertical"
              propMaxlength="256"
              idTextarea="com-textarea-memo"
              :content="this.surveyRecordForMemo.memo"
              :disabled="!hasTreatmentRecordAuthority"
              @set-content-data="setContentData"
            /> -->
            <com-textarea
              cssClass="water-textare textarea textarea--transparent textarea-resize-vertical"
              propMaxlength="256"
              idTextarea="com-textarea-memo"
              :content="this.surveyRecordForMemo.memo"
              :disabled="!hasTreatmentRecordAuthority"
              @set-content-data="setContentData"
              @change="changeTextarea"
            />
            <!-- mod FNSI-改修内容6512修正 xuty end -->
            <!-- mod  FNSI-権限 徐 end -->
          </v-ons-col>
        </v-ons-row>
          </div>
      </div>
    </template>
    <template #footer>
      <div class="flex-container">
        <div class="denial-btn-area" style="background:none">
        <!-- mod 画面スタイル(ボタン)対応 徐 start -->
        <!-- <button class="button denial-btn" @click="cancel">キャンセル</button> -->
        <button class="button btn2-cancel" @click="cancel">キャンセル</button>
        <!-- mod 画面スタイル(ボタン)対応 徐 end -->
      </div>
        <div class="registration-btn-area" style="background:none">
        <!-- mod  FNSI-権限 徐 start -->
        <!-- <button class="button registration-btn" @click="reflect">確定</button> -->
        <!-- mod 画面スタイル(ボタン)対応 徐 start -->
        <!-- <button class="button registration-btn" :disabled="!hasTreatmentRecordAuthority" @click="reflect">確定</button> -->
<!--        mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start-->
<!--        <button class="button registration-btn btn3-normal" :disabled="!hasTreatmentRecordAuthority" @click="reflect">確定</button>-->
        <button class="button registration-btn btn3-normal" :disabled="!hasTreatmentRecordAuthority || !isChanged" @click="reflect">確定</button>
<!--        mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end-->
        <!-- mod 画面スタイル(ボタン)対応 徐 end -->
        <!-- mod  FNSI-権限 徐 end -->
        </div>
      </div>
    </template>
  </modal-base>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import SubModalBase from "@/components/modals/SubModalBase";
import MultiSubModalMixin from "@/components/modals/MultiSubModalMixin";
import { EventBus } from "@/compat/vue/event-bus.js";
import CommonTextArea from "@/components/common/CommonTextArea";
// add  FNSI-権限 徐 start
import PopoverMixin from "@/components/PopoverMixin";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
// add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import {messageFormat} from "@/functions/common/MessageFormat";
// add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end
// add  FNSI-権限 徐 end

export default {
  // mod  FNSI-権限 姜 start
  // mixinの読込
  // mixins: [MultiSubModalMixin],
  mixins: [MultiSubModalMixin, PopoverMixin, ComponentGuardMixin],
  // mod  FNSI-権限 姜 end

  components: {
    "modal-base": SubModalBase,
    "com-textarea": CommonTextArea
  },

  data() {
    return {
      // add  FNSI-権限 徐 start
      // 権限を有無する
      hasTreatmentRecordAuthority: false,
      // add  FNSI-権限 徐 end 
      // add FNSI-改修内容6512修正 xuty start
      changeFlg:false,
      // add FNSI-改修内容6512修正 xuty end
      surveyMemo: {
        memo: "",
        index: -1
      },
      // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start
      initSurveyMemo: null
      // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end
    };
  },

  methods: {
    ...mapActions("multi-sub-modal", ["showWaterResultMemoEditSubModal"]),
    // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start
    ...mapActions("water-quality-survey/result", ["setSurveyRecordForMemo","setSurveyRecordBySurveyMemo"]),
    // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end
    // add  FNSI-権限 徐 start
    getTreatmentRecordAuthority() {
      return this.hasAuthorityByCd(AUTHORITY_CODES.DEV_PEDIT) || this.hasAuthorityByCd(AUTHORITY_CODES.DEV_EDIT);
    },
    
    // add  FNSI-権限 徐 end 
    /**
     * 初期処理
     */
    async init() {
      this.surveyMemo = this.surveyRecordForMemo;
      // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start
      this.initSurveyMemo = JSON.parse(JSON.stringify(this.surveyMemo));
      // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end
    },

    /**
     * キャンセルボタン押下時イベント処理
     */
    cancel() {
      // モーダルを閉じる.
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start
      if(this.isChanged){
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: answer => {
            if (answer === 1) {
              this.hideModal();
            }
          }
        });
      }else{
        this.hideModal();
      }
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end
    },

    /**
     * 確定ボタン押下時イベント処理
     * ※呼出元の`applyWaterResultMemoEditSubModal`を呼びだします.
     */
    reflect() {
      // 行選択イベントにて選択された水質検査結果は格納済なので、
      // 確定ボタン押下時の処理はモーダルを閉じるのみ.
      // add FNSI-改修内容6512修正 xuty start
      if (this.changeFlg) {
        EventBus.$emit("applyWaterResultMemoEditSubModalChange");
      } else {
      // add FNSI-改修内容6512修正 xuty end
      EventBus.$emit("applyWaterResultMemoEditSubModal");
      // add FNSI-改修内容6512修正 xuty start
      }
      // add FNSI-改修内容6512修正 xuty end
      // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start
      this.setSurveyRecordBySurveyMemo(this.surveyMemo);
      // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end
      this.hideModal();
    },
    // mod FNSI-改修内容6512修正 xuty start
    changeTextarea() {
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start
      // this.changeFlg = true;
      this.changeFlg = this.isChanged;
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end
    },
    // mod FNSI-改修内容6512修正 xuty end
    setContentData(newValue) {
      this.surveyMemo.memo = newValue;
      this.setSurveyRecordForMemo(this.surveyMemo);
    }
  },

  /**
   * computed
   */
  computed: {
    // 水質検査結果備考登録モーダルStore
    ...mapGetters("water-quality-survey/result", ["surveyRecordForMemo",]),
    // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start
    isChanged(){
      return JSON.stringify(this.initSurveyMemo) !== JSON.stringify(this.surveyMemo);
    }
    // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end
  },
  
  /**
   * created
   */
  async created() {
    // 初期処理
    await this.init();
    // add  FNSI-権限 徐 start
    this.hasTreatmentRecordAuthority = this.getTreatmentRecordAuthority();
    // add  FNSI-権限 徐 end 
  }
}
</script>

<style scoped>
div :deep(.water-textare) {
  height: 350px;
}
#water-modal-content {
  padding-left: 20px;
}
.water-option {
  border: solid 1px rgb(150, 150, 150);
  border-radius: 5px;
  padding: 10px 20px 20px 20px;
  margin-top: 10px;
  margin-bottom: 20px;
  margin-right: 20px;
}
.modal-scroll {
  overflow-x: hidden;
  overflow-y: scroll;
}
.input-row {
  margin-bottom: 5px;
}
.input-row-header {
  margin-bottom: 10px;
  padding-bottom: 5px;
  border-bottom: 1px solid #bbb;
}
div :deep(textarea) {
  width: 100%;
  border: solid 1px rgb(150, 150, 150);
  min-height: 10em;
  resize: both;
}
div :deep(textarea:focus) {
  border: 2px green solid;
}
.input-item-name {
  font-weight: bold;
  margin-top: 10px;
  max-width: 15%;
}
.input-item-check {
  font-weight: bold;
  margin-top: 10px;
  max-width: 3%;
}
.input-item-check-name {
  font-weight: bold;
  margin-top: 10px;
  max-width: 15%;
}
.input-item-txt {
  max-width: 40%;
}
.input-item-txt-long {
  max-width: 70%;
}
.input-item-textarea {
  max-width: 100%;
}
.input-item-textarea :deep(.textarea) {
  font-size: unset;
}
.input-item-num {
  max-width: 15%;
}
@media screen and (max-width: 1024px) {
  .input-item-name {
    text-align: left;
    font-weight: bold;
    margin-bottom: 5px;
    min-width: 90%;
  }
  .input-item-check {
    text-align: left;
    font-weight: bold;
    margin-bottom: 5px;
    max-width: 15%;
  }
  .input-item-check-name {
    text-align: left;
    font-weight: bold;
    margin-bottom: 5px;
    min-width: 50%;
  }
  .input-item-txt {
    min-width: 90%;
  }
  .input-item-txt-long {
    text-align: left;
    min-width: 90%;
  }
  .input-item-num {
    min-width: 40%;
  }
  .input-item-margin {
    display: none;
  }
}
textarea:focus {
  border: 2px green solid;
  outline: 0;
}
</style>
