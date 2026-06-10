///////////////////////////////////////////////////////////////////////////////
//
// システム名：FutureNetⅢ
// 機能名    ：メッセージ管理機能
// ファイル名：IFn3Message.cs
// 説明      ：メッセージと他クラスのインターフェース
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
	/// メッセージ管理クラスの基底クラス
	/// </summary>
	public interface IFn3Message : IEnumerable<Fn3MessageNode>
	{
		/// <summary>
		/// このメッセージの名称を取得する。
		/// </summary>
		string Name
		{
			get;
		}

		/// <summary>
		/// このメッセージのエンコーディングを取得する。
		/// </summary>
		Encoding Encoding
		{
			get;
		}
	}
}
