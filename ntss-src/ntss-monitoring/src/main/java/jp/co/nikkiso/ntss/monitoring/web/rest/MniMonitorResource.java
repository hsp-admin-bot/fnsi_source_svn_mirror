package jp.co.nikkiso.ntss.monitoring.web.rest;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.Random;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.entity.custom.MniMonitorSelected;
import jp.co.nikkiso.ntss.monitoring.service.MniMonitorService;
import jp.co.nikkiso.ntss.monitoring.web.dto.MonitorParameterDto;
import jp.co.nikkiso.ntss.monitoring.web.dto.MonitorParameterDtoEx;
import jp.co.nikkiso.ntss.monitoring.service.logger.LogEventUtils;

@CrossOrigin(origins = "*") // 別ドメインからのテスト用にアクセスすることを許可
@RestController
@RequestMapping("/api/mni_monitor")
public class MniMonitorResource {

  private final Logger log = LoggerFactory.getLogger(getClass());

  @Autowired
  private MniMonitorService mniMoniService;
  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End


  @GetMapping("/search")
  public ResponseEntity<List<MniMonitorSelected>> fetchMoniValByMachines(@ModelAttribute MonitorParameterDto dto) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "/api/mni_monitor" + "/search";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
     null);
    // wp アプリケーションログの適正化 Add End

    List<MniMonitorSelected> ordMoni;
    try {
      ordMoni = mniMoniService.selectPickupByMachine(dto, dto.buildMonitorKeyParam());
      ResponseEntity<List<MniMonitorSelected>> r = Optional.ofNullable(ordMoni)
          .map(moni -> new ResponseEntity<>(moni, HttpStatus.OK))
          .orElse(new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR));

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return r;
    } catch (Exception e) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  @GetMapping("/search_ex")
  public ResponseEntity<List<MniMonitorSelected>> fetchMoniValByMachinesOfFirst(@ModelAttribute MonitorParameterDtoEx dto) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "/api/mni_monitor" + "/search_ex";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    List<MniMonitorSelected> ordMoni;
    try {
      if(dto.getLastBioMoniCtlNo() <= 0L && dto.getOccurDate() != null) {
        // 最終取得CtlNoが未設定の場合はランダムで終了時刻を設定(10分から190分)
        Random rand = new Random();
        int num = rand.nextInt(19) * 10 + 10;
        LocalDateTime lastDate = dto.getOccurDate().toLocalDateTime();
        dto.setLastOccurDate(Timestamp.valueOf(lastDate.plusMinutes(num)));
      }

      ordMoni = mniMoniService.selectPickupByMachineEx(dto, dto.buildMonitorKeyParam());

      ResponseEntity<List<MniMonitorSelected>> r = Optional.ofNullable(ordMoni)
          .map(moni -> new ResponseEntity<>(moni, HttpStatus.OK))
          .orElse(new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR));
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return r;
    } catch (Exception e) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  @GetMapping("/search_ex_diff")
  public ResponseEntity<List<MniMonitorSelected>> fetchMoniValByMachinesOfDiff(@ModelAttribute MonitorParameterDto dto) {

    List<MniMonitorSelected> ordMoni;
    try {
      ordMoni = mniMoniService.selectPickupByMachineExDiff(dto, dto.buildMonitorKeyParam());

      ResponseEntity<List<MniMonitorSelected>> r = Optional.ofNullable(ordMoni)
          .map(moni -> new ResponseEntity<>(moni, HttpStatus.OK))
          .orElse(new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR));
      return r;
    } catch (Exception e) {
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }



  /**
   * クラス名取得
   */
  private String getClassName() {
    return this.getClass().getName();
  }

  /**
   * メソッド名取得
   */
  private String getMethodName() {
    return Thread.currentThread().getStackTrace()[2].getMethodName();
  }
}
