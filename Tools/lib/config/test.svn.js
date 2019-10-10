/**
 * 测试项目 SVN 配置
 * Created by LOLO on 2019/10/9.
 */


module.exports = {

    // 默认 SVN 账号
    username: 'lolo',
    // 默认 SVN 密码
    password: 'lolo',

    list: [

        // 主项目
        {
            url: 'http://dr-js-luozc:8080/svn/zzsf/code/trunk/zzsf/',
            dest: '${PROJECT}',
            username: '', // 也可以单独指定 SVN 账号密码
            password: '',
        },

        // lua 代码
        {
            url: 'http://dr-js-luozc:8080/svn/zzsf/code/trunk/zzsf/',
            dest: '${PROJECT}/Assets/Lua',
        },

        // 资源
        {
            url: 'http://dr-js-luozc:8080/svn/zzsf/code/trunk/zzsf/',
            dest: '${PROJECT}/Assets/Res',
        },

    ],
};
