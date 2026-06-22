package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import java.util.Map;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstSeverity;

@ConfigAutowireable
@Dao
public interface MstSeverityDao extends MasterDao<Map<String, Object>> {
  @Select
  List<MstSeverity> selectAll(SelectOptions options, MstSeverity params);

  /**
   * 重症度マスタ取得，包含删除
   * @param options
   * @param params
   * @return
   */
  @Select
  List<MstSeverity> selectAllIncludeDel(SelectOptions options, MstSeverity params);

  @Select
  Integer selectByInHospitalCd1(String facilityCd, String inHospitalCd1);
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
  @Select
  List<MstSeverity> selectAllName(List<Integer> severityCds);
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end

  /**
   * mst-list-compose 用：重症度マスタ（削除済み含む、init を含める）
   */
  @Select
  List<Map<String, Object>> selectAllStatus(Map<String, String> params);

}
