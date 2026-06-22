package jp.co.nikkiso.ntss.admin_web.service.indicationResult;

import jp.co.nikkiso.ntss.core.entity.ForecastInforResult;
import jp.co.nikkiso.ntss.core.entity.IndicationResult;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.dao.IndicationResultDao;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstKurDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import lombok.extern.slf4j.Slf4j;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 予実リスト画面のService実装クラス.
 */
@Service
@Slf4j
public class IndicationResultServiceImpl implements IndicationResultService {

  /**
   * 予実リストのDaoインタフェース.
   */
  @Autowired
  private IndicationResultDao indicationResultDao;

  /**
   * 利用者マスタのDaoインタフェース.
   */
  @Autowired
  private MstUserDao mstUserDao;

  /**
   * クールマスタのDaoインタフェース.
   */
  @Autowired
  private MstKurDao mstKurDao;

  /**
   * ベッドマスタのDaoインタフェース.
   */
  @Autowired
  private MstBedDao mstBedDao;

  /**
   * 治療方法マスタのDaoインタフェース.
   */
  @Autowired
  private MstTreatmentDao mstTreatmentDao;

  /**
   * 患者基本情報のDaoインタフェース.
   */
  @Autowired
  private PatMainDao patMainDao;

  /**
  * ロギングのServiceインタフェース.
  */
  @Autowired
  private LogService logService;

  /**
   * {@inheritDoc}
   */
  @Override
  public List<IndicationResult> getList(Long patId, String treatDateFrom, String treatDateTo, String facilityCd) {
    List<IndicationResult> indicationResult = indicationResultDao.selectByPatIdAndTreatDate(patId, treatDateFrom, treatDateTo, facilityCd);

    // 患者基本情報から施設コード取得
    // PatMain patMain = patMainDao.selectById(patId);
    // String facilityCd = patMain.getFacility_cd();

    // クールマスタ取得
    // SelectOptions selectOptions = SelectOptions.get();
    // List<MstKur> mstKurList = mstKurDao.selectByFacilityCd(selectOptions, facilityCd, "0");
    //
    // // ベッドマスタ取得
    // List<MstBed> mstBedList = mstBedDao.selectByFacilityCd(facilityCd, "1", "0");
    //
    // // 治療方法マスタ取得
    // MstTreatment mstTreatmentSearchData = new MstTreatment();
    // mstTreatmentSearchData.setFacilityCd(facilityCd);
    // List<MstTreatment> mstTreatmentList = mstTreatmentDao.selectAll(selectOptions, mstTreatmentSearchData);
    //
    // // 予実リストにマスタからのデータを入れる
    // for (IndicationResult result : indicationResult) {
    //
    //   // クールマスタ(クール開始時刻、クール名)
    //   if (result.getKurCd() != null && result.getKurCd() != 0L) {
    //     Boolean foundKur = false;
    //     for (MstKur kur : mstKurList) {
    //       if (result.getKurCd().toString().equals(kur.getKurCd().toString())) {
    //         foundKur = true;
    //         result.setKurStartTime(kur.getKurStartTime());
    //         if (result.getKurName() == null || result.getKurName().equals("")) {
    //           result.setKurName(kur.getKurName());
    //         }
    //         break;
    //       }
    //     }
    //     if (!foundKur) {
    //       result.setKurStartTime("000000");
    //       result.setKurName("クール削除済み");
    //     }
    //   } else {
    //     result.setKurStartTime("000000");
    //     result.setKurName("クール未登録");
    //   }
    //
    //   // ベッドマスタ(ベッド名)
    //   if (result.getBedCd() != null && result.getBedCd() != 0L) {
    //     Boolean foundBed = false;
    //     for (MstBed bed : mstBedList) {
    //       if (result.getBedCd().equals(bed.getBedCd())) {
    //         foundBed = true;
    //         if (result.getBedName() == null || result.getBedName().equals("")) {
    //           result.setBedName(bed.getBedName());
    //         }
    //         break;
    //       }
    //     }
    //     if (!foundBed) {
    //       result.setBedName("ベッド削除済み");
    //     }
    //   } else {
    //     result.setBedName("ベッド未登録");
    //   }
    //
    //   // 治療方法マスタ(治療方法名)
    //   if (result.getTreatmentCd() != null && result.getTreatmentCd() != 0) {
    //     Boolean foundTreatment = false;
    //     for (MstTreatment treatment : mstTreatmentList) {
    //       if (result.getTreatmentCd().equals(treatment.getTreatmentCd())) {
    //         foundTreatment = true;
    //         if (result.getTreatmentName() == null || result.getTreatmentName().equals("")) {
    //           result.setTreatmentName(treatment.getTreatmentName());
    //         }
    //         break;
    //       }
    //     }
    //     if (!foundTreatment) {
    //       result.setTreatmentName("治療方法削除済み");
    //     }
    //   } else {
    //     result.setTreatmentName("治療方法未登録");
    //   }
    //
    // }
    return indicationResult;
  }

  // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
  /**
   * {@inheritDoc}
   *
   * @param treatDateFrom 治療日(From)
   * @param treatDateTo 治療日(To)
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @param pattern 1:(患者イベント)、3:(検査結果)、4:(一般撮影検査予定)、5:(処方)
   * 予実リストの取得.
   */
  @Override
  public List<ForecastInforResult> getList(String treatDateFrom, String treatDateTo, Long patId, String facilityCd, int pattern) {
    List<ForecastInforResult> forecastInforResult = null;
    // 患者イベント
    if (1 == pattern) {
      forecastInforResult = indicationResultDao.selectPatientEventResultList(
        treatDateFrom,
        treatDateTo,
        patId,
        facilityCd
      );

    // 検査結果
    } else if (3 == pattern) {
      forecastInforResult = indicationResultDao.selectInspectionResultList(
        treatDateFrom,
        treatDateTo,
        patId,
        facilityCd
      );

    // 一般撮影検査予定
    } else if (4 == pattern) {
      forecastInforResult = indicationResultDao.selectGenPhotoInsResultList(
        treatDateFrom,
        treatDateTo,
        patId,
        facilityCd
      );

    // 処方
    } else if (5 == pattern) {
      forecastInforResult = indicationResultDao.selectPrescriptionResultList(
        treatDateFrom,
        treatDateTo,
        patId,
        facilityCd
      );
    }

    return forecastInforResult;
  }

  /**
   * {@inheritDoc}
   *
   * @param examSetCd 検査セットID
   * @return チェック項目数
   */
  @Override
  public Map<String, String> getCheckNum(String facilityCd, List<String> examSetCd) {
    Map<String, String> examSetCdMap = new HashMap<>();
    if (examSetCd == null || examSetCd.isEmpty()) {
      return examSetCdMap;
    }
    Map<String, String> checkNumByExamSetCd = new HashMap<>();
    List<ForecastInforResult> checkNumList = indicationResultDao.selectCheckNumByExamSetCdList(facilityCd, examSetCd);
    if (checkNumList != null) {
      for (ForecastInforResult checkNumResult : checkNumList) {
        if (checkNumResult != null && checkNumResult.getUniqueSerial() != null) {
          checkNumByExamSetCd.put(String.valueOf(checkNumResult.getUniqueSerial()), checkNumResult.getJsonValue());
        }
      }
    }
    for (String examSetCdValue: examSetCd) {
      String jsonValue = checkNumByExamSetCd.get(examSetCdValue);
      if (jsonValue != null) {
        examSetCdMap.put(examSetCdValue, jsonValue);
      }
    }
    return examSetCdMap;
  }
  // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end

  // add FNSI-改修内容 治療単位の治療方法マスタの有効項目に応じた表示 dou start
  /**
   * {@inheritDoc}
   */
  @Override
  public List<String> getTreatmentConditionSetting(String facilityCd,String treatmentName){
    return indicationResultDao.selectTreatmentConditionSetting(facilityCd, treatmentName);
  };
  // add FNSI-改修内容 治療単位の治療方法マスタの有効項目に応じた表示 dou end
}
