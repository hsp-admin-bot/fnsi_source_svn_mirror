/**
 * 投与薬剤中止 popup：currentOrdMainData から実績表示名を解決（valid-ind 医療材料と同様）
 */

function parseMediJsonArray(raw) {
  if (raw == null || raw === "" || raw === "[]") return [];
  try {
    const arr = JSON.parse(raw);
    return Array.isArray(arr) ? arr : [];
  } catch {
    return [];
  }
}

function rowMedicineType(row) {
  const t = row?.medicine_type ?? row?.medicineType;
  return t != null && t !== "" ? String(t) : "";
}

export function mediInfoMapKey(cd, medicineType) {
  const type =
    medicineType != null && medicineType !== "" ? String(medicineType) : "";
  return `${String(cd)}_${type}`;
}

function findMediRow(arr, cd, medicineType) {
  if (!Array.isArray(arr)) return null;
  return (
    arr.find(it => {
      if (String(it?.cd) !== String(cd)) return false;
      if (medicineType == null || medicineType === "") return true;
      return rowMedicineType(it) === String(medicineType);
    }) || null
  );
}

function resolveMediRowName(indRow, rstRow) {
  const indName = indRow?.name;
  if (indName != null && indName !== "") return String(indName);
  const rstName = rstRow?.name;
  if (rstName != null && rstName !== "") return String(rstName);
  return "";
}

/** compose / 白名单行から薬剤コードを取得 */
export function resolveMedicineItemCd(item) {
  if (item == null) return null;
  const cd =
    item.medicineCd ??
    item.medicineMixCd ??
    item.key_cd ??
    item.keyCd ??
    item.value;
  return cd != null && cd !== "" ? cd : null;
}

/** 実績時：indMediInfo / rstMediInfo を cd+medicine_type -> { name, unit } の Map に展開 */
export function buildRstMediInfoMap(currentOrdMainData) {
  const data = currentOrdMainData?.data ?? currentOrdMainData;
  if (!data || Number(data.rstDialysisState || 0) === 0) {
    return null;
  }

  const indRaw = data.indMediInfo ?? data.ind_medi_info;
  const rstRaw = data.rstMediInfo ?? data.rst_medi_info;
  const indArr = parseMediJsonArray(indRaw);
  const rstArr = parseMediJsonArray(rstRaw);
  const map = new Map();
  const seen = new Set();

  [...indArr, ...rstArr].forEach(row => {
    if (row?.cd == null || row.cd === "") return;
    const rowType = rowMedicineType(row);
    const key = mediInfoMapKey(row.cd, rowType);
    if (seen.has(key)) return;
    seen.add(key);

    const indRow = findMediRow(indArr, row.cd, rowType);
    const rstRow = findMediRow(rstArr, row.cd, rowType);

    map.set(key, {
      name: resolveMediRowName(indRow, rstRow),
      unit:
        (indRow?.unit != null && indRow.unit !== "" ? String(indRow.unit) : "") ||
        (rstRow?.unit != null && rstRow.unit !== "" ? String(rstRow.unit) : ""),
    });
  });

  return map;
}

export function resolveSuspendMedicineRstName(rstMediInfoMap, cd, medicineType) {
  if (!rstMediInfoMap || cd == null) return "";
  const type = medicineType != null && medicineType !== "" ? String(medicineType) : "";
  const exact = rstMediInfoMap.get(mediInfoMapKey(cd, type));
  if (exact?.name) return exact.name;
  if (type !== "") {
    const loose = rstMediInfoMap.get(mediInfoMapKey(cd, ""));
    if (loose?.name) return loose.name;
  }
  for (const [key, row] of rstMediInfoMap.entries()) {
    if (String(key).startsWith(`${String(cd)}_`) && row?.name) return row.name;
  }
  return "";
}

/** compose 行の薬剤区分（key_type 欠落時のフォールバック） */
export function resolveMedicineItemType(item) {
  const t = item?.key_type ?? item?.keyType;
  if (t != null && t !== "") return String(t);
  if (item?.medicineMixCd != null && item.medicineMixCd !== "") return "2";
  if (item?.medicineCd != null && item.medicineCd !== "") return "1";
  if (item?.medicineMixName != null && item.medicineMixName !== "") return "2";
  if (item?.medicineName != null && item.medicineName !== "") return "1";
  return null;
}

export function resolveAllowedMedicineType(opt) {
  const t = opt?.medicineType ?? opt?.medicine_type;
  return t != null && t !== "" ? String(t) : "1";
}

/** 白名单にあって compose 側に無い行を追加（中止 popup が空になるのを防ぐ） */
export function appendMissingAllowedMedicineOptions(
  filteredItems,
  allowedData,
  { suspendRstMediMap, isActualRst, masterItems }
) {
  if (!Array.isArray(allowedData) || !allowedData.length) return filteredItems;

  const result = [...filteredItems];
  const hasEntry = (cd, medType) =>
    result.some(item => {
      const icd = resolveMedicineItemCd(item);
      const itype = resolveMedicineItemType(item);
      return String(icd) === String(cd) && String(itype) === String(medType);
    });

  allowedData.forEach(opt => {
    if (opt?.cd == null || opt.cd === "") return;
    const medType = resolveAllowedMedicineType(opt);
    if (hasEntry(opt.cd, medType)) return;

    const masterRow = Array.isArray(masterItems)
      ? masterItems.find(i => {
          const icd = resolveMedicineItemCd(i);
          return (
            String(icd) === String(opt.cd) &&
            String(resolveMedicineItemType(i)) === String(medType)
          );
        })
      : null;
    const masterName =
      masterRow?.medicineName ??
      masterRow?.medicineMixName ??
      masterRow?.text ??
      "";

    const rstName =
      isActualRst && suspendRstMediMap
        ? resolveSuspendMedicineRstName(suspendRstMediMap, opt.cd, medType)
        : "";
    const isMix = medType === "2";
    result.push({
      value: opt.cd,
      medicineCd: isMix ? null : opt.cd,
      medicineMixCd: isMix ? opt.cd : null,
      key_type: medType,
      keyType: medType,
      key_cd: opt.cd,
      class: masterRow?.classCd ?? masterRow?.class ?? null,
      text: rstName || masterName || String(opt.cd),
    });
  });

  return result;
}
