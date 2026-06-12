//@ts-check

/**
 * 投与薬剤モーダル用ストア
 */
import {
  sendRequestGetOrdMainByOrdNo,
  sendRequestGetMstMedicineList,
  sendRequestGetMstMedicineMixList,
  sendRequestGetMstPersonalUser,
  sendRequestUpdateOrdMainMediInfo
  // @ts-ignore
} from "@/apis/check-list";
// @ts-ignore
import { deepCopy } from "@/functions/common/CommonFunctions";
// @ts-ignore
import { dateFormat } from "@/functions/common/DateTimeUtils";
import dayjs from "@/compat/date/dayjs";
import BigNumber from "@/compat/number/bignumber";
// add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
import { medicineAllergy, medicineMixAllergy } from "@/functions/mst/MstGetters.js";
import { getPrefix } from "@/functions/common/CommonFunctions";
// add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end

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
    // 選択中のord_main（スケジュール）
    selectOrdMain: null,
    // 選択中の投与薬剤情報(編集前)
    old_selectMediList: null,
    // 選択中の投与薬剤情報
    selectMediList: null,
    // ログインユーザー情報
    userAccountInfo: null
  },
  getters: {
    getSelectOrdMain(state) {
      return state.selectOrdMain;
    },
    getSelectMediList(state) {
      return state.selectMediList;
    },
    getSchema(state) {
      return state.schema;
    },
    getCmbStaffList(state) {
      return state.cmbStaffList;
    },
    getStaffList(state) {
      return state.staffList;
    }
  },
  actions: {
    /**
     * スタッフ情報取得
     * @param {Object} context
     * @param {String} facilityCd : 施設コード
     */
    async getMstPersonalUser({ commit }, facilityCd) {
      // スタッフ一覧情報取得
      const response = await sendRequestGetMstPersonalUser(facilityCd);

      // 取得データ
      const data = response.data;
      let list = [];

      list.push({ text: " ", value: null });
      data.forEach((value, index, array) => {
        list.push({ text: array[index].userName, value: array[index].userId });
      });

      // グリッドコンボボックス用スタッフ情報をセット
      commit("setCmbStaffList", { cmbStaffList: list });
      // 取得したスタッフ情報をセット
      commit("setStaffList", { staffList: data });
    },

    // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
    /**
     * ord_no指定
     * 投与薬剤情報を作成
     */
    async getMedicineInfoByOrdNo({ state, commit }) {
      // 治療情報を取得
      const response = await sendRequestGetOrdMainByOrdNo(state.selectOrdNo);
      // 取得データの変換
      const data = response.data;
      // add 10962 サインイン直後にチェックリスト画面で0/0のチェック項目を表示しようとすると処理中のままになる 関  start
      let patId;
      if (data.patId) {
        patId = data.patId;
      } else {
        patId = -1;
      }
      // add 10962 サインイン直後にチェックリスト画面で0/0のチェック項目を表示しようとすると処理中のままになる 関  end
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      // mod 10962 サインイン直後にチェックリスト画面で0/0のチェック項目を表示しようとすると処理中のままになる 関  start
      // let medicine = await medicineAllergy(data.patId, true);
      // const medicineMix = await medicineMixAllergy(data.patId, true);
      let medicine = await medicineAllergy(patId, true);
      const medicineMix = await medicineMixAllergy(patId, true);
      // mod 10962 サインイン直後にチェックリスト画面で0/0のチェック項目を表示しようとすると処理中のままになる 関  end
      medicineMix.forEach((item) =>{
        item.medicineCd = item.medicineMixCd + "$";
      })
      medicine = medicine.concat(medicineMix);
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      // 投与薬剤モーダル表示用情報
      let mediList = [];

      // 登録されていない場合は条件送信前扱い
      if (
        data.rstDialysisState === "" ||
        data.rstDialysisState === null ||
        data.rstDialysisState === "null"
      ) {
        data.rstDialysisState = "0";
      }

      // 投与薬剤モーダル表示用情報作成
      if (data.rstDialysisState === "0") {
        // 条件送信前の場合
        // 指示：投与薬剤情報
        if (data.indMediInfo !== null) {
          // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          let medicineObj = {};
          medicine.forEach((item) => {
            medicineObj[item.medicineCd] = item;
          })
          // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
          data.indMediInfo = JSON.parse(data.indMediInfo);
          data.indMediInfo.forEach((value, idx, ary) => {
            // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
            const newMedicineObj = medicineObj[ary[idx].cd] ? medicineObj[ary[idx].cd] : medicineObj[ary[idx].cd+"$"];
            let prefix = getPrefix( {treatDate : data.treatDate, ...newMedicineObj});
            // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
            // add #10196 指示登録以降にマスタの桁数を変更した際に表示がマスタの桁数通りでない。linjunfeng start
            let amount = ary[idx].amount;
            if (ary[idx].amount && newMedicineObj.unitDecimalPoint != null) {
              let numbers = String(amount).split('.');
              let decPoint = (numbers[1]) ? numbers[1].length : 0;
              if (decPoint > newMedicineObj.unitDecimalPoint) {
                let numTemp = BigNumber(amount).toFixed();
                let numSplit = numTemp.split('.');
                let decTempPoint = (numSplit[1]) ? numSplit[1].length : 0;
                if (decTempPoint > newMedicineObj.unitDecimalPoint) {
                  amount = numTemp;
                } else {
                  amount = BigNumber(amount).toFixed(newMedicineObj.unitDecimalPoint);
                }
              } else {
                amount = newMedicineObj.unitDecimalPoint ? BigNumber(amount).toFixed(newMedicineObj.unitDecimalPoint) : amount;
              }
            }
            // add #10196 指示登録以降にマスタの桁数を変更した際に表示がマスタの桁数通りでない。linjunfeng end
            mediList.push({
              no: ary[idx].no,
              // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
              // name: ary[idx].name,
              name: prefix + ary[idx].name,
              // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
              cd: ary[idx].cd,
              timing_name: ary[idx].timing_name,
              timing_cd: ary[idx].timing_cd,
              procedure_name: ary[idx].procedure_name,
              procedure_cd: ary[idx].procedure_cd,
              // #10196 指示登録以降にマスタの桁数を変更した際に表示がマスタの桁数通りでない。linjunfeng start
              // amount: ary[idx].amount,
              amount: amount,
              // #10196 指示登録以降にマスタの桁数を変更した際に表示がマスタの桁数通りでない。linjunfeng end
              unit: ary[idx].unit,
              medicine_type: ary[idx].medicine_type,
              effect_flg: false,
              effect_date: null,
              effect_date_str: null,
              effect_time_str: null,
              effect_user_id: null,
              effect_user_last_name: null,
              effect_user_first_name: null,
              effect_user_up_date: null,
              chg_flg: false,
              chgflg_effect: false,
              chgflg_effect_date: false,
              chgflg_effect_user_id: false
            });
          });
        }

      } else {
        // 条件送信以降の場合
        // 実績：投与薬剤情報
        if (data.rstMediInfo !== null) {
          data.rstMediInfo = JSON.parse(data.rstMediInfo);
          data.rstMediInfo.forEach((value, idx, ary) => {
            // 投与時刻
            let eDate = null;
            if (
              ary[idx].effect_date &&
              ary[idx].effect_date !== "" &&
              ary[idx].effect_date !== "null"
            ) {
              eDate = new Date(ary[idx].effect_date);
            }
            const eDateTimeLocal = eDate
              ? dayjs(eDate).format("YYYY-MM-DDTHH:mm")
              : dayjs(new Date()).format("YYYY-MM-DDTHH:mm");

            // 実施者
            let userId = ary[idx].effect_user_id;
            let username =
              ary[idx].effect_user_last_name +
              " " +
              ary[idx].effect_user_first_name;
            let userUpdate = ary[idx].effect_user_up_date;
            if (!userId || userId === "null") {
              userId = null;
              username = " ";
              userUpdate = null;
            }

            mediList.push({
              no: ary[idx].no,
              name: ary[idx].name,
              cd: ary[idx].cd,
              timing_name: ary[idx].timing_name,
              timing_cd: ary[idx].timing_cd,
              procedure_name: ary[idx].procedure_name,
              procedure_cd: ary[idx].procedure_cd,
              amount: ary[idx].amount ? ary[idx].amount : 0,
              unit: (ary[idx].unit && ary[idx].unit !== "null") ?
                ary[idx].unit :
                "",
              medicine_type: ary[idx].medicine_type,
              // 投与実施フラグ（0：未実施、1：実施済み）
              effect_flg: ary[idx].effect_flg == 1,
              /* modify by chamaojia 2024-02-01 [10196] Date formatting --start */
              effect_date: eDate ? dateFormat.utc2Jst(eDate) : null,
              /* modify by chamaojia 2024-02-01 [10196] Date formatting --end */
              // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリスト 20231115 ztc start
              effect_date_str: ary[idx].effect_flg == 1 ? eDateTimeLocal.substring(0, 10) : null,
              effect_time_str: ary[idx].effect_flg == 1 ? eDateTimeLocal.substring(11) : null,
              effect_user_id: userId,
              effect_user_name: ary[idx].effect_flg == 1 ? username : null,
              // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリスト 20231115 ztc end
              effect_user_last_name: ary[idx].effect_user_last_name,
              effect_user_first_name: ary[idx].effect_user_first_name,
              effect_user_up_date: userUpdate,
              chg_flg: false,
              chgflg_effect: false,
              chgflg_effect_date: false,
              chgflg_effect_user_id: false
            });
          });
        }
      }

      // 表示用患者名情報         「patName」
      // 表示用治療状況情報       「rstDialysisState」
      // 表示用チェック済項目数情報「checkedItemCount」
      data.checkedItemCount = mediList.filter(p => p.effect_flg === true).length;
      // 表示用チェック項目数情報  「medilistItemCount」
      data.medilistItemCount = mediList.length;

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

      // 通常薬剤の場合
      if (mediList.filter(p => p.medicine_type === "1").length > 0) {
        // 薬剤マスタ情報を取得
        const mediResponse = await sendRequestGetMstMedicineList({
          list: [...mediList.filter(p => p.medicine_type === "1").map(p => p.cd)]
        });
        mstMediList = mediResponse.data;
      }

      // 調製薬剤の場合
      if (mediList.filter(p => p.medicine_type === "2").length > 0) {
        // 調製薬剤マスタ情報を取得
        const mediMixResponse = await sendRequestGetMstMedicineMixList({
          list: [...mediList.filter(p => p.medicine_type === "2").map(p => p.cd)]
        });
        mstMediMixList = mediMixResponse.data;
      }

      // リストに取得した薬剤名をセット
      for (let mediItem of mediList) {
        let mstInfo = null;
        // 通常薬剤の場合
        if (mediItem.medicine_type === "1") {
          mstInfo = mstMediList.find(item => item.medicineCd === mediItem.cd);
        }
        // 調製薬剤の場合
        if (mediItem.medicine_type === "2") {
          mstInfo = mstMediMixList.find(item => item.medicineMixCd === mediItem.cd);
        }
        if (mstInfo) {
          // 薬剤コードに該当する薬剤マスタがある場合：小数点桁数補正
          mediItem.decPoint = mstInfo
            ? mstInfo.unitDecimalPoint
            : 0;
          let numbers = String(mediItem.amount).split(".");
          let decPoint = numbers[1] ? numbers[1].length : 0;
          if (decPoint > mediItem.decPoint) {
            mediItem.amount = new BigNumber(
              1 * mediItem.amount
            ).toFixed();
          } else {
            mediItem.amount = new BigNumber(1 * mediItem.amount).toFixed(
              mediItem.decPoint
            );
          }
          // 条件送信前の場合:単位情報は未保管のため、こちらもマスタ参照
          if (data.rstDialysisState === "0") {
            mediItem.unit = mstInfo.unit;
          }
        }
      }
      // 取得したord_main情報をセット
      commit("setSelectOrdMain", { selectOrdMain: data });
      // 取得したチェックリスト情報をセット
      commit("setOldSelectMediList", {
        old_selectMediList: deepCopy(mediList)
      });
      commit("setSelectMediList", { selectMediList: mediList });
    },
    // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end

    /**
     * ord_no指定
     * ord_main情報取得
     */
    async getOrderMainByOrdNo({ state, commit }) {
      // 体重計測定記録一覧情報取得
      const response = await sendRequestGetOrdMainByOrdNo(state.selectOrdNo);
      // 取得データの変換
      const data = response.data;
      // 治療日
      let tDate =
        data.treatDate.substr(0, 4) +
        "/" +
        data.treatDate.substr(4, 2) +
        "/" +
        data.treatDate.substr(6, 2);
      let weekList = ["", "月", "火", "水", "木", "金", "土", "日"];
      let tWeek = "(" + weekList[data.treatWeek] + ")";
      data.viewTreatDate = tDate + tWeek;

      // 指示：投与薬剤情報
      if (data.indMediInfo !== null) {
        data.indMediInfo = JSON.parse(data.indMediInfo);
      }
      // 実績：投与薬剤情報
      if (data.rstMediInfo !== null) {
        data.rstMediInfo = JSON.parse(data.rstMediInfo);
      }

      // 投与薬剤項目数
      let mediChkCount = 0;
      // 投与薬剤実施済み項目数
      let mediOnChkCount = 0;
      // 投与薬剤モーダル表示用情報
      let mediList = [];

      // 薬剤取得用codelist
      let mediCodeList = [];
      // 調整薬剤取得用codelist
      let mediMixCodeList = [];

      // 登録されていない場合は条件送信前扱い
      if (
        data.rstDialysisState === "" ||
        data.rstDialysisState === null ||
        data.rstDialysisState === "null"
      ) {
        data.rstDialysisState = "0";
      }

      // 投与薬剤モーダル表示用情報作成
      if (data.rstDialysisState === "0") {
        // 条件送信前の場合
        data.mediInfo = data.indMediInfo;
        if (data.mediInfo) {
          // 投与薬剤表示用情報作成
          data.mediInfo.forEach((value, idx, ary) => {
            if (ary[idx].medicine_type === "2") {
              // 調整薬剤
              mediMixCodeList.push(ary[idx].cd);
            } else {
              // 薬剤
              mediCodeList.push(ary[idx].cd);
            }
            mediList.push({
              no: ary[idx].no,
              name: ary[idx].name,
              cd: ary[idx].cd,
              timing_name: ary[idx].timing_name,
              timing_cd: ary[idx].timing_cd,
              procedure_name: ary[idx].procedure_name,
              procedure_cd: ary[idx].procedure_cd,
              amount: ary[idx].amount,
              unit: ary[idx].unit,
              medicine_type: ary[idx].medicine_type,
              effect_flg: false,
              effect_date: null,
              effect_date_str: null,
              effect_time_str: null,
              effect_user_id: null,
              effect_user_last_name: null,
              effect_user_first_name: null,
              effect_user_up_date: null,
              chg_flg: false,
              chgflg_effect: false,
              chgflg_effect_date: false,
              chgflg_effect_user_id: false
            });
          });
        }
      } else {
        // 条件送信後の場合
        data.mediInfo = data.rstMediInfo;

        // 投薬情報がある場合
        if (data.mediInfo !== null) {
          // 投与薬剤表示用情報作成
          data.mediInfo.forEach((value, idx, ary) => {
            // 実施フラグ
            let eFlg = false;
            if (ary[idx].effect_flg == 1) {
              eFlg = true;
            }

            // 薬剤・調製薬剤マスタ取得データチェック
            if (ary[idx].medicine_type === "2") {
              // 調整薬剤
              mediMixCodeList.push(ary[idx].cd);
            } else {
              // 薬剤
              mediCodeList.push(ary[idx].cd);
            }

            // 投与時刻
            /**@type {Date} */
            let eDate = null;
            if (
              ary[idx].effect_date &&
              ary[idx].effect_date !== "" &&
              ary[idx].effect_date !== "null"
            ) {
              eDate = new Date(ary[idx].effect_date);
            }
            const eDateTimeLocal = eDate
              ? dayjs(eDate).format("YYYY-MM-DDTHH:mm")
              : dayjs(new Date()).format("YYYY-MM-DDTHH:mm");

            // 実施者
            let userId = ary[idx].effect_user_id;
            let username =
              ary[idx].effect_user_last_name +
              " " +
              ary[idx].effect_user_first_name;
            let userUpdate = ary[idx].effect_user_up_date;
            if (!userId || userId === "null") {
              userId = null;
              username = " ";
              userUpdate = null;
            }

            mediList.push({
              no: ary[idx].no,
              name: ary[idx].name,
              cd: ary[idx].cd,
              timing_name: ary[idx].timing_name,
              timing_cd: ary[idx].timing_cd,
              procedure_name: ary[idx].procedure_name,
              procedure_cd: ary[idx].procedure_cd,
              amount: ary[idx].amount,
              unit: ary[idx].unit,
              medicine_type: ary[idx].medicine_type,
              effect_flg: eFlg,
              /* modify by chamaojia 2024-02-01 [10196] Date formatting --start */
              effect_date: eDate ? dateFormat.utc2Jst(eDate) : null,
              /* modify by chamaojia 2024-02-01 [10196] Date formatting --end */
              effect_date_str: eDateTimeLocal.substring(0, 10),
              effect_time_str: eDateTimeLocal.substring(11),
              effect_user_id: userId,
              effect_user_name: username,
              effect_user_last_name: ary[idx].effect_user_last_name,
              effect_user_first_name: ary[idx].effect_user_first_name,
              effect_user_up_date: userUpdate,
              chg_flg: false,
              chgflg_effect: false,
              chgflg_effect_date: false,
              chgflg_effect_user_id: false
            });
            // 実施済みの場合
            if (ary[idx].effect_flg == 1) {
              mediOnChkCount++;
            }
          });
        }
      }

      // 投与薬剤
      // 投与薬剤項目数セット
      if (data.mediInfo !== null) {
        mediChkCount = data.mediInfo.length;
      }
      data.medilistItemCount = mediChkCount;

      // 投与薬剤実施済み項目数セット
      data.checkedItemCount = mediOnChkCount;

      // 薬剤及び調製薬剤の対象データをマスタから取得
      // 薬剤
      let mstMediList = [];
      let mstMediMixList = [];
      // 薬剤がある場合
      if (mediCodeList.length > 0) {
        // 薬剤リスト重複削除
        mediCodeList = mediCodeList.filter(function(x, i, self) {
          return self.indexOf(x) === i;
        });
        // 薬剤情報取得
        const mediResponse = await sendRequestGetMstMedicineList({
          list: mediCodeList
        });
        mstMediList = mediResponse.data;
      }
      // 調整薬剤がある場合
      if (mediMixCodeList.length > 0) {
        // 調整薬剤リスト重複削除
        mediMixCodeList = mediMixCodeList.filter(function(x, i, self) {
          return self.indexOf(x) === i;
        });
        // 調整薬剤情報取得
        const mediMixResponse = await sendRequestGetMstMedicineMixList({
          list: mediMixCodeList
        });
        mstMediMixList = mediMixResponse.data;
      }

      // リストに取得した薬剤名をセット
      let treatMedicine;
      for (let mediItem of mediList) {
        treatMedicine = null;
        if (mediItem.medicine_type === "1") {
          treatMedicine = mstMediList.find(
            medi => medi.medicineCd === mediItem.cd
          );
        } else if (mediItem.medicine_type === "2") {
          treatMedicine = mstMediMixList.find(
            medi => medi.medicineMixCd === mediItem.cd
          );
        }
        if (treatMedicine) {
          // 薬剤コードに該当する薬剤マスタがある場合：小数点桁数補正
          mediItem.decPoint = treatMedicine
            ? treatMedicine.unitDecimalPoint
            : 0;
          let numbers = String(mediItem.amount).split(".");
          let decPoint = numbers[1] ? numbers[1].length : 0;
          if (decPoint > mediItem.decPoint) {
            mediItem.amount = new BigNumber(
              1 * mediItem.amount
            ).toFixed();
          } else {
            mediItem.amount = new BigNumber(1 * mediItem.amount).toFixed(
              mediItem.decPoint
            );
          }
          // 条件送信前:単位情報は未保管のため、こちらもマスタ参照
          if (data.rstDialysisState === "0") {
            mediItem.unit = treatMedicine.unit;
          }
        }
      }
      // 取得したord_main情報をセット
      commit("setSelectOrdMain", { selectOrdMain: data });
      // 取得したチェックリスト情報をセット
      commit("setOldSelectMediList", {
        old_selectMediList: deepCopy(mediList)
      });
      commit("setSelectMediList", { selectMediList: mediList });
    },

    // モーダル呼び出し前に表示用の情報をセット
    setSelectOrdNo({ commit }, no) {
      // 投与薬剤情報をクリア
      commit("setOldSelectMediList", { old_selectMediList: null });
      commit("setSelectMediList", { selectMediList: null });
      // 選択したordNo情報をセット
      commit("setSelectOrdNo", { selectOrdNo: no });
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
      const medicList = state.selectMediList;
      let chgRecord;
      for (let i = 0; i < medicList.length; i++) {
        if (medicList[i].no === item.no) {
          chgRecord = medicList[i];
          chgRecord.chg_flg = false;
          chgRecord.chgflg_effect = false;
          chgRecord.chgflg_effect_date = false;
          chgRecord.chgflg_effect_user_id = false;
          if (item.effect_flg) {
            // チェック済み→未チェック
            chgRecord.effect_flg = false;
            chgRecord.effect_date = null;
            chgRecord.effect_date_str = null;
            chgRecord.effect_time_str = null;
            chgRecord.effect_user_id = null;
            chgRecord.effect_user_update = null;
            chgRecord.effect_user_name = null;
            // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリスト 20231115 ztc start
            delete chgRecord.effect_user_update;
            // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリスト 20231115 ztc end
          } else {
            // 未チェック→チェック済み
            chgRecord.effect_flg = true;
            // 現在時刻
            let nowTime = new Date();
            const nowTimeStr = nowTime
              ? dayjs(nowTime).format("YYYY-MM-DDTHH:mm")
              : dayjs(new Date()).format("YYYY-MM-DDTHH:mm");
            /* modify by chamaojia 2024-02-01 [10196] Date formatting --start */
            chgRecord.effect_date = dateFormat.utc2Jst(nowTime);
            /* modify by chamaojia 2024-02-01 [10196] Date formatting --end */
            chgRecord.effect_date_str = nowTimeStr.substring(0, 10);
            chgRecord.effect_time_str = nowTimeStr.substring(11);
            chgRecord.effect_user_id = state.userAccountInfo.userId;
            let userUpdate = null;
            if (state.userAccountInfo.upDate != null) {
              const fDate = new Date(state.userAccountInfo.upDate);
              userUpdate = dateFormat.utc2Jst(fDate);
            }
            chgRecord.effect_user_update = userUpdate;
            chgRecord.effect_user_name =
              state.userAccountInfo.userLastName +
              " " +
              state.userAccountInfo.userFirstName;
          }

          // 編集前データ取得
          const old_medicList = getOldData(
            state.old_selectMediList,
            chgRecord.no
          );
          // 編集前データがある場合
          if (old_medicList !== null) {
            // 変更チェック
            if (chgRecord.effect_flg !== old_medicList.effect_flg) {
              chgRecord.chgflg_effect = true;
            }
            if (chgRecord.effect_date !== old_medicList.effect_date) {
              chgRecord.chgflg_effect_date = true;
            }
            if (chgRecord.effect_user_id !== old_medicList.effect_user_id) {
              chgRecord.chgflg_effect_user_id = true;
            }
            if (
              chgRecord.chgflg_effect ||
              chgRecord.chgflg_effect_date ||
              chgRecord.chgflg_effect_user_id
            ) {
              // 変更あり
              chgRecord.chg_flg = true;
            }
          }

          // データ更新
          medicList.splice(i, 1, chgRecord);
        }
      }
      // 変更した投与薬剤情報をセット
      commit("setSelectMediList", { selectMediList: medicList });
    },

    /**
     * 実施時刻/実施者変更時にデータをセットする
     * @param {*} rowData チェック行のデータ
     */
    setCheckInfoChangeData({ state, commit }, { rowData, idx }) {
      // mod #12462 チェックリスト->投与薬剤->実施者 error zrx start
      if (!rowData || !state.selectMediList || !state.selectMediList.length) {
        return;
      }
      // MedicineModal 実施者のみ変更時は idx を渡さないため、rowData.no から行を特定する
      const list = state.selectMediList;
      const listIdx =
        idx != null && list[idx] != null
          ? idx
          : list.findIndex((r) => r.no === rowData.no);
      if (listIdx < 0 || list[listIdx] == null) {
        return;
      }
      let setEffectFlg = true;
      let setEffectDate = list[listIdx].effect_date;
      let setEffectUserId = list[listIdx].effect_user_id;
      let setEffectDateStr = list[listIdx].effect_date_str;
      // mod #12462 チェックリスト->投与薬剤->実施者 error zrx end

      // 実施時刻が変更された場合
      if (rowData.effect_date !== undefined) {
        // 実施時刻が空にされた場合
        if (rowData.effect_date == null) {
          setEffectFlg = false;
        }
        // 実施時刻変更時
        setEffectDate = rowData.effect_date;
        // 実施者が入力されていない場合
        if (setEffectUserId == null) {
          // 実施者セット
          setEffectUserId = state.userAccountInfo.userId;
        }
      }

      // 実施者が変更された場合
      if (rowData.effect_user_id !== undefined) {
        setEffectUserId = rowData.effect_user_id;
        // 実施者が空にされた場合
        if (rowData.effect_user_id == null) {
          setEffectFlg = false;
        } else if (setEffectDate == null) {
          // 実施時刻が入力されていない場合
          // 現在時刻セット
          setEffectDate = new Date();
        }
      }

      if (setEffectDate) {
        setEffectDateStr = setEffectDate
          ? dayjs(setEffectDate).format("YYYY-MM-DDTHH:mm")
          : dayjs(new Date()).format("YYYY-MM-DDTHH:mm");
      }

      const medicList = state.selectMediList;
      let chgRecord;
      for (let i = 0; i < medicList.length; i++) {
        if (medicList[i].no === rowData.no) {
          chgRecord = medicList[i];
          chgRecord.chg_flg = false;
          chgRecord.chgflg_effect = false;
          chgRecord.chgflg_effect_date = false;
          chgRecord.chgflg_effect_user_id = false;

          if (setEffectFlg) {
            // 未チェック→チェック済み
            chgRecord.effect_flg = true;
            /* modify by chamaojia 2024-02-01 [10196] Date formatting --start */
            chgRecord.effect_date = dateFormat.utc2Jst(setEffectDate);
            /* modify by chamaojia 2024-02-01 [10196] Date formatting --end */
            chgRecord.effect_date_str = setEffectDateStr.substring(0, 10);
            chgRecord.effect_time_str = setEffectDateStr.substring(11);
            chgRecord.effect_user_update = null;

            if (setEffectUserId !== null) {
              // 実施者情報取得
              const staffData = getUserInfo(state.staffList, setEffectUserId);
              if (staffData.upDate != null) {
                const fDate = new Date(staffData.upDate);
                const setEffectUpdate = dateFormat.utc2Jst(fDate);
                chgRecord.effect_user_update = setEffectUpdate;
              }
              chgRecord.effect_user_id = setEffectUserId;
              chgRecord.effect_user_name =
                staffData.userLastName + " " + staffData.userFirstName;
            }
          } else {
            // チェック済み→未チェック
            chgRecord.effect_flg = false;
            chgRecord.effect_date = null;
            chgRecord.effect_date_str = null;
            chgRecord.effect_time_str = null;
            chgRecord.effect_user_id = null;
            chgRecord.effect_user_update = null;
            chgRecord.effect_user_name = null;
          }

          // 編集前データ取得
          const old_medicList = getOldData(
            state.old_selectMediList,
            chgRecord.no
          );
          // 編集前データがある場合
          if (old_medicList !== null) {
            // 変更チェック
            if (chgRecord.effect_flg !== old_medicList.effect_flg) {
              chgRecord.chgflg_effect = true;
            }
            if (chgRecord.effect_date !== old_medicList.effect_date) {
              chgRecord.chgflg_effect_date = true;
            }
            if (chgRecord.effect_user_id !== old_medicList.effect_user_id) {
              chgRecord.chgflg_effect_user_id = true;
            }
            if (
              chgRecord.chgflg_effect ||
              chgRecord.chgflg_effect_date ||
              chgRecord.chgflg_effect_user_id
            ) {
              // 変更あり
              chgRecord.chg_flg = true;
            }
          }

          // データ更新
          medicList.splice(i, 1, chgRecord);
        }
      }
      // 変更した投与薬剤情報をセット
      commit("setSelectMediList", { selectMediList: medicList });
    },
    /**
     * 投与薬剤登録
     */
    async regMedicineList({ state }) {
      // グリッドデータ
      let gridData = state.selectMediList;
      let regMediData = [];

      for (let medicItem of gridData) {
        if (medicItem.chg_flg === true) {
          // 登録用情報作成
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
          //let effectFlg = "0";
          let effectFlg = 0;
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
          let update = null;
          if (medicItem.effect_flg == true) {
            // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
            //effectFlg = "1";
            effectFlg = 1;
            // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end

            // 実施者情報取得
            const userInfo = getUserInfo(
              state.staffList,
              medicItem.effect_user_id
            );
            if (userInfo.upDate != null) {
              const fDate = new Date(userInfo.upDate);
              update = dateFormat.utc2Jst(fDate);
            }
          } else {
            medicItem.effect_user_id = null;
          }

          // 編集前データ取得
          let rowData = getOldData(
            state.selectOrdMain.rstMediInfo,
            medicItem.no
          );
          // 投与実施フラグ, ※0：未実施、1：実施済み
          rowData.reg_effect_flg = effectFlg;
          // 投与実施日時, ※ISO8601形式
          rowData.reg_effect_date = medicItem.effect_date;
          // 投与実施者コード
          rowData.reg_effect_user_id = medicItem.effect_user_id;
          // 投与実施者更新日時
          rowData.reg_effect_user_up_date = update;

          regMediData.push(rowData);
        }
      }

      let regData = {
        ordNo: state.selectOrdNo,
        rstMediInfo: ""
      };
      // 設定内容(JSON→文字列)
      regData.rstMediInfo = JSON.stringify(regMediData);
      // 登録結果
      let response = await sendRequestUpdateOrdMainMediInfo(regData);

      // 登録成功
      if (response.status == 200) {
        // 登録失敗情報がある場合
        if (response.data.errorDataList != null) {
          let errData = JSON.parse(response.data.errorDataList);
          let errMessage =
            "以下の項目が更新されているため登録できませんでした。<br>";
          errData.forEach((value, index, array) => {
            errMessage += "・" + array[index].name + "<br>";
          });

          // エラーメッセージ表示
          return { result: false, message: errMessage };
        }

        return { result: true };
      } else {
        return { result: false, message: response?.data?.errorMessage ?? "登録に失敗しました。" };
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
    // ord_no
    setSelectOrdNo(state, payload) {
      state.selectOrdNo = payload.selectOrdNo;
    },
    // ord_main
    setSelectOrdMain(state, payload) {
      state.selectOrdMain = payload.selectOrdMain;
    },
    // 選択中の投与薬剤情報(編集前)
    setOldSelectMediList(state, payload) {
      state.old_selectMediList = payload.old_selectMediList;
    },
    // 選択中の投与薬剤情報(編集内容)
    setSelectMediList(state, payload) {
      state.selectMediList = payload.selectMediList;
    },
    setUserAccountInfo(state, payload) {
      state.userAccountInfo = payload.userAccountInfo;
    }
  }
};

/********** function **********/
// 編集前の投与薬剤情報取得
function getOldData(list, no) {
  let rData = null;
  list.forEach((value, idx, ary) => {
    if (ary[idx].no === no) {
      rData = ary[idx];
    }
  });
  return rData;
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
