package jp.co.nikkiso.ntss.admin_web.security;

import jp.co.nikkiso.ntss.admin_web.exception.DataSourceInconsistencyAuthenticationException;
import jp.co.nikkiso.ntss.admin_web.response.error.ErrorResponse;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.MODULE_NAME;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.converter.json.JacksonJsonHttpMessageConverter;
import org.springframework.http.server.ServletServerHttpResponse;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import jp.co.nikkiso.ntss.core.dao.MstFacilityHashDao;
import jp.co.nikkiso.ntss.core.entity.MstFacilityHash;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

import static jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage.Error.DB_INCONSISTENCY;
import static jp.co.nikkiso.ntss.admin_web.security.NtssAuthenticationConstants.Params;

/**
 * NTSS認証失敗ハンドラー実装クラス.
 */
public class NtssAuthenticationFailureHandler implements AuthenticationFailureHandler {

  // FNSI-修正 ログ対応 xiebzh add start
  /** ログメッセージフォーマット */
  private final static String LOG_MESSAGE = "サインインに失敗しました。";
  // FNSI-修正 ログ対応 xiebzh add start

  /**
   * Response内容にJSONを書き込む.
   */
  @Autowired
  private JacksonJsonHttpMessageConverter httpMessageConverter;

  /**
   * ロガー生成コンポーネント
   */
  //FNSI-修正 ログ対応 xiebzh add start
  //  @Autowired
  //  private EventLoggerFactory eventLoggerFactory;
  //FNSI-修正 ログ対応 xiebzh add end

  /**
   * 施設マスタハッシュDaoインタフェース.
   */
  @Autowired
  private MstFacilityHashDao mstFacilityHashDao;

  //FNSI-修正 ログ対応 xiebzh add start
  @Autowired
  private LogServiceCore logServiceCore;
  //FNSI-修正 ログ対応 xiebzh add end

  /**
   * {@inheritDoc}
   */
  @Override
  public void onAuthenticationFailure(HttpServletRequest request,
                                      HttpServletResponse response,
                                      AuthenticationException exception) throws IOException, ServletException {
    // 施設コードハッシュ値から施設コードを取得
    MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByHashValue(
      request.getParameter(Params.FACILITY_CD)
    );

    if (mstFacilityHash != null) {
      //FNSI-修正 ログ対応 xiebzh add start
      // 失敗時のログ
//      eventLoggerFactory.getLogger(mstFacilityHash.getFacilityCd()).info(
//        new EventLogMessage(
//          mstFacilityHash.getFacilityCd(),
//          request.getParameter(Params.USERNAME),
//          request.getRemoteAddr(),
//          request.getRequestedSessionId(),
//          "",
//          "",
//          "",
//          "",
//          "",
//          MODULE_NAME.ADMIN_WEB + "," + SERVICE_NAME.FNSI,
//          "",
//          "",
//          "",
//          "サインインに失敗しました。",
//          "",
//          this.getClass().getName()
//        )
//      );

      logServiceCore.log(
        LogLevel.INFO,
        new EventLogMessage(
          mstFacilityHash.getFacilityCd(),
          request.getParameter(Params.USERNAME),
          request.getRemoteAddr(),
          request.getRequestedSessionId(),
          "",
          "",
          "",
          "",
          "",
          MODULE_NAME.ADMIN_WEB + "," + SERVICE_NAME.FNSI,
          "",
          "",
          "",
          LOG_MESSAGE,
          "",
          this.getClass().getName(),
          "サインイン"
        ),
        null,
        LoggingConstant.MODULE_NAME.ADMIN_WEB,
        LoggingConstant.SERVICE_NAME.FNSI,
        null
        );
      //FNSI-修正 ログ対応 xiebzh add end
    }

    if (exception instanceof DataSourceInconsistencyAuthenticationException) {
      // データソース間不整合の場合は500を返す
      response.setStatus(DB_INCONSISTENCY.getHttpStatus().value());

      // ReponseにJSON書込
      httpMessageConverter.write(
        new ErrorResponse(DB_INCONSISTENCY.getMessage()),
        MediaType.APPLICATION_JSON,
        new ServletServerHttpResponse(response));
    }
    else {
      /* modify by chamaojia 2023-07-11 ログインエラーリターンメッセージの変更  --start */
      response.setStatus(HttpStatus.FORBIDDEN.value());
      httpMessageConverter.write(
              new ErrorResponse(exception.getMessage()),
              MediaType.APPLICATION_JSON,
              new ServletServerHttpResponse(response));

//      response.sendError(HttpStatus.FORBIDDEN.value(), exception.getMessage());
      /* modify by chamaojia 2023-07-11 ログインエラーリターンメッセージの変更  --end */

    }
  }
}

