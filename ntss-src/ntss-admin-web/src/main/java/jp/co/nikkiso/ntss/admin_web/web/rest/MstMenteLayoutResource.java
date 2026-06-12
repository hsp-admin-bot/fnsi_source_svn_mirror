package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.apache.commons.collections4.map.HashedMap;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.mente.MstMenteLayoutService;
import jp.co.nikkiso.ntss.core.entity.DevMenteMain;
import jp.co.nikkiso.ntss.core.entity.MstMachineType;
import jp.co.nikkiso.ntss.core.entity.MstMenteLayout;
import lombok.extern.slf4j.Slf4j;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;


/**
 * 検査レイアウトのResourceクラス.
 */
@Slf4j
@RestController
@RequestMapping(Uri.MENTE_LAYOUT)
public class MstMenteLayoutResource {

  /**
   * 検査レイアウトのServiceインタフェース.
   */
  @Autowired
  MstMenteLayoutService mstMenteLayoutService;

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
   * 日常点検画面で表示するレイアウトリストを取得
   *
   * @param user NTSS認証ユーザ
   * @param mainteDate 点検日（YYYY-MM-DD）
   * @return レイアウトリスト
   */
  @GetMapping("daily/show-layout")
  public ResponseEntity<List<MstMenteLayout>> getDailyLayoutListWithDate(
    @AuthenticationPrincipal NtssUser user,
    @RequestParam(name = "mainteDate", required = true) String mainteDate
  ) {
    String mappingUrl = Uri.MENTE_LAYOUT;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      FUNCTION_CODE.FUNC_DAILY_CHECK, BEFORE_LOG_FLG_INFO,
      mappingUrl, null, mainteDate);

    try {
      final String facilityCd = user.getFacilityCd();
      List<MstMenteLayout> res = mstMenteLayoutService
        .getDailyLayoutListWithDate(facilityCd, mainteDate);

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        FUNCTION_CODE.FUNC_DAILY_CHECK, AFTER_LOG_FLG_INFO,
        mappingUrl, null, mainteDate);
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        FUNCTION_CODE.FUNC_DAILY_CHECK, AFTER_LOG_FLG_ERROR,
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        mappingUrl, null, ExcetionStackTraceToString(e));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 指定のグループを持つ日常点検用レイアウトリストを取得
   *
   * @param user NTSS認証ユーザ
   * @param mainteCategoryCd 点検グループコード
   * @return レイアウトリスト
   */
  @GetMapping("daily/category-layout")
  public ResponseEntity<List<MstMenteLayout>> getDailyLayoutListWithCategoryCd(
    @AuthenticationPrincipal NtssUser user,
    @RequestParam(name = "mainteCategoryCd", required = true) Long mainteCategoryCd
  ) {
    String mappingUrl = Uri.MENTE_LAYOUT;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      FUNCTION_CODE.FUNC_DAILY_CHECK, BEFORE_LOG_FLG_INFO,
      mappingUrl, null, mainteCategoryCd);

    try {
      final String facilityCd = user.getFacilityCd();
      List<MstMenteLayout> res = mstMenteLayoutService
        .getDailyLayoutListWithCategoryCd(facilityCd, mainteCategoryCd);

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        FUNCTION_CODE.FUNC_DAILY_CHECK, AFTER_LOG_FLG_INFO,
        mappingUrl, null, mainteCategoryCd);
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        FUNCTION_CODE.FUNC_DAILY_CHECK, AFTER_LOG_FLG_ERROR,
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        mappingUrl, null, ExcetionStackTraceToString(e));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  // add #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe start
  /**
   * クラスごとにレイアウトリストを取得
   *
   * @param user    NTSS認証ユーザ
   * @param layoutClass レイアウトのタイプ
   * @param facilityCd 問い合わせが必要な施設
   * @return レイアウトリスト
   */
  @GetMapping("/{facilityCd}/{layoutClass}")
  public ResponseEntity<List<MstMenteLayout>> getLayoutListByLayoutClass(
    @AuthenticationPrincipal NtssUser user,
    @PathVariable(name = "facilityCd", required = true) String facilityCd,
    @PathVariable(name = "layoutClass", required = true) String layoutClass
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie start
    if(!user.isNkkAdminUser()) {
        if (facilityCd != null && !facilityCd.isEmpty() &&
            !facilityCd.equals(user.getFacilityCd())) {
            String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + user.getFacilityCd() + " " + "facilityCd=" + facilityCd + " " + "layoutClass=" + layoutClass + " ";
            InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie end

    String mappingUrl = Uri.MENTE_LAYOUT ;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, BEFORE_LOG_FLG_INFO, mappingUrl, user.getFacilityCd(),
      layoutClass);

    List<MstMenteLayout> res = new ArrayList<>();
    try {
      res = mstMenteLayoutService.getLayoutsListByClass(facilityCd, layoutClass);

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, AFTER_LOG_FLG_INFO, mappingUrl, user.getFacilityCd(),
        layoutClass);
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, AFTER_LOG_FLG_ERROR, mappingUrl, user.getFacilityCd(), ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  // add #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe end

  /**
   * クラスごとにレイアウトリストを取得
   *
   * @param layoutClass レイアウトのタイプ
   * @return レイアウトリスト
   */
  @GetMapping("/{layoutClass}/data/{facilityCd}")
  public ResponseEntity<List<MstMenteLayout>> getLayoutListByLayoutClassAndFacilityCd(
    @PathVariable(name = "layoutClass", required = true) String layoutClass,
    @PathVariable(name = "facilityCd", required = true) String facilityCd,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie end
) {
      // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
          if (facilityCd != null && !facilityCd.isEmpty() &&
              !facilityCd.equals(ntssUser.getFacilityCd())) {
              String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " " + "layoutClass=" + layoutClass + " ";
              InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
              return new ResponseEntity<>(HttpStatus.FORBIDDEN);
          }
      }
      // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.MENTE_LAYOUT + "/data" ;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      layoutClass);
    // wp アプリケーションログの適正化 Add End
    List<MstMenteLayout> res = new ArrayList<>();
    try {
      res = mstMenteLayoutService.getLayoutsListByClass(facilityCd, layoutClass);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
        layoutClass);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setSqlIdentification(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, SERVICE_NAME.FNSI, facilityCd);

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang mod
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * （日常点検用）レイアウトポップアップで表示する情報を取得
   *
   * @param user NTSS認証ユーザ
   * @param mainteLayoutCd 点検レイアウトコード
   * @return レイアウトポップアップで表示する情報
   */
  @GetMapping("details/{mainteLayoutCd}")
  public ResponseEntity<HashedMap<String, Object>> getListDetailInLayoutForDailyInspection(
      @AuthenticationPrincipal NtssUser user,
      @PathVariable(name = "mainteLayoutCd", required = true) Long mainteLayoutCd) {

    String mappingUrl = Uri.MENTE_LAYOUT + "/details";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      FUNCTION_CODE.FUNC_DAILY_CHECK, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      mainteLayoutCd);

    try {
      HashedMap<String, Object> res = mstMenteLayoutService.getLayoutDetailForDaily(
        user.getFacilityCd(), mainteLayoutCd);

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        FUNCTION_CODE.FUNC_DAILY_CHECK, AFTER_LOG_FLG_INFO, mappingUrl, null,
        mainteLayoutCd);
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        FUNCTION_CODE.FUNC_DAILY_CHECK, AFTER_LOG_FLG_ERROR, mappingUrl, null,
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        ExcetionStackTraceToString(e));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * （日常点検用）点検項目入力画面用の点検項目マスタ情報を取得する
   *
   * @param user NTSS認証ユーザ
   * @param machineNo 装置番号
   * @param menteDate 点検日
   * @return 点検項目マスタ情報
   */
  @GetMapping("daily/show-detail")
  public ResponseEntity<List<HashedMap<String, Object>>> getListDetailForDailyShowDetail(
      @AuthenticationPrincipal NtssUser user,
      @RequestParam(name = "machineNo", required = true) Long machineNo,
      @RequestParam(name = "menteDate", required = true) String menteDate) {

    String mappingUrl = Uri.MENTE_LAYOUT + "/daily/show-detail";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      FUNCTION_CODE.FUNC_DAILY_CHECK, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(machineNo, menteDate));

    try {
      final String facilityCd = user.getFacilityCd();
      List<HashedMap<String, Object>> res = mstMenteLayoutService.getListDetailForDailyShowDetail(
        machineNo, menteDate, facilityCd);

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        FUNCTION_CODE.FUNC_DAILY_CHECK, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(machineNo, menteDate));
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        FUNCTION_CODE.FUNC_DAILY_CHECK, AFTER_LOG_FLG_ERROR, mappingUrl, null,
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * （日常点検用）点検履歴画面用の点検項目マスタ情報を取得する
   *
   * @param user NTSS認証ユーザ
   * @param machineNo 装置番号
   * @param menteDate 点検日
   * @param numOfMonth 過去月数
   * @return 点検項目マスタ情報
   */
  @GetMapping("daily/show-detail-history")
  public ResponseEntity<List<HashedMap<String, Object>>> getListDetailForDailyShowDetailHistory(
    @AuthenticationPrincipal NtssUser user,
    @RequestParam(name = "machineNo", required = true) Long machineNo,
    @RequestParam(name = "menteDate", required = true) String menteDate,
    @RequestParam(name = "numOfMonth", required = true) Integer numOfMonth) {

    String mappingUrl = Uri.MENTE_LAYOUT + "/daily/show-detail-history";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      FUNCTION_CODE.FUNC_DAILY_CHECK, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(machineNo, menteDate, numOfMonth));

    try {
      final String facilityCd = user.getFacilityCd();
      List<HashedMap<String, Object>> res = mstMenteLayoutService.getListDetailForDailyShowDetailHistory(
        machineNo, menteDate, facilityCd, numOfMonth);

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        FUNCTION_CODE.FUNC_DAILY_CHECK, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(machineNo, menteDate, numOfMonth));
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        FUNCTION_CODE.FUNC_DAILY_CHECK, AFTER_LOG_FLG_ERROR, mappingUrl, null,
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * リストマシンタイプの取得
   *
   * @return マシンタイプのリスト
   */
  @GetMapping("machine-types/all/data/{facilityCd}")
  public ResponseEntity<List<MstMachineType>> getListMachineTypesByFacilityCd(
    @PathVariable(name = "facilityCd", required = true) String facilityCd,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie end
) {
      // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
          if (facilityCd != null && !facilityCd.isEmpty() &&
              !facilityCd.equals(ntssUser.getFacilityCd())) {
              String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd;
              InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
              return new ResponseEntity<>(HttpStatus.FORBIDDEN);
          }
      }
      // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.MENTE_LAYOUT  +"/machine-types/all/data";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End
    List<MstMachineType> res = new ArrayList<>();
    try {
      res = mstMenteLayoutService.getListMachineTypes(facilityCd);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setSqlIdentification(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 定期ショー詳細のリスト詳細を取得
   *
   * @param user           NTSS認証ユーザ
   * @param mainteMainNo      検査レイアウトコード
   * @param menteLayoutGroupCd 検査レイアウトグループコード
   * @param machineTypeCd      マシンタイプ
   * @return 定期ショー詳細のリスト詳細
   */
  @GetMapping("peri/show-detail")
  public ResponseEntity<?> getListDetailForPeriShowDetail(@AuthenticationPrincipal NtssUser user,
      @RequestParam(name = "devMenteNo", required = false) Long mainteMainNo,
      @RequestParam(name = "menteLayoutGroupCd", required = false) Long menteLayoutGroupCd,
      @RequestParam(name = "machineTypeCd", required = false) String machineTypeCd) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.MENTE_LAYOUT +"/peri/show-detail";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(mainteMainNo, menteLayoutGroupCd,machineTypeCd));
    // wp アプリケーションログの適正化 Add End

    if (mainteMainNo == null && menteLayoutGroupCd == null && machineTypeCd == null) {
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
    try {
      HashedMap<String, Object> res = new HashedMap<>();
      final String facilityCd = user.getFacilityCd();
      res = mstMenteLayoutService.getListDetailForPeriShowDetail(facilityCd, mainteMainNo, menteLayoutGroupCd,
          machineTypeCd);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(mainteMainNo, menteLayoutGroupCd,machineTypeCd));
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setSqlIdentification(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 定期点検の点検結果レコードを作成する
   *
   * @param menteLayoutGroupCd 点検レイアウトグループコード
   * @param machineInfoAndDateList マシン情報リストと日付リスト
   * @return 点検日＋装置番号＋レイアウトグループコードが既存のレコードと重複するものがあった場合はその点検結果レコードのリスト
   */
  @PostMapping("peri/tmp-main/{menteLayoutGroupCd}")
  public ResponseEntity<List<DevMenteMain>> getListMenteMainTemporaryForPeriodicPlan(
      @AuthenticationPrincipal NtssUser user,
      @RequestBody Map<String, Object> machineInfoAndDateList,
      @PathVariable(name = "menteLayoutGroupCd", required = true) Long menteLayoutGroupCd) {

    String mappingUrl = Uri.MENTE_LAYOUT + "/peri/tmp-main";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
      FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, BEFORE_LOG_FLG_INFO,
      mappingUrl, null, menteLayoutGroupCd);
    try {
      final String facilityCd = user.getFacilityCd();
      List<DevMenteMain> res = mstMenteLayoutService
        .createListMenteMainTemporaryForPeriodic(facilityCd,
          machineInfoAndDateList, menteLayoutGroupCd);
      if (res != null) {
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
          FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, AFTER_LOG_FLG_INFO,
          mappingUrl, null, menteLayoutGroupCd);
        return new ResponseEntity<>(res, HttpStatus.OK);
      }

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, AFTER_LOG_FLG_INFO,
        mappingUrl, null, menteLayoutGroupCd);
      return new ResponseEntity<>(HttpStatus.OK);
      // mod FNSI-No.748  何の定期点検を行うのか（1500h, 3000h, 6000hなど）が俯瞰できない。 吉 end
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 add yangxuewang end

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),
        FUNCTION_CODE.FUNC_PERIODIC_INSPECTION, AFTER_LOG_FLG_ERROR,
        mappingUrl, null, e.getMessage());
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
