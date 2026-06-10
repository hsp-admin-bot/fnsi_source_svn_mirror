package jp.co.nikkiso.ntss.web_api.service.component;

import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_DB_CLASS;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_TABLE_NAME;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_ALIAS_COLUMN_NAME;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_CLASS_REMS_CANCEL;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_CLASS_FNSI_CANCEL;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import jp.co.nikkiso.ntss.core.dao.MntFacilityCancelStatAuthDao;
import jp.co.nikkiso.ntss.core.dao.MntFacilityCancelStatDao;
import jp.co.nikkiso.ntss.core.dao.MntFacilityCancelStatDefaultDao;
import jp.co.nikkiso.ntss.core.dao.MntFacilityCancelStatPersonalDao;
import jp.co.nikkiso.ntss.core.entity.MntFacilityCancelStat;
import jp.co.nikkiso.ntss.web_api.config.FacilityCancelConfig;

/**
 * 施設解約の対象テーブルを取得するコンポーネント。
 */
@Component
public class TargetTableCancelComponent implements TargetTableComponent {
  // DAO
  /** 解約施設 統計情報取得（DB4） */
  @Autowired
  private MntFacilityCancelStatAuthDao mntFacilityCancelStatAuthDao;

  /** 解約施設 統計情報取得（DB5） */
  @Autowired
  private MntFacilityCancelStatDefaultDao mntFacilityCancelStatDefaultDao;

  /** 解約施設 統計情報取得（DB6） */
  @Autowired
  private MntFacilityCancelStatPersonalDao mntFacilityCancelStatPersonalDao;

  // 設定
  /** sys_system_define */
  @Autowired
  private FacilityCancelConfig config;

  /**
   * 解約処理対象のテーブルを取得する。
   *
   * @param facilityCd 施設コード
   * @return 解約処理対象を示すJSON文字列
   */
  @Override
  public List<MntFacilityCancelStat> getTargetTableList(String facilityCd) {
    // このメソッドはカーソルを使用しないPostgreSQLデータディクショナリのSELECTのみであるので、
    // 明示的にトランザクションは発行しない。

    // 除外テーブル
    // 以下の方針とする。
    // (1) mnt_facility_cancel_manage
    // 必ず除外対象とし、統計情報中のエントリも作成しない。
    // 設定に記述されていない場合は追加する。
    // 管理レコードを削除してしまうと処理完了後の処理ステータス更新でDBエラー（データ不整合）が発生することによる。
    // (2) mst_user_authentication, mst_facility_hash
    // 統計情報中のエントリを必ず作成し、施設コードに対応するレコードは必ず削除する。
    // （除外テーブルに記述されていても無視する。）
    // (3) その他のテーブル
    // 記述されている場合、統計情報中のエントリを作成せず、レコード削除対象外とする。
    List<String> excludedTableList = config.getExcludedTableList();

    Stream<MntFacilityCancelStatDao> s = Arrays.stream(new MntFacilityCancelStatDao[] {
        mntFacilityCancelStatAuthDao, mntFacilityCancelStatDefaultDao, mntFacilityCancelStatPersonalDao
    });
    List<MntFacilityCancelStat> list = s.map(dao -> dao.select(excludedTableList)).flatMap(lst -> lst.stream()).collect(Collectors.toList());

    // 追加テーブル
    // sys_system_defineに設定されているfacility_cdが別名のテーブルを追加する
    List<Map<String, Object>> targetList = config.getIncludeTableList();
    targetList.forEach(r -> {
      // 削除対象テーブルを追加
      list.add(new MntFacilityCancelStat(
          config.getDbName((Integer) r.get(STAT_KEY_DB_CLASS))
          , (Integer) r.get(STAT_KEY_DB_CLASS)
          , (String) r.get(STAT_KEY_TABLE_NAME)
          , (String) r.get(STAT_KEY_ALIAS_COLUMN_NAME)
          , null));
    });

    return list;
  }

  /**
   * 解約処理対象のテーブルを取得する。
   *
   * @param facilityCd 施設コード
   * @param procClass 処理区分
   * @return 解約処理対象を示すJSON文字列
   */
  @Override
  public List<MntFacilityCancelStat> getTargetTableList(String facilityCd, String procClass) {
    // このメソッドはカーソルを使用しないPostgreSQLデータディクショナリのSELECTのみであるので、
    // 明示的にトランザクションは発行しない。

    // 除外テーブル
    // 以下の方針とする。
    // (1) mnt_facility_cancel_manage
    // 必ず除外対象とし、統計情報中のエントリも作成しない。
    // 設定に記述されていない場合は追加する。
    // 管理レコードを削除してしまうと処理完了後の処理ステータス更新でDBエラー（データ不整合）が発生することによる。
    // (2) mst_user_authentication, mst_facility_hash
    // 統計情報中のエントリを必ず作成し、施設コードに対応するレコードは必ず削除する。
    // （除外テーブルに記述されていても無視する。）
    // (3) その他のテーブル
    // 記述されている場合、統計情報中のエントリを作成せず、レコード削除対象外とする。
    List<String> excludedTableList = config.getExcludedTableList();

    Stream<MntFacilityCancelStatDao> s = Arrays.stream(new MntFacilityCancelStatDao[] {
        mntFacilityCancelStatAuthDao, mntFacilityCancelStatDefaultDao, mntFacilityCancelStatPersonalDao
    });
    List<MntFacilityCancelStat> list = s.map(dao -> dao.select(excludedTableList)).flatMap(lst -> lst.stream()).collect(Collectors.toList());

    // 追加テーブル
    // sys_system_defineに設定されているfacility_cdが別名のテーブルを追加する
    List<Map<String, Object>> targetList = config.getIncludeTableList();
    targetList.forEach(r -> {
      // 削除対象テーブルを追加
      list.add(new MntFacilityCancelStat(
          config.getDbName((Integer) r.get(STAT_KEY_DB_CLASS))
          , (Integer) r.get(STAT_KEY_DB_CLASS)
          , (String) r.get(STAT_KEY_TABLE_NAME)
          , (String) r.get(STAT_KEY_ALIAS_COLUMN_NAME)
          , null));
    });

    if (procClass.equals(PROC_CLASS_REMS_CANCEL)) {
      // ReMSのみ解約の場合、システム設定に定義されているReMSのみ解約対象テーブルリストに含まれるテーブルのみ抽出
      List<String> remsCancelTargetList = config.getRemsCancelTargetTableList();
      return list.stream().filter(stat ->
          remsCancelTargetList.contains(stat.getTableName())
        ).collect(Collectors.toList());
    }

    if (procClass.equals(PROC_CLASS_FNSI_CANCEL)) {
      // FNSiのみ解約の場合、システム設定に定義されているFNSiのみ解約対象外テーブルリストに含まれないテーブルのみ抽出
      List<String> fnsiCancelTargetList = config.getFnsiCancelExcludeTableList();
      return list.stream().filter(stat ->
          !fnsiCancelTargetList.contains(stat.getTableName())
        ).collect(Collectors.toList());
    }

    return list;
  }
}
