-<template>
  <div>
    <div
      v-for="(json, index) in jsonArray"
      :key="index"
      :class="classObjectItem(json)"
    >
      <table class="card-table">
        {{ index + 1 }}
        <button
          v-show="actionMode"
          class="button-delete ntss-btn-outset"
          @click="setJsonIndex(json, index)"
          :disabled="isOtherFacilityRow(json)"
        >
          <v-ons-icon icon="fa-trash"/>
        </button>
        <br />
        <tr>
          <td class="item-title">区分</td>
          <td colspan="2" class="item-data">
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <custom-select -->
            <!--   ref="move_in_out" -->
            <!--   :value="getPatDataJsonArray(json, 'move_in_out')" -->
            <!--   :options="getMoveInOutClass(json)" -->
            <!--   :is-required="json.in_out_check" -->
            <!--   :disabled="isMoveInOutDeath(json) || editFlag" -->
            <!--   form-name="区分" -->
            <!--   @change="setVisitHstData(json)" -->
            <!-- /> -->
            <custom-select
              ref="move_in_out"
              :value="getPatDataJsonArray(json, 'move_in_out')"
              :options="getMoveInOutClass(json)"
              :is-required="json.in_out_check"
              :disabled="isMoveInOutDeath(json) || isOtherFacilityRow(json) || !getItemAuthorized('PatInfo', 'default_authority')"
              form-name="区分"
              @change="setVisitHstData(json)"
            />
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
          </td>
        </tr>
        <tr>
          <td class="item-title">日付</td>
          <td v-if="isMoveInOutDeath(json)" colspan="2" class="item-data">
            <custom-input
              class="death-date"
              :value="getPatDataJsonArray(json, 'period_start')"
              :display-string="changeDate(getPatDataJsonArray(json, 'period_start').editValue)"
              :disabled="isMoveInOutDeath(json) || isOtherFacilityRow(json) || !getItemAuthorized('PatInfo', 'default_authority')"
            />
          </td>
          <td v-else colspan="2" class="item-data-period">
            <span v-if="!isStartDateInputFree(json)" class="span-flex">
              <custom-input-date
                ref="period_start_date"
                class="death-date"
                :value="getPatDataJsonArray(json, 'period_start_date')"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
                :callBackFunc="setDateEach"
                :arguments="{json: json, fromData: 'period_start_date'}"
              />
              <button
                ref="button"
                class="icon-margin ntss-btn-outset"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
                @click="changeinputfree(json, '1')"
              >
                <v-ons-icon icon="fa-dot-circle" />
              </button>
            </span>
            <span v-else class="flex-align-center visit-history">
              <custom-input
                ref="period_start_year"
                class="period-date"
                :maxlength="4"
                :validators="[validateInteger]"
                form-name="開始日"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
                :value="getPatDataJsonArray(json, 'period_start_year')"
                :datetype="'period-year'"
                :datetypeym="datetypechk(json)"
                :datetypeindex="datetypeindex('S_year', index)"
                :wheelChangeUse="true"
                @blur="addNumber(json, 'period_start_year')"
              />年
              <custom-input
                class="period-date"
                :maxlength="2"
                :validators="[validateInteger]"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
                :value="getPatDataJsonArray(json, 'period_start_month')"
                :datetype="'period-month'"
                :datetypeym="datetypechk(json)"
                :datetypeindex="datetypeindex('S_month', index)"
                :wheelChangeUse="true"
                @blur="addNumber(json, 'period_start_month')"
              />月
              <custom-input
                class="period-date"
                :maxlength="2"
                :validators="[validateInteger]"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
                :value="getPatDataJsonArray(json, 'period_start_day')"
                :datetype="'period-day'"
                :datetypeym="datetypechk(json)"
                :datetypeindex="datetypeindex('S_day', index)"
                :wheelChangeUse="true"
                @blur="addNumber(json, 'period_start_day')"
              />日
              <custom-input-calender
                class="calender"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
                :value="getPatDataJsonArray(json, 'period_start_date')"
                :callBackFunc="setDateEach"
                :arguments="{json: json, fromData: 'period_start_date'}"
              />
              <button
                ref="button"
                class="icon-margin ntss-btn-outset"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
                @click="changeinputfree(json, '0')"
              >
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <v-ons-icon icon="fa-dot-circle" />
              </button>
            </span>
            <span v-if="isMoveInOutTemporarilyMovingOut(json)"> ～ </span>
            <span
              v-if="isMoveInOutTemporarilyMovingOut(json) && !isEndDateInputFree(json)"
              class="span-flex"
            >
              <custom-input-date
                class="death-date"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
                :value="getPatDataJsonArray(json, 'period_end_date')"
                :callBackFunc="setDateEach"
                :arguments="{
                  json: json,
                  fromData: 'period_end_date',
                }"
              />
              <button
                ref="button"
                class="icon-margin ntss-btn-outset"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
                @click="setPatDataJsonArray(json, 'period_end_input_free', '1')"
              >
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <v-ons-icon icon="fa-dot-circle" />
              </button>
            </span>
            <span
              class="flex-align-center"
              v-if="
                isMoveInOutTemporarilyMovingOut(json) &&
                isEndDateInputFree(json)
              "
            >
              <custom-input
                ref="period_end_year"
                class="period-date"
                :maxlength="4"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
                :validators="[validateInteger]"
                form-name="終了日"
                :value="getPatDataJsonArray(json, 'period_end_year')"
                :datetype="'period-year'"
                :datetypeym="datetypechk(json)"
                :datetypeindex="datetypeindex('E_year', index)"
                :wheelChangeUse="true"
                @blur="addNumber(json, 'period_end_year')"
              />年
              <custom-input
                class="period-date"
                :maxlength="2"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
                :validators="[validateInteger]"
                :value="getPatDataJsonArray(json, 'period_end_month')"
                :datetype="'period-month'"
                :datetypeym="datetypechk(json)"
                :datetypeindex="datetypeindex('E_month', index)"
                :wheelChangeUse="true"
                @blur="addNumber(json, 'period_end_month')"
              />月
              <custom-input
                class="period-date"
                :maxlength="2"
                :validators="[validateInteger]"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
                :value="getPatDataJsonArray(json, 'period_end_day')"
                :datetype="'period-day'"
                :datetypeym="datetypechk(json)"
                :datetypeindex="datetypeindex('E_day', index)"
                :wheelChangeUse="true"
                @blur="addNumber(json, 'period_end_day')"
              />日
              <custom-input-calender
                class="calender"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
                :value="getPatDataJsonArray(json, 'period_end_date')"
                :callBackFunc="setDateEach"
                :arguments="{
                  json: json,
                  fromData: 'period_end_date',
                }"
              />
              <button
                ref="button"
                class="icon-margin ntss-btn-outset"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
                @click="setPatDataJsonArray(json, 'period_end_input_free', '0')"
              >
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <v-ons-icon icon="fa-dot-circle" />
              </button>
            </span>
          </td>
        </tr>
        <tr v-if="isMoveInOutToFacilityCourseDoctor(json)">
          <td class="item-title">施設</td>
          <td class="item-data">
            <!-- <custom-simple-textarea-a
              ref="from_facility"
              :value="getPatDataJsonArray(json, getFacilityJsonKey(json))"
              :display-string="dispFacilityName(json)"
              :disabled="isMoveInOutDeath(json) || !getItemAuthorized('PatInfo', 'default_authority')"
              form-name="【入外・転入出】施設"
              style="vertical-align: middle;"
            /> -->
            <custom-simple-textarea-a
              ref="from_facility"
              :value="getPatDataJsonArray(json, getFacilityJsonKey(json))"
              :display-string="getNameDisplay(json, dispFacilityName)"
              :disabled="isMoveInOutDeath(json) || isOtherFacilityRow(json) || !getItemAuthorized('PatInfo', 'default_authority')"
              form-name="【入外・転入出】施設"
              style="vertical-align: middle;"
            />
          </td>
          <td class="item-data choice-button-area">
            <v-ons-button
              v-if="!isMoveInOutDeath(json)"
              :ref="'btnSelectFacility' + index"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
              class="common-style-select-button btn3-normal"
              @click="
              selectPopoverData(
                'facility',
                json,
                popoverDataMstFacility(json),
                index
              )">
              選択
            </v-ons-button>
          </td>
        </tr>
        <tr v-if="isMoveInOutToFacilityCourseDoctor(json)">
          <td class="item-title">診療科</td>
          <td class="item-data">
            <!-- <custom-simple-textarea-a
              :value="getPatDataJsonArray(json, getCourseJsonKey(json))"
              :display-string="dispCourseName(json)"
              :disabled="isMoveInOutDeath(json) || isOtherFacilityRow(json) || !getItemAuthorized('PatInfo', 'default_authority')"
              style="vertical-align: middle;"
            /> -->
            <custom-simple-textarea-a
              :value="getPatDataJsonArray(json, getCourseJsonKey(json))"
              :display-string="getNameDisplay(json, dispCourseName)"
              :disabled="isMoveInOutDeath(json) || isOtherFacilityRow(json) || !getItemAuthorized('PatInfo', 'default_authority')"
              style="vertical-align: middle;"
            />
          </td>
          <td class="item-data choice-button-area">
            <v-ons-button
              v-if="!isMoveInOutDeath(json)"
              :ref="'btnSelectCourse' + index"
              class="common-style-select-button btn3-normal"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
              @click="selectPopoverData('course', json, popoverDataMstCourse(json), index)">
              選択
            </v-ons-button>
          </td>
        </tr>
        <tr v-if="isMoveInOutToFacilityCourseDoctor(json)">
          <td class="item-title">医師</td>
          <td class="item-data">
            <!-- <custom-simple-textarea-a
              :value="getPatDataJsonArray(json, getDoctorJsonKey(json))"
              :display-string="
                doctorName(
                  json,
                  getDoctorJsonKey(json),
                  getPatDataJsonArray(json, getFacilityJsonKey(json)).editValue
                )
              "
              :disabled="
                isMoveInOutDeath(json) ||
                !getItemAuthorized('PatInfo', 'default_authority') ||
                isOtherFacilityRow(json)
              "
              style="vertical-align: middle;"
            /> -->
            <custom-simple-textarea-a
              :value="getPatDataJsonArray(json, getDoctorJsonKey(json))"
              :display-string="
                getNameDisplay(
                  json,
                  getDoctorDisplay,
                  getDoctorJsonKey(json)
                )
              "
              :disabled="
                isMoveInOutDeath(json) ||
                !getItemAuthorized('PatInfo', 'default_authority') ||
                isOtherFacilityRow(json)
              "
              style="vertical-align: middle;"
            />
          </td>
          <td class="item-data choice-button-area">
            <v-ons-button
              v-if="!isMoveInOutDeath(json)"
              :ref="'btnSelectDoctor' + index"
              class="common-style-select-button btn3-normal"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow(json)"
              @click="selectDoctor(json, index)"
            >
              選択
            </v-ons-button>
          </td>
        </tr>
        <tr>
          <td class="item-title">入外</td>
          <td colspan="2" class="item-data">
            <custom-select
              :value="getSetInOutData(json)"
              :options="getInOutList(json)"
              :disabled="
                isMoveInOutDeath(json) ||
                !getItemAuthorized('PatInfo', 'default_authority') ||
                isOtherFacilityRow(json)
              "
            />
          </td>
        </tr>
        <tr>
          <td class="item-title">コメント</td>
          <td colspan="2" class="item-data">
            <com-textarea
              class="comTextarea"
              :disabled="
                !getItemAuthorized('PatInfo', 'default_authority') ||
                isOtherFacilityRow(json)
              "
              :content="getPatDataJsonArray(json, 'reason')"
              :idTextarea="'com-textarea-hst-reason' + index"
              cssClass="textarea-custom-text-font textarea-resize-vertical"
              @set-content-data="setContentData($event, index)"
            />
          </td>
        </tr>
      </table>
    </div>
    <div>
      <pop-over-facility
        v-bind="popoverDataFacility"
        :target-position-element="popoverTargetElement('btnSelectFacility')"
        @popover-close="closePopover(popoverDataFacility)"
        @popover-return="setPopoverDataFacility($event)"
      />
      <pop-over
        v-bind="popoverDataCourse"
        :target-position-element="popoverTargetElement('btnSelectCourse')"
        @popover-close="closePopover(popoverDataCourse)"
        @popover-return="setPopoverDataCourse($event)"
      />
      <pop-over
        v-bind="popoverDataDoctor"
        :target-position-element="popoverTargetElement('btnSelectDoctor')"
        @popover-close="closePopover(popoverDataDoctor)"
        @popover-return="setPopoverDataDoctor($event)"
      />
      <message-dialog
        :visible.sync="isDialogVisible"
        :message-cd="21120001"
        type="1"
      />
    </div>
  </div>
</template>

<script>
  // add #10359 編集権限の動作不正 dengshen start
  import { getAuthorized, deepCopy } from "@/functions/common/CommonFunctions.js";
  // add #10359 編集権限の動作不正 dengshen end
  import moment from "moment";
  import { mapGetters, mapActions } from "vuex";
  import { ApiHelper } from "@/apis/AxiosHelper";
  import {
    PAT_UNIQUE_COL_IN_OUT_VISIT_HISTORY_INFO_MOVE_IN_OUT_CLASS,
    PAT_UNIQUE_COL_IN_OUT_VISIT_HISTORY_INFO_IN_OUT_CLASS,
  } from "@/constants/PatInfo";
  import baseCardContent from "@/components/pat-info/base-components/BaseCardContent.vue";
  import messageDialog from "@/components/common/message-dialog/MessageDialog";
  import { getMaxDay } from "@/functions/common/DateTimeUtils";
  // add 編集権限の適用 じょはく start
  // del #10359 編集権限の動作不正 dengshen start
  // import { AUTHORITY_CODES } from "@/constants/userAuthority";
  // import { FUNC_PAT_INFO, FUNC_PAT_INFO_CREATE } from "@/constants/function-code";
  // del #10359 編集権限の動作不正 dengshen end
  // add 編集権限の適用 じょはく end
  //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
  import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
  //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end

  // 導入 区分値
  const MOVE_IN_OUT_CLASS_INTRODUCTION = "1";
  // 転入
  const MOVE_IN_OUT_CLASS_MOVE_IN = "2";
  // 転出
  const MOVE_IN_OUT_CLASS_MOVING_OUT = "3";
  // 入院
  const MOVE_IN_OUT_CLASS_HOSPITALIZATION = "4";
  // 退院
  const MOVE_IN_OUT_CLASS_DISCHARGE = "5";
  // 外来
  const MOVE_IN_OUT_CLASS_OUTPATIENT = "6";
  // 離脱
  const MOVE_IN_OUT_CLASS_WITHDRAWAL = "7";
  // 移植
  const MOVE_IN_OUT_CLASS_IMPLANTATION = "8";
  // 一時転出
  const MOVE_IN_OUT_CLASS_TEMPORARILY_MOVING_OUT = "9";
  // 通院拒否・不明
  const MOVE_IN_OUT_CLASS_REJECTION_UNKNOWN = "10";
  // 死亡
  const MOVE_IN_OUT_CLASS_DEATH = "11";

  // 外来 入外値
  const IN_OUT_CLASS_OUTPATIENT = 0;
  // 入院
  const IN_OUT_CLASS_HOSPITALIZATION = 1;
  // 死亡
  const IN_OUT_CLASS_DEATH = 2;
  // － (不在)
  const IN_OUT_CLASS_ABSRENCE = 3;

  export default {
    name: "VisitHstCard",
    components: {
      "message-dialog": messageDialog,
    },
    mixins: [baseCardContent],

    data() {
      return {
        // del #10359 編集権限の動作不正 dengshen start
        // // add 編集権限の適用 じょはく start
        // isPatViewAuthorized: null,
        // isPatEditAuthorized: null,
        // isCreatePatViewAuthorized: null,
        // editFlag: null,
        // // add 編集権限の適用 じょはく end
        // del #10359 編集権限の動作不正 dengshen end
        arrayColName: "in_out_visit_history_info",
        moveInOutClass:
        PAT_UNIQUE_COL_IN_OUT_VISIT_HISTORY_INFO_MOVE_IN_OUT_CLASS,
        inOutClass: PAT_UNIQUE_COL_IN_OUT_VISIT_HISTORY_INFO_IN_OUT_CLASS,
        // 自施設
        ownFacility: null,
        // 吹き出しデータ
        popoverDataFacility: {},
        popoverDataCourse: {},
        popoverDataDoctor: {},
        /* del by chamaojia 2025-05-21 [11871]  --start */
        // iPhoneアクセスプログラム、画面メモリオーバーフロー改造
        // マスタデータ
        // mstFacility: null,
        /* del by chamaojia 2025-05-21 [11871]  --end */
        mstCourse: null,
        mstUser: null,
        // マスタデータ保持
        selectedJson: null,
        selectedIndex: null,
        selectJson: null,
        selectIndex: null,
        isVisitHstMessage: false,
        oldestDialysis: { facilityCd: null, date: null },
        isDialogVisible: false,
        userData: [],
        isInitFinished: false,
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
        initRecord: null,
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
        facilityNameList: [],
      };
    },

    // add 編集権限の適用 じょはく start
    props: {
      // 新規登録フラグ
      isCreationPat: {
        type: Boolean,
        default: false,
      },
    },
    // add 編集権限の適用 じょはく end

    computed: {
      ...mapGetters("user", ["getFacilityCd"]),
      ...mapGetters("user-selector-popover", ["mstJob"]),
      // add 編集権限の適用 じょはく start
      ...mapGetters("account-edit", [
        "getStateUserAccountInfo",
      // mod #10359、#10331 編集権限について、対応する。 dengshen start
      //   "getUseFunctions",
        "getAuthorizedFunctions",
      // mod #10359、#10331 編集権限について、対応する。 dengshen end
      ]),
      // add 編集権限の適用 じょはく end
      /* del by chamaojia 2025-05-21 [11871]  --start */
      // iPhoneアクセスプログラム、画面メモリオーバーフロー改造
      // ...mapGetters("sys-facility", ["getSysFacilities", "getSysFacilitiesForName"]),
      /* del by chamaojia 2025-05-21 [11871]  --end */
      ...mapGetters("pat-info", ["selectedPatId", "getIsOtherFacility", "getOtherFacilityCd"]),
      jsonArray: {
        get() {
          let arrVisitHstInfoSorted = [];
          // 開始日の降順でソートするため、日付を確認
          for (var visHstInf of this.editRecord[this.arrayColName]) {
            var sortDate = "";
            if (
              visHstInf["period_start_year"].initValue &&
              visHstInf["period_start_month"].initValue &&
              visHstInf["period_start_day"].initValue
            ) {
              // 開始日の年月日がそろっている場合
              sortDate =
                visHstInf["period_start_year"].initValue +
                visHstInf["period_start_month"].initValue +
                visHstInf["period_start_day"].initValue;
            } else if (
              visHstInf["period_start_year"].initValue &&
              visHstInf["period_start_month"].initValue
            ) {
              // 開始日の年月が入力されている場合
              sortDate =
                visHstInf["period_start_year"].initValue +
                visHstInf["period_start_month"].initValue +
                "00";
            } else if (visHstInf["period_start_year"].initValue) {
              // 開始日の年が入力されている場合
              sortDate = visHstInf["period_start_year"].initValue + "0000";
            } else {
              // 開始日が空
              sortDate = "00000000";
            }
            visHstInf["sort_date"] = sortDate;
            // add FNSI-患者情報消除できない 徐博 start
            visHstInf["in_out_check"] = true;
            // add FNSI-患者情報消除できない 徐博 end
            arrVisitHstInfoSorted.push(visHstInf);
          }
          // 並べ替え実施
          arrVisitHstInfoSorted.sort(function (a, b) {
            if (a.sort_date < b.sort_date) return 1;
            if (a.sort_date > b.sort_date) return -1;
            // add FutreNetWeb+SI課題管理No6016 趙 start
            if (a.sort_date == b.sort_date){
              if (a.ctl_no.editValue < b.ctl_no.editValue) return 1;
              if (a.ctl_no.editValue > b.ctl_no.editValue) return -1;
            }
            // add FutreNetWeb+SI課題管理No6016 趙 end
              return 0;
          });
          // 並べ替え用のカラムを削除
          arrVisitHstInfoSorted.forEach((p) => delete p.sort_date);

          return arrVisitHstInfoSorted;
        },

        set(sortedAry) {
          this.editRecord[this.arrayColName] = sortedAry;
        },
      },

      /**
       * @description 取得したデータ内に導入区分(自施設)が存在するか否か
       * @returns {Boolean}
       */
      isJsonArrayToOwnFacility() {
        const JsonArrayToIntroduction = this.jsonArray.filter(
          (json) => json.move_in_out.editValue === MOVE_IN_OUT_CLASS_INTRODUCTION
        );
        const jsonArrayToOwnFacility = JsonArrayToIntroduction.find(
          (json) => json.from_facility.editValue === this.ownFacility
        );
        return jsonArrayToOwnFacility !== undefined;
      },

      userArray() {
        return this.userData;
      },
    },

    watch: {
      async selectedPatId() {
        this.switchingSelectedPatFlg = true;
        this.refreshData();
        // 選択患者が変更されたので、施設名リストを初期化
        this.facilityNameList = [];
        // 施設名リスト再取得
        await this.loadFacilityNameList();
        this.$nextTick(() => {
          this.switchingSelectedPatFlg = false;
        });
      }
    },

    // マスタデータ取得
    async created() {
      this.refreshData();

      // 自施設登録
      this.ownFacility = this.getFacilityCd;
      this.setOldestDialysis();

      // 施設名リスト取得
      await this.loadFacilityNameList();

      this.userData = [];
      let params = [];
      params = params.filter((e) => e !== null);
      if (params.length > 0) {
        await ApiHelper.post("/mstInfo/mstPersonalUserByIdList", params).then(
          (res) => {
            let item = [];
            for (let i = 0; i < res.data.length; i++) {
              const itemInfo = {
                userId: res.data[i].userId,
                userName: res.data[i].userName,
              };
              item.push(itemInfo);
            }
            this.userData = this.userData.concat(item);
          }
        );
      }
      this.getMstJobData();
      this.isInitFinished = true;
    },

    // add bug #7125 修正 chen start
    beforeDestroy() {
      // dataの初期化
      Object.assign(this.$data, this.$options.data());
    },
    // add bug #7125 修正 chen end

    methods: {
      ...mapActions("mst-facility-setting", ["getDoctorsAtFacility", "getDoctorsAtFacilityIncludeDel"]),
      ...mapActions("user-selector-popover", ["getMstJobData"]),
      // ...mapActions("user-selector-popover", ["getMst"]), modify by maxueqiang
      /* del by chamaojia 2025-05-21 [11871]  --start */
      // iPhoneアクセスプログラム、画面メモリオーバーフロー改造
      // ...mapActions("sys-facility", ["loadSysFacility"]),
      /* del by chamaojia 2025-05-21 [11871]  --end */
      ...mapActions("loading-screen", ["setLoadingScreenMessage", "setLoadingScreenVisible"]),
      //#10866：日付(不定型)の部品修正Start
      datetypechk(json) {
        const ym = this.getPatDataJsonArray(json, 'period_start')
        return ym.editValue;
      },
      //#10866:日付(不定型)の部品修正・検証NG対応　Start
      datetypeindex(action, index) {
        return action + index;
      },
      //#10866:日付(不定型)の部品修正・検証NG対応　End
      //#10866：日付(不定型)の部品修正End
      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
      // add #10359 編集権限の動作不正 dengshen start
      getItemAuthorized(pageCd, itemCd) {
        return getAuthorized(pageCd, itemCd);
      },

      //
      changeinputfree(json, Flag) {
        this.setPatDataJsonArray(json, 'period_start_input_free', Flag);
        let start_date = this.getPatDataJsonArray(json, 'period_start_date');
        if (start_date.editValue === null || start_date.editValue === 'Invalid date') {
          //#10715:日付IF修正Start
          //#10715：日付IF修正20240910検証NG対応：村上Start
          if ((start_date.editValue != start_date.initValue) || start_date.initValue === null) {
            //#10715：日付IF修正20240910検証NG対応：村上End
            this.setPatDataJsonArray(json, 'period_start_date', null);
            this.setPatDataJsonArray(json, 'period_start_year', null);
            this.setPatDataJsonArray(json, 'period_start_month', null);
            this.setPatDataJsonArray(json, 'period_start_day', null);
          }
          //#10715:日付IF修正End
        }
      },

      // add bug #7125 修正 chen start
      async refreshData() {
        this.setLoadingScreenVisible(true);
        try {
          const responseCourse = await ApiHelper.get("/mstInfo/mstAllCourse").catch(
            (error) => {
              getErrorMessage("VisitHstCardContent.vue", "created", error);
              throw error;
            }
          );
          this.mstCourse = responseCourse.data;

          // 登録済みの医師を取得
          const facility_cd = this.getFacilityCd;
          const responseUser = await this.getDoctorsAtFacilityIncludeDel(facility_cd).catch(
            (error) => {
              getErrorMessage("VisitHstCardContent.vue", "created", error);
              throw error;
            }
          );
          this.mstUser = responseUser.data;
        } catch (error) {
          this.setLoadingScreenVisible(false);
        }
        this.setLoadingScreenVisible(false);
        this.initRecord = deepCopy(this.editRecord);
      },

      setJsonIndex(json, index) {
        this.selectJson = json;
        this.selectIndex = index;
        this.jsonArray[index].in_out_check = false;
        const delItem = (json) => {
          let ctlNo = json["ctl_no"].editValue;
          if (ctlNo === 0) {
            this.jsonArray.splice(index, 1);
            this.jsonArray = [...this.jsonArray];
          } else if (ctlNo > 0){
            json["ctl_no"].editValue = ctlNo * -1;
          }
          this.actionMode = false;
        }
        if (this.isMoveInOutDeath(json)) {
          this.$ons.notification
            .confirm({
              title: "入外・転入出の削除",
              message: "既往歴の死亡情報も削除されますがよろしいですか？"
            })
            .then((ok) => {
              if (ok) {
                this.isVisitHstMessage = false;
                delItem(json);
              }
            });
        } else {
          delItem(json);
        }
      },

      /**
       * @description キー名を返す関数
       * @summary キー取得:施設
       * @param {Object} json
       * @param {String} jsonKey
       * @returns {String}
       */
      // mod #12462 患者情報共有 Ji start
      getFacilityJsonKey(json) {
        const isOtherFacility = json.facility_cd?.initValue !== this.getFacilityCd;
        if (this.isToData(json)) {
          return isOtherFacility ? "to_facility_name" : "to_facility";
        }
        return isOtherFacility ? "from_facility_name" : "from_facility";
      },
      // mod #12462 患者情報共有 Ji end

      /**
       * @description キー名を返す関数
       * @summary キー取得:診療科
       * @param {Object} json
       * @param {String} jsonKey
       * @returns {String}
       */
      // mod #12462 患者情報共有 Ji start
      getCourseJsonKey(json) {
        const isOtherFacility = json.facility_cd?.initValue !== this.getFacilityCd;
        if (this.isToData(json)) {
          return isOtherFacility ? "to_course_name" : "to_course";
        }
        return isOtherFacility ? "from_course_name" : "from_course";
      },
      // mod #12462 患者情報共有 Ji end

      /**
       * @description キー名を返す関数
       * @summary キー取得:担当医
       * @param {Object} json
       * @param {String} jsonKey
       * @returns {String}
       */
      // mod #12462 患者情報共有 Ji start
      getDoctorJsonKey(json) {
        const isOtherFacility = json.facility_cd?.initValue !== this.getFacilityCd;
        if (this.isToData(json)) {
          return isOtherFacility ? "to_doctor_name" : "to_doctor";
        }
        return isOtherFacility ? "from_doctor_name" : "from_doctor";
      },
      // mod #12462 患者情報共有 Ji end

      /**
       * @description 区分が選択されたか判定
       * @param {Object} json
       * @returns {Boolean}
       */
      isMoveInOut(json) {
        return this.getPatDataJsonArray(json, "move_in_out").editValue === null;
      },

      /**
       * @description 施設が選択されたか判定
       * @param {Object} json
       * @returns {Boolean}
       */
      isFacility(json) {
        return (
          this.getPatDataJsonArray(json, this.getFacilityJsonKey(json))
            .editValue === null
        );
      },

      /**
       * @description 転出と一時転出が選択されたらtrueを返す
       * @summary 先施設、診療科、担当医を表示
       * @param {Object} json
       * @returns {Boolean}
       */
      isToData(json) {
        return (
          this.isMoveInOutMovingOut(json) ||
          this.isMoveInOutTemporarilyMovingOut(json)
        );
      },

      /**
       * @description 導入が選択されたらtrueを返す
       * @param {Object} json
       * @returns {Boolean}
       */
      isMoveInOutIntroduction(json) {
        return this.moveInOutValue(json) === MOVE_IN_OUT_CLASS_INTRODUCTION;
      },

      /**
       * @description 転出が選択されたらtrueを返す
       * @param {Object} json
       * @returns {Boolean}
       */
      isMoveInOutMovingOut(json) {
        return this.moveInOutValue(json) === MOVE_IN_OUT_CLASS_MOVING_OUT;
      },

      /**
       * @description 転入が選択されたらtrueを返す
       * @param {Object} json
       * @returns {Boolean}
       */
      isMoveInOutMoveIn(json) {
        return this.moveInOutValue(json) === MOVE_IN_OUT_CLASS_MOVE_IN;
      },

      /**
       * @description 入院が選択されたらtrueを返す
       * @param {Object} json
       * @returns {Boolean}
       */
      isMoveInOutHospitalization(json) {
        return this.moveInOutValue(json) === MOVE_IN_OUT_CLASS_HOSPITALIZATION;
      },

      /**
       * @description 退院が選択されたらtrueを返す
       * @param {Object} json
       * @returns {Boolean}
       */
      isMoveInOutDischarge(json) {
        return this.moveInOutValue(json) === MOVE_IN_OUT_CLASS_DISCHARGE;
      },

      /**
       * @description 外来が選択されたらtrueを返す
       * @param {Object} json
       * @returns {Boolean}
       */
      isMoveInOutOutPatient(json) {
        return this.moveInOutValue(json) === MOVE_IN_OUT_CLASS_OUTPATIENT;
      },

      /**
       * @description 死亡が選択されたらtrueを返す
       * @param {Object} json
       * @returns {Boolean}
       */
      isMoveInOutDeath(json) {
        return this.moveInOutValue(json) === MOVE_IN_OUT_CLASS_DEATH;
      },

      /**
       * @description 離脱が選択されたらtrueを返す
       * @param {Object} json
       * @returns {Boolean}
       */
      isMoveInOutWithdrawal(json) {
        return this.moveInOutValue(json) === MOVE_IN_OUT_CLASS_WITHDRAWAL;
      },

      /**
       * @description 移植が選択されたらtrueを返す
       * @param {Object} json
       * @returns {Boolean}
       */
      isMoveInOutImplantatlon(json) {
        return this.moveInOutValue(json) === MOVE_IN_OUT_CLASS_IMPLANTATION;
      },

      /**
       * @description 一時転出が選択されたらtrueを返す
       * @param {Object} json
       * @returns {Boolean}
       */
      isMoveInOutTemporarilyMovingOut(json) {
        return (
          this.moveInOutValue(json) === MOVE_IN_OUT_CLASS_TEMPORARILY_MOVING_OUT
        );
      },

      /**
       * @description 通院拒否・不明が選択されたらtrueを返す
       * @param {Object} json
       * @returns {Boolean}
       */
      isMoveInOutClassRejectionUnknown(json) {
        return this.moveInOutValue(json) === MOVE_IN_OUT_CLASS_REJECTION_UNKNOWN;
      },

      /**
       * @description 自施設か比較する
       * @param {Object} json
       * @returns {Boolean}
       */
      isOwnFacility(json) {
        return this.getFacilityData(json) === this.ownFacility;
      },

      /**
       * @description 開始日フリー入力が選択されたらtrueを返す
       * @param {Object} json
       * @returns {Boolean}
       */
      isStartDateInputFree(json) {
        return (
          this.getPatDataJsonArray(json, "period_start_input_free").editValue ===
          "1"
        );
      },

      /**
       * @description 終了日フリー入力が選択されたらtrueを返す
       * @param {Object} json
       * @returns {Boolean}
       */
      isEndDateInputFree(json) {
        return (
          this.getPatDataJsonArray(json, "period_end_input_free").editValue ===
          "1"
        );
      },

      /**
       * @description 区分コード取得
       * @param {Object} json
       * @returns {String}
       */
      moveInOutValue(json) {
        return this.getPatDataJsonArray(json, "move_in_out").editValue;
      },

      /**
       * @description 選択ボタンを押す度にポップオーバーオブジェクトを作成
       * @param {Object} json
       * @returns {Object}
       */
      popoverDataMstFacility(json) {
        /* modify by chamaojia 2025-05-21 [11871]  --start */
        // this.popoverDataFacility = this.createPopoverDataFacility(
        //   "施設",
        //   "施設名",
        //   this.shavedMstData(json, this.mstFacility),
        //   this.getPatDataJsonArray(json, this.getFacilityJsonKey(json)).editValue
        // );
        let cd = this.getPatDataJsonArray(json, this.getFacilityJsonKey(json)).editValue;
        let rest = {
          popoverVisible: false,
          popoverTitleHeader:"施設",
          popoverContentLabel:"施設名",
          popoverContentDataset:[],
          popoverContentSelected:
              {
                "value": cd,
                "text": "",
                "prefecturesCd": "",
                "medicalInstitutionCd": cd
              }
        };
        this.popoverDataFacility = rest;
        /* modify by chamaojia 2025-05-21 [11871]  --end */
        return this.popoverDataFacility;
      },

      /**
       * @description 選択ボタンを押す度にポップオーバーオブジェクトを作成
       * @param {Object} json
       * @returns {Object}
       */
      popoverDataMstCourse(json) {
        const facility_cd = this.getFacilityCd;
        const sortedMstCourse = this.mstCourse.sort((a, b) => a.standardCourseCd - b.standardCourseCd);
        const mstCourseFilter = sortedMstCourse.map(item => {
          return {
            courseCd: item.courseCd,
            facilityCd: item.facilityCd,
            fnCourseCd: item.fnCourseCd,
            courseName: item.courseName,
            standardCourseCd: item.standardCourseCd,
            inHospitalCd_1: item.inHospitalCd_1,
            isDisp: item.isDisp,
            isDel: item.isDel,
            regDate: item.regDate,
            upDate: item.upDate,
            operatorId: item.operatorId,
            clientIp: item.clientIp,
            logUserId: item.logUserId,
            updateFlg: item.updateFlg,
          };
        }).filter(item => item.facilityCd === facility_cd && ((item.isDisp !== "0" && item.isDel !== "1")));

        this.popoverDataCourse = this.createPopoverData(
          "診療科",
          null,
          null,
          "診療科名",
          mstCourseFilter,
          "courseCd",
          "courseName",
          null
        );
        return this.popoverDataCourse;
      },

      /**
       * @description 選択ボタンを押す度にポップオーバーオブジェクトを作成
       * @param {Object} json
       * @returns {Object}
       */
      async selectDoctor(json, index) {
        const facility_cd = this.getFacilityCd;
        const responseUser = await this.getDoctorsAtFacility(facility_cd).catch(
          (error) => {
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
            getErrorMessage("VisitHstCardContent.vue", "selectDoctor", error);
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
            throw error;
          }
        );

        this.popoverDataDoctor = this.createPopoverData(
          "担当医",
          null,
          null,
          "担当医名",
          this.shavedMstData(json, responseUser.data),
          "user_id",
          "user_last_name",
          // modify start 馬 #10097
          "job_cd",
          // modify end 馬 #10097
          "user_first_name"
        );

        // ポップオーバのフィルタデータを取りまとめる
        const all = { text: "すべて", value: 0 };
        const filterJobCdArr = [
          all,
          ...this.mstJob?.filter((item) => {
            return item.isDoctor === '1';
          })?.map((item) => ({
            text: item.jobName,
            value: String(item.jobCd),
          })),
        ];

        // ドロップダウン選択肢設定
        this.popoverDataDoctor.popoverFilter = [
          {
            popoverFilterLabel: "職種",
            popoverFilterDataset: filterJobCdArr,
          },
        ];
        // modify start 馬 #10097
        this.popoverDataDoctor.popoverFilterDisabled = false;
        // modify end 馬 #10097
        this.popoverDataDoctor.popoverContentDataset.forEach((item) => {
          item.fnValue = { 職種: item.fnValue };
        });

        this.selectPopoverData("doctor", json, this.popoverDataDoctor, index);

        // 取得したマスタユーザーを表示ようにマスタへ格納
        const isFacilityCd = this.mstUser.find((item) => {
          return item.facilityCd === facility_cd;
        });
        if (isFacilityCd === undefined) {
          this.mstUser.push(...responseUser.data);
        }
      },

      /**
       * @description マスタデータから自施設、透析実施科、主治医を非表示へ
       * @param {Object} json
       * @param {Object} mstData
       * @returns {Object}
       */
      shavedMstData(json, mstData) {
        if (this.isMoveInOutMovingOut(json) || this.isMoveInOutMoveIn(json)) {
          // 転出、転入マスタデータから自施設を非表示へ
          return mstData.filter((mst) => mst.facilityCd !== this.ownFacility);
        }
        if (
          this.isMoveInOutIntroduction(json) &&
          this.isJsonArrayToOwnFacility &&
          this.getPatDataJsonArray(json, "from_facility").editValue !==
          this.ownFacility
        ) {
          // 導入区分の自施設が選択されていたらそれ以外の導入区分のシートから自施設を非表示へ
          return mstData.filter((mst) => mst.facilityCd !== this.ownFacility);
        }
        return mstData;
      },

      /**
       * @description 入外・転入出項目データセット関数を呼ぶ
       * @summary 区画、施設、診療科、担当医、入外
       * @param {Object} json
       */
      setVisitHstData(json) {
        this.setPeriodEnd(json);
        this.setVisitHstPopoverData(json);
        this.setInOutValue(json);
        if (!this.isMoveInOutToFacilityCourseDoctor(json)) {
          this.setPatDataJsonArray(json, "facility_is_free", "0");
        }
      },

      /**
       * @description 区分データ取得、区分一時転出以外なら転入出期間(終了)にnullセット
       * @param {Object} json
       */
      setPeriodEnd(json) {
        if (!this.isMoveInOutTemporarilyMovingOut(json)) {
          this.setPatDataJsonArray(json, "period_end", null);
          this.setPatDataJsonArray(json, "period_end_date", null);
          this.$delete(json, "period_end_date");
          this.setPatDataJsonArray(json, "period_end_year", null);
          this.setPatDataJsonArray(json, "period_end_month", null);
          this.setPatDataJsonArray(json, "period_end_day", null);
        }
      },

      /**
       * @description 自施設、診療科、担当医セット
       * @param {Object} json
       */
      setVisitHstPopoverData(json) {
        if (
          this.isMoveInOutHospitalization(json) ||
          this.isMoveInOutDischarge(json)
        ) {
          // 非表示、入院、退院は施設に自施設セット
          this.setOwnNullData(json, "from_", this.ownFacility, null, null);
          this.setOwnNullData(json, "to_", null, null, null);
        } else {
          // nullセット
          this.setOwnNullData(json, "from_", null, null, null);
          this.setOwnNullData(json, "to_", null, null, null);
        }
        this.setPatDataJsonArray(json, "from_medicalInstitutionCd", null);
        this.setPatDataJsonArray(json, "to_medicalInstitutionCd", null);
        this.setPatDataJsonArray(json, "course_is_free", 0);
        this.setPatDataJsonArray(json, "doctor_is_free", 0);
      },

      /**
       * @description 施設、診療科、担当医にデータセット
       * @param {Object} json
       * @param {String} jsonKey
       * @param {String} facilityValue 施設
       * @param {Number} courseValue 診療科
       * @param {String} doctorValue 担当医
       */
      setOwnNullData(json, jsonKey, facilityValue, courseValue, doctorValue) {
        this.setPatDataJsonArray(json, `${jsonKey}facility`, facilityValue);
        this.setPatDataJsonArray(json, `${jsonKey}course`, courseValue);
        this.setPatDataJsonArray(json, `${jsonKey}doctor`, doctorValue);
      },

      /**
       * @description 非活性の入外コードセット
       * @param {Object} json
       */
      setInOutValue(json) {
        if (
          !this.isMoveInOutIntroduction(json) ||
          !this.isMoveInOutMoveIn(json)
        ) {
          this.setPatDataJsonArray(json, "in_out", this.getInOutData(json));
        }
      },

      /**
       * @description 区分に対して入外データ(初期値)を返す
       * @param {Object} json
       * @returns {String}
       */
      getInOutData(json) {
        let inOutData;
        switch (this.moveInOutValue(json)) {
          // 転出、離脱、移植、一時転出、通院拒否・不明
          case MOVE_IN_OUT_CLASS_MOVING_OUT:
          case MOVE_IN_OUT_CLASS_WITHDRAWAL:
          case MOVE_IN_OUT_CLASS_IMPLANTATION:
          case MOVE_IN_OUT_CLASS_TEMPORARILY_MOVING_OUT:
          case MOVE_IN_OUT_CLASS_REJECTION_UNKNOWN:
            inOutData = IN_OUT_CLASS_ABSRENCE;
            break;

          case MOVE_IN_OUT_CLASS_HOSPITALIZATION:
            // 入院
            inOutData = IN_OUT_CLASS_HOSPITALIZATION;
            break;

          case MOVE_IN_OUT_CLASS_DISCHARGE:
          case MOVE_IN_OUT_CLASS_OUTPATIENT:
            // 退院、外来
            inOutData = IN_OUT_CLASS_OUTPATIENT;
            break;

          case MOVE_IN_OUT_CLASS_DEATH:
            // 死亡
            inOutData = IN_OUT_CLASS_DEATH;
            break;
        }
        return inOutData;
      },

      /**
       * @description 入外コードを取得・入力
       * @param {Object} json
       * @returns {Object}
       */
      getSetInOutData(json) {
        if (
          (this.isMoveInOutIntroduction(json) || this.isMoveInOutMoveIn(json)) &&
          (this.getPatDataJsonArray(json, "in_out").editValue === undefined ||
            this.getPatDataJsonArray(json, "in_out").editValue === null)
        ) {
          // 導入、転入の新規追加カードには入外区分をあらかじめ選択しておく
          this.setPatDataJsonArray(json, "in_out", IN_OUT_CLASS_OUTPATIENT);
        } else if (
          this.getPatDataJsonArray(json, "in_out").editValue === undefined
        ) {
          // nullを入力する、区分・導入の他施設、・転入の未選択
          this.setPatDataJsonArray(json, "in_out", null);
        }
        return this.getPatDataJsonArray(json, "in_out");
      },

      /**
       * @description 区画データ絞り込み
       * @returns {Array}
       */
      getMoveInOutClass(json) {
        if (this.isMoveInOutDeath(json)) {
          return this.moveInOutClass.filter(
            (moveInOut) => moveInOut.value === MOVE_IN_OUT_CLASS_DEATH
          );
        } else {
          return this.moveInOutClass.filter(
            (moveInOut) => moveInOut.value !== MOVE_IN_OUT_CLASS_DEATH
          );
        }
      },

      /**
       * @description 入外リスト(表示候補)の取得
       * @param {Object} json
       * @returns {Array}
       * @remark 表示順：-(不在)→外来→入院
       */
      getInOutList(json) {
        // 配列の初期化
        let val = [];
        // 条件分岐
        switch (this.moveInOutValue(json)) {
          // 区分 = '1'：導入・'2'：転入の場合
          case MOVE_IN_OUT_CLASS_INTRODUCTION:
          case MOVE_IN_OUT_CLASS_MOVE_IN:
            // 入外 = '0'：外来
            val.push(this.inOutClass.find((item) => item.value === IN_OUT_CLASS_OUTPATIENT));
            // 入外 = '1'：入院
            val.push(this.inOutClass.find((item) => item.value === IN_OUT_CLASS_HOSPITALIZATION));
            break;
          // 区分 = '3'：転出・10'：通院拒否・不明の場合
          case MOVE_IN_OUT_CLASS_MOVING_OUT:
          case MOVE_IN_OUT_CLASS_REJECTION_UNKNOWN:
            // 入外 = '3'：-(不在)
            val.push(this.inOutClass.find((item) => item.value === IN_OUT_CLASS_ABSRENCE));
            break;
          // 区分 = '4'：入院の場合
          case MOVE_IN_OUT_CLASS_HOSPITALIZATION:
            // 入外 = '1'：入院
            val.push(this.inOutClass.find((item) => item.value === IN_OUT_CLASS_HOSPITALIZATION));
            break;
          // 区分 = '5'：退院の場合
          case MOVE_IN_OUT_CLASS_DISCHARGE:
            // 入外 = '3'：-(不在)
            val.push(this.inOutClass.find((item) => item.value === IN_OUT_CLASS_ABSRENCE));
            // 入外 = '0'：外来
            val.push(this.inOutClass.find((item) => item.value === IN_OUT_CLASS_OUTPATIENT));
            break;
          // 区分 = '6'：外来の場合
          case MOVE_IN_OUT_CLASS_OUTPATIENT:
            // 入外 = '0'：外来
            val.push(this.inOutClass.find((item) => item.value === IN_OUT_CLASS_OUTPATIENT));
            break;
          // 区分 = '7'：離脱・'8'：移植・'9'：一時転出の場合
          case MOVE_IN_OUT_CLASS_WITHDRAWAL:
          case MOVE_IN_OUT_CLASS_IMPLANTATION:
          case MOVE_IN_OUT_CLASS_TEMPORARILY_MOVING_OUT:
            // 入外 = '3'：-(不在)
            val.push(this.inOutClass.find((item) => item.value === IN_OUT_CLASS_ABSRENCE));
            // 入外 = '0'：外来
            val.push(this.inOutClass.find((item) => item.value === IN_OUT_CLASS_OUTPATIENT))
            // 入外 = '1'：入院
            val.push(this.inOutClass.find((item) => item.value === IN_OUT_CLASS_HOSPITALIZATION));
            break;
          // 区分 = '11'：死亡の場合
          case MOVE_IN_OUT_CLASS_DEATH:
            // 入外 = '2'：死亡
            val.push(this.inOutClass.find((item) => item.value === IN_OUT_CLASS_DEATH));
            break;
        }
        return val;
      },

      // add FNSI-入外区分の入力方法を2種類(簡易/詳細)用意し、簡易入力 徐博 start
      getInOutStauts() {
        let flag = true;
        let moveInOutValue = this.$refs.move_in_out;
        // console.log("getInOutStauts.moveInOutValue is :", moveInOutV alue);
        // add No.15 じょはく start
        let length;
        // add No.15 じょはく end
        if (
          moveInOutValue != undefined &&
          moveInOutValue != null &&
          moveInOutValue != ""
        ) {
          // mod No.15 じょはく start
          // flag = true;
          length = moveInOutValue.length;
          // modify by maxueqiang,modify the symbol from "<" to "<="
          for (var i = 0; i <= length - 1; i++) {
            if (moveInOutValue[i].isRequired === true) {
              flag = moveInOutValue[i].editValue;
              break;
            }
          }
          // mod No.15 じょはく end
        } else {
          flag = false;
        }
        return flag;
      },

      async setInOutVal(val) {
        // console.log("setInOutVal is begin : ", val);
        const date = moment().format("YYYYMMDD");
        if (val == 1) {
          //  入院
          await this.addItem();
          this.jsonArray[0].move_in_out.editValue = "4";
          this.jsonArray[0].period_start_date.editValue = date;
          this.jsonArray[0].in_out.editValue = 1;
        } else if (val == 0) {
          //  外来
          await this.addItem();
          this.jsonArray[0].move_in_out.editValue = "6";
          this.jsonArray[0].period_start_date.editValue = date;
          this.jsonArray[0].in_out.editValue = 0;
        }
          // ③本人情報の入外区分：不明（3）を選択した場合
          //    現状通り、入外・転入出カードに、新規登録不要
          // bug:4481 maxueqiang
          // else if (val == 3){
          //   // 不明
          //   await this.addItem();
          //   this.jsonArray[0].move_in_out.editValue = MOVE_IN_OUT_CLASS_REJECTION_UNKNOWN;
          //   this.jsonArray[0].period_start_date.editValue = date;
          //   this.jsonArray[0].in_out.editValue = IN_OUT_CLASS_ABSRENCE
          // }
        // bug:4481 maxueqiang end
        else {
          // 不明とnullの時、操作しない
          return false;
        }
      },

      // add No.15 じょはく start
      // mod FutreNetWeb+SI課題管理No6016 趙 start
      // async setInOutEditVal(val, val1) {
      async setInOutEditVal(val, val1, val2) {
      // mod FutreNetWeb+SI課題管理No6016 趙 end
        // console.log("setInOutEditVal is begin", val, val1);
        let length = this.$refs.move_in_out.length;
        let length1 = 1;
        const date = moment().format("YYYYMMDD");
        if (val == 1 && val1 == 4) {
          // 両方は入院
          return false;
        } else if (val == 0 && val1 == 6) {
          // 両方は外来
          return false;
        } else if (val == 1 && val1 != 4) {
          // mod FutreNetWeb+SI課題管理No6016 趙 start
          // 本人情報は入院、入外は入院ではない
          // if (length != 0 && this.jsonArray[length - 1].in_out.editValue == "1") {
          //   return false;
          // }
          // add FutreNetWeb+SI課題管理No6124 趙 start
          // if (length >= 2 && this.jsonArray[length - 2].in_out.editValue == "1") {
          //   return false;
          // }
          // add FutreNetWeb+SI課題管理No6124 趙 end
          if(val2){
            // mod 6625【ST試験】【S12_患者の既往・転入履歴】患者情報：患者状態が変更された場合、ページ頭部状態は変更されない zhou　start
            //if (length != 0 && this.jsonArray[0].in_out.editValue == "1") {
            if (length != 0 && this.jsonArray[0].in_out.initValue == 1) {
              // mod 6625【ST試験】【S12_患者の既往・転入履歴】患者情報：患者状態が変更された場合、ページ頭部状態は変更されない zhou　end
              return false;
            }
            else{
              for(var i = 0; i <= length - 1; i++) {
                if (this.jsonArray[i].period_start_date.editValue < date) {
                  length1 = length1 + 1;
                }
              }
              // mod #8302 by liuzhibo start
              // if (length != 0 && this.jsonArray[length - length1].in_out.editValue == "1") {
                // mod 6625【ST試験】【S12_患者の既往・転入履歴】患者情報：患者状態が変更された場合、ページ頭部状態は変更されない zhou　start
              //if (length >= length1 && this.jsonArray[length - length1].in_out.editValue == "1") {
                if (length >= length1 && this.jsonArray[length - length1].in_out.initValue == 1) {
                  // mod 6625【ST試験】【S12_患者の既往・転入履歴】患者情報：患者状態が変更された場合、ページ頭部状態は変更されない zhou　end
              // mod #8302 by liuzhibo end
                return false;
              }
            }
          }
          // mod FutreNetWeb+SI課題管理No6016 趙 start
          await this.addItem();
          this.jsonArray[length].move_in_out.editValue = "4";
          this.jsonArray[length].period_start_date.editValue = date;
          this.jsonArray[length].in_out.editValue = 1;
        } else if (val == 0 && val1 != 6) {
          // 本人情報は外来、入外は外来ではない
          //保存する時に、入外・転入出カードに外来（０）の情報が存在する場合、
          // 現状通り、入外・転入出カードに、新規登録不要
          // console.log("setInOutEditVal.jsonArray is : ",JSON.stringify(this.jsonArray));
          // if (
          //   (length != 0 && this.jsonArray[length - 1].in_out.editValue == "0") ||
          //   (length != 0 && this.jsonArray[length - 1].in_out.editValue == "1")
          // ) {
          //   return false;
          // }
          // mod FutreNetWeb+SI課題管理No6016 趙 start
          // add FutreNetWeb+SI課題管理No6024 趙 start
          // if (length != 0 && this.jsonArray[length - 1].in_out.editValue == "0") {
          //   return false;
          // }
          // add FutreNetWeb+SI課題管理No6024 趙 end
          // add FutreNetWeb+SI課題管理No6124 趙 start
          // if (length >= 2 && this.jsonArray[length - 2].in_out.editValue == "0") {
          //   return false;
          // }
          // add FutreNetWeb+SI課題管理No6124 趙 end
          if(val2) {
            // mod 6625【ST試験】【S12_患者の既往・転入履歴】患者情報：患者状態が変更された場合、ページ頭部状態は変更されない zhou　start
            //if (length != 0 && this.jsonArray[0].in_out.editValue == "0") {
            if (length != 0 && this.jsonArray[0].in_out.initValue == 0) {
              // mod 6625【ST試験】【S12_患者の既往・転入履歴】患者情報：患者状態が変更された場合、ページ頭部状態は変更されない zhou　end
              return false;
            } else {
              for(var i = 0; i <= length - 1; i++){
                if(this.jsonArray[i].period_start_date.editValue < date){
                  length1 = length1 + 1;
                }
              }
              // mod #8302 by liuzhibo start
              //if (length != 0 && this.jsonArray[length - length1].in_out.editValue == "0") {
              // mod 6625【ST試験】【S12_患者の既往・転入履歴】患者情報：患者状態が変更された場合、ページ頭部状態は変更されない zhou　start
              //if (length >= length1 && this.jsonArray[length - length1].in_out.editValue == "0") {
              if (length >= length1 && this.jsonArray[length - length1].in_out.initValue == 0) {
                // mod 6625【ST試験】【S12_患者の既往・転入履歴】患者情報：患者状態が変更された場合、ページ頭部状態は変更されない zhou　end
              // mod #8302 by liuzhibo end
                return false;
              }
            }
          }
          // mod FutreNetWeb+SI課題管理No6016 趙 start
          await this.addItem();
          this.jsonArray[length].move_in_out.editValue = "6";
          this.jsonArray[length].period_start_date.editValue = date;
          this.jsonArray[length].in_out.editValue = 0;
        } else {
          // 不明とnullの時、操作しない
          return false;
        }
      },
      // add No.15 じょはく end
      // add FNSI-入外区分の入力方法を2種類(簡易/詳細)用意し、簡易入力 徐博 start

      /**
       * @description 自施設を返す
       * @param {Object} json
       * @returns {String}
       */
      getFacilityData(json) {
        return this.getPatDataJsonArray(json, "from_facility").editValue;
      },

      /**
       * @description 区画に対してBooleanを返す
       * @summary 入外項目を非活性・導入、転入のみ活性
       * @param {Object} json
       * @returns {Boolean}
       */
      isIntroductionTracnsfer(json) {
        if (
          !this.isMoveInOutValue(json) &&
          (this.isMoveInOutIntroduction(json) || this.isMoveInOutMoveIn(json))
        ) {
          return false;
        }
        return true;
      },

      /**
       * @description 区画に対してBooleanを返す
       * @summary 施設、診療科、担当医の'入院'、'退院'・'外来'は非表示へ
       * @param {Object} json
       * @returns {Boolean}
       */
      isMoveInOutToFacilityCourseDoctor(json) {
        if (
          this.isMoveInOutHospitalization(json) ||
          this.isMoveInOutDischarge(json) ||
          this.isMoveInOutOutPatient(json)
        ) {
          return false;
        }
        return true;
      },

      /**
       * @description データを保持し選択肢表示関数を呼ぶ
       * @param {Object} json
       * @param {Object} popoverData
       */
      selectPopoverData(type, json, popoverData, index) {
        // 選択ボタンを押した位置の項目を保持
        this.selectedJson = json;
        this.selectedIndex = index;
        if (type === "doctor") {
          // mod 11872 利用者指定IFのデフォルト選択状態 zrx start  新規患者登録-入外転入出-医師
          const key = this.getDoctorJsonKey(json);
          // popoverData.popoverContentSelected.value = json[`${key}`].editValue;
          popoverData.popoverContentSelected.value = json[`${key}`].editValue ? json[`${key}`].editValue : this.getStateUserAccountInfo.userId;
          
          // mod 11872 利用者指定IFのデフォルト選択状態 liyanze-z add  ログインID  補充する start 
          let isUsedUserInfoID = false;
          isUsedUserInfoID = json[`${key}`].editValue?false:true
          popoverData.isUsedUserInfoID = isUsedUserInfoID;
          // mod 11872 利用者指定IFのデフォルト選択状態 liyanze-z add  ログインID  補充する end 
          
          // mod 11872 利用者指定IFのデフォルト選択状態 zrx start  新規患者登録-既往歴-診断医
        } else if (type === "course") {
          const key = this.getCourseJsonKey(json);
          popoverData.popoverContentSelected.value = json[`${key}`].editValue;
        }

        // ポップオーバーを表示
        this.showPopover(popoverData);
      },

      /**
       * @description ポップオーバー確定イベントハンドラ
       * @param {Object} selectedMst
       */
      setPopoverDataFacility(selectedMst) {
        if (
          this.isMoveInOutIntroduction(this.selectedJson) &&
          !this.isIntroductionUnique(selectedMst.medicalInstitutionCd)
        ) {
          // 導入の施設が重複していたら登録させない
          this.isDialogVisible = true;
          return;
        }
        // 選択ボタンを押した項目に選択値を設定
        this.setPopoverData(
          selectedMst,
          this.getFacilityJsonKey(this.selectedJson)
        );
        if (this.isToData(this.selectedJson)) {
          this.setPatDataJsonArray(
            this.selectedJson,
            "to_medicalInstitutionCd",
            selectedMst.medicalInstitutionCd ? selectedMst.medicalInstitutionCd : null
          );
          this.setPatDataJsonArray(
            this.selectedJson,
            "from_medicalInstitutionCd",
            null
          );
        } else {
          this.setPatDataJsonArray(
            this.selectedJson,
            "from_medicalInstitutionCd",
            selectedMst.medicalInstitutionCd ? selectedMst.medicalInstitutionCd : null
          );
          this.setPatDataJsonArray(
            this.selectedJson,
            "to_medicalInstitutionCd",
            null
          );
        }
        this.setPatDataJsonArray(this.selectedJson, "facility_is_free", "0");
        this.selectedJson = null;
      },

      /**
       * @description ポップオーバー確定イベントハンドラ
       * @param {Object} selectedMst
       */
      setPopoverDataCourse(selectedMst) {
        // 選択ボタンを押した項目に選択値を設定
        this.setPopoverData(
          selectedMst,
          this.getCourseJsonKey(this.selectedJson)
        );
        this.setPatDataJsonArray(this.selectedJson, "course_is_free", "0");
        this.selectedJson = null;
      },

      /**
       * @description ポップオーバー確定イベントハンドラ
       * @param {Object} selectedMst
       */
      setPopoverDataDoctor(selectedMst) {
        // 選択ボタンを押した項目に選択値を設定
        this.setPopoverData(
          selectedMst,
          this.getDoctorJsonKey(this.selectedJson)
        );
        this.setPatDataJsonArray(this.selectedJson, "doctor_is_free", "0");
        this.selectedJson = null;
      },

      /**
       * @description 選択された値と自施設、透析実施科、主治医の値をセット
       * @param {Object} selectedMst
       * @param {String} jsonKey
       * @param {String} ownData
       */
      setPopoverData(selectedMst, jsonKey) {
        /* add by chamaojia 2025-05-21 [11871]  --start */
        // iPhoneアクセスプログラム、画面メモリオーバーフロー改造
        // バウンディングボックスで選択したデータは、エコー用の配列に格納されます。
        let obj = {
          cd:selectedMst.value,
          name:selectedMst.text
        };
        this.facilityNameList.push(obj);
        /* add by chamaojia 2025-05-21 [11871]  --end */
        if (
          this.isMoveInOutMovingOut(this.selectedJson) ||
          this.isMoveInOutTemporarilyMovingOut(this.selectedJson)
        ) {
          // 転出、一時転出は先担当医に選択コードセット、元担当医に自施設コードセット
          this.setPatDataJsonArray(this.selectedJson, jsonKey, selectedMst.value);
        } else {
          // それ以外の区分は元担当医に選択コードセット
          this.setPatDataJsonArray(this.selectedJson, jsonKey, selectedMst.value);
        }
      },

      /**
       * @description 担当医コードを名字と名前に変換する
       * @param {Object} json
       * @param {String} jsonKey
       * @returns {String}
       */
      doctorName(json, jsonKey) {
        const doctor = this.getPatDataJsonArray(json, jsonKey).editValue;
        if (!doctor || !this.mstUser) return "";
        const lastName = this.mstCdToNameFreeWord(
          this.mstUser,
          doctor,
          "user_id",
          "user_last_name"
        );
        const firstName = this.mstCdToNameFreeWord(
          this.mstUser,
          doctor,
          "user_id",
          "user_first_name"
        );
        if (!lastName || !firstName) {
          this.setPatDataJsonArray(json, "doctor_is_free", "1");
          return `${doctor}`;
        }
        return `${lastName} ${firstName}`;
      },

      isMoveInOutValue(json) {
        return this.getJsonArrayCtlNo(json) > 0;
      },

      /**
       * @description 取得した日付を任意の表示に変更
       * @param {String} value
       * @returns {String}
       */
      // TODO: 一時的に保留:保存時バリデーション精査中
      changeDate(value) {
        if (value === null) {
          return null;
        }
        if (value.length === 8) {
          return moment(value, "YYYYMMDD").format("YYYY/MM/DD");
        } else if (value.length === 6) {
          return moment(value, "YYYYMMDD").format("YYYY/MM");
        } else if (value.length === 4) {
          return moment(value, "YYYYMMDD").format("YYYY");
        }
      },

      // マスタ選択ポップオーバーの表示位置とする対象コンポーネント
      popoverTargetElement(btnSelect) {
        // 初期表示時は未選択なのでnull
        return this.selectedIndex === null
          ? null
          : this.$refs[`${btnSelect}${this.selectedIndex}`][0];
      },

      // 項目追加処理
      /**
       * @description 配列に新たな要素を追加
       */
      addItem() {
        // 新規項目作成
        const newItem = {
          ctl_no: 0,
          facility_cd: this.getFacilityCd,
          disp_order: 0,
          move_in_out: null,
          period_start: null,
          period_start_year: null,
          period_start_month: null,
          period_start_day: null,
          period_start_input_free: "0",
          period_end: null,
          period_end_year: null,
          period_end_month: null,
          period_end_day: null,
          period_end_input_free: "0",
          //add FNSI-施設選択の箇所を対応する 江 start
          to_medicalInstitutionCd: null,
          from_medicalInstitutionCd: null,
          //add FNSI-施設選択の箇所を対応する 江 end
          to_facility: null,
          from_facility: null,
          to_course: null,
          from_course: null,
          to_doctor: null,
          from_doctor: null,
          in_out: null,
          reason: null,
          course_is_free: "0",
          doctor_is_free: "0",
          facility_is_free: "0",
        };
        this.pushJsonArray(this.arrayColName, newItem);
      },

      // 項目追加処理
      /**
       * @description 保存後に配列に死亡要素追加
       */
      async addDeathItem(deathDate, deathFacility, deathCourse, deathDoctor) {
        const jsonArrayToMoveInOutClassDeath = this.jsonArray.find(
          (json) => json.move_in_out.editValue === MOVE_IN_OUT_CLASS_DEATH
        );
        if (jsonArrayToMoveInOutClassDeath === undefined) {
          // 新規項目作成
          const newItem = {
            ctl_no: 0,
            facility_cd: this.getFacilityCd,
            disp_order: 0,
            move_in_out: MOVE_IN_OUT_CLASS_DEATH,
            period_start: deathDate,
            period_start_year: deathDate ? deathDate.substring(0, 4) : null,
            period_start_month: deathDate ? deathDate.substring(4, 6) : null,
            period_start_day: deathDate ? deathDate.substring(6, 8) : null,
            period_start_input_free: "0",
            period_end: null,
            period_end_year: null,
            period_end_month: null,
            period_end_day: null,
            period_end_input_free: "0",
            to_facility: null,
            from_facility: deathFacility,
            to_course: null,
            from_course: deathCourse,
            to_doctor: null,
            from_doctor: deathDoctor,
            in_out: IN_OUT_CLASS_DEATH,
            reason: null,
            course_is_free: "0",
            doctor_is_free: "0",
            facility_is_free: "0",
          };

          this.pushJsonArray(this.arrayColName, newItem);

          // // 保存後、医師を表示するためにマストユーザーを取得
          // const facility_cd = deathFacility;
          // if (facility_cd !== null) {
          //   const responseUser = await ApiHelper.get(`/mstInfo/mstPersonalUser`, {
          //     facility_cd,
          //   }).catch((error) => {
          //     //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          //     getErrorMessage("VisitHstCardContent.vue", "addDeathItem", error);
          //     //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          //     throw error;
          //     //console.log(`API:"${apiUser}"の実行に失敗しました。`);
          //     //console.log(error);
          //   });

          //   // 取得したユーザーを表示ようにマスタへ格納
          //   const isFacilityCd = this.mstUser.find((item) => {
          //     return item.facilityCd === facility_cd;
          //   });
          //   if (isFacilityCd === undefined) {
          //     this.mstUser.push(...responseUser.data);
          //   }
          // }
        }
      },

      /**
       * @description 死亡データを削除
       * @summary 既往歴の死亡を削除すると発火
       * @param { Array } 削除する死亡リスト
       */
      deleteDeathItem(deleteJson) {
        if (
          this.jsonArray.find(
            (json) => json.move_in_out.editValue === MOVE_IN_OUT_CLASS_DEATH
          )
        ) {
          const period_start = deleteJson.period_start.initValue;
          const from_facility = deleteJson.diagnosis_facility_cd.initValue;
          const from_course = deleteJson.course_cd.initValue;
          const from_doctor = deleteJson.diagnostician_cd.initValue;
          const removedDeleteJsonArray = this.jsonArray.filter(
            (json) =>
              json.period_start.initValue !== period_start ||
              json.from_facility.initValue !== from_facility ||
              json.from_course.initValue !== from_course ||
              json.from_doctor.initValue !== from_doctor
          );
          this.jsonArray = removedDeleteJsonArray;
        }
      },

      // ※保存時、転入出に自施設を入力
      setFacilityOwnData() {
        for (const json of this.jsonArray) {
          if (
            this.isMoveInOutMovingOut(json) ||
            this.isMoveInOutTemporarilyMovingOut(json)
          ) {
            this.setPatDataJsonArray(json, "from_facility", this.ownFacility);
          } else if (this.isMoveInOutMoveIn(json)) {
            this.setPatDataJsonArray(json, "to_facility", this.ownFacility);
          }
        }
      },

      // ※保存時、転入出に透析実施科を入力
      setCourseOwnData(CourseOwnData) {
        for (const json of this.jsonArray) {
          if (
            this.isMoveInOutMovingOut(json) ||
            this.isMoveInOutTemporarilyMovingOut(json)
          ) {
            this.setPatDataJsonArray(json, "from_course", CourseOwnData);
          } else if (this.isMoveInOutMoveIn(json)) {
            this.setPatDataJsonArray(json, "to_course", CourseOwnData);
          }
        }
      },

      // ※保存時、転入出に主治医を入力
      setDoctorOwnData(DoctorOwnData) {
        for (const json of this.jsonArray) {
          if (
            this.isMoveInOutMovingOut(json) ||
            this.isMoveInOutTemporarilyMovingOut(json)
          ) {
            this.setPatDataJsonArray(json, "from_doctor", DoctorOwnData);
          } else if (this.isMoveInOutMoveIn(json)) {
            this.setPatDataJsonArray(json, "to_doctor", DoctorOwnData);
          }
        }
      },

      // 転出日を返す
      getMoveOutDate() {
        let periodStart = "";
        let moveOutDate = moment(new Date());
        let moveOutDateCmp = moment(new Date(9999, 12, 31));
        let moveOutFlg = false;
        // 項目名称を返す
        let rtnParamName = "";
        for (const json of this.jsonArray) {
          // 項目名称を設定
          let tmpParamName = "";
          let targetItem = false;
          if (this.isMoveInOutMovingOut(json)) {
            targetItem = true;
            tmpParamName = "転出日";
          } else if (this.isMoveInOutWithdrawal(json)) {
            targetItem = true;
            tmpParamName = "離脱日";
          } else if (this.isMoveInOutImplantatlon(json)) {
            targetItem = true;
            tmpParamName = "移植日";
          } else if (this.isMoveInOutClassRejectionUnknown(json)) {
            targetItem = true;
            tmpParamName = "通院拒否・不明";
            // add #IES_6772 zs start
          } else if (this.isMoveInOutTemporarilyMovingOut(json)) {
            targetItem = true;
            tmpParamName = "一時転出";
            // add #IES_6772 zs end
          }
          // 転出/離脱/移植/通院拒否・不明が選択且つ、削除対象ではない且つ、日付の項目(編集値)がnullでないこと
          if (
            targetItem &&
            !this.isDeletedJsonArrayItem(json) &&
            this.getPatDataJsonArray(json, "period_start").editValue !== null
          ) {
            moveOutFlg = true;
            if (
              this.getPatDataJsonArray(json, "period_start_year").editValue &&
              this.getPatDataJsonArray(json, "period_start_month").editValue &&
              this.getPatDataJsonArray(json, "period_start_day").editValue
            ) {
              // 開始日が年月日すべて入力されている場合
              periodStart = this.getPatDataJsonArray(
                json,
                "period_start"
              ).editValue;
              moveOutDate = moment(
                new Date(
                  periodStart.slice(0, 4),
                  periodStart.slice(4, 6) - 1,
                  periodStart.slice(6)
                )
              );
            } else {
              // 開始日の年/月/日いずれかが未入力の場合→当日日付を起点とする
              moveOutDate = moment(new Date());
            }
            // 最小の日付を設定する
            if (moment(moveOutDate).isBefore(moveOutDateCmp)) {
              moveOutDateCmp = moveOutDate;
              // 項目名称を設定
              rtnParamName = tmpParamName;
            }
          }
        }
        if (moveOutFlg) {
          return {
            date: moveOutDateCmp,
            paramName: rtnParamName
          }
        } else {
          // 転出が選択されていない場合はnullを返す
          return null;
        }
      },

      // 入外区分から透析困難情報リセット有無を取得する
      getIsCheckResetDifficulty() {
        let resetFlg = false;
        let deleteFlg = false;
        const today = moment(new Date());
        let initDate = moment(new Date());
        let editDate = moment(new Date());
        let initCmpDate = moment(new Date(1900, 1, 1));
        let editCmpDate = moment(new Date(1900, 1, 1));
        let initInOut = null;
        let editInOut = null;

        // 有効な入外区分を設定する
        for (const json of this.jsonArray) {
          const initPeriodStart = this.getPatDataJsonArray(
            json,
            "period_start"
          ).initValue;
          const editPeriodStart = this.getPatDataJsonArray(
            json,
            "period_start"
          ).editValue;
          if (initPeriodStart !== null) {
            initDate = moment(
              new Date(
                initPeriodStart.slice(0, 4),
                initPeriodStart.slice(4, 6) - 1,
                initPeriodStart.slice(6)
              )
            );
            if (
              !moment(today).isBefore(initDate) &&
              !moment(initCmpDate).isAfter(initDate)
            ) {
              initCmpDate = initDate;
              initInOut = this.getPatDataJsonArray(json, "in_out").initValue;
              deleteFlg = this.isMoveInOutValueDelete(json);
            }
          }
          if (editPeriodStart !== null && !this.isMoveInOutValueDelete(json)) {
            editDate = moment(
              new Date(
                editPeriodStart.slice(0, 4),
                editPeriodStart.slice(4, 6) - 1,
                editPeriodStart.slice(6)
              )
            );
            if (
              !moment(today).isBefore(editDate) &&
              !moment(editCmpDate).isAfter(editDate)
            ) {
              editCmpDate = editDate;
              editInOut = this.getPatDataJsonArray(json, "in_out").editValue;
            }
          }
        }
        if (
          initInOut === IN_OUT_CLASS_HOSPITALIZATION &&
          editInOut === IN_OUT_CLASS_OUTPATIENT
        ) {
          // 区分が「入院」から「外来」に変わった場合
          resetFlg = true;
        } else if (
          initInOut === IN_OUT_CLASS_HOSPITALIZATION &&
          editInOut !== IN_OUT_CLASS_HOSPITALIZATION &&
          deleteFlg
        ) {
          // 区分が「入院」のデータが削除された場合
          resetFlg = true;
        }
        return resetFlg;
      },

      setOldestDialysis() {
        // 最古の導入日を保持する
        const introductions = this.jsonArray.filter(
          (el) =>
            this.isMoveInOutIntroduction(el) && !this.isDeletedJsonArrayItem(el)
        );
        if (!introductions.length) {
          this.oldestDialysis.facilityCd = null;
          this.oldestDialysis.date = null;
          return;
        }
        const sortedDialysis = introductions
          .map((el) => {
            return {
              facilityCd: el.from_facility.editValue,
              date: el.period_start.editValue,
            };
          })
          .sort((a, b) => {
            // nullは後ろへ
            if (!a.date) return 1;
            if (!b.date) return -1;
            if (a.date < b.date) return -1;
            if (a.date > b.date) return 1;
            return 0;
          });
        // 昇順ソートの1つ目が最古
        this.oldestDialysis.facilityCd = sortedDialysis[0].facilityCd;
        this.oldestDialysis.date = sortedDialysis[0].date;
      },

      /**
       * @description 区分「導入」が1施設につき1つとなっているか判定
       * @param {Object} selectedMedicalInstitutionCd
       * @return チェック処理結果(true:正常終了、false:エラー)
       * @summary 施設の変更時に使用 ※区分変更時は施設がリセットされるので判定は不要
       */
      isIntroductionUnique(selectedMedicalInstitutionCd) {
        let checkResult = true;
        //施設で未登録が選択されている場合、チェック処理をスキップする
        if(!selectedMedicalInstitutionCd){
          return checkResult;
        }
        const introductions = this.jsonArray.filter(
          (el) =>
            this.isMoveInOutIntroduction(el) && !this.isDeletedJsonArrayItem(el)
        );
        // 施設コードの重複を調べる
        const facilities = introductions.map((el) => el.from_facility.editValue);
        // 選択された施設が既に別の区分「導入」のデータで選択されている施設の場合、入力チェックエラーが発生する
        checkResult = !facilities.some(item => item === selectedMedicalInstitutionCd);
        return checkResult;
      },

      getMedicalHstDate(value) {
        const date = {
          year: null,
          month: null,
          day: null,
        };
        if (value === null) {
          return null;
        }

        if (value.length === 8) {
          date.year = moment(value, "YYYYMMDD").format("YYYY");
          date.month = moment(value, "YYYYMMDD").format("MM");
          date.day = moment(value, "YYYYMMDD").format("DD");
        } else if (value.length === 6) {
          date.year = moment(value, "YYYYMMDD").format("YYYY");
          date.month = moment(value, "YYYYMMDD").format("MM");
        } else if (value.length === 4) {
          date.year = moment(value, "YYYYMMDD").format("YYYY");
        }
        return date;
      },

      /**
       * @description 削除した死亡データ(json)
       * @summary 保存時に呼び出す
       * @returns { Object }
       */
      deathItem() {
        // 編集前の死亡jsonを取得
        const deleteJson = this.jsonArray.find(
          (json) => json.move_in_out.initValue === MOVE_IN_OUT_CLASS_DEATH
        );
        if (deleteJson === undefined) {
          // 編集前に死亡がない場合
          return undefined;
        }

        // 削除した死亡jsonを返す
        if (
          // ctl_noが負数なら削除
          deleteJson.ctl_no.editValue < 0
        ) {
          // 編集後に死亡を削除した場合
          const date = deleteJson.period_start.editValue;
          deleteJson.die_date = {
            // mod FutreNetWeb+SI課題管理No6117 趙 start
            // initValue: date.year,
            // editValue: date.year,
            initValue: date,
            editValue: date,
            // mod FutreNetWeb+SI課題管理No6117 趙 end
          };
          return deleteJson;
        }

        return undefined;
      },

      /**
       * @description 診療科を変換する
       * @param {Object} json
       * @returns {String}
       */
      dispCourseName(json) {
        const courseCd = this.getPatDataJsonArray(
          json,
          this.getCourseJsonKey(json)
        ).editValue;
        if (!courseCd || !this.mstCourse) return "";
        const courseName = this.mstCdToNameFreeWord(
          this.mstCourse,
          courseCd,
          "courseCd",
          "courseName"
        );
        if (!courseName) {
          this.setPatDataJsonArray(json, "course_is_free", "1");
          return `${courseCd}`;
        }
        return `${courseName}`;
      },

      /**
       * @description 施設を変換する
       * @param {Object} json
       * @returns {String}
       */
      dispFacilityName(json) {
        const inputFacilityCd = this.getPatDataJsonArray(
          json,
          this.getFacilityJsonKey(json)
        ).editValue;

        if (!inputFacilityCd) {
          this.setPatDataJsonArray(json, "facility_is_free", "0");
          return "";
        }

        //全施設マスタのデータが取得できなかった場合
        if(this.facilityNameList.length === 0){
          this.setPatDataJsonArray(json, "facility_is_free", "1");
          if(this.getFacilityJsonKey(json) === "from_facility"){
            this.setPatDataJsonArray(json, "from_medicalInstitutionCd", null);
          } else {
            this.setPatDataJsonArray(json, "to_medicalInstitutionCd", null);
          }
          return `${inputFacilityCd}`;
        }

        let inputFacilityName = "";
        const facilityName = this.facilityNameList.find(item => item.cd == inputFacilityCd);
        inputFacilityName = facilityName?.name;
        
        if (inputFacilityName) {
          this.setPatDataJsonArray(json, "facility_is_free", "0");
          if(this.getFacilityJsonKey(json) === "from_facility"){
            this.setPatDataJsonArray(json, "from_medicalInstitutionCd", inputFacilityCd);
          } else {
            this.setPatDataJsonArray(json, "to_medicalInstitutionCd", inputFacilityCd);
          }
          return `${inputFacilityName}`;
        }else{
          this.setPatDataJsonArray(json, "facility_is_free", "1");
          if(this.getFacilityJsonKey(json) === "from_facility"){
            this.setPatDataJsonArray(json, "from_medicalInstitutionCd", null);
          } else {
            this.setPatDataJsonArray(json, "to_medicalInstitutionCd", null);
          }
          return `${inputFacilityCd}`;
        }

      },

      /**
       * @description 年・月・日の入力エリアから開始日/終了日カラムを組み立てる
       * @param {Object} json
       * @param {String} key
       */
      addNumber(json, key) {
        const value = this.getPatDataJsonArray(json, key).editValue;
        if (value !== null) {
          if (key === "period_start_year" || key === "period_end_year") {
            // 年が編集された場合、数値以外はnullにする
            if (isFinite(value)) {
              const year = value.padStart(4, 0);
              this.setPatDataJsonArray(json, key, year);
            } else {
              this.setPatDataJsonArray(json, key, null);
            }
          } else if (key === "period_start_month" || key === "period_end_month") {
            // 月が編集された場合、12を超える数値は12にする、数値以外はnullにする
            if (isFinite(value) && Number(value) <= 12 && Number(value) >= 1) {
              const month = value.padStart(2, 0);
              this.setPatDataJsonArray(json, key, month);
            } else if (isFinite(value) && Number(value) > 12) {
              this.setPatDataJsonArray(json, key, "12");
            } else {
              this.setPatDataJsonArray(json, key, null);
            }
          } else if (key === "period_start_day" || key === "period_end_day") {
            // 日が編集された場合、数値以外はnullにする
            if (isFinite(value)) {
              const day = value.padStart(2, 0);
              this.setPatDataJsonArray(json, key, day);
            } else {
              this.setPatDataJsonArray(json, key, null);
            }
          }

          // 入力された年月日が正当な日付であるかチェックする
          let setDayKey = "";
          let keyYear = "";
          let keyMonth = "";
          let keyDay = "";
          if (key.match(/period_start/)) {
            setDayKey = "period_start_day";
            keyYear = this.getPatDataJsonArray(
              json,
              "period_start_year"
            ).editValue;
            keyMonth = this.getPatDataJsonArray(
              json,
              "period_start_month"
            ).editValue;
            keyDay = this.getPatDataJsonArray(json, "period_start_day").editValue;
          } else if (key.match(/period_end/)) {
            setDayKey = "period_end_day";
            keyYear = this.getPatDataJsonArray(json, "period_end_year").editValue;
            keyMonth = this.getPatDataJsonArray(
              json,
              "period_end_month"
            ).editValue;
            keyDay = this.getPatDataJsonArray(json, "period_end_day").editValue;
          }
          const maxDay = getMaxDay(keyYear, keyMonth);
          this.setCheckedheDay(maxDay, json, setDayKey, keyDay);

          if (
            key === "period_start_year" ||
            key === "period_start_month" ||
            key === "period_start_day"
          ) {
            // 開始日が変更された場合period_startを更新
            const year = this.getPatDataJsonArray(
              json,
              "period_start_year"
            ).editValue;
            const month = this.getPatDataJsonArray(
              json,
              "period_start_month"
            ).editValue;
            const day = this.getPatDataJsonArray(
              json,
              "period_start_day"
            ).editValue;

            if (year && month && day) {
              const startDate = moment(`${year}${month}${day}`);
              // 入力された日付が正しい日付の場合のみセット
              if (startDate.isValid()) {
                this.setPatDataJsonArray(
                  json,
                  "period_start",
                  startDate.format("YYYYMMDD")
                );
                this.setPatDataJsonArray(
                  json,
                  "period_start_date",
                  startDate.format("YYYYMMDD")
                );
                return;
              } else {
                this.setPatDataJsonArray(json, "period_start_date", null);
              }
            } else {
              this.setPatDataJsonArray(json, "period_start_date", null);
            }
          } else if (
            key === "period_end_year" ||
            key === "period_end_month" ||
            key === "period_end_day"
          ) {
            // 終了日が変更された場合period_endを更新
            const year = this.getPatDataJsonArray(
              json,
              "period_end_year"
            ).editValue;
            const month = this.getPatDataJsonArray(
              json,
              "period_end_month"
            ).editValue;
            const day = this.getPatDataJsonArray(
              json,
              "period_end_day"
            ).editValue;

            if (year && month && day) {
              const endDate = moment(`${year}${month}${day}`);
              // 入力された日付が正しい日付の場合のみセット
              if (endDate.isValid()) {
                this.setPatDataJsonArray(
                  json,
                  "period_end",
                  endDate.format("YYYYMMDD")
                );
                this.setPatDataJsonArray(
                  json,
                  "period_end_date",
                  endDate.format("YYYYMMDD")
                );
                return;
              } else {
                this.setPatDataJsonArray(json, "period_end_date", null);
              }
            } else {
              this.setPatDataJsonArray(json, "period_end_date", null);
            }
          }
        } else {
          // 入力年/月/日いずれかが空欄の場合は不正な日付としてdate項目をnullにする
          if (
            key === "period_start_year" ||
            key === "period_start_month" ||
            key === "period_start_day"
          ) {
            // 開始日
            this.setPatDataJsonArray(json, "period_start_date", null);
          } else if (
            key === "period_end_year" ||
            key === "period_end_month" ||
            key === "period_end_day"
          ) {
            // 終了日
            this.setPatDataJsonArray(json, "period_end_date", null);
          }
        }

        // 入外区分/在院状態更新用日付の更新処理呼び出し
        if (
          key === "period_start_year" ||
          key === "period_start_month" ||
          key === "period_start_day"
        ) {
          // 開始日
          this.setPeriod(json, "period_start");
        } else if (
          key === "period_end_year" ||
          key === "period_end_month" ||
          key === "period_end_day"
        ) {
          // 終了日
          this.setPeriod(json, "period_end");
        }
      },

      /**
       * @description 年月日が正当な日付かチェックする
       * @param {String} maxDay 月の最終日
       * @param {Object} json
       * @param {String} key
       * @param {String} value
       */
      setCheckedheDay(maxDay, json, key, value) {
        if (isFinite(value) && Number(value) <= maxDay && Number(value) >= 1) {
          // 正当な日付の場合、日をセットする
          const day = value.padStart(2, 0);
          this.setPatDataJsonArray(json, key, day);
        } else if (isFinite(value) && Number(value) > maxDay) {
          // 年月の最終日を超える場合、最終日をセットする
          this.setPatDataJsonArray(json, key, String(maxDay).padStart(2, 0));
        } else {
          // 正当な日付ではない場合、nullをセットする
          this.setPatDataJsonArray(json, key, null);
        }
      },

      /**
       * @description 転入出履歴の開始日/終了日を設定する
       * @param {Object} json
       * @param {String} key (period_start または period_end)
       */
      setPeriod(json, key) {
        let year = this.getPatDataJsonArray(json, key + "_year").editValue;
        let month = this.getPatDataJsonArray(json, key + "_month").editValue;
        let day = this.getPatDataJsonArray(json, key + "_day").editValue;

        if (!year && !month && !day) {
          // 年月日が全て空欄の場合はnull
          this.setPatDataJsonArray(json, key, null);
        } else {
          if (!year) {
            // 年が空欄→今年
            year = String(moment().year());
          }
          if (!month) {
            // 月が空欄→1月扱い
            month = "01";
          }
          if (!day) {
            // 日が空欄→1日扱い
            day = "01";
          }

          const periodDate = moment(`${year}${month}${day}`);
          if (periodDate.isValid()) {
            // key項目に日付をセット
            this.setPatDataJsonArray(json, key, periodDate.format("YYYYMMDD"));
          } else {
            // 日付として不正の場合はnull更新
            this.setPatDataJsonArray(json, key, null);
          }
        }
      },

      /**
       * @description 開始日/終了日のカレンダーを選択したときに呼び出される処理
       * @param {String} value
       * @param {Object} params
       */
      setDateEach(value, params) {
        if (params.fromData && params.fromData === "period_start_date") {
          const startDate = moment(value);
          // 入力された日付が正しい日付の場合のみセット
          if (startDate.isValid() && params.json) {
            this.setPatDataJsonArray(
              params.json,
              "period_start",
              startDate.format("YYYYMMDD")
            );
            this.setPatDataJsonArray(
              params.json,
              "period_start_year",
              startDate.format("YYYY")
            );
            this.setPatDataJsonArray(
              params.json,
              "period_start_month",
              startDate.format("MM")
            );
            this.setPatDataJsonArray(
              params.json,
              "period_start_day",
              startDate.format("DD")
            );
          } else {
            this.setPatDataJsonArray(
              params.json,
              "period_start",
              null
            );
            this.setPatDataJsonArray(
              params.json,
              "period_start_year",
              null
            );
            this.setPatDataJsonArray(
              params.json,
              "period_start_month",
              null
            );
            this.setPatDataJsonArray(
              params.json,
              "period_start_day",
              null
            );
          }
        } else if (params.fromData && params.fromData === "period_end_date") {
          const endDate = moment(value);
          // 入力された日付が正しい日付の場合のみセット
          if (endDate.isValid() && params.json) {
            this.setPatDataJsonArray(
              params.json,
              "period_end",
              endDate.format("YYYYMMDD")
            );
            this.setPatDataJsonArray(
              params.json,
              "period_end_year",
              endDate.format("YYYY")
            );
            this.setPatDataJsonArray(
              params.json,
              "period_end_month",
              endDate.format("MM")
            );
            this.setPatDataJsonArray(
              params.json,
              "period_end_day",
              endDate.format("DD")
            );
          } else {
            this.setPatDataJsonArray(
              params.json,
              "period_end",
              null
            );
            this.setPatDataJsonArray(
              params.json,
              "period_end_year",
              null
            );
            this.setPatDataJsonArray(
              params.json,
              "period_end_month",
              null
            );
            this.setPatDataJsonArray(
              params.json,
              "period_end_day",
              null
            );
          }
        }
      },
      setContentData(e, index) {
        this.setPatDataJsonArray(this.jsonArray[index], "reason", e);
      },
      /**
       * 入外・転入出カードの施設CDをキーに全施設マスタから施設情報を取得し、施設CD・施設名リストを作成します。
       * ※this.facilityNameListの初期化が必要な場合は、呼出側で行うこと。
       * ※#11871のout of memory対策により、入外・転入出カードの施設CD分しか保持しない。
       */
      async loadFacilityNameList() {
        let cdList = [];
        this.editRecord[this.arrayColName].forEach((info) => {
          const cd = this.getPatDataJsonArray(info, this.getFacilityJsonKey(info)).editValue;
          if (cd) cdList.push(cd);
        });

        if (cdList.length === 0) {
        // 施設CDが取得できない場合、何もせず早期return
          return;
        }

        // 施設CDをキーに全施設マスタから施設情報取得
        const rest = await ApiHelper.post("/sysFacility/getSysFacilityByCdList", cdList);
        for (let i = 0; i < rest.data.length; i++) {
          this.facilityNameList.push({
            cd: rest.data[i].medicalInstitutionCd,
            name: rest.data[i].facilityName
          });
        }
      },
    // add #12462 患者情報共有 Ji start
    /**
     * @description 該当行が他院情報かどうかを判定
     * @param {Object} json - 患者情報
     * @returns {Boolean} true = 他施設のデータは参照のみ
     */
      isOtherFacilityRow(json) {return (json.facility_cd?.initValue !== this.getFacilityCd || this.getIsOtherFacility);
      },
    /**
     *
     * @param json - 患者情報
     * @param displayFunc - 変換Function
     */
      getNameDisplay(json, displayFunc, nameKey) {
        if (json.facility_cd?.initValue !== this.getFacilityCd) {
          const nameObj = this.getPatDataJsonArray(json, nameKey);
          return nameObj.editValue;
        }
        return displayFunc(json);
      },

      getDoctorDisplay(json) {
        return this.doctorName(
          json,
          this.getDoctorJsonKey(json),
          this.getPatDataJsonArray(json, this.getFacilityJsonKey(json)).editValue
        );
      }
     // add #12462 患者情報共有 Ji end
    },
  };
</script>

<!-- カード共通スタイル読み込み -->
<style src="../base-components/BaseCardStyle.css" scoped></style>
<style scoped>
  /* カード個別のスタイルはここ */

  .custom-select,
  .death-date {
    width: auto;
  }

  .death-date >>> .custom-input-date {
    width: auto;
  }

  .item-data-period {
    width: 70%;
  }
  .period-date {
    width: 4em;
  }
  .icon-margin {
    margin-left: 2px;
    font-size: 1em;
  }
  .span-flex {
    display: inline-flex;
  }
  .card-table >>> textarea.custom-textarea {
    color: black !important;
  }
  /* ntss.css の .custom-textarea:disabled と競合する為、個別定義 */
  td .custom-textarea-edited {
    border: 2px green solid;
  }
</style>
