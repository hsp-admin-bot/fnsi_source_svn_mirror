package jp.co.nikkiso.ntss.web_api.service.fileIO;

import org.springframework.web.multipart.MultipartFile;

import lombok.Data;

public interface FileIOService {

  /**
   * S3へファイルをアップロードする
   * ・外部からファイル(multipartFile)が直接送られてきた場合
   *
   * @param multipartFile 対象ファイル
   * @param uploadPath アップロード先のパス(ファイル名を含まない、s3://バケット名＋/XXXX)
   * @return 成功:true、失敗:false
   */
  boolean UploadToS3(MultipartFile multipartFile, String uploadPath);

  /**
   * add 9696指定フォルダ内の本日のファイルではないものを移動させます。
   * @param fileLocation　フォルダパスを指定します
   */
  boolean UploadCopy(String fileLocation);

  /**
   * S3へファイルをアップロードする
   * ・既に特定のディレクトリにファイルが存在し、そのファイルをアップロードする場合
   *
   * @param targetFilePath　対象ファイルパス(ファイル名も含む)
   * @param uploadPath アップロード先のパス(ファイル名も含む、s3://バケット名＋/XXXX)
   * @param isDelete true：成功失敗に関わらず対象ファイルを削除、false:成功の場合のみ対象ファイルを削除(失敗時は残す)
   * @return 成功:true、失敗:false
   */
  boolean UploadToS3(String targetFilePath, String uploadPath, boolean isDelete);

  /**
   * S3からファイルをダウンロードする
   *
   * @param fileName 対象ファイル名
   * @param downloadFilePath ダウンロード先のパス(ファイル名を含まない、s3://バケット名＋/XXXX)
   * @param savePath ダウンロードしたファイルの格納先(ファイル名を含まない)
   * @return 成功:true、失敗:false
   */
  boolean DownloadFromS3(String fileName, String downloadFilePath, String savePath);

  /**
   * S3のファイルを削除
   *
   * @param deleteFilePath 削除対象ファイルパス(ファイル名も含む、s3://バケット名＋/XXXX)
   * @return 成功:true、失敗:false
   */
  boolean DeleteFromS3(String deleteFilePath);

  /**
   * 分割ファイルを結合する
   *
   * @param workFolderPath 結合対象(分割)ファイルの格納先パス
   * @param outFileName 結合後のファイル名(分割ファイルのファイル名の先頭部分とすること ※検索に使用)
   * @param outFilePath 結合ファイルの格納先
   * @return 成功:true、失敗:false
   */
  boolean FileJoin(String workFolderPath, String outFileName, String outFilePath);


  /**
   * オンプレミス情報
   */
  @Data
  public class OnPremiseInfo {

    /**
     * オンプレミス時の基本フォルダ
     */
    private String localStore = null;
    /**
     * オンプレミスならばTrue
     */
    private Boolean isOnPremise = false;
  }
  /**
   * オンプレミスかどうかの判定
   * @return
   */
  OnPremiseInfo ChkOnPremise();
  /**
   * オンプレミスのファイルを削除
   *
   * @param deleteFilePath 削除対象ファイルパス(ファイル名も含む)
   * @return 成功:true、失敗:false
   */
  boolean DeleteFromOnPremise(String deleteFilePath);
  
  /* add by chamaojia 2023-09-12 [9599] 新しいデスクトップ通知を送信できるインタフェースかどうか  --start */
  /**
   * デスクトップ通知送信可否の判断
   * @return  true:送信  false:送信しない
   */
  boolean chkSesOn();
  /* add by chamaojia 2023-09-12 [9599] 新しいデスクトップ通知を送信できるインタフェースかどうか  --end */
}
