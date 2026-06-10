<%@ LANGUAGE="VBScript" %>
<% 
'///////////////////////////////////////////////////////////////////////////////
'//
'// システム名：FutureNetⅢ
'// 機能名    ：FNW版標準WEB-IF　透析ビューア表示asp
'// ファイル名：Pdf_View_Image.asp
'// 説明      ：透析実績一覧から選択した実績ファイル(PDF以外)を表示
'//
'//	Copyright(C) 2012 NIKKISO CO., LTD. All Rights Reserved 
'//
'// 更新履歴
'//	日付		担当				理由
'// 2012/02/23  會田正人            PDF以外のファイル表示に対応
'//
'///////////////////////////////////////////////////////////////////////////////
Option Explicit
%>
<!--#include file="include/CommonConst.asp"-->
<%
Response.CacheControl = "no-cache"
Response.AddHeader "Pragma", "no-cache"
Response.Expires = -1

'-----------------
' 変数宣言
'-----------------
Dim strFileName

'-----------------
' パラメータ取得
'-----------------
strFileName   = request("file")

%>
<HTML>
<HEAD>
<TITLE>menu</TITLE>

<META http-equiv=Content-Type content="text/html; charset=Shift_JIS">
</HEAD>
<img name=IMG src="<%=strFileName%>" width="100%"/>
</HTML>
