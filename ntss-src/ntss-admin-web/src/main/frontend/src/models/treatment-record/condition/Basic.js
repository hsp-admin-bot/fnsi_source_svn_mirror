/**
 * 治療条件画面の基本条件を表現するクラス
 */
import { CODES } from "@/constants/TreatmentRecord";
import { Master } from "@/models/common/master-selector-condition/Master";
import { dateFormat } from "@/functions/common/DateTimeUtils";
import {
  numberToString,
  stringToNumber
} from "@/models/treatment-record/Helper";

export class Basic {
  constructor(
    treatStartTime = null,
    rstCondInfo = null,
    dw = null
  ) {
    if (rstCondInfo === null) {
      rstCondInfo = {};
    }

    // null、undefinedデータをフォーマットしようとしてエラーになるのを防止
    if (treatStartTime !== null && treatStartTime !== undefined) {
      this.treatStartTime = dateFormat.char2time(treatStartTime);
    }

    const item = CODES.TREATMENT_CONDITION_ITEM;
    // VA(2)
    const va = rstCondInfo[item.VA.cd] ? rstCondInfo[item.VA.cd] : this.createEmpty();
    // 除水量制限(4)
    const limit = rstCondInfo[item.WATER_REMOVAL_AMOUNT_LIMIT.cd] ? rstCondInfo[item.WATER_REMOVAL_AMOUNT_LIMIT.cd] : this.createEmpty();
    // 目標体重(3)
    const weight = rstCondInfo[item.TARGET_WEIGHT.cd] ? rstCondInfo[item.TARGET_WEIGHT.cd] : this.createEmpty();
    // ダイアライザ(5)
    const dialyzer = rstCondInfo[item.DIALYZER.cd] ? rstCondInfo[item.DIALYZER.cd] : this.createEmpty();
    // 吸着カラム(6)
    const adsorption = rstCondInfo[item.ADSORPTION_COLUMN.cd] ? rstCondInfo[item.ADSORPTION_COLUMN.cd] : this.createEmpty();
    // 1次膜(7)
    const primary = rstCondInfo[item.PRIMARY_FILM.cd] ? rstCondInfo[item.PRIMARY_FILM.cd] : this.createEmpty();
    // 2次膜(8)
    const secondary = rstCondInfo[item.SECONDARY_FILM.cd] ? rstCondInfo[item.SECONDARY_FILM.cd] : this.createEmpty();
    // 穿刺針(A針)(9)
    const punctureA = rstCondInfo[item.PUNCTURE_NEEDLE_A.cd] ? rstCondInfo[item.PUNCTURE_NEEDLE_A.cd] : this.createEmpty();
    // 穿刺針(V針)(10)
    const punctureV = rstCondInfo[item.PUNCTURE_NEEDLE_V.cd] ? rstCondInfo[item.PUNCTURE_NEEDLE_V.cd] : this.createEmpty();
    // 穿刺針(SN針)(11)
    const punctureSn = rstCondInfo[item.PUNCTURE_NEEDLE_SN.cd] ? rstCondInfo[item.PUNCTURE_NEEDLE_SN.cd] : this.createEmpty();
    // 血液回路(13)
    // add FNSI-血液回路の修正 徐 start
    // const bc = rstCondInfo[item.PUNCTURE_NEEDLE_SN.cd] ? rstCondInfo[item.BLOOD_CIRCUIT.cd] : this.createEmpty();
    const bc = rstCondInfo[item.BLOOD_CIRCUIT.cd] ? rstCondInfo[item.BLOOD_CIRCUIT.cd] : this.createEmpty();
    // add FNSI-血液回路の修正 徐 end
    // 血流量(14)
    const blood = rstCondInfo[item.BLOOD_FLOW.cd] ? rstCondInfo[item.BLOOD_FLOW.cd] : this.createEmpty();
    // シングルニードル使用
    const singleNeedle = rstCondInfo[item.SINGLE_NEEDLE.cd] ? rstCondInfo[item.SINGLE_NEEDLE.cd] : this.createEmpty();
    // 治療時間
    if(!rstCondInfo[item.TREATMENT_TIME.cd]) {
      rstCondInfo[item.TREATMENT_TIME.cd] = this.createEmpty();
    }
    this.treatStartTime = dateFormat.mChar2time(rstCondInfo[item.TREATMENT_TIME.cd].value);
    this.va = new Master(va.value, va.value_name_1);
    this.dw = dw;
    this.waterRemovalAmountLimit = limit.value;
    this.targetWeight = weight.value;
    this.dialyzer = new Master(dialyzer.value, dialyzer.value_name_1);
    this.adsorptionColumn = new Master(
      adsorption.value,
      adsorption.value_name_1
    );
    this.primaryFilm = new Master(primary.value, primary.value_name_1);
    this.secondaryFilm = new Master(secondary.value, secondary.value_name_1);
    this.punctureNeedleA = new Master(punctureA.value, punctureA.value_name_1);
    this.punctureNeedleV = new Master(punctureV.value, punctureV.value_name_1);
    this.punctureNeedleSn = new Master(
      punctureSn.value,
      punctureSn.value_name_1
    );
    // 血液回路
    this.bloodCircuit = new Master(bc.value, bc.value_name_1);
    // 血流量
    this.bloodFlow = blood.value;
    // シングルニードル使用
    this.singleNeedle = numberToString(singleNeedle.value);
  }

  /* modify by chamaojia 2024-01-31 [10196] "Value" assignment string --start */
  /**
   * 基本条件にBasicモデルを反映.
   * @param {*} updateObject 更新用オブジェクト
   */
  // del 10824 治療記録>治療条件を編集するとord_mainのrst_cond_infの一部がnullになる 関 start
//   reflect(updateObject) {
//     // null、undefinedデータをフォーマットしようとしてエラーになるのを防止
//     if (this.treatStartTime !== null && this.treatStartTime !== undefined) {
//       updateObject.ind_treat_start_time = dateFormat.time2char(
//         this.treatStartTime
//       );
//     }
//     const item = CODES.TREATMENT_CONDITION_ITEM;
//     const info = updateObject.rst_cond_info ? updateObject.rst_cond_info : {};
//     if (!info[item.TREATMENT_TIME.cd]) {
//       info[item.TREATMENT_TIME.cd] = this.createEmpty();
//     }
//     if (this.treatStartTime !== null && this.treatStartTime !== undefined) {
//       info[item.TREATMENT_TIME.cd].value =  numberToString(dateFormat.time2MChar(this.treatStartTime));
//     }
//     // mod FNSI-8156 治療条件を編集した際に、グレーなものを空の要素で作成しない、総合ビューア画面で未登録で表示するから。LJX START
// // mod 9342 ljx start
//     /*    if (!info[item.VA.cd]) {
//           info[item.VA.cd] = this.createEmpty();
//         }
//         info[item.VA.cd].value = this.va.cd;
//         info[item.VA.cd].value_name_1 = this.va.name;*/
//     /*    if (info[item.VA.cd]) {
//           info[item.VA.cd].value = this.va.cd;
//           info[item.VA.cd].value_name_1 = this.va.name;
//         }*/
//     if(this.va.cd){//「未登録」以外の値に変更する場合
//       info[item.VA.cd] = this.createEmpty();
//       info[item.VA.cd].value = numberToString(this.va.cd);
//       info[item.VA.cd].value_name_1 = this.va.name;
//     }else if(this.va.name === ""){//「未登録」に変更する場合（nameが""）
//       info[item.VA.cd] = this.createEmpty();
//       info[item.VA.cd].value_name_1 = this.va.name;
//     }

//     /*    if (!info[item.WATER_REMOVAL_AMOUNT_LIMIT.cd]) {
//           info[item.WATER_REMOVAL_AMOUNT_LIMIT.cd] = this.createEmpty();
//         }
//         info[
//           item.WATER_REMOVAL_AMOUNT_LIMIT.cd
//         ].value = this.waterRemovalAmountLimit;*/
//     /*    if (info[item.WATER_REMOVAL_AMOUNT_LIMIT.cd]) {
//           info[
//             item.WATER_REMOVAL_AMOUNT_LIMIT.cd
//             ].value = this.waterRemovalAmountLimit;
//         }*/
//     if(this.waterRemovalAmountLimit){
//       info[item.WATER_REMOVAL_AMOUNT_LIMIT.cd] = this.createEmpty();
//       info[
//         item.WATER_REMOVAL_AMOUNT_LIMIT.cd
//         ].value = numberToString(this.waterRemovalAmountLimit);
//     }else if (info[item.WATER_REMOVAL_AMOUNT_LIMIT.cd]){
//       info[
//         item.WATER_REMOVAL_AMOUNT_LIMIT.cd
//         ].value = numberToString(this.waterRemovalAmountLimit);

//     }

//     /*    if (!info[item.TARGET_WEIGHT.cd]) {
//           info[item.TARGET_WEIGHT.cd] = this.createEmpty();
//         }
//         info[item.TARGET_WEIGHT.cd].value = this.targetWeight;*/
//     /*    if (info[item.TARGET_WEIGHT.cd]) {
//           info[item.TARGET_WEIGHT.cd].value = this.targetWeight;
//         }*/
//     if(this.targetWeight){
//       info[item.TARGET_WEIGHT.cd] = this.createEmpty();
//       info[item.TARGET_WEIGHT.cd].value = numberToString(this.targetWeight);
//     }else if(info[item.TARGET_WEIGHT.cd]){
//       info[item.TARGET_WEIGHT.cd].value = numberToString(this.targetWeight);
//     }

//     /*    if (!info[item.DIALYZER.cd]) {
//           info[item.DIALYZER.cd] = this.createEmpty();
//         }
//         info[item.DIALYZER.cd].value = this.dialyzer.cd;
//         info[item.DIALYZER.cd].value_name_1 = this.dialyzer.name;*/
//     /*    if (info[item.DIALYZER.cd]) {
//           info[item.DIALYZER.cd].value = this.dialyzer.cd;
//           info[item.DIALYZER.cd].value_name_1 = this.dialyzer.name;
//         }*/
//     if(this.dialyzer.cd){//「未登録」以外の値に変更する場合
//       info[item.DIALYZER.cd] = this.createEmpty();
//       info[item.DIALYZER.cd].value = numberToString(this.dialyzer.cd);
//       info[item.DIALYZER.cd].value_name_1 = this.dialyzer.name;
//     }else if(this.dialyzer.name === ""){//「未登録」に変更する場合（nameが""）
//       info[item.DIALYZER.cd] = this.createEmpty();
//       info[item.DIALYZER.cd].value_name_1 = this.dialyzer.name;
//     }

//     /*    if (!info[item.ADSORPTION_COLUMN.cd]) {
//           info[item.ADSORPTION_COLUMN.cd] = this.createEmpty();
//         }
//         info[item.ADSORPTION_COLUMN.cd].value = this.adsorptionColumn.cd;
//         info[item.ADSORPTION_COLUMN.cd].value_name_1 = this.adsorptionColumn.name;*/
//     /*    if (info[item.ADSORPTION_COLUMN.cd]) {
//           info[item.ADSORPTION_COLUMN.cd].value = this.adsorptionColumn.cd;
//           info[item.ADSORPTION_COLUMN.cd].value_name_1 = this.adsorptionColumn.name;
//         }*/
//     if(this.adsorptionColumn.cd){//「未登録」以外の値に変更する場合
//       info[item.ADSORPTION_COLUMN.cd] = this.createEmpty();
//       info[item.ADSORPTION_COLUMN.cd].value = numberToString(this.adsorptionColumn.cd);
//       info[item.ADSORPTION_COLUMN.cd].value_name_1 = this.adsorptionColumn.name;
//     }else if(this.adsorptionColumn.name === ""){//「未登録」に変更する場合（nameが""）
//       info[item.ADSORPTION_COLUMN.cd] = this.createEmpty();
//       info[item.ADSORPTION_COLUMN.cd].value_name_1 = this.adsorptionColumn.name;
//     }

//     /*    if (!info[item.PRIMARY_FILM.cd]) {
//           info[item.PRIMARY_FILM.cd] = this.createEmpty();
//         }
//         info[item.PRIMARY_FILM.cd].value = this.primaryFilm.cd;
//         info[item.PRIMARY_FILM.cd].value_name_1 = this.primaryFilm.name;*/
//     /*    if (info[item.PRIMARY_FILM.cd]) {
//           info[item.PRIMARY_FILM.cd].value = this.primaryFilm.cd;
//           info[item.PRIMARY_FILM.cd].value_name_1 = this.primaryFilm.name;
//         }*/
//     if(this.primaryFilm.cd){//「未登録」以外の値に変更する場合
//       info[item.PRIMARY_FILM.cd] = this.createEmpty();
//       info[item.PRIMARY_FILM.cd].value = numberToString(this.primaryFilm.cd);
//       info[item.PRIMARY_FILM.cd].value_name_1 = this.primaryFilm.name;
//     }else if(this.primaryFilm.name === ""){//「未登録」に変更する場合（nameが""）
//       info[item.PRIMARY_FILM.cd] = this.createEmpty();
//       info[item.PRIMARY_FILM.cd].value_name_1 = this.primaryFilm.name;
//     }

//     /*    if (!info[item.SECONDARY_FILM.cd]) {
//           info[item.SECONDARY_FILM.cd] = this.createEmpty();
//         }
//         info[item.SECONDARY_FILM.cd].value = this.secondaryFilm.cd;
//         info[item.SECONDARY_FILM.cd].value_name_1 = this.secondaryFilm.name;*/
//     /*    if (info[item.SECONDARY_FILM.cd]) {
//           info[item.SECONDARY_FILM.cd].value = this.secondaryFilm.cd;
//           info[item.SECONDARY_FILM.cd].value_name_1 = this.secondaryFilm.name;
//         }*/
//     if(this.secondaryFilm.cd){//「未登録」以外の値に変更する場合
//       info[item.SECONDARY_FILM.cd] = this.createEmpty();
//       info[item.SECONDARY_FILM.cd].value = numberToString(this.secondaryFilm.cd);
//       info[item.SECONDARY_FILM.cd].value_name_1 = this.secondaryFilm.name;
//     }else if(this.secondaryFilm.name === ""){//「未登録」に変更する場合（nameが""）
//       info[item.SECONDARY_FILM.cd] = this.createEmpty();
//       info[item.SECONDARY_FILM.cd].value_name_1 = this.secondaryFilm.name;
//     }

//     /*    if (!info[item.PUNCTURE_NEEDLE_A.cd]) {
//           info[item.PUNCTURE_NEEDLE_A.cd] = this.createEmpty();
//         }
//         info[item.PUNCTURE_NEEDLE_A.cd].value = this.punctureNeedleA.cd;
//         info[item.PUNCTURE_NEEDLE_A.cd].value_name_1 = this.punctureNeedleA.name;*/
//     /*    if (info[item.PUNCTURE_NEEDLE_A.cd]) {
//           info[item.PUNCTURE_NEEDLE_A.cd].value = this.punctureNeedleA.cd;
//           info[item.PUNCTURE_NEEDLE_A.cd].value_name_1 = this.punctureNeedleA.name;
//         }*/
//     if(this.punctureNeedleA.cd){//「未登録」以外の値に変更する場合
//       info[item.PUNCTURE_NEEDLE_A.cd] = this.createEmpty();
//       info[item.PUNCTURE_NEEDLE_A.cd].value = numberToString(this.punctureNeedleA.cd);
//       info[item.PUNCTURE_NEEDLE_A.cd].value_name_1 = this.punctureNeedleA.name;
//     }else if(this.punctureNeedleA.name === ""){//「未登録」に変更する場合（nameが""）
//       info[item.PUNCTURE_NEEDLE_A.cd] = this.createEmpty();
//     }

//     /*    if (!info[item.PUNCTURE_NEEDLE_V.cd]) {
//           info[item.PUNCTURE_NEEDLE_V.cd] = this.createEmpty();
//         }
//         info[item.PUNCTURE_NEEDLE_V.cd].value = this.punctureNeedleV.cd;
//         info[item.PUNCTURE_NEEDLE_V.cd].value_name_1 = this.punctureNeedleV.name;*/
//     /*    if (info[item.PUNCTURE_NEEDLE_V.cd]) {
//           info[item.PUNCTURE_NEEDLE_V.cd].value = this.punctureNeedleV.cd;
//           info[item.PUNCTURE_NEEDLE_V.cd].value_name_1 = this.punctureNeedleV.name;
//         }*/
//     if(this.punctureNeedleV.cd){//「未登録」以外の値に変更する場合
//       info[item.PUNCTURE_NEEDLE_V.cd] = this.createEmpty();
//       info[item.PUNCTURE_NEEDLE_V.cd].value = numberToString(this.punctureNeedleV.cd);
//       info[item.PUNCTURE_NEEDLE_V.cd].value_name_1 = this.punctureNeedleV.name;
//     }else if(this.punctureNeedleV.name === ""){//「未登録」に変更する場合（nameが""）
//       info[item.PUNCTURE_NEEDLE_V.cd] = this.createEmpty();
//     }

//     /*    if (!info[item.PUNCTURE_NEEDLE_SN.cd]) {
//           info[item.PUNCTURE_NEEDLE_SN.cd] = this.createEmpty();
//         }
//         info[item.PUNCTURE_NEEDLE_SN.cd].value = this.punctureNeedleSn.cd;
//         info[item.PUNCTURE_NEEDLE_SN.cd].value_name_1 = this.punctureNeedleSn.name;*/
//     /*    if (info[item.PUNCTURE_NEEDLE_SN.cd]) {
//           info[item.PUNCTURE_NEEDLE_SN.cd].value = this.punctureNeedleSn.cd;
//           info[item.PUNCTURE_NEEDLE_SN.cd].value_name_1 = this.punctureNeedleSn.name;
//         }*/
//     if(this.punctureNeedleSn.cd){//「未登録」以外の値に変更する場合
//       info[item.PUNCTURE_NEEDLE_SN.cd] = this.createEmpty();
//       info[item.PUNCTURE_NEEDLE_SN.cd].value = numberToString(this.punctureNeedleSn.cd);
//       info[item.PUNCTURE_NEEDLE_SN.cd].value_name_1 = this.punctureNeedleSn.name;
//     }else if(this.punctureNeedleSn.name === ""){//「未登録」に変更する場合（nameが""）
//       info[item.PUNCTURE_NEEDLE_SN.cd] = this.createEmpty();
//       info[item.PUNCTURE_NEEDLE_SN.cd].value_name_1 = this.punctureNeedleSn.name;
//     }

//     /*    if (!info[item.BLOOD_FLOW.cd]) {
//           info[item.BLOOD_FLOW.cd] = this.createEmpty();
//         }

//         if (!info[item.BLOOD_CIRCUIT.cd]) {
//           info[item.BLOOD_CIRCUIT.cd] = this.createEmpty();
//         }*/

//     // 血液回路
//     // add FNSI-血液回路の修正 徐 start
//     // info[item.BLOOD_CIRCUIT.cd].value = this.bloodCircuit.cd;
//     // info[item.BLOOD_CIRCUIT.cd].value_name_1 = this.bloodCircuit.name;
//     /*    if (info[item.BLOOD_CIRCUIT.cd] !== undefined) {
//           info[item.BLOOD_CIRCUIT.cd].value = this.bloodCircuit.cd;
//           info[item.BLOOD_CIRCUIT.cd].value_name_1 = this.bloodCircuit.name;
//         }*/
//     if(this.bloodCircuit.cd){//「未登録」以外の値に変更する場合
//       info[item.BLOOD_CIRCUIT.cd] = this.createEmpty();
//       info[item.BLOOD_CIRCUIT.cd].value = this.bloodCircuit.cd;
//       info[item.BLOOD_CIRCUIT.cd].value_name_1 = this.bloodCircuit.name;
//     }else if(this.bloodCircuit.name === ""){//「未登録」に変更する場合（nameが""）
//       info[item.BLOOD_CIRCUIT.cd] = this.createEmpty();
//       info[item.BLOOD_CIRCUIT.cd].value_name_1 = this.bloodCircuit.name;
//     }
//     // add FNSI-血液回路の修正 徐 end
//     /*    if (info[item.BLOOD_FLOW.cd]) {
//           info[item.BLOOD_FLOW.cd].value = this.bloodFlow;
//         }*/
//     if(this.bloodFlow){
//       info[item.BLOOD_FLOW.cd] = this.createEmpty();
//       info[item.BLOOD_FLOW.cd].value = numberToString(this.bloodFlow);
//     }else if(info[item.BLOOD_FLOW.cd]){
//       info[item.BLOOD_FLOW.cd].value = numberToString(this.bloodFlow);
//     }


//     // シングルニードル使用
//     /*    if (!info[item.SINGLE_NEEDLE.cd]) {
//           info[item.SINGLE_NEEDLE.cd] = this.createEmpty();
//         }
//         info[item.SINGLE_NEEDLE.cd].value = stringToNumber(this.singleNeedle);*/
//     /*    if (info[item.SINGLE_NEEDLE.cd]) {
//           info[item.SINGLE_NEEDLE.cd].value = stringToNumber(this.singleNeedle);
//         }*/
//     if(this.singleNeedle){
//       info[item.SINGLE_NEEDLE.cd] = this.createEmpty();
//       info[item.SINGLE_NEEDLE.cd].value = this.singleNeedle;
//     }
//     // mod FNSI-8156 治療条件を編集した際に、グレーなものを空の要素で作成しない、総合ビューア画面で未登録で表示するから。LJX END

//     // シングルシードルを使用する場合、A針V針の情報はクリアする
//     // シングルニードを使用しない場合には、SN針の情報をクリアする
//     /* modify by chamaojia 2023-10-27 [9973] A針/V針とSN針排他処理 --start */
//     if (this.singleNeedle === CODES.CHECK.OFF.cd) {
//       delete info[item.PUNCTURE_NEEDLE_SN.cd];
//       if (!info[item.PUNCTURE_NEEDLE_A.cd]) {
//         info[item.PUNCTURE_NEEDLE_A.cd] = this.createEmpty();
//       }
//       if (!info[item.PUNCTURE_NEEDLE_V.cd]) {
//         info[item.PUNCTURE_NEEDLE_V.cd] = this.createEmpty();
//       }
//       // info[item.PUNCTURE_NEEDLE_SN.cd] = this.createEmpty();
//       // info[item.PUNCTURE_NEEDLE_SN.cd].value = null;
//       // info[item.PUNCTURE_NEEDLE_SN.cd].value_name_1 = null;
//     } else if (this.singleNeedle === CODES.CHECK.ON.cd) {
//       delete info[item.PUNCTURE_NEEDLE_A.cd];
//       delete info[item.PUNCTURE_NEEDLE_V.cd];
//       if (!info[item.PUNCTURE_NEEDLE_SN.cd]) {
//         info[item.PUNCTURE_NEEDLE_SN.cd] = this.createEmpty();
//       }
//       // info[item.PUNCTURE_NEEDLE_A.cd] = this.createEmpty();
//       // info[item.PUNCTURE_NEEDLE_V.cd] = this.createEmpty();
//       // info[item.PUNCTURE_NEEDLE_A.cd].value = null;
//       // info[item.PUNCTURE_NEEDLE_A.cd].value_name_1 = null;
//       // info[item.PUNCTURE_NEEDLE_V.cd].value = null;
//       // info[item.PUNCTURE_NEEDLE_V.cd].value_name_1 = null;
//     }
//     /* modify by chamaojia 2023-10-27 [9973] A針/V針とSN針排他処理 --end */
//     // mod 9342 ljx end
//   }
  /* modify by chamaojia 2024-01-31 [10196] "Value" assignment string --end */
// del 10824 治療記録>治療条件を編集するとord_mainのrst_cond_infの一部がnullになる 関 end
  /**
   * 空の要素を作成
   */
  createEmpty() {
    return {
      unit: null,
      value: null,
      input_class: CODES.CONDITION_INPUT_CLASS.CLIENT.cd,
      is_editable: CODES.IS_EDITABLE.POSSIBLE.cd,
      cop_order_no: null,
      value_name_1: null,
      /* del by chamaojia 2024-01-30 [10196] Delete unnecessary attributes  --start */
      // value_name_2: null,
      // value_name_3: null,
      // value_name_4: null,
      // value_name_5: null,
      // value_name_6: null,
      // value_name_7: null,
      // value_name_8: null,
      // value_name_9: null,
      // value_name_10: null,
      // medicine_type: null,
      // ind_user_id: null,
      // ind_user_last_name: null,
      // ind_user_first_name: null,
      // upd_user_id: null,
      // upd_user_last_name: null,
      // upd_user_first_name: null
      /* del by chamaojia 2024-01-30 [10196] Delete unnecessary attributes  --end */
    };
  }
  // add 10824 治療記録>治療条件を編集するとord_mainのrst_cond_infの一部がnullになる 関 start
  reflect(copyObject, comparisonModel, actualModel, dialyzerInfo, equipmentInfo) {
    let rstCondInfo = copyObject.rst_cond_info;
    const item = CODES.TREATMENT_CONDITION_ITEM;
     const keys = Object.keys(comparisonModel);
     for (let key of keys) {
       if (!this.compareObjects(comparisonModel[key], actualModel[key])) {
         switch (key) {
           case "treatStartTime":
            rstCondInfo[item.TREATMENT_TIME.cd] = this.getTemplate();
            rstCondInfo[item.TREATMENT_TIME.cd].value =  numberToString(dateFormat.time2MChar(actualModel[key]));
            rstCondInfo[item.TREATMENT_TIME.cd].unit = "分";
            continue;
           case "va":
            if(this.va.cd){//「未登録」以外の値に変更する場合
              rstCondInfo[item.VA.cd] = this.getTemplate();
              rstCondInfo[item.VA.cd].value = numberToString(actualModel[key].cd);
              rstCondInfo[item.VA.cd].value_name_1 = actualModel[key].name;
            }else if(this.va.name === ""){//「未登録」に変更する場合（nameが""
              rstCondInfo[item.VA.cd] = this.createEmpty();
            }
            continue;
           case "waterRemovalAmountLimit":
            rstCondInfo[item.WATER_REMOVAL_AMOUNT_LIMIT.cd] = this.getTemplate();
            rstCondInfo[item.WATER_REMOVAL_AMOUNT_LIMIT.cd].value = numberToString(actualModel[key]);
            rstCondInfo[item.WATER_REMOVAL_AMOUNT_LIMIT.cd].unit = "L";
            continue;
           case "targetWeight":
            rstCondInfo[item.TARGET_WEIGHT.cd] = this.getTemplate();
            rstCondInfo[item.TARGET_WEIGHT.cd].value = numberToString(actualModel[key]);
            rstCondInfo[item.TARGET_WEIGHT.cd].unit = "Kg";
            continue;
           case "dialyzer":
            if(this.dialyzer.cd){//「未登録」以外の値に変更する場合
              let maker = dialyzerInfo.filter(d => {
                return d.dialyzerCd === actualModel[key].cd;})[0].maker;
              rstCondInfo[item.DIALYZER.cd] = this.getTemplateD();
              rstCondInfo[item.DIALYZER.cd].value = numberToString(actualModel[key].cd);
              rstCondInfo[item.DIALYZER.cd].value_name_1 = actualModel[key].name;
              rstCondInfo[item.DIALYZER.cd].value_name_2 = maker;
              rstCondInfo[item.DIALYZER.cd].unit = "本";
            }else if(this.dialyzer.name === ""){//「未登録」に変更する場合（nameが""
              rstCondInfo[item.DIALYZER.cd] = this.getTemplateD();
              rstCondInfo[item.DIALYZER.cd].unit = "本";
            }
            continue;
           case "adsorptionColumn":
            if(this.adsorptionColumn.cd){//「未登録」以外の値に変更する場合
              let unit6 = equipmentInfo.filter(e => {
                return e.equipmentCd === actualModel[key].cd;})[0].unit;
              rstCondInfo[item.ADSORPTION_COLUMN.cd] = this.getTemplate();
              rstCondInfo[item.ADSORPTION_COLUMN.cd].value = numberToString(actualModel[key].cd);
              rstCondInfo[item.ADSORPTION_COLUMN.cd].value_name_1 = actualModel[key].name;
              rstCondInfo[item.ADSORPTION_COLUMN.cd].unit = unit6;
            }else if(this.adsorptionColumn.name === ""){//「未登録」に変更する場合（nameが""）
              rstCondInfo[item.ADSORPTION_COLUMN.cd] = this.createEmpty();
            }
            continue;
           case "primaryFilm":
            if(this.primaryFilm.cd){//「未登録」以外の値に変更する場合
              let unit7 = equipmentInfo.filter(e => {
                return e.equipmentCd === actualModel[key].cd;})[0].unit;
              rstCondInfo[item.PRIMARY_FILM.cd] = this.getTemplate();
              rstCondInfo[item.PRIMARY_FILM.cd].value = numberToString(actualModel[key].cd);
              rstCondInfo[item.PRIMARY_FILM.cd].value_name_1 = actualModel[key].name;
              rstCondInfo[item.PRIMARY_FILM.cd].unit = unit7;
            }else if(this.primaryFilm.name === ""){//「未登録」に変更する場合（nameが""）
              rstCondInfo[item.PRIMARY_FILM.cd] = this.createEmpty();
            }
            continue;
           case "secondaryFilm":
            if(this.secondaryFilm.cd){//「未登録」以外の値に変更する場合
              let unit8 = equipmentInfo.filter(e => {
                return e.equipmentCd === actualModel[key].cd;})[0].unit;
              rstCondInfo[item.SECONDARY_FILM.cd] = this.getTemplate();
              rstCondInfo[item.SECONDARY_FILM.cd].value = numberToString(actualModel[key].cd);
              rstCondInfo[item.SECONDARY_FILM.cd].value_name_1 = actualModel[key].name;
              rstCondInfo[item.SECONDARY_FILM.cd].unit = unit8;
            }else if(this.secondaryFilm.name === ""){//「未登録」に変更する場合（nameが""）
              rstCondInfo[item.SECONDARY_FILM.cd] = this.createEmpty();
            }
            continue;
           case "punctureNeedleA":
            if(this.punctureNeedleA.cd){//「未登録」以外の値に変更する場合
              let unit9 = equipmentInfo.filter(e => {
                return e.equipmentCd === actualModel[key].cd;})[0].unit;
              rstCondInfo[item.PUNCTURE_NEEDLE_A.cd] = this.getTemplate();
              rstCondInfo[item.PUNCTURE_NEEDLE_A.cd].value = numberToString(actualModel[key].cd);
              rstCondInfo[item.PUNCTURE_NEEDLE_A.cd].value_name_1 = actualModel[key].name;
              rstCondInfo[item.PUNCTURE_NEEDLE_A.cd].unit = unit9;
              if ((comparisonModel["singleNeedle"] == null || comparisonModel["singleNeedle"] == "1") && this.compareObjects(comparisonModel["punctureNeedleV"], actualModel["punctureNeedleV"])) {
                rstCondInfo[item.PUNCTURE_NEEDLE_V.cd] = this.getTemplate();
              }
            }else if(this.punctureNeedleA.name === ""){//「未登録」に変更する場合（nameが""）
              rstCondInfo[item.PUNCTURE_NEEDLE_A.cd] = this.createEmpty();
            }
            continue;
           case "punctureNeedleV":
            if(this.punctureNeedleV.cd){
              let unit10 = equipmentInfo.filter(e => {
                return e.equipmentCd === actualModel[key].cd;})[0].unit;
              rstCondInfo[item.PUNCTURE_NEEDLE_V.cd] = this.getTemplate();
              rstCondInfo[item.PUNCTURE_NEEDLE_V.cd].value = numberToString(actualModel[key].cd);
              rstCondInfo[item.PUNCTURE_NEEDLE_V.cd].value_name_1 = actualModel[key].name;
              rstCondInfo[item.PUNCTURE_NEEDLE_V.cd].unit = unit10;
              if ((comparisonModel["singleNeedle"] == null || comparisonModel["singleNeedle"] == "1")&& this.compareObjects(comparisonModel["punctureNeedleA"], actualModel["punctureNeedleA"])) {
                rstCondInfo[item.PUNCTURE_NEEDLE_A.cd] = this.getTemplate();
              }
            }else if (this.punctureNeedleV.name === "") {
              rstCondInfo[item.PUNCTURE_NEEDLE_V.cd] = this.createEmpty();
            }
            continue;
           case "punctureNeedleSn":
            if (this.punctureNeedleSn.cd) {
              let unit11 = equipmentInfo.filter(e => {
                return e.equipmentCd === actualModel[key].cd;})[0].unit;
              rstCondInfo[item.PUNCTURE_NEEDLE_SN.cd] = this.getTemplate();
              rstCondInfo[item.PUNCTURE_NEEDLE_SN.cd].value = numberToString(actualModel[key].cd);
              rstCondInfo[item.PUNCTURE_NEEDLE_SN.cd].value_name_1 = actualModel[key].name;
              rstCondInfo[item.PUNCTURE_NEEDLE_SN.cd].unit = unit11;
            }else if (this.punctureNeedleSn.name === "") {
              rstCondInfo[item.PUNCTURE_NEEDLE_SN.cd] = this.createEmpty();
            }
            continue;
           case "bloodCircuit":
            if (this.bloodCircuit.cd) {
              let unit13 = equipmentInfo.filter(e => {
                return e.equipmentCd === actualModel[key].cd;})[0].unit;
              rstCondInfo[item.BLOOD_CIRCUIT.cd] = this.getTemplate();
              rstCondInfo[item.BLOOD_CIRCUIT.cd].value = numberToString(actualModel[key].cd);
              rstCondInfo[item.BLOOD_CIRCUIT.cd].value_name_1 = actualModel[key].name;
              rstCondInfo[item.BLOOD_CIRCUIT.cd].unit = unit13;
            }else if (this.bloodCircuit.name === "") {
              rstCondInfo[item.BLOOD_CIRCUIT.cd] = this.createEmpty();
            }
            continue;
           case "bloodFlow":
            rstCondInfo[item.BLOOD_FLOW.cd] = this.getTemplate();
            rstCondInfo[item.BLOOD_FLOW.cd].value = numberToString(actualModel[key]);
            rstCondInfo[item.BLOOD_FLOW.cd].unit = "mL/min";
            continue;
           case "singleNeedle":
            rstCondInfo[item.SINGLE_NEEDLE.cd] = this.getTemplate();
            rstCondInfo[item.SINGLE_NEEDLE.cd].value = numberToString(actualModel[key]);
            if (actualModel[key] == "1" ) {
              rstCondInfo[item.SINGLE_NEEDLE.cd].value_name_1 = "使用する";
              delete rstCondInfo[item.PUNCTURE_NEEDLE_A.cd];
              delete rstCondInfo[item.PUNCTURE_NEEDLE_V.cd];
              if (rstCondInfo[item.PUNCTURE_NEEDLE_SN.cd] == undefined) {
                rstCondInfo[item.PUNCTURE_NEEDLE_SN.cd] = this.getTemplate();
              }
            }else if (actualModel[key] == "0" ) {
              rstCondInfo[item.SINGLE_NEEDLE.cd].value_name_1 = "使用しない";
              delete rstCondInfo[item.PUNCTURE_NEEDLE_SN.cd];
              if (rstCondInfo[item.PUNCTURE_NEEDLE_V.cd] == undefined) {
                rstCondInfo[item.PUNCTURE_NEEDLE_V.cd] = this.getTemplate();
              }
              if (rstCondInfo[item.PUNCTURE_NEEDLE_A.cd] == undefined) {
                rstCondInfo[item.PUNCTURE_NEEDLE_A.cd] = this.getTemplate();
              }
            }
            continue;
         }
       }
     }
   }
   getTemplate(){
     return {
     unit: null,
     value: null,
     input_class: 1,
     is_editable: "1",
     cop_order_no: null,
     value_name_1: null,
     }
   }
   getTemplateD(){
     return {
     unit: null,
     value: null,
     input_class: 1,
     is_editable: "1",
     cop_order_no: null,
     value_name_1: null,
     value_name_2: null,
     }
   }
   compareObjects(obj1, obj2) {
    if (this.isJSON(obj1)) {
      obj1 = JSON.parse(obj1)
    }
    if (this.isJSON(obj2)) {
      obj2 = JSON.parse(obj2)
    }

    // 基本型(文字列、数字など)の場合は、そのまま等価比較をします。
    if (!this.isObject(obj1)) {
      if (this.isNumber(obj1) && this.isNumber(obj2)) {
        return Number(obj1) == Number(obj2);
      }
      if (obj1 == '' && obj2 == null) {
        return true;
      }
      return obj1 == obj2;
    }

    if (obj1.length !== obj2.length) {
      return false;
    }
    // 1つ目のオブジェクトの属性名を全て取得します
    const keys = Object.keys(obj1);
    // 属性を横断して深さを比較します
    for (let key of keys) {
      if (!this.compareObjects(obj1[key], obj2[key])) {
        return false;
      }
    }
    return true;
  }
  isJSON(str) {
    try {
      JSON.parse(str);
      return true;
    } catch (e) {
      return false;
    }
  }
  isObject(value) {
    return value && typeof value === 'object';
  }
  isNumber(str) {
    return !isNaN(parseFloat(str)) && isFinite(str);
  }
  // add 10824 治療記録>治療条件を編集するとord_mainのrst_cond_infの一部がnullになる 関 end
}
