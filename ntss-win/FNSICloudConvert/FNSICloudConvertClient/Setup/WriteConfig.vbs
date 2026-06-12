' CustomActionData = "INSTALLFOLDER~|~FULL_URI~|~USE_CERT~|~CONVERTER_URI"
        ' fullUri 例: http://example.com:8080?key=ABC123
        '   -> BaseUri     = http://example.com:8080
        '   -> FacilityHash = ABC123
        On Error Resume Next

        Dim sData, aParts
        sData  = Session.Property("CustomActionData")
        aParts = Split(sData, "~|~")

        If UBound(aParts) >= 2 Then

            Dim installDir, fullUri, useCert, converterUri
            installDir   = aParts(0)
            fullUri      = aParts(1)
            useCert      = aParts(2)
            converterUri = ""
            If UBound(aParts) >= 3 Then converterUri = aParts(3)

            If Right(installDir, 1) <> "\" Then installDir = installDir & "\"

            Dim configPath
            configPath = installDir & "FNSICloudConvertClient.config"

            ' URL をパース
            '   BaseUri    = scheme://host[:port]  のみ
            '   FacilityHash = key= パラメータ値
            Dim baseUri, facilityHash
            baseUri      = fullUri
            facilityHash = ""

            ' scheme://host[:port] を抽出
            Dim schemeEnd
            schemeEnd = InStr(fullUri, "://")
            If schemeEnd > 0 Then
                Dim hostStart
                hostStart = schemeEnd + 3
                Dim hostEnd, chkPos
                hostEnd = Len(fullUri) + 1
                chkPos = InStr(hostStart, fullUri, "/")
                If chkPos > 0 And chkPos < hostEnd Then hostEnd = chkPos
                chkPos = InStr(hostStart, fullUri, "?")
                If chkPos > 0 And chkPos < hostEnd Then hostEnd = chkPos
                chkPos = InStr(hostStart, fullUri, "#")
                If chkPos > 0 And chkPos < hostEnd Then hostEnd = chkPos
                baseUri = Left(fullUri, hostEnd - 1)
            End If

            ' key= パラメータを URL 全体から検索
            Dim keyPos
            keyPos = InStr(LCase(fullUri), "key=")
            If keyPos > 0 Then
                Dim keyVal
                keyVal = Mid(fullUri, keyPos + 4)
                Dim ampPos
                ampPos = InStr(keyVal, "&")
                If ampPos > 0 Then
                    facilityHash = Left(keyVal, ampPos - 1)
                Else
                    facilityHash = keyVal
                End If
            End If

            ' converterUri: scheme://host[:port] のみ抽出
            Dim converterBase
            converterBase = converterUri
            Dim convSchemeEnd
            convSchemeEnd = InStr(converterUri, "://")
            If convSchemeEnd > 0 Then
                Dim convHostStart
                convHostStart = convSchemeEnd + 3
                Dim convHostEnd, convChkPos
                convHostEnd = Len(converterUri) + 1
                convChkPos = InStr(convHostStart, converterUri, "/")
                If convChkPos > 0 And convChkPos < convHostEnd Then convHostEnd = convChkPos
                converterBase = Left(converterUri, convHostEnd - 1)
            End If

            Dim fso
            Set fso = CreateObject("Scripting.FileSystemObject")

            If Not fso Is Nothing Then
                If fso.FileExists(configPath) Then

                    Dim xml
                    Set xml = CreateObject("MSXML2.DOMDocument.6.0")

                    If Not xml Is Nothing Then
                        xml.async = False
                        xml.setProperty "SelectionLanguage", "XPath"
                        xml.load configPath

                        If xml.parseError.errorCode = 0 Then

                            Dim node

                            ' BaseUri を更新
                            If baseUri <> "" Then
                                Set node = xml.selectSingleNode("//CommonSection/BaseUri")
                                If Not node Is Nothing Then node.text = baseUri
                            End If

                            ' FacilityHash を更新
                            If facilityHash <> "" Then
                                Set node = xml.selectSingleNode("//CommonSection/FacilityHash")
                                If Not node Is Nothing Then node.text = facilityHash
                            End If

                            ' ConverterBaseUri を更新
                            If converterBase <> "" Then
                                Set node = xml.selectSingleNode("//CommonSection/ConverterBaseUri")
                                If Not node Is Nothing Then node.text = converterBase
                            End If

                            ' クライアント証明書フラグ: 使用しない (0) の場合は値を空にする
                            If useCert = "0" Then
                                Set node = xml.selectSingleNode("//CommonSection/ClientCertificateSearchValue1")
                                If Not node Is Nothing Then node.text = ""
                                Set node = xml.selectSingleNode("//CommonSection/ClientCertificateSearchValue2")
                                If Not node Is Nothing Then node.text = ""
                            End If

                            xml.save configPath

                        End If
                    End If

                End If
            End If

        End If