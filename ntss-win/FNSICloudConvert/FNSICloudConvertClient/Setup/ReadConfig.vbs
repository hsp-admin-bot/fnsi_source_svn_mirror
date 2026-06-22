' 既存の FNSICloudConvertClient.config を読み込み、設定ダイアログ用プロパティへ反映する
' ファイルが存在しない場合（新規インストール）は Product.wxs のデフォルト値を使用する
On Error Resume Next

Dim installDir
installDir = Session.Property("INSTALLFOLDER")
If installDir = "" Then Exit Sub
If Right(installDir, 1) <> "\" Then installDir = installDir & "\"

Dim configPath
configPath = installDir & "FNSICloudConvertClient.config"

Dim fso
Set fso = CreateObject("Scripting.FileSystemObject")
If fso Is Nothing Then Exit Sub
If Not fso.FileExists(configPath) Then Exit Sub

Dim xml
Set xml = CreateObject("MSXML2.DOMDocument.6.0")
If xml Is Nothing Then Exit Sub

xml.async = False
xml.setProperty "SelectionLanguage", "XPath"
xml.load configPath
If xml.parseError.errorCode <> 0 Then Exit Sub

Dim baseUri, facilityHash, converterUri, cert1, cert2, node
baseUri = ""
facilityHash = ""
converterUri = ""
cert1 = ""
cert2 = ""

Set node = xml.selectSingleNode("//CommonSection/BaseUri")
If Not node Is Nothing Then baseUri = Trim(node.text)

Set node = xml.selectSingleNode("//CommonSection/FacilityHash")
If Not node Is Nothing Then facilityHash = Trim(node.text)

Set node = xml.selectSingleNode("//CommonSection/ConverterBaseUri")
If Not node Is Nothing Then converterUri = Trim(node.text)

Set node = xml.selectSingleNode("//CommonSection/ClientCertificateSearchValue1")
If Not node Is Nothing Then cert1 = Trim(node.text)

Set node = xml.selectSingleNode("//CommonSection/ClientCertificateSearchValue2")
If Not node Is Nothing Then cert2 = Trim(node.text)

If baseUri <> "" Then
    Dim signInUrl
    signInUrl = baseUri
    If facilityHash <> "" Then
        Dim sep
        If InStr(baseUri, "?") > 0 Then
            sep = "&"
        Else
            sep = "?"
        End If
        signInUrl = baseUri & sep & "key=" & facilityHash
    End If
    Session.Property("PROP_BASE_URI") = signInUrl
End If

If converterUri <> "" Then
    Session.Property("PROP_CONVERTER_URI") = converterUri
End If

If cert1 <> "" Or cert2 <> "" Then
    Session.Property("PROP_USE_CERT") = "1"
Else
    Session.Property("PROP_USE_CERT") = "0"
End If
