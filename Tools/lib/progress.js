/**
 * 记录进度日志文件（common.progressLogFile）
 * Created by LOLO on 2019/4/3.
 */


const fs = require('fs');
const common = require('./common');


const progress = module.exports = {};


// [0]:当前，[1]:总数, [2]:耗时
let data = progress.data = {
    status: 1,// 整体状态。0:打包成功，1:正在进行中，2:打包出错
    totalTime: 0,// 总耗时
    svn: [0, 0, 0],// 项目检出或更新，svn / git
    manifest: [0, 2, 0],// 0:未创建，1:已创建，2:已读取
    lua: [0, 1, 0],// 0:已完成数，1:总数，2:已耗时
    scene: [0, 1, 0],// ~~
    ab: [0, 1, 0],// ~~
    copyRes: [0, 1, 0],// ~~
    gpp: [0, 0, 0],// 0:未开始，1:已生成，2:已更新
    daz: [0, 2, 0],// 0:未开始，1:dest complete，2:pack zip complete
};
let handle = null;


// 记录各功能的开始时间，用于统计耗时。
// total:总耗时，manifest:生成和读取打包清单耗时，lua:lua编译耗时，scene:打包场景耗时，ab:打包AssetBundle耗时
let startTime = {total: Date.now()};

progress.TT_SVN = 'svn';
progress.TT_MANIFEST = 'manifest';
progress.TT_LUA = 'lua';
progress.TT_SCENE = 'scene';
progress.TT_AB = 'ab';
progress.TT_COPY_RES = 'copyRes';
progress.TT_GPP = 'gpp';
progress.TT_DAZ = 'daz';


/**
 * 开始和结束计时
 * @param type
 * @param start
 */
progress.setTiming = function (type, start) {
    if (start)
        startTime[type] = Date.now();
    else {
        updateTime();
        startTime[type] = undefined;
    }
};


/**
 * 更新耗时
 */
let updateTime = function () {
    let now = Date.now();
    data.totalTime = now - startTime.total;
    let list = [
        progress.TT_SVN, progress.TT_MANIFEST, progress.TT_LUA, progress.TT_SCENE, progress.TT_AB,
        progress.TT_COPY_RES, progress.TT_GPP, progress.TT_DAZ
    ];
    for (let i = 0; i < list.length; i++) {
        let type = list[i];
        let time = startTime[type];
        if (time !== undefined) data[type][2] = now - time;
    }
};


//


/**
 * 更新整体状态，并立即写入文件
 * 程序结束时调用
 * @param status
 */
progress.status = function (status) {
    data.status = status;
    fs.writeFileSync(common.progressLogFile, progress.getData());
};


/**
 * 更新已完成 svn/git 项目更新或检出数量
 * @param count
 */
progress.versionControl = function (count) {
    data.svn[0] = count;
    update();
};


/**
 * 更新 manifest 进度状态
 * @param status
 */
progress.manifest = function (status) {
    data.manifest[0] = status;
    if (status === 2) {
        let manifestData = require('./manifest').data;
        data.lua[1] = manifestData.lua.length;
        data.scene[1] = manifestData.scene.length;
        data.ab[1] = manifestData.ab.length;
        data.copyRes[1] = data.lua[1] + data.scene[1] + data.ab[1] + manifestData.bytes.length;
        if (common.generatePlatformProject) data.gpp[1] = 2;// GPP 共两步
    }
    update();
};


/**
 * 更新编码 lua 文件进度
 * @param count
 */
progress.lua = function (count) {
    data.lua[0] = count;
    update();
};


/**
 * 更新打包场景进度
 * @param count
 */
progress.scene = function (count) {
    data.scene[0] = count;
    update();
};


/**
 * 标记打包 AssetBundle 已全部完成
 * 打包 AssetBundle 无法获取单个进度，只能全部标记完成
 */
progress.ab = function () {
    data.ab[0] = data.ab[1];
    update();
};


/**
 * 更新拷贝资源进度
 * @param count
 */
progress.copyRes = function (count) {
    data.copyRes[0] = count;
    update();
};


/**
 * 创建或更新目标平台项目进度状态
 * @param status
 */
progress.gpp = function (status) {
    data.gpp[0] = status;
    update();
};


/**
 * dest and zip 增加进度状态
 */
progress.daz = function () {
    data.daz[0]++;
    update();
};


/**
 * 更新进度
 */
let update = function () {
    if (handle === null)
        handle = setTimeout(doUpdate, 500);
};

let doUpdate = function () {
    fs.writeFile(common.progressLogFile, progress.getData(), (err) => {
        if (err) throw err;
        handle = setTimeout(doUpdate, 1000);
    });
};


/**
 * 获取进度 json 字符串描述
 */
progress.getData = function () {
    updateTime();
    return JSON.stringify(data);
};


// 先创建文件，写入默认进度
common.writeFileSync(common.progressLogFile, progress.getData());
update();
