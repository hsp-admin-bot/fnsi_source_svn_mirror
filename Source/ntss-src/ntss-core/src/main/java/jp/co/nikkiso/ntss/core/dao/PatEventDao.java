package jp.co.nikkiso.ntss.core.dao;

import java.sql.Timestamp;
import java.util.List;

import org.apache.commons.lang3.tuple.Pair;
import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.PatEventDetailedConditions;
import jp.co.nikkiso.ntss.core.dto.indSchedule.OrdNoAndConnectedTableKeyData;
import jp.co.nikkiso.ntss.core.entity.PatEvent;
import jp.co.nikkiso.ntss.core.entity.PatEventShare;
import jp.co.nikkiso.ntss.core.entity.custom.NumberOfUserTypeByOrdNo;
import jp.co.nikkiso.ntss.core.entity.custom.PatEventCoopInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatEventData;
import jp.co.nikkiso.ntss.core.entity.custom.PatEventVAFile;
import jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar.NumberOfPat;


@ConfigAutowireable
@Dao
public interface PatEventDao {
  @Select
  List<PatEvent> selectAll(SelectOptions options);

  @Select
  List<PatEvent> selectByCd(Long patEventCd);

  // add FNSI-観察記録を追加 楊 start
  /**
   * 指定ID、日付の観察記録を取得する
   * @param patId 患者ID
   * @param dialysis_date_from 開始日付
   * @param dialysis_date_to 終了日付
   * @return 観察記録イベントリスト
   */
  @Select
  List<PatEvent> selectByPatIdDate(long patId, String dialysis_date_from, String dialysis_date_to);
  // add FNSI-観察記録を追加 楊 end

  // add FNSI-患者イベント（仮）を追加 李 start
  /**
   * 指定ID、日付の患者イベント（仮）を取得する
   * @param patId 患者ID
   * @param dialysis_date_from 開始日付
   * @param dialysis_date_to 終了日付
   * @return 患者イベント（仮）イベントリスト
   */
  @Select
  List<PatEvent> selectByPatientIdDate(long patId, String dialysis_date_from, String dialysis_date_to, String facilityCd);
  // add FNSI-患者イベント（仮）を追加 李 end

  // add 426 姜 start
  /**
   * 指定ID、日付の患者イベント（仮）を取得する
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @return 患者イベント（仮）イベントリスト
   */
//  @Select
//  List<PatEvent> selectDateByCd(long patId, String facilityCd);
  // add 426 姜 end

  @Select
  List<PatEvent> selectByOrdNo(Long ordNo,String facilityCd);

  /**
   * 観察記録リストの件数を取得
   * @param ordNo オーダ番号
   * @param facilityCd 施設コード
   * @param key0
   * @return カルテ記載連携用のordNo,連携設定と紐づく患者イベントリスト
   */
  @Select
  List<PatEvent> selectByOrdNoForKarteOrd(Long ordNo, String facilityCd, String key0);

  /**
   * 観察記録リストの件数を取得
   * @param patId
   * @param startEventDate
   * @param endEventDate
   * @param categoryDataList
   * @param regStaffCd
   * @param upStaffCd
   * @return 観察記録リストの件数
   */
  @Select
  int countObsRecByCondition(Long patId, String startEventDate, String endEventDate, List<Pair<Long, Long>> categoryDataList, String regStaffCd, String upStaffCd);

  /**
   * 観察記録のリストを取得
   * @param patId
   * @param startEventDate
   * @param endEventDate
   * @param categoryDataList
   * @param regStaffCd
   * @param upStaffCd
   * @param offset ※追加読込で使用
   * @return 観察記録リスト MAX100件取得
   */
  @Select
  List<PatEventShare> selectObsRecByCondition(Long patId, String startEventDate, String endEventDate, List<Pair<Long, Long>> categoryDataList, String regStaffCd, String upStaffCd, Integer offset);

  @Select
  List<PatEventShare> selectByPatIdNewestShare(Long patId, Timestamp startEventDate, Timestamp endEventDate, String facilityCd, Long... patEventCdList);
  @Select
  List<PatEvent> selectByPatIdNewest(Long patId, Timestamp startEventDate, Timestamp endEventDate);

  /**
   * 指定IDの最新患者イベントリストを取得する
   * @param params 患者ID,開始日付,終了日付
   * @return 患者イベントリスト
   */
  @Select
  List<PatEventData> selectByPatIdNewestCustom(Long patId, String startEventDate, String endEventDate);

  @Select
  PatEvent selectInfoPatEvent(Long pat_event_cd);

  /**
   * シーケンスよりイベントコードを取得する
   * @return イベントコード
   */
  @Select
  Long selectNextSeqPatEventCd();

  /**
   * 指定患者ID、使用区分で患者イベントリストを取得する
   * @param patId 患者ID
   * @param useType 使用区分
   * @return 患者イベントリスト
   */
  @Select
  List<PatEvent> selectByPatIdUseType(Long patId, Short useType);

  /**
   * 指定患者ID,VA名の画像ファイルリストを取得する
   * @param patId 患者ID
   * @param vaName VA名称
   * @param limitCount 取得件数
   * @return 画像ファイルリスト
   */
  @Select
  List<PatEventVAFile> selectVAFileName( Long patId, String vaName, Integer limitCount);

  /**
   * 指定オーダー番号、利用種別の件数を取得する
   * @param ordNoList オーダー番号
   * @param useType 利用種別
   * @return 件数
   */
  @Select
  List<NumberOfUserTypeByOrdNo> selectCountByOrdNoUseType(List<Long> ordNoList, Short useType, String facilityCd );


  @Insert(sqlFile = true)
  int insert(PatEvent patEvent);

  @Delete
  int delete(PatEvent patEvent);

  @Update
  int update(PatEvent patEvent);

  // add FNSI start -- Sanjingye Sun 20201217
  @Update(excludeNull = true)
  int updateSelected(PatEvent patEvent);
  // add FNSI end -- Sanjingye Sun 20201217

  /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
  @Update(sqlFile = true)
  int updateLetterInfo(String letter_info,long pat_event_cd);
  /*add FNSI-改修内容転入転出の患者情報連動 任 end*/
  /**
   * 指定した患者イベントの最新フラグを更新する
   * @param patEvent patEventのEntity
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateIsNewest(PatEvent patEvent);

  /* modify by chamaojia 2023-11-07 [9717] クエリー条件がコレクションに変わり、範囲クエリー  --start */
  /**
   * イベントの日付ごとに患者をカウントする
   * @param startDate 開始日
   * @param endDate 終了日
   * @param facilityCd 施設コード
   * @param categoryCdList カテゴリコード集合
   */
  @Select
  List<NumberOfPat> countPatByEventDate(String startDate, String endDate, String facilityCd, List<Long> categoryCdList);

  /**
   * サブカテゴリのイベント日付で患者をカウントする
   * @param startDate 開始日
   * @param endDate 終了日
   * @param facilityCd 施設コード
   * @param subCategoryCdList カテゴリコード集合
   */
  @Select
  List<NumberOfPat> countPatByEventDateWithSubCate(String startDate, String endDate, String facilityCd, List<Long> subCategoryCdList);
  /* modify by chamaojia 2023-11-07 [9717] クエリー条件がコレクションに変わり、範囲クエリー  --end */

  /**
   * 指定期間の患者イベント取得(スケジュール表の同日予定表示用)
   * @param facilityCd  施設コード
   * @param startDate 開始日
   * @param endDate 終了日
   * @return 患者イベントリスト
   */
  @Select
  List<PatEvent> selectScheduleListByPeriod(String facilityCd, String startDate, String endDate);

  @Update(sqlFile = true)
  int updateResultParamsAndReportUrl(long pat_event_cd, String result_params, String report_url);

  /**
   * 各イベントの日付の患者IDを選択します
   * @param date 日付
   * @param facilityCd  施設コード
   */
  @Select
  List<PatEvent> selectPatIdsByEventDate(String date, String facilityCd, Long cd);

  /**
   * サブカテゴリのイベント日付ごとに患者IDを取得
   * @param date 日付
   * @param facilityCd  施設コード
   */
  @Select
  List<PatEvent> selectPatIdsByEventDateWithSubCate(String date, String facilityCd, Long cd);

  @Update(sqlFile = true)
  int updateBbsCtlNo(long pat_event_cd, long bbs_ctl_no);

  /**
   * FNSI-add 1006 No.426 --Sanjingye Sun 20201217
   * selecting db find event start Date and event end Date
   * @param facilityCd
   * @param patId
   * @param eventStartDate
   * @return
   */
  @Select
  List<PatEvent> selectEventPeriod(String facilityCd, String patId, String eventStartDate);
  // add 9273 start
  /**
   * @param facilityCd
   * @param patId
   * @param eventStartDate
   * @param ordNo
   * @return
   */
  @Select
  List<PatEvent> selectPatEventByOrdNoWithOutStartDate(String facilityCd, String patId, String eventStartDate, Long ordNo);
  /**
   * @param facilityCd
   * @param patId
   * @param eventStartDate
   * @param eventEndDate
   * @return
   */
  @Select
  List<PatEvent> selectPatEventByOrdNoAndDate(String facilityCd, String patId, String eventStartDate, String eventEndDate, List<Long> ordNoList);
  // add 9273 end
  //add NO338 患者イベントで検索　劉全航 start
  @Select
  List<Long> selectByDetailedSearchCondition(List<Long> patIdList, PatEventDetailedConditions conditions);
  //add NO338 患者イベントで検索　劉全航 end
// 426 姜 start
  @Update(sqlFile = true)
  int updateDateByCd(String patEventCd, int dataNumber);

  @Update(sqlFile = true)
  int deleteDateByCd(String patEventCd);
// 426 姜 start

// add FNSI-連携イベント作成・中止ツールを追加 ウ start
  /**
   * 患者情報を取得する
   * @param facilityCd 施設コード
   * @param dialysis_date_from 開始日付
   * @param dialysis_date_to 終了日付
   * @param strkbn 連携イベント
   * @return 患者イベント（仮）イベントリスト
   */
  @Select
  List<PatEventCoopInfo> selectByFacilitycdDate(String facilityCd, String dialysis_date_from, String dialysis_date_to,String strkbn);
  // add FNSI-連携イベント作成・中止ツールを追加 ウ end

  /**
   * 観察記録を取得する
   * @param patEventCd 患者イベントコード
   * @return 患者イベントのうちサブカテゴリの利用種別が観察記録のもの
   */
  @Select
  List<PatEvent> selectObserveRecordByCd(Long patEventCd);

  /**
   * 紹介状を取得する
   * @param patEventCd 患者イベントコード
   * @return 患者イベントのうちサブカテゴリの利用種別が紹介状のもの
   */
  @Select
  List<PatEvent> selectPatIntroLetterByCd(Long patEventCd);
  //7342 add 紹介状のイベント日付が登録日になる 張 start
  /**
   * 紹介状を取得する
   */
  @Select
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
  // List<PatEvent> selectByLetterDate(long patId, String dialysis_date_from, String dialysis_date_to, String facilityCd);
  List<PatEvent> selectByLetterDate(long patId, String dialysis_date_from, String dialysis_date_to, String facilityCd, Integer patShareMode);
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
  //7342 add 紹介状のイベント日付が登録日になる 張 end
  // add 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 start
  @Select
  String  selectByPatIdAndUseType(Long patId,String facilityCd);
  // add 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 end

  //add 患者イベント设定后处理不正 修正 20230601 ztc start
  @Update(sqlFile = true)
  int deleteDataByOrdNo(Long ordNo);
  //add 患者イベント设定后处理不正 修正 20230601 ztc end
  // add #9273 施設設定マスタのNo105の設定どおり動かない。  start
  @Select
  List<PatEvent> selectByPatIdAndEventStartDate(String facilityCd, Long patId, String eventStartDate);
  @Update(sqlFile = true)
  int deleteByPatIdAndEventStartDate(String facilityCd, Long patId, String eventStartDate);
  @Update(sqlFile = true)
  int updateNoticeDate(Long patEventCd, int dataNumber);
  // add #9273 施設設定マスタのNo105の設定どおり動かない。  end

  // add 10409 曜日パターン変更の患者イベント修正 関  start
  @Select
  List<OrdNoAndConnectedTableKeyData> selectPatEventByIsOrder(String facilityCd, String dialysis_date_from, String dialysis_date_to, Long pat_id);
  // add 10409 曜日パターン変更の患者イベント修正 関  end

  // add #11717【因島】曜日パターン変更の動作が遅い fang start
  @Select
  List<PatEvent> selectByOrdNos(Long patId, String facilityCd, List<Long> ordNos);
  // add #11717【因島】曜日パターン変更の動作が遅い fang end

  // add #11716 曜日パターン変更の不正 関 start
  @Update(sqlFile = true)
  int updateIsDelToZeroByList(String facilityCd, Long patId, List<Long> patEventCds);

  @Select
  List<PatEvent> selectByPatIdAndEventStartDates(String facilityCd, Long patId, List<String> eventStartDates);
  // add #11716 曜日パターン変更の不正 関 end
  // add #12324 紹介状の出力時にpat_eventを参照する zhao start
  /**
   * 指定IDの最新患者イベントリストを取得する
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @param fromDate 期間指定From
   * @param toDate 期間指定To
   * @return 患者イベント情報
   */
  @Select
  List<PatEvent> selectByPatIdAndDate(Long patId, String facilityCd, String fromDate, String toDate);
  // add #12324 紹介状の出力時にpat_eventを参照する zhao end
  // add #12462 患者情報共有 zhao start
  /**
   * 指定IDの最新患者イベントリストを取得する
   * @param patId 患者ID
   * @param startEventDate 期間指定From
   * @param endEventDate 期間指定To
   * @param facilityCd 施設コード
   * @param patEventList 患者共有用
   * @param patEventCdList 患者イベントコード
   * @return 患者イベント情報
   */
  @Select
  List<PatEventShare> selectByPatIdFacilitycdNewestShare(Long patId,
                                                         Timestamp startEventDate,
                                                         Timestamp endEventDate,
                                                         String facilityCd,
                                                         List<PatEvent> patEventList,
                                                         Long... patEventCdList);
  /**
   * 観察記録のリストを取得
   * @param patId
   * @param startEventDate
   * @param endEventDate
   * @param categoryDataList
   * @param regStaffCd
   * @param upStaffCd
   * @param offset ※追加読込で使用
   * @param patEventList 患者共有用
   * @return 観察記録リスト MAX100件取得
   */
  @Select
  List<PatEventShare> selectObsRecByConditionShare(Long patId,
                                                   String startEventDate,
                                                   String endEventDate,
                                                   List<Pair<Long, Long>> categoryDataList,
                                                   String regStaffCd,
                                                   String upStaffCd,
                                                   Integer offset,
                                                   List<PatEvent> patEventList);
  /**
   * 観察記録リストの件数を取得
   * @param patId
   * @param startEventDate
   * @param endEventDate
   * @param categoryDataList
   * @param regStaffCd
   * @param upStaffCd
   * @param patEventList 患者共有用
   * @return 観察記録リストの件数
   */
  @Select
  int countObsRecByConditionShare(Long patId,
                                  String startEventDate,
                                  String endEventDate,
                                  List<Pair<Long, Long>> categoryDataList,
                                  String regStaffCd,
                                  String upStaffCd,
                                  List<PatEvent> patEventList);
  // add #12462 患者情報共有 zhao end
}
