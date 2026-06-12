/**
 * 治療状況マップ用ヘッダ
 */
<template>
  <div class="header-item">
    <v-ons-row class="mark-leftmost-header">
      <v-ons-col vertical-align="center" width="50%">
        <div id="changebtn">
          <input
            type="radio"
            class="identification"
            name="identification"
            value="1"
            id="input-bed-name"
            @change="changeTreatStateMode(true)"
            :checked="treatStateModeUi"
          />
          <!-- mod FNSI-redmine#3965 付 start -->
          <!-- <label for="input-bed-name" class="label first-of-type">治療状況</label> -->
          <label for="input-bed-name" class="label first-of-type" :class="startGaMenWidth < 500? 'phone-type' : ''">治療状況</label>
          <!-- mod FNSI-redmine#3965 付 end -->
          <input
            type="radio"
            class="identification"
            name="identification"
            value="2"
            id="input-machine-name"
            @change="changeTreatStateMode(false)"
            :checked="!treatStateModeUi"
          />
          <!-- mod FNSI-redmine#3965 付 start -->
          <!-- <label for="input-machine-name" class="label last-of-type">スケジュール</label> -->
          <label for="input-machine-name" class="label last-of-type" :class="startGaMenWidth < 500? 'phone-type' : ''">スケジュール</label>
          <!-- mod FNSI-redmine#3965 付 end -->
        </div>
      </v-ons-col>

      <v-ons-col width="40%" style="height: 100%;">
        <common-searcharea :conditionList="conditionList" @show-popover='showPopover($event)'/>
        <!-- <div class="condition-search-area" @click="showPopover($event)">
          <div class="condition-search-icon-area">
            <v-ons-icon icon="fa-search" size="2.0em" style="color:gray;"></v-ons-icon>
          </div> -->
          <!-- 抽出条件表示エリア[始] -->
          <!-- <div id="condition-items" class="condition-items-area"> -->
            <!-- ベッドレイアウト -->
            <!-- <label class="condition-label"></label> -->
            <!-- 次患者表示 -->
            <!-- <label
              class="condition-label"
              v-if="conditionFilter.nextPatValue !== undefined
                && isTreatStateMode===true"
            >{{ getNextPatName(conditionFilter.nextPatValue) }}</label> -->
            <!-- 表示項目：治療状況マップ -->
            <!-- <label class="condition-label"></label> -->
            <!-- 治療日 -->
            <!-- <label class="condition-label" v-if="isTreatStateMode===false">{{ selectCurrentDate }}</label> -->
            <!-- クール -->
            <!-- <label class="condition-label"></label> -->
            <!-- ベッドグループ -->
            <!-- <label class="condition-label"></label> -->
            <!-- 指示者 -->
            <!-- <label class="condition-label"></label>
          </div> -->
          <!-- 抽出条件表示エリア[終] -->
        <!-- </div> -->
      </v-ons-col>
    </v-ons-row>
    <!-- 抽出ダイアログ[始] -->
    <v-ons-popover
      cancelable
      v-if="popoverVisible"
      v-model:visible="popoverVisible"
      :target="popoverTarget"
      :direction="popoverDirection"
      :class="[fontSizeSet, 'status-map-header-popover']"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="dialogClosed(); popoverPosthide($event)"
    >
      <!--mod FNSI-画面部品デザイン じょはく start-->
      <!--<div id="popover">-->
      <div id="popover" class="fab-font-color">
        <!--mod FNSI-画面部品デザイン じょはく end-->
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>ベッドレイアウト</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-select style="width: 100%" v-model="viewCondition.bedLayoutId">
              <option
                id="selectBedLayout"
                v-for="option in getBedLayoutList"
                :key="option.layoutId"
                :value="option.layoutId"
              >{{ option.layoutName }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row class="condition-row" v-if="isTreatStateMode">
          <v-ons-col width="40%" vertical-align="center">
            <label>次患者表示</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-select style="width: 100%" v-model="viewCondition.nextPatValue">
              <option
                id="nextpatgrp"
                v-for="option in selectNextPatGroup"
                :key="option.nextPatValue"
                :value="option.nextPatValue"
              >{{ option.nextPatGroupName }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>表示項目</label>
          </v-ons-col>
          <!-- <v-ons-col width='40%' vertical-align='center' v-if='isTreatStateMode===true'> -->
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-select style="width: 100%" v-model="viewCondition.statusLayoutNo">
              <!-- <option v-bind:value="-1">-</option> -->
              <option
                id="colitemgrp"
                v-for="option in selectLayoutList"
                :key="option.length"
                :value="option.layoutNo"
              >{{ option.layoutName }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>


        <v-ons-row class="condition-row" v-if="!isTreatStateMode">
          <v-ons-col width="40%" vertical-align="center">
            <label>治療日</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <!-- add FNSI-改修内容日付のチェックの追加対応。 付 start -->
            <div class="flex-column">
              <div class="flex-align-center">
                <!-- mod FNSI-改修内容日付のチェックの追加対応。 付 start -->
                <!-- <input
                  class="data-datetime ntss-input-date ntss-control-size w-100"
                  type="date"
                  v-model="viewCondition.currentDateTime"
                /> -->
                <!-- mod FNSI-日時表示不正 付 start -->
                <!-- //#5590 2023/04/20 ×を常に表示するように修正 張博 start -->
                <!-- <input
                  class="data-datetime ntss-input-date ntss-control-size w-100"
                  type="date"
                  v-model="viewCondition.currentDateTime"
                  max="9999-12-31"
                  @keyup="showMsg"
                  @blur="getDate"
                  style="padding-right: 1em;"
                /> -->
                <!--#10715:日付IF修正Start-->
                <date-input
                  :classes="'data-datetime ntss-input-date ntss-control-size w-100'"
                  id="data-datetime"
                  v-model="viewCondition.currentDateTime"
                  isRequired
                  @keyup="showMsg"
                  @blur="getDate"
                  style="width:100%"
                />
                <!--#10715:日付IF修正End-->
                <!-- //#5590 2023/04/20 ×を常に表示するように修正 張博 end -->
                <!-- mod FNSI-日時表示不正 付 end -->
                <common-calendar class="start-date-comment" v-model="viewCondition.currentDateTime" />
              </div>
              <!--#10715:日付IF修正Start-->
              <span id="error-message" class="error-message" v-if="showErrorStartDate">{{
                this.msgDiaLog
              }}</span>
              <!--#10715:日付IF修正End-->
              <!-- mod FNSI-改修内容日付のチェックの追加対応。 付 end -->
            </div>
            <!-- add FNSI-改修内容日付のチェックの追加対応。 付 end -->
          </v-ons-col>
        </v-ons-row>

        <v-ons-row class="condition-row" v-if="!isTreatStateMode">
          <v-ons-col width="40%" vertical-align="center">
            <label>クール</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-select style="width: 100%" v-model="viewCondition.kurCd">
              <!-- <option v-bind:value="-1">-</option> -->
              <option
                id="selectkurgrp"
                v-for="option in comboKurItemListGetter"
                :key="option.kurCd"
                :value="option.kurCd"
              >{{ option.kurName }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>ベッドグループ</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-select style="width: 100%" v-model="viewCondition.roomBedGroupCd">
              <option
                id="selectbedgrp"
                v-for="(option) in comboBedGroupListGetter"
                :key="option.length"
                :value="option.roomBedGroupCd"
              >{{ option.roomBedGroupName }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>

        <hr v-show="isTreatStateMode===false">
        <v-ons-row class="condition-row" v-if="isTreatStateMode===false" style="margin-top:15px;">
          <v-ons-col width="40%" vertical-align="center">
            <label>変更指示者</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <v-ons-select style="width: 100%" v-model="viewCondition.userId"> -->
            <v-ons-select
              style="width: 100%"
              class="custom-select-required"
              :disabled="!getItemAuthorized('StatusListMap', 'item_map_schedule_move')"
              v-model="viewCondition.userId">
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <option
                id="selectkurgrp"
                v-for="option in selectInstructorList"
                :key="option.user_id"
                :value="option.user_id"
              >{{ option.fullName }}</option>
            </v-ons-select>
            <!--
            <kendo-dropdownlist
              id="selectkurgrp"
              v-model="viewCondition.userId"
              :data-source="doctorList"
              :data-text-field="'fullName'"
              :data-value-field="'user_id'">
            </kendo-dropdownlist>
            -->
          </v-ons-col>
        </v-ons-row>
        <!-- mod FNSI-画面スタイル(ボタン)対応 付 start -->
        <v-ons-row class="condition-row" style="margin: 0">
          <v-ons-col width="30%" vertical-align="center">
            <v-ons-button class="clear btn2-cancel" @click="dialogClear">クリア</v-ons-button>
          </v-ons-col>
          <v-ons-col vertical-align="center"></v-ons-col>
          <v-ons-col width="30%" vertical-align="center">
            <v-ons-button class="ok btn3-normal" @click="dialogOk" :disabled="showErrorStartDate">OK</v-ons-button>
          </v-ons-col>
        </v-ons-row>
        <!-- mod FNSI-画面スタイル(ボタン)対応 付 end -->
      </div>
    </v-ons-popover>
    <!-- 抽出ダイアログ[終] -->
  </div>
</template>

<!-- スクリプト処理 -->
<script>
import { getScopedElementById, getScopedSessionStorage, getScopedDocument } from "@/functions/common/LayoutMeasureHelper";

import { mapActions, mapGetters } from "@/compat/vue/vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
// mod #10359 編集権限の動作不正 dengshen start
// import { deepCopy } from "@/functions/common/CommonFunctions";
import { deepCopy, getAuthorized } from "@/functions/common/CommonFunctions.js";
// mod #10359 編集権限の動作不正 dengshen end
import dayjs from "@/compat/date/dayjs";
import PopoverMixin from "@/components/PopoverMixin";
import { EventBus } from "@/compat/vue/event-bus.js";

//指示者リスト取得
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import { KEY_NAME_STATUS_MAP } from "@/constants/defaultSettingConstants";
import IndUserSelectMixin from "@/components/common/IndUserSelectMixin";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
export const DATETIME_FORMAT = "yyyy-MM-ddThh:mm";
// add FNSI-改修内容日付のチェックの追加対応。 付 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
// add FNSI-改修内容日付のチェックの追加対応。 付 end

import commonSearchArea from "@/components/common/CommonSearchArea";
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
//#5590 2023/04/20 ×を常に表示するように修正 張博 start
import DateInput from "@/components/common/DateInput.vue";
//#5590 2023/04/20 ×を常に表示するように修正 張博 end
// del #10359 編集権限の動作不正 dengshen start
// // add #10359、#10331 編集権限について、対応する。 dengshen start
// import { sendRequestGetDoctorsAtFacility } from "@/apis/facility";
// import { sendRequestGetMstFacilitySettingValue } from "@/apis/facility-setting";
// // add #10359、#10331 編集権限について、対応する。 dengshen end
// del #10359 編集権限の動作不正 dengshen end

export default {
  mixins: [NextTransitionMixin, IndUserSelectMixin, PopoverMixin],
  components: {
    "common-calendar": commonCalender,
    "common-searcharea": commonSearchArea,
    // #5590 2023/04/20 ×を常に表示するように修正 張博 start
    "date-input": DateInput,
    // #5590 2023/04/20 ×を常に表示するように修正 張博 end
  },
  data() {
    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      mode: null,
      viewCondition: {},
      /*add FNSI-改修内容日付のチェックの追加対応。 付 start*/
      msgDiaLog: DIALOG_MESSAGES["99999995"].message,
      showErrorStartDate: false,
      /*add FNSI-改修内容日付のチェックの追加対応。 付 end*/
      // ラジオボタン表示用（store更新前にUIを同期する）
      treatStateModeUi: true,
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: []
      // add FNSI-redmine#3965 付 start
      ,startGaMenWidth: 0,
      // add FNSI-redmine#3965 付 end
    };
  },
  computed: {
    ...mapGetters("status-map/map", [
      "nextPatGroupListGetter",
      "conditionFilter",
      "comboLayoutItemListGetter",
      "comboKurItemListGetter",
      "comboBedGroupListGetter",
      "comboInstructorListGetter",
      "isTreatStateMode",
      "getStatusLayoutList",
      "getSelectedStatusLayout",
      "getSelectedBedLayout",
      "getBedGroupList",
      "getKurList",
      "getBedLayoutList",
      "getConditionTreatMapCurrentDate"
    ]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("account-edit", ["getDefaultSetting"]),
    /**
     * クールの選択肢リスト取得
     */
    selectKurGroup() {
      return this.getKurList;
    },
    /**
     * ベッドグループの選択肢リスト取得
     */
    selectBedGroup() {
      return this.getBedGroupList;
    },
    /**
     * 表示項目の選択肢リスト取得
     */
    selectLayoutList() {
      return this.comboLayoutItemListGetter;
    },
    // -----------------------------------------
    // 次患者表示の選択肢リスト取得
    // -----------------------------------------
    selectNextPatGroup() {
      return this.nextPatGroupListGetter;
    },
    selectCurrentDate() {
      const date = this.getConditionTreatMapCurrentDate;
      if (date) {
        return dayjs(date).format("YYYY/MM/DD");
      } else {
        return "----/--/--";
      }
    },
    /**
     * 指示者の選択肢リスト取得
     */
    selectInstructorList() {
      return this.comboInstructorListGetter;
    },
    // -----------------------------------------
    // デフォルト設定
    // -----------------------------------------
    defaultCondition() {
      // デフォルト設定を store から取得
      const defaultCondition = deepCopy(this.getDefaultSetting[KEY_NAME_STATUS_MAP.KEY_NAME]);
      if (!(!defaultCondition || Object.keys(defaultCondition).length === 0)) {
        // 初期設定がある場合に値を返す
        return defaultCondition;
      } else {
        return null;
      }
    },
  },
  methods: {
    ...mapActions("status-map/map", [
      "initState",
      "clearCondition",
      "conditionSet",
      "setFilterSignal",
      "setTreatStateMode",
      "setInstructorList",
      "setInstructor",
      "reFetchTreatmentStatus"
    ]),
    ...mapGetters("app", ["getQueryParameters", "setQueryParameters"]),
    ...mapActions("loading-screen", ["startLoadingScreen", "finishLoadingScreen"]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    getNextPatName(nextPatValue) {
      const selectedOption = this.selectNextPatGroup.find(
        option => `${option.nextPatValue}` === `${nextPatValue}`
      );
      return selectedOption ? selectedOption.nextPatGroupName : "";
    },
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    showPopover(event) {
      this.popoverTarget = event;
      // 抽出条件セット
      // ダイアログでの操作中は、コピーを表示する
      this.viewCondition = deepCopy(this.conditionFilter);
      this.viewCondition.currentDateTime = dayjs(
        this.viewCondition.currentDateTime
      ).format("YYYY-MM-DD");
      /*add FNSI-改修内容日付のチェックの追加対応。 付 start*/
      this.showErrorStartDate = false;
      /*add FNSI-改修内容日付のチェックの追加対応。 付 end*/
      this.popoverVisible = true;
    },
    /*add FNSI-改修内容日付のチェックの追加対応。 付 start*/
    showMsg(){
      //#10715:日付IF修正Start
      const dataDateTime = getScopedElementById("data-datetime", this.$el || this);
      if (dataDateTime?.validationMessage)
      this.showErrorStartDate = true;
      else
      this.showErrorStartDate = false;
      //#10715:日付IF修正End
    },
    getDate(){
        //#10715:日付IF修正Start
        //フォーカスアウトでsysdate補正()：エラー解除
        if (this.viewCondition.currentDateTime) {
          this.showErrorStartDate = false;
        }
        //#10715:日付IF修正End
    },
    /*add FNSI-改修内容日付のチェックの追加対応。 付 end*/
    async dialogOk() {
      this.popoverVisible = false;
      // 抽出条件の変更チェック
      if (this.conditionChange()) {
        await this.conditionSet({
          kurCd: this.viewCondition.kurCd, // クール
          roomBedGroupCd: this.viewCondition.roomBedGroupCd, // ベッドグループ
          layoutNo: this.viewCondition.statusLayoutNo, // 表示項目
          nextPatValue: this.viewCondition.nextPatValue, // 次患者表示
          layoutId: this.viewCondition.bedLayoutId, // ベッドレイアウト
          currentDateTime: new Date(this.viewCondition.currentDateTime), // 治療日
          userId: this.viewCondition.userId // 変更指示者
        });
        this.startLoadingScreen();
        await this.reFetchTreatmentStatus();
        this.setFilterSignal(true);
        EventBus.$emit("removeShowChip");
        this.finishLoadingScreen();
      }
    },
    // 抽出条件の変更チェック
    conditionChange() {
      const roomBedGroupCd = this.conditionFilter.roomBedGroupCd;
      const statusLayoutNo = this.conditionFilter.statusLayoutNo;
      const kurCd = this.conditionFilter.kurCd;
      const bedLayoutId = this.conditionFilter.bedLayoutId;
      const nextPatValue = this.conditionFilter.nextPatValue;
      const currentDateTime = this.conditionFilter.currentDateTime;
      const userId = this.conditionFilter.userId;
      if (roomBedGroupCd !== this.viewCondition.roomBedGroupCd) {
        return true;
      }
      if (`${statusLayoutNo}` !== `${this.viewCondition.statusLayoutNo}`) {
        // console.log(
        //   "conditionChange/statusLayoutIndex is %o",
        //   statusLayoutIndex
        // );
        return true;
      }
      if (`${kurCd}` !== `${this.viewCondition.kurCd}`) {
        // console.log("conditionChange/kurIndex is %o", kurIndex);
        return true;
      }
      if (`${bedLayoutId}` !== `${this.viewCondition.bedLayoutId}`) {
        return true;
      }
      if (nextPatValue !== this.viewCondition.nextPatValue) {
        // console.log("conditionChange/nextpatgroupid is %o", nextpatgroupid);
        return true;
      }

      if (currentDateTime !== this.viewCondition.currentDateTime) {
        return true;
      }
      if (userId !== this.viewCondition.userId) {
        return true;
      }
      // 抽出条件に変更がない場合
      return false;
    },
    async changeTreatStateMode(displayFlag) {
      this.treatStateModeUi = displayFlag;
      await this.setTreatStateMode(displayFlag);
      this.setFilterSignal(true);
      EventBus.$emit("removeShowChip");
      // 検索条件表示を更新
      this.setConditionList();
    },
    dialogClear() {
      // 治療状況リスト抽出条件クリア
      // ベッドグループ
      const defaultStatusLayout = this.selectLayoutList[0];
      const defaultBedLayout = this.getBedLayoutList[0];
      const defaultKur = this.comboKurItemListGetter[0];
      this.viewCondition.roomBedGroupCd = 0;
      this.viewCondition.statusLayoutNo = defaultStatusLayout
        ? defaultStatusLayout.layoutNo
        : "";
      this.viewCondition.kurCd = defaultKur ? defaultKur.kurCd : "";
      this.viewCondition.bedLayoutId = defaultBedLayout
        ? defaultBedLayout.layoutId
        : "";
      this.viewCondition.nextPatValue = 2;
      this.viewCondition.isClear = true;
      this.popoverVisible = false;
      /* mod #8872 by zhangruixue 2023-06-21 --start */
      this.viewCondition.layoutNo = this.viewCondition.statusLayoutNo;
      this.viewCondition.layoutId = this.viewCondition.bedLayoutId;
      // 検索条件クリア
      this.clearCondition(this.viewCondition);

      this.conditionSet(this.viewCondition);
      /* mod #8872 by zhangruixue 2023-06-21 --end */
      this.setFilterSignal(true);
      EventBus.$emit("removeShowChip");
    },
    dialogClosed() {
      this.viewCondition = deepCopy(this.conditionFilter);
      this.viewCondition.currentDateTime = dayjs(
        this.viewCondition.currentDateTime
      ).format("YYYY-MM-DD");
      // console.log("date is %o.", this.viewCondition.currentDateTime);
    },
    // 共通検索エリア部品に表示するデータのリストを作成
    setConditionList() {
      let condList = [];
      const condObj = this.conditionFilter;
      // 変更指示者
      const selectedInstructor = this.selectInstructorList.find(
        instructor => instructor.user_id === condObj.userId
      );
      if (this.isTreatStateMode === false && selectedInstructor != null) {
        condList.push({ name:"変更指示者", text:selectedInstructor.fullName });
      }
      // ベッドレイアウト
      const selectedBedLayout = this.getBedLayoutList.find(
        layout => `${layout.layoutId}` === `${condObj.bedLayoutId}`
      );
      if (selectedBedLayout) {
        condList.push({ name:"ベッドレイアウト", text:selectedBedLayout.layoutName });
      }
      // 次患表示
      if (this.isTreatStateMode === true && condObj.nextPatValue !== undefined) {
        condList.push({ name:"次患者表示", text:this.getNextPatName(condObj.nextPatValue) });
      }
      // 表示項目
      const selectedStatusLayout = this.selectLayoutList.find(
        layout => `${layout.layoutNo}` === `${condObj.statusLayoutNo}`
      );
      if (selectedStatusLayout) {
        condList.push({ name:"表示項目", text:selectedStatusLayout.layoutName });
      }
      if (this.isTreatStateMode === false) {
        // 治療日
        condList.push({ name:"治療日", text:this.selectCurrentDate });
        // クール
        const selectedKur = this.comboKurItemListGetter.find(
          kur => `${kur.kurCd}` === `${condObj.kurCd}`
        );
        if (selectedKur) {
          condList.push({ name:"クール", text:selectedKur.kurName });
        }
      }
      // ベッドグループ
      if (condObj.roomBedGroupCd !== 0) {
        const bedGroup = this.comboBedGroupListGetter.find(bg => bg.roomBedGroupCd === condObj.roomBedGroupCd);
        if(bedGroup) {
          condList.push({ name:"ベッドグループ", text:bedGroup.roomBedGroupName });
        }
        else {
          condList.push({ name:"ベッドグループ", text:"すべて" });
        }
      }
      else {
      	condList.push({ name:"ベッドグループ", text:"すべて" });
      }
      // add #11285 機能帳票の印刷情報対応② 高 start
      getScopedSessionStorage(this.$el || this).setItem('roomBedGroupNameStatusMap', JSON.stringify(condList.find(item => item.name === "ベッドグループ").text));
      // add #11285 機能帳票の印刷情報対応② 高 end
      // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
      const kurItem = condList.find(item => item.name === "クール");
      getScopedSessionStorage(this.$el || this).setItem('kurGroupNameStatusList', JSON.stringify(kurItem ? kurItem.text : ""));
      // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
      this.conditionList = condList;
    }
  },
  watch: {
    isTreatStateMode: {
      handler(val) {
        if (val !== null) {
          this.treatStateModeUi = val;
        }
      },
      immediate: true,
    },
    getSelectBedInfo() {
      this.bedData = this.getSelectBedInfo;
    },
    /*add FNSI-改修内容日付のチェックの追加対応。 付 end*/
    conditionFilter: {
      handler() {
        this.setConditionList();
      },
      deep: true
    }
  },
  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
    this.setConditionList();
    // add FNSI-redmine#3965 付 start
    this.startGaMenWidth = (getScopedDocument(this.$el || this)?.body?.clientWidth || 0);
    // add FNSI-redmine#3965 付 end
  },
  async created() {
    // 治療状況/スケジュールの初期表示設定
    if (this.defaultCondition && this.defaultCondition[KEY_NAME_STATUS_MAP.KEY_NAME_DISP_MODE] && this.isTreatStateMode === null) {
      await this.setTreatStateMode(this.defaultCondition[KEY_NAME_STATUS_MAP.KEY_NAME_DISP_MODE] === "1");
    } else if (this.isTreatStateMode === null) {
      await this.setTreatStateMode(true);
    }

    // 画面遷移パラメータ取得
    const queryParameters = this.getQueryParameters();
    let layoutNumbers = {colItemLayoutNo: null};

    if (queryParameters.LAYOUTNO) {
      // 表示項目
      layoutNumbers.LAYOUTNO = queryParameters.LAYOUTNO;
      // クエリパラメータのLAYOUTNOをクリア
      queryParameters.LAYOUTNO = null;
      this.setQueryParameters(queryParameters);
    }
    if (queryParameters.BEDLAYOUTNO) {
      // ベッドレイアウト
      layoutNumbers.BEDLAYOUTNO = queryParameters.BEDLAYOUTNO;
      // クエリパラメータのBEDLAYOUTNOをクリア
      queryParameters.BEDLAYOUTNO = null;
      this.setQueryParameters(queryParameters);
    }

    // 情報取得
    await this.initState({ facilityCd: this.getFacilityCd, defaultCondition: this.defaultCondition, layoutNumbers: layoutNumbers });

    // 指示者リスト作成(非同期)
    this.getIndUserList(
      AUTHORITY_CODES.IND_EDIT,
      AUTHORITY_CODES.IND_PEDIT
    ).then(response => {
      this.setInstructorList(response.doctorList);
      this.$nextTick(() => {
        this.setInstructor(response.iniSelectId);
      });
    });
  }
};
</script>


<!-- 個別スタイル定義 -->
<style scoped>
#popover {
  margin: 5px 10px 5px 10px;
  position: relative;
}
input[type="radio"] {
  display: none; /* ラジオボタンを非表示にする */
}
input[type="checkbox"] {
  display: none; /* チェックボックスを非表示にする */
}
/* ボタングループのスタイル定義 */
.ntss-button-group {
  width: 100%;
  font-size: 1.5em;
}
.label {
  display: block; /* ブロックレベル要素化する */
  float: left; /* 要素の左寄せ・回り込を指定する */
  /* mod FNSI-redmine#3965 付 start */
  /* width: 30%; ボックスの横幅を指定する */
  width: 35%; /* ボックスの横幅を指定する */
  /* mod FNSI-redmine#3965 付 end */
  height: 2em; /* ボックスの高さを指定する */
  padding-left: 5px; /* ボックス内左側の余白を指定する */
  padding-right: 5px; /* ボックス内御右側の余白を指定する */
  color: #ffffff; /* フォントの色を指定する */
  text-align: center; /* テキストのセンタリングを指定する */
  line-height: 2em; /* 行の高さを指定する */
  cursor: pointer; /* マウスカーソルの形（リンクカーソル）を指定する */
  margin: 15px 0px;
  font-size: 1.5em;
}
.first-of-type {
  border-radius: 10px 0 0 10px;
  margin-left: 4px;
}
.last-of-type {
  border-radius: 0 10px 10px 0;
  margin-right: 25px;
}
/* add FNSI-redmine#3965 付 start */
.phone-type {
  border-radius: 10px 10px 10px 10px;
  margin-left: 0px;
  margin-right: 0px;
  width: 50%; /* ボックスの横幅を指定する */
  margin: 0 23%;
  display: block; /* ブロックレベル要素化する */
  height: 2em; /* ボックスの高さを指定する */
  padding-left: 5px; /* ボックス内左側の余白を指定する */
  padding-right: 5px; /* ボックス内御右側の余白を指定する */
  color: #ffffff; /* フォントの色を指定する */
  text-align: center; /* テキストのセンタリングを指定する */
  line-height: 2em; /* 行の高さを指定する */
  cursor: pointer; /* マウスカーソルの形（リンクカーソル）を指定する */
  font-size: 1em;
}
/* add FNSI-redmine#3965 付 end */
v-ons-icon.loupe-icon {
  color: gray;
}
ons-popover :deep(.popover__content) {
    min-width: 420px;
  }

/* mod FNSI-dialog表示不全 付 start */
@media screen and (min-width: 1400px) {
  .status-map-header-popover :deep(.popover__content) {
    min-width: 420px;
  }
}
/* mod FNSI-dialog表示不全 付 end */
</style>
