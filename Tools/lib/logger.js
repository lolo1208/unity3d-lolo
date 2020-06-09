/**
 * 记录日志文件（common.logFile）
 * Created by LOLO on 2019/3/30.
 */


const fs = require('fs');
const common = require('./common');

const logger = module.exports = {};


let handle = null;
let list = [];


// 先创建文件，写入环境和命令行信息
common.writeFileSync(common.logFile,
    ['<b>[COMMAND LINE ARGUMENTS]:</b>'].concat(process.argv).concat(
        '',
        '<b>[ENVIRONMENTS]:</b>',
        'id = ' + common.id,
        'projectName = ' + common.projectName,
        'targetPlatform = ' + common.targetPlatform,
        'notEncode = ' + (common.notEncode === true),
        'luajit = ' + (common.luajit === true),
        'generatePlatformProject = ' + (common.generatePlatformProject === true),
        'development = ' + (common.development === true),
        'version = ' + common.fullVersionNumber,
        'projectDir = ' + common.projectDir,
        'platformProjectDir = ' + common.targetPlatformDir,
        'destDir = ' + common.destDir,
        'packZip = ' + common.packZip,
        'projectBuildDir = ' + common.projectBuildDir,
        'unityPath = ' + common.unityPath,
        '',
        '<b>[LOGGING]:</b>'
    ).join('\n')
);


/**
 * 追加内容到日志文件中
 * @param args
 */
logger.append = function (...args) {
    list = list.concat(args);
    if (handle === null)
        handle = setTimeout(doAppend, 1000);
};

let doAppend = function () {
    fs.appendFile(common.logFile, getData(), (err) => {
        if (err) throw err;
        handle = null;
    });
};


/**
 * 立即将内存中记录的日志内容写入到文件中
 */
logger.updateNow = function () {
    fs.appendFileSync(common.logFile, getData());
};


/**
 * 获取内存中的日志数据，并清空
 */
let getData = function () {
    let data = '\n' + list.join('\n');
    list.length = 0;
    return data;
};
