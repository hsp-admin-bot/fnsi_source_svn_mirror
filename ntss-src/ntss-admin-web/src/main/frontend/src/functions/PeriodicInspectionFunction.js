import { DATE_CHOICES } from "@/constants/defaultSettingConstants";
import { calcTargetDate } from "@/functions/modals/default-setting/defaultSettingUtils";

// 検索条件のシステムデフォルト値を生成
export const makeDefaultCondition = forSetting => {
  const selectDateValue = forSetting
    ? (value => value)
    : (value => calcTargetDate(value));
  return {
    startDate: selectDateValue(DATE_CHOICES.BEFORE_ONE_YEAR.value),
    endDate: selectDateValue(DATE_CHOICES.AFTER_ONE_YEAR.value),
    machineTypeList: [],
    bedGroupCd: null,
  };
};

