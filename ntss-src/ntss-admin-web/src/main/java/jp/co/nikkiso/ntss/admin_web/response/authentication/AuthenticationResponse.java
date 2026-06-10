package jp.co.nikkiso.ntss.admin_web.response.authentication;

import lombok.Data;

@Data
public class AuthenticationResponse {
  private boolean succeed;
  private String errMsg;
  private String secretKey;
  private String facilityName;
}
