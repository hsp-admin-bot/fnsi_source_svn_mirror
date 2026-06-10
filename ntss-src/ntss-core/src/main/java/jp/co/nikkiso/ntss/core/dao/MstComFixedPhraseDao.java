package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstComFixedPhrase;

@ConfigAutowireable
@Dao
public interface MstComFixedPhraseDao {
  @Select
  List<MstComFixedPhrase> selectAll(SelectOptions options, MstComFixedPhrase params);

}
