//

const fs = require('fs');
const args = require('../node_modules/commander');


args.android = false;
args
    .version('0.1.0')
    .option('-a, --android', 'true：将资源拷贝到Android Studio项目资源目录，false[默认]：将资源拷贝到Xcode项目资源目录')
    .parse(process.argv);

const ANDROID = args.android;
const RES_DIR = __dirname + '/../../Assets/StreamingAssets/';
const TAR_DIR = __dirname + '/../../PlatformProjects/' + (ANDROID
            ? 'AndroidStudio/src/main/assets/'
            : 'Xcode/Data/Raw/'
    );


//


//
// copy res
//
let [binDir, pbinDir] = [`${TAR_DIR}bin/`, `${TAR_DIR}../bin/`];
if (ANDROID) copyDir(binDir, pbinDir);// 先把bin目录拷贝至上层
removeDir(TAR_DIR);
copyDir(RES_DIR, TAR_DIR);
if (ANDROID) {
    copyDir(pbinDir, binDir);// 拷回bin目录
    removeDir(pbinDir);
    console.log('Copy Res to Android Studio Project Completed!');
} else {
    console.log('Copy Res to Xcode Project Completed!');
}


//


//


/**
 * 拷贝一个文件夹，包括子文件和子目录
 * @param oldDir
 * @param newDir
 */
function copyDir(oldDir, newDir) {
    oldDir = formatDirPath(oldDir);
    newDir = formatDirPath(newDir);
    let files = fs.readdirSync(oldDir);
    if (files.length === 0) return;
    createDir(newDir);
    for (let i = 0; i < files.length; i++) {
        let oldFile = oldDir + files[i];
        let newFile = newDir + files[i];
        if (fs.statSync(oldFile).isDirectory())
            copyDir(oldFile, newFile);
        else
            copyFile(oldFile, newFile);
    }
}

/**
 * 拷贝一个文件
 * @param oldFile
 * @param newFile
 */
function copyFile(oldFile, newFile) {
    if (oldFile.endsWith('.meta') || oldFile.endsWith('.manifest')
        || oldFile.endsWith('.DS_Store') || oldFile.endsWith('TestModeFlag')
    ) return;

    let buffer = fs.readFileSync(oldFile);
    fs.writeFileSync(newFile, buffer);
}

/**
 * 创建文件夹，包括父目录
 * @param path
 */
function createDir(path) {
    path = path.replace(/\\/g, '/');
    let arr = path.split('/');
    path = arr[0];
    for (let i = 1; i < arr.length; i++) {
        if (arr[i] === '') continue;
        path += '/' + arr[i];
        if (!fs.existsSync(path)) {
            fs.mkdirSync(path);
        }
    }
}

/**
 * 删除一个目录下的所有文件和子文件夹
 * @param path
 */
function removeDir(path) {
    let files = [];
    if (fs.existsSync(path)) {
        files = fs.readdirSync(path);
        files.forEach(function (file, index) {
            let curPath = path + '/' + file;
            if (fs.statSync(curPath).isDirectory()) {
                removeDir(curPath);
            } else {
                fs.unlinkSync(curPath);
            }
        });
        fs.rmdirSync(path);
    }
}

/**
 * 格式化文件夹路径
 * @param dirPath
 */
function formatDirPath(dirPath) {
    if (dirPath === null) return null;
    dirPath = dirPath.replace(/\\/g, '/');
    if (dirPath.substring(dirPath.length - 1) !== '/') dirPath += '/';
    return dirPath;
}


