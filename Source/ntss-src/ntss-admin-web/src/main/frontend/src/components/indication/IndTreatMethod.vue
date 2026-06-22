/** * 治療方法 */

<template>
  <div>
    <v-ons-row class="cond-row-style">
      <v-ons-col class="indInfo-style-label-position">
        <label>治療方法</label>
      </v-ons-col>
      <v-ons-col>
        <!--mod FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 start-->
        <!--
        <span v-for="tmc in treatMethodCList" :key="tmc.value" style="white-space: normal;">
          <input
            v-model="showPlanCreate"
            type="radio"
            name="radioTreatMethodC"
            :id="`radio-TMC-${tmc.value}`"
            :value="tmc.value"
            @change="changeTMC(tmc.value)"
          /><label :for="`radio-TMC-${tmc.value}`" >{{ tmc.label }}</label>
          <v-ons-icon icon="fa-question-circle"
            @click="showPopOver($event, tmc.msg)"
          ></v-ons-icon>
          <br/>
        </span>
        -->
        <!-- FNSI-治療方法説明文の表示を修正 周 mod start -->
        <!-- <span v-for="tmc in treatMethodCList" :key="tmc.value" style="white-space: normal;">
          <custom-radio
            :value="displayInputValue"
            :name="uniqueRadioName"
            :radio-value="tmc.value"
            @change="changeTMC(tmc.value)"
          ></custom-radio>
          <label :for="`radio-TMC-${tmc.value}`" >{{ tmc.label }}</label>
          <v-ons-icon icon="fa-question-circle"
            @click="showPopOver($event, tmc.msg)"
          ></v-ons-icon>
          <br/>
        </span> -->
        <span v-for="tmc in treatMethodCList" :key="tmc.value" style="white-space: normal;">
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <custom-radio -->
          <!--   :input-id="`radio-TMC-${tmc.value}`" -->
          <!--   :value="displayInputValue" -->
          <!--   :name="uniqueRadioName" -->
          <!--   :radio-value="tmc.value" -->
          <!--   @change="changeTMC(tmc.value)" -->
          <!-- ></custom-radio> -->
          <custom-radio
            :input-id="`radio-TMC-${tmc.value}`"
            :value="displayInputValue"
            :name="uniqueRadioName"
            :radio-value="tmc.value"
            @change="changeTMC(tmc.value)"
            :disabled="!getItemAuthorized('Indication', 'default_authority')"
          ></custom-radio>
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <label :for="`radio-TMC-${tmc.value}`" >{{ tmc.label }}</label>
          <v-ons-icon icon="fa-question-circle"
            @click="showPopOver($event, tmc.msg)"
          ></v-ons-icon>
          <br/>
        </span>
        <!-- FNSI-治療方法説明文の表示を修正 周 mod end -->
        <!--mod FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 end-->
      </v-ons-col>
    </v-ons-row>

    <!-- 治療方法のみ変更 -->
    <div v-if="showPlanCreate == 1">
      <v-ons-row class="div-style">
        <v-ons-col class="indInfo-style-label-position" />
        <v-ons-col>
          <v-ons-select
            v-model="selectedTreat"
            style="width: 100%;"
          >
            <option
              v-for="(mt, index) in mstTreatmentList"
              :key="index"
              :value="mt.treatmentCd"
            >
              {{ mt.treatmentName }}
            </option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>
    </div>

    <!-- 治療方法セットの投与薬剤を含んで変更する / 含まずに変更する -->
    <div v-if="showPlanCreate == 2 || showPlanCreate == 3">
      <!-- radio2/radio3: 1インスタンスでprops切替（2↔3でAPI・重複idによるレイアウト崩れを防ぐ） -->
      <ind-plan-create
        ref="activePlanCreate"
        @computedValueChanged="handleComputedValueChanged"
        :is-update-method="true"
        :is-medi-info="showPlanCreate == 2"
      />
    </div>
    <v-ons-popover
      cancelable
      v-model:visible="userMenuPopoverVisible"
      :target="userMenuPopoverTarget"
      :cover-target="false"
      :direction="userMenuPopoverDirection"
      :class="fontSizeSet"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <p id="popOverMessage"></p>
    </v-ons-popover>
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
// mod FNSI-連携イベントの登録適正化 楊 start
// import {mapActions} from "@/compat/vue/vuex";
import {mapActions, mapGetters} from "@/compat/vue/vuex";
// mod FNSI-連携イベントの登録適正化 楊 end
import { ApiHelper } from "@/apis/AxiosHelper";
import IndicationOwnerMixin from "@/components/indication/IndicationOwnerMixin";
import IndPlanCreate from "@/components/indication/IndPlanCreate";
import PopoverMixin from "@/components/PopoverMixin";
// add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
// add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
/**
 * 日時取得
 */
import dayjs from "@/compat/date/dayjs";
import { EventBus } from "@/compat/vue/event-bus.js";
// mod FNSI-連携イベントの登録適正化 楊 start
// add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou start
import { createJournalList } from "@/apis/journal";
// add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou end
// mod FNSI-連携イベントの登録適正化 楊 end
// add FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 start
import customRadio from "@/components/common/custom-form-tags/CustomRadio";
// add FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 end
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start

import { getScopedElementById } from "@/functions/common/LayoutMeasureHelper";
import { nextId } from "@/functions/common/id";
import { messageFormat } from "@/functions/common/MessageFormat";

// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
// add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
// del #11004 連携イベント発生部分不正 piao start
// import { sendRequestGetCoopIniSchModifySendClass } from "@/apis/treatment-record";
// del #11004 連携イベント発生部分不正 piao end
// add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end

export default {
  name: "IndTreatMethod",

  mixins: [IndicationOwnerMixin, PopoverMixin],

  components: {
    "ind-plan-create": IndPlanCreate,
    // add FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 start
    "custom-radio": customRadio
    // add FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 end
  },

  props: {
    indKurName: {
      type: String,
      default: null
    },
    indTreatStartTime: {
      type: String,
      default: null
    },
    // add FNSI-濃度プログラムチェックの追加 楊 start
    isDev: {
      type: Boolean,
      default: false
    },
    // add FNSI-濃度プログラムチェックの追加 楊 start
    indBedName: {
      type: String,
      default: null
    }
  },

  data() {
    return {
      selectedTreat: null,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
      initSelectedTreat: null,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
      showPlanCreate: "3",
      treatMethodCList: [
        { value: "1",
          label: "治療方法のみ変更",
          // mod #10545 治療方法変更の文書修正
          // msg: "選択した治療方法により治療方法の有効化、無効化されます。\n予定に登録されている、投与薬剤、医療材料、指示コメントはそのまま有効となります。",
          msg: "選択した治療方法により治療条件の有効・無効化がされます。\n" +
               "予定に登録されている、投与薬剤、医療材料、指示コメントはそのままとなります。",
          checked: false
        },
        {
          value: "2",
          label: "治療方法セットの内容で全て変更",
          // mod #10545 治療方法変更の文書修正
          // msg: "予定に登録されている、投与薬剤、医療材料、指示コメントを全て中止し、選択した治療方法セットの治療条件、投与薬剤、医療材料、指示コメントに変更します。",
          msg: "予定に登録されている、投与薬剤、医療材料、指示コメントを全て中止し、選択した治療方法セットの治療条件、投与薬剤、医療材料、指示コメント、装置プログラムに変更します。",
          checked: false
        },
        {
          value: "3",
          // mod #10545 治療方法変更の文書修正
          // label: "治療方法セットの内容で治療条件と医療材料を変更",
          label: "治療方法セットの内容で治療条件と医療材料、装置プログラムを変更",
          // msg: "予定に登録されている、医療材料を全て中止し、選択した治療方法セットの治療条件、医療材料に変更します。\n予定に登録されている、投与薬剤、指示コメントはそのまま有効となり、治療方法セットに登録されている投与薬剤、指示コメントは展開しません。",
          msg: "予定に登録されている、医療材料を全て中止し、選択した治療方法セットの治療条件、医療材料、装置プログラムに変更します。\n" +
               "予定に登録されている、投与薬剤、指示コメントはそのままとなり、治療方法セットに登録されている投与薬剤、指示コメントは展開しません。",
          checked: false
        }
      ],
      indStartDate: this.startDate,
      indEndDate: this.endDate,
      structData: this._indicationFlowOwner().structData,
      /**
       * IndTreatMethod内の治療方法リスト
       */
      treatDateList: [],
      /**
       * IndTreatMethod内の治療方法リスト初期データ
       */
      initTreatDateList: [],
      // 吹き出し関連制御
      userMenuPopoverVisible: false,
      userMenuPopoverTarget: null,
      userMenuPopoverDirection: "down",
      // mod FNSI-連携イベントの登録適正化 楊 start
      oldOrdMainList: [],
      // mod FNSI-連携イベントの登録適正化 楊 end

      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
      // del #11004 連携イベント発生部分不正 piao start
      // objModSendClass: "",
      // del #11004 連携イベント発生部分不正 piao end
      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end

      // add FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 start
      displayInputValue: {
        initValue: "3",
        editValue: "3"
      },
      // add FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 end
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
      isHandleChanged: false
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
    };
  },

  computed: {
    // mod FNSI-連携イベントの登録適正化 楊 start
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("pat-viewer-modal", { settingIndData : "getSettingIndData" }),
    // mod FNSI-連携イベントの登録適正化 楊 end
    // add FNSI-連携イベントの登録適正化 李 start
    ...mapGetters("pat-info", ["selectedPat"]),
    // add FNSI-連携イベントの登録適正化 李 end

    // add 6925治療モードを変更した際の制限事項，注意メッセージについて 張岩 start
    ...mapGetters("pat-viewer", ["getSelectedLayout"]),
    // add 6925治療モードを変更した際の制限事項，注意メッセージについて 張岩 end
    mstTreatmentList() {
      return this.treatDateList;
    },

    // add FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 start
    uniqueRadioName() {
      return nextId("autoSelectRadio");
    },
    // add FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 end

    /**
     * スケジュール情報
     */
    scheduleInfo() {
      return {
        indKurName: this.indKurName,
        indTreatStartTime: this.indTreatStartTime,
        indBedName: this.indBedName
      };
    }
  },

  async created() {
    // 治療方法リスト取得
    await this.getMstTreatmentList();
    // IndEditBaseで治療方法選択の最大選択数を1に設定
    this._indicationDialogOwner().treatMaxSelectedItems = 1;
    this.selectedTreat = this.mstTreatmentList[0].treatmentCd;
    //FNSI-修正 #5525 横展開対応、xugj add start
    this._indicationResultOwner().isSendNextPatInfoFlg = true;
    //FNSI-修正 #5525 横展開対応、xugj add end
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
    this.initSelectedTreat = JSON.stringify(this.selectedTreat);
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
  },
  // add FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 start
  watch: {
    displayInputValue: {
      handler({ editValue }) {
        this.displayInputValue.editValue = editValue;
      },
      deep: true
    }
   },
   // add FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 end

  methods: {
    ...mapActions('loading-screen', [
      "startLoadingScreen",
      "finishLoadingScreen"
    ]),
    //mod FNSI-6590 劉全航 start
    ...mapActions("treatment-record/common",
      [
        "getMstMachineByOrdNoRst",
        "sendNextPatInfoViewer"
      ]),
      //mod FNSI-6590 劉全航 end
    // 予実リストへの変更通知
    ...mapActions("indication-result", ["setResultUpdate"]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    // del FNSI-連携イベントの登録適正化 李 start
    // mod FNSI-連携イベントの登録適正化 楊 start
    // ...mapGetters("pat-info", ["selectedPat"]),
    // mod FNSI-連携イベントの登録適正化 楊 end
    // del FNSI-連携イベントの登録適正化 李 end
    changeTMC(value) {
      this.showPlanCreate = value;
      if (value === "2" || value === "3") {
        this.$nextTick(() => {
          setTimeout(() => {
            this.$refs.activePlanCreate?.refreshColumnWidth?.();
          }, 500);
        });
      }
    },

    // 保存ボタン押下時処理
    async updateIndInfo(structData) {
      console.log("IndTreatMethod.vue updateIndInfo this.startLoadingScreen();");
      this.startLoadingScreen();
      structData.treatMethodFlag = Number(this.showPlanCreate) - 1;
      // mod FNSI-連携イベントの登録適正化 楊 start
      // 古いリスト
      const startDate = structData.indStartDate.replace(/-/g, '');
      const endDate = structData.indEndDate == null ? null : structData.indEndDate.replace(/-/g, '');
      const searchData = await ApiHelper.get(
        `/mainData/getByPatIdAndTreatDate/${structData.facilityCd}/${structData.patId}/${startDate}/${endDate}`
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndTreatMethod.vue', 'updateIndInfo', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        console.log("IndTreatMethod.vue updateIndInfo throw error; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        throw error;
      });
      this.oldOrdMainList = searchData.data;
      // mod FNSI-連携イベントの登録適正化 楊 end

      if (this.showPlanCreate === "1") {
        const sendJson = {};
        // 治療方法名
        sendJson.treatment_name = this.mstTreatmentList.find(item => {
          return item.treatmentCd === Number(this.selectedTreat);
        }).treatmentName;
        // 治療方法コード
        sendJson.treatment_set_cd = Number(this.selectedTreat);
        // 更新日時
        sendJson.up_date = dayjs().format("YYYY-MM-DD HH:mm:ss.SSS");
        // 患者ID
        sendJson.pat_id = structData.patId;
        // 開始日
        sendJson.start_date = structData.indStartDate;
        // 終了日
        sendJson.end_date = structData.indEndDate;
        // 施設コード
        sendJson.facility_cd = structData.facilityCd;
        // 曜日Jsonデータ
        sendJson.week_pattern = JSON.stringify(structData.indWeeks);
        // 変更対象クール
        // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  strat
        // sendJson.target_kur_cd = JSON.stringify(structData.selectedKur);
        sendJson.ind_kur_cd = JSON.stringify(structData.selectedKur);
        // 変更対象治療方法
        // sendJson.target_treatment_cd = JSON.stringify(structData.selectedTreat);
        sendJson.ind_treatment_cd = JSON.stringify(structData.selectedTreat);
        // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  end
        // 指示者コード
        sendJson.ind_user_id = structData.indUser;
        // 更新者コード
        sendJson.upd_user_id = structData.updUser;
        // 治療方法変更フラグ
        sendJson.treat_method_flag = structData.treatMethodFlag;
        // add 9281 日次処理にて正しくスケジュールが作成されない事がある 関 start
        // 装置モード
        sendJson.device_mode =  this.mstTreatmentList.find(item => {
          return item.treatmentCd === Number(this.selectedTreat);
        }).deviceMode;
        // add 9281 日次処理にて正しくスケジュールが作成されない事がある 関 end
        // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  strat
        sendJson.startsFlg = structData.ordNo ? "0123456" : "0";
        if (structData.rstDialysisState != "0" && structData.ordNo) {
          await this.$ons.notification.confirm({
            title: DIALOG_MESSAGES[13000050].title,
            message: messageFormat(DIALOG_MESSAGES[13000050].message),
            callback: answer => {
              if (answer === 1) {
                sendJson.rst_flag = true;
                }else{
                  sendJson.rst_flag = false;
                }
              }
            });
        }else {
          sendJson.rst_flag = false;
        }
        // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  end
        // 終了日格納有無
        sendJson.is_deadline = structData.isDeadline;
        // スキップ更新フラグ
        sendJson.is_skip_update = structData.isSkipFlag
          ? structData.isSkipFlag
          : null;
        // mod FNSI-障害票一覧_患者経過総合ビューアNo.47 李 start
        // const response = await ApiHelper.post(
        //   "/mainData/updatetByTreatSetCd/",
        //   sendJson
        // ).catch(error => {
        //   throw error;
        // });
        sendJson.hosp_pat_id = this.selectedPat.pat_personal_main.hosp_pat_id;
        sendJson.user_id = this.getStateUserAccountInfo.userId;
        // add FNSI-7325 劉全航 start
        sendJson.invoke_page_name = "pat-viewer";
        //mod 8260 2023-02-27 患者経過総合ビューアで治療方法を変更すると不要な連携イベントが作成される 張 start
        sendJson.creat = true;
        // add FNSI-7325 劉全航 end
        const response = await ApiHelper.post(
          "/mainData/updatetByTreatSetCd2",
          sendJson
        );
        // mod FNSI-障害票一覧_患者経過総合ビューアNo.47 李 end

        // mod FNSI-連携イベントの登録適正化 楊 start
        if (200 === response.status) {
          // 連携イベントの登録適正化
          //mod FNSI-5525 劉全航 start
          this.updateNextPatInfo(structData);
          //mod FNSI-5525 劉全航 end
          // this.createJournalApi(structData);
          //　add  #7324 2022-04-24 患者経過総合ビューアで治療方法を変更してもイベント作成されない  孟堅　start
          // this.createJournalApi(structData);
          //　add  #7324 2022-04-24 患者経過総合ビューアで治療方法を変更してもイベント作成されない  孟堅　end
          //add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou start
          this.createJournalApi(structData);
          //add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou end
        }
        // mod FNSI-連携イベントの登録適正化 楊 end
      //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start
      // mod #8420 【IES起票】【画面】【患者経過総合ビューア】治療方法変更にエラーが発生 dou start
      // if (200 === response.status && undefined !== response.data.msglist) {
      if (200 === response.status && undefined !== response.data.msglist && response.data.msglist.length > 0) {
      // mod #8420 【IES起票】【画面】【患者経過総合ビューア】治療方法変更にエラーが発生 dou end
        let msgList = response.data.msglist;
        let messages = "";
       //mod 6623 HD→HDF，HF，OHDF，OHF，I-HDFへ切り替えたときに表示されるメッセージが意味不明 張 start
      //  msgList.forEach(item => {
      //     messages = messages + this.messageInfo(item) + "<br>";
      //   })
      //   this.$ons.notification.alert({
      //     title: "",
      //     message: messages,
      //     callback: answer => {
      //     if (answer == 0) {
      //       //OK
      //        // モーダルを閉じる
      //       this.hideModal();
      //     }
      //   }
      //   });
      // }
      //add 6623 HD→HDF，HF，OHDF，OHF，I-HDFへ切り替えたときに表示されるメッセージが意味不明 張 start
      //add 6925治療モードを変更した際の制限事項，注意メッセージについて 張岩 start
      let layouts=[]
      if (this.getSelectedLayout) {
      this.getSelectedLayout[0].categoryItem.forEach(ele=> {
          if(ele.subCategoryNo==10||ele.subCategoryNo==11||ele.subCategoryNo==12||
          ele.subCategoryNo==13||ele.subCategoryNo==15||ele.subCategoryNo==16){
            layouts.push(ele.subCategoryNo)
          }
      })
      }
      //add 6925治療モードを変更した際の制限事項，注意メッセージについて 張岩 end
        let showMessage = false;
        // add #10154 ダイアライザが積層の場合に、治療方法IHDFは積層ダイアライザの場合に注意喚起メッセージが出ない。 dou start
        if (msgList.includes("12000025")) {
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES[12000025].title,
            message: this.messageInfo(12000025),
            callback: answer => {
              if (answer == 0) {
                this.hideModal();
              }
            }
          });
        }
        // add #10154 ダイアライザが積層の場合に、治療方法IHDFは積層ダイアライザの場合に注意喚起メッセージが出ない。 dou end
        //del #10154_#10183 zhao start
        // add start 馬 #9642
        // if (msgList.includes("13000167")) {
        //   this.$ons.notification.alert({
        //     title: DIALOG_MESSAGES[13000167].title,
        //     message: this.messageInfo(13000167)
        //   });
        // }
        // add end 馬 #9642
        //del #10154_#10183 zhao end
        //add 6925治療モードを変更した際の制限事項，注意メッセージについて 張岩 start
        //add 6146 2023-03-31 治療方法変更時のメッセージが不正 張 start
        if (msgList.includes("12000021")) {
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES[12000021].title,
            message: this.messageInfo(12000021),
            callback: answer => {
            if (answer == 0) {
              this.hideModal();
            }
          }
          });
        }
        //#10625 指示制約修正 zrx start
        if (msgList.includes("12000351")) {
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES[12000351].title,
            message: this.messageInfo(12000351),
            callback: answer => {
              if (answer == 0) {
                this.hideModal();
              }
            }
          });
        }
        //#10625 指示制約修正 zrx end
        //add 6146 2023-03-31 治療方法変更時のメッセージが不正 張 end
            if (msgList.includes("12000020")) {
          this.$ons.notification.alert({
            //mod 7895 2022-12-28 治療時間10時間以上の予定の治療方法を変更した際のメッセージ不正 張 start
            // title: "",
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "治療時間上限",
            title: DIALOG_MESSAGES[12000020].title,
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            //mod 7895 2022-12-28 治療時間10時間以上の予定の治療方法を変更した際のメッセージ不正 張 start
            message: this.messageInfo(12000020),
            callback: answer => {
            if (answer == 0) {
              //OK
              // モーダルを閉じる
              this.hideModal();
            }
          }
          });
        }
        //add 6925治療モードを変更した際の制限事項，注意メッセージについて 張岩 end
        if (msgList.includes("12000074")) {
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "除水プログラム設定変更通知",
            title: DIALOG_MESSAGES["12000074"].title,
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            message: this.messageInfo(12000074),
            callback: answer => {
            if (answer == 0) {
              //OK
              // モーダルを閉じる
              this.hideModal();
            }
          }
          });
        }
        //mod FNSI-6623 劉全航 start
        if (msgList.includes("12000024")) {
          this.$ons.notification.alert({
            title: "注意",
            message: this.messageInfo(12000024),
            callback: answer => {
            if (answer == 0) {
              //OK
              // モーダルを閉じる
              this.hideModal();
            }
          }
          });
        }
        //mod FNSI-6623 劉全航 end
        //mod FNSI-7197 劉全航 start
        if (msgList.includes("16010001")) {
          this.$ons.notification.alert({
            title: "",
            message: this.messageInfo(16010001),
            callback: answer => {
            if (answer == 0) {
              //OK
              // モーダルを閉じる
              this.hideModal();
            }
          }
          });
        }
        if (msgList.includes("12000082")) {
          this.$ons.notification.alert({
            title: "",
            message: this.messageInfo(12000082),
            callback: answer => {
            if (answer == 0) {
              //OK
              // モーダルを閉じる
              this.hideModal();
            }
          }
          });
        }
        if (msgList.includes("12000019")) {
          this.$ons.notification.alert({
            title: "",
            message: this.messageInfo(12000019),
            callback: answer => {
            if (answer == 0) {
              //OK
              // モーダルを閉じる
              this.hideModal();
            }
          }
          });
        }
        // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 start
        if (msgList.includes("22010011")) {
          this.$ons.notification.alert({
            title: "",
            message: this.messageInfo(22010011),
            callback: answer => {
            if (answer == 0) {
              //OK
              // モーダルを閉じる
              this.hideModal();
            }
          }
          });
        }
        if (msgList.includes("22020003")) {
          this.$ons.notification.alert({
            title: "",
            message: this.messageInfo(22020003),
            callback: answer => {
            if (answer == 0) {
              //OK
              // モーダルを閉じる
              this.hideModal();
            }
          }
          });
        }
        // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 end
        //mod FNSI-7197 劉全航 end
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // messages = "治療方法変更に伴い、下記プログラムは強制的にOFFになりました。<br>";
        messages = messageFormat(DIALOG_MESSAGES[12000334].message);
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        msgList.forEach(item => {
          if ("12000074"!=item) {
            //add 6925治療モードを変更した際の制限事項，注意メッセージについて 張岩 start
            if (("12000075"==item&&layouts.includes(10))||("12000076"==item&&layouts.includes(12))||
            ("12000077"==item&&layouts.includes(13))||("12000078"==item&&layouts.includes(15))||
            ("12000079"==item&&layouts.includes(16))||("12000080"==item&&layouts.includes(11))) {
            //add 6925治療モードを変更した際の制限事項，注意メッセージについて 張岩 end
            showMessage=true;
            messages = messages + this.messageInfo(item) + "<br>";
            }
          }
        })
        if (showMessage) {
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "プログラム設定変更通知",
            title: DIALOG_MESSAGES[12000334].title,
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            message: messages,
            callback: answer => {
            if (answer == 0) {
              //OK
              // モーダルを閉じる
              this.hideModal();
            }
          }
          });
        }

        // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
        if (msgList.includes("22020004")) {
          this.showMessage(22020004);
          console.log("IndTreatMethod.vue updateIndInfo return; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          // 処理終了
          return;
        }
        // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end

        //del #10412 次患者更新関連全体見直し対応 朴 start
        //   //add 6590  次患者情報（コメントデータ）が更新されない 張 start
        //     ApiHelper.put(
        //       `/patInfo/updatePhysicalInfoById/${structData.patId}`,
        //       {
        //         needle_flag: true
        //       }
        //     ).catch(error => {
        //       getErrorMessage('IndTreatMethod.vue', 'updateIndInfo', "次患者情報更新失敗");
        //       throw new Error("次患者情報更新失敗");
        //     });
        // //add 6590  次患者情報（コメントデータ）が更新されない 張 end
        //del #10412 次患者更新関連全体見直し対応 朴 end
      }
      //mod 6623 HD→HDF，HF，OHDF，OHF，I-HDFへ切り替えたときに表示されるメッセージが意味不明 張 end
      //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
        // mod bug #7804 修正 chen start
        // mod #8420 【IES起票】【画面】【患者経過総合ビューア】治療方法変更にエラーが発生 dou start
        // if (200 === response.status && undefined !== response.data.msgCd && !response.data.msglist.includes(response.data.msgCd + "")) {
        // mod #8420 2023-03-03【IES起票】【画面】【患者経過総合ビューア】治療方法変更にエラーが発生 張 start
        // if (200 === response.status && undefined !== response.data.msgCd
        //   && undefined !== response.data.msglist && response.data.msglist.length > 0
        //   && !response.data.msglist.includes(response.data.msgCd + "")) {
        if (200 === response.status && undefined !== response.data.msgCd && (undefined==response.data.msglist || !response.data.msglist.includes(response.data.msgCd + "")) ) {
        // mod #8420 2023-03-03【IES起票】【画面】【患者経過総合ビューア】治療方法変更にエラーが発生 張 end
        // mod #8420 【IES起票】【画面】【患者経過総合ビューア】治療方法変更にエラーが発生 dou end
        // if (200 === response.status && undefined !== response.data.msgCd) {
        // mod bug #7804 修正 chen end
          // メッセージ表示
          this.showMessage(response.data.msgCd);
          console.log("IndTreatMethod.vue updateIndInfo return; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          // 処理終了
          return;
        }

        // add FNSI-濃度プログラムチェックの追加 楊 start
        // let deviceMode = this.mstTreatmentList.find(item => {
        //   return item.treatmentCd === Number(this.selectedTreat);
        // }).deviceMode;
        //
        // // 6:AFBFの時は、濃度プログラムを「入り」に出来ないようにする。
        // if (this.isDev && deviceMode === 6) {
        //   // メッセージ表示
        //   this.showMessage("00400007","");
        //   return;
        // }
        // add FNSI-濃度プログラムチェックの追加 楊 end
      } else if (this.showPlanCreate === "2") {
        const activePlanCreate = this.$refs.activePlanCreate;
        if (!activePlanCreate) {
          console.log("IndTreatMethod.vue updateIndInfo return; activePlanCreate not found; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          return;
        }
        // 予定内容が選択されているかチェック
        if (activePlanCreate.checkEdit()) {
          this.showMessage(22010001, "予定内容");
          console.log("IndTreatMethod.vue updateIndInfo return; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          // 以降の処理終了
          return;
        }
        // IndPlanCreate の updateTreatMethod()を呼び出す
        if (
          !(await activePlanCreate.updateTreatMethod(structData))
        ) {
          console.log("IndTreatMethod.vue updateIndInfo return; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          return;
        }
        // mod FNSI-連携イベントの登録適正化 楊 start
        else {
          // 連携イベントの登録適正化
          // this.createJournalApi(structData);
          //　add  #7324 2022-04-24 患者経過総合ビューアで治療方法を変更してもイベント作成されない  孟堅　start
          // this.createJournalApi(structData);
          //　add  #7324 2022-04-24 患者経過総合ビューアで治療方法を変更してもイベント作成されない  孟堅　end
          //add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou start
          this.createJournalApi(structData);
          //add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou end
        }
        // mod FNSI-連携イベントの登録適正化 楊 end
      } else {
        const activePlanCreate = this.$refs.activePlanCreate;
        if (!activePlanCreate) {
          console.log("IndTreatMethod.vue updateIndInfo return; activePlanCreate not found; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          return;
        }
        // 予定内容が選択されているかチェック
        if (activePlanCreate.checkEdit()) {
          this.showMessage(22010001, "予定内容");
          console.log("IndTreatMethod.vue updateIndInfo return; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          // 以降の処理終了
          return;
        }
        // IndPlanCreate の updateTreatMethod()を呼び出す
        if (
          !(await activePlanCreate.updateTreatMethod(
            structData
          ))
        ) {
          console.log("IndTreatMethod.vue updateIndInfo return; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          return;
        }
        // mod FNSI-連携イベントの登録適正化 楊 start
        else {
          // 連携イベントの登録適正化
          // this.createJournalApi(structData);
          //　add  #7324 2022-04-24 患者経過総合ビューアで治療方法を変更してもイベント作成されない  孟堅　start
          // this.createJournalApi(structData);
          //mod 8260 2023-02-27 患者経過総合ビューアで治療方法を変更すると不要な連携イベントが作成される 張 end
          //　add  #7324 2022-04-24 患者経過総合ビューアで治療方法を変更してもイベント作成されない  孟堅　end
          //add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou start
          this.createJournalApi(structData);
          //add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou end
        }
        // mod FNSI-連携イベントの登録適正化 楊 end
      }
      EventBus.$emit("isRefresh");
      // 予実リストの更新
      this.setResultUpdate(new Date());
      console.log("IndTreatMethod.vue updateIndInfo return; this.finishLoadingScreen();");
      this.finishLoadingScreen();
      this.hideModal();
    },
    //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start
    /**
     * 定義ファイルから対応するメッセージコードの文字列を取得
     * @param {object} メッセージコード
     */
    messageInfo(messageCd) {
      // 定義ファイルから対応するメッセージコードの文字列を取得
      const message = DIALOG_MESSAGES[messageCd].message;
      if (message === undefined) {
        return "メッセージが定義されていません。";
      }
      // パラメータ文字列を置換
      let replacedMessage = message;

      // 改行文字列をbrタグに置換
      replacedMessage = replacedMessage.replace(/\n/g, "<br>");
      return replacedMessage;
    },
    // mod 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou start
    //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
    // add FNSI-連携イベントの登録適正化 楊 start
    /**
     * 連携イベントの登録適正化
     */
    // async createJournalApi(structData) {
    //   const params = {
    //     ope_cd: "004003",
    //     crud: "U",
    //     facility_cd: structData.facilityCd,
    //     hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
    //     pat_id: structData.patId,
    //     ord_no : "",
    //     base_date: "",
    //     user_id: this.getStateUserAccountInfo.userId
    //   };
    //   // 明細に治療方法変更の場合
    //   if (this.settingIndData.ordNo) {
    //     // 変更対象クールが未登録ではない、治療方法編集
    //     const oldOrdMain = this.oldOrdMainList.find(ordMain => ordMain.ordNo === this.settingIndData.ordNo);
    //     if (oldOrdMain.indKurCd && (0 !== oldOrdMain.indKurCd)) {
    //          createJournal(...params, ord_no: oldOrdMain.ordNo, base_date: oldOrdMain.treatDate);
    //     }
    //
    //   } else {
    //     // 1件以上治療方法変更の場合
    //     if (this.oldOrdMainList) {
    //       for(let i = 0; i < this.oldOrdMainList.length; i++) {
    //         const item = this.oldOrdMainList[i];
    //         // del #8420 【IES起票】【画面】【患者経過総合ビューア】治療方法変更にエラーが発生 dou start
    //         // const isSelectedTreat = structData.selectedTreat.includes(Number(item.indTreatmentCd));
    //         // const isSelectedKur = structData.selectedKur.includes(Number(item.indKurCd));
    //         // del #8420 【IES起票】【画面】【患者経過総合ビューア】治療方法変更にエラーが発生 dou end
    //         if (structData.selectedKur.length > 0) {
    //           // add #8420 【IES起票】【画面】【患者経過総合ビューア】治療方法変更にエラーが発生 dou start
    //           const isSelectedKur = structData.selectedKur.includes(Number(item.indKurCd));
    //           // add #8420 【IES起票】【画面】【患者経過総合ビューア】治療方法変更にエラーが発生 dou end
    //           if (isSelectedKur) {
    //             // 変更対象クールが未登録ではない、治療方法編集
    //             if (item.indKurCd && (0 !== item.indKurCd)) {
    //               createJournal({...params, ord_no: item.ordNo, base_date: item.treatDate});
    //             }
    //           }
    //         } else {
    //           if (structData.selectedTreat.length > 0) {
    //             // add #8420 【IES起票】【画面】【患者経過総合ビューア】治療方法変更にエラーが発生 dou start
    //             const isSelectedTreat = structData.selectedTreat.includes(Number(item.indTreatmentCd));
    //             // add #8420 【IES起票】【画面】【患者経過総合ビューア】治療方法変更にエラーが発生 dou end
    //             if (isSelectedTreat) {
    //               if (item.indKurCd && (0 !== item.indKurCd)) {
    //                 // 変更対象クールが未登録ではない、治療方法編集
    //                 createJournal({...params, ord_no: item.ordNo, base_date: item.treatDate});
    //               }
    //             }
    //           } else {
    //             // 変更対象クールが未登録ではない、治療方法編集
    //             if (item.indKurCd && (0 !== item.indKurCd)) {
    //               createJournal({...params, ord_no: item.ordNo, base_date: item.treatDate});
    //             }
    //           }
    //         }
    //       }
    //     }
    //   }
    // },

    // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
    // del #11004 連携イベント発生部分不正 piao start
    // /**
    //  * @description MODIFY_SEND_CLASS取得
    //  */
    // async getSchModifySendClass(structData) {
    //   let retVal = 0;
    //   const prmFacilityCd = structData.facilityCd;
    //   this.objModSendClass = await sendRequestGetCoopIniSchModifySendClass(prmFacilityCd);
    //
    //   try {
    //     const response = this.objModSendClass;
    //     retVal = response.data;
    //   } catch (error) {
    //     retVal = 0;
    //   }
    //   return retVal;
    // },
    // del #11004 連携イベント発生部分不正 piao end
    // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end

    async createJournalApi(structData) {
      let JournalList = [];

      // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
      // del #11004 連携イベント発生部分不正 piao start
      // let modSendClass = await this.getSchModifySendClass(structData);
      // del #11004 連携イベント発生部分不正 piao end
      let crudTmp = "U";
      // del #11004 連携イベント発生部分不正 piao start
      // if ( modSendClass == 2 ) {
      //   crudTmp = "C";
      // }
      // del #11004 連携イベント発生部分不正 piao end
      // 明細に治療方法変更の場合
      if (this.settingIndData.ordNo) {
        // 変更対象クールが未登録ではない、治療方法編集
        const oldOrdMain = this.oldOrdMainList.find(ordMain => ordMain.ordNo === this.settingIndData.ordNo);
        if (oldOrdMain.indKurCd && (0 !== oldOrdMain.indKurCd)) {
          // del #11004 連携イベント発生部分不正 piao start
          // if ( modSendClass == 2 ) {
          //   JournalList.push({
          //     ope_cd: "004003",
          //     crud: "D",
          //     facility_cd: structData.facilityCd,
          //     hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
          //     pat_id: structData.patId,
          //     ord_no : oldOrdMain.ordNo,
          //     base_date: oldOrdMain.treatDate,
          //     user_id: this.getStateUserAccountInfo.userId
          //   })
          // }
          // del #11004 連携イベント発生部分不正 piao end
          JournalList.push({
            ope_cd: "004003",
            crud: crudTmp,
            facility_cd: structData.facilityCd,
            hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
            pat_id: structData.patId,
            ord_no : oldOrdMain.ordNo,
            base_date: oldOrdMain.treatDate,
            user_id: this.getStateUserAccountInfo.userId
            })
        } else {
            JournalList.push({
            ope_cd: "004203",
            crud: crudTmp,
            facility_cd: structData.facilityCd,
            hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
            pat_id: structData.patId,
            ord_no : oldOrdMain.ordNo,
            base_date: oldOrdMain.treatDate,
            user_id: this.getStateUserAccountInfo.userId
            })
        }
        createJournalList(JournalList);
      } else {
        // 1件以上治療方法変更の場合
        if (this.oldOrdMainList) {
          for(let i = 0; i < this.oldOrdMainList.length; i++) {
            const item = this.oldOrdMainList[i];
            if (structData.selectedKur.length > 0) {
              const isSelectedKur = structData.selectedKur.includes(Number(item.indKurCd));
              if (isSelectedKur) {
                // 変更対象クールが未登録ではない、治療方法編集
                if (item.indKurCd && (0 !== item.indKurCd)) {
                  // del #11004 連携イベント発生部分不正 piao start
                  // if ( modSendClass == 2 ) {
                  //   JournalList.push({
                  //     ope_cd: "004003",
                  //     crud: "D",
                  //     facility_cd: structData.facilityCd,
                  //     hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
                  //     pat_id: structData.patId,
                  //     ord_no : item.ordNo,
                  //     base_date: item.treatDate,
                  //     user_id: this.getStateUserAccountInfo.userId
                  //   })
                  // }
                  // del #11004 連携イベント発生部分不正 piao end
                  JournalList.push({
                      ope_cd: "004003",
                      crud: crudTmp,
                      facility_cd: structData.facilityCd,
                      hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
                      pat_id: structData.patId,
                      ord_no : item.ordNo,
                      base_date: item.treatDate,
                      user_id: this.getStateUserAccountInfo.userId
                      })
                } else {
                      JournalList.push({
                      ope_cd: "004203",
                      crud: crudTmp,
                      facility_cd: structData.facilityCd,
                      hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
                      pat_id: structData.patId,
                      ord_no : item.ordNo,
                      base_date: item.treatDate,
                      user_id: this.getStateUserAccountInfo.userId
                      })
                }
              }
            } else {
              if (structData.selectedTreat.length > 0) {
                const isSelectedTreat = structData.selectedTreat.includes(Number(item.indTreatmentCd));
                if (isSelectedTreat) {
                  if (item.indKurCd && (0 !== item.indKurCd)) {
                    // 変更対象クールが未登録ではない、治療方法編集
                    // del #11004 連携イベント発生部分不正 piao start
                    // if ( modSendClass == 2 ) {
                    //   JournalList.push({
                    //     ope_cd: "004003",
                    //     crud: "D",
                    //     facility_cd: structData.facilityCd,
                    //     hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
                    //     pat_id: structData.patId,
                    //     ord_no : item.ordNo,
                    //     base_date: item.treatDate,
                    //     user_id: this.getStateUserAccountInfo.userId
                    //   })
                    // }
                    // del #11004 連携イベント発生部分不正 piao end
                    JournalList.push({
                      ope_cd: "004003",
                      crud: crudTmp,
                      facility_cd: structData.facilityCd,
                      hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
                      pat_id: structData.patId,
                      ord_no : item.ordNo,
                      base_date: item.treatDate,
                      user_id: this.getStateUserAccountInfo.userId
                      })
                  } else {
                      JournalList.push({
                      ope_cd: "004203",
                      crud: crudTmp,
                      facility_cd: structData.facilityCd,
                      hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
                      pat_id: structData.patId,
                      ord_no : item.ordNo,
                      base_date: item.treatDate,
                      user_id: this.getStateUserAccountInfo.userId
                      })
                  }
                }
              } else {
                // 変更対象クールが未登録ではない、治療方法編集
                if (item.indKurCd && (0 !== item.indKurCd)) {
                  // del #11004 連携イベント発生部分不正 piao start
                  // if ( modSendClass == 2 ) {
                  //   JournalList.push({
                  //     ope_cd: "004003",
                  //     crud: "D",
                  //     facility_cd: structData.facilityCd,
                  //     hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
                  //     pat_id: structData.patId,
                  //     ord_no : item.ordNo,
                  //     base_date: item.treatDate,
                  //     user_id: this.getStateUserAccountInfo.userId
                  //   })
                  // }
                  // del #11004 連携イベント発生部分不正 piao end
                  JournalList.push({
                      ope_cd: "004003",
                      crud: crudTmp,
                      facility_cd: structData.facilityCd,
                      hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
                      pat_id: structData.patId,
                      ord_no : item.ordNo,
                      base_date: item.treatDate,
                      user_id: this.getStateUserAccountInfo.userId
                      })
                } else {
                  JournalList.push({
                      ope_cd: "004203",
                      crud: crudTmp,
                      facility_cd: structData.facilityCd,
                      hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
                      pat_id: structData.patId,
                      ord_no : item.ordNo,
                      base_date: item.treatDate,
                      user_id: this.getStateUserAccountInfo.userId
                      })
                }
              }
            }
          }
          createJournalList(JournalList);
        }
      }
      // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
    },
    // add FNSI-連携イベントの登録適正化 楊 end
    // mod 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou end
    hideModal() {
      /* モーダル閉じる */
      this._hideIndicationModal();
    },

    /**
     * 治療方法リスト取得
     */
    async getMstTreatmentList() {
      await ApiHelper.get("/mstInfo/mstTreatment")
        .then(response => {
          this.treatDateList = response.data.filter(item => {
            return (
              // 施設コードが一致し、表示フラグが1のものだけを取り出す
              item.facilityCd === this._indicationFlowOwner().structData.facilityCd &&
              "1" === item.isDisp
            );
          });
          // 治療方法の選択肢を初期値として格納する
          this.initTreatDateList = this.treatDateList;
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('IndTreatMethod.vue', 'getMstTreatmentList', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          throw error;
        });
    },

    /**
     * IndEditBaseの治療方法選択が行われた際の制御
     * @summary IndEditBaseで治療方法が選択された際に、
     *          IndTreatMethodで治療方法選択が同一にならないよう制御
     * @description IndEditBasaeのstructData.selectedTreatをwatchで変更されたタイミングでこの関数を呼ぶ
     */
    changeMultSelect(value) {
      // IndTreatMethodの治療方法リストを初期化
      this.treatDateList = this.initTreatDateList;
      if (1 === value.length) {
        // IndTreatMethodの選択肢からIndEditBaseで選択中のものを失くす
        this.treatDateList = this.initTreatDateList.filter(item => {
          return Number(item.treatmentCd) !== Number(value[0]);
        });
        // 先頭の治療方法を選択状態とする
        if (0 !== this.treatDateList.length) {
          this.selectedTreat = this.treatDateList[0].treatmentCd;
        }
      }
    },

    /**
     * チェック処理
     */
    checkEdit() {
      return;
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
    isEdit() {
      let editCount = 0;
      if (this.displayInputValue.initValue !== this.displayInputValue.editValue ||
          this.displayInputValue.editValue === '3' && this.isHandleChanged ||
          this.displayInputValue.editValue === '2' && this.isHandleChanged ||
          this.displayInputValue.editValue === '1' && this.initSelectedTreat !== JSON.stringify(this.selectedTreat)
      ) {
        editCount += 1;
      }
      if (0 === editCount) {
        return false;
      }
      return true;
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
    /**
     * メッセージ表示処理
     * @param msgCd メッセージコード
     * @param strParam 置換文字列
     */
    showMessage(msgCd, strParam) {
      let messageType = null;
      let stringParams = [];
      // mod FNSI-濃度プログラムチェックの追加 楊 start
      // switch (parseInt(msgCd)) {
      switch (msgCd) {
        // mod FNSI-濃度プログラムチェックの追加 楊 end
        case 12010001:
          messageType = "2";
          stringParams = ["<br>予定が重ならない日のみ登録しますか？"];
          break;

        case 22010001:
          messageType = "1";
          stringParams = [strParam];
          break;

        case 22010004:
          messageType = "1";
          stringParams = [""];
          break;

        case 22010005:
          messageType = "1";
          stringParams = ["クール", "治療方法・クール"];
          break;
        // add FNSI-濃度プログラムチェックの追加 楊 start
        // case "00400007":
        //   messageType = "1";
        //   break;
        // add FNSI-濃度プログラムチェックの追加 楊 end
        case 22010007:
        case 22020003:
        case 16010001:
        case 22020004:
        case 12000082:
          messageType = "1";
          break;

        case 22010011:
          messageType = "1";
          stringParams = [""];
          break;

        default:
          break;
      }
      this._indicationDialogOwner().messageDialogInfo.messageCd = msgCd;
      this._indicationDialogOwner().messageDialogInfo.type = messageType;
      this._indicationDialogOwner().messageDialogInfo.stringParams = stringParams;
      this._indicationDialogOwner().messageDialogInfo.isDialogVisible = true;
    },

    /**
     * 吹き出し表示処理
     */
    getScopedElementByIdSafe(id) {
      return getScopedElementById(id, this.$el || null);
    },
    showPopOver(event, message) {
      const pop = this.getScopedElementByIdSafe("popOverMessage");
      if (pop) {
        pop.innerText = message;
      }
      this.userMenuPopoverTarget = event;
      this.userMenuPopoverVisible = true;
    },
    //mod FNSI-5525 劉全航 start
    updateNextPatInfo(structData){
        this.oldOrdMainList.forEach(async ordMain => {
          if(ordMain.rstDialysisState !== "0") {
            const tempOrdNo = ordMain.ordNo;
            // 装置マスタの取得
            this.getMstMachineByOrdNoRst(tempOrdNo).then(machineRes => {
              let mstMachine = machineRes.data;
              if (mstMachine.length > 0){
                ApiHelper.get(
                  `/master_maintenance/mst_comsv_setting/data/${structData.facilityCd}`
                ).then((response) =>
                  {
                    let diviceEgeList = response.data.localDataSource.data;
                    let diviceEge = diviceEgeList.find(o =>{
                      return o.deviceEdgeNo == mstMachine[0].deviceEdgeNo;
                    });
                    let npatItem = JSON.parse(diviceEge.lcdNpat).npat_item;
                    let codeList = npatItem.map(o=>{
                      return o.code;
                    });
                    let methodChangeFlag = false;
                    if(codeList.includes(10)){
                      methodChangeFlag = true;
                    }
                    let modelChange = false;
                    if(codeList.includes(13)){
                      let oldTreatment = this.mstTreatmentList.filter( m =>{
                        return m.treatmentCd === Number(ordMain.indTreatmentCd);
                      });
                      let newTreatment = this.mstTreatmentList.filter( m =>{
                        return m.treatmentCd === this.selectedTreat;
                      });
                      if(oldTreatment.deviceMode !== newTreatment.deviceMode){
                        modelChange = true;
                      }
                    }
                    if(methodChangeFlag || modelChange){
                      const params = {
                        ordNo: tempOrdNo, //オーダー番号
                        machineNo: mstMachine[0].machineNo, //装置マスタ.装置番号
                        deviceEdgeNo: mstMachine[0].deviceEdgeNo, //デバイスエッジ番号
                        facilityCd: this.facilityCd //施設コード
                      };
                      this.sendNextPatInfoViewer(params);
                    }
                  }
                ).catch(error => {
                  //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
                  getErrorMessage('IndActionChart.vue', 'updateInfo', '送信失敗しました。');
                  //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
                  throw error;
                });
              }
            });
          }
        });
    },
    //mod FNSI-5525 劉全航 end
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
    handleComputedValueChanged(handleValue){
      this.isHandleChanged = handleValue;
  }
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
  }
};
</script>

/** * スタイル定義 */
<style scoped>
.cond-row-style {
  padding: 5px 0px;
}

.ons-row {
  height: auto;
}

#popOverMessage {
  margin: 10px;
}
/** add FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 start */
/* FNSI-治療方法説明文の表示を修正 周 del start */
/* .custom-radio-edited + label { */
.custom-radio-checked + label {
/* FNSI-治療方法説明文の表示を修正 周 del end */
  color: green;
  font-weight: bold;
}
/** add FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 end */

</style>
