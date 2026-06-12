<template>
  <v-card>
    <div class="header-item">
      <v-ons-row class="mark-leftmost-header leftmost-header">
        <v-ons-col class="condition-search-col">
          <common-searcharea :conditionList="conditionList" @show-popover='showSearch' ref="searchBar"/>
        </v-ons-col>
        <v-ons-col></v-ons-col>
      </v-ons-row>
    </div>

    <!-- Treatment unit search -->
    <v-ons-popover
      cancelable
      v-model:visible="treatmentSearchVisible"
      :target="$refs.searchBar"
      direction="down"
      @prehide="prehideTreatmentSearch"
      :class="[fontSizeSet, 'indication-list-header-popover']"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div id="treatment-search" class="popover-search">
        <div class="d-flex flex-column">
          <label for="treatment-date">治療日</label>
          <div class="d-flex flex-column">
            <div class="flex-align-center">
              <date-input
                v-model="tempTreatmentSearchCondition.treatmentDate"
                :classes="'ntss-input-date ntss-custom-input'"
                id="treatment-date"
                name="treatment-date"
                data-validation-scope="treatment"
                isRequired
              />
              <common-calendar v-model="tempTreatmentSearchCondition.treatmentDate" />
            </div>
            <span class="error-message">{{
              getValidationError("treatment.treatment-date")
            }}</span>
          </div>
        </div>

        <div class="d-flex flex-column">
          <label for="treatment-method">治療方法</label>
          <div class="d-flex flex-column">
            <kendo-dropdownlist
              :data-source="mstTreatment"
              v-model="tempTreatmentSearchCondition.treatmentCd"
              data-text-field="treatmentName"
              data-value-field="treatmentCd"
              name="treatment-method"
              data-validation-scope="treatment"
              v-rules.immediate="'required'"
            />
            <span class="error-message">{{
              getValidationError("treatment.treatment-method")
            }}</span>
          </div>
        </div>

        <div class="d-flex flex-column">
          <label>クール</label>
          <div class="d-flex flex-column">
            <kendo-multiselect
              :data-source="mstKur"
              v-model="tempTreatmentSearchCondition.kurCds"
              data-text-field="kurName"
              data-value-field="kurCd"
              name="kur"
              data-validation-scope="treatment"
            />
          </div>
        </div>

        <div class="d-flex flex-column">
          <label>ベッドグループ</label>
          <kendo-dropdownlist
            :data-source="mstRoomBedGroup"
            v-model="tempTreatmentSearchCondition.bedGroupCd"
            data-text-field="roomBedGroupName"
            data-value-field="roomBedGroupCd"
          />
        </div>

        <div class="d-flex flex-column">
          <label v-show="columnStatus.isShowChecker1 || columnStatus.isShowChecker2 || columnStatus.isShowApprover1 || columnStatus.isShowApprover2"
                 style="margin-bottom: 10px">
                  未指示受け、未指示承認の表示</label>
          <div class="d-flex flex-column switch-group">
            <div class="d-flex align-items-center" v-show="columnStatus.isShowChecker1">
              <label for="checker1HasNotReceived" class="label-style">未指示受け1のみ表示</label>
              <v-ons-switch
                input-id="checker1HasNotReceived"
                v-model="tempTreatmentSearchCondition.checker1HasNotReceived"
              />
            </div>

            <div class="d-flex align-items-center" v-show="columnStatus.isShowChecker2">
              <label for="checker2HasNotReceived" class="label-style">未指示受け2のみ表示</label>
              <v-ons-switch
                input-id="checker2HasNotReceived"
                v-model="tempTreatmentSearchCondition.checker2HasNotReceived"
              />
            </div>

            <div class="d-flex align-items-center" v-show="columnStatus.isShowApprover1">
              <label for="approver1HasNotApproved" class="label-style">未指示承認1のみ表示</label>
              <v-ons-switch
                input-id="approver1HasNotApproved"
                v-model="tempTreatmentSearchCondition.approver1HasNotApproved"
              />
            </div>

            <div class="d-flex align-items-center" v-show="columnStatus.isShowApprover2">
              <label for="approver2HasNotApproved" class="label-style">未指示承認2のみ表示</label>
              <v-ons-switch
                input-id="approver2HasNotApproved"
                v-model="tempTreatmentSearchCondition.approver2HasNotApproved"
              />
            </div>
          </div>
        </div>

        <div class="d-flex flex-column">
          <label>指示者</label>
          <kendo-dropdownlist
            :data-source="mstPersonalUser"
            v-model="tempTreatmentSearchCondition.instructorId"
            data-text-field="userFullName"
            data-value-field="userId"
          />
        </div>
      </div>
      <!-- Actions -->
      <div class="actions d-flex">
        <!-- mod 障害票一覧_NKK 修正 chen start -->
<!--        <v-ons-button-->
<!--          class="nik-btn reset"-->
<!--          @click="resetTreatmentSearchCondition"-->
<!--          >初期化</v-ons-button-->
<!--        >-->
        <v-ons-button
          class="btn2-cancel common-style-cancel-button"
          @click="resetTreatmentSearchCondition"
          >クリア</v-ons-button
        >
        <!-- mod 障害票一覧_NKK 修正 chen end -->
        <div class="spacer"></div>
        <!-- mod 画面部品デザイン定義 修正 chen start -->
        <v-ons-button
          class="btn3-normal common-style-ok-button"
          @click="searchTreatment"
          :disabled="hasValidationErrorsIn('treatment')"
          >OK</v-ons-button
        >
        <!-- <v-ons-button -->
        <!--   class="nik-btn search" -->
        <!--   @click="searchTreatment" -->
        <!--   :disabled="hasValidationErrorsIn('treatment')" -->
        <!--   >検索</v-ons-button -->
        <!-- > -->
        <!-- mod 画面部品デザイン定義 修正 chen end -->
      </div>
      <!-- / Actions -->
    </v-ons-popover>
    <!-- / Treatment unit search -->

    <!-- Indication unit search -->
    <v-ons-popover
      cancelable
      v-model:visible="indicationSearchVisible"
      :target="$refs.searchBar"
      direction="down"
      @prehide="prehideIndicationSearch"
      :class="[fontSizeSet, 'indication-list-header-popover']"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div id="indication-search" class="popover-search">
        <div class="d-flex flex-column">
          <div class="ntss-button-group">
            <input
              type="radio"
              class="identification"
              name="identification"
              value="1"
              id="instruction-issue-date"
              @click="setTreatmentDateOpt(ISSUE_DATE)"
              :checked="tempIndicationSearchCondition.treatmentDateOpt === ISSUE_DATE"
              :v-model="tempIndicationSearchCondition.treatmentDateOpt"
            />
            <label for="instruction-issue-date" class="label first-of-type"
              >指示発行日</label
            >
            <input
              type="radio"
              class="identification"
              name="identification"
              value="2"
              id="instruction-start-date"
              @click="setTreatmentDateOpt(START_DATE)"
              :checked="tempIndicationSearchCondition.treatmentDateOpt === START_DATE"
              :v-model="tempIndicationSearchCondition.treatmentDateOpt"
            />
            <label for="instruction-start-date" class="label last-of-type"
              >指示開始日</label
            >
          </div>
        </div>
        <div class="d-flex flex-column">
          <div class="flex-align-center">
            <!-- mod FNSI-改修内容日付のチェックの追加対応。 dou start -->
            <!-- <input
              class="ntss-input-date ntss-custom-input start-date"
              id="instruction-date"
              name="instruction-date"
              type="date"
              v-model="tempIndicationSearchCondition.treatmentStartDate"
              data-validation-scope="indication"
              v-rules="'required'"
            />
            <common-calendar v-model="tempIndicationSearchCondition.treatmentStartDate" />
          </div> -->
          <!-- <span class="error-message">{{
            getValidationError("indication.instruction-date")
          }}</span> -->
          <date-input
            v-model="tempIndicationSearchCondition.treatmentStartDate"
            :classes="'ntss-input-date ntss-custom-input start-date'"
            id="instruction-date"
            name="instruction-date"
            data-validation-scope="indication"
            v-rules="'required'"
            @keyup="getStartDate"
            @blur="getStartDate"
            isRequired
            />
            <common-calendar class="start-date-comment" v-model="tempIndicationSearchCondition.treatmentStartDate" />
          </div>
          <span class="error-message" v-if="showErrorStartDate">{{
            this.msgDiaLog
          }}</span>
          <!-- mod FNSI-改修内容日付のチェックの追加対応。 dou end -->
        </div>
        <div class="d-flex flex-column">
          <label for="scheduled-treatment-date">治療予定日</label>
          <div class="d-flex flex-column">
            <div class="flex-align-center">
              <date-input
                v-model="tempIndicationSearchCondition.treatmentScheduledDate"
                :classes="'ntss-input-date ntss-custom-input'"
                @handleClearInput="tempIndicationSearchCondition.treatmentScheduledDate = null"
              />
              <common-calendar v-model="tempIndicationSearchCondition.treatmentScheduledDate" />
            </div>
          </div>
        </div>
        <div class="d-flex flex-column">
          <label>クール</label>
          <div class="d-flex flex-column">
            <div class="flex-align-center">
              <kendo-multiselect
                :data-source="mstKur"
                v-model="tempIndicationSearchCondition.kurCds"
                data-text-field="kurName"
                data-value-field="kurCd"
                :disabled="!isTreatmentScheduledDateSet"
              />
            </div>
          </div>
        </div>
        <div class="d-flex flex-column">
          <label>ベッドグループ</label>
          <kendo-dropdownlist
            :data-source="mstRoomBedGroup"
            v-model="tempIndicationSearchCondition.bedGroupCd"
            data-text-field="roomBedGroupName"
            data-value-field="roomBedGroupCd"
            :disabled="!isTreatmentScheduledDateSet"
          />
        </div>
        <div class="d-flex flex-column" v-show="columnStatus.isShowChecker1">
          <span>指示受け1</span>
          <div class="d-flex checkbox-group">
            <div class="d-flex align-items-center">
              <v-ons-checkbox
                input-id="receive1-all"
                :checked="tempIndicationSearchCondition.check1 === ALL"
                @change="onChangeReceive1(ALL, $event.target)"
              />
              <label for="receive1-all">すべて</label>
            </div>

            <div class="d-flex align-items-center">
              <v-ons-checkbox
                input-id="receive1-UnChecked"
                :checked="tempIndicationSearchCondition.check1 === UNCHECKED"
                @change="onChangeReceive1(UNCHECKED, $event.target)"
              />
              <label for="receive1-UnChecked">未</label>
            </div>

            <div class="d-flex align-items-center">
              <v-ons-checkbox
                input-id="receive1-alReady"
                :checked="tempIndicationSearchCondition.check1 === ALREADY"
                @change="onChangeReceive1(ALREADY, $event.target)"
              />
              <label for="receive1-alReady">済</label>
            </div>
          </div>
        </div>
        <div class="d-flex flex-column" v-show="columnStatus.isShowChecker2">
          <span>指示受け2</span>
          <div class="d-flex checkbox-group">
            <div class="d-flex align-items-center">
              <v-ons-checkbox
                input-id="receive2-all"
                :checked="tempIndicationSearchCondition.check2 === ALL"
                @change="onChangeReceive2(ALL, $event.target)"
              />
              <label for="receive2-all">すべて</label>
            </div>

            <div class="d-flex align-items-center">
              <v-ons-checkbox
                input-id="receive2-UnChecked"
                :checked="tempIndicationSearchCondition.check2 === UNCHECKED"
                @change="onChangeReceive2(UNCHECKED, $event.target)"
              />
              <label for="receive2-UnChecked">未</label>
            </div>

            <div class="d-flex align-items-center">
              <v-ons-checkbox
                input-id="receive2-alReady"
                :checked="tempIndicationSearchCondition.check2 === ALREADY"
                @change="onChangeReceive2(ALREADY, $event.target)"
              />
              <label for="receive2-alReady">済</label>
            </div>
          </div>
        </div>
        <div class="d-flex flex-column" v-show="columnStatus.isShowApprover1">
          <span>指示承認1</span>
          <div class="d-flex checkbox-group">
            <div class="d-flex align-items-center">
              <v-ons-checkbox
                input-id="approval1-all"
                :checked="tempIndicationSearchCondition.approver1 === ALL"
                @change="onChangeApproval1(ALL, $event.target)"
              />
              <label for="approval1-all">すべて</label>
            </div>

            <div class="d-flex align-items-center">
              <v-ons-checkbox
                input-id="approval1-unchecked"
                :checked="tempIndicationSearchCondition.approver1 === UNCHECKED"
                @change="onChangeApproval1(UNCHECKED, $event.target)"
              />
              <label for="approval1-unchecked">未</label>
            </div>

            <div class="d-flex align-items-center">
              <v-ons-checkbox
                input-id="approval1-alReady"
                :checked="tempIndicationSearchCondition.approver1 === ALREADY"
                @change="onChangeApproval1(ALREADY, $event.target)"
              />
              <label for="approval1-alReady">済</label>
            </div>
          </div>
        </div>
        <div class="d-flex flex-column" v-show="columnStatus.isShowApprover2">
          <span>指示承認2</span>
          <div class="d-flex checkbox-group">
            <div class="d-flex align-items-center">
              <v-ons-checkbox
                input-id="approval2-all"
                :checked="tempIndicationSearchCondition.approver2 === ALL"
                @change="onChangeApproval2(ALL, $event.target)"
              />
              <label for="approval2-all">すべて</label>
            </div>

            <div class="d-flex align-items-center">
              <v-ons-checkbox
                input-id="approval2-unchecked"
                :checked="tempIndicationSearchCondition.approver2 === UNCHECKED"
                @change="onChangeApproval2(UNCHECKED, $event.target)"
              />
              <label for="approval2-unchecked">未</label>
            </div>

            <div class="d-flex align-items-center">
              <v-ons-checkbox
                input-id="approval2-alReady"
                :checked="tempIndicationSearchCondition.approver2 === ALREADY"
                @change="onChangeApproval2(ALREADY, $event.target)"
              />
              <label for="approval2-alReady">済</label>
            </div>
          </div>
        </div>
        <div class="d-flex flex-column">
          <label>指示者</label>
          <kendo-dropdownlist
            :data-source="mstPersonalUser"
            v-model="tempIndicationSearchCondition.userId"
            data-text-field="userFullName"
            data-value-field="userId"
          />
        </div>
        <div class="d-flex">
          <span>対象指示</span>
        </div>
        <div class="d-flex flex-column">
          <kendo-multiselect
            v-model="tempIndicationSearchCondition.indicationList"
            :data-source="indicationTargetDataSources"
            data-text-field="name"
            data-value-field="value"
            placeholder=""
            @open="getIndicationTargets"
          />
        </div>
      </div>
        <!-- Actions -->
      <div class="actions d-flex">
        <!-- mod 障害票一覧_NKK 修正 chen start -->
<!--        <v-ons-button-->
<!--          class="nik-btn reset"-->
<!--          @click="resetIndicationSearchCondition"-->
<!--          >初期化</v-ons-button-->
<!--        >-->
        <v-ons-button
          class="btn2-cancel common-style-cancel-button"
          @click="resetIndicationSearchCondition"
          >クリア</v-ons-button
        >
        <!-- mod 障害票一覧_NKK 修正 chen end -->
        <div class="spacer"></div>
        <!-- mod 画面部品デザイン定義 修正 chen start -->
        <v-ons-button
          class="btn3-normal common-style-ok-button"
          @click="searchIndication"
          :disabled="showErrorStartDate"
          >
          <!-- mod 障害票一覧_NKK 修正 chen start -->
          <!-- 検索 -->
          OK
          <!-- mod 障害票一覧_NKK 修正 chen end -->
        </v-ons-button>
        <!-- <v-ons-button -->
        <!--   class="nik-btn search" -->
        <!--   @click="searchIndication" -->
        <!--   :disabled="showErrorStartDate" -->
        <!--   >検索</v-ons-button -->
        <!-- > -->
        <!-- mod 画面部品デザイン定義 修正 chen end -->
      </div>
      <!-- / Actions -->
    </v-ons-popover>
    <!-- / Indication unit search -->

    <!-- Loading -->
    <v-ons-modal :visible="isLoading">
      <p class="loading-modal">
        指示を検索しています。
        <v-ons-icon icon="fa-spinner" spin />
      </p>
    </v-ons-modal>
    <!-- / Loading -->
  </v-card>
</template>

<script>
import dayjs from "@/compat/date/dayjs";
import _ from "@/compat/collections/lodash";
import {mapGetters, mapActions, mapMutations} from "@/compat/vue/vuex";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
import commonSearchArea from "@/components/common/CommonSearchArea";
import PopoverMixin from "@/components/PopoverMixin";
import { INDICATION } from "@/constants/defaultSettingConstants";
import { calcTargetDate } from "@/functions/modals/default-setting/defaultSettingUtils"
/* add FNSI-改修内容日付のチェックの追加対応。 dou start*/
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
/* add FNSI-改修内容日付のチェックの追加対応。 dou end*/
// add 画面印刷プレビューと印刷の実現 黄 start
import { getCurrentFunctionCd } from "@/router/routing-helper";
import { EventBus } from "@/compat/vue/event-bus.js";
// add 画面印刷プレビューと印刷の実現 黄 end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
import DateInput from "@/components/common/DateInput";
import { getScopedElementsByClassName, getScopedSessionStorage } from "@/functions/common/LayoutMeasureHelper";

const ALL = "1";
const UNCHECKED = "2";
const ALREADY = "3";
const ISSUE_DATE = "1";
const START_DATE = "2";

export default {
  mixins: [PopoverMixin],
  name: "IndicationListHeaderComponent",
  components: {
    "common-calendar": commonCalender,
    "common-searcharea": commonSearchArea,
    "date-input": DateInput,
  },
  data() {
    return {
      /* add FNSI-改修内容日付のチェックの追加対応。 dou start*/
      msgDiaLog: DIALOG_MESSAGES["99999995"].message,
      showErrorStartDate: false,
      showErrorEndDate: false,
      /* add FNSI-改修内容日付のチェックの追加対応。 dou end*/
      treatmentSearchVisible: false,
      indicationSearchVisible: false,
      tempTreatmentSearchCondition: {},
      tempIndicationSearchCondition: {},
      afterSearched: false,
      isLoading: false,
      multiSelectedItems: [],
      indicationTargetDataSources: [],
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: []
    };
  },
  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("indication", [
      "mstTreatment",
      "mstKur",
      "mstPersonalUser",
      "mstRoomBedGroup",
      "isTreatmentUnit",
      "treatmentSearchCondition",
      "indicationSearchCondition",
      "columnStatus"
    ]),
    // add 障害票一覧_NKK 修正 chen end
    ...mapGetters("account-edit", {
      defaultSetting: "getDefaultSetting"
    }),
    // add 画面印刷プレビューと印刷の実現 黄 start
    ...mapGetters("pat-info", ["searchedPatList", "selectedPatId"]),
    // add 画面印刷プレビューと印刷の実現 黄 end
    ALL() {
      return ALL;
    },
    UNCHECKED() {
      return UNCHECKED;
    },
    ALREADY() {
      return ALREADY;
    },
    ISSUE_DATE() {
      return ISSUE_DATE;
    },
    START_DATE() {
      return START_DATE;
    },
    /**
     * 施設設定マスタのNo23で「2:指示単位」が選択されている場合、治療日が指定されているか否か
     */
    isTreatmentScheduledDateSet() {
      return this.tempIndicationSearchCondition.treatmentScheduledDate ? true : false;
    }
  },
  methods: {
    ...mapActions("indication", [
      "getIndications",
      "setTreatmentSearchCondition",
      "setIndicationSearchCondition",
    ]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    // add 画面印刷プレビューと印刷の実現 黄 start
    //虫眼鏡条件の指示期間~1年後時間
     addStringNumber(str1, str2){
        const arr1 = str1.split(""), arr2 = str2.split("");
        let result = "";
        let len1 = arr1.length - 1, len2 = arr2.length - 1;
        let flag = 0;
        while(len1 >= 0 || len2 >= 0) {
            let temp = Number(arr1[len1]) + Number(arr2[len2]) + flag;
            if(len1 < 0) {
                temp = Number(arr2[len2]) + flag;
                len1 = 0;
            }
            if(len2 < 0) {
                temp = Number(arr1[len1]) + flag;
                len2 = 0;
            }
            flag = temp >= 10 ? 1 : 0;
            result = (temp % 10) + result;
            len1--;
            len2--;
        }
        return flag > 0 ? `${flag}${result}` : `${result}`;
     },
       // add 6299 指示受け・指示承認画面を開くたびに、患者の表示順が勝手に入れ替わる 張 start
    async refresh(){
      console.log("refresh");
       if (this.isTreatmentUnit) {
            await this.searchTreatment();
          }
          if (!this.isTreatmentUnit) {
            this.searchIndication();
          }
     },
       // add 6299 指示受け・指示承認画面を開くたびに、患者の表示順が勝手に入れ替わる 張 start
    requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        // 機能一致

        // 印刷パラメータを応答
        // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
        // mod #9558機能帳票でパラメータが正しく渡されていない 杜天成 start
        //let data = this.tempIndicationSearchCondition.treatmentDate;
        let data = this.tempIndicationSearchCondition.treatmentStartDate == null ? this.tempIndicationSearchCondition.treatmentScheduledDate : this.tempIndicationSearchCondition.treatmentStartDate;
        // mod #9558機能帳票でパラメータが正しく渡されていない 杜天成 end
        // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
        // del #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
        // let data = this.tempIndicationSearchCondition.treatmentStartDate;
        // let endData = null;
        // let startData = null;
        // if (data != null && data != "") {
        //   endData = this.addStringNumber(this.tempIndicationSearchCondition.treatmentStartDate.replaceAll("-", ""), "10000");
        //   startData = data;
        // } else {
        //   data = dayjs(Date.now()).format("YYYY/MM/DD");
        //   endData = this.addStringNumber(data.replaceAll("/", ""), "10000");
        //   startData = data;
        // }
        // del #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
        const dateParam = {
          patId: this.selectedPatId,
          facilityCd: this.getFacilityCd,
          // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
          date: dayjs(data).format("YYYY/MM/DD"),
          // mod #9558機能帳票でパラメータが正しく渡されていない 杜天成 start
          // fromDate: dayjs(Date.now()).format("YYYY/MM/DD"),
          // toDate: dayjs(Date.now()).format("YYYY/MM/DD")
          fromDate: dayjs(data).format("YYYY/MM/DD"),
          toDate: dayjs(data).format("YYYY/MM/DD")
          // mod #9558機能帳票でパラメータが正しく渡されていない 杜天成 end
        // date: dayjs(Date.now()).format("YYYY/MM/DD"),
        // fromDate: dayjs(startData).format("YYYY/MM/DD"),
        // toDate: dayjs(endData).format("YYYY/MM/DD")
          // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
        };
        EventBus.$emit("setDateParams", dateParam);
      }
    },
    // add 画面印刷プレビューと印刷の実現 黄 end
    // add 障害票一覧_NKK 修正 chen start
    ...mapMutations("indication", [
      "resetTreatmentIndications",
      "resetTreatmentIndicationSortStatus"
    ]),
    /* add FNSI-改修内容日付のチェックの追加対応。 dou start*/
    getStartDate(){
      const startDateInput = getScopedElementsByClassName("start-date", this.$el || this)[0];
      this.showErrorStartDate = startDateInput?.value ? startDateInput.validationMessage !== "" : false;
    },
    /* add FNSI-改修内容日付のチェックの追加対応。 dou end*/
    showSearch() {
      this.isTreatmentUnit
        ? (this.treatmentSearchVisible = true)
        : (this.indicationSearchVisible = true);
    },
    resetTreatmentSearchCondition() {
      this.resetValidation();
      // サインインユーザのデフォルト設定を取得
      const defaultIndication = this.defaultSetting[INDICATION.KEY_NAME];
      this.tempTreatmentSearchCondition = initTreatmentSearchCondition(defaultIndication);
    },
    prehideTreatmentSearch() {
      if (this.afterSearched) {
        this.afterSearched = false;
        return;
      }

      this.setTempTreatmentSearchCondition();
    },
    async searchTreatment() {
      this.isLoading = true;
      this.afterSearched = true;
      this.setTreatmentSearchCondition(this.tempTreatmentSearchCondition);
      this.treatmentSearchVisible = false;
      await this.getIndications();
      this.setConditionList();
      // add 障害票一覧_NKK 修正 chen start
      const sortedDesc = getScopedElementsByClassName("sorted-desc", this.$el || this)[0];
      if (sortedDesc) {
        sortedDesc.classList.remove("sorted-desc");
      }
      const sortedAsc = getScopedElementsByClassName("sorted-asc", this.$el || this)[0];
      if (sortedAsc) {
        sortedAsc.classList.remove("sorted-asc");
      }
      // mod FNSI6299-患者の表示順が勝手に入れ替わる start
      //this.resetTreatmentIndications();
      //this.resetTreatmentIndicationSortStatus();
      await this.resetTreatmentIndications();
      await this.resetTreatmentIndicationSortStatus();
      // mod FNSI6299-患者の表示順が勝手に入れ替わる end
      // add 障害票一覧_NKK 修正 chen end
      this.isLoading = false;
    },
    resetIndicationSearchCondition() {
      this.resetValidation();
      // サインインユーザのデフォルト設定を取得
      const defaultIndication = this.defaultSetting[INDICATION.KEY_NAME];
      this.tempIndicationSearchCondition = initIndicationSearchCondition(defaultIndication);
    },
    async searchIndication() {
      this.isLoading = true;
      this.afterSearched = true;
      this.setIndicationSearchCondition(this.tempIndicationSearchCondition);
      this.indicationSearchVisible = false;
      await this.getIndications();
      this.setConditionList();
      this.isLoading = false;
      // add 障害票一覧_NKK 修正 chen start
      this.resetTreatmentIndications();
      this.resetTreatmentIndicationSortStatus();
      // add 障害票一覧_NKK 修正 chen end
    },
    prehideIndicationSearch() {
      if (this.afterSearched) {
        this.afterSearched = false;
        return;
      }

      this.setTempIndicationSearchCondition();
    },
    somethingWentWrong() {
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
      // this.$ons.notification.alert("システムエラーが発生しました。", {
      //   title: "エラー"
      // });
      this.$ons.notification.alert(messageFormat(DIALOG_MESSAGES['00200002'].message), {
        title: DIALOG_MESSAGES['00200002'].title
      });
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
    },
    setTempTreatmentSearchCondition() {
      this.tempTreatmentSearchCondition = {
        ...this.treatmentSearchCondition,
        kurCds: [...this.treatmentSearchCondition.kurCds]
      };
    },
    setTempIndicationSearchCondition() {
      this.tempIndicationSearchCondition = {
        ...this.indicationSearchCondition,
        kurCds: [...this.indicationSearchCondition.kurCds]
      };
    },
    getIndicationTargets() {
      this.indicationTargetDataSources = [
        { name: "クール", value: "クール" },
        { name: "治療開始時刻", value: "治療開始時刻" },
        { name: "ベッド", value: "ベッド" },
        { name: "治療時間", value: "治療時間" },
        { name: "VA", value: "VA" },
        { name: "目標体重", value: "目標体重" },
        { name: "除水量制限", value: "除水量制限" },
        { name: "ダイアライザ", value: "ダイアライザ" },
        { name: "吸着カラム", value: "吸着カラム" },
        { name: "1次膜", value: "1次膜" },
        { name: "2次膜", value: "2次膜" },
        { name: "穿刺針(A針)", value: "穿刺針(A針)" },
        { name: "穿刺針(V針)", value: "穿刺針(V針)" },
        { name: "穿刺針(SN)", value: "穿刺針(SN)" },
        { name: "シングルニードル使用", value: "シングルニードル使用" },
        { name: "血液回路", value: "血液回路" },
        { name: "血液量", value: "血液量" },
        { name: "透析液", value: "透析液" },
        { name: "透析液流量", value: "透析液流量" },
        { name: "透析液使用数", value: "透析液使用数" },
        { name: "透析液温度", value: "透析液温度" },
        { name: "補液", value: "補液" },
        { name: "補液量", value: "補液量" },
        { name: "補液選択", value: "補液選択" },
        { name: "補液使用数", value: "補液使用数" },
        { name: "補液温度", value: "補液温度" },
        { name: "補液速度", value: "補液速度" },
        { name: "抗凝固剤", value: "抗凝固剤" },
        { name: "抗凝固剤ワンショット量", value: "抗凝固剤ワンショット量" },
        { name: "抗凝固剤持続速度", value: "抗凝固剤持続速度" },
        { name: "抗凝固剤持続総量", value: "抗凝固剤持続総量" },
        { name: "IP使用選択", value: "IP使用選択" },
        { name: "IPスタート", value: "IPスタート" },
        { name: "IP速度", value: "IP速度" },
        { name: "IP速度最大値", value: "IP速度最大値" },
        { name: "IPワンショットスタート", value: "IPワンショットスタート" },
        { name: "IPワンショット量", value: "IPワンショット量" },
        { name: "IP電源自動切り", value: "IP電源自動切り" },
        { name: "IP電源自動切り時間", value: "IP電源自動切り時間" },
        { name: "IP電源OKモニタ切り", value: "IP電源OKモニタ切り" },
        { name: "IP電源OKモニタ切り時間", value: "IP電源OKモニタ切り時間" },
        { name: "投与薬剤", value: "投与薬剤" },
        { name: "医療材料", value: "医療材料" },
        { name: "指示コメント", value: "指示コメント" },
        { name: "治療予定", value: "治療予定" },
        { name: "治療方法", value: "治療方法" }
      ];
    },
    onChangeReceive1(value, e) {
      e.checked = true;
      this.tempIndicationSearchCondition.check1 = value;
    },

    onChangeReceive2(value, e) {
      e.checked = true;
      this.tempIndicationSearchCondition.check2 = value;
    },
    onChangeApproval1(value, e) {
      e.checked = true;
      this.tempIndicationSearchCondition.approver1 = value;
    },
    onChangeApproval2(value, e) {
      e.checked = true;
      this.tempIndicationSearchCondition.approver2 = value;
    },
    setTreatmentDateOpt(value) {
      this.tempIndicationSearchCondition.treatmentDateOpt = value;
    },
    // -----------------------------------------
    // 共通検索エリア部品に表示するデータのリストを作成
    // -----------------------------------------
    setConditionList() {
      if (this.isTreatmentUnit === null) {
        this.conditionList = [];
        return;
      }

      let condList = [];
      const searchCondition = this.isTreatmentUnit
        ? this.treatmentSearchCondition
        : this.indicationSearchCondition;

      if (searchCondition) {
        Object.keys(searchCondition).forEach(condition => {
          let value = searchCondition[condition];
          if (!_.isBoolean(value) && _.isEmpty(value)) {
            return;
          }
          switch (condition) {
            case "treatmentDate":
              // 治療日(治療単位)
              value = dayjs(value, "YYYY-MM-DD").format("YYYY/MM/DD");
              condList.push({ name:"治療日", text:value });
              break;
            case "treatmentStartDate": {
              // 指示発行日/指示開始日(指示単位)
              const itemName = searchCondition.treatmentDateOpt === "1" ? "指示発行日" : "指示開始日";
              value = dayjs(value, "YYYY-MM-DD").format("YYYY/MM/DD");
              condList.push({ name:itemName, text:value });
              break;
            }
            case "treatmentScheduledDate":
              // 治療予定日(指示単位)
              value = dayjs(value, "YYYY-MM-DD").format("YYYY/MM/DD");
              condList.push({ name:"治療予定日", text:value });
              break;
            case "treatmentCd":
              // 治療方法(治療単位)
              value = this.mstTreatment.find(
                treatment => +treatment.treatmentCd === +value).treatmentName;
              condList.push({ name:"治療方法", text:value });
              break;
            case "kurCds":
              // クール(治療単位)
              value = this.mstKur
                .filter(kur => value.includes(kur.kurCd))
                .map(kur => kur.kurName)
                .join(", ");
              condList.push({ name:"クール", text:value });
              break;
            case "bedGroupCd":
              // ベッドグループ(治療単位)
              value = this.mstRoomBedGroup.find(
                bed => +bed.roomBedGroupCd === +value).roomBedGroupName;
              if (value) {
                condList.push({ name:"ベッドグループ", text:value });
              }
              break;
            case "checker1HasNotReceived":
              // 未指示受け1のみ表示(治療単位)
              if (this.columnStatus.isShowChecker1 && value) {
                condList.push({ text:"未指示受け1のみ表示" });
              }
              break;
            case "checker2HasNotReceived":
              // 未指示受け2のみ表示(治療単位)
              if (this.columnStatus.isShowChecker2 && value) {
                condList.push({ text:"未指示受け2のみ表示" });
              }
              break;
            case "approver1HasNotApproved":
              // 未指示承認1のみ表示(治療単位)
              if (this.columnStatus.isShowApprover1 && value) {
                condList.push({ text:"未指示承認1のみ表示" });
              }
              break;
            case "approver2HasNotApproved":
              // 未指示承認2のみ表示(治療単位)
              if (this.columnStatus.isShowApprover2 && value) {
                condList.push({ text:"未指示承認2のみ表示" });
              }
              break;
            case "check1": {
              // 指示受け1(指示単位)
              if (this.columnStatus.isShowChecker1) {
                let check1ValueName = "";
                switch (value) {
                  case "1":
                    check1ValueName = "すべて";
                    break;
                  case "2":
                    check1ValueName = "未";
                    break;
                  case "3":
                    check1ValueName = "済";
                    break;
                  default:
                    break;
                }
                if (check1ValueName) {
                  condList.push({ name:"指示受け1", text:check1ValueName });
                }
              }
              break;
            }
            case "check2": {
              // 指示受け2(指示単位)
              if (this.columnStatus.isShowChecker2) {
                let check2ValueName = "";
                switch (value) {
                  case "1":
                    check2ValueName = "すべて";
                    break;
                  case "2":
                    check2ValueName = "未";
                    break;
                  case "3":
                    check2ValueName = "済";
                    break;
                  default:
                    break;
                }
                if (check2ValueName) {
                  condList.push({ name:"指示受け2", text:check2ValueName });
                }
              }
              break;
            }
            case "approver1": {
              // 指示承認1(指示単位)
              if (this.columnStatus.isShowApprover1) {
                let approver1ValueName = "";
                switch (value) {
                  case "1":
                    approver1ValueName = "すべて";
                    break;
                  case "2":
                    approver1ValueName = "未";
                    break;
                  case "3":
                    approver1ValueName = "済";
                    break;
                  default:
                    break;
                }
                if (approver1ValueName) {
                  condList.push({ name:"指示承認1", text:approver1ValueName });
                }
              }
              break;
            }
            case "approver2": {
              // 指示承認2(指示単位)
              if (this.columnStatus.isShowApprover2) {
                let approver2ValueName = "";
                switch (value) {
                  case "1":
                    approver2ValueName = "すべて";
                    break;
                  case "2":
                    approver2ValueName = "未";
                    break;
                  case "3":
                    approver2ValueName = "済";
                    break;
                  default:
                    break;
                }
                if (approver2ValueName) {
                  condList.push({ name:"指示承認2", text:approver2ValueName });
                }
              }
              break;
            }
            case "instructorId":
            case "userId":
              // 指示者(治療単位/指示単位共通)
              if (+value !== 0) {
                condList.push({ name:"指示者", text:this.mstPersonalUser.find(user => +user.userId === +value).userFullName });
              }
              break;
            case "indicationList":
              // 対象指示(指示単位)
              if (
                searchCondition.indicationList &&
                searchCondition.indicationList.length > 0) {
                let valueStr = "";
                searchCondition.indicationList.forEach(item => {
                  valueStr += (item + "、");
                });
                condList.push({ name:"対象指示", text:valueStr.slice(0, -1) });
              }
              break;
            default:
              break;
          }
        });
      }
      // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
      const scopedSessionStorage = getScopedSessionStorage(this.$el);
      scopedSessionStorage.setItem('roomBedGroupNameStatusList', JSON.stringify(condList.find(item => item.name === "ベッドグループ")?.text || ''));
      scopedSessionStorage.setItem('kurGroupNameStatusList', JSON.stringify(condList.find(item => item.name === "クール")?.text || ''));
      // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
      this.conditionList = condList;
    }
  },
// add FNSI-改修内容 治療日をクリアした後、再度日付を選択してください。検索ボタンはクリックできません dou start
  watch:{
    isTreatmentUnit(newv,oldv){
      console.log(newv+"***"+oldv);
    },
    "tempTreatmentSearchCondition.treatmentDate":{
      handler(){
        this.resetValidation("treatment");
        // mod 画面パフォーマンス対応 chen start
        this.$nextTick(() => {
          // setTimeout(() => {
            this.validateField("treatment.treatment-date");
          // }, 0);
        });
        // mod 画面パフォーマンス対応 chen end
      }
    },
    /**
     * 治療予定日変更時の処理
     */
    "tempIndicationSearchCondition.treatmentScheduledDate":{
      handler(newVal){
        // 未指定の場合はクール、ベッドグループをクリア
        if (!newVal) {
          this.tempIndicationSearchCondition.kurCds = [];
          // #10997 Mod 個人設定＞デフォルト設定の各設定にてベッドグループが空値が初期表示になっている Start
          // this.tempIndicationSearchCondition.bedGroupCd = "";
          this.tempIndicationSearchCondition.bedGroupCd = "0";
          // #10997 Mod 個人設定＞デフォルト設定の各設定にてベッドグループが空値が初期表示になっている End
        }
      }
    }
  },
// add FNSI-改修内容 治療日をクリアした後、再度日付を選択してください。検索ボタンはクリックできません dou end
  async created() {
    if (this.isTreatmentUnit === null) {
      return;
    }
    this.getIndicationTargets();
    // add 画面印刷プレビューと印刷の実現 黄 start
    // 印刷パラメータ要求
    // add 性能改善メモリ不足 shan start
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // add 性能改善メモリ不足 shan end
    EventBus.$on("requestReportParams", this.requestrReportParams);
    // add 画面印刷プレビューと印刷の実現 黄 end
    // #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start
    EventBus.$off("refresh", this.refresh);
    EventBus.$on("refresh", this.refresh);
    // #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end
    this.$nextTick(async () => {
      if (this.treatmentSearchCondition === null) {
        // サインインユーザのデフォルト設定を取得
        const defaultIndication = this.defaultSetting[INDICATION.KEY_NAME];
        this.setTreatmentSearchCondition(initTreatmentSearchCondition(defaultIndication));
      }

      if (this.indicationSearchCondition === null) {
        // サインインユーザのデフォルト設定を取得
        const defaultIndication = this.defaultSetting[INDICATION.KEY_NAME];
        this.setIndicationSearchCondition(initIndicationSearchCondition(defaultIndication));
      }

      this.setTempTreatmentSearchCondition();
      this.setTempIndicationSearchCondition();
      this.tempTreatmentSearchCondition.treatmentCd =
        this.tempTreatmentSearchCondition.treatmentCd ||
        this.mstTreatment[0].treatmentCd;

      this.tempTreatmentSearchCondition.kurCds =
        this.tempTreatmentSearchCondition.kurCds ||
        this.mstKur.map(({ kurCd }) => kurCd);

      this.isLoading = true;
      await this.getIndications();
      this.isLoading = false;

      this.$nextTick(async () => {
        this.setConditionList();
      });
    });
  },
  // add 画面印刷プレビューと印刷の実現 黄 start
  beforeUnmount () {
    // 印刷パラメータ要求
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start
    EventBus.$off("refresh", this.refresh);
    // #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end
    // add 画面パフォーマンス対応 chen start
    this.msgDiaLog = null;
    this.showErrorStartDate = null;
    this.showErrorEndDate = null;
    this.treatmentSearchVisible = null;
    this.indicationSearchVisible = null;
    this.tempTreatmentSearchCondition = null;
    this.tempIndicationSearchCondition = null;
    this.afterSearched = null;
    this.isLoading = null;
    this.multiSelectedItems = null;
    this.indicationTargetDataSources = null;
    this.conditionList = null;
    // add 画面パフォーマンス対応 chen end
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
  // add 画面印刷プレビューと印刷の実現 黄 end
};

function initTreatmentSearchCondition(defaultIndication) {
  const mstKur = []
  let defTreatSearchCond = {
    treatmentDate: dayjs().format("YYYY-MM-DD"),
    treatmentCd: "0",
    kurCds: mstKur.map(({ kurCd }) => kurCd),
    bedGroupCd: "0",
    checker1HasNotReceived: false,
    checker2HasNotReceived: false,
    approver1HasNotApproved: false,
    approver2HasNotApproved: false,
    instructorId: "0"
  };

  // サインインユーザのデフォルト設定を設定
  if (defaultIndication) {
    // 治療方法
    if (defaultIndication[INDICATION.KEY_NAME_TREATMENT_CD] !== undefined) {
      defTreatSearchCond.treatmentCd = String(defaultIndication[INDICATION.KEY_NAME_TREATMENT_CD]);
    }
    // クール
    if (defaultIndication[INDICATION.KEY_NAME_KUR_CDS] !== undefined) {
      defTreatSearchCond.kurCds = defaultIndication[INDICATION.KEY_NAME_KUR_CDS];
    }
    // ベッドグループ
    if (defaultIndication[INDICATION.KEY_NAME_BED_GROUP_CD] !== undefined) {
      defTreatSearchCond.bedGroupCd = String(defaultIndication[INDICATION.KEY_NAME_BED_GROUP_CD]);
    }
    // 未指示受け1のみ表示
    if (defaultIndication[INDICATION.KEY_NAME_CHECKER1_HAS_NOT_RECEIVED] !== undefined) {
      defTreatSearchCond.checker1HasNotReceived = defaultIndication[INDICATION.KEY_NAME_CHECKER1_HAS_NOT_RECEIVED];
    }
    // 未指示受け2のみ表示
    if (defaultIndication[INDICATION.KEY_NAME_CHECKER2_HAS_NOT_RECEIVED] !== undefined) {
      defTreatSearchCond.checker2HasNotReceived = defaultIndication[INDICATION.KEY_NAME_CHECKER2_HAS_NOT_RECEIVED];
    }
    // 未指示承認1のみ表示
    if (defaultIndication[INDICATION.KEY_NAME_APPROVER1_HAS_NOT_RECEIVED] !== undefined) {
      defTreatSearchCond.approver1HasNotApproved = defaultIndication[INDICATION.KEY_NAME_APPROVER1_HAS_NOT_RECEIVED];
    }
    // 未指示承認2のみ表示
    if (defaultIndication[INDICATION.KEY_NAME_APPROVER2_HAS_NOT_RECEIVED] !== undefined) {
      defTreatSearchCond.approver2HasNotApproved = defaultIndication[INDICATION.KEY_NAME_APPROVER2_HAS_NOT_RECEIVED];
    }
    // 指示者
    if (defaultIndication[INDICATION.KEY_NAME_INSTRUCTOR_ID] !== undefined) {
      defTreatSearchCond.instructorId = String(defaultIndication[INDICATION.KEY_NAME_INSTRUCTOR_ID]);
    }
  }

  return defTreatSearchCond;
}

function initIndicationSearchCondition(defaultIndication) {
  const mstKur = [];
  let defIndSearchCond = {
    treatmentDateOpt: ISSUE_DATE,
    treatmentStartDate: dayjs().format("YYYY-MM-DD"),
    treatmentScheduledDate: null,
    kurCds: mstKur.map(({ kurCd }) => kurCd),
    // #10997 Mod 個人設定＞デフォルト設定の各設定にてベッドグループが空値が初期表示になっている Start
    // bedGroupCd: "",
    bedGroupCd: "0",
    // #10997 Mod 個人設定＞デフォルト設定の各設定にてベッドグループが空値が初期表示になっている End
    check1: ALL,
    check2: ALL,
    approver1: ALL,
    approver2: ALL,
    createdBy: "0",
    userId: "0",
    indication: false,
    indicationList: []
  };

  // サインインユーザのデフォルト設定を設定
  if (defaultIndication) {
    // 治療日
    if (defaultIndication[INDICATION.KEY_NAME_TREATMENT_SCHEDULE_DATE] !== undefined && defaultIndication[INDICATION.KEY_NAME_TREATMENT_SCHEDULE_DATE] !== "") {
      defIndSearchCond.treatmentScheduledDate = calcTargetDate(defaultIndication[INDICATION.KEY_NAME_TREATMENT_SCHEDULE_DATE])
    }
    // クール
    if (defaultIndication[INDICATION.KEY_NAME_IND_KUR_CDS] !== undefined) {
      defIndSearchCond.kurCds = defaultIndication[INDICATION.KEY_NAME_IND_KUR_CDS];
    }
    // ベッドグループ
    if (defaultIndication[INDICATION.KEY_NAME_IND_BED_GROUP_CD] !== undefined) {
      defIndSearchCond.bedGroupCd = defaultIndication[INDICATION.KEY_NAME_IND_BED_GROUP_CD];
    }
    // 指示受け1
    if (defaultIndication[INDICATION.KEY_NAME_CHECK1] !== undefined) {
      defIndSearchCond.check1 = defaultIndication[INDICATION.KEY_NAME_CHECK1];
    }
    // 指示受け2
    if (defaultIndication[INDICATION.KEY_NAME_CHECK2] !== undefined) {
      defIndSearchCond.check2 = defaultIndication[INDICATION.KEY_NAME_CHECK2];
    }
    // 指示承認1
    if (defaultIndication[INDICATION.KEY_NAME_APPROVER1] !== undefined) {
      defIndSearchCond.approver1 = defaultIndication[INDICATION.KEY_NAME_APPROVER1];
    }
    // 指示承認2
    if (defaultIndication[INDICATION.KEY_NAME_APPROVER2] !== undefined) {
      defIndSearchCond.approver2 = defaultIndication[INDICATION.KEY_NAME_APPROVER2];
    }
    // 指示者
    if (defaultIndication[INDICATION.KEY_NAME_INSTRUCTOR_ID] !== undefined) {
      defIndSearchCond.userId = String(defaultIndication[INDICATION.KEY_NAME_USER_ID]);
    }
    // 対象指示
    if (defaultIndication[INDICATION.KEY_NAME_INDICATION_LIST] !== undefined) {
      defIndSearchCond.indicationList = defaultIndication[INDICATION.KEY_NAME_INDICATION_LIST];
    }
  }

  return defIndSearchCond;
}
</script>

<style scoped>
.loading-modal {
  font-size: 2.4em;
}
ons-popover :deep(.popover--top) {
  width: unset;
}

.indication-list-header-popover :deep(.popover--top) {
  width: unset;
}
.popover-search {
  padding: 1em;
  overflow-y: auto;
  max-height: 50vh;
}
.popover-search > div.d-flex {
  margin-bottom: 0.5em;
}
.popover-search > div.d-flex:last-child {
  margin-bottom: 0;
}
.popover-search :deep(.k-dropdown) {
  width: 100%;
}
.popover-search .actions {
  margin-top: 1em;
}
ons-input :deep(.text-input) {
  font-size: inherit;
}
input[type="date"] {
  font-size: inherit;
}
.checkbox-group > label {
  margin-right: 1.5em;
}
.checkbox-group > label:last-child {
  margin-right: 0;
}
.actions > ons-button.search {
  background-color: #0076ff;
}
.actions > ons-button.reset {
  color: #fff;
  background-image: linear-gradient(#afb1b5 0%,#73839e 30%,#6e83a7 50%,#5b5f67 100%);
}
.error-message {
  font-size: 0.8em;
}
input[type="date"] ~ .error-message {
  min-width: 180px;
}
.toggle-group > div {
  margin-bottom: 5px;
}
.toggle-group > div:last-child {
  margin-bottom: 0;
}
.toggle-group > div > label {
  margin-right: 5px;
}
/* 詳細/簡易ボタン */
.ntss-button-group input[type="radio"] {
  /* ラジオボタンを非表示にする */
  display: none;
}
/* ボタングループのスタイル定義 */
.ntss-button-group {
  display: flex;
}
label.label {
  display: block; /* ブロックレベル要素化する */
  float: left; /* 要素の左寄せ・回り込を指定する */
  color: #ffffff; /* フォントの色を指定する */
  text-align: center; /* テキストのセンタリングを指定する */
  line-height: 30px; /* 行の高さを指定する */
  cursor: pointer; /* マウスカーソルの形（リンクカーソル）を指定する */
  white-space: nowrap;
  padding: 3px 0px;
  width: 100%;
}
.ntss-button-group .first-of-type {
  border-radius: 10px 0 0 10px;
  margin: 2px 0px 2px 5px;
}
.ntss-button-group .last-of-type {
  border-radius: 0 10px 10px 0;
  margin: 2px 5px 2px 0px;
}
.checkbox-group > * {
  margin-right: 10px;
}
.checkbox-group > *:last-child {
  margin-right: 0;
}
.checkbox-group ons-checkbox {
  margin-right: 5px;
}
.ons-switch-label {
  width: 85px;
}
.label-style {
  margin-right: 35px;
}
.switch-group > div {
  margin-bottom: 5px;
}
.actions {
  margin: 8px;
}
</style>
