///////////////////////////////////////////////////////////////////////////////
//
// システム名：FutureNetⅢ
// 機能名    ：メッセージ管理機能
// ファイル名：Fn3MessageTemplate.cs
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

namespace jp.co.nikkiso.fn3.Cooperation.CoopComPlugIn
{
	/// <summary>
	/// 電文テンプレート作成時の基底となるクラス。
	/// </summary>
	public class Fn3MessageTemplate : IFn3MessageTemplateItem, IEnumerable<IFn3MessageTemplateItem>
	{
		#region "メンバ変数"

		List<IFn3MessageTemplateItem> items = new List<IFn3MessageTemplateItem>();

		private int loopCount;
		private string loopCounterName;
		private string name;

		#endregion

		#region "プロパティ"

		/// <summary>
		/// ループカウントを取得または設定します。
		/// </summary>
		public int LoopCount
		{
			get { return loopCount; }
			set { this.LoopCount = value; }
		}

		/// <summary>
		/// 電文上のループカウントの項目名を取得または設定します。
		/// </summary>
		public string LoopCounterName
		{
			get { return loopCounterName; }
			set { this.loopCounterName = value; }
		}

		/// <summary>
		/// 項目名を取得または設定します。
		/// </summary>
		/// <remarks>
		/// 項目名には「/（半角スラッシュ）」は使用しないでください。
		/// </remarks>
		public string Name
		{
			get { return this.name; }
			set { this.name = value; }
		}

		/// <summary>
		/// 保持している項目数を取得します。
		/// </summary>
		public int ItemCount
		{
			get { return this.items.Count; }
		}

		#endregion

		#region "コンストラクタ"

		/// <summary>
		/// Fn3MessageTemplate クラスの新しいインスタンスを初期化します。
		/// </summary>
		public Fn3MessageTemplate()
		{
			this.loopCount = 1;
			this.loopCounterName = "";
			this.name = "";
		}

		/// <summary>
		/// Fn3MessageTemplate クラスの新しいインスタンスを初期化します。
		/// </summary>
		/// <param name="name">項目名</param>
		/// <remarks>
		/// 項目名には「/（半角スラッシュ）」は使用しないでください。
		/// </remarks>
		public Fn3MessageTemplate(string name)
		{
			this.loopCount = 1;
			this.loopCounterName = "";
			this.name = name;
		}

		/// <summary>
		/// Fn3MessageTemplate クラスの新しいインスタンスを初期化します。
		/// </summary>
		/// <param name="name">項目名</param>
		/// <param name="loopCount">ループカウント</param>
		/// <remarks>
		/// 項目名には「/（半角スラッシュ）」は使用しないでください。
		/// </remarks>
		public Fn3MessageTemplate(string name, int loopCount)
		{
			this.loopCount = loopCount;
			this.loopCounterName = "";
			this.name = name;
		}

		/// <summary>
		/// Fn3MessageTemplate クラスの新しいインスタンスを初期化します。
		/// </summary>
		/// <param name="name">項目名</param>
		/// <param name="loopCount">ループカウント</param>
		/// <param name="loopCounterName">電文上のループカウントの項目名</param>
		/// <remarks>
		/// 項目名には「/（半角スラッシュ）」は使用しないでください。
		/// </remarks>
		public Fn3MessageTemplate(string name, int loopCount, string loopCounterName)
		{
			this.loopCount = loopCount;
			this.loopCounterName = loopCounterName;
			this.name = name;
		}

		#endregion

		#region "メソッド"

		/// <summary>
		/// このテンプレートに項目を追加します。
		/// </summary>
		/// <param name="item">追加する項目</param>
		/// <returns>このインスタンス</returns>
		public virtual Fn3MessageTemplate AddItem(IFn3MessageTemplateItem item)
		{
			this.items.Add(item);
			return this;
		}

		/// <summary>
		/// このテンプレートに項目を追加します。
		/// </summary>
		/// <param name="items">追加する項目</param>
		/// <returns>このインスタンス</returns>
		public virtual Fn3MessageTemplate AddItem(params IFn3MessageTemplateItem[] items)
		{
			if(items.Length > 0)
			{
				this.items.AddRange(items);
			}
			return this;
		}

		/// <summary>
		/// このテンプレートに項目を追加します。
		/// </summary>
		/// <param name="items">追加する項目</param>
		/// <returns>このインスタンス</returns>
		public virtual Fn3MessageTemplate AddRange(IFn3MessageTemplateItem[] items)
		{
			this.items.AddRange(items);
			return this;
		}

		/// <summary>
		/// コレクションを反復処理する列挙子を返します。
		/// </summary>
		/// <returns>列挙子</returns>
		public IEnumerator<IFn3MessageTemplateItem> GetEnumerator()
		{
			foreach(IFn3MessageTemplateItem item in items)
			{
				yield return item;
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
		/// 項目を取得します。
		/// </summary>
		/// <param name="index">項目番号</param>
		/// <returns>メッセージテンプレート項目</returns>
		public IFn3MessageTemplateItem this[int index]
		{
			get { return this.items[index]; }
		}

		#endregion
	}
}
