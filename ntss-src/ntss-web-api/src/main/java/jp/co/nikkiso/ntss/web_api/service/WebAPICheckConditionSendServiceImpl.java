package jp.co.nikkiso.ntss.web_api.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.json.JSONObject;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.dao.WebAPICheckConditionSendDao;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;


/**
 * 条件送信画面系のService実装クラス.
 */
@Service
public class WebAPICheckConditionSendServiceImpl implements WebAPICheckConditionSendService {

  /**
   * 条件送信画面系Dao.
   */
  @Autowired
  private WebAPICheckConditionSendDao webAPICheckConditionSendDao;
  @Autowired
  private PatPersonalMainDao patPersonalMainDao ;
  @Autowired
  private OrdMainDao ordMainDao ;
  @Autowired
  private MstDialyzerDao mstDialyzerDao ;
  @Autowired
  private PatUniqueDao patUniqueDao ;
  @Autowired
  private LogService logService;
  
  /**
   * 装置オプション取得用
   * @param ordNo オーダー番号
   * @return 装置オプション
   * @throws Exception
   */
  public List<String> getMachineOptionsFromMstMachine(Long ordNo) {
    return webAPICheckConditionSendDao.selectMachineOptionsFromMstMachine(ordNo);
  }

  /**
   * オーダーメイン取得用
   * @param ordNo オーダー番号
   * @return オーダーメイン情報
   * @throws Exception
   */
  public OrdMain getDataFromOrdMain(Long ordNo) {
    return ordMainDao.selectByOrdNo(ordNo);
  }
  /**
   * 装置タイプ取得用
   * @param ordNo オーダー番号
   * @return 装置タイプ情報
   * @throws Exception
   */
  public List<Map<String,Object>> getMachineTypeFromMstMachine(Long ordNo){
    return webAPICheckConditionSendDao.selectMachineTypeFromMstMachine(ordNo);
  }
  /**
   * 装置マスタ取得用
   * @param ordNo オーダー番号
   * @return 装置マスタ情報
   * @throws Exception
   */
  public List<Map<String,Object>> getDataFromMstMachine(Long ordNo){
    return webAPICheckConditionSendDao.selectDataFromMstMachine(ordNo);
  }
  /**
   * 身体情報取得用
   * @param patId 患者ID
   * @return PatUniqueエンティティのリスト
   * @throws Exception
   */
  public List<PatUnique> getDataFromPatUnique(Long patId){
    List<Long> patIdList = new ArrayList<Long>() ;
    patIdList.add(patId) ;
    return patUniqueDao.selectByIdList(patIdList) ;
  }
  /**
   * 装置設定情報取得用
   * @param ordNo オーダー番号
   * @return 装置設定情報
   * @throws Exception
   */
  public List<Map<String,Object>> getMachineSetting(Long ordNo){
    List<Map<String,Object>> machineSettingList = webAPICheckConditionSendDao.selectMachineSetting(ordNo);
    // A42(補正値の合計)の合計値を設定
    for (Map<String,Object> machineSettingInfo: machineSettingList) {
      JSONObject devInfo = new JSONObject(machineSettingInfo.get("dev").toString());
      String rstOffWaterInfo = devInfo.get("A042").toString();
      if ("null".compareTo(rstOffWaterInfo) != 0) {
        JSONObject rst_off_water_info = new JSONObject(rstOffWaterInfo);
        Double weight_1 = rst_off_water_info.getDouble("weight_1");
        Double weight_2 = rst_off_water_info.getDouble("weight_2");
        Double weight_3 = rst_off_water_info.getDouble("weight_3");
        Double weight_4 = rst_off_water_info.getDouble("weight_4");
        Double weight_5 = rst_off_water_info.getDouble("weight_5");
        Double sumWeight = weight_1 + weight_2 + weight_3 + weight_4 + weight_5;
        devInfo.put("A042", sumWeight);
        machineSettingInfo.put("dev", devInfo);
      }
    }
    return machineSettingList;
  }
  /**
   * 装置モード取得用
   * @param ordNo オーダー番号
   * @return 装置モード
   * @throws Exception
   */
  public List<String> getDeviceModeFromMstTreatment(Long ordNo){
    return webAPICheckConditionSendDao.selectDeviceModeFromMstTreatment(ordNo);  
  }
  /**
   * ダイアライザ情報取得用
   * @param dialyzerCd ダイアライザコード
   * @return ダイアライザ情報
   * @throws Exception
   */
  public MstDialyzer getDialyzerInfoFromDialyzer(
              Integer dialyzerCd            
      )
  {
    return mstDialyzerDao.selectByDialyzerCd(SelectOptions.get(), dialyzerCd);
  }
  /**
   * 患者情報(患者名)取得用
   * @param patId 患者ID
   * @return 患者(患者名)情報
   * @throws Exception
   */
  public Map<String,Object> getPatNameFromPatPersonalMain(Long patId)
  {
    Map<String,Object> ret = new HashMap<String,Object>() ;
    
    PatPersonalMain patPersonalMainData = null ;
    
    //患者情報の取得
    try {
      patPersonalMainData = patPersonalMainDao.selectById(patId) ;
    }
    catch(Exception e)
    {
      //SQLのエラー発生
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
      eventLogMessage.setSqlIdentification( " patPersonalMainDao = " + patId);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, "MntDeviceEdgeStateDao/selectById");
      ret = null ;
      return ret ;
    }
      
    if(null == patPersonalMainData)
    {
      // 取得できなかった
      ret = null ;
    }
    else
    {
      // 患者名(姓)の格納
      ret.put("pat_last_name", patPersonalMainData.getPat_last_name());
      // 患者名(名)の格納
      ret.put("pat_first_name", patPersonalMainData.getPat_first_name()); 
    }
    return ret ;  
  }

  /**
   * 条件送信データ格納用
   * @param ordNo オーダー番号
   * @param sendCondData 条件送信データ(Json文字列)
   * @return 更新件数
   * @throws Exception
   */
  public int insertSendCondData(Long ordNo,String sendCondData) {
    return webAPICheckConditionSendDao.updateInsertSendCondData(ordNo, sendCondData) ;
  }
}
