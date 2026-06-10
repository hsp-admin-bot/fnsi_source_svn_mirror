/**
* 患者イベントページ
*/
<template>
  <div class="main-flex-container">
    <div class="submenu-container">
      <div class="scroll-table" ref="tbl">
        <div class="card-head" style="float: left">
          <div v-if="propsIsMainList">
            <ons-icon
              class="ons-icon ion-navicon ons-icon--ion pat-event-openclose-icon"
              icon="ion-ios-menu"
              @click="onMainListOpen()"
            ></ons-icon>
          </div>
        </div>
        <div class="showName ntss-pat-event-label" v-if="getFlag" >
          <label >{{this.getFacilityName}}</label>
        </div>
        <div class="card-head">
          <div
            class="card-head-table"
            v-if="getPatEventRecord && getPatEventRecord.subCategoryCd !== -1"
          >
            <label class="ntss-pat-event-label">カテゴリ選択</label>
			<div v-if="this.getUpdateMode">
			  <label>{{this.getPatEventRecord.categoryName}}　{{this.getPatEventRecord.subCategoryName}}</label>
			</div>
			<div v-else>
			  <v-ons-select
                class="select"
                v-model="subCategorySelectValue"
                :disabled="getUpdateMode||!getItemAuthorized('PatEvent', 'default_authority')"
                @change="changeSelectedTemplate"
              >
                <option
                  v-for="(item, index) in selectTemplates"
                  :key="index"
                  :value="item.code.toString()"
                  :disabled="item.categoryCode !== undefined"
                  style="color: black;"
                >{{ item.name }}</option>
              </v-ons-select>
			</div>
          </div>
        </div>
        <div v-if="getPatEventRecord && getPatEventRecord.useType !== 3">
          <div class="tab-area" v-if="getPatEventRecord && getPatEventRecord.subCategoryCd > 0">
            <component :is="'pat-event-tab-item'" :input-start-date="computedCreatedDate" keep-alive ref="tab" />
          </div>
        </div>
        <div v-if="getPatEventRecord && getPatEventRecord.useType !== 3">
          <div v-for="(item, index) in getPatEventInputParams" :key="index">
            <table class="card-table" :style="viewStyles(item.format_class)">
              <label style="display:none">{{index}}</label>
              <tr>
                <td>
                  <div v-if="item.format_class === 0">
                    <component
                      :key="itemKey"
                      :is="'pat-event-text-item'"
                      :props-index="index"
                      keep-alive
                      ref="text"
                      @patEventImport="patEventImport"
                    />
                  </div>
                  <div v-if="item.format_class === 1">
                    <component
                      :is="'pat-event-text-area-item'"
                      :props-index="index"
                      keep-alive
                      ref="textArea"
                      :authorityCds="authorityCds"
                      @patEventImport="patEventImport"
                    />
                  </div>
                  <div v-if="item.format_class === 2">
                    <component
                      :is="'pat-event-image-item'"
                      :props-index="index"
                      :props-isva="isVa"
                      keep-alive
                      ref="image"
                      @image-changed="handleImageChanged"
                    />
                  </div>
                  <div v-if="item.format_class === 3">
                    <component
                      :is="'pat-event-list-item'"
                      :props-index="index"
                      keep-alive
                      ref="list"
                    />
                  </div>
                  <div v-if="item.format_class === 4">
                    <component
                      :is="'pat-event-check-item'"
                      :props-index="index"
                      keep-alive
                      ref="check"
                    />
                  </div>
                  <div v-if="item.format_class === 5">
                    <component
                      :is="'pat-event-date-item'"
                      :props-index="index"
                      :props-ini-date="computedCreatedDate"
                      keep-alive
                      ref="date"
                    />
                  </div>
                  <div v-if="item.format_class === 6">
                    <component
                      :is="'pat-event-radio-item'"
                      :props-index="index"
                      keep-alive
                      ref="radio"
                    />
                  </div>
                  <div v-if="item.format_class === 7">
                    <component
                      :is="'pat-event-file-item'"
                      :props-index="index"
                      keep-alive
                      ref="file"
                    />
                  </div>
                  <div v-if="item.format_class === 8">
                    <component
                      :is="'pat-event-calc-item'"
                      :props-index="index"
                      keep-alive
                      ref="calc"
                    />
                  </div>
                  <div v-if="item.format_class === 9">
                    <component
                      :is="'pat-event-dialysis-data-link'"
                      :props-index="index"
                      keep-alive
                      ref="datalink"
                    />
                  </div>
                  <div v-if="item.format_class === 10">
                    <component
                      :is="'pat-event-bbs-item'"
                      :props-index="index"
                      :authorityCds="authorityCds"
                      keep-alive
                      ref="bbs"
                    />
                  </div>
                </td>
              </tr>
            </table>
          </div>
          <!--add FNSI-改修内容患者イベントテンプレートマスタで内容が空白のテンプレートを作成するときの患者イベント画面の表示修正 任 start-->
          <div v-if="getPatEventInputParams === null || (getPatEventInputParams.length === 0 && this.inputModel.subCategoryCd!==0)">
            <span style="color: #FF0000">{{this.msgDiaLog}}</span>
          </div>
          <!--add FNSI-改修内容患者イベントテンプレートマスタで内容が空白のテンプレートを作成するときの患者イベント画面の表示修正 任 end-->
        </div>
        <div v-if="getPatEventRecord && getPatEventRecord.useType === 3">
          <component
            :is="'pat-introduction-letter'"
            ref="patIntroductionLetter"
            :get-view-mode="getViewMode"
            :get-update-mode="getUpdateMode"
            :pat-record="null"
            @content-changed="confirmContentChanged"
          />
        </div>
      </div>
    </div>
    <div
      class="btn-area nowrap-block"
      style="width: 99%; padding-top: 10px;"
      :style="{ 'display': getBtnDisplay }"
    >
      <div class="cancel-btn-area">
        <v-ons-button
          v-if="
            getViewMode === false ||
            selfScreenName === 'observe-record-detail' ||
            this.selfScreenName === 'treatment-observe-detail'
          "
          data-non-authorize="true"
          class="button denial-btn btn2-cancel"
          style="width: 6em"
          @click="handleClickCancel"
          >キャンセル</v-ons-button
        >
        <v-ons-button
          v-if="
            (selfScreenName === 'observe-record-detail' ||
              this.selfScreenName === 'treatment-observe-detail') &&
            getUpdateMode === true
          "
          class="button registration-btn red-btn btn4-alert"
          style="width: 6em; margin-left: 0.5em"
          :style="!getIsOtherFacilitys ? { 'opacity': getItemAuthorized('PatEvent', 'item_patevent_del') ? 1 : 0.6 } : {}"
          @click="remove()"
          :disabled="
            isReadOnly ||
            !isShared ||
            getIsOtherFacilitys
          "
          >削除</v-ons-button
        >
        <v-ons-button
          v-if="
            getViewMode === true &&
            !(
              selfScreenName === 'observe-record-detail' ||
              this.selfScreenName === 'treatment-observe-detail'
            )
          "
          class="button registration-btn red-btn btn4-alert"
          @click="remove()"
          :disabled="
            !getUpdateMode ||
            isReadOnly ||
            getIsOtherFacility ||
            getIsOtherFacilitys
          "
          style="margin-left: 0.5em"
          :style="!getIsOtherFacility ? { 'opacity': hasTreatmentRecordAuthorityDel ? 1 : 0.6 } : {}"
          >削除</v-ons-button
        >
      </div>
      <div class="registration-btn-area">
        <v-ons-button
          v-if="
            getPatEventRecord &&
            getPatEventRecord.useType === 3 &&
            getShowUpload
          "
          class="button registration-btn btn1-execute"
          @click="trigger"
          :disabled="
            getReportFlag ||
            !getItemAuthorized('PatEvent', 'default_authority') ||
            isOtherFacilityDisabled ||
            getIsOtherFacilitys
          "
          >取込</v-ons-button
        >
        <input
          type="file"
          ref="fileBtn"
          id="uploadFile"
          accept=".pdf"
          :disabled="
            !getItemAuthorized('PatEvent', 'default_authority')
          "
          @change="getFile($event)"
          hidden="hidden"
        />
        <v-ons-button
          v-if="
            getTemplateShow &&
            getPatEventRecord &&
            getPatEventRecord.useType !== 3
          "
          class="button registration-btn btn1-execute"
          @click="getNewTemplate"
          style="margin-left: 0.5em"
          :disabled="
            !getItemAuthorized('PatEvent', 'default_authority') ||
            isOtherFacilityDisabled ||
            getIsOtherFacilitys
          "
          >テンプレート取得</v-ons-button
        >
        <v-ons-button
          v-if="getPatEventRecord && getPatEventRecord.useType === 3"
          class="button registration-btn btn3-normal"
          @click="copyLetter"
          :disabled="
            !getUpdateMode ||
            isReadOnly ||
            getDisplayTwo ||
            (('0' === getLetterCategory && getPathReal !== null) || '1' === getLetterCategory) ||
            getIsOtherFacility ||
            !hasTreatmentRecordAuthority ||
            !getItemAuthorized('PatEvent', 'default_authority') ||
            getIsOtherFacilitys
          "
          style="margin-left: 0.5em"
          >コピー</v-ons-button
        >
        <v-ons-button
          v-if="getPatEventRecord && getPatEventRecord.useType === 3"
          class="button registration-btn btn3-normal"
          @click="showPrintPopover($event, 'up', true)"
          :disabled="
            (!getUpdateMode && isReadOnly) ||
            getIsShowSomeThing ||
            (('0' === getLetterCategory && getPathReal !== null) || '1' === getLetterCategory) ||
            !getItemAuthorized('PatEvent', 'default_authority') ||
            isOtherFacilityDisabled ||
            getIsOtherFacilitys
          "
          style="margin-left: 0.5em"
          >印刷</v-ons-button
        >
        <v-ons-button
          v-if="
            !getViewMode && getPatEventRecord && getPatEventRecord.useType === 3
          "
          class="button registration-btn btn1-execute"
          @click="updateLetter"
          :disabled="
            (!getUpdateMode && isReadOnly) ||
            getDisplayTwo ||
            getIsShowSomeThing ||
            !getItemAuthorized('PatEvent', 'default_authority') ||
            isOtherFacilityDisabled ||
            getIsOtherFacilitys || getReportIsDel === '1'
          "
          style="margin-left: 0.5em"
          >
          最新の情報を取得
          </v-ons-button
        >
        <v-ons-button
          v-if="
            getViewMode === true &&
            !hasPreviousPage &&
            selfScreenName != 'observe-record-detail' &&
            this.selfScreenName != 'treatment-observe-detail'
          "
          class="button registration-btn btn3-normal"
          @click="editor('editor')"
          style="margin-left: 0.5em"
          :disabled="
            isReadOnly ||
            getIsOtherFacility ||
            !hasTreatmentRecordAuthority ||
            !getItemAuthorized('PatEvent', 'default_authority') ||
            getIsOtherFacilitys
          "
          >編集</v-ons-button
        >
        <!-- mod #12462 患者情報共有 20260326 start -->
        <v-ons-checkbox
          v-if="getViewMode === false && !isOtherFacilityDisabled && !getIsOtherFacilitys"
          v-model="isNotification"
          :disabled="
            !getItemAuthorized('PatEvent', 'default_authority') ||
            isOtherFacilityDisabled ||
            getIsOtherFacilitys
          "
        />
        <span v-if="getViewMode === false && !isOtherFacilityDisabled && !getIsOtherFacilitys" class="ntss-pat-event-label">
          通知する
        </span>
        <v-ons-button
          v-if="getViewMode === false" && !isOtherFacilityDisabled && !getIsOtherFacilitys
          class="button registration-btn btn1-execute"
          @click="registration()"
          style="margin-left: 0.5em"
          :disabled="!hasBasicAuthority || isOtherFacilityDisabled || getIsOtherFacilitys"
          >保存</v-ons-button
        >
        <!-- mod #12462 患者情報共有 20260326 end -->
        <v-ons-popover
          cancelable
          :class="[fontSizeSet, 'user-menu-item-popover report-list-popover']"
          :visible.sync="popoverPrintVisible"
          :target="popoverPrintTarget"
          :direction="popoverPrintDirection"
        >
          <!-- mod #12107 帳票印刷失敗通知が行われない limingzhe 20251114 start -->
          <!--   <v-ons-select
            v-show="hasPrinter"
            v-model="selectedPrinter"
            data-non-authorize="true"
            class="printer-selection"
          > -->
          <v-ons-select
            :disabled="!hasPrinter"
            v-model="selectedPrinter"
            data-non-authorize="true"
            class="printer-selection"
          >
          <!-- mod #12107 帳票印刷失敗通知が行われない limingzhe 20251114 end -->
            <template v-for="item in getMstPrinters">
              <option :key="item.printerCd" :value="item.printerCd">{{ item.dispPrinterName }}</option>
            </template>
          </v-ons-select>
          <div class="button-area flex-container" style="flex-direction: row-reverse;">
            <div class="registration-btn-area">
              <button
                class="button registration-btn btn3-normal"
                :disabled="!hasPrinter"
                @click="printLetter">印刷実行</button>
            </div>
          </div>
        </v-ons-popover>
      </div>
    </div>
    <message-dialog
      v-if="messageDialogInfo.isDialogVisible"
      :visible.sync="messageDialogInfo.isDialogVisible"
      :message-cd="messageDialogInfo.messageCd"
      :type="messageDialogInfo.type"
      :string-params="messageDialogInfo.stringParams"
      @confirm="confirmResult"
    />
    <message-dialog
      v-if="messageDateInfo.isCheckDialogVisible"
      :visible.sync="messageDateInfo.isCheckDialogVisible"
      :message-cd="messageDateInfo.messageCd"
      :title="messageDateInfo.title"
      :string-params="messageDateInfo.stringParams"
      type="1"
    />
  </div>
</template>
<script>
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
import store from "@/stores";
import axios from 'axios'
import {sendRequestGetPatEventRecord} from "@/apis/pat-event";
import {mapActions, mapGetters, mapMutations} from "vuex";
import {EventBus} from "@/eventBus.js";
import {deepCopy, hasEqualValues} from "@/functions/common/CommonFunctions";
import PatEventTabItem from "@/components/pat-event/sub-item/PatEventTab";
import PatEventTextItem from "@/components/pat-event/sub-item/PatEventText";
import PatEventTextAreaItem from "@/components/pat-event/sub-item/PatEventTextArea";
import PatEventListItem from "@/components/pat-event/sub-item/PatEventList";
import PatEventFileItem from "@/components/pat-event/sub-item/PatEventFile";
import PatEventRadioItem from "@/components/pat-event/sub-item/PatEventRadio";
import PatEventCheckItem from "@/components/pat-event/sub-item/PatEventCheck";
import PatEventDateItem from "@/components/pat-event/sub-item/PatEventDate";
import PatEventCalcItem from "@/components/pat-event/sub-item/PatEventCalc";
import PatEventImageItem from "@/components/pat-event/sub-item/PatEventImage";
import PatIntroductionLetter from "@/components/introduction-letter/IntroductionLetterComponent";
import PatEventDialysisDateLink from "@/components/pat-event/sub-item/PatEventDialysisDateLink";
import PatEventBbsItem from "@/components/pat-event/sub-item/PatEventBbs";
import {ApiHelper} from "@/apis/AxiosHelper.js";
import moment from "moment";
import {ADVANCED_SETTINGS} from "@/constants/advancedSettings";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import PopoverMixin from "@/components/PopoverMixin";
import PatHeaderControlMixin from "@/components/common/PatHeadControlMixin";
import {AUTHORITY_CODES} from "@/constants/userAuthority";
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
import {createJournal} from "@/apis/journal";
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
import {sendRequestPostImageDelete} from "@/apis/pat-event";
import { messageFormat } from '@/functions/common/MessageFormat';
import {DATE_FORMAT, dateFormat} from "@/functions/common/DateTimeUtils";
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
import isEqualWith from "lodash/isEqualWith";
import { customComparatorForType } from "@/utils/util.js"

export default {
  mixins: [NextTransitionMixin, PatHeaderControlMixin, PopoverMixin, ComponentGuardMixin],
  name: "PatEventDetailCompnent",
  props: ["propsIsMainList", "historyKey"],
  components: {
    "pat-event-tab-item": PatEventTabItem,
    "pat-event-text-item": PatEventTextItem,
    "pat-event-text-area-item": PatEventTextAreaItem,
    "pat-event-list-item": PatEventListItem,
    "pat-event-file-item": PatEventFileItem,
    "pat-event-radio-item": PatEventRadioItem,
    "pat-event-check-item": PatEventCheckItem,
    "pat-event-date-item": PatEventDateItem,
    "pat-event-calc-item": PatEventCalcItem,
    "pat-event-image-item": PatEventImageItem,
    "pat-introduction-letter": PatIntroductionLetter,
    "pat-event-dialysis-data-link": PatEventDialysisDateLink,
    "message-dialog": messageDialog,
    "pat-event-bbs-item": PatEventBbsItem
  },
  data() {
    return {
      inputModel: {
        subCategoryCd: 0,
        subReportCd: 0
      },
      title: "",
      errorMessage: "",
      scrollTop: 0,
      scrollLeft: 0,
      reportList: [],
      msgDiaLog: "",
      backupPatEventRecord: null,
      selfScreenName: "",
      ignoreWatchSelectedPatId: false,
      messageDialogInfo: {
        isDialogVisible: false,
        messageCd: null,
        type: null,
        stringParams: [],
        targetName: null
      },
      messageDateInfo: {
        isCheckDialogVisible: false,
        messageCd: null,
        stringParams: []
      },
      hasTreatmentRecordAuthority: false,
      hasPreviousPage: false,
      hasTreatmentRecordAuthorityDel: false,
      authorityCds: [
        AUTHORITY_CODES.PAT_EVENT_PEDIT,  // 患者イベント-代行編集
        AUTHORITY_CODES.PAT_EVENT_EDIT    // 患者イベント-編集
      ],
      confirmAllowDiscardChangesProgress: 0,
      confirmAllowDiscardChangesQueue: [],
      isChanged: false,
      isNotification: false,
      // 紹介状
      letterFile: null,
      letterFileName: "",
      // 患者カレンダーからの新規作成時の日付
      newDateStr: "",
      unsubscribe: null,
      itemKey:0,
      isChangePatId: false,
      mstAllSubCategoryRecords: [],
      mstSubCategoryRecords: [],
      mstAllTemplateRecords: [],
      mstAllCategoryRecords: [],
      mstTemplateRecords: [],
      mstCategoryRecords: [],
      // 印刷ポップアップ設定
      selectedPrinter: null,
      // add #12107 帳票印刷失敗通知が行われない limingzhe 20251114 start
      defaultPrinter: null,
      // add #12107 帳票印刷失敗通知が行われない limingzhe 20251114 end
      popoverPrintVisible: false,
      popoverPrintTarget: null,
      popoverPrintDirection: "up",
      coverPrintTarget: false,
      alertFlag: true,
      // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start
      copySourcePatEventCd: null,
      originalLetterInfo: null,
      // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end
    };
  },
  watch: {
    async selectedPatId() {
      if (this.ignoreWatchSelectedPatId) return;
      if (this.isObserveRecordDetail && this.getPatEventRecord && this.getPatEventRecord.patId !== this.selectedPatId) {
        if(!this.getUpdateMode){
          this.isChangePatId = true;
        }
        if (await this.confirmAllowDiscardChanges()) {
          // 内容破棄をキャンセルしない場合は観察記録の一覧画面に戻す
          this.setRelease();
          await this.setPatEventRecord(null);
          this.$router.go(-1);
        } else {
          // 内容破棄をキャンセルした場合は患者を戻す
          this.ignoreWatchSelectedPatId = true;
          await this.setSelectedPatHeader(this.getPatEventRecord.patId);
          this.ignoreWatchSelectedPatId = false;
        }
      }
    },
    isNotification(newValue){
      this.setIsNotificationFlg(newValue)
    },
    getPatEventRecord: {
      handler(val) {
        this.confirmContentChanged();
      },
      deep: true
    },
      // 紹介状の場合は紹介状のテンプレートを取得する
    getLetterCategory(val) {
      if (this.getPatEventRecord?.useType === 3) {
        this.confirmContentChanged();
      }
    },
    getToFacilityCd(val) {
      if (this.getPatEventRecord?.useType === 3) {
        this.confirmContentChanged();
      }
    },
    getToMedicalInstitutionCd(val) {
      if (this.getPatEventRecord?.useType === 3) {
        this.confirmContentChanged();
      }
    },
    getReportCd(val) {
      if (this.getPatEventRecord?.useType=== 3) {
        this.confirmContentChanged();
      }
    }
  },
  async created() {
    // add 9868 特定の操作で紹介状で紹介状以外の患者イベントを新規作成できてしまう 関 start
    await this.fetchPatEventMaster();
    // add 9868 特定の操作で紹介状で紹介状以外の患者イベントを新規作成できてしまう 関 end
    // 画面名称取得
    this.selfScreenName = this.$router.currentRoute.name;
    await this.getMstReport();
    if (this.getSharedFacilityCd == null) {
      this.setSharedFacilityCd(this.getFacilityCd);
    }
    // add 9868 特定の操作で紹介状で紹介状以外の患者イベントを新規作成できてしまう 関 start
    this.initPatIntroLetter();
    this.mstAllSubCategoryRecords = this.getMstAllSubCategoryRecords;
    this.mstSubCategoryRecords = this.getMstSubCategoryRecords;
    this.mstAllTemplateRecords = this.getMstAllTemplateRecords;
    this.mstAllCategoryRecords = this.getMstAllCategoryRecords;
    this.mstTemplateRecords = this.getMstTemplateRecords;
    this.mstCategoryRecords = this.getMstCategoryRecords;
    this.backupPatEventRecord = deepCopy(this.getPatEventRecord);
    this.setInitPatEventRecord(deepCopy(this.getPatEventRecord));
    // 治療記錄の權限取得
    this.hasTreatmentRecordAuthority = this.getTreatmentRecordAuthority();
    this.hasTreatmentRecordAuthorityDel = this.getTreatmentRecordAuthorityDel();
    EventBus.$off("changLetterCategory",this.changeTemplate);
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("beforeTreatmentRecordSelectedPatIdChange", this.handleBeforeTreatmentRecordSelectedPatIdChange);
    EventBus.$on("changLetterCategory",this.changeTemplate);
    EventBus.$on("refresh", this.refresh);
    EventBus.$on("beforeTreatmentRecordSelectedPatIdChange", this.handleBeforeTreatmentRecordSelectedPatIdChange);
    // URLダイレクト遷移時、ボタンがメニューバーで隠れてしまっていたので縦幅を計算し直す
    // 観察記録の新規登録の場合はサブカテゴリの先頭の項目を初期選択する
    if (this.isObserveDetail && !this.getUpdateMode) {
      await this.selectFirstSubCategory();
    }
    if (this.isObserveDetail) {
      const resettingList = [];
      const textItem = this.$refs.textArea;
      if (textItem !== undefined) {
        for (const item of textItem) {
          resettingList.push(item.editDataHtmlText);
        }
      }
      for (const resetting of resettingList) {
        if (resetting) {
          const reset = resetting();
          await reset;
        }
      }
    }
    await Promise.allSettled([
      this.getMst(this.getFacilityCd),
    ]);
    //upd #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
    // mod 6757 観察記録の新規登録時、カテゴリ選択を切り替えると入力欄の初期値が正しく表示されない 関 start
    // this.changeCondition(1);
    // if (this.$router.currentRoute.name != "treatment-observe-detail")

    // add #12107 帳票印刷失敗通知が行われない limingzhe 20251114 start
    const defaultPrinterResponse = await ApiHelper.get(`/facilitySetting/getFacilitySettingValue/${this.facilityCd}/1018`);
    const defaultPrinterInfo = defaultPrinterResponse.data;
    if (defaultPrinterInfo && defaultPrinterInfo != "-1") {
      this.defaultPrinter = defaultPrinterInfo;
    } else {
      this.defaultPrinter = this.getMstPrinters[0]?.printerCd;
    }
    // add #12107 帳票印刷失敗通知が行われない limingzhe 20251114 end
    
    // created完了をメイン画面へ通知
    this.$emit("detail-created");
  },

  beforeDestroy() {
    window.removeEventListener("beforeprint", this.handleBeforePrint);
    window.removeEventListener("afterprint", this.handleAfterPrint);

    this.setPatEventRecord(null);
    EventBus.$off("changLetterCategory",this.changeTemplate);
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("beforeTreatmentRecordSelectedPatIdChange", this.handleBeforeTreatmentRecordSelectedPatIdChange);
    this.hideItemPopover();

    // 画面遷移先が、治療記録、治療記録内の機能で、且つ、ord_noを保持している場合はリフレッシュ処理を実施しない
    if (!(this.$router.currentRoute.fullPath.startsWith("/treatment-record/list") && this.getOrdNo)) {
      this.setOrdNo(null);
      this.setDialysisState(null);
      this.setTreatDate(null);
    }

    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  mounted() {
    this.$nextTick(() => {
      // 元のスクロール位置に移動
      this.$refs.tbl.scrollTop = this.scrollTop;
      this.$refs.tbl.scrollLeft = this.scrollLeft;
    });
    // 画像シェーマ用の初期化設定を取得
    this.initStampTextInfo();
    
    // 画面印刷時のイベント追加
    window.addEventListener("beforeprint", this.handleBeforePrint);
    window.addEventListener("afterprint", this.handleAfterPrint);
  },
  destroyed() {
    this.setUpdateMode(true);
    this.setViewMode(true);
    this.setIsEdit(false);
    this.setEditingOrdNo(0);
  },
  computed: {
    ...mapGetters("user", ["getFacilityCd", "getAdvancedSettings"]),
    ...mapGetters("account-edit", {
      getUserId: "getUserId",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("pat-info", ["selectedPatId","selectedPatName"]),
    ...mapGetters("treatment-record/common", ["getOrdNo", "getTreatDate"]),
    ...mapGetters("pat-event/detail", [
      "getPatEventInputParams",
      "getPatEventRecord",
      "getInitPatEventRecord",
      "getPatEventResultParams",
      "getPatEventRegStaffInfo",
      "getBbsInfoNew",
      "getPatEventUpStaffInfo",
      "getPatPlansParams",
      "getFacilityName",
      "getTemplateShow",
      "getViewMode"
    ]),
    ...mapGetters("introduction-letter", [
      "getLetterCategory",
      "getToFacilityCd",
      "getToMedicalInstitutionCd",
      "getReportCd",
      "getPathReal",
      "getDBPath",
      "getDialogMsg",
      "getIsShowSomeThing",
      "getIsUpdateLetter",
      "getIsGoNext",
      "getIsGoNext",
      "getReportList",
      "getCltNo"
      // add #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao start
      ,"getReportIsDel"
      // add #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao end
    ]),
    ...mapGetters("pat-event/list", [
      "getUpdateMode",
      "getMstTemplateRecords",
      "getMstCategoryRecords",
      "getMstSubCategoryRecords",
      "getMstAllTemplateRecords",
      "getMstAllCategoryRecords",
      "getMstAllSubCategoryRecords",
      "getReportFlag",
      "getShowUpload",
      "getSubCategoryCd",
      "getDisplayTwo",
      "getIsOtherFacility",
      "getEventStartDate",
      // add #12462 患者情報共有 start
      "resetIsOtherFacility",
      // add #12462 患者情報共有 end
    ]),
    // add #12462 患者情報共有 start
    ...mapGetters("observe-record/list", ["getIsOtherFacilitys", "resetIsOtherFacilitys"]),
    // add #12462 患者情報共有 end
    ...mapGetters("user", {
      facilityCd: "getFacilityCd"
    }),
    ...mapGetters("bread-crumb", {keepHistories: "getKeepHistory"}),
    ...mapGetters("treatment-record/common", ["getSharedFacilityCd"]),
    ...mapGetters("pat-event/viewer", ["getCompareViewImgs"]),
    ...mapGetters("report", ["getMstPrinters"]),

    isSaveButtonDisabled() {

      if (!this.hasBasicAuthority) {
        return true;
      }

      if (this.hasEditRestriction) {
        return true;
      }

      if (!this.hasContentChanged) {
        return true;
      }

      if (this.hasSpecialRestriction) {
        return true;
      }

      return false;
    },


    hasBasicAuthority() {
      return this.getItemAuthorized('PatEvent', 'default_authority');
    },


    hasEditRestriction() {
      return this.isReadOnly || !this.isShared;
    },


    hasContentChanged() {
      return !this.getUpdateMode || this.isChanged;
    },


    hasSpecialRestriction() {
      // 紹介状以外の場合のパラメータチェック
      const hasEmptyParams = this.getPatEventRecord &&
        this.getPatEventRecord.useType !== 3 &&
        (this.getPatEventInputParams === null ||
         (this.getPatEventInputParams.length === 0 &&
          this.inputModel.subCategoryCd !== 0));

      return (
        this.getIsShowSomeThing ||
        this.getIsGoNext ||
        hasEmptyParams
      );
    },

    isVa() {
      if (this.inputModel.subCategoryCd !== 0) {
        const subCategories = this.getMstSubCategoryRecords;
        const subCategory = subCategories.find(item => {
          return item.subCategoryCd === this.inputModel.subCategoryCd;
        });
        if (subCategory.useType === 1) {
          return true;
        }
      }
      return false;
    },
    isObserveDetail() {
      return this.isObserveRecordDetail || this.isTreatmentObserveDetail;
    },
    isObserveRecordDetail() {
      return this.selfScreenName === "observe-record-detail";
    },
    isTreatmentObserveDetail() {
      return this.selfScreenName === "treatment-observe-detail";
    },
    // add 9868 特定の操作で紹介状で紹介状以外の患者イベントを新規作成できてしまう 関 start
    isPatIntroLetter() {
      return this.selfScreenName === "pat-intro-letter";
    },
    // add 9868 特定の操作で紹介状で紹介状以外の患者イベントを新規作成できてしまう 関 end
    getBtnDisplay() {
      if (!this.getPatEventRecord) {
        return "none";
      }
      const selected = this.getPatEventRecord.subCategoryCd > 0;
      if (!selected && this.getViewMode) {
        return "none";
      }
      return "inline-flex";
    },
    getUpdateDisplay() {
      if (this.getUpdateMode) {
        return "none";
      }
      return "inline";
    },
    selectTemplates() {
      let dataTable = [];
      let subCategories = null;
      if (this.isObserveDetail) {
        subCategories = deepCopy(
          this.mstSubCategoryRecords.filter(item => item.useType === 2)
        );
      } else {
        subCategories = deepCopy(this.mstSubCategoryRecords);
      }
      let templates = null;
      let categories = null;
      if(this.getUpdateMode){
        templates = this.mstAllTemplateRecords;
        categories = this.mstAllCategoryRecords;
      }else{
        templates = this.mstTemplateRecords;
        categories = this.mstCategoryRecords;
      }
	  subCategories = this.sortDispData(categories,subCategories);
      for (const subCategory of subCategories) {
        let category = null;
        category = categories.find(item => {
          return item.categoryCd === subCategory.categoryCd;
        });
        let template = null;
        if (subCategory.useType === 3) {
          // 紹介状の場合は subCategory.templateCd には reportCd が入っているため template は参照しない
          template = undefined;
        } else {
          template = templates.find(item => {
            return item.templateCd === subCategory.templateCd;
          });
        }
        if (category !== undefined) {
          if(template !== undefined){
            if (template.templateName) {
              let boolean = false;
              dataTable.forEach(item => {
                if(item.categoryCode === category.categoryCd){
                  boolean = true;
                  return;
                }
              })
              if(!boolean){
                dataTable.push({
                  categoryCode: category.categoryCd,
                  code: 0.1,
                  name: category.categoryName
                });
              }
              dataTable.push({
                code: subCategory.subCategoryCd,
                name: "\xa0" + "\xa0" + "\xa0" + "\xa0" + "\xa0" + subCategory.subCategoryName
              });
              /*del FNSI-改修内容患者イベント画面の右側のカテゴリ選択に紹介状の内容がない。任 start*/
              /*}*/
              /*dels FNSI-改修内容患者イベント画面の右側のカテゴリ選択に紹介状の内容がない。任 end*/
              //mod FNSI-改修内容紹介状レポート選択画面削除 任 end
              /*add FNSI-改修内容患者イベント画面の右側のカテゴリ選択に紹介状の内容がない。任 start*/
            }
          }else{
            if (subCategory.useType === 3) {
              this.returnReportList();
              this.reportList.forEach(item => {
                if(item.reportCd === subCategory.templateCd){
                  let boolean = false;
                  dataTable.forEach(item => {
                    if(item.categoryCode === category.categoryCd){
                      boolean = true;
                      return;
                    }
                  })

                  if(!boolean){
                    dataTable.push({
                      categoryCode: category.categoryCd,
                      code: 0.1,
                      name: category.categoryName
                    });
                  }

                  dataTable.push({
                    code: subCategory.subCategoryCd + "-" + item.reportCd,
                    name: "\xa0" + "\xa0" + "\xa0" + "\xa0" + "\xa0" + subCategory.subCategoryName
                  });
                }
              })
            }
          }
        }
      }
      return dataTable;
    },

    isReadOnly() {
      return !(
        this.getPatEventRecord &&
        this.getPatEventRecord.patId === this.selectedPatId
      );
    },
    subCategorySelectValue: {
      get() {
        if(this.getPatEventRecord.reportCd!==0 && this.getPatEventRecord.reportCd!==undefined){
          return this.getPatEventRecord.subCategoryCd + "-" + this.getPatEventRecord.reportCd;
        }else{
          return this.getPatEventRecord.subCategoryCd;
        }
      },
      set(value) {
        if (value) {
          this.setSelectSubCategory(value);
        }
      }
    },
    isViewScore() {
      return this.getAdvancedSettings.func_advcds.some(
        setting => setting.func_advcd === ADVANCED_SETTINGS.PATEVENT_SCORE_CALC
      );
    },
    isShared() {
      if(this.getPatEventRecord.isComRec){
        return this.getFacilityCd === this.getSharedFacilityCd;
      }
      return true;
    },
    getFlag(){
      return this.$parent.$data.flag;
    },
    /** イベント開始日を設定 */
    computedCreatedDate() {
      // 治療記録＞観察記録
      if (this.getTreatDate) {
        return moment(this.getTreatDate).format("YYYY-MM-DD");
      }
      // 患者カレンダーから新規作成で遷移してきた場合、カレンダーでクリックした日付をイベント開始日にする
      if (this.getEventStartDate) {
        return this.getEventStartDate;
      }
      // 上記以外はシステム日付
      return moment().format("YYYY-MM-DD");
    },
    /**
     * プリンターが登録されているか.
     *
     * @returns true : プリンタが登録されている場合
     *          false : プリンタが登録されていない場合
     */
    hasPrinter() {
      return this.getMstPrinters.length > 0;
    },
    // add #12462 患者情報共有 20260310 start
    isOtherFacilityDisabled() {
      return this.getIsOtherFacility;
    },
    // add #12462 患者情報共有 20260310 end
  },
  methods: {
    ...mapActions("mst-pat-event-template", ["sendRequestGetSysDataSetResult"]),
    ...mapActions("pat-event/detail", [
      "setPatEventCreate",
      "setPatEventUpdate",
      "setPatEventDelete",
      "setPatEventRecord",
      "setInitPatEventRecord",
      "setPatEventUpdateResultParamas",
      "setPatEventUpdateBbsCtlNo",
      "setViewMode",
      "setShowFile",
      "setPatEventList",
      "setTemplateShow",
      "setPatEventInputParams",
      "setPatPlansParams",
      "setIsNotificationFlg",
      "fetchOrdMainRecord",
      "setSkipRoute",
      "getMst",
    ]),
    ...mapActions("pat-event/list", ["setUpdateMode", "setIsEdit","setDisplayTwo","setPatEventFlg","setSubCategoryCd","setMstAllSubCategoryRecords","setMstSubCategoryRecords","fetchPatEventMaster"]),
    ...mapActions("pat-event/image-editor", ["initStampTextInfo"]),
    ...mapActions("pat-info", ["setReportStartDate"]),
    ...mapActions("introduction-letter", [
      "onPrintLetter",
      "onUpdatePatInfo",
      "setReportList",
      "setPath",
      "setDBPath",
      "setIsGoNext",
      "setUpdatePdf",
      "setIsShowSomeThing",
      "setIsUpdateLetter",
      "setTemplate"
    ]),
    ...mapActions("account-edit", ["setIsDispSidebarBtn"]),
    ...mapActions("multi-modal", ["showReportList"]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    ...mapActions("treatment-record/common", ["setOrdNo", "setDialysisState", "setTreatDate"]),
    ...mapActions("pat-event/viewer", [
      "setCompareViewImgsReplaceSrc",
      "setCompareViewImgsDelete",
      "setCompareViewImgsMsg",
      "setCompareViewImgsTrue"
    ]),
    // 予実リストへの変更通知
    ...mapActions("indication-result", ["setResultUpdate"]),
    ...mapActions("observe-record/list", [
      "setEditingOrdNo"
    ]),
    ...mapMutations("treatment-record/common", ["setSharedFacilityCd"]),
       
    /** 画面印刷前の処理 */
    handleBeforePrint() {
      document.querySelectorAll(".print-textarea").forEach(el => el.remove());
      
      // リッチテキストエディタ 印刷用のdiv作成
      const editors = document.querySelectorAll(".k-editor iframe");
      editors.forEach((iframe, i) => {
        const body = iframe.contentDocument?.body;
        if (!body) return;
        const html = body.innerHTML;
        // 表示用div作成
        const div = document.createElement("div");
        div.className = "print-textarea";
        div.innerHTML = html;
        
        const style = iframe.contentWindow.getComputedStyle(body);
        div.style.fontSize = style.fontSize;
        div.style.fontFamily = style.fontFamily;
        div.style.lineHeight = style.lineHeight;
        // iframeの後ろに追加
        iframe.parentNode.appendChild(div);
      });
           
      // 書式設定なし テキストエリア 印刷用のdiv作成
      const textareas = Array.from(document.querySelectorAll("textarea"))
        .filter(el => el.offsetParent !== null);
      textareas.forEach(el => {
        const div = document.createElement("div");
        div.className = "print-textarea";
        // 値コピー（改行そのまま）
        div.innerText = el.value;
        // textareaの後ろに追加
        el.parentNode.appendChild(div);
      });
      
      // 観察記録＞観察記録詳細はmainが2個存在するので、2個目をabsoluteしないと空ページ出る
      const mains = document.getElementsByClassName("main");
      // 2個目
      if (mains.length > 1) {
        const second = mains[1];
        second.dataset.originalPosition = second.style.position || "";
        second.style.setProperty("position", "absolute", "important");
      }
    },
    /** 画面印刷後の処理 */
    handleAfterPrint() {      
      // 追加した表示用テキストエリアのdiv削除
      document.querySelectorAll(".print-textarea").forEach(el => el.remove());
      
      // mainを元に戻す
      const mains = document.getElementsByClassName("main");
      // 2個目
      if (mains.length > 1) {
        const second = mains[1];
        second.style.position = second.dataset.originalPosition || "";
        delete second.dataset.originalPosition;
      }
    },
    
    async setSelectSubCategory(value) {
      if(value.indexOf("-")!==-1){
        this.inputModel.subCategoryCd = parseInt(value.split("-")[0]);
        this.inputModel.subReportCd = parseInt(value.split("-")[1]);
      }else{
        this.inputModel.subCategoryCd = parseInt(value);
        this.inputModel.subReportCd = 0;
      }
      const rec = deepCopy(this.getPatEventRecord);
      if (this.getPatEventInputParams) {
        rec.inputParams = JSON.stringify(this.getPatEventInputParams);
      } else {
        rec.inputParams = null;
      }
      rec.resultParams = JSON.stringify(this.getPatEventResultParams);
      rec.regStaffInfo = JSON.stringify(this.getPatEventRegStaffInfo);
      rec.upStaffInfo = JSON.stringify(this.getPatEventUpStaffInfo);
      rec.subCategoryCd = this.inputModel.subCategoryCd;
      rec.reportCd = this.inputModel.subReportCd;
      await this.setPatEventRecord(rec);
    },
    returnReportList(){
      this.reportList = this.getReportList;
    },
    // カテゴリ選択の変更
    async changeSelectedTemplate() {
      // 画面表示 ≠ 初期表示の場合
      if (this.getPatEventRecord.subCategoryCd !== 0) {
        // 内容破棄確認処理
        if (await this.confirmAllowDiscardChanges()) {
          // テンプレートの切替
          await this.changeTemplate();
        } else {
          // 紹介状の場合
          if(this.backupPatEventRecord.reportCd !== 0 && this.backupPatEventRecord.reportCd !== undefined){
            const value = this.backupPatEventRecord.subCategoryCd.toString() + "-" + this.backupPatEventRecord.reportCd.toString();
            await this.setSelectSubCategory(value);
          }else{
            const value = this.backupPatEventRecord.subCategoryCd.toString();
            await this.setSelectSubCategory(value);
          }
        }
      }
    },
    //add FNSI-改修内容紹介状レポート選択画面削除 任 end
    async changeTemplate() {
      this.setPatEventInputParams();
      this.itemKey++;
      this.setPath(null);
      this.letterFileName = "";
      this.setDBPath(null);
      // 通知チェックをリセット
      this.isNotification = false;
      if (this.inputModel.subCategoryCd === 0) {
        await this.setPatEventInfo(null);
        this.setViewMode(true);
        this.setIsEdit(false);
        return;
      }
      const subCategorys = this.getMstSubCategoryRecords;
      const subCategory = subCategorys.find(item => {
        return item.subCategoryCd === this.inputModel.subCategoryCd;
      });
      // デグレ：治療実績リンクの選択肢に実績のない日が表示される  5673  shan   start
      if(subCategory.useType === 2){
        if(this.$route.name === "pat-event"){
          if(this.$refs.datalink){
            if(this.$refs.datalink.length > 0){
              this.$refs.datalink[0].getOrdMain();
            }
          }


        }
      }
      this.setSubCategoryCd(this.inputModel.subCategoryCd);
      const templateCd = subCategory.templateCd;
      let template = null;
      if(subCategory.useType === 3){
        template = this.reportList.find(item => {
          return item.reportCd === templateCd;
        })
      }else{
        const templates = this.getMstTemplateRecords;
        template = templates.find(item => {
          return item.templateCd === templateCd;
        });
      }
      if (subCategory.useType === 3) {
        this.setUpdatePdf(true);
        /*add FNSI-改修内容患者イベントbug 任 end*/
        if(this.inputModel.subReportCd !== undefined){
          this.setLoadingScreenVisible(true);
          await this.setTemplate({
            patId: this.getPatEventRecord.patId,
            reportCd: this.inputModel.subReportCd
            // add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao start
            ,reportStartDate: this.getReportStartDateValue() == null ? "undefined": this.getReportStartDateValue()
            // add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao end
          });
          this.setLoadingScreenVisible(false);
        }else{
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES[12000172].title,
            // message: "紹介状の帳票が存在していません。"
            message: messageFormat(DIALOG_MESSAGES[12000172].message)
          });
        }
      }else{
        await this.setIsShowSomeThing(false);
      }
      if(subCategory.useType === 2){
        this.setPatEventFlg(true);
      }else{
        this.setPatEventFlg(false);
      }
      this.setPatEventInfo(template, subCategory);
      this.setDisplayTwo(false);
      this.setViewMode(false);
      this.setIsEdit(true);
      this.setIsGoNext(false);
      this.backupPatEventRecord = deepCopy(this.getPatEventRecord);
      this.setInitPatEventRecord(deepCopy(this.getPatEventRecord));
      if(this.$refs.patIntroductionLetter!==undefined){
        this.$refs.patIntroductionLetter.handleEnableControl();
      }
      if ((this.getPatEventInputParams === null || this.getPatEventInputParams === 0) && this.getPatEventRecord.useType != 3) {
        this.msgDiaLog = DIALOG_MESSAGES["02700016"].message;
      }else {
        this.msgDiaLog = "";
      }
      if (this.$refs.tab) {
        this.$refs.tab.inputModel.dayStartDate = this.computedCreatedDate;
      }
      // add #12370 紹介状の転入の動作不正 zhao start
      if(!this.getReportFlag && this.$refs.patIntroductionLetter){
        this.$refs.patIntroductionLetter.setReportFlagFalse();
      }
      // add #12370 紹介状の転入の動作不正 zhao end
    },
    /**
     * 詳細画面の展開時、患者イベント情報
     */
    async setPatEventInfo(template, subCategory) {
      let rec = deepCopy(this.getPatEventRecord);
      let result = [];
      if (template === null) {
        rec.templateCd = 0;
        rec.templateName = "";
        rec.inputParams = JSON.stringify(result);
        rec.resultParams = JSON.stringify(result);
        rec.categoryCd = 0;
        rec.categoryName = "";
        rec.subCategoryCd = 0;
        rec.subCategoryName = "";
        rec.useType = 0;
        rec.regStaffInfo = JSON.stringify(this.getPatEventRegStaffInfo);
        rec.upStaffInfo = JSON.stringify(this.getPatEventUpStaffInfo);
        await this.setPatEventRecord(rec);
        return;
      }
      /*mod FNSI-改修内容患者イベント画面の右側のカテゴリ選択に紹介状の内容がない。任 start*/
      /*rec.templateCd = template.templateCd;
      rec.templateName = template.templateName;
      rec.inputParams = template.inputParams;
      //項目実績の想定する必要な情報を生成
      /!*add FNSI-改修内容患者イベントテンプレートマスタで内容が空白のテンプレートを作成するときの患者イベント画面の表示修正 任 start*!/
      if(template.inputParams !== null){*/
      if(template.reportCd === undefined){
        rec.templateCd = template.templateCd;
        rec.inputParams = template.inputParams;
      }else{
        rec.templateCd = template.reportCd;
        rec.inputParams = null;
      }
      rec.templateName = template.templateName;
      //項目実績の想定する必要な情報を生成
      /*add FNSI-改修内容患者イベントテンプレートマスタで内容が空白のテンプレートを作成するときの患者イベント画面の表示修正 任 start*/
      if(template.inputParams !== null && template.inputParams !== undefined){
        /*mod FNSI-改修内容患者イベント画面の右側のカテゴリ選択に紹介状の内容がない。任 end*/
        /*add FNSI-改修内容患者イベントテンプレートマスタで内容が空白のテンプレートを作成するときの患者イベント画面の表示修正 任 end*/
        //upd #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
        for (const item of JSON.parse(template.inputParams)) {
          let performance = null;
          switch (item.format_class) {
            case 1:
            case 8:
            case 9:
            case 10:
              if(item.format_class === 1 && item?.item_json?.is_formatting == '1'){
                performance = {
                  format_class: item.format_class,
                  result_value: item?.item_json?.html_value
                };
              }else{
                performance = {
                  format_class: item.format_class,
                  result_value: ""
                };
              }
              break;
            case 3:
            case 4:
            case 6:
              performance = {
                format_class: item.format_class,
                result_value: []
              };
              break;
            case 0:
              performance = {
                format_class: item.format_class,
                result_value: item?.item_json?.default_value
              };
              break;
            case 2:
              performance = {
                format_class: item.format_class,
                result_value: this.getTemplateImage(item?.item_json?.image_num)
              };
              break;
            case 5:
              performance = {
                format_class: item.format_class,
                result_value: this.getTemplateDate(item?.item_json?.date_class)
              };
              break;
            case 7:
              performance = {
                format_class: item.format_class,
                result_value: []
              };
              break;
          }
          result.push(performance);
          /*add FNSI-改修内容患者イベントテンプレートマスタで内容が空白のテンプレートを作成するときの患者イベント画面の表示修正 任 start*/
        }
        /*add FNSI-改修内容患者イベントテンプレートマスタで内容が空白のテンプレートを作成するときの患者イベント画面の表示修正 任 end*/
      }
      /*add FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 start*/
      const upDate = {
        upDate: template.upDate
      }
      result.push(upDate)
      /*add FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 end*/
      rec.resultParams = JSON.stringify(result);
      //カテゴリをセット
      rec.categoryCd = subCategory.categoryCd;
      rec.categoryName = this.getMstCategoryRecords.find(
          record => record.categoryCd === subCategory.categoryCd
      ).categoryName;
      //サブカテゴリをセット
      rec.subCategoryCd = subCategory.subCategoryCd;
      rec.subCategoryName = this.getMstSubCategoryRecords.find(
          record => record.subCategoryCd === subCategory.subCategoryCd
      ).subCategoryName;
      rec.useType = subCategory.useType;
      rec.regStaffInfo = JSON.stringify(this.getPatEventRegStaffInfo);
      rec.upStaffInfo = JSON.stringify(this.getPatEventUpStaffInfo);
      await this.setPatEventRecord(rec);
    },
    //upd #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc end
    //add #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
    getTemplateDate(classDate) {
      // #10228 新規登録、造設日が空の場合、データベースでresultvalueは空の文字列です。linjunfeng start
      // let templateDateRst = '';
      let templateDateRst = null;
      // #10228 新規登録、造設日が空の場合、データベースでresultvalueは空の文字列です。linjunfeng end
      let today = new Date();
      if (classDate === "1") {
        templateDateRst = dateFormat.format(
            // #10228 テンプレートの日付フィールド「当日」の場合 開始日に連動して同日 linjunfeng start
            // new Date(today.getFullYear(), today.getMonth(), today.getDate()),
            new Date((this.computedCreatedDate)),
            // #10228 テンプレートの日付フィールド「当日」の場合 開始日に連動して同日 linjunfeng end
            DATE_FORMAT
        );
      } else if (classDate === "2") {
        templateDateRst = dateFormat.format(
            new Date(today.getFullYear(), today.getMonth(), today.getDate()),
            DATE_FORMAT
        );
      } else if (classDate === "3") {
        templateDateRst = dateFormat.format(
            new Date(today.getFullYear(), today.getMonth(), today.getDate() + 1),
            DATE_FORMAT
        );
      } else if (classDate === "4") {
        templateDateRst = dateFormat.format(
            new Date(today.getFullYear(), today.getMonth(), today.getDate() + 2),
            DATE_FORMAT
        );
      } else if (classDate === "5") {
        templateDateRst = dateFormat.format(
            new Date(today.getFullYear(), today.getMonth(), today.getDate() - 1),
            DATE_FORMAT
        );
      } else if (classDate === "6") {
        templateDateRst = dateFormat.format(
            new Date(today.getFullYear(), today.getMonth(), today.getDate() - 2),
            DATE_FORMAT
        );
      }
      // del 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 start
      // else {
      //   templateDateRst = dateFormat.format(
      //       new Date(today.getFullYear(), today.getMonth(), today.getDate()),
      //       DATE_FORMAT
      //   );
      // }
      // del 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 end
      return templateDateRst;
    },

    getTemplateImage(imageNum) {
      const num = Number(imageNum);
      if (isNaN(num) || num < 0) {
        return [];
      }
      return Array.from({ length: num }, () => {
        if (this.isVa) {
          return { name: '', file_name: '', file_path: '', is_send_va: '0', file_modified_time: '' };
        } else {
          return { file_name: '', file_path: '', file_modified_time: '' };
        }
      });
    },
    //add #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc end
    /**
     *
     */
    async validateData() {
      // タブチェック
      if (this.$refs.tab !== undefined) {
        const onRegistration = this.$refs.tab.validateOnRegistration;
        if (onRegistration) {
          const validationResult = onRegistration();
          if (!validationResult) {
            return {
              validateData: false
            };
          }
        }
      }
      const patEventRec = this.getPatEventRecord;
      if (patEventRec.useType === 3) return { validateData: true };
      const onRegistrationList = [];
      // 0.テキストチェック
      const textItem = this.$refs.text;
      if (textItem !== undefined) {
        for (const item of textItem) {
          onRegistrationList.push(item.validateOnRegistration);
        }
      }
      // 1.テキストエリアチェック
      const textAreaItem = this.$refs.textArea;
      if (textAreaItem !== undefined) {
        for (const item of textAreaItem) {
          onRegistrationList.push(item.validateOnRegistration);
        }
      }
      // 2.画像チェック
      const imageItem = this.$refs.image;
      if (imageItem !== undefined) {
        for (const item of imageItem) {
          onRegistrationList.push(item.validateOnRegistration);
        }
      }
      // 8.計算チェック
      const calcItem = this.$refs.calc;
      if (calcItem !== undefined) {
        for (const item of calcItem) {
          onRegistrationList.push(item.validateOnRegistration);
        }
      }
      // 10.掲示板チェック
      const bbsItem = this.$refs.bbs;
      if (bbsItem !== undefined) {
        for (const item of bbsItem) {
          onRegistrationList.push(item.validateOnRegistration);
        }
      }
      // add 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 start
      // 5.日付
      const dateItem = this.$refs.date;
      if (dateItem !== undefined) {
        for (const item of dateItem) {
          onRegistrationList.push(item.validateOnRegistration);
        }
      }
      // add 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 end
      for (const onRegistration of onRegistrationList) {
        if (onRegistration) {
          const validationResult = onRegistration();
          const ret = await validationResult;
          if (!ret) {
            return {
              validateData: false
            };
          }
        }
      }
      return {
        validateData: true
      };
    },
    /** sys_data_set実績取得処理 */
    patEventImport({ index, sqlCd }) {
      const patId = this.getPatEventRecord.patId;
      const ordNo = this.getPatEventRecord.ordNo;
      let startDate = this.getPatEventRecord.eventStartDate;
      let endDate = this.getPatEventRecord.eventEndDate;
      if (startDate) {
        // 登録済みデータあり時
        startDate = moment(startDate).format("YYYYMMDD");
        endDate = moment(endDate).format("YYYYMMDD");
      } else {
        // 作成済みデータなし時
        startDate = moment(this.getPatPlansParams.startDate).format("YYYYMMDD");
        endDate = moment(this.getPatPlansParams.startDate)
          .add(this.getPatPlansParams.dateClass, "days")
          .format("YYYYMMDD");
      }
      this.sendRequestGetSysDataSetResult({
        cd: sqlCd,
        pat: patId,
        ord: ordNo ? ordNo : undefined,
        from: startDate,
        to: endDate
      })
        .then(r => {
          let isExist = false;
          if (this.$refs.text) {
            for (const txt of this.$refs.text) {
              if (txt.propsIndex === index) {
                txt.dataImportResult(r.data);
                isExist = true;
                break;
              }
            }
          }
          if (!isExist && this.$refs.textArea) {
            for (const txt of this.$refs.textArea) {
              if (txt.propsIndex === index) {
                txt.dataImportResult(r.data);
                isExist = true;
                break;
              }
            }
          }
        })
        .catch(e => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('PatEventDetailComponent.vue', 'patEventImport', e);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        });
    },
    getReportStartDateValue() {
      return this.$refs.patIntroductionLetter ? this.$refs.patIntroductionLetter.getReportStartDateValue() : null;
    },
    /**
     *
     */
    async registration() {
      /*add FNSI-改修内容日付のチェックの追加対応。 任 start*/
      const dateArray = [
        {
          //#10715:日付IF修正Start
          dateItem: document.getElementsByClassName("DateInput").length > 0 ? document.getElementsByClassName("DateInput")[0].validationMessage : "",
          //#10715:日付IF修正End
          dateName: ["イベント開始日時"]
        },
        {
          dateItem: document.getElementsByClassName("every-start-date").length > 0 ? document.getElementsByClassName("every-start-date")[0].validationMessage : "",
          dateName: ["作成開始日付"]
        },
        {
          dateItem: document.getElementsByClassName("every-end-date").length > 0 ? document.getElementsByClassName("every-end-date")[0].validationMessage : "",
          dateName: ["作成終了日付"]
        },
        {
          dateItem: document.getElementsByClassName("week-start-date").length > 0 ? document.getElementsByClassName("week-start-date")[0].validationMessage : "",
          dateName: ["作成開始日付"]
        },
        {
          dateItem: document.getElementsByClassName("week-end-date").length > 0 ? document.getElementsByClassName("week-end-date")[0].validationMessage : "",
          dateName: ["作成終了日付"]
        },
        {
          dateItem: document.getElementsByClassName("month-start-date").length > 0 ? document.getElementsByClassName("month-start-date")[0].validationMessage : "",
          dateName: ["作成開始日付"]
        },
        {
          dateItem: document.getElementsByClassName("month-end-date").length > 0 ? document.getElementsByClassName("month-end-date")[0].validationMessage : "",
          dateName: ["作成終了日付"]
        },
        {
          //#10715:日付IF修正Start
          dateItem: document.getElementsByClassName("DateInput").length > 0 ? document.getElementsByClassName("DateInput")[0].validationMessage : "",
          //#10715:日付IF修正End
          dateName: ["イベント開始日時"]
        },
        {
          dateItem: this.$refs.patIntroductionLetter ? this.$refs.patIntroductionLetter.getReportStartDateValidationMessage() : "",
          dateName: ["転入転出日"]
        },
        {
          dateItem: document.getElementsByClassName("notice-start-date").length > 0 ? document.getElementsByClassName("notice-start-date")[0].validationMessage : "",
          dateName: ["掲載期間開始日時"]
        },
        {
          dateItem: document.getElementsByClassName("notice-end-date").length > 0 ? document.getElementsByClassName("notice-end-date")[0].validationMessage : "",
          dateName: ["掲載期間終了日時"]
        },
        // del 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 start
        // {
        //   dateItem: document.getElementsByClassName("input-model-date").length > 0 ? document.getElementsByClassName("input-model-date")[0].validationMessage : "",
        //   dateName: [document.getElementById("input-model-file-name") !== null ? document.getElementById("input-model-file-name").innerText : ""]
        // }
        // del 10228 【因島データ】差分コンバートでVA管理の造設日が正しく反映されていない 関 end
      ];
      for(let i = 0; i<dateArray.length;i++){
        if(dateArray[i].dateItem !== ""){
          this.messageDateInfo.isCheckDialogVisible = true;
          this.messageDateInfo.title = DIALOG_MESSAGES[99999996].title;
          this.messageDateInfo.messageCd = 99999996;
          this.messageDateInfo.stringParams = dateArray[i].dateName;
          return;
        }
      }
      /*add FNSI-改修内容538 連携イベントの登録適正化 任 start*/
      let patEventCd = 0;
      /*add FNSI-改修内容538 連携イベントの登録適正化 任 end*/
      /*add FNSI-改修内容日付のチェックの追加対応。 任 end*/
      if (this.$refs.tab !== undefined) {
        await this.$refs.tab.changeCondition(this.$refs.tab.tabSelectedId);
      }

      if (this.$refs.patIntroductionLetter) {
        // 紹介状の入力チェック
        if (!(await this.$refs.patIntroductionLetter.validateBeforeRegister())) {
          return false;
        }
        // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260424 start
        await this.$refs.patIntroductionLetter.saveLetterImages();
        // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260424 end
      }

      let returnCode = 0;
      const validationResult = await this.validateData();
      if (validationResult === undefined) {
        return false;
      }
      // アップロード対象の添付ファイルの存在チェック
      const onFileExistsCheckList = [];
      const fileItem = this.$refs.file;
      if (fileItem !== undefined) {
        for (const item of fileItem) {
          onFileExistsCheckList.push(item.uploadFileExistsCheck);
        }
      }
      for (const onFileExistsCheck of onFileExistsCheckList) {
        if (onFileExistsCheck) {
          let fileName = await onFileExistsCheck();
          if(fileName){
            this.$ons.notification.alert({
              // title: "チェックエラー",
              // message: "指定されたファイルが見つかりません"
              title: DIALOG_MESSAGES[12000349].title,
              message: messageFormat(DIALOG_MESSAGES[12000349].message,fileName)
            });
            return false;
          }
        }
      }
      // アップロード対象の画像ファイルの存在チェック
      const onImageExistsCheckList = [];
      const imageItem = this.$refs.image;
      if (imageItem !== undefined) {
        for (const item of imageItem) {
          onImageExistsCheckList.push(item.uploadImageFileExistsCheck);
        }
      }
      for (const onImageExistsCheck of onImageExistsCheckList) {
        if (onImageExistsCheck) {
          let fileName = await onImageExistsCheck();
          if (fileName) {
            await this.$ons.notification.alert({
              // title: "チェックエラー",
              // message: "指定されたファイルが見つかりません"
              title: DIALOG_MESSAGES[12000349].title,
              message: messageFormat(DIALOG_MESSAGES[12000349].message,fileName)
            });
            return false;
          }
        }
      }
      let reportDate = this.getReportStartDateValue();
      if (!reportDate) {
        // reportDate が null や "" の場合はデフォルト値としてシステム日付を設定する
        // 紹介状では必須入力項目のため本来は発生しない条件だがリストの検索条件に使用されるカラムのため
        // 万一にもnullのままにならないようにしておく
        reportDate = moment().format("YYYY-MM-DD");
      }
      if (Object.values(validationResult).every(v => v === true)) {
        this.backupPatEventRecord = null;
        // ＤＢ更新
        const rec = deepCopy(this.getPatEventRecord);
        if (this.getPatEventInputParams) {
          rec.inputParams = JSON.stringify(this.getPatEventInputParams);
        } else {
          rec.inputParams = null;
        }
        rec.resultParams = JSON.stringify(this.getPatEventResultParams);
        rec.regStaffInfo = JSON.stringify(this.getPatEventRegStaffInfo);
        rec.upStaffInfo = JSON.stringify({
          up_staff_cd: this.getStateUserAccountInfo.userId,
          up_staff_name: this.getStateUserAccountInfo.userLastName + this.getStateUserAccountInfo.userFirstName
        });
        rec.scoreTotal = this.calcTotalScore(this.getPatEventResultParams);
        if(null != this.getPathReal){
          rec.reportUrl = this.getDBPath;
        }
        // 紹介状情報
        if (rec.useType === 3) {
          rec.reportDate = reportDate;
          // 紹介状のイベント開始日・イベント終了日は転入出日付と同じ値とする
          rec.eventEndDate = rec.eventStartDate = rec.reportDate;
          // add #12370 紹介状の転入の動作不正 zkm start
          const isTransferIn = '1' === this.getLetterCategory;
          if (isTransferIn) {
            rec.templateCd = null;
          }
          // add #12370 紹介状の転入の動作不正 zkm end
          rec.letterInfo = JSON.stringify({
            // add 11488 紹介状登録内容保存時に帳票の版も記憶する　1.1A  吉 start
            ctlNo:this.getCltNo,
            // add 11488 紹介状登録内容保存時に帳票の版も記憶する　1.1A  吉 end
            letter_category: +this.getLetterCategory,
            to_facility_cd: this.getToFacilityCd,
            to_medical_institution_cd:this.getToMedicalInstitutionCd,
            // mod #12370 紹介状の転入の動作不正 zkm start
            // report_cd: this.getReportCd,
            report_cd: isTransferIn ? null : this.getReportCd,
            // mod #12370 紹介状の転入の動作不正 zkm end
            isUpdateLetter: this.getIsUpdateLetter,
            // mod #12370 紹介状の転入の動作不正 zkm start
            // letter_data: this.$refs.patIntroductionLetter.getLetterData()
            letter_data: isTransferIn ? null : this.$refs.patIntroductionLetter.getLetterData()
            // mod #12370 紹介状の転入の動作不正 zkm end
          });
          const params = {
            mode: 1,
            startDate: rec.eventStartDate,
            endDate: null,
            interval: 0,
            intervalClass: null,
            startTime: null,
            dateClass: 0,
            endTime: null
          };
          await this.setPatPlansParams(params);
        }
        let patEventList = [];
        let bbsCtlNoList = [];
        let patEventCdList = [];
        if (!this.getUpdateMode) {
          let tempResultParams = JSON.parse(rec.resultParams);
          tempResultParams.forEach((item,itemIndex,itemArray) => {
            if(item.format_class === 7){
              let path = rec.patId + "/" + rec.patEventCd + "/" + "file" + "/" + itemIndex + "/";
              item.result_value.forEach((file,fileIndex,fileArray) => {
                fileArray[fileIndex].file_path = path + file.file_name;
              });
              itemArray[itemIndex].result_value = item.result_value;
            }
          });
          rec.resultParams = JSON.stringify(tempResultParams);
          // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start
          if (rec.useType === 3 && this.copySourcePatEventCd) {
            try {
              if (rec.letterInfo) {
                const letterInfo = JSON.parse(rec.letterInfo);
                const originalPatEventCd = this.copySourcePatEventCd;
                if (letterInfo.letter_data) {
                  Object.keys(letterInfo.letter_data).forEach(key => {
                    const value = letterInfo.letter_data[key];
                    if (typeof value === 'string') {
                      const imagePathRegex = /(\d+)\/image\//g;
                      let match;
                      let updatedValue = value;
                      while ((match = imagePathRegex.exec(value)) !== null) {
                        const currentPatEventCd = match[1];
                        if (currentPatEventCd === '0' || currentPatEventCd === '0') {
                          const newPath = value.replace(
                            new RegExp(`/${currentPatEventCd}/image/`, 'g'),
                            `/${originalPatEventCd}/image/`
                          );
                          updatedValue = newPath;
                        }
                      }
                      if (updatedValue !== value) {
                        letterInfo.letter_data[key] = updatedValue;
                      }
                    }
                  });
                  letterInfo.isCopy = true;
                  letterInfo.copySourcePatEventCd = originalPatEventCd;
                  rec.letterInfo = JSON.stringify(letterInfo);
                }
              }
            } catch (error) {
              getErrorMessage('PatEventDetailComponent.vue', 'copyLetterImagePath', error);
            }
          }
          // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end
          if(rec.ordNo==0){
            rec.ordNo = null
          }
          // カテゴリタイプ = "2"(観察記録)の場合
          if (rec.useType === 2) {
            // 初期値の取得
            const init = this.getInitPatEventRecord;
            // (新規)観察記録情報の設定
            this.setCreatedObserveRecordInfo(init, rec);
          } else {
            // 観察記録履歴の登録：未実施
            rec.isObserveRecordLog = false;
          }
          const res = await this.setPatEventCreate({
            rec,
            isNotification: this.isNotification
          });
          if (res === "NG001") {
            await this.$ons.notification.alert({
              // title: "登録失敗",
              // message: "患者イベント情報が</br>登録されませんでした。"
              title: DIALOG_MESSAGES[12000173].title,
              message: messageFormat(DIALOG_MESSAGES[12000173].message)
            });
            return;
          } else if (res === "NG002") {
            await this.$ons.notification.alert({
              // title: "登録失敗",
              // message:
              //   "患者イベント情報が</br>登録されませんでした。</br>日付範囲指定の入力内容を確認してください。"
              title: DIALOG_MESSAGES[12000174].title,
              message: messageFormat(DIALOG_MESSAGES[12000174].message)
            });
            return;
          } else {
            patEventList = deepCopy(res);
            for(const item of patEventList){
              patEventCdList.push(item.patEventCd)
            }
            returnCode = patEventList[0].patEventCd;
            // ストアの情報更新（patEventCd）
            await this.setPatEventRecord(deepCopy(patEventList[0]));
          }
        }
        // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260424 start
        if (this.$refs.patIntroductionLetter) {
          await this.$refs.patIntroductionLetter.emitUploadImage();
        }
        // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260424 end
        // 掲示板更新処理
        let bbsCtlNo = 0;
        if(this.$refs.bbs!==undefined) {
          if (this.$refs.bbs.length > 0) {
            if (this.$refs.bbs[0].$data.inputModel.publishedState) {
              const onBbsList = [];
              const bbsItem = this.$refs.bbs;
              if (bbsItem !== undefined) {
                this.setPatEventList(patEventList);
                for (const item of bbsItem) {
                  if (patEventList.length === 0) {
                    onBbsList.push(item.saveRecord);
                  } else {
                    for (let i = 0; i < patEventList.length; i++) {
                      onBbsList.push(item.saveRecord);
                    }
                  }
                }
              }
              for (const onBbs of onBbsList) {
                if (onBbs) {
                  const validationResult = onBbs();
                  bbsCtlNo = await validationResult;
                  bbsCtlNoList.push(bbsCtlNo);
                  if (bbsCtlNo === 0) {
                    await this.$ons.notification.alert({
                      // title: "エラー",
                      // message: "掲示板の登録が</br>出来ませんでした。"
                      title: DIALOG_MESSAGES[12000175].title,
                      message: messageFormat(DIALOG_MESSAGES[12000175].message)
                    });
                    return false;
                  }
                }
              }
            }
          }
        }
        // 添付ファイルアップロード
        const onFileUpLoadList = [];
        const fileItem = this.$refs.file;
        if (fileItem !== undefined) {
          for (const item of fileItem) {
            onFileUpLoadList.push(item.uploadS3File);
          }
        }
        for (const onFileUpLoad of onFileUpLoadList) {
          if (onFileUpLoad) {
            const validationResult = onFileUpLoad();
            const ret = await validationResult;
            if (!ret) {
              await this.$ons.notification.alert({
                // title: "エラー",
                // message: "添付ファイル更新が</br>出来ませんでした。"
                title: DIALOG_MESSAGES[12000176].title,
                message: messageFormat(DIALOG_MESSAGES[12000176].message)
              });
              return false;
            }
          }
        }
        // 画像ファイルアップロード
        const onImageUpLoadList = [];
        const imageItem = this.$refs.image;
        if (imageItem !== undefined) {
          for (const item of imageItem) {
            onImageUpLoadList.push(item.uploadS3File);
          }
        }
        for (const onImageUpLoad of onImageUpLoadList) {
          if (onImageUpLoad) {
            const validationResult = onImageUpLoad();
            const ret = await validationResult;
            if (!ret) {
              await this.$ons.notification.alert({
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // title: "エラー",
                // message: "画像ファイル更新が</br>出来ませんでした。"
                title: DIALOG_MESSAGES[12000177].title,
                message: messageFormat(DIALOG_MESSAGES[12000177].message)
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              });
              return false;
            }
          }
        }
        const updRec = this.getUpdateMode ? deepCopy(this.getPatEventRecord) : deepCopy(patEventList[0]);
        // 紹介状アップロード (正常にアップロード出来たら this.setDBPath; に値を入れておく )
        if (this.letterFile !== undefined && this.letterFileName !== "") {
          const uploadParams = {
            facilityCd: updRec.facilityCd,
            patId: updRec.patId,
            patEventCd: updRec.patEventCd
          }
          const res = await this.letterFileUpload(uploadParams);
          if (res.result) {
            this.setDBPath(res.uplordPath);
          } else {
            await this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "エラー",
              // message: "紹介状更新が</br>出来ませんでした。"
              title: DIALOG_MESSAGES[12000178].title,
              message: messageFormat(DIALOG_MESSAGES[12000178].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
            return false;
          }
        }
        updRec.bbsCtlNo = bbsCtlNo || updRec.bbsCtlNo;
        if (this.getUpdateMode) {
          if (this.getPatEventInputParams) {
            updRec.inputParams = JSON.stringify(this.getPatEventInputParams);
          } else {
            updRec.inputParams = null;
          }
          updRec.resultParams = JSON.stringify(this.getPatEventResultParams);
          updRec.regStaffInfo = JSON.stringify(this.getPatEventRegStaffInfo);
          updRec.upStaffInfo = JSON.stringify({
            up_staff_cd: this.getStateUserAccountInfo.userId,
            up_staff_name: this.getStateUserAccountInfo.userLastName + this.getStateUserAccountInfo.userFirstName
          });
          updRec.scoreTotal = this.calcTotalScore(this.getPatEventResultParams);
        }
        updRec.bbsCtlNo = bbsCtlNo;
        updRec.bbsCtlNoList = bbsCtlNoList;
        updRec.patEventCdList = patEventCdList;
        if(null != this.getPathReal){
          updRec.reportUrl = this.getDBPath;
        }
        //mod オンプレミスの場合、転入患者さんの紹介状が取込できない 吉 end
        // カテゴリタイプ = "2"(観察記録)の場合
        if (updRec.useType === 2) {
          // 初期値の取得
          const initRec = this.getInitPatEventRecord;
          // (更新)観察記録情報の設定
          await this.setUpdatedObserveRecordInfo(initRec, updRec);
        } else {
          // 観察記録履歴の登録：未実施
          updRec.isObserveRecordLog = false;
        }
        /*add FNSI-改修内容紹介状登録と編集画面改修四つボタン改修 任 end*/
        if (updRec.useType === 3) {
          updRec.reportDate = reportDate;
          // 紹介状のイベント開始日・イベント終了日は転入出日付と同じ値とする
          updRec.eventEndDate = updRec.eventStartDate = updRec.reportDate;
          updRec.letterInfo = JSON.stringify({
          // add 11488 紹介状登録内容保存時に帳票の版も記憶する　1.1A  吉 start
            ctlNo:this.getCltNo,
            // add 11488 紹介状登録内容保存時に帳票の版も記憶する　1.1A  吉 end
            letter_category: +this.getLetterCategory,
            to_facility_cd: this.getToFacilityCd,
            // add FNSI-改修内容患者イベント(紹介状)施設選択の箇所に、施設マスタTBL⇒全施設マスタTBL、医療機関コードがkeyとして取得、保存する要 赵 start
            to_medical_institution_cd:this.getToMedicalInstitutionCd,
            // add FNSI-改修内容患者イベント(紹介状)施設選択の箇所に、施設マスタTBL⇒全施設マスタTBL、医療機関コードがkeyとして取得、保存する要 赵 end
            report_cd: this.getReportCd,
            /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
            isUpdateLetter: this.getIsUpdateLetter,
            /*add FNSI-改修内容転入転出の患者情報連動 任 end*/
            letter_data: this.$refs.patIntroductionLetter.getLetterData()
          });
        }
        if (this.getUpdateMode) {
          /*add FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 start*/
          const templates = this.getMstTemplateRecords;
          const template = templates.find(item => {
            return item.templateCd === updRec.templateCd;
          });

          if(templates[templates.length-1].upDate!==undefined){
            if(template!==undefined){
              const upDate = {
                upDate: template.upDate
              }
              const resultParams = JSON.parse(updRec.resultParams)
              if (Object(resultParams[resultParams.length - 1]).hasOwnProperty('upDate')) {
                resultParams[resultParams.length - 1].upDate = upDate.upDate
              } else {
                resultParams.push(upDate);
              }
              updRec.resultParams = JSON.stringify(resultParams);
            }
          }
          /*add FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 end*/
          const res = await this.setPatEventUpdate({
            rec: updRec,
            isNotification: this.isNotification
          });
          /*add FNSI-改修内容538 連携イベントの登録適正化 任 start*/
          patEventCd = updRec.patEventCd;
          /*add FNSI-改修内容538 連携イベントの登録適正化 任 end*/
          if (res === false) {
            await this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "修正失敗",
              // message: "患者イベント情報が</br>修正されませんでした。"
              title: DIALOG_MESSAGES[12000179].title,
              message: messageFormat(DIALOG_MESSAGES[12000179].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
            return;
          }
        } else {
          /*add FNSI-改修内容5570 任 start*/
          const bbsInfoNew = this.getBbsInfoNew;
          const updRecPatEvent = updRec;
          updRecPatEvent.resultParamsOld = JSON.stringify(bbsInfoNew);
          /*add FNSI-改修内容5570 任 end*/
          const res = await this.setPatEventUpdateResultParamas(updRecPatEvent);
          /*add FNSI-改修内容538 連携イベントの登録適正化 任 start*/
          patEventCd = updRec.patEventCd;
          /*add FNSI-改修内容538 連携イベントの登録適正化 任 end*/
          if (res === false) {
            await this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "登録失敗",
              // message: "患者イベント情報が</br>一部、登録されませんでした。"
              title: DIALOG_MESSAGES[12000180].title,
              message: messageFormat(DIALOG_MESSAGES[12000180].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
            return;
          }
          const res1 = await this.setPatEventUpdateBbsCtlNo(updRec);
          if (res1 === false) {
            await this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "登録失敗",
              // message: "患者イベント情報の掲示版番号が</br>更新されませんでした。"
              title: DIALOG_MESSAGES[12000181].title,
              message: messageFormat(DIALOG_MESSAGES[12000181].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
            return;
          }
        }
        await this.setPatEventRecord(updRec);
        /*add FNSI-改修内容患者イベントbug 任 start*/
        if(this.$refs.bbs!==undefined) {
          if (this.$refs.bbs.length > 0) {
            if (this.$refs.bbs[0].$data.inputModel.publishedState) {
              /*add FNSI-改修内容患者イベントbug 任 end*/
              // 掲示板のファイル情報を生成
              const onBbsList2 = [];
              const bbsItem2 = this.$refs.bbs;
              if (bbsItem2 !== undefined) {
                for (const item of bbsItem2) {
                  onBbsList2.push(item.updateRecord);
                }
              }
              for (const onBbs of onBbsList2) {
                if (onBbs) {
                  const validationResult = onBbs();
                  const ret = await validationResult;
                  if (!ret) {
                    await this.$ons.notification.alert({
                      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                      // title: "エラー",
                      // message: "掲示板の更新が</br>出来ませんでした。"
                      title: DIALOG_MESSAGES[12000182].title,
                      message: messageFormat(DIALOG_MESSAGES[12000182].message)
                      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                    });
                    return false;
                    /*add FNSI-改修内容患者イベントbug 任 start*/
                  }
                  /*add FNSI-改修内容患者イベントbug 任 end*/
                }
              }
            }
          }
        }
        /*add FNSI-改修内容538 連携イベントの登録適正化 任 start*/
        const isUpdate = this.getUpdateMode;
        /*add FNSI-改修内容538 連携イベントの登録適正化 任 end*/

        this.editCompareViewImgs();
        // 登録完了の通知更新
        this.inputModel.subCategoryCd = 0;
        this.setViewMode(true);
        this.setIsEdit(false);
        if (this.isObserveDetail) {
          this.$router.go(-1);
        } else {
          if (!isUpdate) {
            this.setUpdateMode(true);
          }
          this.emitReloadPatEventRecord(this.getPatEventRecord.patEventCd);
        }

        // add FNSI-観察記録に移る 徐 start
        if (this.getPatEventRecord.selfScreenName === "treatment-record-observation") {
          this.setOrdNo(this.getPatEventRecord.ordNo);
          this.goSpecifiedView("treatment-record-observation");
        }
        // add FNSI-観察記録に移る 徐 end
        /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start*/
        // 予実リストの更新
        this.setResultUpdate(new Date());
        /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end*/
        /*add FNSI-改修内容538 連携イベントの登録適正化 任 start*/
        const patEventParams = JSON.parse(rec.inputParams)
        let isTrue = false;
        if(patEventParams!==null){
          patEventParams.forEach(item => {
            if(item.format_class === 9){
              isTrue = true;
            }
          })
        }

        // add FNSi6503治療記録の観察記録の期間抽出が正しく抽出されない 周 start
        if(this.keepHistories[0].routerName !== "pat-event") {
          this.$parent.$data.oldOrdNo = this.getPatEventRecord.ordNo;
        }
        // add FNSi6503治療記録の観察記録の期間抽出が正しく抽出されない 周 end
        const ordNo = this.$parent.$data.oldOrdNo;
        let treatDate = moment().format("YYYYMMDD");
        // mod 9954 観察記録における実績リンクが編集済み表示となる 関 start
        // if(ordNo!==0){
          if(ordNo!==0 && ordNo != undefined){
            // mod 9954 観察記録における実績リンクが編集済み表示となる 関 end
          await ApiHelper.get("/pat_event/getPatEventTreatDate/" + ordNo)
            .then(response => {
              treatDate = response.data.msg
            })
        }
        if(isTrue && isUpdate){
          this.sendPostApi(treatDate,"027002",patEventCd);
        }else if(isTrue && !isUpdate){
          this.sendPostApi(treatDate,"027001",patEventCd);
        }else if(!isTrue && !isUpdate){
          this.sendPostApi(treatDate,"027004",patEventCd);
        }else{
          this.sendPostApi(treatDate,"027005",patEventCd);
        }
        /*add FNSI-改修内容538 連携イベントの登録適正化 任 end*/
        return true;
      }
      return false;
    },
    emitReloadPatEventRecord(patEventCd) {
      const reloadOptions = {};
      if (patEventCd != null) {
        reloadOptions.registeredPatEventCd = patEventCd;
      }
      EventBus.$emit("reloadPatEventRecord", reloadOptions);
    },
    /*add FNSI-改修内容比較中の画像について、編集しても、最新の画像で適用されない 任 start*/
    editCompareViewImgs(){
      this.getCompareViewImgs.forEach((item,index) => {
        if(item.isDel === true){
          let preview = document.getElementById("previewImage-" + item.targetId);
          if(preview.src !== ""){
            const compareViewImg = item;
            compareViewImg.data = preview.src;
            this.setCompareViewImgsReplaceSrc(compareViewImg);
          }else{
            this.setCompareViewImgsDelete(index);
          }
        }
        if(item.isEdit === true){
          let preview = document.getElementById("previewImage-" + item.targetId);
          const compareViewImg = item;
          compareViewImg.data = preview.src;
          this.setCompareViewImgsReplaceSrc(compareViewImg);
        }
      })
      const params = {
        patEventCd: this.getPatEventRecord.patEventCd,
        eventStartDate: this.getPatEventRecord.eventStartDate,
        eventEndTime: this.getPatEventRecord.eventEndTime === null ? " 00:00" : " "+this.getPatEventRecord.eventEndTime,
        eventStartTime: this.getPatEventRecord.eventStartTime === null ? " 00:00" : " "+this.getPatEventRecord.eventStartTime,
        eventEndDate: this.getPatEventRecord.eventEndDate
      }
      this.setCompareViewImgsMsg(params);
    },
    /*add FNSI-改修内容比較中の画像について、編集しても、最新の画像で適用されない 任 end*/
    calcTotalScore(resultParams) {
      let arScore = [];
      for (const item of resultParams) {
        let value = 0;
        if (item.format_class === 8) {
          // スコア計算項目の結果合計
          value = item.result_value.score;
          arScore.push(value);
        }
      }
      if (arScore.length > 0) {
        let total = 0;
        for (const score of arScore) {
          total += Number(score);
        }
        return total;
      } else {
        return null;
      }
    },
    setRelease() {
      this.inputModel.subCategoryCd = 0;
      //del #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
      // this.isSelectedTemplate = false;
      //del #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc end
      this.setViewMode(true);
      this.setIsEdit(false);
      this.setUpdateMode(true);
    },
    // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start
    async handleClickCancelCheckOnly() {
      this.isNotification = false;
      const patEventRecord = this.getPatEventRecord;
      // const patEventCd = patEventRecord ? patEventRecord.patEventCd : 0;
      let currentLetterData = {};
      if (this.$refs.patIntroductionLetter && this.$refs.patIntroductionLetter.getLetterData) {
        currentLetterData = this.$refs.patIntroductionLetter.getLetterData();
      }
      const currentLetterInfoObj = {
        letter_category: Number(this.getLetterCategory) || 0,
        to_facility_cd: this.getToFacilityCd ?? '',
        to_medical_institution_cd: this.getToMedicalInstitutionCd ?? '',
        report_cd: this.getReportCd ?? 0,
        isUpdateLetter: Boolean(this.getIsUpdateLetter),
        letter_data: currentLetterData
      };
      let backupLetterInfoObj = {};
      if (this.backupPatEventRecord?.letterInfo) {
        try {
          backupLetterInfoObj = JSON.parse(this.backupPatEventRecord.letterInfo);
        } catch (e) {
          console.error('backup letterInfo error:', e);
        }
      }
      const normalizedBackupLetterInfoObj = {
        letter_category: Number(backupLetterInfoObj.letter_category) || 0,
        to_facility_cd: backupLetterInfoObj.to_facility_cd ?? '',
        to_medical_institution_cd: backupLetterInfoObj.to_medical_institution_cd ?? '',
        report_cd: backupLetterInfoObj.report_cd ?? 0,
        isUpdateLetter: Boolean(backupLetterInfoObj.isUpdateLetter),
        letter_data: backupLetterInfoObj.letter_data || {}
      };
      const removePathPrefix = (value) => {
        if (typeof value === 'string' && value.startsWith(';path:')) {
          return value.substring(6);
        }
        return value;
      };
      const deepProcess = (obj, path = 'root') => {
        if (obj === null || obj === undefined) return obj;
        if (typeof obj === 'string') {
          const result = removePathPrefix(obj);
          return result;
        }
        if (Array.isArray(obj)) {
          return obj.map((item, index) => deepProcess(item, `${path}[${index}]`));
        }
        if (typeof obj === 'object') {
          const result = {};
          Object.keys(obj).forEach(key => {
            result[key] = deepProcess(obj[key], `${path}.${key}`);
          });
          return result;
        }
        return obj;
      };
      const processedBackupLetterData = deepProcess(normalizedBackupLetterInfoObj.letter_data);
      const processedCurrentLetterData = deepProcess(currentLetterInfoObj.letter_data);
      const extractImageSrc = (value) => {
        if (typeof value !== 'string') return value;
        const imgMatch = value.match(/<img\s+[^>]*src=['"]([^'"]+)['"][^>]*>/i);
        if (imgMatch && imgMatch[1]) {
          return imgMatch[1];
        }
        return value;
      };
      const isBase64Image = (value) => {
        if (typeof value !== 'string') return false;
        return value.startsWith('data:image/') && value.includes(';base64,');
      };
      const isImagePath = (value) => {
        if (typeof value !== 'string') return false;
        return /\.(png|jpg|jpeg|gif|bmp|webp)$/i.test(value);
      };
      const normalizeValue = (value) => {
        if (value === null || value === undefined) return '';
        let str = String(value);
        str = extractImageSrc(str);
        if (str.startsWith(';path:')) {
          str = str.substring(6);
        }
        str = str.replace(/<[^>]*>/g, '');
        str = str.replace(/\u00A0/g, ' ');
        str = str.replace(/\s+/g, ' ').trim();
        return str;
      };
      const filterUserEditedFields = (letterData) => {
        if (!letterData || typeof letterData !== 'object') return {};
        const filtered = {};
        const excludeKeys = [
          'A1', 'R11:S11', 'J12:K12', 'L16:N16', 'Q17:S17', 'P19:S26',
          'G27:S27', 'G33:S33'
        ];
        Object.keys(letterData).forEach(key => {
          if (excludeKeys.includes(key)) return;
          const value = letterData[key];
          if (value === null || value === undefined) return;
          const normalized = normalizeValue(value);
          if (isBase64Image(normalized) || isImagePath(normalized)) {
            return;
          }
          if (normalized === '' || normalized === '&nbsp;' || /^\s*$/.test(normalized)) {
            return;
          }
          filtered[key] = normalized;
        });
        return filtered;
      };
      const filteredBackupLetterData = filterUserEditedFields(processedBackupLetterData);
      const filteredCurrentLetterData = filterUserEditedFields(processedCurrentLetterData);
      const sortObjectKeys = (obj) => {
        if (!obj || typeof obj !== 'object') return obj;
        const sorted = {};
        Object.keys(obj).sort().forEach(key => {
          sorted[key] = obj[key];
        });
        return sorted;
      };
      const sortedBackupLetterData = sortObjectKeys(filteredBackupLetterData);
      const sortedCurrentLetterData = sortObjectKeys(filteredCurrentLetterData);
      const isLetterDataSame = JSON.stringify(sortedBackupLetterData) === JSON.stringify(sortedCurrentLetterData);
      const isOtherFieldsSame =
        normalizedBackupLetterInfoObj.letter_category === currentLetterInfoObj.letter_category &&
        normalizedBackupLetterInfoObj.to_facility_cd === currentLetterInfoObj.to_facility_cd &&
        normalizedBackupLetterInfoObj.to_medical_institution_cd === currentLetterInfoObj.to_medical_institution_cd &&
        normalizedBackupLetterInfoObj.report_cd === currentLetterInfoObj.report_cd &&
        normalizedBackupLetterInfoObj.isUpdateLetter === currentLetterInfoObj.isUpdateLetter;
      const isLetterInfoSame = isLetterDataSame && isOtherFieldsSame;
      const isResultParamsSame = JSON.stringify(this.backupPatEventRecord?.resultParams) === JSON.stringify(patEventRecord?.resultParams);
      const isBasicFieldsSame =
        this.backupPatEventRecord?.eventStartDate === patEventRecord?.eventStartDate &&
        this.backupPatEventRecord?.eventEndDate === patEventRecord?.eventEndDate &&
        this.backupPatEventRecord?.eventStartTime === patEventRecord?.eventStartTime &&
        this.backupPatEventRecord?.eventEndTime === patEventRecord?.eventEndTime;

      const isSame = isLetterInfoSame && isResultParamsSame && isBasicFieldsSame;
      return !isSame;
    },
    // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end
    // mod #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start
    async handleClickCancel() {
      this.isNotification = false;
      const patEventRecord = this.getPatEventRecord;
      const patEventCd = patEventRecord ? patEventRecord.patEventCd : 0;
      let currentLetterData = {};
      if (this.$refs.patIntroductionLetter && this.$refs.patIntroductionLetter.getLetterData) {
        currentLetterData = this.$refs.patIntroductionLetter.getLetterData();
      }
      const currentLetterInfoObj = {
        letter_category: Number(this.getLetterCategory) || 0,
        to_facility_cd: this.getToFacilityCd ?? '',
        to_medical_institution_cd: this.getToMedicalInstitutionCd ?? '',
        report_cd: this.getReportCd ?? 0,
        isUpdateLetter: Boolean(this.getIsUpdateLetter),
        letter_data: currentLetterData
      };
      let backupLetterInfoObj = {};
      if (this.backupPatEventRecord?.letterInfo) {
        try {
          backupLetterInfoObj = JSON.parse(this.backupPatEventRecord.letterInfo);
        } catch (e) {
          console.error('backup letterInfo error:', e);
        }
      }
      const normalizedBackupLetterInfoObj = {
        letter_category: Number(backupLetterInfoObj.letter_category) || 0,
        to_facility_cd: backupLetterInfoObj.to_facility_cd ?? '',
        to_medical_institution_cd: backupLetterInfoObj.to_medical_institution_cd ?? '',
        report_cd: backupLetterInfoObj.report_cd ?? 0,
        isUpdateLetter: Boolean(backupLetterInfoObj.isUpdateLetter),
        letter_data: backupLetterInfoObj.letter_data || {}
      };
      const removePathPrefix = (value) => {
        if (typeof value === 'string' && value.startsWith(';path:')) {
          return value.substring(6);
        }
        return value;
      };
      const deepProcess = (obj, path = 'root') => {
        if (obj === null || obj === undefined) return obj;
        if (typeof obj === 'string') {
          const result = removePathPrefix(obj);
          return result;
        }
        if (Array.isArray(obj)) {
          return obj.map((item, index) => deepProcess(item, `${path}[${index}]`));
        }
        if (typeof obj === 'object') {
          const result = {};
          Object.keys(obj).forEach(key => {
            result[key] = deepProcess(obj[key], `${path}.${key}`);
          });
          return result;
        }
        return obj;
      };
      const processedBackupLetterData = deepProcess(normalizedBackupLetterInfoObj.letter_data);
      const processedCurrentLetterData = deepProcess(currentLetterInfoObj.letter_data);
      const extractImageSrc = (value) => {
        if (typeof value !== 'string') return value;
        const imgMatch = value.match(/<img\s+[^>]*src=['"]([^'"]+)['"][^>]*>/i);
        if (imgMatch && imgMatch[1]) {
          return imgMatch[1];
        }
        return value;
      };
      const isBase64Image = (value) => {
        if (typeof value !== 'string') return false;
        return value.startsWith('data:image/') && value.includes(';base64,');
      };
      const isImagePath = (value) => {
        if (typeof value !== 'string') return false;
        return /\.(png|jpg|jpeg|gif|bmp|webp)$/i.test(value);
      };
      const normalizeValue = (value) => {
        if (value === null || value === undefined) return '';
        let str = String(value);
        str = extractImageSrc(str);
        if (str.startsWith(';path:')) {
          str = str.substring(6);
        }
        str = str.replace(/<[^>]*>/g, '');
        str = str.replace(/\u00A0/g, ' ');
        str = str.replace(/\s+/g, ' ').trim();
        return str;
      };
      const filterUserEditedFields = (letterData) => {
        if (!letterData || typeof letterData !== 'object') return {};
        const filtered = {};
        const excludeKeys = [
          'A1', 'R11:S11', 'J12:K12', 'L16:N16', 'Q17:S17', 'P19:S26',
          'G27:S27', 'G33:S33'
        ];
        Object.keys(letterData).forEach(key => {
          if (excludeKeys.includes(key)) return;
          const value = letterData[key];
          if (value === null || value === undefined) return;
          const normalized = normalizeValue(value);
          if (isBase64Image(normalized) || isImagePath(normalized)) {
            return;
          }
          if (normalized === '' || normalized === '&nbsp;' || /^\s*$/.test(normalized)) {
            return;
          }
          filtered[key] = normalized;
        });
        return filtered;
      };
      const filteredBackupLetterData = filterUserEditedFields(processedBackupLetterData);
      const filteredCurrentLetterData = filterUserEditedFields(processedCurrentLetterData);
      const sortObjectKeys = (obj) => {
        if (!obj || typeof obj !== 'object') return obj;
        const sorted = {};
        Object.keys(obj).sort().forEach(key => {
          sorted[key] = obj[key];
        });
        return sorted;
      };
      const sortedBackupLetterData = sortObjectKeys(filteredBackupLetterData);
      const sortedCurrentLetterData = sortObjectKeys(filteredCurrentLetterData);
      const isLetterDataSame = JSON.stringify(sortedBackupLetterData) === JSON.stringify(sortedCurrentLetterData);
      const isOtherFieldsSame =
        normalizedBackupLetterInfoObj.letter_category === currentLetterInfoObj.letter_category &&
        normalizedBackupLetterInfoObj.to_facility_cd === currentLetterInfoObj.to_facility_cd &&
        normalizedBackupLetterInfoObj.to_medical_institution_cd === currentLetterInfoObj.to_medical_institution_cd &&
        normalizedBackupLetterInfoObj.report_cd === currentLetterInfoObj.report_cd &&
        normalizedBackupLetterInfoObj.isUpdateLetter === currentLetterInfoObj.isUpdateLetter;
      const isLetterInfoSame = isLetterDataSame && isOtherFieldsSame;
      const isResultParamsSame = JSON.stringify(this.backupPatEventRecord?.resultParams) === JSON.stringify(patEventRecord?.resultParams);
      const isBasicFieldsSame =
        this.backupPatEventRecord?.eventStartDate === patEventRecord?.eventStartDate &&
        this.backupPatEventRecord?.eventEndDate === patEventRecord?.eventEndDate &&
        this.backupPatEventRecord?.eventStartTime === patEventRecord?.eventStartTime &&
        this.backupPatEventRecord?.eventEndTime === patEventRecord?.eventEndTime;
      const isSame = isLetterInfoSame && isResultParamsSame && isBasicFieldsSame && !this.isChanged;
      if (isSame) {
        this.setRelease();
        if (this.isObserveDetail) {
          this.$router.go(-1);
        } else {
          await this.setPatEventRecord(null);
          this.emitReloadPatEventRecord(patEventCd);
        }
        this.copySourcePatEventCd = null;
      } else {
        await this.cancel(false, true);
      }
    },
    // mod #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end
    async cancel(noConfirm, keepSelect) {
      // clickのハンドラとして使う場合はイベントオブジェクトが第1引数に入ってくるのでbooleanに補正しておく
      noConfirm = noConfirm === true;
      const options = {};
      if (this.isObserveDetail) {
        options.beforeConfirmCallback = () => {
          this.setCompareViewImgsTrue();
        };
      }
      if (noConfirm || await this.confirmAllowDiscardChanges(options)) {
        if (this.isObserveDetail) {
          this.hasPreviousPage = true;
          this.setRelease();
          // 画面遷移時に破棄確認が起きないようにクリアしておく
          await this.setPatEventRecord(null);
          this.$router.go(-1);
        } else {
          const reloadPatEventCd = keepSelect ? this.getPatEventRecord.patEventCd : undefined;
          this.setRelease();
          await this.setPatEventRecord(null);
          this.emitReloadPatEventRecord(reloadPatEventCd);
        }
      }
      //del #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
      // this.isChanged = false;
      //del #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc end
    },
    async refresh() {
      if (this.isObserveDetail && this.selfScreenName === this.$router.currentRoute.name) {
        if (await this.confirmAllowDiscardChanges()) {
          // #6765 観察記録：修正時、修正していないが保存ボタンが有効になってしまっている 訾浩 start
          //del #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
          // this.refreshFlag = true
          //del #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc end
          // #6765 観察記録：修正時、修正していないが保存ボタンが有効になってしまっている 訾浩 end
          // 一度入力画面をクリアさせて再度初期状態を設定しなおす
          // add 8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する 鄭爽 start
          const info = [];
          info.push({
            patEventCd: this.getPatEventRecord.patEventCd
          });
          const params = info[0];
          const response = await sendRequestGetPatEventRecord(params);
          // add 8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する 鄭爽 end
          // await this.setPatEventRecord(null);
          // mod 8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する 鄭爽 start
          // const rec = deepCopy(this.backupPatEventRecord);
          // rec.inputParams = rec.inputParams ? JSON.stringify(rec.inputParams) : null;
          // rec.resultParams = rec.resultParams ? JSON.stringify(rec.resultParams) : null;
          // rec.regStaffInfo = rec.regStaffInfo ? JSON.stringify(rec.regStaffInfo) : null;
          // rec.upStaffInfo = rec.upStaffInfo ? JSON.stringify(rec.upStaffInfo) : null;
          // await new Promise(async (resolve) => {
          //   this.$nextTick(async () => {
          //     await this.setPatEventRecord(rec);
          //     resolve();
          //   });
          // });
          // upd 8618 新規画面入力後にパンくずリストを押下すると画面がまっさらになる ztc start
          await this.setPatEventRecord(null);
          let resultPatEventRecord = null;
          let apiFlg = false;
          if (response.data[0] != null) {
            resultPatEventRecord = response.data[0];
            apiFlg = true;
          } else{
            resultPatEventRecord = this.backupPatEventRecord;
          }
          const rec = deepCopy(resultPatEventRecord);
          rec.inputParams = rec.inputParams ? (apiFlg ? JSON.stringify(JSON.parse(rec.inputParams)) : JSON.stringify(rec.inputParams)) : null;
          rec.resultParams = rec.resultParams ? (apiFlg ? JSON.stringify(JSON.parse(rec.resultParams)) : JSON.stringify(rec.resultParams)) : null;
          rec.regStaffInfo = rec.regStaffInfo ? (apiFlg ? JSON.stringify(JSON.parse(rec.regStaffInfo)) : JSON.stringify(rec.regStaffInfo)) : null;
          rec.upStaffInfo = rec.upStaffInfo ? (apiFlg ? JSON.stringify(JSON.parse(rec.upStaffInfo)) : JSON.stringify(rec.upStaffInfo)) : null;
          await new Promise(async (resolve) => {
            this.$nextTick(async () => {
              await this.setPatEventRecord(rec);
              // #6765 観察記録：修正時、修正していないが保存ボタンが有効になってしまっている 訾浩 start
              //del #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
              // this.backupPatEventRecord = JSON.parse(JSON.stringify(this.getPatEventRecord))
              //del #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc end
              // #6765 観察記録：修正時、修正していないが保存ボタンが有効になってしまっている 訾浩 end
              resolve();
            });
          });
          // upd 8618 新規画面入力後にパンくずリストを押下すると画面がまっさらになる ztc end
          // mod 8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する 鄭爽 end
          this.alertFlag = true;
        }
      }
      // #6765 観察記録：修正時、修正していないが保存ボタンが有効になってしまっている 訾浩 start
      //del #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
      // this.refreshFlag = false
      //del #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc end
      // #6765 観察記録：修正時、修正していないが保存ボタンが有効になってしまっている 訾浩 end
    },
    async editor(type) {
      // 通知チェックをリセット
      this.isNotification = false;
      if (type == 'editor') {
        this.backupPatEventRecord = deepCopy(this.getPatEventRecord);
        this.setInitPatEventRecord(deepCopy(this.getPatEventRecord));
      }
      const templates = this.getMstTemplateRecords;
      const template = templates.find(item => {
        return item.templateCd === this.backupPatEventRecord?.templateCd;
      });
      if(this.backupPatEventRecord?.resultParams.length>0){
        if(this.backupPatEventRecord.resultParams[this.backupPatEventRecord.resultParams.length-1].upDate !== undefined){
          if(this.backupPatEventRecord.useType !== 3 && this.backupPatEventRecord.resultParams[this.backupPatEventRecord.resultParams.length-1].upDate !== template.upDate){
            this.setTemplateShow(true);
          }
        }
      }
      /*add FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 end*/
      this.setIsEdit(true);
      /*add FNSI-改修内容添付ファイル修正 任 start*/
      this.setShowFile(true);
      /*add FNSI-改修内容添付ファイル修正 任 end*/
      this.setViewMode(false);
      /*add FNSI-改修内容紹介状登録と編集画面改修四つボタン改修 任 start*/
      if(this.getPathReal!==null){
        this.setDisplayTwo(true);
      }
      /*add FNSI-改修内容紹介状登録と編集画面改修四つボタン改修 任 end*/
      // 1.テキスト情報
      const resettingList = [];
      const textItem = this.$refs.textArea;
      if (textItem !== undefined) {
        for (const item of textItem) {
          resettingList.push(item.editDataHtmlText);
        }
      }
      for (const resetting of resettingList) {
        if (resetting) {
          const reset = resetting();
          await reset;
        }
      }
      /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start*/
      // 予実リストの更新
      this.setResultUpdate(new Date());
      /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end*/
    },
    /*add FNSI-改修内容5417 任 start*/
    remove() {
      // add #10359_NG対応 編集権限の動作不正 dengshen start
      if (!this.getItemAuthorized('PatEvent', 'item_patevent_del')) {
        this.$ons.notification.alert({
          // title: "権限エラー",
          // message: functionName+"を操作する権限がありません。管理者に確認してください。"
          title: DIALOG_MESSAGES[12000315].title,
          message: messageFormat(DIALOG_MESSAGES[12000315].message, "患者イベント削除")
        });
        return;
      }
      // add #10359_NG対応 編集権限の動作不正 dengshen end
      // add 8440 登録済み観察記録の削除を行うと削除の確認に加え内容破棄の確認ダイアログが表示される 関 start
      //del #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
      // this.deleteFlg = false;
      //del #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc end
      // add 8440 登録済み観察記録の削除を行うと削除の確認に加え内容破棄の確認ダイアログが表示される 関 end
      this.$ons.notification
        .confirm({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "削除確認",
          // message: "削除すると二度と元に戻せません。削除してもよろしいですか？"
          title: DIALOG_MESSAGES[13000006].title,
          message: DIALOG_MESSAGES[13000006].message
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        })
        .then((ok) => {
          if (ok) {
            //add #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
            // mod #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 start
            this.setSkipRoute(true);
            // mod #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 end
            //add #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc end
            this.erasure()
          }
        });
    },
    /*add FNSI-改修内容5417 任 end*/
    /**
     * 患者イベント実績の登録（削除）
     */
    async erasure() {
      // S3 添付ファイル削除
      const onFileUpLoadList = [];
      const fileItem = this.$refs.file;
      if (fileItem !== undefined) {
        for (const item of fileItem) {
          onFileUpLoadList.push(item.deleteS3File);
        }
      }
      for (const onFileUpLoad of onFileUpLoadList) {
        if (onFileUpLoad) {
          const validationResult = onFileUpLoad();
          const ret = await validationResult;
          if (!ret) {
            await this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "添付ファイルエラー",
              // message: "ファイルの削除が</br>出来ませんでした。"
              title: DIALOG_MESSAGES[12000183].title,
              message: messageFormat(DIALOG_MESSAGES[12000183].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
            return false;
          }
        }
      }
      // S3 画像ファイル削除
      const onImageUpLoadList = [];
      const imageItem = this.$refs.image;
      if (imageItem !== undefined) {
        for (const item of imageItem) {
          onImageUpLoadList.push(item.deleteS3File);
        }
      }
      for (const onFileUpLoad of onImageUpLoadList) {
        if (onFileUpLoad) {
          const validationResult = onFileUpLoad();
          const ret = await validationResult;
          if (!ret) {
            await this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "画像エラー",
              // message: "画像ファイルの削除が</br>出来ませんでした。"
              title: DIALOG_MESSAGES[12000184].title,
              message: messageFormat(DIALOG_MESSAGES[12000184].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
            return false;
          }
        }
      }
      // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start
      let removedLetterImages = [];
      try {
        const rec = deepCopy(this.getPatEventRecord);
        if (rec.useType === 3 && rec.letterInfo) {
          const letterInfo = JSON.parse(rec.letterInfo);
          if (letterInfo.letter_data) {
            Object.keys(letterInfo.letter_data).forEach(coordinate => {
              const value = letterInfo.letter_data[coordinate];
              if (typeof value === 'string') {
                if (value.includes('<img') && value.includes('src')) {
                  let fileName = "";
                  let fullPath = "";
                  const pathPattern = />;path:([^<]+)/;
                  const pathMatch = value.match(pathPattern);
                  if (pathMatch && pathMatch[1]) {
                    fullPath = pathMatch[1].trim();
                    if (fullPath.includes('/')) {
                      const pathParts = fullPath.split('/');
                      fileName = pathParts[pathParts.length - 1];
                      if (fileName.includes('?')) {
                        fileName = fileName.split('?')[0];
                      }
                    } else {
                      fileName = fullPath;
                    }
                  } else {
                    const pathPattern2 = /;path:([^;]+)/;
                    const pathMatch2 = value.match(pathPattern2);
                    if (pathMatch2 && pathMatch2[1]) {
                      fullPath = pathMatch2[1].trim();
                    }
                    else if (value.includes(';')) {
                      const lastSemicolonIndex = value.lastIndexOf(';');
                      if (lastSemicolonIndex !== -1) {
                        const afterSemicolon = value.substring(lastSemicolonIndex + 1).trim();
                        if (afterSemicolon.startsWith('path:')) {
                          fullPath = afterSemicolon.substring(5).trim();
                        } else if (afterSemicolon.includes('/') && afterSemicolon.includes('image')) {
                          fullPath = afterSemicolon.trim();
                        }
                      }
                    }
                    if (fullPath && fullPath.includes('/')) {
                      const pathParts = fullPath.split('/');
                      fileName = pathParts[pathParts.length - 1];
                      if (fileName.includes('?')) {
                        fileName = fileName.split('?')[0];
                      }
                    }
                  }
                  const fieldName = coordinate.replace(":", "-");
                  const filePath = `${rec.patId}/${rec.patEventCd}/image/${fieldName}-0/${fileName}`;
                  removedLetterImages.push({
                    coordinate: coordinate,
                    file_name: fileName,
                    file_path: filePath,
                    file_modified_time: dateFormat.format(new Date(), "yyyyMMddhhmmss"),
                    name: ""
                  });
                }
              }
            });
          }
        }
      } catch (error) {
        return false;
      }
      if (removedLetterImages.length > 0) {
        let deleteSuccess = true;
        for (let i = 0; i < removedLetterImages.length; i++) {
          const imgInfo = removedLetterImages[i];
          try {
            const result = await sendRequestPostImageDelete({
              facilityCd: this.getPatEventRecord.facilityCd,
              patId: this.getPatEventRecord.patId,
              removedFiles: [imgInfo]
            }).catch(error => {
              getErrorMessage('PatEventDetailComponent.vue', 'erasure - del', error);
              return false;
            });
            if (!result) {
              deleteSuccess = false;
            }
          } catch (error) {
            deleteSuccess = false;
          }
        }
        if (!deleteSuccess) {
          await this.$ons.notification.alert({
            title: DIALOG_MESSAGES[12000186].title,
            message: messageFormat(DIALOG_MESSAGES[12000186].message, "紹介状内の画像ファイルの削除に失敗しました")
          });
          return false;
        }
      }
      // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end
      // 掲示板更新処理
      /*add FNSI-改修内容患者イベントbug 任 start*/
      if(this.$refs.bbs!==undefined) {
        if (this.$refs.bbs.length > 0) {
          if (this.$refs.bbs[0].$data.inputModel.publishedState) {
            /*add FNSI-改修内容患者イベントbug 任 end*/
            const onBbsList = [];
            const bbsItem = this.$refs.bbs;
            if (bbsItem !== undefined) {
              for (const item of bbsItem) {
                onBbsList.push(item.deleteRecord);
              }
            }
            for (const onBbs of onBbsList) {
              if (onBbs) {
                const validationResult = onBbs();
                const ret = await validationResult;
                if (!ret) {
                  await this.$ons.notification.alert({
                    // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                    // title: "エラー",
                    // message: "掲示板の削除が</br>出来ませんでした。"
                    title: DIALOG_MESSAGES[12000185].title,
                    message: messageFormat(DIALOG_MESSAGES[12000185].message)
                    // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                  });
                  return false;
                  /*add FNSI-改修内容患者イベントbug 任 start*/
                }
              }
              /*add FNSI-改修内容患者イベントbug 任 end*/
            }
          }
        }
      }
      // ＤＢ更新
      let rec = deepCopy(this.getPatEventRecord);
      // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start
      if (rec.letterInfo) {
        try {
          const letterInfo = JSON.parse(rec.letterInfo);
          if (letterInfo.letter_data) {
            Object.keys(letterInfo.letter_data).forEach(key => {
              const value = letterInfo.letter_data[key];
              if (typeof value === 'string' && value.includes('data:image')) {
                let fileName = "";
                let fullPath = "";
                const pathPattern = />;path:([^<]+)/;
                const pathMatch = value.match(pathPattern);
                if (pathMatch && pathMatch[1]) {
                  fullPath = pathMatch[1].trim();
                  if (fullPath.includes('/')) {
                    const pathParts = fullPath.split('/');
                    fileName = pathParts[pathParts.length - 1];
                    if (fileName.includes('?')) {
                      fileName = fileName.split('?')[0];
                    }
                  } else {
                    fileName = fullPath;
                  }
                }
                else {
                  const pathPattern2 = /;path:([^;]+)/;
                  const pathMatch2 = value.match(pathPattern2);
                  if (pathMatch2 && pathMatch2[1]) {
                    fullPath = pathMatch2[1].trim();
                  }
                  else if (value.includes(';')) {
                    const lastSemicolonIndex = value.lastIndexOf(';');
                    if (lastSemicolonIndex !== -1) {
                      const afterSemicolon = value.substring(lastSemicolonIndex + 1).trim();
                      if (afterSemicolon.startsWith('path:')) {
                        fullPath = afterSemicolon.substring(5).trim();
                      } else if (afterSemicolon.includes('/') && afterSemicolon.includes('image')) {
                        fullPath = afterSemicolon.trim();
                      }
                    }
                  }
                  if (fullPath && fullPath.includes('/')) {
                    const pathParts = fullPath.split('/');
                    fileName = pathParts[pathParts.length - 1];
                    if (fileName.includes('?')) {
                      fileName = fileName.split('?')[0];
                    }
                  }
                }
                if (fileName) {
                  const fieldName = key.replace(":", "-");
                  const newPath = `${rec.patId}/${rec.patEventCd}/image/${fieldName}-0/${fileName}`;
                  letterInfo.letter_data[key] = newPath;
                }
              }
            });
            rec.letterInfo = JSON.stringify(letterInfo);
          }
        } catch (error) {
          console.error('Error processing letterInfo image data:', error);
        }
      }
      // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end
      // 紹介状削除(recのデータを参照してDB更新前に実施)
      if (rec.reportUrl != null) {
        const paths = rec.reportUrl.split('/');
        const removedFiles = [{
          file_name: paths[paths.length - 1],
          file_path: rec.reportUrl
        }];
        let ret = true;
        await sendRequestPostImageDelete({
          facilityCd: rec.facilityCd,
          patId: rec.patId,
          removedFiles: removedFiles
        }).catch(error => {
          ret = false;
          getErrorMessage('PatEventDetailComponent.vue', 'erasure', error);
        });
        if (!ret) {
          await this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "エラー",
            // message: "紹介状の削除が</br>出来ませんでした。"
            title: DIALOG_MESSAGES[12000186].title,
            message: messageFormat(DIALOG_MESSAGES[12000186].message)
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
          return false;
        } else {
          // 保存先Pathをクリア
          rec.reportUrl = null;
        }
      }
      // mod #11445 【たくしん会】pat_eventのinput_params「null」によるクエリエラー問題　V1.0B 高 start
      if (this.getPatEventInputParams) {
        rec.inputParams = JSON.stringify(this.getPatEventInputParams);
      } else {
        rec.inputParams = null;
      }
      // rec.inputParams = JSON.stringify(this.getPatEventInputParams);
      // mod #11445 【たくしん会】pat_eventのinput_params「null」によるクエリエラー問題　V1.0B 高 end
      rec.resultParams = JSON.stringify(this.getPatEventResultParams);
      rec.regStaffInfo = JSON.stringify(this.getPatEventRegStaffInfo);
      // NKK- No.3718 姜 start
      rec.upStaffInfo = JSON.stringify({
        up_staff_cd: this.getStateUserAccountInfo.userId,
        up_staff_name: this.getStateUserAccountInfo.userLastName + this.getStateUserAccountInfo.userFirstName
      });
      // NKK- No.3718 姜 end
      rec.isDel = "1";
      // カテゴリタイプ = "2"(観察記録)の場合
      if (rec.useType === 2) {
        // 初期値の取得
        const initRec = this.getInitPatEventRecord;
        // (削除)観察記録情報の設定
        this.setDeletedObserveRecordInfo(initRec, rec);
      } else {
        // 観察記録履歴の登録：未実施
        rec.isObserveRecordLog = false;
      }
      const res = await this.setPatEventUpdate({
        rec,
        isNotification: false
      });
      if (res === false) {
        await this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "削除失敗",
          // message: "患者イベント情報が</br>削除されませんでした。"
          title: DIALOG_MESSAGES[12000187].title,
          message: messageFormat(DIALOG_MESSAGES[12000187].message)
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
        return;
      } else {
        /*del FNSI-改修内容5417 任 start*/
        /*await this.$ons.notification.alert({
          title: "削除成功",
          message: "患者イベント情報が</br>削除されました。"
        });*/
        /*del FNSI-改修内容5417 任 end*/
        // 登録完了の通知更新
        /*modify FNSI-bug6119 観察記録画面Out of memoryの問題 史 start*/
        //if (this.selfScreenName === "observe-record-detail") {
        if (this.isObserveDetail) {
          // this.$router.push({ name: "treatment-record" });
          // setTimeout(()=>{
          //   this.$router.push({ name: "treatment-record-observation" });
          // },1000)
          this.$router.go(-1);
          /*modify FNSI-bug6119 観察記録画面Out of memoryの問題 史 end*/
        } else {
          this.setIsEdit(false);
          this.setViewMode(true);
          this.emitReloadPatEventRecord();
        }
      }
      /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start*/
      // 予実リストの更新
      this.setResultUpdate(new Date());
      /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end*/
      /*add FNSI-改修内容538 連携イベントの登録適正化 任 start*/
      const patEventParams = JSON.parse(rec.inputParams)
      let isTrue = false;
      if (patEventParams !== null) {
        patEventParams.forEach(item => {
          if (item.format_class === 9) {
            isTrue = true;
          }
        });
      }
      //mod FNSI-8441 ljx start
      //const ordNo = this.$parent.$data.oldOrdNo;
      const ordNo = this.getPatEventRecord.ordNo;
      //mod FNSI-8441 ljx end
      let treatDate = moment().format("YYYYMMDD");
      //mod FNSI-8441 ljx start
      //if(ordNo!==0 && ordNo != undefined){
      if(ordNo!==0 && ordNo != undefined){
        //mod FNSI-8441 ljx end
        await ApiHelper.get("/pat_event/getPatEventTreatDate/" + ordNo)
          .then(response => {
            treatDate = response.data.msg
          })
      }
      if(isTrue){
        this.sendPostApi(treatDate,"027003",rec.patEventCd);
      }else{
        this.sendPostApi(treatDate,"027006",rec.patEventCd);
      }
      /*add FNSI-改修内容538 連携イベントの登録適正化 任 end*/
    },
    /**
     * 紹介状コピー
     */
    copyLetter() {
      // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start
      this.copySourcePatEventCd = this.getPatEventRecord.patEventCd;
      if (this.getPatEventRecord.letterInfo) {
        try {
          this.originalLetterInfo = JSON.parse(this.getPatEventRecord.letterInfo);
        } catch (error) {
          this.originalLetterInfo = null;
        }
      } else {
        this.originalLetterInfo = null;
      }
      // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end
      this.$emit("copyLetter");
      this.getPatEventRecord.patEventCd = 0;
      this.getPatEventRecord.reportDate = null;
      this.setReportStartDate(null);
      if (this.$refs.patIntroductionLetter) {
        this.$refs.patIntroductionLetter.renewReportStartDate();
      }
      this.setIsEdit(true);
      this.setViewMode(false);
      this.setUpdateMode(false);
      //del #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
      // this.isSelectedTemplate = true;
      //del #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc end
      this.inputModel.subCategoryCd = this.getPatEventRecord.subCategoryCd;
      /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start*/
      // 予実リストの更新
      this.setResultUpdate(new Date());
      /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end*/
    },
    /**
     * 印刷ポップアップ表示
     */
    async showPrintPopover(event, direction, coverTarget = false) {
      this.popoverPrintTarget = event;
      this.popoverPrintDirection = direction;
      this.coverPrintTarget = coverTarget;
      this.popoverPrintVisible = true;

      this.selectedPrinter = null;

      // del #12107 帳票印刷失敗通知が行われない limingzhe 20251114 start
      // // ひとまず先頭のプリンターを選択
      // if (this.getMstPrinters.length > 0) {
      //   this.selectedPrinter = this.getMstPrinters[0].printerCd;
      // }
      // del #12107 帳票印刷失敗通知が行われない limingzhe 20251114 end

      // 印刷する帳票のデフォルトプリンターを初期選択
      const mstReport = this.getReportList.find(
        e => e.reportCd === this.getReportCd
      );
      if (mstReport.defaultPrinter !== "" && mstReport.defaultPrinter !== null) {
        this.selectedPrinter = mstReport.defaultPrinter;
      }
      // add #12107 帳票印刷失敗通知が行われない limingzhe 20251114 start
      else {
        if(this.defaultPrinter !== "" && this.defaultPrinter !== null) {
          this.selectedPrinter = this.defaultPrinter;
        }
        else {
          this.selectedPrinter = null;
        }
      }
      // add #12107 帳票印刷失敗通知が行われない limingzhe 20251114 end
    },
    /**
     * 紹介状印刷
     */
    async printLetter() {
      this.popoverPrintVisible = false;
      /*add FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 start*/
      // mod #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao start
      //const subCategory = this.getMstSubCategoryRecords.find(item => {
      const subCategory = this.getMstAllSubCategoryRecords.find(item => {
        // mod #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao end
        return item.subCategoryCd === this.getSubCategoryCd
      })
      /*add FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 end*/
      const params = {
        // mod 10726 紹介状で印刷押下でエラー発生/印刷されない 吉 start
        // htmlTemplate: document.getElementById("content-html").innerHTML,
        htmlTemplate: document.getElementById("content-html-id").innerHTML,
        // mod 10726 紹介状で印刷押下でエラー発生/印刷されない 吉 end
        patId: this.getPatEventRecord.patId,
        /*add FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 start*/
        dispItemInfo: subCategory.dispItemInfo,
        /*add FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 end*/
        reportCd: this.getReportCd,
        printerCd: this.selectedPrinter
        // add #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao start
        ,ctlNo: this.getCltNo
        // add #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao end
      };
      await this.onPrintLetter(params);
    },
    /**
     * 患者情報を更新
     */
    async updateLetter() {
      this.setLoadingScreenVisible(true);
      const inputLetterData = this.$refs.patIntroductionLetter.getLetterData();
      this.setUpdatePdf(false);
      this.setViewMode(true);
      await this.setTemplate({
        patId: this.getPatEventRecord.patId,
        reportCd: this.getReportCd != 0 ? this.getReportCd : this.inputModel.subReportCd,
        isUpdate:1
      });
      this.setUpdatePdf(true);
      this.$nextTick(() => {
        this.setLoadingScreenVisible(false);
        this.setViewMode(false);
        this.$refs.patIntroductionLetter.restoreLetterData(inputLetterData);
      });
    },
    /**
     * 変更有無のチェック
     */
    async confirmContentChanged() {
      this.isChanged = false;


      if (this.getViewMode && !this.isObserveDetail) {
        return;
      }

      if (this.backupPatEventRecord === null || !this.getPatEventRecord) {
        return;
      }


      if (!this.getUpdateMode) {
        this.isChanged = true;
        return;
      }


      if (await this.checkBasicInfoChanged() ||
          await this.checkDateTimeChanged() ||
          await this.checkFileChanged() ||
          await this.checkParamsChanged()) {
        this.isChanged = true;
      }
    },

    async checkBasicInfoChanged() {

      const isEqual = isEqualWith(this.backupPatEventRecord?.resultParams, this.getPatEventRecord?.resultParams, customComparatorForType)
      if (!isEqual) {
        return true;
      }


      const backupOrdNo = this.backupPatEventRecord.ordNo == null ? 0 : this.backupPatEventRecord.ordNo;
      const currentOrdNo = this.getPatEventRecord.ordNo == null ? 0 : this.getPatEventRecord.ordNo;
      if (backupOrdNo !== currentOrdNo) {
        return true;
      }

      return false;
    },


    async checkDateTimeChanged() {

      if (this.backupPatEventRecord.eventEndDate &&
          this.getPatEventRecord.eventEndDate &&
          this.backupPatEventRecord.eventEndDate !== this.getPatEventRecord.eventEndDate) {
        return true;
      }


      const backupEndTimeNull = this.backupPatEventRecord.eventEndTime == null;
      const currentEndTimeNull = this.getPatEventRecord.eventEndTime == null;

      if (backupEndTimeNull !== currentEndTimeNull) {
        return true;
      }

      if (!backupEndTimeNull && !currentEndTimeNull &&
          this.backupPatEventRecord.eventEndTime != this.getPatEventRecord.eventEndTime) {
        return true;
      }


      if (this.backupPatEventRecord.eventStartDate &&
          this.getPatEventRecord.eventStartDate &&
          this.backupPatEventRecord.eventStartDate !== this.getPatEventRecord.eventStartDate) {
        return true;
      }


      const backupStartTimeNull = this.backupPatEventRecord.eventStartTime == null;
      const currentStartTimeNull = this.getPatEventRecord.eventStartTime == null;

      if (backupStartTimeNull !== currentStartTimeNull) {
        return true;
      }

      if (!backupStartTimeNull && !currentStartTimeNull &&
          this.backupPatEventRecord.eventStartTime != this.getPatEventRecord.eventStartTime) {
        return true;
      }

      return false;
    },


    async checkFileChanged() {
      const fileItem = this.$refs.file;
      if (fileItem) {
        for (const item of fileItem) {
          const uploadS3List = item.uploadS3List;
          if (uploadS3List) {
            const resultFile = uploadS3List();
            const retFile = await resultFile;
            if (!retFile) continue;

            const backupFile = this.backupPatEventRecord?.resultParams[retFile.index]?.result_value;
            if (JSON.stringify(retFile.result_value) !== JSON.stringify(backupFile)) {
              return true;
            }
          }
        }
      }

      const imageItem = this.$refs.image;
      if (imageItem) {
        for (const item of imageItem) {
          const uploadS3List = item.uploadS3List;
          if (uploadS3List) {
            const resultImage = uploadS3List();
            const retImage = await resultImage;
            if (!retImage) continue;

            const backupImage = this.backupPatEventRecord?.resultParams[retImage.index]?.result_value;
            if (JSON.stringify(retImage.result_value) !== JSON.stringify(backupImage)) {
              return true;
            }
          }
        }
      }

      return false;
    },


    async checkParamsChanged() {
      // 紹介状の場合
      if (this.getPatEventRecord?.useType === 3) {

        const inputReportDate = this.getReportStartDateValue();
        if (this.backupPatEventRecord.reportDate !== inputReportDate) {
          return true;
        }

        const inputLetterInfo = JSON.stringify({
          letter_category: +this.getLetterCategory,
          to_facility_cd: this.getToFacilityCd || '',
          to_medical_institution_cd: this.getToMedicalInstitutionCd || '',
          report_cd: this.getReportCd,
          isUpdateLetter: this.getIsUpdateLetter,
          letter_data: this.$refs.patIntroductionLetter.getLetterData()
        });

        const inputLetterInfoObj = JSON.parse(inputLetterInfo);
        const backupLetterInfoObj = JSON.parse(this.backupPatEventRecord.letterInfo);

        if (inputLetterInfoObj?.letter_data) {
          delete inputLetterInfoObj.letter_data["pat-name-area"];
          Object.keys(inputLetterInfoObj.letter_data).forEach(key => {
            if (inputLetterInfoObj.letter_data[key] === '') {
              delete inputLetterInfoObj.letter_data[key];
            }
          });
          if (!inputLetterInfoObj.to_facility_cd) delete inputLetterInfoObj.to_facility_cd;
          if (!inputLetterInfoObj.to_medical_institution_cd) delete inputLetterInfoObj.to_medical_institution_cd;
        }
        if (backupLetterInfoObj?.letter_data) {
          delete backupLetterInfoObj.letter_data["pat-name-area"];
        }
        if (!backupLetterInfoObj.to_facility_cd) delete backupLetterInfoObj.to_facility_cd;
        if (!backupLetterInfoObj.to_medical_institution_cd) delete backupLetterInfoObj.to_medical_institution_cd;
        delete backupLetterInfoObj["ctlNo"];

        if (!hasEqualValues(backupLetterInfoObj, inputLetterInfoObj)) {
          return true;
        }
      }

      if (this.backupPatEventRecord?.resultParams && this.getPatEventRecord?.resultParams) {

        const filterParams = (params) => params.filter(item =>
          item.format_class !== 2 &&
          item.format_class !== 7 &&
          item.format_class !== 9
        );

        const backupParams = filterParams(this.backupPatEventRecord.resultParams);
        const currentParams = filterParams(this.getPatEventRecord.resultParams);

        if (JSON.stringify(backupParams) !== JSON.stringify(currentParams)) {
          return true;
        }
      }

      return false;
    },
    /**
     * 変更が有り、かつ破棄確認でキャンセルした場合にfalseを返す
     * options.beforeConfirmCallback 破棄確認を表示する場合にその直前に呼ばれるコールバック
     */
    async confirmAllowDiscardChanges(options) {
      if (!options) {
        options = {};
      }
      // 多重に呼ばれた場合は最初の呼び出しによる結果をすべての呼び出しに返す
      if (this.confirmAllowDiscardChangesProgress > 0) {
        if (this.confirmAllowDiscardChangesProgress === 2) {
          // 破棄確認中の場合
          // 破棄確認直前コールバックが設定されていれば呼び出しておく
          if (options.beforeConfirmCallback) {
            options.beforeConfirmCallback();
          }
        }
        return await new Promise((resolve) => {
          this.confirmAllowDiscardChangesQueue.push({ options, resolve });
        });
      }

      this.confirmAllowDiscardChangesProgress = 1; // confirmContentChangedの処理中
      let cancelled = false;
      await this.confirmContentChanged();
      //add #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
      if ((this.isChanged || this.isChangePatId) && this.alertFlag) {
      //add #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc end
        // 破棄確認直前コールバックが設定されていれば呼び出しておく
        if (options.beforeConfirmCallback) {
          options.beforeConfirmCallback();
        }
        this.confirmAllowDiscardChangesQueue.forEach((context) => {
          if (context.options.beforeConfirmCallback) {
            context.options.beforeConfirmCallback();
          }
        });
        this.confirmAllowDiscardChangesProgress = 2; // notification.confirmの処理中
        await this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[12000014].title,
          message: DIALOG_MESSAGES[12000014].message,
          callback: answer => {
            if (answer === 0) {
              cancelled = true;
            }
          }
        });
        //add #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
        this.isChangePatId = false;
        //add #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc end
      }
      this.confirmAllowDiscardChangesProgress = 0; // 処理中ではない

      const result = !cancelled;
      this.confirmAllowDiscardChangesQueue.forEach(context => context.resolve(result));
      this.confirmAllowDiscardChangesQueue.length = 0;

      return result;
    },
    handleBeforeTreatmentRecordSelectedPatIdChange() {
      if (!this.isTreatmentObserveDetail) return;
      if (this.ignoreWatchSelectedPatId) {
        // 患者を戻している間は治療記録側の処理は進めないようにする
        const task = new Promise((resolve) => {
          resolve(false);
        });
        EventBus.$emit("addConfirmTreatmentRecordSelectedPatIdChangeTasks", task);
        return;
      }

      if (!this.getPatEventRecord) return;
      const task = new Promise(async (resolve) => {
        if (await this.confirmAllowDiscardChanges()) {
          // 内容破棄をキャンセルしない場合は編集内容のクリアのみを行って
          // 画面遷移などは治療記録側で行う
          this.setRelease();
          await this.setPatEventRecord(null);
          resolve(true);
        } else {
          // 内容破棄をキャンセルした場合は患者を戻す
          if (this.getPatEventRecord.patId !== this.selectedPatId) {
            this.ignoreWatchSelectedPatId = true;
            await this.setSelectedPatHeader(this.getPatEventRecord.patId);
            this.ignoreWatchSelectedPatId = false;
            resolve(false);
          }
        }
      });
      EventBus.$emit("addConfirmTreatmentRecordSelectedPatIdChangeTasks", task);
    },
    async setSubCategoryClear() {
      this.inputModel.subCategoryCd = 0;
      // 患者イベントもしくは紹介状の場合はサブカテゴリの先頭の項目を初期選択する
      if (["pat-intro-letter", "pat-event"].includes(this.selfScreenName)) {
        await this.selectFirstSubCategory();
      }
    },
    async selectFirstSubCategory() {
      const firstSubCategory = this.selectTemplates.find((item) => {
        if (item.categoryCode !== undefined) return false;
        if (item.code === 0) return false;
        return true;
      });
      if (firstSubCategory) {
        await this.setSelectSubCategory(firstSubCategory.code.toString());
        await this.changeTemplate();
      }
    },
	sortDispData(categories,subCategories) {
	  let sortedSubCategories = [];
	  categories.forEach(category => {
	    subCategories.forEach(subCategory => {
	      if(category.categoryCd === subCategory.categoryCd){
		    sortedSubCategories.push(subCategory);
		  }
	    })
	  })
	  return sortedSubCategories;
	},
    /**
     * レポート情報
     */
    async getMstReport() {
      // mod #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy start
      // await ApiHelper.get("/report/getMstReportByFacilityCd/" + this.facilityCd)
      // mod #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao start
      //await ApiHelper.get("/report/getMstReportByFacilityCdNoIsDisp/" + this.facilityCd)
      await ApiHelper.get("/report/getMstReportByFacilityCdNoIsDel/" + this.facilityCd)
      // mod #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao end
      // mod #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy end
        .then(response => {
          const filteredReport = response.data.filter(item => {
            return item.reportClass == 9;
          });
          if (filteredReport.length > 0) {
            const reportList = filteredReport.map(item => {
              return {
                reportCd: item.reportCd,
                reportName: item.reportName,
                defaultPrinter: item.defaultPrinter
              };
            });
            this.setReportList(reportList);
          }
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('PatEventDetailComponent.vue', 'getMstReport', 'レポートマスターをロードしませんでした');
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        });
    },
    /**
     * メインのリストを表示
     */
    onMainListOpen() {
      EventBus.$emit("openMainList");
    },
    /**
     *
     */
    viewStyles(formatClass) {
      if (formatClass === 8 && !this.isViewScore) {
        return { display: "none" };
      }
      return { display: "table" };
      /*add FNSI-改修内容転入時の紹介状取込ができない 任 start*/
    },
    trigger() {
      this.$refs.fileBtn.dispatchEvent(new MouseEvent("click"));
    },
    // add FNSI-権限関連 王 20200927 start
    // 治療記録の權限を取得する
    getTreatmentRecordAuthority() {
      return this.hasAuthority();
    },
    getTreatmentRecordAuthorityDel() {
      if (this.$route.path.indexOf("treatment-record") > 0) {
        return this.getItemAuthorized('PatEvent', 'item_patrst_del');
      } else {
        return this.getItemAuthorized('PatEvent', 'item_patevent_del');
      }
    },
    getFile(event) {
      // 指定ファイルの表示
      this.letterFile = event.target.files[0];
      if (this.letterFile !== undefined) {
        const reader = new FileReader();
        reader.onload = () => {
          this.letterFileName = this.letterFile.name;
          this.setPath(reader.result);
          this.setDisplayTwo(true);
          this.setIsShowSomeThing(false);
          store.dispatch("loading-screen/setLoadingScreenVisible", false);
          document.getElementById("uploadFile").value = null;
        };
        store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
        store.dispatch("loading-screen/setLoadingScreenVisible", true);
        reader.readAsDataURL(this.letterFile);
      } else {
        this.letterFileName = "";
      }
    },
    async letterFileUpload(params) {
      let fileFormData = new FormData();
      fileFormData.append('file', this.letterFile, this.letterFileName);
      let requestConfig = {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      }
      store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
      store.dispatch("loading-screen/setLoadingScreenVisible", true);
      let client = axios.create({ baseURL: "/ntss-admin-web/api" })
      const res = await client.post(`/report/upload/${params.facilityCd}&${params.patId}&${params.patEventCd}`, fileFormData, requestConfig)
        .catch(error => {
          store.dispatch("loading-screen/setLoadingScreenVisible", false);
          getErrorMessage('PatEventDetailComponent.vue', 'getFile', 'レポートマスターをロードしませんでした');
          return {
            result: false,
            uplordPath: null
          };
        });
      store.dispatch("loading-screen/setLoadingScreenVisible", false);
      if (res.status !== 200) {
        return {
          result: false,
          uplordPath: null
        };
      } else {
        return {
          result: true,
          uplordPath: res.data.htmlTemplate
        };
      }
      /*add FNSI-改修内容転入時の紹介状取込ができない 任 end*/
      /*add FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 start*/
    },
    /*add FNSI-改修内容538 連携イベントの登録適正化 任 start*/
    sendPostApi(baseDate,opeCd,patEventCd){
      const params = {
        facility_cd: this.getFacilityCd,
        coop_cd: "rst_dial",
        coop_cd_index: "",
        crud: "U",
        direction: "S",
        ana_result: "0",
        coop_result: "0",
        pat_id: this.selectedPatId,
        ord_no: this.$parent.$data.oldOrdNo,
        base_date: baseDate,
        ope_cd: opeCd,
        user_id: this.getUserId,
        pat_event_cd: patEventCd
      }
      createJournal(params)
    },
    /*add FNSI-改修内容538 連携イベントの登録適正化 任 end*/
    //add オンプレミスの場合、転入患者さんの紹介状が取込できない 吉 start
    showPdf (data,pdfPath) {
      axios({
        method: 'post',
        url: '/ntss-admin-web/api/report/getPdf',
        headers: {
          'Content-Type': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        },
        data:data,
        responseType: 'blob'
      }).then(response => {
        var blob = new Blob([response.data], {
          type: 'application/pdf;chartset=UTF-8'
        })
        var src  = this.getObjectURL(blob);
        this.setPath(src);
        this.setDBPath(pdfPath);
      }).catch(function (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('PatEventDetailComponent.vue', 'showPdf', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
      });
    },
    getObjectURL(file) {
      let url = null
      if (window.createObjectURL !== undefined) {
        url = window.createObjectURL(file)
      } else if (window.webkitURL !== undefined) {
        try {
          var blob = new Blob([file], {
            type: 'application/png;charset=utf-8',
          });
          url = window.webkitURL.createObjectURL(blob)
        } catch (error) {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('PatEventDetailComponent.vue', 'getObjectURL', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        }
      } else if (window.URL !== undefined) {
        try {
          url = window.URL.createObjectURL(file)
        } catch (error) {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('PatEventDetailComponent.vue', 'getObjectURL', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        }
      }
      return url
    },
    //add オンプレミスの場合、転入患者さんの紹介状が取込できない 吉 end
    getNewTemplate(){
      if (JSON.stringify(this.backupPatEventRecord) === JSON.stringify(this.getPatEventRecord)) {
        this.backupPatEventRecord = deepCopy(this.getPatEventRecord);
        this.setInitPatEventRecord(deepCopy(this.getPatEventRecord));
        const templates = this.getMstTemplateRecords;
        const template = templates.find(item => {
          return item.templateCd === this.backupPatEventRecord.templateCd;
        });
        /*add FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 end*/
        const patEventRecord = this.convertPatEventRecord(deepCopy(this.getPatEventRecord), template);
        this.setPatEventRecord(patEventRecord);
        this.setPatEventInputParams(template.inputParams);
      }
    },
    // add 9868 特定の操作で紹介状で紹介状以外の患者イベントを新規作成できてしまう 関 start
    initPatIntroLetter() {
      if (this.isPatIntroLetter) {
        const filteredSub = this.getMstAllSubCategoryRecords.filter(rec => rec.useType === 3);
        this.setMstAllSubCategoryRecords(filteredSub);
        const lastSub = filteredSub.filter(rec => rec.isDisp === "1");
        this.setMstSubCategoryRecords(lastSub);
      }
    },
    // add 9868 特定の操作で紹介状で紹介状以外の患者イベントを新規作成できてしまう 関 end
    /**
     * 患者イベントレコードの変換
     * @param {Object} patEventRecord 患者イベントレコード
     * @param {Object} template       (新)テンプレートレイアウト
     */
    convertPatEventRecord(patEventRecord, template) {
      // 変換対象項目の取得
      const inputParams = patEventRecord.inputParams;
      const resultParams = this.getSortedResultParams(patEventRecord.inputParams, patEventRecord.resultParams, template);
      const regStaffInfo = patEventRecord.regStaffInfo;
      const upStaffInfo = patEventRecord.upStaffInfo;
      // JSON文字列化
      patEventRecord.inputParams = JSON.stringify(inputParams);
      patEventRecord.resultParams = JSON.stringify(resultParams);
      patEventRecord.regStaffInfo = JSON.stringify(regStaffInfo);
      patEventRecord.upStaffInfo = JSON.stringify(upStaffInfo);
      // 患者イベントレコードの変換
      return patEventRecord;
    },
    /**
     * ソート済入力内容の取得
     * @param {Object} editedInputParams  (旧)テンプレートレイアウト
     * @param {Object} editedResultParams 入力内容
     * @param {Object} template           (新)テンプレートレイアウト
     */
    getSortedResultParams(editedInputParams, editedResultParams, template) {
      // 初期化処理
      const resetResultParams = [];
      const upDateParams = [];
      // 入力内容処理((旧)テンプレートレイアウトと入力内容の順序は同じ)
      for (let i = 0; i < editedResultParams.length; i++) {
        // フィールド名 ≠ "NULL"(該当有)の場合
        if (editedResultParams[i].upDate === undefined && editedInputParams[i].field_name != null) {
          // キー(フィールド名)の格納
          editedResultParams[i].field_name = editedInputParams[i].field_name;
        }
        // upDate ≠ "NULL"の場合
        if (editedResultParams[i].upDate != null) {
          // upDateの格納
          upDateParams.push(editedResultParams[i]);
        } else {
          // resetResultParamsの格納
          resetResultParams.push(editedResultParams[i]);
        }
      }
      // 初期化処理
      const sortedResultParams = [];
      const templateInputParams = JSON.parse(template.inputParams);
      // (新)テンプレートレイアウト
      for (let j = 0; j < templateInputParams.length; j++) {
        // フィールド名の検索
        const resetResultParam = resetResultParams.find(item => item.field_name === templateInputParams[j].field_name && item.format_class === templateInputParams[j].format_class);
        // フィールドクラスの取得
        const formatClass = templateInputParams[j].format_class;
        // 入力内容 ≠ "NULL"(該当有)の場合
        if (resetResultParam != null) {
          // -----既存値-----
          // テキストエリアの場合
          if (formatClass === 1) {
            // フィールド名の検索・・・(旧)テキストエリアの取得
            const editedInputParam = editedInputParams.find(item => item.field_name === templateInputParams[j].field_name && item.format_class === templateInputParams[j].format_class);
            // (旧)テキストエリアのテキスト種別 ≠ (新)テキストエリアのテキスト種別の場合
            if (editedInputParam.item_json.is_formatting !== templateInputParams[j].item_json.is_formatting) {
              // デフォルト値の格納
              resetResultParam.result_value = templateInputParams[j].item_json.is_formatting === "0" ? templateInputParams[j].item_json.default_value : templateInputParams[j].item_json.html_value;
            }
          }
          // 要素の削除
          delete resetResultParam.field_name;
          // sortedResultParamsの格納
          sortedResultParams.push(resetResultParam);
        } else {
          // -----デフォルト値-----
          // 初期化処理
          let resultValue = null;
          // 条件分岐
          if (formatClass === 0) {
            // ・テキストボックス
            resultValue = templateInputParams[j].item_json.default_value;
          } else if (formatClass === 1) {
            // ・テキストエリア
            resultValue = templateInputParams[j].item_json.is_formatting === "0" ? templateInputParams[j].item_json.default_value : templateInputParams[j].item_json.html_value;
          } else if (formatClass === 2) {
            // ・画像
            resultValue = this.getTemplateImage(templateInputParams[j].item_json.image_num);
          } else if (formatClass === 3) {
            // ・リストボックス
            resultValue = [];
          } else if (formatClass === 4) {
            // ・ラジオボタン
            resultValue = [];
          } else if (formatClass === 5) {
            // ・日付
            resultValue = this.getTemplateDate(templateInputParams[j].item_json.date_class);
          } else if (formatClass === 6) {
            // ・チェックボックス
            resultValue = [];
          } else if (formatClass === 7) {
            // ・添付ファイル(１ファイル)
            resultValue = [];
          } else if (formatClass === 8) {
            // ・スコア計算
            resultValue = "";
          } else if (formatClass === 9) {
            // ・治療実績リンク
            resultValue = "";
          } else if (formatClass === 10) {
            // ・掲示板リンク
            resultValue = "";
          }
          // defaultResultParamsの格納
          sortedResultParams.push({ format_class: formatClass, result_value: resultValue });
        }
      }
      // upDateの結合
      return sortedResultParams.concat(upDateParams);
    },
    /**
     * (新規)観察記録情報の設定
     * @param {Object} initRec 初期値
     * @param {Object} updRec  編集値
     */
    setCreatedObserveRecordInfo(initRec, updRec) {
      // (初期)OrdNoの取得
      const initSelectedOrdNo = initRec.ordNo != null ? initRec.ordNo : 0;
      // (編集)OrdNoの取得
      const editedSelectedOrdNo = updRec.ordNo != null ? updRec.ordNo : 0;
      // ■条件分岐
      if (initSelectedOrdNo !== 0 && editedSelectedOrdNo !== 0) {
        // ・実績リンク有 → 実績リンク有
        updRec.isObserveRecordLog = true;
        updRec.findOrdNo = editedSelectedOrdNo;
      } else if (initSelectedOrdNo === 0 && editedSelectedOrdNo !== 0) {
        // ・実績リンク無 → 実績リンク有
        updRec.isObserveRecordLog = true;
        updRec.findOrdNo = editedSelectedOrdNo;
      } else if (initSelectedOrdNo !== 0 && editedSelectedOrdNo === 0) {
        // ・実績リンク有 → 実績リンク無
        updRec.isObserveRecordLog = true;
        updRec.findOrdNo = initSelectedOrdNo;
      } else {
        // ・実績リンク無 → 実績リンク無
        updRec.isObserveRecordLog = false;
        updRec.findOrdNo = null;
      }
    },
    /**
     * (更新)観察記録情報の設定
     * @param {Object} initRec 初期値
     * @param {Object} updRec  編集値
     */
    async setUpdatedObserveRecordInfo(initRec, updRec) {
      // テンプレートレイアウトの取得
      const inputParams = JSON.parse(updRec.inputParams);
      // (初期)OrdNoの取得
      const initSelectedOrdNo = initRec.ordNo != null ? initRec.ordNo : 0;
      // (編集)OrdNoの取得
      const editedSelectedOrdNo = updRec.ordNo != null ? updRec.ordNo : 0;
      // ■条件分岐
      if (initSelectedOrdNo !== 0 && editedSelectedOrdNo !== 0) {
        // ・実績リンク有 → 実績リンク有
        updRec.isObserveRecordLog = true;
        updRec.findOrdNo = editedSelectedOrdNo;
        updRec.procState = this.getUpdateMode === false ? "1" : "2";
        updRec.templateLayoutDiff = this.getTemplateLayoutDiff(initRec, updRec);
        updRec.observeRecordDiff = await this.getObserveRecordDiff(inputParams, initRec, updRec);
      } else if (initSelectedOrdNo === 0 && editedSelectedOrdNo !== 0) {
        // ・実績リンク無 → 実績リンク有
        updRec.isObserveRecordLog = true;
        updRec.findOrdNo = editedSelectedOrdNo;
        updRec.procState = this.getUpdateMode === false ? "1" : "2";
        updRec.templateLayoutDiff = this.getTemplateLayoutDiff(initRec, updRec);
        updRec.observeRecordDiff = await this.getObserveRecordDiff(inputParams, initRec, updRec);
      } else if (initSelectedOrdNo !== 0 && editedSelectedOrdNo === 0) {
        // ・実績リンク有 → 実績リンク無
        updRec.isObserveRecordLog = true;
        updRec.findOrdNo = initSelectedOrdNo;
        updRec.procState = this.getUpdateMode === false ? "1" : "2";
        updRec.templateLayoutDiff = this.getTemplateLayoutDiff(initRec, updRec);
        updRec.observeRecordDiff = await this.getObserveRecordDiff(inputParams, initRec, updRec);
      } else {
        // ・実績リンク無 → 実績リンク無
        updRec.isObserveRecordLog = false;
        updRec.findOrdNo = null;
        updRec.procState = null;
        updRec.templateLayoutDiff = null;
        updRec.observeRecordDiff = null;
      }
    },
    /**
     * (削除)観察記録情報の設定
     * @param {Object} initRec 初期値
     * @param {Object} updRec  編集値
     */
    setDeletedObserveRecordInfo(initRec, updRec) {
      // (初期)OrdNoの取得
      const initSelectedOrdNo = initRec.ordNo != null ? initRec.ordNo : 0;
      // ■条件分岐
      if (initSelectedOrdNo !== 0) {
        // ・実績リンク有
        updRec.isObserveRecordLog = true;
        updRec.findOrdNo = initSelectedOrdNo;
        updRec.procState = "3";
      } else {
        // ・実績リンク無
        updRec.isObserveRecordLog = false;
        updRec.findOrdNo = null;
        updRec.procState = null;
      }
    },
    /**
     * テンプレートレイアウト差分の取得
     * @param {Object} initPatEventRecord   初期値
     * @param {Object} editedPatEventRecord 編集値
     */
    getTemplateLayoutDiff(initPatEventRecord, editedPatEventRecord) {
      // 初期化処理
      const diff = [];
      // クローンの作成
      const initPatEventRecords = deepCopy(initPatEventRecord);
      const editedPatEventRecords = deepCopy(editedPatEventRecord);
      // テンプレートレイアウトの取得
      const initInputParams = initPatEventRecords.inputParams;
      const editedInputParams = JSON.parse(editedPatEventRecords.inputParams);
      // テンプレートレイアウト処理(旧→新テンプレートレイアウトの変化点)
      initInputParams.forEach(x => {
        // フィールド名の検索
        const inputParam = editedInputParams.find(y => x.field_name === y.field_name && x.format_class === y.format_class);
        // フィールド = "undefined"(削除済)の場合
        if (inputParam === undefined) {
          // フィールド名の取得
          const columnName = x.format_class !== 10 ? x.field_name : "掲示板リンク";
          // テンプレートレイアウト差分の格納
          diff.push({ column_name: columnName, is_diff_check: "1" });
        }
      });
      // JSON文字列化
      return JSON.stringify(diff);
    },
    /**
     * 観察記録差分の取得
     * @param {Object} inputParams          テンプレートレイアウト
     * @param {Object} initPatEventRecord   初期値
     * @param {Object} editedPatEventRecord 編集値
     */
    async getObserveRecordDiff(inputParams, initPatEventRecord, editedPatEventRecord) {
      // 初期化処理
      const diff = [];
      // クローンの作成
      const initPatEventRecords = deepCopy(initPatEventRecord);
      const editedPatEventRecords = deepCopy(editedPatEventRecord);
      // 入力内容の取得
      const initResultParams = this.setAttributeParams(initPatEventRecords.inputParams, initPatEventRecords.resultParams);
      const editedResultParams = this.setAttributeParams(JSON.parse(editedPatEventRecords.inputParams), JSON.parse(editedPatEventRecords.resultParams));
      // -----必須フィールド-----
      // ・開始日時
      let initEventStartDateTime = "";
      let editedEventStartDateTime = "";
      if (!this.getUpdateMode) {
        editedEventStartDateTime = this.$refs.tab.inputModel.dayStartTime != null && this.$refs.tab.inputModel.dayStartTime != ":" ? moment(this.$refs.tab.inputModel.dayStartDate + " " + this.$refs.tab.inputModel.dayStartTime).format("YYYY/MM/DD HH:mm") : moment(this.$refs.tab.inputModel.dayStartDate).format("YYYY/MM/DD");
      } else {
        initEventStartDateTime = initPatEventRecords.eventStartTime != null && initPatEventRecords.eventStartTime != ":" ? moment(initPatEventRecords.eventStartDate + " " + initPatEventRecords.eventStartTime).format("YYYY/MM/DD HH:mm") : moment(initPatEventRecords.eventStartDate).format("YYYY/MM/DD");
        editedEventStartDateTime = editedPatEventRecords.eventStartTime != null && editedPatEventRecords.eventStartTime != ":" ? moment(editedPatEventRecords.eventStartDate + " " + editedPatEventRecords.eventStartTime).format("YYYY/MM/DD HH:mm") : moment(editedPatEventRecords.eventStartDate).format("YYYY/MM/DD");
      }
      diff.push({ format_class: -1, column_name: "開始日時", old_value: initEventStartDateTime, new_value: editedEventStartDateTime, is_diff_check: "1" });
      // ・実績リンク
      let initSelectedOrdMainText = "";
      let editedSelectedOrdMainText = "";
      // (患者イベント紐付済)OrdMainの取得
      const initSelectedOrdMain = await this.getSelectedOrdMain(initPatEventRecords);
      const editedSelectedOrdMain = await this.getSelectedOrdMain(editedPatEventRecords);
      // 実績リンクテキストの取得
      initSelectedOrdMainText = await this.getSelectedOrdMainText(initSelectedOrdMain);
      editedSelectedOrdMainText = await this.getSelectedOrdMainText(editedSelectedOrdMain);
      // 表示・非表示の判別
      const inputParam = inputParams.find(item => {
        return item.format_class == 9;
      });
      diff.push({ format_class: 9, column_name: inputParam != null ? inputParam.field_name : "実績リンク", old_value: initSelectedOrdMainText, new_value: editedSelectedOrdMainText, is_diff_check: "1" });
      // -----任意フィールド-----
      for (let i = 0; i < inputParams.length; i++) {
        // 初期化処理
        const formatClass = inputParams[i].format_class;
        const columnName = inputParams[i].field_name;
        // フィールド入力内容の取得
        const initResultParam = initResultParams.find(item => item.field_name === columnName && item.format_class === formatClass);
        const editedResultParam = editedResultParams.find(item => item.field_name === columnName && item.format_class === formatClass);
        let oldValue = null;
        let newValue = null;
        // ■フィールドクラス(項目属性)別
        if (formatClass === 0) {
          // ・テキストボックス
          oldValue = initResultParam != null ? initResultParam.result_value : "";
          newValue = editedResultParam != null ? editedResultParam.result_value : "";
          diff.push({ format_class: formatClass, column_name: columnName, old_value: oldValue, new_value: newValue, is_diff_check: "1" });
        } else if (formatClass === 1) {
          // ・テキストエリア
          const initInputParams = initPatEventRecords.inputParams;
          const editedInputParams = JSON.parse(editedPatEventRecords.inputParams);
          oldValue = this.getInputTextArea(initInputParams, initResultParam, columnName);
          newValue = this.getInputTextArea(editedInputParams, editedResultParam, columnName);
          diff.push({ format_class: formatClass, column_name: columnName, old_value: oldValue, new_value: newValue, is_diff_check: "1" });
        } else if (formatClass === 2) {
          // ・画像
          const imgFileList = inputParams[i].item_json.values != null ? inputParams[i].item_json.values : new Array();
          const initImgFileContentsList = this.getImgFileContentsList(initResultParam);
          const editedImgFileContentsList = this.getImgFileContentsList(editedResultParam);
          for (let j = 0; j < imgFileList.length; j++) {
            const imgName = imgFileList[j].name;
            const initImgFileModifiedTime = this.getImgFileModifiedTime(initImgFileContentsList[j]);
            const editedImgFileModifiedTime = this.getImgFileModifiedTime(editedImgFileContentsList[j]);
            const isModified = initImgFileModifiedTime !== editedImgFileModifiedTime ? "1" : "0";
            oldValue = this.getImgFileName(initImgFileContentsList[j]);
            newValue = this.getImgFileName(editedImgFileContentsList[j]);
            diff.push({ format_class: formatClass, column_name: columnName, img_name: imgName, old_value: oldValue, new_value: newValue, is_modified: isModified, is_diff_check: "1" });
          }
        } else if (formatClass === 3) {
          // ・リストボックス
          oldValue = initResultParam != null ? initResultParam.result_value.length == null ? initResultParam.result_value.name : "" : "";
          newValue = editedResultParam != null ? editedResultParam.result_value.length == null ? editedResultParam.result_value.name : "" : "";
          diff.push({ format_class: formatClass, column_name: columnName, old_value: oldValue, new_value: newValue, is_diff_check: "1" });
        } else if (formatClass === 4) {
          // ・ラジオボタン
          oldValue = initResultParam != null ? initResultParam.result_value.length == null ? initResultParam.result_value.name : "" : "";
          newValue = editedResultParam != null ? editedResultParam.result_value.length == null ? editedResultParam.result_value.name : "" : "";
          diff.push({ format_class: formatClass, column_name: columnName, old_value: oldValue, new_value: newValue, is_diff_check: "1" });
        } else if (formatClass === 5) {
          // ・日付
          oldValue = initResultParam != null ? initResultParam.result_value != null ? moment(initResultParam.result_value).format("YYYY/MM/DD") : "" : "";
          newValue = editedResultParam != null ? editedResultParam.result_value != null ? moment(editedResultParam.result_value).format("YYYY/MM/DD") : "" : "";
          diff.push({ format_class: formatClass, column_name: columnName, old_value: oldValue, new_value: newValue, is_diff_check: "1" });
        } else if (formatClass === 6) {
          // ・チェックボックス
          const initCheckBoxContentsList = this.getCheckBoxContentsList(initResultParam);
          const editedCheckBoxContentsList = this.getCheckBoxContentsList(editedResultParam);
          oldValue = this.getCheckBoxText(initCheckBoxContentsList);
          newValue = this.getCheckBoxText(editedCheckBoxContentsList);
          diff.push({ format_class: formatClass, column_name: columnName, old_value: oldValue, new_value: newValue, is_diff_check: "1" });
        } else if (formatClass === 7) {
          // ・添付ファイル
          const initFileContentsList = this.getFileContentsList(initResultParam);
          const editedFileContentsList = this.getFileContentsList(editedResultParam);
          if (initFileContentsList.length === 1 && editedFileContentsList.length === 1) {
            const initFileModifiedTime = this.getFileModifiedTime(initFileContentsList[0]);
            const editedFileModifiedTime = this.getFileModifiedTime(editedFileContentsList[0]);
            const isModified = initFileModifiedTime !== editedFileModifiedTime ? "1" : "0";
            oldValue = this.getFileName(initFileContentsList[0]);
            newValue = this.getFileName(editedFileContentsList[0]);
            diff.push({ format_class: formatClass, column_name: columnName, old_value: oldValue, new_value: newValue, is_modified: isModified, is_diff_check: "1" });
          } else {
            let initFiles = initFileContentsList;
            let editedFiles = this.getEditedFiles(initFileContentsList, editedFileContentsList);
            for (let j = 0; j < editedFiles.length; j++) {
              const initFileModifiedTime = this.getFileModifiedTime(initFiles[j]);
              const editedFileModifiedTime = this.getFileModifiedTime(editedFiles[j]);
              const isModified = initFileModifiedTime !== editedFileModifiedTime ? "1" : "0";
              oldValue = this.getFileName(initFiles[j]);
              newValue = this.getFileName(editedFiles[j]);
              diff.push({ format_class: formatClass, column_name: columnName, old_value: oldValue, new_value: newValue, is_modified: isModified, is_diff_check: "1" });
            }
          }
        } else if (formatClass === 8) {
          // ・スコア計算
          oldValue = initResultParam != null ? initResultParam.result_value != "" ? initResultParam.result_value.score : "" : "";
          newValue = editedResultParam != null ? editedResultParam.result_value != "" ? editedResultParam.result_value.score : "" : "";
          const oldUnit = initResultParam != null ? initResultParam.result_value != "" ? initResultParam.result_value.unit : "" : "";
          const newUnit = editedResultParam != null ? editedResultParam.result_value != ""  ? editedResultParam.result_value.unit : "" : "";
          diff.push({ format_class: formatClass, column_name: columnName, old_value: oldValue, new_value: newValue, old_unit: oldUnit, new_unit: newUnit, is_diff_check: "1" });
        } else if (formatClass === 9) {
          // ・治療実績リンク
          //   非表示でも内容保持するため、必須フィールドとして処理
        } else if (formatClass === 10) {
          // ・掲示板リンク
          const initBbsInfo = initResultParam != null ? initResultParam.result_value : "";
          const editedBbsInfo = editedResultParam != null ? editedResultParam.result_value : "";
          // >>> 掲載有無
          const oldValue_1 = this.getBbsExist(initBbsInfo, initPatEventRecords.bbsCtlNo);
          const newValue_1 = this.getBbsExist(editedBbsInfo, editedPatEventRecord.bbsCtlNo);
          diff.push({ format_class: formatClass, column_name: "掲示板リンク 掲載有無", old_value: oldValue_1, new_value: newValue_1, is_diff_check: "1" });
          // >>> 掲載期間
          const oldValue_2 = this.getBbsTerm(initBbsInfo);
          const newValue_2 = this.getBbsTerm(editedBbsInfo);
          diff.push({ format_class: formatClass, column_name: "掲示板リンク 掲載期間", old_value: oldValue_2, new_value: newValue_2, is_diff_check: "1" });
          // >>> スタッフ
          const oldValue_3 = this.getBbsStaff(initBbsInfo, initPatEventRecords.bbsCtlNo);
          const newValue_3 = this.getBbsStaff(editedBbsInfo, editedPatEventRecord.bbsCtlNo);
          diff.push({ format_class: formatClass, column_name: "掲示板リンク スタッフ", old_value: oldValue_3, new_value: newValue_3, is_diff_check: "1" });
          // >>> 個別スタッフ(人数)
          const initBbsStaff = oldValue_3;
          const editedBbsStaff = newValue_3;
          // 個別スタッフ選択時の場合
          if (newValue_3 === "個別スタッフ") {
            const initBbsIndividualStaffCdList = this.getBbsIndividualStaffCdList(initBbsInfo, initPatEventRecords.bbsCtlNo);
            const editedBbsIndividualStaffCdList = this.getBbsIndividualStaffCdList(editedBbsInfo, editedPatEventRecord.bbsCtlNo);
            const isDiffCheck =  this.getIsDiffCheck(initBbsIndividualStaffCdList, editedBbsIndividualStaffCdList);
            const oldValue_4 = initBbsStaff === "個別スタッフ" ? initBbsIndividualStaffCdList.length - 1 + "名" : initBbsIndividualStaffCdList.length + "名";
            const newValue_4 = editedBbsStaff === "個別スタッフ" ? editedBbsIndividualStaffCdList.length - 1 + "名" : editedBbsIndividualStaffCdList.length + "名";
            diff.push({ format_class: formatClass, column_name: "掲示板リンク 個別スタッフ", old_value: oldValue_4, new_value: newValue_4, is_diff_check: isDiffCheck });
          }
        }
      }
      // JSON文字列化
      return JSON.stringify(diff);
    },
    /**
     * 属性(キー)の付与
     * @param {Object} inputParams  レイアウト
     * @param {Object} resultParams 入力値
     */
    setAttributeParams(inputParams, resultParams) {
      // 初期化処理
      const attributedParams = [];
      // 入力値処理
      for (let i = 0; i < resultParams.length; i++) {
        // upDate = "undefined"(該当無)の場合
        if (resultParams[i].upDate === undefined) {
          // キー(フィールド名)の格納
          resultParams[i].field_name = inputParams[i].field_name;
        }
        // 配列の格納
        attributedParams.push(resultParams[i]);
      }
      // 属性(キー)の付与
      return attributedParams;
    },
    /**
     * OrdMainの取得
     * @param {Object} patEventRecord 患者イベントレコード
     */
    async getSelectedOrdMain(patEventRecord) {
      // 初期化処理
      let selectedOrdMain = null;
      // OrdMain.ordNo ≠ "NULL"の場合
      if (patEventRecord.ordNo != null) {
        // OrdMainのフェッチ
        await this.fetchOrdMainRecord({
          patId: patEventRecord.patId,
          ordNo: patEventRecord.ordNo
        }).then(res => {
          // OrdMainの抽出
          selectedOrdMain = res.data != null ? res.data : { viewTreatDate: -1 };
        });
      }
      // OrdMainの取得
      return selectedOrdMain;
    },
    /**
     * 実績リンクテキストの取得
     * @param {Object} ordMain OrdMain
     */
    async getSelectedOrdMainText(ordMain) {
      // 初期化処理
      let selectedOrdMainText = "";
      // OrdMain ≠ ""の場合
      if (ordMain && ordMain !== "") {
        // OrdMain.ViewTreatDate = "-1"(削除済)の場合
        if (String(ordMain.viewTreatDate) === "-1") {
          selectedOrdMainText = "削除";
        } else {
          // rstDialysisState = "0"(予定)の場合
          if (ordMain.rstDialysisState === "0") {
            selectedOrdMainText = `${ordMain.viewTreatDate === null ? moment(ordMain.treatDate).format("YYYY/MM/DD") : ordMain.viewTreatDate}` +
                                  " 予定 " +
                                  `${ordMain.indKurName === null ? "-" : ordMain.indKurName} ${ordMain.indBedName === null ? "-" : ordMain.indBedName} ${ordMain.indTreatmentName === null ? "-" : ordMain.indTreatmentName}`;
          } else {
            selectedOrdMainText = `${moment(ordMain.treatDate).format("YYYY/MM/DD")}` +
                                  " 実績 " +
                                  `${ordMain.rstKurName === null ? "-" : ordMain.rstKurName} ${ordMain.rstBedName === null ? "-" : ordMain.rstBedName} ${ordMain.rstTreatmentName === null ? "-" : ordMain.rstTreatmentName}`;
          }
        }
      }
      // 実績リンクテキストの取得
      return selectedOrdMainText;
    },
    /**
     * テキストエリアの取得
     * @param {Object} inputParams テンプレートレイアウト
     * @param {Object} resultParam 入力値
     * @param {String} columnName  項目名
     */
    getInputTextArea(inputParams, resultParam, columnName) {
      // 初期化処理
      let textArea = "";
      // フィールドの取得
      const inputParam = inputParams.find(item => item.field_name === columnName);
      // フィールド ≠ "NULL"(該当無)の場合
      if (inputParam != null) {
        // 条件分岐
        if (inputParam.item_json.is_formatting === "0") {
          // ・テキストエリア形式 = "0"(TEXT)
          // 入力値 ≠ "NULL"(無)の場合
          if (resultParam != null) {
            // " "置換
            textArea = resultParam.result_value.replaceAll("\n", " ")
          }
        } else {
          // ・テキストエリア形式 = "1"(リッチテキスト)
          // HTMLコンテンツの取得
          const htmlContentsList = this.getHTMLContentsList(resultParam);
          // HTMLテキストの取得
          textArea = this.getHTMLText(htmlContentsList);
        }
      }
      // テキストエリアの取得
      return textArea;
    },
    /**
     * HTMLコンテンツリストの取得
     * @param {Object} resultParam 入力値
     */
    getHTMLContentsList(resultParam) {
      // 初期化処理
      let htmlContentsList = new Array();
      // テンプレートの作成
      const template = document.createElement("template");
      // innerHTMLの格納
      template.innerHTML = resultParam != null ? resultParam.result_value : "";
      // HTMLコンテンツの配列化
      htmlContentsList = Array.from(template.content.children);
      // HTMLコンテンツリストの取得
      return htmlContentsList;
    },
    /**
     * HTMLテキストの取得
     * @param {Array} htmlContentsList HTMLコンテンツリスト
     */
    getHTMLText(htmlContentsList) {
      // 初期化処理
      let htmlText = "";
      const htmlTextList = [];
      // HTMLコンテンツリスト処理
      htmlContentsList.forEach(item => {
        // innerTextの格納
        htmlTextList.push(item.innerText);
      });
      // " "連結
      htmlText = htmlTextList.join(" ").length > 1 ? htmlTextList.join(" ") : "";
      // HTMLテキストの取得
      return htmlText;
    },
    /**
     * 画像ファイルコンテンツリストの取得
     * @param {Object} resultParam 入力値
     */
    getImgFileContentsList(resultParam) {
      // 初期化処理
      let imgFileContentsList = new Array();
      // 入力値 ≠ "NULL"(該当有)の場合
      if (resultParam != null) {
        // 画像ファイル ≠ "NULL"の場合
        if (resultParam.result_value != null) {
          // 入力値の格納
          imgFileContentsList = resultParam.result_value;
        }
      }
      // 画像ファイルコンテンツリストの取得
      return imgFileContentsList;
    },
    /**
     * 画像ファイル編集日時の取得
     * @param {Object} imgFileContents 画像ファイルコンテンツ
     */
    getImgFileModifiedTime(imgFileContents) {
      // 初期化処理
      let imgFileModifiedTime = "";
      // 画像ファイル編集日時 ≠ "NULL"の場合
      if (imgFileContents != null && imgFileContents.file_modified_time != null) {
        // 画像ファイル編集日時の格納
        imgFileModifiedTime = imgFileContents.file_modified_time;
      }
      // 画像ファイル編集日時の取得
      return imgFileModifiedTime;
    },
    /**
     * 画像ファイル名の取得
     * @param {Object} imgFileContents 画像ファイルコンテンツ
     */
    getImgFileName(imgFileContents) {
      // 初期化処理
      let imgFileName = "";
      // 画像ファイル名 ≠ "NULL"の場合
      if (imgFileContents != null && imgFileContents.file_name != null) {
        // 画像ファイル名の格納
        imgFileName = imgFileContents.file_name;
      }
      // 画像ファイル名の取得
      return imgFileName;
    },
    /**
     * チェックボックスコンテンツリストの取得
     * @param {Object} resultParam 入力値
     */
    getCheckBoxContentsList(resultParam) {
      // 初期化処理
      let checkBoxContentsList = new Array();
      // 入力値 ≠ "NULL"(該当有)の場合
      if (resultParam != null) {
        // 入力値の格納
        checkBoxContentsList = resultParam.result_value;
      }
      // チェックボックスコンテンツリストの取得
      return checkBoxContentsList;
    },
    /**
     * チェックボックステキストの取得
     * @param {ArrayList} checkBoxContentsList チェックボックスコンテンツリスト
     */
    getCheckBoxText(checkBoxContentsList) {
      // 初期化処理
      const checkBoxList = [];
      // チェックボックスコンテンツリスト処理
      checkBoxContentsList.forEach(item => {
        // Nameの格納
        checkBoxList.push(item.name);
      });
      // "、"連結
      return checkBoxList.join("、");
    },
    /**
     * 添付ファイルコンテンツリストの取得
     * @param {Object} resultParam 入力値
     */
    getFileContentsList(resultParam) {
      // 初期化処理
      let fileContentsList = new Array();
      // 入力値 ≠ "NULL"(該当有)の場合
      if (resultParam != null) {
        // 添付ファイル登録件数 > "0"の場合
        if (resultParam.result_value != null && resultParam.result_value.length > 0) {
          // 入力値の格納
          fileContentsList = resultParam.result_value;
        }
      }
      // 添付ファイルコンテンツリストの取得
      return fileContentsList;
    },
    /**
     * (編集)添付ファイルの取得
     * @param {Object} initFileContentsList   (初期)添付ファイルコンテンツリスト
     * @param {Object} editedFileContentsList (編集)添付ファイルコンテンツリスト
     * @memo  (編集)添付ファイル配列数の補正処理
     */
    getEditedFiles(initFileContentsList, editedFileContentsList) {
      // 初期化処理
      const editedFiles = [];
      // 編集ファイル・削除ファイル処理
      initFileContentsList.forEach(initFile => {
        // ファイル名の検索
        const findFile = editedFileContentsList.find(editedFile => editedFile.file_name === initFile.file_name);
        // ファイル情報 ≠ "NULL"(該当有)の場合
        if (findFile != null) {
          // ファイル情報の格納
          editedFiles.push(findFile);
        } else {
          // (空)ファイル情報の格納(削除済のため)
          editedFiles.push({ file_name: "", file_path: "", file_modified_time: "" });
        }
      });
      // 追加ファイル処理
      editedFileContentsList.forEach(editedFile => {
        // ファイル名の検索
        const findFile = initFileContentsList.find(initFile => initFile.file_name === editedFile.file_name);
        // ファイル情報 = "NULL"(該当無)の場合
        if (findFile == null) {
          // ファイル情報の格納
          editedFiles.push(editedFile);
        }
      });
      // (編集)添付ファイルの取得
      return editedFiles
    },
    /**
     * 添付ファイル編集日時の取得
     * @param {Object} fileContents 添付ファイルコンテンツ
     */
    getFileModifiedTime(fileContents) {
      // 初期化処理
      let fileModifiedTime = "";
      // 添付ファイル編集日時 ≠ "NULL"の場合
      if (fileContents != null && fileContents.file_modified_time != null) {
        // 添付ファイル編集日時の格納
        fileModifiedTime = fileContents.file_modified_time;
      }
      // 添付ファイル編集日時の取得
      return fileModifiedTime;
    },
    /**
     * 添付ファイル名の取得
     * @param {Object} fileContents 添付ファイルコンテンツ
     */
    getFileName(fileContents) {
      // 初期化処理
      let fileName = "";
      // 添付ファイル名 ≠ "NULL"の場合
      if (fileContents != null && fileContents.file_name != null) {
        // 添付ファイル名の格納
        fileName = fileContents.file_name;
      }
      // 添付ファイル名の取得
      return fileName;
    },
    /**
     * (掲示板リンク)掲載有無の取得
     * @param {Object}  bbsInfo  掲示板情報
     * @param {Integer} bbsCtlNo 掲示板管理番号
     */
    getBbsExist(bbsInfo, bbsCtlNo) {
      // 掲示板情報 = ""(該当無)の場合
      if (bbsInfo === "") {
        return "";
      } else {
        // 掲示板管理番号 ≠ "0"(掲載有)の場合
        if (bbsCtlNo !== 0) {
          return "掲載あり";
        } else {
          return "掲載なし";
        }
      }
    },
    /**
     * (掲示板リンク)掲載期間の取得
     * @param {Object} bbsInfo 掲示板情報
     */
    getBbsTerm(bbsInfo) {
      // 掲示板情報 = ""(該当無)の場合
      if (bbsInfo === "") {
        return "";
      } else {
        return bbsInfo.notice_end_date != null ? moment(bbsInfo.notice_start_date).format("YYYY/MM/DD") + "～" + moment(bbsInfo.notice_end_date).format("YYYY/MM/DD") : "";
      }
    },
    /**
     * (掲示板リンク)スタッフの取得
     * @param {Object}  bbsInfo  掲示板情報
     * @param {Integer} bbsCtlNo 掲示板管理番号
     */
    getBbsStaff(bbsInfo, bbsCtlNo) {
      // 掲示板情報 = ""(該当無)の場合
      if (bbsInfo === "") {
        return "";
      } else {
        // 掲示板管理番号 ≠ "0"(掲載有)の場合
        if (bbsCtlNo !== 0) {
          // スタッフ = "0"(個別スタッフ)の場合
          if (bbsInfo.staff_info.target === "0") {
            return "個別スタッフ";
          } else {
            return "全スタッフ";
          }
        } else {
          return "";
        }
      }
    },
    /**
     * (掲示板リンク)個別スタッフコードリストの取得
     * @param {Object} bbsInfo 掲示板情報
     * @param {Integer} bbsCtlNo 掲示板管理番号
     */
    getBbsIndividualStaffCdList(bbsInfo, bbsCtlNo) {
      // 掲示板情報 = ""(該当無)の場合
      if (bbsInfo === "") {
        return new Array();
      } else {
        // 掲示板管理番号 ≠ "0"(掲載有)の場合
        if (bbsCtlNo !== 0) {
          // スタッフ = "0"(個別スタッフ)の場合
          if (bbsInfo.staff_info.target === "0") {
            // 個別スタッフ
            return bbsInfo.staff_info.staff_cd;
          } else {
            // 全スタッフ
            return new Array();
          }
        } else {
          return new Array();
        }
      }
    },
    /**
     * 差分チェックフラグの取得
     * @param {Array} initBbsIndividualStaffCdList   (初期)個別スタッフコードリスト
     * @param {Array} editedBbsIndividualStaffCdList (編集)個別スタッフコードリスト
     * @memo  スタッフが異なるが、人数が同じ場合、java側の差分チェックを行わない
     */
    getIsDiffCheck(initBbsIndividualStaffCdList, editedBbsIndividualStaffCdList) {
      // 初期化処理
      let isDiffCheck = "1";
      // 個別スタッフ同人数の場合
      if (initBbsIndividualStaffCdList.length === editedBbsIndividualStaffCdList.length) {
        // (初期)個別スタッフコードリスト
        for(let i = 0; i < initBbsIndividualStaffCdList.length; i++) {
          // 個別スタッフコードの取得
          const staffCd = initBbsIndividualStaffCdList[i];
          // (編集)個別スタッフコードの検索
          const findStaffCd = editedBbsIndividualStaffCdList.find((item) => item === staffCd);
          // 個別スタッフコード = "undefined"(該当無)の場合
          if (findStaffCd === undefined) {
            isDiffCheck = "0";
            break;
          }
        }
      }
      // 差分チェックフラグの取得
      return isDiffCheck;
    },
    // add #10359 編集権限の動作不正 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 end
    handleImageChanged(event) {

      if (event && event.hasChanged) {
        this.isChanged = true;


        this.confirmContentChanged();
      }
    },
    /**
     * 画面破棄時ポップアップ初期化
     */
    hideItemPopover() {
      this.popoverPrintTarget = null;
      this.popoverPrintVisible = false;
    },
    /**
     * NOTE:
     *   【概要】治療記録画面にて、破棄確認メッセージ表示有無の返却用関数
     *   【操作】「治療開始」「治療終了」「実績確定」「版確定」
     * @seeTreatmentRecordMainComponent.checkWantContinueEditing()
     */
    getChangeStatus() {
      // 変更有無を返却
      return this.isChanged;
    },
    /**
     * NOTE:
     * alertFlag は「治療記録側で破棄確認がすでに行われたか」を判断するためのフラグで、
     * updateChangeStatus は治療記録経由で観察記録詳細に入った場合だけ、このフラグを
     * 無効化して破棄確認の二重表示を防ぐための関数です。
     * また、「新規登録」で観察記録詳細を開くと UpdateMode が false となり、
     * confirmContentChangedで、「this.isChanged = true;」が設定され、
     * confirmAllowDiscardChanges内の破棄確認へ処理が入り、２重で表示されるため、
     * 更新しています。
     */
    updateChangeStatus() {
      // NOTE: 更新フラグを初期化
      this.alertFlag = false;
      if (!this.getUpdateMode) {
        this.setUpdateMode(true);
      }
    },
  },
};
</script>

<style scoped>
.main-flex-container {
  display: flex;
  flex-direction: column;
  overflow: hidden;
  height: 100%;
}
.submenu-container {
  flex-grow: 1;
  overflow-y: hidden;
  min-width: 342px;
}
.detail-main {
  background-color: #fafafa;
  padding: 0px 30px;
}
.tab-area {
  padding-top: 10px;
  padding-left: 12px;
}
.card-table {
  padding-top: 5px;
  width: 100%;
}
.title {
  padding: 10px;
}
/*add FNSI-改修内容患者イベント患者情報共有より改修 任 start*/
.showName {
  padding-left: 10px;
  margin-left: 1%;
}
/*add FNSI-改修内容患者イベント患者情報共有より改修 任 end*/
.scroll-table {
  overflow-x: hidden;
  overflow-y: auto;
  height: 99%;
  /* margin-left: 10px; */
}
.select {
  vertical-align: middle;
}
.wrap-block {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
}
.nowrap-block {
  display: flex;
  flex-direction: row;
  flex-wrap: nowrap;
}
.btn-area {
  display: flex;
  overflow-x: auto;
  flex-shrink: 0;
  justify-content: space-between;
  left: 8px;
  bottom: 3px;
}
/* del #12107 帳票印刷失敗通知が行われない limingzhe 20251125 start */
/*.select >>> .select-input {*/
/*  opacity: 1;*/
/*  !* font-size: 1.5em; *!*/
/*  !* color: var(--ntss-base-color); *!*/
/*}*/
/* del #12107 帳票印刷失敗通知が行われない limingzhe 20251125 end */
.card-head {
  display: flex;
  flex-direction: row;
}
.card-head-table {
  /*del FNSI-改修内容履歴非表示時にハンバーガーアイコンだけで一行分のエリアを取っているので、カテゴリ選択の横に配置して余白をなくす。 任 start*/
  /*padding-top: 10px;*/
  /*del FNSI-改修内容履歴非表示時にハンバーガーアイコンだけで一行分のエリアを取っているので、カテゴリ選択の横に配置して余白をなくす。 任 end*/
  margin-left: 1%;
}
.registration-btn-area {
  display: flex;
  /*add FNSI-改修内容4717 fan start*/
  white-space: nowrap;
  /*add FNSI-改修内容4717 fan end*/
  align-items: center;
}
/** 子機能開閉ボタン */
.pat-event-openclose-icon {
  font-size: 2em;
  margin-right: 15px;
  margin-left: 10px;
  color: var(--pat-event-text-color);
}
.cancel-btn-area {
  /*mod FNSI- fan 4464  start */
  /* margin-left: 4em;*/
  margin-left: 2em;
  /*mod FNSI- fan 4464  end */
  background-color: var(--denial-btn-area-background-color);
}
@media screen and (max-width: 380px ) {
  .cancel-btn-area {
    margin-left: unset;
  }
}
/* 印刷ボタン吹き出しに関するスタイル */
.report-list-popover >>> .popover--bottom {
  width: 300px;
}
.report-list-popover >>> .popover--bottom__content {
  width: 100%;
}
.report-list-popover >>> .popover__content {
  min-height: 90px;
}
.report-list-popover >>> .registration-btn-area {
    background: none;
    margin-right: initial;
  }
.report-list-popover >>> .printer-selection {
  width: 280px;
  margin-left: 10px;
  margin-top: 10px;
}
.report-list-popover >>> .button-area {
  margin: 10px;
  height: auto;
}
@media print {
  /** 1枚に収まらない事象解消 */
  .submenu-container {
    height: 100%;
  }
  /** テキストエリアのページ跨ぎを可能とする */
  .scroll-table {
    display: inline-block;
  }
  /** テキストエリアは印刷用div表示するので非表示 */
  div >>> .k-editor iframe,
  div >>> .custom-textarea {
    display: none !important;
  }
  /** ボタンエリア非表示（他画面と合わせる） */
  .btn-area {
    display: none !important;
  }
}
</style>
