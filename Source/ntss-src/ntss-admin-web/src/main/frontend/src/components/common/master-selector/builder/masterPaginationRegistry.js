import { FACILITY_PAT_INFO } from "../MasterType";

/** MasterSelectorFacility.vue の FavoritePrefecturesValue / AllPrefecturesValue と同じ */
export const FACILITY_PAT_INFO_FAVORITE_PREF_CD = "9999";
export const FACILITY_PAT_INFO_ALL_JAPAN_PREF_CD = "0";

/**
 * @typedef {{
 *   pageSize: number,
 *   composeListId: string,
 *   pagingParamKeys: string[],
 * }} MasterPaginationEntry
 */

/** @type {Record<string, MasterPaginationEntry>} */
const REGISTRY = {
  [FACILITY_PAT_INFO]: {
    pageSize: 50,
    composeListId: "list_facility",
    pagingParamKeys: [
      "composePage",
      "composeLimit",
      "keyword",
      "prefecturesCd",
      "favoriteOwnerFacilityCd",
    ],
  },
};

/**
 * @param {string} masterType
 * @returns {MasterPaginationEntry | null | undefined}
 */
export function getPaginationConfig(masterType) {
  return REGISTRY[masterType];
}

export function getPaginationComposeListId(masterType) {
  return REGISTRY[masterType]?.composeListId ?? null;
}

/**
 * compose 用 lists からページング関連 sqlParams を除去
 * @param {unknown} specLists
 * @param {string} [masterType] 未指定時は先頭エントリの composeListId を試す
 */
export function clearComposePagingSqlParams(specLists, masterType) {
  if (!Array.isArray(specLists)) return;
  const cfg = masterType ? REGISTRY[masterType] : null;
  const listId = cfg?.composeListId;
  const spec = listId
    ? specLists.find(l => l.id === listId)
    : specLists.find(l => {
        const id = l && l.id;
        return id && Object.values(REGISTRY).some(e => e.composeListId === id);
      });
  const sqlParams = spec?.mstSource?.sqlParams;
  if (!sqlParams || typeof sqlParams !== "object") return;
  const keys =
    cfg?.pagingParamKeys ??
    REGISTRY[FACILITY_PAT_INFO]?.pagingParamKeys ??
    [];
  for (const key of keys) {
    delete sqlParams[key];
  }
}
