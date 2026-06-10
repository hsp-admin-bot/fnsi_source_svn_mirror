<template>
<!-- mod FNSI-No.573 他の機能と検索操作が違っている dou start -->
  <!-- <div class="pat-header">
    <div class="condition-pat-header">
      <div class="pat-header-item">
        <v-ons-select class="pat-combo" v-model="selectedLayout">
          <option
            v-for="(layout, i) in layoutMst"
            :key="`layout_${i}`"
            :value="i"
          >{{ layout.patListLayoutName }}</option>
        </v-ons-select>
      </div>
      <template v-if="getSelectedDynamicLayout && getSelectedDynamicLayout.templateCd !== 4">
        <div class="pat-header-item">
          <input
            input-id="startDate"
            class="input-area-date"
            :class="{'ntss-input-date': getTypeInput === 'date'}"
            :type="getTypeInput"
            :max="getmax"
            v-model="searchCondition.startDate"
          />
          <common-calendar v-if="getTypeInput ==='date' " class="calender" v-model="searchCondition.startDate" />
        </div>
        <div class="pat-header-item">
          <span style="font-size: 15px;">～</span>
        </div>
        <div class="pat-header-item">
          <input
            input-id="endDate"
            class="input-area-date"
            :class="{'ntss-input-date': getTypeInput === 'date'}"
            :type="getTypeInput"
            :max="getmax"
            v-model="searchCondition.endDate"
          />
          <common-calendar v-if="getTypeInput ==='date' " class="calender" v-model="searchCondition.endDate" />
        </div>
        <div class="pat-header-item">
          <v-ons-button
            class="common-style-ok-button"
            :disabled="isDisableBtnSearch"
            @click="rangeDate"
          >検索</v-ons-button>
        </div>
      </template>
      <div class="pat-header-item">
        <v-ons-button
          id="button-position"
          class="common-style-ok-button"
          @click="showListType($event)"
        >ファイル出力</v-ons-button>
      </div>
    </div>

    <v-ons-popover
      cancelable
      :visible.sync="popoverInfo.popoverVisible"
      :target="popoverInfo.popoverTarget"
      :direction="popoverInfo.popoverDirection"
      :class="[fontSizeSet, 'popover-style']"
    >
      <div class="popover-content-div">
        <v-ons-row class="popover-content-row">
          <v-ons-col class="popover-content-col">
            <label class="left">
              <v-ons-checkbox
                :input-id="'checkbox-1'"
                :value="1"
                v-model="checkedExcel"
                @click="checkedExcel ? stopCheck($event) : checkExcel()"
              ></v-ons-checkbox>
            </label>
            <label :for="'checkbox-1'" class="center">Excel</label>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="popover-content-row">
          <v-ons-col class="popover-content-col">
            <label class="left">
              <v-ons-checkbox
                :input-id="'checkbox-2'"
                :value="2"
                v-model="checkedCSV"
                @click="checkedCSV ? stopCheck($event) : checkCSV()"
              ></v-ons-checkbox>
            </label>
            <label :for="'checkbox-2'" class="center">CSV</label>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="confirm">
          <v-ons-col vertical-align="center">
            <v-ons-button class="popover-content-button button cancel" @click="cancel">キャンセル</v-ons-button>
          </v-ons-col>
          <v-ons-col vertical-align="center">
            <v-ons-button class="popover-content-button button" @click="download">保存</v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
    </v-ons-popover>
  </div> -->
  <v-card>
    <div class="header-item">
      <div class="mark-leftmost-header">
        <v-ons-row class="content-area" vertical-align="center">
          <v-ons-col class="condition-search-col">
            <div
              id="bbs-search-area"
              class="condition-search-area condition-search-area-multi d-flex position_absolute"
              @click="showPopover($event)"
            >
              <div class="condition-search-icon-area">
                  <v-ons-icon icon="fa-search" size="2.0em" style="color:gray;" />
              </div>
              <div
                class="search-condition flex-1 d-flex flex-wrap align-items-center"
              >
                <label class="condition condition-label margin_left_30" v-if="getSelectedDynamicLayout">
                  {{ "レイアウト：" + getSelectedDynamicLayout.patListLayoutName }}
                </label>
                <label
                  v-show="isNeedDateConditionArea && !!searchConditionExec.startDate"
                  class="condition condition-label margin_left_5">
                  {{ "期間指定開始：" + searchConditionExec.startDate }}
                </label>
                <label
                  v-show="isNeedDateConditionArea && !!searchConditionExec.endDate"
                  class="condition condition-label margin_left_5">
                  {{ "期間指定終了：" + searchConditionExec.endDate }}
                </label>
              </div>
            </div>
            <!-- 検索条件：入力エリア -->
            <v-ons-popover
              cancelable
              :visible.sync="popoverVisible"
              :target="popoverTarget"
              :direction="popoverDirection"
              :cover-target="false"
              :class="[fontSizeSet, 'popover-area']"
              @preshow="popoverPreShow"
              @postshow="popoverPostShow"
              @posthide="popoverPosthide"
            >
              <div style="padding: 10px;">
                <div class="pat-header-item" style="margin-bottom: 1em;">
                  <span style="margin-right: 1em; width: 7em; min-width: 7em;">レイアウト</span>
                  <v-ons-select class="pat-combo" style="margin-bottom: -5px;" v-model="selectedLayout">
                    <option
                      v-for="(layout, i) in layoutMst"
                      :key="`layout_${i}`"
                      :value="i"
                    >{{ layout.patListLayoutName }}</option>
                  </v-ons-select>
                </div>
                <template>
                  <div v-show="isNeedDate" class="pat-header-item" style="margin-bottom: 1em;">
                    <span style="margin-right: 1em; width: 7em">期間指定開始</span>
                    <!--mod FNSI-改修内容日付のチェックの追加対応。 趙立強 start-->
                    <!-- <input
                      input-id="startDate"
                      class="input-area-date"
                      :class="{'ntss-input-date': getTypeInput === 'date'}"
                      :type="getTypeInput"
                      :max="getmax"
                      v-model="searchCondition.startDate"
                    />
                    <common-calendar v-if="getTypeInput ==='date' " class="calender" v-model="searchCondition.startDate" /> -->
                    <!--#10715:日付IF修正param修正Start-->
                    <span v-if="getTypeInput ==='date'">
                    <date-input
                      input-id="startDate"
                      class="input-area-date start-date"
                      :class="{'ntss-input-date': getTypeInput === 'date'}"
                      :type="getTypeInput"
                      :max="getmax"
                      :isRequired="true"
                      :default-date="defaultDate"
                      @blur="chkchange()"
                      v-model="searchCondition.startDate"
                    />
                    <common-calendar v-if="getTypeInput ==='date' " class="calender start-date-comment" v-model="searchCondition.startDate" />
                    <!--mod FNSI-改修内容日付のチェックの追加対応。 趙立強 end-->
                    </span>
                    <span v-else>
                      <input
                      input-id="startDate"
                      class="input-area-date start-date"
                      :class="{'ntss-input-date': getTypeInput === 'date'}"
                      :type="getTypeInput"
                      :max="getmax"
                      @blur="chkchange()"
                      v-model="searchCondition.startDate"
                    />
                    <common-calendar v-if="getTypeInput ==='date' " class="calender start-date-comment" v-model="searchCondition.startDate" />
                    <!--mod FNSI-改修内容日付のチェックの追加対応。 趙立強 end-->
                    </span>
                  </div>
                  <!--add FNSI-改修内容日付のチェックの追加対応。 趙立強 start-->
                  <!--<span class="error-message" v-if="showErrorStartDate" style="padding-left: 29%;">{{
                      this.msgDiaLog
                    }}</span>-->
                  <!--#10715:日付IF修正End-->
                  <!--add FNSI-改修内容日付のチェックの追加対応。 趙立強 end-->
                  <div v-show="isNeedDate" class="pat-header-item" style="margin-bottom: 1em;">
                    <span style="margin-right: 1em; width: 7em">期間指定終了</span>
                    <!--mod FNSI-改修内容日付のチェックの追加対応。 趙立強 start-->
                     <!-- <input
                      input-id="endDate"
                      class="input-area-date"
                      :class="{'ntss-input-date': getTypeInput === 'date'}"
                      :type="getTypeInput"
                      :max="getmax"
                      v-model="searchCondition.endDate"
                    />
                    <common-calendar v-if="getTypeInput ==='date' " class="calender" v-model="searchCondition.endDate" /> -->
                    <!--#10715:日付IF修正+param修正Start-->
                    <span v-if="getTypeInput ==='date'">
                    <date-input
                      input-id="endDate"
                      class="input-area-date end-date"
                      :class="{'ntss-input-date': getTypeInput === 'date'}"
                      :type="getTypeInput"
                      :max="getmax"
                      :isRequired="true"
                      :default-date="defaultDate"
                      @blur="chkchange()"
                      v-model="searchCondition.endDate"
                    />
                    <common-calendar v-if="getTypeInput ==='date' " class="calender end-date-comment" v-model="searchCondition.endDate" />
                    <!--mod FNSI-改修内容日付のチェックの追加対応。 趙立強 end-->
                  </span>
                  <span v-else>
                    <input
                      input-id="endDate"
                      class="input-area-date end-date"
                      :class="{'ntss-input-date': getTypeInput === 'date'}"
                      :type="getTypeInput"
                      :max="getmax"
                      @blur="chkchange()"
                      v-model="searchCondition.endDate"
                    />
                  </span>
                  </div>
                  <!--add FNSI-改修内容日付のチェックの追加対応。 趙立強 start-->
                  <!--<span class="error-message" v-if="showErrorEndDate" style="padding-left: 29%;">{{
                      this.msgDiaLog
                    }}</span>-->
                  <!--#10715:日付IF修正＋param修正End-->
                  <!--add FNSI-改修内容日付のチェックの追加対応。 趙立強 end-->
                  <div class="pat-header-item">
                    <v-ons-button :disabled="!isNeedDate" class="btn2-cancel common-style-cancel-button" :style="{ 'opacity': !isNeedDate ? 0 : 1 }" @click="dialogClear">クリア</v-ons-button>
                    <!--mod FNSI-改修内容日付のチェックの追加対応。 趙立強 start-->
                    <!-- <v-ons-button
                      class="common-style-ok-button"
                      style="height: 2em;"
                      :disabled="isDisableBtnSearch"
                      @click="rangeDate"
                    >OK</v-ons-button> -->
                    <v-ons-button
                      class="btn3-normal ok common-style-ok-button"
                      style="height: 2em; margin-left: 8em;"
                      :disabled="isDisableBtnSearch || showErrorEndDate || showErrorStartDate"
                      @click="onSearch"
                    >実行</v-ons-button>
                    <!--mod FNSI-改修内容日付のチェックの追加対応。 趙立強 end-->
                  </div>
                </template>
              </div>
            </v-ons-popover>
          </v-ons-col >
          <div class="file-button">
            <v-ons-button
              id="button-position"
              class="btn1-execute common-style-ok-button"
              style="height: 3em; width: 9em !important;"
              :disabled="allowEdit"
              @click="showListType($event)"
            >ファイル出力</v-ons-button>
          </div>
          <v-ons-popover
            cancelable
            :visible.sync="popoverInfo.popoverVisible"
            :target="popoverInfo.popoverTarget"
            :direction="popoverInfo.popoverDirection"
            :class="[fontSizeSet, 'popover-style']"
          >
            <div class="popover-content-div">
              <v-ons-row class="popover-content-row">
                <v-ons-col class="popover-content-col">
                  <label class="left">
                    <v-ons-checkbox
                      :input-id="'checkbox-1'"
                      :value="1"
                      v-model="checkedExcel"
                      @click="checkedExcel ? stopCheck($event) : checkExcel()"
                    ></v-ons-checkbox>
                  </label>
                  <label :for="'checkbox-1'" class="center">Excel</label>
                </v-ons-col>
              </v-ons-row>
              <v-ons-row class="popover-content-row">
                <v-ons-col class="popover-content-col">
                  <label class="left">
                    <v-ons-checkbox
                      :input-id="'checkbox-2'"
                      :value="2"
                      v-model="checkedCSV"
                      @click="checkedCSV ? stopCheck($event) : checkCSV()"
                    ></v-ons-checkbox>
                  </label>
                  <label :for="'checkbox-2'" class="center">CSV</label>
                </v-ons-col>
              </v-ons-row>
              <v-ons-row class="confirm" style="flex-wrap: nowrap;">
                <v-ons-col vertical-align="center">
                  <v-ons-button class="button btn2-cancel" @click="cancel">キャンセル</v-ons-button>
                </v-ons-col>
                <v-ons-col vertical-align="center" style="text-align: right;">
                  <v-ons-button class="button btn1-execute" @click="download">保存</v-ons-button>
                </v-ons-col>
              </v-ons-row>
            </div>
          </v-ons-popover>
        </v-ons-row>
      </div>
    </div>
  </v-card>
  <!-- mod FNSI-No.573 他の機能と検索操作が違っている dou end -->
</template>

<script>
import moment from "moment";
import { EventBus } from "@/eventBus.js";
import { mapGetters, mapActions } from "vuex";
import { getMstLayout, filterLayoutMstByJob, confirmAllowDiscardChangesInMultiPatList } from "@/components/multi-pat-list/Functions.js";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import PopoverMixin from "@/components/PopoverMixin";
import { deepCopy } from "@/functions/common/CommonFunctions";
// mod #11528 【たくしん会】データリスト並び順不正 房 start
import {calcTargetDate, DATE_FORMAT} from "@/functions/modals/default-setting/defaultSettingUtils"
// mod #11528 【たくしん会】データリスト並び順不正 房 end
/* add FNSI-改修内容日付のチェックの追加対応。 趙立強 start*/
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
/* add FNSI-改修内容日付のチェックの追加対応。 趙立強 end*/
// mod FNSI-No.573 デフォルト条件の修正 dou start
//import { DATE_TEMPLATE_CD, MONTH_TEMPLATE_CD, PAT_INFO_TEMPLATE_CD } from "@/constants/dataListConstant";
import { PAT_INFO_TEMPLATE_CD,
         PAT_INFO_TWO_TEMPLATE_CD,
         TREATMENT_PLAN_TREATMENT_RECORD,
         VITAL_MONITORS_COMPLAINTS_CD,
         INSPECTION_RADIATION,
         DATE_TEMPLATE_CD,
         MONTH_TEMPLATE_CD,
         DEVICE_SET,
         EQUIPMENT_INFORMATION_WATER_QUALITY_SURVEY,
         EQUIPMENT_INFORMATION_SELF_DIAGNOSIS,
         EQUIPMENT_INFORMATION_INSPECTION_DAILY_REGULAR,
         COLLECTIVE_DAILY_REGULAR
        } from "@/constants/dataListConstant";
import { LAYOUT_ITEM_BREAST_DIA, LAYOUT_ITEM_CHEST_DIA, LAYOUT_ITEM_CTR, LAYOUT_ITEM_CTR_CARDIAC_LATERAL_DIAMETER, LAYOUT_ITEM_CTR_WEIGHT, LAYOUT_ITEM_DW, LAYOUT_ITEM_DW_TARGET_WEIGHT, LAYOUT_ITEM_EXAM_DATE, LAYOUT_ITEM_EXAM_TIME, LAYOUT_ITEM_HEIGHT, LAYOUT_ITEM_INDICATOR_CDNAME, LAYOUT_ITEM_INDICATOR_START_DATE, LAYOUT_ITEM_MEMO, LAYOUT_ITEM_ORDER_CLASSNAME, LAYOUT_ITEM_PREVIOUS_WEIGHT_ALLOWANCE_LIMIT, LAYOUT_ITEM_PRE_SCALE_LOWER, LAYOUT_ITEM_PRE_SCALE_UPPER, LAYOUT_ITEM_PRE_WEIGHT_TOLERANCE_LOWER_LIMIT, LAYOUT_ITEM_STATURE, LAYOUT_ITEM_TARGET_WEIGHT, LAYOUT_ITEM_WEIGHT_AT_TIME_INSPECTION, layout_item_MEMORANDUM } from "@/components/multi-pat-list/Definitions";
// mod FNSI-No.573 デフォルト条件の修正 dou end

import { KEY_NAME_MULTI_PAT_LIST } from "@/constants/defaultSettingConstants";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
// add #10054 破棄確認・保存活性(複数変更含む)・削除対応_データリスト（患者情報） 20231221 ztc start
import {messageFormat} from "@/functions/common/MessageFormat";
// add #10054 破棄確認・保存活性(複数変更含む)・削除対応_データリスト（患者情報） 20231221 ztc end
//#10715:日付IF修正Start
import DateInput from "@/components/common/DateInput.vue";
//#10715:日付IF修正End

export default {
  components: {
    //#10715:日付IF修正Start
    "common-calendar": commonCalender,
    "date-input":DateInput
    //#10715:日付IF修正End
  },
  mixins: [PopoverMixin],
  data() {
    return {
// add FNSI-No.573 他の機能と検索操作が違っている dou start
      // 吹き出し表示フラグ
      popoverVisible: false,
      // 吹き出し位置※左右
      popoverTarget: null,
      // 吹き出し位置※下に表示
      popoverDirection: "down",
// add FNSI-No.573 他の機能と検索操作が違っている dou end
      layoutMst: null,
      mstList: {},
      selectedLayout: 0,
      selectedType: 1,
      popoverInfo: {
        popoverVisible: false,
        popoverTarget: null,
        popoverDirection: "down",
        titleLabel: null
      },
      checkedExcel: true,
      checkedCSV: false,
      searchCondition: {
        startDate: null,
        endDate: null
      },
      defaultStartDate: null,
      /* add FNSI-改修内容日付のチェックの追加対応。 趙立強 start*/
      msgDiaLog: DIALOG_MESSAGES["99999995"].message,
      showErrorStartDate: false,
      showErrorEndDate: false,
      allowEdit: false, // ファイル出力ボタン 活性or非活性 制御
      /* add FNSI-改修内容日付のチェックの追加対応。 趙立強 end*/
      // FNSI-修正、#6520、データリスト検索条件に、期間指定についての改善、xugj add start
      searchConditionExec: {
        startDate: null,
        endDate: null
      },
      // FNSI-修正、#6520、データリスト検索条件に、期間指定についての改善、xugj add end
      // 期間指定
      rangeDateDefault: {}
    };
  },
  // add #6256 背景色が変わらない 徐博 start
  props: {
    getInfo: { type: Function, default: null }
  },
  // add #6256 背景色が変わらない 徐博 end
  computed: {
    ...mapGetters("pat-info", ["searchedPatList"]),
    ...mapGetters("account-edit", {
      userInfo: "getStateUserAccountInfo",
      getDefaultSetting: "getDefaultSetting"
    }),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("data-list", ["getSelectedDynamicLayout", "getRangeDate"]),
// add FNSI-No.223 レイアウトおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou start
    /** 期間指定開始、期間指定終了（抽出条件エリア） の表示有無 */ 
    isNeedDateConditionArea() {
      if (this.layoutMst === null) return false;
      // storeの選択済レイアウトで判定
      if (this.getSelectedDynamicLayout && this.getSelectedDynamicLayout.templateCd != PAT_INFO_TEMPLATE_CD
          && this.getSelectedDynamicLayout.templateCd != PAT_INFO_TWO_TEMPLATE_CD
          && this.getSelectedDynamicLayout.templateCd != DEVICE_SET) {
        return true;
      }
      return false;
    },
    /** 期間指定開始、期間指定終了 の表示必要有無 */ 
    isNeedDate() {
      if (this.layoutMst === null) return false;
      // 吹き出しの選択済レイアウトで判定
      if (this.selectLayout && this.selectLayout.templateCd != PAT_INFO_TEMPLATE_CD
          && this.selectLayout.templateCd != PAT_INFO_TWO_TEMPLATE_CD
          && this.selectLayout.templateCd != DEVICE_SET) {
        return true;
      }
      return false;
    },
// add FNSI-No.223 レイアウトおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou end
    isDisableBtnSearch() {
      // データリストレイアウトマスタ0件、未設定職種は非活性
      if (this.layoutMst === null || !this.selectLayout) return true;
      if (!this.isNeedDate) return false;
      if (this.searchCondition.startDate === null || this.searchCondition.endDate === null) {
        return true;
      }
      const startDate = moment(this.searchCondition.startDate);
      const endDate = moment(this.searchCondition.endDate);
      if (endDate.isBefore(startDate)) {
        return true;
      }
      return false;
    },

    // add FNSI-改修内容 年の最大桁は4桁に修正する 趙 start
    getmax(){
      let max = "9999-12-31";
      if(this.getTypeInput === "month"){
        max = "9999-12";
      }
      return max;
    },
    // add FNSI-改修内容 年の最大桁は4桁に修正する 趙 end

    getTypeInput() {
      let type = "date";
      if (this.selectLayout && this.selectLayout.templateCd === MONTH_TEMPLATE_CD) {
        type = "month"
      }
      return type;
    },
    //#11059:定期点検履歴画面の日付IF修正Start
    defaultDate() {
      return "9999-99-99";
    },
    //#11059:定期点検履歴画面の日付IF修正End
    /** 選択中のレイアウト情報 */ 
    selectLayout() {
      if (this.layoutMst === null) return {};
      return this.layoutMst[this.selectedLayout];
    }
  },
  watch: {
    selectedLayout(value) {
      if (this.layoutMst[value].dispItemInfo === null) this.layoutMst[value].dispItemInfo = [];
      
      this.showErrorStartDate = false;
      this.showErrorEndDate = false;
      
      // 親側に選択済のレイアウト情報を保持
      this.$emit("changeLayout", this.layoutMst[value]);
      this.setRangeDateDefault();
    },
    //#10715:日付IF修正Start
    'searchCondition.endDate'() {
      const template_type = [PAT_INFO_TEMPLATE_CD, PAT_INFO_TWO_TEMPLATE_CD, DEVICE_SET];
      let date_stat = template_type.includes(this.selectLayout.templateCd);
      if(!date_stat && (this.searchCondition.endDate === null || this.searchCondition.endDate === '' )) {
        this.showErrorEndDate = true;
      } else {
      //#10715:日付IF修正End
        this.showErrorEndDate = false;
      }
    },
    'searchCondition.startDate'() {
      //#10715:日付IF修正Start
       const template_type = [PAT_INFO_TEMPLATE_CD, PAT_INFO_TWO_TEMPLATE_CD, DEVICE_SET];
       let date_stat = template_type.includes(this.selectLayout.templateCd);
       if(!date_stat && (this.searchCondition.startDate === null || this.searchCondition.startDate === '' )) {
         this.showErrorStartDate = true;
       } else {
         this.showErrorStartDate = false;
      }
    },
    //#10715:日付IF修正End
  },

  beforeDestroy() {
    EventBus.$off("allowEditTrue");
    Object.assign(this.$data, this.$options.data());
  },
  async created() {
    // add #7430 画面移行時に前の画面のDBへの要求が閉じてない dou start
    this.setLoadingScreenVisible(true);
    // add #7430 画面移行時に前の画面のDBへの要求が閉じてない dou end
    EventBus.$off("allowEditTrue");
    EventBus.$on("allowEditTrue", data => (this.allowEdit = data));

    // データリストレイアウトマスタ取得
    this.mstList = await getMstLayout(this.facilityCd).catch(error => {
      getErrorMessage('MultiPatHeader.vue', 'created', error);
      this.isLoading = false;
      throw new Error(error);
    });

    // レイアウトマスタ有:ヘッダ項目情報を指定してカラム表示
    if (this.mstList && this.mstList.mst_layout) {

      // ユーザーの職種で表示設定ONのデータリストレイアウトマスタを抽出
      this.layoutMst = filterLayoutMstByJob(this.userInfo.jobCd, this.mstList.mst_layout);

// add FNSI-No.573 他の機能と検索操作が違っている dou start
      if (this.layoutMst == null || this.layoutMst.length === 0) {
        // storeクリア
        this.setSelectedDynamicLayout(null);
        
        alert("マスター画面に移動してレイアウトを選択してください");
        this.setLoadingScreenVisible(false);
        // return;
      } else {
// add FNSI-No.573 他の機能と検索操作が違っている dou end
// add データリストの患者情報修正 陳 start
        this.layoutMst.forEach(mst => {
          mst.dispItemInfo.forEach(dispItem => {
            if (dispItem.category === "physical_info") {
              let disItems = [];

              // add #11321 【たくしん会】データリストレイアウトマスタ＞身体情報(追加登録)とデータリスト表示バグ zkm start
              if (dispItem.items.length > 0) {
                disItems.push(LAYOUT_ITEM_EXAM_DATE.key);
                disItems.push(LAYOUT_ITEM_EXAM_TIME.key);
              }
              // add #11321 【たくしん会】データリストレイアウトマスタ＞身体情報(追加登録)とデータリスト表示バグ zkm end

              dispItem.items.forEach(item => {
                // mod #11321 【たくしん会】データリストレイアウトマスタ＞身体情報(追加登録)とデータリスト表示バグ zkm start
                // if (item === LAYOUT_ITEM_INSPECTION_DATE_TIME.key) {
                //   disItems.push(LAYOUT_ITEM_EXAM_DATE.key);
                //   disItems.push(LAYOUT_ITEM_EXAM_TIME.key);
                // } else if (item === LAYOUT_ITEM_WEIGHT_AT_TIME_INSPECTION.key) {
                if (item === LAYOUT_ITEM_WEIGHT_AT_TIME_INSPECTION.key) {
                // mod #11321 【たくしん会】データリストレイアウトマスタ＞身体情報(追加登録)とデータリスト表示バグ zkm end
                  disItems.push(LAYOUT_ITEM_ORDER_CLASSNAME.key);
                  disItems.push(LAYOUT_ITEM_CTR_WEIGHT.key);
                } else if (item === LAYOUT_ITEM_STATURE.key) {
                  disItems.push(LAYOUT_ITEM_HEIGHT.key);
                } else if (item === LAYOUT_ITEM_CTR_CARDIAC_LATERAL_DIAMETER.key) {
                  disItems.push(LAYOUT_ITEM_BREAST_DIA.key);
                  disItems.push(LAYOUT_ITEM_CHEST_DIA.key);
                  disItems.push(LAYOUT_ITEM_CTR.key);
                } else if (item === LAYOUT_ITEM_DW_TARGET_WEIGHT.key) {
                  disItems.push(LAYOUT_ITEM_DW.key);
                  disItems.push(LAYOUT_ITEM_TARGET_WEIGHT.key);
                  disItems.push(LAYOUT_ITEM_INDICATOR_START_DATE.key);
                  disItems.push(LAYOUT_ITEM_INDICATOR_CDNAME.key);
                } else if (item === LAYOUT_ITEM_PREVIOUS_WEIGHT_ALLOWANCE_LIMIT.key) {
                  disItems.push(LAYOUT_ITEM_PRE_SCALE_UPPER.key);
                } else if (item === LAYOUT_ITEM_PRE_WEIGHT_TOLERANCE_LOWER_LIMIT.key) {
                  disItems.push(LAYOUT_ITEM_PRE_SCALE_LOWER.key);
                } else if (item === layout_item_MEMORANDUM.key) {
                  disItems.push(LAYOUT_ITEM_MEMO.key);
                } else {
                  disItems.push(item);
                }
              });
              // del #11321 【たくしん会】データリストレイアウトマスタ＞身体情報(追加登録)とデータリスト表示バグ zkm start
              // const orderClassIndex = disItems.indexOf(LAYOUT_ITEM_ORDER_CLASSNAME.key);
              // if (orderClassIndex !== -1) {
              //   disItems.splice(orderClassIndex, 1);
              //   const examTimeIndex = disItems.indexOf(LAYOUT_ITEM_EXAM_TIME.key);
              //   orderClassIndex !== -1 && disItems.splice(examTimeIndex + 1, 0, LAYOUT_ITEM_ORDER_CLASSNAME.key);
              // }
              // del #11321 【たくしん会】データリストレイアウトマスタ＞身体情報(追加登録)とデータリスト表示バグ zkm end
              dispItem.items = disItems;
            }
          });
        });
      }
// add データリストの患者情報修正 陳 start
    }
    if (this.layoutMst == null || this.layoutMst.length === 0) {
      return;
    }
    if (this.layoutMst[0].dispItemInfo === null) {
      this.layoutMst[0].dispItemInfo = [];
    }
    let index = 0;
    // 以前の設定がある場合は初期値として適用
    if (this.getSelectedDynamicLayout) {
      const patListLayoutCd = this.getSelectedDynamicLayout.patListLayoutCd;
      const indexLayout = this.layoutMst.findIndex(layout => layout.patListLayoutCd === patListLayoutCd);
      index = indexLayout === -1 ? 0 : indexLayout;
    } else {
      // 以前の設定がない場合は、デフォルト設定を適用
      const defaultCondition = deepCopy(this.getDefaultSetting[KEY_NAME_MULTI_PAT_LIST.KEY_NAME]);
      if (!(!defaultCondition || Object.keys(defaultCondition).length === 0)) {
        // レイアウト
        const patListLayoutCd = defaultCondition[KEY_NAME_MULTI_PAT_LIST.KEY_NAME_SELECTED_LAYOUT];
        const indexLayout = this.layoutMst.findIndex(layout => layout.patListLayoutCd === patListLayoutCd);
        index = indexLayout === -1 ? 0 : indexLayout;
        // 開始日付
        this.defaultStartDate = calcTargetDate(defaultCondition[KEY_NAME_MULTI_PAT_LIST.KEY_NAME_START_DATE]);
        // add #11528 【たくしん会】データリスト並び順不正 房 start
        if(!this.defaultStartDate) {
          this.defaultStartDate = moment().format(DATE_FORMAT)
        }
        // add #11528 【たくしん会】データリスト並び順不正 房 end
      }
    }
    this.selectedLayout = index;
    this.setSelectedDynamicLayout(this.layoutMst[index]);
    this.setSelectedLayout(this.layoutMst[index].dispItemInfo);
    this.setRangeDateDefault(true);
    // 親側に選択済レイアウト情報を保持
    this.$emit("changeLayout", this.layoutMst[index]);
    // add #7430 画面移行時に前の画面のDBへの要求が閉じてない dou start
    // 共通ローダー:表示終了
    this.setLoadingScreenVisible(false);
    // add #7430 画面移行時に前の画面のDBへの要求が閉じてない dou end
  },
  // add #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang start
  updated() {
    this.setLoadFlag(true);
  },
  // add #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang end
  methods: {
    // add #7430 画面移行時に前の画面のDBへの要求が閉じてない dou start
    // 共通ローダー設定
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible"
    ]),
    // add #7430 画面移行時に前の画面のDBへの要求が閉じてない dou end
    // mod #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang start
    ...mapActions("data-list", [
      "setRequestExportCSV",
      "setRequestExportExcel",
      "setSelectedLayout",
      "setSelectedDynamicLayout",
      "setRangeDate",
      "setInitflg",
      "setLoadFlag",
      "setIsDataChanged"
    ]),
    // mod #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang end
    ...mapActions("pat-info", ["selectPat"]),
// add FNSI-No.573 他の機能と検索操作が違っている dou start
    // 共通ローダー設定
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    //#10715:日付IF修正Start
    chkchange() {
        if (this.searchCondition.startDate === null || this.searchCondition.startDate === '' || this.searchCondition.startDate === '9999-99-99') this.searchCondition.startDate = this.searchConditionExec.startDate;
        if (this.searchCondition.endDate === null || this.searchCondition.endDate === '' || this.searchCondition.endDate === '9999-99-99') this.searchCondition.endDate = this.searchConditionExec.endDate;
      },
    //#10715:日付IF修正End
    dialogClear() {
      //#10715:日付IF修正Start
      this.searchCondition.startDate = this.searchConditionExec.startDate;
      this.searchCondition.endDate = this.searchConditionExec.endDate;
      /*
      setTimeout(() => {
        this.showErrorStartDate = true;
        this.showErrorEndDate = true;
      }, 100);*/
      //#10715:日付IF修正End
    },
    /**
     * @description 吹き出し表示
     */
    showPopover(event) {
      // FNSI-修正、#6520、データリスト検索条件に、期間指定についての改善、xugj add start
      this.searchCondition = JSON.parse(JSON.stringify(this.searchConditionExec));
      // FNSI-修正、#6520、データリスト検索条件に、期間指定についての改善、xugj add end
      
      // 前回実行時のレイアウト設定
      let index = 0;
      if (this.getSelectedDynamicLayout) {
        const patListLayoutCd = this.getSelectedDynamicLayout.patListLayoutCd;
        const indexLayout = this.layoutMst.findIndex(layout => layout.patListLayoutCd === patListLayoutCd);
        index = indexLayout === -1 ? 0 : indexLayout;
      }
      this.selectedLayout = index;      
      
      // 吹き出し表示位置
      this.popoverTarget = event;
      // 吹き出し表示
      this.popoverVisible = true;
    },
// add FNSI-No.573 他の機能と検索操作が違っている dou end
    showListType(event) {
      this.popoverInfo.popoverTarget = event;
      this.popoverInfo.popoverVisible = true;
    },
    checkCSV() {
      this.checkedExcel = false;
      this.selectedType = 2;
    },
    checkExcel() {
      this.checkedCSV = false;
      this.selectedType = 1;
    },
    stopCheck(e) {
      e.preventDefault();
    },
    download() {
      this.selectedType === 1
        ? this.setRequestExportExcel()
        : this.setRequestExportCSV();
      this.popoverInfo.popoverVisible = false;
    },
    cancel() {
      this.popoverInfo.popoverVisible = false;
    },
    /** 吹き出し表示＞実行ボタン押下時処理 */ 
    async onSearch() {
      // 患者情報1で変更がある場合、破棄確認メッセージを表示
      const answer = await confirmAllowDiscardChangesInMultiPatList();
      if (answer === 1) {
        // 検索実行
        this.rangeDate(); 
      }
    },
    /** 吹き出し表示＞実行処理 */ 
    rangeDate() {
      this.allowEdit = false;
      this.setLoadFlag(false);
      
      if (this.selectLayout.templateCd === DATE_TEMPLATE_CD ||
        this.selectLayout.templateCd === MONTH_TEMPLATE_CD) {
        EventBus.$emit("setFooterMsgFlg", true);
        this.allowEdit = true;
      }
      
      // 患者情報2、装置設定
      if (this.selectLayout.templateCd === PAT_INFO_TWO_TEMPLATE_CD ||
        this.selectLayout.templateCd === DEVICE_SET ) {
        this.setInitflg(true);
        this.$emit("onSearch"); // 親に実行を通知
        this.setInitflg(false);
        
        this.popoverVisible = false;
        
        // add #6256 背景色が変わらない 徐博 start
        this.getInfo();
        // add #6256 背景色が変わらない 徐博 end
        
        this.$nextTick(() => {
          // 親側でstore更新後にコンテンツ表示処理実行
          EventBus.$emit("onInitLayout");
        })
        return;
      }
      // 患者情報1
      if (this.selectLayout.templateCd === PAT_INFO_TEMPLATE_CD ) {
        this.$emit("onSearch"); // 親に実行を通知
        
        this.popoverVisible = false;

        // add #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang start
        this.$nextTick(() => {
          // 親側でstore更新後にフラグON
          this.setLoadFlag(true);
          // 親側でstore更新後にコンテンツ表示処理実行
          EventBus.$emit("refresh");
        })
        // add #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang end       
        return;
      }
      
      // 日付整合性チェック
      let startDate = moment(this.searchCondition.startDate);
      let endDate = moment(this.searchCondition.endDate);
      if (startDate.isAfter(endDate) || !startDate.isValid() || !endDate.isValid()) {
        return;
      }
      
      // add #11873【因島】データリスト「治療予定・実績」テンプレートでサーバダウン fang start
      if(this.selectLayout.templateCd === TREATMENT_PLAN_TREATMENT_RECORD) {
        let tempCompareDate = moment(startDate.toDate().getTime());
        let compareEndTime = tempCompareDate.add(3, 'months').toDate().getTime();
        let endTime = endDate.toDate().getTime();
        // mod 11182 個人設定画面 データリスト画面のテンプレート毎の期間の選択肢不正 zkm start
        const startOfToday = moment().startOf('day').valueOf();
        let warnFlg = false;
        if (endTime > startOfToday) {
          if (startOfToday > compareEndTime) {
            warnFlg = true;
          }
        } else {
          if (endTime > compareEndTime) {
            warnFlg = true;
          }
        }
        // if(endTime > compareEndTime) {
        if(warnFlg) {
          // mod 11182 個人設定画面 データリスト画面のテンプレート毎の期間の選択肢不正 zkm end
          // メインコンテンツ表示ありの場合、ファイル出力ボタンは活性のまま
          const el = document.querySelector('.multi-pat-list');
          this.allowEdit = !el;
          return this.$ons.notification.alert(messageFormat(DIALOG_MESSAGES[14000001].message), {
            title: DIALOG_MESSAGES[14000001].title
          });
        }
      }
      // add #11873【因島】データリスト「治療予定・実績」テンプレートでサーバダウン fang end      
      
      // FNSI-修正、#6520、データリスト検索条件に、期間指定についての改善、xugj add start
      this.searchConditionExec = JSON.parse(JSON.stringify(this.searchCondition));
      // FNSI-修正、#6520、データリスト検索条件に、期間指定についての改善、xugj add end

      // レイアウト毎に日付をフォーマット
      if (this.selectLayout.templateCd === DATE_TEMPLATE_CD || this.selectLayout.templateCd === EQUIPMENT_INFORMATION_WATER_QUALITY_SURVEY) {
        startDate = startDate.format("YYYY-MM-DD");
        endDate = endDate.format("YYYY-MM-DD");
      }
      if (this.selectLayout.templateCd === MONTH_TEMPLATE_CD) {
        startDate = startDate.format("YYYY-MM");
        endDate = endDate.format("YYYY-MM");
      }
      
      const dayObj = {
        startDate,
        endDate
      }
      const dateRange = this.rangeDateDefault;
      const index = dateRange.findIndex(d => d.layoutCd === this.selectLayout.patListLayoutCd);
      if (index >= 0) {
        dateRange[index].dayObj = dayObj;
      }
      this.setRangeDate(dateRange);
// add FNSI-No.573 デフォルト条件の修正 dou start
      this.popoverVisible = false;
// add FNSI-No.573 デフォルト条件の修正 dou end

      this.setInitflg(true);
      this.$emit("onSearch"); // 親に実行を通知
      this.setInitflg(false);
      
      this.$nextTick(() => {
        // 親側でstore更新後にコンテンツ表示処理実行
        EventBus.$emit("onInitLayout", 1);
      })
    },

    /**
     * 期間指定開始、期間指定終了の設定
     * @param {*} updateExecDate 実行条件日付の更新有無 
     */
    setRangeDateDefault(updateExecDate) {
// mod FNSI-No.573 デフォルト条件の修正 dou start
      const templateCd = this.selectLayout.templateCd;
      if (templateCd === PAT_INFO_TEMPLATE_CD
          || templateCd === PAT_INFO_TWO_TEMPLATE_CD
          || templateCd === DEVICE_SET) {
        this.searchCondition.startDate = "";
        this.searchCondition.endDate = "";
        return;
      }
      let rangeDate = this.getRangeDate;
      const patListLayoutCd = this.selectLayout.patListLayoutCd;
      let startDate = "";
      let endDate = "";
      switch (templateCd) {
        case TREATMENT_PLAN_TREATMENT_RECORD:
          startDate = moment().startOf('month').add('month', -1).format("YYYY-MM-DD");
          endDate = moment().endOf('month').format("YYYY-MM-DD");
          break;
        case VITAL_MONITORS_COMPLAINTS_CD:
          startDate = moment().startOf('month').add('month', -1).format("YYYY-MM-DD");
          endDate = moment().endOf('month').format("YYYY-MM-DD");
          break;
        case INSPECTION_RADIATION:
          startDate = moment().startOf('month').add('month', -3).format("YYYY-MM-DD");
          endDate = moment().endOf('month').format("YYYY-MM-DD");
          break;
        case DATE_TEMPLATE_CD:
          startDate = moment().startOf('month').add('month', -1).format("YYYY-MM-DD");
          // mod 11182 個人設定画面 データリスト画面のテンプレート毎の期間の選択肢不正 zkm start
          // endDate = moment().endOf('month').format("YYYY-MM-DD");
          endDate = moment().format("YYYY-MM-DD");
          // mod 11182 個人設定画面 データリスト画面のテンプレート毎の期間の選択肢不正 zkm end
          break;
        case MONTH_TEMPLATE_CD:
          startDate = moment().startOf('month').add('month', -11).format("YYYY-MM");
          endDate = moment().endOf('month').format("YYYY-MM");
          break;
        case EQUIPMENT_INFORMATION_WATER_QUALITY_SURVEY:
          startDate = moment().add('year', -1).format("YYYY-MM-DD");
          endDate = moment().format("YYYY-MM-DD");
          break;
        case COLLECTIVE_DAILY_REGULAR:
          startDate = moment().add('week', -2).format("YYYY-MM-DD");
          endDate = moment().format("YYYY-MM-DD");
          break;
        case EQUIPMENT_INFORMATION_SELF_DIAGNOSIS:
          startDate = moment().add('week', -2).format("YYYY-MM-DD");
          endDate = moment().format("YYYY-MM-DD");
          break;
        case EQUIPMENT_INFORMATION_INSPECTION_DAILY_REGULAR:
          startDate = moment().add('week', -2).format("YYYY-MM-DD");
          endDate = moment().format("YYYY-MM-DD");
          break;
        default:
          break;
      }
      if (this.defaultStartDate) {
        startDate = this.defaultStartDate;
        if (templateCd === MONTH_TEMPLATE_CD) {
          // 集計(月別) は日付フォーマット
          startDate = moment(startDate).format("YYYY-MM");
        }
      }
      if (rangeDate.length === 0) {
        const dayObj = {
          startDate: startDate,
          endDate: endDate
        }
        let obj = {
          layoutCd: patListLayoutCd,
          dayObj
        };
        rangeDate.push(obj)
      }
      
      // 期間指定をプロパティに保持
      this.rangeDateDefault = rangeDate;
      
      const existDayObj = rangeDate.find(d => d.layoutCd === patListLayoutCd);
      // del 11182 個人設定画面 データリスト画面のテンプレート毎の期間の選択肢不正 zkm start
      // // add #11873【因島】データリスト「治療予定・実績」テンプレートでサーバダウン fang start
      // if(templateCd === TREATMENT_PLAN_TREATMENT_RECORD) {
      //   if(existDayObj) {
      //     existDayObj.dayObj.startDate = this.calculateDate(existDayObj.dayObj.startDate, existDayObj.dayObj.endDate);
      //   }
      // }
      // // add #11873【因島】データリスト「治療予定・実績」テンプレートでサーバダウン fang end
      // del 11182 個人設定画面 データリスト画面のテンプレート毎の期間の選択肢不正 zkm end
      if (!existDayObj) {
        // del 11182 個人設定画面 データリスト画面のテンプレート毎の期間の選択肢不正 zkm start
        // // add #11873【因島】データリスト「治療予定・実績」テンプレートでサーバダウン fang start
        // if(templateCd === TREATMENT_PLAN_TREATMENT_RECORD) {
        //   startDate = this.calculateDate(startDate, endDate);
        // }
        // // add #11873【因島】データリスト「治療予定・実績」テンプレートでサーバダウン fang end
        // del 11182 個人設定画面 データリスト画面のテンプレート毎の期間の選択肢不正 zkm end
        const newObj = {
          layoutCd: patListLayoutCd,
          dayObj: {
            startDate: startDate,
            endDate: endDate
          }
        };
        rangeDate.push(newObj)
        this.searchCondition.startDate = newObj.dayObj.startDate;
        this.searchCondition.endDate = newObj.dayObj.endDate;
        this.copySearchCondition(updateExecDate);
        return;
      }
      const index = rangeDate.findIndex(d => d.layoutCd === patListLayoutCd);
      if (index >= 0) {
        switch (templateCd) {
        case MONTH_TEMPLATE_CD:
          this.searchCondition.startDate = moment(rangeDate[index].dayObj.startDate).format("YYYY-MM");
          this.searchCondition.endDate = moment(rangeDate[index].dayObj.endDate).format("YYYY-MM");
          this.copySearchCondition(updateExecDate);
          break;
        default:
          this.searchCondition.startDate = moment(rangeDate[index].dayObj.startDate).format("YYYY-MM-DD");
          this.searchCondition.endDate = moment(rangeDate[index].dayObj.endDate).format("YYYY-MM-DD");
          this.copySearchCondition(updateExecDate);
          break;
      }

      }
    },
    copySearchCondition(updateExecDate) {
      if (updateExecDate) {
        this.searchConditionExec = JSON.parse(JSON.stringify(this.searchCondition));
      }
    },
  // mod FNSI-No.573 デフォルト条件の修正 dou end
    // del 11182 個人設定画面 データリスト画面のテンプレート毎の期間の選択肢不正 zkm start
    // // add #11873【因島】データリスト「治療予定・実績」テンプレートでサーバダウン fang start
    // calculateDate(startDate, endDate) {
    //   let startDateStr = startDate;
    //   let endDateStr = endDate;
    //   let compareEndTime = moment(endDateStr);
    //   let compareStartDate = moment(startDateStr);
    //   let tempCompareEndTime = compareStartDate.add(3, 'months').toDate().getTime();
    //   if(tempCompareEndTime < compareEndTime.toDate().getTime()) {
    //     return compareEndTime.subtract(3, "months").add(1, "days").format("YYYY-MM-DD");
    //   }
    //   return startDateStr;
    // },
    // // add #11873【因島】データリスト「治療予定・実績」テンプレートでサーバダウン fang end
    // del 11182 個人設定画面 データリスト画面のテンプレート毎の期間の選択肢不正 zkm end
  }
}
</script>

<style scoped>
.pat-header {
  width: 100%;
  height: 4.2em;
  color: var(--ntss-list-body-color);
  background-color: var(--header-item-background-color);
  font-size: 1.5em;
}
ons-select.pat-combo {
  border-radius: 5px;
  border: none;
}
ons-button#button-position {
  /*float: right;*/
  /*add FNSI-改修内容 共通検索欄で検索条件の内容が長すぎの場合、スクロールバーが出てこない  趙立強 start */
  /* margin-right: 117px; */
  /*margin-right: 20vw;*/
  /*add FNSI-改修内容 共通検索欄で検索条件の内容が長すぎの場合、スクロールバーが出てこない  趙立強 start */
  width: auto;
}
.popover-content-div {
  margin: 5px;
}
.popover-content-row {
  margin: 5px 0px;
}
.common-style-cancel-button {
  width: 100%;
  height: auto;
}
ons-col {
  margin: 5px;
}
ons-checkbox {
  margin-right: 5px;
}

.condition-pat-header {
  display: flex;
  height: 100%;
  margin-left: 30px;
  overflow-y: auto;
}
.pat-header-item {
  display: flex;
  height: 100%;
  align-items: center;
  padding: 0px 5px;
}
.pat-header-item:last-child {
  margin-left: auto;
}
.input-area-date {
  max-width: 205px;
  background-color: #F7F7F7;
}
/* add FNSI-No.573 他の機能と検索操作が違っている dou start */
.condition-search-col {
  flex: 0 0 55%;
}
#bbs-search-area table th {
  background-image: none;
  /*add FNSI-改修内容検索欄（共通）改修（全部表示される） 王 start */
    height:1em;
  /*add FNSI-改修内容検索欄（共通）改修（全部表示される） 王 end */

}
/* スクロール対応 */
.condition-search-area-multi {
  margin-left: 0;
  /*del FNSI-改修内容検索欄（共通）改修（全部表示される） 王 start */
  /*height: 5em;*/
  /*del FNSI-改修内容検索欄（共通）改修（全部表示される） 王 end */
  /*add FNSI-改修内容 共通検索欄で検索条件の内容が長すぎの場合、スクロールバーが出てこない dou start */
  height: 5.2em;
  /*add FNSI-改修内容 共通検索欄で検索条件の内容が長すぎの場合、スクロールバーが出てこない dou end */
  font-size: 1em;
  /*margin: -1px;*/
  margin-right: 4px;
  margin-top: -1px;
}
.file-button {
  /*margin-left: auto;*/
  position: relative;
  top: 1.5em;
}
.button {
  height: 2em;
  width: 7em !important;
}
.margin_left_30 {
  margin-left: 30px;
}
.margin_left_5 {
  margin-left: 5px;
}
.search-condition {
  padding: 0.5em;
  overflow: auto;
  padding-left: 2.5em;
}
/* スタイルの調整 4204 shan start */
.search-condition > .condition {
  margin: 0.2em;
  border: 1px solid lightgray;
  border-radius: 40px;
  padding: 0.2em 0.4em;
  line-height: 1;
}
/* スタイルの調整 4204 shan end */
.condition-label {
  border: solid 1px lightgray;
  /* 枠線のスタイル */
  border-radius: 10px;
  /* フォントサイズ */
  font-size: 1.3em;
  /* 枠線の角 */
  padding: 2px;
  /* 外枠と内枠のスペース */
  margin-left: 5px;
}
.position_absolute {
  position: absolute;
  top: 5px;
  left: 25px;
  /*add FNSI-改修内容 共通検索欄で検索条件の内容が長すぎの場合、スクロールバーが出てこない  趙立強 start */
  /* width: 80em; */
  width: 38%;
  /*add FNSI-改修内容 共通検索欄で検索条件の内容が長すぎの場合、スクロールバーが出てこない  趙立強 end */
}
.popover-area >>> .popover--top {
  width: 32em;
}
.popover-area >>> .popover--top__content {
  line-height: 2em;
  height: 100%;
}
/* add FNSI-No.573 他の機能と検索操作が違っている dou end */
.popover-area >>> .popover-mask {
  z-index: 999 !important;
}
</style>
