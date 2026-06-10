/**
 * 治療条件画面の透析液を表現するクラス
 */
import { CODES } from "@/constants/TreatmentRecord";
import { Master } from "@/models/common/master-selector-condition/Master";
import {numberToString} from "@/models/treatment-record/Helper";

export class Dialysate {
  /* modify by chamaojia 2024-01-31 [10196] "Value" assignment string --start */
  constructor(rstCondInfo = null,mstMedicine = null,mstMedicineMix = null) {
    if (rstCondInfo === null) {
      rstCondInfo = {};
    }

    // 薬剤マスタ or 調整薬剤マスタ
    let treatMedicine = null;
    const item = CODES.TREATMENT_CONDITION_ITEM;
    // 透析液(15)
    const dialysateData = rstCondInfo[item.DIALYSATE.cd]
      ? rstCondInfo[item.DIALYSATE.cd]
      : this.createEmpty();
    // 透析液流量(16)
    const dialysateFlowRateData = rstCondInfo[item.DIALYSATE_FLOW_RATE.cd]
      ? rstCondInfo[item.DIALYSATE_FLOW_RATE.cd]
      : this.createEmpty();
    // 透析液使用数(17)
    const dialysateAmountData = rstCondInfo[item.DIALYSATE_AMOUNT.cd]
      ? rstCondInfo[item.DIALYSATE_AMOUNT.cd]
       : this.createEmpty();
    // 透析液温度(18)
    const dialysateTemperatureData = rstCondInfo[item.DIALYSATE_TEMPERATURE.cd]
      ? rstCondInfo[item.DIALYSATE_TEMPERATURE.cd]
      : this.createEmpty();

    this.dialysate = new Master(
      dialysateData.value,
      dialysateData.value_name_1
    );
    this.flowRate = dialysateFlowRateData.value;
    this.amount = dialysateAmountData.value;
    // TODO:単位の値は元となる薬剤コードのjsonに持たせるのか表示する薬剤使用数のjsonに持たせるのか回答待ち
    // modify 9351 by kangjie 20240220 start
    // this.amountUnit = dialysateData.unit ? dialysateData.unit : dialysateAmountData.unit;
    this.amountUnit = dialysateAmountData.unit;
    // modify 9351 by kangjie 20240220 end
    this.temperature = dialysateTemperatureData.value;

    // 透析液 薬剤区分によるマスタ
    // mod #9973 shiyw  start
    //if(dialysateData.medicine_type === CODES.MEDICINE_TYPE.NORMAL.cd){
    if(dialysateData.medicine_type == CODES.MEDICINE_TYPE.NORMAL.cd){
      // mod #9973 shiyw  end
      treatMedicine = mstMedicine.find(
        medi => medi.medicineCd == dialysateData.value // mod #9973 value Number→文字列  shiyw
      );
      // mod #9973 shiyw  start
      //}else if(dialysateData.medicine_type === CODES.MEDICINE_TYPE.MIX.cd){
    }else if(dialysateData.medicine_type == CODES.MEDICINE_TYPE.MIX.cd){
      // mod #9973 shiyw  end
      treatMedicine = mstMedicineMix.find(
        medi => medi.medicineCd == dialysateData.value // mod #9973 value Number→文字列  shiyw
      );
    }
    // 薬剤コードに該当する薬剤マスタがある場合
    // modify 9351 by kangjie 20240218 start
    // if (treatMedicine) {
    // modify 9351 by kangjie 20240218 end
      //FNSI#5678-修正 治療条件のデータがマスタに参照ではなく、実績より取得。 del  ljx  start
      //this.dialysate.name = treatMedicine.medicineName;
      //FNSI#5678-修正 治療条件のデータがマスタに参照ではなく、実績より取得。 del  ljx  end
      this.decPoint = treatMedicine ? treatMedicine.unitDecimalPointSecond : 0;
    // modify 9351 by kangjie 20240218 start
    // }
  // modify 9351 by kangjie 20240218 end
  }

  // mod #10824 透析液エリアの変更値設定修正 zkm start
  // /**
  //  * 透析液にDialysateモデルを反映.
  //  * @param {*} updateObject 更新用オブジェクト
  //  */
  // reflect(updateObject) {
  //   const item = CODES.TREATMENT_CONDITION_ITEM;
  //   const info = updateObject.rst_cond_info ? updateObject.rst_cond_info : {};
  //   // mod 9342 ljx start
  //   /*    if (info[item.DIALYSATE.cd]) {
  //         //info[item.DIALYSATE.cd] = this.createEmpty();
  //         if (isNaN(this.dialysate.cd) && (this.dialysate.cd.slice(-1) === "$")){
  //           // 調製薬剤
  //           info[item.DIALYSATE.cd].value = this.dialysate.cd.slice(0, -1);
  //           info[item.DIALYSATE.cd].medicine_type = CODES.MEDICINE_TYPE.MIX.cd;
  //         } else {
  //           // 通常薬剤
  //           info[item.DIALYSATE.cd].value = this.dialysate.cd;
  //           info[item.DIALYSATE.cd].medicine_type = CODES.MEDICINE_TYPE.NORMAL.cd;
  //         }
  //         info[item.DIALYSATE.cd].value_name_1 = this.dialysate.name;
  //       }*/
  //   if (this.dialysate.cd) {//「未登録」以外の値に変更する場合
  //     info[item.DIALYSATE.cd] = this.createEmpty();
  //     if (isNaN(this.dialysate.cd) && (this.dialysate.cd.slice(-1) === "$")){
  //       // 調製薬剤
  //       info[item.DIALYSATE.cd].value = this.dialysate.cd.slice(0, -1);
  //       info[item.DIALYSATE.cd].medicine_type = CODES.MEDICINE_TYPE.MIX.cd;
  //     } else {
  //       // 通常薬剤
  //       info[item.DIALYSATE.cd].value = numberToString(this.dialysate.cd);
  //       info[item.DIALYSATE.cd].medicine_type = CODES.MEDICINE_TYPE.NORMAL.cd;
  //     }
  //     info[item.DIALYSATE.cd].value_name_1 = this.dialysate.name;
  //   }else if(this.dialysate.name === ""){//「未登録」に変更する場合（nameが""）
  //     info[item.DIALYSATE.cd] = this.createEmpty();
  //     info[item.DIALYSATE.cd].value_name_1 = this.dialysate.name;
  //   }
  //   // mod FNSI-8156 治療条件を編集した際に、グレーなものを空の要素で作成しない、総合ビューア画面で未登録で表示するから。LJX START
  //   /*    if (!info[item.DIALYSATE_FLOW_RATE.cd]) {
  //         info[item.DIALYSATE_FLOW_RATE.cd] = this.createEmpty();
  //       }
  //       info[item.DIALYSATE_FLOW_RATE.cd].value = this.flowRate;*/
  //   /*    if (info[item.DIALYSATE_FLOW_RATE.cd]) {
  //         info[item.DIALYSATE_FLOW_RATE.cd].value = this.flowRate;
  //       }*/
  //   if (this.flowRate) {
  //     info[item.DIALYSATE_FLOW_RATE.cd] = this.createEmpty();
  //     info[item.DIALYSATE_FLOW_RATE.cd].value = numberToString(this.flowRate);
  //   }else if(info[item.DIALYSATE_FLOW_RATE.cd]){
  //     info[item.DIALYSATE_FLOW_RATE.cd].value = numberToString(this.flowRate);
  //   }
  //   /*    if (!info[item.DIALYSATE_AMOUNT.cd]) {
  //         info[item.DIALYSATE_AMOUNT.cd] = this.createEmpty();
  //       }
  //       info[item.DIALYSATE_AMOUNT.cd].value = this.amount;
  //       info[item.DIALYSATE_AMOUNT.cd].unit = this.amountUnit;*/
  //   /*    if (info[item.DIALYSATE_AMOUNT.cd]) {
  //         info[item.DIALYSATE_AMOUNT.cd].value = this.amount;
  //         info[item.DIALYSATE_AMOUNT.cd].unit = this.amountUnit;
  //       }*/
  //   if(this.amount){
  //     info[item.DIALYSATE_AMOUNT.cd] = this.createEmpty();
  //     info[item.DIALYSATE_AMOUNT.cd].value = numberToString(this.amount);
  //     info[item.DIALYSATE_AMOUNT.cd].unit = this.amountUnit;
  //   }else if(info[item.DIALYSATE_AMOUNT.cd]){
  //     info[item.DIALYSATE_AMOUNT.cd].value = numberToString(this.amount);
  //     info[item.DIALYSATE_AMOUNT.cd].unit = this.amountUnit;
  //   }
  //   /*    if (!info[item.DIALYSATE_TEMPERATURE.cd]) {
  //         info[item.DIALYSATE_TEMPERATURE.cd] = this.createEmpty();
  //       }
  //       info[item.DIALYSATE_TEMPERATURE.cd].value = this.temperature;*/
  //   /*    if (info[item.DIALYSATE_TEMPERATURE.cd]) {
  //         info[item.DIALYSATE_TEMPERATURE.cd].value = this.temperature;
  //       }*/
  //   if(this.temperature){
  //     info[item.DIALYSATE_TEMPERATURE.cd] = this.createEmpty();
  //     info[item.DIALYSATE_TEMPERATURE.cd].value = numberToString(this.temperature);
  //   }else if(info[item.DIALYSATE_TEMPERATURE.cd]){
  //     info[item.DIALYSATE_TEMPERATURE.cd].value = numberToString(this.temperature);
  //   }
  //   // mod 9342 ljx end
  //   // mod FNSI-8156 治療条件を編集した際に、グレーなものを空の要素で作成しない、総合ビューア画面で未登録で表示するから。LJX END
  // }
  // /* modify by chamaojia 2024-01-31 [10196] "Value" assignment string --end */

  /**
   * 透析液にDialysateモデルを反映.
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
        let unit = actualModel['amountUnit'] ? actualModel['amountUnit']: null;
        switch (key) {
          // 透析液(15)
          case "dialysate":
            rstCondInfo[item.DIALYSATE.cd] = this.getTemplateM();
            if (this.dialysate.cd) {//「未登録」以外の値に変更する場合
              if (isNaN(this.dialysate.cd) && (this.dialysate.cd.slice(-1) === "$")){
                // 調製薬剤
                rstCondInfo[item.DIALYSATE.cd].value = this.dialysate.cd.slice(0, -1);
                rstCondInfo[item.DIALYSATE.cd].medicine_type = CODES.MEDICINE_TYPE.MIX.cd;
              } else {
                // 通常薬剤
                rstCondInfo[item.DIALYSATE.cd].value = numberToString(this.dialysate.cd);
                rstCondInfo[item.DIALYSATE.cd].medicine_type = CODES.MEDICINE_TYPE.NORMAL.cd;
              }
              rstCondInfo[item.DIALYSATE.cd].value_name_1 = this.dialysate.name;
              rstCondInfo[item.DIALYSATE.cd].unit = unit;
              // 透析液使用数(17)
              if (rstCondInfo[item.DIALYSATE_AMOUNT.cd]) {
                rstCondInfo[item.DIALYSATE_AMOUNT.cd].unit = unit;
              }
            }
            continue;
            // 透析液流量(16)
          case "flowRate":
            rstCondInfo[item.DIALYSATE_FLOW_RATE.cd] = this.createEmpty();
            rstCondInfo[item.DIALYSATE_FLOW_RATE.cd].value = numberToString(actualModel[key]);
            rstCondInfo[item.DIALYSATE_FLOW_RATE.cd].unit = "mL/min";
            continue;
            // 透析液使用数(17)
          case "amount":
            rstCondInfo[item.DIALYSATE_AMOUNT.cd] = this.createEmpty();
            rstCondInfo[item.DIALYSATE_AMOUNT.cd].value = numberToString(actualModel[key]);
            if (rstCondInfo[item.DIALYSATE.cd] && rstCondInfo[item.DIALYSATE.cd].unit) {
              rstCondInfo[item.DIALYSATE_AMOUNT.cd].unit = rstCondInfo[item.DIALYSATE.cd].unit
            } else {
              rstCondInfo[item.DIALYSATE_AMOUNT.cd].unit = unit;
            }
            continue;
            // 透析液温度(18)
          case "temperature":
            rstCondInfo[item.DIALYSATE_TEMPERATURE.cd] = this.createEmpty();
            rstCondInfo[item.DIALYSATE_TEMPERATURE.cd].value = numberToString(actualModel[key]);
            rstCondInfo[item.DIALYSATE_TEMPERATURE.cd].unit = "℃";
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
