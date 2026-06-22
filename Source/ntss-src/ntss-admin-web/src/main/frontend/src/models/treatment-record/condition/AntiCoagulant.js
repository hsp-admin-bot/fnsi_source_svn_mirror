/**
 * 治療条件画面の抗凝固剤を表現するクラス
 */
import { CODES } from "@/constants/TreatmentRecord";
import { Master, isUnregisteredMaster } from "@/models/common/master-selector-condition/Master";
import {
  numberToString,
  stringToNumber
} from "@/models/treatment-record/Helper";

export class AntiCoagulant {
  constructor(rstCondInfo = null,mstMedicine = null,mstMedicineMix = null) {
    if (rstCondInfo === null) {
      rstCondInfo = {};
    }

    // 薬剤マスタ or 調整薬剤マスタ
    let treatMedicine = null;
    const item = CODES.TREATMENT_CONDITION_ITEM;
    // 抗凝固剤(25)
    const antiCoagulantData = rstCondInfo[item.ANTI_COAGULANT.cd]
      ? rstCondInfo[item.ANTI_COAGULANT.cd]
      : this.createEmpty();
    // 抗凝固剤ワンショット量(26)
    const oneShot = rstCondInfo[item.ANTI_COAGULANT_ONE_SHOT_AMOUNT.cd]
      ? rstCondInfo[item.ANTI_COAGULANT_ONE_SHOT_AMOUNT.cd]
      : this.createEmpty();
    // 抗凝固剤持続速度(27)
    const antiCoagulantSpeed = rstCondInfo[item.ANTI_COAGULANT_SPEED.cd]
      ? rstCondInfo[item.ANTI_COAGULANT_SPEED.cd]
      : this.createEmpty();
    // 抗凝固剤持続総量(28)
    const amount = rstCondInfo[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd]
      ? rstCondInfo[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd]
      : this.createEmpty();
    // IP使用選択(29)
    const ipCd = rstCondInfo[item.IP.cd]
      ? rstCondInfo[item.IP.cd]
      : this.createEmpty();
    // IPスタート(30)
    const ipStartCd = rstCondInfo[item.IP_START.cd]
      ? rstCondInfo[item.IP_START.cd]
      : this.createEmpty();
    // IP速度(32)
    const ipSpeedCd = rstCondInfo[item.IP_SPEED.cd]
      ? rstCondInfo[item.IP_SPEED.cd]
      : this.createEmpty();
    // IP速度最大値(33)
    const ipSpeedMaxCd = rstCondInfo[item.IP_SPEED_MAX.cd]
      ? rstCondInfo[item.IP_SPEED_MAX.cd]
      : this.createEmpty();
    // IPワンショットスタート(34)
    const autoOneShotCd = rstCondInfo[item.AUTO_ONE_SHOT.cd]
      ? rstCondInfo[item.AUTO_ONE_SHOT.cd]
      : this.createEmpty();
    // IPワンショット量(31)
    const ipOneShotCd = rstCondInfo[item.IP_ONE_SHOT_AMOUNT.cd]
      ? rstCondInfo[item.IP_ONE_SHOT_AMOUNT.cd]
      : this.createEmpty();
    // IP電源自動切り(35)
    const ipAutoOffCd = rstCondInfo[item.IP_AUTO_OFF.cd]
      ? rstCondInfo[item.IP_AUTO_OFF.cd]
      : this.createEmpty();
    // IP電源自動切り時間(36)
    const ipAutoOffTimeCd = rstCondInfo[item.IP_AUTO_OFF_TIME.cd]
      ? rstCondInfo[item.IP_AUTO_OFF_TIME.cd]
      : this.createEmpty();
    // IP電源OKモニタ切り(37)
    const ipMonitorAutoOffCd = rstCondInfo[item.IP_MONITOR_AUTO_OFF.cd]
      ? rstCondInfo[item.IP_MONITOR_AUTO_OFF.cd]
      : this.createEmpty();
    // IP電源OKモニタ切り時間(38)
    const ipMonitorAutoOffTimeCd =
    rstCondInfo[item.IP_MONITOR_AUTO_OFF_TIME.cd]
      ? rstCondInfo[item.IP_MONITOR_AUTO_OFF_TIME.cd]
      : this.createEmpty();

    this.antiCoagulant = new Master(
      antiCoagulantData.value,
      antiCoagulantData.value_name_1
    );
    this.oneShotAmount = oneShot.value;
    this.oneShotAmountUnit = oneShot.unit;
    this.speed = antiCoagulantSpeed.value;
    this.speedUnit = antiCoagulantSpeed.unit;
    this.totalAmount = amount.value;
    this.totalAmountUnit = amount.unit;
    this.ip = numberToString(ipCd.value);
    this.ipStart = numberToString(ipStartCd.value);
    this.ipSpeed = ipSpeedCd.value;
    this.ipSpeedMax = ipSpeedMaxCd.value;
    this.autoOneShot = numberToString(autoOneShotCd.value);
    this.ipOneShotAmount = ipOneShotCd.value;
    this.ipAutoOff = numberToString(ipAutoOffCd.value);
    this.ipAutoOffTime = ipAutoOffTimeCd.value;
    this.ipMonitorAutoOff = numberToString(ipMonitorAutoOffCd.value);
    this.ipMonitorAutoOffTime = ipMonitorAutoOffTimeCd.value;

    // # 10196 modified data's type Start
    // 抗凝固剤 薬剤区分によるマスタ
    if(antiCoagulantData.medicine_type == CODES.MEDICINE_TYPE.NORMAL.cd){
      treatMedicine = mstMedicine.find(
        medi => medi.medicineCd == antiCoagulantData.value
      );
    }else if(antiCoagulantData.medicine_type == CODES.MEDICINE_TYPE.MIX.cd){
      treatMedicine = mstMedicineMix.find(
       // mod 9360 抗凝固剤のワンショット量・持続速度・持続総量の保存が正しくできない zhou start
        //medi => medi.medicineCd === antiCoagulantData.value
        medi => medi.medicineCd === stringToNumber(antiCoagulantData.value.replace("$", ""))
        // mod 9360 抗凝固剤のワンショット量・持続速度・持続総量の保存が正しくできない zhou end
      );
    }
    // # 10196 modified data's type End
    // 薬剤コードに該当する薬剤マスタがある場合
    if (treatMedicine) {
      //FNSI#5678-修正 治療条件のデータがマスタに参照ではなく、実績より取得。 del  ljx  start
      //this.antiCoagulant.name = treatMedicine.medicineName;
      //FNSI#5678-修正 治療条件のデータがマスタに参照ではなく、実績より取得。 del  ljx  end
      this.decPoint = treatMedicine ? treatMedicine.unitDecimalPoint : 0;
    // add 9360 抗凝固剤のワンショット量・持続速度・持続総量の保存が正しくできない zhou start
    } else{
      this.decPoint = null;
    }
      // add 9360 抗凝固剤のワンショット量・持続速度・持続総量の保存が正しくできない zhou end
  }

  /* modify by chamaojia 2024-01-31 [10196] "Value" assignment string --start */
  /**
   * 抗凝固剤にAntiCoagulantモデルを反映.
   * @param {*} updateObject 更新用オブジェクト
   */
  // del 10824 治療記録>治療条件を編集するとord_mainのrst_cond_infの一部がnullになる 関 start
  // reflect(updateObject) {
//     const item = CODES.TREATMENT_CONDITION_ITEM;
//     const info = updateObject.rst_cond_info ? updateObject.rst_cond_info : {};
//     // mod 9342 ljx start
//     /*    if (info[item.ANTI_COAGULANT.cd]) {
//       //info[item.ANTI_COAGULANT.cd] = this.createEmpty();
//       if (isNaN(this.antiCoagulant.cd) && (this.antiCoagulant.cd.slice(-1) === "$")){
//         // 調製薬剤
//         info[item.ANTI_COAGULANT.cd].value = stringToNumber(this.antiCoagulant.cd.slice(0, -1));
//         info[item.ANTI_COAGULANT.cd].medicine_type = CODES.MEDICINE_TYPE.MIX.cd;
//       } else {
//         // 通常薬剤
//         info[item.ANTI_COAGULANT.cd].value = this.antiCoagulant.cd;
//         info[item.ANTI_COAGULANT.cd].medicine_type = CODES.MEDICINE_TYPE.NORMAL.cd;
//       }
//       info[item.ANTI_COAGULANT.cd].value_name_1 = this.antiCoagulant.name;
//     }*/
//     //
//     if(this.antiCoagulant.cd){//「未登録」以外の値に変更する場合
//       info[item.ANTI_COAGULANT.cd] = this.createEmpty();
//       if (isNaN(this.antiCoagulant.cd) && (this.antiCoagulant.cd.slice(-1) === "$")){
//         // 調製薬剤
//         info[item.ANTI_COAGULANT.cd].value = this.antiCoagulant.cd.slice(0, -1);
//         info[item.ANTI_COAGULANT.cd].medicine_type = CODES.MEDICINE_TYPE.MIX.cd;
//       } else {
//         // 通常薬剤
//         info[item.ANTI_COAGULANT.cd].value = numberToString(this.antiCoagulant.cd);
//         info[item.ANTI_COAGULANT.cd].medicine_type = CODES.MEDICINE_TYPE.NORMAL.cd;
//       }
//       info[item.ANTI_COAGULANT.cd].value_name_1 = this.antiCoagulant.name;
//     }else if(this.antiCoagulant.name === ""){//「未登録」に変更する場合（nameが""）
//       info[item.ANTI_COAGULANT.cd] = this.createEmpty();
//       info[item.ANTI_COAGULANT.cd].value_name_1 = this.antiCoagulant.name;
//     }
//     // mod FNSI-8156 治療条件を編集した際に、グレーなものを空の要素で作成しない、総合ビューア画面で未登録で表示するから。LJX START
//     /*if (!info[item.ANTI_COAGULANT_ONE_SHOT_AMOUNT.cd]) {
//       info[item.ANTI_COAGULANT_ONE_SHOT_AMOUNT.cd] = this.createEmpty();
//     }
//     info[item.ANTI_COAGULANT_ONE_SHOT_AMOUNT.cd].value = this.oneShotAmount;
//     info[item.ANTI_COAGULANT_ONE_SHOT_AMOUNT.cd].unit = this.oneShotAmountUnit;*/
//     /*    if (info[item.ANTI_COAGULANT_ONE_SHOT_AMOUNT.cd]) {
//           info[item.ANTI_COAGULANT_ONE_SHOT_AMOUNT.cd].value = this.oneShotAmount;
//           info[item.ANTI_COAGULANT_ONE_SHOT_AMOUNT.cd].unit = this.oneShotAmountUnit;
//         }*/
//     if(this.oneShotAmount){
//       info[item.ANTI_COAGULANT_ONE_SHOT_AMOUNT.cd] = this.createEmpty();
//       info[item.ANTI_COAGULANT_ONE_SHOT_AMOUNT.cd].value = numberToString(this.oneShotAmount);
//       info[item.ANTI_COAGULANT_ONE_SHOT_AMOUNT.cd].unit = this.oneShotAmountUnit;
//     }else if(info[item.ANTI_COAGULANT_ONE_SHOT_AMOUNT.cd]){
//       info[item.ANTI_COAGULANT_ONE_SHOT_AMOUNT.cd].value = numberToString(this.oneShotAmount);
//       info[item.ANTI_COAGULANT_ONE_SHOT_AMOUNT.cd].unit = this.oneShotAmountUnit;
//     }
//     /*    if (!info[item.ANTI_COAGULANT_SPEED.cd]) {
//           info[item.ANTI_COAGULANT_SPEED.cd] = this.createEmpty();
//         }
//         info[item.ANTI_COAGULANT_SPEED.cd].value = this.speed;
//         info[item.ANTI_COAGULANT_SPEED.cd].unit = this.speedUnit;*/
//     /*    if (info[item.ANTI_COAGULANT_SPEED.cd]) {
//           info[item.ANTI_COAGULANT_SPEED.cd].value = this.speed;
//           info[item.ANTI_COAGULANT_SPEED.cd].unit = this.speedUnit;
//         }*/
//     if(this.speed){
//       info[item.ANTI_COAGULANT_SPEED.cd] = this.createEmpty();
//       info[item.ANTI_COAGULANT_SPEED.cd].value = numberToString(this.speed);
//       info[item.ANTI_COAGULANT_SPEED.cd].unit = this.speedUnit
//     }else if(info[item.ANTI_COAGULANT_SPEED.cd]){
//       info[item.ANTI_COAGULANT_SPEED.cd].value = numberToString(this.speed);
//       info[item.ANTI_COAGULANT_SPEED.cd].unit = this.speedUnit
//     }
//     /*    if (!info[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd]) {
//           info[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd] = this.createEmpty();
//         }
//         info[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd].value = this.totalAmount;
//         info[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd].unit = this.totalAmountUnit;*/
//     /*    if (info[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd]) {
//           info[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd].value = this.totalAmount;
//           info[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd].unit = this.totalAmountUnit;
//         }*/
//     if(this.totalAmount){
//       info[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd] = this.createEmpty();
//       info[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd].value = numberToString(this.totalAmount);
//       info[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd].unit = this.totalAmountUnit;
//     }else if(info[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd]){
//       info[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd].value = numberToString(this.totalAmount);
//       info[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd].unit = this.totalAmountUnit;
//     }
//     /*    if (!info[item.IP.cd]) {
//           info[item.IP.cd] = this.createEmpty();
//         }
//         info[item.IP.cd].value = stringToNumber(this.ip);*/
//     /*    if (info[item.IP.cd]) {
//           info[item.IP.cd].value = stringToNumber(this.ip);
//         }*/
//     if(this.ip){
//       info[item.IP.cd] = this.createEmpty();
//       info[item.IP.cd].value = this.ip;
//     }
//     /*    if (!info[item.IP_START.cd]) {
//           info[item.IP_START.cd] = this.createEmpty();
//         }
//         info[item.IP_START.cd].value = stringToNumber(this.ipStart);*/
//     /*    if (info[item.IP_START.cd]) {
//           info[item.IP_START.cd].value = stringToNumber(this.ipStart);
//         }*/
//     if(this.ipStart){
//       info[item.IP_START.cd] = this.createEmpty();
//       info[item.IP_START.cd].value = this.ipStart;
//     }
//     /*    if (!info[item.IP_SPEED.cd]) {
//           info[item.IP_SPEED.cd] = this.createEmpty();
//         }
//         info[item.IP_SPEED.cd].value = this.ipSpeed;*/
//     /*    if (info[item.IP_SPEED.cd]) {
//           info[item.IP_SPEED.cd].value = this.ipSpeed;
//         }*/
//     if(this.ipSpeed){
//       info[item.IP_SPEED.cd] = this.createEmpty();
//       info[item.IP_SPEED.cd].value = numberToString(this.ipSpeed);
//     }else if(info[item.IP_SPEED.cd]){
//       info[item.IP_SPEED.cd].value = numberToString(this.ipSpeed);
//     }
//     /*    if (!info[item.IP_SPEED_MAX.cd]) {
//           info[item.IP_SPEED_MAX.cd] = this.createEmpty();
//         }
//         info[item.IP_SPEED_MAX.cd].value = this.ipSpeedMax;*/
//     /*    if (info[item.IP_SPEED_MAX.cd]) {
//           info[item.IP_SPEED_MAX.cd].value = this.ipSpeedMax;
//         }*/
//     if(this.ipSpeedMax){
//       info[item.IP_SPEED_MAX.cd] = this.createEmpty();
//       info[item.IP_SPEED_MAX.cd].value = numberToString(this.ipSpeedMax);
//     }else if(info[item.IP_SPEED_MAX.cd]){
//       info[item.IP_SPEED_MAX.cd].value = numberToString(this.ipSpeedMax);
//     }
//     /*    if (!info[item.AUTO_ONE_SHOT.cd]) {
//           info[item.AUTO_ONE_SHOT.cd] = this.createEmpty();
//         }
//         info[item.AUTO_ONE_SHOT.cd].value = stringToNumber(this.autoOneShot);*/
//     /*    if (info[item.AUTO_ONE_SHOT.cd]) {
//           info[item.AUTO_ONE_SHOT.cd].value = stringToNumber(this.autoOneShot);
//         }*/
//     if(this.autoOneShot){
//       info[item.AUTO_ONE_SHOT.cd] = this.createEmpty();
//       info[item.AUTO_ONE_SHOT.cd].value = this.autoOneShot;
//     }
//     /*    if (!info[item.IP_ONE_SHOT_AMOUNT.cd]) {
//           info[item.IP_ONE_SHOT_AMOUNT.cd] = this.createEmpty();
//         }
//         info[item.IP_ONE_SHOT_AMOUNT.cd].value = this.ipOneShotAmount;*/
//     /*    if (info[item.IP_ONE_SHOT_AMOUNT.cd]) {
//           info[item.IP_ONE_SHOT_AMOUNT.cd].value = this.ipOneShotAmount;
//         }*/
//     if(this.ipOneShotAmount){
//       info[item.IP_ONE_SHOT_AMOUNT.cd] = this.createEmpty();
//       info[item.IP_ONE_SHOT_AMOUNT.cd].value = numberToString(this.ipOneShotAmount);
//     }else if(info[item.IP_ONE_SHOT_AMOUNT.cd]){
//       info[item.IP_ONE_SHOT_AMOUNT.cd].value = numberToString(this.ipOneShotAmount);
//     }
//     /*    if (!info[item.IP_AUTO_OFF.cd]) {
//           info[item.IP_AUTO_OFF.cd] = this.createEmpty();
//         }
//         info[item.IP_AUTO_OFF.cd].value = stringToNumber(this.ipAutoOff);*/
//     /*    if (info[item.IP_AUTO_OFF.cd]) {
//           info[item.IP_AUTO_OFF.cd].value = stringToNumber(this.ipAutoOff);
//         }*/
//     if(this.ipAutoOff){
//       info[item.IP_AUTO_OFF.cd] = this.createEmpty();
//       info[item.IP_AUTO_OFF.cd].value = this.ipAutoOff;
//     }
//     /*    if (!info[item.IP_AUTO_OFF_TIME.cd]) {
//           info[item.IP_AUTO_OFF_TIME.cd] = this.createEmpty();
//         }
//         info[item.IP_AUTO_OFF_TIME.cd].value = this.ipAutoOffTime;*/
//     /*    if (info[item.IP_AUTO_OFF_TIME.cd]) {
//           info[item.IP_AUTO_OFF_TIME.cd].value = this.ipAutoOffTime;
//         }*/
//     if(this.ipAutoOffTime){
//       info[item.IP_AUTO_OFF_TIME.cd] = this.createEmpty();
//       info[item.IP_AUTO_OFF_TIME.cd].value = numberToString(this.ipAutoOffTime);
//     }else if(info[item.IP_AUTO_OFF_TIME.cd]){
//       info[item.IP_AUTO_OFF_TIME.cd].value = numberToString(this.ipAutoOffTime);
//     }
//     /*    if (!info[item.IP_MONITOR_AUTO_OFF.cd]) {
//           info[item.IP_MONITOR_AUTO_OFF.cd] = this.createEmpty();
//         }
//         info[item.IP_MONITOR_AUTO_OFF.cd].value = stringToNumber(
//           this.ipMonitorAutoOff
//         );*/
//     /*    if (info[item.IP_MONITOR_AUTO_OFF.cd]) {
//           info[item.IP_MONITOR_AUTO_OFF.cd].value = stringToNumber(
//             this.ipMonitorAutoOff
//           );
//         }*/
//     if(this.ipMonitorAutoOff){
//       info[item.IP_MONITOR_AUTO_OFF.cd] = this.createEmpty();
//       info[item.IP_MONITOR_AUTO_OFF.cd].value = this.ipMonitorAutoOff;
//     }
//     /*if (!info[item.IP_MONITOR_AUTO_OFF_TIME.cd]) {
//       info[item.IP_MONITOR_AUTO_OFF_TIME.cd] = this.createEmpty();
//     }
//     info[item.IP_MONITOR_AUTO_OFF_TIME.cd].value = this.ipMonitorAutoOffTime;*/
//     /*    if (info[item.IP_MONITOR_AUTO_OFF_TIME.cd]) {
//           info[item.IP_MONITOR_AUTO_OFF_TIME.cd].value = this.ipMonitorAutoOffTime;
//         }*/
//     if(this.ipMonitorAutoOffTime){
//       info[item.IP_MONITOR_AUTO_OFF_TIME.cd] = this.createEmpty();
//       info[item.IP_MONITOR_AUTO_OFF_TIME.cd].value = numberToString(this.ipMonitorAutoOffTime);
//     }else if(info[item.IP_MONITOR_AUTO_OFF_TIME.cd]){
//       info[item.IP_MONITOR_AUTO_OFF_TIME.cd].value = numberToString(this.ipMonitorAutoOffTime);
//     }
//     // mod 9342 ljx end
// // mod FNSI-8156 治療条件を編集した際に、グレーなものを空の要素で作成しない、総合ビューア画面で未登録で表示するから。LJX END
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
  reflect(copyObject, comparisonModel, actualModel, mstMedicineInfo, mstMedicineMixInfo) {
    let info = copyObject.rst_cond_info ? copyObject.rst_cond_info : {};
    const item = CODES.TREATMENT_CONDITION_ITEM;
    const keys = Object.keys(comparisonModel);
    for (let key of keys) {
      if (!this.compareObjects(comparisonModel[key], actualModel[key])) {
        let nullUnit = false;
        if (!actualModel['antiCoagulant'] || null === actualModel['antiCoagulant'].cd) {
          nullUnit = true;
        }
        // add 12018 治療記録＞治療条件で調製薬剤の持続総量を変更するとord_main.rst_cond_infoの抗凝固剤のvalueの調製薬剤のコードの後ろに$のごみが登録される zkm start
        if (info['25'] && null != info['25'].value) {
          info['25'].value = info['25'].value.replace(/\$/g, "");
        }
        // add 12018 治療記録＞治療条件で調製薬剤の持続総量を変更するとord_main.rst_cond_infoの抗凝固剤のvalueの調製薬剤のコードの後ろに$のごみが登録される zkm end
        switch (key) {
          case "antiCoagulant":
            //「未登録」以外の値に変更する場合
            if(this.antiCoagulant.cd){
              info[item.ANTI_COAGULANT.cd] = this.getTemplate();
              // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
              //if (isNaN(this.antiCoagulant.cd) && (this.antiCoagulant.cd.slice(-1) === "$")){
              if ((this.antiCoagulant.type == "2")){
              // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
                // 調製薬剤
                let unit = mstMedicineMixInfo.filter(d => {
                  return d.medicineCd === actualModel[key].cd;}).unit;
                // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
                //info[item.ANTI_COAGULANT.cd].value = this.antiCoagulant.cd.slice(0, -1);  
                info[item.ANTI_COAGULANT.cd].value = this.antiCoagulant.cd;
                  // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
                info[item.ANTI_COAGULANT.cd].medicine_type = CODES.MEDICINE_TYPE.MIX.cd;
                info[item.ANTI_COAGULANT.cd].unit = unit;
              } else {
                // 通常薬剤
                let unit = mstMedicineInfo.filter(d => {
                  return d.medicineCd === actualModel[key].cd;})[0].unit;
                info[item.ANTI_COAGULANT.cd].value = numberToString(this.antiCoagulant.cd);
                info[item.ANTI_COAGULANT.cd].medicine_type = CODES.MEDICINE_TYPE.NORMAL.cd;
                info[item.ANTI_COAGULANT.cd].unit = unit;
              }
              info[item.ANTI_COAGULANT.cd].value_name_1 = this.antiCoagulant.name;
              // 抗凝固剤ワンショット量(26)
              if (info[item.ANTI_COAGULANT_ONE_SHOT_AMOUNT.cd] != undefined) {
                info[item.ANTI_COAGULANT_ONE_SHOT_AMOUNT.cd].unit = nullUnit ? null: this.oneShotAmountUnit;
              }
              // 抗凝固剤持続総量(28)
              if (info[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd] != undefined) {
                info[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd].unit = nullUnit ? null : this.totalAmountUnit;
              }
              // 抗凝固剤持続速度(27)
              if (info[item.ANTI_COAGULANT_SPEED.cd] != undefined) {
                info[item.ANTI_COAGULANT_SPEED.cd].unit = nullUnit ? null : this.speedUnit;
              }
            }else if(isUnregisteredMaster(this.antiCoagulant)){//「未登録」に変更する場合
              info[item.ANTI_COAGULANT.cd] = this.getTemplate();
            }
            continue;
            // 抗凝固剤ワンショット量(26)
          case "oneShotAmount":
            info[item.ANTI_COAGULANT_ONE_SHOT_AMOUNT.cd] = this.createEmpty();
            info[item.ANTI_COAGULANT_ONE_SHOT_AMOUNT.cd].value = numberToString(this.oneShotAmount);
            // info[item.ANTI_COAGULANT_ONE_SHOT_AMOUNT.cd].unit = this.oneShotAmountUnit;
            if (info[item.ANTI_COAGULANT.cd]) {
                info[item.ANTI_COAGULANT_ONE_SHOT_AMOUNT.cd].unit = nullUnit ? null : info[item.ANTI_COAGULANT.cd].unit;
            }
            continue;
            // 抗凝固剤持続速度(27)
          case "speed":
            info[item.ANTI_COAGULANT_SPEED.cd] = this.createEmpty();
            info[item.ANTI_COAGULANT_SPEED.cd].value = numberToString(this.speed);
            // info[item.ANTI_COAGULANT_SPEED.cd].unit = this.speedUnit;
            if (info[item.ANTI_COAGULANT.cd]) {
                info[item.ANTI_COAGULANT_SPEED.cd].unit = nullUnit || null == info[item.ANTI_COAGULANT.cd].unit ?  null : info[item.ANTI_COAGULANT.cd].unit+"/h";
            }
            continue;
            // 抗凝固剤持続総量(28)
          case "totalAmount":
            info[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd] = this.createEmpty();
            info[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd].value = numberToString(this.totalAmount);
            // info[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd].unit = this.totalAmountUnit;
            if (info[item.ANTI_COAGULANT.cd]) {
                info[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd].unit = nullUnit ? null : info[item.ANTI_COAGULANT.cd].unit;
            }
            continue;
          case "oneShotAmountUnit":
            if (!info[item.ANTI_COAGULANT.cd]) {
              info[item.ANTI_COAGULANT.cd] = this.getTemplate();
            }
            info[item.ANTI_COAGULANT.cd].unit = nullUnit ? null : this.oneShotAmountUnit;
            if (!info[item.ANTI_COAGULANT_ONE_SHOT_AMOUNT.cd]) {
              info[item.ANTI_COAGULANT_ONE_SHOT_AMOUNT.cd] = this.createEmpty();
            }
            info[item.ANTI_COAGULANT_ONE_SHOT_AMOUNT.cd].unit = nullUnit ? null : this.oneShotAmountUnit;
            if (!info[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd]) {
              info[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd] = this.createEmpty();
            }
            info[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd].unit = nullUnit ? null : this.totalAmountUnit;
            if (!info[item.ANTI_COAGULANT_SPEED.cd]) {
              info[item.ANTI_COAGULANT_SPEED.cd] = this.createEmpty();
            }
            info[item.ANTI_COAGULANT_SPEED.cd].unit = nullUnit ? null : this.speedUnit;
            continue;
          case "speedUnit":
            if (!info[item.ANTI_COAGULANT_SPEED.cd]) {
              info[item.ANTI_COAGULANT_SPEED.cd] = this.createEmpty();
            }
            info[item.ANTI_COAGULANT_SPEED.cd].unit = nullUnit ? null : this.speedUnit;
            continue;
          case "totalAmountUnit":
            if (!info[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd]) {
              info[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd] = this.createEmpty();
            }
            info[item.ANTI_COAGULANT_TOTAL_AMOUNT.cd].unit = nullUnit ? null : this.totalAmountUnit;
            continue;
          case "ipSpeed":
            info[item.IP_SPEED.cd] = this.createEmpty();
            info[item.IP_SPEED.cd].value = numberToString(this.ipSpeed);
            info[item.IP_SPEED.cd].unit = "mL/h";
            continue;
          case "ipSpeedMax":
            info[item.IP_SPEED_MAX.cd] = this.createEmpty();
            info[item.IP_SPEED_MAX.cd].value = numberToString(this.ipSpeedMax);
            info[item.IP_SPEED_MAX.cd].unit = "mL/h";
            continue;
          case "ip":
            if(this.ip){
              info[item.IP.cd] = this.createEmpty();
              info[item.IP.cd].value = this.ip;
              if (this.ip == "1" ) {
                info[item.IP.cd].value_name_1 = "使用する";
              }else if (this.ip == "0" ) {
                info[item.IP.cd].value_name_1  = "使用しない";
              }
            }
            continue;
          case "ipStart":
            if(this.ipStart){
              info[item.IP_START.cd] = this.createEmpty();
              info[item.IP_START.cd].value = this.ipStart;
              if (this.ipStart == "0") {
                info[item.IP_START.cd].value_name_1 = "手動";
              }else if(this.ipStart == "1") {
                info[item.IP_START.cd].value_name_1 = "自動";
              }
            }
            continue;
          case "ipAutoOff":
            if(this.ipAutoOff){
              info[item.IP_AUTO_OFF.cd] = this.createEmpty();
              info[item.IP_AUTO_OFF.cd].value = this.ipAutoOff;
              if (this.ipAutoOff == "0") {
                info[item.IP_AUTO_OFF.cd].value_name_1 = "切";
              }else if (this.ipAutoOff == "1") {
                info[item.IP_AUTO_OFF.cd].value_name_1 = "入";
              }
            }
            continue;
          case "ipAutoOffTime":
            info[item.IP_AUTO_OFF_TIME.cd] = this.createEmpty();
            info[item.IP_AUTO_OFF_TIME.cd].value = numberToString(this.ipAutoOffTime);
            info[item.IP_AUTO_OFF_TIME.cd].unit = "分前";
            continue;
          case "ipMonitorAutoOff":
            if(this.ipMonitorAutoOff){
              info[item.IP_MONITOR_AUTO_OFF.cd] = this.createEmpty();
              info[item.IP_MONITOR_AUTO_OFF.cd].value = this.ipMonitorAutoOff;
              if (this.ipMonitorAutoOff == "0") {
                info[item.IP_MONITOR_AUTO_OFF.cd].value_name_1 = "切";
              }else if (this.ipMonitorAutoOff == "1") {
                info[item.IP_MONITOR_AUTO_OFF.cd].value_name_1 = "入";
              }
            }
            continue;
          case "ipMonitorAutoOffTime":
            info[item.IP_MONITOR_AUTO_OFF_TIME.cd] = this.createEmpty();
            info[item.IP_MONITOR_AUTO_OFF_TIME.cd].value = numberToString(this.ipMonitorAutoOffTime);
            info[item.IP_MONITOR_AUTO_OFF_TIME.cd].unit = "分前";
            continue;
          // IPワンショットスタート(34)
          case "autoOneShot":
            if(this.autoOneShot){
              info[item.AUTO_ONE_SHOT.cd] = this.createEmpty();
              info[item.AUTO_ONE_SHOT.cd].value = this.autoOneShot;
              if (this.autoOneShot == "1" ) {
                info[item.AUTO_ONE_SHOT.cd].value_name_1 = "自動";
              }else if (this.autoOneShot == "0" ) {
                info[item.AUTO_ONE_SHOT.cd].value_name_1  = "手動";
              }
            }
            continue;
          case "ipOneShotAmount":
            info[item.IP_ONE_SHOT_AMOUNT.cd] = this.createEmpty();
            info[item.IP_ONE_SHOT_AMOUNT.cd].value = numberToString(this.ipOneShotAmount);
            info[item.IP_ONE_SHOT_AMOUNT.cd].unit = "mL";
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
        return Number(obj1) == Number(obj2);
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
