package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstWard;

@ConfigAutowireable
@Dao
public interface MstWardDao {
  @Select
  List<MstWard> selectAll(SelectOptions options, MstWard params);

  /**
   * 病棟コードを取得,包含删除
   * @param options
   * @param params
   * @return
   */
  @Select
  List<MstWard> selectAllIncludeDel(SelectOptions options, MstWard params);

  /**
   * 病棟コードを指定してすべてのカラムを取得
   * @param wardCd 病棟コード
   * @return
   */
  @Select
  MstWard selectByCd(int wardCd);
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
  @Select
  List<MstWard> selectAllName(List<Integer> wardCds);
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end
}
