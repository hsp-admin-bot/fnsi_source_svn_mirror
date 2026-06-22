package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstFacilityHash;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.entity.MntFacilityCancelManage;

import java.net.URISyntaxException;
import java.util.List;

import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import jp.co.nikkiso.ntss.core.dao.MstFacilityHashDao;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallFacilityCancelManage;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.FacilitySettingNo;
import jp.co.nikkiso.ntss.core.dao.MntFacilityCancelManageDao;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import org.springframework.util.StringUtils;

/**
 * 施設設定用のService実装クラス.
 */
@Service
public class MstFacilityServiceImpl implements MstFacilityService {

  /**
   * 施設設定Daoインターフェース.
   */
  @Autowired
  private MstFacilityHashDao mstFacilityHashDao;

  /**
   * 施設解約管理Daoインターフェース.
   */
  @Autowired
  private MntFacilityCancelManageDao mntFacilityCancelManageDao;

  /**
   * 施設解約API処理インタフェース
   */
  @Autowired
  private WebApiCallFacilityCancelManage webApiCallFacilityCancelManage;

  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  /**
   * 施設設定Daoインターフェース.
   */
  @Autowired
  private MstFacilityDao mstFacilityDao;

  /**
   * {@inheritDoc}
   */
  @Override
  public String getSystemUseSettingByHashValue(String hashValue) throws Exception {
    try {
      MstFacilityHash mstFacilityHash = mstFacilityHashDao.findByHashValue(hashValue);
      return mstFacilityHash.getSystemUseSetting();
    } catch (Exception e) {
      throw new Exception(e);
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public MstFacilityHash getMstFacilityHashByFacilityCd(String facilityCd) throws Exception {
    try {
      MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByFacilityCd(facilityCd);
      return mstFacilityHash;
    } catch (Exception e) {
      throw new Exception(e);
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstFacilityHash> getMstFacilityHash() throws Exception {
    try {
      List<MstFacilityHash> mstFacilityHashList = mstFacilityHashDao.selectAll();
      return mstFacilityHashList;
    } catch (Exception e) {
      throw new Exception(e);
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MntFacilityCancelManage> getMntFacilityCancelManage() throws Exception {
    try {
      List<MntFacilityCancelManage> mntFacilityCancelManageList = mntFacilityCancelManageDao.selectByProcClass();
      return mntFacilityCancelManageList;
    } catch (Exception e) {
      throw new Exception(e);
    }
  }

  /**
   * {@inheritDoc}
   * @return
   */
  @Override
  public void completeDeleteFacility(String facilityCd) throws Exception {
    try {
      // 解約済施設完全削除API呼出し
      webApiCallFacilityCancelManage.completeDeleteFacility(facilityCd);
    } catch (URISyntaxException | RuntimeException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      eventLogMessage.setLogMessage("解約済施設 完全削除 例外発生 facilityCd:" + facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.REMS, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end

    }
  }

  /**
   * {@inheritDoc}
   * @return
   */
  @Override
  public void deleteBackupFileFacility(String facilityCd) throws Exception {
    try {
      // バックアップデータ削除API呼出し
      webApiCallFacilityCancelManage.deleteBackupFileFacility(facilityCd);
    } catch (URISyntaxException | RuntimeException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      eventLogMessage.setLogMessage("バックアップファイル削除 例外発生 facilityCd:" + facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.REMS, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public int getSystemOtpFailureCntByHashValue(String hashValue) throws Exception {
    try {
      MstFacilityHash mstFacilityHash = mstFacilityHashDao.findByHashValue(hashValue);
      return mstFacilityHash.getOtpFailureCnt();
    } catch (Exception e) {
      throw new Exception(e);
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public String getUrlSignin(String hashValue) throws Exception {
    try {
      MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByHashValue(hashValue);
      JSONObject result = new JSONObject();
      result.put(FacilitySettingNo.URL_SIGNIN, mstFacilityHash.getUrlSignin());
      result.put(FacilitySettingNo.URL_SIGNIN_SECRETKEY, mstFacilityHash.getUrlSigninSecretkey());
      return result.toString();
    } catch (Exception e) {
      throw new Exception(e);
    }
  }
  
  /**
   * {@inheritDoc}
   */
  @Override
  public String getIsSigninDisp(String hashValue) throws Exception {
    try {
      MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByHashValue(hashValue);
      JSONObject result = new JSONObject();
      if(mstFacilityHash != null) {
        result.put(FacilitySettingNo.IS_SIGNIN_DISP, mstFacilityHash.getIsSigninDisp()); 
      }
      return result.toString();
    } catch (Exception e) {
      throw new Exception(e);
    }
  }


  // add FNSI-3922 投薬指示機能が施設拡張設定のON\OFF制御に反映していない liumx start
  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstFacility> getFacilityInfoByCd(String facilityCd) throws Exception {
    return mstFacilityDao.getFacilityInfoByCd(facilityCd);
  }
  // add FNSI-3922 投薬指示機能が施設拡張設定のON\OFF制御に反映していない liumx end
}
