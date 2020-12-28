/**
 * SVN 项目检出和更新
 * Created by LOLO on 2019/10/9.
 */


const fs = require('fs');
const path = require('path');
const child_process = require('child_process');
const common = require('./common');
const logger = require('./logger');
const progress = require('./progress');
const buildUnity = require('./buildUnity')
const versionControl = require('./versionControl');
const svnCfg = require('./config/' + common.svnOrGitConfigName);


const vc_svn = module.exports = {};

const cmdTypes = {checkout: 'ckeckout', update: 'update', revert: 'revert'};

let workError = null;// 更新或检出项目时出现的错误
let completeCount = 0;// SVN 检出或更新已完成项目数
let callback = null;// 全部完成时的回调


vc_svn.start = function (cb) {
    buildUnity.cacheLibrary(false);
    callback = cb;
    progress.data.svn[1] = svnCfg.list.length;
    progress.versionControl(completeCount);
    progress.setTiming(progress.TT_SVN, true);
    logger.append('- 开始检出或更新 SVN 项目');

    // 有指定检出的本地目录
    if (svnCfg.destDir) {
        common.sourceDir = path.normalize(svnCfg.destDir + '/');
        common.sourceProjectDir = `${common.sourceDir}project/`;
    }

    // 几个项目同时执行 svn 命令
    for (let i = svnCfg.list.length - 1; i >= 0; i--)
        createWork(svnCfg.list[i], `work${i + 1}/`);
};


/**
 * 创建一个 svn 工作进程
 * @param data
 * @param workDirPath
 */
let createWork = function (data, workDirPath) {
    let args = {
        url: data.url,
        dir: common.sourceDir + workDirPath,
        username: data.username !== undefined ? data.username : svnCfg.username,
        password: data.password !== undefined ? data.password : svnCfg.password,
    };
    let destDir = path.normalize(common.sourceProjectDir + data.dest + '/');

    // 临时目录存在，直接删除
    if (fs.existsSync(args.dir))
        common.removeDir(args.dir);


    // 更新项目
    if (fs.existsSync(destDir)) {
        fs.renameSync(destDir, args.dir);// 先移动到工作目录

        logger.append(`* 开始更新 ${args.url}`);

        // 先更新
        execSvnCmd(cmdTypes.update, args, (err) => {
            if (err) {
                // 更新失败尝试还原
                logger.append(`* 更新 ${args.url} 失败，尝试还原`);
                execSvnCmd(cmdTypes.revert, args, (err) => {
                    if (err) {
                        // 还原失败，结束
                        workError = err;
                        logger.append(`* 还原 ${args.url} 失败`);
                        endWork();
                    } else {
                        // 还原成功，再次尝试更新
                        logger.append(`* 还原 ${args.url} 成功，再次尝试更新`);
                        execSvnCmd(cmdTypes.update, args, (err) => {
                            if (err) {
                                workError = err;
                                logger.append(`* 更新 ${args.url} 失败`);
                            } else {
                                logger.append(`* 更新 ${args.url} 完成`);
                            }
                            // 结束
                            endWork();
                        });
                    }
                });
            } else {
                // 更新成功，结束
                logger.append(`* 更新 ${args.url} 完成`);
                endWork();
            }
        });
    }


    // 检出项目
    else {
        logger.append(`* 开始检出 ${args.url}`);
        execSvnCmd(cmdTypes.checkout, args, (err) => {
            if (err) {
                workError = err;
                logger.append(`* 检出 ${args.url} 失败`);
            } else {
                logger.append(`* 检出 ${args.url} 完成`);
            }
            endWork();
        });
    }
};


let execSvnCmd = function (type, args, callback) {
    let cmd;
    let [url, dir, un, pw] = [args.url, args.dir, args.username, args.password];
    switch (type) {
        case cmdTypes.checkout:
            cmd = `svn checkout ${url} ${dir} --username ${un} --password "${pw}"`;
            break;
        case cmdTypes.update:
            cmd = `svn update ${dir} --username ${un} --password "${pw}"`;
            break;
        case cmdTypes.revert:
            cmd = `svn revert -R ${dir}`;
    }

    child_process.exec(cmd, {maxBuffer: 1024 * 1024 * 5}, (err, stdout, stderr) => {
        // 添加 svn 日志
        versionControl.appendLog(`<b>##[ ${url} ]##</b>`);
        versionControl.appendLog(`<b>${cmd.slice(0, cmd.lastIndexOf(' --password'))}</b>`);
        versionControl.appendLog('<p class="content-text-small">');

        versionControl.appendLog('<b>[stdout]:</b>');
        if (stdout === '')
            versionControl.appendLog('none');
        else
            versionControl.appendLog(stdout.replace(new RegExp(dir, 'g'), '| '));

        versionControl.appendLog('<b>[stderr]:</b>');
        if (stderr === '')
            versionControl.appendLog('none');
        else
            versionControl.appendLog(`<p class="content-text-error">${stderr}</p>`);

        if (stdout.indexOf('Summary of conflicts') !== -1)
            err = new Error('执行 SVN 命令时，有冲突产生！');

        if (err) {
            versionControl.appendLog('<b>[error]:</b>');
            versionControl.appendLog(`<p class="content-text-error">${err.stack}</p>`);
        }

        versionControl.appendLog('</p>', ' ');

        callback(err);
    });
};


/**
 * 项目检出或更新结束
 */
let endWork = function () {
    progress.versionControl(++completeCount);

    // all complete
    if (completeCount === svnCfg.list.length) {
        logger.append('- 检出或更新 SVN 项目已全部完成');
        progress.setTiming(progress.TT_SVN, false);

        for (let i = 0; i < svnCfg.list.length; i++) {
            // 将 work 目录改名为 dest 目录
            try {
                let workDir = `${common.sourceDir}work${i + 1}/`;
                let destDir = path.normalize(common.sourceProjectDir + svnCfg.list[i].dest + '/');
                fs.renameSync(workDir, destDir);
            } catch (err) {
                workError = err;
            }
        }

        // 抛出错误
        if (workError !== null) {
            logger.append('- 检出或更新 SVN 过程中有错误产生');
            throw workError;

        } else {
            callback();
        }
    }
};

