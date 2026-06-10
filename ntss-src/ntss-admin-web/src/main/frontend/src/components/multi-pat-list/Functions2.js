import { bedSelector, dialyzerSelector, equipmentSelector, kurSelector, medicateTiming, medicineMixSelector, medicineSelector, procedure, treatmentSelector, vaSelector } from "@/functions/mst/MstGetters.js";
import {ApiHelper} from "@/apis/AxiosHelper";
import {MASTER_DELETE_DISPLAY} from "@/constants/TreatmentRecord";
import moment from "moment";

/**
 * @description 必要なすべてのマスタを取得
 * @param {String} facilityCd 施設コード
 * @returns {Object} { <マスタ名>: <マスタオブジェクト配列> }
 */
export const getAllMst = async facilityCd => {
  const [
    mst_treatment,
    mst_treatment_del,
    mst_Kur,
    mst_Kur_del,
    mst_bed,
    mst_bed_del,
    mst_va,
    mst_va_del,
    mst_dialyzer,
    mst_dialyzer_del,
    mst_equipment,
    mst_equipment_del,
    mst_procedure,
    mst_procedure_del,
    mst_medicine,
    mst_medicine_del,
    mst_medicine_mix,
    mst_medicine_mix_del,
    mst_medicate_timing,
    mst_medicate_timing_del,
    /*add FNSI-改修内容5204 任 start*/
    mst_medicine_unit,
    mst_medicine_mix_unit,
    mst_equipment_unit
    /*add FNSI-改修内容5204 任 end*/
  ] = await Promise.all([
    treatmentSelector(facilityCd),
    ApiHelper.get("/mstInfo/mstTreatmentDel", {
      facilityCd: facilityCd
    }),
    kurSelector(facilityCd),
    ApiHelper.get("/mstInfo/mstKurDel", {
      facility_cd: facilityCd
    }),
    bedSelector(facilityCd),
    ApiHelper.get("/mstInfo/mstBedDel", {
      facility_cd: facilityCd
    }),
    vaSelector(facilityCd),
    ApiHelper.get("/mstInfo/mstVaDel", {
      facilityCd: facilityCd
    }),
    dialyzerSelector(facilityCd),
    ApiHelper.get("/mstInfo/mstDialyzerDel", {
      facilityCd: facilityCd
    }),
    equipmentSelector(facilityCd),
    ApiHelper.get("/mstInfo/mstEquipmentDel", {
      facilityCd: facilityCd
    }),
    procedure(facilityCd),
    ApiHelper.get("/mstInfo/mstProcedureIncludeDeleted", {
      facilityCd: facilityCd
    }),
    medicineSelector(facilityCd),
    ApiHelper.get("/mstInfo/mstMedicineIncludeDeleted", {
      facilityCd: facilityCd
    }),
    medicineMixSelector(facilityCd),
    ApiHelper.get("/mstInfo/mstMedicineMixIncludeDeleted", {
      facilityCd: facilityCd
    }),
    medicateTiming(facilityCd),
    ApiHelper.get("/mstInfo/medicateTimingIncludeDeleted", {
      facilityCd: facilityCd
    }),
    /*add FNSI-改修内容5204 任 start*/
    ApiHelper.get("/mstInfo/getMstMedicineUnit", {
      facilityCd: facilityCd
    }),
    ApiHelper.get("/mstInfo/getMstMedicineMixUnit", {
      facilityCd: facilityCd
    }),
    ApiHelper.get("/mstInfo/getMstEquipmentUnit", {
      facilityCd: facilityCd
    }),
    /*add FNSI-改修内容5204 任 end*/
  ]).catch(error => {
    throw new Error(error);
  });

  return {
    mst_treatment,
    mst_treatment_del,
    mst_Kur,
    mst_Kur_del,
    mst_bed,
    mst_bed_del,
    mst_va,
    mst_va_del,
    mst_dialyzer,
    mst_dialyzer_del,
    mst_equipment,
    mst_equipment_del,
    mst_procedure,
    mst_procedure_del,
    mst_medicine,
    mst_medicine_del,
    mst_medicine_mix,
    mst_medicine_mix_del,
    mst_medicate_timing,
    mst_medicate_timing_del,
    /*add FNSI-改修内容5204 任 start*/
    mst_medicine_unit,
    mst_medicine_mix_unit,
    mst_equipment_unit
    /*add FNSI-改修内容5204 任 end*/
  };
};

/**
 * @description マスタコード→名称変換
 * @param {Array} mst 対象のマスタオブジェクト配列
 * @param {Number} code 変換するコード
 * @param {String} codeString マスタオブジェクトのコードのキー名
 * @param {String} nameString マスタオブジェクトの名称のキー名
 * @returns {String} マスタ名称 ※コードがnull: '未登録'、コードがマスタに存在しない: ''
 */
export const mstCodeToName = (mst, code, codeString = "code", nameString = "name") => {
  if (code === null) {
    return "未登録";
  }

  const target = mst.find(el => el[codeString] === code);
  if (!target) {
    return "";
  }
  return target[nameString];
};

/**
 * @description マスタコード→名称変換
 * @param {String} rstDialysisState 治療状況
 * @param {Array} mst 対象のマスタオブジェクト配列
 * @param {Array} mst_del 対象削除のマスタオブジェクト配列
 * @param {Number} code 変換するコード
 * @param {String} name DB name
 * @param {String} codeString マスタオブジェクトのコードのキー名
 * @param {String} nameString マスタオブジェクトの名称のキー名
 * @returns {String} マスタ名称 ※コードがnull: '未登録'、コードがマスタに存在しない: ''
 */
 export const mstCodeToNameIncludeDel = (rstDialysisState, mst, mst_del, code, name, codeString = "code", nameString = "name") => {
  if (code === null) {
    return "未登録";
  }
  if (rstDialysisState + '' !== "0") {
    // mod #9973 shiyw start
    // const target = mst.find(el => el[codeString] === code);
    const target = mst.find(el => el[codeString] == code);
    // mod #9973 shiyw end
    if (!target) {
      if (rstDialysisState + '' === "6") {
        return name;
      } else {
        return MASTER_DELETE_DISPLAY.DELETED + name;
      }
    }
    return name;
  }

  // mod #9973 Zhou.tao start
  // const target = mst.find(el => el[codeString] === code);
  const target = mst.find(el => el[codeString] == code);
  if (!target) {
    if (mst_del && mst_del.data) {
      // const targetDel = mst_del.data.find(el => el[codeString] === code);
      const targetDel = mst_del.data.find(el => el[codeString] == code);
  // mod #9973 Zhou.tao End
      if (!targetDel) {
        return "";
      }
      if (rstDialysisState + '' === "6") {
        return targetDel[nameString];
      } else {
        return MASTER_DELETE_DISPLAY.DELETED + targetDel[nameString];
      }
    } else {
      return "";
    }
  }
  return target[nameString];
};

//add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240424 start
/**
 * @description 薬剤マスタコード→unit获取
 * @param ind_medi_info
 * @param mst_medicine_unit
 * @param {Array} medicine_del 薬剤マスタオブジェクト配列
 * @param {Number} code 変換するコード
 * @param {String} codeString マスタオブジェクトのコードのキー名
 * @param {String} nameString マスタオブジェクトの名称のキー名
 * @returns {*|string}
 */
export const medicineCodeToUnit = (ind_medi_info, mst_medicine_unit, medicine_del, code,
                                   codeString = "medicineCd", nameString = "unit") => {
  if (code === null) {
    return "未登録";
  }
  if (ind_medi_info.unit) {
    return ind_medi_info.unit;
  }
  const target = mst_medicine_unit.find(el => el[codeString] == code);
  if (!target) {
    if (medicine_del && medicine_del.data) {
      const targetDel = medicine_del.data.find(el => el[codeString] == code);
      if (!targetDel) {
        return "";
      }
      return targetDel[nameString];
    } else {
      return "";
    }
  }

  return target[nameString];
};

/**
 * @description 医療材料→unit获取
 * @param ind_equip_info
 * @param mst_equipment_unit
 * @param {Array} equipment_del 薬剤マスタオブジェクト配列
 * @param {Number} code 変換するコード
 * @param {String} codeString マスタオブジェクトのコードのキー名
 * @param {String} nameString マスタオブジェクトの名称のキー名
 * @returns {*|string}
 */
export const equipmentCodeToUnit = (ind_equip_info, mst_equipment_unit, equipment_del, code,
                                    codeString = "equipmentCd", nameString = "unit") => {
  if (code === null) {
    return "未登録";
  }
  if (ind_equip_info.unit) {
    return ind_equip_info.unit;
  }
  const target = mst_equipment_unit.find(el => el[codeString] == code);
  if (!target) {
    if (equipment_del && equipment_del.data) {
      const targetDel = equipment_del.data.find(el => el[codeString] == code);
      if (!targetDel) {
        return "";
      }
      return targetDel[nameString];
    } else {
      return "";
    }
  }
  return target[nameString];
};
//add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240424 end

/**
 * @description 薬剤マスタコード→名称変換
 * @param {String} rstDialysisState 治療状況
 * @param {Array} medicine 薬剤マスタオブジェクト配列
 * @param {Array} medicine_del 薬剤マスタオブジェクト配列
 * @param {Array} medicine_mix 調製薬剤マスタオブジェクト配列
 * @param {Array} medicine_mix_del 調製薬剤マスタオブジェクト配列
 * @param {Number} code 変換するコード
 * @param {String} name DB name
 * @param {String} medicine_type 薬剤区分
 * @param {String} codeString マスタオブジェクトのコードのキー名
 * @param {String} nameString マスタオブジェクトの名称のキー名
 * @returns {String} マスタ名称 ※コードがnull: '未登録'、コードがマスタに存在しない: ''
 */
export const medicineCodeToName = (rstDialysisState, medicine, medicine_del, medicine_mix, medicine_mix_del, code, name, medicine_type, codeString = "code", nameString = "name") => {
  if (code === null) {
    return "未登録";
  }
  if (rstDialysisState !== "0") {
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //if (medicine_type === "1") {
    if (medicine_type == 1) {
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      //mod #10076 データリストで実績がある場合に表示されない zrx start
      //   const target = medicine.find(el => el[codeString] === code);
      const target = medicine.find(el => el[codeString] == code);
      //mod #10076 データリストで実績がある場合に表示されない zrx end
      if (!target) {
        if (rstDialysisState === "6") {
          return name;
        } else {
          return MASTER_DELETE_DISPLAY.DELETED + name;
        }
      }
      return name;
    }
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //if (medicine_type === "2") {
    if (medicine_type == 2) {
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      // Mod #9973 By Tao.zhou fix the type of JSON value node. Start Since 2023-10-27
    //   const target = medicine_mix.find(el => el[codeString] === code);
      const target = medicine_mix.find(el => el[codeString] == code);
      // Mod #9973 By Tao.zhou fix the type of JSON value node. End Since 2023-10-27
      if (!target) {
        if (rstDialysisState === "6") {
          return name;
        } else {
          return MASTER_DELETE_DISPLAY.DELETED + name;
        }
      }
      return name;
    }
    return "";
  }
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //if (medicine_type === "1") {
  if (medicine_type == 1) {
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240424 start
    const target = medicine.find(el => el[codeString] == code);
    //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240424 end
    if (!target) {
      if (medicine_del && medicine_del.data) {
        // Mod #9973 By Tao.zhou fix the type of JSON value node. Start Since 2023-10-27
        // const targetDel = medicine_del.data.find(el => el[codeString] === code);
        const targetDel = medicine_del.data.find(el => el[codeString] == code);
        // Mod #9973 By Tao.zhou fix the type of JSON value node. End Since 2023-10-27
        if (!targetDel) {
          return "";
        }
        if (rstDialysisState === "6") {
          return targetDel[nameString];
        } else {
          return MASTER_DELETE_DISPLAY.DELETED + targetDel[nameString];
        }
      } else {
        return "";
      }
    }
    return target[nameString];
  }
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //if (medicine_type === "2") {
  if (medicine_type == 2) {
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    // Mod #9973 By Tao.zhou fix the type of JSON value node. Start Since 2023-10-27
  //   const target = medicine_mix.find(el => el[codeString] === code);
    const target = medicine_mix.find(el => el[codeString] == code);
    if (!target) {
      if (medicine_mix_del && medicine_mix_del.data) {
        // const targetDel = medicine_mix_del.data.find(el => el[codeString] === code);
        const targetDel = medicine_mix_del.data.find(el => el[codeString] == code);
    // Mod #9973 By Tao.zhou fix the type of JSON value node. End Since 2023-10-27
        if (!targetDel) {
          return "";
        }
        if (rstDialysisState === "6") {
          return targetDel[nameString];
        } else {
          return MASTER_DELETE_DISPLAY.DELETED + targetDel[nameString];
        }
      } else {
        return "";
      }
    }
    return target[nameString];
  }
  return "";
};
/**
 * @description 投与間隔→名称変換
 * @param {Number} code 変換するコード
 * @returns {String} マスタ名称 ※コードがnull: '未登録'、コードがマスタに存在しない: ''
 */
export const dateIntervalCodeToName = (code) => {
  let strName = "";
  if (!code) {
    return "未登録";
  }
  switch (code) {
    case 0:
      strName = "毎回";
      break;
    case 1:
      strName = "毎週";
      break;
    case 2:
      strName = "1回／2週";
      break;
    case 3:
      strName = "1回／3週";
      break;
    case 4:
      strName = "1回／4週";
      break;
    case 5:
      strName = "1回／月：第1曜日";
      break;
    case 6:
      strName = "1回／月：第2曜日";
      break;
    case 7:
      strName = "1回／月：第3曜日";
      break;
    case 8:
      strName = "1回／月：第4曜日";
      break;
    case 9:
      strName = "1回／月：最終曜日";
      break;
    case 10:
      strName = "1回／月：最終治療日";
      break;
    default:
      strName = "";
      break;
  }
  return strName;
};
/*add FNSI-改修内容5204 任 start*/
//  mod DWが登録されているのにも関わらず、DWの欄に「未登録」と表示される 6523  関 start
// export const getDwFromMst = (rstDialysisState,code,patUniques,nameList) => {
export const getDwFromMst = (rstDialysisState,code,patUniques,nameList,treatDate) => {
  // mod DWが登録されているのにも関わらず、DWの欄に「未登録」と表示される 6523  関 end
  if (rstDialysisState !== "0") {
    return code ? code : null;
  }else{
    const patUnique = patUniques.find(el => el.pat_id === nameList[0].pat_id);
    if (patUnique.physical_info) {
      let physical_info = JSON.parse(patUnique.physical_info);
      let physicalInfo = null;
      physical_info.forEach(item => {
        if (physicalInfo) {
          if (item.indicator_start_date && item.indicator_start_date > physicalInfo.indicator_start_date) {
            physicalInfo = item;
          }
        } else {
          if (item.indicator_start_date) {
            physicalInfo = item;
          }
        }
      });
      // add DWが登録されているのにも関わらず、DWの欄に「未登録」と表示される 6523  関 start
      let arrTemp = [];
      let b = null;
      let indexSort = null;
      if (physical_info != null){
        physical_info.forEach(item => {
          var reg = new RegExp("-","g");
          var a = item.exam_date.replace(reg,"");
          if (a === treatDate){
            arrTemp.push(item.dw)
          }
        });
      }
      //add DW 同じ時間内の日付がない場合は、日付内の最大値をとります。 6523  高 start
      physical_info = physical_info.filter((item) =>{
        return item.dw !== null && item.dw != undefined
      })
      if(arrTemp.length  === 0){
        let treatDateMoment = new Date(moment(treatDate).format("YYYY-MM-DD")).getTime();
        physical_info.sort((a, b) => {
          let aExamDate = new Date(moment(a.exam_date).format("YYYY-MM-DD")).getTime();
          let bExamDate = new Date(moment(b.exam_date).format("YYYY-MM-DD")).getTime();
          return aExamDate - bExamDate;
        });
        for(const item of physical_info){
          if(b == null){
            b = new Date(moment(item.exam_date).format("YYYY-MM-DD")).getTime();
            arrTemp.push(item.dw)
          }else{
            const a  = new Date(moment(item.exam_date).format("YYYY-MM-DD")).getTime();
            if(a > b){
              if( a < treatDateMoment || a == treatDateMoment){
                b = a
                arrTemp.push(item.dw)
              }
            }
          }
        }
      }
      // add DW 同じ時間内の日付がない場合は、日付内の最大値をとります。 6523  高 end
      // add DWが登録されているのにも関わらず、DWの欄に「未登録」と表示される 6523  関 end
      // if (physicalInfo) {
      //   return physicalInfo.dw;
      // }
      //add FNSi6523DWが登録されているのにも関わらず、DWの欄に「未登録」と表示される 周 start
      // mod DWが登録されているのにも関わらず、DWの欄に「未登録」と表示される 6523  関 start
      // if(physical_info.length > 0) {
      //   return physical_info[0].dw;
      // }
      if(arrTemp.length > 0) {
        return arrTemp[arrTemp.length-1]
      }
      // mod DWが登録されているのにも関わらず、DWの欄に「未登録」と表示される 6523  関 end
      //add FNSi6523DWが登録されているのにも関わらず、DWの欄に「未登録」と表示される 周 end
    }
    return null;
  }
}

export const getUnit = (rstDialysisState, medicine , medicine_mix, code, name, medicine_type) => {
  if (rstDialysisState !== "0") {
    return ' ' + (name === null ? '' : name);
  }else{
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //if(medicine_type === "2"){
    if(medicine_type == 2){
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      // Mod #9973 By Tao.zhou fix the type of JSON value node. Start Since 2023-10-27
    //   const param = medicine_mix.find(el => el.medicineMixCd === code);
      const param = medicine_mix.find(el => el.medicineMixCd == code);
      return param ? ' ' + (param.unit === null ? '' : param.unit) : '';
    }else{
      // const item = medicine.find(el => el.medicineCd === code);
      const item = medicine.find(el => el.medicineCd == code);
      return item ? ' ' + (item.unit === null ? '' : item.unit) : '';
      // Mod #9973 By Tao.zhou fix the type of JSON value node. End Since 2023-10-27
    }
  }
};
/*add FNSI-改修内容5204 任 end*/

// add #6523 DWが登録されているのにも関わらず、DWの欄に「未登録」と表示される dou start
export const getTimeFromMins = (mins) => {
  if (!mins || mins < 0) {
    return;
  }
  let h = mins / 60 | 0;
  let m = mins % 60 | 0;
  return moment().hours(h).minutes(m).format("HH:mm");
}
// add #6523 DWが登録されているのにも関わらず、DWの欄に「未登録」と表示される dou end
