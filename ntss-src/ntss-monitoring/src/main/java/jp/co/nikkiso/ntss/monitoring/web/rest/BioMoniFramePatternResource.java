package jp.co.nikkiso.ntss.monitoring.web.rest;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import jp.co.nikkiso.ntss.monitoring.service.logger.LogEventUtils;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.MstBioMoniFramePattern;
import jp.co.nikkiso.ntss.core.entity.custom.MstBioMoniFramePatternWithDefine;
import jp.co.nikkiso.ntss.monitoring.service.MstBioMoniFramePatternService;

import jp.co.nikkiso.ntss.monitoring.service.logger.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
@CrossOrigin(origins = "*") // 別ドメインからのテスト用にアクセスすることを許可
@RestController
@RequestMapping("/api/bio_moni_frame_pattern")
public class BioMoniFramePatternResource {

  @Autowired
  private LogService logService;

  @Autowired
  private MstBioMoniFramePatternService mstBioMoniFramePatternService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  /**
   * グラフ設定値の取得
   * @param facility_cd 施設コード
   * @param ctl_no コントロールナンバー
   * @return 成功： HttpStatus 200, グラフ設定値Json文字列 / 失敗: HttpStatus 500
   */
  @GetMapping("/define_info/{facility_cd}/{ctl_no}")
  public ResponseEntity<String> getBioMoniFramePatternDefineInfo(
      @PathVariable("facility_cd") String facility_cd,
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //@PathVariable("ctl_no") int ctl_no) {
      @PathVariable("ctl_no") Long ctl_no) {
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "/api/bio_moni_frame_pattern" + "/define_info";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    String res = mstBioMoniFramePatternService.selectDefineInfo(facility_cd, ctl_no);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return Optional.ofNullable(res).map(pat -> new ResponseEntity<>(pat, HttpStatus.OK))
        .orElse(new ResponseEntity<>("", HttpStatus.OK));
  }

  /**
   * グラフ設定のテーブル取得
   * @param facility_cd
   * @param ctl_no
   * @return
   */
  @GetMapping({"/{facility_cd}", "/{facility_cd}/{ctl_no}"})
  public ResponseEntity<List<MstBioMoniFramePatternWithDefine>> getBioMoniFramePattern(
      @PathVariable("facility_cd") String facility_cd,
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //@PathVariable(name = "ctl_no", required = false) String ctl_no) {
      @PathVariable(name = "ctl_no", required = false) Long ctl_no) {
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(String.format("REST request to get BioMoniPattern : %s %s", facility_cd, ctl_no));
    eventLogMessage.setFacilityCd(facility_cd);
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
    List<MstBioMoniFramePatternWithDefine> res = new ArrayList<>();
    Long ctlNo = ctl_no != null ? ctl_no : -1L;

    res = mstBioMoniFramePatternService.selectWithDefine(facility_cd, ctlNo);
    return new ResponseEntity<>(res, HttpStatus.OK);
  }

  /**
   * グラフ設定の新規登録
   * @param mstBioMoniFramePattern
   * @return
   * @throws URISyntaxException
   */
  @PostMapping("")
  public ResponseEntity<Void> createBioMoniFramePattern (
      @RequestBody MstBioMoniFramePattern mstBioMoniFramePattern) throws URISyntaxException{
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(String.format("REST request to post createBioMoniFramePattern : %s ", mstBioMoniFramePattern.getFacilityCd()));
    eventLogMessage.setFacilityCd(mstBioMoniFramePattern.getFacilityCd());
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
    // エスケープ文字の置換
    mstBioMoniFramePattern.setDefineInfo(mstBioMoniFramePattern.getDefineInfo().replace("\\\"", "\""));
    try {
      MstBioMoniFramePattern savedMstBioMoniFramePattern = mstBioMoniFramePatternService.insertPattern(mstBioMoniFramePattern);

      return ResponseEntity.created(
          new URI("/api/BioMoniFramePattern/" + savedMstBioMoniFramePattern.getFacilityCd() + "/" + savedMstBioMoniFramePattern.getCtlNo().toString())
          ).build();

    } catch (DuplicateKeyException e) {

      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
    }
  }

  /**
   * グラフ設定更新
   * @param facility_cd
   * @param ctl_no
   * @param mstBioMoniFramePattern
   * @return
   */
  @PutMapping("/{facility_cd}/{ctl_no}")
  public ResponseEntity<Void> updateBioMoniFramePattern(
      @PathVariable("facility_cd") String facility_cd,
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //@PathVariable("ctl_no") String ctl_no,
      @PathVariable("ctl_no") Long ctl_no,
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      @RequestBody MstBioMoniFramePattern mstBioMoniFramePattern){
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(String.format("REST request to put createBioMoniFramePattern : %s ", facility_cd));
    eventLogMessage.setFacilityCd(facility_cd);
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
    // エスケープ文字の置換
    mstBioMoniFramePattern.setDefineInfo(mstBioMoniFramePattern.getDefineInfo().replace("\\\"", "\""));

    mstBioMoniFramePatternService.updatePattern(mstBioMoniFramePattern);
    return ResponseEntity.ok().build();
  }
  /**
   * グラフ設定削除
   * @param facility_cd
   * @param ctl_no
   * @return
   */
  @DeleteMapping("/{facility_cd}/{ctl_no}")
  public ResponseEntity<Void> deleteBioMoniFramePattern(
      @PathVariable("facility_cd") String facility_cd,
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      // @PathVariable("ctl_no") String ctl_no){
      @PathVariable("ctl_no") Long ctl_no){
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(String.format("REST request to put createBioMoniFramePattern : %s ", facility_cd));
    eventLogMessage.setFacilityCd(facility_cd);
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //mstBioMoniFramePatternService.delete(facility_cd, Integer.parseInt(ctl_no));
    mstBioMoniFramePatternService.delete(facility_cd, ctl_no);
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    return ResponseEntity.ok().build();
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
