package jp.co.nikkiso.ntss.certificate_download.web.rest;

import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import jp.co.nikkiso.ntss.certificate_download.constant.ClientCertificateConstant.ScreenName;
import jp.co.nikkiso.ntss.certificate_download.constant.ClientCertificateConstant.Uri;
import jp.co.nikkiso.ntss.certificate_download.security.NtssUser;
import jp.co.nikkiso.ntss.certificate_download.service.P12CombineService;
import jp.co.nikkiso.ntss.certificate_download.service.log.LogService;
import jp.co.nikkiso.ntss.core.dao.ClDetailsDao;
import jp.co.nikkiso.ntss.core.entity.ClDetail;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

@Service
@RequestMapping(Uri.CLDOWNLOAD)
public class ClDownloadResource {

    // ロギングサービス
    @Autowired
    LogService logService;

    // P12結合再発行サービス
    @Autowired
    P12CombineService p12CombineService;

    @Autowired
    ClDetailsDao clDetailsDao;

    // クライアント証明書のパス
    @Value("${ntss.cl-certificate.p12-path}")
    private String certificatePath;



    /**
     * 証明書ファイルをダウンロードする
     *
     * @param facilityCd      施設コード
     * @param manyFacilityCd  複数施設コード（ファイル名の基底部分）
     * @param clCertificateId 証明書ID（任意）。指定時は DB の file_rand_suffix を参照し
     *                        ファイル名に付与する。旧データ（NULL）の場合はサフィックスなし。
     * @return ファイルストリーム
     * @throws IOException
     */
    @GetMapping("/downloadCertificate")
    public ResponseEntity<ByteArrayResource> downloadFile(String facilityCd, String manyFacilityCd, Integer clCertificateId) throws IOException {
        if (!StringUtils.isEmpty(manyFacilityCd) && manyFacilityCd.indexOf(";") >= 0) {
          manyFacilityCd = manyFacilityCd.replace(";", " ");
        }

        // file_rand_suffix の有無を DB から確認（後方互換：旧データは NULL のためサフィックスなし）
        String fileBaseName = manyFacilityCd;
        if (clCertificateId != null) {
            try {
                ClDetail detail = clDetailsDao.selectById(clCertificateId);
                if (detail != null && !StringUtils.isEmpty(detail.getFileRandSuffix())) {
                    fileBaseName = manyFacilityCd + "_" + detail.getFileRandSuffix();
                }
            } catch (Exception e) {
                // サフィックス取得失敗時はサフィックスなしで続行
            }
        }

        File clFile = new File(
                certificatePath + "/" + facilityCd + "/" + fileBaseName + ".p12");
        if (!clFile.exists()) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("REST to download file certificate: ファイル認証局が見つかりません");
            logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.DOWNLOAD_SCREEN, null);
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        } else {
            try {
                Path path = clFile.toPath();
                byte[] data = Files.readAllBytes(path);
                ByteArrayResource resource = new ByteArrayResource(data);
                return ResponseEntity.ok()
                        .header(HttpHeaders.CONTENT_DISPOSITION, "attachment;filename=" + path.getFileName().toString())
                        .contentType(MediaType.APPLICATION_OCTET_STREAM).contentLength(data.length).body(resource);
            } catch (Exception e) {
                EventLogMessage eventLogMessage = new EventLogMessage();
                String errMsg = e.getMessage();
                if (errMsg == null) {
                    errMsg = e.toString() + " " + e.getStackTrace()[0];
                }
                eventLogMessage.setLogMessage("jp.co.nikkiso.ntss.certificate_download.web.rest.ClDownloadResource.java method:downloadFile エラー: " + errMsg);
                logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.DOWNLOAD_SCREEN, null);
                return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
            }
        }
    }

    /**
     * 複数の .p12 から CN を抽出し、結合した CN で新しい証明書を再発行してレスポンスとして返す。
     * フロントエンドはこのレスポンスを直接ダウンロードし、その後ログアウトする。
     *
     * @param files          アップロードされた .p12 ファイル（1件以上）
     * @param passwords      各ファイルのパスワード（files と同じ順序）
     * @param outputPassword 出力 .p12 のパスワード（省略可）
     * @return 再発行された .p12 ファイルのバイト列
     */
    @PostMapping(value = "/mergeP12", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ByteArrayResource> mergeP12(
            @RequestParam("files") MultipartFile[] files,
            @RequestParam("passwords") String[] passwords,
            @RequestParam(name = "outputPassword", required = false, defaultValue = "") String outputPassword
    ) {
        try {
            NtssUser principal = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
            String facilityCd = principal.getUsername();
            P12CombineService.CombineResult result = p12CombineService.combineAndReissue(files, passwords, outputPassword, facilityCd, facilityCd);
            ByteArrayResource resource = new ByteArrayResource(result.p12Bytes);
            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + result.fileName)
                    .contentType(MediaType.APPLICATION_OCTET_STREAM)
                    .contentLength(result.p12Bytes.length)
                    .body(resource);
        } catch (IllegalArgumentException e) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(
                    "jp.co.nikkiso.ntss.certificate_download.web.rest.ClDownloadResource.java method:mergeP12 エラー: "
                            + e.getMessage());
            logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.DOWNLOAD_SCREEN, null);
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            String errMsg = e.getMessage();
            if (errMsg == null) {
                errMsg = e.toString() + " " + e.getStackTrace()[0];
            }
            eventLogMessage.setLogMessage(
                    "jp.co.nikkiso.ntss.certificate_download.web.rest.ClDownloadResource.java method:mergeP12 エラー: "
                            + errMsg);
            logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.DOWNLOAD_SCREEN, null);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
