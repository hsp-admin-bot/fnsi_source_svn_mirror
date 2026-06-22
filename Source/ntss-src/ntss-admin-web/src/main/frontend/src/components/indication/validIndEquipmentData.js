/**
 * 指示有効な医療材料選択：データ取得・リスト構築・接頭辞付与（Mixin / Builder 共用）
 */
import { ApiHelper } from "@/apis/AxiosHelper";
import { shapeSelectionItem } from "@/functions/for-componet/ListSelector";
import {
  dialyzerTabooAllergyDeleted,
  equipmentAllergy,
  equipmentClass,
} from "@/functions/mst/MstGetters.js";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { getPrefix } from "@/functions/common/CommonFunctions";
import {
  encryptPersistentCodeToInternalCd,
  decryptDialyzerCdToPersistentCode,
} from "@/functions/EquipTypeFunctions";

const CATEGORY_KEY = "医療材料分類";

export function shapeDateFormat(date) {
  if (date == null) return null;
  return Number(String(date).replaceAll("-", ""));
}

export function isActualRstDialysisState(currentOrdMainData) {
  return (
    currentOrdMainData &&
    currentOrdMainData.data &&
    currentOrdMainData.data.rstDialysisState != 0
  );
}

/** 実績時：indEquipInfo を cd -> { name, unit } の Map に展開 */
export function buildRstEquipInfoMap(currentOrdMainData) {
  if (!isActualRstDialysisState(currentOrdMainData)) {
    return null;
  }
  const rstEquipInfo = currentOrdMainData.data.indEquipInfo;
  const arr = rstEquipInfo ? JSON.parse(rstEquipInfo) : [];
  const map = new Map();
  (arr || []).forEach(row => {
    if (row && row.cd != null && row.cd !== "") {
      map.set(String(row.cd), {
        name: row.name != null && row.name !== "" ? String(row.name) : "",
        unit: row.unit != null && row.unit !== "" ? String(row.unit) : "",
      });
    }
  });
  return map;
}

export function resolveRstEquipName(currentOrdMainData, cd) {
  if (!isActualRstDialysisState(currentOrdMainData) || cd == null) {
    return "";
  }
  const map = buildRstEquipInfoMap(currentOrdMainData);
  const row = map && map.get(String(cd));
  return row && row.name ? row.name : "";
}

/** 一覧行の表示名：実績時は当該 cd の indEquipInfo のみ実績名、それ以外はマスタ＋接頭辞 */
export function resolveOptionDisplayText(item, rawMasterName, treatDate, nameContext) {
  const { isActualRst, rstEquipInfoMap, persistentCd } = nameContext || {};
  const prefixItem = { ...item, treatDate, text: rawMasterName };
  const masterText = getPrefix(prefixItem) + rawMasterName;

  if (!isActualRst || !rstEquipInfoMap || persistentCd == null) {
    return masterText;
  }

  const rstRow = rstEquipInfoMap.get(String(persistentCd));
  if (rstRow && rstRow.name) {
    return rstRow.name;
  }
  return masterText;
}

export function buildMasterLabelText(mstRecord, treatDate) {
  if (!mstRecord) return null;
  const prefixItem = { ...mstRecord, treatDate, text: mstRecord.text };
  return getPrefix(prefixItem) + mstRecord.text;
}

export function setPrefixToEquipmentName(
  item,
  { currentOrdMainData, persistentCd, fieldsDataCd }
) {
  if (item == undefined) return null;
  const cd =
    persistentCd != null
      ? persistentCd
      : fieldsDataCd != null
        ? fieldsDataCd
        : decryptDialyzerCdToPersistentCode(item.value);

  if (isActualRstDialysisState(currentOrdMainData)) {
    const rstName = resolveRstEquipName(currentOrdMainData, cd);
    if (rstName) return rstName;
  }
  return getPrefix(item) + item.text;
}

export function buildValidIndEquipList(cds, master, equipType) {
  if (!cds || !cds[equipType]) {
    return [];
  }
  const equipList = [];
  cds[equipType].forEach(cd => {
    const found = master.find(
      masterRecord =>
        masterRecord.value === encryptPersistentCodeToInternalCd(cd, equipType)
    );
    if (found) equipList.push(found);
  });
  return equipList;
}

export function mapEquipmentToOption(item, treatDate, nameContext) {
  const text = resolveOptionDisplayText(item, item.equipmentName, treatDate, {
    ...nameContext,
    persistentCd: item.equipmentCd,
  });
  const base = {
    value: item.equipmentCd,
    text,
    fnValue: { [CATEGORY_KEY]: item.classCd },
    unit: item.unit,
    isDisp: item.isDisp,
    useStartDate: item.useStartDate,
    useEndDate: item.useEndDate,
    isTaboo: item.isTaboo,
    isAllergy: item.isAllergy,
    treatDate,
    classCd: item.classCd,
  };
  return toMasterPopoverOption(base);
}

export function mapDialyzerToOption(item, treatDate, nameContext) {
  const text = resolveOptionDisplayText(item, item.modelNumber, treatDate, {
    ...nameContext,
    persistentCd: item.dialyzerCd,
  });
  const base = {
    value: encryptPersistentCodeToInternalCd(item.dialyzerCd, 1),
    text,
    fnValue: { [CATEGORY_KEY]: "dialyzer" },
    unit: null,
    isDisp: item.isDisp,
    useStartDate: item.useStartDate,
    useEndDate: item.useEndDate,
    isTaboo: item.isTaboo,
    isAllergy: item.isAllergy,
    treatDate,
    classCd: "dialyzer",
  };
  return toMasterPopoverOption(base);
}

function mapIncludedDeletedEquipment(item, treatDate) {
  return {
    value: item.equipmentCd,
    text: item.equipmentName,
    fnValue: { [CATEGORY_KEY]: item.classCd },
    unit: item.unit,
    isDisp: item.isDisp,
    useStartDate: item.useStartDate,
    useEndDate: item.useEndDate,
    isTaboo: item.isTaboo,
    isAllergy: item.isAllergy,
    treatDate,
    classCd: item.classCd,
  };
}

function mapIncludedDeletedDialyzer(item, treatDate) {
  return {
    value: encryptPersistentCodeToInternalCd(item.dialyzerCd, 1),
    text: item.modelNumber,
    fnValue: { [CATEGORY_KEY]: "dialyzer" },
    unit: null,
    isDisp: item.isDisp,
    useStartDate: item.useStartDate,
    useEndDate: item.useEndDate,
    isTaboo: item.isTaboo,
    isAllergy: item.isAllergy,
    treatDate,
    classCd: "dialyzer",
  };
}

/** MasterPopover 分類フィルタ：fnValue -> category.key フィールド */
export function toMasterPopoverOption(option) {
  const classVal = option.fnValue?.[CATEGORY_KEY];
  return {
    ...option,
    [CATEGORY_KEY]: classVal,
  };
}

export async function fetchValidIndEquipmentsList(facilityCd, patientId, structData) {
  const paramJson = {
    facility_cd: facilityCd,
    pat_id: patientId,
    start_date: shapeDateFormat(structData.indStartDate),
    end_date: !structData.indEndDate ? "" : shapeDateFormat(structData.indEndDate),
    ind_kur_cd: JSON.stringify(structData.selectedKur),
    ind_treatment_cd: JSON.stringify(structData.selectedTreat),
    weeks: JSON.stringify(structData.indWeeks),
  };
  const response = await ApiHelper.post("/mainData/validIndEquipmentsList", paramJson).catch(
    error => {
      getErrorMessage("validIndEquipmentData.js", "fetchValidIndEquipmentsList", error);
      throw error;
    }
  );
  return response.data;
}

export async function loadValidIndMasterData(facilityCd, patientId, treatDate) {
  const [mstEquipmentClass, mstEquipment, mstDialyzer] = await Promise.all([
    equipmentClass(facilityCd),
    equipmentAllergy(patientId, true),
    dialyzerTabooAllergyDeleted(patientId),
  ]).catch(error => {
    getErrorMessage("validIndEquipmentData.js", "loadValidIndMasterData", error);
    throw error;
  });

  const mstEquipmentDialyzerIncludedDeleted = [
    ...mstEquipment.map(item => mapIncludedDeletedEquipment(item, treatDate)),
    ...mstDialyzer.map(item => mapIncludedDeletedDialyzer(item, treatDate)),
  ];

  return {
    mstEquipmentClass,
    mstEquipment,
    mstDialyzer,
    mstEquipmentDialyzerIncludedDeleted,
  };
}

/**
 * 指示有効リスト + 接頭辞付き options を MasterPopover 形式で構築
 */
export async function buildValidIndEquipmentListData(params) {
  const {
    facilityCd,
    patientId,
    structData,
    fieldsData,
    showAllSelectTag,
    selectedEquipment,
    mstEquipmentClass,
    mstEquipment,
    mstDialyzer,
    mstEquipmentDialyzerIncludedDeleted,
    currentOrdMainData,
    validIndEquipments: validIndEquipmentsInput,
    refreshValidList = false,
  } = params;

  if (!structData || !structData.indWeeks) {
    return null;
  }

  let validIndEquipments = validIndEquipmentsInput;
  if (refreshValidList && facilityCd && patientId) {
    validIndEquipments = await fetchValidIndEquipmentsList(
      facilityCd,
      patientId,
      structData
    );
  }

  const indStartDate = structData.indStartDate;
  const isActualRst = isActualRstDialysisState(currentOrdMainData);
  const rstEquipInfoMap = buildRstEquipInfoMap(currentOrdMainData);
  const nameContext = { isActualRst, rstEquipInfoMap };
  const rstNameForCd = isActualRst
    ? resolveRstEquipName(currentOrdMainData, fieldsData?.cd) || null
    : null;

  const filterArr = mstEquipmentClass.map(item => ({
    text: item.className,
    value: item.classCd,
  }));
  filterArr.push({ text: "ダイアライザ", value: "dialyzer" });

  const contentArr = mstEquipment.map(item =>
    mapEquipmentToOption(item, indStartDate, nameContext)
  );
  const contentDialyzer = mstDialyzer.map(item =>
    mapDialyzerToOption(item, indStartDate, nameContext)
  );

  let validIndContentsArr = [];
  if (validIndEquipments) {
    validIndContentsArr = buildValidIndEquipList(validIndEquipments, contentArr, 0);
    validIndContentsArr.push(
      ...buildValidIndEquipList(validIndEquipments, contentDialyzer, 1)
    );
  }

  if (showAllSelectTag) {
    shapeSelectionItem(filterArr);
  }

  let selectedEquipmentCd = fieldsData?.cd;
  let selectedEquipmentEquipType = fieldsData?.equipType;
  if (selectedEquipment?.cd) {
    selectedEquipmentCd = selectedEquipment.cd;
    selectedEquipmentEquipType = selectedEquipment.equipType;
  }

  const selectedValue = encryptPersistentCodeToInternalCd(
    selectedEquipmentCd,
    selectedEquipmentEquipType
  );

  const selectedItem =
    validIndContentsArr.find(o => String(o.value) === String(selectedValue)) ||
    mstEquipmentDialyzerIncludedDeleted.find(
      o => String(o.value) === String(selectedValue)
    ) ||
    null;

  const mstRecordForSelected = mstEquipmentDialyzerIncludedDeleted.find(
    o => String(o.value) === String(selectedValue)
  );
  const masterLabelForCd = mstRecordForSelected
    ? buildMasterLabelText(mstRecordForSelected, indStartDate)
    : null;

  return {
    validIndEquipments,
    options: validIndContentsArr,
    filterArr,
    selectedItem: selectedItem ? toMasterPopoverOption(selectedItem) : null,
    masterLabelForCd,
    rstNameForCd,
    selectedValue,
  };
}

export function resolveInitialEquipmentDisplay(
  cd,
  equipType,
  mstEquipmentDialyzerIncludedDeleted,
  prefixCtx
) {
  if (!cd) return null;
  const selectedItem = mstEquipmentDialyzerIncludedDeleted.find(
    equipment => equipment.value == encryptPersistentCodeToInternalCd(cd, equipType)
  );
  if (selectedItem) {
    return setPrefixToEquipmentName(selectedItem, {
      ...prefixCtx,
      persistentCd: cd,
    });
  }
  return null;
}

export { CATEGORY_KEY };
