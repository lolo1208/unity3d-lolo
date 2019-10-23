/**
 * 测试项目 SVN 配置
 * Created by LOLO on 2019/10/9.
 */


module.exports = {

    // 默认 svn 账号
    username: 'lolo',
    // 默认 svn 密码
    password: 'lolo',

    list: [

        // 主工程项目（列表第一条必须为主工程）
        {
            url: 'http://dr-js-luozc:8080/svn/zzsf/test/main',
            dest: '',
            username: undefined, // 也可以单独指定 svn 账号密码
            password: undefined,
        },

        // lua 代码项目
        {
            url: 'http://dr-js-luozc:8080/svn/zzsf/test/lua',
            dest: 'Assets/Lua/',
        },

        // 资源项目
        {
            url: 'http://dr-js-luozc:8080/svn/zzsf/test/res',
            dest: 'Assets/Res',
        },

    ],
};
