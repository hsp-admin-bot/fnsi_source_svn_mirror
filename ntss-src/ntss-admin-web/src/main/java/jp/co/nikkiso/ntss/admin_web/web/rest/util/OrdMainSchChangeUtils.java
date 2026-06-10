package jp.co.nikkiso.ntss.admin_web.web.rest.util;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.service.MstInfoService;
import jp.co.nikkiso.ntss.core.dao.OrdScheduleDao;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdSchedule;
import jp.co.nikkiso.ntss.core.entity.OrdScheduleNewKurPreview;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * ord_main scheduleクラス
 */
@Component
public class OrdMainSchChangeUtils {

  @Autowired
  MstInfoService mstInfoService;

  @Autowired
  OrdScheduleDao ordScheduleDao;

  /**
   * 患者治療の変更する前に、治療ベッドの使うが重複場合、優先順位低い番号を検索する
   *
   * @param facilityCd   施設コード
   * @param ordScheduleList   更新範囲内展開した治療
   * @return 正常終了:未登録に落としクール時刻のみ登録するオーダー番号 list、異常終了:null
   */
  public List<Long> searchLowPriorityNoList(String facilityCd, List<OrdScheduleNewKurPreview> ordScheduleList) {
    record Tuple(Long patId, String treatDate, Long kurCd, Long bedCd) {
    }
    Map<Tuple, List<OrdScheduleNewKurPreview>> tupleListMap = ordScheduleList.stream()
      .collect(Collectors.groupingBy(ord -> new Tuple(ord.getPatId(), ord.getTreatDate(), ord.getKurCd(), ord.getBedCd()), LinkedHashMap::new, Collectors.toList()));

    MstTreatment mstTreatmentSearchData = new MstTreatment();
    mstTreatmentSearchData.setFacilityCd(facilityCd);
    // 治療方法リストを取得し治療方法コードのみを抽出
    List<MstTreatment> mstTreatmentList = mstInfoService.findMstTreatmentList(mstTreatmentSearchData);

    // 取得した治療方法リストに特殊浄化と不明を除外して治療方法コードをまとめる
    List<Integer> treatmentCdNoPurificationUnknownList = mstTreatmentList.stream()
      .filter(t -> Objects.isNull(t.getDeviceMode()) || (t.getDeviceMode().compareTo(AdminWebConstant.Treatment.DeviceMode.PURIFICATION) != 0
        && t.getDeviceMode().compareTo(AdminWebConstant.Treatment.DeviceMode.UNKNOWN) != 0))
      .map(MstTreatment::getTreatmentCd).toList();

    // 取得した治療方法リストに特殊浄化と不明を取得して治療方法コードをまとめる
    List<Integer> treatmentCdPurificationUnknownList = new ArrayList<>(mstTreatmentList.stream()
      .filter(t -> Objects.nonNull(t.getDeviceMode()) && (t.getDeviceMode().compareTo(AdminWebConstant.Treatment.DeviceMode.PURIFICATION) == 0))
      .map(MstTreatment::getTreatmentCd).toList());
    treatmentCdPurificationUnknownList.addAll(mstTreatmentList.stream()
      .filter(t -> Objects.nonNull(t.getDeviceMode()) && (t.getDeviceMode().compareTo(AdminWebConstant.Treatment.DeviceMode.UNKNOWN) == 0))
      .map(MstTreatment::getTreatmentCd).toList());

    List<Long> lowPriorityNoList = new ArrayList<>();
    tupleListMap.forEach((key, schList) -> {
      if (schList.size() > 1) {
        schList = schList.stream().filter(s -> !lowPriorityNoList.contains(s.getKeyNo())).toList();

        // オーダー番号リストの中で優先順位の一番高い治療方法を取得
        List<OrdScheduleNewKurPreview> finalSchList = schList;
        Optional<Integer> treatmentResult =
          treatmentCdNoPurificationUnknownList.stream()
            .filter(i -> finalSchList.stream().anyMatch(e -> e.getIndTreatmentCd().equals(i)))
            .findFirst();

        if (treatmentResult.isEmpty()) {
          treatmentResult = treatmentCdPurificationUnknownList.stream()
            .filter(i -> finalSchList.stream().anyMatch(e -> e.getIndTreatmentCd().equals(i)))
            .findFirst();
        }
        Integer topTreatmentCd = treatmentResult.orElse(0);

        if (topTreatmentCd.compareTo(0) > 0) {
          // 同日予定リストの中から優先順位が低い治療方法の予定を抽出（ベッド未登録更新対象）
          List<Long> subLowPriorityNoList = schList.stream()
            .filter(e -> !e.getIndTreatmentCd().equals(topTreatmentCd))
            .map(OrdScheduleNewKurPreview::getKeyNo)
            .toList();
          if (schList.size() - subLowPriorityNoList.size() > 1) {
            List<Long> finalSubLowPriorityNoList = subLowPriorityNoList;
            List<OrdScheduleNewKurPreview> newSchList = schList.stream().filter(s -> !finalSubLowPriorityNoList.contains(s.getKeyNo())).collect(Collectors.toList());
            newSchList.remove(0);
            subLowPriorityNoList = newSchList.stream().map(OrdScheduleNewKurPreview::getKeyNo).toList();
          }
          lowPriorityNoList.addAll(subLowPriorityNoList);
        }
      }
    });
    return lowPriorityNoList;
  }

  /**
   * 患者治療の変更する前に、治療ベッドの使うが重複場合、優先順位低い番号を検索する
   *
   * @param facilityCd   施設コード
   * @param editIndKurCd 治療情報スケジュール編集クール情報
   * @param ordNoList    更新対象のオーダー番号
   * @return 正常終了:未登録に落としクール時刻のみ登録するオーダー番号 list、異常終了:null
   */
  public List<OrdSchedule> searchDuplicatedSchList(String facilityCd, String editIndKurCd, String editIndBedCd, String editIndTreatStartTime, List<Long> ordNoList) {

    // 今回変更したい予定のダミースケジュールを作成する
    List<OrdScheduleNewKurPreview> ordScheduleList = ordScheduleDao.selectDummyScheduleInOrdNoList(facilityCd, ordNoList, Long.parseLong(editIndKurCd), Long.parseLong(editIndBedCd), editIndTreatStartTime);
    List<Long> beforeExcludeHimOrdNoList = ordScheduleList.stream().map(OrdScheduleNewKurPreview::getKeyNo).distinct().collect(Collectors.toList());

    List<OrdSchedule> allPatDupulicateSchList;
    // ダミースケジュールがある場合
    if (!beforeExcludeHimOrdNoList.isEmpty()) {
      // 今回変更したい予定以外、同一治療日、クール、ベッドの治療を検索する
      allPatDupulicateSchList = ordScheduleDao.selectOrdScheduleWithNewKur(facilityCd, ordScheduleList, beforeExcludeHimOrdNoList);
      if (!allPatDupulicateSchList.isEmpty()) {
        // ダミースケジュールが既存のスケジュールに同一治療日、クール、ベッドの治療noをまとめる
        List<Long> updatedDupulicateOrdNoList = ordScheduleList.stream()
          .filter(sch -> allPatDupulicateSchList.stream()
            .anyMatch(e -> e.getTreatDate().equals(sch.getTreatDate())
              && e.getKurCd().equals(sch.getKurCd())
              && e.getBedCd().equals(sch.getBedCd()))).map(OrdScheduleNewKurPreview::getKeyNo).toList();
        // 別治療スケジュールと一緒に戻る
        allPatDupulicateSchList.addAll(updatedDupulicateOrdNoList.stream().map(no -> {
          OrdSchedule ordSchedule = new OrdSchedule();
          ordSchedule.setOrdNo(no);
          return ordSchedule;
        }).toList());
      }
    } else {
      allPatDupulicateSchList = new ArrayList<>();
    }
    return allPatDupulicateSchList;
  }
}
