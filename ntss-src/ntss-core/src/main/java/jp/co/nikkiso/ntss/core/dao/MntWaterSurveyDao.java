package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MntWaterSurvey;
import jp.co.nikkiso.ntss.core.entity.custom.SchedulePlanData;

@ConfigAutowireable
@Dao
public interface MntWaterSurveyDao {
	@Select
	List<MntWaterSurvey> filter(String startDate, String endDate, List<Long> listSurveyTypeCd, List<Long> listBedCd, String facilityCd);
  // add 7290 カレンダーを利用した水質検査の予定作成・結果登録をした際、水質管理画面にその内容が反映されない 周安寧 start
  @Select
  List<MntWaterSurvey> filterWithoutBed(String startDate, String endDate, List<Long> listSurveyTypeCd, String facilityCd);
  // add 7290 カレンダーを利用した水質検査の予定作成・結果登録をした際、水質管理画面にその内容が反映されない 周安寧 end
	@Select
	MntWaterSurvey selectBySurveyRecordNo(Long surveyRecordNo);
	
	@Insert(sqlFile = true)
	int insert(MntWaterSurvey watSurvey);

	@Update(sqlFile = true)
	int update(MntWaterSurvey watSurvey);

	@Delete(sqlFile = true)
	int deleteBySurveyRecordNo(Long surveyRecordNo, String facilityCd);
	
  /**
   * 指定期間の水質管理予定取得(スケジュール表の予定表示用)
   * @param facilityCd  施設コード
   * @param startDate 開始日
   * @param endDate 終了日
   * @return 水質管理リスト
   */
  @Select
  List<SchedulePlanData> selectScheduleListByPeriod(String facilityCd, String startDate, String endDate);

}
