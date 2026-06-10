package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatHistoryInfo;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.PatNameIdentification;
import jp.co.nikkiso.ntss.core.entity.custom.PatientInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PublicPatientInfo;
import jp.co.nikkiso.ntss.core.entity.custom.ReceivedPatientInfo;

@ConfigAutowireable
@Dao
public interface PatNameIdentificationDao {

    @Select
    List<Long> selectInfoPatReadOnlyLst(List<String> lstFacility_cd);

    @Select
    List<PatientInfo> selectPatInfoPublic(List<Long> lstPatInfo, List<String> lstFacility_cd);

    @Select
    List<PatientInfo> selectReceivedPatientList(List<Long> lstPatInfo, String loginFacilityCd);

    @Select
    List<PatientInfo> selectNotReceivePatientList(String loginFacilityCd);

    @Select
    List<PublicPatientInfo> selectDstFacilities(String facility_cd_src, Long pat_id_src);

    @Select
    List<ReceivedPatientInfo> selectSrcFacilities(String facility_cd_dst, Long pat_id_dst);

    @Select
    List<ReceivedPatientInfo> selectSrcFacilitiesByPatIdSrc(String facility_cd_dst, Long pat_id_src);

    @Insert(sqlFile = true)
    int insert(PatNameIdentification patNameIdentification);

    @Update(sqlFile = true)
    int updateForDst(PublicPatientInfo publicPatientInfo);

    //add FNSI-削除ボタンがクリックできないバグを修正します 江 start
    @Update(sqlFile = true)
    int deleteForDst(List<Long> patNameIds);
    //add FNSI-削除ボタンがクリックできないバグを修正します 江 end

    @Update(sqlFile = true)
    int updateForSrc(ReceivedPatientInfo receivedPatientInfo);

    /*
     * Check query on database and then return the number of patients which is
     * received or approved
     */
    @Select
    Integer selectCountPatNotReceived(String facility_cd);

    /*
     * Check query on database and then return the number of patients which is
     * received or approved
     */
    @Select
    Integer selectCountPatNotApprove(String facility_cd);

    @Select
    List<PatNameIdentification> getListPatIdSrcFromPatDst(Long pat_id_dst);
    @Select
    List<Long> getListPatIdSrcFromListPatDst(List<Long> pat_id_dst);

    /*
     * 承認済み患者IDのリスト
     */
    @Select
    List<String> getListFacilityCdDstApproved(Long pat_id_src);

    /*
     * 患者情報共有解除のため、承認フラグを更新
     */
    @Update(sqlFile = true)
    int updateApproveByFacilityCdSrc(List<String> facilityCdList, String updateData);

    /*
     * 患者情報共有解除のため、受理フラグを更新
     */
    @Update(sqlFile = true)
    int updateReceiveByFacilityCdDst(List<String> facilityCdList, String updateData);

  // add #12462 クエリ共有テーブル情報 患者情報共有 zrx start
  @Select
  List<PatNameIdentification> getListPatIdSrcFromPatTo(Long pat_id_dst);

  @Select
  List<OrdMain> findOrdMainByDateCdSharingInfo(String facility_cd, Long pat_id, String dialysis_date_from,
                                               String dialysis_date_to, List<Integer> weeksArry);

  @Select
  List<PatHistoryInfo> getHospitalByIdList(List<String> pat_id_src);

  @Select
  List<PatNameIdentification> getListPatIdSrcFromPatDstAndId(Long pat_id_dst,String facility_cd_src);

  @Select
  List<Long> getListPatIdSrcFromListPatTo(List<Long> pat_id_dst);
  // add #12462 クエリ共有テーブル情報 患者情報共有 zrx end
}

