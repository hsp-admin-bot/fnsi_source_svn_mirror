package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 連携エッジコマンドマスタEntity
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_if_edge_command")
@Getter
@Setter
public class MstIfEdgeCommand extends BaseEntity {

  /** 管理番号 */
  @Id
  private Long ctlNo;

  /** コマンドキー */
  private String commandKey;

  /** コマンド内容 */
  private String command;

  /** 設定ファイル追加 */
  private String addSetting;

  /** 削除フラグ */
  private String isDel;

//  add 5615 IFエッジコマンド実行 関 start
  /** 処理名 */
  private String processing;

  /** 処理詳細 */
  private String processing_detail;
//  add 5615 IFエッジコマンド実行 関 end
}
