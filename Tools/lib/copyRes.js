/**
 * 拷贝资源（命名成 md5.后缀 移动到 common.resDir），生成资源清单
 * Created by LOLO on 2019/4/11.
 */


const fs = require('fs');
const path = require('path');
const common = require('./common');
const logger = require('./logger');
const manifest = require('./manifest');
const progress = require('./progress');

const copyRes = module.exports = {};

// 资源后缀名
const EXT_LUA = '.lua';
const EXT_SCENE = '.scene';
const EXT_AB = '.ab';
const EXT_BYTES = '.bytes';


let resIndex = 0;// 当前已拷贝完成资源数
let resManifest = [];// resManifestFile 文件内容
let resList = copyRes.resList = [];// 包含的资源列表
let resMap = {};// 资源路径 -> 资源文件名 映射表
let newResList = [];// 新增资源（路径）列表
let callback;// 拷贝完成时的回调


/**
 * 开始
 * @param cb
 */
copyRes.start = function (cb) {
    // 创建文件夹
    common.createDir(common.resDir + 'o.o');
    common.createDir(common.resManifestFile);

    callback = cb;
    progress.setTiming(progress.TT_COPY_RES, true);
    logger.append('- 开始拷贝资源');
    copyLua();
};


/**
 * 拷贝一个资源完成
 */
let resItemComplete = function (next, src, dest, isNew, isAB) {
    resMap[src] = dest;
    if (isNew) newResList.push(src);
    if (!isAB) resManifest.push(src, dest);// ab 最后单独写入 manifest
    resList.push(dest);
    progress.copyRes(++resIndex);
    next();
}


/**
 * 拷贝 Lua
 */
let copyLua = function () {
    let list = manifest.data.lua;
    let count = list.length;
    let index = -1;
    let src, dest, isNew;
    resManifest.push(count);

    // 拷贝下一个 lua 文件
    let next = () => {
        if (++index === count) {
            copyBytes();
            return;
        }

        src = common.luaCacheDir + list[index];
        common.getFileMD5(src, (md5) => {
            dest = common.resDir + md5 + EXT_LUA;
            isNew = !fs.existsSync(dest);
            if (isNew)
                fs.renameSync(src, dest);// lua 文件无需拷贝，可以直接移动
            copyComplete();
        });
    };

    // 拷贝 lua 文件完成
    let copyComplete = () => {
        src = src.replace(common.luaCacheDir, '')
            .replace('Assets/Framework/ShibaInu/Lua/', '')
            .replace('Assets/Framework/ToLua/Lua/', '')
            .replace('Assets/Lua/', '')
            .replace('.lua', '');
        dest = dest.replace(common.resDir, '');
        resItemComplete(next, src, dest, isNew);
    };
    next();
};


/**
 * 拷贝其他文件
 */
let copyBytes = function () {
    let list = manifest.data.bytes;
    let count = list.length;
    let index = -1;
    let src, dest, isNew;
    resManifest.push(count);

    // 拷贝下一个文件
    let next = () => {
        if (++index === count) {
            copyScene();
            return;
        }

        src = common.projectDir + list[index];
        common.getFileMD5(src, (md5) => {
            dest = common.resDir + md5 + EXT_BYTES;
            isNew = !fs.existsSync(dest);
            if (isNew)
                fs.copyFileSync(src, dest);
            copyComplete();
        });
    };

    // 拷贝文件完成
    let copyComplete = () => {
        src = src.replace(common.projectDir, '')
            .replace('Assets/StreamingAssets/', '')
            .replace('Assets/Res/', '');
        dest = dest.replace(common.resDir, '');
        resItemComplete(next, src, dest, isNew);
    };
    next();
};


/**
 * 拷贝场景
 */
let copyScene = function () {
    let list = manifest.data.scene;
    let count = list.length;
    let index = -1;
    let src, dest, isNew;
    resManifest.push(count);

    // 拷贝下一个场景
    let next = () => {
        if (++index === count) {
            copyAssetBundle();
            return;
        }

        src = common.sceneCacheDir + path.basename(list[index]);
        common.getFileMD5AndData(src, (md5, data) => {
            dest = common.resDir + md5 + EXT_SCENE;
            isNew = !fs.existsSync(dest);
            if (isNew)
                fs.writeFile(dest, data, (err) => {
                    if (err) throw err;
                    copyComplete();
                });
            else
                copyComplete();
        });
    };

    // 拷贝场景完成
    let copyComplete = () => {
        src = path.basename(src, '.unity');
        dest = dest.replace(common.resDir, '');
        resItemComplete(next, src, dest, isNew);
    };
    next();
};


/**
 * 拷贝 AssetBundle
 */
let copyAssetBundle = function () {
    let list = manifest.data.ab;
    let count = list.length;
    let index = -1;
    let src, dest, isNew;

    // 拷贝下一个 AssetBundle
    let next = () => {
        if (++index === count) {
            writeAssetBundleInfo();
            return;
        }

        let abInfo = list[index];
        src = common.abCacheDir + abInfo.name;
        common.getFileMD5AndData(src, (md5, data) => {
            dest = common.resDir + md5 + EXT_AB;
            isNew = !fs.existsSync(dest);
            if (isNew)
                fs.writeFile(dest, data, (err) => {
                    if (err) throw err;
                    copyComplete();
                });
            else
                copyComplete();
        });
    };

    // 拷贝 AssetBundle 完成
    let copyComplete = () => {
        src = src.replace(common.abCacheDir, '').replace(/\\/g, '/');
        dest = dest.replace(common.resDir, '');
        resItemComplete(next, src, dest, isNew, true);
    };
    next();
};


/**
 * 写入 AssetBundle 信息，包括包含的文件，以及依赖的 AssetBundle
 */
let writeAssetBundleInfo = function () {
    // 读取 AssetBundle 依赖信息临时文件
    let depData = fs.readFileSync(common.abDependenciesFile, 'utf8');
    let depMap = JSON.parse(depData);
    fs.writeFileSync(common.depLogFile, depData);

    // resManifest 写入 AssetBundle 信息
    let list = manifest.data.ab;
    for (let i = 0; i < list.length; i++) {
        let abInfo = list[i];
        let assets = abInfo.assets;

        resManifest.push(assets.length + 1);// 数据总数
        resManifest.push(resMap[abInfo.name]);// 资源名称
        let depList = depMap[abInfo.name];
        if (depList === undefined)
            resManifest.push(0);
        else {
            resManifest.push(depList.length);// 依赖的资源总数
            for (let i = 0; i < depList.length; i++)
                resManifest.push(resMap[depList[i]]);// 依赖的资源
        }

        for (let i = 0; i < assets.length; i++)
            resManifest.push(assets[i].replace('Assets/Res/', ''));// 包含的资源
    }

    allComplete();
};


/**
 * 资源全部拷贝完成
 */
let allComplete = function () {
    // 本次打包生成的资源清单
    common.writeFileSync(common.resManifestFile, resManifest.join('\n'));

    // 资源映射表
    common.writeFileSync(common.resLogFile, JSON.stringify(resMap, null, 2));

    // 新增资源
    logger.append(`- 共有 ${newResList.length} 个新增资源`);
    for (let i = 0; i < newResList.length; i++) {
        let src = newResList[i];
        logger.append(`* ${src} -> ${resMap[src]}`);
    }

    logger.append('- 拷贝资源完成');
    progress.setTiming(progress.TT_COPY_RES, false);
    callback();
};

