package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstUrlLinkRegister;


@ConfigAutowireable
@Dao
public interface MstUrlLinkRegisterDao {

  /**
   * 外部リンク登録マスタを取得する
   * @param facilityCd 施設コード
   * @return 外部リンクリスト
   */
  @Select
  List<MstUrlLinkRegister> selectAll(String facilityCd);

}
