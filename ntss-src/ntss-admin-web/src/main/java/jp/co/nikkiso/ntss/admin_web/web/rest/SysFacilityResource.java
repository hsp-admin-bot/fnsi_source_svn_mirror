package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.sysFacility.SysFacilityService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.entity.SysFacility;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 *@ClassName： SysFacilityResource
 *@Decscript: iPhone側のメモリが大きいためにシステムが登録されている問題を処理する、新しいインタフェース
 *@Author: chamaojia
 *@Date: 2025/05/21
 */
@RestController
@RequestMapping(AdminWebConstant.Uri.SYS_FACILITY)
public class SysFacilityResource {
  @Autowired
  SysFacilityService sysFacilityService;
  @Autowired
  LogEventUtils logEventUtils;
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

  /**
   * @MethodName:  getSysFacilityByCd
   * @Description: プライマリ・キーからsysFacilityを取得するには
   * @author: chamaojia
   * @date:  2025/05/21
   */
  @GetMapping("/getSysFacilityByCd/{cd}")
  public ResponseEntity<?> getSysFacilityByCd(@PathVariable String cd){
    String mappingUrl = AdminWebConstant.Uri.SYS_FACILITY + "/getSysFacilityByCd";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_MULTI_PAT_LIST ,
      BEFORE_LOG_FLG_INFO, mappingUrl, null,cd);
    try {
      SysFacility sysFacility = sysFacilityService.getSysFacilityByCd(cd);
      return new ResponseEntity<>(sysFacility, HttpStatus.OK);
    }catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, null,ExcetionStackTraceToString(e));
      return new ResponseEntity<>(ExcetionStackTraceToString(e),HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * @MethodName:  getSysFacilityByCdList
   * @Description: プライマリ・キー・コレクションからsysFacilityを取得するには
   * @author: chamaojia
   * @date:  2025/05/21
   */
  @PostMapping("/getSysFacilityByCdList")
  public ResponseEntity<?> getSysFacilityByCdList(@RequestBody List<String> cdList) {
    String mappingUrl = AdminWebConstant.Uri.SYS_FACILITY + "/getSysFacilityByCd";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_MULTI_PAT_LIST ,
      BEFORE_LOG_FLG_INFO, mappingUrl, null,null);
    try {
      List<SysFacility> sysFacilityList = sysFacilityService.getSysFacilityByCdList(cdList);
      return new ResponseEntity<>(sysFacilityList, HttpStatus.OK);
    }catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, null,ExcetionStackTraceToString(e));
      return new ResponseEntity<>(ExcetionStackTraceToString(e),HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * @MethodName:  getSysFacilityByFacilityCd
   * @Description: 設定cdからsysFacilityを取得し、オブジェクトを返します
   * @author: chamaojia
   * @date:  2025/05/21
   */
  @GetMapping("/getSysFacilityByFacilityCd/{facilityCd}")
  public ResponseEntity<?> getSysFacilityByFacilityCd(@PathVariable String facilityCd){
    String mappingUrl = AdminWebConstant.Uri.SYS_FACILITY + "/getSysFacilityByFacilityCd";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_MULTI_PAT_LIST ,
      BEFORE_LOG_FLG_INFO, mappingUrl, null,facilityCd);
    try {
      SysFacility sysFacility = sysFacilityService.getSysFacilityByFacilityCd(facilityCd);
      return new ResponseEntity<>(sysFacility, HttpStatus.OK);
    }catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_MULTI_PAT_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, null,ExcetionStackTraceToString(e));
      return new ResponseEntity<>(ExcetionStackTraceToString(e),HttpStatus.BAD_REQUEST);
    }

  }
}
