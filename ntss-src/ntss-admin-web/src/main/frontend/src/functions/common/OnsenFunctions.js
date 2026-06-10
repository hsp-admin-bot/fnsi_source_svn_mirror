import ons from "onsenui";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from "@/functions/common/MessageFormat";

/** ons.notification.confirmの結果の値 */
export const ConfirmAnswer = Object.freeze({
  Cancel: 0,
  Ok: 1,
});

/**
 * ons.notification.confirmでOKを選択した場合はtrueを返す形にするラッパー
 * @param {{ title: string, message: string }} messages DIALOG_MESSAGESの要素
 * @param {any[]} args messages.message とともに messageFormat に渡す引数
 */
export const confirmIsOk = async (messages, ...args) => {
  const answer = await ons.notification.confirm({
    title: messages.title,
    message: messageFormat(messages.message, ...args),
  });
  return (answer === ConfirmAnswer.Ok);
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
export const alertByMessages = (messages, ...args) => ons.notification.alert({
  title: messages.title,
  message: messageFormat(messages.message, ...args),
});
/**
 * DIALOG_MESSAGESのコードを指定してons.notification.alertを使うラッパー
 * @param {string | number} key DIALOG_MESSAGESのキー
 * @param {any[]} args DIALOG_MESSAGES[key].message とともに messageFormat に渡す引数
 */
export const alertByKey = (key, ...args) => (
  alertByMessages(DIALOG_MESSAGES[key], ...args)
);
