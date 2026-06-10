package jp.co.nikkiso.ntss.device_edge.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.ComsvOrdMainDao;
import jp.co.nikkiso.ntss.core.dao.ComsvOrdTreatConditionDao;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvOrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvOrdTreatCondition;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.device_edge.util.CondInfo.CondInfoService;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;

@Service
public class ComsvOrdTreatConditionServiceImpl implements ComsvOrdTreatConditionService {

  @Autowired
  private LogService logService;

  @Autowired
  ComsvOrdTreatConditionDao comsvOrdTreatConditionDao;
  @Autowired
  ComsvOrdMainDao comsvOrdMainDao;
  // add #IES_6789 dou start
  @Autowired
  CondInfoService condInfoService;
  // add #IES_6789 dou end
  @Override
  public List<ComsvOrdTreatCondition> selectCondition(ComsvOrdTreatCondition param) {
    return comsvOrdTreatConditionDao.selectCondition(param);
  }

  @Override
  @Transactional
  public int deleteCondition(ComsvOrdTreatCondition param) {


    int updateCount = comsvOrdTreatConditionDao.deleteCondition(param);

    return updateCount;
  }

  @Override
  @Transactional
  public int insertCondition(ComsvOrdTreatCondition param) {
	int iRet = -1;
    try {
      if ( param.getTreatClass() == 3 ) {
        // 排液の場合、最新データのみ有効とする
        // 排液の設定値読み込み履歴を抽出
    	List<ComsvOrdTreatCondition> ordTreatCondition =  selectCondition(param);
        if ( ordTreatCondition.size() > 0 ) {

        	// データが存在する場合、設定値読み込み履歴を削除（削除フラグON）
          int updateCount = comsvOrdTreatConditionDao.deleteCondition(param);

        }
      }
      // 設定値読み込み履歴を追加
      iRet = comsvOrdTreatConditionDao.insertCondition(param);
      if ( iRet > 0 && param.getTreatClass() == 2 ) {
	    // 運転開始時に目標除水量を更新する
	      ObjectMapper mapper = new ObjectMapper();
        JsonNode jsonText = mapper.readTree(param.getTreatCondition());
        // mod #9973 Resolve null exception for key 20240117 ztc start
//        String sVal = jsonText.get("20").asText();	// 除水目標値
        String sVal = !jsonText.get("20").isNull() ? jsonText.get("20").asText() : null;	// 除水目標値
        // mod #9973 Resolve null exception for key 20240117 ztc end
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("除水目標値 = [" + sVal + "]");
        eventLogMessage.setFacilityCd(param.getFacilityCd());
        //FNSI-修正 ログ対応 xiebzh add start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        //FNSI-修正 ログ対応 xiebzh add end
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        iRet = comsvOrdMainDao.updateRstWeight(param.getOrdNo(), sVal);
        // add #IES_6789 dou start
        // 装置設定を更新する
        this.updateMachineSet(param, jsonText);
        // add #IES_6789 dou end
      }
    } catch (Exception e) {
      // ロールバック
      throw new RuntimeException(e);
    }
    return iRet;
  }
  // add #IES_6789 dou start
  /**
   * 装置設定を更新する
   *
   * @param param
   * @param jsonText
   */
  private void updateMachineSet(ComsvOrdTreatCondition param, JsonNode jsonText) {
    ComsvOrdMain comsvOrdMain = comsvOrdMainDao.selectByNo(param.getOrdNo());
    String rstCondInfo = comsvOrdMain.getRstCondInfo();
    if (!StringUtils.isEmpty(rstCondInfo)) {
      JSONObject obj = new JSONObject(rstCondInfo);
      // 29:ＩＰ使用選択 // 29: ＩＰ使用選択
      this.setNewValue(obj, "29", "29", jsonText);
      // 30:ＩＰスタート // 31: ＩＰスタート
      this.setNewValue(obj, "30", "31", jsonText);
      // 31:ＩＰワンショット量 // 33: ＩＰワンショット量
      this.setNewValue(obj, "31", "33", jsonText);
      // 32:IP速度 // 30: ＩＰ速度設定
      this.setNewValue(obj, "32", "30", jsonText);
      // 34:自動ワンショット // 32: ＩＰ自動ワンショット
      this.setNewValue(obj, "34", "32", jsonText);
      // 35:IP電源自動切り // 36: ＩＰ電源自動切りＳＷ
      this.setNewValue(obj, "35", "36", jsonText);
      // 36:IP電源自動切り時間 // 37: ＩＰ電源自動切り時間
      this.setNewValue(obj, "36", "37", jsonText);
      // 37:IP電源OKモニタ切り // 34: ＩＰ電源報知切りＳＷ
      this.setNewValue(obj, "37", "34", jsonText);
      // 38:IP電源OKモニタ切り時間 // 35: ＩＰ電源報知切り時間
      this.setNewValue(obj, "38", "35", jsonText);
      comsvOrdMainDao.updateRstCondInfo(param.getOrdNo(), obj.toString());
    }
  }

  /**
   * 値設定
   *
   * @param obj
   * @param ordMainKey
   * @param ordTreatConditionKey
   * @param jsonText
   */
  private void setNewValue(JSONObject obj, String ordMainKey, String ordTreatConditionKey, JsonNode jsonText) {
    // mod #9973 Resolve null exception for key 20240117 ztc start
//    if (obj.has(ordMainKey) && jsonText.has(ordTreatConditionKey)) {
    if (obj.has(ordMainKey) && jsonText.has(ordTreatConditionKey) && jsonText.hasNonNull(ordTreatConditionKey)) {
    // mod #9973 Resolve null exception for key 20240117 ztc end
      JSONObject jsonObject = obj.getJSONObject(ordMainKey);
      obj.put(ordMainKey, jsonObject.put("value", jsonText.get(ordTreatConditionKey).asText()));
    }
  }
  // add #IES_6789 dou end
}
