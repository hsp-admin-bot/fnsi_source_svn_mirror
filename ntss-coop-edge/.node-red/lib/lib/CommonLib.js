/* ##########################################
フロー内でglobal.getしているので取り扱い注意
############################################# */

function isExist(path) {
    var fs = require('fs');

    try {
        fs.statSync(path);
    } catch (err) {
        if (err.code === 'ENOENT') {
            return false;
        } else {
            throw new Error('Exeption occured at File Exist check isExist');
        }
    }
    return true;
}

exports.isExist = function (path) {
    return isExist(path);
}

exports.createDummyFile = function(dirPath) {
    var fs = require('fs');
    var path = dirPath + '/dummy.dat';


    if (isExist(path) === false) {
        try {
            fs.writeFileSync(path, '');
        } catch (err) {
            throw new Error('Exeption occured at createDummyFile');
        }
    }

    return path;
}


exports.getSettings = function() {
    var fs = require('fs');
    var settingPath = process.env.NTSS_IF_CONF_SETTING;

    try {
        var setting = JSON.parse(fs.readFileSync(settingPath, 'utf-8'));
    } catch (error) {
        throw error;
    }

    return setting;
}

exports.encodeString = function(cstr, code) {
    var iconv = require('iconv-lite');

    // var buffer = Buffer.from(cstr);

    conv = iconv.encode(cstr, code);

    return conv;
}

exports.decodeBuffer = function(buf, code){
    var iconv = require('iconv-lite');
    var conv;

    conv = iconv.decode(buf, code);

    return conv;
}

function getTimeStamp() {
    require('date-utils');
    // yyyyMMddHHmmssSSS形式
    var dt = new Date();
    var formatDate = dt.toFormat("YYYYMMDDHH24MISSLL");
    return formatDate;
}

exports.createTempFileName = function(coopCd, protocol) {

    // 接尾辞は固定
    var suffix = '.dmp';

    // yyyyMMddHHmmssSSS_[電文種別]_[通信形式].dmp
    var formatDate = getTimeStamp();
    var fileName = formatDate + '_' + coopCd + '_' + protocol + suffix;

    return fileName;
}

/**
 * ユニークキー
 */
exports.getTempUniqueKey = function() {
    // yyyyMMddHHmmssSSSでユニークキーとする
    return getTimeStamp();
}

exports.isProcessSkip = function(kbn) {
    var path = process.env.NTSS_IF_CONF;

    if (kbn === 's') {
        path += '/send.skip';
    } else if (kbn === 'r') {
        path += '/receive.skip';
    } else if (kbn === 'd') {
        path += '/distribute.skip';
    }
    
    return isExist(path);
}


exports.setProcessSkip = function(kbn) {
    var fs = require('fs');
    var path = process.env.NTSS_IF_CONF;

    if (kbn === 's') {
        path += '/send.skip';
    } else if (kbn === 'r') {
        path += '/receive.skip';
    } else if (kbn === 'd') {
        path += '/distribute.skip';
    }
    
    if (isExist(path) === false) {
        try {
            fs.writeFileSync(path, '');
        } catch (err) {
            throw new Error('Exeption occured at setProcessSkip');
        }
    }

    return true;
}

exports.cancelProcessSkip = function(kbn) {
    var fs = require('fs');
    var path = process.env.NTSS_IF_CONF;

    if (kbn === 's') {
        path += '/send.skip';
    } else if (kbn === 'r') {
        path += '/receive.skip';
    } else if (kbn === 'd') {
        path += '/distribute.skip';
    }

    if (isExist(path) === true) {
        try {
            fs.unlinkSync(path);
        } catch (err) {
            throw new Error('Exeption occured at cancelProcessSkip');
        }
    }
    return true;
}

/**
 * ディレクトリ作成
 * @param {String} パス
 */
function createDirectory(dir) {
    var fs = require('fs');
    // mod 2021-10-26 #5890:Medicom連携ができない 孫 start
    //fs.mkdirSync(dir, { recursive: true });
    var path = require("path");
    if (isExist(dir)) {
        return true;
    } else {
        if (createDirectory(path.dirname(dir))) {
            fs.mkdirSync(dir, { recursive: true });
            return true;
        }
    }
    // mod 2021-10-26 #5890:Medicom連携ができない 孫 end
}

/**
 * ディレクトリ作成
 * @param {*} dir パス
 */
exports.createDirectory = function(dir) {
    // ディレクトリチェック
    if (isExist(dir)) {
        return;
    }
    // ディレクトリ作成
    createDirectory(dir);
}

// add 2020-12-08 No.712：IFエッジのログをログ参照画面で参照できるようにする。 孫 start
/**
 * HOST IPを取得する
 */
exports.getHostIp = function() {
    var os = require('os');

    var interfaces = os.networkInterfaces();
    for (var devName in interfaces) {
        var iface = interfaces[devName];
        for (var i = 0; i < iface.length; i++) {
            var alias = iface[i];
            if (alias.family === 'IPv4' && alias.address !== '127.0.0.1' && !alias.internal) {
                return alias.address;
            }
        }
    }
    
    return '';
}
// add 2020-12-08 No.712：IFエッジのログをログ参照画面で参照できるようにする。 孫 end
// add 2021-04-25 外部連携:TSHPlus Socketの対応 孫 start
function LeftAppend(buf, len, str) {
	var append = '';
	var addLen = len - buf.length;
	for (k=0; k<addLen; k++) {
		append = append + str;
	}
	append = append + buf;
    return append;
}
exports.LeftAppend = function(buf, len, str) {
	return LeftAppend(buf, len, str);
}

function getTSHColInfoByName(buf, tshformat, name) {
	var formatCnt = tshformat.format.length;
    var start = 0;
    var len = 0;
    for (i=0; i<formatCnt; i++) {
        var format = tshformat.format[i];
        if (format.name === name) {
            len = format.length;
            break;
        }
        start = start + format.length;
    }

    if (name === 'Data') {
    	var bufLength = buf.length;
    	var headLength = tshformat.header_length;
    	len = bufLength - headLength;
    }

    var colInfo = {};
    colInfo.start = start;
    colInfo.len = len;
    return colInfo;
}

exports.getTSHColInfoByName = function(buf, tshformat, name) {
	return getTSHColInfoByName(buf, tshformat, name);
}

function getTSHItemByName(buf, tshformat, name) {
	var colInfo = getTSHColInfoByName(buf, tshformat, name);
	var start = colInfo.start;
	var len = colInfo.len;
    if ((start+len) > buf.length) {
        return '';
    }
    
	data = buf.slice(start, start + len);
//console.log('------------------------------>name:[' +name+ '], data=[' + data + ']');
    var iconv = require('iconv-lite');
    var conv = iconv.decode(data, 'shift-jis');
//console.log('------------------------------>name:[' +name+ '], conv=[' + conv + ']');
    return conv;
}

exports.getTSHItemByName = function(buf, tshformat, name) {
	return getTSHItemByName(buf, tshformat, name);
}

exports.getTSHDataLength = function(buf, tshformat) {
	var length = getTSHItemByName(buf, tshformat, 'TelegramLength');
	    if (length === '' || !isFinite(length)) {
        return 0;
    }
    return (length*1);
}

exports.TSHCheckValidation = function(buf, length) {
    if (buf.length !== length * 1) {
        return false;
    }
    return true;
}

exports.getDataByLength = function(buf, start, len) {
    str = buf.slice(start, start + len);
    return str;
}

exports.setTSHItemByName = function(buf, tshformat, name, value) {
	var iconv = require('iconv-lite');

	var colInfo = getTSHColInfoByName(buf, tshformat, name);
	var start = colInfo.start;
	var len = colInfo.len;
    if ((start+len) > buf.length) {
        return buf;
    }
    if (name === 'Data') {
        var bufLength = buf.length;
        var headLength = tshformat.header_length;
        len = bufLength - headLength;  
        
        // Before data
        retData = Buffer.alloc(headLength + value.length);
        buf.copy(retData, 0, 0, start);
        
        // copy data
        conv = iconv.encode(value, 'shift-jis');
        conv.copy(retData, start, 0, value.length);
        
        // After data
        var lastStart = start + len;
        var lastLen = bufLength -  (start + len);
        if (lastLen > 0) {
            buf.copy(retData, (start+value.length), lastStart, lastLen);
        }
        return retData;
    } else {
        if (value.length < len) {
            for (i=0;i<(len - value.length);i++) {
                value = value + ' ';
            }
        }
        retData = Buffer.alloc(buf.length);
        buf.copy(retData, 0, 0, buf.length);
        
		conv = iconv.encode(value, 'shift-jis');
        conv.copy(retData, start, 0, len);
        return retData;
    }
}

function Str2Hex(strHex) {
    let str = strHex.toUpperCase();
    if (str === '0X00') {return 0X00;}
    else if (str === '0X01') {return 0X01;}
    else if (str === '0X02') {return 0X02;}
    else if (str === '0X03') {return 0X03;}
    else if (str === '0X04') {return 0X04;}
    else if (str === '0X05') {return 0X05;}
    else if (str === '0X06') {return 0X06;}
    else if (str === '0X07') {return 0X07;}
    else if (str === '0X08') {return 0X08;}
    else if (str === '0X09') {return 0X09;}
    else if (str === '0X0A') {return 0X0A;}
    else if (str === '0X0B') {return 0X0B;}
    else if (str === '0X0C') {return 0X0C;}
    else if (str === '0X0D') {return 0X0D;}
    else if (str === '0X0E') {return 0X0E;}
    else if (str === '0X0F') {return 0X0F;}
    else if (str === '0X10') {return 0X10;}
    else if (str === '0X11') {return 0X11;}
    else if (str === '0X12') {return 0X12;}
    else if (str === '0X13') {return 0X13;}
    else if (str === '0X14') {return 0X14;}
    else if (str === '0X15') {return 0X15;}
    else if (str === '0X16') {return 0X16;}
    else if (str === '0X17') {return 0X17;}
    else if (str === '0X18') {return 0X18;}
    else if (str === '0X19') {return 0X19;}
    else if (str === '0X1A') {return 0X1A;}
    else if (str === '0X1B') {return 0X1B;}
    else if (str === '0X1C') {return 0X1C;}
    else if (str === '0X1D') {return 0X1D;}
    else if (str === '0X1E') {return 0X1E;}
    else if (str === '0X1F') {return 0X1F;}
    else if (str === '0X7F') {return 0X7F;}
}

exports.Str2Hex = function(strHex) {
    return Str2Hex(strHex);
}
// add 2021-04-25 外部連携:TSHPlus Sockeの対応 孫 end
// add 2021-06-06 #5293:[送信時：再送信時の動きについて]の対応 孫 start
// 追加キーを使って新しいファイル名を作成します。
exports.GetNewFileName = function(oldName, addName) {
	var path = require('path');
	
    var MAX_FILE_NAME_LENGTH = 255;
    var pathName = path.dirname(oldName);
    var baseName = path.basename(oldName);
    var extName = path.extname(baseName);
    var notExtBaseName = baseName.slice(0, (baseName.length - extName.length));
    var addLength = addName.length + 1;
    var newBaseName = '';
    if (baseName.length + addLength <= MAX_FILE_NAME_LENGTH) {
        newBaseName = notExtBaseName + '_' + addName + extName;
    } else {
        newBaseName = notExtBaseName.slice(0, (MAX_FILE_NAME_LENGTH - addLength - extName.length)) + '_' + addName + extName;
    }
    if (pathName !== undefined && pathName !== null && pathName !== '') {
	    newName = pathName  + '/' + newBaseName;
    } else {
    	newName = newBaseName;
    }
    return newName;
}

// 指定されたパスの下で固定文字列の先頭のファイルを指定のパスに移動します。
function sleep(time = 0) {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      resolve();
    }, time);
  })
}

exports.sleep = function(time = 0) {
	sleep(time);
}

exports.MoveFilesFromPathByStartsWith = function(fromPath, fileNameStartPart, toPath, deleteFlag) {
	var fs = require('fs');
	var path = require('path');
	
//console.log('fromPath = [' + fromPath + ']');
//console.log('fileNameStartPart = [' + fileNameStartPart + ']');
//console.log('toPath = [' + toPath + ']');
//console.log('deleteFlag = [' + deleteFlag + ']');
	
	if (fromPath.slice( -1 ) !== '/') { fromPath = fromPath + '/'; }
//console.log('check fromPath=' + fromPath);
	if (toPath.slice( -1 ) !== '/') { toPath = toPath + '/'; }
//console.log('check toPath=' + toPath);

	// pathから、filesを取得する
	const files = fs.readdirSync(fromPath);
	// ファイル ループ
	files.forEach(function (item, index) {
//console.log('item  file =====> [' + item + ']');
		// 有効ファイルか
		if (item.startsWith(fileNameStartPart) === true) {
			var delFilePath = fromPath + item;
			var destPath = toPath + item;
			
			fs.copyFileSync(delFilePath, destPath);
			var logMessage = 'file copy success [' + delFilePath +  '] => [' + destPath + ']';
			
			if (deleteFlag === undefined || deleteFlag === "undefined" || deleteFlag === "true") {
				fs.unlinkSync(delFilePath);
//console.log('file [' + delFilePath +  '] deleted');
				logMessage = 'file move success [' + delFilePath +  '] => [' + destPath + ']';
			}
console.log(logMessage);
			sleep(300);
		} else {
//console.log('other file=' + item);
		}
	});
}
// add 2021-06-06 #5293:[送信時：再送信時の動きについて]の対応 孫 end


exports.GetChildFolderNames = function(directoryPath) {
  var fs = require('fs');
  
  try {
    const childFolderNames = fs.readdirSync(directoryPath, { withFileTypes: true })
      .filter(dirent => dirent.isDirectory())
      .map(dirent => dirent.name);

    return childFolderNames;
  } catch (error) {
     throw error;
  }
}
