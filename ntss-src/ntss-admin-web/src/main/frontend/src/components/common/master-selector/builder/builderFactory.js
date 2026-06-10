import { MASTER } from "../MasterType";

/**
 * MasterType から Master定義を取得
 */
function getMaster(masterType) {
  const master = MASTER[masterType];
  if (!master) {
    console.warn(`[builderFactory] Master not found: ${masterType}`);
    return null;
  }
  if (!master.builder) {
    console.warn(`[builderFactory] Builder not defined for: ${masterType}`);
    return null;
  }
  return master;
}

/**
 * 初期選択項目構築
 */
export function buildInitSelectedItem(masterType, context) {
  const master = getMaster(masterType);
  if (!master) return null;
  const builder = master.builder;
  if (typeof builder.buildInitSelectedItem !== "function") return null;
  return builder.buildInitSelectedItem(context);
}

/**
 * Popover構築処理
 */
export function buildMasterPopover(masterType, context) {
  const master = getMaster(masterType);
  if (!master) return null;
  const builder = master.builder;
  if (typeof builder.buildMasterPopover !== "function") {
    console.warn(
      `[builderFactory] buildMasterPopover not implemented: ${masterType}`
    );
    return null;
  }
  return builder.buildMasterPopover(context);
}
