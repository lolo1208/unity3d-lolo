/**
 * 生成 AST zip 文件相关操作
 * Created by LOLO on 2021/08/12.
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const common = require('./common');
const copyRes = require('./copyRes');


const genAstZip = module.exports = {};

let resContent = '';


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
 * @param archive
 */
genAstZip.zip = function (archive) {
    let f1 = formatFileName;
    let f2 = formatResItem;
    let f3 = getFileSize;
    resContent = 'data_res_info = {\n';

    // 版本信息文件
    let hash = crypto.createHash('md5');
    hash.update(common.fullVersionNumber);
    f2(common.versionConfigFileName, hash.digest('hex'), common.fullVersionNumber.length);
    archive.append(common.fullVersionNumber, {name: f1(common.versionConfigFileName)});

    // 资源清单文件
    hash = crypto.createHash('md5');
    let buffer = fs.readFileSync(common.resManifestFile);
    hash.update(buffer);
    let manifestFileName = path.basename(common.resManifestFile);
    f2(manifestFileName, hash.digest('hex'), f3(common.resManifestFile));
    archive.append(fs.createReadStream(common.resManifestFile), {name: f1(manifestFileName)});

    // 资源文件列表
    let list = copyRes.resList;
    for (let i = 0; i < list.length; i++) {
        let fileName = list[i];
        if (resExists(fileName)) continue;
        let filePath = common.resDir + fileName;
        f2(fileName, fileName.substring(0, 32), f3(filePath));
        archive.append(fs.createReadStream(filePath), {name: f1(fileName)});
    }

    // res.lua
    resContent += '}';
    archive.append(resContent, {name: f1('res.lua')});

    // 各渠道 version.lua
    let channels = common.zipForAST.split(',');
    let verLuaContent = `sys_version.game = "${common.versionName}"`;
    for (let i = 0; i < channels.length; i++) {
        archive.append(verLuaContent, {name: channels[i] + '/version.lua'});
    }
}


let formatFileName = function (fileName) {
    return common.versionName + '/' + fileName;
}


let formatResItem = function (name, md5, size) {
    resContent += `["${name}"] = {md5="${md5}", size=${size}},\n`;
}

let getFileSize = function (filePath) {
    return fs.statSync(filePath).size
}