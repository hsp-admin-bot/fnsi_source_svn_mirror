package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import java.util.Map;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;

import jp.co.nikkiso.ntss.core.config.ConfigAutowireablePersonalDb;



@ConfigAutowireablePersonalDb
@Dao
public interface DBAppWebAPIUserDao {
  
  @Select
  List<Map<String,Object>> selectNamesFromPatPersonalMain(
                    List<String> facilityCdList ,
                    List<Long> userIdList,
                    boolean cryptoFlag
              );

}

