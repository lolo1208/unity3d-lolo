var args = require("./node_modules/commander");
var fs = require("fs");


args.android = false;
args
    .version('0.1.0')
    .option('-a, --android', 'true：将资源拷贝到Android Studio项目资源目录，false[默认]：将资源拷贝到Xcode项目资源目录')
    .parse(process.argv);

var isAndroid = args.android;
var RES_DIR = __dirname + "/../../Assets/StreamingAssets/";
var TAR_DIR = __dirname + "/../../PlatformProjects/" + (isAndroid
            ? "AndroidStudio/src/main/assets/"
            : "Xcode/Data/Raw/"
    );


//

// Copy Res
if (isAndroid) copyDir(TAR_DIR + "bin/", TAR_DIR + "../bin/");// 先把bin目录拷贝至上层
removeDir(TAR_DIR);
copyDir(RES_DIR, TAR_DIR);
if (isAndroid) {
    copyDir(TAR_DIR + "../bin/", TAR_DIR + "bin/");// 拷回bin目录
    removeDir(TAR_DIR + "../bin/");
    console.log("Copy Res to Android Studio Project Completed!");
} else {
    console.log("Copy Res to Xcode Project Completed!");
}

//


/**
 * str 的结束内容是否为 endValue
 * @param str
 * @param endValue
 */
function endsWith(str, endValue) {
    return str.substring(str.length - endValue.length) === endValue;
}


/**
 * 拷贝一个文件夹，包括子文件和子目录
 * @param oldDir
 * @param newDir
 */
function copyDir(oldDir, newDir) {
    oldDir = formatDirPath(oldDir);
    newDir = formatDirPath(newDir);
    var files = fs.readdirSync(oldDir);
    if (files.length === 0) return;
    createDir(newDir);
    for (var i = 0; i < files.length; i++) {
        var oldFile = oldDir + files[i];
        var newFile = newDir + files[i];
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
    if (endsWith(oldFile, ".meta") || endsWith(oldFile, ".manifest")
        || endsWith(oldFile, ".DS_Store") || endsWith(oldFile, "TestModeFlag")
    ) return;

    var buffer = fs.readFileSync(oldFile);
    fs.writeFileSync(newFile, buffer);
}

/**
 * 创建文件夹，包括父目录
 * @param path
 */
function createDir(path) {
    path = path.replace(/\\/g, "/");
    var arr = path.split("/");
    path = arr[0];
    for (var i = 1; i < arr.length; i++) {
        if (arr[i] === "") continue;
        path += "/" + arr[i];
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
    var files = [];
    if (fs.existsSync(path)) {
        files = fs.readdirSync(path);
        files.forEach(function (file/*, index*/) {
            var curPath = path + "/" + file;
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
    dirPath = dirPath.replace(/\\/g, "/");
    if (dirPath.substring(dirPath.length - 1) !== "/") dirPath += "/";
    return dirPath;
}


