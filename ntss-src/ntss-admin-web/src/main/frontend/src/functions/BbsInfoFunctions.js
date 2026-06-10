import moment from "moment";
import { ApiHelper } from "@/apis/AxiosHelper";

const uriSearch = "/bbsInfo/getBbsSearchResult";
const uriSearchCalendar = "/bbsInfo/getBbsSearchResultForCalendar";
const uriPat = "/bbsInfo/getPatList";

/**
 * @description 検索
 * @param {Object} searchCondition
 * {
 *  categoryFuncList: {String} カテゴリ機能,
 *  categoryKindList: {Number} カテゴリ種類,
 *  freeWord: {String} フリーワード,
 *  noticeStartDate: {String} "YYYYMMDD" 掲載開始日,
 *  noticeEndDate: {String} "YYYYMMDD" 掲載終了日,
 *  dialysisDate: {String} "YYYYMMDD" 透析日,
 *  kur: {String} クール,
 *  roomBedGroup: {String} ベッドグループ
 * }
 * @return {Array} 検索条件絞り込み掲示板登録情報
 */
export const searchBbsList = async (searchCondition, facilityCd) => {
  // 検索条件をAPI用に変換
  const param = {
    func_cd_list: searchCondition.categoryFuncList,
    kind_no_list: searchCondition.categoryKindList,
    notice_start_date: searchCondition.noticeStartDate,
    notice_end_date: searchCondition.noticeEndDate,
    dialysis_date: searchCondition.dialysisDate,
    kur_cd: searchCondition.kur,
    room_bed_group_cd: searchCondition.roomBedGroup.bedCdList,
    text: searchCondition.freeWord === null || searchCondition.freeWord === "" 
      ? null 
      : searchCondition.freeWord,
    // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
    limitFrom: searchCondition.limitFrom,
    limitTo: searchCondition.limitTo,
    userId: searchCondition.userId,
    sortColumn: searchCondition.sortColumn,
    sortKind: searchCondition.sortKind,
    targetUserId: searchCondition.targetUserId
    // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
  };

  // 検索結果の掲示板一覧
  // let searchedBbsList = [];

  // 検索条件から掲示板一覧を取得
  const { data: searchedBbsList } = await ApiHelper.post(
    `${uriSearch}/${facilityCd}`,
    param
  ).catch(() => {
    throw new Error("[BbsInfoFunctions.js]searchBbs(): 検索失敗");
  });

  // 掲示板の検索結果から必要なカラムのみ取り出す
  return searchedBbsList.map(bbs => {
    return {
      bbs_ctl_no: bbs.bbs_ctl_no,
      pat_info: JSON.parse(bbs.pat_info),
      staff_info: JSON.parse(bbs.staff_info),
      func_cd: bbs.func_cd,
      kind_no: bbs.kind_no,
      content: bbs.content,
      title: bbs.title,
      /*add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 start*/
      html_content: bbs.html_content,
      /*add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 end*/
      transition_router_path: bbs.transition_router_path,
      // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
      count: bbs.count,
      // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
      // add FNSI-No.550 リストに掲載期間が必要。ソート条件を変更したときに、元に戻すために再検索する必要があるため。 陳 start
      notice_date: bbs.notice_date,
      notice_start_date: bbs.notice_start_date,
      notice_end_date: bbs.notice_end_date,
      // add FNSI-No.550 リストに掲載期間が必要。ソート条件を変更したときに、元に戻すために再検索する必要があるため。 陳 end
      // add FNSI-437 改修内容 施設イベントの施設カレンダー背景色指定の色調整掲示板への色反映 趙立強 start
      color:bbs.color,
      font_color:bbs.font_color,
      // add FNSI-437 改修内容 施設イベントの施設カレンダー背景色指定の色調整掲示板への色反映 趙立強 end
      reg_func_class: bbs.reg_func_class,
      /* add by chamaojia 2026-02-05 [11893] キャッシュ軽減対応 --start */
      kind_name: bbs.kind_name,
      /* add by chamaojia 2026-02-05 [11893] キャッシュ軽減対応 --end */
    };
  });
};

/**
 * @description 患者情報検索
 * @param {Array} searchPatIdList: 患者ID一覧
 * @return {Array} 検索条件から患者を絞り込み
 */
export const searchPatList = async searchPatIdList => {
  let patList = [];
  // 患者IDから患者名を取得
  const responsePatList = await ApiHelper.post(uriPat, searchPatIdList).catch(
    () => {
      throw new Error("[BbsInfoFunctions.js]searchPatList(): 患者検索失敗");
    }
  );
  patList = responsePatList.data;

  // 患者の検索結果から必要なカラムのみ取り出す
  return patList.map(pat => {
    return {
      pat_id: pat.pat_id,
      pat_last_name: pat.pat_last_name,
      pat_first_name: pat.pat_first_name,
      pat_last_name_kana: pat.pat_last_name_kana,
      pat_first_name_kana: pat.pat_first_name_kana
    };
  });
};

/**
 * @description 掲示板詳細情報取得
 * @param {Number} bbsCtlNo: 掲示板番号
 * @return {Array}
 */
export const selectedBbsInfo = async bbsCtlNo => {
  // 選択した掲示板番号の詳細情報をDBから取得
  return await ApiHelper.get(`bbsInfo/getBbsInfoById/${bbsCtlNo}`).catch(() => {
    throw new Error(
      "[BbsInfoFunctions.js]selectedBbsInfo(): 掲示板詳細情報取得失敗"
    );
  });
};

/**
 * @description 新規登録
 * @param {Object} record
 * record: {
 *  facility_cd: {String} 施設コード
 *  pat_info: {String} 患者ID一覧
 *  staff_info: {String} スタッフID一覧・既読未読状態一覧
 *  func_cd: {String} 機能コード
 *  kind_no: {Number} 種別コード
 *  fn_seq_id: {Number} 管理番号(観察記録等の関係テーブル)
 *  content: {String} 内容
 *  file_info: {String} ファイル添付
 *  notice_start_date: {String} "YYYYMMDD" 掲載開始日
 *  notice_end_date: {String} "YYYYMMDD" 掲載終了日
 *  reg_staff_id: {Number} 起票者ID
 *  reg_staff_name: {String} 起票者
 *  upd_staff_id: {Number} 最終更新者ID
 *  upd_staff_name: {String} 最終更新者
 *  transition_router_path: {String} 遷移先機能パス
 *  reg_date: {String} "YYYYMMDD" 登録日
 *  up_date: {String} "YYYYMMDD" 更新日
 * }
 * @returns {Number} 掲示板番号
 */
export const createBbs = async (record, isNotification) => {
  const bbs_info = JSON.stringify(record);
  const response = await ApiHelper.post("bbsInfo/createBbs", {
    bbs_info,
    isNotification
  }).catch(() => {
    throw new Error("[BbsInfoFunctions.js]createBbs(): 掲示板登録失敗");
  });
  return response.data;
};

/**
 * @description 更新
 * @param {Object} record
 * record: {
 *  bbs_ctl_no: {Number} 掲示板番号
 *  facility_cd: {String} 施設コード
 *  pat_info: {String} 患者ID一覧
 *  staff_info: {String} スタッフID一覧・既読未読状態一覧
 *  func_cd: {String} 機能コード
 *  kind_no: {Number} 種別コード
 *  fn_seq_id: {Number} 管理番号(観察記録等の関係テーブル)
 *  content: {String} 内容
 *  file_info: {String} ファイル添付
 *  notice_start_date: {String} "YYYYMMDD" 掲載開始日
 *  notice_end_date: {String} "YYYYMMDD" 掲載終了日
 *  reg_staff_id: {Number} 起票者ID
 *  reg_staff_name: {String} 起票者
 *  upd_staff_id: {Number} 最終更新者ID
 *  upd_staff_name: {String} 最終更新者
 *  transition_router_path: {String} 遷移先機能パス
 *  reg_date: {String} "YYYYMMDD" 登録日
 *  up_date: {String} "YYYYMMDD" 更新日
 * }
 */
export const updateBbs = async (record, isNotification) => {
  const bbs_info = JSON.stringify(record);
  await ApiHelper.post(`bbsInfo/updateBbs/${record.bbs_ctl_no}`, {
    bbs_info,
    isNotification
  }).catch(() => {
    throw new Error("[BbsInfoFunctions.js]updateBbs(): 掲示板更新失敗");
  });
};

/**
 * @description 更新
 * @param {Array} recordList
 * record: {
 *  bbs_ctl_no: {Number} 掲示板番号
 *  staff_info: {String} スタッフID一覧・既読未読状態一覧
 * }
 * @param {Number} userId
 * @param {String} userName
 * @param {String} nowDate
 */
export const updateBbsList = async (recordList, userId, userName, nowDate) => {
  const bbsInfo = recordList.map(record => {
    return {
      bbs_info: JSON.stringify({
        // 掲示板番号
        bbs_ctl_no: record.bbs_ctl_no,
        // スタッフ情報
        staff_info: JSON.stringify(record.staff_info),
        // 最終更新者ID
        upd_staff_id: userId,
        // 最終更新者
        upd_staff_name: userName,
        // 更新日時
        up_date: nowDate
      })
    };
  });
  // mod 障害票一覧_NKK 修正 chen start
  // await ApiHelper.post(`bbsInfo/updateBbsList`, bbsInfo).catch(() => {
  //   throw new Error("[BbsHeader]updateBbsList(): 掲示板更新失敗");
  // });
  await ApiHelper.post(`bbsInfo/updateBbsListNoAuthorize`, bbsInfo).catch(() => {
    throw new Error("[BbsHeader]updateBbsListNoAuthorize(): 掲示板更新失敗");
  });
  // mod 障害票一覧_NKK 修正 chen end
};

/**
 * @description 削除
 * @param {Number} bbs_ctl_no
 */
export const deleteBbs = async bbs_ctl_no => {
  await ApiHelper.post(`bbsInfo/deleteBbs/${bbs_ctl_no}`).catch(() => {
    throw new Error("[BbsInfoFunctions.js]deleteBbs(): 掲示板削除失敗");
  });
};

/**
 * @description 観察記録情報から掲示板情報を作成
 * @param {Object} obsRecord
 * @param {Object} bbsRecord
 */
export const getObsToBbs = (obsRecord, bbsRecord) => {
  // 観察記録区分-SOAP
  const OBSERVE_RECORD_CLASS_SOAP = 1;
  const OBSERVE_RECORD_CLASS_FDAR = 2;
  const kindNo = obsRecord.kindInfo.kind_class;
  if (
    kindNo === OBSERVE_RECORD_CLASS_SOAP ||
    kindNo === OBSERVE_RECORD_CLASS_FDAR
  ) {
    // SOAP区切り文字
    const SOAP_DELIMITER = "\u001C\u001B\u001D";
    bbsRecord.content = [
      obsRecord.obsRecInfo.detail1,
      obsRecord.obsRecInfo.detail2,
      obsRecord.obsRecInfo.detail3,
      obsRecord.obsRecInfo.detail4
    ].join(SOAP_DELIMITER);
  } else {
    bbsRecord.content = obsRecord.obsRecInfo.detail1;
  }
  return bbsRecord;
};

/**
 * @description 観察記録から掲示板新規登録
 * @param {Object} obsRecord
 */
export const createObsToBbs = obsRecord => {
  obsRecord.kindInfo = JSON.parse(obsRecord.kindInfo);
  obsRecord.obsRecInfo = JSON.parse(obsRecord.obsRecInfo);
  obsRecord.regStaffInfo = JSON.parse(obsRecord.regStaffInfo);

  const bbsInfo = {
    func_cd: "016",
    kind_no: obsRecord.kindInfo.kind_no,
    upd_staff_id: obsRecord.regStaffInfo.reg_staff_cd,
    upd_staff_name: obsRecord.regStaffInfo.reg_staff_name,
    up_date: moment(obsRecord.recDate).format(),
    facility_cd: obsRecord.facilityCd,
    pat_info: JSON.stringify({
      target: "1",
      detail: [obsRecord.patId]
    }),
    staff_info: JSON.stringify({
      target: "1",
      detail: [
        {
          staff_cd: obsRecord.regStaffInfo.reg_staff_cd,
          read_state: "0"
        }
      ]
    }),
    file_info: JSON.stringify([]),
    notice_start_date: moment().format(),
    notice_end_date: moment().format(),
    reg_staff_id: obsRecord.regStaffInfo.reg_staff_cd,
    reg_staff_name: obsRecord.regStaffInfo.reg_staff_name,
    transition_router_path: null,
    reg_date: moment(obsRecord.recDate).format()
  };

  const bbsRecord = getObsToBbs(obsRecord, bbsInfo);

  // 掲示板新規登録
  createBbs(bbsRecord);
};

/**
 * @description 観察記録から掲示板新規登録
 * @param {Object} obsRecord
 */
export const updateObsToBbs = async obsRecord => {
  obsRecord.kindInfo = JSON.parse(obsRecord.kindInfo);
  obsRecord.obsRecInfo = JSON.parse(obsRecord.obsRecInfo);
  obsRecord.regStaffInfo = JSON.parse(obsRecord.regStaffInfo);

  const responseBbsInfo = await selectedBbsInfo(obsRecord.bbsCtlNo);
  const bbsInfo = responseBbsInfo.data;

  // 更新
  bbsInfo.kind_no = obsRecord.kindInfo.kind_no;
  // 毎回管理番号を設定し直す※観察記録の更新は新規登録扱いのため、観察記録主キーを設定
  bbsInfo.upd_staff_id = obsRecord.regStaffInfo.reg_staff_cd;
  bbsInfo.upd_staff_name = obsRecord.regStaffInfo.reg_staff_name;
  bbsInfo.up_date = moment(obsRecord.recDate).format();

  const bbsRecord = getObsToBbs(obsRecord, bbsInfo);

  // 掲示板新規登録
  // mod 8337 【デグレ】掲示板リンクを含んだ患者イベントの編集→保存ができない 関 start
  // updateBbs(bbsRecord);
  updateBbs(bbsRecord, false);
  // mod 8337 【デグレ】掲示板リンクを含んだ患者イベントの編集→保存ができない 関  end
};


/**
 * @description 検索
 * @param {Object} searchCondition
 * {
 *  dialysisDate: {String} "YYYYMMDD" 透析日,
 *  kur: {String} クール,
 *  roomBedGroup: {String} ベッドグループ
 *  noticeStartDate: {String} "YYYYMMDD" 掲載開始日,
 *  noticeEndDate: {String} "YYYYMMDD" 掲載終了日,
 *  freeWord: {String} フリーワード,
 * }
 * @return {Array} 検索条件絞り込み掲示板登録情報
 */
export const searchBbsCalendarList = async (searchCondition, facilityCd) => {
  // 検索条件をAPI用に変換
  const param = {
    notice_start_date: searchCondition.noticeStartDate,
    notice_end_date: searchCondition.noticeEndDate,
    dialysis_date: searchCondition.dialysisDate,
    kur_cd: searchCondition.kur,
    room_bed_group_cd: searchCondition.roomBedGroup.bedCdList,
    text: searchCondition.freeWord
  };

  // 検索条件から掲示板一覧を取得
  const { data: searchedBbsCalendarList } = await ApiHelper.post(
    `${uriSearchCalendar}/${facilityCd}`,
    param
  ).catch(() => {
    throw new Error("[BbsInfoFunctions.js]searchBbsCalendar(): 検索失敗");
  });
  return searchedBbsCalendarList;
};
//  add 6216 施設イベントの表示条件の不正 zhao start
export const searchBbsCalendarListEvent = async (searchCondition, facilityCd,facCalLayoutCd) => {
  // 検索条件をAPI用に変換
  const param = {
    notice_start_date: searchCondition.noticeStartDate,
    notice_end_date: searchCondition.noticeEndDate,
    dialysis_date: searchCondition.dialysisDate,
    kur_cd: searchCondition.kur,
    room_bed_group_cd: searchCondition.roomBedGroup.bedCdList,
    text: searchCondition.freeWord
  };

  // 検索条件から掲示板一覧を取得
  const { data: searchedBbsCalendarList } = await ApiHelper.post(
    `${uriSearchCalendar}/${facilityCd}/${facCalLayoutCd}`,
    param
  ).catch(() => {
    throw new Error("[BbsInfoFunctions.js]searchBbsCalendar(): 検索失敗");
  });
  return searchedBbsCalendarList;
};
//  add 6216 施設イベントの表示条件の不正 zhao end
export const updateBbsFileInfo = async record => {
  const bbs_info = JSON.stringify(record);
  await ApiHelper.post(`bbsInfo/updateBbsFileInfo/${record.bbs_ctl_no}`, {
    bbs_info
  }).catch(() => {
    throw new Error("[BbsInfoFunctions.js]updateBbsFileInfo(): 掲示板更新失敗");
  });
};

