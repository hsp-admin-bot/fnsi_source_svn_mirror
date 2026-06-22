///////////////////////////////////////////////////////////////////////////////
//
// システム名：FutureNetⅢ
// 機能名    ：メッセージ管理機能
// ファイル名：Fn3MessageLoopManager.cs
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
	/// メッセージ繰返し項目管理クラス
	/// </summary>
	public class Fn3MessageLoopManager : Fn3MessageGroup
	{
		#region "メンバ変数"

		private int m_intLoopCount;
		private string m_strLoopCounterName;

		#endregion

		#region "プロパティ"

		/// <summary>
		/// サイズを取得する
		/// </summary>
		public override int Size
		{
			get
			{
				int count = this.Count;
				int size = 0;

				for(int i = 0; i < count; i++)
				{
					size += this[i].Size;
				}

				return size;
			}
		}

		/// <summary>
		/// 繰返し回数を取得する
		/// </summary>
		public override int Count
		{
			get
			{
				if(m_strLoopCounterName == "" || this.Parent == null)
				{
					return this.m_intLoopCount;
				}
				else
				{
					int count = 0;
					Fn3MessageItem item = this.GetParentItem(this.Parent, this.m_strLoopCounterName);
					if(item == null) return this.m_intLoopCount;

					if(item.Type == MessageNodeType.String)
					{
						if(int.TryParse(this.ParentMessage.Encoding.GetString(item.GetByteValue()), out count) == true)
						{
							return count;
						}
						else
						{
							return this.m_intLoopCount;
						}
					}
					else
					{
						byte[] bytes = new byte[4];
						bytes.Initialize();
						Array.Copy(item.GetByteValue(), bytes, (item.Size > 4 ? 4 : item.Size));

						count = BitConverter.ToInt32(bytes, 0);
						return count;
					}
				}
			}
		}

		/// <summary>
		/// ループカウンタを取得または設定します。
		/// </summary>
		/// <remarks>
		/// コンストラクタで設定したループ回数よりも小さな値を設定してください。
		/// </remarks>
		public int LoopCount
		{
			get { return this.m_intLoopCount; }
			set { this.m_intLoopCount = value; }
		}

		/// <summary>
		/// ループカウンター名を取得する。
		/// </summary>
		public string LoopCounter
		{
			get { return this.m_strLoopCounterName; }
		}

		#endregion

		#region "コンストラクタ"

		/// <summary>
		/// Fn3MessageLoopManagerクラスの新しいインスタンスを初期化します。
		/// </summary>
		/// <param name="ifMessage">関連するメッセージ</param>
		/// <param name="strName">項目名</param>
		/// <param name="intLoopCount">ループ回数</param>
		public Fn3MessageLoopManager(IFn3Message ifMessage, string strName, int intLoopCount)
			: this(ifMessage, strName, intLoopCount, "")
		{
		}

		/// <summary>
		/// Fn3MessageLoopManagerクラスの新しいインスタンスを初期化します。
		/// </summary>
		/// <param name="ifMessage">関連するメッセージ</param>
		/// <param name="strName">項目名</param>
		/// <param name="intLoopCount">ループ回数</param>
		/// <param name="strLoopCounterName">ループカウンター名称</param>
		public Fn3MessageLoopManager(IFn3Message ifMessage, string strName, int intLoopCount, string strLoopCounterName)
			: base(ifMessage, strName)
		{
			this.m_intLoopCount = intLoopCount;
			this.m_strLoopCounterName = strLoopCounterName;
		}

		#endregion
	}
}
