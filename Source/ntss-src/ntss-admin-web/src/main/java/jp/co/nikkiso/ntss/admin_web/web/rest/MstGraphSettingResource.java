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
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.master.graphSetting.MstGraphSettingService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.core.JacksonException;
import jp.co.nikkiso.ntss.core.entity.MstGraphSetting;

/**
 * P-Ca9分割グラフ設定マスタ画面のResourceクラス.
 */
@RestController
@RequestMapping(Uri.MASTER_MAINTENANCE)
public class MstGraphSettingResource {

  /**
   * P-Ca9分割グラフ設定一覧Service
   */
  @Autowired
  private MstGraphSettingService mstGraphSettingService;

  @Autowired
  LogService logService;

  /**
  * P-Ca9分割グラフ管理一覧データ取得.
  *
  * @param facilityCd 取得対象の施設コード
  * @return 利用者マスタデータのResponse
  *
  */
  @GetMapping("/mst_graph_setting/{facilityCd}")
  public ResponseEntity<?> getMasterData(@PathVariable String facilityCd,
                                         // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie start
                                         @AuthenticationPrincipal NtssUser ntssUser
                                         // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie end
) {
      // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie start
          if(!ntssUser.isNkkAdminUser()) {
              if (facilityCd != null && !facilityCd.isEmpty() &&
                  !facilityCd.equals(ntssUser.getFacilityCd())) {
                  String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
                  InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
                  return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
              }
          }
      // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie end


    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : mst_graph_setting & sys_graph_setting");
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, SERVICE_NAME.FNSI, null);

    try {
      // レスポンス生成
      MasterDataResponse response = mstGraphSettingService.getMasterData(facilityCd);
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {

      // マスタ定義が取得できなかった場合
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, SERVICE_NAME.FNSI, null);
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
  @GetMapping("/mst_graph_setting/mst_facility")
  public ResponseEntity<?> getFacilityData() {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage( "REST request to get master : mst_facility");
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, SERVICE_NAME.FNSI, null);

    try {
      // レスポンス生成
      return new ResponseEntity<>(mstGraphSettingService.selectMstFacility(), HttpStatus.OK);
    } catch (Exception e) {

      // マスタ定義が取得できなかった場合
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  @PutMapping("/saveMstGraphSetting")
  /**
   * P-Ca9分割グラフマスタ登録・更新
   */
  public ResponseEntity<Void> saveMstGraphSetting(@RequestBody Map<String, List<String>> payload,
                                                  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                  @AuthenticationPrincipal NtssUser ntssUser
                                                  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    try {
      if(!ntssUser.isNkkAdminUser()) {
        if (payload.get("insertRecord") != null && !payload.get("insertRecord").isEmpty()) {
          ObjectMapper mapper = new ObjectMapper();
          MstGraphSetting mstGraphSetting = mapper.readValue(payload.get("insertRecord").get(payload.get("insertRecord").size() - 1),
            MstGraphSetting.class);
          if (mstGraphSetting != null && mstGraphSetting.getFacilityCd() != null &&
            !mstGraphSetting.getFacilityCd().equals(ntssUser.getFacilityCd())) {
            String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + mstGraphSetting.getFacilityCd() + " " + "getGraphSettingNo=" + mstGraphSetting.getGraphSettingNo() + " ";
            InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("セキュリティチェックの例外!");
            logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, SERVICE_NAME.FNSI, null);
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
          }
        }
      }
    } catch (JacksonException e) {
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 start
      if (!ntssUser.isNkkAdminUser()) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " JsonProcessingException during security check ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260420 end
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
    try {
      mstGraphSettingService.saveMstGraphSetting(payload);
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

}
