/* 指示履歴 */

<template>
  <modal-base @onClose="hideModal" class="custom-modal">
    <div
      slot="body"
      class="modal-container-custom box_dis master-maintenance-page"
      id="indications-history-modal"
    >
      <div class="modal-contents">
        <v-ons-row>
          <kendo-grid
            ref="grid"
            :data-source="gridData"
            :columns="gridColumns"
            :sortable="true"
            :resizable="true"
            :scrollable-endless="true"
            :pageable-numeric="false"
            :pageable-previous-next="false"
            :pageable-messages-empty="pageableMessageEmpty"
            :height="gridHeightValue"
          />
        </v-ons-row>
      </div>
    </div>
    <div slot="footer" class="modal-footer-custom">
      <v-ons-row>
        <v-ons-col>
          <!-- mod 画面部品デザイン定義 修正 chen start -->
          <v-ons-button class="btn3-normal common-style-select-button" @click="hideModal">
          <!-- <v-ons-button class="common-style-ok-button" @click="hideModal"> -->
          <!-- mod 画面部品デザイン定義 修正 chen end -->
            OK
          </v-ons-button>
        </v-ons-col>
      </v-ons-row>
    </div>
  </modal-base>
</template>

<script>
import { mapGetters } from "vuex";
import moment from "moment";
import kendo from "@progress/kendo-ui";
import ModalBase from "@/components/modals/ModalBase";
import elementResizeDetectorMaker from "element-resize-detector";
import MultiModalMixin from "@/components/modals/MultiModalMixin";

const erd = elementResizeDetectorMaker({
  strategy: "scroll"
});

export default {
  components: {
    ModalBase
  },

  mixins: [MultiModalMixin],

  data() {
    return {
      gridColumns: [
        { field: "upDate", title: "日時", width: 100 },
        { field: "approveKind", title: "対象", width: 100 },
        { field: "signType", title: "編集", width: 100 },
        { field: "approveBefId", title: "変更前", width: 100 },
        { field: "approveAftId", title: "変更後", width: 100 },
        { field: "userId", title: "登録者", width: 100 }
      ],
      pageableMessageEmpty: "データがありません",
      gridData: [],
      isGridInitialLoad: true,
      gridHeight: 0,
      signTypeDataSources: [
        { value: 0, text: "解除" },
        { value: 1, text: "登録" }
      ],
      approveKindDataSources: [
        { value: 1, text: "指示受け1" },
        { value: 2, text: "指示受け2" },
        { value: 3, text: "指示承認1" },
        { value: 4, text: "指示承認2" }
      ]
    };
  },

  computed: {
    ...mapGetters("indication", ["mstPersonalUser"]),
    ...mapGetters("treatment-record/common", ["getOrdNoForSideBarRecord"]),
    gridHeightValue() {
      return this.gridHeight;
    },
    isApproving() {
      return this.$route.name === "indication-approve-detail";
    }
  },

  mounted() {
    erd.listenTo(this.$el, () => {
      this.$refs.grid.kendoWidget().refresh();
    });
    this.$nextTick(async () => {
      window.addEventListener("resize", this.onResize);
    });
  },

  methods: {
    /**
     * @description テーブル内容を取得関数
     *              ★ kendoの既定リクエストAPIはjQueryである
     */
    async updateGridData() {
      let total;
      const kindName = this.isApproving ? "approve" : "check";
      const that = this;
      that.isGridInitialLoad = true;
      that.gridData = new kendo.data.DataSource({
        transport: {
          read: {
            url: "api/patIndApproveHistory",
            dataType: "json"
          },
          parameterMap(data) {
            const params = {
              kind: kindName,
              ordNo: that.getOrdNoForSideBarRecord,
              page: data.page - 1, // APIのページは0オリジン
              size: data.pageSize
              //del #12663 #12665 securify】SQLインジェクション(High) まとめ zrx start
              // sort: "ind_approve_history_no,desc"
              //del #12663 #12665 securify】SQLインジェクション(High) まとめ zrx end
            };

            // 値がないフィールドを抜く
            Object.keys(params).forEach(
              key => !params[key] && delete params[key]
            );

            return params;
          }
        },
        // kendo内のページごとのデータ件数
        pageSize: 50,
        // ページネーションはサーバーで行うかどうか
        serverPaging: true,
        // 並べ替えはサーバーで行うかどうか
        serverSorting: true,
        // kendo内の取ってくるデータ構成
        schema: {
          // データを取ってきた後のコールバック
          data(response) {
            const responseData = response.result;
            responseData.forEach(item => {
              item.upDate = moment(item.upDate).format(
                "YYYY/MM/DD(ddd) HH:mm:ss"
              );
              item.userId = that.getUserName(item.userId);
              item.approveBefId = that.getUserName(item.approveBefId);
              item.approveAftId = that.getUserName(item.approveAftId);
              item.signType = that.getSignTypeName(item.signType);
              item.approveKind = that.getApproveKindName(item.approveKind);
            });
            return responseData;
          },
          // データ総数
          total(response) {
            total = total || response.totalElements;
            return total;
          }
        },
        requestStart(e) {
          // 初期ロード時にkendoが2回リクエストをしてるから、2重化しないために1回目のリクエストを処理しない
          if (!that.getOrdNoForSideBarRecord || that.isGridInitialLoad) {
            e.preventDefault();
            if (that.isGridInitialLoad) that.isGridInitialLoad = false;
          }

          // ロードアイコンを表示
          kendo.ui.progress(that.$refs.grid.kendoWidget().element, true);
        },
        requestEnd() {
          // ロードアイコンを非表示
          kendo.ui.progress(that.$refs.grid.kendoWidget().element, false);
        }
      });
    },
    getUserName(userId) {
      const user = this.mstPersonalUser.find(user => +user.userId === +userId);
      return user ? user.userFullName : "";
    },
    getSignTypeName(value) {
      const signType = this.signTypeDataSources.find(
        item => +item.value === +value
      );
      return signType ? signType.text : "";
    },
    getApproveKindName(value) {
      const approveKind = this.approveKindDataSources.find(
        item => +item.value === +value
      );
      return approveKind ? approveKind.text : "";
    },
    onResize() {
      const ele = document.getElementById("indications-history-modal");
      this.gridHeight = ele ? ele.offsetHeight - 20 : 0;
    }
  },

  async created() {
    await this.updateGridData();
    this.$nextTick(async () => {
      this.onResize();
    });
  },

  beforeDestroy() {
    window.removeEventListener("resize", this.onResize);
    // add 画面パフォーマンス対応 chen start
    this.gridColumns = null;
    this.pageableMessageEmpty = null;
    this.gridData = null;
    this.isGridInitialLoad = null;
    this.gridHeight = null;
    this.signTypeDataSources = null;
    this.approveKindDataSources = null;
    // add 画面パフォーマンス対応 chen end
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
};
</script>

<style scoped>
/* モーダル内がくずれるのでdisplay:hiddenではなくnoneにする */
div >>> .erd_scroll_detection_container {
  display: none !important;
}

.modal-container-custom >>> .k-grid {
  width: 100%;
  font-size: 1em;
/* add 障害票一覧_指示受け・指示承認 修正 chen start */
  border: 1px solid #dee2e6;
/* add 障害票一覧_指示受け・指示承認 修正 chen end */
}

.modal-container-custom >>> .k-grid-content {
  height: 50vh;
/* add 障害票一覧_指示受け・指示承認 修正 chen start */
  border: 1px solid #dee2e6;
/* add 障害票一覧_指示受け・指示承認 修正 chen end */
}
/* add 障害票一覧_指示受け・指示承認 修正 chen start */
.modal-container-custom >>> .k-grid-pager {
  border: 1px solid #dee2e6;
}
/* add 障害票一覧_指示受け・指示承認 修正 chen end */

.modal-container-custom {
  height: auto;
  color: black;
}

.modal-header-custom {
  text-align: left;
  color: white;
  background-color: black;
  padding: 3px;
  height: auto;
  width: auto;
  position: initial;
}

.modal-contents {
  padding: 10px;
}

.modal-footer-custom {
  padding: 10px;
  text-align: center;
}

.icon-close {
  float: right;
  padding: 3px;
  cursor: pointer;
}

.popover-style >>> .popover__content {
  width: 450px;
  height: 100%;
  padding: 15px;
  font-size: 14px;
}

.popover-style >>> .popover-mask {
  z-index: 10005;
}

.popover-style >>> .popover {
  z-index: 10010;
  margin-top: 50px;
}

.popover-footer-style {
  margin-top: 15px;
}

.button-cancel {
  float: left;
}

.button-confirm {
  float: right;
}

input::-webkit-calendar-picker-indicator {
  display: none;
}

.select-style,
.search-style {
  width: 100%;
}

/* TODO: 共通スタイル(modal.css)に定義 */
div >>> .modal-header .toolbar {
  background-color: var(--ntss-header-background-color);
}

div >>> .modal-header .toolbar__title.toolbar__left {
  color: var(--ntss-header-color) !important;
}

div >>> .modal-search,
div >>> .modal-body,
div >>> .modal-footer,
div >>> .modal-footer .bottom-bar,
div >>> .k-grid .k-grid-pager {
  background-color: var(--ntss-base-background-color);
  color: var(--ntss-base-color);
}

div >>> .modal-body {
  overflow: hidden;
}

#indications-history-modal {
  height: 100%;
}

#indications-history-modal .k-grid-header .k-header {
  color: #fff;
  background-color: var(--ntss-header-background-color);
  background-image: -webkit-linear-gradient(
    rgba(255, 255, 255, 0.3) 0%,
    transparent 50%,
    transparent 50%,
    rgba(0, 0, 0, 0.1) 100%
  );
  background-image: linear-gradient(
    rgba(255, 255, 255, 0.3) 0%,
    transparent 50%,
    transparent 50%,
    rgba(0, 0, 0, 0.1) 100%
  );
}
/* 指示受け履歴画面で二重スクロールが発生する  6425  shan  start */
.box_dis{
  position: absolute;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 100;
  overflow-y: auto;
  margin: 5px;
  margin-top: 0;
  height: inherit;
}

.box_dis::-webkit-scrollbar {
  display: none; /* Chrome Safari */
}

.box_dis {
  scrollbar-width: none; /* firefox */
  -ms-overflow-style: none; /* IE 10+ */
}
/* 指示受け履歴画面で二重スクロールが発生する  6425  shan  end */

@media print {
  /** 日時 */
  .modal-contents >>> .k-grid colgroup col:nth-child(1) {
    min-width: 6.7em;
    width: 25% !important;
  }
  /** 日時以外 */
  .modal-contents >>> .k-grid colgroup col:nth-child(n+2) {
    width: 15% !important;
  }
  /* ヘッダ、ボディ */
  .modal-contents >>> .k-grid-header {
    padding-right: 0 !important;
  }
  /* Grid本体を紙幅に収める */
  .modal-contents >>> div {
    height: auto !important;
  }
  .modal-contents >>> .k-grid,
  .modal-contents >>> .k-grid table {
    width: 100% !important;
    table-layout: fixed !important;
  }
  /* KendoがJSで設定した幅を無効化 */
  .modal-contents >>> .k-grid th,
  .modal-contents >>> .k-grid td {
    width: auto !important;
    max-width: none !important;
  }
  .modal-contents >>> .k-grid colgroup col {
    width: auto !important;
    max-width: none !important;
  }
  .modal-contents >>> .k-grid th,
  .modal-contents >>> .k-grid td {
    white-space: normal !important;
    overflow-wrap: anywhere;
    word-break: break-word;
    height: auto !important;
    padding: 2px 1px !important;
  }
  /* Kendoのellipsis解除 */
  .modal-contents >>> .k-grid .k-link,
  .modal-contents >>> .k-grid .k-column-title,
  .modal-contents >>> .k-grid .k-cell-inner {
    white-space: normal !important;
    text-overflow: unset !important;
    overflow: visible !important;
  }
}
</style>
