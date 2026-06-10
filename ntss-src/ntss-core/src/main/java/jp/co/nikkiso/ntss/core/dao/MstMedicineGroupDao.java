package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstMedicineGroup;

@ConfigAutowireable
@Dao
public interface MstMedicineGroupDao {
  @Select
  List<MstMedicineGroup> selectAll(SelectOptions options, MstMedicineGroup params);

  // add 投薬支援マスタ 削除されたデータの処理 孔 start
  /**
   * 削除済みを含むすべての調整薬剤リストを取得する
   * @param options 検索オプション
   * @param params 施設コードを指定するパラメータ
   * @return
   */
  @Select
  List<MstMedicineGroup> selectAllIncludeDeleted(SelectOptions options, MstMedicineGroup params);
  // add 投薬支援マスタ 削除されたデータの処理 孔 end
}
