package jp.co.nikkiso.ntss.core.dao;

import com.google.common.base.Strings;
import jp.co.nikkiso.ntss.core.dto.FacilitySettingNo.FacilitySettingNoDisplayOrder;
import jp.co.nikkiso.ntss.core.dto.OrdMain.OrdMainCrudDto;
import jp.co.nikkiso.ntss.core.dto.OrdMain.OrdMainMedicineDelete;
import jp.co.nikkiso.ntss.core.dto.OrdMain.OrdMainRequest;
import jp.co.nikkiso.ntss.core.dto.OrdMain.OrdMainWithlastWeightAfter;
import jp.co.nikkiso.ntss.core.dto.OrdMain.OrdNoTreatDateCopyDto;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.OrdMainDetailedConditions;
import jp.co.nikkiso.ntss.core.dto.patUnique.OrdMainForUpdTargetWeightDTO;
import jp.co.nikkiso.ntss.core.entity.*;
import jp.co.nikkiso.ntss.core.entity.custom.AdditionInfoOrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.MstEquipmentMstMedicine;
import jp.co.nikkiso.ntss.core.entity.custom.OrdAdditionInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainBedAndKur;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForAcceptanceStatusInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForCheckListSchedule;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForDeviceSetInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForExamRecord;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForNotAssignedSchedule;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForPatList;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForScheduleAssignment;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForWeightInd;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForWeightModal;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForWeightNextSchedule;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForWeightSchedule;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainIndIndCommentInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainKurAndTreatmentList;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainKurBed;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainLatelyWeightInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainListInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainPatEventRecCombo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainPatObsRecCombo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainTreatDate;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainUpdateForScheduleAssignment;
import jp.co.nikkiso.ntss.core.entity.custom.OrdWeightScaleBuildInfo;
import jp.co.nikkiso.ntss.core.entity.custom.TemplateHospitalCd;
import jp.co.nikkiso.ntss.core.entity.custom.TemplateMachine;
import jp.co.nikkiso.ntss.core.entity.custom.TemplateMedicine;
import jp.co.nikkiso.ntss.core.entity.custom.TemplateMonitor;
import jp.co.nikkiso.ntss.core.entity.custom.TemplateOrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.TreatmentStatusList;
import jp.co.nikkiso.ntss.core.entity.custom.WeekChangeInfo;
import jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar.ItemFacilityCalendar;
import jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar.NumberTreatmentsByCourse;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq32;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq36;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq38;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq41;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq42;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq51;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq52;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq53;
import org.seasar.doma.BatchUpdate;
import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Suppress;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.Result;
import org.seasar.doma.jdbc.SelectOptions;
import org.seasar.doma.jdbc.builder.SelectBuilder;
import org.seasar.doma.message.Message;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.sql.Timestamp;
import java.util.List;
import java.util.Map;
import java.util.Optional;
@ConfigAutowireable
@Dao
public interface OrdMainDao {
  //add 7311 新規に作った治療予定の存在しない施設でクールマスタを保存するとフリーズ 関俊楠 start
  @Select
  List<OrdMain> selectOrdMainByFacilityCdCount(String facilityCd);
  //add 7311  新規に作った治療予定の存在しない施設でクールマスタを保存するとフリーズ 関俊楠 end

  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない。 関 start
  @Select
  List<Long> selectOrdNoByRstDialysisState0(String facilityCd);

  @Update(sqlFile = true)
  int updateChecklistCdByOrdNos(List<Long> ordNos, String checklistCd, String facilityCd);
  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない。 関 end

  // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 start
  @Select
  List<TreatmentRecordSetting> selectTreatmentByOrdNo(Long patId);
  // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 end
  @Select
  List<OrdMain> selectAll(SelectOptions options);

  // FNSI-投与薬剤の補助画面を追加 周 add start
  @Select
  String selectIndMediInfoHistory(Long patId, String facilityCd, Long mediNo);
  // FNSI-投与薬剤の補助画面を追加 周 add end

  // add 10787 投与薬剤の数量を変更すると薬剤が消える。 start
  @Select
  String selectAllIndMediInfo(Long patId, String facilityCd, Long mediNo);
  // add 10787 投与薬剤の数量を変更すると薬剤が消える。 end

  //add FutreNetWeb+SI課題管理No5188対応 呉 start
  @Select
  Long countPatMediniceNo(Long patId, String facilityCd, Long mediNo,List<String> youbi);
  //add FutreNetWeb+SI課題管理No5188対応 呉 end

  @Select
  OrdMain selectByOrdNo(Long ordNo);

  // add FNSI-7217 バッチ操作インターフェイスを追加します 查 start
  @Select
  List<OrdMain> selectListByOrdNo(List<Long> ordNoList);
  // add FNSI-7217 バッチ操作インターフェイスを追加します 查 end

  //add 6410 デグレ：機能帳票から「治療経過表」が消えている 吉 start
  @Select
  OrdMain selectByPatIdAndDate(Long patId,String data, String facilityCd);
  //add 6410 デグレ：機能帳票から「治療経過表」が消えている 吉 end

  //add 7233 zhaoqj 20230413 状況リスト: 機能帳票 [単患者帳票] start
  @Select
  OrdMain selectByPatIdAndDateCondition(Long patId,String data, String facilityCd);
  //add 7233 zhaoqj 20230413 状況リスト: 機能帳票 [単患者帳票] end

  //add 7233 zhaoqj 20230413 検査結果: 機能帳票  start
  @Select
  List<OrdMain> selectByPatIdAndDateFromTo(Long patId,String fromDate,String toDate, String facilityCd);
  //add 7233 zhaoqj 20230413 検査結果: 機能帳票  end

  //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
  @Select
  OrdMain selectOrderByPatId(Long patId,String treatDate,String facilityCd);
  //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
  // add #5984 体重測定 コンテンツを追加する 孟堅 Start
  /***
   * 指定されたひずけ日付のpatidとordNoをしゅとく取得する
   * @param facilityCd 施設コード
   * @param treatDate 治療日
   * @return
   */
  @Select
  List<OrdMain> selectByTreatDateAndFacilityCd(String treatDate,String facilityCd);
  // add #5984 体重測定 コンテンツを追加する 孟堅 end
  // add #5984 連携稼働ビューア コンテンツを追加する 孟堅 Start

  /***
   * してー指定されたきかん期間をちゅーしゅつ抽出する
   * @param patId 患者ID
   * @param startTreatDate 开始治療日
   * @param endTreatDate 结束治療日
   * @param facilityCd 施設コード
   * @return
   */
  @Select
  List<OrdMain> selectByDateQuantumAndFacilityCd(Long patId,String startTreatDate, String endTreatDate,String facilityCd);
  // add #5984 連携稼働ビューア コンテンツを追加する 孟堅 end
  //add 治療状況リスト性能改善 劉 start
  @Select
  List<OrdMain> selectAllByOrdNoList(List<Long> ordNoList);
  //add 治療状況リスト性能改善 劉 end

  // mod #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao start
  //@Select
  //Optional<OrdMain> selectItemByPatId(Long patId);
  @Select
  // mod #12462 患者情報共有 zhao start
  //Optional<OrdMain> selectItemByPatId(Long patId, String treatDate);
  Optional<OrdMain> selectItemByPatId(String facilityCd, Long patId, String treatDate);
  // mod #12462 患者情報共有 zhao end
  // mod #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao end
  //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
  @Select
  Optional<OrdMain> selectNearByPatId(Long patId,String treatDate);
  //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end

  //add #7790 初版確定前の治療実績削除で不要なイベントが登録される 王永吉　start
  @Select
  List<OrdMain> selectRstByOrdNo(Long ordNo);
  //add #7790 初版確定前の治療実績削除で不要なイベントが登録される 王永吉　end

  @Select
  List<OrdMainTreatDate> selectByPatIdAndTreatDate(String facilityCd, Long pat_id, String fromDate, String toDate);

  @Select
  List<OrdMainTreatDate> selectByPatIdAndTreatDateOrdMain(String facilityCd, Long pat_id, String treatDate, String coopCd, String coopCdIndex, String coopVersion, String indTreatmentName);

  @Select
  List<OrdMainTreatDate> selectByPatIdAndTreatDateMediInfo(String facilityCd, Long pat_id, String treatDate, String coopCd, String coopVersion, String indTreatmentName);

  @Select
  List<OrdMain> selectByOrdNoList(List<Long> ordNoList);

  /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
  @Select
  List<OrdMain> selectMstCdByOrdNoList(List<Long> ordNoList);
  /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */

// add データリストの患者情報修正 陳 start
  //mod #12096 データリストにてDWおよび目標体重を登録するとサーバダウン zrx start
//  @Select
//  List<OrdMain> selectByPatIdList(Long patId, String facilityCd);
  @Select
  List<OrdMain> selectByPatIdList(List<Long> patIdList, String facilityCd);
  //mod #12096 データリストにてDWおよび目標体重を登録するとサーバダウン zrx end

  //  mod FNSI redmine 劉祥霖 5923 start
  @Select
  List<String> selectOrdNoByTreatmentCdTreatDateKurCd(Long patId,Integer treatmentCd, String treatDate, Long kurCd);

  @Select
  List<String> selectOrdNoByTreatDateKurCd(Long indBedCd, String treatDate, Long kurCd);
  //  mod FNSI redmine 劉祥霖 5923 end

  // add FNSI redmine 6588 劉祥霖 start
  @Select
  List<String> selectDummyOrdNoByTreatDateKurCdBedCd(Long indBedCd, String treatDate, Long kurCd);
  // add FNSI redmine 6588 劉祥霖 end

  @Select
  String selectMaxIndMediInfoNoNew(Long patId, String facilityCd);
  //  mod FNSI redmine 劉祥霖 5923 start
  @Select
  List<String> selectKurInfo(Long indBedCd, String treatDate);
//  mod FNSI redmine 劉祥霖 5923 end// add データリストの患者情報修正 陳 end

  // add FutreNetWeb+SI課題管理No6227 趙 start
  @Select
  List<OrdMain> selectByPatId(Long patId);
  // add FutreNetWeb+SI課題管理No6227 趙 end

  @Select
  OrdMainForCheckListSchedule selectByOrdNoChecklist(Long ordNo);

  /* add by chamaojia 2023-03-07 [6118] 新規一括クエリー方法  --start */
  @Select
  List<OrdMainForCheckListSchedule> selectByOrdNoListChecklist(List<Long> ordNoList);
  /* add by chamaojia 2023-03-07 [6118] 新規一括クエリー方法  --end */

  @Select
  List<OrdMainForNotAssignedSchedule> selectByOrdMainNotAssigned(String facilityCd, String treatDate, Long bedCd);

  @Select
  OrdMainForScheduleAssignment selectByOrdNoScheduleAssignment(Long ordNo);

  @Select
  List<OrdMain> selectByCd(String pat_id, String treat_date_from, String treat_date_to, Long ord_no, Integer edition, String is_del);

  @Select
  List<OrdMain> selectByCd2(String pat_id, String treat_date_from, String treat_date_to, Long ord_no, Integer edition, String is_del);

  @Select
  List<OrdMain> selectByDateCd(String facility_cd, Long pat_id, String dialysis_date_from, String dialysis_date_to, Long ord_no, List<Integer> weeksArry, String is_del);

  /* add by chamaojia 2026-03-17 [12462] 患者情報共有->患者経過総合ビューア --start */
  @Select
  List<OrdMain> selectByDateCdToPatShr(String facility_cd, Long pat_id, String dialysis_date_from, String dialysis_date_to);

  @Select
  List<OrdMain> selectByDateCdToShr(String facilityCd, Long patId, String dialysisDateFrom, String dialysisDateTo, List<Integer> weeksArry);
  /* add by chamaojia 2026-03-17 [12462] 患者情報共有->患者経過総合ビューア --end */

  //mod 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
  @Select
  List<OrdMainWithlastWeightAfter> findByDateCdWithlastWeightAfter(String facility_cd, Long pat_id, String dialysis_date_from, String dialysis_date_to, Long ord_no, List<Integer> weeksArry, String is_del);
  //mod 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end

  // add FNSi6002-補液速度操作範囲上限を超えて設定できる 周 start
  @Select
  List<OrdMain> selectFutureScheduleByDateCd(String facility_cd, Long pat_id);
  // add FNSi6002-補液速度操作範囲上限を超えて設定できる 周 end

  // add FNSI-FutreNetWeb+SI課題管理No.4362 李 start
  @Select
  List<OrdMain> selectWeekChangeByDateCd(String facility_cd, Long pat_id, String dialysis_date_from, Long ord_no, List<Integer> weeksArry, String is_del);
  // add FNSI-FutreNetWeb+SI課題管理No.4362 李 end

  //  add 4693 鞠 start
  @Select
  List<OrdMain> selectOrdMainByFacilityCd(String facilityCd,String treatDate);
  @Update(sqlFile = true)
  int updateOrdMainByOrdNo(Long ordNo);
  //  add 4693 鞠 end
  // del #7977 2022/10/13【デグレ】仮想端末の投与薬剤が表示されなくなった dou start
  // add #7660 2022/08/24 【デグレ】実績確定するまでの間は治療記録用紙に表示されない項目がある。 王永吉 start
//  @Update(sqlFile = true)
//  int updateIndInfoToRstInfo(Long ordNo, int indBedCd, String indCondInfo, String indMedInfo, String indEquipInfo, String indIndComentInfo, String indDeviceSetInfo);
  // add #7660 2022/08/24 【デグレ】実績確定するまでの間は治療記録用紙に表示されない項目がある。 王永吉 end
  // del #7977 2022/10/13【デグレ】仮想端末の投与薬剤が表示されなくなった dou end
  // add FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 start
  // mod #11716 曜日パターン変更の不正 関 start
  @Select
  List<OrdMain> selectByDateCdDayInfo(String facility_cd, Long pat_id, String dialysis_date_from, String dialysis_date_to, Long ord_no, List<Integer> weeksArry, String is_del, String indTreatmentCd);
  // mod #11716 曜日パターン変更の不正 関 end
  // add FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 end
  @Select
  List<OrdMain> selectByBaseDate(String facilityCd, Long patId, String baseDate, Integer period, Integer pastPeriod);

  /* add by chamaojia 2026-03-23 [12462] 患者情報共有->患者経過総合ビューア --start */
  @Select
  List<OrdMain> selectByBaseDateToShr(String facilityCd, Long patId, String baseDate, Integer period, Integer pastPeriod);
  /* add by chamaojia 2026-03-23 [12462] 患者情報共有->患者経過総合ビューア --end */

  @Select
  List<OrdMain> selectByPastBaseDate(String facilityCd, Long patId, String baseDate, Integer period);

  /**
   * 体重計患者スケジュール検索
   * @param facilityCd
   * @param patId
   * @param treatDate
   * @param treatLocalDate
   * @param isPast
   * @return
   */
  @Select
  List<OrdMainForWeightSchedule> selectScheduleForWeight(String facilityCd, Long patId, String treatDate, Timestamp treatLocalDate, Timestamp treatLocalDateLast, boolean isPast);

  @Select
  OrdMainForWeightNextSchedule selectNextShceduleByPat(Long patId, String basetreatDateTime);

  @Select
  List<OrdMainKurAndTreatmentList> selectOrdMainKurAndTreatmentList(String facility_cd, Long pat_id, String dialysis_date_from, String dialysis_date_to, List<Integer> week_pattern, String is_del);

  @Select
  List<OrdMain> selectByTreatItemCd(String pat_id, String dialysis_date_from, String dialysis_date_to, List<Integer> weeks_array, String kur_cd, String treat_item_cd_before, Integer edition, String is_del);

  @Select
  List<OrdMainForCheckListSchedule> selectByTreatDate(String facilityCd, String treatDate);

  /**
   * スケジュール一覧情報取得
   * @param facilityCd
   * @param startDate
   * @param endDate
   * @param bedCd
   * @return
   */
  @Select
  List<OrdMainForScheduleAssignment> selectScheduleByTreatDateBedCd(String facilityCd, String startDate, String endDate,Long bedCd);
  // add FNSI-？？？？患者割り当て 徐 start
  @Select
  List<OrdMainForScheduleAssignment> selectScheduleByTreatDateFacilityCd(String facilityCd, String startDate, String endDate,Long bedCd);
  // add FNSI-？？？？患者割り当て 徐 end

  // del #11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) zkm start
//  @Select
//  List<OrdMain> selectScheduleExtendCheck(String facilityCd,List<OrdMain> ordMainList);
  // del #11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) zkm end

  @Select
  List<OrdMain> selectOneselfScheduleExtendCheck(String facilityCd,List<OrdMain> ordMainList);

  @Select
  List<OrdMainForCheckListSchedule> selectTreatmentByTreatDate(String facilityCd, String treatDate);

  @Select
  List<DeviceSetInfo> selectDeviceInfo(Long ord_no, String facility_cd, Long pat_id, String start_date, String end_date, List<Integer> week, List<Integer> treat_method, List<Integer> kur_cd, String second_key);

  @Select
  List<DeviceSetInfo> selectRstDeveiceInfo(Long ord_no, String facility_cd, Long pat_id, String start_date, String end_date, List<Integer> week, List<Integer> treat_method, List<Integer> kur_cd, String second_key);

  @Insert(sqlFile = true)
  int insert(OrdMain ordMain);

  /* modify by chamaojia 2023-04-11 [6118] 一括挿入方法の変更、単一バッチへの変更  --start */
  /* add by chamaojia 2023-03-20 [8101] 新規一括メソッド  --start */
  @Insert(sqlFile = true)
  int insertList(List<OrdMain> ordMainList);
  /* add by chamaojia 2023-03-20 [8101] 新規一括メソッド  --end */
  /* modify by chamaojia 2023-04-11 [6118] 一括挿入方法の変更、単一バッチへの変更  --end */

  @Insert
  int insertNoSqlFile(OrdMain ordMain);

  @Select
  OrdMain selectMaxNo();

  @Select
  String selectLastRstWeight(Long patId, Long currentOrdNo, Timestamp baseDate, Integer tokushu);

  /* add by chamaojia 2023-06-16 [8637] 新規一括クエリー方法 --start */
  @Select
  List<TreatmentStatusList> selectLastRstWeightByList(List<TreatmentStatusList> dataList);
  /* add by chamaojia 2023-06-16 [8637] 新規一括クエリー方法 --end */

  @Select
  String selectWeightByTreatDate(Long patId, Long currentOrdNo, String treatDate, Integer tokushu);

  @Select
  List<DeviceSetInfo> selectTareAndOffWater(Long ord_no, Integer flgIndRst);

  @Select
  List<DeviceSetInfo> selectTareAndOffWaterByWeek(Long pat_id, String fromDate, String toDate);

  @Select
  List<OrdMainPatObsRecCombo> selectPatObsRecCombo(String facilityCd, Long patId, String treatDate, Long ordNo, Timestamp dialysisDateFrom, Timestamp dialysisDateTo, boolean getIndTreatFlg);

  @Select
  List<OrdMainPatEventRecCombo> selectPatEventRecCombo(String facilityCd, Long patId, Timestamp dialysisDateFrom, Timestamp dialysisDateTo, Integer mode);

  @Select
  OrdMainPatEventRecCombo selectPatEventOrd(Long ordNo, Long patId);

  @Select
  List<DeviceSetInfo> selectDisableUpdate(Long pat_id, String fromDate);

  @Select
  int getMachineTreatmode(Long ordNo);

  @Select
  Long selectPatEventAmount(Long patId, Long ordNo, Long categoryCd);

  @Select
  Long countMediUsedByCd(Long patId, String mediCd);

  @Select
  String getOrdIndTreatStartTime(Long ordNo);

  @Select
  List<Long> selectMediCdList(Long ordNo, Integer medicineCd);

  @Delete(sqlFile = true)
  int delete(
      Long ord_no,
      Long pat_id,
      String dialysis_date_from,
      String dialysis_date_to,
      List<Integer> treatment_cd,
      List<Integer> kur_cd);

  @Select
  List<OrdMain> getDeleteOrdMain(Long ord_no,
                                 Long pat_id,
                                 String dialysis_date_from,
                                 String dialysis_date_to,
                                 List<Integer> treatment_cd,
                                 List<Integer> kur_cd);

  @Delete(sqlFile = true)
  int deleteByOrdNo(List<Long> ordNoList);

  @Delete
  int delete(OrdMain ordMain);

  @Update
  int update(OrdMain ordMain);

  /* modify by chamaojia 2023-03-20 [8101] エンティティ・オブジェクトの変更、リスニングされていないオブジェクトの変更  --start */
  @BatchUpdate(batchSize = 100)
  int[] update(List<OrdMainEsListener> ordMains);
  /* modify by chamaojia 2023-03-20 [8101] エンティティ・オブジェクトの変更、リスニングされていないオブジェクトの変更  --end */

  /**
   * 条件送信履歴用のデータ収集
   * @param ordNo オーダー番号
   * @return
   */
  @Select
  OrdWeightScaleBuildInfo selectWithTreatInfo(Long ordNo);
  @Select
  String selectWeightInfo(Long ordNo);

  @Update(sqlFile = true)
  int updateWeightInfo(Long ordNo, String weightInfo);

  /**
   * 在宅透析時-前体重更新
   * @param ordNo
   * @param weightBefore
   * @param beforeDate
   * @return
   */
  @Update(sqlFile = true)
  int updateWeightBefore(Long ordNo, BigDecimal weightBefore, String beforeDate);

  /**
   * 在宅透析時-後体重更新
   * @param ordNo
   * @param weightAfter
   * @param afterDate
   * @return
   */
  @Update(sqlFile = true)
  int updateWeightAfter(Long ordNo, BigDecimal weightAfter, String afterDate);


  /***
   * 帰宅日時更新
   * @param ordNo
   * @param weightInfo
   * @param state
   * @return
   */
  @Update(sqlFile = true)
  int updateReturnHomeDateAndState(Long ordNo, Timestamp returnHomeDate, String state);

  /**
   * 体重測定画面で必要な項目を取得
   * @param ordNo オーダー番号
   * @return
   */
  @Select
  OrdMainForWeightInd selectForWeightIndByOrdNo(Long ordNo);
//add 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
  @Select
  OrdMainForWeightInd selectForWeightIndByOrdNoAndFacilityCd(Long ordNo,String facilityCd);
  //add 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
  /**
   * 曜日パターンダイアログで選択項目に表示するデータを取得
   * @param pat_id 患者ID
   * @param facility_cd 施設コード
   * @param dialysis_date_from 開始日
   * @param dialysis_date_to 終了日
   * @param rst_dialysis_state 状態
   * @return
   */
  @Select
  List<String> selectWeekPerTreatCdList(Long pat_id, String facility_cd, String dialysis_date_from, String dialysis_date_to, String rst_dialysis_state);

  /**
   * 仮想端末情報（CTRトレンド）のDaoインタフェース
   * @author Y.Takamura
   */
  @Select
  List<LcdReq53> selectWeightAll(Long patId);

  /**
   * 仮想端末情報（酸素吸入）のDaoインタフェース
   * @author Y.Takamura
   *
   */
  @Select
  List<LcdReq32> selectOxygenByNo(Long ordNo);

  /**
   * 仮想端末情報（体重トレンド）のDaoインタフェース
   * @author Y.Takamura
   *
   */
  @Select
  List<LcdReq38> selectWeightTrend(Long patId);

  /**
   * 仮想端末情報（投与薬剤）のDaoインタフェース
   * @author Y.Takamura
   *
   */
  @Select
  List<LcdReq41> selectMediInfoByNo(Long ordNo);

  /**
   * 仮想端末情報（抗凝固剤）のDaoインタフェース
   * @author Y.Takamura
   *
   */
  @Select
  LcdReq42 selectCondInfoByNo(Long ordNo);

  @Select
  List<OrdMain> selectMediInfoByNoList(List<Long> ordNoList);

  /**
   * 曜日移動対象(状態：0)のOrdMainレコードリストを取得
   * @param pat_id 患者ID
   * @param facility_cd 施設コード
   * @param dialysis_date_from　開始日
   * @param dialysis_date_to　終了日
   * @param rst_dialysis_state　状態
   * @param treatment_cd　治療方法コード
   * @param treat_week 治療曜日リスト
   * @return
   */
  @Select
  List<OrdMain> selectMoveTarget(
      Long pat_id,
      String facility_cd,
      String dialysis_date_from,
      String dialysis_date_to,
      String rst_dialysis_state,
      Integer treatment_cd,
      List<Integer> treat_week,
      boolean hasIndKurCd);

  /**
   * 仮想端末情報（指示／特記）のDaoインタフェース
   * @author Y.Takamura
   *
   */
  @Select
  List<LcdReq52> selectCommentByNo(Long ordNo);

  /**
   * 透析状態
   *
   * @param facilityCd 施設コード
   * @param today 治療日(当日)
   * @param yesterday 治療日(前日)
   * @param patId 患者ID
   * @return 対象の透析状態
   */
  @Select
  OrdMain selectRstDialysisStateAndOrdNo(String facilityCd, String today, String yesterday, Long patId);


  /**
   * 透析状態-体重情報(Pat_idより対象取得)
   *
   * @param facilityCd 施設コード
   * @param today 治療日(当日)
   * @param yesterday 治療日(前日)
   * @param patId 患者ID
   * @param state 指定ステータス
   * @return 対象の透析状態
   */
  @Select
  OrdMain selectRstWeightInfoByPatId(String facilityCd, String today, String yesterday, Long patId, List<String> state);

  /**
   * 仮想端末情報（穿刺／回収／担当）のDaoインタフェース
   * @author Y.Takamura
   *
   */
  @Select
  LcdReq51 selectRstUserInfoByNo(Long ordNo);

  /**
   * 次患者情報
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param searchStartDate 検索開始日
   * @param searchEndDate 検索終了日
   * @return 対象の治療情報
   */
  @Select
  List<OrdMain> selectByNextPatInfoCondition(String facilityCd, String machineTypeCd, String machineSerial, String searchStartDate, String searchEndDate, boolean isSendCondition);

  /**
   * 直近の次患者情報
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param searchStartDate 検索開始日
   * @return 対象の治療情報
   */
  @Select
  OrdMain selectByNextPat(String facilityCd, String machineTypeCd, String machineSerial, String searchStartDate);

  /**
   * 更新対象のord_main情報取得
   * @param patId
   * @param facilityCd
   * @param treatDateFrom
   * @param treatDateTo
   * @param weeks
   * @param treats
   * @param kurs
   * @return
   */
  @Select
  List<OrdMain> selectUpdateTarget(Long patId, String facilityCd, String treatDateFrom, String treatDateTo, List<Integer> weeks, List<Integer> treats, List<Long> kurs, String targetDialysisState);

  /* add by chamaojia 2026-05-18 [12703] 【securify】API診断を実施するとntss-admin-webが落ちる --start */
  @Select
  List<OrdMain> selectForTareOrOffwaterJournal(Long patId, String facilityCd, String treatDateFrom, String treatDateTo
          , List<Integer> weeks, List<Integer> treats, List<Long> kurs, String targetDialysisState);
  /* add by chamaojia 2026-05-18 [12703] 【securify】API診断を実施するとntss-admin-webが落ちる --end */

  // add #11731_【因島：改良】指示コメント番号の指定方法 start
  /**
   * 指示コメント情報（指示コメント番号で集約）の取得
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @param treatDateFrom 開始日
   * @param treatDateTo 終了日
   * @param weeks 治療曜日リスト
   * @param treats 治療方法コード
   * @param kurs クールリスト
   * @return 指示コメント情報（指示コメント番号で集約）したリスト
   */
  @Select
  List<OrdMainIndIndCommentInfo> selectIndIndCommentInfo(Long patId, String facilityCd, String treatDateFrom, String treatDateTo, List<Integer> weeks, List<Integer> treats, List<Long> kurs);
  // add #11731_【因島：改良】指示コメント番号の指定方法 end

  // add 10150_9664 by kangjie 20240802 start
  /**
   * 更新対象のord_main情報取得
   * @param patId
   * @param facilityCd
   * @param treatDateFrom
   * @param treatDateTo
   * @param weeks
   * @param treats
   * @param kurs
   * @param targetDialysisState
   * @param kurs
   * @return
   */
  @Select
  List<OrdMain> selectUpdateTargetCondInfo(Long patId, String facilityCd, String treatDateFrom, String treatDateTo, List<Integer> weeks,
                                   List<Integer> treats, List<Long> kurs, String targetDialysisState, String condKeys, List<Integer> treatmentCdList);
  // add 10150_9664 by kangjie 20240802 end

  // add 9664 by kangjie 20231205 start
  @Select
  List<OrdMain> findUpdateTargetOrdMain(String facilityCd, String treatDateFrom, Integer treatmentCd);
  // add 9664 by kangjie 20231205 end
 //add 8204 周安寧 start
 @Select
  List<TreatmentConditionSetting> selectTreatmentConditionSetting(Long patId, String facilityCd, String treatDateFrom, String treatDateTo, List<Integer> weeks, List<Integer> treats, List<Long> kurs);
//add 8204 周安寧 end
  @Update(sqlFile = true)
  int updateRstTare(Long ord_no, String jsonTareValue);

  // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  start
  @Update(sqlFile = true)
  int updateByTreatmentCdOnlyForHD(Integer treatmentCd, OrdMainOnly ord, List<Long> ordNoList,
                                   BigInteger indUserId, Long userId);
  @Update(sqlFile = true)
  int updateByTreatmentCdOnlyForECUM(Integer treatmentCd, OrdMainOnly ord, List<Long> ordNoList,
                              BigInteger indUserId, Long userId);
  @Update(sqlFile = true)
  int updateByTreatmentCdOnlyForHDF(Integer treatmentCd, OrdMainOnly ord, List<Long> ordNoList,
                              BigInteger indUserId, Long userId);
  @Update(sqlFile = true)
  int updateByTreatmentCdOnlyForHF(Integer treatmentCd, OrdMainOnly ord, List<Long> ordNoList,
                              BigInteger indUserId, Long userId);
  @Update(sqlFile = true)
  int updateByTreatmentCdOnlyForPURIFICATION(Integer treatmentCd, OrdMainOnly ord, List<Long> ordNoList,
                              BigInteger indUserId, Long userId);
  @Update(sqlFile = true)
  int updateByTreatmentCdOnlyForAFBF(Integer treatmentCd, OrdMainOnly ord, List<Long> ordNoList,
                              BigInteger indUserId, Long userId);
  @Update(sqlFile = true)
  int updateByTreatmentCdOnlyForOHDF(Integer treatmentCd, OrdMainOnly ord, List<Long> ordNoList,
                              BigInteger indUserId, Long userId);
  @Update(sqlFile = true)
  int updateByTreatmentCdOnlyForOHF(Integer treatmentCd, OrdMainOnly ord, List<Long> ordNoList,
                              BigInteger indUserId, Long userId);
  @Update(sqlFile = true)
  int updateByTreatmentCdOnlyForIHDF(Integer treatmentCd, OrdMainOnly ord, List<Long> ordNoList,
                                    BigInteger indUserId, Long userId);
  @Update(sqlFile = true)
  int updateByTreatmentCd(Integer treatmentCd, OrdMain ord, List<Long> ordNoList,
                          BigInteger indUserId, Long userId);
  @Update(sqlFile = true)
  int updateByTreatmentCdIndRst(Integer treatmentCd, OrdMain ord, List<Long> ordNoList,
                          BigInteger indUserId, Long userId);
  @Update(sqlFile = true)
  int updateBedToNullByOrdNo(List<Long> ordNoList, String indScheduleUserInfo);
  // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  end

  @Update(sqlFile = true)
  int updateRstOffWater(Long ord_no, String jsonOffWaterValue);

  @Update(sqlFile = true)
  int updateWeightScaleNo(Long ordNo, Long weightScaleNo);

  @Update(sqlFile = true)
  int moveDataToIndDate(
          OrdMain ordMain,
          String indScheduleUserInfo
       );

  // add #10196 rst=456 move Treatment plan ztc 20240304 start
  @Update(sqlFile = true)
  int moveDataToIndDateOfRst(OrdMain ordMain, String indScheduleUserInfo);
  // add #10196 rst=456 move Treatment plan ztc 20240304 end

  // add FNSI-障害票一覧_患者経過総合ビューアNo.22-27 李 start
  @Update(sqlFile = true)
  int moveDataToIndDateCanel(OrdMain ordMain);
  // add FNSI-障害票一覧_患者経過総合ビューアNo.22-27 李 end

  //コピー用SQL
  @Insert(sqlFile = true)
  int copyData(
      OrdMain ordMain
    );

  @Update(sqlFile = true)
  int updateCommentInfo(
      Long ordNo,
      String commentInfo
  );

  @Update(sqlFile = true)
  // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 start
  int updateIndCommentInfo(
    Long ordNo,
    String commentInfo
  );
  // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 end
 // add キャンセル（実績に反映しない）を選択　⇒　実績に反映される修正  xmj 2022-08-11 start
  @Update(sqlFile = true)
  int deleteCommentInfo(
      Long ordNo,
      String commentInfo,
      String isRstUpdate
    );
 // add キャンセル（実績に反映しない）を選択　⇒　実績に反映される修正  xmj 2022-08-11 end

  @Update(sqlFile = true)
  int updateTreatMethod(String treatItemCd, List<Integer> ordNo);

  /**
   * 治療情報スケジュール更新
   * @param ordNoList 抽出データ（更新対象レコードリスト)
   * @param indKurCd 編集データ（指示：クールコード）
   * @param indKurName 編集データ（指示：クール名）
   * @param indTreatStartTime 編集データ（指示：治療開始時刻）
   * @param indBedCd 編集データ（指示：ベッドコード）
   * @param indBedName 編集データ（指示：ベッド名）
   * @param indUserId 編集データ（指示者）
   * @param updUserid 編集データ（更新者）
   * @param indUserLastName 編集データ（指示者名_姓)
   * @param indUserFirstName 編集データ（指示者名_名)
   * @param updateMode 更新モード 0->通常更新, 1->ベッド未登録処理
   * @return 実行件数
   */
  @Update(sqlFile = true)
  int updateOrdMainScheduleInfo(
      List<Long> ordNoList,
      Long indKurCd,
      String indKurName,
      String indTreatStartTime,
      Long indBedCd,
      String indBedName,
      Long indUserId,
      Long updUserid,
      // mod FNSI-指示編集でDB登録データの更新 楊 start
      String indUserLastName,
      String indUserFirstName,
      // mod FNSI-指示編集でDB登録データの更新 楊 end
      // add 10196 by kangjie 20240122 start
      String updUserLastName,
      String updUserFirstName,
      // add 10196 by kangjie 20240122 end
      Integer updateMode,
      // add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.79(外結)対応 韓 start
      boolean rstUpdFlg
      // add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.79(外結)対応 韓 end
  );

  /* modify by chamaojia 2023-10-27 [9973] A針/V針とSN針の排他条件追加  --start */
  /**
   * 治療条件更新
   *
   * @param ord_no オーダー番号
   * @param ord_info 編集データ
   * @return
   */
  @Update(sqlFile = true)
  int updateOrdMainInfo(List<Long> ord_no, String ord_info,Long up_ind_user_id, Long up_user_id, String needExcludeItem);

  // add 9664 by kangjie 20240425 start
  @Update(sqlFile = true)
  int updateNewSteps(String fluidJSONString,List<Long> ordNos,Long up_ind_user_id, Long up_user_id);
  // add 9664 by kangjie 20240425 end

  /* modify by chamaojia 2023-03-08 [6118] 新規クエリ、merge不要  --start */
  /**
   * 治療条件更新
   *
   * @param ord_no オーダー番号
   * @param ord_info 編集データ
   * @return
   */
  @Update(sqlFile = true)
  // mod 10495 無期限治療条件変更時のpat_treatment_patternの更新バグ 関  start
  // int updateOrdMainInfoByOrdNos(List<Long> ord_no, String ord_info,Long up_ind_user_id, Long up_user_id, String needExcludeItem);
  // mod 10443 身体情報・DW・目標体重バグ 関 start
  // int updateOrdMainInfoByOrdNos(List<Long> ord_no, String ord_info,Long up_ind_user_id, Long up_user_id, String needExcludeItem, Long patId);
  int updateOrdMainInfoByOrdNos(List<Long> ord_no, String ord_info,Long up_ind_user_id, Long up_user_id, String needExcludeItem, Long patId, String indDwUserInfo);
  // mod 10443 身体情報・DW・目標体重バグ 関 end
  // mod 10495 無期限治療条件変更時のpat_treatment_patternの更新バグ 関  end
  /* modify by chamaojia 2023-03-08 [6118] 新規クエリ、merge不要  --end */

  // add 10495 無期限治療条件変更時のpat_treatment_patternの更新バグ 関  start
  /**
   * 治療条件更新
   *
   * @param ord_no オーダー番号
   * @param ord_info 編集データ
   * @return
   */
  @Update(sqlFile = true)
  // mod 10443 身体情報・DW・目標体重バグ 関 start
  // int updateOrdMainInfoByOrdNosAndPatId(List<Long> ord_no, String ord_info,Long up_ind_user_id, Long up_user_id, Long patId);
  int updateOrdMainInfoByOrdNosAndPatId(List<Long> ord_no, String ord_info,Long up_ind_user_id, Long up_user_id, Long patId, String indDwUserInfo);
  // mod 10443 身体情報・DW・目標体重バグ 関 end
  // add 10495 無期限治療条件変更時のpat_treatment_patternの更新バグ 関  end

  //upd by ztc 2023-03-02 [Optimize runtime No.6968] --start /
  @Update(sqlFile = true)
  int updateOrdMainInfoList(List<OrdMainEsListener> updateOrdMainInfoList);
  //upd by ztc 2023-03-02 [Optimize runtime No.6968] --end /

  /* modify by chamaojia 2023-11-29 [9973] A針/V針とSN針の排他条件追加  --start */
  /**
   * 治療条件実績更新
   *
   * @param ord_no オーダー番号
   * @param rst_info 編集データ
   * @return
   */
  @Update(sqlFile = true)
  int updateRstOrdMainInfo(List<Long> ord_no, String rst_info, String needExcludeItem);
  /* modify by chamaojia 2023-11-29 [9973] A針/V針とSN針の排他条件追加  --end */

  // del #12455 条件送信後に医材変更＆実績反映すると数量が0になる zkm start
//  /**
//   * 医療材料更新
//   *
//   * @param ord_no オーダー番号
//   * @param ord_info 編集データ
//   * @return
//   */
//  @Update(sqlFile = true)
//  int updateOrdMainEquipInfo(
//    Long ord_no,
//    String ord_info,
//    String rst_info
//  );
  // del #12455 条件送信後に医材変更＆実績反映すると数量が0になる zkm end

  /* modify by chamaojia 2024-01-23 [10196]  No need to modify the content of 'indScheduleUserInfo' --start */
  /**
   * 医療材料更新
   */
  @Update(sqlFile = true)
  int updateOrdMainEquipInfoAndUserId(
    Long ord_no,
    String indEquipInfo,
    String rstEquipInfo,
//    String indScheduleUserInfo,
    Long up_ind_user_id,
    Long up_user_id,
    //mod 9806 ljx start 医療材料
    Boolean rstUpdFlg
    //mod 9806 ljx end
  );
  /* modify by chamaojia 2024-01-23 [10196]  No need to modify the content of 'indScheduleUserInfo' --end */

  /* modify by chamaojia 2024-01-22 [10196]  No need to modify the content of 'indScheduleUserInfo' --start */
  /**
   * 投与薬剤更新
   */
  @Update(sqlFile = true)
  int updateOrdMainMedInfoAndUserId(
    Long ord_no,
    String indMediInfo,
    String rstMediInfo,
//    String indScheduleUserInfo,
    Long up_ind_user_id,
    Long up_user_id,
    //add 9806 ljx start 投与薬剤
    Boolean rstUpdFlg
    //add 9806 ljx end
  );
  /* modify by chamaojia 2024-01-22 [10196]  No need to modify the content of 'indScheduleUserInfo' --end */

  /**
   * 投与薬剤更新
   */
  @Update(sqlFile = true)
  //mod 8277 周安寧 start

//  int updateOrdMainCommentInfoAndUserId(
//    Long ord_no,
//    String indIndCommentInfo,
//    String rstIndCommentInfo,
//    String indScheduleUserInfo,
//    Long up_ind_user_id,
//    Long up_user_id
//  );
  /* modify by chamaojia 2024-01-23 [10196]  Add and delete modified content --start */
  int updateOrdMainCommentInfoAndUserId(
    Long ord_no,
    String indIndCommentInfo,
    String rstIndCommentInfo,
//    String indScheduleUserInfo,
    Long up_ind_user_id,
    Long up_user_id,
    Boolean isIndFlag,
    //add 9806 ljx start 指示コメント
    Boolean rstUpdFlg
    //add 9806 ljx end
  );
  /* modify by chamaojia 2024-01-23 [10196]  Add and delete modified content --end */
//mod 8277 周安寧 end
  // add #12471 ord_main.ind_medi_infoに不正データが登録される zkm start
  /**
   * 投与薬剤追加更新
   *
   * @param ordNoList オーダー番号
   * @param changeMediInfo 編集データ
   * @param isRstUpdate 実績が反映するか
   * @param upIndUserId 最終更新指示者ID
   * @param upUserId 最終更新者ID
   * @return 更新されたレコードリスト
   */
  @Select
  List<OrdMain> updateOrdMainMediInfoWithAdd(
    List<Long> ordNoList
    ,String changeMediInfo
    ,String isRstUpdate
    ,String upIndUserId
    ,String upUserId
  );

  /**
   * 投与薬剤更新
   *
   * @param ordNoList オーダー番号
   * @param changeMediInfo 編集データ
   * @param treatDates 投薬パターンなど有効投薬日リスト
   * @param isEditOtherAmount 数量以外を変更するか(false:以外を更新、true:数量のみ更新)
   * @param weeksArray 更新曜日リスト
   * @param oldMediNo 更新投薬No
   * @param isRstUpdate 実績が反映するか
   * @param upIndUserId 最終更新指示者ID
   * @param upUserId 最終更新者ID
   * @return 更新されたレコードリスト
   */
  @Select
  List<OrdMain> updateOrdMainMediInfoWithUpd(
    List<Long> ordNoList
    ,String changeMediInfo
    ,List<String> treatDates
    ,String isEditOtherAmount
    ,List<Integer> weeksArray
    ,String oldMediNo
    ,String isRstUpdate
    ,String upIndUserId
    ,String upUserId
  );

  /**
   * 投与薬剤中止更新
   *
   * @param ordNoList オーダー番号
   * @param changeMediInfo 編集データ
   * @param isRstUpdate 実績が反映するか
   * @param upIndUserId 最終更新指示者ID
   * @param upUserId 最終更新者ID
   * @return 更新されたレコードリスト
   */
  @Select
  List<OrdMain> updateOrdMainMediInfoWithDel(
    List<Long> ordNoList
    ,String changeMediInfo
    ,String isRstUpdate
    ,String upIndUserId
    ,String upUserId
  );
  // add #12471 ord_main.ind_medi_infoに不正データが登録される zkm end

  // add #12455 条件送信後に医材変更＆実績反映すると数量が0になる zkm start
  /**
   * 医療材料更新
   *
   * @param ordNoList 処理対象オーダー番号リスト
   * @param dualType 処理種類(add, upd, del_add, del)
   * @param updOldKey 編集対象医療材料コード_編集対象医療材料の区分
   * @param autoInsertAmount 編集対象医療材料コード_変更前の数量(画面表示のみ)
   * @param changeEquipInfo 編集データ
   * @param isRstUpdate 実績が反映するか
   * @param upIndUserId 最終更新指示者ID
   * @param upUserId 最終更新者ID
   * @return 更新されたレコードリスト
   */
  @Select
  List<OrdMain> updateOrdMainEquipInfo(
    List<Long> ordNoList
    ,String dualType
    ,String updOldKey
    ,String autoInsertAmount
    ,String changeEquipInfo
    ,String isRstUpdate
    ,String upIndUserId
    ,String upUserId
  );
  // add #12455 条件送信後に医材変更＆実績反映すると数量が0になる zkm end

  /**
   * 体重測定時に体重実績、風袋実績、除水実績、受付日時、DWを保存する
   * @param ordNo オーダー番号
   * @param weightInfo 体重実績
   * @param offWaterInfo 除水補正JSON文字列
   * @param tareInfo 風袋JSON文字列
   * @param rstAcceptDate 受付日時
   * @param dw DW
   * @return
   */
  @Update(sqlFile = true)
  int updateBeforeWeight(Long ordNo, String weightInfo, String offWaterInfo, String tareInfo, Timestamp rstAcceptDate, String dw);

  @Update(sqlFile = true)
  int updateBeforeWeightWithVariousTbl(Long ordNo, String weightInfo, String offWaterInfo, String tareInfo, Timestamp rstAcceptDate, String dw);

  @Update(sqlFile = true)
  int updateIndStartTareAndOffWater(Long ordNo, String offWaterInfo, String tareInfo);

  @Update(sqlFile = true)
  int updateRstTareOffWaterInfo(Long ordNo, String tareInfo, String offWaterInfo, Timestamp upDate);

  @Update(sqlFile = true)
  int updateTareAndOffWater(Long ordNo, String tareInfo, String offWaterInfo);

  @Update(sqlFile = true)
  int updateIndTareOffWaterInfo(Long ordNo, String tareInfo, String offWaterInfo, Timestamp upDate);

  //add by ztc 2023-02-23 [Optimize runtime No.5482] --start /
  @Update(sqlFile = true)
  // del 11119 by kangjie 20241008 start
//  int updateIndTareOffWaterInfoList(List<Long> ordNoList, String tareInfo, String offWaterInfo, String indUser);
  int updateIndTareOffWaterInfoList(List<Long> ordNoList, String tareInfo, String offWaterInfo);
  // del 11119 by kangjie 20241008 end
  //add by ztc 2023-02-23 [Optimize runtime No.5482] --end /

  @Update(sqlFile = true)
  int updateRstTareAndOffWater(Long ordNo, String tareInfo, String offWaterInfo);

  @Update(sqlFile = true)
  int updateFutureIndTareAndOffWater(Long patId, String treatDate, Integer treatWeek, String tareInfo, String offWaterInfo, Timestamp upDate);

  @Select
  List<Long> selectUpdateFutureIndTareAndOffWater(Long patId, String treatDate, Integer treatWeek);

  @Select
  List<OrdMain> selectFutureIndTareAndOffWater(Long patId, String treatDate, Integer treatWeek);

  @Update(sqlFile = true)
  int updateDeviceInfo(Long ordNo, String facilityCd, Long patId, String startDate, String endDate, List<Integer> week, List<Integer> treatMethod, List<Integer> kurCd, String deviceInfo);

  @Select
  List<Long> selectUpdateDeviceInfo(Long ordNo, String facilityCd, Long patId, String startDate, String endDate, List<Integer> week, List<Integer> treatMethod, List<Integer> kurCd);

  @Select
  List<OrdMain> selectDeviceInfos(Long ordNo, String facilityCd, Long patId, String startDate, String endDate, List<Integer> week, List<Integer> treatMethod, List<Integer> kurCd);

  @Update(sqlFile = true)
  int updateRstDeviceSetInfo(Long ordNo, String facilityCd, Long patId, String startDate, String endDate, List<Integer> week, List<Integer> treatMethod, List<Integer> kurCd, String deviceInfo);

  @Select
  List<Long> selectUpdateRstDeviceSetInfo(Long ordNo, String facilityCd, Long patId, String startDate, String endDate, List<Integer> week, List<Integer> treatMethod, List<Integer> kurCd);

  @Select
  List<OrdMain> selectRstDeviceSetInfos(Long ordNo, String facilityCd, Long patId, String startDate, String endDate, List<Integer> week, List<Integer> treatMethod, List<Integer> kurCd);

  @Update(sqlFile = true)
  int immediateCommitOffWater(Long ordNo, String offWaterInfo);

  @Update(sqlFile = true)
  int immediateCommitTare(Long ordNo, String tareInfo);

  // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
  @Select
  List<OrdMain> selectByDetailedSearchCondition(OrdMainDetailedConditions conditions, List<String> facilityCdList, List<Long> patIdList);

  // add FutreNetWeb+SI課題管理No6206 趙 start
  @Select
  List<OrdMain> selectByDetailedSearchConditionadd(OrdMainDetailedConditions conditions, List<String> facilityCdList, String rstDialysisStateFlag, List<Long> patIdList);
  // add FutreNetWeb+SI課題管理No6206 趙 end
  // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end

  @Select
  long selectMaxIndMediInfoNo();

  // add FNSI-投薬最新識別番号の設定 李 start
  @Select
  long selectIndMediInfoNo(String facilityCd, String patId);

  @Update(sqlFile = true)
  int updateIndMediInfoNo(String facilityCd, String patId, long maxMediInfoNo);

  // mod #12471 投薬最新識別番号の設定 zkm start
//  @Insert(sqlFile = true)
//    //mod 8151 選択したものと異なる薬剤の指示編集画面が表示する。 張 start
////  int insertIndMediInfoNo(String facilityCd, String patId);
//  int insertIndMediInfoNo(String facilityCd, String patId,long maxMediInfoNo);
//  //mod 8151 選択したものと異なる薬剤の指示編集画面が表示する。 張 end
//  // add FNSI-投薬最新識別番号の設定 李 end
  @Select
  Long lockMaxIndMediInfoNo(String facilityCd, String patId);
  @Select
  Long lockMaxIndEquipInfoNo(String facilityCd, String patId);
  // mod #12471 投薬最新識別番号の設定 zkm end

  // add FNSI-医療材料最新識別番号の設定 start
  @Select
  long selectIndEquipInfoNo(String facilityCd, String patId);
  // add FNSI-医療材料最新識別番号の設定 end

  /**
   * オーダーに関連付けられている患者IDを取得
   * @param ordNo オーダー番号
   * @return 患者ID
   */
  @Select
  Long selectPatIdByOrdNo(Long ordNo);

  /**
   * 後体重確認時の更新
   * @param ordNo オーダー番号
   * @param mediInfo 投薬情報のJSON文字列
   * @return 実行件数
   */
  @Update(sqlFile = true)
  int updateCheckAfterWeight(Long ordNo, String mediInfo);

  /**
   * 投与薬剤実績の更新
   * @param ordNo オーダー番号
   * @param mediInfo 投薬情報のJSON文字列
   * @return 実行件数
   */
  @Update(sqlFile = true)
  int updateMediInfo(Long ordNo, String mediInfo);

  @Update(sqlFile = true)
  int updateTreatmentMethod(List<Long> ordNoList, OrdMain ordMain, Long indUserId, Long updUserId);

  //add by ztc 2023-02-12 [Optimize no.8099] --start
//  @Update(sqlFile = true)
//  int updateTreatmentMethodList(List<OrdMainTreatmentMethodVo> uptOrdMainTMethodVoList);
  //add by ztc 2023-02-12 [Optimize no.8099] --end

  @Update(sqlFile = true)
  int updateRstTreatmentMethod(List<Long> ordNoList, Integer treatmentCd, String treatmentName);

  //add by ztc 2023-02-12 [Optimize no.8099] --start
//  @Update(sqlFile = true)
//  int updateRstTreatmentMethodList(List<OrdMainTreatmentMethodVo> rstOrdMainTMethodVoList);
  //add by ztc 2023-02-12 [Optimize no.8099] --end

  /**
   * 最終治療日取得
   *
   * @param facilityCd 施設コード
   * @param patId 患者ID
   * @param treatDateStart 開始治療日
   * @param treatDateEnd 終了治療日
   * @return
   */
  @Select
  List<String> selectLastTreatDate(String facilityCd, Long patId, String treatDateStart, String treatDateEnd);

  /**
   * 3カ月間の体重情報履歴取得
   *
   * @param facilityCd 施設コード
   * @param patId 患者ID
   * @param satrttreatDate 治療日
   * @param endtreatDate 終了治療日
   * @return
   */
  @Select
  List<OrdMainForWeightModal> selectWeighthistory(String facilityCd, Long patId, String satrttreatDate, String endtreatDate);

  @Select
  String selectDeviceSetInfo(Long ord_no);

  /* add by chamaojia 2023-03-07 [6118] 新規一括クエリー方法  --start */
  @Select
  List<OrdMainForDeviceSetInfo> selectDeviceSetInfos(List<Long> ordNoList);
  /* add by chamaojia 2023-03-07 [6118] 新規一括クエリー方法  --end */

  @Update(sqlFile = true)
  int updateDeviceSetInfo(Long ord_no, String deviceSetInfo);

  //add by ztc 2023-02-27 [Optimize runtime No.5482] --start
  @Update(sqlFile = true)
  int updateDeviceSetInfoList(List<OrdMainEsListener> updateDeviceSetInfoList);
  //add by ztc 2023-02-27 [Optimize runtime No.5482] --end

  // add #10150 装置プログラムのI-HDF設定を変更する場合、ord_mainの治療条件の補液量(key:20)と補液速度(key:24)を再計算する zkm start
  @Update(sqlFile = true)
  int updateCondWithDeviceIhdf(List<OrdMain> updateCondInfoList);
  // add #10150 装置プログラムのI-HDF設定を変更する場合、ord_mainの治療条件の補液量(key:20)と補液速度(key:24)を再計算する zkm end

  /* modify by chamaojia 2024-01-26 [10196]  Add modification items --start */
  /**
   * 条件送信キャンセル、条件送信日時と治療状況ステータスを初期化する
   * @param ordMain 治療情報
   * @param upDate 更新日
   * @return
   */
  @Update(sqlFile = true)
  int updateCancelSendCondition(OrdMain ordMain, Timestamp upDate);
  /* modify by chamaojia 2024-01-26 [10196]  Add modification items --end */

  /**
   * 患者ID登録
   *
   * @param patId 患者ID
   * @param ordNo ordNo
   * @return
   */
  @Update(sqlFile = true)
  int updatePatId(Long patId, Long ordNo, Timestamp upDate);

  /**
   * 透析回数更新
   *
   * @param ordNo ordNo
   * @param rsrDialysisCnt 透析回数
   * @return
   */
  @Update(sqlFile = true)
  int updateRstDialysisCnt(Long ordNo, Long rstDialysisCnt);


  /**
   * スケジュール割り当て時実績コピー用ord_main取得
   * @param ordNo
   * @return
   */
  @Select
  OrdMainUpdateForScheduleAssignment selectByOrdNoUpdateScheduleAssignment(Long ordNo);

  /**
   * スケジュール割り当て時実績コピー用
   * @param ordNo
   * @return
   */
  @Update(sqlFile = true)
  int updateScheduleAssignment(OrdMainUpdateForScheduleAssignment param, Timestamp upDate);

  /**
   * ord_main削除
   *
   * @param ordNo ordNo
   * @param upDate 更新日時
   * @return
   */
  @Update(sqlFile = true)
  int updateDeleteByOrdNo(Long ordNo, Timestamp upDate);

  /**
   * ord_main論理削除
   *
   * @param patId 患者ID
   * @return
   */
  @Update(sqlFile = true)
  int updateDeleteByPatId(Long patId);


  @Select
  List<OrdMain> selectByDeleteOrdNo(
      Long ord_no,
      Long pat_id,
      String dialysis_date_from,
      String dialysis_date_to,
      List<Integer> treatment_cd,
      List<Integer> kur_cd);

  /**
   * 患者毎の透析予定日のリストを取得.
   * @param patIdList 患者IDリスト
   * @param facilityCd 施設コード.
   * @return 患者毎の透析予定日のリスト
   */
  @Select
  List<String> selectTreatDateList(List<Long> patIdList, String facilityCd);

  /**
   * 患者の透析予定日のリストを取得(同日複数予定がある場合、ordNoで識別する)
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @param treatDateFrom 開始日
   * @param treatDateTo 終了日
   * @param weeks 曜日
   * @param treats 治療方法リスト
   * @param kurs クールリスト
   * @return 患者の透析予定日のリスト
   */
  @Select
  List<OrdMain> selectTreatDateListAll(Long patId, String facilityCd, String treatDateFrom, String treatDateTo, List<Integer> weeks, List<Integer> treats, List<Long> kurs);

  /**
   * 検査結果入力画面：対象透析実績の開始日付取得
   * 施設コード：必須
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @return 対象透析実施ord_no/実績日付/実績日付(文字列変換)
   */
  @Select
  List<OrdMainForExamRecord> selectRstStartDateByPatId(Long patId, String facilityCd);

  /**
   * 患者IDでベッド名とクール名の習得
   * @param patIdList
   * @param facilityCd
   * @param treatDateStart
   * @param treatDateEnd
   * @return
   */
  @Select
  List<OrdMainBedAndKur> selectBedAndKurDetailByIdsAndRange(List<Long> patIdList, String facilityCd, String treatDateStart, String treatDateEnd, String treatDate);

    /**
     * 治療条件でordMainの検索
     *
     * @param treatDate
     * @param treatmentCode
     * @param kurCode
     * @param bedGroup
     * @param checker1
     * @param checker2
     * @param approver1
     * @param approver2
     * @param instructorId
     * @param facilityCd
     * @return
     */
  @Select
  List<OrdChAp> selectOrderByTreatmentCondition (
    String treatDate, Long treatmentCode, List<Long> kurCode, Long bedGroup,
    Boolean checker1, Boolean checker2,
    Boolean approver1, Boolean approver2,
    Integer instructorId, String facilityCd
  );

  /**
   * 指示受け・承認の検索
   *
   * @param treatStartTime
   * @param treatStartDate
   * @param treatEndDate
   * @param checker1
   * @param checker2
   * @param approver1
   * @param approver2
   * @param instructorId
   * @param facilityCd
   * @return
   */
  @Select
  List<OrdChAp> selectOrderByInstCondition (
    String treatStartTime,
    String treatStartDate, String treatEndDate,
    Boolean checker1, Boolean checker2,
    Boolean approver1, Boolean approver2,
    Integer instructorId, String facilityCd
  );

  @Select
  List<OrdMain> selectForSearchFreeBedDate(String facilityCd, Long patId, Long kurCd, List<Integer> treatWeekList, String searchStartDate, String searchEndDate, boolean isAll, Long bedCd);

  /**
   * 実績：確定フラグを更新
   *
   * @param ordNo オーダー番号
   * @param updateTargetIsConfirm 更新対象とする確定フラグの値
   * @param isConfirm 変更する確定フラグの値
   * @return
   */
  @Update(sqlFile = true)
  int updateIsConfirm(Long ordNo, String updateTargetIsConfirm, String isConfirm);

  @Select
  List<OrdMain> selectUpdateIsConfirm(Long ordNo, String updateTargetIsConfirm);

  @Select
  List<OrdMain> selectByRegExamDate(String facility_cd, Long pat_id, String start_date, String end_date, List<String> reg_order_class, List<Integer> weeksArry ,String is_del);

  @Select
  List<OrdMainTreatDate> selectOrdNoList(SelectOptions options, Long pat_id);

  // add FNSI-FutreNetWeb+SI課題管理No.4362 李 start
  @Select
  String selectMaxTreatmentDate(String patId, String facilityCd);
  // add FNSI-FutreNetWeb+SI課題管理No.4362 李 end

  /**
   * 指示・実績：DWを更新
   *
   * @param ordNo オーダー番号
   * @param dw 更新するDW値
   * @return
   */
  @Update(sqlFile = true)
  int updateIndRstDw(Long ordNo, Double dw);

  /**
   * 治療方法の設定で治療条件を更新
   * 「未使用」と設定された項目はJSONに持たせない
   * @param ordNoList 変更対象オーダー番号リスト
   * @param toAddTreatCond 「使用」と設定された項目(JSON文字列)
   * @param toDeleteTreatCondList 「未使用」と設定された項目(文字列リスト)
   * @param isUpdateRst 「実績：治療条件情報」を更新するかフラグ
   */
  @Update(sqlFile = true)
  int updateIndCondInfoWithTreatCondSetting(List<Long> ordNoList, String toAddTreatCond, List<String> toDeleteTreatCondList, Boolean isUpdateRst);

  //add by ztc 2023-02-12 [Optimize no.8099] --start
//  @Update(sqlFile = true)
//  int updateIndCondInfoWithTreatCondSettingList(List<OrdMainTreatmentMethodVo> setOrdMainTMethodVoList);
  //add by ztc 2023-02-12 [Optimize no.8099] --end

  /**
   * 治療方法変更による補液の更新
   * @param ordNoList 変更対象オーダー番号リスト
   * @param isOnline 変更後治療方法のオンライン系フラグ
   */
  @Update(sqlFile = true)
  int updateIndCondInfoWithTreatMethodNonReplenish(List<Long> ordNoList, Boolean isOnline);
  @Select
  List<Long> selectUpdateIndCondInfoWithTreatMethodNonReplenish(List<Long> ordNoList);
  @Update(sqlFile = true)
  int updateIndCondInfoWithTreatMethodReplenish(List<Long> ordNoList, Boolean isOnline);
  @Select
  List<Long> selectUpdateIndCondInfoWithTreatMethodReplenish(List<Long> ordNoList, Boolean isOnline);

  /**
    *
    * @param ordNo
    * @param additioninfo
    * @return
    */
  @Update(sqlFile = true)
  int updateManualAddInfoById(Long ordNo, String additionInfo);

  /**
    * @param facilityCd
    * @param patId
    * @param ordNo
    * @return
    */
  @Select
  List<String> selectAdditionShortName(String facilityCd, Long patId, Long ordNo);

  /**
    * @param facilityCd
    * @param patId
    * @param ordNo
    * @return
    */
  @Select
  List<OrdAdditionInfo> selectAdditionInfo(String facilityCd, Long patId, Long ordNo);
  @Select
  List<OrdAdditionInfo> selectAdditionInfoOtherfacilities(Long ordNo);
  /**
   * 「導入期加算の算定期間」
   *  同月内
   * @param facilityCd 施設コード
   * @param patId 患者ID
   * @param additionCd 加算コード
   * @return
   */
  @Select
  int countMedicalFeeByMonth(String facilityCd, Long patId,String additionCd);

  /**
   * 「導入期加算の算定期間」
   *  日付計算
   * @param facilityCd 施設コード
   * @param patId 患者ID
   * @param additionCd 加算コード
   * @return
   */
  @Select
  int countMedicalFeeByDate(String facilityCd, Long patId, String additionCd);

  /**
   * 「導入期加算の算定期間」
   *  同月内
   * @param ordNo オーダ番号
   * @param patId 患者ID
   * @return
   */
  @Select
  boolean checkDialysisStartDateByMonth(Long ordNo, Long patId);

  /**
   * 「導入期加算の算定期間」
   *  日付計算
   * @param ordNo オーダ番号
   * @param patId 患者ID
   * @return
   */
  @Select
  boolean checkDialysisStartDateByDate(Long ordNo, Long patId);

  /**
    *
    * @param facilityCd
    * @param patId
    * @param ordNo
    * @return
    */
  @Select
  Long selectUsedInMonthByClass(String facilityCd, Long patId);

    /**
      *
      * @param ordNo
      * @param additionInfo
      * @return
      */
  @Update(sqlFile = true)
  int updateAdditionInfoById(Long ordNo, String additionInfo);

  /**
   * 患者ID一覧を取得
   * @param treatDate 治療日
   * @param kurCode 指示：クールコード
   * @param bedGroup ベッドグループコード
   * @return
   */
  @Select
  //抽出条件＞治療予定日による抽出が行われない  6430   shan   start
  List<String> selectPatIdByTreatDate(String treatDate, List<Long> kurCode, Long bedGroup);
  //抽出条件＞治療予定日による抽出が行われない  6430   shan   end
  /**
   * 全治療件数 (rst_diasis_state = 6)
   * @param startDate 開始日
   * @param endDate 終了日
   * @param facilityCd  施設コード
   */
  @Select
  List<ItemFacilityCalendar> getTotalTreatments(String startDate, String endDate, String facilityCd);
  /**
   * 透析治療件数
   * @param startDate 開始日
   * @param endDate 終了日
   * @param facilityCd  施設コード
   * @param deviceModeCd 装置モード (device_mode = 9)
   */
  @Select
  List<ItemFacilityCalendar> getDialysisTreatments(String startDate, String endDate, String facilityCd, int deviceModeCd);
  /**
   * 特殊浄化治療件数
   * @param startDate 開始日
   * @param endDate 終了日
   * @param facilityCd  施設コード
   * @param deviceModeCd 装置モード (device_mode != 9)
   */
  @Select
  List<ItemFacilityCalendar> getSpecialPurificationTreatments(String startDate, String endDate, String facilityCd, int deviceModeCd);

  /* modify by chamaojia 2023-11-07 [9717] クエリー条件がコレクションに変わり、範囲クエリー  --start */
  /**
   * デバイスモードで治療を受ける
   * @param startDate 開始日
   * @param endDate 終了日
   * @param facilityCd  施設コード
   * @param deviceModeCdList 装置モード集合
   */
  @Select
  List<ItemFacilityCalendar> getTreatmentsByDeviceModeCd(String startDate, String endDate, String facilityCd, List<Integer> deviceModeCdList);
  /* modify by chamaojia 2023-11-07 [9717] クエリー条件がコレクションに変わり、範囲クエリー  --end */

  /**
   * クール別治療件数
   * @param startDate 開始日
   * @param endDate 終了日
   * @param facilityCd  施設コード
   */
  @Select
  List<NumberTreatmentsByCourse> getTreatmentsByCourse(String startDate, String endDate, String facilityCd);

  /**
   * 入院患者または外来患者の数
   * @param startDate 開始日
   * @param endDate 終了日
   * @param facilityCd  施設コード
   * @param rstInOutClass 実績：入外区分
   */
  @Select
// mod 障害票一覧_施設カレンダー 修正 chen start
  // List<ItemFacilityCalendar> getTreatmentsByRstInOutClass(String startDate, String endDate, String facilityCd, int rstInOutClass);
  List<ItemFacilityCalendar> getTreatmentsByRstInOutClass(String startDate, String endDate, String facilityCd, List<String> patIdList);
// mod 障害票一覧_施設カレンダー 修正 chen end

  // add 11702 施設カレンダーで過去の集計件数が変わってしまう zkm start
  /**
   * 実績の入院患者または外来患者の数
   * @param startDate 開始日
   * @param endDate 終了日
   * @param facilityCd  施設コード
   * @param rstInOutClass 実績：入外区分
   */
   @Select
   List<ItemFacilityCalendar> getRstTreatmentsByInOutClass(String startDate, String endDate, String facilityCd, int rstInOutClass);
  // add 11702 施設カレンダーで過去の集計件数が変わってしまう zkm end

  /**
   * 患者IDリストのオーダーを取得する
   * @param patIds 患者IDリスト
   * @param facilityCd 施設コード
   * @param treatDate 治療日
   */
  @Select
  List<OrdMainKurBed> selectByPatIdsWithBedAndKur(List<Long> patIds, String facilityCd, String treatDate);

  /**
   * @param facilityCd 施設コード
   * @param patId 患者ID
   * @param additionCd 加算コード
   * @param treatDate 治療日
   * @param mStartDate 治療日の月始め日付
   */
  @Select
  boolean checkExistAdditionByTreateDate(String facilityCd, Long patId, String additionCd, String treatDate, String mStartDate);

  /**
   * オーダ番号に該当する治療方法マスタを取得する.
   * 実績情報の治療方法マスタが<code>null</code>の場合には、指示情報に登録されている治療方法マスタを取得する.
   * 実績情報、指示情報の両方の治療方法マスタが<code>null</code>の場合には、<code>null</code>を返却する.
   *
   * @param ordNo オーダ番号
   * @return オーダ番号に登録されている治療方法マスタ(実績情報 or 指示情報)
   */
  @Select
  MstTreatment selectMstTreatmentByOrdNo(Long ordNo);
 /**
   * 対象施設の最新登録データを取得
   * @param facilityCd
   * @return 透析情報クラス
   */
  @Select
  OrdMain selectLastByFacilityCd(String facilityCd);

  /**
   * 受信時登録
   *
   * @param ordMain 透析情報クラス
   * @return 登録件数
   */
  @Insert(sqlFile = true)
  int insertReceive(OrdMain ordMain);

  /**
   * 受信時更新
   *
   * @param ordMain 透析情報クラス
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateReceive(OrdMain ordMain);



  /**
   * 治療進捗状況更新用に指定患者でrst_dialysis_stateが1～5のものを取得する
   * @param patId 患者ID
   * @return 条件に合致する治療情報一覧
   */
  @Select
  // mod FNSI-改修内容 患者情報共通ヘッダー外結No4対応 趙 start
  // List<OrdMainForAcceptanceStatusInfo> selectByPatIdForUpdateAcceptanceStatusInfo(Long patId);
  List<OrdMainForAcceptanceStatusInfo> selectByPatIdForUpdateAcceptanceStatusInfo(Long patId, String sysDate);
  // mod FNSI-改修内容 患者情報共通ヘッダー外結No4対応 趙 end

  // add FNSI-改修内容追加OrdMain履歴 付 start
  /**
   * historyコピー用SQL
   */
  @Select
  List<OrdMain> selectHistory(Integer mode, Long ordNo, Long patId, List<Long> ordNoList, List<Long> kurList,
                              String facilityCd, Boolean isOnline, String updateTargetIsConfirm,
                              String startDate, String endDate, List<Integer> week,List<Integer> treatMethod,
                              String condTreatDate, String treatDate, Integer treatWeek,
                              List<Long> treatmentCdList, String dialysisDateFrom, String dialysisDateTo
                              );
  // add FNSI-改修内容追加OrdMain履歴 付 end
//add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s start
  /**
   * 患者IDリストのオーダーを取得する
   * @param facilityCd 施設コード
   * @param treats 治療方法コード
   * @param isNotSent 実績：治療状況 条件送信前
   */
  @Select
  List<OrdMain> selectByTreatmentCd(String facilityCd, Integer treats, boolean isNotSent,List<Long> ordNoList);
//add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s end
  /*mod #8495 by zhangruixue 2023-03-27  GC overhead limit exceeded start*/
  @Select
  List<Long> selectOrdNoByTreatmentCd(String facilityCd, Integer treats, boolean isNotSent);
  /*mod #8495 by zhangruixue 2023-03-27  GC overhead limit exceeded end*/
  // add 8235 周安寧 start
  @Select
  List<OrdMain> selectByTreatmentCdUpdateAll(String facilityCd, Integer treats, boolean isNotSent);
  // add 8235 周安寧 end
  /* mod #8677  治療方法マスタを変更保存するとシステムが停止する。 by zhangruixue 2023-05-25 --start */
  /**
   *Gets  field in the ord_main table
   *     ord_no,
   *     pat_id,
   *     treat_date,
   *     treat_week,
   *     facility_cd,
   *     ind_treatment_cd,
   *     ind_kur_cd,
   *     ind_bed_cd,
   *     up_ind_user_id,
   *     up_user_id
   */
  @Select
  List<OrdMain> selectByFacilityCdTreatmentCd(String facilityCd, Integer treats, boolean isNotSent);
  // add 9664 by kangjie 20231206 start
  @Select
  List<OrdMain> selectTreatmentInfoByOrdNo(List<Long> ordNoList);
  // add 9664 by kangjie 20231206 end

  /* mod #8677  by zhangruixue 2023-05-25 --end */
  //FNSI-修正 共有設定追加 start
  @Select
  List<OrdMainTreatDate> selectOrdNoListWithShared(SelectOptions options, Long pat_id, List<String> states);
  //FNSI-修正 共有設定追加 end
  // add FNSI-分類不一致判断の追加 徐 start
  @Select
  List<OrdMain> selectChkIndCondInfoData(Long ordNo, Long ordNos);

  @Select
  MstEquipmentMstMedicine selectClassTypeFromMstEquipment(int cd, String facilityCd);

  @Select
  MstEquipmentMstMedicine selectClassTypeFromMstMedicine(int cd, String facilityCd);

  @Select
  MstEquipmentMstMedicine selectClassTypeFromMstMedicineMix(int cd, String facilityCd);
  //add 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
  @Select
  List<MstEquipmentMstMedicine> selectClassTypeFromMstEquipmentByFacility(String facilityCd);
  @Select
  List<MstEquipmentMstMedicine> selectClassTypeFromMstEquipmentByFacility1(String facilityCd);
  @Select
  List<MstEquipmentMstMedicine> selectClassTypeFromMstEquipmentByFacility2(String facilityCd);
//add 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
  // add FNSI-分類不一致判断の追加 徐 end

  //add クールマスタ 王 start
  @Select
  List<OrdMain> selectByFacilityCd(String facilityCd);
  /*mod #8494 by zhangruixue 2023-03-27  GC overhead limit exceeded start*/
  @Select
  List<Long> selectOrdNoByFacilityCd(String facilityCd);
  /*mod #8494 by zhangruixue 2023-03-27  GC overhead limit exceeded end*/

  @Select
  OrdMain selectByStatue(String facilityCd, List<String> state);

  @Select
  List<OrdMain> selectKurByFacilityCd(String facilityCd);
  //add クールマスタ 王 end

// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou start
  @Select
  List<TemplateOrdMain> selectTemplateOrdMain(List<Long> patIdList, String facilityCd, String startDate, String endDate);

  @Select
  List<TemplateMachine> selectTemplateMachine(List<Long> patIdList, String facilityCd, String startDate, String endDate);

  @Select
  List<TemplateMonitor> selectTemplateMonitor(List<Long> patIdList, String facilityCd, String startDate, String endDate);

  @Select
  List<TemplateMedicine> selectTemplateMedicine(String facilityCd);

  @Select
  List<TemplateMedicine> selectTemplateMedicineMix(String facilityCd);

  @Select
  List<OrdMain> selectByPatIdListFacilityCd(List<Long> patIdList, String facilityCd, String startDate, String endDate);

   //mod #11034 データリストにてテンプレートに「治療予定・治療記録」をつかっているレイアウトでは最大50件までしか表示されない zrx start
  //No.7167 upd Paging Optimization runtime by ztc start
//  @Select
//  List<OrdMain> selectByPatIdListFacilityCdByLimitAndOffset(List<Long> patIdList, String facilityCd, String startDate, String endDate, Integer limit, Integer offset, Boolean isOnlyRst);
//No.7167 upd Paging Optimization runtime by ztc end
  @Select
  List<OrdMain> selectByPatIdListFacilityCdByLimitAndOffset(List<Long> patIdList, String facilityCd, String startDate, String endDate, Boolean isOnlyRst);
  //mod #11034 データリストにてテンプレートに「治療予定・治療記録」をつかっているレイアウトでは最大50件までしか表示されない zrx end

  @Select
  List<TemplateHospitalCd> selectCdByPatIdListFacilityCd(List<Long> patIdList, String facilityCd, String startDate, String endDate);

  //No.7167 upd Paging Optimization runtime by ztc start
  @Select
  List<TemplateHospitalCd> selectCdByPatIdListFacilityCdByIsOnlyRst(List<Long> patIdList, String facilityCd, String startDate, String endDate, Boolean isOnlyRst);
//No.7167 upd Paging Optimization runtime by ztc end

  @Select
  List<OrdMain> selectByPatIdFacilityCd(Long patIdList, String facilityCd, Timestamp startDate);

// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou end

  // add FNSI-最終更新指示者のカラム追加と更新処理 楊 start
  /**
   * 最終更新指示者のカラム追加と更新
   * @param ordNoList　オーダー番号リスト
   * @param up_ind_user_id 最終更新指示者ID
   * @param up_user_id 最終更新者ID
   */
  @Update(sqlFile = true)
  // mod FNSI-sqlパフォーマンスの最適化 李 start
  // int updateUpUseId(List<Long> ordNoList, Long up_ind_user_id, Long up_user_id);
  int updateUpUseId(Long ordNo, Long up_ind_user_id, Long up_user_id);
  // mod FNSI-sqlパフォーマンスの最適化 李 end
  // add FNSI-最終更新指示者のカラム追加と更新処理 楊 end

  // add FNSI-No.341 患者リストのソート項目不足 吉 start
  @Select
  List<OrdMain> selectAllByPatIdList(List<Long> patIdList,String facilityCd);
  // add FNSI-No.341 患者リストのソート項目不足  吉 end
// add FNSI-No196 透析前後の判断の最適化 関 start
  @Select
  List<OrdMain> selectPatOrdMainByTreatDate(Long patId, String facilityCd, String treatDate);
  @Select
  List<OrdMain> selectPatOrdMainAfterTreatDate(Long patId, String facilityCd, String treatDate);
  //add 9480 実績情報-前回からの体重増加量（Kg），前回後の体重を調べる gjn start
  @Select
  List<OrdMain> selectPatOrdMainLastTreatDate(Long patId, String facilityCd, String treatDate);
  //add 9480 実績情報-前回からの体重増加量（Kg），前回後の体重を調べる gjn end
  @Select
  List<OrdMain> selectPatOrdMainBetweenDate(Long patId, String facilityCd, String startDate, String endDate);
// add FNSI-No196 透析前後の判断の最適化 関 end
// add 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
  @Select
  List<OrdMain> selectPatOrdMainBetweenTreatDate(Long patId, String facilityCd, String startDate, String endDate);
  // add 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 end
  // add FNSI-No.396 使用物品の指示、レセ換算結果の保持に対応 李 start
  @Select
  List<String> selectOrdNo(String patId, String facilityCd, String treatDate);
  // add FNSI-No.396 使用物品の指示、レセ換算結果の保持に対応 李 end
/*add FNSI-改修内容538 連携イベントの登録適正化 任 start*/
  @Select
  OrdMain selectTreatDate(Long ordNo);
  /*add FNSI-改修内容538 連携イベントの登録適正化 任 end*/
// add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s start
  /**
   * 治療方法変更による補液の更新
   * @param ordNoList 変更対象オーダー番号リスト
   * @param isOnline 変更後治療方法のオンライン系フラグ
   */
  @Update(sqlFile = true)
  int updateIndCondInfoWithTreatMethodNonReplenishSup(List<Long> ordNoList, Boolean isOnline, Long deviceMode);

  @Select
  List<Long> selectUpdateIndCondInfoWithTreatMethodNonReplenishSup(List<Long> ordNoList, Long deviceMode);

  //7734 指示者変更の場合 lig stsrt
  @Update(sqlFile = true)
  int updateInduser(Long ord_no, String ind_schedule_user_info);
  //7734 指示者変更の場合 lig end
  @Update(sqlFile = true)
  int updateIndCondInfoWithTreatMethodReplenishSup(List<Long> ordNoList, Boolean isOnline, Long deviceMode);

  @Select
  List<Long> selectUpdateIndCondInfoWithTreatMethodReplenishSup(List<Long> ordNoList, Boolean isOnline, Long deviceMode);
// add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s END

  // add FNSI-薬剤、医療材料の表示順の設定を追加する 李 start
  @Select
  //mod FNSI-7270 劉全航 start
  //List<FacilitySettingNoDisplayOrder> selectMedEquipDisplayOrder();
  List<FacilitySettingNoDisplayOrder> selectMedEquipDisplayOrder(String facilityCd);
  //mod FNSI-7270 劉全航 end
  // add FNSI-薬剤、医療材料の表示順の設定を追加する 李 end

  /**
   * 対象治療予定の装置モードが特殊浄化かどうか判定
   * @param ordNo オーダ番号
   * @return
   */
  @Select
  boolean checkSpecialPurification(Long ordNo);

  /**
   * 治療日が対象オーダー番号と同じ月の登録データを取得
   * @param facilityCd
   * @param patId
   * @param ordNo
   * @return
   */
  @Select
  List<OrdMain> selectBySameMonth(String facilityCd, Long patId, Long ordNo);

  /**
   * 治療日が指定期間内の登録データを取得
   * @param facilityCd
   * @param patId
   * @param searchStartDate 開始日 YYYY-MM-DD形式
   * @param searchEndDate 終了日  YYYY-MM-DD形式
   * @return
   */
  @Select
  List<OrdMain> selectByPeriod(String facilityCd, Long patId, String searchStartDate, String searchEndDate);

  /**
   * 同月内の治療実績から同加算項目(コード検索)がONの件数をカウント
   * @param facilityCd
   * @param patId
   * @param ordNo
   * @param additionCd
   * @return
   */
  @Select
  Long countExistAdditionBySameMonth(String facilityCd, Long patId, Long ordNo, String additionCd);

  /**
   * 治療情報から、対象患者の加算情報-算定日のリストを取得する
   * @param ordNo
   * @param facilityCd
   * @param patId
   * @param treatDate
   * @return
   */
  @Select
  List<AdditionInfoOrdMain> selectCalculationDateList(Long ordNo, String facilityCd, Long patId, String treatDate);
  //add #12462 患者情報共有 zrx start
  @Select
  List<AdditionInfoOrdMain> selectCalculationDateListOtherfacilities(Long ordNo, String facilityCd, Long patId, String treatDate);
  //add #12462 患者情報共有 zrx end
  /**
   * 当日のベッド未登録件数を取得する
   * @param facilityCd 施設コード
   * @return 当日のベッド未登録件数
   */
  @Select
  int countTodayBedNotSet(String facilityCd);

  /**
   * 当日のクール未登録件数を取得する
   * @param facilityCd 施設コード
   * @return 当日のクール未登録件数
   */
  @Select
  int countTodayKurNotSet(String facilityCd);

  // add FNSI-マスタ削除表示の対応課題--治療方法 李 start
  /**
   * 治療方法コードで、治療方法名を取得する
   * @param treatmentCd 治療方法コード
   * @return 治療方法名
   */
  @Select
  String selectMstTreatmentNameByCd(String treatmentCd);
  // add FNSI-マスタ削除表示の対応課題--治療方法 李 end

  // add FNSI-マスタ削除表示の対応課題--予実リスト 鄧シン start
  /**
   * ベッドコードで、ベッドを取得する
   * @param bedCd ベッドコード
   * @return ベッド名
   */
  @Select
  String selectMstBedNameByCd(String bedCd);
  /**
   * クールコードで、クールを取得する
   * @param kueCd クールコード
   * @return クール名
   */
  @Select
  String selectMstKurNameByCd(String kurCd);
  // add FNSI-マスタ削除表示の対応課題--予実リスト 鄧シン end
  // redmine 4672  姜 start
  @Select
  Integer getIndVaCd(Long ordNo);
  // redmine 4672  姜 end
  /*add FNSI-改修内容4608 任 start*/
  @Select
  // mod 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
  // List<Long> selectReportCd(Long patId, Integer times);
  List<Long> selectReportCd(String facilityCd,Long patId, Integer times);
  // mod 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end
  /*add FNSI-改修内容4608 任 end*/
  /*add FNSI-改修内容5984 任 start*/
  @Select
  List<OrdMain> selectOrdNoListForReport(List<Long> patIdList, String treatDate);
  /*add FNSI-改修内容5984 任 end*/
  //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
  @Select
  List<OrdMain> selectByBase(String facilityCd,String baseDate,String fromDate,String toDate);
  //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
//  add  FNSI 外来/入院患者治療予定件数の不正 5886修正 shan start
  @Select
  List<TreatDatePatIdList> getTreatmentsTreatDate(List<String> treatDateList);
//  add  FNSI 外来/入院患者治療予定件数の不正 5886修正 shan　end
  @Select
  List<OrdMain> selectDelete(
          Long ord_no,
          Long pat_id,
          String dialysis_date_from,
          String dialysis_date_to,
          List<Integer> treatment_cd,
          List<Integer> kur_cd);

  //add redmine bug#6392 劉 start
  @Select
  List<LcdReq36> selectCompAndTreatMessage(String facilityCd, String machineTypeCd, String machineSerial, Timestamp fromDate, long ordNo, int offset);
  //add redmine bug#6392 劉 end

  /**
   * 身体情報のDW変更時に、
   * 画面指定検査日時～DWが登録されている最新の身体情報の検査日時の期間にある
   * rst_dialysis_state＞0の透析予定件数を検索する。
   *
   * @param patId 患者ID
   * @param startDate 画面指定検査日時(YYYYMMDD)
   * @return 件数
   */
  @Select
  int countStateIsNotZero(Long patId, String startDate);
  @Select
  List<Integer> allStateIsNotZero(Long patId, String startDate);
  //add redmine bug#5880 劉 start
  /**
   * 仮想端末情報（投与薬剤）.
   *
   * @param ordNo       マスタ定義
   * @param facilityCd  施設コード
   * @return 該当データ(HashMapのリスト)
   */
  public default List<LcdReq41> getRstMediInfo(Long ordNo, String facilityCd, String orderList) {
    SelectBuilder builder = SelectBuilder.newInstance(Config.get(this));
    StringBuilder strSql = new StringBuilder();
    strSql.append(" SELECT ");
    strSql.append("tt3.idx,");
    strSql.append("tt3.sno,");
    strSql.append("tt3.name,");
    strSql.append("tt3.unit,");
    strSql.append("tt3.amount,");
    strSql.append("tt3.effect_flg,");
    strSql.append("tt3.effect_date,");
    strSql.append("tt3.is_medicated,");
    strSql.append("tt3.progress_cd,");
    strSql.append("tt3.alert_time,");
    strSql.append("tt3.is_alert");
    strSql.append(" FROM ");
    strSql.append(" (SELECT ");
    strSql.append("info.idx AS idx,");
    strSql.append("medi ->> 'no' AS sno,");
    strSql.append("medi ->> 'name' AS name,");
    strSql.append("medi ->> 'unit' AS unit,");
    strSql.append("medi ->> 'amount' AS amount,");
    strSql.append("medi ->> 'effect_flg' AS effect_flg,");
    strSql.append(" CASE WHEN medi ->> 'effect_date' IS NULL OR medi ->> 'effect_date' = 'null'");
    strSql.append(" THEN NULL ");
    strSql.append(" ELSE TO_TIMESTAMP(medi ->> 'effect_date', 'YYYY-MM-DD\"T\"HH24:MI:SS')");
    strSql.append(" END AS effect_date,");
    strSql.append(" CASE WHEN medi ->> 'medicine_type' = '2'");
    strSql.append(" THEN (SELECT A .is_medicated FROM mst_medicine_mix A WHERE (medi ->> 'cd') :: INT = A.medicine_mix_cd AND A.is_disp = '1' AND A.is_del = '0')");
    strSql.append(" ELSE (SELECT B.is_medicated FROM mst_medicine B WHERE (medi ->> 'cd') :: INT = B.medicine_cd AND B.is_disp = '1' AND B.is_del = '0')");
    strSql.append(" END AS is_medicated,");
    strSql.append("mst_t.dialysis_progress_cd AS progress_cd,");
    // mod FNSI-バグ 通信サーバ  #5798 高 start
    // strSql.append("COALESCE (mst_t.alert_time, - 1) AS alert_time,");
    strSql.append(" CASE WHEN mst_t.is_alert = '1'");
    strSql.append(" THEN COALESCE(mst_t.alert_time, -1)");
    strSql.append(" ELSE '-1'");
    strSql.append(" END as alert_time,");
    // mod FNSI-バグ 通信サーバ  #5798 高 end
    strSql.append("mst_t.is_alert AS is_alert,");
    strSql.append(" CASE WHEN medi ->> 'medicine_type' = '2'");
    strSql.append(" THEN tt2.INDEX * 1000");
    strSql.append(" ELSE tt1.INDEX");
    strSql.append(" END AS index1,");
    strSql.append("CAST(medi ->> 'class_cd' AS INT) AS class_cd,");
    strSql.append("medi ->> 'medicine_type' AS medicine_type,");
    strSql.append("CAST(medi ->> 'timing_cd' AS INT) AS timing_cd,");
    strSql.append("CAST(medi ->> 'procedure_cd' AS INT) AS procedure_cd,");
    strSql.append("CAST(medi ->> 'date_interval' AS INT) AS date_interval");
    strSql.append(" FROM ");
    strSql.append("ord_main AS ord");
    strSql.append(" CROSS JOIN LATERAL ");
    strSql.append("json_array_elements (ord.rst_medi_info :: json) WITH ORDINALITY AS info (medi, idx)");
    strSql.append(" LEFT JOIN ");
    strSql.append("mst_medicate_timing mst_t ON (medi ->> 'timing_cd') :: INT = mst_t.medicate_timing_cd");
    // del FNSI-バグ 通信サーバ  #5798 高 start
    // strSql.append(" AND mst_t.is_alert = '1'");
    // del FNSI-バグ 通信サーバ  #5798 高 end
    strSql.append(" AND mst_t.is_del = '0'");
    strSql.append(" LEFT JOIN ");
    strSql.append(" (SELECT * ");
    strSql.append(" FROM ");
    strSql.append("mst_medicine A,");
    strSql.append(" (SELECT ");
    strSql.append("mss.facility_cd,");
    strSql.append("ms.* ,");
    strSql.append("ROW_NUMBER ( ) OVER ( ) AS INDEX");
    strSql.append(" FROM ");
    strSql.append("mst_selector mss");
    strSql.append(" CROSS JOIN LATERAL ");
    strSql.append("jsonb_to_recordset (mss.order_settings -> 'items') AS ms (code BIGINT, NAME TEXT)");
    strSql.append(" WHERE ");
    if (!Strings.isNullOrEmpty(facilityCd)) {
      strSql.append("facility_cd = '").append(facilityCd).append("' ");
      strSql.append(" AND ");
    }
    strSql.append("master_physical_name = 'mst_medicine'");
    strSql.append(")ms");
    strSql.append(" WHERE A.facility_cd = ms.facility_cd");
    strSql.append(" AND A.medicine_cd = ms.code");
    strSql.append(" AND A.is_del = '0'");
    strSql.append(" AND A.is_disp = '1'");
    strSql.append(")tt1 ON tt1.medicine_cd = (medi ->> 'cd') :: INT");
    strSql.append(" LEFT JOIN ");
    strSql.append(" (SELECT * ");
    strSql.append(" FROM ");
    strSql.append("mst_medicine_mix A,");
    strSql.append(" (SELECT ");
    strSql.append("mss.facility_cd,");
    strSql.append("ms.* ,");
    strSql.append("ROW_NUMBER ( ) OVER ( ) AS INDEX");
    strSql.append(" FROM ");
    strSql.append("mst_selector mss");
    strSql.append(" CROSS JOIN LATERAL ");
    strSql.append("jsonb_to_recordset ( mss.order_settings -> 'items' ) AS ms ( code BIGINT, NAME TEXT )");
    strSql.append(" WHERE ");
    if (!Strings.isNullOrEmpty(facilityCd)) {
      strSql.append("facility_cd = '").append(facilityCd).append("' ");
      strSql.append(" AND ");
    }
    strSql.append("master_physical_name = 'mst_medicine_mix'");
    strSql.append(")ms");
    strSql.append(" WHERE A.facility_cd = ms.facility_cd");
    strSql.append(" AND A.medicine_mix_cd = ms.code");
    strSql.append(" AND A.is_del = '0'");
    strSql.append(" AND A.is_disp = '1'");
    strSql.append(")tt2 ON tt2.medicine_mix_cd = (medi ->> 'cd') :: INT");
    strSql.append(" WHERE ");
    strSql.append("ord.ord_no = '").append(ordNo.toString()).append("' ");
    strSql.append(" ORDER BY ");
    if (!Strings.isNullOrEmpty(orderList)) {
      strSql.append(orderList);
      strSql.append(", ");
    }
    strSql.append("info.idx ");
    strSql.append(")tt3;");

    String stringSql = strSql.toString();
    builder.sql(stringSql);
    return builder.getEntityResultList(LcdReq41.class);
  }
  //add redmine bug#5880 劉 end
//add 7307 曜日変更bug 張 start
 @Select
    List<OrdMain> selectByFacilityCdAndTreatDate(String facilityCd, String treatDate, Short treatWeek, Integer indKurCd, Integer indBedCd);
  @Select
    List<OrdMain> selectByPatIdAndDeviceMode(String facilityCd,Long patId, Integer mode);
  @Select
  List<OrdMain> selectBySingleNeedle(String facilityCd, Long patId);

  // add bug 7810 修正 start
  @Select
  List<OrdMain> selectByAuxiliaryLiquidAndDeviceMode(String facilityCd, Long patId,List<Integer> deviceModeLiat,Double auxiliaryLiquid);
  @Select
  List<OrdMain> selectByBloodFlowAndDeviceMode(String facilityCd, Long patId, Double dstBloodFlow);
  @Select
  List<OrdMain> selectByDialysisFluidTemperatureAndDeviceMode(String facilityCd, Long patId, Double dstDialysisFluidTemperatureUp, Double dstDialysisFluidTemperatureDown);
  // add bug 7810 修正 end

//add 7307 曜日変更bug 張 end
  // add #7641 自動印刷で値が入らない項目がある 鄭爽 start
  @Select
  OrdMain selectRstDialysisState(Long ordNo);
  // add #7641 自動印刷で値が入らない項目がある 鄭爽 end

  // add #7194 OHDF・OHFで濾過率から算出に設定すると補液速度と補液量が不適切 dou start
  @Update(sqlFile = true)
  int updateIndCondInfo(Long ordNo, String indCondInfo);
  // add #7194 OHDF・OHFで濾過率から算出に設定すると補液速度と補液量が不適切 dou end

  // add #7524 2022/11/10 同日同クールで同時に透析治療が実施できてしまう dou start
  @Select
  Integer checkSameOrd(Long patId, String treatDate, Integer kurCd);
  // add #7524 2022/11/10 同日同クールで同時に透析治療が実施できてしまう dou end
//    del 8074 【デグレ】ログに誤った利用者が記録される 関 start
//  add 8074 【デグレ】ログに誤った利用者が記録される 関 start
//  @Update(sqlFile = true)
//  int updateUseId(Long ordNo,Long upUserId);
//  add 8074 【デグレ】ログに誤った利用者が記録される 関  end
//    del 8074 【デグレ】ログに誤った利用者が記録される 関  end
  // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
  // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen start
  @Update(sqlFile = true)
  int updateUseId(Long ordNo,Long upUserId);
  // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen end
  @Select
  List<Long> selectOrdnoByPatIdNear(String facilityCd,Long patId, Integer times);
  // add 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end

  //add 8179+8011 GX-常勤医空白の場合条件判断です  ljg start
  @Select
  String  selectDocterblank(String facilityCd,Long ordNo,String coopcd,String crud);

  @Select
  String  selectExamdoctor(String facilityCd,Long ordNo,String crud);
  //add 8179+8011 GX-常勤医空白の場合条件判断です  ljg end
  // add #6127 モニタ変更する際に、変更履歴で必要の版番号を取得。ljx start
  @Select
  OrdMain selectEdition(Long ordNo);
// add #6127 モニタ変更する際に、変更履歴で必要の版番号を取得。ljx end
//upd by ztc 2023-03-20 Treatment method change branch 2, 3 optimization --start /
  @Update(sqlFile = true)
  int updateOrdMainEsListener(List<OrdMainEsListener> uptOrdList);

//  @Update(sqlFile = true)
//  int[] batchUpdateOrdMainScheduleInfo(List<OrdMainUptSchInfoVo> ordMainUptSchInfoVoList);

  @BatchUpdate(sqlFile = true)
  @Suppress(messages = { Message.DOMA4182 })
  int[] updateOrdMainScheduleInfoByOrdNo(List<OrdMainUptSchInfoVo> ordMainUptSchInfoVoList);
//upd by ztc 2023-03-20 Treatment method change branch 2, 3 optimization --end /

  //add 8360 ljx start
  /**
   * bvms path更新
   *
   * @param ord_no オーダー番号
   * @param bvmsPath bvms path
   * @return
   */
  @Update(sqlFile = true)
  int updateBvmsPath(Long ordNo, String bvmsPath);
  //add 8360 ljx end

  // add #8144 【デグレ】検査計算結果が検査後にしか反映されない 関 start
  @Select
  List<OrdMainListInfo> selectCdByFacilityCd(String pat_id, String treat_date_from, String treat_date_to, Long ord_no, Integer edition, String is_del);
  // add #8144 【デグレ】検査計算結果が検査後にしか反映されない 関 end
  // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
  @Select
//  add #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　start
//  List<Long> selectOrdnoByPatId(String facilityCd,Long patId, String fromDate, String toDate);
  List<Long> selectOrdnoByPatId(String facilityCd,Long patId, String fromDate, String toDate,String rstDialysisState);
//  add #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　end
  // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end

  // add 11010 スケジュール表出力時の処理が不足している gjn start
  @Select
  List<OrdMain> selectAllByPatIdAndTreatDate (String facilityCd,List<Long> patIds, String fromDate, String toDate);
  // add 11010 スケジュール表出力時の処理が不足している gjn end
  // add #9323 donghao start
  @Select
  String getInOutClass(String facilityCd, String ordNo, String patId);
  // add #9323 donghao end

  //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
  @Select
  List<OrdMain> checkChangedOrdMainAndGetAllOrdNo(String facilityCd);

  @Update(sqlFile = true)
  int resetAllChangedOrdMain(String allOrdNo, Long userId, String userLastName, String userFirstName, Long updUserId, String updUserLastName, String updUserFirstName);

  @Update(sqlFile = true)
  int setAllEmptyTreatStartDate(String facilityCd);

  // add #10282 fixed OOM issue. ztc 20240516 start
  //mod #10634 クールマスタで標準治療開始時刻を変更した際のダミー予定・連携イベント作成処理不正 zrx start
//  @Select
//  List<Long> getAllUndeleteBedCdData(String facilityCd);
  @Select
  List<Long> getAllUndeleteBedCdData(String facilityCd, List<MstKur> oldMstKurList);
  //mod #10634 クールマスタで標準治療開始時刻を変更した際のダミー予定・連携イベント作成処理不正 zrx end
  // add #10282 fixed OOM issue. ztc 20240516 end

  @Select
  // mod #10282 fixed OOM issue. ztc 20240516 start
//  List<OrdMain> getAllUndeleteData(String facilityCd);
  List<OrdMain> getAllUndeleteData(String facilityCd, Long bedCd);
  // mod #10282 fixed OOM issue. ztc 20240516 end

  @Select
  List<OrdMainForCsv> getAllDataBeforeChange(String allOrdNo);
  //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end
  //add 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start
  @Select
  List<OrdMainMedicineDelete> getPatIndMmdicine(OrdMainRequest ordMainRequest);
  @Select
  List<OrdMainMedicineDelete> getPatIndAndRstMmdicine(OrdMainRequest ordMainRequest);
  //add 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end

  // #10338 2024.03.26 add 治療ステータスのみ先行して更新するためのDAO TDC片口 start
  /**
   * rst_dialysis_stateのみを更新する
   * @param ordNo 対象ord_no
   * @param rstDialysisState 更新する値
   * @return 影響を受けた行数
   */
  @Update(sqlFile = true)
  int updateRstDialysisState(Long ordNo, String rstDialysisState);
  // #10338 2024.03.26 add 治療ステータスのみ先行して更新するためのDAO TDC片口 end
  // #10337 2024.04.25 add 治療ステータスと版番号更新フラグのみ更新するためのDAO TDC片口 start
  /**
   * rst_dialysis_state=6とし、版番号更新フラグの更新を行う
   * @param ordNo 対象ord_no
   * @return 影響を受けた行数
   */
  @Update(sqlFile = true)
  int updateDialysisStateFinishBeforeEditionUp(Long ordNo);
  /**
   * medi_infoと版番号の同時更新
   * @param ordNo オーダー番号
   * @param mediInfo 投薬情報のJSON文字列
   * @return 実行件数
   */
  @Update(sqlFile = true)
  int updateMediInfoAndEditionUp(Long ordNo, String mediInfo);
  // #10337 2024.04.25 add 治療ステータスと版番号更新フラグするためのDAO TDC片口 end

  //add #10185 DW一括登録時に連携イベントが発生しない zhaoqi 20240105 start

  @Select
  List<OrdMain> getAllOrdNoWithStateIsNotZero(List<Long> patIdList);
  //add #10185 DW一括登録時に連携イベントが発生しない zhaoqi 20240105 end

  // add #9577 「？？？？」患者は表示されません（複数患者帳票）。 2024/03/18 高 start
  @Select
  List<OrdMain> selectOrdMainByNullPatId(String facilityCd, String fromDate, String toDate);
  // add #9577 「？？？？」患者は表示されません（複数患者帳票）。 2024/03/18 高 end

  //add #10412 次患者更新関連全体見直し対応 朴 start
  @Select
  List<OrdMain> selectByListConditionForMstNextPatInfo1or2Changed(String facilityCd, List<Long> ordNoList, List<Integer> treatmenCdList, List<Integer> kurCdList
    , List<Long> bedCdList, List<Long> bedCdForMemoList, List<Long> bedCdForMemoForEquipmentList
    , List<Long> bedCdForMemoForDialyzerList, List<Long> bedCdForMemoForPrimaryMembraneList, List<Long> bedCdForMemoForANeedleMembraneList, List<Long> bedCdForMemoForVNeedleMembraneList
    , List<Long> bedCdForMemoForDialysateList, List<Long> bedCdForMemoForAnticoagulantList
    , List<Integer> dialyzerCdList, List<Integer> dialyzerCdForMemoList, List<Long> patIdForMemoList, List<Integer> vaCdForMemoList, List<Integer> treatmenCdForMemoList
    , List<Integer> mstEquipmentCdForMemoList, List<Integer> mstMedicineCdForMemoList, List<Integer> mstMedicineMixCdForMemoList);
  //add #10412 次患者更新関連全体見直し対応 朴 end

  // Add #10344 指定投薬最新識別番号を更新する Start
  /** 指定投薬最新識別番号を更新する */
  @Update(sqlFile = true)
  Result<MedicineLatestNo> updatePatMedicineNo(MedicineLatestNo updCond);
  // Add #10344 指定投薬最新識別番号を更新する End

  // add FNSI-医療材料最新識別番号を更新する start
  /** 指定医療材料最新識別番号を更新する */
  @Update(sqlFile = true)
  Result<EquipmentLatestNo> updatePatEquipmentNo(EquipmentLatestNo updCond);
  // add FNSI-医療材料最新識別番号を更新する end

  // add 9664 by kangjie 20240513 start
  @Select
  OrdMainConditionSetting findFutureOrdMainConditionInfo(Long patId, String facilityCd, String treatDateFrom, String treatDateTo, List<Integer> weeks, List<Integer> treats, List<Long> kurs);

  @Select
  List<Integer> findFutureOrdMainConditionIsUsedCtlNos(Long patId, String facilityCd, String treatDateFrom, String treatDateTo, List<Integer> weeks, List<Integer> treats, List<Long> kurs);
  // add 9664 by kangjie 20240513 end

  // add #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc start
  @Select
  int findByPatIdDateListCd(String facility_cd, Long pat_id, List<Map<String, String>> moveOutDateMapList);
  // add #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc end

  // Add #10443 Start
  @Update(sqlFile = true)
  int updateTargetWeightByPhyInfo(List<OrdMainForUpdTargetWeightDTO> updTargetWeight);
  // Add #10443 End

  // add 10443 身体情報・DW・目標体重バグ 関  start
  @Select
  OrdMain selectFirstTreatDate(Long patId, String facilityCd, String treatDateFrom, List<Integer> weeks, List<Integer> treats, List<Long> kurs, boolean isIndFlag);
  // add 10443 身体情報・DW・目標体重バグ 関  end

  /* #10443 ADD 測定日と同日の治療日の治療データから、測定タイミングと一致する体重を対象にデータ取得をする Start */
  @Select
  List<OrdMainLatelyWeightInfo> getNearestWeightRecordForPat(String facilityCd, Long patId, String treatDate, String treatTime);
  /* #10443 ADD 測定日と同日の治療日の治療データから、測定タイミングと一致する体重を対象にデータ取得をする End */

  // add #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　start
  @Select
  List<OrdMain> selectByBaseforPatAndOrd(String facilityCd,String baseDate);

  @Select
  OrdMain selectBedCdByPatAndOrd(Long patId,Long ordNo);
  // add #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　end

  /* #10344 ADD Start */
  /**
   * rst_dialysis_stateのみを更新する
   * @param ordNo 対象ord_no
   * @param rstDialysisState 更新する値
   * @return 影響を受けた行数
   */
  @Update(sqlFile = true)
  int updateRstDialysisStateAndEndDate(Long ordNo, String rstDialysisState, Timestamp rstEndDate);

  /* #10344 ADD Start */
  /**
  * @Author kangjie
  * @Description 10150_9664
  * @Date 2024/08/30 11:49
  * @Param [fluidSpeedAndAmountEntities]
  * @return int
  **/
  @Update(sqlFile = true)
  int updateFluidSpeedAndAmount(List<FluidSpeedAndAmountEntity> fluidSpeedAndAmountEntities, boolean rstDialysisState);

  /* add by zkm [10150] rst_cond_info.20/24.value  --start */
  /**
   * 治療実績更新
   *
   * @param ordNo オーダー番号
   * @param amount 補液量
   * @param speed 補液速度
   * @return
   */
  @Update(sqlFile = true)
  int  updateRstCondInfoIvValue(Long ordNo, String amount, String speed);
  /* add by zkm [10150] rst_cond_info.20/24.value  --end */

  // add 11061 治療方法変更治療時間が長すぎて他の予定と衝突する 関 start
  @Update(sqlFile = true)
  int updateBedAndScheToNullByOrdNo(List<Long> ordNoList, BigInteger indUserId, Long userId);
  // add 11061 治療方法変更治療時間が長すぎて他の予定と衝突する 関 end

  // add 10626 データリストのCTR・DW一括登録修正 房 start
  /**
   * 治療情報から、対象患者の加算情報-算定日のリストを取得する
   * @param facilityCd
   * @param patIds
   * @return
   */
  @Select
  List<AdditionInfoOrdMain> selectCalculationDateListByPats(String facilityCd, List<Long> patIds);
  // add 10626 データリストのCTR・DW一括登録修正 房 end

  // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
  @Select
  List<OrdMain> selectLastestOrdNoByBaseDate(Long patId, String facilityCd, String baseDate, String rstDialysisState);

  @Select
  List<OrdMain> selectLastestOrdNosByBaseDate(List<Long> patIds, String facilityCd, String baseDate, String rstDialysisState);
  // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end

  // add #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
  @Select
  List<OrdMain> selectOrdNosByPatIds(List<Long> patIds, String facilityCd, String specifyDate, String fromDate, String toDate, String rstDialysisState);
  // add #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end

  // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
  @Select
  List<OrdMainKurBed> selectByPatIdListWithBedAndKur(List<Long> ordNoList, String facilityCd);
  // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
  // add #11435 並び替えキー「医材／薬剤」の仕様見直し 高 start
  @Select
  List<FacilitySettingNoDisplayOrder> selectReportSettingDisplayOrder(String facilityCd);
  // add #11435 並び替えキー「医材／薬剤」の仕様見直し 高 end

  //add #10901 死亡患者受信時処理について 20241231 zrx start
  @Select
  List<OrdMain> deathDelOrdMainAndBack(String facilityCd, List<PatPersonalMain> personalMainList);
  //add #10901 死亡患者受信時処理について 20241231 zrx end

  //add #11841 【たくしん会】ord_mainの登録不正 zrx start
  @Update(sqlFile = true)
  int updateOrdMainInfoDelJsonByOrdNos(List<Long> ordNoList);
  //add #11841 【たくしん会】ord_mainの登録不正 zrx end

  // add #11717【因島】曜日パターン変更の動作が遅い fang start
  @BatchUpdate(batchSize = 300)
  int[] batchUpdate(List<OrdMain> ordMains);

  @Select
  List<OrdMain> doOrdMainCheckOfWeekChange(String facilityCd, Long patId, String startDate, String endDate,
                                           List<WeekChangeInfo> updateList, List<WeekChangeInfo> copyList, List<WeekChangeInfo> delList, Integer indTreatmentCd);
  // add #11717【因島】曜日パターン変更の動作が遅い fang end

  // add #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm start
  @Select
  List<OrdMain> bulkInsertIndInfo(String userInfo, OrdMainCrudDto dto);
  // add #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm end

  // 11827 2025.05.14 add 透析番号から施設コードを取得 TDC米沢 start
  @Select
  String selectFacilityCdByOrdNo(Long ordNo);
  // 11827 2025.05.14 add 透析番号から施設コードを取得 TDC米沢 end

  // add #11679 複数患者帳票で「透析条件.補液量」が出ない 20250527 limingzhe start
  @Select
  OrdMain selectRstOrdNoByBaseDate(Long patId, String facilityCd, String baseDate);
  // add #11679 複数患者帳票で「透析条件.補液量」が出ない 20250527 limingzhe end
  // add #11716 曜日パターン変更の不正 関 start
  @Select
  List<TreatmentInstanceSourceDto> selectOrdMainMoveTargetList(String facilityCd, Long patId, String startDate, String endDate, Integer treatmentCd, List<Long> ownOrdNoList, List<Integer> bedList);

  @Select
  List<OrdMain> insertOrdMainForTreatDateCopy(List<OrdNoTreatDateCopyDto> copyList, Long indUserId, Long updUserId);


  @Select
  List<OrdMain> insertOrdMainFromTreatmentPattern(List<OrdNoTreatDateCopyDto> copyList, String facilityCd, Long patId, Long indUserId, Long updUserId);
  // add #11716 曜日パターン変更の不正 関 end

  @Select
  int checkExistKurCdByPatIdBaseDate(Long patId, String facilityCd, String baseDate);

  @Select
  List<OrdMainForPatList> selectOrdInfoListForPatListByOrdNo(String facilityCd, List<Long> ordNoList);

  // add #11276 キー日付に対するデータ引き当て仕様対応 高　start
  /**
   * key日付（fromDate）以降で、ord_main テーブルから
   * 指定患者（patId）・施設（facilityCd）に該当する
   * 最も近いデータ（後回）を1件取得する。
   *
   * @param patId      患者ID
   * @param fromDate   基準日付（yyyyMMdd）
   * @param facilityCd 施設コード
   * @return 条件に該当する ord_no（存在しない場合は null）
   */
  @Select
  Long selectOrdMainNearestFutureByKeyDate(Long patId,String fromDate,String facilityCd);

  /**
   * key日付（fromDate）以前で、ord_main テーブルから
   * 指定患者（patId）・施設（facilityCd）に該当する
   * 最も近いデータ（前回）を1件取得する。
   *
   * @param patId      患者ID
   * @param fromDate   基準日付（yyyyMMdd）
   * @param facilityCd 施設コード
   * @return 条件に該当する ord_no（存在しない場合は null）
   */
  @Select
  Long selectOrdMainNearestPastByKeyDate(Long patId,String fromDate,String facilityCd);
  // add #11276 キー日付に対するデータ引き当て仕様対応 高　end
}
