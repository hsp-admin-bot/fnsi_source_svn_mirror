package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstInfection;

@ConfigAutowireable
@Dao
public interface MstInfectionDao {
  @Select
  List<MstInfection> selectAll(SelectOptions options, MstInfection params);

  @Select
  Integer selectByInHospitalCd1(String facilityCd, String inHospitalCd1);

  @Select
  MstInfection selectByCd(Integer infectionCd);
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou start
  @Select
  List<MstInfection> selectAllInfection();
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou end

  //No.7167 upd Paging Optimization runtime by ztc start
  @Select
  List<MstInfection> getMstInfectionInfoByFacilityCd(String facilityCd);
  //No.7167 upd Paging Optimization runtime by ztc end
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
  @Select
  List<MstInfection> selectAllName(List<Integer> infectionCds);
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end
}
