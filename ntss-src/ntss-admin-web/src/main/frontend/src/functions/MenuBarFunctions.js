/**
 * メニューバー表示機能設定 共通関数
 */
import { getMstUrlLinkRegister, getMstMenuGroup } from "@/functions/mst/MstGetters";
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";

/**
 * 外部リンクメニューマスタ、メニューグループマスタ 取得
 */
export const fetchMenuData = async (facilityCd, authorizedFunctions = undefined) => {
  const [mstUrlLink, mstMenuGroup] = await Promise.all([
    getMstUrlLinkRegister(facilityCd),
    getMstMenuGroup(facilityCd)
  ]);

  const menuList = [];
  
  // 外部リンクメニューをリストに追加
  mstUrlLink.forEach(({ urlCd, functionName }) => {
    const urlCode = `url-${urlCd}`;
    if (authorizedFunctions === undefined || authorizedFunctions.includes(urlCode)) {
      menuList.push({ code: urlCode, label: functionName });
    }
  });
  // メニューグループをリストに追加
  mstMenuGroup.forEach(({ menuGroupCd, menuGroupName }) => {
    const groupCode = `group-${menuGroupCd}`;
    if (authorizedFunctions === undefined || authorizedFunctions.includes(groupCode)) {
      menuList.push({ code: groupCode, label: menuGroupName });
    }
  });

  return menuList;
}

/**
 * 入力チェック
 */
const validateData = (inputModel) => {
  // 通常メニューONが0件の状態での保存できないように確定時制限をする
  const existsNormalMenu = inputModel.useAuthFuncs.some(item => 
    !item.startsWith("url") && !item.startsWith("group")
  );
  return { existsNormalMenuValid: existsNormalMenu };
}

/**
 * 確定or保存ボタン押下時 バリデーション
 */
export const validateOnRegistration = (inputModel, ons) => {
  const validationResult = validateData(inputModel);
  if (Object.values(validationResult).every(v => v === true)) {
    // 全てチェックOK
    return true;
  }
  const message = `
    ${
      !validationResult.existsNormalMenuValid
        ? messageFormat(DIALOG_MESSAGES["00200163"].message)
        : ""
    }
  `;
  // ダイアログ表示
  ons.notification.alert({
    title: DIALOG_MESSAGES["00200163"].title,
    message: message
  });
  return false;
}
