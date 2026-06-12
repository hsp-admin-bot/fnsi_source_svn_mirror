/** 治療予定移動 */
<template>
<!--  mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc start-->
<!--  <modal-base @onClose="hideModal">-->
  <modal-base @onClose="hideModal('hide-modal')">
<!--  mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc end-->
        <template #body>
<div class="indInfo-style-modal-container">
      <v-ons-row class="row-style">
        <v-ons-col class="col-style-right-title">
          <label>移動元 治療日</label>
        </v-ons-col>
        <v-ons-col class="col-style-left">
          <label>{{ dispTreatDate }}</label>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="row-style">
        <v-ons-col class="col-style-right">
        </v-ons-col>
        <v-ons-col class="col-style-left">
          <label>治療方法&ensp;:&ensp;{{ dispTreatmethod }}</label>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="row-style">
        <v-ons-col class="col-style-right">
        </v-ons-col>
        <v-ons-col class="col-style-left">
          <label>クール&emsp;&ensp;:&ensp;{{ dispKur }}</label>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="row-style">
        <v-ons-col class="col-style-right">
        </v-ons-col>
        <v-ons-col class="col-style-left">
          <label>ベッド&emsp;&ensp;:&ensp;{{ dispBed }}</label>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="row-style">
        <v-ons-col class="col-style-right">
          <label style="font-weight:bold;">&emsp;&emsp;&emsp;↓&emsp;&emsp;&emsp;</label>
        </v-ons-col>
        <v-ons-col class="col-style-left">
          <label style="font-weight:bold;">&emsp;&emsp;&emsp;↓&emsp;&emsp;&emsp;</label>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="row-style">
        <v-ons-col class="col-style-right-title">
          <label>移動先 治療日</label>
        </v-ons-col>
        <v-ons-col class="col-style-left">
          <!-- mod FNSI-横展開--inputの色 関 start -->
          <!-- <input
            v-model="selectedDialysisDate"
            type="date"
            class="date-input common-style-input ntss-input-date"
            :max="maxDate"
            :min="minDate"
          /> -->
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <input -->
          <!--   v-model="selectedDialysisDate" -->
          <!--   id="date-move" -->
          <!--   type="date" -->
          <!--   class="date-input common-style-input ntss-input-date date-move-input" -->
          <!--   :max="maxDate" -->
          <!--   :min="minDate" -->
          <!--   @blur="delFocusCss($event)" -->
          <!--   @focus="addFocusCss($event)" -->
          <!--   :class="classObject" -->
          <!-- /> -->
          <date-input
            v-model="selectedDialysisDate"
            id="date-move"
            class="date-input common-style-input ntss-input-date date-move-input"
            classes="date-input-required date-input-unjust-size date-input-focus"
            :max="maxDate"
            :min="minDate"
            :class="classObject"
            :disabled="!getItemAuthorized('Indication', 'item_paln_move_date')"
            @focus="beforeDialysisDate = selectedDialysisDate"
            @blur="onBlurDialysisDate"
            isRequired
            defaultEmpty
          />
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <!-- mod FNSI-横展開--inputの色 関 end -->
          <!-- mod FNSI-障害票一覧_患者経過総合ビューアNo.22-27 李 start -->
          <!-- <custom-calendar
            v-model="selectedDialysisDate"
          /> -->
          <!-- #10748 患者経過総合ビューアで治療終了と実績確定をベッド，クールが未登録で移動可能 linjunfeng start -->
          <!-- <custom-calendar
            v-model="selectedDialysisDate"
            :disable-dates-after="disableDatesAfter"
          /> -->
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <custom-calendar -->
          <!--   v-model="selectedDialysisDate" -->
          <!--   :disable-dates-after="disableDatesAfter" -->
          <!--   :disabled="rstDialysisStateFlg" -->
          <!-- /> -->
          <custom-calendar
            v-model="calendarDialysisDate"
            :disable-dates-after="disableDatesAfter"
            :disabled="!getItemAuthorized('Indication', 'item_paln_move_date')"
          />
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <!-- #10748 患者経過総合ビューアで治療終了と実績確定をベッド，クールが未登録で移動可能 linjunfeng end -->
          <!-- mod FNSI-障害票一覧_患者経過総合ビューアNo.22-27 李 end -->
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="row-style">
        <v-ons-col class="col-style-right">
        </v-ons-col>
        <v-ons-col class="col-style-left">
          <label>治療方法&ensp;:&ensp;{{ dispTreatmethod }}</label>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="row-style">
        <v-ons-col class="col-style-right">
        </v-ons-col>
        <v-ons-col class="col-style-left">
          <label>クール&emsp;&ensp;:&ensp;</label>
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-select v-model="selectKurCd"> -->
          <v-ons-select v-model="selectKurCd" :disabled="!getItemAuthorized('Indication', 'item_schedule')">
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
            <option
              v-for="(item, index) in dispKurList"
              :key="index"
              :value="item.kurCd"
            >
              {{ item.kurName }}
            </option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="row-style">
        <v-ons-col class="col-style-right">
        </v-ons-col>
        <v-ons-col class="col-style-left">
          <label>ベッド&emsp;&ensp;:&ensp;</label>
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-select v-model="selectBedCd"> -->
          <v-ons-select v-model="selectBedCd" :disabled="!getItemAuthorized('Indication', 'item_schedule')">
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
            <option
              v-for="(item, index) in dispBedList"
              :key="index"
              :value="item.bedCd"
            >
              {{ item.bedName }}
            </option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>
      <!-- mod 7579 【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧　start -->
      <!--redmine 4672  姜 start-->
      <!-- <div v-if="messageDeviceModeDialogInfo.isDialogVisible">
        <message-dialog
          v-model:visible="messageDeviceModeDialogInfo.isDialogVisible"
          :message-cd="messageDeviceModeDialogInfo.messageCd"
          :type="messageDeviceModeDialogInfo.type"
          :string-params="messageDeviceModeDialogInfo.stringParams"
          @confirm="confirmDeviceModeCancel"
        />
      </div>

      <div v-if="messageVaDialogInfo.isDialogVisible">
        <message-dialog
          v-model:visible="messageVaDialogInfo.isDialogVisible"
          :message-cd="messageVaDialogInfo.messageCd"
          :type="messageVaDialogInfo.type"
          :string-params="messageVaDialogInfo.stringParams"
          @confirm="confirmVaCancel"
        />
      </div>
      <div v-if="messageInfDialogInfo.isDialogVisible">
        <message-dialog
          v-model:visible="messageInfDialogInfo.isDialogVisible"
          :message-cd="messageInfDialogInfo.messageCd"
          :type="messageInfDialogInfo.type"
          :string-params="messageInfDialogInfo.stringParams"
          @confirm="confirmInfCancel"
        />
      </div> -->
      <!--redmine 4672  姜  end -->
      <div v-if="messageFuicchiDialogInfo.isDialogVisible">
        <message-dialog
          v-model:visible="messageFuicchiDialogInfo.isDialogVisible"
          :message-cd="messageFuicchiDialogInfo.messageCd"
          :type="messageFuicchiDialogInfo.type"
          :string-params="messageFuicchiDialogInfo.stringParams"
          :title="messageFuicchiDialogInfo.title"
          @confirm="confirmInfCancel"
        />
      </div>
      <!-- mod 7579 【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧　end -->
      <div v-if="messageDialogInfo.isDialogVisible">
        <message-dialog
          v-model:visible="messageDialogInfo.isDialogVisible"
          :message-cd="messageDialogInfo.messageCd"
          :type="messageDialogInfo.type"
          :string-params="messageDialogInfo.stringParams"
          @confirm="confirmResult"
        />
      </div>
    </div>
    </template>

        <template #footer>
<div class="in-ind-dropdown-area">
      <v-ons-row class="row-style-footer">
        <v-ons-col style="text-align: end; padding-right: 10px; margin: auto;">
          <label>指示者</label>
        </v-ons-col>
        <v-ons-col width="170px">
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <kendo-dropdownlist -->
          <!--   v-model="indUser" -->
          <!--   :data-source="userOptions" -->
          <!--   :data-text-field="'fullName'" -->
          <!--   :data-value-field="'user_id'" -->
          <!--   style="width: 100%;" -->
          <!--   class="common-style-input select-style-list"> -->
          <!-- </kendo-dropdownlist> -->
          <kendo-dropdownlist
            v-model="indUser"
            :data-source="userOptions"
            :data-text-field="'fullName'"
            :data-value-field="'user_id'"
            style="width: 100%;"
            class="common-style-input select-style-list"
            :disabled="!getItemAuthorized('Indication', 'item_schedule')"
            @open="onIndUserDropdownOpen"
          />
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="row-style-footer">
        <v-ons-col>
          <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
          <!-- <v-ons-button
            class="common-style-cancel-button"
            style="float: left;"
            @click="hideModal()"
          >
            キャンセル
          </v-ons-button> -->
<!--          mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start-->
<!--          <v-ons-button-->
<!--            class="btn2-cancel width-padding"-->
<!--            style="float: left;"-->
<!--            @click="hideModal()"-->
<!--          >-->
          <v-ons-button
            class="btn2-cancel width-padding"
            style="float: left;"
            @click="hideModal('hide-modal')"
          >
<!--            mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end-->
            キャンセル
          </v-ons-button>
          <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
        </v-ons-col>

        <v-ons-col>
          <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
          <!-- <v-ons-button
            class="common-style-ok-button"
            style="float: right;"
            @click="updateInfo()"
          >
            保存
          </v-ons-button> -->
<!--          mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start-->
<!--          <v-ons-button-->
<!--            class="btn1-execute width-padding"-->
<!--            style="float: right;"-->
<!--            @click="updateInfo()"-->
<!--          >-->
          <!-- mod #10553   start -->
<!--          <v-ons-button-->
<!--            class="btn1-execute width-padding"-->
<!--            style="float: right;"-->
<!--            :disabled="!isChanged"-->
<!--            @click="updateInfo()"-->
<!--          >-->
            <v-ons-button
              class="btn1-execute width-padding"
              style="float: right;"
              :disabled=false
              @click="updateInfo2()"
            >
            <!-- mod #10553   end -->
<!--          mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end-->
            保存
          </v-ons-button>
          <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
        </v-ons-col>
      </v-ons-row>

    </div>
    </template>
  </modal-base>
</template>
<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { ApiHelper } from "@/apis/AxiosHelper";
/**
 * Vue関連
 */
import { mapGetters, mapActions } from "@/compat/vue/vuex";

import CustomCalendar from "@/components/common/custom-calendar/CustomCalendar";

/**
 * 日付操作
 */
import dayjs from "@/compat/date/dayjs";
import { dateFormat, fitTermCheckForUpdate } from "@/functions/common/DateTimeUtils";

/**
 * メッセージダイアログ
 */
import messageDialog from "@/components/common/message-dialog/MessageDialog";

import ModalBase from "@/components/modals/ModalBase";

/**
 * 指示者関連
 */
import { AUTHORITY_CODES } from "@/constants/userAuthority";

import IndUserSelectMixin from "@/components/common/IndUserSelectMixin";


// 426 姜 start
/**
 * 施設設定番号
 */









import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
// 426 姜 end

//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
import { isProcSuccess } from "@/functions/common/ApiResponseFunctions";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
// add #10748 患者経過総合ビューアで治療終了と実績確定をベッド，クールが未登録で移動可能 linjunfeng start
import { CODES } from "@/constants/TreatmentRecord.js";
import { getScopedElementById, getScopedElementsByClassName } from "@/functions/common/LayoutMeasureHelper";
import { getOnsAlertDialogFooterItems, getOnsAlertDialogFromEvent } from "@/functions/common/OnsenFunctions";
// add #10748 患者経過総合ビューアで治療終了と実績確定をベッド，クールが未登録で移動可能 linjunfeng end
import DateInput from "@/components/common/DateInput";
export default {
  //mod FNSI-No.IES145 権限対応  吉 start
  // mixins: [IndUserSelectMixin],
  // mod #10359 編集権限の動作不正 dengshen start
  // mixins: [IndUserSelectMixin,UserAuthorityMixin],
  mixins: [IndUserSelectMixin],
  // mod #10359 編集権限の動作不正 dengshen end
  //mod FNSI-No.IES145 権限対応  吉 end

  components: {
    "custom-calendar": CustomCalendar,
    "message-dialog": messageDialog,
    ModalBase,
    "date-input": DateInput,
  },

  props: {
    /**
     * 施設コード
     */
    propFacilityCd: {
      type: String,
      required: true
    },

    /**
     * 患者ID
     */
    propPatId: {
      type: Number,
      required: true
    },

    /**
     * オーダー番号
     */
    propOrdNo: {
      type: Number,
      required: true
    },

    /**
     * 表示する日付
     */
    propDialysisDate: {
      type: String,
      required: true
    }
  },

  data() {
    return {
      // 426 姜 start
      patEventFlg: false,
      patEventCd: null,
      diaViewEven: false,
      messageEvend: null,
      facilitySettingEventValue: "",
      // 426 姜 end
      // 425 姜 start
      patExamFlg: false,
      patExamCd: null,
      diaViewExam: false,
      messageExam: null,
      facilitySettingExamValue: "",
      facilitySettingExamFlg: true,
      patRadFlg: false,
      patRadCd: null,
      diaViewRad: false,
      messageRad: null,
      facilitySettingExamScheduleChangeLimitDay: 0,
      facilitySettingRadScheduleChangeLimitDay: 0,
      facilitySettingExamScheduleChangeLimitTime: 0,
      facilitySettingRadScheduleChangeLimitTime: 0,
      facilitySettingRadValue: "",
      facilitySettingRadFlg: true,
      examStatus: false,
      radStatus: false,
      // 425 姜 end
      // redmine 4672  姜 start
      bedCd: null,
      // redmine 4672  姜 end
      /**
       * 指示者リスト格納
       */
      userOptions: [],
      /**
       * 選択支持者
       */
      indUser: null,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
      initIndUser: null,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
      /**
       * 参照元で画面更新を行うかどうかのフラグ
       * @summary 更新を行うかどうかは参照元画面で判断
       */
      isRefresh: false,
      /**
       * 施設コード
       */
      facilityCd: this.propFacilityCd,
      /**
       * 患者ID
       */
      patId: this.propPatId,
      /**
       * オーダー番号
       */
      ordNo: this.propOrdNo,
      /**
       * 表示用治療日
       */
      dispDialysisDate: this.propDialysisDate,
      /**
       * 選択治療日
       */
      selectedDialysisDate: "",
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
      initSelectedDialysisDate: "",
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end

      /**
       * 治療方法表示文字
       */
      dispTreatmethod: "",
      /**
       * クール表示文字
       */
      dispKur: "",
      /**
       * ベッド表示文字
       */
      dispBed: "",

      /**
       * 選択したクールコード
       */
      selectKurCd: 0,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
      initSelectKurCd: 0,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
      /**
       * クールリスト
       * { kurCd: 0, kurName: "午前" }
       */
      dispKurList: [],

      /**
       * 選択したベッドコード
       */
      selectBedCd: 0,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
      initSelectBedCd: 0,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
      /**
       * ベッドリスト(施設内の全ベッド)
       * { bedCd: 0, bedName: "ベッド１" }
       */
      bedListAll: [],
      /**
       * ベッドリスト
       * { bedCd: 0, bedName: "ベッド１" }
       */
      dispBedList: [],
      // redmine 4672  姜 start
      deviceModeMismatchMsgFlg: false,
      vaDirectionInconsistentMsgFlg: false,
      infectionNotConsistentMsgFlg: false,
      //mod 7579 【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧　start
      // messageDeviceModeDialogInfo: {
      //   isDialogVisible: false,
      //   messageCd: "70000002",
      //   type: "2",
      //   stringParams: ["治療方法"]
      // },
      // messageVaDialogInfo: {
      //   isDialogVisible: false,
      //   messageCd: "70000002",
      //   type: "2",
      //   stringParams: ["シャント位置"]
      // },
      // messageInfDialogInfo: {
      //   isDialogVisible: false,
      //   messageCd: "70000002",
      //   type: "2",
      //   stringParams: ["感染症"]
      // },
      // redmine 4672  姜 end
      messageFuicchiDialogInfo: {
        isDialogVisible: false,
        messageCd: "70000002",
        type: "2",
        stringParams: []
      },
      //mod 7579 【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧　end
      /**
       * メッセージダイアログ情報
       */
      messageDialogInfo: {
        isDialogVisible: false,
        messageCd: "22010001",
        type: "1",
        stringParams: []
      },

      /**
       * スタイル
       */
      styleObj: { "max-width": "370px", width: "370px" },

      // add FNSI-障害票一覧_患者経過総合ビューアNo.68,69 李 start
      examMainDataFlg: false,
      radMainDataFlg: false,
      // add FNSI-障害票一覧_患者経過総合ビューアNo.68,69 李 end
      // add #10748 患者経過総合ビューアで治療終了と実績確定をベッド，クールが未登録で移動可能 linjunfeng start
      rstDialysisState: 0,
      rstDialysisStateFlg: false,
      // add #10748 患者経過総合ビューアで治療終了と実績確定をベッド，クールが未登録で移動可能 linjunfeng end
      // add #10553 start
      oldIndKurCd : 0,
      oldIndBedCd : 0,
      oldTreatDate : null,
      diaViewEvenFlag: true,
      // add #10553 end
      // add #11038 患者経過総合ビューア－予定移動画面 メッセージダイアログのタイトルがない 関 start
      msgCd: "",
      msgCdList: [],
      examDeadlineCancelCheck: "",
      radDeadlineCancelCheck: "",
      examDeadlineSelectedVal: "",
      radDeadlineSelectedVal: "",
      // add #11038 患者経過総合ビューア－予定移動画面 メッセージダイアログのタイトルがない 関 end
      // 変更前 移動先治療日
      beforeDialysisDate: "",
      // custom-calendar用 移動先治療日がカレンダーから選択されたかを判別可能とする
      calendarDialysisDate: "",
    };
  },
  // 425 姜 start
  mounted() {
    //add FNSI-No.IES145 権限対応  吉 start
    this.authorityCds = [ AUTHORITY_CODES.SCHE_MOVE];
    // add #11038 患者経過総合ビューア－予定移動画面 メッセージダイアログのタイトルがない 関 start
    this.treatPlanMoveOwnerDocument = this.$el?.ownerDocument || document;
    this.treatPlanMovePreshowHandler = function(event) {
      const dialog = getOnsAlertDialogFromEvent(event);
      const buttons = getOnsAlertDialogFooterItems(dialog);
      if (buttons[0]) {
        buttons[0].style.display = 'flex';
      }
    };
    this.treatPlanMoveOwnerDocument.addEventListener('preshow', this.treatPlanMovePreshowHandler);
    // add #11038 患者経過総合ビューア－予定移動画面 メッセージダイアログのタイトルがない 関 end
  },
  // 425 姜 end
    beforeUnmount() {
    this.treatPlanMoveOwnerDocument?.removeEventListener?.('preshow', this.treatPlanMovePreshowHandler);
    this.treatPlanMoveOwnerDocument = null;
    this.treatPlanMovePreshowHandler = null;
  },
  computed: {
    // mod FNSI-障害票一覧_患者経過総合ビューアNo.68,69 李 start
    // ...mapGetters("pat-viewer", ["getMstTreatmentData", "getMstKurData", "getMstBedData"]),
          //add 5619 装置と紐づいていないベッドも表示 張 start
    // ...mapGetters("pat-viewer", ["getMstTreatmentData", "getMstKurData", "getMstBedData", "getExamMainData", "getRadMainData"]),
    ...mapGetters("pat-viewer", ["getMstTreatmentData", "getMstKurData", "getMstBedData", "getExamMainData", "getRadMainData","getBedAndMachine"]),
      //add 5619 装置と紐づいていないベッドも表示 張 end
    // mod FNSI-障害票一覧_患者経過総合ビューアNo.68,69 李 end
    ...mapGetters("pat-info", ["selectedPat"]),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("pat-viewer-modal", { settingIndData: "getSettingIndData" }),
    //9273 start
    ...mapGetters("exam-request/list", ["getDeadlineCondition"]),
    ...mapGetters("rad-request/list", { getRadDeadlineCondition: "getDeadlineCondition" }),
    ...mapGetters("user", ["getFacilityCd"]),
    //9273 start
    /**
     * 治療方法マスタ
     */
    mstTreamentData() {
      return this.getMstTreatmentData;
    },

    /**
     * クール方法マスタ
     */
    mstKurData() {
      return this.getMstKurData;
    },

    /**
     * ベッドマスタ
     */
    mstBedData() {
      //mod 5619 装置と紐づいていないベッドも表示 張 start
      // return this.getMstBedData;
      return this.getBedAndMachine;
      //mod 5619 装置と紐づいていないベッドも表示 張 end
    },

    /**
     * 表示治療日
     */
    dispTreatDate() {
      const dispStr = dayjs(this.dispDialysisDate, "YYYY-MM-DD").format(
        "YYYY/MM/DD(ddd)"
      );
      return dispStr;
    },

    /**
     * 移動先治療日の最大日(本日から一年未満)
     */
    maxDate() {
      const day = dayjs().format("YYYYMMDD");
      // 一年後に最大日を設定
      let endMaxDate = this.schExtEndDate
        ? dayjs(this.schExtEndDate, "YYYYMMDD")
        : dayjs(day).add(1, "year");
      endMaxDate = dayjs(endMaxDate).endOf("month");
      return dayjs(endMaxDate).format("YYYY-MM-DD");
    },

    /**
     * 指定日以降編集不可
     */
    disableDatesAfter() {
      return dayjs(this.maxDate).format("YYYYMMDD");
    },

    /**
     * 移動日先治療日の最小日(本日)
     */
    minDate() {
      return dayjs().format("YYYY-MM-DD");
    },

    /**
     * スケジュール自動延長最終日
     */
    schExtEndDate() {
      // TODO: 自動延長の実行タイミングによりデータ不一致が発生する可能性がある
      return this.selectedPat.pat_main.sch_ext_end_date;
    },
    // mod FNSI-横展開--inputの色 関 start
    classObject() {
      return {
        // 編集時に適用されるclass
        "custom-input-edited": false,
      };
    },
    // mod FNSI-横展開--inputの色 関 end
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
    isChanged() {
      return this.initSelectedDialysisDate !== JSON.stringify(this.selectedDialysisDate) ||
          this.initSelectKurCd !== JSON.stringify(this.selectKurCd) ||
          this.initSelectBedCd !== JSON.stringify(this.selectBedCd);
    }
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
  },

  watch: {
    calendarDialysisDate(value) {
      this.selectedDialysisDate = value;

      // 選択治療日が空の場合もしくはコピー先治療日の変更の場合処理終了
      if (null === value || "" === value) {
        return;
      }else{
        this.setDateMoveBackground("#ffff99");
      }
      // 選択治療日が1年後よりも後に行かないよう制御
      const maxDate = parseInt(dayjs(this.maxDate).format("YYYYMMDD"));
      const date = parseInt(dayjs(value).format("YYYYMMDD"));
      if (date > maxDate) {
        this.calendarDialysisDate = this.maxDate;
        return;
      }

      // クールを未登録に変更する
      this.selectKurCd = 0;
      // 選択日の治療予定を全件取得(空きベッド候補表示用)
      this.setOrdSchList(value);
    },

    selectKurCd(value) {
      // クール選択時にベッドドロップダウンに空きベッド候補を表示
      // クール変更時にはベッドを一度未登録に変更する
      this.selectBedCd = 0;
      if (value === 0) {
        // クール未登録 → 全ベッドを候補に表示
        this.dispBedList = this.bedListAll;
      } else {
        // 対象クールで予定がないベッドのみを表示
        this.dispBedList = this.bedListAll.filter(bed =>
          !this.ordSchList?.some(sch =>
            bed.bedCd === sch.bedCd && sch.kurCd === value
          )
        )
      }
    }
  },

  async created() {
    // 指示者リスト作成
    //mod FNSI-No.IES145 権限対応  吉 start
    // this.getIndUserList(AUTHORITY_CODES.IND_EDIT, AUTHORITY_CODES.IND_PEDIT)
    // mod #10359 編集権限の動作不正 dengshen start
    // this.getIndUserList(AUTHORITY_CODES.SCHE_MOVE, AUTHORITY_CODES.SCHE_MOVE)
    this.getIndUserList(AUTHORITY_CODES.IND_EDIT, AUTHORITY_CODES.IND_PEDIT)
    // mod #10359 編集権限の動作不正 dengshen end
      //mod FNSI-No.IES145 権限対応  吉 end
    .then(response => {
      this.userOptions = response.doctorList;
      this.$nextTick(() => {
        this.indUser = response.iniSelectId;
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
        this.initIndUser = this.indUser;
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
        // 表示領域の調整
        const dropdownArea = getScopedElementsByClassName("in-ind-dropdown-area", this.$el || null)[0];
        dropdownArea?.parentElement?.parentElement && (dropdownArea.parentElement.parentElement.style.height = "calc(5rem + 1em)");
      });
    });
    // add #10748 患者経過総合ビューアで治療終了と実績確定をベッド，クールが未登録で移動可能 linjunfeng start
    const responseOrdMain = await ApiHelper.get(`/mainData/getOrdMainByOrdNo/${this.ordNo}`)
    this.rstDialysisState = responseOrdMain.data.rstDialysisState;
    const rstDialysisStateArr = [
        CODES.DIALYSIS_STATE.AFTER_DRAINAGE.cd,
        CODES.DIALYSIS_STATE.AFTER_WEIGHT_MEASURING.cd,
        CODES.DIALYSIS_STATE.CONFIRMED_WEIGHT_MEASURING.cd
      ];
    if (rstDialysisStateArr.includes(this.rstDialysisState)) {
      this.rstDialysisStateFlg = true;
      this.selectedDialysisDate = this.dispTreatDate;
    }
    // add #10748 患者経過総合ビューアで治療終了と実績確定をベッド，クールが未登録で移動可能 linjunfeng end
    // add #10553 start
    this.oldIndKurCd = responseOrdMain.data.indKurCd;
    this.oldIndBedCd = responseOrdMain.data.indBedCd;
    this.oldTreatDate = responseOrdMain.data.treatDate;
    // add #10553 end
    // 移動元治療日の治療方法&クール表示文字列取得
    this.setDispTreatmentAndKur(this.dispDialysisDate);
    // add #10359 編集権限の動作不正 dengshen start
    // 移動先治療日表示文字列取得
    if (!this.getItemAuthorized('Indication', 'item_paln_move_date')) {
      this.selectedDialysisDate = this.dispDialysisDate;
    }
    // add #10359 編集権限の動作不正 dengshen end
    // 締切設定を取得
    //9273 add ljx start
    this.setExamDeadline(this.getFacilityCd);
    this.setRadDeadline(this.getFacilityCd);
    //9273 add ljx end
    // 表示用クールリスト作成
    const objKurNon = { kurCd: 0, kurName: "未登録"};
    this.dispKurList = [objKurNon, ...this.mstKurData];


    // 表示用ベッドリスト作成
    const objBedNon = { bedCd: 0, bedName: "未登録"};
    this.bedListAll = [objBedNon, ...this.mstBedData];
    this.dispBedList = this.bedListAll;

    // 426 姜 start
    const sendJson = {};
    sendJson.facilityCd = this.facilityCd;
    sendJson.patId = this.patId;
    sendJson.eventStartDate = dayjs(this.dispDialysisDate).format("YYYYMMDD");
    ApiHelper.post(`/pat_event/mainData/selectDateByCd/${sendJson.facilityCd}/${sendJson.patId}/${sendJson.eventStartDate}`)
        //成功した場合の処理
        .then(response => {
          //ストアへデータをセット
          if (response.data.length > 0) {
            this.patEventFlg = true;

            // mod FNSI-FutreNetWeb+SI課題管理No.4710 李 start
            this.patEventCd = response.data;
            // mod FNSI-FutreNetWeb+SI課題管理No.4710 李 end

          }
            // add 9273 start
            ApiHelper.post(`/pat_event/mainData/selectDateByOrdNo/${sendJson.facilityCd}/${sendJson.patId}/${sendJson.eventStartDate}/${this.ordNo}`).then(response => {
              //ストアへデータをセット
              if (response.data.length > 0) {
                this.patEventFlg = true;
                if (this.patEventCd) {
                  response.data.forEach(item =>{
                    this.patEventCd.push(item);
                  });
                } else {
                  this.patEventCd = response.data;
                }
              }
            })
              .catch(err => {
                //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
                getErrorMessage('TreatPlanMove.vue', 'created', err);
                //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
                err;
              });
            // add 9273 end
        })
        .catch(err => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('TreatPlanMove.vue', 'created', err);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          err;
        });
    // 426 姜 end

    // 425 姜 start
    
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
    this.initSelectedDialysisDate = JSON.stringify(this.selectedDialysisDate);
    this.initSelectKurCd = JSON.stringify(this.selectKurCd);
    this.initSelectBedCd = JSON.stringify(this.selectBedCd);
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
},

  methods: {
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "setLoadingScreenMessage",
      "startLoadingScreen",
      "finishLoadingScreen"
    ]),
    // 予実リストへの変更通知
    ...mapActions("indication-result", ["setResultUpdate"]),
    //FNSI-修正 #5525 横展開対応、xugj add start
    ...mapActions("treatment-record/common",
      [
        "getMstMachineByOrdNoRst",
        "sendNextPatInfoViewer"
      ]),
    //FNSI-修正 #5525 横展開対応、xugj add end
    ...mapActions("exam-request/list", ["setExamDeadline"]),
    ...mapActions("rad-request/list", ["setRadDeadline"]),
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    getDateMoveInput() {
      return getScopedElementById("date-move", this.$el || null);
    },
    setDateMoveBackground(background) {
      const dateMoveInput = this.getDateMoveInput();
      if (dateMoveInput?.style) {
        dateMoveInput.style.setProperty("background", background, "important");
      }
    },
    /**
     * モーダルを閉じる
     */
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
    // hideModal() {
    hideModal(type) {
      if (this.isChanged && type === 'hide-modal') {
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: answer => {
            if (answer === 1) {
              // モーダル閉じる
              this.$emit("hide-modal");
            }
          }
        });
      }else {
        // モーダル閉じる
        this.$emit("hide-modal");
      }
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
    },

    // add #10553   start
    async updateInfo2() {
      // 入力漏れチェック
      if (!this.checkInputLeak()) {
        return;
      }
      this.startLoadingScreen();
      const paramCheckFuicchi = await this.checkFuicchi();
      if (paramCheckFuicchi) {
        let outMsg = "";
        if (this.infectionNotConsistentMsgFlg) {
          outMsg += "感染症";
        }
        if (!this.vaDirectionInconsistentMsgFlg) {
          if (outMsg !== "") {
            outMsg += "・";
          }
          outMsg += "VA位置";
        }
        if (this.deviceModeMismatchMsgFlg) {
          if (outMsg !== "") {
            outMsg += "・";
          }
          outMsg += "治療方法";
        }
        const dispStr = outMsg;
        this.messageFuicchiDialogInfo.stringParams = [dispStr];
        this.messageFuicchiDialogInfo.title = "ベッド条件不一致";
        this.messageFuicchiDialogInfo.messageCd = parseInt("70000002");
        this.messageFuicchiDialogInfo.type = "2";
        this.messageFuicchiDialogInfo.isDialogVisible = true;
        this.finishLoadingScreen();
        return;
      } else {
        this.updateInfoOperation();
        this.finishLoadingScreen();
      }
    },

    async updateInfoOperation() {

      // 共通ローダー表示
      this.startLoadingScreen("保存中...");
      // 期限切れ確認
      if (!await this.chkInExpiryDate(this.selectedDialysisDate)) {
        return;
      }
      this.updateDBInfo();
      this.finishLoadingScreen();
      return;
    },
    // mod #11038 患者経過総合ビューア－予定移動画面 メッセージダイアログのタイトルがない 関 start
    async updateDBInfo() {

      let patEventCdListTmp = this.patEventCd ? this.patEventCd.filter(item => item.ordNo === null || item.ordNo === this.ordNo) : [];
      if (this.patEventFlg && patEventCdListTmp && patEventCdListTmp.length > 0) {
        const dataNumber =  (this.stringToDate(this.selectedDialysisDate) - this.stringToDate(this.dispDialysisDate)) / (24*60*60*1000);
        this.dataNumber = dataNumber;
        if (this.facilitySettingEventValue == "4" && this.diaViewEvenFlag) {
          this.diaViewEven = true;
          this.diaViewEvenFlag = false ;
          return;
        }
      }

      let beforeIndScheduleInfo = {
        facilityCd: this.facilityCd,
        ordNo : this.ordNo,
        patId : this.patId,
        indBedCd : this.oldIndBedCd,
        indKurCd : this.oldIndKurCd,
        treatDate : this.oldTreatDate
      }
      let afterIndScheduleInfo = {
        facilityCd: this.facilityCd,
        ordNo : null,
        patId : null,
        indBedCd : this.selectBedCd,
        indKurCd : this.selectKurCd,
        treatDate : this.selectedDialysisDate?.replaceAll("-", "")
      }

      let beforeIndScheduleInfoList = [];
      let afterIndScheduleInfoList = [];
      afterIndScheduleInfoList.push(afterIndScheduleInfo);
      beforeIndScheduleInfoList.push(beforeIndScheduleInfo);

      this.startLoadingScreen();
      const param = {
        facilityCd: this.facilityCd,
        indUserId: parseInt(this.indUser),
        updUserId: this.getStateUserAccountInfo.userId,
        beforeIndScheduleInfoList: beforeIndScheduleInfoList,
        afterIndScheduleInfoList: afterIndScheduleInfoList,
        indscheduleChangeUserSelectedInfo:{
          facilitySetting1007SelectedVal: this.facilitySettingExamValue,
          facilitySetting1008SelectedVal: this.facilitySettingRadValue,
          facilitySetting3005SelectedVal: this.facilitySettingEventValue,
          examDeadlineSelectedVal: this.examDeadlineSelectedVal,
          radDeadlineSelectedVal: this.radDeadlineSelectedVal,
          updateRst: "OK",
        }
      };

        const response = await ApiHelper.post("/mainData/moveTreatPlan2", param)
        .catch((error) => {
          getErrorMessage(
            "TreatPlanMove.vue",
            "updateDBInfo",
            error
          );
          throw(error);
        });
        const data = response?.data;
        if (isProcSuccess(data)) {
            if (data.hasDoCancel) {
              // メッセージ表示
              this.showMessage(22010006, "移動", "1");
              this.finishLoadingScreen();
              }else {
              // 参照元画面更新フラグをON
              this.isRefresh = true;
              // 予実リストの更新
              this.setResultUpdate(new Date());
              // モーダルを閉じる
              this.finishLoadingScreen();
              // モーダルを閉じる
              this.hideModal();
            }
        } else {
          this.msgCdList = data?.msgCdList;
          this.msgCd = data?.msgCd;
          this.examDeadlineCancelCheck = "";
          this.radDeadlineCancelCheck = "";
          this.examDeadlineSelectedVal = "";
          this.radDeadlineSelectedVal = "";
          if (this.msgCd != null && this.msgCd.includes("70000001")) {
            await this.$ons.notification.confirm({
              title: DIALOG_MESSAGES[70000001].title,
              message: messageFormat(DIALOG_MESSAGES[70000001].message),
              buttonLabels: ["OK"],
            });
          }
          if (this.msgCd != null && this.msgCd.includes("12000212")) {
            await this.$ons.notification.confirm({
              title: DIALOG_MESSAGES[12000212].title,
              message: messageFormat(DIALOG_MESSAGES[12000212].message),
              buttonLabels: ["OK"],
            });
          }
          if (this.msgCd != null && this.msgCd.includes("70000008")) {
            await this.$ons.notification.confirm({
              title: DIALOG_MESSAGES[70000008].title,
              message: messageFormat(DIALOG_MESSAGES[70000008].message),
              buttonLabels: ["OK"],
            });
          }
          if (this.msgCd != null && this.msgCd.includes("22020005")) {
            await this.$ons.notification.confirm({
              title: DIALOG_MESSAGES[22020005].title,
              message: messageFormat(DIALOG_MESSAGES[22020005].message),
              buttonLabels: ["OK"],
            });
          }
          if (this.msgCd != null && this.msgCd.includes("12000060")) {
            await this.$ons.notification.confirm({
              title: "",
              message: "複数件の実績あり予定は操作できません。",
              buttonLabels: ["OK"],
            });
          }
          // 移動できない場合は続行しない
            if (this.msgCd == null && this.msgCdList.length == 0) {
              let message = data?.message;
               await this.$ons.notification.confirm({
              title: "",
              message: message,
              buttonLabels: ["OK"],
            });
          }
          if (this.msgCd == null && this.msgCdList.length > 0) {
            if (this.msgCdList.includes("70000030")) {
              await this.$ons.notification.confirm({
                title: DIALOG_MESSAGES[70000030].title,
                message: messageFormat(DIALOG_MESSAGES[70000030].message),
                buttonLabels: ["1", "2", "3"],
                callback: (answer) => {
                  if (answer === 0) {
                    this.facilitySettingExamValue = 1;
                  } else if (answer === 1) {
                    this.facilitySettingExamValue = 2;
                  } else if (answer === 2) {
                    this.facilitySettingExamValue = 3;
                  }
                },
              });
            }
            if (this.msgCdList.includes("70000033") &&
              this.facilitySettingExamValue != 3
            ) {
              await this.$ons.notification.confirm({
                title: DIALOG_MESSAGES[70000033].title,
                message: messageFormat(DIALOG_MESSAGES[70000033].message),
                callback: (answer) => {
                  if (answer === 1) {
                    this.examDeadlineSelectedVal = "OK";
                  } else {
                    this.examDeadlineCancelCheck = "cancel";
                    this.facilitySettingExamValue = "";
                    this.facilitySettingRadValue = "";
                    this.facilitySettingEventValue = "";
                    this.examDeadlineSelectedVal = "";
                    this.radDeadlineSelectedVal = "";
                  }
                },
              });
            }
            if (this.msgCdList.includes("70000031") &&
              !this.examDeadlineCancelCheck.includes("cancel")
            ) {
              await this.$ons.notification.confirm({
                title: DIALOG_MESSAGES[70000031].title,
                message: messageFormat(DIALOG_MESSAGES[70000031].message),
                buttonLabels: ["1", "2", "3"],
                callback: (answer) => {
                  if (answer === 0) {
                    this.facilitySettingRadValue = 1;
                  } else if (answer === 1) {
                    this.facilitySettingRadValue = 2;
                  } else if (answer === 2) {
                    this.facilitySettingRadValue = 3;
                  }
                },
              });
            }
            if (this.msgCdList.includes("70000034") &&
              !this.examDeadlineCancelCheck.includes("cancel") &&
              this.facilitySettingRadValue != 3
            ) {
              await this.$ons.notification.confirm({
                title: DIALOG_MESSAGES[70000033].title,
                message: messageFormat(DIALOG_MESSAGES[70000033].message),
                callback: (answer) => {
                  if (answer === 1) {
                    this.radDeadlineSelectedVal = "OK";
                  } else {
                    this.radDeadlineCancelCheck = "cancel";
                    this.facilitySettingExamValue = "";
                    this.facilitySettingRadValue = "";
                    this.facilitySettingEventValue = "";
                    this.examDeadlineSelectedVal = "";
                    this.radDeadlineSelectedVal = "";
                  }
                },
              });
            }
            if (this.msgCdList.includes("70000032") &&
              !this.examDeadlineCancelCheck.includes("cancel") &&
              !this.radDeadlineCancelCheck.includes("cancel")
            ) {
              await this.$ons.notification.confirm({
                title: DIALOG_MESSAGES[70000032].title,
                message: messageFormat(DIALOG_MESSAGES[70000032].message),
                buttonLabels: ["1", "2", "3"],
                callback: (answer) => {
                  if (answer === 0) {
                    this.facilitySettingEventValue = 1;
                  } else if (answer === 1) {
                    this.facilitySettingEventValue = 2;
                  } else if (answer === 2) {
                    this.facilitySettingEventValue = 3;
                  }
                },
              });
            }
          }
          this.finishLoadingScreen();
          if((this.msgCdList != null && this.msgCdList.length > 0) && !(this.examDeadlineCancelCheck.includes("cancel") || this.radDeadlineCancelCheck.includes("cancel"))) {
          await this.updateDBInfo();
          }
        }

    },
    //  add #10553   end
   
    confirmInfCancel(answer) {
      if (answer === "OK") {
        this.updateInfoOperation();
      }
    },
    // mod #11038 患者経過総合ビューア－予定移動画面 メッセージダイアログのタイトルがない 関 end


    async checkFuicchi() {
      const sendJson = {};
      sendJson.bed_cd = this.bedCd;
      sendJson.facility_cd = this.facilityCd;
      sendJson.ind_bed_cd = this.selectBedCd;
      sendJson.pat_id = this.patId;
      sendJson.ord_no = this.ordNo;
      //add 7579 【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧　start
      if(this.selectBedCd === 0){
        return false;
      }
      this.startLoadingScreen();
      //add 7579 【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧　end
      await ApiHelper.post(`/mainData/checkFuicchi`,sendJson)
        //成功した場合の処理
        .then(response => {
          //ストアへデータをセット
          this.deviceModeMismatchMsgFlg = response.data.deviceModeMismatchMsgFlg;
          this.vaDirectionInconsistentMsgFlg = response.data.vaDirectionInconsistentMsgFlg;
          this.infectionNotConsistentMsgFlg = response.data.infectionNotConsistentMsgFlg;

        })
        .catch(err => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('TreatPlanMove.vue', 'created', err);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          err;
        });
        //mod 7579 【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧　start
      //if (this.deviceModeMismatchMsgFlg || this.vaDirectionInconsistentMsgFlg || this.infectionNotConsistentMsgFlg) {
      if (this.deviceModeMismatchMsgFlg || !this.vaDirectionInconsistentMsgFlg || this.infectionNotConsistentMsgFlg) {
        //mod 7579 【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧　end
        this.finishLoadingScreen();
        return true;
      } else {
        this.finishLoadingScreen();
        return false;
      }
    },
    /**
     * 入力漏れチェック
     */
    checkInputLeak() {
      // メッセージ置換文字配列初期化
      this.messageDialogInfo.stringParams = [];
      // メッセージコード
      let messageCd = 22010001;
      // メッセージ表示文字列
      let dispStr = null;
      // 治療日入力チェック
      if (
        null === this.selectedDialysisDate ||
        "" === this.selectedDialysisDate
      ) {
        dispStr = "移動先 治療日";
      }
      //移動先 治療日の必須入力スタイル
      if("" === this.selectedDialysisDate){
        this.setDateMoveBackground("rgba(255, 0, 0, 0.5)");
      // #10748 患者経過総合ビューアで治療終了と実績確定をベッド，クールが未登録で移動可能 linjunfeng start
      } else {
      // if("" !== this.selectedDialysisDate){
        //  document.getElementById('date-move').style.background = "#ffff99";
        if (!this.rstDialysisStateFlg) {
          this.setDateMoveBackground("#ffff99");
        }
        // #10748 患者経過総合ビューアで治療終了と実績確定をベッド，クールが未登録で移動可能 linjunfeng end
      }
      // 指示者入力チェック
      if (!this.indUser && !dispStr) {
        dispStr = "指示者";
      }
      // add #10748 患者経過総合ビューアで治療終了と実績確定をベッド，クールが未登録で移動可能 linjunfeng start
      const prefix = `${CODES.DIALYSIS_STATE.AFTER_DRAINAGE.text}・${CODES.DIALYSIS_STATE.AFTER_WEIGHT_MEASURING.text}・${CODES.DIALYSIS_STATE.CONFIRMED_WEIGHT_MEASURING.text}の場合、移動先 `;
      if (this.rstDialysisStateFlg && !dispStr && !this.selectKurCd && !this.selectBedCd) {
        dispStr = prefix + "クール、ベッド";
      } else if (this.rstDialysisStateFlg && !dispStr && !this.selectKurCd) {
        dispStr = prefix + "クール";
      } else if (this.rstDialysisStateFlg && !dispStr && !this.selectBedCd) {
        dispStr = prefix + "ベッド";
      }
      // add #10748 患者経過総合ビューアで治療終了と実績確定をベッド，クールが未登録で移動可能 linjunfeng end

      // コピー先治療日上限チェック
      if (null === dispStr) {
        const maxDate = parseInt(dayjs(this.maxDate).format("YYYYMMDD"));
        const treatDate = parseInt(
          dayjs(this.selectedDialysisDate).format("YYYYMMDD")
        );
        if (treatDate > maxDate) {
          messageCd = 22010002;
          dispStr = `移動先治療日は${dayjs(this.maxDate, "YYYY-MM-DD").format(
            "YYYY年M月D日以下"
          )}`;
        }
      }

      if (null !== dispStr) {
        // メッセージ表示
        this.showMessage(messageCd, dispStr, "1");
        return false;
      } else {
        // 入力漏れなし
        return true;
      }
    },

    /**
     * 使用期限のチェック
     */
    async chkInExpiryDate(CopyToDate) {
      this.startLoadingScreen();
      // コピー元予定データの取得
      let treatSetObj = null;

      // mod 障害票一覧_患者経過総合ビューア_予定移動No.1 李 start
      // const storeTreatmentData = this.$store.getters["pat-viewer/getTreatmentData"][0];
      let storeTreatmentData = this.$store.getters["pat-viewer/getTreatmentData"][0];
      // mod 障害票一覧_患者経過総合ビューア_予定移動No.1 李 end
      for (const index in storeTreatmentData) {
        if (storeTreatmentData[index] && storeTreatmentData[index].ordNo === this.ordNo) {
          treatSetObj = storeTreatmentData[index];
        }
      }

      // add 障害票一覧_患者経過総合ビューア_予定移動No.1 李 start
      if (!treatSetObj) {
        // APIの引数作成
        const sendData = {};
        // 施設コード
        sendData.facility_cd = this.facilityCd;
        // 患者ID
        sendData.pat_id = this.patId;
        // 抽出開始日
        sendData.ind_start_date = this.propDialysisDate;
        // 抽出終了日
        sendData.ind_end_date = this.propDialysisDate;
        // 曜日パターン
        sendData.week_pattern = `[{ 'text': '全', 'done': true, 'value': 0 }]`;

        // RestAPI実行
        const response = await ApiHelper.post(
          "/mainData/sharingInfo/TreatDateList",
          sendData
        ).catch(err => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('TreatPlanMove.vue', 'chkInExpiryDate', err);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          throw err;
        });

        storeTreatmentData = response.data;
        for (const index in storeTreatmentData) {
          if (storeTreatmentData[index] && storeTreatmentData[index].ordNo === this.ordNo) {
            treatSetObj = storeTreatmentData[index];
          }
        }
      }
      // add 障害票一覧_患者経過総合ビューア_予定移動No.1 李 end

      let msg = "";
      // 治療条件
      const condObj = JSON.parse(treatSetObj.indCondInfo);
      const keyList = Object.keys(condObj);
      keyList.forEach(key => {
        switch (Number(key)) {
          case 5: {
            // ダイアライザ,  dialyzer.dialyzerCd == condObj[5].value(文字列)
            const tmpDialyzerObj = this.$store.getters["pat-viewer/getMstDialyzerData"].filter(dialyzer => dialyzer.dialyzerCd == condObj[key].value); // mod #9973 value Number→文字列  shiyw
            if (tmpDialyzerObj.length === 0) {
              break;
            }
            const dialyzerObj = tmpDialyzerObj[0];
            if (!fitTermCheckForUpdate(dialyzerObj.useStartDate, dialyzerObj.useEndDate, CopyToDate, CopyToDate)) {
              msg += "</br>" + dialyzerObj.modelNumber + "："
                  + dateFormat.normalDateWithCheck(dialyzerObj.useStartDate)
                  + "～" + dateFormat.normalDateWithCheck(dialyzerObj.useEndDate);
            }
            break;
          }
          case 6:
          case 7:
          case 8:
          case 9:
          case 10:
          case 11:
          case 13: {
            // 吸着カラム/1次膜/2次膜/穿刺針(A/V/SN)/血液回路
            if (!condObj[key].value) {
              // シングルニードル使用の有無により、A/V、SNのいずれかがnullになる
              break;
            }
            // equipment.equipmentCd == condObj[13].value(文字列)
            const tmpEquipmentObj = this.$store.getters["pat-viewer/getMstEquipmentData"].filter(equipment => equipment.equipmentCd == condObj[key].value); // mod #9973 value Number→文字列  shiyw
            if (tmpEquipmentObj.length === 0) {
              break;
            }
            const equipmentObj = tmpEquipmentObj[0];
            if (!fitTermCheckForUpdate(equipmentObj.useStartDate, equipmentObj.useEndDate, CopyToDate, CopyToDate)) {
              msg += "</br>" + equipmentObj.equipmentName + "："
                  + dateFormat.normalDateWithCheck(equipmentObj.useStartDate)
                  + "～" + dateFormat.normalDateWithCheck(equipmentObj.useEndDate);
            }
            break;
          }
          case 15:
          case 19:
          case 25: {
            // 薬剤/調製薬剤項目
            // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
            //if (condObj[key].medicine_type === "1") {
            if (condObj[key].medicine_type == 1) {
              // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
              // 薬剤の場合,medi.medicineCd == condObj[25].value(文字列)
              const tmpMediObj = this.$store.getters["pat-viewer/getMstMedicineData"].filter(medi => medi.medicineCd == condObj[key].value); // mod #9973 value Number→文字列  shiyw
              if (tmpMediObj.length === 0) {
                break;
              }
              const mediObj = tmpMediObj[0];
              if (!fitTermCheckForUpdate(mediObj.useStartDate, mediObj.useEndDate, CopyToDate, CopyToDate)) {
                msg += "</br>" + mediObj.medicineName + "："
                    + dateFormat.normalDateWithCheck(mediObj.useStartDate)
                    + "～" + dateFormat.normalDateWithCheck(mediObj.useEndDate);
              }
              // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
              //} else if (condObj[key].medicine_type === "2") {
            } else if (condObj[key].medicine_type == 2) {
              // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
              // 調製薬剤の場合,medi.medicineMixCd == condObj[25].value(文字列)
              const tmpMediObj = this.$store.getters["pat-viewer/getMstMedicineMixTabooAllergyData"].filter(medi => medi.medicineMixCd == condObj[key].value); // mod #9973 value Number→文字列  shiyw
              if (tmpMediObj.length === 0) {
                break;
              }
              const mediObj = tmpMediObj[0];
              if (!fitTermCheckForUpdate(mediObj.maxUseStartDate, mediObj.minUseEndDate, CopyToDate, CopyToDate)) {
                msg += "</br>" + mediObj.medicineMixName + "："
                    + dateFormat.normalDateWithCheck(mediObj.maxUseStartDate)
                    + "～" + dateFormat.normalDateWithCheck(mediObj.minUseEndDate);
              }
            }
            break;
          }
        }
      });

      // 投与薬剤
      const mediInfoObj = JSON.parse(treatSetObj.indMediInfo);
      for (const key in mediInfoObj) {
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
        //if (mediInfoObj[key].medicine_type === "1") {
        if (mediInfoObj[key].medicine_type == 1) {
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
          // 薬剤の場合
          const tmpMediObj = this.$store.getters["pat-viewer/getMstMedicineData"].filter(medi => medi.medicineCd === mediInfoObj[key].cd);
          if (tmpMediObj.length === 0) {
            continue;
          }
          const mediObj = tmpMediObj[0];
          if (!fitTermCheckForUpdate(mediObj.useStartDate, mediObj.useEndDate, CopyToDate, CopyToDate)) {
            msg += "</br>" + mediObj.medicineName + "："
                + dateFormat.normalDateWithCheck(mediObj.useStartDate)
                + "～" + dateFormat.normalDateWithCheck(mediObj.useEndDate);
          }
        } else {
          // 調製薬剤の場合
          const tmpMediObj = this.$store.getters["pat-viewer/getMstMedicineMixTabooAllergyData"].filter(medi => medi.medicineMixCd === mediInfoObj[key].cd);
          if (tmpMediObj.length === 0) {
            continue;
          }
          const mediObj = tmpMediObj[0];
          if (!fitTermCheckForUpdate(mediObj.maxUseStartDate, mediObj.minUseEndDate, CopyToDate, CopyToDate)) {
            msg += "</br>" + mediObj.medicineMixName + "："
                + dateFormat.normalDateWithCheck(mediObj.maxUseStartDate)
                + "～" + dateFormat.normalDateWithCheck(mediObj.minUseEndDate);
          }
        }
      }

      // 医療材料
      const equipInfoObj = JSON.parse(treatSetObj.indEquipInfo);
      for (const key in equipInfoObj) {
        if (equipInfoObj[key].equip_type === 0) {
          // 医療材料
          const tmpEquipObj = this.$store.getters["pat-viewer/getMstEquipmentData"].filter(equipment => equipment.equipmentCd === equipInfoObj[key].cd);
          if (tmpEquipObj.length === 0) {
            continue;
          }
          const equipObj = tmpEquipObj[0];
          if (!fitTermCheckForUpdate(equipObj.useStartDate, equipObj.useEndDate, CopyToDate, CopyToDate)) {
            msg += "</br>" + equipObj.equipmentName + "："
                + dateFormat.normalDateWithCheck(equipObj.useStartDate)
                + "～" + dateFormat.normalDateWithCheck(equipObj.useEndDate);
          }
        } else if (equipInfoObj[key].equip_type === 1) {
          // ダイアライザ
          const tmpDialyzerObj = this.$store.getters["pat-viewer/getMstDialyzerData"].filter(dialyzer => dialyzer.dialyzerCd === equipInfoObj[key].cd);
          if (tmpDialyzerObj.length === 0) {
            continue;
          }
          const dialyzerObj = tmpDialyzerObj[0];
          if (!fitTermCheckForUpdate(dialyzerObj.useStartDate, dialyzerObj.useEndDate, CopyToDate, CopyToDate)) {
            msg += "</br>" + dialyzerObj.modelNumber + "："
                + dateFormat.normalDateWithCheck(dialyzerObj.useStartDate)
                + "～" + dateFormat.normalDateWithCheck(dialyzerObj.useEndDate);
          }
        }
      }

      if (msg) {
        let rtn = false;
        await this.$ons.notification.confirm({
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
          // title: "",
          title: DIALOG_MESSAGES[13000072].title,
          // message: "指示期間に使用期間外となる項目が含まれています。" + msg + "</br>登録してよろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000072].message,msg),
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer === 1) {
              rtn = true;
            } else {
              // 処理を中止するので保存ボタン無効を解除
              this.updateDisable = false;
            }
          }
        });
        this.finishLoadingScreen();
        return rtn;
      } else {
        // チェック対象項目なし / 期限切れ項目なしの場合
        this.finishLoadingScreen();
        return true;
      }
    },

    /**
     * 治療方法&クールリスト作成
     * @description コピー元日時が選択されたタイミングでリスト作成
     * @param date コピー元治療日
     */
    async setDispTreatmentAndKur(date) {
      const paramJson = {};
      // 施設情報
      paramJson.facility_cd = this.facilityCd;
      // 患者情報
      paramJson.pat_id = this.patId;
      // 治療開始日時
      paramJson.ind_start_date = date;
      // 治療終了日時
      paramJson.ind_end_date = date;
      // 曜日パターン
      paramJson.week_pattern = "[{'text': '全','done': false,'value': 0}]";
      // 対象日時の治療情報取得
      const response = await ApiHelper.post(
        "/mainData/TreatDateList",
        paramJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('TreatPlanMove.vue', 'setDispTreatmentAndKur', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });
      if (0 !== response.data) {
        response.data.forEach(eleItem => {
          // 移動元のオーダー番号と一致した場合
          if (eleItem.ordNo === this.ordNo) {
            // 治療方法名
            this.dispTreatmethod = this.translateMstName(
              eleItem.indTreatmentCd,
              "treatment",
              this.mstTreamentData
            );
            // クール名
            this.dispKur = this.translateMstName(
              eleItem.indKurCd,
              "kur",
              this.mstKurData
            );
            // ベッド名
            this.dispBed = this.translateMstName(
              eleItem.indBedCd,
              "bed",
              this.mstBedData
            );
            // redmine 4672  姜 start
            this.bedCd = eleItem.indBedCd;
            // redmine 4672  姜 end
          }
        });
      }
    },

    /**
     * @description 対象日の[クール・ベッド設定済み治療予定]を取得する
     * @param date 対象治療日
     */
    async setOrdSchList(date) {
      // 共通ローダー表示
      this.setLoadingScreenMessage("治療予定取得中...");
      this.setLoadingScreenVisible(true);

      const formatDate = dayjs(date).format("YYYYMMDD");
      const url = "/mainData/getReservedOrdScheduleList/" + this.facilityCd + "/" + formatDate + "/" + this.patId;
      const response = await ApiHelper.post(
        url
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('TreatPlanMove.vue', 'setOrdSchList', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        this.setLoadingScreenVisible(false);
        throw error;
      });
      if (response.data) {
        this.ordSchList = [];
        response.data.forEach(eleItem => {
          const obj = {patId: eleItem.patId, kurCd: eleItem.kurCd, bedCd: eleItem.bedCd};
          this.ordSchList.push(obj);
        })
      }
      this.setLoadingScreenVisible(false);
    },

    /**
     * マスタ翻訳
     * @param cd 変換元のコード
     * @param mstName 翻訳するためのマスタ名(treatment, kur)
     * @param mstInfo 翻訳するマスタ情報(mstTreamentData, mstKurData)
     */
    translateMstName(cd, mstName, mstInfo) {
      const mstData = mstInfo.find(item => {
        // 変換元コードとマスタのコードが一致するものを返す
        return item[`${mstName}Cd`] === cd;
      });
      // マスタにコードが存在しなければ
      if (!mstData) {
        return "未登録";
      } else {
        return mstData[`${mstName}Name`];
      }
    },

    /**
     * 文字列調整処理
     * @param  inputStr   入力文字列
     * @param  distLength 出力文字列
     * @return 調整した文字列
     */
    addSpace(inputStr, distLength) {
      //全角SPの準備
      const zenSpStr = "　";
      //半角SPの準備
      const hanSpStr = " ";

      //返却文字列
      let retStr = inputStr;

      //現在の文字列長の取得
      const nowLength = inputStr.length;
      //追加文字列長の取得
      const addLength = distLength - nowLength;

      //全角の個数の計算
      const zenSp = Math.floor(addLength / 2);
      //半角の個数の計算
      const hanSp = addLength % 2;

      //全角spの付加
      for (let i = 0; i < zenSp; i++) {
        retStr += zenSpStr;
      }

      //半角spの付加
      for (let i = 0; i < hanSp; i++) {
        retStr += hanSpStr;
      }
      //返却
      return retStr;
    },

    /**
     * メッセージ表示処理
     */
    showMessage(msgCd, strParam, type) {
      this.messageDialogInfo.messageCd = parseInt(msgCd);
      this.messageDialogInfo.type = type;
      this.messageDialogInfo.stringParams = [strParam];
      this.messageDialogInfo.isDialogVisible = true;
    },

    /**
     * メッセージ返答処理
     */
    confirmResult() {
      switch (this.messageDialogInfo.messageCd) {
        case 22010006:
          // add FNSI-障害票一覧_患者経過総合ビューアNo.22-27 李 start
          this.isRefresh = true;
          // add FNSI-障害票一覧_患者経過総合ビューアNo.22-27 李 end
          // モーダルを閉じる
          this.$emit("hide-modal");
          break;
        // add FNSI-ScreenVisible閉じる 李 start
        default:
          this.setLoadingScreenVisible(false);
        // add FNSI-ScreenVisible閉じる 李 end
      }
    },
    stringToDate(str){
      var strDatepart = str.split("-");
      var dtDate = new Date(strDatepart[0],strDatepart[1],strDatepart[2]);
      return dtDate;
    },
    /** 移動先治療日フォーカスアウト時の処理 */
    onBlurDialysisDate() {
      if (this.beforeDialysisDate === this.selectedDialysisDate) {
        return;
      }
      this.calendarDialysisDate = this.selectedDialysisDate;
    },
  }
};
</script>

<style scoped>
.row-style {
  padding: 5px 10px;
}

.row-style-footer {
  padding: 5px 10px;
}

.col-style-right,
.col-style-right-title {
  text-align: right;
  padding-right: 2em;
}

.col-style-left {
  text-align: left;
  padding-left: 2em;
}

input::-webkit-calendar-picker-indicator {
  display: none;
}

@media screen and (max-width: 450px) {
  .row-style {
    padding: 5px 0px;
  }

  .col-style-right {
    display: none;
  }

  .col-style-right-title {
    text-align: left;
    padding-right: 0.1em;
  }

  .col-style-left {
    text-align: left;
    padding-left: 0;
  }

  .date-input{
    width:120px;
  }

}
/* add FNSI-患者経過総合ビューア 画面デザイン 李 start */
.width-padding {
  width: 100px;
  padding-top: 8px;
}
/* add FNSI-患者経過総合ビューア 画面デザイン 李 end */
  /* add 7952 必須項目にも関わらず背景色が黄色になっていない 張 start */
.select-style-list > span {
  background-color: #ffff99 !important;
}
  /* add 7952 必須項目にも関わらず背景色が黄色になっていない 張 end */
</style>
