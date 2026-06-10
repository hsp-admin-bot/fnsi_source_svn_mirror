/**
* 実績マージ画面用ページ
*/
<template>
  <modal-base @onClose="cancel">
    <div slot="body" class="result-merge-base">
      <div class="title-merge-base">
        <div class="title-contain-h1">
          <div class="title-h1-contain">
            <div class="rst-state-common">
              <label class="rst-state-inner">マージ後</label>
            </div>
            <div :class="`rst-state-common rst-state-${statusCd}`">
              <label class="rst-state-inner" style="color:#fff;">{{dialysisStateNames[statusCd]}}</label>
            </div>
            <div class="rst-state-common">
              <label class="rst-state-inner">ベッド</label>
            </div>
            <div>
              <v-ons-row>
                <v-ons-col>
                  <!-- mod #10359 編集権限の動作不正 start -->
                  <!-- <v-ons-select
                    :disabled="bedDisabled"
                    class="selectbox"
                    input-id="bed-cd"
                    model-event="change"
                    v-model="selectedBedCd"
                    name="bed-cd"
                  > -->
                  <v-ons-select
                    :disabled="
                      bedDisabled ||
                      !getItemAuthorized(
                        'TreatmentRecord',
                        'default_authority'
                      )
                    "
                    class="selectbox"
                    input-id="bed-cd"
                    model-event="change"
                    v-model="selectedBedCd"
                    name="bed-cd"
                  >
                    <!-- mod #10359 編集権限の動作不正 end -->
                    <option
                      v-for="(item, index) in comboList.bed"
                      :key="index"
                      :value="item.cd"
                    >{{ item.text }}</option>
                  </v-ons-select>
                </v-ons-col>
              </v-ons-row>
            </div>
          </div>
          <div class="title-h1-icon">
          </div>
          <div class="title-h1-contain align-right-style">
            <div class="align-right-style">
              <v-ons-row>
                <v-ons-col>
                  <!-- mod #10359 編集権限の動作不正 start -->
                  <!-- <v-ons-select
                    v-if="mergeResult"
                    :disabled="delDisabled"
                    class="selectbox"
                    input-id="bed-cd"
                    model-event="change"
                    v-model="defaultCd"
                    name="bed-cd"
                  > -->
                  <v-ons-select
                    v-if="mergeResult"
                    :disabled="
                      delDisabled ||
                      !getItemAuthorized(
                        'TreatmentRecord',
                        'item_delete_btn'
                      )
                    "
                    class="selectbox"
                    input-id="bed-cd"
                    model-event="change"
                    v-model="defaultCd"
                    name="bed-cd"
                  >
                    <!-- mod #10359 編集権限の動作不正 end -->
                    <option
                      v-for="(item, index) in delComboList"
                      :key="index"
                      :value="item.cd"
                    >{{ item.text }}</option>
                  </v-ons-select>
                </v-ons-col>
              </v-ons-row>
            </div>
            <div class="rst-state-common">
              <label v-if="mergeResult" class="rst-state-inner">マージ後</label>
            </div>
          </div>
        </div>
        <div class="title-contain-h2">
          <div class="title-h2-contain">
            <div class="title-font-common">
              <label>治療実績ベース</label>
            </div>
            <div class="title-font-detail">
              <div>
                <label>
                  <span style="margin-right: 0.5em;">{{basePatId}}</span>
                  <span style="word-break: break-all;" :class="inHospital === 1 ? 'pat-name-in-hospital' : ''">{{basePatName}}</span>
                  <span><img v-if="isSame === '1'" class='same-icon' :src="image_src_same" /></span>
                  <br v-if="hasTreatmentInfo(baseTreatmentInfo)">
                  <span :class="getStyle(baseTreatmentInfo.startDate)">{{baseTreatmentInfo.startDate}}</span><span>{{baseTreatmentInfo.startTime}}</span>
                  <span v-if="hasTreatmentInfo(baseTreatmentInfo)"> ～ </span>
                  <span :class="getStyle(baseTreatmentInfo.endDate)">{{baseTreatmentInfo.endDate}}</span><span>{{baseTreatmentInfo.endTime}}</span>
                </label>
              </div>
              <div class="button-img-style">
                <img src="img/treatment-record/round_lock_white.png" v-if="isUnknownPatient() !== true" style="height: 2em;"/>
                <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 start -->
                <v-ons-button v-if="isUnknownPatient() === true" class="btn1-execute select-btn btn3-normal" @click="isChangedShow">変更</v-ons-button>
                <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 end -->
              </div>
            </div>
          </div>
          <div class="title-h2-icon">
            <img v-if="replaceFlag" :src="theme === 0 ? replaceMarkIconB : replaceMarkIconW" style="height: 2em;"/>
          </div>
          <div class="title-h2-contain">
            <div class="title-font-common">
              <label>マージデータ</label>
            </div>
            <div class="title-font-detail">
              <div>
                <label>
                  <span style="margin-right: 0.5em;">{{mergePatId}}</span>
                  <span style="word-break: break-all;" :class="inHospital === 1 ? 'pat-name-in-hospital' : ''">{{mergePatName}}</span>
                  <span><img v-if="isSame === '1' && mergePatName !== ''" class='same-icon' :src="image_src_same" /></span>
                  <br v-if="hasTreatmentInfo(mergeTreatmentInfo)">
                  <span :class="getStyle(mergeTreatmentInfo.startDate)">{{mergeTreatmentInfo.startDate}}</span><span>{{mergeTreatmentInfo.startTime}}</span>
                  <span v-if="hasTreatmentInfo(mergeTreatmentInfo)"> ～ </span>
                  <span :class="getStyle(mergeTreatmentInfo.endDate)">{{mergeTreatmentInfo.endDate}}</span><span>{{mergeTreatmentInfo.endTime}}</span>
                </label>
              </div>
              <div class="button-img-style">
                <img src="img/treatment-record/round_lock_white.png" v-if="isUnknownPatient() === true" style="height: 2em;"/>
                <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 start -->
                <v-ons-button v-if="isUnknownPatient() !== true" class="btn1-execute select-btn btn3-normal" @click="isChangedShow">変更</v-ons-button>
                <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 end -->
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="detail-merge-base">
        <div class="merge-to">
          <table class="treatment-record-list">
            <tbody>
            <template v-for="(data, index) in baseDatalist" >
<!--              <tr :key="index"  :class="'ntss-list-body-tr'" style="height: 3em;">-->
              <tr :key="index"
                  :class="{'ntss-list-body-tr': true, 'tr-unavailable': data.available}"
                  style="height: 3em;">


                <td v-if="data.type === MERGE_ITEM_TYPES.WEIGHT_INFO_RECRCL_DETAIL"
                    class="align-center" style="width: 10%;">
                  <!-- mod FNSI-redmine6535 fang start  -->
                  <!-- mod #10359 編集権限の動作不正 start -->
                    <!-- <v-ons-checkbox
                      v-model="baseRtSelect"
                      :value="data.key"
                      @click.stop
                    >
                    </v-ons-checkbox> -->
                    <v-ons-checkbox
                      v-model="baseRtSelect"
                      :value="data.key"
                      @click.stop
                      :disabled="
                        !getItemAuthorized(
                          'TreatmentRecord',
                          'default_authority'
                        )
                      "
                    >
                    </v-ons-checkbox>
                    <!-- mod #10359 編集権限の動作不正 end -->
                  <!-- mod FNSI-redmine6535 fang end  -->
                </td>

                <td class="align-center" style="width: 10%;" :rowspan="data.rowNum" v-else-if="data.rowNum > 0">
                   <!-- mod #10359 編集権限の動作不正 start -->
                   <!-- <v-ons-checkbox
                      v-if="data.selectNum == 2"
                      v-model="data.selected"
                      @click.stop
                    >
                    </v-ons-checkbox> -->
                    <v-ons-checkbox
                      v-if="data.selectNum == 2"
                      v-model="data.selected"
                      @click.stop
                      :disabled="
                        !getItemAuthorized(
                          'TreatmentRecord',
                          'default_authority'
                        )
                      "
                    >
                    </v-ons-checkbox>
                    <!-- mod #10359 編集権限の動作不正 end -->
                    </td>
                <td class="align-left ntss-list-body-td" :class="mergeItemCellClass(data.type)"
                    :colspan="data.isGroupOrDetail ? 2 : 1" style="width: 45%;"
                    :rowspan="data.rowNum" v-if="data.rowNum > 0">
                  {{data.description}}
                </td>
                <td class="align-left ntss-list-body-td" v-if="!data.isGroupOrDetail" style="width: 45%;">
<!--                  {{getBaseValue(index)}}-->
                  <div v-if="data.type === MERGE_ITEM_TYPES.WEIGHT_INFO_RECRCL_DETAIL"
                       style="height: 13em;"
                       ref="base-weight-info-recrcls"
                       v-html="getBaseValue(index)"></div>
                  <div v-else v-html="getBaseValue(index)"></div>
                </td>
              </tr>
            </template>
            </tbody>
          </table>
        </div>
        <div class="merge-icon">
          <div class="float-icon">
            <img :src="theme === 0 ? leftArrowIconB : leftArrowIconW" style="height: 2em;"/>
          </div>
        </div>
        <div class="merge-from">
          <table class="treatment-record-list">
            <tbody>
            <template v-for="(data, index) in mergeDatalist" >
              <tr :key="index"
                  :class="{'ntss-list-body-tr': true, 'tr-unavailable': data.available}"
                  style="height: 3em;">

                <td v-if="data.type === MERGE_ITEM_TYPES.WEIGHT_INFO_RECRCL_DETAIL"
                    class="align-center" style="width: 10%;">
                  <!-- mod FNSI-redmine6535 fang start  -->
                  <!-- mod #10359 編集権限の動作不正 start -->
                  <!-- <v-ons-checkbox
                    v-if="data.selectNum == 2"
                    v-model="mergeRtSelect"
                    :value="data.key"
                    :disabled="mergeResult && baseResult
                      && (mergeResult.dialysisState == 3 || baseResult.dialysisState == 3)
                      && data.type.name == '治療終了日時'"
                    @click.stop>
                  </v-ons-checkbox> -->
                  <v-ons-checkbox
                    v-if="data.selectNum == 2"
                    v-model="mergeRtSelect"
                    :value="data.key"
                    :disabled="mergeResult && baseResult
                      && (mergeResult.dialysisState == 3 || baseResult.dialysisState == 3)
                      && data.type.name == '治療終了日時'||
                        !getItemAuthorized(
                          'TreatmentRecord',
                          'default_authority'
                        )"
                    @click.stop>
                  </v-ons-checkbox>
                  <!-- mod #10359 編集権限の動作不正 end -->
                  <!-- mod FNSI-redmine6535 fang end  -->
                </td>

                <td v-else-if="data.rowNum > 0" class="align-center" style="width: 10%;" :rowspan="data.rowNum" >
                  <!-- mod FNSI-redmine6535 fang start  -->
                   <!-- mod #10359 編集権限の動作不正 start -->
                  <!-- <v-ons-checkbox
                    v-if="data.selectNum == 2"
                    v-model="data.selected"
                    :disabled="mergeResult && baseResult
                      && (mergeResult.dialysisState == 3 || baseResult.dialysisState == 3)
                      && data.type.name == '治療終了日時'"
                    @click.stop>
                  </v-ons-checkbox> -->
                  <v-ons-checkbox
                    v-if="data.selectNum == 2"
                    v-model="data.selected"
                    :disabled="mergeResult && baseResult
                      && (mergeResult.dialysisState == 3 || baseResult.dialysisState == 3)
                      && data.type.name == '治療終了日時'||
                        !getItemAuthorized(
                          'TreatmentRecord',
                          'default_authority'
                        )"
                    @click.stop>
                  </v-ons-checkbox>
                  <!-- mod #10359 編集権限の動作不正 end -->
                  <!-- mod FNSI-redmine6535 fang end  -->
                </td>

                <td class="align-left ntss-list-body-td" :class="mergeItemCellClass(data.type)"
                    :colspan="data.isGroupOrDetail ? 2 : 1" style="width: 45%;"
                    :rowspan="data.rowNum" v-if="data.rowNum > 0">
                  {{data.description}}
                </td>
                <td class="align-left ntss-list-body-td" v-if="!data.isGroupOrDetail" style="width: 45%;">
<!--                  {{data.value}}-->
                  <div v-if="data.type === MERGE_ITEM_TYPES.WEIGHT_INFO_RECRCL_DETAIL"
                       style="height: 13em;"
                       ref="merge-weight-info-recrcls"
                       v-html="data.value"
                  ></div>
                  <div v-else v-html="data.value"></div>
                </td>
              </tr>
            </template>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <div slot="footer" class="flex-container">
      <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 start -->
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="button denial-btn btn2-cancel" :disabled="!isShared" data-non-authorize="true" @click="cancel">キャンセル</v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <!-- mod #10359 編集権限の動作不正 start -->
        <!-- <v-ons-button class="button registration-btn btn1-execute" :disabled="!isChanged || isReadOnly || !isShared" @click="execute">マージ実行</v-ons-button> -->
        <v-ons-button
          class="button registration-btn btn1-execute"
          :disabled="
            !isChanged ||
            isReadOnly ||
            !isShared ||
            !getItemAuthorized('TreatmentRecord', 'default_authority')
          "
          @click="execute"
          >マージ実行</v-ons-button
        >
        <!-- mod #10359 編集権限の動作不正 end -->
      </div>
      <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 end -->
    </div>
  </modal-base>
</template>
<script>
  // mod FNSI-修正 redmine-8041「？？？？患者の実績マージ後、治療記録の患者名が？？？？患者のまま」 房 start
  import {mapActions, mapGetters, mapMutations} from "vuex";
  // mod FNSI-修正 redmine-8041「？？？？患者の実績マージ後、治療記録の患者名が？？？？患者のまま」 房 end
  import ModalBase from "@/components/modals/ModalBase";
  import DiscardConfirmationMixin from "@/components/treatment-record/DiscardConfirmationMixin";
  import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
  import { ResultMerge } from "@/models/treatment-record/result-merge/ResultMerge";
  import {
    ResultMergeItem,
    MERGE_ITEM_TYPES
  } from "@/models/treatment-record/result-merge/ResultMergeItem";
//#10359 mod 編集権限の動作不正 2024-06-05 卓 start
  // import { AUTHORITY_CODES } from "@/constants/userAuthority";
//#10359 mod 編集権限の動作不正 2024-06-05 卓 end
  // add 8304 【デグレ】実績マージを実行すると診療情報の一部が削除済みとなる start
  import { EventBus } from "@/eventBus.js";
  // add 8304 【デグレ】実績マージを実行すると診療情報の一部が削除済みとなる end
  import {
    // 治療方法マスタ取得API
    sendRequestGetMstTreatment,
    // 薬剤情報取得API
    getMedicineAllTabooAllergy,
    // 医療材料情報取得API
    sendRequestGetMstEquipmentTabooAllergy,
    // ダイアライザ情報取得API
    sendRequestGetMstDialyzerTabooAllergy
  } from "@/apis/treatment-record";
  // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
  import {CODES, TREATMENT_MESSAGES} from "@/constants/TreatmentRecord.js";
  // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
  import moment from "moment";
  // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
  import { messageFormat } from '@/functions/common/MessageFormat';
  import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
  // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
  // add #9709 愁訴処置の実績マージで余分なデータが登録されている。 dengshen start
  import {deepCopy, getAuthorized, getHolidayStyle} from "@/functions/common/CommonFunctions";
  // add #9709 愁訴処置の実績マージで余分なデータが登録されている。 dengshen end
  // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
  import {createJournal} from "@/apis/journal";
  // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end

  export default {
    name: "resultMergeModal",
    mixins: [DiscardConfirmationMixin, ComponentGuardMixin],
    components: {
      "modal-base": ModalBase
    },
    data() {
      return {
        mergeCandidates: [],
        baseResult: null,
        mergeResult: null,
        targetItems: [],
        //#10359 del 編集権限の動作不正 2024-06-05 卓 start
        // authorityCds: [ AUTHORITY_CODES.RST_PEDIT, AUTHORITY_CODES.RST_EDIT ],
        //#10359 del 編集権限の動作不正 2024-06-05 卓 end
        // 治療方法マスタ
        mstTreatment: null,
        // 薬剤マスタ
        mstMedicine: null,
        // 医療材料マスタ
        mstEquipment: null,
        delComboList:[{cd:2,text:"削除する"}, {cd:1,text:"削除しない"}],
        defaultCd:1,
        testList:null,
        baseDatalist:null,
        backBaseDatalist:null,
        mergeDatalist:null,
        backmergeDatalist:null,
        baseInfo:null,
        mergeInfo:null,
        basePatId: "未選択",
        basePatName: "",
        baseTreatmentInfo: {
          startDate: "",
          startTime: "",
          endDate: "",
          endTime: ""
        },
        mergePatId: "未選択",
        mergePatName: "",
        mergeTreatmentInfo: {
          startDate: "",
          startTime: "",
          endDate: "",
          endTime: ""
        },
        comboList: {
          bed: [],
        },
        backCombolist: {
          bed: [],
        },
        baseResultDeviceMode: false,
        selectedBedCd: null,
        // 実績状況と表示名
        dialysisStateNames: {
          1 : "前体重\n測定済",
          2 : "患者\n確認済",
          3 : "治療中",
          4 : "後体重\n未測定",
          5 : "未確定\n実績",
          6 : "確定実績"
        },
        statusCd:null,
        bedDisabled: false,
        delDisabled: false,
        displayFlag: false,
        replaceFlag: false,
        replaceMarkIconB: require("@/../public/img/treatment-record/round_autorenew_black.png"),
        replaceMarkIconW: require("@/../public/img/treatment-record/round_autorenew_white.png"),
        leftArrowIconB: require("@/../public/img/treatment-record/round_arrow_back_ios_new_black.png"),
        leftArrowIconW: require("@/../public/img/treatment-record/round_arrow_back_ios_new_white.png"),
        // 同姓同名アイコン
        image_src_same: require('@/../src/assets/name_duplication.png'),
        inHospital: 0,
        isSame: "0",

        /* #10344 再循環率は三界の外に飛び出した */
        baseRtSelect: [],
        mergeRtSelect: [],
        // 再循環率選択したキュー, 最大5つの選択を制御
        finalRtSelectQueue: [],
      };
    },
    computed: {
      MERGE_ITEM_TYPES() {
        return MERGE_ITEM_TYPES
      },
      ...mapGetters("treatment-record/common", [
        "getOrd"
      ]),
      // mod FNSI-修正 redmine-8041「？？？？患者の実績マージ後、治療記録の患者名が？？？？患者のまま」 房 start
      ...mapGetters("pat-info", { selectedPat: "selectedPat", isNullPat: "isNullPat", selectedPatId:"selectedPatId", treatmentPatList:"treatmentPatList" }),
      // mod FNSI-修正 redmine-8041「？？？？患者の実績マージ後、治療記録の患者名が？？？？患者のまま」 房 end
      // add FNSI-修正 共有設定 トウ start
      ...mapGetters("treatment-record/common", [
        "getOrd",
        "getSharedFacilityCd"
      ]),
      ...mapGetters("user", ["getFacilityCd"]),
      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
      ...mapGetters("account-edit", ["getUserId"]),
      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
      ...mapGetters("treatment-record/result-merge", ["getParamData"]),
      // add FNSI-修正 共有設定 トウ end
      ...mapGetters("account-edit", { theme: "getTheme" }),
      isChanged() {
        if (this.mergeDatalist == null && this.finalRtSelectQueue.length === 0) {
          return false;
        } else {
          return (this.mergeDatalist.some(e => e.selected)) || (this.finalRtSelectQueue.length > 0);
        }
      },
      isReadOnly() {
        return this.getOrd.readOnly;
      },
      // add FNSI-修正 共有設定 トウ start
      isShared() {
        return this.getFacilityCd === this.getSharedFacilityCd;
      },
      // add FNSI-修正 共有設定 トウ end


      ...mapGetters("treatment-record/roundsInfo", {
        roundTypesAtStore: "roundTypes",
      }),

      roundTypes() {
        return this.roundTypesAtStore ? Array.from(this.roundTypesAtStore) : [];
      }
    },
    methods: {
      ...mapActions("multi-modal", ["hideModal"]),
      ...mapActions("treatment-record/result-merge", [
        "getTreatmentRecordResultMergeList",
        "updateTreatmentRecordResultMerge",
        "setSearchParam",
        // add FNSI-修正 redmine-8041「？？？？患者の実績マージ後、治療記録の患者名が？？？？患者のまま」 房 start
        "setMergeOrderNo"
        // add FNSI-修正 redmine-8041「？？？？患者の実績マージ後、治療記録の患者名が？？？？患者のまま」 房 end
      ]),
      ...mapActions("treatment-record/common", ["setOrdNo"]),
      ...mapActions("multi-sub-modal", ["showResultMergePatSearchModal"]),
      // add FNSI-修正 redmine-8041「？？？？患者の実績マージ後、治療記録の患者名が？？？？患者のまま」 房 start
      ...mapActions("pat-info", {setPat: "selectPat", setIsNullPat: "setIsNullPat"}),
      ...mapMutations("pat-info", {
        updateTreatmentPatList: "updateTreatmentPatList"
      }),
      ...mapActions("treatment-record/roundsInfo", [
        "setRstRoundsInfoToCompare",
        "setRstRoundsInfoInProgress",
        "setSelectedRoundType",
      ]),
      // add FNSI-修正 redmine-8041「？？？？患者の実績マージ後、治療記録の患者名が？？？？患者のまま」 房 end
      /**
       * 実績リスト行のクラス取得.
       */
      candidateRowClass(selected) {
        return selected ? "selected-candidate-tr" : null;
      },
      /**
       * マージ項目セルのクラス取得.
       */
      mergeItemCellClass(type) {
        return [
          type.group ? "group-merge-item" : null,
          type.detail ? "detail-merge-item" : null,
          type.subdetail ? "detail-merge-item" : null,
        ];
      },
      /**
       * 透析実績ベースに表示する値を取得.
       */
      getBaseValue(index) {
        if (this.mergeDatalist != null && this.mergeDatalist.length > 0) {
          if (this.mergeDatalist[index].selected === true) {
            return this.mergeDatalist[index].value;
          } else {
            let tempArrs = this.mergeDatalist.filter(el=>el.type.name === "CTR");
            if (this.mergeDatalist[index].type.name === "CTR" && tempArrs[0].selected === true) {
              return this.mergeDatalist[index].value;
            }
          }

        }

        return this.baseDatalist[index].value;
      },
      /**
       * キャンセル処理.
       */
      cancel() {
        if (this.isChanged) {
          this.discardConfirm(() => this.hideModal());
        } else {
          this.hideModal();
        }
      },
      /**
       * 実行処理.
       */
      execute() {
        if(this.isReadOnly) {
          return;
        }
        this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "実行確認",
          title: DIALOG_MESSAGES[13000145].title,
          // message: "実績をマージします。</br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000145].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer === 1) {
              this.doResultMerge();
            }
          }
        });
      },
      /**
       * 実績マージ処理.
       */
      doResultMerge() {

        const deletedItems = this.baseDatalist.filter(e => !e.selected);
        const base = JSON.parse(JSON.stringify(this.baseResult.ordMain));
        let ordCheckListFlag = false;
        deletedItems.forEach(item => {
          if (item.type.name === "投与薬剤情報明細") {
            /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --start */
            // let baseJson = JSON.parse(base.rst_medi_info);
            let baseJson = base.rst_medi_info ? JSON.parse(base.rst_medi_info) : [];
            /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --end */
            if (baseJson != undefined && baseJson.length > 0) {
              for (let i = baseJson.length - 1; i >=0; i--) {
                if (baseJson[i].no == item.key) {
                  baseJson.splice(i, 1);
                }
              }
              base.rst_medi_info = JSON.stringify(baseJson);
            }
          } else if (item.type.name === "医療材料情報明細") {
            /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --start */
            // let baseJson = JSON.parse(base.rst_equip_info);
            let baseJson = base.rst_equip_info ? JSON.parse(base.rst_equip_info) : [];
            /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --end */
            if (baseJson != undefined && baseJson.length > 0) {
              for (let i = baseJson.length - 1; i >=0; i--) {
                if (baseJson[i].cd == item.key) {
                  baseJson.splice(i, 1);
                }
              }
              base.rst_equip_info = JSON.stringify(baseJson);
            }
          } else if (item.type.name === "指示コメント情報明細") {
            /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --start */
            // let baseJson = JSON.parse(base.rst_ind_comment_info);
            let baseJson = base.rst_ind_comment_info ? JSON.parse(base.rst_ind_comment_info) : [];
            /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --end */
            if (baseJson != undefined && baseJson.length > 0) {
              for (let i = baseJson.length - 1; i >=0; i--) {
                if (baseJson[i].no == item.key) {
                  baseJson.splice(i, 1);
                }
              }
              base.rst_ind_comment_info = JSON.stringify(baseJson);
            }
          }
        })

        const selectedItems = this.mergeDatalist.filter(e => e.selected);
        const selectedItemTypes = selectedItems.map(e => e.type);

        // 投与薬剤情報の明細
        const mediInfoItems = selectedItems.filter(e => e.selected && e.type === MERGE_ITEM_TYPES.MEDI_INFO_DETAIL);
        // 医療材料情報の明細
        const equipInfoItems = selectedItems.filter(e => e.selected && e.type === MERGE_ITEM_TYPES.EQUIP_INFO_DETAIL);
        // 指示コメント情報明細
        const commentInfoItems = selectedItems.filter(e => e.selected && e.type.name === "指示コメント情報明細");

        // バイタル情報及びモニタ情報のマージ有無フラグをfalseを設定
        base.vital_merge = false;
        base.monitor_merge = false;

        const merge = this.mergeResult.ordMain;
        const conditionSelected = selectedItems.find(el=>el.type.name === "治療条件情報") != undefined ? true : false;
        let deviceSetRecordFlag = false;
        let deviceFromOrdno = undefined;
        let deviceSetInfoFlag = false;

        let selectedMergeMediInfo = [];

        selectedItems.forEach(item => {
          if (item.type.properties && !item.type.base_property) {
            // 二者択一のマージ項目
            item.type.properties.forEach(e => {
              base[e] = merge[e];
            });
            if (item.type === MERGE_ITEM_TYPES.DEVICE_SET_INFO){
              deviceSetInfoFlag = true;

              base.merge_ord_no = this.mergeResult.ordNo;
            }
            if (item.type.name === "チェックリスト") {
              ordCheckListFlag = true;
            }

            // #11467 【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。　V1.0B Start
            if (item.type.name === "治療方法") {
              base.rst_device_mode = merge.rst_device_mode;
            }
            // #11467 【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。　V1.0B End

          } else if (item.type.properties && item.type.base_property) {
            // 二者択一のマージ項目（JSON項目内）
            const jsonNodes = item.type.base_property.split(".");
            const property = jsonNodes[0];
            const path = jsonNodes.slice(1);

            let baseJson = JSON.parse(base[property]);
            const mergeJson = JSON.parse(merge[property]);
            if (baseJson == null) {
              baseJson = {};
            }
            item.type.properties.forEach(e => {
              const dest = path.reduce((o, n) => o[n], baseJson);
              const source = path.reduce((o, n) => o[n], mergeJson);
              dest[e] = source ? source[e] : null;
            });

            base[property] = JSON.stringify(baseJson);
          } else if (!conditionSelected && item.type.name === "治療条件情報明細") {
            let baseConditionInfo = JSON.parse(base.rst_cond_info);
            let mergeConditionInfo = JSON.parse(merge.rst_cond_info);
            if (mergeConditionInfo == null) {
              if (baseConditionInfo != null && baseConditionInfo.hasOwnProperty(item.type.property)) {
                delete baseConditionInfo[item.type.property];
              }
            } else {
              if (mergeConditionInfo[item.type.property] == undefined || mergeConditionInfo[item.type.property] == null) {
                if (baseConditionInfo != null && baseConditionInfo.hasOwnProperty(item.type.property)) {
                  delete baseConditionInfo[item.type.property];
                }
              } else {
                baseConditionInfo[item.type.property] = mergeConditionInfo[item.type.property];
              }
            }
            base.rst_cond_info = JSON.stringify(baseConditionInfo);
          } else if (item.type === MERGE_ITEM_TYPES.BLOOD_CIRCULATE_TOTAL) {
            // 血液循環積算値
            base.rst_blood_circulate_total += merge.rst_blood_circulate_total;
          } else if (item.type === MERGE_ITEM_TYPES.EQUIP_INFO) {
            // 医療材料情報（グループ）
            base.rst_equip_info = merge.rst_equip_info;
            // 明細のマージは行わないのでリストをクリア
            equipInfoItems.length = 0;
          } else if (item.type === MERGE_ITEM_TYPES.VITAL_INFO) {
            // バイタル情報のマージはサーバ側で行う
            base.vital_merge = true;
            // マージ元のオーダ番号
            base.merge_ord_no = this.mergeResult.ordNo;
          } else if (item.type === MERGE_ITEM_TYPES.MONITOR_INFO) {
            // モニタ情報のマージはサーバ側で行う
            base.monitor_merge = true;
            // マージ元のオーダ番号
            base.merge_ord_no = this.mergeResult.ordNo;
          } else if (item.type === MERGE_ITEM_TYPES.COMPLAINT_INFO) {
            // 愁訴情報
            let editInfo = this.mergeAdditionWithCtlNo(base.rst_complaint_info, merge.rst_complaint_info, base.rst_treatment_info, merge.rst_treatment_info, base.rst_treat_staff_info, merge.rst_treat_staff_info);
            base.rst_complaint_info = editInfo.newComplaint;
            base.rst_treatment_info = editInfo.newTreatment;
            base.rst_treat_staff_info = editInfo.newStaff;
          } else if (item.type === MERGE_ITEM_TYPES.DEVICE_SET_RECORD) {
            deviceSetRecordFlag = true;
            deviceFromOrdno = this.mergeResult.ordNo;
          }
        });
        //mod FNSI-投薬最新識別番号の設定 房 start
        if (mediInfoItems.length > 0) {
          /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --start */
          const mergeJson = merge.rst_medi_info ? JSON.parse(merge.rst_medi_info) : [];
          /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --end */
          mediInfoItems.forEach(item => {
            const source = mergeJson.find(el => el.no === item.key);
            if (this.mergeResult.patId == null) {
              source.no = 0;
            }
            selectedMergeMediInfo.push(source);
          });

          // base.rst_medi_info = JSON.stringify(baseJson);
        }
        //mod FNSI-投薬最新識別番号の設定 房 end

        if (equipInfoItems.length > 0) {
          const baseJson = JSON.parse(base.rst_equip_info);
          const mergeJson = JSON.parse(merge.rst_equip_info);

          equipInfoItems.forEach(item => {
            const source = mergeJson.find(e=>e.cd == item.key);
            baseJson.push(source);
          })

          base.rst_equip_info = JSON.stringify(baseJson);
        }

        if (commentInfoItems.length > 0) {
          let baseJson,mergeJson,baseIndJson = [];
          /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --start */
          // baseJson = JSON.parse(base.rst_ind_comment_info);
          // mergeJson = JSON.parse(merge.rst_ind_comment_info);
          // baseIndJson = JSON.parse(base.ind_ind_comment_info);
          baseJson = base.rst_ind_comment_info ? JSON.parse(base.rst_ind_comment_info) : [];
          mergeJson = merge.rst_ind_comment_info ? JSON.parse(merge.rst_ind_comment_info) : [];
          baseIndJson = base.ind_ind_comment_info ? JSON.parse(base.ind_ind_comment_info) : [];
          /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --end */

          /* modify  #10344 rst_ind_comment's ctlNo Merge rebuild.  --start */

          /* ===== 2024/06/28 Q&Aようり、仕様参照 ===== */
          /*  1.優先指示と実際の最大番号を後ろに並べ替える、
              2.その後、指示と実際の番号では存在しないの番号、
              3.最後に実際の番号では存在しないの番号。       */

          let baseRstNoArr = baseJson.length > 0 ? baseJson.map(z => z.no) : [];
          let baseIndNoArr = baseIndJson.length > 0 ? baseIndJson.map(z => z.no) : [];

          let rstMax = baseJson.length > 0 ? Math.max.apply(Math, baseRstNoArr) : 0;
          let intMax = baseIndJson.length > 0 ? Math.max.apply(Math, baseIndNoArr) : 0;

          let maxNo = rstMax > intMax ? rstMax : intMax;

          // 基底は1 ~ 99の固定番号リスト
          let basicNoArr = Array.from({length:99}, (_, i) => i + 1);
          // ①優先指示と実際の最大番号を後ろに並べ替える
          let firstRoundItemNoArr = basicNoArr.filter(no => no > maxNo);
          // ②その後、指示と実際の番号では存在しないの番号
          let secondRoundItemNoArr = basicNoArr.filter(no =>
             !baseIndNoArr.includes(no) && !baseRstNoArr.includes(no) && !firstRoundItemNoArr.includes(no)
          );
          // ③最後に実際の番号では存在しないの番号。
          let thirdRoundItemNoArr = basicNoArr.filter(no =>
            !baseRstNoArr.includes(no) && !secondRoundItemNoArr.includes(no) && !firstRoundItemNoArr.includes(no)
          );

          let mergeIndCommentItemNoArr = [...firstRoundItemNoArr, ...secondRoundItemNoArr, ...thirdRoundItemNoArr];

          // find out which comment has been selected, then reset ctlNo, set into baseDate.
          commentInfoItems.forEach(item => {
            // #10694 実績マージ後の指示コメントの結果が正しくない
            const source = JSON.parse(JSON.stringify(mergeJson.find(el=>el.no === item.key)));
            // mergeが入力した番号は、残りの番号の先頭に割り当てられ
            if (mergeIndCommentItemNoArr.length > 0) {
              source.no = mergeIndCommentItemNoArr.shift();
            } else {
              // 残りの番号がなくなっている場合は、挿入できないこと。
              return;
            }
            baseJson.push(source);
          });
          /* modify  #10344 rst_ind_comment's ctlNo Merge rebuild.  --end */
          base.rst_ind_comment_info = JSON.stringify(baseJson);
        }

        // 治療開始日時・治療終了日時がマージされた場合
        if (selectedItemTypes.includes(MERGE_ITEM_TYPES.START_DATE)
          || selectedItemTypes.includes(MERGE_ITEM_TYPES.END_DATE)) {
          const startDate = new Date(base.rst_start_date);
          const endDate = new Date(base.rst_end_date);

          // 相関チェックを行う
          if (startDate > endDate && base.rst_end_date != undefined) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "エラー",
              // message: "治療終了日時は治療開始日時より前に設定出来ません。"
              title: DIALOG_MESSAGES[12000262].title,
              message: messageFormat(DIALOG_MESSAGES[12000262].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
            return;
          }

          // 透析運転時間を再計算する
          if (base.rst_end_date == undefined) {
            base.rst_running_time = undefined;
          } else {
            base.rst_running_time = (endDate.getTime() - startDate.getTime()) / (1000 * 60);
          }
        }

        //ベッド処理
        base['rst_bed_cd'] = this.selectedBedCd;
        const selectedBed = this.comboList.bed.find(el=>el.cd === this.selectedBedCd);
        base['rst_bed_name'] = selectedBed.text;
        base['rst_dialysis_state'] = this.statusCd;
        // add FNSI redmine 7474 劉祥霖 start
        if(base['rst_dialysis_state'] === "3"){
          base.rst_end_date = null;
        }

        // #10344 Add 再循環率マージ処理
        if (this.finalRtSelectQueue) {
          let newWeightRecrclRt = {};

          // base & merge の再循環率情報
          let baseWeight = JSON.parse(this.baseResult.ordMain.rst_weight_info);
          let mergeWeight = JSON.parse(this.mergeResult.ordMain.rst_weight_info);
          // target
          let basicWeight = JSON.parse(base.rst_weight_info);

          // 再循環率情報のvalid_no設定
          let inputNodes = document.getElementsByName("rt-valid-chk");
          let validNo = 1;
          for (const inputNode of inputNodes) {
            if (inputNode.checked) {
              validNo = inputNode.value;
              break;
            }
          }
          // Checking vaildNo's param, split by ','
          if (validNo !== 1) {

            let validNoParam = validNo.split(",");
            // 再循環率情報マージ
            for (let i = 1; i < this.finalRtSelectQueue.length + 1; i++) {
              let selectRtElement = this.finalRtSelectQueue[i - 1];

              // selected baseData
              if (selectRtElement.startsWith("base")) {
                // no
                let rtNo = selectRtElement.replace("baser", "");
                // rt info
                let recrclRt = baseWeight.recrcl_rt[rtNo];

                if (validNoParam[0] === rtNo
                  && validNoParam[1] === String(recrclRt.rate)
                  && validNoParam[2] === String(recrclRt.bld_vl)) {
                  validNo = i;
                }

                newWeightRecrclRt = Object.assign(newWeightRecrclRt, {[String(i)]: recrclRt});

              }
              // selected mergeData
              else if (selectRtElement.startsWith("merge")) {
                // no
                let rtNo = selectRtElement.replace("merger", "");
                // rt info
                let recrclRt = mergeWeight.recrcl_rt[rtNo];

                if (validNoParam[0] === rtNo
                  && validNoParam[1] === String(recrclRt.rate)
                  && validNoParam[2] === String(recrclRt.bld_vl)) {
                  validNo = i;
                }

                newWeightRecrclRt = Object.assign(newWeightRecrclRt, {[String(i)]: recrclRt});
              }
            }
            newWeightRecrclRt = Object.assign(newWeightRecrclRt, {"valid_no": String(validNo)});

            basicWeight.recrcl_rt = newWeightRecrclRt;
            base.rst_weight_info = JSON.stringify(basicWeight);
          }

        }

        // マージ結果を更新する
        const param = {
          ordNo: this.getOrdNo,
          payload: base
        };

        let baseOrdNo = this.baseResult.ordNo;
        let basePatId = this.baseResult.patId;

        param.payload.delete_flag = this.defaultCd === 2;
        param.payload.base_ord_no = baseOrdNo;
        param.payload.base_facility_cd = this.getFacilityCd;
        param.payload.base_bed_cd = this.baseResult.ordMain.rst_bed_cd;
        param.payload.mer_ord_no = this.mergeResult.ordNo;
        param.payload.merge_facility_cd = this.getFacilityCd;
        param.payload.merge_bed_cd = this.mergeResult.ordMain.rst_bed_cd;
        param.payload.device_set_record_flag = deviceSetRecordFlag;
        param.payload.device_from_ord_no = deviceFromOrdno;
        param.payload.device_set_info_flag = deviceSetInfoFlag;
        param.payload.ord_check_list_flag = ordCheckListFlag;

        // #10344 Add マージ用投与薬剤リスト長
        param.payload.merge_medi_info_array_len = Array.isArray(mediInfoItems) ? mediInfoItems.length : 0;
        param.payload.merge_rst_medi_info = JSON.stringify(selectedMergeMediInfo);

        let that = this;

        this.updateTreatmentRecordResultMerge(param).then(() => {
          // del 8304 【デグレ】実績マージを実行すると診療情報の一部が削除済みとなる start
          //this.setOrdNo(null);
          // del 8304 【デグレ】実績マージを実行すると診療情報の一部が削除済みとなる end

          that.$nextTick(() => {

            that.setOrdNo(baseOrdNo);
            that.setPat(basePatId);
            that.setIsNullPat(false);
            that.setMergeOrderNo(that.baseResult.ordMain.ord_no);
            let patList = that.treatmentPatList;
            for (let delIndex = patList.length-1; delIndex >= 0; delIndex--) {
              if (patList[delIndex].ord_no == baseOrdNo) {
                patList[delIndex].kur_name = param.payload["rst_kur_name"];
                patList[delIndex].bed_name = param.payload["rst_bed_name"];
              }
              if (patList[delIndex].ord_no == that.mergeResult.ordNo && that.defaultCd == 2) {
                patList.splice(delIndex, 1);
              }
            }
            that.updateTreatmentPatList(patList);

            // #10593 ベース側の回診記録あり&マージ側の回診記録なし、roundInfoがNULLな可能性がある。
            let roundInfo = JSON.parse(base.rst_rounds_info);
            that.setRstRoundsInfoInProgress(roundInfo);
            that.setRstRoundsInfoToCompare(roundInfo);
            let selectRound = that.roundTypes.find(r => r.round_type_cd === (roundInfo ? roundInfo.round_type_cd : 0));
            that.setSelectedRoundType({ selectedRoundType: selectRound });

            // add #10779 実績マージ後の画面でマージ内容が即反映されない zhangyue start
            if (this.selectedPatId) {
              EventBus.$emit("refresh");
            }
            // add #10779 実績マージ後の画面でマージ内容が即反映されない  zhangyue end
            EventBus.$emit("refreshSummary");
            // EventBus.$emit("checkRstDialysisState");
          });
          this.hideModal();

          // 子機能ボタンエリアの更新
          // mod 8304 【デグレ】実績マージを実行すると診療情報の一部が削除済みとなる start
          //this.$emit("update");
          // mod 8304 【デグレ】実績マージを実行すると診療情報の一部が削除済みとなる end
        });
        // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
        const toDeviceMode = this.getDeviceModeForTreatmentCd(parseInt(this.mergeResult.ordMain['rst_treatment_cd']));
        const fromDeviceMode = this.getDeviceModeForTreatmentCd(parseInt(this.baseResult.ordMain['rst_treatment_cd']));
        // 治療記録変更メッセージ
        const message = TREATMENT_MESSAGES.TREATMENT_MAP.filter(
          (msg) => msg.key === `${toDeviceMode}:${fromDeviceMode}`
        ).map((msg) => msg.message)[0];

        // メッセージが空ではない場合
        if (message !== undefined) {
          const params = {
            ope_cd: "006012",
            hosp_pat_id:
              this.selectedPat != null
                ? this.selectedPat.pat_personal_main.hosp_pat_id
                : -1,
            pat_id:
              this.selectedPat != null
                ? this.selectedPat.pat_personal_main.pat_id
                : -1,
            base_date: base['treat_date'],
            facility_cd: this.getFacilityCd,
            crud: "U",
            ord_no: this.getOrdNo,
            user_id: this.getUserId,
          };
          createJournal(params);
        }
        // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
      },
      /**
       * JSON項目の単純追加処理(管理番号洗い替えあり).
       */
      mergeAdditionWithCtlNo(complaintBase, complaintMerge, treatmentBase, treatmentMerge, staffBase, staffMerge) {

        let complaintBaseArr = JSON.parse(complaintBase);

        let treatmentBaseArr = JSON.parse(treatmentBase);

        let staffBaseArr = JSON.parse(staffBase);

        let ctlNoArr = [];

        if (complaintBaseArr != undefined && complaintBaseArr.length > 0) {
          ctlNoArr = ctlNoArr.concat(complaintBaseArr.map(el=>el.ctl_no));
        } else if (complaintBaseArr == undefined || complaintBaseArr == null) {
          complaintBaseArr = [];
        }
        if (treatmentBaseArr != undefined && treatmentBaseArr.length > 0) {
          ctlNoArr = ctlNoArr.concat(treatmentBaseArr.map(el=>el.ctl_no));
        } else if (treatmentBaseArr == undefined || treatmentBaseArr == null) {
          treatmentBaseArr = [];
        }
        if (staffBaseArr != undefined && staffBaseArr.length > 0) {
          ctlNoArr = ctlNoArr.concat(staffBaseArr.map(el=>el.ctl_no));
        } else if (staffBaseArr == undefined || staffBaseArr == null) {
          staffBaseArr = [];
        }

        let maxCtlNo = 0;

        if (ctlNoArr != undefined && ctlNoArr.length > 0) {
          maxCtlNo = ctlNoArr.length > 0 ? Math.max.apply(Math, ctlNoArr) : 0;
        }

        let complaintMergeArr = JSON.parse(complaintMerge);

        let treatmentMergeArr = JSON.parse(treatmentMerge);

        let staffMergeArr = JSON.parse(staffMerge);

        if (complaintMergeArr == undefined || complaintMergeArr == null) {
          complaintMergeArr = [];
        }

        if (treatmentMergeArr == undefined || treatmentMergeArr == null) {
          treatmentMergeArr = [];
        }

        if (staffMergeArr == undefined || staffMergeArr == null) {
          staffMergeArr = [];
        }

        let mergeCtlNoArr = [];

        if (complaintMergeArr != undefined && complaintMergeArr.length > 0) {
          mergeCtlNoArr = mergeCtlNoArr.concat(complaintMergeArr.map(el=>el.ctl_no));
        }
        if (treatmentMergeArr != undefined && treatmentMergeArr.length > 0) {
          mergeCtlNoArr = mergeCtlNoArr.concat(treatmentMergeArr.map(el=>el.ctl_no));
        }
        if (staffMergeArr != undefined && staffMergeArr.length > 0) {
          mergeCtlNoArr = mergeCtlNoArr.concat(staffMergeArr.map(el=>el.ctl_no));
        }

        if (staffMergeArr != undefined && staffMergeArr.length > 0) {
          mergeCtlNoArr = Array.from(new Set(mergeCtlNoArr));

          mergeCtlNoArr.forEach(el=>{
            maxCtlNo = maxCtlNo + 1;
            let editComplaints = complaintMergeArr.filter(element=>element.ctl_no === el);
            if (editComplaints != undefined && editComplaints.length > 0) {
              editComplaints.forEach(editComplaint=> {
                if (editComplaint != undefined) {
                  // mod #9709 愁訴処置の実績マージで余分なデータが登録されている。 dengshen start
                  // editComplaint.ctl_no = maxCtlNo;
                  // complaintBaseArr.push(editComplaint);
                  let item = deepCopy(editComplaint);
                  item.ctl_no = maxCtlNo;
                  complaintBaseArr.push(item);
                  // mod #9709 愁訴処置の実績マージで余分なデータが登録されている。 dengshen end
                }
              })
            }

            let editTreatments = treatmentMergeArr.filter(element=>element.ctl_no === el);
            if (editTreatments != undefined && editTreatments.length > 0) {
              editTreatments.forEach(editTreatment=> {
                if (editTreatment != undefined) {
                  // mod #9709 愁訴処置の実績マージで余分なデータが登録されている。 dengshen start
                  // editTreatment.ctl_no = maxCtlNo;
                  // treatmentBaseArr.push(editTreatment);
                  let item = deepCopy(editTreatment);
                  item.ctl_no = maxCtlNo;
                  treatmentBaseArr.push(item);
                  // mod #9709 愁訴処置の実績マージで余分なデータが登録されている。 dengshen end
                }
              })
            }

            let editStaffs = staffMergeArr.filter(element=>element.ctl_no === el);
            if (editStaffs != undefined && editStaffs.length > 0) {
              editStaffs.forEach(editStaff=> {
                if (editStaff != undefined) {
                  // mod #9709 愁訴処置の実績マージで余分なデータが登録されている。 dengshen start
                  // editStaff.ctl_no = maxCtlNo;
                  // staffBaseArr.push(editStaff);
                  let item = deepCopy(editStaff);
                  item.ctl_no = maxCtlNo;
                  staffBaseArr.push(item);
                  // mod #9709 愁訴処置の実績マージで余分なデータが登録されている。 dengshen end
                }
              })
            }
          })
        }

        return {
          newComplaint: JSON.stringify(complaintBaseArr),
          newTreatment: JSON.stringify(treatmentBaseArr),
          newStaff: JSON.stringify(staffBaseArr)
        }

        // const maxCtlNo = ctlNoArr.reduce((a,b)=>{
        //   return a.ctlNo > b.ctlNo ? a.ctlNo : b.ctlNo;
        // });
        // // mod FNSI-バーグ修正 单体 障害票 治療記録 No.22 孫灝 20201224 start
        // let finalArray = new Array();
        // if(!base) {
        //   finalArray.concat(JSON.parse(base));
        // }
        // if(!merge) {
        //   finalArray.concat(JSON.parse(merge));
        // }
        //
        // // 管理番号の洗い替え
        // finalArray.forEach((e, i) => e.ctl_no = i + 1);
        //
        // return JSON.stringify(finalArray);
        //
        // // const baseJson = JSON.parse(base).concat(JSON.parse(merge));
        // // 管理番号の洗い替え
        // // baseJson.forEach((e, i) => e.ctl_no = i + 1);
        // // return JSON.stringify(baseJson);
        //
        // // mod FNSI-バーグ修正 单体 障害票 治療記録 No.22 孫灝 20201224 end
      },
      /**
       * 初期化処理
       */
      async init() {
        if (!this.getOrdNo) {
          return;
        }
        // マスタ情報取得
        await this.getMstMedicine();
        await this.getMstEquipment();
        await this.getMstDialyzer();

        // 実績マージ対象データを取得する
        await this.getTreatmentRecordResultMergeList(this.getOrdNo).then(response => {
          this.mergeCandidates = response.data.map(e => new ResultMerge(e, this.mstMedicine, this.mstEquipment, this.mstDialyzer));
          this.baseDataCreate();
        });
        await this.getMstTreatment();
        // 選択患者の状態を取得
        if (this.selectedPat !== null) {
          this.inHospital = this.selectedPat.pat_personal_main["in_out_class"];
          this.isSame = this.selectedPat.pat_main["is_same"];
        }
      },

      /**
       * 治療方法マスタ取得
       * 取得した治療方法マスタはmstTreatmentに格納する.
       */
      async getMstTreatment() {
        const response =  await sendRequestGetMstTreatment();
        this.mstTreatment = response.data;
      },

      async baseDataCreate() {
        let tempDatalist = undefined;
        if (this.mergeCandidates.length > 0) {
          tempDatalist =  this.mergeCandidates.find(x => x.ordNo === this.getOrdNo);
        }
        this.baseResultDeviceMode = this.getDeviceModeForTreatmentCd(parseInt(tempDatalist.ordMain.rst_treatment_cd));
        if (this.isUnknownPatient() === true) {
          this.mergeResult = tempDatalist;
          this.mergeInfo = tempDatalist;
          //mod FNSI redmine 7343 ljx　start
          this.mergeDatalist = this.dataListCreate(tempDatalist,"right");
          //this.mergeDatalist = this.dataListCreate(tempDatalist);
          //mod FNSI redmine 7343 ljx　end
          if (this.mergeInfo.patId != null) {
            this.mergePatId = "患者ID：" + this.mergeInfo.hospPatId;
            this.mergePatName = this.mergeInfo.patName;
          } else {
            this.mergePatId = "？？？？患者";
            this.mergePatName = "";
          }

          // 画面表示プロパティに治療開始/終了日時を設定
          this.setTreatmentInfoDate(this.mergeTreatmentInfo, this.mergeInfo.startDate, this.mergeInfo.endDate);

          this.mergeDatalist.forEach(el=>{
            if (el.type.name !== "ベッド"
              && el.type.name !== "条件送信日時"
              && el.type.name !== "受付日時"
              && el.type.name !== "帰宅日時"
              && el.type.name !== "血液循環積算値"
              && el.type.name !== "Kt/V"
              && el.type.name !== "透析記録確認日時"
              && el.type.name !== "送信管理番号"
              && el.type.name !== "血液浄化装置名称"
              && el.type.name !== "プログラム補液引き残し量"
              && el.type.name !== "体重測定記録番号") {
              el.selectNum = 2;
            }
            el.be_selected = false;
          })
          this.backmergeDatalist = this.mergeDatalist.slice(0);
        } else {
          this.baseResult = tempDatalist;
          this.baseInfo = tempDatalist;
          //mod FNSI redmine 7343 ljx　start
          this.baseDatalist = this.dataListCreate(tempDatalist,"left");
          //this.baseDatalist = this.dataListCreate(tempDatalist);
          //mod FNSI redmine 7343 ljx　end
          if (this.baseInfo.patId != null) {
            this.basePatId = "患者ID：" + this.baseInfo.hospPatId;
            this.basePatName = this.baseInfo.patName;
          }

          // 画面表示プロパティに治療開始/終了日時を設定
          this.setTreatmentInfoDate(this.baseTreatmentInfo, this.baseInfo.startDate, this.baseInfo.endDate);

          this.backBaseDatalist = this.baseDatalist.slice(0);
        }
        this.comboList.bed.push({
          cd:tempDatalist.ordMain.rst_bed_cd,
          text:tempDatalist.ordMain.rst_bed_name
        });
        this.backCombolist.bed = this.comboList.bed.slice(0);
        this.selectedBedCd = tempDatalist.ordMain.rst_bed_cd;
        this.statusCd = tempDatalist.ordMain.rst_dialysis_state;
        this.baseSortHandle(this.baseDatalist);
        this.baseSortHandle(this.mergeDatalist);
      },
      //mod FNSI redmine 7343 ljx　start
      //side:left(ベース側)、right(マージ側)
      dataListCreate(dataList,side){
        //dataListCreate(dataList){
      //mod FNSI redmine 7343 ljx　end
        let dataItems = dataList.getItems();
        const dataFixedItems = dataItems.filter(e => e.type != undefined && !e.type.detail);

        // 透析か特殊浄化かの判定
        const isBaseResultPurification = this.baseResultDeviceMode === CODES.DEVICE_MODE.PURIFICATION.cd;

        let deleteItemIndex = -1;
        let resultItems = dataFixedItems.map((e, i) => {
          if (isBaseResultPurification && e.type === MERGE_ITEM_TYPES.DIALYSIS_CNT) {
            deleteItemIndex = i;
            return e;
          } else if (!isBaseResultPurification && e.type === MERGE_ITEM_TYPES.PURIFICATION_CNT) {
            deleteItemIndex = i;
            return e;
          }
          return e;
        });
        if (deleteItemIndex > -1) {
          resultItems.splice(deleteItemIndex, 1);
        }
        // 明細行の項目作成
        Object.values(MERGE_ITEM_TYPES)
          .filter(e => e.detail)
          .forEach(e => {
            const DummyItem = new ResultMergeItem(e);
            const tempDetailItems = dataItems.filter(item => item.type === e);
            const itemLength = Math.max(
              tempDetailItems.length,
            );
            for (let i = 0; i < itemLength; i++) {
              let tempData = i < tempDetailItems.length ? tempDetailItems[i] : DummyItem;
              //add FNSI redmine 7343 ljx　start
              //初期化にベース側の投与薬剤、医療材料、指示コメントのcheckboxがonにする。
              if(side === "left"){
                tempData._selected = true;
              }
              //add FNSI redmine 7343 ljx　end
              resultItems.push(tempData);
            }
          });
        return resultItems;
      },
      /**
       * ？？？？患者か否かを判定する.
       * 判定は下記の条件に合致する場合に？？？？患者である(true)と判断する.
       *  ・selectedPatId が null
       *  ・ordNo が 設定されている
       * @returns {Boolean} true:？？？？患者、false:実患者
       */
      isUnknownPatient() {
        return !(this.selectedPatId && !this.isNullPat && this.getOrdNo);
      },
      /**
       * 治療方法コードに該当する装置モード取得する.
       * @param {Integer} treatmentCd 治療方法コード
       * @return {Integer} 装置モード
       */
      getDeviceModeForTreatmentCd(treatmentCd) {
        // 治療方法マスタ無しの場合、不明を返す
        if (!this.mstTreatment) {
          return CODES.DEVICE_MODE.UNKNOWN.cd;
        }
        if (this.mstTreatment.find(e => e.treatmentCd === treatmentCd) == undefined) {
          return CODES.DEVICE_MODE.UNKNOWN.cd;
        }
        return this.mstTreatment.find(e => e.treatmentCd === treatmentCd).deviceMode;
      },

      /**
       * 薬剤情報取得(禁忌・アレルギー情報付き).
       * @param {Integer} treatmentCd 治療方法コード
       * @return {Integer} 装置モード
       */
      async getMstMedicine() {
        // 治療方法マスタ無しの場合、不明を返す
        const response =  await getMedicineAllTabooAllergy(this.selectedPatId);
        this.mstMedicine = response.data;
      },

      /**
       * 医療材料情報取得(禁忌・アレルギー情報付き).
       * @param {Integer} treatmentCd 治療方法コード
       * @return {Integer} 装置モード
       */
      async getMstEquipment() {
        // 治療方法マスタ無しの場合、不明を返す
        const response =  await sendRequestGetMstEquipmentTabooAllergy(this.selectedPatId);
        this.mstEquipment = response.data;
      },

      /**
       * ダイアライザ―情報取得(禁忌・アレルギー情報付き).
       * @param {Integer} treatmentCd 治療方法コード
       * @return {Integer} 装置モード
       */
      async getMstDialyzer() {
        // 治療方法マスタ無しの場合、不明を返す
        const response =  await sendRequestGetMstDialyzerTabooAllergy(this.selectedPatId);
        this.mstDialyzer = response.data;
      },
      isChangedShow() {
        //変更判断
        if (this.isChanged) {
          this.$ons.notification.confirm({
           // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "内容破棄",
          title: DIALOG_MESSAGES[13000004].title,
          // message: "編集内容が破棄されます。</br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer === 1) {
                this.showDetailList();
              }
            }
          });
        } else {
          this.showDetailList();
        }
      },
      showDetailList() {
        let isUnKnownPat = false;
        let searchStartDate = "";
        let searchEndDate = "";
        let paramInfo = undefined;
        let state;
        if (this.isUnknownPatient() === true) {
          isUnKnownPat = true;
          paramInfo = this.mergeInfo;
          state = this.mergeResult.dialysisState;
        } else {
          paramInfo = this.baseInfo;
          state = this.baseResult.dialysisState;
        }
        if (paramInfo.startDate != null && paramInfo.endDate != null) {
          if (paramInfo.treatmentDate != null) {
            if (paramInfo.treatmentDate <= paramInfo.startDate) {
              searchStartDate = paramInfo.ordMain.treat_date;
              searchEndDate = paramInfo.endDate;
            } else {
              searchStartDate = paramInfo.startDate;
              searchEndDate = paramInfo.endDate;
            }
          } else {
            searchStartDate = paramInfo.startDate;
            searchEndDate = paramInfo.endDate;
          }
        } else if (paramInfo.startDate != null && paramInfo.endDate == null) {
          searchStartDate = paramInfo.startDate;
          searchEndDate = moment(new Date()).format("YYYYMMDD");
        } else {
          searchStartDate = paramInfo.ordMain.treat_date;
          searchEndDate = paramInfo.ordMain.treat_date;
        }
        if (searchStartDate != null && searchStartDate != undefined && searchStartDate != "") {
          searchStartDate = searchStartDate.replace(/\//g,'').substr(0, 8).trim();
        }
        if (searchEndDate != null && searchEndDate != undefined && searchEndDate != "") {
          searchEndDate = searchEndDate.replace(/\//g,'').substr(0, 8).trim();
        }

        this.setSearchParam({
          ord_no: this.getOrdNo,
          is_unknown: isUnKnownPat,
          start_date: searchStartDate,
          end_date: searchEndDate,
          state: state
        });
        this.showResultMergePatSearchModal();
      },
      baseSortHandle(baseSortData){
        const names = Object.values(MERGE_ITEM_TYPES).map(e => e.name);
        if (baseSortData != null) {
          baseSortData.sort((a, b) => {
            return (
              names.indexOf(a.type.name) - names.indexOf(b.type.name)
            );
          });
        }
        return baseSortData;
      },

      /* #10344 ADD --Start */
      /**
       * 変化する要素を見つける
       *
       * @param newVal
       * @param oldVal
       * @returns {*|null}
       */
      findNewElement(newVal, oldVal) {
        if (newVal && !oldVal) {
          return newVal[0];
        } else if (newVal && oldVal) {
          return newVal.find(item => !oldVal.includes(item));
        } else {
          return null;
        }
      },

      /**
       * 再循環率選択したキューに追加要素
       *
       * @param value
       */
      addToRtQueue(value) {
        this.finalRtSelectQueue.push(value);
        if (this.finalRtSelectQueue && this.finalRtSelectQueue.length > 5) {
          let out = this.finalRtSelectQueue.shift();
          this.removeOutQueElementForEachArray(out);
        }
      },

      /**
       * 再循環率選択したキューに削除要素
       *
       * @param value
       */
      removeFromRtQueue(value) {
        let index = this.finalRtSelectQueue.indexOf(value);
        if (index !== 1) {
          let out = this.finalRtSelectQueue.splice(index, 1);
          this.removeOutQueElementForEachArray(out[0]);
        }
      },

      /**
       *
       * @param outElement
       */
      removeOutQueElementForEachArray(outElement) {
        if (outElement) {
          if (outElement.startsWith("base")) {
            let baseOut = outElement.replace("base", "");
            let index = this.baseRtSelect.indexOf(baseOut);
            if (index !== -1) this.baseRtSelect.splice(index, 1);
          } else if (outElement.startsWith("merge")) {
            let mergeOut = outElement.replace("merge", "");
            let index = this.mergeRtSelect.indexOf(mergeOut);
            if (index !== -1) this.mergeRtSelect.splice(index, 1);
          }
        }
      },
      /* #10344 ADD --END */
      // add #10359 編集権限の動作不正 start
      getItemAuthorized(pageCd, itemCd) {
        return getAuthorized(pageCd, itemCd);
      },
      // add #10359 編集権限の動作不正 end
      /**
       * 治療開始終了日時を画面表示プロパティに設定
       * @param {Object} treatmentInfo ベースorマージ
       * @param {String} startDateStr
       * @param {String} endDateStr
       */
      setTreatmentInfoDate(treatmentInfo, startDateStr, endDateStr) {
        const formatDate = (dateStr) => {
          if (!dateStr) return { date: "", time: "" };
          const date = moment(dateStr, "YYYY/MM/DD HH:mm");
          return { date: date.format("YYYY/MM/DD(dd)"), time: date.format(" HH:mm") };
        };
        const { date: startDate, time: startTime } = formatDate(startDateStr);
        const { date: endDate, time: endTime } = formatDate(endDateStr);
        Object.assign(treatmentInfo, { startDate, startTime, endDate, endTime });
      },
      /**
       * 治療開始終了日時の存在有無
       * @param {Object} treatmentInfo ベースorマージ
       * @return true: 存在する、false: 存在しない
       */
      hasTreatmentInfo(treatmentInfo) {
        return treatmentInfo.startDate || treatmentInfo.endDate;
      },
      /**
       * 休日のスタイル取得
       */
      getStyle(date) {
        return getHolidayStyle(date);
      }
    },
    beforeDestroy() {
      // dataの初期化
      Object.assign(this.$data, this.$options.data());
    },
    created() {
      this.init();
    },
    watch: {
      getParamData() {
        this.displayFlag = true;
        this.bedDisabled = false;
        this.delDisabled = false;
        this.replaceFlag = false;
        let paramInfo = new ResultMerge(this.getParamData, this.mstMedicine, this.mstEquipment, this.mstDialyzer);
        if (this.isUnknownPatient() === true) {
          this.baseResult = paramInfo;
          this.baseDatalist = [];
          this.baseInfo = paramInfo;
          //mod FNSI redmine 7343 ljx　start
          const tempDatalist = this.dataListCreate(paramInfo,"left");
          //const tempDatalist = this.dataListCreate(paramInfo);
          //mod FNSI redmine 7343 ljx　end
          this.basePatId = "患者ID：" + this.baseInfo.hospPatId;
          this.basePatName = this.baseInfo.patName;

          // 画面表示プロパティに治療開始/終了日時を設定
          this.setTreatmentInfoDate(this.baseTreatmentInfo, this.baseInfo.startDate, this.baseInfo.endDate);

          let baseMediLength = tempDatalist.filter(element=>element.type.name === "投与薬剤情報明細").length;
          let baseEquipLength = tempDatalist.filter(element=>element.type.name === "医療材料情報明細").length;
          let baseCommentLength = tempDatalist.filter(element=>element.type.name === "指示コメント情報明細").length;
          let mergeMediLength = this.mergeDatalist.filter(element=>element.type.name === "投与薬剤情報明細").length;
          let mergeEquipLength = this.mergeDatalist.filter(element=>element.type.name === "医療材料情報明細").length;
          let mergeCommentLength = this.mergeDatalist.filter(element=>element.type.name === "指示コメント情報明細").length;

          /* #10344 rstMediInfo & rstComment needs to diff by rows. --start */

          // dummy elements add by both side. For sorting method at next call, we can't use short cut array.from()
          // find the max ctl no both side, so the dummy element's no start from max no plus 1
          let baseMaxMediNo = Math.max(
            tempDatalist
              .filter(element=>element.type.name === "投与薬剤情報明細")
              .map(z => z.no)
              .max
          );
          let mergeMaxMediNo = Math.max(
            this.mergeDatalist
              .filter(element=>element.type.name === "投与薬剤情報明細")
              .map(z => z.no)
          );
          for (let i = 1; i <= mergeMediLength; i++) {
            tempDatalist.push(
              new ResultMergeItem(
                MERGE_ITEM_TYPES.MEDI_INFO_DETAIL,
                ``,
                i,
                true,
                []
              )
            );
          }
          for (let i = 1; i <= baseMediLength; i++) {
            this.mergeDatalist.unshift(
              new ResultMergeItem(
                MERGE_ITEM_TYPES.MEDI_INFO_DETAIL,
                ``,
                i,
                true,
                []
              )
            );
          }

          // cause of comment's ctlNo can't raise to 100, so the dummy element's no can start from 100
          for (let i = 100; i < mergeCommentLength + 100; i++) {
            tempDatalist.push(
              new ResultMergeItem(
                MERGE_ITEM_TYPES.IND_COMMENT_INFO_DETAIL,
                ``,
                i,
                true,
                []
              )
            );
          }
          for (let i = 100; i < baseCommentLength + 100; i++) {
            this.mergeDatalist.unshift(
              new ResultMergeItem(
                MERGE_ITEM_TYPES.IND_COMMENT_INFO_DETAIL,
                ``,
                i,
                true,
                []
              )
            );
          }

          /* #10344 rstMediInfo & rstComment needs to diff by rows. --end */

          if (mergeEquipLength > baseEquipLength) {
            for (let i = 0; i < mergeEquipLength - baseEquipLength; i++) {
              tempDatalist.push(new ResultMergeItem(
                MERGE_ITEM_TYPES.EQUIP_INFO_DETAIL,
                ``,
                mergeEquipLength+i,
                false,
                []
              ));
            }
          } else if (baseEquipLength > mergeEquipLength) {
            for (let i = 0; i < baseEquipLength - mergeEquipLength; i++) {
              this.mergeDatalist.push(new ResultMergeItem(
                MERGE_ITEM_TYPES.EQUIP_INFO_DETAIL,
                ``,
                baseEquipLength+i,
                false,
                []
              ));
            }
          }

          tempDatalist.forEach (element=>{
            this.baseDatalist.push(element);
          })
        } else {
          this.mergeResult = paramInfo;
          this.mergeDatalist = [];
          this.mergeInfo = paramInfo;
          //mod FNSI redmine 7343 ljx　start
          const tempDatalist = this.dataListCreate(paramInfo,"right");
          //const tempDatalist = this.dataListCreate(paramInfo);
          //mod FNSI redmine 7343 ljx　start
          if (this.mergeInfo.patId == undefined || this.mergeInfo.patId == null || this.mergeInfo.patId == "") {
            this.mergePatId = "？？？？患者";
            this.mergePatName = "";
          } else {
            this.replaceFlag = true;
            this.mergePatId = "患者ID：" + this.mergeInfo.hospPatId;
            this.mergePatName = this.mergeInfo.patName;
          }

          // 画面表示プロパティに治療開始/終了日時を設定
          this.setTreatmentInfoDate(this.mergeTreatmentInfo, this.mergeInfo.startDate, this.mergeInfo.endDate);

          tempDatalist.forEach(element=>{
            if (element.type.name !== "ベッド"
              && element.type.name !== "条件送信日時"
              && element.type.name !== "受付日時"
              && element.type.name !== "帰宅日時"
              && element.type.name !== "血液循環積算値"
              && element.type.name !== "Kt/V"
              && element.type.name !== "透析記録確認日時"
              && element.type.name !== "送信管理番号"
              && element.type.name !== "血液浄化装置名称"
              && element.type.name !== "プログラム補液引き残し量"
              && element.type.name !== "体重測定記録番号") {
              element.selectNum = 2;
            }
          });
          let mergeMediLength = tempDatalist.filter(element=>element.type.name === "投与薬剤情報明細").length;
          let mergeEquipLength = tempDatalist.filter(element=>element.type.name === "医療材料情報明細").length;
          let mergeCommentLength = tempDatalist.filter(element=>element.type.name === "指示コメント情報明細").length;
          let baseMediLength = this.baseDatalist.filter(element=>element.type.name === "投与薬剤情報明細").length;
          let baseEquipLength = this.baseDatalist.filter(element=>element.type.name === "医療材料情報明細").length;
          let baseCommentLength = this.baseDatalist.filter(element=>element.type.name === "指示コメント情報明細").length;

          /* #10344 rstMediInfo & rstComment needs to diff by rows. --start */

          // dummy elements add by both side.
          // find the max ctl no both side, so the dummy element's no start from max no plus 1
          let baseMaxMediNo = Math.max(
            this.baseDatalist
              .filter(element=>element.type.name === "投与薬剤情報明細")
              .map(z => z.no)
          );
          let mergeMaxMediNo = Math.max(
            tempDatalist
              .filter(element=>element.type.name === "投与薬剤情報明細")
              .map(z => z.no)
          );
          for (let i = 1; i <= mergeMediLength; i++) {
            this.baseDatalist.push(
              new ResultMergeItem(
                MERGE_ITEM_TYPES.MEDI_INFO_DETAIL,
                ``,
                i + baseMaxMediNo,
                true,
                []
              )
            );
          }
          for (let i = 1; i <= baseMediLength; i++) {
            tempDatalist.unshift(
              new ResultMergeItem(
                MERGE_ITEM_TYPES.MEDI_INFO_DETAIL,
                ``,
                i + mergeMaxMediNo,
                true,
                []
              )
            );
          }

          // cause of comment's ctlNo can't raise to 100, so the dummy element's no can start from 100
          for (let i = 100; i < mergeCommentLength + 100; i++) {
            this.baseDatalist.push(
              new ResultMergeItem(
                MERGE_ITEM_TYPES.IND_COMMENT_INFO_DETAIL,
                ``,
                i,
                true,
                []
              )
            );
          }
          for (let i = 100; i < baseCommentLength + 100; i++) {
            tempDatalist.unshift(
              new ResultMergeItem(
                MERGE_ITEM_TYPES.IND_COMMENT_INFO_DETAIL,
                ``,
                i,
                true,
                []
              )
            );
          }
          /* #10344 rstMediInfo & rstComment needs to diff by rows. --start */

          if (mergeEquipLength > baseEquipLength) {
            for (let i = 0; i < mergeEquipLength - baseEquipLength; i++) {
              this.baseDatalist.push(new ResultMergeItem(
                MERGE_ITEM_TYPES.EQUIP_INFO_DETAIL,
                ``,
                mergeEquipLength+i,
                false,
                []
              ));
            }
          } else if (baseEquipLength > mergeEquipLength) {
            for (let i = 0; i < baseEquipLength - mergeEquipLength; i++) {
              tempDatalist.push(new ResultMergeItem(
                MERGE_ITEM_TYPES.EQUIP_INFO_DETAIL,
                ``,
                baseEquipLength+i,
                false,
                []
              ));
            }
          }

          tempDatalist.forEach (element=>{
            this.mergeDatalist.push(element);
          })
        }
        this.comboList.bed = this.backCombolist.bed.slice(0);
        let tempList = this.comboList.bed.filter(e=>e.cd == paramInfo.ordMain.rst_bed_cd);
        if (tempList.length === 0) {
          this.comboList.bed.push({
            cd:paramInfo.ordMain.rst_bed_cd,
            text:paramInfo.ordMain.rst_bed_name
          });
        }
        this.baseSortHandle(this.baseDatalist);
        this.baseSortHandle(this.mergeDatalist);
        if (this.mergeResult.patId == null) {
          if (this.baseResult.dialysisState == 3) {
            if (this.mergeResult.dialysisState == 4 || this.mergeResult.dialysisState == 5) {
              this.delDisabled = true;
              this.bedDisabled = true;
              this.defaultCd = 2;
              this.selectedBedCd = this.baseResult.ordMain.rst_bed_cd;
              this.statusCd = 3;
            }
          } else if (this.baseResult.dialysisState == 4) {
            this.delDisabled = true;
            this.defaultCd = 2;
            if (this.mergeResult.dialysisState == 3) {
              this.bedDisabled = true;
              this.selectedBedCd = this.mergeResult.ordMain.rst_bed_cd;
              this.statusCd = 3;
            } else {
              this.statusCd = this.mergeResult.dialysisState;
            }
          } else if (this.baseResult.dialysisState == 5) {
            this.delDisabled = true;
            this.defaultCd = 2;
            if (this.mergeResult.dialysisState == 3) {
              this.bedDisabled = true;
              this.selectedBedCd = this.mergeResult.ordMain.rst_bed_cd;
              this.statusCd = 3;
            } else {
              this.statusCd = 5;
            }
          } else if (this.baseResult.dialysisState == 6) {
            this.delDisabled = true;
            this.defaultCd = 1;
            this.statusCd = 6;
          }
        } else {
          if (this.baseResult.dialysisState == 3) {
            if (this.mergeResult.dialysisState != 3) {
              this.statusCd = 3;
              this.bedDisabled = true;
              this.selectedBedCd = this.baseResult.ordMain.rst_bed_cd;
              if (this.mergeResult.dialysisState == 6) {
                this.delDisabled = true;
                this.defaultCd = 1;
              }
            }
          } else if (this.baseResult.dialysisState == 4) {
            this.statusCd = this.mergeResult.dialysisState;
            if (this.mergeResult.dialysisState == 6) {
              this.statusCd = 4;
              this.delDisabled = true;
              this.defaultCd = 1;
              this.bedDisabled = true;
              this.selectedBedCd = this.baseResult.ordMain.rst_bed_cd;
            }
            if (this.mergeResult.dialysisState == 3) {
              this.statusCd = 3;
              this.bedDisabled = true;
              this.selectedBedCd = this.mergeResult.ordMain.rst_bed_cd;
            }
          } else if (this.baseResult.dialysisState == 5) {
            this.statusCd = 5;
            if (this.mergeResult.dialysisState == 6) {
              this.delDisabled = true;
              this.defaultCd = 1;
              this.bedDisabled = true;
              this.selectedBedCd = this.baseResult.ordMain.rst_bed_cd;
            }
            if (this.mergeResult.dialysisState == 3) {
              this.statusCd = 3;
              this.bedDisabled = true;
              this.selectedBedCd = this.mergeResult.ordMain.rst_bed_cd;
            }
          } else if (this.baseResult.dialysisState == 6) {
            this.statusCd = 6;
            this.delDisabled = true;
            this.defaultCd = 1;
          }
        }
        // add #10359 編集権限の動作不正 dengshen start
        if (!this.getItemAuthorized('TreatmentRecord', 'item_delete_btn')) {
          this.defaultCd = 1;
        }
        // add #10359 編集権限の動作不正 dengshen end
      },

      /* #10344 Add*/
      // baseSelect
      baseRtSelect: {
        handler(newVal, oldVal) {
          let difElement;
          if (newVal && oldVal) {
            // find the element which has been added just now.
            if (newVal.length > oldVal.length) {
              difElement = this.findNewElement(newVal, oldVal);
              if (difElement) {
                this.addToRtQueue("base" + difElement);
              }
            } else {
              // find the element which has been removed just now.
              difElement = this.findNewElement(oldVal, newVal);
              if (difElement) {
                this.removeFromRtQueue("base" + difElement);
              }
            }
          } else {
            // only one element add or removed
            difElement = newVal ? newVal[0] : oldVal[0];
            if (difElement) {
              if (newVal) this.addToRtQueue("base" + difElement);
              if (oldVal) this.removeFromRtQueue("base" + difElement);
            }
          }
        },
        deep: true
      },
      // mergeSelect
      mergeRtSelect: {
        handler(newVal, oldVal) {
          let difElement;
          if (newVal && oldVal) {
            if (newVal.length > oldVal.length) {
              // find the element which has been added just now.
              difElement = this.findNewElement(newVal, oldVal);
              if (difElement) {
                this.addToRtQueue("merge" + difElement);
              }
            } else {
              // find the element which has been removed just now.
              difElement = this.findNewElement(oldVal, newVal);
              if (difElement) {
                this.removeFromRtQueue("merge" + difElement);
              }
            }
          } else {
            // only one element add or removed
            difElement = newVal ? newVal[0] : oldVal[0];
            if (difElement) {
              if (newVal) this.addToRtQueue("merge" + difElement);
              if (oldVal) this.removeFromRtQueue("merge" + difElement);
            }
          }
        },
        deep: true
      },
    },
  };
</script>

<style scoped>
  .result-merge-base {
    padding: 0px 4px;
    min-width: 1000px;
  }
  .detail-merge-base {
    padding: 0px 4px;
    display: flex;
  }
  .title-merge-base {
    padding: 0px 4px;
    position: sticky;
    top: -3em;
    z-index: 2;
  }
  .merge-to {
    width: 48%;
  }
  .merge-from {
    width: 48%;
  }
  .merge-icon {
    width: 4%;
    align-items: center;
    justify-content: center;
  }
  .title-contain-h1 {
    height: 3em;
    display: flex;
  }
  .title-contain-h2 {
    display: flex;
  }
  .title-h2-contain {
    width: 47.5%;
    background-color: #333333;
    padding: 0.3em 0.3em 0px 0.3em;
  }
  .title-h2-icon {
    width: 4%;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .title-h1-contain {
    width: 47.5%;
    display: flex;
  }
  .title-h1-icon {
    width: 4%;
  }
  .rst-state-inner{
    display: table-cell;
    vertical-align: middle;
    white-space: pre;
    line-height: 1.2em;
  }
  /** 実績状況の背景色(治療中) */
  .rst-state-3 {
    background:#2CA06F;
  }
  /** 実績状況の背景色(排液済) */
  .rst-state-4 {
    background:#557769;
  }
  /** 実績状況の背景色(実績未確定) */
  .rst-state-5 {
    background:#557769;
  }
  /** 実績状況の背景色(過去実績) */
  .rst-state-6 {
    background:#808080;
  }
  /** 実績状況の共通スタイル */
  .rst-state-common {
    text-align:center;
    display: table;
    margin-bottom: 5px;
    position: relative;
    width: 8em;
    height: 2.5em;
    margin: 1px;
    border-radius: none;
  }
  .selectbox {
    margin-top: 0.3em;
    width: 8em;
    height: 2em;
  }
  .align-right-style{
    flex-direction: row-reverse;
  }
  .title-font-common {
    display: flex;
    align-items: center;
    height: 1.5em;
    color: #ffffff;
    text-align: left;
    padding: 0;
    border: 0;
  }
  .title-font-detail {
    display: flex;
    align-items: center;
    justify-content: space-between;
    color: #ffffff;
    text-align: left;
    padding: 0;
    border: 0;
  }
  .button-img-style {
    text-align: center;
  }
  .select-btn {
    width: 4em;
    border-radius:5px;
  }
  .float-icon {
    position: sticky;
    top: calc(30% + 3em);
  }
  .align-center {
    text-align: center;
  }
  .align-left {
    text-align: left;
  }
  .group-merge-item {
    background-color: #777777;
    color: #ffffff;
  }
  .detail-merge-item {
    padding-left: 2em;
  }
  .merge-items {
    height: 68%;
    overflow-y: auto;
  }
  .merge-items > table {
    position: relative;
  }
  .selected-candidate-tr {
    background-color: orange !important;
  }
  th {
    z-index: 2;
  }
  .ntss-list-body-tr,
  .ntss-list-body-td {
    border: solid 1px #cccccc;
  }
  .pat-name-in-hospital {
    color: rgb(163, 86, 163);
  }
  .same-icon {
    position: relative;
    top: 0.25em;
    height: 1.2em;
    margin-left: 0.3em;
  }

  /*Add #10344 unavailable style --start */
  .tr-unavailable {
    background-color: #bcbcbc;
  }
  /*Add #10344 unavailable style --end */
  
@media print {
  .title-h1-contain,
  .title-h2-contain {
    width: 44%;
  }
  .title-h1-icon,
  .title-h2-icon,
  .merge-icon {
    width: 3%;
  }
  .merge-to,
  .merge-from {
    width: 44.8%;
  }
}
</style>
