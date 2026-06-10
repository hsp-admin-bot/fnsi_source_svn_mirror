package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.response.destinationGroup.DestinationGroupNameResponse;
import jp.co.nikkiso.ntss.admin_web.service.DestinationGroupService;
import lombok.extern.slf4j.Slf4j;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

/**
 * 送信先グループ（mst_destination_group）系のリソースクラス.
 */
@RestController
@RequestMapping(Uri.DESTINATION_GROUP)
@Slf4j
public class DestinationGroupResource {

  /**
   * 送信先グループService.
   */
  @Autowired
  private DestinationGroupService destinationGroupService;
  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  /**
   * 送信先グループコードとグループ名を取得する.
   *
   * @param destinationGroupCd 送信先グループコード
   * @return 利用者の名前とメールアドレス登録有無のセット
   */
  @GetMapping("/{destinationGroupCd}/name")
  public ResponseEntity<DestinationGroupNameResponse> getDestinationGroupName(@PathVariable Long destinationGroupCd) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DESTINATION_GROUP ;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      destinationGroupCd);
    // wp アプリケーションログの適正化 Add End
    DestinationGroupNameResponse destinationGroupNameResponse = destinationGroupService
        .createDestinationGroupNameResponse(destinationGroupCd);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      destinationGroupCd);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(destinationGroupNameResponse, HttpStatus.OK);
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
