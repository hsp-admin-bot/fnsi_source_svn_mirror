package jp.co.nikkiso.ntss.coop_api.service;

import jp.co.nikkiso.ntss.core.entity.MstCoopFacility;
import jp.co.nikkiso.ntss.core.entity.MstCoopIni;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayout;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayoutDetail;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;

import java.io.UnsupportedEncodingException;
import java.util.List;
import java.util.Map;

/**
 * 受信変換時、電文フォーマット（text/csv/xml）によらず実行する共通処理を規定するインタフェース。
 */
public interface ConvertCommonService {

  /**
   * 変換対象ジャーナルを取得する。
   *
   * @param facilityCd 施設コード
   * @param direction  向き（送受信）
   * @param coopResult 通信ステータス
   * @param ctlNoList  管理番号リスト
   * @param ordNo      （次世代FN)オーダ番号
   * @param patId      患者番号（システム）
   * @return ジャーナルのリスト
   */
  /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId  --start */
  /* modify by chamaojia 2023-01-10 [7050] インタフェースパラメータの追加ctlNoList  --start */
  List<SysCoopJournal> getJournalList(String facilityCd, String direction, String coopResult, List<Long> ctlNoList, Long ordNo, Long patId);
  /* modify by chamaojia 2023-01-10 [7050] インタフェースパラメータの追加ctlNoList  --end */
  /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId  --end */

//#8350  mod ini_dial連携受信時のprofile連携（要求）が処理されず患者属性の更新ができないことがある 卓 2023-04-26 start
  /**
   * 変換対象のジャーナル数量統計。
   *
   * @param facilityCd 施設コード
   * @param direction  向き（送受信）
   * @param coopResult 通信ステータス
   * @param ctlNoList  管理番号リスト
   * @param ordNo      （次世代FN)オーダ番号
   * @param patId      患者番号（システム）
   * @return ジャーナルのリスト
   */
  Long getJournalListCount(String facilityCd, String direction, String coopResult, List<Long> ctlNoList, Long ordNo, Long patId);
//#8350  mod ini_dial連携受信時のprofile連携（要求）が処理されず患者属性の更新ができないことがある 卓 2023-04-26 end

  /**
   * 変換処理中/送信処理中のジャーナルの取得
   *
   * @param facilityCd 施設コード
   * @param direction  向き（送受信）
   * @param ordNo      オーダ番号
   * @param patId      患者ID
   * @return 変換処理中ジャーナルリスト {@link SysCoopJournal}
   */
  List<SysCoopJournal> getProcessingJournalList(String facilityCd, String direction, Long ordNo, Long patId);

  /**
   * 変換対象ジャーナルを1件取得する。
   *
   * @param facilityCd 施設コード
   * @param direction  向き（送受信）
   * @param coopResult 通信ステータス
   * @param ctlNoList  管理番号リスト
   * @param ordNo      （次世代FN)オーダ番号
   * @param patId      患者番号（システム）
   * @return ジャーナルのリスト
   */
  List<SysCoopJournal> getJournalListOne(String facilityCd, String direction, String coopResult, List<Long> ctlNoList, Long ordNo, Long patId);


  /**
   * 変換レイアウトマスタを取得する。
   *
   * @param facilityCd 施設コード
   * @param direction 向き（送受信）
   * @param coopCd 電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @param coopCdSub 電文種別補足コード
   * @return 変換レイアウトマスタ（{@link MstCoopLayout}）のエンティティ
   */
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  MstCoopLayout getMstCoopLayout(String facilityCd, String direction, String coopCd, String coopCdIndex, String coopCdSub);
  MstCoopLayout getMstCoopLayout(String facilityCd, String direction, String coopCd, String coopCdIndex,
                                 String coopVersion, String coopCdSub);
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

// add 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
  /**
   * 電文種別補足コードで変換レイアウトマスタを取得する。
   *
   * @param facilityCd 施設コード
   * @param direction 向き（送受信）
   * @param coopCd 電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @param coopCdSub 電文種別補足コード
   * @return 変換レイアウトマスタ（{@link MstCoopLayout}）のエンティティ
   */
  MstCoopLayout getMstCoopLayoutBySub(String facilityCd, String direction, String coopCd, String coopCdIndex,
                                 String coopVersion, String coopCdSub);

  /**
   * 電文種別詳細補足コードで変換レイアウト詳細マスタを取得する。
   *
   * @param facilityCd 施設コード
   * @param direction 向き（送受信）
   * @param coopCd 電文種別
   * @param coopVersion 連携版番号
   * @param coopCdDetail 電文種別詳細コード
   * @param coopCdDetailSub 電文種別詳細補足コード
   * @return 変換レイアウト詳細マスタ（{@link MstCoopLayoutDetail}）のエンティティ
   */
  MstCoopLayoutDetail getMstCoopLayoutDetailBySub(String facilityCd, String direction, String coopCd,
                                                  String coopVersion, String coopCdDetail, String coopCdDetailSub);

  /**
   * 電文種別詳細補足コードが引数に一致するレコードがなく、preのレコードがある場合は後者を取得する。
   *
   * @param facilityCd 施設コード
   * @param direction 向き（送受信）
   * @param coopCd 電文種別
   * @param coopVersion 連携版番号
   * @param coopCdDetail 電文種別詳細コード
   * @param coopCdDetailSub 電文種別詳細補足コード
   * @param preConst 電文種別詳細補足コードpreに対応する定数
   * @param allConst 電文種別詳細補足コードallに対応する定数
   * @return 変換レイアウト詳細マスタ（{@link MstCoopLayoutDetail}）のエンティティ
   */
  public MstCoopLayoutDetail getMstCoopLayoutDetailWithPre(String facilityCd, String direction, String coopCd,
             String coopVersion, String coopCdDetail, String coopCdDetailSub, String preConst, String allConst);
  // add 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end

  /* modify by chamaojia 2023-06-20 入力パラメータを追加します, 方向を区別する  --start */
  /**
   * 対象ジャーナルの変換ステータスを「処理中」に更新する。
   *
   * @param journalCtlNoList ジャーナルの管理番号のリスト
   * @param statusCode 更新後の変換ステータス
   * @param direction 向き（送受信）
   * @return 更新されたレコード数
   */
  List<Long> updateConvStatus(List<Long> journalCtlNoList, String statusCode, String direction);
  /* modify by chamaojia 2023-06-20 入力パラメータを追加します, 方向を区別する  --end */

  /**
   * 対象ジャーナルの変換ステータスを更新する
   *
   * @param journalCtlNo
   * @param message メッセージ
   * @param statusCode 更新後の変換ステータス
   * @return 更新されたレコード数
   * */
  int updateAnaResult(Long journalCtlNo, String message, String statusCode);

  // add 2021-06-10 #5279:API連動の処理順番が正しくない 孫 start
  /**
   * 対象ジャーナルの変換ステータスを更新する(API連動処理が無し)
   *
   * @param journalCtlNo
   * @param message メッセージ
   * @param statusCode 更新後の変換ステータス
   * @return 更新されたレコード数
   * */
  int updateAnaResultNotCallApi(Long journalCtlNo, String message, String statusCode);
  // add 2021-06-10 #5279:API連動の処理順番が正しくない 孫 end

  // add 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 start
  /**
   * 連携対象の電文種別を取得する。
   *
   * @param facilityCd 施設コード
   * @return 連携対象の電文種別リスト
   */
  List<MstCoopFacility.CoopOrdCd> getCoopOrdCdList(String facilityCd);
  // add 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 end

  // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
  /**
   * 対象ジャーナルのtempContentを更新する
   *
   * @param journalCtlNo
   * @param tempContent
   * @param crud
   * @return 更新されたレコード数
   */
// mod 2021-08-25 受信時、電文内容を解析した後、sys_coop_journalのcrudを更新するの対応 孫 start
//  int updateTempContent(Long journalCtlNo, String tempContent);
  int updateTempContent(Long journalCtlNo, String tempContent, String crud);
// mod 2021-08-25 受信時、電文内容を解析した後、sys_coop_journalのcrudを更新するの対応 孫 end

  /**
   * 対象ジャーナルのcoopOrdNoを更新する
   *
   * @param journalCtlNo
   * @param coopOrdNo
   * @param idMap
   * @return 更新されたレコード数
   */
  int updateCoopOrdNo(Long journalCtlNo, String coopOrdNo, Map<String,Object> idMap);

  /**
   * 対象ジャーナルのcoopOrdNoを更新する
   * journal -{@link SysCoopJournal}
   *
   */
  void updateCoopOrdNo(SysCoopJournal journal);


  // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end

  // add 2021-09-16 #5897:CSI連携ができないの対応 孫 start
  /**
   * 連携設定マスタを取得.
   * @param facilityCd 施設コード
   * @return 連携エッジマスタ情報
   */
  public List<MstCoopIni> getMstCoopIniByFacilityCd(String facilityCd);
  // add 2021-09-16 #5897:CSI連携ができないの対応 孫 end

// add 2022-11-08 bug #7113 rep_dial連携の処理タイミングがずれる 孫 start
  /**
   * 帳票データを更新する。
   *
   * @param journal 外部連携用ジャーナル
   */
  public void updateReportData(SysCoopJournal journal);
// add 2022-11-08 bug #7113 rep_dial連携の処理タイミングがずれる 孫 end

  /* add by chamaojia 2023-05-22 検査結果1 file多患者受信時のデータ分割処理とIFedgeファイル移動処理の競合  --start */
  // 次の3つのインタフェースは、JournalConvertReceiveResourceから移行してきました
  /***
   * 電文フォーマットがmultiの場合、1電文に複数患者の検査結果があります。
   *    * 1行１ジャーナルで処理する  from : 明石　
   * @param facilityCd  施設コード
   */
  public List<SysCoopJournal> updateJournalListExamRst(String facilityCd, List<Long> ctlNoList);

  /**
   * 複数患者指定を取得する。
   *
   * @param facilityCd 施設コード
   * @param direction 向き（送受信）
   * @param coopCd 電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @return 先頭が複数患者対応可否文字列（"true"/"false"）、残りが区切り文字を表す文字列配列
   */
  public String[] getMultiSetting(String facilityCd, String direction, String coopCd, String coopCdIndex,
                                  String coopVersion);

  /**
   * 電文を区切り文字で分割する。
   *
   * @param telegram 電文
   * @param delimStrs 電文区切り文字列（複数）
   * @return 分割された電文
   * @throws UnsupportedEncodingException
   */
  public List<byte[]> splitTelegram(byte[] telegram, String[] delimStrs) throws UnsupportedEncodingException;
  /* add by chamaojia 2023-05-22 検査結果1 file多患者受信時のデータ分割処理とIFedgeファイル移動処理の競合  --end */

  /**
   * 対象ジャーナルの変換ステータスを「未処理」に更新する。
   *
   * @param ctlNo ジャーナルの管理番号
   * @return 更新されたレコード数
   */
  public int updateAnaResultUnprocess(Long ctlNo);
}
