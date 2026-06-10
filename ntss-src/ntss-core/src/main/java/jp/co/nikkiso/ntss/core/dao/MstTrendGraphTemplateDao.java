package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstTrendGraphTemplate;

/**
 * トレンドグラフテンプレートマスタ用のDaoインタフェース
 *
 */
@ConfigAutowireable
@Dao
public interface MstTrendGraphTemplateDao {
  @Select
  // mod FNSI-改修内容5702修正 xuty start
  // List<MstTrendGraphTemplate> selectByModel(String facilityCd, String model);
  List<MstTrendGraphTemplate> selectByModel(String facilityCd, String model, String comFormatCd);
  // mod FNSI-改修内容5702修正 xuty end


}
