package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.sysMedicine.SysMedicineService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.entity.SysMedicine;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 標準医薬品マスタ（sys_medicine）系のリソースクラス
 */
@Slf4j
@RestController
@RequestMapping(Uri.SYS_MEDICINE)
public class SysMedicineResource {

  /**
   * 標準医薬品マスタサービス.
   */
  @Autowired
  SysMedicineService sysMedicineService;

  @Autowired
  LogService logService;

  /**
  * 標準医薬品マスタを全件取得する.
  */
  @GetMapping("/getSysMedicineAll")
  public ResponseEntity<?> getSysMedicineAll() {
    // ログ出力

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("標準医薬品マスタ取得のRestAPI実行");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // レスポンス生成
    List<SysMedicine> response = sysMedicineService.getSysMedicineAll();
    // ログ出力

    eventLogMessage.setLogMessage("標準医薬品マスタ取得:取得件数[" +  response.size() + "]");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /* add by zhaohan 2022-10-12 [7280] 標準医薬品マスタ検索を表示するのに時間がかかる。 --start */
  /***
   * 標準医薬品マスタのキーワード検索
   *
   * @param keyword キーワード
   * @param offset オフセット
   * @return {@link SysMedicine}のリスト
   */
  @GetMapping("/getSysMedicineByKeyword/{keyword}/{offset}")
  public ResponseEntity<?> getSysMedicineByKeyword(@PathVariable String keyword, @PathVariable Integer offset) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("標準医薬品マスタ取得のRestAPI実行");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // レスポンス生成
    List<SysMedicine> response = sysMedicineService.getSysMedicineByKeyword(keyword, offset);
    // ログ出力

    eventLogMessage.setLogMessage("標準医薬品マスタ取得:取得件数[" +  response.size() + "]");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return new ResponseEntity<>(response, HttpStatus.OK);
  }
  /* add by zhaohan 2022-10-12 [7280] 標準医薬品マスタ検索を表示するのに時間がかかる。 --end */

  // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy start
  /**
   * 標準医薬品マスタを全件取得する.分頁
   */
  @GetMapping({"/getSysMedicineByLimitAndOffset/{offset}/{keyword}", "/getSysMedicineByLimitAndOffset/{offset}"})
  public ResponseEntity<?> getSysMedicineByLimitAndOffset(@PathVariable Integer offset, @PathVariable(name = "keyword", required = false) String keyword) {
    // ログ出力
    Integer limit = 100;
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("標準医薬品マスタ取得のRestAPI実行");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // レスポンス生成
    List<SysMedicine> response = sysMedicineService.getSysMedicineByLimitAndOffset(limit, offset, keyword);
    // ログ出力

    eventLogMessage.setLogMessage("標準医薬品マスタ取得:取得件数[" +  response.size() + "]");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return new ResponseEntity<>(response, HttpStatus.OK);
  }
  // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy end

  // add #6930 標準医薬品マスタの抽出で追加読み込みが行われない 徐博 start
  /**
   * 標準医薬品マスタを件数取得する
   */
  @GetMapping("/getTotal")
  public ResponseEntity<?> getTotal() {
    String Total = sysMedicineService.getTotal();
    return new ResponseEntity<>(Total, HttpStatus.OK);
  }
  // add #6930 標準医薬品マスタの抽出で追加読み込みが行われない 徐博 end

  /***
   * 標準医薬品マスタ検索
   *
   * @param salesName 販売名
   * @return {@link SysMedicine}のリスト
   */
  @GetMapping("/getSysMedicineBySalesName/{salesName}")
  public ResponseEntity<?> selectBySalesName(@PathVariable String salesName) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("標準医薬品マスタ取得のRestAPI実行");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    // レスポンス生成
    List<SysMedicine> response = sysMedicineService.selectBySalesName(salesName);

    // ログ出力
    eventLogMessage.setLogMessage("標準医薬品マスタ取得:取得件数[" +  response.size() + "]");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return new ResponseEntity<>(response, HttpStatus.OK);
  }
}
