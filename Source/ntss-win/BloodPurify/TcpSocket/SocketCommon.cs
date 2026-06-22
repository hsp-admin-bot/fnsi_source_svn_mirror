///////////////////////////////////////////////////////////////////////////////
//
// システム名 ：FutureNetⅢ
// 機能名     ：FN3システム TCP/IPソケット通信用共通クラス定義
// ファイル名 ：SocketCommon.cs
// 説明       ：ソケット通信で使用する共通クラスを定義する。
//
//	Copyright(C) 2008 NIKKISO CO., LTD. All Rights Reserved.
//
// 更新履歴
//	日付		担当				理由
//	2008/04/17	中村 竜也			新規作成（スタブ）
//
///////////////////////////////////////////////////////////////////////////////

namespace NKK.FN3.Common.Library.TcpSocket
{
	/// <summary>
	/// 例外イベント用デリゲート定義
	/// </summary>
	/// <remarks>
	/// 例外発生時に呼び出されるハンドラを登録する為のデリゲートである。
	/// </remarks>
	public delegate void dgtOnException_Mng(BaseSocket sender, System.Exception e);

	/// <summary>
	/// 受信データ格納用クラス
	/// </summary>
	/// <remarks>
	/// 本クラスに受信データとその受信したデータのサイズを格納する。
	/// ソケットでのデータ受信時には本クラスに受信データが格納され管理される。
	/// </remarks>
	public class ReceiveStream
	{
		/// <summary>
		/// 受信データを格納する。
		/// </summary>
		/// <remarks>
		/// この領域のサイズと受信データサイズはイコールではない事に注意する。
		/// </remarks>
		public byte[] rcvData;
		/// <summary>
		/// 受信したデータのサイズを格納する。
		/// </summary>
		public int rcvSize;
	}

	/// <summary>
	/// 接続先装置情報格納用クラス
	/// </summary>
	/// <remarks>
	/// 接続先の装置情報を格納するためのクラスである。
	/// </remarks>
	public class DeviceInformation
	{
		/// <summary>
		/// 接続先のＩＰアドレス
		/// </summary>
		private string _ipAddress = string.Empty;
		/// <summary>
		/// 接続先のポート番号
		/// </summary>
		private int _portNo = -1;
		/// <summary>
		/// 接続先装置のＭＡＣアドレス
		/// </summary>
		private string _macAddress = string.Empty;
		/// <summary>
		/// 接続先装置の装置ＩＤ
		/// </summary>
		private string _deviceId = string.Empty;

		private string _devInfoStr = string.Empty;

		#region プロパティ
		/// <summary>
		/// ＩＰアドレスを取得する。
		/// </summary>
		public string IpAddress
		{
			get
			{
				return _ipAddress;
			}
		}

		/// <summary>
		/// ポート番号を取得する。
		/// </summary>
		public int PortNo
		{
			get
			{
				return _portNo;
			}
		}

		/// <summary>
		/// ＭＡＣアドレスを取得する。
		/// </summary>
		public string MacAddress
		{
			get
			{
				return _macAddress;
			}
		}

		/// <summary>
		/// 装置ＩＤを取得する。
		/// </summary>
		public string DeviceId
		{
			get
			{
				return _deviceId;
			}
		}

		/// <summary>
		/// 装置情報文字列取得
		/// </summary>
		public string DevInfoStr
		{
			get { return _devInfoStr; }
		}
		#endregion

		/// <summary>
		/// コンストラクタ
		/// </summary>
		/// <param name="ipAdr">ＩＰアドレス</param>
		/// <param name="portNo">ポート番号</param>
		/// <param name="devId">装置ＩＤ</param>
		/// <param name="macAdr">ＭＡＣアドレス</param>
		public DeviceInformation(string ipAdr, int portNo, string macAdr, string devId)
		{
			_ipAddress = ipAdr;
			_portNo = portNo;
			_deviceId = devId;
			_macAddress = macAdr;

			_devInfoStr = string.Format("IP = {0}, Port = {1}, MAC = {2}", _ipAddress, _portNo, _macAddress);
		}

		/// <summary>
		/// DeviceInformationオブジェクトの比較を行います。
		/// </summary>
		public override bool Equals(object obj)
		{
			bool ret = false;

			DeviceInformation targetDi = obj as DeviceInformation;
			if (targetDi != null)
			{
				if (this._ipAddress.Equals(targetDi._ipAddress))
				{
					if (this._portNo.Equals(targetDi._portNo))
					{
						if (this._macAddress.Equals(targetDi._macAddress))
						{
							ret = true;
						}
					}
				}
			}

			return ret;
			//return base.Equals(obj);
		}

		/// <summary>
		/// ハッシュコードを返す
		/// </summary>
		/// <returns></returns>
		public override int GetHashCode()
		{
			return base.GetHashCode();
		}
	}
}
