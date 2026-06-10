package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 連携情報Entity
 *
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "pat_coop_detail")
@Getter
@Setter
public class ConIntelligenceListmon extends BaseEntity {
  /** 連携情報カラム1 */
  private String save1;
  /** 連携情報カラム2 */
  private String save2;
  /** 連携情報カラム3 */
  private String save3;
  /** 連携情報カラム4 */
  private String save4;
  /** 連携情報カラム5 */
  private String save5;
  /** 連携情報カラム6 */
  private String save6;
  /** 連携情報カラム7 */
  private String save7;
  /** 連携情報カラム8 */
  private String save8;
  /** 連携情報カラム9 */
  private String save9;
  /** 連携情報カラム10 */
  private String save10;
 }
