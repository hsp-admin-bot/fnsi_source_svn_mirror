package jp.co.nikkiso.ntss.admin_web.service.measureHistory;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.admin_web.response.measureHistory.OrdWeightScaleResponse;
import jp.co.nikkiso.ntss.core.dao.OrdWeightScaleDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.OrdWeightScale;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;

@Service
public class MeasureHistoryServiceImpl implements MeasureHistoryService {

  @Autowired
  private OrdWeightScaleDao ordWeightScaleDao;
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

  /**
   * {@inheritDoc}
   */
  @Override
  public List<OrdWeightScaleResponse> getOrder(String facilityCd, Timestamp startDate, Timestamp endDate) {
    List<OrdWeightScaleResponse> res = new ArrayList<>();
    List<OrdWeightScale> ordList = ordWeightScaleDao.selectByFacility(facilityCd, startDate, endDate);
    List<Long> patIdList = ordList.stream().map(s -> s.getPatId()).distinct().collect(Collectors.toList());
    patIdList.removeAll(Collections.singleton(null)); // null削除
    List<PatPersonalMain> pats = patPersonalMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
    List<PatPersonalMain> pat;
    String patLastName = "";
    String patFirstName = "";
    // FNSI-add 患者IDの修正 徐 start
    String hospPatId = "";
    // FNSI-add 患者IDの修正 徐 end
    for (OrdWeightScale ordWeight : ordList) {

      // 患者名取得
      pat = pats.stream().filter(p -> Objects.equals(p.getPat_id(), ordWeight.getPatId())).collect(Collectors.toList());
      patLastName = "";
      patFirstName = "";
      // #12630 2026.05.26 add 院内患者IDの初期化漏れ TDC片口 start
      hospPatId = "";
      // #12630 2026.05.26 add 院内患者IDの初期化漏れ TDC片口 end
      if (pat.size() > 0) {
        patLastName = pat.get(0).getPat_last_name();
        patFirstName = pat.get(0).getPat_first_name();
        // FNSI-add 患者IDの修正 徐 start
        hospPatId = pat.get(0).getHosp_pat_id();
        // FNSI-add 患者IDの修正 徐 end
      }

      // 応答用体重計測定記録情報作成
      OrdWeightScaleResponse r = new OrdWeightScaleResponse();
      r.setWeightScaleNo(ordWeight.getWeightScaleNo());
      r.setOrdNo(ordWeight.getOrdNo());
      r.setFacilityCd(ordWeight.getFacilityCd());
      r.setWeightName(ordWeight.getWeightName());
      r.setWeightScaleStatus(ordWeight.getWeightScaleStatus());
      r.setMessage(ordWeight.getMessage());
      r.setMeasureDate(ordWeight.getMeasureDate());
      r.setBedCd(ordWeight.getBedCd());
      r.setBedName(ordWeight.getBedName());
      r.setKurCd(ordWeight.getKurCd());
      r.setKurName(ordWeight.getKurName());
      r.setPatId(ordWeight.getPatId());
      r.setPatLastName(patLastName);
      r.setPatFirstName(patFirstName);
      r.setScaleClass(ordWeight.getScaleClass());
      r.setScaleMode(ordWeight.getScaleMode());
      r.setScaleValue(ordWeight.getScaleValue());
      r.setRstTareInfo(ordWeight.getRstTareInfo());
      r.setRstOffWaterInfo(ordWeight.getRstOffWaterInfo());
      r.setWeightValue(ordWeight.getWeightValue());
      r.setTargetWeightValue(ordWeight.getTargetWeightValue());
      r.setWheelChairCd(ordWeight.getWheelChairCd());
      r.setWheelChairName(ordWeight.getWheelChairName());
      r.setWheelChairWeight(ordWeight.getWheelChairWeight());
      r.setOffWaterLimit(ordWeight.getOffWaterLimit());
      r.setUserId(ordWeight.getUserId());
      // FNSI-add 患者IDの修正 徐 start
      r.setHospPatId(hospPatId);
      // FNSI-add 患者IDの修正 徐 end

      res.add(r);
    }

    return res;
  }

  @Override
  public OrdWeightScale getSingle(Long serialNo) {
    return ordWeightScaleDao.selectByCd(serialNo);
  }

}
