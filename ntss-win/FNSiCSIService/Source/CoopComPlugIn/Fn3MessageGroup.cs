///////////////////////////////////////////////////////////////////////////////
//
// システム名：FutureNetⅢ
// 機能名    ：メッセージ管理機能
// ファイル名：Fn3MessageGroup.cs
// 説明      ：電文の管理を行う。
//
//	Copyright(C) 2009 NIKKISO CO., LTD. All Rights Reserved 
//
// 更新履歴
//	日付		担当				理由
//	2009/08/10	根津知則			新規作成
//	2015/03/12	宮崎公伯			登録文字列ををバイト数で切り取る対応(#4373)
//
///////////////////////////////////////////////////////////////////////////////

using System;
using System.Collections.Generic;
using System.IO;
using System.Collections;

namespace jp.co.nikkiso.fn3.Cooperation.CoopComPlugIn
{
	/// <summary>
	/// メッセージグループ管理クラス
	/// </summary>
	public class Fn3MessageGroup : Fn3MessageNode, IEnumerable<Fn3MessageNode>
	{
		#region "メンバ変数"

		private List<Fn3MessageNode> m_arrMsgNode;

		#endregion

		#region "プロパティ"

		/// <summary>
		///	サイズを取得する。
		/// </summary>
		public override int Size
		{
			get
			{
				int size = 0;

				foreach(Fn3MessageNode node in this.m_arrMsgNode)
				{
					size += node.Size;
				}

				return size;
			}
		}

		/// <summary>
		/// 管理項目数を取得する。
		/// </summary>
		public virtual int Count
		{
			get { return this.m_arrMsgNode.Count; }
		}

		/// <summary>
		/// 子グループも含め、全ての項目数を取得します。
		/// </summary>
		public virtual int TotalCount
		{
			get
			{
				int count = 0;

				for(int i = 0; i < this.Count; i++)
				{
					Fn3MessageNode node = this[i];

					if(node is Fn3MessageItem)
					{
						count++;
					}
					else if(node is Fn3MessageGroup)
					{
						count += ((Fn3MessageGroup)node).TotalCount;
					}
				}

				return count;
			}
		}

		#endregion

		#region "コンストラクタ"

		/// <summary>
		/// Fn3MessagGroupクラスの新しいインスタンスを初期化する。
		/// </summary>
		/// <param name="ifMessage">関連するメッセージ</param>
		/// <param name="strName">項目名称</param>
		public Fn3MessageGroup(IFn3Message ifMessage, string strName)
			: base(ifMessage, strName)
		{
			this.m_arrMsgNode = new List<Fn3MessageNode>();
		}

		#endregion

		#region "メソッド"

		/// <summary>
		/// コレクションを反復処理する列挙子を返します。
		/// </summary>
		/// <returns>列挙子</returns>
		public IEnumerator<Fn3MessageNode> GetEnumerator()
		{
			foreach(Fn3MessageNode node in this.m_arrMsgNode)
			{
				yield return node;
			}
		}

		/// <summary>
		/// コレクションを反復処理する列挙子を返します。
		/// </summary>
		/// <returns>列挙子</returns>
		IEnumerator IEnumerable.GetEnumerator()
		{
			return this.GetEnumerator();
		}

		/// <summary>
		/// 保持している項目を取得します。
		/// </summary>
		/// <param name="index">項目番号</param>
		/// <returns>メッセージ項目</returns>
		public Fn3MessageNode this[int index]
		{
			get { return this.m_arrMsgNode[index]; }
		}

		/// <summary>
		/// メッセージ項目を追加します。
		/// </summary>
		/// <param name="node">追加するメッセージ項目</param>
		public virtual void Add(Fn3MessageNode node)
		{
			node.SetParent(this);
			this.m_arrMsgNode.Add(node);
		}

		/// <summary>
		/// このメッセージ項目にバイナリデータを設定します。
		/// </summary>
		/// <param name="value">バイナリデータ</param>
		/// <returns>項目に設定されたバイト数。</returns>
		public override int SetByteValue(byte[] value)
		{
			int totalSetSize = 0;

			using(MemoryStream memStream = new MemoryStream(value))
			{
				foreach(Fn3MessageNode node in this.m_arrMsgNode)
				{
					byte[] bytes = new byte[node.Size];
					int readSize = memStream.Read(bytes, 0, bytes.Length);
					if(readSize == 0) break;
					int setSize = node.SetByteValue(bytes);

					if(readSize > setSize)
					{
						memStream.Seek(setSize - readSize, SeekOrigin.Current);
					}

					totalSetSize += setSize;
				}
			}

			return totalSetSize;
		}

		/// <summary>
		/// メッセージ項目にバイナリデータを設定します。
		/// </summary>
		/// <param name="value">バイナリデータ</param>
		/// <param name="strNodeName">グループ内に管理されている項目名</param>
		/// <returns>項目に設定されたバイト数。</returns>
		/// <example>
		/// 電文の以下の項目に値をセットする。<br />
		/// Fn3テストメッセージ<br />
		/// └内容部<br />
		/// 　└項目情報部<br />
		/// 　　└項目情報部[1]<br />
		/// 　　　└項目名称
		/// <code>
		///	{
		///		Fn3TestMessage msg = new Fn3TestMessage();
		///
		///		//	電文構造作成など
		///		・・・
		///
		///		//	設定値作成
		///		byte[] bytes = new byte[] { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
		///
		///		//	項目に値を設定
		///		int n = msg.SetByteValue("内容部/項目情報/1/項目名称", bytes);
		///	}
		/// </code>
		/// </example>
		public virtual int SetByteValue(string strNodeName, byte[] value)
		{
			Fn3MessageNode node = this.GetChildNode(strNodeName);
			if(node == null) return 0;

			return node.SetByteValue(value);
		}

		/// <summary>
		/// メッセージ項目に文字列を設定します。
		/// </summary>
		/// <param name="strValue">文字列データ</param>
		/// <param name="strNodeName">グループ内に管理されている項目名</param>
		/// <returns>項目に設定されたバイト数。</returns>
		public virtual int SetStringValue(string strNodeName, string strValue)
		{
			Fn3MessageNode node = this.GetChildNode(strNodeName);
			if(node == null) return 0;

            // >>>>> 2015.03.12 M.Miyazaki RedMine#4373(登録文字列ををバイト数で切り取る対応)
            strValue = Fn3ComTool.SubstringBytes(strValue, node.Size);
            // <<<<< 2015.03.12 M.Miyazaki RedMine#4373(登録文字列ををバイト数で切り取る対応)

			return node.SetStringValue(strValue);
		}

		/// <summary>
		/// このメッセージ項目に設定されているバイナリデータを取得します。
		/// </summary>
		/// <returns>バイナリデータ</returns>
		public override byte[] GetByteValue()
		{
			byte[] values = null;

			using(MemoryStream memStream = new MemoryStream())
			{
				for(int i=0; i<this.Count; i++)
				{
					byte[] value = this[i].GetByteValue();
					memStream.Write(value, 0, value.Length);
				}

				memStream.Seek(0, SeekOrigin.Begin);
				values = new byte[memStream.Length];
				memStream.Read(values, 0, values.Length);
			}

			return values;
		}

		/// <summary>
		/// メッセージ項目に設定されているバイナリデータを取得します。
		/// </summary>
		/// <param name="strNodeName">グループ内に管理されている項目名</param>
		/// <returns>バイナリデータ</returns>
		/// <example>
		/// 電文の以下の項目の値を取得する。<br />
		/// Fn3テストメッセージ<br />
		/// └内容部<br />
		/// 　└状態（1バイト）<br />
		/// <code>
		///	{
		///		Fn3TestMessage msg = new Fn3TestMessage();
		///
		///		//	電文構造作成など
		///		・・・
		///
		///		//	値の取得
		///		byte[] value = msg.GetByteValue("内容部/状態");
		///	}
		/// </code>
		/// </example>
		public virtual byte[] GetByteValue(string strNodeName)
		{
			Fn3MessageNode node = this.GetChildNode(strNodeName);
			if(node == null) return null;

			return node.GetByteValue();
		}

		/// <summary>
		/// メッセージ項目に設定されている文字列データを取得します。
		/// </summary>
		/// <param name="strNodeName">グループ内に管理されている項目名</param>
		/// <returns>文字列</returns>
		public virtual string GetStringValue(string strNodeName)
		{
			Fn3MessageNode node = this.GetChildNode(strNodeName);
			if(node == null) return null;

			byte[] bytes = node.GetByteValue();
			if(bytes == null) return null;

			return node.ParentMessage.Encoding.GetString(bytes);
		}

		/// <summary>
		/// このグループの子項目を取得します。
		/// </summary>
		/// <param name="strNodeName">グループ内に管理されている項目名</param>
		/// <returns>子項目</returns>
		public virtual Fn3MessageNode GetChildNode(string strNodeName)
		{
			string[] strKeys = strNodeName.Split("/".ToCharArray());

			return this.GetChildNode(this, strKeys);
		}

		/// <summary>
		/// グループの子項目を取得します。
		/// </summary>
		/// <param name="group">グループ名</param>
		/// <param name="keys">項目名</param>
		/// <returns>子項目</returns>
		private Fn3MessageNode GetChildNode(Fn3MessageGroup group, params string[] keys)
		{
			string strItemName = (string)keys[0];

			foreach(Fn3MessageNode item in group)
			{
				if(item.Name == strItemName)
				{
					if(keys.Length == 1) return item;

					if(item is Fn3MessageLoopManager)
					{
						Fn3MessageLoopManager lm = (Fn3MessageLoopManager)item;
						int index = 0;
						if(int.TryParse(keys[1], out index) == true)
						{
							if(keys.Length == 2) return lm[index];

							string[] newKeys = new string[keys.Length - 2];
							Array.ConstrainedCopy(keys, 2, newKeys, 0, newKeys.Length);
							return this.GetChildNode((Fn3MessageGroup)lm[index], newKeys);
						}
						else
						{
							string[] newKeys = new string[keys.Length - 1];
							Array.ConstrainedCopy(keys, 1, newKeys, 0, newKeys.Length);
							return this.GetChildNode((Fn3MessageGroup)lm[0], newKeys);
						}
					}
					else if(item is Fn3MessageGroup)
					{
						string[] newKeys = new string[keys.Length - 1];
						Array.ConstrainedCopy(keys, 1, newKeys, 0, newKeys.Length);
						return this.GetChildNode((Fn3MessageGroup)item, newKeys);
					}
					else
					{
						
					}
				}
			}

			return null;
		}

		#endregion

	}
}
