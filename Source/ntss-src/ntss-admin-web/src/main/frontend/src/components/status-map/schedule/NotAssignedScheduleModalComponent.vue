/**
 * スケジュール割当モーダル
 */
 <template>
  <modal-base @onClose="closeScheduleAssignmentModal">
    <template #header>
      <div>
        <component :is="header"></component>
      </div>
    </template>
    <template #body>
      <div>
        <div id="schedulemodal-header">
        <v-ons-row>
          <v-ons-col>
            <!-- ベッド名 -->
            <label class="pat-info">ベッド名：{{getFindState.bedName}}</label>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col>
            <!-- 治療日 -->
            <label class="pat-info">治療日&emsp;：{{getFindState.treatDate}}</label>
          </v-ons-col>
        </v-ons-row>
      </div>
      <!-- スケジュール/患者のグリッド -->
      <div id="schedule-grid">
        <kendo-grid
          ref="scheduleGrid"
          :data-source="scheduleList"
          :editable="false"
          :reorderable="true"
          :resizable="true"
          :selectable="'row'"
          :scrollable="true"
          :height="scheduleGridHeight"
          @change="onChangeGrid"
        >
        <!--#9899:スケジュール割り当てで患者IDの列と同姓同名アイコンが表示されていない Start-->
        <!--#9899:スケジュール割り当てで患者IDの列と同姓同名アイコンが表示されていない(警告対応) Start-->
        <kendo-grid-column v-for='(column, index) in TreatmentStatusGridColumns'
        :key="index"
        :template="column.template"
        :field='column.field'
        :hidden='column.hidden'
        :title='column.title'
        :width='column.width'
        ></kendo-grid-column>
        </kendo-grid>
        <!--#9899:スケジュール割り当てで患者IDの列と同姓同名アイコンが表示されていない(警告対応) End-->
        <!--#9899:スケジュール割り当てで患者IDの列と同姓同名アイコンが表示されていない End-->
      </div>
      </div>
    </template>

    <template #footer>
      <div class="flex-container">
      <!-- mod FNSI-画面スタイル(ボタン)対応 付 start -->
      <div class="denial-btn-area">
        <button class="button denial-btn btn2-cancel" @click="closeScheduleAssignmentModal">キャンセル</button>
      </div>
      <div class="registration-btn-area">
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <button class="button registration-btn btn1-execute" :disabled="0===this.selectedOrdNo"   @click="saveChecklist">保存</button> -->
        <button
          class="button registration-btn btn1-execute"
          :disabled="0===this.selectedOrdNo || !getItemAuthorized('StatusListMap', 'item_map_schedule')"
          @click="saveChecklist">保存</button>
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
      </div>
      <!-- mod FNSI-画面スタイル(ボタン)対応 付 end -->
      </div>
    </template>
  </modal-base>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { createDataSource } from "@/functions/common/KendoFunctions";
import ModalBase from "@/components/modals/ModalBase";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import nameDuplicationImg from "../../../assets/name_duplication.png";
import { getModalBodyElement, getScopedElementById, resolveRefElement } from "@/functions/common/LayoutMeasureHelper";

export default {
  name: "NotAssignedScheduleModal",
  components: {
    "modal-base": ModalBase
  },
  data() {
    return {
      scheduleGridToolbarHeight: 500,
      scheduleGridHeight: 300,
      main: "",
      header: "",
      //#9899:スケジュール割り当てで患者IDの列と同姓同名アイコンが表示されていない Start
      selectedOrdNo: 0,
      image_src_same: nameDuplicationImg,
      //#9899:スケジュール割り当てで患者IDの列と同姓同名アイコンが表示されていない End
    };
  },
  computed: {
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("status-map/modal", [
      "getNotAssignedOrdMainList",
      "getFindState"
    ]),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    // グリッド表示用データ
    scheduleList() {
      // storeからデータを取得
      //#9899:スケジュール割り当てで患者IDの列と同姓同名アイコンが表示されていない Start
      if (this.getNotAssignedOrdMainList != null) {
      this.getNotAssignedOrdMainList.forEach(element => {
            element.image_src_same= this.$data.image_src_same;
        });
      }
      console.log(this.getNotAssignedOrdMainList);
      //#9899:スケジュール割り当てで患者IDの列と同姓同名アイコンが表示されていない End
      return createDataSource({
        data: this.getNotAssignedOrdMainList
      });
    //#9899:スケジュール割り当てで患者IDの列と同姓同名アイコンが表示されていない Start 
    },
    TreatmentStatusGridColumns() {
      return [
       {
          field: "ordNo",
          hidden: true,
          locked: true,
          title: "オーダーID",
          width: 0
        },
        {
          field: "facilityCd",
          hidden: true,
          locked: true,
          title: "施設コード",
          width: 0
        },
        {
          field: "patId",
          hidden: true,
          locked: true,
          title: "患者ID",
          width: 0
        },
        {
          field: "hospPatId",
          hidden: false,
          locked: true,
          title: "患者ID",
          width: "80"
        },
        {
          field: "patName",
          hidden: false,
          locked: true,
          title: "患者名",
          template: `<span class="#: inOutClass === 1 ? 'in_class_prescription' : '' #">#: patName # `
             + `# if(issame === 1){ # <img src="#: image_src_same #" class="pat-name-same-icon"> # } #</span>`,
          width: "80",
        },
        {
          field: "viewTreatDate",
          hidden: false,
          locked: true,
          title: "治療日付",
          width: "80",
        },
        {
          field: "indKurName",
          hidden: false,
          locked: true,
          title: "クール",
          width: "80",
        },
        {
          field: "indTreatmentName",
          hidden: false,
          locked: true,
          title: "治療方法",
          width: "80",
        }
    ]},
    //#9899:スケジュール割り当てで患者IDの列と同姓同名アイコンが表示されていない End
  },
  methods: {
    getScheduleGridRef() {
      return this.$refs.scheduleGrid || null;
    },
    getScheduleGridWidget() {
      return this.getScheduleGridRef()?.gridWidget?.() || this.getScheduleGridRef()?.kendoWidget?.() || null;
    },
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("status-map/modal", ["getOrderMainList", "setSelectOrdNo"]),
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      // モーダルのbodyの高さ
      const mb = getModalBodyElement(this.$el || this);
      const mh = mb ? mb.clientHeight : 0;
      // モーダルのヘッダの高さ
      const hElm = getScopedElementById("schedulemodal-header", this.$el || this);
      const hh = hElm ? hElm.clientHeight : 50;
      this.scheduleGridToolbarHeight = mh - hh;
      this.scheduleGridToolbarHeight =
        this.scheduleGridToolbarHeight < 300
          ? 300
          : this.scheduleGridToolbarHeight;
      this.scheduleGridHeight = this.scheduleGridToolbarHeight - 10;
    },
    // 登録完了通知
    gridDataLoad() {
      // 登録完了通知
      EventBus.$emit("dataUpdate");
    },
    /**
     * 確定ボタン
     */
    async saveChecklist() {
      // console.log(
      //   "saveCheckList/this.scheduleList.select is %o.",
      //   this.scheduleList.select
      //);

      this.setSelectOrdNo(this.selectedOrdNo);

      // モーダルを非表示に
      this.hideModal();

      // 登録完了通知
      this.gridDataLoad();
    },
    /**
     * キャンセルボタン
     */
    closeScheduleAssignmentModal() {
      // モーダルを非表示に
      this.hideModal();
    },
    /**
     * 行選択時の処理
     */
    onChangeGrid() {
      // 選択行取得
      const scheduleGrid = this.getScheduleGridWidget();
      const selRow = scheduleGrid?.select?.().closest("tr");
      // 選択行のデータ
      const rowData = scheduleGrid?.dataItem?.(selRow);
      this.selectedOrdNo = rowData.ordNo;
    },
    // 背景色セット
    editBackgroundColor() {
      this.$nextTick(() => {
        const scheduleGridRoot = resolveRefElement(this, "scheduleGrid");
        if (scheduleGridRoot) {
          let gridHeader = scheduleGridRoot.firstChild;
          if (gridHeader?.classList === undefined) {
            gridHeader = scheduleGridRoot.firstElementChild;
          }
          gridHeader?.classList?.add("master-grid-header");
        }
      });
    }
  },
  watch: {
    windowHeight() {
      this.calculateGridHeight();
    },
    isDispMenu() {
      this.calculateGridHeight();
    },
    getFontSize() {
      this.calculateGridHeight();
    }
  },

  updated() {
    // Storeの更新等で画面が再描画された場合に背景色を変更
    this.editBackgroundColor();

    this.editBackgroundColor();
  },
  mounted() {
    this.editBackgroundColor();
    // 選択されたordNoのスケジュール取得
    this.getOrderMainList();

    // 患者一覧情報取得
    // this.requestGetPatList();

    // 該当のスケジュール取得
    // this.requestGetScheduleList();

    this.$nextTick(() => {
      this.calculateGridHeight();
    });
    EventBus.$emit("showNotAssignedScheduleModal");
  },
  unmounted() {
    EventBus.$emit("hideNotAssignedScheduleModal");
  }
};
</script>
//#9899:スケジュール割り当てで患者IDの列と同姓同名アイコンが表示されていない Start
<style >
.in_class_prescription {
  color: #A356A3;
}
</style>
//#9899:スケジュール割り当てで患者IDの列と同姓同名アイコンが表示されていない End
<style scoped>
div.denial-btn-area {
  background: none;
}
div.registration-btn-area {
  background: none;
}
#schedule-grid :deep(.k-widget) {
  font-size: unset;
}
#schedule-grid :deep(.k-grid-content tr) {
  border-color: var(--master-maintenance-kgrid-border-color);
  color: var(--master-maintenance-kgrid-body-color);
  background-color: var(--master-maintenance-kgrid-item-background-color);
}
#schedule-grid :deep(.k-grid-content tr:nth-child(2n)) {
  background-color: var(--ntss-list-content-2nd-background-color);
}
#schedule-grid :deep(.k-grid tr.k-state-selected > td) {
  color: unset;
}
#schedule-grid :deep(.k-grid-content) {
  background-color: var(--ntss-base-background-color);
  color: var(--ntss-base-color);
}
#schedule-grid :deep(.k-grid-header) {
  background-color: var(--master-maintenance-kgrid-header-background-color);
  background-image: -webkit-linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%) !important;
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%) !important;
  border: solid 1px var(--ntss-list-border-color);
}
#schedule-grid :deep(.k-grid .k-table-th){
  border-color: #fff !important;
}
#schedule-grid :deep(.k-grid-header){
  background-image: linear-gradient(rgba(255, 255, 255, .3) 0%, transparent 50%, transparent 50%, rgba(0, 0, 0, .1) 100%);
  background-color: #333333;
}
</style>
