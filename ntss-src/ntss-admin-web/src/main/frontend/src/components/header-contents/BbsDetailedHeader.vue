<template>
  <v-card>
    <div class="header-item">
      <v-touch
        class="v-touch"
        :disabled="searchedBbsList.length === 0 || !isBbsSelected"
        @swipeleft="bbsPre()"
      >
        <v-touch
          class="v-touch"
          :disabled="searchedBbsList.length === 0 || !isBbsSelected"
          @swiperight="bbsNext()"
        >
          <div
            v-if="selectedBbs.bbs_ctl_no === null"
            class="content-area">
          </div>
          <div v-else class="content-area style-date-label">
            <div style="display: flex; flex-wrap: nowrap; align-items: center;">
              <div class="reg-title">起</div>
              <div style="margin-left: 0.3em;">{{ regDate }}</div>
              <div style="text-overflow: ellipsis; overflow: hidden; margin-left: 0.3em;">{{ regStaffName }}</div>
            </div>
            <div style="display: flex; flex-wrap: nowrap; align-items: center;">
              <div class="upd-title">最</div>
              <div style="margin-left: 0.3em;">{{ upDate }}</div>
              <div style="text-overflow: ellipsis; overflow: hidden; margin-left: 0.3em;">{{ updStaffName }}</div>
            </div>
          </div>
        </v-touch>
      </v-touch>
    </div>

    <v-ons-modal :visible="isLoadingBbs">
      <p class="loading-modal">
        掲示板情報を取得しています
        <v-ons-icon icon="fa-spinner" spin />
      </p>
    </v-ons-modal>
  </v-card>
</template>

<script>
import Vue from "vue";
import moment from "moment";
import VueTouch from "vue-touch";
import { mapGetters, mapActions } from "vuex";
import { EventBus } from "@/eventBus.js";
import { ApiHelper } from "@/apis/AxiosHelper";
import { deserializeJsonColumn } from "@/functions/common/CommonFunctions";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
// mod #6107 2023/03/22 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/22 メッセージボックス全調整 張博 end

Vue.use(VueTouch);

/**
 * @description 掲示板詳細情報ページ用ヘッダー
 */
export default {
  data() {
    return {
      // デシリアライズ対象のjsonbカラム名
      jsonColumns: ["pat_info", "staff_info", "file_info"],

      isNotEdited: true,
      moveSelectBbs: null,
      // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
      answer: null,
      abanDoning: 0,
      // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
      /* add by chamaojia 2026-02-05 [11893] キャッシュ軽減対応 --start */
      onIsNotEdited: null
      /* add by chamaojia 2026-02-05 [11893] キャッシュ軽減対応 --end */
    };
  },

  computed: {
    ...mapGetters("bbs-info", [
      "selectedBbs",
      "selectedBbsCtlNo",
      "searchedBbsList",
      "isLoadingBbs",
    ]),

    /**
     * @description 起票者
     */
    regStaffName() {
      return this.selectedBbs === null ? null : this.selectedBbs.reg_staff_name;
    },

    /**
     * @description 起票日時
     */
    regDate() {
      if (this.selectedBbs === null || this.selectedBbs.reg_date === null) {
        return null;
      }
      return moment(this.selectedBbs.reg_date).format("YYYY/MM/DD HH:mm");
    },

    /**
     * @description 最終更新者
     */
    updStaffName() {
      return this.selectedBbs === null ? null : this.selectedBbs.upd_staff_name;
    },

    /**
     * @description 最終更新日時
     */
    upDate() {
      if (this.selectedBbs === null || this.selectedBbs.upd_date === null) {
        return null;
      }
      return moment(this.selectedBbs.up_date).format("YYYY/MM/DD HH:mm");
    },

    /**
     * @description 掲示板一覧におけるbbs_ctl_noのリスト
     */
    bbsCtlNoList() {
      return this.searchedBbsList.map(record => record.bbs_ctl_no);
    },

    /**
     * @description 掲示板一覧における選択掲示板Noのインデックスを取得
     * @summary 前後記事取得用
     * @returns {Number} 掲示板一覧インデックス
     */
    selectedBbsCtlNoIndex() {
      return this.bbsCtlNoList.indexOf(this.selectedBbsCtlNo);
    },

    /**
     * @description 記事選択フラグ
     * @returns {Boolean}
     */
    isBbsSelected() {
      return this.selectedBbs !== null;
    }
  },

  watch: {
    // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
    answer (val) {
      if (val == 1) {
        this.setSelectedBbsInfo(this.selectedBbsCtlNo)
        this.abanDoning++
      }
    }
  },
  // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end

  created() {
    // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
    EventBus.$off("refresh", this.refresh);
    EventBus.$on("refresh", this.refresh);
    EventBus.$off("answer");
    EventBus.$on("answer", data => (this.answer = data));
    // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
    // 掲示板詳細内容の編集有無を取得
    // add 性能改善メモリ不足 shan start
    /* update by chamaojia 2026-02-05 [11893] キャッシュ軽減対応 --start */
    // EventBus.$off("isNotEdited", this.isNotEdited);
    EventBus.$off("isNotEdited", this.onIsNotEdited);
    // add 性能改善メモリ不足 shan end
    // EventBus.$on("isNotEdited", data => (this.isNotEdited = data));
    this.onIsNotEdited = (data) => {
      this.isNotEdited = data;
    };
    EventBus.$on("isNotEdited", this.onIsNotEdited);
    /* update by chamaojia 2026-02-05 [11893] キャッシュ軽減対応 --end */
  },

   beforeDestroy() {
    /* update by chamaojia 2026-02-05 [11893] キャッシュ軽減対応 --start */
    // EventBus.$off("isNotEdited", this.isNotEdited);
    EventBus.$off("isNotEdited", this.onIsNotEdited);
    /* update by chamaojia 2026-02-05 [11893] キャッシュ軽減対応 --end */
    // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
    EventBus.$off("answer", data => (this.answer = data));
    EventBus.$off("refresh", this.refresh);
    // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
  },

  methods: {
    // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
    refresh () {
      if (this.answer == 1) {
        this.answer++
      }
      if (this.isNotEdited) {
        this.setSelectedBbsInfo(this.selectedBbsCtlNo)
      }
    },
    // 共通ローダーの設定
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
    ]),
    // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
    ...mapActions("bbs-info", ["setSelectedBbs", "setIsLoadingBbs"]),

    /**
     * @description 掲示板情報のローディング
     * @param 管理番号
     */
    async loadingSelectedBbsInfo(bbsCtlNo) {
      // 共通ローダーの表示開始
      this.startLoadingScreen();
      // 掲示板情報の設定
      await this.setSelectedBbsInfo(bbsCtlNo);
      // 共通ローダーの表示終了
      this.finishLoadingScreen();
    },

    /**
     * @description 掲示板選択
     * @summary 選択した掲示板のレコードをストアに格納する
     */
    async setSelectedBbsInfo(selectedBbsCtlNo) {
      // add 新規作成時に、selectedBbsCtlNoはヌルの場合、エラー発生について、対応する。 dengshen start
      if (!!!selectedBbsCtlNo){
        return;
      }
      // add 新規作成時に、selectedBbsCtlNoはヌルの場合、エラー発生について、対応する。 dengshen end
      const responseBbsInfo = await ApiHelper.get(
        `bbsInfo/getBbsInfoById/${selectedBbsCtlNo}`
      ).catch(() => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('BbsDetailedHeader.vue', 'setSelectedBbsInfo', '掲示板選択失敗');
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw new Error(
          "[BbsDEtailedHeader.vue]setSelectedBbs(): 掲示板選択失敗"
        );
      });
      const deserializeRecordList = responseBbsInfo.data;
      // 掲示板一覧取得
      const bbsInfo = deserializeJsonColumn(
        deserializeRecordList,
        this.jsonColumns
      );
      // sotreに設定
      this.setSelectedBbs(bbsInfo);
      // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
      EventBus.$emit("abanDoning", this.abanDoning);
      // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
    },

    /**
     * @description 掲示板一覧における前の記事を選択
     */
    selectBbsPre() {
      if (this.bbsCtlNoList.length === 0) {
        return;
      }

      let preBbsCtlNo;
      if (this.selectedBbsCtlNoIndex !== -1) {
        const preBbsCtlNoIndex =
          this.selectedBbsCtlNoIndex === 0
            ? this.bbsCtlNoList.length - 1
            : this.selectedBbsCtlNoIndex - 1;
        preBbsCtlNo = this.bbsCtlNoList[preBbsCtlNoIndex];
      } else {
        // 先頭へ
        preBbsCtlNo = this.bbsCtlNoList[0];
      }
      // 掲示板情報のローディング
      this.loadingSelectedBbsInfo(preBbsCtlNo);
    },

    /**
     * @description 掲示板一覧における次の記事を選択
     */
    selectBbsNext() {
      if (this.bbsCtlNoList.length === 0) {
        return;
      }

      let nextBbsCtlNo;
      if (this.selectedBbsCtlNoIndex !== -1) {
        const nextBbsNoIndex =
          this.selectedBbsCtlNoIndex === this.bbsCtlNoList.length - 1
            ? 0
            : this.selectedBbsCtlNoIndex + 1;
        nextBbsCtlNo = this.bbsCtlNoList[nextBbsNoIndex];
      } else {
        // 先頭へ
        nextBbsCtlNo = this.bbsCtlNoList[0];
      }
      // 掲示板情報のローディング
      this.loadingSelectedBbsInfo(nextBbsCtlNo);
    },

    bbsPre() {
      // 未編集の場合
      if (this.isNotEdited) {
        this.selectBbsPre();
      } else {
        this.moveSelectBbs = this.selectBbsPre;
        this.confirmEdite();
      }
    },

    bbsNext() {
      // 未編集の場合
      if (this.isNotEdited) {
        this.selectBbsNext();
      } else {
        this.moveSelectBbs = this.selectBbsNext;
        this.confirmEdite();
      }
    },

    confirmEdite() {
      this.$ons.notification.confirm({
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
       // title: "内容破棄",
        title: DIALOG_MESSAGES[13000004].title,
        // message: "編集内容が破棄されます。</br>よろしいですか？",
        message: messageFormat(DIALOG_MESSAGES[13000004].message),
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
        callback: answer => {
          if (answer === 1) {
            this.moveSelectBbs();
            // タイトルの初期化
            EventBus.$emit("initTitle", this.initTitle);
          }
        }
      });
    }
  }
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.v-touch {
  height: 100%;
}

.loading-modal {
  text-align: center;
  font-size: 30px;
}

.content-area {
  /* 一覧の文字色 */
  color: var(--ntss-header-color);
  font-size: 1.5em;
}

.reg-title,
.upd-title {
  padding: 0 0.5em;
  border: solid 1px var(--ntss-list-body-color);
  border-radius: 5px;
  margin-left: 0.1em;
  height: 100%;
  display: flex;
  align-items: center;
}
/* mod FNSI-改修内容5591修正 関 start */
/* .style-date-label {
  padding-top: 8px;
  margin-left: 25px;
} */
.style-date-label {
  margin-left: 25px;
  white-space: nowrap;
  height: 100%;
  display: flex;
  flex-flow: column;
  justify-content: space-evenly;
  width: calc(100% - 100px);
}
/* mod FNSI-改修内容5591修正 関　end */
</style>
