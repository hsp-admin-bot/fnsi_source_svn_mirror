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
'// 日付        担当                理由
'// 2020/05/20  TEX-SOL             既存システムより流用
'//
'///////////////////////////////////////////////////////////////////////////////

Option Explicit
%>
<!--#include file="include/CommonConst.asp"-->
<!--#include file="include/functions.asp"-->
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
Dim strPatID2
Dim strFileName
Dim strURL
Dim objFSO
Dim strRep
dim strPATHVal1
dim strURLVal1
dim strPATHVal2
dim strURLVal2
' add 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 start
dim hospPatIdLen
' add 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 end
'-----------------
' パラメータ取得
'-----------------
intCnt     = Cint(request("cnt"))	'表示される現在位置
intVer     = Cint(request("ver"))	'バージョン
strPatID   = request("id")			'患者ID
strFileName= request("fn")
strRep= request("repname")
' add 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 start
hospPatIdLen = request("padlen")
' add 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 end

Set objFSO = CreateObject("Scripting.FileSystemObject")

strPatID = FormatNumber(strPatID, 0, 0, 0, 0)
' mod 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 start
'strPatID2 = ZeroPad(FormatNumber(strPatID, 0, 0, 0, 0))
strPatID2 = ZeroPadByLen(FormatNumber(strPatID, 0, 0, 0, 0), hospPatIdLen)
' mod 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 end

'初期表示ファイルのURL
strURL = ""
strPATHVal1 = ""
strURLVal1 = ""
strPATHVal2 = ""
strURLVal2 = ""

	If instr(strFileName,".") > 0 Then
		strPATHVal1 = Server.MapPath("./" & pdfPath ) & "/" & strPatID & "/" & strFileName
		strURLVal1 = pdfPath & strPatID & "/" & strFileName
		strPATHVal2 = Server.MapPath("./" & pdfPath ) & "/" & strPatID2 & "/" & strFileName
		strURLVal2 = pdfPath & strPatID2 & "/" & strFileName
	ElseIf (intVer = 1 and len(strRep) > 0) Then
		strPATHVal1 = Server.MapPath("./" & pdfPath ) & "/" & strPatID & "/" & strRep
		strURLVal1 = pdfPath & strPatID & "/" & strRep
		strPATHVal2 = Server.MapPath("./" & pdfPath ) & "/" & strPatID2 & "/" & strRep
		strURLVal2 = pdfPath & strPatID2 & "/" & strRep
	Else
		strPATHVal1 = Server.MapPath("./" & pdfPath ) & "/" & strPatID & "/" & strFileName & Right("000" & intVer, 4) & ".pdf"
		strURLVal1 = pdfPath & strPatID & "/" & strFileName & Right("000" & intVer, 4) & ".pdf"
		strPATHVal2 = Server.MapPath("./" & pdfPath ) & "/" & strPatID2 & "/" & strFileName & Right("000" & intVer, 4) & ".pdf"
		strURLVal2 = pdfPath & strPatID2 & "/" & strFileName & Right("000" & intVer, 4) & ".pdf"
	End If

    If objFSO.FileExists(strPATHVal1) Then
        'ファイルが存在するため、このファイルパスを採用
        strURL = strURLVal1
    ElseIf objFSO.FileExists(strPATHVal2) Then
        strURL = strURLVal2
    Else
		strURL = "Msg_NoFile.html"
    End If
%>  
<HTML>
<HEAD>
<TITLE>透析実績ビューアー</TITLE>
<META http-equiv=Content-Type content="text/html; charset=shift_jis">
<link rel=stylesheet href="form.css" type="text/css">
</HEAD>
<body>
	<div class="main-content">
		<div class="inner-content navi-area">
<!-- mod 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 start -->
<!--			<iframe name="LEFT" src="Pdf_View_Control.asp?cnt=<%=intCnt%>&ver=<%=intVer%>&id=<%=strPatID%>"></iframe>-->
			<iframe name="LEFT" src="Pdf_View_Control.asp?cnt=<%=intCnt%>&ver=<%=intVer%>&id=<%=strPatID%>&padlen=<%=hospPatIdLen%>"></iframe>
<!-- mod 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 end -->
		</div>
		<div class="inner-content preview-area">
		<% If instr(strURL,"pdf") > 0 Then %>
		    <iframe name="RIGHT" src="<%=strURL%>"></iframe>
		<% ElseIf instr(strURL,"html") > 0 Then %>
		    <iframe name="RIGHT" src="<%=strURL%>"></iframe>
		<% Else %>
		    <iframe name="RIGHT" src="Pdf_View_Image.asp?file=<%=strURL%>"></iframe>
		<% End If %>
		</div>
	</div>
</body>

</HTML>
