/** * 治療記録の子機能 実績情報ページ */
<template>
  <submenu-base v-if="hasOrdNo">
    <template #main>
      <div id="result-component">
      <v-ons-list class="treatment-record-accordion">
        <v-ons-list-item
          expandable
          v-model:expanded="isExpandedResult"
          id="result-sub"
        >
          <label>実績情報</label>
          <result-sub
            :value="actualModel"
            :comboData="comboList"
            :isPurification="isPurification"
            :initDeviceMode="initDeviceMode"
            :newDeviceMode="newDeviceMode"
            @input="reflectResultSub"
            ref="actual_model_component"
          />
        </v-ons-list-item>
        <v-ons-list-item
          expandable
          v-model:expanded="isExpandedPuncture"
          id="puncture-user-sub"
        >
          <label>穿刺者</label>
          <user-sub
            type-name="穿刺"
            :show-date="true"
            :value="actualModel.rst_puncture_user_info"
            :initValue="comparisonModel.rst_puncture_user_info"
            :masterDefinition="punctureUser"
            @input="reflectPunctureUserSub"
            id="punctureUserInfo"
            ref="rst_puncture_user_info"
          />
        </v-ons-list-item>
        <v-ons-list-item
          expandable
          v-model:expanded="isExpandedReturn"
          id="return-user-sub"
        >
          <label>返血者</label>
          <user-sub
            type-name="返血"
            :show-date="true"
            :value="actualModel.rst_return_user_info"
            :initValue="comparisonModel.rst_return_user_info"
            :masterDefinition="returnUser"
            @input="reflectReturnUserSub"
            id="returnUserInfo"
            ref="rst_return_user_info"
          />
          <!-- add FNSI-横展開 日付のチェックの追加 徐 end -->
        </v-ons-list-item>
        <v-ons-list-item
          expandable
          v-model:expanded="isExpandedCharge"
          id="charge-user-sub"
        >
          <label>担当者</label>
          <user-sub
            type-name="担当"
            :show-date="false"
            :value="this.actualModel.rst_charge_user_info"
            :initValue="comparisonModel.rst_charge_user_info"
            :masterDefinition="chargeUser"
            @input="reflectChargeUserSub"
            ref="rst_charge_user_info"
          />
        </v-ons-list-item>
      </v-ons-list>
      </div>
    </template>
    <template #footer>
      <div class="flex-container treatment-submenu" >
      <div class="denial-btn-area">
        <v-ons-button
          class="button denial-btn btn2-cancel"
          data-non-authorize="true"
          @click="onClickCancel"
          >キャンセル</v-ons-button
        >
      </div>
      <div class="registration-btn-area">
        <v-ons-button
          class="button registration-btn btn1-execute"
          :disabled="!canSave || isReadOnly || !getItemAuthorized('TreatmentRecord', 'default_authority')"
          @click="update"
        >保存</v-ons-button
        >
      </div>
      </div>
    </template>
  </submenu-base>
</template>

<script>
import { getScopedElementsByClassName } from "@/functions/common/LayoutMeasureHelper";
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized} from "@/functions/common/CommonFunctions.js";
//add #12300 20260427 zhaojinzhao start
import { isJsonChanged} from "@/functions/common/CommonFunctions.js";
//add #12300 20260427 zhaojinzhao end
// add #10359 編集権限の動作不正 dengshen end
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
import {mapActions, mapGetters, mapMutations} from "@/compat/vue/vuex";
import cloneDeep from "@/compat/collections/lodash/cloneDeep";
import isEqualWith from "@/compat/collections/lodash/isEqualWith";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
import SubmenuBase from "@/components/treatment-record/SubmenuBaseComponent";
import ResultSubComponent from "@/components/treatment-record/submenu/result/ResultSubComponent";
import UserSubComponent from "@/components/treatment-record/submenu/result/UserSubComponent";
import DiscardConfirmationMixin from "@/components/treatment-record/DiscardConfirmationMixin";
// del #10359 編集権限の動作不正 dengshen start
// import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
// del #10359 編集権限の動作不正 dengshen end
import {
  CODES,
  TREATMENT_MESSAGES,
  TREATMENT_CHANGE_PROCESS,
} from "@/constants/TreatmentRecord.js";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import {
  punctureUser,
  returnUser,
  chargeUser,
} from "@/components/common/master-selector/MasterSelectorDefinitions";
import {
  dateFormat
} from "@/functions/common/DateTimeUtils.js";
import {
  // 治療方法マスタ取得API
  sendRequestGetMstTreatment,
} from "@/apis/treatment-record";
import { EventBus } from "@/compat/vue/event-bus.js";
// add FNSI 1006 No.538 治療記録 外部連携APIを呼び出 start -- Sanjingye Sun 20210112
import { createJournal } from "@/apis/journal";
// add FNSI 1006 No.538 治療記録 外部連携APIを呼び出 end -- Sanjingye Sun 20210112
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import dayjs from "@/compat/date/dayjs";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

export default {
  // mod #10359 編集権限の動作不正 dengshen start
  // mixins: [DiscardConfirmationMixin, ComponentGuardMixin],
  mixins: [DiscardConfirmationMixin],
  // mod #10359 編集権限の動作不正 dengshen end
  components: {
    "submenu-base": SubmenuBase,
    "result-sub": ResultSubComponent,
    "user-sub": UserSubComponent,
  },
  data() {
    return {
      comparisonModel: "",
      actualModel: {},
      // add #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc start
      initResponseData: {},
      // add #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc end
      isExpandedResult: false,
      isExpandedPuncture: false,
      isExpandedReturn: false,
      isExpandedCharge: false,
      comboList: {
        kur: undefined,
        bed: undefined,
        ward: undefined,
        course: undefined,
        treatment: undefined,
      },
      comboListMatched: false,
      returnUser: returnUser,
      punctureUser: punctureUser,
      chargeUser: chargeUser,
      authorityCds: [AUTHORITY_CODES.RST_PEDIT, AUTHORITY_CODES.RST_EDIT],
      // 治療方法マスタ
      mstTreatment: null,
      selfScreenName: "",
      isPurification: false,
      //add メッセージ順番修正 房 start
      alertFlag: true,
      //add メッセージ順番修正 房 end
      //add 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start
      initDeviceMode: "",
      newDeviceMode: "",
      //add 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end
      isChanged: false,
      //add #12300 20260427 zhaojinzhao start
      oldValue:""
      //add #12300 20260427 zhaojinzhao end
    };
  },

  watch: {
    comboList: {
      handler() {
        this.comboListMatching();
      },
      deep: true,
    },
    //del #12300 20260427 zhaojinzhao start
    // actualModel: {
    //   handler(val) {
    //     // 比較を除外するキーを指定するカスタム比較関数
    //     const customizer = (objValue, othValue, key) => {
    //       if (['date_1', 'date_2'].includes(key)) {
    //         return true; // 除外するキーの値は常に等しいとみなす
    //       }
    //     };
    //     this.isChanged = !isEqualWith(val, this.comparisonModel, customizer);
    //     this.setIsPatInfoChaned(this.isChanged);
    //   },
    //   deep: true
    // }
    //del #12300 20260427 zhaojinzhao end


    //del 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start
    // getOrdNo() {
    //   this.isExpandedResult = false;
    //   this.isExpandedPuncture = false;
    //   this.isExpandedReturn = false;
    //   this.isExpandedCharge = false;
    //   // this.refresh();
    // }
    //del 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end
  },

  computed: {
    ...mapGetters("treatment-record/common", [
      "getOrdNo",
      "getOrd",
      "getSharedFacilityCd",
      // add FNSI 1006 No.538 治療記録 外部連携APIを呼び出 start -- Sanjingye Sun 20210112
      "getTreatDate",
      // add FNSI 1006 No.538 治療記録 外部連携APIを呼び出 end -- Sanjingye Sun 20210112
    ]),

    // add 共有設定の追加 周雨晴 2020/09/22 start
    ...mapGetters("user", {
      facilityCd: "getFacilityCd",
      advancedSettings: "getAdvancedSettings",
    }),
    ...mapGetters("mst-user", { getSharedFlag: "getIsRegisteredShared" }),
    // add 共有設定の追加 周雨晴 2020/09/22 end

    // add FNSI 1006 No.538 治療記録 外部連携APIを呼び出 start -- Sanjingye Sun 20210112
    ...mapGetters("pat-info", ["selectedPat"]),
    // 利用者情報に関するGetter
    ...mapGetters("account-edit", ["getUserId"]),
    // add FNSI 1006 No.538 治療記録 外部連携APIを呼び出 end -- Sanjingye Sun 20210112
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
    ...mapGetters("pat-info", ["selectedPatId"]),
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
    /**
     * 保存ボタンがクリックできるかどうか.
     */
    canSave() {
      // del #10359 編集権限の動作不正 dengshen start
      // if (!this.authorized) {
      //   return false;
      // }
      // del #10359 編集権限の動作不正 dengshen end
      return this.isChanged && this.validationErrors.length === 0;
    },

    isReadOnly() {
      return this.getOrd.readOnly;
    },
  },
  methods: {
    ...mapActions("treatment-record/result", [
      "getTreatmentRecordResult",
      "updateTreatmentRecordResult",
      "updateTreatmentRecordResultWithCondition",
      "updateMniMachineState",
    ]),
    ...mapActions("reference-combo", [
      "getKurComboList",
      "getBedComboList",
      "getWardComboList",
      "getCourseComboList",
      "getTreatmentMethodComboList",
    ]),
    ...mapActions("treatment-record/common", [
      "getSummary",
      "setTreatmentUpdate",
      "sendNextPatInfo",
      // #10518 2024.04.22 add 治療開始時刻の変更があった場合は「オフライン運転タイマー更新」通知を行うアクションを追加 TDC米沢 start
      "sendRequestChangeTreatTime",
      // #10518 2024.04.22 add 治療開始時刻の変更があった場合は「オフライン運転タイマー更新」通知を行うアクションを追加 TDC米沢 end
    ]),
    ...mapActions("loading-screen", ["startLoadingScreen", "finishLoadingScreen"]),
    // 予実リストへの変更通知
    ...mapActions("indication-result", ["setResultUpdate"]),
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
    ...mapMutations("pat-info", ["setIsPatInfoChaned"]),
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    // FNSI-add 診療科表示不正 徐 start
    async init() {
      if (!this.getOrdNo) {
        return;
      }
      this.startLoadingScreen();
      await this.getTreatmentRecordResult({
        ordNo: this.getOrdNo,
        selectedPatId: this.selectedPatId
      }).then(async(response) => {
        // FNSI-add 診療科表示不正 徐 end
        // add #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc start
        this.initResponseData = JSON.parse(JSON.stringify(response.data));
        // add #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc end
        this.actualModel = response.data;
        // 穿刺者、返血者、担当者のJSONがnullの場合、空データを設定.
        if (!this.actualModel.rst_puncture_user_info) {
          this.actualModel.rst_puncture_user_info =
            this.getEmptySubComponentData();
        }
        if (!this.actualModel.rst_return_user_info) {
          this.actualModel.rst_return_user_info =
            this.getEmptySubComponentData();
        }
        if (!this.actualModel.rst_charge_user_info) {
          this.actualModel.rst_charge_user_info =
            this.getEmptySubComponentData();
        }

        this.convertDateFields();
        this.initComparisonModel();
        //初期状態でアコーディオンを開く
        this.isExpandedResult = true;
        this.isExpandedPuncture = true;
        this.isExpandedReturn = true;
        this.isExpandedCharge = true;
        //add #12300 20260427 zhaojinzhao start
        this.oldValue = JSON.parse(JSON.stringify(this.actualModel))
        //add #12300 20260427 zhaojinzhao end


        // 治療方法マスタ取得
        await this.getMstTreatment().then(() => {
          //add 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start
          this.initDeviceMode = this.getDeviceModeForTreatmentCd(this.initResponseData.rst_treatment_cd)
          //add 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end
          this.checkIsPurification();
        });
        this.finishLoadingScreen();
      });
    },
    /**
     * 治療記録のトップ画面に遷移.
     */
    backTreatmentRecord() {
      // 画面遷移前に変更内容を同期する.
      // 理由は画面遷移時に変更破棄ダイアログが2回表示されてしまう為.
      this.initComparisonModel();
      this.refresh()
      // this.$nextTick(() => {
      //   this.$router.push({ name: "treatment-record" });
      // });
    },
    isValidIsoDateTime(value) {
      if (!value) {
        return false;
      }
      const isoFormats = [
        "YYYY-MM-DDTHH:mm:ss.SSSZ",
        "YYYY-MM-DDTHH:mm:ssZ",
        "YYYY-MM-DDTHH:mm:ss",
        "YYYY-MM-DDTHH:mmZ",
        "YYYY-MM-DDTHH:mm"
      ];
      return isoFormats.some(format => dayjs(value, format, true).isValid());
    },
    /**
     * 日付項目をDate型に変換
     */
    convertDateFields() {
      // 治療開始日時
      let rstStartDate = null;
      if (this.actualModel.rst_start_date) {
        rstStartDate = new Date(this.actualModel.rst_start_date);
        rstStartDate.setSeconds(0);
      }
      this.actualModel.rst_start_date = rstStartDate;
      // 治療終了日時
      let rstEndDate = null;
      if (this.actualModel.rst_end_date) {
        rstEndDate = new Date(this.actualModel.rst_end_date);
        rstEndDate.setSeconds(0);
      }
      this.actualModel.rst_end_date = rstEndDate;

      // 穿刺者情報がnull以外の場合
      if (this.actualModel.rst_puncture_user_info !== null) {
        // 穿刺時刻
        let rstPunctureDate = null;
        if (this.actualModel.rst_puncture_user_info.date && this.isValidIsoDateTime(this.actualModel.rst_puncture_user_info.date)) {
          rstPunctureDate = new Date(
            this.actualModel.rst_puncture_user_info.date
          );
          rstPunctureDate.setSeconds(0, 0);
          this.actualModel.rst_puncture_user_info.date = dateFormat.utc2Jst(rstPunctureDate);
        } else if (!this.actualModel.rst_puncture_user_info.date) {
          this.actualModel.rst_puncture_user_info.date = null;
        }
      }

      // 返血者情報がnull以外の場合
      if (this.actualModel.rst_return_user_info !== null) {
        // 返血時刻
        let rstReturnDate = null;
        if (this.actualModel.rst_return_user_info.date && this.isValidIsoDateTime(this.actualModel.rst_return_user_info.date)) {
          rstReturnDate = new Date(this.actualModel.rst_return_user_info.date);
          rstReturnDate.setSeconds(0, 0);
          this.actualModel.rst_return_user_info.date = dateFormat.utc2Jst(rstReturnDate);
        } else if (!this.actualModel.rst_return_user_info.date) {
          this.actualModel.rst_return_user_info.date = null;
        }
      }
    },
    /**
     * サブコンポーネント(UserSubCompnent)用の空データを取得.
     *
     * @returns {Object} 空データ
     */
    getEmptySubComponentData() {
      return {
        user_id_1: "",
        user_last_name_1: null,
        user_first_name_1: null,
        user_id_2: "",
        user_last_name_2: null,
        user_first_name_2: null,
        date_1: null,
        date_2: null,
      };
    },
    /**
     * 編集有無を判断する為の比較用モデル設定.
     */
    initComparisonModel() {
      // 編集前の値を比較用に保存
      this.comparisonModel = cloneDeep(this.actualModel);
    },
    /**
     * 治療方法マスタ取得
     * 取得した治療方法マスタはmstTreatmentに格納する.
     */
    async getMstTreatment() {
      const response = await sendRequestGetMstTreatment(undefined, this.selectedPatId);
      this.mstTreatment = response.data;
    },

    /**
     * 治療方法コードに該当する装置モード取得する.
     * 与えられた治療方法コードがnullの場合、不明のコード(-1)を返す.
     * また、治療方法コードに該当する治療方法マスタが取得出来ない場合も不明のコード(-1)を返す.
     * @param {Integer} treatmentCd 治療方法コード
     * @return {Integer} 装置モード
     */
    getDeviceModeForTreatmentCd(treatmentCd) {
      // 治療方法マスタ無しの場合、不明を返す
      if (!this.mstTreatment || !treatmentCd) {
        return CODES.DEVICE_MODE.UNKNOWN.cd;
      }
      const selectedMstTreatment = this.mstTreatment.find(
        (e) => e.treatmentCd === treatmentCd
      );
      // 見つからない場合、不明を返す
      return selectedMstTreatment
        ? selectedMstTreatment.deviceMode
        : CODES.DEVICE_MODE.UNKNOWN.cd;
    },
      //add #12300 20260427 zhaojinzhao start
      isTrueChanged(){
      if(this.actualModel && this.oldValue){
        let actualModel = JSON.parse(JSON.stringify(this.actualModel))
        let oldValue = JSON.parse(JSON.stringify(this.oldValue))
        //ドロップダウンボックスに問題があります：名前の対比によって改名がある可能性がある場合は、名前フィールドを削除して対比することができます
        delete actualModel.rst_course_name
        delete actualModel.rst_ward_name
        delete actualModel.rst_kur_name
        delete actualModel.rst_bed_name
        delete actualModel.rst_treatment_name
        
        delete oldValue.rst_course_name
        delete oldValue.rst_ward_name
        delete oldValue.rst_kur_name
        delete oldValue.rst_bed_name
        delete oldValue.rst_treatment_name
        this.isChanged = isJsonChanged(JSON.stringify(actualModel), JSON.stringify(oldValue))
        this.setIsPatInfoChaned(this.isChanged);
      }
      else{
        this.isChanged = false
      }
    },
    //add #12300 20260427 zhaojinzhao end
    /**

     * 保存ボタンクリックイベント
     */
    update() {
      if (this.isReadOnly) {
        return;
      }
      //add FNSI-redmine5858 fang start
      if (this.$refs["actual_model_component"] != undefined) {
        if (this.$refs["actual_model_component"].checkTreatmentTime()) {
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "チェックエラー",
            // message: '<div style="text-align:left;">' + "治療時間が72時間を超えました。治療開始時間と治療終了時間をもう一度確認してください。" + "</div>"
            title: DIALOG_MESSAGES[12000327].title,
            message:
              '<div style="text-align:left;">' +
              messageFormat(DIALOG_MESSAGES[12000327].message) +
              "</div>",
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
          return;
        }
      }

      // #10518 2024.04.22 add 治療開始時刻の変更判定処理を追加 TDC米沢 start
      // 治療開始時刻の変更確認
      let isChangeStartDate = false;
      const orgTreatStartDate = new Date(
        this.comparisonModel.rst_start_date ?? null
      ).setSeconds(0);
      const newTreatStartDate = new Date(
        this.actualModel.rst_start_date ?? null
      ).setSeconds(0);
      if (orgTreatStartDate !== newTreatStartDate) {
        // 治療開始日時が変更された場合はデバイスエッジへ通知
        isChangeStartDate = true;
      }
      // #10518 2024.04.22 add 治療開始時刻の変更判定処理を追加 TDC米沢 end

      //add FNSI-redmine5858 fang end
      // 治療方法の変更確認
      const orgTreatmentCd = this.comparisonModel.rst_treatment_cd;
      const newTreatmentCd = this.actualModel.rst_treatment_cd;
      let bedChangeFlag = false;
      const oldCoolCd = this.comparisonModel.rst_kur_cd;
      const newCoolCd = this.actualModel.rst_kur_cd;
      const oldBedCd = this.comparisonModel.rst_bed_cd;
      const newBedCd = this.actualModel.rst_bed_cd;
      if (oldCoolCd != newCoolCd || oldBedCd != newBedCd) {
        bedChangeFlag = true;
      }

      // add FNSI 1006 No.538 治療記録 外部連携APIを呼び出 start -- Sanjingye Sun 20210112
      // mod FNSI 1006 No.538 治療記録 外部連携APIを呼び出 房 start
      const params = {
        ope_cd: "006006",
        hosp_pat_id:
          this.selectedPat != null
            ? this.selectedPat.pat_personal_main.hosp_pat_id
            : -1,
        pat_id:
          this.selectedPat != null
            ? this.selectedPat.pat_personal_main.pat_id
            : -1,
        base_date: this.getTreatDate,
        facility_cd: this.facilityCd,
        crud: "U",
        ord_no: this.getOrdNo,
        user_id: this.getUserId,
      };
      // mod FNSI 1006 No.538 治療記録 外部連携APIを呼び出 房 end
      // add FNSI 1006 No.538 治療記録 外部連携APIを呼び出 end -- Sanjingye Sun 20210112

      if (orgTreatmentCd !== newTreatmentCd) {
        const toTreatmentCd = this.comparisonModel.rst_treatment_cd;
        const fromTreatmentCd = this.actualModel.rst_treatment_cd;
        const toDeviceMode = this.getDeviceModeForTreatmentCd(toTreatmentCd);
        const fromDeviceMode =
          this.getDeviceModeForTreatmentCd(fromTreatmentCd);
        // 治療記録変更メッセージ
        const message = TREATMENT_MESSAGES.TREATMENT_MAP.filter(
          (msg) => msg.key === `${toDeviceMode}:${fromDeviceMode}`
        ).map((msg) => msg.message)[0];

        // メッセージが空ではない場合
        if (message !== undefined) {
          const process = TREATMENT_MESSAGES.TREATMENT_MAP.filter(
            (msg) => msg.key === `${toDeviceMode}:${fromDeviceMode}`
          ).map((msg) => msg.process)[0];
          // 変更メッセージ表示
          this.$ons.notification.confirm({
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
            // title: "確認",
            title: DIALOG_MESSAGES[13000144].title,
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
            message: message,
            buttonLabels: ["いいえ", "はい"],
            callback: async (answer) => {
              // 治療方法変更に伴う処理区分
              // 初期値は"0"(何もしない)を設定
              let processType =
                TREATMENT_CHANGE_PROCESS.PROCESS_TYPE.PROCESS_NONE;
              if (answer === 1) {
                processType = process;
              }
              //add FNSI-redmine6089 fang start
              this.deleteMakrDel();
              //add FNSI-redmine6089 fang end
              // 更新処理
              const payload = {
                ordNo: this.getOrdNo,
                treatmentRecordResult: this.actualModel,
                processType,
              };
              this.updateTreatmentRecordResultWithCondition(payload)
                .then(() => {
                  // 初期化処理を実行
                  this.init();
                  // 概要欄情報の更新
                  this.setTreatmentUpdate(new Date());
                  // 予実リストの更新
                  this.setResultUpdate(new Date());
                  // 子機能ボタンエリアの更新
                  this.$emit("update");
                  if (bedChangeFlag) {
                    this.updateMniMachineState({
                      ordNo: this.getOrdNo,
                      bedNo: this.actualModel.rst_bed_cd,
                    }).then((response) => {
                      // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
                      if (response.data) {
                        // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
                        const params = {
                          ordNo: this.getOrdNo, //オーダー番号
                          machineNo: response.data[1], //装置マスタ.装置番号
                          deviceEdgeNo: response.data[0], //デバイスエッジ番号
                          facilityCd: this.facilityCd, //施設コード
                        };
                        this.sendNextPatInfo(params);
                        // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
                      }
                      // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
                    });
                  }

                  // #10518 2024.04.22 add 治療開始時刻の変更があった場合は「オフライン運転タイマー更新」通知を行う TDC米沢 start
                  // 治療開始日時が変更された場合はデバイスエッジへ通知
                  if (isChangeStartDate) {
                    const params = {
                      ordNo: this.getOrdNo, //オーダー番号
                      facilityCd: this.facilityCd, //施設コード
                    };
                    this.sendRequestChangeTreatTime(params);
                  }
                  // #10518 2024.04.22 add 治療開始時刻の変更があった場合は「オフライン運転タイマー更新」通知を行う TDC米沢 end
                })
                .catch((error) => {
                  //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
                  getErrorMessage(
                    "ResultComponent.vue",
                    "update",
                    "必須項目が入力されていません。"
                  );
                  //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
                  if (error.response.status === 400) {
                    this.$ons.notification.alert({
                      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                      // title: "更新失敗",
                      // message: "必須項目が入力されていません。"
                      title: DIALOG_MESSAGES["00200070"].title,
                      message: messageFormat(
                        DIALOG_MESSAGES["00200070"].message
                      ),
                      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                    });
                  }
                });

              // add FNSI 1006 No.538 治療記録 外部連携APIを呼び出 start -- Sanjingye Sun 20210112
              createJournal(params);
              // add FNSI 1006 No.538 治療記録 外部連携APIを呼び出 end -- Sanjingye Sun 20210112
            },
          });
          return;
        }
      }
      // 治療方法が変更されていない場合、治療方法は変更されているが何もしない場合
      // #10518 2024.04.22 mod 治療開始時刻の変更フラグを引数に追加 TDC米沢 start
      //this.saveTreatmentRecordResult(bedChangeFlag);
      this.saveTreatmentRecordResult(bedChangeFlag, isChangeStartDate);
      // #10518 2024.04.22 mod 治療開始時刻の変更フラグを引数に追加 TDC米沢 end
      // add FNSI 1006 No.538 治療記録 外部連携APIを呼び出 start -- Sanjingye Sun 20210112
      createJournal(params);
      // add FNSI 1006 No.538 治療記録 外部連携APIを呼び出 end -- Sanjingye Sun 20210112
      let elements = getScopedElementsByClassName("custom-input-edited", this.$el || null);
      for (let i = elements.length - 1; i >= 0; i--) {
        elements[i].classList.remove("custom-input-edited");
      }
      if (this.$refs["actual_model_component"] != undefined) {
        this.$refs["actual_model_component"].initValueEdit();
      }
    },
    /**
     * 実績情報の保存処理
     */
    // #10518 2024.04.22 mod 治療開始時刻の変更フラグを引数に追加 TDC米沢 start
    //saveTreatmentRecordResult(bedChangeFlag) {
    saveTreatmentRecordResult(bedChangeFlag, isChangeStartDate) {
      // #10518 2024.04.22 mod 治療開始時刻の変更フラグを引数に追加 TDC米沢 end
      //add FNSI-redmine6089 fang start
      this.deleteMakrDel();
      //add FNSI-redmine6089 fang end
      // api用のパラメータ生成
      const payload = {
        ordNo: this.getOrdNo,
        treatmentRecordResult: this.actualModel,
      };
      this.updateTreatmentRecordResult(payload)
        .then(() => {
          // 初期化処理を実行
          this.init();
          // 概要欄情報の更新
          this.setTreatmentUpdate(new Date());
          // 予実リストの更新
          this.setResultUpdate(new Date());
          // 子機能ボタンエリアの更新
          this.$emit("update");
          if (bedChangeFlag) {
            this.updateMniMachineState({
              ordNo: this.getOrdNo,
              bedNo: this.actualModel.rst_bed_cd,
            }).then((response) => {
              // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
              if (response.data) {
                // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
                const params = {
                  ordNo: this.getOrdNo, //オーダー番号
                  machineNo: response.data[1], //装置マスタ.装置番号
                  deviceEdgeNo: response.data[0], //デバイスエッジ番号
                  facilityCd: this.facilityCd, //施設コード
                };
                this.sendNextPatInfo(params);
                // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
              }
              // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
            });
          }

          // #10518 2024.04.22 add 治療開始時刻の変更があった場合は「オフライン運転タイマー更新」通知を行う TDC米沢 start
          // 治療開始日時が変更された場合はデバイスエッジへ通知
          if (isChangeStartDate) {
            const params = {
              ordNo: this.getOrdNo, //オーダー番号
              facilityCd: this.facilityCd, //施設コード
            };
            this.sendRequestChangeTreatTime(params);
          }
          // #10518 2024.04.22 add 治療開始時刻の変更があった場合は「オフライン運転タイマー更新」通知を行う TDC米沢 end
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage(
            "ResultComponent.vue",
            "saveTreatmentRecordResult",
            "必須項目が入力されていません"
          );
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              // message: "必須項目が入力されていません。"
              title: DIALOG_MESSAGES["00200070"].title,
              message: messageFormat(DIALOG_MESSAGES["00200070"].message),
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }
        });
    },
    onClickCancel() {
      // 編集済みであれば確認ダイアログを表示して初期化処理を実行
      if (this.isChanged) {
        this.discardConfirm(this.backTreatmentRecord);
      } else {
        this.backTreatmentRecord();
      }
    },
    // 透析回数を表示するか特殊浄化回数を表示するかの判定
    checkIsPurification() {
      const newTreatmentCd = this.actualModel.rst_treatment_cd;
      //mod 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start
      // const toDeviceMode = this.getDeviceModeForTreatmentCd(newTreatmentCd);
      // this.isPurification = toDeviceMode === CODES.DEVICE_MODE.PURIFICATION.cd;
      this.newDeviceMode = this.getDeviceModeForTreatmentCd(newTreatmentCd);
      this.isPurification = this.newDeviceMode === CODES.DEVICE_MODE.PURIFICATION.cd;
      //mod 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end
    },
    reflectResultSub(value) {
      Object.assign(this.actualModel, value);
      this.checkIsPurification();
      //add #12300 20260427 zhaojinzhao start
       this.isTrueChanged()
      //add #12300 20260427 zhaojinzhao end
    },

    /**
     * 穿刺者情報
     * @param {*} value 入力された穿刺者情報
     */
    reflectPunctureUserSub(value) {
      // 穿刺者情報がnullの場合
      if (this.actualModel.rst_puncture_user_info === null) {
        this.actualModel.rst_puncture_user_info = value;
        //add #12300 20260427 zhaojinzhao
        this.isTrueChanged()
      } else {
        ((this.actualModel)["rst_puncture_user_info"] = value)
        this.isTrueChanged()
      }
    },
    /**
     * 返血者情報
     * @param {*} value 入力された返血者情報
     */
    reflectReturnUserSub(value) {
      if (this.actualModel.rst_return_user_info === null) {
        this.actualModel.rst_return_user_info = value;
      //add #12300 20260427 zhaojinzhao
        this.isTrueChanged()
      } else {
        ((this.actualModel)["rst_return_user_info"] = value)
        this.isTrueChanged()
      }
    },
    /**
     * 担当者情報
     * @param {*} value 入力された担当者情報
     */
    reflectChargeUserSub(value) {
      if (this.actualModel.rst_charge_user_info === null) {
        this.actualModel.rst_charge_user_info = value;
      //add #12300 20260427 zhaojinzhao
        this.isTrueChanged()
      } else {
        ((this.actualModel)["rst_charge_user_info"] = value);
        this.isTrueChanged()
      }
    },
    // コンボリストと実績情報の突合
    comboListMatching() {
      // 下記のデータが全てロード済(!==undefined)になった場合に1回だけ実行する
      const dataList = [
        this.actualModel.rst_in_out_class,
        this.comboList.kur,
        this.comboList.bed,
        this.comboList.ward,
        this.comboList.course,
        this.comboList.treatment,
      ];

      if (!this.comboListMatched && !dataList.includes(undefined)) {
        this.comboListMatchingBody(
          this.comboList.kur,
          this.actualModel.rst_kur_cd,
          this.actualModel.rst_kur_name,
          `rst_kur_name`
        );
        this.comboListMatchingBody(
          this.comboList.bed,
          this.actualModel.rst_bed_cd,
          this.actualModel.rst_bed_name,
          `rst_bed_name`
        );
        this.comboListMatchingBody(
          this.comboList.ward,
          this.actualModel.rst_ward_cd,
          this.actualModel.rst_ward_name,
          `rst_ward_name`
        );
        this.comboListMatchingBody(
          this.comboList.course,
          this.actualModel.rst_course_cd,
          this.actualModel.rst_course_name,
          `rst_course_name`
        );
        this.comboListMatchingBody(
          this.comboList.treatment,
          this.actualModel.rst_treatment_cd,
          this.actualModel.rst_treatment_name,
          `rst_treatment_name`
        );
        // add #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc start
        //治療項目名
        const matchingTreat = this.comboList.treatment.find(
          (item) =>
            item.cd == this.initResponseData.rst_treatment_cd &&
            item.text != this.initResponseData.rst_treatment_name
        );
        if (matchingTreat) {
          this.comboList.treatment.unshift({
            cd: this.initResponseData.rst_treatment_cd,
            text: this.initResponseData.rst_treatment_name,
            hidden: true,
          });
        }
        //クール名
        const matchingKur = this.comboList.kur.find(
          (item) =>
            item.cd == this.initResponseData.rst_kur_cd &&
            item.text != this.initResponseData.rst_kur_name
        );
        if (matchingKur) {
          this.comboList.kur.unshift({
            cd: this.initResponseData.rst_kur_cd,
            text: this.initResponseData.rst_kur_name,
            hidden: true,
          });
        }
        //ベッド名
        const matchingBed = this.comboList.bed.find(
          (item) =>
            item.cd == this.initResponseData.rst_bed_cd &&
            item.text != this.initResponseData.rst_bed_name
        );
        if (matchingBed) {
          this.comboList.bed.unshift({
            cd: this.initResponseData.rst_bed_cd,
            text: this.initResponseData.rst_bed_name,
            hidden: true,
          });
        }
        //診療科
        const matchingCourse = this.comboList.course.find(
          (item) =>
            item.cd == this.initResponseData.rst_course_cd &&
            item.text != this.initResponseData.rst_course_name
        );
        if (matchingCourse) {
          this.comboList.course.unshift({
            cd: this.initResponseData.rst_course_cd,
            text: this.initResponseData.rst_course_name,
            hidden: true,
          });
        }
        //病棟名
        const matchingWard = this.comboList.ward.find(
          (item) =>
            item.cd == this.initResponseData.rst_ward_cd &&
            item.text != this.initResponseData.rst_ward_name
        );
        if (matchingWard) {
          this.comboList.ward.unshift({
            cd: this.initResponseData.rst_ward_cd,
            text: this.initResponseData.rst_ward_name,
            hidden: true,
          });
        }
        // add #8896 条件送信後の治療記録画面で名称をマスタ参照している項目がある 20230701 ztc end
        this.comboListMatched = true;
      }
    },
    comboListMatchingBody(list, cd, text, fieldName) {
      const node = list.find((elem) => elem.cd === cd);

      // 名称変更/削除なしの場合は何もしない
      if (node !== undefined && node.text === text) {
        return;
      }

      // 過去実績の場合はリストに追加
      if (
        this.actualModel.rst_dialysis_state ===
        CODES.DIALYSIS_STATE.CONFIRMED_WEIGHT_MEASURING.cd
      ) {
        if (node === undefined) {
          //mod FNSI-8347 ljx start(8347より、新方法が使われるため、特別処理はないので、この処理を戻す)
          //add FNSI-6777 ljx start
          //ベッドのコードが特別処理されるのため、実際に削除されない、この場合、「削除済み含む」という文字が付ける必要ない。
          /* if(!cd.toString().includes("000000000")){
            text = text ? `${text}【削除済み含む】` : "";
          }*/
          text = text ? `${text}【削除済み含む】` : "";
          //mod FNSI-8347 ljx end
          //add FNSI-6777 ljx end
        }

        list.unshift({ cd: cd, text: text, hidden: true });
        return;
      } else {
        // 過去実績以外の場合
        // マスタ削除の場合は【削除】を付加
        if (node === undefined) {
          //mod FNSI-8347 ljx start(8347より、新方法が使われるため、特別処理はないので、この処理を戻す)
          //add FNSI-6777 ljx start
          //ベッドのコードが特別処理されるのため、実際に削除されない、この場合、「削除済み含む」という文字が付ける必要ない。
          /* if(!cd.toString().includes("000000000")){
          text = text ? `【削除済み】${text}` : "";
          }*/
          text = text ? `【削除済み】${text}` : "";
          //add FNSI-6777 ljx end
          //mod FNSI-8347 ljx end
          list.unshift({ cd: cd, text: text, hidden: true });
        } else {
          // マスタ名称変更の場合は最新名称に更新
          this.actualModel[fieldName] = node.text;
          // 編集した内容を編集前比較用として保存
          this.initComparisonModel();
        }
      }
    },
    /**
     * 再描画処理
     */
    refresh() {
      // 子機能ボタンエリアの更新
      this.$emit("update");
      if (this.selfScreenName !== this.$route.name) {
        return;
      }
      //mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 start
      //mod メッセージ順番修正 房 start
      // if (this.isChanged && this.alertFlag) {
      //   this.discardConfirm(this.init);
      // } else {
      //   this.init();
      // }
      this.init()
      //mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 end
      this.alertFlag = true;
      //mod メッセージ順番修正 房 end
    },
     // add 10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
     eventBusRefresh() {
      if (this.selfScreenName !== this.$route.name) {
        return;
      }
      if (this.isChanged && this.alertFlag) {
        this.discardConfirm(this.init);
      } else {
        this.init();
      }
      this.alertFlag = true;
    },
    // add 10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
    //add メッセージ順番修正 房 start
    getChangeStatus(){
      return this.isChanged;
    },
    updateChangeStatus(){
      this.alertFlag = false;
    },
    //add メッセージ順番修正 房 end
    //add FNSI-redmine6089 fang start
    deleteMakrDel(){
      this.actualModel.rst_bed_name = this.markDel("rst_bed_name");
      this.actualModel.rst_treatment_name = this.markDel("rst_treatment_name");
      this.actualModel.rst_kur_name = this.markDel("rst_kur_name");
      this.actualModel.rst_ward_name = this.markDel("rst_ward_name");
      this.actualModel.rst_course_name = this.markDel("rst_course_name");
    },
    markDel(name) {
      let mark = this.actualModel[name];
      if (mark != null && mark != undefined) {
        if (mark.indexOf("【削除済み】") > 0) {
          mark = mark.replace("【削除済み】", "");
        }
        if (mark.indexOf("【削除済み含む】") > 0) {
          mark = mark.replace("【削除済み含む】", "");
        }
      }
      return mark;
    },
    //add FNSI-redmine6089 fang end
  },
  // FNSI-add 診療科表示不正 徐 start
  // created() {
  async created() {
    // 画面名称取得
    this.selfScreenName = this.$route.name;
    // FNSI-add 診療科表示不正 徐 end
    // 子コンポーネントで使用するコンボリストを取得
    const emptyOption = { text: null, cd: null };
    // クール
    this.getKurComboList({ selectedPatId: this.selectedPatId }).then(
      (response) => (this.comboList.kur = response.data)
    );
    // ベッド
    this.getBedComboList({ selectedPatId: this.selectedPatId }).then(
      (response) => (this.comboList.bed = response.data)
    );
    // 病棟
    this.getWardComboList({ selectedPatId: this.selectedPatId }).then((response) => {
      this.comboList.ward = [emptyOption].concat(response.data);
    });
    // 診療科
    this.getCourseComboList({ selectedPatId: this.selectedPatId }).then((response) => {
      this.comboList.course = [emptyOption].concat(response.data);
    });
    // 治療方法マスタ
    this.getTreatmentMethodComboList({ selectedPatId: this.selectedPatId }).then((response) => {
      this.comboList.treatment = [emptyOption].concat(response.data);
    });
    // イベント登録
    // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
    // EventBus.$on("refresh", this.refresh);
    EventBus.$on("refresh", this.eventBusRefresh);
    // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
    // OrdMainレコードをチェックする
    if (!this.checkOrdNo()) {
      return;
    }
    // 治療記録(実績情報取得)
    // FNSI-add 診療科表示不正 徐 start
    // this.init();
    await this.init();
    // FNSI-add 診療科表示不正 徐 end
  },
  // add 共有設定の追加 周雨晴 2020/09/22 start
  mounted() {
    const submenu = getScopedElementsByClassName("select-btn", this.$el || null);
    if (
      this.getSharedFacilityCd !== undefined &&
      this.getSharedFacilityCd != null
    ) {
      if (
        this.getSharedFlag === 1 &&
        this.facilityCd !== this.getSharedFacilityCd
      ) {
        for (let i = 0; i < submenu.length; i++) {
          submenu[i].disabled = true;
        }
      } else {
        for (let i = 0; i < submenu.length; i++) {
          submenu[i].disabled = false;
        }
      }
    } else {
      for (let i = 0; i < submenu.length; i++) {
        submenu[i].disabled = false;
      }
    }
    // add 共有設定の追加 周雨晴 2020/09/22 end
  },
  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
    // del refresh方法処理不正について、対応する。 dengshen start
    // EventBus.$off("refresh");
    // del refresh方法処理不正について、対応する。 dengshen end
    // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
    EventBus.$off("refresh", this.eventBusRefresh);
    // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
  },
};
</script>

<style scoped>
#result-sub {
  overflow: hidden;
  border: 1px solid #dddddd;
}
#puncture-user-sub {
  overflow: hidden;
  border: 1px solid #dddddd;
}
#return-user-sub {
  overflow: hidden;
  border: 1px solid #dddddd;
}
#charge-user-sub {
  overflow: hidden;
  border: 1px solid #dddddd;
}
:deep(.common-style-select-button){
  margin-left: 5px !important;
}
</style>
