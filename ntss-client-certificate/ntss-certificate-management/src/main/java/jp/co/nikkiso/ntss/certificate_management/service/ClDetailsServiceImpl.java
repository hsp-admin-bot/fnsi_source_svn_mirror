package jp.co.nikkiso.ntss.certificate_management.service;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.TreeSet;
import java.nio.file.StandardCopyOption;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import jp.co.nikkiso.ntss.certificate_management.constant.ClientCertificateConstant;
import jp.co.nikkiso.ntss.certificate_management.service.log.LogService;
import jp.co.nikkiso.ntss.core.dao.ClFacilityDao;
import jp.co.nikkiso.ntss.core.dto.ClDetail.ClDetails;
import jp.co.nikkiso.ntss.core.logger.ExceptionMessageUtil;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.apache.commons.io.FileUtils;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Value;
import jp.co.nikkiso.ntss.core.dao.ClDetailsDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.ClDefineDao;
import jp.co.nikkiso.ntss.core.entity.ClDetail;
import jp.co.nikkiso.ntss.core.dto.ClDetail.ClDetailsDownload;
import jp.co.nikkiso.ntss.core.entity.ClDefine;
import org.springframework.util.StringUtils;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
@Service
public class ClDetailsServiceImpl implements ClDetailsService {

  // 国名
  //del FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 start
  //@Value("${ntss.cl-certificate.cl-details.country-name}")
  //del FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 end
  private String countryName;

  // 州または県名前
  //del FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 start
  //@Value("${ntss.cl-certificate.cl-details.state-or-province-name}")
  //del FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 end
  private String stateOrProvinceName;

  // 地域名
  //del FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 start
  //@Value("${ntss.cl-certificate.cl-details.locality-name}")
  //del FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 end
  private String localityName;

  // 組織名
  //del FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 start
  //@Value("${ntss.cl-certificate.cl-details.organization-name}")
  //del FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 end
  private String organizationName;

  // 組織単位名
  //del FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 start
  //@Value("${ntss.cl-certificate.cl-details.organizational-unit-name}")
  //del FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 end
  private String organizationalUnitName;
  //del FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 start
  // 認証局パスワード
  //@Value("${ntss.cl-certificate.cl-details.ca-pass}")
  //private String caPassword;
  //del FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 end
  // デフォルト日付
  //del FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 start
  //@Value("${ntss.cl-certificate.cl-details.default-days}")
  //del FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 end
  private String defaultDays;

  // クライアント証明書のパス
  @Value("${ntss.cl-certificate.certificate-path}")
  private String certificatePath;

  // 無効リストのパス
  @Value("${ntss.cl-certificate.ssl_crl-path}")
  private String sslCrlPath;

  @Value("${ntss.cl-certificate.p12-path}")
  private String clientCertificatePath;

  private String demoCaPath;

  // クライアント証明書（認証DB）Daoインターフェース。
  @Autowired
  ClDetailsDao clDetailsDao;

  @Autowired
  MstFacilityDao mstFacilityDao;

  //add FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 start
  @Autowired
  ClDefineDao clDefineDao;

  @Autowired
  private ClFacilityDao clFacilityDao;

  public static final short CTL_NO = 1;

  private String newFileName;

  @Value("${ntss.cl-certificate.conf-path}")
  private String confPath;

  @Value("${ntss.cl-certificate.env-name}")
  private String certEnvName;
  // ロギングサービス
  @Autowired
  LogService logService;
  //add FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 end
  @Override
  //mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start
  //public void insertCl(String passwordCl, Timestamp expiredDate, int maxDownload, int curDownload, String facilityCd,
                       //String latestIssuedUser, Timestamp regDate, Timestamp upDate) throws Exception {
  public void insertCl(String passwordCl, String facilityCd, String manyFacilityCd, String manyFacilityName, String latestIssuedUser, Timestamp regDate, Timestamp upDate) throws Exception {
    //mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end
    // 重複チェック：同一 facility_cd で同じ CN の組み合わせが既に存在する場合はエラー（順序違いも重複とみなす）
    // 管理端発行ファイルは file_rand_suffix を持たず固定パスに保存されるため、
    // 同一 CN 組み合わせの2回発行はファイル上書きとなる。それを防ぐために必須。
    if (!StringUtils.isEmpty(manyFacilityCd)) {
      List<ClDetail> existing = clDetailsDao.selectClCertificateByFacilityCd(facilityCd);
      if (existing != null && !existing.isEmpty()) {
        TreeSet<String> newSet = new TreeSet<>(Arrays.asList(manyFacilityCd.trim().split("\\s+")));
        for (ClDetail detail : existing) {
          if (!StringUtils.isEmpty(detail.getManyFacilityCd())) {
            TreeSet<String> existSet = new TreeSet<>(Arrays.asList(detail.getManyFacilityCd().trim().split("\\s+")));
            if (newSet.equals(existSet)) {
              throw new Exception("同じ証明書の組み合わせが既に登録されています。many_facility_cd=\"" + detail.getManyFacilityCd() + "\"");
            }
          }
        }
      }
    }
    //mod FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 start
    //issueCertificate(caPassword, facilityCd, passwordCl);
    issueCertificate(facilityCd, manyFacilityCd, passwordCl);
    //mod FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 end
    // add #7831 「ログにPWが出力されている」について、対応する。 鄧シン start
    List<String> pwdLst = clDetailsDao.selectPasswordEncrypt(passwordCl);
    if (pwdLst != null) {
      passwordCl = pwdLst.get(0);
    }
    // add #7831 「ログにPWが出力されている」について、対応する。 鄧シン end
    //mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start
//    clDetailsDao.insertCl(passwordCl, expiredDate, maxDownload, curDownload, facilityCd, latestIssuedUser,
//      regDate, upDate);
    clDetailsDao.insertCl(passwordCl, facilityCd, manyFacilityCd, manyFacilityName, latestIssuedUser, regDate, upDate);
    //mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start
  }

  //@Override
  //mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start
  //public void updateCl(String passwordCl, Timestamp expiredDate, int maxDownload, String facilityCd,
                       //String latestIssuedUser, Timestamp upDate) throws Exception {
//  public void updateCl(String passwordCl, String facilityCd, String latestIssuedUser, Timestamp upDate) throws Exception {
//    //mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end
//    //mod FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 start
//    //issueCertificate(caPassword, facilityCd, passwordCl);
//    //issueCertificate(facilityCd, passwordCl);
//    //mod FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 end
//    //mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start
//    //clDetailsDao.updateCl(passwordCl, expiredDate, maxDownload, facilityCd, latestIssuedUser, upDate);
//    clDetailsDao.updateCl(passwordCl,facilityCd, latestIssuedUser, upDate);
//    //mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end
//  }

  @Override
  public ClDetail selectCertificateByFacilityCd(String facilityCd) throws Exception {
    ClDetail clDetail = clDetailsDao.selectNotDeteteClCertificateByFacilityCd(facilityCd);
    if (clDetail != null) {
      clDetail.setIssueDate(convertStringFromTimestamp(clDetail.getRegDate()));
    }
    //mod FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 start
//    if (clDetail != null) {
//      clDetail.setPasswordCl(null);
//    }
    //mod FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 end
    return clDetail;
  }
//  @Override
//  public void updateClNoPassword(Timestamp expiredDate, int maxDownload, String facilityCd, String latestIssuedUser,
//                                 Timestamp upDate) throws Exception {
//    ClDetail clDetail = clDetailsDao.selectClCertificateByFacilityCd(facilityCd);
//    if (clDetail != null) {
//      String passwordCl = clDetail.getPasswordCl();
//      //mod FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 start
//      //issueCertificate(caPassword, facilityCd, passwordCl);
//      issueCertificate(facilityCd, passwordCl);
//      //mod FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 start
//      clDetailsDao.updateClNoPassword(expiredDate, maxDownload, facilityCd, latestIssuedUser, upDate);
//    }
//  }

  @Override
  public List<ClDetailsDownload> selectClCertificateByFacilityCdWithName(String facilityCd) throws Exception {
    String facilityName = mstFacilityDao.selectNameByCd(facilityCd);
    List<ClDetail> clDetails = clDetailsDao.selectClCertificateByFacilityCd(facilityCd);

    List<ClDetailsDownload>  ClDetailsDownloads = new ArrayList<>();
    for (ClDetail clDetail: clDetails) {
      ClDetailsDownload clDetailsDownload = new ClDetailsDownload();
      clDetailsDownload.setPasswordCl(null);
      clDetailsDownload.setExpiredDate(clDetail.getExpiredDate());
      clDetailsDownload.setMaxDownload(clDetail.getMaxDownload());
      clDetailsDownload.setCurDownload(clDetail.getCurDownload());
      clDetailsDownload.setFacilityCd(clDetail.getFacilityCd());
      clDetailsDownload.setClCertificateId(clDetail.getClCertificateId());
      clDetailsDownload.setFacilityName(facilityName);
      clDetailsDownload.setManyFacilityName(clDetail.getManyFacilityName());
    }

    return ClDetailsDownloads;
  }

//  @Override
//  public void updateCurDownload(String facilityCd, int curDownload, Timestamp upDate) throws Exception {
//    clDetailsDao.updateCurDownload(facilityCd, curDownload, upDate);
//  }
//

  //mod FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 start
  //    /**
  //     * 証明書を発行する
  //     * @param caPass 認証局パスワード.
  //     * @param facilityCdClient 施設コード.
  //     * @param passwordCl 証明書のパスワード.
  //     * @throws Exception
  //     */
  //    public void issueCertificate(String caPass, String facilityCdClient, String passwordCl) throws Exception {

  /**
   * 証明書を発行する
   *
   * @param facilityCdClient 施設コード.
   * @param passwordCl       証明書のパスワード.
   * @throws Exception
   */
  public void issueCertificate(String facilityCdClient, String manyFacilityCdClient, String passwordCl) throws Exception {
    //mod FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 end
    File dir = new File(clientCertificatePath + "/" + facilityCdClient);
    if (!dir.exists()) {
      Path path = Paths.get(clientCertificatePath + "/" + facilityCdClient);
      try {
        Files.createDirectories(path);
      } catch (Exception e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExceptionMessageUtil.getErrorMessage(e));
        logService.log(LogLevel.ERROR, eventLogMessage, null, ClientCertificateConstant.ScreenName.MANAGEMENT_CL_ISSUE, null);
        throw new Exception("フォルダー機能コードを作成できません. ");
      }
    }
    try {//add FNSI-【6301】最後にopensslの一時ファイルを削除(opensslxxxxxxxx.cnf)。ljx
      File caCer = new File(certificatePath + "/serverCA.crt");
      File caKey = new File(certificatePath + "/serverprivate.key");
      //add FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 start
      selectClCertificatedefine(facilityCdClient, manyFacilityCdClient);
      //add FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 end
      if (!caCer.exists() || !caKey.exists()) {
        throw new Exception("ファイル認証局が見つかりません. ");
      } else {
        ArrayList<String[]> listCmd = new ArrayList<String[]>();
        listCmd.add(new String[]{"openssl", "genrsa", "-out", "clientprivate.key", "4096"});
        //mod FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 start
                /*listCmd.add(new String[] { "openssl", "req", "-new", "-key", "clientprivate.key", "-out", "client.csr", "-subj",
                       "/C=" + countryName + "/ST=" + stateOrProvinceName + "/L=" + localityName + "/O="
                                + organizationName + "/OU=" + organizationalUnitName + "/CN=" + facilityCdClient});*/
        listCmd.add(new String[]{"openssl", "req", "-new", "-key", "clientprivate.key", "-out", "client.csr", "-config",
          newFileName, "-batch"});
        //mod FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 end
        //mod FNSI-【1006】最新の改修対象一覧.NO49を追加 周安寧 start
          /*listCmd.add(new String[] { "openssl", "x509", "-req", "-in", "client.csr", "-CA", "serverCA.crt", "-CAkey",
                  "serverprivate.key", "-CAcreateserial", "-out", "client.crt", "-days", defaultDays, "-passin", "pass:" + caPass });*/
        listCmd.add(new String[]{"openssl", "x509", "-req", "-in", "client.csr", "-CA", "serverCA.crt", "-CAkey",
          "serverprivate.key", "-CAcreateserial", "-out", manyFacilityCdClient + "client.crt", "-days", defaultDays});
        //mod FNSI-【1006】最新の改修対象一覧.NO49を追加 周安寧 end
        listCmd.add(new String[]{"openssl", "pkcs12", "-export", "-inkey", "clientprivate.key", "-in", manyFacilityCdClient + "client.crt",
          "-out", getFacilityCdClient(facilityCdClient, manyFacilityCdClient) + ".p12", "-passin", "pass:" + passwordCl, "-passout",
          "pass:" + passwordCl});
        for (String[] strArr : listCmd) {
          Path path = Paths.get(certificatePath);
          Process p = Runtime.getRuntime().exec(strArr, null, path.toFile());
          p.waitFor();
        }
        //del FNSI-【1006】最新の改修対象一覧.NO52を追加 周安寧 start
        //File clientCer = new File(certificatePath + "/client.crt");
        //del FNSI-【1006】最新の改修対象一覧.NO52を追加 周安寧 end
        File clientKey = new File(certificatePath + "/clientprivate.key");
        File clientReq = new File(certificatePath + "/client.csr");
        //add FNSI-【6301】ここで削除不要、最後に削除するように変更。ljx
        //add FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 start
        //File newFile = new File(newFileName);
        //newFile.delete();
        //add FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 end
        if (!(clientKey.delete() && clientReq.delete())) {
          throw new Exception("ファイルクライアントの削除に失敗しました. ");
        }

        Path result = Files.move(
          Paths.get(certificatePath + "/" + getFacilityCdClient(facilityCdClient, manyFacilityCdClient) + ".p12"),
          Paths.get(clientCertificatePath + "/" + facilityCdClient + "/"
            + getFacilityCdClient(facilityCdClient, manyFacilityCdClient) + ".p12"),
          StandardCopyOption.REPLACE_EXISTING);
        if (result == null)
          throw new Exception("ファイル.p12をフォルダー機能コードに移動できません. ");
        //add FNSI-【1006】最新の改修対象一覧.NO50を追加 周安寧 start
        Path resultCer = Files.move(
          Paths.get(certificatePath + "/" + manyFacilityCdClient + "client.crt"),
          Paths.get(clientCertificatePath + "/" + facilityCdClient + "/"
            + manyFacilityCdClient + "client.crt"),
          StandardCopyOption.REPLACE_EXISTING);
        if (resultCer == null)
          throw new Exception("ファイル.crtをフォルダー機能コードに移動できません. ");
        //add FNSI-【1006】最新の改修対象一覧.NO50を追加 周安寧 end
      }
    //add FNSI-【6301】最後にopensslの一時ファイルを削除(opensslxxxxxxxx.cnf)。ljx start
    }finally {
      File newFile = new File(newFileName);
      if(newFile.exists()){
        newFile.delete();
      }
    }
    //add FNSI-【6301】最後にopensslの一時ファイル(opensslxxxxxxxx.cnf)を削除。ljx end

  }
  //add FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 start

  // add FNSI-44480修正 解 start

  /**
   * ダウンロードサーバ取得
   * @return
   * @throws Exception
   */
  public String getDownloadServer() throws Exception {
    String server = "";
    ClDefine ClDefine = clDefineDao.selectClDefine(2);
    if (ClDefine != null) {
      if (!StringUtils.isEmpty(ClDefine.getValue())) {
        JSONObject json = new JSONObject(ClDefine.getValue());
        if (json != null) {
          server = json.getString("server");
          return server;
        }
      }
    }

    return "";
  }
  // add FNSI-44480修正 解 end

  /**
   * クライアント証明書の設定を取得する
   *
   * @throws Exception
   */
  public void selectClCertificatedefine(String facilityCdClient, String manyFacilityCdClient) throws Exception {
    //クライアント証明書の設定を取得
    ClDefine ClDefine = clDefineDao.selectClDefine(CTL_NO);

    if (ClDefine != null) {
      JSONObject CtlNoList = new JSONObject(ClDefine.getValue());
      if (null != CtlNoList && CtlNoList.length() > 0) {
        //国名
        countryName = CtlNoList.getString("countryName");
        //州または県名前
        stateOrProvinceName = CtlNoList.getString("stateOrProvinceName");
        //地域名
        localityName = CtlNoList.getString("localityName");
        //組織名
        organizationName = CtlNoList.getString("organizationName");
        //組織単位名
        organizationalUnitName = CtlNoList.getString("organizationalUnitName");
        //デフォルト日付
        defaultDays = CtlNoList.getString("defaultDays");
      }
      //openssl.cnfを読み取り
      try {
        String opensslConfPath = System.getenv(certEnvName) != null ? System.getenv(certEnvName) : confPath;
        File file = new File(opensslConfPath);
        List<String> list = FileUtils.readLines(file, "UTF-8");
        Iterator<String> iterator = list.iterator();
        while (iterator.hasNext()) {
          String item = iterator.next();
          if (item != null && (item.contains("default_days"))) {
            //DBでdefault_daysが空の場合
            if (StringUtils.isEmpty(defaultDays)) {
              String days = item.split("=")[1];
              //＃含む
              if (days.indexOf("#") != -1) {
                days = days.substring(0, days.indexOf("#"));
              }
              //スペース、改行、およびキャリッジリターンを削除します
              Pattern pat = Pattern.compile("\\s*|\t|\r|\n");
              Matcher mat = pat.matcher(days);
              defaultDays = mat.replaceAll("");
            }
          }

          if (item != null && ((item.contains("countryName_default") && !StringUtils.isEmpty(countryName)) ||
            (item.contains("stateOrProvinceName_default") && !StringUtils.isEmpty(stateOrProvinceName)) ||
            (item.contains("localityName_default") && !StringUtils.isEmpty(localityName)) ||
            (item.contains("0.organizationName_default") && !StringUtils.isEmpty(organizationName)) ||
            (item.contains("organizationalUnitName_default") && !StringUtils.isEmpty(organizationalUnitName)) ||
            item.contains("commonName_default"))) {
            //カラムcountryName_default,stateOrProvinceName_default,localityName_default,
            // organizationName_default,organizationalUnitName_default,commonName_defaultを削除します
            iterator.remove();
          }
        }
        //カラムcountryName_default,stateOrProvinceName_default,localityName_default,
        // organizationName_default,organizationalUnitName_default,commonName_defaultをします
        List<String> insArgs = new ArrayList<String>();
        if (!StringUtils.isEmpty(countryName)) {
          insArgs.add("countryName_default=" + countryName);
        }
        if (!StringUtils.isEmpty(stateOrProvinceName)) {
          insArgs.add("stateOrProvinceName_default=" + stateOrProvinceName);
        }
        if (!StringUtils.isEmpty(localityName)) {
          insArgs.add("localityName_default=" + localityName);
        }
        if (!StringUtils.isEmpty(organizationName)) {
          insArgs.add("0.organizationName_default=" + organizationName);
        }
        if (!StringUtils.isEmpty(organizationalUnitName)) {
          insArgs.add("organizationalUnitName_default=" + organizationalUnitName);
        }


        insArgs.add("commonName_default=" + getFacilityCdClient(facilityCdClient, manyFacilityCdClient));

        list.addAll(list.indexOf("[ req_distinguished_name ]") + 1, insArgs);

        //日付の書式
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMddHHmmss");
        //ファイル名
        newFileName = certificatePath + "/openssl" + dateFormat.format(new Date()) + ".cnf";

        File newFile = new File(newFileName);
        FileUtils.writeLines(newFile, "UTF-8", list, false);

      } catch (Exception e){
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("opensslの構成ファイルが指定されたパスに存在しません。" + ExceptionMessageUtil.getErrorMessage(e));
        logService.log(LogLevel.ERROR, eventLogMessage, null, ClientCertificateConstant.ScreenName.MANAGEMENT_CL_ISSUE, null);
        throw new Exception("証明書の発行に失敗しました。 ");
      }
    }
  }
  //add FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 end
  //add FNSI-【1006】最新の改修対象一覧.NO50を追加 周安寧 start
  /**
   * 証明書を無効化する
   *
   * @param facilityCdClient 施設コード.
   * @throws Exception
   */
  public void certificateDisable(String facilityCdClient, String manyFacilityCdClient, String id) throws Exception {

    EventLogMessage eventLogMessage = new EventLogMessage();
    File dir = new File(clientCertificatePath + "/" + facilityCdClient);
    if (!dir.exists()) {
      throw new Exception("フォルダー機能コードを作成できません. ");
    }
    try {
      String opensslConfPath = System.getenv(certEnvName) != null ? System.getenv(certEnvName) : confPath;
      demoCaPath = readCaDefaultDir(Paths.get(opensslConfPath));

      File ssldir = new File(sslCrlPath);
      if (!ssldir.exists()) {
        Path path = Paths.get(sslCrlPath);
        try {
          Files.createDirectories(path);
        } catch (Exception e) {
          eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExceptionMessageUtil.getErrorMessage(e));
          logService.log(LogLevel.ERROR, eventLogMessage, null, ClientCertificateConstant.ScreenName.MANAGEMENT_CL_ISSUE, null);
          throw new Exception("フォルダー(" + sslCrlPath + ")を作成できません. ");
        }
      }

      // is_merge_issued='1' の場合は file_rand_suffix 付きのファイル名で .crt を参照する
      // 例（通常）: NKKSBR CONV70client.crt
      // 例（merge）: NKKSBR CONV70_974client.crt
      String crtBaseName = manyFacilityCdClient;
      try {
        if (id != null) {
          ClDetail detail = clDetailsDao.selectById(Integer.parseInt(id));
          if (detail != null && !StringUtils.isEmpty(detail.getFileRandSuffix())) {
            crtBaseName = manyFacilityCdClient + "_" + detail.getFileRandSuffix();
          }
        }
      } catch (Exception ignored) {
        // サフィックス取得失敗時は元のファイル名で続行
      }
      File caCer = new File(certificatePath + "/serverCA.crt");
      File caKey = new File(certificatePath + "/serverprivate.key");
      File clientCer = new File(clientCertificatePath + "/" + facilityCdClient + "/" + crtBaseName + "client.crt");
      if (!caCer.exists() || !caKey.exists() || !clientCer.exists()) {
        eventLogMessage.setLogMessage("ファイル認証局が見つかりません。" + caCer.getPath() + " " + caKey.getPath() + " " + clientCer.getPath());
        logService.log(LogLevel.ERROR, eventLogMessage, null, ClientCertificateConstant.ScreenName.MANAGEMENT_CL_ISSUE, null);
        throw new Exception("ファイル認証局が見つかりません. ");
      } else {
        ArrayList<String[]> listCmd = new ArrayList<String[]>();
        listCmd.add(new String[]{"openssl", "ca", "-name", "CA_default", "-revoke", clientCertificatePath + "/" + facilityCdClient + "/" + crtBaseName + "client.crt"
          , "-keyfile", certificatePath + "/serverprivate.key", "-cert", certificatePath + "/serverCA.crt"});

        listCmd.add(new String[]{"openssl", "ca", "-gencrl",
          "-keyfile", certificatePath + "/serverprivate.key", "-cert", certificatePath + "/serverCA.crt", "-out"
          , sslCrlPath + "/certificate.crl", "-crldays", "7300"});

        for (String[] strArr : listCmd) {
          Path path = Paths.get(demoCaPath);
          Process p = Runtime.getRuntime().exec(strArr, null, path.toFile());
          p.waitFor();
          eventLogMessage.setLogMessage("実施されたコマンドパラメータ: " + Arrays.toString(strArr));
          logService.log(LogLevel.INFO, eventLogMessage, null, ClientCertificateConstant.ScreenName.MANAGEMENT_CL_ISSUE, null);
          eventLogMessage.setLogMessage("失効リストを作成しました。demoCaPath："+ demoCaPath + " ファイル: " + path.toFile());
          logService.log(LogLevel.INFO, eventLogMessage, null, ClientCertificateConstant.ScreenName.MANAGEMENT_CL_ISSUE, null);
        }
      }
    }catch (Exception e){
        eventLogMessage.setLogMessage("opensslの構成ファイルが指定されたパスに存在しません。" + ExceptionMessageUtil.getErrorMessage(e));
        logService.log(LogLevel.ERROR, eventLogMessage, null, ClientCertificateConstant.ScreenName.MANAGEMENT_CL_ISSUE, null);
        throw new Exception("証明書の無効化に失敗しました。 ");
    }
  }
  @Override
  public void deleteCl(String facilityCd, Integer clCertificateId, Timestamp upDate) throws Exception {
    clDetailsDao.deleteClDetails(facilityCd, clCertificateId, upDate);
    List<ClDetail>  clDetails = clDetailsDao.selectClCertificateByFacilityCd(facilityCd);
    if (clDetails == null || clDetails.size() == 0) {
      clFacilityDao.deleteClFacility(facilityCd, upDate);
    }
  }

  @Override
  public List<ClDetails> selectAllCertificatesByFacilityCd(String facilityCd) throws Exception {

    List<ClDetails> list = clDetailsDao.selectAllCertificatesByFacilityCd(facilityCd);

    return list;
  }
  //add FNSI-【1006】最新の改修対象一覧.NO50を追加 周安寧 end


  private String readCaDefaultDir(Path opensslConfPath) throws Exception {
    boolean inCaDefault = false;
    for (String rawLine : Files.readAllLines(opensslConfPath)) {
      String line = stripIniComment(rawLine).trim();
      if (line.isEmpty()) {
        continue;
      }
      if (line.startsWith("[") && line.endsWith("]")) {
        inCaDefault = "CA_default".equals(line.substring(1, line.length() - 1).trim());
        continue;
      }
      if (!inCaDefault) {
        continue;
      }
      int equalsIndex = line.indexOf('=');
      if (equalsIndex < 0) {
        continue;
      }
      String key = line.substring(0, equalsIndex).trim();
      if (!"dir".equals(key)) {
        continue;
      }
      String value = line.substring(equalsIndex + 1).trim();
      if (!StringUtils.hasText(value)) {
        break;
      }
      return value;
    }
    throw new Exception("openssl.cnf から [CA_default] dir を取得できません.");
  }

  private String stripIniComment(String line) {
    int hashIndex = line.indexOf('#');
    int semicolonIndex = line.indexOf(';');
    int commentIndex = -1;
    if (hashIndex >= 0 && semicolonIndex >= 0) {
      commentIndex = Math.min(hashIndex, semicolonIndex);
    } else if (hashIndex >= 0) {
      commentIndex = hashIndex;
    } else if (semicolonIndex >= 0) {
      commentIndex = semicolonIndex;
    }
    return commentIndex >= 0 ? line.substring(0, commentIndex) : line;
  }
  private String getFacilityCdClient(String facilityCd, String manyFacilityCd) {
    if (StringUtils.isEmpty(manyFacilityCd)) {
      return facilityCd;
    }

    if (manyFacilityCd.equals(facilityCd)) {
      return facilityCd;
    } else {
      return manyFacilityCd;
    }
  }

  // add 6360対応 xie start
  /**
   * timestampからStringに変更する
   * @param ts
   * @return
   */
  private String convertStringFromTimestamp(Timestamp ts) {
    try {
      SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
      String str = df.format(ts);
      return str;
    } catch(Exception e) {
      return "";
    }
  }
  // add 6360対応 xie end
}
