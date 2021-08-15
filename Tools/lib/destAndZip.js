/**
 * 将生成的所有资源拷贝至指定目录，以及生成 zip 包
 * Created by LOLO on 2019/4/17.
 */


const fs = require('fs');
const path = require('path');
const archiver = require('archiver');
const common = require('./common');
const logger = require('./logger');
const progress = require('./progress');
const copyRes = require('./copyRes');
const genAstZip = require('./genAstZip');


const destAndZip = module.exports = {};

let count = 0;


//


const resList = {};
/**
 * 资源文件是否已存在 resList 中
 * @param name
 */
const resExists = function (name) {
    if (resList[name]) return true;
    resList[name] = true;
    return false;
}


/**
 * 拷贝所有生成的资源
 * @param callback
 */
destAndZip.dest = function (callback) {
    progress.setTiming(progress.TT_DAZ, true);

    if (common.destDir === undefined) {
        complete(callback);
        return;
    }

    logger.append('- 开始导出资源: ' + common.destDir);
    destAndZip.destRes(common.destDir, () => {
        logger.append('- 导出资源完成');
        complete(callback);
    });
};


/**
 * 打 zip 包
 * @param callback
 */
destAndZip.zip = function (callback) {
    if (common.packZip === undefined) {
        complete(callback);
        return;
    }

    // zip 文件完整路径
    let zipFile = common.packZip === 'true' ? common.zipDir + common.fullVersionNumber + '.zip' : common.packZip;
    logger.append('- 开始生成 zip: ' + zipFile.replace(common.buildDir, ''));
    common.createDir(zipFile);
    let output = fs.createWriteStream(zipFile);
    let archive = archiver('zip');
    output.on('close', () => {
        let size = Math.floor(archive.pointer() / 1024 / 1024 * 100) / 100;
        logger.append(`- 生成 zip 完成: ${size} MB`);
        complete(callback);
    });
    archive.on('error', (err) => {
        throw err;
    });
    archive.pipe(output);

    if (common.zipForAST === undefined) {
        // 版本信息文件
        archive.append(common.fullVersionNumber, {name: common.versionConfigFileName});
        // 资源清单文件
        archive.append(fs.createReadStream(common.resManifestFile), {name: path.basename(common.resManifestFile)});
        // 资源文件列表
        let list = copyRes.resList;
        for (let i = 0; i < list.length; i++) {
            let fileName = list[i];
            if (!resExists(fileName))
                archive.append(fs.createReadStream(common.resDir + fileName), {name: fileName});
        }
    } else {
        genAstZip.zip(archive);
    }
    archive.finalize();
};


/**
 * 拷贝资源或打包 zip 完成
 * @param callback
 */
let complete = function (callback) {
    progress.daz();
    if (++count === 2)
        progress.setTiming(progress.TT_DAZ, false);
    callback();
};


/**
 * 将生成的所有资源拷贝至指定目录
 * @param destDir
 * @param callback
 */
destAndZip.destRes = function (destDir, callback) {
    // 清空目录
    common.removeDir(destDir);

    // 写入版本信息文件
    common.writeFileSync(destDir + common.versionConfigFileName, common.fullVersionNumber);
    // 拷贝资源清单文件
    fs.copyFileSync(common.resManifestFile, destDir + path.basename(common.resManifestFile));

    // 创建进入 AssetBundle 模式的标志文件
    if (common.abModeFlag) {
        common.writeFileSync(common.abModeFlagFile, '');
        logger.append('- 已创建进入 AssetBundle 模式的标志文件');
    }

    // 拷贝资源文件
    let list = copyRes.resList;
    let count = list.length;
    let index = 0;
    for (let i = 0; i < count; i++) {
        let fileName = list[i];
        fs.copyFile(common.resDir + fileName, destDir + fileName, (err) => {
            if (err) throw err;
            if (++index === count) {
                callback();
            }
        });
    }
};

