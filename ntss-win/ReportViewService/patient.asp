<%@ LANGUAGE="VBScript" %>
<%
'///////////////////////////////////////////////////////////////////////////////
'//
'// システム名：FutureNetⅢ
'// 機能名    ：FNW版標準WEB-IF　患者選択画面asp
'// ファイル名：patient.asp
'// 説明      ：患者一覧のベースフレーム
'//
'//	Copyright(C) 2010 NIKKISO CO., LTD. All Rights Reserved 
'//
'// 更新履歴
'// 日付        担当                理由
'// 2020/05/20  TEX-SOL             既存システムより流用
'//
'///////////////////////////////////////////////////////////////////////////////

Option Explicit
%>
<!--#include file="include/functions.asp"-->
<!--#include file="include/PatBasic.asp"-->

<!-- パラメータ取得 -->
<% Call GetArg %>

<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=x-sjis">
		<link rel=stylesheet href="form.css" type="text/css">
		<base target="frame1">
		<title>透析実績ビューア</title>
	</head>
	<body>
		<div class="patient-main"><iframe name="frame1" src="patient_main.asp?Key1=<%=Req("Key1")%>">iframe 対応のブラウザで見てください。</iframe></div>
		<div class="patient-cmd"><iframe name="frame2" src="patient_cmd.asp"></iframe></div>
	</body>
</html>
