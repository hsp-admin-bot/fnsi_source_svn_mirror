<template>
</template>
<script>
import { ApiHelper } from "@/apis/AxiosHelper";
import { EventBus } from "@/compat/vue/event-bus.js";
import { mapActions, mapGetters } from "@/compat/vue/vuex";

import { sendRequestGetMstFacilitySettingValue as getMstFacilitySettingValue } from "@/apis/facility-setting";
import {EXAM_SCHEDULE_CHANGE} from "@/constants/facilitySetting";
import {RAD_SCHEDULE_CHANGE} from "@/constants/facilitySetting";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { messageFormat } from '@/functions/common/MessageFormat';
import IndicationOwnerMixin from '@/components/indication/IndicationOwnerMixin';
import { getOnsAlertDialogFooterItems, getOnsAlertDialogFromEvent } from "@/functions/common/OnsenFunctions";
export default {
  mixins: [IndicationOwnerMixin],
  props: {
    patId: String,
    startDate: String,
    endDate: String
  },
  data() {
    return {
      oldOrdMainList: [],
      structData: null,
      patExamFlg: false,
      patExamCd: null,
      diaViewExam: false,
      messageExam: null,
      facilitySettingExamValue: null,
      patRadFlg: false,
      patRadCd: null,
      diaViewRad: false,
      messageRad: null,
      facilitySettingExamScheduleChangeLimitDay: 0,
      facilitySettingRadScheduleChangeLimitDay: 0,
      facilitySettingExamScheduleChangeLimitTime: 0,
      facilitySettingRadScheduleChangeLimitTime: 0,
      facilitySettingRadValue: null,
      examStatus: false,
      patEventFlg: false,
      patEventCd: null,
      diaViewEven: false,
      messageEvend: null,
      facilitySettingEventValue: null,
      examFLG: false,
      radFLG: false,
      allExam: null,
      allRad: null,
      sendJsonData: {},
      facilitySettingExamChangeOnOffWithOrder: null,
      facilitySettingRadChangeOnOffWithOrder: null,
      mstfacilitySettingRadValue: null,
      mstfacilitySettingExamValue: null,
      currentPatId: this.patId,
      examDeadlineSelectedVal: "",
      radDeadlineSelectedVal: "",
      msgCdList: [],
    };
  },
  mounted() {
    const ownerDocument = this.$el?.ownerDocument || document;
    ownerDocument.addEventListener('preshow', function(event) {
      const dialog = getOnsAlertDialogFromEvent(event);
      const buttons = getOnsAlertDialogFooterItems(dialog);
      if (buttons[0]) {
        buttons[0].style.display = 'flex';
      }
    });
  },
  computed: {
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("pat-viewer-modal", { settingIndData : "getSettingIndData" }),
    ...mapGetters("pat-info", ["selectedPat"]),
    ...mapGetters("pat-viewer", { ordNoList : "getOrdNoList", getExamMainData : "getExamMainData", getRadMainData : "getRadMainData"}),
  },
  watch: {
    selectedTreat() {}

    , patId: {
      handler(newVal) {
        this.currentPatId = newVal;
      },
      deep: true
    }
  },

  methods: {
    // 予実リストへの変更通知
    ...mapActions("indication-result", ["setResultUpdate"]),
    ...mapActions("notification-message", [
      "registerNotificationMessage"
    ]),
    ...mapActions("exam-request/list", ["setExamDeadline"]),
    ...mapActions("rad-request/list", ["setRadDeadline"]),
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "setLoadingScreenMessage",
      "startLoadingScreen",
      "finishLoadingScreen"
    ]),
    async updateIndInfo(structData) {
      console.log("IndPlanDelete.vue updateIndInfo this.startLoadingScreen();");
      this.startLoadingScreen();

      let response = await this.deleteIndInfo(structData);
      const data = response?.data;
      this.msgCdList = data?.msgCdList;
      const hasMsgCdList = Array.isArray(this.msgCdList) && this.msgCdList.length > 0;

      let cancelFlg = false;
      // 一般検査の処理を選択してください
      if (hasMsgCdList && this.msgCdList.includes("70000030") && !cancelFlg) {
        await this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[70000030].title,
          message: messageFormat(DIALOG_MESSAGES[70000030].message),
          buttonLabels: ["1", "2", "3"],
          callback: (answer) => {
            if (answer === 0) {
              this.facilitySettingExamValue = "1";
            } else if (answer === 1) {
              this.facilitySettingExamValue = "2";
            } else if (answer === 2) {
              this.facilitySettingExamValue = "3";
            }
          },
        });
      }
      // 一般検査の締切日が過ぎている予定移動があります
      if (hasMsgCdList && this.msgCdList.includes("70000033")
          && this.mstfacilitySettingExamValue != 3
          && this.facilitySettingExamValue != "3"
          && !cancelFlg
      ) {
        await this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[70000033].title,
          message: messageFormat(DIALOG_MESSAGES[70000033].message),
          callback: (answer) => {
            if (answer === 1) {
              this.examDeadlineSelectedVal = "OK";
            } else {
              cancelFlg = true;
            }
          },
        });
      }
      // X線検査の処理を選択してください
      if (hasMsgCdList && this.msgCdList.includes("70000031") && !cancelFlg) {
        await this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[70000031].title,
          message: messageFormat(DIALOG_MESSAGES[70000031].message),
          buttonLabels: ["1", "2", "3"],
          callback: (answer) => {
            if (answer === 0) {
              this.facilitySettingRadValue = "1";
            } else if (answer === 1) {
              this.facilitySettingRadValue = "2";
            } else if (answer === 2) {
              this.facilitySettingRadValue = "3";
            }
          },
        });
      }
      // 放射線検査の締切日が過ぎている予定移動があります
      if (hasMsgCdList && this.msgCdList.includes("70000034")
          && this.mstfacilitySettingRadValue != 3
          && this.facilitySettingRadValue != "3"
          && !cancelFlg
      ) {
        await this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[70000033].title,
          message: messageFormat(DIALOG_MESSAGES[70000033].message),
          callback: (answer) => {
            if (answer === 1) {
              this.radDeadlineSelectedVal = "OK";
            } else {
              cancelFlg = true;
            }
          },
        });
      }
      // 患者イベントの処理を選択してください
      if (hasMsgCdList && this.msgCdList.includes("70000032") && !cancelFlg) {
        await this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[70000032].title,
          message: messageFormat(DIALOG_MESSAGES[70000032].message),
          buttonLabels: ["1", "2", "3"],
          callback: (answer) => {
            if (answer === 0) {
              this.facilitySettingEventValue = "1";
            } else if (answer === 1) {
              this.facilitySettingEventValue = "2";
            } else if (answer === 2) {
              this.facilitySettingEventValue = "3";
            }
          },
        });
      }
      if (200 === response.status && undefined !== response.data.msgCd) {
        this._indicationDialogOwner().messageDialogInfo.messageCd = parseInt(
          response.data.msgCd
        );
        this._indicationDialogOwner().messageDialogInfo.type = "1";
        this._indicationDialogOwner().messageDialogInfo.stringParams = ["中止"];
        this._indicationDialogOwner().messageDialogInfo.isDialogVisible = true;
        this.finishLoadingScreen();
        return;
      }
      if ((this.msgCdList != null && this.msgCdList.length > 0) && !cancelFlg) {
        await this.updateIndInfo(structData);
      }
      if (cancelFlg) {
        this.facilitySettingExamValue = null;
        this.facilitySettingRadValue = null;
        this.facilitySettingEventValue = null;
      }

      EventBus.$emit("isRefresh");
      // 予実リストの更新
      this.setResultUpdate(new Date());
      this.finishLoadingScreen();
      // モーダルを閉じる
      this._hideIndicationModal();
    },
    async deleteIndInfo(structData){

      this.structData = structData;
      //データの収集
      const sendJson = {};
      // 患者ID
      sendJson.pat_id = structData.patId;
      // 治療開始日
      sendJson.start_date = structData.indStartDate;
      // 治療終了日
      sendJson.end_date = structData.indEndDate;
      // 治療終了日格納有無
      sendJson.is_deadline = structData.isDeadline;
      // 施設コード
      sendJson.facility_cd = structData.facilityCd;
      // 指示者コード
      sendJson.ind_user_id = structData.indUser;
      // 更新者コード
      sendJson.upd_user_id = structData.updUser;
      // 治療方法コード
      sendJson.treatment_cd = JSON.stringify(structData.selectedTreat);
      // クール方法コード
      sendJson.kur_cd = JSON.stringify(structData.selectedKur);

      sendJson.ord_no = this.settingIndData.ordNo;

      sendJson.del_list = [];

      this.currentPatId = structData.patId;

      await this.master(structData);

      sendJson.facilitySettingExamValue = this.facilitySettingExamValue;

      sendJson.facilitySettingRadValue = this.facilitySettingRadValue;

      sendJson.facilitySettingEventValue = this.facilitySettingEventValue;

      sendJson.examDeadlineSelectedVal = this.examDeadlineSelectedVal;

      sendJson.radDeadlineSelectedVal = this.radDeadlineSelectedVal;

      const response = await ApiHelper.post(
        "/mainData/deleteIndPlan",
        sendJson
      ).catch(error => {
        getErrorMessage('IndPlanDelete.vue', 'updateIndInfo', error);
        console.log("IndPlanDelete.vue updateIndInfo throw error; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        throw error;
      });

      return response;
    },
    async master(structData){
      this.facilityCd = structData.facilityCd;
      // 検査依頼
      await getMstFacilitySettingValue(this.facilityCd, EXAM_SCHEDULE_CHANGE)
            .then(response => {
              this.mstfacilitySettingRadValue = response.data;
            });
      // 一般撮影検査依頼
      await getMstFacilitySettingValue(this.facilityCd, RAD_SCHEDULE_CHANGE)
            .then(response => {
              this.mstfacilitySettingExamValue = response.data;
            });
    },
    /**
     * チェック処理
     */
    checkEdit() {
      return;
    }
  }
};
</script>

<style scoped></style>
