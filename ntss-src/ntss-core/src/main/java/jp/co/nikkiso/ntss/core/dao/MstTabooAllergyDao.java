package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import java.util.Map;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstTabooAllergy;

@ConfigAutowireable
@Dao
public interface MstTabooAllergyDao extends MasterDao<Map<String, Object>> {
  @Select
  List<Map<String, Object>> selectAllStatus(Map<String, String> params);

  @Select
  List<MstTabooAllergy> selectAll(SelectOptions options, MstTabooAllergy params);

  @Select
  Integer selectByInHospitalCd1(String facilityCd, String inHospitalCd1);

  @Select
  List<MstTabooAllergy> selectAllIncludeDeleted(SelectOptions options, MstTabooAllergy params);
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou start
  @Select
  List<MstTabooAllergy> selectAllTabooAllergy();
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou end

  //No.7167 upd Paging Optimization runtime by ztc start
  @Select
  List<MstTabooAllergy> getMstTabooAllergyInfoByFacilityCd(String facilityCd);
  //No.7167 upd Paging Optimization runtime by ztc end

  /* add by chamaojia 2026-03-27 [12462] 患者情報共有->患者経過総合ビューア --start */
  @Select
  List<MstTabooAllergy> getMstTabooAllergyInfoByCds(List<String> tabooAllergyCds);
  /* add by chamaojia 2026-03-27 [12462] 患者情報共有->患者経過総合ビューア --end */

}
