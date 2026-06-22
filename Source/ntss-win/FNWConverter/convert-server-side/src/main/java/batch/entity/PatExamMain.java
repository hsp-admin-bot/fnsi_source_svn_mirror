package batch.entity;

import lombok.Getter;
import lombok.Setter;
import org.json.JSONArray;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "pat_exam_main")
@Getter
@Setter
public class PatExamMain extends BaseEntity {
	@Id
	private Long exam_main_cd;
	private Long pat_id;
	private String facility_cd;
	private Long ord_no;
	private String fn_pat_id;
	private Timestamp reg_exam_date;
	private String reg_order_class;
	private String exam_status;
	private String order_comment;
	private JSONArray order_exam_set_info;
	private JSONArray exam_order_info;
	private JSONArray order_label_info;
	private String data_gen_class;
	private Timestamp result_exam_date;
	private String result_comment;
	private JSONArray exam_result_info;
	private Long cop_order_no1;
	private Long cop_order_no2;
	private String is_lock;
	private Long ind_user_id;
	private String is_del;
	private Timestamp reg_date;
	private Long reg_staff;
	private Timestamp up_date;
	private Long up_staff;
	private String is_order;
	private Integer exam_week;
	private Timestamp exam_from;
	private Timestamp exam_to;
	private Integer exam_pattern;
	private String phy_ord_class;

	/**
	 * csvを変換し、csvを書き込むためのtoStringメソッドの書き換え
	 *
	 * @return
	 */
	@Override
	public String toString() {
		StringBuffer sb = new StringBuffer();
		sb.append(facility_cd).append(",")
				.append(pat_id).append(",")
				.append(fn_pat_id).append(",")
				.append(order_exam_set_info).append(",")
				.append(exam_order_info).append(",")
				.append(order_label_info).append(",")
				.append(result_exam_date == null ? "" : result_exam_date).append(",")
				.append(reg_exam_date == null ? "" : reg_exam_date).append(",")
				.append(reg_order_class == null ? "" : reg_order_class).append(",")
				.append(data_gen_class == null ? "" : data_gen_class).append(",")
				.append(is_del == null ? "" : is_del).append(",")
				.append(exam_status == null ? "" : exam_status).append(",")
				.append(is_order == null ? "" : is_order).append(",")
				.append(up_date == null ? "" : up_date).append(",")
				.append(reg_date == null ? "" : reg_date).append(",")
				.append(exam_result_info == null ? null : exam_result_info.toString().replace(",", "|"));
		return sb.toString();
	}

	/**
	 * csvを変換し、csvを書き込むためのtoStringメソッドの書き換え
	 *
	 * @return
	 */
	public String schToString() {
		StringBuffer sb = new StringBuffer();
		sb.append(facility_cd).append(",")
				.append(pat_id).append(",")
				.append(fn_pat_id).append(",")
				.append(order_label_info).append(",")
				.append(reg_exam_date == null ? "" : reg_exam_date).append(",")
				.append(reg_order_class == null ? "" : reg_order_class).append(",")
				.append(ind_user_id == null ? "" : ind_user_id).append(",")
				.append(reg_staff == null ? "" : reg_staff).append(",")
				.append(up_staff == null ? "" : up_staff).append(",")
				.append(exam_status == null ? "" : exam_status).append(",")
				.append(is_order == null ? "" : is_order).append(",")
				.append(data_gen_class == null ? "" : data_gen_class).append(",")
				.append(up_date == null ? "" : up_date).append(",")
				.append(reg_date == null ? "" : reg_date).append(",")
				.append(order_exam_set_info == null ? null : order_exam_set_info.toString().replace(",", "|")).append(",")
				.append(exam_order_info == null ? null : exam_order_info.toString().replace(",", "|"));
		return sb.toString();
	}
}

