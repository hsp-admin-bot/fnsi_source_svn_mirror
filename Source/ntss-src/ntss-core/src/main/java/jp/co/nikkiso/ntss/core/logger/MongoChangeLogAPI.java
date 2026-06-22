package jp.co.nikkiso.ntss.core.logger;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MongoChangeLogAPI {
  private String ord_no;
  private String rst_edition;
  private String up_date;
  private String up_user_id;
  private String up_user_name;
  private String message;
}
