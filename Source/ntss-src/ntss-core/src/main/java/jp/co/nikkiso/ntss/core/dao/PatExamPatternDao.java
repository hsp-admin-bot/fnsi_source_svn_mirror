package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.PatExamPatternConditions;
import jp.co.nikkiso.ntss.core.entity.custom.WeekChangeInfo;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.PatExamPattern;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamPatternData;


@ConfigAutowireable
@Dao
public interface PatExamPatternDao {

  /**
   * 指定ユーザの指定期間内検査パターンを取得
   * @param patId 患者ID
   * @param fromDate 期間開始日 ('YYYY/MM/DD')
   * @param toDate 期間終了日 ('YYYY/MM/DD')
   * @return 患者検査パターンリスト
   */
  @Select
  List<PatExamPattern> selectPatExamPattern(Long patId, String fromDate, String toDate);

  @Select
  int  selectPatExamPatternByPatId(Long patId);

  /**
   * 指定期間内の検査パターンを取得
   * @param params 以下の３つを含む
   *   patId 患者ID
   *   fromDate 期間開始日 ('YYYY/MM/DD')
   *   toDate 期間終了日 ('YYYY/MM/DD')
   * @return 患者検査結果リスト
   */
  @Select
  List<PatExamPattern> selectPatExamPatternList(Map<String,String> params) ;

  /**
   * 患者検査パターン取得用(全件)
   * @param patIdList 患者ID
   * @param startDate 検索開始日
   * @return 該当患者の検査パターンのリスト
   */
  @Select
  List<PatExamPatternData> selectPatExamPatternByPatIdList(List<Long> patIdList, String startDate);

  /**
   * 検査セットパターンを保存(追加).
   * @param patExamPattern PatExamPatternのEntity
   * @return 更新件数
   */
  @Insert
  int insertPatExamPattern(PatExamPattern patExamPattern);

  /**
   * 検査パターンを保存(更新).
   * @param patExamPattern PatExamPatternのEntity
   * @return 更新件数
   */
  @Update(include = {"isDel", "upDate", "upStaff"})
  int updatePatExamPattern(PatExamPattern patExamPattern);

  /**
   * 検査パターンを削除(is_del を 1 に更新).
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @param deleteDate 日付(exam_toがこの日付以降だった場合に削除対象とします)
   * @param userId 利用者ID
   * @param indUserId 指示者ID
   * @return 更新件数
   */
  @Update(sqlFile = true)
  // mod #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc start
//  int updateIsDelByPatIdAndExamTo(Long patId, String facilityCd, String deleteDate, Long userId, Long indUserId);
  int updateIsDelByPatIdAndExamTo(Long patId, String facilityCd, String indStartDate, String indEndDate, Long userId, Long indUserId);
  // mod #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc end
  /**
   * 患者检索
   * @param conditions
   * @param patIdList
   * @param facilityCdList
   * @return
   */
  @Select
  List<Long> selectByDetailedSearchCondition(PatExamPatternConditions conditions, List<Long> patIdList, List<String> facilityCdList);

  //add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
  @Update(sqlFile = true)
  int updateExamOrderInfoByItemCd(String facilityCd,String examItemName,String examItemCd,String isDisp);

  @Update(sqlFile = true)
  int updateExamOrderInfoBySetCd(String facilityCd,String setCd,String examSetInfo);
  //add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end

  //add #10901 死亡患者受信時処理について 20241231 zrx start
  @Select
  List<PatExamPattern> deleteExamPatternByPatIdList(String facilityCd, List<Long> patIdList);
  //add #10901 死亡患者受信時処理について 20241231 zrx end

  // add #11716 曜日パターン変更の不正 関 start
  @Update(sqlFile = true)
  int updateExamWeekByChangeWeek(String facilityCd, Long patId, List<WeekChangeInfo> changeList, Long indUserId, Long updUserId);

  @Select
  List<PatExamPattern> deleteExamPatternByExamWeekList(String facilityCd, Long patId, List<Integer> examWeekList, Long indUserId, Long updUserId);

  @Select
  List<PatExamPattern> selectExamPatternByExamWeekList(String facilityCd, Long patId, List<Integer> examWeekList);
  // add #11716 曜日パターン変更の不正 関 end
}
