/**
 * 治療条件画面の補液を表現するクラス
 */
import { CODES } from "@/constants/TreatmentRecord";
import { Master } from "@/models/common/master-selector-condition/Master";
import {
  numberToString,
  stringToNumber
} from "@/models/treatment-record/Helper";

export class Replacement {
  constructor(rstCondInfo = null,mstMedicine = null,mstMedicineMix = null) {
    if (rstCondInfo === null) {
      rstCondInfo = {};
    }

    // 薬剤マスタ or 調整薬剤マスタ
    let treatMedicine = null;
    const item = CODES.TREATMENT_CONDITION_ITEM;
    // 補液(19)
    const fluidReplacement = rstCondInfo[item.FLUID_REPLACEMENT.cd]
      ? rstCondInfo[item.FLUID_REPLACEMENT.cd]
      : this.createEmpty();
    // 補液量(20)
    const fluidReplacementAmount =
      rstCondInfo[item.FLUID_REPLACEMENT_AMOUNT.cd]
      ? rstCondInfo[item.FLUID_REPLACEMENT_AMOUNT.cd]
      : this.createEmpty();
    // 補液選択(21)
    const fluidReplacementTiming =
      rstCondInfo[item.FLUID_REPLACEMENT_TIMING.cd]
      ? rstCondInfo[item.FLUID_REPLACEMENT_TIMING.cd]
      : this.createEmpty();
    // 補液使用数(22)
    const fluidReplacementUseCount =
      rstCondInfo[item.FLUID_REPLACEMENT_USE_COUNT.cd]
      ? rstCondInfo[item.FLUID_REPLACEMENT_USE_COUNT.cd]
      : this.createEmpty();
    // 補液温度(23)
    const fluidReplacementTemperature =
      rstCondInfo[item.FLUID_REPLACEMENT_TEMPERATURE.cd]
      ? rstCondInfo[item.FLUID_REPLACEMENT_TEMPERATURE.cd]
      : this.createEmpty();
    // 補液速度(24)
    const fluidReplacementSpeed = rstCondInfo[item.FLUID_REPLACEMENT_SPEED.cd]
      ? rstCondInfo[item.FLUID_REPLACEMENT_SPEED.cd]
      : this.createEmpty();

    this.replacement = new Master(
      fluidReplacement.value,
      fluidReplacement.value_name_1
    );
    this.amount = fluidReplacementAmount.value;
    this.timing = numberToString(fluidReplacementTiming.value);
    this.useCount = fluidReplacementUseCount.value;
    this.unit = fluidReplacement.unit;
    this.useCountUnit = fluidReplacementUseCount.unit;
    this.temperature = fluidReplacementTemperature.value;
    this.speed = fluidReplacementSpeed.value ? Number(fluidReplacementSpeed.value) : fluidReplacementSpeed.value;

    // 補液 薬剤区分による取得先マスタ
    // mod #9973 shiyw  start
    //if(fluidReplacement.medicine_type === CODES.MEDICINE_TYPE.NORMAL.cd){
    if(fluidReplacement.medicine_type == CODES.MEDICINE_TYPE.NORMAL.cd){
      // mod #9973 shiyw  end
      treatMedicine = mstMedicine.find(
        medi => medi.medicineCd == fluidReplacement.value // mod #9973 value Number→文字列  shiyw
      );
      // mod #9973 shiyw  start
      //}else if(fluidReplacement.medicine_type === CODES.MEDICINE_TYPE.MIX.cd){
    }else if(fluidReplacement.medicine_type == CODES.MEDICINE_TYPE.MIX.cd){
      // mod #9973 shiyw  end
      treatMedicine = mstMedicineMix.find(
        medi => medi.medicineCd == fluidReplacement.value // mod #9973 value Number→文字列  shiyw
      );
    }
    // 薬剤コードに該当する薬剤マスタがある場合
    // modify 9351 by kangjie 20240218 start
    // if (treatMedicine) {
    // modify 9351 by kangjie 20240218 end
      //FNSI#5678-修正 治療条件のデータがマスタに参照ではなく、実績より取得。 del  ljx  start
      //this.replacement.name = treatMedicine.medicineName;
      //FNSI#5678-修正 治療条件のデータがマスタに参照ではなく、実績より取得。 del  ljx  end
      this.decPoint = treatMedicine ? treatMedicine.unitDecimalPointSecond : 0;
    // modify 9351 by kangjie 20240218 start
    // }
  // modify 9351 by kangjie 20240218 end

  }

  // mod #10824 透析液エリアの変更値設定修正 zkm start
//   /* modify by chamaojia 2024-01-31 [10196] "Value" assignment string --start */
//   /**
//    * 補液にReplacementモデルを反映.
//    * @param {*} updateObject 更新用オブジェクト
//    */
//   reflect(updateObject) {
//     const item = CODES.TREATMENT_CONDITION_ITEM;
//     const info = updateObject.rst_cond_info ? updateObject.rst_cond_info : {};
//     // mod FNSI-8156 治療条件を編集した際に、グレーなものを空の要素で作成しない、総合ビューア画面で未登録で表示するから。LJX START
//     // mod 9342 ljx start
//     /*    if (info[item.FLUID_REPLACEMENT.cd]) {
//           //info[item.FLUID_REPLACEMENT.cd] = this.createEmpty();
//           if (isNaN(this.replacement.cd) && (this.replacement.cd.slice(-1) === "$")){
//             // 調製薬剤
//             info[item.FLUID_REPLACEMENT.cd].value = this.replacement.cd.slice(0, -1);
//             info[item.FLUID_REPLACEMENT.cd].medicine_type = CODES.MEDICINE_TYPE.MIX.cd;
//           } else {
//             // 通常薬剤
//             info[item.FLUID_REPLACEMENT.cd].value = this.replacement.cd;
//             info[item.FLUID_REPLACEMENT.cd].medicine_type = CODES.MEDICINE_TYPE.NORMAL.cd;
//           }
//           info[item.FLUID_REPLACEMENT.cd].value_name_1 = this.replacement.name;
//         }*/
//     if (this.replacement.cd) {//「未登録」以外の値に変更する場合
//       info[item.FLUID_REPLACEMENT.cd] = this.createEmpty();
//       if (isNaN(this.replacement.cd) && (this.replacement.cd.slice(-1) === "$")){
//         // 調製薬剤
//         info[item.FLUID_REPLACEMENT.cd].value = this.replacement.cd.slice(0, -1);
//         info[item.FLUID_REPLACEMENT.cd].medicine_type = CODES.MEDICINE_TYPE.MIX.cd;
//       } else {
//         // 通常薬剤
//         info[item.FLUID_REPLACEMENT.cd].value = numberToString(this.replacement.cd);
//         info[item.FLUID_REPLACEMENT.cd].medicine_type = CODES.MEDICINE_TYPE.NORMAL.cd;
//       }
//       info[item.FLUID_REPLACEMENT.cd].value_name_1 = this.replacement.name;
//     }else if(this.replacement.name === ""){//「未登録」に変更する場合（nameが""）
//       info[item.FLUID_REPLACEMENT.cd] = this.createEmpty();
//       info[item.FLUID_REPLACEMENT.cd].value_name_1 = this.replacement.name;
//     }
//     /*    if (!info[item.FLUID_REPLACEMENT_AMOUNT.cd]) {
//           info[item.FLUID_REPLACEMENT_AMOUNT.cd] = this.createEmpty();
//         }
//         info[item.FLUID_REPLACEMENT_AMOUNT.cd].value = this.amount;*/
//     /*    if (info[item.FLUID_REPLACEMENT_AMOUNT.cd]) {
//           info[item.FLUID_REPLACEMENT_AMOUNT.cd].value = this.amount;
//         }*/
//     if (this.amount) {
//       info[item.FLUID_REPLACEMENT_AMOUNT.cd] = this.createEmpty();
//       info[item.FLUID_REPLACEMENT_AMOUNT.cd].value = numberToString(this.amount);
//     }else if(info[item.FLUID_REPLACEMENT_AMOUNT.cd]){
//       info[item.FLUID_REPLACEMENT_AMOUNT.cd].value = numberToString(this.amount);
//     }
//     /*if (!info[item.FLUID_REPLACEMENT_TIMING.cd]) {
//       info[item.FLUID_REPLACEMENT_TIMING.cd] = this.createEmpty();
//     }
//     info[item.FLUID_REPLACEMENT_TIMING.cd].value = stringToNumber(this.timing);*/
//     /*    if (info[item.FLUID_REPLACEMENT_TIMING.cd]) {
//           info[item.FLUID_REPLACEMENT_TIMING.cd].value = stringToNumber(this.timing);
//         }*/
//     if (this.timing) {
//       info[item.FLUID_REPLACEMENT_TIMING.cd] = this.createEmpty();
//       // mod #9973 shiyw start
//       // info[item.FLUID_REPLACEMENT_TIMING.cd].value = stringToNumber(this.timing);
//       info[item.FLUID_REPLACEMENT_TIMING.cd].value = this.timing;
//       // mod #9973 shiyw end
//     }
//
//     /*    if (!info[item.FLUID_REPLACEMENT_USE_COUNT.cd]) {
//           info[item.FLUID_REPLACEMENT_USE_COUNT.cd] = this.createEmpty();
//         }
//         info[item.FLUID_REPLACEMENT_USE_COUNT.cd].value = this.useCount;
//         info[item.FLUID_REPLACEMENT_USE_COUNT.cd].unit = this.useCountUnit;*/
//     /*    if (info[item.FLUID_REPLACEMENT_USE_COUNT.cd]) {
//           info[item.FLUID_REPLACEMENT_USE_COUNT.cd].value = this.useCount;
//           info[item.FLUID_REPLACEMENT_USE_COUNT.cd].unit = this.useCountUnit;
//         }*/
//     if (this.useCount) {
//       info[item.FLUID_REPLACEMENT_USE_COUNT.cd] = this.createEmpty();
//       info[item.FLUID_REPLACEMENT_USE_COUNT.cd].value = numberToString(this.useCount);
//       info[item.FLUID_REPLACEMENT_USE_COUNT.cd].unit = this.useCountUnit;
//     }else if(info[item.FLUID_REPLACEMENT_USE_COUNT.cd]){
//       info[item.FLUID_REPLACEMENT_USE_COUNT.cd].value = numberToString(this.useCount);
//       info[item.FLUID_REPLACEMENT_USE_COUNT.cd].unit = this.useCountUnit;
//     }
//     /*    if (!info[item.FLUID_REPLACEMENT_TEMPERATURE.cd]) {
//           info[item.FLUID_REPLACEMENT_TEMPERATURE.cd] = this.createEmpty();
//         }
//         info[item.FLUID_REPLACEMENT_TEMPERATURE.cd].value = this.temperature;*/
//     /*    if (info[item.FLUID_REPLACEMENT_TEMPERATURE.cd]) {
//           info[item.FLUID_REPLACEMENT_TEMPERATURE.cd].value = this.temperature;
//         }*/
//     if (this.temperature) {
//       info[item.FLUID_REPLACEMENT_TEMPERATURE.cd] = this.createEmpty();
//       info[item.FLUID_REPLACEMENT_TEMPERATURE.cd].value = numberToString(this.temperature);
//     }else if(info[item.FLUID_REPLACEMENT_TEMPERATURE.cd]){
//       info[item.FLUID_REPLACEMENT_TEMPERATURE.cd].value = numberToString(this.temperature);
//     }
//     /*    if (!info[item.FLUID_REPLACEMENT_SPEED.cd]) {
//           info[item.FLUID_REPLACEMENT_SPEED.cd] = this.createEmpty();
//         }
//         info[item.FLUID_REPLACEMENT_SPEED.cd].value = this.speed;*/
//     /*    if (info[item.FLUID_REPLACEMENT_SPEED.cd]) {
//           info[item.FLUID_REPLACEMENT_SPEED.cd].value = this.speed;
//         }*/
//     if (this.speed) {
//       info[item.FLUID_REPLACEMENT_SPEED.cd] = this.createEmpty();
//       info[item.FLUID_REPLACEMENT_SPEED.cd].value = numberToString(this.speed);
//     }else if(info[item.FLUID_REPLACEMENT_SPEED.cd]){
//       info[item.FLUID_REPLACEMENT_SPEED.cd].value = numberToString(this.speed);
//     }
//     // mod 9342 ljx end
// // mod FNSI-8156 治療条件を編集した際に、グレーなものを空の要素で作成しない、総合ビューア画面で未登録で表示するから。LJX END
//   }
//   /* modify by chamaojia 2024-01-31 [10196] "Value" assignment string --end */

  /**
   * 補液にReplacementモデルを反映.
   * @param copyObject 設定値
   * @param comparisonModel 変更する前の設定値
   * @param actualModel 変更した設定値
   */
  reflect(copyObject, comparisonModel, actualModel) {
    let rstCondInfo = copyObject.rst_cond_info;
    const item = CODES.TREATMENT_CONDITION_ITEM;
    const keys = Object.keys(comparisonModel);
    for (let key of keys) {
      if (!this.compareObjects(comparisonModel[key], actualModel[key])) {
        let unit = actualModel['useCountUnit'] ? actualModel['useCountUnit'] : null;
        let replacementUnit = actualModel['unit'] ? actualModel['unit'] : null;
        switch (key) {
          // 補液(19)
          case "replacement":
            rstCondInfo[item.FLUID_REPLACEMENT.cd] = this.getTemplateM();
            if (this.replacement.cd) {//「未登録」以外の値に変更する場合
              if (isNaN(this.replacement.cd) && (this.replacement.cd.slice(-1) === "$")){
                // 調製薬剤
                rstCondInfo[item.FLUID_REPLACEMENT.cd].value = this.replacement.cd.slice(0, -1);
                rstCondInfo[item.FLUID_REPLACEMENT.cd].medicine_type = CODES.MEDICINE_TYPE.MIX.cd;
              } else {
                // 通常薬剤
                rstCondInfo[item.FLUID_REPLACEMENT.cd].value = numberToString(this.replacement.cd);
                rstCondInfo[item.FLUID_REPLACEMENT.cd].medicine_type = CODES.MEDICINE_TYPE.NORMAL.cd;
              }
              rstCondInfo[item.FLUID_REPLACEMENT.cd].value_name_1 = this.replacement.name;
              rstCondInfo[item.FLUID_REPLACEMENT.cd].unit = replacementUnit;
              // 補液使用数(22)
              if (rstCondInfo[item.FLUID_REPLACEMENT_USE_COUNT.cd]) {
                rstCondInfo[item.FLUID_REPLACEMENT_USE_COUNT.cd].unit = unit;
              }
            }
            continue;
            // 補液量(20)
          case "amount":
            rstCondInfo[item.FLUID_REPLACEMENT_AMOUNT.cd] = this.createEmpty();
            rstCondInfo[item.FLUID_REPLACEMENT_AMOUNT.cd].value = numberToString(actualModel[key]);
            rstCondInfo[item.FLUID_REPLACEMENT_AMOUNT.cd].unit = "L";
            continue;
            // 補液選択(21)
          case "timing":
            rstCondInfo[item.FLUID_REPLACEMENT_TIMING.cd] = this.createEmpty();
            rstCondInfo[item.FLUID_REPLACEMENT_TIMING.cd].value = numberToString(actualModel[key]);
            rstCondInfo[item.FLUID_REPLACEMENT_TIMING.cd].value_name_1 = actualModel[key] === "1" ? "前補液" : actualModel[key] === "0" ? "後補液" : null;
            continue;
            // 補液使用数(22)
          case "useCount":
            rstCondInfo[item.FLUID_REPLACEMENT_USE_COUNT.cd] = this.createEmpty();
            rstCondInfo[item.FLUID_REPLACEMENT_USE_COUNT.cd].value = numberToString(actualModel[key]);
            if (rstCondInfo[item.FLUID_REPLACEMENT.cd] && rstCondInfo[item.FLUID_REPLACEMENT.cd].unit) {
              rstCondInfo[item.FLUID_REPLACEMENT_USE_COUNT.cd].unit = rstCondInfo[item.FLUID_REPLACEMENT.cd].unit
            } else {
              rstCondInfo[item.FLUID_REPLACEMENT_USE_COUNT.cd].unit = unit;
            }
            continue;
            // 補液温度(23)
          case "temperature":
            rstCondInfo[item.FLUID_REPLACEMENT_TEMPERATURE.cd] = this.createEmpty();
            rstCondInfo[item.FLUID_REPLACEMENT_TEMPERATURE.cd].value = numberToString(actualModel[key]);
            rstCondInfo[item.FLUID_REPLACEMENT_TEMPERATURE.cd].unit = "℃";
            continue;
            // 補液速度(24)
          case "speed":
            rstCondInfo[item.FLUID_REPLACEMENT_SPEED.cd] = this.createEmpty();
            rstCondInfo[item.FLUID_REPLACEMENT_SPEED.cd].value = numberToString(actualModel[key]);
            rstCondInfo[item.FLUID_REPLACEMENT_SPEED.cd].unit = "L/h";
            continue;
          case "unit":
            if (!rstCondInfo[item.FLUID_REPLACEMENT.cd]) {
              rstCondInfo[item.FLUID_REPLACEMENT.cd] = this.getTemplateM();
            }
            rstCondInfo[item.FLUID_REPLACEMENT.cd].unit = replacementUnit;
            continue;
          case "useCountUnit":
            if (!rstCondInfo[item.FLUID_REPLACEMENT_USE_COUNT.cd]) {
              rstCondInfo[item.FLUID_REPLACEMENT_USE_COUNT.cd] = this.createEmpty();
            }
            rstCondInfo[item.FLUID_REPLACEMENT_USE_COUNT.cd].unit = unit;
            continue;
        }
      }
    }
  }

  getTemplateM(){
    return {
      unit: null,
      value: null,
      input_class: 1,
      is_editable: "1",
      cop_order_no: null,
      value_name_1: null,
      medicine_type: null,
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
        return Number(obj1) === Number(obj2);
      }
      if (obj1 === '' && obj2 == null) {
        return true;
      }
      return obj1 === obj2;
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
  // mod #10824 透析液エリアの変更値設定修正 zkm end

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
}
