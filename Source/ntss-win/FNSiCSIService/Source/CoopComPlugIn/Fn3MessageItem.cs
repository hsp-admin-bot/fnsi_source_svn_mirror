///////////////////////////////////////////////////////////////////////////////
//
// システム名：FutureNetⅢ
// 機能名    ：メッセージ管理機能
// ファイル名：Fn3MessageItem.cs
// 説明      ：電文の管理を行う。
//
//	Copyright(C) 2009 NIKKISO CO., LTD. All Rights Reserved 
//
// 更新履歴
//	日付		担当				理由
//	2009/08/10	根津知則			新規作成
//
///////////////////////////////////////////////////////////////////////////////

using System;
using System.Collections.Generic;
using System.Text;

namespace jp.co.nikkiso.fn3.Cooperation.CoopComPlugIn
{
	/// <summary>
	/// メッセージ項目管理クラス
	/// </summary>
	public class Fn3MessageItem : Fn3MessageNode
	{
		#region "メンバ変数"

		private int m_intSize;
		private byte[] m_bytvalue;
		private string m_strSizeCounter;
		private MessageNodeType m_type;

		#endregion

		#region "プロパティ"

		/// <summary>
		/// 項目種別を取得します。
		/// </summary>
		public MessageNodeType Type
		{
			get { return this.m_type; }
		}

		/// <summary>
		/// 項目サイズを取得します。
		/// </summary>
		public override int Size
		{
			get
			{
				if(this.m_strSizeCounter.Equals("") || this.Parent == null)
				{
					return this.m_intSize;
				}
				else
				{
					int size = 0;
					Fn3MessageItem counterItem = this.GetParentItem(this.Parent, this.m_strSizeCounter);
					if(counterItem == null) return this.m_intSize;

					if(counterItem.Type == MessageNodeType.String)
					{
						if(int.TryParse(this.ParentMessage.Encoding.GetString(counterItem.GetByteValue()), out size) == true)
						{
							return size;
						}
						else
						{
							return this.m_intSize;
						}
					}
					else
					{
						byte[] bytes = new byte[4];
						bytes.Initialize();
						Array.Copy(counterItem.GetByteValue(), bytes, (counterItem.Size > 4 ? 4 : counterItem.Size));

						size = BitConverter.ToInt32(bytes, 0);
						return size;
					}
				}
			}
		}

		#endregion

		#region "コンストラクタ"

		/// <summary>
		/// Fn3MessageItemクラスの新しいインスタンスを初期化します。
		/// </summary>
		/// <param name="ifMessage">関連するメッセージクラス</param>
		/// <param name="strName">項目名称</param>
		/// <param name="intSize">サイズ</param>
		public Fn3MessageItem(IFn3Message ifMessage, string strName, int intSize)
			: this(ifMessage, strName, intSize, MessageNodeType.String, "")
		{

		}

		/// <summary>
		/// Fn3MessageItemクラスの新しいインスタンスを初期化します。
		/// </summary>
		/// <param name="ifMessage">関連するメッセージクラス</param>
		/// <param name="strName">項目名称</param>
		/// <param name="intSize">サイズ</param>
		/// <param name="msgNodeType">項目種別</param>
		public Fn3MessageItem(IFn3Message ifMessage, string strName, int intSize, MessageNodeType msgNodeType)
			: this(ifMessage, strName, intSize, msgNodeType, "")
		{
		}

		/// <summary>
		/// Fn3MessageItemクラスの新しいインスタンスを初期化します。
		/// </summary>
		/// <param name="ifMessage">関連するメッセージクラス</param>
		/// <param name="strName">項目名称</param>
		/// <param name="intSize">サイズ</param>
		/// <param name="msgNodeType">項目種別</param>
		/// <param name="strSizeCounter">サイズカウンター名称</param>
		public Fn3MessageItem(IFn3Message ifMessage, string strName, int intSize, MessageNodeType msgNodeType, string strSizeCounter)
			: base(ifMessage, strName)
		{
			this.m_intSize = intSize;
			this.m_bytvalue = new byte[this.m_intSize];
			this.m_type = msgNodeType;
			this.m_strSizeCounter = strSizeCounter;
		}

		#endregion

		#region "メソッド"

		/// <summary>
		/// このメッセージ項目にバイナリデータを設定します。
		/// </summary>
		/// <param name="bytValue">バイナリデータ</param>
		/// <returns>項目に設定されたバイト数。</returns>
		public override int SetByteValue(byte[] bytValue)
		{
			int copyBytes = 0;

			bytValue.Initialize();
			copyBytes = (bytValue.Length < this.m_intSize ? bytValue.Length : this.m_intSize);
			Array.ConstrainedCopy(bytValue, 0, m_bytvalue, 0, copyBytes);

			return copyBytes;
		}

		/// <summary>
		/// このメッセージ項目に設定されているバイナリデータを取得します。
		/// </summary>
		/// <returns>バイナリデータ</returns>
		public override byte[] GetByteValue()
		{
			return this.m_bytvalue;
		}

		#endregion
	}
}
