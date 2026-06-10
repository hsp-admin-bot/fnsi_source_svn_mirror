package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstBbsKind;

@ConfigAutowireable
@Dao
public interface MstBbsKindDao {
  @Select
  List<MstBbsKind> selectAll(SelectOptions options, MstBbsKind params);

// add マスタ削除 対応 chen start
  @Select
  List<MstBbsKind> selectAllContainDel(MstBbsKind params);
// add マスタ削除 対応 chen end

  @Select
  List<MstBbsKind> selectByFacilityCd(String facility_cd, String is_del);

  @Select
  MstBbsKind selectBykindNo(Long kind_no, String facility_cd);

}
