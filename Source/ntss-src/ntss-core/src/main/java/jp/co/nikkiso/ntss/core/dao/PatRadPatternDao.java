package jp.co.nikkiso.ntss.core.dao;

import java.sql.Timestamp;
import java.util.List;

import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.PatRadPatternDetailedConditions;
import jp.co.nikkiso.ntss.core.entity.custom.WeekChangeInfo;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.PatRadPattern;
import jp.co.nikkiso.ntss.core.entity.custom.PatRadPatternData;

@ConfigAutowireable
@Dao
public interface PatRadPatternDao {

  /**
   * 患者放射線検査パターン取得用(全件)
   * @param patId 患者ID
   * @return 該当患者の放射線検査パターンのリスト
   */
  @Select
  List<PatRadPattern> selectPatRadPatternByPatId(Long patId);

  /**
   * 指定ユーザの指定期間内放射線検査パターンを取得
   * @param patId 患者ID
   * @param fromDate 期間開始日 ('YYYY/MM/DD')
   * @param toDate 期間終了日 ('YYYY/MM/DD')
   * @return 患者放射線検査パターンリスト
   */
  @Select
  List<PatRadPattern> selectPatRadPattern(Long patId, String fromDate, String toDate);

  /**
   * 患者放射線検査パターン取得用(期間指定)
   * @param patId 患者ID
   * @return 該当患者の放射線検査パターンのリスト
   */
  @Select
  List<PatRadPattern> selectPatRadPatternByPatIdPeriod(Long patId, Timestamp fromDt, Timestamp toDt);

  /**
   * 患者放射線検査パターン取得用(全件)
   * @param patId 患者ID
   * @param startDate 検索開始日
   * @return 該当患者の放射線検査パターンのリスト
   */
  @Select
  List<PatRadPatternData> selectPatRadPatternByPatIdList(List<Long> patIdList, String startDate, String facilityCd);

  /**
   * 放射線検査パターンを保存(追加).
   * @param patRadMain PatRadMainのEntity
   * @return 更新件数
   */
  @Insert
  int insertPatRadPattern(PatRadPattern patRadPattern);

  /**
   * 放射線検査パターンを保存(更新).
   * @param patRadMain PatRadMainのEntity
   * @return 更新件数
   */
  @Update(include = {"isDel", "upDate", "upStaff"})
  int updatePatRadPattern(PatRadPattern patRadPattern);

  /**
   * 一般撮影検査パターンを削除(is_del を 1 に更新).
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @param deleteDate 日付(rad_toがこの日付以降だった場合に削除対象とします)
   * @param userId 利用者ID
   * @param indUserId 指示者ID
   * @return 更新件数
   */
  @Update(sqlFile = true)
  // mod #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc start
//  int updateIsDelByPatIdAndRadTo(Long patId, String facilityCd, String deleteDate, Long userId, Long indUserId);
  int updateIsDelByPatIdAndRadTo(Long patId, String facilityCd, String indStartDate, String indEndDate, Long userId, Long indUserId);
  // mod #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc end

  //add No338患者詳細検索の追加項目 一般撮影検査予定検索 劉全航 start
  @Select
  List<Long> selectByDetailedSearchCondition(List<Long> patIdList, PatRadPatternDetailedConditions conditions,List<String> facilityCdList);
  //add No338患者詳細検索の追加項目 一般撮影検査予定検索 劉全航 end

  //add #10901 死亡患者受信時処理について 20241231 zrx start
  @Select
  List<PatRadPattern> deleteRadPatternByPatIdList(String facilityCd, List<Long> patIdList);
  //add #10901 死亡患者受信時処理について 20241231 zrx end

  // add #11716 曜日パターン変更の不正 関 start
  @Update(sqlFile = true)
  int updateRadWeekByChangeWeek(String facilityCd, Long patId, List<WeekChangeInfo>  changeList, Long indUserId, Long updUserId);

  @Select
  List<PatRadPattern> deleteRadPatternByRadWeekList(String facilityCd, Long patId, List<Integer> radWeekList, Long indUserId, Long updUserId);

  @Select
  List<PatRadPattern> selectRadPatternByRadWeekList(String facilityCd, Long patId, List<Integer> radWeekList);
  // add #11716 曜日パターン変更の不正 関 end
}
