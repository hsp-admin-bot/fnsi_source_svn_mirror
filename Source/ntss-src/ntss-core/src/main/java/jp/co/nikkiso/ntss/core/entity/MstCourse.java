package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstCourseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 診療科クラス
 */
@Entity(listener = MstCourseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_course")
@Getter
@Setter
public class MstCourse extends BaseBlankEntity {

  /**
   * 診療科コード
   */
  @Id
  private Integer courseCd;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * FNW+で管理する施設内の一意な診療科コード
   */
  private String fnCourseCd;

  /**
   * 診療科名
   */
  private String courseName;
  /**
   * 標準診療科コード
   */
  private String standardCourseCd
;
  /**
   * 連携コード
   */
  private String inHospitalCd_1;
  /**
   * 表示フラグ
   */
  private String isDisp;
  /**
   * 削除フラグ
   */
  private String isDel;
  /**
   * 登録日時
   */
  private String regDate;
  /**
   * 更新日時
   */
  private String upDate;
}
