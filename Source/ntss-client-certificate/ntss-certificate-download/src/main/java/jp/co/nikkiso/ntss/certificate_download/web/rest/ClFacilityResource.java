package jp.co.nikkiso.ntss.certificate_download.web.rest;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.certificate_download.constant.ClientCertificateConstant.ScreenName;
import jp.co.nikkiso.ntss.certificate_download.constant.ClientCertificateConstant.Uri;
import jp.co.nikkiso.ntss.certificate_download.response.clFacility.ResponseClFacilitySetting;
import jp.co.nikkiso.ntss.certificate_download.service.ClFacilityService;
import jp.co.nikkiso.ntss.certificate_download.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.entity.ClFacility;

import java.sql.Timestamp;
import java.util.Date;

@RestController
@RequestMapping(Uri.CLFACILITY)
public class ClFacilityResource {

    // クライアント施設サービス
    @Autowired
    ClFacilityService clFacilityService;

    // ロギングサービス
    @Autowired
    LogService logService;
  //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    @Autowired
    public PasswordEncoder passwordEncoder;
//add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
  /**
     * 施設設定の取得
     *
     * @return 施設設置
     */
    @GetMapping("/getFacilitySetting")
    public ResponseEntity<ResponseClFacilitySetting> getFacilitySetting() {
        try {
            ResponseClFacilitySetting result = clFacilityService.getFacilitySetting();
            return new ResponseEntity<ResponseClFacilitySetting>(result, HttpStatus.OK);
        } catch (Exception e) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            String errMsg = e.getMessage();
            if (errMsg == null) {
                errMsg = e.toString() + " " + e.getStackTrace()[0];
            }
            eventLogMessage.setLogMessage("jp.co.nikkiso.ntss.certificate_download.web.rest.ClFacilityResource.java エラー: " + errMsg);
            logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.MANAGEMENT_FACILITY_LIST, null);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    /**
     * 仮登録フラグの取得
     *
     * @return 仮登録フラグ
     */
    @GetMapping("/getProvisional")
    public ResponseEntity<ClFacility> getProvisional(String facilityCd) {
      try {
        ClFacility result = clFacilityService.getProvisional(facilityCd);
        return new ResponseEntity<>(result, HttpStatus.OK);
      } catch (Exception e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        String errMsg = e.getMessage();
        if (errMsg == null) {
          errMsg = e.toString() + " " + e.getStackTrace()[0];
        }
        eventLogMessage.setLogMessage("jp.co.nikkiso.ntss.certificate_download.web.rest.ClFacilityResource.java エラー: " + errMsg);
        logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.DOWNLOAD_LOGIN, null);
        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      }
    }
    /**
     * 仮登録フラグの更新
     *
     *
     */

    @PutMapping("/updateProvisional")
    public ResponseEntity<String> updateProvisional(@RequestBody ClFacility clFacility) {
      try {
        Date now = new Date();
        Timestamp timestamp = new Timestamp(now.getTime());
        clFacility.setIsProvisional(CoreConstant.ProvisionalStatus.NOT_PROVISIONAL);
        String hashFacilityPassword = passwordEncoder.encode(clFacility.getFacilityPassword());
        clFacilityService.updateProvisional(clFacility.getFacilityCd(),clFacility.getIsProvisional(), hashFacilityPassword, timestamp);
        return new ResponseEntity<String>("success", HttpStatus.OK);
      } catch (Exception e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        String errMsg = e.getMessage();
        if (errMsg == null) {
          errMsg = e.toString() + " " + e.getStackTrace()[0];
        }
        eventLogMessage.setLogMessage("jp.co.nikkiso.ntss.certificate_download.web.rest.ClFacilityResource.java エラー: " + errMsg);
        logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.DOWNLOAD_RESET, null);
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }
    }
    /**
     * 画面から入力された現在のパスワードとDB上のパスワードが一致するかチェック.
     *
     * @param facilityCd ユーザID
     * @param CurrentPassword 入力された現在のパスワード
     * @return 現在のパスワードと一致する場合trueを返す.
     */
    @GetMapping("/checkMatchCurrentPassword")
    public ResponseEntity<?> checkMatchCurrentPassword(
      @RequestParam(value = "facilityCd") String facilityCd,
      @RequestParam(value = "CurrentPassword") String CurrentPassword) {
      try {
        // ログ出力
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("REST request to Match current password with mst_user_authentication password : " + facilityCd);
        logService.log(LogLevel.DEBUG, eventLogMessage, "", ScreenName.DOWNLOAD_RESET, null);
        // 現在のパスワードとDB上のパスワードの突合せ
        return new ResponseEntity<>(clFacilityService.isMatchCurrentPassword(CurrentPassword, facilityCd), HttpStatus.OK);
      } catch (Exception e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        String errMsg = e.getMessage();
        if (errMsg == null) {
          errMsg = e.toString() + " " + e.getStackTrace()[0];
        }
        eventLogMessage.setLogMessage("jp.co.nikkiso.ntss.certificate_download.web.rest.ClFacilityResource.java method:checkMatchCurrentPassword エラー: " + errMsg);
        logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.DOWNLOAD_RESET, null);
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }
    }
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
}
