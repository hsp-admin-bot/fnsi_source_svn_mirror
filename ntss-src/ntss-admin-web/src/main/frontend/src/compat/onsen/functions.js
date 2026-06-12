/**
 * vue-onsenui 3 / App.vue の v-ons-alert-dialog（Vuex共通ダイアログ）
 */
import store from "@/stores";

/** 旧 ons.notification.confirm の結果に合わせた定数（互換用） */
export const ConfirmAnswer = Object.freeze({
  Cancel: 0,
  Ok: 1
});

function getRawLoadingDisplayCount() {
  return store?.state?.["loading-screen"]?.displayCount || 0;
}

async function runWithLoadingSuspended(task) {
  const shouldSuspend = getRawLoadingDisplayCount() > 0;
  if (shouldSuspend) {
    await store.dispatch("loading-screen/suspendLoadingScreen");
  }
  try {
    return await task();
  } finally {
    if (shouldSuspend) {
      await store.dispatch("loading-screen/resumeLoadingScreen");
    }
  }
}

function normalizeNotificationArgs(messageOrOptions, maybeOptions = {}) {
  if (messageOrOptions && typeof messageOrOptions === "object" && !Array.isArray(messageOrOptions)) {
    return {
      ...messageOrOptions,
      title: messageOrOptions.title != null ? String(messageOrOptions.title) : "",
      message: messageOrOptions.message != null ? String(messageOrOptions.message) : "",
      messageHTML: messageOrOptions.messageHTML != null ? String(messageOrOptions.messageHTML) : ""
    };
  }
  return {
    ...(maybeOptions || {}),
    title: maybeOptions?.title != null ? String(maybeOptions.title) : "",
    message: messageOrOptions != null ? String(messageOrOptions) : "",
    messageHTML: maybeOptions?.messageHTML != null ? String(maybeOptions.messageHTML) : ""
  };
}

/**
 * アラート（単一 OK）
 * @param {{ title?: string | null, message?: string | null, messageHTML?: string | null }} opts
 * @returns {Promise<void>}
 */
export function showAlertDialog(opts) {
  const { title, message, messageHTML, buttonLabel, buttonLabels, modifier, class: dialogClass } = opts;
  const msg = message != null ? String(message) : "";
  const msgHtml = messageHTML != null ? String(messageHTML) : "";
  if (!msg && !msgHtml && (title == null || String(title).trim() === "")) {
    return Promise.resolve();
  }
  return runWithLoadingSuspended(() => store.dispatch("app/showOnsAlert", {
    title: title != null ? String(title) : "",
    message: msg,
    messageHTML: msgHtml,
    buttonLabels: buttonLabels ?? buttonLabel,
    modifier,
    dialogClass
  }));
}

/**
 * 確認ダイアログ。選択されたボタンの index を返す
 * @param {{ title?: string | null, message?: string | null, messageHTML?: string | null }} opts
 * @returns {Promise<number>}
 */
export function showConfirmDialog(opts) {
  const { title, message, messageHTML, buttonLabel, buttonLabels, cancelable, modifier, class: dialogClass } = opts;
  const msg = message != null ? String(message) : "";
  const msgHtml = messageHTML != null ? String(messageHTML) : "";
  return runWithLoadingSuspended(() => store.dispatch("app/showOnsConfirm", {
    title: title != null ? String(title) : "",
    message: msg,
    messageHTML: msgHtml,
    buttonLabels: buttonLabels ?? buttonLabel,
    cancelable,
    modifier,
    dialogClass
  }));
}

export async function onsNotificationAlert(messageOrOptions, maybeOptions = {}) {
  const options = normalizeNotificationArgs(messageOrOptions, maybeOptions);
  await showAlertDialog(options);
  // 旧 ons.notification.alert と同様、OK 押下時はボタン index 0 を callback に渡す
  const answer = 0;
  if (typeof options.callback === "function") {
    options.callback(answer);
  }
  return answer;
}

export async function onsNotificationConfirm(messageOrOptions, maybeOptions = {}) {
  const options = normalizeNotificationArgs(messageOrOptions, maybeOptions);
  const selectedIndex = await showConfirmDialog(options);
  const answer = Number.isInteger(selectedIndex) ? selectedIndex : ConfirmAnswer.Cancel;
  if (typeof options.callback === "function") {
    options.callback(answer);
  }
  return answer;
}

export function createOnsCompat(originalOns = {}) {
  const originalNotification = originalOns?.notification || {};
  return {
    ...originalOns,
    notification: {
      ...originalNotification,
      alert(messageOrOptions, maybeOptions = {}) {
        return onsNotificationAlert(messageOrOptions, maybeOptions);
      },
      confirm(messageOrOptions, maybeOptions = {}) {
        return onsNotificationConfirm(messageOrOptions, maybeOptions);
      }
    }
  };
}
