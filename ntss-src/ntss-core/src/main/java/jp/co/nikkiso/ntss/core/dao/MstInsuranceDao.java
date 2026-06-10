package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MstInsurance;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import java.util.List;


@ConfigAutowireable
@Dao
public interface MstInsuranceDao {

  @Select
  List<MstInsurance> selectAll();
}

