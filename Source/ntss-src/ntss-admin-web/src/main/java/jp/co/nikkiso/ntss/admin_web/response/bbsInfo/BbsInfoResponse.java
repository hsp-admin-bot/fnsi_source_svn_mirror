package jp.co.nikkiso.ntss.admin_web.response.bbsInfo;

import org.seasar.doma.Id;

import lombok.Data;

/**
 * 掲示板番号のResponseクラス.
 */
@Data
public class BbsInfoResponse {
	  /**
	   * 掲示板番号
	   */
	  @Id
	  private Long bbs_ctl_no;

	  /**
	   * 対象患者
	   */
	  private String pat_info;

	  /**
	   * 対象スタッフ
	   */
	  private String staff_info;

	  /**
	   * タイトル
	   */
	  private String title;

	  /**
	   * 内容
	   */
	  private String content;

	  /**
	   * ファイル情報
	   */
	  private String file_info;

	  /**
	   * 遷移先機能パス
	   */
	  private String transition_router_path;

	  /**
	   * 施設カレンダーの開始日に投稿.
	   */
	  private String notice_fac_cal_start_date;

	  /**
	   * 施設カレンダーの終了日に投稿.
	   */
	  private String notice_fac_cal_end_date;

//	   add FNSI-434 改修内容 施設カレンダのみに表示 趙立強 start
    /**
     * 施設カレンダーイベント開始時刻.
     */
	  private String notice_fac_cal_start_time;

    /**
     * 施設カレンダーイベント終了時刻.
     */
	  private  String notice_fac_cal_end_time;
//  add FNSI-434 改修内容 施設カレンダのみに表示 趙立強 end

	  /**
	   * 掲示板フラグに表示.
	   */
	  private String is_disp_bbs;

	  /**
	   * 色.
	   */
	  private String color;
//  add FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 start
    /**
    * 文字色.
    */
    private String font_color;
//  add FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 end
	  /**
	   * 種別名
	   */
	  private String kindName;
}
