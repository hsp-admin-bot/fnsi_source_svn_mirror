package jp.co.nikkiso.ntss.core.dao;

import org.seasar.doma.Dao;
import org.seasar.doma.boot.ConfigAutowireable;

/**
 * データベース共通処理のDB5用インタフェース。
 *
 * @see MntFacilityCancelStatDao
 */
@ConfigAutowireable
@Dao
public interface MntFacilityCancelStatDefaultDao extends MntFacilityCancelStatDao {
  // このインタフェースは独自のクエリAPIを持たない。
}
