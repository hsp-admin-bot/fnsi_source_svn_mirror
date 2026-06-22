package jp.co.nikkiso.ntss.certificate_management.constant;

public class ClientCertificateConstant {

	public static class Uri {

		public static final String LOGIN = "/api/login";

		public static final String CLUSER = "/api/cl-user";

		public static final String CLUSERSETTING = "/api/cl-user/getUserSetting";

		public static final String CLFACILITYSETTING = "/api/cl-facility/getFacilitySetting";

		public static final String CLDETAILS = "/api/cl-details";

		public static final String CLFACILITY = "/api/cl-facility";

		public static final String LOGOUT = "/api/logout";
	}

	public static class ScreenName {

		public static final String MANAGEMENT_FACILITY_LIST = "[管理サイト]施設一覧画面​​";

		public static final String MANAGEMENT_EDIT_SCREEN = "[管理サイト]施設編集画面​​";

		public static final String MANAGEMENT_CL_ISSUE = "[管理サイト] CL証明書発行画面​​";

		public static final String MANAGEMENT_USER_LIST = "[管理サイト]ユーザ一覧画面​​";

		public static final String MANAGEMENT_USER_EDIT_SCREEN = "[管理サイト]ユーザー追加・編集画面​​";;

		public static final String MANAGEMENT_LOGIN = "[管理サイト]ログイン画面";
    //add FNSI-【1006】最新の改修対象一覧.NO50を修正 周安寧 start
    public static final String MANAGEMENT_SHOW = "[管理サイト]CL証明書発行一覧画面";
    //add FNSI-【1006】最新の改修対象一覧.NO50を修正 周安寧 end
	}

}
