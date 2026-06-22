<template>
  <!-- mod 更新中の予定を表示する様にする。 李 start -->
  <!-- <div class="list-content" :style="{ 'height':this.contentHeight + 'px' }"> -->
  <!-- mod bug 7872 修正 chen start -->
  <div id="pat_viewer" class="list-content" :style="{ 'height':this.contentHeight + 'px' }" v-show="isDisflg">
  <!-- mod bug 7872 修正 chen end -->
  <!-- mod 更新中の予定を表示する様にする。 李 end -->
    <!-- ヘッダー部分 -->
    <!-- mod FutreNetWeb+SI課題管理 no.6450 chen start  -->
    <!-- <div class="list-header-div" :style="{ 'min-width':this.contentWidth + 'px' }"> -->
    <div class="list-header-div" :style="contentClass">
    <!-- mod FutreNetWeb+SI課題管理 no.6450 chen end  -->
      <v-ons-row class="list-header-row">
        <v-ons-col
          class="list-header-col-title"
          @click="showPopoverSetting($event, 'down', false)"
        >
          {{ getTitleDay }}
        </v-ons-col>
        <v-ons-col
          v-for="(date, index) in dateList"
          :key="index"
          :class="getWeek(date)"
          class="list-header-col"
          @click="onDateClick($event, date)"
        >
          <div
            :class="[
              { 'list-header-col-align-left': currentSelectedPeriod === '4' },
              { 'list-header-baseday': needOutline(date) },
              { 'list-header-today': needTodayBG(date) }
            ]"
          >
            {{ dateFormatter(date) }}
          </div>
        </v-ons-col>
      </v-ons-row>

      <!-- 治療状況 -->
      <v-ons-row
        v-if="0 !== ordMainData.length"
        class="list-content-row-height item-status-style"
      >
        <v-ons-col class="list-content-row list-content-col-title">
          <v-ons-icon
            class="list-paging-btn"
            size="20px"
            icon="fa-angle-double-left"
            @click="setBaseDatePrev()"
          />
          <v-ons-icon
            class="list-paging-btn"
            size="20px"
            icon="fa-angle-left"
            @click="setBaseDatePrev(1)"
          />
          <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
          <!-- <v-ons-button
            class="button-style list-paging-btn"
            @click="setBaseDateToday"
          >
            今日
          </v-ons-button> -->
          <v-ons-button
            class="button-style list-paging-btn btn3-normal"
            @click="setBaseDateToday"
          >
            今日
          </v-ons-button>
          <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
          <v-ons-icon
            class="list-paging-btn"
            size="20px"
            icon="fa-angle-right"
            @click="setBaseDateNext(1)"
          />
          <v-ons-icon
            class="list-paging-btn"
            size="20px"
            icon="fa-angle-double-right"
            @click="setBaseDateNext()"
          />
        </v-ons-col>
        <v-ons-col
          v-for="(data, index) in treatStatusList"
          :key="index"
          class="list-content-status-col"
        >
        <div
          v-for="(itemData, itemIndex) in data"
          :key="itemIndex"
        >

          <v-ons-row v-if="itemData.dispCount === null" @click="moveSpecifiedPos(itemIndex, 'scroll-column')" >
            <div class="status-figure-label">
              <div :style="treatmentTimeStyle0(itemData.status)">
                <div :style="treatmentProgressStyle0(itemData.status, itemData.treatDate)"></div>
              </div>
            </div>
            </v-ons-row>

            <v-ons-row v-else>
            <div class="status-figure-processbar">
              <div @click="showPopoverSetting1($event, 'down', false, index)" >
                <div :style="treatmentTimeStyle1(itemData.status)">
                  <span :style="treatmentCountStyle1(itemData.status)" class="state-dispcount">{{itemData.dispCount}}</span>
                  <div :style="treatmentProgressStyle1(itemData.status, itemData.treatDate)"></div>
                </div>
              </div>
            </div>
          </v-ons-row>

          </div>
        </v-ons-col>
      </v-ons-row>
    </div>

    <div>
      <v-ons-popover
        :class="[fontSizeSet, 'popover-style']"
        v-model:visible="popoverVisible1"
        :target="popoverTarget1"
        :direction="popoverDirection1"
        :cover-target="popoverCoverTarget1"
        :key="`popover${popoverKey}`"
        cancelable
      >
     <div class="v-ons-popover-around">
        <div
          v-for="(itemData, itemIndex) in arrayDialysisState"
          :key="itemIndex"
          class="status-figure-label-popup"
          @click="moveSpecifiedPos(itemIndex, 'scroll-popup')"
        >
            <div :style="treatmentTimeStylePopup(itemData.status)">
              <div :style="treatmentProgressStylePopup(itemData.status, itemData.treatDate)"></div>
            </div>
          </div>
        </div>
      </v-ons-popover>
    </div>

    <!-- コンテンツ部分 -->
    <div
      v-if="patId != null && (0 !== ordMainData.length || !dataReady)"
      class="list-content-div"
      :style="contentClass"
    >
      <div v-for="(layout, index) in selectedLayout" :key="index">
        <component
          v-if="dataReady && allComponents.includes(layout.component)"
          :is="layout.component"
          :selected-layout-cd="selectedLayoutCd"
          :category-item="layout.categoryItem"
          :layout="layout"
          :ref="'childContent' + index"
        />
      </div>
    </div>
    <!-- 表示条件用ポップオーバー -->
    <div v-show="popoverVisible">
      <v-ons-popover
        v-model:visible="popoverVisible"
        :target="popoverTarget"
        :direction="popoverDirection"
        :cover-target="popoverCoverTarget"
        :class="[fontSizeSet, 'popover-content popover-content-condition']"
        cancelable
        @preshow="patViewerPopoverPreShow(); popoverPreShow($event)"
        @postshow="popoverPostShow"
        @posthide="popoverPosthide"
      >
        <!--mod FNSI-画面部品デザイン じょはく start-->
        <div class="popover-content-div fab-font-color">
        <!--mod FNSI-画面部品デザイン じょはく end-->
          <!-- 治療日のみ表示チェックボックス(TODO: 検査日のみの後日追加予定) -->
          <v-ons-row class="popover-content-row" align="top">
            <v-ons-col class="popover-content-col-left">
              <label class="popover-content-cond-label">治療日のみ表示</label>
            </v-ons-col>
            <v-ons-col class="flex-1">
              <label class="left">
                <v-ons-checkbox
                  v-model="isTreatmentOnly"
                  input-id="checkTreatmentOnly"
                />
              </label>
              <label for="checkTreatmentOnly" class="center"></label>
            </v-ons-col>
          </v-ons-row>
          <!-- 表示基準日 -->
          <v-ons-row class="popover-content-row" align="top">
            <v-ons-col class="popover-content-col-left">
              <label class="popover-content-cond-label">基準日</label>
            </v-ons-col>
            <v-ons-col>
              <!-- <custom-Input-Date :value="baseDay"> -->
              <!-- mod FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「初期表示」機能分 周 start -->
              <!-- <div class="flex-align-center">
                <input v-model="baseDay" type="date" class="ntss-input-date ntss-date-size" />
                <common-calendar v-model="baseDay" />
              </div> -->
              <div class="d-flex flex-column">
                <div class="flex-align-center">
                  <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 start -->
                  <!-- <input
                    class="ntss-input-date ntss-date-size"
                    id="baseDay"
                    name="baseDay"
                    type="date"
                    v-model="baseDay"
                    data-validation-scope="baseDayScope"
                    v-rules="'required|date_format:yyyy-MM-dd'"
                    /> -->
                    <date-input
                      v-model="baseDay"
                      id="baseDay"
                      name="baseDay"
                      :classes="'input-area ntss-input-date ntss-custom-input'"
                      data-validation-scope="baseDayScope"
                      isRequired
                    />
                    <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 end -->
                  <common-calendar v-model="baseDay" />
                </div>
                <span class="error-message">{{
                  getValidationError("baseDayScope.baseDay")
                }}</span>
              </div>
              <!-- mod FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「初期表示」機能分 周 end -->
            </v-ons-col>
          </v-ons-row>
          <!-- 表示期間ラジオボタン1 -->
          <v-ons-row class="popover-content-row" align="top">
            <v-ons-col class="popover-content-col-left">
              <label class="popover-content-cond-label">期間 / レイアウト</label>
            </v-ons-col>
            <v-ons-col class="flex-1">
              <!-- <custom-radio name="peripd" :value="selectedPeripd" :radio-value="1">3日分</custom-radio>
              <custom-radio name="peripd" :value="selectedPeripd" :radio-value="2">7日分</custom-radio>
              <custom-radio name="peripd" :value="selectedPeripd" :radio-value="3">14日分</custom-radio> -->
              <v-ons-row>
                <div style="white-space: nowrap; margin-right: 0.5em;">
                  <v-ons-radio
                    v-model="selectedPeriod"
                    :input-id="'rdoPeriod1'"
                    :value="'1'"
                    modifier="round"
                    class="popover-content-radio-pat"
                  />
                  <label :for="'rdoPeriod1'">3日分</label>
                </div>
                <div style="white-space: nowrap; margin-right: 0.5em;">
                  <v-ons-radio
                    v-model="selectedPeriod"
                    :input-id="'rdoPeriod2'"
                    :value="'2'"
                    modifier="round"
                    class="popover-content-radio-pat"
                  />
                  <label :for="'rdoPeriod2'">7日分</label>
                </div>
                <div style="white-space: nowrap;">
                  <v-ons-radio
                    v-model="selectedPeriod"
                    :input-id="'rdoPeriod3'"
                    :value="'3'"
                    modifier="round"
                    class="popover-content-radio-pat"
                  />
                  <label :for="'rdoPeriod3'">14日分</label>
                </div>
              </v-ons-row>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="popover-content-row">
            <v-ons-col class="popover-content-col-left">
              <label class="popover-content-cond-label"></label>
            </v-ons-col>
            <v-ons-col>
              <v-ons-select
                v-model="setSelectedLayoutCd"
                :disabled="!(3 >= selectedPeriod)"
                style="width: 100%"
              >
                <option
                  v-for="(layoutItem,
                  layoutIndex) in smallPeriodDispItemOptions"
                  id="selectDispLayoutItem"
                  :key="layoutIndex"
                  :value="layoutItem.layoutCd"
                >
                  {{ layoutItem.layoutName }}
                </option>
              </v-ons-select>
            </v-ons-col>
          </v-ons-row>
          <!-- 表示期間ラジオボタン2 -->
          <v-ons-row class="popover-content-row">
            <v-ons-col class="popover-content-col-left">
              <label class="popover-content-cond-label"></label>
            </v-ons-col>
            <v-ons-col>
              <v-ons-row>
                <div style="white-space: nowrap; margin-right: 0.5em;">
                  <v-ons-radio
                    v-model="selectedPeriod"
                    :input-id="'rdoPeriod4'"
                    :value="'4'"
                    modifier="round"
                    class="popover-content-radio-pat"
                  />
                  <label :for="'rdoPeriod4'">12週</label>
                </div>
                <div style="white-space: nowrap; margin-right: 0.5em;">
                  <v-ons-radio
                    v-model="selectedPeriod"
                    :input-id="'rdoPeriod5'"
                    :value="'5'"
                    modifier="round"
                    class="popover-content-radio-pat"
                  />
                  <label :for="'rdoPeriod5'">6ヶ月</label>
                </div>
                <div style="white-space: nowrap; margin-right: 0.5em;">
                  <v-ons-radio
                    v-model="selectedPeriod"
                    :input-id="'rdoPeriod6'"
                    :value="'6'"
                    modifier="round"
                    class="popover-content-radio-pat"
                  />
                  <label :for="'rdoPeriod6'">1年</label>
                </div>
                <div style="white-space: nowrap;">
                  <v-ons-radio
                    v-model="selectedPeriod"
                    :input-id="'rdoPeriod7'"
                    :value="'7'"
                    modifier="round"
                    class="popover-content-radio-pat"
                  />
                  <label :for="'rdoPeriod7'">3年</label>
                </div>
              </v-ons-row>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="popover-content-row">
            <v-ons-col class="popover-content-col-left">
              <label class="popover-content-cond-label"></label>
            </v-ons-col>
            <v-ons-col>
              <v-ons-select
                v-model="setSelectedLayoutCd"
                :disabled="!(selectedPeriod > 3)"
                style="width: 100%"
              >
                <option
                  v-for="(layoutItem,
                  layoutIndex) in largePeriodDispItemOptions"
                  id="selectDispLayoutItem"
                  :key="layoutIndex"
                  :value="layoutItem.layoutCd"
                >
                  {{ layoutItem.layoutName }}
                </option>
              </v-ons-select>
            </v-ons-col>
          </v-ons-row>

          <!-- 拡張表示 -->
          <v-ons-row class="popover-content-row" align="top">
            <v-ons-col class="popover-content-col-left">
              <label class="popover-content-cond-label">拡張表示</label>
            </v-ons-col>
            <v-ons-col>
              <label class="left">
                <v-ons-checkbox
                  v-model="isExtendedView"
                  input-id="checkExtendedView"
                />
              </label>
              <label for="checkExtendedView" class="center"></label>
            </v-ons-col>
          </v-ons-row>

          <!-- 指示/実績表示切替 -->
          <v-ons-row class="popover-content-row" align="top">
            <v-ons-col class="popover-content-col-left">
              <label class="popover-content-cond-label">指示 / 実績の表示</label>
            </v-ons-col>
            <v-ons-col style="display: flex; flex-wrap: wrap;">
              <label
                v-for="(data, index) in selectShowIndRstOptions"
                :key="index"
                style="white-space: nowrap; margin-right: 0.5em;"
              >
                <v-ons-radio
                  v-model="selectedShowIndRst"
                  :input-id="data.inputId"
                  :value="data.value"
                  modifier="round"
                />
                {{ data.label }}
                <br v-if="1 === index" />
              </label>
            </v-ons-col>
          </v-ons-row>

          <!-- 指示履歴 -->
          <v-ons-row class="popover-content-row" align="top">
            <v-ons-col class="popover-content-col-left">
              <label class="popover-content-cond-label">指示履歴</label>
            </v-ons-col>
            <v-ons-col>
              <v-ons-button
                class="common-style-select-button"
                @click="
                  showIndHistoryModal();
                  popoverVisible = false;
                "
              >
                表示
              </v-ons-button>
            </v-ons-col>
          </v-ons-row>
          <!-- add FNSI-242_投薬支援 徐 start -->
          <!-- 投薬支援-->
          <v-ons-row v-show="isShowAdvanceFlag" class="popover-content-row" align="top">
            <v-ons-col class="popover-content-col-left">
              <label class="popover-content-cond-label">投薬支援</label>
            </v-ons-col>
            <v-ons-col>
              <v-ons-button
                class="common-style-select-button"
                @click="
                  showIndSupportModal({ startDate: baseDay });
                  popoverVisible = false;
                "
              >
                表示
              </v-ons-button>
            </v-ons-col>
          </v-ons-row>
          <!-- add FNSI-242_投薬支援 徐 end -->
          <!-- クリア、OKボタン -->
          <div class="popover-content-footer">
            <div class="popover-content-footer-left">
              <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
              <!-- <v-ons-button class="clear" @click="clearDispSetting">
                クリア
              </v-ons-button> -->
              <v-ons-button class="btn2-cancel width-padding" @click="clearDispSetting">
                クリア
              </v-ons-button>
              <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
            </div>
            <div class="popover-content-footer-right">
              <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
              <!-- mod FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「初期表示」機能分 周 start -->
              <!-- <v-ons-button class="ok" @click="setDispSetting">OK</v-ons-button> -->
              <!-- <v-ons-button class="ok" :disabled="!canSave" @click="setDispSetting">OK</v-ons-button> -->
              <!-- mod FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「初期表示」機能分 周 end -->
              <v-ons-button class="btn3-normal width-padding" :disabled="!canSave" @click="setDispSetting">OK</v-ons-button>
              <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
            </div>
          </div>
        </div>
      </v-ons-popover>

      <!-- ポップオーバー関連 -->

      <treat-plan-menu />

      <div v-if="messageDialogInfo.isDialogVisible">
        <message-dialog
          v-model:visible="messageDialogInfo.isDialogVisible"
          :message-cd="messageDialogInfo.messageCd"
          :type="messageDialogInfo.type"
          :string-params="messageDialogInfo.stringParams"
          @confirm="hideMessageDialog"
        />
      </div>

      <message-dialog
        :visible="isDieMessage"
        :message-cd="12010003"
        type="1"
        @confirm="hideDieMessage"
      />
    </div>
  </div>
</template>

<script>
/**
 * Vue関連
 */
import { mapActions, mapGetters, mapMutations } from "@/compat/vue/vuex";

/**
 * 外部ライブラリ関連
 */
// 日付操作
import dayjs from "@/compat/date/dayjs";

/**
 * ポップオーバー関連
 */
import TreatPlanMenu from "@/components/pat-viewer/pop-over/TreatPlanMenu";

/**
 * 患者経過総合ビューア表示項目関連
 */
 import treatmentContents from "@/components/pat-viewer/contents/PatViewerTreatmentContents";

// 検査予定・結果
import ExamInfo from "@/components/pat-viewer/contents/treatment/ExamInfo";

// 一般撮影検査予定
import RadInfo from "@/components/pat-viewer/contents/treatment/RadInfo";

// 観察記録
import ObserInfo from "@/components/pat-viewer/contents/treatment/ObserInfo";

// 紹介状
import LetterInfo from "@/components/pat-viewer/contents/treatment/LetterInfo";

// 患者イベント（仮）
import PatientInfo from "@/components/pat-viewer/contents/treatment/PatientInfo";
import Prescription from "@/components/pat-viewer/contents/treatment/Prescription";
/**
 * バイタル
 */
import Vital from "@/components/pat-viewer/contents/treatment/Vital";
/**
 * 体重情報
 */
import Weight from "@/components/pat-viewer/contents/treatment/Weight";
/**
 * 検査結果
 */
import ExamResult from "@/components/pat-viewer/contents/treatment/ExamResult";
/**
 * 薬剤グラフ
 */
import DrugComponent from "@/components/pat-viewer/contents/treatment/DrugComponent";
/**
 * 複合グラフ
 */
import ComprehensiveComponent from "@/components/pat-viewer/contents/treatment/ComprehensiveComponent";

/**
 * 薬剤、医療材料集計
 */
import Aggregate from "@/components/pat-viewer/contents/treatment/Aggregate";
import TreatmentRecordSummary from "@/components/pat-viewer/contents/treatment/TreatmentRecordSummary";
import Complaint from "@/components/pat-viewer/contents/treatment/Complaint";

/**
 * jQuery
 */

import _ from "@/compat/collections/lodash";

/**
 * 共通操作
 */
import { deepCopy, getHolidayStyle } from "@/functions/common/CommonFunctions";

import { ApiHelper } from "@/apis/AxiosHelper";
import { sendRequestPostTreatDateList } from "@/apis/ord-main";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import { EventBus } from "@/compat/vue/event-bus.js";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
import PopoverMixin from "@/components/PopoverMixin";
import { KEY_NAME_PAT_VIEWER } from "@/constants/defaultSettingConstants";
// add 画面印刷プレビューと印刷の実現 黄 start
import { getCurrentFunctionCd } from "@/router/routing-helper";
// add 画面印刷プレビューと印刷の実現 黄 end
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
import { getMstInfo } from "@/apis/mst-info.js";
import DateInput from "@/components/common/DateInput.vue";
import PrintMixin from "@/components/PrintMixin";
import asset0Img from "../../assets/0.png";
import asset1Img from "../../assets/1.png";
import asset3Img from "../../assets/3.png";
import asset4Img from "../../assets/4.png";
import asset6Img from "../../assets/6.png";
import { getLatestHeaderElement, getHeaderHeight, getFooterMenuClientHeight, getScopedElementById, getScopedElementsByClassName, getScopedJQuery } from "@/functions/common/LayoutMeasureHelper";

/**
 * 曜日の日本語化
 */
dayjs.updateLocale("ja", {
  weekdays: [
    "日曜日",
    "月曜日",
    "火曜日",
    "水曜日",
    "木曜日",
    "金曜日",
    "土曜日"
  ],
  weekdaysShort: ["日", "月", "火", "水", "木", "金", "土"]
});

// 治療予定メニュー情報
const defaultMenuInfo = {
  isShowCreate: false,
  isShowCopy: false,
  isShowMove: false,
  isShowDelete: false,
  isShowWeekPattern: false,
  isShowRst: false,
  target: null,
  direction: null,
  ordNo: null,
  treatDate: "",
  dialysisState: null,
  isOneDay: true
};

export default {
  mixins: [PopoverMixin, PrintMixin],
  components: {
    "common-calendar": commonCalender,
    "date-input": DateInput,
    /**
     * ポップオーバー関連
     */
    // 治療予定メニュー
    "treat-plan-menu": TreatPlanMenu,
    /**
     * 患者経過総合ビューア表示項目関連
     */
     "treatment-contents": treatmentContents,
    // 検査依頼・結果
    "exam-info": ExamInfo,
    // 放射線検査依頼
    "rad-info": RadInfo,
    // 観察記録
    "obser": ObserInfo,
    // 紹介状
    "letter": LetterInfo,
    // 患者イベント（仮）
    "patient": PatientInfo,
    "prescription": Prescription,
    /**
     * バイタル
     */
    vital: Vital,
    /**
     * 体重情報
     */
    weight: Weight,
    /**
     * 検査結果
     */
    "exam-result": ExamResult,
    /**
     * 薬剤グラフ
     */
    "drug-graph": DrugComponent,
    /**
     * 複合グラフ
     */
    "comprehensive": ComprehensiveComponent,
    /**
     * 薬剤集計
     */
    drugAggregate: Aggregate,
    /**
     * 医療材料集計
     */
    medical: Aggregate,
    /**
     * ダイアライザ集計
     */
    dialyzer: Aggregate,
    treatment: TreatmentRecordSummary,
    complaint: Complaint,
    /**
     * メッセージダイアログ
     */
    "message-dialog": messageDialog
  },

  data() {
    return {
      popoverKey: 0,
      selectedDay: -1,

      /**
       * ポップオーバー表示関連
       */
      popoverTarget: null,
      popoverDirection: "down",
      popoverCoverTarget: false,
      popoverVisible: false,
      popoverVisible1: false,
      popoverDirection1: "down",
      popoverTarget1: null,
      popoverCoverTarget1: false,

      /**
       * 表示条件(治療日のみ表示 選択値)
       */
      isTreatmentOnly: false,

      // add bug 7872 修正 chen start
      isDisflg:false,
      // add bug 7872 修正 chen end

      /**
       * 表示条件(期間 選択値)
       */
      selectedPeriod: null,

      /**
       * 表示条件(表示レイアウト 選択値)
       */
      selectedLayoutCd: null,

      /**
       * コンポーネント設定用表示条件
       */
      setSelectedLayoutCd: null,

      /**
       * 表示条件(基準日 選択値)
       */
      baseDay: null,

      /**
       * 表示対象基準日(基準日:検索結果より設定値)
       */
      dispBaseDay: null,

      /**
       * 表示開始日
       */
      startDay: null,

      /**
       * 表示終了日
       */
      endDay: null,

      /**
       *  指示・実績表示選択区分
       */
      selectedShowIndRst: "2",
      /**
       * 指示・実績表示選択リスト
       */
      selectShowIndRstOptions: [
        { label: "指示のみ", value: "1", inputId: "indRst1" },
        { label: "実績優先", value: "2", inputId: "indRst2" },
        { label: "実績指示併記", value: "3", inputId: "indRst3" }
      ],

      /**
       *  メッセージダイアログ格納項目
       */
      messageDialogInfo: {
        isDialogVisible: false,
        messageCd: "",
        type: "1",
        stringParams: [""]
      },

      /**
       * ポップアップ管理用-表示条件パラメータ一覧
       */
      isPopExtendedView: false,
      isPopTrentmentOnly: false,
      popSelectedPeriod: null,
      popBaseDay: null,
      popSelectedShowIndRst: null,

      /**
       * スクロール量
       */
      scrollPos: 0,
      /**
       * 指定位置情報
       */
      specifiedPos: {},
      /**
       * 表示レイアウト項目
       */
      dispLayoutItem: [],
      /**
       * 表示条件(期間 OKしてから値)
       */
      currentSelectedPeriod: null,

      /**
       * <<ボタン押下時ワーニングフラグ（警告ダイアログ表示用）
       */
      prevWarningFlg: false,

      /**
       * >>ボタン押下時ワーニングフラグ（警告ダイアログ表示用）
       */
      nextWarningFlg: false,

      /**
       * 拡張表示
       */
      isExtendedView: false,

      patInfo: null,
      // 死亡日※メッセージ表示用
      dieInfo: { is_die: "0", die_date: null },
      dialysisStateArray: [],
      listChartComponents: [],
      selectedLayoutCdByPeriodType: {
        small: null,
        large: null
      },
      contentHeight: 700,
      contentWidth: 800,
      // add FNSI-3922 投薬指示機能が施設拡張設定のON\OFF制御に反映していない liumx start
      isShowAdvanceFlag: false,
       // add FNSI-3922 投薬指示機能が施設拡張設定のON\OFF制御に反映していない liumx end
      selfScreenName: "",
      // #9713 グラフの描画が遅い/共通ローダーが消えるのが早い linjunfeng start
      chartLoadingCount: 0,
      // #9713 グラフの描画が遅い/共通ローダーが消えるのが早い linjunfeng end
      isShowComponents: new Set(),
      dataReady: false,
      printTargetClass: ["list-content"],
      chartRenderedCount: 0,
      totalChartsExpected: 0,
      chartRenderResolve: null,
    };
  },

  computed: {
    ...mapGetters("loading-screen", ["getLoadingScreenLocked"]),
    ...mapGetters("pat-viewer", [
      "getDateList",
      "getDialysisStateArray",
      "getDispLayoutItemListData",
      "getTreatmentData",
      "getTreatBaseDate",
      "getSelectedCondition",
    ]),
    ...mapGetters("pat-viewer", {
      isDieMessage: "getIsDieMessage"
    }),

    ...mapGetters("pat-info", ["selectedPat", "selectedPatId"]),
    ...mapGetters("pat-info", {
      patId: "selectedPatId"
    }),

    //施設コード取得用
    ...mapGetters("user", ["getFacilityCd"]),

    ...mapGetters("pat-viewer-modal", {
      getDefaultSettingIndPlanCreateNewData:
        "getDefaultSettingIndPlanCreateNewData",
      isShowIndModal: "getIsShowIndModal",
      isShowPlanCopy: "getIsShowPlanCopyModal",
      isShowPlanMove: "getIsShowPlanMoveModal",
      isShowWeekPattern: "getIsShowWeekPatternModal",
      isShowIndMedicineCreateModal: "getIsShowMediCreateModal",
      isShowIndMedicineEditModal: "getIsShowMediEditModal",
      isShowUfrProgramModal: "getIsShowUfrProgramModal",
      isShowNaProgramModal: "getIsShowNaProgramModal",
      isShowDialysateProgramModal: "getIsShowDialysateProgramModal",
      isShowQbqdProgramModal: "getIsShowQbqdProgramModal",
      isShowIHdfProgramModal: "getIsShowIHdfProgramModal",
      isShowDiaysisProgramModal: "getIsShowDiaysisProgramModal",
      isShowBvUfcModal: "getIsShowBvUfcModal",
      isShowDwModal: "getIsShowDwModal",
      settingIndData: "getSettingIndData",
      isShowMessage: "getIsShowMessageDialog"
    }),

    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth",
      sidebarWidth: "getSidebarWidth"
    }),

    ...mapGetters("account-edit", {
      getFontSize: "getFontSize",
      getDefaultSetting: "getDefaultSetting",
      getPatientShareMode: "getPatientShareMode",
      getPatientShareFacilityCdMode: "getPatientShareFacilityCdMode"
    }),

    facilityCd() {
      return this.getFacilityCd;
    },

    /**
     * 一覧に表示するデータのリスト
     */
    dateList() {
      return this.getDateList;
    },

    /**
     * 表示条件ポップオーバーの表示レイアウト一覧
     */
    dispLayoutItemList() {
      return this.getDispLayoutItemListData;
    },

    treatmentClassType() {
      const dbValue = JSON.parse(
        this.selectedPat.pat_main.acceptance_status_info
      );
      // 治療種類
      return dbValue.class;
    },

    /**
     * 選択患者経過総合ビューアレイアウトマスタ情報
     */
    selectedLayout() {
      const layout = this.getDispLayoutItemListData.find(ele => {
        return Number(this.selectedLayoutCd) === Number(ele.layoutCd);
      });
      if (!layout) {
        return [];
      }
      return layout.dispItemInfo;
    },

    /**
     * 項目列の上段に表示する日付
     */
    getTitleDay() {
      // 表示開始日の年
      const yearStart = dayjs(this.startDay).year();
      // 表示終了日の年
      const yearEnd = dayjs(this.endDay).year();
      // 表示開始日の月
      const monthStart = dayjs(this.startDay).month() + 1;
      // 表示終了日の月
      const monthEnd = dayjs(this.endDay).month() + 1;

      // 表示開始年月の文字列
      let label = `${yearStart}.${monthStart}`;

      // 表示開始・終了の年、または、月が異なる場合は表示文字の作成
      if (yearStart !== yearEnd || monthStart !== monthEnd) {
        label +=
          yearStart !== yearEnd
            ? ` ～ ${yearEnd}.${monthEnd}`
            : monthStart !== monthEnd
            ? ` ～ ${monthEnd}`
            : "";
      }

      return label;
    },
    isPatSelected() {
      return this.selectedPat !== null;
    },
    // add FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「初期表示」機能分 周 start
    /**
     * OKボタンがクリックできるかどうか.
     */
    canSave() {
      return this.validationErrors.length === 0;
    },
    // add FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「初期表示」機能分 周 end
    /**
     * 治療予定モーダル(新規登録時)に渡すデータ(雛型)
     */
    defaultSettingIndPlanCreateNewData() {
      return this.getDefaultSettingIndPlanCreateNewData;
    },

    /**
     * ordMain情報
     */
    ordMainData() {
      return this.getTreatmentData;
    },

    /**
     * 治療状況リスト
     */
    treatStatusList() {
      const dateArr = [];
      // 表示中の治療日でループ
      this.dateList.forEach(date => {
        // 治療状況リスト
        let treatStatusArray = [];
        // 治療予定数
        let planAmount = 0;
        let arrState = [];
        let treatDateArr = [];
        // 表示中の治療日に格納されている治療情報でループ
        this.ordMainData.forEach(item => {
          for (const itemDate in item) {
            // 治療日リストと治療情報リストの日付が一致した場合以下の処理
            if (itemDate === date) {
              // 治療情報リストに治療予定がある場合は以下の処理
              if (null !== item[itemDate]) {
                planAmount++;
                arrState.push(item[itemDate].rstDialysisState);
                // 治療予定数が4つ以下の場合
                if (4 >= planAmount) {
                  //mod 7680 治療の進捗状態を示す棒グラフが一致しない_再発 張 start
                  // treatDateArr.push({"rstDialysisState": item[itemDate].rstDialysisState, "treatDate": item[itemDate].treatDate, "indTreatStartTime": item[itemDate].indTreatStartTime,  "indCondInfo": JSON.parse(item[itemDate].indCondInfo)});
                  treatDateArr.push({"rstDialysisState": item[itemDate].rstDialysisState, "treatDate": item[itemDate].treatDate, "indTreatStartTime": item[itemDate].indTreatStartTime,  "indCondInfo": JSON.parse(item[itemDate].indCondInfo), "rstStartDate" : item[itemDate].rstStartDate});
                  //mod 7680 治療の進捗状態を示す棒グラフが一致しない_再発 張 end
                  treatStatusArray.push({
                    status: item[itemDate].rstDialysisState,
                    treatDate: [...treatDateArr],
                    dispCount: null,
                  });
                } else {
                  treatStatusArray = [];
                  //mod 7680 治療の進捗状態を示す棒グラフが一致しない_再発 張 start
                  treatDateArr.push({"rstDialysisState": item[itemDate].rstDialysisState, "treatDate": item[itemDate].treatDate, "indTreatStartTime": item[itemDate].indTreatStartTime,  "indCondInfo": JSON.parse(item[itemDate].indCondInfo)});
                  treatDateArr.push({"rstDialysisState": item[itemDate].rstDialysisState, "treatDate": item[itemDate].treatDate, "indTreatStartTime": item[itemDate].indTreatStartTime,  "indCondInfo": JSON.parse(item[itemDate].indCondInfo), "rstStartDate" : item[itemDate].rstStartDate});
                  //mod 7680 治療の進捗状態を示す棒グラフが一致しない_再発 張 end
                  treatStatusArray.push({
                    dispCount: planAmount,
                    status: [...arrState],
                    treatDate: [...treatDateArr]
                  });
                }
              }
            }
          }
        });
        dateArr.push(treatStatusArray);
      });
      return dateArr;
    },

    /**
     * 3日・7日・14日選択時のレイアウト選択肢リスト
     */
    smallPeriodDispItemOptions() {
      return 3 >= this.selectedPeriod ? this.dispLayoutItem : [];
    },

    /**
     * 12週・6ヶ月・1年・3年選択時のレイアウト選択肢リスト
     */
    largePeriodDispItemOptions() {
      return this.selectedPeriod > 3 ? this.dispLayoutItem : [];
    },

    /**
     * @description 治療時間スタイル
     * @returns
     */

    arrayDialysisState() {
      return this.getDialysisStateArray;
    },
    //mod FutreNetWeb+SI課題管理 no.5921 劉全航 start
    contentClass(){
      if(JSON.stringify(this.getDefaultSetting) !== '{}'){
        if(this.getDefaultSetting["pat-viewer"]){
          if(this.getDefaultSetting["pat-viewer"].isExtendedView){
            if(this.getSelectedCondition){
              if(this.getSelectedCondition.isExtendedView){
                return "min-width:" + (this.contentWidth*2) + "px;width:200%;";
              }else{
                return "min-width:" + this.contentWidth+"px;";
              }
            }else{
              return "min-width:" + (this.contentWidth*2) + "px;width:200%;";
            }
          }
          if(!this.getDefaultSetting["pat-viewer"].isExtendedView) {
            if(this.getSelectedCondition && this.getSelectedCondition.isExtendedView){
              return "min-width:" + (this.contentWidth*2) + "px;width:200%;";
            }
            return "min-width:" + this.contentWidth+"px;";
          }
        }else{
          if(this.getSelectedCondition){
            if(this.getSelectedCondition.isExtendedView){
              return "min-width:" + (this.contentWidth*2) + "px;width:200%;";
            }else{
              return "min-width:" + this.contentWidth+"px;";
            }
          }else{
            return "min-width:" + this.contentWidth+"px;";
          }
        }
      }else{
          if(this.getSelectedCondition){
            if(this.getSelectedCondition.isExtendedView){
              return "min-width:" + (this.contentWidth*2) + "px;width:200%;";
            }else{
              return "min-width:" + this.contentWidth+"px;";
            }
          }else{
            return "min-width:" + this.contentWidth+"px;";
          }
        }
    },
    //mod FutreNetWeb+SI課題管理 no.5921 劉全航 end
    allComponents () {
      return Object.keys(this.$options.components)
    },
  },
  watch: {
    getPatientShareMode() {
      if (!this.getPatientShareFacilityCdMode) {
        this.refresh();
      }
    },
    getPatientShareFacilityCdMode(newValue, oldValue) {
      if ((oldValue && !newValue) || (!oldValue && newValue)) {
        this.refresh();
      }
    },
    selectedPat: {
      handler(newVal) {
        // 選択患者変更時サイドバーを閉じる
        this.isSideBarVisble = false;

        // 患者名の文字数により文字サイズを変更する
        const nameArea = getScopedElementById("pat-header-pat-name", this.$el || null);
        if (!nameArea || newVal === null || nameArea.classList.contains("pat-create")) {
          if (nameArea) {
            nameArea.style.fontSize = "";
          }
           //mod FNSI-6904 劉全航 start
          if(this.isTreatmentOnly
            ||this.baseDay
            ||this.selectedPeriod
            ||this.setSelectedLayoutCd
            ||this.isExtendedView
            ||this.selectedShowIndRst){
            this.setDispSetting();
          }
          //mod FNSI-6904 劉全航 end
        }
      },
      deep: true
    },
    /**
     * 患者選択/切替時
     */
    async patId(value) {
      if (null !== value) {
        // 画面更新処理
        await this.refresh(true);
        const patInfo = await this.getPatInfo();
        this.dieInfo = this.getDieInfo(patInfo);
        this.setIsDie(this.dieInfo.is_die === "1");
        this.calculateGridSize();
      }
    },

    // add FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「初期表示」機能分 周 start
    "baseDay": {
      handler() {
        setTimeout(() => {
          this.validateField("baseDayScope.baseDay");
        }, 0);
      }
    },
    // add FNSI-横展開 日付のチェックの追加対応_患者経過総合ビューア「初期表示」機能分 周 end

    /**
     * 期間選択時
     */
    selectedPeriod:{
      handler(value) {
      // 表示項目リストの設定
      this.setDispItemList(value);
      },
      immediate: true
    },

    isShowIndModal(isShow) {
      if (isShow) {
        this.showIndEditModal(this.settingIndData.headerTitle);
      }
    },

    isShowPlanCopy(isShow) {
      if (isShow) {
        this.showIndEditModal("予定コピー");
      }
    },

    isShowPlanMove(isShow) {
      if (isShow) {
        this.showIndEditModal("予定移動");
      }
    },

    isShowWeekPattern(isShow) {
      if (isShow) {
        this.showIndEditModal("曜日パターン変更");
      }
    },

    isShowIndMedicineCreateModal(isShow) {
      if (isShow) {
        this.showIndEditModal(this.settingIndData.headerTitle);
      }
    },

    isShowIndMedicineEditModal(isShow) {
      if (isShow) {
        this.showIndEditModal(this.settingIndData.headerTitle);
      }
    },

    isShowUfrProgramModal(isShow) {
      if (isShow) {
        this.showIndEditModal(this.settingIndData.headerTitle);
      }
    },

    isShowNaProgramModal(isShow) {
      if (isShow) {
        this.showIndEditModal(this.settingIndData.headerTitle);
      }
    },

    isShowDialysateProgramModal(isShow) {
      if (isShow) {
        this.showIndEditModal(this.settingIndData.headerTitle);
      }
    },

    isShowQbqdProgramModal(isShow) {
      if (isShow) {
        this.showIndEditModal(this.settingIndData.headerTitle);
      }
    },

    isShowIHdfProgramModal(isShow) {
      if (isShow) {
        this.showIndEditModal(this.settingIndData.headerTitle);
      }
    },

    isShowDiaysisProgramModal(isShow) {
      if (isShow) {
        this.showIndEditModal(this.settingIndData.headerTitle);
      }
    },

    isShowBvUfcModal(isShow) {
      if (isShow) {
        this.showIndEditModal(this.settingIndData.headerTitle);
      }
    },
    isShowDwModal(isShow) {
      if (isShow) {
        this.showIndEditModal(this.settingIndData.headerTitle);
      }
    },

    isShowMessage(isVisible) {
      if (isVisible) {
        this.messageDialogInfo.isDialogVisible = true;
        this.messageDialogInfo.messageCd = 22010003;
        this.messageDialogInfo.type = "1";
      }
    },

    getTreatBaseDate(newBaseDate) {
      // ストアに格納されている治療日(基準日を取得)
      if (this.getTreatBaseDate) {
        this.setBaseDayByTreatBaseDate();
        this.$nextTick(() => {
          // setBaseDayByTreatBaseDate で selectedPeriod や
          // setSelectedLayoutCd が切り替わった場合にも
          // （watch:getTreatBaseDate での setDispItemList など）
          // そのリアクションが終わってから
          // setDispSetting が実行されるようにする
          this.setDispSetting();
        });
      }
    },

    selectedLayout(layout) {
      const components = new Set();
      layout.forEach((item) => {
        components.add(item.component);
        item.categoryItem?.forEach((i) => {
          components.add(i.component);
        })
      });
      this.isShowComponents = components;
      this.setSelectedLayout(layout);
    },

    setSelectedLayoutCd(selectedLayoutCd) {
      const periodType = +this.selectedPeriod < 4 ? "small" : "large";
      this.selectedLayoutCdByPeriodType[periodType] = selectedLayoutCd;
    },
    windowHeight(){
      this.calculateGridSize();
    },
    windowWidth(){
      this.calculateGridSize();
    },
    sidebarWidth(){
      this.calculateGridSize();
    },
    getFontSize() {
      this.calculateGridSize();
    }
  },
  async created() {
    // 画面名称取得
    this.selfScreenName = this.$route.name;
    this.resetLoadingScreenVisibleCount();
    this.startLoadingScreen();
    this.lockLoadingScreen();
    this.setPatIdKeep("");
    this.isDisflg = false;
    if (this.isPatSelected) {
      // 再描画時(別のヘッダが表示された後の再表示)はそれまで選択されていた患者をストアに格納(最新の状態にするため)
      // ※体重計画面の場合は初期化状態から始まるため行わない
      this.selectPat(this.patId);
    }

    // 表示期間デフォルトを7日間を格納する
    this.selectedPeriod = "2";

    if (this.getSelectedCondition) {
      this.baseDay = this.getSelectedCondition.baseDay;
      this.isTreatmentOnly = this.getSelectedCondition.isTreatmentOnly;
      this.selectedPeriod = this.getSelectedCondition.selectedPeriod;
      this.isExtendedView = this.getSelectedCondition.isExtendedView;
      this.selectedShowIndRst = this.getSelectedCondition.selectedShowIndRst;
      this.setSelectedLayoutCd = this.getSelectedCondition.setSelectedLayoutCd;
      this.currentSelectedPeriod = this.selectedPeriod;
    } else {
      // デフォルト設定を store から取得
      const defaultCondition = deepCopy(this.getDefaultSetting[KEY_NAME_PAT_VIEWER.KEY_NAME]);
      if (!(!defaultCondition || Object.keys(defaultCondition).length === 0)) {
        this.isTreatmentOnly = defaultCondition[KEY_NAME_PAT_VIEWER.KEY_NAME_TREAT_ONLY];
        this.selectedPeriod = defaultCondition[KEY_NAME_PAT_VIEWER.KEY_NAME_SELECTED_PERIOD];
        this.isExtendedView = defaultCondition[KEY_NAME_PAT_VIEWER.KEY_NAME_EXTENDED_VIEW];
        this.selectedShowIndRst = defaultCondition[KEY_NAME_PAT_VIEWER.KEY_NAME_SELECTED_SHOW_INDRST];
        this.setSelectedLayoutCd = defaultCondition[KEY_NAME_PAT_VIEWER.KEY_NAME_SELECTED_LAYOUT_CD];
        this.currentSelectedPeriod = defaultCondition[KEY_NAME_PAT_VIEWER.KEY_NAME_SELECTED_PERIOD];
      }
    }
    var periodType = this.selectedPeriod < 4 ? "small" : "large";
    this.selectedLayoutCdByPeriodType[periodType] = this.setSelectedLayoutCd;
    if (this.$route.params.startDate != null && this.$route.params.startDate != undefined) {
      this.baseDay = dayjs(this.$route.params.startDate).format("YYYY-MM-DD");
    }

    // ストアに格納されている治療日(基準日を取得)
    if (this.getTreatBaseDate) {
      this.setBaseDayByTreatBaseDate();
    }

    // 表示開始日・終了日の設定

    await this.setStartEndTime();

    // 基準日の格納
    this.setBaseDate({ baseDate: this.baseDay });

    // 画面表示枠サイズの設定
    this.setContentWidth();
    // 共通操作
    this.initProc();

    // モーダル表示フラグ等のリセット
    this.hideIndModal();
    this.commitIsShowTreatPlanMenuPopover(false);
    this.showMessageDialog({ isShowMessageDialog: false });

    this.getIsShowFlag();

    // 画面表示時検索条件初期値を保存
    this.setDialogToPopTemp();

    this.$nextTick(() => {
      // 拡張表示
      this.setExtendedView();
    });

    this.listChartComponents = [];
    if (this.patId !== null) {
      this.getPatInfo().then(patInfo => {
        this.dieInfo = this.getDieInfo(patInfo);
        this.setIsDie(this.dieInfo.is_die === "1");
      });
    }

    // add FNSI-予定内容遅延問題対応 李 start
    this.setIndPlanCreateDate([this.startDay, this.endDay]);
    // add FNSI-予定内容遅延問題対応 李 end

    // 休日マスタの休日を取得
    await this.fetchHolidays(this.getFacilityCd);

    await this.refresh();
    this.isDisflg = true;
    await this.$nextTick();
  },
  mounted() {
    EventBus.$on("isRefresh", this.refresh);
    EventBus.$on("setDispSetting", this.setDispSetting);
    EventBus.$on("refresh", this.refresh);
    EventBus.$on("isBedUnregist", this.showMessageBedUnregist);
    EventBus.$on("isDuplicated", this.showMessageDuplicated);
    EventBus.$on("reflowPatViewerCharts", this.reflowPatViewerCharts);
    EventBus.$on("requestReportParams", this.requestrReportParams);
    EventBus.$on("childCreated", this.setScrollPos);
    this.$nextTick(() => {
      this.calculateGridSize();
    });
  },
  beforeUnmount() {
    this.clearHolidays(); // storeの休日マスタをクリア
    // Vueインスタンス破棄前に表示データの初期化
    this.clearTreatmentData();
    this.setTreatBaseDate(null);
    // mod FNSI-パンくずリスト押下修正 楊 start
    // EventBus.$off("isRefresh");
    // EventBus.$off("isBedUnregist");
    // EventBus.$off("isDuplicated");
    // EventBus.$off("reflowPatViewerCharts");

    EventBus.$off("isRefresh", this.refresh);
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("setDispSetting", this.setDispSetting);
    EventBus.$off("isBedUnregist", this.showMessageBedUnregist);
    EventBus.$off("isDuplicated", this.showMessageDuplicated);
    EventBus.$off("reflowPatViewerCharts", this.reflowPatViewerCharts);
    // mod FNSI-パンくずリスト押下修正 楊 end

    // add 画面印刷プレビューと印刷の実現 黄 start
    // 印刷パラメータ要求
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // add 画面印刷プレビューと印刷の実現 黄 end
    EventBus.$off("childCreated", this.setScrollPos);

    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    ...mapActions("pat-viewer", [
      "setDateList",
      "setDialysisStateArray",
      "setIsTreatmentOnlyDateList",
      "clearTreatmentData",
      "getOrdMain",
      "getOrdMainOfIndMediInfo",
      "getOrdMainOfPeriod",
      "getDispLayoutItemList",
      "getMstDialyzerTabooAllergy",
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      "getMstDialyzerTabooAllergyDeleted",
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      "getMstMedicineTabooAllergy",
      "getMstMedicineAllergy",
      "getMstMedicineMixTabooAllergy",
      "getMstMedicineMixAllergyData",
      "getMstEquipmentTabooAllergy",
      "getMstEquipmentAllergy",
      "getBedAndMachine",
      "getPatExamMain",
      "getPatRadMain",
      "getPatRadMainLastDate",
      "getExamMainDataLastDate",
      "getPatEventData",
      "getPatientData",
      "getLetterData",
      "getPrescriptionData",
      "setShowIndRst",
      "setTreatBaseDate",
      "setIsDie",
      "setIsDieMessage",
      "setPatIdKeep",
      "setSelectedCondition",
      "setIndPlanCreateDate"
    ]),
    ...mapActions("pat-viewer-popover", [
      "setShowTreatPlanMenuPopover",
      "setTreatDate",
      "setCopyFlag"
    ]),
    ...mapActions("pat-viewer-modal", [
      "showIndModal",
      "setBaseDate",
      "setSettingIndData",
      "showMessageDialog",
      "hideIndModal"
    ]),
    ...mapMutations("pat-info", {
      setPat: "setSelectedPat",
      setIsLoadingPat: "setIsLoadingPat",
      setIsPatInfoVisible: "setIsPatInfoVisible",
      setIsNullPat: "setIsNullPat"
    }),
    ...mapActions("pat-info", ["selectPat"]),
    ...mapActions("multi-modal", ["showIndHistoryModal", "showIndEditModal", "showIndSupportModal"]),
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
      "resetLoadingScreenVisibleCount",
      "lockLoadingScreen",
      "unlockLoadingScreen"
    ]),
    ...mapMutations("pat-viewer", [
      "setSelectedLayout",
      "setMstTreatmentData",
      "setMstTreatmentDataIsDel",
      "setMstVaData",
      "setMstVaDelData",
      "setMstDialyzerData",
      "setMstDialyzerDelData",
      "setMstMedicineData",
      "setMstMedicineMixData",
      "setMstMedicineClassData",
      "setMstEquipmentData",
      "setMstEquipmentClassData",
      "setMstProcedureData",
      "setMstMedicateTimingData",
      "setMstMedicineSupportData",
      "setMstKurData",
      "setMstAllBed",
      "setTreatDateList"
    ]),
    ...mapMutations("pat-viewer-popover", ["commitIsShowTreatPlanMenuPopover"]),
    ...mapActions("mst-holiday", [
      "fetchHolidays",
      "clearHolidays"
    ]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
// add 9200 by kangjie 20230918 start
    async setStartEndTime(){
      if (!this.baseDay) {
        this.baseDay = dayjs().format("YYYY-MM-DD");
      }
      if (undefined !== this.patId && null !== this.patId) {
        // 治療日のみ表示
        //mod FNSI-6907 劉全航 start
        // if (this.isTreatmentOnly) {
        if (this.isTreatmentOnly && this.selectedPeriod <= 3) {
          //mod FNSI-6907 劉全航 end
         await this.setIsTreatmentOnlyStartEndDay();
        } else {
          // 表示開始日・終了日の設定
          this.setStartEndDay();
        }

        // 基準日の格納
        this.setBaseDate({ baseDate: this.baseDay });

        // 指示・実績表示切替の格納
        this.setShowIndRst(this.selectedShowIndRst);

        this.selectedLayoutCd = this.setSelectedLayoutCd;

      } else {
        // 表示開始日・終了日の設定
        this.setStartEndDay();
        // 基準日の格納
        this.setBaseDate({ baseDate: this.baseDay });
        // add FNSI-障害票一覧_患者経過総合ビューア_初期表示#1。 周 start
        // 指示・実績表示切替の格納
        this.setShowIndRst(this.selectedShowIndRst);
        // 表示レイアウトの格納
        this.selectedLayoutCd = this.setSelectedLayoutCd;
        // add FNSI-障害票一覧_患者経過総合ビューア_初期表示#1。 周 end
      }
    },
    // add 9200 by kangjie 20230918 end
    // add 画面印刷プレビューと印刷の実現 黄 start
    requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        // 機能一致

        // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
        var curDate = new Date();
        // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
        // 印刷パラメータを応答
        const param = {
          // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          //patId: this.selectedPat,
          // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
          //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
          functionCd:"00401",
          //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
          baseDate:dayjs(this.baseDay).format("YYYYMMDD"),
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          //date: dayjs(Date.now()).format("YYYY/MM/DD"),
          facilityCd: this.getFacilityCd,
          patId: this.patId,
          date: dayjs(Date.now()).format("YYYYMMDD"),
          fromDate: dayjs(Date.now()).format("YYYYMMDD"),
          toDate: dayjs(new Date(curDate.setMonth(curDate.getMonth() + 1))).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //dialysisDate: dayjs(this.baseDay).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
        };
        EventBus.$emit("sendReportParams", param);
      }
    },
    // add 画面印刷プレビューと印刷の実現 黄 end

    setBaseDayByTreatBaseDate() {
      // 基準日を設定
      this.baseDay = dayjs(this.getTreatBaseDate, "YYYYMMDD").format("YYYY-MM-DD");
      // 期間が長期の場合は短期の7日分に切り替えて
      // レイアウトはリスト最上部のものに設定する
      const isSelectedPeriodSmall = this.selectedPeriod < "4";
      if (!isSelectedPeriodSmall) {
        // selectedPeriod の変更により watch で
        // setDispItemList が実行される際に setSelectedLayoutCd が
        // 更新後の dispLayoutItem の先頭のものになるようにしておく
        this.selectedLayoutCdByPeriodType.small = null;
        this.setSelectedLayoutCd = null;
        this.currentSelectedPeriod = this.selectedPeriod = "2";
      }
      // 再度同じ日付が渡されても処理されるようにクリアしておく
      this.setTreatBaseDate(null);
    },

    /**
     * 項目作成の初期操作
     */
    async initProc() {
      this.startLoadingScreen();
      // 患者経過総合ビューアレイアウトマスタ取得
      await this.getDispLayoutItemList({
        facilityCd: this.facilityCd,
        selectedPatId: this.selectedPatId
      })
      .catch(
        error => {
          getErrorMessage('PatViewer.vue', 'initProc', error);
          // 共通ローダー：表示終了
          throw error;
        }
      ).finally(() => {
        this.finishLoadingScreen();
      });
      // 取得したレイアウトが0の場合処理終了
      if (0 !== this.dispLayoutItemList.length) {
        // 選択された期間から項目候補を設定
        this.setDispItemList();
        this.selectedLayoutCd = this.setSelectedLayoutCd;
      }

      this.calculateGridSize();
    },

    async setSelectedPat(selectedPatId) {
      this.setIsNullPat(false);
      this.setIsLoadingPat(true);
      this.setPat(null);
      // オーダ番号をクリア
      this.setOrdNo(null);
      if (selectedPatId === null) {
        this.setIsNullPat(true);
        // 現在の表示画面が治療状況リストの場合、治療状況を再読み込みさせる
        if (this.$route.name.indexOf("treatment-record") === 0) {
          EventBus.$emit("refresh");
        }
      } else {
        await this.selectPat(selectedPatId).catch(() => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('PatViewer.vue', 'setSelectedPat', "[PatHeader.vue]setSelectedPat(): 患者選択失敗");
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          // 共通ローダー：表示終了
          // TODO: エラー処理ちゃんと考える
          throw new Error("[PatHeader.vue]setSelectedPat(): 患者選択失敗");
        });
      }
      this.setIsLoadingPat(false);
    },

    /**
     * マスタ情報を取得
     * TODO: ここで全てのマスタを取得すると、遅延の原因となる可能性があるため、別途取得方法の検討が必要
     */
    getMst() { // refresh
      return new Promise((resolve) => {
        const reqMstNamesArr = [
          "mstTreatment", "mstTreatmentDeleted", "mstVa", "mstVaDeleted",
          "mstDialyze", "mstDialyzeDeleted", "mstMedicine", "mstMedicineMix",
          "mstMedicineClass", "mstEquipment", "mstEquipmentClass", "mstProcedure",
          "mstMedicateTiming", "mntMedicineSupport", "mstKur", "mstBed"
        ];

        Promise.all([
          getMstInfo({ reqMstNamesArr: reqMstNamesArr, selectedPatId: this.selectedPatId }),
          this.getBedAndMachine({ facilityCd: this.facilityCd, selectedPatId: this.selectedPatId }),
        this.getMstDialyzerTabooAllergy({ patId: this.patId }), // TreatCond.vue mstClass: 13; findConvertData.itemNo: 5; convertEquipmentData
          // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          this.getMstDialyzerTabooAllergyDeleted({ patId: this.patId}),
          // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
          this.getMstMedicineTabooAllergy({ patId: this.patId }), // mstClass: 10 11;findConvertData.itemNo: 25; Medicine.vue;Equipment.vue
          this.getMstMedicineAllergy({ patId: this.patId, is_Del_Flg: true }),
          this.getMstMedicineMixTabooAllergy({ patId: this.patId }),
          this.getMstMedicineMixAllergyData({ patId: this.patId, isDelFlg: true }),
          this.getMstEquipmentTabooAllergy({ patId: this.patId }),
          this.getMstEquipmentAllergy({ patId: this.patId, isDelFlg: true })
        ]).then((responseArr) => {
          if (responseArr[0].status === 200) {
            const data = responseArr[0].data;
            this.setMstTreatmentData(data?.mstTreatment || []); // 治療方法マスタデータを設定
            this.setMstTreatmentDataIsDel(data?.mstTreatmentDeleted || []); // 治療方法マスタ削除データを設定
            this.setMstVaData(data?.mstVa || []); // VAマスタデータ
            this.setMstVaDelData(data?.mstVaDeleted || []); // VAマスタデータを設定(削除されたを含む)
            this.setMstDialyzerData(data?.mstDialyze || []); // ダイアライザマスタデータを設定
            this.setMstDialyzerDelData(data?.mstDialyzeDeleted || []); // ダイアライザマスタデータを設定(削除されたを含む)
            this.setMstMedicineData(data?.mstMedicine || []); // 薬剤マスタデータを設定
            this.setMstMedicineMixData(data?.mstMedicineMix) // 調製薬剤マスタデータを設定
            this.setMstMedicineClassData(data?.mstMedicineClass) // 薬剤分類マスタを取得
            this.setMstEquipmentData(data?.mstEquipment || []); // 医療材料マスタデータを設定
            this.setMstEquipmentClassData(data?.mstEquipmentClass || []); // 医療材料分類マスタデータを設定
            this.setMstProcedureData(data?.mstProcedure || []); // 手技マスタデータを設定
            this.setMstMedicateTimingData(data?.mstMedicateTiming || []); // 投与タイミングマスタデータを設定
            this.setMstMedicineSupportData(data?.mntMedicineSupport || []); // 投薬支援マスタを取得
            this.setMstKurData(data?.mstKur || []); // クールマスタデータを設定
            this.setMstAllBed(data?.mstBed || []); // ベッドマスタデータを設定
            resolve(true);
          }
        }).catch(err => {
          getErrorMessage('PatViewer.vue', 'getMst', err);
          reject(err);
        });
      });
    },
    /**
     * 9200
     * 投与薬剤情報(ord_main)を取得
     * @returns {Promise<void>}
     */
    async setIndMediInfoData() {
      this.startLoadingScreen();
      const patShareMode = this.getPatientShareMode == 0 && !this.getPatientShareFacilityCdMode ? 0 : 1;
      await this.getOrdMainOfIndMediInfo(
          {
            facilityCd: this.facilityCd,
            patId: this.patId,
            // ページに表示された最後の日付です
            startTime: this.endDay,
            patShareMode
          }
      )
      .catch(err =>{
        getErrorMessage('PatViewer.vue', 'setIndMediInfoData', err);
      })
      .finally(() => {
        this.finishLoadingScreen();
      });
    },
    /**
     * 治療情報(ord_main)を取得(一部データを加工)
     */
    async setTreatmentData() {
      this.startLoadingScreen();
      return await this.getOrdMain({
        facilityCd: this.facilityCd,
        patId: this.patId,
        startDay: this.startDay,
        // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
        // endDay: this.endDay,
        endDay: "9999-12-24",
        // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
        weekPattern: `[{ 'text': '全', 'done': true, 'value': 0 }]`,
        selectedPatId: this.selectedPatId
      }).then(async() => {
        const includes = (components) => {
          return components.some((item) => {
            return this.isShowComponents.has(item);
          });
        };
        return includes(['vital', 'weight', 'comprehensive', 'complaint', 'treatment'])
          && await this.getTreatDateList().then((res) => {
          return res;
        });
      }).catch(err => {
        getErrorMessage('PatViewer.vue', 'setTreatmentData', err);
        // TODO: メッセージボックスへ変更すること
        alert(err);
      }).finally(() => {
        this.finishLoadingScreen();
      });
    },
    //内部remine 5840  add ljx start
    /**
     * 治療情報(ord_main)を取得(一部データを加工)
     */
    async setTreatmentDataOfPeriod() {
      this.startLoadingScreen();
      try {
        const patId = this.patId;
        const facilityCd = this.facilityCd;
        const response = await ApiHelper.get(
          "mainData/changeDay/maxTreatmentDate",
          { patId, facilityCd }
        );
        if (!response?.data) {
          return;
        }
        const startDateYMD = dayjs(this.indTreatStartDate).format("YYYYMMDD");
        const endDateYMD = response.data;
        if (!startDateYMD || !endDateYMD) {
          return;
        }
        const endDateStr = String(endDateYMD);
        const formattedEndDate = `${endDateStr.slice(0, 4)}-${endDateStr.slice(4, 6)}-${endDateStr.slice(6, 8)}`;
        const weekOfDay = dayjs(formattedEndDate).day();
        const currentWeekFirstDay = dayjs(startDateYMD, "YYYYMMDD")
          .startOf("week")
          .add(1, "day")
          .format("YYYYMMDD");
        const lastDayOfNextWeek = dayjs(formattedEndDate)
          .add(14 - weekOfDay, "day")
          .format("YYYYMMDD");
        await this.getOrdMainOfPeriod({
          facilityCd: this.facilityCd,
          patId: this.patId,
          startDay: currentWeekFirstDay,
          endDay: lastDayOfNextWeek,
          weekPattern: `[{ 'text': '全', 'done': true, 'value': 0 }]`
        });
      } catch (err) {
        getErrorMessage("PatViewer.vue", "setTreatmentDataOfPeriod", err);
        alert(err);
      } finally {
        this.finishLoadingScreen();
      }
    },
    //内部remine 5840  add ljx start

    /**
     * 患者検査結果(pat_exam_main)を取得(一部データを加工)
     */
    async setExamMainData() {
      if (this.patId !== null) {
        const patShareMode = this.getPatientShareMode == 0 && !this.getPatientShareFacilityCdMode ? 0 : 1;
        await this.getPatExamMain({
          patId: this.patId,
          startDay: this.startDay,
          endDay: this.endDay,
          patShareMode
        }).catch(err => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('PatViewer.vue', 'setExamMainData', "患者検査結果の取得に失敗しました。");
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "取得失敗",
            // message: "患者検査結果の取得に失敗しました。"
            title: DIALOG_MESSAGES[12000197].title,
            message: messageFormat(DIALOG_MESSAGES[12000197].message)
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        });
      }
    },

    // add FNSI-検体検査の表示の修正 楊 start
    /**
     * 患者検査結果(pat_exam_main)を取得(一部データを加工)
     */
    async setLastExamMainData() {
      if (this.patId !== null) {
        const patShareMode = this.getPatientShareMode == 0 && !this.getPatientShareFacilityCdMode ? 0 : 1;
        await this.getExamMainDataLastDate({
          patId: this.patId,
          // mod #9772 前回検査予定日の日付が不正 蔡 start
          //startDay: this.startDay
          startDay: dayjs().format("YYYYMMDD"),
          // mod #9772 前回検査予定日の日付が不正 蔡 end
          patShareMode
        }).catch(err => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('PatViewer.vue', 'setLastExamMainData', "患者検査結果の前回検査日の取得に失敗しました。");
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "取得失敗",
            // message: "患者検査結果の前回検査日の取得に失敗しました。"
            title: DIALOG_MESSAGES[12000198].title,
            message: messageFormat(DIALOG_MESSAGES[12000198].message)
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        });
      }
    },
    // add FNSI-検体検査の表示の修正 楊 end

    /**
     * 放射線検査結果(pat_rad_main)を取得(一部データを加工)
     */
    async setRadMainData() {
      if (this.patId !== null) {
        const patShareMode = this.getPatientShareMode == 0 && !this.getPatientShareFacilityCdMode ? 0 : 1;
        await this.getPatRadMain({
          patId: this.patId,
          startDay: this.startDay,
          endDay: this.endDay,
          patShareMode
        }).catch(err => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('PatViewer.vue', 'setRadMainData', "一般撮影検査結果の取得に失敗しました。");
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "取得失敗",
            // message: "一般撮影検査結果の取得に失敗しました。"
            title: DIALOG_MESSAGES[12000199].title,
            message: messageFormat(DIALOG_MESSAGES[12000199].message)
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        });
      }
    },

    // add FNSI-放射線検査の表示の修正 楊 start
    /**
     * 一般撮影検査前回検査日の取得
     */
    async setLastRadDate() {
      if (this.patId !== null) {
        const patShareMode = this.getPatientShareMode == 0 && !this.getPatientShareFacilityCdMode ? 0 : 1;
        await this.getPatRadMainLastDate({
          patId: this.patId,
          // mod #9772 前回検査予定日の日付が不正 蔡 start
          //startDay: this.startDay
          startDay: dayjs().format("YYYYMMDD"),
          // mod #9772 前回検査予定日の日付が不正 蔡 end
          patShareMode
        }).catch(err => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('PatViewer.vue', 'setLastRadDate', "一般撮影検査結果の前回検査日の取得に失敗しました。");
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "取得失敗",
            // message: "一般撮影検査結果の前回検査日の取得に失敗しました。"
            title: DIALOG_MESSAGES[12000200].title,
            message: messageFormat(DIALOG_MESSAGES[12000200].message)
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        });
      }
    },
    // add FNSI-放射線検査の表示の修正 楊 end

    // add FNSI-観察記録を追加 楊 start
    /**
     * 観察記録の取得
     */
    async setPatEventData() {
      if (this.patId !== null) {
        await this.getPatEventData({
          patId: this.patId,
          startDay: this.startDay,
          endDay: this.endDay
        }).catch(err => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('PatViewer.vue', 'setPatEventData', "観察記録の取得に失敗しました。");
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "取得失敗",
            // message: "観察記録の取得に失敗しました。"
            title: DIALOG_MESSAGES[12000201].title,
            message: messageFormat(DIALOG_MESSAGES[12000201].message)
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        });
      }
    },
    // add FNSI-観察記録を追加 楊 end

    // del FNSI-FutreNetWeb+SI課題管理No.5317 李 start
    // // add FNSI-紹介状を追加 楊 start
    // /**
    //  * 紹介状の取得
    //  */
    // async setPatUniqueData() {
    //   if (this.patId !== null) {
    //     await this.getPatUniqueData({
    //       patId: this.patId
    //     }).catch(err => {
    //       //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
    //       getErrorMessage('PatViewer.vue', 'setPatUniqueData', "紹介状の取得に失敗しました。");
    //       //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
    //       this.$ons.notification.alert({
    //         title: "取得失敗",
    //         message: "紹介状の取得に失敗しました。"
    //       });
    //     });
    //   }
    // },
    // // add FNSI-紹介状を追加 楊 end
    // del FNSI-FutreNetWeb+SI課題管理No.5317 李 end

    // add FNSI-患者イベント（仮）を追加 李 start
    /**
     * 患者イベント（仮）の取得
     */
    async setPatientData() {
      if (this.patId !== null) {
        await this.getPatientData({
          patId: this.patId,
          startDay: this.startDay,
          endDay: this.endDay
        }).catch(err => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('PatViewer.vue', 'setPatientData', "患者イベント（仮）の取得に失敗しました。");
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "取得失敗",
            // message: "患者イベント（仮）の取得に失敗しました。"
            title: DIALOG_MESSAGES[12000202].title,
            message: messageFormat(DIALOG_MESSAGES[12000202].message)
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        });
      }
    },
    // add FNSI-患者イベント（仮）を追加 李 end
    //7342 add 紹介状のイベント日付が登録日になる 張 start
    async setLetterData() {
      if (this.patId !== null) {
        const patShareMode = this.getPatientShareMode == 0 && !this.getPatientShareFacilityCdMode ? 0 : 1;
        await this.getLetterData({
          patId: this.patId,
          startDay: this.startDay,
          endDay: this.endDay,
          patShareMode
        }).catch(err => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('PatViewer.vue', 'getLetterData', "紹介状の取得に失敗しました。");
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "取得失敗",
            // message: "紹介状の取得に失敗しました。"
            title: DIALOG_MESSAGES[12000203].title,
            message: messageFormat(DIALOG_MESSAGES[12000203].message)
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        });
      }
    },
      //7342 add 紹介状のイベント日付が登録日になる 張 end
    // add FNSI-処方を追加 姜 start
    /**
     * 処方の取得
     */
    async setPatPrescriptionData() {
      if (this.patId !== null) {
        // mod #9738 患者経過総合ビューアで検査依頼、一般撮影検査依頼、招待状、処方、患者イベントのデータが正常に表示されない zy start
        // await this.getPrescriptionData({
          //   patId: this.patId,
        //   facilityCd: this.facilityCd
        const patShareMode = this.getPatientShareMode == 0 && !this.getPatientShareFacilityCdMode ? 0 : 1;
        await this.getPrescriptionData({
          patId: this.patId,
          facilityCd: this.facilityCd,
          startDay: this.startDay,
          endDay: this.endDay,
          patShareMode
          // mod #9738 患者経過総合ビューアで検査依頼、一般撮影検査依頼、招待状、処方、患者イベントのデータが正常に表示されない zy end
        }).catch(err => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('PatViewer.vue', 'setPatPrescriptionData', "処方の取得に失敗しました。");
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "取得失敗",
            // message: "処方の取得に失敗しました。"
            title: DIALOG_MESSAGES[12000204].title,
            message: messageFormat(DIALOG_MESSAGES[12000204].message)
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        });
      }
    },
    // add FNSI-処方を追加 姜 end

    // add FNSI-3922 投薬指示機能が施設拡張設定のON\OFF制御に反映していない liumx start
    /**
     * 施設の取得
     */
    async getIsShowFlag() {
      const response = await ApiHelper.get(
        `/facilities/getFacilityInfoByCd/${this.facilityCd}`,
        { selectedPatId: this.selectedPatId }
      ).catch(err => {
        throw err;
      });
      // 投薬表示の有無
      this.isShowAdvanceFlag = false;
      if(response.data.length > 0){
        let advance = response.data[0].advancedSettings;
        let advanceObject = JSON.parse(advance);
        let advanceArray = advanceObject.func_advcds;
        for(let i = 0; i < advanceArray.length; i++){
          let advanceCode = advanceArray[i];
          if('A10' == advanceCode.func_advcd){
            this.isShowAdvanceFlag = true;
            break;
          }
        }
      }
    },
    // add FNSI-3922 投薬指示機能が施設拡張設定のON\OFF制御に反映していない liumx end

    /**
     * 画面更新処理
     * @param isNewPat 患者切替フラグ
     */
    async refresh(isChangePat) {
      if (this.selfScreenName !== this.$route.name) {
        return;
      }
      const loadingAlreadyLocked = this.getLoadingScreenLocked;
      if (!loadingAlreadyLocked) {
        this.startLoadingScreen();
        this.lockLoadingScreen();
      }
      this.dataReady = false;
      try {
        this.setIndPlanCreateDate([this.startDay, this.endDay]);
        this.chartRenderedCount = 0;
        this.totalChartsExpected = 0;
        // スクロール量を取得
        this.getScrollPos(isChangePat);
        // 表示データの初期化
        await this.clearTreatmentData();

        // 患者未選択時は未実施
        if (undefined !== this.patId && null !== this.patId) {
          if (this.isTreatmentOnly && this.selectedPeriod <= 3) {
            await this.setIsTreatmentOnlyStartEndDay();
          }
          await this.getMst();
          const interfaces = [];
          const includes = (components) => {
            return components.some((item) => {
              return this.isShowComponents.has(item);
            });
          };
          if (includes(["medicine"])) {
            interfaces.push(this.setIndMediInfoData());
          }
          if (includes(["treat-plan", "rad-info"])) {
            interfaces.push(this.setRadMainData());
          }
          if (includes(["rad-info"])) {
            interfaces.push(this.setLastRadDate());
          }
          if (includes(["treat-plan", "exam-info"])) {
            interfaces.push(this.setExamMainData());
          }
          if (includes(["exam-info"])) {
            interfaces.push(this.setLastExamMainData());
          }
          if (includes(["obser"])) {
            interfaces.push(this.setPatEventData());
          }
          if (includes(["patient"])) {
            interfaces.push(this.setPatientData());
          }
          if (includes(["letter"])) {
            interfaces.push(this.setLetterData());
          }
          if (includes(["prescription"])) {
            interfaces.push(this.setPatPrescriptionData());
          }
          interfaces.push(this.setTreatmentData());
          interfaces.push(this.setTreatmentDataOfPeriod());
          try {
            await Promise.all(interfaces);
          } catch (err) {
            getErrorMessage("PatViewer.vue", "refresh", err);
          }
          let treatPlanLoadPromise = null;
          if (includes(["treat-plan"])) {
            treatPlanLoadPromise = this.waitForTreatPlanDataReady(
              this.getTreatPlanRowCount()
            );
          }
          this.dataReady = true;
          await this.flushChildComponentMounts();
          if (treatPlanLoadPromise) {
            await treatPlanLoadPromise;
          }
          await this.flushChildComponentMounts();
          this.setShowIndRst(this.selectedShowIndRst);
        } else {
          await this.clearTreatmentData();
          this.dataReady = true;
        }
        // 子コンポーネント(表示しているコンテンツ)のDOM更新が完了するのを待つ
        const contentsCnt = Object.keys(this.$refs).filter(
          refName => refName.startsWith("childContent")
        ).length;
        for (let i = 0; i < contentsCnt; i++) {
          await this.$nextTick();
        }
        await this.$nextTick();
        this.totalChartsExpected = this.calculateExpectedChartCount();
        if (this.totalChartsExpected > 0) {
          await this.waitForChartsToRender();
        }
      } finally {
        this.unlockLoadingScreen();
        if (!loadingAlreadyLocked) {
          this.finishLoadingScreen();
        }
        this.resetLoadingScreenVisibleCount();
      }
      this.setScrollPos();

      // 拡張表示
      this.setExtendedView();

      // 警告ダイアログ表示
      this.showWarningDialogs();
    },
    async flushChildComponentMounts() {
      await this.$nextTick();
      await this.$nextTick();
      await new Promise((resolve) => {
        requestAnimationFrame(() => {
          requestAnimationFrame(resolve);
        });
      });
      await this.$nextTick();
    },
    getTreatPlanRowCount() {
      const treatmentData = this.getTreatmentData;
      if (!treatmentData) {
        return 0;
      }
      return Array.isArray(treatmentData)
        ? treatmentData.length
        : Object.keys(treatmentData).length;
    },
    /**
     * 計画(treat-plan)行のデータ読込完了を待つ（refresh 中の lock 解除前）
     */
    waitForTreatPlanDataReady(expectedCount) {
      if (!expectedCount || expectedCount === 0) {
        return Promise.resolve();
      }
      return new Promise((resolve) => {
        let completed = 0;
        const eventName = "pat-viewer-treat-plan-loaded";
        const onLoaded = () => {
          completed += 1;
          if (completed >= expectedCount) {
            cleanup();
            resolve();
          }
        };
        const cleanup = () => {
          clearTimeout(timeoutId);
          EventBus.$off(eventName, onLoaded);
        };
        const timeoutId = setTimeout(() => {
          cleanup();
          resolve();
        }, 15000);
        EventBus.$on(eventName, onLoaded);
      });
    },
    // add #9713 特定操作で3/7/14日表示のグラフの横幅が1カ月表示になる wangchao 20260520 start
    calculateExpectedChartCount() {
      let count = 0;
      if (!this.selectedLayout || !Array.isArray(this.selectedLayout)) {
        return 0;
      }
      this.selectedLayout.forEach(layout => {
        if (this.isChartComponent(layout.component)) {
          count++;
        }
        if (layout.categoryItem && Array.isArray(layout.categoryItem)) {
          layout.categoryItem.forEach(category => {
            if (this.isChartComponent(category.component)) {
              count++;
            }
            if (category.subCategoryItem && Array.isArray(category.subCategoryItem)) {
              category.subCategoryItem.forEach(subCategory => {
                if (this.isChartComponent(subCategory.component)) {
                  count++;
                }
              });
            }
          });
        }
      });
      return count;
    },
    isChartComponent(componentName) {
      const chartComponents = [
        'exam-result',
        'comprehensive',
        'drug-graph',
        'weight',
        'vital'
      ];
      return chartComponents.includes(componentName);
    },
    waitForChartsToRender() {
      return new Promise((resolve) => {
        const timeout = setTimeout(() => {
          EventBus.$off('chartRendered', onChartRendered);
          EventBus.$off('chartRenderComplete', onChartRendered);
          resolve();
        }, 3000);

        const onChartRendered = (chartInfo) => {
          this.chartRenderedCount++;
          if (this.chartRenderedCount >= this.totalChartsExpected) {
            clearTimeout(timeout);
            EventBus.$off('chartRendered', onChartRendered);
            EventBus.$off('chartRenderComplete', onChartRendered);
            resolve();
          }
        };

        EventBus.$on('chartRendered', onChartRendered);
        EventBus.$on('chartRenderComplete', onChartRendered);
      });
    },
    showWarningDialogs() {
      if (this.nextWarningFlg) {
        this.messageDialogInfo.messageCd = "71000004";
        this.messageDialogInfo.type = "1";
        this.messageDialogInfo.isDialogVisible = true;
        this.nextWarningFlg = false;
      } else if (this.prevWarningFlg) {
        this.messageDialogInfo.messageCd = "71000003";
        this.messageDialogInfo.type = "1";
        this.messageDialogInfo.isDialogVisible = true;
        this.prevWarningFlg = false;
      }
    },
    // add #9713 特定操作で3/7/14日表示のグラフの横幅が1カ月表示になる wangchao 20260520 end
    async getTreatDateList() {
      const treatmentData = this.getTreatmentData[0] || {}
      const lastIndex = Object.keys(treatmentData).length - 1;
      let startDate = dayjs(
        Object.keys(treatmentData)[0] || this.getDateList[0],
        "YYYYMMDD"
      ).startOf("day");
      let endDate = dayjs(
        Object.keys(treatmentData)[lastIndex] ||
        this.getDateList[this.getDateList.length - 1],
        "YYYYMMDD"
      ).endOf("day");
      const isLongPeriod = ["4", "5", "6", "7"].includes(this.selectedPeriod);
      if (isLongPeriod) {
        switch (this.selectedPeriod) {
          case "4":
            endDate = endDate.add(1, "week").startOf("day").subtract(1, "days");
            break;
          case "5":
          case "6":
            startDate = startDate.startOf("month");
            endDate = endDate.endOf("month");
            break;
          case "7":
            startDate = startDate.startOf("month");
            endDate = endDate.add(11, "months").endOf("month");
            break;
        }
      } else { // convertWeightInfo
        endDate = endDate.add(1, "day").startOf("day");
      }
      // add #12462 患者情報共有->患者経過総合ビューア fang start
      const patShareMode = this.getPatientShareMode == 0 && !this.getPatientShareFacilityCdMode ? 0 : 1;
      // add #12462 患者情報共有->患者経過総合ビューア fang end
      const sendData = {
        facility_cd: this.getFacilityCd,
        pat_id: this.patId,
        ind_start_date: startDate.format("YYYYMMDD"),
        ind_end_date: endDate.format("YYYYMMDD"),
        week_pattern: "[{ 'text': '全', 'done': true, 'value': 0 }]",
        // add #12462 患者情報共有->患者経過総合ビューア fang start
        patShareMode: patShareMode
        // add #12462 患者情報共有->患者経過総合ビューア fang end
      };
      return await sendRequestPostTreatDateList(sendData, this.patId).then((response) => {
        this.setTreatDateList(deepCopy(response))
        return response;
      }).catch(err => {
        getErrorMessage('PatViewer.vue', 'getTreatDateList', err);
        throw err;
      }).finally(() => {
      });
    },

    /**
     * スクロール量取得
     * @description 画面再描画前のスクロール量を取得
     *  患者を切替時はスクロール量をリセットする
     * @param isChangePat 患者切替フラグ
     */
    getScrollPos(isChangePat) {
      const scoped$ = getScopedJQuery(this.$el || this) || $;
      this.scrollPos = isChangePat === true ? 0 : scoped$(".list-content").scrollTop();
    },

    /**
     * スクロール位置の設定
     */
    setScrollPos() {
      const scoped$ = getScopedJQuery(this.$el || this) || $;
      const listContent = scoped$(".list-content");
      listContent.scrollTop(this.scrollPos);
      // 治療日のみ表示が非チェック、且つ14日分表示の場合は、基準日が中央になるのでスクロールさせる
      if (this.selectedPeriod == "3" && listContent[0]) {
        const scr = (listContent[0].scrollWidth / 2) - 80;
        listContent[0].scrollLeft = scr;
      }
    },

    /**
     * 指定位置取得
     */
    getSpecifiedPos(checkScroll) {
      // 1日での治療予定の最大数を取得
      let statusMaxAmount = 0;

      if(checkScroll == 'scroll-column') {
        this.treatStatusList.forEach(eleItem => {
          if (eleItem.length > statusMaxAmount) {
            statusMaxAmount = eleItem.length;
          }
        });
      }

      if(checkScroll == 'scroll-popup') {
        if (this.getDialysisStateArray.length > statusMaxAmount) {
          statusMaxAmount = this.getDialysisStateArray.length;
        }
      }

      const scoped$ = getScopedJQuery(this.$el || this) || $;
      const listContent = scoped$(".list-content");
      // ヘッダー固定位置の高さ
      const fixedHeight = scoped$(".list-header-div").height();
      // 一覧情報ができていない場合は指定位置取得の処理を終了する
      // mod 9560 患者経過総合ビューアで長期間表示のグラフの時間軸が不正 張玲 start
      const listContentOffset = listContent.offset();
      if (!listContentOffset || !listContentOffset.top) {
        return;
      }
      // mod 9560 患者経過総合ビューアで長期間表示のグラフの時間軸が不正 張玲 end
      // 要素内のベースになる高さ
      const baseHeight = listContentOffset.top;

      // 現在のスクロール位置
      const currentPos = listContent.scrollTop();

      // 治療予定ごとのスクロール位置を指定
      for (let i = 0; i < statusMaxAmount; i++) {
        // 対象治療予定の高さ
        const targetOffset = scoped$(`.status${i}`).offset();
        if (!targetOffset) {
          continue;
        }
        const target = targetOffset.top;
        // 治療予定ごとのスクロール位置を格納
        this.specifiedPos[`status${i}`] =
          target - fixedHeight - baseHeight + currentPos;
      }
    },

    /**
     * 指定位置へ移動
     * @description 治療予定のバーをクリック時、クリックした治療予定の先頭に移動する
     */
    moveSpecifiedPos(index, checkScroll) {
      // 治療予定ごとのスクロール位置を取得
      this.getSpecifiedPos(checkScroll);
      // 特定の治療予定の先頭に移動する
      const scoped$ = getScopedJQuery(this.$el || this) || $;
      scoped$(".list-content").animate(
        { scrollTop: this.specifiedPos[`status${index}`] },
        1000,
        "swing"
      );
      if(checkScroll == 'scroll-popup') {
        this.popoverVisible1 = false;
      }
    },

    /**
     * 表示条件設定ポップオーバー表示
     */
    showPopoverSetting(event, direction, coverTarget) {
      this.popoverTarget = event;
      this.popoverDirection = direction;
      this.popoverCoverTarget = coverTarget;
      this.popoverVisible = true;
    },

    progressDay() {
      if (this.selectedDay < 0) {
        return [];
      }

      let dialysisStateArray = [];
      // 表示中の治療日に格納されている治療情報でループ
      let date = this.dateList[this.selectedDay];
      this.ordMainData.forEach(item => {
        for (const itemDate in item) {
          // 治療日リストと治療情報リストの日付が一致した場合以下の処理
          if (itemDate === date) {
            // 治療情報リストに治療予定がある場合は以下の処理
            if (null !== item[itemDate]) {
              let treatDateArr = []
              treatDateArr.push({"rstDialysisState": item[itemDate].rstDialysisState, "treatDate": item[itemDate].treatDate, "indTreatStartTime": item[itemDate].indTreatStartTime,  "indCondInfo": JSON.parse(item[itemDate].indCondInfo)});
              dialysisStateArray.push({
                status: item[itemDate].rstDialysisState,
                treatDate: [...treatDateArr],
              });
            }

          }
        }
      });

      if (dialysisStateArray) {
        this.setDialysisStateArray(dialysisStateArray);
        this.$nextTick();
      }
    },

    showPopoverSetting1(event, direction1, coverTarget1, index) {
      this.popoverTarget1 = event;
      this.popoverDirection1 = direction1;
      this.popoverCoverTarget1 = coverTarget1;
      this.popoverVisible1 = true;
      this.selectedDay = index;
      this.dialysisStateArray = this.getDialysisStateArray;
      this.progressDay();
      this.popoverKey += 1;
    },
    /**
     * 表示条件設定ポップオーバー 表示時処理
     * -検索時情報を検索条件項目に再セット
     */
    patViewerPopoverPreShow() {
      this.setPopTempToDialog();
    },

    /**
     * 表示条件設定ポップオーバー クリアボタン押下処理
     * @summary 表示条件設定を初期化
     */
    clearDispSetting() {
      // 基準日: 本日日付
      this.baseDay = dayjs().format("YYYY-MM-DD");

      // 期間: 7日分
      this.selectedPeriod = "2";

      // 治療日のみ表示: OFF
      this.isTreatmentOnly = false;

      // 指示・実績表示切替:指示実績併記表示
      this.selectedShowIndRst = "2";

      // 拡張表示: OFF
      this.isExtendedView = false;

      // 患者経過総合ビューアレイアウトマスタリストの先頭のレイアウトコード(3日・7日・14日)
      this.setSelectedLayoutCd = this.dispLayoutItemList.find(item => {
        return item.dispPeriodClass === "0";
      }).layoutCd;

      // 画面表示枠サイズの設定
      this.setContentWidth();

      // ポップオーバーを閉じる 2019/06/14 暫定対応
      // this.popoverVisible = false;
    },

    /**
     * 表示条件設定ポップオーバー OKボタン押下処理
     */
    async setDispSetting() {
      // add FNSI-改修内容検索条件ログ対応 李 start
      let msg = '患者経過総合ビューアが[';

      // 治療日のみ表示の設定
      if (this.isTreatmentOnly) msg = msg + '治療日のみ表示';
      // 基準日の設定
      if (this.baseDay) {
        if (msg == '患者経過総合ビューアが[') {
          msg = msg + this.baseDay;
        } else {
          msg = msg + '、' + this.baseDay;
        }
      }
      // 期間 / レイアウトの設定
      let layoutTitleName = '';
      switch (this.selectedPeriod) {
        case '1':
          layoutTitleName = '3日分';
          break;
        case '2':
          layoutTitleName = '7日分';
          break;
        case '3':
          layoutTitleName = '14日分';
          break;
        case '4':
          layoutTitleName = '12週';
          break;
        case '5':
          layoutTitleName = '6ヶ月';
            break;
        case '6':
          layoutTitleName = '1年';
          break;
        case '7':
          layoutTitleName = '3年';
          break;
      }
      msg = msg + '、' + layoutTitleName;
      // 期間 / レイアウトドロップダウンリストの設定
      if (this.dispLayoutItemList) {
        let layoutNameList = this.dispLayoutItemList.map(item => item.layoutName);
        msg = msg + '、' + layoutNameList[parseInt(this.setSelectedLayoutCd) - 1];
      }
      // 拡張表示の設定
      if (this.isExtendedView) msg = msg + '、' + '拡張表示';
      // 指示 / 実績の表示の設定
      let showIndRstName = '';
      switch (this.selectedShowIndRst) {
        case '1':
          showIndRstName = '指示のみ';
          break;
        case '2':
          showIndRstName = '実績優先';
          break;
        case '3':
          showIndRstName = '実績指示併記';
          break;
      }
      msg = msg + '、' + showIndRstName;
      msg = msg + ']で検索しました。';

      // セッションに設定する
      let paramObj = {'message': msg, 'functionName': '患者経過総合ビューア'};
      ApiHelper.put("/logs/event/conditionlog", paramObj)
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('PatViewer.vue', 'setDispSetting', error);
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
        });
      // add FNSI-改修内容検索条件ログ対応 李 end

      if (undefined !== this.patId && null !== this.patId) {
        // 治療日のみ表示
        //mod FNSI-6907 劉全航 start
        // if (this.isTreatmentOnly) {
          if (this.isTreatmentOnly && this.selectedPeriod <= 3) {
            //mod FNSI-6907 劉全航 end
          await this.setIsTreatmentOnlyStartEndDay();
        } else {
          // 表示開始日・終了日の設定
          this.setStartEndDay();
        }

        // 基準日の格納
        this.setBaseDate({ baseDate: this.baseDay });

        // 指示・実績表示切替の格納
        this.setShowIndRst(this.selectedShowIndRst);

        this.selectedLayoutCd = this.setSelectedLayoutCd;

        // 既存仕様：ポップオーバーを先に閉じてから計画画面側で loading
        this.popoverVisible = false;
        await this.$nextTick();
        await this.refresh();
      } else {
        // 表示開始日・終了日の設定
        this.setStartEndDay();
        // 基準日の格納
        this.setBaseDate({ baseDate: this.baseDay });
        // add FNSI-障害票一覧_患者経過総合ビューア_初期表示#1。 周 start
        // 指示・実績表示切替の格納
        this.setShowIndRst(this.selectedShowIndRst);
        // 表示レイアウトの格納
        this.selectedLayoutCd = this.setSelectedLayoutCd;
        // add FNSI-障害票一覧_患者経過総合ビューア_初期表示#1。 周 end
      }
      // 画面表示枠サイズの設定
      this.setContentWidth();

      //検索条件の一時保管
      this.setDialogToPopTemp();
      // mod FNSI-redmine 4125 姜 start
      this.setExtendedView();
      // mod FNSI-redmine 4125 姜 end
      // 表示期間の格納
      this.currentSelectedPeriod = this.selectedPeriod;

      this.$store.commit('pat-viewer/setSelectedPeriod', this.selectedPeriod);

      const conditionSearch = {
        isTreatmentOnly: this.isTreatmentOnly,
        baseDay : this.baseDay,
        selectedPeriod: this.selectedPeriod,
        isExtendedView: this.isExtendedView,
        selectedShowIndRst: this.selectedShowIndRst,
        setSelectedLayoutCd: this.setSelectedLayoutCd,
      }
      this.setSelectedCondition(conditionSearch);
      // add redmine 6057 yuqizheng start
      EventBus.$emit("indicationRefresh");
      // add redmine 6057 yuqizheng end
      if (this.popoverVisible) {
        this.popoverVisible = false;
      }
      // // add 9200 by kangjie 20230912 start
      // // 投与薬剤
      // await this.setIndMediInfoData();
      // // add 9200 by kangjie 20230912 end
    },

    /**
     * 表示範囲ごとの枠内サイズ設定
     */
    setContentWidth(){
      let setContentWidth = 0;
      // 表示期間を計算、
      switch (this.selectedPeriod) {
        case "1":
          // 3日分
          setContentWidth = 450;
          break;
        case "2":
          // 7日分
          setContentWidth = 800;
          break;
        case "3":
          // 14日分
          setContentWidth = 1430;
          break;
        case "4":
          // 12週
          setContentWidth = 1250;
          break;
        case "5":
          // 6ヶ月
          setContentWidth = 710;
          break;
        case "6":
          // 1年
          setContentWidth = 1250;
          break;
        case "7":
          // 3年
          setContentWidth = 450;
          break;
      }
      this.contentWidth = setContentWidth;
    },

    /**
     * 期間ラジオボタン、基準日を元に表示開始日・終了日を設定
     */
    setStartEndDay() {
      // 基準日が未入力の場合は本日日付で処理
      if (!this.baseDay) {
        this.baseDay = dayjs().format("YYYY-MM-DD");
      }
      // 表示期間を計算、設定
      switch (this.selectedPeriod) {
        case "1":
          // 3日分
          this.endDay = dayjs(this.baseDay)
            .add(2, "days")
            .format("YYYYMMDD");
          this.startDay = dayjs(this.baseDay).format("YYYYMMDD");
          break;

        case "2":
          // 7日分
          this.endDay = dayjs(this.baseDay)
            .add(6, "days")
            .format("YYYYMMDD");
          this.startDay = dayjs(this.baseDay).format("YYYYMMDD");
          break;

        case "3":
          // 14日分
          // 基準日から過去7日分、未来6日分を表示する
          this.endDay = dayjs(this.baseDay)
            .add(6, "days")
            .format("YYYYMMDD");
          this.startDay = dayjs(this.baseDay)
            .subtract(7, "days")
            .format("YYYYMMDD");
          break;
        case "4":
          // 12週
          // 月曜からスタート
          this.endDay = dayjs(this.baseDay)
            .startOf("isoWeek")
            .format("YYYYMMDD");
          this.startDay = dayjs(this.baseDay)
            .add(-11, "weeks")
            .startOf("isoWeek")
            .format("YYYYMMDD");
          break;

        case "5":
          // 6ヶ月
          this.endDay = dayjs(this.baseDay).format("YYYYMMDD");
          this.startDay = dayjs(this.baseDay)
            .add(-5, "months")
            .startOf("month")
            .format("YYYYMMDD");
          break;

        case "6":
          // 1年
          this.endDay = dayjs(this.baseDay).format("YYYYMMDD");
          this.startDay = dayjs(this.baseDay)
            .add(-11, "months")
            .startOf("month")
            .format("YYYYMMDD");
          break;

        case "7":
          // 3年
          this.endDay = dayjs(this.baseDay).format("YYYYMMDD");
          this.startDay = dayjs(this.baseDay)
            .add(-35, "months")
            .startOf("month")
            .format("YYYYMMDD");
          break;
      }

      // 一覧ヘッダーの日付リストの設定
      this.setDateList({
        startDay: this.startDay,
        endDay: this.endDay,
        period: this.selectedPeriod
      });
    },

    /**
     * 曜日取得
     * @summary 曜日取得(0:日曜日～6:土曜日)
     */
    getWeek(date) {
      let cssString = "";
      if (
        false === dayjs(date).isValid() ||
        ["4", "5", "6", "7"].includes(this.currentSelectedPeriod)) {
        return cssString;
      }
      return getHolidayStyle(date);
    },

    /**
     * 基準日を含むカラムに罫線を追加
     */
    needOutline(date) {
      const normalDate = dayjs(date);
      const popBaseday = dayjs(this.popBaseDay);
      const daysDiff = dayjs(date).add(1, "weeks").diff(popBaseday, "days");
      const monthsDiff = dayjs(date).diff(popBaseday, "months");
      const yearsDiff = dayjs(date).diff(popBaseday, "years");

      switch (this.popSelectedPeriod) {
        case "1":
        case "2":
        case "3":
          // 3日分、7日分、14日分
          return normalDate.isSame(popBaseday, "day");
        case "4":
          // 12週
          return daysDiff > 0;
        case "5":
        case "6":
          // 6ヶ月、1年
          return monthsDiff === 0;
        case "7":
          // 3年
          return yearsDiff === 0;
        default:
          return false;
      }
    },

    /**
     * 当日を含むカラムの背景色を変更
     */
    needTodayBG(date) {
      const normalDate = dayjs(date);
      const today = dayjs();
      const yearsDiff = dayjs(date).diff(today, "years");

      switch (this.popSelectedPeriod) {
        case "1":
        case "2":
        case "3":
          // 3日分、7日分、14日分
          return normalDate.isSame(today, "day");
        case "4":
          // 12週
          return normalDate.isSame(today, "weeks");
        case "5":
        case "6":
          // 6ヶ月、1年
          return normalDate.isSame(today, "months");
        case "7":
          // 3年
          return yearsDiff === 0;
        default:
          return false;
      }
    },

    /**
     * 日付列をクリック時処理
     */
    onDateClick(event, treatDate) {
      // 患者IDが格納されていなければ処理終了
      if (null === this.patId) {
        return;
      }
      // 今日の日付を取得
      const day = dayjs().format("YYYYMMDD");
      // 治療日を比較用データに変換
      const checkTreatDate = dayjs(treatDate).format("YYYYMMDD");
      // 治療日が過去日の場合、治療予定作成モーダルを直接表示
      const menuInfo = deepCopy(defaultMenuInfo);
      // 治療日の格納
      menuInfo.treatDate = treatDate;
      // 表示ターゲット
      menuInfo.target = event;
      // 表示方向
      menuInfo.direction = "down";
      // 予定作成
      menuInfo.isShowCreate = true;
      // 予定コピー
      menuInfo.isShowCopy = true;
      // 予定元コピーフラグを設定
      this.setCopyFlag({copyFlag: 1});
      // 治療予定メニューポップオーバーの表示
      this.setShowTreatPlanMenuPopover({menuInfo});
    },

    /**
     * 曜日を英語表記に変換
     */
    changeWeekStr(num) {
      switch (num) {
        case 0:
          return "sunday";
        case 1:
          return "monday";
        case 2:
          return "tuesday";
        case 3:
          return "wednesday";
        case 4:
          return "thursday";
        case 5:
          return "friday";
        case 6:
          return "saturday";
        default:
          return null;
      }
    },

    // mod FNSI-redmine 4688 劉祥霖 start
    treatmentProgressStyle1(arrState, arrTreatDate) {
      const styleborder = 'height: 34px; border-radius: 25px';
      const styleBorderMobile = 'height: 34px; border-radius: 17px 0px 0px 17px; width: 17px; margin-left: -2px';
      if (arrState.includes('3')) {
        const resulttreatmentProgress =  this.treatmentProgress(arrTreatDate);
        //mod 6816 治療の進捗状態を示す棒グラフが一致しない 張 start
        // const progress = (resulttreatmentProgress === 0) ? 20 : (resulttreatmentProgress + 20);
        const progress = (resulttreatmentProgress === 0) ? 2 : (resulttreatmentProgress + 2);
        return `background-color: ${this.colorStyle(arrState)}; ${styleborder}; width: ${progress}%;`;
      } else if(arrState.includes('1') || arrState.includes('2')) {
        // return `background-color: ${this.colorStyle(arrState)}; ${styleBorderMobile};width: 20%;`;
        return `background-color: ${this.colorStyle(arrState)}; ${styleBorderMobile};width: 2%;`;
        //mod 6816 治療の進捗状態を示す棒グラフが一致しない 張 end
      } else if(arrState.includes('4') || arrState.includes('5')) {
        return `background-color: ${this.colorStyle(arrState)}; ${styleborder}; width: 100%;`;
      } else if(arrState.includes('0')) {
        return `background-color: #FFFFFF; ${styleborder};  width: 100%;`;
      } else {
        return `background-color: ${this.colorStyle(arrState)}; ${styleborder};  width: 100%; `;
      }
    },
    // mod FNSI-redmine 4688 劉祥霖 end

    treatmentCountStyle1(arrState) {
      if(arrState.includes('0') || arrState.includes('1') || arrState.includes('2') || arrState.includes('3')) {
        return "color:#050505";
      } else if(arrState.includes('4') || arrState.includes('5') || arrState.includes('6')) {
        return `color:white;`;
      } else {
        return "";
      }
    },

    treatmentTimeStyle1(arrState) {
      return `border: 1px solid ${this.colorStyle(arrState)}; height: 34px; width: 100%; border-radius: 25px; position: relative; background-color: white;`;
    },

    colorStyle(arrState) {
      // mod FNSI-redmine 4688 劉祥霖 start
      if (arrState.includes('3')) {
      // mod FNSI-redmine 4688 劉祥霖 end
        return "#2CA06F";
      } else if (arrState.includes('1') || arrState.includes('2')) {
        return "#42CB92";
      // mod FNSI-redmine 4688 劉祥霖 start
      } else if (arrState.includes('4') || arrState.includes('5')) {
      // mod FNSI-redmine 4688 劉祥霖 end
        return "#557769";
      } else if (arrState.includes('0')) {
        return "#595959";
      } else {
        return "#808080";
      }
    },

    // mod FNSI-redmine 4688 劉祥霖 start
    treatmentProgressStyle0(dyalState, arrTreatDate) {
      const styleborder = 'height: 6px; border-radius: 25px';
      const styleBorderMobile = 'height: 6px; border-radius: 3px 0px 0px 3px; width: 3px; margin-left: -1px';
      if (dyalState == '3') {
        const resulttreatmentProgress =  this.treatmentProgress(arrTreatDate);
        //mod 6816 治療の進捗状態を示す棒グラフが一致しない 張 start
        // const progress = (resulttreatmentProgress === 0) ? 20 : (resulttreatmentProgress + 20);
        const progress = (resulttreatmentProgress === 0) ? 2 : (resulttreatmentProgress + 2);
        return `background-color: ${this.colorStyle0(dyalState)}; ${styleborder}; width: ${progress}%;`;
      } else if(dyalState == '1' || dyalState == '2') {
        // return `background-color: ${this.colorStyle0(dyalState)}; ${styleBorderMobile};width: 20%;`;
        return `background-color: ${this.colorStyle0(dyalState)}; ${styleBorderMobile};width: 2%;`;
        //mod 6816 治療の進捗状態を示す棒グラフが一致しない 張 end
      } else if(dyalState == '4' || dyalState == '5') {
        return `background-color: ${this.colorStyle0(dyalState)}; ${styleborder}; width: 100%;`;
      } else if(dyalState == '0') {
        return `background-color: #FFFFFF; ${styleborder}; width: 100%;`;
      } else {
        return `background-color: ${this.colorStyle0(dyalState)}; ${styleborder};  width: 100%;`;
      }
    },
    // mod FNSI-redmine 4688 劉祥霖 end

    treatmentTimeStyle0(dyalState) {
      return `border: 1px solid ${this.colorStyle0(dyalState)}; height: 6px; width: 100%; border-radius: 25px; background-color: white;`;
    },

    treatmentTimeStylePopup(dyalState) {
      return `border: 1px solid ${this.colorStyle0(dyalState)}; height: 15px; width: 100%; border-radius: 25px; background-color: white;`;
    },

    // mod FNSI-redmine 4688 劉祥霖 start
    treatmentProgressStylePopup(dyalState, arrTreatDate) {
      const styleborder = 'height: 15px; border-radius: 25px'
      const styleBorderMobile = 'height: 15px; border-radius: 8px 0px 0px 8px; width: 8px; margin-left: -1px'
      if (dyalState == '3') {
        const resulttreatmentProgress =  this.treatmentProgress(arrTreatDate);
        //mod 6816 治療の進捗状態を示す棒グラフが一致しない 張 start
        // const progress = (resulttreatmentProgress === 0) ? 20 : (resulttreatmentProgress + 20);
        const progress = (resulttreatmentProgress === 0) ? 2 : (resulttreatmentProgress + 2);
        return `background-color: ${this.colorStyle0(dyalState)}; ${styleborder}; width: ${progress}%;`;
      } else if(dyalState == '1' || dyalState == '2') {
        // return `background-color: ${this.colorStyle0(dyalState)}; ${styleBorderMobile};width: 20%;`;
        return `background-color: ${this.colorStyle0(dyalState)}; ${styleBorderMobile};width: 2%;`;
        //mod 6816 治療の進捗状態を示す棒グラフが一致しない 張 end
      } else if(dyalState == '4' || dyalState == '5') {
        return `background-color: ${this.colorStyle0(dyalState)}; ${styleborder};  width: 100%;`;
      } else if(dyalState == '0') {
        return `background-color: #FFFFFF; ${styleborder};  width: 100%; `;
      } else {
        return `background-color: ${this.colorStyle0(dyalState)}; ${styleborder};  width: 100%;`;
      }
    },
    // mod FNSI-redmine 4688 劉祥霖 end

    colorStyle0(dyalState) {
      // mod FNSI-redmine 4688 劉祥霖 start
      if (dyalState == '3') {
      // mod FNSI-redmine 4688 劉祥霖 end
        return "#2CA06F";
      } else if(dyalState == '1' || dyalState == '2'){
        return "#42CB92";
      // mod FNSI-redmine 4688 劉祥霖 start
      } else if(dyalState == '4' || dyalState == '5'){
      // mod FNSI-redmine 4688 劉祥霖 end
        return "#557769";
      } else if(dyalState == '0') {
        return "#595959";
      } else {
        return "#808080";
      }
    },

     treatmentProgress(arrTreatDate) {
      let start_date_time = "";
      let treatment_time = "";
      arrTreatDate.forEach(itemTreatDateArray => {
        if (itemTreatDateArray.rstDialysisState === "3") {
          //mod 7680 治療の進捗状態を示す棒グラフが一致しない_再発 張 start
          // start_date_time =  dayjs(itemTreatDateArray.treatDate).format('YYYY-MM-DD') + ' ' + dayjs(itemTreatDateArray.indTreatStartTime, "hmm").format("HH:mm");
          if (itemTreatDateArray.rstStartDate) {
            // start_date_time =  dayjs(itemTreatDateArray.rstStartDate, 'YYYY-MM-DD HH:mm:ss').format("YYYY-MM-DD HH:mm");
            start_date_time = dayjs(dayjs.utc(itemTreatDateArray.rstStartDate).toDate()).format("YYYY-MM-DD HH:mm");
          }else{
            start_date_time =  dayjs(itemTreatDateArray.treatDate).format('YYYY-MM-DD') + ' ' + dayjs(itemTreatDateArray.indTreatStartTime, "hmm").format("HH:mm");
          }
          //mod 7680 治療の進捗状態を示す棒グラフが一致しない_再発 張 end
         treatment_time = itemTreatDateArray.indCondInfo['1'].value;
        }
      });
      if (start_date_time.includes("Invalid") || treatment_time === null) {
        return 0;
      }
      // "3": 経過時間表示
      const treatmentStartDateTime = dayjs(start_date_time);
      const now = dayjs();
      // ミリ秒を分へ変換
      const treatmentProgressTime = now.diff(treatmentStartDateTime) / 60000;
      // %へ変換
      let treatmentTimeRatio = (treatmentProgressTime / treatment_time) * 100;
      // 120pxの内25pxは0表示、残り95pxで経過を表示する
      //mod 6816 治療の進捗状態を示す棒グラフが一致しない 張 start
      // treatmentTimeRatio *= 0.95;
      treatmentTimeRatio *= 0.98;
      // 治療が開始していない場合の処理
      if (treatmentTimeRatio < 0) {
        return 0;
      }
      // let tmpTreatmentTimeRatio = (treatmentTimeRatio * 80) / 95;
      // return treatmentTimeRatio >= 95 ? 80 : tmpTreatmentTimeRatio;
      return treatmentTimeRatio >= 98 ? 98 : treatmentTimeRatio;
      //mod 6816 治療の進捗状態を示す棒グラフが一致しない 張 end
    },

    /**
     * @description 治療状況に応じて色を変更
     * @param value 治療状況
     * TODO: 現在はすべて緑
     * 条件送信前 -> ?
     * 条件送信前 -> ?
     * 条件送信確認済み -> ?
     * 治療中 -> ?
     * 排液済み -> ?
     * 後体重確認済み(実績未確定) -> ?
     * 後体重確認済み(過去実績) -> ?
     */
    setImage(value) {
      switch (value) {
        // 条件送信前
        case "0":
          return asset0Img;
        case "1":
        case "2":
          return asset1Img;
        case "3":
          return asset3Img;
        case "4":
        case "5":
          return asset4Img;
        case "6":
          return asset6Img;
        default:
          break;
      }
    },

    /**
     * 治療日のみの治療開始日、終了日設定
     */
    async setIsTreatmentOnlyStartEndDay() {
      // 表示期間
      let dispPeriod = null;
      let dispPastPeriod = null;
      switch (this.selectedPeriod) {
        case "1":
          dispPeriod = 3;
          dispPastPeriod = 0;
          break;

        case "2":
          dispPeriod = 7;
          dispPastPeriod = 0;
          break;

        case "3":
          dispPeriod = 7;
          dispPastPeriod = 7;
          break;

        case "4":
          break;

        default:
          break;
      }
      const sendJson = {};
      // 患者ID
      sendJson.pat_id = this.patId;
      // 施設コード
      sendJson.facility_cd = this.facilityCd;
      // 基準日
      sendJson.base_date = this.baseDay;
      // 期間(未来)
      sendJson.period = dispPeriod;
      // 期間(過去)
      sendJson.pastPeriod = dispPastPeriod;
      // RestAPI実行
      const response = await ApiHelper.post(
        "/mainData/IsTreaOnlyTreatDateList",
        sendJson
      ).catch(err => {
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
        getErrorMessage('PatViewer.vue', 'setIsTreatmentOnlyStartEndDay', err);
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
        throw err;
      });
      // 治療日リスト
      let treatDateList = [];
      if (0 !== response.data.length) {
        // 取得した治療日リストを格納
        response.data.forEach(eleItem => {
          treatDateList.push(eleItem.treatDate);
        });
      } else {
        // 取得件数が0件の場合、基準日を格納
        treatDateList.push(dayjs(this.baseDay).format("YYYYMMDD"));
      }
      // 治療日の重複を排除
      treatDateList = treatDateList.filter((x, i, self) => {
        return self.indexOf(x) === i;
      });

      // 日付けのソート
      treatDateList.sort((a, b) => {
        return Number(a) - Number(b);
      });

      // 選択されている期間ごとに治療日リストの調整
      switch (this.selectedPeriod) {
        // 3日分
        case "1":
          // 取得した治療日リストが3日分入っていない場合
          if (3 !== treatDateList.length) {
            // 治療日リストが3日分になるまで現在の最後尾の治療日に1日ずつ加算していく
            while (3 > treatDateList.length) {
              treatDateList.push(
                dayjs(treatDateList[treatDateList.length - 1])
                  .add(1, "days")
                  .format("YYYYMMDD")
              );
            }
          }
          break;

        // 7日分
        case "2":
          // 取得した治療日リストが7日分入っていない場合
          if (7 !== treatDateList.length) {
            // 治療日リストが7日分になるまで現在の最後尾の治療日に1日ずつ加算していく
            while (7 > treatDateList.length) {
              treatDateList.push(
                dayjs(treatDateList[treatDateList.length - 1])
                  .add(1, "days")
                  .format("YYYYMMDD")
              );
            }
          }
          break;

        // 14日分
        case "3":
          // 取得した治療日リストが14日分入っていない場合
          if (14 !== treatDateList.length) {
            // 基準日に満たないデータを抽出し7件未満なら不足日数分をtreatDateListに追加
            const pastTreatDateList = treatDateList.filter(
              (element, index, array) => {
                return element < dayjs(this.baseDay).format("YYYYMMDD");
              });
            const futureTreatDateList = treatDateList.filter(
              (element, index, array) => {
                return element >= dayjs(this.baseDay).format("YYYYMMDD");
              });
            if (7 !== pastTreatDateList.length) {
              while (treatDateList.length !== futureTreatDateList.length + 7) {
                treatDateList.unshift(
                  dayjs(treatDateList[0])
                    .subtract(1, "days")
                    .format("YYYYMMDD")
                );
              }
            }

            // 治療日リストが14日分になるまで現在の最後尾の治療日に1日ずつ加算していく
            while (14 > treatDateList.length) {
              treatDateList.push(
                dayjs(treatDateList[treatDateList.length - 1])
                  .add(1, "days")
                  .format("YYYYMMDD")
              );
            }
          }
          break;

        // 12週分
        case "4":
          break;

        // 6ヶ月分
        case "5":
          break;

        // 1年分
        case "6":
          break;

        // 3年分
        case "7":
          break;

        default:
          break;
      }

      // 表示開始日を設定
      this.startDay = treatDateList[0];
      // 表示中央日を設定
      this.dispBaseDay = treatDateList[Math.floor(treatDateList.length / 2)];
      // 表示終了日を設定
      this.endDay = treatDateList[treatDateList.length - 1];

      // 治療日のみ一覧ヘッダーの日付リスト設定
      this.setIsTreatmentOnlyDateList({
        dateList: treatDateList
      });
    },
    /**
     * 日付ラベル内 todayボタン押下処理
     */
    async setBaseDateToday() {
      // 画面表示時検索条件の再セット
      this.setPopTempToDialog();
      // 基準日の格納
      this.baseDay = dayjs().format("YYYY-MM-DD");
      // 表示条件設定保存処理を呼び出し
      await this.setDispSetting();
    },

    /**
     * 日付ラベル内 prevボタン押下処理
     */
    async setBaseDatePrev(period) {
      // 画面表示時検索条件の再セット
      this.setPopTempToDialog();

      // 移動させる表示期間
      let movePeriod = null;

      // パラメータ有：値を優先／パラメータ無:画面表示期間を使用
      if (period) {
        movePeriod = period;
      } else {
        switch (this.selectedPeriod + "") {
          case "1":
            movePeriod = 3;
            break;

          case "2":
            movePeriod = 7;
            break;

          case "3":
            if (this.isTreatmentOnly) {
              // 14日のみ表示後の残日数チェックのために14日＋7日＋1日の合計22日分取得
              movePeriod = 22;
            } else {
              movePeriod = 14;
            }
            break;

          case "4":
            movePeriod = 12;
            break;

          case "5":
            movePeriod = 6;
            break;

          case "6":
            movePeriod = 12;
            break;

          case "7":
            movePeriod = 3;
            break;

          default:
            movePeriod = 1;
            break;
        }
      }

      // 治療日のみ表示フラグ
      if (this.isTreatmentOnly) {
        // 治療日のみ
        // 基準日未満の日付をlimit 1で取得／取得成功ならその日付を基準日へ

        const sendJson = {};
        // 患者ID
        sendJson.pat_id = this.patId;
        // 施設コード
        sendJson.facility_cd = this.facilityCd;
        // 基準日
        switch (this.selectedPeriod + "") {
          case "1":
            sendJson.base_date = dayjs(this.startDay)
              .subtract(1, "days")
              .format("YYYY-MM-DD");
            break;

          case "2":
            sendJson.base_date = dayjs(this.startDay)
              .subtract(1, "days")
              .format("YYYY-MM-DD");
            break;

          case "3":
            //基準日が画面中央日付のためdispBaseDayを使用
            sendJson.base_date = dayjs(this.dispBaseDay)
              .subtract(1, "days")
              .format("YYYY-MM-DD");
            break;
          // del 9560 患者経過総合ビューアで長期間表示のグラフの時間軸が不正 張玲 start
          // case "4":
          //   break;
          // del 9560 患者経過総合ビューアで長期間表示のグラフの時間軸が不正 張玲 end

          default:
            sendJson.base_date = dayjs(this.startDay)
              .subtract(1, "days")
              .format("YYYY-MM-DD");
            break;
        }
        // 期間
        sendJson.period = movePeriod;
        // RestAPI実行
        const response = await ApiHelper.post(
          "/mainData/IsTreaOnlyTreatPastDateList",
          sendJson
        ).catch(err => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('PatViewer.vue', 'setBaseDatePrev', err);
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          // 検索エラー
          throw err;
        });

        // 治療日リスト
        let treatDateList = [];
        if (0 !== response.data.length) {
          // 取得した治療日リストを格納
          response.data.forEach(eleItem => {
            treatDateList.push(eleItem.treatDate);
          });
          // 治療日の重複を排除
          treatDateList = treatDateList.filter((x, i, self) => {
            return self.indexOf(x) === i;
          });
          // 日付けのソート
          treatDateList.sort((a, b) => {
            return Number(a) - Number(b);
          });
        } else {
          // 取得件数が0件の場合、データをセットしない
        }

        // 取得した治療日リストが1件以上あり14日以外の場合
        if (1 <= treatDateList.length && this.selectedPeriod + "" !== "3") {
          // 表示開始日を設定
          this.baseDay = dayjs(treatDateList[0]).format("YYYY-MM-DD");
          // 表示条件設定保存処理を呼び出し
          await this.setDispSetting();
        } else if (
          1 <= treatDateList.length &&
          this.selectedPeriod + "" === "3" &&
          period === 1
        ) {
          // 表示開始日を設定
          this.baseDay = dayjs(treatDateList[0]).format("YYYY-MM-DD");
          // 表示条件設定保存処理を呼び出し
          await this.setDispSetting();
        } else if (this.selectedPeriod + "" === "3") {
          // 3.14日表示かつ>>ボタン押下時
          if (treatDateList.length === 0) {
            // 対象日数：0日
            // 確認ダイアログ表示
            this.messageDialogInfo.messageCd = "71000001";
            this.messageDialogInfo.type = "1";
            this.messageDialogInfo.isDialogVisible = true;
          } else if (treatDateList.length <= 7) {
            // 対象日数：1日～6日（画面の右側が一部空白日付または右端がデータ最終日）
            // 確認ダイアログ表示
            this.messageDialogInfo.messageCd = "71000001";
            this.messageDialogInfo.type = "1";
            this.messageDialogInfo.isDialogVisible = true;
          } else if (treatDateList.length <= 21) {
            // 対象日数：7日～13日（画面左端に対して余剰日付が１日以上あり／１４日までの場合 14+7日）
            // 押下後の表示は左端が最初データになるように基準日にセット
            this.baseDay = dayjs(treatDateList[7]).format("YYYY-MM-DD");
            // 警告ダイアログ表示
            this.prevWarningFlg = true;
            // 表示条件設定保存処理を呼び出し
            await this.setDispSetting();
          } else {
            // 対象日数：14日以上（表示後の画面右端がまだ最終データではない）
            // 表示開始日を設定
            this.baseDay = dayjs(treatDateList[8]).format("YYYY-MM-DD");
            // 表示条件設定保存処理を呼び出し
            await this.setDispSetting();
          }
        } else {
          // 確認ダイアログ表示
          this.messageDialogInfo.messageCd = "71000001";
          this.messageDialogInfo.type = "1";
          this.messageDialogInfo.isDialogVisible = true;
        }
      } else {
        // 全対象日程
        // 基準日の格納
        switch (this.selectedPeriod + "") {
          case "1":
          case "2":
            //基準日が一覧初期値のためsubtract間隔=movePeriod
            this.baseDay = dayjs(this.startDay)
              .subtract(movePeriod, "days")
              .format("YYYY-MM-DD");
            break;
          case "3":
            //基準日が一覧中央値のためsubtract間隔を変更
            // mod bug #6604 修正 chen start
            this.baseDay = dayjs(this.baseDay)
              .subtract(movePeriod, "days")
              .format("YYYY-MM-DD");
            // this.baseDay = dayjs(this.startDay)
            //   .subtract(movePeriod - 7, "days")
            //   .format("YYYY-MM-DD");
            // mod bug #6604 修正 chen end
            break;

          case "4":
            this.baseDay = dayjs(this.startDay)
              .subtract(movePeriod - 11, "weeks")
              .format("YYYY-MM-DD");
            break;

          case "5":
            this.baseDay = dayjs(this.startDay)
              .subtract(movePeriod - 5, "months")
              .format("YYYY-MM-DD");
            break;

          case "6":
            this.baseDay = dayjs(this.startDay)
              .subtract(movePeriod - 11, "months")
              .format("YYYY-MM-DD");
            break;

          case "7":
            this.baseDay = dayjs(this.startDay)
              .subtract(movePeriod - 3, "years")
              .format("YYYY-MM-DD");
            this.baseDay = dayjs(this.baseDay)
              .subtract(1, "months")
              .format("YYYY-MM-DD");
            break;

          default:
            this.baseDay = dayjs(this.startDay)
              .subtract(movePeriod, "days")
              .format("YYYY-MM-DD");
            break;
        }
        // 表示条件設定保存処理を呼び出し
        await this.setDispSetting();
      }
    },

    /**
     * 日付ラベル内 nextボタン押下処理
     */
    async setBaseDateNext(period) {
      // 画面表示時検索条件の再セット
      this.setPopTempToDialog();
      // 移動させる表示期間
      let movePeriod = null;

      // パラメータ有：値を優先／パラメータ無:画面表示期間を使用
      if (period) {
        movePeriod = period;
      } else {
        switch (this.selectedPeriod + "") {
          case "1":
            movePeriod = 3;
            break;

          case "2":
            movePeriod = 7;
            break;

          case "3":
            if (this.isTreatmentOnly) {
              // 14日のみ表示後の残日数チェックのために14日＋7日＋1日の合計22日分取得
              movePeriod = 22;
            } else {
              movePeriod = 14;
            }
            break;

          case "4":
            movePeriod = 12;
            break;

          case "5":
            movePeriod = 6;
            break;

          case "6":
            movePeriod = 12;
            break;

          case "7":
            movePeriod = 3;
            break;

          default:
            movePeriod = 1;
            break;
        }
      }

      // 治療日のみ表示フラグ
      if (this.isTreatmentOnly) {
        // 治療日のみ
        // 基準日未満の日付をlimit 1で取得／取得成功ならその日付を基準日へ

        const sendJson = {};
        // 患者ID
        sendJson.pat_id = this.patId;
        // 施設コード
        sendJson.facility_cd = this.facilityCd;
        // 基準日
        switch (this.selectedPeriod + "") {
          case "1":
            sendJson.base_date = dayjs(this.startDay)
              .add(1, "days")
              .format("YYYY-MM-DD");
            break;

          case "2":
            sendJson.base_date = dayjs(this.startDay)
              .add(1, "days")
              .format("YYYY-MM-DD");
            break;

          case "3":
            //基準日が画面中央日付のためdispBaseDayを使用
            sendJson.base_date = dayjs(this.dispBaseDay)
              .add(1, "days")
              .format("YYYY-MM-DD");
            break;
          // del 9560 患者経過総合ビューアで長期間表示のグラフの時間軸が不正 張玲 start
          // case "4":
          //   break;
          // del 9560 患者経過総合ビューアで長期間表示のグラフの時間軸が不正 張玲 end

          default:
            sendJson.base_date = dayjs(this.startDay)
              .add(1, "days")
              .format("YYYY-MM-DD");
            break;
        }
        // 期間
        sendJson.period = movePeriod;
        sendJson.pastPeriod = 0;
        // RestAPI実行
        const response = await ApiHelper.post(
          "/mainData/IsTreaOnlyTreatDateList",
          sendJson
        ).catch(err => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('PatViewer.vue', 'setBaseDateNext', err);
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          // 検索エラー
          throw err;
        });

        // 治療日リスト
        let treatDateList = [];
        if (0 !== response.data.length) {
          // 取得した治療日リストを格納
          response.data.forEach(eleItem => {
            treatDateList.push(eleItem.treatDate);
          });
          // 治療日の重複を排除
          treatDateList = treatDateList.filter((x, i, self) => {
            return self.indexOf(x) === i;
          });
          // 日付けのソート
          treatDateList.sort((a, b) => {
            return Number(a) - Number(b);
          });
        } else {
          // 取得件数が0件の場合、データをセットしない
        }

        // 検索結果件数と押下ボタンごとの制御
        if (movePeriod === treatDateList.length && this.selectedPeriod + "" !== "3") {
          // 1.取得した治療日リストが指定日(3/7)分入っている
          // 表示開始日を設定
          this.baseDay = dayjs(treatDateList[movePeriod - 1]).format(
            "YYYY-MM-DD");

          // 表示条件設定保存処理を呼び出し
          await this.setDispSetting();
        } else if (this.selectedPeriod + "" === "3" && period == 1) {
          // 2.14日表示かつ１日移動で対象データ無し時
          sendJson.base_date = dayjs(this.dispBaseDay).format("YYYY-MM-DD");
          // dispBaseDayを加算せずにもう一度実施
          const response = await ApiHelper.post(
            "/mainData/IsTreaOnlyTreatDateList",
            sendJson
          ).catch(err => {
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
            getErrorMessage('PatViewer.vue', 'setBaseDateNext', err);
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
            // 検索エラー
            throw err;
          });
          if (0 !== response.data.length) {
            // 表示開始日を設定
            this.baseDay = dayjs(this.dispBaseDay)
              .add(1, "days")
              .format("YYYY-MM-DD");
            // 表示条件設定保存処理を呼び出し
            await this.setDispSetting();
          } else {
            // 確認ダイアログ表示
            this.messageDialogInfo.messageCd = "71000002";
            this.messageDialogInfo.type = "1";
            this.messageDialogInfo.isDialogVisible = true;
          }
        } else if (this.selectedPeriod + "" === "3") {
          // 3.14日表示かつ>>ボタン押下時
          if (treatDateList.length == 0) {
            // 対象日数：0日
            // 確認ダイアログ表示
            this.messageDialogInfo.messageCd = "71000002";
            this.messageDialogInfo.type = "1";
            this.messageDialogInfo.isDialogVisible = true;
          } else if (treatDateList.length < 7) {
            // 対象日数：1日～6日（画面の右側が一部空白日付または右端がデータ最終日）
            // 確認ダイアログ表示
            this.messageDialogInfo.messageCd = "71000002";
            this.messageDialogInfo.type = "1";
            this.messageDialogInfo.isDialogVisible = true;
          } else if (treatDateList.length <= 20) {
            // 対象日数：7日～13日（画面右端に対して余剰日付が１日以上あり／１４日までの場合:14+6日）
            // 押下後の表示は右端が最終データになるように基準日にセット
            this.baseDay = dayjs(
              treatDateList[treatDateList.length - 7]).format("YYYY-MM-DD");
            // 警告ダイアログ表示
            this.nextWarningFlg = true;
            // 表示条件設定保存処理を呼び出し
            await this.setDispSetting();
          } else {
            // 対象日数：14日以上（表示後の画面右端がまだ最終データではない）
            // 表示開始日を設定
            this.baseDay = dayjs(treatDateList[movePeriod - 9]).format(
              "YYYY-MM-DD");
            // 表示条件設定保存処理を呼び出し
            await this.setDispSetting();
          }
        } else {
          // 確認ダイアログ表示
          this.messageDialogInfo.messageCd = "71000002";
          this.messageDialogInfo.type = "1";
          this.messageDialogInfo.isDialogVisible = true;
        }
      } else {
        // 全対象日程
        // 基準日の格納
        switch (this.selectedPeriod + "") {
          case "1":
          case "2":
            //基準日が一覧初期値のためadd間隔=movePeriod
            this.baseDay = dayjs(this.startDay)
              .add(movePeriod, "days")
              .format("YYYY-MM-DD");
            break;
          case "3":
            //基準日が一覧中央値のためadd間隔を変更
            // mod bug #6604 修正 chen start
            this.baseDay = dayjs(this.baseDay)
              .add(movePeriod, "days")
              .format("YYYY-MM-DD");
            // this.baseDay = dayjs(this.startDay)
            //   .add(movePeriod + 7, "days")
            //   .format("YYYY-MM-DD");
            // mod bug #6604 修正 chen end
            break;

          case "4":
            this.baseDay = dayjs(this.startDay)
              .add(movePeriod + 11, "weeks")
              .format("YYYY-MM-DD");
            break;

          case "5":
            this.baseDay = dayjs(this.startDay)
              .add(movePeriod + 5, "months")
              .format("YYYY-MM-DD");
            break;

          case "6":
            this.baseDay = dayjs(this.startDay)
              .add(movePeriod + 11, "months")
              .format("YYYY-MM-DD");
            break;

          case "7":
            this.baseDay = dayjs(this.startDay)
              .add(movePeriod + 3, "years")
              .format("YYYY-MM-DD");
            this.baseDay = dayjs(this.baseDay)
              .subtract(1, "months")
              .format("YYYY-MM-DD");
            break;

          default:
            this.baseDay = dayjs(this.startDay)
              .add(movePeriod, "days")
              .format("YYYY-MM-DD");
            break;
        }
        // 表示条件設定保存処理を呼び出し
        await this.setDispSetting();
      }
    },

    /**
     * 検索条件：ダイアログ選択情報→ポップアップ一時管理情報へ保管
     */
    setDialogToPopTemp() {
      this.popBaseDay = this.baseDay;
      this.popSelectedPeriod = this.selectedPeriod;
      this.isPopTrentmentOnly = this.isTreatmentOnly;
      this.popSelectedShowIndRst = this.selectedShowIndRst;
      this.isPopExtendedView = this.isExtendedView;
    },

    /**
     * 検索条件：ポップアップ一時管理情報→ダイアログ選択情報へ保管
     */
    setPopTempToDialog() {
      this.baseDay = this.popBaseDay;
      this.selectedPeriod = this.popSelectedPeriod;
      this.isTreatmentOnly = this.isPopTrentmentOnly;
      this.selectedShowIndRst = this.popSelectedShowIndRst;
      this.isExtendedView = this.isPopExtendedView;
    },

    /**
     * 表示項目リストの設定
     * @description 表示期間選択時の表示項目設定
     */
    setDispItemList() {
      const initialSetSelectedLayoutCd = this.setSelectedLayoutCd;
      this.dispLayoutItem = this.dispLayoutItemList.filter(item => {
        // 表示項目リストが格納されている場合
        if (0 !== item.dispItemInfo.length) {
          // 3日・7日・14日選択時の項目設定
          if (4 > Number(this.selectedPeriod)) {
            return "0" === item.dispPeriodClass;
          } else {
            return "1" === item.dispPeriodClass;
          }
        }
      });
      let layoutCd = null;
      if (this.dispLayoutItem.length > 0) {
        // デフォルトはレイアウトリストの先頭
        layoutCd = this.dispLayoutItem[0].layoutCd;

        const layoutCdExists = (cd => !!this.dispLayoutItem.find(layout => layout.layoutCd === cd));
        if (layoutCdExists(initialSetSelectedLayoutCd)) {
          // 更新後のリストに存在するレイアウトが
          // 元々 setSelectedLayoutCd に設定されていた場合は
          // その値のままにする
          layoutCd = initialSetSelectedLayoutCd;
        } else {
          const periodType = this.selectedPeriod < "4" ? "small" : "large";
          const prevLayoutCd = this.selectedLayoutCdByPeriodType[periodType];
          if (layoutCdExists(prevLayoutCd)) {
            // 以前に選択されていたレイアウトの情報が有効な場合は
            // その値にする
            layoutCd = prevLayoutCd;
          }
        }
      }
      this.setSelectedLayoutCd = layoutCd;
    },

    /**
     * 日付の表示フォーマット
     */
    dateFormatter(date) {
      switch (this.currentSelectedPeriod) {
        case "4":
          return dayjs(date).format("M/D～");

        case "5":
        case "6":
          return dayjs(date).format("M月");

        case "7":
          return `${dayjs(date).format("'YY.M")}～${dayjs(date)
            .add(11, "months")
            .format("'YY.M")}`;

        default:
          return dayjs(date).format("D日(ddd)");
      }
    },

    /**
     * 操作不可メッセージを閉じる
     */
    hideMessageDialog() {
      this.showMessageDialog({ isShowMessageDialog: false });
    },

    async getPatInfo() {
      const uri = "/patInfo/getPatById";
      const responsePat = await ApiHelper.get(`${uri}/${this.patId}`).catch(
        () => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('PatViewer.vue', 'getPatInfo', "[PatInfoFunctions.js]getPatById(): APIエラー  404以外ならJavaのログ確認してください");
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          throw new Error(
            "[PatInfoFunctions.js]getPatById(): APIエラー  404以外ならJavaのログ確認してください"
          );
        }
      );
      return _.mapValues(responsePat.data, patInfoJson =>
        JSON.parse(patInfoJson)
      );
    },

    /**
     * @description 死亡情報取得
     * @returns { Object } is_die: "0" or "1", die_date: null or "YYYYMMDD"
     */
    getDieInfo(patInfo) {
      const patPersonalMain = patInfo.pat_personal_main;
      const isDie = patPersonalMain.is_die;
      const dieInfo = { is_die: "0", die_date: null };
      if (isDie === "1") {
        // 「"1": 死亡」なら
        dieInfo.is_die = "1";
        const date = patPersonalMain.die_date;

        if (date === null) {
          // 死亡日が"YYYYMMDD"でないならnullとなる
          const patUnique = patInfo.pat_unique;
          const medicalHstInfo = JSON.parse(patUnique.medical_hst_info);
          // 「"10": 死亡」
          const item = medicalHstInfo.find(item => item.out_come === "10");

          if (item) {
            const year =
              item.diagnosis_year === null ? "0000" : item.diagnosis_year;
            const month =
              item.diagnosis_month === null ? "00" : item.diagnosis_month;
            const day = item.diagnosis_day === null ? "00" : item.diagnosis_day;
            dieInfo.die_date = `${year}${month}${day}`;
          }
        } else {
          dieInfo.die_date = dayjs(date, "YYYY-MM-DD HH:mm:ss").format(
            "YYYYMMDD"
          );
        }
      }

      return dieInfo;
    },

    hideDieMessage() {
      this.setIsDieMessage(false);
    },

    /**
     * 拡張表示の設定
     */
    setExtendedView() {
      // mod FutreNetWeb+SI課題管理 no.6450 chen start
      //   if (this.isExtendedView === true) {
      // // mod FNSI-redmine 4125 姜 start
      //     const header = document.getElementsByClassName("list-header-div")[0];
      //     header.setAttribute("style", "min-width:" + (this.contentWidth*2) + "px;width:200%;");
      //     //FutreNetWeb+SI課題管理 no.6450 劉全航 start
      //     // const content = document.getElementsByClassName("list-content-div")[0];
      //     // if (content !== undefined) {
      //     //   content.setAttribute("style", "min-width:" + (this.contentWidth*2) + "px;width:200%;");
      //     // }
      //     //FutreNetWeb+SI課題管理 no.6450 劉全航 end
      //   } else {
      //     const header = document.getElementsByClassName("list-header-div")[0];
      //     //FutreNetWeb+SI課題管理 no.6450 劉全航 start
      //     // const content = document.getElementsByClassName("list-content-div")[0];
      //     // if (content !== undefined) {
      //     //   content.removeAttribute("style");
      //     //   content.setAttribute("style", "min-width:" + this.contentWidth + "px;");
      //     // }
      //     //FutreNetWeb+SI課題管理 no.6450 劉全航 end
      //     header.removeAttribute("style");
      //     header.setAttribute("style", "min-width:" + this.contentWidth + "px;");
      // // mod FNSI-redmine 4125 姜 end
      // }
      // mod FutreNetWeb+SI課題管理 no.6450 chen end
    },

    /**
     * ベッドが未登録となった予定がある場合に発火するイベント
     * ベッドが未登録となった予定一覧をダイアログで表示する
     */
    showMessageBedUnregist(params) {
      let infoList = "<br>"
      if (params.BedUnregistSchInfo && params.BedUnregistSchInfo.length > 0) {
        params.BedUnregistSchInfo.forEach((item) => {
          infoList = infoList + item + "<br>"
        })
      }
      if (params.updateMode === "1") {
        this.messageDialogInfo.messageCd = 12010006;
      } else if (params.updateMode === "2") {
        this.messageDialogInfo.messageCd = 12010005;
      }
      this.messageDialogInfo.type = "1";
      this.messageDialogInfo.stringParams = [infoList];
      this.messageDialogInfo.isDialogVisible = true;
    },

    /**
     * 同日に複数予定が存在したため、ベッド未登録となった予定がある場合に発火するイベント
     * ベッドが未登録となった予定一覧をダイアログで表示する
     */
    showMessageDuplicated(params) {
      let infoList = "<br>"
      if (params.DuplicatedOrdInfo && params.DuplicatedOrdInfo.length > 0) {
        infoList = infoList + params.DuplicatedOrdInfo.join("<br>");
      }
      this.messageDialogInfo.messageCd = 12010007;
      this.messageDialogInfo.type = "1";
      this.messageDialogInfo.stringParams = [infoList];
      this.messageDialogInfo.isDialogVisible = true;
    },

    reflowPatViewerCharts(chartComponent) {
      this.listChartComponents.push(chartComponent);
      this.listChartComponents.forEach((chart, index) => {
        if (chart.options !== undefined) {
          chart.reflow();
        } else {
          this.listChartComponents.splice(index, 1);
        }
      });
    },

    // ウインドウ変更時の高さ、幅を調整
    calculateGridSize(){
      const ww = this.windowWidth;
      const contentWidth = ww - 5;
      const sbWidth = this.sidebarWidth;
      if(sbWidth){
        const contWidth = contentWidth - sbWidth;
        const listContent = getScopedElementsByClassName("list-content", this.$el || null)[0];
        if (listContent) {
          listContent.style.width = contWidth + 'px';
        }
      }else{
        const listContent = getScopedElementsByClassName("list-content", this.$el || null)[0];
        if (listContent) {
          listContent.style.width = contentWidth + 'px';
        }
      }

      const wh = this.windowHeight;
      const hh = getHeaderHeight(getLatestHeaderElement(this.$el || document), 0);
      const fh = getFooterMenuClientHeight(this.$el || null);
      const contHeight = wh - hh - fh - 5;
      this.contentHeight = contHeight;
     },
  }
};
</script>

<style>
@media print {
  /** 表崩れ回避 */
  body:has(#pat_viewer) #main-id {
    display: inline-block;
    top: 110px;
  }
  body:has(#pat_viewer) .header {
    position: absolute;
  }
}
</style>

<style scoped lang="scss">
/* 患者経過総合ビューア共通スタイル定義 */
/* mod bug 7185 修正 chen start */
/* @import "/css/style.scss"; */
@use "css/style.scss" as *;
/* mod bug 7185 修正 chen start */

.status-figure-label {
  width: 90%;
  height: 7px;
  padding-bottom: 2px;
  margin: 0 auto;
}
.status-figure-processbar {
  width: 90%;
  margin: 0 auto;
}
.status-figure-label-popup {
  padding-bottom: 2px;
  width: 90%;
  margin: 0 auto;
}
.v-ons-popover-around {
  padding-top: 5px;
  padding-bottom: 5px;
}
.popover-content-cond-label {
  min-width: 8em;
  margin-right: 0.5em;
}
img {
  width: 100%;
  max-width: 51px;
  height: 100%;
}
.pat-create {
  display: inline-block;
  width: auto;
  height: 30px;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.button-style {
  padding: 0.1em 0.5em 0em 0.5em;
  line-height: 1.5em;
  font-size: 100%;
  min-width: 3em;
}
.treatment-time-area {
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  position: absolute;
  display: inline-block;
}
// mod 9560 患者経過総合ビューアで長期間表示のグラフの時間軸が不正 張玲 start
// .item-status-style[data-v-f375909c]{
.item-status-style {
// mod 9560 患者経過総合ビューアで長期間表示のグラフの時間軸が不正 張玲 end
  background-color: var(--ntss-base-background-color);
  height: auto;
}
.img-popup {
  display: block;
  margin-left: auto;
  margin-right: auto;
  padding-top: 5px;
  padding-bottom: 5px;
  width: 50%;
}

.popover-style :deep(.popover--top) {
  width: 200px;
}

.state-dispcount {
  position: absolute;
  color: var(--ntss-base-color);
  line-height: 34px;
  display: flex;
  width: 100%;
  justify-content: center;
}

.list-header-baseday {
  outline: 3px solid #1a71cc;
  outline-offset: -3px;
}

.list-header-today {
  background-color: #2ca06f;
}

/* add FNSI-患者経過総合ビューア 画面デザイン 李 start */
.width-padding {
  width: 80px;
  padding-top: 8px;
}
/* add FNSI-患者経過総合ビューア 画面デザイン 李 end */

/* add FNSI-FutreNetWeb+SI課題管理No.5585 李 start */
.popover-content-radio-pat {
  padding-right: 1px;
}
/* add FNSI-FutreNetWeb+SI課題管理No.5585 李 end */

/* add FNSI-患者経過総合ビューア 画面印刷レイアウトが崩れるの対応 xie start */
@media print {
  div {
    position: relative !important;
  }

  .list-content {
    height: auto !important;
    line-height: 0;
    width: 100% !important;
    max-width: none !important;
  }
}
/* add FNSI-患者経過総合ビューア 画面印刷レイアウトが崩れるの対応 xie end */
</style>
