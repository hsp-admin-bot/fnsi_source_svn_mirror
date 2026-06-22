///////////////////////////////////////////////////////////////////////////////
//
// システム名：FutureNetⅢ
// 機能名    ：プラグイン機能
// ファイル名：Fn3ComTool.cs
// 説明      ：共通処理を提供します。
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
using System.IO;
using System.Globalization;
using System.Reflection;
using System.Xml;
using System.Collections;

namespace jp.co.nikkiso.fn3.Cooperation.CoopComPlugIn
{
	/// <summary>
	/// 共通処理クラス
	/// </summary>
	public static class Fn3ComTool
	{
		#region "メンバ"

		/// <summary>
		/// 外字を変換する。
		/// </summary>
		/// <remarks>
		/// このメソッドは引数で渡された文字列内に文字コードが0xE000～0xF8FFの文字が存在した場合にその文字を置き換えます。
		/// 文字列内に外字が存在しない場合、このメソッドは引数で渡された文字列のコピーを戻します。
		/// </remarks>
		/// <param name="strDest">対象の文字列</param>
		/// <param name="chrConv">置き換える文字</param>
		/// <returns>変換された文字列</returns>
		/// <example>
		/// <code>
		/// string str = "・・・";
		/// 
		/// string ret = Fn3ComTool.ConvExternalFont(str, "■");	//	外字を"■"で置き換える。
		/// </code>
		/// </example>
		public static string ConvExternalFont(string strDest, char chrConv)
		{
			StringBuilder sb = new StringBuilder(strDest.Length);

			for(int i = 0; i < strDest.Length; i++)
			{
				//	文字コードを取得する。

				uint code = Convert.ToUInt16(strDest[i]);
				if(code >= 0xE000 && code <= 0xF8FF)
				{
					//	外字の場合

					sb.Append(chrConv);
				}
				else
				{
					//	外字以外の場合

					sb.Append(strDest[i]);
				}
			}

			return sb.ToString();
		}

		/// <summary>
		/// メソッドログ出力用メソッド名を取得する。
		/// </summary>
		/// <param name="methodBase">メソッド情報</param>
		/// <returns>メソッド名</returns>
		public static string GetMethodName(MethodBase methodBase)
		{
			StringBuilder sb = new StringBuilder();

			sb.Append(methodBase.DeclaringType.Name);
			if(!methodBase.IsConstructor) sb.AppendFormat(".{0}", methodBase.Name);
			else sb.Append(methodBase.Name);
			sb.AppendFormat("(");

			ParameterInfo[] pi = methodBase.GetParameters();
			for(int i = 0; i < pi.Length; i++)
			{
				if(i != 0) sb.AppendFormat(", {0}", pi[i].ParameterType.Name);
				else sb.Append(pi[i].ParameterType.Name);
			}
			sb.Append(")");

			return sb.ToString();
		}

		

		/// <summary>
		/// DateTimeを標準連携で使用されるフォーマットの文字列に変換する。
		/// </summary>
		/// <param name="dt">変換するDateTimeオブジェクト</param>
		/// <returns>変換された日時を表す文字列</returns>
		/// <remarks>
		/// </remarks>
		/// <example>
		/// <code>
		/// DateTime dt = DateTime.Now;
		///
		/// //	変換を行う。
		/// string strDateTime = Fn3ComTool.DateTimeToString(dt);
		/// </code>
		/// </example>
		public static string DateTimeToString(DateTime dt)
		{
			return dt.ToString("yyyy/MM/dd HH:mm:ss");
		}

		/// <summary>
		/// XMLより値を取得
		/// </summary>
		/// <param name="xml">XML</param>
		/// <param name="strNodePath">XPATH</param>
		/// <returns>値</returns>
		public static string GetXmlValue(XmlNode xml, string strNodePath)
		{
			XmlNode node = xml.SelectSingleNode(strNodePath);
			if(node == null) return "";
			return node.InnerText;
		}

		/// <summary>
		/// XMLより数値を取得
		/// </summary>
		/// <param name="xml">XML</param>
		/// <param name="strNodePath">XPATH</param>
		/// <returns>数値</returns>
		public static decimal? GetXmlValueNumber(XmlNode xml, string strNodePath)
		{
			string strValue = GetXmlValue(xml, strNodePath);
			decimal decValue;
			if(decimal.TryParse(strValue, out decValue) == false)
			{
				return null;
			}
			return decValue;
		}

		/// <summary>
		/// キー情報文字列取得
		/// </summary>
		/// <param name="exeInfo">連携情報</param>
		/// <returns>キー情報文字列</returns>
		public static string GetKeyInfoString(Fn3ExecuteInfo exeInfo)
		{
			StringBuilder sb = new StringBuilder();

			XmlDocument doc = new XmlDocument();
			doc.LoadXml(exeInfo.KeyInfo);

			foreach(XmlNode node in doc.DocumentElement.ChildNodes)
			{
				if(sb.Length > 0) sb.Append(",");
				sb.AppendFormat("{0}={1}", node.Name, node.InnerText);
			}

			if(sb.Length > 0) sb.Append(",");
			sb.AppendFormat("SPECIFIK_KEY={0}", exeInfo.SpecificKey);

			return sb.ToString();
		}

		/// <summary>
		/// キー情報ハッシュテーブル取得
		/// </summary>
		/// <param name="exeInfo">連携情報</param>
		/// <returns>キー情報ハッシュテーブル</returns>
		public static Hashtable GetKeyInfoHashtable(Fn3ExecuteInfo exeInfo)
		{
			XmlDocument doc = new XmlDocument();
			doc.LoadXml(exeInfo.KeyInfo);

			Hashtable hashKeyInfo = new Hashtable();

			foreach(XmlNode node in doc.DocumentElement.ChildNodes)
			{
				hashKeyInfo.Add(node.Name, node.InnerText);
			}

			return hashKeyInfo;
		}

		/// <summary>
		/// 文字列をバイト数で切り取る。
		/// 最終文字が全角の1バイト目の場合は、そのバイトも切り取ります。
		/// </summary>
		/// <param name="str">文字列</param>
		/// <param name="byteCount">バイト数</param>
		/// <returns>切り取られた文字列</returns>
		public static string SubstringBytes(string str, int byteCount)
		{
			Encoding enc = Encoding.GetEncoding(932);
			byte[] bytes = enc.GetBytes(str);
			bool bolFraction = false;

			int counter = 0;

			while(bytes.Length > 0)
			{
				if((bytes[counter] >= 0x81 && bytes[counter] <= 0x9F) || (bytes[counter] >= 0xE0 && bytes[counter] <= 0xFC))
				{
					//	全角の1バイト目
					if(counter == byteCount - 1)
					{
						//	全角1バイト目で半端になってしまう場合
						bolFraction = true;		//	半端フラグを立てる
					}
					else
					{
						counter += 2;
					}
				}
				else
				{
					//	半角
					counter++;
				}

				if(counter == byteCount || counter == bytes.Length || bolFraction == true)
				{
					//	指定バイト数に達した、または配列の最後まで達した、または全角の半端フラグON
					byte[] b = new byte[counter];
					Array.Copy(bytes, 0, b, 0, counter);
					return enc.GetString(b);
				}
			}

			return "";
		}

		/// <summary>
		/// 数値を文字列に変換
		/// </summary>
		/// <param name="dec">変換する数値</param>
		/// <param name="len">桁数</param>
		/// <param name="decimalPlace">lenの内の小数以下の桁数</param>
		/// <returns></returns>
		public static string CreateNumberValue(decimal? dec, int len, int decimalPlace)
		{
			if(dec == null)
			{
				//	数値がnullの場合は、桁数分の空白を返す
				return new string(' ', len);
			}

			//	倍数計算
			int mul = (int)Math.Pow(10, decimalPlace);

			decimal decMulValue = dec.Value * mul;
			int intMulValue = (int)decMulValue;
			string strValue = intMulValue.ToString();
			if(strValue.Length > len)
			{
				//	桁数より大きくなった場合は左桁を切り捨てる
				strValue = strValue.Substring(strValue.Length - len, len);
			}

			//	桁数より小さい場合は、左桁に空白を追加
			strValue = strValue.PadLeft(len, ' ');

			return strValue;
		}


		#endregion
	}
}
