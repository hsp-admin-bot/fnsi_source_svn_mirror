package jp.co.nikkiso.ntss.certificate_download.service;

import jp.co.nikkiso.ntss.core.dao.ClDefineDao;
import jp.co.nikkiso.ntss.core.dao.ClDetailsDao;
import jp.co.nikkiso.ntss.core.dao.ClFacilityDao;
import jp.co.nikkiso.ntss.core.entity.ClDefine;
import org.apache.commons.io.FileUtils;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import javax.naming.InvalidNameException;
import javax.naming.ldap.LdapName;
import javax.naming.ldap.Rdn;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.KeyStore;
import java.security.cert.Certificate;
import java.security.cert.X509Certificate;
import java.sql.Timestamp;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.concurrent.ThreadLocalRandom;

/**
 * 複数の既存 .p12 の CN をまとめて「1枚の新しい証明書」を再発行するサービス。
 *
 * - 各ファイルに個別パスワードを指定可能
 * - CN の区切り文字はスペース（例：CN="CONV70 CONV80 CONV90"）
 * - CA ファイル（serverCA.crt / serverprivate.key）を使って openssl で署名する
 */
@Service
public class P12CombineService {

  /**
   * combineAndReissue の戻り値。
   * 生成した .p12 のバイト列と、レスポンス用のファイル名を保持する。
   */
  public static class CombineResult {
    /** 生成された .p12 ファイルのバイト列 */
    public final byte[] p12Bytes;
    /** レスポンスの Content-Disposition に使用するファイル名（例: client_NKKSBR_CONV70_974.p12） */
    public final String fileName;

    public CombineResult(byte[] p12Bytes, String fileName) {
      this.p12Bytes = p12Bytes;
      this.fileName = fileName;
    }
  }

  private static final short CTL_NO = 1;
  private static final String CN_DELIMITER = " ";

  @Value("${ntss.cl-certificate.certificate-path}")
  private String certificatePath;

  @Value("${ntss.cl-certificate.p12-path}")
  private String p12Path;

  @Value("${ntss.cl-certificate.conf-path}")
  private String confPath;

  @Value("${ntss.cl-certificate.env-name}")
  private String certEnvName;

  private final ClDefineDao clDefineDao;
  private final ClDetailsDao clDetailsDao;
  private final ClFacilityDao clFacilityDao;

  public P12CombineService(ClDefineDao clDefineDao, ClDetailsDao clDetailsDao, ClFacilityDao clFacilityDao) {
    this.clDefineDao = clDefineDao;
    this.clDetailsDao = clDetailsDao;
    this.clFacilityDao = clFacilityDao;
  }

  /**
   * 複数の .p12 ファイルから CN を抽出し、ログイン施設CD を先頭に加えた CN で新しい証明書を発行する。
   *
   * @param files          アップロードされた .p12 ファイル（1件以上）
   * @param passwords      各ファイルのパスワード（files と同じ順序）
   * @param outputPassword 出力 .p12 のパスワード
   * @param facilityCd     ログイン中の施設CD（合成 CN の先頭に追加、DB 登録に使用）
   * @param loginUserId    ログインユーザーID（latest_issued_user に使用）
   * @return {@link CombineResult}（バイト列とファイル名を含む）
   */
  public CombineResult combineAndReissue(MultipartFile[] files, String[] passwords, String outputPassword,
      String facilityCd, String loginUserId) throws Exception {

    if (files == null || files.length < 1) {
      throw new IllegalArgumentException("1つ以上の .p12 ファイルを指定してください。");
    }
    if (outputPassword == null) {
      outputPassword = "";
    }

    // 各ファイルから CN を抽出してまとめる
    LinkedHashSet<String> cns = extractDistinctCns(files, passwords);

    // ログイン施設CD を先頭に挿入（重複除外）
    if (!StringUtils.isEmpty(facilityCd)) {
      LinkedHashSet<String> merged = new LinkedHashSet<>();
      merged.add(facilityCd.trim());
      merged.addAll(cns);
      cns = merged;
    }

    if (cns.size() < 2) {
      throw new IllegalArgumentException("異なる CN が2つ以上必要です。");
    }

    // CN をスペース区切りで結合（例："NKKSBR CONV70 CONV80"）
    String combinedCn = String.join(CN_DELIMITER, cns);

    // CA ファイルの存在確認
    File caCrt = new File(certificatePath + "/serverCA.crt");
    File caKey = new File(certificatePath + "/serverprivate.key");
    if (!caCrt.exists() || !caKey.exists()) {
      throw new IllegalStateException(
          "CA ファイルが見つかりません。certificate-path を確認してください: " + certificatePath);
    }

    // 一時ディレクトリで openssl コマンドを実行
    Path workDir = Files.createTempDirectory("ntss-p12-combine-");
    try {
      Path opensslCfg = workDir.resolve("openssl.cnf");
      String defaultDays = buildOpensslConfigWithCnOverride(opensslCfg.toFile(), combinedCn);

      run(workDir, new String[]{"openssl", "genrsa", "-out", "clientprivate.key", "4096"});
      run(workDir, new String[]{"openssl", "req", "-new", "-key", "clientprivate.key",
          "-out", "client.csr", "-config", opensslCfg.toString(), "-batch"});
      run(workDir, new String[]{"openssl", "x509", "-req", "-in", "client.csr",
          "-CA", caCrt.getAbsolutePath(), "-CAkey", caKey.getAbsolutePath(),
          "-CAcreateserial", "-out", "client.crt", "-days", defaultDays});
      run(workDir, new String[]{"openssl", "pkcs12", "-export", "-inkey", "clientprivate.key",
          "-in", "client.crt", "-out", "client.p12", "-passout", "pass:" + outputPassword});

      // 生成した .p12 のバイト列を読み込む（レスポンスとして直接返すため）
      byte[] p12Bytes = Files.readAllBytes(workDir.resolve("client.p12"));

      // ファイル名重複防止用の3桁ランダムサフィックスを生成（100〜999）
      String fileRandSuffix = String.valueOf(ThreadLocalRandom.current().nextInt(100, 1000));

      // ディスクに保存（サフィックス付きファイル名で上書き防止）
      // 例: /nfs/p12-path/NKKSBR/NKKSBR CONV45_435.p12
      Path destDir = Paths.get(p12Path, facilityCd);
      Files.createDirectories(destDir);
      Files.write(destDir.resolve(combinedCn + "_" + fileRandSuffix + ".p12"), p12Bytes);
      // 失効処理（certificateDisable）で使用するため .crt も同時に保存する
      // ファイル名例: NKKSBR CONV45_435client.crt
      byte[] crtBytes = Files.readAllBytes(workDir.resolve("client.crt"));
      Files.write(destDir.resolve(combinedCn + "_" + fileRandSuffix + "client.crt"), crtBytes);

      // 各施設CDの施設名を取得してスペース区切りで結合
      List<String> names = new ArrayList<>();
      for (String cd : cns) {
        String name = clFacilityDao.selectNameByCd(cd);
        names.add(name != null ? name : cd);
      }
      String manyFacilityName = String.join(CN_DELIMITER, names);

      // DB に証明書情報を登録（is_merge_issued='1'、file_rand_suffix を設定）
      insertCerDetail(outputPassword, facilityCd, combinedCn, manyFacilityName, loginUserId, fileRandSuffix);

      // ダウンロード用ファイル名：client_{CN1}_{CN2}_{suffix}.p12
      // CN のスペースをアンダースコアに置換（例："NKKSBR CONV70" → "NKKSBR_CONV70"）
      String fileName = "client_" + combinedCn.replace(CN_DELIMITER, "_") + "_" + fileRandSuffix + ".p12";
      return new CombineResult(p12Bytes, fileName);

    } finally {
      try {
        org.apache.commons.io.FileUtils.deleteDirectory(workDir.toFile());
      } catch (Exception ignore) {
      }
    }
  }

  /**
   * 再発行した証明書情報を client_cer_detail テーブルに登録する。
   */
  private void insertCerDetail(String passwordCl, String facilityCd, String manyFacilityCd,
      String manyFacilityName, String loginUserId, String fileRandSuffix) {
    try {
      // パスワードを暗号化（管理側と同じ処理）
      List<String> pwdList = clDetailsDao.selectPasswordEncrypt(passwordCl);
      String encryptedPassword = (pwdList != null && !pwdList.isEmpty()) ? pwdList.get(0) : passwordCl;

      Timestamp now = new Timestamp(System.currentTimeMillis());
      // insertClMerge を使用することで is_merge_issued='1'、file_rand_suffix が設定される
      clDetailsDao.insertClMerge(encryptedPassword, facilityCd, manyFacilityCd, manyFacilityName, loginUserId, now, now, fileRandSuffix);
    } catch (Exception e) {
      // DB 登録失敗はログに残すが、証明書ダウンロード自体は成功させる
      System.err.println("P12CombineService.insertCerDetail: DB 登録に失敗しました。" + e.getMessage());
    }
  }

  /**
   * 各 .p12 ファイルから CN を抽出する。
   * CN がスペース区切りで複数含まれる場合（例："CONV80 CONV90"）は分割して追加する。
   */
  private LinkedHashSet<String> extractDistinctCns(MultipartFile[] files, String[] passwords) throws Exception {
    LinkedHashSet<String> allCns = new LinkedHashSet<>();
    for (int i = 0; i < files.length; i++) {
      MultipartFile file = files[i];
      if (file == null || file.isEmpty()) {
        continue;
      }
      char[] pwd = new char[0];
      if (passwords != null && i < passwords.length && passwords[i] != null) {
        pwd = passwords[i].toCharArray();
      }
      KeyStore ks = KeyStore.getInstance("PKCS12");
      try (InputStream in = new ByteArrayInputStream(file.getBytes())) {
        ks.load(in, pwd);
      }
      String cn = extractCnFromFirstCertificate(ks);
      if (!StringUtils.isEmpty(cn)) {
        // CN がスペース区切りの場合（例："CONV80 CONV90"）は分割して追加
        for (String part : cn.split(" ")) {
          String trimmed = part.trim();
          if (!trimmed.isEmpty()) {
            allCns.add(trimmed);
          }
        }
      }
    }
    return allCns;
  }

  private static String extractCnFromFirstCertificate(KeyStore ks) throws Exception {
    Enumeration<String> aliases = ks.aliases();
    while (aliases.hasMoreElements()) {
      String alias = aliases.nextElement();
      Certificate cert = ks.getCertificate(alias);
      if (cert instanceof X509Certificate) {
        return extractCn((X509Certificate) cert);
      }
    }
    return null;
  }

  private static String extractCn(X509Certificate cert) {
    String dn = cert.getSubjectX500Principal().getName();
    try {
      LdapName ldapName = new LdapName(dn);
      for (Rdn rdn : ldapName.getRdns()) {
        if ("CN".equalsIgnoreCase(rdn.getType())) {
          Object value = rdn.getValue();
          return value == null ? null : value.toString();
        }
      }
      return null;
    } catch (InvalidNameException e) {
      return null;
    }
  }

  /**
   * openssl.cnf のベースファイルを読み込み、CN を差し替えた一時設定ファイルを生成する。
   *
   * @return defaultDays（"-days" に使用する日数文字列）
   */
  private String buildOpensslConfigWithCnOverride(File outFile, String cnOverride) throws Exception {
    String basePath = System.getenv(certEnvName) != null ? System.getenv(certEnvName) : confPath;
    File base = new File(basePath);
    if (!base.exists()) {
      throw new IllegalStateException("openssl.cnf が見つかりません: " + basePath);
    }

    String countryName = null;
    String stateOrProvinceName = null;
    String localityName = null;
    String organizationName = null;
    String organizationalUnitName = null;
    String defaultDays = null;

    ClDefine define = clDefineDao.selectClDefine(CTL_NO);
    if (define != null && !StringUtils.isEmpty(define.getValue())) {
      JSONObject json = new JSONObject(define.getValue());
      countryName = optString(json, "countryName");
      stateOrProvinceName = optString(json, "stateOrProvinceName");
      localityName = optString(json, "localityName");
      organizationName = optString(json, "organizationName");
      organizationalUnitName = optString(json, "organizationalUnitName");
      defaultDays = optString(json, "defaultDays");
    }

    List<String> list = FileUtils.readLines(base, "UTF-8");
    Iterator<String> it = list.iterator();
    while (it.hasNext()) {
      String item = it.next();
      if (item == null) continue;

      if (item.contains("default_days") && StringUtils.isEmpty(defaultDays)) {
        String[] parts = item.split("=", 2);
        if (parts.length == 2) {
          String days = parts[1];
          if (days.contains("#")) days = days.substring(0, days.indexOf("#"));
          Pattern pat = Pattern.compile("\\s*|\t|\r|\n");
          Matcher mat = pat.matcher(days);
          defaultDays = mat.replaceAll("");
        }
      }

      boolean shouldRemove =
          (item.contains("countryName_default") && !StringUtils.isEmpty(countryName)) ||
          (item.contains("stateOrProvinceName_default") && !StringUtils.isEmpty(stateOrProvinceName)) ||
          (item.contains("localityName_default") && !StringUtils.isEmpty(localityName)) ||
          (item.contains("0.organizationName_default") && !StringUtils.isEmpty(organizationName)) ||
          (item.contains("organizationalUnitName_default") && !StringUtils.isEmpty(organizationalUnitName)) ||
          item.contains("commonName_default");

      if (shouldRemove) {
        it.remove();
      }
    }

    List<String> ins = new ArrayList<>();
    if (!StringUtils.isEmpty(countryName)) ins.add("countryName_default=" + countryName);
    if (!StringUtils.isEmpty(stateOrProvinceName)) ins.add("stateOrProvinceName_default=" + stateOrProvinceName);
    if (!StringUtils.isEmpty(localityName)) ins.add("localityName_default=" + localityName);
    if (!StringUtils.isEmpty(organizationName)) ins.add("0.organizationName_default=" + organizationName);
    if (!StringUtils.isEmpty(organizationalUnitName)) ins.add("organizationalUnitName_default=" + organizationalUnitName);
    ins.add("commonName_default=" + cnOverride);

    int insertAt = list.indexOf("[ req_distinguished_name ]");
    if (insertAt < 0) {
      throw new IllegalStateException("openssl.cnf に [ req_distinguished_name ] セクションがありません。");
    }
    list.addAll(insertAt + 1, ins);

    FileUtils.writeLines(outFile, "UTF-8", list, false);

    if (StringUtils.isEmpty(defaultDays)) {
      defaultDays = "3650";
    }
    return defaultDays;
  }

  private static void run(Path cwd, String[] cmd) throws Exception {
    Process p = Runtime.getRuntime().exec(cmd, null, cwd.toFile());
    int code = p.waitFor();
    if (code != 0) {
      String err = new String(p.getErrorStream().readAllBytes(), StandardCharsets.UTF_8);
      throw new IllegalStateException(
          "openssl コマンドが失敗しました (" + code + "): " + Arrays.toString(cmd) + "\n" + err);
    }
  }

  private static String optString(JSONObject json, String key) {
    if (json == null || !json.has(key)) return null;
    String v = json.optString(key, null);
    return StringUtils.isEmpty(v) ? null : v;
  }

}
