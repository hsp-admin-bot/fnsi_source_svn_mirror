package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstMainteCategoryHst;
import jp.co.nikkiso.ntss.core.entity.custom.CusMainteCategoryResult;

/**
 * 定期点検項目グループ
 */
@ConfigAutowireable
@Dao
public interface MstMainteCategoryHstDao {

  @Select
  List<MstMainteCategoryHst> selectByListIdAndEdition(List<CusMainteCategoryResult> cusMainteCategoryResults);

  @Select
  List<MstMainteCategoryHst> selectByListIdAndEditionWithOrder(List<CusMainteCategoryResult> cusMainteCategoryResults);

  @Insert(sqlFile = true)
  int insertList(List<MstMainteCategoryHst> mstMainteCategoryHsts);

  /* add by quzhinan  2023-02-01 [Trigger]  start */
  @Insert
  int insert(MstMainteCategoryHst mstMainteCategoryHst);
  /* add by quzhinan  2023-02-01 [Trigger]  end */
  @Insert(sqlFile = true)
  int insertCategoryHst(MstMainteCategoryHst mstMainteCategoryHst);
}
