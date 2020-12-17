/**
 * [ 独立脚本 ]
 * 生成 SVN 配置文件
 * Created by LOLO on 2020/12/16.
 */

const fs = require('fs');
const args = require('commander');
const crypto = require('crypto');


// 解析命令行参数
args
    .version('1.0.0')
    .option('-s, --svn <value>', '需要写入配置文件的 svn 相关信息列表，第一条需为主工程项目。格式：url,dest,un,pw|url,de...')
    .option('-u, --username <value>', '默认 svn 账号')
    .option('-p, --password <value>', '默认 svn 密码')
    .option('-n, --cfgName <value>', '生成的配置文件名称。默认值为 -s 参数值的 md5 值')
    .option('-d, --destDir <value>', 'svn 检出的本地目录。默认值为 common.sourceDir')
    .parse(process.argv);


const svn = args.svn;
const username = args.username;
const password = args.password;
const cfgName = args.cfgName;
const destDir = args.destDir;


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
    // 配置文件路径
    let cfgFilePath = cfgName;
    if (cfgFilePath === undefined)
        cfgFilePath = crypto.createHash('md5').update(svn).digest('hex');
    cfgFilePath = `config/${cfgFilePath}.svn.js`;

    // 配置文件已存在
    if (fs.existsSync(cfgFilePath))
        return;

    // 构建需保存的数据
    let data = {username, password, destDir, list: []};

    // 解析 svn 信息列表
    let list = svn.split('|');
    for (let i = 0; i < list.length; i++) {
        let info = list[i].split(',');
        let svn = {};
        svn.url = info[0];
        svn.dest = info[1] ? info[1] : '';
        svn.username = info[2];
        svn.password = info[3];
        data.list.push(svn);
    }

    // 存入文件
    let content = `module.exports = ${JSON.stringify(data, null, 4)}`;
    fs.writeFileSync(cfgFilePath, content);
}

main();

