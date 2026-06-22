package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 通信サーバ設定取得用のclass
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class ComsvSet {

  /**
   * 新通信一斉時刻合わせ
   */
  private String isTimeset;

  /**
   * 新通信一斉時刻合わせ時刻
   */
  private String timesetTime;

  /**
   * NX通信一斉時刻合わせ
   */
  private String isTimesetNx;

  /**
   * NX通信一斉時刻合わせ時刻
   */
  private String timesetNxTime;

  /**
   * 仮想端末ログ時間
   */
  private String lcdLogTime;

  /**
   * 仮想端末ログ内容
   */
  private String lcdLogType;

  /**
   * 仮想端末投与時間帯表示
   */
  private String isLcdMedi;

  /**
   * 排液判定待機時間
   */
  private Integer endWaitTime;

  /**
   * 患者切り替えタイミング
   */
  private String patTiming;

  /**
   * お知らせ機能
   */
  private String isNotice;

  /**
   * お知らせ機能補正時間
   */
  private Integer noticeTime;

  /**
   * ログのアップロード実施時刻
   */
  private String logUploadTime;

  /**
   * オフライン運転自動開始時間
   */
  private Integer offlineStartTime;

  /**
   * オフライン運転自動終了
   */
  private String isOfflineAutoEnd;

  /**
   * 日付変更時次患者更新時刻
   */
  private String reloadNextPatTime;

  /**
   * 次患者送信モード
   */
  private Integer nextPatMode;

  /**
   * 次患者検索期間
   */
  private Integer nextPatModeRange;

  /**
   * 装置生存監視時間
   */
  private Integer deviceTimeout;

  /**
   * 治療中モニタ通知間隔
   */
  private Integer treatMoniInterval;

  /**
   * 治療外モニタ通知間隔
   */
  private Integer otherMoniInterval;

  // add 治療記録用データと治療状況用データの登録先を振分けにする 高 start
  /**
   * 治療中リアルタイムモニタ通知間隔
   */
  private Integer treatRealtimeMonitoInterval;

  /**
   * 治療外リアルタイムモニタ通知間隔
   */
  private Integer otherRealtimeMonitoInterval;
  // add 治療記録用データと治療状況用データの登録先を振分けにする 高 end

  /**
   * 仮想端末メニュー表示設定
   */
  private String lcdMenu;

  /**
   * 次患者情報表示設定
   */
  private String lcdNpat;

  /**
   * 透析日報表示設定
   */
  private String lcdReport;

  /**
   * 検査１グラフ表示設定
   */
  private String lcdGraph1;

  /**
   * 検査２グラフ表示設定
   */
  private String lcdGraph2;

  /**
   * 検査レーダーチャート表示設定
   */
  private String lcdRadar;

  /**
   * 投与薬剤お知らせ
   */
  private String isNoticeMedi;

  //add redmine bug#5618 劉 start
  /**
   * 治療時間判定時間（分）
   */
  private String treatmentJudgeTime;
  //add redmine bug#5618 劉 end

  //add redmine bug#5798 高 start
  /**
   * 仮想端末投与時間
   */
  private String lcdMediTime;
  //add redmine bug#5798 高 end
}
