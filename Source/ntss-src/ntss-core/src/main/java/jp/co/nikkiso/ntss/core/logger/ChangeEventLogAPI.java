package jp.co.nikkiso.ntss.core.logger;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ChangeEventLogAPI {

	private String ordNo;

  private String rstEdition;

  private String upDate;

  private String upUserId;

  private String upUserName;

  private String message;

  private String rstEditionMax;

  // add FNSI-ログ保存場所の追加 関 end
	public ChangeEventLogAPI(String ordNo, String rstEdition, String upDate, String upUserId, String upUserName,
                             String message, String rstEditionMax) {
		super();
		this.ordNo = ordNo;
		this.rstEdition = rstEdition;
		this.upDate = upDate;
		this.upUserId = upUserId;
		this.upUserName = upUserName;
		this.message = message;
    this.rstEditionMax = rstEditionMax;
	}

  // add FNSI-ログ保存場所の追加 xiebzh start
  public ChangeEventLogAPI() {

  }
  // add FNSI-ログ保存場所の追加 xiebzh end
}
