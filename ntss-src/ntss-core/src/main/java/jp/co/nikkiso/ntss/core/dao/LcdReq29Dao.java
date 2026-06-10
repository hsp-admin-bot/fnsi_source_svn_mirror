package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq29;

/**
 * 仮想端末情報（処置者）のDaoインタフェース
 * @author Y.Takamura
 *
 */
@ConfigAutowireable
@Dao
public interface LcdReq29Dao {
  @Select
  List<LcdReq29> selectByCd(String facilityCd);
}
