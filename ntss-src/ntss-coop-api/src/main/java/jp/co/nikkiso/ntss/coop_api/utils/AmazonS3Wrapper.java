package jp.co.nikkiso.ntss.coop_api.utils;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.GetObjectRequest;
import com.amazonaws.services.s3.model.S3Object;
import com.amazonaws.services.s3.model.S3ObjectInputStream;
import com.amazonaws.util.IOUtils;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import org.springframework.beans.factory.annotation.Value;

/**
 * {@link AmazonS3} wrapper
 *
 */
public class AmazonS3Wrapper {

  // mod 2021-03-19 問題確認：NODEJS側に確認JAVA側のPDFファイルを送付しました。 孫 start
//  /** {@link AmazonS3} */
//  private AmazonS3 S3;
//  /** バケット名 */
//  private String bucketName;
//  /** S3が使えないクローズドネットワーク用のファイルパス */
//  private String saveLocalFilePath;
//  /** S3接続権限 */
//  private boolean permissionConnect;

  /** Amazon S3. */
  @Autowired(required = false)
  private AmazonS3 s3;

  @Value("${ntss.report.s3-bucket}")
  private String s3Bucket;
  // mod 2021-03-19 問題確認：NODEJS側に確認JAVA側のPDFファイルを送付しました。 孫 end

  /**
   * システム設定のDaoインタフェース.
   */
  @Autowired
  private SysSystemDefineDao sysSystemDefineDao;

  /**
   * オンプレミスの管理番号
   */
  private final int CTL_NO_ON_PREMISE = 14;

  // mod 2021-03-19 問題確認：NODEJS側に確認JAVA側のPDFファイルを送付しました。 孫 start
//  /**
//   * Constructor
//   *
//   * @param bucketName - バケット名
//   * @param region - リージョン名
//   * @param saveLocalFilePath - S3が使えないクローズドネットワーク用のファイルパス
//   * @param clientConfiguration - {@link ClientConfiguration}
//   * @param provider - {@link AWSStaticCredentialsProvider}
//   * @param permissionConnect - 接続権限
//   */
//  public AmazonS3Wrapper(String bucketName, String region, String saveLocalFilePath,
//      ClientConfiguration clientConfiguration,  AWSStaticCredentialsProvider provider, boolean permissionConnect) {
//    if (permissionConnect) {
//      AmazonS3ClientBuilder builder = AmazonS3ClientBuilder.standard()
//          .withRegion(region)
//          .withClientConfiguration(clientConfiguration)
//          .withCredentials(provider);
//      this.S3 = builder.build();
//    }
//    this.bucketName = bucketName;
//    this.permissionConnect = permissionConnect;
//    this.saveLocalFilePath = saveLocalFilePath;
//  }
//
//  /**
//   * S3が使えない場合のローカルファイル取得
//   * @return {@link File}
//   */
//  public File getSaveLocalFile() {
//    return new File(this.saveLocalFilePath);
//  }
//
//  /**
//   * S3接続権限
//   * @return true 接続可能 | false 接続不可
//   */
//  public boolean isApprovalConnect() {
//    return this.permissionConnect;
//  }

  /**
   * Constructor
   */
  public AmazonS3Wrapper() {}
  // mod 2021-03-19 問題確認：NODEJS側に確認JAVA側のPDFファイルを送付しました。 孫 end

  /**
   * {@link AmazonS3#getObject(GetObjectRequest)} to byte[]
   *
   * @param key キー名
   * @return byte[]
   * @throws IOException S3接続時のIOエラー
   */
  public byte[] getS3ObjectByteArray(String key) throws IOException {
    String localStore = null;
    String status = null;
    try {
      SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CTL_NO_ON_PREMISE);
      ObjectMapper objectMapper = new ObjectMapper();
      HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(), new TypeReference<HashMap<String, String>>(){});
      localStore = onPremise.get("path");
      status = onPremise.get("status");
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
//      return new byte[0];
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang start
      throw e;
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang end
    }

    if (status.equals("off")) {
      S3Object s3Object = this.getS3Object(key);
      try (S3ObjectInputStream inputStream = s3Object.getObjectContent()) {
        return IOUtils.toByteArray(inputStream);
      } catch (IOException e) {
        throw e;
      }
    } else {
      // mod 2021-03-19 問題確認：NODEJS側に確認JAVA側のPDFファイルを送付しました。 孫 start
//      localStore += "/" + bucketName;
      localStore += "/" + s3Bucket;
      // mod 2021-03-19 問題確認：NODEJS側に確認JAVA側のPDFファイルを送付しました。 孫 end
      return getFile(localStore, key);
    }
  }

  /**
   * {@link AmazonS3#getObject(GetObjectRequest)}
   *
   * @param key キー名
   * @return {@link S3Object}
   */
  public S3Object getS3Object(String key) {
    // mod 2021-03-19 問題確認：NODEJS側に確認JAVA側のPDFファイルを送付しました。 孫 start
//    GetObjectRequest request = new GetObjectRequest(bucketName, key);
//    return S3.getObject(request);
    GetObjectRequest request = new GetObjectRequest(s3Bucket, key);
    return s3.getObject(request);
    // mod 2021-03-19 問題確認：NODEJS側に確認JAVA側のPDFファイルを送付しました。 孫 end
  }

  /**
   * ロカルからファイルを挿入する
   *
   * @param localStore ローカル取得
   * @param filePath ファイル取得
   *
   * @return byte[]
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
  public byte[] getFile(String localStore, String filePath) throws IOException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    // キャッシュファイルパスの生成
    try
    {
      String fileLocation = localStore + "/" + filePath;
      Path path = Paths.get(fileLocation);
      return Files.readAllBytes(path);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
//      return new byte[0];
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang start
      throw e;
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang end
    }
  }
}
