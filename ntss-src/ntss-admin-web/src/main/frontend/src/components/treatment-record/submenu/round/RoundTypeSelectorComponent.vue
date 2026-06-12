<template>
  <div class="title-and-contents-wrapper">
    <div class="router-link-width">
      <!-- add FNSI-指示者が「医者」以外の場合、回診記録タイトルと回診記録ステータスは非活性 徐 start -->
      <!-- <v-ons-button type="button" class="button registration-btn" :disabled="!getOrdNo" @click="showRoundsInfoRegistration">回診記録</v-ons-button> -->
      <v-ons-button type="button" class="button registration-btn btn3-normal bt3-disabled" :disabled="!getOrdNo || deletedOrCancelCond" @click="showRoundsInfoRegistration">回診記録</v-ons-button>
      <!-- add FNSI-指示者が「医者」以外の場合、回診記録タイトルと回診記録ステータスは非活性 徐 end -->
    </div>
    <div class="contents-area">
      <div class="type-selector">
        <!-- add FNSI-指示者が「医者」以外の場合、回診記録タイトルと回診記録ステータスは非活性 徐 start -->
        <!-- <kendo-dropdownlist
          :disabled="!getOrdNo || atRound || !isNewRoundInfo || !authorized"
          v-model="selectedRoundTypeCd"
          @change="onChangeRoundType"
          @open="addMaxContentStyle"
          :data-source="roundTypes"
          :data-text-field="'round_type_name'"
          :data-value-field="'round_type_cd'"
          :filter="'contains'"
          style="font-size: inherit; width: 100%; margin: 2px;">
        </kendo-dropdownlist> -->
<!--        mod 9553 by kangjie 20231009 start-->
<!--        <kendo-dropdownlist-->
<!--          :disabled="!getOrdNo || atRound || !isNewRoundInfo || !authorized || !isDoctor"-->
<!--          v-model="selectedRoundTypeCd"-->
<!--          @change="onChangeRoundType"-->
<!--          @open="addMaxContentStyle"-->
<!--          :data-source="roundTypes"-->
<!--          :data-text-field="'round_type_name'"-->
<!--          :data-value-field="'round_type_cd'"-->
<!--          :filter="'contains'"-->
<!--          style="font-size: inherit; width: 100%; margin: 2px;">-->
<!--        </kendo-dropdownlist>-->
        <!-- mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen start -->
        <!-- <kendo-dropdownlist -->
        <!--     :disabled="!getOrdNo || atRound || !isNewRoundInfo || !authorized || !isDoctor" -->
        <!--   v-model="selectedRoundTypeCd" -->
        <!--     @change="onChangeSelectedRoundTypeCd($event),onChangeRoundType()" -->
        <!--   @open="addMaxContentStyle" -->
        <!--   :data-source="roundTypes" -->
        <!--   :data-text-field="'round_type_name'" -->
        <!--   :data-value-field="'round_type_cd'" -->
        <!--   :filter="'contains'" -->
        <!--   style="font-size: inherit; width: 100%; margin: 2px;"> -->
        <!-- </kendo-dropdownlist> -->
        <!-- mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 zhao start -->
<!--        <kendo-dropdownlist-->
<!--          :disabled="!getOrdNo || atRound || !isNewRoundInfo || !getItemAuthorized('TreatmentRecord', 'default_authority') || !isDoctor"-->
<!--          v-model="selectedRoundTypeCd"-->
<!--            @change="onChangeSelectedRoundTypeCd($event),onChangeRoundType()"-->
<!--          @open="addMaxContentStyle"-->
<!--          :data-source="roundTypes"-->
<!--          :data-text-field="'round_type_name'"-->
<!--          :data-value-field="'round_type_cd'"-->
<!--          :filter="'contains'"-->
<!--          style="font-size: inherit; width: 100%; margin: 2px;">-->
<!--        </kendo-dropdownlist>-->
        <kendo-dropdownlist
          ref="roundTypeDropdown"
          :disabled="!getOrdNo || atRound || !isNewRoundInfo || !getItemAuthorized('TreatmentRecord', 'default_authority') || !isShared"
          v-model="selectedRoundTypeCd"
          @change="onChangeSelectedRoundTypeCd($event),onChangeRoundType()"
          @open="addMaxContentStyle"
          :data-source="roundTypes"
          :data-text-field="'round_type_name'"
          :data-value-field="'round_type_cd'"
          :filter="'contains'"
          style="font-size: inherit; width: 100%; margin: 2px;">
        </kendo-dropdownlist>
        <!-- mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 zhao end -->
        <!-- mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen end -->
<!--      mod 9553 by kangjie 20231009 end  -->
        <!-- add FNSI-指示者が「医者」以外の場合、回診記録タイトルと回診記録ステータスは非活性 徐 end -->
      </div>
      <div>
        <!--mod FNSI-画面部品デザイン じょはく start-->
        <!-- add FNSI-指示者が「医者」以外の場合、回診記録タイトルと回診記録ステータスは非活性 徐 start -->
        <!-- <v-ons-button type="button" class="button registration-btn registration-btn-area"
          :disabled="!getOrdNo || !isRoundTypeSelected || atRound || !authorized"
          :class="isNewRoundInfo ? 'unregistered-bg-color' : 'green-btn'"
          @click="onRegistrationBtnClick">
          <img src="img/treatment-record/checkbox-icon.png" style="width: 1.2em; vertical-align: text-bottom;" v-show="!isNewRoundInfo"/>
          {{ registrationBtnTitle }}
        </v-ons-button> -->
        <!-- mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen start -->
        <!-- <v-ons-button type="button" class="button registration-btn registration-btn-area btn3-normal" -->
        <!--   :disabled="!getOrdNo || !isRoundTypeSelected || atRound || !authorized || !isDoctor" -->
        <!--   :class="isNewRoundInfo ? 'unregistered-bg-color' : 'green-btn'" -->
        <!--   @click="onRegistrationBtnClick"> -->
        <!-- mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 zhao start -->
<!--        <v-ons-button type="button" class="button registration-btn registration-btn-area btn3-normal"-->
<!--          :disabled="!getOrdNo || !isRoundTypeSelected || atRound || !getItemAuthorized('TreatmentRecord', 'default_authority') || !isDoctor"-->
<!--          :class="isNewRoundInfo ? 'unregistered-bg-color' : 'green-btn'"-->
<!--          @click="onRegistrationBtnClick">-->
<!--        &lt;!&ndash; mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen end &ndash;&gt;-->
<!--          <img src="img/treatment-record/checkbox-icon.png" style="width: 1.2em; vertical-align: text-bottom;" v-show="!isNewRoundInfo"/>-->
<!--          {{ registrationBtnTitle }}-->
<!--        </v-ons-button>-->
        <v-ons-button type="button" class="button registration-btn registration-btn-area btn3-normal"
                      :disabled="!getOrdNo || !isRoundTypeSelected || atRound || !getItemAuthorized('TreatmentRecord', 'default_authority') || !isShared"
                      :class="isNewRoundInfo ? 'unregistered-bg-color' : registrationBtnColorClass"
                      @click="onRegistrationBtnClick">
          <!-- mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen end -->
          <img src="img/treatment-record/checkbox-icon.png" style="width: 1.2em; vertical-align: text-bottom;" v-show="!isNewRoundInfo"/>
          {{ registrationBtnTitle }}
        </v-ons-button>
        <!-- mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 zhao end -->
        <!-- add FNSI-指示者が「医者」以外の場合、回診記録タイトルと回診記録ステータスは非活性 徐 end -->
        <!--mod FNSI-画面部品デザイン じょはく end-->
      </div>
    </div>
  </div>
</template>

<script>
// add #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen end
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { ROUND } from "@/router/treatment-record/index";
import { RstRoundInfo } from "@/models/treatment-record/round/RstRoundInfo";
import RoundComponentMixin from "@/components/treatment-record/submenu/round/RoundComponentMixin";
import dayjs from "@/compat/date/dayjs";
import cloneDeep from "@/compat/collections/lodash/cloneDeep";
import { CODES } from "@/constants/TreatmentRecord";
import {
  dateFormat,
  DATE_FORMAT,
  SHORT_TIME_FORMAT,
  parseDate
} from "@/functions/common/DateTimeUtils"
//import { dateFormat } from "@/functions/common/DateTimeUtils";
import UserAuthorityMixin from "@/components/common/UserAuthorityMixin";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import { sendRequestGetDoctorsAtFacility } from "@/apis/facility";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { findKendoDropdownRoot, findKendoDropdownText, setKendoPopupSurfaceStyles } from "@/functions/common/KendoFunctions";

import { EventBus } from "@/compat/vue/event-bus.js";
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { findKendoDropdownButton } from "@/compat/kendo/dom";

//add #10593 NG マージ後，回診記録タイトル値がありません zhangyue end

export default {
  props: {
    deletedOrCancelCond: {
      type: Boolean,
      default: false
    }
  },
  mixins: [RoundComponentMixin, UserAuthorityMixin],
  data() {
    return {
      roundTypes: [],
      roundRouteDef: ROUND,
      selectedRoundTypeCd: -1,
      rstRoundsInfo: {
        toCompare: null,
        inProgress: new RstRoundInfo()
      },
      commentInfo: {
        facilityCd: null,
        patId: null,
        rstKurCd: [ ],
        rstTreatmentCd: [ ],
        treatDate: null
      },
      authorityCds: [ AUTHORITY_CODES.RST_PEDIT, AUTHORITY_CODES.RST_EDIT ],
	  //add 9724 回診記録の動作が不正 start
      roundTypesAtStore_clone: [],
	  //add 9724 回診記録の動作が不正 end
      //mod 10570回診記録指示コメント転記不具合_#10416指摘事項 zhao start
      hasInProgressFlag:false
      //mod 10570回診記録指示コメント転記不具合_#10416指摘事項 zhao end
    };
  },
  watch: {
    getOrdNo: {
      async handler(newOrdNo) {
        if(!newOrdNo) {
          // 回診記録情報をリセット
          this.selectedRoundTypeCd = -1;
          this.setRstRoundsInfoToCompare(null);
          this.setRstRoundsInfoInProgress(null);
          return;
        }
        await this.getRstRoundsInfoAndSaveToStore();
        this.saveRoundType();
        this.$nextTick(() => {
          this.syncRoundTypeDropdownPresentation();
        });
        // modify start 馬 #9724
        if(!this.rstRoundsInfo.inProgress.round_type_cd && this.rstRoundsInfo.inProgress.round_type_name){
          this.roundTypes = cloneDeep(this.roundTypesAtStore_clone);
          this.roundTypes.unshift({
            round_type_cd: this.rstRoundsInfo.inProgress.round_type_cd,
            round_type_name: this.rstRoundsInfo.inProgress.round_type_name,
            content: this.rstRoundsInfo.inProgress.content,
            is_content_omission: this.rstRoundsInfo.inProgress.is_content_omission,
            comment_post_default: this.rstRoundsInfo.inProgress.comment_post_default,
            posting_class_default: this.rstRoundsInfo.inProgress.posting_class_default,
            hidden: true
          });
        } else {
          this.roundTypes = cloneDeep(this.roundTypesAtStore_clone);
        }
        this.$nextTick(() => {
          this.selectedRoundTypeCd = this.rstRoundsInfo.inProgress.round_type_cd;
          if ((this.selectedRoundTypeCd == -1 || this.selectedRoundTypeCd == null) && this.roundTypes[0] != undefined) {
            this.selectedRoundTypeCd = this.roundTypes[0].round_type_cd;
          }
        })
      },
      immediate: true
      // modify end 馬 #9724
    },
    selectedRoundType(newRoundType) {
      if (newRoundType != null) {
        this.selectedRoundTypeCd = newRoundType.round_type_cd;
      }
    },
    async $route(newVal, oldVal) {
      const toPath = newVal.path.split("/").slice(-1)[0];
      const fromPath = oldVal.path.split("/").slice(-1)[0];

      // 回診記録から他の子機能へ遷移するときに、種別を変更前の状態にもどす
      if(toPath !== this.roundRouteDef.path && fromPath === this.roundRouteDef.path) {
        //add 9724 ljx start コンソールError修正
        if(this.getOrdNo){
        await this.getRstRoundsInfoAndSaveToStore();
        this.saveRoundType();
        }
        //add 9724 ljx end コンソールError修正
      }
    },
    isNewRoundInfo(){
      this.$nextTick(() => {
        this.syncRoundTypeDropdownPresentation();
      });
    },
    // add 9724 start
    roundTypesAtStore(){
      this.roundTypes = this.roundTypesAtStore;
    },
    // add 9724 end
  },
  computed: {
    ...mapGetters("pat-info", ["selectedPatId", "isNullPat"]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("treatment-record/common", ["getOrdNo", "getSharedFacilityCd"]),
    ...mapGetters("treatment-record/roundsInfo", {
      roundTypesAtStore: "roundTypes",
      rstRoundsInfoToCompare: "rstRoundsInfoToCompare",
      rstRoundsInfoInProgress: "rstRoundsInfoInProgress",
      selectedRoundType: "selectedRoundType",
      rstIndComments: "rstIndComments",
    }),
    ...mapGetters("account-edit", {
      accountInfo: "getStateUserAccountInfo"
    }),
    // add FNSI-指示者が「医者」以外の場合、回診記録タイトルと回診記録ステータスは非活性 徐 start
    ...mapGetters("indication", ["isDoctor"]),
    // add FNSI-指示者が「医者」以外の場合、回診記録タイトルと回診記録ステータスは非活性 徐 end
    registrationBtnTitle() {
      return this.isNewRoundInfo ? "未回診" : "回診済み";
    },
    isShared() {
      return this.getFacilityCd === this.getSharedFacilityCd;
    },
    isRoundTypeSelected() {
      return this.selectedRoundTypeCd > -1;
    },
    isRoundTypeChanged() {
      return this.rstRoundsInfoToCompare.round_type_cd
        !== this.rstRoundsInfoInProgress.round_type_cd;
    },
    atRound() {
      return this.$route.path.split("/").slice(-1)[0] === this.roundRouteDef.path;
    },
    registrationBtnColorClass() {
      // 強調表示初期値(通常)
      let highlighting = 0;
      // 選択されている回診記録の種別コードより強調表示値を取得
      const selectedRoundType = this.roundTypes.find(r => r.round_type_cd === this.selectedRoundTypeCd);
      if(!!selectedRoundType && !!selectedRoundType.highlighting){
        highlighting = selectedRoundType.highlighting;
      }
      // 取得した強調表示値をもとにclass文字列返却
      return "registered-bg-color-" + highlighting;
    },
  },
  methods: {
    ...mapActions("treatment-record/roundsInfo", [
      "updateIndComment"
      , "updateTreatmentRecordRstRoundsInfo"
      , "setSelectedRoundTypeCd"
      , "setRstRoundsInfoToCompare"
      , "setRstRoundsInfoInProgress"
    ]),
    ...mapActions("treatment-record/addition", ["updateTreatmentRecordAddition"]),
    // add FNSI-指示者が「医者」以外の場合、回診記録タイトルと回診記録ステータスは非活性 徐 start
    ...mapActions("indication", ["checkIsDoctor"]),
    // add FNSI-指示者が「医者」以外の場合、回診記録タイトルと回診記録ステータスは非活性 徐 end
    // add #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10570 回診記録指示コメント転記不具合_#10416指摘事項 dengshen end
    // 回診記録ボタン押下時の処理

    onRegistrationBtnClick() {
      if (this.isNewRoundInfo) {
        // mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 張玲 start
        // this.roundsInfoRegistration();
        const selectedRoundType = this.roundTypes.find(r => r.round_type_cd === this.selectedRoundTypeCd);
        selectedRoundType &&
        (
          selectedRoundType.is_content_omission === '0' ||
          selectedRoundType.comment_post_default === '1'
        )
         ? this.showRoundsInfoRegistration() : this.roundsInfoRegistration();
        // mod #10570 回診記録指示コメント転記不具合_#10416指摘事項 張玲 end
      } else {
        this.onDeleteClick();
      }
      // 子機能ボタンエリアの更新
      //mod 9724 ljx start
      //this.$emit("update");
      //mod 9724 ljx end
    },
    async roundsInfoRegistration() {
      const response = await this.getTreatmentRecordAddition(this.getOrdNo);
      this.commentInfo.facilityCd = response.data.facility_cd;
      this.commentInfo.patId = response.data.pat_id;
      this.commentInfo.rstKurCd = response.data.rst_kur_cd;
      this.commentInfo.rstTreatmentCd = response.data.rst_treatment_cd;
      this.commentInfo.treatDate = response.data.treat_date;

      await this.getRstRoundsInfoAndSaveToStore();
      this.updateRoundType();
      if(!this.isNewRoundInfo && this.isRoundTypeChanged) {
        this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "削除確認",
          title: DIALOG_MESSAGES[13000148].title,
          // message:
          // "種別が変更になりましたので<br>前の記録は削除されますが<br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000148].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: async answer => {
            if (answer === 1) {
              if(this.selectedRoundType.is_content_omission === "0") {
                this.routePushToRound();
              } else {
                await this.deleteIndIndComment();
                await this.deleteRstIndComment();
                await this.saveRoundsInfoOmission();
              }
            } else {
              const roundTypeCd = this.rstRoundsInfo.toCompare.round_type_cd;
              const roundType = this.roundTypes.find(r => r.round_type_cd === roundTypeCd);
              this.setSelectedRoundType({ selectedRoundType: roundType });
              this.selectedRoundTypeCd = roundTypeCd;
            }
            //mod 9724 ljx start
            this.$emit("update");
            //mod 9724 ljx end
          }
        });
      } else {
        // 職種が医師の利用者一覧を取得
        const doctorResponse = await sendRequestGetDoctorsAtFacility(this.getFacilityCd, this.selectedPatId);
        // add 9553 by kangjie 20231007 start ページボタンには既に権限制御が存在しているので、このコードに権限を判断する必要はありません。
        // 治療指示権限がない、又は対応する医師がいない場合は省略をしない
        // 指示コメントに転記のチェックがオン、且つ選択患者が？？？？患者(patId=null)の場合も省略しない
        //this.selectedRoundType.is_content_omission === "0" ||
        //(this.selectedRoundType.comment_post_default === "1" && this.selectedPatId === null && this.isNullPat)
        // if( this.selectedRoundType.is_content_omission === "1"
        //     // || !(this.getUserAuthorityCds().includes(AUTHORITY_CODES.IND_EDIT) || this.getUserAuthorityCds().includes(AUTHORITY_CODES.IND_PEDIT))
        //    || doctorResponse.data.length <= 0
        //    || (this.selectedRoundType.comment_post_default === "0" && this.selectedPatId === null && this.isNullPat)) {
        //   this.routePushToRound();
        // } else {
          await this.saveRoundsInfoOmission();
          await this.getRstRoundsInfoAndSaveToStore();
        //mod 9724 ljx start
        this.$emit("update");
        //mod 9724 ljx end
        // }
        // add 9553 by kangjie 20231007 end
      }

    },
    // 回診記録の表示
    async showRoundsInfoRegistration() {
      // すでに回診記録が表示されている場合、以降の処理をしない
      if (this.atRound) {
        return;
      }
      const response = await this.getTreatmentRecordAddition(this.getOrdNo);
      this.commentInfo.facilityCd = response.data.facility_cd;
      this.commentInfo.patId = response.data.pat_id;
      this.commentInfo.rstKurCd = response.data.rst_kur_cd;
      this.commentInfo.rstTreatmentCd = response.data.rst_treatment_cd;
      this.commentInfo.treatDate = response.data.treat_date;

      await this.getRstRoundsInfoAndSaveToStore();
      this.updateRoundType();
      this.routePushToRound();
    },
    routePushToRound() {
      this.$router.push({ name: this.roundRouteDef.name });
    },
    // add 9553 by kangjie 20231009 start
    onChangeSelectedRoundTypeCd(event){
      this.selectedRoundTypeCd = event.sender._old;
    },
    // add 9553 by kangjie 20231009 end
    onChangeRoundType() {
      // mod 9553 by kangjie 20231007 start
      const selectedRoundType = this.roundTypes
        // .find(roundType => roundType.round_type_cd.toString() === this.selectedRoundTypeCd)
		//mod 9724 回診記録の動作が不正 start
        .find(roundType => roundType.round_type_cd == this.selectedRoundTypeCd)
		//mod 9724 回診記録の動作が不正 end
      ;
      // mod 9553 by kangjie 20231007 end
      this.setSelectedRoundType({ selectedRoundType });
    },
    updateRoundType() {
      const selectedRoundType = this.roundTypes.find(r => r.round_type_cd === this.selectedRoundTypeCd);
      if(!selectedRoundType) return;

      this.rstRoundsInfo.inProgress.round_type_cd = selectedRoundType.round_type_cd;
      this.rstRoundsInfo.inProgress.round_type_name = selectedRoundType.round_type_name;

      this.setRstRoundsInfoInProgress(this.rstRoundsInfo.inProgress);
    },
    /**
     * YEDの指示コメント更新APIに渡すパラメータJSONを生成する.
     * @param {Number} commentFlag コメントフラグ(1：新規、2：編集、それ以外：削除) constants/TreatmentRecord#COMMENT_FLAG参照
     * @param {boolean} isDeadline true（期限付き）、false（無期限）
     */
    createIndCommentParameter(commentFlag, isDeadline) {
      const endDate = isDeadline ?
        this.commentInfo.treatDate :
        (() => {
          // 無期限の場合、`本日＋１年－1日`
          const d = dayjs().add(1, "years").subtract(1, 'days');
          return d.format("YYYYMMDD");
        })();
      return {
        comment_flag: commentFlag,
        pat_id: this.commentInfo.patId,
        facility_cd: this.commentInfo.facilityCd,
        start_date: this.commentInfo.treatDate,
        end_date: endDate,
        num_comment: this.rstRoundsInfo.inProgress.ind_comment_no,
        comment: this.rstRoundsInfo.inProgress.content,
        weeks: '[{"text":"全","done":true,"value":0}]',
        ind_kur_cd: this.commentInfo.rstKurCd,
        ind_treatment_cd: this.commentInfo.rstTreatmentCd,
        ind_user: this.rstRoundsInfo.inProgress.ind_user_id,
        upd_user: this.accountInfo.userId,
        //add 9724回診記録の動作が不正 zhao start
        ind_user_id: this.rstRoundsInfo.inProgress.ind_user_id,
        upd_user_id: this.accountInfo.userId,
        //add 9724回診記録の動作が不正 zhao end
        is_deadline: isDeadline,
        //add 10416 治療記録＞回診記録の指示コメント展開バグ zhao start
        ord_no: this.getOrdNo
        //add 10416 治療記録＞回診記録の指示コメント展開バグ zhao end
      };
    },
    async deleteIndIndComment() {
      if(!this.rstRoundsInfo.inProgress.shouldSaveIndComment()) return;
      //mod 10416 治療記録＞回診記録の指示コメント展開バグ zhao start
      // this.updateIndComment(this.createIndCommentParameter(CODES.COMMENT_FLAG.DELETE.cd, false));
      this.updateIndComment(this.createIndCommentParameter(CODES.COMMENT_FLAG.DELETE.cd, true));
      //mod 10416 治療記録＞回診記録の指示コメント展開バグ zhao end
    },
    async deleteRstIndComment() {
      if(!this.rstRoundsInfo.inProgress.shouldSaveRstIndComment()) return;
      const commentNo = this.rstRoundsInfo.inProgress.ind_comment_no;
      const indComments = this.rstIndComments.filter(c => c.no !== commentNo);

      this.updateTreatmentRecordAddition({
        ordNo: this.getOrdNo,
        payload: { rst_ind_comment_info: JSON.stringify(indComments) }
      })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage('RoundTypeSelectorComponent.vue','deleteRstIndComment','実績の指示コメント登録に失敗しました。');
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end

          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "登録失敗",
              // message: "実績の指示コメント登録に失敗しました。"
              title: DIALOG_MESSAGES[12000252].title,
              message: messageFormat(DIALOG_MESSAGES[12000252].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }
        });
    },
    saveRoundsInfoOmission() {
      //9724-③　add  ljx start isChangedの解決
      // 新規の場合、回診日にシステム日時を設定
      const roundDate = dateFormat.format(new Date(), DATE_FORMAT);
      const roundTime = dateFormat.format(new Date(), SHORT_TIME_FORMAT);
      // 回診日時
      let roundDateTime = dateFormat.utc2Jst(
        parseDate(
          roundDate,
          roundTime));
      //9724-③ add  ljx end
      return this.updateTreatmentRecordRstRoundsInfo({
        ordNo: this.getOrdNo,
        rstRoundsInfo: new RstRoundInfo(
          // mod #10593 zhangyue start
          this.selectedRoundType? this.selectedRoundType.round_type_cd : null,
          this.selectedRoundType? this.selectedRoundType.round_type_name : null,
          //9724-③　mod  ljx start
          //dateFormat.utc2Jst(new Date()),
          roundDateTime,
          //9724-③　mod  ljx end
          this.accountInfo.userId,
          this.accountInfo.userLastName,
          this.accountInfo.userFirstName,
          this.accountInfo.userId,
          this.accountInfo.userLastName,
          this.accountInfo.userFirstName,
          this.selectedRoundType? this.selectedRoundType.content : null,
          // mod #10593 zhangyue end
          "0",
          null,
          this.selectedRoundType? this.selectedRoundType.posting_class_default : "0",
          this.accountInfo.userId,
          this.accountInfo.userLastName,
          this.accountInfo.userFirstName,
          dateFormat.utc2Jst(new Date()),
          this.accountInfo.userId,
          this.accountInfo.userLastName,
          this.accountInfo.userFirstName,
          dateFormat.utc2Jst(new Date())
        ).toString()
      });
    },
    async onDeleteClick() {
      //10416 治療記録＞回診記録の指示コメント展開バグ zhao start
      const response = await this.getTreatmentRecordAddition(this.getOrdNo);
      this.commentInfo.facilityCd = response.data.facility_cd;
      this.commentInfo.patId = response.data.pat_id;
      this.commentInfo.rstKurCd = response.data.rst_kur_cd;
      this.commentInfo.rstTreatmentCd = response.data.rst_treatment_cd;
      this.commentInfo.treatDate = response.data.treat_date;
      //10416 治療記録＞回診記録の指示コメント展開バグ zhao end
      const deleteRoundsInfo = () => {
        return this.updateTreatmentRecordRstRoundsInfo({
          ordNo: this.getOrdNo,
          rstRoundsInfo: null
        });
      }
      this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "回診記録削除確認",
        title: DIALOG_MESSAGES[13000147].title,
        // message:
        //   "回診記録を削除し、未回診状態にします。<br>削除すると二度と元に戻せません。削除してもよろしいですか？",
        message: messageFormat(DIALOG_MESSAGES[13000147].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: async answer => {
          if (answer === 1) {
            await deleteRoundsInfo();
            //del 10416治療記録＞回診記録の指示コメント展開バグ start zhao
            //await this.deleteIndIndComment();
            //await this.deleteRstIndComment();
            //del 10416治療記録＞回診記録の指示コメント展開バグ start end
            // add 9724 start
            await this.fetchRoundTypes({
              facilityCd: this.getFacilityCd,
              patId: this.selectedPatId,
              selectedPatId: this.selectedPatId
            });
            // add 9724 end

            await this.getRstRoundsInfoAndSaveToStore();
            this.saveRoundType();
            //mod 9724 ljx start
            this.$emit("update");
            //mod 9724 ljx end
          }
        }
      });
    },
    resolveRoundTypeDropdownRoot() {
      const dropdownComponent = this.$refs.roundTypeDropdown;
      const dropdownAnchor = dropdownComponent?.$el || dropdownComponent?.$refs?.root || this.$el?.querySelector(".type-selector");
      return findKendoDropdownRoot(dropdownAnchor) || null;
    },
    resolveRoundTypeDropdownButton() {
      const dropdownRoot = this.resolveRoundTypeDropdownRoot();
      return findKendoDropdownButton(dropdownRoot) || null;
    },
    syncRoundTypeDropdownPresentation() {
      const dropdownRoot = this.resolveRoundTypeDropdownRoot();
      if (!dropdownRoot) {
        return;
      }
      const textNode = findKendoDropdownText(dropdownRoot);
      if (textNode) {
        textNode.style.whiteSpace = "pre-wrap";
        textNode.style.minHeight = "0.8em";
        textNode.style.height = "auto";
        textNode.style.color = "var(--kendo-input-color)";
        textNode.style.backgroundColor = "var(--kendo-input-background-color)";
      }
      const trigger = this.resolveRoundTypeDropdownButton();
      if (trigger) {
        trigger.style.display = this.isNewRoundInfo ? "" : "none";
      }
    },
    // dropDownを開いた時にデータに応じて表示枠を広げる
    addMaxContentStyle(event) {
      this.$nextTick(() => {
        setKendoPopupSurfaceStyles(event, { width: "max-content" }, this.$el);
      });
    },
    //add #10593 NG マージ後，回診記録タイトル値がありません zhangyue start
    async refresh() {
      await this.getRstRoundsInfoAndSaveToStore();
      this.saveRoundType();
      // this.$emit("update");
    }
    //add #10593 NG マージ後，回診記録タイトル値がありません zhangyue end
  },
  async created() {
    // add FNSI-指示者が「医者」以外の場合、回診記録タイトルと回診記録ステータスは非活性 徐 start
    // await this.fetchRoundTypes(this.getFacilityCd);
    await Promise.all([
      this.fetchRoundTypes({
        facilityCd: this.getFacilityCd,
        patId: this.selectedPatId,
        selectedPatId: this.selectedPatId
      }),
      this.checkIsDoctor()
    ]);
    // add FNSI-指示者が「医者」以外の場合、回診記録タイトルと回診記録ステータスは非活性 徐 end
    this.roundTypes = this.roundTypesAtStore;
    // modify start 馬 #9724
    this.roundTypesAtStore_clone = cloneDeep(this.roundTypesAtStore);
    // modify start 馬 #9724
    //add 9724-①　ljx start
    if(this.getOrdNo){
      await this.getRstRoundsInfoAndSaveToStore();
      this.saveRoundType();
    }
    //add 9724-①　ljx end
    //add #10593 NG マージ後，回診記録タイトル値がありません zhangyue start
    EventBus.$on("refresh", this.refresh);
    //add #10593 NG マージ後，回診記録タイトル値がありません zhangyue end
  },
  beforeUnmount() {
    if (this.rstRoundsInfo.inProgress) {
      delete this.rstRoundsInfo.inProgress;
    }
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
    //add #10593 NG マージ後，回診記録タイトル値がありません zhangyue start
    EventBus.$off("refresh", this.refresh);
    //add #10593 NG マージ後，回診記録タイトル値がありません zhangyue end
  },
  mounted() {
    // 初期表示時のstyle補正
    this.$nextTick(() => {
      // CSS指定では適用されない為、要素作成を待ってstyleを付与する
      this.syncRoundTypeDropdownPresentation();
    });
    // modify start 馬 #9724
    if (this.selectedRoundTypeCd == -1 && this.roundTypes[0] != undefined) {
      this.selectedRoundTypeCd = this.roundTypes[0].round_type_cd;
    }
    // modify end 馬 #9724
  }
}
</script>

<style scoped>
.title-and-contents-wrapper {
  display: grid;
  grid-template-columns: 9em;
  width: 9em;
}
.contents-area {
  border: solid 1px gray;
  margin: -8px -2px 0px 1px;
  padding: 7px 5px 1px 1px;
  border-top: none;
  border-radius: 0px 0px 3px 3px;
  width: 7.5em;
}
.type-selector .selectbox {
  width: 100%;
}
ons-select :deep(.select-input) {
  font-size: 1em !important;
  color: var(--treatment-record-text-color);
}
.button {
  width: 8em;
  margin: 1px;
  padding: 2px;
}
.registration-btn-area {
  width: 100%;
}
.registration-btn-area .unregistered-bg-color {
  background-color: var(--btn1-execute-color) !important;
  background-image: none !important;
}
.registration-btn-area .registered-bg-color-0 {
  background-color: #2ca06f !important;
  background-image: none !important;
}
.registration-btn-area .registered-bg-color-1 {
  background-color: #FFA500 !important;
  background-image: none !important;
}
.registration-btn-area .registered-bg-color-2 {
  background-color: #FF3366 !important;
  background-image: none !important;
}
label {
  color: var(--treatment-record-text-color);
}
.green-btn {
  background-image: none !important;
}
.bt3-disabled[disabled] {
  color: #ffffff !important;
  background-color: #4291B9 !important;
  background-image: none !important;
  border-bottom: solid 3px var(--btn-common-border-color) !important;
  box-shadow: unset;
}
.router-link-width {
  width: 9em;
}
</style>
