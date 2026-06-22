package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MntMNoticeManage;

/**
 * 緊急発報管理のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MntMNoticeManageDao {

  @Select
  List<MntMNoticeManage> selectAll();

  @Select
  MntMNoticeManage selectByManageNo(Long mNoticeManageNo);

  @Insert
  int insert(MntMNoticeManage mntMNoticeManage);

  @Delete
  int delete(MntMNoticeManage mntMNoticeManage);

  @Update
  int update(MntMNoticeManage mntMNoticeManage);
  
}
