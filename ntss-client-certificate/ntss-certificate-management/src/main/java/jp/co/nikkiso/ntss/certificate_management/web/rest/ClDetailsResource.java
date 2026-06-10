package jp.co.nikkiso.ntss.certificate_management.web.rest;

import java.sql.Timestamp;
import java.util.Date;
import java.util.List;

import jp.co.nikkiso.ntss.core.dto.ClDetail.ClDetails;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

import jp.co.nikkiso.ntss.certificate_management.constant.ClientCertificateConstant.ScreenName;
import jp.co.nikkiso.ntss.certificate_management.constant.ClientCertificateConstant.Uri;
import jp.co.nikkiso.ntss.certificate_management.service.ClDetailsService;
import jp.co.nikkiso.ntss.certificate_management.service.ClFacilityService;
import jp.co.nikkiso.ntss.certificate_management.service.log.LogService;
import jp.co.nikkiso.ntss.core.entity.ClDetail;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

@Service
@RequestMapping(Uri.CLDETAILS)
public class ClDetailsResource {

    // クライアント証明書サービス
    @Autowired
    ClDetailsService clDetailsService;

    // クライアント施設サービス
    @Autowired
    ClFacilityService clFacilityService;

    // ロギングサービス
    @Autowired
    LogService logService;

    /**
     * 証明書を挿入
     *
     * @param clDetail クライアント詳細オブジェクト
     * @return ストリング
     */
    @PostMapping("/insertCl")
    public ResponseEntity<String> insert(@RequestBody ClDetail clDetail) {
        try {
            Date now = new Date();
            Timestamp timestamp = new Timestamp(now.getTime());
            //mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start
            //clDetailsService.insertCl(clDetail.getPasswordCl(), clDetail.getExpiredDate(), clDetail.getMaxDownload(), 0,
                    //clDetail.getFacilityCd(), clDetail.getLatestIssuedUser(), timestamp, timestamp);
              clDetailsService.insertCl(clDetail.getPasswordCl(), clDetail.getFacilityCd(), clDetail.getManyFacilityCd(), clDetail.getManyFacilityName(), clDetail.getLatestIssuedUser(), timestamp, timestamp);
          //mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end
            return new ResponseEntity<String>("Success", HttpStatus.OK);
        } catch (final Exception e) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            String errMsg = e.getMessage();
            if (errMsg == null) {
                errMsg = e.toString() + " " + e.getStackTrace()[0];
            }
            eventLogMessage.setLogMessage("jp.co.nikkiso.ntss.certificate_management.web.rest.ClDetailsResource.java method:insert エラー: " + errMsg);
            logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.MANAGEMENT_CL_ISSUE, null);
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    /**
     * 施設コード別の証明書を選択
     *
     * @param facilityCd 施設コード.
     * @return クライアント詳細オブジェクト.
     */
    @GetMapping("/selectByFacilityCd")
    public ResponseEntity<ClDetail> selectCertificateByFacilityCd(String facilityCd) {
        try {
            ClDetail clDetails = clDetailsService.selectCertificateByFacilityCd(facilityCd);
            return new ResponseEntity(clDetails, HttpStatus.OK);
        } catch (final Exception e) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            String errMsg = e.getMessage();
            if (errMsg == null) {
                errMsg = e.toString() + " " + e.getStackTrace()[0];
            }
            eventLogMessage.setLogMessage("jp.co.nikkiso.ntss.certificate_management.web.rest.ClDetailsResource.java method:selectCertificateByFacilityCd  エラー: " + errMsg);
            logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.MANAGEMENT_CL_ISSUE, null);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
//del FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start
//    /**
//     * 更新証明書
//     *
//     * @param clDetail クライアント詳細オブジェクト
//     * @return ストリング
//     */
//    @PostMapping("/updateCl")
//    public ResponseEntity<String> updateCl(@RequestBody ClDetail clDetail) {
//        try {
//            Date now = new Date();
//            Timestamp timestamp = new Timestamp(now.getTime());
//            //mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start
////            clDetailsService.updateCl(clDetail.getPasswordCl(), clDetail.getExpiredDate(), clDetail.getMaxDownload(),
////                    clDetail.getFacilityCd(), clDetail.getLatestIssuedUser(), timestamp);
//              clDetailsService.updateCl(clDetail.getPasswordCl(), clDetail.getFacilityCd(), clDetail.getLatestIssuedUser(), timestamp);
//            //mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start
//            return new ResponseEntity<String>("Success", HttpStatus.OK);
//        } catch (final Exception e) {
//            EventLogMessage eventLogMessage = new EventLogMessage();
//            String errMsg = e.getMessage();
//            if (errMsg == null) {
//                errMsg = e.toString() + " " + e.getStackTrace()[0];
//            }
//            eventLogMessage.setLogMessage("REST to update ClDetails: " + errMsg);
//            logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.MANAGEMENT_CL_ISSUE, null);
//            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
//        }
//    }
//del FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end
//    /**
//     * 証明書の更新パスワードなし
//     *
//     * @param clDetail クライアント詳細オブジェクト
//     * @return ストリング
//     */
//    @PostMapping("/updateClNoPassword")
//    public ResponseEntity<String> updateClNoPassword(@RequestBody ClDetail clDetail) {
//        try {
//            Date now = new Date();
//            Timestamp timestamp = new Timestamp(now.getTime());
//            clDetailsService.updateClNoPassword(clDetail.getExpiredDate(), clDetail.getMaxDownload(),
//                    clDetail.getFacilityCd(), clDetail.getLatestIssuedUser(), timestamp);
//            return new ResponseEntity<String>("Update Cl no password success", HttpStatus.OK);
//        } catch (final Exception e) {
//            EventLogMessage eventLogMessage = new EventLogMessage();
//            String errMsg = e.getMessage();
//            if (errMsg == null) {
//                errMsg = e.toString() + " " + e.getStackTrace()[0];
//            }
//            eventLogMessage.setLogMessage("REST to update ClDetails except password: " + errMsg);
//            logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.MANAGEMENT_CL_ISSUE, null);
//            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
//        }
//    }
   //add FNSI-【1006】最新の改修対象一覧.NO50を追加 周安寧 start
  /**
   * 証明書を無効化
   *
   * @param clDetail 施設コード.
   * @return ストリング
   */
  @PostMapping("/deleteCl")
  public ResponseEntity<String> certificateDisable(@RequestBody ClDetail clDetail) {
    try {
      Date now = new Date();
      Timestamp timestamp = new Timestamp(now.getTime());
      clDetailsService.certificateDisable(clDetail.getFacilityCd(), clDetail.getManyFacilityCd(), clDetail.getClCertificateId().toString());
      clDetailsService.deleteCl(clDetail.getFacilityCd(), clDetail.getClCertificateId(), timestamp);
      return new ResponseEntity<String>("Success", HttpStatus.OK);
    } catch (final Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      String errMsg = e.getMessage();
      if (errMsg == null) {
        errMsg = e.toString() + " " + e.getStackTrace()[0];
      }
      eventLogMessage.setLogMessage("jp.co.nikkiso.ntss.certificate_management.web.rest.ClDetailsResource.java method:certificateDisable エラー: " + errMsg);
      logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.MANAGEMENT_SHOW, null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  /**
   * ダウンロードサイトで発行されたCL証明書
   *
   * @param facilityCd 施設コード.
   * @return ストリング
   */
  @GetMapping("/selectAllCertificatesByFacilityCd")
  public ResponseEntity<List<ClDetails>> selectAllCertificatesByFacilityCd(String facilityCd) {
    try {
      List<ClDetails> list = clDetailsService.selectAllCertificatesByFacilityCd(facilityCd);

      for (ClDetails clDetail: list) {
        if (StringUtils.isEmpty(clDetail.getManyFacilityCd())) {
          clDetail.setManyFacilityName(clDetail.getFacilityName());
        }
      }
      return new ResponseEntity<>(list, HttpStatus.OK);
    } catch (final Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      String errMsg = e.getMessage();
      if (errMsg == null) {
        errMsg = e.toString() + " " + e.getStackTrace()[0];
      }
      eventLogMessage.setLogMessage("jp.co.nikkiso.ntss.certificate_management.web.rest.ClDetailsResource.java method:selectAllCertificatesByFacilityCd エラー: " + errMsg);
      logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.MANAGEMENT_SHOW, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  //add FNSI-【1006】最新の改修対象一覧.NO50を追加 周安寧 end

  // add FNSI-4448修正 解 start
  /**
   * ダウンロードサーバ取得
   *
   * @return ストリング
   */
  @GetMapping("/getDownloadServer")
  public ResponseEntity<String> getDownloadServer() {
    try {
      String server = clDetailsService.getDownloadServer();
      return new ResponseEntity<>(server, HttpStatus.OK);
    } catch (final Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      String errMsg = e.getMessage();
      if (errMsg == null) {
        errMsg = e.toString() + " " + e.getStackTrace()[0];
      }
      eventLogMessage.setLogMessage("jp.co.nikkiso.ntss.certificate_management.web.rest.ClDetailsResource.java method:getDownloadServer エラー: " + errMsg);
      logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.MANAGEMENT_SHOW, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  // add FNSI-4448修正 解 end
}
