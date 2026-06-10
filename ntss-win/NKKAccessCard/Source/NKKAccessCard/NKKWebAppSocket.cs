using System.IO;
using NKKCommon;

namespace NKKAccessCardLib
{
	using System;
	using NKKLoggingLib;
	using SuperWebSocket;
	using WebSocketSharp;
	using NKKWebAccessLib;
	using System.Collections.Generic;
	using System.Text;
	using Newtonsoft.Json;
	// add redmai #4820 「患者カードを作成しても透析装置でデータ異常と表示される」を修正する。 鄧シン start
	using System.Linq;
    using ToGUILib;

    // add redmai #4820 「患者カードを作成しても透析装置でデータ異常と表示される」を修正する。 鄧シン end

    public class SocketServerParameter
	{
		public int Port { get; set; }
		public string Host { get; set; }
	}

	public class SocketClientParameter
	{
		public string URL { get; set; }
	}

	public static class NKKWebAppSocketConfig
	{
		public static int WS_PORT;
		public static string WS_URL;
	}

	public class NKKWebAppSocket : ToGUI
	{
		//----------------------------------------------------------------------------------------------------
		/// <summary>
		/// サービス名
		/// </summary>
		//----------------------------------------------------------------------------------------------------
		private readonly String SERVICE_NAME = "WebSocket";
		//----------------------------------------------------------------------------------------------------

		public static NKKWebAppSocket webAppSocket;
		private static WebSocketServer _ws;
		private const int INFO = 1;
		private const int ERROR = 2;
		private const string BROWSER = "BROWSER";
		private const string CARD_CLIENT = "CARD_CLIENT";
		public static string WS_URL = NKKWebAppSocketConfig.WS_URL;
		public static int WS_PORT = NKKWebAppSocketConfig.WS_PORT;
		private const string GET_STAFF_INFO_URI = "/api/card_state/staff_info/";
		private const string GET_PAT_INFO_URI = "/api/card_state/pat_info/";
		private const string SET_STAFF_CARD_NO_URI = "/api/card_state/setCard";
        // add 2020-08-13 FNSI-仕様追加 患者基本情報(pat_main)にアクセスカード番号(card_idm)の追加処理 夏 start
        private const string SET_PATIENT_CARD_NO_URI = "/api/card_state/setPatCard";
		// add 2020-08-13 FNSI-仕様追加 患者基本情報(pat_main)にアクセスカード番号(card_idm)の追加処理 夏 end

		// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 start
		// 患者カード_設定項目のフォーマット
		private readonly static Dictionary<String, Int32> dictDecimalNumber = new Dictionary<String, Int32>();
		// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 end

		private readonly CardConfiguration _cardConfiguration;
		private List<WebSocketSession> connectingSessions = new List<WebSocketSession>();

		public NKKWebAppSocket()
		{
			var cardConfigPath = AppDomain.CurrentDomain.BaseDirectory + "\\card-config.json";
			using (var reader = new JsonTextReader(new StreamReader(File.OpenRead(cardConfigPath))))
			{
				_cardConfiguration = JsonSerializer.CreateDefault().Deserialize<CardConfiguration>(reader);
				Console.WriteLine(_cardConfiguration);
			}
		}

		public static NKKWebAppSocket GetInstance()
		{
			// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 start

			if (dictDecimalNumber.Count == 0)
            {
				dictDecimalNumber.Add("weight_before", 2); // 前体重
				dictDecimalNumber.Add("weight_mea", 2); // 体重測定値
				dictDecimalNumber.Add("target_weight", 2); // 目標体重
				dictDecimalNumber.Add("water_info_weight_1", 2); // 除水補正値1 重量
				dictDecimalNumber.Add("water_info_weight_2", 2); // 除水補正値2 重量
				dictDecimalNumber.Add("water_info_weight_3", 2); // 除水補正値3 重量
				dictDecimalNumber.Add("water_info_weight_4", 2); // 除水補正値4 重量
				dictDecimalNumber.Add("water_info_weight_5", 2); // 除水補正値5 重量
				dictDecimalNumber.Add("ind_tare_info_weight_1", 2); // 風袋補正値1 重量
				dictDecimalNumber.Add("ind_tare_info_weight_2", 2); // 風袋補正値2 重量
				dictDecimalNumber.Add("ind_tare_info_weight_3", 2); // 風袋補正値3 重量
				dictDecimalNumber.Add("ind_tare_info_weight_4", 2); // 風袋補正値4 重量
				dictDecimalNumber.Add("ind_tare_info_weight_5", 2); // 風袋補正値5 重量
				dictDecimalNumber.Add("ind_cond_info_20", 1); // 補液量設定
				dictDecimalNumber.Add("ind_cond_info_24", 1); // 補液速度 
				dictDecimalNumber.Add("ind_cond_info_23", 2); // 補液温度
				dictDecimalNumber.Add("ind_cond_info_31", 1); // IPワンショット量
				dictDecimalNumber.Add("ind_cond_info_32", 1); // IP速度
				dictDecimalNumber.Add("ind_cond_info_18", 2); // 透析液温度
				dictDecimalNumber.Add("treat_condition_181", 2); // 除水速度操作範囲上限 
			}
			// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 end

			if (webAppSocket == null)
			{
				webAppSocket = new NKKWebAppSocket();
				webAppSocket.SetupSocketServer(new SocketServerParameter());
			}
			return webAppSocket;
		}

		public void SetupSocketServer(SocketServerParameter socketServerParameter)
		{
			LogInfo("WS_URL:" + WS_URL, INFO);
			try
			{
				RegisterAndOpenWS(socketServerParameter);
				RegisterClientTemp(new SocketClientParameter
				{
					URL = WS_URL
				});
			}
			catch (Exception ex)
			{
				LogInfo(ex.ToString(), ERROR);
			}
		}

		public string Getlocalip()
		{
			return "localhost";
		}

		public void RegisterClientTemp(SocketClientParameter _)
		{
			try
			{
				string url = string.Format("{0}:{1}", WS_URL, WS_PORT);
				LogInfo(url, INFO);
				NKKWebAppSocketClient.wsClient = new WebSocket(url);
				NKKWebAppSocketClient.wsClient.Connect();
				LogInfo("Create card app socket session success", INFO);
			}
			catch (Exception e)
			{
				LogInfo(e.ToString(), ERROR);
			}

		}

		private void RegisterAndOpenWS(SocketServerParameter _)
		{
			LogInfo("WS_POST_SOCKET_SERVER: " + WS_PORT, INFO);
			if (_ws == null)
			{
				_ws = new WebSocketServer();
				_ws.Setup(WS_PORT);
				_ws.NewSessionConnected += WsServer_NewSessionConnected;
				_ws.NewMessageReceived += WsServer_NewMessageReceived;
				_ws.NewDataReceived += WsServer_NewDataReceived;
				_ws.SessionClosed += WsServer_SessionClosed;
				_ws.Start();
			}
		}

		/// <summary>
		/// GUI通知
		/// </summary>
		/// <param name="strStatus">状態</param>
		/// <param name="dtOccurDate">発生日時</param>
		/// <param name="strMessage">内容</param>
		//----------------------------------------------------------------------------------------------------
		private void SendMessageToGUI(String strStatus, DateTime dtOccurDate, String strMessage)
		{
			// GUIへ通知
			base.SendMessageToGUI(this.SERVICE_NAME, strStatus, dtOccurDate, strMessage);
		}

		public void SendMessage(string message)
		{
			if (NKKWebAppSocketClient.wsClient.ReadyState == WebSocketState.Closed)
			{
				RegisterClientTemp(new SocketClientParameter());
			}
			try
			{
				//mod #9511 FNSiカードアプリが一方のブラウザとしかつながらない。 donghao start
				foreach (var webSocketSession in connectingSessions)
                {
					webSocketSession.Send(message);

				}

				//NKKWebAppSocketClient.wsClient.Send(message);
				//mod #9511 FNSiカードアプリが一方のブラウザとしかつながらない。 donghao end
			}
			catch (Exception ex)
			{
				LogInfo(ex.ToString(), ERROR);
			}
			
		}

		private void WsServer_SessionClosed(WebSocketSession session, SuperSocket.SocketBase.CloseReason value)
		{
			Console.WriteLine("SessionClosed");
			if(!CheckBrowserConnection())
            {
				this.SendMessageToGUI("未接続", DateTime.Now, "接続終了");
			}
		}

		private void WsServer_NewDataReceived(WebSocketSession session, byte[] value)
		{
		}

		private void WsServer_NewMessageReceived(WebSocketSession session, string strMessage)
		{
			if (strMessage.Equals(" "))
			{
				session.Send(" ");
				return;
			}
			String[] strlines = strMessage.Split(new char[] { '\t' }, StringSplitOptions.None);
			string clientType = strlines[0];
			if (clientType.Equals(BROWSER))
			{
				if (strlines.Length < 2)
				{
					return;
				}
				string topic = strlines[1];

				string strlog = String.Format("ブラウザから受信：{0}", topic);
				this.SendMessageToGUI("接続中", DateTime.Now, strlog);

				string status = "";
				try
				{
					switch (topic)
					{
						case "WRITE_STAFF_CARD":
							// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 start
							LogInfo("--->WriteStaffCard Start!", INFO);
							// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 end
							try
							{
								status = WriteStaffCard(strlines[2]).ToString();
							} catch (Exception e)
							{
								// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 start
								LogInfo("--->WriteCard NG：" + e.ToString(), ERROR);
								// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 end
								status = "false";
							}
							// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 start
							LogInfo("--->WriteStaffCard End!", INFO);
							// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 end
							SendToWebClient(session, status, "CARD_WRITE_STATUS");
							break;
						case "WRITE_PAT_CARD":
							// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 start
							LogInfo("--->WritePatCard Start!", INFO);
							// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 end
							try
							{
								status = WritePatCard(strlines[2]).ToString();
							} catch (Exception e)
							{
								// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 start
								LogInfo("--->WriteCard NG：" + e.ToString(), ERROR);
								// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 end
								status = "false";
							}
							// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 start
							LogInfo("--->WritePatCard End!", INFO);
							// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 end
							SendToWebClient(session, status, "CARD_WRITE_STATUS");
							break;
						case "CARD_READER_STATUS":
							GetCardDeviceStatus(session);
							break;
					}
				}
				catch (Exception ex)
				{
					LogInfo("ERROR: " + ex, ERROR);
				}

			}
			else if (clientType.Equals(CARD_CLIENT))
			{
				string message = strlines[2];
				// mod FNSI-4200ポートを使用している 孫 start
				if (strlines.Length >= 4)
                {
					message = String.Format("{0}\t{1}", strlines[2], strlines[3]);
				}
				// mod FNSI-4200ポートを使用している 孫 end
				string topic = strlines[1];
				SendToAllWebClient(message, topic);
			}
		}

		private void WsServer_NewSessionConnected(WebSocketSession session)
		{
			Console.WriteLine("NewSessionConnected");
			if (!session.Origin.IsNullOrEmpty())
			{
				connectingSessions.Add(session);
			}
		}

		private bool CheckBrowserConnection()
        {
			bool rt = true;

			connectingSessions.RemoveAll(x => !x.Connected);
			if (connectingSessions.Count <= 0)
			{
				rt = false;
			}

			return rt;
		}

		private void SendToWebClient(WebSocketSession webSocketSession, string strMessage, string topic)
		{
			if (webSocketSession != null && webSocketSession.Connected)
			{
				strMessage = BuildTopic(strMessage, topic);
				webSocketSession.Send(strMessage);
				string strlog = String.Format("送信成功：{0}", topic);
				this.SendMessageToGUI("接続中", DateTime.Now, strlog);
			}
			else
            {
				if(!CheckBrowserConnection())
                {
					LogInfo("NO WEB CLIENT CONNECTED", INFO);
					this.SendMessageToGUI("未接続", DateTime.Now, "送信失敗：ブラウザのウエブが存在しない");
				}
			}
		}

		private void SendToAllWebClient(string strMessage, string topic)
		{
			bool sentFlag = false;
			foreach(WebSocketSession webSocketSession in connectingSessions)
            {
				if (webSocketSession.Connected)
				{
					strMessage = BuildTopic(strMessage, topic);
					webSocketSession.Send(strMessage);
					string strlog = String.Format("送信成功：{0}", topic);
					this.SendMessageToGUI("接続中", DateTime.Now, strlog);
					sentFlag = true;
				}
			}
			
			if(!sentFlag && !CheckBrowserConnection())
			{
				LogInfo("NO WEB CLIENT CONNECTED", INFO);
				this.SendMessageToGUI("未接続", DateTime.Now, "送信失敗：ブラウザのウエブが存在しない");
			}
		}

		private String BuildTopic(string strMessage, string topic)
		{
			return String.Format("{0}\t{1}\t{2}\t{3}", CARD_CLIENT, topic, strMessage, NKKFalica.card_idm); ;
		}

		private void LogInfo(string strMesssage, int type)
		{
			NKKLogging log = NKKLogging.GetInstance();
			switch (type)
			{
				case INFO:
					log.AddLogInfo(DateTime.Now, "NKKWebAppSocket", NKKLogging.LOGGING_CLASS.INFO, strMesssage);
					break;
				case ERROR:
					log.AddLogInfo(DateTime.Now, "NKKWebAppSocket", NKKLogging.LOGGING_CLASS.ERROR, strMesssage);
					break;
			}

		}

		private Boolean WriteStaffCard(string strMessage)
		{
			string[] strSplit = strMessage.Split(new char[] { '-' }, StringSplitOptions.None);
			string facilityCd = strSplit[0];
			string patCd = strSplit[1];
			string strUri = String.Format("{0}{1}{2}{3}/{4}?_={5}"
					   , NKKWebAccess.BaseUri
					   , NKKAccessCardInfo.WEB_APP_URI
					   , GET_STAFF_INFO_URI
					   , facilityCd
					   , patCd
					   , DateTime.Now.Ticks);		
			NKKWebAccessResponse res = NKKWebAccess.Get("体重計接続状態取得", strUri).Result;

			if (res.response.IsSuccessStatusCode == true)
			{
				String strstate = res.strContent;
				
				string strUri_setCard = String.Format("{0}{1}{2}/{3}?_={4}"
					   , NKKWebAccess.BaseUri
					   , NKKAccessCardInfo.WEB_APP_URI
					   , SET_STAFF_CARD_NO_URI
					   , patCd
					   , DateTime.Now.Ticks);
				NKKWebAccessResponse res_set_card = NKKWebAccess.Post("体重計接続状態取得", strUri_setCard, NKKFalica.card_idm).Result;
				if(res_set_card.response.IsSuccessStatusCode == false || res_set_card.strContent.Equals("false"))
				// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 start
				{
					LogInfo("--->WriteCard NG：" + strUri_setCard + " NG. patCd=[" + patCd + "] ", ERROR);
					return false;
				}
				// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 end

				if (String.IsNullOrEmpty(strstate) == false)
				{
					// 処理成功

					// ログ記録：状態値
					// this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("体重計状態値:{0}", strstate));

					int nret = 0;

					// JSON分解
					Dictionary<String, String> json = NKKWebAccess.GetJsonData(strstate);

					// カード書き込み内容
					if (json.ContainsKey("cardWriteValue") == true)
					{
						String carddata = json["cardWriteValue"];

						// JSON分解
						json = NKKWebAccess.GetJsonData(carddata);

						// カード書き込み内容
						if (json.ContainsKey("cardCd") == true)
						{
							// カード書き込み内容取得
							String strdata = "**" + json["cardCd"];
							
							// Add By HandsomeLin Begin
							// Write fullname to the seconds block, using 40 bytes.
							var firstnameText = string.Empty;
							if (json.ContainsKey("firstname"))
							{
								var data = Convert.FromBase64String(json["firstname"]);
								var decodedString = Encoding.UTF8.GetString(data);
								firstnameText = decodedString;
							}
							var lastnameText = string.Empty;
							if (json.ContainsKey("lastname"))
							{
								var data = Convert.FromBase64String(json["lastname"]);
								var decodedString = Encoding.UTF8.GetString(data);
								lastnameText = decodedString;
							}

							var fullnameText = firstnameText + lastnameText;
							// Add By HandsomeLin End

							// カード書き込み
							// Update By HandsomeLin Begin
							// Write fullname to the seconds block, using 40 bytes.
							if (NKKFalica.WriteStaffCard(strdata, fullnameText))
							// Update By HandsomeLin End
							{
								// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 start
								LogInfo("--->WriteCard：カード書き込み成功。", INFO);
								// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 end
								// 書き込み成功
								return true;
							}
						}
						else
						{
							// カード書き込み内容(id)なし

							// ログ記録：カード書き込み情報(id)なし
							//strlog = "カード書き込み情報(id)なし";
							//this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, strlog);

							// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 start
							LogInfo("--->WriteCard NG：json[" + JsonConvert.SerializeObject(json) + "]にkey[cardCd]が無し。 ", ERROR);
							// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 end
						}
					}
					// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 start
					else
					{
						LogInfo("--->WriteCard NG：json[" + JsonConvert.SerializeObject(json) + "]にkey[cardWriteValue]が無し。 ", ERROR);
					}
					// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 end
				}
				// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 start
				else
				{
					LogInfo("--->WriteCard NG：[" + strUri_setCard + "]より、データが無し。 ", ERROR);
				}
				// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 end
			}
			// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 start
			else
            {
				LogInfo("--->WriteCard NG：" + strUri  + " [" + res.response.StatusCode.ToString() + "] " + res.response.RequestMessage.ToString(), ERROR);
			}
			// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 end

			return false;
		}

		private Boolean WritePatCard(string strMessage)
		{
			bool result = true;
			string[] strSplit = strMessage.Split(new char[] { '-' }, StringSplitOptions.None);
			string facilityCd = strSplit[0];
			string patCd = strSplit[1];
			string strUri = String.Format("{0}{1}{2}{3}/{4}?_={5}"
					   , NKKWebAccess.BaseUri
					   , NKKAccessCardInfo.WEB_APP_URI
					   , GET_PAT_INFO_URI
					   , facilityCd
					   , patCd
					   , DateTime.Now.Ticks);
			
			DateTime begin = DateTime.Now;
			NKKWebAccessResponse res = NKKWebAccess.Get("体重計接続状態取得", strUri).Result;
			LogInfo("=====> GET_PAT_INFO_URI: " + (DateTime.Now - begin).TotalMilliseconds, INFO);
			if (res.response.IsSuccessStatusCode)
			{
				String strstate = res.strContent;

                // add 2020-08-13 FNSI-仕様追加 患者基本情報(pat_main)にアクセスカード番号(card_idm)の追加処理 夏 start
                string strPat_setCard = String.Format("{0}{1}{2}/{3}?_={4}"
                       , NKKWebAccess.BaseUri
                       , NKKAccessCardInfo.WEB_APP_URI
                       , SET_PATIENT_CARD_NO_URI
                       , patCd
                       , DateTime.Now.Ticks);
                
                begin = DateTime.Now;
                NKKWebAccessResponse res_set_card = NKKWebAccess.Post("体重計接続状態取得", strPat_setCard, NKKFalica.card_idm).Result;
                LogInfo("=====> SET_PATIENT_CARD_NO_URI: " + (DateTime.Now - begin).TotalMilliseconds, INFO);
                
                if (res_set_card.response.IsSuccessStatusCode == false || res_set_card.strContent.Equals("false"))
                // add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 start
                {
					LogInfo("--->WriteCard NG：" + strPat_setCard + " NG. patCd=[" + patCd  + "] ", ERROR);
					return false;
				}
				// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 end
				// add 2020-08-13 FNSI-仕様追加 患者基本情報(pat_main)にアクセスカード番号(card_idm)の追加処理 夏 end

				if (String.IsNullOrEmpty(strstate) == false)
				{
					// 処理成功
					var newWriter = new NewPatientCardWriter();
					var serviceData = newWriter.ConvertAllServiceData(_cardConfiguration.Metadata, strstate);

					List<string> lstStrError = null;
					if(NKKFalica.WritePatCard(serviceData, out lstStrError) == false)
                    {
						foreach(string strError in lstStrError)
                        {
							LogInfo(strError, INFO);
						}

						result = false;
					}

					if (result)
					{
						LogInfo("--->WriteCard OK", INFO);
					}
				}
				else
				{
					// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 start
					LogInfo("--->WriteCard NG：[" + strPat_setCard + "]より、データが無し。 ", ERROR);
					// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 end
					result = false;
				}

			}
			else
			{
				// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 start
				LogInfo("--->WriteCard NG：" + strUri + " [" + res.response.StatusCode.ToString() + "] " + res.response.RequestMessage.ToString(), ERROR);
				// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 end
				result = false;
			}
			return result;
		}

		// add redmai #4820 「患者カードを作成しても透析装置でデータ異常と表示される」を修正する。 鄧シン start
		private byte[] ShortToByte(short data)
		{
			return new byte[]
			{
				(byte)(data >> 8),
				(byte)data
			};
		}
		private byte[] MakeByteArray(List<byte[]> byteList)
		{
			byte[] array = new byte[0];
			if (byteList.Count > 2)
			{
				array = byteList[0].Concat(byteList[1]).ToArray<byte>();
				for (int i = 2; i < byteList.Count; i++)
				{
					array = array.Concat(byteList[i]).ToArray<byte>();
				}
			}
			return array;
		}
		private byte[] GetByteData(DateTime Birthday)
		{
			List<byte[]> list = new List<byte[]>();
			byte[] result;
			short data;
			short.TryParse(Birthday.ToString("yyyy"), out data);
			list.Add(ShortToByte(data));
			short.TryParse(Birthday.ToString("MMdd"), out data);
			list.Add(ShortToByte(data));
			list.Add(new byte[4]);
			result = MakeByteArray(list);

			return result;
		}
		// add redmai #4820 「患者カードを作成しても透析装置でデータ異常と表示される」を修正する。 鄧シン end

		private void GetCardDeviceStatus(WebSocketSession webSocketSession)
		{
			// mod FNSI-4200ポートを使用している 孫 start
			//SendToWebClient(NKKFalica.cardDeviceStatus.ToString(), "CARD_READER_STATUS");
			SendToWebClient(webSocketSession, String.Format("{0}\t{1}", NKKFalica.cardDeviceStatus.ToString(), NKKWebAppSocketConfig.WS_PORT.ToString()), "CARD_READER_STATUS");
			// mod FNSI-4200ポートを使用している 孫 end
		}

		// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 start
		private static string SetDecimalNumber(string s, string name)
		{
			if (dictDecimalNumber.ContainsKey(name))
			{
				int keepDecimalLength = dictDecimalNumber[name];
				if (string.IsNullOrEmpty(s))
                {
					if (keepDecimalLength > 0)
                    {
						string value = "0";
						value = value.PadRight(value.Length + keepDecimalLength, '0');
						return value;
					}
					else
                    {
						return s;
                    }
                }
				else
                {
					string[] str = s.Split('.');
					string para1 = str[0];
					string para2 = "";
					if (s.IndexOf('.') > 0)
                    {
						para2 = str[1];
					}

					if (keepDecimalLength > 0)
					{
						para2 = para2.PadRight(para2.Length + keepDecimalLength, '0');
						if (string.IsNullOrEmpty(para1))
						{
							para1 = "0";
						}
						string value = para1 + para2.Substring(0, keepDecimalLength);
						return value;
					}
					else
					{
						return para1;
					}
				}
			}
			else
            {
				return s;
            }
		}

		private static Int32 Int32_Parse(string s, string name)
        {
			try
            {
				return Int32.Parse(SetDecimalNumber(s, name));
			}
			catch (Exception e)
            {
				NKKLogging log = NKKLogging.GetInstance();
				string strMesssage = "--->WriteCard：Int32.Parse error. name[" + name + "] value[" + s + "]";
				log.AddLogInfo(DateTime.Now, "NKKWebAppSocket", NKKLogging.LOGGING_CLASS.INFO, strMesssage);
				throw e;
            }
        }

		private static Int64 long_Parse(string s, string name)
		{
			try
			{
				return long.Parse(SetDecimalNumber(s, name));
			}
			catch (Exception e)
			{
				NKKLogging log = NKKLogging.GetInstance();
				string strMesssage = "--->WriteCard：long.Parse error. name[" + name + "] value[" + s + "]";
				log.AddLogInfo(DateTime.Now, "NKKWebAppSocket", NKKLogging.LOGGING_CLASS.INFO, strMesssage);
				throw e;
			}
		}

		private static bool ushort_Parse(string s, out ushort result, string name)
		{
			try
			{
				return ushort.TryParse(SetDecimalNumber(s, name), out result);
			}
			catch (Exception e)
			{
				NKKLogging log = NKKLogging.GetInstance();
				string strMesssage = "--->WriteCard：ushort.Parse error. name[" + name + "] value[" + s + "]";
				log.AddLogInfo(DateTime.Now, "NKKWebAppSocket", NKKLogging.LOGGING_CLASS.INFO, strMesssage);
				throw e;
			}			
		}

		private static bool ulong_TryParse(string s, out ulong result, string name)
		{
			try
			{
				return ulong.TryParse(SetDecimalNumber(s, name), out result);
			}
			catch (Exception e)
			{
				NKKLogging log = NKKLogging.GetInstance();
				string strMesssage = "--->WriteCard：ulong.Parse error. name[" + name + "] value[" + s + "]";
				log.AddLogInfo(DateTime.Now, "NKKWebAppSocket", NKKLogging.LOGGING_CLASS.INFO, strMesssage);
				throw e;
			}
		}
		// add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 end
	}
}
