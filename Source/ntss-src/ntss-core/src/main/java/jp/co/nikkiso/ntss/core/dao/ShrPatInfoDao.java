package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.PatInsuranceConditionsSharing;
import jp.co.nikkiso.ntss.core.entity.PatientFacilityInfo;
import jp.co.nikkiso.ntss.core.entity.PatientShareCount;
import jp.co.nikkiso.ntss.core.entity.ShrPatInfo;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import java.util.List;

@ConfigAutowireable
@Dao
public interface ShrPatInfoDao {

  /**
   * 当院患者ID取得
   * @param patInsuranceConditionsSharing
   * @return
   */
  @Select
  List<PatientFacilityInfo> getAllHospitalPatientIds(PatInsuranceConditionsSharing patInsuranceConditionsSharing);

  /**
   * 共有先数
   * @param hospitalCd
   * @return
   */
  @Select
  List<PatientShareCount> selectShareFromCounts(String hospitalCd);

  /**
   * 共有元数
   * @param hospitalCd
   * @return
   */
  @Select
  List<PatientShareCount> selectShareToCounts(String hospitalCd);

  /**
   * 未完の回数
   */
  @Select
  List<PatientShareCount> selectPendingCounts(String hospitalCd,List<Long> patientIds);

  /**
   *
   * @param patId
   * @returnPatientShareCount
   */
  @Select
  List<ShrPatInfo> selectShrPatInfoSource(Long patId,String facilityCd);

  /**
   *
   * @param patId
   * @return
   */
  @Select
  List<ShrPatInfo> selectShrPatInfoReceive(Long patId,String facilityCd);

  @Select
  ShrPatInfo selectShrPatInfoByShrPatInfoId(Long shrPatInfoId);

  /**
   * 新規登録
   */
  @Insert
  int insert(ShrPatInfo shrPatInfo);

  /**
   * 条件付き更新
   */
  @Update(sqlFile = true)
  int update(ShrPatInfo shrPatInfo);

  /**
   * 条件付き更新
   */
  @Update(sqlFile = true)
  int updateAttachment(String shrAttachment,Long shrPatInfoId);

  /**
   * 削除
   * @param shrPatInfoId
   */
  @Update(sqlFile = true)
  int deleteShrPatInfo(Long shrPatInfoId);

  @Select
  List<PatientShareCount> selectProhibitedCounts(String hospitalCd, List<Long> patientIds);
  // add #12462 患者情報共有 zhao start
  /**
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @return ShrPatInfo 共有情報
   */
  @Select
  List<ShrPatInfo> selectShrPatInfoByPatId(Long patId,String facilityCd);
  // add #12462 患者情報共有 zhao end

  /**
   * 患者IDに紐づく施設コード一覧を取得（共有元・共有先の両方を含む）.
   * @param patId 患者ID
   * @return 施設コードリスト
   */
  @Select
  List<String> selectFacilityCdsByPatId(Long patId);
}
