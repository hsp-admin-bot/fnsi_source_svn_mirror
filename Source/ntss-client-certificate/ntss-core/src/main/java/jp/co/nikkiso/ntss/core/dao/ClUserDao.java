package jp.co.nikkiso.ntss.core.dao;

import java.sql.Timestamp;
import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import jp.co.nikkiso.ntss.core.config.ConfigAutowireableCertificateDb;
import jp.co.nikkiso.ntss.core.entity.ClUser;
import org.seasar.doma.jdbc.SelectOptions;
@ConfigAutowireableCertificateDb
@Dao
public interface ClUserDao {

  @Select
  List<ClUser> selectAllUser(SelectOptions options);

  @Update(sqlFile = true)
  int updateUser(long id, String userName, String userRole, String userPass, String departmentCd, Timestamp upDate);

  @Update(sqlFile = true)
  int updateUserNoPass(long id, String userName, String userRole, String departmentCd, Timestamp upDate);

  @Update(sqlFile = true)
  int deleteUser(String userId);

  @Select
  ClUser selectById(String userId);

  @Insert(sqlFile = true)
  int insertUser(String userId, String userName, String userRole, Timestamp regDate, Timestamp upDate, String userPass,
      String departmentCd, int numLoginAttempt);

  @Update(sqlFile = true)
  int updateNumLoginAttempt(String userId, int numLoginAttempt);
}