/* ##########################################
フロー内でglobal.getしているので取り扱い注意
############################################# */
function console_debug_log(buf) {
    //    console.log(buf);
    }
    
    function Bytes2HexString(retBuf) {
        let hexs = "";
        for (var k = 0; k < retBuf.length; k++) {
            let hex = (retBuf[k]).toString(16);
            if (hex.length === 1) {
                hexs = hexs + '0';
            }
            hexs = hexs + hex.toUpperCase() + ' ';
        }
        return hexs;
    }
    
    function getResponseTelegram(sockettype) {
    console_debug_log('-------------------------->sockettype : [' + sockettype + ']');
        var commonLib = require('./CommonLib.js');
        var setting = commonLib.getSettings();
        
        // 応答電文Listの設定を取得する
        telegramList = setting.response_telegram;
        if (telegramList === undefined || telegramList === null || telegramList === '') {
            console.log('ifedge_setting : response_telegram none.');
            return null;
        }
        
        // sockettypeより、応答電文の設定を取得する
        var responseTelegram;
        for (var k=0; k<telegramList.length; k++) {
    console_debug_log('-------------------------->getResponseTelegram->socket-type : [' + telegramList[k]["socket-type"] + ']');
            if (telegramList[k]["socket-type"] !== undefined && telegramList[k]["socket-type"] === sockettype) {
                responseTelegram = telegramList[k];
                break;
            }
        }
        if (responseTelegram === undefined || responseTelegram === null || responseTelegram === '') {
            console.log('ifedge_setting : response_telegram->socket-type[' + sockettype + '] none.');
            return null;
        }
        
        return responseTelegram;
    }
    
    function checkValidation(sockettype, buf, count, datatype) {
        // 応答電文の設定を取得する
        var responseTelegram = getResponseTelegram(sockettype);
        if (responseTelegram === null || responseTelegram === '') {
            return false;
        }
        
        // 電文長の項目名を取得する
        var length_name = responseTelegram.length_name;
        if (length_name === undefined || length_name === null || length_name === '') {
            console.log('ifedge_setting : length_name none.');
            return true;
        }
        
        // 電文頭の長の追加フラッグを取得する
        var header_length_included = responseTelegram.header_length_included;
        var headerLength = 0;
        if (header_length_included !== undefined && header_length_included !== null && header_length_included !== '' && header_length_included !== false) {
    console_debug_log('checkValidation->header_length_included : [' + header_length_included + ']');
            // 電文頭の長をを取得する
            // 正常応答電文の設定を取得する
            var responseInfo = responseTelegram.response_success;
            if (responseInfo === undefined || responseInfo === null || responseInfo === '') {
                console.log('ifedge_setting : response_success none.');
                return false;
            }
            
            // 電文頭長さの設定を取得する
            headerLength = responseInfo.header_length;
            if (headerLength === undefined || headerLength === null || headerLength === '') {
                console.log('ifedge_setting : header_length none.');
                return false;
            }
        }
        
        // 電文長の項目名より、電文長の値を取得する
        length = getValueFromName(responseTelegram, buf, length_name, true);
    console_debug_log('checkValidation->length : [' + length * 1 + '] buf.length=[' + buf.length + ']');
    
        // 電文長のチェック
        if (!isFinite(length)) {
            return false;
        }
        if (buf.length !== length * 1 + headerLength) {
            return false;
        }
    
        return true;
    }
    
    function setValueFromName(responseTelegram, buf, name, value, responseType) {
        var commonLib = require('./CommonLib.js');
        var valBuf = commonLib.encodeString(value, 'shift-jis');
    
        var colInfo = getColInfoFromName(responseTelegram, buf, name, responseType);
    
        if (!colInfo) return false;
    
        valBuf.copy(buf, colInfo.start, 0, colInfo.start + colInfo.length);
    
        return true;
    }
    
    function getValueFromName(responseTelegram, buf, name, responseType) {
        var colInfo = getColInfoFromName(responseTelegram, buf, name, responseType);
    
        if (colInfo) {
            return getValue(buf, colInfo.start, colInfo.length);
        }
    
        return '';
    }
    
    function getColInfoFromName(responseTelegram, buf, name, responseType) {
        // 正常応答電文の設定を取得する
        var responseInfo = responseTelegram.response_success;
        if (responseType === false) {
            // 異常応答電文の設定を取得する
            var failureResponseInfo = responseTelegram.response_failure;
            if (failureResponseInfo !== undefined && failureResponseInfo !== null && failureResponseInfo !== '') {
                responseInfo = failureResponseInfo;
            }
        }
        if (responseInfo === undefined || responseInfo === null || responseInfo === '') {
            console.log('ifedge_setting : response_success/response_failure none.');
            return null;
        }
        
        // 電文頭内容の設定を取得する
        var header = responseInfo.header;
        if (header === undefined || header === null || header === '') {
            console.log('ifedge_setting : header none.');
            return null;
        }
        
        var ret = {};
    
        var col = 0;
    
        for (var i = 0; i < header.length; i++) {
            if (header[i].name === name) {
                ret.start = col;
                ret.length = header[i].length;
                return ret;
            }
            col += header[i].length;
        }
    
        return null;
    }
    
    function getValue(buf, start, len) {
        var commonLib = require('./CommonLib.js');
    
        //console.log(buf.slice(start, start + len));
        str = commonLib.decodeBuffer(buf.slice(start, start + len), 'shift-jis');
        return str;
    }
    
    function returnRetryMax(sockettype){
        var responseTelegram = getResponseTelegram(sockettype);
        if (responseTelegram === null || responseTelegram === '') {
            return null;
        }
        var responseInfo = responseTelegram.retryMax;
        return responseInfo;
    }

    function returnTimeout(sockettype){
        var responseTelegram = getResponseTelegram(sockettype);
        if (responseTelegram === null || responseTelegram === '') {
            return null;
        }
        var responseInfo = responseTelegram.timeout;
        return responseInfo;
    }

    function createResponseRetry(sockettype, buf) {
        require('date-utils');
        var commonLib = require('./CommonLib.js');
    console_debug_log('createResponseRetry->buf [' + commonLib.decodeBuffer(buf, 'shift-jis').replace(/\r/g, ' ') + ']');
    
        // 応答電文の設定を取得する
        var responseTelegram = getResponseTelegram(sockettype);
        if (responseTelegram === null || responseTelegram === '') {
            return null;
        }

        // 正常応答電文の設定を取得する
        var responseInfo = responseTelegram.response_success;
        if (responseInfo === undefined || responseInfo === null || responseInfo === '') {
            console.log('ifedge_setting : response_success/response_failure none.');
            return null;
        }
    
        // 電文頭内容と電文頭長さの設定を取得する
        var headerLength = responseInfo.header_length;
        var header = responseInfo.header;
        if (header === undefined || header === null || header === '' ||
            headerLength === undefined || headerLength === null || headerLength === '') {
            console.log('ifedge_setting : header/header_length none.');
            return null;
        }
    
        var retBuf = Buffer.alloc(headerLength);
        buf.copy(retBuf, 0, 0, headerLength);
    console_debug_log('createResponseRetry->retBuf[' + Bytes2HexString(retBuf) + ']');
    console_debug_log('createResponseRetry->retBuf[' + commonLib.decodeBuffer(retBuf, 'shift-jis').replace(/\r/g, ' ') + ']');
        var dt = new Date();
        var start = 0;
        for (var i = 0; i < header.length; i++) {
    console_debug_log('createResponseRetry->i=[' + i + ']start=['+ start + ']----------------------------------------------');
    console_debug_log('createResponseRetry->name=[' + header[i].name + ']length=['+ header[i].length + ']value=[' + header[i].value + ']');
            // 応答電文項目の長さのチェック
            if (header[i].length === undefined || header[i].length === null || header[i].length === '') {
                console.log('ifedge_setting : header[' + header[i].name + '].length none.');
                return null;
            }
    
            // 応答電文項目の値のチェック
            if (header[i].value !== undefined && header[i].value !== null || header[i].value !== '') {
                if (header[i].value.startsWith('0x') || header[i].value.startsWith('0X')) {
                    // 2進数の場合、Unicodeコードを1文字に変換する
                    (commonLib.encodeString(String.fromCharCode(commonLib.Str2Hex(header[i].value)), 'shift-jis')).copy(retBuf, start, 0, header[i].length);
                } else if (header[i].value === '$DATE') {
                    // 日付と時刻の場合、フォーマットのチェック
                    if (header[i].format === undefined && header[i].format === null || header[i].format === '') {
                        console.log('ifedge_setting : header[' + header[i].name + '].format none.');
                        return null;
                    }
                    // 設定された書式に従って現在の日付書式を設定します
                    (commonLib.encodeString(dt.toFormat(header[i].format), 'shift-jis')).copy(retBuf, start, 0, header[i].length);
                } else if (header[i].value === '$TYPENAME') {
                    // 応答コード（$TYPENAME）を取得する
                    var responseCode;
                    // 再送として設定
                    responseCode = responseTelegram.retry_value;
                    if (responseCode === undefined || responseCode === null || responseCode === '') {
                        console.log('ifedge_setting : retry_value none.');
                        return null;
                    }
                    // 応答コードを設定します
                    (commonLib.encodeString(responseCode, 'shift-jis')).copy(retBuf, start, 0, header[i].length);
                } else {
                    // そのた場合、そのまま
                    (commonLib.encodeString(header[i].value, 'shift-jis')).copy(retBuf, start, 0, header[i].length);
                }
            }
    
    console_debug_log('createResponseRetry->retBuf[' + Bytes2HexString(retBuf) + ']');
    console_debug_log('createResponseRetry->retBuf[' + commonLib.decodeBuffer(retBuf, 'shift-jis').replace(/\r/g, ' ') + ']');
    
            start = start + header[i].length;
        }
    
        return retBuf;
    }
    
    function createResponse(sockettype, buf, responseType) {
        require('date-utils');
        var commonLib = require('./CommonLib.js');
    console_debug_log('createResponse->buf [' + commonLib.decodeBuffer(buf, 'shift-jis').replace(/\r/g, ' ') + ']');
    console_debug_log('createResponse->responseType=[' + responseType + ']');
    
        // 応答電文の設定を取得する
        var responseTelegram = getResponseTelegram(sockettype);
        if (responseTelegram === null || responseTelegram === '') {
            return null;
        }
    
        // 正常応答電文の設定を取得する
        var responseInfo = responseTelegram.response_success;
        if (responseType === false) {
            // 異常応答電文の設定を取得する
            var failureResponseInfo = responseTelegram.response_failure;
            if (failureResponseInfo !== undefined && failureResponseInfo !== null && failureResponseInfo !== '') {
                responseInfo = failureResponseInfo;
            }
        }
        if (responseInfo === undefined || responseInfo === null || responseInfo === '') {
            console.log('ifedge_setting : response_success/response_failure none.');
            return null;
        }
    
        // 電文頭内容と電文頭長さの設定を取得する
        var headerLength = responseInfo.header_length;
        var header = responseInfo.header;
        if (header === undefined || header === null || header === '' ||
            headerLength === undefined || headerLength === null || headerLength === '') {
            console.log('ifedge_setting : header/header_length none.');
            return null;
        }
    
        var retBuf = Buffer.alloc(headerLength);
        buf.copy(retBuf, 0, 0, headerLength);
    console_debug_log('createResponse->retBuf[' + Bytes2HexString(retBuf) + ']');
    console_debug_log('createResponse->retBuf[' + commonLib.decodeBuffer(retBuf, 'shift-jis').replace(/\r/g, ' ') + ']');
        var dt = new Date();
        var start = 0;
        for (var i = 0; i < header.length; i++) {
    console_debug_log('createResponse->i=[' + i + ']start=['+ start + ']----------------------------------------------');
    console_debug_log('createResponse->name=[' + header[i].name + ']length=['+ header[i].length + ']value=[' + header[i].value + ']');
            // 応答電文項目の長さのチェック
            if (header[i].length === undefined || header[i].length === null || header[i].length === '') {
                console.log('ifedge_setting : header[' + header[i].name + '].length none.');
                return null;
            }
    
            // 応答電文項目の値のチェック
            if (header[i].value !== undefined && header[i].value !== null || header[i].value !== '') {
                if (header[i].value.startsWith('0x') || header[i].value.startsWith('0X')) {
                    // 2進数の場合、Unicodeコードを1文字に変換する
                    (commonLib.encodeString(String.fromCharCode(commonLib.Str2Hex(header[i].value)), 'shift-jis')).copy(retBuf, start, 0, header[i].length);
                } else if (header[i].value === '$DATE') {
                    // 日付と時刻の場合、フォーマットのチェック
                    if (header[i].format === undefined && header[i].format === null || header[i].format === '') {
                        console.log('ifedge_setting : header[' + header[i].name + '].format none.');
                        return null;
                    }
                    // 設定された書式に従って現在の日付書式を設定します
                    (commonLib.encodeString(dt.toFormat(header[i].format), 'shift-jis')).copy(retBuf, start, 0, header[i].length);
                } else if (header[i].value === '$TYPENAME') {
                    // 応答コード（$TYPENAME）を取得する
                    var responseCode;
                    if (responseType === true) {
                        // 正常
                        responseCode = responseTelegram.type_name_success;
                    } else {
                        // 異常
                        responseCode = responseTelegram.type_name_failure;
                    }
                    if (responseCode === undefined || responseCode === null || responseCode === '') {
                        console.log('ifedge_setting : type_name_success/type_name_failure none.');
                        return null;
                    }
                    // 応答コードを設定します
                    (commonLib.encodeString(responseCode, 'shift-jis')).copy(retBuf, start, 0, header[i].length);
                } else {
                    // そのた場合、そのまま
                    (commonLib.encodeString(header[i].value, 'shift-jis')).copy(retBuf, start, 0, header[i].length);
                }
            }
    
    console_debug_log('createResponse->retBuf[' + Bytes2HexString(retBuf) + ']');
    console_debug_log('createResponse->retBuf[' + commonLib.decodeBuffer(retBuf, 'shift-jis').replace(/\r/g, ' ') + ']');
    
            start = start + header[i].length;
        }
    
        return retBuf;
    }
    

var createErrorResponse = function(sockettype, buf, errorCode) {
    require('date-utils');
    var commonLib = require('./CommonLib.js');

    // 応答電文の設定を取得する
    var responseTelegram = getResponseTelegram(sockettype);
    if (responseTelegram === null || responseTelegram === '') {
        return null;
    }
    // 異常応答電文の設定を取得する
    var responseInfo;
    var failureResponseInfo = responseTelegram.response_failure;
    if (failureResponseInfo !== undefined && failureResponseInfo !== null && failureResponseInfo !== '') {
        responseInfo = failureResponseInfo;
    }
    if (responseInfo === undefined || responseInfo === null || responseInfo === '') {
        console.log('ifedge_setting : response_success/response_failure none.');
        return null;
    }

    // 電文頭内容と電文頭長さの設定を取得する
    var headerLength = responseInfo.header_length;
    var header = responseInfo.header;
    if (header === undefined || header === null || header === '' ||
        headerLength === undefined || headerLength === null || headerLength === '') {
        console.log('ifedge_setting : header/header_length none.');
        return null;
    }

    var retBuf = Buffer.alloc(headerLength);
    if(buf){
        buf.copy(retBuf, 0, 0, headerLength);
    }
    
    var dt = new Date();
    var start = 0;
    for (var i = 0; i < header.length; i++) {
        // 応答電文項目の長さのチェック
        if (header[i].length === undefined || header[i].length === null || header[i].length === '') {
            console.log('ifedge_setting : header[' + header[i].name + '].length none.');
            return null;
        }

        // 応答電文項目の値のチェック
        if (header[i].value !== undefined && header[i].value !== null || header[i].value !== '') {
            if (header[i].value.startsWith('0x') || header[i].value.startsWith('0X')) {
                // 2進数の場合、Unicodeコードを1文字に変換する
                (commonLib.encodeString(String.fromCharCode(commonLib.Str2Hex(header[i].value)), 'shift-jis')).copy(retBuf, start, 0, header[i].length);
            } else if (header[i].value === '$DATE') {
                // 日付と時刻の場合、フォーマットのチェック
                if (header[i].format === undefined && header[i].format === null || header[i].format === '') {
                    console.log('ifedge_setting : header[' + header[i].name + '].format none.');
                    return null;
                }
                // 設定された書式に従って現在の日付書式を設定します
                (commonLib.encodeString(dt.toFormat(header[i].format), 'shift-jis')).copy(retBuf, start, 0, header[i].length);
            } else if (header[i].value === '$TYPENAME') {
            	// 応答コード（$TYPENAME）を取得する
            	var responseCode;
            	if (responseType === true) {
            		// 正常
            		responseCode = responseTelegram.type_name_success;
            	} else {
            		// 異常
            		responseCode = responseTelegram.type_name_failure;
            	}
				if (responseCode === undefined || responseCode === null || responseCode === '') {
		            console.log('ifedge_setting : type_name_success/type_name_failure none.');
		            return null;
				}
                // 応答コードを設定します
                (commonLib.encodeString(responseCode, 'shift-jis')).copy(retBuf, start, 0, header[i].length);
            } else if (header[i].name === 'ErrorCode') {
                // エラーコードの場合、エラーコードを返す
                (commonLib.encodeString(errorCode, 'shift-jis')).copy(retBuf, start, 0, header[i].length);
            } else {
                // そのた場合、そのまま
                (commonLib.encodeString(header[i].value, 'shift-jis')).copy(retBuf, start, 0, header[i].length);
            }
        }
        start = start + header[i].length;
    }
    return retBuf;
}

    exports.checkValidation = function (sockettype, buf, count, datatype) {
        return checkValidation(sockettype, buf, count, datatype);
    }
    
    exports.isFirst = function (sockettype, buf) {
        return true;
    }
    
    exports.isEnd = function (sockettype, buf) {
        return true;
    }
    
    exports.getMessageCount = function (sockettype, buf) {
        return 1;
    }
    
    exports.returnRetryMax = function (sockettype) {
        return returnRetryMax(sockettype);
    }

    exports.returnTimeout = function (sockettype) {
        return returnTimeout(sockettype);
    }

    exports.createResponseRetry = function (sockettype, buf) {
        return createResponseRetry(sockettype, buf);
    }
    
    exports.createResponse = function (sockettype, buf, responseType) {
        return createResponse(sockettype, buf, responseType);
    }

    exports.createErrorResponse = function (sockettype, buf, errorCode) {
        return createErrorResponse(sockettype, buf, errorCode);
    }

    exports.getResponseTelegram = function (sockettype) {
        return getResponseTelegram(sockettype);
    }

    
    exports.isRetry = function (sockettype, buf) {
        var commonLib = require('./CommonLib.js');
    console_debug_log('isRetry->buf [' + commonLib.decodeBuffer(buf, 'shift-jis').replace(/\r/g, ' ') + ']');
    
        // 応答電文の設定を取得する
        var responseTelegram = getResponseTelegram(sockettype);
        if (responseTelegram === null || responseTelegram === '') {
            return false;
        }
        
        // 応答種別の項目名を取得する
        var type_name = responseTelegram.type_name;
        // 再送要求の応答種別の値を取得する。（例えば：N1）
        var retry_value = responseTelegram.retry_value;
        
        // 応答種別と再送要求が無しの場合
        if (type_name === undefined || type_name === null || type_name === '' ||
            retry_value === undefined || retry_value === null || retry_value === '') {
            console.log('ifedge_setting : type_name/retry_value none.');
            return false;
        }
        
    console_debug_log('isRetry->type_name=[' + type_name + ']');
    console_debug_log('isRetry->retry_value=[' + retry_value + ']');
    
        // add 2022-10-08 bug 7710 【富士通指摘事項】IFエッジでエラー受信時、タイムアウト時の挙動について 孫 start
        // 応答種別がは複数ですか
        var arr_flg = Array.isArray(retry_value);
        if (arr_flg) {
            // 複数場合
            // 応答種別が再送要求か？
            if (retry_value[0].startsWith('0x') || retry_value[0].startsWith('0X')) {
                var colInfo = getColInfoFromName(responseTelegram, buf, type_name, true);
                var responseType = buf[colInfo.start];
    console_debug_log('isRetry->responseType=[' + responseType.toString(16) + ']');
                for (var i = 0; i < retry_value.length; i++) {
                    if (responseType === commonLib.Str2Hex(retry_value[i])) {
    console_debug_log('isRetry->check result=[true]');
                        return true;
                    }
                }
            } else {
                var responseType = getValueFromName(responseTelegram, buf, type_name, true);
    console_debug_log('isRetry->responseType=[' + responseType + ']');
                for (var i = 0; i < retry_value.length; i++) {
                   if (responseType === retry_value[i]) {
    console_debug_log('isRetry->check result=[true]');
                        return true;
                    }
                }
            }
        } else {
            // 単数場合
        // add 2022-10-08 bug 7710 【富士通指摘事項】IFエッジでエラー受信時、タイムアウト時の挙動について 孫 end
    
            // 応答種別が再送要求か？
            if (retry_value.startsWith('0x') || retry_value.startsWith('0X')) {
                var colInfo = getColInfoFromName(responseTelegram, buf, type_name, true);
    console_debug_log('isRetry->responseType=[' + buf[colInfo.start].toString(16) + ']');
                if (commonLib.Str2Hex(retry_value) === buf[colInfo.start]) {
    console_debug_log('isRetry->check result=[true]');
                    return true;
                }
            } else {
    console_debug_log('isRetry->responseType=[' + getValueFromName(responseTelegram, buf, type_name, true) + ']');
                if (getValueFromName(responseTelegram, buf, type_name, true) === retry_value) {
    console_debug_log('isRetry->check result=[true]');
                    return true;
                }
            }
    
        // add 2022-10-08 bug 7710 【富士通指摘事項】IFエッジでエラー受信時、タイムアウト時の挙動について 孫 start
        }
        // add 2022-10-08 bug 7710 【富士通指摘事項】IFエッジでエラー受信時、タイムアウト時の挙動について 孫 end
    
        return false;
    }
    exports.isNormalData = function (sockettype, buf) {
        var commonLib = require('./CommonLib.js');
    console_debug_log('isNormalData->buf [' + commonLib.decodeBuffer(buf, 'shift-jis').replace(/\r/g, ' ') + ']');
    
        // 応答電文の設定を取得する
        var responseTelegram = getResponseTelegram(sockettype);
        if (responseTelegram === null || responseTelegram === '') {
            return false;
        }
        
        // 応答種別の項目名を取得する
        var type_name = responseTelegram.type_name;
        // 正常の応答種別の値を取得する。
        var type_name_success = responseTelegram.type_name_success;
    
        // 応答種別と正常が無しの場合
        if (type_name === undefined || type_name === null || type_name === '' ||
            type_name_success === undefined || type_name_success === null || type_name_success === '') {
                console.log('ifedge_setting : type_name_success none.');
                return null;
        }
    
    console_debug_log('isNormalData->type_name=[' + type_name + ']');
    console_debug_log('isNormalData->type_name_success=[' + type_name_success + ']');
    
        // 応答種別がは複数ですか
        var arr_flg = Array.isArray(type_name_success);
        if (arr_flg) {
            // 複数場合
            // 応答種別の値を取得する、応答種別が異常か？
            if (type_name_success[0].startsWith('0x') || type_name_success[0].startsWith('0X')) {
                var colInfo = getColInfoFromName(responseTelegram, buf, type_name, true);
                var responseType = buf[colInfo.start];
    console_debug_log('isNormalData->responseType=[' + responseType.toString(16) + ']');
                for (var i = 0; i < type_name_success.length; i++) {
                    if (responseType === commonLib.Str2Hex(type_name_success[i])) {
    console_debug_log('isNormalData->check result=[true]');
                        return true;
                    }
                }
            } else {
                var responseType = getValueFromName(responseTelegram, buf, type_name, true);
    console_debug_log('isNormalData->responseType=[' + responseType + ']');
                for (var i = 0; i < type_name_success.length; i++) {
                   if (responseType === type_name_success[i]) {
    console_debug_log('isNormalData->check result=[true]');
                        return true;
                    }
                }
            }
        
        } else {
            // 単数場合
            // 応答種別の値を取得する、応答種別が異常か？
            if (type_name_success.startsWith('0x') || type_name_success.startsWith('0X')) {
                var colInfo = getColInfoFromName(responseTelegram, buf, type_name, true);
    console_debug_log('isNormalData->responseType=[' + buf[colInfo.start].toString(16) + ']');
                if (commonLib.Str2Hex(type_name_success) === buf[colInfo.start]) {
    console_debug_log('isNormalData->check result=[true]');
                    return true;
                }
            } else {
    console_debug_log('isNormalData->responseType=[' + getValueFromName(responseTelegram, buf, type_name, true) + ']');
                if (getValueFromName(responseTelegram, buf, type_name, true) === type_name_success) {
    console_debug_log('isNormalData->check result=[true]');
                    return true;
                }
            }
        }
        return false;
    }
    
    exports.isAbnormalData = function (sockettype, buf) {
        var commonLib = require('./CommonLib.js');
    console_debug_log('isAbnormalData->buf [' + commonLib.decodeBuffer(buf, 'shift-jis').replace(/\r/g, ' ') + ']');
    
        // 応答電文の設定を取得する
        var responseTelegram = getResponseTelegram(sockettype);
        if (responseTelegram === null || responseTelegram === '') {
            return false;
        }
        
        // 応答種別の項目名を取得する
        var type_name = responseTelegram.type_name;
        // 異常の応答種別の値を取得する。（例えば：NG,N3,N4）
        var abnormal_value = responseTelegram.abnormal_value;
    
        // 応答種別と異常が無しの場合
        if (type_name === undefined || type_name === null || type_name === '' ||
            abnormal_value === undefined || abnormal_value === null || abnormal_value === '') {
            console.log('ifedge_setting : type_name/abnormal_value none.');
            return false;
        }
    
    console_debug_log('isAbnormalData->type_name=[' + type_name + ']');
    console_debug_log('isAbnormalData->abnormal_value=[' + abnormal_value + ']');
    
        // add 2022-10-08 bug 7710 【富士通指摘事項】IFエッジでエラー受信時、タイムアウト時の挙動について 孫 start
        // 応答種別がは複数ですか
        var arr_flg = Array.isArray(abnormal_value);
        if (arr_flg) {
            // 複数場合
        // add 2022-10-08 bug 7710 【富士通指摘事項】IFエッジでエラー受信時、タイムアウト時の挙動について 孫 end
    
            // 応答種別の値を取得する、応答種別が異常か？
            if (abnormal_value[0].startsWith('0x') || abnormal_value[0].startsWith('0X')) {
                var colInfo = getColInfoFromName(responseTelegram, buf, type_name, true);
                var responseType = buf[colInfo.start];
    console_debug_log('isAbnormalData->responseType=[' + responseType.toString(16) + ']');
                for (var i = 0; i < abnormal_value.length; i++) {
                    if (responseType === commonLib.Str2Hex(abnormal_value[i])) {
    console_debug_log('isAbnormalData->check result=[true]');
                        return true;
                    }
                }
            } else {
                var responseType = getValueFromName(responseTelegram, buf, type_name, true);
    console_debug_log('isAbnormalData->responseType=[' + responseType + ']');
                for (var i = 0; i < abnormal_value.length; i++) {
                   if (responseType === abnormal_value[i]) {
    console_debug_log('isAbnormalData->check result=[true]');
                        return true;
                    }
                }
            }
        
        // add 2022-10-08 bug 7710 【富士通指摘事項】IFエッジでエラー受信時、タイムアウト時の挙動について 孫 start
        } else {
            // 単数場合
            // 応答種別の値を取得する、応答種別が異常か？
            if (abnormal_value.startsWith('0x') || abnormal_value.startsWith('0X')) {
                var colInfo = getColInfoFromName(responseTelegram, buf, type_name, true);
    console_debug_log('isAbnormalData->responseType=[' + buf[colInfo.start].toString(16) + ']');
                if (commonLib.Str2Hex(abnormal_value) === buf[colInfo.start]) {
    console_debug_log('isAbnormalData->check result=[true]');
                    return true;
                }
            } else {
    console_debug_log('isAbnormalData->responseType=[' + getValueFromName(responseTelegram, buf, type_name, true) + ']');
                if (getValueFromName(responseTelegram, buf, type_name, true) === abnormal_value) {
    console_debug_log('isAbnormalData->check result=[true]');
                    return true;
                }
            }
        }
        // add 2022-10-08 bug 7710 【富士通指摘事項】IFエッジでエラー受信時、タイムアウト時の挙動について 孫 end
    
        return false;
    }
    
    exports.isSkip = function (sockettype, buf) {
        var commonLib = require('./CommonLib.js');
    console_debug_log('isSkip->buf [' + commonLib.decodeBuffer(buf, 'shift-jis').replace(/\r/g, ' ') + ']');
    
        // 応答電文の設定を取得する
        var responseTelegram = getResponseTelegram(sockettype);
        if (responseTelegram === null || responseTelegram === '') {
            return false;
        }
        
        // 応答種別の項目名を取得する
        var type_name = responseTelegram.type_name;
        // スキップの応答種別の値を取得する。（例えば：N2）
        var skip_value = responseTelegram.skip_value;
    
        // 応答種別とスキップが無しの場合
        if (type_name === undefined || type_name === null || type_name === '' ||
            skip_value === undefined || skip_value === null || skip_value === '') {
            console.log('ifedge_setting : type_name/skip_value none.');
            return false;
        }
        
    console_debug_log('isSkip->type_name=[' + type_name + ']');
    console_debug_log('isSkip->skip_value=[' + skip_value + ']');
    
        // add 2022-10-08 bug 7710 【富士通指摘事項】IFエッジでエラー受信時、タイムアウト時の挙動について 孫 start
        // 応答種別がは複数ですか
        var arr_flg = Array.isArray(skip_value);
        if (arr_flg) {
            // 複数場合
            // 応答種別がスキップか？
            if (skip_value[0].startsWith('0x') || skip_value[0].startsWith('0X')) {
                var colInfo = getColInfoFromName(responseTelegram, buf, type_name, true);
                var responseType = buf[colInfo.start];
    console_debug_log('isSkip->responseType=[' + responseType.toString(16) + ']');
                for (var i = 0; i < skip_value.length; i++) {
                    if (responseType === commonLib.Str2Hex(skip_value[i])) {
    console_debug_log('isSkip->check result=[true]');
                        return true;
                    }
                }
            } else {
                var responseType = getValueFromName(responseTelegram, buf, type_name, true);
    console_debug_log('isSkip->responseType=[' + responseType + ']');
                for (var i = 0; i < skip_value.length; i++) {
                   if (responseType === skip_value[i]) {
    console_debug_log('isSkip->check result=[true]');
                        return true;
                    }
                }
            }
        } else {
            // 単数場合
        // add 2022-10-08 bug 7710 【富士通指摘事項】IFエッジでエラー受信時、タイムアウト時の挙動について 孫 end
    
            // 応答種別がスキップか？
            if (skip_value.startsWith('0x') || skip_value.startsWith('0X')) {
                var colInfo = getColInfoFromName(responseTelegram, buf, type_name, true);
    console_debug_log('isSkip->responseType=[' + buf[colInfo.start].toString(16) + ']');
                if (commonLib.Str2Hex(skip_value) === buf[colInfo.start]) {
    console_debug_log('isSkip->check result=[true]');
                    return true;
                }
            } else {
    console_debug_log('isSkip->responseType=[' + getValueFromName(responseTelegram, buf, type_name, true) + ']');
                if (getValueFromName(responseTelegram, buf, type_name, true) === skip_value) {
    console_debug_log('isSkip->check result=[true]');
                    return true;
                }
            }
    
        // add 2022-10-08 bug 7710 【富士通指摘事項】IFエッジでエラー受信時、タイムアウト時の挙動について 孫 start
        }
        // add 2022-10-08 bug 7710 【富士通指摘事項】IFエッジでエラー受信時、タイムアウト時の挙動について 孫 end
    
        return false;
    }
    
    exports.getLength = function (sockettype, buf) {
        // 応答電文の設定を取得する
        var responseTelegram = getResponseTelegram(sockettype);
        if (responseTelegram === null || responseTelegram === '') {
            return 0;
        }
        
        // 電文長の項目名を取得する
        var length_name = responseTelegram.length_name;
        if (length_name === undefined || length_name === null || length_name === '') {
            console.log('ifedge_setting : length_name none.');
            return 0;
        }
        
        // 電文長の項目名より、電文長の値を取得する
        length = getValueFromName(responseTelegram, buf, length_name, true);
    console_debug_log('getLength->length : [' + length * 1 + ']');
    
        return length * 1;
    }
    
    exports.getHeaderLength = function (sockettype) {
        // 応答電文の設定を取得する
        var responseTelegram = getResponseTelegram(sockettype);
        if (responseTelegram === null || responseTelegram === '') {
            return 0;
        }
    
        // 正常応答電文の設定を取得する
        var responseInfo = responseTelegram.response_success;
        if (responseInfo === undefined || responseInfo === null || responseInfo === '') {
            console.log('ifedge_setting : response_success none.');
            return 0;
        }
    
        // 電文頭内容と電文頭長さの設定を取得する
        var headerLength = responseInfo.header_length;
    console_debug_log('getHeaderLength->headerLength : [' + headerLength + ']');
    
        return headerLength;
    }
    
    exports.isUseCoopOrdNo = function (sockettype) {
        // 応答電文の設定を取得する
        var responseTelegram = getResponseTelegram(sockettype);
        if (responseTelegram === null || responseTelegram === '') {
            return false;
        }
    
        var colInfo = getColInfoFromName(responseTelegram, null, 'IsUseCoopOrdNo', true);
    
        if (colInfo) {
            return true;
        }
    
        return false;
    }
    
    exports.getHeaderLengthByIncluded = function (sockettype, isSuccess) {
        // 応答電文の設定を取得する
        var responseTelegram = getResponseTelegram(sockettype);
        if (responseTelegram === null || responseTelegram === '') {
            return 0;
        }
    
        // 電文頭の長の追加フラッグを取得する
        var header_length_included = responseTelegram.header_length_included;
        if (header_length_included !== undefined && header_length_included !== null && header_length_included !== '' && header_length_included !== false) {
            console_debug_log('checkValidation->header_length_included : [' + header_length_included + ']');
    
            if (isSuccess) {
                var responseInfo = responseTelegram.response_success;
                if (responseInfo === undefined || responseInfo === null || responseInfo === '') {
                    console.log('ifedge_setting : response_success none.');
                    return 0;
                }
            } else {
                 var responseInfo = responseTelegram.response_failure;
                 if (responseInfo === undefined || responseInfo === null || responseInfo === '') {
                     console.log('ifedge_setting : response_failure none.');
                     return 0;
                 }
            }
            // 電文頭内容と電文頭長さの設定を取得する
            var headerLength = responseInfo.header_length;
            console_debug_log('getHeaderLength->headerLength : [' + headerLength + ']');
            
            if (headerLength === undefined || headerLength === null || headerLength === '') {
                console.log('ifedge_setting : headerLength none.');
                return 0;
            }
    
            return headerLength;
        }
        return 0;
    }