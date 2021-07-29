/**
 * 生成或更新目标平台项目 iOS / Android
 * Created by LOLO on 2019/4/15.
 */


const fs = require('fs');
const path = require('path');
const child_process = require('child_process');
const common = require('./common');
const logger = require('./logger');
const progress = require('./progress');
const destAndZip = require('./destAndZip');

const platform = module.exports = {};


let callback;// 完成时的回调
let ppName = common.targetPlatform === 'ios' ? 'XCode' : 'AndroidStudio';
let isAndroidUnity2019 = false;

// 需要合并的文件夹
const combineDirs = {
    android: {
        move: ['libs/', 'src/main/jniLibs/', 'src/main/jniStaticLibs/', 'src/main/Il2CppOutputProject/'],
        merge: ['src/main/assets/', 'src/main/java/shibaInu/'],
        res: 'src/main/assets/',// 打包生成的所有资源存放目录
    },
    ios: {
        move: [],
        merge: ['Data/', 'Classes/', 'Libraries/'],
        res: 'Data/Raw/',
    },
};


/**
 * 开始生成目标平台项目
 * @param cb
 */
platform.start = function (cb) {
    callback = cb;
    if (!common.generatePlatformProject) {
        callback();
        return;
    }

    progress.setTiming(progress.TT_GPP, true);
    let logstr = `- 开始生成 ${ppName} 项目`;
    if (common.development) logstr += '（Development）';
    logger.append(logstr);

    // 清空 StreamingAssets 文件夹
    let saDir = common.projectDir + 'Assets/StreamingAssets/';
    if (fs.existsSync(saDir)) common.removeDir(saDir);
    fs.mkdirSync(saDir);

    // 启动 unity 进程
    let cmd = common.unityCmd;
    cmd += ' -executeMethod ShibaInu.Builder.GeneratePlatformProject';
    cmd += ` -targetPlatform ${common.targetPlatform}`;
    cmd += ` -outputDir ${common.tmpPlatformDir}`;
    cmd += ` -development ${common.development}`;
    child_process.exec(cmd, (err, stdout, stderr) => {
        if (err) throw err;
        common.verifyUnityLogError();
        logger.append(`- 生成 ${ppName} 项目完成`);
        progress.gpp(1);
        generateComplete();
    });
};


/**
 * 创建目标平台项目完成，项目路径为 tmpPlatformDir
 */
let generateComplete = function () {
    let isAndroid = common.targetPlatform === 'android';
    if (isAndroid) {
        isAndroidUnity2019 = fs.existsSync(`${common.tmpPlatformDir}unityLibrary/`);
        if (isAndroidUnity2019) {
            // unity2019 项目在 unityLibrary 目录中
            common.tmpPlatformDir += 'unityLibrary/';
        } else {
            // unity2018 项目会生成在子目录中
            common.tmpPlatformDir += `${fs.readdirSync(common.tmpPlatformDir)[0]}/`;
        }
        // 拷贝框架 java 代码
        common.copyDir(common.androidJavaDir, `${common.tmpPlatformDir}src/main/java/`);
    }
    else {
        // 拷贝框架 Object-C 代码
        common.copyDir(common.iOSObjCDir, `${common.tmpPlatformDir}Sources/`);
    }

    let resDir = combineDirs[common.targetPlatform].res;
    let androidResBinDir = `${common.tmpPlatformDir}${resDir}bin/`;
    let androidResBinBakDir = `${common.tmpPlatformDir}${resDir}../bin_bak/`;
    if (isAndroid)
        fs.renameSync(androidResBinDir, androidResBinBakDir);// 备份 bin 目录到上级目录

    // 拷贝打包生成的所有资源到 tmpPlatformDir
    destAndZip.destRes(common.tmpPlatformDir + resDir, () => {
        if (isAndroid)
            fs.renameSync(androidResBinBakDir, androidResBinDir);// 还原 bin 目录
        updatePlatformProject();
    });
};


/**
 * 更新目标平台项目
 */
let updatePlatformProject = function () {
    logger.append(`- 开始更新 ${ppName} 项目`);

    let dirParent = '';
    if (isAndroidUnity2019) {
        dirParent = 'unityLibrary/';// unity2019 需要添加前置目录
        common.tmpPlatformDir = path.normalize(common.tmpPlatformDir + '../');// 回到上一级目录
    }

    // 没生成过，直接改名
    if (!fs.existsSync(common.targetPlatformDir)) {
        fs.renameSync(common.tmpPlatformDir, common.targetPlatformDir);
        updateComplete();
    }

    // 同步文件夹内容
    else {
        // 删除资源目录
        let dirs = combineDirs[common.targetPlatform];
        common.removeDir(common.targetPlatformDir + dirParent + dirs.res);

        // 移动目录
        for (let i = 0; i < dirs.move.length; i++) {
            let dirName = dirParent + dirs.move[i];
            if (fs.existsSync(common.tmpPlatformDir + dirName))
                common.moveDir(common.tmpPlatformDir + dirName, common.targetPlatformDir + dirName);
        }

        // 合并目录
        let count = dirs.merge.length;
        let index = -1;
        let next = () => {
            if (++index === count) {
                updateComplete();
                return;
            }
            let dirName = dirParent + dirs.merge[index];
            common.mergeDir(common.tmpPlatformDir + dirName, common.targetPlatformDir + dirName, next);
        };
        next();
    }
};


/**
 * 更新目标平台项目完成
 */
let updateComplete = function () {
    logger.append(`- 更新 ${ppName} 项目完成`);
    progress.gpp(2);
    progress.setTiming(progress.TT_GPP, false);
    callback();
};

