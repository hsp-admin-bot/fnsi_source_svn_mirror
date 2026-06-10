package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstTrendGraphMonitorSet;

/**
 * トレンドグラフのモニター設定用のDaoインタフェース
 *
 */
@ConfigAutowireable
@Dao
public interface MstTrendGraphMonitorSetDao {
  @Select
  // mod FNSI-改修内容5702修正 xuty start
  // List<MstTrendGraphMonitorSet> selectByModel(String facilityCd, String model);
  List<MstTrendGraphMonitorSet> selectByModel(String facilityCd, String model, String comFormatCd);
  // mod FNSI-改修内容5702修正 xuty end

}
