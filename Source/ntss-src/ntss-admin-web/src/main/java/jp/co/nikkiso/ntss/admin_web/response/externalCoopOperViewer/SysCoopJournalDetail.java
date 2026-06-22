package jp.co.nikkiso.ntss.admin_web.response.externalCoopOperViewer;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import lombok.Getter;
import lombok.Setter;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class SysCoopJournalDetail extends SysCoopJournal {

  /**
   * 患者名
   */
  private String patName;
  /**
   * 患者氏名(姓)
   */
  private String patLastName;
  /**
   * 患者氏名(名)
   */
  private String patFirstName;
  /**
   * 患者氏名(カタカナ姓)
   */
  private String patLastNameKana;
  /**
   * 患者氏名(カタカナ名)
   */
  private String patFirstNameKana;
}
