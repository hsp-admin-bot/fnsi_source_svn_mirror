<template>
  <div class="i-hdf"
    v-show="isProgramUseChacked"
    :class="showButton ? 'device-info-container' : null"
  >
    <!--    mod FNSI redmine 4174 劉祥霖 start-->
    <div class="device-info-content" :class="isUnderIndModal">
    <!--      <div class="device-info-content" >-->
    <!--    mod FNSI redmine 4174 end-->
      <!--    mod FNSI redmine 4173 劉祥霖 start-->
      <div class="device-info-content-area" style="min-width: 71em;">
      <!--    mod FNSI redmine 4173 劉祥霖 end-->
        <!-- ヘッダ -->
        <v-ons-row
          v-if="showButton"
          class="common-style-header device-info-main-title"
        >
          Ｉ‐ＨＤＦ
        </v-ons-row>
        <!-- コンポーネント切替 -->
        <!-- タイトル -->
        <v-ons-row class="common-style-header device-info-cell-title">
          使用選択
        </v-ons-row>
        <!-- 項目 -->
        <v-ons-row class="device-info-cell device-info-left">
          <v-ons-col class="device-info-cell-name" width="18em">
            Ｉ‐ＨＤＦプログラム使用選択
          </v-ons-col>
          <v-ons-col class="device-info-cell-value">
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <device-radio -->
            <!--   ref="radio1" -->
            <!--   :device-info="radioItems" -->
            <!--   :disabled="isThisTreatRecord" -->
            <!--   @change="onRadioClick" -->
            <!-- /> -->
            <device-radio
              ref="radio1"
              :device-info="radioItems"
              :disabled="isThisTreatRecord || !getItemAuthorized('Indication', 'default_authority') || isOtherFacilityRow()"
              @change="onRadioClick"
            />
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
          </v-ons-col>
        </v-ons-row>
        <div>
          <!-- Ｉ‐ＨＤＦ -->
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <i-hdf -->
          <!--   v-if="isIhdfMain" -->
          <!--   ref="ihdfEditor" -->
          <!--   :ord-no="ordNo" -->
          <!--   :facility-cd="facilityCd" -->
          <!--   :data-source-type="dataSourceType" -->
          <!--   v-model:is-ihdf-main="isIhdfMain" -->
          <!--   v-model:is-program-use-chacked="isProgramUseChacked" -->
          <!--   :show-button="showButton" -->
          <!--   @save-edit="saveEdit" -->
          <!--   @close="closeModal()" -->
          <!--   @init-radio="initRadio" -->
          <!--   @change-radio="changeRadio" -->
          <!-- /> -->
          <!-- #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start -->
          <!-- <i-hdf
            v-if="isIhdfMain"
            ref="ihdfEditor"
            :ord-no="ordNo"
            :facility-cd="facilityCd"
            :data-source-type="dataSourceType"
            v-model:is-ihdf-main="isIhdfMain"
            v-model:is-program-use-chacked="isProgramUseChacked"
            :show-button="showButton"
            @save-edit="saveEdit"
            @close="closeModal()"
            @init-radio="initRadio"
            @change-radio="changeRadio"
            :is-mst="isMst"
          /> -->
          <i-hdf
            v-if="isIhdfMain"
            ref="ihdfEditor"
            :key="refreshIhdfKey"
            :ord-no="ordNo"
            :facility-cd="facilityCd"
            :data-source-type="dataSourceType"
            v-model:is-ihdf-main="isIhdfMain"
            v-model:is-program-use-chacked="isProgramUseChacked"
            :show-button="showButton"
            @save-edit="saveEdit"
            @close="closeModal()"
            @init-radio="initRadio"
            @change-radio="changeRadio"
            @change-start-date="changeStartDate"
            :is-mst="isMst"
          />
          <!-- #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end -->
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <!-- Ｉ‐ＨＤＦプログラム -->
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <i-hdf-program -->
          <!--   v-else -->
          <!--   ref="ihdfProgramEditor" -->
          <!--   :ord-no="ordNo" -->
          <!--   :facility-cd="facilityCd" -->
          <!--   :data-source-type="dataSourceType" -->
          <!--   v-model:is-ihdf-main="isIhdfMain" -->
          <!--   v-model:is-program-use-chacked="isProgramUseChacked" -->
          <!--   :show-button="showButton" -->
          <!--   @save-edit="saveEdit" -->
          <!--   @close="closeModal()" -->
          <!--   @init-radio="initRadio" -->
          <!--   @change-radio="changeRadio" -->
          <!-- /> -->
          <!-- #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start -->
          <!-- <i-hdf-program
            v-else
            ref="ihdfProgramEditor"
            :ord-no="ordNo"
            :facility-cd="facilityCd"
            :data-source-type="dataSourceType"
            v-model:is-ihdf-main="isIhdfMain"
            v-model:is-program-use-chacked="isProgramUseChacked"
            :show-button="showButton"
            @save-edit="saveEdit"
            @close="closeModal()"
            @init-radio="initRadio"
            @change-radio="changeRadio"
            :is-mst="isMst"
          /> -->
          <i-hdf-program
            v-else
            ref="ihdfProgramEditor"
            :key="refreshIhdfProgramEditorKey"
            :ord-no="ordNo"
            :facility-cd="facilityCd"
            :data-source-type="dataSourceType"
            v-model:is-ihdf-main="isIhdfMain"
            v-model:is-program-use-chacked="isProgramUseChacked"
            :show-button="showButton"
            @save-edit="saveEdit"
            @close="closeModal()"
            @init-radio="initRadio"
            @change-radio="changeRadio"
            @change-start-date="changeStartDate"
            :is-mst="isMst"
          />
          <!-- #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end -->
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
        </div>
      </div>
    </div>
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import {mapActions, mapGetters} from "@/compat/vue/vuex";
import iHdf from "@/components/deviceset-info/i-hdf/IHdfEditor.vue";
import iHdfProgram from "@/components/deviceset-info/i-hdf/IHdfProgramEditor.vue";
import { DATA_SOURCE_TYPE_ORD } from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
import deviceRadio from "@/components/deviceset-info/base-modules/DeviceSetInfoRadio.vue";
import { EventBus } from "@/compat/vue/event-bus.js";

import DeviceSetOwnerMixin from '@/components/deviceset-info/base-modules/DeviceSetOwnerMixin';
import { getModalBodyElement, getScopedElementById, getFirstElementByClassName } from '@/functions/common/LayoutMeasureHelper';
/**
 * @description I-HDF設定値編集画面
 */
export default {
  mixins: [DeviceSetOwnerMixin],
  components: {
    "device-radio": deviceRadio,
    "i-hdf": iHdf,
    "i-hdf-program": iHdfProgram
  },

  props: {
    // add #10359 編集権限の動作不正 dengshen start
    isMst: {
      type: Boolean,
      default: false
    },
    // add #10359 編集権限の動作不正 dengshen end
    dataSourceType: {
      type: Number,
      required: true
    },

    facilityCd: {
      type: String,
      default: null
    },

    ordNo: {
      type: Number,
      default: null
    },

    // キャンセル・保存ボタン表示用
    showButton: {
      type: Boolean,
      default: true
    }
  },

  data() {
    return {
      // コンポーネント切替フラグ
      isIhdfMain: true,
      // 画面表示フラグ ※子コンポーネントで使用選択状態を確認
      isProgramUseChacked: false,
      /**
       * 参照元で画面更新を行うかどうかのフラグ
       * @summary 更新を行うかどうかは参照元画面で判断
       */
      isRefresh: false,
      // コンポーネント切り替えラジオボタン用変数
      isRadioProgramUseChecked: {
        initValue: null,
        editValue: null
      },
      isThisTreatRecord: false,

      //add FNSI redmine 4174 劉祥霖 start
      contentHeight: "300px",
      //add FNSI redmine 4174 劉祥霖 end
      isUnderIndModal: "",
      // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start
      refreshIhdfKey: 0,
      refreshIhdfProgramEditorKey: 0,
      // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end
    };
  },

  computed: {
    ...mapGetters("pat-viewer-modal", ["getSettingIndChildData"]),
    ...mapGetters("master-maintenance", ["getMasterName"]),
    ...mapGetters("account-edit", ["getFontSize"]),
    ...mapGetters("user", ["getFacilityCd"]),

    /**
     * コンポーネント切り替えラジオボタン用
     */
    radioItems() {
      return {
        value: this.isRadioProgramUseChecked,
        formName: "ihdfProUse",
        options: [
          {
            radioValue: 'false',
            displayString: "使用しない"

          },
          {
            radioValue: 'true',
            displayString: "使用する"
          }
        ]
      }
    }
  },
  //add FNSI redmine 4174 劉祥霖 start
  mounted() {
    this.$nextTick(() => {
      this.calculateGridSize();
      // 患者経過総合ビューアで表示している時は、画面が小さい時のスタイル用classを付与する
      const indObj = getFirstElementByClassName("indInfo-style-modal-container", this.$el || this);
      if (indObj) {
        this.isUnderIndModal = "ind-style-media-query";
      }
    });
  },
  //add FNSI redmine 4174 劉祥霖 end
  created() {
    if (this.dataSourceType === DATA_SOURCE_TYPE_ORD) {
      // 親のスタイル修正
      this._deviceSetDialogOwner().styleObj = { "max-width": "1050px", width: "100%" };
    }
    // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start
    this.setIhdfAnswerThreeDevA(null);
    // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end
    this.setDialysisTimeData(null);
  },

  methods: {
    ...mapActions('loading-screen', [
      "startLoadingScreen",
      "finishLoadingScreen"
    ]),
    // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start
    ...mapActions('pat-viewer-modal', ["setIhdfAnswerThreeDevA","setDialysisTimeData"]),
    // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end
    isOtherFacilityRow() {
      if (!this.getSettingIndChildData) {
        return false;
      }
      return this.getSettingIndChildData.facilityCd
        ? this.getSettingIndChildData.facilityCd !== this.getFacilityCd
        : false;
    },
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return this.isMst || (this.isMst != true && getAuthorized(pageCd, itemCd));
    },
    // add #10359 編集権限の動作不正 dengshen end
    /**
     * @description モーダルを閉じる
     */
    closeModal() {
      // refの中をループ
      for (const refs in this.$refs) {
        // refの中にObjectが存在すれば次の処理へ
        if (this.$refs[refs]) {
          // 更新フラグがONの場合
          if (this.$refs[refs].isRefresh) {
            // 更新フラグをOFFに戻す
            this.$refs[refs].isRefresh = false;
            this.isRefresh = true;
          }
        }
      }
      // 装置設定一覧の表示フラグを折る
      this.$emit("close");
    },

    //add FNSI redmine 4174 劉祥霖 start
    // ウインドウ変更時、幅を調整
    calculateGridSize(){
      const mb = getModalBodyElement(this.$el || this)?.offsetHeight || 0;
      const IBH = getFirstElementByClassName("IndBaseHeader", this.$el || this)?.offsetHeight || 0;
      const ch=mb-IBH-10;
      this.contentHeight =ch+"px" ;

      if(this.getMasterName == "mst_treatment_set" && getScopedElementById("grid-header", this.$el || this) != null){
        this.contentHeight =""
      }
    },
    //add FNSI redmine 4174 劉祥霖 end

    /**
     * @description 編集有無確認
     * @returns {Boolean}
     *   成功: モーダル表示
     *   失敗: モーダル非表示
     */
    checkEdit(num) {
      if (num === 1) {
        // キャンセルボタンクリック時チェック
        this.$refs.ihdfEditor === undefined
          ? this.$refs.ihdfProgramEditor.cancelConfirm()
          : this.$refs.ihdfEditor.cancelConfirm();
        // cancelConfirm関数(子)でモーダルの表示非表示を行うため、ベース(親)では何も処理しない
        return true;
      }
    },

    /**
     * 更新処理(指示)
     * @description 親からこの関数を呼んで更新処理を行う
     */
    updateIndInfo(structData) {
      console.log("IHdfMain.vue updateIndInfo this.startLoadingScreen();");
      this.startLoadingScreen();
      // 治療情報更新
      if (this.getSettingIndChildData.isAllSave) {
        // 一括更新
        this.$refs.ihdfEditor === undefined
          ? this.$refs.ihdfProgramEditor.save(structData)
          : this.$refs.ihdfEditor.save(structData);
      } else {
        this.$refs.ihdfEditor === undefined
          ? this.$refs.ihdfProgramEditor.ordMainAllSave(structData)
          : this.$refs.ihdfEditor.ordMainAllSave(structData);
      }
      console.log("IHdfMain.vue updateIndInfo this.finishLoadingScreen();");
      this.finishLoadingScreen();
    },

    /**
     * @description メッセージ確認後保存ボタン活性へ
     */
    saveEdit() {
      // 保存ボタン活性へ
      this._deviceSetDialogOwner().updateDisable = false;

      EventBus.$emit("deviceSetChanged");
    },

    /**
     * @description 画面切り替え確認
     */
    changeDisplayConfirm(key, boolean) {
      // #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start
      // if (this.$refs[key].isEdited()) {
      if (this.$refs[key].isEdited('ihdfMain')) {
      // #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end
        // 編集されている場合は装置設定コンポーネントにキャンセル確認ダイアログを表示させる
        this.$refs[key].showChangeDisplayDialog();
      } else {
        // 画面を切り替える
        this.isIhdfMain = boolean;
      }
    },

    /**
     * @description キャンセル確認
     */
    cancelConfirm() {
      if (this.isIhdfMain) {
        this.$refs.ihdfEditor.cancelConfirm();
      } else {
        this.$refs.ihdfProgramEditor.cancelConfirm();
      }
    },

    /**
     * @description 保存ボタン処理
     */
    async save() {
      if (this.isIhdfMain) {
        await this.$refs.ihdfEditor.save();
      } else {
        await this.$refs.ihdfProgramEditor.save();
      }
    },
    /**
     * @description 子コンポーネントの初期化時に呼び出される切り替えラジオボタン用初期値設定
     */
    initRadio(context) {
      this.isRadioProgramUseChecked = {
        initValue: context.initVal,
        editValue: context.editVal
      };
      this.isThisTreatRecord = context.isTreatRecord;
    },
    /**
     * @description 切り替えラジオボタンクリック時のコンポーネント切り替え処理
     */
    onRadioClick() {
      // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定 20240220 ztc start
      EventBus.$emit("deviceSetChanged", this.isRadioProgramUseChecked.initValue !== this.isRadioProgramUseChecked.editValue);
      EventBus.$emit("mstTreatmentSetRegistered", this.isRadioProgramUseChecked.initValue === this.isRadioProgramUseChecked.editValue);
      this._deviceSetRootOwner().ihdfChangeFlag = this.isRadioProgramUseChecked.initValue !== this.isRadioProgramUseChecked.editValue;
      // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定 20240220 ztc end
      if (this.isRadioProgramUseChecked.editValue.toString() == 'true') {
        this.changeDisplayConfirm('ihdfEditor', false);
      } else {
        this.changeDisplayConfirm('ihdfProgramEditor', true);
      }
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア_I-HDF設定 20240123 ztc start
      // EventBus.$emit( "mstTreatmentSetRegistered", false);

      // EventBus.$emit("deviceSetChanged");
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア_I-HDF設定 20240123 ztc end
      // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start
      this.setIhdfAnswerThreeDevA(null);
      // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end
    },
    /**
     * @description 切り替えラジオボタンを子コンポーネントから操作するための関数
     */
    changeRadio(val) {
      this.isRadioProgramUseChecked.editValue = val;
      // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定 20240220 ztc start
      EventBus.$emit("deviceSetChanged",this.isRadioProgramUseChecked.initValue !== this.isRadioProgramUseChecked.editValue);
      EventBus.$emit("mstTreatmentSetRegistered", this.isRadioProgramUseChecked.initValue === this.isRadioProgramUseChecked.editValue);
      this._deviceSetRootOwner().ihdfChangeFlag = this.isRadioProgramUseChecked.initValue !== this.isRadioProgramUseChecked.editValue;
      // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定 20240220 ztc end
    },
    // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng start
    changeStartDate(devA, answer) {
      this.setIhdfAnswerThreeDevA(answer === 3 ? devA : null);
      let val = devA[432];
      this.isIhdfMain = val != "1" ? true : false;
      this.isRadioProgramUseChecked.editValue = val == "1" ? true : false;
      this.isRadioProgramUseChecked.initValue = this.isRadioProgramUseChecked.editValue
      if (this.isIhdfMain) {
        this.refreshIhdfKey++;
      } else {
        this.refreshIhdfProgramEditorKey++;
      }
    },
    // add #11120 I-HDF設定内の破棄確認メッセージ不正 linjunfeng end

    /**
     * @description 保存ボタン処理（DeviceSetInfoModalから呼び出し対応）
     */
    async saveConfirm() {
      if (this.isIhdfMain) {
        await this.$refs.ihdfEditor.saveConfirm();
      } else {
        await this.$refs.ihdfProgramEditor.saveConfirm();
      }
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
    isEdit() {
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定 20240220 ztc start
      // return this.isIhdfMain ? this.$refs.ihdfEditor?.isEdit() : true;
      return this.isIhdfMain ? this.$refs.ihdfEditor?.isEdit() : this.$refs.ihdfProgramEditor?.isEdit();
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_装置設定 20240220 ztc end
    }
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
  }
};
</script>

<style src="../base-modules/BeseDeviceSetInfoStyle.css" scoped></style>
<style scoped>
.device-info-content {
  max-width: 1050px;
  max-height: 740px;
  white-space: nowrap;
}

/** iPhone X/8/7/6 or Android(M,L) */
/** Device Width:360-480           */
/** ボックス要素-スクロール制御 */
@media only screen and (min-device-width:360px) and (max-device-width:480px) {
  .ind-style-media-query {
    overflow-x: auto;
    overflow-y: hidden;
    -webkit-overflow-scrolling:auto;
    overscroll-behavior-y: auto;
  }
}

@media only screen and (min-device-width:376px) and (max-device-width:667px) {
  .device-info-content-area {
    width: 130%;
  }
}

@media only screen and (max-height:530px) {
  .ind-style-media-query {
    overflow-x: auto;
    overflow-y: hidden;
    -webkit-overflow-scrolling:auto;
    overscroll-behavior-y: auto;
  }
}

.device-info-main-title {
  border: none;
}

.device-info-main-sab-title {
  border: solid 1px var(--ntss-border-color);
  border-bottom: none;
  padding: 3px 5px;
}

.background-color {
  background-color: orange;
}

@media print {
  .device-info-content-area {
    min-width: 0 !important;
  }
}
</style>
