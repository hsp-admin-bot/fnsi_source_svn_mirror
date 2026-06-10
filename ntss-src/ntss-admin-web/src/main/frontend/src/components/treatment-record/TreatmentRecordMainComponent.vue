/** * 治療記録 MainContent */
<template>
  <div class="main-content-area treatment-record-content-area">
    <summary-component ref="summary" @change="isOpenButtonArea" :is-open="isOpen" />
    <div
      class="main-area"
      :style="{ height: 'calc(100% - ' + summaryHeight + 'px)' }"
    >
      <div class="scroll-area">
        <div class="registration-btn-area button-area" v-show="isOpen">
          <!-- 実績状況表示 -->
          <div
            :class="`rst-state-common rst-state-${dialysisState}`"
            v-if="dialysisState !== 0"
          >
            <label class="rst-state-inner">{{ dialysisStateName }}</label>
          </div>
          <!-- 実績確定ボタン -->
          <!-- mod 8074【デグレ】ログに誤った利用者が記録される 関 start -->
          <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 start -->
          <!-- <v-ons-button type="button" v-if="isDispDialysisConfirmButton()"
            class="button registration-btn registered-bg-color btn3-normal confirm-background-color"
            :disabled="!canConfirm"
            @click="confirmDialysis"> -->
          <!-- mod #10359 編集権限の動作不正 start -->
          <!-- <v-ons-button
            type="button"
            v-show="isDispDialysisConfirmButton()"
            class="button registration-btn registered-bg-color btn3-normal confirm-background-color"
            :disabled="!canConfirm"
            @click="confirmDialysis"
          >
            {{ dialysisConfirmName }}
          </v-ons-button> -->
          <v-ons-button
            type="button"
            v-show="isDispDialysisConfirmButton()"
            class="button registration-btn registered-bg-color btn3-normal confirm-background-color"
            :disabled="!isShared"
            @click="confirmDialysis"
          >
            {{ dialysisConfirmName }}
          </v-ons-button>
          <!-- mod #10359 編集権限の動作不正 end -->
          <!-- mod 8074【デグレ】ログに誤った利用者が記録される 関  end -->
          <template v-for="subMenu in subMenus">
            <!-- ？？？？患者(patId=null)の場合、観察記録画面に遷移させない -->
            <!-- mod FNSI修正観察記録内結バッグ1 房 start -->
            <!-- #9692 mod  治療記録のモニタ画面を表示しながら患者を切り替えてもモニタデータが更新されない 2023-11-28 卓 start -->
            <router-link
              class="router-link-width"
              v-if="
                subMenu.key !== roundRouteDef.name &&
                subMenu.key !== 'Bvms' &&
                (!subMenuPatIdIsNull.includes(subMenu.key) || getObserveRecord)
              "
              :key="subMenu.key"
              :to="{
                name:
                  !getOrdNo ||
                  deletedOrCancelCond ||
                  (subMenuPatIdIsNull.includes(subMenu.key) && patId == null)
                    ? null
                    : subMenu.key,
              }"
            >
              <v-ons-button
                class="button registration-btn btn3-normal"
                :name="subMenu.key"
                :disabled="
                  !getOrdNo ||
                  deletedOrCancelCond ||
                  (subMenuPatIdIsNull.includes(subMenu.key) && patId == null)
                "
                >{{ subMenu.label }}</v-ons-button
              >
            </router-link>
            <!-- #9692 mod  治療記録のモニタ画面を表示しながら患者を切り替えてもモニタデータが更新されない 2023-11-28 卓 end -->
            <!-- mod FNSI修正観察記録内結バッグ1 房 end -->
          </template>
          <template v-for="subMenu in subMenus">
            <round-type-selector
              v-if="subMenu.key === roundRouteDef.name"
              :key="subMenu.key"
              :deletedOrCancelCond="deletedOrCancelCond"
              @update="checkRstDialysisState"
            ></round-type-selector>
          </template>
          <template v-for="subMenu in subMenus">
            <!-- mod FNSI修正観察記録内結バッグ1 房 start -->
            <!-- #9692 mod  治療記録のモニタ画面を表示しながら患者を切り替えてもモニタデータが更新されない 2023-11-28 卓 start -->
            <router-link
              class="router-link-width"
              v-if="
                subMenu.key === 'Bvms' &&
                isShowBvms &&
                (!subMenuPatIdIsNull.includes(subMenu.key) || getObserveRecord)
              "
              :key="subMenu.key"
              :to="{
                name:
                  !getOrdNo ||
                  deletedOrCancelCond ||
                  (subMenuPatIdIsNull.includes(subMenu.key) && patId == null)
                    ? null
                    : subMenu.key,
              }"
            >
              <v-ons-button
                class="button registration-btn btn3-normal"
                :name="subMenu.key"
                :disabled="
                  !getOrdNo ||
                  deletedOrCancelCond ||
                  (subMenuPatIdIsNull.includes(subMenu.key) && patId == null)
                "
                >{{ subMenu.label }}</v-ons-button
              >
            </router-link>
            <!-- #9692 mod  治療記録のモニタ画面を表示しながら患者を切り替えてもモニタデータが更新されない 2023-11-28 卓 end -->
            <!-- mod FNSI修正観察記録内結バッグ1 房 end -->
          </template>
          <div class="separator-line"></div>

          <!-- modified 権限関連 孫 20200925 start -->
          <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
          <v-ons-button
            v-if="getItemAuthorized('TreatmentRecord', 'item_merge_results')"
            class="button registration-btn btn3-normal"
            :disabled="!getOrdNo || deletedOrCancelCond || rstCanBeMerging || !isShared"
            @click="showResultMerge"
            >実績マージ</v-ons-button
          >
          <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
          <!-- mod 8074【デグレ】ログに誤った利用者が記録される 関 start -->
          <!-- <v-ons-button class="button registration-btn btn3-normal" :disabled="!getOrdNo || deletedOrCancelCond || !canConfirm" @click="offlineResultMerge" v-if="isOfflineResultMarge">モニタデータ取込</v-ons-button> -->
          <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
          <v-ons-button
            class="button registration-btn btn3-normal"
            :disabled="
              !getOrdNo ||
              deletedOrCancelCond ||
              !getItemAuthorized('TreatmentRecord', 'default_authority') || 
              !isShared
            "
            @click="offlineResultMerge"
            v-show="isOfflineResultMarge"
            >モニタデータ取込</v-ons-button
          >
          <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
          <!-- mod 8074【デグレ】ログに誤った利用者が記録される 関  end -->
          <!-- add 治療記録_変更履歴 追加 陳 start-->
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-button -->
          <!--   class="button registration-btn btn3-normal" -->
          <!--   :disabled="!getOrdNo || deletedOrCancelCond || !canConfirm" -->
          <!--   @click="showChangeLog" -->
          <!--   >変更履歴</v-ons-button -->
          <!-- > -->
          <v-ons-button
            class="button registration-btn btn3-normal"
            :disabled="!getOrdNo || deletedOrCancelCond || !isShared"
            @click="showChangeLog"
            >変更履歴</v-ons-button
          >
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <!-- add 治療記録_変更履歴 追加 陳 end-->
          <!-- modified 権限関連 孫 20200925 end -->
          <!-- mod 8074【デグレ】ログに誤った利用者が記録される 関 start -->
          <!-- <v-ons-button class="button registration-btn btn1-execute" :disabled="!getOrdNo" @click="offlineStartTreat" v-if="isTreatStart && alivemonistatus">治療開始</v-ons-button> -->
          <!-- <v-ons-button class="button registration-btn btn1-execute" :disabled="!getOrdNo" @click="offlineEndTreat" v-if="isTreatEnd">治療終了</v-ons-button> -->
          <!-- mod #10359 編集権限の動作不正 start -->
          <!-- <v-ons-button
            class="button registration-btn btn1-execute"
            :disabled="!getOrdNo"
            @click="offlineStartTreat"
            v-show="isTreatStart && alivemonistatus"
            >治療開始</v-ons-button
          >
          <v-ons-button
            class="button registration-btn btn1-execute"
            :disabled="!getOrdNo"
            @click="offlineEndTreat"
            v-show="isTreatEnd"
            >治療終了</v-ons-button
          >-->
          <v-ons-button
            class="button registration-btn btn1-execute"
            :disabled="
              !getOrdNo ||
              deletedOrCancelCond ||
              !getItemAuthorized('TreatmentRecord', 'default_authority') ||
              !isShared
            "
            @click="offlineStartTreat"
            v-show="isTreatStart && alivemonistatus"
            >治療開始</v-ons-button
          >
          <v-ons-button
            class="button registration-btn btn1-execute"
            :disabled="
              !getOrdNo ||
              deletedOrCancelCond ||
              !getItemAuthorized('TreatmentRecord', 'default_authority') ||
              !isShared
            "
            @click="offlineEndTreat"
            v-show="isTreatEnd"
            >治療終了</v-ons-button
          >
          <!-- mod #10359 編集権限の動作不正 end -->
          <!-- mod #10359 編集権限の動作不正 start -->
          <!-- <v-ons-button
            class="button registration-btn deleteRecord btn4-alert"
            @click="deleteRecord"
            :disabled="
              !getOrdNo
            "
            v-show="canDeleteRecord"
            >治療記録削除</v-ons-button
          > -->
          <!-- mod #10359_NG対応 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-button -->
          <!--   class="button registration-btn deleteRecord btn4-alert" -->
          <!--   @click="deleteRecord" -->
          <!--   :disabled=" -->
          <!--     !getOrdNo || deletedOrCancelCond || -->
          <!--     !getItemAuthorized('TreatmentRecord', 'default_authority_del') -->
          <!--   " -->
          <!--   v-show="canDeleteRecord" -->
          <!--   >治療記録削除</v-ons-button -->
          <!-- > -->
          <v-ons-button
            class="button registration-btn deleteRecord btn4-alert"
            @click="deleteRecord"
            :disabled="
              !getOrdNo ||
              deletedOrCancelCond || 
              !isShared
            "
            v-show="canDeleteRecord"
            :style="{ 'opacity': this.getItemAuthorized('TreatmentRecord', 'item_delete_btn') ? 1 : 0.6}"
            >治療記録削除</v-ons-button
          >
          <!-- mod #10359_NG対応 編集権限の動作不正 dengshen end -->
          <!-- mod #10359 編集権限の動作不正 end -->
          <!-- mod 8074【デグレ】ログに誤った利用者が記録される 関  end -->
          <!-- mod FNSI修正 8273  ljx end-->
          <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 end -->
          <!-- mod 8074【デグレ】ログに誤った利用者が記録される 関 start -->
          <!-- <v-ons-button class="button registration-btn deleteRecord btn4-alert" :disabled="!getOrdNo" @click="cancelSendCond" v-if="isConditionCancel">条件送信破棄</v-ons-button> -->
          <v-ons-button
            class="button registration-btn deleteRecord btn4-alert"
            :disabled="!getOrdNo || deletedOrCancelCond || !isShared"
            @click="cancelSendCond"
            v-show="isConditionCancel"
            >条件送信破棄</v-ons-button
          >
          <!-- mod 8074【デグレ】ログに誤った利用者が記録される 関  end -->
        </div>
        <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 end -->
      </div>
      <div class="submenu-area">
        <report-component v-if="showReport" ref="messageComponent" />
        <router-view
          v-if="getOrdNo && $route.name === 'treatment-observe-detail'"
          @update="checkRstDialysisState"
          ref="subComponent"
        ></router-view>
        <router-view
          v-else-if="getOrdNo && renderFlg"
          @update="checkRstDialysisState"
          ref="subComponent"
        ></router-view>
      </div>
      <!-- add 実績確定修正 房 start -->
      <!--mod redmine#7185 centOS7サポート切れ zkq start -->
      <!-- <v-ons-alert-dialog modifier="rowfooter" :title="'未実施の投与薬剤が含まれていますがよろしいですか？'" :footer="{
        キャンセル: () => diaView = false,
        未実施確定: () => zisekiConfirm(false),
        実施済確定: () => zisekiConfirm(true)
      }" :visible="diaView" class="ons-dialog-c"> -->
      <v-ons-alert-dialog
        modifier="rowfooter"
        :visible="diaView"
        class="ons-dialog-c"
      >
        <span slot="title"
          >未実施の投与薬剤が含まれていますがよろしいですか？</span
        >
        <template slot="footer">
          <v-ons-alert-dialog-button @click="zisekiConfirmCancel()"
            >キャンセル</v-ons-alert-dialog-button
          >
          <v-ons-alert-dialog-button @click="zisekiConfirm(false)"
            >未実施確定</v-ons-alert-dialog-button
          >
          <v-ons-alert-dialog-button @click="zisekiConfirm(true)"
            >実施済確定</v-ons-alert-dialog-button
          >
        </template>
        <!--mod redmine#7185 centOS7サポート切れ zkq end -->
        <!-- add redmine#3932 房 start -->
        <div style="max-height: 240px; overflow-y: auto">
          <v-ons-row>
            <v-ons-col class="align-items-left">
              <br />
            </v-ons-col>
          </v-ons-row>
          <v-ons-row v-for="(radioItem, index) in recordList" :key="index">
            <v-ons-col class="align-items-left">
              <label>
                {{ radioItem.name }} {{ radioItem.amount }} {{ radioItem.unit }}
              </label>
            </v-ons-col>
          </v-ons-row>
        </div>
        <div>
          <!-- add redmine#3932 房 end -->
          <v-ons-row>
            <v-ons-col class="align-items-left">
              <br />
            </v-ons-col>
          </v-ons-row>
          <v-ons-row>
            <v-ons-col class="align-items-left">
              <label> キャンセル：治療実績の確定をキャンセルします。 </label>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row>
            <v-ons-col class="align-items-left">
              <label> 未実施確定：投与薬剤未実施のまま実績確定します。 </label>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row>
            <!-- mod FNSI修正 redmine3931 房 start -->
            <v-ons-col class="align-items-left">
              実施済確定：未実施の投与薬剤を実施済にして実績確定します。投与日時は現在日時、実施者はサイン
              イン者で登録します。
            </v-ons-col>
            <!-- mod FNSI修正 redmine3931 房 end -->
          </v-ons-row>
        </div>
      </v-ons-alert-dialog>
      <!-- add 実績確定修正 房 end -->
    </div>
  </div>
</template>

<script>
import { sendRequestDeleteTreatmentRecordRst } from "@/apis/treatment-record";
//add 6987 2023-03-01 【デグレ】患者経過総合ビューア、治療記録画面を開くとTypeErrorが発生する。横展開 張 start
import { FUNC_OBSERVE_RECORD } from "@/constants/function-code";
//add 6987 2023-03-01 【デグレ】患者経過総合ビューア、治療記録画面を開くとTypeErrorが発生する。横展開 張 end
import { EventBus } from "@/eventBus.js";
import { mapGetters, mapActions, mapMutations, mapState } from "vuex";
import routing, { ROUND } from "@/router/treatment-record/index";
import TreatmentSummaryComponent from "@/components/treatment-record/TreatmentSummaryComponent";
import TreatmentReportComponent from "@/components/treatment-record/TreatmentReportComponent";
import RoundTypeSelectorComponent from "@/components/treatment-record/submenu/round/RoundTypeSelectorComponent";
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
//#10359 mod 編集権限の動作不正 2024-06-05 卓 start
// import { AUTHORITY_CODES } from "@/constants/userAuthority";
//#10359 mod 編集権限の動作不正 2024-06-05 卓 end
import { CODES } from "@/constants/TreatmentRecord.js";
import { ApiHelper } from "@/apis/AxiosHelper";
import { createJournal } from "@/apis/journal";
import { getCurrentFunctionCd } from "@/router/routing-helper";
import { ADVANCED_SETTINGS } from "@/constants/advancedSettings";
import { MediInfo } from "@/models/treatment-record/medicine/MediInfo";
// add 画面印刷プレビューと印刷の実現 黄 start
import moment from "moment";
// add 画面印刷プレビューと印刷の実現 黄 end
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
// add #10359 編集権限の動作不正 start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 end

export default {
  mixins: [ComponentGuardMixin],
  components: {
    "summary-component": TreatmentSummaryComponent,
    "report-component": TreatmentReportComponent,
    "round-type-selector": RoundTypeSelectorComponent,
  },
  data() {
    return {
      deletedOrCancelCond: false,
      roundRouteDef: ROUND,
      showReport: this.setShowReport,
      //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
      // authorityCds: [AUTHORITY_CODES.DEL_RST],
      //#10359 mod 編集権限の動作不正 2024-06-05 卓 end
      // 治療記録の削除可否
      // 治療記録削除ボタンの表示非表示判定に使用
      //  true : 削除可(治療状況が 4-6 の場合)
      //  false : 削除不可(治療状況が 0-3 の場合)
      canDeleteRecord: true,
      // 実績確定操作可否
      canConfirm: false,
      isConditionCancel: false,
      isTreatStart: false,
      isTreatEnd: false,
      // 死活監視ステータス
      alivemonistatus: false,
      // 実績状況
      dialysisState: 0,
      // 表示名
      dialysisStateName: "",
      // 実績状況と表示名
      dialysisStateNames: {
        1: "前体重\n測定済",
        2: "患者\n確認済",
        3: "治療中",
        4: "後体重\n未測定",
        5: "未確定\n実績",
        6: "確定実績",
      },
      // 実績確定ボタン
      dialysisConfirmName: "",
      // 確定フラグ(0:未確定、1:確定済)
      is_confirm: "0",
      mstMachine: [],
      bedCd: 0,
      // 子機能ボタンエリアの開閉状態
      // 初期値：開いた状態
      isOpen: true,
      // 治療状況取得処理のタイマー処理ID
      timerIdForGetDialysisState: null,
      // 治療状況確認ループカウント回数
      chkCnt: 0,
      recordList: [],
      diaView: false,
      //add FNSI修正 No.305 start
      rstInputClass: 1,
      //add FNSI修正 No.305 end
      // #9692 mod  治療記録のモニタ画面を表示しながら患者を切り替えてもモニタデータが更新されない 2023-11-28 卓 start
      summaryHeight: 30,
      subMenuPatIdIsNull: [
        "treatment-record-observation",
        "treatment-record-addition-info",
      ],
      // #9692 mod  治療記録のモニタ画面を表示しながら患者を切り替えてもモニタデータが更新されない 2023-11-28 卓 end
      renderFlg: false
    };
  },
  computed: {
    ...mapGetters("treatment-record/common", [
      //add FNSI修正 共有設定 房 start
      "getOrd",
      //add FNSI修正 共有設定 房 end
      //共有設定
      "getOrdNo",
      "getSharedFacilityCd",
      // add FNSI 1006 No.538 治療記録 外部連携APIを呼び出 start -- Sanjingye Sun 20210105
      "getTreatDate",
      // add FNSI 1006 No.538 治療記録 外部連携APIを呼び出 end -- Sanjingye Sun 20210105
    ]),
    ...mapGetters("pat-info", {
      patId: "selectedPatId",
      isNullPat: "isNullPat",
      // add FNSI 1006 No.538 治療記録 外部連携APIを呼び出 start -- Sanjingye Sun 20210105
      selectedPat: "selectedPat",
      // add FNSI 1006 No.538 治療記録 外部連携APIを呼び出 end -- Sanjingye Sun 20210105
      srcFuncName: "srcFuncName",
      treatmentPatList: "treatmentPatList",
    }),
    ...mapGetters("user", {
      facilityCd: "getFacilityCd",
      advancedSettings: "getAdvancedSettings",
    }),
    //add FNSI-修正 共有設定 房 start
    ...mapGetters("mst-user", { getSharedFlag: "getIsRegisteredShared" }),
    //add FNSI-修正 共有設定 房 end
    //add FNSI修正観察記録内結バッグ1 房 start
    ...mapGetters("account-edit", [
      //del 6987 2023-03-01 【デグレ】患者経過総合ビューア、治療記録画面を開くとTypeErrorが発生する。横展開 張 start
      // "getAuthorizedFunctions",
      //del 6987 2023-03-01 【デグレ】患者経過総合ビューア、治療記録画面を開くとTypeErrorが発生する。横展開 張 end
      "getFontSize",
      //mod FNSI-7531 劉全航 start
      "getStateUserAccountInfo",
      //mod FNSI-7531 劉全航 end
      "getPatientShareMode", 
      "getPatientShareFacilityCdMode"
    ]),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
    }),
    ...mapState("treatment-record/common", ["ordNoDataSourcesState"]),
    //add FNSI修正観察記録内結バッグ1 房 end
    subMenus() {
      // add #10359 編集権限の動作不正 start
      let authorityOther = [
        "treatment-record-round",
        "treatment-record-observation",
      ];

      // let subMenu = routing[0].children.map((child) => ({
      //   key: child.name,
      //   label: child.meta.title,
      // }));
      let subMenu = routing[0].children.map((child) => ({
        key: child.name,
        label: child.meta.title,
        authorityOther: !authorityOther.includes(child.name),
      }));
      // add #10359 編集権限の動作不正 end
      subMenu = subMenu.filter((sub) => sub.key != "treatment-observe-detail");
      if (!this.isShowAdditionInfo) {
        subMenu = subMenu.filter(
          (sub) => sub.key != "treatment-record-addition-info"
        );
      }

      return subMenu;
    },
    isShowBvms() {
      if (!this.advancedSettings.func_advcds) return false;

      return this.advancedSettings.func_advcds.some(
        (setting) => setting.func_advcd === ADVANCED_SETTINGS.BVMS
      );
    },
    isShowAdditionInfo() {
      if (!this.advancedSettings.func_advcds) return false;

      return this.advancedSettings.func_advcds.some(
        (setting) => setting.func_advcd === ADVANCED_SETTINGS.ADDITION_INFO
      );
    },

    /**
     * モニタデータ取込許可有無
     */
    isOfflineResultMarge() {
      let ret = false;
      if (this.dialysisState && 1 <= this.dialysisState) {
        ret = true;
      }
      return ret;
    },
    //add FNSI修正観察記録内結バッグ1 房 start
    getObserveRecord() {
      //mod 6987 2023-03-01 【デグレ】患者経過総合ビューア、治療記録画面を開くとTypeErrorが発生する。横展開 張 start
      //      if (this.getAuthorizedFunctions.indexOf("016") != -1) {
      if (this.getAuthorizedFunctions().includes(FUNC_OBSERVE_RECORD)) {
        //mod 6987 2023-03-01 【デグレ】患者経過総合ビューア、治療記録画面を開くとTypeErrorが発生する。横展開 張 end
        return true;
      }
      return false;
    },
    //add FNSI修正観察記録内結バッグ1 房 end

    // #10196 add logic : only when dialysisState >= 3, rst can be merging. Add by zhou.tao Start
    rstCanBeMerging() {
      return !(this.dialysisState && this.dialysisState >= 3);
    },
    // #10196 add logic : only when dialysisState >= 3, rst can be merging. Add by zhou.tao End
    // add #12462 患者情報共有 Ji start
    isShared() {
      return this.facilityCd === this.getSharedFacilityCd;
    }
    // add #12462 患者情報共有 Ji end
  },
  watch: {
    $route(to) {
      // 遷移するタイミングで最新の状況を反映させる.
      this.checkRstDialysisState();
      // ルートの変更を検知して、レポート表示/非表示を切り替える
      this.showReport = to.name === "treatment-record";
    },
    // mod FNSI-7967 治療状況リスト，マップから治療記録を開いた後に患者を切り替えて表示できない時がある 房 start
    getOrdNo(val) {
      this.checkRstDialysisState();
      this.isMonistatus();
      const dataSource = this.srcFuncName
        ? this.treatmentPatList
        : this.ordNoDataSourcesState;
      if (dataSource) {
        this.deletedOrCancelCond = dataSource?.some((item) => {
          return (
            item.ordNo === val &&
            (item.hasDeleteRecord || item.hasCancelSendCond)
          );
        });
      }
    },
    // mod FNSI-7967 治療状況リスト，マップから治療記録を開いた後に患者を切り替えて表示できない時がある 房 end
    //add FNSI-修正 共有設定 房 start
    getSharedFlag() {
      const submenu = document.getElementsByClassName("submenu-area");
      if (
        this.getSharedFacilityCd !== undefined &&
        this.getSharedFacilityCd != null
      ) {
        if (
          this.getSharedFlag === 1 &&
          this.facilityCd !== this.getSharedFacilityCd
        ) {
          submenu[0].style.backgroundColor = "#ffff99";
        } else {
          submenu[0].style.backgroundColor = "";
        }
      } else {
        submenu[0].style.backgroundColor = "";
      }
    },
    patId() {
      const submenu = document.getElementsByClassName("submenu-area");
      if (
        this.getSharedFacilityCd !== undefined &&
        this.getSharedFacilityCd != null
      ) {
        if (
          this.getSharedFlag === 1 &&
          this.facilityCd !== this.getSharedFacilityCd
        ) {
          submenu[0].style.backgroundColor = "#ffff99";
        } else {
          submenu[0].style.backgroundColor = "";
        }
      } else {
        submenu[0].style.backgroundColor = "";
      }
    },
    getSharedFacilityCd() {
      const submenu = document.getElementsByClassName("submenu-area");
      if (
        this.getSharedFacilityCd !== undefined &&
        this.getSharedFacilityCd != null
      ) {
        if (
          this.getSharedFlag === 1 &&
          this.facilityCd !== this.getSharedFacilityCd
        ) {
          submenu[0].style.backgroundColor = "#ffff99";
        } else {
          submenu[0].style.backgroundColor = "";
        }
      } else {
        submenu[0].style.backgroundColor = "";
      }
    },
    windowHeight() {
      this.calculateGridHeight();
    },
    getFontSize() {
      this.calculateGridHeight();
    },
    //add FNSI-修正 共有設定 房 end
  },
  methods: {
    // #9315 2024.02.27 add 共通ローダー変更 TDC片口 start
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
      "executeWithLoadingScreen",
    ]),
    // #9315 2024.02.27 add 共通ローダー変更 TDC片口 end
    // mod 治療記録_変更履歴 追加 陳 start
    ...mapActions("multi-modal", ["showResultMerge", "showChangeLog"]),
    //...mapActions("multi-modal", ["showResultMerge"]),
    // mod 治療記録_変更履歴 追加 陳 end
    ...mapActions("treatment-record/result", [
      "getTreatmentRecordResult",
      "getmonistatus",
    ]),
    ...mapActions("treatment-record/common", [
      "setOrdNo",
      "setIsMenuOpen",
      "setDialysisState",
      "setTreatDate",
      "setRstEditionDate",
      "setRstStartDate",
      "setRstEndDate",
      "setOrdNoForSideBarRecord",
      "dialysisConfirm",
      "deleteDialysis",
      //add FNSI内容修正 外部Api調用 房 start
      "setOrd",
      // #10518 2024.04.19 del 実績版確定時の処理で使用しないため削除 TDC米沢 start
      //"sendTreatingOrdNo",
      // #10518 2024.04.19 del 実績版確定時の処理で使用しないため削除 TDC米沢 end
      //add FNSI内容修正 外部Api調用 房 end
      // #9315 2024.02.14 add オフライン治療開始後画面リロード処理 TDC片口 start
      "sendRequestGetTreatmentRecordCurrentRstDialysisState",
      // #9315 2024.02.14 add オフライン治療開始後画面リロード処理 TDC片口 end
      "setRstCondInfo",
    ]),

    // 実績確定処理
    ...mapActions("status-list/list", [
      "putCheckAfterWeight",
      "getCheckMediDone",
      "deleteUnknownPatRecord",
    ]),
    // 利用者情報に関するGetter
    ...mapGetters("account-edit", ["getUserId"]),
    // 患者情報に関するAction
    ...mapActions("pat-info", [
      "clearSelectedPat",
      "setIsNullPat",
      //merge
      "getAcceptanceStatusInfo",
      //add 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧 start
      "selectPat",
      //add 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧 end
    ]),
    // 患者情報に関するMutations
    ...mapMutations("pat-info", ["updateTreatmentPatList"]),
    //add 実績確定修正 房 start
    //add FNSI-修正 共有設定 徐 start
    ...mapMutations("treatment-record/common", [
      "setSharedFacilityCd",
      "setOrdNoDataSources",
    ]),
    //add FNSI-修正 共有設定 徐 end
    
    /** 画面印刷前の処理 */
    handleBeforePrint() {
      // 書式設定なし テキストエリア 印刷用のdiv作成
      const textareas = Array.from(document.querySelectorAll("textarea.custom-textarea"))
        .filter(el => el.offsetParent !== null);
    
      textareas.forEach(el => {
        const div = document.createElement("div");
        div.className = "print-textarea";
        // 値コピー（改行そのまま）
        div.innerText = el.value;
        // textareaの後ろに追加
        el.parentNode.appendChild(div);
      });
    },
    /** 画面印刷後の処理 */
    handleAfterPrint() {
      // 追加した表示用テキストエリアのdiv削除
      document.querySelectorAll(".print-textarea").forEach(el => el.remove());
    },
    zisekiConfirm(val) {
      // 更新する為のパラメータ生成.
      const param = this.buildConfirmParamJournal(
        [
          {
            ordNo: this.getOrdNo,
            doCompleteMedi: val,
            userId: this.getUserId(),
            // #10518 2024.05.23 add 患者指定で「実績確定・削除時装置レポート画像更新」通知を行う TDC片口 start
            patId: this.patId,
            // #10518 2024.05.23 add 患者指定で「実績確定・削除時装置レポート画像更新」通知を行う TDC片口 end
          },
        ],
        // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
        ["006001", "006003", "006009", "006002"]
        // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
      );

      this.putCheckAfterWeight(param).then(() => {
        this.checkRstDialysisState();
        this.selectPat(this.patId);
        EventBus.$emit("initOrdNoList");
      });
      // 患者共通ヘッダー：治療進捗状況を更新
      this.getAcceptanceStatusInfo();
      // リフレッシュ
      EventBus.$emit("refresh");

      this.diaView = false;
    },
    zisekiConfirmCancel() {
      // NOTE:観察記録かそれ以外でコンポーネント参照（$refs）の取得元を変更する
      const observeDetailPath = "/treatment-record/list/treatment-observe-detail";
      const targetRef =
        this.$route.path === observeDetailPath
          ? this.$refs["subComponent"].$refs["mainComponent"]
          : this.$refs["subComponent"];
      if (targetRef !== undefined) {
        targetRef.alertFlag = true;
      }
      // ダイアログを閉じる
      this.diaView = false;
    },
    //add 実績確定修正 房 end
    // #9315 2024.02.14 add リロード前の編集チェックを別関数に切り出し TDC片口 start
    /**
     * @summary 子画面側の編集中データを破棄していいかどうかのチェック
     * @returns true: 破棄したくない / false: 編集中データが無い、または破棄してよい
     */
    async checkWantContinueEditing() {
      let isEditing = false;
      // NOTE:観察記録かそれ以外でコンポーネント参照（$refs）の取得元を変更する
      const observeDetailPath = "/treatment-record/list/treatment-observe-detail";
      const targetRef =
        this.$route.path === observeDetailPath
          ? this.$refs["subComponent"].$refs["mainComponent"]
          : this.$refs["subComponent"];
      if (targetRef !== undefined) {
        try {
          isEditing = await targetRef.getChangeStatus();
        } catch (e) {
          getErrorMessage(
            "TreatmentRecordMainComponent.vue",
            "checkAcceptResetEditingData",
            e
          );
        }
      }

      let isWantContinue = false;
      if (isEditing) {
        await this.$ons.notification.confirm({
          // title: "内容破棄",
          title: DIALOG_MESSAGES[13000004].title,
          // message: "編集内容が破棄されます。</br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: (answer) => {
            if (answer === 0) {
              isWantContinue = true;
            } else {
              if (targetRef != undefined) {
                targetRef.updateChangeStatus?.();
              }
            }
          },
        });
      }
      return isWantContinue;
    },
    // #9315 2024.02.14 add リロード前の編集チェックを別関数に切り出し TDC片口 end
    //mod 実績確定修正 房 start
    /**
     * 実績確定or版確定処理
     */
    async confirmDialysis() {
      // 編集中データを破棄していいかどうかのチェック
      const isEditContinue = await this.checkWantContinueEditing();
      if (isEditContinue) {
        return;
      }
      // #9315 2024.02.14 mod リロード前の編集チェックを別関数に切り出し TDC片口 end

      if (
        this.dialysisState ===
        Number(CODES.DIALYSIS_STATE.AFTER_WEIGHT_MEASURING.cd)
      ) {
        // 未実施の投与薬剤を実施済にするか否か
        this.recordList = [];
        // 未実施の薬剤を実施済にするか否か
        this.getCheckMediDone(this.getOrdNo).then((response) => {
          const resData = response.data;
          if (resData[0] && !resData[0].isMediDone) {
            let tempList = JSON.parse(
              resData[0].rstMediInfo == null ? "[]" : resData[0].rstMediInfo
            );
            tempList = tempList.filter((x) => x.effect_flg == 0);
            for (let tempIndex = 0; tempIndex < tempList.length; tempIndex++) {
              const tempMediInfo = MediInfo.of({
                effect_flg: tempList[tempIndex].effect_flg,
                unit: tempList[tempIndex].unit,
                amount: tempList[tempIndex].amount + " ",
                name: tempList[tempIndex].name + " ",
              });
              this.recordList.push(tempMediInfo);
            }
            this.diaView = true;
            let elements = document.getElementsByClassName("ons-dialog-c");
            elements[0].childNodes[1].style.width = "28em";
          } else {
            const param = this.buildConfirmParamJournal(
              [
                {
                  ordNo: this.getOrdNo,
                  doCompleteMedi: false,
                  userId: this.getUserId(),
                  // #10518 2024.05.23 add 患者指定で「実績確定・削除時装置レポート画像更新」通知を行う TDC片口 start
                  patId: this.patId,
                  // #10518 2024.05.23 add 患者指定で「実績確定・削除時装置レポート画像更新」通知を行う TDC片口 end
                },
              ],
              // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
              ["006001", "006003", "006009", "006002"]
              // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
            );
            this.putCheckAfterWeight(param).then(() => {
              this.checkRstDialysisState();
              this.selectPat(this.patId);
            });
            // 患者共通ヘッダー：治療進捗状況を更新
            this.getAcceptanceStatusInfo();
            // リフレッシュ
            EventBus.$emit("refresh");
          }
        });
      } else if (
        this.dialysisState ===
        Number(CODES.DIALYSIS_STATE.CONFIRMED_WEIGHT_MEASURING.cd)
      ) {
        // NOTE:観察記録かそれ以外でコンポーネント参照（$refs）の取得元を変更する
        const observeDetailPath = "/treatment-record/list/treatment-observe-detail";
        const targetRef =
          this.$route.path === observeDetailPath
            ? this.$refs["subComponent"].$refs["mainComponent"]
            : this.$refs["subComponent"];
        await this.$ons.notification.confirm({
          modifier: "info",
          // title:"確認",
          title: DIALOG_MESSAGES[13000135].title,
          // message:"実績を確定します。<br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000135].message),
          callback: async (answer) => {
            if (answer == 1) {
              // 版確定処理実行.
              //mod FNSI-7531 劉全航 start
              var param = {
                ordNo: this.getOrdNo,
                userId: this.getStateUserAccountInfo.userId,
              };
              this.dialysisConfirm(param).then(() => {
                this.checkRstDialysisState();

                this.executeCreateJournal("006001", "U", this.getOrdNo);
                this.executeCreateJournal("006003", "U", this.getOrdNo);
                this.executeCreateJournal("006009", "U", this.getOrdNo);
                this.executeCreateJournal("006002", "U", this.getOrdNo);

                const params = {
                  patId: this.patId, // 患者Id
                  ordNo: this.getOrdNo, //オーダー番号
                  facilityCd: this.facilityCd, //施設コード
                };
                this.sendReportUpdateInfo(params).catch(() => {
                  getErrorMessage(
                    "TreatmentRecordMainComponent.vue",
                    "confirmDialysis",
                    "装置へ送信に失敗しました。"
                  );
                  this.$ons.notification.alert({
                    modifier: "warn",
                    title: DIALOG_MESSAGES["00200033"].title,
                    message: messageFormat(DIALOG_MESSAGES["00200033"].message),
                  });
                });
              });
              // リフレッシュ
              if (targetRef != undefined) {
                targetRef?.updateChangeStatus?.();
              }
              EventBus.$emit("refresh");
              this.selectPat(this.patId);
            } else {
              if (targetRef) {
                targetRef.alertFlag = true;
              }
            }
          },
        });
      }
    },
    //mod 実績確定修正 房 end
    ...mapActions("treatment-record/common", [
      "sendCancelCondition",
      "getMstMachineByOrdNoRst",
      "getMntMachineState",
      "sendStartOfflineTreat",
      "sendEndOfflineTreat",
      "getIsPurification",
      "sendNextPatInfo",
      "sendReportUpdateInfo",
      // #10518 2024.04.19 mod 対象患者が現患者のベッドに対して「実績確定・削除時装置レポート画像更新」通知を行うメソッド変更 TDC米沢 start
      //    //add FNSI内容修正 外部Api調用 房 start
      //    "sendEndDateUpdateInfo",
      //  ]),
      //  //add FNSI内容修正 外部Api調用 房 end
      "sendAllReportUpdateByPatId",
    ]),
    // #10518 2024.04.19 mod 対象患者が現患者のベッドに対して「実績確定・削除時装置レポート画像更新」通知を行うメソッド変更 TDC米沢 end
    ...mapMutations("pat-info", {
      setSrcFuncName: "setSrcFuncName",
    }),

    /**
     * 治療記録削除ボタンクリック時のイベント
     */
    async deleteRecord() {
      // add #10359_NG対応 編集権限の動作不正 dengshen start
      if (!this.getItemAuthorized('TreatmentRecord', 'item_delete_btn')) {
        this.$ons.notification.alert({
          // title: "権限エラー",
          // message: functionName+"を操作する権限がありません。管理者に確認してください。"
          title: DIALOG_MESSAGES[12000315].title,
          message: messageFormat(DIALOG_MESSAGES[12000315].message, "治療記録削除")
        });
        return;
      }
      // add #10359_NG対応 編集権限の動作不正 dengshen end
      let dialogDispFlg = false;
      await this.$ons.notification.confirm({
        modifier: "warn",
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title:"治療記録削除警告",
        title: DIALOG_MESSAGES[13000131].title,
        // message:"表示している治療記録を削除します。削除すると二度と元に戻せません。削除しますか？",
        message: messageFormat(DIALOG_MESSAGES[13000131].message),
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: (answer) => {
          if (answer == 1) {
            dialogDispFlg = true;
          }
        },
      });
      //add #7790 初版確定前の治療実績削除で不要なイベントが登録される 20220720 zhaoqi start
      let ordMain = await ApiHelper.get(
        `/mainData/getOrdMainByOrdNo/${this.getOrdNo}`
      );
      //add #7790 初版確定前の治療実績削除で不要なイベントが登録される 20220720 zhaoqi end
      if (dialogDispFlg) {
        await this.$ons.notification.confirm({
          modifier: "warn",
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "治療記録削除最終確認",
          title: DIALOG_MESSAGES[13000132].title,
          // message: "表示している治療記録を削除します。本当によろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000132].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: (answer) => {
            if (answer == 0) {
              dialogDispFlg = false;
            }
          },
        });
        // 最終確認でキャンセルがクリックされた場合
        if (!dialogDispFlg) {
          return;
        }
        // add 6963 過去のスケジュールを編集すると対象のベッドの装置の次患者が再送される 房 start
        let nowDate = moment().format("YYYYMMDD");
        // add 6963 過去のスケジュールを編集すると対象のベッドの装置の次患者が再送される 房 end
        // 実績削除処理
        // ？？？？患者は論理削除を行う.
        if (this.isUnknownPatient()) {
          // 削除処理
          try {
            const ret = await this.deleteUnknownPatRecord(this.getOrdNo);
            // 削除成功した場合
            if (ret.data.isSuccess) {
              // del #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
              // let rstEdition = ordMain.data.rstEdition;
              // let rstDialysisState = ordMain.data.rstDialysisState;
              // if (!(rstEdition == 0 || rstDialysisState != 6)) {
              //   this.executeCreateJournal("006004", "D", this.getOrdNo);
              //   this.executeCreateJournal("006005", "D", this.getOrdNo);
              //   this.executeCreateJournal("006010", "D", this.getOrdNo);
              //   this.executeCreateJournal("006011", "D", this.getOrdNo);
              // }
              // del #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
              // 選択中の患者情報をクリア
              this.clearSelectedPat();
              // ？？？？患者フラグを解除
              this.setIsNullPat(false);
              // サイドバーの患者リストの更新
              this.clearTreatmentPatList(this.getOrdNo);
              // オーダ番号クリア
              this.setOrdNo(null);
              // サイドバーのオーダ番号クリア
              this.setOrdNoForSideBarRecord(null);
              this.setTreatDate(null);
              // 治療状況のチェック
              this.checkRstDialysisState();
              this.$router.push({ path: "/treatment-record/" });
            } else {
              this.$ons.notification.alert({
                modifier: "warn",
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // title: "治療記録削除失敗",
                // message:  `治療記録の削除に失敗しました。\n${ret.data.errorMessage}`
                title: DIALOG_MESSAGES[12000239].title,
                message: messageFormat(
                  DIALOG_MESSAGES[12000239].message,
                  ret.data.errorMessage
                ),
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              });
            }
          } catch (e) {
            //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
            getErrorMessage(
              "TreatmentRecordMainComponent.vue",
              "deleteRecord",
              "治療記録の削除に失敗しました。"
            );
            //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
            this.$ons.notification.alert({
              modifier: "warn",
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "治療記録削除失敗",
              // message:  `治療記録の削除に失敗しました。\n${e}`
              title: DIALOG_MESSAGES[12000239].title,
              message: messageFormat(DIALOG_MESSAGES[12000239].message, e),
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }
          //add 次患者情報更新の追加 房 start
          try {
            const params = {
              ordNo: tempOrdNo, //オーダー番号
              machineNo: this.mstMachine[0].machineNo, //装置マスタ.装置番号
              deviceEdgeNo: this.mstMachine[0].deviceEdgeNo, //デバイスエッジ番号
              facilityCd: this.facilityCd, //施設コード
            };
            // add 6963 過去のスケジュールを編集すると対象のベッドの装置の次患者が再送される 房 start
            if (!(parseInt(this.getTreatDate) < parseInt(nowDate))) {
              await this.sendNextPatInfo(params);
            }
            // add 6963 過去のスケジュールを編集すると対象のベッドの装置の次患者が再送される 房 end
            // #10518 2024.04.19 del ？？？？患者削除時に「実績確定・削除時装置レポート画像更新」は行わないため削除 TDC米沢 start
            // //add FNSI内容修正 外部Api調用 房 start
            // await this.sendEndDateUpdateInfo(params);
            // //add FNSI内容修正 外部Api調用 房 end
            // #10518 2024.04.19 del ？？？？患者削除時に「実績確定・削除時装置レポート画像更新」は行わないため削除 TDC米沢 end
          } catch (e) {
            //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
            getErrorMessage(
              "TreatmentRecordMainComponent.vue",
              "deleteRecord",
              "送信失敗しました。"
            );
            //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
            //del FNSI-8069 装置へ送信が失敗しても画面に表示しない ljx start
            /* this.$ons.notification.alert({
              modifier: "warn",
              title: "送信失敗",
              message: `送信失敗しました。\n${e}`
            });*/
            //del FNSI-8069装置へ送信が失敗しても画面に表示しない ljx end
          }
          //add 次患者情報更新の追加 房 end
          return;
        }

        //add 次患者情報更新の追加 房 start
        const tempOrdNo = this.getOrdNo;
        //add 次患者情報更新の追加 房 end
        try {
          this.getMstMachineByOrdNoRst(this.getOrdNo).then((machineRes) => {
            this.mstMachine = machineRes.data;
          });
          // 通常患者
          await sendRequestDeleteTreatmentRecordRst(this.getOrdNo).then(() => {
            let rstEdition = ordMain.data.rstEdition;
            let rstDialysisState = ordMain.data.rstDialysisState;
            // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
            // if (!(rstEdition == 0 || rstDialysisState != 6)) {
            if (rstDialysisState == 6 && rstEdition != 0) {
              this.executeCreateJournal("006004", "D", this.getOrdNo);
              this.executeCreateJournal("006005", "D", this.getOrdNo);
              this.executeCreateJournal("006010", "D", this.getOrdNo);
              this.executeCreateJournal("006011", "D", this.getOrdNo);
            }
            // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
            const dataSource = this.srcFuncName
              ? this.treatmentPatList
              : this.ordNoDataSourcesState;
            const curItemIndex = dataSource?.findIndex((item) => {
              return item.ordNo === this.getOrdNo;
            });
            dataSource[curItemIndex].hasDeleteRecord = true;
            this.srcFuncName
              ? this.updateTreatmentPatList(dataSource)
              : this.setOrdNoDataSources(dataSource);
            this.setOrdNo(null);
            this.setMessage(
              rstDialysisState !== 6
                ? "指定日のデータはありません"
                : " 治療方法が設定されていません。"
            );
            this.backTreatmentRecord();
            // 患者共通ヘッダー：治療進捗状況を更新
            this.getAcceptanceStatusInfo();
          });
        } catch (e) {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage(
            "TreatmentRecordMainComponent.vue",
            "deleteRecord",
            "治療記録の削除に失敗しました。"
          );
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
          this.$ons.notification.alert({
            modifier: "warn",
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "治療記録削除失敗",
            // message: `治療記録の削除に失敗しました。\n${e}`
            title: DIALOG_MESSAGES[12000239].title,
            message: messageFormat(DIALOG_MESSAGES[12000239].message, e),
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        }
        //add 次患者情報更新の追加 房 start
        try {
          const params = {
            ordNo: tempOrdNo, //オーダー番号
            machineNo: this.mstMachine[0].machineNo, //装置マスタ.装置番号
            deviceEdgeNo: this.mstMachine[0].deviceEdgeNo, //デバイスエッジ番号
            facilityCd: this.facilityCd, //施設コード
            // #10518 2024.04.19 add 対象患者が現患者のベッドに対して「実績確定・削除時装置レポート画像更新」通知を行うためにパラメータ：患者Idを追加 TDC米沢 start
            patId: ordMain.data.patId, //患者Id
            // #10518 2024.04.19 add 対象患者が現患者のベッドに対して「実績確定・削除時装置レポート画像更新」通知を行うためにパラメータ：患者Idを追加 TDC米沢 end
          };
          // add 6963 過去のスケジュールを編集すると対象のベッドの装置の次患者が再送される 房 start
          if (!(parseInt(this.getTreatDate) < parseInt(nowDate))) {
            await this.sendNextPatInfo(params);
          }

          // #10518 2024.04.19 mod 対象患者が現患者のベッドに対して「実績確定・削除時装置レポート画像更新」通知を行う TDC米沢 start
          // // add 6963 過去のスケジュールを編集すると対象のベッドの装置の次患者が再送される 房 end
          // //add FNSI内容修正 外部Api調用 房 start
          // await this.sendEndDateUpdateInfo(params);
          // //add FNSI内容修正 外部Api調用 房 end
          await this.sendAllReportUpdateByPatId(params);
          // #10518 2024.04.19 mod 対象患者が現患者のベッドに対して「実績確定・削除時装置レポート画像更新」通知を行う TDC米沢 end
        } catch (e) {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage(
            "TreatmentRecordMainComponent.vue",
            "deleteRecord",
            "送信失敗しました。"
          );
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
          //del FNSI-8069装置へ送信が失敗しても画面に表示しない ljx start
          /*this.$ons.notification.alert({
            modifier: "warn",
            title: "送信失敗",
            message: `送信失敗しました。\n${e}`
          });*/
          //del FNSI-8069装置へ送信が失敗しても画面に表示しない ljx end
        }
        //add 次患者情報更新の追加 房 end
      }
    },
    /**
     * 【本関数は？？？？患者の場合のみ使用する事】
     * サイドバーの治療状況リスト、治療状況マップ、スケジュールの患者一覧から
     * 与えれたオーダ番号に該当する患者を削除する.
     * 削除した結果は、PatInfoStoreのtreatmentPatListに格納される.
     * @param {Number} ordNo オーダ番号
     */
    clearTreatmentPatList(ordNo) {
      // PatInfoStoreから患者一覧のリストを取得
      const patList = this.treatmentPatList;
      // null若しくは空配列の場合
      if (!patList || patList.length === 0) {
        return;
      }
      // 削除したオーダ番号ではない患者情報に絞り込む.
      const filterResult = patList.filter((pat) => {
        return pat.ord_no !== ordNo;
      });
      this.updateTreatmentPatList(filterResult);
    },
    checkRstDialysisState() {
      this.renderFlg = false;
      // 患者選択有無をチェック
      // ※未選択の場合には、オーダ番号にnullを設定する
      if (!this.patId && !this.isNullPat) {
        this.setOrdNo(null);
      }
      // 治療記録削除ボタン表示判定
      // 治療記録削除ボタン、条件送信破棄ボタン表示判定
      if (this.getOrdNo) {
        this.startLoadingScreen();
        this.getTreatmentRecordResult(this.getOrdNo)
          .then(async (response) => {
            let treatmentRecordData = response.data;
            //add FNSI修正 No.305 start
            this.rstInputClass = treatmentRecordData.rst_input_class;
            //add FNSI修正 No.305 end
            // 排液済以降は治療記録削除ボタンを表示する
            if (
              treatmentRecordData.rst_dialysis_state >=
              CODES.DIALYSIS_STATE.AFTER_DRAINAGE.cd
            ) {
              this.canDeleteRecord = true;
            } else {
              this.canDeleteRecord = false;
            }
            // 実績確定及び版確定可否
            //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
            if (
              this.getItemAuthorized("TreatmentRecord", "default_authority")
              // this.hasAuthorityByCd(AUTHORITY_CODES.RST_PEDIT) ||
              // this.hasAuthorityByCd(AUTHORITY_CODES.RST_EDIT)
              //#10359 mod 編集権限の動作不正 2024-06-05 卓 end
            ) {
              this.canConfirm = true;
            } else {
              this.canConfirm = false;
            }

            // 条件送信後、条件送信確認済みは条件送信破棄ボタンを非活性にする
            if (
              treatmentRecordData.rst_dialysis_state ===
                CODES.DIALYSIS_STATE.AFTER_SEND_CONDITION.cd ||
              treatmentRecordData.rst_dialysis_state ===
                CODES.DIALYSIS_STATE.CONFIRMED_SEND_CONDITION.cd
            ) {
              this.isConditionCancel = true;
            } else {
              this.isConditionCancel = false;
            }

            // 条件送信後、条件送信確認済みは治療開始ボタンの表示判定を行う
            if (
              treatmentRecordData.rst_dialysis_state ===
                CODES.DIALYSIS_STATE.AFTER_SEND_CONDITION.cd ||
              treatmentRecordData.rst_dialysis_state ===
                CODES.DIALYSIS_STATE.CONFIRMED_SEND_CONDITION.cd
            ) {
              const machineStateParams = {
                facilityCd: this.facilityCd,
                ordNo: this.getOrdNo,
              };
              const machineStateRes = await this.getMntMachineState(
                machineStateParams
              );
              // 装置通信異常でないこと
              if (
                machineStateRes.data.length > 0 &&
                machineStateRes.data[0].processState !==
                  CODES.PROCESS_STATE.ABNORMAL.cd
              ) {
                // 装置マスタの取得
                const machineRes = await this.getMstMachineByOrdNoRst(
                  this.getOrdNo
                );
                // add FNSI-「治療開始」ボタン表示不正 徐 end
                this.mstMachine = machineRes.data;
                if (this.mstMachine.length > 0) {
                  // 通信フォーマットがFの場合に治療開始ボタン表示
                  this.isTreatStart =
                    this.mstMachine[0].comFormatCd ===
                      CODES.COM_FORMAT_CD.OFFLINE.cd &&
                    this.mstMachine[0].comType === CODES.COM_TYPE.NOT.cd;
                } else {
                  this.isTreatStart = false;
                }
                if (
                  !this.isTreatStart &&
                  treatmentRecordData.rst_treatment_cd
                ) {
                  // 通信フォーマットがFでない場合、特殊浄化かどうかを判定する
                  const isPurification = await this.getIsPurification(
                    treatmentRecordData.rst_treatment_cd
                  );
                  // 特殊浄化モードの場合に治療開始ボタンを表示
                  this.isTreatStart = String(isPurification.data) === "1";
                }
              } else {
                this.isTreatStart = false;
              }
              // #10889 2024.10.16 mod 治療開始ボタンの表示条件に装置通信異常でないことを追加 TDC片口 end
            } else {
              this.isTreatStart = false;
            }

            // 治療中は治療終了ボタンの表示判定を行う
            if (
              treatmentRecordData.rst_dialysis_state ===
              CODES.DIALYSIS_STATE.DURING_TREATMENT.cd
            ) {
              // 装置マスタの取得
              await this.getMstMachineByOrdNoRst(this.getOrdNo).then(
                async (machineRes) => {
                  this.mstMachine = machineRes.data;
                  if (this.mstMachine.length > 0) {
                    // 通信フォーマットがFの場合治療終了ボタン表示
                    this.isTreatEnd =
                      this.mstMachine[0].comFormatCd ===
                        CODES.COM_FORMAT_CD.OFFLINE.cd &&
                      this.mstMachine[0].comType === CODES.COM_TYPE.NOT.cd;

                    // 通信フォーマットがFでない場合、特殊浄化かどうかを判定する
                    if (
                      !this.isTreatEnd &&
                      treatmentRecordData.rst_treatment_cd
                    ) {
                      // 通信フォーマットがFでない場合、特殊浄化かどうかを判定する
                      await this.getIsPurification(
                        treatmentRecordData.rst_treatment_cd
                      ).then((isPurification) => {
                        // 特殊浄化モードの場合に治療終了ボタンを表示
                        this.isTreatEnd = String(isPurification.data) === "1";
                      });
                    }
                    // 通信フォーマットがFでも特殊浄化でもない場合、装置状態を取得
                    if (!this.isTreatEnd) {
                      const params = {
                        facilityCd: this.facilityCd,
                        ordNo: this.getOrdNo,
                      };
                      this.getMntMachineState(params).then(
                        (machineStateRes) => {
                          // #11192 2025.03.26 mod 装置通信異常、または既に現患者クリア済みの場合に治療終了ボタン表示 TDC片口 start
                          // this.isTreatEnd =
                          //   machineStateRes.data.length > 0 &&
                          //   machineStateRes.data[0].processState ===
                          //     CODES.PROCESS_STATE.ABNORMAL.cd;

                          if (machineStateRes.data.length > 0) {
                            // 装置通信異常
                            this.isTreatEnd = machineStateRes.data[0].processState === CODES.PROCESS_STATE.ABNORMAL.cd;
                          } else {
                            // 現患者登録されている装置がない
                            this.isTreatEnd = true;
                          }
                          // #11192 2025.03.26 mod 装置通信異常、または既に現患者クリア済みの場合に治療終了ボタン表示 TDC片口 end
                        }
                      );
                    }
                  } else {
                    this.isTreatEnd = false;
                  }
                }
              );
            } else {
              this.isTreatEnd = false;
            }
            // ベッドコード
            this.bedCd = treatmentRecordData.rst_bed_cd
              ? treatmentRecordData.rst_bed_cd
              : 0;
            // 実績状況
            this.dialysisState = Number(treatmentRecordData.rst_dialysis_state);
            // 実績状況をstoreに登録
            this.setDialysisState(this.dialysisState);
            // 治療日時をstoreに登録
            this.setTreatDate(treatmentRecordData.treat_date);
            // 初版確定日時をstoreに登録
            this.setRstEditionDate(treatmentRecordData.rst_edition_date);
            // 治療開始日時をstoreに登録
            this.setRstStartDate(treatmentRecordData.rst_start_date);
            // 治療終了日時をstoreに登録
            this.setRstEndDate(treatmentRecordData.rst_end_date);
            // 実績：治療条件情報の格納
            this.setRstCondInfo(treatmentRecordData.rst_cond_info);
            // 表示名
            this.dialysisStateName =
              this.dialysisStateNames[this.dialysisState];
            // 実績確定ボタン名を設定
            if (
              this.dialysisState ===
              Number(CODES.DIALYSIS_STATE.AFTER_WEIGHT_MEASURING.cd)
            ) {
              this.dialysisConfirmName = "実績確定";
            } else if (
              this.dialysisState ===
              Number(CODES.DIALYSIS_STATE.CONFIRMED_WEIGHT_MEASURING.cd)
            ) {
              this.dialysisConfirmName = "版確定";
            }
            // 確定フラグ
            this.is_confirm = treatmentRecordData.is_confirm;
          })
          .finally(() => {
            this.renderFlg = true;
            this.finishLoadingScreen();
          });
      } else {
        this.canDeleteRecord = false;
        this.isConditionCancel = false;

        // 実績状況
        this.dialysisState = 0;
        // 表示名
        this.dialysisStateName = "";
        // 実績確定
        this.dialysisConfirmName = "";
        // 確定フラグ
        this.is_confirm = CODES.IS_CONFIRM.PENDING.cd;
      }
    },

    /**
     * 実績確定／版確定ボタン表示有無
     * ※実績状況(rst_dialysis_state)が、5 or 6 の場合でかつ確定フラグ(is_confirm)が"0"の場合にtrueを返す.
     *   上記以外はfalseを返す.
     * ※？？？？患者(patId=null)が選択されている場合は必ずfalseを返す.
     * 表示条件は下記の通り.
     *  dialysisState = 5 or 6
     *  is_confirm = 0
     *  pat_id != null
     * @returns {Boolean} true:表示する、false:表示しない
     */
    isDispDialysisConfirmButton() {
      // 権限がない場合
      if (!this.canConfirm) {
        return false;
      }
      // mod redmine-8058 「治療記録画面での実績確定を行うことができない」 dou start
      let temp_is_confirm = "0";
      if (this.is_confirm) {
        temp_is_confirm = this.is_confirm;
      } else {
        if (
          this.dialysisState ===
          Number(CODES.DIALYSIS_STATE.CONFIRMED_WEIGHT_MEASURING.cd)
        ) {
          return false;
        }
      }

      return !(this.patId === null && this.isNullPat) &&
        (this.dialysisState ===
          Number(CODES.DIALYSIS_STATE.AFTER_WEIGHT_MEASURING.cd) ||
          this.dialysisState ===
            Number(CODES.DIALYSIS_STATE.CONFIRMED_WEIGHT_MEASURING.cd)) &&
        temp_is_confirm === CODES.IS_CONFIRM.PENDING.cd
        ? true
        : false;
      // mod redmine-8058 「治療記録画面での実績確定を行うことができない」 dou end
    },

    /**
     * ？？？？患者か否かを判定する.
     * 判定は下記の条件に合致する場合に？？？？患者である(true)と判断する.
     *  ・patId が null
     *  ・ordNo が 設定されている
     * @returns {Boolean} true:？？？？患者、false:実患者
     */
    isUnknownPatient() {
      return !(this.patId && !this.isNullPat && this.getOrdNo);
    },

    /**
     * 治療記録のトップ画面に遷移.
     */
    backTreatmentRecord() {
      this.$nextTick(() => {
        this.$router.push({ name: "treatment-record" });
      });
    },

    async cancelSendCond() {
      // 治療中データのordNoを取得
      const ordNoDialysis = this.getOrdNo;
      //mod 内結バッグ28修正 房 start
      // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
      // let alertMsg = "条件送信をキャンセルします。本当によろしいですか？";
      let alertMsg = messageFormat(DIALOG_MESSAGES[13000136].message);
      // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
      if (this.dialysisState == 2) {
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // alertMsg = "透析装置にて条件送信確認済みのため不整合が発生する可能性があります。<br>" +
        //   "システムと透析装置で不整合が発生している場合を除き、透析装置にて条件送信確認解除をしてか<br>" +
        //   "ら条件送信破棄をしてください。<br>" +
        //   "条件送信破棄をしますか？";
        alertMsg = messageFormat(DIALOG_MESSAGES[13000137].message);
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
      }

      await this.$ons.notification.confirm({
        modifier: "warn",
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title:"条件送信キャンセル確認",
        title: DIALOG_MESSAGES[13000136].title,
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        message: alertMsg,
        callback: async (answer) => {
          if (answer == 1) {
            const params = {
              facilityCd: this.facilityCd,
              bedCd: this.bedCd,
              //add FNSI-redmine6215 fang start
              ordNo: this.getOrdNo,
              //add FNSI-redmine6215 fang end
            };
            await this.sendCancelCondition(params)
              .then(() => {
                this.$ons.notification.alert({
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // title: "条件送信キャンセル完了",
                  // message: "条件送信キャンセルが完了しました。",
                  title: DIALOG_MESSAGES[12000245].title,
                  message: messageFormat(DIALOG_MESSAGES[12000245].message),
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                  callback: async () => {
                    // 再表示-ordNoをリセット
                    this.setOrdNo(null);
                    this.setMessage(
                      "治療前、治療中、未確定データはありません。"
                    );
                    // 患者共通ヘッダー：治療進捗状況を更新
                    this.getAcceptanceStatusInfo();
                    // リフレッシュ
                    // EventBus.$emit("refresh");
                    this.backTreatmentRecord();
                    EventBus.$emit("refreshSummary", "cancelSendCond");
                    this.checkRstDialysisState();
                  },
                });
              })
              .catch((error) => {
                this.$ons.notification.alert({
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // title: "条件送信キャンセル失敗",
                  // message: "条件送信キャンセルが失敗しました。",
                  title: DIALOG_MESSAGES[12000246].title,
                  message: messageFormat(DIALOG_MESSAGES[12000246].message),
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                });
                //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
                getErrorMessage(
                  "TreatmentRecordMainComponent.vue",
                  "cancelSendCond",
                  "条件送信キャンセルが失敗しました。"
                );
                //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
                throw new Error(error);
              });
          }
        },
      });
      //mod 内結バッグ28修正 房 end
    },

    async offlineStartTreat() {
      // #9315 2024.02.14 add リロード前の編集チェックを別関数に切り出し TDC片口 start
      // 編集中データを破棄していいかどうかのチェック
      const isEditContinue = await this.checkWantContinueEditing();
      if (isEditContinue) {
        return;
      }
      // #9315 2024.02.14 add リロード前の編集チェックを別関数に切り出し TDC片口 end
      await this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title:"治療開始確認",
        title: DIALOG_MESSAGES[13000138].title,
        // message:"治療を開始してよろしいですか？",
        message: messageFormat(DIALOG_MESSAGES[13000138].message),
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: async (answer) => {
          if (answer == 1) {
            const params = {
              ordNo: this.getOrdNo, //オーダー番号
              machineNo: this.mstMachine[0].machineNo, //装置マスタ.装置番号
              deviceEdgeNo: this.mstMachine[0].deviceEdgeNo, //デバイスエッジ番号
              facilityCd: this.facilityCd, //施設コード
            };
            this.startLoadingScreen();
            this.sendStartOfflineTreat(params)
              .then(async () => {
                const isStartTreatStatus = await this.waitOfflineStartTreat();
                if (!isStartTreatStatus) {
                  this.$ons.notification.alert({
                    // title: "治療開始処理遅延",
                    // message: "治療開始処理に時間がかかっています。時間をおいて画面を更新してください。",
                    title: DIALOG_MESSAGES[12000338].title,
                    message: messageFormat(DIALOG_MESSAGES[12000338].message),
                  });
                }
                // 患者共通ヘッダー：治療進捗状況をリロード
                this.getAcceptanceStatusInfo();
                // 共通部と表示中の子画面のリフレッシュ
                EventBus.$emit("refresh");
                // #9315 2024.02.14 mod オフライン治療開始後画面リロード処理 TDC片口 end
              })
              .catch((error) => {
                this.$ons.notification.alert({
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // title: "治療開始失敗",
                  // message: "治療開始処理が失敗しました。",
                  title: DIALOG_MESSAGES[12000247].title,
                  message: messageFormat(DIALOG_MESSAGES[12000247].message),
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                });
                //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
                getErrorMessage(
                  "TreatmentRecordMainComponent.vue",
                  "offlineStartTreat",
                  "治療開始処理が失敗しました。"
                );
                //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
                throw new Error(error);

                // #9315 2024.02.27 add 共通ローダー変更 TDC片口 start
                //   // add FNSI-画面リフレッシュの追加 徐 start
                // }).finally(() => this.setLoadingScreenVisible(false));
                // // add FNSI-画面リフレッシュの追加 徐 end
              })
              .finally(() => this.finishLoadingScreen());
            // #9315 2024.02.27 add 共通ローダー変更 TDC片口 end
          }
        },
      });
    },
    // #9315 2024.02.26 mod オフライン治療終了後画面リロード処理 TDC片口 start
    // #9315 2024.02.14 add オフライン治療開始後画面リロード処理 TDC片口 start
    /**
     * @summary 0.5秒ごとに10回までステータスが治療中になったかどうかを確認する
     * @returns true: 治療開始を確認, false: 治療開始を確認できなかった
     */
    async waitOfflineStartTreat() {
      return await this.waitDialysisStateUpperThan(
        CODES.DIALYSIS_STATE.DURING_TREATMENT.cd
      );
    },
    /**
     * @summary 0.5秒ごとに10回までステータスが治療終了になったかどうかを確認する
     * @returns true: 治療終了を確認, false: 治療終了を確認できなかった
     */
    async waitOfflineEndTreat() {
      return await this.waitDialysisStateUpperThan(
        CODES.DIALYSIS_STATE.AFTER_DRAINAGE.cd
      );
    },
    /**
     * @summary 0.5秒ごとに10回までステータスが指定値以降になったかどうかを確認する
     * @returns true: 指定値以降を確認, false: 指定値以降を確認できなかった
     */
    async waitDialysisStateUpperThan(state) {
      // 指定時間スリープ関数
      const _sleep = (msec) =>
        new Promise((resolve) => setTimeout(() => resolve(true), msec));

      return this.executeWithLoadingScreen(async () => {
        for (let i = 0; i < 10; i++) {
          // 0.5秒ごと10回繰り返す
          await _sleep(500);
          const currentStateResponse =
            await this.sendRequestGetTreatmentRecordCurrentRstDialysisState(
              this.getOrdNo
            );

          if (Number(currentStateResponse.data) >= Number(state)) {
            // 治療中状態になったことを確認したら終了
            return true;
          }
        }
        return false;
      });
    },
    // #9315 2024.02.14 add オフライン治療開始後画面リロード処理 TDC片口 end
    // #9315 2024.02.26 mod オフライン治療終了後画面リロード処理 TDC片口 end
    async offlineEndTreat() {
      // #9315 2024.02.26 add オフライン治療終了後画面リロード処理 TDC片口 start
      // 編集中データを破棄していいかどうかのチェック
      const isEditContinue = await this.checkWantContinueEditing();
      if (isEditContinue) {
        return;
      }
      // #9315 2024.02.26 add オフライン治療終了後画面リロード処理 TDC片口 end
      await this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title:"治療終了確認",
        title: DIALOG_MESSAGES[13000139].title,
        // message:"治療を終了してよろしいですか？",
        message: messageFormat(DIALOG_MESSAGES[13000139].message),
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: async (answer) => {
          if (answer == 1) {
            // #9315 2024.02.26 mod オフライン治療終了後画面リロード処理 TDC片口 start
            // this.setLoadingScreenVisible(true);
            this.startLoadingScreen();
            const params = {
              ordNo: this.getOrdNo, //オーダー番号
              machineNo: this.mstMachine[0].machineNo, //装置マスタ.装置番号
              deviceEdgeNo: this.mstMachine[0].deviceEdgeNo, //デバイスエッジ番号
              facilityCd: this.facilityCd, //施設コード
            };
            // await this.sendEndOfflineTreat(params).then(() => {
            //   // ord_main.dialysis_stateを監視する
            //   this.chkCnt = 0;
            //   this.timerIdForGetDialysisState = setInterval(
            //     this.chkOfflineEndResult, 2000
            //   );
            this.sendEndOfflineTreat(params)
              .then(async () => {
                const isEndTreatStatus = await this.waitOfflineEndTreat();
                if (!isEndTreatStatus) {
                  this.$ons.notification.alert({
                    // title: "治療終了処理遅延",
                    // message: "治療終了処理に時間がかかっています。時間をおいて画面を更新してください。",
                    title: DIALOG_MESSAGES[12000339].title,
                    message: messageFormat(DIALOG_MESSAGES[12000339].message),
                  });
                }
                if (this.isUnknownPatient()) {
                  // ？？？？患者時はordNo関連情報のリフレッシュのみ行う
                  this.checkRstDialysisState();
                } else {
                  // 患者共通ヘッダー：治療進捗状況をリロード
                  this.getAcceptanceStatusInfo();
                  // 加算機能 - 透析完了した時
                  this.executeAdditionCalculation(2);
                  // 共通部と表示中の子画面のリフレッシュ
                  EventBus.$emit("refresh");
                }
                // #11192 2025.04.24 mod ？？？？患者の治療終了に対応 TDC片口 end
                // #9315 2024.02.26 mod オフライン治療終了後画面リロード処理 TDC片口 end
              })
              .catch((error) => {
                // #9315 2024.02.26 del オフライン治療終了後画面リロード処理 TDC片口 start
                // this.chkCnt = 0;
                // this.setLoadingScreenVisible(false);
                // #9315 2024.02.26 del オフライン治療終了後画面リロード処理 TDC片口 start
                this.$ons.notification.alert({
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // title: "治療終了失敗",
                  // message: "治療終了処理が失敗しました。",
                  title: DIALOG_MESSAGES[12000248].title,
                  message: messageFormat(DIALOG_MESSAGES[12000248].message),
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                });
                //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
                getErrorMessage(
                  "TreatmentRecordMainComponent.vue",
                  "offlineEndTreat",
                  "治療終了処理が失敗しました。"
                );
                //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
                throw new Error(error);
              })
              .finally(() => this.finishLoadingScreen());
          }
        },
      });
    },
    ...mapActions("treatment-record/offlineResultMerge", [
      "selectOfflineResult",
      "mergeOfflineResult",
    ]),
    /**
     * モニタデータ取込
     */
    async offlineResultMerge() {
      // モニタデータファイル込択
      const file = await this.selectOfflineResult();
      if (file) {
        const title = "モニタデータ取込";
        await this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title:title + "確認",
          title: DIALOG_MESSAGES[13000140].title,
          // message:"選択したモニタデータファイル：" + file.name +" をこの治療記録に追加します。<br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000140].message, file.name),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: async (answer) => {
            if (answer == 1) {
              // モニタデータをファイルから読み込んで取り込みを実施
              await this.mergeOfflineResult({
                ordNo: this.getOrdNo,
                file: file,
              })
                .then((res) => {
                  if (res) {
                    // 取り込みが成功した場合は画面更新
                    this.delayReload();
                  }
                })
                .catch((error) => {
                  this.$ons.notification.alert({
                    // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                    // title: title + "失敗",
                    // message: "治療記録への追加に失敗しました。",
                    title: DIALOG_MESSAGES[12000249].title,
                    message: messageFormat(DIALOG_MESSAGES[12000249].message),
                    // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                  });
                  //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
                  getErrorMessage(
                    "TreatmentRecordMainComponent.vue",
                    "offlineResultMerge",
                    "治療記録への追加に失敗しました。"
                  );
                  //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
                  throw new Error(error);
                });
            }
          },
        });
      }
    },
    // #9315 2024.02.26 del オフライン治療終了後画面リロード処理 TDC片口 start
    // chkOfflineEndResult(){
    //   // 患者選択有無をチェック
    //   if (this.patId && !this.isNullPat && this.getOrdNo) {
    //     this.getTreatmentRecordResult(this.getOrdNo).then(response => {
    //       let treatmentRecordData = response.data;
    //       //add FNSI修正 No.305 start
    //       this.rstInputClass = treatmentRecordData.rst_input_class;
    //       //add FNSI修正 No.305 end
    //       // 排液済以降はループ処理を抜ける
    //       if (treatmentRecordData.rst_dialysis_state >= CODES.DIALYSIS_STATE.AFTER_DRAINAGE.cd) {
    //         this.chkCnt = 0;
    //         clearInterval(this.timerIdForGetDialysisState);
    //         this.checkRstDialysisState();
    //         this.setLoadingScreenVisible(false);
    //       }
    //     });
    //   } else {
    //     // 患者未選択・ダミー患者などの場合は処理を抜ける
    //     clearInterval(this.timerIdForGetDialysisState);
    //     this.setLoadingScreenVisible(false);
    //   }
    //   this.chkCnt += 1;
    //   if (this.chkCnt > 4){
    //     // 10秒待っても更新されない場合は処理を抜ける
    //     this.chkCnt = 0;
    //     clearInterval(this.timerIdForGetDialysisState);
    //     this.setLoadingScreenVisible(false);
    //   }
    // },
    // #9315 2024.02.26 del オフライン治療終了後画面リロード処理 TDC片口 end
    /**
     * 子機能ボタンエリアの表示・非表示切替
     * ※治療概要(TreatmentSummaryComponent.vue)からemitで呼出される.
     */
    isOpenButtonArea() {
      this.isOpen = !this.isOpen;
      let elementCancel = document.getElementsByClassName("scroll-area")[0];
      if (this.isOpen) {
        elementCancel.style.width = "10em";
      } else {
        elementCancel.style.width = "0em";
      }
      this.setIsMenuOpen(this.isOpen);

      // グラフを保有するコンポーネント(バイタル、モニタ)の場合はリサイズを行う
      const graphElement = this.$el.getElementsByClassName(
        "highcharts-container"
      );
      if (!graphElement || graphElement.length <= 0) {
        return;
      }
      // レポート(グラフあり)の場合もhighcharts-container(非表示)を使用しているがgraphResize()が存在しないのでリサイズしない
      const isReport = this.$el.querySelector("#highcharts-config");
      if (isReport) return;

      this.$refs.subComponent.graphResize();
    },
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount",
    }),
    delayReload() {
      this.setLoadingScreenVisible(true);
      setTimeout(() => {
        this.checkRstDialysisState();
        this.setLoadingScreenVisible(false);
        // add FNSI-画面リフレッシュの追加 徐 start
        // リフレッシュ
        EventBus.$emit("refresh");
        // add FNSI-画面リフレッシュの追加 徐 end
      }, 2000);
    },

    // mod FNSI 1006 No.538 治療記録 外部連携APIを呼び出 start -- Sanjingye Sun 20210105
    // async executeCreateJournal(coopCd, crud, ordNo) {
    async executeCreateJournal(opeCd, crud, ordNo) {
      const params = {
        ope_cd: opeCd,
        hosp_pat_id:
          this.selectedPat != null
            ? this.selectedPat.pat_personal_main.hosp_pat_id
            : -1,
        base_date: this.getTreatDate,
        facility_cd: this.facilityCd,
        // coop_cd: coopCd,
        // coop_cd_index: "",
        crud: crud,
        // direction: "S",
        // ana_result:"0",
        // coop_result:"0",
        pat_id: this.patId,
        ord_no: ordNo,
        user_id: this.getUserId(),
      };
      // mod FNSI 1006 No.538 治療記録 外部連携APIを呼び出 end -- Sanjingye Sun 20210105
      createJournal(params);
    },
    // #10338 2024.03.29 mod 外部連携パラメータを構築 TDC片口 start
    buildConfirmParamJournal(confirmList, opeCdArray) {
      const createParamRecord = (opeCd, crud) => {
        return {
          opeCd: opeCd,
          patId: this.patId,
          hospPatId:
            this.selectedPat != null
              ? this.selectedPat.pat_personal_main.hosp_pat_id
              : -1,
          crud: crud,
          userId: this.getUserId(),
          baseDate: this.getTreatDate,
        };
      };
      for (const confirmParam of confirmList) {
        confirmParam.journal = [];
        for (const opeCd of opeCdArray) {
          confirmParam.journal.push(createParamRecord(opeCd, "C"));
        }
      }
      return confirmList;
    },
    // #10338 2024.03.29 mod 外部連携パラメータを構築 TDC片口 end
    requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        // 機能一致
        var datee = this.$refs.summary.model.treatment_date;
        // mod 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる　V1.0B 房 start
        if (this.$refs["messageComponent"] != undefined) {
          this.$refs["messageComponent"].setTreatmentDate(datee);
          if(typeof this.$refs["messageComponent"].requestrReportParams === 'function') {
            this.$refs["messageComponent"].requestrReportParams(param);
          }
        } else {
          // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          var curDate = new Date();
          // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
          // 印刷パラメータを応答
          const param = {
            patId: this.patId,
            ordNo: this.getOrdNo,
            // add 画面印刷プレビューと印刷の実現 黄 start
            date: moment(datee).format("YYYY/MM/DD"),
            // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
            //fromDate: moment(datee).format("YYYY/MM/DD"),
            //toDate: moment(datee).format("YYYY/MM/DD"),
            facilityCd: this.facilityCd,
            treatDate: moment(datee).format("YYYYMMDD"),
            fromDate: moment(new Date()).format("YYYYMMDD"),
            toDate: moment(new Date(curDate.setMonth(curDate.getMonth() + 1))).format("YYYYMMDD"),
            // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
            // add 画面印刷プレビューと印刷の実現 黄 end
            functionCd: "00601",
            // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
            reportOneFlag: "0",
            // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
          };
          EventBus.$emit("sendReportParams", param);
        }
        // mod 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる　V1.0B 房 end
      }
    },
    /**
     * 加算機能
     */
    async executeAdditionCalculation(eventId) {
      const addParams = {
        facilityCd: this.facilityCd,
        patId: this.patId,
        ordNo: this.getOrdNo,
        eventId: eventId,
      };
      await ApiHelper.put("/addition_info/calculation", addParams);
    },
    // add FNSI-治療記録バグ7 何 start
    /**
     * 帳票表示処理
     */
    setShowReport: function () {
      if (this.$route.path === "/treatment-record/list") {
        // this.showReport = true;
        return true;
      } else {
        // this.showReport = false;
        return false;
      }
    },
    // add FNSI-治療記録バグ7 何 end
    /**
     * 死活監視ステータス
     */
    isMonistatus() {
      // mod FNSI-修正 redmine3916 房 start
      // add FNSI7836-治療記録画面で患者を変更しても更新しない 周 start
      if (this.getOrdNo) {
        // add FNSI7836-治療記録画面で患者を変更しても更新しない 周 end
        this.getMstMachineByOrdNoRst(this.getOrdNo).then((machineRes) => {
          this.mstMachine = machineRes.data;
          // mod #7233 デフォルト帳票について 日本指摘対応 商 start
          // if (this.mstMachine[0] != undefined) {
          if (
            this.mstMachine[0] != undefined &&
            this.mstMachine[0].deviceEdgeNo != null
          ) {
            // mod #7233 デフォルト帳票について 日本指摘対応 商 end
            this.getmonistatus(this.mstMachine[0].deviceEdgeNo).then(
              (result) => {
                if (result.data === "01") {
                  this.alivemonistatus = true;
                } else {
                  this.alivemonistatus = false;
                }
              }
            );
          }
        });
        // add FNSI7836-治療記録画面で患者を変更しても更新しない 周 start
      }
      // add FNSI7836-治療記録画面で患者を変更しても更新しない 周 end
      // mod FNSI-修正 redmine3916 房 end
    },
    //add FSNI修正外結バッグ35 房 start
    setMessage(message) {
      if (this.$refs["messageComponent"] != undefined) {
        this.$refs["messageComponent"].setMessage(message);
      }
    },
    //add FSNI修正外結バッグ35 房 end
    calculateGridHeight() {
      let targetObj = null;
      const objList = document.getElementsByClassName("treatment-summary");
      if (objList.length !== 0) {
        // class 対象が2つある為、取得対象(divタグ部品)を取得する
        for (let i = 0; objList.length > i; i++) {
          if (objList[i].nodeName === "DIV") {
            targetObj = objList[i];
          }
        }
        this.summaryHeight =
          targetObj != null ? targetObj.offsetHeight + 10 : 40;
      }
    },
    // add #10359 編集権限の動作不正 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 end
  },
  created() {
    // add FNSI-「治療開始」ボタン表示不正 徐 start
    this.checkRstDialysisState();
    this.isMonistatus();
    // add FNSI-「治療開始」ボタン表示不正 徐 end

    // 印刷パラメータ要求
    EventBus.$on("requestReportParams", this.requestrReportParams);
    // add 8304 【デグレ】実績マージを実行すると診療情報の一部が削除済みとなる start
    EventBus.$on("checkRstDialysisState", this.checkRstDialysisState);
    // add 8304 【デグレ】実績マージを実行すると診療情報の一部が削除済みとなる end
    /* modify by chamaojia 2022-10-26 [7217] 繰り返し呼び出しの削除  --start */
    // this.checkRstDialysisState();
    /* modify by chamaojia 2022-10-26 [7217] 繰り返し呼び出しの削除  --end */
    // add FNSI-治療記録バグ7 何 start
    this.showReport = this.setShowReport();
    // add FNSI-治療記録バグ7 何 end

    // #9836 add 利用者マスタの治療記録編集権限をOFFの状態でコンソールエラー/ボタンを押下しても画面の反応がなくなる 2023-09-22 卓 start
    if (this.getOrd == undefined || this.getOrd == null) {
      this.setOrd({
        readOnly: false,
      });
    }
    // #9836 add 利用者マスタの治療記録編集権限をOFFの状態でコンソールエラー/ボタンを押下しても画面の反応がなくなる 2023-09-22 卓 end
  },
  mounted() {
    //add FNSI-修正 共有設定 房 start
    const submenu = document.getElementsByClassName("submenu-area");
    if (
      this.getSharedFacilityCd !== undefined &&
      this.getSharedFacilityCd != null
    ) {
      if (
        this.getSharedFlag === 1 &&
        this.facilityCd !== this.getSharedFacilityCd
      ) {
        submenu[0].style.backgroundColor = "#ffff99";
      } else {
        submenu[0].style.backgroundColor = "";
      }
    } else {
      this.setSharedFacilityCd(this.facilityCd);
      submenu[0].style.backgroundColor = "";
    }

    // #9836 mod 利用者マスタの治療記録編集権限をOFFの状態でコンソールエラー/ボタンを押下しても画面の反応がなくなる 2023-09-22 卓 start
    // if (this.getOrd == undefined || this.getOrd == null) {
    //   this.setOrd({
    //     readOnly: false,
    //   });
    // }
    // #9836 mod 利用者マスタの治療記録編集権限をOFFの状態でコンソールエラー/ボタンを押下しても画面の反応がなくなる 2023-09-22 卓 end

    //add FNSI-修正 共有設定 房 end
    setTimeout(() => {
      this.calculateGridHeight();
    }, 2500);
    this.$nextTick(() => {
      this.calculateGridHeight();
    });

    // 画面印刷時のイベント追加
    window.addEventListener("beforeprint", this.handleBeforePrint);
    window.addEventListener("afterprint", this.handleAfterPrint);
  },
  beforeDestroy() {
    // ポップオーバーの削除
    let hel2 = document.getElementsByClassName("popover-elem");
    if (hel2.length > 0) {
      for (let ii = 0; ii < hel2.length; ii++) {
        hel2[ii].remove();
      }
    }

    // 印刷パラメータ要求
    // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
    // EventBus.$off("requestReportParams");
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
    EventBus.$off("checkRstDialysisState");
    
    window.removeEventListener("beforeprint", this.handleBeforePrint);
    window.removeEventListener("afterprint", this.handleAfterPrint);

    // インターバルをクリア
    if (this.timerIdForGetDialysisState) {
      clearInterval(this.timerIdForGetDialysisState);
    }

    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
};
</script>

<style>
@media print {
  /** 治療記録 通常テキストエリア非表示 */
  body:has(.treatment-record-content-area) textarea.custom-textarea {
    display: none !important;
  }
}
</style>

<style scoped>
.button {
  width: 8em;
  margin: 1px;
  padding: 2px;
}
.button-area {
  background: none;
  display: flex;
  flex-direction: column;
  width: 10em;
  height: fit-content;
}
.button-area a {
  text-decoration: none;
}
.main-area {
  display: flex;
  flex-direction: row;
  height: calc(100% - 5em);
}
.submenu-area {
  flex-grow: 4;
  width: calc(100% - 9.5em);
  overflow-x: auto;
}
.scroll-area {
  width: 9.5em;
  overflow-y: auto;
  overflow-x: hidden;
}
.deleteRecord {
  background-color: #ff3366 !important;
  background-image: none;
}
/** 実績状況の共通スタイル */
.rst-state-common {
  color: #fff;
  text-align: center;
  display: table;
  margin-bottom: 5px;
  position: relative;
  width: 8em;
  height: 2.5em;
  margin: 1px;
  border-radius: none;
}
/** 実績状況表示部の内部要素のスタイル */
.rst-state-inner {
  display: table-cell;
  vertical-align: middle;
  white-space: pre;
  line-height: 1.2em;
}
/** 実績状況の背景色(条件送信後) */
.rst-state-1 {
  background: #42cb92;
}
/** 実績状況の背景色(条件送信確認済) */
.rst-state-2 {
  background: #42cb92;
}
/** 実績状況の背景色(治療中) */
.rst-state-3 {
  background: #2ca06f;
}
/** 実績状況の背景色(排液済) */
.rst-state-4 {
  background: #557769;
}
/** 実績状況の背景色(実績未確定) */
.rst-state-5 {
  background: #557769;
}
/** 実績状況の背景色(過去実績) */
.rst-state-6 {
  background: #808080;
}
/** 実績マージボタン上部の区切り線 */
.separator-line {
  border-top: solid 1px grey;
  margin-top: 1em;
  margin-bottom: 1em;
  width: 6.7em;
  font-size: 1.2em;
}
/** 実績確定／版確定ボタンの背景色 */
.registered-bg-color {
  background-color: #00b050 !important;
  background-image: none;
}
/** 治療記録のメインエリアのスタイル */
.treatment-record-content-area {
  overflow-y: hidden;
  display: flex;
  flex-flow: column;
}
.align-items-left {
  text-align: left;
}
.confirm-background-color {
  background-color: #2ca06f !important;
  background-image: none !important;
}
.btn3-normal[disabled] {
  color: #ffffff !important;
  background-color: #4291b9 !important;
  background-image: none !important;
  border-bottom: solid 3px var(--btn-common-border-color) !important;
  box-shadow: unset;
}
.router-link-width {
  width: 9em;
}
.registration-btn-area {
  width: 9em;
}
</style>
