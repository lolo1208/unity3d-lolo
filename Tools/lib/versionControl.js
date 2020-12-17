/**
 * 版本控制，检出或更新 svn/git
 * Created by LOLO on 2019/10/11.
 */


const fs = require('fs');
const common = require('./common');


const versionControl = module.exports = {};
let isFirstAppendLog = true;


/**
 * 开始更新或检出 svn/git
 * @param cb
 */
versionControl.start = function (cb) {
    let cfgName = common.svnOrGitConfigName;
    if (cfgName === undefined) {
        cb();
        return;
    }

    // 清空日志
    common.writeFileSync(common.versionLogFile, '');

    if (cfgName.endsWith('.svn')) {
        const svn = require('./vc_svn');
        svn.start(cb);
        return;
    }

    if (cfgName.endsWith('.git')) {
        throw Error('Git 相关功能还未实现！');
    }

    throw Error('仅支持 SVN 或 Git。配置名称包含 .svn 或 .git。\n' +
        '例如，\n' +
        '  SVN 配置文件位置：config/test.svn.js，配置名称为：test.svn\n' +
        '  Git 配置文件位置：config/test.git.js，配置名称为：test.git\n');
};


/**
 * 写入 svn/git 更新内容日志
 * @param list
 */
versionControl.appendLog = function (...list) {
    let data = '';
    if (isFirstAppendLog) {
        isFirstAppendLog = false;
    } else
        data = '\n';
    data += list.join('\n');
    data = data.replace(/\r\n/g, '\n');
    data = data.replace(/\n\n/g, '\n');
    fs.appendFileSync(common.versionLogFile, data);
};

