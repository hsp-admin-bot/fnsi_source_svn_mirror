package jp.co.nikkiso.ntss.web_api.web.rest;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import javax.validation.Valid;

import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.web_api.service.LogEventUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.web_api.service.ExamResultCalcUtilService;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

@RestController
@RequestMapping("util")
public class ExamResultCalcUtilResource {

  /**
   * 検査結果計算Service
   */
  @Autowired
  private ExamResultCalcUtilService examResultCalcUtilService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  @Autowired
  private PatExamMainDao patExamMainDao;

  /**
  * 検査結果計算処理.
  */
  @PostMapping("/updateExamResultCalc")
  public ResponseEntity<?> updateExamResultCalc(
    @Valid @RequestBody String bodydata
    ){

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "util" + "/updateExamResultCalc";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      JSONObject receiveData = new JSONObject(bodydata);
      JSONArray examMainCdArray = receiveData.getJSONArray("examMainCd");

      List<Long> examMainCd = new ArrayList<Long>();
      for(int idx = 0; idx < examMainCdArray.length(); idx++) {
        examMainCd.add(Long.parseLong(examMainCdArray.get(idx).toString()));
      }
      List<Long> recalculationExamItem = new ArrayList<Long>();
      examResultCalcUtilService.calculate(examMainCd, recalculationExamItem);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // 例外発生時、BAD_REQUESTを返す
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
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

  /**
   * 連携が成功した後 検査結果計算処理.
   */
  @PostMapping("/updateExamResultCalcForCoop")
  public ResponseEntity<?> updateExamResultCalcForCoop(
    @Valid @RequestBody String bodydata
  ){

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "util" + "/updateExamResultCalcForCoop";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      JSONObject receiveData = new JSONObject(bodydata);
      String patId = receiveData.getString("patId");

      List<PatExamMain> patExamMainList= patExamMainDao.selectPatExamMainByPatIdAndRegOrderClass(patId);

      if(patExamMainList.size()>0){
        List<Long> examMainCd = patExamMainList.stream().map(x->x.getExamMainCd()).collect(Collectors.toList());
        List<Long> recalculationExamItem = new ArrayList<Long>();
        examResultCalcUtilService.calculate(examMainCd, recalculationExamItem);
      }
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // 例外発生時、BAD_REQUESTを返す
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

}
