-- LuCI by libc0607 (libc0607@gmail.com)
-- 华工路由群 262939451
-- 抄的
string.split = function(s, p)
	local rt = {}
	string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end)
	return rt
end

scut = Map(
		"scutclient",
		"华南理工大学客户端 设置"
)
function scut.on_commit(self)

	luci.sys.call("uci commit")
	luci.sys.call("rm -rf /tmp/luci-*cache")
	luci.sys.call("sh /usr/share/scut_helper/set_unicom.sh")
end

-- config option
scut_option = scut:section(TypedSection, "option", translate("选项"))
scut_option.anonymous = true

scut_option:option(Flag, "enable", "启用")



scut_helper_unicom = scut:section(TypedSection, "option", translate("联通加速"))
scut_helper.anonymous = true
scut_helper_unicom:option(Flag, "enable_unicom", "启用联通加速")
scut_helper_unicom:option(Value, "unicom_username", "联通的用户名")
scut_helper_unicom:option(Value, "unicom_password", "联通的密码")
scut_helper_unicom:option(Value, "unicom_server", "联通服务器ip")






-- config scutclient
scut_client = scut:section(TypedSection, "scutclient", "用户信息")
scut_client.anonymous = true
scut_client:option(Value, "username", "拨号用户名", "学校提供的用户名，一般是学号")
scut_client:option(Value, "password", "拨号密码").password = true

-- config drcom
scut_drcom = scut:section(TypedSection, "drcom", "Drcom设置")
scut_drcom.anonymous = true

scut_drcom_version = scut_drcom:option(Value, "version", "Drcom版本")
scut_drcom_version.rmempty = false
scut_drcom_version:value("4472434f4d0096022a")
scut_drcom_version:value("4472434f4d0096022a00636b2031")
scut_drcom_version:value("4472434f4d00cf072a00332e31332e302d32342d67656e65726963")
scut_drcom_version.default = "4472434f4d0096022a"
scut_drcom_hash = scut_drcom:option(Value, "hash", translate("DrAuthSvr.dll版本"))
scut_drcom_hash.rmempty = false
scut_drcom_hash:value("2ec15ad258aee9604b18f2f8114da38db16efd00")
scut_drcom_hash:value("d985f3d51656a15837e00fab41d3013ecfb6313f")
scut_drcom_hash:value("915e3d0281c3a0bdec36d7f9c15e7a16b59c12b8")
scut_drcom_hash.default = "2ec15ad258aee9604b18f2f8114da38db16efd00"
scut_drcom_server = scut_drcom:option(Value, "server_auth_ip", translate("服务器IP"))
scut_drcom_server.rmempty = false
scut_drcom_server.datatype = "ip4addr"
scut_drcom_server:value("202.38.210.131")
scut_drcom_nettime = scut_drcom:option(Value, "nettime", translate("允许上网时间"))
scut_drcom_nettime.description = "允许的上网时间，断网后等待到指定时间重新开始认证。如6:15"
scut_drcom_nettime.validate = function(self, value, t)
	if (string.find(value, ":")) then
		local sp = string.split(value, ":")

		if (#sp == 2) then
			local hour, minute = tonumber(sp[1]), tonumber(sp[2])
			if (hour and minute and hour >= 0 and hour < 12 and minute >= 0 and minute < 60) then
				return value
			end
		end
	end

	return nil, "上网时间格式错误！"
end

-- config ipv6相关
scut_helper = scut:section(TypedSection, "option", "校园网ipv6")
scut_helper.anonymous = true
o = scut_helper:option(Button, "b1", translate("设置ipv6中继"))
o.inputstyle = "reload"
o.write = function()
	luci.sys.call("sh /usr/share/scut_helper/set_ipv6_relay.sh")
end
o = scut_helper:option(Button, "b2", translate("还原ipv6设置"))
o.inputstyle = "reload"
o.write = function()
	luci.sys.call("sh /usr/share/scut_helper/reset_ipv6.sh")
end

--[[ 主机名列表预置
    1.生成一个 DESKTOP-XXXXXXX 的随机
    2.dhcp分配的第一个
]]--
scut_drcom_hostname = scut_drcom:option(Value, "hostname", translate("向服务器发送的主机名"))
scut_drcom_hostname.rmempty = false

local random_hostname = "DESKTOP-"
local randtmp

math.randomseed(os.time())
for i = 1, 7 do
	randtmp = math.random(1, 36)
	random_hostname = (randtmp > 10)
			and random_hostname..string.char(randtmp+54)
			or  random_hostname..string.char(randtmp+47)
end

-- 获取dhcp列表，加入第一个主机名候选
local dhcp_hostnames = string.split(luci.sys.exec("cat /tmp/dhcp.leases|awk {'print $4'}"), "\n") or {}

scut_drcom_hostname:value(random_hostname)
scut_drcom_hostname:value(dhcp_hostnames[1])
scut_drcom_hostname.default = random_hostname

return scut
