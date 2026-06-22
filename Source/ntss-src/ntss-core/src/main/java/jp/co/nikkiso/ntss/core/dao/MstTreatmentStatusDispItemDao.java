package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstTreatmentStatusDispItem;

@ConfigAutowireable
@Dao
public interface MstTreatmentStatusDispItemDao {
  /**
   * テーブルの全件取得
   * @return
   */
  @Select
  List<MstTreatmentStatusDispItem> selectAll();

  /**
   * 削除扱いのレコードを除く全件を取得
   * @return
   */
  @Select
  List<MstTreatmentStatusDispItem> selectAllExceptDeleted();

  /**
   * 表示項目番号を指定しレコードを取得
   * @param itemCd
   * @return
   */
  @Select
  MstTreatmentStatusDispItem selectByItemCd(Long itemCd);

  /**
   * 複数の表示項目番号を指定しレコードを取得
   * @param itemCd
   * @return
   */
  @Select
  MstTreatmentStatusDispItem selectByItemCdList(List<Long> itemCdList);
}
