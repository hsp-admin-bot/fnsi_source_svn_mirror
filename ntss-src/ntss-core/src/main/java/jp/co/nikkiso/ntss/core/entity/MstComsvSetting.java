package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 通信サーバー設定のEntity.
 */
@Entity(listener=BaseEntityListener.class, naming=NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_comsv_setting")
@Getter
@Setter
public class MstComsvSetting extends BaseEntity{

  /**
   * 通信サーバー管理コード
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long comsvCd;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * デバイスエッジ番号
   */
  private Integer deviceEdgeNo;

  /**
   * 新対維新一斉時刻合わせ
   */
  private String isTimeset;

  /**
   * 新通信一斉時刻合わせ時刻
   */
  private String timesetTime;

  /**
   *NX通信一斉時刻合わせ
   */
  private String isTimesetNx;

  /**
   *NX通信一斉時刻合わせ時刻
   */
  private String timesetNxTime;

  // add 「投薬変更のお知らせ」の有無を判断する項目を追加 劉 start
  /**
   *投薬変更のお知らせ
   */
  private String isNoticeMedi;
  // add 「投薬変更のお知らせ」の有無を判断する項目を追加 劉 end

  /**
   *仮想端末ログ時間
   */
  private String lcdLogTime;

  /**
   *仮想端末ログ内容
   */
  private Integer lcdLogType;

  /**
   *仮想端末投与時間帯表示
   */
  private String isLcdMedi;

  /**
   *仮想端末投与時間帯
   */
//  add 5798仮想端末投与時間帯表示を有効にしているが、表示されない薬剤がある start zhao
  private String lcdMediTime;
//  add 5798仮想端末投与時間帯表示を有効にしているが、表示されない薬剤がある end  zhao

  /**
   *排液判定待機時間
   */
  private Integer endWaitTime;

  /**
   *患者切り替えタイミング
   */
  private String patTiming;

  /**
   *お知らせ機能
   */
  private String isNotice;

  /**
   *お知らせ機能補正時間
   */
  private Integer noticeTime;

  /**
   *ログのアップロード実施時刻
   */
  private String logUploadTime;

  /**
   *仮想端末メニュー設定
   */
  private String lcdMenu;

  /**
   *次患者情報表示設定
   */
  private String lcdNpat;

  /**
   *透析日報表示設定
   */
  private String lcdReport;

  /**
   *検査１グラフ表示設定
   */
  private String lcdGraph1;

  /**
   *検査２グラフ表示設定
   */
  private String lcdGraph2;

  /**
   *検査レーダーチャート表示設定
   */
  private String lcdRadar;

  /**
   *仮想端末スタッフ一覧
   */
  private String lcdStaffList;

  /**
   * 表示フラグ
   */
  private String isDisp;
  /**
   * 削除フラグ
   */
  private String isDel;

  /**
   * オフライン自動開始時間
   */
  private Integer offlineStartTime;
  /**
   * オフライン運転終了時間
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
  /**
   * 治療中リアルタイムモニタ通知間隔
   */
  private Integer treatRealtimeMonitoInterval;
  /**
   * 治療外リアルタイムモニタ通知間隔
   */
  private Integer otherRealtimeMonitoInterval;
  /**
   * 次患者情報2段組表示
   */
  private String nextPatSplitarea;
}
