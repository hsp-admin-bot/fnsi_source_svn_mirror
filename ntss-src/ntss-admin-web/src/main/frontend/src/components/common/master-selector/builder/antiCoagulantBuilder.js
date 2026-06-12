/**
 * 抗凝薬マスター Builder
 *
 * 【外部公開】
 * ・buildMasterPopover(params)
 * ・buildInitSelectedItem(params)
 *
 * 【責務】
 * ・抗凝薬マスタDB取得
 * ・Popover表示データ構築
 * ・初期選択／編集選択値構築
 */
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
//import * as Mst from "@/functions/mst/MstGetters.js";

//import { getPrefix } from "@/functions/common/CommonFunctions.js";
import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord.js";
import { fitTermCheck } from "@/functions/common/DateTimeUtils";
import { ApiHelper } from "@/apis/AxiosHelper";
import { getMstListCompose } from "@/apis/pat-prescription"

// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
/** 定数 */
const CLASS_MISMATCH_LABEL = "【分類不一致】";

/* =========================================================
 * 外部公開
 * ======================================================= */

/**
 * 初期選択項目構築
 */
export async function buildInitSelectedItem(params) {
  return fetchInitSelectedItem(params);
}

/**
 * 抗凝薬ポップオーバー構築
 */
export async function buildMasterPopover(params) {
  const raw = await fetchMasterData(params);
  if (!raw) return null;
  const popoverData = await createMasterPopover(raw, params);
  return popoverData;
}

/* =========================================================
 * DBアクセス
 * ======================================================= */

/**
 * マスタ情報を取得
 */
async function fetchMasterData({ facilityCd,patientId }) {
  
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
  try {
    //const [mstMedicine, mstMedicineMix, classData, pharmaList] = await Promise.all([
    //const { mstMedicine, mstMedicineMix, classDat } = await Promise.all([
      //Mst.medicineAllergy(patientId, true),
      //Mst.medicineMixAllergy(patientId, true),
      //Mst.medicineClass(facilityCd)
    //]);
    //const res = await getPharmaceuticalManagement(facilityCd);
    const item = {
      lists: [
        {
          id: "list1",
          name: "固定分类",
          sourceType: "FIXED",
          fixedItems: [
            { value: 0, text: "すべて" },
            { value: "1", text: "通常薬剤" },
            { value: "2", text: "調製薬剤" }
          ],
          keyMapping: [
            { keyName: "key_type", valueFrom: "value" }
          ]
        },
        {
          id: "list2",
          name: "药剂分类MST",
          sourceType: "MST",
          mstSource: {
            mstCode: "mstMedicineClassDaoImpl",
            sqlParams: { facilityCd: facilityCd }
          },
          keyMapping: [
            { keyName: "key_class", valueFrom: "classCd" }
          ]
        },
        {
          id: "list3",
          name: "通常药剂 + 调制药剂 合并",
          sourceType: "MST_COMBINED",
          mstSourceList: [
            {
              mstCode: "mstMedicineDaoImpl",
              sourceTag: "1",
              sqlParams: { facilityCd: facilityCd,patId:patientId ? String(patientId) : null },
              keyMapping: [
                { keyName: "key_type", valueFrom: "sourceTag" },
                { keyName: "key_class", valueFrom: "classCd" },
                { keyName: "key_cd", valueFrom: "medicineCd" }
              ]
            },
            {
              mstCode: "mstMedicineMixDaoImpl",
              sourceTag: "2",
              sqlParams: { facilityCd: facilityCd,patId:patientId ? String(patientId) : null },
              keyMapping: [
                { keyName: "key_type", valueFrom: "sourceTag" },
                { keyName: "key_class", valueFrom: "classCd" },
                { keyName: "key_cd", valueFrom: "medicineMixCd" }
              ]
            }
          ]
        }
      ]
    }
    const res = await getMstListCompose(item);
    
    //return { mstMedicine, mstMedicineMix, classData, pharmaList };
    return res.data;
  } catch (e) {
    console.error("[antiCoagulantBuilder] マスタ取得失敗", e);
    throw e;
  }
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
}

/**
 * APIから薬剤情報を取得
 */
async function getMedicineInfoByCd(medicineCd, medicineType) {
  try {
    const response = await ApiHelper.get("/mstInfo/mstMedicine/getByCd", {
      medicineCd: medicineCd,
      medicineType: medicineType
    });
    return response;
  } catch (error) {
    console.error("[antiCoagulantBuilder] 薬剤情報取得失敗", error);
    throw error;
  }
}

/* =========================================================
 * 内部Builderロジック
 * ======================================================= */

/**
 * Popover構築
 */
async function createMasterPopover(raw, context) {
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
  //const medicineList = raw.mstMedicine || [];
  //const medicineMixList = raw.mstMedicineMix || [];
  //const classList = raw.classData || [];
  //const medicineList = raw.MEDICINE || [];
  //const medicineMixList = raw.MEDICINEMIX || [];
  //const classList = raw.MEDICINEClASS || [];
  const medicineList =  raw.lists.list3.items.filter(item => item.key_type == 1) || [];
  const medicineMixList = raw.lists.list3.items.filter(item => item.key_type == 2) || [];
  
  const classList = raw.lists.list2.items || [];
  const kbnList = raw.lists.list1.items || [];
  const { initItem, selectedItem, extraParams } = context;
  const treatDate = extraParams.treatDate;
  const rstName = extraParams.rstInfo.rstName || '';
  const rstUnit = extraParams.rstInfo.rstUnit || '';

  const categories = buildCategories(classList,kbnList,context);
  const options = buildMasterOptions({
    medicineList,
    medicineMixList,
    categories,
    treatDate,
    rstName,
    rstUnit,
    initItem,
    selectedItem,
    context
  });
  // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end

  const popoverData = {
    headerTitle: "薬剤",
    categories,
    master: {
      key: "master",
      label: "薬剤名",
      options,
      selectedItem: options.find(o => String(o.value) === String(selectedItem.value)) || null
    }
  }

  return popoverData;
}

/**
 * 初期選択項目構築
 */
async function fetchInitSelectedItem(context) {
  const { initItem, selectedItem, extraParams } = context;
  const { isMedicineTypeMix, isIndication, rstInfo } = extraParams || {};

  // 初期値が存在する場合の処理
  if (initItem || selectedItem) {
    const raw = await fetchMasterData(context);
    const popoverData = await createMasterPopover(raw, context);
    const initValue = initItem && initItem.value;
    const editValue = selectedItem && selectedItem.value;
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    //const initTarget = isMedicineTypeMix ? initValue + "$" : initValue;
    //const editTarget = isMedicineTypeMix ? editValue + "$" : editValue;
    const initTarget = initValue;
    const editTarget = editValue;
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
    const options = popoverData.master.options || [];
    const selectedMst = options.find(item => item.value == initTarget);
    const selectedEditMst = options.find(selectedItem => selectedItem.value == editTarget)
    if (selectedMst || selectedEditMst) {
      if (rstInfo && rstInfo.rstName) {
        if (selectedMst) {
          selectedMst.text = selectedMst.rstName;
          selectedMst.unit = selectedMst.rstUnit;
        }
        if (selectedEditMst) {
          selectedEditMst.text = selectedEditMst.rstName;
          selectedEditMst.unit = selectedEditMst.rstUnit;
        }
      }
      return {
        initItem: selectedMst || null,
        selectedItem: isIndication ? selectedEditMst : selectedMst
      };
    }

    // ===== マスタに存在しない場合はAPIから再取得する =====
    if (initValue) {
      try {
        const res = await getMedicineInfoByCd(initValue, isMedicineTypeMix);
        if (res && res.data) {
          const medicineName = isMedicineTypeMix
            ? res.data.medicineMixName
            : res.data.medicineName;

          const mstClassValue = (raw.classData || []).find(function (mstData) {
            return mstData.classCd === res.data.classCd;
          });
          var resultItem = Object.assign({}, res.data);

          // 分類不一致
          if ((mstClassValue && mstClassValue.classType !== 1) || res.data.classCd === -1) {
            resultItem.text = CLASS_MISMATCH_LABEL + medicineName;
          } else {
            resultItem.text = medicineName;
          }

          // 削除・非表示
          if (!(res.data.isDisp == "1" && res.data.isDel == "0")) {
            resultItem.text = MASTER_DELETE_DISPLAY.DELETED + resultItem.text;
          }
          // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
          //resultItem.value = isMedicineTypeMix ? initValue + "$" : initValue;
          resultItem.value = isMedicineTypeMix ? initValue : initValue;
          // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
          return {
            initItem: resultItem,
            selectedItem: resultItem
          };
        }
      } catch (err) {
        console.error("[antiCoagulantBuilder] 薬剤情報取得失敗", err);
        throw err;
      }
    }
  }

  return {
    initItem: initItem,
    selectedItem: selectedItem
  };
}

/**
 * カテゴリオプションを構築
 */

// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
function buildCategories(classList,kbnList,context) {
  /*const classOptions = classList
    .filter(i => i.classType === 1)
    .map(i => ({ text: i.className, value: i.classCd }));
  */

  const classOptions = classList
    .filter(i => context.isMedicament == 1 ? i.classType === 1 : true )
    .map(i => ({ text: i.className, value: i.classCd }));
  classOptions.unshift({ text: "すべて", value: 0 });
  
  const kbnOptions = kbnList
    .map(i => ({ text: i.text, value: i.value }));
  return [
    {
      key: "kbn",
      label: "薬剤区分",
      value: 0,
      options: kbnOptions
      /*[
        { text: "すべて", value: 0 },
        { text: "通常薬剤", value: "1" },
        { text: "調製薬剤", value: "2" }
      ]*/
    },
    {
      key: "class",
      label: "薬剤分類",
      value: 0,
      options: classOptions
    }
  ];
}
/**
 * マスタオプションを構築
 */
function buildMasterOptions({
  medicineList,
  medicineMixList,
  categories,
  treatDate,
  rstName,
  rstUnit,
  initItem,
  selectedItem,
  context
}) {
  // 医薬品リストのフィルタリング
  const filteredMedicineList = medicineList.filter(item => {
    // 初期選択項目と一致する場合は常に表示
    if (initItem && String(initItem.value) === String(item.medicineCd)) {
      return true;
    }
    // 有効期限チェック
    return fitTermCheck(item.useStartDate, item.useEndDate, treatDate);
  });

  // 医薬品混合リストのフィルタリング
  const filteredMedicineMixList = medicineMixList.filter(item => {
    // 初期選択項目と一致する場合は常に表示
    if (initItem && String(initItem.value) === String(item.medicineMixCd)) {
      return true;
    }
    // 有効期限チェック
    return fitTermCheck(item.maxUseStartDate, item.minUseEndDate, treatDate);
  });

  // カテゴリオプションの取得
  const classOptions = (categories?.find(category => category.key === "class") || {}).options || [];
  // 医薬品のクラスフィルタリング用関数
  const filterByClass = (item, cd) => {
    return classOptions.some(option => {
      //return item.classCd === option.value ||
      return item.key_class === option.value ||
        (initItem?.value != null && item[cd] == initItem.value) ||
        (selectedItem?.value != null && item[cd] == selectedItem.value);
    });
  };

  // 表示状態フィルタリング用関数
  const filterByDisplayStatus = (item, cd) => {
    return item.isDisp === "1" ||
      (initItem?.value != null && item[cd] == initItem.value) ||
      (selectedItem?.value != null && item[cd] == selectedItem.value);
  };
  const allowedFields = (item, val, cd, type) =>{
    return val.some(option=>{
      return item[cd] == option.cd && item[type] == option.medicineType
    })
  }
  // 医薬品オプションのマッピング関数
  const mapMedicineItem = (item, cdKey, nameKey, unitKey, kbnValue) => {
    /*const prefix = getPrefix({
      treatDate: treatDate,
      normalClassType: 1,
      isRst: rstName ? true : false,
      ...item
    });*/

    let prefix = '';
    let statusText = '';

    if (item.key_type == 2 && item.key_class == -1) {
      prefix = CLASS_MISMATCH_LABEL;
    }

    if (context.dialysisState == 0) {
      statusText = `${item.expired}${item.deleted}${item.includeDeleted}`;
    }
    
    return {
      ...item,
      //rstName: rstName ? prefix + rstName : "",
      rstName: rstName,
      rstUnit: rstUnit ? rstUnit : "",
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
      //value: kbnValue === "1" ? item[cdKey] : `${item[cdKey]}$`,
      value: kbnValue === "1" ? item[cdKey] : `${item[cdKey]}`,
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
      kbnValue: kbnValue,
      classValue: item.classCd,
      unit: item[unitKey],
      //text: prefix + item[nameKey]
      //text: (item.key_type == 2 && item.key_class == -1 ? CLASS_MISMATCH_LABEL : '') + item.tabooAllergy + item.expired + item.deleted + item.includeDeleted + item[nameKey]
      text: prefix + item.tabooAllergy + statusText + item[nameKey],
    };
  };
  // 医薬品オプションの生成
  let contentMedicine;
  let contentMedicineMix;
  if(context.allowedFields.showMedicineFieldOnly){
    contentMedicine = filteredMedicineList
      //.filter(item => context.isMedicament==1? filterByClass(item, "medicineCd"): true)
      //.filter(item => filterByDisplayStatus(item, "medicineCd"))
      .filter(item => allowedFields(item, context.allowedFields.data, "medicineCd","key_type"))
      .map(item => mapMedicineItem(item, "medicineCd", "medicineName", "unit", "1"))

      // 医薬品混合オプションの生成
    contentMedicineMix = filteredMedicineMixList
      //.filter(item => context.isMedicament==1? filterByClass(item, "medicineMixCd"): true)
      //.filter(item => filterByDisplayStatus(item, "medicineMixCd"))
      .filter(item => allowedFields(item, context.allowedFields.data, "medicineMixCd","key_type"))
      .map(item => mapMedicineItem(item, "medicineMixCd", "medicineMixName", "unit", "2"))
  }else{
    contentMedicine = filteredMedicineList
    .filter(item => context.isMedicament==1? filterByClass(item, "medicineCd"): true)
    .filter(item => filterByDisplayStatus(item, "medicineCd"))
    .map(item => mapMedicineItem(item, "medicineCd", "medicineName", "unit", "1"))
    //.filter(item => context.allowedFields.showMedicineFieldOnly? allowedFields(item, context.allowedFields.data, "medicineCd","key_type"): true)

  // 医薬品混合オプションの生成
  contentMedicineMix = filteredMedicineMixList
    .filter(item => context.isMedicament==1? filterByClass(item, "medicineMixCd"): true)
    .filter(item => filterByDisplayStatus(item, "medicineMixCd"))
    .map(item => mapMedicineItem(item, "medicineMixCd", "medicineMixName", "unit", "2"))
    //.filter(item => context.allowedFields.showMedicineFieldOnly? allowedFields(item, context.allowedFields.data, "medicineMixCd","key_type"): true)
  }
  const merged = [...contentMedicine, ...contentMedicineMix]
    .sort((a, b) => b.isDisp - a.isDisp);
  return merged;
}

// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
export default {
  buildMasterPopover,
  buildInitSelectedItem
}