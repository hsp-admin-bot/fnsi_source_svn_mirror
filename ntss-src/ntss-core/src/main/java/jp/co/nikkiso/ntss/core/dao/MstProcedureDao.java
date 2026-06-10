package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstProcedure;

@ConfigAutowireable
@Dao
public interface MstProcedureDao {
  @Select
  List<MstProcedure> selectAll(SelectOptions options, MstProcedure params);

  @Select
  List<MstProcedure> selectAllIncludeDeleted(SelectOptions options, MstProcedure params);

  @Select
  MstProcedure selectByCd(String facilityCd, Integer procedureCd);
  
  @Select
  MstProcedure selectByProcedureCd(Integer procedureCd);

  /* add by chamaojia 2026-03-24 [12462] 患者情報共有->患者経過総合ビューア --start */
  @Select
  List<MstProcedure> selectByOrdNoList(List<Long> ordNoList);
  /* add by chamaojia 2026-03-24 [12462] 患者情報共有->患者経過総合ビューア --end */

}
