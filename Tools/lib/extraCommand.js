/**
 * 在打包场景和 AssetBundle 完成后（拷贝资源前），执行额外的脚本
 * Created by LOLO on 2025/05/13.
 */

const common = require('./common');
const logger = require('./logger');

const extraCommand = module.exports = {};


/**
 * 开始
 * @param callback
 */
extraCommand.start = function (callback) {
    if (common.extraCmd === undefined) {
        logger.append('- 没有额外的脚本需要执行');
        callback();
    }
    else {
        logger.append(`- 执行额外的脚本：${common.extraCmd}`);
        const extraCmd = require(common.extraCmd);
        extraCmd(callback);
    }
};

