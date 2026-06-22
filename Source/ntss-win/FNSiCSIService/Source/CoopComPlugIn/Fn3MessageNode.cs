///////////////////////////////////////////////////////////////////////////////
//
// システム名：FutureNetⅢ
// 機能名    ：メッセージ管理機能
// ファイル名：Fn3MessageNode.cs
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
	/// メッセージ項目を管理する基底クラス
	/// </summary>
	public abstract class Fn3MessageNode
	{
		#region "メンバ変数"

		private string m_strName;
		private Fn3MessageGroup m_msgParent = null;
		private IFn3Message m_ifMessage = null;

		#endregion

		#region "プロパティ"

		/// <summary>
		/// メッセージ項目の名称を取得します。
		/// </summary>
		public string Name
		{
			get { return this.m_strName; }
		}

		/// <summary>
		/// メッセージ項目のサイズを取得します。
		/// </summary>
		public abstract int Size
		{
			get;
		}

		/// <summary>
		///	このメッセージ項目と関連するメッセージを取得します。
		/// </summary>
		public IFn3Message ParentMessage
		{
			get { return this.m_ifMessage; }
		}

		/// <summary>
		/// このメッセージ項目の親項目を取得します。
		/// </summary>
		public Fn3MessageGroup Parent
		{
			get { return this.m_msgParent; }
		}

		#endregion

		#region "コンストラクタ"

		/// <summary>
		/// Fn3MessageNodeクラスの新しいインスタンスを初期化します。
		/// </summary>
		/// <param name="ifMessage">関連付くメッセージ</param>
		/// <param name="strName">このメッセージ項目の名称</param>
		public Fn3MessageNode(IFn3Message ifMessage, string strName)
		{
			this.m_ifMessage = ifMessage;
			this.m_strName = strName;
		}

		#endregion

		#region "メソッド"

		/// <summary>
		/// このメッセージ項目の親項目を設定します。
		/// </summary>
		/// <param name="parent">親項目</param>
		internal void SetParent(Fn3MessageGroup parent)
		{
			this.m_msgParent = parent;
		}

		/// <summary>
		/// 親項目が管理している項目を取得します。
		/// </summary>
		/// <param name="group">検索する親グループ</param>
		/// <param name="strItemName">項目名</param>
		/// <returns>取得したメッセージ項目。該当項目が存在しない場合はnull。</returns>
		protected Fn3MessageItem GetParentItem(Fn3MessageGroup group, string strItemName)
		{
			foreach(Fn3MessageNode node in group)
			{
				if(node.Name.Equals(strItemName) && node is Fn3MessageItem)
				{
					return (Fn3MessageItem)node;
				}
			}

			if(group.Parent != null)
			{
				return this.GetParentItem(group.Parent, strItemName);
			}
			else
			{
				return null;
			}
		}

		/// <summary>
		/// このメッセージ項目に文字列を設定します。
		/// </summary>
		/// <param name="strValue">設定文字列</param>
		/// <returns>項目に設定されたバイト数。</returns>
		public virtual int SetStringValue(string strValue)
		{
			byte[] bytes = this.ParentMessage.Encoding.GetBytes(strValue);
			return SetByteValue(bytes);
		}

		/// <summary>
		/// このメッセージ項目の設定値を文字列として取得します。
		/// </summary>
		/// <returns>設定文字列</returns>
		public virtual string GetStringValue()
		{
			byte[] bytes = this.GetByteValue();
			return this.ParentMessage.Encoding.GetString(bytes);
		}

		/// <summary>
		/// メッセージを引数のバイト配列でクリアします。
		/// </summary>
		/// <param name="bytes">クリアバイト配列</param>
		/// <remarks>
		/// 項目をクリアバイト配列で埋め尽くします。
		/// </remarks>
		public virtual void Clear(byte[] bytes)
		{
			int num = this.Size / bytes.Length;

			byte[] setBytes = new byte[this.Size];
			setBytes.Initialize();

			for(int i = 0; i < num; i++)
			{
				Array.ConstrainedCopy(bytes, 0, setBytes, i * bytes.Length, bytes.Length);
			}

			this.SetByteValue(setBytes);
		}

		/// <summary>
		/// このメッセージ項目にバイナリデータを設定します。
		/// </summary>
		/// <param name="value">バイナリデータ</param>
		/// <returns>項目に設定されたバイト数。</returns>
		public abstract int SetByteValue(byte[] value);

		/// <summary>
		/// このメッセージ項目に設定されているバイナリデータを取得します。
		/// </summary>
		/// <returns>バイナリデータ</returns>
		public abstract byte[] GetByteValue();

		#endregion
	}
}
