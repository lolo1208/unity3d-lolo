/**
 * Created by LOLO on 2019/4/25.
 */


if (!!window.chrome) document.body.style.fontFamily = 'none';


var LOG_TYPE = {
    BUILD: 'build',
    MANIFEST: 'manifest',
    UNITY: 'unity',
    RES: 'res',
    DEP: 'dependencies',
    PROGRESS: 'progress'
};

// 在 Unity log 中需要标红的报错关键字
var failedKeys = [
    "Error", "Exception", "Failed", "Script asset",
    "not supported",
    "Unrecognized assets",
    "Cannot mark assets",
    "Usage Description is empty",
    "Plugins colliding with each other"
];


var packid = getQueryVariable('packid');
if (packid == null) {
    alert('错误的 packid 参数');
}


//


// 左侧 - 日志类型

var curLogType = LOG_TYPE.BUILD;
var refreshLogHandle = null;
var versionNum = null;
var zipPath = null;
var errorList = [];
var errorIndex = -1;


function delayRefreshLog() {
    if (!packaging) return;
    if (refreshLogHandle == null)
        refreshLogHandle = setTimeout(function () {
            refreshLogHandle = null;
            showLog(E(curLogType));
        }, 1500);
}


/**
 * 显示指定类型的日志
 * @param element
 */
function showLog(element) {
    var type = element.id;
    var logContent = E('logContent');
    getLog(type, function (data) {
        if (data == null) {
            logContent.innerHTML = '获取日志失败！！<br/>' +
                '稍后将会自动尝试重新获取...<br/><br/>' +
                '请确认 url 的 packid 参数是否正确！';
            delayRefreshLog();
            return;
        }

        E(curLogType).className = 'log-item';

        curLogType = type;
        element.className = 'log-item log-item-selected';
        E('logTitle').innerHTML = element.innerHTML;


        var resTable, depContent, startIdx, endIdx;
        switch (type) {

            case LOG_TYPE.BUILD:
                // 取版本号
                if (versionNum == null) {
                    startIdx = data.indexOf('version = ');
                    if (startIdx != -1) {
                        endIdx = data.indexOf('\n', startIdx);
                        versionNum = data.substring(startIdx + 10, endIdx);
                        showPackIDAndVersion();
                    }
                }

                // 取 zip 地址，显示下载按钮
                if (!packaging && zipPath == null) {
                    startIdx = data.indexOf(' zip: ');
                    if (startIdx != -1) {
                        endIdx = data.indexOf('\n', startIdx);
                        zipPath = data.substring(startIdx + 6, endIdx);
                        E('downloadBtn').style.visibility = 'visible';
                    }
                }
                break;

            case LOG_TYPE.RES:
                resTable = '<table class="res-tb">';
                data = JSON.parse(data);
                var i = 0;
                for (var key in data) {
                    resTable += (++i % 2 == 0) ? '<tr class="res-tb-tr-odd">' : '<tr>';
                    resTable += '<td class="res-tb-td-left">' + data[key] + '</td>';
                    resTable += '<td class="res-tb-td-right" title="' + key + '">' + key + '</td>';
                    resTable += '</tr>';
                }
                resTable += '</table>';
                break;

            case LOG_TYPE.DEP:
                depContent = '';
                var obj = JSON.parse(data);
                for (var abPath in obj) {
                    depContent += '<div class="dep-item">';
                    depContent += '<p>' + abPath + '</p>';
                    var list = obj[abPath];
                    for (var j = 0; j < list.length; j++) {
                        depContent += '<p>- ' + list[j] + '</p>';
                    }
                    depContent += '</div>';
                }
                break;
        }

        var autoScrollDiv = E("autoScrollDiv");
        if (type == LOG_TYPE.BUILD || type == LOG_TYPE.UNITY) {
            autoScrollDiv.style.visibility = "visible";
            delayRefreshLog();

            // 转义 Unity 日志中的尖括号
            if (type == LOG_TYPE.UNITY) {
                data = data.replace(/</gi, '&lt;');
                data = data.replace(/>/gi, '&gt;');
            }

            // 打包结束，并失败，将 Unity 日志中的报错信息标红
            if (!packaging && !successful && type == LOG_TYPE.UNITY) {
                data = data.replace(/error/gi, 'Error');// error 关键字大小写需要统一
                data = data.replace(/\n/g, '<br/>');// <br/> 作为首尾索引字符
                errorList = [];
                for (var k = 0; k < failedKeys.length; k++) {
                    var fk = failedKeys[k];
                    var idx = data.indexOf(fk);
                    while (idx != -1) {
                        startIdx = data.lastIndexOf('<br/>', idx);
                        endIdx = data.indexOf('<br/>', idx);
                        var errStr = data.substring(startIdx, endIdx);
                        if (errStr.indexOf('Socket: connect failed') == -1
                            && errStr.indexOf('external process') == -1
                            && errStr.indexOf('LicensingClient') == -1
                            && errStr.indexOf('[usbmuxd] Error') == -1
                            && errStr.indexOf('Debug:LogError') == -1
                            && errStr.indexOf('LogAssemblyErrors') == -1
                            && errStr.indexOf('fmod_Errors.cs') == -1
                            && errStr.indexOf('Exception.cs') == -1
                            && errStr.indexOf('was thrown') == -1
                            && errStr.indexOf('DetectErrorsAndWarnings') == -1
                            && errStr.indexOf('/MaterialError') == -1
                            && errStr.indexOf('/FallbackError') == -1
                            && errStr.indexOf('/ErrorPulse.') == -1
                            && errStr.indexOf('/ExceptionUtils.cs') == -1
                            && errStr.indexOf('/ErrorNotifier.cs') == -1
                            && errStr.indexOf('UnityWebRequest.isNetworkError') == -1
                        ) {
                            data = insert(data, startIdx + 5,
                                '<span id="errorAnchor' + startIdx + '" class="fail-color">'
                            );
                            endIdx = data.indexOf('<br/>', idx);
                            data = insert(data, endIdx, '</span>');
                            errorList.push(startIdx);
                        }
                        idx = data.indexOf(fk, endIdx);
                    }
                }

                if (errorList.length > 0) {
                    errorList.sort();
                    errorIndex = -1;
                    E('nextErrorBtn').style.visibility = 'visible';
                    nextError();
                }

                // Crash
                data = data.replace(/Crash!!!/gi, '<span class="fail-color">' +
                    'Crash！！！<br/>' +
                    'Crash 常发生在资源处理阶段，<br/>' +
                    '请往上看！！！<br/>' +
                    '看日志最终停留在处理哪个资源，再围绕该资源分析原因。<br/>' +
                    '<br/></span>');
            }
        } else {
            autoScrollDiv.style.visibility = "hidden";
            logContent.scrollTop = 0;
        }

        if (packaging || type != LOG_TYPE.UNITY)
            E('nextErrorBtn').style.visibility = 'hidden';

        switch (type) {
            case LOG_TYPE.RES:
                logContent.innerHTML = resTable;
                break;
            case LOG_TYPE.DEP:
                logContent.innerHTML = depContent;
                break;
            default:
                logContent.innerHTML = data.replace(/\n/g, '<br/>');
        }
        scrollToBottom();
    });
}


function scrollToBottom() {
    if (E("autoScroll").checked)
        logContent.scrollTop = logContent.scrollHeight;
}


function showPackIDAndVersion() {
    var str = 'pack id: ' + packid;
    if (versionNum != null)
        str += '<br/>version: ' + versionNum;
    E('packid').innerHTML = str;
}

showPackIDAndVersion();
showLog(E(LOG_TYPE.BUILD));


function downloadZip() {
    var iframe = document.querySelector('#download-iframe');
    if (iframe) document.body.removeChild(iframe);
    iframe = document.createElement('iframe');
    iframe.style.display = "none";
    iframe.id = 'download-iframe';
    iframe.src = zipPath;
    document.body.appendChild(iframe);
}


function nextError() {
    if (++errorIndex == errorList.length)
        errorIndex = 0;
    E('nextErrorBtn').href = '#errorAnchor' + errorList[errorIndex];
}


function insert(str, index, value) {
    return str.substr(0, index) + value + str.substr(index);
}


//


// 右侧 - 打包进度

var packaging = true;// 是否正在打包中
var successful = false;// 打包是否成功
var refreshProgressHandle = null;
var barInfo = {};


function getProgress() {
    getLog(LOG_TYPE.PROGRESS, function (data) {
        if (data == null) {
            E('pTotalInfo').innerHTML = '获取数据失败';
            delayRefreshProgress();
            return;
        }

        // 可能会报错（待解决：有可能是 IO 冲突）
        try {
            data = JSON.parse(data);
        } catch (err) {
            delayRefreshProgress();
            return;
        }

        var completeCount = 0;
        if (setProgress('Svn', data.svn)) completeCount++;
        if (setProgress('Manifest', data.manifest)) completeCount++;
        if (setProgress('Lua', data.lua)) completeCount++;
        if (setProgress('Scene', data.scene)) completeCount++;
        if (setProgress('Ab', data.ab)) completeCount++;
        if (setProgress('Res', data.copyRes)) completeCount++;
        if (setProgress('Gpp', data.gpp)) completeCount++;
        if (setProgress('Daz', data.daz)) completeCount++;
        // console.log(completeCount + ",  " + Math.floor(completeCount / 8 * 100));

        // 总进度
        E('pTotal').className = 'progress-item';
        E('pTotalInfo').innerHTML = '总耗时 [ ' + formatTime(data.totalTime) + " ]";
        setProgressBar(E('pTotalBar'), Math.floor(completeCount / 8 * 100));

        // 已全部完成
        if (data.status != 1) {
            packaging = false;
            successful = data.status == 0;
            E('pTotalTitle').innerHTML = successful
                ? '<b class="succ-color">打包成功</b>'
                : '<b class="fail-color">打包出错</b>';
            showLog(E(curLogType));
        } else
            delayRefreshProgress();
    });
}


function setProgress(name, data) {
    var complete = true;
    var item = E('p' + name);
    var info = E('p' + name + "Info");
    var bar = E('p' + name + "Bar");

    var text = data[0] + '/' + data[1];
    if (data[1] > 0) {
        item.className = 'progress-item';
        bar.className = 'progress-item-bar bar-running';
        setProgressBar(bar, Math.floor(data[0] / data[1] * 100));
        complete = data[0] == data[1];
        if (complete) text += ' [ ' + formatTime(data[2]) + ' ]';
    } else {
        item.className = 'progress-item progress-item-disabled';
        bar.className = 'progress-item';
    }
    info.innerHTML = text;

    return complete;
}


function setProgressBar(bar, p) {
    var info = barInfo[bar.id];
    if (info == null)
        info = barInfo[bar.id] = {cur: 0, tar: 0, handle: null};
    info.tar = p;

    if (info.cur == info.tar) return;

    (info.tar > info.cur) ? info.cur++ : info.cur--;
    bar.style.width = info.cur + '%';

    if (info.handle != null) clearTimeout(info.handle);

    if (info.cur != info.tar) {
        info.handle = setTimeout(function () {
            info.handle = null;
            setProgressBar(bar, info.tar);
        }, 10);
    }
}


getProgress();


function delayRefreshProgress() {
    if (!packaging) return;
    if (refreshProgressHandle == null)
        refreshProgressHandle = setTimeout(function () {
            refreshProgressHandle = null;
            getProgress();
        }, 1000);
}


//


/**
 * 获取 url 参数
 * @param variable
 * @return {*}
 */
function getQueryVariable(variable) {
    var query = window.location.search.substring(1);
    var vars = query.split('&');
    for (var i = 0; i < vars.length; i++) {
        var pair = vars[i].split('=');
        if (pair[0] == variable) {
            return pair[1];
        }
    }
    return null;
}


/**
 * 获取日志内容
 * @param type
 * @param callback
 */
function getLog(type, callback) {
    var xmlhttp = (window.XMLHttpRequest)
        ? new XMLHttpRequest()// IE7+, Firefox, Chrome, Opera, Safari
        : new ActiveXObject('Microsoft.XMLHTTP');// IE6, IE5
    xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState == 4)
            callback((xmlhttp.status == 200) ? xmlhttp.responseText : null);
    };
    xmlhttp.open('GET', packid + '/' + type + '.log?r=' + Date.now() + Math.random(), true);
    xmlhttp.send();
}


/**
 * 通过 id 获取 html 元素
 * @param id
 * @return {*}
 */
function E(id) {
    return document.getElementById(id);
}


/**
 * 格式化时间
 * @param millisec
 * @return {string}
 */
function formatTime(millisec) {
    var seconds = millisec / 1000;
    var minutes = Math.floor(seconds / 60);
    var hours = '';
    if (minutes > 59) {
        hours = Math.floor(minutes / 60);
        hours = (hours >= 10) ? hours : '0' + hours;
        minutes = minutes - (hours * 60);
    }

    seconds = (seconds % 60).toFixed(2);
    if (minutes == 0)
        return seconds + 's';

    minutes = (minutes >= 10) ? minutes : '0' + minutes;
    seconds = (seconds >= 10) ? seconds : '0' + seconds;

    if (hours != '')
        return hours + ':' + minutes + ':' + seconds;

    return minutes + ':' + seconds;
}
