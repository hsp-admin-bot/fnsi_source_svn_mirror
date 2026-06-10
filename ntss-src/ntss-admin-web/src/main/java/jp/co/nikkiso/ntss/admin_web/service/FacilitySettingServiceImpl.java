package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import org.springframework.dao.EmptyResultDataAccessException;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.dao.MstFacilityHashDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.entity.MstFacilityHash;

import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 施設設定用のService実装クラス.
 */
@Service
public class FacilitySettingServiceImpl implements FacilitySettingService {

  /**
   * 施設設定Daoインターフェース.
   */
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;

  /**
   * 施設マスタハッシュDaoインタフェース.
   */
  @Autowired
  private MstFacilityHashDao mstFacilityHashDao;

  @Autowired
  private MstUserAuthenticationDao mstUserAuthenticationDao;
  /**
   * 並び順管理マスタのDaoインタフェース.
   */
  @Autowired
  private MstSelectorDao mstSelectorDao;

  @Autowired
  private MstUserDao mstUserDao;

  /**
   * 設定値を取得
   */
  @Override
  public String getFacilitySettingValue(String facilityCd, String facilitySettingNo) throws NotExistException{
    try{
      final FacilitySettingInfo settingValue
      = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd,facilitySettingNo);

      if(settingValue == null){
        throw new EmptyResultDataAccessException(0);
      }
      return settingValue.getValue();

    }catch (EmptyResultDataAccessException e) {
      throw new NotExistException("指定されたキーの施設設定はシステムテーブルに登録されていません");
    }
  }

  // add FNSI-7217 バッチ操作インターフェイスを追加します 查 start
  @Override
  public Map<String, String> getFacilitySettingValueMap(String facilityCd, List<String> facilitySettingNos) throws NotExistException {
    try{
      List<FacilitySettingInfo> settingValue = mstFacilitySettingDao.getByCdAndSettingNos(facilityCd, facilitySettingNos);

      Map<String, String> resultMap = new HashMap<>();
      if (settingValue != null && settingValue.size() == facilitySettingNos.size()) {
        for (FacilitySettingInfo settingInfo : settingValue) {
          resultMap.put(settingInfo.getFacilitySettingNo(), settingInfo.getValue());
        }
      } else {
        throw new EmptyResultDataAccessException(facilitySettingNos.size());
      }

      return resultMap;
    }catch (EmptyResultDataAccessException e) {
      throw new NotExistException("指定されたキーの施設設定はシステムテーブルに登録されていません");
    }
  }
  // add FNSI-7217 バッチ操作インターフェイスを追加します 查 end

  /**
   * {@inheritDoc}
   */
  @Override
  public String getFacilityLoginMethodValue(String facilityCdHash) throws Exception {
    MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByHashValue(facilityCdHash);
    //del 7328 IDｍが医療情報DBにて管理されている 関俊楠 start
//    final FacilitySettingInfo settingValue
//    = mstFacilitySettingDao.getBySettingNoAndCd(mstFacilityHash.getFacilityCd(), FacilitySettingNo.LOGIN_METHOD_SETTING_NO);
    //del 7328 IDｍが医療情報DBにて管理されている 関俊楠 end
    //mod 7328 IDｍが医療情報DBにて管理されている 関俊楠 start
    if(mstFacilityHash == null || "".equals(mstFacilityHash.getValue())){
      throw new EmptyResultDataAccessException(0);
    }
    return mstFacilityHash.getValue();
    //mod 7328 IDｍが医療情報DBにて管理されている 関俊楠 end
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public String getUserIdByCard(String facilityHash, String userId, String cardIdm) throws Exception {
    MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByHashValue(facilityHash);
    String facilityCd = mstFacilityHash.getFacilityCd();
    MstUserAuthentication userAuthentication =  mstUserAuthenticationDao.selectByCardCd(userId, facilityCd);
    //mod 7328 IDｍが医療情報DBにて管理されている 関俊楠 start
    if(userAuthentication != null) {
      MstUserAuthentication user = mstUserAuthenticationDao.selectByCardIdm(cardIdm, userId);
    	if(user != null && !"".equals(user.getDispUserId())) {
    		return user.getDispUserId();
    	}
    }
    //mod 7328 IDｍが医療情報DBにて管理されている 関俊楠 end
    throw new java.util.NoSuchElementException();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstSelector> getSelectorDataList(String facilityCd, List<String> masterPhysicalNameList) {
    return mstSelectorDao.selectByNameList(facilityCd, masterPhysicalNameList);
  }
}
