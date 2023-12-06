/**
 * [ 独立脚本 ]
 * 根据分包配置文件，在已打出的资源包中分出多个 DLC 包。
 * Created by LOLO on 2023/12/05.
 */

// const readline = require('readline');
const fs = require('fs-extra');
const args = require('commander');
const zipper = require('zip-local');
const LineByLine = require('n-readlines');


// 解析命令行参数
args
    .version('1.0.0')
    .option('-c, --config <value>', '分包配置文件路径')
    .option('-s, --srcZip <value>', '已打出的资源包 zip 文件路径')
    .option('-d, --destDir <value>', '生成的所有分包的存储目录路径')
    .parse(process.argv);


const config = args.config;
const srcZip = args.srcZip;
const destDir = args.destDir;
const unzipDir = `${destDir}/uncompress/`;


//


/**
 * 捕获全局异常
 */
process.on('uncaughtException', function (err) {
    console.error(err.stack);
    process.exit(2);
    throw Error("Exit");
});



//


/**
 * 入口，流程
 */
function main() {
    // 读取配置文件，将 dlc 和场景的名称映射到对应的 map 上
    const cfg = JSON.parse(fs.readFileSync(config));
    const list = cfg.list;
    const sceneMap = {};
    const dlcMap = {};
    list.forEach(item => {
        item.scenes.forEach(sceneName => {
            sceneMap[sceneName] = item.exportName;
        });
        dlcMap[item.dlcName] = item.exportName;
    });

    // 先清空临时目录，再将 zip 解压到该目录
    fs.emptyDirSync(unzipDir);
    zipper.sync.unzip(srcZip).save(unzipDir);

    // 获取版本号
    const version = fs.readFileSync(`${unzipDir}version.cfg`, 'utf8');
    const manifestFile = `${unzipDir}${version}.manifest`;
    const versionDir = `${destDir}/${version}/`;
    fs.emptyDirSync(versionDir);

    // 解析 manifest，将属于 dlc 的文件拷到对应的目录中
    let [phase, count, index] = [1, 0, 0];

    const liner = new LineByLine(manifestFile);
    let line, resName, abName, exportName, exportDir;
    while (line = liner.next()) {
        switch (phase) {

            // 读取 lua 列表
            case 1:
                if (count === 0)
                    count = parseInt(line);
                else {
                    // console.log(line);
                    liner.next();
                    if (++index === count) {
                        count = index = 0;
                        phase++;
                    }
                }
                break;

            // Res 与 StreamingAssets 目录下需要被拷贝的文件列表
            case 2:
                if (count === 0) {
                    count = parseInt(line);
                    if (count === 0) phase++;// 可能没有需要直接拷贝的文件
                } else {
                    // console.log(line);
                    liner.next();
                    if (++index === count) {
                        count = index = 0;
                        phase++;
                    }
                }
                break;

            // 读取场景列表
            case 3:
                if (count === 0) {
                    count = parseInt(line);
                }
                else {
                    resName = line.toString('utf8');
                    abName = liner.next().toString('utf8');
                    exportName = sceneMap[resName];
                    if (exportName) {
                        exportDir = `${versionDir}dlc/${exportName}/`;
                        fs.moveSync(`${unzipDir}${abName}`, `${exportDir}${abName}`);
                    }

                    if (++index === count) {
                        count = index = 0;
                        phase++;
                    }
                }
                break;

            // 读取 AssetBundle 信息（读取 AB 信息只能放在最后一个阶段，不能再升阶）
            case 4:
                if (count === 0)
                    count = parseInt(line);
                else {
                    if (index === 0) {
                        abName = line.toString('utf8');
                        // 解析依赖列表
                        let num = parseInt(liner.next());
                        for (let i = 0; i < num; i++)
                            liner.next();
                    }
                    else {
                        resName = line.toString('utf8');
                        let pathArr = resName.split('/');
                        if (pathArr[0].toLocaleLowerCase() === 'dlc') {
                            exportName = dlcMap[pathArr[1]];
                            if (exportName) {
                                exportDir = `${versionDir}dlc/${exportName}/`;
                                let abPath = `${unzipDir}${abName}`;
                                if (fs.existsSync(abPath)) {
                                    fs.moveSync(abPath, `${exportDir}${abName}`);
                                }
                            }
                        }
                    }
                    if (++index === count) {
                        count = index = 0;
                    }
                }
                break;
        }
    }

    // 剩下的内容是主包体
    fs.moveSync(unzipDir, `${versionDir}app/`);


    console.log('complete.');
}

main();