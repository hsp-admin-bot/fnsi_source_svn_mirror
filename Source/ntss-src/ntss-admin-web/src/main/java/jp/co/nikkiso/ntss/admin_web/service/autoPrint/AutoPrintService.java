package jp.co.nikkiso.ntss.admin_web.service.autoPrint;

/**
 * 自動レポート印刷インターフェース
 *
 */
public interface AutoPrintService {
  /**
   * 自動印刷タイミング
   */
  public enum TimingEnum {
  /**
   * 前体重測定時
   */
  beforeWeight,
  /**
   * 後体重測定時
   */
  afterWeight,
  /**
   * 実績確定時
   */
  commitEdition
  }

  public class AutoPrintResult {
    /**
     * 自動印刷が必要ならばTrue
     */
    public boolean isAutoPrint;
    /**
     * 自動印刷が成功していればTrue
     */
    public boolean isSuccessAutoPrint;
    /**
     * 自動印刷エラーメッセージ
     */
    public String autoPrintErrorMessage;
  }

  /**
   * 帳票自動印刷
   * @param ordNo オーダ番号
   * @param timing 処理タイミング
   * @param userId 発行者
   * @param userName ユーザー名
   * @return 成功: 1, 印刷不要: 0, 失敗: -1
   * @throws Exception
   */
  public AutoPrintResult reportAutoPrint(Long ordNo, TimingEnum timing, Long userId, String userName) throws Exception;

  /**
   * 帳票自動印刷
   * @param patId 患者番号
   * @param ordNo オーダ番号
   * @param treatmentCd 治療方法コード
   * @param bedCd ベッドコード
   * @param timing 処理タイミング
   * @param userId 発行者
   * @param userName ユーザー名
   * @param mustCheckInputClass 手動実績かどうかのチェックが未実施ならばtrue
   * @return 成功: 1, 印刷不要: 0, 失敗: -1
   * @throws Exception
   */
  public AutoPrintResult reportAutoPrint(Long patId, Long ordNo, Integer treatmentCd, Long bedCd, TimingEnum timing,
      Long userId, String userName, boolean mustCheckInputClass) throws Exception;
}
