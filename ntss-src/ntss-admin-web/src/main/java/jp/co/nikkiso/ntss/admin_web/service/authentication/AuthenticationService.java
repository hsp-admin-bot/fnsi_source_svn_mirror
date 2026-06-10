package jp.co.nikkiso.ntss.admin_web.service.authentication;

import jp.co.nikkiso.ntss.admin_web.request.userAccount.AuthenticationUser;
import jp.co.nikkiso.ntss.admin_web.response.authentication.AuthenticationResponse;

public interface AuthenticationService {

  AuthenticationResponse checkLogin(AuthenticationUser authenticationUser) throws Exception;

  String getFacilityNameByHash(String facilityHash) throws Exception;
}
