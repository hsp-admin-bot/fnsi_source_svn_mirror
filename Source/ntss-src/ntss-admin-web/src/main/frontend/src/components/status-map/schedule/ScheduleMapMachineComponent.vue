/**
 * マップ上に配置される装置(スケジュールマップ)
 */
<template>
  <div
    ref="machine-container"
    class="machine"
    :id="'machine-' + machineData.bedLayout.machine_no"
    :style="sizeAndPosition"
    :class="isBedMachineAtHome ? 'machine-athome' : ''"
    @mousedown="listenerStart"
    @mouseup="listenerEnd($event, machineData)"
    @mousemove="listenerMove"
    @touchstart="listenerStart"
    @touchend="listenerEnd($event, machineData)"
    @touchmove="listenerMove"
  >
    <template v-if="shouldRenderItem">
      <div
        class="display-full auto-event"
        :style="isBedMachineAtHome ? 'display: none;' : ''"
        @mouseup="showPopover"
        @touchend="showPopover"
        @mousewheel="$event.stopPropagation()"
        v-if="!isBedMachineAtHome"
      >
        <div
          v-if="machineData.treatment != null && machineData.treatment.rstDialysisState === '6'"
        >
          <img class="img-icon" :src="image_src_all_view_dark" />
        </div>
        <div
          v-else
        >
          <img class="img-icon" :src="image_src_all_view" />
        </div>
        <!-- mod  FNSI redmine 6031 陳 end-->
      </div>
      <div
        v-if="isBedMachineAtHome"
        class="machine-inner auto-event"
        style="background-color: #0000;"
        @mouseup="showPopover"
        @touchend="showPopover"
      >
        <ScheduleMapBedAtHome :bedData="machineData"></ScheduleMapBedAtHome>
      </div>
      <div v-else-if="isBedMachine" class="machine-inner none-event">
        <ScheduleMapBed :bedData="machineData"></ScheduleMapBed>
      </div>
      <!-- mod FNSI-警報・報知追加 付 start -->
      <div v-else-if="!isBedMachine" class="machine-inner auto-event">
        <ScheduleMapMachineRoom :machineData="machineData"></ScheduleMapMachineRoom>
      </div>
      <!-- mod FNSI-警報・報知追加 付 end -->
      <!-- ツールチップ -->
      <v-ons-dialog
        ref="machinePopoverDialog"
        v-if="popoverVisible"
        animation="none"
        cancelable
        v-model:visible="popoverVisible"
        :target="'#machine-' + machineData.bedLayout.machine_no"
        :direction="popoverDirection"
        @postshow="popoverAdjustment"
        @posthide="popoverClose"
        class="tool-tip"
      >
        <div class="popover-size">
          <ScheduleMapBedAtHomePopOver
            :isPopoverScroll="true"
            :bedData="machineData"
            v-if="popoverVisible && isBedMachineAtHome"
          ></ScheduleMapBedAtHomePopOver>
          <ScheduleMapBed
            :isPopoverScroll="true"
            :bedData="machineData"
            v-else-if="popoverVisible && isBedMachine && !isBedMachineAtHome"
          ></ScheduleMapBed>
          <ScheduleMapMachineRoom
            :isPopoverScroll="true"
            :machineData="machineData"
            v-else-if="popoverVisible && !isBedMachine"
          ></ScheduleMapMachineRoom>
        </div>
      </v-ons-dialog>
    </template>
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import ScheduleMapBed from "@/components/status-map/schedule/ScheduleMapBedComponent";
import ScheduleMapBedAtHome from "@/components/status-map/schedule/ScheduleMapBedAtHomeComponent";
import ScheduleMapBedAtHomePopOver from "@/components/status-map/schedule/ScheduleMapBedAtHomePopOverComponent";
import ScheduleMapMachineRoom from "@/components/status-map/schedule/ScheduleMapMachineRoomComponent";
// 機能コード 在宅透析施設用
import { MACHINE_MODEL } from "@/constants/machineModel";
import dayjs from "@/compat/date/dayjs";
import { EventBus } from "@/compat/vue/event-bus.js";
// add FNSI redmine 5461 劉祥霖 start
import {ApiHelper} from "@/apis/AxiosHelper";
// add FNSI redmine 5461 劉祥霖 end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import allViewImg from "../../../assets/all_view.png";
import allViewDarkImg from "../../../assets/all_view_dark.png";
import { getOnsDialogScopedElementsByClassName } from "@/functions/common/OnsenFunctions.js";

// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
//add #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 start
const DEF_SHUNT_NONE = "3";
const DEF_SHUNT_UNKNOWN = "-";
//add #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 end
export default {
  data() {
    return {
      shouldRenderItem: false,
      observer: null,
      isListenerStarted: false,
      moveCount: 0,
      isAssignOrderQueueing: false,
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "right down up left",

      //  mod FNSI redmine 6031 陳 start
      // image_src_all_view: require("../../../assets/all_view.png")
      image_src_all_view: allViewImg,
      image_src_all_view_dark: allViewDarkImg,
      //  mod FNSI redmine 6031 陳 end
      //add #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 start
      bedDataInfo: []
      //add #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 end
    };
  },
  components: {
    ScheduleMapBed,
    ScheduleMapBedAtHome,
    ScheduleMapBedAtHomePopOver,
    ScheduleMapMachineRoom
  },
  computed: {
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("status-map/map", [
      "conditionFilter",
      "getConditionTreatMapCurrentDate",
      "getSelectedTreatmentSchedule",
      "getSelectedUser"
    ]),
    ...mapGetters("status-map/modal", {
      selectedOrdMain: "getSelectedOrdMain"
    }),
    ...mapGetters("multi-modal", ["isModalOpened"]),
    /**
     * ポインターカーソル表示有無
     */
    isCursorPointer() {
      if (this.machineData.isClickable) {
        return true;
      } else {
        return false;
      }
    },
    sizeAndPosition() {
      let ret =
        `width: ${this.machineData.bedLayout.width}px; ` +
        `height: ${this.machineData.bedLayout.height}px; ` +
        `top: ${this.machineData.bedLayout.top}px; ` +
        `left: ${this.machineData.bedLayout.left}px;`;
      if (this.isCursorPointer) {
        ret = ret + "cursor: pointer";
      }
      return ret;
    },
    isBedMachine() {
      if (
        this.machineData.bedLayout &&
        [MACHINE_MODEL.PERSONAL, MACHINE_MODEL.DCS].includes(
          this.machineData.bedLayout.model
        )
      ) {
        return true;
      } else {
        return false;
      }
    },
    isBedMachineAtHome() {
      if (
        this.machineData.bedLayout &&
        [MACHINE_MODEL.PERSONAL, MACHINE_MODEL.DCS].includes(
          this.machineData.bedLayout.model
        ) &&
        "1" === this.machineData.bedLayout.is_home_dialysis
      ) {
        return true;
      } else {
        return false;
      }
    }
  },
  props: ["machineData", "historyKey"],
  methods: {
    getMachineOwnerDocument() {
      return this.$refs["machine-container"]?.ownerDocument || document;
    },
    getMachinePopoverElements(directionClass) {
      return getOnsDialogScopedElementsByClassName(
        this.$refs.machinePopoverDialog,
        directionClass,
        this.$refs["machine-container"] || this.$el || null,
        "tool-tip"
      );
    },
    getMovingChipElements() {
      const scopeRoot = this.$refs["machine-container"]?.closest?.("[data-ntss-layout-root], .main-content-area, #app")
        || this.getMachineOwnerDocument().body
        || document;
      return Array.from(scopeRoot?.querySelectorAll?.(".machine.cls_move_chip") || []);
    },
    // add #6940 2022/8/17 【DBデータ整合性を壊す】治療状況マップのスケジュールにてスケジュール操作で画面更新がされる前に別のスケジュール操作が可能。 dou start
    // 共通ローダー設定
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    // add #6940 2022/8/17 【DBデータ整合性を壊す】治療状況マップのスケジュールにてスケジュール操作で画面更新がされる前に別のスケジュール操作が可能。 dou end
    ...mapActions("status-map/map", {
      actionTreatmentSchedule: "actionTreatmentSchedule",
      assignScheduleOrdMain: "assignScheduleOrdMain",
      checkEmptyBed: "checkEmptyBed",
      setFilterSignal: "setFilterSignal",
      checkBeforeMoveOrdMain: "checkBeforeMoveOrdMain",
      //add FNSI redmine5436 fang start
      setShowFlg: "setShowFlg",
      //add FNSI redmine5436 fang end
    }),
    ...mapActions("status-map/modal", ["setFindCondition"]),
    ...mapActions("multi-modal", ["showNotAssignedSchedule"]),
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    /**
     * 不一致項目文字列を取得する
     * @param {*} response
     */
    makeBeforeMoveOrdMainErrorMassage(response) {
      let ret = "";
      // シャント一不一致判定
      if (response.isShuntMismatch) {
        if (ret !== "") {
          ret = ret + "・";
        }
        ret = ret + "シャント";
      }
      // 感染症不一致判定
      if (response.isInfectionMismatch) {
        if (ret !== "") {
          ret = ret + "・";
        }
        ret = ret + "感染症";
      }
      // 治療方法不一致判定
      if (response.isTreatmentMismatch) {
        if (ret !== "") {
          ret = ret + "・";
        }
        ret = ret + "治療方法";
      }
      //add #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 start
      if (response.isVaMismatch) {
        if (ret !== "") {
          ret = ret + "・";
        }
        ret = ret + "VA位置";
      }
      //add #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 end
      return ret;
    },
    // add FNSI-popup close 付 start
    closeDialog() {
      this.popoverVisible = false;
    },
    // add FNSI-popup close 付 end
    // add FNSI redmine 5461 劉祥霖 start
    async selectForSearchReservedBedOnDB(
      facilityCd,
      ordNo,
      patId,
      bedCd,
      searchStartDate,
      searchStartKurCd,
      isMoveTreatDate
    ) {
      let counter = 0;
      await ApiHelper.get("/scheduleList/selectForSearchReservedBed", {
        facilityCd,
        ordNo,
        patId,
        bedCd,
        searchStartDate,
        searchStartKurCd,
        isMoveTreatDate
      })
        .then(
          function(response) {
            counter = response.data.length;
          }.bind(counter)
        )
        .catch(error => {
          throw error;
        });
      return counter;
    },
    // add FNSI redmine 5461 劉祥霖 end

    // add FNSI redmine 6588 劉祥霖 start
    async checkBedForSwap(
      facilityCd,
      ordNo1,
      patId1,
      ordNo2,
      patId2,
      bedCd1,
      bedCd2,
      searchStartDate,
      searchStartKurCd,
      isMoveTreatDate
    ) {
      let counter = 0;
      let ordNo=ordNo1;
      let patId=patId1;
      let bedCd=bedCd2;

      await ApiHelper.get("/scheduleList/selectForSearchReservedBed", {
        facilityCd,
        ordNo,
        patId,
        bedCd,
        searchStartDate,
        searchStartKurCd,
        isMoveTreatDate
      })
        .then(
          function(response) {
            let data1=response.data;
            if(data1.length>0){
              for (const data of data1){
                if(data.ordNo!= ordNo2 && data.ordNo!=ordNo1){
                  counter++;
                }
              }
            }
          }.bind(counter)
        )
        .catch(error => {
          throw error;
        });
      ordNo=ordNo2;
      patId=patId2;
      bedCd=bedCd1;
      await ApiHelper.get("/scheduleList/selectForSearchReservedBed", {
        facilityCd,
        ordNo,
        patId,
        bedCd,
        searchStartDate,
        searchStartKurCd,
        isMoveTreatDate
      })
        .then(
          function(response) {
            let data2=response.data;
            if(data2.length>0){
              for (const data of data2){
                if(data.ordNo!= ordNo1 && data.ordNo!= ordNo2){
                  counter++;
                }
              }
            }
          }.bind(counter)
        )
        .catch(error => {
          throw error;
        });

      return counter;
    },
    // add FNSI redmine 6588 劉祥霖 end

    /**
     * 空きベッドに対する未割当スケジュール選択
     */
    async clickScheduleMachine(e, machineData) {
      // mod #10359 編集権限の動作不正 dengshen start
      const userAuthorityCds = this.getItemAuthorized('StatusListMap', 'item_map_schedule_move');
      if (!userAuthorityCds) {
        this.$ons.notification.alert({
          // title: "権限エラー",
          // message: functionName+"を操作する権限がありません。管理者に確認してください。"
          title: DIALOG_MESSAGES[12000315].title,
          message: messageFormat(DIALOG_MESSAGES[12000315].message, "治療指示")
        });
        return ;
      }
      // mod #10359 編集権限の動作不正 dengshen end
      if (machineData.isClickable) {
        if ("1" !== machineData.bedLayout.is_home_dialysis) {
          // 在宅ベッド以外のみ実行する

          // 指示者チェック
          if (this.getSelectedUser && this.getSelectedUser != "") {
            // 指示者あり

            // 空きベッド
            // mod #10649 治療状況マップのスケジュール表示にてスケジュール割り当てができない【マニュアル検証指摘】20240618 ztc start
            // if (
            //   !this.getSelectedTreatmentSchedule &&
            //   !machineData.treatment &&
            //   0 < machineData.bedLayout.bed_cd
            // ) {
            if (
              !this.getSelectedTreatmentSchedule &&
                (!machineData.treatment || !!machineData.treatment && !machineData.treatment.ordNo) &&
              0 < machineData.bedLayout.bed_cd
            ) {
            // mod #10649 治療状況マップのスケジュール表示にてスケジュール割り当てができない【マニュアル検証指摘】20240618 ztc end
              const date = dayjs(this.getConditionTreatMapCurrentDate).format(
                "YYYYMMDD"
              );
              // 未割当の治療データ選択
              this.setFindCondition({
                facilityCd: this.getFacilityCd,
                treatDate: date,
                bedCd: machineData.bedLayout.bed_cd,
                bedName: machineData.bedLayout.name
              })
                .then(() => this.showNotAssignedSchedule())
                .then(() => (this.isAssignOrderQueueing = true));
            } else {
              // ベッド判定
              if (
                [MACHINE_MODEL.PERSONAL, MACHINE_MODEL.DCS].includes(
                  machineData.bedLayout.model
                ) &&
                0 < machineData.bedLayout.bed_cd
              ) {
                // スケジュールが選択済みで移動先のベッドが空かどうか判定
                let res = true;
                const selectedInfo = this.getSelectedTreatmentSchedule;
                if (
                  selectedInfo &&
                  selectedInfo.treatment &&
                  machineData.treatment === null
                ) {
                  // 移動先ベッドの空き確認
                  //mod FNSI-redmine 5461 劉祥霖　start
                  const moveFlag=false;
                  // res = await this.checkEmptyBed({
                  //   treatDate: selectedInfo.treatment.treatDate,
                  //   kurCd: selectedInfo.treatment.kurCd,
                  //   bedCd: this.machineData.bedLayout.bed_cd
                  await this.selectForSearchReservedBedOnDB(
                    this.getFacilityCd,
                    selectedInfo.treatment.ordNo,
                    selectedInfo.treatment.patId,
                    this.machineData.bedLayout.bed_cd,
                    selectedInfo.treatment.treatDate,
                    selectedInfo.treatment.kurCd,
                    moveFlag
                  ).then(function(response) {
                      if(response!==0){
                        res=false;
                      }
                    }.bind(res)
                  ).catch(error => {
                    throw error;
                  });
                  // mod FNSI redmine 5461 劉祥霖 end
                  if (!res) {
                    // エラーメッセージ
                    this.$ons.notification.alert({
                      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                      // title: "エラー",
                      // message:
                      //   "移動先ベッドが空きベッドではなくなったため、スケジュールの移動に失敗しました"
                      title: DIALOG_MESSAGES[12000240].title,
                      message: messageFormat(DIALOG_MESSAGES[12000240].message)
                      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                    });

                    // 選択解除＋画面更新
                    this.setFilterSignal(true);
                  }
                }

                if (
                  res &&
                  selectedInfo &&
                  selectedInfo.treatment &&
                  selectedInfo.bedLayout.bed_cd != machineData.bedLayout.bed_cd &&
                  selectedInfo.treatment.ordNo
                ) {
                  //add #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 start

                  const bedCd = machineData.bedLayout.bed_cd;
                  const bedInfo = this.bedDataInfo.find(item => item.bed_cd == bedCd);
                  const bedVaDirect = bedInfo.shunt_position;
                  const patVaDirect = selectedInfo.statusMapInfo.patVaDirect;
                  let shuntFlag = true;
                  if (null === patVaDirect || "" === patVaDirect || null === bedVaDirect || "" === bedVaDirect) {
                    shuntFlag = true;
                  }else if (DEF_SHUNT_NONE == patVaDirect || DEF_SHUNT_NONE == bedVaDirect) {
                    // 3:無
                    shuntFlag = true;
                  }else if (DEF_SHUNT_UNKNOWN == patVaDirect) {
                    // -:不明
                    shuntFlag = false;
                  }else if (bedVaDirect != patVaDirect) {
                    shuntFlag = false;
                  }
                  //add #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 end

                  // 移動先ベッド割り当て前チェック
                  let err1 = await this.checkBeforeMoveOrdMain({
                    ordNo: selectedInfo.treatment.ordNo,
                    bedCd: this.machineData.bedLayout.bed_cd
                  });
                  if (machineData.treatment?.ordNo && machineData.treatment?.patId) {
                    // 移動元ベッド割り当て前チェック
                    //add FNSI redmine 6588 劉祥霖　start
                    //ベッド入れ替えの場合、ダミースケジュールチェック
                    await this.checkBedForSwap(
                      this.getFacilityCd,
                      selectedInfo.treatment.ordNo,
                      selectedInfo.treatment.patId,
                      machineData.treatment.ordNo,
                      machineData.treatment.patId,
                      selectedInfo.bedLayout.bed_cd,
                      this.machineData.bedLayout.bed_cd,
                      selectedInfo.treatment.treatDate,
                      selectedInfo.treatment.kurCd,
                      false
                    ).then(function(response) {
                        if(response!==0){
                          res=false;
                        }
                      }.bind(res)
                    ).catch(error => {
                      throw error;
                    });
                    // mod FNSI redmine 5461 劉祥霖 end
                    if (!res) {
                      // エラーメッセージ
                      this.$ons.notification.alert({
                        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                      // title: "エラー",
                      // message:
                      //   "移動先ベッドが空きベッドではなくなったため、スケジュールの移動に失敗しました"
                      title: DIALOG_MESSAGES[12000240].title,
                      message: messageFormat(DIALOG_MESSAGES[12000240].message)
                      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                      });

                      // 選択解除＋画面更新
                      this.setFilterSignal(true);
                      return;
                    }
                    //add FNSI redmine 6588 劉祥霖　end
                    let err2 = await this.checkBeforeMoveOrdMain({
                      ordNo: machineData.treatment.ordNo,
                      bedCd: selectedInfo.bedLayout.bed_cd
                    });
                    if (err2) {
                      // シャント一不一致判定
                      if (err1.isShuntMismatch || err2.isShuntMismatch) {
                        err1.isShuntMismatch = true;
                      }
                      // 感染症不一致判定
                      if (
                        err1.isInfectionMismatch ||
                        err2.isInfectionMismatch
                      ) {
                        err1.isInfectionMismatch = true;
                      }
                      // 治療方法不一致判定
                      if (
                        err1.isTreatmentMismatch ||
                        err2.isTreatmentMismatch
                      ) {
                        err1.isTreatmentMismatch = true;
                      }
                    }
                  }
                  //add #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 start
                  if (!shuntFlag) {
                    err1.isVaMismatch = true;
                  }
                  //add #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 end
                  const errmsg = this.makeBeforeMoveOrdMainErrorMassage(err1);
                  if (errmsg != "") {
                    // 処理確認
                    await this.$ons.notification.confirm({
                      // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
                      // title: "治療予定の移動",
                      title: DIALOG_MESSAGES[13000133].title,
                      // message:
                      //   "指定されたベッドでは " +
                      //   errmsg +
                      //   " が不一致ですが、移動を行いますか？",
                      message: messageFormat(DIALOG_MESSAGES[13000133].message,errmsg),
                        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
                      callback: answer => {
                        if (answer == 0) {
                          res = false;
                          // 選択解除＋画面更新
                          this.setFilterSignal(true);
                        }
                      }
                    });
                  }
                }
                /* add #IES_7066 by zhangruixue 2023-07-11 --start */
                if (machineData.treatment && machineData.treatment.rstDialysisState === '2') {
                  if (!await this.showMoveCheckDialog(machineData.treatment.rstDialysisState)) {
                    res = false;
                    this.setFilterSignal(true);
                    return;
                  }
                }
                /* add #IES_7066 by zhangruixue 2023-07-11 --end */
                if (res) {
                  // スケジュール移動
                  // add #6940 2022/8/17 【DBデータ整合性を壊す】治療状況マップのスケジュールにてスケジュール操作で画面更新がされる前に別のスケジュール操作が可能。 dou start
                  await this.setLoadingScreenVisible(true);
                  // add #6940 2022/8/17 【DBデータ整合性を壊す】治療状況マップのスケジュールにてスケジュール操作で画面更新がされる前に別のスケジュール操作が可能。 dou end
                  const isSuccess = await this.actionTreatmentSchedule(
                    machineData
                  );
                  // add #6940 2022/8/17 【DBデータ整合性を壊す】治療状況マップのスケジュールにてスケジュール操作で画面更新がされる前に別のスケジュール操作が可能。 dou start
                  await this.setLoadingScreenVisible(false);
                  // add #6940 2022/8/17 【DBデータ整合性を壊す】治療状況マップのスケジュールにてスケジュール操作で画面更新がされる前に別のスケジュール操作が可能。 dou end
                  if (isSuccess === false) {
                    // エラーメッセージ
                    await this.$ons.notification.alert({
                      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                      // title: "エラー",
                      // message:
                      //   "スケジュールが変更されているため、スケジュール移動に失敗しました"
                      title: DIALOG_MESSAGES[12000326].title,
                      message: messageFormat(DIALOG_MESSAGES[12000326].message)
                      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                    });

                    // 選択解除＋画面更新
                    this.setFilterSignal(true);
                    }
                  }
                }
              }
            // add FNSI-redmine#3956 付 start
            EventBus.$emit("showChip",e);
            // add FNSI-redmine#3956 付 end
          } else {
            // 指示者なし

            // エラーメッセージ
            const { title, message } = DIALOG_MESSAGES[22010001];
            await this.$ons.notification.alert({
              // title: "必須項目未入力",
              // message: "{$1}は必須入力項目です。\n必ず値を入力してください。"
              title: title,
              message: messageFormat(message, "指示者")
            });
          }
        }
      }
      // add FNSI-redmine#3958 付 start
      else {
        if (machineData.bedLayout.model != "005" && machineData.bedLayout.model != "004") {
          // エラーメッセージ
          await this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "エラー",
            // message: "透析液調製装置へのスケジュールの割り当ては行えません"
            title: DIALOG_MESSAGES[12000242].title,
            message: messageFormat(DIALOG_MESSAGES[12000242].message)
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        }
      }
      // add FNSI-redmine#3958 付 end
    },
    /* add #IES_7066 by zhangruixue 2023-07-11 --start */
    async showMoveCheckDialog(state) {
      if (state === "2") {
        let rtn = false;
        await this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000122].title,
          message: messageFormat(DIALOG_MESSAGES[13000122].message),
          callback: answer => {
            if (answer === 1) {
              rtn = true;
            }
          }
        });
        return rtn;
      } else {
        return true;
      }
    },
    /* add #IES_7066 by zhangruixue 2023-07-11 --end */
    popoverClose() {
      this.popoverVisible = false;
    },
    /**
     * 表示後にポップアップの位置を調整
     * （在宅アイコン用）
     */
    popoverAdjustment() {
      // 右表示の位置調整(在宅アイコン)
      const leftPopOver = this.getMachinePopoverElements("popover--left");
      if (leftPopOver.length > 0) {
        this.$nextTick(() => {
          leftPopOver.forEach(pop => {
            const newAttr =
              pop.getAttribute("style") + " transform-origin: left;";
            pop.setAttribute("style", newAttr);
          });
        });
      }
      // 左表示の位置調整(在宅アイコン)
      const rightPopOver = this.getMachinePopoverElements("popover--right");
      if (rightPopOver.length > 0) {
        this.$nextTick(() => {
          rightPopOver.forEach(pop => {
            const newAttr =
              pop.getAttribute("style") + " transform-origin: right;";
            pop.setAttribute("style", newAttr);
          });
        });
      }
      // 上表示の位置調整(在宅アイコン)
      const topPopOver = this.getMachinePopoverElements("popover--top");
      if (topPopOver.length > 0) {
        this.$nextTick(() => {
          topPopOver.forEach(pop => {
            const newAttr =
              pop.getAttribute("style") + " transform-origin: top;";
            pop.setAttribute("style", newAttr);
          });
        });
      }
      // 下表示の位置調整(在宅アイコン)
      const bottomPopOver = this.getMachinePopoverElements("popover--bottom");
      if (bottomPopOver.length > 0) {
        this.$nextTick(() => {
          bottomPopOver.forEach(pop => {
            const newAttr =
              pop.getAttribute("style") + " transform-origin: bottom;";
            pop.setAttribute("style", newAttr);
          });
        });
      }
    },
    showPopover(event) {
      event.preventDefault();
      event.stopPropagation();
      if (
        this.isListenerStarted === true &&
        this.moveCount <= 3
      ) {
        this.popoverVisible = true;
      }
      this.isListenerStarted = false;
      this.listenerMove(event);
    },
    listenerStart(e) {
      //#10407:変更なしでも画面を表示させる Start
      // #10623:治療状況マップの装置自己診断行押下時の動作不正Start
      if (!(e.target.id != undefined && ( e.target.id === 'changeinstructionline'
         || e.target.id === 'deviceselfdiagnosisline'))) {
        //_指示変更行クリック以外　又は　装置自己診断行クリック以外：ベッド移動操作
        //#10623:治療状況マップの装置自己診断行押下時の動作不正 End
         e.preventDefault();
         this.isListenerStarted = true;
         this.moveCount = 0;
      }
      //#10407:変更なしでも画面を表示させる End
    },
    listenerMove(e) {
      e.preventDefault();
      if ( this.isListenerStarted === true
        && ( e.movementX !== 0 || e.movementY !== 0 )) {
          this.moveCount = this.moveCount + 1;      }
    },
    async listenerEnd(e, machine) {
      //add FNSI-redmine 5461 劉祥霖 start
      if(this.machineData.treatment){
        if(this.machineData.treatment.isDummy=="1"){
          //mod FNSI-redmine 6588 劉祥霖 start
          // 6588による5461のメッセージを削除
          let move_chip=this.getMovingChipElements();
          let length=move_chip.length;
          if(length > 0){
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "長時間予定との入れ替え不可",
              // message:
              //   "長時間予定とのスケジュール入替はできません。\n長時間予定の開始クールにて予定を変更するか、長時間予定をベッド未登録に変更にて操作してください。"
              title: DIALOG_MESSAGES[12000243].title,
              message: messageFormat(DIALOG_MESSAGES[12000243].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }else{
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "長時間予定との入れ替え不可",
              // message:
              //   "他の予定と重複するためスケジュール変更できません。"
              title: DIALOG_MESSAGES[12000331].title,
              message: messageFormat(DIALOG_MESSAGES[12000331].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          // mod FNSI-redmine 6588 劉祥霖 end
          }
          return;
        }
      }
      //add FNSI-redmine 5461 劉祥霖 end
      e.preventDefault();
      // MoveStartからEndの間に発火したMoveイベントが3回以下は移動中ではないとする
      if (this.isListenerStarted === true
        && this.moveCount <= 3) {
        this.clickScheduleMachine(e, machine);
      }
      this.isListenerStarted = false;
    }
  },
  watch: {
    async isModalOpened(newValue, oldValue) {
      if (this.isAssignOrderQueueing === true) {
        // 本画面でのモーダルオープンに反応、一回限りの実行になるように
        this.isAssignOrderQueueing = false;
        if (oldValue === true && newValue === false && this.selectedOrdMain) {
          // モーダルが閉じられたとき
          // 対象ベッドの空き確認
          let res = await this.checkEmptyBed({
            treatDate: this.selectedOrdMain.treatDate,
            kurCd: this.conditionFilter.kurCd,
            bedCd: this.machineData.bedLayout.bed_cd
            //add FNSI redmine 6588 劉祥霖　start
            ,facilityCd:this.selectedOrdMain.facilityCd
            ,ordNo:this.selectedOrdMain.ordNo
            ,patId:this.selectedOrdMain.patId
            //add FNSI redmine 6588 劉祥霖　end
            ,indTreatmentCd:this.selectedOrdMain.indTreatmentCd
          });
          if (res=="noclash") {
            // ベッド割り当て前チェック
            const err = await this.checkBeforeMoveOrdMain({
              ordNo: this.selectedOrdMain.ordNo,
              bedCd: this.machineData.bedLayout.bed_cd
            });
            const errmsg = this.makeBeforeMoveOrdMainErrorMassage(err);
            if (errmsg != "") {
              // 処理確認
              await this.$ons.notification.confirm({
                // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
                // title: "治療予定の割り当て",
                title: DIALOG_MESSAGES[13000134].title,
                // message:
                //   "選択されたベッドでは " +
                //   errmsg +
                //   " が不一致ですが、割り当てを行いますか？",
                message: messageFormat(DIALOG_MESSAGES[13000134].message,errmsg),
                  // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
                callback: answer => {
                  if (answer == 0) {
                    res = false;
                  }
                }
              });
            }
            if (res) {
              // ベッド割り当て処理
              this.assignScheduleOrdMain({
                ordNo: this.selectedOrdMain.ordNo,
                bedCd: this.machineData.bedLayout.bed_cd,
                currentDate: this.selectedOrdMain.treatDate
              });
            }
          //add FNSI redmine 6588 劉祥霖　start
          }else if(res=="isDummy"){
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "長時間予定との予定重複",
              // message:
              //   "他の予定と重複するためスケジュール変更できません。"
              title: DIALOG_MESSAGES[12000212].title,
              message: messageFormat(DIALOG_MESSAGES[12000212].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }else if(res=="notDummy")
          //add FNSI redmine 6588 劉祥霖　end
          {
            // エラーメッセージ
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "エラー",
              // message:
              //   "指定ベッドが空きベッドではなくなったため、治療記録の割り当てが行えません"
              title: DIALOG_MESSAGES[12000244].title,
              message: messageFormat(DIALOG_MESSAGES[12000244].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          // add/ #12465同患者同日同治療方法同クールの使用制限をしてもメッセージがでない tianqidong start
          }else if(res=='allSame'){
            this.$ons.notification.alert({
              title: DIALOG_MESSAGES[22010011].title,
              message: messageFormat(DIALOG_MESSAGES[22010011].message)
            });
          }
          // add/ #12465同患者同日同治療方法同クールの使用制限をしてもメッセージがでない tianqidong end
        }
      }
    },
    //add FNSI redmine5436 fang start
    popoverVisible(newValue) {
      if (newValue) {
        this.setShowFlg(true);
      } else {
        this.setShowFlg(false);
      }
    }
    //add FNSI redmine5436 fang end
  },

  //mod #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 start
  async created() {
    // add FNSI-popup close 付 start
    // add 性能改善メモリ不足 shan start
    EventBus.$off("closeDialog", this.closeDialog);
    // add 性能改善メモリ不足 shan start
    EventBus.$on("closeDialog", this.closeDialog);
    // add FNSI-popup close 付 end
    const facilityCd = this.getFacilityCd;
    await ApiHelper.get("/scheduleList/getBedAndKurInfo", {
      facilityCd
    }).then(response => {
      this.bedDataInfo = response.data.bed;
    })
    //mod #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 end
  },

  mounted() {
    this.observer = new IntersectionObserver((entries, observer) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.shouldRenderItem = true;
          observer.unobserve(entry.target);
        }
      });
    });
    this.observer.observe(this.$refs["machine-container"]);
  },


  beforeUnmount() {
    this.observer?.disconnect();
    EventBus.$off("closeDialog", this.closeDialog);
  },
};
</script>
<style scoped>
.machine {
  position: absolute;
  z-index: 2;
  /* del FNSI-No388 font-size 付 start */
  /* font-size: 1.2em; */
  /* del FNSI-No388 font-size 付 end */
}
.machine-inner {
  height: 100%;
  width: 100%;
}
.none-event {
  pointer-events: none;
}
div.display-full {
  position: absolute;
  /* #9771 FNWから取得したVisualLayoutが正しく取り込めていない linjunfeng start*/
  /* ベッドの図はかぶっているように見える */
  /* top: 0.2em;
  right: -0.4em; */
  top: 0.6em;
  right: 0.1em;
  /* #9771 FNWから取得したVisualLayoutが正しく取り込めていない linjunfeng end*/
  background-color: #0000;
  z-index: 2;
}
img.img-icon {
  cursor: pointer;
  /* #9771 FNWから取得したVisualLayoutが正しく取り込めていない linjunfeng start*/
  /* ベッドの図はかぶっているように見える */
  /* height: 1.5em;
  width: 1.5em; */
  height: 1em;
  width: 1em;
  /* #9771 FNWから取得したVisualLayoutが正しく取り込めていない linjunfeng end*/
}
.machine-athome {
  background-color: #0000;
}
.popover-size {
  padding: 0.5rem 1rem 0.5rem 0.5rem;
  font-size: 1.3em;
}
@media (max-height: 410px) {
  /* 高さが410px以下の場合に適用するスタイル */
  .tool-tip {
    transform: scale(1);
  }
}
@media (min-height: 411px) and (max-height: 450px) {
  /* 高さが411pxから450pxにて適用するスタイル */
  .tool-tip {
    transform: scale(1.1);
  }
}
@media (min-height: 451px) and (max-height: 550px) {
  /* 高さが451pxから550pxにて適用するスタイル */
  .tool-tip {
    transform: scale(1.2);
  }
}
@media (min-height: 551px) and (max-height: 679px) and (max-width: 320px) {
  /* 高さが551pxから679pxかつ横幅が320px以内に適用するスタイル */
  .tool-tip {
    transform: scale(1.2);
  }
}
@media (min-height: 551px) and (max-height: 679px) and (min-width: 321px) and (max-width: 419px) {
  /* 高さが551pxから679pxかつ横幅が321pxから420px以下に適用するスタイル */
  .tool-tip {
    transform: scale(1.28);
  }
}
@media (min-height: 551px) and (max-height: 679px) and (min-width: 420px) {
  /* 高さが551pxから679pxかつ横幅が420p以上に適用するスタイル */
  .tool-tip {
    transform: scale(1.45);
  }
}
@media (min-height: 680px) and (max-width: 320px) {
  /* 高さが680px以上かつ横幅が320px以内に適用するスタイル */
  .tool-tip {
    transform: scale(1.2);
  }
}
@media (min-height: 680px) and (min-width: 321px) and (max-width: 419px) {
  /* 高さが680px以上かつ横幅が321pxから420px以下に適用するスタイル */
  .tool-tip {
    transform: scale(1.28);
  }
}
@media (min-height: 680px) and (min-width: 420px) {
  /* 高さが680px以上かつ横幅が420p以上に適用するスタイル */
  .tool-tip {
    transform: scale(1.6);
  }
}
</style>
