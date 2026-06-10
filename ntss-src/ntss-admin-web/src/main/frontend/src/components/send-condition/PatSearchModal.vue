/**
 * 患者選択モーダルPage
 */
 <template>
  <modal-base @onClose="closePatSearchModal" class="send-condition-pat-modal-base">
    <div slot="header">
      <component :is="header"></component>
    </div>
    <div slot="body">
      <v-ons-row id="send-condition-pat-modal-search-area">
        <!-- 指定日 -->
        <div class="filter-content date-value">
          <div class="flex-align-center">
            <!-- add FNSI-横展開 日付のチェックの追加 徐 start -->
            <!-- <input
              class="ntss-input-date ntss-control-size"
              name="weight-pat-search-date-input"
              type="date"
              @change="onChangeDate"
              v-model="targetDate"
              v-validate="'required|date_format:yyyy-MM-dd'"
            />
            <common-calendar v-model="targetDate" @input="onChangeDate" />-->
            <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 start -->
            <!-- <input
              id="weight-pat-search-date-input"
              data-vv-scope="targetDate"
              class="ntss-input-date ntss-control-size"
              name="weight-pat-search-date-input"
              type="date"
              @change="onChangeDate"
              v-model="targetDate"
              max="9999-12-31"
              v-validate="'required|date_format:yyyy-MM-dd'"
            /> -->
            <date-input
              id="weight-pat-search-date-input"
              data-vv-scope="targetDate"
              class="ntss-input-date ntss-control-size"
              name="weight-pat-search-date-input"
              @change="onChangeDate"
              v-model="targetDate"
              isRequired
            />
            <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 end -->
            <common-calendar v-model="targetDate" @input="onChangeDate" />
            <span class="error-message">{{
              errors.first("targetDate.weight-pat-search-date-input")
            }}</span>
            <!-- add FNSI-横展開 日付のチェックの追加 徐 end -->
          </div>
        </div>
        <!-- クール -->
        <div class="filter-content flex-align-center">
          <v-ons-select v-model="filter.selectKur" :disabled="isDualMode">
            <option value="-1">全クール</option>
            <option
              v-for="selector in getMstKurSelector"
              :key="selector.code"
              :value="selector.code"
            >{{ selector.name }}</option>
          </v-ons-select>
        </div>
        <!-- ベッドグループ -->
        <div class="filter-content flex-align-center">
          <v-ons-select v-model="filter.selectBedGroup" :disabled="isDualMode">
            <option :value="defaultSelect">全ベッド</option>
            <option
              v-for="(mstBedGroup, index) in getMstBedGroupList"
              :key="index"
              :value="mstBedGroup.roomBedGroupCd"
            >{{ mstBedGroup.roomBedGroupName }}</option>
          </v-ons-select>
        </div>
        <div class="filter-content horizontal-div">
          <div class="content-vertical-center">
            <v-ons-checkbox
              v-model="filter.isFilterTreating"
              :input-id="'filter-treating'"
              :disabled="isDualMode"
            />
          </div>
          <div class="vertical-div">
            <label for="filter-treating">治療中表示</label>
            <label for="filter-treating">(車いす先測定用)</label>
          </div>
        </div>
        <div class="filter-content horizontal-div">
          <div class="content-vertical-center">
            <v-ons-checkbox
              v-model="filter.isFilterChecked"
              :input-id="'filter-checked'"
              :disabled="isDualMode"
            />
          </div>
          <div class="vertical-div">
            <label for="filter-checked">条件送信</label>
            <label for="filter-checked">確認済み表示</label>
          </div>
        </div>
      </v-ons-row>
      <!-- 患者一覧のグリッド -->
      <!-- mod #9461  by zhangruixue 2023-08-17 --start -->
      <div :style="{ 'height':tableHeight + 'px','overflow-y':'auto','position':'relative','top':'0'}" class="pat-modal-list-wrapper">
        <table class="send-condition-pat-modal-list" :style="{ 'top':0 + 'px' }">
          <!-- mod #9461  by zhangruixue 2023-08-17 --end -->
          <thead>
            <tr>
              <th
                v-for="column in columns"
                :key="column.key"
                :class="[column.centerAlign ? 'list-header-th-center' : '']"
                class="ntss-list-header-th-sticky manual-width"
                :style="{ 'min-width':column.width + 'em' }"
              >
                <div class="resizable-header">
                  <span @click="sortBy(column.key)" class="clickable-header-label" :class="sortedClass(column.key)">{{ column.colName }}</span>
                </div>
              </th>
              <th
                :key="dialysisStateColumn.key"
                :class="[dialysisStateColumn.centerAlign ? 'list-header-th-center' : '']"
                class="ntss-list-header-th-sticky manual-width"
                :style="{ 'min-width': dialysisStateColumn.width + 'em' }"
              >
                <div class="resizable-header">
                  <span @click="sortBy(dialysisStateColumn.key)" class="clickable-header-label" :class="sortedClass(dialysisStateColumn.key)">{{ dialysisStateColumn.colName }}</span>
                </div>
              </th>
            </tr>
          </thead>
          <tr
            v-for="(scheduleData, idx) in scheduleList"
            :key="idx"
            :id="'pat-modal-row-' + scheduleData.ordNo"
            :class="'pat-modal-row'"
            @click="onClickRow(scheduleData)"
            style="height: 1.1rem;"
          >
            <!-- FNSI-add 入院・同姓同名配布 徐 start -->
            <!-- <td
              v-for="column in columns"
              class="ntss-list-body-td"
              :key="column.className"
              style="text-align: left;"
            >{{ column.text(scheduleData) }}</td> -->
            <td
              v-for="column in columns"
              :class="[
                'ntss-list-body-td-pat-serch-selected-row',
                column.key === 'hospPatId' ? 'hosp-pat-id-body' : ''
              ]"
              :key="column.className"
              :style="column.style(scheduleData)"
            >{{ column.text(scheduleData) }}</td>
            <!-- FNSI-add 入院・同姓同名配布 徐 end -->
            <td
              class="ntss-list-body-td-pat-serch-selected-row"
              :key="dialysisStateColumn.className"
              style="text-align: left;"
            >
              <div>{{ dialysisStateColumn.text(scheduleData) }}</div>
              <div
                class="send-condition-pat-modal-view-start-date"
              >{{ dialysisStartDate(scheduleData.rstStartDate) }}</div>
            </td>
          </tr>
          <tr
            v-if="isDualMode"
            :class="'pat-modal-row'"
            style="height: 1.1rem;"
            class="pat-modal-message-row"
          >
          <!-- mod FNSI-4681 同時条件送信の予定選択画面の案内文のエリアが短い、案内文が不適切 liumx start -->
          <!-- mod FutreNetWeb+SI課題管理No6855 趙 start -->
          <!-- <td-->
          <!--  class="ntss-list-body-td-pat-serch"-->
          <!--  colspan="6"-->
          <!--  style="text-align: left;"-->
          <!--  >特殊浄化治療の複数選択との同時条件送信が可能です。</td>-->
            <td
              class="ntss-list-body-td-pat-serch"
              colspan="6"
              style="text-align: left;"
            >特殊浄化治療の複数選択との同時条件送信が可能です。</td>
          <!-- mod FutreNetWeb+SI課題管理No6855 趙 end -->
          <!-- mod FNSI-4681 同時条件送信の予定選択画面の案内文のエリアが短い、案内文が不適切 liumx end -->
          </tr>
        </table>
      </div>
    </div>

    <div slot="footer" class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <!-- FNSI-add 画面スタイル(ボタン)対応 徐 start -->
        <!-- <v-ons-button class="button denial-btn" @click="closePatSearchModal">キャンセル</v-ons-button> -->
        <v-ons-button class="btn2-cancel denial-btn" @click="closePatSearchModal">キャンセル</v-ons-button>
        <!-- FNSI-add 画面スタイル(ボタン)対応 徐 end -->
      </div>
      <div class="registration-btn-area" style="background:none">
        <!-- FNSI-add 画面スタイル(ボタン)対応 徐 start -->
        <!-- <v-ons-button
          v-if="!isNotSelectedOrd"
          :disabled="!isOkRangeTargetDate"
          class="button registration-btn"
          @click="goScalePage"
        >測定画面へ</v-ons-button> -->
        <v-ons-button
          v-if="!isNotSelectedOrd"
          :disabled="!isOkRangeTargetDate"
          class="btn3-normal registration-btn"
          @click="goScalePage"
        >測定画面へ</v-ons-button>
        <!-- FNSI-add 画面スタイル(ボタン)対応 徐 end -->
      </div>
    </div>
  </modal-base>
</template>

<script>
import { ApiHelper } from "@/apis/AxiosHelper";
import ModalBase from "@/components/modals/ModalBase";
import { mapGetters, mapActions } from "vuex";
import {
  dialysisStateMsg,
  weightScaleClassByDialysisState
} from "@/functions/common/WeightFunctions";
import {
  dialysisState
  // @ts-ignore
} from "@/constants/weightDefine";
import moment from "moment";

// 特殊浄化の治療種別コード
import { deviceModeConstant } from "@/constants/weightDefine";
import { EventBus } from "@/eventBus.js";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
//#5590 2023/04/20 ×を常に表示するように修正 張博 start
import DateInput from "@/components/common/DateInput.vue";
//#5590 2023/04/20 ×を常に表示するように修正 張博 end
// add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 start
import store from "@/stores";
// add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 end
import { updateSort, getSortedClass, sortableCompare } from "@/functions/SortFunctions";

export default {
  name: "patSearchModal",
  components: {
    "common-calendar": commonCalender,
    "modal-base": ModalBase,
    //#5590 2023/04/20 ×を常に表示するように修正 張博 start
    "date-input":DateInput,
    //#5590 2023/04/20 ×を常に表示するように修正 張博 end

  },
  data() {
    return {
      header: "",
      // 選択日付
      targetDate: moment().format("YYYY-MM-DD"),
      // 複数選択用選択情報
      selectedOrdNoList: [null, null],
      filter: {
        // 選択クール
        selectKur: -1,
        // 選択ベッドグループ
        selectBedGroup: -1,
        // 治療中表示フィルタ
        isFilterTreating: false,
        // 条件確認済みフィルタ
        isFilterChecked: false
      },
      sort: {
        key: "",
        isAsc: true
      },
      // 複数選択モード
      isDualMode: false,

      tableTop: 0,
      tableHeight: 300,

      checkedOrdValue: [],
      initialized: false
    };
  },
  computed: {
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("send-condition/schedule", [
      "getScheduleList",
      "getMstKurSelector",
      "getMstBedGroupList",
      "getFilteringHospPatId"
    ]),
    ...mapGetters("send-condition/weight", ["getSelectedMstWeight"]),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("account-edit", {
      getFontSize: "getFontSize",
    }),
    defaultSelect: () => 0,
    /**
     * カラム情報
     * - key: ソートキー
     */
    columns() {
      return [
        {
          key: "hospPatId",
          colName: "患者ID",
          className: "hospPatIdBody",
          width: 3,
          centerAlign: false,
          text: src => src.hospPatId,
          // FNSI-add 入院・同姓同名配布 徐 start
          style: src => (src.inOutClass ? "text-align: left;" : "text-align: left;")
          // FNSI-add 入院・同姓同名配布 徐 end
        },
        {
          key: "patName",
          colName: "患者名",
          className: "patLastNameBody",
          width: 8,
          centerAlign: false,
          //mod 9251 nullを空文字列判定に変換します 張博 start
          text: src => (src.patLastName == null ? "" : src.patLastName)
          + " " + (src.patFirstName == null ? "" : src.patFirstName),
          //mod 9251 nullを空文字列判定に変換します 張博 end
          // FNSI-add 入院・同姓同名配布 徐 start
          style: src => (src.inOutClass === 1 ? "text-align: left; color: #A356A3;" : "text-align: left;")
          // FNSI-add 入院・同姓同名配布 徐 end
        },
        {
          key: "patBirthday",
          colName: "生年月日",
          className: "patBirthdayBody",
          width: 2,
          centerAlign: false,
          text: src => src.patBirthday ? moment(src.patBirthday).format("YYYY/MM/DD") : "",
          // FNSI-add 入院・同姓同名配布 徐 start
          style: src => (src.inOutClass ? "text-align: left;" : "text-align: left;")
          // FNSI-add 入院・同姓同名配布 徐 end
        },
        {
          key: "isSame",
          colName: "同姓同名",
          className: "isSameBody",
          width: 2,
          centerAlign: false,
          text: src => (src.isSame === "0" ? "" : "あり"),
          // FNSI-add 入院・同姓同名配布 徐 start
          style: src => (src.inOutClass ? "text-align: left;" : "text-align: left;")
          // FNSI-add 入院・同姓同名配布 徐 end
        },
        {
          key: "treatmentName",
          colName: "治療方法名",
          className: "treatmentNameBody",
          width: 5,
          centerAlign: false,
          text: src => src.treatmentName,
          // FNSI-add 入院・同姓同名配布 徐 start
          style: src => (src.inOutClass ? "text-align: left;" : "text-align: left;")
          // FNSI-add 入院・同姓同名配布 徐 end
        },
        {
          key: "kurName",
          colName: "クール",
          className: "kurNameBody",
          width: 5,
          centerAlign: false,
          text: src => src.kurName,
          // FNSI-add 入院・同姓同名配布 徐 start
          style: src => (src.inOutClass ? "text-align: left;" : "text-align: left;")
          // FNSI-add 入院・同姓同名配布 徐 end
        },
        {
          key: "bedName",
          colName: "ベッド名",
          className: "bedNameBody",
          /* mod FNSI-4198 タブレット表示の際の患者検索モーダルのレイアウト不正 liumx start */
          width: 12,
          /* mod FNSI-4198 タブレット表示の際の患者検索モーダルのレイアウト不正 liumx end */
          centerAlign: false,
          text: src => src.bedName,
          // FNSI-add 入院・同姓同名配布 徐 start
          style: src => (src.inOutClass ? "text-align: left;" : "text-align: left;")
          // FNSI-add 入院・同姓同名配布 徐 end
        }
      ];
    },
    dialysisStateColumn() {
      return {
        key: "rstDialysisState",
        colName: "治療状況",
        className: "rstDialysisStateBody",
        width: 7,
        text: src => dialysisStateMsg(src.rstDialysisState)
      };
    },
    /**
     * ヘッダ領域の高さを返す
     */
    headerAreaHeight() {
      const elem = document.getElementById(
        "send-condition-pat-modal-search-area"
      );
      if (elem) {
        return elem.clientHeight;
      }
      return 0;
    },
    scheduleList() {
      // 選択状態最更新
      this.clearSelectRow();
      const retList = this.filteredScheduleList(this.sortedItems);

      this.$nextTick(() => {
        for (const selectedOrd of this.selectedOrdNoList) {
          if (selectedOrd) {
            this.changeCheckBox(selectedOrd, true);
          }
        }
      });
      return retList;
    },
    isNotSelectedOrd() {
      return this.selectedOrdNoList[0] === null;
    },
    sortedItems() {
      const list = this.getScheduleList.slice(); // ソート時でstate自体の順序を書き換えないため
      if (this.sort.key) {
        list.sort((a, b) => {
          // 同姓同名の場合 "0":空欄、"1":あり のため昇降逆転
          return sortableCompare(a, b, this.sort.key, this.sort.isAsc, { reverseFields: ["isSame"] });
        });
      }
      return list;
    },
    isOkRangeTargetDate() {
      // 画面遷移可能な範囲の対象日付かどうか
      const targetDate = this.targetDate;
      if (targetDate === null || targetDate === "") {
        return false;
      }
      const targetDateNum = targetDate.replace(/-/g, "");
      if (
        Number(
          moment()
            .add(1, "days")
            .format("YYYYMMDD") - Number(targetDateNum)
        ) < 0
      ) {
        // 翌々日以降
        return false;
      }
      return true;
    }
  },
  methods: {
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("send-condition/scale", ["setSelectOrdNo", "setInputPatId"]),
    ...mapActions("send-condition/schedule", [
      "searchWeightSchedule",
      "setScheduleList",
      "fetchKurBedGroup",
      "setKurBedGroup",
      "setFilteringHospPatId"
    ]),
  // add 8449【デグレ】体重測定画面を開くと患者名欄が緑枠（変更状態）になる zhao start
    //mod #9558 機能帳票でパラメータが正しく渡されていない 房 start
    ...mapActions("send-condition/weight", ["setFocus", "setSelectedPats"]),
    //mod #9558 機能帳票でパラメータが正しく渡されていない 房 end
  // add 8449【デグレ】体重測定画面を開くと患者名欄が緑枠（変更状態）になる zhao end
    findKurSelectorByCode(kurCd) {
      return (this.getMstKurSelector || []).find(
        selector => `${selector.code}` === `${kurCd}`
      );
    },
    getSelectedKurName(kurCd) {
      if (`${kurCd}` === "-1") {
        return "全クール";
      }
      const selector = this.findKurSelectorByCode(kurCd);
      return selector ? selector.name : "全クール";
    },
    dialysisStartDate(rstStartDate) {
      // 治療開始日が過去ならば表示
      if (rstStartDate) {
        const startDate = moment(new Date(rstStartDate));
        const currentDate = moment();
        if (startDate.format("YYYYMMDD") < currentDate.format("YYYYMMDD")) {
          return `${moment(startDate).format("YYYY/MM/DD")} 開始`;
        }
      }
      return null;
    },
    // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
    requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) === '013') {
        // 機能一致
        // 印刷パラメータを応答
        const param = {
          facilityCd: this.getFacilityCd,
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //dialysisDate: this.targetDate,
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          functionCd:'01301',
          date: this.targetDate,
          fromDate: this.targetDate,
          toDate: this.targetDate,
          kurNames: this.getSelectedKurName(this.filter.selectKur),
          bedCdListString: this.filter.selectBedGroup <= '0' ? "全ベッド" : this.getMstBedGroupList.find(bg => bg.roomBedGroupCd === this.filter.selectBedGroup).roomBedGroupName,
          bedCds: this.scheduleList.map(i => i.bedCd).filter((id, i, arr) => arr.indexOf(id) === i),
          patIds: this.scheduleList.map(item => item.patId).filter((id, i, arr) => arr.indexOf(id) === i),
          ordNos: this.scheduleList.map(item => item.ordNo).filter((id, i, arr) => arr.indexOf(id) === i),
        };
        EventBus.$emit("sendReportParams", param);
      }
    },
    // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
    onChangeDate() {
      // 対象日付の変更
      if (this.targetDate == null) {
        this.targetDate = moment().format("YYYY-MM-DD");
      }
      if (this.targetDate == "") {
        this.setScheduleList([]);
        return;
      }
      const targetDate = this.targetDate.replace(/-/g, "");
      let isPast = false;
      if (Number(targetDate) - Number(moment().format("YYYYMMDD")) < 0) {
        // 過去日
        isPast = true;
      }
      // FNSI-修正 ログ対応 徐 start
      let msg = '患者検索が[' + targetDate +  ']で検索しました。';
      let paramObj = {'message': msg, 'functionName': '患者検索'};
      ApiHelper.put("/logs/event/conditionlog", paramObj)
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('PatSearchModal.vue', 'onChangeDate', error);
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
        });
      // FNSI-修正 ログ対応 徐 end
      // スケジュールを取得
      this.searchWeightSchedule({ treatDate: targetDate, isPast: isPast }).then(
        response => {
          // 選択解除
          this.selectedOrdNoList = [null, null];
          // 行選択状態削除
          this.clearSelectRow();
          // 取得したスケジュールをセット
          this.setScheduleList(response.data);
          // 複数選択モード解除
          this.isDualMode = false;
        }
      );
    },
    // 昇順/降順のclassを作成
    sortedClass(key) {
      return getSortedClass(key, this.sort);
    },
    // ソートするキーを設定する
    sortBy(key) {
      updateSort(key, this.sort);
    },
    changeCheckBox(ordNo, checked) {
      this.checkedOrdValue[ordNo] = checked;
      // 行変更
      let rowElem = document.getElementById(`pat-modal-row-${ordNo}`);
      if (checked) {
        rowElem?.classList?.add("pat-modal-selected-row");
      } else {
        rowElem.classList.remove("pat-modal-selected-row");
      }
    },
    // 行選択状態削除
    clearSelectRow() {
      for (let elem of document.getElementsByClassName(
        "pat-modal-selected-row"
      )) {
        elem.classList.remove("pat-modal-selected-row");
      }
    },
    // グリッドクリックイベント
    onClickRow(src) {
      const idx = this.selectedOrdNoList.findIndex(
        r => Number(r) === src.ordNo
      );
      if (idx >= 0) {
        // 選択済み
        if (idx === 0) {
          // 1番目に選択済み箇所の場合は[1]を[0]にスライドさせる
          this.selectedOrdNoList.shift();
          this.selectedOrdNoList.splice(1, 1, null);
        } else if (idx === 1) {
          // 2番目に選択済み箇所の場合は[1]を除去
          this.selectedOrdNoList.splice(1, 1, null);
        }
        this.changeCheckBox(src.ordNo, false);
        return;
      }

      // 未選択の場合
      if (this.selectedOrdNoList[0] === null) {
        // 1件目
        this.selectedOrdNoList.splice(0, 1, src.ordNo);
        this.changeCheckBox(src.ordNo, true);
        this.goNextOrFilter(this.getScheduleList, src.ordNo);
        return;
      }
      // this.selectedOrdNoList[0]で選択済みの指示
      const selectedSrc = this.getScheduleList.find(
        r => r.ordNo === this.selectedOrdNoList[0]
      );
      if (this.selectedOrdNoList[1] === null) {
        // 2件目
        if (
          selectedSrc.patId === src.patId &&
          weightScaleClassByDialysisState(selectedSrc.rstDialysisState) ===
            weightScaleClassByDialysisState(src.rstDialysisState)
        ) {
          // 同じ患者で前後体重測定モードが同じの場合
          if (
            src.deviceMode === deviceModeConstant.PURIFICATION ||
            selectedSrc.deviceMode === deviceModeConstant.PURIFICATION
          ) {
            // 透析＋特殊浄化または特殊浄化同士は複数選択可能
            this.selectedOrdNoList.splice(1, 1, src.ordNo);
            this.changeCheckBox(src.ordNo, true);
          } else {
            // 透析+透析は選択切り替え
            this.changeCheckBox(this.selectedOrdNoList[0], false);
            this.selectedOrdNoList.splice(0, 1, src.ordNo);
            this.changeCheckBox(src.ordNo, true);
          }
        } else {
          // 違う患者,治療状況の場合は選択切り替え
          this.changeCheckBox(this.selectedOrdNoList[0], false);
          this.selectedOrdNoList.splice(0, 1, src.ordNo);
          this.changeCheckBox(src.ordNo, true);
        }
      } else {
        // 3件目
        // 選択不可
      }
    },
    goNextOrFilter(scheduleList, ordNo) {
      if (scheduleList === null) {
        this.goScalePage();
        return;
      }
      const selectedSrc = this.getScheduleList.find(r => r.ordNo === ordNo);
      let filteredList = scheduleList
        .filter(dat => {
          // 自分自身は含める
          if (dat.ordNo === selectedSrc.ordNo) {
            return true;
          }
          // 同一ユーザーフィルター作成
          const isSamePat = dat.patId === selectedSrc.patId;

          // 治療状況フィルター作成
          let isDialysisStateSame = false;
          if (
            Number(dat.rstDialysisState) <
              Number(dialysisState.checkedSendCondition) &&
            Number(selectedSrc.rstDialysisState) <
              Number(dialysisState.checkedSendCondition)
          ) {
            // 条件確認前
            isDialysisStateSame = true;
          } else if (
            Number(dat.rstDialysisState) === Number(dialysisState.dialysis) &&
            Number(selectedSrc.rstDialysisState) ===
              Number(dialysisState.dialysis)
          ) {
            // 治療中（車いす先行測定）
            isDialysisStateSame = true;
          } else if (
            Number(dat.rstDialysisState) > Number(dialysisState.dialysis) &&
            Number(selectedSrc.rstDialysisState) >
              Number(dialysisState.dialysis)
          ) {
            // 治療後
            isDialysisStateSame = true;
          }

          const retValue = isSamePat && isDialysisStateSame;
          return retValue;
        })
        .slice();

      if (filteredList.length === 1) {
        this.goScalePage();
        return;
      } else {
        // フィルター初期化
        this.filter.selectKur = -1;
        this.filter.selectBedGroup = -1;
        // 選択状態削除
        this.clearSelectRow();
        // リスト
        this.setScheduleList(filteredList).then(() => {
          this.$nextTick(() => {
            this.changeCheckBox(this.selectedOrdNoList[0], true);
          });
        });
        // 複数選択モードフラグON
        this.isDualMode = true;
      }
    },
    // クール・ベッドグループ変更時
    /**
     * フィルタリング処理
     */
    filteredScheduleList(scheduleList) {
      if (scheduleList === null) {
        return null;
      }

      const ret = scheduleList
        .filter(dat => {
          // クールフィルター作成
          let isFilteringKur = true;
          if (`${this.filter.selectKur}` !== "-1") {
            isFilteringKur =
              dat.kurCd !== null &&
              `${dat.kurCd}` === `${this.filter.selectKur}`;
          }

          // ベッドグループフィルター作成
          let isFilteringBed = true;
          if (this.filter.selectBedGroup > 0) {
            isFilteringBed = false;
            let bedGroup = this.getMstBedGroupList.find(bg => bg.roomBedGroupCd === this.filter.selectBedGroup);
            if (bedGroup !== null && bedGroup.bedList)
            {
              for (const bedCd of bedGroup.bedList) {
                if (dat.bedCd === bedCd) {
                  isFilteringBed = true;
                  break;
                }
              }
            }
          }

          // 抽出患者フィルタ作成
          let isTargetPat = true;
          if (this.getFilteringHospPatId) {
            // 抽出患者指定ありかつ対象ならばtrue
            isTargetPat = dat.hospPatId === this.getFilteringHospPatId;
            if (
              !this.initialized &&
              isTargetPat &&
              dat.rstDialysisState === dialysisState.dialysis
            ) {
              // 抽出患者指定ありかつ対象患者で、治療中オーダーならば治療中表示フィルタ初期値を有効にする
              // （その場合はあらかじめ表示しないとわかりづらいため）
              this.filter.isFilterTreating = true;
            }
            if (
              !this.initialized &&
              isTargetPat &&
              dat.rstDialysisState === dialysisState.checkedSendCondition
            ) {
              // 抽出患者指定ありかつ対象患者で、確認済みオーダーならば確認済み表示フィルタ初期値を有効にする
              // （その場合はあらかじめ表示しないとわかりづらいため）
              this.filter.isFilteringChecked = true;
            }
          }
          // 治療中フィルタ作成
          let isFilteringTreating = true;
          if (!this.filter.isFilterTreating) {
            // 治療中以外ならtrue
            isFilteringTreating =
              dat.rstDialysisState !== dialysisState.dialysis;
          }
          // 確認済みフィルタ作成
          let isFilteringChecked = true;
          if (!this.filter.isFilterChecked) {
            // 条件確認済み以外ならtrue
            isFilteringChecked =
              dat.rstDialysisState !== dialysisState.checkedSendCondition;
          }
          const retValue =
            isFilteringKur &&
            isFilteringBed &&
            isFilteringTreating &&
            isFilteringChecked &&
            isTargetPat;
          const selectedIdx = this.selectedOrdNoList.findIndex(
            ord => ord === dat.ordNo
          );
          if (!retValue && selectedIdx >= 0) {
            // 選択済み項目が非表示になった場合は選択済みでなくす
            if (selectedIdx === 0) {
              this.selectedOrdNoList.shift();
              this.selectedOrdNoList.splice(1, 1, null);
            } else {
              this.selectedOrdNoList.splice(1, 1, null);
            }
            this.changeCheckBox(dat.ordNo, false);
          }

          return retValue;
        })
        .slice();

      this.initialized = true;
      //add #9558 機能帳票でパラメータが正しく渡されていない 房 start
      this.setSelectedPats(ret);
      //add #9558 機能帳票でパラメータが正しく渡されていない 房 end
      return ret;
    },
    // 測定画面遷移
    goScalePage() {
      if (this.selectedOrdNoList[0] === null) {
        return false;
      }
      if (this.isOkRangeTargetDate === false) {
        return false;
      }

      // スケジュール選択されている場合
      const selectedSchedule1 = this.getScheduleList.find(
        elm => elm.ordNo === this.selectedOrdNoList[0]
      );
      const selectedSchedule2 = this.getScheduleList.find(
        elm => elm.ordNo === this.selectedOrdNoList[1]
      );

      if (
        selectedSchedule2 !== null &&
        selectedSchedule2 !== undefined &&
        selectedSchedule1.deviceMode === deviceModeConstant.PURIFICATION
      ) {
        // 指示２が選択されていて、指示１が特殊浄化
        if (selectedSchedule2.deviceMode !== deviceModeConstant.PURIFICATION) {
          // 指示２が透析ならば、２つの指示を入れ替える
          const temp = this.selectedOrdNoList.shift();
          this.selectedOrdNoList[1] = temp;
        } else {
          // 指示２が特殊浄化ならば、ordNoが若い方を先にする
          if (this.selectedOrdNoList[1] < this.selectedOrdNoList[0]) {
            const temp = this.selectedOrdNoList.shift();
            this.selectedOrdNoList[1] = temp;
          }
        }
      }

      // 選択した患者情報セット
      this.setInputPatId(selectedSchedule1.hospPatId);
      this.setSelectOrdNo({
        ordNo: this.selectedOrdNoList[0],
        ordNo2: this.selectedOrdNoList[1]
      }).then(() => {
        // 患者情報ヘッダ用に患者情報登録
        this.hideModal();
        EventBus.$emit("loadSendConditionView");
      });
    },
    // キャンセルボタン
    closePatSearchModal() {
      // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 start
      store.dispatch("report/getMstReport", {funcCd: "01302",printFlag: 9});
      // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 end
      // モーダルを非表示に
      this.hideModal();
  // add 8449【デグレ】体重測定画面を開くと患者名欄が緑枠（変更状態）になる zhao start
      this.setFocus("1");
  // add 8449【デグレ】体重測定画面を開くと患者名欄が緑枠（変更状態）になる zhao end
    },

    // モーダルの高さからtableコンポーネント領域の高さを算出
    calculateTableHeight() {
      // mod FNSI-redMine #4462対応  陳 start
      // const ah = this.headerAreaHeight;
      let ah = 0;
      const elem = document.getElementById(
        "send-condition-pat-modal-search-area"
      )
      if(elem.clientHeight) {

        ah = document.getElementById("send-condition-pat-modal-search-area").clientHeight;
      }
      // mod FNSI-redMine #4462対応  陳 end
      const mbh = Array.prototype.slice
        .call(document.getElementsByClassName("modal-body"))
        .shift().clientHeight;

      this.tableHeight = mbh - ah - 3;
      this.tableHeight = this.tableHeight < 100 ? 100 : this.tableHeight;
      // モーダルの高さからGirdコンポーネント領域のTopを算出
      this.$nextTick(() => {
        this.tableTop = ah + 3;
      });

      // add FNSI-redMine #4462対応  陳 start
      // setTimeout(this.calculateTableHeight, 200);
      // add FNSI-redMine #4462対応  陳 end
    }
  },
  created() {
    // クールとベッドグループ情報取得
    this.fetchKurBedGroup().then(response => {
      this.setKurBedGroup(response).then(() => {
        // ベッドグループ読み込み後、選択体重計マスタ情報から初期選択透析室を設定する
        if (this.getSelectedMstWeight && this.getMstBedGroupList) {
          const defaultBedGroupIdx = this.getMstBedGroupList.findIndex(
            g => g.roomBedGroupCd === this.getSelectedMstWeight.bedGroupCd
          );
          /* mod #9600 by zhangruixue 2023-08-23  --start */
          // this.$set(this.filter, "selectBedGroup", defaultBedGroupIdx);
          this.$set(this.filter, "selectBedGroup", this.getMstBedGroupList[defaultBedGroupIdx]?.roomBedGroupCd);
          /* mod #9600 by zhangruixue 2023-08-23  --end */
        }
      });
    });
    // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
    EventBus.$off("requestReportParams", this.requestrReportParams);
    EventBus.$on("requestReportParams", this.requestrReportParams);
    // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
  },
  mounted() {
    this.$nextTick(() => {
      this.calculateTableHeight();
    });
  },
  beforeDestroy() {
    this.setFilteringHospPatId(null);
    this.initialized = false;
    // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
  },
  // FNSI-修正 ログ対応 徐 start
  watch: {
    'filter.selectKur'() {
      const name = this.getSelectedKurName(this.filter.selectKur);
      let msg = '患者検索が[' + name +  ']で検索しました。';
      let paramObj = {'message': msg, 'functionName': '患者検索'};
      ApiHelper.put("/logs/event/conditionlog", paramObj)
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('PatSearchModal.vue', 'watch', error);
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
        });
    },
    'filter.selectBedGroup'() {
      let name = '';
      if (this.filter.selectBedGroup > 0) {
        let bedGroup = this.getMstBedGroupList.find(bg => bg.roomBedGroupCd === this.filter.selectBedGroup);
        if (bedGroup !== null )
        {
          name = bedGroup.roomBedGroupName
        }
      } else {
        name = '全ベッド';
      }
      let msg = '患者検索が[' + name +  ']で検索しました。';
      let paramObj = {'message': msg, 'functionName': '患者検索'};
      ApiHelper.put("/logs/event/conditionlog", paramObj)
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('PatSearchModal.vue', 'watch', error);
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
        });
    },
    'filter.isFilterTreating'() {
      if (this.filter.isFilterTreating) {
        let msg = '患者検索が[治療中表示(車いす先測定用)]で検索しました。';
        let paramObj = {'message': msg, 'functionName': '患者検索'};
        ApiHelper.put("/logs/event/conditionlog", paramObj)
          .catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
            getErrorMessage('PatSearchModal.vue', 'watch', error);
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          });
      }
    },
    'filter.isFilterChecked'() {
      if (this.filter.isFilterChecked) {
        let msg = '患者検索が[条件送信確認済み表示]で検索しました。';
        let paramObj = {'message': msg, 'functionName': '患者検索'};
        ApiHelper.put("/logs/event/conditionlog", paramObj)
          .catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
            getErrorMessage('PatSearchModal.vue', 'watch', error);
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          });
      }
    },
    windowHeight() {
      this.calculateTableHeight();
    },
    getFontSize() {
      this.calculateTableHeight();
    },
  }
  // FNSI-修正 ログ対応 徐 end
};
</script>

<style scoped>
.pat-modal-row {
  background-color:var(--ntss-base-background-color);
  /* add FutreNetWeb+SI課題管理No6855 趙 start*/
  color: var(--ntss-list-body-color);
  /* add FutreNetWeb+SI課題管理No6855 趙 end*/
}
.send-condition-pat-modal-list tr:hover {
  background-color: var(--master-maintenance-kgrid-item-hover-background-color);
}
.date-value {
  flex: 0 0 11em;
  white-space: nowrap;
  display: flex;
  align-items: center;
}
.content-vertical-center {
  display: flex;
  justify-content: center;
  align-items: center;
}
.filter-content {
  margin-left: 5px;
}
.horizontal-div {
  display: flex;
  flex-direction: row;
}
.vertical-div {
  display: flex;
  flex-direction: column;
  align-content: flex-start;
}
#send-condition-pat-modal-search-area .vertical-div label {
  font-size: unset;
}
.pat-modal-selected-row {
  background-color: #ccffcc !important;
  /* add FutreNetWeb+SI課題管理No6855 趙 start*/
  color: var(--ntss-list-body-pat-serch-color);
  /* add FutreNetWeb+SI課題管理No6855 趙 end*/
}
.pat-modal-message-row {
  background-color: #99ccff !important;
}
/* add FutreNetWeb+SI課題管理No6855 趙 start*/
.ntss-list-body-td-pat-serch{
  /* 一覧のボーダーライン */
  border: solid 1px var(--ntss-list-border-color);
  padding: 8px;
  color: var(--machine-record-detail-base-color);
}
.ntss-list-body-td-pat-serch-selected-row{
  border: solid 1px var(--ntss-list-border-color);
  padding: 8px;
}
/* add FutreNetWeb+SI課題管理No6855 趙 end*/
/* add #9461  by zhangruixue 2023-08-17 --start */
.modal-body {
  margin: 0px 0;
  position: absolute;
  top: 50px;
  width: 100%;
  height: calc(100% - 70px - 2em);
  color: var(--ntss-base-color);
}
/* add #9461  by zhangruixue 2023-08-17 --end */
.manual-width .resizable-header {
  display: inline-block;
  resize: horizontal;
  overflow: hidden;
  min-width: 100%;
  white-space: nowrap;
  box-sizing: border-box;
  vertical-align: top;
}
.clickable-header-label {
  display: block;
  width: 100%;
  padding: 0 4px;
  box-sizing: border-box;
  overflow: hidden;
}
@media print {
  .ntss-list-header-th-sticky{
    min-width: 0 !important;
  }

  .pat-modal-list-wrapper{
    height:  100% !important;
  }

  .send-condition-pat-modal-list{
    position: static !important;
  }
}
</style>
