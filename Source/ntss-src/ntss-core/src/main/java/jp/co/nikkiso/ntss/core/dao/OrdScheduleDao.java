package jp.co.nikkiso.ntss.core.dao;

import java.sql.Timestamp;
import java.util.List;

import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdScheduleNewKurPreview;
import org.seasar.doma.BatchInsert;
import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.OrdScheduleSimpleConditions;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.OrdScheduleDetailedConditions;
import jp.co.nikkiso.ntss.core.entity.OrdSchedule;
import jp.co.nikkiso.ntss.core.entity.custom.OrdScheduleCustom;

@ConfigAutowireable
@Dao
public interface OrdScheduleDao {
  /**
   * 簡易検索SQL実行
   * @param conditions ord_scheduleの簡易検索条件
   * @param patIdList 患者IDリスト
   * @param facilityCdList 施設コードリスト
   * @return 対象患者ID(pat_id)のリスト
   */
  @Select
  //mod 5273 吉 start
//  List<Long> selectBySimpleSearchCondition(OrdScheduleSimpleConditions conditions, List<Long> patIdList, List<String> facilityCdList);
  List<Long> selectBySimpleSearchCondition(OrdScheduleSimpleConditions conditions, List<Long> patIdList, List<String> facilityCdList,String rstDialysisStateFlag);
  //mod 5273 吉 end
  /**
   * 詳細検索,
   * @param conditions ord_scheduleの詳細検索条件
   * @param patIdList 患者IDリスト
   * @param facilityCdList 施設コードリスト
   * @return 対象患者ID(pat_id)のリスト
   */
  // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
  @Select
  List<OrdSchedule> selectByDetailedSearchCondition(OrdScheduleDetailedConditions conditions, List<Long> patIdList, List<String> facilityCdList);
  // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end

  /**
   * ベッド空き状況確認
   * @param facilityCd 検索施設コード
   * @param ordNoList 検索対象外治療予定リスト(ベッド割り当て予定(処理対象のクール、曜日、期間(開始日、終了日)を加味した)オーダ番号リスト)
   * @param patId 検索対象外患者ID(ベッド割り当て予定の患者ID)
   * @param bedCd 検索ベッドコード
   * @param searchStartDatetime 検索開始日時(形式:yyyyMMddHH24MISS) ※メインスケジュールの治療日+クール内標準治療開始時刻
   * @param searchEndDatetime 検索終了日時(形式:yyyyMMddHH24MISS) ※メインスケジュール(ダミースケジュール)の治療日+クール内標準治療開始時刻
   * @return 検索にヒットしたスケジュールのリスト
   */
  @Select
  List<OrdSchedule> selectForSearchReservedBed(String facilityCd, List<Long> ordNoList, Long patId, Long bedCd, String searchStartDatetime, String searchEndDatetime);

  /**
   * オーダー番号リストからスケジュール検索
   * @param facilityCd 検索施設コード
   * @param ordNoList オーダ番号リスト
   * @return 検索にヒットしたスケジュールのリスト
   */
  @Select
  List<OrdScheduleCustom> selectByOrdNoList(String facilityCd, List<Long> ordNoList);

  /**
   * スケジュール検索
   * @param facilityCd  施設コード
   * @param treatDate   治療日
   * @param kurCd       クールコード
   * @param bedCd       ベッドコード
   * @return 検索にヒットしたスケジュールのリスト
   */
  @Select
  List<OrdSchedule> selectByTreatDateKurCdBedCd(String facilityCd, String treatDate, Long kurCd, Long bedCd);

  /**
   * ダミースケジュール登録
   * @param ordNo メインスケジュールのオーダ番号
   * @param treatDate ダミースケジュールを登録する治療日
   * @param kurCd ダミースケジュールを登録するクールコード
   * @param bedCd ダミースケジュールを登録するベッドコード
   * @param upDate 更新日時
   * @return 実行件数
   */
  @Insert(sqlFile = true)
  int insertDummySchedule(Long ordNo, String treatDate, Long kurCd, Long bedCd, Timestamp upDate);

  /**
   * ダミースケジュール削除
   * @param ordNoList メインスケジュールのオーダ番号リスト
   * @return 実行件数
   */
  @Delete(sqlFile = true)
  int deleteDummySchedule(List<Long> ordNoList);

  /**
   * 治療日から患者検索
   * @param treatDate 治療日
   * @param facilityCd 施設コード
   * @return 対象患者ID(pat_id)のリスト
   */
  @Select
  List<Long> selectPatIdByTreatDate(String treatDate, String facilityCd);

  /**
   * 治療日からクール・ベッド指定済みの予定一覧を検索
   * @param facilityCd 施設コード
   * @param treatDate 治療日
   * @return クール・ベッド指定済み治療予定のリスト
   */
  @Select
  // mod FNSI-FutreNetWeb+SI課題管理No.4220 李 start
  // List<OrdSchedule> selectReservedTreatPlanByTreatDate(String facilityCd, String treatDate, Long patId);
  List<OrdSchedule> selectReservedTreatPlanByTreatDate(String facilityCd, String treatDate);
  // mod FNSI-FutreNetWeb+SI課題管理No.4220 李 end

  /* add by quzhinan  2023-02-01 [Trigger]  start */
  /**
   * insertOrdSchedule
   * @param ord ord
   * @return count
   */
  @Insert(sqlFile = true)
  int insertOrdSchedule(OrdMain ord);

  //add by ztc 2023-02-12 [Optimize no.8099] --start
  @Insert(sqlFile = true)
  int insertOrdScheduleList(List<OrdMain> ordSchList);
  //add by ztc 2023-02-12 [Optimize no.8099] --end

  /**
   * updateOrdSchedule
   * @param ord ord
   * @return count
   */
  @Update(sqlFile = true)
  int updateOrdSchedule(OrdMain ord);

  /**
   * deleteScheduleByOrdNo
   * @param ordNo ordNo
   * @return count
   */
  @Delete(sqlFile = true)
  int deleteScheduleByOrdNo(Long ordNo);

  /**
   * selectOrdScheduleRowCntByOrdNo
   * @param ordNo ordNo
   * @return count
   */
  /* modify by shiyw 2023-02-24 [#8101] Append the where condition facilityCd, matching the primary key [facility_cd,ord_no], to improve the del speed --start */
  @Select
  //int selectOrdScheduleRowCntByOrdNo(Long ordNo);
  int selectOrdScheduleRowCntByOrdNo(String facilityCd,Long ordNo);
  /* modify by shiyw 2023-02-24 [#8101] Append the where condition facilityCd, matching the primary key [facility_cd,ord_no], to improve the del speed --end */
  /* add by quzhinan  2023-02-01 [Trigger]  end */

  //add by ztc 2023-02-12 [Optimize no.8099] --start
  @Select
  List<Long> selectOrdScheduleRowCntByOrdNoList(String facilityCd, List<Long> ordNo);
  //add by ztc 2023-02-12 [Optimize no.8099] --end

  @Update(sqlFile = true)
  int updateOrdScheduleList(List<OrdMain> resultOrdMainDiffList);

  /* modify by shiyw 2023-02-24 [#8101] Append the where condition facilityCd, matching the primary key [facility_cd,ord_no], to improve the del speed --start */
  @Delete(sqlFile = true)
  //int deleteDummyScheduleList(List<Long> deleteDummyScheduleList);
  int deleteDummyScheduleList(String facilityCd,List<Long> deleteDummyScheduleList);
  /* modify by shiyw 2023-02-24 [#8101] Append the where condition facilityCd, matching the primary key [facility_cd,ord_no], to improve the del speed --end */

  /* modify by shiyw 2023-02-24 [#8101] Append the where condition facilityCd, matching the primary key [facility_cd,ord_no], to improve the del speed --start */
  @Delete(sqlFile = true)
  //int deleteScheduleByOrdNoList(List<Long> deleteScheduleByOrdNoList);
  int deleteScheduleByOrdNoList(String facilityCd,List<Long> deleteScheduleByOrdNoList);
  /* modify by shiyw 2023-02-24 [#8101] Append the where condition facilityCd, matching the primary key [facility_cd,ord_no], to improve the del speed --end */

  //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
  @Update(sqlFile = true)
  int updateOrdScheduleForZeroData(String ordNoList);

  @BatchInsert(sqlFile = true, batchSize = 500)
  int[] batchInsert(List<OrdSchedule> ordScheduleList);

  @Delete(sqlFile = true)
  int deleteDummyScheduleByIsDummy(String allOrdNo);

  @Select
  List<OrdSchedule> selectByFacilityCd(String facilityCd, Long bedCd);

  @Select
  List<OrdSchedule> getAllDeleteSchedule(String facilityCd);

  @Delete(sqlFile = true)
  int deleteDummyByPrimaryKeys(String facilityCd, List<OrdSchedule> needToDelOsList);
  //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end

  //add #11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) zkm start
  /**
   * ベッド空き状況確認
   * @param facilityCd 検索施設コード
   * @param ordNoList 検索対象外治療予定リスト(ベッド割り当て予定(処理対象のクール、曜日、期間(開始日、終了日)を加味した)オーダ番号リスト)
   * @param kurCd 変更したいクールコード
   * @param bedCd 変更したいベッドコード
   * @param indTreatStartTime 変更したい治療開始時間
   * @return 検索にヒットしたスケジュールのリスト
   */
  @Select
  List<OrdScheduleNewKurPreview> selectDummyScheduleInOrdNoList(String facilityCd, List<Long> ordNoList, Long kurCd, Long bedCd, String indTreatStartTime);

  @Select
  List<OrdScheduleNewKurPreview> selectDummyScheduleInPatId(String facilityCd, Long patId, List<Integer> weeksArray, List<Integer> indTreatmentCdList, List<Long> indKurCdList);
  //add #11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) zkm end
  // add 11061 治療方法変更治療時間が長すぎて他の予定と衝突する 関 start
  @Select
  List<OrdScheduleNewKurPreview> selectOrdMainWithNewKur(String facilityCd, List<Long> ordNoList);
  @Select
  List<OrdSchedule> selectOrdScheduleWithNewKur(String facilityCd, List<OrdScheduleNewKurPreview> scheduleList, List<Long> findOrdNoList);
  // add 11061 治療方法変更治療時間が長すぎて他の予定と衝突する 関 end
  // add 11169 治療時間を長時間として指示変更した場合に、ダミースケジュールの衝突があると、不正な治療時間で更新してしまう。関 start
  @Select
  List<OrdScheduleNewKurPreview> selectOrdMainScheduleDummyInOrdNoList(String facilityCd, List<Long> ordNoList, String treatTime);
  // add 11169 治療時間を長時間として指示変更した場合に、ダミースケジュールの衝突があると、不正な治療時間で更新してしまう。関 end

  //add #10901 死亡患者受信時処理について 20241231 zrx start
  @Select
  List<OrdSchedule> deathDelByOrdNoList(String facilityCd, List<Long> ordNoList);
  //add #10901 死亡患者受信時処理について 20241231 zrx end

  //add #10634 クールマスタで標準治療開始時刻を変更した際のダミー予定・連携イベント作成処理不正 zrx start
  /**
   * determine if it exists Dummy
   * @param facilityCd  施設コード
   * @param treatDate   治療日
   * @param bedCd       ベッドコード
   * @return 検索にヒットしたスケジュールのリスト
   */
  @Select
  List<OrdSchedule> selectByTreatDateBedCd(String facilityCd, String treatDate, Long bedCd);
  //add #10634 クールマスタで標準治療開始時刻を変更した際のダミー予定・連携イベント作成処理不正 zrx end

  @Select
  List<OrdSchedule> bulkUpdateByOrdMainIndCondInfo(String facilityCd, List<Long> ordNoList);
}
