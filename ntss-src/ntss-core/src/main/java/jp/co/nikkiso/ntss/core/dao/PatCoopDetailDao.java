package jp.co.nikkiso.ntss.core.dao;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.PatCoopDetail;

@ConfigAutowireable
@Dao
public interface PatCoopDetailDao {
  @Select
  PatCoopDetail selectById(Long coopSaveNo);

  @Select
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  PatCoopDetail selectByPatId(Long patId, String facilityCd);
  PatCoopDetail selectByPatId(Long patId, String facilityCd, String coopVersion);
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

  @Insert
  int insert(PatCoopDetail param);

  @Update(excludeNull = true)
  int update(PatCoopDetail param);
}
