/**
 * [ 独立脚本 ]
 * 拷贝资源文件到平台项目资源目录下
 * Created by LOLO on 2019/10/10.
 */


const path = require('path');
const fs = require('fs');
const args = require('commander');
const zipper = require('zip-local');


// 解析命令行参数
args
    .version('1.0.0')
    .option('-s, --src <value>', '要拷贝的资源所在目录，或 zip 文件路径')
    .option('-d, --dest <value>', '要拷贝至的平台项目路径')
    .option('-t, --platform <value>', '目标平台，可接受值: ios, android')
    .parse(process.argv);


const platform = args.platform;
const isAndroid = platform === 'android';

let destDir = path.normalize(args.dest + '/');
if (isAndroid && fs.existsSync(`${destDir}unityLibrary/`))// android unity2019
    destDir += 'unityLibrary/';

const src = args.src;
const isZip = path.extname(src) === '.zip';
const tmpDir = path.normalize(`../tmp/${Date.now()}/`);
const tmpUnzipDir = `${tmpDir}unzip/`;
const tmpBinDir = `${tmpDir}bin/`;
let srcDir = isZip ? tmpUnzipDir : path.normalize(src + '/');
const resDir = isAndroid ? `${destDir}src/main/assets/` : `${destDir}Data/Raw/`;
const resBinDir = `${resDir}bin/`;

let isRenameBin = false;


//


/**
 * 捕获全局异常
 */
process.on('uncaughtException', function (err) {
    restore();
    console.error(err.stack);
    process.exit(2);
    throw Error("Exit");
});


/**
 * 还原 android res/bin 目录
 * 删除临时文件夹
 */
function restore() {
    try {
        if (isRenameBin) {
            fs.renameSync(tmpBinDir, resBinDir);
            console.log('restore res bin!');
        }

        removeDir(tmpDir);

        let rootTmpDir = path.normalize(tmpDir + '../');
        let files = fs.readdirSync(rootTmpDir);
        if (files.length === 0 || (files.length === 1 && files[0] === '.DS_Store')) {
            removeDir(rootTmpDir);
        }

        console.log('remove temp dir!');
    } catch (e) {
    }
}


/**
 * 入口，流程
 */
function main() {
    // 先解压 zip
    if (isZip) {
        console.log('unzip...');
        createDir(tmpUnzipDir + 'o.o');
        zipper.sync.unzip(src).save(tmpUnzipDir);
        console.log('unzip complete!');
    }

    // 如果有子目录，version.cfg 所在子目录才是 srcDir
    let srcFiles = fs.readdirSync(srcDir)
    for (let i = 0; i < srcFiles.length; i++) {
        let srcFile = path.join(srcDir, srcFiles[i]);
        if (fs.statSync(srcFile).isDirectory()) {
            if (fs.existsSync(path.join(srcFile, 'version.cfg'))) {
                srcDir = srcFile;
                break;
            }
        }
    }

    // android 先备份 bin 目录
    if (isAndroid) {
        console.log('backup res bin...');
        isRenameBin = true;
        createDir(tmpBinDir + 'o.o');
        fs.renameSync(resBinDir, tmpBinDir);
    }

    // 拷贝文件到资源目录
    console.log(`copy ${platform} res...`);
    removeDir(resDir);
    copyDir(srcDir, resDir);
    console.log(`copy ${platform} res complete!`);

    // 删除 res.lua 文件
    let resLuaFile = path.join(resDir, 'res.lua');
    if (fs.existsSync(resLuaFile))
        fs.unlinkSync(resLuaFile);

    // 清理，还原
    restore();
    console.log('all complete!');
}

main();


//


/**
 * 创建文件路径对应的所有层级的父目录
 * @param filePath
 */
function createDir(filePath) {
    let sep = '/';
    filePath = filePath.replace(/\\/g, sep);
    let dirs = path.dirname(filePath).split(sep);
    let p = '';
    while (dirs.length) {
        p += dirs.shift() + sep;
        if (!fs.existsSync(p))
            fs.mkdirSync(p);
    }
}


/**
 * 删除目录，以及目录中所有的文件和子目录
 * @param dirPath
 */
function removeDir(dirPath) {
    if (!fs.existsSync(dirPath)) return;

    let files = fs.readdirSync(dirPath);
    for (let i = 0; i < files.length; i++) {
        let filePath = path.join(dirPath, files[i]);
        if (fs.statSync(filePath).isDirectory()) {
            removeDir(filePath);
        } else {
            fs.unlinkSync(filePath);
        }
    }
    fs.rmdirSync(dirPath);
}


/**
 * 拷贝目录，包括文件和子目录
 * @param oldDir
 * @param newDir
 */
function copyDir(oldDir, newDir) {
    let files = fs.readdirSync(oldDir);
    if (files.length === 0) return;
    if (!fs.existsSync(newDir)) fs.mkdirSync(newDir);
    for (let i = 0; i < files.length; i++) {
        let oldFile = path.join(oldDir, files[i]);
        let newFile = path.join(newDir, files[i]);
        if (fs.statSync(oldFile).isDirectory())
            copyDir(oldFile, newFile);
        else {
            if (!oldFile.endsWith('.DS_Store')
                && !oldFile.endsWith('.meta')
            ) fs.copyFileSync(oldFile, newFile);
        }
    }
}

