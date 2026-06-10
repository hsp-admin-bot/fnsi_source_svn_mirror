package jp.co.nikkiso.ntss.web_api.service;

import java.time.LocalTime;
import java.util.List;

/**
 * 施設解約サービスインタフェース。
 */
public interface FacilityCancelService {

  /**
   * 施設解約を登録する。
   *
   * @param facilityCd 施設コード
   * @param baseDate 解約基準日
   */
  void register(String facilityCd, String baseDate, String procClass);

  /**
   * 削除対象レコードのバックアップを作成する。
   *
   * @param expiration 実行時間上限（単位=分）
   */
  // mod 8008日次処理のスケジュール自動延長がされない患者が存在する。 赵 start
  void backup(Long expiration);
  void backup(Long expiration, LocalTime startTime, LocalTime endTime);
  // mod 8008日次処理のスケジュール自動延長がされない患者が存在する。 赵 end
  /**
   * 施設解約を実行する。
   *
   * @param expiration 実行時間上限（単位=分）
   */
  // mod 8008日次処理のスケジュール自動延長がされない患者が存在する。 赵 start
  void execute(Long expiration);
  void execute(Long expiration,LocalTime startTime, LocalTime endTime);
  // mod 8008日次処理のスケジュール自動延長がされない患者が存在する。 赵 end

  /**
   * 施設解約の処理ステータスを更新する。（解約キャンセル）
   *
   * @param facilityCd 施設コード
   */
  void updateStatus(String facilityCd, String procClass);

  /**
   * ログイン無効化の更新をする
   */
  void disableLogin();

  /**
   * 対象施設、対象日の施設解約バックアップデータを取得する。
   *
   * @param facilityCd 施設コード
   * @param baseDate 解約基準日
   * @param procClass 処理区分
   * @return 施設解約バックアップのバイトデータ
   */
  byte[] getBackupData(String facilityCd, String baseDate, String procClass);

  /**
   * 解約施設のデータを完全削除する。
   *
   * @param facilityCd 施設コード
   */
  void completeDeleteFacility(String facilityCd);

  /**
   * ReMS/FNSi解約施設のバックアップデータを削除する。
   *
   * @param facilityCd 施設コード
   */
  void dataDeleteFacility(String facilityCd);

  /**
   * 施設全解約、FNSi解約時に患者情報共有の解除を行う
   *
   * @param lstFacilityCd 施設コードのリスト
   */
  void cancelSharePatientInfo(List<String> lstFacilityCd);
}
