package jp.co.nikkiso.ntss.monitoring.web.rest;

import java.net.URISyntaxException;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.dao.MstBedGroupDao;
import jp.co.nikkiso.ntss.core.entity.MstBedGroup;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;

import jp.co.nikkiso.ntss.monitoring.service.logger.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
/**
 * 装置状態のResourceクラス.
 */
@CrossOrigin(origins = "*") // 別ドメインからのテスト用にアクセスすることを許可
@RestController
@RequestMapping("/api/bed_group")
public class MstBedGroupResource {

  /**
   * Logger.
   */
  private final Logger logger = LoggerFactory.getLogger(getClass());

  /**
   * ベッドグループ一覧Service.
   */
  @Autowired
  private MstBedGroupDao mstBedGroupDao;

  @Autowired
  private LogService logService;
  /**
   * ベッドグループ一覧表示.
   *
   * @param facilityCd 施設コード
   * @return ベッドグループ一覧のResponseEntity
   */
  @GetMapping("/{facilityCd}")
  public ResponseEntity<?> getBedGroup(@PathVariable String facilityCd) throws URISyntaxException {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(String.format("REST request to get getBedGroup : %s", facilityCd));
    eventLogMessage.setFacilityCd(facilityCd);
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
    List<MstBedGroup> mstBedGroup = mstBedGroupDao.selectByFacility(facilityCd);

    return new ResponseEntity<>(mstBedGroup, HttpStatus.OK);

  }

}
