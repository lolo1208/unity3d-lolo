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
    ['[command line args]'].concat(process.argv).concat(
        '[environment]',
        'id = ' + common.id,
        'projectName = ' + common.projectName,
        'targetPlatform = ' + common.targetPlatform,
        'notEncode = ' + (common.notEncode === true),
        'generatePlatformProject = ' + (common.generatePlatformProject === true),
        'luajit = ' + common.luajit,
        'version = ' + common.version4,
        'projectDir = ' + common.projectDir,
        'platformProjectDir = ' + common.targetPlatformDir,
        'destDir = ' + common.destDir,
        'zipDir = ' + common.zipDir,
        'projectBuildDir = ' + common.projectBuildDir,
        'unityPath = ' + common.unityPath,
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
        if (err) {
            console.error(err.stack);
            common.exit(common.EXIT_CODE_1);
        }
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
