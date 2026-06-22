package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.SysFunctionAdvanced;

/**
 * 拡張機能のDaoインタフェース
 */
@ConfigAutowireable
@Dao
public interface SysFunctionAdvancedDao {
  @Select
  List<SysFunctionAdvanced> selectAll();
  
  @Select
  List<SysFunctionAdvanced> selectByDelAndDisp(String isDel, String isDisp, List<String> isNkkList, List<String> systemUseDispList);

  @Select
  SysFunctionAdvanced selectByFunctionAdvCd(String functionAdvCd);
}
