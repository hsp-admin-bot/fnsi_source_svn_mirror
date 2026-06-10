/** * 医療材料 */
<template>
  <!-- #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start -->
  <!-- <base-content
    :func-name="funcName"
    :disp-data-list="equipmentDataList"
    @onTitleClick="onTitleClick"
    @onSubTitleClick="onSubTitleClick"
    @onCellClick="onCellClick"
  /> -->
  <base-content
    :func-name="funcName"
    :disp-data-list="equipmentDataList"
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
import { ApiHelper } from "@/apis/AxiosHelper";
//add FNSI-No.IES145 権限対応  吉 start
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
//add FNSI-No.IES145 権限対応  吉 end

// add FNSI-障害票一覧_患者経過総合ビューアNo.16-19(指示の切り替わりポイントを赤くする) 李 start
import MakeStructionColorMixin from "./MakeStructionColorMixin";
// add FNSI-障害票一覧_患者経過総合ビューアNo.16-19(指示の切り替わりポイントを赤くする) 李 end
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
import { EventBus } from "@/eventBus.js";

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
      equipmentDataList: [],
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
    ...mapGetters("pat-viewer", ["getMstEquipmentData"]),
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
    ...mapGetters("pat-viewer", ["getDataListKeepEquipment", "getPatIdKeep", "getDateList", "getSelectedPeriod", "getPatIdKeepChgFlg",
      "getTreatmentDataTmp"]),
    ...mapGetters("pat-info", { patId: "selectedPatId" }),
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 end
    ...mapGetters("pat-viewer-modal", ["getDefaultSettingIndEquipmentData"]),
    /**
     * 項目列の縦文字タイトル
     * @summary 親コンポーネントに渡す情報
     */
    funcName() {
      let name = "医療材料";
      // del #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start
      // if (
      //   this.equipmentDataList.length &&
      //   this.equipmentDataList[0].itemName === "医療材料"
      // ) {
      //   name = null;
      // }
      // del #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end

      return name;
    },

    /**
     * 指示コメント(IndEditBase)に渡すデータ(雛形)
     */
    faultSettingIndEquipmentData() {
      return this.getDefaultSettingIndEquipmentData;
    },

    /**
     * 医材マスタデータ
     */
    mstEquipmentData() {
      return this.getMstEquipmentData;
    }
  },

  async created() {
    this.startLoadingScreen();
    this.flagAuthority = this.getTreatmentRecordAuthority();
    // 表示用に医療材料情報を加工
    this.convertEquipmentData({
      listIndex: this.rowIndex
    }).then(async equipmentDataListLet => {
      if (equipmentDataListLet) {
        // RestAPI実行
        var facility_cd = this.getFacilityCd;
        const response = await ApiHelper.get(
          "/mainData/displayOrder",
          //mod FNSI-7270 劉全航 start
          {facility_cd}
          //mod FNSI-7270 劉全航 end
        ).catch(err => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('Equipment.vue', 'created', error);
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          throw err;
        });

        if (response.data) {
          let medOrderNo = response.data.find(item => item.facilitySettingNo == '3006');
          //#11397 医材の表示順の修正 false start
          // if (medOrderNo) {
          //     //FNSI-修正 #5879 医材の表示順の修正　ljx start
          //     let medOrderNoValueArray = eval(medOrderNo.value);
          //     let sortKeyObj = [];
          //     for(let i=0;i<medOrderNoValueArray.length;i++){
          //           switch (medOrderNoValueArray[i]){
          //               // 医療材料分類マスタ表示順
          //               case '1':
          //                 // mod 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
          //                 //sortKeyObj['classCd'] = "ascending";
          //                 sortKeyObj['classCdIndex'] = "ascending";
          //                 // mod 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
          //                 break;
          //               // 医療材料マスタ表示順
          //               case '2':
          //                 sortKeyObj['index'] = "ascending";
          //                 break;
          //           }
          //     }
          //   equipmentDataListLet.sort((frontValue, nextValue) => this.sortByProps(frontValue,nextValue,sortKeyObj));
          //   //switch (medOrderNo.value) {
          //     // 医療材料分類名称コード
          //     //case '1':
          //       //equipmentDataListLet.sort((frontValue, nextValue) => frontValue.classCd - nextValue.classCd);
          //       //break;
          //     // 医療材料マスタ表示順
          //     //case '2':
          //       //equipmentDataListLet.sort((frontValue, nextValue) => frontValue.index - nextValue.index);
          //      // break;
          //   //}
          //   //FNSI-修正 #5879 医材の表示順の修正　ljx end
          // }
          //#11397 医材の表示順の修正 false end
        }
      }

      if (this.patId !== null && this.patId !== "") {
        // 指示の切り替わりポイント処理を呼び出す
        await this.makeStructionColor(equipmentDataListLet, 5);

      }
      if (equipmentDataListLet.length > 1) {
        const addIndex = equipmentDataListLet.findIndex(item => item.itemNo === -1);
        const addObject = equipmentDataListLet.find(item => item.itemNo === -1);
        if (addIndex > -1) {
          equipmentDataListLet.splice(addIndex, 1);
          equipmentDataListLet.unshift(addObject);
        }
      }
      this.equipmentDataList = equipmentDataListLet;

    }).finally(() => {
      this.finishLoadingScreen();
      
      // 親コンポーネント（PatViewer.vue）にcreated完了を通知
      EventBus.$emit("childCreated");
    });
  },

  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    ...mapActions("pat-viewer", ["convertEquipmentData"]),
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
    ...mapActions("pat-viewer", ["setPatIdKeep", "setDataListKeepEquipment", "setDateList", "setPatIdKeepChgFlg"]),
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
     * 「医療材料」タイトルクリック時処理
     * @summary 医療材料新規登録モーダル表示
     */
     onTitleClick() {
      // add #10359 編集権限の動作不正 dengshen start
      if (!this.getItemAuthorized('Indication', 'default_authority')) {
        this.$ons.notification.alert({
          // title: "権限エラー",
          // message: functionName+"を操作する権限がありません。管理者に確認してください。"
          title: DIALOG_MESSAGES[12000315].title,
          message: messageFormat(DIALOG_MESSAGES[12000315].message, "医療材料")
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
      // 治療日
      // mod 2023/09/06 #9585 条件送信後に医療材料の指示を出す際の開始日が当日のまま by liumx start
      // const treatDate = moment(this.baseDate).format("YYYY-MM-DD");
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      // const treatDate = this.getRecentBaseDate() || this.baseDate;
      const treatDate = this.getRecentBaseDate();
      if (!treatDate) {
        return;
      }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      // mod 2023/09/06 #9585 条件送信後に医療材料の指示を出す際の開始日が当日のまま by liumx end
      // 医療材料モーダルの表示
      //mod #10266  start
      // this.showEquipmentModal(treatDate, null, true, null);
      this.showEquipmentModal(treatDate, null, true, null,"2");
      //mod #10266  end
    },

    /**
     * 「医療材料」タイトルクリック時処理
     * @summary 医療材料追加多级モーダル表示
     */
    // #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start
    onAddImgClick(cellInfo) {
      // すべて過去日の場合、操作不可メッセージを表示
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      // if (this.getIsPastDate) {
      //   this.showDisProcMessage();
      //   return;
      // }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      // 一覧上に治療予定がない場合は処理終了
      if (!this.isTreatPlan) {
        return;
      }
      // 治療日
      const treatDate = cellInfo.treatDate;
      // 医療材料モーダルの表示
      //mod #10266  start
      // this.showEquipmentModal(treatDate, cellInfo.ordNo, true, null);
      this.showEquipmentModal(treatDate, cellInfo.ordNo, true, null,null);
      //mod #10266  end
    },
    // #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end

    /**
     * 「医療材料」サブタイトルクリック時処理
     * @summary タイトルがなくサブタイトルが「医療材料」の場合、指示コメント新規登録モーダル表示
     *          サブタイトルが「医療材料」でない場合、指示コメント編集モダール表示
     * @param event ターゲット
     * @param rowInfo 行情報
     * @param itemInfo 「医療材料」項目情報
     * @param itemIndex 「医療材料」行番号
     */
    onSubTitleClick(event, rowInfo, itemInfo, itemIndex) {
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
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      // 一覧上に治療予定がない場合は処理終了
      // if (!this.isTreatPlan) {
      //   return;
      // }
      // 新規登録フラグ
      const isCreate = rowInfo.itemNo === -1;
      // 治療日
      // mod 2023/09/06 #9585 条件送信後に医療材料の指示を出す際の開始日が当日のまま by liumx start
      // const treatDate = isCreate
      //   ? this.baseDate
      //   : this.getRecentEquipBaseDate(rowInfo.itemNo);
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      // const treatDate = this.getRecentBaseDate() || this.baseDate;
      let treatDate = this.getRecentBaseDate();
      // mod 2023/09/06 #9585 条件送信後に医療材料の指示を出す際の開始日が当日のまま by liumx end
      if (!treatDate) {
        return;
      }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
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
        let indEquipInfo = "";
        let newDate = null;
        for (let date in this.ordMainData) {
          if (date >= treatDate && this.ordMainData[date] && this.ordMainData[date].indEquipInfo && this.ordMainData[date].rstDialysisState == "0") {
            indEquipInfo = this.ordMainData[date].indEquipInfo;
            if (indEquipInfo) {
              let indEquipInfoArr = JSON.parse(indEquipInfo);
              const hasMedineInfo = indEquipInfoArr.find(item => item.cd == rowInfo.itemNo);
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

      // 医療材料モーダルの表示
      //mod #10266  start
      // this.showEquipmentModal(treatDate, null, isCreate, itemIndex);
      this.showEquipmentModal(treatDate, null, isCreate, itemIndex,"2");
      //mod #10266  end

    },

    /**
     * 「医療材料」データセルクリック時処理
     * @summary 医療材料編集モーダル表示
     * @param event ターゲット
     * @param cellInfo セル情報
     * @param itemName 行項目名
     * @param itemInfo 「医療材料」データリスト
     * @param itemIndex 行番号
     */
    onCellClick(event, cellInfo, itemName, itemInfo, itemIndex, isIndClick) {
      // クリックしたセルに治療情報がない場合は、処理終了
      if (null === cellInfo.ordNo) {
        return;
      }

      // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
      if (isIndClick && cellInfo.isDisabled1) {
        return;
      }
      // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end

      /* upd by chamaojia 2026-03-31 [12462] 患者情報共有->患者経過総合ビューア --start */
      // if (cellInfo.isNotClickable) {
      if (isIndClick && cellInfo.isNotClickable) {
        return;
      }
      /* upd by chamaojia 2026-03-31 [12462] 患者情報共有->患者経過総合ビューア --end */

      // 指示項目がクリックされた場合以下の処理を実行
      if (isIndClick) {
        // クリックしたセルに医療材料が登録されていない場合、処理終了
        if (null === cellInfo.value1 || cellInfo.value1 === "未登録") {
          return;
        }

        // 医療材料編集モーダルを表示
        this.showEquipmentModal(
          cellInfo.treatDate,
          cellInfo.ordNo,
          false,
          itemIndex,
          //add #10266 start
          null
          //add #10266 end
        );
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

        // 「治療記録」-「医療材料」に画面遷移する
        this.setRouter(cellInfo.ordNo, [
          "treatment-record",
          "treatment-record-equipment"
        ]);
      }
    },

    //mod #10266  start
    /**
     * 医療材料モーダルを表示
     * @param treatDate 治療日
     * @param ordNo オーダー番号
     * @param recentDate 直近日
     * @param isCreate 新規登録フラグ
     * @param itemIndex
     * @param update_flag  2:一括編集  その他の値（2以外）：個別編集
     */
    // showEquipmentModal(treatDate, ordNo, isCreate, itemIndex) {
    showEquipmentModal(treatDate, ordNo, isCreate, itemIndex, update_flag) {
      //mod #10266  end
      // IndEditBaseにわたす情報
      const settingData = deepCopy(this.faultSettingIndEquipmentData);
      // 患者ID
      settingData.patId = this.patId;
      // 施設コード
      settingData.facilityCd = this.facilityCd;
      // 治療日のフォーマットを調整
      treatDate = moment(treatDate).format("YYYY-MM-DD");
      // 治療開始日
      settingData.startDate = treatDate;
      // 治療終了日
      settingData.endDate = ordNo ? treatDate : "";
      // オーダー番号
      settingData.ordNo = ordNo;
      // 【編集】【中止】ボタン表示/非表示切替
      settingData.showNewEdit = !isCreate;

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

      if (isCreate) {
        // 医療材料新規登録モーダルの表示
        this.showIndModal({
          dispComponentId: "ind-equipment-set",
          settingIndData: settingData
        });
      } else {
        const date = moment(treatDate).format("YYYYMMDD");
        // 子コンポーネントにわたす情報を格納
        const settingChildData = {
          fieldsData: this.setDefaultData(date, itemIndex)
        };

        // 編集モーダル表示
        this.showIndModal({
          dispComponentId: "ind-equipment-base",
          settingIndData: settingData,
          settingIndChildData: settingChildData
        });
      }
    },

    /**
     * 医療材料のモーダルに渡すデフォルト値の設定
     * @param targetDate 対象曜日
     * @param index クリックデータセルの要素番号(医療材料の何番目の項目か)
     * @param itemName サブタイトル
     * @return defaultData {Object}医療材料モーダルのデフォルト値情報
     */
    setDefaultData(targetDate, index) {
      let defaultData = {};
      if (null !== this.ordMainData[targetDate]) {
        // クリックしたデータセルの日付の医療材料データを取得
        const equipJson = JSON.parse(this.ordMainData[targetDate].indEquipInfo);

        // クリックしたデータセルの日付に対象医療材料の存在チェック
        const objectData = equipJson.find(item => {
          return (
            // item.cd === this.equipmentDataList[index].itemNo &&
            // item.equip_type === this.equipmentDataList[index].equipType
            item.cd == this.equipmentDataList[index].itemNo &&
            item.equip_type == this.equipmentDataList[index].equipType
          );
        });

        // 削除済み以外の医療材料と対象日付に存在する医療材料のみデフォルトを与える
        if (this.equipmentDataList[index].itemNo && objectData) {
          // デフォルト値の各要素を格納
          defaultData = {
            // ポップオーバー用データ
            cd: objectData.cd,
            // 数量
            amount: objectData.amount,
            // 単位
            unit: this.transrateEquipMst(objectData.cd, "unit"),
            // 医療材料区分
            equipType: objectData.equip_type
          };
        } else {
          defaultData = {
            // ポップオーバー用データ
            cd: this.equipmentDataList[index].itemNo,
            // 医療材料区分
            equipType: this.equipmentDataList[index].equipType
          };
        }
      }
      return defaultData;
    },

    /**
     * 基準日から直近日の医療材料データのある日付を取得
     * @param cd 医療材料コード
     */
    getRecentEquipBaseDate(cd) {
      // 直近日格納用
      let recentDate = null;
      for (const date in this.ordMainData) {
        // 治療日ごとの治療情報を取得
        const ordInfo = this.ordMainData[date];
        // 治療情報から医療材料情報を取得
        const equipInfo = ordInfo ? JSON.parse(ordInfo.indEquipInfo) : [];
        // 医療材料コードが一致するデータのある治療日を取得
        equipInfo.forEach(equipItem => {
          // if (equipItem.cd === cd) {
          if (equipItem.cd == cd) {
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
     * 医材マスタ取得
     * @param code 変換元コード
     * @param column 変換するマスタのカラム名
     */
    transrateEquipMst(code, column) {
      const mstData = this.mstEquipmentData.find(mstItem => {
        // return mstItem.equipmentCd === code;
        return mstItem.equipmentCd == code;
      });
      if (!mstData) {
        return null;
      } else {
        return mstData[column];
      }
    },

    //add FNSI-No.IES145 権限対応  吉 start
    getTreatmentRecordAuthority() {
      return this.hasAuthority();
    },
    //add FNSI-No.IES145 権限対応  吉 end
    //FNSI-修正 #5879 医材の表示順の修正　ljx start
    sortByProps(item1,item2,obj){
      var props = [];
      if(obj){
        props.push(obj)
      }
      var cps = [];
      var asc = true;
      if (props.length < 1) {
        for (var p in item1) {
          if (item1[p] > item2[p]) {
            cps.push(1);
            break;
          } else if (item1[p] === item2[p]) {
            cps.push(0);
          } else {
            cps.push(-1);
            break;
          }
        }
      }
      else {
        for (var i = 0; i < props.length; i++) {
          var prop = props[i];
          for (var o in prop) {
            asc = prop[o] === "ascending";
            if (item1[o] > item2[o]) {
              cps.push(asc ? 1 : -1);
              break;
            } else if (item1[o] === item2[o]) {
              cps.push(0);
            } else {
              cps.push(asc ? -1 : 1);
              break;
            }
          }
        }
      }
      for (var j = 0; j < cps.length; j++) {
        if (cps[j] === 1 || cps[j] === -1) {
          return cps[j];
        }
      }
      return false;
    },
    //FNSI-修正 #5879 医材の表示順の修正　ljx end
  }
};
</script>

<style scoped lang="scss">
/* 患者経過総合ビューア共通スタイル定義 */
@import "../../css/style.scss";
</style>
