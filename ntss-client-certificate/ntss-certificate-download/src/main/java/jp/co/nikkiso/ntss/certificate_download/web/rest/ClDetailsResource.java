package jp.co.nikkiso.ntss.certificate_download.web.rest;

import java.sql.Timestamp;
import java.util.Date;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

import jp.co.nikkiso.ntss.certificate_download.constant.ClientCertificateConstant.ScreenName;
import jp.co.nikkiso.ntss.certificate_download.constant.ClientCertificateConstant.Uri;
import jp.co.nikkiso.ntss.certificate_download.service.ClDetailsService;
import jp.co.nikkiso.ntss.certificate_download.service.ClFacilityService;
import jp.co.nikkiso.ntss.certificate_download.service.log.LogService;
import jp.co.nikkiso.ntss.core.dto.ClDetail.ClDetailsDownload;
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
     * 名前付きファシリティコードによる証明書の選択
     *
     * @param facilityCd 施設コード.
     * @return クライアント詳細ダウンロード.
     */
    @GetMapping("/selectByFacilityCdWithNameMany")
    public ResponseEntity<List<ClDetailsDownload>> selectByFacilityCdWithNameMany(String facilityCd) {
        try {
            List<ClDetailsDownload> clDetailsDownload = clDetailsService.selectClCertificateByFacilityCdWithName(facilityCd);
            return new ResponseEntity(clDetailsDownload, HttpStatus.OK);
        } catch (final Exception e) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            String errMsg = e.getMessage();
            if (errMsg == null) {
                errMsg = e.toString() + " " + e.getStackTrace()[0];
            }
            eventLogMessage.setLogMessage("jp.co.nikkiso.ntss.certificate_download.web.rest.ClDetailsResource.java method:selectCertificateByFacilityCdWithName エラー: " + errMsg);
            logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.DOWNLOAD_SCREEN, null);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

  /**
   * 名前付きファシリティコードによる証明書の選択
   *
   * @param facilityCd 施設コード.
   * @return クライアント詳細ダウンロード.
   */
  @GetMapping("/selectByFacilityCdWithNameOnly")
  public ResponseEntity selectCertificateByFacilityCdWithNameOnly(String facilityCd) {
    try {
      ClDetailsDownload clDetailsDownload = clDetailsService.selectClCertificateByFacilityCdWithNameOnly(facilityCd);
      return new ResponseEntity(clDetailsDownload, HttpStatus.OK);
    } catch (final Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      String errMsg = e.getMessage();
      if (errMsg == null) {
        errMsg = e.toString() + " " + e.getStackTrace()[0];
      }
      eventLogMessage.setLogMessage("jp.co.nikkiso.ntss.certificate_download.web.rest.ClDetailsResource.java method:selectCertificateByFacilityCdWithName エラー: " + errMsg);
      logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.DOWNLOAD_SCREEN, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
    /**
     * 現在のダウンロードを更新
     *
     * @param clDetail クライアント詳細オブジェクト
     * @return ストリング
     */
    @PostMapping("/updateCurDownload")
    public ResponseEntity<String> updateCurDownload(@RequestBody ClDetail clDetail) {
        try {
            Date now = new Date();
            Timestamp timestamp = new Timestamp(now.getTime());
            //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
            //clDetailsService.updateCurDownload(clDetail.getFacilityCd(), clDetail.getCurDownload(), timestamp);
            clDetailsService.updateCurDownload(clDetail.getClCertificateId(),clDetail.getFacilityCd(), clDetail.getCurDownload(), timestamp);
            //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
           return new ResponseEntity<String>("Update current download successful", HttpStatus.OK);
        } catch (Exception e) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            String errMsg = e.getMessage();
            if (errMsg == null) {
                errMsg = e.toString() + " " + e.getStackTrace()[0];
            }
            eventLogMessage.setLogMessage("jp.co.nikkiso.ntss.certificate_download.web.rest.ClDetailsResource.java method:updateCurDownload エラー: " + errMsg);
            logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.DOWNLOAD_SCREEN, null);
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

  /**
   * 施設設定の取得
   *
   * @return 施設設置
   */
  @GetMapping("/getFacilityName")
  public ResponseEntity<String> getFacilityName(String facilityCd) {
    try {
      String facilityName = clFacilityService.getFacilityName(facilityCd);
      return new ResponseEntity<String>(facilityName, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      String errMsg = e.getMessage();
      if (errMsg == null) {
        errMsg = e.toString() + " " + e.getStackTrace()[0];
      }
      eventLogMessage.setLogMessage("jp.co.nikkiso.ntss.certificate_download.web.rest.ClDetailsResource.java エラー: " + errMsg);
      logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.DOWNLOAD_SCREEN, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
}
