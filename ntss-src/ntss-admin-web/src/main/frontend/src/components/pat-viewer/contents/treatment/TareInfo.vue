/** * 風袋 */
<template>
  <base-content
    :func-name="funcName"
    :disp-data-list="tareInfoDataList"
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
import { mapActions, mapGetters } from "@/compat/vue/vuex";

/**
 * ベースコンポーネント
 * @summary このコンポーネントへ、表示する情報を渡す
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

//add FNSI-No.IES145 権限対応  吉 start
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
//add FNSI-No.IES145 権限対応  吉 end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
import { EventBus } from "@/compat/vue/event-bus.js";

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
      funcName: "風袋",

      /**
       * 表示するデータのリスト
       * @summary 親コンポーネントに渡す情報
       */
      tareInfoDataList: [],
      //add FNSI-No.IES145 権限対応  吉 start
      authorityCds:[
        AUTHORITY_CODES.PAT_EDIT,
      ],
      flagAuthority:false,
    };
  },

  computed: {
    ...mapGetters("pat-viewer-modal", ["getDefaultSettingTareInfoData"]),
    ...mapGetters("pat-viewer", ["getTreatmentData"]),

    /**
     * 指示コメント(IndEditBase)に渡すデータ(雛形)
     */
    faultSettingIndTareInfoData() {
      return this.getDefaultSettingTareInfoData;
    },

    /** 治療データ読込完了を監視する */
    treatmentDataForRow() {
      return this.getTreatmentData?.[this.rowIndex];
    }
  },

  watch: {
    treatmentDataForRow: {
      handler(newVal, oldVal) {
        if (!newVal) {
          return;
        }
        // 治療データ初回到着時のみ再読込（参照差し替えだけでは再読込しない）
        if (!oldVal || !Object.keys(oldVal).length) {
          this.loadTareInfoData();
        }
      }
    }
  },

  async created() {
    await this.loadTareInfoData();
  },

  mounted() {
    EventBus.$on("isRefresh", this.loadTareInfoData);
  },

  beforeUnmount() {
    EventBus.$off("isRefresh", this.loadTareInfoData);
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    ...mapActions("pat-viewer", ["convertTareInfoData"]),
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
    async loadTareInfoData() {
      this.startLoadingScreen();
      this.flagAuthority = this.getTreatmentRecordAuthority();
      try {
        const tareInfoDataList = await this.convertTareInfoData({
          listIndex: this.rowIndex
        });
        this.tareInfoDataList = tareInfoDataList || [];
        this.calculateSum();
        this.addUnitSum();
        this.separatedComma();
      } catch (e) {
        console.error("風袋データの読み込みに失敗しました", e);
        if (!this.tareInfoDataList.length) {
          this.tareInfoDataList = [];
        }
      } finally {
        this.finishLoadingScreen();
      }
    },

    getTareSumRow() {
      return this.tareInfoDataList.find(item => item.itemNo === 11);
    },

    parseNumericGramValue(value) {
      if (value == null || value === "") {
        return 0;
      }
      const str = String(value);
      const numStr = str.endsWith("g") ? str.slice(0, -1) : str;
      return Number(numStr.replace(/,/g, "")) || 0;
    },

    /**
     * 「風袋」タイトルクリック時処理
     * @summary 風袋編集モーダル表示
     */
    async onTitleClick() {
      // add #10359 編集権限の動作不正 dengshen start
      if (!this.getItemAuthorized('Indication', 'item_base_tare_off_water')) {
        this.$ons.notification.alert({
          // title: "権限エラー",
          // message: functionName+"を操作する権限がありません。管理者に確認してください。"
          title: DIALOG_MESSAGES[12000315].title,
          message: messageFormat(DIALOG_MESSAGES[12000315].message, "風袋")
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

      /**
       * 一覧上に治療予定がない場合は処理終了
       */
      // if (!this.isTreatPlan) {
      //   return;
      // }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      const recentDate = await this.getRecentBaseDate();
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      if (!recentDate) {
        return;
      }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      // 編集対象日
      const treatDate = dayjs(recentDate, "YYYYMMDD").format("YYYY-MM-DD");
      // 風袋モーダルの表示

      //mod #10266  start
      // this.showTareModal(treatDate, "", this.getOrdNo(recentDate));
      this.showTareModal(treatDate, "", this.getOrdNo(recentDate),"2");
      //mod #10266  end

    },

    /**
     * 「風袋」サブタイトルクリック時処理
     * @summary 風袋編集モーダル表示
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
      const recentDate = await this.getRecentBaseDate();
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      if (!recentDate) {
        return;
      }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      // 編集対象日
      const treatDate = dayjs(recentDate, "YYYYMMDD").format("YYYY-MM-DD");
      // 風袋モーダルの表示

      //mod #10266  start
      // this.showTareModal(treatDate, "", this.getOrdNo(recentDate));
      this.showTareModal(treatDate, "", this.getOrdNo(recentDate),"2");
      //mod #10266  end

    },

    /**
     * 「風袋」データセルクリック時処理
     * @summary 風袋編集モーダル表示
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
      if(isIndClick && cellInfo.isNotClickable) {
        return;
      }
      // 指示項目がクリックされた場合以下の処理を実行
      if (isIndClick) {
        // 編集対象日
        const treatDate = dayjs(cellInfo.treatDate, "YYYYMMDD").format(
          "YYYY-MM-DD"
        );
        // 風袋モーダルの表示

        //mod #10266  start
        // this.showTareModal(treatDate, treatDate, cellInfo.ordNo);
        this.showTareModal(treatDate, treatDate, cellInfo.ordNo,null);
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
        //#9836  利用者マスタの治療記録編集権限をOFFの状態でコンソールエラー/ボタンを押下しても画面の反応がなくなる 2023-10-12 卓 end

        //add FNSI-No.IES145 権限対応  吉 end
        // 治療記録に画面遷移する
        this.setRouter(cellInfo.ordNo, [
          "treatment-record",
          "treatment-record-weight"
        ]);
      }
    },

    /**
     * 風袋モーダル表示
     * @param startDate 開始日
     * @param endDate 終了日
     * @param ordno オーダー番号
     * @param update_flag  2:一括編集  その他の値（2以外）：個別編集
     */
    //mod #10266  start
    // showTareModal(startDate, endDate, ordNo) {
    showTareModal(startDate, endDate, ordNo, update_flag) {
      //mod #10266  end
      // ベースコンポーネントにわたすデータ
      const settingData = deepCopy(this.faultSettingIndTareInfoData);
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
        // 対象曜日を格納
        const week = dayjs(startDate, "YYYY-MM-DD").day();
        for (let i = 0; i < 7; i++) {
          // すべての曜日を未選択状態にする
          settingData[this.changeWeekStr(i)] = i !== week ? false : true;
        }
        // 対象の曜日のみ選択状態にする
        settingData[this.changeWeekStr(week)] = true;
      }

      // 風袋コンポーネントにわたすデータ
      const settingChildData = {
        // 患者ID
        propsPatId: this.patId,
        // オーダー番号
        propsOrdNo: ordNo,
        // 施設コード
        propsFacilityCd: this.facilityCd,
        // テーブルフラグ(治療情報)
        propsTableFlag: 2
      };
      // モーダル表示
      this.showIndModal({
        dispComponentId: "tare-info-editor",
        settingIndData: settingData,
        settingIndChildData: settingChildData
      });
    },

    /**
     * 合計量算出
     */
    calculateSum() {
      const sumRow = this.getTareSumRow();
      if (!sumRow || !sumRow.data) {
        return;
      }
      for (let i = 0; i < this.tareInfoDataList.length; i++) {
        const tareInfo = this.tareInfoDataList[i];
        if (!tareInfo || tareInfo.itemNo === 11 || tareInfo.itemNo % 2 !== 0) {
          continue;
        }
        for (let j = 0; j < tareInfo.data.length; j++) {
          if (null !== tareInfo.data[j].value1) {
            sumRow.data[j].value1 =
              (sumRow.data[j].value1 || 0) +
              this.parseNumericGramValue(tareInfo.data[j].value1);
          }
          if (null !== tareInfo.data[j].value2) {
            sumRow.data[j].value2 =
              (sumRow.data[j].value2 || 0) +
              this.parseNumericGramValue(tareInfo.data[j].value2);
          }
        }
      }
    },

    /**
     * 風袋補正合計量への単位付与
     */
    addUnitSum() {
      const sumRow = this.getTareSumRow();
      if (!sumRow || !sumRow.data) {
        return;
      }
      for (let i = 0; i < sumRow.data.length; i++) {
        const value1 = sumRow.data[i].value1;
        const value2 = sumRow.data[i].value2;
        sumRow.data[i].value1 = null != value1 && value1 !== "" ? `${value1}g` : value1;
        sumRow.data[i].value2 = null != value2 && value2 !== "" ? `${value2}g` : value2;
      }
    },

    /**
     * 数値にカンマの付与(3桁区切り)
     */
    separatedComma() {
      for (let i = 0; i < this.tareInfoDataList.length; i++) {
        const tareInfo = this.tareInfoDataList[i];
        if (!tareInfo || !tareInfo.data) {
          continue;
        }
        if (tareInfo.itemNo % 2 === 0 || tareInfo.itemNo === 11) {
          for (let j = 0; j < tareInfo.data.length; j++) {
            const value1 = tareInfo.data[j].value1;
            const value2 = tareInfo.data[j].value2;
            if (value1 != null && value1 !== "") {
              const numStr = String(value1).replace(/g$/, "");
              tareInfo.data[j].value1 = numStr.replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1,");
            }
            if (value2 != null && value2 !== "") {
              const numStr = String(value2).replace(/g$/, "");
              tareInfo.data[j].value2 = numStr.replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1,");
            }
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
@use "../../css/style.scss" as *;
</style>
