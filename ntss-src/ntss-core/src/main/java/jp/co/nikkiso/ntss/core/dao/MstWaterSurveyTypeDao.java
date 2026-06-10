package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MstWaterSurveyPointType;
import jp.co.nikkiso.ntss.core.entity.MstWaterSurveyType;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import java.util.List;

@ConfigAutowireable
@Dao
public interface MstWaterSurveyTypeDao {

	@Select
	List<MstWaterSurveyType> getAll(SelectOptions options, String facilityCd);

	@Select
	MstWaterSurveyType selectByCd(Long surveyTypeCd);
  /*add FNSI-改修内容5237 任 start*/
  @Select
  List<MstWaterSurveyPointType> selectDecimal(String facilityCd);
  /*add FNSI-改修内容5237 任 end*/
}
