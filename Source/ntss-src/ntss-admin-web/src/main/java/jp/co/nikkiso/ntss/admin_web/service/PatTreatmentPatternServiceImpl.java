package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.utils.MasterCacheHandler;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstKurDao;
import jp.co.nikkiso.ntss.core.dao.PatTreatmentPatternDao;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdSchedule;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatTreatmentPattern;
import jp.co.nikkiso.ntss.core.entity.PatTreatmentPatternExtends;
import jp.co.nikkiso.ntss.core.entity.PatTreatmentPatternMstKur;
import jp.co.nikkiso.ntss.core.entity.custom.PatTreatmentPatternIndIndCommentInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.Getter;
import lombok.Setter;
import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
@Service
public class PatTreatmentPatternServiceImpl implements PatTreatmentPatternService {

  @Autowired
  PatTreatmentPatternDao patTreatmentPatternDao;

  @Autowired
  MstKurDao mstKurDao;
  // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240306 ztc start
  @Autowired
  MstFacilityService mstFacilityService;
  // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240306 ztc end


  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
  @Autowired
  private LogService logService;
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
  //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
  /**
   * pat_treatment_pattern更新
   * @param facilityCd 施設コード
   * @param userId ユーザID
   * @throws Exception
   */
  @Override
  @Transactional
  public void updatePatTreatmentPatternOnceForAll(String facilityCd, Long userId, Long updUserId) throws Exception {
    //pat_treatment_patternから範囲外の処理対象の取得処理（SQLで）
    List<PatTreatmentPatternMstKur> changedPatternList = patTreatmentPatternDao.checkAllChangedPattern(facilityCd);

    //１、で取得したリストによって、pat_treatment_patternの更新
    //※	ind_kur_cd='0'を更新行う。
    if (!changedPatternList.isEmpty()) {
      patTreatmentPatternDao.resetKurCdToZero(facilityCd, changedPatternList, userId, updUserId);
    }

    //一括更新用の内部リスト変数を作成，set kur_cd = '0'
    List<PatTreatmentPatternMstKur> ptpList = new ArrayList<>();

    DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
    DateTimeFormatter dayFormat = DateTimeFormatter.ofPattern("yyyyMMdd");

    //変更後の最新なmst_kurテーブル情報取得
    List<MstKur> mstKur = mstKurDao.selectByFacilityCd(SelectOptions.get(), facilityCd, AdminWebConstant.FlagType.FLAG_OFF);

    //(範囲内)処理対象がpat_treatment_patternから取得する。（order by 治療曜日、適用開始日）
    List<PatTreatmentPatternExtends> unDeleteData = patTreatmentPatternDao.getAllInRangeData(facilityCd);
    SelectOptions options = SelectOptions.get();
    List<MstKur> mstKurList = mstKurDao.selectByFacilityCd(options, facilityCd, "0");
    for (int i = 0; i < unDeleteData.size(); i++) {
      Long ctlNo = unDeleteData.get(i).getCtlNo();
        //内部変数の治療開始日時を作成
      Integer indKurCd = unDeleteData.get(i).getIndKurCd().intValue();
      Integer indBedCd = unDeleteData.get(i).getIndBedCd();
      String treatDate = unDeleteData.get(i).getIndTreatStartDate();
      String startTime = unDeleteData.get(i).getIndTreatStartTime();
      long treatTime = 0L;
      JSONObject indCondInfo = new JSONObject(unDeleteData.get(i).getIndCondInfo());
      if (indCondInfo.has("1")) {
        Object treatTimeStr = new JSONObject(indCondInfo.get("1").toString()).get("value");
        if (treatTimeStr != null && !treatTimeStr.toString().isEmpty()) {
          treatTime = Long.parseLong((new JSONObject(indCondInfo.get("1").toString()).get("value").toString()));
        }
      }
      //治療開始日時＝治療日＋指示：治療開始時刻
      LocalDateTime treatStartDate = LocalDateTime.parse(treatDate + startTime, dateFormat);
      //治療終了日時 = (治療日＋指示：治療開始時刻) + 治療時間 - 1s
      LocalDateTime treatEndDate = LocalDateTime.parse(treatDate + startTime, dateFormat).plusMinutes(treatTime).minusSeconds(1);

      LocalDateTime dummyDate = LocalDateTime.parse(treatDate + "000000", dateFormat);
      long dummyKur = unDeleteData.get(i).getIndKurCd();
      Optional<MstKur> kur = mstKurList.stream().filter(data -> data.getKurCd().equals(indKurCd)).findFirst();
      if(!kur.isPresent()) continue;
      String dummyTreatDate = dummyDate.format(dayFormat);
      dummyDate = LocalDateTime.parse(dummyTreatDate + kur.get().getKurEndTime(), dateFormat);
      Long patId = unDeleteData.get(i).getPatId();
      while (!dummyDate.isAfter(treatEndDate)) {
        // 次クール情報取得
        MstKurEx nextKurInfo = this.calcNextKurInfo(mstKur, dummyKur);
        if (nextKurInfo != null) {
          OrdSchedule tmp = new OrdSchedule();
          // 次クールの最初のクールフラグがtrueの場合は日付を翌日に更新
          if (nextKurInfo.getIsFirstKur()) {
            dummyDate = dummyDate.plusDays(1);
          }
          // ダミースケジュール更新(クールの期間すべてを含んでいるかをチェックするため、ダミースケジュールの時刻はクール終了時刻を設定)
          dummyTreatDate = dummyDate.format(dayFormat);
          dummyDate = LocalDateTime.parse(dummyTreatDate + nextKurInfo.getKurEndTime(), dateFormat);
          dummyKur = nextKurInfo.getKurCd().longValue();
          //判断ルール、				（衝突の判断）
          //現在ord _mainの内部変数の治療開始日時から内部変数の治療終了日時までの間に、
          //相同に指示：ベッドコードがあれば、　且つ、　
          //治療開始時間はある所定の治療時間区間内にあり
            LocalDateTime tempDummyDate = dummyDate;
          //mod #10634 クールマスタで標準治療開始時刻を変更した際のダミー予定・連携イベント作成処理不正 zrx start
//          boolean inOrOut = unDeleteData.stream().anyMatch(data ->
//            data.getIndBedCd().equals(indBedCd)
//              && !data.getPatId().equals(patId)
//              && LocalDateTime.parse(data.getIndTreatStartDate() + data.getIndTreatStartTime(), dateFormat).isAfter(treatStartDate)
//              && !LocalDateTime.parse(data.getIndTreatStartDate() + data.getIndTreatStartTime(), dateFormat).isAfter(treatEndDate)
//              && !treatEndDate.isBefore(tempDummyDate));
          boolean inOrOut = unDeleteData.stream().anyMatch(data -> {
            LocalDateTime otherStart =
              LocalDateTime.parse(data.getIndTreatStartDate() + data.getIndTreatStartTime(), dateFormat);
            boolean ctlNoFlag = true;
            if(data.getPatId().equals(patId) && data.getCtlNo().equals(ctlNo)) {
              ctlNoFlag = false;
            }
            return data.getIndBedCd().equals(indBedCd)
              && !otherStart.isBefore(treatStartDate)
              && !otherStart.isAfter(treatEndDate)
              && !treatEndDate.isBefore(tempDummyDate)
              && ctlNoFlag;
            //mod #10634 クールマスタで標準治療開始時刻を変更した際のダミー予定・連携イベント作成処理不正 zrx end
          });
          if (inOrOut) {
            PatTreatmentPatternMstKur ptp = new PatTreatmentPatternMstKur();
            ptp.setPatId(patId);
            ptp.setCtlNo(ctlNo);
            ptpList.add(ptp);
          }
        }
      }
    }

    //batch update pat_treatment_pattern
    if (!ptpList.isEmpty()) {
      patTreatmentPatternDao.resetKurCdToZero(facilityCd, ptpList, userId, updUserId);
    }
  }

  /** クールマスタの拡張情報を格納するクラス */
  @Getter
  @Setter
  private static class MstKurEx extends MstKur {
    /**
     * 最初のクールフラグ(true:最初のクール、false:最後のクール以外)
     */
    private Boolean isFirstKur;

    private static MstKurEx parse(MstKur base) {
      MstKurEx ret = new MstKurEx();
      ret.setKurCd(base.getKurCd());
      ret.setKurStandardStartTime(base.getKurStandardStartTime());
      ret.setKurStartTime(base.getKurStartTime());
      ret.setKurEndTime(base.getKurEndTime());
      ret.setIsFirstKur(false);
      return ret;
    }
  }

  /**
   * 次クール情報取得
   * @param mstKur クールマスタ情報
   * @param currentKurCd 現在クール
   * @return 正常終了:次クール情報、異常終了:null
   */
  private MstKurEx calcNextKurInfo(List<MstKur>mstKur, long currentKurCd) {
    MstKurEx targetKur = null;
    Boolean isCurrentKur = false;
    if (!mstKur.isEmpty()) {
      for (int i = 0; i < mstKur.size(); i++) {
        // 次クール判定
        if (isCurrentKur) {
          // 次クールを返す
          targetKur = MstKurEx.parse(mstKur.get(i));
          break;
        }
        // 現在クール判定(最後のクールは除外)
        if ((i != mstKur.size()-1) && (currentKurCd == mstKur.get(i).getKurCd().longValue())) {
          isCurrentKur = true;
        }
      }
      // 次クールが見つからなかった場合は最初のクールを返す
      if (!isCurrentKur) {
        targetKur = MstKurEx.parse(mstKur.get(0));
        targetKur.setIsFirstKur(true);
      }
    }

    return targetKur;
  }
  //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end
  // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240306 ztc start
  public List<OrdMain> createOrdMainListByUpdateWeek(String facilityCd, PatPersonalMain patPersonalMain, PatMain patMain,
                                                     List<PatTreatmentPattern> patTreatmentPatternList, HashMap<Short, List<Short>> changeWeekList,
                                                     List<String> missingDateList) throws Exception{
    List<OrdMain> ordMainToInsert = new ArrayList<OrdMain>();
    if (facilityCd == null && CollectionUtils.isEmpty(patTreatmentPatternList) || CollectionUtils.isEmpty(missingDateList)) {
      return ordMainToInsert;
    }
    MasterCacheHandler masterCacheHandler = MasterCacheHandler.get();
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
    List<MstFacility> mstFacilityList = new ArrayList<>();
    try {
      mstFacilityList = mstFacilityService.getFacilityInfoByCd(facilityCd);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    for (PatTreatmentPattern ptp : patTreatmentPatternList) {
      JSONObject indSchInfo = new JSONObject(ptp.getIndSchInfo());
      JSONObject indScheduleUserInfo = new JSONObject();
      indScheduleUserInfo.put("ind_user_id", indSchInfo.isNull("ind_user_id") ? JSONObject.NULL : indSchInfo.getInt("ind_user_id"));
      MstPersonalUser indMstPersonalUser = masterCacheHandler.getMstPersonalUser(indSchInfo.getLong("ind_user_id"));
      if (indMstPersonalUser != null) {
        indScheduleUserInfo.put("ind_user_last_name", indMstPersonalUser.getUserLastName());
        indScheduleUserInfo.put("ind_user_first_name", indMstPersonalUser.getUserLastName());
      }else{
        indScheduleUserInfo.put("ind_user_last_name", JSONObject.NULL);
        indScheduleUserInfo.put("ind_user_first_name", JSONObject.NULL);
      }
      indScheduleUserInfo.put("upd_user_id", indSchInfo.isNull("upd_user_id") ? JSONObject.NULL : indSchInfo.getInt("upd_user_id"));
      MstPersonalUser updMstPersonalUser = masterCacheHandler.getMstPersonalUser(indSchInfo.getLong("ind_user_id"));
      if (updMstPersonalUser != null) {
        indScheduleUserInfo.put("upd_user_last_name", updMstPersonalUser.getUserLastName());
        indScheduleUserInfo.put("upd_user_first_name", updMstPersonalUser.getUserLastName());
      }else{
        indScheduleUserInfo.put("upd_user_last_name", JSONObject.NULL);
        indScheduleUserInfo.put("upd_user_first_name", JSONObject.NULL);
      }
      JSONObject indCondInfo = null == ptp.getIndCondInfo() ? new JSONObject() : new JSONObject(ptp.getIndCondInfo());
      String indTreatStartTime = indSchInfo.isNull("ind_treat_start_time") ? null : indSchInfo.getString("ind_treat_start_time");
      Integer indBedCd = indSchInfo.isNull("ind_bed_cd") ? null : indSchInfo.getInt("ind_bed_cd");
      Integer indVaCd = null;
      for (String missDate : missingDateList) {
        LocalDate missLocalDate = LocalDate.parse(missDate, formatter);
        DayOfWeek dayOfWeek = missLocalDate.getDayOfWeek();
        Short correspondingKey = null;
        for (Map.Entry<Short, List<Short>> entry : changeWeekList.entrySet()) {
          if (entry.getValue().contains((short) dayOfWeek.getValue())) {
            correspondingKey = entry.getKey();
            break;
          }
        }
        //変更日mapを使用して、追加のordmainを作成するために移動前のpattereatmentPatternを問い合せます
        if (Objects.equals(ptp.getTreatWeek(), correspondingKey)) {
          if (!indCondInfo.isNull("2")) {
            indVaCd = indCondInfo.getJSONObject("2").isNull("value") ? null : indCondInfo.getJSONObject("2").getInt("value");
          }
          JSONArray retArr = new JSONArray();
          String indMediInfo = retArr.toString();
          if (ptp.getIndMediInfo() != null && !"".equals(ptp.getIndMediInfo()) && !"[]".equals(ptp.getIndMediInfo())) {
            //mod #10590 次患者更新関連全体見直し対応 朴 start
//            indMediInfo = createIndMediInfo(ptp.getIndMediInfo(), LocalDate.parse(missDate), false);
            indMediInfo = createIndMediInfo(ptp.getIndMediInfo(), LocalDate.parse(missDate,formatter), false);
            //mod #10590 次患者更新関連全体見直し対応 朴 end
          }
          JSONObject tareJson = new JSONObject(patMain.getTare_info());
          String tareInfo = tareJson.get(ptp.getTreatWeek().toString()).toString();
          JSONObject offWaterJson = new JSONObject(patMain.getOff_water_info());
          String offWaterInfo = offWaterJson.get(ptp.getTreatWeek().toString()).toString();
          // インサートデータ
          OrdMain ordMain = new OrdMain();
          ordMain.setPatId(ptp.getPatId());
          ordMain.setFnPatId(patPersonalMain.getFn_pat_id() == null ? null : String.valueOf(patPersonalMain.getFn_pat_id()));
          ordMain.setTreatDate(missDate);
          ordMain.setTreatWeek((short) dayOfWeek.getValue());
          ordMain.setFacilityCd(ptp.getFacilityCd());
          ordMain.setFacilityName(mstFacilityList.get(0).getFacilityName());
          ordMain.setIndVaCd(indVaCd);
          ordMain.setIndTreatmentCd(ptp.getIndTreatmentCd());
          ordMain.setIndTreatmentName(null);
          if (ptp.getIndKurCd() != null) {
            ordMain.setIndKurCd(ptp.getIndKurCd().intValue());
          } else {
            ordMain.setIndKurCd(0);
          }
          if (indBedCd != null) {
            ordMain.setIndBedCd(indBedCd);
          } else {
            ordMain.setIndBedCd(0);
          }
          ordMain.setIndTreatStartTime(indTreatStartTime);
          ordMain.setIndScheduleUserInfo(indScheduleUserInfo.toString());
          ordMain.setIndCondInfo(ptp.getIndCondInfo());
          ordMain.setIndMediInfo(indMediInfo);
          ordMain.setIndEquipInfo(ptp.getIndEquipInfo());
          ordMain.setIndIndCommentInfo(ptp.getIndIndCommentInfo());
          ordMain.setIndTareInfo(tareInfo);
          ordMain.setIndOffWaterInfo(offWaterInfo);
          ordMain.setIndDeviceSetInfo(ptp.getIndDeviceSetInfo());
          ordMain.setTreatType(ptp.getTreatType());
          ordMain.setRstEdition(0);
          ordMain.setRstDialysisState("0");
          ordMain.setIsDel("0");
          Long ind_user_id = indSchInfo.isNull("ind_user_id") ? null : indSchInfo.getLong("ind_user_id");
          Long upd_user_id = indSchInfo.isNull("upd_user_id") ? null : indSchInfo.getLong("upd_user_id");
          ordMain.setRstIsUpdateEdition(null);
          ordMain.setIsConfirm("0");
          ordMain.setUpIndUserId(ind_user_id);
          ordMain.setUpUserId(upd_user_id);
          ordMain.setBvmsPath(null);
          ordMainToInsert.add(ordMain);
        }
      }
    }
    return ordMainToInsert;
  }

  /**
   * 指定投与間隔により登録する投与薬剤を取得
   * @param indMediInfo 投与薬剤情報
   * @param treatDate　治療日
   * @param isLastTreatDate 最終治療日フラグ
   */
  private String createIndMediInfo(String indMediInfo, LocalDate treatDate, Boolean isLastTreatDate) {
    JSONArray mediArr = new JSONArray(indMediInfo);
    JSONArray retArr = new JSONArray();

    for (int i = 0; i < mediArr.length(); i++) {
      // 投与薬剤情報
      JSONObject medi = mediArr.getJSONObject(i);
      // 初回投与日
      if(medi.get("init_date") == null || "null".equals(medi.get("init_date").toString()) || "".equals(medi.get("init_date").toString())
              || medi.get("date_interval") == null || "null".equals(medi.get("date_interval").toString()) || "".equals(medi.get("date_interval"))){
        continue;
      }
      if (medi.getString("init_date") == null || "".equals(medi.getString("init_date"))) {
        continue;
      }
      LocalDate initDate = LocalDate.parse(medi.getString("init_date"), DateTimeFormatter.ofPattern("yyyyMMdd")).with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));

      // 投与間隔
      switch (medi.getInt("date_interval")) {
        // 毎回
        case 0:
          // 毎週
        case 1:
          retArr.put(medi);
          break;
        // 1回／2週
        case 2:
          if (0 == ChronoUnit.WEEKS.between(initDate, treatDate) % 2) {
            retArr.put(medi);
          }
          break;
        // 1回／3週
        case 3:
          if (0 == ChronoUnit.WEEKS.between(initDate, treatDate) % 3) {
            retArr.put(medi);
          }
          break;
        // 1回／4週
        case 4:
          if (0 == ChronoUnit.WEEKS.between(initDate, treatDate) % 4) {
            retArr.put(medi);
          }
          break;
        // 1回／月：第1曜日
        case 5:
          if (treatDate.equals(treatDate.with(TemporalAdjusters.dayOfWeekInMonth(1, treatDate.getDayOfWeek())))) {
            retArr.put(medi);
          }
          break;
        // 1回／月：第2曜日
        case 6:
          if (treatDate.equals(treatDate.with(TemporalAdjusters.dayOfWeekInMonth(2, treatDate.getDayOfWeek())))) {
            retArr.put(medi);
          }
          break;
        // 1回／月：第3曜日
        case 7:
          if (treatDate.equals(treatDate.with(TemporalAdjusters.dayOfWeekInMonth(3, treatDate.getDayOfWeek())))) {
            retArr.put(medi);
          }
          break;
        // 1回／月：第4曜日
        case 8:
          if (treatDate.equals(treatDate.with(TemporalAdjusters.dayOfWeekInMonth(4, treatDate.getDayOfWeek())))) {
            retArr.put(medi);
          }
          break;
        // 1回／月：最終曜日
        case 9:
          if (treatDate.getDayOfMonth() >= treatDate.lengthOfMonth() - 6) {
            retArr.put(medi);
          }
          break;
        // 1回／月：最終治療日
        case 10:
          if (isLastTreatDate) {
            retArr.put(medi);
          }
          break;
        default:
          break;
      }
    }

    return retArr.toString();
  }
  // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240306 ztc end

  // add #11731_【因島：改良】指示コメント番号の指定方法 start
  // 指示コメント情報（指示コメント番号で集約）の取得
  @Override
  public List<PatTreatmentPatternIndIndCommentInfo> getIndIndCommentInfo(Long patId, String facilityCd, List<Integer> weeks, List<Integer> treats, List<Long> kurs) {
    return patTreatmentPatternDao.selectIndIndCommentInfo(patId, facilityCd, weeks, treats, kurs);
  }
  // add #11731_【因島：改良】指示コメント番号の指定方法 end
}
