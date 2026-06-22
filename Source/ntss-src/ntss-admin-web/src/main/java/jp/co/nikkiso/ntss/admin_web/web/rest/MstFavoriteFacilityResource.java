package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.entity.custom.MstFavoriteFacilityDataT;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.service.master.favoriteFacility.MstFavoriteFacilityService;
import jp.co.nikkiso.ntss.core.entity.custom.SysFacilityData;

import lombok.extern.slf4j.Slf4j;

import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;



/**
 * よく使う施設マスタ画面のResourceクラス.
 */
@RestController
@Slf4j
@RequestMapping(Uri.MASTER_MAINTENANCE)
public class MstFavoriteFacilityResource {

    /**
     * よく使う施設一覧Service
     */
    @Autowired
    private MstFavoriteFacilityService mstFavoriteFacilityService;
    @Autowired
    LogService logService;

  //add by ztc 2023-03-01 [Optimize runtime No.8372] --start /
  /**
   * 全施設マスタ一覧の取得 改ページの追加
   */
  @PostMapping("/mst_favorite_facility/getSysFacility/{offset}")
  public ResponseEntity<?> getSysFacility(@PathVariable(name = "offset", required = true) String offset,
                                          @RequestParam(name = "selectedInsCd", required = true) String selectedInsCd,
                                          @RequestBody Map<String, Object> params) {
    Integer limit = 100;
    int offsetIer = Integer.parseInt(offset);
    String prefCd = String.valueOf(params.get("prefCd"));
    String freeWord = String.valueOf(params.get("freeWord"));
    try {
      List<SysFacilityData> response = mstFavoriteFacilityService.getSysFacilityByLimitAndOffset(limit, offsetIer, prefCd, freeWord, selectedInsCd);
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI,
        null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  //add by ztc 2023-03-01 [Optimize runtime No.8372] --end /

    // add FNSI-よく使う施設の変更 関 start
    @GetMapping("/mst_favorite_facility/getFacilityFavoriteFacility/{facilityCd}")
    /**
     * Favorite施設の取得
    */
    public ResponseEntity<?> getFacilityFavoriteFacility(@PathVariable String facilityCd,
                                                         // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie start
                                                         @AuthenticationPrincipal NtssUser ntssUser
                                                         // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie end
) {
        // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie start
            if(!ntssUser.isNkkAdminUser()) {
                if (facilityCd != null && !facilityCd.isEmpty() &&
                    !facilityCd.equals(ntssUser.getFacilityCd())) {
                    String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
                    InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
                    return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
                }
            }
        // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie end

      try {
        List<MstFavoriteFacilityDataT> response = mstFavoriteFacilityService.getFacilityFavoriteFacility(facilityCd);
        return new ResponseEntity<>(response, HttpStatus.OK);
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        EventLogMessage eventLogMessage = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (facilityCd != null) {
          eventLogMessage.setFacilityCd(facilityCd);
        }
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI,
          null);
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }
    }
  // add FNSI-よく使う施設の変更 関 end
}

