///////////////////////////////////////////////////////////////////////////////
//
// システム名：FutureNetⅢ
// 機能名    ：メッセージ管理機能
// ファイル名：Fn3MessageTemplateItem.cs
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
	/// ノード種別
	/// </summary>
	public enum MessageNodeType
	{
		/// <summary>
		/// バイナリ項目
		/// </summary>
		Binaly,

		/// <summary>
		/// 文字列項目
		/// </summary>
		String,
	}

	/// <summary>
	/// 電文フォーマット作成時の項目を表すクラス
	/// </summary>
	public class Fn3MessageTemplateItem : IFn3MessageTemplateItem
	{
		#region "メンバ変数"

		private string m_strName;
		private int m_intSize;
		private string m_strSizeCounter;
		private MessageNodeType m_type;

		#endregion

		#region "プロパティ"

		/// <summary>
		/// 項目名を取得または設定します。
		/// </summary>
		/// <remarks>
		/// 項目名には「/（半角スラッシュ）」は使用しないでください。
		/// </remarks>
		public string Name
		{
			get { return this.m_strName; }
			set { this.m_strName = value; }
		}

		/// <summary>
		/// 項目のサイズを取得または設定します。
		/// </summary>
		/// <remarks>
		/// 項目のサイズはバイト数で設定します。
		/// </remarks>
		public int Size
		{
			get { return this.m_intSize; }
			set { this.m_intSize = value; }
		}

		/// <summary>
		/// 項目のサイズを格納している項目を設定します。
		/// </summary>
		public string SizeCounter
		{
			get { return this.m_strSizeCounter; }
			set { this.m_strSizeCounter = value; }
		}

		/// <summary>
		/// ノード種別を取得または設定します。
		/// </summary>
		public MessageNodeType Type
		{
			get { return this.m_type; }
			set { this.m_type = value; }
		}

		#endregion

		#region "コンストラクタ"

		/// <summary>
		/// Fn3MessageTemplateItem クラスの新しいインスタンスを初期化します。
		/// </summary>
		/// <param name="strName">項目名</param>
		/// <param name="intSize">項目のサイズ</param>
		/// <remarks>
		/// 項目名には「/（半角スラッシュ）」は使用しないでください。
		/// </remarks>
		public Fn3MessageTemplateItem(string strName, int intSize)
		{
			this.m_strName = strName;
			this.m_intSize = intSize;
			this.m_strSizeCounter = "";
			this.m_type = MessageNodeType.String;
		}

		/// <summary>
		/// Fn3MessageTemplateItem クラスの新しいインスタンスを初期化します。
		/// </summary>
		/// <param name="strName">項目名</param>
		/// <param name="intSize">項目のサイズ</param>
		/// <param name="msgNodeType">ノード種別</param>
		/// <remarks>
		/// 項目名には「/（半角スラッシュ）」は使用しないでください。
		/// </remarks>
		public Fn3MessageTemplateItem(string strName, int intSize, MessageNodeType msgNodeType)
		{
			this.m_strName = strName;
			this.m_intSize = intSize;
			this.m_strSizeCounter = "";
			this.m_type = msgNodeType;
		}

		/// <summary>
		/// Fn3MessageTemplateItem クラスの新しいインスタンスを初期化します。
		/// </summary>
		/// <param name="strName">項目名</param>
		/// <param name="strSizeCounter">項目のサイズを格納している項目</param>
		/// <param name="msgNodeType">ノード種別</param>
		/// <remarks>
		/// 項目名には「/（半角スラッシュ）」は使用しないでください。
		/// </remarks>
		public Fn3MessageTemplateItem(string strName, string strSizeCounter, MessageNodeType msgNodeType)
		{
			this.m_strName = strName;
			this.m_intSize = -1;
			this.m_strSizeCounter = strSizeCounter;
			this.m_type = msgNodeType;
		}

		#endregion
	}
}
