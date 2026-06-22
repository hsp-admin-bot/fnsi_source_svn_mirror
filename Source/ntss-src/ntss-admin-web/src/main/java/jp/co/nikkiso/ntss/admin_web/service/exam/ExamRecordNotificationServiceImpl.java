package jp.co.nikkiso.ntss.admin_web.service.exam;

import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class ExamRecordNotificationServiceImpl implements ExamRecordNotificationService{
  @Autowired
  private WebApiCallCommonUtil webApiCallCommonUtil;

  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

  /**
   * 検査結果からの感染症連動の場合の感染症通知がされない
   * 通知がされない
   * @param oldPatMain
   * @param newPatMain
   */
  @Override
  public void registerInfectionNotification(PatMain oldPatMain, PatMain newPatMain) {
    List<String> newinfectionCdList = this.getinfectInfo(newPatMain);
    List<String> oldinfectionCdList = this.getinfectInfo(oldPatMain);
    Boolean infectInfoFlag = false;
    for (int i = 0; i < newinfectionCdList.size(); i++) {
      if (!oldinfectionCdList.contains(newinfectionCdList.get(i))) {
        infectInfoFlag = true;
        break;
      }
    }
    if(infectInfoFlag){
      PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(newPatMain.getPat_id());
      JSONObject baseReplaceData = new JSONObject();
      baseReplaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
      baseReplaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());
      JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
      replaceData.put("PATID", String.valueOf(newPatMain.getPat_id()));
      replaceData.put("FACILITYCD", patPersonalMain.getFacility_cd());
      try {
        webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.CHANGE_INFECT_POSITIVE, patPersonalMain.getFacility_cd(), replaceData);
      } catch (URISyntaxException e) {
//        e.printStackTrace();
        log.error(String.valueOf(e));
      }
    }
  }
  
  /**
   * 感染症取得
   * @param patMain 患者固有情報
   * @return
   */
  private List<String> getinfectInfo(PatMain patMain) {
    List<String> infectionCdList = new ArrayList<>();
    if (patMain != null) {
      String infectInfo = patMain.getInfect_info();
      if (!"[]".equals(infectInfo)) {
        JSONArray newInfectInfoJsonList = new JSONArray(infectInfo);
        for (int i = 0; i < newInfectInfoJsonList.length(); i++) {
          JSONObject jsonObj = newInfectInfoJsonList.getJSONObject(i);
          if ("2".equals(jsonObj.get("infect").toString())) {
            String code = jsonObj.get("infection_cd").toString();
            infectionCdList.add(code);
          }
        }
      }
    }
    return infectionCdList;
  }
}
