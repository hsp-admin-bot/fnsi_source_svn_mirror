/**
 * チェックリストモーダル用ストア
 */
import {
  sendRequestGetMstChecklistByChecklistCd,
  sendRequestGetMstPersonalUser,
  sendRequestGetOrdMainByOrdNo,
  sendRequestGetMstDialyzerList,
  sendRequestGetMstMedicineList,
  sendRequestGetMstMedicineMixList,
  sendRequestGetMstEquipList,
  // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
  sendRequestGetOrdCheckListZen,
  sendRequestGetOrdCheckListIcou,
  // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
  sendRequestGetOrdCheckListByListCd,
  sendRequestUpdateOrdChecklist
} from "@/apis/check-list";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { dateFormat } from "@/functions/common/DateTimeUtils";
import dayjs from "@/compat/date/dayjs";
import BigNumber from "@/compat/number/bignumber";

// 穿刺針種類(治療条件)
const needleType_cond = {
  9: { type: 1, name: "A針" },
  10: { type: 2, name: "V針" },
  11: { type: 3, name: "SN" }
};

// 穿刺針種類(医療材料)
const needleType_equip = ["未指定", "A針", "V針", "SN"];

export default {
  strict: true,
  namespaced: true,
  state: {
    // 実施者選択用スタッフ一覧
    cmbStaffList: null,
    // スタッフ一覧情報
    staffList: null,
    // 選択中のord_no（ord_main）
    selectOrdNo: null,
    // 選択中のlist_cd（mst_checklist）
    selectListCd: null,
    // 選択中のchecklist_cd（mst_checklist）
    selectChecklistCd: null,
    // 選択中のチェックリスト設定（mst_checklist）
    selectChecklistSetting: null,
    // チェックリストマスタ設定情報
    checklistSetting: null,
    // 選択中のord_main（スケジュール）
    selectOrdMain: null,
    // 選択中のchecklist(編集前)
    old_selectChecklist: null,
    // 選択中のchecklist
    selectChecklist: null,
    // ログインユーザー情報
    userAccountInfo: null
  },
  getters: {
    getSelectChecklistSetting(state) {
      return state.selectChecklistSetting;
    },
    getChecklistSetting(state) {
      return state.checklistSetting;
    },
    getSelectOrdMain(state) {
      return state.selectOrdMain;
    },
    getSelectChecklist(state) {
      return state.selectChecklist;
    },
    getCmbStaffList(state) {
      return state.cmbStaffList;
    }
  },
  actions: {
    /**
     * スタッフ情報取得
     * facilityCd: 施設コード
     */
    async getMstPersonalUser({ commit }, facilityCd) {
      // スタッフ一覧情報取得
      const response = await sendRequestGetMstPersonalUser(facilityCd);

      // 取得データ
      const data = response.data;
      let list = [];

      list.push({ text: " ", value: -1 });
      data.forEach((value, index, array) => {
        list.push({ text: array[index].userName, value: array[index].userId });
      });

      // グリッドコンボボックス用スタッフ情報をセット
      commit("setCmbStaffList", { cmbStaffList: list });
      // 取得したスタッフ情報をセット
      commit("setStaffList", { staffList: data });
    },
    /**
     * 指定チェックリストコードのチェックリストマスタ設定情報取得
     */
    async getCheckListSetting({ state, commit }) {
      try {
        // add FNSI-４００エラー対応 周 start
        // チェックリストコード存在しない場合
        if (!state.selectChecklistCd) {
          // add 10962 サインイン直後にチェックリスト画面で0/0のチェック項目を表示しようとすると処理中のままになる 関  start
          commit("setSelectChecklistSetting", null);
          // add 10962 サインイン直後にチェックリスト画面で0/0のチェック項目を表示しようとすると処理中のままになる 関  end
          return;
        }
        // add FNSI-４００エラー対応 周 end
        // 施設コードを指定してチェックリストマスタ設定情報を取得
        const response = await sendRequestGetMstChecklistByChecklistCd(
          state.selectChecklistCd
        );
        const checkSetting = response.data;
        // JSONデータ変換
        // チェックリストマスタ項目
        checkSetting.checklistSettings = JSON.parse(
          checkSetting.checklistSettings
        );

        // 取得した設定内容を保存
        commit("setChecklistSetting", checkSetting);

        // 選択中のリストコードのチェックリスト設定を保存
        let selectSetting = null;
        for (const setting of checkSetting.checklistSettings) {
          if (setting.list_cd === state.selectListCd) {
            selectSetting = setting;
          }
        }
        commit("setSelectChecklistSetting", selectSetting);
      } catch (e) {
        alert(e.message);
      }
    },

    // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
    /**
     * ord_no指定
     * チェックリスト情報を作成
     */
    async getChecklistInfoByOrdNo({ state, commit }) {
      // 治療情報を取得
      const response = await sendRequestGetOrdMainByOrdNo(state.selectOrdNo);
      // 取得データの変換
      const data = response.data;
      // チェックリスト実績情報
      let checkListSource = [];
      // チェックリストモーダル表示用情報
      let checkList = [];

      // 登録されていない場合は条件送信前扱い
      if (
        data.rstDialysisState === "" ||
        data.rstDialysisState === null ||
        data.rstDialysisState === "null"
      ) {
        data.rstDialysisState = "0";
      }

      // チェックリスト情報を取得
      if (data.rstDialysisState === "0") {
        // 条件送信前の場合
        const response = await sendRequestGetOrdCheckListZen({
          ordNo: state.selectOrdNo,
          // 一覧情報を取得「リストコード：0以外」
          listCd: state.selectListCd
        });
        checkListSource = response.data;
      } else {
        // 条件送信以降の場合
        const response = await sendRequestGetOrdCheckListIcou({
          ordNo: state.selectOrdNo,
          // 一覧情報を取得「リストコード：0以外」
          listCd: state.selectListCd
        });
        checkListSource = response.data;
      }
      // チェックリストモーダル表示用情報作成
      // FNSI-チェックリスト画面表示を修正 周 mod start
      // checkListSource
      //   // 表示順「チェックリスト管理番号」
      //   .sort(function(a, b) {
      //     if (a.ord_checklist.rstChecklistInfo.class_cd == b.ord_checklist.rstChecklistInfo.class_cd) {
      //       return a.ord_checklist.rstChecklistInfo.code - b.ord_checklist.rstChecklistInfo.code;
      //     } else {
      //       return a.ord_checklist.rstChecklistInfo.class_cd - b.ord_checklist.rstChecklistInfo.class_cd;
      //     }
      //   })
      //   .forEach((item, index) => {

      //   // 表示用発生日時を作成「一覧」
      //   let vTime = null;
      //   if (item.ord_checklist.occurDate != null) {
      //     const occurDate = dayjs(item.ord_checklist.occurDate);
      //     vTime = occurDate.format("HH:mm");
      //   }

      //   checkList.push({
      //     rowno: index,
      //     ctlNo: item.ord_checklist.checklistCtlNo,
      //     check: item.ord_checklist.isCheck === "1",
      //     func_class: item.ord_checklist.funcClass,
      //     time: item.ord_checklist.occurDate,
      //     // 発生日時
      //     viewtime: vTime,
      //     // 種別
      //     kind: "",

      //     // 薬剤区分
      //     medicine_type: item.ord_checklist.rstChecklistInfo.medicine_type,
      //     // ダイアライザフラグ
      //     dialyzer_flg: (item.ord_checklist.rstChecklistInfo.medicine_type === null && item.ord_checklist.rstChecklistInfo.class_cd === "5"),
      //     // 医療材料フラグ
      //     equip_flg: (item.ord_checklist.rstChecklistInfo.medicine_type === null && item.ord_checklist.rstChecklistInfo.class_cd !== "5"),
      //     // 通常薬剤フラグ
      //     medi_flg: (item.ord_checklist.rstChecklistInfo.medicine_type === "1"),
      //     // 調製薬剤フラグ
      //     is_medicine_mix: (item.ord_checklist.rstChecklistInfo.medicine_type === "2"),
      //     item_number: item.ord_checklist.rstChecklistInfo.item_number,
      //     class_cd: item.ord_checklist.rstChecklistInfo.class_cd,
      //     code: item.ord_checklist.rstChecklistInfo.code,
      //     code_update: item.ord_checklist.rstChecklistInfo.code_update,
      //     name: item.ord_checklist.rstChecklistInfo.name,
      //     // 穿刺針区分(null: 対象外、0: 未指定、1: A針、2: V針、3: SN)
      //     needle_type: item.ord_checklist.rstChecklistInfo.needle_type,
      //     // 数量
      //     amount: item.ord_checklist.rstChecklistInfo.amount ? item.ord_checklist.rstChecklistInfo.amount : 0,
      //     // 単位
      //     unit: (item.ord_checklist.rstChecklistInfo.unit && item.ord_checklist.rstChecklistInfo.unit !== "null") ?
      //       item.ord_checklist.rstChecklistInfo.unit :
      //       "",

      //     chg_flg: false,
      //     chgflg_time: false,
      //     chgflg_user_id: false,

      //     user_id: item.ord_checklist.regStaffInfo.reg_staff_cd ? item.ord_checklist.regStaffInfo.reg_staff_cd : -1,
      //     user_update: item.ord_checklist.regStaffInfo.reg_staff_update,
      //     user_name: item.user_name,
      //     occur_date: item.ord_checklist.occurDate,
      //     up_date: item.ord_checklist.upDate
      //   });
      // });
      // add 10962 サインイン直後にチェックリスト画面で0/0のチェック項目を表示しようとすると処理中のままになる 関  start
      if (state.selectChecklistSetting) {
        // add 10962 サインイン直後にチェックリスト画面で0/0のチェック項目を表示しようとすると処理中のままになる 関  end
      if (data.rstDialysisState === "0") {
        // 条件送信前の場合
        const funcList = deepCopy(state.selectChecklistSetting.funclist);

        let index = 0;

        //mod FNSI修正-redmine4586 房 start
        let sortList = [];

        funcList.forEach(func => {
          let tempList = checkListSource
            .filter(item => item.ord_checklist.rstChecklistInfo.item_number === func.item_number)
            .sort(function(a, b) {
              switch (func.func_class) {
                case 1:
                  // 治療条件
                  return a.ord_checklist.rstChecklistInfo.class_cd - b.ord_checklist.rstChecklistInfo.class_cd;
                case 2:
                  // 医療材料
                  return 0;
                case 3:
                  // 投与薬剤
                  return 0;
                default:
                  return 0;
              }
            })
          sortList = sortList.concat(tempList);
        })

        checkListSource = sortList;
        checkListSource.forEach(item => {
          //mod FNSI修正-redmine4586 房 end

            // 表示用発生日時を作成「一覧」
            let vTime = null;
            //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 Start
            let vDate = null;
            //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 End
            if (item.ord_checklist.occurDate != null) {
              const occurDate = dayjs(item.ord_checklist.occurDate);
              vTime = occurDate.format("HH:mm");
              //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 Start
              const eDateTimeLocal = occurDate
              ? dayjs(occurDate).format("YYYY-MM-DDTHH:mm")
              : dayjs(new Date()).format("YYYY-MM-DDTHH:mm");
              vDate = eDateTimeLocal.substring(0, 10);
             //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 End 
            }

            checkList.push({
              rowno: index,
              ctlNo: item.ord_checklist.checklistCtlNo,
              check: item.ord_checklist.isCheck === "1",
              func_class: item.ord_checklist.funcClass,
              // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリスト 20231115 ztc start
              time: item.ord_checklist.isCheck === "1" ? item.ord_checklist.occurDate : null,
              // 発生日時
              viewtime: item.ord_checklist.isCheck === "1" ? vTime : null,
              //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 Start
              viewDate: item.ord_checklist.isCheck === "1" ? vDate : null,
              // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリスト 20231115 ztc end
              //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 End
              // 種別
              kind: "",

              // 薬剤区分
              medicine_type: item.ord_checklist.rstChecklistInfo.medicine_type,
              // ダイアライザフラグ
              dialyzer_flg: (item.ord_checklist.rstChecklistInfo.medicine_type === null && item.ord_checklist.rstChecklistInfo.class_cd === "5"),
              // 医療材料フラグ
              equip_flg: (item.ord_checklist.rstChecklistInfo.medicine_type === null && item.ord_checklist.rstChecklistInfo.class_cd !== "5"),
              // 通常薬剤フラグ
              medi_flg: (item.ord_checklist.rstChecklistInfo.medicine_type === "1"),
              // 調製薬剤フラグ
              is_medicine_mix: (item.ord_checklist.rstChecklistInfo.medicine_type === "2"),
              item_number: item.ord_checklist.rstChecklistInfo.item_number,
              class_cd: item.ord_checklist.rstChecklistInfo.class_cd,
              code: item.ord_checklist.rstChecklistInfo.code,
              code_update: item.ord_checklist.rstChecklistInfo.code_update,
              name: item.ord_checklist.rstChecklistInfo.name,
              // 穿刺針区分(null: 対象外、0: 未指定、1: A針、2: V針、3: SN)
              needle_type: item.ord_checklist.rstChecklistInfo.needle_type,
              // 数量
              // mod FutreNetWeb+SI課題管理No5556 趙 start
              // amount: item.ord_checklist.rstChecklistInfo.amount ? item.ord_checklist.rstChecklistInfo.amount : 0,
              amount: (item.ord_checklist.rstChecklistInfo.amount && item.ord_checklist.rstChecklistInfo.amount !== "null") ? item.ord_checklist.rstChecklistInfo.amount : 0,
              // mod FutreNetWeb+SI課題管理No5556 趙 end
              // 単位
              unit: (item.ord_checklist.rstChecklistInfo.unit && item.ord_checklist.rstChecklistInfo.unit !== "null") ?
                item.ord_checklist.rstChecklistInfo.unit :
                "",

              //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
              rstClass: item.ord_checklist.rstClass,
              //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

              chg_flg: false,
              chgflg_time: false,
              chgflg_user_id: false,

              user_id: item.ord_checklist.regStaffInfo.reg_staff_cd ? item.ord_checklist.regStaffInfo.reg_staff_cd : -1,
              user_update: item.ord_checklist.regStaffInfo.reg_staff_update,
              user_name: item.user_name,
              occur_date: item.ord_checklist.occurDate,
              //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
              equip_type: item.ord_checklist.rstChecklistInfo.equip_type,
              medicine_no: item.ord_checklist.rstChecklistInfo.medicine_no,
              //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
              up_date: item.ord_checklist.upDate
            });

            index = index + 1;
          });
      } else {
        // 条件送信以降の場合
        // add FutreNetWeb+SI課題管理No7159 趙 start
        const funcList = deepCopy(state.selectChecklistSetting.funclist);

        let index = 0;

        //mod FNSI修正-redmine4586 房 start
        let sortList = [];

        funcList.forEach(func => {
          let tempList = checkListSource
            .filter(item => item.ord_checklist.rstChecklistInfo.item_number === func.item_number)
            .sort(function(a, b) {
              switch (func.func_class) {
                case 1:
                  // 治療条件
                  return a.ord_checklist.rstChecklistInfo.class_cd - b.ord_checklist.rstChecklistInfo.class_cd;
                case 2:
                  // 医療材料
                  return 0;
                case 3:
                  // 投与薬剤
                  return 0;
                default:
                  return 0;
              }
            })
          sortList = sortList.concat(tempList);
        })

        checkListSource = sortList;
        // add FutreNetWeb+SI課題管理No7159 趙 end
        checkListSource
          .forEach((item, index) => {

          // 表示用発生日時を作成「一覧」
          let vTime = null;
           //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 Start
           let vDate = null;
           //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 End
          if (item.ord_checklist.occurDate != null) {
            const occurDate = dayjs(item.ord_checklist.occurDate);
            vTime = occurDate.format("HH:mm");
             //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 Start
             const eDateTimeLocal = occurDate
              ? dayjs(occurDate).format("YYYY-MM-DDTHH:mm")
              : dayjs(new Date()).format("YYYY-MM-DDTHH:mm");
             vDate = eDateTimeLocal.substring(0, 10);
             //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 End
          }

          checkList.push({
            rowno: index,
            ctlNo: item.ord_checklist.checklistCtlNo,
            check: item.ord_checklist.isCheck === "1",
            func_class: item.ord_checklist.funcClass,
            // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリスト 20231115 ztc start
            time: item.ord_checklist.isCheck === "1" ? item.ord_checklist.occurDate : null,
            // 発生日時
            viewtime: item.ord_checklist.isCheck === "1" ? vTime : null,
             //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 Start
            viewDate: item.ord_checklist.isCheck === "1" ? vDate : null,
            // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリスト 20231115 ztc end
             //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 End
            // 種別
            kind: "",

            // 薬剤区分
            medicine_type: item.ord_checklist.rstChecklistInfo.medicine_type,
            // ダイアライザフラグ
            dialyzer_flg: (item.ord_checklist.rstChecklistInfo.medicine_type === null && item.ord_checklist.rstChecklistInfo.class_cd === "5"),
            // 医療材料フラグ
            equip_flg: (item.ord_checklist.rstChecklistInfo.medicine_type === null && item.ord_checklist.rstChecklistInfo.class_cd !== "5"),
            // 通常薬剤フラグ
            medi_flg: (item.ord_checklist.rstChecklistInfo.medicine_type === "1"),
            // 調製薬剤フラグ
            is_medicine_mix: (item.ord_checklist.rstChecklistInfo.medicine_type === "2"),
            item_number: item.ord_checklist.rstChecklistInfo.item_number,
            class_cd: item.ord_checklist.rstChecklistInfo.class_cd,
            code: item.ord_checklist.rstChecklistInfo.code,
            code_update: item.ord_checklist.rstChecklistInfo.code_update,
            name: item.ord_checklist.rstChecklistInfo.name,
            // 穿刺針区分(null: 対象外、0: 未指定、1: A針、2: V針、3: SN)
            needle_type: item.ord_checklist.rstChecklistInfo.needle_type,
            // 数量
            // mod FutreNetWeb+SI課題管理No5556 趙 start
            // amount: item.ord_checklist.rstChecklistInfo.amount ? item.ord_checklist.rstChecklistInfo.amount : 0,
            amount: (item.ord_checklist.rstChecklistInfo.amount && item.ord_checklist.rstChecklistInfo.amount !== "null") ? item.ord_checklist.rstChecklistInfo.amount : 0,
            // mod FutreNetWeb+SI課題管理No5556 趙 end
            // 単位
            unit: (item.ord_checklist.rstChecklistInfo.unit && item.ord_checklist.rstChecklistInfo.unit !== "null") ?
              item.ord_checklist.rstChecklistInfo.unit :
              "",

            //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
            rstClass: item.ord_checklist.rstClass,
            //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

            chg_flg: false,
            chgflg_time: false,
            chgflg_user_id: false,

            user_id: item.ord_checklist.regStaffInfo.reg_staff_cd ? item.ord_checklist.regStaffInfo.reg_staff_cd : -1,
            user_update: item.ord_checklist.regStaffInfo.reg_staff_update,
            user_name: item.user_name,
            occur_date: item.ord_checklist.occurDate,
            //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
            equip_type: item.ord_checklist.rstChecklistInfo.equip_type,
            medicine_no: item.ord_checklist.rstChecklistInfo.medicine_no,
            //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
            up_date: item.ord_checklist.upDate
          });
        });
      }
        // add 10962 サインイン直後にチェックリスト画面で0/0のチェック項目を表示しようとすると処理中のままになる 関  start
      }
      // add 10962 サインイン直後にチェックリスト画面で0/0のチェック項目を表示しようとすると処理中のままになる 関  end
      // FNSI-チェックリスト画面表示を修正 周 mod end

      // 表示用患者名情報         「patName」
      // 表示用治療状況情報       「rstDialysisState」
      // 表示用チェック済項目数情報「checkedItemCount」
      data.checkedItemCount = checkList.filter(p => p.check == true).length;
      // 表示用チェック項目数情報  「checklistItemCount」
      data.checklistItemCount = checkList.length;

      // 表示用クール情報         「kurName」
      // 表示用ベッド名情報       「bedName」
      // 表示用治療日情報         「viewTreatDate」
      let tDate =
        data.treatDate.substr(0, 4) +
        "/" +
        data.treatDate.substr(4, 2) +
        "/" +
        data.treatDate.substr(6, 2);
      let weekList = ["", "月", "火", "水", "木", "金", "土", "日"];
      let tWeek = "(" + weekList[data.treatWeek] + ")";
      data.viewTreatDate = tDate + tWeek;

      // 薬剤及び調製薬剤の対象データをマスタから取得
      let mstMediList = [];
      let mstMediMixList = [];
      // ダイアライザマスタ情報を取得
      let dialyzerList = [];
      // 医療材料マスタ情報を取得
      let equipList = [];

      // 通常薬剤の場合
      // 薬剤区分「1: 通常薬剤」
      if (checkList.filter(p => p.medicine_type === 1).length > 0) {
        // 薬剤マスタ情報を取得
        const mediResponse = await sendRequestGetMstMedicineList({
          list: [...checkList.filter(p => p.medicine_type === 1).map(p => p.code)]
        });
        mstMediList = mediResponse.data;
      }

      // 調製薬剤の場合
      // 薬剤区分「2: 調製薬剤（投与薬剤、調製薬剤の場合）」
      if (checkList.filter(p => p.medicine_type === 2).length > 0) {
        // 調製薬剤マスタ情報を取得
        const mediMixResponse = await sendRequestGetMstMedicineMixList({
          list: [...checkList.filter(p => p.medicine_type === 2).map(p => p.code)]
        });
        mstMediMixList = mediMixResponse.data;
      }

      // ダイアライザの場合
      // 薬剤区分「null: 薬剤以外」
      // チェックリストマスタ.チェックリスト設定.機能リスト.分類コード「5：ダイアライザ」
      if (checkList.filter(p => p.medicine_type === null && p.class_cd === 5).length > 0) {
        // ダイアライザマスタ情報を取得
        const dialyzerResponse = await sendRequestGetMstDialyzerList({
          list: [...checkList.filter(p => p.medicine_type === null && p.class_cd === 5).map(p => p.code)]
        });
        dialyzerList = dialyzerResponse.data;
      }

      // 医療材料の場合
      // 薬剤区分「null: 薬剤以外」
      // チェックリストマスタ.チェックリスト設定.機能リスト.分類コード「5：ダイアライザ」以外
      if (checkList.filter(p => p.medicine_type === null && (p.class_cd && p.class_cd !== 5)).length > 0) {
        // 医療材料マスタ情報を取得
        const equipResponse = await sendRequestGetMstEquipList({
          list: [...checkList.filter(p => p.medicine_type === null && (p.class_cd && p.class_cd !== 5)).map(p => p.code)]
        });
        equipList = equipResponse.data;
      }

      // リストに取得した対象名をセット
      for (let checkListItem of checkList) {
        let mstInfo = null;
        // 通常薬剤の場合
        if (checkListItem.medicine_type === 1) {
          mstInfo = mstMediList.find(item => item.medicineCd === checkListItem.code);
        }
        // 調製薬剤の場合
        if (checkListItem.medicine_type === 2) {
          mstInfo = mstMediMixList.find(item => item.medicineMixCd === checkListItem.code);
        }
        // ダイアライザの場合
        if (checkListItem.medicine_type === null && checkListItem.class_cd === 5) {
          mstInfo = dialyzerList.find(item => item.dialyzerCd === checkListItem.code);
        }
        // 医療材料の場合
        if (checkListItem.medicine_type === null && (checkListItem.class_cd && checkListItem.class_cd !== 5)) {
          mstInfo = equipList.find(item => item.equipmentCd === checkListItem.code);
        }
        // マスタ情報存在場合
        // mod 10310 チェックリストの動作が不正 関 start
        if (data.rstDialysisState === "0" && mstInfo) {
          // 薬剤コードに該当する薬剤マスタがある場合：小数点桁数補正
          checkListItem.decPoint = mstInfo
            ? mstInfo.unitDecimalPoint
            : 0;
          // let numbers = String(checkListItem.amount).split(".");
          // let decPoint = numbers[1] ? numbers[1].length : 0;
          // if (decPoint > checkListItem.decPoint) {
          //   checkListItem.amount = new BigNumber(
          //     1 * checkListItem.amount
          //   ).toFixed();
          // } else {
          //   checkListItem.amount = new BigNumber(1 * checkListItem.amount).toFixed(
          //     checkListItem.decPoint
          //   );
          // }
          // add #10196 指示登録以降にマスタの桁数を変更した際に表示がマスタの桁数通りでない。linjunfeng start
          if ((checkListItem.func_class === 1 && [15, 19, 25].includes(checkListItem.class_cd)) || checkListItem.func_class === 3) {
            let medicineDecPoint = "unitDecimalPoint";
            if (checkListItem.class_cd == 15 || checkListItem.class_cd == 19) {
              medicineDecPoint = "unitDecimalPointSecond"
            }
            let numbers = String(checkListItem.amount).split('.');
            let decPoint = (numbers[1]) ? numbers[1].length : 0;
            if (decPoint > mstInfo[medicineDecPoint]) {
              let numTemp = BigNumber(checkListItem.amount).toFixed();
              let numSplit = numTemp.split('.');
              let decTempPoint = (numSplit[1]) ? numSplit[1].length : 0;
              if (decTempPoint > mstInfo[medicineDecPoint]) {
                checkListItem.amount = numTemp;
              } else {
                checkListItem.amount = BigNumber(checkListItem.amount).toFixed(mstInfo[medicineDecPoint]);
              }
            } else {
              checkListItem.amount = mstInfo[medicineDecPoint] ? BigNumber(checkListItem.amount).toFixed(mstInfo[medicineDecPoint]) : checkListItem.amount;
            }
          }
          // add #10196 指示登録以降にマスタの桁数を変更した際に表示がマスタの桁数通りでない。linjunfeng end
          // 条件送信前の場合:単位情報は未保管のため、こちらもマスタ参照
          if (!checkListItem.unit) {
            // if (data.rstDialysisState === "0") {
              checkListItem.unit = mstInfo.unit;
            // }
            }
          }
        // mod 10310 チェックリストの動作が不正 関 end
        // 種別
        switch(checkListItem.func_class) {
          // 機能種別（func_class）「0：通常リスト」
          case 0:
          default:
            checkListItem.kind = "";
            // フリーワード場合、数量表示空欄
            checkListItem.amount = null;
            checkListItem.unit = null;
            break;
          // 機能種別（func_class）「1：治療条件」
          case 1:
            checkListItem.kind = "条件";
            // 穿刺針の場合
            checkListItem.kind += checkListItem.needle_type ? needleType_equip[checkListItem.needle_type] : "";
            break;
          // 機能種別（func_class）「2：医療材料」
          case 2:
            checkListItem.kind = "医材";
            break;
          // 機能種別（func_class）「3：投与薬剤」
          case 3:
            checkListItem.kind = "投薬";
            break;
        }
      }

      // 取得したord_main情報をセット
      commit("setSelectOrdMain", { selectOrdMain: data });
      // 取得したチェックリスト情報をセット
      commit("setOldSelectChecklist", {
        old_selectChecklist: deepCopy(checkList)
      });
      commit("setSelectChecklist", { selectChecklist: checkList });
    },
    // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end

    // mod #9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zkm start
    /**
     * ord_no指定
     * ord_main情報取得
     */
    // async getOrderMainListByOrdNo({ state, commit }) {
    //   // 治療記録情報取得
    //   const response = await sendRequestGetOrdMainByOrdNo(state.selectOrdNo);

    //   // 取得データの変換
    //   const data = response.data;
    //   // 治療日
    //   let tDate =
    //     data.treatDate.substr(0, 4) +
    //     "/" +
    //     data.treatDate.substr(4, 2) +
    //     "/" +
    //     data.treatDate.substr(6, 2);
    //   let weekList = ["", "月", "火", "水", "木", "金", "土", "日"];
    //   let tWeek = "(" + weekList[data.treatWeek] + ")";
    //   data.viewTreatDate = tDate + tWeek;

    //   // 指示：投与薬剤情報
    //   if (data.indMediInfo !== null) {
    //     data.indMediInfo = JSON.parse(data.indMediInfo);
    //   }
    //   // 指示：治療条件情報
    //   if (data.indCondInfo !== null) {
    //     data.indCondInfo = JSON.parse(data.indCondInfo);
    //   }
    //   // 指示：医療材料情報
    //   if (data.indEquipInfo !== null) {
    //     data.indEquipInfo = JSON.parse(data.indEquipInfo);
    //   }

    //   // 実績：投与薬剤情報
    //   if (data.rstMediInfo !== null) {
    //     data.rstMediInfo = JSON.parse(data.rstMediInfo);
    //   }
    //   // 実績：治療条件情報
    //   if (data.rstCondInfo !== null) {
    //     data.rstCondInfo = JSON.parse(data.rstCondInfo);
    //   }
    //   // 実績：医療材料情報
    //   if (data.rstEquipInfo !== null) {
    //     data.rstEquipInfo = JSON.parse(data.rstEquipInfo);
    //   }

    //   // チェックリストマスタ
    //   let funcList = state.selectChecklistSetting.funclist;
    //   // チェックリスト項目数カウント
    //   let chkCount = 0;
    //   // チェックリストチェック済み項目数カウント
    //   let chkOnCount = 0;
    //   // チェックリスト表示用データ
    //   let checklist = [];

    //   // 登録されていない場合は条件送信前扱い
    //   if (data.rstDialysisState === "" || data.rstDialysisState === null) {
    //     data.rstDialysisState = "0";
    //   }
    //   // チェックリストモーダル表示用情報作成
    //   if (data.rstDialysisState === "0") {
    //     // 条件送信前の場合

    //     // 医療材料指示の医療材料情報取得
    //     let indEquipCodeList = [];
    //     let indEquipList = [];
    //     if (data.indEquipInfo) {
    //       data.indEquipInfo.forEach((value, index, array) => {
    //         if (array[index].equip_type === 0) {
    //           indEquipCodeList.push(array[index].cd);
    //         }
    //       });
    //     }

    //     // 医療材料がある場合
    //     if (indEquipCodeList.length > 0) {
    //       // 医療材料リスト重複削除
    //       indEquipCodeList = indEquipCodeList.filter(function(x, i, self) {
    //         return self.indexOf(x) === i;
    //       });
    //       // 医療材料情報取得
    //       const equipResponse = await sendRequestGetMstEquipList({
    //         list: indEquipCodeList
    //       });
    //       indEquipList = equipResponse.data;

    //       data.indEquipInfo.forEach((value, index, array) => {
    //         for (let i = 0; i < indEquipList.length; i++) {
    //           if (array[index].cd == indEquipList[i].equipmentCd) {
    //             array[index].class_cd = indEquipList[i].classCd;
    //             array[index].name = indEquipList[i].equipmentName;
    //             // 医療材料の更新日時
    //             if (indEquipList[i].upDate !== null) {
    //               const fDate = new Date(indEquipList[i].upDate);
    //               array[index].code_update = dateFormat.utc2Jst(fDate);
    //             }
    //           }
    //         }
    //       });
    //     }

    //     // ダイアライザ取得用codelist
    //     let dialyzerCodeList = [];
    //     // 薬剤取得用codelist
    //     let mediCodeList = [];
    //     // 調整薬剤取得用codelist
    //     let medicineMixCodeList = [];
    //     // 医療材料取得用codelist
    //     let equipCodeList = [];
    //     for (const funcItem of funcList) {
    //       if (funcItem.func_class === 0) {
    //         // 通常リストの場合
    //         checklist.push({
    //           ctlNo: null,
    //           rowno: chkCount,
    //           check: false,
    //           code: null,
    //           code_update: null,
    //           name: funcItem.list_name,
    //           class_cd: funcItem.class_cd,
    //           equip_flg: false,
    //           dialyzer_flg: false,
    //           medi_flg: false,
    //           is_medicine_mix: false,
    //           func_class: funcItem.func_class,
    //           item_number: funcItem.item_number,
    //           kind: "",
    //           needle_type: null,
    //           amount: null,
    //           unit: null,
    //           unit_type: null,
    //           time: null,
    //           viewtime: null,
    //           user_id: -1,
    //           user_update: null,
    //           user_name: "",
    //           chg_flg: false,
    //           chgflg_time: false,
    //           chgflg_user_id: false,
    //           up_date: null
    //         });
    //         chkCount++;
    //       } else if (funcItem.func_class === 1) {
    //         // 治療条件の場合
    //         let cond_class_cd = [funcItem.class_cd];
    //         // ダイアライザの場合
    //         if (funcItem.class_cd === 5) {
    //           // 吸着カラムも追加
    //           cond_class_cd.push(6);
    //           // 一次膜・二次膜
    //           cond_class_cd.push(7);
    //           cond_class_cd.push(8);
    //         }
    //         // 吸着カラムはダイアライザと同時設定にしたので除外
    //         if (funcItem.class_cd === 6) {
    //           continue;
    //         }
    //         // 穿刺針の場合
    //         if (funcItem.class_cd === 9) {
    //           cond_class_cd.push(10);
    //           cond_class_cd.push(11);
    //         }
    //         let resData = checkCondInfo(data.indCondInfo, cond_class_cd);
    //         for (const item of resData.list) {
    //           let dialyzer_flg = false;
    //           let medi_flg = false;
    //           let is_medicine_mix = false;
    //           // 指示単位・レセ単位(指示:1 レセ:2)
    //           let unit_type = null;
    //           // 数量
    //           let amount = null;
    //           // 単位
    //           let unit = null;
    //           // ダイアライザの場合
    //           if (item.class_cd === 5) {
    //             dialyzerCodeList.push(item.code);
    //             dialyzer_flg = true;
    //             // 数量
    //             amount = 1;
    //             // 単位
    //             unit = "本";
    //           } else if (
    //             item.class_cd === 15 ||
    //             item.class_cd === 19 ||
    //             item.class_cd === 25
    //           ) {
    //             // 薬剤(15:透析液,19:補液,25:抗凝固剤)の場合
    //             // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //             //if (item.medicine_type === "2") {
    //             if (item.medicine_type == 2) {
    //               // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    //               // 調整薬剤
    //               medicineMixCodeList.push(item.code);
    //               is_medicine_mix = true;
    //             } else if (
    //               // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //               //item.medicine_type === "1" ||
    //               //item.medicine_type !== "2" // NOTE: 調製薬剤以外はすべて薬剤マスタから取得する
    //               item.medicine_type == 1 ||
    //               item.medicine_type != 2 // NOTE: 調製薬剤以外はすべて薬剤マスタから取得する
    //               // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    //             ) {
    //               // 薬剤
    //               mediCodeList.push(item.code);
    //               medi_flg = true;
    //             }

    //             // 薬剤ごとに数量及び単位設定
    //             if (item.class_cd === 15) {
    //               // 透析液ケース
    //               amount =
    //                 data.indCondInfo[17].value !== null
    //                   ? data.indCondInfo[17].value
    //                   : null;
    //               unit_type = "2";
    //             } else if (item.class_cd === 19) {
    //               // 補液ケース
    //               amount =
    //                 data.indCondInfo[22].value !== null
    //                   ? data.indCondInfo[22].value
    //                   : null;
    //               unit_type = "2";
    //             } else {
    //               // 抗凝固剤ケース
    //               let onnShot =
    //                 data.indCondInfo[26].value !== null
    //                   ? data.indCondInfo[26].value
    //                   : null;
    //               let total =
    //                 data.indCondInfo[28].value !== null
    //                   ? data.indCondInfo[28].value
    //                   : null;
    //               unit_type = "1";
    //               if (onnShot == null || total == null) {
    //                 amount = null;
    //               } else {
    //                 // ワンショット量＋持続総量
    //                 amount = BigNumber(onnShot)
    //                   .plus(total)
    //                   .valueOf();
    //               }
    //             }
    //           } else {
    //             // 医療材料
    //             equipCodeList.push(item.code);
    //           }

    //           // 穿刺針(A/V針, SN)の場合
    //           if (item.needle_type != null) {
    //             // 数量
    //             amount = 1;
    //             // 単位
    //             unit = "本";
    //           }
    //           checklist.push({
    //             ctlNo: null,
    //             rowno: chkCount,
    //             check: false,
    //             code: item.code,
    //             code_update: item.code_update,
    //             name: item.name,
    //             class_cd: item.class_cd,
    //             equip_flg: false,
    //             dialyzer_flg: dialyzer_flg,
    //             medi_flg: medi_flg,
    //             is_medicine_mix: is_medicine_mix,
    //             func_class: funcItem.func_class,
    //             item_number: funcItem.item_number,
    //             kind: item.kind,
    //             needle_type: item.needle_type,
    //             amount: amount,
    //             unit: unit,
    //             unit_type: unit_type,
    //             time: null,
    //             viewtime: null,
    //             user_id: -1,
    //             user_update: null,
    //             user_name: null,
    //             chg_flg: false,
    //             chgflg_time: false,
    //             chgflg_user_id: false,
    //             up_date: null
    //           });
    //           chkCount++;
    //         }
    //       } else if (funcItem.func_class === 2) {
    //         // 医療材料の場合
    //         let equipList = null;

    //         if (funcItem.class_cd === 0) {
    //           // ダイアライザの場合
    //           equipList = checkEquipDialyzerInfo(
    //             data.indEquipInfo,
    //             funcItem.class_cd
    //           );
    //         } else {
    //           // 医療材料の場合
    //           equipList = checkEquipInfo(data.indEquipInfo, funcItem.class_cd);
    //         }
    //         for (const item of equipList.list) {
    //           let dialyzer_flg = false;
    //           // ダイアライザの場合
    //           if (item.class_cd === 0) {
    //             dialyzerCodeList.push(item.code);
    //             dialyzer_flg = true;
    //           }

    //           checklist.push({
    //             ctlNo: null,
    //             rowno: chkCount,
    //             check: false,
    //             code: item.code,
    //             code_update: item.code_update,
    //             name: item.name,
    //             class_cd: item.class_cd,
    //             equip_flg: true,
    //             dialyzer_flg: dialyzer_flg,
    //             medi_flg: false,
    //             is_medicine_mix: false,
    //             func_class: funcItem.func_class,
    //             item_number: funcItem.item_number,
    //             kind: item.kind,
    //             needle_type: item.needle_type,
    //             amount: item.amount,
    //             unit: item.unit,
    //             unit_type: null,
    //             time: null,
    //             viewtime: null,
    //             user_id: -1,
    //             user_update: null,
    //             user_name: null,
    //             chg_flg: false,
    //             chgflg_time: false,
    //             chgflg_user_id: false,
    //             up_date: null
    //           });
    //           chkCount++;
    //         }
    //       }
    //     }

    //     // チェック項目数セット
    //     data.checklistItemCount = chkCount;

    //     // ダイアライザ
    //     let mstDialyzerList = [];
    //     // ダイアライザがある場合
    //     if (dialyzerCodeList.length > 0) {
    //       // ダイアライザリスト重複削除
    //       dialyzerCodeList = dialyzerCodeList.filter(function(x, i, self) {
    //         return self.indexOf(x) === i;
    //       });
    //       // ダイアライザ情報取得
    //       const dialyzerResponse = await sendRequestGetMstDialyzerList({
    //         list: dialyzerCodeList
    //       });
    //       mstDialyzerList = dialyzerResponse.data;
    //     }

    //     // 薬剤
    //     let mstMediList = [];
    //     // 薬剤がある場合
    //     if (mediCodeList.length > 0) {
    //       // 薬剤リスト重複削除
    //       mediCodeList = mediCodeList.filter(function(x, i, self) {
    //         return self.indexOf(x) === i;
    //       });
    //       // 薬剤情報取得
    //       const mediResponse = await sendRequestGetMstMedicineList({
    //         list: mediCodeList
    //       });
    //       mstMediList = mediResponse.data;
    //     }

    //     // 調整薬剤
    //     let mstMedicineMixList = [];
    //     // 調整薬剤がある場合
    //     if (medicineMixCodeList.length > 0) {
    //       // 調整薬剤リスト重複削除
    //       medicineMixCodeList = medicineMixCodeList.filter(function(
    //         x,
    //         i,
    //         self
    //       ) {
    //         return self.indexOf(x) === i;
    //       });
    //       // 調整薬剤情報取得
    //       const medicineMixResponse = await sendRequestGetMstMedicineMixList({
    //         list: medicineMixCodeList
    //       });
    //       mstMedicineMixList = medicineMixResponse.data;
    //     }

    //     // 医療材料
    //     let mstEquipList = [];
    //     // 医療材料がある場合
    //     if (equipCodeList.length > 0) {
    //       // 医療材料リスト重複削除
    //       equipCodeList = equipCodeList.filter(function(x, i, self) {
    //         return self.indexOf(x) === i;
    //       });
    //       // 医療材料情報取得
    //       const equipResponse = await sendRequestGetMstEquipList({
    //         list: equipCodeList
    //       });
    //       mstEquipList = equipResponse.data;
    //     }

    //     // チェックリストに取得したダイアライザ名,医療材料名,薬剤名をセット
    //     for (let i = 0; i < checklist.length; i++) {
    //       if (checklist[i].dialyzer_flg === true) {
    //         // ダイアライザの場合
    //         for (let j = 0; j < mstDialyzerList.length; j++) {
    //           if (checklist[i].code === mstDialyzerList[j].dialyzerCd) {
    //             checklist[i].name = mstDialyzerList[j].modelNumber;
    //             // 治療条件の場合
    //             if (checklist[i].equip_flg === false) {
    //               // 数量セット
    //               checklist[i].amount = 1;
    //             }
    //             // ダイアライザの更新日時
    //             if (mstDialyzerList[j].upDate !== null) {
    //               const fDate = new Date(mstDialyzerList[j].upDate);
    //               checklist[i].code_update = dateFormat.utc2Jst(fDate);
    //             }
    //           }
    //         }
    //       } else if (checklist[i].medi_flg === true) {
    //         // 薬剤の場合
    //         for (let j = 0; j < mstMediList.length; j++) {
    //           if (checklist[i].code === mstMediList[j].medicineCd) {
    //             checklist[i].name = mstMediList[j].medicineName;
    //             checklist[i] = getCheckListUnitAndValue(
    //               checklist[i],
    //               mstMediList[j]
    //             );
    //             // 薬剤の更新日時
    //             if (mstMediList[j].upDate !== null) {
    //               const fDate = new Date(mstMediList[j].upDate);
    //               checklist[i].code_update = dateFormat.utc2Jst(fDate);
    //             }
    //           }
    //         }
    //       } else if (checklist[i].is_medicine_mix === true) {
    //         // 調整薬剤の場合
    //         for (const medicineMix of mstMedicineMixList) {
    //           if (checklist[i].code === medicineMix.medicineMixCd) {
    //             checklist[i].name = medicineMix.medicineMixName;
    //             checklist[i] = getCheckListUnitAndValue(
    //               checklist[i],
    //               medicineMix
    //             );
    //             // 薬剤の更新日時
    //             if (medicineMix.upDate !== null) {
    //               const fDate = new Date(medicineMix.upDate);
    //               checklist[i].code_update = dateFormat.utc2Jst(fDate);
    //             }
    //           }
    //         }
    //       } else {
    //         // 医療材料の場合
    //         for (let j = 0; j < mstEquipList.length; j++) {
    //           if (checklist[i].code === mstEquipList[j].equipmentCd) {
    //             checklist[i].name = mstEquipList[j].equipmentName;
    //             //checklist[i].unit = mstEquipList[j].unit;
    //             // 医療材料の更新日時
    //             if (mstEquipList[j].upDate !== null) {
    //               const fDate = new Date(mstEquipList[j].upDate);
    //               checklist[i].code_update = dateFormat.utc2Jst(fDate);
    //             }
    //           }
    //         }
    //       }
    //     }
    //   }

    //   // チェックリスト実績情報取得
    //   const checklistResponse = await sendRequestGetOrdCheckListByListCd({
    //     ordNo: state.selectOrdNo,
    //     listCd: state.selectListCd
    //   });
    //   // チェックリスト実績
    //   let ordChecklist = checklistResponse.data;

    //   if (data.rstDialysisState === "0") {
    //     // 条件送信前の場合
    //     ordChecklist.forEach((value, index, array) => {
    //       array[index].ord_checklist.regStaffInfo.user_name =
    //         array[index].user_name;
    //       // チェック状態セット
    //       if (array[index].ord_checklist.isCheck === "0") {
    //         array[index].ord_checklist.check = false;
    //       } else if (array[index].ord_checklist.isCheck === "1") {
    //         array[index].ord_checklist.check = true;
    //       }

    //       // チェック済み項目をセットする
    //       for (let idx in checklist) {
    //         // 機能フラグ,item_number,code、needle_type、が一致する場合
    //         if (
    //           checklist[idx].func_class ==
    //             array[index].ord_checklist.funcClass &&
    //           checklist[idx].item_number ==
    //             array[index].ord_checklist.rstChecklistInfo.item_number &&
    //           checklist[idx].code ==
    //             array[index].ord_checklist.rstChecklistInfo.code &&
    //           checklist[idx].needle_type ==
    //             array[index].ord_checklist.rstChecklistInfo.needle_type
    //         ) {
    //           checklist[idx].ctlNo = array[index].ord_checklist.checklistCtlNo;
    //           checklist[idx].check = array[index].ord_checklist.check;
    //           checklist[idx].name =
    //             array[index].ord_checklist.rstChecklistInfo.name;
    //           checklist[idx].amount =
    //             array[index].ord_checklist.rstChecklistInfo.amount;
    //           checklist[idx].unit =
    //             array[index].ord_checklist.rstChecklistInfo.unit;
    //           checklist[idx].time = array[index].ord_checklist.occurDate;
    //           let vTime = "";
    //           if (array[index].ord_checklist.occurDate != null) {
    //             const occurDate = dayjs(array[index].ord_checklist.occurDate);
    //             vTime = occurDate.format("HH:mm");
    //           }
    //           checklist[idx].viewtime = vTime;
    //           checklist[idx].user_id =
    //             array[index].ord_checklist.regStaffInfo.reg_staff_cd;
    //           checklist[idx].user_update =
    //             array[index].ord_checklist.regStaffInfo.reg_staff_update;
    //           checklist[idx].user_name =
    //             array[index].ord_checklist.regStaffInfo.user_name;
    //           checklist[idx].up_date = array[index].ord_checklist.upDate;
    //           if (array[index].ord_checklist.check === true) {
    //             chkOnCount++;
    //           }
    //         }
    //       }
    //     });
    //   } else {
    //     // 条件送信後の場合
    //     chkCount = 0;

    //     const funclist = state.selectChecklistSetting.funclist;

    //     funclist.forEach((func, idx, list) => {
    //       const itemNumber = list[idx].item_number;
    //       const funcClass = func.func_class;
    //       const classCd = func.class_cd;
    //       let tmpOrdCheckList = [];
    //       for (const ordChkItem of ordChecklist) {
    //         // item_numberが一致する項目を抽出
    //         if (
    //           itemNumber ===
    //           ordChkItem.ord_checklist.rstChecklistInfo.item_number
    //         ) {
    //           tmpOrdCheckList.push(ordChkItem);
    //         }
    //       }
    //       if (funcClass == 1) {
    //         // 治療条件の場合
    //         if (classCd == 5) {
    //           // ダイアライザの場合
    //           const baseList = deepCopy(tmpOrdCheckList);
    //           tmpOrdCheckList = [];
    //           for (const targetCd of [5, 6, 7, 8]) {
    //             for (const item of baseList) {
    //               if (
    //                 item.ord_checklist.rstChecklistInfo.class_cd == targetCd
    //               ) {
    //                 // 順序で整列
    //                 tmpOrdCheckList.push(item);
    //               }
    //             }
    //           }
    //         } else if (classCd == 9) {
    //           // 穿刺針の場合
    //           const baseList = deepCopy(tmpOrdCheckList);
    //           tmpOrdCheckList = [];
    //           for (const targetCd of [9, 10, 11]) {
    //             for (const item of baseList) {
    //               if (
    //                 item.ord_checklist.rstChecklistInfo.class_cd == targetCd
    //               ) {
    //                 // 順序で整列
    //                 tmpOrdCheckList.push(item);
    //               }
    //             }
    //           }
    //         }
    //       } else if (funcClass == 2) {
    //         // 医療材料の場合
    //         tmpOrdCheckList = tmpOrdCheckList.sort((s1, s2) => {
    //           const name1 = s1.ord_checklist.rstChecklistInfo.name;
    //           const name2 = s2.ord_checklist.rstChecklistInfo.name;
    //           if (!name1) {
    //             return 1;
    //           } else if (!name2) {
    //             return 1;
    //           }
    //           if (name1 < name2) {
    //             return -1;
    //           }
    //           if (name1 > name2) {
    //             return 1;
    //           }
    //           return 0;
    //         });
    //       }
    //       for (const ordChkItem of tmpOrdCheckList) {
    //         // チェックリスト項目作成
    //         // チェック状態セット
    //         if (ordChkItem.ord_checklist.isCheck === "0") {
    //           ordChkItem.ord_checklist.check = false;
    //         } else if (ordChkItem.ord_checklist.isCheck === "1") {
    //           ordChkItem.ord_checklist.check = true;
    //         }

    //         // 種別
    //         let strKind = "";
    //         if (ordChkItem.ord_checklist.funcClass === 1) {
    //           // 透析条件
    //           strKind += "条件";
    //         } else if (ordChkItem.ord_checklist.funcClass === 2) {
    //           // 医療材料
    //           strKind += "医材";
    //         }
    //         // 穿刺針の場合
    //         if (
    //           ordChkItem.ord_checklist.rstChecklistInfo.needle_type !== null
    //         ) {
    //           strKind +=
    //             needleType_equip[
    //               ordChkItem.ord_checklist.rstChecklistInfo.needle_type
    //             ];
    //         }

    //         // 発生日時
    //         let vTime = null;
    //         if (ordChkItem.ord_checklist.occurDate !== null) {
    //           const occurDate = dayjs(ordChkItem.ord_checklist.occurDate);
    //           vTime = occurDate.format("HH:mm");
    //         }

    //         // 実施者ID
    //         let userId = ordChkItem.ord_checklist.regStaffInfo.reg_staff_cd;
    //         if (userId === null) {
    //           userId = -1;
    //         }

    //         checklist.push({
    //           ctlNo: ordChkItem.ord_checklist.checklistCtlNo,
    //           rowno: chkCount,
    //           check: ordChkItem.ord_checklist.check,
    //           code: ordChkItem.ord_checklist.rstChecklistInfo.code,
    //           code_update:
    //             ordChkItem.ord_checklist.rstChecklistInfo.code_update,
    //           name: ordChkItem.ord_checklist.rstChecklistInfo.name,
    //           class_cd: ordChkItem.ord_checklist.rstChecklistInfo.class_cd,
    //           dialyzer_flg: null,
    //           func_class: ordChkItem.ord_checklist.funcClass,
    //           item_number:
    //             ordChkItem.ord_checklist.rstChecklistInfo.item_number,
    //           kind: strKind,
    //           needle_type:
    //             ordChkItem.ord_checklist.rstChecklistInfo.needle_type,
    //           amount: ordChkItem.ord_checklist.rstChecklistInfo.amount,
    //           unit: ordChkItem.ord_checklist.rstChecklistInfo.unit,
    //           time: ordChkItem.ord_checklist.occurDate,
    //           viewtime: vTime,
    //           user_id: userId,
    //           user_update:
    //             ordChkItem.ord_checklist.regStaffInfo.reg_staff_update,
    //           user_name: ordChkItem.user_name,
    //           chg_flg: false,
    //           chgflg_time: false,
    //           chgflg_user_id: false,
    //           up_date: ordChkItem.ord_checklist.upDate
    //         });
    //         chkCount++;

    //         if (ordChkItem.ord_checklist.check === true) {
    //           chkOnCount++;
    //         }
    //       }
    //     });

    //     // 表示用チェックリストに追加漏れがあった場合は追加する
    //     for (const ordChkItem of ordChecklist) {
    //       if (
    //         checklist.findIndex(
    //           chk => chk.ctlNo === ordChkItem.ord_checklist.checklistCtlNo
    //         ) < 0
    //       ) {
    //         // チェックリスト項目作成
    //         // チェック状態セット
    //         if (ordChkItem.ord_checklist.isCheck === "0") {
    //           ordChkItem.ord_checklist.check = false;
    //         } else if (ordChkItem.ord_checklist.isCheck === "1") {
    //           ordChkItem.ord_checklist.check = true;
    //         }

    //         // 種別
    //         let strKind = "";
    //         if (ordChkItem.ord_checklist.funcClass === 1) {
    //           // 透析条件
    //           strKind += "条件";
    //         } else if (ordChkItem.ord_checklist.funcClass === 2) {
    //           // 医療材料
    //           strKind += "医材";
    //         }
    //         // 穿刺針の場合
    //         if (
    //           ordChkItem.ord_checklist.rstChecklistInfo.needle_type !== null
    //         ) {
    //           strKind +=
    //             needleType_equip[
    //               ordChkItem.ord_checklist.rstChecklistInfo.needle_type
    //             ];
    //         }

    //         // 発生日時
    //         let vTime = null;
    //         if (ordChkItem.ord_checklist.occurDate !== null) {
    //           const occurDate = dayjs(ordChkItem.ord_checklist.occurDate);
    //           vTime = occurDate.format("HH:mm");
    //         }

    //         // 実施者ID
    //         let userId = ordChkItem.ord_checklist.regStaffInfo.reg_staff_cd;
    //         if (userId === null) {
    //           userId = -1;
    //         }

    //         checklist.push({
    //           ctlNo: ordChkItem.ord_checklist.checklistCtlNo,
    //           rowno: chkCount,
    //           check: ordChkItem.ord_checklist.check,
    //           code: ordChkItem.ord_checklist.rstChecklistInfo.code,
    //           code_update:
    //             ordChkItem.ord_checklist.rstChecklistInfo.code_update,
    //           name: ordChkItem.ord_checklist.rstChecklistInfo.name,
    //           class_cd: ordChkItem.ord_checklist.rstChecklistInfo.class_cd,
    //           dialyzer_flg: null,
    //           func_class: ordChkItem.ord_checklist.funcClass,
    //           item_number:
    //             ordChkItem.ord_checklist.rstChecklistInfo.item_number,
    //           kind: strKind,
    //           needle_type:
    //             ordChkItem.ord_checklist.rstChecklistInfo.needle_type,
    //           amount: ordChkItem.ord_checklist.rstChecklistInfo.amount,
    //           unit: ordChkItem.ord_checklist.rstChecklistInfo.unit,
    //           time: ordChkItem.ord_checklist.occurDate,
    //           viewtime: vTime,
    //           user_id: userId,
    //           user_update:
    //             ordChkItem.ord_checklist.regStaffInfo.reg_staff_update,
    //           user_name: ordChkItem.user_name,
    //           chg_flg: false,
    //           chgflg_time: false,
    //           chgflg_user_id: false,
    //           up_date: ordChkItem.ord_checklist.upDate
    //         });
    //         chkCount++;

    //         if (ordChkItem.ord_checklist.check === true) {
    //           chkOnCount++;
    //         }
    //       }
    //     }
    //     // チェック項目数セット
    //     data.checklistItemCount = chkCount;
    //   }

    //   // チェック済み項目数セット
    //   data.checkedItemCount = chkOnCount;

    //   // 取得したord_main情報をセット
    //   commit("setSelectOrdMain", { selectOrdMain: data });
    //   // 取得したチェックリスト情報をセット
    //   commit("setOldSelectChecklist", {
    //     old_selectChecklist: deepCopy(checklist)
    //   });
    //   commit("setSelectChecklist", { selectChecklist: checklist });
    // },
    // mod #9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zkm start

    // モーダル呼び出し前に表示用の情報をセット
    setSelectCheckList({ commit }, item) {
      // チェックリスト情報をクリア
      commit("setOldSelectChecklist", { old_selectChecklist: null });
      commit("setSelectChecklist", { selectChecklist: null });
      // 選択したord_main情報をセット
      commit("setSelectOrdNo", { selectOrdNo: item.ordNo });
      // 選択したlist_cd情報をセット
      commit("setSelectListCd", { selectListCd: Number(item.listCd) });
      // 選択したchecklistCd情報をセット
      commit("setSelectChecklistCd", {
        selectChecklistCd: Number(item.checklistCd)
      });
    },

    // モーダル表示時に
    setUserAccountInfo({ commit }, info) {
      // ログインユーザー情報をセット
      commit("setUserAccountInfo", { userAccountInfo: info });
    },

    /**
     * チェック状態の変更時にデータをセットする
     * @param {*} item チェック行のデータ
     */
    setCheckInfo({ state, commit }, item) {
      const checklist = state.selectChecklist;
      let chgRecord;
      //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 Start
      let setViewDate;
      //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 End
      for (let i = 0; i < checklist.length; i++) {
        if (checklist[i].rowno === item.rowno) {
          chgRecord = checklist[i];
          chgRecord.chg_flg = false;
          chgRecord.chgflg_time = false;
          chgRecord.chgflg_user_id = false;

          if (item.check) {
            // チェック済み→未チェック
            chgRecord.check = false;
            chgRecord.time = null;
            // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリスト 20231115 ztc start
            chgRecord.viewDate = null;
            // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリスト 20231115 ztc end
            chgRecord.viewtime = null;
            chgRecord.user_id = -1;
            chgRecord.user_update = null;
            chgRecord.user_name = null;
          } else {
            // 未チェック→チェック済み
            chgRecord.check = true;
            // 現在時刻
            let nowTime = new Date();
            chgRecord.time = nowTime;
            chgRecord.viewtime = dayjs().format("HH:mm");
            //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 Start
            setViewDate = dayjs(new Date()).format("YYYY-MM-DDTHH:mm");
            setViewDate = setViewDate.substring(0, 10);
            chgRecord.viewDate = setViewDate;
            //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 End

            chgRecord.user_id = state.userAccountInfo.userId;
            chgRecord.user_update = state.userAccountInfo.upDate;
            chgRecord.user_name =
              state.userAccountInfo.userLastName +
              " " +
              state.userAccountInfo.userFirstName;
          }

          // 変更チェック
          const oldChecklist = state.old_selectChecklist[chgRecord.rowno];
          // 編集前データがある場合
          if (oldChecklist !== null) {
            // チェック状態
            if (chgRecord.check !== oldChecklist.check) {
              // 変更あり
              chgRecord.chg_flg = true;
            }
            // 時刻
            let chkTime = chgRecord.viewtime;
            if (chgRecord.viewtime == null) {
              chkTime = null;
            }
            if (chkTime !== oldChecklist.viewtime) {
              // 変更あり
              chgRecord.chgflg_time = true;
            }
            // 実施者
            let chkUser = chgRecord.user_id;
            if (chkUser !== oldChecklist.user_id) {
              // 変更あり
              chgRecord.chgflg_user_id = true;
            }

            if (
              chgRecord.chg_flg ||
              chgRecord.chgflg_time ||
              chgRecord.chgflg_user_id
            ) {
              // 変更あり
              chgRecord.chg_flg = true;
            }
          }

          // データ更新
          checklist.splice(i, 1, chgRecord);
        }
      }
      // 変更したチェックリスト情報をセット
      commit("setSelectChecklist", { selectChecklist: checklist });
    },

    /**
     * 実施者変更時にデータをセットする
     * @param {*} rowData チェック行のデータ
     */
    setCheckInfoChangeData({ state, commit }, rowData) {
      let setCheck = true;
      let setTime = rowData.time;
      let setViewTime = rowData.viewtime;
      //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 Start
      let setViewDate = rowData.viewDate;
      //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 End
      let setUserId = null;

      // 実施者が変更された場合
      if (rowData.user_id !== undefined) {
        setUserId = rowData.user_id;
        // 実施者が空にされた場合
        // MedicineModal と同様：マスタ「未登録」は value が null のため、実施チェックを外して行をクリアする
        if (rowData.user_id == -1 || rowData.user_id == null) {
          setCheck = false;
        } else if (setTime == null) {
          // 実施時刻が入力されていない場合
          // 現在時刻セット
          setViewTime = dayjs().format("HH:mm");
          //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 Start
          setViewDate = dayjs(new Date()).format("YYYY-MM-DDTHH:mm");
          setViewDate = setViewDate.substring(0, 10);
           //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 End
        }
      }

      const checklist = state.selectChecklist;
      let chgRecord;
      //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 Start
      let vDate;
      //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 End
      for (let i = 0; i < checklist.length; i++) {
        if (checklist[i].rowno === rowData.rowno) {
          chgRecord = checklist[i];
          chgRecord.chg_flg = false;
          chgRecord.chgflg_time = false;
          chgRecord.chgflg_user_id = false;

          if (setCheck) {
            // 未チェック→チェック済み
            chgRecord.check = true;
            chgRecord.time = setTime;
            chgRecord.viewtime = setViewTime;
            //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 Start
            chgRecord.viewDate = setViewDate;
            //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 End
            if (setUserId !== null) {
              // 実施者情報取得
              const staffInfo = getUserInfo(state.staffList, setUserId);
              if (staffInfo.upDate != null) {
                const fDate = new Date(staffInfo.upDate);
                const setUserUpdate = dateFormat.utc2Jst(fDate);
                chgRecord.user_update = setUserUpdate;
              }
              chgRecord.user_id = setUserId;
              chgRecord.user_name =
                staffInfo.userLastName + " " + staffInfo.userFirstName;
            }
          } else {
            // チェック済み→未チェック
            chgRecord.check = false;
            chgRecord.time = null;
            chgRecord.viewtime = null;
            chgRecord.viewDate = null;
            chgRecord.user_id = -1;
            chgRecord.user_update = null;
            chgRecord.user_name = null;
          }

          // 変更チェック
          const oldChecklist = state.old_selectChecklist[chgRecord.rowno];
           //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 Start
           const eDateTimeLocal = oldChecklist.occur_date
           ? dayjs(oldChecklist.occur_date).format("YYYY-MM-DDTHH:mm")
           : dayjs(new Date()).format("YYYY-MM-DDTHH:mm");
           vDate = eDateTimeLocal.substring(0, 10);
          //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 End 
          // 編集前データがある場合
          if (oldChecklist !== null) {
            // チェック状態
            if (chgRecord.check !== oldChecklist.check) {
              // 変更あり
              chgRecord.chg_flg = true;
            }
             // 時刻(日付)
             if (chgRecord.viewDate !== vDate) {
              // 変更あり
              chgRecord.chgflg_time = true;
            }
            // 時刻（時間）
            if (chgRecord.viewtime !== oldChecklist.viewtime) {
              // 変更あり
              chgRecord.chgflg_time = true;
            }
            // 実施者
            if (chgRecord.user_id !== oldChecklist.user_id) {
              // 変更あり
              chgRecord.chgflg_user_id = true;
            }

            if (
              chgRecord.chg_flg ||
              chgRecord.chgflg_time ||
              chgRecord.chgflg_user_id
            ) {
              // 変更あり
              chgRecord.chg_flg = true;
            }
          }

          // データ更新
          checklist.splice(i, 1, chgRecord);
        }
      }
      // 変更したチェックリスト情報をセット
      commit("setSelectChecklist", { selectChecklist: checklist });
    },
    getRowData({ state }, rowno) {
      const checklist = state.selectChecklist;
      let Record = null;
      for (const item of checklist) {
        if (item.rowno === rowno) {
          Record = item;
        }
      }
      return Record;
    },
    /**
     * チェックリスト登録
     */
    async regChecklist({ state }) {
      // グリッドデータ
      let gridData = state.selectChecklist;
      let regData = [];

      for (const gridItem of gridData) {
        if (gridItem.chg_flg === true) {
          if (gridItem.user_id === -1) {
            gridItem.user_id = null;
          }
          //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 Start
          if (gridItem.chgflg_time && gridItem.Date != null) {
              gridItem.time = gridItem.Date;
          }
          //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 End
          let rowData = {
            // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
            // checklistCtlNo: gridItem.ctlNo,
            // ordNo: state.selectOrdNo,
            // isCheck: gridItem.check === true ? "1" : "0",
            // rstClass: state.selectOrdMain.rstDialysisState === "0" ? 0 : 1,

            // 「チェックリスト管理番号」
            // 「新規の場合」   ⇒   null
            // 「更新の場合」   ⇒   データベースを取得
            // 「削除の場合」   ⇒   データベースを取得
            checklistCtlNo: gridItem.ctlNo,
            ordNo: state.selectOrdNo,
            // 「実施状態」          「条件送信前」         「条件送信以降」
            // 「新規の場合」   ⇒   （１：実施済み）        （存在なし）
            // 「更新の場合」   ⇒   （実施者更新のみ）      （実施済み⇒未実施）
            //                                            （未実施⇒実施済み）
            // 「削除の場合」   ⇒   （０：未実施）          （存在なし）
            isCheck: gridItem.check === true ? "1" : "0",
            // 「実績区分」          「条件送信前」         「条件送信以降」         「機能対象外」
            //                      （０：条件送信前）      （１：条件送信以降）     （２：初版確定）
            //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
            // rstClass: state.selectOrdMain.rstDialysisState === "0" ? 0 : 1,
            rstClass: gridItem.rstClass,
            //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
            // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
            funcClass: gridItem.func_class,
            listCd: state.selectListCd,
            // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
            // occurDate: gridItem.occur_date,
            //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 Start
            occurDate: (gridItem.ctlNo ?
              (gridItem.chgflg_time ? gridItem.time : gridItem.occur_date) :
              gridItem.time),
            //#9226：チェックリストで画面で実施者を変更すると実施時刻がクリアされる。 End
            // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
            isDisp: "1",
            isDel: "0",
            rstChecklistInfo: {
              checklist_cd: state.checklistSetting.checklistCd,
              item_number: gridItem.item_number,
              class_cd: gridItem.class_cd,
              code: gridItem.code,
              code_update: gridItem.code_update,
              // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
              // 「薬剤区分」1: 通常薬剤、2: 調製薬剤（投与薬剤、調製薬剤の場合）
              medicine_type: gridItem.medicine_type,
              // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
              name: gridItem.name,
              needle_type: gridItem.needle_type,
              amount: gridItem.amount,
              //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
              medicine_no: gridItem.medicine_no,
              equip_type: gridItem.equip_type,
              //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
              unit: gridItem.unit
            },
            regStaffInfo: {
              reg_staff_cd: gridItem.user_id,
              // add #7857-【デグレ】チェックリストマスタとチェックリストが正しくコンバートされなくなっている 徐博 start
              reg_staff_name: gridItem.user_name,
              // add #7857-【デグレ】チェックリストマスタとチェックリストが正しくコンバートされなくなっている 徐博 end
              reg_staff_update: gridItem.user_update
            },
            // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
            // upDate: gridItem.up_date
            // del #12270 【因島】ord_checklist.reg_date、up_dateを登録していない処理がある。 関 start
            // upDate: dateFormat.utc2Jst(new Date()),
            // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
            // del #12270 【因島】ord_checklist.reg_date、up_dateを登録していない処理がある。 関 end
          };
          // 設定内容(JSON→文字列)
          rowData.rstChecklistInfo = JSON.stringify(rowData.rstChecklistInfo);
          rowData.regStaffInfo = JSON.stringify(rowData.regStaffInfo);
          regData.push(rowData);
        }
      }

      // 登録結果
      let response = await sendRequestUpdateOrdChecklist(regData);

      // 登録成功
      if (response.status == 200) {
        // 登録失敗情報がある場合
        if (response.data.errorDataList != null) {
          let errData = JSON.parse(response.data.errorDataList);
          let errMessage =
            "以下の項目が更新されているため登録できませんでした。<br>";
          errData.forEach((value, index, array) => {
            errMessage += "・" + array[index].rstChecklistInfo.name + "<br>";
          });

          // エラーメッセージ表示
          return { result: false, message: errMessage };
        }

        return { result: true };
      } else {
        return { result: false, message: response.errorMessage };
      }
    }
  },
  mutations: {
    // グリッドコンボボックス用スタッフ一覧
    setCmbStaffList(state, payload) {
      state.cmbStaffList = payload.cmbStaffList;
    },
    // スタッフ一覧
    setStaffList(state, payload) {
      state.staffList = payload.staffList;
    },
    // チェックリスト設定
    setChecklistSetting(state, setting) {
      state.checklistSetting = setting;
    },
    // 選択中のlistCdのチェックリスト設定
    setSelectChecklistSetting(state, setting) {
      state.selectChecklistSetting = setting;
    },
    // ord_no
    setSelectOrdNo(state, payload) {
      state.selectOrdNo = payload.selectOrdNo;
    },
    // ord_main
    setSelectOrdMain(state, payload) {
      state.selectOrdMain = payload.selectOrdMain;
    },
    // 選択中のチェックリスト(編集前)
    setOldSelectChecklist(state, payload) {
      state.old_selectChecklist = payload.old_selectChecklist;
    },
    // 選択中のチェックリスト(編集内容)
    setSelectChecklist(state, payload) {
      state.selectChecklist = payload.selectChecklist;
    },
    // list_cd
    setSelectListCd(state, payload) {
      state.selectListCd = payload.selectListCd;
    },
    // checklist_cd
    setSelectChecklistCd(state, payload) {
      state.selectChecklistCd = payload.selectChecklistCd;
    },
    setUserAccountInfo(state, payload) {
      state.userAccountInfo = payload.userAccountInfo;
    }
  }
};

/********** function **********/
// 治療条件項目
function checkCondInfo(condList, codelist) {
  let rCnt = 0;
  let rList = [];
  // 治療条件
  for (const code of codelist) {
    // 指示・実績がある場合
    if (condList !== null && code !== null) {
      if (condList[code] && condList[code].value !== null) {
        // 種別
        let strKind = "条件";
        // 穿刺針種別
        let nType = null;
        // 穿刺針の場合
        if (needleType_cond[code] !== undefined) {
          strKind += needleType_cond[code].name;
          nType = needleType_cond[code].type;
        }
        rList.push({
          class_cd: code,
          code: condList[code].value,
          code_update: null,
          name: condList[code].value_name_1,
          medicine_type: condList[code].medicine_type,
          kind: strKind,
          needle_type: nType
        });
        rCnt++;
      }
    }
  }

  return { list: rList, count: rCnt };
}

// 医療材料項目
function checkEquipInfo(list, code) {
  let rCnt = 0;
  let rList = [];
  // 指示・実績がある場合
  if (list !== null && code !== null) {
    for (let elp = 0; elp < list.length; elp++) {
      if (list[elp].class_cd === code) {
        // 種別
        let strKind = "医材";
        // 穿刺針の場合
        if (list[elp].needle_type !== null) {
          strKind += needleType_equip[list[elp].needle_type];
        }
        rList.push({
          class_cd: code,
          code: list[elp].cd,
          code_update: list[elp].code_update,
          name: list[elp].name,
          kind: strKind,
          needle_type: list[elp].needle_type,
          amount: list[elp].amount,
          unit: list[elp].unit
        });
        rCnt++;
      }
    }
  }
  return { list: rList, count: rCnt };
}

// 医療材料のダイアライザ項目
function checkEquipDialyzerInfo(list, code) {
  let rCnt = 0;
  let rList = [];
  // 指示・実績がある場合
  if (list !== null) {
    for (let elp = 0; elp < list.length; elp++) {
      // 医療材料区分がダイアライザのもの
      if (list[elp].equip_type === 1) {
        // 種別
        let strKind = "医材";
        rList.push({
          class_cd: code,
          code: list[elp].cd,
          code_update: null,
          name: null,
          kind: strKind,
          needle_type: list[elp].needle_type,
          amount: list[elp].amount,
          unit: "本"
          //unit: list[elp].unit
        });
        rCnt++;
      }
    }
  }
  return { list: rList, count: rCnt };
}

// use_idからユーザ情報取得
function getUserInfo(useList, id) {
  let rData = null;
  useList.forEach((value, idx, ary) => {
    if (ary[idx].userId === id) {
      rData = ary[idx];
    }
  });
  return rData;
}

// チェックリストに薬剤・調製薬剤マスタの単位及び数量情報セット
function getCheckListUnitAndValue(checkList, mediMaster) {
  let mstDecPoint = null;
  if (checkList.class_cd === 15 || checkList.class_cd === 19) {
    // 透析液及び補液の場合
    checkList.unit = mediMaster.unitSecond;
    mstDecPoint = mediMaster.unitDecimalPointSecond
      ? mediMaster.unitDecimalPointSecond
      : 0;
  } else if (checkList.class_cd === 25) {
    // 抗凝固剤の場合
    checkList.unit = mediMaster.unit;
    mstDecPoint = mediMaster.unitDecimalPoint ? mediMaster.unitDecimalPoint : 0;
  } else {
    // それ以外：そのまま返却
  }

  if (mstDecPoint) {
    let numbers = String(checkList.amount).split(".");
    let decPoint = numbers[1] ? numbers[1].length : 0;
    if (decPoint > mstDecPoint) {
      checkList.amount = new BigNumber(1 * checkList.amount).toFixed();
    } else {
      checkList.amount = new BigNumber(1 * checkList.amount).toFixed(
        mstDecPoint
      );
    }
  }

  return checkList;
}
