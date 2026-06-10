package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Data;

import java.util.Date;
import java.util.List;

@Data
public class SysCoopJournalParam {
  /** 施設コード */
  private String facilityCd;
  /** 電文種別 */
  private String coopCd;
  /** IBM向け_電文付帯情報 */
  private String coopCdIndex;
  /** 作成更新区分 */
  private String crud;
  /**   基準日 */
  private String baseBate;
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
  //private Timestamp baseDate;
  private String baseDate;
  /** 変換処理ステータスコード */
  private List<String> anaResult;

  /** 配信処理ステータスコード */
  private List<String> coopResult;
//  /** メッセージ */
//  private String message;
//  /** レポートコード */
//  private Long reportCd;
//  /** 送信電文パス */
//  private String dumpPath;
//  /** 送信電文(Base64) */
//  private byte[] dump;
  /** 編集可否フラグ */
  private String isEditable;
//  /** 削除フラグ */
//  private String isDel;

  /** 操作番号 */
//  private String opeId;
  private String opeCd;

  //#9527 mod 再送回数が増加しない  卓 start
  private  Integer retryCnt;
  //#9527 mod 再送回数が増加しない  卓 end

  private  String tempContent;

  /** 電子カルテ種別 */
  private  String key0;

  /** 連携版番号 */
  private  String coopVersion;
  /** 登録日時*/
  private Date regDate;



}
