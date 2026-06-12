/** * 患者経過総合ビュアー透析液濃度プログラム */
<template>
  <div>
    <base-content
      :disp-data-list="dialysateProgramDataList"
      @onSubTitleClick="onSubTitleClick"
      @onCellClick="onCellClick"
    />
  </div>
</template>

<script>
/**
 * Vue関連
 */
import { mapActions, mapGetters } from "@/compat/vue/vuex";

/**
 * ベースコンポーネント
 * @summary このコンポーネントへ表示する情報を渡す
 */
import baseContent from "@/components/pat-viewer/contents/base/BaseContent";

import dayjs from "@/compat/date/dayjs";

/**
 * 共通操作
 */

import deviceSetInfoCore from "@/components/pat-info/device-set-info/DeviceSetInfoCore";

/**
 * コンポーネント共通操作
 */
import BaseComponent from "@/components/pat-viewer/contents/base/BaseComponent";

import MODAL_TITLE from "@/components/common/ModalTitleContrast.js";

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
      dialysateProgramDataList: []
    };
  },

  computed: {
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
    ...mapGetters("pat-viewer", ["getDataListKeepDialysateProgram", "getPatIdKeep", "getPatIdKeepChgFlg"]),
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
    this.convertDialysateProgramData({
      listIndex: this.rowIndex,
      selectLayoutCd: this.selectedLayoutCd
    }).then(dialysateProgramDataListLet => {
      if(this.ordMainData){
        let dateList = Object.keys(this.ordMainData);
        for(let day of dateList){
          if(this.ordMainData[day]){
            // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
            // let finalProgram = JSON.parse(this.ordMainData[day].indDeviceSetInfo).ufr.dev.A[311];
            // let UFRfLag = JSON.parse(this.ordMainData[day].indDeviceSetInfo).dc.dev.A[368];
            // let powerFlag = JSON.parse(this.ordMainData[day].indDeviceSetInfo).ufr.dev.A[290];
            let finalProgram = JSON.parse(this.ordMainData[day].indDeviceSetInfo)?.ufr.dev.A[311];
            let UFRfLag = JSON.parse(this.ordMainData[day].indDeviceSetInfo)?.dc.dev.A[368];
            let powerFlag = JSON.parse(this.ordMainData[day].indDeviceSetInfo)?.ufr.dev.A[290];
            // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
            if(UFRfLag === "1" && powerFlag !== "0"){
              for(let i = 0; i < 2; i++){
                for(let data of dialysateProgramDataListLet[i].data){
                  if(data.treatDate === day){
                    for(let i = finalProgram;i < 10;i ++){
                      data.chartData[0].stepValues[1][i] = 0;
                    }
                  }
                }
              }
            }
          }
        }
      }
      this.dialysateProgramDataList = dialysateProgramDataListLet;
    }).finally(() => {
      this.finishLoadingScreen();
    });
  },

  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    ...mapActions("pat-viewer", [
      "convertDialysateProgramData",
      "getMstRecordInState"
    ]),
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
    ...mapActions("pat-viewer", ["setPatIdKeep", "setDataListKeepDialysateProgram", "setPatIdKeepChgFlg"]),
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 end
    ...mapActions("pat-viewer-popover", ["setCellInfo"]),
    ...mapActions("pat-viewer-modal", [
      "showDialysateProgramEditModal",
      "showIndModal"
    ]),
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
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      // すべて過去日の場合、操作不可メッセージを表示
      // if (this.getIsPastDate) {
      //   this.showDisProcMessage();
      //   return;
      // }

      // 一覧上に治療予定がない場合は処理終了
      // if (!this.isTreatPlan) {
      //   return;
      // }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end

      // ベースに渡す雛形情報(IndEditBase)
      const settingData = this.getDefaultSettingIndData;
      // モーダルのヘッダータイトル
      settingData.headerTitle = MODAL_TITLE["透析液濃度プログラム"];
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
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      if (!recentDate) {
        return;
      }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      // 開始日(基準日)
      settingData.startDate = dayjs(recentDate, "YYYYMMDD").format(
        "YYYY-MM-DD"
      );
      // 終了日(未選択)
      settingData.endDate = "";

      // 治療予定日のordNo
      const ordNo = this.ordMainData[recentDate].ordNo;
      // モーダルに渡すデータ設定
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
      this.showDialysateProgramEditModal({
        // ベースからslotで表示される子コンポーネント
        dispComponentId: "pat-device-program-dialysate",
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

      if(cellInfo.isNotClickable) {
        return;
      }
      // 取得したデータを格納
      this.setCellInfo({ cellInfo });

      // ベースに渡す雛形情報(IndEditBase)
      const settingData = this.getDefaultSettingIndData;
      // オーダー番号
      settingData.ordNo = cellInfo.ordNo;
      // モーダルのヘッダータイトル
      settingData.headerTitle = MODAL_TITLE["透析液濃度プログラム"];
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

      //add #10266 start
      settingData.update_flag = null;
      //add #10266 end

      // 開始日
      settingData.startDate = dayjs(cellInfo.treatDate, "YYYYMMDD").format(
        "YYYY-MM-DD"
      );
      // 終了日
      settingData.endDate = dayjs(cellInfo.treatDate, "YYYYMMDD").format(
        "YYYY-MM-DD"
      );
      // 開始日操作不可
      settingData.startDateEdit = true;
      // 終了日操作不可
      settingData.endDateEdit = true;
      // 全曜日選択をfalse
      settingData.allWeek = false;
      const facilitySameFlag = this.facilityCd === cellInfo.facilityCd;
      settingData.showNewEdit = facilitySameFlag;
      settingData.disIndUserEdit = !facilitySameFlag;
      // 選択された曜日以外をfalseに変更
      for (let i = 0; i < 7; i++) {
        settingData[this.changeWeekStr(i)] =
          i !== dayjs(cellInfo.treatDate, "YYYYMMDD").day() ? false : true;
      }
      settingData[
        this.changeWeekStr(dayjs(cellInfo.treatDate, "YYYYMMDD").day())
      ] = true;

      const settingChildData = {
        ordNo: cellInfo.ordNo,
        patId: this.patId,
        facilityCd: cellInfo.facilityCd,
        treatDate: cellInfo.treatDate,
        listIndex: this.rowIndex,
        // 終了日操作不可 = 個別保存
        isAllSave: !settingData.endDateEdit
      };

      // モーダル表示
      this.showDialysateProgramEditModal({
        // ベースからslotで表示される子コンポーネント
        dispComponentId: "pat-device-program-dialysate",
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
@use "../../css/style.scss" as *;

/* 患者経過総合ビューア共通スタイル定義 */
div :deep(.list-content-col) {
  width: 0px;
}
</style>
