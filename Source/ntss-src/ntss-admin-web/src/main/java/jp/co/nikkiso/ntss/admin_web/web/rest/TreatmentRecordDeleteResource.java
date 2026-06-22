package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.nextpat.NextPatService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.TreatmentRecordDeleteService;
import jp.co.nikkiso.ntss.core.dao.OrdChecklistDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.annotation.Resource;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.ExecutorService;

import static jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;

/**
 * 治療記録(削除)のResourceクラス.
 */
@RestController
@RequestMapping(Uri.TREATMENT_RECORD)
@PreAuthorize("isAuthenticated()")
public class TreatmentRecordDeleteResource {
  /**
   * 治療記録(削除)Service.
   */
  @Autowired
  private TreatmentRecordDeleteService treatmentRecordDeleteService;

  //add 9480 治療記録（実績削除） gjn start
  @Autowired
  private WebApiCallCommonUtil webApiCallCommonUtil;
  //add 9480 治療記録（実績削除） gjn end
  /**
   * ログ出力Service.
   */
  @Autowired
  LogService logService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End
  // add #10132 時間外加算処理不正 dengshen Start
  @Autowired
  OrdMainDao ordMainDao;
  // add #10132 時間外加算処理不正 dengshen end

  //add 9480 実績削除.检查计算 gjn start
  @Resource(name = "crawlExecutorPool")
  private ExecutorService threadExector;
  //add 9480 実績削除.检查计算 gjn end
  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
  @Autowired
  private OrdChecklistDao ordChecklistDao;
  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

  //add #10412 次患者更新関連全体見直し対応 朴 start
  /**
   * 次患者更新関連
   */
  @Autowired
  private NextPatService nextPatService;
  //add #10412 次患者更新関連全体見直し対応 朴 end

  /**
   * 実績削除.
   *
   * @param ordNo 削除対象のオーダ番号
   * @param ntssUser NTSS認証ユーザ
   * @return 正常に削除した場合、{@link HttpStatus#OK}
   */
  @PutMapping("/delete/{ord_no}")
  @PreAuthorize("hasAuthority('" + AdminWebConstant.Authority.DEL_RST + "')")
  public ResponseEntity<?> deleteTreatmentRecord(
    @PathVariable("ord_no") Long ordNo,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.TREATMENT_RECORD + "/delete";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      ordNo);
    // wp アプリケーションログの適正化 Add End

//    // ログ出力
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage(String.format("実績削除処理のRestAPI実行 : オーダ番号[%s]", ordNo));
//    logService.log(LogLevel.DEBUG, eventLogMessage,"", SERVICE_NAME.FNSI, null);
    // 実績削除処理
    // mod #6848 2022-08-26 透析実績を削除しても次患者は戻らない。 dou start

    //add #10412 次患者更新関連全体見直し対応 朴 start
    OrdMain beforOrdMain = ordMainDao.selectByOrdNo(ordNo);
    if (beforOrdMain != null && beforOrdMain.getFacilityCd() != null
      && (ntssUser == null || !beforOrdMain.getFacilityCd().equals(ntssUser.getFacilityCd()))) {
      // #11205 mod 20260421 start
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + beforOrdMain.getFacilityCd() + " " + "ordNo=" + ordNo + " " + "patId=" + beforOrdMain.getPatId() + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      // #11205 mod 20260421 end
    }
    //add #10412 次患者更新関連全体見直し対応 朴 end

    //mod FNSI修正401対応 房 start
//    treatmentRecordDeleteService.deleteTreatmentRecordByOrdNo(ordNo, ntssUser.getFacilityCd());
    OrdMain ordMain = treatmentRecordDeleteService.deleteTreatmentRecordByOrdNo(ordNo, ntssUser.getFacilityCd());

    //mod FNSI修正401対応 房 end
    // mod #10132 時間外加算処理不正 dengshen Start
    ordMainDao.updateAdditionInfoById(ordNo, "[]");
    // mod #10132 時間外加算処理不正 dengshen end

    //mod #10412 次患者更新関連全体見直し対応 朴 start
//    treatmentRecordDeleteService.setNextPat(ordMain);
//    // mod #6848 2022-08-26 透析実績を削除しても次患者は戻らない。 dou start

    // サービスの新しい次患者更新呼出統合処理を呼び出す
    nextPatService.CallNextPatChange(beforOrdMain.getFacilityCd(), Arrays.asList(beforOrdMain));
    //mod #10412 次患者更新関連全体見直し対応 朴 end

    //add 9480 治療記録（実績削除） gjn start
    threadExector.execute(new Runnable() {
      @Override
      public void run() {
        // 非同期実行チェック計算
        webApiCallCommonUtil.doAutoCalculation(ordNo);
      }
    });
    //add 9480 治療記録（実績削除） gjn end
    //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
    List<Long> ordNoList = new ArrayList<>();
    ordNoList.add(ordMain.getOrdNo());
    ordChecklistDao.deleteByOrdNoAndFacilityCdBatch(ordNoList, ntssUser.getFacilityCd());
    //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      ordNo);
    // wp アプリケーションログの適正化 Add End
    // レスポンス生成
    return new ResponseEntity(HttpStatus.OK);
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
