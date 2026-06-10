package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.SysFacility;
import jp.co.nikkiso.ntss.core.entity.custom.SysFacilityData;
import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import java.util.List;

/**
 * 全施設マスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface SysFacilityDao {

  //add by ztc 2023-03-01 [Optimize runtime No.8372] --start /
  @Select
  List<SysFacilityData> selectJoinSysPrefByLimitAndOffset(Integer limit, Integer offsetIer, String prefCd, String freeWord, List<String> selectedInsCdList);
  //add by ztc 2023-03-01 [Optimize runtime No.8372] --end /


  @Insert(sqlFile = true)
  int insert(SysFacility sysFacility);

  @Delete
  int delete(SysFacility sysFacility);

  @Update(sqlFile = true)
  int update(SysFacility sysFacility);

  @Delete(sqlFile = true)
  int deleteByCd(String medicalInstitutionCd);
  /*add FNSI-改修内容患者イベント外结No.7 任 start*/
  @Select
  List<SysFacility> getFacilityNameByCd();
  /*add FNSI-改修内容患者イベント外结No.7 任 end*/

  /*
   * 施設マスタのパラメータ指定による検索
   */
  @Select
  List<SysFacility> selectBySearchConditions(String prefecturesCd, String keyword, Integer limit, Integer page);

  //No.7167 upd Paging Optimization runtime by ztc start
  @Select
  List<SysFacility> getSysFacilityByMedicalInstitutionCd(List<String> medicalInstitutionCds);
  //No.7167 upd Paging Optimization runtime by ztc end

  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
  @Select
  List<SysFacility> selectAllName(List<String> medicalInstitutionCds);
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end

  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 start
  @Select
  List<SysFacility> selectAllForCdAndName();
  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 end

  // add #10988 データ項目「処方.処方箋情報.QRコード」を追加　V1.1A 吉 start
  @Select
  SysFacility getSysFacilityByFacilityCd(String facilityCd);
  // add #10988 データ項目「処方.処方箋情報.QRコード」を追加　V1.1A 吉 end

  /* add by chamaojia 2025-05-21 [11871] --start */
  // iPhone側のメモリが大きいためにシステムが登録されている問題を処理する、新しいインタフェース
  @Select
  SysFacility getSysFacilityByCd(String medicalInstitutionCds);
  @Select
  List<SysFacility> getSysFacilityByCdList(List<String> cdList);
  /* add by chamaojia 2025-05-21 [11871] --end */
}
