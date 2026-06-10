/** * スケジュール(クール、治療開始時刻、ベッド) */
<template>
  <div>
  <base-content
    :func-name="funcName"
    :disp-data-list="scheduleDataList"
    @onTitleClick="onTitleClick"
    @onSubTitleClick="onSubTitleClick"
    @onCellClick="onCellClick"
  />
    <message-dialog
      :visible.sync="isDialogVisble"
      :message-cd="22020005"
      type="1"
    />
  </div>
</template>

<script>
// add FNSI-マスタ削除表示の対応課題--クール 鄧シン start
import { ApiHelper } from "@/apis/AxiosHelper";
import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord.js";
// add FNSI-マスタ削除表示の対応課題--クール 鄧シン end
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
//add FNSI-No.IES145 権限対応  吉 start
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
//add FNSI-No.IES145 権限対応  吉 end
/**
 * コンポーネント共通操作
 */
import BaseComponent from "@/components/pat-viewer/contents/base/BaseComponent";
import messageDialog from "@/components/common/message-dialog/MessageDialog.vue";
// add FNSI-障害票一覧_患者経過総合ビューアNo.16-19(指示の切り替わりポイントを赤くする) 李 start
import MakeStructionColorMixin from "./MakeStructionColorMixin";
// add FNSI-障害票一覧_患者経過総合ビューアNo.16-19(指示の切り替わりポイントを赤くする) 李 end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

export default {
  components: {
    "base-content": baseContent,
    "message-dialog": messageDialog
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
       * 表示するデータのリスト
       * @summary 親コンポーネントに渡す情報
       */
      scheduleDataList: [],
      isDialogVisble: false,
    //add FNSI-No.IES145 権限対応  吉 start
    authorityCds:[
      AUTHORITY_CODES.IND_PEDIT,
      AUTHORITY_CODES.IND_EDIT,
      AUTHORITY_CODES.SCHE_MOVE,
    ],
      flagAuthority:false,
    //add FNSI-No.IES145 権限対応  吉 end
      deletedName: '削除済み'
    };
  },

  computed: {
    // mod 1006-398 指示の切り替わりポイントを赤くする 陳 start
    //...mapGetters("pat-viewer", ["getMstKurData", "getMstBedData", "getTreatmentData"]),
    ...mapGetters("pat-viewer", ["getMstKurData", "getMstBedData", "getTreatmentData", "getTreatmentDataTmp",
      "getDateList", "getSelectedPeriod", "getDataListKeepSchedule", "getPatIdKeep", "getPatIdKeepChgFlg"]),
    ...mapGetters("pat-info", { patId: "selectedPatId" }),
    // mod 1006-398 指示の切り替わりポイントを赤くする 陳 end
    ...mapGetters("pat-viewer-modal", ["getDefaultSettingIndScheduleData"]),

    /**
     * 項目列の縦文字タイトル
     * @summary 親コンポーネントに渡す情報
     */
    funcName() {
      let name = "スケジュール";

      if (
        this.scheduleDataList.length &&
        this.scheduleDataList[0].itemName === "スケジュール"
      ) {
        name = null;
      }

      return name;
    },

    /**
     * スケジュール(IndEditBase)に渡すデータ(雛形)
     */
    faultSettingScheduleData() {
      return this.getDefaultSettingIndScheduleData;
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

  async created() {
    this.startLoadingScreen();
    this.flagAuthority = this.getTreatmentRecordAuthority();
    // 表示用にスケジュール情報を加工
    this.convertScheduleData({
      listIndex: this.rowIndex,
      selectLayoutCd: this.selectedLayoutCd
    }).then(scheduleDataListLet => {
      // add FNSI-マスタ削除表示の対応課題--クール 鄧シン start
      scheduleDataListLet[0].data.forEach(item =>{
        if (item.value1 === "削除済み") {
            ApiHelper.get("/mainData/getMstKurNameByCd/" + item.kurCd1).then(
              response => {
                if (response.data) {
                    // 削除のクール名取得するの場合、【削除済み】＋ 倫理削除されたマスタの表示内容を表示
                    item.value1 = MASTER_DELETE_DISPLAY.DELETED + response.data;
                }
              }
            );
        }
        if (item.value2 === "削除済み") {
            ApiHelper.get("/mainData/getMstKurNameByCd/" + item.kurCd2).then(
              response => {
                if (response.data) {
                    // 削除のクール名取得するの場合、【削除済み】＋ 倫理削除されたマスタの表示内容を表示
                    item.value2 = MASTER_DELETE_DISPLAY.DELETED + response.data;
                }
              }
            );
        }
      });
      // 指示の切り替わりポイント処理を呼び出す
      this.makeStructionColor(scheduleDataListLet, 2);

      this.scheduleDataList = scheduleDataListLet;
      // FNSI-修正 マスタ削除の対応 wangchen add start
      this.scheduleDataList.forEach(item=>{
          item.data.forEach(dateItem=>{
              if(dateItem.rstDialysisState!="0"){
                  if(dateItem.rstDialysisState=="6"){
                      // 指示データの場合
                      if (dateItem.value1 && dateItem.value1.indexOf(this.deletedName) != -1) {
                          // ord＿mainに保持している名称を表示。
                          if(item.itemName=="クール"){
                              dateItem.value1 = dateItem.indKurName;
                          }else if(item.itemName=="ベッド"){
                              dateItem.value1 = dateItem.indBedName;
                          }
                      }
                      // 実績データの場合
                      if (dateItem.value2 && dateItem.value2.indexOf(this.deletedName) != -1) {
                          // ord＿mainに保持している名称を表示。
                          if(item.itemName=="クール"){
                              dateItem.value2 = dateItem.rstKurName;
                          }else if(item.itemName=="ベッド"){
                              dateItem.value2 = dateItem.rstBedName;
                          }
                      }
                  }else{
                      // 指示データの場合
                      if (dateItem.value1 && dateItem.value1.indexOf(this.deletedName) != -1) {
                          // 【削除済み】＋ ord＿mainに保持している名称を表示。
                          if(item.itemName=="クール"){
                              dateItem.value1 = '【' + this.deletedName + '】' +dateItem.indKurName;
                          }else if(item.itemName=="ベッド"){
                              dateItem.value1 = '【' + this.deletedName + '】' +dateItem.indBedName;
                          }
                      }
                      // 実績データの場合
                      if (item.value2 && item.value2.indexOf(this.deletedName) != -1) {
                          // 【削除済み】＋ ord＿mainに保持している名称を表示。
                          if(item.itemName=="クール"){
                              dateItem.value2 = '【' + this.deletedName + '】' +dateItem.rstKurName;
                          }else if(item.itemName=="ベッド"){
                              dateItem.value2 = '【' + this.deletedName + '】' +dateItem.rstBedName;
                          }
                      }
                  }
              }
          })
      })
      // FNSI-修正 マスタ削除の対応 wangchen add end
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
    // mod 1006-398 指示の切り替わりポイントを赤くする 陳 start
    //...mapActions("pat-viewer", ["convertScheduleData"]),
    ...mapActions("pat-viewer", ["convertScheduleData", "setPatIdKeep",
      "setDateList", "setDataListKeepSchedule", "setPatIdKeepChgFlg"]),
    // mod 1006-398 指示の切り替わりポイントを赤くする 陳 end
    ...mapActions("pat-viewer-popover", ["setCellInfo"]),
    ...mapActions("pat-viewer-modal", ["showIndModal"]),
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
    ]),
    /**
     * 「スケジュール」タイトルクリック時処理
     * @summary スケジュール編集モーダルの表示
     */
    onTitleClick(event, itemInfo) {
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      // 一覧上がすべて過去日表示の場合、操作不可メッセージの表示
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
      const recentDate = this.getRecentBaseDate();
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      // const treatDate = recentDate || this.baseDate;
      const treatDate = recentDate;
      if (!treatDate) {
        return;
      }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end

      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、前の改修を回復する xugj add start
      // mod FNSI-障害票一覧_患者経過総合ビューア_スケジュール編集No.1 李 start
      // クール、治療開始時刻、ベッドのデータを取得
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      // const scheduleInfo = this.getScheduleData(treatDate, itemInfo);
      let scheduleInfo = this.getScheduleData(treatDate, itemInfo);
      let treatStartTime = this.ordMainData[treatDate].indTreatStartTime;
      treatStartTime = treatStartTime && treatStartTime.indexOf(":") < 0 ? (treatStartTime.slice(0,2) + ":" +  treatStartTime.slice(2)): treatStartTime;
      if (!scheduleInfo) {
        scheduleInfo = {
          bed: this.ordMainData[treatDate].indBedCd,
          kur: this.ordMainData[treatDate].indKurCd,
          treatStartTime:  treatStartTime,
        }
      }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      // スケジュール編集モーダルを開く
      // this.showScheduleModal(treatDate, null, null);

      //mod #10266  start
      // this.showScheduleModal(treatDate, null, scheduleInfo);
      this.showScheduleModal(treatDate, null, scheduleInfo,"2");
      //mod #10266  end

      // mod FNSI-障害票一覧_患者経過総合ビューア_スケジュール編集No.1 李 end
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、前の改修を回復する xugj add end
    },

    /**
     * 「スケジュール」タイトルサブタイトルクリック時処理
     * @summary スケジュール編集モーダルの表示
     */
    onSubTitleClick(event, rowInfo, itemInfo) {
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      // 一覧上がすべて過去日表示の場合、操作不可メッセージの表示
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
      const recentDate = this.getRecentBaseDate();
      // スケジュール編集モーダルで設定する治療開始日デフォルト値
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      // const treatDate = recentDate || this.baseDate;
      const treatDate = recentDate;
      if (!treatDate) {
        return;
      }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、前の改修を回復する xugj add start
      // mod FNSI-障害票一覧_患者経過総合ビューア_スケジュール編集No.1 李 start
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      // クール、治療開始時刻、ベッドのデータを取得
      // const scheduleInfo = this.getScheduleData(treatDate, itemInfo);
      let scheduleInfo = this.getScheduleData(treatDate, itemInfo);
      let treatStartTime = this.ordMainData[treatDate].indTreatStartTime;
      treatStartTime = treatStartTime && treatStartTime.indexOf(":") < 0 ? (treatStartTime.slice(0,2) + ":" +  treatStartTime.slice(2)): treatStartTime;
      if (!scheduleInfo) {
        scheduleInfo = {
          bed: this.ordMainData[treatDate].indBedCd,
          kur: this.ordMainData[treatDate].indKurCd,
          treatStartTime:  treatStartTime,
        }
      }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      // スケジュール編集モーダルを開く
      // this.showScheduleModal(treatDate, null, null);

      //mod #10266  start
      // this.showScheduleModal(treatDate, null, scheduleInfo);
      this.showScheduleModal(treatDate, null, scheduleInfo,"2");
      //mod #10266  end

      // mod FNSI-障害票一覧_患者経過総合ビューア_スケジュール編集No.1 李 end
      //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、前の改修を回復する xugj add end
    },

    /**
     * 「スケジュール」データセルクリック時処理
     * @summary スケジュール編集モーダル表示
     */
    onCellClick(event, cellInfo, itemName, itemInfo, itemIndex, isIndClick) {
      // クリックしたセルに治療日ない場合は、処理終了
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
      // 指示項目クリック時以下の処理を実行する
      if (isIndClick) {
        const treatmentData = this.getTreatmentData[this.rowIndex];
        if (treatmentData[cellInfo.treatDate]) {
          const rstDialysisState = treatmentData[cellInfo.treatDate].rstDialysisState;
          if(rstDialysisState === "3") {
            this.isDialogVisble = true;
            return;
          }
        }

        // クール、治療開始時刻、ベッドのデータを取得
        const scheduleInfo = this.getScheduleData(cellInfo.treatDate, itemInfo);
        // スケジュール編集モーダルの表示
        this.showScheduleModal(
          cellInfo.treatDate,
          cellInfo.ordNo,
          scheduleInfo,
          //add #10266  start
          null
          //add #10266  end
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

        // 治療記録に画面遷移する
        this.setRouter(cellInfo.ordNo, [
          "treatment-record",
          "treatment-record-result"
        ]);
      }
    },

    /**
     * スケジュール編集モーダルの表示
     * @param treatDate 治療日(開始日) ※オーダー番号が格納されている場合、終了日を格納
     * @param ordNo オーダー番号
     * @param scheduleInfo スケジュール情報
     * @param update_flag  2:一括編集  その他の値（2以外）：個別編集
     */
    //mod #10266  start
    // showScheduleModal(treatDate, ordNo, scheduleInfo) {
    showScheduleModal(treatDate, ordNo, scheduleInfo, update_flag) {
      //mod #10266  end
      // IndEditBaseにわたす情報
      const settingData = deepCopy(this.faultSettingScheduleData);
      // 患者ID
      settingData.patId = this.patId;
      // 施設コード
      settingData.facilityCd = this.facilityCd;
      // 治療日のフォーマット調整
      treatDate = moment(treatDate).format("YYYY-MM-DD");
      // 開始日
      settingData.startDate = treatDate;
      // 終了日
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
      // 子コンポーネント(IndSchEdit)にわたす情報
      const settingChildData = new Object();
      // 施設コード
      settingChildData.propsFacilityCd = this.facilityCd;
      // mod FNSI-障害票一覧_患者経過総合ビューア_スケジュール編集No.1 李 start
      if (scheduleInfo) {
        // 透析開始時刻
        settingChildData.propsIndTreatStartTime = scheduleInfo.treatStartTime;
        // クール
        settingChildData.propsSelectedKur = scheduleInfo.kur;
        // ベッド
        settingChildData.propsSelectedBed = scheduleInfo.bed;
      }
      // mod FNSI-障害票一覧_患者経過総合ビューア_スケジュール編集No.1 李 end
      // モダール表示
      this.showIndModal({
        dispComponentId: "ind-sch-edit",
        settingIndData: settingData,
        settingIndChildData: settingChildData
      });
    },

    /**
     * ベッド、治療開始時刻、ベッド 取得処理
     * @param date 基準日
     * @param itemInfo
     */
    getScheduleData(date, itemInfo) {
      const scheduleInfo = {};
      //mod #12546 デグレ】コンバートされた施設の患者経過総合ビューアで治療開始時刻とベッド登録が正しくない zrx start
      // let kurInfo = {};
      // let treatStartTimeInfo = {};
      // let bedInfo = {};
      // for (let i = 0; i < itemInfo.length; i++) {
      //    switch (i) {
      //     case 0:
      //       // クール情報取得
      //       kurInfo = itemInfo[i].data.find(eleData => {
      //         return eleData.treatDate === date;
      //       });
      //       break;
      //     case 1:
      //       // 治療開始時刻取得
      //       treatStartTimeInfo = itemInfo[i].data.find(eleData => {
      //         return eleData.treatDate === date;
      //       });
      //       break;
      //     case 2:
      //       // ベッド情報取得
      //       bedInfo = itemInfo[i].data.find(eleData => {
      //         return eleData.treatDate === date;
      //       });
      //       break;
      //     default:
      //       break;
      //   }
      // }
      const ordInfo = this.ordMainData[date] || {};
      const itemMap = {};
      itemInfo.forEach(item => {
        itemMap[item.itemNo] = item;
      });

      // ===== 1. クール =====
      let kurInfo = itemMap[1]?.data?.find(d => d.treatDate === date) || {};

      if (!kurInfo.treatDate && ordInfo.indKurCd) {
        const kurMaster = this.mstKurData.find(
          m => m.kurCd === ordInfo.indKurCd
        );
        kurInfo = {
          treatDate: ordInfo.treatDate,
          ordNo: ordInfo.ordNo,
          treatMethodCd: ordInfo.indTreatmentCd,
          rstDialysisState: ordInfo.rstDialysisState,
          value1: kurMaster?.kurName || null,
          value2: "未登録"
        };
      }

      // ===== 2. 治療開始時刻 =====
      let treatStartTimeInfo = itemMap[2]?.data?.find(d => d.treatDate === date) || {};

      if (!treatStartTimeInfo.treatDate && ordInfo.indTreatStartTime) {
        const time = ordInfo.indTreatStartTime;
        const formatted =
          time.length === 4
            ? `${time.slice(0, 2)}:${time.slice(2)}`
            : time;
        treatStartTimeInfo = {
          treatDate: ordInfo.treatDate,
          ordNo: ordInfo.ordNo,
          treatMethodCd: ordInfo.indTreatmentCd,
          rstDialysisState: ordInfo.rstDialysisState,
          value1: formatted,
          value2: "未登録"
        };
      }

      // ===== 3. ベッド =====
      let bedInfo = itemMap[3]?.data?.find(d => d.treatDate === date) || {};

      if (!bedInfo.treatDate && ordInfo.indBedCd) {
        const bedMaster = this.mstBedData.find(
          m => m.bedCd === ordInfo.indBedCd
        );
        bedInfo = {
          treatDate: ordInfo.treatDate,
          ordNo: ordInfo.ordNo,
          treatMethodCd: ordInfo.indTreatmentCd,
          rstDialysisState: ordInfo.rstDialysisState,
          value1: bedMaster?.bedName || null,
          value2: "未登録"
        };
      }
      //mod #12546 デグレ】コンバートされた施設の患者経過総合ビューアで治療開始時刻とベッド登録が正しくない zrx end

      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      if (!kurInfo) {
        return false;
      }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      // マスタ翻訳後クール情報格納
      scheduleInfo.kur = this.translationToCode(
        kurInfo.value1,
        this.mstKurData,
        "kurName",
        "kurCd"
      );
      // 透析開始時刻格納
      scheduleInfo.treatStartTime =
        !treatStartTimeInfo.value1 || "未登録" === treatStartTimeInfo.value1
          ? null
          : treatStartTimeInfo.value1;
      //del #12546 デグレ】コンバートされた施設の患者経過総合ビューアで治療開始時刻とベッド登録が正しくない zrx end
      // 透析開始時刻の0埋め
      // scheduleInfo.treatStartTime =
      //   null !== scheduleInfo.treatStartTime
      //     ? scheduleInfo.treatStartTime.padStart(5, "0")
      //     : null;
      //del #12546 デグレ】コンバートされた施設の患者経過総合ビューアで治療開始時刻とベッド登録が正しくない zrx end
      // マスタ翻訳後ベッド情報格納
      scheduleInfo.bed = this.translationToCode(
        bedInfo.value1,
        this.mstBedData,
        "bedName",
        "bedCd"
      );
      return scheduleInfo;
    },

    /**
     * マスタデータをコードへ翻訳
     * @param value 翻訳する元データ
     * @param mstInfo 翻訳する情報
     * @param mstName 翻訳元の名称名
     * @param mstCd  翻訳するコード名
     */
    translationToCode(value, mstInfo, mstName, mstCd) {
      const mstData = mstInfo.find(item => {
        return item[mstName] === value;
      });
      // マスタに名称がなければ未登録の0を返す
      if (!mstData) {
        return 0;
      } else {
        return mstData[mstCd];
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
