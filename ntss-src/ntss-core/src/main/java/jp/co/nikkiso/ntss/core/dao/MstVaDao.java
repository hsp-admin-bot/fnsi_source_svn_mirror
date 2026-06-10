package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstVa;

@ConfigAutowireable
@Dao
public interface MstVaDao {
  @Select
  List<MstVa> selectAll(SelectOptions options, MstVa params);
// FNSI-修正 マスタ削除の対応 chen add start
  @Select
  List<MstVa> selectAllNoDel(SelectOptions options, MstVa params);
// FNSI-修正 マスタ削除の対応 chen add end

  @Select
  MstVa selectByCd(int vaCd);

  // add #6746 额外批评查询高性能 查 start
  @Select
  List<MstVa> selectAllByCds(List<Integer> vaCds);
  // add #6746 额外批评查询高性能 查 end

  // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 start
  @Select
  MstVa selectAllByCd(int vaCd);
  // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 end
  
  @Select
  List<MstVa> selectByFacilityCd(String facilityCd);
}
