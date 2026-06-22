/** * モーダル関連コンポーネント */
<template>
  <!-- 指示ベース -->
  <ind-edit-base
    v-if="isShowIndModal"
    ref="refIndEditBase"
    :setting-data="settingIndData"
    :component-id="dispComponentId"
    @hide-modal="
      hideIndModal();
      postHideModal();
    "
  >
    <component
      :is="dispComponentId"
      :ind-start-date="settingIndData.startDate"
      ref="refIndEditBaseSlot"
      v-bind="settingIndChildData"
    />
  </ind-edit-base>

  <!-- 治療予定コピー -->
  <ind-plan-copy
    v-else-if="isShowPlanCopy"
    ref="refPlanCopy"
    v-bind="settingIndData"
    @hide-modal="
      hideIndModal();
      postHideModal();
    "
  />

  <!-- 治療予定移動 -->
  <ind-plan-move
    v-else-if="isShowPlanMove"
    ref="refPlanMove"
    v-bind="settingIndData"
    @hide-modal="
      hideIndModal();
      postHideModal();
    "
  />

  <!-- 曜日パターン変更 -->
  <ind-week-pattern
    v-else-if="isShowWeekPattern"
    ref="refWeekPattern"
    v-bind="settingIndData"
    @hide-modal="
      hideIndModal();
      postHideModal();
    "
  />

  <!-- 投与薬剤新規登録 -->
  <ind-medi-base
    v-else-if="isShowIndMedicineCreateModal"
    ref="refIndMediCreateBase"
    :show-new-edit="false"
    :setting-data="settingIndData"
    @hide-modal="
      hideIndModal();
      postHideModal();
    "
  >
    <component :is="dispComponentId" v-bind="settingIndData" />
  </ind-medi-base>

  <!-- 投与薬剤編集 -->
  <ind-medicine-edit-base
    v-else-if="isShowIndMedicineEditModal"
    ref="refIndMediBase"
    :show-new-edit="false"
    :setting-data="settingIndData"
    @hide-modal="
      hideIndModal();
      postHideModal();
    "
  />

  <!-- UFRプログラム編集 -->
  <ind-edit-base
    v-else-if="isShowUfrProgramModal"
    ref="refIndEditBase"
    :setting-data="settingIndData"
    :component-id="dispComponentId"
    @hide-modal="
      hideIndModal();
      postHideModal();
    "
  >
    <component
      :is="dispComponentId"
      ref="refPatDeviceProgramUfr"
      :ord-no="settingIndChildData.ordNo"
      :data-source-type="DATA_SOURCE_TYPE_ORD"
      :show-button="false"
      @close="
        hideIndModal();
        postHideModal();
      "
    />
  </ind-edit-base>

  <!-- Naプログラム編集 -->
  <ind-edit-base
    v-else-if="isShowNaProgramModal"
    ref="refIndEditBase"
    :setting-data="settingIndData"
    :component-id="dispComponentId"
    @hide-modal="
      hideIndModal();
      postHideModal();
    "
  >
    <component
      :is="dispComponentId"
      ref="refPatDeviceProgramNa"
      :ord-no="settingIndChildData.ordNo"
      :data-source-type="DATA_SOURCE_TYPE_ORD"
      :show-button="false"
      @close="
        hideIndModal();
        postHideModal();
      "
    />
  </ind-edit-base>

  <!-- 透析液濃度プログラム編集 -->
  <ind-edit-base
    v-else-if="isShowDialysateProgramModal"
    ref="refIndEditBase"
    :setting-data="settingIndData"
    :component-id="dispComponentId"
    @hide-modal="
      hideIndModal();
      postHideModal();
    "
  >
    <component
      :is="dispComponentId"
      ref="refPatDeviceProgramDialysate"
      :ord-no="settingIndChildData.ordNo"
      :data-source-type="DATA_SOURCE_TYPE_ORD"
      :show-button="false"
      @close="
        hideIndModal();
        postHideModal();
      "
    />
  </ind-edit-base>

  <!-- QbQdプログラム編集 -->
  <ind-edit-base
    v-else-if="isShowQbqdProgramModal"
    ref="refIndEditBase"
    :setting-data="settingIndData"
    :component-id="dispComponentId"
    @hide-modal="
      hideIndModal();
      postHideModal();
    "
  >
    <component
      :is="dispComponentId"
      ref="refPatDeviceProgramQbqd"
      :ord-no="settingIndChildData.ordNo"
      :data-source-type="DATA_SOURCE_TYPE_ORD"
      :show-button="false"
      @close="
        hideIndModal();
        postHideModal();
      "
    />
  </ind-edit-base>

  <!-- IHdfプログラム編集 -->
  <ind-edit-base
    v-else-if="isShowIHdfProgramModal"
    ref="refIndEditBase"
    :setting-data="settingIndData"
    :component-id="dispComponentId"
    @hide-modal="
      hideIndModal();
      postHideModal();
    "
  >
    <component
      :is="dispComponentId"
      ref="refPatDeviceProgramIHdf"
      :ord-no="settingIndChildData.ordNo"
      :data-source-type="DATA_SOURCE_TYPE_ORD"
      :show-button="false"
      @close="
        hideIndModal();
        postHideModal();
      "
    />
  </ind-edit-base>

  <!-- 透析量プログラム -->
  <ind-edit-base
    v-else-if="isShowDiaysisProgramModal"
    ref="refIndEditBase"
    :setting-data="settingIndData"
    :component-id="dispComponentId"
    @hide-modal="
      hideIndModal();
      postHideModal();
    "
  >
    <component
      :is="dispComponentId"
      ref="refPatDeviceProgramQbqd"
      :ord-no="settingIndChildData.ordNo"
      :data-source-type="DATA_SOURCE_TYPE_ORD"
      :show-button="false"
      @close="
        hideIndModal();
        postHideModal();
      "
    />
  </ind-edit-base>

  <!-- BV-UFC -->
  <ind-edit-base
    v-else-if="isShowBvUfcModal"
    ref="refIndEditBase"
    :setting-data="settingIndData"
    :component-id="dispComponentId"
    @hide-modal="
      hideIndModal();
      postHideModal();
    "
  >
    <component
      :is="dispComponentId"
      ref="refBvUfc"
      :ord-no="settingIndChildData.ordNo"
      :data-source-type="DATA_SOURCE_TYPE_ORD"
      :show-button="false"
      @close="
        hideIndModal();
        postHideModal();
      "
    />
  </ind-edit-base>

  <!-- DW -->
  <ind-edit-base
    v-else-if="isShowDwModal"
    ref="refIndEditBase"
    :setting-data="settingIndData"
    :component-id="dispComponentId"
    @hide-modal="
      hideIndModal();
      postHideModal();
    "
  >
    <component
      :is="dispComponentId"
      ref="refDw"
      :ord-no="settingIndData.ordNo"
      :component-names="settingIndChildData.componentNames"
      :show-button="false"
      @close="
        hideIndModal();
        postHideModal();
      "
    />
  </ind-edit-base>
</template>

<script>
  var _pageName='';
  /**
   * Vue関連
   */
  import { mapActions, mapGetters } from "@/compat/vue/vuex";
  import store from "@/stores";
  import { DATA_SOURCE_TYPE_ORD } from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
  import MultiModalMixin from "@/components/modals/MultiModalMixin";
  import UserAuthorityMixin from "@/components/common/UserAuthorityMixin";
  import { EventBus } from "@/compat/vue/event-bus.js";

  import { ApiHelper } from "@/apis/AxiosHelper";

  /**
   * モーダルコンポーネント
   * @summary モーダルコンポーネントのインポート
   */
  // 指示モーダルのベースコンポーネント
  import IndEditBase from "@/components/indication/IndEditBase";
  // 治療予定作成
  import IndPlanCreate from "@/components/indication/IndPlanCreate";
  // 治療予定コピー
  import TreatPlanCopy from "@/components/indication/TreatPlanCopy";
  // 治療予定移動
  import TreatPlanMove from "@/components/indication/TreatPlanMove";
  // 予定中止
  import IndPlanDelete from "@/components/indication/IndPlanDelete";
  // 曜日パターン変更
  import ChangeDayOfWeekPattern from "@/components/indication/ChangeDayOfWeekPattern";
  // 治療方法
  import IndTreatMethod from "@/components/indication/IndTreatMethod";
  // スケジュール
  import IndSchEdit from "@/components/indication/IndSchEdit";
  // 治療条件
  import IndActionChart from "@/components/indication/IndActionChart";
  // 投与薬剤新規登録ベース
  import IndTreatmentMediBase from "@/components/indication/IndMedicineCreateBase";
  // 投与薬剤セット(新規登録スロット)
  import IndMedicineSet from "@/components/indication/IndMedicineSet";
  // 投与薬剤編集
  import IndMedicineEditBase from "@/components/indication/IndMedicineEditBase";
  // 医療材料新規登録
  import IndEquipmentEdit from "@/components/indication/IndEquipmentEdit";
  // 医療材料編集
  import IndEquipmentEditBase from "@/components/indication/IndEquipmentEditBase";
  // 医療材料新規登録
  import IndEquipmentSet from "@/components/indication/IndEquipmentSet";
  // 指示コメント
  import IndCommentCreate from "@/components/indication/IndCommentCreate";
  // 風袋編集モーダル
  import TareInfoEditor from "@/components/deviceset-info/tare-info/TareInfoEditor";
  // 除水補正編集モーダル
  import OffWaterInfoEditor from "@/components/deviceset-info/off-water-info/OffWaterInfoEditor";
  // UFRプログラム
  import PatDeviceProgramUFR from "@/components/deviceset-info/ufr-program/UfrProgramEditor";
  // Naプログラム
  import PatDeviceProgramNa from "@/components/deviceset-info/na-program/NaProgramEditor";
  // 透析液濃度プログラム
  import PatDeviceProgramDialysate from "@/components/deviceset-info/dc-program/DcProgramEditor";
  // QbQdプログラム
  import PatDeviceProgramQbqd from "@/components/deviceset-info/qbqd/QbqdEditor";
  // IHdfプログラム
  import PatDeviceProgramIHdf from "@/components/deviceset-info/i-hdf/IHdfMain";
  // 透析量プログラム
  import DiaysisProgramEditor from "@/components/deviceset-info/diaysis-program/DiaysisProgramEditor";
  // BV-UFC
  import BvUfcEditor from "@/components/deviceset-info/bv-ufc/BvUfcEditor";
  // DW
  import DwEditor from "@/components/indication/indRstDw";
  //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
  import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
  import { getScopedElementsByClassName, queryScopedSelectorAll } from "@/functions/common/LayoutMeasureHelper";
  import { findAncestorWithMethod } from "@/functions/common/ComponentOwnerResolver";
  //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end

  export default {
    components: {
      "ind-edit-base": IndEditBase,
      "ind-plan-create": IndPlanCreate,
      "ind-plan-copy": TreatPlanCopy,
      "ind-plan-move": TreatPlanMove,
      "ind-plan-delete": IndPlanDelete,
      "ind-week-pattern": ChangeDayOfWeekPattern,
      "ind-treat-method": IndTreatMethod,
      "ind-sch-edit": IndSchEdit,
      "ind-action-chart": IndActionChart,
      "ind-medi-base": IndTreatmentMediBase,
      "ind-medicine-set": IndMedicineSet,
      "ind-medicine-edit-base": IndMedicineEditBase,
      "ind-equipment-edit": IndEquipmentEdit,
      "ind-equipment-base": IndEquipmentEditBase,
      "ind-equipment-set": IndEquipmentSet,
      "ind-comment": IndCommentCreate,
      "tare-info-editor": TareInfoEditor,
      "off-water-info-editor": OffWaterInfoEditor,
      "pat-device-program-ufr": PatDeviceProgramUFR,
      "pat-device-program-na": PatDeviceProgramNa,
      "pat-device-program-dialysate": PatDeviceProgramDialysate,
      "pat-device-program-qbqd": PatDeviceProgramQbqd,
      "pat-device-program-ihdf": PatDeviceProgramIHdf,
      "diaysis-program-editor": DiaysisProgramEditor,
      "bv-ufc-editor": BvUfcEditor,
      "ind-rst-dw": DwEditor
    },

    mixins: [MultiModalMixin, UserAuthorityMixin],

    props: {
      /**
       * 患者経過総合ビューアを更新するかどうかのフラグ
       */
      isPatViewerRefresh: {
        type: Boolean,
        default: false,
        required: false
      }
    },

    data() {
      return {
        DATA_SOURCE_TYPE_ORD
      };
    },

    computed: {
      ...mapGetters("pat-viewer-modal", [
        "getDispComponentId",
        "getIsShowIndModal",
        "getIsShowPlanCopyModal",
        "getIsShowPlanMoveModal",
        "getIsShowWeekPatternModal",
        "getIsShowMediCreateModal",
        "getIsShowMediEditModal",
        "getIsShowUfrProgramModal",
        "getIsShowNaProgramModal",
        "getIsShowDialysateProgramModal",
        "getIsShowQbqdProgramModal",
        "getIsShowIHdfProgramModal",
        "getIsShowDiaysisProgramModal",
        "getIsShowBvUfcModal",
        "getIsShowDwModal",
        "getSettingIndData",
        "getSettingIndChildData"
      ]),
      ...mapGetters("pat-viewer-popover", ["getCopyFlag"]),
      ...mapGetters("window-size", {
        windowHeight: "getWindowHeight",
        windowWidth: "getSplittedWidth"
      }),
      ...mapGetters("account-edit", {
        getFontSize: "getFontSize",
      }),
      ...mapGetters("pat-info", ["selectedPat"]),

      /**
       * モーダル表示するコンポーネントID
       */
      dispComponentId() {
        return this.getDispComponentId;
      },

      /**
       * 指示系モーダル表示／非表示切替
       */
      isShowIndModal() {
        return this.getIsShowIndModal;
      },

      /**
       * 治療予定コピーモーダル表示/非表示切替
       */
      isShowPlanCopy() {
        return this.getIsShowPlanCopyModal;
      },

      /**
       * 治療予定移動モーダル表示/非表示切替
       */
      isShowPlanMove() {
        return this.getIsShowPlanMoveModal;
      },

      /**
       * 曜日パターン変更モーダル表示/非表示切替
       */
      isShowWeekPattern() {
        return this.getIsShowWeekPatternModal;
      },

      /**
       * 投与薬剤新規登録モーダル表示/非表示切替
       */
      isShowIndMedicineCreateModal() {
        return this.getIsShowMediCreateModal;
      },

      /**
       * 投与薬剤編集モーダル表示/非表示切替
       */
      isShowIndMedicineEditModal() {
        return this.getIsShowMediEditModal;
      },

      /**
       * UFRプログラム編集モーダル表示/非表示切替
       */
      isShowUfrProgramModal() {
        return this.getIsShowUfrProgramModal;
      },

      /**
       * Naプログラム編集モーダル表示/非表示切替
       */
      isShowNaProgramModal() {
        return this.getIsShowNaProgramModal;
      },

      /**
       * 透析液濃度プログラム編集モーダル表示/非表示切替
       */
      isShowDialysateProgramModal() {
        return this.getIsShowDialysateProgramModal;
      },

      /**
       * QbQdプログラム編集モーダル表示/非表示切替
       */
      isShowQbqdProgramModal() {
        return this.getIsShowQbqdProgramModal;
      },

      /**
       * IHdfプログラム編集モーダル表示/非表示切替
       */
      isShowIHdfProgramModal() {
        return this.getIsShowIHdfProgramModal;
      },

      /**
       * 透析量プログラム編集モーダル表示/非表示切替
       */
      isShowDiaysisProgramModal() {
        return this.getIsShowDiaysisProgramModal;
      },

      /**
       * BV-UFC
       */
      isShowBvUfcModal() {
        return this.getIsShowBvUfcModal;
      },
      /**
       * DW
       */
      isShowDwModal() {
        return this.getIsShowDwModal;
      },

      /**
       * 指示系モーダルへ渡すデータ
       */
      settingIndData() {
        _pageName = this.getSettingIndData.headerTitle;
        return this.getSettingIndData;
      },

      /**
       * 指示系モーダル子コンポーネントへ渡すデータ
       */
      settingIndChildData() {
        return this.getSettingIndChildData;
      }
    },

    watch: {
      windowHeight() {
        this.adjustHeight();
      },
      windowWidth() {
        this.adjustHeight();
      },
      getFontSize() {
        this.adjustHeight();
      },
    },

    methods: {
      ...mapActions("pat-viewer-modal", ["hideIndModal"]),

      /**
       * モーダルを閉じた直後に実施
       */
      postHideModal() {
        this.hideModal();

        // refの中をループ
        for (const refs in this.$refs) {
          // refの中にObjectが存在すれば次の処理へ
          if (this.$refs[refs]) {
            // 更新フラグがONの場合
            if (this.$refs[refs].isRefresh) {
              // 患者経過総合ビューアの更新処理を実施
              EventBus.$emit("isRefresh");
              // 更新フラグをOFFに戻す
              this.$refs[refs].isRefresh = false;
            }
          }
        }
      },
      /**
       * component破棄前に実施
       */
      beforeDestroyHideModal() {
      	// 各モーダルの表示/非表示フラグの初期化
        this.hideIndModal();
      },
      /**
       * フッターの高さに応じてメインコンテンツエリアの高さを調整
       */
      adjustHeight() {
        // フッターの高さを取得
        const footerObj = getScopedElementsByClassName("modal-footer", this.$el || null);
        let footerHeight = 0;
        if (footerObj.length > 0) {
          // 高さのない要素も取得される為、高さのある要素の値のみ取得する
          for (let f = 0; f < footerObj.length; f++) {
            footerHeight = footerObj[f].offsetHeight !== 0 ? footerObj[f].offsetHeight : footerHeight;
          }
        }
        if (footerHeight !== 0) {
          const bodyObj = getScopedElementsByClassName("modal-body", this.$el || null);
          if (bodyObj.length > 0) {
            // modal-body の height:100% 指定した時に -50px するとフッターの高さになる
            footerHeight = footerHeight + 50;
            for (let b = 0; b < bodyObj.length; b++) {
              // 高さのない要素も取得される為、高さのある要素の値のみ取得する
              bodyObj[b].style.height = bodyObj[b].offsetHeight !== 0 ? "calc(100% - " + footerHeight + "px)" : "";
            }
          }
        }
      },
      resolveModalContentsOwner() {
        return findAncestorWithMethod(this, ["getPageNameBySubPage"], { maxDepth: 24 });
      }
    },

    mounted() {
      // 利用権限がない場合入力部品を操作不可にする
      // this.authorityCds = [ AUTHORITY_CODES.IND_PEDIT, AUTHORITY_CODES.IND_EDIT ];
      // this.disableElement(this.$el);
      //FNSI-修正 ログ対応 xiebzh add start
      this.$nextTick(() => {
        // ボタンのクリックイベントを追加
        var buttonObj = queryScopedSelectorAll("ons-button", this.$el || null);
        var parentName = this.resolveModalContentsOwner()?.getPageNameBySubPage?.() || "";
        for (var i = 0; i < buttonObj.length; i++) {
          if (isPC()) {
            // PC側
            buttonObj[i].onmouseup = function(e) {
              if (_pageName === undefined) {
                _pageName = getPageName(e.target);
              }
              var pageName = parentName + 'の' + _pageName;
              var btnName = this.innerText;
              //FNSI-修正 8164 ljx mod start
              let selectedPatId = store.getters["pat-info/selectedPatId"];
              let param = {'pageName':pageName, 'btnName':btnName,'patId':selectedPatId,'functionName':parentName};
              //FNSI-修正 8164 ljx mod end
              ApiHelper.put("/logs/event/accesslog", param)
                .catch(error => {
                  //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
                  getErrorMessage('ModalContents.vue', 'mounted', error);
                  //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
                });
            };
          } else {
            // スマート設備
            buttonObj[i].ontouchend = function(e) {
              if (_pageName === undefined) {
                _pageName = getPageName(e.target);
              }
              var pageName = parentName + 'の' + _pageName;
              var btnName = this.innerText;
              let param = {'pageName':pageName, 'btnName':btnName};
              ApiHelper.put("/logs/event/accesslog", param)
                .catch(error => {
                  //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
                  getErrorMessage('ModalContents.vue', 'mounted', error);
                  //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
                });
            };
          }
        }
        buttonObj = null;
        // メインコンテンツエリアの高さを調整
        this.adjustHeight();
      });
      //FNSI-修正 ログ対応 xiebzh add end
    },
    beforeUnmount() {
      // 各モーダルの表示/非表示フラグの初期化
      this.beforeDestroyHideModal();
    }
  };

  function getPageName(btnObj) {
    var pageName = '';
    var parentDivParam = btnObj?.parentNode || null;
    for (var i = 0; i < 40 && parentDivParam; i++) {
      if (String(parentDivParam.className || '').indexOf('modal-mask') >= 0) {
        parentDivParam.querySelectorAll?.('div').forEach(elementDiv => {
          if (elementDiv.classList.contains("toolbar__title") && elementDiv.classList.contains("toolbar__left")) {
            pageName = elementDiv.querySelector('span')?.innerText || '';
          }
        });
        break;
      } else {
        parentDivParam = parentDivParam.parentNode;
      }
    }
    return pageName;
  }

  function isPC() {
    var userAgentInfo = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "");
    var Agents = ["Android", "iPhone",
      "SymbianOS", "Windows Phone",
      "iPad", "iPod"];
    var flag = true;
    for (var v = 0; v < Agents.length; v++) {
      if (userAgentInfo.indexOf(Agents[v]) > 0) {
        flag = false;
        break;
      }
    }
    return flag;
  }
</script>

<style scoped>
  .ind-modal-style :deep(.device-info-container) {
    margin: auto;
    display: unset;
  }

  div :deep(.device-info-content) {
    font-size: 1em;
  }

  /* TODO: 共通スタイル(modal.css)に定義 */
  div :deep(.modal-header .toolbar) {
    background-color: var(--ntss-header-background-color);
  }

  div :deep(.modal-header .toolbar__title.toolbar__left) {
    color: var(--ntss-header-color) !important;
  }

  div :deep(.modal-body){
    height: calc(100% - 4em - 73px);
  }

  div :deep(.modal-search),
  div :deep(.modal-body),
  div :deep(.modal-footer),
  div :deep(.modal-footer .bottom-bar) {
    background-color: var(--ntss-base-background-color);
    color: var(--ntss-base-color);
  }
  @media print {
    body:has(.ind-plan-create) div :deep(.modal-wrapper),
    body:has(.change-day-of-Week-pattern) div :deep(.modal-wrapper){
      display: inline-block !important;
      text-align: center !important;
      width: 100%  !important;
    }

    body:has(.ind-plan-create) div :deep(.modal-container),
    body:has(.change-day-of-Week-pattern) div :deep(.modal-container){
      display: inline-block !important;
    }

    body:has(.dc-program) div :deep(.modal-wrapper),
    body:has(.i-hdf) div :deep(.modal-wrapper){
      display: inline-block !important;
      text-align: center !important
    }

    body:has(.indInfo-style-modal-container) div :deep(.modal-wrapper) {
      display: inline-block !important;
      width: 100%;
    }

    body:has(.dc-program) div :deep(.modal-container),
    body:has(.i-hdf) div :deep(.modal-container){
      display: inline-block !important;
    }
    body:has(.i-hdf) div :deep(.modal-container) {
      width: 99% !important;
    }
  }
</style>
