package jp.co.nikkiso.ntss.core.dao;

import org.seasar.doma.Dao;

import jp.co.nikkiso.ntss.core.config.ConfigAutowireablePersonalDb;

/**
 * データベース共通処理のDB6用インタフェース。
 *
 * @see MntFacilityCancelStatDao
 */
@ConfigAutowireablePersonalDb
@Dao
public interface MntFacilityCancelStatPersonalDao extends MntFacilityCancelStatDao {
  // このインタフェースは独自のクエリAPIを持たない。
}
