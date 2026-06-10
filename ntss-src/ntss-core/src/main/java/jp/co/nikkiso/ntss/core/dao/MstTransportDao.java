package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstTransport;

@ConfigAutowireable
@Dao
public interface MstTransportDao {
  @Select
  List<MstTransport> selectAll(SelectOptions options, MstTransport params);

  /**
   * 搬送区分マスタ取得，包含删除
   * @param options
   * @param params
   * @return
   */
  @Select
  List<MstTransport> selectAllIncludeDel(SelectOptions options, MstTransport params);

  @Select
  Integer selectByInHospitalCd1(String facilityCd, String inHospitalCd1);
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
  @Select
  List<MstTransport> selectAllName(List<Integer> transportCds);
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end

}
