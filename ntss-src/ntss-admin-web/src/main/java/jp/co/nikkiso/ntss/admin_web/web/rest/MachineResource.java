package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.io.IOException;
import java.net.URISyntaxException;
import java.util.List;

import jp.co.nikkiso.ntss.admin_web.service.master.machine.MstMachineService;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.response.MachinesResponse;
import jp.co.nikkiso.ntss.admin_web.response.partsRunning.PartsRunningResponse;
import jp.co.nikkiso.ntss.admin_web.service.machines.MachinesService;
import jp.co.nikkiso.ntss.admin_web.service.partsRunning.PartsRunningService;
import jp.co.nikkiso.ntss.core.entity.MstSelfMeasureResult;
import jp.co.nikkiso.ntss.core.entity.custom.Machine;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;


/**
 * 装置系画面のResourceクラス.
 * <p>
 * 装置系画面から呼び出されるDB処理
 * <p>
 */
@RestController
@RequestMapping(Uri.MACHINES)
public class MachineResource {

  // add #8118 2022/12/06 装置マスタから装置を削除すると治療状況ベッドレイアウトマスタが編集不可 dou start
  /**
   * 装置Service.
   */
  @Autowired
  private MstMachineService mstMachineService;
  // add #8118 2022/12/06 装置マスタから装置を削除すると治療状況ベッドレイアウトマスタが編集不可 dou end

  /**
   * 装置一覧Service.
   */
  @Autowired
  private MachinesService machinesService;

  /**
   * 部品運転/交換時間Service.
   */
  @Autowired
  private PartsRunningService partsRunningService;
	@Autowired
	LogService logService;

  // add #8118 2022/12/06 装置マスタから装置を削除すると治療状況ベッドレイアウトマスタが編集不可 dou start
  /**
   * 装置一覧取得.
   *
   * @param facilityCd 施設コード
   * @return 装置一覧
   */
  @GetMapping("mst_machine/{facilityCd}")
  public ResponseEntity<?> getMstmachines( @PathVariable String facilityCd,
                                           // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                           @AuthenticationPrincipal NtssUser ntssUser
                                           // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get Machines : " + facilityCd);
    logService.log(LogLevel.DEBUG, eventLogMessage,"", SERVICE_NAME.FNSI, null);
    // レスポンス生成
    List<MstMachine> response = mstMachineService.selectByFacility(facilityCd);

    return new ResponseEntity<>(response, HttpStatus.OK);

  }
  // add #8118 2022/12/06 装置マスタから装置を削除すると治療状況ベッドレイアウトマスタが編集不可 dou end

  /**
   * 装置一覧取得.
   * <code>isNkkFacility</code>に<code>true</code>を指定する事で戻り値に設定される
   * 最大イベント発生日時を取得する際の条件が異なる.
   *
   * <code>true</code>を指定した場合
   *  サービス対応区分が、'0':未受付、1:一次対応済み、<code>null</code>の最大イベント発生日時
   * <code>false</code>を指定した場合
   *  対処が'0':未対処、<code>null</code>の最大イベント発生日時
   *
   * @param facilityCd 施設コード
   * @param isNkkFacility 日機装施設に属しているか否か
   *                      属している場合は<code>true</code>を指定する.
   * @return 装置一覧画面のResponseEntity
   */
  @GetMapping("/{facilityCd}")
  public ResponseEntity<?> getMachines(
    @PathVariable String facilityCd,
    @RequestParam(name="isNkkFacility") boolean isNkkFacility
  ,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) throws URISyntaxException {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " " + "isNkkFacility=" + isNkkFacility + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get Machines : " + facilityCd + ":" + isNkkFacility);
    logService.log(LogLevel.DEBUG, eventLogMessage,"", SERVICE_NAME.FNSI, null);
    // レスポンス生成
    MachinesResponse response = machinesService.createMachinesResponse(facilityCd, isNkkFacility);

    return new ResponseEntity<>(response, HttpStatus.OK);

  }

  /**
   * 部品の運転/交換時間取得.
   * <p>
   * 装置選択状態のヘッダーエリアタップorスワイプ時に表示
   * </p>
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @return 部品の運転/交換時間のResponseEntity.
   */
  @GetMapping("/parts_running/{facilityCd}/{machineTypeCd}/{machineSerial}")
  public ResponseEntity<?> getPartsRunning(@PathVariable String facilityCd, @PathVariable String machineTypeCd,
      @PathVariable String machineSerial,
                                           // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                           @AuthenticationPrincipal NtssUser ntssUser
                                           // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " " + "machineTypeCd=" + machineTypeCd + " " + "machineSerial=" + machineSerial + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get PartsRunning : "+ facilityCd+ machineTypeCd+ machineSerial);
    logService.log(LogLevel.DEBUG, eventLogMessage,"", SERVICE_NAME.FNSI,
    null);
    // レスポンス生成
    try {
      PartsRunningResponse response = partsRunningService.createPartsRunningResponse(facilityCd, machineTypeCd,
          machineSerial);
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (IOException e) {
    	// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    	logService.log(LogLevel.DEBUG, eventLogMessage,"", SERVICE_NAME.FNSI,
    	null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }

  /**
   * 装置動作記録IDに該当するレコードから装置マスタを取得します。
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @return 装置マスタ
   */
  @GetMapping("/{facilityCd}/{machineTypeCd}/{machineSerial}")
  public ResponseEntity<?> getMachine(@PathVariable String facilityCd,
                                      @PathVariable String machineTypeCd,
                                      @PathVariable String machineSerial,
                                      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                      @AuthenticationPrincipal NtssUser ntssUser
                                      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " " + "machineTypeCd=" + machineTypeCd + " " + "machineSerial=" + machineSerial + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    try {
      // ログ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage( "REST request to get getMachine : "+ facilityCd+ machineTypeCd+ machineSerial);
      logService.log(LogLevel.DEBUG, eventLogMessage,"", SERVICE_NAME.FNSI,
      null);
      // サービスの呼び出し
      Machine machine = machinesService.getMachine(facilityCd, machineTypeCd, machineSerial);
      // 装置情報が取得出来ない場合
      if (null == machine) {
      eventLogMessage.setLogMessage( "指定された条件に該当する装置情報がありません。");
      logService.log(LogLevel.WARN, eventLogMessage,"", SERVICE_NAME.FNSI,
      null);
      }
      // 返却
      return new ResponseEntity<>(machine, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage( "指定された条件に該当する装置情報の取得に失敗しました。"+ e);
      logService.log(LogLevel.ERROR, eventLogMessage,"", SERVICE_NAME.FNSI,
      null);
    }
    return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
  }

  /**
   * 装置動作記録IDに該当するレコードから装置自己診断判定マスタを取得します。
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @return 自己診断判定情報
   */
  @GetMapping("/{facilityCd}/{machineTypeCd}")
  public ResponseEntity<?> getSelfMeasureResultInfo(@PathVariable String facilityCd, @PathVariable String machineTypeCd,
                                                    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                    @AuthenticationPrincipal NtssUser ntssUser
                                                    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " " + "machineTypeCd=" + machineTypeCd + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    try {
      // ログ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage( "REST request to get selfMeasureResultInfo : "+ facilityCd + " " + machineTypeCd);
      logService.log(LogLevel.DEBUG, eventLogMessage,"", SERVICE_NAME.REMS,
      null);
      // サービスの呼び出し
      List<MstSelfMeasureResult> res = machinesService.getSelfMeasureResultInfo(facilityCd, machineTypeCd);
      // 返却
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage( "自己診断判定情報の取得に失敗しました。"+ e);
      logService.log(LogLevel.ERROR, eventLogMessage,"", SERVICE_NAME.REMS,
      null);
    }
    return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
  }
}
