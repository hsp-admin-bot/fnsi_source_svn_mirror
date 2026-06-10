/** * 治療方法 */
<template>
  <base-content
    :func-name="funcName"
    :disp-data-list="treatMethodDataList"
    @onTitleClick="onTitleClick"
    @onSubTitleClick="onSubTitleClick"
    @onCellClick="onCellClick"
  />
</template>

<script>
/**
 * Vue関連
 */
import { mapActions, mapGetters } from "vuex";

/**
 * 日付操作
 */
import moment from "moment";

/**
 * 共通操作
 */
import { deepCopy } from "@/functions/common/CommonFunctions";

/**
 * ベースコンポーネント
 * @summary このコンポーネントへ表示する情報を渡す
 */
import baseContent from "@/components/pat-viewer/contents/base/BaseContent";

/**
 * コンポーネント共通操作
 */
import BaseComponent from "@/components/pat-viewer/contents/base/BaseComponent";
//add FNSI-No.IES145 権限対応  吉 start
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
//add FNSI-No.IES145 権限対応  吉 end
// add FNSI-障害票一覧_患者経過総合ビューアNo.16-19(指示の切り替わりポイントを赤くする) 李 start
import MakeStructionColorMixin from "./MakeStructionColorMixin";
// add FNSI-障害票一覧_患者経過総合ビューアNo.16-19(指示の切り替わりポイントを赤くする) 李 end
// add FNSI-マスタ削除表示の対応課題--治療方法 李 start
import { ApiHelper } from "@/apis/AxiosHelper";
// add FNSI-マスタ削除表示の対応課題--治療方法 李 end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

export default {
  components: {
    "base-content": baseContent
  },
  // mod FNSI-障害票一覧_患者経過総合ビューアNo.16-19(指示の切り替わりポイントを赤くする) 李 start
  // //mod FNSI-No.IES145 権限対応  吉 start
  // // mixins: [BaseComponent],
  // mixins: [BaseComponent, ComponentGuardMixin],
  // //mod FNSI-No.IES145 権限対応  吉 end
  mixins: [BaseComponent, ComponentGuardMixin, MakeStructionColorMixin],
  // mod FNSI-障害票一覧_患者経過総合ビューアNo.16-19(指示の切り替わりポイントを赤くする) 李 end

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
       * @summary 親コンポーネントに渡す情報
       */
      funcName: null,

      /**
       * 表示するデータのリスト
       * @summary 親コンポーネントに渡す情報
       */
      treatMethodDataList: [],

      //add FNSI-No.IES145 権限対応  吉 start
      authorityCds:[
        AUTHORITY_CODES.IND_PEDIT,
        AUTHORITY_CODES.IND_EDIT,
      ],
      flagAuthority:false,
      //add FNSI-No.IES145 権限対応  吉 end

      // add FNSI-マスタ削除表示の対応課題--治療方法 李 start
      deletedName: '削除済み'
      // add FNSI-マスタ削除表示の対応課題--治療方法 李 end
    };
  },

  computed: {
    // mod 1006-398 指示の切り替わりポイントを赤くする 陳 start
    //...mapGetters("pat-viewer", ["getMstKurData", "getMstBedData"]),
    ...mapGetters("pat-viewer", ["getMstKurData", "getMstBedData", "getTreatmentDataTmp",
      "getDateList", "getSelectedPeriod", "getDataListKeepTreatMethod", "getPatIdKeep", "getPatIdKeepChgFlg"]),
    ...mapGetters("pat-info", { patId: "selectedPatId" }),
    // mod 1006-398 指示の切り替わりポイントを赤くする 陳 end
    ...mapGetters("pat-viewer-modal", ["getDefaultSettingIndTreatMethodData"]),

    /**
     * スケジュール(IndEditBase)に渡すデータ(雛形)
     */
    faultSettingScheduleData() {
      return this.getDefaultSettingIndTreatMethodData;
    },

    /**
     * クールマスタデータ
     */
    mstKurData() {
      return this.getMstKurData;
    },

    /**
     * ベッドマスタデータ
     */
    mstBedData() {
      return this.getMstBedData;
    }
  },

  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  async created() {
    this.startLoadingScreen();
    this.flagAuthority = this.getTreatmentRecordAuthority();
    // 表示用に治療方法データを加工
    this.convertTreatMethodData({
      listIndex: this.rowIndex,
      selectLayoutCd: this.selectedLayoutCd
    }).then(treatMethodDataListLet => {
      // 指示の切り替わりポイント処理を呼び出す
      this.makeStructionColor(treatMethodDataListLet, 1);
      this.treatMethodDataList = treatMethodDataListLet;

      // 治療方法加工データがない場合、処理中止
      if (!this.treatMethodDataList) return;

      // 治療方法加工データのデータがあるの場合
      if (this.treatMethodDataList?.[0]?.data) {
        // データ循環
        this.treatMethodDataList[0].data.forEach(item => {
          // 治療方法コードがないの場合、循環中止
          if (!item.treatMethodCd || item.treatMethodCd == 0) return;

          // 治療状況の判断
          /* 「rst_diarysis_state = 0」の場合、ind_～に保持しているコードからマスタ参照。
            マスタが削除されている場合、【削除済み】＋ 倫理削除されたマスタの表示内容を表示。 */
          if (item.rstDialysisState == '0') {
            // 指示データの場合
            if (item.value1 && item.value1.indexOf(this.deletedName) != -1) {
              // 指示の治療方法名初期化
              item.value1 = null;
              // 治療方法コードで、削除の治療方法名を取得する
              ApiHelper.get("/mainData/getMstTreatmentNameByCd/" + item.treatMethodCd).then(
                response => {
                  // 削除の治療方法名取得するの場合、【削除済み】＋ 倫理削除されたマスタの表示内容を表示
                  if (response.data) item.value1 = '【' + this.deletedName + '】' + response.data;
                }
              );
            }

          // 「rst_diarysis_state = 6」の場合、ord_mainに保持している値を表示。(マスタの削除は考慮しない)
          } else if (item.rstDialysisState == '6') {
            // 指示データの場合
            if (item.value1 && item.value1.indexOf(this.deletedName) != -1) {
              // ord＿mainに保持している名称を表示。
              item.value1 = item.indTreatmentName;
            }

            // 実績データの場合
            if (item.value2 && item.value2.indexOf(this.deletedName) != -1) {
              // ord＿mainに保持している名称を表示。
              item.value2 = item.rstTreatmentName;
            }

          /* 「rst_diarysis_state = 1～5」の場合、ord_mainに値を持っているが、一度コードからマスタの存在をチェックする。
            【削除済み】＋ ord＿mainに保持している名称を表示。 */
          } else {
            // 指示データの場合
            if (item.value1 && item.value1.indexOf(this.deletedName) != -1) {
              // 【削除済み】＋ ord＿mainに保持している名称を表示。
              item.value1 = '【' + this.deletedName + '】' + item.indTreatmentName;
            }

            // 実績データの場合
            if (item.value2 && item.value2.indexOf(this.deletedName) != -1) {
              // 【削除済み】＋ ord＿mainに保持している名称を表示。
              item.value2 = '【' + this.deletedName + '】' + item.rstTreatmentName;
            }
          }
        });
      }
    }).finally(() => {
      this.finishLoadingScreen();
    });
  },

  methods: {
    // mod 1006-398 指示の切り替わりポイントを赤くする 陳 start
    // ...mapActions("pat-viewer", ["convertTreatMethodData"]),
    ...mapActions("pat-viewer", ["convertTreatMethodData", "setPatIdKeep",
      "setDateList", "setDataListKeepTreatMethod", "setPatIdKeepChgFlg"]),
    // mod 1006-398 指示の切り替わりポイントを赤くする 陳 end
    ...mapActions("pat-viewer-modal", ["showIndModal"]),
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
    ]),

    /**
     * 「治療方法」タイトルクリック時処理
     * @summary 治療方法編集モーダル表示
     */
    onTitleClick() {},

    /**
     * 「治療方法」サブタイトルクリック時処理
     * @summary 治療方法編集モーダル表示
     */
    onSubTitleClick() {
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
      // 治療情報のある直近日を取得
      const recentDate = this.getRecentBaseDate();
      // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  start
      // this.showTreatmethodModal(recentDate, null);
      this.showTreatmethodModal(recentDate, null, null);
      // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  end
    },

    /**
     * 「医療材料」データセルクリック時処理
     * @summary 医療材料編集モーダル表示
     */
    onCellClick(event, cellInfo, itemName, itemInfo, itemIndex, isIndClick) {
      // クリックしたセルに治療情報がない場合は、処理終了
      if (null === cellInfo.ordNo) {
        return;
      }
      // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
      if (isIndClick && cellInfo.isDisabled1) {
        return;
      }
      // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
      /* upd by chamaojia 2026-03-31 [12462] 患者情報共有->患者経過総合ビューア --start */
      // if (cellInfo.isNotClickable) {
      if (isIndClick && cellInfo.isNotClickable) {
        // 画面遷移しない
        return;
      }
      /* upd by chamaojia 2026-03-31 [12462] 患者情報共有->患者経過総合ビューア --end */
      // 指示項目クリック時以下の処理を実行する
      if (isIndClick) {
        // 治療方法変更モーダルを閉じる
        // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  start
        // this.showTreatmethodModal(cellInfo.treatDate, cellInfo.ordNo);
        this.showTreatmethodModal(cellInfo.treatDate, cellInfo.ordNo, cellInfo.rstDialysisState);
        // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  end
      } else {
        // 実績が存在しない場合処理終了
        if (!cellInfo.value2 && cellInfo.value2 !== 0) {
          return;
        }

        //#9836  利用者マスタの治療記録編集権限をOFFの状態でコンソールエラー/ボタンを押下しても画面の反応がなくなる 2023-10-12 卓 start
        //add FNSI-No.IES145 権限対応  吉 start
        // this.flagAuthority = this.getTreatmentRecordAuthority();
        // if(!this.flagAuthority){
        //   this.$ons.notification.alert({
        //     // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        //     // title: "",
        //     // message: "権限不足"
        //     title: DIALOG_MESSAGES['00200116'].title,
        //     message: messageFormat(DIALOG_MESSAGES['00200116'].mesage)
        //     // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        //   });
        //   return;
        // }
        //add FNSI-No.IES145 権限対応  吉 end
        //#9836  利用者マスタの治療記録編集権限をOFFの状態でコンソールエラー/ボタンを押下しても画面の反応がなくなる 2023-10-12 卓 end

        // 治療記録に画面遷移する
        this.setRouter(cellInfo.ordNo, ["treatment-record"]);
      }
    },

    /**
     * 治療方法編集モーダルの表示
     * @param treatDate 治療日(開始日) ※オーダー番号が格納されている場合、終了日も格納する
     */
    // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  start
    // showTreatmethodModal(treatDate, ordNo) {
    showTreatmethodModal(treatDate, ordNo, rstDialysisState) {
      // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  end
      // add #10196 ztc 20240206 ztc start
      if(treatDate === null || treatDate === undefined){
        return;
      }
      // add #10196 ztc 20240206 ztc end
      // 投与薬剤に渡す情報の設定(IndMedicineCreateBase)
      const settingData = deepCopy(this.faultSettingScheduleData);
      // 患者ID
      settingData.patId = this.patId;
      // 施設コード
      settingData.facilityCd = this.facilityCd;
      // オーダー番号
      settingData.ordNo = ordNo;
      // 治療開始日
      settingData.startDate = moment(treatDate, "YYYYMMDD").format(
        "YYYY-MM-DD"
      );
      // 終了日
      settingData.endDate = ordNo ? settingData.startDate : "";
      // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  start
      // 実績：治療状況
      settingData.rstDialysisState = rstDialysisState;
      // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  end
      if (ordNo) {
        // 開始日操作不可
        settingData.startDateEdit = true;
        // 終了日操作不可
        settingData.endDateEdit = true;
        // 全曜日選択をfalse
        settingData.allWeek = false;
        // 選択された曜日以外をfalseへ変更
        for (let i = 0; i < 7; i++) {
          settingData[this.changeWeekStr(i)] =
            i !== moment(treatDate, "YYYYMMDD").day() ? false : true;
        }
      }
      // 子コンポーネント(IndTreatMethod)にわたす情報
      const settingChildData = {};
      // 治療情報
      const ordInfo = this.ordMainData[treatDate];
      // クール名格納
      settingChildData.indKurName = this.translateCd(ordInfo.indKurCd, 0);
      // 治療開始時刻格納
      let indTreatStartTime;
      if (null === ordInfo.indTreatStartTime) {
        indTreatStartTime = "未登録";
      } else {
        indTreatStartTime = moment(ordInfo.indTreatStartTime, "HHmm").format(
          "HH:mm"
        );
      }
      settingChildData.indTreatStartTime = indTreatStartTime;
      // ベッド名格納
      settingChildData.indBedName = this.translateCd(ordInfo.indBedCd, 1);

      // add FNSI-濃度プログラムチェックの追加 楊 start
      if (ordInfo) {
        // 装置設定情報
        const deviceSetInfo =
          ordInfo &&
          ordInfo.indDeviceSetInfo &&
          JSON.parse(ordInfo.indDeviceSetInfo);

        let dcInfo;
        if (deviceSetInfo && deviceSetInfo.dc) {
          dcInfo = deviceSetInfo.dc;
        }

        if (dcInfo) {
          const devA = dcInfo.dev.A[340];
          if (devA && devA !== '0') {
            settingChildData.isDev = true;
          }
        }
      }
      // add FNSI-濃度プログラムチェックの追加 楊 end
      // モーダル表示
      this.showIndModal({
        dispComponentId: "ind-treat-method",
        settingIndData: settingData,
        settingIndChildData: settingChildData
      });
    },

    /**
     * マスタ翻訳
     * @description クール、ベッドコードを名称に翻訳
     * @param cd 翻訳するコード
     * @param mstClass マスタクラス 0->クール、 1->ベッド
     */
    translateCd(cd, mstClass) {
      // マスタ情報
      const mstInfo = 0 === mstClass ? this.mstKurData : this.mstBedData;
      // コード
      const mstCd = 0 === mstClass ? "kurCd" : "bedCd";
      // 名称
      const mstName = 0 === mstClass ? "kurName" : "bedName";
      let translateName = "未登録";
      mstInfo.forEach(eleData => {
        if (eleData[mstCd] === cd) {
          translateName = eleData[mstName];
        }
      });
      return translateName;
    },
    //add FNSI-No.IES145 権限対応  吉 start
    getTreatmentRecordAuthority() {
      return this.hasAuthority();
    },
    //add FNSI-No.IES145 権限対応  吉 end
  }
};
</script>

<style scoped lang="scss">
/* 患者経過総合ビューア共通スタイル定義 */
@import "../../css/style.scss";
</style>
