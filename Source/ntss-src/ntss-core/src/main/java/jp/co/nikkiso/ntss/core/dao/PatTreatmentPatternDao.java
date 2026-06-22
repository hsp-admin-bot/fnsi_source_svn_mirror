package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import jp.co.nikkiso.ntss.core.dto.OrdMain.OrdMainCrudDto;
import jp.co.nikkiso.ntss.core.dto.pattreatmentpattern.EditDto;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.OrdMainOnly;
import jp.co.nikkiso.ntss.core.entity.PatTreatmentPattern;
import jp.co.nikkiso.ntss.core.entity.PatTreatmentPatternExtends;
import jp.co.nikkiso.ntss.core.entity.PatTreatmentPatternMstKur;
import jp.co.nikkiso.ntss.core.entity.TreatmentInstanceSourceDto;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.custom.PatTreatmentPatternPatMain;
import jp.co.nikkiso.ntss.core.entity.custom.PatTreatmentPatternIndIndCommentInfo;


@ConfigAutowireable
@Dao
public interface PatTreatmentPatternDao {
  @Select
  List<PatTreatmentPattern> selectBySearchInfo(Long pat_id, String facility_cd, List<Integer> ind_treatment_cd, List<Long> ind_kur_cd, List<Integer> week_pattern);

  @Select
  Long selectNextCtlNoById(Long pat_id);

  @Insert(sqlFile = true)
  int insert(PatTreatmentPattern pat);

  @Update(sqlFile = true)
  int deleteBySearchInfo(Long pat_id, Long ctl_no, String facility_cd, List<Integer> ind_treatment_cd, List<Long> ind_kur_cd, List<Integer> treat_week_list);

  @Update(sqlFile = true)
  int updateIndTareAndOffWaterByWeek(String ind_tare_info, String ind_off_water_info, Long pat_id, String facility_cd, Integer treat_week);

  @Update(sqlFile = true)
  int updateById(Long pat_id, Long ctl_no, PatTreatmentPattern pat);

  //upd by ztc 2023-02-23 [Optimize runtime No.5482] --start /
  @Update(sqlFile = true)
  int updateByIdList(List<PatTreatmentPattern> patList);
  //upd by ztc 2023-02-23 [Optimize runtime No.5482] --end /

  // add 9664 by kangjie 20240425 start
  @Update(sqlFile = true)
  int updateNewPatternSteps( List<PatTreatmentPattern> mergeFluidList);
  // add 9664 by kangjie 20240425 end

  @Select
  Long selectCountByPatId(Long pat_id);

  @Select
  List<PatTreatmentPatternPatMain> selectByFacilityCdWithPatMain(String facility_cd);

  @Select
  List<PatTreatmentPattern> selectByPatIdList(List<Long> patIdList, String facilityCd);

  @Select
  /**
   * 患者情報.スケジュール延長最終日が、引数で指定した日付より過去日で指定されている患者の患者治療パターン情報を取得
   * @param sch_ext_end_date 検索対象のスケジュール延長最終日
   * @return
   */
  List<PatTreatmentPatternPatMain> selectBySchExtEndDate(String sch_ext_end_date);

  @Select
  /**
   * 患者情報.スケジュール延長最終日が、引数で指定した日付より過去日で指定されている患者の患者治療パターン情報を取得
   * @param sch_ext_end_date 検索対象のスケジュール延長最終日
   * @return
   */
  List<PatTreatmentPatternPatMain> selectBySchExtEndDateAndFacilityCode(String sch_ext_end_date,String facility_cd);

  @Select
  List<PatTreatmentPatternPatMain> selectByFacilityCodeAndSchExtEndDate(String facility_cd, String sch_ext_end_date);

  // add #11731_【因島：改良】指示コメント番号の指定方法 start
  /**
   * 指示コメント情報（指示コメント番号で集約）の取得
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @param weeks 治療曜日リスト
   * @param treats 治療方法コード
   * @param kurs クールリスト
   * @return 指示コメント情報（指示コメント番号で集約）したリスト
   */
  @Select
  List<PatTreatmentPatternIndIndCommentInfo> selectIndIndCommentInfo(Long patId, String facilityCd, List<Integer> weeks, List<Integer> treats, List<Long> kurs);
  // add #11731_【因島：改良】指示コメント番号の指定方法 end

//add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s start
  /**
   * 患者IDリストのオーダーを取得する
   * @param facilityCd 施設コード
   * @param treats 治療方法コード
   */
  @Select
  List<PatTreatmentPattern> selectByTreatmentCd(String facility_cd ,Integer ind_treatment_cd);

  @Update(sqlFile = true)
  int updateIndCondInfoWithTreatCondSetting(Integer ind_treatment_cd, String toAddTreatCond, List<String> toDeleteTreatCondList);

  @Update(sqlFile = true)
  int updateIndCondInfo(Long pat_id, Long ctl_no, String toAddTreatCond, List<String> toDeleteTreatCondList);
  // add 9664 by kangjie 20231208 start

  @Update(sqlFile = true)
  int updatePatTreatmentPatternByPatIdsAFBF(OrdMainOnly ord, String facilityCd, Integer code);

  @Update(sqlFile = true)
  int updatePatTreatmentPatternByPatIdsECUM(OrdMainOnly ord,String facilityCd, Integer code);

  @Update(sqlFile = true)
  int updatePatTreatmentPatternByPatIdsHDF(OrdMainOnly ord,String facilityCd, Integer code);


  @Update(sqlFile = true)
  int updatePatTreatmentPatternByPatIdsHD(OrdMainOnly ord,String facilityCd, Integer code);

  @Update(sqlFile = true)
  int updatePatTreatmentPatternByPatIdsHF(OrdMainOnly ord,String facilityCd, Integer code);

  @Update(sqlFile = true)
  int updatePatTreatmentPatternByPatIdsIHDF(OrdMainOnly ord,String facilityCd, Integer code);

  @Update(sqlFile = true)
  int updatePatTreatmentPatternByPatIdsOHDF(OrdMainOnly ord,String facilityCd, Integer code);

  @Update(sqlFile = true)
  int updatePatTreatmentPatternByPatIdsOHF(OrdMainOnly ord,String facilityCd, Integer code);

  @Update(sqlFile = true)
  int updatePatTreatmentPatternByPatIdsPURIFICATION(OrdMainOnly ord,String facilityCd, Integer code);
  // add 9664 by kangjie 20231208 end
//add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s end
  // add 9281 日次処理にて正しくスケジュールが作成されない事がある 関 start
  @Update(sqlFile = true)
  int updateByIdListWithTreatCondSetting(List<PatTreatmentPattern> patList);
  // add 9281 日次処理にて正しくスケジュールが作成されない事がある 関 end

  //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
  @Insert(sqlFile = true)
  int batchInsert(List<PatTreatmentPattern> patTreatmentPatternList);

  @Select
  List<PatTreatmentPatternMstKur> checkAllChangedPattern(String facilityCd);

  @Update(sqlFile = true)
  int resetKurCdToZero(String facilityCd, List<PatTreatmentPatternMstKur> changedPatternList, Long userId, Long updUserId);

  @Select
  List<PatTreatmentPatternExtends> getAllInRangeData(String facilityCd);
  //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end

  // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240306 ztc start
  @Select
  List<PatTreatmentPattern> getDataByPatIdAndTreatWeek(String facilityCd, Long patId);
  // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240306 ztc end

  // #10443 Add Start
  @Update(sqlFile = true)
  int updateTargetWeightByPhyicalInfo(String facilityCd, Long patId, String targetWeight);
  // #10443 Add Start

  //add 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) start
  @Update(sqlFile = true)
  int updatePatTreatmentPatternBedCdZeroForWeekChange(String facilityCd, Long patId, String updateMode,List<Integer> treatWeekList,
                                                      List<Integer> indTreatmentCdList, List<Long> indKurCdList);
  //add 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) end

  //add 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) zkm start
  @Update(sqlFile = true)
  int updatePatTreatmentPatternBedCdZeroByCtlNoList(String facilityCd, Long patId, List<Long> ctlNoList);
  //add 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) zkm end
  // add 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる 関 start
  @Select
  List<PatTreatmentPatternPatMain> selectByTreatmentCdAndTreatWeek(String facilityCd, Long patId, List<Integer> indTreatmentCdList, List<Integer> treatWeekList, List<Long> indKurCdList);

  @Update(sqlFile = true)
  int updatePatTreatmentPatternBedCdZeroForTreatMethod(String facilityCd, Long patId, String updateMode, List<Long> ctlNoList);
  // add 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる 関 end

  //add #10901 死亡患者受信時処理について 20241231 zrx start
  @Select
  List<PatTreatmentPattern> deletePatTreatmentPatternByPatIdList(String facilityCd, List<Long> patIdList);
  //add #10901 死亡患者受信時処理について 20241231 zrx end
  // add #12249 治療条件変更の高速化 zkm start
  @Select
  List<PatTreatmentPattern> bulkUpdateIndCondInfo(String facilityCd, Long patId, List<Integer> weeks,
                                                  List<Integer> treats, List<Long> kurs, String checkBoxFlg, String indTreatCondIvMode, String changeIndCondInfo,
                                                  String answerFlg, String accountItemCd, String quantityBefore, String quantityAfter);
  @Select
  List<PatTreatmentPattern> bulkInsert(String facilityCd, Long patId, EditDto dto);
  @Select
  List<PatTreatmentPattern> bulkUpdate(String facilityCd, Long patId, List<Integer> weeks,
                                       List<Integer> treats, List<Long> kurs, EditDto dto);
  @Select
  List<PatTreatmentPattern> bulkDelete(String facilityCd, Long patId, List<Integer> indTreatmentCds, List<Long> indKurCds, List<Integer> treatWeeks);
  // add #12249 治療条件変更の高速化 zkm end
  // add #11716 曜日パターン変更の不正 関 start

  @Select
  List<TreatmentInstanceSourceDto> selectPatTreatmentPatternMoveTargetList(String facilityCd, Long patId, Integer treatmentCd, List<Integer> patternBedList);
  // add #11716 曜日パターン変更の不正 関 end
  // mod #12472 治療方法の変更で補液なし治療からオンライン補液あり治療に、「治療方法のみ」で変更するとpat_treatment_patternに欠損データが発生する。 関 start
  @Select
  List<PatTreatmentPattern> updatePatTreatmentPatternTreatmentMethodOnly(String facilityCd, Long patId, List<Integer> weeks,
                                                                         List<Integer> treats, List<Long> kurs, Integer treatmentCd, MstPersonalUser indUser, MstPersonalUser updUser);
  @Select
  PatTreatmentPattern createPatTreatmentPatternFromMstTreatmentSet(String userInfo, OrdMainCrudDto dto);
  // mod #12472 治療方法の変更で補液なし治療からオンライン補液あり治療に、「治療方法のみ」で変更するとpat_treatment_patternに欠損データが発生する。 関 end
}
