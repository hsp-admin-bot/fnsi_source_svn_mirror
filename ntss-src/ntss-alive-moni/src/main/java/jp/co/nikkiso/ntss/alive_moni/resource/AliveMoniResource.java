package jp.co.nikkiso.ntss.alive_moni.resource;

import java.util.Base64;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.alive_moni.service.AliveMoniService;
import jp.co.nikkiso.ntss.alive_moni.service.AliveMoniService.AliveMoniTarget;
import jp.co.nikkiso.ntss.alive_moni.service.AliveMoniService.PublishInfo;
import jp.co.nikkiso.ntss.alive_moni.service.LogService;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;


@RestController
@RequestMapping("/api")
public class AliveMoniResource
{
	@Autowired
	private AliveMoniService aliveMoniSv;

	@Autowired
	private LogService logService;

	/**
	 * 受信時に受け取るデータ格納用クラス
	 */
	private static class ResponseData
	{
		public String content;
	}

	/**
	 * 死活監視要求
	 * @param target
	 * @return
	 */
	@PostMapping("/request")
	public HttpStatus Request(@RequestBody String target)
	{

		EventLogMessage eventLogMessage = new EventLogMessage();

		eventLogMessage.setLogMessage("死活監視API：起動確認要求処理開始");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
		logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
		eventLogMessage.setLogMessage("死活監視API：呼び出し側からの受信情報[\" + target + \"]");
		logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
		// 戻り値
		HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;

		AliveMoniTarget targetData = null;
		ObjectMapper mapper = new ObjectMapper();
		try
		{
			targetData = mapper.readValue(target, AliveMoniTarget.class);
		}
		catch (Exception e)
		{

			eventLogMessage.setLogMessage("死活監視API：受け取った情報の変換処理に失敗　受信情報[" + target + "]、" + e.getMessage());
			eventLogMessage.setDeviceEdgeNo(String.valueOf(targetData.getDeviceEdgeNo()));
			eventLogMessage.setFacilityCd(targetData.getFacilityCd());
			logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
			return status;
		}

		// 死活監視要求
		PublishInfo publishInfo = this.aliveMoniSv.AliveMoni(targetData);
		if (false == publishInfo.Result)
		{

			eventLogMessage.setLogMessage("死活監視API：要求失敗　対象施設コード[" + targetData.getFacilityCd() + "]、対象デバイスエッジ番号 [" + targetData.getDeviceEdgeNo() + "]");
			eventLogMessage.setDeviceEdgeNo(String.valueOf(targetData.getDeviceEdgeNo()));
			eventLogMessage.setFacilityCd(targetData.getFacilityCd());
			logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
			return status;
		}
		else
		{
			eventLogMessage.setLogMessage("死活監視API：要求成功　対象施設コード[" + targetData.getFacilityCd() + "]、対象デバイスエッジ番号 [" + targetData.getDeviceEdgeNo() + "]");
			eventLogMessage.setDeviceEdgeNo(String.valueOf(targetData.getDeviceEdgeNo()));
			eventLogMessage.setFacilityCd(targetData.getFacilityCd());
			logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
			status = HttpStatus.OK;
		}

		return status;
	}

	/**
	 * 死活監視受信
	 * @param body
	 * @return
	 */
	@PostMapping("/response")
	public HttpStatus Response(@RequestBody String body)
	{

		EventLogMessage eventLogMessage = new EventLogMessage();
		eventLogMessage.setLogMessage("死活監視API：死活監視受信処理開始");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
		logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
		eventLogMessage.setLogMessage("死活監視API：呼び出し側からの受信情報[" + body + "]");
		logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);

		// 戻り値
		HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;

		// 受信データJson形式なので一度クラスに格納
		ObjectMapper mapper = new ObjectMapper();
		ResponseData data;
		try
		{
			data = mapper.readValue(body, ResponseData.class);
		}
		catch (Exception e)
		{
			eventLogMessage.setLogMessage("死活監視API：受け取った情報の変換処理に失敗　受信情報[" + body + "]" + e.getMessage());
			logService.log(LogLevel.ERROR, eventLogMessage,null, SERVICE_NAME.REMS, null);
			return status;
		}

		eventLogMessage.setLogMessage("死活監視API：受信情報変換前[" + data.content + "]");
		logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

		// Base64のデータをデコード
		String strReceptData = new String(Base64.getDecoder().decode(data.content));

		eventLogMessage.setLogMessage("死活監視API：受信情報変換後[" + strReceptData + "]");
		logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);

		// 死活監視受信処理
		boolean ret = this.aliveMoniSv.AliveMoniResponse(strReceptData);
		if (false == ret)
		{
			// エラー
			eventLogMessage.setLogMessage("死活監視API：受信処理失敗");
			logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);

			return status;
		}

		status = HttpStatus.OK;

		eventLogMessage.setLogMessage("死活監視API：受信処理成功");
		logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

		return status;
	}

}
