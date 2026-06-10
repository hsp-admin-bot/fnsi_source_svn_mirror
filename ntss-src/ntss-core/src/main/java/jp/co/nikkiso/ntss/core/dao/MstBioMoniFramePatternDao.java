package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstBioMoniFramePattern;
import jp.co.nikkiso.ntss.core.entity.custom.MstBioMoniFramePatternWithDefine;

/**
 * 設定のDaoインタフェース
 */
@ConfigAutowireable
@Dao
public interface MstBioMoniFramePatternDao {

  @Select
  List<MstBioMoniFramePattern> selectAll(String facility_cd);
  @Select
  MstBioMoniFramePattern selectByCtlNo(String facility_cd, int ctl_no);
  @Select
  String selectDefineInfo(String facility_cd, int ctl_no);
  @Select
  List<MstBioMoniFramePatternWithDefine> selectWithFrameDefine(String facility_cd, int ctl_no);
  
  @Delete
  int delete(MstBioMoniFramePattern mstBioMoniFramePattern);
  
  @Update(sqlFile = true)
  int updatePattern(MstBioMoniFramePattern param);
  @Insert(sqlFile = true)
  int insertPattern(MstBioMoniFramePattern param);
}
