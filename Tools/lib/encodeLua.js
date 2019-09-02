/**
 * 编码 lua
 * Created by LOLO on 2019/4/4.
 */

const fs = require('fs');
const child_process = require('child_process');
const common = require('./common');
const logger = require('./logger');
const manifest = require('./manifest');
const progress = require('./progress');

const encodeLua = module.exports = {};


let index = 0;// 当前已编码文件索引（数量）
let callback = null;// 全部编码完成时的回调


/**
 * 开始编码（拷贝）lua 文件
 * @param cb
 */
encodeLua.start = function (cb) {
    callback = cb;
    progress.setTiming(progress.TT_LUA, true);
    logger.append("- 开始编码 lua 文件");
    encodeNext();
};


let encodeNext = function () {
    let cmd = common.luaEndcoder;
    let luaFile = manifest.data.lua[index];
    let inFile = common.projectDir + luaFile;
    let outFile = common.luaCacheDir + luaFile;

    // jit 目录下的 lua 文件，不使用 jit 模式
    let inJitDir = !common.luajit && inFile.indexOf('ToLua/Lua/jit/') !== -1;

    // 不需要编码，直接拷贝
    if (common.notEncode || inJitDir) {
        fs.readFile(inFile, (err, data) => {
            if (err) throw err;
            common.createDir(outFile);
            fs.writeFile(outFile, data, (err) => {
                if (err) throw err;
                encodeComplete();
            });
        });
        return;
    }

    // 调用外部程序，编码 lua 文件
    cmd += common.luajit
        ? ` -b ${inFile} ${outFile}`
        : ` -o ${outFile} ${inFile}`;

    common.createDir(outFile);
    child_process.exec(cmd, {cwd: common.luaEndcoderDir}, (err, stdout, stderr) => {
        if (err) throw err;
        encodeComplete();
    });
};


let encodeComplete = function () {
    progress.lua(++index);
    if (index === manifest.data.lua.length) {
        if (common.notEncode)
            logger.append("- 无需编码 lua 文件，已全部拷贝完成");
        else
            logger.append("- 编码 lua 文件已全部完成");
        progress.setTiming(progress.TT_LUA, false);
        callback();
    }
    else
        encodeNext();
};

