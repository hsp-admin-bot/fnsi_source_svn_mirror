import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from "@/functions/common/MessageFormat";
import {
  ConfirmAnswer,
  showAlertDialog,
  showConfirmDialog,
  onsNotificationAlert,
  onsNotificationConfirm,
  createOnsCompat
} from "@/compat/onsen/functions.js";

export {
  ConfirmAnswer,
  showAlertDialog,
  showConfirmDialog,
  onsNotificationAlert,
  onsNotificationConfirm,
  createOnsCompat
};

/**
 * ons.notification.confirmでOKを選択した場合はtrueを返す形にするラッパー
 * @param {{ title: string, message: string }} messages DIALOG_MESSAGESの要素
 * @param {any[]} args messages.message とともに messageFormat に渡す引数
 */
export const confirmIsOk = async (messages, ...args) => {
  const formatted = messageFormat(messages.message, ...args);
  return showConfirmDialog({
    title: messages.title != null ? String(messages.title) : "",
    message: formatted,
    buttonLabels: ["Cancel", "OK"]
  });
};

/**
 * ons.notification.confirmでOKを選択した場合はtrueを返す形にするラッパー
 * @param {string | number} key DIALOG_MESSAGESのキー
 * @param {any[]} args DIALOG_MESSAGES[key].message とともに messageFormat に渡す引数
 */
export const confirmIsOkByKey = async (key, ...args) => (
  await confirmIsOk(DIALOG_MESSAGES[key], ...args)
);

/**
 * ons.notification.alertでDIALOG_MESSAGESを使う場合の定型処理を持つラッパー
 * @param {{ title: string, message: string }} messages DIALOG_MESSAGESの要素
 * @param {any[]} args messages.message とともに messageFormat に渡す引数
 */
export const alertByMessages = (messages, ...args) => (
  showAlertDialog({
    title: messages.title,
    message: messageFormat(messages.message, ...args)
  })
);

/**
 * DIALOG_MESSAGESのコードを指定してons.notification.alertを使うラッパー
 * @param {string | number} key DIALOG_MESSAGESのキー
 * @param {any[]} args DIALOG_MESSAGES[key].message とともに messageFormat に渡す引数
 */
export const alertByKey = (key, ...args) => (
  alertByMessages(DIALOG_MESSAGES[key], ...args)
);

export * from "@/compat/onsen/dialog.js";
export * from "@/compat/onsen/popover.js";
export * from "@/compat/onsen/speed-dial.js";
