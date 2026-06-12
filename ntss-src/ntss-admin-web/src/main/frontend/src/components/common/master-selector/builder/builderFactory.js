import {
  MASTER,
  DOCTOR_PAT_INFO,
  STAFF_INFO,
  STAFF_PAT_INFO,
  FACILITY_PAT_INFO,
  VALID_IND_EQUIPMENT,
} from "../MasterType";
import { getMstListCompose } from "@/apis/pat-prescription";
import { ApiHelper } from "@/apis/AxiosHelper";
import {
  getMasterConfig
} from "@/components/common/master-selector/builder/masterPopoverConfig";
import { fitTermCheck } from "@/functions/common/DateTimeUtils";
import { normalizeTextForCompare } from "@/components/common/master-selector/utils/MasterSelectorUtil";
import {
  getPaginationConfig,
  FACILITY_PAT_INFO_FAVORITE_PREF_CD,
  FACILITY_PAT_INFO_ALL_JAPAN_PREF_CD,
} from "@/components/common/master-selector/builder/masterPaginationRegistry";
import { FACILITY_PAT_INFO_STATIC_PREFECTURE_OPTIONS } from "@/components/common/master-selector/builder/facilityPatInfoPrefectures";
import { buildValidIndEquipmentPopover } from "@/components/common/master-selector/builder/validIndEquipmentBuilder";
import {
  buildRstMediInfoMap,
  resolveSuspendMedicineRstName,
  resolveMedicineItemType,
  resolveMedicineItemCd,
  appendMissingAllowedMedicineOptions,
} from "@/components/indication/indMedicineSuspendData";

/**
 * MasterType から Master定義を取得
 */
function getMaster(masterType) {
  const master = MASTER[masterType];

  if (!master) {
    console.warn(`[builderFactory] Master not found: ${masterType}`);
    return null;
  }
  return master;
}

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
    if (!String(st).includes("【ﾏｽﾀ変更有】")) {
      const noChg = same.find(o => !String(o.text || "").includes("【ﾏｽﾀ変更有】"));
      if (noChg) return noChg;
    }
  }
  return same[0];
}

async function fetchFavoriteFacilityMedicalInstitutionCdsFromCompose(context) {
  const facilityCd = context?.facilityCd;
  if (facilityCd == null || facilityCd === "") return [];
  try {
    const data = await fetchFacilityFavoriteComposeData(context);
    const options = await buildMasterOptions(
      data.master ?? [],
      FACILITY_PAT_INFO,
      context
    );
    return options.map(option => String(option.value ?? "")).filter(Boolean);
  } catch {
    return [];
  }
}

async function fetchFacilityFavoriteComposeData(context) {
  const queryParams = cloneComposeRequest(
    getMasterConfig(FACILITY_PAT_INFO, context)
  );
  setComposeListSqlParams(
    queryParams,
    context,
    { favoriteOwnerFacilityCd: String(context.facilityCd) },
    FACILITY_PAT_INFO
  );
  const commonSearchApi = await getMstListCompose(queryParams);
  return commonSearchApi?.data ?? {};
}

function patchFacilityPatInfoPrefectureCategories(categories, preferredPrefValue) {
  let value = FACILITY_PAT_INFO_FAVORITE_PREF_CD;
  if (preferredPrefValue != null && preferredPrefValue !== "") {
    const s = String(preferredPrefValue);
    value = s === "all" ? FACILITY_PAT_INFO_ALL_JAPAN_PREF_CD : s;
  }
  return categories.map(category => {
    if (category.key !== "prefecturesCd") return category;
    const rest = (category.options || []).filter(option => option.value !== "all");
    const options = [
      { text: "よく使う施設", value: FACILITY_PAT_INFO_FAVORITE_PREF_CD },
      { text: "全国", value: FACILITY_PAT_INFO_ALL_JAPAN_PREF_CD },
      ...rest,
    ];
    return {
      ...category,
      value,
      options,
    };
  });
}

function alignFacilityPatInfoPrefectureCategory(
  categories,
  options,
  selectedItem,
  favoriteCds
) {
  const prefCategory = categories.find(category => category.key === "prefecturesCd");
  if (!prefCategory || !selectedItem) return;
  const selectedValue = String(selectedItem.value ?? "");
  if (!selectedValue) return;

  if (favoriteCds && favoriteCds.includes(selectedValue)) {
    prefCategory.value = FACILITY_PAT_INFO_FAVORITE_PREF_CD;
    return;
  }

  const option = options.find(item => String(item.value) === selectedValue);
  const prefecturesCd = option && (option.prefecturesCd ?? option.key_class);
  if (
    prefecturesCd != null &&
    prefecturesCd !== "" &&
    prefCategory.options.some(item => String(item.value) === String(prefecturesCd))
  ) {
    prefCategory.value = String(prefecturesCd);
    return;
  }

  prefCategory.value = FACILITY_PAT_INFO_ALL_JAPAN_PREF_CD;
}

function cloneComposeRequest(obj) {
  return JSON.parse(JSON.stringify(obj));
}

function resolveFacilityInitCd(context) {
  const { initItem, selectedItem, extraParams } = context || {};
  const value =
    (initItem && initItem.value != null && initItem.value !== ""
      ? initItem.value
      : null) ??
    (selectedItem && selectedItem.value != null && selectedItem.value !== ""
      ? selectedItem.value
      : null) ??
    (extraParams && extraParams.initValue != null && extraParams.initValue !== ""
      ? extraParams.initValue
      : null);
  return value != null && String(value).trim() !== "" ? String(value).trim() : null;
}

async function resolveFacilityOpenState(context, favoriteCds) {
  const initCd = resolveFacilityInitCd(context);
  if (!initCd) {
    return {
      initialPref: FACILITY_PAT_INFO_FAVORITE_PREF_CD,
      prefetchedFacilityRow: null,
    };
  }
  const selectedCd = String(initCd);
  if (favoriteCds && favoriteCds.includes(selectedCd)) {
    return {
      initialPref: FACILITY_PAT_INFO_FAVORITE_PREF_CD,
      prefetchedFacilityRow: null,
    };
  }
  try {
    const response = await ApiHelper.get(
      `/sysFacility/getSysFacilityByCd/${encodeURIComponent(selectedCd)}`
    );
    const data = response?.data;
    if (!data) {
      return {
        initialPref: FACILITY_PAT_INFO_ALL_JAPAN_PREF_CD,
        prefetchedFacilityRow: null,
      };
    }
    const prefecturesCd = data.prefecturesCd ?? data.prefectures_cd;
    const initialPref =
      prefecturesCd != null && prefecturesCd !== ""
        ? String(prefecturesCd)
        : FACILITY_PAT_INFO_ALL_JAPAN_PREF_CD;
    return { initialPref, prefetchedFacilityRow: data };
  } catch {
    return {
      initialPref: FACILITY_PAT_INFO_ALL_JAPAN_PREF_CD,
      prefetchedFacilityRow: null,
    };
  }
}

function setComposeListSqlParams(queryParams, context, patch, masterType) {
  const config = getPaginationConfig(masterType);
  const listId = config?.composeListId;
  if (!listId) return;
  const lists = queryParams?.lists;
  if (!Array.isArray(lists)) return;
  const spec = lists.find(list => list.id === listId);
  if (!spec?.mstSource) return;
  const initCd = resolveFacilityInitCd(context);
  const base =
    masterType === FACILITY_PAT_INFO && initCd != null
      ? { initFacilityCd: initCd }
      : {};
  spec.mstSource.sqlParams = { ...base, ...patch };
}

function resolveConcreteComposePrefectureFilter(prefecture) {
  const value = prefecture != null && prefecture !== "" ? String(prefecture) : "";
  if (
    !value ||
    value === "all" ||
    value === FACILITY_PAT_INFO_ALL_JAPAN_PREF_CD ||
    value === FACILITY_PAT_INFO_FAVORITE_PREF_CD
  ) {
    return null;
  }
  return value;
}

function facilityRowMatchesComposePrefecture(row, composePrefectureFilter) {
  if (composePrefectureFilter == null || row == null) return true;
  const prefecturesCd = row.prefecturesCd ?? row.prefectures_cd;
  if (prefecturesCd == null || prefecturesCd === "") return false;
  return String(prefecturesCd) === String(composePrefectureFilter);
}

function selectedItemKnownPrefForFilter(context, composePrefectureFilter) {
  if (composePrefectureFilter == null) return null;
  const item = context?.selectedItem ?? context?.initItem;
  if (!item) return null;
  const prefecturesCd = item.prefecturesCd ?? item.key_class;
  return prefecturesCd != null && prefecturesCd !== "" ? String(prefecturesCd) : null;
}

function pinSelectedFacilityOptionToTop(
  options,
  context,
  prefetchedFacilityRow,
  composePrefectureFilter = null
) {
  if (!Array.isArray(options)) return;
  if (composePrefectureFilter != null) return;

  const selectedCd = context?.selectedItem?.value ?? context?.initItem?.value;
  if (selectedCd == null || selectedCd === "") return;
  const selectedCdStr = String(selectedCd);

  const rowFromApi = data => ({
    ...data,
    value: data.medicalInstitutionCd ?? data.medical_institution_cd,
    text: data.facilityName ?? data.facility_name ?? data.name ?? "",
    prefecturesCd: data.prefecturesCd ?? data.prefectures_cd,
    key_class: data.prefecturesCd ?? data.prefectures_cd,
  });

  if (prefetchedFacilityRow) {
    const institutionCd =
      prefetchedFacilityRow.medicalInstitutionCd ??
      prefetchedFacilityRow.medical_institution_cd;
    if (institutionCd != null && String(institutionCd) === selectedCdStr) {
      const rest = options.filter(option => String(option.value ?? "") !== selectedCdStr);
      rest.unshift(rowFromApi(prefetchedFacilityRow));
      options.splice(0, options.length, ...rest);
      return;
    }
  }

  const index = options.findIndex(option => String(option.value ?? "") === selectedCdStr);
  if (index >= 0) {
    const [row] = options.splice(index, 1);
    options.unshift(row);
  }
}

async function ensureSelectedFacilityInOptions(
  options,
  context,
  prefetchedFacilityRow = null,
  composePrefectureFilter = null
) {
  const selectedCd = context?.selectedItem?.value ?? context?.initItem?.value;
  if (selectedCd == null || selectedCd === "") return;
  if (options.some(option => String(option.value) === String(selectedCd))) return;

  const knownPref = selectedItemKnownPrefForFilter(context, composePrefectureFilter);
  if (
    knownPref != null &&
    composePrefectureFilter != null &&
    knownPref !== String(composePrefectureFilter)
  ) {
    return;
  }

  if (prefetchedFacilityRow) {
    const data = prefetchedFacilityRow;
    const institutionCd = data.medicalInstitutionCd ?? data.medical_institution_cd;
    if (
      institutionCd != null &&
      String(institutionCd) === String(selectedCd) &&
      facilityRowMatchesComposePrefecture(data, composePrefectureFilter)
    ) {
      options.unshift({
        ...data,
        value: institutionCd,
        text: data.facilityName ?? data.facility_name ?? data.name ?? "",
        prefecturesCd: data.prefecturesCd ?? data.prefectures_cd,
        key_class: data.prefecturesCd ?? data.prefectures_cd,
      });
      return;
    }
  }

  try {
    const response = await ApiHelper.get(
      `/sysFacility/getSysFacilityByCd/${encodeURIComponent(selectedCd)}`
    );
    const data = response?.data;
    if (!data) return;
    if (!facilityRowMatchesComposePrefecture(data, composePrefectureFilter)) return;
    options.unshift({
      ...data,
      value: data.medicalInstitutionCd,
      text: data.facilityName,
      prefecturesCd: data.prefecturesCd,
      key_class: data.prefecturesCd,
    });
  } catch {
    // ignore
  }
}

function buildFacilityPatInfoCategoriesFromStatic(patchPrefForUi) {
  const staticCategory = {
    key: "prefecturesCd",
    label: "都道府県",
    value: "all",
    options: [
      { text: "すべて", value: "all" },
      ...FACILITY_PAT_INFO_STATIC_PREFECTURE_OPTIONS,
    ],
  };
  return patchFacilityPatInfoPrefectureCategories([staticCategory], patchPrefForUi);
}

export async function fetchFacilityPatInfoComposePage(
  context,
  {
    prefecturesCategoryValue,
    keyword = "",
    page = 0,
    favoriteCds: favoriteCdsOpt,
    prefetchedFacilityRow = null,
    alignPrefectureToSelection = true,
    reuseComposeData = null,
  } = {}
) {
  const paginationConfig = getPaginationConfig(FACILITY_PAT_INFO);
  const pageSize = paginationConfig?.pageSize ?? 50;
  const prefecture = String(
    prefecturesCategoryValue ?? FACILITY_PAT_INFO_FAVORITE_PREF_CD
  );
  const hasFacilityCd =
    context?.facilityCd != null && String(context.facilityCd).trim() !== "";

  const buildPagedPatch = () => {
    const patch = {
      composePage: String(page),
      composeLimit: String(pageSize),
    };
    const keywordText = keyword != null ? String(keyword).trim() : "";
    if (keywordText) {
      patch.keyword = keywordText;
    }
    if (
      prefecture &&
      prefecture !== "all" &&
      prefecture !== FACILITY_PAT_INFO_ALL_JAPAN_PREF_CD &&
      prefecture !== FACILITY_PAT_INFO_FAVORITE_PREF_CD
    ) {
      patch.prefecturesCd = prefecture;
    }
    return patch;
  };

  const fetchCompose = async patch => {
    const queryParams = cloneComposeRequest(
      getMasterConfig(FACILITY_PAT_INFO, context)
    );
    setComposeListSqlParams(queryParams, context, patch, FACILITY_PAT_INFO);
    const commonSearchApi = await getMstListCompose(queryParams);
    return commonSearchApi?.data ?? {};
  };

  let data;
  let useFavoriteMode = false;

  if (reuseComposeData != null) {
    data = reuseComposeData;
    useFavoriteMode =
      prefecture === FACILITY_PAT_INFO_FAVORITE_PREF_CD && hasFacilityCd;
  } else if (prefecture === FACILITY_PAT_INFO_FAVORITE_PREF_CD && hasFacilityCd) {
    useFavoriteMode = true;
    data = await fetchCompose({
      favoriteOwnerFacilityCd: String(context.facilityCd),
    });
    const quickOptions = await buildMasterOptions(
      data.master ?? [],
      FACILITY_PAT_INFO,
      context
    );
    if (quickOptions.length === 0) {
      useFavoriteMode = false;
      data = await fetchCompose(buildPagedPatch());
    }
  } else {
    data = await fetchCompose(buildPagedPatch());
  }

  let patchPrefForUi = prefecture;
  if (prefecture === "all") {
    patchPrefForUi = FACILITY_PAT_INFO_ALL_JAPAN_PREF_CD;
  }
  if (!useFavoriteMode && prefecture === FACILITY_PAT_INFO_FAVORITE_PREF_CD) {
    patchPrefForUi = FACILITY_PAT_INFO_ALL_JAPAN_PREF_CD;
  }

  const categories = buildFacilityPatInfoCategoriesFromStatic(patchPrefForUi);
  const options = await buildMasterOptions(
    data.master ?? [],
    FACILITY_PAT_INFO,
    context
  );
  const composePrefectureFilter = resolveConcreteComposePrefectureFilter(prefecture);
  if (!useFavoriteMode) {
    pinSelectedFacilityOptionToTop(
      options,
      context,
      prefetchedFacilityRow,
      composePrefectureFilter
    );
    await ensureSelectedFacilityInOptions(
      options,
      context,
      prefetchedFacilityRow,
      composePrefectureFilter
    );
  }
  const selectedItem = resolvePopoverSelectedItem(options, context.selectedItem);

  const favoriteCds =
    favoriteCdsOpt != null
      ? favoriteCdsOpt
      : useFavoriteMode
        ? options.map(option => String(option.value ?? "")).filter(Boolean)
        : [];

  if (alignPrefectureToSelection) {
    alignFacilityPatInfoPrefectureCategory(
      categories,
      options,
      selectedItem,
      favoriteCds
    );
  }
  if (
    alignPrefectureToSelection &&
    !useFavoriteMode &&
    prefecture === FACILITY_PAT_INFO_FAVORITE_PREF_CD
  ) {
    const prefectureCategory = categories.find(category => category.key === "prefecturesCd");
    if (prefectureCategory) {
      prefectureCategory.value = FACILITY_PAT_INFO_ALL_JAPAN_PREF_CD;
    }
  }

  const mode = useFavoriteMode ? "favorite" : "paged";
  const pagination = {
    enabled: true,
    mode,
    page,
    pageSize,
    hasMore: mode === "favorite" ? false : data.master?.hasMore === true,
    prefecturesCd:
      !useFavoriteMode && prefecture === FACILITY_PAT_INFO_FAVORITE_PREF_CD
        ? FACILITY_PAT_INFO_ALL_JAPAN_PREF_CD
        : prefecture,
    keyword: keyword != null ? String(keyword) : "",
    loading: false,
  };

  return {
    headerTitle: MASTER_FIELD_MAP[FACILITY_PAT_INFO].headerTitle,
    categories,
    master: {
      key: "master",
      label: MASTER_FIELD_MAP[FACILITY_PAT_INFO].label,
      options,
      selectedItem,
      pagination,
    },
    favoriteFacilityMedicalInstitutionCds: favoriteCds,
  };
}

export async function appendFacilityPatInfoComposePage(innerPopoverData, context) {
  const pagination = innerPopoverData?.master?.pagination;
  const paginationConfig = getPaginationConfig(FACILITY_PAT_INFO);
  if (
    !pagination ||
    pagination.mode !== "paged" ||
    !pagination.hasMore ||
    !paginationConfig
  ) {
    return null;
  }

  const pageSize = pagination.pageSize ?? paginationConfig.pageSize;
  const queryParams = cloneComposeRequest(
    getMasterConfig(FACILITY_PAT_INFO, context)
  );
  const patch = {
    composePage: String(pagination.page + 1),
    composeLimit: String(pageSize),
  };
  const keyword = pagination.keyword != null ? String(pagination.keyword).trim() : "";
  if (keyword) {
    patch.keyword = keyword;
  }
  const prefecture =
    pagination.prefecturesCd != null ? String(pagination.prefecturesCd) : "";
  if (
    prefecture &&
    prefecture !== "all" &&
    prefecture !== FACILITY_PAT_INFO_ALL_JAPAN_PREF_CD &&
    prefecture !== FACILITY_PAT_INFO_FAVORITE_PREF_CD
  ) {
    patch.prefecturesCd = prefecture;
  }
  setComposeListSqlParams(queryParams, context, patch, FACILITY_PAT_INFO);
  const commonSearchApi = await getMstListCompose(queryParams);
  const data = commonSearchApi?.data ?? {};
  return {
    newOptions: await buildMasterOptions(data.master ?? [], FACILITY_PAT_INFO, context),
    hasMore: data.master?.hasMore === true,
    nextPage: pagination.page + 1,
  };
}

async function buildFacilityOpeningPopoverPaginated(context) {
  const initCd = resolveFacilityInitCd(context);
  let reuseComposeData = null;
  let favoriteCdsFromProbe = null;
  if (initCd && context?.facilityCd) {
    const probeData = await fetchFacilityFavoriteComposeData(context);
    const probeOptions = await buildMasterOptions(
      probeData.master ?? [],
      FACILITY_PAT_INFO,
      context
    );
    const cds = probeOptions
      .map(option => String(option.value ?? ""))
      .filter(Boolean);
    favoriteCdsFromProbe = cds;
    if (cds.includes(String(initCd))) {
      reuseComposeData = probeData;
    }
  }
  const { initialPref, prefetchedFacilityRow } = await resolveFacilityOpenState(
    context,
    favoriteCdsFromProbe ?? []
  );
  const keyword =
    context && context.composeKeyword != null ? String(context.composeKeyword) : "";
  return fetchFacilityPatInfoComposePage(context, {
    prefecturesCategoryValue: initialPref,
    keyword,
    page: 0,
    ...(favoriteCdsFromProbe != null ? { favoriteCds: favoriteCdsFromProbe } : {}),
    prefetchedFacilityRow,
    reuseComposeData,
  });
}

const PAGINATED_COMPOSE_HANDLERS = {
  [FACILITY_PAT_INFO]: {
    fetchPage: fetchFacilityPatInfoComposePage,
    appendPage: appendFacilityPatInfoComposePage,
    buildOpeningPopover: buildFacilityOpeningPopoverPaginated,
  },
};

export function getPaginatedComposeHandlers(masterType) {
  if (!getPaginationConfig(masterType)) return null;
  return PAGINATED_COMPOSE_HANDLERS[masterType] ?? null;
}

/**
 * 初期選択項目構築
 */
export function buildInitSelectedItem(masterType, context) {
  const master = getMaster(masterType);
  if (!master) return null;
  const builder = master.builder;
  if (!builder) return null;
  if (typeof builder.buildInitSelectedItem !== "function") return null;
  return builder.buildInitSelectedItem(context);
}

/**
 * Popover構築処理
 */
export async function buildMasterPopover(masterType, context) {
  if (masterType === VALID_IND_EQUIPMENT) {
    return buildValidIndEquipmentPopover(context);
  }

  const paginatedHandlers = getPaginatedComposeHandlers(masterType);
  if (paginatedHandlers?.buildOpeningPopover) {
    return paginatedHandlers.buildOpeningPopover(context);
  }

  // 検索パラメータを生成する
  const queryParams = getMasterConfig(masterType, context);

  if (!queryParams) {
    const master = getMaster(masterType);
    const builder = master?.builder;
    if (builder && typeof builder.buildMasterPopover === "function") {
      return builder.buildMasterPopover(context);
    }
    console.warn(`[masterPopover] クエリパラメータ生成失敗 masterType=${masterType}`);
    return null;
  }

  // 共通検索API
  const commonSearchApi = await getMstListCompose(queryParams);

  const data = commonSearchApi?.data ?? {};

  let categories;

  if (masterType == 'va_treatment_record') {
    categories = vaBuildCategories();
  }else {
    categories = buildCategoriesFromFilterLists(data);
  }

  let favoriteFacilityMedicalInstitutionCds = null;
  if (masterType === FACILITY_PAT_INFO) {
    categories = patchFacilityPatInfoPrefectureCategories(categories);
    try {
      favoriteFacilityMedicalInstitutionCds =
        await fetchFavoriteFacilityMedicalInstitutionCdsFromCompose(context);
    } catch {
      favoriteFacilityMedicalInstitutionCds = [];
    }
  }

  const options = await buildMasterOptions(data.master ?? [], masterType, context);

  let selectedItem = resolvePopoverSelectedItem(options, context.selectedItem);
  // #11872 患者情報・診断医：未選択時は extraParams.initValue（ログインユーザ）を一覧から拾い POP 上で初期選択
  const INIT_SELECT_MASTER_TYPES = new Set([
    DOCTOR_PAT_INFO,
    STAFF_INFO,
    STAFF_PAT_INFO,
  ]);
  if (
    !selectedItem &&
    INIT_SELECT_MASTER_TYPES.has(masterType) &&
    options?.length
  ) {
    const cur = context.selectedItem && context.selectedItem.value;
    const hasCurrent =
      cur != null &&
      cur !== "" &&
      String(cur).trim() !== "" &&
      String(cur).trim() !== "undefined";
    if (!hasCurrent) {
      const uid = context.extraParams && context.extraParams.initValue;
      if (uid != null && String(uid).trim() !== "") {
        selectedItem =
          options.find(o => String(o.value) === String(uid)) || null;
      }
    }
  }

  if (masterType === FACILITY_PAT_INFO) {
    alignFacilityPatInfoPrefectureCategory(
      categories,
      options,
      selectedItem,
      favoriteFacilityMedicalInstitutionCds
    );
  }

  const result = {
    headerTitle: MASTER_FIELD_MAP[masterType].headerTitle,
    categories,
    master: {
      key: "master",
      label: MASTER_FIELD_MAP[masterType].label,
      options,
      selectedItem
    }
  };

  if (masterType === FACILITY_PAT_INFO) {
    result.favoriteFacilityMedicalInstitutionCds = favoriteFacilityMedicalInstitutionCds;
  }

  return result;
}

function buildCategoriesFromFilterLists(raw) {

  const filterLists = raw.filterList || {};

  return Object.values(filterLists).flatMap(list =>
    Object.values(list).map(sub => {

      const options = (sub.items || []).map(item => ({
        text: item.className ? item.className : item.value,
        value: item.classCd ? item.classCd : item.cd
      }));

      options.unshift({
        text: "すべて",
        value: "all"
      });

      return {
        key: sub.filterKey,
        label: sub.filterLabel,
        value: "all",
        options: options
      };
    })
  );
}

async function buildMasterOptions(master, masterType, context) {
  const map = MASTER_FIELD_MAP[masterType];

  const items = master?.items ?? [];

  const allowed = context?.allowedFields;
  const allowedData = Array.isArray(allowed?.data) ? allowed.data : null;
  const shouldFilterByAllowedFields =
    allowed?.showMedicineFieldOnly === true &&
    Array.isArray(allowedData) &&
    allowedData.length > 0 &&
    (masterType === "medication_treatment_record" ||
      masterType === "medication_treatment_classtype_record");

  const initV = context?.initItem?.value;
  const selV = context?.selectedItem?.value;
  const keepValues = [initV, selV]
    .filter(v => v != null && v !== "")
    .map(v => String(v));

  const isAllowedSuspendMedicine = (cd, medType) =>
    allowedData.some(opt => {
      if (String(opt?.cd) !== String(cd)) return false;
      const optType = opt?.medicineType ?? opt?.medicine_type ?? "1";
      if (medType == null || medType === "") return true;
      return String(optType) === String(medType);
    });

  const isActualRstSuspend =
    shouldFilterByAllowedFields && Number(context?.dialysisState || 0) !== 0;
  const suspendRstMediMap = isActualRstSuspend
    ? buildRstMediInfoMap(context?.extraParams?.currentOrdMainData)
    : null;

  let filteredItems = shouldFilterByAllowedFields
    ? items.filter(item => {
        const itemValue = resolveField(item, map.value) ?? resolveMedicineItemCd(item);
        if (itemValue != null && keepValues.includes(String(itemValue))) return true;

        const cd = resolveMedicineItemCd(item);
        const medType = resolveMedicineItemType(item);
        if (cd == null) return false;

        return isAllowedSuspendMedicine(cd, medType);
      })
    : items;

  if (shouldFilterByAllowedFields) {
    filteredItems = appendMissingAllowedMedicineOptions(filteredItems, allowedData, {
      suspendRstMediMap,
      isActualRst: isActualRstSuspend,
      masterItems: items,
    });
  }

  return filteredItems.map(item => {
    const rawText = resolveField(item, map.text);

    // 投与薬剤中止：getPatIndMmdicine 白名单 + currentOrdMainData の実績名。実績時は接頭辞なし
    if (isActualRstSuspend) {
      const cd = resolveMedicineItemCd(item);
      const medType = resolveMedicineItemType(item);
      const rstName = resolveSuspendMedicineRstName(suspendRstMediMap, cd, medType);
      return {
        ...item,
        classValue: resolveField(item, map.classValue),
        value: resolveField(item, map.value) ?? cd,
        text: rstName || rawText || item.text || (cd != null ? String(cd) : ""),
      };
    }

    const hideDeletedPrefix = context?.extraParams?.hideDeletedPrefix === true;
    const ext = (
      context?.dialysisState == 0 || context?.dialysisState == null
        ? [
            item.tabooAllergy,
            item.classInconsistent,
            item.expired,
            ...(hideDeletedPrefix ? [] : [item.deleted]),
            item.includeDeleted
          ]
        : [item.tabooAllergy]
    ).filter(Boolean).join("");

    return {
      ...item,
      classValue: resolveField(item, map.classValue),
      value: resolveField(item, map.value),
      text: ext + rawText
    };
  });
}

/**
 * マスタオプションを構築
 */
async function medicationClassBuildMasterOptions(
  master,
  categories,
  context
) {

  const medicineList =  master.items.filter(item => item.key_type == 1) || [];
  const medicineMixList = master.items.filter(item => item.key_type == 2) || [];
  const { initItem, selectedItem, extraParams } = context;
  const treatDate = extraParams.treatDate;
  const rstName = extraParams.rstInfo.rstName || '';
  const rstUnit = extraParams.rstInfo.rstUnit || '';

  // 医薬品リストのフィルタリング
  const filteredMedicineList = medicineList.filter(item => {
    // 初期選択項目と一致する場合は常に表示
    if (initItem && String(initItem.value) === String(item.medicineCd)) {
      return true;
    }
    // 有効期限チェック
    return fitTermCheck(item.useStartDate, item.useEndDate, treatDate);
  });

  // 医薬品混合リストのフィルタリング
  const filteredMedicineMixList = medicineMixList.filter(item => {
    // 初期選択項目と一致する場合は常に表示
    if (initItem && String(initItem.value) === String(item.medicineMixCd)) {
      return true;
    }
    // 有効期限チェック
    return fitTermCheck(item.maxUseStartDate, item.minUseEndDate, treatDate);
  });

  // カテゴリオプションの取得
  const classOptions = (categories?.find(category => category.key === "class") || {}).options || [];
  // 医薬品のクラスフィルタリング用関数
  const filterByClass = (item, cd) => {
    return classOptions.some(option => {
      return item.key_class === option.value ||
        (initItem?.value != null && item[cd] == initItem.value) ||
        (selectedItem?.value != null && item[cd] == selectedItem.value);
    });
  };

  // 表示状態フィルタリング用関数
  const filterByDisplayStatus = (item, cd) => {
    return item.isDisp === "1" ||
      (initItem?.value != null && item[cd] == initItem.value) ||
      (selectedItem?.value != null && item[cd] == selectedItem.value);
  };
  const allowedFields = (item, val, cd, type) =>{
    return val.some(option=>{
      return item[cd] == option.cd && item[type] == option.medicineType
    })
  }
  // 医薬品オプションのマッピング関数
  const mapMedicineItem = (item, cdKey, nameKey, unitKey, kbnValue) => {

    let prefix = '';
    let statusText = '';

    statusText = `${item.expired}${item.deleted}${item.includeDeleted}`;
    
    prefix = item.classInconsistent || '';
    return {
      ...item,
      rstName: rstName,
      rstUnit: rstUnit ? rstUnit : "",
      value: kbnValue === "1" ? item[cdKey] : `${item[cdKey]}`,
      kbnValue: kbnValue,
      classValue: item.classCd,
      unit: item[unitKey],
      text: prefix + item.tabooAllergy + statusText + item[nameKey],
    };
  };
  // 医薬品オプションの生成
  let contentMedicine = null
  let contentMedicineMix = null
  if(context.allowedFields.showMedicineFieldOnly){
    contentMedicine = filteredMedicineList
      .filter(item => allowedFields(item, context.allowedFields.data, "medicineCd","key_type"))
      .map(item => mapMedicineItem(item, "medicineCd", "medicineName", "unit", "1"))

      // 医薬品混合オプションの生成
    contentMedicineMix = filteredMedicineMixList
      .filter(item => allowedFields(item, context.allowedFields.data, "medicineMixCd","key_type"))
      .map(item => mapMedicineItem(item, "medicineMixCd", "medicineMixName", "unit", "2"))
  }else{
    contentMedicine = filteredMedicineList
    .filter(item => context.isMedicament==1? filterByClass(item, "medicineCd"): true)
    .filter(item => filterByDisplayStatus(item, "medicineCd"))
    .map(item => mapMedicineItem(item, "medicineCd", "medicineName", "unit", "1"))

  // 医薬品混合オプションの生成
  contentMedicineMix = filteredMedicineMixList
    .filter(item => context.isMedicament==1? filterByClass(item, "medicineMixCd"): true)
    .filter(item => filterByDisplayStatus(item, "medicineMixCd"))
    .map(item => mapMedicineItem(item, "medicineMixCd", "medicineMixName", "unit", "2"))
  }
  const merged = [...contentMedicine, ...contentMedicineMix]
    .sort((a, b) => b.isDisp - a.isDisp);
  return merged;
}

const MASTER_FIELD_MAP = {
  equipment_set_record: {
    value: ["equipmentSetCd"],
    text: ["equipmentSetName"],
    classValue: "equipmentSetClassCd",
    headerTitle: "医療材料セット",
    label: "医療材料セット名"
  },
  medicine_set_indication_record: {
    value: ["medicineSetCd", "key_cd"],
    text: ["medicineSetName", "name", "text"],
    classValue: "key_class",
    headerTitle: "薬剤セット",
    label: "薬剤セット名"
  },
  wheel_chair_owner_patient_master: {
    value: ["patId", "pat_id", "key_cd"],
    text: item =>
      `${item.patLastName != null ? item.patLastName : item.pat_last_name != null ? item.pat_last_name : ""}${item.patFirstName != null ? item.patFirstName : item.pat_first_name != null ? item.pat_first_name : ""}`.trim(),
    classValue: "key_class",
    headerTitle: "所有患者",
    label: "患者名"
  },
  equipment_treatment_record: {
    value: ['equipmentCd', 'dialyzerCd'],
    text: ['equipmentName', 'modelNumber'],
    classValue: ['classCd','key_class'],
    headerTitle: "医療材料",
    label: "医療材料名"
  },
  valid_ind_equipment: {
    value: ['equipmentCd', 'dialyzerCd'],
    text: ['equipmentName', 'modelNumber'],
    classValue: ['classCd','key_class'],
    headerTitle: "医療材料",
    label: "医療材料名"
  },
  medication_treatment_record: {
    value: ['medicineCd','medicineMixCd'],
    text: ['medicineName','medicineMixName'],
    classValue: "classCd",
    headerTitle: "薬剤",
    label: "薬剤名"
  },
  dialyzer_treatment_record: {
    value: ['dialyzerCd'],
    text: ['modelNumber'],
    classValue: ['dialyzerType'],
    headerTitle: "ダイアライザ",
    label: "ダイアライザ名"
  },
  equipment_treatment_classtype_record: {
    value: ['equipmentCd', 'dialyzerCd'],
    text: ['equipmentName', 'modelNumber'],
    classValue: ['classCd','key_class'],
    headerTitle: "医療材料",
    label: "医療材料名"
  },
  medication_treatment_classtype_record: {
    value: ['medicineCd','medicineMixCd'],
    text: ['medicineName','medicineMixName'],
    classValue: "classCd",
    headerTitle: "薬剤",
    label: "薬剤名"
  },
  va_treatment_record: {
    value: ['va_cd'],
    text: ['va_name'],
    classValue: "va_direct",
    headerTitle: "VA",
    label: "VA名"
  },
  personal_user_treatment_record: {
    value: ["userId", "key_cd"],
    text: item =>
      `${item.userLastName != null ? item.userLastName : ""} ${item.userFirstName != null ? item.userFirstName : ""}`.trim(),
    classValue: "key_class",
    headerTitle: "利用者",
    label: "利用者名"
  },
  practitioner_check_list: {
    value: ["userId", "key_cd"],
    text: item =>
      `${item.userLastName != null ? item.userLastName : ""} ${item.userFirstName != null ? item.userFirstName : ""}`.trim(),
    classValue: "key_class",
    headerTitle: "実施者",
    label: "実施者名"
  },
  complaint_treatment_record: {
    value: ["complaintCd", "key_cd"],
    text: ["complaintName", "name", "text"],
    classValue: "key_class",
    headerTitle: "愁訴",
    label: "愁訴名"
  },
  comp_treatment_record: {
    value: ["compTreatmentCd", "key_cd"],
    text: ["treatment", "name", "text"],
    classValue: "key_class",
    headerTitle: "処置",
    label: "処置名"
  },
  procedure_treatment_record: {
    value: ["procedureCd", "key_cd"],
    text: ["pricedureName", "procedureName", "name", "text"],
    classValue: "key_class",
    headerTitle: "手技",
    label: "手技名"
  },
  wheel_chair_treatment_record: {
    value: ["wheelChairCd", "key_cd"],
    text: ["wheelChairName", "name", "text"],
    classValue: "key_class",
    headerTitle: "車いす",
    label: "車いす名称"
  },
  severity_pat_info: {
    value: ["severityCd", "key_cd"],
    text: ["severityName", "name", "text"],
    classValue: "key_class",
    headerTitle: "重症度",
    label: "重症度"
  },
  transport_pat_info: {
    value: ["transportCd", "key_cd"],
    text: ["transportName", "name", "text"],
    classValue: "key_class",
    headerTitle: "搬送",
    label: "搬送"
  },
  wheel_chair_pat_info: {
    value: ["wheelChairCd", "key_cd"],
    text: ["wheelChairName", "name", "text"],
    classValue: "key_class",
    headerTitle: "車いす",
    label: "車いす名称"
  },
  facility_pat_info: {
    /**
     * 患者情報の診断施設・入外施設等は getSysFacilityByCdList が医療機関コード基準のため、
     * compose が snake_case や facilityCd 先頭の行でも医療機関コードを最優先する。
     */
    value: item => {
      const inst = item.medicalInstitutionCd ?? item.medical_institution_cd;
      if (inst != null && inst !== "") return inst;
      const fc = item.facilityCd ?? item.facility_cd ?? item.key_cd;
      return fc != null && fc !== "" ? fc : "";
    },
    text: item =>
      item.facilityName ??
      item.facility_name ??
      item.name ??
      item.text ??
      "",
    classValue: "key_class",
    headerTitle: "施設",
    label: "施設名"
  },
  course_pat_info: {
    value: ["courseCd", "key_cd"],
    text: ["courseName", "name", "text"],
    classValue: "key_class",
    headerTitle: "診療科",
    label: "診療科名"
  },
  doctor_pat_info: {
    value: ["userId", "key_cd"],
    text: item =>
      `${item.userLastName != null ? item.userLastName : ""} ${item.userFirstName != null ? item.userFirstName : ""}`.trim(),
    classValue: "key_class",
    headerTitle: "担当医",
    label: "担当医名"
  },
  staff_pat_info: {
    value: ["userId", "key_cd"],
    text: item =>
      `${item.userLastName != null ? item.userLastName : ""} ${item.userFirstName != null ? item.userFirstName : ""}`.trim(),
    classValue: "key_class",
    headerTitle: "担当者",
    label: "担当者名"
  },
  staff_info: {
    value: ["userId", "key_cd"],
    text: item =>
      `${item.userLastName != null ? item.userLastName : ""} ${item.userFirstName != null ? item.userFirstName : ""}`.trim(),
    classValue: "key_class",
    headerTitle: "スタッフ",
    label: "スタッフ名"
  },
  implant_pat_info: {
    value: ["implantCd", "key_cd"],
    text: ["implantName", "name", "text"],
    classValue: "key_class",
    headerTitle: "インプラント",
    label: "内容"
  },
  relationship_pat_info: {
    value: ["relationshipCd", "key_cd"],
    text: ["relationshipName", "name", "text"],
    classValue: "key_class",
    headerTitle: "続柄",
    label: "続柄名"
  },
  nationality_pat_info: {
    value: ["countryCdAlpha3", "key_cd"],
    text: ["countryName", "name", "text"],
    classValue: "key_class",
    headerTitle: "国籍",
    label: "国名"
  },
  dialysis_course_pat_info: {
    value: ["courseCd", "key_cd"],
    text: ["courseName", "name", "text"],
    classValue: "key_class",
    headerTitle: "透析実施科",
    label: "透析実施科名"
  },
  ward_pat_info: {
    value: ["wardCd", "key_cd"],
    text: ["wardName", "name", "text"],
    classValue: "key_class",
    headerTitle: "病棟",
    label: "病棟名"
  },
  taboo_allergy_pat_info: {
    value: ["tabooAllergyCd", "key_cd"],
    text: ["content", "name", "text"],
    classValue: "key_class",
    headerTitle: "禁忌・アレルギー",
    label: "禁忌・アレルギー名"
  },
  disease_pat_info: {
    value: ["diseaseCd", "key_cd"],
    text: ["diseaseName", "name", "text"],
    classValue: "key_class",
    headerTitle: "病名",
    label: "病名"
  },
  insurance_pat_info: {
    value: ["insuCd", "code", "key_cd"],
    text: ["name", "insu_name", "text"],
    classValue: "key_class",
    headerTitle: "保険選択",
    label: "保険名"
  },
  other_contact_pat_pat_info: {
    value: ["patId", "key_cd"],
    text: ["patName", "name", "text"],
    classValue: "key_class",
    headerTitle: "患者",
    label: "患者名"
  },
  addition_pat_info: {
    value: ["additionCd", "key_cd", "code"],
    text: ["additionName", "name", "text"],
    classValue: "key_class",
    headerTitle: "加算・管理料",
    label: "加算・管理料"
  }
};

function resolveField(item, field) {
  if (typeof field === 'function') {
    return field(item);
  }

  if (Array.isArray(field)) {
    for (const key of field) {
      const value = item[key];
      if (value !== undefined && value !== null && value !== '') {
        return value;
      }
    }
    return '';
  }

  return item[field];
}
function vaBuildCategories() {
  return [
    {
      key: "class",
      label: "VA方向",
      value: 'all',
      options: [
        { text: "すべて", value: 'all' },
        { text: "両方", value: "0" },
        { text: "左", value: "1" },
        { text: "右", value: "2" },
        { text: "なし", value: "3" },
        { text: "不明", value: "-" }
      ]
    }
  ];
}
