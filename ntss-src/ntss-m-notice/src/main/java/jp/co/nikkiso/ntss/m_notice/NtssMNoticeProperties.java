package jp.co.nikkiso.ntss.m_notice;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import com.amazonaws.regions.Regions;

import lombok.Data;
import org.springframework.util.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;

import javax.annotation.PostConstruct;

import java.util.List;
import java.util.regex.Pattern;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;

/**
 * アプリケーションのプロパティクラスです。
 */
@Component
@ConfigurationProperties(prefix = "ntss.m-notice")
@Data
public class NtssMNoticeProperties {
  /**
   * メール設定
   */
  private Mail mail;

  /**
   * 稼働ビューア設定
   */
  private Viewer viewer;

  /**
   * 日機装施設コード
   */
  private String nikkisoFacilityCd;

  /**
   * 日機装ユーザーメールアドレスかどうかを判定するための正規表現.
   */
  private String nikkisoUserMailAddressRegex;

  /**
   * 正規表現オブジェクト.
   */
  private Pattern nikkisoUserMailAddressPattern;

  /**
   * 利用者マスタ(個人情報DB)Dao
   */
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  /**
   * 初期化.
   */
  @PostConstruct
  public void init() {
    this.nikkisoUserMailAddressPattern = Pattern.compile(this.nikkisoUserMailAddressRegex);
  }

  /**
   * メール設定クラスです。
   */
  @Data
  public static class Mail {
    /**
     * 送信元メールアドレス
     */
    private String fromAddress;
    /**
     * AmazonSESを利用するリージョン
     */
    private Regions sesRegion = Regions.US_WEST_2;

    public void setSesRegion(String regionName) {
      this.sesRegion = Regions.fromName(regionName);
    }

    public String getSesRegion() {
      return this.sesRegion.getName();
    }
  }

  /**
   * メール本文に埋め込む稼働ビューアに関する設定クラスです。
   */
  @Data
  public static class Viewer {
    /**
     * 稼働ビューアのURL情報
     */
    private String url;
    /**
     * 稼働ビューアのURL情報(日機装施設)
     */
    private String nkkurl;
  }

  /**
   * 引数で指定されたメールアドレスが日機装ユーザーのものかどうかを判定する.
   *
   * @param mailAddress メールアドレス
   * @param isChkTypeNikkiso {@code true}である場合、 メールアドレス登録者に日機装ユーザが含まれるか判定する。
   *  {@code false}である場合、 メールアドレス登録者に一般ユーザが含まれるか判定する。
   * @return {@code true}である場合、 日機装ユーザ(isChkTypeNikkiso = true)/一般ユーザ(isChkTypeNikkiso = false)のメールアドレスが含まれる.
   */
  public boolean chkMailAddressUserType(String mailAddress, boolean isChkTypeNikkiso) {
    if (!StringUtils.hasText(mailAddress)) {
      return false;
    }
    
    // 対象のメールアドレスがメールアドレス1またはメールアドレス2に指定されている利用者一覧を取得
    List<MstPersonalUser> lstUsr = mstPersonalUserDao.selectByUserEmailAddressList(mailAddress);
    
    // 戻り値用フラグ
    boolean isChkResult = false;
    String strUsrTyp;
    
    if (isChkTypeNikkiso)
    {
      // 日機装ユーザーのアドレスかチェック(ユーザーリストの中に一人でもuser_type=1のユーザがいた場合はtrue)
      strUsrTyp = CoreConstant.UserType.NIKKISO;
    } else
    {
      // 一般ユーザーのアドレスかチェック(ユーザーリストの中に一人でもuser_type=0のユーザがいた場合はtrue)
      strUsrTyp = CoreConstant.UserType.GENERAL;
    }
    
    for(MstPersonalUser usr:lstUsr)
    {
      // 取得したユーザリストのuser_typeをチェック
      if (strUsrTyp.equals(usr.getUserType().toString()))
      {
        isChkResult = true;
        break;
      }
    }
    
    return isChkResult;
  }
}
