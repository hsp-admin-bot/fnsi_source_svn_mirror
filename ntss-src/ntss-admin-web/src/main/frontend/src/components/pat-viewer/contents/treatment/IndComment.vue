/** * 指示コメント */
<template>
  <!-- #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start -->
  <!-- <base-content
    :func-name="funcName"
    :disp-data-list="indCommentDataList"
    @onTitleClick="onTitleClick"
    @onSubTitleClick="onSubTitleClick"
    @onCellClick="onCellClick"
  /> -->
  <base-content
    :func-name="funcName"
    :disp-data-list="indCommentDataList"
    @onTitleClick="onTitleClick"
    @onSubTitleClick="onSubTitleClick"
    @onCellClick="onCellClick"
    @onAddImgClick="onAddImgClick"
  />
  <!-- #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end -->
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
 * @summary このコンポーネントへ表示する情報を渡す
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

// add FNSI-障害票一覧_患者経過総合ビューアNo.16-19(指示の切り替わりポイントを赤くする) 李 start
import MakeStructionColorMixin from "./MakeStructionColorMixin";
// add FNSI-障害票一覧_患者経過総合ビューアNo.16-19(指示の切り替わりポイントを赤くする) 李 end
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
  // mixins: [BaseComponent,ComponentGuardMixin],
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
       * 表示するデータのリスト
       * @summary 親コンポーネントに渡す情報
       */
      indCommentDataList: [],
      //add FNSI-No.IES145 権限対応  吉 start
      authorityCds:[
        AUTHORITY_CODES.IND_PEDIT,
        AUTHORITY_CODES.IND_EDIT,
      ],
      flagAuthority:false,
      //add FNSI-No.IES145 権限対応  吉 end
    };
  },

  computed: {
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
    ...mapGetters("pat-viewer", ["getDataListKeepIndComment", "getPatIdKeep", "getDateList", "getSelectedPeriod", "getPatIdKeepChgFlg",
      "getTreatmentDataTmp"]),
    ...mapGetters("pat-info", { patId: "selectedPatId" }),
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 end
    ...mapGetters("pat-viewer-modal", ["getDefaultSettingIndCommentData"]),

    /**
     * 項目列の縦文字タイトル
     * @summary 親コンポーネントに渡す情報
     */
    funcName() {
      let name = "指示コメント";
      // #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start
      // if (
      //   this.indCommentDataList.length &&
      //   this.indCommentDataList[0].itemName === "指示コメント"
      // ) {
      //   name = null;
      // }
      // #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end

      return name;
    },

    /**
     * 指示コメント(IndEditBase)に渡すデータ(雛形)
     */
    faultSettingIndCommentData() {
      return this.getDefaultSettingIndCommentData;
    }
  },

  async created() {
    this.startLoadingScreen();
    this.flagAuthority = this.getTreatmentRecordAuthority();

    // 表示用に指示コメント情報を加工
    this.convertIndCommentData({
      listIndex: this.rowIndex
    }).then(indCommentDataListLet => {
      if (0 === indCommentDataListLet.length) { return; }

      indCommentDataListLet.sort((a, b) => {
        return a.itemNo - b.itemNo;
      });

      // 指示の切り替わりポイント処理を呼び出す
      this.makeStructionColor(indCommentDataListLet, 6);

      this.indCommentDataList = indCommentDataListLet;
      // add 1006-398 指示の切り替わりポイントを赤くする 陳 end
    }).finally(() => {
      this.finishLoadingScreen();
    });
    // mod FNSI-性能を最適化する 李 end
  },

  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    ...mapActions("pat-viewer", ["convertIndCommentData"]),
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
    ...mapActions("pat-viewer", ["setPatIdKeep", "setDataListKeepIndComment", "setDateList", "setPatIdKeepChgFlg"]),
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 end
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
     * 「指示コメント」タイトルクリック時処理
     *  @summary 指示コメント新規登録モーダル表示
     */
    onTitleClick() {
      // add #10359 編集権限の動作不正 dengshen start
      if (!this.getItemAuthorized('Indication', 'default_authority')) {
        this.$ons.notification.alert({
          // title: "権限エラー",
          // message: functionName+"を操作する権限がありません。管理者に確認してください。"
          title: DIALOG_MESSAGES[12000315].title,
          message: messageFormat(DIALOG_MESSAGES[12000315].message, "指示コメント")
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

      // 一覧上に治療予定が無い場合は処理終了
      // if (!this.isTreatPlan) {
      //   return;
      // }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      // 直近日を治療日に格納
      const treatDate = this.getRecentBaseDate();
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      if (!treatDate) {
        return;
      }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      // 子コンポーネントへ渡すデータ
      const settingChildData = {
        editCommentNumFlag: false,
        // mod #11731_【因島：改良】指示コメント番号の指定方法（指示コメント番号と指示コメントの内容は空） start
        // // #10266 指示コメントのヘッダー押下で しかし指示コメントの登録内容が表示されていない linjunfeng start
        // commentNum: 1,
        // propsCommentContent: this.getTargetDateIndComment(
        //   treatDate,
        //   1
        // )
        // // #10266 指示コメントのヘッダー押下で しかし指示コメントの登録内容が表示されていない linjunfeng end
        commentNum: null,
        propsCommentContent: null
        // mod #11731_【因島：改良】指示コメント番号の指定方法 end
      };

      // 指示コメント編集モーダルを開く
      //mod #10266  start
      // this.showIndCommentModal(treatDate, null, settingChildData, false);
      this.showIndCommentModal(treatDate, null, settingChildData, false,"2");
      //mod #10266  end
    },

    /**
     * 「指示コメント」タイトルクリック時処理
     *  @summary 指示コメント新規登録モーダル表示
     */
    // #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start
     onAddImgClick(dispData) {
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      // すべて過去日の場合、操作不可メッセージを表示
      // if (this.getIsPastDate) {
      //   this.showDisProcMessage();
      //   return;
      // }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end

      // 一覧上に治療予定が無い場合は処理終了
      if (!this.isTreatPlan) {
        return;
      }

      // 子コンポーネントへ渡すデータ
      const settingChildData = {
        editCommentNumFlag: false,
        // mod #11731_【因島：改良】指示コメント番号の指定方法（指示コメント番号と指示コメントの内容は空） start
        // // #10266 指示コメントのヘッダー押下で しかし指示コメントの登録内容が表示されていない linjunfeng start
        // commentNum: 1,
        // propsCommentContent: this.getTargetDateIndComment(
        //   dispData.treatDate,
        //   1
        // )
        // // #10266 指示コメントのヘッダー押下で しかし指示コメントの登録内容が表示されていない linjunfeng end
        commentNum: null,
        propsCommentContent: null
        // mod #11731_【因島：改良】指示コメント番号の指定方法 end
      };
      // 指示コメント編集モーダルを開く
      //mod #10266  start
      // this.showIndCommentModal(dispData.treatDate, dispData.ordNo, settingChildData, false);
      this.showIndCommentModal(dispData.treatDate, dispData.ordNo, settingChildData, false,null);
      //mod #10266  end
    },
    // #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end

    /**
     * 「指示コメント」サブタイトルクリック時処理
     * @summary タイトルがなくサブタイトルが「指示コメント」の場合、指示コメント新規登録モーダル表示
     *          サブタイトルが「指示コメント<番号>」の場合、指示コメント編集モダール表示
     */
    onSubTitleClick(event, rowInfo) {
      /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
      if (rowInfo.readOnly) {
        return;
      }
      /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      // すべて過去日の場合、操作不可メッセージを表示
      // if (this.getIsPastDate) {
      //   this.showDisProcMessage();
      //   return;
      // }

      // 一覧上に治療予定が無い場合は処理終了
      // if (!this.isTreatPlan) {
      //   return;
      // }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      // 新規登録フラグ
      const isCreate = rowInfo.itemNo === null;
      // 対象の指示コメントのある直近日を取得
      const recentDate = this.getRecentCommentDate(rowInfo.itemNo);
      // 【編集】【中止】ボタン表示/非表示切替を格納
      const showNewEdit = null !== recentDate;
      // 治療日を格納
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      // const treatDate = showNewEdit ? recentDate : this.getRecentBaseDate();
      let treatDate = this.getRecentBaseDate();
      if (!treatDate) {
        return;
      }

      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      // 子コンポーネントへ渡すデータ
      const settingChildData = {};
      // コメント番号編集可/不可切替を格納
      settingChildData.editCommentNumFlag = showNewEdit;
      // コメント番号を格納
      settingChildData.commentNum = rowInfo.itemNo;

      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      // 直近日の指示有無チェック
      // const hasIndInfo = rowInfo.data.find(
      //   i => i.treatDate === treatDate && i.value1 !== null
      // );
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end

      // 指示がない場合は処理終了
      if (!isCreate) {
        // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
        // return;
        // 現在の画面は予定されておらず、後の日付は予定されています。
        let indCommentInfo = "";
        let newDate = null;
        for (let date in this.ordMainData) {
          if (date >= treatDate && this.ordMainData[date] && this.ordMainData[date].indIndCommentInfo && this.ordMainData[date].rstDialysisState == "0") {
            indCommentInfo = this.ordMainData[date].indIndCommentInfo;
            if (indCommentInfo) {
              let indCommentInfoArr = JSON.parse(indCommentInfo);
              // #10266 指示コメント編集→修正指示コメント後再修正開始/終了日(編集破棄)、保存後クリック指示コメント編集、開始日変更です linjunfeng start
              // const hasMedineInfo = indCommentInfoArr.find(item => item.no == rowInfo.itemNo);
              const hasMedineInfo = indCommentInfoArr.find(item => item.no == rowInfo.itemNo && item.content != null);
              // #10266 指示コメント編集→修正指示コメント後再修正開始/終了日(編集破棄)、保存後クリック指示コメント編集、開始日変更です linjunfeng end
              if (hasMedineInfo) {
                newDate = date;
                break;
              }
            }
          }
        }
        if (!newDate) {
          return;
        }
        treatDate = newDate;
        // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      }
      // 対象治療日の指示コメント取得
      settingChildData.propsCommentContent = this.getTargetDateIndComment(
        treatDate,
        rowInfo.itemNo
      );
      console.log('treatDate', treatDate)
      // 指示コメントモーダルを開く
      //mod #10266  start
      // this.showIndCommentModal(treatDate, null, settingChildData, showNewEdit);
      this.showIndCommentModal(treatDate, null, settingChildData, showNewEdit,"2");
      //mod #10266  end
    },

    /**
     * 「指示コメント」データセルクリック時処理
     * @summary 指示コメント編集モーダル表示
     */
    onCellClick(event, cellInfo, itemName, itemInfo, itemIndex, isIndClick) {
      // 治療予定が存在しなければ、処理終了
      if (null === cellInfo.ordNo) {
        return;
      }

      /* upd by chamaojia 2026-03-31 [12462] 患者情報共有->患者経過総合ビューア --start */
      // if(cellInfo.isNotClickable) {
      if(isIndClick && cellInfo.isNotClickable) {
        return;
      }
      /* upd by chamaojia 2026-03-31 [12462] 患者情報共有->患者経過総合ビューア --end */
      // 指示項目がクリックされた場合、以下の処理を実行する
      if (isIndClick) {
        // クリックしたセルに指示コメントが登録されていない場合、処理終了
        if (!cellInfo.hasInd) {
          return;
        }

        // 【編集】【中止】切替ボタン-表示
        const showNewEdit = null !== this.getRecentCommentDate(cellInfo.itemNo);
        // 子コンポーネントへ渡すデータ
        const settingChildData = {};
        // 指示コメント番号を格納
        settingChildData.commentNum = cellInfo.itemNo;
        // コメント番号編不可格納
        settingChildData.editCommentNumFlag = showNewEdit;
        // 指示コメント内容格納
        settingChildData.propsCommentContent = cellInfo.value1;
        // 指示コメント編集モーダルを開く
        this.showIndCommentModal(
          cellInfo.treatDate,
          cellInfo.ordNo,
          settingChildData,
          showNewEdit,
          //add #10266 start
          null
          //add #10266 end
        );
      } else {
        // 実績が存在しない場合処理終了
        if (!cellInfo.hasRst) {
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

        // 「治療記録」-「指示コメント」に画面遷移する
        this.setRouter(cellInfo.ordNo, [
          "treatment-record",
          "treatment-record-addition"
        ]);
      }
    },

    /**
     * 指示コメント編集モーダル表示
     * @param treatDate 治療日(開始日) ※オーダー番号が格納されている場合、終了日も格納する
     * @param ordNo オーダー番号
     * @param settingChildData 指示コメントコンポーネントにわたす情報
     * @param showNewEdit 【編集】【中止】切り替えフラグ
     * @param update_flag  2:一括編集  その他の値（2以外）：個別編集
     */
    //mod #10266  start
    // showIndCommentModal(treatDate, ordNo, settingChildData, showNewEdit) {
    showIndCommentModal(treatDate, ordNo, settingChildData, showNewEdit, update_flag) {
      //mod #10266  end
      // IndEditBaseに渡す情報
      const settingData = deepCopy(this.faultSettingIndCommentData);
      // 患者ID
      settingData.patId = this.patId;
      // 施設コード
      settingData.facilityCd = this.facilityCd;
      // 【編集】【中止】切替ボタン-非表示
      settingData.showNewEdit = showNewEdit;
      // 治療日のフォーマットを調整
      treatDate = moment(treatDate).format("YYYY-MM-DD");
      // 治療開始日
      settingData.startDate = treatDate;
      // 治療終了日
      settingData.endDate = ordNo ? treatDate : "";
      // オーダー番号
      settingData.ordNo = ordNo;

      //add #10266 start
      settingData.update_flag = update_flag;
      //add #10266 end

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
      // モーダル表示
      this.showIndModal({
        dispComponentId: "ind-comment",
        settingIndData: settingData,
        settingIndChildData: settingChildData
      });
    },

    /**
     * 基準日から直近の指示コメントが存在する治療日を取得
     */
    getRecentCommentDate(no) {
      // 直近日格納用
      let recentDate = null;
      for (const date in this.ordMainData) {
        // 治療日ごとに治療情報を取得
        const ordInfo = this.ordMainData[date];
        // 治療情報から指示コメント情報を取得
        /* modify by chamaojia 2024-04-03 [10196] add null judgment processing  --start */
        const indCommentInfo = (ordInfo && ordInfo.indIndCommentInfo)
          ? JSON.parse(ordInfo.indIndCommentInfo)
          : [];
        /* modify by chamaojia 2024-04-03 [10196] add null judgment processing  --end */
        indCommentInfo.forEach(indCommentItem => {
          if (indCommentItem.no === no) {
            recentDate = date;
            return;
          }
        });
        if (recentDate) {
          break;
        }
      }
      return recentDate;
    },

    /**
     * 対象の治療日、指示コメント番号から指示コメントを取得
     * @param date 治療日
     * @param commentNum 指示コメント番号
     */
    getTargetDateIndComment(date, commentNo) {
      // 治療日のフォーマットを調整
      const treatDate = moment(date).format("YYYYMMDD");
      // 指示コメント内容格納用
      let content = null;
      // 対象治療日の治療情報取得
      const ordInfo = this.ordMainData[treatDate];
      // 指示コメント情報を取得
      /* modify by chamaojia 2024-04-03 [10196] add null judgment processing  --start */
      const indCommentInfo = (ordInfo && ordInfo.indIndCommentInfo)
        ? JSON.parse(ordInfo.indIndCommentInfo)
        : [];
      /* modify by chamaojia 2024-04-03 [10196] add null judgment processing  --end */
      // 指定した指示コメント番号と一致した指示コメント内容を取得
      indCommentInfo.forEach(item => {
        if (item.no === commentNo) {
          content = item.content;
          return;
        }
      });
      return content;
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
