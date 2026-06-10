/**
 * スケジュール・患者割当モーダルPage
 */
 <template>
  <modal-base @onClose="closeScheduleAssignmentModal">
    <div slot="header">
      <component :is="header"></component>
    </div>
    <div slot="body">
      <!-- add FNSI-？？？？患者割り当て 徐 start -->
      <div v-if="isShowEditModal">
        <schedule-assignment-edit-modal @close="closeDetailView" @comserverNotification="comserverNotification"/>
      </div>
      <div v-if="!isShowEditModal">
      <!-- add FNSI-？？？？患者割り当て 徐 end -->
      <div id="schedulemodal-header">
        <div>
          <!-- 患者情報 -->
          <v-ons-row>
            <!-- ベッド名 -->
            <!-- 9694 mod ljx start -->
            <label class="pat-info" v-if="getSelectOrdMain">ベッド名：{{getSelectOrdMain.bedName}}</label>
            <!-- 9694 mod ljx end -->
          <!-- mod FNSI-？？？？患者割り当て 徐 start -->
          <!-- </v-ons-row>
          <v-ons-row> -->
            &emsp;
          <!-- mod FNSI-？？？？患者割り当て 徐 end -->
            <!-- 治療日 -->
            <!-- 9694 mod ljx start -->
            <label class="pat-info" v-if="getSelectOrdMain">治療日：{{getSelectOrdMain.viewTreatDate}}</label>
            <!-- 9694 mod ljx end -->
          <!-- mod FNSI-？？？？患者割り当て 徐 start -->
          <!-- </v-ons-row>
          <v-ons-row> -->
            &emsp;
          <!-- mod FNSI-？？？？患者割り当て 徐 end -->
            <!-- 透析時間 -->
            <!-- 9694 mod ljx start -->
            <label class="pat-info" v-if="getSelectOrdMain">透析時間：{{getSelectOrdMain.viewTreatTime}}</label>
            <!-- 9694 mod ljx end -->
          </v-ons-row>
        </div>

        <v-ons-row>
<!--
          <div class="ntss-button-group">
            <input
              type="radio"
              class="assign"
              name="assign"
              value="1"
              id="input-pat"
              @click="changeAssignment(true);"
              checked="checked"
            <label for="input-pat" class="label first-of-type">患者</label>
            <input
              type="radio"
              class="assign"
              name="assign"
              value="2"
              id="input-schedule"
              @click="changeAssignment(false);"
            />
            <label for="input-schedule" class="label last-of-type">スケジュール</label>
          </div>
-->
          <!-- mod FNSI-？？？？患者割り当て 徐 start -->
          <!--<div class="ntss-button-group">
            <input
              type="radio"
              class="assign"
              name="assign"
              value="2"
              id="input-schedule"
              @click="changeAssignment(false);"
              checked="checked"
            />
            <label for="input-schedule" class="label last-of-type">スケジュール</label>
          </div>-->
          <div class="ntss-button-group">
            <input
              type="radio"
              class="identification"
              name="assign"
              value="1"
              id="input-schedule"
              @click="changeModel(true);"
              :checked="isMode === true ? 'checked' : ''"
            />
            <label for="input-schedule" class="label first-of-type">スケジュール</label>
            <input
              type="radio"
              class="identification"
              name="assign"
              value="2"
              id="input-patient"
              @click="changeModel(false);"
              :checked="isMode === false ? 'checked' : ''"
            />
            <label for="input-patient" class="label last-of-type">患者名</label>
          </div>
          <!-- mod FNSI-？？？？患者割り当て 徐 end -->
        </v-ons-row>
      </div>


    <!-- Patient search -->
    <div v-if="isMode === false" id="schedulemodal-pat-search" class="pat-search d-flex flex-column">
      <div class="d-flex align-items-center">
        <label for="free-text-search" class="pat-search-label">フリーワード検索</label>
        <v-ons-input
          input-id="free-text-search"
          type="text"
          v-model.trim="freeText"
          v-on:keyup.enter="searchPatSimple"
          padder
        />
        <ons-button
          class="search-button common-style-ok-button button btn3-normal"
          style="margin-left: 0.5rem"
          @click="searchPatSimple"
          >検索</ons-button
        >
      </div>
    </div>
    <!-- / Patient search -->

      <!-- スケジュール/患者のグリッド -->
      <div id="schedule-grid">
        <!-- mod FNSI-？？？？患者割り当て 徐 start -->
        <!-- <kendo-grid
          :class="fontSizeSet"
          ref="scheduleGrid"
          :data-source="scheduleList"
          :editable="false"
          :reorderable="true"
          :resizable="true"
          :selectable="'row'"
          :height="scheduleGridHeight"
          :scrollable="true"
          :change="onClick"
        >
          <kendo-grid-column
            v-for="category in scheduleGridColumns"
            :key="category.length"
            :title="category.title"
            width="category.width"
            :field="category.field"
            :hidden="category.hidden"
            :locked="category.locked"
          ></kendo-grid-column> -->
        <kendo-grid
          :class="fontSizeSet"
          ref="scheduleGrid"
          :data-source="scheduleList"
          :editable="false"
          :reorderable="true"
          :resizable="true"
          :selectable="'row'"
          :height="scheduleGridHeight"
          :scrollable="true"
          :change="onClick"
          :filterable="false"
          :sortable="{ compare: compareByField }"
          :sort="sortHandler"
        >
        <!--<kendo-grid-column
            v-for="category in scheduleGridColumns"
            :key="category.length"
            :title="category.title"
            width="category.width"
            :field="category.field"
            :hidden="category.hidden"
            :locked="category.locked"
          ></kendo-grid-column> -->
          <kendo-grid-column :field="'ordNo'" :title="'ordNo'" width="0" :hidden="true"></kendo-grid-column>
          <!--mod FNSI-？？？？患者割り当て 陳 start-->
          <!--<kendo-grid-column :field="'patId'" :title="'患者ID'" width="80"></kendo-grid-column>-->
          <!-- mod 画面スタイル(ボタン)対応 陳 start -->
          <!--<kendo-grid-column :field="'hospPatId'" :title="'患者ID'" width="80"></kendo-grid-column>-->
          <kendo-grid-column :field="'hospPatId'" :title="'患者ID'" :header-attributes="{ 'class': 'gridHead' }" :attributes="{ class: 'hosp-pat-id-body' }" width="80"></kendo-grid-column>
          <!--add FNSI-？？？？患者割り当て 陳 end-->
          <!--<kendo-grid-column :field="'patName'" :title="'患者名'" width="80" :editable="() => false"></kendo-grid-column>-->
          <kendo-grid-column
            :field="'patName'"
            :title="'患者名'"
            :header-attributes="{ 'class': 'gridHead' }"
            width="80"
            :editable="() => false"
            :template="patNameTemplate">
          </kendo-grid-column>
          <!--<kendo-grid-column
            :field="'treatDate'"
            :title="'治療日'"
            width="80"
            :editable="() => false"
            :hidden="!isMode"
          ></kendo-grid-column>-->
          <kendo-grid-column
            :field="'treatDate'"
            :title="'治療日'"
            :header-attributes="{ 'class': 'gridHead' }"
            width="80"
            :editable="() => false"
            :hidden="!isMode"
          ></kendo-grid-column>
          <!--<kendo-grid-column
            :field="'kurName'"
            :title="'クール'"
            width="80"
            :editable="() => false"
            :hidden="!isMode"
          ></kendo-grid-column>-->
          <kendo-grid-column
            :field="'kurName'"
            :title="'クール'"
            :header-attributes="{ 'class': 'gridHead' }"
            width="80"
            :editable="() => false"
            :hidden="!isMode"
          ></kendo-grid-column>
          <!--<kendo-grid-column
            :field="'bedName'"
            :title="'ベッド名'"
            width="80"
            :editable="() => false"
            :hidden="!isMode"
          ></kendo-grid-column>-->
          <kendo-grid-column
            :field="'bedName'"
            :title="'ベッド名'"
            :header-attributes="{ 'class': 'gridHead' }"
            width="80"
            :editable="() => false"
            :hidden="!isMode"
          ></kendo-grid-column>
          <!-- mod 画面スタイル(ボタン)対応 陳 end -->
        <!-- mod FNSI-？？？？患者割り当て 徐 end -->
        </kendo-grid>
      </div>
      <!-- add FNSI-？？？？患者割り当て 徐 start -->
      </div>
      <!-- add FNSI-？？？？患者割り当て 徐 end -->
    </div>
    <div slot="footer" class="flex-container" v-if="!isShowEditModal">
      <div class="denial-btn-area" style="background:none">
        <!-- mod 画面スタイル(ボタン)対応 徐 start -->
        <!-- <button
          class="button denial-btn"
          @click="closeScheduleAssignmentModal"
        >キャンセル</button> -->
        <button
          class="button btn2-cancel"
          @click="closeScheduleAssignmentModal"
        >キャンセル</button>
        <!-- mod 画面スタイル(ボタン)対応 徐 end -->
      </div>
      <div class="registration-btn-area" style="background:none">
        <!-- mod FNSI-？？？？患者割り当て 徐 start -->
        <!-- <button
          class="button registration-btn"
          @click="saveChecklist"
          :disabled="disabledState"
        >確定</button> -->
        <!-- mod 画面スタイル(ボタン)対応 徐 start -->
        <!-- <button
          class="button registration-btn"
          @click="saveChecklist"
          :disabled="disabledState"
          v-show="isMode"
        >割り当て</button>
        <button
          class="button"
          @click="showEditModal"
          :disabled="disabledState"
          v-show="!isMode"
        >予定作成に進む</button> -->
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <button -->
        <!--   class="button registration-btn btn1-execute" -->
        <!--   @click="saveChecklist" -->
        <!--   :disabled="disabledState" -->
        <!--   v-show="isMode" -->
        <!-- >割り当て</button> -->
        <!-- <button -->
        <!--   class="button btn3-normal" -->
        <!--   @click="showEditModal" -->
        <!--   :disabled="disabledState" -->
        <!--   v-show="!isMode" -->
        <!-- >予定作成に進む</button> -->
        <button
          class="button registration-btn btn1-execute"
          @click="saveChecklist"
          :disabled="disabledState || !getItemAuthorized('StatusListMap', 'item_list_assignment')"
          v-show="isMode"
        >割り当て</button>
        <button
          class="button btn3-normal"
          @click="showEditModal"
          :disabled="disabledState || !getItemAuthorized('StatusListMap', 'item_list_schedule')"
          v-show="!isMode"
        >予定作成に進む</button>
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
        <!-- mod 画面スタイル(ボタン)対応 徐 end -->
        <!-- mod FNSI-？？？？患者割り当て 徐 end -->
      </div>
    </div>
  </modal-base>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import moment from "moment";
import Kendo from "@progress/kendo-ui";
import ModalBase from "@/components/modals/ModalBase";
import ScheduleAssignmentEditModal from "@/components/schedule-assignment/ScheduleAssignmentEditModal";
import { mapGetters, mapActions} from "vuex";
import { EventBus } from "@/eventBus.js";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import IndUserSelectMixin from "@/components/common/IndUserSelectMixin";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
// add 10443 身体情報・DW・目標体重バグ 関  start
import {sendRequestFindPhysicalInfo} from "@/apis/pat-viewer";
// add 10443 身体情報・DW・目標体重バグ 関  end
import { sortableCompare } from "@/functions/SortFunctions";

export default {
  name: "ScheduleAssignmentModal",
  mixins: [MasterMaintenanceMixin, IndUserSelectMixin],
  components: {
    // mod FNSI-？？？？患者割り当て 徐 start
    // "modal-base": ModalBase
    "modal-base": ModalBase,
    "schedule-assignment-edit-modal": ScheduleAssignmentEditModal,
    // mod FNSI-？？？？患者割り当て 徐 end
  },
  props: {
    settingData: {
      type: Object,
      default: () => ({
        headerTitle: {
          type: String
        },
        segmentLabel1: {
          type: String
        },
        segmentLabel2: {
          type: String
        },
        segmentLabel3: {
          type: String
        },
        segmentLabel4: {
          type: String
        },
        segmentLabel5: {
          type: String
        },
        facilityCd: {
          type: String,
          required: true
        },
        ordNo: {
          type: String,
          default: null
        },
        patId: {
          type: String,
          required: true
        },
        patName: {
          type: String,
          required: true
        },
        bedName: {
          type: String,
          required: true
        },
        startDate: {
          type: String,
          default: "2018-01-01"
        },
        endDate: {
          type: String,
          default: ""
        },
        showSegment: {
          type: Boolean,
          default: true
        },
        showNewEdit: {
          type: Boolean
        },
        showDelete: {
          type: Boolean,
          default: false
        },
        showWeeks: {
          type: Boolean,
          default: true
        },
        showKur: {
          type: Boolean,
          default: false
        },
        showTreat: {
          type: Boolean,
          default: false
        },
        allWeek: {
          type: Boolean,
          default: false
        },
        monday: {
          type: Boolean,
          default: false
        },
        tuesday: {
          type: Boolean,
          default: false
        },
        wednesday: {
          type: Boolean,
          default: false
        },
        thursday: {
          type: Boolean,
          default: false
        },
        friday: {
          type: Boolean,
          default: false
        },
        saturday: {
          type: Boolean,
          default: false
        },
        sunday: {
          type: Boolean,
          default: false
        },
        hrOnder: {
          type: Boolean,
          default: true
        },
        hrUnder: {
          type: Boolean,
          default: true
        },
        startDateEdit: {
          type: Boolean,
          default: false
        },
        endDateEdit: {
          type: Boolean,
          default: false
        },
        disIndUserEdit: {
          default: false,
          type: Boolean
        }
      })
    },
    /**
     * モーダル表示フラグ
     */
    modalVisible: {
      type: Boolean,
      default: false
    },
    /**
     * コンポーネントID
     */
    componentId: {
      type: String,
      default: null
    }
  },
  data() {
    return {
      structData: {
        //    add FNSI redmine 劉祥霖 5923 start
        bedcd:"",
        //    add FNSI redmine 劉祥霖 5923 end
        patId: this.settingData.patId,
        patName: this.settingData.patName,
        bedName: this.settingData.bedName,
        indStartDate: this.settingData.startDate,
        indEndDate: this.settingData.endDate,
        indWeeks: [
          {
            text: "全",
            done: this.settingData.allWeek,
            value: 0
          },
          {
            text: "月",
            done: this.settingData.monday,
            value: 1
          },
          {
            text: "火",
            done: this.settingData.tuesday,
            value: 2
          },
          {
            text: "水",
            done: this.settingData.wednesday,
            value: 3
          },
          {
            text: "木",
            done: this.settingData.thursday,
            value: 4
          },
          {
            text: "金",
            done: this.settingData.friday,
            value: 5
          },
          {
            text: "土",
            done: this.settingData.saturday,
            value: 6
          },
          {
            text: "日",
            done: this.settingData.sunday,
            value: 7
          }
        ],
        facilityCd: this.settingData.facilityCd,
        selectedKur: [],
        kurOptions: [],
        selectedTreat: [],
        treatOptions: [],
        /**
         * 治療方法リストの初期値
         */
        initTreatOptions: [],
        indUser: null,
        userOptions: [],
        kakujituWeeks: [
          {
            text: "全",
            done: false,
            value: 0
          },
          {
            text: "月・火",
            done: false,
            value: 1
          },
          {
            text: "水・木",
            done: false,
            value: 2
          },
          {
            text: "金・土",
            done: false,
            value: 3
          },
          {
            text: "日",
            done: false,
            value: 4
          }
        ],
        cycleWeek: "0",
        isDeadline: true,
        // 治療種別を表示フラグ(予定作成で使用)
        isShowTreatType: this.settingData.showSegment,
        // 警告受け入れフラグ(予定作成で使用)
        acceptWarnFlag: false
      },
      main: "",
      header: "",
      // add FNSI-？？？？患者割り当て 徐 start
      isShowEditModal: false,
      // add FNSI-？？？？患者割り当て 徐 end
      scheduleGridToolbarHeight: 500,
      scheduleGridHeight: 300,
      // add FNSI-？？？？患者割り当て 徐 start
      isMode: true,
      // add FNSI-？？？？患者割り当て 徐 end
      selRowIndex: null,
      //同姓同名アイコン
      image_src_same: require('../../assets/name_duplication.png'),
      freeText: "",
      currentSort: null
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    //施設コード取得用
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("schedule-assignment/modal", [
      "getScheduleColumn",
      "getAssignmentFlag",
      "getSelectOrdMain",
      "getPatlist",
      "getSchedulelist",
      "getRequestData",
      "getStructData",
      "getDisabledButton"
    ]),
    // グリッド表示用データ
    scheduleList() {
      if (this.getAssignmentFlag) {
        // 患者
        // storeからデータを取得
        return new Kendo.data.DataSource({
          data: this.getPatlist
        });
      } else {
        // スケジュール
        // storeからデータを取得
        return new Kendo.data.DataSource({
          data: this.getSchedulelist
        });
      }
    },
    scheduleGridColumns() {
      return this.getScheduleColumn;
    },
    // add FNSI-？？？？患者割り当て 徐 start
    /**
     * 「登録」ボタン非表示状態
     */
    hiddenState() {
      return this.isMode;
    },
    hiddenState1() {
      return this.isMode;
    },
    // add FNSI-？？？？患者割り当て 徐 end
    /**
     * 「登録」ボタン活性状態
     */
    disabledState() {
      return this.getDisabledButton;
    }
  },
  methods: {
    // mod FNSI-？？？？患者割り当てtitle名不正 付 start
    // ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("multi-modal", ["showSchedule", "hideModal"]),
    // mod FNSI-？？？？患者割り当てtitle名不正 付 end
    ...mapActions("schedule-assignment/modal", [
      "changeAssignmentFlag",
      "setScheduleColumn",
      "getOrderMainListByOrdNo",
      "requestGetPatList",
      "searchPatList",
      "requestGetScheduleList",
      "setPatAssignment",
      "notificationPatAssignment",
      "setScheduleAssignment",
      "setStructData",
      "setDisabledButton"
    ]),
    // add FNSI redmine 6706 劉祥霖 start
    ...mapActions("treatment-record/common", ["getMstMachineByOrdNoRst", "sendGetNoticeMedi"]),
    ...mapActions("treatment-record/mediInfo", {
      sendRequestChangeIndMediInfoRst: "sendRequestChangeIndMediIn",
    }),
    // add FNSI redmine 6706 劉祥霖 end
    //患者ID取得用
    ...mapActions("pat-info", [
      "selectPat"
    ]),
    // add 10443 身体情報・DW・目標体重バグ 関  start
    ...mapActions("pat-viewer", ["setPhysicalInfo"]),
    // add 10443 身体情報・DW・目標体重バグ 関  end
    
    /**
     * 列ヘッダクリック時にソート順を設定
     * @param {*} e 
     */
    sortHandler(e) {
      this.currentSort = e.sort;
      
      // 行選択解除
      this.clearSelect();
    },
    /**
     * 列ヘッダクリック時のソート処理
     * @param {*} a 
     * @param {*} b 
     */
    compareByField(a, b) {
      // ソートなしはreturn
      if (!this.currentSort || !this.currentSort.field) return;
      // 治療日の場合は逆順 *降順*→昇順→ソートなし
　　　// ※前日のデータも対象に表示する仕様のため、降順として本日のデータが優先に出るようにします。ソートマークはスタイル指定で対応  
      return sortableCompare(a, b, this.currentSort.field, true, { reverseFields: ["treatDate"] });
    },
    // Windowの高さからGirdコンポーネント領域の高さを算出
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    calculateGridHeight() {
      // モーダルのbodyの高さ
      const mb = document.getElementsByClassName("modal-body")[0];
      const mh = mb ? mb.clientHeight : 0;
      // モーダルのヘッダの高さ
      const hElm = document.getElementById("schedulemodal-header");
      const hh = hElm ? hElm.clientHeight : 0;
      const sElm = document.getElementById("schedulemodal-pat-search");
      const sh = sElm ? sElm.clientHeight : 0;
      this.scheduleGridToolbarHeight = mh - hh - sh;
      this.scheduleGridToolbarHeight =
        this.scheduleGridToolbarHeight < 300
          ? 300
          : this.scheduleGridToolbarHeight;
      this.scheduleGridHeight = this.scheduleGridToolbarHeight;
      // add FNSI-？？？？患者割り当て 陳 start
      if (mh + hh === 0) {
          setTimeout(this.calculateGridHeight, 10);
      }
      // add FNSI-？？？？患者割り当て 陳 end
    },
    // 患者/スケジュールの表示切替を変更
    changeAssignment(displayNameFlag) {
      // 選択行クリア
      this.selRowIndex = null;

      // クール/ベッド名の表示/非表示
      let colsetting = this.getScheduleColumn;
      colsetting[4].hidden = displayNameFlag;
      colsetting[5].hidden = displayNameFlag;
      // add FNSI-？？？？患者割り当て 徐 start
      colsetting[6].hidden = displayNameFlag;
      // add FNSI-？？？？患者割り当て 徐 end
      let colsize = "6em";
      if (displayNameFlag) {
        colsize = "12em";
      }
      colsetting[2].width = colsize;
      colsetting[3].width = colsize;
      this.setScheduleColumn(colsetting);

      this.changeAssignmentFlag(displayNameFlag);
    },
    // グリッドクリック時
    onClick(event) {
      if (event.sender) {
        // 選択行取得
        this.selRowIndex = this.$refs.scheduleGrid
          .kendoWidget()
          .select()
          .index();

        // 選択時のみ
        if (this.selRowIndex > -1) {
          const selrow = this.$refs.scheduleGrid
            .kendoWidget()
            .select()
            .closest("tr");
          // 選択情報
          // 患者ID
          this.selPatId = this.$refs.scheduleGrid
            .kendoWidget()
            .dataItem(selrow).patId;
          // ordNo
          this.selOrdNo = this.$refs.scheduleGrid
            .kendoWidget()
            .dataItem(selrow).ordNo;

          // 「登録」ボタン活性
          this.setDisabledButton( false );
        }
      }
    },
    // 登録完了通知
    gridDataLoad() {
      // 登録完了通知
      //EventBus.$emit("dataUpdate");
    },
    // 確定ボタン
    async saveChecklist() {

      // 「登録」ボタン非活性
      this.setDisabledButton( true );

      if (this.getAssignmentFlag) {
        // 患者割当の場合
        this.setPatAssignment(this.selPatId).then(res => {
          if (res.result === false) {
            // エラーメッセージ表示
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "患者割当失敗",
              title: DIALOG_MESSAGES["00300021"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: res.message
            });
          } else {
            // 通信サーバ通知処理
            this.comserverNotification();
          }
        });
      } else {

        // add FNSI-？？？？患者割り当て 陳 start
        await this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "？？？？患者スケジュール割り当て",
          title: DIALOG_MESSAGES[13000120].title,
          // message:
          //   "？？？？患者治療データに選択した患者のスケジュールを割り当てます。</br>実行すると元に戻すことができません。</br>実行してよろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000120].message),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer == 1) {
        // add FNSI-？？？？患者割り当て 陳 end

              // スケジュール割り当ての場合
              this.setScheduleAssignment({
              selOrdNo : this.selOrdNo,
              rstInputClass : 3
              }).then(res => {
                if (res.result === false) {
                  // エラーメッセージ表示
                  this.$ons.notification.alert({
                    // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                    // title: "スケジュール割当失敗",
                    title: DIALOG_MESSAGES["00300022"].title,
                    // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                    message: res.message
                  });
                  // 「登録」ボタン活性
                  this.setDisabledButton( false );
                } else {
                  // 通信サーバ通知処理
                  this.comserverNotification();
                  //del 9353 ????患者から患者を割り付けると投与薬剤のお知らせが働かない zhao start
                  // add FNSI redmine 6706 劉祥霖 start
                  //add FNSI redmine 6706 劉祥霖 start 追加再修正：？？？？患者予定部分に投薬がないと通知しない
                  // if(res.sendMediNoticeFlag ==true) {
                  // //add FNSI redmine 6706 劉祥霖 start 追加再修正：？？？？患者予定部分に投薬がないと通知しない
                  //   this.sendGetNoticeMedi(this.selOrdNo).then(results => {
                  //     if (results.data == true) {
                  //       this.getMstMachineByOrdNoRst(this.selOrdNo).then(machineRes => {
                  //         const params = {
                  //           ordNo: this.selOrdNo, //オーダー番号
                  //           machineNo: machineRes.data[0].machineNo, //装置マスタ.装置番号
                  //           deviceEdgeNo: machineRes.data[0].deviceEdgeNo, //デバイスエッジ番号
                  //           facilityCd: this.facilityCd //施設コード
                  //         };
                  //         // mod #8347 【デグレ】????患者治療割り当てができない dou start
                  //         // try {
                  //         //   this.sendRequestChangeIndMediInfoRst(params);
                  //         // } catch (e) {
                  //         //   //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
                  //         //   getErrorMessage('ScheduleAssignmentModalStore.js', 'setScheduleAssignment', '装置へ送信に失敗しました。');
                  //         //   //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
                  //         //   this.$ons.notification.alert({
                  //         //     modifier: "warn",
                  //         //     title: "送信に失敗しました",
                  //         //     message: `装置へ送信に失敗しました。`
                  //         //   });
                  //         // }
                  //         this.sendRequestChangeIndMediInfoRst(params).catch(err => {
                  //           getErrorMessage('ScheduleAssignmentModal.vue', 'sendRequestChangeIndMediInfoRst', err);
                  //           this.$ons.notification.alert({
                  //             modifier: "warn",
                  //             // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  //             // title: "装置へ送信に失敗しました",
                  //             // message: `投薬指示変更指示送信に失敗しました。`
                  //             title: DIALOG_MESSAGES[12000215].title,
                  //             message: messageFormat(DIALOG_MESSAGES[12000215].message)
                  //             // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                  //           });
                  //         });
                  //         // mod #8347 【デグレ】????患者治療割り当てができない dou end
                  //       });
                  //     }
                  //   });
                  // }
                  // add FNSI redmine 6706 劉祥霖 end
                  //del 9353 ????患者から患者を割り付けると投与薬剤のお知らせが働かない zhao end
                }
              });
            // add FNSI-？？？？患者割り当て 陳 start
            }
          }
          // add FNSI-？？？？患者割り当て 陳 end
        });
      }
    },
    // add FNSI-？？？？患者割り当て 徐 start
    async changeModel(displayFlag) {
      this.isMode = displayFlag;
      this.changeAssignmentFlag(!displayFlag);
      this.changeAssignment(!displayFlag);
      // mod FNSI-？？？？患者割り当てtitle名不正 陳 start
      // add FNSI-？？？？患者割り当てtitle名不正 付 start
      // if (displayFlag) {
        // this.showSchedule({title :"スケジュール割り当て"});
        this.showSchedule({title :"？？？？患者治療割り当て"});
      // } else {
      //   this.showSchedule({title :"患者名割り当て"})
      // }
      // add FNSI-？？？？患者割り当てtitle名不正 付 end
      // 行選択解除
      this.clearSelect();
      // mod FNSI-？？？？患者割り当てtitle名不正 陳 end
      this.$nextTick(() => {
        this.calculateGridHeight();
      });
    },
    async showEditModal() {
      // ソート後のリスト取得
      const sortedPatList = this.scheduleList.view();
      
      this.structData.indStartDate = moment(this.getSelectOrdMain.viewTreatDate).format("YYYY-MM-DD");  // 治療開始日時

      this.structData.facilityCd = sortedPatList[this.selRowIndex].facilityCd;
      //add FNSI redmine 5923 start
      this.structData.hospPatId = sortedPatList[this.selRowIndex].hospPatId;
      //add FNSI redmine 5923 end
      this.structData.patId = sortedPatList[this.selRowIndex].patId;
      this.structData.patName = sortedPatList[this.selRowIndex].patName;
      this.structData.bedName = this.getSelectOrdMain.bedName;

      // add FNSI 373,374修正対応 陳 start
      this.structData.bedCd = this.getSelectOrdMain.bedCd;
      // add FNSI 373,374修正対応 陳 end

      this.selectPat(sortedPatList[this.selRowIndex].patId);

      this.setStructData(this.structData);
      // add 10443 身体情報・DW・目標体重バグ 関  start
      // 患者身体情報も取得
      let physical = [];
      if (this.structData.patId) {
        physical = await sendRequestFindPhysicalInfo(this.structData.patId).catch(err => {
          throw err;
        });
      }
      this.setPhysicalInfo(physical.data);
      // add 10443 身体情報・DW・目標体重バグ 関  end
      setTimeout(() => {
        this.isShowEditModal = true;
      }, 800);
    },
    closeDetailView() {
      this.isShowEditModal = false;
    },
    patNameTemplate(rowData) {
      if (this.isMode) {
        // 表示がスケジュールの時は、該当の患者データを取得する
        const patObj = this.getPatlist.find(obj => obj.patId == rowData.patId);
        if (patObj) {
          rowData["is_same"] = patObj.is_same;
          rowData["in_out_class"] = patObj.in_out_class;
        }
      }
      let rtn = "";
      let inOutColor = rowData.in_out_class == 1 ? "color: #A356A3" : "";
      if(rowData.is_same === "1") {
        rtn = `<div style="word-break: break-all;${inOutColor}">${rowData.patName}<img name="icon" src="${this.image_src_same}" style="height: 20px; margin-left: 5px;"/></div>`;
      } else {
        rtn = `<div style="word-break: break-all;${inOutColor}">${rowData.patName}</div>`;
      }
      return rtn;
    },
    // 通信サーバ通知処理
    comserverNotification() {
      this.notificationPatAssignment().then(notires => {
        if (notires.result === false) {
          // 通知失敗
          // 確認のダイアログを表示する
          this.$ons.notification.confirm({
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
            // title: "割当通知失敗",
            title: DIALOG_MESSAGES[13000121].title,
            // message: "通信サーバーへの通知に失敗しました。<br>再通知しますか？",
            message: messageFormat(DIALOG_MESSAGES[13000121].message),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer === 0) {
                // キャンセル
                // 登録完了通知
                this.gridDataLoad();
                // モーダルを非表示に
                this.hideModal();

                // スケジュール割当後の治療記録への遷移
                EventBus.$emit("ScheduleAssignment", {
                  patId: this.getRequestData.patId,
                  ordNo: this.getRequestData.ordNo
                } );
              } else if (answer === 1) {
                // 再通知
                this.comserverNotification();
              }
            }
          });
        } else {
          // 通知成功
          // 登録完了通知
          this.gridDataLoad();

          // mod FNSI-？？？？患者割り当て 陳 start
          //// モーダルを非表示に
          //this.hideModal();

          // // スケジュール割当後の治療記録への遷移
          // EventBus.$emit("ScheduleAssignment", {
          //   patId: this.getRequestData.patId,
          //   ordNo: this.getRequestData.ordNo
          // } );

          // 割り当て完了メッセージ表示
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "割り当て完了",
            // message: "？？？？患者治療データに割り当てが完了しました。</br>投与薬剤や医療材料がマージされているため治療記録を確認してください。"
            title: DIALOG_MESSAGES[12000216].title,
            message: messageFormat(DIALOG_MESSAGES[12000216].message)
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });

          // モーダルを非表示に
          this.hideModal();
          // mod FNSI-？？？？患者割り当て 陳 end
        }
      });
    },
    // キャンセルボタン
    closeScheduleAssignmentModal() {
      // モーダルを非表示に
      this.hideModal();
    },
    // 背景色セット
    editBackgroundColor() {
      this.$nextTick(() => {
        if (this.$refs.scheduleGrid) {
          let gridHeader = this.$refs.scheduleGrid.$el.firstChild;
          if (gridHeader.classList === undefined) {
            gridHeader = this.$refs.scheduleGrid.$el.firstElementChild;
          }
          gridHeader?.classList?.add("master-grid-header");
        }
      });
    },
    searchPatSimple() {
      this.searchPatList(this.freeText);
      // 行選択解除
      this.clearSelect();
    },
    /**
     * 行選択解除
     */
    clearSelect() {
      // 行選択解除
      this.selRowIndex = null;
      this.selPatId = null;
      this.selOrdNo = null;
      // ボタン非活性
      this.setDisabledButton( true );
    },
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
  },
  async mounted() {
    // 「登録」ボタン非活性
    this.setDisabledButton( true );
    // 選択されたordNoのスケジュール取得
    await this.getOrderMainListByOrdNo();
    // 患者一覧情報取得
    await this.requestGetPatList();
    // 該当のスケジュール取得
    await this.requestGetScheduleList();
    // 初期表示
    await this.changeAssignment(this.getAssignmentFlag);
    // 背景色セット
    await this.editBackgroundColor();
    await this.$nextTick(() => {
      this.calculateGridHeight();
    });
    EventBus.$emit("showScheduleAssignmentModal");
    
    // 画面印刷時のイベント追加
    // gridがスクロール可だと、tableがヘッダとボディで分断され、cssで全ページに表ヘッダ付与できない
    this.handleBeforePrint = () => {
      // スクロール解除
      const grid = this.$refs.scheduleGrid?.kendoWidget();
      if (!grid) return;
      
      grid.setOptions({
        scrollable: false
      });
      // setOptionsするとgridの選択行解除されるため、保持している選択値もクリア
      this.clearSelect();
    };
    this.handleAfterPrint = () => {
      // スクロール設定
      const grid = this.$refs.scheduleGrid?.kendoWidget();
      if (!grid) return;
      
      grid.setOptions({
        scrollable: true
      });
      // setOptionsするとgridの選択行解除されるため、保持している選択値もクリア
      this.clearSelect();
    };
    window.addEventListener("beforeprint", this.handleBeforePrint);
    window.addEventListener("afterprint", this.handleAfterPrint);   
  },
  beforeDestroy() {
    window.removeEventListener("beforeprint", this.handleBeforePrint);
    window.removeEventListener("afterprint", this.handleAfterPrint);
  },
  destroyed() {
    EventBus.$emit("hideScheduleAssignmentModal");
  }
};
</script>

<style scoped>
input[type="radio"] {
  display: none; /* ラジオボタンを非表示にする */
}
/* add #9319  文字サイズの設定とは異なるサイズ表示される画面がある fangyiming start */
.k-widget {
  font-size: unset;
}
/* add #9319  文字サイズの設定とは異なるサイズ表示される画面がある fangyiming end */
/* ボタングループのスタイル定義 */
/*mod FutreNetWeb+SI課題管理No5109対応 于 start*/
.ntss-button-group {
  width: 100%;
  display: flex;
  flex-flow: nowrap;
  align-items: center;
  height: 2.5em;
}
/*mod FutreNetWeb+SI課題管理No5109対応 于 end*/

.label {
  display: block; /* ブロックレベル要素化する */
  float: left; /* 要素の左寄せ・回り込を指定する */
  width: 30%; /* ボックスの横幅を指定する */
  height: 2em; /* ボックスの高さを指定する */
  padding-left: 5px; /* ボックス内左側の余白を指定する */
  padding-right: 5px; /* ボックス内御右側の余白を指定する */
  color: #ffffff; /* フォントの色を指定する */
  text-align: center; /* テキストのセンタリングを指定する */
  line-height: 2em; /* 行の高さを指定する */
  cursor: pointer; /* マウスカーソルの形（リンクカーソル）を指定する */
  margin: 15px 0px;
  white-space: nowrap;
}
/*mod FutreNetWeb+SI課題管理No5109対応 于 start*/
.first-of-type {
  border-radius: 10px 0 0 10px;
  margin: 0;
  min-width: 7em;
}
.last-of-type {
  border-radius: 0 10px 10px 0;
  margin: 0;
  min-width: 7em;
}
/*mod FutreNetWeb+SI課題管理No5109対応 于 end*/
#schedulemodal-header {
  margin-left: 5px;
}
#schedule-grid >>> .k-grid .k-grid-content tr {
  border-color: var(--master-maintenance-kgrid-border-color);
  color: var(--master-maintenance-kgrid-body-color);
  background-color: var(--master-maintenance-kgrid-item-background-color);
}
#schedule-grid >>> .k-grid .k-grid-content tr:nth-child(2n) {
  background-color: var(--ntss-list-content-2nd-background-color);
}
#schedule-grid >>> .k-grid tr.k-state-selected > td {
  color: unset;
}
#schedule-grid >>> .k-grid-content {
  background-color: var(--ntss-base-background-color);
  color: var(--ntss-base-color);
}

.pat-search > div {
  margin: 0.5em;
}
.pat-search .title {
  color: #fff;
  padding: 4px;
  background-color: var(--ntss-list-header-background-color);
  font-weight: 100;
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
.pat-search ons-button.detailed-search {
  border-radius: 0;
  background-color: var(--ntss-btn-ok-background-color);
  padding-top: 2px;
  padding-bottom: 2px;
  font-size: 1em;
}
.pat-search-label {
  margin-right: 0.4em;
  white-space: nowrap;
}
#schedule-grid >>> .k-i-sort-asc-sm::before {
  content: "▲" !important;
  color: #ffffff;
}
#schedule-grid >>> .k-i-sort-desc-sm::before {
  content: "▼" !important;
  color: #ffffff;
}
/* 治療日は昇順アイコンを強制的に「降順」に見せる */
#schedule-grid >>> th[data-field="treatDate"] .k-i-sort-asc-sm::before {
  content: "▼" !important;
  color: #ffffff;
}
/* 治療日は降順アイコンを強制的に「昇順」に見せる */
#schedule-grid >>> th[data-field="treatDate"] .k-i-sort-desc-sm::before {
  content: "▲" !important;
  color: #ffffff;
}
@media print {
  /** モーダル高さ確保 */
  .modal-mask >>> div {
    height: auto !important;
  }
  /** レイアウト崩れ防止 */
  div >>> .modal-wrapper:has(.indInfo-style-modal-container) {
    display: inline-block !important;
    width: 100%;
  }
  #schedule-grid >>> .k-grid .k-grid-header {
    padding-right: 0 !important;
  }
  /** 表ヘッダー全ページに付与 */
  #schedule-grid >>> .k-grid thead {
    display: table-header-group !important;
  }
  /** はみ出し防止 */
  #schedule-grid >>> .k-grid,
  #schedule-grid >>> .k-grid-content {
    width: 100% !important;
    overflow: visible !important;
  }
  /** 横幅をページ内に強制収める */
  #schedule-grid >>> .k-grid table {
    width: 100% !important;
    table-layout: fixed !important;
  }
  /** colgroupの固定幅を辞める */
  #schedule-grid >>> col {
    width: auto !important;
  }
  /** 文字折り返す */
  #schedule-grid >>> td,
  #schedule-grid >>> th {
    white-space: normal !important;
    word-break: break-word;
  }
}
</style>
