/**
 * SVN 项目检出和更新
 * Created by LOLO on 2019/10/9.
 */


// const common = require('./common');
// const logger = require('./logger');
// const progress = require('./progress');
// const config = require('./config/config');

const svnCfg = require('./config/test.svn');


const svn = module.exports = {};

let callback = null;// 全部完成时的回调
let completeCount = 0;// SVN 检出或更新已完成数


svn.start = function (cb) {
    callback = cb;
    // progress.setTiming(progress.TT_SVN, true);

    completeCount = 0;
    for (let i = 0; i < svnCfg.list.length; i++)
        createWork(svnCfg.list[i]);
};


/**
 * 创建一个 svn 进程，检出或更新
 * @param data
 */
let createWork = function (data) {
    console.log(data.dest);

    // common.projectBuildDir
};


svn.start(() => {
    console.log("OK!!!")
});

