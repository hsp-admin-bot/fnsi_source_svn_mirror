package jp.co.nikkiso.ntss.admin_web.service.ordmain.check;

import jp.co.nikkiso.ntss.admin_web.request.scheduleList.UpdateScheduleListDataResponse;
import jp.co.nikkiso.ntss.admin_web.service.indschedule.IndScheduleServiceImpl;
import jp.co.nikkiso.ntss.admin_web.service.MstInfoService;
import jp.co.nikkiso.ntss.admin_web.service.nextpat.NextPatService;
import jp.co.nikkiso.ntss.admin_web.service.sendConditionCancel.SendConditionCancelService;
import jp.co.nikkiso.ntss.admin_web.web.rest.OrdMainResource;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.OrdMainSchChangeUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.validation.ApiEntityOrdMain;
import jp.co.nikkiso.ntss.core.dao.IndScheduleDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdScheduleDao;
import jp.co.nikkiso.ntss.core.dao.MstKurDao;
import jp.co.nikkiso.ntss.core.dto.indSchedule.IndScheduleInfo;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdSchedule;
import jp.co.nikkiso.ntss.core.entity.OrdScheduleNewKurPreview;
import org.apache.commons.lang3.SerializationUtils;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * {@link OrdMainResource#updateIndScheduleByOrdMoveCheck} 向けに、旧 {@code POST .../updateIndSchedule}
 * と同等の事前チェックをまとめ、移動更新に必要な {@link UpdateScheduleListDataResponse} を組み立てる。
 *
 * <p>このクラスは {@link OrdScheduleMoveCheck#checkOrdScheduleMove} を直接呼ばず、同更新に必要な
 * {@code toBeOrdScheduleListAllForCheak} 等を移植して返す。</p>
 */
@Component
public class IndScheduleUpdateCheck {

  @Autowired
  @Lazy
  private OrdMainResource ordMainResource;

  @Autowired
  private OrdMainSchChangeUtils ordMainSchChangeUtils;

  @Autowired
  private IndScheduleServiceImpl indScheduleServiceImpl;

  @Autowired
  private MstKurDao mstKurDao;

  @Autowired
  private OrdMainDao ordMainDao;

  @Autowired
  private IndScheduleDao indScheduleDao;

  @Autowired
  private OrdScheduleDao ordScheduleDao;

  @Autowired
  private MstInfoService mstInfoService;

  @Autowired
  private SendConditionCancelService sendConditionCancelService;

  @Autowired
  private NextPatService nextPatService;

  /**
   * 旧 updateIndSchedule のクール変更時重複・ベッド重複（update_mode=0）に相当するチェックの後、
   * {@link IndScheduleServiceImpl#updateIndSchedule2} が必要とする {@link UpdateScheduleListDataResponse} を組み立てる。
   */
  /**
   * @param outBeforeIndScheduleInfoList 呼び出し元が用意した空リスト。処理成功時に変更前スケジュール（最終更新対象のみ）が格納される。
   * @param outAfterIndScheduleInfoList  呼び出し元が用意した空リスト。処理成功時に変更後スケジュールが格納される。
   */
  public UpdateScheduleListDataResponse checkForIndScheduleByOrdMove(
    ApiEntityOrdMain.ValiUpdateIndSchedule bodyData,
    OrdMainResource.UpdateInfoData updateInfo,
    List<OrdMain> ordMain,
    String facilityCd,
    List<IndScheduleInfo> outBeforeIndScheduleInfoList,
    List<IndScheduleInfo> outAfterIndScheduleInfoList
  ) {
    // クール変更時、同一患者・治療日・治療方法・クールの重複（22010011）
    if (bodyData.getInd_kur_cd() != null
      && bodyData.getEdit_ind_kur_cd() != null
      && !bodyData.getInd_kur_cd().contains(bodyData.getEdit_ind_kur_cd())) {
      if (!"true".equals(bodyData.getIs_skip_update())) {
        List<OrdMain> duplicateOrdMain = ordMainResource.getUpdateInfoForScheduleCheck(updateInfo, 1, true);
        if (duplicateOrdMain != null && !duplicateOrdMain.isEmpty()) {
          return rejectWithMsgCd("22010011");
        }
      }
    }

    int updateMode = bodyData.getUpdate_mode() == null ? 0 : Integer.parseInt(bodyData.getUpdate_mode());
    Long indKurCd = Long.parseLong(bodyData.getEdit_ind_kur_cd());
    Long indBedCd = Long.parseLong(bodyData.getEdit_ind_bed_cd());

    // update_mode=0 かつ変更先クール・ベッド指定時、他予定との重複
    // update_flag!=2: 重複があれば不可(12000240)。update_flag==2: 12010002 確認／双方ロック時のみ 12000240
    if (updateMode == 0 && indKurCd != 0L && indBedCd != 0L) {
      List<Long> ordNoList = ordMain.stream().map(OrdMain::getOrdNo).distinct().collect(Collectors.toList());
      ordNoList = ordNoList == null ? new ArrayList<>() : ordNoList;
      if (!ordNoList.isEmpty()) {
        List<OrdSchedule> scheduleInfo = ordMainSchChangeUtils.searchDuplicatedSchList(
          bodyData.getFacility_cd(),
          bodyData.getEdit_ind_kur_cd(),
          bodyData.getEdit_ind_bed_cd(),
          bodyData.getEdit_ind_treat_start_time(),
          ordNoList);
        if (scheduleInfo != null && !scheduleInfo.isEmpty()) {
          if (!"2".equals(bodyData.getUpdate_flag())) {
            return rejectWithMsgCd("12000240");
          }
          List<Long> dupOrdNos = scheduleInfo.stream()
            .map(OrdSchedule::getOrdNo)
            .filter(Objects::nonNull)
            .distinct()
            .collect(Collectors.toList());
          if (hasDialysisLockedConflictBothSides(ordMain, dupOrdNos)) {
            return rejectWithMsgCd("12000240");
          }
          return rejectWithMsgCd("12010002");
        }
      }
    }

    // 副作用処理より前に「変更前」スナップショットを取得する（途中の updateBedUnregistered 等で DB が変わるため）
    List<Long> initialOrdNoList = ordMain.stream().map(OrdMain::getOrdNo).distinct().collect(Collectors.toList());
    initialOrdNoList = initialOrdNoList == null ? new ArrayList<>() : initialOrdNoList;
    List<IndScheduleInfo> dbInfosSnapshot = initialOrdNoList.isEmpty()
      ? Collections.emptyList()
      : indScheduleDao.selectIndScheduleInfoByOrdNoList(facilityCd, initialOrdNoList);
    Map<Long, IndScheduleInfo> beforeSnapshotByOrdNo = new HashMap<>();
    if (dbInfosSnapshot != null) {
      for (IndScheduleInfo inf : dbInfosSnapshot) {
        if (inf != null && inf.getOrdNo() != null) {
          beforeSnapshotByOrdNo.put(inf.getOrdNo(), inf);
        }
      }
    }
    int snapshotHitCount = 0;
    for (OrdMain om : ordMain) {
      if (om != null && om.getOrdNo() != null && beforeSnapshotByOrdNo.get(om.getOrdNo()) != null) {
        snapshotHitCount++;
      }
    }
    if (snapshotHitCount != ordMain.size()) {
      clearOutScheduleLists(outBeforeIndScheduleInfoList, outAfterIndScheduleInfoList);
      return rejectParamErrScheduleSnapshot("変更前スケジュール情報の取得に失敗しました");
    }

    // ---- legacy updateIndSchedule parity for update_mode=1/2 (DB side effects + response fields) ----
    // These lists are returned to frontend (legacy keys)
    List<Long> bedUnregistOrdList = new ArrayList<>();
    List<Long> duplicatedOrdNoList = new ArrayList<>();
    // add #10553 連携退避相当（check 内副作用を updateIndSchedule2 の result に載せるため）
    List<OrdMain> scheduleCheckCoopOrdMainBeforeList = new ArrayList<>();
    List<OrdMain> scheduleCheckCoopOrdMainAfterList = new ArrayList<>();
    String msgCd = null;
    Long ordNoForMsg = null;

    List<Long> ordNoList = ordMain.stream().map(OrdMain::getOrdNo).distinct().collect(Collectors.toList());
    ordNoList = ordNoList == null ? new ArrayList<>() : ordNoList;
    List<Long> removeOrdNoList = new ArrayList<>();

    if (!ordNoList.isEmpty() && indKurCd != 0L && indBedCd != 0L) {
      List<OrdSchedule> scheduleInfo = ordMainSchChangeUtils.searchDuplicatedSchList(
        bodyData.getFacility_cd(),
        bodyData.getEdit_ind_kur_cd(),
        bodyData.getEdit_ind_bed_cd(),
        bodyData.getEdit_ind_treat_start_time(),
        ordNoList);

      // すべての患者の重複対象オーダー番号リスト
      List<Long> allPatDupulicateOrdNoList = scheduleInfo == null
        ? new ArrayList<>()
        : scheduleInfo.stream().map(OrdSchedule::getOrdNo).distinct().collect(Collectors.toList());

      // ダミースケジュールでの更新対象内重複対象リスト
      List<OrdMain> dummyDupulicateOrdMain = new ArrayList<>();
      List<Long> skipOrdNoList = new ArrayList<>();

      if (!allPatDupulicateOrdNoList.isEmpty()) {
        List<OrdMain> allPatDupulicateOrdMainList = ordMainDao.selectByOrdNoList(allPatDupulicateOrdNoList);

        // update_mode==2 の場合、クール変更時に作った skipOrdMainList 相当はこの API では未対応。
        // 旧仕様に合わせ、通常の ordMain を対象に dummyDupulicate を計算する。
        for (OrdMain o : ordMain) {
          for (OrdMain e : allPatDupulicateOrdMainList) {
            if (updateMode == 2 && o.getOrdNo().equals(e.getOrdNo())) {
              dummyDupulicateOrdMain.add(o);
            } else {
              if (Objects.equals(o.getTreatDate(), e.getTreatDate())
                && Objects.equals(o.getIndKurCd(), e.getIndKurCd())
                && Objects.equals(o.getIndBedCd(), e.getIndBedCd())) {
                dummyDupulicateOrdMain.add(o);
              }
            }
          }
        }
        skipOrdNoList = dummyDupulicateOrdMain.stream().map(OrdMain::getOrdNo).distinct().collect(Collectors.toList());
      }

      switch (updateMode) {
        case 1: {
          // 空きベッド候補（facilityCd 未設定）を除去
          if (scheduleInfo != null) {
            for (OrdSchedule ord : scheduleInfo) {
              if (!StringUtils.hasText(ord.getFacilityCd())) {
                allPatDupulicateOrdNoList.remove(ord.getOrdNo());
              }
            }
          }

          if (!allPatDupulicateOrdNoList.isEmpty()) {
            if (hasDialysisLockedConflictBothSides(ordMain, new ArrayList<>(allPatDupulicateOrdNoList))) {
              clearOutScheduleLists(outBeforeIndScheduleInfoList, outAfterIndScheduleInfoList);
              return rejectWithMsgCd("12000240");
            }
            String[] msgSlot = new String[1];
            Long[] ordNoSlot = new Long[1];
            List<Long> narrowUserOrdNos = skipOrdNoList == null ? new ArrayList<>() : new ArrayList<>(skipOrdNoList);
            List<OrdScheduleNewKurPreview> dummyPreviewForFb = ordScheduleDao.selectDummyScheduleInOrdNoList(
              bodyData.getFacility_cd(),
              new ArrayList<>(ordNoList),
              indKurCd,
              indBedCd,
              bodyData.getEdit_ind_treat_start_time());
            applyDisRegistDuplicateOrdNoHandling(
              allPatDupulicateOrdNoList,
              ordNoList,
              updateInfo,
              bodyData,
              facilityCd,
              bedUnregistOrdList,
              false,
              msgSlot,
              ordNoSlot,
              narrowUserOrdNos,
              ordMain,
              dummyPreviewForFb,
              true,
              scheduleCheckCoopOrdMainBeforeList,
              scheduleCheckCoopOrdMainAfterList);
            if (msgSlot[0] != null) {
              msgCd = msgSlot[0];
              ordNoForMsg = ordNoSlot[0];
            }
          }
          break;
        }
        case 2: {
          List<Long> bedUnregistOrdNoList = new ArrayList<>();
          List<Long> finalOrdNoList = ordNoList;
          ordNoList.removeIf(skipOrdNoList::contains);
          bedUnregistOrdNoList.addAll(skipOrdNoList.stream().filter(o -> !finalOrdNoList.contains(o)).collect(Collectors.toList()));

          if (!bedUnregistOrdNoList.isEmpty()) {
            if (hasDialysisLockedConflictBothSides(ordMain, new ArrayList<>(bedUnregistOrdNoList))) {
              clearOutScheduleLists(outBeforeIndScheduleInfoList, outAfterIndScheduleInfoList);
              return rejectWithMsgCd("12000240");
            }
            String[] msgSlot = new String[1];
            Long[] ordNoSlot = new Long[1];
            List<Long> narrowUserOrdNos = skipOrdNoList == null ? new ArrayList<>() : new ArrayList<>(skipOrdNoList);
            List<OrdScheduleNewKurPreview> dummyPreviewForFb = ordScheduleDao.selectDummyScheduleInOrdNoList(
              bodyData.getFacility_cd(),
              new ArrayList<>(ordNoList),
              indKurCd,
              indBedCd,
              bodyData.getEdit_ind_treat_start_time());
            applyDisRegistDuplicateOrdNoHandling(
              bedUnregistOrdNoList,
              ordNoList,
              updateInfo,
              bodyData,
              facilityCd,
              bedUnregistOrdList,
              true,
              msgSlot,
              ordNoSlot,
              narrowUserOrdNos,
              ordMain,
              dummyPreviewForFb,
              true,
              scheduleCheckCoopOrdMainBeforeList,
              scheduleCheckCoopOrdMainAfterList);
            if (msgSlot[0] != null) {
              msgCd = msgSlot[0];
              ordNoForMsg = ordNoSlot[0];
            }
          }
          break;
        }
        default:
          break;
      }

      // 低優先度処理（旧接口逻辑）
      List<Long> allLowPriorityOrdNoList = new ArrayList<>();
      if (StringUtils.hasText(bodyData.getEdit_ind_bed_cd()) && Long.parseLong(bodyData.getEdit_ind_bed_cd()) > 0) {
        List<OrdMain> targetOrdMainList = ordMainDao.selectByOrdNoList(ordNoList);

        List<OrdMain> sameDateOrdMainList = targetOrdMainList.stream()
          .filter(target -> targetOrdMainList.stream().anyMatch(item ->
            !target.getOrdNo().equals(item.getOrdNo())
              && Objects.equals(target.getPatId(), item.getPatId())
              && Objects.equals(target.getTreatDate(), item.getTreatDate())))
          .collect(Collectors.toList());

        if (!sameDateOrdMainList.isEmpty()) {
          MstTreatment mstTreatmentSearchData = new MstTreatment();
          mstTreatmentSearchData.setFacilityCd(bodyData.getFacility_cd());
          List<Integer> treatmentCdList =
            mstInfoService.findMstTreatmentList(mstTreatmentSearchData).stream().map(MstTreatment::getTreatmentCd).collect(Collectors.toList());

          Optional<Integer> treatmentResult =
            treatmentCdList.stream()
              .filter(i -> sameDateOrdMainList.stream().anyMatch(e -> e.getIndTreatmentCd().equals(i)))
              .findFirst();

          Integer topTreatmentCd = treatmentResult.orElse(0);
          if (topTreatmentCd.compareTo(0) > 0) {
            List<Long> lowPriorityOrdNoList =
              sameDateOrdMainList.stream()
                .filter(e -> !e.getIndTreatmentCd().equals(topTreatmentCd))
                .map(OrdMain::getOrdNo)
                .collect(Collectors.toList());
            allLowPriorityOrdNoList.addAll(lowPriorityOrdNoList);
          }
        }

        List<OrdScheduleNewKurPreview> ordScheduleList = ordScheduleDao.selectDummyScheduleInOrdNoList(
          bodyData.getFacility_cd(),
          ordNoList,
          Long.parseLong(bodyData.getEdit_ind_kur_cd()),
          Long.parseLong(bodyData.getEdit_ind_bed_cd()),
          bodyData.getEdit_ind_treat_start_time());
        List<Long> lowPriorityOrdNoList2 = ordMainSchChangeUtils.searchLowPriorityNoList(bodyData.getFacility_cd(), ordScheduleList);
        allLowPriorityOrdNoList.addAll(lowPriorityOrdNoList2);

        if (!allLowPriorityOrdNoList.isEmpty()) {
          List<Long> distinctLowPri = allLowPriorityOrdNoList.stream().filter(Objects::nonNull).distinct().collect(Collectors.toList());
          scheduleCheckCoopOrdMainBeforeList.addAll(ordMainDao.selectByOrdNoList(distinctLowPri));
          ordMainResource.updateKurTimeAndBedUnregisteredForScheduleCheck(updateInfo, distinctLowPri, bodyData);
          scheduleCheckCoopOrdMainAfterList.addAll(ordMainDao.selectByOrdNoList(distinctLowPri));
          ordNoList = ordNoList.stream().filter(o -> !distinctLowPri.contains(o)).collect(Collectors.toList());

          if (!bedUnregistOrdList.isEmpty()) {
            bedUnregistOrdList.addAll(distinctLowPri);
          } else {
            duplicatedOrdNoList.addAll(distinctLowPri);
          }
        }
      }

      // 更新対象から未登録に落とせないものがあるために除去する
      if (!removeOrdNoList.isEmpty()) {
        ordNoList.removeIf(removeOrdNoList::contains);
      }

      // 条件送信キャンセル（更新対象側）
      if (!ordNoList.isEmpty()) {
        List<OrdMain> ordMainList = ordMainDao.selectByOrdNoList(ordNoList);
        DoCancelInfo doCancelInfo = getDoCancelInfo(ordMainList);
        List<OrdMain> doCancelList = doCancelInfo.doCancelList;

        ordMainList = doCancelInfo.ordMainList;
        ordNoList = ordMainList.stream().map(OrdMain::getOrdNo).filter(Objects::nonNull).distinct().collect(Collectors.toList());

        // 旧 updateIndSchedule（OrdMainResource）No.79: 治療情報スケジュール編集時、取り除いた removed から透析状態3以外を更新対象に戻す
        if (ordNoList.isEmpty() && bodyData.getIs_ind_sch_edit() != null && "true".equals(bodyData.getIs_ind_sch_edit())) {
          List<OrdMain> removedForRecover = doCancelInfo.removedList == null
            ? new ArrayList<>()
            : new ArrayList<>(doCancelInfo.removedList);
          for (int i = removedForRecover.size() - 1; i >= 0; i--) {
            Integer dialysisState = Integer.parseInt(removedForRecover.get(i).getRstDialysisState());
            if (dialysisState == 3) {
              removedForRecover.remove(i);
            }
          }
          ordNoList = removedForRecover.stream()
            .map(OrdMain::getOrdNo)
            .filter(Objects::nonNull)
            .distinct()
            .collect(Collectors.toList());
        }

        if (!doCancelList.isEmpty()) {
          scheduleCheckCoopOrdMainBeforeList.addAll(doCancelList);
        }
        for (OrdMain sendCancelOrdMain : doCancelList) {
          sendConditionCancelService.resetOrdMain(sendCancelOrdMain.getOrdNo());
        }
        if (!doCancelList.isEmpty()) {
          List<Long> doCancelOrdNos = doCancelList.stream()
            .map(OrdMain::getOrdNo)
            .filter(Objects::nonNull)
            .distinct()
            .collect(Collectors.toList());
          scheduleCheckCoopOrdMainAfterList.addAll(ordMainDao.selectByOrdNoList(doCancelOrdNos));
        }

        try {
          List<OrdMain> forNextPat = new ArrayList<>();
          forNextPat.addAll(doCancelList.stream().map(SerializationUtils::clone).collect(Collectors.toList()));
          forNextPat.addAll(ordMainList.stream().map(SerializationUtils::clone).collect(Collectors.toList()));
          nextPatService.CallNextPatChange(facilityCd, forNextPat);
        } catch (Exception ignore) {
        }

        if (!doCancelList.isEmpty()) {
          msgCd = "22010007";
          ordNoForMsg = doCancelList.get(0).getOrdNo();
        }
      }
    }
    // ---- end legacy parity ----

    // 最終 ordNoList の順序で変更前／変更後リストを組み立てる（スナップショット参照のみ）
    List<Long> finalOrdNoListForUpdate = ordNoList == null ? new ArrayList<>() : new ArrayList<>(ordNoList);
    List<IndScheduleInfo> beforeList = new ArrayList<>();
    for (Long ordNo : finalOrdNoListForUpdate) {
      if (ordNo == null) {
        continue;
      }
      IndScheduleInfo row = beforeSnapshotByOrdNo.get(ordNo);
      if (row == null) {
        clearOutScheduleLists(outBeforeIndScheduleInfoList, outAfterIndScheduleInfoList);
        return rejectParamErrScheduleSnapshot("変更前スケジュール情報の取得に失敗しました");
      }
      beforeList.add(row);
    }

    Long editKur = Long.parseLong(bodyData.getEdit_ind_kur_cd());
    Long editBed = Long.parseLong(bodyData.getEdit_ind_bed_cd());
    String editTreatStart = bodyData.getEdit_ind_treat_start_time() != null
      ? bodyData.getEdit_ind_treat_start_time().replaceAll(":", "") : null;

    List<IndScheduleInfo> afterList = new ArrayList<>();
    for (IndScheduleInfo before : beforeList) {
      IndScheduleInfo after = new IndScheduleInfo();
      after.setOrdNo(before.getOrdNo());
      after.setPatId(before.getPatId());
      after.setTreatDate(before.getTreatDate());
      after.setIndKurCd(editKur);
      after.setIndBedCd(editBed);
      after.setIndTreatStartTime(editTreatStart);
      after.setIndTreatmentCd(before.getIndTreatmentCd());
      after.setRstDialysisState(before.getRstDialysisState());
      afterList.add(after);
    }

    // ここから updateIndSchedule2 に必要な checkResponse を組み立てる
    // checkOrdScheduleMove と同様、after の ordNo/patId は「同一 ordNo の場合 null」に補正する
    int count = beforeList.size();
    for (int i = 0; i < Math.min(count, afterList.size()); i++) {
      if (Objects.equals(beforeList.get(i).getOrdNo(), afterList.get(i).getOrdNo())) {
        afterList.get(i).setOrdNo(null);
        afterList.get(i).setPatId(null);
      }
    }

    List<MstKur> mstKurList = mstKurDao.selectByFacilityCd(SelectOptions.get(), facilityCd, "0");
    mstKurList = mstKurList == null ? Collections.emptyList() : mstKurList;

    // updateIndScheduleByOrdMoveCheck は「入替」ではなく「同一 ordNo を別 bed/kur に更新」なので、
    // toBe は before を基準に 1 系列（go）のみ組み立てる。
    List<IndScheduleInfo> toBeOrdScheduleListGo = new ArrayList<>();
    for (IndScheduleInfo before : beforeList) {
      if (before == null) continue;
      IndScheduleInfo toBe = new IndScheduleInfo();
      toBe.setFacilityCd(facilityCd);
      toBe.setOrdNo(before.getOrdNo());
      toBe.setPatId(before.getPatId());
      toBe.setOldTreatDate(before.getTreatDate());
      // treatDate はこの API では変更しない（同日編集）
      toBe.setTreatDate(before.getTreatDate());
      // 変更後クール／ベッド／開始時刻
      toBe.setIndKurCd(indKurCd);
      toBe.setIndBedCd(indBedCd);
      toBe.setIndTreatStartTime(bodyData.getEdit_ind_treat_start_time() != null
        ? bodyData.getEdit_ind_treat_start_time().replaceAll(":", "")
        : null);
      // 治療方法・治療時間・曜日は DB 取得値（before）を引き継ぐ
      toBe.setIndTreatmentCd(before.getIndTreatmentCd());
      toBe.setIndTreatmentTime(before.getIndTreatmentTime());
      toBe.setTreatWeek(before.getTreatWeek());
      toBeOrdScheduleListGo.add(toBe);
    }

    // 補完処理（connectedXXX、クール時刻計算等）
    Map<String, List<IndScheduleInfo>> complemented =
      indScheduleServiceImpl.complementIndScheduleInfo(facilityCd, toBeOrdScheduleListGo, mstKurList);
    List<IndScheduleInfo> complementedList = complemented != null
      ? complemented.getOrDefault("indScheduleInfoList", toBeOrdScheduleListGo)
      : toBeOrdScheduleListGo;

    UpdateScheduleListDataResponse ok = new UpdateScheduleListDataResponse();
    ok.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.SUCCESS.toString());
    ok.setHasPatEvent(false);
    ok.setHasExam(false);
    ok.setHasRad(false);
    ok.setDupulicateOrdScheduleListAll(new ArrayList<>());
    ok.setToBeOrdScheduleListAllForCheak(complementedList);
    if (!bedUnregistOrdList.isEmpty()) {
      ok.setBedUnregistOrdList(bedUnregistOrdList);
    }
    if (!duplicatedOrdNoList.isEmpty()) {
      ok.setDuplicatedOrdNoList(duplicatedOrdNoList);
    }
    if (msgCd != null) {
      ok.setMsgCd(msgCd);
    }
    if (ordNoForMsg != null) {
      ok.setOrdNo(ordNoForMsg);
    }
    if (!scheduleCheckCoopOrdMainBeforeList.isEmpty()) {
      ok.setScheduleCheckCoopOrdMainBeforeList(scheduleCheckCoopOrdMainBeforeList);
    }
    if (!scheduleCheckCoopOrdMainAfterList.isEmpty()) {
      ok.setScheduleCheckCoopOrdMainAfterList(scheduleCheckCoopOrdMainAfterList);
    }

    if (outBeforeIndScheduleInfoList != null) {
      outBeforeIndScheduleInfoList.clear();
      outBeforeIndScheduleInfoList.addAll(beforeList);
    }
    if (outAfterIndScheduleInfoList != null) {
      outAfterIndScheduleInfoList.clear();
      outAfterIndScheduleInfoList.addAll(afterList);
    }
    return ok;
  }

  private static void clearOutScheduleLists(List<IndScheduleInfo> outBefore, List<IndScheduleInfo> outAfter) {
    if (outBefore != null) {
      outBefore.clear();
    }
    if (outAfter != null) {
      outAfter.clear();
    }
  }

  private static UpdateScheduleListDataResponse rejectParamErrScheduleSnapshot(String message) {
    UpdateScheduleListDataResponse r = new UpdateScheduleListDataResponse();
    r.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.PARAM_ERR.toString());
    r.setMessage(message);
    return r;
  }

  /**
   * 重複解消で未登録／クール時刻＋未登録に落とす対象 ordNo に対し、{@link #getDoCancelInfoForDuplicateDisregist} で分類し、
   * 状態 0 の重複側のみ直接未登録を行う。1/2/3+ は {@code removedList} によりフォールバック側未登録へ誘導する。
   * 条件送信キャンセル（{@code resetOrdMain}）は本専用分類では発生しない。{@code nextPatService.CallNextPatChange} は
   * {@code doCancelList} が空でない場合のみ（現状ここでは呼ばれない想定）。
   *
   * @param duplicateOrdNos getDoCancelInfoForDuplicateDisregist 適用後の残存 ordNo で上書き（同一リストを in-place 更新）
   * @param mainOrdNoList    更新対象の ordNo リスト（removedList 分を in-place で除去）
   * @param useKurTimeAndBedUnregistered true: {@code updateKurTimeAndBedUnregisteredForScheduleCheck}（update_mode=2・重複側）、
   *                                     false: {@code updateBedUnregisteredForScheduleCheck}（update_mode=1・重複側）。
   *                                     更新側フォールバック（removedList 時の再帰）: mainOrdNoList 内は {@code useKurTimeAndBedUnregistered}、外はベッド未登録のみ。
   * @param msgCdHolder       長さ1、条件送信キャンセルがあれば [0]={@code "22010007"}
   * @param ordNoForMsgHolder 長さ1、上記に対応する ordNo
   * @param conflictingUserOrdNosForNarrowRemoval 変更先重複と紐づく更新側 ordNo（skipOrdNoList 相当）。非空かつ removedList ありのとき、
   *                                                 旧仕様の「治療日単位で全除去」ではなく当該衝突 ord のみ main から除去する
   * @param requestOrdMainForFallbackPairing 変更対象の OrdMain（dummy が空のときのみフォールバック比較に使用）
   * @param dummyPreviewForFallbackPairing {@code selectDummyScheduleInOrdNoList} の結果。非空時は変更後スロットで removed と紐づけ（searchDuplicatedSchList と同じ座標系）
   * @param attemptOppositeSideFallback true のときのみ上記フォールバックを試行（再帰呼出では false）
   * @param coopOrdMainBeforeAcc #10553 連携用・変更前 ord_main の蓄積
   * @param coopOrdMainAfterAcc  #10553 連携用・変更後 ord_main の蓄積
   */
  private void applyDisRegistDuplicateOrdNoHandling(
    List<Long> duplicateOrdNos,
    List<Long> mainOrdNoList,
    OrdMainResource.UpdateInfoData updateInfo,
    ApiEntityOrdMain.ValiUpdateIndSchedule bodyData,
    String facilityCd,
    List<Long> bedUnregistOrdListAcc,
    boolean useKurTimeAndBedUnregistered,
    String[] msgCdHolder,
    Long[] ordNoForMsgHolder,
    List<Long> conflictingUserOrdNosForNarrowRemoval,
    List<OrdMain> requestOrdMainForFallbackPairing,
    List<OrdScheduleNewKurPreview> dummyPreviewForFallbackPairing,
    boolean attemptOppositeSideFallback,
    List<OrdMain> coopOrdMainBeforeAcc,
    List<OrdMain> coopOrdMainAfterAcc
  ) {
    if (duplicateOrdNos == null || duplicateOrdNos.isEmpty()) {
      return;
    }
    List<OrdMain> disRegistList = ordMainDao.selectByOrdNoList(duplicateOrdNos);
    DoCancelInfo disRegistDoCancelInfo = getDoCancelInfoForDuplicateDisregist(disRegistList);
    List<OrdMain> disRegistDoCancelList = disRegistDoCancelInfo.doCancelList;

    duplicateOrdNos.clear();
    duplicateOrdNos.addAll(
      disRegistDoCancelInfo.ordMainList.stream().map(OrdMain::getOrdNo).distinct().collect(Collectors.toList()));

    if (!duplicateOrdNos.isEmpty()) {
      List<Long> toUnregNos = new ArrayList<>(duplicateOrdNos);
      if (coopOrdMainBeforeAcc != null) {
        coopOrdMainBeforeAcc.addAll(ordMainDao.selectByOrdNoList(toUnregNos));
      }
      if (useKurTimeAndBedUnregistered) {
        ordMainResource.updateKurTimeAndBedUnregisteredForScheduleCheck(updateInfo, duplicateOrdNos, bodyData);
      } else {
        ordMainResource.updateBedUnregisteredForScheduleCheck(updateInfo, duplicateOrdNos, bodyData);
      }
      bedUnregistOrdListAcc.addAll(duplicateOrdNos);
      if (mainOrdNoList != null) {
        mainOrdNoList.removeAll(duplicateOrdNos);
      }
      if (coopOrdMainAfterAcc != null) {
        coopOrdMainAfterAcc.addAll(ordMainDao.selectByOrdNoList(toUnregNos));
      }
    }

    if (!disRegistDoCancelList.isEmpty() && coopOrdMainBeforeAcc != null) {
      coopOrdMainBeforeAcc.addAll(disRegistDoCancelList);
    }
    for (OrdMain sendCancelOrdMain : disRegistDoCancelList) {
      sendConditionCancelService.resetOrdMain(sendCancelOrdMain.getOrdNo());
    }
    if (!disRegistDoCancelList.isEmpty() && coopOrdMainAfterAcc != null) {
      List<Long> doCancelOrdNos = disRegistDoCancelList.stream()
        .map(OrdMain::getOrdNo)
        .filter(Objects::nonNull)
        .distinct()
        .collect(Collectors.toList());
      coopOrdMainAfterAcc.addAll(ordMainDao.selectByOrdNoList(doCancelOrdNos));
    }

    if (!disRegistDoCancelList.isEmpty()) {
      msgCdHolder[0] = "22010007";
      ordNoForMsgHolder[0] = disRegistDoCancelList.get(0).getOrdNo();
    }

    // 重複側が未登録化不可(removedList)のとき、変更後ダミーまたは OrdMain で同一スロットの更新側を未登録化して解消を試みる
    if (attemptOppositeSideFallback
      && !disRegistDoCancelInfo.removedList.isEmpty()
      && ((dummyPreviewForFallbackPairing != null && !dummyPreviewForFallbackPairing.isEmpty())
        || requestOrdMainForFallbackPairing != null)) {
      List<Long> fallbackOrdNos = dummyPreviewForFallbackPairing != null && !dummyPreviewForFallbackPairing.isEmpty()
        ? collectUserOrdNosPairedWithRemovedDuplicatesUsingDummyPreview(
          dummyPreviewForFallbackPairing, disRegistDoCancelInfo.removedList)
        : collectUserOrdNosPairedWithRemovedDuplicates(
          requestOrdMainForFallbackPairing, disRegistDoCancelInfo.removedList);
      fallbackOrdNos.removeIf(Objects::isNull);
      List<Long> fallbackInMainOrdNoList = new ArrayList<>();
      List<Long> fallbackOutsideMainOrdNoList = new ArrayList<>();
      if (mainOrdNoList != null && !mainOrdNoList.isEmpty()) {
        Set<Long> mainSet = mainOrdNoList.stream().filter(Objects::nonNull).collect(Collectors.toSet());
        for (Long no : fallbackOrdNos) {
          if (mainSet.contains(no)) {
            fallbackInMainOrdNoList.add(no);
          } else {
            fallbackOutsideMainOrdNoList.add(no);
          }
        }
      } else {
        fallbackOutsideMainOrdNoList.addAll(fallbackOrdNos);
      }
      if (!fallbackInMainOrdNoList.isEmpty()) {
        applyDisRegistDuplicateOrdNoHandling(
          new ArrayList<>(fallbackInMainOrdNoList),
          mainOrdNoList,
          updateInfo,
          bodyData,
          facilityCd,
          bedUnregistOrdListAcc,
          true,
          msgCdHolder,
          ordNoForMsgHolder,
          new ArrayList<>(fallbackInMainOrdNoList),
          null,
          null,
          false,
          coopOrdMainBeforeAcc,
          coopOrdMainAfterAcc);
      }
      if (!fallbackOutsideMainOrdNoList.isEmpty()) {
        applyDisRegistDuplicateOrdNoHandling(
          new ArrayList<>(fallbackOutsideMainOrdNoList),
          mainOrdNoList,
          updateInfo,
          bodyData,
          facilityCd,
          bedUnregistOrdListAcc,
          false,
          msgCdHolder,
          ordNoForMsgHolder,
          new ArrayList<>(fallbackOutsideMainOrdNoList),
          null,
          null,
          false,
          coopOrdMainBeforeAcc,
          coopOrdMainAfterAcc);
      }
    }

    if (!disRegistDoCancelInfo.removedList.isEmpty() && mainOrdNoList != null) {
      List<OrdMain> targetOrdMain = ordMainDao.selectByOrdNoList(mainOrdNoList);
      List<String> treatDateList = disRegistDoCancelInfo.removedList.stream()
        .map(OrdMain::getTreatDate).filter(Objects::nonNull).distinct().collect(Collectors.toList());
      if (conflictingUserOrdNosForNarrowRemoval != null && !conflictingUserOrdNosForNarrowRemoval.isEmpty()) {
        Set<Long> conflictUserOrdSet = conflictingUserOrdNosForNarrowRemoval.stream()
          .filter(Objects::nonNull)
          .collect(Collectors.toSet());
        targetOrdMain.removeIf(o ->
          o != null
            && o.getTreatDate() != null
            && treatDateList.contains(o.getTreatDate())
            && o.getOrdNo() != null
            && conflictUserOrdSet.contains(o.getOrdNo()));
      } else {
        targetOrdMain.removeIf(o -> o != null && o.getTreatDate() != null && treatDateList.contains(o.getTreatDate()));
      }
      mainOrdNoList.clear();
      mainOrdNoList.addAll(targetOrdMain.stream().map(OrdMain::getOrdNo).distinct().collect(Collectors.toList()));
    }

    if (!disRegistDoCancelList.isEmpty()) {
      try {
        List<OrdMain> forNextPat = new ArrayList<>();
        forNextPat.addAll(disRegistDoCancelList.stream().map(SerializationUtils::clone).collect(Collectors.toList()));
        forNextPat.addAll(disRegistDoCancelInfo.ordMainList.stream().map(SerializationUtils::clone).collect(Collectors.toList()));
        nextPatService.CallNextPatChange(facilityCd, forNextPat);
      } catch (Exception ignore) {
        // keep parity: old interface swallowed nextPat exceptions
      }
    }
  }

  private static class DoCancelInfo {
    final List<OrdMain> ordMainList;
    final List<OrdMain> doCancelList;
    final List<OrdMain> removedList;

    private DoCancelInfo(List<OrdMain> ordMainList, List<OrdMain> doCancelList, List<OrdMain> removedList) {
      this.ordMainList = ordMainList;
      this.doCancelList = doCancelList;
      this.removedList = removedList;
    }
  }

  private static DoCancelInfo getDoCancelInfo(List<OrdMain> ordMainList) {
    List<OrdMain> doCancelList = new ArrayList<>();
    List<OrdMain> removedList = new ArrayList<>();
    for (int i = ordMainList.size() - 1; -1 < i; i--) {
      Integer dialysisState = Integer.parseInt(ordMainList.get(i).getRstDialysisState());
      if (0 != ordMainList.get(i).getIndBedCd()) {
        if (1 == dialysisState || 2 == dialysisState) {
          doCancelList.add(ordMainList.get(i));
        }
        if (dialysisState >= 3) {
          removedList.add(ordMainList.get(i));
          ordMainList.remove(i);
        }
      }
    }
    return new DoCancelInfo(ordMainList, doCancelList, removedList);
  }

  /**
   * 重複解消専用。{@code rstDialysisState} が 1・2・3 以上でベッド登録済みの行は {@code removedList} に積み {@code ordMainList} から除去し、
   * 更新側フォールバック（{@code attemptOppositeSideFallback}）と同一経路に載せる。条件送信キャンセル（{@code doCancelList}）は使わない。
   * 状態 0 のみが残り、重複側の直接ベッド未登録の対象になり得る。
   */
  private static DoCancelInfo getDoCancelInfoForDuplicateDisregist(List<OrdMain> ordMainList) {
    List<OrdMain> doCancelList = new ArrayList<>();
    List<OrdMain> removedList = new ArrayList<>();
    for (int i = ordMainList.size() - 1; -1 < i; i--) {
      Integer dialysisState = Integer.parseInt(ordMainList.get(i).getRstDialysisState());
      if (0 != ordMainList.get(i).getIndBedCd()) {
        if (dialysisState > 0) {
          removedList.add(ordMainList.get(i));
          ordMainList.remove(i);
        }
      }
    }
    return new DoCancelInfo(ordMainList, doCancelList, removedList);
  }

  private static UpdateScheduleListDataResponse rejectWithMsgCd(String msgCd) {
    UpdateScheduleListDataResponse r = new UpdateScheduleListDataResponse();
    r.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.ERROR.toString());
    r.setMsgCd(msgCd);
    return r;
  }

  /**
   * {@code removedDuplicateOrdMainList} の各件と、{@code requestOrdMain} のうち
   * {@code treatDate}・{@code indKurCd}・{@code indBedCd} が一致する更新側 ordNo を重複なく返す（dummyDupulicate と同一ルール）。
   */
  public List<Long> collectUserOrdNosPairedWithRemovedDuplicates(
    List<OrdMain> requestOrdMain,
    List<OrdMain> removedDuplicateOrdMainList
  ) {
    List<Long> out = new ArrayList<>();
    if (requestOrdMain == null || removedDuplicateOrdMainList == null) {
      return out;
    }
    for (OrdMain e : removedDuplicateOrdMainList) {
      if (e == null) {
        continue;
      }
      for (OrdMain o : requestOrdMain) {
        if (o == null || o.getOrdNo() == null) {
          continue;
        }
        if (Objects.equals(o.getTreatDate(), e.getTreatDate())
          && Objects.equals(o.getIndKurCd(), e.getIndKurCd())
          && Objects.equals(o.getIndBedCd(), e.getIndBedCd())) {
          if (!out.contains(o.getOrdNo())) {
            out.add(o.getOrdNo());
          }
        }
      }
    }
    return out;
  }

  /**
   * {@code removedDuplicateOrdMainList} の各件と、ダミー（変更後）スケジュール {@code dummyPreviewList} の {@code keyNo} で、
   * {@code searchDuplicatedSchList} と同じ治療日・クール・ベッド一致で更新側 ordNo を重複なく返す。
   */
  public List<Long> collectUserOrdNosPairedWithRemovedDuplicatesUsingDummyPreview(
    List<OrdScheduleNewKurPreview> dummyPreviewList,
    List<OrdMain> removedDuplicateOrdMainList
  ) {
    List<Long> out = new ArrayList<>();
    if (dummyPreviewList == null || dummyPreviewList.isEmpty() || removedDuplicateOrdMainList == null) {
      return out;
    }
    for (OrdMain e : removedDuplicateOrdMainList) {
      if (e == null) {
        continue;
      }
      for (OrdScheduleNewKurPreview sch : dummyPreviewList) {
        if (sch == null || sch.getKeyNo() == null) {
          continue;
        }
        if (previewSlotMatchesRemovedOrd(e, sch) && !out.contains(sch.getKeyNo())) {
          out.add(sch.getKeyNo());
        }
      }
    }
    return out;
  }

  private static boolean previewSlotMatchesRemovedOrd(OrdMain removed, OrdScheduleNewKurPreview sch) {
    if (!Objects.equals(removed.getTreatDate(), sch.getTreatDate())) {
      return false;
    }
    return kurCdMatchesPreview(removed.getIndKurCd(), sch.getKurCd())
      && bedCdMatchesPreview(removed.getIndBedCd(), sch.getBedCd());
  }

  private static boolean kurCdMatchesPreview(Integer ordKur, Long previewKur) {
    if (ordKur == null || previewKur == null) {
      return false;
    }
    return ordKur.longValue() == previewKur.longValue();
  }

  private static boolean bedCdMatchesPreview(Integer ordBed, Long previewBed) {
    if (ordBed == null || previewBed == null) {
      return false;
    }
    return ordBed.longValue() == previewBed.longValue();
  }

  /**
   * 変更先重複側に未登録化不可(登録ベッドかつ透析状態>=3)があり、かつ同一治療日の更新対象側にも同様の予定がある場合 true。
   * このとき 12010002 の確認ではなく {@code 12000240} で不可とする。
   */
  public boolean hasDialysisLockedConflictBothSides(List<OrdMain> requestOrdMainList, List<Long> duplicateOrdNoList) {
    if (duplicateOrdNoList == null || duplicateOrdNoList.isEmpty() || requestOrdMainList == null || requestOrdMainList.isEmpty()) {
      return false;
    }
    List<Long> dupIds = duplicateOrdNoList.stream().filter(Objects::nonNull).distinct().collect(Collectors.toList());
    if (dupIds.isEmpty()) {
      return false;
    }
    List<OrdMain> dupMains = ordMainDao.selectByOrdNoList(dupIds);
    if (dupMains == null || dupMains.isEmpty()) {
      return false;
    }
    if (!dupMains.stream().anyMatch(IndScheduleUpdateCheck::isDialysisLockedCannotUnregistBed)) {
      return false;
    }
    Set<String> lockedDupTreatDates = dupMains.stream()
      .filter(IndScheduleUpdateCheck::isDialysisLockedCannotUnregistBed)
      .map(OrdMain::getTreatDate)
      .filter(Objects::nonNull)
      .collect(Collectors.toSet());
    if (lockedDupTreatDates.isEmpty()) {
      return false;
    }
    return requestOrdMainList.stream()
      .filter(o -> o != null && o.getTreatDate() != null && lockedDupTreatDates.contains(o.getTreatDate()))
      .anyMatch(IndScheduleUpdateCheck::isDialysisLockedCannotUnregistBed);
  }

  /** {@link #getDoCancelInfo} と同条件: 登録ベッドかつ透析状態が条件送信確認済み以降(>=3)でベッド未登録化できない */
  private static boolean isDialysisLockedCannotUnregistBed(OrdMain o) {
    if (o == null || o.getIndBedCd() == null || o.getRstDialysisState() == null) {
      return false;
    }
    if (o.getIndBedCd() == 0) {
      return false;
    }
    try {
      int s = Integer.parseInt(o.getRstDialysisState().trim());
      return s >= 3;
    } catch (NumberFormatException e) {
      return false;
    }
  }
}
