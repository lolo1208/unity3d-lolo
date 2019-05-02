/**
 * 导出 Unity Scene 和 AssetBundle
 * Created by LOLO on 2019/4/9.
 */


const fs = require('fs');
const path = require('path');
const child_process = require('child_process');
const common = require('./common');
const logger = require('./logger');
const manifest = require('./manifest');
const progress = require('./progress');

const buildUnity = module.exports = {};


let sceneCache = {};
let buildScenes = [];
let callback;// 打包完成时的回调
let sceneIndex;


/**
 * 开始打包
 * @param cb
 */
buildUnity.start = function (cb) {
    callback = cb;

    // 获取缓存的场景 MD5 信息
    if (fs.existsSync(common.sceneMD5File))
        sceneCache = JSON.parse(fs.readFileSync(common.sceneMD5File));
    if (sceneCache[common.targetPlatform] === undefined)
        sceneCache[common.targetPlatform] = {};

    // 对比缓存，得出要打包的场景列表
    let count = manifest.data.scene.length;
    let index = -1;
    let checkNextScene = () => {
        if (++index === count) {
            build();
            return;
        }

        let scenePath = common.projectDir + manifest.data.scene[index];
        let sceneName = path.basename(scenePath, '.unity');
        let cache = sceneCache[common.targetPlatform];
        common.getFileMD5(scenePath, (md5) => {
            // 场景与缓存不一致
            if (md5 !== cache[sceneName]) {
                cache[sceneName] = md5;
                buildScenes.push(index);
            }
            checkNextScene();
        });
    };
    checkNextScene();
};


/**
 * 启动 Unity 进程，开始打包
 */
let build = function () {
    sceneIndex = manifest.data.scene.length - buildScenes.length;
    progress.scene(sceneIndex);
    if (buildScenes.length === 0)
        logger.append('- 没有需要打包的场景');

    // 启动 unity 进程
    let cmd = common.unityCmd;
    cmd += ' -executeMethod ShibaInu.Builder.GenerateAssets';
    cmd += ` -targetPlatform ${common.targetPlatform}`;
    cmd += ` -manifestPath ${common.manifestFile}`;
    cmd += ` -outputDir ${common.cacheDir}`;
    cmd += ` -scenes ${buildScenes.join(',')}`;
    child_process.exec(cmd, (err, stdout, stderr) => {
        if (err) throw err;
        if (readUnityOutHandle !== null)
            clearTimeout(readUnityOutHandle);
        callback();
    });
    delayReadUnityOut();
};


/**
 * 读取 Unity out 文件
 */
let readUnityOut = function () {
    if (fs.existsSync(common.unityOutFile)) {
        fs.readFile(common.unityOutFile, 'utf8', (err, data) => {
            readUnityOutHandle = null;
            if (!err && data !== '') {
                let list = data.split('\n');
                for (let i = 0; i < list.length; i++) {
                    let args = list[i].split(',');
                    switch (args[0]) {
                        case 'build scene start':
                            progress.setTiming(progress.TT_SCENE, true);
                            logger.append('- 开始打包场景');
                            break;

                        case 'build scene complete':
                            progress.scene(++sceneIndex);
                            logger.append(`* 打包场景完成：${args[1]} 耗时：${parseInt(args[2]) / 1000}s`);
                            break;

                        case 'build scene all complete':
                            progress.setTiming(progress.TT_SCENE, false);
                            progress.data.scene[2] = parseInt(args[1]);
                            logger.append('- 打包场景已全部完成');
                            // 记录场景缓存信息
                            common.writeFileSync(common.sceneMD5File, JSON.stringify(sceneCache, null, 2));
                            break;

                        //

                        case 'build assetbundle start':
                            progress.setTiming(progress.TT_AB, true);
                            logger.append('- 开始打包 AssetBundle');
                            break;

                        case 'build assetbundle complete':
                            progress.setTiming(progress.TT_AB, false);
                            progress.data.ab[2] = parseInt(args[1]);
                            progress.ab();
                            logger.append('- 打包 AssetBundle 已全部完成');
                            break;
                    }
                }
            }
            fs.writeFileSync(common.unityOutFile, '');
            delayReadUnityOut();
        });
    } else {
        readUnityOutHandle = null;
        delayReadUnityOut();
    }
};

let readUnityOutHandle = null;
let delayReadUnityOut = function () {
    if (readUnityOutHandle === null)
        readUnityOutHandle = setTimeout(readUnityOut, 500);
};


/**
 * 使用 Unity Library 缓存目录
 */
buildUnity.useLibraryCache = function () {
    common.createDir(common.libraryCaheRootDir + 'o.o');
    // 处理已存在的 [Priject]/Library 目录
    if (fs.existsSync(common.libraryDir)) {
        if (!fs.existsSync(common.libraryNativeDir))
            fs.renameSync(common.libraryDir, common.libraryNativeDir);
        else
            common.removeDir(common.libraryDir);
    }

    if (fs.existsSync(common.libraryCacheDir)) {
        fs.renameSync(common.libraryCacheDir, common.libraryDir);
        logger.append('- 已使用 Unity Library 缓存目录');
    }
};


/**
 * 将 Unity Library 目录缓存起来
 */
buildUnity.cacheLibrary = function () {
    if (fs.existsSync(common.libraryDir) && !fs.existsSync(common.libraryCacheDir)) {
        fs.renameSync(common.libraryDir, common.libraryCacheDir);
        logger.append('- 已缓存 Unity Library 目录');

        if (fs.existsSync(common.libraryNativeDir))
            fs.renameSync(common.libraryNativeDir, common.libraryDir);
    }
};



