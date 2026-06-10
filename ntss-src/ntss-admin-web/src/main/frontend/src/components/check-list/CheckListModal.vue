/**
 * チェックリストモーダルPage
 */
 <template>
  <modal-base @onClose="closeCheckListModal">
    <div slot="header">
      <component :is="header"></component>
    </div>
    <!-- mod FNSI-redmine_#3904_グリッド表示を修正 周 start -->
    <!-- <div slot="body"> -->
    <div slot="body" class="master-maintenance-page">
    <!-- mod FNSI-redmine_#3904_グリッド表示を修正 周 end -->
      <div id="checklist-modal-header">
        <!-- 患者情報 -->
        <v-ons-row>
          <v-ons-col>
            <!-- 患者名 -->
            <label class="pat-info">{{displayInfo.patName}}</label>
          </v-ons-col>
          <v-ons-col>
            <!-- 治療状況 -->
            <label
              class="treat-state state-send"
              v-if="displayInfo.rstDialysisState === '1' || displayInfo.rstDialysisState === '2'"
            >条件送信済み</label>
            <label class="treat-state state-treat" v-if="displayInfo.rstDialysisState === '3'">治療中</label>
            <label
              class="treat-state state-treat-end"
              v-if="displayInfo.rstDialysisState === '4' || displayInfo.rstDialysisState === '5'"
            >治療終了</label>
            <label class="treat-state state-end" v-if="displayInfo.rstDialysisState === '6'">実績確定</label>
          </v-ons-col>
          <v-ons-col>
            <!-- チェック済項目数/チェック項目数 -->
            <label
              class="pat-info"
            >{{displayInfo.checkedItemCount}}/{{displayInfo.checklistItemCount}}</label>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col>
            <!-- 治療日 -->
            <label class="pat-info">{{displayInfo.viewTreatDate}}</label>
          </v-ons-col>
          <v-ons-col>
            <!-- クール -->
            <label class="pat-info">{{displayInfo.kurName}}</label>
          </v-ons-col>
          <v-ons-col>
            <!-- ベッド名 -->
            <label class="pat-info">{{displayInfo.bedName}}</label>
          </v-ons-col>
        </v-ons-row>
      </div>

      <!-- mod FNSI-redmine_#3904_グリッド表示を修正 周 start -->
      <!-- <div modal-body class="grid-content-area"> -->
      <div modal-body class="grid-content-area k-grid">
      <!-- mod FNSI-redmine_#3904_グリッド表示を修正 周 end -->
        <!-- チェックリストのグリッド -->
        <table class="checklist-modal-list custom-checklist-modal-list" :style="{ 'top':tableTop + 'px' }">
          <thead>
            <tr>
              <!--mod #6853-チェックボックス、実施者の選択ボタンがヘッダーの前面に表示される 徐博 start-->
              <!--<th id="column-01" class="ntss-list-header-th-sticky">実施</th>-->
              <th id="column-01" class="ntss-list-header-th-sticky" style="z-index: 999">実施</th>
              <!--mod #6853-チェックボックス、実施者の選択ボタンがヘッダーの前面に表示される 徐博 end-->
              <th
                v-for="(column, idx) in columns"
                :key="column.key"
                :id="'column-0' + (idx + 2)"
                class="ntss-list-header-th-sticky"
              >{{ column.colName }}</th>
              <!--#9226:チェックリストで画面で実施者を変更すると実施時刻がクリアされる。Start　-->
              <th id="column-05" class="ntss-list-header-th-sticky" style="z-index: 999">時刻</th>
              <!--#9226:チェックリストで画面で実施者を変更すると実施時刻がクリアされる。End　-->
              <!--mod #6853-チェックボックス、実施者の選択ボタンがヘッダーの前面に表示される 徐博 start-->
              <!--<th id="column-06" class="ntss-list-header-th-sticky">実施者</th>-->
              <th id="column-06" class="ntss-list-header-th-sticky" style="z-index: 999">実施者</th>
              <!--mod #6853-チェックボックス、実施者の選択ボタンがヘッダーの前面に表示される 徐博 end-->
            </tr>
          </thead>
          <tr
            v-for="(checkData, idx) in displayCheckList"
            :key="idx"
            :class="'checklist-modal-row'"
            style="height: 4rem;"
          >
          <!-- mod #11065 【03】編集権限バグ修正 関 start -->
            <td class="ntss-list-body-td" @click="onClickRow(checkData)">
              <v-ons-checkbox
                :input-id="'checkbox-' + idx"
                v-model="checkData.check"
                :disabled="!editState || !getItemAuthorized('CheckList', 'default_authority')"
              ></v-ons-checkbox>
            </td>
            <td
              v-for="column in columns"
              class="ntss-list-body-td"
              :key="column.className"
              style="text-align: left;"
              @click="onClickRow(checkData)"
            >{{ column.text(checkData) }}</td>
            <!--#9226:チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 Start -->
            <td class="ntss-list-body-td">
            <!--#10715:日付IF修正Start（必須追加+param修正）-->
            <date-input
                class="ntss-input-date"
                :classes="'input-area ntss-input-date ntss-custom-input ntss-input-start-date date-input-required '"
                v-model="checkData.viewDate"
                @handleClearInput="checkData.viewDate = null"
                v-show="checkData.check"
                :disabled="!editState || !getItemAuthorized('CheckList', 'default_authority')"
                :isRequired="true"
                @change="onChangeDate(checkData, idx)"
            />
            <!--#10715:日付IF修正End（必須追加+param修正+param修正）-->
            <common-calendar
                v-model="checkData.viewDate"
                v-show="checkData.check"
                :disabled="!editState || !getItemAuthorized('CheckList', 'default_authority')"
                @input="onChangeDate(checkData, idx)"
            />
            <!--#10715:日付IF修正Start（必須追加+param修正）-->
            <time-input
                class="occurs_date_time"
                v-model="checkData.viewtime"
                @handleClearInput="checkData.viewtime = null"
                v-show="checkData.check"
                :disabled="!editState || !getItemAuthorized('CheckList', 'default_authority')"
                :isRequired="true"
                :classes="'time-input-required '"
                @change="onChangeDate(checkData, idx)"
            />
            <!--#10715:日付IF修正End（必須追加+param修正）-->
            </td>
            <!--#9226:チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 End -->
            <td class="ntss-list-body-td">
              <com-master-selector
                v-show="checkData.check"
                :isDisabled="!editState || !getItemAuthorized('CheckList', 'default_authority')"
                select-id="user_id"
                name="user_id"
                :showLabelName="false"
                :showClassFilter="true"
                :readMasterData="fetchPersonalUserAll"
                :masterDefine="personalUserDefine"
                :index="idx"
                :value="userSelectorList[idx]"
                @changePersonalUser="onChangeStaff($event, checkData, idx)"
              />
            </td>
          </tr>
        </table>
      </div>
    </div>

    <div slot="footer" class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <!-- mod FNSI-横展開 画面デザイン_チェックリスト機能分 周 start -->
        <!-- <v-ons-button class="button denial-btn" @click="closeCheckListModal">キャンセル</v-ons-button> -->
        <v-ons-button class="button denial-btn btn2-cancel" @click="closeCheckListModal">キャンセル</v-ons-button>
        <!-- mod FNSI-横展開 画面デザイン_チェックリスト機能分 周 end -->
      </div>
      <div class="registration-btn-area" style="background:none">
        <!-- mod FNSI-横展開 画面デザイン_チェックリスト機能分 周 start -->
        <!-- <v-ons-button class="button registration-btn" @click="saveChecklist" v-if="editState">確定</v-ons-button> -->
        <v-ons-button class="button registration-btn btn1-execute" :disabled="!isChanged || !getItemAuthorized('CheckList', 'default_authority')" @click="saveChecklist" v-if="editState">保存</v-ons-button>
        <!-- mod FNSI-横展開 画面デザイン_チェックリスト機能分 周 end -->
        <!-- mod #11065 【03】編集権限バグ修正 関 end -->
      </div>
    </div>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
// mod 5984 機能帳票でパラメータが正しく渡されていない 歴 start
// import { mapGetters, mapActions } from "vuex";
import { mapGetters, mapActions, mapMutations } from "vuex";
// mod 5984 機能帳票でパラメータが正しく渡されていない 歴 end
import { EventBus } from "@/eventBus.js";
import CommonMasterSelectorComponent from "@/components/common/master-selector/CommonMasterSelectorComponent";
import { sendRequestGetMstPersonalUser, sendRequestMstGetJobs } from "@/apis/user-selector-popover";
import { practitioner } from "@/components/common/master-selector/MasterSelectorDefinitions";
import { Master } from "@/models/common/master-selector-condition/Master";
// add 5984 機能帳票でパラメータが正しく渡されていない 歴 start
import store from "@/stores";
import { getCurrentFunctionCd } from "@/router/routing-helper";
// add 5984 機能帳票でパラメータが正しく渡されていない 歴 end
// add #6107 2023/03/08 メッセージボックス全調整 林峻峰 start
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/08 メッセージボックス全調整 林峻峰 end
//#9226:チェックリストで画面で実施者を変更すると実施時刻がクリアされる。Start
import CommonCalender from "@/components/common/custom-calendar/CustomCalendar";
import DateInput from "@/components/common/DateInput.vue";
import TimeInput from "@/components/common/TimeInput.vue";
import { dateFormat } from "@/functions/common/DateTimeUtils";
//#9226:チェックリストで画面で実施者を変更すると実施時刻がクリアされる。End
// mod #11065 【03】編集権限バグ修正 関 start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// mod #11065 【03】編集権限バグ修正 関 end

export default {
  name: "CheckListModal",
  components: {
    "modal-base": ModalBase,
    "com-master-selector": CommonMasterSelectorComponent,
    //#9226:チェックリストで画面で実施者を変更すると実施時刻がクリアされる。Start
    "common-calendar": CommonCalender,
    "date-input":DateInput,
    "time-input":TimeInput
    //#9226:チェックリストで画面で実施者を変更すると実施時刻がクリアされる。End
  },
  mixins: [MasterMaintenanceMixin],
  data() {
    return {
      main: "",
      header: "",
      checklistGridToolbarHeight: 500,
      checklistGridHeight: 300,

      tableTop: 0,
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      isAndroid: false,

      isIOS: false,
      personalUserDefine: practitioner,
      userSelectorList: [],
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリスト 20231115 ztc start
      ignoreWatchSelectChecklist: true,
      isChanged: false,
      initGetSelectChecklist: {}
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリスト 20231115 ztc end
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
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("check-list/modal", [
      "getSelectChecklistSetting",
      "getSelectOrdMain",
      "getSelectChecklist",
    ]),
    columns() {
      return [
        {
          key: "name",
          colName: "チェック項目",
          className: "nameBody",
          width: 8,
          text: src => this.nameTemplate(src)
        },
        {
          key: "kind",
          colName: "種別",
          className: "kindBody",
          width: 8,
          text: src => src.kind
        },
        {
          key: "amount",
          colName: "数量",
          className: "amountBody",
          width: 4,
          text: src => this.amountTemplate(src)
     // #9226:チェックリストで画面で実施者を変更すると実施時刻がクリアされる。Start
        }
     // #9226:チェックリストで画面で実施者を変更すると実施時刻がクリアされる。End
      ];
    },
    displayInfo() {
      if (this.getSelectOrdMain) {
        return this.getSelectOrdMain;
      } else {
        return {
          patName: "",
          rstDialysisState: "",
          checkedItemCount: 0,
          checklistItemCount: 0,
          viewTreatDate: "",
          kurName: "",
          bedName: ""
        };
      }
    },
    // グリッドの編集状態
    editState() {
      let rEdit = true;
      // TODO:変更の可能性があるため以下の処理をコメントとする
      // // 透析中のチェックリストの場合
      // if (
      //   this.getSelectChecklistSetting !== null &&
      //   this.getSelectChecklistSetting.dialysis_prog_cd === 1 &&
      //   this.getSelectOrdMain.rstDialysisState < "3"
      // ) {
      //   // 編集不可
      //   rEdit = false;
      // }

      // // 透析後のチェックリストの場合
      // if (
      //   this.getSelectChecklistSetting !== null &&
      //   this.getSelectChecklistSetting.dialysis_prog_cd === 2 &&
      //   this.getSelectOrdMain.rstDialysisState < "5"
      // ) {
      //   // 編集不可
      //   rEdit = false;
      // }

      // // ？？？？患者の場合
      // if (
      //   this.getSelectOrdMain !== null &&
      //   this.getSelectOrdMain.patId === null
      // ) {
      //   // 編集不可
      //   rEdit = false;
      // }
      return rEdit;
    },
    // グリッド表示用チェックリストデータ
    displayCheckList() {
      return this.getSelectChecklist;
    }
  },
  methods: {
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("check-list/modal", [
      "setUserAccountInfo",
      "getMstPersonalUser",
      "getCheckListSetting",
      // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
      // "getOrderMainListByOrdNo",
      "getChecklistInfoByOrdNo",
      // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
      "setCheckInfo",
      "setCheckInfoChangeData",
      "regChecklist"
    ]),
    // add 5984 機能帳票でパラメータが正しく渡されていない 歴 start
    ...mapMutations("check-list/modal", {
      setSelectOrdMain: "setSelectOrdMain"
    }),
    // add 5984 機能帳票でパラメータが正しく渡されていない 歴 end
    //FNSI-修正 #5407 xugj add start
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    //FNSI-修正 #5407 xugj add end
    /** 名称テンプレート */
    nameTemplate(src) {
      const displayName = src.name ? src.name : "";
      return displayName;
    },
    /** 数量template */
    amountTemplate(src) {
      const displayAmount = src.amount !== null && src.amount !== undefined ? src.amount : "";
      const displayUnit = src.unit ? src.unit : "";
      return `${displayAmount}${displayUnit}`;
    },
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      if (!this.editingFlg) {
        this.calculateGridTop();

        // モーダルのbodyの高さ
        const mb = document.getElementsByClassName("modal-body")[0];
        // add #6853-チェックボックス、実施者の選択ボタンがヘッダーの前面に表示される 徐博 start
        mb.style.overflowY = "unset"
        // add #6853-チェックボックス、実施者の選択ボタンがヘッダーの前面に表示される 徐博 end
        const mh = mb ? mb.clientHeight : 0;
        // モーダルのヘッダの高さ
        const hc = document.getElementById("checklist-modal-header");
        const hh = hc ? hc.clientHeight : 0;
        this.checklistGridToolbarHeight = mh - hh;
        this.checklistGridToolbarHeight =
          this.checklistGridToolbarHeight < 300
            ? 300
            : this.checklistGridToolbarHeight;
        this.checklistGridHeight = this.checklistGridToolbarHeight - 10;
        // add #6853-チェックボックス、実施者の選択ボタンがヘッダーの前面に表示される 徐博 start
        document.getElementsByClassName("grid-content-area")[0].style.overflowY = "auto";
        document.getElementsByClassName("grid-content-area")[0].style.height = this.checklistGridHeight + "px"
        // add #6853-チェックボックス、実施者の選択ボタンがヘッダーの前面に表示される 徐博 end
        if (mh + hh === 0) {
          setTimeout(this.calculateGridHeight, 10);
        }
      }
    },
    // #9226:チェックリストで画面で実施者を変更すると実施時刻がクリアされる。Start
    onChangeDate(rowData, idx) {
      rowData.Date = rowData.viewDate && rowData.viewtime
        ? new Date(dateFormat.utc2Jst(rowData.viewDate + "T" + rowData.viewtime))
        : null;
      this.setCheckInfoChangeData(rowData);
    },
    // #9226:チェックリストで画面で実施者を変更すると実施時刻がクリアされる。End
    onChangeStaff(userInfo, rowData, index) {
      if(userInfo) {
        rowData.user_id = userInfo.id;
        this.userSelectorList[index].cd = userInfo.id;
        this.userSelectorList[index].name = userInfo.lastName + " " + userInfo.firstName;
      } else {
        rowData.user_id = -1;
        this.userSelectorList[index].cd = null;
        this.userSelectorList[index].name = null;
      }
      this.setCheckInfoChangeData(rowData);
    },
    // グリッドクリックイベント
    onClickRow(rowData) {
      // mod #11710 チェックリスト実施時の挙動不正 関 start
      // mod #11065 【03】編集権限バグ修正 関 start
      if (rowData && this.editState && this.getItemAuthorized('CheckList', 'default_authority')) {
        // mod #11065 【03】編集権限バグ修正 関 end
        // mod #11710 チェックリスト実施時の挙動不正 関 end
        // チェックリスト項目名
        const name = rowData.name;
        if (name !== null) {
          this.setCheckInfo(rowData);
          this.convertUserSelectors();
        }
      }
    },
    templateData(item) {
      return {
        dataItem: item,
        parentComponent: this
      };
    },
    // 背景色セット
    editBackgroundColor() {
      this.$nextTick(() => {
        const tBodyList = document.getElementsByClassName(
          "checklist-modal-row"
        );
        if (tBodyList) {
          for (let rwCount = 0; rwCount < tBodyList.length; rwCount++) {
            const currentTrc = tBodyList[rwCount].children;

            // 編集で色を変更する
            const edited = this.getSelectChecklist[rwCount].chg_flg;

            // 並び順以外の項目が変更されていた場合は、削除か修正にあわせて並び順より後の項目の背景色を変更
            this.changeRowColor(currentTrc, edited);

            // 時刻・実施者が変更されていた場合、背景色を変更
            this.changeCellFont(currentTrc, this.getSelectChecklist[rwCount]);
          }
        }
      });
    },
    changeRowColor(currentTrc, edited) {
      const addClass = "master-edited-row";

      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        // 全項目の背景色を変更
        if (edited) {
          currentTrc[clCount]?.classList?.add(addClass);
        } else if (currentTrc[clCount].classList.length > 0) {
          currentTrc[clCount].classList.remove(addClass);
        }
      }
    },
    changeCellFont(currentTrc, data) {
      const addClass = "master-edited-cell";

      // 時刻
      const dateIdx = 4;
      // 変更ありの場合
      if (data.chgflg_time) {
        currentTrc[dateIdx]?.classList?.add(addClass);
      } else if (currentTrc[dateIdx].classList.length > 0) {
        currentTrc[dateIdx].classList.remove(addClass);
      }

      // 実施者
      const userIdx = 5;
      // 変更ありの場合
      if (data.chgflg_user_id) {
        currentTrc[userIdx].children[0].children[0]?.classList?.add(addClass);
      } else if (currentTrc[userIdx].classList.length > 0) {
        currentTrc[userIdx].children[0].children[0].classList.remove(addClass);
      }
    },
    onSave(ev) {
      this.editingFlg = false;
      // 変更データ更新
      this.setCheckInfoChangeData(ev);
    },
    // 登録完了通知
    gridDataLoad() {
      // 登録完了通知
      EventBus.$emit("dataUpdate");
    },
    // モーダルの高さからGirdコンポーネント領域のTopを算出
    calculateGridTop() {
      this.tableTop =
        document.getElementById("checklist-modal-header").clientHeight + 3;
    },
    // 確定ボタン
    async saveChecklist() {
      // グリッドに表示されているデータを登録
      this.regChecklist().then(res => {
        if (res.result === false) {
          // エラーメッセージ表示
          this.$ons.notification.alert({
            // mod #6107 2023/03/08 メッセージボックス全調整 林峻峰 start
            // title: "チェックリスト登録失敗",
            title: DIALOG_MESSAGES['00300001'].title,
            // mod #6107 2023/03/08 メッセージボックス全調整 林峻峰 end
            message: res.message
          });
        }
        // モーダルを非表示に
        this.hideModal();

        // 登録完了通知
        this.gridDataLoad();
      });
    },
    // キャンセルボタン
    closeCheckListModal() {
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリスト 20231115 ztc start
      if (this.isChanged) {
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[12000014].title,
          // add 全マスタメッセージ調整 王 start
          // message: "編集内容が破棄されます。</br>よろしいですか？",
          message: DIALOG_MESSAGES[12000014].message,
          // add 全マスタメッセージ調整 王 end
          callback: answer => {
            if (answer === 1) {
              // モーダルを非表示に
              this.hideModal();
              EventBus.$emit("closeModal");
            }
          }
        });
      }else{
        // モーダルを非表示に
        this.hideModal();
        EventBus.$emit("closeModal");
      }
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリスト 20231115 ztc end
    },
    fetchPersonalUserAll() {
      return Promise.all([sendRequestGetMstPersonalUser(this.getFacilityCd), sendRequestMstGetJobs(this.getFacilityCd)]);
    },
    convertUserSelectors() {
      this.userSelectorList = this.displayCheckList.map(m => {
        if (m.user_id === null) return new Master();
        return new Master(m.user_id, m.user_name);
      });
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリスト 20231115 ztc start
    setSelectChecklist(){
      this.initGetSelectChecklist =  JSON.parse(JSON.stringify(this.getSelectChecklist));
    },
    changeButton(){
      let checklistArr = JSON.parse(JSON.stringify(this.getSelectChecklist))
      let initChecklistArr = JSON.parse(JSON.stringify(this.initGetSelectChecklist))
      checklistArr && checklistArr.forEach(item => {
        delete item.chg_flg
        delete item.chgflg_time
        delete item.chgflg_user_id
        delete item.user_update
        delete item.Date
      })
      initChecklistArr && initChecklistArr.forEach(item => {
        delete item.chg_flg
        delete item.chgflg_time
        delete item.chgflg_user_id
        delete item.user_update
        delete item.Date
      })
      if (!!checklistArr && !!initChecklistArr &&
          JSON.stringify(checklistArr).replace(/\s/g, '') !== JSON.stringify(initChecklistArr).replace(/\s/g, '')) {
        this.isChanged = true;
      } else {
        this.isChanged = false;
      }
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリスト 20231115 ztc end
    // add #11065 【03】編集権限バグ修正 関 start
    getItemAuthorized(pageCd, itemCd) {
        return getAuthorized(pageCd, itemCd);
    },
    // add #11065 【03】編集権限バグ修正 関 end
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
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリスト 20231115 ztc start
    getSelectChecklist: {
      handler() {
        if (this.ignoreWatchSelectChecklist){
          this.ignoreWatchSelectChecklist = false;
          return;
        }
        this.changeButton();
      },
      deep: true
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリスト 20231115 ztc end
  },
  created() {
    //FNSI-修正 #5407 xugj add start
    this.setLoadingScreenVisible(true);
    //FNSI-修正 #5407 xugj add end
    // 端末判別
    const ua = navigator.userAgent;
    if (ua.match(/Android/)) {
      this.isAndroid = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.isIOS = true;
    }
  },
  updated() {
    // Storeの更新等で画面が再描画された場合に背景色を変更
    this.editBackgroundColor();
  },
  async mounted() {
    // ログインアカウントセット
    this.setUserAccountInfo(this.getStateUserAccountInfo);

    // スタッフマスタ情報取得
    await this.getMstPersonalUser(this.getFacilityCd);
    // チェックリストマスタ情報取得
    await this.getCheckListSetting();
    // 選択されたordNoのスケジュール取得
    // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
    // await this.getOrderMainListByOrdNo();
    await this.getChecklistInfoByOrdNo();
    // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリスト 20231115 ztc start
    await this.setSelectChecklist();
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリスト 20231115 ztc end
    //FNSI-修正 #5407 xugj add start
    this.setLoadingScreenVisible(false);
    //FNSI-修正 #5407 xugj add end

    this.$nextTick(() => {
      this.calculateGridHeight();
      this.convertUserSelectors();
    });
  },
  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  destroyed() {
    // add 5984 機能帳票でパラメータが正しく渡されていない 歴 start
    this.setSelectOrdMain({ selectOrdMain: null });
    const funcCd = getCurrentFunctionCd();
    if (funcCd) {
      store.dispatch("report/getMstReport", {funcCd: funcCd,printFlag: 0});
    }
    // add 5984 機能帳票でパラメータが正しく渡されていない 歴 end
  }
};
</script>

<style scoped>
/* 治療状況 */
.treat-state {
  border-radius: 5px;
  padding: 0px 5px 0px 5px;
}
.state-send {
  color: white;
  background-color: #42CB92;
}
.state-treat {
  color: white;
  background-color: #2CA06F;
}
.state-treat-end {
  color: white;
  background-color: #557769;
}
.state-end {
  color: white;
  background-color: #808080;
}
#column-01 {
  width: 8%;
  min-width: 2em;
}
#column-02 {
  /* #9226:チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 Start*/
  width: 25%;
  min-width: 12em;
  /* #9226:チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 End*/
}
#column-03 {
  /* #9226:チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 Start */
  width: 10%;
  min-width: 5em
  /* #9226:チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 End*/
}
#column-04 {
  width: 10%;
  min-width: 4em;
}
#column-05 {
/* #9226:チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 Start*/
   width: 25%;
   min-width: 12em;
/* #9226:チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 End */
}
#column-06 {
  width: 22%;
  min-width: 8em;
}
.grid-content-area {
  font-size: 1em;
}
.checklist-modal-row {
  background-color: white;
}
ons-input >>> .text-input {
  font-size: 100%;
}
.checklist-modal-list tr:hover {
  background-color:  #f5f5f5;
}
/*#9226:チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 Start　*/
.ntss-input-date {
  max-width: 7.5em;
  min-width: 7.5em;
}
.occurs_date_time {
  margin-left: 5px;
}

.ntss-input-date,
.ntss-btn-outset,
.occurs_date_time {
  font-size: 100%;
}
/*#9226:チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 End　*/
.ntss-list-body-td >>> ons-button.select-btn {
  font-size: 1em;
}

.custom-checklist-modal-list {
  font-size: unset;
}
/* add FNSI-redmine_#3904_グリッド表示を修正 周 start */
.master-maintenance-page .k-grid {
  position: inherit;
}
.checklist-modal-list {
  position: inherit;
}
/* add FNSI-redmine_#3904_グリッド表示を修正 周 end */
@media print {
  #column-01 ,#column-02,#column-03,#column-04,#column-05,#column-06{
    min-width: 0;
  }

  .grid-content-area{
    height:  100% !important;
  }
}
</style>
