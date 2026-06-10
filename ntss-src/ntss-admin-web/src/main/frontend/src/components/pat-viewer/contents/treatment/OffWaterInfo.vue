/** * 除水補正 */
<template>
  <base-content
    :func-name="funcName"
    :disp-data-list="offWaterInfoDataList"
    @onTitleClick="onTitleClick"
    @onSubTitleClick="onSubTitleClick"
    @onCellClick="onCellClick"
  />
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
/**
 * Vue関連
 */
import { mapActions, mapGetters } from "vuex";

/**
 * ベースコンポーネント
 * @summary このコンポーネントへ、表示する情報を渡す
 */
import baseContent from "@/components/pat-viewer/contents/base/BaseContent";

/**
 * 日付操作
 */
import moment from "moment";

/**
 * 共通操作
 */
import { deepCopy } from "@/functions/common/CommonFunctions";

/**
 * コンポーネント共通操作
 */
import BaseComponent from "@/components/pat-viewer/contents/base/BaseComponent";

//add FNSI-No.IES145 権限対応  吉 start
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
//add FNSI-No.IES145 権限対応  吉 end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

export default {
  components: {
    "base-content": baseContent
  },

  //mod FNSI-No.IES145 権限対応  吉 start
  // mixins: [BaseComponent],
  mixins: [BaseComponent,ComponentGuardMixin],
  //mod FNSI-No.IES145 権限対応  吉 end

  props: {
    /**
     * 一覧に表示する治療情報の行番号
     * @summary 何回目の治療予定かどうかの番号。表示に使用すデータの行番号となる
     */
    rowIndex: {
      type: Number,
      default: -1,
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
      funcName: "除水補正",

      /**
       * 表示するデータのリスト
       * @summary 親コンポーネントに渡す情報
       */
      offWaterInfoDataList: [],
      //add FNSI-No.IES145 権限対応  吉 start
      authorityCds:[
        AUTHORITY_CODES.PAT_EDIT,
      ],
      flagAuthority:false,
      //add FNSI-No.IES145 権限対応  吉 end
    };
  },

  computed: {
    ...mapGetters("pat-viewer-modal", ["getDefaultSettingOffWaterInfoData"]),

    /**
     * 指示コメント(IndEditBase)に渡すデータ(雛形)
     */
    faultSettingIndOffWaterInfoData() {
      return this.getDefaultSettingOffWaterInfoData;
    }
  },

  async created() {
    this.startLoadingScreen();
    this.flagAuthority = this.getTreatmentRecordAuthority();
    this.convertOffWaterInfoData({
      listIndex: this.rowIndex
    }).then(offWaterInfoDataList => {
      this.offWaterInfoDataList = offWaterInfoDataList;

      // 合計量計算
      this.calculateSum();
      // 合計量単位付与
      this.addUnitSum();
      // 重さ項目数値カンマ区切り
      this.separatedComma();
    }).finally(() => {
      this.finishLoadingScreen();
    });
  },

  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    ...mapActions("pat-viewer", ["convertOffWaterInfoData"]),
    ...mapActions("pat-viewer-modal", ["showIndModal"]),
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
    ]),
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end

    /**
     * 「除水補正」タイトルクリック時処理
     * @summary 除水補正編集モーダル表示
     */
    async onTitleClick() {
      // add #10359 編集権限の動作不正 dengshen start
      if (!this.getItemAuthorized('Indication', 'item_base_tare_off_water')) {
        this.$ons.notification.alert({
          // title: "権限エラー",
          // message: functionName+"を操作する権限がありません。管理者に確認してください。"
          title: DIALOG_MESSAGES[12000315].title,
          message: messageFormat(DIALOG_MESSAGES[12000315].message, "除水補正")
        });
        return;
      }
      // add #10359 編集権限の動作不正 dengshen end
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
      // 直近日の取得
      const recentDate = await this.getRecentBaseDate();
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      if (!recentDate) {
        return;
      }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      // 編集対象日
      const treatDate = moment(recentDate, "YYYYMMDD").format("YYYY-MM-DD");
      // 除水補正モーダルの表示

      //mod #10266  start
      // this.showOffWaterModal(treatDate, "", this.getOrdNo(recentDate));
      this.showOffWaterModal(treatDate, "", this.getOrdNo(recentDate),"2");
      //mod #10266  end

    },

    /**
     * 「除水補正」サブタイトルクリック時処理
     * @summary 除水補正編集モーダル表示
     */
    async onSubTitleClick() {
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
      // 直近日の取得
      const recentDate = await this.getRecentBaseDate();
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      if (!recentDate) {
        return;
      }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      // 編集対象日
      const treatDate = moment(recentDate, "YYYYMMDD").format("YYYY-MM-DD");
      // 除水補正モーダルの表示

      //mod #10266  start
      // this.showOffWaterModal(treatDate, "", this.getOrdNo(recentDate));
      this.showOffWaterModal(treatDate, "", this.getOrdNo(recentDate),"2");
      //mod #10266  end

    },

    /**
     * 「除水補正」データセルクリック時処理
     * @summary 除水補正編集モーダル表示
     */
    onCellClick(event, cellInfo, itemName, itemInfo, itemIndex, isIndClick) {
      // 治療予定が存在しなければ、処理終了
      if (null === cellInfo.ordNo) {
        return;
      }
      // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
      if (isIndClick && cellInfo.isDisabled1) {
        return;
      }
      // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
      /* upd by chamaojia 2026-03-31 [12462] 患者情報共有->患者経過総合ビューア --start */
      // if(cellInfo.isNotClickable) {
      if(isIndClick && cellInfo.isNotClickable) {
        return;
      }
      /* upd by chamaojia 2026-03-31 [12462] 患者情報共有->患者経過総合ビューア --end */
      // 指示項目がクリックされた場合以下の処理を実行
      if (isIndClick) {
        // 編集対象日
        const treatDate = moment(cellInfo.treatDate, "YYYYMMDD").format(
          "YYYY-MM-DD"
        );
        // 除水補正モーダルの表示
        //mod #10266  start
        // this.showOffWaterModal(treatDate, treatDate, cellInfo.ordNo);
        this.showOffWaterModal(treatDate, treatDate, cellInfo.ordNo,null);
        //mod #10266  end
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
        this.setRouter(cellInfo.ordNo, [
          "treatment-record",
          "treatment-record-weight"
        ]);
      }
    },

    /**
     * 除水補正モーダル表示
     * @param startDate 開始日
     * @param endDate 終了日
     * @param ordNo オーダー番号
     * @param update_flag  2:一括編集  その他の値（2以外）：個別編集
     */
    //mod #10266  start
    // showOffWaterModal(startDate, endDate, ordNo) {
    showOffWaterModal(startDate, endDate, ordNo, update_flag) {
      //mod #10266  end
      // ベースコンポーネントにわたすデータ
      const settingData = deepCopy(this.faultSettingIndOffWaterInfoData);
      // 患者ID
      settingData.patId = this.patId;
      // 施設コード
      settingData.facilityCd = this.facilityCd;
      // 開始日
      settingData.startDate = startDate;
      // 終了日
      settingData.endDate = endDate;

      //add #10266 start
      settingData.update_flag = update_flag;
      //add #10266 end

      // 終了日が格納されている場合
      if ("" !== endDate) {
        // オーダー番号の格納
        settingData.ordNo = ordNo;
        // 開始日操作不可
        settingData.startDateEdit = true;
        // 終了日操作不可
        settingData.endDateEdit = true;
        // 全曜日選択を未選択状態にする
        settingData.allWeek = false;
        // 対象曜日の格納
        const week = moment(startDate, "YYYY-MM-DD").day();
        for (let i = 0; i < 7; i++) {
          // すべての曜日を未選択状態にする
          settingData[this.changeWeekStr(i)] = i !== week ? false : true;
        }
        // 対象の曜日のみ選択状態にする
        settingData[this.changeWeekStr(week)] = true;
      }
      // 除水補正コンポーネントにわたすデータ
      const settingChildData = {
        // 患者ID
        propsPatId: this.patId,
        // オーダー番號
        propsOrdNo: ordNo,
        // 施設コード
        propsFacilityCd: this.facilityCd,
        // テーブルフラグ(治療情報)
        propsTableFlag: 2
      };
      // モーダルを表示
      this.showIndModal({
        dispComponentId: "off-water-info-editor",
        settingIndData: settingData,
        settingIndChildData: settingChildData
      });
    },

    /**
     * 合計量算出
     */
    calculateSum() {
      for (let i = 0; i < this.offWaterInfoDataList.length - 1; i++) {
        const offWaterInfo = this.offWaterInfoDataList[i];
        // 重さ項目合計量算出
        if (0 === offWaterInfo.itemNo % 2) {
          for (let j = 0; j < offWaterInfo.data.length; j++) {
            // value1がnullでなければ除水補正量合計に加算していく
            if (null !== offWaterInfo.data[j].value1) {
              this.offWaterInfoDataList[10].data[j].value1 += Number(
                offWaterInfo.data[j].value1.slice(0, -1)
              );
            }
            // value2がnullでなければ除水補正量合計に加算していく
            if (null !== offWaterInfo.data[j].value2) {
              this.offWaterInfoDataList[10].data[j].value2 += Number(
                offWaterInfo.data[j].value2.slice(0, -1)
              );
            }
          }
        }
      }
    },

    /**
     * 除水補正合計量への単位付与
     */
    addUnitSum() {
      for (let i = 0; i < this.offWaterInfoDataList[10].data.length; i++) {
        const value1 = this.offWaterInfoDataList[10].data[i].value1;
        const value2 = this.offWaterInfoDataList[10].data[i].value2;
        // 値が入っていれば、単位を格納する
        this.offWaterInfoDataList[10].data[i].value1 =
          null !== value1 ? `${value1}g` : value1;
        this.offWaterInfoDataList[10].data[i].value2 =
          null !== value2 ? `${value2}g` : value2;
      }
    },

    /**
     * 数値にカンマの付与(3桁区切り)
     */
    separatedComma() {
      for (let i = 0; i < this.offWaterInfoDataList.length; i++) {
        if (i % 2 === 1 || i === this.offWaterInfoDataList.length - 1) {
          for (let j = 0; j < this.offWaterInfoDataList[i].data.length; j++) {
            const value1 = this.offWaterInfoDataList[i].data[j].value1;
            const value2 = this.offWaterInfoDataList[i].data[j].value2;
            // 値があれば、カンマ区切り
            this.offWaterInfoDataList[i].data[j].value1 = !value1
              ? value1
              : value1.replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1,");
            this.offWaterInfoDataList[i].data[j].value2 = !value2
              ? value2
              : value2.replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1,");
          }
        }
      }
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
