/**
 * 打包入口
 * Created by LOLO on 2019/3/27.
 */


const common = require('./common');
const logger = require('./logger');
const versionControl = require('./versionControl');
const manifest = require('./manifest');
const encodeLua = require('./encodeLua');
const buildUnity = require('./buildUnity');
const copyRes = require('./copyRes');
const platform = require('./platform');
const destAndZip = require('./destAndZip');


/**
 * 捕获全局异常
 */
process.on('uncaughtException', function (err) {
    logger.append('\n[ERROR]:', err.stack.replace(/\n\n/g, '\n'), '');
    console.error(err.stack);
    common.exit(1);
});


/**
 * 入口，流程
 */
function main() {

    let svn_git = () => {
        versionControl.start(() => {
            buildUnity.useLibraryCache();
            get_manifest();
            // common.exit(1);
        });
    };

    let get_manifest = () => {
        manifest.start(() => {
            build_lua();
            build_unity();
        });
    };


    let build_lua = () => {
        encodeLua.start(() => {
            b1 = true;
            buildComplete();
        });
    };

    let build_unity = () => {
        buildUnity.start(() => {
            b2 = true;
            buildComplete();
        });
    };

    let [b1, b2] = [false, false];
    let buildComplete = () => {
        if (b1 && b2) copy_res();
    };


    let copy_res = () => {
        copyRes.start(build_platform);
    };

    let build_platform = () => {
        platform.start(dest_and_zip);
    };


    let dest_and_zip = () => {
        b1 = b2 = false;
        destAndZip.dest(() => {
            b1 = true;
            dazComplete();
        });

        destAndZip.zip(() => {
            b2 = true;
            dazComplete();
        });
    };

    let dazComplete = () => {
        if (b1 && b2) all_complete();
    };


    let all_complete = () => {
        console.log('all complete!');
        common.exit(0);
    };

    svn_git();
}

main();