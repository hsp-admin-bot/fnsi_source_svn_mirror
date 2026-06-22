package jp.co.nikkiso.ntss.core.dao;

import org.seasar.doma.Dao;

import jp.co.nikkiso.ntss.core.config.ConfigAutowireableAuthDb;

/**
 * データベース共通処理のDB4用インタフェース。
 *
 * @see MntFacilityCancelStatDao
 */
@ConfigAutowireableAuthDb
@Dao
public interface MntFacilityCancelStatAuthDao extends MntFacilityCancelStatDao {
  // このインタフェースは独自のクエリAPIを持たない。
}
