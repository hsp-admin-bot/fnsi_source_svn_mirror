<template>
  <div class="modal-mask custom-modal-mask daily-history-modal">
    <div class="modal-wrapper">
      <div class="modal-container">
        <!-- ヘッダ -->
        <div class="modal-header">
          <ons-toolbar>
            <div class="left toolbar__title">
              <span class="custom-h3">点検履歴</span>
            </div>
            <div class="right">
              <ons-toolbar-button class="close-btn print-none" @click="closeHistory">
                <ons-icon icon="fa-times"></ons-icon>
              </ons-toolbar-button>
            </div>
          </ons-toolbar>
        </div>

        <!-- メイン要素 -->
        <div class="modal-body">
          <div id="selectUnitArea" class="history-header-modal" style="overflow: auto;">
            <!-- 検索条件 -->
            <common-searcharea
              id="daily-history-condition-list"
              style="height: 5em; min-width: 200px; margin-top: 1px; max-height: 4.1em;"
              :conditionList="conditionList"
              @show-popover="showPopover"
            />

            <!-- 装置情報 -->
            <table class="ntss-list-detail">
              <tr>
                <th class="list-header-th-center">ベッド</th>
                <th class="list-header-th-center">型式</th>
                <th class="list-header-th-center">製造番号</th>
                <th class="list-header-th-center">装置名</th>
              </tr>
              <tr>
                <td class="ntss-list-body-td">{{ getMachine.bedName }}</td>
                <td class="ntss-list-body-td">{{ getMachine.machineType }}</td>
                <td class="ntss-list-body-td">{{ getMachine.machineSerial }}</td>
                <td class="ntss-list-body-td">{{ getMachine.machineName }}</td>
              </tr>
            </table>
          </div>

          <div
            v-if="isDisplay"
            id="listArea"
            class="history-list-modal"
          >
            <kendo-grid
              ref="historyGrid"
              class="tare-offwater"
              :data-source="localDataSource"
              :data-bound="gridDataBound"
              :scrollable="true"
              :resizable="true"
              @columnresize="onColumnResize"
            >
              <kendo-grid-column
                field="rowTitle"
                title="点検項目<br>点検日"
                :width="125"
                :attributes="columnRowNameClass"
                :header-attributes="columnRowNameHeaderClass"
                @editable="handleEditable"
                :locked="true"
              />
              <kendo-grid-column
                field="rowTitle2"
                title="総合合否"
                :width="120"
                :attributes="columnRowNameClass"
                :header-attributes="columnRowNameHeaderClass"
                @editable="handleEditable"
                :locked="false"
              />
              <kendo-grid-column
                v-for="(item, index) in layoutList"
                :key="index"
                :columns="item.columns"
                :title="item.title"
                :header-attributes="columnHeaderClass"
                :header-template="item.headerTemplate"
              />
            </kendo-grid>
          </div>
        </div>

        <!-- フッター -->
        <div slot="footer" class="modal-footer">
          <div class="flex-container">
            <div class="denial-btn-area">
              <button
                class="btn2-cancel button denial-btn"
                @click="closeHistory"
              >閉じる</button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <v-ons-popover
      cancelable
      :visible.sync="popoverVisible"
      target="#daily-history-condition-list"
      direction="down"
      :class="fontSizeSet"
      style="width: auto;"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div id="popover" style="margin: 10px;">
        <v-ons-row class="popover-row-style">
          <v-ons-col
            class="custom-ons-col"
            style="white-space: nowrap; margin-right: 0.5em;"
          >
            <div class="custom-line-height">
              <span class="dailyHistory-checkday-span">点検日:</span>
              <date-input
                type="date"
                id="input-search-date"
                class="hide-arrow-calendar search-history-date"
                max="9999-12-31"
                isRequired
                v-model="condition.inProgress.mainteDate"
              />
              <common-calendar
                class="history-date-comment"
                v-model="condition.inProgress.mainteDate"
              />
              <label> から</label>
            </div>
          </v-ons-col>
          <v-ons-col
            class="custom-ons-col"
            style="white-space: nowrap;"
          >
            <div class="custom-line-height">
              <label>過去 </label>
              <input
                type="number"
                class="distance-time"
                style="text-align: right;"
                min="1"
                max="99"
                v-model="condition.inProgress.numOfMonth"
                @change="inputValidValue"
                @mousewheel.prevent="stopScrollFun"
                @blur="handleBlur"
                @focus="handleFocus"
              />
              <label> か月</label>
            </div>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col width="30%" vertical-align="center">
            <div class="popover-label">
              <label
                style="align-content: center;"
                class="fab-font-color"
              >点検途中</label>
            </div>
          </v-ons-col>
          <v-ons-col width="30%" vertical-align="center">
            <v-ons-switch v-model="condition.inProgress.dailyRunning" />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col width="30%" vertical-align="center">
            <div class="popover-label">
              <label
                style="align-content: center;"
                class="fab-font-color"
              >不合格</label>
            </div>
          </v-ons-col>
          <v-ons-col width="30%" vertical-align="center">
            <v-ons-switch v-model="condition.inProgress.dailyNotGood" />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col width="30%" vertical-align="center">
            <div class="popover-label">
              <label
                style="align-content: center;"
                class="fab-font-color"
              >全件合格</label>
            </div>
          </v-ons-col>
          <v-ons-col width="30%" vertical-align="center">
            <v-ons-switch v-model="condition.inProgress.dailyGood" />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col width="30%" vertical-align="center">
            <div class="popover-label">
              <label
                style="align-content: center;"
                class="fab-font-color"
              >未実施日</label>
            </div>
          </v-ons-col>
          <v-ons-col width="30%" vertical-align="center">
            <v-ons-switch v-model="condition.inProgress.notDailyDate" />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row" style="margin: 0">
          <v-ons-col width="30%" vertical-align="center">
            <v-ons-button
              class="btn2-cancel"
              @click="dialogClear"
            >クリア</v-ons-button>
          </v-ons-col>
          <v-ons-col vertical-align="center"></v-ons-col>
          <v-ons-col width="30%" vertical-align="center">
            <v-ons-button
              class="btn1-execute"
              style="margin-bottom: 0;"
              @click="dialogOk"
            >OK</v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
    </v-ons-popover>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import { EventBus } from "@/eventBus";
import commonSearchArea from "@/components/common/CommonSearchArea";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import moment from "moment";
import $ from "jquery";
import PopoverMixin from "@/components/PopoverMixin";
import {
  popoverPreShow,
  popoverPostShow,
  popoverPosthide,
} from "@/functions/common/CommonPopoverFunctions";
import { alertByKey } from "@/functions/common/OnsenFunctions";
import { convertStatus } from "@/functions/DailyInspectionFunction";
import DateInput from "@/components/common/DateInput";
import {
  Answer,
  StatusText,
} from "@/constants/mainteConstants";
import { getCurrentFunctionCd } from "@/router/routing-helper";
import PrintMixin from "@/components/PrintMixin";

const columnRowNameClass = { class: "deviceSetInfo-row-name" };
const columnRowNameHeaderClass = { class: "deviceSetInfo-header-row-name" };
const columnHeaderClass = { class: "deviceSetInfo-header-first-name" };
const columnHeaderSecendClass = { class: "deviceSetInfo-header-secound-name" };

export default {
  components: {
    "common-searcharea": commonSearchArea,
    "common-calendar": commonCalender,
    "date-input": DateInput,
  },
  mixins: [PopoverMixin, PrintMixin],
  data() {
    return {
      popoverVisible: false,
      condition: {
        // 入力中の検索条件
        inProgress: createDefaultConditon(),
        // 検索に使用される条件
        inUsed: createDefaultConditon(),
      },
      isDisplay: true,
      localDataSource: {
        schema: {
          model: {
            id: "rowNum",
            fields: {
              rowTitle: { nullable: false },
              rowTitle2: { nullable: false },
            },
          },
        },
        data: [],
      },
      minValue: 1,
      maxValue: 99,
      focusFlg: false,
      columnRowNameClass,
      columnRowNameHeaderClass,
      columnHeaderClass,
      scrollQuerySelector: ".k-grid-content", // スクロールコンテナ
      addClassTargetQuerySelector: [".k-grid-header-wrap table, .k-grid-content table"], // scroll-rightmostクラスを付与する対象のクエリセレクタ
    };
  },
  computed: {
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("daily-check", [
      "getMachine",
      "getMachineResult",
      "getUserAccountInfo",
      "getResultMasterHis",
      "getLayoutParams",
      "getCondition",
      "getConditionForReportParams",
    ]),
    ...mapGetters("mst-holiday", ["getHolidays"]),
    ...mapGetters("account-edit", ["getFontSize"]),
    ...mapGetters("window-size", [
      "getWindowHeight",
      "getWindowWidth",
    ]),
    ...mapGetters("periodic-inspection", ["getStorSimlpSearchQurey"]),

    conditionList() {
      const conditionList = [];
      const layoutParams = this.getLayoutParams;
      if (!layoutParams) return conditionList;

      conditionList.push({
        text: moment(layoutParams.mainteDate).format("YYYY/MM/DD"),
      });
      conditionList.push({
        text: `過去${layoutParams.numOfMonth}か月`,
      });

      if (layoutParams.dailyRunning) {
        conditionList.push({ text: "点検途中" });
      }
      if (layoutParams.dailyNotGood) {
        conditionList.push({ text: "不合格" });
      }
      if (layoutParams.dailyGood) {
        conditionList.push({ text: "全件合格" });
      }
      if (layoutParams.notDailyDate) {
        conditionList.push({ text: "未実施日" });
      }

      return conditionList;
    },
    layoutList() {
      return this.getResultMasterHis.map((item, index) => ({
        columns: createMultiColumnInfo(item, index),
        title: item.layoutName,
        headerTemplate: `<label style="margin-left: 1em;">${item.layoutName}</label>`,
      }));
    },
  },
  methods: {
    ...mapActions("daily-check", [
      "setLayoutParams",
      "sendRequestGetDetailHistory",
      "sendRequestGetMachineResult",
      "setUserAccountInfo",
    ]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,

    showPopover() {
      // 入力値を初期化する
      Object.assign(this.condition.inProgress, this.condition.inUsed);
      this.popoverVisible = true;
    },
    handleEditable() {
      return false;
    },
    setArrRow() {
      const arrRow = Array.from(document.getElementsByClassName("deviceSetInfo-row-name"));
      arrRow.forEach(item => {
        item.style.color = "var(--ntss-list-body-color)";

        // 日付色変更
        const dateCurrent = moment().format("YYYYMMDD");
        const date = moment(item.textContent.substring(0, 10));
        if (date.isSame(dateCurrent)) {
          item.style.backgroundColor = "#2ca06f";
          item.style.color = "#FFF";
        }
        if (date.day() === 6) {
          item.style.color = "var(--ntss-saturday-color-n)";
        }
        if (date.day() === 0) {
          item.style.color = "var(--ntss-sunday-color)";
        }

        const holidays = this.getHolidays;
        if (holidays[date.format("YYYY-MM-DD")] != null) {
          item.style.color = "var(--ntss-holiday-color)";
        }
      });
    },
    /**
     * サイズ調整用のパーツ
     */
    // padding取得(スクロール要素)
    getPaddingList() {
      // padding要素のpxを取得
      const elm = document.getElementsByClassName("k-auto-scrollable")[1];
      const paddingY = elm.getBoundingClientRect().height - parseFloat(getComputedStyle(elm).height);
      const paddingX = elm.getBoundingClientRect().width - parseFloat(getComputedStyle(elm).width);
      return {
        x: paddingX,
        y: paddingY,
      };
    },
    // padding取得(モーダル要素)
    getPaddingBody() {
      // padding要素のpxを取得
      const elm = document.getElementsByClassName("modal-body")[1];
      const paddingY = elm.getBoundingClientRect().height - parseFloat(getComputedStyle(elm).height);
      const paddingX = elm.getBoundingClientRect().width - parseFloat(getComputedStyle(elm).width);
      return {
        x: paddingX,
        y: paddingY,
      };
    },
    /**
     * テーブル内の各行の高さの調節を行う
     */
    rowHeightResize() {
      // tr要素取得
      const lockTrs = $(".k-grid-content-locked").find("tr");
      const scrollTrs = $(".k-grid-content.k-auto-scrollable").find("tr");

      // 高さ設定
      for (let i = 0; i < lockTrs.length; i++) {
        const lockTr = lockTrs[i];
        const scrollTr = scrollTrs[i];

        // スタイルリセット
        lockTr.style.height = "auto";
        scrollTr.style.height = "auto";

        // 要素の高さを取得
        const lockH = lockTr.getBoundingClientRect().height;
        const scrollH = scrollTr.getBoundingClientRect().height;

        // 高さが異なる場合は高いほうに合わせる
        if (lockH < scrollH) {
          lockTr.style.height = `${scrollH}px`;
        } else if (scrollH < lockH) {
          scrollTr.style.height = `${lockH}px`;
        }
      }
    },
    /**
     * スクロール可能部分の縦スクロールがヘッダとズレる場合があるため
     * スクロール可能部分のヘッダと、一覧の幅を調整する
     */
    scrollAbleWidthResize() {
      // ヘッダ部のpaddingを調整
      document.getElementsByClassName("k-grid-header")[0].style.paddingRight = `${this.getPaddingList().x}px`;

      // 要素の幅を取得
      const gridHed = $(".k-grid-header");
      const gridHedLocked = $(".k-grid-header-locked");
      const allW = gridHed.get(0).getBoundingClientRect().width;
      const lockHedW = gridHedLocked.get(0).getBoundingClientRect().width;

      // あるべき幅の設定
      const fixW = allW - lockHedW;
      document.getElementsByClassName("k-auto-scrollable")[1].style.width = `${fixW}px`;
    },
    /**
     * 表全体の幅の調整
     */
    setTableWidth() {
      // 幅の調整
      const MIN_WIDTH = 400;
      const mBody = $(".modal-body");
      // 現在の要素の幅を取得
      const allW = mBody.get(1).getBoundingClientRect().width;

      // 最小幅を下回った場合
      if (allW < MIN_WIDTH) {
        const scroll = $(".k-auto-scrollable");
        const locked = $(document.getElementsByClassName("k-grid-content-locked")[0]);
        // 親のdiv要素の幅を一覧の幅に合わせる
        document.getElementsByClassName("history-list-modal")[0].style.width = "fit-content";
        // widthをautoで上書き
        document.getElementsByClassName("k-auto-scrollable")[1].style.width = "auto";
        // 一覧部分の横スクロールが消えるため、固定列とスクロール列の高さを合わせる
        document.getElementsByClassName("k-auto-scrollable")[1].style.height = `${locked.innerHeight()}px`;
        // カラムヘッダの横幅を明細部分に合わせる
        const scrollW = scroll.get(1).getBoundingClientRect().width;
        const lockedW = locked.get(0).getBoundingClientRect().width;
        document.getElementsByClassName("k-grid-header")[0].style.width = `${scrollW + lockedW - this.getPaddingList().x}px`;
      } else {
        // widthをautoで上書き
        document.getElementsByClassName("k-grid-header")[0].style.width = "auto";
        // 親のdiv要素の幅をリセット
        document.getElementsByClassName("history-list-modal")[0].style.width = "";
      }
    },
    /**
     * 表全体の高さの調整
     */
    setTableHeight() {
      // 最小高さの設定
      const MIN_HEIGHT = 100;
      // min-heightの適用
      document.getElementsByClassName("k-auto-scrollable")[1].style.minHeight = `${MIN_HEIGHT}px`;
      document.getElementsByClassName("k-grid-content-locked")[0].style.minHeight = `${MIN_HEIGHT - this.getPaddingList().y}px`;

      // 高さの調整
      // 座標計算の為スクロール位置を0指定
      const mBodyScrollPosition = document.getElementsByClassName("modal-body")[1].scrollTop;
      document.getElementsByClassName("modal-body")[1].scrollTop = 0;

      // 目標の高さの計算
      const fotterTop = document.getElementsByClassName("modal-footer")[0].getBoundingClientRect().top;
      const scrollTop = document.getElementsByClassName("k-auto-scrollable")[1].getBoundingClientRect().top;
      const fixH = Math.floor(fotterTop - scrollTop - this.getPaddingBody().y);

      // スクロール位置を元に戻す
      document.getElementsByClassName("modal-body")[1].scrollTop = mBodyScrollPosition;

      // 最小の高さを下回る場合autoで設定
      if (fixH <= MIN_HEIGHT) {
        document.getElementsByClassName("k-auto-scrollable")[1].style.height = "auto";
        document.getElementsByClassName("k-grid-content-locked")[0].style.height = "auto";
      } else {
        document.getElementsByClassName("k-auto-scrollable")[1].style.height = `${fixH}px`;
        document.getElementsByClassName("k-grid-content-locked")[0].style.height = `${fixH - this.getPaddingList().y}px`;
      }
    },
    /**
     * 表全体の高さ/幅の設定を行う
     * 縦スクロール制御
     * 　・通常時
     * 　　フッター要素のギリギリまで伸ばす
     * 　・2重の縦スクロールが発生しそうになった場合
     * 　　heightをautoとし
     * 　　外側のスクロールで表全体を見るようにする
     * 横スクロール制御
     * 　・最小の幅よりも小さくなった場合widthをautoとし
     * 　　外側のスクロールで表全体を見るようにする
     */
    setTableWidthHeight() {
      // 高さの調整(1回目)
      this.setTableHeight();
      // 幅の調整
      this.setTableWidth();
      // スクロール可能幅の調整
      this.scrollAbleWidthResize();
      // 高さの調整(2回目)
      // 　幅の調整が完了するまでモーダルの横スクロールが出るため
      // 　スクロールバーの分だけ高さが不足してしまう
      // 　幅の調整完了後、再度高さの調整が必要となる
      this.setTableHeight();
    },
    gridSetting() {
      this.$nextTick(() => {
        // 一覧部分にスタイル設定(文字列を改行して全体表示)
        const rowNames = Array.from(document.getElementsByClassName("deviceSetInfo-row-name"));
        rowNames.forEach(item => {
          item.style = "word-break: break-all; word-wrap: break-word; white-space: normal;";
        });
        const arr = Array.from(document.getElementsByClassName("deviceSetInfo-header-secound-name"));
        arr.forEach(item => {
          item.style = "word-break: break-all; word-wrap: break-word; white-space: normal;"
          if (item.offsetHeight > 200) {
            item.style = "";
          }
        })
        this.$refs.historyGrid.$el.style.borderStyle = "none";
        // 行高さの調整
        this.rowHeightResize();
        // 全体の調整
        this.setTableWidthHeight();
        // スタイル設定
        this.setArrRow();
      });
      this.$refs.historyGrid.$el.firstElementChild.style.backgroundColor = "var(--ntss-list-header-background-color)";
      this.$refs.historyGrid.$el.firstElementChild.firstElementChild.style.borderColor = "var(--ntss-base-background-color)";
      document.getElementsByClassName("k-auto-scrollable")[1].style.WebkitOverflowScrolling = "touch";
    },
    gridDataBound() {
      // clickイベントの設定
      const gridRoot = this.$refs.historyGrid.$el;
      const gridContent = gridRoot.getElementsByClassName("k-grid-content")[0];
      const contentTrList = gridContent.getElementsByTagName("tr");
      const gridLocked = gridRoot.getElementsByClassName("k-grid-content-locked")[0];
      const lockedTrList = gridLocked.getElementsByTagName("tr");
      const localData = this.localDataSource.data;
      for (let i = 0; i < localData.length; i++) {
        const rowTitle = localData[i].rowTitle;
        const handleClick = () => {
          const rowDate = moment(rowTitle.split("(")[0]).format("YYYY-MM-DD");
          this.goToBack(rowDate);
        };
        contentTrList[i]?.addEventListener("click", handleClick);
        lockedTrList[i]?.addEventListener("click", handleClick);
      }
      // スタイル設定
      this.gridSetting();

      if (!gridLocked || !gridContent) return;
      if (gridLocked) {
        let startY = 0;
        // タッチ開始位置を記録（iOS/Android対応）
        gridLocked.addEventListener("touchstart", (e) => {
          startY = e.touches[0].clientY;
        }, { passive: false });

        gridLocked.addEventListener("touchmove", (e) => {
          // タッチ移動に応じてスクロール（iOS/Android対応）
          const deltaY = startY - e.touches[0].clientY;
          gridLocked.scrollTop += deltaY;
          startY = e.touches[0].clientY;
          e.preventDefault(); // 慣性スクロールを有効にするために必要
        }, { passive: false });
      }

      if (gridLocked && gridContent) {
        // 固定列のスクロールに応じて可動列を同期（縦スクロールの一体化）
        gridLocked.addEventListener("scroll", () => {
          gridContent.scrollTop = gridLocked.scrollTop;
        });

        // 可動列のスクロールに応じて固定列を同期（双方向同期）
        gridContent.addEventListener("scroll", () => {
          gridLocked.scrollTop = gridContent.scrollTop;
        });
      }
    },
    goToBack(rowDate) {
      // 点検項目入力画面に点検日を渡して点検履歴を閉じる
      this.closeHistoryWithParams({ date: rowDate });
    },
    async search() {
      this.setLoadingScreenVisible(true);
      this.isDisplay = false;

      const {
        mainteDate,
        numOfMonth,
      } = this.condition.inUsed;
      const endDate = moment(mainteDate)
        .subtract(numOfMonth, "month")
        .format("YYYY-MM-DD");
      const params = {
        machineNo: this.getMachine.machineNo,
        date: mainteDate,
        numOfMonth,
      };
      const machine = {
        machineNo: this.getMachine.machineNo,
        startDate: mainteDate,
        endDate,
        facilityCd: this.getFacilityCd,
      };
      await Promise.all([
        // 点検レイアウトマスタと点検項目マスタの情報を取得
        this.sendRequestGetDetailHistory(params),
        // 点検結果の情報を取得
        this.sendRequestGetMachineResult(machine),
        // 最終更新者の氏名取得用のユーザー情報を取得
        this.setUserAccountInfo(this.getFacilityCd),
      ]);

      // 表示データ更新
      this.renewLocalDataSource();

      this.isDisplay = true;
      this.setLoadingScreenVisible(false);
    },
    dialogOk() {
      const inProgress = this.condition.inProgress;
      let validate = true;
      if (!inProgress.mainteDate) {
        validate = false;
        // title: "チェックエラー",
        // message: "日付を無効にする。"
        alertByKey("00200005");
      }
      // stringからnumberに変換しておく
      inProgress.numOfMonth = Number(inProgress.numOfMonth);
      if (inProgress.numOfMonth < 1) {
        validate = false;
        // title: "チェックエラー",
        // message: "過去年数を無効にする。"
        alertByKey("03400006");
      }
      if (inProgress.numOfMonth > 120) {
        inProgress.numOfMonth = 120;
      }
      if (validate) {
        // 入力エラーがなければ検索を実行する
        const inUsed = this.condition.inUsed;
        Object.assign(inUsed, inProgress);
        this.setLayoutParams({ ...inUsed });

        this.popoverVisible = false;
        this.search();
      }
    },
    dialogClear() {
      // 検索条件をデフォルト値にして検索
      Object.assign(this.condition.inProgress, createDefaultConditon());
      this.dialogOk();
    },
    closeHistory() {
      EventBus.$emit("closeHistory");
    },
    closeHistoryWithParams(params) {
      EventBus.$emit("closeHistory", params);
    },
    inputValidValue(event) {
      const valueString = event.target.value;
      let valueNumber = (valueString === "")
        ? createDefaultConditon().numOfMonth
        : Number(valueString);
      // 範囲内の数値に補正する
      if (this.maxValue != null && valueNumber > this.maxValue) {
        valueNumber = this.maxValue;
      }
      if (this.minValue != null && valueNumber < this.minValue) {
        valueNumber = this.minValue;
      }
      // 入力値をnumber値に更新する
      this.condition.inProgress.numOfMonth = valueNumber;
    },
    stopScrollFun(event) {
      if (!this.focusFlg) {
        return;
      }
      const delta = (event.wheelDelta && (event.wheelDelta > 0 ? 1 : -1))
        || (event.detail && (event.detail > 0 ? -1 : 1));
      if (!event.target.value) {
        event.target.value = 0;
      }
      let value = parseFloat(event.target.value);
      const parameterStep = 1;
      if (delta > 0) {
        // 滑ります
        value += parameterStep;
      } else {
        // 下がります
        value -= parameterStep;
      }
      // 数値範囲内かどうかの確認
      if (value > this.maxValue) {
        value = this.minValue;
      }
      if (value < this.minValue) {
        value = this.maxValue;
      }
      this.condition.inProgress.numOfMonth = value;
    },
    handleBlur() {
      this.focusFlg = false;
    },
    handleFocus() {
      this.focusFlg = true;
    },
    initCondition() {
      // created時はdata項目生成処理で検索条件のデフォルト値が設定されている
      const inUsed = this.condition.inUsed;
      if (this.getLayoutParams) {
        // Storeに保存された情報があればinUseに上書きする
        // （ inProgress は入力UIのための変数なので
        // 　showPopover の時点で inUse の内容が反映されるだけで問題ない）
        const {
          mainteDate,
          numOfMonth,
          dailyRunning,
          dailyNotGood,
          dailyGood,
          notDailyDate,
        } = this.getLayoutParams;
        if (mainteDate) {
          inUsed.mainteDate = mainteDate;
        }
        if (numOfMonth) {
          inUsed.numOfMonth = numOfMonth;
        }
        if (dailyRunning != null) {
          inUsed.dailyRunning = dailyRunning;
        }
        if (dailyNotGood != null) {
          inUsed.dailyNotGood = dailyNotGood;
        }
        if (dailyGood != null) {
          inUsed.dailyGood = dailyGood;
        }
        if (notDailyDate != null) {
          inUsed.notDailyDate = notDailyDate;
        }
      } else {
        // 初期状態をStoreに保存する
        this.setLayoutParams({ ...inUsed });
      }
    },
    renewLocalDataSource() {
      const inUsed = this.condition.inUsed;
      // 表示対象期間に対応する初期状態のデータを作成
      const localData = createInitLocalData(inUsed);
      // 点検結果データを反映する
      convertGridData(
        localData,
        this.getResultMasterHis,
        this.getMachineResult,
        this.getUserAccountInfo
      );
      // フィルター条件を適用する
      applyFilterLocalData(localData, inUsed);
      this.localDataSource.data = localData;
    },
    requestReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) !== getCurrentFunctionCd().substring(0, 3)) return;

      // 印刷パラメータを応答
      const toDate = (this.getLayoutParams?.mainteDate != null)
        ? moment(this.getLayoutParams.mainteDate)
        : moment();
      const fromDate = moment(toDate);
      if (this.getLayoutParams?.numOfMonth != null) {
        fromDate.subtract(this.getLayoutParams.numOfMonth, "months");
      }
      const mainteNos = (this.getMachineResult?.length)
        ? this.getMachineResult.map(x => x.devMenteNo)
        : [];
      const {
        rstDialysisState,
        kurNames,
        selectedPatGroupNames,
        treatDate,
      } = this.getStorSimlpSearchQurey;
      const expressCondCdStr = (rstDialysisState?.length) ? (
        (rstDialysisState.length === 2) ? "予定・実績" : (
          (rstDialysisState[0] === "1") ? "予定" : "実績"
        )
      ) : "";
      const kurNamesStr = (kurNames?.length) ? kurNames.join("・") : "すべて";
      const patGroups = selectedPatGroupNames || "すべて";
      const {
        bedCdListString,
        machineTypeName,
      } = this.getConditionForReportParams;
      const date = toDate.format("YYYYMMDD");
      const reportParams = {
        functionCd: "03401",
        facilityCd: this.getFacilityCd,
        date,
        fromDate: fromDate.format("YYYYMMDD"),
        toDate: date,
        machineNos: [this.getMachine.machineNo],
        mainteNos,
        treatDate,
        bedCdListString,
        freeWord: this.getCondition.keyword,
        expressCondCdStr,
        kurNames: kurNamesStr,
        patGroups,
        type: machineTypeName.replaceAll("、", "・"),
      };
      EventBus.$emit("sendReportParams", reportParams);
    },
    onColumnResize() {
      this.gridSetting();
    },
    // 固定列幅変更中のtable幅にdiv幅を追随させるためのイベントハンドラ
    onColumnResizingMouseMove(event) {
      // 左ボタン押下状態でなければ処理対象外
      if (event.buttons !== 1) return;
      // グリッド要素が存在していなければ処理対象外
      const grid = this.$refs.historyGrid?.$el;
      if (!grid) return;

      // 固定列ヘッダーと固定列ボディのdivの幅がその中のtableの幅と異なる場合は
      // divの幅をtableの幅に合わせる
      ["k-grid-header-locked", "k-grid-content-locked"].forEach(className => {
        const lockedDiv = grid.getElementsByClassName(className)[0];
        const lockedTable = lockedDiv?.getElementsByTagName("table")[0];
        if (lockedDiv && lockedTable) {
          const tableWidth = getComputedStyle(lockedTable).width;
          if (getComputedStyle(lockedDiv).width !== tableWidth) {
            lockedDiv.style.width = tableWidth;
          }
        }
      });
    },
    
    /** 画面印刷の処理 */
    handleBeforePrint() {
      // 印刷不要な要素を非表示にする
      document.getElementsByClassName("content-container")[0].style.display = "none";
      
      const modal = document.querySelector('.daily-history-modal');
      if (!modal) return;
    
      // 同階層の兄弟要素を取得して非表示にする
      const siblings = modal.parentNode.children;
      Array.from(siblings).forEach(el => {
        if (el !== modal) {
          el.dataset.printHidden = 'true';
          el.style.display = 'none';
        }
      }); 
    },
    handleAfterPrint() {
      // 非表示にした要素を元に戻す
      document.getElementsByClassName("content-container")[0].style.display = "block";
      
      // data-print-hidden が付いている要素を元に戻す
      document.querySelectorAll('[data-print-hidden="true"]').forEach(el => {
        el.style.display = '';
        delete el.dataset.printHidden;
      });
    },
  },
  watch: {
    /**
     * @description フォントサイズ切り替え時
     */
    getFontSize() {
      this.gridSetting();
    },
    getWindowHeight() {
      this.gridSetting();
    },
    getWindowWidth() {
      this.gridSetting();
    },
  },
  created() {
    // 検索条件の初期化
    this.initCondition();
    // 初期検索を実行
    this.search();

    EventBus.$on("requestReportParams", this.requestReportParams);
  },
  mounted() {
    // 固定列幅変更中のtable幅にdiv幅を追随させるためのイベントリスナを追加
    document.addEventListener("mousemove", this.onColumnResizingMouseMove);
    // 画面印刷のイベントリスナを追加
    window.addEventListener("beforeprint", this.handleBeforePrint);
    window.addEventListener("afterprint", this.handleAfterPrint);
  },
  beforeDestroy() {
    EventBus.$off("requestReportParams", this.requestReportParams);
    // mountedで追加したイベントリスナを削除
    document.removeEventListener("mousemove", this.onColumnResizingMouseMove);
    window.removeEventListener("beforeprint", this.handleBeforePrint);
    window.removeEventListener("afterprint", this.handleAfterPrint);
  },
};

// 検索条件のデフォルト値を生成
const createDefaultConditon = () => ({
  mainteDate: moment().format("YYYY-MM-DD"),
  numOfMonth: 1,
  dailyRunning: true,
  dailyNotGood: true,
  dailyGood: true,
  notDailyDate: true,
});

// グリッドのレイアウトごとのカラム定義を生成
const createMultiColumnInfo = (masterItem, masterIndex) => {
  const disabledSpan = "<span class='cell-disabled'></span>";
  const createTemplete = (field, itemIndex) => (
    dataItem => dataItem.cellDisable[masterIndex][itemIndex]
      ? disabledSpan : dataItem[field]
  );
  const columns = masterItem.items.map((item, itemIndex) => {
    const field = `column${masterIndex}${itemIndex}`;
    return {
      field,
      title: item.menteContent1,
      width: "100px",
      headerAttributes: columnHeaderSecendClass,
      format: "",
      template: createTemplete(field, itemIndex),
    };
  });
  const lastUserNameIndex = masterItem.items.length;
  const lastUserNameField = `column${masterIndex}${lastUserNameIndex}`;
  columns.push({
    field: lastUserNameField,
    title: "最終更新者",
    width: "100px",
    headerAttributes: columnHeaderSecendClass,
    format: "",
    template: createTemplete(lastUserNameField, lastUserNameIndex),
  });
  const lastUpdateIndex = masterItem.items.length + 1;
  const lastUpdateField = `column${masterIndex}${lastUpdateIndex}`;
  columns.push({
    field: lastUpdateField,
    title: "最終更新日時",
    width: "9em",
    headerAttributes: columnHeaderSecendClass,
    format: "",
    template: createTemplete(lastUpdateField, lastUpdateIndex),
  });
  return columns;
};

// 表示対象期間に対応する初期状態のデータを作成する
const createInitLocalData = ({ mainteDate, numOfMonth }) => {
  const origin = moment(mainteDate).startOf("day");
  const month = moment(origin).subtract(numOfMonth, "months");
  const days = origin.diff(month, "days") + 1;
  const result = [];
  const rowDate = moment(origin);
  for (let i = 0; i < days; i++) {
    result.push({
      rowNum: i + 1,
      rowTitle: rowDate.format("YYYY/MM/DD(dd)"),
      cellDisable: [],
    });
    rowDate.subtract(1, "days");
  }
  return result;
};

// 点検結果から追加された点検項目の列のうち
// 最新マスタ分の同一項目名の列数を考慮して
// 点検結果を表示するのに必要な列数だけを残す補正を行う
const deleteTrailingItems = (localData, resultMaster, mainteMainList) => {
  resultMaster.forEach(layoutResult => {
    if (!layoutResult) return;
    // 点検結果から追加された点検項目がなければ処理不要
    if (layoutResult.items.length === layoutResult.detailLatestCount) return;

    // layoutResult.items を最新マスタ分と点検結果分に分けて
    // 点検日降順で点検結果を見て結果を表示するために
    // 最新マスタ分だけでは不足する分を点検結果分から追加する
    const itemsNew = layoutResult.items.slice(0, layoutResult.detailLatestCount);
    const itemsRest = layoutResult.items.slice(layoutResult.detailLatestCount);
    for (const rowData of localData) {
      const rowMainteDate = rowData.rowTitle.split("(")[0].replaceAll("/", "-");
      // 点検結果データの仕様として
      // 特定の（装置と）点検日とレイアウトコードの組み合わせに対して
      // （未削除の）点検結果は1件しか存在しない想定
      const mainteMain = mainteMainList.find(mainteMain => (
        mainteMain.menteDate === rowMainteDate
        && mainteMain.menteLayoutCd === layoutResult.menteLayoutCd
      ));
      const mainteMainDetail = mainteMain && JSON.parse(mainteMain.detail);
      // 点検結果が持つ点検項目の項目名のリストを作成する
      const detailNames = mainteMainDetail?.map(
        detailItem => layoutResult.detailHst.find(
          detailHst => (
            detailItem.detail_cd === detailHst.menteDetailCd
            && detailItem.detail_edi === detailHst.editionNo
          )
        ).menteContent1
      );
      if (!detailNames?.length) continue;

      // 点検結果が持つ点検項目の項目名ごとの件数のリストを作成する
      const nameCountList = [];
      detailNames.forEach(name => {
        const countItem = nameCountList.find(item => item.name === name);
        if (countItem) {
          countItem.count++;
        } else {
          nameCountList.push({
            name,
            count: 1,
          });
        }
      });
      // 点検結果が持つ点検項目の項目名ごとの件数分に
      // itemsNew が持つ列数が足りない場合は不足数分 itemsRest から移す
      // （itemsNew が持つ項目名ごとの列数を調整するだけでよい場面なので
      // 　itemsRest から移す要素が持つ点検項目のコード＋版数と
      // 　点検結果が持つ点検項目のコード＋版数を合わせる必要はない）
      nameCountList.forEach(countItem => {
        const nowCount = itemsNew.filter(resultItem => (
          resultItem.menteContent1 === countItem.name
        )).length;
        const shortCount = countItem.count - nowCount;
        if (shortCount < 1) return;
        for (let i = 0; i < shortCount; i++) {
          const index = itemsRest.findIndex(resultItem => (
            resultItem.menteContent1 === countItem.name
          ));
          itemsNew.push(...itemsRest.splice(index, 1));
        }
      });
    }

    layoutResult.items = itemsNew;
  });
};

// グループごとの点検項目の点検結果からグループ単位での合否を決定する
const decideGroupAnswer = (answerArray) => {
  // 「不合格」が存在する場合は「不合格」とする
  if (answerArray.includes(Answer.NotGood)) {
    return Answer.NotGood;
  }
  // 「不合格」の条件に該当せず、
  // 「点検途中」が存在する、もしくは
  // 未実施と「合格」がいずれも存在する場合は「点検途中」とする
  if (
    answerArray.includes(Answer.Running)
    || (
      answerArray.includes(Answer.NotDateForDb)
      && answerArray.includes(Answer.Good)
    )
  ) {
    return Answer.Running;
  }
  // 「不合格」と「点検途中」の条件に該当せず、
  // 「合格」が存在する場合は
  // （未実施は存在しないはずなので）「合格」とする
  if (answerArray.includes(Answer.Good)) {
    return Answer.Good;
  }
  // 「不合格」と「点検途中」と「合格」の条件に該当しない場合は
  // （「未実施」もしくはダミー値しか存在しないはずなので）「未実施」とする
  return Answer.NotDateForDb;
};
// 点検日の点検項目ごとの点検結果から総合合否を決定する
const decideTotalAnswer = (answerArrayMap) => {
  // グループごとの点検結果を決定する
  const groupAnswerArray = Object.values(answerArrayMap).map(decideGroupAnswer);

  // 「不合格」が存在する場合は「不合格」とする
  if (groupAnswerArray.includes(Answer.NotGood)) {
    return StatusText.NotGood;
  }
  // 「不合格」の条件に該当せず、
  // 「点検途中」が存在する場合は「点検途中」とする
  if (groupAnswerArray.includes(Answer.Running)) {
    return StatusText.Running;
  }
  // 「不合格」と「点検途中」の条件に該当せず、
  // 「合格」が存在する場合は「合格」とする
  if (groupAnswerArray.includes(Answer.Good)) {
    return StatusText.Good;
  }
  // #9451対応時の仕様メモ：
  // 臨時的に対応するレイアウト・グループを登録するケースもあるので、
  // （「不合格」や「点検途中」のグループがない場合に）
  // グループ内がすべて合格のグループがある場合は総合合否を合格にする

  // 「不合格」と「点検途中」と「合格」の条件に該当しない場合は
  // （「未実施」しか存在しないはずなので）空欄（未実施日）とする
  return StatusText.NotDate;
};

// 点検結果履歴データを反映する
const convertGridData = (localData, resultMaster, mainteMainList, userAccount) => {
  if (!resultMaster.length) return localData;

  // 点検結果から追加された点検項目の列のうち
  // 最新マスタ分の同一項目名の列数を考慮して
  // 点検結果を表示するのに必要な列数だけを残す補正を行う
  deleteTrailingItems(localData, resultMaster, mainteMainList);

  for (const rowData of localData) {
    // 検査日に対応する１行分のグリッド用データを生成する
    const rowMainteDate = rowData.rowTitle.split("(")[0].replaceAll("/", "-");
    const answerArrayMap = {};
    let isDateFound = false;
    resultMaster.forEach((layoutResult, masterIndex) => {
      // １レイアウト分の列のデータを生成する
      if (!layoutResult) return;

      let lastUpdate = null;
      let lastUserId = null;
      const cellDisable = [];
      const layoutKey = `${layoutResult.menteLayoutCd}`;
      layoutResult.items.forEach((resultItem, itemIndex) => {
        // レイアウト内の点検項目の列のデータを生成する
        // 点検項目に対応する点検結果情報を探す
        let judge = Answer.NotDateForDb;
        let judgeStatus = StatusText.NotDate;

        // 点検結果データの仕様として
        // 特定の（装置と）点検日とレイアウトコードの組み合わせに対して
        // （未削除の）点検結果は1件しか存在しない想定
        const mainteMain = mainteMainList.find(mainteMain => (
          mainteMain.menteDate === rowMainteDate
          && mainteMain.menteLayoutCd === layoutResult.menteLayoutCd
        ));
        const mainteMainDetail = mainteMain && JSON.parse(mainteMain.detail);
        // 点検項目は項目名ごとに列を作成するので
        // 列の項目名と一致する点検項目の点検結果を検索する
        const detailItems = mainteMainDetail?.filter(detailItem => (
          resultItem.menteContent1 === layoutResult.detailHst?.find(
            detailHst => (
              detailItem.detail_cd === detailHst.menteDetailCd
              && detailItem.detail_edi === detailHst.editionNo
            )
          )?.menteContent1
        ));
        // 処理対象の列が項目名が同一のもののうちの何番目かを調べて
        // それに対応する点検結果を取得する
        const nameCount = layoutResult.items.filter((item, index) => (
          (index <= itemIndex)
          && (item.menteContent1 === resultItem.menteContent1)
        )).length;
        const detailItem = detailItems
          && nameCount <= detailItems.length
          && detailItems[nameCount - 1];
        if (detailItem) {
          // 点検日とレイアウトのコードが一致する点検結果情報の
          // 処理対象の列に対応する点検項目の点検結果情報が見つかった場合

          // 最終更新日時の情報を更新
          if (mainteMain.upDate) {
            lastUpdate = mainteMain.upDate;
          }
          // 最終更新者の情報を更新
          if (mainteMain.checkerId1) {
            lastUserId = mainteMain.checkerId1;
          }
          judge = detailItem.judge;
          // Answer.NotDate の値が残っていた場合はこの後の総合合否判定処理のために
          // Answer.NotDateForDb に置き換えておく
          if (judge === Answer.NotDate) {
            judge = Answer.NotDateForDb;
          }
          judgeStatus = convertStatus(judge);
        } else if (mainteMain) {
          // 点検日とレイアウトのコードが一致する点検結果情報が見つかったが
          // 列と項目名が一致する、点検結果が持つ点検項目数が列数に満たない場合は
          // 残りの列は点検結果登録時点では対象ではなかった項目を示すための
          // ダミー値を設定する
          judge = Answer.Dummy;
        }
        const itemKey = `${layoutKey}`;
        // #12550対応時のメモ
        // ここは本来グループごとに answerArrayMap のキー文字列を生成する場面だが
        // グループ重複排除処理によりレイアウトごとの点検結果には
        // 1グループ分しか入っていない想定でもあり、
        // レイアウト単位のキー文字列をそのまま使用することで
        // グループの情報を感知しない画面仕様と
        // 総合合否判定ロジックとの整合性を保つ
        if (!answerArrayMap[itemKey]) {
          answerArrayMap[itemKey] = [];
        }
        answerArrayMap[itemKey].push(judge);

        rowData[`column${masterIndex}${itemIndex}`] = judgeStatus;
        cellDisable[itemIndex] = !detailItem;
      });
      // レイアウト単位で点検結果が存在しなかったかどうかの判定
      const lastCellDisable = !cellDisable.includes(false);
      if (!lastCellDisable) {
        isDateFound = true;
      }

      const itemsLength = layoutResult.items.length;
      // 最終更新者列の情報を生成
      const lastUser = lastUserId && userAccount.findLast(
        item => (item.userId === lastUserId)
      );
      const lastUserNameIndex = itemsLength;
      rowData[`column${masterIndex}${lastUserNameIndex}`] = lastUser
        ? `${lastUser.userLastName} ${lastUser.userFirstName}`
        : "";
      cellDisable[lastUserNameIndex] = lastCellDisable;
      // 最終更新日時列の情報を生成
      const lastUpdateIndex = itemsLength + 1;
      rowData[`column${masterIndex}${lastUpdateIndex}`]
        = (lastUser && lastUpdate)
          ? moment(lastUpdate).format("YYYY/MM/DD(dd) HH:mm")
          : "";
      // #12550対応時の仕様メモ：
      // 新規点検結果データ作成時に自動生成された未実施のままのレコードの
      // checker_id_1 は null になっている想定で、
      // lastUpdate が null の場合は最終更新日時も空欄とする
      cellDisable[lastUpdateIndex] = lastCellDisable;

      // グレー表示判定用のデータを入れる
      rowData.cellDisable[masterIndex] = cellDisable;
    });
    // 点検日の点検項目ごとの点検結果から総合合否を決定する
    rowData.rowTitle2 = decideTotalAnswer(answerArrayMap);

    if (!isDateFound) {
      // 点検日単位で点検結果が存在しなかった場合は
      // （点検項目が0件のレイアウトを除いて）
      // 最新のマスタに存在するレイアウトのみグレー判定結果を無効化する
      resultMaster.forEach((layoutResult, masterIndex) => {
        if (
          !layoutResult?.isCurrent
          || !layoutResult?.items?.length
        ) return;
        // １レイアウト分の列のデータを生成する
        const latestCount = layoutResult.detailLatestCount;
        const itemCount = layoutResult.items.length;
        for (let i = 0; i < rowData.cellDisable[masterIndex].length; i++) {
          // 点検結果から追加された（最新のマスタ状態には存在しない）
          // 点検項目はグレーアウトのままにする
          if (latestCount <= i && i < itemCount) continue;
          rowData.cellDisable[masterIndex][i] = false;
        }
      });
    }
  }

  return localData;
};

// フィルター条件を適用する
const applyFilterLocalData = (localData, { dailyRunning, dailyNotGood, dailyGood, notDailyDate }) => {
  for (let i = localData.length - 1; i >= 0; i--) {
    const { rowTitle2 } = localData[i];
    if (
      (rowTitle2 === StatusText.Running && !dailyRunning)
      || (rowTitle2 === StatusText.NotGood && !dailyNotGood)
      || (rowTitle2 === StatusText.Good && !dailyGood)
      || (rowTitle2 === StatusText.NotDate && !notDailyDate)
    ) {
      localData.splice(i, 1);
    }
  }
  return localData;
};
</script>

<style>

@media print {
  /* 親(点検項目入力)のヘッダを背面に移動 */
  body:has(.daily-history-modal) .modal-mask.custom-modal .modal-header:first-of-type {
    z-index: 9;
  }
  /* ヘッダとbodyでページわかれるのを防止 */
  body:has(.daily-history-modal) .modal-mask.custom-modal .modal-wrapper {
    display: inline-block !important;
    margin-top: 1.5vh !important;
  }
}
/* 横印刷時 */
@media print and (orientation: landscape) {
  body:has(.daily-history-modal) .modal-mask.custom-modal .modal-wrapper {
    margin-top: 3vh !important;
  }
}
</style>

<style scoped>
/* モーダル全体の設定 */
.daily-history-modal {
  z-index: 10000;
}
.daily-history-modal >>> .modal-container {
  margin: 0;
  width: 100%;
  height: 100%;
}
.modal-footer {
  border-top: 1px solid;
  border-color: var(--ntss-footer-border-color) !important;
  background-color: var(--ntss-base-background-color);
  display: flex;
  justify-content: right;
}

.list-header-th-center {
  text-align: center;
  background-color: var(--ntss-list-header-background-color);
  height: 20px;
  color: #fff;
  border: solid 1px #cccccc;
  font-weight: normal;
  white-space: nowrap;
}
.ntss-list {
  border-collapse: collapse;
  margin: 80px 0px 10px 15px;
  background-color: #fff;
}
.ntss-list-body-td {
  border: solid 1px #cccccc;
  word-break: break-all;
  white-space: nowrap;
}
.ntss-list-detail {
  border-collapse: collapse;
  margin: 0 auto;
  width: -webkit-fill-available;
  top: 0px;
  background-color: var(--ntss-list-background-color);
  height: 57px;
}
.history-header-modal {
  font-size: 1.5em;
  display: flex;
  width: 98%;
  margin-inline: auto;
}
.history-list-modal {
  width: 98%;
  padding-top: 10px;
  margin-inline: auto;
}
.distance-time {
  width: 48px;
  text-align: left;
}
.custom-ons-col {
  height: auto;
}
.custom-line-height {
  line-height: 35px;
}
.custom-h3 {
  color: #ffffff;
}
.deviceSetInfo-row-name {
  border: solid 1px var(--ntss-list-border-color);
  background-color: var(--ntss-list-background-color);
  color: var(--ntss-list-body-color);
}

.modal-body >>> .k-grid-content > table > tbody > tr > td:has(.cell-disabled) {
  background-color: var(--pat-viewer-ind-cond-info-disabled);
}
.modal-body {
  margin: 0px 0;
  position: absolute;
  top: 50px;
  width: 100%;
  height: calc(100% - 70px - 2em);
  overflow-y: auto;
  color: var(--ntss-base-color);
}
.popover-row-style {
  flex-wrap: nowrap;
}
@media screen and (max-width: 624px) {
  .ntss-list {
    margin: 133px 0px 10px 15px;
  }
  .popover-row-style {
    flex-wrap: wrap;
  }
}

.custom-modal-mask {
  background: rgba(0, 0, 0, 0.8);
}

.hide-arrow-calendar::-webkit-inner-spin-button,
.hide-arrow-calendar::-webkit-calendar-picker-indicator {
  display: none;
  -webkit-appearance: none;
}

.dailyHistory-checkday-span {
  margin-right: 10px;
}
.condition-search-icon-area-here {
  float: left;
  position: absolute;
  line-height: 4em;
  margin-left: 5px;
  margin-right: 5px;
}
.modal-body >>> .k-grid td,
.modal-body >>> .k-grid tr {
  border: solid 1px var(--ntss-list-border-color) !important;
  background-color: var(--ntss-list-background-color);
  color: var(--ntss-list-body-color);
}
.modal-body >>> .k-grid .k-alt,
.modal-body >>> .k-grid .k-alt td {
  background-color: var(--ntss-list-content-2nd-background-color);
}
::v-deep .k-grid th,
::v-deep .k-grid td {
  height: 2em !important;
}
.kendo-grid-toolbar-style >>> .k-grid-content-locked {
  overflow-y: scroll !important;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
  -ms-overflow-style: none;
}
.kendo-grid-toolbar-style >>> .k-grid-content-locked::-webkit-scrollbar {
  display: none;
}

/* ヘッダー抽出条件 */
#daily-history-condition-list >>> .condition-search-icon-area {
  line-height: 4.2em;
}
#daily-history-condition-list >>> .condition-items-area {
  margin-left: 1.8em;
  color: #333333 !important;
}

@media print {
  /* モーダル全般 */
  .custom-modal-mask {
    background: unset;
    top: -88px;
  }
  .custom-modal-mask .modal-container {
    width: 100% !important;
  }
  .daily-history-modal {
    
    z-index: 9998;
  }
  .modal-footer {
    display: none;
  }
  
  /* ヘッダとbodyでページわかれるのを防止 */
  .daily-history-modal >>> .modal-wrapper {
    display: inline-block !important;
    margin-top: 1.5vh !important;
  }
  /* ヘッダ */
  .ntss-list-detail .ntss-list-body-td {
    white-space: normal;
  }
  /* ベッド */
  .ntss-list-detail th:nth-child(1),
  .ntss-list-detail td:nth-child(1) { min-width: 7em; width: 7em; }
  /* 型式 */
  .ntss-list-detail th:nth-child(2),
  .ntss-list-detail td:nth-child(2) { min-width: 7em; width: 7em; }
  /* 製造番号 */
  .ntss-list-detail th:nth-child(3),
  .ntss-list-detail td:nth-child(3) { min-width: 6em; width: 6em; }
  /* 装置名 */
  .ntss-list-detail th:nth-child(4),
  .ntss-list-detail td:nth-child(4) { min-width: 8em; width: 8em; }
    
  /* 表部分 */
  
  .history-list-modal {
    width: 100%;
  }
  
  /** スクロールコンテナ */
  .history-list-modal >>> .k-grid-header-wrap,
  .history-list-modal >>> .k-grid-content {
    overflow: hidden !important;
    height: auto !important;
  }
  
  /** 固定列調整 */
  .history-list-modal >>> .k-grid-content-locked {
    height: auto !important;
  }
  /** ヘッダのズレ原因を除去 */
  .history-list-modal >>> .k-grid-header {
    padding-right: 0 !important;
  }
  /** gridの幅 */
  .history-list-modal >>> .k-grid {
    width: 100vw;
    height: auto !important;
  }

  /** 印刷時に横スクロール右端時に強制的にスクロール位置を調整 */
  /* 右端時固定列最前面表示*/
  .history-list-modal:has(table.scroll-rightmost) >>> .k-grid-content-locked {
    z-index: 1;
  }
  .history-list-modal >>> .k-grid-header-wrap:has(table.scroll-rightmost),
  .history-list-modal >>> .k-grid-content:has(table.scroll-rightmost) {
    position: static;
  }
  .history-list-modal >>> .k-grid-header-wrap .scroll-rightmost {
    position: relative;
    float: right;
  }
}
/* 横印刷時 */
@media print and (orientation: landscape) {
  .daily-history-modal >>> .modal-wrapper {
    margin-top: 3vh !important;
  }
}
</style>
