

const MASTER_CHANGED_PREFIX = "【ﾏｽﾀ変更有】";

function isActualRstDialysisState(context) {
  if (context == null) return false;
  const ds = context.dialysisState;
  if (ds == null || ds === "") return false;
  return Number(ds) !== 0;
}

function stripLeadingMasterChangeMarkersOnly(text) {
  return String(text || "").replace(/^(【ﾏｽﾀ変更有】)+/g, "");
}

const TEXT_COMPARE_PREFIXES = [
  "【禁忌・ｱﾚﾙｷﾞｰ】",
  "【禁忌】",
  "【ｱﾚﾙｷﾞｰ】",
  "【期限切れ】",
  "【分類不一致】",
  "【削除済み含む】",
  "【削除済み】",
  "【ﾏｽﾀ変更有】"
];

function stripLeadingTextCompareMarkers(text) {
  let s = String(text || "");
  let changed = true;
  while (changed) {
    changed = false;
    for (const p of TEXT_COMPARE_PREFIXES) {
      if (s.startsWith(p)) {
        s = s.slice(p.length);
        changed = true;
        break;
      }
    }
  }
  return s;
}

export function normalizeTextForCompare(text) {
  return stripLeadingTextCompareMarkers(String(text || ""));
}

/**
 * 「未登録」または空行オプションかどうか
 * @param {Object} item
 * @returns {Boolean}
 */
export function isUnregisteredMasterItem(item) {
  if (!item) return false;
  const value = item.value;
  if (value != null && value !== "") return false;
  const text = item.text;
  return text === "未登録" || text === "" || text == null;
}

/**
 * POP 用の未登録選択オブジェクトを生成
 * @param {Object} item
 * @returns {{ text: string, value: null }}
 */
export function buildUnregisteredMasterItem(item) {
  const text = item?.text;
  return {
    text: text === "" ? "" : (text || "未登録"),
    value: null
  };
}

export function appendChangedOptionsIfNeeded(popoverData, context) {
  const { initItem, selectedItem, hasChangedOption, changeOptionMode } = context

  // 投与薬剤中止（getPatIndMmdicine 白名单）：データ源が異なるため【ﾏｽﾀ変更有】行は付けない
  if (context?.allowedFields?.showMedicineFieldOnly === true) {
    return;
  }

  if (!hasChangedOption || !selectedItem) {
    return;
  }

  // 「未登録」は master.options に含まれないため、initItem で上書きしない
  if (isUnregisteredMasterItem(selectedItem)) {
    if (popoverData?.master) {
      popoverData.master.selectedItem = buildUnregisteredMasterItem(selectedItem);
    }
    return;
  }
  const isValid =
    (selectedItem.isDisp === undefined || selectedItem.isDisp === "1") &&
    (selectedItem.isDel === undefined || selectedItem.isDel === "0");

  if (isValid) {
    // 初期値の名称または単位が変更された場合、末尾に追記して表示する。
    pushItemToPopover(popoverData, initItem, changeOptionMode, context);
    if (initItem && initItem.text !== selectedItem.text) {
      // 選択値の名称または単位が変更された場合、末尾に追記して表示する。
      pushItemToPopover(popoverData, selectedItem, changeOptionMode, context);
    }
  }
  appendIndMedicineMasterChangeWhenProcedureTimingOnly(
    popoverData,
    selectedItem,
    changeOptionMode,
    context
  );
}

export function removePrefixFromOptions(item, _context) {
  if (item == null || item.text == null || item.text === "") return item;
  return {
    ...item,
    text: stripLeadingMasterChangeMarkersOnly(item.text)
  };
}

/**
 * リスト先頭に「未登録」および空行オプションを付加する
 * @param {Array} list 元データリスト
 * @param {Boolean} hasUnregisteredOption 「未登録」オプション表示フラグ
 * @param {Boolean} popoverBlankLine 空行挿入フラグ
 * @returns {Array}
 */
export function appendUnregisteredOption(
  list,
  hasUnregisteredOption,
  popoverBlankLine
) {
  const ret = [...(list || [])];

  if (hasUnregisteredOption === false) return ret;

  if (popoverBlankLine) {
    ret.unshift({ text: "", value: null });
    return ret;
  }

  if (ret.length === 0 || ret[0]?.value !== null) {
    ret.unshift({ text: "未登録", value: null });
  }

  return ret;
}

/**
 * Master システムエラー
 * @param {Vue} vm
 * @param {Error} error
 * @param {String} from
 */
export function handleMasterLoadError(vm, error, from) {
  console.error("[MasterError]", from, error);

  // getErrorMessage(
  //   "CommonMasterSelector.vue",
  //   from,
  //   "システムエラーが発生しました"
  // );

  // vm.$ons.notification.alert({
  //   title: DIALOG_MESSAGES["00200002"].title,
  //   message: messageFormat(DIALOG_MESSAGES["00200002"].message),
  // });

  vm.$router.push({ name: "signin" });
}

function appendIndMedicineMasterChangeWhenProcedureTimingOnly(
  popoverData,
  selectedItem,
  changeOptionMode,
  context
) {
  const extraParams = context?.extraParams;
  const compareProcedure = extraParams?.compareProcedure === true;
  const compareTiming = extraParams?.compareTiming === true;
  const compareReceiptUnit = extraParams?.compareReceiptUnit === true;
  const enabled = compareProcedure || compareTiming || compareReceiptUnit;
  if (!enabled) {
    return;
  }
  const selValid =
    selectedItem &&
    (selectedItem.isDisp === undefined || selectedItem.isDisp === "1") &&
    (selectedItem.isDel === undefined || selectedItem.isDel === "0");
  if (
    !isActualRstDialysisState(context) ||
    !selValid ||
    !selectedItem?.value ||
    !selectedItem?.text ||
    !popoverData.master?.options?.length
  ) {
    return;
  }

  const foundItem = popoverData.master.options.find(
    o => String(o.value) === String(selectedItem.value)
  );
  if (!foundItem) return;
  if (!hasIndMedicineDiffFromMaster(foundItem, selectedItem, extraParams)) {
    return;
  }

  const body = stripLeadingMasterChangeMarkersOnly(String(selectedItem.text));
  const renamedText = `${MASTER_CHANGED_PREFIX}${body}`;

  const currentProcedureCd =
    extraParams?.procedureCd ??
    extraParams?.currentProcedureCd ??
    selectedItem?.procedureCd ??
    selectedItem?.procedure_cd ??
    null;
  const currentTimingCd =
    extraParams?.timingCd ??
    extraParams?.currentTimingCd ??
    selectedItem?.medicateTimingCd ??
    selectedItem?.medicate_timing_cd ??
    selectedItem?.timingCd ??
    selectedItem?.timing_cd ??
    null;

  const attachMasterChangedRowFlags = row => {
    if (!row) return;
    row.procedureCd = currentProcedureCd ?? row.procedureCd;
    row.medicateTimingCd = currentTimingCd ?? row.medicateTimingCd;
    row.unitSecond =
      extraParams?.receiptUnit != null && extraParams?.receiptUnit !== ""
        ? String(extraParams.receiptUnit)
        : row.unitSecond;
    row.__isMasterChangedRow = true;
    row.__procedureCd = currentProcedureCd ?? null;
    row.__timingCd = currentTimingCd ?? null;
  };

  const existing = popoverData.master.options.find(
    o => String(o.value) === String(selectedItem.value) && o.text === renamedText
  );
  if (existing) {
    attachMasterChangedRowFlags(existing);
    popoverData.master.selectedItem = existing;
    return;
  }

  const rowValid =
    (foundItem.isDisp === undefined || foundItem.isDisp === "1") &&
    (foundItem.isDel === undefined || foundItem.isDel === "0");
  if (!rowValid) return;

  const unit =
    changeOptionMode === "nameOnly"
      ? foundItem.unit
      : selectedItem.unit != null && selectedItem.unit !== ""
        ? selectedItem.unit
        : foundItem.unit;
  const newItem = addItemToOptions(popoverData, foundItem, renamedText, unit);
  attachMasterChangedRowFlags(newItem);
  popoverData.master.selectedItem = newItem;
}

function hasIndMedicineDiffFromMaster(foundItem, selectedItem, extraParams) {
  if (!foundItem) return false;
  const compareProcedure = extraParams?.compareProcedure === true;
  const compareTiming = extraParams?.compareTiming === true;
  const compareReceiptUnit = extraParams?.compareReceiptUnit === true;
  const enabled = compareProcedure || compareTiming || compareReceiptUnit;
  if (!enabled) return false;
  const masterProcedureCd = foundItem?.procedureCd ?? foundItem?.procedure_cd ?? null;
  const masterTimingCd =
    foundItem?.medicateTimingCd ??
    foundItem?.medicate_timing_cd ??
    foundItem?.timingCd ??
    foundItem?.timing_cd ??
    null;
  const masterUnit = foundItem?.unitSecond ?? null;
  const currentProcedureCd =
    extraParams?.procedureCd ??
    extraParams?.currentProcedureCd ??
    selectedItem?.procedureCd ??
    selectedItem?.procedure_cd ??
    null;
  const currentTimingCd =
    extraParams?.timingCd ??
    extraParams?.currentTimingCd ??
    selectedItem?.medicateTimingCd ??
    selectedItem?.medicate_timing_cd ??
    selectedItem?.timingCd ??
    selectedItem?.timing_cd ??
    null;
  const currentUnit =
    compareReceiptUnit && extraParams?.receiptUnit != null && extraParams?.receiptUnit !== ""
      ? extraParams.receiptUnit
      : (selectedItem?.unit ?? null);

  const hasMaster =
    (compareProcedure && masterProcedureCd != null) ||
    (compareTiming && masterTimingCd != null) ||
    (compareReceiptUnit && (masterUnit != null && masterUnit !== ""));
  const hasCurrent =
    (compareProcedure && currentProcedureCd != null) ||
    (compareTiming && currentTimingCd != null) ||
    (compareReceiptUnit && (currentUnit != null && currentUnit !== ""));
  if (!hasMaster) return false;
  if (!hasCurrent) return false;

  const procDiff = compareProcedure
    ? String(masterProcedureCd ?? "") !== String(currentProcedureCd ?? "")
    : false;
  const timingDiff = compareTiming
    ? String(masterTimingCd ?? "") !== String(currentTimingCd ?? "")
    : false;
  const unitDiff =
    compareReceiptUnit &&
    masterUnit != null &&
    masterUnit !== "" &&
    currentUnit != null &&
    currentUnit !== "" &&
    String(masterUnit) !== String(currentUnit);
  return procDiff || timingDiff || unitDiff;
}

function pushItemToPopover(popoverData, item, changeOptionMode, context) {
  let { value, text, unit } = item;
  if (!value || !text || !popoverData.master.options) return;
  const textFoundItem = popoverData.master.options.find(
    option =>
      String(option.value) === String(value) &&
      normalizeTextForCompare(option.text) === normalizeTextForCompare(text) &&
      (changeOptionMode !== "nameAndUnit" || String(option.unit) === String(unit))
  );
  if (textFoundItem) {
    popoverData.master.selectedItem = textFoundItem;
    return;
  }
  const foundItem = popoverData.master.options.find(
    option => String(option.value) === String(value)
  );
  if (!foundItem) return;
  
  const isValid =
    (foundItem.isDisp === undefined || foundItem.isDisp === "1") &&
    (foundItem.isDel === undefined || foundItem.isDel === "0");

  if (isValid) {
    const prefix = getChangePrefix(
      {
        originalText: foundItem.text,
        originalUnit: changeOptionMode === "nameOnly" ? null : foundItem.unit,
        currentText: text,
        currentUnit: changeOptionMode === "nameOnly" ? null : unit
      },
      context,
      foundItem
    );
    if (prefix == null || prefix === "") {
      popoverData.master.selectedItem = foundItem;
      return;
    }
    const renamedText = prefix + stripLeadingMasterChangeMarkersOnly(text);
    const selectedItem = addItemToOptions(popoverData, foundItem, renamedText, unit);
    selectedItem.__isMasterChangedRow = true;
    if (context?.extraParams || context?.selectedItem) {
      const extraParams = context?.extraParams;
      selectedItem.procedureCd =
        extraParams?.procedureCd ??
        extraParams?.currentProcedureCd ??
        context?.selectedItem?.procedureCd ??
        context?.selectedItem?.procedure_cd ??
        selectedItem.procedureCd;
      selectedItem.medicateTimingCd =
        extraParams?.timingCd ??
        extraParams?.currentTimingCd ??
        context?.selectedItem?.medicateTimingCd ??
        context?.selectedItem?.medicate_timing_cd ??
        context?.selectedItem?.timingCd ??
        context?.selectedItem?.timing_cd ??
        selectedItem.medicateTimingCd;
      if (extraParams?.receiptUnit != null && extraParams?.receiptUnit !== "") {
        selectedItem.unitSecond = String(extraParams.receiptUnit);
      } else if (context?.selectedItem?.unitSecond != null && context?.selectedItem?.unitSecond !== "") {
        selectedItem.unitSecond = String(context.selectedItem.unitSecond);
      }
    }
    popoverData.master.selectedItem = selectedItem;
  } else {
    popoverData.master.selectedItem = foundItem;
  }
}

/**
 * 新しい項目をオプションに追加する
 * @param {Object} popoverData ポップオーバーデータ
 * @param {Object} baseItem 基本項目
 * @param {string} renamedText 接頭辞付与後の表示テキスト
 * @returns {Object} 追加後の項目
 */
function addItemToOptions(popoverData, baseItem, renamedText, unit) {
  const newItem = { ...baseItem, text: renamedText, unit: unit };
  popoverData.master.options.push(newItem);
  return newItem;
}

function getChangePrefix(
  {
    originalText,
    originalUnit,
    currentText,
    currentUnit
  },
  context,
  foundItem
) {
  const nameDiff = originalText && currentText && originalText !== currentText;
  const unitDiff =
    originalUnit != null &&
    originalUnit !== "" &&
    currentUnit != null &&
    currentUnit !== "" &&
    String(originalUnit) !== String(currentUnit);
  const procTimingDiff = hasIndMedicineDiffFromMaster(
    foundItem,
    context?.selectedItem,
    context?.extraParams
  );
  if ((nameDiff || unitDiff || procTimingDiff) && isActualRstDialysisState(context)) {
    return MASTER_CHANGED_PREFIX;
  }
  return "";
}
