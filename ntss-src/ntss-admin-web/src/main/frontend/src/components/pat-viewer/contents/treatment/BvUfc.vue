/** * 患者経過総合ビュアーBV-UFC */
<template>
  <div>
    <base-content
      :func-name="funcName"
      :disp-data-list="bvUfcDataList"
      @onSubTitleClick="onSubTitleClick"
      @onCellClick="onCellClick"
    />
  </div>
</template>

<script>
/**
 * Vue関連
 */
import { mapActions, mapGetters } from "vuex";

import moment from "moment";

/**
 * ベースコンポーネント
 * @summary このコンポーネントへ表示する情報を渡す
 */
import baseContent from "@/components/pat-viewer/contents/base/BaseContent";

/**
 * コンポーネント共通操作
 */
import BaseComponent from "@/components/pat-viewer/contents/base/BaseComponent";

/**
 * 共通操作
 */
// import { deepCopy } from "@/functions/common/CommonFunctions";

import deviceSetInfoCore from "@/components/pat-info/device-set-info/DeviceSetInfoCore";
import {deepCopy} from "@/functions/common/CommonFunctions";
import MODAL_TITLE from "@/components/common/ModalTitleContrast.js";

// import _ from "underscore";

export default {
  components: {
    "base-content": baseContent
  },

  mixins: [deviceSetInfoCore, BaseComponent],

  props: {
    /**
     * 一覧に表示する治療情報の行番号
     * @summary 何回目の治療予定かどうかの番号(表示に使用すデータの行番号となる)
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
       * 表示するデータのリスト
       * @summary 親コンポーネントに渡す情報
       * fields -> デフォルト値
       * groupCd -> クリックした際に一緒に表示するグループコード
       */
      bvUfcDataList: [],

      /**
       * 項目列tの横文字列タイトル
       * @summary
       *  親コンポーネントに渡す情報
       *  null(空文字)に設定することで縦列エリアを非表示とすることが可能
       */
      funcName: null
    };
  },

  computed: {
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
    ...mapGetters("pat-viewer", ["getDataListKeepBvUfc", "getPatIdKeep", "getPatIdKeepChgFlg"]),
    ...mapGetters("pat-info", { patId: "selectedPatId" }),
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 end
    ...mapGetters("pat-viewer-modal", [
      "getDefaultSettingIndConditionData",
      "getDefaultSettingIndData"
    ]),

    /**
     * 指示コメント(IndEditBase)に渡すデータ(雛形)
     */
    faultSettingIndConditionData() {
      return this.getDefaultSettingIndConditionData;
    }
  },

  async created() {
    this.startLoadingScreen();
    // 表示用に治療条件情報を加工
    this.convertBvUfcData({
      listIndex: this.rowIndex,
      selectLayoutCd: this.selectedLayoutCd
    }).then(bvUfcDataListLet => {
      this.bvUfcDataList = bvUfcDataListLet;
    }).finally(() => {
      this.finishLoadingScreen();
    });
  },

  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    ...mapActions("pat-viewer", ["convertBvUfcData", "getMstRecordInState"]),
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
    ...mapActions("pat-viewer", ["setPatIdKeep", "setDataListKeepBvUfc", "setPatIdKeepChgFlg"]),
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 end
    ...mapActions("pat-viewer-popover", ["setCellInfo"]),
    ...mapActions("pat-viewer-modal", ["showBvUfcEditModal", "showIndModal"]),
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
    ]),
    /**
     * 「治療条件」タイトルクリック時処理
     * @summary 治療条件編集モーダル表示
     */
    onTitleClick() {},

    /**
     * 「治療条件」サブタイトルクリック時処理
     * @summary 治療条件編集モーダル表示
     * @param event ターゲット
     * @param rowInfo 行情報
     * @param itemInfo「治療条件」項目情報
     * @param itemIndex 「治療条件」項目番号
     */
    onSubTitleClick(event, rowInfo) {
      // すべて過去日の場合、操作不可メッセージを表示
      if (this.getIsPastDate) {
        this.showDisProcMessage();
        return;
      }

      // 一覧上に治療予定がない場合は処理終了
      if (!this.isTreatPlan) {
        return;
      }

      // ベースに渡す雛形情報(IndEditBase)
      const settingData = this.getDefaultSettingIndData;
      // QBQD用に設定
      // モーダルのヘッダータイトル
      // mod FNSI-FutreNetWeb+SI課題管理No.5246 李 start
      // settingData.headerTitle = MODAL_TITLE["ＢＶ‐ＵＦＣ"];
      settingData.headerTitle = MODAL_TITLE["BV‐UFC"];
      // mod FNSI-FutreNetWeb+SI課題管理No.5246 李 end
      // 【通常】【隔日】切替ボタン-非表示
      settingData.showSegment = false;
      // 中止ボタン-非表示
      settingData.showDelete = false;
      // 曜日ボタン-表示
      settingData.showWeeks = true;
      // 各曜日-選択
      settingData.allWeek = true;
      settingData.monday = true;
      settingData.tuesday = true;
      settingData.wednesday = true;
      settingData.thursday = true;
      settingData.friday = true;
      settingData.saturday = true;
      settingData.sunday = true;
      // 治療方法選択-表示
      settingData.showTreat = true;
      // クール選択-表示
      settingData.showKur = true;
      // 上区切り線-非表示
      settingData.hrOnder = false;
      // 下区切り線-表示
      settingData.hrUnder = false;
      // 患者ID
      settingData.patId = this.patId;
      // 施設コード
      settingData.facilityCd = this.facilityCd;
      // 開始日操作可
      settingData.startDateEdit = false;
      // 終了日操作可
      settingData.endDateEdit = false;

      //add #10266 start
      settingData.update_flag = "2";
      //add #10266 end

      // 基準日から直近のデータのある日付を取得
      const recentDate = this.getRecentBaseDate(rowInfo.data);
      /* add by chamaojia 2026-03-25 [12462] 患者情報共有->患者経過総合ビューア --start */
      if (!recentDate) {
        return;
      }
      /* add by chamaojia 2026-03-25 [12462] 患者情報共有->患者経過総合ビューア --end */
      // 開始日(基準日)
      settingData.startDate = moment(recentDate, "YYYYMMDD").format(
        "YYYY-MM-DD"
      );
      // 終了日(未選択)
      settingData.endDate = "";

      // 治療予定日のordNo
      const ordNo = this.ordMainData[recentDate].ordNo;
      // QBQDに渡すデータ設定
      const settingChildData = {
        ordNo,
        patId: this.patId,
        facilityCd: this.facilityCd,
        treatDate: recentDate,
        listIndex: this.rowIndex,
        // 終了日操作可 = 一括保存
        isAllSave: !settingData.endDateEdit
      };

      // モーダル表示
      this.showBvUfcEditModal({
        // ベースからslotで表示される子コンポーネント
        dispComponentId: "bv-ufc-editor",
        // ベースに渡す雛形データ(QBQD用に修正)
        settingIndData: settingData,
        // 子コンポーネントに渡すデータ
        settingIndChildData: settingChildData
      });
    },

    /**
     * 「治療条件」データセルクリック時処理
     * @summary 治療条件編集モーダル表示
     * @param event ターゲット
     * @param cellInfo クリックしたセル情報
     * @param itemName クリックしたセルの項目名
     * @param itemuInfo クリックした治療予定の「治療条件」情報
     * @param itemIndex 行番号
     */
    onCellClick(event, cellInfo) {
      // クリックしたセルに治療情報がない場合は、処理終了
      if (null === cellInfo.ordNo) {
        return;
      }

      // 取得したデータを格納
      this.setCellInfo({ cellInfo });

      // ベースに渡す雛形情報(IndEditBase)
      const settingData = this.getDefaultSettingIndData;
      // QBQD用に設定
      // オーダー番号
      settingData.ordNo = cellInfo.ordNo;
      // モーダルのヘッダータイトル
      // mod FNSI-FutreNetWeb+SI課題管理No.5246 李 start
      // settingData.headerTitle = MODAL_TITLE["ＢＶ‐ＵＦＣ"];
      settingData.headerTitle = MODAL_TITLE["BV‐UFC"];
      // mod FNSI-FutreNetWeb+SI課題管理No.5246 李 end
      // 【通常】【隔日】切替ボタン-非表示
      settingData.showSegment = false;
      // 中止ボタン-非表示
      settingData.showDelete = false;
      // 曜日ボタン-表示
      settingData.showWeeks = true;
      // 各曜日-選択
      settingData.allWeek = true;
      settingData.monday = true;
      settingData.tuesday = true;
      settingData.wednesday = true;
      settingData.thursday = true;
      settingData.friday = true;
      settingData.saturday = true;
      settingData.sunday = true;
      // 治療方法選択-表示
      settingData.showTreat = true;
      // クール選択-表示
      settingData.showKur = true;
      // 上区切り線-非表示
      settingData.hrOnder = false;
      // 下区切り線-表示
      settingData.hrUnder = false;
      // 患者ID
      settingData.patId = this.patId;
      // 施設コード
      settingData.facilityCd = this.facilityCd;

      // 開始日
      settingData.startDate = moment(cellInfo.treatDate, "YYYYMMDD").format(
        "YYYY-MM-DD"
      );
      // 終了日
      settingData.endDate = moment(cellInfo.treatDate, "YYYYMMDD").format(
        "YYYY-MM-DD"
      );
      // 開始日操作不可
      settingData.startDateEdit = true;
      // 終了日操作不可
      settingData.endDateEdit = true;
      // 全曜日選択をfalse
      settingData.allWeek = false;

      /* add by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
      const facilitySameFlag = this.facilityCd === cellInfo.facilityCd;
      settingData.showNewEdit = facilitySameFlag;
      settingData.disIndUserEdit = !facilitySameFlag;
      /* add by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
      
      // 選択された曜日以外をfalseに変更
      for (let i = 0; i < 7; i++) {
        settingData[this.changeWeekStr(i)] =
          i !== moment(cellInfo.treatDate, "YYYYMMDD").day() ? false : true;
      }
      settingData[
        this.changeWeekStr(moment(cellInfo.treatDate, "YYYYMMDD").day())
      ] = true;

      const settingChildData = {
        ordNo: cellInfo.ordNo,
        patId: this.patId,
        /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
        // facilityCd: this.facilityCd,
        facilityCd: cellInfo.facilityCd,
        /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
        treatDate: cellInfo.treatDate,
        listIndex: this.rowIndex,
        // 終了日操作不可 = 個別保存
        isAllSave: !settingData.endDateEdit
      };

      // QBQDモーダル表示
      this.showBvUfcEditModal({
        // ベースからslotで表示される子コンポーネント
        dispComponentId: "bv-ufc-editor",
        // ベースに渡す雛形データ(QBQD用に修正)
        settingIndData: settingData,
        // 子コンポーネントに渡すデータ
        settingIndChildData: settingChildData
      });
    }
  }
};
</script>

<style scoped lang="scss">
/* 患者経過総合ビューア共通スタイル定義 */
@import "../../css/style.scss";

div /deep/ .list-content-col {
  width: 0px;
}
</style>
