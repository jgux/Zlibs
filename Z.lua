local Z = {}
local config = {
    -- 需要加载的插件列表,会按添加顺序从前往后加载
    PluginList = {
        {
            -- 是否启用该插件
            enable = false,
            -- 插件名
            name = "竹云平台对接",
            -- 插件入口文件,相对plugins文件夹
            entry = 'ZY',
            -- 在Z.lua中添加唯一索引,防止重复加载/加载冲突
            addIndex = 'ZY',
            -- 插件设置,会在初始化时自动传入
            config = {}
        }, {
            enable = true,
            name = "HSV颜色支持",
            entry = 'HSVColor',
            addIndex = 'HSVColor',
            config = {}
        }, {
            enable = false,
            name = "全分辨率找色函数",
            entry = 'ExtraFindColor',
            addIndex = 'ExtraFindColor',
            config = {
                init = 1, -- 脚本init的方向(0竖屏,1横屏)
                width = 1920, -- 开发分辨率的宽
                height = 1080, -- 开发分辨率的高
                safeSpace = 10 -- 自动转换预留的间隙(开发分辨率下)
            }
        }
    }

}

Z.info = [[
Author: 竹子菌
QQ: 454689880
Updated: 2019年7月28日18:33:11
Project: https://github.com/bamboo98/Zlibs
开发手册: https://www.yuque.com/zhuzijun/zlibs
请关注github获取最新版更新,Zlibs仍在开发中
可能会出现各种不可预知的错误,如果发现BUG请反馈给竹子菌
]]
Z.config = config
local init = false
function Z.getJson()
    -- 尝试直接加载2.0的json库
    local ok, json = pcall(require, 'cjson')
    if ok then return json end
    -- 加载1.9的lua版JSON库
    local lo_json = {}
    local obj = require('Zlibs.tool.JSON')
    lo_json.decode = function(x) return obj:decode(x) end
    lo_json.encode = function(x) return obj:encode(x) end
    lo_json.encode_pretty = function(x) return obj:encode_pretty(x) end
    return lo_json
end

function Z.init()
    if init then return end
    init = true
    local log = rawget(_G, "sysLog")
    print = log and function(...)
        local t = {...}
        for k, v in ipairs(t) do
            if type(v) ~= "string" then t[k] = tostring(v) end
        end
        log(table.concat(t, "\t"))
    end or print
    printf = printf or function(...) print(string.format(...)) end
    require"Zlibs.class.Point"._init()
    require"Zlibs.class.Rect"._init()
    require"Zlibs.class.Sequence"._init()
    require"Zlibs.class.Finger"._init()
    printf('Zlibs加载成功\r%s', Z.info)
    if #(config.PluginList) > 0 then
        print('开始加载插件')
        pcall(require, 'Zlibs.plugins.init')
    else
        print('配置文件中没有插件')
    end
end
function Z.MD5(s)
    local md5func = rawget(_G, 'md5') or rawget(_G, 'md5_fast') or
                        require'crypto'.md5
    return md5func(s)
end

local type = require 'Zlibs.tool.type'
function var_dump(val)
    local function dump(val, deep)
        local s = ''
        deep = deep or 0
        if type(val) == 'table' then
            s = s .. '{\r'
            deep = deep + 1
            for k, v in pairs(val) do
                s = s .. string.rep('\t', deep) .. '[' .. dump(k, deep) ..
                        '] = ' .. dump(v, deep) .. ',\r'
            end
            s = s .. string.rep('\t', deep - 1) .. '}'
        elseif type(val) ~= 'string' then
            s = tostring(val)
        else
            s = '"' .. val .. '"'
        end
        return s
    end
    local s = dump(val)
    print(s)
    return s
end

return Z
