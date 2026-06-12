package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.request.userAccount.AuthenticationUser;
import jp.co.nikkiso.ntss.admin_web.response.authentication.AuthenticationResponse;
import jp.co.nikkiso.ntss.admin_web.response.registerOpt.RegisterOptResponse;
import jp.co.nikkiso.ntss.admin_web.service.authentication.AuthenticationService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.master.user.MstUserService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(AdminWebConstant.Uri.AUTHENTICATION)
public class AuthenticationResource {

  @Autowired
  LogService logService;

  @Autowired
  private MstUserService mstUserService;

  @Autowired
  AuthenticationService authenticationService;
  @PostMapping("/check_login")
  public ResponseEntity<?> checkLogin(@RequestBody AuthenticationUser authenticationUser) {

    try {

      AuthenticationResponse authenticationResponse = authenticationService.checkLogin(authenticationUser);
      return new ResponseEntity<>(authenticationResponse, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, LoggingConstant.SERVICE_NAME.REMS, null);
      return null;
    }
  }
  @PutMapping("/check_otp/{otp}/{secretKey}")
  public ResponseEntity<?> checkOTP(@PathVariable String otp, @PathVariable String secretKey, @RequestParam("facilityHash") String facilityHash) {
    try {

      Boolean response = mstUserService.checkOtpOnRegister(secretKey, otp);
      RegisterOptResponse registerOptResponse = new RegisterOptResponse();
      registerOptResponse.setOptSuccess(response);
      if(response){
        String facilityNameByHash = authenticationService.getFacilityNameByHash(facilityHash);
        registerOptResponse.setFacilityName(facilityNameByHash);
      }
      return new ResponseEntity<>(registerOptResponse, HttpStatus.OK);

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, LoggingConstant.SERVICE_NAME.REMS, null);
      return null;
    }
  }


}
