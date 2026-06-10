/** アプリケーションダウンロードページ */
 <template>
  <div class='main-content-area master-maintenance-page'>
    <div class='sys-app-main-content-area'>
      <kendo-grid
        ref='sysApplicationGrid'
        :class='fontSizeSet'
        :height='kendoGridHeight'
        :data-source='applicationInfoGrid'
        :editable='false'
        :scrollable='true'
      >
        <template v-for='(item, index) in getSysApplicationColumn'>
          <kendo-grid-column
            v-if='item.title === "ダウンロード"'
            :key='`download-${index}`'
            :title='item.title'
            :width='item.width'
            :field='item.field'
            :hidden='item.hidden'
            :locked='item.locked'
            :editable='item.editable'
            :attributes='{ style: "text-align: center;" }'
            :template="downloadTemplate"
          />
          <kendo-grid-column
            v-else
            :key='`other-${index}`'
            :title='item.title'
            :width='item.width'
            :field='item.field'
            :hidden='item.hidden'
            :locked='item.locked'
            :editable='item.editable'
            :template='item.template'
            :values='item.values'
          />
        </template>
      </kendo-grid>
    </div>
  </div>
</template>

<script>
import Vue from "vue";
import { mapActions, mapGetters } from "vuex";
import { EventBus } from "@/eventBus.js";
import Kendo from "@progress/kendo-ui";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import DownloadTemplate from "./SysApplicationDownloadButtonTemplate";

export default {
  mixins: [NextTransitionMixin, MasterMaintenanceMixin],
  data() {
    return {
      columns: [],
      selfScreenName: "",
      kendoGridHeight: 300,
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", {isDispMenu: "isDispMenu"}),
    ...mapGetters("sys-application", ["getSysApplicationColumn", "getApplicationInfo", "getCondition"]),
    /** グリッド表示情報 */
    applicationInfoGrid() {
      return new Kendo.data.DataSource({data: this.getApplicationInfo});
    },
  },
  watch: {
    windowHeight() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    },
    windowWidth() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    },
    getFontSize() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    },
    isDispMenu() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    },
    getCondition() {
      this.fetchApplicationInfo();
    },
  },
  methods: {
    ...mapActions("sys-application", [
      "setCondition",
      "setSysApplicationColumn",
      "fetchApplicationInfo",
      "cleanApplicationInfo"
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
    }),
    /** ダウンロードボタンのテンプレート作成 */
    downloadTemplate(event) {
      return {
        template: Vue.component(DownloadTemplate.name, DownloadTemplate),
        templateArgs: event
      };
    },
    /** データ取得 */
    loadGridData() {
      this.setLoadingScreenVisible(true);
      this.fetchApplicationInfo();
      this.$nextTick(() => {
        this.calculateColumnsWidth();
        this.calculateGridHeight();
        this.calculateGridWidth();
      });
    },
    /** リフレッシュ処理 */
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$router.currentRoute.name
          && document.getElementsByTagName("ons-alert-dialog").length === 0) {
        this.loadGridData();
      }
    },
  },
  created() {
    this.setLoadingScreenVisible(true);
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    this.cleanApplicationInfo();
    this.selfScreenName = this.$router.currentRoute.name;
    EventBus.$on("refresh", this.refresh);
  },
  mounted() {
    this.loadGridData();
  },
  updated() {
    this.$nextTick(() => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
      this.setLoadingScreenVisible(false);
    });
  },
  beforeDestroy() {
    EventBus.$off("refresh", this.refresh);
    this.setCondition(JSON.parse(JSON.stringify({recordName: ""})));
  }
};
</script>

<style scoped>
.sys-app-main-content-area >>> .k-grid-content > .k-selectable {
  box-shadow: 1px 0px 0px 0px white;
  border-right: 1px solid transparent;
}
.sys-app-main-content-area >>> .k-grid-content-locked {
  border-right: 0px solid transparent !important;
}
.sys-app-main-content-area >>> .k-grid-header-locked {
  border-right-width: 0px;
}
.sys-app-main-content-area >>> .k-grid td {
  height: 2.4em;
}
</style>
