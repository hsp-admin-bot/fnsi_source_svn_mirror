/** 患者イベント画面 */
<template>
  <div class="main-content-area" style="overflow-y: hidden;">
    <div class="main-flex-container">
      <div class="history-area" v-show="!isHideMainList">
        <div class="header-area">
          <div class="header-icon">
            <ons-icon
              class="ons-icon ion-navicon ons-icon--ion pat-event-openclose-icon"
              icon="ion-ios-menu"
              @click="onCloseMainList()"
            ></ons-icon>
          </div>
          <div class="header-viewer-button">
            <v-ons-button class="button" id="viewer-button" v-show="isPatEvent" @click="onImageViewerClick()">
              <img :src="patEventAsset('viewer.png')" id="viewer-button-icon" />
            </v-ons-button>
          </div>
          <div class="header-button">
            <!-- mod #10359_NG対応 編集権限の動作不正 dengshen start -->
            <!-- <v-ons-button -->
            <!--   class="button btn3-normal" -->
            <!--   @click="editNewPatEventRec()" -->
            <!--   :disabled="!selectedPatId || !hasTreatmentRecordAuthority" -->
            <!--   ref="popoverButton" -->
            <!-- >新規登録</v-ons-button> -->
            <v-ons-button
              class="button btn3-normal"
              @click="editNewPatEventRec()"
              :disabled="!selectedPatId || !this.getItemAuthorized('PatEvent', 'default_authority')"
              ref="popoverButton"
            >新規登録</v-ons-button>
            <!-- mod #10359_NG対応 編集権限の動作不正 dengshen end -->
          </div>
        </div>
        <div class="header-area" id="header-category">
          <common-searcharea :conditionList="conditionList" style="height: 7em; width: 100%; font-size: .667em;" :lineHeight="'7em'" @show-popover='showPopover($event)'/>
        </div>
        <div class="detail-area">
          <table id="history" class="table-area list"  ref="scrollTable">
            <thead>
              <tr>
                <th
                  class="ntss-list-header-th-sticky list-event"
                  scope="col"
                  :style="viewStyles"
                >イベント</th>
                <th class="ntss-list-header-th-sticky list-score" scope="col" v-if="isViewScore">スコア</th>
              </tr>
            </thead>
            <tbody>
                <template v-for="(item, index) in inputModel.history" :key="index">
                  <tr
                   
                    @click="selectHistory(index)"
                    :class="classRowSetting(index, item.activeRow)"
                    v-if="isPatientShared || !item.isOtherFacility"
                  >
                    <td class="ntss-list-body-td ntss-pat-event-label list-event" :style="viewStyles" :class="{ 'other-facility': isPatientShared && item.isOtherFacility }">
                      <label>{{ getHistoryItemDate(item) }}</label>
                      <br />
                      <template v-if="isPatientShared">
                        <label>{{ item.facilityName }}</label>
                        <br />
                      </template>
                      <label>{{ item.categoryName }}</label>
                      <br />
                      <label>{{ item.subCategoryName }}</label>
                      <br />
                      <label>{{ item.sysFacilityName }}</label>
                    </td>
                    <td v-if="isViewScore" class="ntss-list-body-td ntss-pat-event-label list-score" :class="{ 'other-facility': isPatientShared && item.isOtherFacility }">
                      <label>{{ item.scoreTotal }}</label>
                    </td>
                  </tr>
                </template>
              </tbody>
          </table>
        </div>
      </div>
      <div class="content-area">
        <component
          :is="'pat-event-detail'"
          :props-is-main-list="isHideMainList"
          ref="detail"
          @copyLetter="clearActiveRow"
          @detail-created="onDetailCreated"
        />
      </div>
    </div>

    <!-- 検索ポップオーバー -->
    <v-ons-popover
      cancelable
      v-model:visible="popoverVisible"
      :target="popoverTarget"
      :direction="popoverDirection"
      :cover-target="false"
      :class="fontSizeSet"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="handlePopoverPosthide"
    >
      <div style='margin:10px;'>
        <v-ons-row class='condition-row'>
          <v-ons-col width='100%' vertical-align='center'>
            <div class="pat-list flex-1 d-flex">
              <div class="unselected-pat-list flex-1" ref="scrollDiv">
                <div class="list-wrapper ntss-pat-event-label">
                  <div
                    v-for="(item, index) in categorySelection"
                    :class="['pat-display', { selected: item.selected }]"
                    :id="`pat-display${index}`"
                    :key="item.code"
                    @click.exact="singleSelect(index)"
                  >
                    {{ `${item.name}` }}
                  </div>
                </div>
              </div>
            </div>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='30%' vertical-align='center'>
            <!--#10715:日付IF修正StartEnd-->
            <label>表示期間</label>
          </v-ons-col>
          <v-ons-col width='70%' vertical-align='center'>
            <div class="flex-align-center">
              <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 start -->
              <!-- <input type="date" v-model="inputModel.startDate" class="input ntss-input-date start-date" max="9999-12-31" @keyup="showStartMsg" @blur="getStartDate"/> -->
              <date-input v-model="inputModel.startDate" @handleClearInput="inputModel.startDate = null" :classes="'input ntss-input-date start-date'" @keyup="showStartMsg" @blur="getStartDate"/>
             <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 end -->
              <common-calendar v-model="inputModel.startDate" class="start-date-comment"/>
            </div>
            <span class="error-message" v-if="showErrorStartDate">{{ this.msgDiaLog }}</span>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <!--#10715:日付IF修正Start-->
          <v-ons-col width="30%" vertical-align="center">
            <label style="font-size:1.6em;float:right;">～</label>
          </v-ons-col>
          <!--#10715:日付IF修正End-->
          <v-ons-col width='70%' vertical-align='center'>
            <div class="flex-align-center">
              <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 start -->
              <!-- <input type="date" v-model="inputModel.endDate" class="input ntss-input-date end-date" max="9999-12-31" @keyup="showEndMsg" @blur="getEndDate"/> -->
              <date-input  v-model="inputModel.endDate" @handleClearInput="inputModel.endDate = null" :classes="'input ntss-input-date end-date'" @keyup="showEndMsg" @blur="getEndDate"/>
              <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 end -->
              <common-calendar v-model="inputModel.endDate" class="end-date-comment"/>
            </div>
            <span class="error-message" v-if="showErrorEndDate">{{ this.msgDiaLog }}</span>
          </v-ons-col>
        </v-ons-row>
        <div class='condition-row' style="height:30px;margin-bottom:5px;">
          <div style="float:left;">
            <v-ons-button class="clear btn2-cancel" @click="resetCondition">クリア</v-ons-button>
          </div>
          <div style="float:right;">
            <v-ons-button class="ok btn3-normal" :disabled="showErrorEndDate || showErrorStartDate" @click="applyCondition">OK</v-ons-button>
          </div>
        </div>
      </div>
    </v-ons-popover>

    <v-ons-modal :visible="isShowViewerModal" @deviceBackButton="onDeviceBackButton" class="image-viewer-modal">
      <pat-event-image-viewer
        :imageSource="viewTargetImage"
        @cancelViewer="onCancelViewer"
        ref="viewer"
      />
    </v-ons-modal>
  </div>
</template>

<script>
import { publicAssetPath } from "@/compat/assets/public-path";
  import {mapActions, mapGetters} from "@/compat/vue/vuex";
  import {EventBus} from "@/compat/vue/event-bus.js";
  import NextTransitionMixin from "@/components/NextTransitionMixin";
  import PatHeaderControlMixin from "@/components/common/PatHeadControlMixin";
  import dayjs from "@/compat/date/dayjs";
  import PatEventDetail from "@/components/pat-event/PatEventDetailComponent";
  import PatEventImageViewer from "@/components/pat-event/image-viewer/PatEventImageViewer";
  // mod #10359_NG対応 編集権限の動作不正 dengshen start
  // import {deepCopy} from "@/functions/common/CommonFunctions";
  import { deepCopy, getAuthorized } from "@/functions/common/CommonFunctions";
  // mod #10359_NG対応 編集権限の動作不正 dengshen end
  import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
  import {getCurrentFunctionCd} from "@/router/routing-helper";
  import {ADVANCED_SETTINGS} from "@/constants/advancedSettings";
  import {PAT_EVENT, PAT_INTRO_LETTER} from "@/constants/defaultSettingConstants";
  import {calcTargetDate, DATE_FORMAT as SETTING_DATE_FORMAT} from "@/functions/modals/default-setting/defaultSettingUtils"
  /*add FNSI-改修内容患者イベント患者情報共有より改修 任 start*/
  import {ApiHelper} from "../../apis/AxiosHelper";
  import PopoverMixin from "@/components/PopoverMixin";
  import commonSearchArea from "@/components/common/CommonSearchArea";
  /*add FNSI-改修内容患者イベント患者情報共有より改修 任 end*/
  import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
  /*add FNSI-改修内容権限関連 任 start*/
  import {AUTHORITY_CODES} from "@/constants/userAuthority";
  import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
  /*add FNSI-改修内容権限関連 任 end*/
  //add オンプレミスの場合、転入患者さんの紹介状が取込できない 吉 start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";

import { getScopedElementsByClassName } from "@/functions/common/LayoutMeasureHelper";
  //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
  import {popoverPosthide, popoverPostShow, popoverPreShow} from "@/functions/common/CommonPopoverFunctions";
  //#5590 2023/04/19 ×を常に表示するように修正 張博 start
  import DateInput from "@/components/common/DateInput.vue";
import axios from "@/compat/http/axios";
  //#5590 2023/04/19 ×を常に表示するように修正 張博 end

  const AnyCategoryCd = "0";
  const AnySubCategoryCd = "0";
  const CategoryCdDelimiter = "-";
  const joinCategoryCd = (subCategoryCd, categoryCd) => `${subCategoryCd}${CategoryCdDelimiter}${categoryCd}`;
  const joinCategoryName = (categoryName, subCategoryName) => `${categoryName} ＞ ${subCategoryName}`;
  const AllCategoryCd = joinCategoryCd(AnySubCategoryCd, AnyCategoryCd);
  const AllCategoryTemplete = {
    code: AllCategoryCd,
    name: "全カテゴリ"
  };

  const toDate = (dateString) => dayjs(dateString).toDate();
  const formatToSettingDate = (dateInfo) => dayjs(dateInfo).format(SETTING_DATE_FORMAT);
  const formatToInputDate = (dateInfo) => dayjs(dateInfo).format("YYYY-MM-DD");
  const formatToDisplayDate = (dateInfo) => dayjs(dateInfo).format("YYYY/MM/DD")

  const nomalizeNullableString = (value) => value !== null ? value : "";

  const copyCondition = (from, to) => {
    to.relationCategoryCd.length = 0;
    to.relationCategoryCd.push(...from.relationCategoryCd);
    to.startDate = from.startDate;
    to.endDate = from.endDate;
  };

  export default {

  components: {
    "common-calendar": commonCalender,
    "pat-event-detail": PatEventDetail,
    "pat-event-image-viewer": PatEventImageViewer,
    "common-searcharea": commonSearchArea,
    //#5590 2023/04/19 ×を常に表示するように修正 張博 start
    "date-input":DateInput,
    //#5590 2023/04/19 ×を常に表示するように修正 張博 end
  },
  /*mod FNSI-改修内容権限関連 任 start*/
  /*mixins: [NextTransitionMixin, PatHeaderControlMixin],*/
  mixins: [NextTransitionMixin, PatHeaderControlMixin,ComponentGuardMixin,PopoverMixin],
  /*mod FNSI-改修内容権限関連 任 end*/
  data() {
    return {
      inputModel: {
        relationCategoryCd: [],
        startDate: null,
        endDate: null,
        history: []
      },
      // ポップオーバー編集中データを破棄する為の一時データ
      tmpInputData: {
        relationCategoryCd: [],
        startDate: null,
        endDate: null,
        valid: false
      },
      categorySelection: [],
      msgDiaLog: DIALOG_MESSAGES["99999995"].message,
      showErrorStartDate: false,
      showErrorEndDate: false,
      patEventInfo: {
        patEventCd: 0,
        patId: 0,
        facilityCd: null,
        fnCtlNo: 0,
        eventStatus: null,
        templateCd: 0,
        templateName: null,
        categoryCd: 0,
        categoryName: null,
        useType: 0,
        ordNo: 0,
        inputParams: null,
        eventStartDate: null,
        eventEndDate: null,
        subCategoryCd: 0,
        subCategoryName: null,
        resultParams: null,
        scoreTotal: null,
        regStaffInfo: null,
        upStaffInfo: null,
        letterInfo: null,
        bbsCtlNo: null,
        isNewest: null,
        isDel: null,
        regDate: null,
        upDate: null
      },
      //自画面の名称
      selfScreenName: "",
      beforeSelectPatId: null,
      //切替え処理中有無
      processing: false,
      /*add FNSI-改修内容患者を切り替え時、キャンセルして編集した内容を保持していない、任 start*/
      isGoOn: true,
      /*add FNSI-改修内容患者を切り替え時、キャンセルして編集した内容を保持していない、任 end*/
      //選択行
      rowSelect: 0,
      isShowViewerModal: false,
      viewTargetImage: null,
      /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
      isPatientShared: false,
      oldLetterInfo: {},
      oldReportDate: null,
      /*add FNSI-改修内容538 連携イベントの登録適正化 任 start*/
      oldOrdNo: 0,
      /*add FNSI-改修内容538 連携イベントの登録適正化 任 end*/
      /*add FNSI-改修内容転入転出の患者情報連動 任 end*/
      /*add FNSI-改修内容患者切り替える時の表示不正 任 start*/
      tempPatId: null,
      /*add FNSI-改修内容患者切り替える時の表示不正 任 end*/
      isHideMainList: false,
      /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start*/
      isRouteCreateFlg: false,
      /*add FNSI-改修内容権限関連 任 start*/
      // del #10359_NG対応 編集権限の動作不正 dengshen start
      // hasTreatmentRecordAuthority: false,
      // del #10359_NG対応 編集権限の動作不正 dengshen end
      authorityCds: [
        AUTHORITY_CODES.PAT_EVENT_PEDIT,
        AUTHORITY_CODES.PAT_EVENT_EDIT
      ],
      /*add FNSI-改修内容権限関連 任 end*/
      isRouteGamenFlg: false
      /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end*/
      //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 start
      ,scrollTable:null
      ,scrollDiv:null
      ,scrollDivNameForPosition:null,
      //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 end
      // 検索ポップオーバー
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      // 共通検索エリア部品に表示するデータのリスト
      /* del by chamaojia 2025-05-21 [11871]  --start */
      /*add FNSI-改修内容患者イベント外结No.7 任 start*/
      // facilityNameList: null,
      /*add FNSI-改修内容患者イベント外结No.7 任 end*/
      /* del by chamaojia 2025-05-21 [11871]  --end */
      conditionList: [],
      mstCategoryRecords: [],
      mstSubCategoryRecords: [],
      /* add by chamaojia 2025-05-21 [11871]  --start */
      // インタフェースリターンオブジェクト
      respObj: null,
      /* add by chamaojia 2025-05-21 [11871]  --end */
      // 患者カレンダーから新規登録で遷移したかのフラグ
      isCreateNew: false
    };
  },
  computed: {
    ...mapGetters("user", {
      facilityCd: "getFacilityCd",
      dispUserId: "getDispUserId",
      advancedSettings: "getAdvancedSettings"
    }),
    ...mapGetters("account-edit", [
      "getUserId",
      "getStateUserAccountInfo",
      "getDefaultSetting",
      "getPatientShareMode",
      "getPatientShareFacilityCdMode"
    ]),
    ...mapGetters("pat-info", ["selectedPatId", "selectedPatName"]),
    ...mapGetters("pat-event/list", [
      "getPatEventRecords",
      "getPatEventRecord",
      "getMstTemplateRecords",
      "getMstCategoryRecords",
      "getMstSubCategoryRecords",
      "getConditionDate",
      "getSystemDefaultConditionDate",
      "getSelectInfo",
      "getIsEdit",
      "getUpdateMode",
      /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start*/
      "getTreatBaseDate",
      /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end*/
      "getIsOtherFacility",
    ]),
    ...mapGetters("pat-event/detail", {
      patEventRecord: "getPatEventRecord"
    }),
    /*mod FNSI-改修内容転入時の紹介状取込ができない 任 start*/
    /*...mapGetters("introduction-letter", ["getReportCd"]),*/
    ...mapGetters("introduction-letter", ["getReportCd","getPathReal"]),
    /*add FNSI-改修内容比較中の画像について、編集しても、最新の画像で適用されない 任 start*/
    ...mapGetters("pat-event/viewer", ["getCompareViewImgs"]),
    /*add FNSI-改修内容比較中の画像について、編集しても、最新の画像で適用されない 任 end*/
    /*mod FNSI-改修内容転入時の紹介状取込ができない 任 end*/
    /* del by chamaojia 2025-05-21 [11871]  --start */
    /*...mapGetters("sys-facility", ["getSysFacilitiesForName"]),*/
    /* del by chamaojia 2025-05-21 [11871]  --end */
    isPatEvent() {
      return this.selfScreenName === "pat-event";
    },
    isPatIntroLetter() {
      return this.selfScreenName === "pat-intro-letter";
    },
    defaultSetting() {
      const result = {};
      const settingInfo = {};
      if (this.isPatEvent) {
        settingInfo.settings = this.getDefaultSetting[PAT_EVENT.KEY_NAME];
        settingInfo.keyMap = {
          relationCategoryCd: PAT_EVENT.KEY_NAME_RELATION_CATEGORY_CD,
          startDate: PAT_EVENT.KEY_NAME_START_DATE,
          endDate: PAT_EVENT.KEY_NAME_END_DATE,
        };
      } else if (this.isPatIntroLetter) {
        settingInfo.settings = this.getDefaultSetting[PAT_INTRO_LETTER.KEY_NAME];
        settingInfo.keyMap = {
          relationCategoryCd: PAT_INTRO_LETTER.KEY_NAME_RELATION_CATEGORY_CD,
          startDate: PAT_INTRO_LETTER.KEY_NAME_START_DATE,
          endDate: PAT_INTRO_LETTER.KEY_NAME_END_DATE,
        };
      }
      if (settingInfo.settings && settingInfo.keyMap) {
        const normalizeCategoryCd = (value) => (value != null) ? [value] : null;
		const categoryData = settingInfo.settings[settingInfo.keyMap.relationCategoryCd];
		if(categoryData){
		  const subCategoryCd = categoryData.substring(0,categoryData.indexOf("-"));
		  const categoryCd = categoryData.substring(categoryData.indexOf("-") + 1);
		  let categoryExistFlg = true;
		  let subCategoryExistFlg = true;
		  if(categoryCd !== AnyCategoryCd){
		    categoryExistFlg = (this.mstCategoryRecords.filter(rec => rec.categoryCd == categoryCd).length > 0) ? true:false;
		  }
		  if(subCategoryCd !== AnySubCategoryCd){
			subCategoryExistFlg = (this.mstSubCategoryRecords.filter(rec => rec.subCategoryCd == subCategoryCd).length > 0) ? true:false;
		  }
		  if(categoryCd !== AnyCategoryCd && subCategoryCd === AnySubCategoryCd){
			subCategoryExistFlg = (this.mstSubCategoryRecords.filter(rec => rec.categoryCd == categoryCd).length > 0) ? true:false;
		  }
		  if(categoryExistFlg && subCategoryExistFlg){
			result.relationCategoryCd = normalizeCategoryCd(settingInfo.settings[settingInfo.keyMap.relationCategoryCd]);
          }
        }
		const normalizeDate = (value) => (value != null) ? calcTargetDate(value) : null;
        result.startDate = normalizeDate(settingInfo.settings[settingInfo.keyMap.startDate]);
        result.endDate = normalizeDate(settingInfo.settings[settingInfo.keyMap.endDate]);
      }
      if (!result.startDate && !result.endDate) {
        // 日付範囲について個人設定のデフォルト設定がない場合
        result.startDate = formatToSettingDate(this.getSystemDefaultConditionDate.startDate);
        result.endDate = formatToSettingDate(this.getSystemDefaultConditionDate.endDate);
      }
      if (!result.relationCategoryCd || result.relationCategoryCd.length === 0) {
        // カテゴリについて個人設定のデフォルト設定がない場合
        result.relationCategoryCd = [AllCategoryCd];
      }
      return result;
    },
    selectInfo() {
      return (
        this.isPatEvent ? this.getSelectInfo.patEvent
        : this.isPatIntroLetter ? this.getSelectInfo.patIntroLetter
        : {}
      );
    },
    isEdit() {
      return this.getIsEdit;
    },
    selectTemplates() {
      const dataTable = [AllCategoryTemplete];
      let subCategories = deepCopy(this.mstSubCategoryRecords);
      const categories = this.mstCategoryRecords;
	  subCategories = this.sortDispData(categories,subCategories);
      let category = null;
      for (const subCategory of subCategories) {
        if (
          category === null ||
          category.categoryCd !== subCategory.categoryCd
        ) {
          category = categories.find(item => {
            return item.categoryCd === subCategory.categoryCd;
          });
          dataTable.push({
            code: joinCategoryCd(AnySubCategoryCd, category.categoryCd),
            name: category.categoryName,
          });
        }
        dataTable.push({
          code: joinCategoryCd(subCategory.subCategoryCd, category.categoryCd),
          name: joinCategoryName(category.categoryName, subCategory.subCategoryName),
        });
      }
      return dataTable;
    },
    isViewScore() {
      // #9551 紹介状リストにスコア欄は不要 start
      if (this.$route.name !== 'pat-intro-letter') {
        return this.advancedSettings.func_advcds.some(
          setting => setting.func_advcd === ADVANCED_SETTINGS.PATEVENT_SCORE_CALC
        );
      } else {
        return false;
      }
      // #9551 紹介状リストにスコア欄は不要 end
    },
    viewStyles() {
      if (!this.isViewScore) {
        return { width: "20%" };
      }
      return { width: "100%" };
    },
  },
  methods: {
    patEventAsset(fileName) {
      return publicAssetPath(`img/pat-event/${fileName}`);
    },
    getScopedClassElementSafe(className) {
      return getScopedElementsByClassName(className, this.$el || null)[0] || null;
    },
    getHistoryItemDate({ useType, eventStartDate, reportDate }) {
      return useType == 3 && reportDate != null && reportDate != "Invalid date" ? reportDate : eventStartDate;
    },
    ...mapActions("observe-record/list", [
      "setEditingOrdNo",
      "resetIsOtherFacilitys",
    ]),
    ...mapActions("patient", {
      getPatient: "getPatient"
    }),
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "setLoadingScreenMessage",
    ]),
    ...mapActions("pat-event/list", [
      "fetchPatEventRecords",
      "fetchPatEventMaster",
      "setMstSubCategoryRecords",
      "findPatEventByCd",
      "setConditionDate",
      "setUpdateMode",
      /*add FNSI-改修内容転入時の紹介状取込ができない 任 start*/
      "setShowUpload",
      "setDisplayTwo",
      /*add FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 start*/
      "setSubCategoryCd",
      /*add FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 end*/
      "setIsOtherFacility",
      /*add FNSI-改修内容転入時の紹介状取込ができない 任 end*/
      "setIsEdit",
      "setSelectInfo",
      // add FNSI-コントロールの削除 徐 start
      "setPatEventFlg",
      // add FNSI-コントロールの削除 徐 end
      "setEventStartDate",
      "resetIsOtherFacility"
    ]),
    ...mapActions("pat-event/detail", [
      "setPatEventRecord",
      "setInitPatEventRecord",
      "setViewMode",
      /*add FNSI-改修内容患者イベント患者情報共有より改修 任 start*/
      "setFacilityName",
      /*add FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 start*/
      "setTemplateShow",
      /*add FNSI-改修内容添付ファイル修正 任 start*/
      "setShowFile",
      /*add FNSI-改修内容添付ファイル修正 任 end*/
      /*add FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 end*/
      /*add FNSI-改修内容患者イベント患者情報共有より改修 任 end*/
      "setIsMainList"
    ]),
    ...mapActions("introduction-letter", [
      "setReportCd",
      "setTemplate",
      /*add FNSI-改修内容転入時の紹介状取込ができない 任 start*/
      "setPath",
      /*add FNSI-改修内容新規ボタン押下した、登録ボタン非活性する、前回履歴をクリアする。 任 start*/
      "setIsGoNext",
      /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
      "setIsUpdateLetter",
      /*add FNSI-改修内容転入転出の患者情報連動 任 end*/
      /*add FNSI-改修内容新規ボタン押下した、登録ボタン非活性する、前回履歴をクリアする。 任 end*/
      /*add FNSI-改修内容転入時の紹介状取込ができない 任 end*/
      "clearState"
    ]),
    ...mapActions("pat-event/viewer", ["clearCompareViewImgs"]),
    ...mapActions("pat-event/image-editor", ["initStampTextInfo"]),
    // Windowの高さからGirdコンポーネント領域の高さを算出
    /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
    ...mapActions("pat-info",["setReportStartDate"]),
    /*add FNSI-改修内容転入転出の患者情報連動 任 end*/
    ...mapGetters("app", ["getQueryParameters"]),
    ...mapActions("app", ["setQueryParameters"]),
    /* del by chamaojia 2025-05-21 [11871]  --start */
    /*...mapActions("sys-facility", ["loadSysFacility"]),*/
    /* del by chamaojia 2025-05-21 [11871]  --end */
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    // add #10359_NG対応 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359_NG対応 編集権限の動作不正 dengshen end
    setConditionDateByValues(startDate, endDate) {
      this.setConditionDate({
        startDate,
        endDate,
      });
    },
    updateInputModelDate() {
      // 無効な日付判定
      const isInvalidDate = (date) => Number.isNaN(date.getTime());

      this.inputModel.startDate = isInvalidDate(this.getConditionDate.startDate) ? null : formatToInputDate(this.getConditionDate.startDate);
      this.inputModel.endDate = isInvalidDate(this.getConditionDate.endDate) ? null : formatToInputDate(this.getConditionDate.endDate);
    },
    initCondition() {
      if ("letter" === this.$route.params.parentName) {
        // 患者経過総合ビューアで紹介状に遷移した場合
        // 患者経過総合ビューア側で日付条件をsetConditionDateしてあるので
        // デフォルト設定などの反映は行わない
        // カテゴリ条件は「全カテゴリ」を選択する
        this.inputModel.relationCategoryCd.length = 0;
        this.inputModel.relationCategoryCd.push(AllCategoryCd);
      } else {
        // 患者経過総合ビューアで紹介状に遷移した場合以外
        // 以前に退避した検索条件、もしくはデフォルト設定の検索条件を設定する
        // 表示期間はnullの場合もあるため、カテゴリ条件の有無で退避された検索条件を使うかを判定する
        const selectInitialValue = (savedValue, defaultValue, savedFlg) => (savedFlg ? toDate(savedValue) : defaultValue != null ? toDate(defaultValue) : null);
        this.setConditionDateByValues(
          selectInitialValue(this.selectInfo.startDate, this.defaultSetting.startDate, this.selectInfo.relationCategoryCd.length > 0),
          selectInitialValue(this.selectInfo.endDate, this.defaultSetting.endDate, this.selectInfo.relationCategoryCd.length > 0)
        );

        this.inputModel.relationCategoryCd.length = 0;
        this.inputModel.relationCategoryCd.push(...(
          this.selectInfo.relationCategoryCd.length > 0
          ? this.selectInfo.relationCategoryCd
          : this.defaultSetting.relationCategoryCd
        ));
      }

      if (!(this.getConditionDate.startDate && this.getConditionDate.endDate)) {
        this.setConditionDateByValues(null, null);
      }

      // 画面遷移パラメータ取得
      const queryParameters = this.getQueryParameters();
      // 開始日/終了日のパラメータがあれば指定
      const updatedDate = (dateString, currentDate) => {
        if (dateString) {
          const dateMoment = dayjs(dateString);
          if (dateMoment.isValid()) {
            return dateMoment.toDate();
          }
        }
        return currentDate;
      };
      this.setConditionDateByValues(
        updatedDate(queryParameters.eventStartDate, this.getConditionDate.startDate),
        updatedDate(queryParameters.eventEndDate, this.getConditionDate.endDate),
      );

      if (this.$route.params.condition) {
        if (this.$route.params.condition.patEventCd) {
          // 患者イベント画面以外で予実リストの患者イベントを選択して遷移してきた場合
          // #9329対応時の仕様メモ：
          // 選択したデータの開始日を表示条件の開始日終了日に設定し　カテゴリは全カテゴリにする。
          const eventStartDate = toDate(this.$route.params.condition.eventStartDate);
          this.setConditionDateByValues(eventStartDate, eventStartDate);
          this.inputModel.relationCategoryCd.length = 0;
          this.isRouteCreateFlg = true;
        } else if (this.$route.params.condition.categoryCd) {
          // 患者経過総合ビューアからカテゴリをクリックして遷移してきた場合
          // もしくは患者カレンダーから患者イベント（もしくはカテゴリ）をクリックして遷移してきた場合
          this.setConditionDateByValues(
            toDate(this.$route.params.condition.eventStartDate),
            toDate(this.$route.params.condition.eventEndDate)
          );
          // サブカテゴリコードがパラメータに設定されている場合は抽出条件に設定
          const subCategoryCd = this.$route.params.condition.subCategoryCd ? this.$route.params.condition.subCategoryCd : AnySubCategoryCd;
          this.inputModel.relationCategoryCd.length = 0;
          this.selectTemplates.forEach(template => {
            if (template.code === joinCategoryCd(subCategoryCd, this.$route.params.condition.categoryCd)) {
              this.inputModel.relationCategoryCd.push(template.code);
            }
          });
        } else if (this.$route.params.condition.eventStartDate) {
          // 患者カレンダーから新規作成で遷移してきた場合
          this.setConditionDateByValues(
            toDate(this.$route.params.condition.eventStartDate),
            toDate(this.$route.params.condition.eventEndDate)
          );

          // カテゴリ条件は「全カテゴリ」を選択する
          this.inputModel.relationCategoryCd.length = 0;
          this.inputModel.relationCategoryCd.push(AllCategoryCd);
          
          // storeにパラメータ指定のイベント開始日を設定 ※"YYYY-MM-DD"形式
          this.setEventStartDate(this.$route.params.condition.eventStartDate);
        }
        if (
          !this.isRouteCreateFlg
          && this.$route.params.condition.type === "pat_event"
          && !this.$route.params.condition.isRouteCreateFlg
        ) {
          // 患者経過総合ビューアから遷移してきた場合
          const treatDateObject = toDate(this.$route.params.condition.treatDate);
          this.setConditionDateByValues(treatDateObject, treatDateObject);
        }
      }

      if (this.$route.params.startDate !== undefined) {
        // 掲示板から患者イベントに遷移した場合
        if (this.$route.params.startDate != null) {
          const startDateMoment = dayjs(this.$route.params.startDate);
          const startDate = startDateMoment.toDate();
          this.setConditionDateByValues(
            startDate,
            (this.$route.params.endDate != null)
              ? toDate(this.$route.params.endDate)
              : startDateMoment.add(7, "days").toDate()
          );
        } else if (this.$route.params.endDate === null) {
          const todayMoment = dayjs();
          const endDate = todayMoment.toDate();
          this.setConditionDateByValues(
            todayMoment.subtract(7, "days").toDate(),
            endDate
          );
        }
        // カテゴリ条件は「全カテゴリ」を選択する
        this.inputModel.relationCategoryCd.length = 0;
        this.inputModel.relationCategoryCd.push(AllCategoryCd);
      }

      if (this.inputModel.relationCategoryCd.length === 0) {
        this.inputModel.relationCategoryCd.push(AllCategoryCd);
      }
      this.updateInputModelDate();

      this.setConditionList();
      this.storeSelectInfo();
    },
    singleSelect(index) {
      const targetCategorySelection = this.categorySelection[index];
      if (targetCategorySelection.selected) {
        // 選択解除する場合
        targetCategorySelection.selected = false;
        if (!this.categorySelection.some(aCategorySelection => aCategorySelection.selected)) {
          // 何も選択されていない状態になったら「全カテゴリ」を選択する
          this.categorySelection[0].selected = true;
        }
      } else {
        // 選択する場合
        const unselectCondition = (index === 0) ? aCategorySelection => (
          // 「全カテゴリ」を選択した場合は「全カテゴリ」以外の項目の選択を解除する
          aCategorySelection.categoryCd !== AnyCategoryCd
          || aCategorySelection.subCategoryCd !== AnySubCategoryCd
        ) : (targetCategorySelection.subCategoryCd === AnySubCategoryCd) ? aCategorySelection => (
          // サブカテゴリでない項目を選択した場合はそれが含むサブカテゴリと「全カテゴリ」の選択を解除する
          aCategorySelection.categoryCd === AnyCategoryCd
          || (
            aCategorySelection.categoryCd === targetCategorySelection.categoryCd
            && aCategorySelection.subCategoryCd !== AnySubCategoryCd
          )
        ) : aCategorySelection => (
          // サブカテゴリ項目を選択した場合はそれを含むサブカテゴリでない項目の選択を解除する
          aCategorySelection.categoryCd === AnyCategoryCd
          || (
            aCategorySelection.categoryCd === targetCategorySelection.categoryCd
            && aCategorySelection.subCategoryCd === AnySubCategoryCd
          )
        );
        this.categorySelection.forEach(aCategorySelection => {
          if (
            aCategorySelection.selected
            && unselectCondition(aCategorySelection)
          ) {
            aCategorySelection.selected = false;
          }
        });
        targetCategorySelection.selected = true;
      }
    },
    /**
     * 新規登録ボタンクリック時の処理
     */
    async editNewPatEventRec() {
      await this.resetIsOtherFacility();
      await this.resetIsOtherFacilitys();
      if (await this.confirmAllowDiscardChanges()) {
        this.editPatEventRec();
      }
      // storeのイベント開始日クリア
      this.setEventStartDate(null);
    },
    clearActiveRow() {
      for (const history of this.inputModel.history) {
        history.activeRow = false;
      }
    },
    /**
     * 指定された患者情報データを詳細ストアが取得、詳細画面を開く
     */
    async editPatEventRec() {
      this.clearActiveRow();
      this.goNext();
    },
    /**
     * 詳細ページの遷移（新規と修正）
     */
    async goNext() {
      /*add FNSI-改修内容新規ボタン押下した、登録ボタン非活性する、前回履歴をクリアする。 任 start*/
      this.setIsGoNext(true);
      /*add FNSI-改修内容新規ボタン押下した、登録ボタン非活性する、前回履歴をクリアする。 任 end*/
      /*add FNSI-改修内容転入時の紹介状取込ができない 任 start*/
      this.setShowUpload(true);
      /*add FNSI-改修内容転入時の紹介状取込ができない 任 end*/
      this.setUpdateMode(false);
      /*add FNSI-改修内容添付ファイル修正 任 start*/
      this.setShowFile(true);
      /*add FNSI-改修内容添付ファイル修正 任 end*/
      /*add FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 start*/
      this.setTemplateShow(false)
      /*add FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 end*/
      /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
      this.setIsUpdateLetter(false);
      /*add FNSI-改修内容転入転出の患者情報連動 任 end*/
      // 患者イベントデータを新規作成
      this.setPatEventInfo(null);
      await this.setPatEventRecord(this.patEventInfo);
      // Mixinで定義したメソッドで次画面へ遷移
      this.setIsEdit(false);
      this.setViewMode(false);
      
      // 新規登録ボタン押下時は詳細画面のカテゴリ選択処理を実行
      if (!this.isCreateNew) {
        this.$refs.detail.setSubCategoryClear();
      }
    },
    // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start
    async checkHasUnsavedChanges() {
      const detailComponent = this.$refs.detail;
      if (!detailComponent) {
        return false;
      }
      if (typeof detailComponent.handleClickCancelCheckOnly === 'function') {
        return await detailComponent.handleClickCancelCheckOnly();
      }
      return false;
    },
    // add #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end
    /**
     * 患者カレンダー＞新規登録ボタン押下からの機能遷移時は、詳細画面のcreated完了後にカテゴリ選択処理を実行
     */
    onDetailCreated() {
      if (this.isCreateNew) {
        this.$refs.detail.setSubCategoryClear();
        // 新規登録フラグをクリア
        this.isCreateNew = false;
      }
    },
    /**
     * リスト一覧からのクリック選択処理
     */
    async selectHistory(index) {
      // #8609 患者イベント画面にて、exe形式がアップロードされてしまう 訾浩 start
      //del #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc start
      // EventBus.$emit('selectHistory')
      //del #9364 患者イベントに関連する4つの画面のコード調整 20230831 ztc end
      // #8609 患者イベント画面にて、exe形式がアップロードされてしまう 訾浩 end
      await this.resetIsOtherFacility();
      await this.resetIsOtherFacilitys();
      // mod #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 start
      const hasUnsavedChanges = await this.checkHasUnsavedChanges();
      if (hasUnsavedChanges) {
        if (await this.confirmAllowDiscardChanges()) {
          this.selectEvent(index);
        }
      } else {
        this.selectEvent(index);
      }
      // mod #12402 紹介状の編集で画像の追加や差し替えができない wangchao 20260422 end
    },
    async selectEvent(index) {
      // add IES_6668 【ST試験】【S 09 _フットケアセット】患者イベント：切替ページ表示不正 zhou  start
      this.setLoadingScreenVisible(true);
      // add #12370 紹介状の転入の動作不正 zkm start
      this.clearState();
      // add #12370 紹介状の転入の動作不正 zkm end
      // add IES_6668 【ST試験】【S 09 _フットケアセット】患者イベント：切替ページ表示不正 zhou  end
      for (let i = 0; i < this.inputModel.history.length; i++) {
        if (i !== index) {
          this.inputModel.history[i].activeRow = false;
        } else {
          this.inputModel.history[i].activeRow = true;
        }
      }
      /*add FNSI-改修内容転入時の紹介状取込ができない 任 start*/
      //mod オンプレミスの場合、転入患者さんの紹介状が取込できない 吉 start
      // await this.setPath(this.inputModel.history[index].reportUrl);
      var formData = new FormData();
      if(this.inputModel.history[index].reportUrl !==null&&this.inputModel.history[index].reportUrl!==""){
        formData.append("pdfUrl", this.inputModel.history[index].reportUrl);
        this.showPdf(formData);
        /*add FNSI-改修内容绍介状bug修正 任 start*/
      }else{
        this.setPath(null);
        /*add FNSI-改修内容绍介状bug修正 任 end*/
      }
      //mod オンプレミスの場合、転入患者さんの紹介状が取込できない 吉 end
      /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
      this.oldLetterInfo = this.inputModel.history[index].letterInfo;
      this.oldReportDate = this.inputModel.history[index].reportDate;
      /*add FNSI-改修内容538 連携イベントの登録適正化 任 start*/
      this.oldOrdNo = this.inputModel.history[index].ordNo;
      /*add FNSI-改修内容538 連携イベントの登録適正化 任 end*/
      this.setReportStartDate(this.inputModel.history[index].reportDate);
      /*add FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 start*/
      this.setSubCategoryCd(this.inputModel.history[index].subCategoryCd);
      /*add FNSI-改修内容マスタ画面の修正に伴い、紐付ける帳票を一括印刷するように修正 任 end*/
      /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
      if(JSON.parse(this.oldLetterInfo)!==null){
        this.setIsUpdateLetter(JSON.parse(this.oldLetterInfo).isUpdateLetter);
      }
      /*add FNSI-改修内容転入転出の患者情報連動 任 end*/
      /*add FNSI-改修内容転入転出の患者情報連動 任 end*/
      /*add FNSI-改修内容転入時の紹介状取込ができない 任 end*/
      // 選択行のセーブ
      /*add FNSI-改修内容患者イベント患者情報共有より改修 任 start*/
      this.setFacilityName(this.inputModel.history[index].facilityName);
      /*add FNSI-改修内容患者イベント患者情報共有より改修 任 end*/
      this.rowSelect = index;
      //詳細のコンポーネントをクリアするために一旦セットします。
      this.setIsOtherFacility(this.inputModel.history[index].isOtherFacility);
      this.setPatEventInfo(null);
      await this.setPatEventRecord(this.patEventInfo);
      //修正モード設定
      /*add FNSI-改修内容転入時の紹介状取込ができない 任 start*/
      this.setShowUpload(false);
      this.setDisplayTwo(false);
      /*add FNSI-改修内容新規ボタン押下した、登録ボタン非活性する、前回履歴をクリアする。 任 start*/
      this.setIsGoNext(false);
      /*add FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 start*/
      this.setTemplateShow(false);
      /*add FNSI-改修内容編集モードでテンプレート更新を操作して最新マスタのテンプレートを再取得して編集を可能とする。 任 end*/
      /*add FNSI-改修内容新規ボタン押下した、登録ボタン非活性する、前回履歴をクリアする。 任 end*/
      /*add FNSI-改修内容転入時の紹介状取込ができない 任 end*/
      this.setUpdateMode(true);
      let selectedPatEvent = null;
      const info = [];
      info.push({
        patEventCd: this.inputModel.history[index].patEventCd,
        selectedPatId: this.selectedPatId
      });
      await this.findPatEventByCd(info);
      selectedPatEvent = this.getPatEventRecord[0];
      // 紹介状テンプレートをレンダーします
      if (selectedPatEvent && selectedPatEvent.useType === 3) {
        const letterInfo =
          selectedPatEvent.letterInfo &&
          JSON.parse(selectedPatEvent.letterInfo);
        if (letterInfo.report_cd) {
          // mod FNSI-改修内容紹介状レポート選択画面削除 任 start
          /*await this.setTemplate({
            patId: this.selectedPatId,
            reportCd: letterInfo.report_cd
          });
        }*/
          selectedPatEvent.reportCd =letterInfo.report_cd
          /*mod FNSI-改修内容転入時の紹介状取込ができない 任 start*/
          /*await this.setTemplate({
            patId: this.selectedPatId,
            reportCd: letterInfo.report_cd
          });*/
          if(this.getPathReal !== null){
            await this.setReportCd(letterInfo.report_cd)
          }else{
            await this.setTemplate({
              patId: this.selectedPatId,
              reportCd: letterInfo.report_cd,
              // add 11488 紹介状登録内容保存時に帳票の版も記憶する　1.1A  吉 start
              ctlNo:letterInfo.ctlNo
              // add 11488 紹介状登録内容保存時に帳票の版も記憶する　1.1A  吉 end
            });
          }
          /*mod FNSI-改修内容転入時の紹介状取込ができない 任 end*/
        }else{
          selectedPatEvent.reportCd = 0
        }
      }else{
        selectedPatEvent.reportCd = 0
        // mod FNSI-改修内容紹介状レポート選択画面削除 任 end
      }
      /*add FNSI-改修内容「1回限り」、「毎日」、「毎週」、「毎月」、終了時刻項目を削除 任 start*/
      if(selectedPatEvent && selectedPatEvent.useType === 2){
        this.setPatEventFlg(true);
      }else{
        this.setPatEventFlg(false);
      }
      /*add FNSI-改修内容「1回限り」、「毎日」、「毎週」、「毎月」、終了時刻項目を削除 任 end*/
      await this.setPatEventRecord(selectedPatEvent);
      // Mixinで定義したメソッドで次画面へ遷移
      this.setViewMode(true);
      this.setIsEdit(false);
      /*add FNSI-改修内容添付ファイル修正 任 start*/
      this.setShowFile(false);
      /*add FNSI-改修内容添付ファイル修正 任 end*/
      this.setInitPatEventRecord(deepCopy(this.patEventRecord));
      // add IES_6668 【ST試験】【S 09 _フットケアセット】患者イベント：切替ページ表示不正 zhou  start
      this.setLoadingScreenVisible(false);
      // add IES_6668 【ST試験】【S 09 _フットケアセット】患者イベント：切替ページ表示不正 zhou  end
    },
    //add オンプレミスの場合、転入患者さんの紹介状が取込できない 吉 start
    showPdf (data) {
      axios({
        method: 'post',
        url: '/ntss-admin-web/api/report/getPdf',
        headers: {
          'Content-Type': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        },
        data:data,
        responseType: 'blob'
      }).then(response => {
        var src  = this.getObjectURL(response.data);
        this.setPath(src);
      }).catch(function (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('PatEventMainComponent.vue', 'showPdf', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end

      });
    },
    getObjectURL(file) {
      const ownerWindow = this.$el?.ownerDocument?.defaultView || window;
      let url = null
      if (ownerWindow.createObjectURL !== undefined) {
        url = ownerWindow.createObjectURL(file)
      } else if (ownerWindow.webkitURL !== undefined) {
        try {
          var blob = new Blob([file], {
            type: 'application/png;charset=utf-8',
          });
          url = ownerWindow.webkitURL.createObjectURL(blob)
        } catch (error) {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('PatEventMainComponent.vue', 'getObjectURL', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end

        }
      } else if (ownerWindow.URL !== undefined) { // mozilla(firefox)
        try {
          url = ownerWindow.URL.createObjectURL(file)
        } catch (error) {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('PatEventMainComponent.vue', 'getObjectURL', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end

        }
      }
      return url
    },
    //add オンプレミスの場合、転入患者さんの紹介状が取込できない 吉 end
    /**
     * 詳細画面の展開時、患者イベント情報
     */
    setPatEventInfo(mstTemplate) {
      this.patEventInfo.patId = this.selectedPatId;
      this.patEventInfo.facilityCd = this.facilityCd;
      this.patEventInfo.fnCtlNo = 0;
      this.patEventInfo.eventStatus = "0";
      let result = [];
      if (mstTemplate !== null) {
        this.patEventInfo.templateCd = mstTemplate.templateCd;
        this.patEventInfo.templateName = mstTemplate.templateName;
        this.patEventInfo.categoryCd = mstTemplate.categoryCd;
        this.patEventInfo.categoryName = this.getMstCategoryRecords.find(
          record => record.categoryCd === mstTemplate.categoryCd
        ).categoryName;
        this.patEventInfo.subCategoryCd = 0;
        this.patEventInfo.subCategoryName = null;
        this.patEventInfo.useType = 0;
        this.patEventInfo.inputParams = mstTemplate.inputParams;
        //項目実績の想定する必要な情報を生成
        for (const item of JSON.parse(mstTemplate.inputParams)) {
          let performance = null;
          switch (item.format_class) {
            case 0:
            case 1:
            case 5:
            case 8:
            case 9:
            case 10:
              performance = {
                format_class: item.format_class,
                result_value: ""
              };
              break;
            case 2:
            case 3:
            case 4:
            case 6:
            case 7:
              performance = {
                format_class: item.format_class,
                result_value: []
              };
              break;
          }
          result.push(performance);
        }
      } else {
        this.patEventInfo.templateCd = 0;
        this.patEventInfo.templateName = null;
        this.patEventInfo.categoryCd = 0;
        this.patEventInfo.categoryName = null;
        if (!this.getUpdateMode) {
          this.patEventInfo.subCategoryCd = 0;
        } else {
          this.patEventInfo.subCategoryCd = -1;
        }
        this.patEventInfo.subCategoryName = null;
        this.patEventInfo.templateName = null;
        this.patEventInfo.useType = 0;
        this.patEventInfo.inputParams = "[]";
      }
      this.patEventInfo.resultParams = JSON.stringify(result);
      // TODO:オーダ仮番号
      this.patEventInfo.ordNo = 0;
      this.patEventInfo.eventStartDate = null;
      this.patEventInfo.eventEndDate = null;
      const user = this.getStateUserAccountInfo;
      this.patEventInfo.scoreTotal = 0;
      this.patEventInfo.regStaffInfo = JSON.stringify({
        reg_staff_cd: user.userId,
        reg_staff_name: user.userLastName + user.userFirstName
      });
      this.patEventInfo.upStaffInfo = JSON.stringify({
        up_staff_cd: user.userId,
        up_staff_name: user.userLastName + user.userFirstName
      });
      this.patEventInfo.bbsCtlNo = 0;
      this.patEventInfo.isNewest = "1";
      this.patEventInfo.isDel = "0";
      this.patEventInfo.regDate = null;
      this.patEventInfo.upDate = null;
    },
    /**
     * 一覧行選択の制御
     */
    classRowSetting(index, value) {
      return {
        "item-row-hovered": !value,
        "item-row-checked": value
      };
    },
    /**
     * リストの患者イベント表示処理
     */
    async getSelectPatEventRecords(options) {
      if (this.processing) return;
      this.processing = true;

      if (typeof options !== "object") options = {};
      const hasRegisteredPatEventCd = typeof options.registeredPatEventCd === "number";

      // 患者切替え判断
      const nowSelectPatId = this.selectedPatId;
      if (nowSelectPatId === null) {
        this.processing = false;
        return;
      }
      this.beforeSelectPatId = (this.beforeSelectPatId === null) ? nowSelectPatId : this.tempPatId;
      this.tempPatId = nowSelectPatId;

      let isYesNo = true;
      if (this.beforeSelectPatId !== nowSelectPatId) {
        let changed = false;
        const options = {};
        options.beforeConfirmCallback = () => {
          changed = true;
        };
        const allowed = await this.confirmAllowDiscardChanges(options);
        if (changed) {
          if (allowed) {
            this.rowSelect = 0;
            this.beforeSelectPatId = nowSelectPatId;
            this.isGoOn = true;
            // 以降の処理で破棄確認が起きないようにクリアしておく
            await this.setDetailCancel(true);
          } else {
            this.tempPatId = this.beforeSelectPatId;
            this.isGoOn = false;
          }
          this.setSelectedPatHeader(this.beforeSelectPatId);
          this.nowSelectPatId = this.beforeSelectPatId;
          isYesNo = false;
        }
      }
      if (!isYesNo) {
        this.processing = false;
        return;
      }
      /*add FNSI-改修内容患者を切り替え時、キャンセルして編集した内容を保持していない、任 start*/
      if (this.isGoOn) {
        this.setLoadingScreenVisible(true);
        /*add FNSI-改修内容患者を切り替え時、キャンセルして編集した内容を保持していない、任 end*/
        await this.setDetailCancel();
        // 詳細のコンポーネントをクリア
        this.setPatEventInfo(null);
        await this.setPatEventRecord(this.patEventInfo);

        // 検索条件ログ送信
        this.putConditionLog();

        // リストの明細データ生成
        this.inputModel.history.splice(0);

        const info = {
          patId: nowSelectPatId,
          ...this.getConditionDateYYYYMMDD(),
        };

        if (this.isPatIntroLetter) {
          info.isIntroLetter = true;
        }
        if (hasRegisteredPatEventCd) {
          info.patEventCd = options.registeredPatEventCd;
        }
        info.patShareMode = this.getPatientShareMode;
        info.otherFacilityCd =
          this.getPatientShareMode === 1
            ? this.facilityCd
            : this.getPatientShareFacilityCdMode;
        await this.fetchPatEventRecords(info);
        // add 提示板一覧から患者イベント画面への移行初期表示が補正されていない 20230703 ztc start
        let registeredPatEventIndexByBoard = -1;
        const addHistory = (record) => {
          registeredPatEventIndexByBoard++;
          if(!!this.$route.params.bbsCtlNoFr && record.bbsCtlNo == this.$route.params.bbsCtlNoFr){
            this.rowSelect = registeredPatEventIndexByBoard;
          }
          // add 提示板一覧から患者イベント画面への移行初期表示が補正されていない 20230703 ztc end
          const isOtherFacility = false;
          // 追加対象でない場合は処理しない
          if (!this.isPatientShared && isOtherFacility) return;

          const item = {
            patEventCd: record.patEventCd,
            eventStartDate: formatToDisplayDate(record.eventStartDate),
            eventStartTime: nomalizeNullableString(record.eventStartTime),
            eventEndDate: record.eventEndDate !== null ? formatToDisplayDate(record.eventEndDate) : "",
            eventEndTime: nomalizeNullableString(record.eventEndTime),
            categoryName: record.categoryName,
            templateName: record.templateName,
            scoreTotal: record.scoreTotal,
            reportUrl: record.reportUrl,
            isOtherFacility,
            reportDate: formatToDisplayDate(record.reportDate),
            useType: record.useType,
            letterInfo: record.letterInfo,
            facilityName: record.facilityName,
            ordNo: record.ordNo,
            subCategoryName: record.subCategoryName,
            subCategoryCd: record.subCategoryCd,
            activeRow: false,
            sysFacilityName: null,
          };
          if (record.letterInfo !== null) {
            const recordLetterInfo = JSON.parse(record.letterInfo);
            if (recordLetterInfo.to_medical_institution_cd == null) {
              if (recordLetterInfo.to_facility_cd !== null) {
                item.sysFacilityName = recordLetterInfo.to_facility_cd;
              }
            /* modify by chamaojia 2025-05-21 [11871]  --start */  
            // } else if (this.facilityNameList !== null) {
            //   const facilityNameItem = this.facilityNameList.find(name => (recordLetterInfo.to_medical_institution_cd === name.medicalInstitutionCd));
            //   if (facilityNameItem) {
            //       item.sysFacilityName = facilityNameItem.facilityName;
            //   }
            // }
            } else if (this.respObj) {
              item.sysFacilityName = this.respObj.data.facilityName;
            }
            /* modify by chamaojia 2025-05-21 [11871]  --end */
          }
          this.inputModel.history.push(item);
        };
		const relationCategoryCdTable = this.inputModel.relationCategoryCd.reduce((result, relationCategoryCd) => {
		  const subCategoryCd = relationCategoryCd.split(CategoryCdDelimiter)[0];
		  const categoryCd = relationCategoryCd.split(CategoryCdDelimiter)[1];
		  if ((subCategoryCd === AnySubCategoryCd && categoryCd === AnyCategoryCd)
		  || (subCategoryCd !== AnySubCategoryCd && categoryCd !== AnyCategoryCd)) {
		    result.push([Number(subCategoryCd),Number(categoryCd)]);
		  }
		  if(subCategoryCd === AnySubCategoryCd && categoryCd !== AnyCategoryCd){
		    this.selectTemplates.forEach(templete => {
			  if(templete.code.split(CategoryCdDelimiter)[1] === categoryCd && templete.code.split(CategoryCdDelimiter)[0] !== AnySubCategoryCd){
				result.push([Number(templete.code.split(CategoryCdDelimiter)[0]),Number(templete.code.split(CategoryCdDelimiter)[1])]);
			  }
			})
		  }
		  return result;
		}, []);
        const AnyCategoryCdNumber = Number(AnyCategoryCd);
        const AnySubCategoryCdNumber = Number(AnySubCategoryCd);
        const isTargetCategory = (record) => {
          return !!relationCategoryCdTable.find((relationCategoryCd) => {
            return (
              [AnySubCategoryCdNumber, record.subCategoryCd].includes(relationCategoryCd[0])
              && [AnyCategoryCdNumber, record.categoryCd].includes(relationCategoryCd[1])
            );
          });
        };
        for (const iterator of this.getPatEventRecords) {
          if (
            isTargetCategory(iterator)
            || (hasRegisteredPatEventCd && iterator.patEventCd === options.registeredPatEventCd)
          ) {
            /* add by chamaojia 2025-05-21 [11871]  --start */
            const recordLetterInfo = JSON.parse(iterator.letterInfo);
            if(recordLetterInfo) {
              const rest = await ApiHelper.get("/sysFacility/getSysFacilityByCd/"
                  +recordLetterInfo.to_medical_institution_cd);
              this.respObj = rest;
            }
            /* add by chamaojia 2025-05-21 [11871]  --end */
            addHistory(iterator);
          }
        }

        const registeredPatEventFinder = (item) => item.patEventCd === options.registeredPatEventCd;
        const registeredPatEventIndex = hasRegisteredPatEventCd
          ? this.inputModel.history.findIndex(registeredPatEventFinder)
          : -1;

        // 表示対象を選択したか
        let isSelected = false;

        // 画面遷移パラメータ取得
        const queryParametersPatEventCd = this.getQueryParameters().PATEVENTCD;
        // イベントコードが指定されて画面遷移した場合、リスト内から対象イベントを表示
        if (queryParametersPatEventCd) {
          // リストからPATEVENTCDに合致するindexを抽出
          const targetIndex = this.inputModel.history.findIndex(aHistory => (
            aHistory.patEventCd == queryParametersPatEventCd
          ));
          if (targetIndex > -1) {
            await this.selectHistory(targetIndex);
            isSelected = true;
          }
        }
        // クエリパラメータをクリアする
        this.setQueryParameters({});

        if (this.isCreateNew) {
          // 患者カレンダー画面から、新規作成で画面遷移した場合
          this.$refs.detail.newDateStr = this.$route.params.condition.eventStartDate;
          this.editPatEventRec();
        } else if (this.inputModel.history.length >= 1 && !isSelected) {
          // 初期表示はリスト表示の一番上を強制的に表示する(画面遷移時に表示処理を行っていない場合)
          let patEventCdCondition = null;
          if (this.isRouteCreateFlg && this.$route.params.condition.patEventCd) {
            this.isRouteCreateFlg = false;
            patEventCdCondition = this.$route.params.condition.patEventCd;
          } else if (this.isRouteGamenFlg) {
            this.isRouteGamenFlg = false;
            patEventCdCondition = this.getTreatBaseDate[0].patEventCd;
          // #10228 患者カレンダー ＞日付文字列押下(強制画面移動で患者イベントの新規登録状態に遷移) linjunfeng start
          } else if (this.$route.params.condition?.patCalendarFlg) {
            this.$refs.detail.newDateStr = this.$route.params.condition.eventStartDate;
          }
          // #10228 患者カレンダー ＞日付文字列押下(強制画面移動で患者イベントの新規登録状態に遷移) linjunfeng end
          if (patEventCdCondition) {
            // 患者イベントコードが指定されている場合
            const historyList = this.inputModel.history;
            const index = historyList && historyList.findIndex(history => history.patEventCd === patEventCdCondition);
            if (index > -1) {
              await this.selectHistory(index);
            }
          } else if (this.isRouteCreateFlg) {
            this.isRouteCreateFlg = false;
            const conditionList = this.$route.params.condition;
            // conditionList.eventEndDate は YYYMMDD 形式になっているので
            // 比較用に YYYY/MM/DD 形式にする
            // （conditionList.treatDate は YYYY/MM/DD 形式）
            const conditionEndDate = formatToDisplayDate(conditionList.eventEndDate);
            // 患者イベントデータ
            const historyList = this.inputModel.history;
            for (let index = 0; index < historyList.length; index++) {
              // イベント開始日、カテゴリ名称、サブカテゴリ名称と同じの場合
              // #8016調査時のメモ：
              // ここは患者経過総合ビューアから遷移してきた際
              // （もしくは患者イベント画面以外で予実リストの患者イベントを選択して遷移してきた際）
              // の処理と思われるが、
              // 患者イベント画面で予実リストの患者イベントを選択した際の処理と同じく
              // #6339向けの修正としてeventStartTime、eventEndTimeなどの一致条件も追加されている
              // 患者経過総合ビューアからの遷移時には
              // eventStartTime、eventEndTimeは設定されないようなので
              // 常に一致するものが見つからない結果となっている
              // [2023/08/07 追記]#9329の対応にて予実リストからの遷移時は患者イベントコードによる判定に修正される
              if (
                historyList[index].eventStartDate == conditionList.treatDate &&
                /*add 6339 予実リストでイベントを選択しても患者イベントのイベントリスト最上部のイベントが必ず表示される 周安寧 start*/
                historyList[index].eventStartTime == conditionList.eventStartTime &&
                historyList[index].eventEndDate == conditionEndDate &&
                historyList[index].eventEndTime == conditionList.eventEndTime &&
                /*add 6339 予実リストでイベントを選択しても患者イベントのイベントリスト最上部のイベントが必ず表示される 周安寧 end*/
                historyList[index].categoryName == conditionList.categoryName &&
                historyList[index].subCategoryName == conditionList.subCategoryName
              ) {
                await this.selectHistory(index);
                break;
              }
            }
          } else if (registeredPatEventIndex > -1) {
            // 保存や編集キャンセルの直後のデータを選択する
            this.rowSelect = registeredPatEventIndex;
            await this.selectHistory(this.rowSelect);
          } else {
            // リストの先頭を選択する
            // add 提示板一覧から患者イベント画面への移行初期表示が補正されていない 20230703 ztc start
            if (!this.$route.params.bbsCtlNoFr) {
              this.rowSelect = 0;
            }
            // add 提示板一覧から患者イベント画面への移行初期表示が補正されていない 20230703 ztc end
            await this.selectHistory(this.rowSelect);
          }
        }
        this.processing = false;
        /*add FNSI-改修内容患者を切り替え時、キャンセルして編集した内容を保持していない、任 start*/
        this.setLoadingScreenVisible(false);
      }
      /*add FNSI-改修内容患者を切り替え時、キャンセルして編集した内容を保持していない、任 end*/
    },
    getConditionDateYYYYMMDD() {
      const toYYYYMMDD = (date) => date ? dayjs(date).format("YYYYMMDD") : "";
      return  {
        startDate: toYYYYMMDD(this.getConditionDate.startDate),
        endDate: toYYYYMMDD(this.getConditionDate.endDate),
      };
    },
    putConditionLog() {
      const conditionValues = this.selectTemplates.reduce((result, templete) => {
        if (this.inputModel.relationCategoryCd.find(cd => cd === templete.code)) {
          result.push(templete.name);
        }
        return result;
      }, []);
      if (this.inputModel.startDate) {
        conditionValues.push(this.inputModel.startDate);
      }
      if (this.inputModel.endDate) {
        conditionValues.push(this.inputModel.endDate);
      }
      const functionName = this.isPatEvent ? "患者イベント" : this.isPatIntroLetter ? "紹介状" : "患者イベント・紹介状";
      const message = `${functionName}が[${conditionValues.join("、")}]で検索しました。`;
      ApiHelper.put("/logs/event/conditionlog", {
        message,
        functionName,
      }).catch(error => {
        getErrorMessage("PatEventMainComponent.vue", "putConditionLog", error);
      });
    },
    // パンくずリストをクリックされた場合に呼び出される関数
    async refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      // #8016調査時のメモ：
      // beforeRouteLeaveでawaitした場合はthis.$route.nameが切り替わる前にここを通るので
      // 自分の画面への遷移時かどうかは判定できない
      // 自分の画面への遷移時でない場合はconfirmAllowDiscardChangesの多重呼び出し時の対応により
      // それぞれの破棄OK時の処理が行われるが最終的にbeforeRouteLeaveの処理で画面遷移して終わる
      // #8368調査時のメモ：
      // 患者イベント・紹介状のパンくずリストの自画面クリック時に
      // Viewのrefresh処理とEventBus.emitでのrefresh発生により2回呼び出されている
      // 動作の見た目上はおかしくならないがおそらく2重に処理されている
      if (this.selfScreenName === this.$route.name) {
        if (await this.confirmAllowDiscardChanges()) {
          // 以降の処理で破棄確認が起きないようにクリアしておく
          await this.setDetailCancel(true);
          this.getSelectPatEventRecords();
        }
      }
    },
    initPatIntroLetter() {
	 let mstSubCategoryRecords = this.getMstSubCategoryRecords;
		
      if (this.isPatIntroLetter) {
        mstSubCategoryRecords = mstSubCategoryRecords.filter(rec => rec.useType === 3);
      }
	  
	  mstSubCategoryRecords = mstSubCategoryRecords.filter(obj1 => this.getMstCategoryRecords.some(obj2 => obj1.categoryCd === obj2.categoryCd));
      this.setMstSubCategoryRecords(mstSubCategoryRecords);
    },
    async confirmAllowDiscardChanges(options) {
      return await this.$refs.detail.confirmAllowDiscardChanges(options);
    },
    async setDetailCancel(noConfirm) {
      try {
        if (this.$refs.detail) {
          await this.$refs.detail.cancel(noConfirm);
        }
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('PatEventMainComponent.vue', 'setDetailCancel', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end

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
    onImageViewerClick() {
      this.isShowViewerModal = true;
      this.$refs.viewer.initImage();
    },
    onCancelViewer() {
      this.isShowViewerModal = false;
    },
    onDeviceBackButton(event) {
      event.preventDefault();
      this.isShowViewerModal = false;
    },
    onCloseMainList() {
      this.isHideMainList = true;
      this.setIsMainList(true);
    },
    onOpenMainList() {
      this.isHideMainList = false;
      this.setIsMainList(false);
    },
    requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        // 機能一致

        // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
        const index = this.inputModel.history && this.inputModel.history.findIndex(history => history.activeRow === true);
        var dialysisDate = dayjs(Date.now()).format("YYYYMMDD");
        if(index > -1){
          dialysisDate = dayjs(this.inputModel.history[index].eventStartDate).format("YYYYMMDD");
        }
        // add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao start
        let reportDate = this.$refs.detail.getReportStartDateValue();
        // 新規登録の場合
        if(reportDate !== null && this.getUpdateMode === false){
          dialysisDate = dayjs(reportDate).format("YYYYMMDD");
        }
        // add #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao end
        // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end

        // 印刷パラメータを応答
        // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
        if (param == "02701") {
          // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
        const param = {
          facilityCd: this.facilityCd,
          //mod 5984 機能帳票でパラメータが正しく渡されていない 吉 start
          // patId: this.dispUserId,
          patId: this.patEventInfo.patId,
          functionCd:"02701",
          //mod 5984 機能帳票でパラメータが正しく渡されていない 吉 end
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          // mod #9558 機能帳票でパラメータが正しく渡されていない 房 start
          //date: dayjs(this.inputModel.startDate).format("YYYY/MM/DD"),
          // mod #9558 機能帳票でパラメータが正しく渡されていない 房 end
          //fromDate: dayjs(this.inputModel.startDate).format("YYYY/MM/DD"),
          //toDate: dayjs(this.inputModel.endDate).format("YYYY/MM/DD"),
          // mod #12328 【因島】画面内にデータリストを持つ画面の機能帳票パラメータ修正 高　start
          // date: this.inputModel.startDate != null ? dayjs(this.inputModel.startDate).format("YYYYMMDD") : (this.inputModel.endDate != null ? dayjs(this.inputModel.endDate).format("YYYYMMDD") : dayjs(Date.now()).format("YYYYMMDD")),
          // fromDate: this.inputModel.startDate != null ? dayjs(this.inputModel.startDate).format("YYYYMMDD") : (this.inputModel.endDate != null ? dayjs(this.inputModel.endDate).format("YYYYMMDD") : dayjs(Date.now()).format("YYYYMMDD")),
          // toDate: this.inputModel.endDate != null ? dayjs(this.inputModel.endDate).format("YYYYMMDD") : (this.inputModel.startDate != null ? dayjs(this.inputModel.startDate).format("YYYYMMDD") : dayjs(Date.now()).format("YYYYMMDD")),
          date: dialysisDate,
          fromDate: dialysisDate,
          toDate: dialysisDate,
          // mod #12328 【因島】画面内にデータリストを持つ画面の機能帳票パラメータ修正 高　end
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //dialysisDate: dialysisDate,
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
        };
        EventBus.$emit("sendReportParams", param);
          // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
        } else {
          // add #9558 機能帳票で正しく変数が引き渡されていない limingzhe start
          var curDate = new Date();
          // add #9558 機能帳票で正しく変数が引き渡されていない limingzhe end
          const param = {
            facilityCd: this.facilityCd,
            //mod 5984 機能帳票でパラメータが正しく渡されていない 吉 start
            // patId: this.dispUserId,
            patId: this.patEventInfo.patId,
            functionCd:"03001",
            //mod 5984 機能帳票でパラメータが正しく渡されていない 吉 end
            // mod #9558 機能帳票で正しく変数が引き渡されていない limingzhe start
            //date: dayjs(Date.now()).format("YYYY/MM/DD"),
            //fromDate: dayjs(this.inputModel.startDate).format("YYYY/MM/DD"),
            //toDate: dayjs(this.inputModel.endDate).format("YYYY/MM/DD")
            // mod #12328 【因島】画面内にデータリストを持つ画面の機能帳票パラメータ修正 高　start
            // date: dayjs(Date.now()).format("YYYY/MM/DD"),
            // fromDate: dayjs(Date.now()).format("YYYY/MM/DD"),
            // toDate: dayjs(new Date(curDate.setMonth(curDate.getMonth() + 1))).format("YYYY/MM/DD"),
            date: dialysisDate,
            fromDate: dialysisDate,
            toDate: dialysisDate,
            // mod #12328 【因島】画面内にデータリストを持つ画面の機能帳票パラメータ修正 高　end
            // mod #9558 機能帳票で正しく変数が引き渡されていない limingzhe end
            // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
            // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
            //dialysisDate: dialysisDate,
            // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
            // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
          };
          EventBus.$emit("sendReportParams", param);
        }
        // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
      }
    },
    /*add FNSI-改修内容日付のチェックの追加対応。 任 start*/
    showStartMsg(){
      this.showErrorStartDate = this.getScopedClassElementSafe("start-date")?.validationMessage !== "";
    },
    showEndMsg(){
      this.showErrorEndDate = this.getScopedClassElementSafe("end-date")?.validationMessage !== "";
    },
    getStartDate(){
      this.showErrorStartDate = this.getScopedClassElementSafe("start-date")?.validationMessage !== "";
    },
    getEndDate(){
      this.showErrorEndDate = this.getScopedClassElementSafe("end-date")?.validationMessage !== "";
    },
    /*add FNSI-改修内容権限関連 任 start*/
    // del #10359_NG対応 編集権限の動作不正 dengshen start
    // getTreatmentRecordAuthority() {
    //   return this.hasAuthority();
    // },
    // del #10359_NG対応 編集権限の動作不正 dengshen end
    /*add FNSI-改修内容権限関連 任 end*/
    /*add FNSI-改修内容日付のチェックの追加対応。 任 end*/
    getPublicFlag() {
      ApiHelper.get(
        "/pat_event/getPublicFlag/" + this.getUserId,
        {
          selectedPatId: this.selectedPatId
        }
      ).then(res => {
        this.isPatientShared = res.data.msg === 1;
      }).catch(error => {
        getErrorMessage("PatEventMainComponent.vue", "getPublicFlag", error);
        throw error;
      });
    },
    makeCategorySelection() {
      // カテゴリ選択リスト用の情報を作成する
      this.categorySelection = this.selectTemplates.map(templete => {
        const categoryCodes = templete.code.split(CategoryCdDelimiter);
        return {
          ...templete,
          subCategoryCd: categoryCodes[0],
          categoryCd: categoryCodes[1],
          selected: this.inputModel.relationCategoryCd.some(cd => cd === templete.code),
        };
      });
    },
    // ポップオーバー表示
    showPopover(event) {
      this.snapshotCondition();
      this.makeCategorySelection();
      // ポップオーバー表示
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    handlePopoverPosthide(event) {
      this.revertCondition();
      this.popoverPosthide(event);
    },
    async applyCondition() {
      this.popoverVisible = false;
      // 破棄確認を表示する前にポップアップを非表示にする必要があるが、
      // popoverVisibleをfalseにした後にawaitするとその間にposthideが発生して
      // revertConditionなどが走ってしまうので、先行してtmpInputData.validをfalseにしておき、
      // 破棄確認でキャンセルされた場合には改めてtmpInputData.validをtrueにしてから
      // revertConditionを呼ぶ
      this.tmpInputData.valid = false;

      if (!(await this.confirmAllowDiscardChanges())) {
        // 破棄確認でキャンセルされた場合は検索条件をポップアップ表示時の状態に戻す
        this.tmpInputData.valid = true;
        this.revertCondition();
        this.setConditionList();
        return;
      }

      this.setLoadingScreenVisible(true);
      // 以降の処理で破棄確認が起きないようにクリアしておく
      await this.setDetailCancel(true);

      this.setConditionDateByValues(
        toDate(this.inputModel.startDate),
        toDate(this.inputModel.endDate)
      );

      // categorySelectionの状態をinputModel.relationCategoryCdに反映する
      this.inputModel.relationCategoryCd.length = 0;
      this.inputModel.relationCategoryCd.push(
        ...this.categorySelection.reduce((result, item) => {
          if (item.selected) {
            result.push(item.code);
          }
          return result;
        }, [])
      );
      if (this.inputModel.relationCategoryCd.length === 0) {
        this.inputModel.relationCategoryCd.push(AllCategoryCd);
      }
      this.setConditionList();
      this.storeSelectInfo();

      await this.getSelectPatEventRecords();
      this.setLoadingScreenVisible(false);
    },
    // ポップオーバー クリアボタンクリックイベント
    resetCondition() {
      this.inputModel.relationCategoryCd = [...this.defaultSetting.relationCategoryCd];
      this.inputModel.startDate = formatToInputDate(this.defaultSetting.startDate);
      this.inputModel.endDate = formatToInputDate(this.defaultSetting.endDate);

      this.makeCategorySelection();
    },
    // 共通検索エリア部品に表示するデータのリストを作成
    setConditionList() {
      const newList = [];
      const addCondition = (name, text) => newList.push({ name, text });
      // カテゴリ
      const categoryText = this.selectTemplates.reduce((result, template) => {
        if (this.inputModel.relationCategoryCd.find(cd => cd === template.code)) {
          result.push(template.name);
        }
        return result;
      }, []).join("、");
      if (categoryText.length > 0) {
        addCondition("カテゴリ", categoryText);
      }
      //#10715:日付IF修正Start
      //表示期間
      if (this.inputModel.startDate) {
        addCondition("表示期間", this.inputModel.startDate.replace(/-/g, "/"));
      }
      //表示期間
      if (this.inputModel.endDate) {
        addCondition("　　　～", this.inputModel.endDate.replace(/-/g, "/"));
      }
      //#10715:日付IF修正End
      this.conditionList = newList;
    },
    snapshotCondition() {
      // 変更前の条件を退避
      copyCondition(this.inputModel, this.tmpInputData);
      this.tmpInputData.valid = true;
    },
    revertCondition() {
      if (!this.tmpInputData.valid) return;
      // 変更前の条件に戻す
      copyCondition(this.tmpInputData, this.inputModel);
      this.tmpInputData.valid = false;
    },
    storeSelectInfo() {
      const historyInfo = {
        relationCategoryCd: [...this.inputModel.relationCategoryCd],
        startDate: this.inputModel.startDate,
        endDate: this.inputModel.endDate,
      };
      this.setSelectInfo(
        this.isPatEvent ? { patEvent: historyInfo }
        : this.isPatIntroLetter ? { patIntroLetter: historyInfo }
        : {}
      );
    },
  },
  watch: {
    /*add FNSI-改修内容日付のチェックの追加対応。 任 start*/
    'inputModel.endDate'() {
      if(this.getScopedClassElementSafe("end-date")?.validationMessage !== ""){
        this.showErrorEndDate = !(this.getScopedClassElementSafe("end-date")?.value === "" && this.getScopedClassElementSafe("end-date-comment")?.value !== "");
      }else{
        this.showErrorEndDate = false;
      }
    },
    'inputModel.startDate'() {
      if(this.getScopedClassElementSafe("start-date")?.validationMessage !== ""){
        this.showErrorStartDate = !(this.getScopedClassElementSafe("start-date")?.value === "" && this.getScopedClassElementSafe("start-date-comment")?.value !== "");
      }else{
        this.showErrorStartDate = false;
      }
    },
    /*add FNSI-改修内容日付のチェックの追加対応。 任 end*/
    selectedPatId() {
      /*add FNSI-改修内容患者を切り替え時、キャンセルして編集した内容を保持していない、任 start*/
      if(this.isGoOn){
        /*add FNSI-改修内容患者を切り替え時、キャンセルして編集した内容を保持していない、任 end*/
        this.getSelectPatEventRecords();
        /*add FNSI-改修内容患者を切り替え時、キャンセルして編集した内容を保持していない、任 start*/
      }else{
        if(this.selectedPatId !== null && this.nowSelectPatId === this.selectedPatId){
          this.isGoOn = true;
        }
      }
      /*add FNSI-改修内容患者を切り替え時、キャンセルして編集した内容を保持していない、任 end*/
    },
    async getTreatBaseDate() {
      // 患者イベント画面以外は処理対象外
      // （患者イベント画面以外で予実リストの患者イベントを選択した場合は患者イベントに遷移した後に処理される）
      if (!this.isPatEvent) return;

      // 患者イベント画面で予実リストの患者イベントを選択した場合
      // 破棄確認でキャンセルされたら処理を中止する
      if (!(await this.confirmAllowDiscardChanges())) return;
      this.setLoadingScreenVisible(true);
      // 以降の処理で破棄確認が起きないようにクリアしておく
      await this.setDetailCancel(true);

      this.isRouteGamenFlg = true;
      // #9329対応時の仕様メモ：
      // 選択したデータの開始日を表示条件の開始日終了日に設定し　カテゴリは全カテゴリにする。
      const eventStartDate = toDate(this.getTreatBaseDate[0].eventStartDate);
      this.setConditionDateByValues(eventStartDate, eventStartDate);
      this.updateInputModelDate();

      const relationCategoryCd = this.inputModel.relationCategoryCd;
      relationCategoryCd.length = 0;
      relationCategoryCd.push(AllCategoryCd);

      this.setConditionList();
      this.storeSelectInfo();
      await this.getSelectPatEventRecords();
      this.setLoadingScreenVisible(false);
    }
  },
  async created() {
    this.setEditingOrdNo(0);
    // add #9975 start 馬
    this.setPatEventRecord(null);
    // add #9975 end 馬
    this.setLoadingScreenMessage("処理中・・・");
    this.setLoadingScreenVisible(true);
    /*add FNSI-改修内容患者イベント外结No.7 任 start*/
    // #8062対応時のメモ：
    // #8062で問題になっている現象はここでの await this.loadSysFacility(); の
    // 完了待ちが長時間にわたることによる。
    // このチケットでは直接awaitしない形にして、created内の以降の処理が
    // 長時間ブロックされることがないようにだけしておく。
    // 施設名表示などに問題が残るが、
    // 詳細は https://redmine.nksfn.com/redmine/issues/8062 を参照。
    /* del by chamaojia 2025-05-21 [11871]  --start */
    // Promise.resolve().then(async () => {
    //   await this.loadSysFacility();
    //   this.facilityNameList = this.getSysFacilitiesForName;
    // });
    /* del by chamaojia 2025-05-21 [11871]  --end */
    /*add FNSI-改修内容患者イベント外结No.7 任 end*/
    /*add FNSI-改修内容権限関連 任 start*/
    // del #10359_NG対応 編集権限の動作不正 dengshen start
    // this.hasTreatmentRecordAuthority = this.getTreatmentRecordAuthority();
    // del #10359_NG対応 編集権限の動作不正 dengshen end
    /*add FNSI-改修内容権限関連 任 end*/
    // add 性能改善メモリ不足 shan start
    EventBus.$off("reloadPatEventRecord", this.getSelectPatEventRecords);
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("requestReportParams", this.requestrReportParams);
    EventBus.$off("openMainList", this.onOpenMainList);
    EventBus.$off("refreshPatEventList", this.getSelectPatEventRecords);
    // add 性能改善メモリ不足 shan end

    EventBus.$on("reloadPatEventRecord", this.getSelectPatEventRecords);
    // 画面名称取得
    this.selfScreenName = this.$route.name;
    EventBus.$on("refresh", this.refresh);

    // 印刷パラメータ要求
    EventBus.$on("requestReportParams", this.requestrReportParams);

    EventBus.$on("openMainList", this.onOpenMainList);
    EventBus.$on("refreshPatEventList", this.getSelectPatEventRecords);

    this.setViewMode(true);
    this.setIsEdit(false);

    /*add FNSI-改修内容患者イベント患者情報共有より改修 任 start*/
    await this.getPublicFlag();
    /*add FNSI-改修内容患者イベント患者情報共有より改修 任 end*/
    // add FNSI-コントロールの削除 徐 start
    this.setPatEventFlg(false);
    // add FNSI-コントロールの削除 徐 end
    this.setLoadingScreenVisible(false);
  },
  async mounted() {
    this.setLoadingScreenVisible(true);

    // 画像シェーマ用の初期化設定を取得
    this.initStampTextInfo(this.selectedPatId);

    await this.fetchPatEventMaster({ selectedPatId: this.selectedPatId });
    this.initPatIntroLetter();
    this.mstSubCategoryRecords = this.getMstSubCategoryRecords;
    this.mstCategoryRecords = this.getMstCategoryRecords;
    
    // 患者カレンダーから新規登録で遷移したかを設定
    this.isCreateNew = this.$route.params.condition?.createNew;
     
    // 検索条件の初期設定
    this.initCondition();
    // delete start 馬 #9975
    // await this.setPatEventRecord(null);
    // delete end 馬 #9975
    if (this.selectedPatId !== null) {
      await this.getSelectPatEventRecords();
    }

    this.setLoadingScreenVisible(false);
  },
  beforeUnmount() {
    EventBus.$off("reloadPatEventRecord", this.getSelectPatEventRecords);
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("requestReportParams", this.requestrReportParams);
    EventBus.$off("openMainList", this.onOpenMainList);
    EventBus.$off("refreshPatEventList", this.getSelectPatEventRecords);

    this.clearCompareViewImgs();
    this.setUpdateMode(true);
    this.setViewMode(true);
    this.setIsEdit(false);
    
    // storeのイベント開始日クリア
    this.setEventStartDate(null);
    
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
};
</script>
<style scoped>
.main-flex-container {
  display: flex;
  height: 100%;
}
.history-area {
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
  height: 100%;
  width: 285px;
  padding-left: 5px;
}
.header-area {
  display: flex;
  width: 100%;
}
.detail-area {
  display: flex;
  flex-grow: 1;
  overflow-y: hidden;
  width: 100%;
  padding-top: 5px;
}
.content-area {
  flex-grow: 1;
  overflow-x: auto;
  height: 100%;
}
.table-area {
  width: 100%;
  border-collapse: collapse;
  overflow-y: scroll;
}
.table-area tr {
  height: 30px;
}
.table-area tr th {
  text-align: left;
}
.table-area tr td:first-child,
.table-area tr td:nth-child(2),
.table-area tr td:nth-child(3) {
  text-align: left;
}
table.list {
  background-color: transparent;
  background-image: none;
}
table.list .list-score {
  text-align: center;
  white-space: nowrap;
  width: 100%;
}
table.list .list-event {
  text-align: center;
  /*del FNSI-改修内容患者イベント患者情報共有より改修 任 start*/
  /*white-space: nowrap;*/
  /*del FNSI-改修内容患者イベント患者情報共有より改修 任 end*/
  width: 100%;
}
.other-facility {
  background-color: #ffff99;
}
.button {
  /*height: 30px;*/
  padding: 0px 3px 0px 5px;
  font-size: 1em;
}
.item-row-hovered:hover {
  background-color: transparent;
}
/*del FNSI-画面部品デザイン じょはく start*/
/*.item-row-checked {
  outline: 3px solid #0000ff;
  outline-offset: -3px;
}*/
/*del FNSI-画面部品デザイン じょはく end*/
/*.title-label {
  padding-top: 5px;
}*/
.input {
  max-width: 15em;
  vertical-align: middle;
  background-color: white;
}
.header-icon {
  width: 3em;
  position: relative;
  margin-top: 0px;
  line-height:normal;
}
.header-button {
  width: 100%;
}
.header-viewer-button {
  width: fit-content;
}

#header-category {
  display: flex;
  justify-content: space-between;
}
/*#search-select {
  width: calc(100% - 3em);
}*/
#viewer-button {
  width: 3em;
  height: 2em;
  padding: 0;
  display: flex;
  justify-content: center;
  align-items: center;
  margin-right: 1em;
}
#viewer-button-icon {
  width: 1.5em;
  display: block;
}
/*#search-select {
  width: calc(100% - 3em);
}*/
#hide-button {
  width: 3em;
  height: 2em;
  padding: 0;
  display: flex;
  justify-content: center;
  align-items: center;
  margin-left: 2em;
}
/** 子機能開閉ボタン */
.pat-event-openclose-icon {
  font-size: 2em;
  margin-right: 15px;
  margin-left: 5px;
  color: var(--pat-event-text-color);
}
/*add FNSI-改修内容イベント実績一覧のマルチカテゴリフィルター 任 start*/
.pat-list {
  height: 110px;
}
.pat-list .unselected-pat-list{
  position: relative;
  border: 1px solid var(--ntss-list-border-color);
  overflow: auto;
}
.pat-display {
  /*mod FNSI-4421 fan start*/
  /*padding: 0.5em 0.3em;*/
  padding: 0.05em 0.3em;
  /*mod FNSI-4421 fan start*/
}
.pat-display:hover {
  background-color: #e4e7eb;
}
.pat-display.selected {
  color: #fff;
  background-color: #0076ff;
}
/*add FNSI-改修内容イベント実績一覧のマルチカテゴリフィルター 任 end*/

@media print {
  /** 履歴のスクロールバー非表示 */
  .detail-area table {
    overflow: visible !important;
  }
  /** 履歴のヘッダがページ毎に表示されるのを回避 */
  .detail-area table thead {
    display: table-row-group !important;
  }
}
</style>
