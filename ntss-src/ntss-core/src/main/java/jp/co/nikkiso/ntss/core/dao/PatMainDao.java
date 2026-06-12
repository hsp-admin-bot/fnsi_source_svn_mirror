package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.PatMainDetailedConditions;
import jp.co.nikkiso.ntss.core.entity.DeviceSetInfo;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.custom.AdditionInfo;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvPatNotificateInfo;
import jp.co.nikkiso.ntss.core.entity.custom.SharedPatFacilityInfo;
import jp.co.nikkiso.ntss.core.entity.custom.TareAndOffWater;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq44;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq45;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import java.sql.Timestamp;
import java.util.List;
import java.util.Map;

// add FNSI-患者情報共有よりの改修 江 start
// add FNSI-患者情報共有よりの改修 江 end


@ConfigAutowireable
@Dao
public interface PatMainDao {
  @Insert(sqlFile = true)
  int insert(PatMain pat);

  /**
   * 患者IDリスト取得用
   * @param patIdList 患者IDリスト
   * @return 患者リスト
   */
  @Select
  List<PatMain> selectByIdList(List<Long> patIdList);

  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
  @Select
  List<PatMain> selectByFacilityCd(String facilityCd);
  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end

  //add #10632 装置設定画面の更新時にpat_main_historyがインサートされない 20240530 ztc start
  @Select
  List<PatMain> selectByFacilityCdPatId(String facilityCd, Long patId);
  //add #10632 装置設定画面の更新時にpat_main_historyがインサートされない 20240530 ztc end

  /**
   * pat_idを指定して患者取得
   * @param patIdList 患者IDリスト
   * @param facilityCd 処理対象施設の施設コード
   * @return 患者リスト
   */
  @Select
  List<PatMain> selectByIdListFacilityCd(List<Long> patIdList, String facilityCd);

  // add 10389 患者リストのソートが遅い gjn start
  @Select
  List<PatMain> selectByIdListFacilityCdToPatGroup(List<Long> patIdList, String facilityCd);
  // add 10389 患者リストのソートが遅い gjn end

  @Select
  List<PatMain> selectByIdListFacilityCdToTreatmentStatus(List<Long> patIdList, String facilityCd);

  @Select
  List<PatMain> selectByIdListFacilityCdDate(List<Long> patIdList, String facilityCd, String startDate, String endDate);

  //mod #11034 データリストにてテンプレートに「治療予定・治療記録」をつかっているレイアウトでは最大50件までしか表示されない zrx start
  //No.7167 upd Paging Optimization runtime by ztc start
//  @Select
//  List<PatMain> selectByIdListFacilityCdDateByLimitAndOffset(List<Long> patIdList, String facilityCd, String startDate,
//                                                             String endDate, Integer limit, Integer offset, Boolean isOnlyRst);
//No.7167 upd Paging Optimization runtime by ztc end
  @Select
  List<PatMain> selectByIdListFacilityCdDateByLimitAndOffset(List<Long> patIdList, String facilityCd, String startDate,
                                                             String endDate, Boolean isOnlyRst);
  //mod #11034 データリストにてテンプレートに「治療予定・治療記録」をつかっているレイアウトでは最大50件までしか表示されない zrx end

  /**
   * 施設毎患者リスト取得用
   * @param facilityCdList 施設CDリスト
   * @return 患者リスト
   */
  @Select
  List<PatMain> selectByCdList(List<String> facilityCdList);

  @Select
  List<DeviceSetInfo> selectDeviceInfo(Long pat_id, String second_key);

  @Select
  List<DeviceSetInfo> selectTareAndOffWater(Long pat_id);

  @Select
  TareAndOffWater selectTareAndOffWaterByDayOfWeek(Long patId, String dayOfWeekTare, String dayOfWeekOffWater);
  /**
   * 患者情報のホスト報知情報取得用
   * @param pat_id 患者ID
   * @return 患者情報のホスト報知情報
   */
  @Select
  String selectHostNotificationById(Long pat_id);

  @Select
  Map<String, Object> selectInOutState(String facility_cd, long pat_id);

  @Select
  List<AdditionInfo> selectAdditionInfo(String facilityCd, Long patId);
  // add FNSI-患者情報共有よりの改修 江 start
  @Select
  List<SharedPatFacilityInfo> selectFacilityList(String facilityCd, Long patId);
  // add FNSI-患者情報共有よりの改修 江 end

  @Update(sqlFile = true)
  int updateAdditionInfoById(Long patId, String additionInfo);

  @Update(sqlFile = true)
  int updateManualAddInfoById(Long patId, String additionInfo);

  @Update(sqlFile = true)
  int updateById(long pat_id, PatMain pat);

  /*
  @Delete
  int deleteByCd(long pat_id);
  */

  @Update(sqlFile = true)
  int updateIsSame(List<Long> patIdList, String is_same);

  // #11205 -ペンテスト2－4認可制御の不備  add 20260427 start
  @Update(sqlFile = true)
  int updateIsSameByFacilityCd(List<Long> patIdList, String is_same, String facilityCd);
  // #11205 -ペンテスト2－4認可制御の不備  add 20260427 end

  @Update(sqlFile = true)
  int updateStartTareAndOffWater(Long patId, String offWaterInfo, String tareInfo);

  @Update(sqlFile = true)
  int immediateCommitRemovalWater(Long patId, String offWaterInfo);

  @Update(sqlFile = true)
  int immediateCommitTare(Long patId, String tareInfo);

  @Update(sqlFile = true)
  int updateTareAndOffWater(Long patId, String tareInfo, String offWaterInfo);

  @Update(sqlFile = true)
  int updateSysTareOffWaterInfo(String facilityCd, String tareInfo, String offWaterInfo);

  @Update(sqlFile = true)
  int updateDeviceInfo(Long patId, String facilityCd, String deviceInfo);

  @Update(sqlFile = true)
  int updateDeviceSetInfoAll(Long patId, String deviceInfo);

  @Update
  int update(PatMain patMain);

  /**
   * 確定・予定転入出状態更新
   */
  @Update(sqlFile = true)
  int updateInOutState(Long pat_id, String in_out_current_state, String in_out_plan_state, String in_out_plan_date, PatMain pat);

  /**
   * 仮想端末情報（禁忌）のDaoインタフェース
   * @author Y.Takamura
   *
   */
  @Select
  List<LcdReq44> selectTabooById(Long patId);
  /**
   * 仮想端末情報（メモ）のDaoインタフェース
   * @author Y.Takamura
   *
   */
  @Select
  List<LcdReq45> selectMemoById(Long patId);
  /**
   * 患者取得用
   * @param patId 患者ID
   * @return 抽出条件を満たした患者の患者
   */
  @Select
  PatMain selectById(Long patId);

  // #11205 -ペンテスト2－4認可制御の不備  add 20260420 start
  @Select
  long countByPatIdAndFacilityCd(long patId, String facilityCd);
  // #11205 -ペンテスト2－4認可制御の不備  add 20260420 end

  /**
   * 患者情報の治療状況更新
   * @param patId 患者情報
   * @return
   */
  @Update(sqlFile = true)
  int updateAcceptanceStatusClass(Long patId, String statusClass, Timestamp upDate);
  /**
   * 患者情報の治療状況初期化
   * @param patId 患者情報
   * @return
   */
  @Update(sqlFile = true)
  int updateResetAcceptanceStatus(Long patId, Timestamp upDate);

  // mod 11315【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
  @Select
  List<Long> selectByDetailedSearchCondition(PatMainDetailedConditions conditions, List<Long> patIdList, List<String> facilityCdList, boolean unknownFlag);
  // mod 11315【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end

  @Select
  String selectDeviceSetInfo(Long pat_id);

  @Update(sqlFile = true)
  int updateDeviceSetInfo(Long patId, String facilityCd, String deviceSetInfo);

  @Update(sqlFile = true)
  int updatePatHostNotification(Long patId, String facilityCd, String hostNotificationInfo, Timestamp upDate);

  @Update(sqlFile = true)
  int updatePatTareOffWaterInfo(Long patId, String facilityCd, String tareInfo, String offWaterInfo, Timestamp upDate);

  @Update(sqlFile = true)
  int updateIsDelById(Long patId);

  @Update(sqlFile = true)
  int updateSchExtEndDate(Long patId, String schExtEndDate);

  //add redmine bug#6484 劉 start
  @Update(sqlFile = true)
  int updateMedicalCareInfo(Long patId, String medicalCareInfo);
  //add redmine bug#6484 劉 end

  @Update(excludeNull = true)
  int updatePatMain(PatMain patMain);

  @Select
  String selectSchExtStatus(Long patId);

  /**
   * 特定患者のホスト報知設定を取得
   * @param patId 患者ID
   * @return ホスト報知設定JSON
   */
  @Select
  String selectHostNotificationInfo(Long patId);

  /**
   * 複数患者のホスト報知設定を取得
   * @param patIdList 患者ID
   * @return ホスト報知設定JSON
   */
  @Select
  List<ComsvPatNotificateInfo> selectHostNotificationInfoList(List<Long> patIdList);

  /**
   * 指定日の入外・転入出情報を元に転入出情報を更新する
   * @param targetDt 更新対象日付
   * @param today 本日日付
   * @param pat_id_list 更新対象者のpat_idリスト(空のリスト指定時は全件対象)
   * @param move_in_out_cd_list 更新対象の転入出区分(空のリスト指定時は全件対象)
   * @return
   */
  @Update(sqlFile = true)
  int updateMoveInOutInfo(String targetDt, String today, List<Long> pat_id_list, List<String> move_in_out_cd_list);

  /**
   * 指定日に期間終了する一時転出患者の転入出情報を更新する
   * @param targetDt 更新対象日付
   * @param today 本日日付
   * @param pat_id_list 更新対象者のpat_idリスト(空のリスト指定時は全件対象)
   * @return
   */
  @Update(sqlFile = true)
  int updateMoveInOutInfoTempMoveOutBack(String targetDt, String today, List<Long> pat_id_list);

  /**
   * スケジュール自動延長処理対象患者リスト取得用
   * @param sch_ext_end_date スケジュール延長日(この日以前の患者を取得)
   * @return 患者IDリスト
   */
  @Select
  List<Long> selectPatIdListBySchExtEndDate(String sch_ext_end_date);
  // add 8008日次処理のスケジュール自動延長がされない患者が存在する。20221018 赵 start
  @Select
  List<Long> selectPatIdDelListBySchExtEndDate(String sch_ext_end_date);
  // add 8008日次処理のスケジュール自動延長がされない患者が存在する。20221018 赵 end

  @Select
  List<Long> selectPadIdListByFacilityCodeAndSchExtEndDate(String facilityCode, String sch_ext_end_date);

  /* add #6358 by zhangruixue 2023-06-13 --start */
  @Select
  String selectMinSchExtEndDateByFacilityAndPatIds(String facility_cd,List<Long> patIdList);
  /* add #6358 by zhangruixue 2023-06-13 --end */

  /**
   * 指定患者の治療進捗状態を更新する
   * @param patId                   患者id
   * @param acceptanceStatusInfo    治療進捗状況
   * @return
   */
  @Update(sqlFile = true)
  int updateAcceptanceStatusInfoById(Long patId, String acceptanceStatusInfo);

  // #11205 -ペンテスト2－4認可制御の不備  add 20260427 start
  @Update(sqlFile = true)
  int updateAcceptanceStatusInfoByIdFacilityCd(Long patId, String acceptanceStatusInfo, String facilityCd);
  // #11205 -ペンテスト2－4認可制御の不備  add 20260427 end

  // add 2020-08-08 FNSI-仕様追加 カード読み込み時にIdmでカード有効無効なチェック処理 夏 start
  /**
   * アクセスカード番号を取得
   * @param patId ユーザーID
   * @return アクセスカード番号
   */

  @Select
  String selectCardIdm(Long patId);
  // add 2020-08-08 FNSI-仕様追加 カード読み込み時にIdmでカード有効無効なチェック処理 夏 end

  // add 2020-08-13 FNSI-仕様追加 患者基本情報(pat_main)にアクセスカード番号(card_idm)の追加処理 夏 start
  /**
   * アクセスカード番号を設定
   * @param cardIdm アクセスカード番号
   * @param patId ユーザーID
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int setPatCardIdm(String cardIdm, long patId);
  // add 2020-08-13 FNSI-仕様追加 患者基本情報(pat_main)にアクセスカード番号(card_idm)の追加処理 夏 end

  // add FNSI-共有された患者情報作成を見直し 江 start
  @Select
  List<String> selectOtherContactPatIdListById(long pat_id,String dstfacility_cd,String srcfacility_cd);
  // add FNSI-共有された患者情報作成を見直し 江 end
  // add FNSI-？？？？患者割り当て 陳 start
  /**
   * 患者情報の治療状況更新
   * @param patId 患者情報
   * @param classStatus オーダー番号
   * @param treatmentTime 治療情報.指示：治療条件情報
   * @param startDateTime 治療情報.実績：治療開始日時
   * @param upDate
   * @return
   */
  @Update(sqlFile = true)
  int updateAcceptanceStatusInfo(Long patId, String classStatus, String treatmentTime, String startDateTime, Timestamp upDate);
  // add FNSI-？？？？患者割り当て 陳 end

  /**
   * ホスト報知設定 血圧測定間隔取得用
   * @param patId 患者id
   * @return 血圧測定間隔(分)
   */
  @Select
  String selectBpmiIntervalById(Long patId);

  /*add FNSI-改修内容掲示板外结No.10 任 start*/
  @Select
  List<PatMain> selectIsSame();
  /*add FNSI-改修内容掲示板外结No.10 任 end*/

  // add 入院・同姓同名配布 趙 start
  @Select
  /* update by chamaojia 2026-02-05 [11893] キャッシュ軽減対応 --start */
  List<PatMain> selectPatIsSame(List<String> facilityCdList, List<Long> patIds);
  /* update by chamaojia 2026-02-05 [11893] キャッシュ軽減対応 --end */
  // add 入院・同姓同名配布 趙 end
  /*add FNSI-改修内容5195 任 start*/
  @Select
  List<PatMain> selectByIdListFacilityCdMultiPatList(List<Long> patIdList, String facilityCd);
  /*add #6829 ljg start*/
  @Select
  String selectSchextenddate(Long patId);
  /*add #6829 ljg end*/
  @Select
  int checkIsPrint(String facilityCd,Integer patId,String treatDate,Integer reportCd);
  //add 5127 透析レポート印刷時の条件について 吉 end
  //add 7734  患者情報の主治医取得 ljg start
  @Select
  String selectStaff(Long patId);
  //add 7734  患者情報の主治医取得 ljg end

  //add 患者検索設定後処理不正 修正 20230601 ztc start
  @Select
  List<PatMain> selectByCdListAndSetting(List<String> facilityCdList, int simpleSearchConditions);

  @Select
  List<PatMain> selectByPatIdListFacilityCdAndSetting(List<Long> patIdList, String facilityCd, int simpleSearchConditions);
  //add 患者検索設定後処理不正 修正 20230601 ztc end

  //add #10203 profile連携で同姓同名のチェックが行われない 20240110 zhaoqi start
  @Update(sqlFile = true)
  int updateIsSameToZero(List<Long> patIdList);
  //add #10203 profile連携で同姓同名のチェックが行われない 20240110 zhaoqi end

  @Update(sqlFile = true)
  int deletePatReplenisherFiltration(String facilityCd);

  @Update(sqlFile = true)
  int insertPatReplenisherFiltration(String facilityCd);

  @Update(sqlFile = true)
  int updatePatReplenisherFiltrationCode(String facilityCd);

  //add #10412 次患者更新関連全体見直し対応 朴 start
  @Select
  List<PatMain> selectByFacilityCdAndWardCd(String facilityCd, List<Integer> wardCdList);

  @Select
  List<PatMain> selectByFacilityCdAndCourseCd(String facilityCd, List<Integer> courseCdList);

  @Select
  List<PatMain> selectByFacilityCdAndStaffCd(String facilityCd, List<Long> staffCdList);
  //add #10412 次患者更新関連全体見直し対応 朴 end

  //add 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある zhao start
  /**
   * 患者共通診療情報
   * @param patId 患者ID
   * @param patId 患者ID
   * @return 患者共通診療情報
   */
  @Select
  PatMain selectMedicalCareInfoByIdAndFacilityCd(String facilityCd, Long patId);
  //add 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある zhao end

  // add #12306 スケジュール作成可能期間外について、患者経過総合ビューア＆スケジュール表で動作不正 関 start
  @Select
  List<Long> selectPatIdListBySchExtEndDateAfterTreatDate(List<Long> patIdList, String facilityCd, String targetTreatDate);
  // add #12306 スケジュール作成可能期間外について、患者経過総合ビューア＆スケジュール表で動作不正 関 end

  /* add by chamaojia 2026-03-27 [12462] 患者情報共有->患者経過総合ビューア --start */
  @Select
  List<PatMain> selectSharePatByPatId(String facilityCd, Long patId);
  /* add by chamaojia 2026-03-27 [12462] 患者情報共有->患者経過総合ビューア --end */

  /**
   * 指定車いすを割当済みの患者リスト
   * @param facilityCd 施設コード
   * @param wheelChairCd 車いすコード
   * @return
   */
  @Select
  List<Long> selectPadIdListByWheelChairCd(String facilityCd,Long wheelChairCd);

  /**
   * 指定車いすの割当解除
   * @param wheelChairCd 車いすコード
   * @return
   */
  @Update(sqlFile = true)
  int updateWheelChairCdDel(Long wheelChairCd);

  /**
   * 車いす個人所有
   * @param patId 患者ID
   * @return
   */
  @Update(sqlFile = true)
  int updateIsWheelChair(Long patId);

  // add #11718 【#11600持ち越し】データリスト画面不正② fang start
  /**
   * 患者取得用
   * @param facilityCd 施設コード
   * @param patIds 患者ID
   * @return 抽出条件を満たした患者の患者
   */
  @Select
  List<PatMain> selectByPatIds(String facilityCd, List<Long> patIds);
  // add #11718 【#11600持ち越し】データリスト画面不正② fang end
}
