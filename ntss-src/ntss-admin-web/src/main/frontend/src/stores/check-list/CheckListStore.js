//@ts-check
/**
 * チェックリスト用ストア
 */
import {
  sendRequestGetReloadInterval,
  sendRequestGetOrdMainTreatment,
  sendRequestGetOrdMainByTreatDate,
  // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
  // sendRequestGetOrdCheckListByOrdNo,
  sendRequestGetOrdMainChiryouchuu,
  sendRequestGetOrdMainShiteibi,
  sendRequestGetOrdCheckListZen,
  sendRequestGetOrdCheckListIcou,
  // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
  sendRequestGetMstEquipList,
  sendRequestGetOrdCheckListAll
} from "@/apis/check-list";
import { sendRequestGetKurSelector } from "@/apis/send-condition";
import { sendRequestGetMstChecklist } from "@/apis/mst-checklist";
import { sendRequestGetKur } from "@/apis/status-list";
import {
  DIALISYS_STATE,
  MACHINE_ENTRY_STATE
} from "@/constants/statusMapConstants";
import moment from "moment";
// チェックリスト画面に患者の横の画像が表示されません。linjunfeng start
import imgDuplication from "@/assets/name_duplication.png"
// チェックリスト画面に患者の横の画像が表示されません。linjunfeng end

export default {
  strict: true,
  namespaced: true,
  state: {
    // チェックリストグリッド用列設定
    checklistColumn: null,
    checklistColumnHeader: null,
    // クール詳細一覧情報
    mstKurList: [],
    // クール一覧情報
    mstKurSelector: null,
    // ベッドグループ一覧情報
    mstBedGroupList: null,
    // チェックリストマスタ設定情報
    checklistSetting: null,
    // 表示切替フラグ true:治療中、false:指定日
    isDisplayTreatingMode: true,
    // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
    isAsynComplete: false,
    // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end
    // 抽出条件
    //mod FNSI修正 redmine4255 房 start
    // mod FNSI-横展開 表示条件のサインイン内保持_チェックリスト機能分 周 start
    condition: null,
    // condition: {
    //   bedGroupCd: -1,
    //   nextPat: 0,
    //   treatDate: moment(new Date()).format("YYYY-MM-DD"),
    //   kurCd: -1,
    //   viewTreatDate: false,
    //   isAutoReload: false,
    //   isShowUsageGuide: false
    // },
    // mod FNSI-横展開 表示条件のサインイン内保持_チェックリスト機能分 周 end
    //mod FNSI修正 redmine4255 房 end
    // スケジュール
    ordMainList: null,
    // データ取得処理のキャンセルフラグ
    isDataLoadCancel: false,
    // データ読み込み中
    isDataLoading: false,
    // 自動更新間隔
    reloadInterval: 3,
    // 強制サインアウトフラグ (0:自動サインアウトする、1:自動サインアウトしない)
    forceSignOutFlag: 0,
  },
  getters: {
    // 抽出条件
    getCondition: state => state.condition,
    // チェックリストグリッド用列設定
    getChecklistColumn: state => state.checklistColumn,
    getChecklistColumnHeader: state => state.checklistColumnHeader,
    getMstKurSelector: state => state.mstKurSelector,
    getMstBedGroupList: state => state.mstBedGroupList,
    getChecklistSetting: state => state.checklistSetting,
    getOrdMainList: state => state.ordMainList,
    getIsDisplayTreatingMode: state => state.isDisplayTreatingMode,
    // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
    getIsAsynComplete: state => state.isAsynComplete,
    getIsDataLoadCancel: state => state.isDataLoadCancel,
    // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end
    getIsDataLoading: state => state.isDataLoading,
    getReloadInterval: state => state.reloadInterval,

    /**
    /**
     * 情報表示判定処理
     */
    isDispTreatData(state, getters) {
      return treatData => {
        let ret = false;

        // 現クール/次クール開始日付時刻を取得
        const currentKurStartDateTime = getCurrentKurStartDateTime(
          state.mstKurList
        );
        const nextKurStartDateTime = getNextKurStartDateTime(state.mstKurList);

        // 現在治療中の治療データである
        let isDialysis =
          treatData.machineEntry === MACHINE_ENTRY_STATE.NOW_PATIENT &&
          treatData.rstDialysisState < DIALISYS_STATE.AFTER_DRAINAGE;
        // 次患者の治療データである
        const isNextDialysis =
          !isDialysis &&
          treatData.machineEntry === MACHINE_ENTRY_STATE.NEXT_PATIENT;
        // 次患者である場合
        let checkKurDateTime = "";
        if (isNextDialysis) {
          // チェック対象日時(治療日+クール開始時刻)を作成
          checkKurDateTime =
            treatData.treatDate +
            getKurStartTime(state.mstKurList, treatData.kurCd);
        }

        // 治療状況画面が表示されている場合
        if (getters.getIsDisplayTreatingMode) {
          // 治療状態が後体重測定待ち、版確定待ちの場合
          if (
            treatData.rstDialysisState === DIALISYS_STATE.AFTER_DRAINAGE ||
            treatData.rstDialysisState === DIALISYS_STATE.AFTER_WEIGHT_MEASURING
          ) {
            // 治療中とする
            isDialysis = true;
          }
        }
        if (isDialysis) {
          // 治療中のデータは表示する
          ret = true;
        } else {
          // 条件別次患者表示
          switch (getters.getCondition.nextPat) {
            case 0: {
              // 表示しない
              break;
            }
            case 1: {
              // 現クール
              if (isNextDialysis) {
                // 現クール判定
                if (checkKurDateTime <= currentKurStartDateTime) {
                  ret = true;
                }
              }
              break;
            }
            default: {
              // 次クール
              if (isNextDialysis) {
                // 次クール判定
                if (checkKurDateTime <= nextKurStartDateTime) {
                  ret = true;
                }
              }
              break;
            }
          }
        }
        return ret;
      };
    },
    getForceSignOutFlag: state => state.forceSignOutFlag,
  },
  actions: {
    /**
     * クール詳細情報一覧の取得
     */
    async fetchKur({ commit }, facilityCd) {
      await sendRequestGetKur(facilityCd)
        .then(response => {
          // 取得したクール一覧情報をセット
          commit("setMstKurList", response.data);
        })
        .catch(err => {
          console.error(err);
        });
    },
    /**
     * クールとベッドの一覧取得
     * facilityCd: 施設コード
     */
    async fetchKurBedGroup({ commit },facilityCd = undefined) {
      await sendRequestGetKurSelector(undefined,facilityCd)
        .then(response => {
          // 取得したクール一覧情報をセット
          commit("setKurSelector", {
            mstKurSelector: response.data.kurSelector
          });

          const dataList = response.data.bedGroupList.copyWithin(0, 0);
          dataList.forEach((value, index, array) => {
            // ベッドリスト
            array[index].bedList = JSON.parse(array[index].bedList);
          });

          // 取得したベッドグループ一覧情報をセット
          commit("setBedGroupList", { mstBedGroupList: dataList });
        })
        .catch(err => {
          console.error(err);
        });
    },

    /**
     * チェックリストマスタ設定情報取得
     * facilityCd: 施設コード
     */
    async getCheckListSetting({ commit }, {facilityCd, autoRefreshFlag}) {
      try {
        // 施設コードを指定してチェックリストマスタ設定情報を取得
        const response = await sendRequestGetMstChecklist({
          facilityCd: facilityCd,
          autoRefreshFlag
        });
        const dataList = response.data.copyWithin(0, 0);

        dataList.forEach((value, index, array) => {
          // JSONデータ変換
          // チェックリストマスタ項目
          array[index].checklistSettings = JSON.parse(
            array[index].checklistSettings
          );
        });

        // 取得した設定内容を保存
        commit("setChecklistSetting", dataList[0]);
      } catch (e) {
        alert(e.message);
      }
    },

    // チェックリスト：grid列項目作成
    setStatusGridColumn({ state, commit }) {
      // add FNSI-redmine_#3908_ソート方法の改善 周 start
      const getWidthArray = emValue => {
        switch (emValue) {
          case 8:
            return [96, 120, 132, 156];
          case 9:
            return [108, 135, 148, 175];
          case 10:
          default:
            return [120, 150, 165, 195];
        }
      };
      // add FNSI-redmine_#3908_ソート方法の改善 周 end
      // ロック列
      // FNSI-チェックリスト画面表示を修正 周 mod start
      // const headColumn = {
      //   key: "bedName",
      //   code: "bedCd",
      //   field: "bedName",
      //   title: "ベッド名",
      //   // mod FNSI-redmine_#3908_ソート方法の改善 周 start
      //   // width: 120,
      //   width: getWidthArray(10),
      //   // mod FNSI-redmine_#3908_ソート方法の改善 周 end
      //   centerAlign: false,
      //   hidden: false,
      //   locked: true,
      //   lockable: false
      // };
      const headColumn = [{
        key: "bedName",
        code: "bedCd",
        field: "bedName",
        title: "ベッド名",
        // mod FNSI-redmine_#3908_ソート方法の改善 周 start
        // width: 120,
        width: getWidthArray(10),
        // mod FNSI-redmine_#3908_ソート方法の改善 周 end
        centerAlign: false,
        hidden: false,
        locked: true,
        lockable: false
      }];
      // FNSI-チェックリスト画面表示を修正 周 mod end
      // 固定列
      let fixedColumns = [
        {
          key: "patName",
          code: "patId",
          field: "patName",
          title: "患者名",
          // add FNSI-redmine_#3908_ソート方法の改善 周 start
          // width: 10,
          width: getWidthArray(10),
          // add FNSI-redmine_#3908_ソート方法の改善 周 end
          centerAlign: false,
          hidden: false,
          lockable: true,
          // add FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 start
          // mod FNSI-入院患者名の配布表示を修正 周 start
          // isSame: "isSame",
          // mod チェックリスト画面に患者の横の画像が表示されません。linjunfeng start
          // template: "#if (isSame === \"1\") {# #: patName # <img src=\"/ntss-admin-web/img/name_duplication.9baeef13.png\" class=\"pat-name-same-icon\"></img> #} else {# #: patName # #} #",
          template: `#if (isSame === \"1\") {# #: patName # <img src=\"${imgDuplication}\" class=\"pat-name-same-icon\"> #} else {# #: patName # #} #`,
          // mod チェックリスト画面に患者の横の画像が表示されません。linjunfeng end
          // mod FNSI-入院患者名の配布表示を修正 周 end
          // add FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 end
          inOutClass: "inOutClass"
        },
        // add FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 start
        {
          key: "hospPatId",
          code: "hospPatId",
          field: "hospPatId",
          title: "患者ID",
          // add FNSI-redmine_#3908_ソート方法の改善 周 start
          // width: 9,
          width: getWidthArray(9),
          // add FNSI-redmine_#3908_ソート方法の改善 周 end
          centerAlign: false,
          hidden: false,
          lockable: true
        },
        // add FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 end
        {
          key: "viewTreatDate",
          code: "treatDate",
          field: "viewTreatDate",
          title: "治療日",
          // add FNSI-redmine_#3908_ソート方法の改善 周 start
          // width: 8,
          width: getWidthArray(8),
          // add FNSI-redmine_#3908_ソート方法の改善 周 end
          centerAlign: false,
          hidden: true,
          lockable: true
        },
        {
          key: "kurName",
          code: "kurCd",
          field: "kurName",
          title: "クール",
          // add FNSI-redmine_#3908_ソート方法の改善 周 start
          // width: 8,
          width: getWidthArray(8),
          // add FNSI-redmine_#3908_ソート方法の改善 周 end
          centerAlign: false,
          hidden: false,
          lockable: true
        },
        {
          key: "medicine",
          code: "medicineCd",
          field: "medicine",
          title: "投与薬剤",
          // add FNSI-redmine_#3908_ソート方法の改善 周 start
          // width: 8,
          width: getWidthArray(8),
          // add FNSI-redmine_#3908_ソート方法の改善 周 end
          centerAlign: false,
          hidden: false,
          lockable: false
        }
      ];

      // 可変列
      // チェックリスト項目数セット
      const checklistSetting = state.checklistSetting.checklistSettings;
      for (const setting of checklistSetting) {
        // 工程判定
        if ( setting.dialysis_prog_cd !== 3 ) {
          // 「3：未使用」以外
          const listCdString = "checklist_" + setting.list_cd.toString();
          let addColumn = {
            key: listCdString,
            code: setting.list_cd,
            field: listCdString,
            title: setting.list_name,
            // add FNSI-redmine_#3908_ソート方法の改善 周 start
            // width: 8,
            width: getWidthArray(8),
            // add FNSI-redmine_#3908_ソート方法の改善 周 end
            centerAlign: false,
            hidden: false,
            lockable: false
          };
          fixedColumns.push(addColumn);
        }
      }
      // チェックリスト項目列セット
      // mod FNSI-redmine_#3908_ソート方法の改善 周 start
      // commit("setChecklistColumn", fixedColumns);
      // commit("setChecklistColumnHeader", headColumn);

      if (!state.checklistColumn) {
        commit("setChecklistColumn", fixedColumns);
      }
      if (!state.checklistColumnHeader) {
        commit("setChecklistColumnHeader", headColumn);
      }
      // mod FNSI-redmine_#3908_ソート方法の改善 周 end
    },

    // 抽出条件
    setCondition({ commit }, condition) {
      // 抽出条件セット
      commit("setCondition", condition);
    },
    setChecklistColumn({ commit }, columns) {
      // チェックリスト項目列セット
      commit("setChecklistColumn", columns);
    },
    // add FNSI-redmine_#3908_ソート方法の改善 周 start
    setChecklistColumnHeaderWidth({ commit }, parm) {
      commit("setChecklistColumnHeaderWidth", parm);
    },
    setChecklistColumnWidth({ commit }, parm) {
      commit("setChecklistColumnWidth", parm);
    },
    // add FNSI-redmine_#3908_ソート方法の改善 周 end
    // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
    /**
     * 治療中
     * ord_main情報を取得
     * facilityCd: 施設コード
     * nextPat: 次患者[0:次クール, 1:当日, 2:次クール以降]
     */
    async getOrderMainListChiryouchuu({ commit, dispatch }, parm) {
      // ord_main情報取得
      const response = await sendRequestGetOrdMainChiryouchuu(parm);

      // 取得データの変換
      const dataList = response.data.copyWithin(0, 0);
      dataList.forEach(async (value, index, array) => {
        // 治療日を作成
        let tDate =
          array[index].treatDate.substr(4, 2) +
          "/" +
          array[index].treatDate.substr(6, 2);
        let weekList = ["", "月", "火", "水", "木", "金", "土", "日"];
        let tWeek = "(" + weekList[array[index].treatWeek] + ")";
        array[index].viewTreatDate = tDate + tWeek;

        // 登録されていない場合は条件送信前扱い
        if (
          array[index].rstDialysisState === "" ||
          array[index].rstDialysisState === null
        ) {
          array[index].rstDialysisState = "0";
        }

        // 指示：投与薬剤情報を取得
        if (array[index].indMediInfo !== null) {
          array[index].indMediInfo = JSON.parse(array[index].indMediInfo);
        }
        // 実績：投与薬剤情報を取得
        if (array[index].rstMediInfo !== null) {
          array[index].rstMediInfo = JSON.parse(array[index].rstMediInfo);
        }

        // 条件送信前の場合「指示：投与薬剤情報」
        // 条件送信後の場合「実績：投与薬剤情報」
        array[index].mediInfo =
          array[index].rstDialysisState === "0" ?
          array[index].indMediInfo :
          array[index].rstMediInfo;

        // 投与薬剤項目数
        let mediChkCount = 0;
        // 投与薬剤実施済み項目数
        let mediOnChkCount = 0;

        if (array[index].mediInfo !== null) {
          // 投与薬剤項目数セット
          mediChkCount = array[index].mediInfo.length;
          // 投与薬剤実施済み項目数セット
          mediOnChkCount = array[index].mediInfo.filter(item => item.effect_flg == 1).length;
        }

        array[index].medi_count = mediChkCount;
        array[index].medi_chkcount = mediOnChkCount;
        array[index].medicine = mediOnChkCount + "/" + mediChkCount;
      });

      // 取得したord_main情報をセット
      commit("setIsDataLoadCancel", false);
      commit("setOrdMainList", { ordMainList: dataList });

      // チェックリスト実績を取得
      dispatch("getOrderCheckListByOrdNo");
    },

    /**
     * 治療日指定
     * ord_main情報を取得
     * facilityCd: 施設コード
     */
    async getOrderMainListShiteibi({ commit, dispatch }, parm) {
      // ord_main情報取得
      const response = await sendRequestGetOrdMainShiteibi(parm);

      // 取得データの変換
      const dataList = response.data.copyWithin(0, 0);
      dataList.forEach(async (value, index, array) => {
        // 治療日を作成
        let tDate =
          array[index].treatDate.substr(4, 2) +
          "/" +
          array[index].treatDate.substr(6, 2);
        let weekList = ["", "月", "火", "水", "木", "金", "土", "日"];
        let tWeek = "(" + weekList[array[index].treatWeek] + ")";
        array[index].viewTreatDate = tDate + tWeek;

        // 登録されていない場合は条件送信前扱い
        if (
          array[index].rstDialysisState === "" ||
          array[index].rstDialysisState === null
        ) {
          array[index].rstDialysisState = "0";
        }

        // 指示：投与薬剤情報を取得
        if (array[index].indMediInfo !== null) {
          array[index].indMediInfo = JSON.parse(array[index].indMediInfo);
        }
        // 実績：投与薬剤情報を取得
        if (array[index].rstMediInfo !== null) {
          array[index].rstMediInfo = JSON.parse(array[index].rstMediInfo);
        }

        // 条件送信前の場合「指示：投与薬剤情報」
        // 条件送信後の場合「実績：投与薬剤情報」
        array[index].mediInfo =
          array[index].rstDialysisState === "0" ?
          array[index].indMediInfo :
          array[index].rstMediInfo;

        // 投与薬剤項目数
        let mediChkCount = 0;
        // 投与薬剤実施済み項目数
        let mediOnChkCount = 0;

        if (array[index].mediInfo !== null) {
          // 投与薬剤項目数セット
          mediChkCount = array[index].mediInfo.length;
          // 投与薬剤実施済み項目数セット
          mediOnChkCount = array[index].mediInfo.filter(item => item.effect_flg == 1).length;
        }

        array[index].medi_count = mediChkCount;
        array[index].medi_chkcount = mediOnChkCount;
        array[index].medicine = mediOnChkCount + "/" + mediChkCount;
      });

      // 取得したord_main情報をセット
      commit("setIsDataLoadCancel", false);
      commit("setOrdMainList", { ordMainList: dataList });

      // チェックリスト実績を取得
      dispatch("getOrderCheckListByOrdNo");
    },
    /**
     * 指定のタブ定義コードの設定項目情報を取得
     * @param {*} commit commitオブジェクト
     * @param {*} params タブ定義コード
     */
    getRequestGetOrdCheckListAll({ commit }, {params, autoRefreshFlag}) {
      return sendRequestGetOrdCheckListAll(params, autoRefreshFlag);
    },
    getRequestGetOrdMainChiryouchuu({ commit }, params) {
      return sendRequestGetOrdMainChiryouchuu(params);
    },
    getRequestGetOrdMainShiteibi({ commit }, params) {
      return sendRequestGetOrdMainShiteibi(params);
    },
    /**
     * チェックリスト実績情報を取得
     */
    async getOrderCheckListByOrdNo({ state, commit }, autoRefreshFlag) {
      let listChecklistResponse = [];
      let listChgRecord = [];
      let list = state.ordMainList;
      // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
      state.isAsynComplete = false;
      // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end

      if (state.isDataLoadCancel) {
        // ページ切り替えなどでデータ読み込みの中断があった
        commit("setIsDataLoadCancel", false);
      } else {
        listChgRecord = listChgRecord.concat(list);
        let params = list.map(item=>{
          return {
            ordNo: item.ordNo,
            rstDialysisState: item.rstDialysisState
          }
        })
        // console.log(params);
        await sendRequestGetOrdCheckListAll(params).then(checklistResponse=>{
          listChecklistResponse = listChecklistResponse.concat(checklistResponse.data);
        });
      }

      // console.log(listChecklistResponse);

      listChecklistResponse.forEach((checklistResponse, index) => {
        const chgRecord = listChgRecord[index];
        let ordChecklist = checklistResponse;


        // チェックリスト
        let checkSettings = state.checklistSetting.checklistSettings;
        for (let checkSetting of checkSettings) {
          // チェック表示項目数
          let checkString = "checklist_" + checkSetting.list_cd.toString();
          // チェック済み項目数
          let checkStringChecked = checkString + "_chkcount";
          chgRecord[checkStringChecked] = ordChecklist[checkSetting.list_cd][0];
          // チェック項目数
          let checkStringTotal = checkString + "_count";
          chgRecord[checkStringTotal] = ordChecklist[checkSetting.list_cd][1];

          chgRecord[checkString] =
            ordChecklist[checkSetting.list_cd][0] +
            "/" +
            ordChecklist[checkSetting.list_cd][1];
        }

        // 実績にチェックリストコードが登録されている場合
        // mod FNSI-４００エラー対応 周 start
        // if (ordChecklist[0][0] !== null) {
        //   // チェックリストコード
        //   chgRecord.checklistCd = ordChecklist[0][0];
        // }
        chgRecord.checklistCd = ordChecklist[0][0] === null ? 0 : ordChecklist[0][0];
        // mod FNSI-４００エラー対応 周 end

        if (state.isDataLoadCancel) {
          // ページ切り替えなどでデータ読み込みの中断があった
          return;
        }

        // データ更新
        list.splice(index, 1, chgRecord);

        // 取得したord_main情報をセット
        commit("setOrdMainList", { ordMainList: list });
      });
      // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
      state.isAsynComplete = true;
      // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end
    },
    // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end

    /**
     * 治療中
     * ord_main情報取得
     * facilityCd: 施設コード
     * nextPat: 次患者[0:次クール, 1:当日, 2:次クール以降]
     */
    async getOrderMainListTreatment({ state, commit, dispatch }, parm) {
      // ord_main情報取得
      const response = await sendRequestGetOrdMainTreatment(parm);

      // 取得データの変換
      const dataList = response.data.copyWithin(0, 0);
      dataList.forEach(async (value, index, array) => {
        // 治療日
        let tDate =
          array[index].treatDate.substr(4, 2) +
          "/" +
          array[index].treatDate.substr(6, 2);
        let weekList = ["", "月", "火", "水", "木", "金", "土", "日"];
        let tWeek = "(" + weekList[array[index].treatWeek] + ")";
        array[index].viewTreatDate = tDate + tWeek;

        // チェックリストコード
        array[index].checklistCd = state.checklistSetting.checklistCd;

        // 指示：投与薬剤情報
        if (array[index].indMediInfo !== null) {
          array[index].indMediInfo = JSON.parse(array[index].indMediInfo);
        }
        // 指示：治療条件情報
        if (array[index].indCondInfo !== null) {
          array[index].indCondInfo = JSON.parse(array[index].indCondInfo);
        }
        // 指示：医療材料情報
        if (array[index].indEquipInfo !== null) {
          array[index].indEquipInfo = JSON.parse(array[index].indEquipInfo);
        }

        // 実績：投与薬剤情報
        if (array[index].rstMediInfo !== null) {
          array[index].rstMediInfo = JSON.parse(array[index].rstMediInfo);
        }
        // 実績：治療条件情報
        if (array[index].rstCondInfo !== null) {
          array[index].rstCondInfo = JSON.parse(array[index].rstCondInfo);
        }
        // 実績：医療材料情報
        if (array[index].rstEquipInfo !== null) {
          array[index].rstEquipInfo = JSON.parse(array[index].rstEquipInfo);
        }

        // 投与薬剤項目数
        let mediChkCount = 0;
        // 投与薬剤実施済み項目数
        let mediOnChkCount = 0;

        // 登録されていない場合は条件送信前扱い
        if (
          array[index].rstDialysisState === "" ||
          array[index].rstDialysisState === null
        ) {
          array[index].rstDialysisState = "0";
        }

        if (array[index].rstDialysisState === "0") {
          // 条件送信前の場合
          array[index].mediInfo = array[index].indMediInfo;
          array[index].condInfo = array[index].indCondInfo;
          array[index].equipInfo = array[index].indEquipInfo;

          // 医療材料指示の医療材料情報取得
          let indEquipCodeList = [];
          let indEquipList = [];
          array[index].equipInfo.forEach((val, eIdx, eArray) => {
            indEquipCodeList.push(eArray[eIdx].cd);
          });

          // 医療材料がある場合
          if (indEquipCodeList.length > 0) {
            // 医療材料リスト重複削除
            indEquipCodeList = indEquipCodeList.filter(function(x, i, self) {
              return self.indexOf(x) === i;
            });
            // 医療材料情報取得
            const equipResponse = await sendRequestGetMstEquipList({
              list: indEquipCodeList
            });
            indEquipList = equipResponse.data;

            array[index].equipInfo.forEach((val, idx, ary) => {
              for (const indEquip of indEquipList) {
                if (ary[idx].cd == indEquip.equipmentCd) {
                  ary[idx].class_cd = indEquip.classCd;
                }
              }
            });
          }
        } else {
          // 条件送信後の場合
          array[index].mediInfo = array[index].rstMediInfo;
          array[index].condInfo = array[index].rstCondInfo;
          array[index].equipInfo = array[index].rstEquipInfo;

          // 投与薬剤実績がある場合
          if (array[index].mediInfo !== null) {
            // 投与薬剤実施済み項目数カウント
            array[index].mediInfo.forEach((value, idx, ary) => {
              // 実施済みの場合
              if (ary[idx].effect_flg == 1) {
                mediOnChkCount++;
              }
            });
          }
        }

        // 投与薬剤
        // 投与薬剤項目数セット
        // 投与薬剤実績がある場合
        if (array[index].mediInfo !== null) {
          mediChkCount = array[index].mediInfo.length;
        }
        array[index].medi_count = mediChkCount;

        // 投与薬剤実施済み項目数セット
        array[index].medi_chkcount = mediOnChkCount;

        // 投与薬剤実施済み項目数/投与薬剤項目数セット
        array[index].medicine = mediOnChkCount + "/" + mediChkCount;

        // チェックリスト
        let checkSettings = state.checklistSetting.checklistSettings;
        for (let checkSetting of checkSettings) {
          const funcList = checkSetting.funclist;
          // チェックリスト項目数カウント
          let chkCount = 0;
          for (const funcItem of funcList) {
            if (funcItem.func_class === 0) {
              // 通常リストの場合
              chkCount++;
            } else if (funcItem.func_class === 1) {
              // 治療条件の場合
              let cond_class_cd = [funcItem.class_cd];
              // ダイアライザの場合
              if (funcItem.class_cd === 5) {
                // 吸着カラムも追加
                cond_class_cd.push(6);
                // 一次膜・二次膜
                cond_class_cd.push(7);
                cond_class_cd.push(8);
              }
              // 吸着カラムはダイアライザと同時設定にしたので除外
              if (funcItem.class_cd === 6) {
                continue;
              }
              // 穿刺針の場合
              if (funcItem.class_cd === 9) {
                cond_class_cd.push(10);
                cond_class_cd.push(11);
              }
              let count = checkCondInfo(array[index].condInfo, cond_class_cd);
              chkCount += count;
            } else if (funcItem.func_class === 2) {
              // 医療材料の場合

              let count = 0;
              // ダイアライザの場合
              if (funcItem.class_cd === 0) {
                count = checkEquipDialyzerInfo(array[index].equipInfo);
              } else {
                // 医療材料の場合
                count = checkEquipInfo(
                  array[index].equipInfo,
                  funcItem.class_cd
                );
              }
              chkCount += count;
            }
          }
          // チェック項目数セット
          let listCdString =
            "checklist_" + checkSetting.list_cd.toString() + "_count";
          array[index][listCdString] = chkCount;

          // チェック済み項目数セット
          listCdString =
            "checklist_" + checkSetting.list_cd.toString() + "_chkcount";
          array[index][listCdString] = 0;

          // チェック項目数セット
          listCdString = "checklist_" + checkSetting.list_cd.toString();
          array[index][listCdString] = 0 + "/" + chkCount;
        }
      });

      // 取得したord_main情報をセット
      commit("setIsDataLoadCancel", false);
      commit("setOrdMainList", { ordMainList: dataList });

      // チェックリスト実績取得
      dispatch("getOrderCheckByOrdNo");
    },

    /**
     * 治療日指定
     * ord_main情報取得
     * facilityCd: 施設コード
     */
    async getOrderMainListByTreatDate({ state, commit, dispatch }, parm) {
      // ord_main情報取得
      const response = await sendRequestGetOrdMainByTreatDate(parm);

      // 取得データの変換
      const dataList = response.data.copyWithin(0, 0);
      dataList.forEach(async (value, index, array) => {
        // 治療日
        let tDate =
          array[index].treatDate.substr(4, 2) +
          "/" +
          array[index].treatDate.substr(6, 2);
        let weekList = ["", "月", "火", "水", "木", "金", "土", "日"];
        let tWeek = "(" + weekList[array[index].treatWeek] + ")";
        array[index].viewTreatDate = tDate + tWeek;

        // チェックリストコード
        array[index].checklistCd = state.checklistSetting.checklistCd;

        // 指示：投与薬剤情報
        if (array[index].indMediInfo !== null) {
          array[index].indMediInfo = JSON.parse(array[index].indMediInfo);
        }
        // 指示：治療条件情報
        if (array[index].indCondInfo !== null) {
          array[index].indCondInfo = JSON.parse(array[index].indCondInfo);
        }
        // 指示：医療材料情報
        if (array[index].indEquipInfo !== null) {
          array[index].indEquipInfo = JSON.parse(array[index].indEquipInfo);
        }

        // 実績：投与薬剤情報
        if (array[index].rstMediInfo !== null) {
          array[index].rstMediInfo = JSON.parse(array[index].rstMediInfo);
        }
        // 実績：治療条件情報
        if (array[index].rstCondInfo !== null) {
          array[index].rstCondInfo = JSON.parse(array[index].rstCondInfo);
        }
        // 実績：医療材料情報
        if (array[index].rstEquipInfo !== null) {
          array[index].rstEquipInfo = JSON.parse(array[index].rstEquipInfo);
        }

        // 投与薬剤項目数
        let mediChkCount = 0;
        // 投与薬剤実施済み項目数
        let mediOnChkCount = 0;

        // 登録されていない場合は条件送信前扱い
        if (
          array[index].rstDialysisState === "" ||
          array[index].rstDialysisState === null
        ) {
          array[index].rstDialysisState = "0";
        }
        if (array[index].rstDialysisState === "0") {
          // 条件送信前の場合
          array[index].mediInfo = array[index].indMediInfo;
          array[index].condInfo = array[index].indCondInfo;
          array[index].equipInfo = array[index].indEquipInfo;

          // 医療材料指示の医療材料情報取得
          let indEquipCodeList = [];
          let indEquipList = [];
          if (array[index].equipInfo) {
            array[index].equipInfo.forEach((val, eIdx, eArray) => {
              indEquipCodeList.push(eArray[eIdx].cd);
            });
          }

          // 医療材料がある場合
          if (indEquipCodeList.length > 0) {
            // 医療材料リスト重複削除
            indEquipCodeList = indEquipCodeList.filter(function(x, i, self) {
              return self.indexOf(x) === i;
            });
            // 医療材料情報取得
            const equipResponse = await sendRequestGetMstEquipList({
              list: indEquipCodeList
            });
            indEquipList = equipResponse.data;

            array[index].equipInfo.forEach((val, idx, ary) => {
              for (const indEquip of indEquipList) {
                if (ary[idx].cd == indEquip.equipmentCd) {
                  ary[idx].class_cd = indEquip.classCd;
                }
              }
            });
          }
        } else {
          // 条件送信後の場合
          array[index].mediInfo = array[index].rstMediInfo;
          array[index].condInfo = array[index].rstCondInfo;
          array[index].equipInfo = array[index].rstEquipInfo;

          // 投与薬剤// 投与薬剤実績がある場合
          if (array[index].mediInfo !== null) {
            // 投与薬剤実施済み項目数カウント
            array[index].mediInfo.forEach((value, idx, ary) => {
              // 実施済みの場合
              if (ary[idx].effect_flg == 1) {
                mediOnChkCount++;
              }
            });
          }
        }

        // 投与薬剤
        // 投与薬剤項目数セット// 投与薬剤実績がある場合
        if (array[index].mediInfo !== null) {
          mediChkCount = array[index].mediInfo.length;
        }
        array[index].medi_count = mediChkCount;

        // 投与薬剤実施済み項目数セット
        array[index].medi_chkcount = mediOnChkCount;

        // 投与薬剤実施済み項目数/投与薬剤項目数セット
        array[index].medicine = mediOnChkCount + "/" + mediChkCount;

        // チェックリスト
        // 条件送信前
        if (array[index].rstDialysisState === "0") {
          let checkSettings = state.checklistSetting.checklistSettings;
          for (let checkSetting of checkSettings) {
            const funcList = checkSetting.funclist;
            // チェックリスト項目数カウント
            let chkCount = 0;
            for (const funcItem of funcList) {
              if (funcItem.func_class === 0) {
                // 通常リストの場合
                chkCount++;
              } else if (funcItem.func_class === 1) {
                // 治療条件の場合
                let cond_class_cd = [funcItem.class_cd];
                // ダイアライザの場合
                if (funcItem.class_cd === 5) {
                  // 吸着カラムも追加
                  cond_class_cd.push(6);
                  // 一次膜・二次膜
                  cond_class_cd.push(7);
                  cond_class_cd.push(8);
                }
                // 吸着カラムはダイアライザと同時設定にしたので除外
                if (funcItem.class_cd === 6) {
                  continue;
                }
                // 穿刺針の場合
                if (funcItem.class_cd === 9) {
                  cond_class_cd.push(10);
                  cond_class_cd.push(11);
                }
                let count = checkCondInfo(array[index].condInfo, cond_class_cd);
                chkCount += count;
              } else if (funcItem.func_class === 2) {
                // 医療材料の場合
                let count = 0;
                // ダイアライザの場合
                if (funcItem.class_cd === 0) {
                  count = checkEquipDialyzerInfo(array[index].equipInfo);
                } else {
                  // 医療材料の場合
                  count = checkEquipInfo(
                    array[index].equipInfo,
                    funcItem.class_cd
                  );
                }
                chkCount += count;
              }
            }
            // チェック項目数セット
            let listCdString =
              "checklist_" + checkSetting.list_cd.toString() + "_count";
            array[index][listCdString] = chkCount;

            // チェック済み項目数セット
            listCdString =
              "checklist_" + checkSetting.list_cd.toString() + "_chkcount";
            array[index][listCdString] = 0;

            // チェック項目数セット
            listCdString = "checklist_" + checkSetting.list_cd.toString();
            array[index][listCdString] = 0 + "/" + chkCount;
          }
        }
      });

      // 取得したord_main情報をセット
      commit("setIsDataLoadCancel", false);
      commit("setOrdMainList", { ordMainList: dataList });

      // チェックリスト実績取得
      dispatch("getOrderCheckByOrdNo");
    },

    /**
     * チェックリスト実績情報取得
     */
    async getOrderCheckByOrdNo({ state, commit }) {
      const listChecklistResponse = [];
      const listChgRecord = [];
      let list = state.ordMainList;

      for (let i = 0; i < list.length; i++) {
        if (state.isDataLoadCancel) {
          // ページ切り替えなどでデータ読み込みの中断があった
          commit("setIsDataLoadCancel", false);
          break;
        }
        listChgRecord.push(list[i]);
        // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
        // await sendRequestGetOrdCheckListByOrdNo({
        //   ordNo: list[i].ordNo
        // }).then(checklistResponse => {
        //   listChecklistResponse.push(checklistResponse);
        // });

        // 治療情報テーブル「実績：治療状況（rst_dialysis_state） = 0：条件送信前」
        if (list[i].rstDialysisState === "0") {
          // ●全項目数          ：指示情報とチェックリストマスト情報を取得
          // ●チェック済み項目数 ：チェックリスト実績情報を取得
          await sendRequestGetOrdCheckListZen({
            ordNo: list[i].ordNo
          }).then(checklistResponse => {
            listChecklistResponse.push(checklistResponse);
          });
        } else {
          // チェックリスト実績進度情報を取得「ダミーデータは含まれない」
          await sendRequestGetOrdCheckListIcou({
            ordNo: list[i].ordNo
          }).then(checklistResponse => {
            listChecklistResponse.push(checklistResponse);
          });
        }
        // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
      }
      listChecklistResponse.forEach((checklistResponse, index) => {
        const chgRecord = listChgRecord[index];
        let ordChecklist = checklistResponse.data;

        // チェックリスト
        let checkSettings = state.checklistSetting.checklistSettings;
        for (let checkSetting of checkSettings) {
          // チェック済み項目数セット
          let listCdString =
            "checklist_" + checkSetting.list_cd.toString() + "_chkcount";
          chgRecord[listCdString] = ordChecklist[checkSetting.list_cd][0];

          // チェック項目数セット
          listCdString = "checklist_" + checkSetting.list_cd.toString();
          let listCdStringCount =
            "checklist_" + checkSetting.list_cd.toString() + "_count";

          // 条件送信前
          let allCount = chgRecord[listCdStringCount];
          if (chgRecord.rstDialysisState !== "0") {
            // 条件送信後
            allCount = ordChecklist[checkSetting.list_cd][1];
            chgRecord[listCdStringCount] = allCount;
          }

          chgRecord[listCdString] =
            ordChecklist[checkSetting.list_cd][0] + "/" + allCount;
        }

        // 実績にチェックリストコードが登録されている場合
        if (ordChecklist[0][0] !== null) {
          // チェックリストコード
          chgRecord.checklistCd = ordChecklist[0][0];
        }

        if (state.isDataLoadCancel) {
          // ページ切り替えなどでデータ読み込みの中断があった
          return;
        }

        // データ更新
        list.splice(index, 1, chgRecord);

        // 取得したord_main情報をセット
        commit("setOrdMainList", { ordMainList: list });
      });
    },

    // 表示切替フラグ変更
    changeIsDisplayTreatingMode({ commit }, flg) {
      commit("changeIsDisplayTreatingMode", flg);
    },
    /**
     * リストコードに一致するリスト名を返す
     * @param {*} code リストコード
     */
    getChecklistName({ state }, code) {
      const setting = state.checklistSetting;
      let listName = "";
      for (const item of setting.checklistSettings) {
        if (item.list_cd == code) {
          listName = item.list_name;
        }
      }
      return listName;
    },
    setIsDataLoadCancel({ commit }, val) {
      commit("setIsDataLoadCancel", val);
    },
    setIsAsynComplete({ commit }, val) {
      commit("setIsAsynComplete", val);
    },
    setIsDataLoading({ commit }, val) {
      commit("setIsDataLoading", val);
    },
    fetchReloadInterval(autoRefreshFlag) {
      return sendRequestGetReloadInterval(autoRefreshFlag);
    },
    setReloadInterval({ commit }, val) {
      commit("setReloadInterval", val);
    },
    // -----------------------------------------
    // 強制サインアウトフラグ設定
    // -----------------------------------------
    setForceSignOutFlag({ commit }, forceSignOutFlag) {
      commit("setForceSignOutFlag", forceSignOutFlag);
    },
  },
  mutations: {
    // 更新間隔
    setReloadInterval(state, val) {
      state.reloadInterval = val;
    },
    // 抽出条件
    setCondition(state, condition) {
      state.condition = condition;
    },
    // チェックリストグリッド列
    setChecklistColumn(state, column) {
      state.checklistColumn = column;
    },
    setChecklistColumnHeader(state, column) {
      state.checklistColumnHeader = column;
    },
    setKurSelector(state, payload) {
      state.mstKurSelector = payload.mstKurSelector;
    },
    // add FNSI-redmine_#3908_ソート方法の改善 周 start
    // 固定列（ベッド名）
    setChecklistColumnHeaderWidth(state, parm) {
      state.checklistColumnHeader[0].width[parm.selectedFontSize] = parm.width;
    },
    // スクロール列
    setChecklistColumnWidth(state, parm) {
      for (let index = 0; index < state.checklistColumn.length; index++) {
        if (state.checklistColumn[index].field === parm.field) {
          state.checklistColumn[index].width[parm.selectedFontSize] = parm.width;
        }
      }
    },
    // add FNSI-redmine_#3908_ソート方法の改善 周 end
    setBedGroupList(state, payload) {
      state.mstBedGroupList = payload.mstBedGroupList;
    },
    // チェックリスト設定
    setChecklistSetting(state, data) {
      state.checklistSetting = data;
    },
    // ord_main
    setOrdMainList(state, payload) {
      state.ordMainList = payload.ordMainList;
    },
    setIsAsynComplete(state, payload) {
      state.isAsynComplete = payload.isAsynComplete;
    },
    // 表示切替フラグ変更
    changeIsDisplayTreatingMode(state, isDisplayTreatingMode) {
      state.isDisplayTreatingMode = isDisplayTreatingMode;
    },
    /**
     * クール詳細リストをセット
     * @param {*} state
     * @param {*} mstKurList
     */
    setMstKurList(state, mstKurList) {
      let kurList = mstKurList.map(dat => {
        return {
          kurName: dat.kurName,
          kurCd: dat.kurCd,
          kurStartTime: dat.kurStartTime,
          kurEndTime: dat.kurEndTime,
          kurStandardStartTime: dat.kurStandardStartTime
        };
      });

      // クール開始時刻でソート
      kurList.sort(function(a, b) {
        return a.kurStartTime < b.kurStartTime
          ? -1
          : a.kurStartTime === b.kurStartTime
          ? 0
          : 1;
      });
      state.mstKurList = kurList;
    },
    setIsDataLoadCancel: (state, val) => {
      state.isDataLoadCancel = val;
      if (val) {
        state.ordMainList = [];
      }
    },
    setIsDataLoading: (state, val) => {
      state.isDataLoading = val;
    },
    setForceSignOutFlag(state, forceSignOutFlag) {
      state.forceSignOutFlag = forceSignOutFlag;
    },
  }
};

/********** function **********/
function getCurrentDate() {
  return moment(new Date()).format("YYYYMMDD");
}
function getCurrentTime() {
  return moment(new Date()).format("HHmmss");
}
/**
 * 現在クール
 */
function getCurrentKur(kurList) {
  return kurList.find(
    dat =>
      dat.kurStartTime <= getCurrentTime() && dat.kurEndTime >= getCurrentTime()
  );
}
/**
 * 指定クールの開始時刻を取得
 */
function getKurStartTime(kurList, kurCd) {
  let ret = "000000";
  if (kurCd != null) {
    const kur = kurList.find(dat => dat.kurCd.toString() === kurCd.toString());
    if (kur !== undefined) {
      ret = kur.kurStartTime;
    }
  }
  return ret;
}
/**
 *  現クール開始日付時刻を取得
 */
function getCurrentKurStartDateTime(kurList) {
  let ret = getCurrentDate();
  // 現在クール取得
  const kur = getCurrentKur(kurList);
  if (kur !== undefined) {
    ret += kur.kurStartTime;
  }
  return ret;
}
/**
 *  次クール開始日付時刻を取得
 */
function getNextKurStartDateTime(kurList) {
  let ret = "";
  // 現在日付取得
  const now = new Date();
  let checkDate = moment(now).format("YYYYMMDD");

  // 現クール開始時刻を取得
  const currentKurStartDateTime = getCurrentKurStartDateTime(kurList);

  // クール情報リスト
  let lop = 0;
  for (; lop < kurList.length; lop++) {
    // 対象クールの開始日付時刻を作成
    let checkDateTime =
      checkDate + getKurStartTime(kurList, kurList[lop].kurCd);

    // 現クール開始時刻と比較
    if (currentKurStartDateTime < checkDateTime) {
      // 現クール開始時刻より大きい
      ret = checkDateTime;
      break;
    }
  }

  // 最後クール判定
  if (lop !== 0 && lop === kurList.length) {
    // 翌日判定
    now.setDate(now.getDate() + 1);
    ret =
      moment(now).format("YYYYMMDD") +
      getKurStartTime(kurList, kurList[0].kurCd);
  }

  return ret;
}

// 治療条件項目
function checkCondInfo(condList, codeList) {
  let rCnt = 0;
  // 治療条件
  for (let code of codeList) {
    // 指示・実績がある場合
    if (condList !== null && code !== null) {
      if (condList[code] && condList[code].value !== null) {
        rCnt++;
      }
    }
  }
  return rCnt;
}

// 医療材料項目
function checkEquipInfo(list, code) {
  let rCnt = 0;
  // 指示・実績がある場合
  if (list !== null && code !== null) {
    for (let item of list) {
      if (item.class_cd === code) {
        rCnt++;
      }
    }
  }
  return rCnt;
}

// 医療材料のダイアライザ項目
function checkEquipDialyzerInfo(list) {
  let rCnt = 0;
  // 指示・実績がある場合
  if (list !== null) {
    for (let item of list) {
      if (item.equip_type === 1) {
        rCnt++;
      }
    }
  }
  return rCnt;
}
