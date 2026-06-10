///////////////////////////////////////////////////////////////////////////////
//
// システム名 ：FutureNetⅢ
// 機能名     ：FN3システム TCP/IPソケット通信 クライアント接続用ワーカースレッドクラス
// ファイル名 ：ConnectWorkerThread.cs
// 説明       ：
//
//	Copyright(C) 2008 NIKKISO CO., LTD. All Rights Reserved.
//
// 更新履歴
//	日付		担当				理由
//	2008/06/17	中村 竜也			新規作成（スタブ）
//
///////////////////////////////////////////////////////////////////////////////
using System;
using System.Net;
using System.Net.Sockets;
using System.Threading;

namespace NKK.FN3.Common.Library.TcpSocket
{
	/// <summary>
	/// ソケットクライアント接続処理用のワーカースレッドクラス
	/// </summary>
	class ConnectWorkerThread
	{
		/// <summary>
		/// 接続処理状態
		/// </summary>
		public enum CONNECTMODE
		{
			IDLE = 0,			//アイドル状態
			CONNECTING = 1,		//接続処理中
			CONNECTED = 2,		//接続完了
			ERROR = 3,			//接続処理エラー
			INNERPROCS = 4		//接続完了後の内部処理中
		}

		private CONNECTMODE m_connectMode = CONNECTMODE.IDLE;
		private TcpClient m_client = null;
		private DeviceInformation m_devInf = null;

		private const int CONNECT_CYCLE = 100;

		private Thread m_thread = null;

		#region プロパティ
		/// <summary>
		/// 接続処理状態取得
		/// </summary>
		public CONNECTMODE ConnectMode
		{
			get { return m_connectMode; }
		}

		/// <summary>
		/// ソケットオブジェクト取得
		/// </summary>
		public TcpClient ClientSocket
		{
			get 
			{ 
				TcpClient ret = null;
				if (m_connectMode == CONNECTMODE.CONNECTED)
				{
					ret = m_client;
					m_connectMode = CONNECTMODE.INNERPROCS;
				}
				return ret;
			}
		}
		#endregion

		#region publicメソッド
		public ConnectWorkerThread(DeviceInformation di)
		{
			m_devInf = di;
			m_connectMode = CONNECTMODE.IDLE;
			m_thread = new Thread(new ThreadStart(WorkerThread));
			m_thread.Start();
		}

		public void End()
		{
			if (m_thread != null)
			{
				m_thread.Abort();
				m_thread = null;
			}
		}
		#endregion

		#region privateメソッド
		private void WorkerThread()
		{
			while (m_client == null)
			{
				try
				{
					TcpClient client = new TcpClient();
					client.Connect(m_devInf.IpAddress, m_devInf.PortNo);
					Socket sock = client.Client;
					System.Net.IPEndPoint endPoint = sock.RemoteEndPoint as IPEndPoint;
					int portNo = endPoint.Port;

					//ＭＡＣアドレス取得
					string macAdr = BaseConnect.GetMacAddress(endPoint.Address);

					//接続先情報とリモートポイントのＭＡＣアドレスを比較
					if (macAdr.Equals(m_devInf.MacAddress))
					{
						m_client = client;
						m_connectMode = CONNECTMODE.CONNECTED;
					}
					else
					{
						// ADD S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
						m_client = client;
						m_connectMode = CONNECTMODE.CONNECTED;
						// ADD S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
						Console.WriteLine("MACアドレスエラー IP[{0}]:Port[{1}]", m_devInf.IpAddress, m_devInf.PortNo);
						// DEL S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
						//m_connectMode = CONNECTMODE.ERROR;
						//break;
						// DEL S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
					}
				}
				catch (SocketException se)
				{
					// ADD S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
					Console.WriteLine("接続エラー IP[{0}]:Port[{1}] Msg = {2}", m_devInf.IpAddress, m_devInf.PortNo, se.Message);
					m_connectMode = CONNECTMODE.ERROR;
					break;
					// ADD S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
				}
				catch (Exception ee)
				{
					Console.WriteLine("接続エラー IP[{0}]:Port[{1}] Msg = {2}", m_devInf.IpAddress, m_devInf.PortNo, ee.Message);
					m_connectMode = CONNECTMODE.ERROR;
					break;
				}

				Thread.Sleep(100);
			}
		}
		#endregion
	}
}
