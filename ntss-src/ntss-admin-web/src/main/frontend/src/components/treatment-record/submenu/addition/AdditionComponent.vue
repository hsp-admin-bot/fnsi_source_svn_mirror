/**
 * 治療記録の子機能 指示コメントページ
 */
<template>
  <submenu-base v-if="hasOrdNo">
    <div slot="header">
      <div class="new-btn-area">
        <!-- mod FNSI-権限関連 王 20200927 start -->
        <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 start -->
        <!-- redmine4783 修正 姜 mod start -->
        <!-- <v-ons-button class="button registration-btn btn3-normal" :disabled="!canCreate || isReadOnly || !isShared || !hasTreatmentRecordAuthority" @click="onClickNew">新規</v-ons-button> -->
        <!-- mod #10359 編集権限の動作不正 start -->
        <!-- <v-ons-button class="button registration-btn btn3-normal" :disabled="!canCreate || isReadOnly || !isShared || !hasTreatmentRecordAuthority" @click="onClickNew">追加</v-ons-button> -->
        <v-ons-button class="button registration-btn btn3-normal" :disabled="!canCreate || isReadOnly || !isShared ||!getItemAuthorized('TreatmentRecord', 'default_authority')" @click="onClickNew">追加</v-ons-button>
        <!-- mod #10359 編集権限の動作不正 end -->
        <!-- redmine4783 修正 姜 mod end -->
        <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 end -->
        <!-- mod FNSI-権限関連 王 20200927 end -->
      </div>
    </div>
    <div slot="main" id="addition-component">
      <div>
        <table class="treatment-record-list">
          <thead>
            <tr>
              <th class="ntss-list-header-th-sticky align-center no-col">No</th>
              <th class="ntss-list-header-th-sticky comment-col">指示コメント</th>
              <th class="ntss-list-header-th-sticky edit-button-col"></th>
              <th class="ntss-list-header-th-sticky delete-col"></th>
            </tr>
          </thead>
          <tbody>
            <template v-for="(data, index) in commentList">
              <tr :key="index" class="ntss-list-body-tr">
                <td class="align-center ntss-list-body-td">{{ data.no }}</td>
                <td class="ntss-list-body-td comment-td">{{ data.comment }}</td>
                <td class="align-center ntss-list-body-td">
                  <!-- mod FNSI-権限関連 王 20200927 start -->
                  <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 start -->
                  <!-- mod #10359 編集権限の動作不正 start -->
                  <!-- <v-ons-button class="k-button btn3-normal" v-if="data.isEditable && isShared" :disabled="!hasTreatmentRecordAuthority" @click="onClickEdit(data.no)">編集</v-ons-button> -->
                  <v-ons-button class="k-button btn3-normal" v-if="data.isEditable" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority') || !isShared" @click="onClickEdit(data.no)">編集</v-ons-button>
                  <!-- mod #10359 編集権限の動作不正 start -->
                  <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 end -->
                  <!-- mod FNSI-権限関連 王 20200927 end -->
                </td>
                <td class="ntss-list-body-td">
                  <button class="ntss-btn-outset button-delete" @click="onClickDelete(index)" :disabled="!isShared">
                    <v-ons-icon icon="fa-trash"/>
                  </button>
                </td>
              </tr>
            </template>
          </tbody>
        </table>
      </div>
    </div>
    <div slot="footer" class="flex-container" />
  </submenu-base>
</template>

<script>
//#10359 mod 編集権限の動作不正 2024-06-05 卓 start
import { mapActions, mapGetters } from "vuex";
import SubmenuBase from "@/components/treatment-record/SubmenuBaseComponent";
import DiscardConfirmationMixin from "@/components/treatment-record/DiscardConfirmationMixin";
//import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
import { IndComment } from "@/models/treatment-record/addition/IndComment";
import { EventBus } from "@/eventBus.js";
import { CODES } from "@/constants/TreatmentRecord";
// import { AUTHORITY_CODES } from "@/constants/userAuthority";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
//#10359 mod 編集権限の動作不正 2024-06-05 卓 end

export default {
  //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
  // mixins: [DiscardConfirmationMixin, ComponentGuardMixin],
  mixins: [DiscardConfirmationMixin],
  //#10359 mod 編集権限の動作不正 2024-06-05 卓 end


  components: {
    "submenu-base": SubmenuBase
  },
  data() {
    return {
      commentList: [],
      // authorityCds: [ AUTHORITY_CODES.RST_PEDIT, AUTHORITY_CODES.RST_EDIT ],
      // add FNSI-権限関連 王 20200927 start
      // 治療記録の権限を有無する
      // del #10359 編集権限の動作不正 start
      // hasTreatmentRecordAuthority: false,
      // del #10359 編集権限の動作不正 end
      // add FNSI-権限関連 王 20200927 end
      selfScreenName: ""
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowWidth: "getMainWindowWidth"
    }),

    ...mapGetters("treatment-record/common", [
      "getOrd",
      // add 孫 svn72
      "getSharedFacilityCd"
      // add 孫 svn72 end
    ]),

    // add 孫 svn72
    ...mapGetters("user", ["getFacilityCd"]),

    isShared() {
      return this.getFacilityCd === this.getSharedFacilityCd;
    },
    // add 孫 svn72 end
    /**
     * 新規登録できるかを返す
     */
    canCreate() {
      // #10777 治療記録で指示コメント1~99を入力した際に追加ボタン押下で番号指定しないで登録できる/患者経過総合ビューアでがundefinedと表示される linjunfeng start
      // return this.commentList.length < 100;
      return this.commentList.length < 99;
      // #10777 治療記録で指示コメント1~99を入力した際に追加ボタン押下で番号指定しないで登録できる/患者経過総合ビューアでがundefinedと表示される linjunfeng end
    },
    /**
     * 削除できるかを返す
     */
    canDelete() {
      return this.commentList.some(e => e.isDel);
    },

    isReadOnly() {
      return this.getOrd.readOnly;
    }
  },
  methods: {
    ...mapActions("multi-modal", ["showTreatmentRecordAdditionInput"]),
    ...mapActions("treatment-record/addition", [
      "getTreatmentRecordAddition",
      "setCommentInfo",
      "setTargetNo",
      "updateTreatmentRecordAddition",
      "updateIndComment"
    ]),
    ...mapGetters("treatment-record/addition", [
      "getRstIndCommentInfo",
      "getCommentInfo"
    ]),
    /**
     * 新規ボタンクリックイベントハンドラー
     */
    onClickNew() {
      if(this.isReadOnly) {
        return;
      }
      this.setTargetNo(null);
      this.showTreatmentRecordAdditionInput();
    },
    /**
     * 編集ボタンクリックイベントハンドラー
     * @param {Number} targetNo 指示コメント番号
     */
    onClickEdit(targetNo) {
      this.setTargetNo(targetNo);
      this.showTreatmentRecordAdditionInput();
    },
    /**
     * 削除ボタンクリックイベントハンドラー
     */
    onClickDelete(targetIndex) {
      if(this.isReadOnly) {
        return;
      }
      this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "削除確認",
        title: DIALOG_MESSAGES[13000141].title,
        // message: "削除します。<br>よろしいですか？",
        message: messageFormat(DIALOG_MESSAGES[13000141].message),
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: answer => {
          if (answer === 1) {
            this.deleteComments(targetIndex);
            // 子機能ボタンエリアの更新
            this.$emit("update");
          }
        }
      });
    },
    // add #10359 編集権限の動作不正 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 end
    /**
     * 指示コメントを削除する.
     */
    async deleteComments(targetIndex) {
      // ESM API 呼び出し
      const responseRst = await this.deleteCommentsRst(targetIndex);
      if (responseRst.status !== 200) {
        return;
      }

      // YED API 呼び出し
      //modify FNSI-6780(5685残り) 実績を削除する際に指示は削除不要に修正。ljx start
      //if (!(await this.deleteCommentsInd())) {
        //return;
      //}
      //modify FNSI-6780(5685残り) 実績を削除する際に指示は削除不要に修正。ljx end

      this.success();
    },
    /**
     * 指示コメント（実績）を削除する.
     */
    async deleteCommentsRst(targetIndex) {
      const undeleteCommentNoList = this.commentList
        .filter((_, index) => index !== targetIndex)
        .map(e => e.no);
      const rstIndCommentInfo = this.getRstIndCommentInfo().filter(c =>
        undeleteCommentNoList.includes(c.no)
      );

      return await this.updateTreatmentRecordAddition({
        ordNo: this.getOrdNo,
        payload: { rst_ind_comment_info: JSON.stringify(rstIndCommentInfo) }
      }).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
        getErrorMessage('AdditionComponent.vue','deleteCommentsRst','実績の指示コメント削除に失敗しました。');
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        if (error.response.status === 400) {
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "削除失敗",
            // message: "実績の指示コメント削除に失敗しました。"
            title: DIALOG_MESSAGES[12000250].title,
            message: messageFormat(DIALOG_MESSAGES[12000250].message)
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        }
      });
    },
    /**
     * 指示コメント（指示）を削除する.
     */
    async deleteCommentsInd() {
      const deleteCommentNoList = this.commentList
        .filter(e => e.isDel)
        .map(e => e.no);
      const indCommentInfoList = this.getRstIndCommentInfo()
        .filter(c => deleteCommentNoList.includes(c.no))
        .map(c =>
          this.createIndCommentParameter(
            CODES.COMMENT_FLAG.DELETE.cd,
            c.no,
            c.content
          )
        );

      for (let index = 0; index < indCommentInfoList.length; index++) {
        const element = indCommentInfoList[index];
        const response = await this.updateIndComment(element).catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage('AdditionComponent.vue','deleteCommentsInd','指示の指示コメント削除に失敗しました。');
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "削除失敗",
              // message: "指示の指示コメント削除に失敗しました。"
              title: DIALOG_MESSAGES[12000251].title,
              message: messageFormat(DIALOG_MESSAGES[12000251].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
            return error.response;
          }
        });

        if (response.status !== 200) {
          return false;
        }
      }

      return true;
    },

    /**
     * YEDの指示コメント更新APIに渡すパラメータJSONを生成する.
     * @param {*} commentFlag コメントフラグ
     * @param {Number} no 指示コメント番号
     * @param {String} content 指示コメント
     */
    createIndCommentParameter(commentFlag, no, content) {
      const commentInfo = this.getCommentInfo();
      return {
        comment_flag: commentFlag,
        pat_id: commentInfo.pat_id,
        facility_cd: commentInfo.facility_cd,
        start_date: commentInfo.treat_date,
        end_date: commentInfo.treat_date,
        num_comment: no,
        comment: content,
        weeks: '[{"text":"全","done":true,"value":0}]',
        ind_kur_cd: commentInfo.rst_kur_cd,
        ind_treatment_cd: commentInfo.rst_treatment_cd,
        ind_user: this.getStateUserAccountInfo().userId,
        upd_user: this.getStateUserAccountInfo().userId
      };
    },
    /**
     * 削除成功時処理
     */
    success() {
      this.init();
      // 子機能ボタンエリアの更新
      this.$emit("update");
    },
    update() {
      // 子機能ボタンエリアの更新
      this.$emit("update");
    },
    /**
     * 初期化処理
     */
    init() {
      if (!this.getOrdNo) {
        return;
      }
      this.getTreatmentRecordAddition(this.getOrdNo).then(response => {
        /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --start */
        // const commentInfo = JSON.parse(response.data.rst_ind_comment_info);
        const commentInfo = (response.data && response.data.rst_ind_comment_info)
            ? JSON.parse(response.data.rst_ind_comment_info) : null;
        /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --end */
        this.setCommentInfo(response.data);
        this.commentList = commentInfo
          ? commentInfo
              .map(c => {
                return new IndComment(
                  c.no,
                  c.input_class,
                  c.content,
                  c.is_editable === CODES.IS_EDITABLE.POSSIBLE.cd
                );
              })
              .sort((a, b) => a.no - b.no)
          : [];
        //#10359 del 編集権限の動作不正 2024-06-05 卓 start
        // this.$nextTick(() => {
        //   this.disableElement(this.$el);
        // });
        //#10359 del 編集権限の動作不正 2024-06-05 卓 end

      });
    },
    // add FNSI-権限関連 王 20200927 start
    // 治療記錄の權限を取得する
    // del #10359 編集権限の動作不正 start
    // getTreatmentRecordAuthority() {
    //   return (this.hasAuthorityByCd(AUTHORITY_CODES.RST_PEDIT) || this.hasAuthorityByCd(AUTHORITY_CODES.RST_EDIT)) &&
    //   (this.hasAuthorityByCd(AUTHORITY_CODES.IND_PEDIT) || this.hasAuthorityByCd(AUTHORITY_CODES.IND_EDIT));
    // },
    // del #10359 編集権限の動作不正 end
    // add FNSI-権限関連 王 20200927 end
    /**
     * 再描画処理
     */
    refresh() {
      // 子機能ボタンエリアの更新
      this.$emit("update");
      if (this.selfScreenName !== this.$router.currentRoute.name) {
        return;
      }
      this.init();
    }
  },
  created() {
    this.init();
    EventBus.$on("applyAdditionModal", this.init);
    EventBus.$on("update", this.update);
    // 画面名称取得
    this.selfScreenName = this.$router.currentRoute.name;
    // イベント登録
    EventBus.$on("refresh", this.refresh);
    // add FNSI-権限関連 王 20200927 start
    // 治療記錄の權限取得
    // del #10359 編集権限の動作不正 start
    // this.hasTreatmentRecordAuthority = this.getTreatmentRecordAuthority();
    // del #10359 編集権限の動作不正 end
    // add FNSI-権限関連 王 20200927 end
  },
  beforeDestroy() {
    EventBus.$off("applyAdditionModal");
    EventBus.$off("update");
    // イベント解除
    // del refresh方法処理不正について、対応する。 dengshen start
    // EventBus.$off("refresh");
    // del refresh方法処理不正について、対応する。 dengshen end
    EventBus.$off("refresh", this.refresh);
    // add #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng end
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
};
</script>

<style scoped>
.ntss-list-header-th-sticky {
  z-index: 1;
}
.new-btn-area {
  margin-left: 1em;
  margin-bottom: 1em;
  position: sticky;
  z-index: 1;
  top: 0;
  margin: 0;
  padding: 8px 8px 8px 0;
  background-color: var(--main-background-color);
}
.align-center {
  text-align: center;
}
.scroll-table {
  width: 1px;
}
.edit-button-col {
  width: 5em;
}
.delete-col {
  width: 2.2em;
  min-width: 2.2em;
}
.no-col,
.div-col {
  width: 4em;
}
.comment-col {
  min-width: 20em;
}
.comment-td {
  white-space: pre-wrap;
}
tbody tr {
  height: 3.5em;
}
/* 削除ボタン */
.button-delete {
  max-width: 25px;
}
</style>
