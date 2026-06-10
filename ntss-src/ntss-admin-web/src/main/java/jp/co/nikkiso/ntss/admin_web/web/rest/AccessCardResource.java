package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.response.userAccount.UserAccountResponse;
import jp.co.nikkiso.ntss.admin_web.service.PatPersonalMainService;
import jp.co.nikkiso.ntss.admin_web.service.accessCard.AccessCardService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.userAccount.UserAccountService;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.MntCardappPort;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.UserAccountInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.ObjectUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;

@Slf4j
@RestController
@RequestMapping(Uri.CARD_STATE)
public class AccessCardResource {

    private static final String STAFF = "1";
    private static final String PATIENT = "2";

    @Autowired
    PatPersonalMainService patPersonalMainService;

    @Autowired
    AccessCardService accessCardService;

    @Autowired
    WebSocketNotifyService sendWsMsg;

    @Autowired
    private UserAccountService userAccountService;

    @Autowired
    private LogService logService;

    @GetMapping("/staff_info/{facilityCd}/{staffId}")
    public ResponseEntity<?> createStaff(HttpServletRequest request, @PathVariable String facilityCd, @PathVariable Long staffId){

        // 毛 アプリケーションログの適正化 Add Start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setFacilityCd(facilityCd);
        eventLogMessage.setLogMessage(this.getClass().getName() + "createStaff実施開始：" + "/staff_info/" + facilityCd + "/" + staffId);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        // 毛 アプリケーションログの適正化 Add End

        try {
            HashMap<String, HashMap<String, String>> data = new HashMap<>();
            HashMap<String, String> staffInfo = new HashMap<>();
            staffInfo.put("type", STAFF);
            staffInfo.put("cardCd", staffId.toString());
            data.put("cardWriteValue", staffInfo);

            // Add By HandsomeLin Begin
            //   Write staff card need to get staff name.
            //   Why use HashMap ?! Sorry, I had to do the same!
            UserAccountResponse response = userAccountService.createUserAccountResponse(staffId);
            if (response != null) {
                UserAccountInfo account = response.userAccountInfo;
                if (account != null) {
                    staffInfo.put("lastname", Base64.getEncoder().encodeToString(
                      ObjectUtils.defaultIfNull(account.getUserLastName(), StringUtils.EMPTY).getBytes())
                    );
                    staffInfo.put("firstname", Base64.getEncoder().encodeToString(
                      ObjectUtils.defaultIfNull(account.getUserFirstName(), StringUtils.EMPTY).getBytes())
                    );
                }
            }
            // Add By HandsomeLin End

            // 毛 アプリケーションログの適正化 Add Start
            eventLogMessage.setLogMessage(this.getClass().getName() + "createStaff実施終了：" + "/staff_info/" + facilityCd + "/" + staffId);
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            // 毛 アプリケーションログの適正化 Add End

            return new ResponseEntity<>(data, HttpStatus.OK);
        } catch (Exception e) {
            // 毛 アプリケーションログの適正化 Mod
            eventLogMessage.setLogMessage(this.getClass().getName() + "createStaff実施異常終了：" + e.getMessage());
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/pat_info/{facilityCd}/{patId}")
    public ResponseEntity<?> createPat(HttpServletRequest request, @PathVariable String facilityCd, @PathVariable Long patId){

        // 毛 アプリケーションログの適正化 Add Start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setFacilityCd(facilityCd);
        eventLogMessage.setLogMessage(this.getClass().getName() + "createPat実施開始：" + "/pat_info/" + facilityCd + "/" + patId);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        // 毛 アプリケーションログの適正化 Add End

        try {
            HashMap<String, HashMap<String, String>> data = new HashMap<>();
            HashMap<String, String> patInfo = new HashMap<>();
            patInfo.put("type", PATIENT);
            // del 2020-11/10 FNSI-改修内容:カード作成場合、カードIDの変更（pat_id⇒hosp_pat_id） 孫 start
            //patInfo.put("cardCd", patId.toString());
            // del 2020-11/10 FNSI-改修内容:カード作成場合、カードIDの変更（pat_id⇒hosp_pat_id） 孫 end
            // 毛 アプリケーションログの適正化 Add Start
            eventLogMessage.setLogMessage(this.getClass().getName() + "patPersonalMainService.selectByIdForWriteCard呼び出す開始：" + patId);
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            // 毛 アプリケーションログの適正化 Add End
            PatPersonalMain patPersonalMain = patPersonalMainService.selectByIdForWriteCard(patId);
            // 毛 アプリケーションログの適正化 Add Start
            eventLogMessage.setLogMessage(this.getClass().getName() + "patPersonalMainService.selectByIdForWriteCard呼び出す終了：" + patId);
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            // 毛 アプリケーションログの適正化 Add End
            // add 2020-11/10 FNSI-改修内容:カード作成場合、カードIDの変更（pat_id⇒hosp_pat_id） 孫 start
            String hospPatId = patPersonalMain.getHosp_pat_id();
            patInfo.put("cardCd", hospPatId);
            // add 2020-11/10 FNSI-改修内容:カード作成場合、カードIDの変更（pat_id⇒hosp_pat_id） 孫 end
            String patBirthDay = patPersonalMain.getPat_birthday();
            String patFirstName = patPersonalMain.getPat_first_name();
            if (patFirstName == null) {
                patFirstName = "";
            };
            String patLastName = patPersonalMain.getPat_last_name();
            if (patLastName == null) {
                patLastName = "";
            }

            patInfo.put("birthdate", patBirthDay);
            patInfo.put("firstname", patFirstName);
            patInfo.put("lastname", patLastName);
            String info = accessCardService.selectPatInfoWriteCard(patId);
            patInfo.put("info", info);
            data.put("cardWriteValue", patInfo);

            // 毛 アプリケーションログの適正化 Add Start
            eventLogMessage.setLogMessage(this.getClass().getName() + "createPat実施終了：" + "/pat_info/" + facilityCd + "/" + patId);
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            // 毛 アプリケーションログの適正化 Add End

            return new ResponseEntity<>(data, HttpStatus.OK);
        } catch (Exception e) {
            // 毛 アプリケーションログの適正化 Mod
            eventLogMessage.setLogMessage(this.getClass().getName() + "createPat実施異常終了：" + e.getMessage());
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("setCard/{userId}")
    public ResponseEntity<?> setCardNo(
        @PathVariable(name = "userId", required = true) Long userId,
        @RequestBody String cardIdm) {

      // wangzuo アプリケーションログの適正化 Add Start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(this.getClass().getName() + "setCardNo実施開始：" + "/setCard/" + userId);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // wangzuo アプリケーションログの適正化 Add End

        try {
            boolean res = accessCardService.setAccessCardIdm(cardIdm, userId);

          // wangzuo アプリケーションログの適正化 Add Start
          eventLogMessage.setLogMessage(this.getClass().getName() + "setCardNo実施終了：" + "/setCard/" + userId);
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          // wangzuo アプリケーションログの適正化 Add End

            return new ResponseEntity<>(res, HttpStatus.OK);
        } catch (Exception e) {
            // wangzuo アプリケーションログの適正化 Mod
            eventLogMessage.setLogMessage(this.getClass().getName() + "setCardNo実施異常終了：" + e.getMessage());
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    // add 2020-08-13 FNSI-仕様追加 患者基本情報(pat_main)にアクセスカード番号(card_idm)の追加処理 夏 start
    @PostMapping("setPatCard/{patId}")
    public ResponseEntity<?> setPatCardNo(
        @PathVariable(name = "patId", required = true) Long patId,
        @RequestBody String cardIdm) {

      // wangzuo アプリケーションログの適正化 Add Start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(this.getClass().getName() + "setPatCardNo実施開始：" + "/setPatCard/" + patId);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // wangzuo アプリケーションログの適正化 Add End

        try {
            boolean res = accessCardService.setPatCardIdm(cardIdm, patId);

          // wangzuo アプリケーションログの適正化 Add Start
          eventLogMessage.setLogMessage(this.getClass().getName() + "setPatCardNo実施終了：" + "/setPatCard/" + patId);
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          // wangzuo アプリケーションログの適正化 Add End

            return new ResponseEntity<>(res, HttpStatus.OK);
        } catch (Exception e) {
            // wangzuo アプリケーションログの適正化 Mod
            eventLogMessage.setLogMessage(this.getClass().getName() + "setPatCardNo実施異常終了：" + e.getMessage());
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    // add 2020-08-13 FNSI-仕様追加 患者基本情報(pat_main)にアクセスカード番号(card_idm)の追加処理 夏 end

    //  add 2020-09-25 FNSI-4200ポートを使用している 孫 start
    @PutMapping("/update_card_app_port/")
    public ResponseEntity<?> updateCardAppPort(
      @RequestBody MntCardappPort cardAppPortInfo) {

      // wangzuo アプリケーションログの適正化 Add Start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(this.getClass().getName() + "updateCardAppPort実施開始：" + "/update_card_app_port/");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // wangzuo アプリケーションログの適正化 Add End

      try {
        boolean res = accessCardService.updateCarAppPortInfo(cardAppPortInfo);

        // wangzuo アプリケーションログの適正化 Add Start
        eventLogMessage.setLogMessage(this.getClass().getName() + "updateCardAppPort実施終了：" + "/update_card_app_port/");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        // wangzuo アプリケーションログの適正化 Add End

        return new ResponseEntity<>(res, HttpStatus.OK);
      } catch (Exception e) {
        // wangzuo アプリケーションログの適正化 Mod
        eventLogMessage.setLogMessage(this.getClass().getName() + "updateCardAppPort実施異常終了：" + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      }
    }

    @GetMapping("/get_card_app_ports/{facilityCd}")
    public ResponseEntity<?> GetCardAppPorts(
      @PathVariable(name = "facilityCd", required = true) String facilityCd) {

      // wangzuo アプリケーションログの適正化 Add Start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setLogMessage(this.getClass().getName() + "GetCardAppPorts実施開始：" + "/get_card_app_ports/" + facilityCd);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // wangzuo アプリケーションログの適正化 Add End

      try {
        List<Integer> result = accessCardService.selectByFacility(facilityCd);

        String portList = "";
        if (result != null && !result.isEmpty() && result.size() > 0) {
          for(Integer port : result) {
            if (portList.isEmpty()) {
              portList = port.toString();
            } else {
              portList = portList + "," + port.toString();
            }
          }
        }

        // wangzuo アプリケーションログの適正化 Add Start
        eventLogMessage.setFacilityCd(facilityCd);
        eventLogMessage.setLogMessage(this.getClass().getName() + "GetCardAppPorts実施終了：" + "/get_card_app_ports/" + facilityCd);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        // wangzuo アプリケーションログの適正化 Add End

        return new ResponseEntity<>(portList, HttpStatus.OK);
      } catch (Exception e) {
        // wangzuo アプリケーションログの適正化 Mod
        eventLogMessage.setLogMessage(this.getClass().getName() + "GetCardAppPorts実施異常終了：" + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      }
    }
    // add 2020-09-25 FNSI-4200ポートを使用している 孫 end
}
