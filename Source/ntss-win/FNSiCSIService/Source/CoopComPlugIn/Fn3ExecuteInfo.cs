using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;

namespace jp.co.nikkiso.fn3.Cooperation.CoopComPlugIn
{
	/// <summary>
	/// 実行情報を内包したクラス
	/// </summary>
	public class Fn3ExecuteInfo
	{
		private XmlDocument m_xmlCoopInfo;
		private XmlNode m_xmlSendHist;
		private XmlNode m_xmlEventMng;

		#region "プロパティ"

		#region "連携情報"

		/// <summary>
		/// 連携情報XMLを取得します。
		/// </summary>
		public XmlNode CoopInfoXML
		{
			get { return this.m_xmlCoopInfo; }
		}

		#endregion

		#region "送信履歴情報"

		/// <summary>
		/// 送信履歴情報の送信区分を取得する。
		/// </summary>
		public string SendClass
		{
			get
			{
				XmlElement element = this.m_xmlSendHist["SEND_CLASS"];
				if(element == null) return "0";
				return element.InnerText;
			}
		}

		/// <summary>
		/// 送信履歴情報の送信ステータスを取得する。
		/// </summary>
		public string SendState
		{
			get
			{
				XmlElement element = this.m_xmlSendHist["SEND_STATE"];
				if(element == null) return "0";
				return element.InnerText;
			}
		}

		/// <summary>
		/// 送信履歴情報の送信版数を取得する。
		/// </summary>
		public int SendVersion
		{
			get
			{
				XmlElement element = this.m_xmlSendHist["SEND_VERSION"];
				if(element == null) return 1;
				return int.Parse(element.InnerText);
			}
		}

		/// <summary>
		/// 送信履歴情報のメモを取得する。
		/// </summary>
		public string SendHistMemo
		{
			get
			{
				XmlElement element = this.m_xmlSendHist["MEMO"];
				if(element == null) return "";
				return element.InnerText;
			}
		}

		/// <summary>
		/// 送信履歴テーブルの予備を取得します。
		/// </summary>
		public string SendHistReserve
		{
			get
			{
				XmlElement element = this.m_xmlSendHist["RESERVE"];
				if(element == null) return "";
				return element.InnerText;
			}
		}

		#endregion

		#region "イベント管理情報"

		/// <summary>
		/// イベント管理テーブルの連携IDを取得します。
		/// </summary>
		public string CoopID
		{
			get { return this.m_xmlEventMng["COOP_ID"].InnerText; }
		}

        /// <summary>
        /// イベント管理テーブルのイベントグループ番号を取得します。
        /// </summary>
        public string EventGroupNo
        {
            get { return this.m_xmlEventMng["EVENT_GROUP_NO"].InnerText; }
        }

		/// <summary>
		/// イベント管理テーブルの特定キーを取得します。
		/// </summary>
		public string SpecificKey
		{
			get { return this.m_xmlEventMng["SPECIFIC_KEY"].InnerText; }
		}

		/// <summary>
		/// イベント管理テーブルの連番を取得します。
		/// </summary>
		public decimal SeqNumber
		{
			get { return decimal.Parse(this.m_xmlEventMng["EVENT_SEQ_NUMBER"].InnerText); }
		}

		/// <summary>
		/// イベント管理テーブルの発生日時を取得します。
		/// </summary>
		public DateTime OccurDate
		{
			get { return DateTime.Parse(this.m_xmlEventMng["EVENT_OCCUR_DATE"].InnerText); }
		}

		/// <summary>
		/// イベント管理テーブルのイベント区分を取得します。
		/// </summary>
		public string EventType
		{
			get { return this.m_xmlEventMng["EVENT_CLASS"].InnerText; }
		}

		/// <summary>
		/// イベント管理テーブルの処理フラグを取得します。
		/// </summary>
		public string ProcFlag
		{
			get { return this.m_xmlEventMng["PROC_FLG"].InnerText; }
		}

		/// <summary>
		/// イベント管理テーブルのオーダー番号を取得します。
		/// </summary>
		public string OrderNumber
		{
			get { return this.m_xmlEventMng["ORDER_NUMBER"].InnerText; }
		}

		/// <summary>
		/// イベント管理テーブルの連携機能名を取得します。
		/// </summary>
		public string FunctionName
		{
			get { return this.m_xmlEventMng["COOP_FUNCTION_NAME"].InnerText; }
		}

		/// <summary>
		/// イベント管理テーブルのキー情報を取得します。
		/// </summary>
		public string KeyInfo
		{
			// CSI製電子カルテ（MIRAIS)についての対応 ADD 2021.03.09 START
			//get { return this.m_xmlEventMng["KEY_INFO"].InnerText; }
			get { return this.m_xmlEventMng["KEY_INFO"].InnerXml; }
			// CSI製電子カルテ（MIRAIS)についての対応 ADD 2021.03.09 END
		}

		/// <summary>
		/// イベント管理テーブルのコメントを取得します。
		/// </summary>
		public string EvtMngMemo
		{
			get { return this.m_xmlEventMng["MEMO"].InnerText; }
		}

		/// <summary>
		/// イベント管理テーブルの予備を取得します。
		/// </summary>
		public string EvtMngReserve
		{
			get { return this.m_xmlEventMng["RESERVE"].InnerText; }
		}

        // 系列施設複数連携(受入NG)対応 大星憲士 2013/06/25
        // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
        // TODO:NG20130626
        /// <summary>
        /// 系列施設コードを取得します。
        /// </summary>
        public string SeriesCD
        {
            get 
            {
                XmlNode node = this.m_xmlEventMng["SERIES_CD"];
                string seriesCode = string.Empty;
                if (node != null)
                {
                    seriesCode = node.InnerText;
                }
                return seriesCode; 
            }
        }
        // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07

		#endregion

		#endregion

		#region "コンストラクタ"

		/// <summary>
		/// Fn3ExecuteInfoクラスの新しいインスタンスを初期化します。
		/// </summary>
		public Fn3ExecuteInfo()
		{
			this.m_xmlCoopInfo = null;
			this.m_xmlSendHist = null;
			this.m_xmlEventMng = null;
		}

		/// <summary>
		/// 連携情報Xmlを設定します。
		/// </summary>
		/// <param name="strCoopInfoXml">連携情報Xml</param>
		/// <returns>リターンコード</returns>
		public Fn3ReturnCode SetCoopInfoXml(string strCoopInfoXml)
		{
			try
			{
				this.m_xmlCoopInfo = new XmlDocument();
				this.m_xmlCoopInfo.LoadXml(strCoopInfoXml);
				return Fn3ComPlugInReturnCode.Success;
			}
			catch
			{
				return Fn3ComPlugInReturnCode.WrongCoopInfoXml;
			}
		}

		/// <summary>
		/// 送信履歴情報Xmlを設定します。
		/// </summary>
		/// <param name="strSendHistXml">送信履歴情報Xml</param>
		/// <returns>リターンコード</returns>
		public Fn3ReturnCode SetSendHistXml(string strSendHistXml)
		{
			try
			{
				XmlDocument xmlSendHistRoot = new XmlDocument();
				xmlSendHistRoot.LoadXml(strSendHistXml);
				this.m_xmlSendHist = xmlSendHistRoot.SelectSingleNode("rootNode/COP_COOP_SEND_HST");
				return Fn3ComPlugInReturnCode.Success;
			}
			catch
			{
				return Fn3ComPlugInReturnCode.WrongSendHistXml;
			}
		}

		/// <summary>
		/// イベント管理情報Xmlを設定します。
		/// </summary>
		/// <param name="strEventManagerXml">イベント管理情報Xml</param>
		/// <returns>リターンコード</returns>
		public Fn3ReturnCode SetEventManagerXml(string strEventManagerXml)
		{
			try
			{
				XmlDocument xmlEventMngRoot = new XmlDocument();
				xmlEventMngRoot.LoadXml(strEventManagerXml);
				this.m_xmlEventMng = xmlEventMngRoot.SelectSingleNode("COP_EVENT_MANAGE");
				return Fn3ComPlugInReturnCode.Success;
			}
			catch
			{
				return Fn3ComPlugInReturnCode.WrongEventManagerXml;
			}
		}

		#endregion
	}
}
