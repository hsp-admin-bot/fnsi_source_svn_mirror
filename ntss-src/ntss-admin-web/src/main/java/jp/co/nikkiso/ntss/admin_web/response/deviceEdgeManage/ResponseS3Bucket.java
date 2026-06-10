package jp.co.nikkiso.ntss.admin_web.response.deviceEdgeManage;

import java.util.Date;

import lombok.Data;

@Data
public class ResponseS3Bucket {
  /**
   * 対象バケット
   */
  private String bucket;
  /**
   * 対象ファイル名
   */
  private String fileName;
  /**
   * 対象ファイルが存在するかどうか
   */
  private boolean isExists;
  /**
   * ファイル更新日時
   */
  private Date modifiedDate;
  /**
   * メッセージ
   */
  private String message;
}
