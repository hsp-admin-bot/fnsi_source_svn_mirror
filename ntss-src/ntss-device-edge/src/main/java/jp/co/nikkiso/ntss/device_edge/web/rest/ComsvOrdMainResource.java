package jp.co.nikkiso.ntss.device_edge.web.rest;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;


import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import jp.co.nikkiso.ntss.api.request.AdditionCalculationRequest;
import jp.co.nikkiso.ntss.api.service.additionInfo.AdditionCalculationService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvComplaintTreatment;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvOrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvOrdMainRstDialysisState;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainRstWeightInfo;
import jp.co.nikkiso.ntss.core.entity.custom.RecrclRtElement;
import jp.co.nikkiso.ntss.device_edge.service.MntMachineStateService;
import jp.co.nikkiso.ntss.device_edge.util.DateTimeUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.device_edge.response.comsvOrdMain.ComsvNextPatOrdResponse;
import jp.co.nikkiso.ntss.device_edge.service.ComsvOrdMainService;
import jp.co.nikkiso.ntss.device_edge.service.ComsvPatRelatedService;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import jp.co.nikkiso.ntss.device_edge.web.rest.util.WebApiCallCommonUtil;

import javax.annotation.Resource;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@RestController
@RequestMapping("/api/comsv_ord")

public class ComsvOrdMainResource {

  @Autowired
  private LogService logService;

  /**
   * 通信サーバ用治療情報の取得
   */
  @Autowired
  private ComsvOrdMainService comsvOrdMainService;
  // add 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- start
  @Autowired
  MntMachineStateService mntMachineStateService;
  // add 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- end
  @Autowired
  private ComsvPatRelatedService comsvPatRelatedService;

  @Autowired
  OrdMainDao ordMainDao;

  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;

  // add 11454 時間外加算自動処理が機能していない zkm start
  @Autowired
  private AdditionCalculationService additionCalculationService;
  // add 11454 時間外加算自動処理が機能していない zkm end

  //9480 排液済，検査計算 gjn start
  @Resource(name = "crawlExecutorPool")
  private ExecutorService threadExector;
  //9480 排液済，検査計算 gjn end

  private static class MonitorData {
    public String mon1;
    public String mon2;
    public String mon3;
    public String mon4;
    public String mon5;
    public String mon6;
    public String mon7;
  }

  private static class LogData {
    public String log1;
    public String log2;
    public String log3;
    public String log4;
  }

  //add 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
  private static class Rst_Comptreat {
    public String unit; //単位
    public String amount; //数量
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //public String ctl_no; // 管理番号
    public Long ctl_no; // 管理番号
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    public String row_no; //行番号
    public String treat_cd; //処置コード
    public String checkFlag; //帳票出力区分
    public String over_time;
    public String occur_date; // 発生日時
    public String treat_name; //処置名
    public String input_class; //入力区分
    public String is_editable; //編集可能フラグ, (*2)
    public String medicine_cd; //薬剤コード
    public String oxygen_time; //酸素吸入時間
    // mod #10158 コンバートされた酸素吸入が画面に表示されない dou start
    // public String treat_class; //処置区分
    public Integer treat_class; //処置区分
    // mod #10158 コンバートされた酸素吸入が画面に表示されない dou end
    public String cop_order_no; //連携オーダ番号, (*1)
    public String oxygen_speed; //酸素速度
    public String oxygen_start; //酸素吸入開始日時
    public String procedure_cd; //手技コード
    public String linkStartDate;
    public String medicine_name; //薬剤名
    public String medicine_type;
    public String oxygen_amount; //酸素吸入量
    public String procedure_name; //手技名
    public String treat_medicine_cd; //処置薬剤コード
    public String treat_medicine_name; //処置薬剤名
    public String electrocardiogram_type; //心電編集種別 (*3)
    public String electrocardiogram_start;
  }

  private static class Rst_Complaint {
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //public String ctl_no; // 管理番号
    public Long ctl_no; // 管理番号
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    public String row_no; // 行番号
    public String comp_cd; //愁訴コード
    public String checkFlag; //帳票出力区分
    public String complaint; //愁訴内容
    public String occur_date; //発生日時
    public String input_class; //入力区分
  }

  private static class Rst_Treat_Staff {
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //public String ctl_no; // 管理番号
    public Long ctl_no; // 管理番号
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    public String row_no; // 行番号
    public String occur_date; //発生日時
    public String input_class; //入力区分
    public String is_editable; //編集可能フラグ
    public String cop_order_no; //連携オーダ番号
    public String treat_staff_cd; //処置者コード
    public String treat_staff_name; //処置者名
    //add redmine bug#6452 劉 start
    public String checkFlag; //帳票出力区分
    //add redmine bug#6452 劉 end
  }
  //add 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end

  @GetMapping("/{ord_no}")
  public ResponseEntity<?> getComsvOrd(
    @PathVariable("ord_no") Long ord_no) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API GET CALLED = " + ord_no);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (ord_no > 0) {
      ComsvOrdMain res = comsvOrdMainService.selectByNo(ord_no);
      eventLogMessage.setLogMessage("API GET CALLED = " + ord_no);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      eventLogMessage.setLogMessage("API GET CALLED = " + ord_no);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  // #11168 2024.10.11 add 対象オーダーの有無確認 TDC片口 start
  @GetMapping("/exists/{facility_cd}/{ord_no}")
  public ResponseEntity<?> existsOrd(
    @PathVariable("facility_cd") String facilityCd,
    @PathVariable("ord_no") Long ord_no) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setLogMessage("API CALL existsOrd : ord_no = " + ord_no);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    boolean res = comsvOrdMainService.existsOrdNo(ord_no);
    eventLogMessage.setLogMessage("API Exit existsOrd : ord_no = " + ord_no + " is " + (res ? "exists." : "not found."));
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    return new ResponseEntity<>(res ? 1 : 0, HttpStatus.OK);
  }
  // #11168 2024.10.11 add 対象オーダーの有無確認 TDC片口 end

  /**
   * 通信サーバ用次患者情報の取得
   * @param ord_no
   * @return
   */
  @GetMapping("/next_pat/{ord_no}/{device_edge_no}")
  public ResponseEntity<?> getNextPatInfo(
    @PathVariable("ord_no") Long ord_no,
    @PathVariable("device_edge_no") Integer device_edge_no) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API GET CALLED = " + ord_no);
    eventLogMessage.setDeviceEdgeNo(String.valueOf(device_edge_no));
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (ord_no > 0) {
      ComsvNextPatOrdResponse res = comsvOrdMainService.selectNextPatInfo(ord_no, device_edge_no);
      if (Objects.isNull(res)) {
        eventLogMessage.setLogMessage("NO DATA");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
        //return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
      }
      eventLogMessage.setLogMessage("O K");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      eventLogMessage.setLogMessage("ERROR");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 通信サーバ用治療情報の条件送信日時更新
   * @param ord_no
   * @param dial_state
   * @param send_date
   * @return
   * @throws ParseException
   */
  @PutMapping("/send_date/{ord_no}/{dial_state}/{send_date}")
  public ResponseEntity<Void> updateSendDate(
    @PathVariable("ord_no") Long ord_no,
    @PathVariable(name = "dial_state", required = false) String dial_state,
    @PathVariable(name = "send_date", required = false) String send_date) throws ParseException {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API PUT CALLED = " + ord_no + " " + send_date);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    ComsvOrdMain comsv = new ComsvOrdMain();
    comsv.setOrdNo(ord_no);
    comsv.setDialState(dial_state);
    if (send_date.equals("null")) {
      comsv.setSendDate(null);
    } else {
      Timestamp sendTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(send_date).getTime());
      comsv.setSendDate(sendTime);
    }
    int ret = comsvOrdMainService.updateSendDate(comsv);
    if (ret > 0) {
      return ResponseEntity.ok().build();
    } else {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }

  /**
   * 通信サーバ用治療情報の治療開始日時更新
   * @param ord_no
   * @param pat_id
   * @param dial_state
   * @param start_date
   * @return
   * @throws ParseException
   * @throws RuntimeException
   * @throws URISyntaxException
   */
  @PutMapping("/start_date/{ord_no}/{pat_id}/{dial_state}/{start_date}")
  public ResponseEntity<Void> updateStartDate(
    @PathVariable("ord_no") Long ord_no,
    @PathVariable("pat_id") Long pat_id,
    @PathVariable(name = "dial_state", required = false) String dial_state,
    @PathVariable(name = "start_date", required = false) String start_date) throws ParseException, URISyntaxException, RuntimeException {

    ComsvOrdMain comsv = new ComsvOrdMain();
    comsv.setOrdNo(ord_no);
    comsv.setDialState(dial_state);
    if (start_date.equals("null")) {
      comsv.setStartDate(null);
    } else {
      Timestamp startTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(start_date).getTime());
      comsv.setStartDate(startTime);
    }
    int ret = comsvOrdMainService.updateStartDate(comsv);
    if (ret > 0) {
      // 加算処理
      if (dial_state.equals("3")) {
        OrdMain ord = ordMainDao.selectByOrdNo(ord_no);
        AdditionCalculationRequest addReq = new AdditionCalculationRequest();
        addReq.setFacilityCd(ord.getFacilityCd());
        addReq.setPatId(pat_id);
        addReq.setOrdNo(ord_no);
        addReq.setEventId(5);
        // mod 11454 時間外加算自動処理が機能していない zkm start
//        webApiCallCommonUtil.calculationAddition(addReq);
        additionCalculationService.calculationAddition(addReq);
        // mod 11454 時間外加算自動処理が機能していない zkm end
      }
      return ResponseEntity.ok().build();
    } else {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }

  /**
   * 通信サーバ用治療情報の治療終了日時更新
   * @param ord_no
   * @param dial_state
   * @param end_date
   * @return
   * @throws ParseException
   */
  @PutMapping("/end_date/{ord_no}/{dial_state}/{end_date}")
  public ResponseEntity<Void> updateEndDate(
    @PathVariable("ord_no") Long ord_no,
    @PathVariable(name = "dial_state", required = false) String dial_state,
    @PathVariable(name = "end_date", required = false) String end_date) throws ParseException {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API PUT CALLED = " + ord_no + " " + end_date);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    ComsvOrdMain comsv = new ComsvOrdMain();
    comsv.setOrdNo(ord_no);
    comsv.setDialState(dial_state);
    if (end_date.equals("null")) {
      comsv.setEndDate(null);
    } else {
      Timestamp endTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(end_date).getTime());
      comsv.setEndDate(endTime);
    }
    int ret = comsvOrdMainService.updateEndDate(comsv);
    if (ret > 0) {
      //9480 排液済，検査計算 gjn start
      if (!StringUtils.isEmpty(dial_state) && dial_state.equals("4")) {
        //排液済代表治療が終了し、実際の終了時間を更新するには、計算インタフェースを呼び出す必要がある
        threadExector.execute(new Runnable() {
          @Override
          public void run() {
            // 非同期実行チェック計算
            webApiCallCommonUtil.doAutoCalculation(ord_no);
          }
        });
      }
      //9480 排液済，検査計算 gjn end
      return ResponseEntity.ok().build();
    } else {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }

  /**
   * 通信サーバ用治療情報の愁訴処置者更新
   * @param ord_no
   * @param occur_date
   * @param staff_cd
   * @return
   * @throws ParseException
   */
  @PutMapping("/comptreat_staff/{ord_no}/{occur_date}/{staff_cd}")
  public ResponseEntity<Void> updateCompTreatStaff(
    @PathVariable("ord_no") Long ord_no,
    @PathVariable(name = "occur_date", required = false) String occur_date,
    @PathVariable(name = "staff_cd", required = false) String staff_cd) throws ParseException {

    //add 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
    List<Rst_Comptreat> treatlist = null;
    List<Rst_Complaint> complaintlist = null;
    List<Rst_Treat_Staff> treatStafflist = null;
    int ctl_no_complaint= 1;
    int ctl_no_treat = 1;
    int ctl_no_treat_staff = 1;
    int ctl_no_max = 1;
    // mod 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 start
    // Date date= null;
    // Rst_Comptreat last_treat = null;
    // Rst_Complaint last_comp = null;
    boolean inputClassFlag = false;
    Optional<Rst_Comptreat> last_treat = null;
    Optional<Rst_Complaint>  last_comp = null;
    Optional<Rst_Treat_Staff>  last_treat_staff = null;
    // mod 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 end
    //add 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API PUT CALLED = " + ord_no + " " + occur_date + " " + staff_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (ord_no <= 0) {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
    ZonedDateTime input_date = null;
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSSXXX");
    if (occur_date == null || occur_date.isEmpty() || "null".equals(occur_date)) {
      input_date = ZonedDateTime.now();
      occur_date = input_date.format(formatter);
    } else {
      LocalDateTime localDateTime = LocalDateTime.parse(occur_date, DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
      input_date= localDateTime.atZone(ZoneId.of("Asia/Tokyo"));
      occur_date = input_date.format(formatter);
    }

    //add 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
    ComsvComplaintTreatment cct = comsvOrdMainService.selectRecentRstTreatmentInfo(ord_no);
    String strTrementInfo = cct.getRstTreatmentInfo();
    if (strTrementInfo != null) {
      ObjectMapper mapper = new ObjectMapper();
      try {
        treatlist = mapper.readValue(strTrementInfo, new TypeReference<List<Rst_Comptreat>>() {
        });
      } catch (Exception e) {
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("通信サーバ用治療情報の愁訴情報の変換処理に失敗" + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      }
    }

    String strComplaintInfo = cct.getRstComplaintInfo();
    if (strComplaintInfo != null) {
      ObjectMapper mapper = new ObjectMapper();
      try {
        complaintlist = mapper.readValue(strComplaintInfo, new TypeReference<List<Rst_Complaint>>() {
        });
      } catch (Exception e) {
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("通信サーバ用治療情報の処置情報の変換処理に失敗" + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      }
    }
    String strTreatStaffInfo = cct.getRstTreatStaffInfo();
    if (strTreatStaffInfo != null) {
      ObjectMapper mapper = new ObjectMapper();
      try {
        treatStafflist = mapper.readValue(strTreatStaffInfo, new TypeReference<List<Rst_Treat_Staff>>() {
        });
      } catch (Exception e) {
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("通信サーバ用治療情報の処置情報の変換処理に失敗" + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      }
    }

    // mod 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 start
    List<Long> ctlNoList = Optional.ofNullable(treatlist)
      .orElse(Collections.emptyList()).stream()
      .filter(item -> item.treat_class != null && (item.treat_class == 3 || item.treat_class == 4)).map(item -> item.ctl_no).collect(Collectors.toList());

    Optional<Rst_Complaint> latestComplaint = Optional.ofNullable(complaintlist)
      .orElse(Collections.emptyList()).stream()
      .filter(item -> "0".equals(item.input_class) && item.occur_date
        != null && item.occur_date.isEmpty() == false
        && "null".equals(item.occur_date) == false && !ctlNoList.contains(item.ctl_no))
      .max(Comparator.comparing(item -> item.occur_date));
    Optional<Rst_Comptreat> latestTreat = Optional.ofNullable(treatlist)
      .orElse(Collections.emptyList()).stream()
      .filter(item -> "0".equals(item.input_class) && item.occur_date
        != null && item.occur_date.isEmpty() == false
        && "null".equals(item.occur_date) == false && !ctlNoList.contains(item.ctl_no))
      .max(Comparator.comparing(item -> item.occur_date));
    Optional<Rst_Treat_Staff> latestTreatStaff = Optional.ofNullable(treatStafflist)
      .orElse(Collections.emptyList()).stream()
      .filter(item -> "0".equals(item.input_class) && item.occur_date
        != null && item.occur_date.isEmpty() == false
        && "null".equals(item.occur_date) == false && !ctlNoList.contains(item.ctl_no))
      .max(Comparator.comparing(item -> item.occur_date));

    Long ctl_no_latestTmp = 0L;
    String occur_dateTmp = "";
    Boolean addToNewCtlNoFlag = false;
    if (latestComplaint.isPresent()) {
      Rst_Complaint result = latestComplaint.get();
      ctl_no_latestTmp = result.ctl_no;
      occur_dateTmp = result.occur_date;
      addToNewCtlNoFlag = true;
    }
    if (latestTreat.isPresent()) {
      Rst_Comptreat result = latestTreat.get();
      if (result.ctl_no > ctl_no_latestTmp) {
        ctl_no_latestTmp = result.ctl_no;
        occur_dateTmp = result.occur_date;
        addToNewCtlNoFlag = true;
      }
    }
    if (latestTreatStaff.isPresent()) {
      Rst_Treat_Staff result = latestTreatStaff.get();

      // #11598 2026.01.07 add 処置者の最大ctl_noが愁訴処置の最大ctl_noと同じ場合は登録処理を行わないようにする TDC米沢 start
      if(result.ctl_no.equals(ctl_no_latestTmp)) {
        // ctl_noが同じ場合はすでに登録済みと判断

        // ログ記録
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(String.format(
          "愁訴・処置者登録: すでに登録済みのため登録処理をキャンセル (ord_no: %d / occur_date: %s / staff_cd: %s / ctl_no: %d)"
          ,ord_no
          ,occur_date
          ,staff_cd,
          result.ctl_no
        ));
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);

        // 登録処理を行わずに正常終了を返す
        return ResponseEntity.ok().build();
      }
      // #11598 2026.01.07 add 処置者の最大ctl_noが愁訴処置の最大ctl_noと同じ場合は登録処理を行わないようにする TDC米沢 end

      if (result.ctl_no > ctl_no_latestTmp) {
        ctl_no_latestTmp = result.ctl_no;
        occur_dateTmp = result.occur_date;
        addToNewCtlNoFlag = false;
      }
    }

    boolean dbMinOccurDate = true;

    ZonedDateTime dbDateTime = null;
    if (occur_dateTmp == null || occur_dateTmp.isEmpty()) {
      dbMinOccurDate = false;
    } else {
      Pattern pattern = Pattern.compile("([+-]\\d{2}:\\d{2}|Z)$");
      Matcher matcher = pattern.matcher(occur_dateTmp);
      if (!matcher.find()) {
        String newDateTime = occur_dateTmp + "+09:00";
        dbDateTime = ZonedDateTime.parse(newDateTime, DateTimeFormatter.ISO_OFFSET_DATE_TIME);
      } else {
        dbDateTime = ZonedDateTime.parse(occur_dateTmp, DateTimeFormatter.ISO_OFFSET_DATE_TIME);
      }
    }
    if (dbMinOccurDate) {
      long diffInMinutes = Math.abs(Duration.between(input_date, dbDateTime).toMinutes());
      if (diffInMinutes <= 3) {
        occur_date = occur_dateTmp;
        inputClassFlag = true;
      }
    }
    //add 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end

    //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
    //int ret = comsvOrdMainService.updateCompTreatStaff(ord_no, occur_date, staff_cd);
    int ret = 0;
    if (inputClassFlag && addToNewCtlNoFlag) {
      ret = comsvOrdMainService.updateCompTreatStaff(ord_no, ctl_no_latestTmp.intValue(), occur_date, staff_cd);
    }else {
      if (complaintlist != null && complaintlist.size() > 0 ) {
        last_comp = complaintlist.stream()
          .filter(item -> item.ctl_no != null)
          .max(Comparator.comparing(item -> item.ctl_no));
        if (last_comp.isPresent()) {
          Rst_Complaint result = last_comp.get();
          ctl_no_complaint = Integer.parseInt(result.ctl_no.toString());
        }
      }
      if (treatlist != null && treatlist.size() > 0) {
        last_treat = treatlist.stream()
          .filter(item -> item.ctl_no != null)
          .max(Comparator.comparing(item -> item.ctl_no));
        if (last_treat.isPresent()) {
          Rst_Comptreat result = last_treat.get();
          ctl_no_treat = Integer.parseInt(result.ctl_no.toString());
        }
      }

      if (treatStafflist != null && treatStafflist.size() > 0) {
        last_treat_staff = treatStafflist.stream()
          .filter(item -> item.ctl_no != null)
          .max(Comparator.comparing(item -> item.ctl_no));
        if (last_treat_staff.isPresent()) {
          Rst_Treat_Staff result = last_treat_staff.get();
          ctl_no_treat_staff = Integer.parseInt(result.ctl_no.toString());
        }
      }
      ctl_no_max = Math.max(ctl_no_complaint, Math.max(ctl_no_treat, ctl_no_treat_staff));

      // getNewCtlNo
      ret = comsvOrdMainService.updateCompTreatStaff(ord_no, ctl_no_max + 1, occur_date, staff_cd);
    }
    // mod 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 end
    //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end
    eventLogMessage.setLogMessage("comsvOrdMainService = " + ret);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (ret > 0) {
      return ResponseEntity.ok().build();
    } else {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }

  /**
   * 通信サーバ用治療情報の酸素吸入更新
   * @param ord_no
   * @param occur_date
   * @param oxygen_start
   * @param oxygen_amount
   * @return
   * @throws ParseException
   */
  @PutMapping("/oxygen/{ord_no}/{occur_date}/{oxygen_start}/{oxygen_amount}")
  public ResponseEntity<Void> updateOxygen(
    @PathVariable("ord_no") Long ord_no,
    @PathVariable(name = "occur_date", required = false) String occur_date,
    @PathVariable(name = "oxygen_start", required = false) String oxygen_start,
    @PathVariable(name = "oxygen_amount", required = false) String oxygen_amount) throws ParseException {

    //add 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
    List<Rst_Comptreat> treatlist = null;
    List<Rst_Complaint> complaintlist = null;
    List<Rst_Treat_Staff> treatstafflist = null;
    int ctl_no_complaint= 0;
    int ctl_no_treat = 0;
    int ctl_no_max = 0;
    Rst_Comptreat last_treat = null;
    Rst_Complaint last_comp = null;
    Rst_Treat_Staff last_treatstaff = null;
    int ctl_no_treatstaff = 0;
    //add 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API PUT CALLED = " + ord_no + " " + occur_date + " " + oxygen_start + " " + oxygen_amount);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (ord_no <= 0) {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
    // mod 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 start
    //    if (occur_date.equals("null") == false) {
    //      Timestamp occurTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(occur_date).getTime());
    //      //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
    //      //occur_date = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX").format(occurTime);
    //      occur_date = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss").format(occurTime);
    //      //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end
    //    }
    ZonedDateTime input_date = null;
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSSXXX");
    if (occur_date == null || occur_date.isEmpty() || "null".equals(occur_date)) {
      input_date = ZonedDateTime.now();
      occur_date = input_date.format(formatter);
    } else {
      LocalDateTime localDateTime = LocalDateTime.parse(occur_date, DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
      input_date= localDateTime.atZone(ZoneId.of("Asia/Tokyo"));
      occur_date = input_date.format(formatter);
    }
    // mod 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 end
    if ("null".equals(oxygen_start) == false) {
      Timestamp startTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(oxygen_start).getTime());
      //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
      //oxygen_start = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX").format(startTime);
      oxygen_start = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss").format(startTime);
      //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end
    }

    //add 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
    ComsvComplaintTreatment cct = comsvOrdMainService.selectRecentRstTreatmentInfo(ord_no);
    String strTrementInfo = cct.getRstTreatmentInfo();
    if (strTrementInfo != null) {
      ObjectMapper mapper = new ObjectMapper();
      try {
        treatlist = mapper.readValue(strTrementInfo, new TypeReference<List<Rst_Comptreat>>() {
        });
      } catch (Exception e) {
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("通信サーバ用治療情報の愁訴情報の変換処理に失敗" + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      }
    }

    String strComplaintInfo = cct.getRstComplaintInfo();
    if (strComplaintInfo != null) {
      ObjectMapper mapper = new ObjectMapper();
      try {
        complaintlist = mapper.readValue(strComplaintInfo, new TypeReference<List<Rst_Complaint>>() {
        });
      } catch (Exception e) {
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("通信サーバ用治療情報の処置情報の変換処理に失敗" + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      }
    }

    String strTreatStaffInfo = cct.getRstTreatStaffInfo();
    if (strTreatStaffInfo != null) {
      ObjectMapper mapper = new ObjectMapper();
      try {
        treatstafflist = mapper.readValue(strTreatStaffInfo, new TypeReference<List<Rst_Treat_Staff>>() {
        });
      } catch (Exception e) {
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("通信サーバ用治療情報の酸素吸入処置者情報の変換処理に失敗" + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      }
    }

    //  mod 10270 仮想端末追加酸素吸入linkStartDate不正 関  start
    //  if (complaintlist != null) {
    if (complaintlist != null && complaintlist.size() > 0) {
      //  mod 10270 仮想端末追加酸素吸入linkStartDate不正 関  end
      // mod #10270 酸素吸入でブラウザから開始を行った後に透析装置の仮想端末で終了ができない dengshen start
      // last_comp = complaintlist.get(complaintlist.size() - 1);
      // // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      // //if(last_comp != null &&  last_comp.ctl_no!= null && last_comp.ctl_no.isEmpty()==false && last_comp.ctl_no.equals("null")==false) {
      //   //ctl_no_complaint=Integer.parseInt(last_comp.ctl_no);
      // if (last_comp != null && last_comp.ctl_no != null) {
      //   ctl_no_complaint = Integer.parseInt(last_comp.ctl_no.toString());
      // // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      // }
      for (Rst_Complaint item : complaintlist) {
        if (last_comp != null) {
          if (last_comp.ctl_no != null && item.ctl_no != null) {
            last_comp = last_comp.ctl_no > item.ctl_no ? last_comp : item;
          }
        } else {
          last_comp = item;
        }
      }
      ctl_no_complaint = last_comp == null ? 0 : Integer.parseInt(last_comp.ctl_no.toString());
      // mod #10270 酸素吸入でブラウザから開始を行った後に透析装置の仮想端末で終了ができない dengshen end
    }

    //  mod 10270 仮想端末追加酸素吸入linkStartDate不正 関  start
    //  if (treatlist != null) {
    if (treatlist != null && treatlist.size() > 0) {
      //  mod 10270 仮想端末追加酸素吸入linkStartDate不正 関  end
      // mod #10270 酸素吸入でブラウザから開始を行った後に透析装置の仮想端末で終了ができない dengshen start
      // last_treat = treatlist.get(treatlist.size() - 1);
      // // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      // //if(last_treat != null &&  last_treat.ctl_no!= null && last_treat.ctl_no.isEmpty()==false && last_treat.ctl_no.equals("null")==false) {
      //   //ctl_no_treat = Integer.parseInt(last_treat.ctl_no);
      // if (last_treat != null && last_treat.ctl_no != null) {
      //   ctl_no_treat = Integer.parseInt(last_treat.ctl_no.toString());
      // // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      // }
      for (Rst_Comptreat item : treatlist) {
        if (last_treat != null) {
          if (last_treat.ctl_no != null && item.ctl_no != null) {
            last_treat = last_treat.ctl_no > item.ctl_no ? last_treat : item;
          }
        } else {
          last_treat = item;
        }
      }
      ctl_no_treat = last_treat == null ? 0 : Integer.parseInt(last_treat.ctl_no.toString());
      // mod #10270 酸素吸入でブラウザから開始を行った後に透析装置の仮想端末で終了ができない dengshen end
    }

    //  mod 10270 仮想端末追加酸素吸入linkStartDate不正 関  start
    //  if (treatstafflist != null) {
    if (treatstafflist != null && treatstafflist.size() > 0) {
      //  mod 10270 仮想端末追加酸素吸入linkStartDate不正 関  end
      // mod #10270 酸素吸入でブラウザから開始を行った後に透析装置の仮想端末で終了ができない dengshen start
      // last_treatstaff = treatstafflist.get(treatstafflist.size() - 1);
      // // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      // //if(last_treatstaff != null &&  last_treatstaff.ctl_no!= null && last_treatstaff.ctl_no.isEmpty()==false && last_treatstaff.ctl_no.equals("null")==false) {
      //   //ctl_no_treatstaff = Integer.parseInt(last_treatstaff.ctl_no);
      // if (last_treatstaff != null && last_treatstaff.ctl_no != null) {
      //   ctl_no_treatstaff = Integer.parseInt(last_treatstaff.ctl_no.toString());
      // // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      // }
      for (Rst_Treat_Staff item : treatstafflist) {
        if (last_treatstaff != null) {
          if (last_treatstaff.ctl_no != null && item.ctl_no != null) {
            last_treatstaff = last_treatstaff.ctl_no > item.ctl_no ? last_treatstaff : item;
          }
        } else {
          last_treatstaff = item;
        }
      }
      ctl_no_treatstaff = last_treatstaff == null ? 0 : Integer.parseInt(last_treatstaff.ctl_no.toString());
      // mod #10270 酸素吸入でブラウザから開始を行った後に透析装置の仮想端末で終了ができない dengshen end
    }

    ctl_no_max = ctl_no_complaint > ctl_no_treat ? ctl_no_complaint : ctl_no_treat;
    ctl_no_max = ctl_no_max > ctl_no_treatstaff ? ctl_no_max : ctl_no_treatstaff;

    //add 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end

    //add 複数組の酸素吸入データマッチング問題に対応 劉 start
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //String ctlNoStart = "null";
    Long ctlNoStart = null;
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    if (null != oxygen_start && "null".equals(oxygen_start) && !treatlist.isEmpty()) {
      //酸素吸入終了時の判断
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //List<String> ctlNoStartList = new ArrayList<>();
      List<Long> ctlNoStartList = new ArrayList<>();
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      //  del 10270 仮想端末追加酸素吸入linkStartDate不正 関  start
      //  List<String> linkStartDateList = new ArrayList<>();
      //  del 10270 仮想端末追加酸素吸入linkStartDate不正 関  end

      //  add 10270 仮想端末追加酸素吸入linkStartDate不正 関  start
      List<Long> ctlNoLinkList = new ArrayList<>();
      //  add 10270 仮想端末追加酸素吸入linkStartDate不正 関  end

      for (int i = 0; i < treatlist.size(); i++) {
        Rst_Comptreat treat = treatlist.get(i);
        // mod #10158 コンバートされた酸素吸入が画面に表示されない dou start
        // if (null != treat && null != treat.treat_class && "3".equals(treat.treat_class)) {
        if (null != treat && null != treat.treat_class && treat.treat_class.equals(3)) {
          // mod #10158 コンバートされた酸素吸入が画面に表示されない dou end
          //酸素吸入開始ctl_no取得
          if (null != treat.oxygen_start && !treat.oxygen_start.isEmpty()) {
            // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
            //if (null != treat.ctl_no && !treat.ctl_no.isEmpty()) {
            if (null != treat.ctl_no) {
            // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
              ctlNoStartList.add(treat.ctl_no);
            }
          }
          //酸素吸入終了linkStartDate取得
          //  mod 10270 仮想端末追加酸素吸入linkStartDate不正 関  start
          //  if (null != treat.oxygen_amount && !treat.oxygen_amount.isEmpty()) {
          //    if (null != treat.linkStartDate && !treat.linkStartDate.isEmpty()) {
          //      linkStartDateList.add(treat.linkStartDate);
          //    }
          //  }
          if (null != treat.linkStartDate && !treat.linkStartDate.isEmpty()) {
            for (int j = 0; j < treatlist.size(); j++) {
              if (null != treatlist.get(j).ctl_no && treatlist.get(j).ctl_no.toString().equals(treat.linkStartDate)) {
                ctlNoLinkList.add(treatlist.get(j).ctl_no);
              }
            }
          }
          //  mod 10270 仮想端末追加酸素吸入linkStartDate不正 関  end
        }
      }

      //  mod 10270 仮想端末追加酸素吸入linkStartDate不正 関  start
      //      for (int indexCtlNo = 0; indexCtlNo < ctlNoStartList.size(); indexCtlNo++) {
      //        int indexLink;
      //        for (indexLink = 0; indexLink < linkStartDateList.size(); indexLink++) {
      //          if (ctlNoStartList.get(indexCtlNo).equals(linkStartDateList.get(indexLink))) {
      //            break;
      //          }
      //        }
      //        if (indexLink == linkStartDateList.size()) {
      //          ctlNoStart = ctlNoStartList.get(indexCtlNo);
      //          break;
      //        }
      //      }

      if (ctlNoStartList.size() > ctlNoLinkList.size()) {
        ctlNoStartList.removeAll(ctlNoLinkList);
        if (ctlNoStartList.size() > 0) {
          ctlNoStart = Collections.max(ctlNoStartList);
        }
      }
      //  mod 10270 仮想端末追加酸素吸入linkStartDate不正 関  end
    }
    //add 複数組の酸素吸入データマッチング問題に対応 劉 end
    int ret = 0;
    AtomicInteger ctlNo = new AtomicInteger();
    AtomicInteger linkStartDate = new AtomicInteger();

    Optional<Rst_Comptreat> maxCtlNoTreatment = Optional.ofNullable(treatlist)
      .orElse(Collections.emptyList()).stream()
      .filter(t -> (t.oxygen_amount == null || "null".equals(t.oxygen_amount))
        && Objects.nonNull(t.linkStartDate) && !"null".equals(t.linkStartDate))
      .max(Comparator.comparing(t -> t.ctl_no, Comparator.nullsLast(Comparator.naturalOrder())));

    // 終了と開始の完全ペア 装置登録の終了
    if (ctlNoStart == null && null != oxygen_start && "null".equals(oxygen_start) && maxCtlNoTreatment.isPresent()) {
      maxCtlNoTreatment.ifPresent(treatment -> {
        if (treatment.ctl_no != null && !"".equals(treatment.ctl_no)) {
          ctlNo.set(Math.toIntExact(treatment.ctl_no));
        }
        if (treatment.linkStartDate != null && !"".equals(treatment.linkStartDate)) {
          linkStartDate.set(Integer.parseInt(treatment.linkStartDate));
        }
      });
      ret = comsvOrdMainService.updateOxygenReplace(ord_no, ctlNo.get(), occur_date, oxygen_start, oxygen_amount, linkStartDate.toString());
    } else {
     ret = comsvOrdMainService.updateOxygen(ord_no, ctl_no_max + 1, 1, occur_date, oxygen_start, oxygen_amount, ctlNoStart != null ? ctlNoStart.toString() : "null");
    }

    //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
    //int ret = comsvOrdMainService.updateOxygen(ord_no, occur_date, oxygen_start, oxygen_amount);
    //mod 複数組の酸素吸入データマッチング問題に対応 劉 start
    //int ret = comsvOrdMainService.updateOxygen(ord_no,ctl_no_max + 1, 1, occur_date, oxygen_start, oxygen_amount);
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //int ret = comsvOrdMainService.updateOxygen(ord_no,ctl_no_max + 1, 1, occur_date, oxygen_start, oxygen_amount, ctlNoStart);
//    int ret = comsvOrdMainService.updateOxygen(ord_no, ctl_no_max + 1, 1, occur_date, oxygen_start, oxygen_amount, ctlNoStart.toString());
    /* mod EOL対応内部 #6990 by zrx 2023-07-10 --start */
    /* mod EOL対応内部 #6990 by zrx 2023-07-10 --end */
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    //mod 複数組の酸素吸入データマッチング問題に対応 劉 end
    //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end
    eventLogMessage.setLogMessage("updateOxygen = " + ret);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (ret > 0) {
      return ResponseEntity.ok().build();
    } else {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }

  /**
   * 通信サーバ用治療情報の酸素吸入処置者更新
   * @param ord_no
   * @param occur_date
   * @param staff_cd
   * @return
   * @throws ParseException
   */
  @PutMapping("/oxygen_staff/{ord_no}/{occur_date}/{staff_cd}")
  public ResponseEntity<Void> updateOxygenStaff(
    @PathVariable("ord_no") Long ord_no,
    @PathVariable(name = "occur_date", required = false) String occur_date,
    @PathVariable(name = "staff_cd", required = false) String staff_cd) throws ParseException {

    //add 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
    List<Rst_Comptreat> treatlist = null;
    List<Rst_Complaint> complaintlist = null;
    int ctl_no_complaint= 1;
    int ctl_no_treat = 1;
    int ctl_no_max = 1;
    Date date= null;
    Rst_Comptreat last_treat = null;
    Rst_Complaint last_comp = null;
    //add 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API PUT CALLED = " + ord_no + " " + occur_date + " " + staff_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (ord_no <= 0) {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
    // mod 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 start
    //    if (occur_date.equals("null") == false) {
    //      Timestamp occurTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(occur_date).getTime());
    //      //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
    //      //occur_date = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX").format(occurTime);
    //      occur_date = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss").format(occurTime);
    //      //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end
    //    }
    ZonedDateTime input_date = null;
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSSXXX");
    if (occur_date == null || occur_date.isEmpty() || "null".equals(occur_date)) {
      input_date = ZonedDateTime.now();
      occur_date = input_date.format(formatter);
    } else {
      LocalDateTime localDateTime = LocalDateTime.parse(occur_date, DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
      input_date= localDateTime.atZone(ZoneId.of("Asia/Tokyo"));
      occur_date = input_date.format(formatter);
    }
    // mod 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 end
    //add 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
    ComsvComplaintTreatment cct = comsvOrdMainService.selectRecentRstTreatmentInfo(ord_no);
    String strTrementInfo = cct.getRstTreatmentInfo();
    if (strTrementInfo != null) {
      ObjectMapper mapper = new ObjectMapper();
      try {
        treatlist = mapper.readValue(strTrementInfo, new TypeReference<List<Rst_Comptreat>>() {
        });
      } catch (Exception e) {
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("通信サーバ用治療情報の愁訴情報の変換処理に失敗" + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      }
    }
    Optional<Rst_Comptreat> latestTreat = Optional.ofNullable(treatlist)
      .orElse(Collections.emptyList()).stream()
      .filter(item -> item.treat_class != null && item.treat_class == 3)
      .max(Comparator.comparing(item -> item.ctl_no));

    if (latestTreat.isPresent()) {
      Rst_Comptreat result = latestTreat.get();
      if (result.ctl_no != null && !"".equals(result.ctl_no)) {
        ctl_no_max = Integer.parseInt(result.ctl_no.toString());
      }
      occur_date = result.occur_date;
    }

    //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
    //int ret = comsvOrdMainService.updateOxygenStaff(ord_no, occur_date, staff_cd);
    int ret = comsvOrdMainService.updateOxygenStaff(ord_no, ctl_no_max, 1, occur_date, staff_cd);
    //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end
    eventLogMessage.setLogMessage("comsvOrdMainService = " + ret);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (ret > 0) {
      return ResponseEntity.ok().build();
    } else {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }

  /**
   * 通信サーバ用治療情報の穿刺者情報更新
   * @param inp_no
   * @param ord_no
   * @param user_id
   * @param inp_date
   * @return
   * @throws ParseException
   */
  @PutMapping("/puncture_user/{inp_no}/{ord_no}/{user_id}/{inp_date}")
  public ResponseEntity<Void> updatePunctureUser(
    @PathVariable("inp_no") Integer inp_no,
    @PathVariable("ord_no") Long ord_no,
    @PathVariable("user_id") Long user_id,
    @PathVariable(name = "inp_date", required = false) String inp_date) throws ParseException {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API PUT CALLED = " + inp_no + " " + ord_no + " " + user_id + " " + inp_date);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (ord_no <= 0 || user_id <= 0) {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }

    if (inp_date.equals("null") == false) {
      Timestamp inpTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(inp_date).getTime());
      inp_date = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX").format(inpTime);
    }

    int ret;
    ret = comsvOrdMainService.updatePunctureUser(inp_no, ord_no, user_id, inp_date);
    eventLogMessage.setLogMessage("updatePunctureUser = " + ret + " " + inp_date);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (ret > 0) {
      return ResponseEntity.ok().build();
    } else {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }

  /**
   * 通信サーバ用治療情報の返血者情報更新
   * @param inp_no
   * @param ord_no
   * @param user_id
   * @param inp_date
   * @return
   * @throws ParseException
   */
  @PutMapping("/return_user/{inp_no}/{ord_no}/{user_id}/{inp_date}")
  public ResponseEntity<Void> updateReturnUser(
    @PathVariable("inp_no") Integer inp_no,
    @PathVariable("ord_no") Long ord_no,
    @PathVariable("user_id") Long user_id,
    @PathVariable(name = "inp_date", required = false) String inp_date) throws ParseException {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API PUT CALLED = " + inp_no + " " + ord_no + " " + user_id + " " + inp_date);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (ord_no <= 0 || user_id <= 0) {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }

    if (inp_date.equals("null") == false) {
      Timestamp inpTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(inp_date).getTime());
      inp_date = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX").format(inpTime);
    }

    int ret;
    ret = comsvOrdMainService.updateReturnUser(inp_no, ord_no, user_id, inp_date);
    eventLogMessage.setLogMessage("updateReturnUser = " + ret + " " + inp_date);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (ret > 0) {
      return ResponseEntity.ok().build();
    } else {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }

  /**
   * 通信サーバ用治療情報の担当者情報更新
   * @param inp_no
   * @param ord_no
   * @param user_id
   * @param inp_date
   * @return
   * @throws ParseException
   */
  @PutMapping("/charge_user/{inp_no}/{ord_no}/{user_id}/{inp_date}")
  public ResponseEntity<Void> updateChargeUser(
    @PathVariable("inp_no") Integer inp_no,
    @PathVariable("ord_no") Long ord_no,
    @PathVariable("user_id") Long user_id,
    @PathVariable(name = "inp_date", required = false) String inp_date) throws ParseException {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API PUT CALLED = " + inp_no + " " + ord_no + " " + user_id + " " + inp_date);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (ord_no <= 0 || user_id <= 0) {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }

    if (inp_date.equals("null") == false) {
      Timestamp inpTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(inp_date).getTime());
      inp_date = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX").format(inpTime);
    }

    int ret;
    ret = comsvOrdMainService.updateChargeUser(inp_no, ord_no, user_id, inp_date);
    eventLogMessage.setLogMessage("updateChargeUser = " + ret + " " + inp_date);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (ret > 0) {
      return ResponseEntity.ok().build();
    } else {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }

  /**
   * 通信サーバ用治療情報の登録（患者未登録運転開始）
   * @param ord_no
   * @param machine_no
   * @param dial_state
   * @param start_date
   * @return
   * @throws ParseException
   */
  @PutMapping("/unregistered/{facility_cd}/{machine_no}/{machine_status}/{dial_state}/{start_date}")
  public ResponseEntity<Void> insertUnregisteredPat(
    @PathVariable(name = "facility_cd", required = false) String facility_cd,
    @PathVariable("machine_no") Long machine_no,
    @PathVariable("machine_status") Integer machine_status,
    @PathVariable(name = "dial_state", required = false) String dial_state,
    //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
    //  @PathVariable(name = "start_date", required = false) String start_date) throws ParseException {
    @PathVariable(name = "start_date", required = false) String start_date) throws ParseException, IOException {
    //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API PUT CALLED = " + facility_cd + " " + machine_no + " " + start_date);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    ComsvOrdMain comsv = new ComsvOrdMain();
    comsv.setFacilityCd(facility_cd);
    comsv.setRstMachineNo(machine_no);
    comsv.setDialState(dial_state);
    comsv.setRstDialysisCnt(1);
    if (start_date.equals("null")) {
      comsv.setTreatDate(null);
      comsv.setStartDate(null);
    } else {
      Timestamp startTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(start_date).getTime());
      String treat_date = start_date.substring(0, 8);
      comsv.setTreatDate(treat_date);
      //日付チェック
      SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
      sdf.setLenient(false);
      sdf.parse(treat_date);
      //年・月を取得する
      int y = Integer.parseInt(treat_date.substring(0, 4));
      int m = Integer.parseInt(treat_date.substring(4, 6)) - 1;
      int d = Integer.parseInt(treat_date.substring(6, 8));
      //取得した年月の最終年月日を取得する
      Calendar cal = Calendar.getInstance();
      cal.set(y, m, d);
      //曜日を取得する
      //mod 外結障害通信サーバNo.18 劉 start
      int dayOfWeek = cal.get(Calendar.DAY_OF_WEEK);
      if (Calendar.SUNDAY == cal.getFirstDayOfWeek()) {
        dayOfWeek = dayOfWeek - 1;
        if (0 == dayOfWeek) {
          dayOfWeek = 7;
        }
      }
      comsv.setTreatWeek(dayOfWeek);
      //comsv.setTreatWeek(cal.get(Calendar.DAY_OF_WEEK));
      //mod 外結障害通信サーバNo.18 劉 end
      comsv.setStartDate(startTime);
    }
    int ret = comsvOrdMainService.insertUnregistered(machine_status, comsv);
    if (ret > 0) {
      return ResponseEntity.ok().build();
    } else {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }

  /**
   * 通信サーバ用治療情報の投与薬剤実施者更新
   * @param ord_no
   * @param user_id
   * @param effect_date
   * @return
   * @throws ParseException
   */
  @PutMapping("/rst_medi_user/{ord_no}/{user_id}/{effect_date}")
  public ResponseEntity<Void> updateRstMediInfoUser(
    @PathVariable("ord_no") Long ord_no,
    @PathVariable("user_id") Long user_id,
    @PathVariable(name = "effect_date", required = false) String effect_date) throws ParseException {

    if (ord_no <= 0 || effect_date.equals("null")) {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }

    Timestamp inpTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(effect_date).getTime());
    effect_date = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX").format(inpTime);

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("user_id = [" + user_id + "] effect_date = [" + effect_date + "]");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    int ret;
    ret = comsvOrdMainService.updateRstMediInfoUser(ord_no, user_id, effect_date);
    eventLogMessage.setLogMessage("updateRstMediInfoUser = " + ret);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (ret > 0) {
      return ResponseEntity.ok().build();
    } else {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }

  /**
   * 通信サーバ用治療情報の実績モニタ値更新
   * @param ord_no
   * @param body
   */
  @PostMapping("/rst_monitor/{ord_no}")
  public HttpStatus Response(
    @PathVariable("ord_no") Long ord_no,
    @RequestBody String body) throws ParseException {

    // 受信データJson形式なので一度クラスに格納
    ObjectMapper mapper = new ObjectMapper();
    MonitorData data;
    try {
      data = mapper.readValue(body, MonitorData.class);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("アプリ更新API応答：受け取った情報の変換処理に失敗" + e.getMessage());
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return HttpStatus.INTERNAL_SERVER_ERROR;
    }
    String strMon1 = null;
    String strMon2 = null;
    String strMon3 = null;
    String strMon4 = null;
    String strMon5 = null;
    String strMon6 = null;
    String strMon7 = null;
    if (false == StringUtils.isEmpty(data.mon1)) {
      strMon1 = data.mon1;
    }
    if (false == StringUtils.isEmpty(data.mon2)) {
      strMon2 = data.mon2;
    }
    if (false == StringUtils.isEmpty(data.mon3)) {
      strMon3 = data.mon3;
    }
    if (false == StringUtils.isEmpty(data.mon4)) {
      strMon4 = data.mon4;
    }
    if (false == StringUtils.isEmpty(data.mon5)) {
      strMon5 = data.mon5;
    }
    if (false == StringUtils.isEmpty(data.mon6)) {
      strMon6 = data.mon6;
    }
    if (false == StringUtils.isEmpty(data.mon7)) {
      strMon7 = data.mon7;
    }
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("アプリ更新応答API受信内容[mon1:" + strMon1 + " mon2:" + strMon2 + " mon3:" + strMon3 + " mon4:" + strMon4 + " mon5:"
      + strMon5 + " mon6:" + strMon6 + " mon7:" + strMon7 + "]");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    ComsvOrdMain comsv = new ComsvOrdMain();
    comsv.setOrdNo(ord_no); // オーダ番号
    comsv.setAddTotal(strMon1); // 除水積算値
    comsv.setRstBloodCirculate(strMon2); // 血液循環量
    comsv.setRstRunningTime(strMon3); // 透析運転時間
    comsv.setKtvMeasure(strMon4); // Kt/V（測定値）
    comsv.setRstKtv(strMon5); // Kt/V
    comsv.setAddWaterTotal(strMon6); // 補液量現在値
    comsv.setUfr(strMon7); // ＵＲＲ

    int ret;
    ret = comsvOrdMainService.updateRstMonitor(comsv);
    if (ret > 0) {
      return HttpStatus.OK;
    } else {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return HttpStatus.BAD_REQUEST;
      return HttpStatus.INTERNAL_SERVER_ERROR;
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }

  /**
   * 通信サーバ用治療情報の実績ログ測定値更新
   * @param log_type
   * @param ord_no
   * @param body
   */
  // mod 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- start
  //@PostMapping("/rst_logdata/{log_type}/{ord_no}")
  @PostMapping("/rst_logdata/{facilitycd}/{machinetypecd}/{machineserial}/{log_type}/{ord_no}/{occurdatetime}")
  // mod 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- end
  public HttpStatus Response(
    // add 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- start
    @PathVariable("facilitycd") String facilitycd,
    @PathVariable("machinetypecd") String machinetypecd,
    @PathVariable("machineserial") String machineserial,
    // add 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- end
    @PathVariable("log_type") Integer log_type,
    @PathVariable("ord_no") Long ord_no,
    // add 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- start
    @PathVariable("occurdatetime") String occurdatetime,
    // add 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- end
    @RequestBody String body) throws ParseException {

    // log_no ログ種類
    //   1:再循環率測定
    //   2:プログラム補液引き残し量
    //   3:静的静脈圧
    //   4:IAP ratio

    // 受信データJson形式なので一度クラスに格納
    ObjectMapper mapper = new ObjectMapper();
    LogData data;
    try {
      data = mapper.readValue(body, LogData.class);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("アプリ更新API応答：受け取った情報の変換処理に失敗" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return HttpStatus.INTERNAL_SERVER_ERROR;
    }

    String strLog1 = "0";
    String strLog2 = "0";
    String strLog3 = "0";
    String strLog4 = "0";
    switch (log_type) {
      //1:再循環率測定
      case 1:
        if (false == StringUtils.isEmpty(data.log1)) {
          strLog1 = data.log1;
        }
        break;
      //2:プログラム補液引き残し量
      case 2:
        if (false == StringUtils.isEmpty(data.log1)) {
          strLog2 = data.log1;
        }
        break;
      //3:静的静脈圧
      case 3:
        if (false == StringUtils.isEmpty(data.log1)) {
          strLog3 = data.log1;
        }
        break;
      //4:IAP ratio
      case 4:
        if (false == StringUtils.isEmpty(data.log1)) {
          strLog4 = data.log1;
        }
        break;
      default:
        break;
    }
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("アプリ更新応答API受信内容[log1:" + strLog1 + " log2:" + strLog2 + " log3:" + strLog3 + " log4:" + strLog4 + "]");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    int ret = 0;
    ComsvOrdMain comsv = new ComsvOrdMain();
    comsv.setOrdNo(ord_no); // オーダ番号

    // mod 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- start
    //    if (log_type == 2) {
    //      // プログラム補液引き残し量
    //      comsv.setPullLeaveAmount(strLog1);
    //      ret = comsvOrdMainService.updatePullLeaveAmount(comsv);
    //    }
    String weight = comsvOrdMainService.selectWeightInfo(ord_no);
    OrdMainRstWeightInfo dto = null;
    try {
      dto = weight == null || weight.isEmpty() ? new OrdMainRstWeightInfo()
        : mapper.readValue(weight, OrdMainRstWeightInfo.class);
    } catch (IOException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessageNew = new EventLogMessage();
      if (facilitycd != null) {
        eventLogMessage.setFacilityCd(facilitycd);
      }
      eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }

    switch (log_type) {
      //1:再循環率測定
      case 1:
        if (false == StringUtils.isEmpty(strLog1)) {
          // ＃10847 2024.07.12 mod 登録する再循環率情報修正 TDC米沢 start
          // RecrclRt rec = new RecrclRt();
          // int elem_count = 0;
          //
          // if (dto.getRecrcl_rt() != null && !StringUtils.isEmpty(dto.getRecrcl_rt())) {
          //  // try {
          //   rec = dto.getRecrcl_rt();
          //   //rec = mapper.readValue(String.valueOf((Recrcl_rt)dto.getRecrcl_rt()), Recrcl_rt.class);
          //   elem_count = Integer.parseInt(rec.valid_no);
          //  // } catch (IOException e) {
          //  //   e.printStackTrace();
          //  // }
          // } else {
          //   elem_count = 0;
          // }
          //
          // //初期値の場合、recrcl_rtの値の無にする
          // //1件目データを登録時に、データブロック：No１の分のみ作成する、No2以降の分を作成しない。
          // //つまり、できる分のデータブロック分のみ作成する
          // //最大5件、6件目以降データが来るとき、登録しない
          // if (elem_count < 5 && elem_count >= 0) {
          //   RecrclRtElement elem = new RecrclRtElement();
          //   elem.rate = Double.parseDouble(strLog1);
          //   elem.datetime = occurdatetime;
          //   elem.comment = "";
          //   //mnt_machine_state.monitor_dataから「血流量」の値を取得
          //   MntMachineState state = new MntMachineState();
          //   state = mntMachineStateService.selectByKey(facilitycd, machinetypecd, machineserial);
          //   String monitorData = state.getMonitorData();
          //   JsonNode root = null;
          //   try {
          //     root = mapper.readTree(monitorData);
          //   } catch (IOException e) {
          //     e.printStackTrace();
          //   }
          //   //新通信 8 血流量
          //   // String bld_vl = String.valueOf(root.get("8"));
          //   // if (bld_vl != null && bld_vl.isEmpty() == false && bld_vl.equals("null") == false) {
          //   //   elem.bld_vl = Integer.valueOf(String.valueOf(root.get("8")));
          //   // } else {
          //   //   elem.bld_vl = 0;
          //   // }
          //   elem.bld_vl =
          //     root != null && root.hasNonNull("8") && StringUtils.hasText(root.get("8").asText())
          //     ? root.get("8").asInt() : 0;
          //
          //   switch (elem_count) {
          //     case 4:
          //       rec._5 = elem;
          //       rec.valid_no = "5";
          //       break;
          //     case 3:
          //       rec._4 = elem;
          //       rec.valid_no = "4";
          //       break;
          //     case 2:
          //       rec._3 = elem;
          //       rec.valid_no = "3";
          //       break;
          //     case 1:
          //       rec._2 = elem;
          //       rec.valid_no = "2";
          //       break;
          //     case 0:
          //       rec._1 = elem;
          //       rec.valid_no = "1";
          //       break;
          //     default:
          //       break;
          //   }
          //
          //   dto.setRecrcl_rt(rec);
          //
          // } else {
          //   EventLogMessage eventLogMessage1 = new EventLogMessage();
          //   eventLogMessage1.setLogMessage("最大5件、6件目以降データが来るとき、登録しない");
          //   logService.log(LogLevel.INFO, eventLogMessage1, null, SERVICE_NAME.REMS, null);
          // }

          // 登録する再循環率測定値作成
          RecrclRtElement elem = new RecrclRtElement();
          elem.rate = Double.parseDouble(strLog1);
          elem.comment = "";
          try{
            // yyyymmddHHMMss文字列からISO8601形式文字列への変換
            elem.datetime = DateTimeUtils.getDateString_iso8601(new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(occurdatetime).getTime()));
          } catch (Exception e) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
            EventLogMessage eventLogMessageNew = new EventLogMessage();
            if (facilitycd != null) {
              eventLogMessage.setFacilityCd(facilitycd);
            }
            eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
            logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
          }

          //mnt_machine_state.monitor_dataから「血流量」の値を取得
          MntMachineState state = new MntMachineState();
          state = mntMachineStateService.selectByKey(facilitycd, machinetypecd, machineserial);
          String monitorData = state.getMonitorData();
          JsonNode root = null;
          try {
            root = mapper.readTree(monitorData);
          } catch (IOException e) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
            EventLogMessage eventLogMessageNew = new EventLogMessage();
            if (facilitycd != null) {
              eventLogMessage.setFacilityCd(facilitycd);
            }
            eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
            logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
          }
          //新通信 8 血流量
          elem.bld_vl =
            root != null && root.hasNonNull("8") && StringUtils.hasText(root.get("8").asText())
            ? root.get("8").asInt() : null;

          // 再循環率登録
          dto.setRecrcl_rt(comsvOrdMainService.makeRecrclRt(dto.getRecrcl_rt(), elem));
          // ＃10847 2024.07.12 mod 登録する再循環率情報修正 TDC米沢 end
       }
        break;
      //2:プログラム補液引き残し量
      case 2:
        if (false == StringUtils.isEmpty(strLog2)) {
          // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 start
          // dto.setIhdf_pll(strLog2);
          dto.setIhdf_pll(new BigDecimal(strLog2));
          // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 end
        }
        break;
      //3:静的静脈圧
      case 3:
        if (false == StringUtils.isEmpty(strLog3)) {
          // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 start
          // dto.setSttc_vns_prssr(strLog3);
          dto.setSttc_vns_prssr(new BigDecimal(strLog3));
          // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 end
        }
        break;
      //4:IAP ratio
      case 4:
        if (false == StringUtils.isEmpty(strLog4)) {
          // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 start
          // dto.setIap_rt(strLog4);
          dto.setIap_rt(new BigDecimal(strLog4));
          // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 end
        }
        break;
      default:
        break;
    }

    try {
      ret = comsvOrdMainService.updateWeightInfo(ord_no, mapper.writeValueAsString(dto));
    } catch (JsonProcessingException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessageNew = new EventLogMessage();
      if (facilitycd != null) {
        eventLogMessage.setFacilityCd(facilitycd);
      }
      eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
    // mod 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- end

    if (ret > 0) {
      return HttpStatus.OK;
    } else {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return HttpStatus.BAD_REQUEST;
      return HttpStatus.INTERNAL_SERVER_ERROR;
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }

  /**
   * 通信サーバ用治療情報の投与薬剤実施更新
   * @param ord_no
   * @param effect_date
   * @param body
   */
  @PostMapping("/rst_medi/{ord_no}/{effect_date}")
  public HttpStatus Response(
    @PathVariable("ord_no") Long ord_no,
    @PathVariable(name = "effect_date", required = false) String effect_date,
    @RequestBody String body) throws ParseException {

    Timestamp inpTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(effect_date).getTime());
    effect_date = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX").format(inpTime);

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("body = [" + body + "] effect_date = [" + effect_date + "]");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    int ret;
    ret = comsvOrdMainService.updateRstMediInfo(ord_no, effect_date, body);
    eventLogMessage.setLogMessage("updateRstMediInfo = " + ret);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (ret > 0) {
      return HttpStatus.OK;
    } else {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return HttpStatus.BAD_REQUEST;
      return HttpStatus.INTERNAL_SERVER_ERROR;
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }

  /**
   * 通信サーバ用治療情報の愁訴処置情報更新
   * @param facility_cd
   * @param ord_no
   * @param occur_date
   * @param body
   */
  @PostMapping("/rst_comptreat/{facility_cd}/{ord_no}/{occur_date}")
  public HttpStatus Response(
    @PathVariable(name = "facility_cd", required = false) String facility_cd,
    @PathVariable("ord_no") Long ord_no,
    @PathVariable(name = "occur_date", required = false) String occur_date,
    @RequestBody String body) throws ParseException {

    //add 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
    List<Rst_Comptreat> treatlist = null;
    List<Rst_Complaint> complaintlist = null;
    int ctl_no_complaint= 0;
    int ctl_no_treat = 0;
    int ctl_no_max = 0;
    // mod 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 start
    // Rst_Comptreat last_treat = null;
    // Rst_Complaint last_comp = null;
    Optional<Rst_Comptreat>  last_treat = null;
    Optional<Rst_Complaint>  last_comp = null;
    List<Rst_Treat_Staff> treatstafflist = null;
    // Rst_Treat_Staff last_treatstaff = null;
    Optional<Rst_Treat_Staff> last_treatstaff = null;
    // mod 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 end
    int ctl_no_treatstaff = 0;
    //add 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("通信サーバ用治療情報の愁訴処置情報更新");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    // Timestamp inpTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(occur_date).getTime());
    //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
    //occur_date = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX").format(inpTime);
    // occur_date = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss").format(inpTime);
    ZonedDateTime input_date = null;
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSSXXX");
    if (occur_date == null || occur_date.isEmpty() || "null".equals(occur_date) == true) {
      input_date = ZonedDateTime.now();
      occur_date = input_date.format(formatter);
    } else {
      LocalDateTime localDateTime = LocalDateTime.parse(occur_date, DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
      input_date= localDateTime.atZone(ZoneId.of("Asia/Tokyo"));
      occur_date = input_date.format(formatter);
    }
    //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end
    eventLogMessage.setLogMessage("body = [" + body + "] occur_date = [" + occur_date + "]");
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    int ret;

    //add 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
    ComsvComplaintTreatment cct = comsvOrdMainService.selectRecentRstTreatmentInfo(ord_no);
    String strTrementInfo = cct.getRstTreatmentInfo();
    if (strTrementInfo != null) {
      ObjectMapper mapper = new ObjectMapper();
      try {
        treatlist = mapper.readValue(strTrementInfo, new TypeReference<List<Rst_Comptreat>>() {
        });
      } catch (Exception e) {
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("通信サーバ用治療情報の愁訴情報の変換処理に失敗" + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      }
    }

    String strComplaintInfo = cct.getRstComplaintInfo();
    if (strComplaintInfo != null) {
      ObjectMapper mapper = new ObjectMapper();
      try {
        complaintlist = mapper.readValue(strComplaintInfo, new TypeReference<List<Rst_Complaint>>() {
        });
      } catch (Exception e) {
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("通信サーバ用治療情報の処置情報の変換処理に失敗" + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      }
    }

    String strTreatStaffInfo = cct.getRstTreatStaffInfo();
    if (strTreatStaffInfo != null) {
      ObjectMapper mapper = new ObjectMapper();
      try {
        treatstafflist = mapper.readValue(strTreatStaffInfo, new TypeReference<List<Rst_Treat_Staff>>() {
        });
      } catch (Exception e) {
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("通信サーバ用治療情報の酸素吸入処置者情報の変換処理に失敗" + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      }
    }

    // mod 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 start
    if (complaintlist != null && 0 < complaintlist.size()) {
      last_comp = complaintlist.stream()
        .filter(item -> item.ctl_no != null)
        .max(Comparator.comparing(item -> item.ctl_no));
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //if(last_comp != null &&  last_comp.ctl_no!= null && last_comp.ctl_no.isEmpty()==false && last_comp.ctl_no.equals("null")==false) {
        //ctl_no_complaint=Integer.parseInt(last_comp.ctl_no);
      if (last_comp.isPresent()) {
        Rst_Complaint result = last_comp.get();
        ctl_no_complaint = Integer.parseInt(result.ctl_no.toString());
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      }
    }

    if (treatlist != null && 0 < treatlist.size()) {
      last_treat = treatlist.stream()
        .filter(item -> item.ctl_no != null)
        .max(Comparator.comparing(item -> item.ctl_no));
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //if(last_treat != null &&  last_treat.ctl_no!= null && last_treat.ctl_no.isEmpty()==false && last_treat.ctl_no.equals("null")==false) {
        //ctl_no_treat = Integer.parseInt(last_treat.ctl_no);
      if (last_treat.isPresent()) {
        Rst_Comptreat result = last_treat.get();
        ctl_no_treat = Integer.parseInt(result.ctl_no.toString());
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      }
    }

    if (treatstafflist != null && 0 < treatstafflist.size()) {
      last_treatstaff = treatstafflist.stream()
        .filter(item -> item.ctl_no != null)
        .max(Comparator.comparing(item -> item.ctl_no));
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //if(last_treatstaff != null &&  last_treatstaff.ctl_no!= null && last_treatstaff.ctl_no.isEmpty()==false && last_treatstaff.ctl_no.equals("null")==false) {
        //ctl_no_treatstaff = Integer.parseInt(last_treatstaff.ctl_no);
      if (last_treatstaff.isPresent()) {
        Rst_Treat_Staff result = last_treatstaff.get();
        ctl_no_treatstaff = Integer.parseInt(result.ctl_no.toString());
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      }
    }
    // mod 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 end

    ctl_no_max = ctl_no_complaint > ctl_no_treat ? ctl_no_complaint : ctl_no_treat;
    ctl_no_max = ctl_no_max > ctl_no_treatstaff ? ctl_no_max : ctl_no_treatstaff;

    //add 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end
    //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
    //ret = comsvOrdMainService.updateRstCompTreat(facility_cd, ord_no, occur_date, body);
    ret = comsvOrdMainService.updateRstCompTreat(facility_cd, ord_no, ctl_no_max + 1, ctl_no_max + 1, occur_date, body);
    //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end
    eventLogMessage.setLogMessage("updateRstMediInfo = " + ret);
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (ret > 0) {
      return HttpStatus.OK;
    } else {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return HttpStatus.BAD_REQUEST;
      return HttpStatus.INTERNAL_SERVER_ERROR;
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }

// add AWSとDEの通信断からの復旧 --趙-- start
  /**
   * 通信サーバ用治療情報の登録（AWSとDEの通信断からの復旧,患者未登録運転開始）
   * @param pat_id
   * @param facility_cd
   * @param machine_no
   * @return
   * @throws ParseException
   */
  @PutMapping("/unregistered_commfail/{pat_id}/{facility_cd}/{machine_no}/{start_date}")
  public ResponseEntity<Void> insertUnregisteredPatCommFail(
    @PathVariable(name = "pat_id", required = false) Long pat_id,
    @PathVariable(name = "facility_cd", required = false) String facility_cd,
    @PathVariable("machine_no") Long machine_no,
    @PathVariable(name = "start_date", required = false) String start_date) throws ParseException {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API PUT CALLED = " + facility_cd + " " + machine_no);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    ComsvOrdMain comsv = new ComsvOrdMain();
    comsv.setFacilityCd(facility_cd);
    comsv.setRstMachineNo(machine_no);
    comsv.setRstDialysisCnt(1);
    if (pat_id == 0)
      comsv.setPatId(null);
    else
      comsv.setPatId(pat_id);
    if (start_date.equals("null")) {
      comsv.setTreatDate(null);
      comsv.setStartDate(null);
    } else {
      Timestamp startTime = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(start_date).getTime());
      String treat_date = start_date.substring(0, 8);
      comsv.setTreatDate(treat_date);
      //日付チェック
      SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
      sdf.setLenient(false);
      sdf.parse(treat_date);
      //年・月を取得する
      int y = Integer.parseInt(treat_date.substring(0, 4));
      int m = Integer.parseInt(treat_date.substring(4, 6)) - 1;
      int d = Integer.parseInt(treat_date.substring(6, 8));
      //取得した年月の最終年月日を取得する
      Calendar cal = Calendar.getInstance();
      cal.set(y, m, d);
      //曜日を取得する
      //mod 外結障害通信サーバNo.18 劉 start
      int dayOfWeek = cal.get(Calendar.DAY_OF_WEEK);
      if (Calendar.SUNDAY == cal.getFirstDayOfWeek()) {
        dayOfWeek = dayOfWeek - 1;
        if (0 == dayOfWeek) {
          dayOfWeek = 7;
        }
      }
      comsv.setTreatWeek(dayOfWeek);
      //comsv.setTreatWeek(cal.get(Calendar.DAY_OF_WEEK));
      //mod 外結障害通信サーバNo.18 劉 end
      comsv.setStartDate(startTime);
    }
    int ret = comsvOrdMainService.insertUnregisteredCommFail(comsv);
    if (ret > 0) {
      return ResponseEntity.ok().build();
    } else {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }

  /**
   * 通信サーバ用治療情報の実績ログ測定値更新
   * @param log_type
   * @param ord_no
   * @param body
   */
  // mod 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- start
  //@PostMapping("/rst_logdata/{log_type}/{ord_no}")
  @PostMapping("/rst_logdata_commfail/{facilitycd}/{machinetypecd}/{machineserial}/{log_type}/{ord_no}/{occurdatetime}/{bld_vl}")
  // mod 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- end
  public HttpStatus Response(
    // add 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- start
    @PathVariable("facilitycd") String facilitycd,
    @PathVariable("machinetypecd") String machinetypecd,
    @PathVariable("machineserial") String machineserial,
    // add 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- end
    @PathVariable("log_type") Integer log_type,
    @PathVariable("ord_no") Long ord_no,
    // add 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- start
    @PathVariable("occurdatetime") String occurdatetime,
    // add 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- end
    @PathVariable("bld_vl") Integer bld_vl,
    @RequestBody String body) throws ParseException {

    // log_no ログ種類
    //   1:再循環率測定
    //   2:プログラム補液引き残し量
    //   3:静的静脈圧
    //   4:IAP ratio

    // 受信データJson形式なので一度クラスに格納
    ObjectMapper mapper = new ObjectMapper();
    LogData data;
    try {
      data = mapper.readValue(body, LogData.class);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("アプリ更新API応答：受け取った情報の変換処理に失敗" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return HttpStatus.INTERNAL_SERVER_ERROR;
    }

    String strLog1 = "0";
    String strLog2 = "0";
    String strLog3 = "0";
    String strLog4 = "0";
    if (false == StringUtils.isEmpty(data.log1)) {
      strLog1 = data.log1;
    }
    if (false == StringUtils.isEmpty(data.log2)) {
      strLog2 = data.log2;
    }
    if (false == StringUtils.isEmpty(data.log3)) {
      strLog3 = data.log3;
    }
    if (false == StringUtils.isEmpty(data.log4)) {
      strLog4 = data.log4;
    }
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("アプリ更新応答API受信内容[log1:" + strLog1 + " log2:" + strLog2 + " log3:" + strLog3 + " log4:" + strLog4 + "]");
    eventLogMessage.setFacilityCd(facilitycd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

    int ret = 0;
    ComsvOrdMain comsv = new ComsvOrdMain();
    comsv.setOrdNo(ord_no); // オーダ番号

    // mod 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- start
    //    if (log_type == 2) {
    //      // プログラム補液引き残し量
    //      comsv.setPullLeaveAmount(strLog1);
    //      ret = comsvOrdMainService.updatePullLeaveAmount(comsv);
    //    }
    String weight = comsvOrdMainService.selectWeightInfo(ord_no);
    OrdMainRstWeightInfo dto = null;
    try {
      dto = weight == null || weight.isEmpty() ? new OrdMainRstWeightInfo()
        : mapper.readValue(weight, OrdMainRstWeightInfo.class);
    } catch (IOException e) {
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessageNew = new EventLogMessage();
      if (facilitycd != null) {
        eventLogMessage.setFacilityCd(facilitycd);
      }
      eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }

    switch (log_type) {
      //1:再循環率測定
      case 1:
        if (false == StringUtils.isEmpty(strLog1)) {
          // ＃10847 2024.07.12 mod 登録する再循環率情報修正 TDC米沢 start
          // RecrclRt rec = new RecrclRt();
          // int elem_count = 0;
          //
          // if (dto.getRecrcl_rt() != null && !StringUtils.isEmpty(dto.getRecrcl_rt())) {
          //  // try {
          //   rec = dto.getRecrcl_rt();
          //   //rec = mapper.readValue(String.valueOf((Recrcl_rt)dto.getRecrcl_rt()), Recrcl_rt.class);
          //   elem_count = Integer.parseInt(rec.valid_no);
          //  // } catch (IOException e) {
          //  //   e.printStackTrace();
          //  // }
          // } else {
          //   elem_count = 0;
          // }
          //
          // //初期値の場合、recrcl_rtの値の無にする
          // //1件目データを登録時に、データブロック：No１の分のみ作成する、No2以降の分を作成しない。
          // //つまり、できる分のデータブロック分のみ作成する
          // //最大5件、6件目以降データが来るとき、登録しない
          // if (elem_count < 5 && elem_count >= 0) {
          //   RecrclRtElement elem = new RecrclRtElement();
          //   elem.rate = Double.parseDouble(strLog1);
          //   elem.datetime = occurdatetime;
          //   elem.comment = "";
          //
          //   //mnt_machine_state.monitor_dataから「血流量」の値を取得
          //  // MntMachineState state = new MntMachineState();
          //  // state = mntMachineStateService.selectByKey(facilitycd, machinetypecd, machineserial);
          //  // String monitorData = state.getMonitorData();
          //  // JsonNode root = null;
          //  // try {
          //  //   root = mapper.readTree(monitorData);
          //  // } catch (IOException e) {
          //  //   e.printStackTrace();
          //  // }
          //  // //新通信 8 血流量
          //  // String bld_vl = String.valueOf(root.get("8"));
          //  // if(bld_vl != null && bld_vl.isEmpty() == false && bld_vl.equals("null")==false){
          //  //   elem.bld_vl = Integer.valueOf(String.valueOf( root.get("8")));
          //  // }else{
          //  //   elem.bld_vl = 0;
          //  // }
          //   elem.bld_vl = bld_vl;
          //   switch (elem_count) {
          //     case 4:
          //       rec._5 = elem;
          //       rec.valid_no = "5";
          //       break;
          //     case 3:
          //       rec._4 = elem;
          //       rec.valid_no = "4";
          //       break;
          //     case 2:
          //       rec._3 = elem;
          //       rec.valid_no = "3";
          //       break;
          //     case 1:
          //       rec._2 = elem;
          //       rec.valid_no = "2";
          //       break;
          //     case 0:
          //       rec._1 = elem;
          //       rec.valid_no = "1";
          //       break;
          //     default:
          //       break;
          //   }
          //
          //   dto.setRecrcl_rt(rec);
          //
          // } else {
          //   EventLogMessage eventLogMessage1 = new EventLogMessage();
          //   eventLogMessage1.setLogMessage("最大5件、6件目以降データが来るとき、登録しない");
          //   logService.log(LogLevel.INFO, eventLogMessage1, null, SERVICE_NAME.REMS, null);
          // }

          // 登録する再循環率測定値作成
          RecrclRtElement elem = new RecrclRtElement();
          elem.rate = Double.parseDouble(strLog1);
          // yyyymmddHHMMss文字列からISO8601形式文字列への変換
          elem.datetime = DateTimeUtils.getDateString_iso8601(new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(occurdatetime).getTime()));
          elem.bld_vl = bld_vl;
          elem.comment = "";

          // 再循環率登録
          dto.setRecrcl_rt(comsvOrdMainService.makeRecrclRt(dto.getRecrcl_rt(), elem));
          // ＃10847 2024.07.12 mod 登録する再循環率情報修正 TDC米沢 end
        }
        break;
      //2:プログラム補液引き残し量
      case 2:
        if (false == StringUtils.isEmpty(strLog2)) {
          // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 start
          // dto.setIhdf_pll(strLog2);
          dto.setIhdf_pll(new BigDecimal(strLog2));
          // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 end
        }
        break;
      //3:静的静脈圧
      case 3:
        if (false == StringUtils.isEmpty(strLog3)) {
          // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 start
          // dto.setSttc_vns_prssr(strLog3);
          dto.setSttc_vns_prssr(new BigDecimal(strLog3));
          // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 end
        }
        break;
      //4:IAP ratio
      case 4:
        if (false == StringUtils.isEmpty(strLog4)) {
          // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 start
          // dto.setIap_rt(strLog4);
          dto.setIap_rt(new BigDecimal(strLog4));
          // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 end
        }
        break;
      default:
        break;
    }

    try {
      ret = comsvOrdMainService.updateWeightInfo(ord_no, mapper.writeValueAsString(dto));
    } catch (JsonProcessingException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessageNew = new EventLogMessage();
      eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
      if (facilitycd != null) {
        eventLogMessage.setFacilityCd(facilitycd);
      }
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
    // mod 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- end

    if (ret > 0) {
      return HttpStatus.OK;
    } else {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return HttpStatus.BAD_REQUEST;
      return HttpStatus.INTERNAL_SERVER_ERROR;
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }
  // add AWSとDEの通信断からの復旧 --趙-- end

  //add 通信サーバ用条件送信キャンセル 劉 start
  /**
   * 通信サーバ用条件送信キャンセル（AWSとDEの通信断からの復旧）
   * @param facilityCd    施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param ordNo         システムで管理する一意なオーダ番号
   * @return
   */
  @PutMapping("/cancelSendCond_commfail/{facilitycd}/{machinetypecd}/{machineserial}/{ordNo}")
  public ResponseEntity<Void> comsvCancelSendCondCommfail(
    @PathVariable("facilitycd") String facilityCd,
    @PathVariable("machinetypecd") String machineTypeCd,
    @PathVariable("machineserial") String machineSerial,
    @PathVariable("ordNo") Long ordNo) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("/cancelSendCond_commfail = " + facilityCd + " " + machineTypeCd + " " + machineSerial + " " + ordNo);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

    if (0 >= ordNo) {
      eventLogMessage.setLogMessage("comsvSendCondCancelCommfail実施終了:" + " " + ordNo);
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }

    int ret = comsvOrdMainService.cancelSendCondCommfail(facilityCd, machineTypeCd, machineSerial, ordNo);
    if (0 == ret) {
      eventLogMessage.setLogMessage("条件送信キャンセル成功");
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return ResponseEntity.ok().build();
    } else {
      eventLogMessage.setLogMessage("条件送信キャンセル失敗");
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }
  //add 通信サーバ用条件送信キャンセル 劉 end

  //add 実績：治療状況取得 劉 start
  /**
   * 実績：治療状況取得
   * @param ordNo システムで管理する一意なオーダ番号
   * @return
   */
  @GetMapping("/dialysis_state/{ordNo}")
  public ResponseEntity<?> comsvGetDialysisState(@PathVariable("ordNo") Long ordNo) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("/dialysis_state = " + ordNo);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

    ComsvOrdMainRstDialysisState res = new ComsvOrdMainRstDialysisState();
    if (0 >= ordNo) {
      eventLogMessage.setLogMessage("comsvGetDialysisState実施終了:" + " " + ordNo);
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

    String rstDialysisState = comsvOrdMainService.selectRstDialysisState(ordNo);
    res.setRstDialysisState(rstDialysisState);
    return new ResponseEntity<>(res, HttpStatus.OK);
  }
  //add 実績：治療状況取得 劉 end
}
