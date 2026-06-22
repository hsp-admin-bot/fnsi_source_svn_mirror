package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstMainteLayoutGroupHst;

/**
 * 定期点検機種別レイアウト
 */
@ConfigAutowireable
@Dao
public interface MstMainteLayoutGroupHstDao {

  @Insert(sqlFile = true)
  int insertList(List<MstMainteLayoutGroupHst> mstMainteLayoutGroupHsts);

  // add by ztc 2023-03-07: add trigger logic code  --start
  @Insert
  int insert(MstMainteLayoutGroupHst mstMainteLayoutGroupHst);

  @Insert(sqlFile = true)
  int insertLayoutGroupHst(MstMainteLayoutGroupHst mstMainteLayoutGroupHst);
  // add by ztc 2023-03-07: add trigger logic code  --end
}
