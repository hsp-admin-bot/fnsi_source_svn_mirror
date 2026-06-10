package jp.co.nikkiso.ntss.admin_web.service.ordmain.check;

import jp.co.nikkiso.ntss.core.dao.OrdScheduleDao;
import jp.co.nikkiso.ntss.core.entity.OrdSchedule;
import jp.co.nikkiso.ntss.core.entity.OrdScheduleNewKurPreview;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Component
public class OrdMainCondInfoCheck {

  @Autowired
  private OrdScheduleDao ordScheduleDao;

  public String validateScheduleExtension(String isDeadline, String schExtStatus) {
    if (Boolean.FALSE.toString().equals(isDeadline)) {
      if (("1").equals(schExtStatus)) {
        JSONObject msgJson = new JSONObject("{}");
        msgJson.put("msgCd", 22020004);
        return msgJson.toString();
      }
    }
    return StringUtils.EMPTY;
  }

  public String validateScheduleChangeScope(String facilityCd, JSONObject treatTimeInfo, List<Long> updPreOrdOrdNoList) {
    if (!treatTimeInfo.isNull("value") && !"null".equals(treatTimeInfo.get("value"))) {
      List<OrdScheduleNewKurPreview> scheduleList = ordScheduleDao
        .selectOrdMainScheduleDummyInOrdNoList(facilityCd, updPreOrdOrdNoList, treatTimeInfo.get("value").toString());
      List<Long> scheduleListOrdNoList = scheduleList.stream().map(OrdScheduleNewKurPreview::getKeyNo).distinct().collect(Collectors.toList());
      List<OrdSchedule> changeOutsideScopeSchList;

      // 変更範囲内チェック
      Map<String, List<OrdScheduleNewKurPreview>> groupedList = scheduleList.stream()
        .collect(Collectors.groupingBy(record ->
          record.getTreatDate() + "_" + record.getKurCd() + "_" + record.getBedCd(), LinkedHashMap::new, Collectors.toList()));
      if (!groupedList.isEmpty() && groupedList.values().stream()
        .anyMatch(list -> list.size() > 1)) {
        JSONObject msgJson = new JSONObject("{}");
        msgJson.put("msgCd", 22020002);
        return msgJson.toString();
      }

      //変更範囲外チェック
      if (!scheduleList.isEmpty()) {
        changeOutsideScopeSchList = ordScheduleDao.selectOrdScheduleWithNewKur(facilityCd, scheduleList, scheduleListOrdNoList);
        if (!changeOutsideScopeSchList.isEmpty()) {
          JSONObject msgJson = new JSONObject("{}");
          msgJson.put("msgCd", 22020002);
          return msgJson.toString();
        }
      }
    }
    return StringUtils.EMPTY;
  }
}
