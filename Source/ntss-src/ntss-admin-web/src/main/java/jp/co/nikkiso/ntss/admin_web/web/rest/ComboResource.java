package jp.co.nikkiso.ntss.admin_web.web.rest;

import static java.util.stream.Collectors.toList;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

import java.util.Arrays;
import java.util.List;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.response.combo.Combo;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.master.ReferenceComboService;
import jp.co.nikkiso.ntss.core.entity.custom.ReferenceComboTargetTable;
import lombok.extern.slf4j.Slf4j;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.access.FacilityAccessService;

/**
 * コンボボックス用のResourceクラス.
 */
@RestController
@Slf4j
@RequestMapping(Uri.COMBO)
public class ComboResource {

  /**
   * 参照型コンボ用Service.
   */
  @Autowired
  private ReferenceComboService referenceComboService;
  @Autowired
	LogService logService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  @Autowired
  private FacilityAccessService facilityAccessService;

  // wp アプリケーションログの適正化 Add End

  /**
   * コンボデータ取得.
   * @param masterPhysicalName マスタ物理名
   * @param textColumnPhysicalName コンボに出すテキストの物理カラム名
   * @param cdColumnPhysicalName 主キーの物理カラム名
   * @param ntssUser NTSS認証ユーザー
   * @return 対象マスタのコンボデータリスト
   */
  @GetMapping("/{master_physical_name}/{text_column_physical_name}/{cd_column_physical_name}")
  public ResponseEntity<List<Combo>> getComboList(
      @PathVariable("master_physical_name") String masterPhysicalName,
      @PathVariable("text_column_physical_name") String textColumnPhysicalName,
      @PathVariable("cd_column_physical_name") String cdColumnPhysicalName,
      @RequestParam(required = false) Long selectedPatId,
      @AuthenticationPrincipal NtssUser ntssUser) {
    if (!facilityAccessService.hasFacilityOrSelectedPatShareAccess(ntssUser, ntssUser.getFacilityCd(), selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }



    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.COMBO ;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(masterPhysicalName, textColumnPhysicalName,cdColumnPhysicalName));
    // wp アプリケーションログの適正化 Add End

//    // ログ出力
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("REST request to get combo data : "+ masterPhysicalName);
//    logService.log(LogLevel.DEBUG, eventLogMessage,"", SERVICE_NAME.FNSI,
//    null);

    // レスポンス生成
    String facilityCd = ntssUser.getFacilityCd();
    ReferenceComboTargetTable referenceComboTargetTable
      = new ReferenceComboTargetTable(masterPhysicalName, cdColumnPhysicalName, textColumnPhysicalName, cdColumnPhysicalName);
    List<Combo> response = referenceComboService.build(facilityCd, referenceComboTargetTable).stream()
      .map(referenceCombo -> new Combo(referenceCombo.getDisplayValue().toString(), referenceCombo.getIdentifierValue()))
      .collect(toList());

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(masterPhysicalName, textColumnPhysicalName,cdColumnPhysicalName));
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(response, HttpStatus.OK);

  }
  // add マスタ一覧 1･施設切替を可能とする 孔s start
  @GetMapping("/{master_physical_name}/{text_column_physical_name}/{cd_column_physical_name}/{facilityCd}")
  public ResponseEntity<List<Combo>> getComboListByFacilityCd(
      @PathVariable("master_physical_name") String masterPhysicalName,
      @PathVariable("text_column_physical_name") String textColumnPhysicalName,
      @PathVariable("cd_column_physical_name") String cdColumnPhysicalName,
      @PathVariable("facilityCd") String facilityCd,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if (!ntssUser.isNkkAdminUser()) {
      try {
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      } catch (Exception ignored) {
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.COMBO ;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      Arrays.asList(masterPhysicalName, textColumnPhysicalName,cdColumnPhysicalName));
    // wp アプリケーションログの適正化 Add End

//    // ログ出力
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("REST request to get combo data : "+ masterPhysicalName);
//    logService.log(LogLevel.DEBUG, eventLogMessage,"", SERVICE_NAME.FNSI,
//    null);

    // レスポンス生成
    ReferenceComboTargetTable referenceComboTargetTable
      = new ReferenceComboTargetTable(masterPhysicalName, cdColumnPhysicalName, textColumnPhysicalName, cdColumnPhysicalName);
    List<Combo> response = referenceComboService.build(facilityCd, referenceComboTargetTable).stream()
      .map(referenceCombo -> new Combo(referenceCombo.getDisplayValue().toString(), referenceCombo.getIdentifierValue()))
      .collect(toList());

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
      Arrays.asList(masterPhysicalName, textColumnPhysicalName,cdColumnPhysicalName));
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(response, HttpStatus.OK);

  }
  // add マスタ一覧 1･施設切替を可能とする 孔s emd

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
