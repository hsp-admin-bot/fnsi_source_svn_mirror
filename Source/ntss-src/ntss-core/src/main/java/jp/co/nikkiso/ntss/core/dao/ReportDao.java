package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.custom.Vital;

/**
 * 帳票データ取得用のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface ReportDao {

  /**
   * バイタルチャート用のバイタル情報を取得する.
   * @param ordNo オーダ番号
   * @return バイタル情報のリスト
   */
  @Select
  List<Vital> selectVitalData(Long ordNo);

}
