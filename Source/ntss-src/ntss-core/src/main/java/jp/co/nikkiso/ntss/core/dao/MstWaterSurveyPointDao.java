package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import java.util.Map;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.custom.WaterSurveyPoint;;

@ConfigAutowireable
@Dao
public interface MstWaterSurveyPointDao {

	@Select
	List<WaterSurveyPoint> getAll(SelectOptions options, String facilityCd);

	@Select
	WaterSurveyPoint selectByCd(Long surveyPointCd);

  // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
  @Select
  List<Map<String, Object>> selectByWaterSurveyPoint(String facilityCd, String machineTypeCd);
  // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end

}
