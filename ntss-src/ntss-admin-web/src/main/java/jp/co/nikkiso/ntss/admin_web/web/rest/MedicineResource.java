package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.reportDesigner.ReportDesignerService;
import lombok.extern.slf4j.Slf4j;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;


/**
 * 薬剤リストのResourceクラス.
 */
@RestController
@Slf4j
@RequestMapping(Uri.MEDICINE)
public class MedicineResource {

	@Autowired
  LogService logService;

  @Autowired
  ReportDesignerService reportDesignerService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End
  /**
   * 薬剤データ取得.
   * @param facilityCd 施設コード
   * @param ntssUser
   * @return 薬剤データのResponse
   */
  @GetMapping("/{facilityCd}")
  public ResponseEntity<?> getByCd(@PathVariable(name = "facilityCd", required = true) String facilityCd,
      @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.MEDICINE ;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

    // ResponseEntityを返す
    // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe start
    // return getByCd(ntssUser.getFacilityCd());
    return getByCd(facilityCd);
    // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe end

  }

  /**
   * 薬剤データ取得.
   * @param ntssUser
   * @return 薬剤データのResponse
   */
  @GetMapping("")
  public ResponseEntity<?> getByCd(@AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.MEDICINE ;
    // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe start
    // logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, ntssUser.getFacilityCd(),
    // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe end
      null);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe start
    // logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, ntssUser.getFacilityCd(),
    // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe end
      null);
    // wp アプリケーションログの適正化 Add End

    // ResponseEntityを返す
    return getByCd(ntssUser.getFacilityCd());

  }

  /**
   * 薬剤データ取得.
   * @param facilityCd 施設コード
   * @return 薬剤データのResponse
   */
  private ResponseEntity<?> getByCd(final String facilityCd) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get data for report layout designer. facilityCd:["+facilityCd+"]");
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
    null);

    try {
      // レスポンス作成
      // mod #11832 準備リスト.物品情報(薬剤)の調製薬剤フィルタは不要 limingzhe start
      //return new ResponseEntity<>(reportDesignerService.getMedicine(facilityCd), HttpStatus.OK);
      return new ResponseEntity<>(reportDesignerService.getMedicine(facilityCd, 0), HttpStatus.OK);
      // mod #11832 準備リスト.物品情報(薬剤)の調製薬剤フィルタは不要 limingzhe end

    } catch (Exception e) {

      // マスタが取得できなかった場合
    	// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    	logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
    	null);
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
