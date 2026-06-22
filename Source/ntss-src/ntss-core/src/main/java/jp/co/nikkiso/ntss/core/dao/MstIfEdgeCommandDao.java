package jp.co.nikkiso.ntss.core.dao;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstIfEdgeCommand;

import java.util.List;

/**
 * 連携エッジコマンドマスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstIfEdgeCommandDao {

  /**
   * 施設コードを条件に連携エッジクライアント接続状態を取得.
   * @param commandKey コマンドキー
   * @return 連携エッジクライアント接続状態エンティティ
   */
  @Select
  MstIfEdgeCommand selectByKey(String commandKey);

//  add 5615 IFエッジコマンド実行 関 start
  @Select
  List<MstIfEdgeCommand> selectCommand();
//  add 5615 IFエッジコマンド実行 関 end
}
