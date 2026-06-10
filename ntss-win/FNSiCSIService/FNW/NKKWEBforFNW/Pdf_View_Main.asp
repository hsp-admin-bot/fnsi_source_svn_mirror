<%@ LANGUAGE="VBScript" %>
<% 
'///////////////////////////////////////////////////////////////////////////////
'//
'// システム名：FutureNetⅢ
'// 機能名    ：FNW版標準WEB-IF　透析ビューア表示asp
'// ファイル名：Pdf_View_Main.asp
'// 説明      ：透析実績一覧から選択した実績ファイルを表示する為のメインフレーム
'//
'//	Copyright(C) 2010 NIKKISO CO., LTD. All Rights Reserved 
'//
'// 更新履歴
'//	日付		担当				理由
'//	2010/01/15	堀内英史			FN2版から流用カスタマイズ
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
Dim intCnt
Dim intVer
Dim strPatID
Dim strFileName
Dim strURL
Dim objFSO
Dim strRep

'-----------------
' パラメータ取得
'-----------------
intCnt     = Cint(request("cnt"))	'表示される現在位置
intVer     = Cint(request("ver"))	'バージョン
strPatID   = request("id")			'患者ID
strFileName= request("fn")
strRep= request("repname")

Set objFSO = CreateObject("Scripting.FileSystemObject")


'初期表示ファイルのURL
strURL = ""

	If instr(strFileName,".") > 0 Then
		strURL = pdfPath & strPatID & "/" & strFileName
	elseIf (intVer = 1 and len(strRep) > 0) Then
		strURL = pdfPath & strPatID & "/" & strRep
'	elseIf intVer = 1 Then
'		''初版は版数付きと版数無しを検索
'		If objFSO.FileExists(pdfFolder & strPatID & "\\" & strFileName & "0001.pdf") Then
'			strURL = pdfPath & strPatID & "/" & strFileName & Right("000" & intVer, 4) & ".pdf"
'		ElseIf objFSO.FileExists(pdfFolder & strPatID & "\\" & strFileName & ".pdf") Then
'			strURL = pdfPath & strPatID & "/" & strFileName & ".pdf"
'		Else
'			strURL = "Msg_NoFile.html"
'		End If
	ElseIf objFSO.FileExists(pdfFolder & strPatID & "\\" & strFileName & Right("000" & intVer, 4) & ".pdf") Then
		strURL = pdfPath & strPatID & "/" & strFileName & Right("000" & intVer, 4) & ".pdf"
	Else
		strURL = "Msg_NoFile.html"
	End If
%>  
<HTML>
<HEAD>
<TITLE>透析実績ビューアー</TITLE>
<META http-equiv=Content-Type content="text/html; charset=shift_jis">
</HEAD>
<FRAMESET border=0 frameSpacing=0 frameBorder=no cols=200,*>
	<FRAME name="LEFT"  marginWidth=0 marginHeight=0 src="Pdf_View_Control.asp?cnt=<%=intCnt%>&ver=<%=intVer%>&id=<%=strPatID%>" noResize>
	<% If instr(strURL,"pdf") > 0 Then %>
	    <FRAME name="RIGHT" marginWidth=0 marginHeight=0 src="<%=strURL%>">
	<% Else %>
	    <FRAME name="RIGHT" marginWidth=0 marginHeight=0 src="Pdf_View_Image.asp?file=<%=strURL%>">
	<% End If %>
</FRAMESET>

</HTML>
