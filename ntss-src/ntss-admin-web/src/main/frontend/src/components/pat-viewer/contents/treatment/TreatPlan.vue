/** * 治療予定 */
<template>
  <!-- <base-content :funcName="funcName" :dispDataList="treatPlanDataList" @onSubTitleClick="showTreatPlanMenuPopover" /> -->
  <base-content
    :func-name="funcName"
    :disp-data-list="treatPlanDataList"
    @onSubTitleClick="onSubTitleClick"
    @onMouseDown="onMouseDown"
    @onMouseUp="onMouseUp"
    @onTouchStart="onTouchStart"
    @onTouchEnd="onTouchEnd"
  />
</template>

<script>
import { getFirstElementByClassName } from "@/functions/common/LayoutMeasureHelper";

/**
 * Vue関連
 */
import { mapActions, mapGetters } from "@/compat/vue/vuex";

/**
 * ベースコンポーネント
 * @summary このコンポーネントへ表示する情報を渡す
 */
import baseContent from "@/components/pat-viewer/contents/base/BaseContent";

/**
 * 日付操作
 */
import dayjs from "@/compat/date/dayjs";

/**
 * 共通操作
 */
import { deepCopy } from "@/functions/common/CommonFunctions";

/**
 * コンポーネント共通操作
 */
import BaseComponent from "@/components/pat-viewer/contents/base/BaseComponent";

/**
 * 治療予定マーカーセルの長押し判定閾値
 */
import { LONG_CLICK_THRESHOLD } from "@/constants/PatViewerConstants";

/**
 * ダイアログメッセージ
 */
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import { EventBus } from "@/compat/vue/event-bus.js";

const TREAT_PLAN_LOADED_EVENT = "pat-viewer-treat-plan-loaded";

// 治療予定メニュー情報
const defaultMenuInfo = {
  isShowCreate: false,
  isShowCopy: false,
  isShowMove: false,
  isShowDelete: false,
  isShowWeekPattern: false,
  isShowRst: false,
  target: null,
  direction: null,
  ordNo: null,
  treatDate: "",
  dialysisState: null,
  isOneDay: false,
  isShowOrdNo: false
};

export default {
  components: {
    "base-content": baseContent
  },

  mixins: [BaseComponent],

  props: {
    /**
     * 一覧に表示する治療情報の行番号
     * @summary 何回目の治療予定かどうかの番号。表示に使用すデータの行番号となる
     */
    rowIndex: {
      type: Number,
      default: null,
      required: false
    },

    /**
     * 患者経過総合ビューアレイアウトマスタ選択コード
     */
    selectedLayoutCd: {
      type: Number,
      default: -1,
      required: false
    }
  },

  data() {
    return {
      /**
       * 項目列の縦文字タイトル
       * @summary
       *   親コンポーネントに渡す情報
       *   null (空文字)に設定することで縦列エリアを非表示とすることが可能
       */
      funcName: null,

      /**
       * 表示するデータのリスト
       * @summary 親コンポーネントに渡す情報
       */
      treatPlanDataList: [],

      /**
       * 長押し開始タイミング
       */
      startLongClick: 0,

      /**
       * 長押し終了タイミング
       */
      endLongClick: 0,

      /**
       * 長押し開始したセル(PC)
       */
      onMouseDownCell: null,

      /**
       * 長押し開始したセル(スマホ)
       */
      onTouchStartCellData: {
        cellX: 0,
        cellY: 0,
        cellWidth: 0,
        cellHeight: 0
      },

      // add 更新中の予定を表示する様にする。 李 start
      scrollBarPositioningOrdNo: [],
      // add 更新中の予定を表示する様にする。 李 end
      loadRequestId: 0,
    };
  },

  computed: {
    ...mapGetters("pat-viewer-modal", [
      "getDefaultSettingIndPlanCreateNewData"
    ]),
    ...mapGetters("pat-viewer", ["getIsDie", "getTreatmentData"]),
    // add 更新中の予定を表示する様にする。 李 start
    ...mapGetters("pat-viewer", ["getScrollBarPositioningOrdNo"]),
    // add 更新中の予定を表示する様にする。 李 end
    ...mapGetters("pat-info", ["selectedPat"]),
    /**
     * 治療予定モーダル(新規登録時)に渡すデータ(雛型)
     */
    defaultSettingIndPlanCreateNewData() {
      return this.getDefaultSettingIndPlanCreateNewData;
    },

    /**
     * スケジュール自動延長最終日
     */
    schExtEndDate() {
      // TODO: 自動延長の実行タイミングによりデータ不一致が発生する可能性がある
      return this.selectedPat.pat_main.sch_ext_end_date;
    },

    /**
     * 終了日の最大日(本日から一年未満)
     */
    maxDate() {
      const day = dayjs().format("YYYYMMDD");
      // 一年後に最大日を設定
      let endMaxDate = this.schExtEndDate
        ? dayjs(this.schExtEndDate, "YYYYMMDD")
        : dayjs(day).add(1, "year");
      endMaxDate = dayjs(endMaxDate).endOf("month");
      return dayjs(endMaxDate).format("YYYY-MM-DD");
    },
  },

  beforeUnmount() {
    this.loadRequestId += 1;
    Object.assign(this.$data, this.$options.data());
  },

  watch: {
    selectedLayoutCd() {
      this.loadTreatPlanData();
    },
  },

  created() {
    this.loadTreatPlanData();
  },

  methods: {
    ...mapActions("pat-viewer", ["convertTreatPlanData", "setIsDieMessage"]),
    ...mapActions("pat-viewer-popover", [
      "setShowTreatPlanMenuPopover",
      "setCopyFlag"
    ]),
    ...mapActions("pat-viewer-modal", ["showIndModal", "showPlanCopyModal"]),
    // add 更新中の予定を表示する様にする。 李 start
    ...mapActions("pat-viewer", ["setScrollBarPositioningOrdNo"]),
    // add 更新中の予定を表示する様にする。 李 end
    normalizeLayoutCd(layoutCd) {
      if (layoutCd === null || layoutCd === undefined || layoutCd === "") {
        return null;
      }
      const normalized = Number(layoutCd);
      return Number.isNaN(normalized) ? layoutCd : normalized;
    },
    applyScrollBarPositioning() {
      this.scrollBarPositioningOrdNo = this.getScrollBarPositioningOrdNo;
      if (this.scrollBarPositioningOrdNo.length === 1) {
        A:for (
          let i = 0;
          i < this.treatPlanDataList.length;
          i++)
        {
          let treatPlanData = this.treatPlanDataList[i].data;
          for (
            let j = 0;
            j < treatPlanData.length;
            j++)
          {
            if (treatPlanData[j].ordNo === this.scrollBarPositioningOrdNo[0].ordNo) {
              treatPlanData[j].scrollBarPositioningFlg = true;
              this.setScrollBarPositioningOrdNo({ ordNoName: "reset" });
              break A;
            }
          }
        }
      } else if (this.scrollBarPositioningOrdNo.length > 1) {
        let sbpFlg = false;
        for (
          let i = 0;
          i < this.treatPlanDataList.length;
          i++)
        {
          let treatPlanData = this.treatPlanDataList[i].data;
          for (
            let j = 0;
            j < treatPlanData.length;
            j++)
          {
            for (
              let k = 0;
              k < this.scrollBarPositioningOrdNo.length;
              k++)
            {
              if (!treatPlanData[j].ordNo || treatPlanData[j].ordNo === this.scrollBarPositioningOrdNo[k]) {
                sbpFlg = true;
              }
            }
            if (!sbpFlg) {
              treatPlanData[j].scrollBarPositioningFlg = true;
              this.setScrollBarPositioningOrdNo({ ordNoName: "reset" });
            }
            sbpFlg = false;
          }
        }
      }
    },
    /**
     * 計画データ読込（loading は PatViewer.refresh が一括管理）
     */
    async loadTreatPlanData() {
      const requestId = ++this.loadRequestId;
      try {
        const treatPlanDataList = await this.convertTreatPlanData({
          listIndex: this.rowIndex,
          selectLayoutCd: this.normalizeLayoutCd(this.selectedLayoutCd),
        });
        if (requestId !== this.loadRequestId) {
          return;
        }
        this.treatPlanDataList = treatPlanDataList;
        this.applyScrollBarPositioning();
      } finally {
        if (requestId === this.loadRequestId) {
          EventBus.$emit(TREAT_PLAN_LOADED_EVENT);
        }
      }
    },
    /**
     * 治療予定メニューポップオーバー表示
     */
    showTreatPlanMenuPopover(event, clickPlaceNum) {
      this.setShowTreatPlanMenuPopover({
        targetTreatPlanMenuPopover: event,
        directionTreatPlanMenuPopover: "down",
        clickPlaceNum
      });
    },

    /**
     * 予定作成、コピーの対象日付チェック
     */
    isOverMaxDate(treatDate) {
      // 日付指定で予定作成、コピーをする場合に対象日付のチェック
      const tgt = new Date(`${treatDate} 00:00:00`);
      const max = new Date(`${this.maxDate} 00:00:00`);
      // 対象日付がMAX値よりも大きい場合はダイアログを表示し処理を中断
      if (tgt > max) {
        // メッセージ表示
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES["70000034"].title,
          message: DIALOG_MESSAGES["70000034"].message,
        });
        return true;
      }
      return false;
    },

    /**
     * 「治療予定」サブタイトルクリック時処理
     */
    onSubTitleClick(event) {
      // 本日日付を格納
      const day = dayjs().format("YYYYMMDD");
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      // 一覧上に表示されている治療予定がすべて過去日のものである場合、以下の処理を実行
      // if (this.getIsPastDate) {
      //   // 操作不可メッセージ
      //   this.showDisProcMessage();
      //   return;
      // }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      // 一覧上に治療予定が存在する場合、治療予定メニューを表示する
      // #10266 画面に治療予定がないと吹き出し表示が表示されないで予定作成モダールが展開されてしまう。 linjunfeng start
      let isTreatPlan = false;
      for(let key in this.ordMainData) {
        if (this.ordMainData[key]) {
          isTreatPlan = true;
          break;
        }
      }
      // if (this.isTreatPlan) {
      if (isTreatPlan) {
      // #10266 画面に治療予定がないと吹き出し表示が表示されないで予定作成モダールが展開されてしまう。 linjunfeng end  
        // 治療予定メニューボタン表示情報
        const menuInfo = deepCopy(defaultMenuInfo);
        // 治療日を格納
        // mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start
        // const treatDate = this.getRecentBaseDate();
        const treatDate = this.baseDate;
        // mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end
        menuInfo.treatDate = treatDate;
        // 治療予定メニューターゲットを格納
        menuInfo.target = event;
        // 治療予定メニュー表示方向を格納
        menuInfo.direction = "down";
        menuInfo.isShowCreate = true;
        menuInfo.isShowDelete = true;
        menuInfo.isShowWeekPattern = true;
        // 治療予定メニューポップオーバー表示
        this.setShowTreatPlanMenuPopover({ menuInfo });
      } else {
        // 日付がMAX値を超えている場合処理を中断
        if(this.isOverMaxDate(dayjs(this.baseDate).format("YYYY-MM-DD"))) {
          return;
        }
        // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
        // 基準日が過去日の場合、本日の日付を格納
        // const treatDate = this.baseDate > day ? this.baseDate : day;
        const treatDate = this.baseDate;
        // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
        // 治療予定作成にわたす情報の設定
        const settingData = deepCopy(this.defaultSettingIndPlanCreateNewData);
        // 患者ID
        settingData.patId = this.patId;
        // 施設コード
        settingData.facilityCd = this.facilityCd;
        // 開始日
        settingData.startDate = dayjs(treatDate).format("YYYY-MM-DD");
        // 終了日
        settingData.endDate = "";
        // 全曜日選択をfalse
        settingData.allWeek = false;
        // 全ての選択曜日をfalseへ変更
        for (let i = 0; i < 7; i++) {
          settingData[this.changeWeekStr(i)] = false;
        }
        // モーダル表示
        this.showIndModal({
          dispComponentId: "ind-plan-create",
          settingIndData: settingData
        });
      }
    },

    /**
     * 「治療予定」データセルクリック時処理
     * @description 治療予定が「治療中」以降の場合は、「直接治療予定コピー」モーダルを表示
     *              過去日で予定がない場合は直接「治療予定作成」モーダルを表示
     *              今日含め未来では治療未実施の場合のみ「コピー」、「移動」、「中止」、「手動実績作成」
     *              治療予定があるセルを長押しした場合、オーダー番号のみを表示
     */
    onCellClick(event, cellInfo) {
      if(cellInfo.isNotClickable) {
        return;
      }
      // 長押し時間の計算処理
      // 長押し中に処理をしないので、mousedown→clickの間の経過時間を計測して判別する
      this.endLongClick = performance.now();
      const longClickTime = Math.floor(this.endLongClick - this.startLongClick);

      // 長押しタイミング変数の初期化
      this.startLongClick = 0;
      this.endLongClick = 0;

      // 治療状況を取得
      const dialysisState = this.getRstDialysisState(cellInfo.ordNo);
      // クリック対象の日付
      const checkTreatDate = dayjs(cellInfo.treatDate).format("YYYYMMDD");
      // 本日の日付取得
      const day = dayjs().format("YYYYMMDD");
      // 治療予定メニューボタン表示情報
      const menuInfo = deepCopy(defaultMenuInfo);
      // 表示ターゲット
      menuInfo.target = event;
      // 表示方向
      menuInfo.direction = "down";
      // 治療日格納
      menuInfo.treatDate = cellInfo.treatDate;
      // オーダー番号格納
      menuInfo.ordNo = cellInfo.ordNo;
      // 治療状況格納
      menuInfo.dialysisState = dialysisState;
      // 1日限定フラグ
      menuInfo.isOneDay = true;
      // 予定コピーボタンを表示
      menuInfo.isShowCopy = true;
      // 予定コピーフラグを設定 0->コピー元、 1->コピー先
      this.setCopyFlag({ copyFlag: null === dialysisState ? 1 : 0 });
      // 治療予定がない場合
      if (null === dialysisState) {
        // クリックしたセルが過去日の場合、治療予定作成モーダルを表示する
        // mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start
        // if (day > checkTreatDate) {
        //   // 治療予定作成にわたす情報の設定
        //   const settingData = deepCopy(this.defaultSettingIndPlanCreateNewData);
        //   // 患者ID
        //   settingData.patId = this.patId;
        //   // 施設コード
        //   settingData.facilityCd = this.facilityCd;
        //   // 開始日
        //   settingData.startDate = dayjs(cellInfo.treatDate).format(
        //     "YYYY-MM-DD"
        //   );
        //   // 終了日
        //   settingData.endDate = dayjs(cellInfo.treatDate).format("YYYY-MM-DD");
        //   // 開始日操作不可
        //   settingData.startDateEdit = true;
        //   // 終了日操作不可
        //   settingData.endDateEdit = true;
        //   // 全曜日選択をfalse
        //   settingData.allWeek = false;
        //   // 選択された曜日以外をfalseへ変更
        //   for (let i = 0; i < 7; i++) {
        //     settingData[this.changeWeekStr(i)] =
        //       i !== dayjs(cellInfo.treatDate, "YYYYMMDD").day() ? false : true;
        //   }
        //   if (this.getIsDie) {
        //     // 死亡している場合はメッセージ表示
        //     this.setIsDieMessage(true);
        //     return;
        //   }
        //   // モーダル表示
        //   this.showIndModal({
        //     dispComponentId: "ind-plan-create",
        //     settingIndData: settingData
        //   });
        //   return;
        // } else {
          // 治療予定作成ボタンを表示
          menuInfo.isShowCreate = true;
        // }
        // mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end
      } else {
        // 条件送信確認前の時のみ以下のボタンを表示する
        // mod #10196 rst=456 move Treatment plan ztc 20240304 start
        // if (2 > Number(dialysisState)) {
        if (2 >= Number(dialysisState)) {
          // 長押しされた際の処理
          if (longClickTime > LONG_CLICK_THRESHOLD) {
            // オーダー番号を表示
            menuInfo.isShowOrdNo = true;
          }
          // 予定中止ボタンを表示
          menuInfo.isShowDelete = true;
          // 移動ボタンを表示
          menuInfo.isShowMove = true;
          // 手動実績作成ボタンを表示
          // menuInfo.isShowRst = true;
          if(0 === Number(dialysisState)){
            menuInfo.isShowRst = true;
          }
          // add FNSI-障害票一覧_患者経過総合ビューアNo.22-27 李 start
          // } else if (2 == Number(dialysisState)) {
        } else if(3 < Number(dialysisState)){
          // 長押しされた際の処理
          if (longClickTime > LONG_CLICK_THRESHOLD) {
            // オーダー番号を表示
            menuInfo.isShowOrdNo = true;
            // 予定コピーボタンを表示しない
            menuInfo.isShowCopy = true;
            // 移動ボタンを表示
            menuInfo.isShowMove = true;
            // 治療予定メニューポップオーバー表示
            this.setShowTreatPlanMenuPopover({ menuInfo });
            return;
          }
          // 予定コピーボタンを表示
          // menuInfo.isShowCopy = true;
          // 移動ボタンを表示
          menuInfo.isShowMove = true;
        }
            // else if (2 == Number(dialysisState)) {
            //   // 長押しされた際の処理
            //   if (longClickTime > LONG_CLICK_THRESHOLD) {
            //     // オーダー番号を表示
            //     menuInfo.isShowOrdNo = true;
            //   }
            //   // 予定コピーボタンを表示
            //   menuInfo.isShowCopy = true;
            //   // 移動ボタンを表示
            //   menuInfo.isShowMove = true;
            // // add FNSI-障害票一覧_患者経過総合ビューアNo.22-27 李 end
            //
        // }
        else {
          // 日付がMAX値を超えている場合処理を中断
          if(this.isOverMaxDate(dayjs(cellInfo.treatDate).format("YYYY-MM-DD"))) {
            return;
          }
          // 2 == Number(dialysisState)
          // 長押しされた際の処理
          if (longClickTime > LONG_CLICK_THRESHOLD) {
            // オーダー番号を表示
            menuInfo.isShowOrdNo = true;
            // 予定コピーボタンを表示しない
            menuInfo.isShowCopy = false;
            // 治療予定メニューポップオーバー表示
            this.setShowTreatPlanMenuPopover({ menuInfo });
            return;
          }
          // 治療予定コピーのモーダル直接表示する
          const settingData = {};
          // オーダー番号を格納
          settingData.propOrdNo = cellInfo.ordNo;
          // 患者ID
          settingData.propPatId = this.patId;
          // 施設コード
          settingData.propFacilityCd = this.facilityCd;
          // コピー元治療日
          settingData.propDialysisDate = dayjs(cellInfo.treatDate).format(
              "YYYY-MM-DD"
          );
          // コピーフラグ
          settingData.propSelFlag = 0;
          if (this.getIsDie) {
            // 死亡している場合はメッセージ表示
            this.setIsDieMessage(true);
            return;
          }
          // モーダルを表示
          this.showPlanCopyModal({ settingIndData: settingData });
          return;
        }
        // mod #10196 rst=456 move Treatment plan ztc 20240304 end
      }

      menuInfo.treatmentData = this.getTreatmentData[this.rowIndex][cellInfo.treatDate];

      // 治療予定メニューポップオーバー表示
      this.setShowTreatPlanMenuPopover({ menuInfo });
    },

    /**
     * 「治療予定」データマウスダウン時処理
     * @description マウスが押されたタイミングを長押し開始タイミングとして記録
     *              マウスダウンイベントの後にクリックイベントが発火するため、クリックイベント側で
     *              長押し終了タイミングを記録して判断する
     */
    onMouseDown(event, cellInfo) {
        // マウスクリックを開始したセルの要素を記録
      //mod 8244 2023-01-13 患者経過総合ビューアにて治療予定の行をクリックするとエラー発生 張 start
      // this.onMouseDownCell = event.path[0];
      this.onMouseDownCell = event.path=== undefined  ? event.composedPath[0] : event.path[0];
      //mod 8244 2023-01-13 患者経過総合ビューアにて治療予定の行をクリックするとエラー発生 張 end
      // 長押し開始タイミングを記録
      this.startLongClick = performance.now();
    },

    /**
     * 「治療予定」データマウスアップ時処理
     */
    onMouseUp(event, cellInfo) {
      // クリック時処理を起動
      // マウスを離したセルと同じ要素なら起動する
      //mod 8244 2023-01-13 患者経過総合ビューアにて治療予定の行をクリックするとエラー発生 張 end
      // if (this.onMouseDownCell === event.path[0]) {
      if (this.onMouseDownCell ===( event.path=== undefined  ? event.composedPath[0] : event.path[0])) {
      //mod 8244 2023-01-13 患者経過総合ビューアにて治療予定の行をクリックするとエラー発生 張 end
        this.onCellClick(event, cellInfo);
      }
      this.onMouseDownOrdNo = null;
    },


    /**
     * 「治療予定」データタッチ開始時処理
     * @description タッチ開始タイミングを長押し開始タイミングとして記録（スマホ用）
     */
    onTouchStart(event, cellInfo) {
      // 指を置いたセルの座標を記録
      this.onTouchStartCellData.cellX =
        event.target.offsetLeft
        + event.target.offsetParent.offsetLeft;
      this.onTouchStartCellData.cellY =
        event.target.offsetTop
        + event.target.offsetParent.offsetTop;
      this.onTouchStartCellData.cellWidth = event.target.offsetWidth;
      this.onTouchStartCellData.cellHeight = event.target.offsetHeight;
      // 長押し開始タイミングを記録
      this.startLongClick = performance.now();
      event.preventDefault();
    },

    /**
     * 「治療予定」データタッチ終了時処理
     */
    onTouchEnd(event, cellInfo) {
      // 指を置いたセルと離したセルが同じか判断する
      // スマホだと指を離した先のセルの要素が取得できないため、座標ベースで判断する
      // mod FNSI-redmine 4958 劉祥霖 start
      let MovedLength = getFirstElementByClassName("list-content", this.$el || this)?.scrollLeft || 0;
      const isTouchInCell = this.checkTouchInCell(
        event.changedTouches[0].clientX+MovedLength, event.changedTouches[0].clientY, this.onTouchStartCellData);
      //mod FNSI-redmine 4958 劉祥霖 end
      // クリック時処理を起動
      // 指を離したセルの座標範囲内なら起動する
      if (isTouchInCell) {
        this.onCellClick(event, cellInfo);
      }
      this.onMouseDownOrdNo = 0;
      event.preventDefault();
    },

    /**
     * タッチ開始時と終了時の指の位置が同じセルにいるかの確認
     * @param touchX 指を離した座標X
     * @param touchY 指を離した座標Y
     * @param cellData 対象セルの座標,サイズをキーとして持つ cellX,cellY,cellWidth,cellHeight
     */
    checkTouchInCell(touchX, touchY, cellData) {
      // とりうる座標の最大値
      const maxX = cellData.cellX + cellData.cellWidth;
      const maxY = cellData.cellY + cellData.cellHeight;
      // X座標チェック
      if (touchX < cellData.cellX || touchX > maxX) {
        return false;
      }
      // Y座標チェック
      if (touchY < cellData.cellY || touchY > maxY) {
        return false;
      }
      return true;
    }
  }
};
</script>

<style scoped lang="scss">
/* 患者経過総合ビューア共通スタイル定義 */
@use "../../css/style.scss" as *;
</style>
