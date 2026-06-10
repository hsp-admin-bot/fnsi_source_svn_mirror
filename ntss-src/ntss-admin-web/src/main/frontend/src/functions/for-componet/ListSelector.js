/**
 * @description リスト選択用データ作成
 * @summary データをリスト選択コンポーネントで扱える形にする
 * @param {Array} data 対象のデータオブジェクト配列
 * @param {String} cdString コード名のキー名
 * @param {String} nameString 名称のキー名
 * @param {String} class1String 分類1のキー名(任意)
 * @param {String} class2String 分類2のキー名(任意)
 * @param {String} cdTypeString 重複コード識別値(任意)
 * @returns {Array} [{ cd, name, class1, class2 }, ...]
 * @example
 *   const mstRecords = [{ mst_cd: 1, mst_name: 'hoge', foo_class: '1', bar_division: '1' }, ...]
 *   const itemList = createItemListData(mstRecords, 'mst_cd', 'mst_name', 'foo_class', 'bar_division');
 *   // itemList -> [{ cd: 1, name: 'hoge', class1: '1', class2: '1' }, ...]
 */
export const createItemListData = (
  data,
  cdString,
  nameString,
  class1String = "",
  class2String = "",
  cdTypeString = null,
  name2String = ""
) => {
  return data.map(obj => ({
    cd: obj[cdString],
    // mod 9485 患者名の姓または名に連携からnullが登録された場合に、各画面の患者名表示に「null」と表示してしまう。 張玲 start
    // name: name2String === "" ? obj[nameString] : obj[name2String] + " " + obj[nameString],
    name: name2String === "" ? obj[nameString] : (obj[name2String] ? obj[name2String] :"") + " " + (obj[nameString] ? obj[nameString]:""),
    // mod 9485 患者名の姓または名に連携からnullが登録された場合に、各画面の患者名表示に「null」と表示してしまう。 張玲 end
    class1: class1String === "" ? "" : obj[class1String],
    class2: class2String === "" ? "" : obj[class2String],
    cdType: cdTypeString
  }));
};

/*add FNSI-改修内容掲示板外结No.10 任 start*/
export const createItemListDataBbs = (
  data,
  cdString,
  hostCdString,
  nameString,
  cdTypeString,
  isSame,
// add FNSI-入外区分が入院の場合、患者名は紫色にする dou start
  isInClass,
// add FNSI-入外区分が入院の場合、患者名は紫色にする dou end
  jobName,
  class1String = "",
  class2String = "",
  name2String = "",
  jobCd = ""
) => {
  return data.map(obj => ({
    cd: obj[cdString],
    hostCd: hostCdString === "" ? "" : obj[hostCdString],
    name: name2String === "" ? obj[nameString] : obj[name2String] + " " + obj[nameString],
    class1: class1String === "" ? "" : obj[class1String],
    class2: class2String === "" ? "" : obj[class2String],
    isSame: isSame === "" ? "" : obj[isSame],
// add FNSI-入外区分が入院の場合、患者名は紫色にする dou start
    isInClass: isInClass === "" ? "" : obj[isInClass],
// add FNSI-入外区分が入院の場合、患者名は紫色にする dou end
    cdType: cdTypeString,
    jobName: jobName === "" ? "" : obj[jobName],
    jobCd: jobCd === "" ? "" : obj[jobCd]
  }));
};
/*add FNSI-改修内容掲示板外结No.10 任 end*/
/**
 * @description リスト選択区分用データ作成
 * @summary データをリスト選択コンポーネントの区分で扱える形にする
 * @param {Array} data 対象のデータオブジェクト配列
 * @param {String} classCdString 区分コード名のキー名
 * @param {String} classNameString 区分名称のキー名
 * @param {String} label 区分プルダウンメニューのラベル
 * @returns {Object} { label, classes: [{ cd, name }, ...] }
 * @example
 *   const classRecords = [{ class_cd: 1, class_name: '区分1' }, ...]
 *   const classData = createClassData(classRecords, 'class_cd', 'class_name', '区分フィルタ1');
 *   // classData -> { label: '区分フィルタ1', classes: [{ cd: 1, name: '区分1' }, ...] }
 */
export const createClassData = (
  data,
  classCdString,
  classNameString,
  label
) => {
  const classes = data.map(obj => ({
    cd: obj[classCdString],
    name: obj[classNameString]
  }));
  return { label, classes };
};

/**
 * @description 選択項目の先頭に「すべて」、末尾に「未分類」を追加する.
 * @param {Array} selectItemArr 選択項目.
 * @param {Boolean} withoutAll (true: EquipmentComponent.vueと他の医療材料分類プルダウン生成の差を吸収する , false(デフォルト): 「すべて」を追加する).
 */ 
 export const shapeSelectionItem = (selectItemArr, withoutAll = false) => {
  if (withoutAll) {
  	selectItemArr.push({ className: "未分類", classCd: -1 });
  } else {
    selectItemArr.unshift({ text: "すべて", value: 0 });
  	selectItemArr.push({ text: "未分類", value: -1 });
  }
 };
