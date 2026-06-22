package jp.co.nikkiso.ntss.core.dao;

import java.sql.Timestamp;
import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MntFacilityCancelManage;

/**
 * 施設解約管理Dao
 *
 */
@ConfigAutowireable
@Dao
public interface MntFacilityCancelManageDao {

  @Insert
  int insert(MntFacilityCancelManage entity);

  @Select
  List<MntFacilityCancelManage> select(List<String> statusList, List<String> procClass, Timestamp now);

  @Select
  MntFacilityCancelManage selectByCtlNo(Long ctlNo);

  @Select
  MntFacilityCancelManage selectByFacilityCd(String facilityCd, String procClass);

  @Select
  List<MntFacilityCancelManage> selectByFacilityCdProcClass(String facilityCd, String procClass);

  @Select
  MntFacilityCancelManage selectByFacilityCdProcClassList(String facilityCd, List<String> lstProcClass);

  @Select
  MntFacilityCancelManage selectById(Long ctlNo);

  @Select
  List<MntFacilityCancelManage> selectByProcClass();

  @Update(sqlFile = true)
  int updateProcStatus(Long ctlNo, String procStatus, String isDel);

  @Update(excludeNull = true)
  int update(MntFacilityCancelManage entity);

  @Delete(sqlFile = true)
  int deleteById(Long ctlNo);

  @Delete(sqlFile = true)
  int deleteByFacilityCd(String facilityCd);

  @Select
  MntFacilityCancelManage selectByDownloadRequirement(String facilityCd, String baseDate, String procClass);

  @Update(include = {"isDel", "isDisp"})
  int updateIsDispIsDel(MntFacilityCancelManage mstUser);
//  add FNSI redmine 6143修正 任 start
  @Select
  List<String> getFacilityCd();
//  add FNSI redmine 6143修正 任 end
}
