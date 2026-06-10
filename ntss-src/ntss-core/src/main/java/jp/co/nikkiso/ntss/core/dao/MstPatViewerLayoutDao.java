package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.custom.MstPatViewerLayoutMonitorItem;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstPatViewerLayout;

/**
 * mst_pat_viewer_layout(患者経過総合ビューアレイアウトマスタ)のインターフェイスクラス
 */
@ConfigAutowireable
@Dao
public interface MstPatViewerLayoutDao {

  /**
   * 与えられた{@link MstPatViewerLayout}内に格納された施設コードに該当する{@link MstPatViewerLayout}を取得する.
   *
   * @param options セレクトオプション
   * @param params {@link MstPatViewerLayout}
   * @return {@link MstPatViewerLayout}のリスト
   */
  @Select
  List<MstPatViewerLayout> selectAll(SelectOptions options, MstPatViewerLayout params);

  //add 障害票一覧_NKK.xlsxの3707 対応 韓 start
  /**
   * 与えられた{@link MstPatViewerLayout}内に格納された施設コードに該当する{@link MstPatViewerLayout}を取得する.
   *
   * @param params {@link MstPatViewerLayout}
   * @return {@link MstPatViewerLayout}のリスト
   */
  @Select
  List<MstPatViewerLayout> selectAll(MstPatViewerLayout params);
  //add 障害票一覧_NKK.xlsxの3707 対応 韓 end

  /* modify by chamaojia 2023-06-05 モニタレイアウトマスタ下拉框可以选择バイタル的项目  --start */
  /**
   * 患者経過総合ビューアレイアウトマスタのバイタル・モニタに表示する選択肢を取得する.
   *
   * @param facilityCd 施設コード
   * @param vitalMonitorClass バイタル・モニタクラス
   * @param isAllDisp 全表示フラグ
   * @return 該当するモニタ項目リスト
   */
  @Select
  List<MstPatViewerLayoutMonitorItem> selectMonitorItem(String facilityCd, String vitalMonitorClass, String isAllDisp);
  /* modify by chamaojia 2023-06-05 モニタレイアウトマスタ下拉框可以选择バイタル的项目  --end */
}
