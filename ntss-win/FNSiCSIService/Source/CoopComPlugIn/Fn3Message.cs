///////////////////////////////////////////////////////////////////////////////
//
// システム名：FutureNetⅢ
// 機能名    ：メッセージ管理機能
// ファイル名：Fn3Message.cs
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
using System.Collections;
using System.IO;

namespace jp.co.nikkiso.fn3.Cooperation.CoopComPlugIn
{

	/// <summary>
	/// メッセージ管理クラス
	/// </summary>
	/// <remarks>
	/// 電文テンプレートによりメッセージの構造を作成し、このクラスで実態を生成します。
	/// </remarks>
	/// <example>
	/// メッセージ構造の生成方法を以下に示す。<br />
	/// Fn3テストメッセージ<br />
	/// ├ヘッダー<br />
	/// │├電文種別（2バイト）<br />
	/// │└電文長（3バイト）<br />
	/// ├内容部<br />
	/// │├患者番号（10バイト）<br />
	/// │├状態（1バイト）<br />
	/// │├ベッド番号（2バイト）<br />
	/// │└項目情報部（繰返し項目）<br />
	/// │　├項目情報部[0]<br />
	/// │　│├項目コード（3バイト）<br />
	/// │　│└項目名称（20バイト）<br />
	/// │　└項目情報部[1]<br />
	/// │　　├項目コード（3バイト）<br />
	/// │　　└項目名称（20バイト）<br />
	/// └EOD
	/// <code>
	///	public class Fn3TestMessage : Fn3Message
	///	{
	///		public Fn3TestMessage()
	///			: base("Fn3テストメッセージ")
	///		{
	///			Fn3MessageTemplate root = new Fn3MessageTemplate();
	///
	///			//	ヘッダーグループ作成
	///			Fn3MessageTemplate header = new Fn3MessageTemplate("ヘッダー");
	///			header.AddItem(new Fn3MessageTemplateItem("電文種別", 2));
	///			header.AddItem(new Fn3MessageTemplateItem("電文長", 3));
	///
	///			//	内容部グループ作成
	///			Fn3MessageTemplate content = new Fn3MessageTemplate("内容部");
	///			content.AddItem(new Fn3MessageTemplateItem("患者番号", 10));
	///			content.AddItem(new Fn3MessageTemplateItem("状態", 1));
	///			content.AddItem(new Fn3MessageTemplateItem("ベッド番号", 2));
	///
	///			//	項目情報作成（繰返し2回）
	///			Fn3MessageTemplate itemInfo = new Fn3MessageTemplate("項目情報", 2);
	///			itemInfo.AddItem(new Fn3MessageTemplateItem("項目コード", 3));
	///			itemInfo.AddItem(new Fn3MessageTemplateItem("項目名称", 20));
	///			content.AddItem(itemInfo);		//	項目情報を内容部に追加
	///
	///			root.AddItem(header);		//	ヘッダーグループをルートに追加
	///			root.AddItem(content);		//	内容部グループをルートに追加
	///			root.AddItem(new Fn3MessageTemplateItem("EOD", 1));		//	EODをルートに追加
	///
	///			//	テンプレートを元に電文を生成する。
	///			this.Create(root);
	///		}
	///	}
	/// </code>
	/// 上で作成した電文の以下の項目に値をセットする。<br />
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
	/// 上で作成した電文の以下の項目の値を取得する。<br />
	/// Fn3テストメッセージ<br />
	/// └内容部<br />
	/// 　└状態（1バイト）
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
	public class Fn3Message : Fn3MessageGroup, IFn3Message
	{
		#region "メンバ変数"

		private Encoding m_encoding;

		#endregion

		#region "プロパティ"

		/// <summary>
		/// 文字列変換時のエンコーディングを設定します。
		/// </summary>
		public Encoding Encoding
		{
			get	{ return this.m_encoding; }
			set	{ this.m_encoding = value; }
		}

		#endregion

		#region "コンストラクタ"

		/// <summary>
		/// Fn3Messageクラスの新しいインスタンスを設定します。
		/// </summary>
		/// <param name="strName">メッセージ名</param>
		/// <remarks>
		/// コンストラクタをオーバーライドしてメッセージ構造を生成してください。
		/// </remarks>
		public Fn3Message(string strName)
			: base(null, strName)
		{
			//	エンコーディングをShift-JISに設定
			this.m_encoding = Encoding.GetEncoding(932);
		}

		#endregion

		#region "メソッド"

		/// <summary>
		/// Fn3MessageTemplateをもとにメッセージ構成を生成します。
		/// </summary>
		/// <param name="template">テンプレート</param>
		public void Create(Fn3MessageTemplate template)
		{
			this.Create(template, this);
		}

		/// <summary>
		/// Fn3MessageTemplateをもとにメッセージ構成を生成します。
		/// </summary>
		/// <param name="template">テンプレート</param>
		/// <param name="group">生成グループ</param>
		/// <example>
		/// メッセージ構造の生成方法を以下に示す。<br />
		/// Fn3テストメッセージ
		/// ├ヘッダー
		/// │├電文種別
		/// │└電文長
		/// ├内容部
		/// │├患者番号
		/// │├状態
		/// │├ベッド番号
		/// │└項目情報部
		/// │　├項目情報部[0]
		/// │　│├項目コード
		/// │　│└項目名称
		/// │　└項目情報部[1]
		/// │　　├項目コード
		/// │　　└項目名称
		/// └EOD
		/// <code>
		///	public class Fn3TestMessage : Fn3Message
		///	{
		///		public Fn3TestMessage()
		///			: base("Fn3テストメッセージ")
		///		{
		///			Fn3MessageTemplate root = new Fn3MessageTemplate();
		///
		///			Fn3MessageTemplate header = new Fn3MessageTemplate("ヘッダー");
		///			header.AddItem(new Fn3MessageTemplateItem("電文種別", 2));
		///			header.AddItem(new Fn3MessageTemplateItem("電文長", 3));
		///
		///			Fn3MessageTemplate content = new Fn3MessageTemplate("内容部");
		///			content.AddItem(new Fn3MessageTemplateItem("患者番号", 10));
		///			content.AddItem(new Fn3MessageTemplateItem("状態", 1));
		///			content.AddItem(new Fn3MessageTemplateItem("ベッド番号", 2));
		///
		///			Fn3MessageTemplate itemInfo = new Fn3MessageTemplate("項目情報", 2);
		///			itemInfo.AddItem(new Fn3MessageTemplateItem("項目コード", 3));
		///			itemInfo.AddItem(new Fn3MessageTemplateItem("項目名称", 20));
		///			content.AddItem(itemInfo);
		///
		///			root.AddItem(header);
		///			root.AddItem(content);
		///			root.AddItem(new Fn3MessageTemplateItem("EOD", 1));
		///
		///			this.Create(root);
		///		}
		///	}
		/// </code>
		/// </example>
		/// <remarks>
		/// 項目名には「/（半角スラッシュ）」は使用しないでください。
		/// </remarks>
		private void Create(Fn3MessageTemplate template, Fn3MessageGroup group)
		{
			foreach(IFn3MessageTemplateItem item in template)
			{
				if(item is Fn3MessageTemplate)
				{
					Fn3MessageTemplate temp = (Fn3MessageTemplate)item;
					if(temp.LoopCount == 1)
					{
						Fn3MessageGroup mg = new Fn3MessageGroup(this, temp.Name);
						this.Create(temp, mg);
						group.Add(mg);
					}
					else
					{
						Fn3MessageLoopManager lm = new Fn3MessageLoopManager(this, temp.Name, temp.LoopCount, temp.LoopCounterName);
						for(int i = 0; i < temp.LoopCount; i++)
						{
							Fn3MessageGroup mg = new Fn3MessageGroup(this, temp.Name);
							this.Create(temp, mg);
							lm.Add(mg);
						}
						group.Add(lm);
					}
				}
				else
				{
					Fn3MessageTemplateItem tempItem = (Fn3MessageTemplateItem)item;
					Fn3MessageItem messageItem = new Fn3MessageItem(this, tempItem.Name, tempItem.Size, tempItem.Type, tempItem.SizeCounter);
					group.Add(messageItem);
				}
			}
		}

		/// <summary>
		/// メッセージ項目に設定されている文字列データを取得します。
		/// </summary>
		/// <returns>文字列</returns>
		public override string GetStringValue()
		{
			byte[] bytes = this.GetByteValue();
			return this.Encoding.GetString(bytes);
		}

		#endregion
	}
}
