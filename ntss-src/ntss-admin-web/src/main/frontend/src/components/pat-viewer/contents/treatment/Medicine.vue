/** * 投与薬剤 */
<template>
  <!-- mod FNSI-投与薬剤の補助画面を追加 周 start -->
  <!-- <base-content
    :func-name="funcName"
    :disp-data-list="medicineDataList"
    @onTitleClick="onTitleClick"
    @onSubTitleClick="onSubTitleClick"
    @onCellClick="onCellClick"
  /> -->
  <!-- #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start -->
  <!-- <base-content
    :func-name="funcName"
    :disp-data-list="medicineDataList"
    :is-medicine="true"
    @onTitleClick="onTitleClick"
    @onSubTitleClick="onSubTitleClick"
    @onCellClick="onCellClick"
  /> -->
  <base-content
    :func-name="funcName"
    :disp-data-list="medicineDataList"
    :is-medicine="true"
    @onTitleClick="onTitleClick"
    @onSubTitleClick="onSubTitleClick"
    @onCellClick="onCellClick"
    @onAddImgClick="onAddImgClick"
  />
  <!-- #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end -->
  <!-- mod FNSI-投与薬剤の補助画面を追加 周 end -->
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
/**
 * Vue関連
 */
import { mapActions, mapGetters } from "vuex";
import { EventBus } from "@/eventBus.js";

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

    rowIndexMax: {
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
      medicineDataList: [],
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
    ...mapGetters("pat-viewer", [
      "getMstMedicineData",
      "getMstMedicineMixData",
      "getTreatmentDataTmp",
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
      "getDateList", "getSelectedPeriod", "getDataListKeepMedicine", "getPatIdKeep", "getPatIdKeepChgFlg"
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 end
    ]),
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
    ...mapGetters("pat-info", { patId: "selectedPatId" }),
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 end
    ...mapGetters("pat-viewer-modal", ["getDefaultSettingMedicineData"]),

    /**
     * 項目列の縦文字タイトル
     * @summary 親コンポーネントに渡す情報
     */
    funcName() {
      let name = "投与薬剤";
      // del #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start
      // if (
      //   this.medicineDataList.length &&
      //   this.medicineDataList[0].itemName === "投与薬剤"
      // ) {
      //   name = null;
      // }
      // del #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start

      return name;
    },

    /**
     * 投与薬剤(IndMedicineCreateBase)に渡すデータ(雛形)
     */
    faultSettingMedicineData() {
      return this.getDefaultSettingMedicineData;
    },

    /**
     * 薬剤マスタデータ
     */
    mstMedicineData() {
      return this.getMstMedicineData;
    },
    /**
     * 調製薬剤マスタデータ
     */
    mstMedicineMixData() {
      return this.getMstMedicineMixData;
    }
  },

  async created() {
    this.startLoadingScreen();
    this.flagAuthority = this.getTreatmentRecordAuthority();
    // 表示用に投与薬剤情報を加工
    this.convertMedicinetData({
      listIndex: this.rowIndex,
      selectLayoutCd: this.selectedLayoutCd
    }).then(async medicineDataListLet => {
      // add FNSI-薬剤、医療材料の表示順の設定を追加する 李 start

      //#11397 薬剤の表示順の修正 false start
      // if (medicineDataListLet) {
      //   // RestAPI実行
      //   var facility_cd = this.getFacilityCd;
      //   const response = await ApiHelper.get(
      //     "/mainData/displayOrder",
      //     //mod FNSI-7270 劉全航 start
      //     { facility_cd }
      //     //mod FNSI-7270 劉全航 end
      //   ).catch(err => {
      //     //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
      //     getErrorMessage('Medicine.vue', 'created', err);
      //     //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
      //     throw err;
      //   });
      //   if (response.data) {
      //     let medOrderNo = response.data.find(item => item.facilitySettingNo == '3007');
      //     if (medOrderNo) {
      //         //FNSI-修正 #5879 投薬の表示順の修正　ljx start
      //         let medOrderNoValueArray = eval(medOrderNo.value);
      //         let sortKeyObj = {};
      //         for(let i=0;i<medOrderNoValueArray.length;i++){
      //               switch (medOrderNoValueArray[i]){
      //                   // 薬剤分類マスタ表示順
      //                   case '1':
      //                     // mod 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
      //                     //sortKeyObj['classCd'] = "ascending";
      //                     sortKeyObj['classCdIndex'] = "ascending";
      //                     // mod 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
      //                     break;
      //                   // 薬剤区分
      //                   case '2':
      //                     sortKeyObj['medicineType'] = "ascending";
      //                     break;
      //                   // 薬剤マスタ表示順
      //                   case '3':
      //                     sortKeyObj['index'] = "ascending";
      //                     break;
      //                   // 投与タイミングマスタ表示順
      //                   case '4':
      //                     // mod 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
      //                     //sortKeyObj['medicateTimingCd2'] = "ascending";
      //                     sortKeyObj['medicateTimingCdIndex'] = "ascending";
      //                     // mod 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
      //                     break;
      //                   // 手技マスタ表示順
      //                   case '5':
      //                    // mod 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
      //                    // sortKeyObj['procedureCd2'] = "ascending";
      //                    sortKeyObj['procedureCdIndex'] = "ascending";
      //                    // mod 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
      //                     break;
      //                   // 投薬パターンコード
      //                   case '6':
      //                     sortKeyObj['dateInterval'] = "ascending";
      //                     break;
      //               }
      //         }
      //       medicineDataListLet.sort((frontValue, nextValue) => this.sortByProps(frontValue,nextValue,sortKeyObj));
      //         //switch (medOrderNo.value) {
      //         // 薬剤分類名称コード
      //         //case '1':
      //           //medicineDataListLet.sort((frontValue, nextValue) => frontValue.classCd - nextValue.classCd);
      //           //break;
      //         // 薬剤区分
      //         //case '2':
      //           //medicineDataListLet.sort((frontValue, nextValue) => frontValue.medicineType - nextValue.medicineType);
      //           //break;
      //         // 薬剤マスタ表示順
      //         //case '3':
      //           //medicineDataListLet.sort((frontValue, nextValue) => frontValue.index - nextValue.index);
      //           //break;
      //         // 投与時間帯
      //         //case '4':
      //           //medicineDataListLet.sort((frontValue, nextValue) => frontValue.medicateTimingCd - nextValue.medicateTimingCd);
      //           //break;
      //         // 手技
      //         //case '5':
      //           //medicineDataListLet.sort((frontValue, nextValue) => frontValue.procedureCd - nextValue.procedureCd);
      //           //break;
      //         // 投薬パターンコード
      //         //case '6':
      //           //medicineDataListLet.sort((frontValue, nextValue) => frontValue.dateInterval - nextValue.dateInterval);
      //           //break;
      //       //}
      //           //FNSI-修正 #5879 投薬の表示順の修正　ljx end
      //     }
      //   }
      // }
      //#11397 薬剤の表示順の修正 false end
      // add FNSI-薬剤、医療材料の表示順の設定を追加する 李 end

      // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
      // if (this.patId !== null && this.patId !== "") {
      //   if (this.patId !== this.getPatIdKeep) {
      //     if (!this.getPatIdKeepChgFlg) {
      //       this.setPatIdKeepChgFlg(true);
      //       this.$nextTick(() => {
      //         setTimeout(() => {
      //           this.setPatIdKeep(this.patId);
      //           this.setPatIdKeepChgFlg(false);
      //         }, 2000);
      //       })
      //     }
      //     this.setDataListKeepMedicine(deepCopy(medicineDataListLet));
      //   } else {
      //     let dataListKeep = this.getDataListKeepMedicine;
      //     if (!dataListKeep || !dataListKeep.length || dataListKeep.length > 0) {
      //       this.setDataListKeepMedicine(deepCopy(medicineDataListLet));
      //     } else {
      //       let dataArray = medicineDataListLet;
      //       for (let i = 0; i < dataArray.length; i++) {
      //         let datas = dataArray[i].data;
      //         let indexMax = dataListKeep.length - 1;
      //         if (i > indexMax) {
      //           datas.forEach(data => {
      //             if (data.ordNo !== undefined && data.ordNo !== null && data.ordNo !== "") {
      //               data.colorFlg = 1;
      //             }
      //           });
      //           continue;
      //         }
      //         let datasKeep = dataListKeep[i].data;
      //         for (let j = 0; j < datas.length; j++) {
      //           let data = datas[j];
      //           let dataKeep = datasKeep.find(
      //             x => x.treatDate === data.treatDate
      //           );
      //           if (dataKeep === undefined || dataKeep === null) {
      //             datasKeep.push(deepCopy(data));
      //             continue;
      //           }
      //           if ((data.ordNo !== undefined && data.ordNo !== null && data.ordNo !== "") ||
      //             (dataKeep.ordNo !== undefined && dataKeep.ordNo !== null && dataKeep.ordNo !== "")) {
      //             if (data.isExpired !== dataKeep.isExpired ||
      //               data.isNotClickable !== dataKeep.isNotClickable ||
      //               data.ordNo !== dataKeep.ordNo ||
      //               data.value1 !== dataKeep.value1 ||
      //               data.toolText1 !== dataKeep.toolText1 ||
      //               data.toolText2 !== dataKeep.toolText2 ||
      //               data.value2 !== dataKeep.value2) {
      //               data.colorFlg = 1;
      //             }
      //           }
      //         }
      //       }
      //     }
      //   }
      // }

      // mod FNSI-障害票一覧_患者経過総合ビューアNo.16-19(指示の切り替わりポイントを赤くする) 李 start
      // 指示の切り替わりポイント処理を呼び出す
      await this.makeStructionColor(medicineDataListLet, 4);

      // const dataListTmp = await this.convertMedicinetDataTmp({
      //   listIndex: this.rowIndex,
      //   selectLayoutCd: this.selectedLayoutCd
      // });
      // let dataArray = medicineDataListLet;
      // for (let i = 0; i < dataArray.length; i++) {
      //   let datas = dataArray[i].data;
      //   let datasKeepTmp = dataListTmp.find(e => {
      //     return dataArray[i].itemNo === e.itemNo;
      //   });
      //   let datasKeep = null;
      //   if (datasKeepTmp && datasKeepTmp.data && datasKeepTmp.data.length) {
      //     datasKeep = datasKeepTmp.data;
      //   }
      //   datas.forEach(data =>{
      //     if (!datasKeep) {
      //       data.colorFlg = 1;
      //     } else if (data.colorFlg !== 1) {
      //       let hasbefFlg = false;
      //       let hasaftFlg = false;
      //       let befTreatDateDatas = null;
      //       let aftTreatDateDatas = null;
      //       let befStartDt = moment(data.treatDate).add(-7, "days").format("YYYYMMDD");
      //       let befEndDt = moment(data.treatDate).add(-1, "days").format("YYYYMMDD");
      //       let aftStartDt = moment(data.treatDate).add(1, "days").format("YYYYMMDD");
      //       let aftEndDt = moment(data.treatDate).add(7, "days").format("YYYYMMDD");
      //       datasKeep.forEach(dataKeep =>{
      //         if (moment(dataKeep.treatDate).isBetween(befStartDt, befEndDt, "day", "[]")){
      //           if (data.deviceMode === 9) {
      //             if (data.treatMethodCd === dataKeep.treatMethodCd) {
      //               hasbefFlg = true;
      //               befTreatDateDatas = dataKeep;
      //             }
      //           } else if (data.deviceMode !== null && data.deviceMode !== -1) {
      //             if (data.deviceMode === dataKeep.deviceMode) {
      //               hasbefFlg = true;
      //               befTreatDateDatas = dataKeep;
      //             }
      //           }
      //         }
      //         if (moment(dataKeep.treatDate).isBetween(aftStartDt, aftEndDt, "day", "[]")) {
      //           if (data.deviceMode === 9) {
      //             if (data.treatMethodCd === dataKeep.treatMethodCd) {
      //               hasaftFlg = true;
      //               if (aftTreatDateDatas === null) {
      //                 aftTreatDateDatas = dataKeep;
      //               }
      //             }
      //           } else if (data.deviceMode !== null && data.deviceMode !== -1) {
      //             if (data.deviceMode === dataKeep.deviceMode) {
      //               hasaftFlg = true;
      //               if (aftTreatDateDatas === null) {
      //                 aftTreatDateDatas = dataKeep;
      //               }
      //             }
      //           }
      //         }
      //       });
      //       if (!hasbefFlg || !hasaftFlg) {
      //         data.colorFlg = 1;
      //       } else {
      //         if (befTreatDateDatas !== null) {
      //           if (data.isNotClickable !== befTreatDateDatas.isNotClickable ||
      //             data.isRstRoundsFlg !== befTreatDateDatas.isRstRoundsFlg ||
      //             data.value1 !== befTreatDateDatas.value1 ||
      //             data.value2 !== befTreatDateDatas.value2) {
      //             data.colorFlg = 1;
      //           }
      //         }
      //         if (aftTreatDateDatas !== null) {
      //           if (data.isNotClickable !== aftTreatDateDatas.isNotClickable ||
      //             data.isRstRoundsFlg !== aftTreatDateDatas.isRstRoundsFlg ||
      //             data.value1 !== aftTreatDateDatas.value1 ||
      //             data.value2 !== aftTreatDateDatas.value2) {
      //             data.colorFlg = 1;
      //           }
      //         }
      //       }
      //     }
      //   });
      // }

      // for (let i = 0; i < medicineDataListLet.length; i++) {
      //   let datas = medicineDataListLet[i].data;
      //   for (let j = 0; j < medicineDataListLet.length; j++) {
      //     if (i !== j && medicineDataListLet[i].cd === medicineDataListLet[j].cd) {
      //       for (let x = 0; x < datas.length; x++) {
      //         let data = datas[x];
      //         let dataj = medicineDataListLet[j].data.find(
      //           e => e.treatDate === data.treatDate
      //         );
      //         if (data.value1 !== undefined && data.value1 !== null && data.value1 !== "" &&
      //           dataj.value1 !== undefined && dataj.value1 !== null && dataj.value1 !== "") {
      //           data.colorFlg = 2;
      //         }
      //         if (data.value2 !== undefined && data.value2 !== null && data.value2 !== "" &&
      //           dataj.value2 !== undefined && dataj.value2 !== null && dataj.value2 !== "") {
      //           data.colorFlg = 2;
      //         }
      //       }
      //     }
      //   }
      // }
      // mod FNSI-障害票一覧_患者経過総合ビューアNo.16-19(指示の切り替わりポイントを赤くする) 李 end

      for (let l = 0; l < this.rowIndexMax; l++) {
        if (l !== this.rowIndex) {
          let medicineDataListLetTmp = await this.convertMedicinetData({
            listIndex: l,
            selectLayoutCd: this.selectedLayoutCd
          });
          for (let i = 0; i < medicineDataListLet.length; i++) {
            let datas = medicineDataListLet[i].data;
            for (let j = 0; j < medicineDataListLetTmp.length; j++) {
              if (medicineDataListLet[i].cd === medicineDataListLetTmp[j].cd) {
                for (let x = 0; x < datas.length; x++) {
                  let data = datas[x];
                  let dataj = medicineDataListLetTmp[j].data.find(
                    e => e.treatDate === data.treatDate
                  );
                  // mod bug 7872 修正 chen start
                  if (data && data.value1 !== undefined && data.value1 !== null && data.value1 !== "" &&
                    dataj.value1 !== undefined && dataj.value1 !== null && dataj.value1 !== "") {
                    data.colorFlg = 2;
                  }
                  if (data && data.value2 !== undefined && data.value2 !== null && data.value2 !== "" &&
                    dataj.value2 !== undefined && dataj.value2 !== null && dataj.value2 !== "") {
                    data.colorFlg = 2;
                  }
                  // mod bug 7872 修正 chen end
                }
              }
            }
          }
        }
      }
      // #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start
      if (medicineDataListLet.length > 1) {
        const addIndex = medicineDataListLet.findIndex(item => item.itemNo === -1);
        const addObject = medicineDataListLet.find(item => item.itemNo === -1);
        if (addIndex > -1) {
          medicineDataListLet.splice(addIndex, 1);
          medicineDataListLet.unshift(addObject);
        }
      }
      // #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end
      this.medicineDataList = medicineDataListLet;
      // add 1006-398 指示の切り替わりポイントを赤くする 陳 end
    }).finally(() => {
      this.finishLoadingScreen();
      
      // 親コンポーネント（PatViewer.vue）にcreated完了を通知
      EventBus.$emit("childCreated");
    });
    // mod FNSI-性能を最適化する 李 end
  },

  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    //add FNSI内容修正 バグ284、286 姜
    ...mapActions("pat-viewer", ["setOrdNoMediList"]),
    //add FNSI内容修正 バグ284、286 姜
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
    ...mapActions("pat-viewer", ["setPatIdKeep", "setDataListKeepMedicine", "setDateList", "setPatIdKeepChgFlg"]),
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 end
    ...mapActions("pat-viewer", ["convertMedicinetData"]),
    ...mapActions("pat-viewer-modal", [
      "showMediCreateModal",
      "showMediEditModal"
    ]),
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
     * 「投与薬剤」タイトルクリック時処理
     * @summary 投与薬剤新規登録モーダル表示
     */
    onTitleClick() {
      // add #10359 編集権限の動作不正 dengshen start
      if (!this.getItemAuthorized('Indication', 'default_authority')) {
        this.$ons.notification.alert({
          // title: "権限エラー",
          // message: functionName+"を操作する権限がありません。管理者に確認してください。"
          title: DIALOG_MESSAGES[12000315].title,
          message: messageFormat(DIALOG_MESSAGES[12000315].message, "投与薬剤")
        });
        return;
      }
      // add #10359 編集権限の動作不正 dengshen end
      // すべて過去日の場合、操作不可メッセージを表示
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
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
      // mod FNSI-【1006】最新の改修対象一覧の678対応 韓 start
      //const treatDate = moment(this.baseDate, "YYYYMMDD").format("YYYY-MM-DD");
      //FNSI-修正　#4707　【患者経過総合ビューア】→【投与薬剤】、「開始日」「初回投与日」 修正、xugj add start
      let treatDate = this.getRecentBaseDate();
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      if (!treatDate) {
        return;
      }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      // const today = this.baseDate;
      // if (this.ordMainData[today]) {
      //   // 治療状況は「3:治療中」の場合、【投与薬剤編集】の「開始日」「初回投与日」を当日にする
      //   const rstDialysisState = this.ordMainData[today].rstDialysisState;
      //   if(rstDialysisState === "3") {
      //     treatDate = today;
      //   }
      // }
　　　//FNSI-修正　#4707　【患者経過総合ビューア】→【投与薬剤】、「開始日」「初回投与日」 修正、xugj add end
      // mod FNSI-【1006】最新の改修対象一覧の678対応 韓 end
      // 新規登録モーダルを表示

      //mod #10266  start
      // this.showMedicineModal(treatDate, null, true, null);
      this.showMedicineModal(treatDate, null, true, null,null,"2");
      //mod #10266  end
    },

    /**
     * 「投与薬剤」タイトルクリック時処理
     * @summary 医療材料追加多级モーダル表示
     */
    // #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start
    onAddImgClick(cellInfo) {
      console.log('cellInfo', cellInfo)
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
      let treatDate = cellInfo.treatDate;

      // 新規登録モーダルを表示

      //mod #10266  start
      // this.showMedicineModal(treatDate, cellInfo.ordNo, true, null);
      this.showMedicineModal(treatDate, cellInfo.ordNo, true, null,null,null);
      //mod #10266  end

    },
    // #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end

    /**
     * 「投与薬剤」サブタイトルクリック時処理
     * @summary タイトルがなくサブタイトルが「投与薬剤」の場合、投与薬剤新規登録モーダルヒュウ時
     *          サブタイトルが「投与薬剤」でなければ、投与薬剤編集モーダル表示
     * @param event ターゲット
     * @param rowInfo 行情報
     */
    onSubTitleClick(event, rowInfo, itemInfo, itemIndex) {
      // すべて過去日の場合、操作不可メッセージを表示
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      // if (this.getIsPastDate) {
      //   this.showDisProcMessage();
      //   return;
      // }

      /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
      if (rowInfo.readOnly) {
        return;
      }
      /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */

      // 一覧上に治療予定がない場合は処理終了
      // if (!this.isTreatPlan) {
      //   return;
      // }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      // 新規登録フラグ
      const isCreate = rowInfo.itemNo === -1;
      // 治療日      //mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start
      // 治療日
      // const treatDate = isCreate
      //   ? this.baseDate
      //   : this.getRecentMediBaseDate(rowInfo.cd, rowInfo.itemNo);
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      // const treatDate = this.getRecentBaseDate();
      let treatDate = this.getRecentBaseDate();
      if (!treatDate) {
        return;
      }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      //mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end
      // 直近日の指示有無チェック
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      // const hasIndInfo = rowInfo.data.find(
      //   i => i.treatDate === treatDate && i.value1 !== null
      // );
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end

      // 指示がない場合は処理終了
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      let indMediNewInfo = null;
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      if (!isCreate) {
        // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
        // return;
        // 現在の画面は予定されておらず、後の日付は予定されています。
        let indMediInfo = "";
        let newDate = null;
        for (let date in this.ordMainData) {
          if (date >= treatDate && this.ordMainData[date] && this.ordMainData[date].indMediInfo && this.ordMainData[date].rstDialysisState == "0") {
            indMediInfo = this.ordMainData[date].indMediInfo;
            if (indMediInfo) {
              let indMediInfoArr = JSON.parse(indMediInfo);
              const hasMedineInfo = indMediInfoArr.find(item => item.no == rowInfo.itemNo);
              if (hasMedineInfo) {
                newDate = date;
                indMediNewInfo = hasMedineInfo;
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
      //add FNSI内容修正 バグ284、286 姜
      let ordNoList = [];
      for (let i = 0; i < rowInfo.data.length; i++) {
        if (rowInfo.data[i].value1 !== null && rowInfo.data[i].value1 !== undefined) {
          ordNoList.push(rowInfo.data[i].ordNo);
        }
      }
      this.setOrdNoMediList(ordNoList);
      //add FNSI内容修正 バグ284、286 姜
      // 投与薬剤モーダルの表示
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      // this.showMedicineModal(treatDate, null, isCreate, itemIndex);

      //mod #10266  start
      // this.showMedicineModal(treatDate, null, isCreate, itemIndex, indMediNewInfo);
      this.showMedicineModal(treatDate, null, isCreate, itemIndex, indMediNewInfo,"2");
      //mod #10266  end

      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
    },

    /**
     * 「投与薬剤」データセルクリック時処理
     * @summary 投与薬剤編集モーダル表示
     * @param event ターゲット
     * @param cellInfo セル情報
     * @param itemName 行項目名
     * @param 「投与薬剤」データリスト
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
      //add FNSI内容修正 バグ284、286 姜
      let ordNoList = [];
      ordNoList.push(cellInfo.ordNo);
      this.setOrdNoMediList(ordNoList);
      //add FNSI内容修正 バグ284、286 姜
      // 指示項目がクリックsれた場合、以下の処理を実行する
      if (isIndClick) {
        // 対象投与薬剤の存在チェック
        if (cellInfo.value1 === "未登録" || cellInfo.value1 === null) {
          return;
        }

        // 投与薬剤モーダルの表示
        this.showMedicineModal(
          cellInfo.treatDate,
          cellInfo.ordNo,
          false,
          itemIndex,
          //add #10266 start
          null,
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

        // 「治療記録」-「投与薬剤」に画面遷移する
        this.setRouter(cellInfo.ordNo, [
          "treatment-record",
          "treatment-record-medicine"
        ]);
      }
    },

    /**
     * 投与薬剤モーダルを表示
     * @param treatDate 治療日
     * @param ordNo オーダー番号
     * @param recentDate 直近日
     * @param isCreate 新規登録フラグ
     * @param itemIndex
     * @param indMediNewInfo 薬剤情報です
     * @param update_flag  2:一括編集  その他の値（2以外）：個別編集
     */
    // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
    // showMedicineModal(treatDate, ordNo, isCreate, itemIndex) {
    //mod #10266  start
    // showMedicineModal(treatDate, ordNo, isCreate, itemIndex, indMediNewInfo) {
    showMedicineModal(treatDate, ordNo, isCreate, itemIndex, indMediNewInfo, update_flag) {
      //mod #10266  end
    // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      // 投与薬剤モーダルに渡す情報
      const settingData = deepCopy(this.faultSettingMedicineData);
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

      //add #10266 start
      settingData.update_flag = update_flag;
      //add #10266 end

      // add FNSI-投与薬剤編集の修正 楊 start
      // サブタイトルクリック時
      settingData.isTitleCk = ordNo ? false : true;
      // add FNSI-投与薬剤編集の修正 楊 end
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
      if (!isCreate) {
        // 投与薬剤デフォルトデータ
        const date = moment(treatDate).format("YYYYMMDD");
        settingData.fieldsData = this.setDefaultData(date, itemIndex);
      }
      if (isCreate) {
        // 新規登録モーダルを表示
        this.showMediCreateModal({
          dispComponentId: "ind-medicine-set",
          settingIndData: settingData
        });
      } else {
        // 編集モーダルを表示
        //FutureNetWeb+Si no.5448 劉全航 start
        settingData.dateInterval = this.medicineDataList[itemIndex].dateInterval;
        //FutureNetWeb+Si no.5448 劉全航 end
        // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
        if (settingData.dateInterval > 10) {
          settingData.dateInterval = indMediNewInfo?.date_interval;
        }
        // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
        this.showMediEditModal({
          settingIndData: settingData
        });
      }
    },

    /**
     * 投与薬剤のモーダルに渡すデフォルト値の設定
     * @param targetDate 対象曜日
     * @param index クリックデータセルの要素番号(投与薬剤の何番目の項目か)
     * @param itemName サブタイトル
     * @return defaultData {Objecct}投与薬剤モーダルのデフォルト値情報
     */
    setDefaultData(targetDate, index) {
      let defaultData = null;
      if (null !== this.ordMainData[targetDate]) {
        // クリックしたデータセルの日付の投与薬剤データを取得
        const mediJson = JSON.parse(this.ordMainData[targetDate].indMediInfo);

        // mod FNSI-小数点の修正 楊 start
        // 治療状況
        const rstDialysisState = this.ordMainData[targetDate].rstDialysisState;
        // mod FNSI-小数点の修正 楊 end

        // クリックしたデータセルの日付に対象投与薬剤の存在チェック
        // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
        // const objectData = mediJson.find(item => {
        const objectData = !!mediJson && mediJson.find(item => {
          // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
          return item.no === this.medicineDataList[index].itemNo;
        });

        // 削除済み以外の投与薬剤と対象日付に存在する投与薬剤のみデフォルトを与える
        if (this.medicineDataList[index].cd && objectData) {
          // デフォルト値の各要素を格納
          defaultData = {
            // mod FNSI-小数点の修正 楊 start
            // 治療状況
            rstDialysisState: rstDialysisState,
            // mod FNSI-小数点の修正 楊 end
            // シーケンス番号
            seqNo: objectData.no,
            // ポップオーバー用データ
            cd: objectData.cd,
            // 数量
            amount: objectData.amount,
            // 単位
            unit: this.transrateMediMst(
              objectData.cd,
              "unit",
              objectData.medicine_type,
              objectData.unit
            ),
            // プロシージャコード
            procedureCd: objectData.procedure_cd,
            // タイミングコード
            timingCd: objectData.timing_cd,
            // コメント
            comment: objectData.comment,
            // 薬剤区分
            medicineType: objectData.medicine_type
          };
        } else {
          defaultData = {
            // シーケンス番号
            seqNo: this.medicineDataList[index].itemNo,
            // ポップオーバー用データ
            cd: this.medicineDataList[index].cd,
            medicineType: this.medicineDataList[index].medicineType
          };
        }
      }
      return defaultData;
    },

    /**
     * 薬剤マスタ取得
     * @param code 変換元コード
     * @param column 変換するマスタのカラム名
     * @param unit json格納単位
     */
    transrateMediMst(code, column, medicineType,unit) {
      //jsonに単位があればそれがdefault値
      if(unit){
        return unit;
      }
      let mstMedi = this.mstMedicineData;
      let mstMediCd = "medicineCd";
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //if (medicineType === "2") {
      if (medicineType == 2) {
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        // 調製薬剤なら
        mstMedi = this.mstMedicineMixData;
        mstMediCd = "medicineMixCd";
      }

      const mstData = mstMedi.find(mstItem => {
        // return mstItem[mstMediCd] === code;
        return mstItem[mstMediCd] == code;
      });
      if (!mstData) {
        return null;
      } else {
        return mstData[column];
      }
    },

    /**
     * 基準日から直近日の投与薬剤データのある日付を取得
     * @param cd 投与薬剤コード
     * @param no 投与薬剤識別番号
     */
    getRecentMediBaseDate(cd, no) {
      // 直近日格納用
      let recentDate = null;
      for (const date in this.ordMainData) {
        // 治療情報から投与薬剤情報を取得
        const mediInfo = this.ordMainData[date]
          ? JSON.parse(this.ordMainData[date].indMediInfo)
          : [];
        // 投与薬剤コードと投与薬剤識別番号がともに一致するデータのある治療日を取得
        mediInfo.forEach(mediItem => {
          if (mediItem.cd === cd && mediItem.no === no) {
            recentDate = null === recentDate ? date : recentDate;
            return;
          }
        });
        if (recentDate) {
          break;
        }
      }
      return recentDate;
    },
    //add FNSI-No.IES145 権限対応  吉 start
    getTreatmentRecordAuthority() {
      return this.hasAuthority();
    },
    //add FNSI-No.IES145 権限対応  吉 end
    //FNSI-修正 #5879 投薬の表示順の修正　ljx start
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
    //FNSI-修正 #5879 投薬の表示順の修正　ljx end
  }
};
</script>

<style scoped lang="scss">
/* 患者経過総合ビューア共通スタイル定義 */
@import "../../css/style.scss";
</style>
