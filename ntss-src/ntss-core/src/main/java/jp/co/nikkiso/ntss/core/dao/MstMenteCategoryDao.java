package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstMenteCategory;
import jp.co.nikkiso.ntss.core.entity.custom.CusMenteCategoryResponse;

/**
 * 検査カテゴリDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstMenteCategoryDao {
  @Select
  List<CusMenteCategoryResponse> selectAllByFacility(String facilityCd, String mainteClass);

  // mod FNSI-No.762 点検項目を複数のレイアウトで使用できるようにするために、定期点検のカテゴリに点検項目を紐づけるようテーブルを修正する 吉 start
  @Select
  List<MstMenteCategory> selectByIdList(List<Long> categoryIdList);
  @Select
  List<MstMenteCategory> selectByIdListOrderCategoryId(List<Long> categoryIdList,String listCategoryOrderId);
  // mod FNSI-No.762 点検項目を複数のレイアウトで使用できるようにするために、定期点検のカテゴリに点検項目を紐づけるようテーブルを修正する  吉 end

  @Select
  List<MstMenteCategory> selectByIdListWithDeleted(List<Long> categoryIdList);

  /* add by quzhinan  2023-02-01 [Trigger]  start */
  @Insert
  int insert(MstMenteCategory mstMenteCategory);

  @Delete
  int delete(MstMenteCategory mstMenteCategory);
  /* add by quzhinan  2023-02-01 [Trigger]  end */
}
