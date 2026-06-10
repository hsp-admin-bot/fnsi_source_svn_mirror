package jp.co.nikkiso.ntss.admin_web.request.userAccount;

import lombok.Data;

import java.io.Serializable;

@Data
public class AuthenticationUser implements Serializable {

  private String userId;

  private String password;

  private String facilityCd;
}
