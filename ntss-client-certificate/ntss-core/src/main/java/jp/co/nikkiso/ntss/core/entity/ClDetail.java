package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
/**
 * クライアント証明書の詳細
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "client_cer_detail")
@Getter
@Setter
public class ClDetail {

  /**
   * ID
   */
  @Id
  private Integer clCertificateId;

  /**
   * パスワード
   */
  private String passwordCl;

  /**
   * 発行数
   */
  private Integer maxDownload;

  /**
   * 現在のダウンロード
   */
  private Integer curDownload;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 複数施設コード
   */
  private String manyFacilityCd;

  /**
   * 複数施設名
   */
  private String manyFacilityName;

  /**
   * 公開期限
   */
  private Timestamp expiredDate;

  /**
   * 最新の発行ユーザー
   */
  private String latestIssuedUser;

  /**
   * 登録日
   */
  private Timestamp regDate;

  /**
   * 更新日
   */
  private Timestamp upDate;
  //add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start
  /**
   * 削除フラグ
   */
  private String isDelete;
  //add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end

  private Integer facilityCount;

  // add 6360対応 xie start
  private String issueDate;
  // add 6360対応 xie end

  /**
   * マージ発行フラグ。
   * <p>
   * 取得値：
   * <ul>
   *   <li>{@code '1'} : ntss-certificate-download の証明書マージ機能（/merge 画面）によって発行された証明書</li>
   *   <li>{@code '0'} または {@code null} : 管理側（ntss-certificate-management）から通常発行された証明書</li>
   * </ul>
   * <p>
   * 用途：
   * <ul>
   *   <li>ntss-certificate-download の /user 画面（証明書ダウンロード一覧）では、
   *       {@code is_merge_issued = '1'} のレコードを表示対象から除外する。</li>
   *   <li>マージ発行証明書はマージ完了時にその場でダウンロードするため、
   *       ダウンロード一覧への表示は不要。</li>
   * </ul>
   */
  private String isMergeIssued;

  /**
   * ファイル名ランダムサフィックス（3桁数字文字列、例："435"）。
   * <p>
   * マージ発行時（{@code is_merge_issued = '1'}）にのみ設定される。
   * 管理側から通常発行された証明書には設定されない（{@code null}）。
   * <p>
   * 設定目的：
   * <ul>
   *   <li>同一の CN 組み合わせ（例："NKKSBR CONV45"）が複数回マージされた場合でも、
   *       ディスク上の証明書ファイルが上書きされないようにするため。</li>
   *   <li>例：{@code /nfs/p12-path/NKKSBR/NKKSBR CONV45_435.p12}</li>
   * </ul>
   * <p>
   * 後方互換：
   * <ul>
   *   <li>本フィールド追加前の既存レコードは {@code null} のため、
   *       ファイル読み取り時は {@code null} チェックを行い、
   *       {@code null} の場合はサフィックスを付与しない。</li>
   * </ul>
   */
  private String fileRandSuffix;

}
