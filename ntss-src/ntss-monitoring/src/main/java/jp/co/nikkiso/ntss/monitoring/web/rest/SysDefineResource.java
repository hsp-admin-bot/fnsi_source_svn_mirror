package jp.co.nikkiso.ntss.monitoring.web.rest;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.net.URI;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.monitoring.service.SysSystemDefineService;

import jp.co.nikkiso.ntss.monitoring.service.logger.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;

@CrossOrigin(origins = "*") // 別ドメインからのテスト用にアクセスすることを許可
@RestController
@RequestMapping("/api/system_define")
public class SysDefineResource {

  private final Logger log = LoggerFactory.getLogger(getClass());

  @Autowired
  private SysSystemDefineService sysSystemDefineService;

  @Autowired
  private LogService logService;
  /**
   * SysSystemDefineの内容を取得する
   * @param facility_cd 施設コード
   * @param ctl_no 識別子
   * @return
   */
  @GetMapping("/{facility_cd}/{ctl_no}")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<SysSystemDefine> getSystemDefine(
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
      @PathVariable("facility_cd") String facility_cd,
     // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
     //@PathVariable("ctl_no") String ctl_no) {
      @PathVariable("ctl_no") Long ctl_no) {
     // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(String.format("REST request to get sysSystemDefine : %s %s", facility_cd, ctl_no));
    eventLogMessage.setFacilityCd(facility_cd);
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
    try {
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //return new ResponseEntity<>(sysSystemDefineService.selectByPrimaryKey(facility_cd, BigDecimal.valueOf(Integer.parseInt(ctl_no))), HttpStatus.OK);
      return new ResponseEntity<>(sysSystemDefineService.selectByPrimaryKey(facility_cd, BigDecimal.valueOf(ctl_no)), HttpStatus.OK);
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    }catch (Exception ex) {
      eventLogMessage.setLogMessage(String.format("Error get sysSystemDefine : %s", ex.getMessage()));
      eventLogMessage.setFacilityCd(facility_cd);
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
    }
  }

  @PostMapping("")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<String> writeSystemDefine(@RequestBody SysSystemDefine sysSystemDefine) {
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
    try {
      // エスケープ文字の置換
      String val = sysSystemDefine.getValue();
      if(val != null) {
        sysSystemDefine.setValue(val.replace("\\\"", "\""));
      }

      int result = sysSystemDefineService.insertOrUpdate(sysSystemDefine);
      if(result == 1) {
        return new ResponseEntity<>("", HttpStatus.OK);
      } else if(result == -1) {
        // 新しいデータがDBにある
        return new ResponseEntity<>("先にデータベースが変更されていたため、書き込みできませんでした。", HttpStatus.CONFLICT);
      } else {
        return new ResponseEntity<>("", HttpStatus.INTERNAL_SERVER_ERROR);
      }
    }catch (Exception ex) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(String.format("Error post sysSystemDefine : %s", ex.getMessage()));
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(ex.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
}
