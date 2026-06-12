import {
  sendRequestFindRecordListByFacilityCd,
  sendRequestUpdateRecordListByFacilityCd,
} from "@/apis/master-maintenance";

/**
 * @description 子項目リストから削除対象に含まれるコードの要素を削除した配列を生成する
 * @param {Array} items 子項目リスト
 * @param {Array} deleteCodes 削除対象コード配列
 * @returns {Array} 処理後の配列
 */
const dataProcessing = (items, deleteCodes) => items.filter(item => (
  !deleteCodes.includes(String(item.code || item.cd || item))
));
/**
 * @description レコードの対象フィールドのリストJSONから
 * 削除対象に含まれるコードの要素を削除する処理を行い、
 * 削除対象があった場合はtrueを返す
 * @param {Object} record 処理対象レコード
 * @param {String} field 処理対象フィールド名
 * @param {Array} deleteCodes 削除対象コード配列
 * @returns {boolean} 子項目リストに削除対象コードがあった場合はtrue
 */
const fieldProcessing = (record, field, deleteCodes) => {
  if (!record[field]) return false;

  const items = record[field] ? JSON.parse(record[field]) : [];
  const newItems = dataProcessing(items, deleteCodes);
  // 削除対象があればフィールドの値を更新して operation を更新の値にする
  if (newItems.length === items.length) return false;
  record[field] = JSON.stringify(newItems);
  record.operation = 2;
  return true;
};
/**
 * @description 点検項目マスタ、点検グループマスタ、点検レイアウトマスタの更新時に
 * 削除されたコードを親項目となる点検グループマスタ、点検レイアウトマスタ、
 * 点検機種別レイアウトマスタが持つリストから削除する
 * @param {String} facilityCd 施設コード
 * @param {String} masterName 更新対象マスタ名
 * @param {Array} data 更新対象マスタデータ配列
 */
export const deleteDataProcessing = async (facilityCd, masterName, data) => {
  const updateMasterName = {
    "mst_mainte_detail": "mst_mainte_category",
    "mst_mainte_category": "mst_mainte_layout",
    "mst_mainte_layout": "mst_mainte_layout_group",
  }[masterName];
  if (!updateMasterName) return;

  // 削除されるレコードのコードリストを作成する
  const deleteCodes = data.filter(
    record => record.isDisp === "0" && record.operation === 2
  ).map(record => String(record.code));
  if (!deleteCodes?.length) return;

  const response = await sendRequestFindRecordListByFacilityCd(updateMasterName, facilityCd);
  const requestData = response.data.localDataSource.data;
  let updated = false;
  const recordProcessing = {
    "mst_mainte_detail": item => {
      const detailObj = item.detail && JSON.parse(item.detail);
      // item.detail が detail_list を持つオブジェクトのJSONかを判定し、
      // detail_list を持つ場合は detail_list のJSONを処理対象とし、
      // そうでなければ item.detail 自体を処理対象とする
      const hasDetailList = !!detailObj?.detail_list;
      const detail = hasDetailList ? detailObj.detail_list : detailObj;
      if (!detail) return;

      const newItems = dataProcessing(detail, deleteCodes);
      if (newItems.length !== detail.length) {
        if (hasDetailList) {
          detailObj.detail_list = newItems;
          item.detail = JSON.stringify(detailObj);
        } else {
          item.detail = JSON.stringify(newItems);
        }
        item.operation = 2;
        updated = true;
      }
    },
    "mst_mainte_category": item => {
      const results = ["detailInfo1", "detailInfo2"].map(
        field => fieldProcessing(item, field, deleteCodes)
      );
      if (results.includes(true)) {
        updated = true;
      }
    },
    "mst_mainte_layout": item => {
      if (fieldProcessing(item, "layoutList", deleteCodes)) {
        updated = true;
      }
    },
  }[masterName];
  requestData.forEach(recordProcessing);

  // 親項目の更新が発生したら更新APIを呼び出す
  if (!updated) return;
  await sendRequestUpdateRecordListByFacilityCd(updateMasterName, facilityCd, requestData);
};
