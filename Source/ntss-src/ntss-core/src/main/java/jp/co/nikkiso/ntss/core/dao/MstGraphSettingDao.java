package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.Insert;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstGraphSetting;


@ConfigAutowireable
@Dao
public interface MstGraphSettingDao {

  /**
   * マスタメンテナンス用：施設コードと管理番号をもとに当該施設の現有効設定値を取得(マスタ値出力／マスタにない場合はシステムデフォルト値を表示)
   * 施設コード：必須　P-Ca9分割グラフ設定番号：nullの場合は条件から除外
   * 複数検索及び0件許容用
   * @param facilityCd 施設コード
   * @param graphSettingNo P-Ca9分割グラフ設定番号 (Null許容)
   * @return 共通P-Ca9分割グラフ設定情報
   */
  @Select
  List<MstGraphSetting> selectGraphSetting(String facilityCd);


  /**
   * 登録値を更新.
   * @param MstGraphSetting P-Ca9分割グラフ設定情報
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int update(MstGraphSetting mstGraphSetting);

  /**
   * 新規P-Ca9分割グラフ設定を登録
   * @param MstGraphSetting P-Ca9分割グラフ設定情報
   * @return 更新件数
   */
  @Insert(sqlFile = true)
  int insert(MstGraphSetting mstGraphSetting);

  /**
   * 設定Noでグラフ設定を取得する
   * @param facilityCd 施設コード
   * @param graphSettingNos 設定No
   * @return
   */
  @Select
  List<MstGraphSetting> getBySettingNos(String facilityCd);
}
