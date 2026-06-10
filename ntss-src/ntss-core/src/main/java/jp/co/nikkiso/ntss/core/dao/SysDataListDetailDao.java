package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import java.util.Map;

import org.seasar.doma.Dao;
import org.seasar.doma.MapKeyNamingType;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.builder.SelectBuilder;

import jp.co.nikkiso.ntss.core.entity.SysDataListDetail;

@ConfigAutowireable
@Dao
public interface SysDataListDetailDao {

  /**
   * カテゴリーリストに該当するデータリスト詳細取得.
   * @param listCategory カテゴリーリスト
   * @return データリスト詳細
   */
  @Select
  List<SysDataListDetail> selectByListCategory(List<Long> listCategory);

  /**
   * データリスト詳細コードに該当するデータリスト詳細取得
   * @param sysDataListDetailCd データリスト詳細コード
   * @return データリスト詳細
   */
  @Select
  SysDataListDetail selectByCd(Long sysDataListDetailCd);

  /**
   * 指定されたselect文を実行.
   * @param selectBuilder select文
   * @return 実行結果
   */
  public default List<Map<String, Object>> executeSql(SelectBuilder selectBuilder) {
    return selectBuilder.getMapResultList(MapKeyNamingType.NONE);
  }
}
