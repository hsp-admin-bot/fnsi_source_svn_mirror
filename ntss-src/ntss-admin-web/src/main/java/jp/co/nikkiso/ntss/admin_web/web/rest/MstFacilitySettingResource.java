package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterDataResponse;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.service.master.facilitySetting.MstFacilitySettingService;

import lombok.extern.slf4j.Slf4j;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;



/**
 * 施設設定マスタ画面のResourceクラス.
 */
@RestController
@Slf4j
@RequestMapping(Uri.MASTER_MAINTENANCE)
public class MstFacilitySettingResource {

    /**
     * 施設設定一覧Service
     */
    @Autowired
    private MstFacilitySettingService mstFacilitySettingService;

    @Autowired
	  LogService logService;


    /**
    * 施設管理一覧データ取得.
    *
    * @param facilityCd 取得対象の施設コード
    * @return 利用者マスタデータのResponse
    *
    */
    @GetMapping("/mst_facility_setting/{facilityCd}")
    public ResponseEntity<?> getMasterData(@PathVariable String facilityCd) {

      // ログ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request to get master : mst_facility_setting & sys_facility_setting");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, SERVICE_NAME.FNSI, null);

      try {
        // レスポンス生成
        MasterDataResponse response = mstFacilitySettingService.getMasterData(facilityCd);
        return new ResponseEntity<>(response, HttpStatus.OK);
      } catch (Exception e) {

        // マスタ定義が取得できなかった場合
    	  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (facilityCd != null) {
          eventLogMessage.setFacilityCd(facilityCd);
        }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    	  logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
            HttpStatus.INTERNAL_SERVER_ERROR);
      }

    }

    /**
    * 施設マスタデータ取得.
    *
    * @return 施設マスタデータのResponse
    *
    */
    @GetMapping("/mst_facility_setting/mst_facility")
    public ResponseEntity<?> getFacilityData() {

      // ログ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage( "REST request to get master : mst_facility");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, SERVICE_NAME.FNSI, null);

      try {
        // レスポンス生成
        return new ResponseEntity<>(mstFacilitySettingService.selectMstFacility(), HttpStatus.OK);
      } catch (Exception e) {

        // マスタ定義が取得できなかった場合
    	  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    	  logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
            HttpStatus.INTERNAL_SERVER_ERROR);
      }
    }

    @PutMapping("/saveMstFacilitySetting")
    /**
     * 施設設定マスタ登録・更新
     */
    public ResponseEntity<Void> saveMstFacilitySetting(@RequestBody Map<String, List<String>> payload) {
      try {
        mstFacilitySettingService.saveMstFacilitySetting(payload);
        return new ResponseEntity<>(HttpStatus.OK);
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        EventLogMessage eventLogMessage = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }
    }

    @GetMapping("mst_facility_setting/get_value_signin/{facilityCd}")
    public ResponseEntity<?> getValueSignInByFacilityCd(@PathVariable String facilityCd) {
      try {
        return new ResponseEntity<>(mstFacilitySettingService.getValueSignInByFacilityCd(facilityCd), HttpStatus.OK);
      } catch (Exception e) {

        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("Exception message : " +  e.getMessage());
        logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
            HttpStatus.INTERNAL_SERVER_ERROR);
      }
    }
}
