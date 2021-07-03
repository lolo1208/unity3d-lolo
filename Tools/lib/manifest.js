/**
 * 创建和读取打包清单文件
 * Created by LOLO on 2019/3/29.
 */


const readline = require('readline');
const fs = require('fs');
const child_process = require('child_process');
const common = require('./common');
const progress = require('./progress');
const logger = require('./logger');

const manifest = module.exports = {};


/**
 * 生成打包清单
 * @param callback
 */
let generate = function (callback) {
    progress.setTiming(progress.TT_MANIFEST, true);
    logger.append("- 开始生成打包清单");

    // 启动 unity 进程
    let cmd = common.unityCmd;
    cmd += ' -executeMethod ShibaInu.Builder.GenerateBuildManifest';
    cmd += ` -manifestPath ${common.manifestFile}`;
    child_process.exec(cmd, (err, stdout, stderr) => {
        if (err) throw err;
        common.verifyUnityLogError();
        progress.manifest(1);
        logger.append("- 生成打包清单完成");
        callback();
    });
};


/**
 * 读取打包清单
 * @param callback
 */
let read = function (callback) {
    logger.append("- 开始读取打包清单");
    let data = manifest.data = {lua: [], bytes: [], scene: [], ab: []};
    let [phase, count, index] = [1, 0, 0];
    let rl = readline.createInterface({input: fs.createReadStream(common.manifestFile), crlfDelay: Infinity});

    rl.on('line', (line) => {
        switch (phase) {

            // 读取 lua 列表
            case 1:
                if (count === 0)
                    count = parseInt(line);
                else {
                    data.lua.push(line);
                    if (++index === count) {
                        count = index = 0;
                        phase++;
                    }
                }
                break;

            // Res 与 StreamingAssets 目录下需要被拷贝的文件列表
            case 2:
                if (count === 0) {
                    count = parseInt(line);
                    if (count === 0) phase++;// 可能没有需要直接拷贝的文件
                } else {
                    data.bytes.push(line);
                    if (++index === count) {
                        count = index = 0;
                        phase++;
                    }
                }
                break;

            // 读取场景列表
            case 3:
                if (count === 0)
                    count = parseInt(line);
                else {
                    data.scene.push(line);
                    if (++index === count) {
                        count = index = 0;
                        phase++;
                    }
                }
                break;

            // 读取 AssetBundle 信息（读取 AB 信息只能放在最后一个阶段，不能再升阶）
            case 4:
                if (count === 0)
                    count = parseInt(line);
                else {
                    if (index === 0)
                        data.ab.push({name: line, assets: []});
                    else
                        data.ab[data.ab.length - 1].assets.push(line);
                    if (++index === count) {
                        count = index = 0;
                    }
                }
                break;
        }
    });

    rl.on('close', () => {
        progress.manifest(2);
        logger.append("- 读取打包清单完成");
        progress.setTiming(progress.TT_MANIFEST, false);
        callback();
    });
};


/**
 * 创建并读取打包清单
 * @param callback
 */
manifest.start = function (callback) {
    generate(() => {
        read(callback);
    });
};