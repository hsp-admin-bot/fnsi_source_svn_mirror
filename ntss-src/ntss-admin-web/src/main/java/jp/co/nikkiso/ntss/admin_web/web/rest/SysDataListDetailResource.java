package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.request.sysDataListDetail.GetTemplateValueRequest;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.sysDataListDetail.SysDataListDetailService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.entity.DataListAggregationParam;
import jp.co.nikkiso.ntss.core.entity.MstExamItem;
import jp.co.nikkiso.ntss.core.entity.MstWaterSurveyPointType;
import jp.co.nikkiso.ntss.core.entity.SysDataListCategory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.util.CollectionUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;

/**
 * データリストカテゴリ詳細のResourceクラス.
 */
@RestController
@RequestMapping(Uri.SYS_DATA_LIST_DETAIL)
public class SysDataListDetailResource {

  /**
   * データリストカテゴリ詳細Serviceインタフェース.
   */
  @Autowired
  private SysDataListDetailService sysDataListDetailService;

  @Autowired
  private LogService logService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  /**
   * マスタに表示用のデータリストカテゴリ詳細項目を取得
   * @param templateCd テンプレートコード
   * @return データリストカテゴリ詳細レスポンスリスト
   */
  @GetMapping("/getByTemplate/{templateCd}")
  public ResponseEntity<?> getItemForMasterDisplay(
    @PathVariable Integer templateCd,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SEND_PUSH + "/getByTemplate";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST , BEFORE_LOG_FLG_INFO, mappingUrl, null,
      templateCd);
    // wp アプリケーションログの適正化 Add End
    try {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        templateCd);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(sysDataListDetailService.getDataListItemDisplayMaster(templateCd, ntssUser.getFacilityCd()), HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_MULTI_PAT_LIST ,SERVICE_NAME.FNSI, null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),  FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * マスタに表示用のデータリストカテゴリ詳細項目を取得
   * @param templateCd テンプレートコード
   * @return データリストカテゴリ詳細レスポンスリスト
   */
  @GetMapping("/getByTemplate/{templateCd}/temp/{facilityCd}")
  public ResponseEntity<?> getItemForMasterDisplayByFacilityCd(
    @PathVariable Integer templateCd,
    @PathVariable(name = "facilityCd", required = true) String facilityCd,
    @AuthenticationPrincipal NtssUser ntssUser) {
    if (!hasFacilityAccess(ntssUser, facilityCd)) {
      // #11205 mod 20260421 start
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      // #11205 mod 20260421 end
    }


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SEND_PUSH + "/getByTemplate";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST , BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      templateCd);
    // wp アプリケーションログの適正化 Add End

    try {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
        templateCd);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(sysDataListDetailService.getDataListItemDisplayMaster(templateCd, facilityCd), HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_MULTI_PAT_LIST ,SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),  FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 該当機能に表示用のデータリストカテゴリ詳細項目を取得
   * @param layoutCd マルチ患者一覧レイアウトコード
   * @return データリストカテゴリ詳細レスポンスリスト
   */
  @GetMapping("/getByLayoutCd/{layoutCd}")
  public ResponseEntity<?> getItemForFunctionDisplay(
    @PathVariable Long layoutCd,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SEND_PUSH + "/getByLayoutCd";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST , BEFORE_LOG_FLG_INFO, mappingUrl, null,
      layoutCd);
    // wp アプリケーションログの適正化 Add End

    try {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        layoutCd);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(sysDataListDetailService.getDataListItemDisplayFuntion(layoutCd, ntssUser.getFacilityCd()), HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_MULTI_PAT_LIST ,SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),  FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou start
  /**
   * 該当機能に表示用のデータリストカテゴリ詳細項目を取得
   * @param templateCd マルチ患者一覧レイアウトコード
   * @return データリストカテゴリ詳細レスポンスリスト
   */
  @GetMapping("/getTemplateValue/{patIdList}/{startDate}/{endDate}/{templateCd}")
  public ResponseEntity<?> getTemplateValue(
    @PathVariable List<Long> patIdList,
    @PathVariable String startDate,
    @PathVariable String endDate,
    @PathVariable Integer templateCd,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SEND_PUSH + "/getTemplateValue";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST , BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(startDate, endDate,templateCd));
    // wp アプリケーションログの適正化 Add End

    try {
      Map<String, Object> map = sysDataListDetailService.getTemplateValue(patIdList, ntssUser.getFacilityCd(), startDate, endDate, templateCd);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(startDate, endDate,templateCd));
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(map, HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_MULTI_PAT_LIST ,SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),  FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  //No.7167 upd Paging Optimization runtime by ztc start
  /**
   * 該当機能に表示用のデータリストカテゴリ詳細項目を取得
   * @param templateCd マルチ患者一覧レイアウトコード
   * @return データリストカテゴリ詳細レスポンスリスト
   */
  @GetMapping("/getTemplateValue/{patIdList}/{startDate}/{endDate}/{templateCd}/{offset}")
  public ResponseEntity<?> getTemplateValue(
    @PathVariable List<Long> patIdList,
    @PathVariable String startDate,
    @PathVariable String endDate,
    @PathVariable Integer templateCd,
    @PathVariable Integer offset,
    @RequestParam(name = "isOnlyRst", required = true) Boolean isOnlyRst,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SEND_PUSH + "/getTemplateValue";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST , BEFORE_LOG_FLG_INFO,
      mappingUrl, null, Arrays.asList(startDate, endDate,templateCd));
    // wp アプリケーションログの適正化 Add End

    try {
      Map<String, Object> map = sysDataListDetailService.getTemplateValue(patIdList, ntssUser.getFacilityCd(), startDate,
        endDate, templateCd, offset, isOnlyRst);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(startDate, endDate,templateCd));
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(map, HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_MULTI_PAT_LIST ,SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),  FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
//No.7167 upd Paging Optimization runtime by ztc end

  /**
   * 該当機能に表示用のデータリストカテゴリ詳細項目を取得
   * @param templateCd マルチ患者一覧レイアウトコード
   * @return データリストカテゴリ詳細レスポンスリスト
   */
  @GetMapping("/getTitleName/{templateCd}")
  public ResponseEntity<?> getTitleName(@PathVariable Integer templateCd) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SEND_PUSH + "/getTitleName";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST , BEFORE_LOG_FLG_INFO, mappingUrl, null,
      templateCd);
    // wp アプリケーションログの適正化 Add End

    try {
      List<SysDataListCategory> titleName = sysDataListDetailService.getTitleName(templateCd);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        templateCd);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(titleName, HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_MULTI_PAT_LIST ,SERVICE_NAME.FNSI, null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),  FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  @GetMapping("/getInitData/{templateCd}/{facilityCd}")
  public ResponseEntity<?> getInitData(@PathVariable Integer templateCd, @PathVariable String facilityCd,
                                       @AuthenticationPrincipal NtssUser ntssUser) {
    if (!hasFacilityAccess(ntssUser, facilityCd)) {
      // #11205 mod 20260421 start
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      // #11205 mod 20260421 end
    }

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SEND_PUSH + "/getInitData";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST , BEFORE_LOG_FLG_INFO, mappingUrl, null,
      templateCd);
    // wp アプリケーションログの適正化 Add End
    try {
      Map<String, Object> initData = sysDataListDetailService.getInitData(templateCd, facilityCd);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        templateCd);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(initData, HttpStatus.OK);
    } catch (Exception e) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),  FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  @GetMapping("/getListData/{templateCd}/{facilityCd}/{startDate}/{endDate}")
  public ResponseEntity<?> getListData(@PathVariable Integer templateCd, @PathVariable String facilityCd,  @PathVariable String startDate,  @PathVariable String endDate,
                                       @AuthenticationPrincipal NtssUser ntssUser) {
    if (!hasFacilityAccess(ntssUser, facilityCd)) {
      // #11205 mod 20260421 start
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      // #11205 mod 20260421 end
    }

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SEND_PUSH + "/getListData";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST , BEFORE_LOG_FLG_INFO, mappingUrl, null,
      templateCd);
    // wp アプリケーションログの適正化 Add End
    try {
      Map<String, Object> listData = sysDataListDetailService.getListData(templateCd, facilityCd, startDate, endDate);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        templateCd);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(listData, HttpStatus.OK);
    } catch (Exception e) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),  FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou end
  /**
   * 各セルに表示するデータを取得
   * @param dataListDetailCd --データリスト詳細コード
   * @param type データキー
   * @param itemId
   * @return
   */
  @GetMapping("/cellResult")
  public ResponseEntity<?> getSysDataSetResult(
    @RequestParam(name = "dataListDetailCd", required = true) Long dataListDetailCd,
    @RequestParam(name = "itemId", required = true) Integer itemId,
    @RequestParam(name = "dateFrom", required = false) String dateFrom,
    @RequestParam(name = "dateTo", required = false) String dateTo,
    @RequestParam(name = "type", required = false) Integer type,
    @RequestParam(name = "kubun", required = false) Integer kubun,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SEND_PUSH + "/cellResult";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST , BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(dataListDetailCd, itemId,dateFrom,dateTo,type));
    // wp アプリケーションログの適正化 Add End


    // sys_data_listリストのレスポンス生成
    Map<String, Object> dataKey = new HashMap<String, Object>();
    dataKey.put("id", itemId);
    dataKey.put("facilityCd", ntssUser.getFacilityCd());
    if (dateFrom != null) {
      dataKey.put("dateFrom", dateFrom);
    }
    if (dateTo != null) {
      dataKey.put("dateTo", dateTo);
    }
    if (type != null) {
      dataKey.put("type", type);
    }
    /*add FNSI-改修内容データリスト 任 start*/
    if(itemId!=null){
      dataKey.put("itemId", itemId);
    }
    if(kubun!=null){
      dataKey.put("kubun", kubun);
    }
    /*add FNSI-改修内容データリスト 任 end*/
    try {
      Object res = sysDataListDetailService.getCellData(dataListDetailCd, dataKey);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(dataListDetailCd, itemId,dateFrom,dateTo,type));
      // wp アプリケーションログの適正化 Add End
      // レスポンス作成
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_MULTI_PAT_LIST ,SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),  FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
    }

  }

  /* add by zhaohan 2022-11-16 [6543] 集計のテンプレートを表示すると、DBへの負荷がかかる。 --start */
  /**
   * 各行に表示するデータを取得
   * @param dataListDetailCd --データリスト詳細コード
   * @param type データキー
   * @param itemId
   * @return
   */
  @GetMapping("/rowResult")
  public ResponseEntity<?> getRowSysDataSetResult(
    @RequestParam(name = "dataListDetailCd", required = true) Long dataListDetailCd,
    @RequestParam(name = "itemId", required = true) Integer itemId,
    @RequestParam(name = "dateFrom", required = false) String dateFrom,
    @RequestParam(name = "dateTo", required = false) String dateTo,
    @RequestParam(name = "type", required = false) Integer type,
    @RequestParam(name = "kubun", required = false) Integer kubun,
    @AuthenticationPrincipal NtssUser ntssUser) {

    String mappingUrl = Uri.SEND_PUSH + "/rowResult";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST , BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(dataListDetailCd, itemId,dateFrom,dateTo,type));

    // sys_data_listリストのレスポンス生成
    Map<String, Object> dataKey = new HashMap<String, Object>();
    dataKey.put("id", itemId);
    dataKey.put("facilityCd", ntssUser.getFacilityCd());
    if (dateFrom != null) {
      dataKey.put("dateFrom", dateFrom);
    }
    if (dateTo != null) {
      dataKey.put("dateTo", dateTo);
    }
    if (type != null) {
      dataKey.put("type", type);
    }

    if(itemId!=null){
      dataKey.put("itemId", itemId);
    }
    if(kubun!=null){
      dataKey.put("kubun", kubun);
    }

    try {
      Object res = sysDataListDetailService.getRowData(dataListDetailCd, dataKey);

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(dataListDetailCd, itemId,dateFrom,dateTo,type));

      // レスポンス作成
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),  FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
    }
  }
  /* add by zhaohan 2022-11-16 [6543] 集計のテンプレートを表示すると、DBへの負荷がかかる。 --end */

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
  /*add FNSI-改修内容5237 任 start*/
  @GetMapping("/getFigureValue/{facilityCd}")
  public ResponseEntity<?> getFigureValue( @PathVariable String facilityCd,
                                           @AuthenticationPrincipal NtssUser ntssUser){
    if (!hasFacilityAccess(ntssUser, facilityCd)) {
      // #11205 mod 20260421 start
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      // #11205 mod 20260421 end
    }

    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.SEND_PUSH + "/getFigureValue/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST ,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd));
    // add FNSi5712アプリケーションログが出力しない 周 End
    try {
      List<MstExamItem> mstExamItemList = sysDataListDetailService.getFigureValue(facilityCd);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd));
      // add FNSi5712アプリケーションログが出力しない 周 End
      return new ResponseEntity<>(mstExamItemList, HttpStatus.OK);
    } catch (Exception e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),  FUNCTION_CODE.FUNC_MULTI_PAT_LIST,
        AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // add FNSi5712アプリケーションログが出力しない 周 End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  @GetMapping("/getDecimalValue/{facilityCd}")
  public ResponseEntity<?> getDecimalValue( @PathVariable String facilityCd,
                                            @AuthenticationPrincipal NtssUser ntssUser){
    if (!hasFacilityAccess(ntssUser, facilityCd)) {
      // #11205 mod 20260421 start
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      // #11205 mod 20260421 end
    }

    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.SEND_PUSH + "/getDecimalValue/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST ,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd));
    // add FNSi5712アプリケーションログが出力しない 周 End
    try {
      List<MstWaterSurveyPointType> mstWaterSurveyTypeList = sysDataListDetailService.getDecimalValue(facilityCd);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd));
      // add FNSi5712アプリケーションログが出力しない 周 End
      return new ResponseEntity<>(mstWaterSurveyTypeList, HttpStatus.OK);
    } catch (Exception e) {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),  FUNCTION_CODE.FUNC_MULTI_PAT_LIST,
        AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // add FNSi5712アプリケーションログが出力しない 周 End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  /*add FNSI-改修内容5237 任 end*/
  private boolean hasFacilityAccess(NtssUser ntssUser, String facilityCd) {
    return ntssUser != null && (ntssUser.isNkkAdminUser() || facilityCd == null || facilityCd.equals(ntssUser.getFacilityCd()));
  }

  // add #11718 【#11600持ち越し】データリスト画面不正② fang start
  /**
   * 各行に表示するデータを取得
   * @param dataListDetailCd --データリスト詳細コード
   * @param type データキー
   * @param itemId
   * @return
   */
  @PostMapping("/rowResult")
  public ResponseEntity<?> getRowSysDataSetResultNew(
    @RequestBody List<DataListAggregationParam> params,
    @AuthenticationPrincipal NtssUser ntssUser) {

    String mappingUrl = Uri.SEND_PUSH + "/rowResult";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST , BEFORE_LOG_FLG_INFO, mappingUrl, null,
      params);

    // sys_data_listリストのレスポンス生成
    try {
      List<Object> resultList = new ArrayList<>();
      if(!CollectionUtils.isEmpty(params)) {
        Map<String, List<DataListAggregationParam>> groupMap = new HashMap<>();
        for(DataListAggregationParam paramInfo : params) {
          String mapKey = paramInfo.getDataListDetailCd().toString()
            + (paramInfo.getType() != null ? paramInfo.getType() : "")
            + (paramInfo.getKubun() != null ? paramInfo.getKubun() : "");
          if(groupMap.containsKey(mapKey)) {
            groupMap.get(mapKey).add(paramInfo);
          } else {
            List<DataListAggregationParam> tempList = new ArrayList<>();
            tempList.add(paramInfo);
            groupMap.put(mapKey, tempList);
          }
        }
        resultList = sysDataListDetailService.getRowDataNew(ntssUser.getFacilityCd(), groupMap);
      }
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        params);

      // レスポンス作成
      return new ResponseEntity<>(resultList, HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),  FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
    }
  }
  // add #11718 【#11600持ち越し】データリスト画面不正② fang end

  // add #11895 データリスト「治療予定・実績」テンプレート恒久対応 fang start
  /**
   * 該当機能に表示用のデータリストカテゴリ詳細項目を取得（POST、患者IDリストをボディで受け取る）
   */
  @PostMapping("/getTemplateValueForTreatmentRecord")
  public ResponseEntity<?> getTemplateValuePost(
    @RequestBody GetTemplateValueRequest request,
    @AuthenticationPrincipal NtssUser ntssUser) {

    String mappingUrl = Uri.SEND_PUSH + "/getTemplateValueForTreatmentRecord";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(request.getStartDate(), request.getEndDate(), request.getTemplateCd()));

    try {
      Map<String, Object> map;
      if (request.getOffset() != null) {
        map = sysDataListDetailService.getTemplateValue(request.getPatIdList(), ntssUser.getFacilityCd(), request.getStartDate(),
          request.getEndDate(), request.getTemplateCd(), request.getOffset(), request.getIsOnlyRst());
      } else {
        map = sysDataListDetailService.getTemplateValue(request.getPatIdList(), ntssUser.getFacilityCd(), request.getStartDate(),
          request.getEndDate(), request.getTemplateCd());
      }

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(request.getStartDate(), request.getEndDate(), request.getTemplateCd()));
      return new ResponseEntity<>(map, HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  // add #11895 データリスト「治療予定・実績」テンプレート恒久対応 fang end

}
