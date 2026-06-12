package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import java.util.Map;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import jp.co.nikkiso.ntss.core.config.ConfigAutowireablePersonalDb;

/**
 * 所有患者選択（車いすマスタ詳細用）の簡易患者一覧 Dao.
 */
@ConfigAutowireablePersonalDb
@Dao
public interface MstPatPersonalSimpleDao extends MasterDao<Map<String, Object>> {

  @Override
  @Select
  List<Map<String, Object>> selectAllStatus(Map<String, String> params);
}

