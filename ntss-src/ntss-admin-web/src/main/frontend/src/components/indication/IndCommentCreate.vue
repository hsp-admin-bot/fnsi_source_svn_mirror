/** * 指示コメント編集 */

<template>
  <v-ons-row>
    <v-ons-row class="instructionNumber">
      <v-ons-col class="title-area">
        <label>指示コメント番号</label>
      </v-ons-col>
      <v-ons-col class="text-area">
        <!-- mod FNSI-指示コメントID入力修正 楊 start -->
        <!--
          <input
          v-model="commentNumber"
          type="number"
          :disabled="editCommentNum"
          min="1"
          max="2147483647"
        />
        -->
        <!--mod FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 start-->
        <!--
        <input
          v-model="commentNumber"
          type="number"
          :disabled="editCommentNum"
          min="1"
          max="2147483647"
          onkeypress='return(/[\d]/.test(String.fromCharCode(event.keyCode)))'
        />
        -->
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <custom-input-number -->
        <!--   ref="commentNumber" -->
        <!--   :value="commentNumber" -->
        <!--   style="width:8%; min-width: 3em; white-space: initial;" -->
        <!--   :digits="10" -->
        <!--   :disabled="editCommentNum" -->
        <!--   :min-value="1" -->
        <!--   :max-value="2147483647" -->
        <!-- /> -->
        <!-- #10777 患者経過総合ビューアでの指示コメント追加時指示コメント番号に101以上の番号が設定可能 linjunfeng start-->
        <!-- <custom-input-number
          ref="commentNumber"
          :value="commentNumber"
          style="width:8%; min-width: 3em; white-space: initial;"
          :digits="10"
          :disabled="editCommentNum || !getItemAuthorized('Indication', 'default_authority')"
          :min-value="1"
          :max-value="2147483647"
        /> -->
        <!-- #11731_【因島：改良】指示コメント番号の指定方法 start -->
        <!-- <custom-input-number-pro
          ref="commentNumber"
          :value="commentNumber.editValue"
          style="width:8%; min-width: 3em; white-space: initial;"
          :disabled="editCommentNum || !getItemAuthorized('Indication', 'default_authority')"
          :min="1"
          :max="99"
          :step="1"
          @handlerInput="(val) =>{ commentNumber.editValue = Number(val) }"
        /> -->
        <!-- #10777 患者経過総合ビューアでの指示コメント追加時指示コメント番号に101以上の番号が設定可能 linjunfeng end-->
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
        <!--mod FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 start-->
        <!-- mod FNSI-指示コメントID入力修正 楊 end -->
        <custom-select
          ref="commentNumber"
          :value="commentNumber"
          :options="commentNumbersSelect"
          class="select-style common-style-input"
          @focusin="focusinCommentNumber()"
          :disabled="editCommentNum || !getItemAuthorized('Indication', 'default_authority')"
        />
        <!-- #11731_【因島：改良】指示コメント番号の指定方法 end -->
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="instructionComment">
      <v-ons-col class="title-area">
        <label>指示コメント</label>
      </v-ons-col>
      <v-ons-col class="text-area">
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <com-textarea -->
        <!--   ref="commentContent" -->
        <!--   class="comTextarea" -->
        <!--   style="min-width: 10em;" -->
        <!--   :content="commentContent" -->
        <!--   cssClass="textarea-custom-text-font comment-textarea-style textarea-resize-vertical" -->
        <!--   :idTextarea="'com-textarea-ind-comment' + getNextIndex()" -->
        <!--   propMaxlength="2048" -->
        <!--   :disabled="editComment" -->
        <!--   @set-content-data="setContentData" -->
        <!-- /> -->
        <com-textarea
          ref="commentContent"
          :class="!editComment ? 'custom-textarea-required' : ''"
          class="comTextarea"
          style="min-width: 10em;"
          :content="commentContent"
          cssClass="textarea-custom-text-font comment-textarea-style textarea-resize-vertical"
          :idTextarea="'com-textarea-ind-comment' + getNextIndex()"
          propMaxlength="2048"
          :disabled="editComment || !getItemAuthorized('Indication', 'default_authority')"
          @set-content-data="setContentData"
        />
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
      </v-ons-col>
    </v-ons-row>
  </v-ons-row>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { ApiHelper } from "@/apis/AxiosHelper";
import { mapActions, mapGetters } from "vuex";
import { EventBus } from "@/eventBus.js";
import CommonTextArea from "@/components/common/CommonTextArea";
// #10777 患者経過総合ビューアでの指示コメント追加時指示コメント番号に101以上の番号が設定可能 linjunfeng start
// add FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 start
// import customInputNumber from "@/components/common/custom-form-tags/CustomInputNumber";
// add FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 end
// mod #11731_【因島：改良】指示コメント番号の指定方法 start
// import CustomInputNumberPro from '@/components/common/custom-form-tags/CustomInputNumberPro'
import CustomSelect from "@/components/common/custom-form-tags/CustomSelect";
// mod #11731_【因島：改良】指示コメント番号の指定方法 end

// #10777 患者経過総合ビューアでの指示コメント追加時指示コメント番号に101以上の番号が設定可能 linjunfeng end
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
// mod #6107 2023/03/22 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/22 メッセージボックス全調整 張博 end
// del #11004 連携イベント発生部分不正 piao start
// import { sendRequestGetCoopIniSchModifySendClass } from "@/apis/treatment-record";
// del #11004 連携イベント発生部分不正 piao end

export default {
  components: {
    "com-textarea": CommonTextArea,
    // #10777 患者経過総合ビューアでの指示コメント追加時指示コメント番号に101以上の番号が設定可能 linjunfeng start
    // add FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 start
    // "custom-input-number": customInputNumber,
    // add FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 end
    // mod #11731_【因島：改良】指示コメント番号の指定方法 start
    // "custom-input-number-pro":CustomInputNumberPro,
    "custom-select": CustomSelect,
    // mod #11731_【因島：改良】指示コメント番号の指定方法 end
    // #10777 患者経過総合ビューアでの指示コメント追加時指示コメント番号に101以上の番号が設定可能 linjunfeng end
  },
  props: {
    // add #10359 編集権限の動作不正 dengshen start
    isMst: {
      type: Boolean,
      default: false
    },
    // add #10359 編集権限の動作不正 dengshen end
    /**
     * 編集するコメント番号
     */
    commentNum: {
      type: Number,
      default: 1
    },

    /**
     * コメント番号編集/不可切替
     * @summary 編集可->false, 編集不可->true
     */
    editCommentNumFlag: {
      type: Boolean,
      default: false
    },

    /**
     * 指示コメント内容
     */
    propsCommentContent: {
      type: String,
      default: null
    }
  },
  data() {
    return {
      // 編集/中止切替
      selectedEdit: 0,
      // 指示コメント内容
      commentContent: {
        initValue: this.propsCommentContent,
        editValue: this.propsCommentContent
      },
      // 指示コメント番号
      // mod FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 start
      //commentNumber: this.commentNum,
      commentNumber: {
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
        // initValue: this.commentNum ? this.commentNum : "1",
        // editValue: this.commentNum ? this.commentNum : "1"
        // mod #11731_【因島：改良】指示コメント番号の指定方法 start
        // initValue: this.commentNum ? this.commentNum : 1,
        // editValue: this.commentNum ? this.commentNum : 1
        // 新規: 0 / 編集: this.commentNum
        // ※新規 0 は、指示コメント番号 1～99 を使い切った場合に 0 のままになり、保存できないようにするため
        initValue: this.commentNum ? this.commentNum : 0,
        editValue: this.commentNum ? this.commentNum : 0
        // mod #11731_【因島：改良】指示コメント番号の指定方法 end
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
      },
      // mod FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 end

      // add #11731_【因島：改良】指示コメント番号の指定方法 start
      // 指定条件下で未使用の指示コメント番号
      unusedCommentNumbers: [],
      // 未使用の指示コメント番号（選択リスト）
      commentNumbersSelect: [{
        value: 0,
        displayValue: null,
      }],
      // add #11731_【因島：改良】指示コメント番号の指定方法 end

      textAreaIdIndex: 0,
      // del #11004 連携イベント発生部分不正 piao start
      // objModSendClass: "",
      // del #11004 連携イベント発生部分不正 piao end
      // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 start
      oldOrdMainList: [],
      // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 end
      // #6100 患者経過総合ビューア(計画)_指示コメント:選択「編集維持」時 start
      // del #11731_【因島：改良】指示コメント番号の指定方法 start
      // dataObjectArr: []
      // del #11731_【因島：改良】指示コメント番号の指定方法 end
      // #6100 患者経過総合ビューア(計画)_指示コメント:選択「編集維持」時 end
    };
  },

  computed: {
    //施設コード取得用
    ...mapGetters("user", ["getFacilityCd"]),
    // mod FNSI-連携イベントの登録適正化 楊 start
    ...mapGetters("pat-viewer-modal", { settingIndData: "getSettingIndData" }),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("pat-info", ["selectedPat"]),
    // mod FNSI-連携イベントの登録適正化 楊 end
    /**
     * 指示コメント番号編集 可/不可切替
     */
    editCommentNum() {
      return this.editCommentNumFlag;
    },

    /**
     * 指示コメント編集 可/不可切替
     */
    editComment() {
      if (0 === this.selectedEdit) {
        return false;
      } else {
        return true;
      }
    },

    /**
     * 指示コメント編集内容
     */
    editedComment() {
      return {
        // mod FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 start
        // no: parseInt(this.commentNumber) || null,
        no: parseInt(this.commentNumber.editValue) || null,
        // mod FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 end
        content: this.commentContent.editValue
      };
    }
  },

  watch: {
    editedComment(data) {
      this.$emit("input", data);
    },
    // del #11731_【因島：改良】指示コメント番号の指定方法 start
    // commentNumber(data) {
    //   // mod FNSI-指示コメントID入力修正 楊 start
    //   // // 最小値の設定
    //   // this.commentNumber = data > 0 ? data : 1;
    //   // // 最大値の設定
    //   // this.commentNumber = 2147483647 > data ? data : 2147483647;
    //   if (data === "") {
    //     return;
    //   }
    //   // 最小値の設定
    //   data = data > 0 ? data : 1;
    //   // 最大値の設定
    //   // mod FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 start
    //   // this.commentNumber = 2147483647 > data ? data : 2147483647;
    //   this.commentNumber.editValue = 2147483647 > data ? data : 2147483647;
    //   // mod FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 end
    //   // mod FNSI-指示コメントID入力修正 楊 end
    // }
    // del #11731_【因島：改良】指示コメント番号の指定方法 end
  },

  mounted() {
    // add #11731_【因島：改良】指示コメント番号の指定方法 start
    this.initializeUnusedCommentNumbers();
    // add #11731_【因島：改良】指示コメント番号の指定方法 end
  },
  methods: {
    ...mapActions('loading-screen', [
      "startLoadingScreen",
      "finishLoadingScreen"
    ]),
    ...mapActions("pat-viewer", ["setTreatBaseDate"]),
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return this.isMst || (this.isMst != true && getAuthorized(pageCd, itemCd));
    },
    // add #10359 編集権限の動作不正 dengshen end
    /**
     * 編集/中止切替
     */
    selectSegment(edit) {
      this.selectedEdit = Number(edit);
      // 初期データに戻す処理
      this.commentContent.editValue = this.propsCommentContent;
    },

    // add #11731_【因島：改良】指示コメント番号の指定方法 start
    // 未使用の指示コメント番号を選択する
    async initializeUnusedCommentNumbers() {
      // 患者経過総合ビューアの指示コメント新規追加の場合
      if (!this.isMst && !this.commentNum) {
        await this.setUnusedCommentNumbers();
        this.setUnusedCommentNumbersSelect();
        // 未使用の指示コメント番号がある
        if (this.commentNumbersSelect.length) {
          // 未使用の指示コメント番号の最初の番号を選択リストから選択する
          this.commentNumber = {
            initValue: this.commentNumbersSelect[0].value,
            editValue: this.commentNumbersSelect[0].value
          }
        }
      } else {
        // 編集時の指示コメント番号を設定する
        this.commentNumber = {
          initValue: this.commentNum,
          editValue: this.commentNum
        }
        // 患者経過総合ビューアの指示コメント・編集である場合
        if (!this.isMst) {
          // 編集時の指示コメント番号を選択リストに設定する（表示用）
          this.commentNumbersSelect = [{
            value: this.commentNum,
            displayValue: String(this.commentNum)
          }];
        }
        // マスタ編集(治療方法セットマスタ)の指示コメントの追加・編集である場合
        else {
          this.unusedCommentNumbers = this.validRangeCommentNumbers();
          this.setUnusedCommentNumbersSelect();
        }
      }
    },
    // 指示コメント選択リストIFを操作した契機で使用済みの指示コメント番号を取得する
    // ※指示コメント選択リストIFを開いた場合（フォーカスイン）
    async focusinCommentNumber(){
      // 患者経過総合ビューアの指示コメント・編集である場合
      if (!this.isMst) {
        await this.setUnusedCommentNumbers();
        this.setUnusedCommentNumbersSelect();
      }
    },
    // add #11731_【因島：改良】指示コメント番号の指定方法 end

    // del #11004 連携イベント発生部分不正 piao start
    // /**
    //  * @description MODIFY_SEND_CLASS取得
    //  */
    // async getSchModifySendClass() {
    //   let retVal = 0;
    //   const prmfacilityCd = this.getFacilityCd;
    //   this.objModSendClass = sendRequestGetCoopIniSchModifySendClass(prmfacilityCd);
    //
    //   try {
    //     const response = await this.objModSendClass;
    //     retVal = response.data;
    //   } catch (error) {
    //     retVal = 0;
    //   }
    //   return retVal;
    // },
    // del #11004 連携イベント発生部分不正 piao end

    /**
     * データの更新
     */
    async updateIndInfo(structData) {
      // 保存時編集チェック
      if (this.checkEdit(0)) {
        // 処理終了
        return;
      }
      // del #11731_【因島：改良】指示コメント番号の指定方法 (不用なログ) start
      // console.log("IndCommentCreate.vue updateIndInfo this.startLoadingScreen();");
      // del #11731_【因島：改良】指示コメント番号の指定方法 end
      this.startLoadingScreen();

      let stringParam = null;
      let messageCd = 0;
      // mod #11731_【因島：改良】指示コメント番号の指定方法 start
      // mod FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 start
      // if (!this.commentNumber) {
      if (!this.commentNumber.editValue) {
      // mod FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 end
        messageCd = 22010001;
        stringParam = "指示コメント番号";
      }
      // 新規作成時の場合
      else if (!this.commentNum) {
        // 未使用の指示コメント番号を再取得する
        await this.setUnusedCommentNumbers();
        // 指定条件下で除外番号が選択されている場合
        if (this.isUsedCommentNumberSelected()){
          messageCd = 12000347;
          stringParam = "";
        }
      }
      // mod #11731_【因島：改良】指示コメント番号の指定方法 end

      // mod #11731_【因島：改良】指示コメント番号の指定方法 start
      // if (stringParam) {
      if (messageCd && stringParam != null) {
        this.$parent.$parent.messageDialogInfo.messageCd = messageCd;
        this.$parent.$parent.messageDialogInfo.type = "1";
        this.$parent.$parent.messageDialogInfo.stringParams = [stringParam];
        this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
        // del #11731_【因島：改良】指示コメント番号の指定方法 (不用なログ) 
        // console.log("IndCommentCreate.vue updateIndInfo return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return;
      }
      // mod #11731_【因島：改良】指示コメント番号の指定方法 end

      const sendJson = {};
      // 指示コメントフラグ(1->新規登録、2->編集、3->中止)
      sendJson.comment_flag = structData.flag;
      // 患者ID
      sendJson.pat_id = structData.patId;
      // 施設コード
      sendJson.facility_cd = structData.facilityCd;
      // 治療開始日
      sendJson.start_date = structData.indStartDate;
      // 治療終了日
      sendJson.end_date = structData.indEndDate;
      // 指示コメント番号
      // mod FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 start
      // sendJson.num_comment = this.commentNumber;
      sendJson.num_comment = this.commentNumber.editValue;
      // mod FNSI-画面デザイン【患者経過総合ビューア.xlsx】ラジオボタン対応 韓 end
      // 指示コメント内容
      sendJson.comment = this.commentContent.editValue;
      // 変更前指示コメント内容
      sendJson.init_comment = this.commentContent.editValue;
      // 登録・編集対象曜日
      sendJson.weeks = JSON.stringify(structData.indWeeks);
      // 登録・編集対象クール
      sendJson.ind_kur_cd = JSON.stringify(structData.selectedKur);
      // 登録・編集対象治療方法
      sendJson.ind_treatment_cd = JSON.stringify(structData.selectedTreat);
      // 指示者
      sendJson.ind_user_id = structData.indUser;
      // 更新者
      sendJson.upd_user_id = structData.updUser;
      // 終了日格納有無
      sendJson.is_deadline = structData.isDeadline;

      // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 start
      sendJson.is_rst_update = false;

      // mod FNSI-指示編集でDB登録データの更新 楊 start
      // 指示者ドロップダウンの設定
      let doctorList = structData.userOptions;
      const doctor = doctorList.find(doctor => doctor.user_id === Number(structData.indUser));
      // 指示者
      sendJson.ind_user_last_name = doctor.user_last_name;
      // 更新者
      sendJson.ind_user_first_name = doctor.user_first_name;
      // mod FNSI-指示編集でDB登録データの更新 楊 end

      // 古いリスト
      const startDate = structData.indStartDate.replace(/-/g, '');
      const endDate = structData.indEndDate == null ? null : structData.indEndDate.replace(/-/g, '');
      const searchData = await ApiHelper.get(
        `/mainData/getByPatIdAndTreatDate/${structData.facilityCd}/${structData.patId}/${startDate}/${endDate}`
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndCommentCreate.vue', 'updateIndInfo', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        // del #11731_【因島：改良】指示コメント番号の指定方法 (不用なログ) start
        // console.log("IndCommentCreate.vue updateIndInfo throw error; this.finishLoadingScreen();");
        // del #11731_【因島：改良】指示コメント番号の指定方法 end
        this.finishLoadingScreen();
        throw error;
      });
      this.oldOrdMainList = searchData.data;

      let weekList = [];
      structData.indWeeks.forEach(eleItem => {
        if (eleItem.done === true) {
          weekList.push(parseInt(eleItem.value));
        }
      });

      if (this.oldOrdMainList) {
        // 実績があるフラグ
        let isRstHave = false;


        this.oldOrdMainList.forEach(item => {
            const isSelectedTreat = structData.selectedTreat.length > 0 ? structData.selectedTreat.includes(parseInt(item.indTreatmentCd)) : true;
            const isSelectedKur = structData.selectedKur.length > 0 ? structData.selectedKur.includes(parseInt(item.indKurCd)) : true;
            const isTreatWeek = weekList.length > 0 ? weekList.includes(parseInt(item.treatWeek)) : true;
          if(item.rstDialysisState !=="0" && isSelectedTreat && isSelectedKur && isTreatWeek) {
            isRstHave = true;
          }
        });
        //mod 7114 治療中の透析指示の投与薬剤、医療材料、指示コメント削除を実施した場合の注意メッセージがない 張 start
        // if (isRstHave && (structData.flag === 1 || structData.flag === 2)) {
        if (isRstHave && (structData.flag === 1 || structData.flag === 2|| structData.flag === 3)) {
          //mod 7114 治療中の透析指示の投与薬剤、医療材料、指示コメント削除を実施した場合の注意メッセージがない 張 end
          //mod #10266 start
          // if (await this.showUpdateCheckDialog()) {
          if (this.settingIndData.update_flag != "2" && await this.showUpdateCheckDialog()) {
            //mod #10266 end
            sendJson.is_rst_update = true;
            // add キャンセル（実績に反映しない）を選択　⇒　実績に反映される修正  xmj 2022-08-11 start
          }else{
            sendJson.is_rst_update = false;
          }
          // add キャンセル（実績に反映しない）を選択　⇒　実績に反映される修正  xmj 2022-08-11 end
        }

      }
      // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 end

      // add FNSI-患者経過総合ビューア_修正内容1.xlsx 対応 李 start
      // 発生元区分(1:患者経過総合ビューア)
      sendJson.genDifferentiation = '1';
      sendJson.hosp_pat_id = this.selectedPat.pat_personal_main.hosp_pat_id;
      sendJson.user_id = this.getStateUserAccountInfo.userId;

      //add #10266 start
      sendJson.update_flag = this.settingIndData.update_flag
      //add #10266 end

      // add FNSI-患者経過総合ビューア_修正内容1.xlsx 対応 李 end
      // mod 10553 指示コメント編集連携送信 関  start
      // let modSendClass = await this.getSchModifySendClass();
      //データの送信
      const response = await ApiHelper.post("/mainData/updateIndComment/", sendJson).catch(
        error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('IndCommentCreate.vue', 'updateIndInfo', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          // del #11731_【因島：改良】指示コメント番号の指定方法 (不用なログ) start
          // console.log("IndCommentCreate.vue updateIndInfo throw error; this.finishLoadingScreen();");
          // del #11731_【因島：改良】指示コメント番号の指定方法 end
          this.finishLoadingScreen();
          throw error;
        }
      )

      // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
      if (200 === response.status && 22020004 === response.data.msgCd) {
        this.$parent.$parent.messageDialogInfo.messageCd = response.data.msgCd;
        this.$parent.$parent.messageDialogInfo.type = "1";
        this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
        console.log("IndCommentCreate.vue updateIndInfo return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return;
      }
      // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start

      // add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou start
      // .then(() => {
      //     let JournalList = [];
      //     if (this.settingIndData.ordNo) {
      //       // 変更対象クールが未登録ではないの場合、外部連携APIを呼び出す
      //       if (this.oldOrdMainList[0].indKurCd !== null && this.oldOrdMainList[0].indKurCd !== 0) {
      //         if ( modSendClass == 2 ) {
      //           //MODIFY_SEND_CLASS=2 削除,新規
      //           JournalList.push({
      //             ope_cd: "004029",
      //             crud: "D",
      //             facility_cd: structData.facilityCd,
      //             hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //             pat_id: structData.patId,
      //             ord_no: this.settingIndData.ordNo,
      //             base_date: this.oldOrdMainList[0].treatDate,
      //             user_id: this.getStateUserAccountInfo.userId
      //           });
      //           JournalList.push({
      //             ope_cd: "004029",
      //             crud: "C",
      //             facility_cd: structData.facilityCd,
      //             hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //             pat_id: structData.patId,
      //             ord_no: this.settingIndData.ordNo,
      //             base_date: this.oldOrdMainList[0].treatDate,
      //             user_id: this.getStateUserAccountInfo.userId
      //           });
      //           createJournalList(JournalList);
      //         } else {
      //           //MODIFY_SEND_CLASS=0 or 1 更新
      //           JournalList.push({
      //             ope_cd: "004029",
      //             crud: "U",
      //             facility_cd: structData.facilityCd,
      //             hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //             pat_id: structData.patId,
      //             ord_no: this.settingIndData.ordNo,
      //             base_date: this.oldOrdMainList[0].treatDate,
      //             user_id: this.getStateUserAccountInfo.userId
      //           });
      //           createJournalList(JournalList);
      //         }
      //       }
      //     } else {
      //       if (this.oldOrdMainList) {
      //         this.oldOrdMainList.forEach(item => {
      //           const isSelectedTreat = structData.selectedTreat.includes(item.indTreatmentCd);
      //           const isSelectedKur = structData.selectedKur.includes(item.indKurCd);
      //           if (structData.selectedKur.length > 0) {
      //             if (isSelectedKur) {
      //               if (item.indKurCd !== null && item.indKurCd !== 0) {
      //                 if ( modSendClass == 2 ) {
      //                   //MODIFY_SEND_CLASS=2 削除、新規
      //                   JournalList.push({
      //                     ope_cd: "004029",
      //                     crud: "D",
      //                     facility_cd: structData.facilityCd,
      //                     hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //                     pat_id: structData.patId,
      //                     ord_no: item.ordNo,
      //                     base_date: item.treatDate,
      //                     user_id: this.getStateUserAccountInfo.userId
      //                   });
      //                   JournalList.push({
      //                     ope_cd: "004029",
      //                     crud: "C",
      //                     facility_cd: structData.facilityCd,
      //                     hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //                     pat_id: structData.patId,
      //                     ord_no: item.ordNo,
      //                     base_date: item.treatDate,
      //                     user_id: this.getStateUserAccountInfo.userId
      //                   });
      //                 } else {
      //                   //MODIFY_SEND_CLASS=0 or 1 更新
      //                   JournalList.push({
      //                     ope_cd: "004029",
      //                     crud: "U",
      //                     facility_cd: structData.facilityCd,
      //                     hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //                     pat_id: structData.patId,
      //                     ord_no: item.ordNo,
      //                     base_date: item.treatDate,
      //                     user_id: this.getStateUserAccountInfo.userId
      //                   });
      //                 }
      //               }
      //             }
      //           } else {
      //             if (structData.selectedTreat.length > 0) {
      //               if (isSelectedTreat) {
      //                 if (item.indKurCd !== null && item.indKurCd !== 0) {
      //                   if ( modSendClass == 2 ) {
      //                     //MODIFY_SEND_CLASS=2 削除、新規
      //                     JournalList.push({
      //                       ope_cd: "004029",
      //                       crud: "D",
      //                       facility_cd: structData.facilityCd,
      //                       hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //                       pat_id: structData.patId,
      //                       ord_no: item.ordNo,
      //                       base_date: item.treatDate,
      //                       user_id: this.getStateUserAccountInfo.userId
      //                     });
      //                     JournalList.push({
      //                       ope_cd: "004029",
      //                       crud: "C",
      //                       facility_cd: structData.facilityCd,
      //                       hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //                       pat_id: structData.patId,
      //                       ord_no: item.ordNo,
      //                       base_date: item.treatDate,
      //                       user_id: this.getStateUserAccountInfo.userId
      //                     });
      //                   } else {
      //                     //MODIFY_SEND_CLASS=0 or 1 更新
      //                     JournalList.push({
      //                       ope_cd: "004029",
      //                       crud: "U",
      //                       facility_cd: structData.facilityCd,
      //                       hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //                       pat_id: structData.patId,
      //                       ord_no: item.ordNo,
      //                       base_date: item.treatDate,
      //                       user_id: this.getStateUserAccountInfo.userId
      //                     });
      //                   }
      //                 }
      //               }
      //             } else {
      //               if (item.indKurCd !== null && item.indKurCd !== 0) {
      //                 if ( modSendClass == 2 ) {
      //                   //MODIFY_SEND_CLASS=2 削除、新規
      //                   JournalList.push({
      //                     ope_cd: "004029",
      //                     crud: "D",
      //                     facility_cd: structData.facilityCd,
      //                     hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //                     pat_id: structData.patId,
      //                     ord_no: item.ordNo,
      //                     base_date: item.treatDate,
      //                     user_id: this.getStateUserAccountInfo.userId
      //                   });
      //                   JournalList.push({
      //                     ope_cd: "004029",
      //                     crud: "C",
      //                     facility_cd: structData.facilityCd,
      //                     hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //                     pat_id: structData.patId,
      //                     ord_no: item.ordNo,
      //                     base_date: item.treatDate,
      //                     user_id: this.getStateUserAccountInfo.userId
      //                   });
      //                 } else {
      //                   //MODIFY_SEND_CLASS=0 or 1 更新
      //                   JournalList.push({
      //                     ope_cd: "004029",
      //                     crud: "U",
      //                     facility_cd: structData.facilityCd,
      //                     hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //                     pat_id: structData.patId,
      //                     ord_no: item.ordNo,
      //                     base_date: item.treatDate,
      //                     user_id: this.getStateUserAccountInfo.userId
      //                   });
      //                 }
      //               }
      //             }
      //           }
      //         });
      //         createJournalList(JournalList);
      //       }
      //     }
      //   });
      // mod 10553 指示コメント編集連携送信 関  end
       // add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou end
      // mod FNSI-連携イベントの登録適正化 楊 start
      // const params = {
      //   ope_cd: "004029",
      //   crud: "U",
      //   facility_cd: structData.facilityCd,
      //   hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //   pat_id: structData.patId,
      //   ord_no: this.settingIndData.ordNo,
      //   base_date: "",
      //   user_id: this.getStateUserAccountInfo.userId
      // };
      // if (this.settingIndData.ordNo) {
      //   // 変更対象クールが未登録ではないの場合、外部連携APIを呼び出す
      //   if (this.oldOrdMainList[0].indKurCd !== null && this.oldOrdMainList[0].indKurCd !== 0) {
      //     createJournal({...params, base_date: this.oldOrdMainList[0].treatDate});
      //   }
      // } else {
      //   if (this.oldOrdMainList) {
      //     this.oldOrdMainList.forEach(item => {
      //       const isSelectedTreat = structData.selectedTreat.includes(item.indTreatmentCd);
      //       const isSelectedKur = structData.selectedKur.includes(item.indKurCd);
      //       if (structData.selectedKur.length > 0) {
      //         if (isSelectedKur) {
      //           if (item.indKurCd !== null && item.indKurCd !== 0) {
      //             createJournal({...params, ord_no: item.ordNo, base_date: item.treatDate});
      //           }
      //         }
      //       } else {
      //         if (structData.selectedTreat.length > 0) {
      //           if (isSelectedTreat) {
      //             if (item.indKurCd !== null && item.indKurCd !== 0) {
      //               createJournal({...params, ord_no: item.ordNo, base_date: item.treatDate});
      //             }
      //           }
      //         } else {
      //           if (item.indKurCd !== null && item.indKurCd !== 0) {
      //             createJournal({...params, ord_no: item.ordNo, base_date: item.treatDate});
      //           }
      //         }
      //       }
      //     });
      //   }
      // }
      // mod FNSI-連携イベントの登録適正化 楊 end
      EventBus.$emit("isRefresh");
      // del #11731_【因島：改良】指示コメント番号の指定方法 (不用なログ) start
      // console.log("IndCommentCreate.vue updateIndInfo hide-modal this.finishLoadingScreen();");
      // del #11731_【因島：改良】指示コメント番号の指定方法 end
      this.finishLoadingScreen();
      // モーダルを閉じる
      this.$parent.$parent.$emit("hide-modal");
    },

    // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 start
    // 条件送信以降の場合、実績の変更をするか確認する。
    async showUpdateCheckDialog() {
        let rtn = false;
        await this.$ons.notification.confirm({
           // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
          // title: "",
          title: DIALOG_MESSAGES[13000050].title,
          // message: "条件送信済みまたは治療中、治療終了後の指示を変更しました。<br>" +
          //          "実績データへの反映をしますか？",
          message: messageFormat(DIALOG_MESSAGES[13000050].message),
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer === 1) {
              rtn = true;
              // add キャンセル（実績に反映しない）を選択　⇒　実績に反映される修正  xmj 2022-08-11 start
            }else{
              rtn = false;
            }
            // add キャンセル（実績に反映しない）を選択　⇒　実績に反映される修正  xmj 2022-08-11 end
          }
        });
        return rtn;
    },
    // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 end

    /**
     * 変更チェック
     * @description 指示コメントの編集内容に応じてメッセージを出す
     * @param num 0->保存ボタンクリック時 1->キャンセルボタンクリック時
     * @return showMessage trueを返した場合呼び出し元で処理を終了する
     */
    checkEdit(num) {
      // 中止選択中の場合はチェック処理を行わない
      if (1 === this.selectedEdit) {
        return;
      }

      // メッセージ表示、非表示切り替え
      let showMessage = false;
      // メッセージコード
      let messageCd = null;
      // メッセージタイプ
      let messageType = null;

      // 初期値と編集値に相違無し
      if (this.commentContent.initValue === this.commentContent.editValue) {
        // 保存時チェックならメッセージ表示
        if (0 === num && !this.commentContent.editValue) {
          showMessage = true;
          messageCd = 22010001;
          messageType = "1";
          this.$parent.$parent.messageDialogInfo.title = DIALOG_MESSAGES[22010001].title;
          this.$parent.$parent.messageDialogInfo.stringParams = ["指示コメント"]
        }
      } else {
        // キャンセル時チェックならメッセージ表示
        if (1 === num) {
          showMessage = true;
          messageCd = 20010001;
          messageType = "2";
        }
        // add #10266 編集の場合は、指示内容に空でないヒントを追加します。linjunfeng start
        if (0 === num && !this.commentContent.editValue) {
          showMessage = true;
          messageCd = 22010001;
          messageType = "1";
          this.$parent.$parent.messageDialogInfo.title = DIALOG_MESSAGES[22010001].title;
          this.$parent.$parent.messageDialogInfo.stringParams = ["指示コメント"]
        }
        // add #10266 編集の場合は、指示内容に空でないヒントを追加します。linjunfeng end
      }
      this.$parent.$parent.messageDialogInfo.messageCd = messageCd;
      this.$parent.$parent.messageDialogInfo.type = messageType;
      this.$parent.$parent.messageDialogInfo.isDialogVisible = showMessage;
      return showMessage;
    },

    getNextIndex() {
      const element = document.getElementById("com-textarea-ind-comment" + this.textAreaIdIndex);
      if (element) {
        this.textAreaIdIndex = this.textAreaIdIndex + 1;
      }
      return this.textAreaIdIndex;
    },
    setContentData(newValue) {
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
      // this.commentContent.editValue = newValue;
      this.commentContent.editValue = newValue === '' ? null : newValue;
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
    },

    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
    isEdit() {
      const treatCondItems = this.$refs;
      let editCount = 0;
      Object.keys(treatCondItems).filter(key =>{
        // 指示コメント番号は変更箇所対象から除く
        return key !== 'commentNumber'
      }).forEach(key => {
        if ((treatCondItems[key] && treatCondItems[key].isEdited)
          || (treatCondItems[key][0] && treatCondItems[key][0].isEdited)) {

          // 変更箇所数格納
          editCount += 1;
        }
      });
      if (0 === editCount) {
        return false;
      }
      return true;
    },
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end

    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
    async resetComponentIndData(structData){
      if (this.isEdit()) {
        this.$parent.$parent.messageDialogInfo.messageCd = 70000028;
        /* mod FNSI-4212 更新対象変更時のウインドウが不正 liumx start */
        this.$parent.$parent.messageDialogInfo.type = "9";
        /* mod FNSI-4212 更新対象変更時のウインドウが不正 liumx end */
        this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
        return;
      }
      // #10196 指示コメントが複数ある場合に過去日を選択すると強制的に指示コメント１が選択状態となる。 linjunfeng start
      // else {
      //   this.getComponentData(structData,2);
      // }
      // #10196 指示コメントが複数ある場合に過去日を選択すると強制的に指示コメント１が選択状態となる。 linjunfeng end
      // #10266 開始日をに変更したが 指定した日付の指示コメントの内容が表示されていない　linjunfeng start
      else {
        this.getComponentData(structData,2);
      }
      // #10266 開始日をに変更したが 指定した日付の指示コメントの内容が表示されていない　linjunfeng end
    },
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end

    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
    async getComponentData(structData,answer) {
      //del FNSI-5639 劉全航 start
      // let indInfo = [];
      //del FNSI-5639 劉全航 end
      if (answer === 1) {
        return;
      }/*  else if (answer === 3) {
        //del FNSI-5639 劉全航 start
        // const treatCondItems = this.$refs;

        // Object.keys(treatCondItems).forEach(key => {
        //   //mod FNSI-改修内容 redmine 4880 4882 劉祥霖 start
        //   // if (treatCondItems[key] && (treatCondItems[key].initValue !== treatCondItems[key].editValue)) {
        //   //mod FNSI-改修内容 redmine 4880 4882 劉祥霖 end
        //   if (treatCondItems[key] && (treatCondItems[key].initValue !== treatCondItems[key].editValue)) {
        //     let value = treatCondItems[key].editValue ? treatCondItems[key].editValue : "";
        //     let item = "{\"" + key + "\":\"" + value + "\"}";
        //     indInfo.push(JSON.parse(item));
        //   }
        // });
        //del FNSI-5639 劉全航 end
      } */

      // del #11731_【因島：改良】指示コメント番号の指定方法 start（仕様：条件指定を変更した場合に、指示コメント番号を変更しない）
      let indWeeks = [
        {
          text: "全",
          done: true,
          value: 0
        },
        {
          text: "月",
          done: true,
          value: 1
        },
        {
          text: "火",
          done: true,
          value: 2
        },
        {
          text: "水",
          done: true,
          value: 3
        },
        {
          text: "木",
          done: true,
          value: 4
        },
        {
          text: "金",
          done: true,
          value: 5
        },
        {
          text: "土",
          done: true,
          value: 6
        },
        {
          text: "日",
          done: true,
          value: 7
        }
      ];
      const paramJson = {};
      // 施設情報
      paramJson.facility_cd = structData.facilityCd;
      // 患者情報
      paramJson.pat_id = structData.patId;
      // 治療開始日時
      paramJson.start_date = structData.indStartDate;
      // 治療終了日時
      paramJson.end_date = "";
      // クール
      paramJson.ind_kur_cd = JSON.stringify(structData.selectedKur);
      // 治療方法
      paramJson.ind_treatment_cd = JSON.stringify(structData.selectedTreat);
      // 曜日パターン
      paramJson.weeks = JSON.stringify(indWeeks);

      // 対象日時の治療情報取得(開始日付・治療方法・クールで絞り込み)
      let response = await ApiHelper.post(
        "/mainData/getOrdMainDataInfo",
        paramJson
      ).catch(error => {
        getErrorMessage('IndActionChart.vue', 'resetComponentData', error);
        throw error;
      });
      let ordMainData = response.data;
      if(ordMainData && ordMainData.length > 0) {
        ordMainData = ordMainData[0];
      } else {
        return;
      }

      // 最新の検索結果すべてを画面に設定する
      const dataObject  = ordMainData ? JSON.parse(ordMainData.indIndCommentInfo) : null;
      // add #10266 開始日をに変更したが 指定した日付の指示コメントの内容が表示されていない　linjunfeng start
      let dataObjectResult = dataObject.find(item => item.no == this.commentNum);
      if (dataObjectResult) {
        this.commentContent.initValue = dataObjectResult.content ? dataObject[0].content : "";
        if (answer == 2) {
          this.commentContent.editValue = dataObjectResult.content ? dataObject[0].content : "";
        }
      }
      // del #11731_【因島：改良】指示コメント番号の指定方法 end
    },
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end

    // add #11731_【因島：改良】指示コメント番号の指定方法 start
    // 1～99の有効な指示コメント番号
    validRangeCommentNumbers() {
      return [...Array(99).keys()].map(no => ++no);
    },
    /**
     * 未使用の指示コメント番号リストを作成する
     * ※条件指定を変更した場合に指示コメント番号を変更しないため、未使用の指示コメント番号リストのみ作成する。
     */
    async setUnusedCommentNumbers() {
      // 使用済みの指示コメント番号配列
      const usedCommentNumbers = await this.getUsedCommentNo(this.$parent.$parent.structData);

      // 1～99の番号から使用済み指示コメント番号を除外する
      this.unusedCommentNumbers = this.validRangeCommentNumbers().filter(no => !usedCommentNumbers.includes(no));
    },
    // 指示コメント番号の選択リストを設定する
    setUnusedCommentNumbersSelect() {
      // 未使用の指示コメント番号配列を選択リストに設定する
      this.commentNumbersSelect = this.unusedCommentNumbers.map( no => ({
          value: no,
          displayValue: String(no)
        }));
      if (this.isUsedCommentNumberSelected()){
        if (this.commentNumbersSelect.length) {
          // リストを出しつつ未使用の若い番号に強制変更をしておく。
          this.commentNumber.editValue = this.commentNumbersSelect[0].value;
        }
      }
    },
    // 指定条件下で除外番号が選択されているか
    isUsedCommentNumberSelected() {
      // 選択した指示コメント番号が、指定条件下で未使用の指示コメント番号の中に存在しない
      return !this.unusedCommentNumbers.includes(this.commentNumber.editValue);
    },
    /**
     * 指示コメント情報と患者治療パターンを指定条件で検索して使用済みの指示コメント番号を返す
     * @param structData 指定条件
     * @return 指示コメント番号配列
     */ 
    async getUsedCommentNo(structData) {
      // 検索条件
      const paramJson = {
        facility_cd: structData.facilityCd,  // 施設情報
        pat_id: structData.patId,  // 患者情報
        start_date: structData.indStartDate, // 治療開始日時
        end_date: structData.indEndDate, // 治療終了日時
        ind_kur_cd: JSON.stringify(structData.selectedKur),  // クール
        ind_treatment_cd: JSON.stringify(structData.selectedTreat),  // 治療方法
        weeks: JSON.stringify(structData.indWeeks)  // 曜日パターン
      }
      // 対象期間の治療情報の指示コメント情報を取得(開始日～終了日・曜日・治療方法・クールで絞り込み)
      const mdResponse = await ApiHelper.post(
        "/mainData/getIndIndCommentInfo",
        paramJson
      ).catch(error => {
        getErrorMessage('IndCommentCreate.vue', 'getUsedCommentNo', error);
        throw error;
      });
      let ptpResponse = null;
      // 終了日が指定されていない場合（無期限）無期限の場合は患者治療パターンも参照する
      if (!structData.indEndDate) {
        // 開始日・終了日は不用
        delete paramJson.start_date;
        delete paramJson.end_date;
        // 患者治療パターンの指示コメント情報を取得(曜日・治療方法・クールで絞り込み)
        ptpResponse = await ApiHelper.post(
          "/mainData/getPatTreatmentPattern/IndIndCommentInfo",
          paramJson
        ).catch(error => {
          getErrorMessage('IndCommentCreate.vue', 'getUsedCommentNo', error);
          throw error;
        });
      }

      let mdCommentNumbers = [];   // 治療情報の指示コメント番号配列
      let ptpCommentNumbers = [];  // 患者治療パターンの指示コメント番号配列
      if (mdResponse && mdResponse.data && mdResponse.data.length) {
        mdCommentNumbers = mdResponse.data.map(md => JSON.parse(md.indIndCommentInfo).no);
      }
      if (ptpResponse && ptpResponse.data && ptpResponse.data.length) {
        ptpCommentNumbers = ptpResponse.data.map(ptp => JSON.parse(ptp.indIndCommentInfo).no);
      }
      // 使用済みの指示コメント番号配列を作成（すべての要素を結合し、重複する番号は1つに集約してソートする）
      const usedCommentNumbers = [...new Set([...mdCommentNumbers, ...ptpCommentNumbers])].sort((a, b) => a - b);
      return usedCommentNumbers;
    },
    // add #11731_【因島：改良】指示コメント番号の指定方法 end
  },

  //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
  async created() {
    this.$parent.$parent.isDialogType9 = true;
  }
  //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end
};
</script>

/** * スタイル定義 /*
<style scoped>
/* 指示コメント番号 */
/* mod #11731_【因島：改良】指示コメント番号の指定方法（スペルミス） */
.instructionNumber {
  margin: 15px 0;
  justify-content: center;
  align-items: center;
}

/* 指示コメントテキスト */
/* mod #11731_【因島：改良】指示コメント番号の指定方法（スペルミス） */
.instructionComment {
  margin-bottom: 15px;
}

.select-style {
  width: 8%;
  min-width: 3em;
}

.title-area {
  /* add FNSI-薬剤指示画面等の画面崩れの修正 楊 start */
  /*flex: 0 0 30%;*/
  flex: 0 0 10em;
  /* add FNSI-薬剤指示画面等の画面崩れの修正 楊 end */
}

div >>> .comment-textarea-style {
  height: 2.5em;
}

.custom-textarea-required >>> textarea {
  background-color: #ffff99;
}
</style>
