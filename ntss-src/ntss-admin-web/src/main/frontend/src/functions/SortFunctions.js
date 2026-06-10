/**
 * ソート 共通関数
 */
import { convertToHalfWidth } from "@/functions/common/CommonFunctions";

// ソート対象のフィールド名 → 実際のソートキーのマッピング
// - スネークケース、キャメルケースに対応
const SORT_KEY_MAP = {
  patName: "patNameSort",     // システム共通患者名ソート用（フリガナ優先）
  pat_name: "pat_name_sort",  // システム共通患者名ソート用（フリガナ優先）
  pat_personal_main$pat_name: "patNameSort",  // システム共通患者名ソート用（フリガナ優先）
  kurName: "kurStartTime",    // クール開始時刻
  bedName: "bedOrderIndex",   // ベッドマスタ表示順
  treatmentName: "treatmentOrderIndex", // 治療方法マスタ表示順
};

/**
 * 指定された時刻文字列をゼロ埋めして "HH:MM" の形式に整形します。
 *
 * @param {string} timeStr - ゼロ埋めする対象の時刻文字列（例: "1:5", "9:00"）
 * @returns {string} - 2桁ゼロ埋めされた時刻文字列（例: "01:05", "09:00"）
 *
 * @example
 * zeroPadTime("1:00");   // "01:00"
 * zeroPadTime("9:5");    // "09:05"
 */
const zeroPadTime = (timeStr) => {
  const [hour, min] = timeStr.split(":");
  const hh = hour.padStart(2, "0");
  const mm = min.padStart(2, "0");
  return `${hh}:${mm}`;
};

/**
 * ソート比較関数
 * @param {*} a 比較対象A
 * @param {*} b 比較対象B
 * @param {string} sortField ソート項目
 * @param {boolean} isAsc 昇順かのフラグ
 * @param {Object} [options={}] - ソート処理のオプション（省略可能）
 * @returns {number} - 比較結果（-1, 0, 1）
 * 
 * - 各項目の設定値
 * 
 * options.reverseFields の設定値：
 * 特定のフィールドに対して、昇順/降順の意味を逆にしたい場合に使用します。
 *
 * 通常の並び：
 *   - isAsc = true（昇順） → 小さい値 → 大きい値
 *   - isAsc = false（降順）→ 大きい値 → 小さい値
 *
 * reverseFields にフィールド名を指定すると：
 *   - isAsc = true（昇順） → 実際には降順で比較
 *   - isAsc = false（降順）→ 実際には昇順で比較
 * 
 * 例：
 *   const options = {
 *     reverseFields: ["treatDate", "isSame"]
 *   };
 * 
 * options.nullOrderRule の設定値（ソートにおける空欄（null / undefined / ""）の並び位置）：
 * {
 *   [fieldName: string]: "normal" | "reverse" | "last"
 *   ※kendoGridのsortable.compareから呼ぶ際に"last"を指定する場合は降順ソートで[isDesc: true]を指定する必要あり
 * }
 *
 * 各値の意味：
 * "normal"（デフォルト動作）:
 *   - 昇順（asc）のとき → 空欄は後方（末尾）に
 *   - 降順（desc）のとき → 空欄は先頭に
 *   - 例: { age: 'normal' }
 *
 * "reverse":
 *   - 昇順（asc）のとき → 空欄は先頭に
 *   - 降順（desc）のとき → 空欄は後方に
 *   - 例: { patName: "reverse" }
 *   - 特定項目で空欄の並びを反転させたい場合に使用
 *
 * "last":
 *   - 昇順・降順に関係なく常に空欄を後方（末尾）に配置
 *   - 例: { hospPatId: "last" }
 *   - 並び順に関係なく空欄を一番下に置きたいときに使用
 * 
 * options.notUseSortKeyMap の設定値：
 * SORT_KEY_MAPを未使用とするかをtrue/falseで指定します。
 *   - デフォルト: false -> SORT_KEY_MAPを使用
 *   - true -> SORT_KEY_MAP未使用の場合は各画面で制御します
 * 
 * options.orderAsNumberFields の設定値：
 * 特定のフィールドに対して、数値化できるものは数値でソートしたい場合に使用します。 ※検査結果など
 * 
 * 例：
 *   const options = {
 *     orderAsNumberFields: ["item_354_order_1", item_354_order_2]
 *   };
 * 
 * options.orderAsTimeFields の設定値：
 * 特定のフィールドに対して、時刻形式（hh:mm）にフォーマットしてソートしたい場合に使用します。 ※治療状況リスト＞治療時間など
 */
export function sortableCompare(a, b, sortField, isAsc, options = {}) {
  const {
    reverseFields = [],       // 昇順/降順を逆順でソートするフィールド
    nullOrderRule = {},       // 空欄位置の制御
    notUseSortKeyMap = false, // SORT_KEY_MAPを未使用とするか
    orderAsNumberFields = [], // 数値化できるものは数値でソートするフィールド
    orderAsTimeFields = [], 　// 時刻形式（hh:mm）にフォーマットしてソートするフィールド
  } = options;
  
  let sortFieldName = sortField;
  if (!notUseSortKeyMap) {
    // SORT_KEY_MAPを使用
    sortFieldName = SORT_KEY_MAP[sortFieldName] || sortFieldName;
  }

  let valA = a[sortFieldName];
  let valB = b[sortFieldName];

  // null、undefined、""の処理（値なしとみなす）
  const isEmpty = (v) => v === null || v === undefined || (typeof v === "string" && v.trim() === "");
  const aEmpty = isEmpty(valA);
  const bEmpty = isEmpty(valB);
  
  const rule = nullOrderRule[sortField] || "normal";
  const nullOrderRuleIsDesc = nullOrderRule["isDesc"] || false;
  
  // 空欄比較処理
  if (aEmpty || bEmpty) {
    if (aEmpty && bEmpty) return 0;

    // 空欄の位置制御
    switch (rule) {
      case "reverse":
        return isAsc
          ? (aEmpty ? -1 : 1) // 昇順：空欄を前へ
          : (aEmpty ? 1 : -1); // 降順：空欄を後ろへ
    
      case "last":
        return nullOrderRuleIsDesc // 常に空欄を後ろへ
          ? (aEmpty ? -1 : 1)
          : (aEmpty ? 1 : -1);
    
      case "normal":
      default:
        return isAsc
          ? (aEmpty ? 1 : -1) // 昇順：空欄を後ろへ
          : (aEmpty ? -1 : 1); // 降順：空欄を前へ
    }
  }
  
  // 時刻フォーマット
  if (orderAsTimeFields.includes(sortField)) {
    valA = zeroPadTime(valA);
    valB = zeroPadTime(valB);
  }

  // 値がある場合の比較
  let result;
  if (["hosp_pat_id", "hospPatId", "pat_personal_main$hosp_pat_id"].includes(sortField)) {
    // 患者ID
    result = compareHospPatId(valA, valB);
  } else if (["pat_name", "patName", "pat_personal_main$pat_name"].includes(sortField)) {
    // 患者名は辞書順
    result = valA.localeCompare(valB);
  } else if (orderAsNumberFields.includes(sortField)) {
    // 数値化できるものは数値でソートするfieldの場合
    result = compareAsNumber(valA, valB);
  } else {
    result = (valA === valB) ? 0 : (valA > valB ? 1 : -1);
  }
  
  // 指定されたキーで昇順/降順を反転
  const actualAsc = reverseFields.includes(sortField) ? !isAsc : isAsc;

  return actualAsc ? result : -result;
}

/**
 * 患者ID（hospPatId）用のカスタム比較関数
 *  - 患者検索＞患者リストの制御（ /ntss-core/src/main/java/jp/co/nikkiso/ntss/core/utils/PatSortCommonUtil.java >> compareHospPatIdFunc() ）と同じ
 * 
 * 比較ルール：
 *  1. 両方が数字のみ → 数値として比較、値が同じ場合は桁数で比較（桁数が短い方を先に）
 *  2. 一方が数字、もう一方が非数字 → 数字を優先
 *  3. その他 → 文字列として辞書順比較
 * 
 * @param {*} a - 比較対象A
 * @param {*} b - 比較対象B
 * @returns {number} - 比較結果（-1, 0, 1）
 */
export const compareHospPatId = (a, b) => {
  return compareAsNumber(a, b);
}

/**
 * 数値項目用のカスタム比較関数
 *  - 数値化できるものは数値でソートする（患者ID、検査結果で使用）
 * 
 * 比較ルール：
 *  全角 → 半角に変換して比較
 *  1. 両方が数字のみ → 数値として比較、値が同じ場合は桁数で比較（桁数が短い方を先に）
 *  2. 一方が数字、もう一方が非数字 → 数字を優先
 *  3. その他 → 文字列として辞書順比較
 * 
 * @param {*} a - 比較対象A
 * @param {*} b - 比較対象B
 * @returns {number} - 比較結果（-1, 0, 1）
 */
export const compareAsNumber = (a, b) => {
  const normA = convertToHalfWidth(a);
  const normB = convertToHalfWidth(b);

  const numA = Number(normA);
  const numB = Number(normB);

  const aIsNum = !Number.isNaN(numA);
  const bIsNum = !Number.isNaN(numB);

  // 1. 両方が数字のみ → 数値として比較、値が同じ場合は桁数で比較
  if (aIsNum && bIsNum) {
    if (numA < numB) return -1;
    if (numA > numB) return 1;

    // 数値が同じなら桁数が短い方を先に
    if (normA.length < normB.length) return -1;
    if (normA.length > normB.length) return 1;

    return 0;
  }
  
  // 2. 一方が数字、もう一方が非数字 → 数字を優先
  if (aIsNum && !bIsNum) return -1; // 数値は文字列より前
  if (!aIsNum && bIsNum) return 1;  // 文字列は数値より後

  // 3. その他 → 文字列として辞書順比較
  return normA.localeCompare(normB);
}

/**
 * 多段階ソート比較関数
 * 複数のソート条件に基づいて比較結果を返す
 * 
 * @param {Array} sortFields - ソート対象のフィールドと昇順or降順の配列
 *  例: [{ field: "patNameSort", dir: "asc" }, { field: "hospPatId", dir: "desc" }]
 * @param {Object} [options={}] - ソート処理のオプション（省略可能）、昇降逆転、空欄の扱い等
 * @returns {Function} 比較関数（Array.prototype.sort() に渡せる関数）
 */
export const multiSortableCompare = (sortFields, options = {}) => {
  return (a, b) => {
    for (const { field, dir } of sortFields) {
      // 昇順かどうかを判定
      const isAsc = dir === "asc";

      // 各フィールドでソート比較を実施
      const result = sortableCompare(a, b, field, isAsc, options);

      // 差がある（ソート結果が決まった）場合、その値を返す
      if (result !== 0) return result;
    }
    // すべてのフィールドで等しい場合は 0 を返す（並び順を変えない）
    return 0;
  };
};

/**
 * 列ヘッダクリック時のソートキーと昇順/降順を更新する関数
 * @param {string} key - クリックされたソート対象のキー
 * @param {Object} sort - ソート状態を保持するオブジェクト（{ key: string, isAsc: boolean }）
 */
export const updateSort = (key, sort) => {
  if ((key === sort.key && !sort.isAsc) || key === "") {
    // ソートをクリア
    sort.key = "";
    sort.isAsc = true;
    return;
  }
  sort.isAsc = sort.key === key ? !sort.isAsc : true;
  sort.key = key;
};

/**
 * ソートアイコンのclassを返す関数
 * @param {string} key - 対象の列キー
 * @param {Object} sort - ソート状態を保持するオブジェクト（{ key: string, isAsc: boolean }）
 * @returns {string} - クラス名（"sorted-asc", "sorted-desc" など）
 */
export const getSortedClass = (key, sort) => {
  return key === sort.key
    ? `sorted-${sort.isAsc ? "desc" : "asc"}`
    : "";
};

/**
 * リストを指定キーでグループ化する関数（Map保持で順序も保つ）
 * @param {Array} list - リスト
 * @param {(item: any) => string|number} getKey グループ化キーを取得するためのコールバック関数
 * @returns {Array} - 指定キーでグループ化したリストを返す
 */
export const groupBy = (list, getKey) => {
  const groupedMap = new Map();
  for (const item of list) {
    const key = getKey(item);
    if (!groupedMap.has(key)) groupedMap.set(key, []);
    groupedMap.get(key).push(item);
  }
  return Array.from(groupedMap.values());
};

/**
 * 患者/利用者情報オブジェクトまたはその配列に、ソート用の患者名（フリガナ優先）を patNameSort プロパティとして追加します。
 *
 * - 対応プロパティ（優先順）:
 *   - 姓: patLastNameKana, pat_last_name_kana, patLastName, pat_last_name
 *   - 名: patFirstNameKana, pat_first_name_kana, patFirstName, pat_first_name
 * - 結果の patNameSort は「姓 名」の形式になります（いずれか一方のみ存在する場合は単独）
 *
 * @param {Object|Object[]} input - 患者/利用者情報オブジェクトまたはその配列
 * @param {Boolean} isUser - 利用者情報かのフラグ
 * @returns {Object|Object[]} - patNameSort を追加したオブジェクトまたは配列（元の構造を保持）
 */
export const addPatNameSortToList = (input, isUser = false) => {
  const processItem = (item) => {
    if (!item || typeof item !== "object") return item;
    
    // プレフィックス切り替え（患者: pat / ユーザー: user）
    const prefix = isUser ? "user" : "pat";

    // システム共通ソート用(フリガナ優先文字列)をセット
    // - スネークケース、キャメルケースに対応
    const lastName =
      item[`${prefix}LastNameKana`]?.trim() ||
      item[`${prefix}_last_name_kana`]?.trim() ||
      item[`${prefix}LastName`]?.trim() ||
      item[`${prefix}_last_name`]?.trim() ||
      "";
    const firstName =
      item[`${prefix}FirstNameKana`]?.trim() ||
      item[`${prefix}_first_name_kana`]?.trim() ||
      item[`${prefix}FirstName`]?.trim() ||
      item[`${prefix}_first_name`]?.trim() ||
      "";

    const nameSort =
      lastName && firstName ? `${lastName} ${firstName}` : lastName || firstName;

    // 出力キーを切り替え
    const sortKey = isUser ? "userNameSort" : "patNameSort";

    return {
      ...item,
      [sortKey]: nameSort,
    };
  };

  if (Array.isArray(input)) {
    return input.map(processItem);
  } else {
    return processItem(input);
  }
};
