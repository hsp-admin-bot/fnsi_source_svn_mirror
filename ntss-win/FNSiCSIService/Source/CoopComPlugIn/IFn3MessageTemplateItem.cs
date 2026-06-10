///////////////////////////////////////////////////////////////////////////////
//
// システム名：FutureNetⅢ
// 機能名    ：メッセージ管理機能
// ファイル名：IFn3Message.cs
// 説明      ：メッセージテンプレートのインターフェース
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
	/// メッセージテンプレートインターフェース
	/// </summary>
	public interface IFn3MessageTemplateItem
	{
		/// <summary>
		/// テンプレート項目名を取得または設定します。
		/// </summary>
		string Name
		{
			get;
			set;
		}
	}
}
