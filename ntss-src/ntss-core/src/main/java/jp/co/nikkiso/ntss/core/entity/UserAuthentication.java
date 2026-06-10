package jp.co.nikkiso.ntss.core.entity;

import lombok.Data;

@Data
public class UserAuthentication {

  /**
   * ハッシュ値
   */
  private  String  facilityHash;

  /**
   * 施設名
   */
  private  String  facilityName;

  /**
   * 施しの名前
   */
  private  String  username;

//  /**
//   * 施しパスワード
//   */
//  private  String  password;

  private String optStatus;

  private long switchId;

  private String massage;

  private boolean showButton = true;

  private boolean optAuth = false;

  private String secretKey ;

}
