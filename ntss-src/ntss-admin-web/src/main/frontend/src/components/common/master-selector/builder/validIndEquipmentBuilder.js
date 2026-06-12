import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import {
  buildValidIndEquipmentListData,
  CATEGORY_KEY,
} from "@/components/indication/validIndEquipmentData";
import { normalizeTextForCompare } from "@/components/common/master-selector/utils/MasterSelectorUtil";

function resolvePopoverSelectedItem(options, selectedItem) {
  if (!options?.length || selectedItem == null) return null;
  const sv = selectedItem.value;
  const same = options.filter(o => String(o.value) === String(sv));
  if (same.length === 0) return null;
  if (same.length === 1) return same[0];
  const st = selectedItem.text;
  if (st != null && st !== "") {
    const exact = same.find(o => String(o.text) === String(st));
    if (exact) return exact;
    const nt = normalizeTextForCompare(st);
    const norm = same.find(o => normalizeTextForCompare(o.text) === nt);
    if (norm) return norm;
  }
  return same[0];
}

/**
 * 指示有効な医療材料：MasterPopover 形式（validIndEquipmentsList データ源）
 */
export async function buildValidIndEquipmentPopover(context) {
  try {
    const extra = context?.extraParams || {};
    const structData = extra.structData;
    if (!structData) {
      console.warn("[validIndEquipmentBuilder] structData missing in extraParams");
      return null;
    }

    const listData = await buildValidIndEquipmentListData({
      facilityCd: context.facilityCd,
      patientId: context.patientId,
      structData,
      fieldsData: extra.fieldsData,
      showAllSelectTag: extra.showAllSelectTag !== false,
      selectedEquipment: extra.selectedEquipment,
      popoverContentSelected: context.selectedItem || extra.popoverContentSelected,
      mstEquipmentClass: extra.mstEquipmentClass || [],
      mstEquipment: extra.mstEquipment || [],
      mstDialyzer: extra.mstDialyzer || [],
      mstEquipmentDialyzerIncludedDeleted:
        extra.mstEquipmentDialyzerIncludedDeleted || [],
      currentOrdMainData: extra.currentOrdMainData || {},
      validIndEquipments: extra.validIndEquipments,
      refreshValidList: extra.refreshValidList !== false,
    });

    if (!listData) return null;

    const selectedItem =
      resolvePopoverSelectedItem(listData.options, context.selectedItem) ||
      listData.selectedItem;

    return {
      headerTitle: "医療材料",
      categories: [
        {
          key: CATEGORY_KEY,
          label: CATEGORY_KEY,
          value: 0,
          options: listData.filterArr,
        },
      ],
      master: {
        key: "master",
        label: "医療材料名",
        options: listData.options,
        selectedItem,
      },
      _meta: {
        validIndEquipments: listData.validIndEquipments,
        masterLabelForCd: listData.masterLabelForCd,
        rstNameForCd: listData.rstNameForCd,
      },
    };
  } catch (e) {
    getErrorMessage("validIndEquipmentBuilder.js", "buildValidIndEquipmentPopover", e);
    throw e;
  }
}
