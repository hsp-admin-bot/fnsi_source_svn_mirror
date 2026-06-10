package jp.co.nikkiso.ntss.coop_api.service;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.coop_api.request.JournalConvertSendDataSetRequest;
import jp.co.nikkiso.ntss.core.entity.MstCoopIni;
import jp.co.nikkiso.ntss.core.entity.json.LayoutExtSetting;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayout;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;

/**
 * ConvertSend service
 *
 */
public interface ConvertSendCommonService {


  /**
   * 電文をジャーナルに登録します
   * @param journal - ジャーナル
   */
  void storeTelegram(SysCoopJournal journal);

  /**
   * ntss-api(/data-set)へのリクエスト作成およびリクエストを行います
   * @param journal - {@link SysCoopJournal}
   * @param layoutExtSetting - {@link LayoutExtSetting}
   * @param detailDataSetMap - detailレイアウトからループしているdatasetの1要素
   * @return data-setの結果Map<sqlCode, data-setの結果>
   */
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni --start */
  Map<String, List<Map<String, Object>>> createRequestAndRequestByDataSetApi(SysCoopJournal journal, LayoutExtSetting layoutExtSetting,
      Map<String, Object> detailDataSetMap, MstCoopIni coopIni);
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni --end */

  /**
   * ntss-api(/data-set)へのリクエストを行います
   *
   * @param request - "/data-set"  へのリクエスト
   * @return data-setの結果
   */
  List<Map<String, Object>> requestNtssApi(JournalConvertSendDataSetRequest request);
  /**
   * 作成した電文のファイル名を取得します.
   * ベンダーごとにフォーマットが異なるためdatasetから取得を行います
   *
   * @param layout - {@link MstCoopLayout}
   * @param journal - {@link SysCoopJournal journal}
   * @return 電文ファイル名
   */
  String getDumpFileName(MstCoopLayout layout, SysCoopJournal journal);
  /**
   * mst_coop_layoutおよびmst_coop_layout_detailのcoop_cd_subを求めます
   *
   * @param crud - sys_coop_journal.crud
   * @return coop_cd_sub
   */
  String getCoopCdSub(String crud);
  /**
   * ジャーナルテーブルのデータを取得する
   * @param replaceEscape 変換文字列
   * @param journal - {@link SysCoopJournal journal}
   * @return 変換した値
   */
  String getJournalReplaceData(String replaceEscape, SysCoopJournal journal);

  /**
   * 利用者マスタより表示用利用者IDを取得
   *
   * @param value 文字列
   * @return 表示用利用者ID
   * */
  String getAuthId(String value);

  // add 2021-12-22 #5888:NEC-iS連携ができない(透析実績(rst_dial)) 孫 start
  /**
   * 利用者マスタ(mst_personal_user)より院内コード1を取得
   *
   * @param value 文字列
   * @return 院内コード1
   * */
  String getInHospitalCd1(String value);

  /**
   * 利用者マスタ(mst_personal_user)より院内コード2を取得
   *
   * @param value 文字列
   * @return 院内コード2
   * */
  String getInHospitalCd2(String value);
  // add 2021-12-22 #5888:NEC-iS連携ができない(透析実績(rst_dial)) 孫 end

  // add 2021-10-14 CSIの「【検査予定送信】のスタッフマスタ.職種コード」の対応 孫 start
  /**
   * 利用者マスタ(mst_personal_user)より職種コードを取得
   *
   * @param value 文字列
   * @return 職種コード
   * */
  String getJobCd(String value);
  // add 2021-10-14 CSIの「【検査予定送信】のスタッフマスタ.職種コード」の対応 孫 end

  // add 2021-10-28 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 start
  /**
   * 利用者マスタ(mst_personal_user)より利用者名を取得
   *
   * @param value 文字列
   * @return 利用者名
   * */
  String getStaffName(String value);
  // add 2021-10-28 #5890:Medicom連携ができない(カルテ記載連携(karte_ord))(透析経過データ連携) 孫 end

  /**
   * mst_coop_facilityの各機能共通設定から、レポート対象か確認する
   * @param journal {@link SysCoopJournal} sys_coop_journal
   * @return true:レポート対象 false レポート対象外
   */
  boolean isReport(SysCoopJournal journal);

  /**
   * 各種ファイル名を取得
   * @param journal {@SysCoopJournal} 外部連携用ジャーナル
   * @return {@link ReportFile} ファイル名
   */
  Map<String, String> getFileNames(SysCoopJournal journal);
}
