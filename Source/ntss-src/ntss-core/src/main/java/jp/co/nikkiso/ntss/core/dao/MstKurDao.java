package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstKur;

@ConfigAutowireable
@Dao
public interface MstKurDao {
  @Select
  List<MstKur> selectAll(SelectOptions options);

  @Select
  List<MstKur> selectByFacilityCd(SelectOptions options, String facility_cd, String is_del);

// FNSI-修正 マスタ削除の対応 chen add start
  @Select
  List<MstKur> selectByFacilityCdDel(SelectOptions options, String facility_cd);
// FNSI-修正 マスタ削除の対応 chen add end

  @Select
  MstKur selectByKurCd(String kurCd);

  // Add By HandsomeLin At 2023/02/16 Start
  // #6174
  @Select
  List<MstKur> selectByKurCdList(List<String> kurCdList);
  // Add By HandsomeLin At 2023/02/16 End

  @Insert(sqlFile = true)
  int insert(String facility_cd, MstKur mstKur );

  @Update(sqlFile = true)
  int updateByCd(MstKur mstKur );

  @Select
  Integer selectNextSeqKurCd();

  @Select
  String selectByName(String facility_cd);

  /**
   * 特定の時刻が範囲内にあるクールを検索
   * @param facilityCd
   * @param currentTime
   * @return
   */
  @Select
  List<MstKur> selectByTargetTime(String facilityCd, String currentTime);

  // add 2022-01-06 院内コードから本システムコードへの変換の対応 孫 start
  @Select
  List<MstKur> selectByInHospitalCd1(String facilityCd, String inHospitalCd1);
  // add 2022-01-06 院内コードから本システムコードへの変換の対応 孫 end

  @Insert(sqlFile = true)
  int insertByMstSelector(String facility_cd, String master_physical_name, String nowDate);

  @Update(sqlFile = true)
  int updateByMasterPhysicalName(String facility_cd, String master_physical_name, String nowDate);

  /**
   * 削除したクールコードを使用しているind_kur_cdを未登録へ設定
   */
  @Update(sqlFile = true)
  int updateByIndKurCd(List<Long> kurList, String facility_cd, int kur_cd);

  /**
   * 常勤医設定変更
   * @param mstKur
   * @return
   */
  @Update(sqlFile = true)
  int updateDoctorByCd(MstKur mstKur);
  //add 8011 常勤医   ljg start
  /**
   * ind_dial常勤医存在するかどうか
   * @return
   */
//  @Select
//  String  selectDispusercd(String facilityCd, Long ordNo, String key0);

  /**
   * rst_dial常勤医存在するかどうか
   * @return
   */
//  @Select
//  String  selectDispusercdcopy(String facilityCd, Long ordNo, String key0);

//  /**
//   * exam_ord常勤医存在するかどうか
//   * @return
//   */
//  @Select
//  String selectExamordDoctortypeByFacilityCd(String facilityCd, Long ordNo, String key0);
//  //add 8011 常勤医   ljg end

  //add #10901 死亡患者受信時処理について zrx start
  @Select
  String selectStaffByCurrentTimeAndFacilityCd(String facilityCd);
  //add #10901 死亡患者受信時処理について zrx end
}
