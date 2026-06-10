/**
 * 投与薬剤モーダルPage
 */
 <template>
  <modal-base @onClose="closeMedicineModal">
    <div slot="header">
      <component :is="header"></component>
    </div>
    <!-- mod FNSI-redmine_#3904_グリッド表示を修正 周 start -->
    <!-- <div slot="body"> -->
    <div slot="body" class="master-maintenance-page">
    <!-- mod FNSI-redmine_#3904_グリッド表示を修正 周 end -->
      <div id="medicine-modal-header">
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
            >{{displayInfo.checkedItemCount}}/{{displayInfo.medilistItemCount}}</label>
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
      <!-- <div id="modal-body" class="grid-content-area"> -->
      <div id="modal-body" class="grid-content-area k-grid">
      <!-- mod FNSI-redmine_#3904_グリッド表示を修正 周 end -->
        <!-- 投与薬剤のグリッド -->
        <table class="checklist-modal-list custom-checklist-modal-list" :style="{ 'top':tableTop + 'px' }">
          <thead>
            <tr>
              <th id="column-01" class="ntss-list-header-th-sticky">実施</th>
              <th id="column-02" class="ntss-list-header-th-sticky">{{ columns[0].colName }}</th>
              <th id="column-03" class="ntss-list-header-th-sticky">数量</th>
              <th id="column-04" class="ntss-list-header-th-sticky">投与時間</th>
              <th id="column-05" class="ntss-list-header-th-sticky">実施者</th>
            </tr>
          </thead>
          <tr
            v-for="(medicineData, idx) in displayMedicineList"
            :key="idx"
            :class="'medicine-modal-row'"
            style="height: 4rem;"
          >
            <td class="ntss-list-body-td" @click="onClickRow(medicineData)">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <v-ons-checkbox -->
              <!--   :input-id="'checkbox-' + idx" -->
              <!--   v-model="medicineData.effect_flg" -->
              <!--   :disabled="!editState" -->
              <!-- ></v-ons-checkbox> -->
              <v-ons-checkbox
                :input-id="'checkbox-' + idx"
                v-model="medicineData.effect_flg"
                :disabled="!editState || !getItemAuthorized('CheckList', 'default_authority')"
              ></v-ons-checkbox>
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </td>
            <td
              v-for="column in columns"
              class="ntss-list-body-td"
              :key="column.className"
              :style="column.style"
              @click="onClickRow(medicineData)"
            >{{ column.text(medicineData) }}</td>
            <td class="ntss-list-body-td">
              <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 start -->
              <!-- <input
                type="date"
                class="ntss-input-date"
                v-model="medicineData.effect_date_str"
                v-show="medicineData.effect_flg"
                :disabled="!editState"
                @change="onChangeDate(medicineData, idx)"
              /> -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <date-input -->
              <!--   class="ntss-input-date" -->
              <!--   v-model="medicineData.effect_date_str" -->
              <!--   @handleClearInput="medicineData.effect_date_str = null" -->
              <!--   v-show="medicineData.effect_flg" -->
              <!--   :disabled="!editState" -->
              <!--   @change="onChangeDate(medicineData, idx)" -->
              <!-- /> -->
              <!--#10715:日付IF修正Start（必須追加+param修正）-->
              <date-input
                class="ntss-input-date"
                :classes="'input-area ntss-input-date ntss-custom-input ntss-input-start-date date-input-required '"
                v-model="medicineData.effect_date_str"
                @handleClearInput="medicineData.effect_date_str = null"
                v-show="medicineData.effect_flg"
                :disabled="!editState || !getItemAuthorized('CheckList', 'default_authority')"
                :isRequired="true"
                :defaultDate="medicineData.effect_date_str"
                @change="onChangeDate(medicineData, idx)"
              />
              <!--#10715:日付IF修正End（必須追加+param修正）-->
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 end -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <common-calendar -->
              <!--   v-model="medicineData.effect_date_str" -->
              <!--   v-show="medicineData.effect_flg" -->
              <!--   :disabled="!editState" -->
              <!--   @input="onChangeDate(medicineData, idx)" -->
              <!-- /> -->
              <common-calendar
                v-model="medicineData.effect_date_str"
                v-show="medicineData.effect_flg"
                :disabled="!editState || !getItemAuthorized('CheckList', 'default_authority')"
                @input="onChangeDate(medicineData, idx)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 start -->
              <!-- <input
                type="time"
                class="effect-input-time"
                v-model="medicineData.effect_time_str"
                v-show="medicineData.effect_flg"
                :disabled="!editState"
                @change="onChangeDate(medicineData, idx)"
              /> -->
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <time-input -->
              <!--   class="effect-input-time" -->
              <!--   v-model="medicineData.effect_time_str" -->
              <!--   @handleClearInput="medicineData.effect_time_str = null" -->
              <!--   v-show="medicineData.effect_flg" -->
              <!--   :disabled="!editState" -->
              <!--   @change="onChangeDate(medicineData, idx)" -->
              <!-- /> -->
              <!--#10715:日付IF修正Start（必須追加+param修正）-->
              <time-input
                class="effect-input-time"
                v-model="medicineData.effect_time_str"
                @handleClearInput="medicineData.effect_time_str = null"
                v-show="medicineData.effect_flg"
                :disabled="!editState || !getItemAuthorized('CheckList', 'default_authority')"
                :isRequired="true"
                :defaultTime="medicineData.effect_time_str"
                :classes="'time-input-required '"
                @change="onChangeDate(medicineData, idx)"
              />
              <!--#10715:日付IF修正End（必須追加+param修正）-->
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 end -->
            </td>
            <td class="ntss-list-body-td">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <com-master-selector -->
              <!--   v-show="medicineData.effect_flg" -->
              <!--   :isDisabled="!editState" -->
              <!--   select-id="effect_user_id" -->
              <!--   name="effect_user_id" -->
              <!--   :showLabelName="false" -->
              <!--   :showClassFilter="true" -->
              <!--   :readMasterData="fetchPersonalUserAll" -->
              <!--   :masterDefine="personalUserDefine" -->
              <!--   :index="idx" -->
              <!--   :value="userSelectorList[idx]" -->
              <!--   @changePersonalUser="onChangeStaff($event, medicineData, idx)" -->
              <!-- /> -->
              <com-master-selector
                v-show="medicineData.effect_flg"
                :isDisabled="!editState || !getItemAuthorized('CheckList', 'default_authority')"
                select-id="effect_user_id"
                name="effect_user_id"
                :showLabelName="false"
                :showClassFilter="true"
                :readMasterData="fetchPersonalUserAll"
                :masterDefine="personalUserDefine"
                :index="idx"
                :value="userSelectorList[idx]"
                @changePersonalUser="onChangeStaff($event, medicineData, idx)"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </td>
          </tr>
        </table>
      </div>
    </div>

    <div slot="footer" class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <!-- mod FNSI-横展開 画面デザイン_チェックリスト機能分 周 start -->
        <!-- <v-ons-button class="button denial-btn" @click="closeMedicineModal">キャンセル</v-ons-button> -->
        <v-ons-button class="button denial-btn btn2-cancel" @click="closeMedicineModal">キャンセル</v-ons-button>
        <!-- mod FNSI-横展開 画面デザイン_チェックリスト機能分 周 end -->
      </div>
      <div class="registration-btn-area" style="background:none" v-if="editState">
        <!-- mod FNSI-横展開 画面デザイン_チェックリスト機能分 周 start -->
        <!-- <v-ons-button class="button registration-btn" @click="saveMedicine">確定</v-ons-button> -->
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <v-ons-button class="button registration-btn btn1-execute" :disabled="!isChanged" @click="saveMedicine">保存</v-ons-button> -->
        <v-ons-button
          class="button registration-btn btn1-execute"
          :disabled="!isChanged || !getItemAuthorized('CheckList', 'default_authority')"
          @click="saveMedicine"
        >保存</v-ons-button>
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
        <!-- mod FNSI-横展開 画面デザイン_チェックリスト機能分 周 end -->
      </div>
    </div>
  </modal-base>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import ModalBase from "@/components/modals/ModalBase";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
// mod 5984 機能帳票でパラメータが正しく渡されていない 歴 start
// import { mapGetters, mapActions } from "vuex";
import { mapGetters, mapActions, mapMutations } from "vuex";
// mod 5984 機能帳票でパラメータが正しく渡されていない 歴 end
import { EventBus } from "@/eventBus.js";
import { dateFormat } from "@/functions/common/DateTimeUtils";
import CommonCalender from "@/components/common/custom-calendar/CustomCalendar";
import CommonMasterSelectorComponent from "@/components/common/master-selector/CommonMasterSelectorComponent";
import { sendRequestGetMstPersonalUser, sendRequestMstGetJobs } from "@/apis/user-selector-popover";
import { practitioner } from "@/components/common/master-selector/MasterSelectorDefinitions";
import { Master } from "@/models/common/master-selector-condition/Master";
// add 5984 機能帳票でパラメータが正しく渡されていない 歴 start
import store from "@/stores";
import { getCurrentFunctionCd } from "@/router/routing-helper";
// add 5984 機能帳票でパラメータが正しく渡されていない 歴 end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
//#5590 2023/04/20 ×を常に表示するように修正 張博 start
import DateInput from "@/components/common/DateInput.vue";
import TimeInput from "@/components/common/TimeInput.vue";
//#5590 2023/04/20 ×を常に表示するように修正 張博 end

export default {
  name: "MedicineModal",
  components: {
    "modal-base": ModalBase,
    "common-calendar": CommonCalender,
    "com-master-selector": CommonMasterSelectorComponent,
    //#5590 2023/04/20 ×を常に表示するように修正 張博 start
    "date-input":DateInput,
    "time-input":TimeInput
    //#5590 2023/04/20 ×を常に表示するように修正 張博 end
  },
  mixins: [MasterMaintenanceMixin],
  data() {
    return {
      main: "",
      header: "",
      medicineGridToolbarHeight: 500,
      medicineGridHeight: 300,
      tableTop: 0,
      personalUserDefine: practitioner,
      userSelectorList: [],
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリスト 20231115 ztc start
      ignoreWatchSelectedMediList: true,
      isChanged: false,
      initGetSelectMediList: {}
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
    ...mapGetters("check-list/medimodal", [
      "getSelectOrdMain",
      "getSelectMediList",
      "getSchema"
    ]),
    columns() {
      return [
        {
          key: "name",
          colName: "薬剤名\n(投与時間帯/手技)",
          className: "nameBody",
          width: 12,
          style:
            "text-align: left; white-space:pre-wrap; word-wrap:break-word;",
          text: src => this.mediNameTemplate(src)
        },
        {
          key: "amount",
          colName: "数量",
          className: "amountBody",
          width: 4,
          style: "text-align: left;",
          text: src => this.amountTemplate(src)
        }
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
          medilistItemCount: 0,
          viewTreatDate: "",
          kurName: "",
          bedName: ""
        };
      }
    },
    // グリッドの編集状態
    editState() {
      let rEdit = true;
      // 条件送信前の場合
      if (
        this.getSelectOrdMain !== null &&
        (this.getSelectOrdMain.rstDialysisState === "0" ||
          this.getSelectOrdMain.patId === null)
      ) {
        // 編集不可
        rEdit = false;
      }
      return rEdit;
    },
    // 表示用投与薬剤情報
    displayMedicineList() {
      // storeからデータを取得
      return this.getSelectMediList;
    }
  },
  methods: {
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("check-list/medimodal", [
      "setUserAccountInfo",
      "getMstPersonalUser",
      // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
      // "getOrderMainByOrdNo",
      "getMedicineInfoByOrdNo",
      // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
      "setCheckInfo",
      "setCheckInfoChangeData",
      "regMedicineList"
    ]),
    // add 5984 機能帳票でパラメータが正しく渡されていない 歴 start
    ...mapMutations("check-list/medimodal", {
      setSelectOrdMain: "setSelectOrdMain"
    }),
    // add 5984 機能帳票でパラメータが正しく渡されていない 歴 end
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end

    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      this.calculateGridTop();

      // モーダルのbodyの高さ
      const mb = document.getElementsByClassName("modal-body")[0];
      /* add #9461  by zhangruixue 2023-08-17 --start */
      mb.style.overflowY = "unset"
      /* add #9461  by zhangruixue 2023-08-17 --start */
      const mh = mb ? mb.clientHeight : 0;
      // モーダルのヘッダの高さ
      const hElm = document.getElementById("medicine-modal-header");
      const hh = hElm ? hElm.clientHeight : 0;
      this.medicineGridToolbarHeight = mh - hh;
      this.medicineGridToolbarHeight =
        this.medicineGridToolbarHeight < 150
          ? 150
          : this.medicineGridToolbarHeight;
      this.medicineGridHeight = this.medicineGridToolbarHeight - 10;
      /* add #9461  by zhangruixue 2023-08-17 --start */
      document.getElementsByClassName("grid-content-area")[0].style.overflowY = "auto";
      document.getElementsByClassName("grid-content-area")[0].style.height = this.medicineGridHeight + "px"
      /* add #9461  by zhangruixue 2023-08-17 --start */
      if (mh + hh === 0) {
        setTimeout(this.calculateGridHeight, 10);
      }
    },
    mediNameTemplate(src) {
      const displayName = src.name ? src.name : "";
      const displayTiming = src.timing_name ? src.timing_name : "未登録";
      const displayProcedure =
        src.procedure_name ? src.procedure_name : "未登録";
      return `${displayName}\n${displayTiming} / ${displayProcedure}`;
    },
    amountTemplate(src) {
      const displayAmount = src.amount !== null && src.amount !== undefined ? src.amount : "";
      const displayUnit = src.unit ? src.unit : "";
      return `${displayAmount}${displayUnit}`;
    },
    // 背景色セット
    editBackgroundColor() {
      this.$nextTick(() => {
        const tBodyList = document.getElementsByClassName("medicine-modal-row");
        if (tBodyList) {
          for (let rwCount = 0; rwCount < tBodyList.length; rwCount++) {
            const currentTrc = tBodyList[rwCount].children;

            // 編集で色を変更する
            const edited = this.getSelectMediList[rwCount].chg_flg;

            // 並び順以外の項目が変更されていた場合は、削除か修正にあわせて並び順より後の項目の背景色を変更
            this.changeRowColor(currentTrc, edited);

            // 投与時刻・実施者が変更されていた場合、背景色を変更
            this.changeCellFont(currentTrc, this.getSelectMediList[rwCount]);
          }
        }
      });
    },
    changeRowColor(currentTrc, edited) {
      const addClass = "master-edited-row";

      for (const trc of currentTrc) {
        // 全項目の背景色を変更
        if (edited) {
          trc?.classList?.add(addClass);
        } else if (trc.classList.length > 0) {
          trc.classList.remove(addClass);
        }
      }
    },
    changeCellFont(currentTrc, data) {
      const addClass = "master-edited-cell";

      // 投与時間
      const dateIdx = 3;
      // 変更ありの場合
      if (data.chgflg_effect_date) {
        currentTrc[dateIdx].children[0]?.classList?.add(addClass);
        currentTrc[dateIdx].children[2]?.classList?.add(addClass);
      } else if (
        currentTrc[dateIdx].classList.length > 0 &&
        currentTrc[dateIdx].children[0]
      ) {
        currentTrc[dateIdx].children[0].classList.remove(addClass);
        currentTrc[dateIdx].children[2].classList.remove(addClass);
      }

      // 実施者
      const userIdx = 4;
      // 変更ありの場合
      if (data.chgflg_effect_user_id) {
        currentTrc[userIdx].children[0].children[0]?.classList?.add(addClass);
      } else if (
        currentTrc[userIdx].classList.length > 0 &&
        currentTrc[dateIdx].children[0].children[0]
      ) {
        currentTrc[userIdx].children[0].children[0].classList.remove(addClass);
      }
    },
    onChangeDate(rowData, idx) {
      rowData.effect_date = rowData.effect_date_str && rowData.effect_time_str
        ? new Date(dateFormat.utc2Jst(rowData.effect_date_str + "T" + rowData.effect_time_str))
        : null;
      //#10715:日付IF修正Start
      if (rowData.effect_date !== null)
          this.setCheckInfoChangeData({ rowData: rowData, idx: idx });
      //#10715:日付IF修正End
    },
    // グリッドクリックイベント
    onClickRow(rowData) {
      // 条件送信後以降かつ？？？？患者ではない場合
      // mod #11710 チェックリスト実施時の挙動不正 関 start
      // mod #11065 【03】編集権限バグ修正 関 start
      if (
        rowData &&
        this.editState &&
        this.getSelectOrdMain.rstDialysisState !== "0" &&
        this.getSelectOrdMain.patId !== null && this.getItemAuthorized('CheckList', 'default_authority')
      ) {
        this.setCheckInfo(rowData);
        this.convertUserSelectors();
      }
      // mod #11065 【03】編集権限バグ修正 関 end
      // mod #11710 チェックリスト実施時の挙動不正 関 end
    },
    // 登録完了通知
    gridDataLoad() {
      // 登録完了通知
      EventBus.$emit("dataUpdate");
    },
    // 確定ボタン
    async saveMedicine() {
      // グリッドに表示されているデータを登録
      this.regMedicineList().then(res => {
        if (res.result === false) {
          // エラーメッセージ表示
          this.$ons.notification.alert({
            // mod #6107 2023/03/08 メッセージボックス全調整 林峻峰 start
            // title: "投与薬剤登録失敗",
            title: DIALOG_MESSAGES['00300002'].title,
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
    closeMedicineModal() {
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
    // モーダルの高さからGirdコンポーネント領域のTopを算出
    calculateGridTop() {
      this.tableTop =
        document.getElementById("medicine-modal-header").clientHeight + 3;
    },
    fetchPersonalUserAll() {
      return Promise.all([sendRequestGetMstPersonalUser(this.getFacilityCd), sendRequestMstGetJobs(this.getFacilityCd)]);
    },
    onChangeStaff(userInfo, rowData, index) {
      if(userInfo) {
        rowData.effect_user_id = userInfo.id;
        this.userSelectorList[index].cd = userInfo.id;
        this.userSelectorList[index].name = userInfo.lastName + " " + userInfo.firstName;
      } else {
        rowData.effect_user_id = null;
        this.userSelectorList[index].cd = null;
        this.userSelectorList[index].name = null;
      }
      this.setCheckInfoChangeData({ rowData: rowData, idx: index });
    },
    convertUserSelectors() {
      this.userSelectorList = this.displayMedicineList.map(m => {
        if (m.effect_user_id === null) return new Master();
        return new Master(m.effect_user_id, m.effect_user_name);
      });
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリスト 20231115 ztc start
    setInitSelectMediList(){
      this.initGetSelectMediList =  JSON.parse(JSON.stringify(this.getSelectMediList));
    },
    changeButton(){
      let selectMediArr = JSON.parse(JSON.stringify(this.getSelectMediList))
      let initSelectMediArr = JSON.parse(JSON.stringify(this.initGetSelectMediList))
      selectMediArr && selectMediArr.forEach(item => {
        delete item.chg_flg
        delete item.chgflg_effect
        delete item.chgflg_effect_date
        delete item.chgflg_effect_user_id
        delete item.effect_user_update
      })
      initSelectMediArr && initSelectMediArr.forEach(item => {
        delete item.chg_flg
        delete item.chgflg_effect
        delete item.chgflg_effect_date
        delete item.chgflg_effect_user_id
        delete item.effect_user_update
      })
      if (!!selectMediArr && !!initSelectMediArr &&
          JSON.stringify(selectMediArr).replace(/\s/g, '') !== JSON.stringify(initSelectMediArr).replace(/\s/g, '')) {
        this.isChanged = true;
      } else {
        this.isChanged = false;
      }
    }
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリスト 20231115 ztc end
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
    getSelectMediList: {
      handler() {
        if (this.ignoreWatchSelectedMediList){
          this.ignoreWatchSelectedMediList = false;
          return;
        }
        this.changeButton();
      },
      deep: true
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリスト 20231115 ztc end
  },
  created() {
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
    // 選択されたordNoのスケジュール取得
    // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
    // await this.getOrderMainByOrdNo();
    await this.getMedicineInfoByOrdNo();
    // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリスト 20231115 ztc start
    await this.setInitSelectMediList();
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリスト 20231115 ztc end
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
  width: 30%;
  min-width: 12em;
}
#column-03 {
  width: 10%;
  min-width: 4em;
}
#column-04 {
  width: 20%;
  min-width: 19em;
}
#column-05 {
  width: 32%;
  min-width: 18em;
}

.grid-content-area {
  font-size: 1em;
}
.medicine-modal-row {
  background-color: white;
}
ons-input >>> .text-input {
  font-size: 100%;
}
.checklist-modal-list tr:hover {
  background-color:  #f5f5f5;
}

.ntss-input-date {
  /* mod FNSI-障害票一覧_チェックリスト#9。 周 start */
  /* max-width: 6em; */
  max-width: 7.5em;
  min-width: 7.5em;
  /* mod FNSI-障害票一覧_チェックリスト#9。 周 end */
}

.effect-input-time {
  margin-left: 5px;
}

.ntss-input-date,
.ntss-btn-outset,
.effect-input-time {
  font-size: 100%;
}

.ntss-list-body-td >>> ons-button.select-btn  {
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
/* add #9461  by zhangruixue 2023-08-17 --start */
#column-01{
  z-index: 2;
}
#column-04{
  z-index: 2;
}
#column-05{
  z-index: 2;
}
/* add #9461  by zhangruixue 2023-08-17 --end */

@media print {
  #column-01 ,#column-02,#column-03,#column-04,#column-05{
    min-width: 0;
  }

  #modal-body{
    height:  100% !important;
  }
}
</style>
