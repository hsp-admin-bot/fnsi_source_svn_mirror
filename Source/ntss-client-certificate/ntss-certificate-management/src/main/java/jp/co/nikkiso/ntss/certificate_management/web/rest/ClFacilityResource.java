package jp.co.nikkiso.ntss.certificate_management.web.rest;

import java.util.Date;
import java.util.List;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.certificate_management.response.clFacility.ResponseClFacilitySetting;
import jp.co.nikkiso.ntss.core.dto.ClFacility.ClFacilityInfo;
import jp.co.nikkiso.ntss.core.entity.ClFacility;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.certificate_management.service.ClFacilityService;
import jp.co.nikkiso.ntss.certificate_management.service.log.LogService;
import jp.co.nikkiso.ntss.certificate_management.constant.ClientCertificateConstant.ScreenName;
import jp.co.nikkiso.ntss.certificate_management.constant.ClientCertificateConstant.Uri;
import java.sql.Timestamp;

@RestController
@RequestMapping(Uri.CLFACILITY)
public class ClFacilityResource {

    // クライアント施設サービス
    @Autowired
    ClFacilityService clFacilityService;

    // ロギングサービス
    @Autowired
    LogService logService;

    /**
     * すべての施設を取得
     *
     * @return 施設情報一覧
     */
    @GetMapping("/getAllFacilities")
    //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
    public ResponseEntity<List<ClFacilityInfo>> getAllFacilities(String OrderKey) {
    //public ResponseEntity<List<ClFacilityInfo>> getAllFacilities() {
    // mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
        try {
            //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
            //List<ClFacilityInfo> list = clFacilityService.selectAllFacility();
            List<ClFacilityInfo> list = clFacilityService.selectAllFacility(OrderKey);
            //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
            return new ResponseEntity<List<ClFacilityInfo>>(list, HttpStatus.OK);
        } catch (Exception e) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            String errMsg = e.getMessage();
            if (errMsg == null) {
                errMsg = e.toString() + " " + e.getStackTrace()[0];
            }
            eventLogMessage.setLogMessage("jp.co.nikkiso.ntss.certificate_management.web.rest.ClFacilityResource.java method:getAllFacilities エラー: " + errMsg);
            logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.MANAGEMENT_FACILITY_LIST, null);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * 更新施設
     *
     * @param clFacility クライアント施設
     * @return ストリング
     */
    @PostMapping("/updateFacility")
    public ResponseEntity<String> updateFacilities(@RequestBody ClFacility clFacility) {
        try {
            Date now = new Date();
            Timestamp timestamp = new Timestamp(now.getTime());
            clFacilityService.updateFacility(clFacility.getFacilityCd(), clFacility.getFacilityName(), clFacility.getFacilityPassword(), timestamp);
            return new ResponseEntity<String>("success", HttpStatus.OK);
        } catch (Exception e) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            String errMsg = e.getMessage();
            if (errMsg == null) {
                errMsg = e.toString() + " " + e.getStackTrace()[0];
            }
            eventLogMessage.setLogMessage("jp.co.nikkiso.ntss.certificate_management.web.rest.ClFacilityResource.java method:updateFacilities エラー: " + errMsg);
            logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.MANAGEMENT_EDIT_SCREEN, null);
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    /**
     * 挿入機能
     *
     * @param clFacility クライアント施設
     * @return ストリング
     */
    @PostMapping("/insertFacility")
    public ResponseEntity<String> insertFacility(@RequestBody ClFacility clFacility) {
        try {
            ClFacility facility = clFacilityService.selectByFacilityCd(clFacility.getFacilityCd());
            if (facility == null || facility.getId() == null) {
              Date now = new Date();
              Timestamp timestamp = new Timestamp(now.getTime());
              clFacilityService.insertFacility(clFacility.getFacilityCd(), clFacility.getFacilityName(), clFacility.getFacilityPassword(), 0,
                timestamp);
            } else {
              Date now = new Date();
              Timestamp timestamp = new Timestamp(now.getTime());
              clFacilityService.updateFacility(clFacility.getFacilityCd(), clFacility.getFacilityName(), clFacility.getFacilityPassword(), timestamp);
            }

            return new ResponseEntity<String>("success", HttpStatus.OK);
        } catch (Exception e) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            String errMsg = e.getMessage();
            if (errMsg == null) {
                errMsg = e.toString() + " " + e.getStackTrace()[0];
            }
            eventLogMessage.setLogMessage("jp.co.nikkiso.ntss.certificate_management.web.rest.ClFacilityResource.java method:insertFacility エラー: " + errMsg);
            logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.MANAGEMENT_EDIT_SCREEN, null);
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    /**
     * コードで施設を取得
     *
     * @param clFacility クライアント施設
     * @return クライアント施設
     */
    @GetMapping("/getFacilitiesByCd")
    public ResponseEntity<ClFacility> getFacilitiesByCd(ClFacility clFacility) {
        try {
            ClFacility facility = clFacilityService.selectByFacilityCd(clFacility.getFacilityCd());
            return new ResponseEntity<ClFacility>(facility, HttpStatus.OK);
        } catch (Exception e) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            String errMsg = e.getMessage();
            if (errMsg == null) {
                errMsg = e.toString() + " " + e.getStackTrace()[0];
            }
            eventLogMessage.setLogMessage("jp.co.nikkiso.ntss.certificate_management.web.rest.ClFacilityResource.java method:getFacilitiesByCd エラー: " + errMsg);
            logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.MANAGEMENT_EDIT_SCREEN, null);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * サインインの更新に失敗しました
     *
     * @param clFacility クライアント施設
     * @return ストリング
     */
    @PostMapping("/updateAttempFail")
    public ResponseEntity<String> updateAttempFail(@RequestBody ClFacility clFacility) {
        try {
            clFacilityService.updateAttemptFail(clFacility.getFacilityCd(), clFacility.getFacilityName(), clFacility.getAttemptFail());
            return new ResponseEntity<String>("success", HttpStatus.OK);
        } catch (Exception e) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            String errMsg = e.getMessage();
            if (errMsg == null) {
                errMsg = e.toString() + " " + e.getStackTrace()[0];
            }
            eventLogMessage.setLogMessage("jp.co.nikkiso.ntss.certificate_management.web.rest.ClFacilityResource.java method:updateAttempFail エラー: " + errMsg);
            logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.MANAGEMENT_FACILITY_LIST, null);
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

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
            eventLogMessage.setLogMessage("jp.co.nikkiso.ntss.certificate_management.web.rest.ClFacilityResource.java method:getFacilitySetting エラー: " + errMsg);
            logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.MANAGEMENT_FACILITY_LIST, null);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

}
