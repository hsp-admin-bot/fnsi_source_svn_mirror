package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.SysFunction;

@ConfigAutowireable
@Dao
public interface SysFunctionDao {
  @Select
  List<SysFunction> selectAll(SelectOptions options);

  @Select
  List<SysFunction> selectDispOnly(SelectOptions options);

  @Select
  List<SysFunction> selectDispOnly();

  @Select
  List<SysFunction> selectByDelAndDisp(String isDel, String isDisp, List<String> isNkkList, List<String> systemUseDispList);

  @Select
  SysFunction selectByFunctionCd(String functionCd);

  @Select
  List<SysFunction> selectSysFunctionForLogCondition();

  @Select
  SysFunction selectByFunctionName(String functionName);
}
