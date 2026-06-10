import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";

/**
 * ポップオーバーに項目をプッシュする
 * @param {Object} popoverData ポップオーバーデータ
 * @param {Object} params 項目データ
 */
export function appendChangedOptionsIfNeeded(popoverData, context) {
  const { initItem, selectedItem, hasChangedOption, changeOptionMode } = context

  if (!hasChangedOption || !selectedItem) {
    return;
  }
  const isValid =
    (selectedItem.isDisp === undefined || selectedItem.isDisp === "1") &&
    (selectedItem.isDel === undefined || selectedItem.isDel === "0");

  if (isValid) {
    // 初期値の名称または単位が変更された場合、末尾に追記して表示する。
    pushItemToPopover(popoverData, initItem, changeOptionMode);
    if (initItem && initItem.text !== selectedItem.text) {
      // 選択値の名称または単位が変更された場合、末尾に追記して表示する。
      pushItemToPopover(popoverData, selectedItem, changeOptionMode);
    }
  }
}

/**
 * ポップオーバーに項目をプッシュする
 * @param {Object} popoverData ポップオーバーデータ
 * @param {Object} params 項目データ
 */
export function removePrefixFromOptions(item) {
  if (!item.text) return item;
  return {
    ...item,
    text: removePrefix(item.text)
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

  if (!hasUnregisteredOption) return ret;

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

/**
 * ポップオーバーに項目をプッシュする
 * @param {Object} popoverData ポップオーバーデータ
 * @param {Object} item 項目データ
 */
function pushItemToPopover(popoverData, item, changeOptionMode) {
  let { value, text, unit } = item;
  if (!value || !text || !popoverData.master.options) return;
  const textFoundItem = popoverData.master.options.find(
    option =>
      String(option.value) === String(value) &&
      String(option.text) === String(text) &&
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
    const renamedText = getChangePrefix({
      originalText: foundItem.text,
      originalUnit: changeOptionMode === "nameOnly" ? null : foundItem.unit,
      currentText: text,
      currentUnit: changeOptionMode === "nameOnly" ? null : unit
    }) + text;
    const selectedItem = addItemToOptions(popoverData, foundItem, renamedText, unit);
    popoverData.master.selectedItem = selectedItem;
  } else {
    popoverData.master.selectedItem = foundItem;
  }
}

/**
 * 新しい項目をオプションに追加する
 * @param {Object} popoverData ポップオーバーデータ
 * @param {Object} baseItem 基本項目
 * @param {string} renamedText 名前変更後のテキスト
 * @returns {Object} 追加後の項目
 */
function addItemToOptions(popoverData, baseItem, renamedText, unit) {
  const newItem = { ...baseItem, text: renamedText, unit: unit };
  popoverData.master.options.push(newItem);
  return newItem;
}

/**
 * 名称変更・単位変更用の前缀文字列を生成する
 *
 * @param {Object} params
 * @returns {string} 前缀文字列
 */
function getChangePrefix({
  originalText,
  originalUnit,
  currentText,
  currentUnit
}) {
  let prefix = "";

  if (originalText && currentText && originalText !== currentText) {
    prefix += "【名前変更】";
  }

  if (originalUnit && currentUnit && originalUnit !== currentUnit) {
    prefix += "【単位変更】";
  }

  return prefix;
}

/**
 * 表示文字列から前缀を除去し、元の名称を復元する
 *
 * @param {string} text 表示用文字列
 * @returns {string}
 */
function removePrefix(text) {
  if (!text) return text;

  let result = text;

  // 名前変更・単位変更 前缀を除去
  if (/【(名前変更|単位変更)】/.test(result)) {
    result = result.replace(/【(名前変更|単位変更)】/g, "");
  }

  return result;
}
