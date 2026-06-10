package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@EqualsAndHashCode(callSuper=false)
@Data
public class OrdChAp extends PatIndApprove{
//	PatPersonalMain
	/**
	 * システムで管理する一意なオーダ番号
	 */
	private Long ord_no;

	/**
	 * システムで管理する一意な患者Info
	 */
//	private PatPersonalMain patInfo;

	/**
	 * システムで管理する一意な患者Id
	 */
	private Long pat_id;

	/**
	 * 治療日
	 */
	private String treat_date;

	/**
	 * 指示：治療方法コード
	 */
	private Integer ind_treatment_cd;

	/**
	 * 指示：治療方法名
	 */
	private String ind_treatment_name;

	/**
	 * 指示：クールコード
	 */
	private Integer ind_kur_cd;

	/**
	 * 指示：クール名
	 */
	private String ind_kur_name;

	/**
	 * 指示：治療予定指示者情報
	 */
	private String ind_schedule_user_info;

	/**
	 * 院内表示用の患者ID
	 */
	private String hosp_pat_id;

	/**
	 * 患者氏名(漢字姓)
	 */
	private String pat_last_name;

	/**
	 * 患者氏名(漢字名)
	 */
	private String pat_first_name;

	/**
	 * 患者氏名(カタカナ名)
	 */
	private String pat_first_name_kana;

	/**
	 * 患者氏名(カタカナ姓)
	 */
	private String pat_last_name_kana;

	/**
	 * 指示：ベッドコード
	 */
	private Long ind_bed_cd;
  // add FNSI-7570 劉全航 start
	private String rst_dialysis_state;
  // add FNSI-7570 劉全航 end
	
	/**
	 * 指示：クール開始時刻
	 */
	private String ind_kur_start_time;
	/**
	 * 指示：治療方法マスタ表示順
	 */
	private Long ind_treatment_order_index;
	/**
	 * 指示：ベッドマスタ表示順
	 */
	private Long ind_bed_order_index;
}
