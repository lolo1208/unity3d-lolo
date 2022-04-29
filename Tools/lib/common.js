/**
 * 公用常量，变量和方法
 * Created by LOLO on 2019/3/29.
 */


const path = require('path');
const fs = require('fs');
const crypto = require('crypto');
const args = require('commander');
const config = require('./config/config');

const common = module.exports = {};


// 解析命令行参数
args
    .version('1.0.0')
    .option('-i, --id <value>', '本次打包唯一标识符')
    .option('-p, --projectName <value>', '项目名称')
    .option('-v, --versionName <value>', '传入的（3或4位）用于显示的版本号')
    .option('-t, --targetPlatform <value>', '目标平台，可接受值: ios, android, macos, windows')
    .option('-n, --notEncode', '是否不需要编码 lua 文件')
    .option('-g, --generatePlatformProject', '是否生成目标平台项目，只支持: ios, android')
    .option('-u, --unityVersion <value>', '使用的 unity 版本号，默认值为: config.unityVersion')
    .option('-f, --projectPath <value>', '项目路径')
    .option('-s, --svnOrGitConfigName <value>', 'svn 或 git 配置名称')
    .option('-c, --platformProject <value>', '目标平台项目路径。如果传入了该参数，-g 参数将为 true')
    .option('-d, --destDir <value>', '将生成的资源拷贝至该目录')
    .option('-z, --packZip <value>', '传入值为 true，表示生成 zip 文件，并放在缓存目录中。也可以传入完整 zip 路径，将按该路径生成')
    .option('-a, --zipForAST <value>', '生成 AST zip 文件，传入的值为渠道列表，使用 "," 分割。例："appstore,android,taptap"')
    .option('-y, --abModeFlag', '是否需要创建进入 AssetBundle 模式的标志文件')
    .option('-x, --development', '是否生成开发版本的目标平台项目')
    .parse(process.argv);

common.id = args.id;                                            // -i
common.projectName = args.projectName;                          // -p
common.versionName = args.versionName;                          // -v
common.targetPlatform = args.targetPlatform;                    // -t
common.notEncode = args.notEncode;                              // -n
common.generatePlatformProject = args.generatePlatformProject;  // -g
common.unityVersion = args.unityVersion;                        // -u
common.projectPath = args.projectPath;                          // -f
common.svnOrGitConfigName = args.svnOrGitConfigName;            // -s
common.platformProject = args.platformProject;                  // -c
common.destDir = args.destDir;                                  // -d
common.packZip = args.packZip;                                  // -z
common.zipForAST = args.zipForAST;                              // -a
common.abModeFlag = args.abModeFlag;                            // -y
common.development = args.development;                          // -x

if (common.unityVersion === undefined)
    common.unityVersion = config.unityVersion;

if (common.platformProject !== undefined) {
    common.platformProject = path.normalize(common.platformProject + '/');
    common.generatePlatformProject = true;
}
if (common.generatePlatformProject === true)
    common.generatePlatformProject = common.targetPlatform === 'ios' || common.targetPlatform === 'android';

if (common.projectPath !== undefined) common.projectPath = path.normalize(common.projectPath + '/');
if (common.destDir !== undefined) {
    common.destDir = path.normalize(common.destDir + '/');
    if (common.abModeFlag)
        common.abModeFlagFile = common.destDir + 'AssetBundleMode.flag';
}


// 程序是否运行在 windows 平台
common.isWindows = process.platform === 'win32';
// version.cfg 文件名称
common.versionConfigFileName = 'version.cfg';


// 工具箱根目录
common.rootDir = path.normalize(`${__dirname}/../`);
// 编译打包目录
common.buildDir = config.buildDir !== '' ? config.buildDir : `${common.rootDir}build/`;
// 其他工具目录
common.toolsDir = `${common.rootDir}tools/`;
// 项目编译打包目录
common.projectBuildDir = `${common.buildDir}${common.projectName}/`;
// 日志目录
common.logDir = `${common.buildDir}log/${common.id}/`;
// 资源产出目录
common.resDir = `${common.projectBuildDir}res/${common.targetPlatform}/`;
// 默认 zip 产出目录
common.zipDir = `${common.projectBuildDir}zip/${common.targetPlatform}/`;
// 版本资源清单目录
common.resManifestDir = `${common.resDir}manifest/`;
// 检出 svn/git 的本地目录
common.sourceDir = `${common.projectBuildDir}source/`;
// 检出 svn/git 后的项目目录
common.sourceProjectDir = `${common.sourceDir}project/`;
// 缓存目录
common.cacheDir = `${common.projectBuildDir}cache/`;
// lua（Encode 完成后的）缓存目录
common.luaCacheDir = `${common.cacheDir}lua/`;
// 场景（打包完成后的）缓存目录
common.sceneCacheDir = `${common.cacheDir}scene/${common.targetPlatform}/`;
// AssetBundle （打包完成后的）缓存目录
common.abCacheDir = `${common.cacheDir}assetbundle/${common.targetPlatform}/`;
// 平台项目根目录
common.platformDir = `${common.projectBuildDir}platform/`;
// 目标平台项目目录
if (common.platformProject !== undefined)
    common.targetPlatformDir = common.platformProject;
else
    common.targetPlatformDir = `${common.platformDir}${common.targetPlatform}/`;
// 临时产出的平台项目目录
common.tmpPlatformDir = `${common.platformDir}tmp/`;


// Android 平台的 Java 代码目录
common.androidJavaDir = `${common.rootDir}templates/java/`;
// iOS 平台的 Object-C 代码目录
common.iOSObjCDir = `${common.rootDir}templates/objc/`;


// lua 编码工具路径
switch (common.targetPlatform) {
    case 'ios':
    case 'windows':
    case 'android':
        common.luajit = true;// jit
        common.luaEndcoder = common.isWindows
            ? `${common.toolsDir}luaEncoder/luajit/luajit.exe`
            : `${common.toolsDir}luaEncoder/luajit_mac/luajit`;
        break;
    case 'macos':
        common.luajit = false;// lua vm
        common.luaEndcoder = `${common.toolsDir}luaEncoder/luavm/luac`;
        break;
    default:
        throw Error('未知的目标平台: ' + common.targetPlatform);
}
// lua 编码工具所在目录路径
if (!common.notEncode)
    common.luaEndcoderDir = path.dirname(common.luaEndcoder);


// 版本号文件路径
common.versionFile = `${common.cacheDir}version.json`;
// 场景 MD5 信息文件路径
common.sceneMD5File = `${common.cacheDir}sceneMD5.json`;
// AssetBundle 依赖信息临时文件路径
common.abDependenciesFile = `${common.cacheDir}dependencies.json`;
// 日志文件路径
common.logFile = `${common.logDir}build.log`;
// svn/git 更新内容日志文件路径
common.versionLogFile = `${common.logDir}version.log`;
// 打包清单文件路径
common.manifestFile = `${common.logDir}manifest.log`;
// 打包进度文件路径
common.progressLogFile = `${common.logDir}progress.log`;
// unity 运行日志文件路径
common.unityLogFile = `${common.logDir}unity.log`;
// unity 输出文件路径（stdout 在 windows 下无法使用）
common.unityOutFile = `${common.logDir}unity.out`;
// 资源映射日志文件路径
common.resLogFile = `${common.logDir}res.log`;
// AssetBundle 依赖信息日志文件路径
common.depLogFile = `${common.logDir}dependencies.log`;


// Unity 程序路径
common.unityPath = (common.isWindows ? config.winUnityPath : config.macUnityPath)
    .replace('[UnityVersion]', common.unityVersion);


// 根据 versionName 生成 buildNumber
let versionCache;
if (fs.existsSync(common.versionFile))
    versionCache = JSON.parse(fs.readFileSync(common.versionFile));
else
    versionCache = {};
if (versionCache[common.versionName] === undefined)
    versionCache[common.versionName] = 0;
common.buildNumber = ++versionCache[common.versionName];
// 完整版本号 = versionName.buildNumber.packid
common.fullVersionNumber = `${common.versionName}.${common.buildNumber}.${common.id}`;

// 版本资源清单文件
common.resManifestFile = `${common.resManifestDir}${common.fullVersionNumber}.manifest`;


// unity 项目路径
if (common.projectPath !== undefined)
    common.projectDir = common.projectPath;
else {
    common.projectDir = common.sourceProjectDir;
}


// 调用 Unity 程序命令行模版
common.unityCmd = `${common.unityPath} -batchmode -nographics -quit -projectPath ${common.projectDir} -logFile ${common.unityLogFile}`;


// Unity Library 目录，和 Library 缓存目录
common.libraryDir = `${common.projectDir}Library/`;
common.libraryCaheRootDir = `${common.cacheDir}library/`;
common.libraryCacheDir = `${common.libraryCaheRootDir}${common.targetPlatform}/`;
common.libraryNativeDir = `${common.libraryCaheRootDir}${common.isWindows ? 'windows' : 'macos'}/`;


//


//


/**
 * 验证 Unity 进程生成的日志中，是否包含了 C# 代码异常
 */
common.verifyUnityLogError = function () {
    let log = fs.readFileSync(common.unityLogFile).toString();
    if (log.lastIndexOf('): error') !== -1)
        throw Error('调用 Unity 程序出错！\nUnity 运行日志中包含 C# Error');
}


/**
 * 结束进程
 * @param code
 */
common.exit = function (code) {
    let buildUnity = require('./buildUnity');
    buildUnity.cacheLibrary();

    let logger = require('./logger');
    let progress = require('./progress');
    logger.append('\n<b>[PROGRESS]:</b>', progress.getData());
    logger.append('\n<b>[EXIT CODE]:</b>', code);
    logger.updateNow();
    progress.status(code);

    process.exit(code);
    throw Error("Exit");// 需要抛错才能结束代码运行？
};


//


//


/**
 * 创建文件路径对应的所有层级的父目录
 * @param filePath
 */
common.createDir = function (filePath) {
    let sep = '/';
    filePath = filePath.replace(/\\/g, sep);
    let dirs = path.dirname(filePath).split(sep);
    let p = '';
    while (dirs.length) {
        p += dirs.shift() + sep;
        if (!fs.existsSync(p))
            fs.mkdirSync(p);
    }
};


/**
 * 删除目录，以及目录中所有的文件和子目录
 * @param dirPath
 */
common.removeDir = function (dirPath) {
    if (!fs.existsSync(dirPath)) return;

    let files = fs.readdirSync(dirPath);
    for (let i = 0; i < files.length; i++) {
        let filePath = path.join(dirPath, files[i]);
        if (fs.statSync(filePath).isDirectory()) {
            common.removeDir(filePath);
        } else {
            fs.unlinkSync(filePath);
        }
    }
    fs.rmdirSync(dirPath);
};


/**
 * 拷贝目录，包括文件和子目录
 * 添加新增文件，覆盖已有文件
 * @param oldDir
 * @param newDir
 */
common.copyDir = function (oldDir, newDir) {
    let files = fs.readdirSync(oldDir);
    if (files.length === 0) return;
    if (!fs.existsSync(newDir)) fs.mkdirSync(newDir);
    for (let i = 0; i < files.length; i++) {
        let oldFile = path.join(oldDir, files[i]);
        let newFile = path.join(newDir, files[i]);
        if (fs.statSync(oldFile).isDirectory())
            common.copyDir(oldFile, newFile);
        else {
            if (!oldFile.endsWith('.DS_Store')
                && !oldFile.endsWith('.meta')
            ) fs.copyFileSync(oldFile, newFile);
        }
    }
};


/**
 * 移动目录
 * 如果目标目录已存在，则先删除目标目录
 * @param srcDir 源目录
 * @param destDir 目标目录
 */
common.moveDir = function (srcDir, destDir) {
    common.removeDir(destDir);
    fs.renameSync(srcDir, destDir);
}


/**
 * 合并两个目录
 * 添加新增文件，更新有变化的文件，（在源目录内）删除已不存在的文件
 * @param srcDir 源目录
 * @param destDir 目标目录
 * @param callback 合并完成时的回调
 */
common.mergeDir = function (srcDir, destDir, callback) {
    // 目标目录不存在，直接改名移动
    if (!fs.existsSync(destDir)) {
        fs.renameSync(srcDir, destDir);
        callback();
        return;
    }

    // 删除目标目录内多余的文件以及子目录
    let destFiles = fs.readdirSync(destDir);
    for (let i = 0; i < destFiles.length; i++) {
        let fileName = destFiles[i];
        let srcFile = path.join(srcDir, fileName);
        // 源目录中已没有该文件，删除
        if (!fs.existsSync(srcFile)) {
            let destFile = path.join(destDir, fileName);
            if (fs.statSync(destFile).isDirectory())
                common.removeDir(destFile);
            else
                fs.unlinkSync(destFile);
        }
    }

    let srcFiles = fs.readdirSync(srcDir);
    let count = srcFiles.length;
    let index = -1;
    let next = () => {
        if (++index === count) {
            callback();
            return;
        }

        let fileName = srcFiles[index];
        let srcFile = path.join(srcDir, fileName);
        let destFile = path.join(destDir, fileName);
        // 目标目录中没有该文件，直接改名移动
        if (!fs.existsSync(destFile)) {
            fs.renameSync(srcFile, destFile);
            next();
        } else {
            if (fs.statSync(srcFile).isDirectory()) {
                common.mergeDir(srcFile, destFile, next);// 目录递归
            } else {
                // 更新内容有变化的文件
                common.getFileMD5(srcFile, (srcMD5) => {
                    common.getFileMD5(destFile, (destMD5) => {
                        if (srcMD5 !== destMD5)
                            fs.renameSync(srcFile, destFile);// 直接改名移动
                        next();
                    });
                });
            }
        }
    };
    next();
};


/**
 * 同步写入文件（并创建文件所在目录）
 * @param path 文件路径
 * @param data 文件数据
 */
common.writeFileSync = function (path, data) {
    common.createDir(path);
    fs.writeFileSync(path, data);
};


/**
 * 获取 字符串 或 buffer 的 md5
 * @param data
 */
common.getMD5 = function (data) {
    return crypto.createHash('md5').update(data).digest('hex');
};


/**
 * 异步获取文件 md5 和 文件数据
 * @param filePath
 * @param callback
 */
common.getFileMD5AndData = function (filePath, callback) {
    fs.readFile(filePath, (err, data) => {
        if (err) throw err;
        callback(common.getMD5(data), data);
    });
};


/**
 * 异步获取文件 md5
 * @param filePath
 * @param callback
 */
common.getFileMD5 = function (filePath, callback) {
    let hash = crypto.createHash('md5');
    let rs = fs.createReadStream(filePath);
    rs.on('data', (chunk) => {
        hash.update(chunk);
    });
    rs.on('end', () => {
        callback(hash.digest('hex'));
    });
};


/**
 * 同步获取文件 md5
 * @param filePath
 */
common.getFileMD5Sync = function (filePath) {
    return crypto.createHash('md5').update(fs.readFileSync(filePath)).digest('hex');
};


//


// 更新保存版本号缓存文件
common.writeFileSync(common.versionFile, JSON.stringify(versionCache, null, 2));