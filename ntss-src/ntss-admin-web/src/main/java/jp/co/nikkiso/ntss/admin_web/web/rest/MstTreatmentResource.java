package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.service.JournalService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.nextpat.NextPatService;
import jp.co.nikkiso.ntss.api.service.utils.InvokeResult;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatTreatmentPattern;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.mstTreatment.TreatmentService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;


/**
 * 治療方法マスタのResourceクラス.
 */
@RestController
@RequestMapping(Uri.MST_TREATMENT)
public class MstTreatmentResource {
	@Autowired
	private TreatmentService treatmentService;
	/**
	 * ログ出力Service.
	 */
	@Autowired
	LogService logService;

  // add bug 8099 修正 chen start
  @Autowired
  private JournalService journalService;
  // add bug 8099 修正 chen end

  /* del by gaojuncheng  2023-02-01 [CodeOptimization]  start */
//  @Autowired
//  private OrdMainDao ordMainDao;
  /* del by gaojuncheng  2023-02-01 [CodeOptimization]  end */

  //add #10412 次患者更新関連全体見直し対応 朴 start
  /**
   * 次患者更新関連
   */
  @Autowired
  private NextPatService nextPatService;
  //add #10412 次患者更新関連全体見直し対応 朴 end

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End
  // add 9664 by kangjie 20240222 start
  public static final String ADD_ROW_DATA_1 = "1";
  public static final String DEL_ROW_DATA_2 = "2";
  public static final String DEL_ROW_DATA_0 = "0";
  // add 9664 by kangjie 20240222 end

  // add 9664 by kangjie 20240515 start
  /**
  * @Author kangjie
  * @Description
  * @Date 2024/05/15 10:38
  * @Param [tratmentCd]
  * @return org.springframework.http.ResponseEntity<?>
  **/
  @GetMapping("/getMstTreatmentBycd/{tratmentCd}")
  public ResponseEntity<?> getMstTreatmentBycd(@PathVariable Integer tratmentCd) {
    if (tratmentCd == null) {
      return new ResponseEntity<>(new MstTreatment(), HttpStatus.OK);
    }
    MstTreatment treatment = treatmentService.selectByCd(tratmentCd);
    return new ResponseEntity<>(treatment, HttpStatus.OK);
  }
  // add 9664 by kangjie 20240515 end

  //  add #7327-治療方法マスタ操作時の動作がおかしい 徐博 start
  @GetMapping("/getOrdMainByCd/{indTreatmentCd}")
  public ResponseEntity<?> getOrdMainByCd(@PathVariable String indTreatmentCd) {
    int count = 0;
    try {
      count = treatmentService.getOrdMainByCd(indTreatmentCd);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
    return new ResponseEntity<>(count, HttpStatus.OK);
  }
  //  add #7327-治療方法マスタ操作時の動作がおかしい 徐博 end

  // add by zhaoqj 2023-03-29 [#8495] 解決フライアウト早期クローズと一括クエリーの変更 --start /
  @PostMapping("/getOrdMainByCds")
  public ResponseEntity<?> getOrdMainByCds(@RequestBody List<Integer> cdList) {
    Map<Integer,Integer> dataMap = new HashMap<Integer,Integer>();
    List<Integer> dataList = null;
    try {
      dataList = treatmentService.getOrdMainByCds(cdList);
      for (int i=0;i<dataList.size();i++){
        dataMap.put(cdList.get(i),dataList.get(i));
      }
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
    return new ResponseEntity<>(dataMap, HttpStatus.OK);
  }
  // add by zhaoqj 2023-03-29 [#8495] 解決フライアウト早期クローズと一括クエリーの変更 --end /

	/**
	 * IndCondInfoの更新
	 *
	 * @param facilityCd 施設コード
	 * @param request    マスタデータ更新のrequest
	 * @return
	 */
	@PutMapping("/updateTreatment/{facilityCd}")
	public ResponseEntity<?> updateTreatmentRecord(@PathVariable String facilityCd,
			@RequestBody List<Map<String, Object>> request, @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.MST_TREATMENT + "/updateTreatment";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_REPORT_MENU, BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

		// ログ出力
//		EventLogMessage eventLogMessage = new EventLogMessage();
//		eventLogMessage.setLogMessage("REST request to updateTreatmentRecord.");
//		logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
		List<Integer> treatmentCdList = new ArrayList<Integer>();
		Map<Integer, JSONObject> CondList = new HashMap<Integer, JSONObject>();
		for (Map<String, Object> mstTreatment : request) {
			try {
				if ((Integer) mstTreatment.get("code") >= 0) {
					treatmentCdList.add((Integer) mstTreatment.get("code"));
					CondList.put((Integer) mstTreatment.get("code"),
							(JSONObject) mstTreatment.get("treatmentConditionSetting"));
				}
			} catch (Exception e) {
				// TODO: handle exception
        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_REPORT_MENU, AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, e.getMessage());
        // wp アプリケーションログの適正化 Add End
			}
		}
		if (treatmentCdList.size() != 0) {
			try {

        /* del by gaojuncheng  2023-02-01 [CodeOptimization]  start */
//				treatmentService.updateOrdMain(facilityCd, treatmentCdList, CondList, ntssUser.getUserId());
//				treatmentService.updatePatTreatmentPattern(facilityCd, treatmentCdList, CondList, ntssUser.getUserId());
        /* del by gaojuncheng  2023-02-01 [CodeOptimization]  end */

        /* add by gaojuncheng  2023-02-01 [CodeOptimization]  start */
        treatmentService.updateTreatmentRecord(facilityCd, treatmentCdList, CondList, ntssUser);
        /* add by gaojuncheng  2023-02-01 [CodeOptimization]  end */
			} catch (Exception e) {
				// TODO: handle exception
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//              e.printStackTrace();
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//				eventLogMessage = new EventLogMessage();
//				eventLogMessage.setLogMessage(e.getMessage());
//				logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_CHECK_LIST, SERVICE_NAME.FNSI, null);
        // wp アプリケーションログの適正化 Add Start
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_REPORT_MENU, AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, ExcetionStackTraceToString(e));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
        // wp アプリケーションログの適正化 Add End
				return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
			}
		}

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_REPORT_MENU, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
     null);
    // wp アプリケーションログの適正化 Add End
		return new ResponseEntity<>(HttpStatus.OK);
	}

  // add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s start
  /**
   * IndCondInfoの更新補足
   *
   * @param request    必要パラメータの記載されたJson文字列
   * @return
   */
  @PostMapping("/updatetByTreatSetCdSup")
  public ResponseEntity<?> updatetByTreatSetCdSup(@RequestBody Map<String, Long> request) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.MST_TREATMENT + "/updatetByTreatSetCdSup";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_REPORT_MENU, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

//    // ログ出力
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("REST request to updatetByTreatSetCdSup.");
//    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);

    /* del by gaojuncheng  2023-01-31 [CodeOptimization]  start */
//    Boolean isUpdateReplenishLiquid = false;
//    Integer deviceMode = Math.toIntExact(request.get("deviceMode"));
//    Long oldDeviceMode = request.get("oldDeviceMode");
//    // 補液に透析液を同じ値を設定
//    if (
//      deviceMode.equals(AdminWebConstant.Treatment.DeviceMode.HD_AND_REPLACEMENT) ||
//        deviceMode.equals(AdminWebConstant.Treatment.DeviceMode.OHDF) ||
//        deviceMode.equals(AdminWebConstant.Treatment.DeviceMode.OHF) ||
//        deviceMode.equals(AdminWebConstant.Treatment.DeviceMode.I_HDF)
//    ) {
//      isUpdateReplenishLiquid = true;
//    }
//
//    List<Long> ordNoList = new ArrayList<Long>();
//    Long ordNo = request.get("ordNo");
//    if (ordNo != null) {
//      ordNoList.add(ordNo);
//    }
//
//    //　補液更新
//    ordMainDao.updateIndCondInfoWithTreatMethodNonReplenishSup(ordNoList, isUpdateReplenishLiquid, oldDeviceMode);
//    ordMainDao.updateIndCondInfoWithTreatMethodReplenishSup(ordNoList, isUpdateReplenishLiquid, oldDeviceMode);

    /* del by gaojuncheng  2023-01-31 [CodeOptimization]  end */

    /* add by gaojuncheng  2023-02-01 [CodeOptimization]  start */
    treatmentService.updatetByTreatSetCdSup(request);
    /* add by gaojuncheng  2023-02-01 [CodeOptimization]  end */

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_REPORT_MENU, AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(HttpStatus.OK);
  }
  // add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s end

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

  // add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s start
  /**
   * IndCondInfoの更新
   *
   * @param request    必要パラメータの記載されたJson文字列
   * @return
   */
  @PutMapping("/updateOrdMainForTreatment/{facilityCd}")
  public ResponseEntity<?> updateOrdMainForTreatment(@PathVariable String facilityCd,
       @RequestBody List<Map<String, Object>> request, @AuthenticationPrincipal NtssUser ntssUser) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.MST_TREATMENT + "/updateOrdMainForTreatment";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_REPORT_MENU, BEFORE_LOG_FLG_INFO, mappingUrl, null,null);
    // wp アプリケーションログの適正化 Add End

    //add #10412 次患者更新関連全体見直し対応 朴 start
    List<OrdMain> doCallNextPatOrdMainList = new ArrayList<>();
    List<JournalCreateRequestPayload> doCreateJournalCtlNoList = new ArrayList<>();
    //add #10412 次患者更新関連全体見直し対応 朴 end

    JSONObject data = new JSONObject("{}");
    ArrayList<Map> success = new ArrayList<>();
    ArrayList<OrdMain> error = new ArrayList<>();
    ArrayList<Map> patPatternSuccess = new ArrayList<>();
    ArrayList<PatTreatmentPattern> patPatternError = new ArrayList<>();
    try {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setFacilityCd(facilityCd);
        eventLogMessage.setLogMessage("治療マスタの治療条件変更に伴い、配布処理を開始します");
        logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
        for (Map treatment : request) {
            if (Objects.equals(treatment.get("operation").toString(),ADD_ROW_DATA_1)) {
              continue;
            }
            if (Objects.equals(treatment.get("operation").toString(),DEL_ROW_DATA_2) && Objects.equals(treatment.get("isDisp").toString(),DEL_ROW_DATA_0)) {
              continue;
            }
            InvokeResult<Map<String,List>> invokeResult = treatmentService.updateOrdMainForMstTreatment(facilityCd,treatment,ntssUser.getUserId(),ntssUser);
            Map<String,List> resultMap = invokeResult.getData();

            // Message
            ArrayList<Map> resultSuccess = (ArrayList<Map>) resultMap.get("success");
            ArrayList<OrdMain> resultError = (ArrayList<OrdMain>) resultMap.get("error");
            ArrayList<Map> resultPatPatternSuccess = (ArrayList<Map>) resultMap.get("patPatternSuccess");
            ArrayList<PatTreatmentPattern> resultPatPatternError =(ArrayList<PatTreatmentPattern>) resultMap.get("patPatternError");
            success.addAll(resultSuccess);
            error.addAll(resultError);
            patPatternSuccess.addAll(resultPatPatternSuccess);
            patPatternError.addAll(resultPatPatternError);

        //mod #10412 次患者更新関連全体見直し対応 朴 start

            // 次患者更新
            List<OrdMain> callNextPatOrdMainList = (ArrayList<OrdMain>) resultMap.get("callNextPatOrdMainList");
        doCallNextPatOrdMainList.addAll(callNextPatOrdMainList);

//        treatmentService.callSetNextPatInfo(facilityCd,callNextPatOrdMainList);

            // 治療方法マスタの中の装置モードの項目を変更した場合,外部連携イベントを送信する
            List<JournalCreateRequestPayload> ctlNoList = (ArrayList<JournalCreateRequestPayload>) resultMap.get("ctlNoList");
        doCreateJournalCtlNoList.addAll(ctlNoList);

//        journalService.callCreateJournalForCtrNo(ctlNoList);
        //mod #10412 次患者更新関連全体見直し対応 朴 end
        }

      //add #10412 次患者更新関連全体見直し対応 朴 start

      // 次患者情報１、次患者情報２にたいして変更が発生しているかをチェックし、次患者情報呼び出し統合処理を呼び出す
      // サービスの新しい次患者更新呼出統合処理を呼び出す
      nextPatService.CallNextPatChange(facilityCd, nextPatService.FilterNextPatInfo1or2ChangedForOrdMain(facilityCd, doCallNextPatOrdMainList));

      // 治療方法マスタの中の装置モードの項目を変更した場合,外部連携イベントを送信する
      journalService.callCreateJournalForCtrNo(doCreateJournalCtlNoList);
      //add #10412 次患者更新関連全体見直し対応 朴 end

        eventLogMessage.setLogMessage("配布処理完了しました（成功件数：" + (success.size() + patPatternSuccess.size()) + "、失敗件数：" + (error.size() + patPatternError.size()) + ")");
        logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
    data.put("success", success);
    data.put("error", error);
    data.put("patPatternSuccess", patPatternSuccess);
    data.put("patPatternError", patPatternError);
    return new ResponseEntity<>(data.toString(), null, HttpStatus.OK);
  }
  // add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s end
}
