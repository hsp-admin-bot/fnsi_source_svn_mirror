import {
  getOnsElement,
  getOnsElementFromEvent,
  getOnsScopedElementsByClassName,
  queryOnsPart,
  queryOnsParts,
  resolveOnsElement
} from "@/compat/onsen/host";

export function isOnsAlertDialogElement(candidate) {
  const element = resolveOnsElement(candidate);
  return !!element && (
    element.matches?.("ons-alert-dialog") === true
    || String(element.localName || element.nodeName || "").toLowerCase() === "ons-alert-dialog"
  );
}

export function getOnsAlertDialogElement(target, fallbackRoot = null) {
  return getOnsElement(target, "ons-alert-dialog", ".alert-dialog", fallbackRoot);
}

export function getOnsAlertDialogFromEvent(event, fallbackRoot = null) {
  return getOnsElementFromEvent(event, "ons-alert-dialog", ".alert-dialog", fallbackRoot, "alertDialog");
}

export function getOnsAlertDialogFooterElement(alertDialog) {
  const dialog = getOnsAlertDialogElement(alertDialog);
  return queryOnsPart(dialog, [".alert-dialog-footer"]);
}

export function getOnsAlertDialogFooterItems(alertDialog) {
  const footer = getOnsAlertDialogFooterElement(alertDialog);
  return Array.from(footer?.children || []);
}

// add メッセージダイアログのデフォルトボタン（OK 等）フォーカス対応 start
// MessageDialog.vue の type 定数（1〜9）に対応する、デフォルトで選択するボタンのインデックス
const MESSAGE_DIALOG_TYPE_OK = "1";
const MESSAGE_DIALOG_TYPE_OK_CANCEL = "2";
const MESSAGE_DIALOG_TYPE_YES_NO_CANCEL = "3";
const MESSAGE_DIALOG_TYPE_YES_NO = "4";
const MESSAGE_DIALOG_TYPE_SAVE_EXPAND = "5";
const MESSAGE_DIALOG_TYPE_YES_NO_CANCEL_JPN = "6";
const MESSAGE_DIALOG_TYPE_DELSAVE_SAVE_CANCEL = "7";
const MESSAGE_DIALOG_TYPE_123 = "8";
const MESSAGE_DIALOG_TYPE_WORD = "9";

const PRIMARY_BUTTON_INDEX_BY_TYPE = {
  [MESSAGE_DIALOG_TYPE_OK]: 0,
  [MESSAGE_DIALOG_TYPE_OK_CANCEL]: 1,
  [MESSAGE_DIALOG_TYPE_YES_NO_CANCEL]: 1,
  [MESSAGE_DIALOG_TYPE_YES_NO]: 0,
  [MESSAGE_DIALOG_TYPE_SAVE_EXPAND]: 0,
  [MESSAGE_DIALOG_TYPE_YES_NO_CANCEL_JPN]: 2,
  [MESSAGE_DIALOG_TYPE_DELSAVE_SAVE_CANCEL]: 0,
  [MESSAGE_DIALOG_TYPE_123]: 0,
  [MESSAGE_DIALOG_TYPE_WORD]: 0
};

/** MessageDialog の type から、デフォルトフォーカス対象ボタンのインデックスを取得する */
function getDefaultAlertDialogButtonFocusIndex(type, buttonCount) {
  if (buttonCount <= 1) {
    return 0;
  }
  const primaryIndex = PRIMARY_BUTTON_INDEX_BY_TYPE[type];
  if (Number.isInteger(primaryIndex) && primaryIndex < buttonCount) {
    return primaryIndex;
  }
  if (buttonCount === 2) {
    return 1;
  }
  return buttonCount - 1;
}

/** ntss.css の .focus-button（青枠）を付与し、デフォルト選択状態を表示する */
function applyAlertDialogButtonFocusStyle(footerItem, index, buttonCount) {
  const footer = footerItem?.parentElement;
  if (!footer) {
    return;
  }
  footer.querySelectorAll(".focus-button").forEach((element) => {
    element.classList.remove(
      "focus-button",
      "bottom-radius",
      "bottom-left-radius",
      "bottom-right-radius"
    );
  });
  footerItem.classList.add("focus-button");
  if (buttonCount === 1) {
    footerItem.classList.add("bottom-radius");
  } else if (buttonCount === 2) {
    footerItem.classList.add(index === 0 ? "bottom-left-radius" : "bottom-right-radius");
  } else if (buttonCount === 3) {
    if (index === 0) {
      footerItem.classList.add("bottom-left-radius");
    } else if (index === 2) {
      footerItem.classList.add("bottom-right-radius");
    }
  }
}

/** フォーカス用 <a> にクリック・Enter/Space・フォーカスイベントを紐付ける */
function bindAlertDialogFocusAnchor(anchor, footerItem, index, buttonCount) {
  anchor.addEventListener("click", (event) => {
    event.preventDefault();
    footerItem.click();
  });
  anchor.addEventListener("keydown", (event) => {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      footerItem.click();
    }
  });
  anchor.addEventListener("focus", () => {
    applyAlertDialogButtonFocusStyle(footerItem, index, buttonCount);
  });
  anchor.addEventListener("focusout", () => {
    footerItem.classList.remove(
      "focus-button",
      "bottom-radius",
      "bottom-left-radius",
      "bottom-right-radius"
    );
  });
}

/**
 * ボタン内にフォーカス用 <a> を用意する。
 * App.vue observeAlertDialog が差し込んだ <a> があればそれを再利用する。
 */
function ensureAlertDialogFocusAnchor(footerItem, index, buttonCount) {
  const ownAnchor = footerItem.querySelector("a[data-ntss-focus-anchor]");
  if (ownAnchor) {
    return ownAnchor;
  }
  const existingAnchor = footerItem.querySelector("a");
  if (existingAnchor) {
    return existingAnchor;
  }
  const anchor = footerItem.ownerDocument.createElement("a");
  anchor.href = "#";
  anchor.setAttribute("data-ntss-focus-anchor", "true");
  bindAlertDialogFocusAnchor(anchor, footerItem, index, buttonCount);
  footerItem.appendChild(anchor);
  return anchor;
}

/** フッター未描画時は requestAnimationFrame で再試行する（初回表示・postshow 直後対策） */
function scheduleAlertDialogFocusRetry(alertDialogEl, options) {
  if (options.retryCount >= 20) {
    return;
  }
  requestAnimationFrame(() => {
    focusAlertDialogDefaultButton(alertDialogEl, {
      ...options,
      retryCount: options.retryCount + 1
    });
  });
}

/** primaryButtonIndex 指定時はそちらを優先、未指定時は MessageDialog の type から決定する */
function resolveAlertDialogFocusIndex(type, buttonCount, primaryButtonIndex) {
  if (
    Number.isInteger(primaryButtonIndex)
    && primaryButtonIndex >= 0
    && primaryButtonIndex < buttonCount
  ) {
    return primaryButtonIndex;
  }
  return getDefaultAlertDialogButtonFocusIndex(type, buttonCount);
}

/**
 * @description アラートダイアログ表示後にデフォルトボタン（OK 等）へフォーカスを当てる
 * @param {Element} alertDialogEl ons-alert-dialog 要素、またはその子孫を含むルート
 * @param {{ type?: string, primaryButtonIndex?: number, retryCount?: number, stabilize?: boolean }} [options]
 *   - type: MessageDialog.vue の type（1〜9）
 *   - primaryButtonIndex: GlobalOnsAlertDialog 等で最後のボタン（OK）を直接指定する場合
 *   - stabilize: true のときは再試行・遅延再適用を行わない（内部用）
 */
export function focusAlertDialogDefaultButton(alertDialogEl, { type, primaryButtonIndex, retryCount = 0, stabilize = false } = {}) {
  const dialog = getOnsAlertDialogElement(alertDialogEl);
  if (!dialog) {
    if (!stabilize) {
      scheduleAlertDialogFocusRetry(alertDialogEl, { type, primaryButtonIndex, retryCount });
    }
    return;
  }
  const footer = getOnsAlertDialogFooterElement(dialog);
  if (!footer) {
    if (!stabilize) {
      scheduleAlertDialogFocusRetry(alertDialogEl, { type, primaryButtonIndex, retryCount });
    }
    return;
  }
  const footerItems = Array.from(footer.children);
  if (footerItems.length === 0) {
    if (!stabilize) {
      scheduleAlertDialogFocusRetry(alertDialogEl, { type, primaryButtonIndex, retryCount });
    }
    return;
  }
  const focusIndex = resolveAlertDialogFocusIndex(type, footerItems.length, primaryButtonIndex);
  const footerItem = footerItems[focusIndex];
  if (!footerItem) {
    return;
  }
  const anchor = ensureAlertDialogFocusAnchor(footerItem, focusIndex, footerItems.length);
  anchor.focus();
  applyAlertDialogButtonFocusStyle(footerItem, focusIndex, footerItems.length);

  // 初回表示時にフッター描画・他処理と競合して選択状態が消える場合があるため、50ms 後に再適用する
  if (!stabilize) {
    setTimeout(() => {
      focusAlertDialogDefaultButton(alertDialogEl, {
        type,
        primaryButtonIndex,
        stabilize: true
      });
    }, 50);
  }
}
// add メッセージダイアログのデフォルトボタン（OK 等）フォーカス対応 end

export function getOnsAlertDialogPanelElement(alertDialog) {
  const dialog = getOnsAlertDialogElement(alertDialog);
  if (!dialog) {
    return null;
  }

  return queryOnsPart(dialog, [".alert-dialog"])
    || Array.from(dialog.children || []).find((element) => element?.classList?.contains?.("alert-dialog"))
    || dialog.childNodes?.[1]
    || null;
}

export function getOnsAlertDialogContentElement(alertDialog) {
  const dialog = getOnsAlertDialogElement(alertDialog);
  return queryOnsPart(dialog, [".alert-dialog-content"]);
}

export function getOnsAlertDialogScopedElementsByClassName(alertDialogOrRoot, className, fallbackRoot = null, hostClass = null) {
  return getOnsScopedElementsByClassName(
    alertDialogOrRoot,
    "ons-alert-dialog",
    className,
    fallbackRoot,
    hostClass,
    ".alert-dialog"
  );
}

export function isOnsDialogElement(candidate) {
  const element = resolveOnsElement(candidate);
  return !!element && (
    element.matches?.("ons-dialog") === true
    || String(element.localName || element.nodeName || "").toLowerCase() === "ons-dialog"
  );
}

export function getOnsDialogElement(target, fallbackRoot = null) {
  return getOnsElement(target, "ons-dialog", ".dialog", fallbackRoot);
}

export function getOnsDialogFromEvent(event, fallbackRoot = null) {
  return getOnsElementFromEvent(event, "ons-dialog", ".dialog", fallbackRoot, "dialog");
}

export function getOnsDialogScopedElementsByClassName(dialogOrRef, className, fallbackRoot = null, hostClass = null) {
  return getOnsScopedElementsByClassName(
    dialogOrRef,
    "ons-dialog",
    className,
    fallbackRoot,
    hostClass,
    ".dialog"
  );
}

export function getOnsDialogPanelElement(dialogOrRef) {
  const dialog = getOnsDialogElement(dialogOrRef);
  return queryOnsPart(dialog, [".dialog"]);
}

export function getOnsDialogContentElements(dialogOrRef) {
  const dialog = getOnsDialogElement(dialogOrRef);
  return queryOnsParts(dialog, [".dialog-container", ".dialog-content", ".dialog .content"]);
}
