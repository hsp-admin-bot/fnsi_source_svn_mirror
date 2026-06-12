package jp.co.nikkiso.ntss.admin_web.service.authentication;

import jp.co.nikkiso.ntss.admin_web.request.userAccount.AuthenticationUser;
import jp.co.nikkiso.ntss.admin_web.response.authentication.AuthenticationResponse;

import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityHashDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstFacilityHash;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
@Slf4j
public class AuthenticationServiceImpl implements  AuthenticationService{

  @Autowired
  private MstFacilityHashDao mstFacilityHashDao;

  @Autowired
  private PasswordEncoder passwordEncoder;

  @Autowired
  private MstUserAuthenticationDao mstUserAuthenticationDao;

  @Autowired
  private MstUserDao mstUserDao;

  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;

  @Autowired
  private MstFacilityDao mstFacilityDao;


  @Override
  public AuthenticationResponse checkLogin(AuthenticationUser authenticationUser) throws Exception {

    AuthenticationResponse authenticationResponse = new AuthenticationResponse();
    String userId = selectUserId(authenticationUser);
    if(!StringUtils.hasText(userId)){
      return getErrorAuthenticationResponse(authenticationResponse);
    }
    MstUserAuthentication mstUserAuthentication = mstUserAuthenticationDao.selectById(Long.valueOf(userId));

    if(!passwordEncoder.matches(authenticationUser.getPassword(), mstUserAuthentication.getUserPassword())){
      return getErrorAuthenticationResponse(authenticationResponse);
    }

    //判断是否启用认证
    FacilitySettingInfo facilitySetting = mstFacilitySettingDao.getValueSignInByFacilityCd(mstUserAuthentication.getFacilityCd());
    MstUser mstUser = getSecretKey(Long.valueOf(userId));

    switch (facilitySetting.getValue()){
      case "0":
        authenticationResponse.setSucceed(true);
        break;
      case "1":
        authenticationResponse.setSucceed(true);
        if(mstUser != null && mstUser.getIsSetQrCode() == 1){
          authenticationResponse.setSecretKey(mstUser.getSecretKey());
        }
        break;
      case "2":
        if(mstUser != null && mstUser.getIsSetQrCode() == 1){
          authenticationResponse.setSucceed(true);
          authenticationResponse.setSecretKey(mstUser.getSecretKey());
        }else{
          authenticationResponse.setSucceed(false);
          authenticationResponse.setErrMsg("2要素認証が未設定です。設定を行ってください。");
        }
        break;
    }
    String facilityNameByHash = getFacilityNameByHash(authenticationUser.getFacilityCd());
    authenticationResponse.setFacilityName(facilityNameByHash);
    return authenticationResponse;
  }

  private AuthenticationResponse getErrorAuthenticationResponse(AuthenticationResponse authenticationResponse) {
    authenticationResponse.setSucceed(false);
    authenticationResponse.setErrMsg("認証に失敗しました。認証情報を確認して下さい。");
    return authenticationResponse;
  }


  private MstUser getSecretKey(Long userId) throws Exception {
    return mstUserDao.selectById(userId);
  }

  private String selectUserId(AuthenticationUser authenticationUser) throws Exception {
    String userName = authenticationUser.getUserId();
    String facilityCd = authenticationUser.getFacilityCd();
    MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByHashValue(facilityCd);
    if(mstFacilityHash == null){
      return null;
    }

    return mstUserAuthenticationDao.selectUserId(userName, mstFacilityHash.getFacilityCd());
  }
  @Override
  public String getFacilityNameByHash(String facilityHash) {

    MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByHashValue(facilityHash);
    if (mstFacilityHash == null) {
      return "";
    }
    MstFacility mstFacility = mstFacilityDao.selectByCd(mstFacilityHash.getFacilityCd());
    if (mstFacility == null) {
      return "";
    }

    return mstFacility.getFacilityName();
  }
}
