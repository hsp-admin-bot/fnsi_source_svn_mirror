package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
/**
 * クライアント証明書ユーザー
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "client_cer_user")
@Getter
@Setter
public class ClUser {
  
  //ID
  @Id
  private long id;

  //ユーザーID
  private String userId;

  //ユーザー役割
  private String userRole;

  //ユーザーのフルネーム
  private String userName;

  //ユーザーのパスワード
  private String userPass;

  //部門コード
  private String departmentCd;

  //登録日
  private Timestamp regDate;

  //更新日
  private Timestamp upDate;

  //失敗したサインインの数
  private int numLoginAttempt;

  //削除フラグ
  private String isDelete;

}
