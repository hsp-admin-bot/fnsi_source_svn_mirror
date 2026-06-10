package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord;

import jp.co.nikkiso.ntss.admin_web.service.PatInfoService;
import jp.co.nikkiso.ntss.admin_web.service.SelectHistoryUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.dao.MstRoundTypeDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.TreatmentRecordDao;
import jp.co.nikkiso.ntss.core.entity.MstRoundType;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordRoundsInfo;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import lombok.extern.slf4j.Slf4j;

import java.util.ArrayList;
import java.util.Map;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 治療記録画面（装置設定機能）のService実装クラス.
 */
@Service
@Slf4j
public class TreatmentRecordRoundServiceImpl implements TreatmentRecordRoundService {

  /**
   * 治療情報のDaoインタフェース.
   */
  @Autowired
  private TreatmentRecordDao treatmentRecordDao;
  // add FNSI-改修内容追加OrdMain履歴 付 start
  @Autowired
  private SelectHistoryUtils selectHistoryUtils;
  // add FNSI-改修内容追加OrdMain履歴 付 end
  /**
  * ロギングのServiceインタフェース.
  */
  @Autowired
  private LogService logService;

  @Autowired
  private OrdMainDao ordMainDao;

  @Autowired
  private MstRoundTypeDao mstRoundTypeDao;

  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;

  @Autowired
  PatInfoService patInfoService;

  /**
   * {@inheritDoc}
   */
  @Override
  public TreatmentRecordRoundsInfo getTreatmentRecordRoundsInfoByOrdNo(Long ordNo) throws NotExistException {
    try {
      return treatmentRecordDao.selectTreatmentRecordRoundsInfoByOrdNo(ordNo);
    } catch (EmptyResultDataAccessException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no TreatmentRecordRoundsInfo.");
      eventLogMessage.setSqlIdentification("(ordNo = "+ ordNo +")");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, "TreatmentRecordDao/selectTreatmentRecordRoundsInfoByOrdNo");
      throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
    }
  }

  /**
   * {@inheritDoc}
   */
  @Transactional
  @Override
  public void updateTreatmentRecordRoundsInfo(Long ordNo, TreatmentRecordRoundsInfo treatmentRecordRoundsInfo)
      throws NotExistException {
    treatmentRecordRoundsInfo.setOrdNo(ordNo);
    // add FNSI-改修内容追加OrdMain履歴 付 start
    selectHistoryUtils.insertMangoDbHistory(1, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
    // mangoDb-updateTreatmentRecordForRoundsInfo-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(treatmentRecordRoundsInfo,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end

    // update前の回診記録を取得
    TreatmentRecordRoundsInfo oldRoundsInfo = treatmentRecordDao.selectTreatmentRecordRoundsInfoByOrdNo(ordNo);

    final int updatedRoundsInfoCount = treatmentRecordDao.updateTreatmentRecordForRoundsInfo(ordNo, treatmentRecordRoundsInfo);
    if (updatedRoundsInfoCount <= 0) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no TreatmentRecordRoundsInfo.");
      eventLogMessage.setSqlIdentification("(ordNo = "+ ordNo +", treatmentRecordRoundsInfo = "+ treatmentRecordRoundsInfo +")");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, "TreatmentRecordDao/updateTreatmentRecordForRoundsInfo");
      throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
    } else {
      // 更新後、通知を発火
      // 条件1:新規登録時(=update前の回診記録がnull) かつ 削除ではない(=update用の回診記録がnullではない)
      // add 9553 by kangjie 20231030 start
      // if (oldRoundsInfo.getRstRoundsInfo() == null && treatmentRecordRoundsInfo.getRstRoundsInfo() != null) {
      if ( treatmentRecordRoundsInfo.getRstRoundsInfo() != null) {
      // add 9553 by kangjie 20231030 end
        // 通知判断に必要な情報として該当通知マスタの通知設定を取得
        JSONObject roundsInfo = new JSONObject(treatmentRecordRoundsInfo.getRstRoundsInfo());
        // #10196 Add these checks, in case of the data without key which from FNW will course a NPE. Add by Zhou.tao
        if (roundsInfo.has("round_type_cd") && !roundsInfo.isNull("round_type_cd")) {

          MstRoundType roundType = mstRoundTypeDao.selectByRoundTypeCd(roundsInfo.getLong("round_type_cd"));

          // 条件2:通知マスタの通知設定が1(通知する)
          if (roundType.getIsNotification().equals("1")) {
            try {
              registerNotification(ordNo, roundType.getRoundTypeName());
            } catch (Exception e) {
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
              logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
            }
          }
        }
      }
    }
    //add FNSI-redmine6060 fang start
    //del FNSI-redmine6060 再修正 劉祥霖 start
    //webApiCallCommonUtil.doAutoCalculation(ordNo);
    //del FNSI-redmine6060 再修正 劉祥霖 end
    // add FNSI-redmine6060 fang end
  }

  /**
   * 治療中指示変更通知発火処理
   * @param ordNo オーダー番号
   * @param roundTypeName 回診記録カテゴリ名
   * @return アップデート件数
   * @throws Exception
   */
  private void registerNotification(Long ordNo, String roundTypeName) throws Exception {
    OrdMain ord = ordMainDao.selectByOrdNo(ordNo);

    Long patId = ord.getPatId();
    String facilityCd = ord.getFacilityCd();
    String bedName = ord.getIndBedName() != null ? ord.getIndBedName() : "未登録";

    Map<String, String> patInfo = patInfoService.selectById(patId , facilityCd);
    ObjectMapper mapper = new ObjectMapper();
    PatPersonalMain patPersonalMain = mapper.readValue(patInfo.get("pat_personal_main"), PatPersonalMain.class);
    JSONObject replaceData = new JSONObject();
    replaceData.put("PATID", patId.toString());
    replaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
    replaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());
    replaceData.put("BEDNAME", bedName);
    replaceData.put("FACILITYCD", facilityCd);
    replaceData.put("ORDNO", ordNo.toString());
    replaceData.put("CATEGORY", roundTypeName);
    webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.ADD_ROUNDS_INFO, facilityCd, replaceData);
  }
}
