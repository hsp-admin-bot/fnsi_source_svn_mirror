<%@ LANGUAGE="VBScript" %>
<% 
'///////////////////////////////////////////////////////////////////////////////
'//
'// システム名：FutureNetⅢ
'// 機能名    ：FNW版標準WEB-IF　透析ビューア表示制御asp
'// ファイル名：Pdf_View_Control.asp
'// 説明      ：透析ビューアの表示制御を行う為のasp
'//			  ：前回ボタン、次回ボタンによる表示する実績ファイルの移動と版数指定表示を行う。
'//
'//	Copyright(C) 2010 NIKKISO CO., LTD. All Rights Reserved 
'//
'// 更新履歴
'//	日付		担当				理由
'//	2010/01/15	堀内英史			FN2版から流用カスタマイズ
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
Dim intPrevCnt
Dim intNextCnt

Dim aryComboData
Dim strSelect
dim objFSO
Dim j
Dim strFileName
Dim strRep

'-----------------
' パラメータ取得
'-----------------
intCnt     = Cint(request("cnt"))	'表示される現在位置
intVer     = Cint(request("ver"))	'バージョン
strPatID   = request("id")			'患者ID


Set objFSO = CreateObject("Scripting.FileSystemObject")

'-----------------
' 配列情報
'-----------------

'※データ配列は降順である為、次回は配列もバック、前回は配列を次へ移動する
'次回ボタン押下後の番号
if intCnt = 0 then
	'最初であれば最初を常に表示
	intPrevCnt = 0
else
	intPrevCnt = intCnt - 1
end if

'前回ボタン押下後の番号
If IsEmpty(Session("aryData")) = False Then
	if intCnt = UBound(Session("aryData"),2) then
		'最後であれば最後を常に表示
		intNextCnt = intCnt
	else
		intNextCnt = intCnt + 1
	end if
End if
%>
<HTML>
<HEAD>
<TITLE>menu</TITLE>



<META http-equiv=Content-Type content="text/html; charset=Shift_JIS">
<% if IsEmpty(Session("aryData")) = False Then %>
<SCRIPT LANGUAGE="JavaScript">
<!--
	// 前回・次回ボタン押下
	function afNextButton(intCnt, intVer, strFileName, strRep){
		with(document.form1){
			top.location.href = "Pdf_View_Main.asp?cnt="+intCnt+"&ver="+intVer+"&id=<%=strPatID%>&fn="+strFileName+"&repName="+strRep;
		}
	}
	// 最新ボタン押下
	function afLatestButton(intCnt, intVer, strFileName, strRep){
		with(document.form1){
			top.location.href = "Pdf_View_Main.asp?cnt="+intCnt+"&ver="+intVer+"&id=<%=strPatID%>&fn="+strFileName+"&repName="+strRep;
		}
	}
	// 表示ボタン押下
	function afPDFView(){
		with(document.form1){
			top.location.href = "Pdf_View_Main.asp?cnt=<%=intCnt%>&ver="+lstVersion.value+"&id=<%=strPatID%>&fn=<%=Session("aryData")(1,intCnt)%>&repName=<%=Session("aryData")(3,intCnt)%>";
		}
	}
-->
</SCRIPT>
<%End If%>
</HEAD>
<BODY text=#000000 vLink=#000000 aLink=#000000 link=#000000>
<FORM NAME="form1">
	<TABLE border="0" cellpadding="0" cellspacing="0" height=100% width=100%>
		<TR valign="top" align="center">
			<TD>
				<table border="1" cellpadding="0" cellspacing="0" width=100% bgcolor="#eeeeee">
					<tr height="80" align="center">
						<td><img src="image/nikkiso.bmp" border=0></td>
					</tr>
					<tr height="80" align="center">
						<td>
<%If IsEmpty(Session("aryData")) = False Then%>
							<INPUT type="button" value="前　回" onClick="Javascript:afNextButton(<%=intNextCnt%>,<%=Session("aryData")(2,intNextCnt)%>,'<%=Session("aryData")(1,intNextCnt)%>','<%=Session("aryData")(3,intNextCnt)%>');">
							<INPUT type="button" value="次　回" onClick="Javascript:afNextButton(<%=intPrevCnt%>,<%=Session("aryData")(2,intPrevCnt)%>,'<%=Session("aryData")(1,intPrevCnt)%>','<%=Session("aryData")(3,intPrevCnt)%>');">　
							<INPUT type="button" value="最　新" onClick="Javascript:afLatestButton(<%=0%>,<%=Session("aryData")(2,0)%>,'<%=Session("aryData")(1,0)%>','<%=Session("aryData")(3,0)%>');">
<%Else%>
							<INPUT type="button" value="前　回" disable>
							<INPUT type="button" value="次　回" disable>
							<INPUT type="button" value="最　新" disable>
<%End If%>
						</td>
					</tr>
					<tr height="80" align="center">
<%If IsEmpty(Session("aryData")) = False Then%>
						<td><%=Session("aryData")(0,intCnt)%></td>
<%Else%>
						<td><font color=Red>セッションタイムアウト</font></td>
<%End If%>
					</tr>
					<tr height="80" align="center">
						<TD>
<%
			If IsEmpty(Session("aryData")) = False Then
				'ファイル名がある場合
				if len(Session("aryData")(3,intCnt)) > 0 and Session("aryData")(2,intCnt) = 1 then
					If objFSO.FileExists(pdfFolder & strPatID & "\\" & Session("aryData")(3,intCnt) ) Then
'						strFileName = Session("aryData")(3,intCnt)
%>							<SELECT NAME="lstVersion" style="width:4em;">
								<OPTION VALUE=1>001
							</SELECT>
							<INPUT type="button" value="表示" onClick="Javascript:afPDFView();">
<%					End If
				'バージョンがある場合
				Elseif Session("aryData")(2,intCnt) = 1 then
					If objFSO.FileExists(pdfFolder & strPatID & "\\" & Session("aryData")(1,intCnt) & "0001.pdf") or _
							objFSO.FileExists(pdfFolder & strPatID & "\\" & Session("aryData")(1,intCnt) & ".pdf") Then
'							strFileName = Session("aryData")(1,intCnt)
%>							<SELECT NAME="lstVersion" style="width:4em;">
								<OPTION VALUE=1>001
							</SELECT>
							<INPUT type="button" value="表示" onClick="Javascript:afPDFView();">
<%					End If

				'バージョンがある場合
				Else
					'コンボデータ作成
					aryComboData = ""
					for j = Session("aryData")(2,intCnt) to 1 step -1
						If j = 1 and len(Session("aryData")(3,intCnt)) > 0 Then
							''ファイル名を直指定で検索
							If objFSO.FileExists(pdfFolder & strPatID & "\\" & Session("aryData")(3,intCnt)) Then
								strFileName = Session("aryData")(3,intCnt)
								If aryComboData = "" then
									aryComboData = j
								Else
									aryComboData = aryComboData & "," & j
								End If
							End If
						elseIf j = 1 Then
							''初版は版数付きのファイルと版数無しのファイルを検索
							If objFSO.FileExists(pdfFolder & strPatID & "\\" & Session("aryData")(1,intCnt) & "0001.pdf") or _
								objFSO.FileExists(pdfFolder & strPatID & "\\" & Session("aryData")(1,intCnt) & ".pdf") Then
									strFileName = Session("aryData")(1,intCnt)
								If aryComboData = "" then
									aryComboData = j
								Else
									aryComboData = aryComboData & "," & j
								End If
							End If
						ElseIf objFSO.FileExists(pdfFolder & strPatID & "\\" & Session("aryData")(1,intCnt) & Right("000" & j, 4) & ".pdf") Then
							strFileName = Session("aryData")(1,intCnt)
							If aryComboData = "" then
								aryComboData = j
							Else
								aryComboData = aryComboData & "," & j
							End if
						end if
					next
							strFileName = Session("aryData")(1,intCnt)

					if aryComboData = "" then
						'表示なし
					else
						response.write "							<SELECT NAME='lstVersion' style='width:4em;'>" & vbCrLf
						'コンボ表示
						aryComboData = Split(aryComboData, ",")
						for j = LBound(aryComboData) to UBound(aryComboData)
							'現在位置を初期表示とする
							strSelect = ""
							if Cint(aryComboData(j)) = intVer then
								strSelect = " SELECTED"
							end if
							response.write "								<OPTION VALUE=" & aryComboData(j) & strSelect & ">" & Right("000" & aryComboData(j),4) & "</OPTION>"& vbCrLf
						next

						response.write "							</SELECT>" & vbCrLf
						response.write "							<INPUT type='button' value='表示' onClick='Javascript:afPDFView();'>" & vbCrLf
					end if
				End If
			Else
%>
							<font color=Red>本画面を閉じ、透析実績一覧画面を再表示してください。</font>
<%
			End If
%>						</TD>
					</tr>
				</TABLE>
			</TD>
		</TR>
	</TABLE>
</FORM>
</BODY>
</HTML>
