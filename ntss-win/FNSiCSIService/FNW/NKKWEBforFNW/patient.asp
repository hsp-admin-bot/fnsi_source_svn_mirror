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
'//	日付		担当				理由
'//	2010/01/15	堀内英史			FN2版から流用
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
		<title>透析実績ビューア</title>
	</head>
	<frameset framespacing="0" border="0" rows="*,50" frameborder="0">
		<frame name="frame1" src="patient_main.asp?Key1=<%=Req("Key1")%>" marginwidth="0" marginheight="0">
		<frame name="frame2" src="patient_cmd.asp" marginwidth="0" marginheight="0">
		<noframes>
			<body topmargin="0" leftmargin="0">
				<p>このページにはフレームが使用されていますが、お使いのブラウザではサポートされていません。</p>
			</body>
		</noframes>
	</frameset>
</html>
