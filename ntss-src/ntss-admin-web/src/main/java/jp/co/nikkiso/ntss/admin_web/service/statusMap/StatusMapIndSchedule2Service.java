package jp.co.nikkiso.ntss.admin_web.service.statusMap;

import jp.co.nikkiso.ntss.admin_web.request.statusMap.StatusMapIndSchedule2Operation;
import jp.co.nikkiso.ntss.admin_web.request.statusMap.StatusMapIndSchedule2Request;
import jp.co.nikkiso.ntss.admin_web.request.scheduleList.UpdateScheduleListDataResponse;
import jp.co.nikkiso.ntss.admin_web.service.indschedule.IndScheduleService;
import jp.co.nikkiso.ntss.admin_web.service.indschedule.IndScheduleServiceImpl;
import jp.co.nikkiso.ntss.admin_web.service.indschedule.dto.IndscheduleChangeUserSelectedInfo;
import jp.co.nikkiso.ntss.api.response.scheduleList.WeekPatternResponse;
import jp.co.nikkiso.ntss.core.dao.IndScheduleDao;
import jp.co.nikkiso.ntss.core.dao.MstKurDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dto.indSchedule.IndScheduleInfo;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import org.json.JSONException;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * 治療状況マップ専用: {@link IndScheduleService#updateIndSchedule2} の統合呼び出し（事前チェックレイヤーなし）。
 */
@Service
public class StatusMapIndSchedule2Service {

  @Autowired
  private OrdMainDao ordMainDao;

  @Autowired
  private IndScheduleDao indScheduleDao;

  @Autowired
  private MstKurDao mstKurDao;

  @Autowired
  private IndScheduleService indScheduleService;

  @Autowired
  private IndScheduleServiceImpl indScheduleServiceImpl;

  /**
   * MOVE / SWAP を {@code operation} に応じて {@link IndScheduleService#updateIndSchedule2} へ委譲する。
   */
  public UpdateScheduleListDataResponse updateSchedule2(StatusMapIndSchedule2Request req)
    throws JSONException, ArrayIndexOutOfBoundsException {

    if (req == null || req.getOperation() == null) {
      return reject("operation が不正です。");
    }
    switch (req.getOperation()) {
      case MOVE:
        return moveScheduleInternal(req.getFacilityCd(), req.getOrdNo(), req.getBedCd(), req.getUserId());
      case SWAP:
        return swapScheduleInternal(req.getOrdNo1(), req.getOrdNo2(), req.getUserId());
      default:
        return reject("未対応の operation です。");
    }
  }

  private UpdateScheduleListDataResponse moveScheduleInternal(
    String facilityCd,
    Long ordNo,
    Long targetBedCd,
    Long userId
  ) throws JSONException, ArrayIndexOutOfBoundsException {

    if (!StringUtils.hasText(facilityCd) || ordNo == null || targetBedCd == null || userId == null) {
      return reject("必須パラメータが不足しています。");
    }

    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    if (ordMain == null) {
      return reject("治療情報が見つかりません。ordNo=" + ordNo);
    }
    if (!facilityCd.equals(ordMain.getFacilityCd())) {
      return reject("施設コードが治療情報と一致しません。");
    }

    List<IndScheduleInfo> dbInfos = indScheduleDao.selectIndScheduleInfoByOrdNoList(facilityCd, Collections.singletonList(ordNo));
    if (dbInfos == null || dbInfos.isEmpty()) {
      return reject("スケジュール情報の取得に失敗しました。ordNo=" + ordNo);
    }
    IndScheduleInfo before = dbInfos.get(0);

    Long indKurCd = getKurCd(ordMain);
    String editStart = normalizeTreatStartTime(before.getIndTreatStartTime());

    List<IndScheduleInfo> beforeList = new ArrayList<>();
    beforeList.add(before);

    List<IndScheduleInfo> afterList = buildAfterListOne(beforeList, indKurCd, targetBedCd, editStart);

    List<IndScheduleInfo> toBeGo = buildToBeList(facilityCd, beforeList, indKurCd, targetBedCd, editStart);
    List<IndScheduleInfo> complemented = complementToBe(facilityCd, toBeGo);

    UpdateScheduleListDataResponse checkResponse = baseCheckResponse(complemented);

    IndscheduleChangeUserSelectedInfo userSelected = defaultUserSelected();

    return indScheduleService.updateIndSchedule2(
      facilityCd,
      beforeList,
      afterList,
      userSelected,
      new WeekPatternResponse(),
      checkResponse,
      new ArrayList<>(),
      userId,
      userId
    );
  }

  private UpdateScheduleListDataResponse swapScheduleInternal(
    Long ordNo1,
    Long ordNo2,
    Long userId
  ) throws JSONException, ArrayIndexOutOfBoundsException {

    if (ordNo1 == null || ordNo2 == null || userId == null || Objects.equals(ordNo1, ordNo2)) {
      return reject("必須パラメータが不正です。");
    }

    OrdMain om1 = ordMainDao.selectByOrdNo(ordNo1);
    OrdMain om2 = ordMainDao.selectByOrdNo(ordNo2);
    if (om1 == null || om2 == null) {
      return reject("治療情報が見つかりません。");
    }
    String facilityCd = om1.getFacilityCd();
    if (facilityCd == null || !facilityCd.equals(om2.getFacilityCd())) {
      return reject("同一施設のオーダ同士でのみ入替できます。");
    }

    List<Long> ordNos = new ArrayList<>();
    ordNos.add(ordNo1);
    ordNos.add(ordNo2);
    List<IndScheduleInfo> dbInfos = indScheduleDao.selectIndScheduleInfoByOrdNoList(facilityCd, ordNos);
    if (dbInfos == null || dbInfos.size() < 2) {
      return reject("スケジュール情報の取得に失敗しました。");
    }
    IndScheduleInfo b1 = dbInfos.stream().filter(i -> ordNo1.equals(i.getOrdNo())).findFirst().orElse(null);
    IndScheduleInfo b2 = dbInfos.stream().filter(i -> ordNo2.equals(i.getOrdNo())).findFirst().orElse(null);
    if (b1 == null || b2 == null) {
      return reject("スケジュール情報の取得に失敗しました。");
    }

    Long bed1 = getBedCd(om1);
    Long bed2 = getBedCd(om2);
    Long kur1 = getKurCd(om1);
    Long kur2 = getKurCd(om2);

    String start1 = normalizeTreatStartTime(b1.getIndTreatStartTime());
    String start2 = normalizeTreatStartTime(b2.getIndTreatStartTime());

    List<IndScheduleInfo> beforeList = new ArrayList<>();
    beforeList.add(b1);
    beforeList.add(b2);

    List<IndScheduleInfo> afterList = new ArrayList<>();
    afterList.add(buildAfterOne(b1, kur1, bed2, start1));
    afterList.add(buildAfterOne(b2, kur2, bed1, start2));
    nullOutOrdNoPatIdWhenSameOrd(beforeList, afterList);

    List<IndScheduleInfo> toBeGo = new ArrayList<>();
    toBeGo.add(buildToBeOne(facilityCd, b1, kur1, bed2, start1));
    toBeGo.add(buildToBeOne(facilityCd, b2, kur2, bed1, start2));
    List<IndScheduleInfo> complemented = complementToBe(facilityCd, toBeGo);

    UpdateScheduleListDataResponse checkResponse = baseCheckResponse(complemented);
    IndscheduleChangeUserSelectedInfo userSelected = defaultUserSelected();

    return indScheduleService.updateIndSchedule2(
      facilityCd,
      beforeList,
      afterList,
      userSelected,
      new WeekPatternResponse(),
      checkResponse,
      new ArrayList<>(),
      userId,
      userId
    );
  }

  private static UpdateScheduleListDataResponse reject(String message) {
    UpdateScheduleListDataResponse r = new UpdateScheduleListDataResponse();
    r.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.ERROR.toString());
    r.setMessage(message);
    return r;
  }

  private static IndscheduleChangeUserSelectedInfo defaultUserSelected() {
    IndscheduleChangeUserSelectedInfo u = new IndscheduleChangeUserSelectedInfo();
    u.setDupulicateUpdateMode("0");
    u.setUpdateRst("");
    return u;
  }

  private UpdateScheduleListDataResponse baseCheckResponse(List<IndScheduleInfo> toBeComplemented) {
    UpdateScheduleListDataResponse ok = new UpdateScheduleListDataResponse();
    ok.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.SUCCESS.toString());
    ok.setHasPatEvent(false);
    ok.setHasExam(false);
    ok.setHasRad(false);
    ok.setDupulicateOrdScheduleListAll(new ArrayList<>());
    ok.setToBeOrdScheduleListAllForCheak(toBeComplemented);
    return ok;
  }

  private List<IndScheduleInfo> complementToBe(String facilityCd, List<IndScheduleInfo> toBeGo) {
    List<MstKur> mstKurList = mstKurDao.selectByFacilityCd(SelectOptions.get(), facilityCd, "0");
    if (mstKurList == null) {
      mstKurList = Collections.emptyList();
    }
    Map<String, List<IndScheduleInfo>> complemented =
      indScheduleServiceImpl.complementIndScheduleInfo(facilityCd, toBeGo, mstKurList);
    if (complemented == null) {
      return toBeGo;
    }
    return complemented.getOrDefault("indScheduleInfoList", toBeGo);
  }

  private static List<IndScheduleInfo> buildAfterListOne(
    List<IndScheduleInfo> beforeList,
    Long indKurCd,
    Long indBedCd,
    String editTreatStart
  ) {
    List<IndScheduleInfo> afterList = new ArrayList<>();
    for (IndScheduleInfo before : beforeList) {
      afterList.add(buildAfterOne(before, indKurCd, indBedCd, editTreatStart));
    }
    nullOutOrdNoPatIdWhenSameOrd(beforeList, afterList);
    return afterList;
  }

  private static IndScheduleInfo buildAfterOne(
    IndScheduleInfo before,
    Long indKurCd,
    Long indBedCd,
    String editTreatStart
  ) {
    IndScheduleInfo after = new IndScheduleInfo();
    after.setOrdNo(before.getOrdNo());
    after.setPatId(before.getPatId());
    after.setTreatDate(before.getTreatDate());
    after.setIndKurCd(indKurCd);
    after.setIndBedCd(indBedCd);
    after.setIndTreatStartTime(editTreatStart);
    after.setIndTreatmentCd(before.getIndTreatmentCd());
    after.setRstDialysisState(before.getRstDialysisState());
    return after;
  }

  private static void nullOutOrdNoPatIdWhenSameOrd(List<IndScheduleInfo> beforeList, List<IndScheduleInfo> afterList) {
    int n = Math.min(beforeList.size(), afterList.size());
    for (int i = 0; i < n; i++) {
      if (Objects.equals(beforeList.get(i).getOrdNo(), afterList.get(i).getOrdNo())) {
        afterList.get(i).setOrdNo(null);
        afterList.get(i).setPatId(null);
      }
    }
  }

  private static List<IndScheduleInfo> buildToBeList(
    String facilityCd,
    List<IndScheduleInfo> beforeList,
    Long indKurCd,
    Long indBedCd,
    String editTreatStart
  ) {
    List<IndScheduleInfo> toBe = new ArrayList<>();
    for (IndScheduleInfo before : beforeList) {
      if (before == null) {
        continue;
      }
      toBe.add(buildToBeOne(facilityCd, before, indKurCd, indBedCd, editTreatStart));
    }
    return toBe;
  }

  private static IndScheduleInfo buildToBeOne(
    String facilityCd,
    IndScheduleInfo before,
    Long indKurCd,
    Long indBedCd,
    String editTreatStart
  ) {
    IndScheduleInfo toBe = new IndScheduleInfo();
    toBe.setFacilityCd(facilityCd);
    toBe.setOrdNo(before.getOrdNo());
    toBe.setPatId(before.getPatId());
    toBe.setOldTreatDate(before.getTreatDate());
    toBe.setTreatDate(before.getTreatDate());
    toBe.setIndKurCd(indKurCd);
    toBe.setIndBedCd(indBedCd);
    toBe.setIndTreatStartTime(editTreatStart);
    toBe.setIndTreatmentCd(before.getIndTreatmentCd());
    toBe.setIndTreatmentTime(before.getIndTreatmentTime());
    toBe.setTreatWeek(before.getTreatWeek());
    return toBe;
  }

  private static String normalizeTreatStartTime(String t) {
    if (t == null) {
      return null;
    }
    return t.replace(":", "");
  }

  private static boolean isSended(OrdMain ordMain) {
    if (ordMain.getRstDialysisState() == null
      || ordMain.getRstDialysisState().isEmpty()
      || "0".equals(ordMain.getRstDialysisState())) {
      return false;
    }
    return true;
  }

  private static Long getBedCd(OrdMain ordMain) {
    if (isSended(ordMain)) {
      return ordMain.getRstBedCd() != null ? ordMain.getRstBedCd().longValue() : 0L;
    }
    return ordMain.getIndBedCd() != null ? ordMain.getIndBedCd().longValue() : 0L;
  }

  private static Long getKurCd(OrdMain ordMain) {
    if (isSended(ordMain)) {
      return ordMain.getRstKurCd() != null ? ordMain.getRstKurCd().longValue() : 0L;
    }
    return ordMain.getIndKurCd() != null ? ordMain.getIndKurCd().longValue() : 0L;
  }
}
