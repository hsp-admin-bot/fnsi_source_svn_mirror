package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstObsKind;

@ConfigAutowireable
@Dao
public interface MstObsKindDao {
  @Select
  List<MstObsKind> selectAll(String facilityCd);

  @Select
  List<MstObsKind> selectByKindNo(Long kindNo);

  @Insert
  int insert(MstObsKind param);

  @Delete
  int delete(MstObsKind param);

  @Update
  int update(MstObsKind param);

  @Select
  List<MstObsKind> selectAllOrderByMstSelector(SelectOptions options, MstObsKind params);
}
