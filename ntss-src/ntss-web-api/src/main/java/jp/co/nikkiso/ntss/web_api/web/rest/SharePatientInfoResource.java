package jp.co.nikkiso.ntss.web_api.web.rest;

import java.util.ArrayList;
import java.util.List;

import javax.validation.Valid;

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

import jp.co.nikkiso.ntss.web_api.service.FacilityCancelService;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 患者共有のResourceクラス.
 */
@RestController
@RequestMapping("util")
public class SharePatientInfoResource {

  @Autowired
  private FacilityCancelService facilityCancelService;
  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  /**
   * 患者情報共有の解除処理
   *
   * @param request  解除する施設コードリスト
   * @return
   */
  @PostMapping("/cancelSharePatientInfo")
  public ResponseEntity<?> cancelSharePatientInfo(
    @Valid @RequestBody String request
    ) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "/util" + "/cancelSharePatientInfo";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      JSONObject receiveData = new JSONObject(request);
      JSONArray facilityCdArray = receiveData.getJSONArray("facilityCdList");
      List<String> facilityCdList = new ArrayList<String>();

      for(int i = 0; i < facilityCdArray.length(); i++) {
        facilityCdList.add(facilityCdArray.get(i).toString());
      }

      facilityCancelService.cancelSharePatientInfo(facilityCdList);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End


      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // 例外発生時、BAD_REQUESTを返す

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
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
}
