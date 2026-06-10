import { isEmpty } from "@/utils/util.js";
import { mapActions, mapState } from "vuex";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
import { messageFormat } from "@/functions/common/MessageFormat";
import { MSG_SETTING_REFLECTION } from "@/constants/masterMaintenanceConstants";
import { ApiHelper } from "@/apis/AxiosHelper";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import cloneDeep from 'lodash/cloneDeep';
export default {
  computed: {
    ...mapState("mst-job", ["isEditAuthority", "isMenuSettings", "isDefaultDispSettings", "isDefaultNotificationSettings"]),
    // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
    ...mapState("master-maintenance", {
      facilityCd: "facilitySwitch",
    }),
    // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end
  },
  methods: {
  ...mapActions("account-edit", ["getUserAccountInfo"]),
   async handleValidate (callback) {
      const fieldMapping = this.requiredFields.map(field => this.fieldsMap.get(field));
      const data = this.gridData.data();
      const validateRequired = [];
      const fieldSet = new Set();
      data.forEach((item) => {
        if (item.isDisp === "1") {
          fieldMapping.forEach((field, fieldIndex) => {
            const hasReqFieldIsEmpty = isEmpty(item[this.requiredFields[fieldIndex]]);
            if (hasReqFieldIsEmpty && !fieldSet.has(field) && item.isDisp === '1' && !item.isNew()) {
              field && validateRequired.push(field);
              fieldSet.add(field);
            }
          })
        }
      });
      if (validateRequired.length > 0) {
        const message = `${messageFormat(DIALOG_MESSAGES[12000270].message)} ${validateRequired.join("</br>&nbsp&nbsp・")}</br>`;
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES["00300006"].title,
          message: `<div style="text-align:left;">${message}</div>`,
        });
        return;
      }
      if (callback) {
        let classiFicationFlg = false;
        const data = cloneDeep(this.gridData.data());
        const dataForIsDisp = data.toJSON().filter((item) => {
          return item.isDisp === "1";
        });
        let examItemFalg = true;
        let hasEditedRow = false;
        for(let i = data.length - 1; i >= 0; i--) {
          const item = data.at(i);
          if (item.isNew() && item.sortRank === 0) { // 未編集の空白行の削除
            this.gridData.remove(item);
          }
          if (item.dirty && !item.isNew() && !item.isImport) {
            hasEditedRow = true;
            if (['mst_medicine_class', 'mst_equipment_class', 'mst_equipment', 'mst_medicine', 'mst_medicine_mix'].includes(this.masterPhysicalName) &&
            (item.dirtyFields.hasOwnProperty("classCd") || item.dirtyFields.hasOwnProperty("classType"))) {
              classiFicationFlg = true;
            }
          }
          if (this.masterPhysicalName === "mst_exam_item" && item.isDisp === "1") { // 検査項目マスタ
            for (let item2 of dataForIsDisp) {
              if (item.defaultCalcExamItemCd != "0" &&
                  item.code != item2.code &&
                  item.defaultCalcExamItemCd == item2.defaultCalcExamItemCd &&
                  item2.dialysisProgressFlag !== "0" && item2.dialysisProgressFlag !== "") {
                if ((item.dialysisProgressFlag == "1" && item2.dialysisProgressFlag != "2") ||
                    (item.dialysisProgressFlag == "2" && item2.dialysisProgressFlag != "1") ||
                    (item.dialysisProgressFlag == "3" && item2.dialysisProgressFlag != "0")) {
                  examItemFalg = false;
                  break;
                }
              }
            }
          }
        }
        if (this.masterPhysicalName === "mst_job" && (this.isEditAuthority || this.isMenuSettings || this.isDefaultDispSettings || this.isDefaultNotificationSettings) && hasEditedRow) { // used for 職種マスタ #9386
          await this.$ons.notification.confirm({
            title: DIALOG_MESSAGES[13000095].title,
            message: messageFormat(DIALOG_MESSAGES[13000095].message),
            buttonLabels: ["保存", "展開保存"],
            callback: async answer => {
              if (answer === 1) {
                const requestArr = data.map((item) => {
                  return {
                    // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
                    facilityCd: this.facilityCd,
                    // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end
                    jobCd: item.code,
                    defaultAuthorizedAuthorities: item.defaultAuthorizedAuthorities,
                    defaultMenuSettings: item.defaultMenuSettings,
                    defaultDispSettings: item.defaultDispSettings,
                    defaultNotificationSettings: item.defaultNotificationSettings
                  };
                });
                const initData = this.originalDataSource.toJSON().map((item) => {
                  return {
                    jobCd: item.code,
                    defaultAuthorizedAuthorities: item.defaultAuthorizedAuthorities?.split(",") || [],
                    defaultMenuSettings: JSON.parse(item.defaultMenuSettings),
                  };
                });
                let requestObject = {};
                requestArr.forEach((item) => {
                  requestObject[item.jobCd] = {
                    defaultAuthorizedAuthorities: item.defaultAuthorizedAuthorities?.split(",") || [],
                    defaultMenuFunctions: JSON.parse(item.defaultMenuSettings)?.default_menu_functions
                  }
                })
                let notHasDelAuthFlg = initData.every((item) => {
                  const defaultAuthorizedAuthorities = item.defaultAuthorizedAuthorities;
                  const defaultMenuFunctions = item.defaultMenuSettings.default_menu_functions;
                  if (requestObject.hasOwnProperty(item.jobCd)) {
                    let requestItem = requestObject[item.jobCd];
                    const includeAllAuth = defaultAuthorizedAuthorities.every(auth => requestItem.defaultAuthorizedAuthorities?.includes(auth));
                    const includeAllFunc = defaultMenuFunctions.every(func => requestItem.defaultMenuFunctions?.includes(func));
                    return includeAllAuth && includeAllFunc;
                  }
                  return true;
                });
                // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
                // if (this.PERMISSION_CHANGE_SIGNOUT && !notHasDelAuthFlg) {
                //   await this.$ons.notification.confirm({
                //     title: DIALOG_MESSAGES[13000157].title,
                //     message: MSG_SETTING_REFLECTION,
                //     callback: async (answer) => {
                //       if (answer === 1) {
                //         await ApiHelper.put("/mstInfo/updMstJobAuthorities", requestArr)
                //         .catch(error => {
                //           getErrorMessage('MstJobMainComponent.vue', 'saveRecord', error);
                //           this.$ons.notification.alert({
                //             title: DIALOG_MESSAGES["00300005"].title,
                //             message: error.response.data.errorMessage
                //           });
                //         });
                //         callback();
                //       } else {
                //         this.setIsEditAuthority(this.isEditAuthorityBak);
                //         this.setIsMenuSettings(this.isMenuSettingsBak);
                //         return;
                //       }
                //     }
                //   });
                // } else {
                //   callback();
                // }
                let changeFlg = true;
                if (this.PERMISSION_CHANGE_SIGNOUT && !notHasDelAuthFlg) {
                  await this.$ons.notification.confirm({
                    title: DIALOG_MESSAGES[13000157].title,
                    message: MSG_SETTING_REFLECTION,
                    callback: async (answer) => {
                      if (answer !== 1) {
                        this.setIsEditAuthority(false);
                        this.setIsMenuSettings(false);
                        this.setIsDefaultDispSettings(false);
                        this.setIsDefaultNotificationSettings(false);
                        changeFlg = false;
                        this.$refs.grid.kendoWidget().cancelChanges();
                        this.isNotChanged = true;
                      }
                    }
                  });
                }
                if (changeFlg) {
                  await ApiHelper.put("/mstInfo/updMstJobAuthorities", requestArr)
                    .then(() => {
                      this.getUserAccountInfo(); // 更新されたアカウント情報取得
                    })
                    .catch(error => {
                      getErrorMessage('MstJobMainComponent.vue', 'saveRecord', error);
                      this.$ons.notification.alert({
                        title: DIALOG_MESSAGES["00300005"].title,
                        message: error.response.data.errorMessage
                      });
                    });
                  callback();
                }
                // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end
              } else {
                callback();
              }
            }
          });
          return;
        }
        if(!examItemFalg) { // 検査項目マスタ
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES[12000012].title,
            message: DIALOG_MESSAGES[12000012].message + "<br>"
          });
          return;
        }
        // 画面上で医療材料の分類が変更された場合
        if (classiFicationFlg) {
          await this.$ons.notification.alert({
            title: DIALOG_MESSAGES[12000051].title,
            message: DIALOG_MESSAGES[12000051].message
          });
        }
        callback()
      }
    }
  }
}
