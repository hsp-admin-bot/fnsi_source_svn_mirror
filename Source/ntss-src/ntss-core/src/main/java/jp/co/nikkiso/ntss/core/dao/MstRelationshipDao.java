package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import java.util.Map;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstRelationship;

@ConfigAutowireable
@Dao
public interface MstRelationshipDao extends MasterDao<Map<String, Object>> {
  @Select
  List<Map<String, Object>> selectAllStatus(Map<String, String> params);

  @Select
  List<MstRelationship> selectAll(SelectOptions options, MstRelationship params);


  /**
   *  続柄マスタ取得，包含删除
   * @param options
   * @param params
   * @return
   */
  @Select
  List<MstRelationship> selectAllIncludeDel(SelectOptions options, MstRelationship params);

  @Select
  Integer selectByInHospitalCd1(String facilityCd, String inHospitalCd1);

  // add FNSI-共有された患者情報作成を見直し 江 start
  @Select
  List<MstRelationship> selectByRelationName(String facilityCd, String relation_name);
  // add FNSI-共有された患者情報作成を見直し 江 end

  // add #10723 続柄マスタのデフォルト。 本田 start
  /**
   * 対象施設の続柄情報を登録
   * 
   * @param facilityCd
   * @return 登録件数
   */
  @Insert(sqlFile = true)
  int insertInitMstForFacility(String facilityCd);

  /**
   * 対象施設の続柄情報を取得
   * 
   * @param facilityCd
   * @return 続柄情報のリスト
   */
  @Select
  List<MstRelationship> getMstRelationshipInfoByFacilityCd(String facilityCd);
  // add #10723 続柄マスタのデフォルト。 本田 end
}
