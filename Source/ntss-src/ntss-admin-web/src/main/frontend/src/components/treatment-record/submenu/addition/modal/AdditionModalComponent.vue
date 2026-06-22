/**
 * 治療記録の子機能 指示コメント（新規・編集）
 */
<template>
  <modal-base @onClose="onClickCancel">
    <template #body>
      <div style="height: 100%;">
      <div class="expandable-content custom-expandable-content" style="height: calc(100% - 2em); display: flex; flex-flow: column;">
        <v-ons-row class="comment-no" style="height: unset;">
          <v-ons-col class="title" width="10em">
            <label class="theme">指示コメント番号</label>
          </v-ons-col>
          <v-ons-col>
            <label v-if="!isNew()" class="theme">{{ this.getTargetNo() }}</label>
            <v-ons-select v-if="isNew()" v-model="selectedNo">
              <option v-for="(no, index) in this.getUnusedCommentNoList()" :key="index" :value="no">{{ no }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row style="height: unset;">
          <v-ons-col class="title">
            <label class="theme">指示コメント</label>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row style="height: unset;">
          <v-ons-col class="title">
            <label>2048文字まで入力可能</label>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="addition-modal-com-textarea" style="height: unset;">
          <v-ons-col>
            <com-textarea
              class="com-textarea"
              :content="{
              initValue: initialComment,
              editValue: comment
              }"
              idTextarea="com-textarea-comment"
              rows="25"
              cols="100"
              propMaxlength="2048"
              defaultHeight="100%"
              :isRisize="false"
              cssClass="textarea-resize-vertical"
              @set-content-data="setContentData"
            ></com-textarea>
          </v-ons-col>
        </v-ons-row>
        <!-- 指示に反映 -->
        <!-- FNSI-改修内容 反映(指示) 房 start
        <v-ons-row v-if="isNew()">
          <v-ons-col style="margin: 1em 0;">
            <div>
              <v-ons-checkbox
                input-id="ind-comment-post-chkbox"
                @change="onIndCommentPost"
              ></v-ons-checkbox>
              <label
                id="ind-comment-post-chkbox-label"
                for="ind-comment-post-chkbox">指示に反映</label>
            </div>
          </v-ons-col>
        </v-ons-row>
        FNSI-改修内容 反映(指示) 房 end-->
        <!-- 指示者 -->
        <!-- FNSI-改修内容 反映(指示) 房 start
        <v-ons-row v-if="isNew()" style="margin: 1em 0;">
          <v-ons-col class="title" width="5em">
            <label>指示者</label>
          </v-ons-col>
          <v-ons-col>
            <kendo-dropdownlist
              v-model="selectedIndUserId"
              :disabled="!isIndCommentPost"
              :data-source="doctorList"
              :data-text-field="'fullName'"
              :data-value-field="'user_id'">
            </kendo-dropdownlist>
          </v-ons-col>
        </v-ons-row>
        FNSI-改修内容 反映(指示) 房 end-->
      </div>
      </div>
    </template>
    <template #footer>
      <div class="flex-container">
      <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 start -->
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="button denial-btn btn2-cancel" @click="onClickCancel">キャンセル</v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <v-ons-button class="button registration-btn btn1-execute" :disabled="!isChanged" @click="onClickApply">保存</v-ons-button>
      </div>
      <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 end -->
      </div>
    </template>
  </modal-base>
</template>

<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import DiscardConfirmationMixin from "@/components/treatment-record/DiscardConfirmationMixin";
import IndUserSelectMixin from "@/components/common/IndUserSelectMixin";
import { CODES } from "@/constants/TreatmentRecord";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import { EventBus } from "@/compat/vue/event-bus.js";
import CommonTextArea from "@/components/common/CommonTextArea";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

export default {
  mixins: [MultiModalMixin, DiscardConfirmationMixin, IndUserSelectMixin],
  components: {
    "modal-base": ModalBase,
    "com-textarea": CommonTextArea
  },
  data() {
    return {
      /**
       * 指示コメント
       */
      comment: null,
      /**
       * 修正前の指示コメント
       */
      initialComment: null,
      /**
       * 指示者ID（編集時）
       */
      initialIndUserId: null,
      /**
       * 選択している指示コメント番号
       */
      selectedNo: null,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
      /**
       * 修正前の選択している指示コメント番号
       */
      initialSelectedNo: null,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
      /**
       * 指示者リストの選択肢
       */
      doctorList:[],
      /**
       * 指示への反映のチェックボックスの状態
       */
      isIndCommentPost: false,
      /**
       * 選択された指示者ID
       */
      selectedIndUserId: 0
    };
  },
  methods: {
    ...mapGetters("treatment-record/addition", [
      "isNew",
      "getTargetNo",
      "getCommentInfo",
      "getUnusedCommentNoList",
      "getRstIndCommentInfo"
    ]),
    ...mapActions("treatment-record/addition", [
      "updateTreatmentRecordAddition",
      "updateIndComment"
    ]),
    /**
     * キャンセルボタンクリック時ハンドラ.
     */
    onClickCancel() {
      if (this.isChanged) {
        this.discardConfirm(this.hideModal);
      } else {
        this.hideModal();
      }
    },
    /**
     * 反映ボタンクリック時ハンドラ.
     */
    onClickApply() {
      // 新規登録
      if (this.isNew()) {
        this.applyNew();
      } else {
        // mod FNSI-改修内容 反映(指示) 房 start
        this.applyEdit(false);
        // this.$ons.notification.confirm({
        //   title: null,
        //   message: "指示にも反映しますか？",
        //   buttonLabels: ["Yes", "No"],
        //   callback: answer => {
        //     this.applyEdit(answer === 0);
        //   }
        // });
        // mod FNSI-改修内容 反映(指示) 房 start
      }
    },
    /**
     * 指示コメント（新規）を保存する
     */
    async applyNew() {
      // 「指示に反映」にチェックされている場合は指示:指示コメントの
      // 登録APIを呼びだす.
      // ※サーバ側で実績:指示コメントへの展開も行う.
      if (this.isIndCommentPost) {
        const responseInd = await this.applyEditInd(CODES.COMMENT_FLAG.NEW.cd);
        if (responseInd.status !== 200) {
          return;
        }
        this.success();
        return;
      }
      // 指示者の情報を取得
      const indUserInfo = this.getIndUserInfo();
      /* modify by chamaojia 2024-01-31 [10196] Default value setting modification --start */
      // 保存する指示コメントのjson作成
      const commentJson = {
        no: this.selectedNo,
        content: this.comment,
        // ind_user_id: indUserInfo.ind_user_id,
        // ind_user_last_name: indUserInfo.ind_user_last_name,
        // ind_user_first_name: indUserInfo.ind_user_first_name,
        // upd_user_id: this.getStateUserAccountInfo().userId,
        // upd_user_last_name: this.getStateUserAccountInfo().userLastName,
        // upd_user_first_name: this.getStateUserAccountInfo().userFirstName,
        input_class: CODES.COMMENT_INPUT_CLASS.RST.cd,
        is_editable: CODES.IS_EDITABLE.POSSIBLE.cd,
        cop_order_no: null
      };
      /* modify by chamaojia 2024-01-31 [10196] Default value setting modification --end */
      // 作成したjsonを既存の指示コメントに追加
      const commentInfo = JSON.stringify(
        this.getRstIndCommentInfo().concat(commentJson)
      );
      // 実績:指示コメントを登録
      this.updateTreatmentRecordAddition({
        ordNo: this.getOrdNo,
        payload: { rst_ind_comment_info: commentInfo }
      })
        .then(() => {
          this.success();
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage('AdditionModalComponent.vue','applyNew','実績の指示コメント登録に失敗しました。');
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
    /**
     * 指示コメント（編集）を保存する.
     * @param isBothApiCall 指示:指示コメントも保存する場合、trueを指定する.
     */
    async applyEdit(isBothApiCall) {
      if (isBothApiCall) {
        // 指示:指示コメントのAPIを呼び出す.
        const responseInd = await this.applyEditInd(CODES.COMMENT_FLAG.EDIT.cd);
        if (responseInd.status !== 200) {
          return;
        }
      } else {
        // 実績:指示コメント保存のAPIを呼びだす.
        const responseRst = await this.applyEditRst();
        if (responseRst.status !== 200) {
          return;
        }
      }
      this.success();
    },
    /**
     * 指示コメント（実績）を更新する
     */
    applyEditRst() {
      // 一覧から対象指示コメントを取得
      const updateCommentInfo = JSON.parse(
        JSON.stringify(this.getRstIndCommentInfo())
      );
      const info = updateCommentInfo.find(c => c.no === this.getTargetNo());

      // 対象指示コメントのコメント、更新者情報を書き換える
      info.content = this.comment;
      /* modify by chamaojia 2024-01-31 [10196] The database has removed this content --start */
      // info.upd_user_id = this.getStateUserAccountInfo().userId;
      // info.upd_user_last_name = this.getStateUserAccountInfo().userLastName;
      // info.upd_user_first_name = this.getStateUserAccountInfo().userFirstName;
      /* modify by chamaojia 2024-01-31 [10196] The database has removed this content --end */

      // 実績:指示コメント保存APIを呼びだす.
      const commentInfo = JSON.stringify(updateCommentInfo);
      return this.updateTreatmentRecordAddition({
        ordNo: this.getOrdNo,
        payload: { rst_ind_comment_info: commentInfo }
      }).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
        getErrorMessage('AdditionModalComponent.vue','applyEditRst','実績の指示コメント登録に失敗しました。');
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
    /**
     * 指示コメント（指示）を更新する
     * @param commentFlag 指示コメントフラグ
     */
    applyEditInd(commentFlag) {
      return this.updateIndComment(
        this.createIndCommentParameter(commentFlag)).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
        getErrorMessage('AdditionModalComponent.vue','applyEditInd','指示の指示コメント登録に失敗しました。');
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        if (error.response.status === 400) {
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "登録失敗",
            // message: "指示の指示コメント登録に失敗しました。"
            title: DIALOG_MESSAGES[12000253].title,
            message: messageFormat(DIALOG_MESSAGES[12000253].message)  
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        }
      });
    },
    /**
     * 指示:指示コメント更新APIに渡すパラメータJSONを生成する.
     * @param {*} commentFlag コメントフラグ
     * @returns パラメータjson
     *          {
     *            comment_flag      コメントフラグ
     *            pat_id            患者ID
     *            facility_cd       施設コード
     *            start_date        治療日
     *            end_date          治療日
     *            num_comment       指示コメント番号
     *            comment           指示コメント内容
     *            weeks             [{"text":"全","done":true,"value":0}]
     *            ind_kur_cd        指示のクールコード(配列)
     *            ind_treatment_cd  指示の治療方法コード(配列)
     *            ind_user_id       指示者
     *            upd_user_id       更新者(サインインユーザID)
     *            input_class       登録区分
     *            is_editable       編集可否
     *            ind_user_last_name  指示者名_姓
     *            ind_user_first_name 指示者名_名
     *            upd_user_last_name  更新者名_姓
     *            upd_user_first_name 更新者名_名
     *          }
     */
    createIndCommentParameter(commentFlag) {
      // 指示者の情報を取得
      const indUserInfo = this.getIndUserInfo();
      // 指示コメント情報を取得
      const commentInfo = this.getCommentInfo();
      // 指示コメント番号を取得
      // 新規の場合は画面で選択されている指示コメント番号を取得
      // 新規以外の場合には、登録済の指示コメント番号を取得
      const ctlNo = commentFlag === CODES.COMMENT_FLAG.NEW.cd
        ? this.selectedNo
        : this.getTargetNo();
      return {
        comment_flag: commentFlag,
        pat_id: commentInfo.pat_id,
        facility_cd: commentInfo.facility_cd,
        start_date: commentInfo.treat_date,
        end_date: commentInfo.treat_date,
        num_comment: ctlNo,
        comment: this.comment,
        init_comment: commentFlag === CODES.COMMENT_FLAG.NEW.cd ? null : this.initialComment,
        weeks: '[{"text":"全","done":true,"value":0}]',
        ind_kur_cd: `[${commentInfo.ind_kur_cd}]`,
        ind_treatment_cd: `[${commentInfo.ind_treatment_cd}]`,
        ind_user_id: indUserInfo.ind_user_id,
        ind_user_last_name: indUserInfo.ind_user_last_name,
        ind_user_first_name: indUserInfo.ind_user_first_name,
        upd_user_id: this.getStateUserAccountInfo().userId,
        upd_user_last_name: this.getStateUserAccountInfo().userLastName,
        upd_user_first_name: this.getStateUserAccountInfo().userFirstName,
        input_class: CODES.COMMENT_INPUT_CLASS.RST.cd,
        is_editable: CODES.IS_EDITABLE.POSSIBLE.cd
      };
    },
    /**
     * 登録成功時処理
     */
    success() {
      this.hideModal();
      EventBus.$emit("applyAdditionModal");
      // 子機能ボタンエリアの更新
      EventBus.$emit("update");
    },
    /**
     * 指示者を設定する.
     */
    async setIndUser() {
      // 指示者ドロップダウンの設定
      this.getIndUserList(
        AUTHORITY_CODES.RST_EDIT,    // 治療記録-編集
        AUTHORITY_CODES.RST_PEDIT    // 治療記録-代行編集
      ).then(response => {
        // 初期選択利用者ID
        const iniSelectId = response.iniSelectId;
        // 指示者リスト
        this.doctorList = response.doctorList;
        // 初期設定
        this.$nextTick(() => {
          this.selectedIndUserId = iniSelectId;
        });
      });
    },
    /**
     * 指示に反映チェックボックスイベント
     * @param {Event} event イベント
     */
    onIndCommentPost(event) {
      this.$nextTick(() => {
        this.isIndCommentPost = event.target.checked;
      });
    },
    /**
     * 指示者情報を取得
     *
     * 「指示に反映」にチェックされていない場合はサインイン者の情報を返却する.
     * チェックされている場合は、選択されている利用者情報（IDと氏名）を返却する.
     * ※チェックされているが、指示者が未選択の場合は、サインイン者の情報を返却する.
     *
     * 編集時(this.isNew() が false) の場合には、初期表示に退避した指示者の情報を
     * 返却する.
     *
     * @returns 指示者情報
     */
    getIndUserInfo() {
      // 編集時
      if (!this.isNew()) {
        const initialUserInfo = this.getDoctorInfo(this.initialIndUserId);
        if (initialUserInfo) {
          return {
            ind_user_id: initialUserInfo.user_id,
            ind_user_last_name: initialUserInfo.user_last_name,
            ind_user_first_name: initialUserInfo.user_first_name
          };
        }
      }
      // 「指示に反映」が選択されている場合
      if (this.isIndCommentPost) {
        // 指示者情報を取得
        const userInfo = this.getDoctorInfo(this.selectedIndUserId);
        if (userInfo) {
          return {
            ind_user_id: userInfo.user_id,
            ind_user_last_name: userInfo.user_last_name,
            ind_user_first_name: userInfo.user_first_name
          };
        }
      }
      return {
        ind_user_id: this.getStateUserAccountInfo().userId,
        ind_user_last_name: this.getStateUserAccountInfo().userLastName,
        ind_user_first_name: this.getStateUserAccountInfo().userFirstName
      };
    },
    /**
     * 利用者IDに該当する利用者情報を取得
     * @param userId 利用者ID
     * @returns 利用者IDに該当する利用者情報
     *          ※doctorListに含まれている必要がある.
     */
    getDoctorInfo(userId) {
      return this.doctorList.find(doctor => doctor.user_id === Number(userId));
    },
    setContentData(newValue) {
      this.comment = newValue;
    }
  },
  computed: {
    isChanged() {
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
      // return this.initialComment !== this.comment;
      return this.initialComment !== this.comment || this.initialSelectedNo !== this.selectedNo;
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
    }
  },
  created() {
    if (this.isNew()) {
      this.selectedNo = this.getUnusedCommentNoList()[0];
      this.comment = "";
    } else {
      const info = this.getRstIndCommentInfo().find(
        c => c.no === this.getTargetNo()
      );
      this.comment = info ? info.content : "";
      // 指示者ID
      this.initialIndUserId = info ? info.ind_user_id : "";
    }
    this.initialComment = this.comment;
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
    this.initialSelectedNo = this.selectedNo;
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
    // 指示者選択肢の構築
    this.setIndUser();
  },
  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
};
</script>

<style scoped>
.expandable-content {
  padding: 0 1em 1em 1em;
}
.custom-expandable-content :deep(.k-widget.k-dropdown) {
  font-size: unset;
}
.comment-no {
  align-items: center;
}
.addition-modal-com-textarea {
  flex: 1;
  min-height: 0;
}
.addition-modal-com-textarea :deep(ons-col) {
  display: flex;
  flex-direction: column;
  flex: 1;
  min-height: 0;
}
div :deep(textarea) {
  width: 100%;
  height: 100%;
  box-sizing: border-box;
  font-size: 1em;
  resize: both;
  font-family: inherit;
}
ons-select {
  width: 4em;
  background-color: white;
}
.select-input {
  font-size: 1em;
}
.com-textarea {
  width: 100%;
  height: 100%;
  flex: 1;
  min-height: 0;
  box-sizing: border-box;
}
@media print {
  /** テキストエリアのページ跨ぎを可能とする */
  .modal-mask {
    text-align: center;
  }
  div :deep(.modal-wrapper){
    display: inline-block !important;
    text-align: left;
    width: 100%;
  }
  /** テキストエリアは印刷用div表示するので非表示 */
  div :deep(.custom-textarea){
    display: none !important;
  }
  /** 印刷用divの高さ調整 */
  div :deep(.print-textarea){
    min-height: 60vh;
  }
}
</style>
