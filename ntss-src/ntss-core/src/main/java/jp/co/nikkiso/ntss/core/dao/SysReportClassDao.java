package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.SysReportClass;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import java.util.List;

/**
 * 帳票種別定義のDaoインタフェース
 */
@ConfigAutowireable
@Dao
public interface SysReportClassDao {

  // add #12125 文字列型の組み合わせが正しく表示されない場合がある limingzhe start
  @Select
  List<SysReportClass> selectSysReportClassAll();
  // add #12125 文字列型の組み合わせが正しく表示されない場合がある limingzhe end

  /**
   * 帳票種別定義データ収集
   * @return 帳票種別定義のリスト
   */
  @Select
  List<SysReportClass> selectAll(int classCd);

}
