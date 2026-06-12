package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.net.InetAddress;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.validation.Valid;
import java.util.HexFormat;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import jp.co.nikkiso.ntss.core.entity.MstMainteCategoryAndDetail;
import jp.co.nikkiso.ntss.core.entity.MstMenteDetail;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
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
import jp.co.nikkiso.ntss.admin_web.request.reportDesigner.DownloadRequest;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.master.MstDialysisDifficultyService;
import jp.co.nikkiso.ntss.admin_web.service.master.equipment.EquipmentService;
import jp.co.nikkiso.ntss.admin_web.service.reportDesigner.ReportDesignerService;
import jp.co.nikkiso.ntss.admin_web.service.access.FacilityAccessService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.api.service.SysDataSetService;
import jp.co.nikkiso.ntss.core.entity.MstDialysisDifficulty;
import jp.co.nikkiso.ntss.core.entity.SysDataSet;
import jp.co.nikkiso.ntss.core.entity.custom.Equipment;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

/**
 * 帳票レイアウトデザイナ用Resourceクラス.
 */
@RestController
@Slf4j
@RequestMapping((Uri.REPORT_DESIGNER))
public class ReportDesignerResource {
  @Autowired
  private FacilityAccessService facilityAccessService;


  @Autowired
  ReportDesignerService reportDesignerService;
  @Autowired
  EquipmentService equipmentService;

  @Autowired
  LogService logService;

  MstDialysisDifficultyService difficultyService;
  // add 9601 印刷サーバにて帳票の印刷が行われない　吉 start
  @Value("${server.port:#{8080}}")
  private String port;
  // add 9601 印刷サーバにて帳票の印刷が行われない　吉 end

  /**
   * 指定のマスタの主キーとレコード名称を取得する
   * @param ntssUser
   * @param tableName テーブル名称（mst_をつけてもつけなくても良い）
   * @return
   */
  @GetMapping("/master/{tableName}")
  public ResponseEntity<?> getMaster(
      @AuthenticationPrincipal NtssUser ntssUser,
      @PathVariable String tableName,
      @RequestParam(required = false) Long selectedPatId
  ) {
    if (!facilityAccessService.hasFacilityOrSelectedPatShareAccess(ntssUser, ntssUser.getFacilityCd(), selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }


    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get data for report layout designer. facilityCd:[" + ntssUser.getFacilityCd() +"], tableName:["+ tableName +"]");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
    try {
      return new ResponseEntity<>(reportDesignerService.getMaster(ntssUser.getFacilityCd(), tableName), HttpStatus.OK);
    } catch (Exception e) {
      return new ResponseEntity<>(e.getLocalizedMessage(), HttpStatus.BAD_REQUEST);
    }
  }

  // add #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe start
  /**
   * 指定のマスタの主キーとレコード名称を取得する
   * @param ntssUser
   * @param tableName テーブル名称（mst_をつけてもつけなくても良い）
   * @param facilityCd 問い合わせが必要な施設
   * @return
   */
  @GetMapping("/master/{tableName}/{facilityCd}")
  public ResponseEntity<?> getMaster(
    @AuthenticationPrincipal NtssUser ntssUser,
    @PathVariable String tableName,
    @PathVariable(name = "facilityCd", required = true) String facilityCd
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260421 start
    if (!ntssUser.isNkkAdminUser() && facilityCd != null && !facilityCd.equals(ntssUser.getFacilityCd())) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260421 end

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get data for report layout designer. user facilityCd:[" + ntssUser.getFacilityCd() +"], tableName:["+ tableName +"], select facilityCd:["+ facilityCd +"]");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
    try {
      return new ResponseEntity<>(reportDesignerService.getMaster(facilityCd, tableName), HttpStatus.OK);
    } catch (Exception e) {
      return new ResponseEntity<>(e.getLocalizedMessage(), HttpStatus.BAD_REQUEST);
    }
  }
  // add #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe end

  // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe start
  // @GetMapping("/pat_event")
  @GetMapping("/pat_event/{facilityCd}")
  // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe end
  public ResponseEntity<?> getPatEvent(
    @AuthenticationPrincipal NtssUser ntssUser,
    // add #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe start
    @PathVariable(name = "facilityCd", required = true) String facilityCd
    // add #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260421 start
    if (!ntssUser.isNkkAdminUser() && facilityCd != null && !facilityCd.equals(ntssUser.getFacilityCd())) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260421 end


    EventLogMessage eventLogMessage = new EventLogMessage();
    // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe start
    // eventLogMessage.setLogMessage("REST request to get data for report layout designer. facilityCd:["+ ntssUser.getFacilityCd() +"], tableName:[" + "pat_event" + "]");
    eventLogMessage.setLogMessage("REST request to get data for report layout designer. user facilityCd:["+ ntssUser.getFacilityCd() +"], tableName:[" + "pat_event" + "], select facilityCd:["+ facilityCd +"]");
    // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe end
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
    try {
      // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe start
      // return new ResponseEntity<>(reportDesignerService.getPatEventCategory(ntssUser.getFacilityCd()), HttpStatus.OK);
      return new ResponseEntity<>(reportDesignerService.getPatEventCategory(facilityCd), HttpStatus.OK);
      // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe end
    } catch (Exception e) {
      return new ResponseEntity<>(e.getLocalizedMessage(), HttpStatus.BAD_REQUEST);
    }
  }

  // add #11832 準備リスト.物品情報(薬剤)の調製薬剤フィルタは不要 limingzhe start
  /**
   * 薬剤データ取得.
   * @param ntssUser
   * @param facilityCd 施設コード
   * @param medflag 0:all 1:通常薬剤 2:調製薬剤
   * @return 薬剤データのResponse
   */
  @GetMapping("/medicine/{facilityCd}/{medflag}")
  public ResponseEntity<?> getMedicine(
    @AuthenticationPrincipal NtssUser ntssUser,
    @PathVariable(name = "facilityCd", required = true) String facilityCd,
    @PathVariable(name = "medflag", required = true) Integer medflag
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260421 start
    if (!ntssUser.isNkkAdminUser() && facilityCd != null && !facilityCd.equals(ntssUser.getFacilityCd())) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260421 end

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get data for report layout designer. user facilityCd:["+ ntssUser.getFacilityCd() +"], FilterType:[" + "medicine" + "], select facilityCd:["+ facilityCd +"] and medflag:[" + medflag + "]");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);

    try {
      // レスポンス作成
      return new ResponseEntity<>(reportDesignerService.getMedicine(facilityCd, medflag), HttpStatus.OK);
    } catch (Exception e) {

      // マスタが取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  // add #11832 準備リスト.物品情報(薬剤)の調製薬剤フィルタは不要 limingzhe end

  /**
   * 医材データ取得.
   * @param ntssUser
   * @return 医材データのResponse
   */
  // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe start
  // @GetMapping("/equipment")
  @GetMapping("/equipment/{facilityCd}")
  // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe end
  public ResponseEntity<?> getByCd(
    @AuthenticationPrincipal NtssUser ntssUser,
    // add #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe start
    @PathVariable(name = "facilityCd", required = true) String facilityCd
    // add #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260421 start
    if (!ntssUser.isNkkAdminUser() && facilityCd != null && !facilityCd.equals(ntssUser.getFacilityCd())) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260421 end

    // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe start
    // ResponseEntityを返す
    // return getByCd(ntssUser.getFacilityCd());
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get data for report layout designer. user facilityCd:["+ ntssUser.getFacilityCd() +"], FilterType:[" + "equipment" + "], select facilityCd:["+ facilityCd +"]");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
    // ResponseEntityを返す
    return getByCd(facilityCd);
    // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe end
  }

  /**
   * 医材データ取得.
   * @param facilityCd 施設コード
   * @return 医材データのResponse
   */
  private ResponseEntity<?> getByCd(final String facilityCd) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    // del #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe start
//    eventLogMessage.setLogMessage("REST request to get data for report layout designer. facilityCd:["+facilityCd+"]");
//    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    // del #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe end

    try {

      // 医材リストのレスポンス生成
      // mod #12416 帳票移植時にフィルタ設定が無効化する（横展開） limingzhe start
      //List<Equipment> res = equipmentService.selectByCd(facilityCd);
      List<Equipment> res = equipmentService.selectAllByFacilityCd(facilityCd, "1", "0");
      // mod #12416 帳票移植時にフィルタ設定が無効化する（横展開） limingzhe end

      // レスポンス作成
      return new ResponseEntity<>(res, HttpStatus.OK);

    } catch (Exception e) {

      // マスタが取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

  }

  /**
   * 透析困難データ取得.
   * @param ntssUser
   * @return 透析困難データのResponse
   */
  // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe start
  // @GetMapping("/dialysis_difficulties")
  @GetMapping("/dialysis_difficulties/{facilityCd}")
  // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe end
  public ResponseEntity<?> getAll(
    @AuthenticationPrincipal NtssUser ntssUser,
    // add #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe start
    @PathVariable(name = "facilityCd", required = true) String facilityCd
    // add #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260421 start
    if (!ntssUser.isNkkAdminUser() && facilityCd != null && !facilityCd.equals(ntssUser.getFacilityCd())) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260421 end

    // del #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe start
//    final String facilityCd = ntssUser.getFacilityCd();
    // del #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe end
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe start
    // eventLogMessage.setLogMessage("REST request to get data for report layout designer. facilityCd:["+facilityCd+"]");
    eventLogMessage.setLogMessage("REST request to get data for report layout designer. user facilityCd:["+ ntssUser.getFacilityCd() +"], FilterType:[" + "dialysis_difficulties" + "], select facilityCd:["+ facilityCd +"]");
    // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe end
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    try {

      // 透析困難リストのレスポンス生成
      List<MstDialysisDifficulty> res = difficultyService.selectAll(facilityCd);

      // レスポンス作成
      return new ResponseEntity<>(res, HttpStatus.OK);

    } catch (Exception e) {

      // マスタが取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }

  // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
  /**
   * レセプトデータ取得.
   * @param ntssUser
   * @return レセプトデータのResponse
   */
  // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe start
  // @GetMapping("/Receipt")
  @GetMapping("/Receipt/{facilityCd}")
  // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe end
  public ResponseEntity<?> getReceipt(
    @AuthenticationPrincipal NtssUser ntssUser,
    // add #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe start
    @PathVariable(name = "facilityCd", required = true) String facilityCd
    // add #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260421 start
    if (!ntssUser.isNkkAdminUser() && facilityCd != null && !facilityCd.equals(ntssUser.getFacilityCd())) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260421 end

    EventLogMessage eventLogMessage = new EventLogMessage();
    // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe start
    // eventLogMessage.setLogMessage("REST request to get data for report layout designer. facilityCd:["+ ntssUser.getFacilityCd() +"], FilterType:[" + "Receipt" + "]");
    eventLogMessage.setLogMessage("REST request to get data for report layout designer. facilityCd:["+ ntssUser.getFacilityCd() +"], FilterType:[" + "Receipt" + "], select facilityCd:["+ facilityCd +"]");
    // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe end
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
    try {
      // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe start
      // return new ResponseEntity<>(reportDesignerService.getReceipt(ntssUser.getFacilityCd()), HttpStatus.OK);
      return new ResponseEntity<>(reportDesignerService.getReceipt(facilityCd), HttpStatus.OK);
      // mod #11597 レイアウトデザイナ管理者モードでフィルタリストが選択施設のものにならない limingzhe end
    } catch (Exception e) {
      return new ResponseEntity<>(e.getLocalizedMessage(), HttpStatus.BAD_REQUEST);
    }
  }
  // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end

	// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
//  // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
//  /**
//   * 検査レイアウトでリストの詳細を取得
//   *
//   * @param user NTSS認証ユーザ
//   * @param facilityCd 問い合わせが必要な施設
//   * @param mainteRecordType 記録簿 日常点検:1 定期点検:2
//   * @return リストの詳細
//   */
//  @GetMapping("Inspection/{facilityCd}/{mainteLayoutCd}/{mainteRecordType}")
//  public ResponseEntity<List<MstMenteDetail>> getListDetailInLayoutForInspection(
//    @AuthenticationPrincipal NtssUser user,
//    @PathVariable(name = "facilityCd", required = true) String facilityCd,
//    @PathVariable(name = "mainteLayoutCd", required = true) Long mainteLayoutCd,
//    @PathVariable(name = "mainteRecordType", required = true) Long mainteRecordType
//  ) {
//
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("REST request to get data for report layout designer. facilityCd:["+ user.getFacilityCd() +"], FilterType:[" + "inspection" + "], select facilityCd:["+ facilityCd +"]");
//    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
//
//    try {
//      return new ResponseEntity<>(reportDesignerService.getInspection(facilityCd, mainteLayoutCd, mainteRecordType), HttpStatus.OK);
//    } catch (Exception e) {
//      // マスタが取得できなかった場合
//      eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
//      logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
//      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
//    }
//  }
//  // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end

  /**
   * 点検項目データ取得.
   *
   * @param user NTSS認証ユーザ
   * @param facilityCd 問い合わせが必要な施設
   * @param layoutClass 用途 1:日常点検用 2:定期点検用
   * @return リストの詳細
   */
  @GetMapping("Inspection/{facilityCd}/{layoutClass}")
  public ResponseEntity<List<MstMainteCategoryAndDetail>> getListDetailInLayoutForInspection(
    @AuthenticationPrincipal NtssUser user,
    @PathVariable(name = "facilityCd", required = true) String facilityCd,
    @PathVariable(name = "layoutClass", required = true) String layoutClass
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260421 start
    if (!user.isNkkAdminUser() && facilityCd != null && !facilityCd.equals(user.getFacilityCd())) {
      String msg_11205_FORBIDDEN = "user.getFacilityCd()=" + user.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260421 end


    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get data for report layout designer. facilityCd:["+ user.getFacilityCd() +"], FilterType:[" + "inspection" + "], select facilityCd:["+ facilityCd +"]");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);

    try {
      return new ResponseEntity<>(reportDesignerService.getInspection(facilityCd, layoutClass), HttpStatus.OK);
    } catch (Exception e) {
      // マスタが取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 型式データ取得.
   *
   * @param user    NTSS認証ユーザ
   * @param facilityCd 問い合わせが必要な施設
   * @param layoutClass 用途 1:日常点検用 2:定期点検用
   * @return レイアウトリスト
   */
  @GetMapping("machine_type/{facilityCd}/{layoutClass}")
  public ResponseEntity<?> getMachineTypeListByLayoutClass(
    @AuthenticationPrincipal NtssUser user,
    @PathVariable(name = "facilityCd", required = true) String facilityCd,
    @PathVariable(name = "layoutClass", required = true) String layoutClass
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260421 start
    if (!user.isNkkAdminUser() && facilityCd != null && !facilityCd.equals(user.getFacilityCd())) {
      String msg_11205_FORBIDDEN = "user.getFacilityCd()=" + user.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260421 end

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get data for report layout designer. facilityCd:["+ user.getFacilityCd() +"], Layout:[" + "MachineType" + "], select facilityCd:["+ facilityCd +"]" + " layoutClass:["+ layoutClass +"]");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);

    try {
      return new ResponseEntity<>(reportDesignerService.getMachineType(facilityCd, layoutClass), HttpStatus.OK);
    } catch (Exception e) {
      // マスタが取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

  // add #12585 水質管理.水質検査のフィルタ処理仕様修正　高　start
  @GetMapping("water_survey_point/{facilityCd}/{machineTypeCd}")
  public ResponseEntity<?> getWaterSurveyPointListByLayoutClass(
    @AuthenticationPrincipal NtssUser user,
    @PathVariable(name = "facilityCd", required = true) String facilityCd,
    @PathVariable(name = "machineTypeCd", required = true) String machineTypeCd
  ) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get data for report layout designer. facilityCd:["+ user.getFacilityCd() +"], Layout:[" + "WaterSurveyPoint" + "], select facilityCd:["+ facilityCd +"]" + " machineTypeCd:["+ machineTypeCd +"]");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);

    try {
      return new ResponseEntity<>(reportDesignerService.getWaterSurveyPoint(facilityCd,machineTypeCd), HttpStatus.OK);
    } catch (Exception e) {
      // マスタが取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  // add #12585 水質管理.水質検査のフィルタ処理仕様修正　高　end

  /**
   * SysDataSetから帳票出力情報を取得するServiceインタフェース.
   */
  @Autowired
  private SysDataSetService sysDataSetService;

  /**
   * sys_data_set全レコード取得.
   * @return sys_data_set全レコード
   */
  @GetMapping("/sys_data_sets")
  public ResponseEntity<?> getSysDataSets() {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get sys_data_set for report layout designer.");
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    try {

      // sys_data_setリストのレスポンス生成
      List<SysDataSet> res = sysDataSetService.selectForReport();

      // レスポンス作成
      return new ResponseEntity<>(res, HttpStatus.OK);

    } catch (Exception e) {

      // マスタが取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }

  /**
   * sys_data_setが正常に動作するかチェックするためのREST API
   * @param ordNo
   * @param patId
   * @param machineNo
   * @param date yyyyMMdd
   * @param fromDate yyyyMMdd
   * @param toDate yyyyMMdd
   * @param sqlCd
   * @return
   */
  @GetMapping("/sys_data_set_execute/{ordNo}/{patId}/{machineNo}/{date}/{fromDate}/{toDate}/{sqlCd}")
  public ResponseEntity<?> getSysDataSetTest(
      @AuthenticationPrincipal NtssUser ntssUser,
      @PathVariable Long ordNo,
      @PathVariable Long patId,
      @PathVariable Long machineNo,
      @PathVariable String date,
      @PathVariable String fromDate,
      @PathVariable String toDate,
      @PathVariable Long sqlCd) {

    // ログ出力

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get sys_data_set_execute for report layout designer.");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);

    try {

      // sys_data_setリストのレスポンス生成
      java.util.Map<String, Object> param = new java.util.HashMap<String, Object>();
      Long[] ordNos = {ordNo};
      Long[] patIds = {patId};
      Long[] machineNos = {machineNo};
      param.put("facilityCd", ntssUser.getFacilityCd());
      param.put("ordNos", ordNos);
      param.put("ordNo", ordNo);
      param.put("patIds", patIds);
      param.put("patId", patId);
      param.put("machineNo", machineNo);
      param.put("machineNos", machineNos);
      param.put("fromDate", fromDate);
      param.put("toDate", toDate);
      param.put("date", date);
      List<Map<String, Object>> res = sysDataSetService.getDataList(sqlCd, param);

      // レスポンス作成
      return new ResponseEntity<>(res, HttpStatus.OK);

    } catch (Exception e) {

      // マスタが取得できなかった場合

      eventLogMessage.setLogMessage("Exception message : " +  e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }

  /**
   * 二次元帳票用データが正常に動作するかチェックするためのREST API
   * TODO:※別の方法でデータ取得が可能になった場合に削除
   *
   * @param ordNo
   * @param patId
   * @param machineNo
   * @param date yyyyMMdd
   * @param fromDate yyyyMMdd
   * @param toDate yyyyMMdd
   * @param sqlCd
   * @return
   */
  @GetMapping("/matrix/{ordNo}/{patId}/{machineNo}/{date}/{fromDate}/{toDate}/{sqlCd}")
  public ResponseEntity<?> getMatrixTest(
      @AuthenticationPrincipal NtssUser ntssUser,
      @PathVariable Long ordNo,
      @PathVariable Long patId,
      @PathVariable Long machineNo,
      @PathVariable String date,
      @PathVariable String fromDate,
      @PathVariable String toDate,
      @PathVariable Long sqlCd) {

    // ログ出力

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get matrix for report layout designer.");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
    try {

      // sys_data_setリストのレスポンス生成
      java.util.Map<String, Object> param = new java.util.HashMap<String, Object>();
      Long[] ordNos = {ordNo};
      Long[] patIds = {patId};
      Long[] machineNos = {machineNo};
      param.put("facilityCd", ntssUser.getFacilityCd());
      param.put("ordNos", ordNos);
      param.put("ordNo", ordNo);
      param.put("patIds", patIds);
      param.put("patId", patId);
      param.put("machineNo", machineNo);
      param.put("machineNos", machineNos);
      param.put("fromDate", fromDate);
      param.put("toDate", toDate);
      param.put("date", date);
      /* modify by yuqinlong  2023-01-31 [CodeOptimization]  start */
//      List<Map<String, Object>> res = sysDataSetService.getDataList(sqlCd, param);
//
//      //
//      List<String> rowList = new ArrayList<String>(){
//        {
//          add("bed_name");
//        }
//      };
//      List<String> colList = new ArrayList<String>(){
//        {
//          add("treat_date");
//          add("ind_treat_start_time");
//        }
//      };
//      List<String> valList = new ArrayList<String>(){
//        {
//          add("pat_id");
//          add("pat_name");
//        }
//      };
//      res = sysDataSetService.getMatrixDataList(res, rowList, colList, valList );

      List<Map<String, Object>> res = reportDesignerService.getMatrixTest(sqlCd, param);
      /* modify by yuqinlong  2023-01-31 [CodeOptimization]  end */

      // レスポンス作成
      return new ResponseEntity<>(res, HttpStatus.OK);

    } catch (Exception e) {

      // マスタが取得できなかった場合

      eventLogMessage.setLogMessage("Exception message : " +  e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }

  // ADD #10637 2024/09/05 Thach Start

  /**
   * 帳票のファイルダウンロード処理.
   *
   * @param request ファイルダウンロードのリクエスト
   * @return ファイルダウンロード用ResponseEntity
   */
  @GetMapping("/download/{reportCd}")
  public ResponseEntity<?> downloadReport(@PathVariable(name = "reportCd", required = true) long reportCd) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to download report.");
    eventLogMessage.setInvokeClass(this.getClass().getName());
    logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_DETAIL, SERVICE_NAME.FNSI,
    null);

    try {
      byte[] content = reportDesignerService.getReportFile(reportCd);
      String hexString = HexFormat.of().withUpperCase().formatHex(content);
      return new ResponseEntity<>(hexString, HttpStatus.OK);
    } catch (Exception e) {
      // エラーメッセージをログ出力
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  // ADD #10637 2024/09/05 Thach End

  /**
   * 印刷データファイルのダウンロード処理.
   *
   * @param request ファイルダウンロードのリクエスト
   * @return ファイルダウンロード用ResponseEntity
   */
  @PostMapping("/forPrintServer/download")
  public ResponseEntity<?> downloadPrintFile(@Valid @RequestBody DownloadRequest request) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to forPrintServer download.");
    eventLogMessage.setInvokeClass(this.getClass().getName());
    logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);

    // 印刷ファイルはS3保存しない為、ローカルから取得
    try {
      // add 9601 印刷サーバにて帳票の印刷が行われない　吉 start
      String hostIp = InetAddress.getLocalHost().getHostAddress();
      String serveIp = request.getServiceIp();
      if(hostIp.equals(serveIp)){
        // add 9601 印刷サーバにて帳票の印刷が行われない　吉 end
        String bucket = request.getBucket();
        String filename = request.getFilename();
        String fileLocation = bucket + "/" + filename;
        Path path = Paths.get(fileLocation);
        byte[] bytes = Files.readAllBytes(path);
        // 16進数文字列に変換
        String hexString = HexFormat.of().withUpperCase().formatHex(bytes);
        return new ResponseEntity<>(hexString, HttpStatus.OK);
        // add 9601 印刷サーバにて帳票の印刷が行われない　吉 start
      }else{
        URI uri = null;
        try {
          StringBuilder uriBuilder = new StringBuilder();
          uriBuilder.append("http://")
            .append(serveIp)
            .append(":")
            .append(port)
            .append("/ntss-admin-web/api/report_designer/forPrintServer/getFileByServeIp");
          String url = uriBuilder.toString();
          uri = new URI(url);
        } catch (URISyntaxException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
          logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
          return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
        Map<String, Object> payloadMap = new HashMap<>();
        payloadMap.put("bucket", request.getBucket());
        payloadMap.put("filename", request.getFilename());
        try {
          HttpHeaders headers = new HttpHeaders();
          headers.setAccept(Arrays.asList(MediaType.APPLICATION_JSON));
          HttpEntity<Object> httpEntity = new HttpEntity<>(payloadMap, headers);
		  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
          RequestEntity<Map<String, Object>> logRequest = RequestEntity.post(uri).
            contentType(MediaType.APPLICATION_JSON).headers(headers)
            .body(payloadMap);
          RestTemplate rt = new RestTemplate();
          long start = System.currentTimeMillis();
          ResponseEntity<String> response = rt.exchange(uri, HttpMethod.POST, httpEntity, String.class);
          String result = response.getBody();
          long cost = System.currentTimeMillis() - start;
          Map<String, Object> map = new HashMap<>();
          map.put("logType", "RESTTEMPLATE-LOG");
          map.put("className", "jp.co.nikkiso.ntss.admin_web.web.rest.ReportDesignerResource");
          map.put("methodName", "downloadPrintFile");
          map.put("method", logRequest.getMethod());
          map.put("url", logRequest.getUrl());
          map.put("headers", logRequest.getHeaders().toSingleValueMap());
          map.put("requestParameter", logRequest.getBody());
          map.put("status",response.getStatusCode());
          map.put("cost", cost);
          map.put("result",response.getBody());
          EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
          restTemplateEventLogMessage.setLogMessage(toJson(map));
          logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
          return new ResponseEntity<>(result, HttpStatus.OK);
        } catch (RestClientException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
          logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
          return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
      }
      // add 9601 印刷サーバにて帳票の印刷が行われない　吉 end
    } catch (Exception e) {
      // エラーメッセージをログ出力
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  // add 9601 印刷サーバにて帳票の印刷が行われない　吉 start
  @PostMapping("/forPrintServer/getFileByServeIp")
  public ResponseEntity<?> getFileByServeIp(@Valid @RequestBody DownloadRequest request) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to getFileByServeIp.");
    eventLogMessage.setInvokeClass(this.getClass().getName());
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
    try {
      String bucket = request.getBucket();
      String filename = request.getFilename();
      String fileLocation = bucket + "/" + filename;
      Path path = Paths.get(fileLocation);
      byte[] bytes = Files.readAllBytes(path);
      // 16進数文字列に変換
      String hexString = HexFormat.of().withUpperCase().formatHex(bytes);
      return new ResponseEntity<>(hexString, HttpStatus.OK);
    } catch (Exception e) {
      // エラーメッセージをログ出力
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  // add 9601 印刷サーバにて帳票の印刷が行われない　吉 end
}
