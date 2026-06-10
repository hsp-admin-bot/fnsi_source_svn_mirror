package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.admin_web.service.MstInfoService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.core.entity.MstMenteLayoutGroupByMachineType;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.mente.MstMenteLayoutGroupService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.entity.MstMenteLayoutGroup;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import lombok.extern.slf4j.Slf4j;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

/**
 * 検査レイアウトグループのResourceクラス.
 */
@Slf4j
@RestController
@RequestMapping(Uri.MENTE_LAYOUT_GROUP)
public class MstMenteLayoutGroupResource {

  /**
   * 検査レイアウトグループのServiceインタフェース.
   */
  @Autowired
  MstMenteLayoutGroupService mstMenteLayoutGroupService;
  @Autowired
  private MstInfoService mstInfoService;

  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;
  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  /**
   * すべての検査レイアウトグループを取得
   *
   * @param user NTSS認証ユーザ
   * @return 検査レイアウト一覧
   */
  @GetMapping("get-all")
  public ResponseEntity<List<MstMenteLayoutGroup>> getAllLayoutGroup(@AuthenticationPrincipal NtssUser user) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.MENTE_LAYOUT_GROUP + "/get-all";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    List<MstMenteLayoutGroup> res = new ArrayList<>();
    try {
      final String facilityCd = user.getFacilityCd();
      res = mstMenteLayoutGroupService.getAllLayoutGroup(facilityCd);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_INDICATION, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_INDICATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  //add 吉 start
  @GetMapping("get-layout-all")
  public ResponseEntity<Map<String,Object>> getAllLayout(@AuthenticationPrincipal NtssUser user) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.MENTE_LAYOUT_GROUP + "/get-layout-all";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    Map<String,Object> res = new HashMap<String,Object>();
    try {
      final String facilityCd = user.getFacilityCd();
      res = mstMenteLayoutGroupService.getAllLayout(facilityCd);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_INDICATION, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_INDICATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  //add 吉 end
//add FNSI-8013 定期点検でマスタで設定した機種に該当しない定期点検が作成できる 2022/10/27　周安寧 start
    /**
   * 対象機種のレイアウトグループ情報取得
   *
   * @param facilityCd 施設コード
   * @return 検査レイアウト一覧
   */
  @GetMapping("get-layout-machineType")
  public ResponseEntity<List<MstMenteLayoutGroupByMachineType>> getAllLayoutGroupByMachineType(@AuthenticationPrincipal NtssUser user) {
    String mappingUrl = Uri.MENTE_LAYOUT_GROUP + "/get-layout-machineType";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    try {
      final String facilityCd = user.getFacilityCd();
      List<MstMenteLayoutGroupByMachineType> res = mstMenteLayoutGroupService.getAllLayoutGroupByMachineType(facilityCd);
      MstSelector mstSelector = mstInfoService.findMstSelectorByMstName(facilityCd, "mst_mainte_layout_group");
      List<MstMenteLayoutGroupByMachineType> sortedData = new ArrayList<>();
      List<String> sortedCodes = new ArrayList<String>();
      if(mstSelector != null) {
	      sortedCodes = mstSelector.getOrderSettings().getItems()
	              .stream().map(e -> e.getCode().toString()).collect(Collectors.toList());
	      for (String sortedCode : sortedCodes) {
	        for (MstMenteLayoutGroupByMachineType item : res) {
	          if (sortedCode.equals(item.getMainteLayoutGroupCd())) {
	            sortedData.add(item);
	          }
	        }
	      }
      }
      res = sortedData;
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_INDICATION, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
        null);
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_INDICATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
//add FNSI-8013 定期点検でマスタで設定した機種に該当しない定期点検が作成できる 2022/10/27　周安寧 end
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
