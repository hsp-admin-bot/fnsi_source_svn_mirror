package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.OriginalStates;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "sys_coop_journal")
@Getter
@Setter
public class SysCoopJournal extends BaseEntity {
  /** 管理番号 */
  @Id
  private Long ctlNo;
  /** 施設コード */
  private String facilityCd;
  /** 電文種別 */
  private String coopCd;
  /** IBM向け_電文付帯情報 */
  private String coopCdIndex;
  /** 作成更新区分 */
  private String crud;
  //del #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi start 名前間違い変量を削除する
  /**   基準日 */
//  private String baseBate;
  //del #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi end 名前間違い変量を削除する
  /** 送信/受信 */
  private String direction;
  /** 次世代FutureNet オーダ番号 */
  private Long ordNo;
  /** 電子カルテ連携 オーダ番号 */
  private String coopOrdNo;
  /** 患者番号(連携用) */
  private String hospPatId;
  /** 患者番号(システム) */
  private Long patId;
  /** 受付番号 */
  private Long acceptNo;
  /** 基準日 */
  // mod 2020-10-13 FNSI-改修 外部連携276 夏 start
  //private Timestamp baseDate;
  private String baseDate;
  // mod 2020-10-13 FNSI-改修 外部連携276 夏 end
  /** 変換処理結果 */
  private String anaResult;
  /** 配信処理終了日時 */
  private Timestamp inAnaDate;
  /** 変換処理完了日時 */
  private Timestamp outAnaDate;
  /** 通信結果 */
  private String coopResult;
  /** 配信処理開始日時 */
  private Timestamp inRegDate;
  /** 変換処理開始日時 */
  private Timestamp outRegDate;
  /** メッセージ */
  private String message;
  /** レポートコード */
  private Long reportCd;
  /** 送信電文パス */
  private String dumpPath;
  /** 送信電文(Base64) */
  private byte[] dump;
  /** 編集可否フラグ */
  private String isEditable;
  /** 削除フラグ */
  private String isDel;
  /** 操作者ID */
  private Long userId;
// mod 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
  /** 操作番号 */
//  private String opeId;
  private String opeCd;
// mod 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end

  // mod #9756  NKK連携 exam_rstにて複数患者のデータを取込時検査結果自動計算が最後に取り込んだ患者しか行われない 20230901 孟堅 start
  //#9527 mod 再送回数が増加しない  卓 start
  //private  Integer retryCnt;
  private  int retryCnt;
  //#9527 mod 再送回数が増加しない  卓 end
  // mod #9756  NKK連携 exam_rstにて複数患者のデータを取込時検査結果自動計算が最後に取り込んだ患者しか行われない 20230901 孟堅 end

  // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
  private  String tempContent;
  // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end

// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  /** 電子カルテ種別 */
  private  String key0;
  /** 連携版番号 */
  private  String coopVersion;
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

  /**
   * @see : http://doma.seasar.org/reference/entity.html#%E5%8F%96%E5%BE%97%E6%99%82%E3%81%AE%E7%8A%B6%E6%85%8B%E3%82%92%E7%AE%A1%E7%90%86%E3%81%99%E3%82%8B%E3%83%95%E3%82%A3%E3%83%BC%E3%83%AB%E3%83%89
   */
  @OriginalStates
  SysCoopJournal originalStates;
}
