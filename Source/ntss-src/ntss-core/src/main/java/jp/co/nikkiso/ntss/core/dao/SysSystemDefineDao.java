package jp.co.nikkiso.ntss.core.dao;

import java.math.BigDecimal;
import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;

/**
 * システム設定マスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface SysSystemDefineDao {

  @Select
  List<SysSystemDefine> selectAll();
  
  @Select
  SysSystemDefine selectByFacilityCd(String facilityCd);
  
  @Select
  SysSystemDefine selectDefaultMail();
  
  @Select
  String selectNoticeMailAddress();
  
  @Select
  List<SysSystemDefine> selectByCtlNo(int ctlNo);

  @Insert
  int insert(SysSystemDefine sysSystemDefine);

  @Delete
  int delete(SysSystemDefine sysSystemDefine);

  @Update
  int update(SysSystemDefine sysSystemDefine);
  
  @Select
  SysSystemDefine selectByPrimaryKey(String facilityCd, BigDecimal ctlNo);

  @Update(sqlFile = true)
  int updateDefine(SysSystemDefine param);
  @Insert(sqlFile = true)
  int insertDefine(SysSystemDefine param);
  
  @Select
  SysSystemDefine selectByCtlNoAndServiceCd(int ctlNo, String serviceCd);

  @Select
  SysSystemDefine selectOnPremise(int ctlNo);
}
