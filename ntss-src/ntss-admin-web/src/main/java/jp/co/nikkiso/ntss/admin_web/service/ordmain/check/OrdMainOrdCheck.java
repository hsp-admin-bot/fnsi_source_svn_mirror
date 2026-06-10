package jp.co.nikkiso.ntss.admin_web.service.ordmain.check;

import jp.co.nikkiso.ntss.admin_web.web.rest.validation.ApiEntityOrdMain;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.MstTreatmentSet;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Objects;

@Component
public class OrdMainOrdCheck {

  @Autowired
  private OrdMainDao ordMainDao;

  public String validateScheduleScope(ApiEntityOrdMain.ValiCreateTreatPlan bodyData, Integer treatmentCd) {
    if ((!Objects.isNull(bodyData.getInd_kur_cd()) || !"[]".equals(bodyData.getInd_kur_cd()))
      && !Objects.isNull(bodyData.getInd_bed_cd()) && !Objects.isNull(bodyData.getInd_treat_start_time())) {

      //ダミースケジュール重複チェック
      List<String> listInfoDummy = ordMainDao.selectDummyOrdNoByTreatDateKurCdBedCd(
        Long.parseLong(bodyData.getInd_bed_cd()),
        bodyData.getTreatDays().replace("[", StringUtils.EMPTY).replace("]", StringUtils.EMPTY).replace("\"", StringUtils.EMPTY),
        Long.parseLong(bodyData.getInd_kur_cd()));
      if (!listInfoDummy.isEmpty()) {
        return "Dummy治療予定重複エラー";
      }

      // 重複チェック
      List<String> listInfo = ordMainDao.selectOrdNoByTreatmentCdTreatDateKurCd(
        Long.parseLong(bodyData.getPat_id()),
        treatmentCd,
        bodyData.getTreatDays().replace("[", StringUtils.EMPTY).replace("]", StringUtils.EMPTY).replace("\"", StringUtils.EMPTY),
        Long.parseLong(bodyData.getInd_kur_cd()));
      if (!listInfo.isEmpty()) {
        return "3治療予定重複エラー";
      }

      // 重複チェック
      List<String> listInfo2 = ordMainDao.selectOrdNoByTreatDateKurCd(
        Long.parseLong(bodyData.getInd_bed_cd()),
        bodyData.getTreatDays().replace("[", StringUtils.EMPTY).replace("]", StringUtils.EMPTY).replace("\"", StringUtils.EMPTY),
        Long.parseLong(bodyData.getInd_kur_cd()));
      if (!listInfo2.isEmpty()) {
        return "4治療予定重複エラー";
      }
    }
    return StringUtils.EMPTY;
  }

  public String validateTreatmentSetChangeForCreate(String update, MstTreatmentSet treatmentSet) throws ParseException {
    Timestamp bodyUpdate = new Timestamp(new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ").parse(update).getTime());
    if (!treatmentSet.getUpDate().equals(bodyUpdate)) {
      return "治療方法セットが更新されている為、治療予定登録を中止"
        + " 更新日時(マスタ):" + treatmentSet.getUpDate()
        + " 更新日時(引数):" + bodyUpdate;
    }
    return StringUtils.EMPTY;
  }
}
