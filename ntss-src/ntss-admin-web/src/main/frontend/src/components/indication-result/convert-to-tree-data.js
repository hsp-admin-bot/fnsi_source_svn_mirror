/**
 * 予実データ配列をツリー表示用データに変換する.
 */
import { CODES } from "@/constants/IndicationResult";

/**
 * 指定されたコードからカテゴリを取得する.
 * @param {*} category カテゴリコード
 */
function getCategory(category) {
  return Object.values(CODES.CATEGORY).find(e => e.cd === category)
}

/**
 * 指定された区分から予実を取得する.
 * @param {*} type 予実
 */
function getInsRstType(type) {
  return Object.values(CODES.IND_RESULT_TYPE).find(e => e.cd === type)
}

/**
 * 予実データ配列から「カテゴリ」（重複なし、昇順）を取得する.
 * @param {*} list 予実データ配列
 */
function extractCategories(list) {
  return Array
    .from(new Set(list.map(e => e.category)))
    .map(e => getCategory(e))
    .sort((a, b) => (a.cd < b.cd ? -1 : 1));
}

/**
 * 治療日の配列（重複なし、降順）を取得する.
 * @param {*} list 予実データ配列
 */
function extractTreatDate(list) {
  const treatDates =  Array.from(new Set(list.map(e => e.treatDate)));
  return treatDates.length <= 1 ? treatDates : treatDates.sort((a, b) => (a < b) ? 1 : -1);
}

/**
 * 予実データ配列から「予実」（重複なし、昇順）を取得する.
 * @param {*} list 予実データ配列
 */
function extractIndRstType(list) {
  return Array
    .from(new Set(list.map(e => e.indRstType)))
    .map(e => getInsRstType(e))
    .sort((a, b) => (a.cd < b.cd ? -1 : 1));
}

/**
 * 予実データ配列を以下の通り並び替える.
 * ・治療日（降順）
 * ・クール開始時刻（降順）
 * ・治療方法コード（昇順）
 * ・予実（昇順）パターン1,2,4,5のみ
 * ・カテゴリ（昇順）パターン4のみ
 * @param {*} list 予実データ配列
 */
function sortModel(list, pattern) {
  return list.length <= 1 ? list : list
    .sort((a, b) => {
      // 治療日（降順）
      if (a.treatmentDate < b.treatmentDate) {
        return 1;
      }
      if (a.treatmentDate > b.treatmentDate) {
        return -1;
      }

      // クール開始時刻（降順）
      if (a.kurStartTime < b.kurStartTime) {
        return 1;
      }
      if (a.kurStartTime > b.kurStartTime) {
        return -1;
      }

      // 治療方法コード（昇順）
      if (a.treatmentCd < b.treatmentCd) {
        return -1;
      }
      if (a.treatmentCd > b.treatmentCd) {
        return 1;
      }

      // 予実（昇順）パターン1,2,4,5のみ
      if (a.indRstType < b.indRstType && (pattern === 1 || pattern === 2 || pattern === 4 || pattern === 5)) {
        return -1;
      }
      if (a.indRstType > b.indRstType && (pattern === 1 || pattern === 2 || pattern === 4 || pattern === 5)) {
        return 1;
      }

      // カテゴリ（昇順）パターン4のみ
      if (a.category < b.category && pattern === 4) {
        return -1;
      }
      if (a.category > b.category && pattern === 4) {
        return -1;
      }
      return 0;
    });
}

/**
 * パターン１（カテゴリ、予実・日付）データを生成する.
 * @param {*} list 予実データ配列
 */
export function convertToTreeDataPattern1(list) {
  // mod FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
  // return extractCategories(list).map(c => {
  //   return {
  //     title: c.text,
  //     children: sortModel(list.filter(e => e.category === c.cd), 1)
  //   }
  // });
  let treeData = [];

  // 患者経過総合ビューアデータ取得
  const patViewList = list.filter(element => element.ordNo);
  // 患者経過総合ビューアデータがあるの場合
  if (patViewList) {
    let ysTreeData = [];
    ysTreeData = extractCategories(patViewList).map(eo => {
      return {
        title: eo.text,
        children: sortModel(patViewList.filter(et => et.category === eo.cd), 1)
      }
    });
    // ツリーデータ作成
    Array.prototype.push.apply(treeData, ysTreeData);
  }

  // 患者イベント画面データ取得
  const patList = list.filter(element => element.type == 'pat_event');
  // 患者イベント画面データがあるの場合
  if (patList) {
    let patTreeData = [];
    patTreeData = Array.from(new Set(patList.map(eo => eo.type))).map(et => {
      return {
        title: '患者イベント',
        children: patList.filter(es => es.type === et)
      }
    });
    // ツリーデータ作成
    Array.prototype.push.apply(treeData, patTreeData);
  }

  // 検査予定画面データ取得
  const scheduleList = list.filter(element => element.type == 'in_schedule');
  // 検査結果画面データ取得
  const resultList = list.filter(element => element.type == 'in_result');
  // データ結合
  Array.prototype.push.apply(scheduleList, resultList);
  // 検査予定画面/検査結果画面データがあるの場合
  if (scheduleList) {
    // 時間の降順
    scheduleList.sort((frontValue, behindValue) =>
      behindValue.treatDate.replaceAll('/', '') - frontValue.treatDate.replaceAll('/', ''));
    let schTreeData = [];

    schTreeData = Array.from(new Set(scheduleList.map(eo => eo.title = '検査'))).map(et => {
      return {
        title: et,
        children: scheduleList
      }
    });
    // ツリーデータ作成
    Array.prototype.push.apply(treeData, schTreeData);
  }

  // 一般撮影検査予定画面データ取得
  const photoScheduleList = list.filter(element => element.type == 'in_photo');
  // 一般撮影検査予定画面データがあるの場合
  if (photoScheduleList) {
    let photoTreeData = [];

    photoTreeData = Array.from(new Set(photoScheduleList.map(eo => eo.type))).map(et => {
      return {
        title: '一般撮影予定',
        children: photoScheduleList.filter(es => es.type === et)
      }
    });
    // ツリーデータ作成
    Array.prototype.push.apply(treeData, photoTreeData);
  }

  // 処方画面データ取得
  const prescriptionList = list.filter(element => element.type == 'prescription');
  // 処方画面データがあるの場合
  if (prescriptionList) {
    let prescriptionTreeData = [];

    prescriptionTreeData = Array.from(new Set(prescriptionList.map(eo => eo.type))).map(et => {
      return {
        title: '処方',
        children: prescriptionList.filter(es => es.type === et)
      }
    });
    // ツリーデータ作成
    Array.prototype.push.apply(treeData, prescriptionTreeData);
  }

  // ツリーデータ戻る
  return treeData;
  // mod FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end
}

/**
 * パターン２（カテゴリ、日付、予実）データを生成する.
 * @param {*} list 予実データ配列
 */
export function convertToTreeDataPattern2(list) {
  // mod FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
  // return extractCategories(list).map(c => {
  //   return {
  //     title: c.text,
  //     children: extractTreatDate(list.filter(e => e.category === c.cd))
  //       .map(d => {
  //         return {
  //           title: d,
  //           children: sortModel(list.filter(e => e.category === c.cd && e.treatDate === d), 2)
  //         }
  //       })
  //     }
  //   }
  // )
  let treeData = [];

  // 患者経過総合ビューア画面データ取得
  const patViewList = list.filter(element => element.ordNo);
  // 患者経過総合ビューアデータがあるの場合
  if (patViewList) {
    let ysTreeList = [];

    ysTreeList = extractCategories(patViewList).map(c => {
      return {
        title: c.text,
        children: extractTreatDate(patViewList.filter(e => e.category === c.cd))
          .map(d => {
            return {
              title: d,
              children: sortModel(patViewList.filter(e => e.category === c.cd && e.treatDate === d), 2)
            }
          })
        }
      }
    )
    // ツリーデータ作成
    Array.prototype.push.apply(treeData, ysTreeList);
  }

  // 患者イベント画面データ取得
  const patList = list.filter(element => element.type == 'pat_event');
  // 患者イベントデータがあるの場合
  if (patList) {
    let patTreeList = [];

    patTreeList = Array.from(new Set(patList.map(eo => eo.title = '患者イベント'))).map(et => {
      return {
        title: et,
        children: patList.map(es => {
          return {
            title: es.treatDate,
            children: [es]
          }
        })
      }
    });
    // ツリーデータ作成
    Array.prototype.push.apply(treeData, patTreeList);
  }

  // 検査予定画面データ取得
  const scheduleList = list.filter(element => element.type == 'in_schedule');
  // 検査結果画面データ取得
  const resultList = list.filter(element => element.type == 'in_result');
  // データ結合
  Array.prototype.push.apply(scheduleList, resultList);
  // 検査予定画面/検査結果画面データがあるの場合
  if (scheduleList) {
    let schTreeData = [];

    schTreeData = Array.from(new Set(scheduleList.map(eo => eo.title = '検査'))).map(et => {
      return {
        title: et,
        children: scheduleList.map(es => {
          return {
            title: es.treatDate,
            children: [es]
          }
        })
      }
    });
    // ツリーデータ作成
    Array.prototype.push.apply(treeData, schTreeData);
  }

  // 一般撮影検査予定画面データ取得
  const photoScheduleList = list.filter(element => element.type == 'in_photo');
  // 一般撮影検査予定データがあるの場合
  if (photoScheduleList) {
    let photoTreeData = [];

    photoTreeData = Array.from(new Set(photoScheduleList.map(eo => eo.title = '一般撮影予定'))).map(et => {
      return {
        title: et,
        children: photoScheduleList.map(es => {
          return {
            title: es.treatDate,
            children: [es]
          }
        })
      }
    });
    // ツリーデータ作成
    Array.prototype.push.apply(treeData, photoTreeData);
  }

  // 処方画面データ取得
  const prescriptionList = list.filter(element => element.type == 'prescription');
  // 処方画面データがあるの場合
  if (prescriptionList) {
    let prescriptionTreeData = [];

    prescriptionTreeData = Array.from(new Set(prescriptionList.map(eo => eo.title = '処方'))).map(et => {
      return {
        title: et,
        children: prescriptionList.map(es => {
          return {
            title: es.treatDate,
            children: [es]
          }
        })
      }
    });
    // ツリーデータ作成
    Array.prototype.push.apply(treeData, prescriptionTreeData);
  }

  // ツリーデータ戻る
  return treeData;
  // mod FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end
}

/**
 * パターン３（カテゴリ、予実、日付）データを生成する.
 * @param {*} list 予実データ配列
 */
export function convertToTreeDataPattern3(list) {
  // mod FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
  // return extractCategories(list).map(c => {
  //   return {
  //     title: c.text,
  //     children: extractIndRstType(list.filter(e => e.category === c.cd))
  //       .map(t => {
  //         return {
  //           title: t.text,
  //           children: sortModel(list.filter(e => e.category === c.cd && e.indRstType === t.cd), 3)
  //         }
  //       })
  //     }
  //   }
  // )
  let treeData = [];

  // 患者経過総合ビューア画面データ取得
  const patViewList = list.filter(element => element.ordNo);
  // 患者経過総合ビューアデータがあるの場合
  if (patViewList) {
    let ysTreeList = [];

    ysTreeList = extractCategories(patViewList).map(c => {
      return {
        title: c.text,
        children: extractIndRstType(patViewList.filter(e => e.category === c.cd))
          .map(t => {
            return {
              title: t.text,
              children: sortModel(patViewList.filter(e => e.category === c.cd && e.indRstType === t.cd), 3)
            }
          })
        }
      }
    )
    // ツリーデータ作成
    Array.prototype.push.apply(treeData, ysTreeList);
  }

  // 患者イベント画面データ取得
  const patList = list.filter(element => element.type == 'pat_event');
  // 患者イベントデータがあるの場合
  if (patList) {
    let patTreeList = [];

    patTreeList = Array.from(new Set(patList.map(eo => eo.title = '患者イベント'))).map(et => {
      return {
        title: et,
        children: Array.from(new Set(patList.map(es => es.subTitle = '【イベント】'))).map(ef => {
            return {
              title: ef,
              children: patList
            }
          })
        }
      }
    )
    // ツリーデータ作成
    Array.prototype.push.apply(treeData, patTreeList);
  }

  // 検査予定画面データ取得
  const scheduleList = list.filter(element => element.type == 'in_schedule');
  // 検査結果画面データ取得
  const resultList = list.filter(element => element.type == 'in_result');
  // 一般撮影検査予定画面データ取得
  const photoScheduleList = list.filter(element => element.type == 'in_photo');
  // データ結合
  Array.prototype.push.apply(scheduleList, resultList);
  Array.prototype.push.apply(scheduleList, photoScheduleList);

  // 検査予定/検査結果/一般撮影検査予定画面データがあるの場合
  if (scheduleList) {
    let schTreeData = [];

    schTreeData = Array.from(new Set(scheduleList.map(eo => eo.title = '検査'))).map(et => {
      return {
        title: et,
        children: Array.from(new Set(scheduleList.map(es => {
          if (es.type == 'in_schedule') return es.subTitle = '【予定】';
          if (es.type == 'in_result') return es.subTitle = '【結果】';
          if (es.type == 'in_photo') return es.subTitle = '【一般撮影】';
        }))).map(ef => {
          return {
            title: ef,
            children: scheduleList.filter(item => {
              if (ef == '【予定】') return item.type == 'in_schedule';
              if (ef == '【結果】') return item.type == 'in_result';
              if (ef == '【一般撮影】') return item.type == 'in_photo';
            })
          }})
        }
      }
    )
    // ツリーデータ作成
    Array.prototype.push.apply(treeData, schTreeData);
  }

  // 処方画面データ取得
  const prescriptionList = list.filter(element => element.type == 'prescription');
  // 処方データがあるの場合
  if (prescriptionList) {
    // redmine6072 add yuqizheng start
    let prescriptionTreeData = [];
    let allTreeList = [];
    // 患者経過総合ビューア画面データ
    Array.prototype.push.apply(allTreeList, sortModel(list.filter(element => element.ordNo), 3));
    // 検査結果、検査予定、一般撮影検査予定、処方画面データ
    Array.prototype.push.apply(allTreeList, list.filter(element => !element.ordNo));
    // 患者経過総合ビューア画面
    allTreeList.forEach(e => {
      if (e.ordNo) e.typeName = '血液浄化';
      if (e.type == 'pat_event') {e.typeName = '患者イベント'; e.indRstTypeName = '【イベント】'}
      if (e.type == 'in_schedule') {e.typeName = '検査予定'; e.indRstTypeName = '【予定】'}
      if (e.type == 'in_result') {e.typeName = '検査結果'; e.indRstTypeName = '【結果】'}
      if (e.type == 'in_photo') {e.typeName = '一般撮影予定'; e.indRstTypeName = '【予定】'}
      if (e.type == 'prescription') {e.typeName = '処方'; e.indRstTypeName = e.issueState}
    });
    const treeList = Array.from(new Set(prescriptionList.map(ep => ep.title = '処方'))).map(eo => {
      return {
        title: eo,
        children: Array.from(new Set(allTreeList.map(et => et.indRstTypeName)))
          .map(es => {
            return {
              title: es,
              children: allTreeList.filter(ef => ef.typeName == eo && ef.indRstTypeName == es)
            }
          })
      }
    });
    // redmine6072 add yuqizheng end
    // prescriptionTreeData = Array.from(new Set(prescriptionList.map(eo => eo.title = '処方'))).map(et => {
    //   return {
    //     title: et,
    //     children: Array.from(new Set(prescriptionList.map(es => es.issueState))).map(ef => {
    //         return {
    //           title: ef,
    //           children: prescriptionList
    //         }
    //       })
    //     }
    //   }
    // )
    // ツリーデータ作成
    Array.prototype.push.apply(treeData, treeList);
  }

  // ツリーデータ戻る
  return treeData;
  // mod FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end
}

/**
 * パターン４（日付、予実・カテゴリ）データを生成する.
 * @param {*} list 予実データ配列
 */
export function convertToTreeDataPattern4(list) {
  // mod FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
  // return extractTreatDate(list).map(d => {
  //   return {
  //     title: d,
  //     children: sortModel(list.filter(e => e.treatDate === d), 4)
  //   }
  // });
  let treeData = [];
  let allTreeList = [];

  // 患者経過総合ビューア画面データ
  Array.prototype.push.apply(allTreeList, sortModel(list.filter(element => element.ordNo), 4));
  // 患者イベント、検査結果、検査予定、一般撮影検査予定、処方画面データ
  Array.prototype.push.apply(allTreeList, list.filter(element => !element.ordNo));

  const treeList = extractTreatDate(allTreeList).map(eo => {
    return {
      title: eo,
      children: allTreeList.filter(e => e.treatDate == eo)
      }
    }
  )
  // ツリーデータ作成
  Array.prototype.push.apply(treeData, treeList);

  // ツリーデータ戻る
  return treeData;
  // mod FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end
}

/**
 * パターン５（日付、カテゴリ、予実）データを生成する.
 * @param {*} list 予実データ配列
 */
export function convertToTreeDataPattern5(list) {
  // mod FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
  // return extractTreatDate(list).map(d => {
  //   return {
  //     title: d,
  //     children: extractCategories(list.filter(e => e.treatDate === d))
  //     .map(c => {
  //       return {
  //         title: c.text,
  //         children: sortModel(list.filter(e => e.treatDate === d && e.category === c.cd), 5)
  //       }
  //     })
  //   }
  // });
  let treeData = [];
  let allTreeList = [];

  // 患者経過総合ビューア画面データ
  Array.prototype.push.apply(allTreeList, sortModel(list.filter(element => element.ordNo), 4));
  // 検査結果、検査予定、一般撮影検査予定、処方画面データ
  Array.prototype.push.apply(allTreeList, list.filter(element => !element.ordNo));

  allTreeList.forEach(e => {
    if (e.ordNo) e.typeName = '血液浄化';
    if (e.type == 'pat_event') e.typeName = 'イベント';
    if (e.type == 'in_schedule') e.typeName = '検査予定';
    if (e.type == 'in_result') e.typeName = '検査結果';
    if (e.type == 'in_photo') e.typeName = '一般撮影予定';
    if (e.type == 'prescription') e.typeName = '処方';
  });

  const treeList = extractTreatDate(allTreeList).map(eo => {
    return {
      title: eo,
      children: Array.from(new Set(allTreeList.map(et => et.typeName)))
      .map(es => {
        return {
          title: es,
          children: allTreeList.filter(ef => ef.treatDate == eo && ef.typeName == es)
        }
      })
    }
  });
  // ツリーデータ作成
  Array.prototype.push.apply(treeData, treeList);

  // ツリーデータ戻る
  return treeData;
  // mod FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end
}

/**
 * パターン６（日付、予実、カテゴリ）データを生成する.
 * @param {*} list 予実データ配列
 */
export function convertToTreeDataPattern6(list) {
  // mod FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
  // return extractTreatDate(list).map(d => {
  //   return {
  //     title: d,
  //     children: extractIndRstType(list.filter(e => e.treatDate === d))
  //     .map(t => {
  //       return {
  //         title: t.text,
  //         children: sortModel(list.filter(e => e.treatDate === d && e.indRstType === t.cd), 6)
  //       }
  //     })
  //   }
  // });

  let treeData = [];
  let allTreeList = [];

  // 患者経過総合ビューア画面データ
  Array.prototype.push.apply(allTreeList, sortModel(list.filter(element => element.ordNo), 4));
  // 検査結果、検査予定、一般撮影検査予定、処方画面データ
  Array.prototype.push.apply(allTreeList, list.filter(element => !element.ordNo));

  // 患者経過総合ビューア画面
  allTreeList.forEach(e => {
    if (e.ordNo) e.typeName = '血液浄化';
    if (e.type == 'pat_event') {e.typeName = '患者イベント'; e.indRstTypeName = '【イベント】'}
    if (e.type == 'in_schedule') {e.typeName = '検査予定'; e.indRstTypeName = '【予定】'}
    if (e.type == 'in_result') {e.typeName = '検査結果'; e.indRstTypeName = '【結果】'}
    if (e.type == 'in_photo') {e.typeName = '一般撮影予定'; e.indRstTypeName = '【予定】'}
    if (e.type == 'prescription') {e.typeName = '処方'; e.indRstTypeName = e.issueState}
  });

  const treeList = extractTreatDate(allTreeList).map(eo => {
    return {
      title: eo,
      children: Array.from(new Set(allTreeList.map(et => et.indRstTypeName)))
      .map(es => {
        return {
          title: es,
          children: allTreeList.filter(ef => ef.treatDate == eo && ef.indRstTypeName == es)
        }
      })
    }
  });
  // ツリーデータ作成
  Array.prototype.push.apply(treeData, treeList);

  // ツリーデータ戻る
  return treeData;
  // mod FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end
}
