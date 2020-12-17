/**
 * [ 独立脚本 ]
 * 启动 web 服务
 * Created by LOLO on 2019/4/25.
 */

const http = require('http');
const url = require('url');
const path = require('path');
const fs = require('fs');
const os = require('os');
const args = require('commander');
const config = require('./config/config');


// 解析命令行参数
args
    .version('0.1.0')
    .option('-p, --port <value>', '绑定的端口号')
    .parse(process.argv);


const PORT = args.port === undefined ? 1208 : args.port;
const ROOT_DIR = path.normalize(`${__dirname}/../`);
const WEB_DIR = path.normalize(`${ROOT_DIR}web/`);
const BUILD_DIR = path.normalize(config.buildDir !== '' ? config.buildDir : ROOT_DIR + 'build/');
const LOG_DIR = path.normalize(`${BUILD_DIR}log/`);


// mime type
const MIME = {
    ico: 'image/x-icon',
    html: 'text/html',
    css: 'text/css',
    js: 'text/javascript',
    log: 'text/plain',
    txt: 'text/plain',
    zip: 'application/octet-stream',
    binary: 'application/octet-stream',
};


const server = http.createServer((request, response) => {
    let pathName = url.parse(request.url).pathname;
    let ext = path.extname(pathName);
    ext = ext ? ext.slice(1) : 'unknown';
    let dir;
    switch (ext) {
        case 'log':
            dir = LOG_DIR;
            break;
        case 'zip':
            dir = BUILD_DIR;
            break;
        default :
            dir = WEB_DIR;
    }
    let filePath = dir + pathName.slice(1);

    let errHandler = (err) => {
        response.writeHead(500, {'Content-Type': MIME.txt});
        response.end(err.toString());
    };
    let size = 0;
    fs.stat(filePath, (err, stats) => {
        if (err) {
            // 可能是 zip 包的绝对路径
            if (ext === 'zip') {
                try {
                    filePath = pathName;
                    stats = fs.statSync(filePath);
                    size = stats.size;
                } catch (err) {
                    errHandler(err);
                    return;
                }
            } else {
                errHandler(err);
                return;
            }
        } else {
            size = stats.size;
        }

        response.writeHead(200, {
            'Content-Type': MIME[ext] || MIME.binary,
            'Content-Length': size
        });

        let rs = fs.createReadStream(filePath);
        rs.on('error', (err) => {
            errHandler(err);
        });
        rs.on('data', (data) => {
            response.write(data, 'binary');
        });
        rs.on('end', () => {
            response.end();
        });
    });
});


// 获取 IP 地址
let ip = '';
let interfaces = os.networkInterfaces();
for (let devName in interfaces) {
    let iface = interfaces[devName];
    for (let i = 0; i < iface.length; i++) {
        let alias = iface[i];
        if (alias.family === 'IPv4' && alias.address !== '127.0.0.1' && !alias.internal) {
            ip = alias.address;
        }
    }
}


// 启动服务
server.listen(PORT);
console.log('HTTP 服务器启动成功，访问地址：');
console.log(`http://${ip}:${PORT}/index.html?packid=0`);

