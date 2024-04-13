module("luci.controller.scutclient", package.seeall)

http = require "luci.http"
fs = require "nixio.fs"
sys  = require "luci.sys"

log_file = "/tmp/scutclient.log"
log_file_backup = "/tmp/scutclient.log.backup.log"

function index()
	if not nixio.fs.access("/etc/config/scutclient") then
		return
	end
	local uci = require "luci.model.uci".cursor()
	local mainorder = uci:get_first("scutclient", "luci", "mainorder", 10)

	entry({"admin", "services", "scutclient"},
		alias("admin", "services", "scutclient", "settings"),
		"华南理工大学客户端",
		mainorder
	)

	entry({"admin", "services", "scutclient", "settings"},
		cbi("scutclient/scutclient"),
		"设置",
		10
	).leaf = true

	entry({"admin", "services", "scutclient", "status"},
		call("action_status"),
		"状态",
		20
	).leaf = true

	entry({"admin", "services", "scutclient", "logs"}, template("scutclient/logs"), "日志", 30).leaf = true
	entry({"admin", "services", "scutclient", "about"}, call("action_about"), "关于", 40).leaf = true
	entry({"admin", "services", "scutclient", "get_log"}, call("get_log"))
	entry({"admin", "services", "scutclient", "netstat"}, call("get_netstat"))
	entry({"admin", "services", "scutclient", "scutclient-log.tar"}, call("get_dbgtar"))
end


function get_log()
	local send_log_lines = 75
	if fs.access(log_file) then
		client_log = sys.exec("tail -n "..send_log_lines.." " .. log_file)
	else
		client_log = "Unable to access the log file!"
	end

	http.prepare_content("text/plain; charset=gbk")
	http.write(client_log)
	http.close()
end

function action_about()
	luci.template.render("scutclient/about")
end


function action_status()
	luci.template.render("scutclient/status")
	if luci.http.formvalue("logoff") == "1" then
		luci.sys.call("/etc/init.d/scutclient stop > /dev/null")
	end
	if luci.http.formvalue("redial") == "1" then
		luci.sys.call("/etc/init.d/scutclient stop > /dev/null")
		luci.sys.call("/etc/init.d/scutclient start > /dev/null")
	end
end

function get_netstat()
	local hcontent = sys.exec("wget -O- http://whatismyip.akamai.com 2>/dev/null | head -n1")
	local nstat = {}
	if hcontent == '' then
		nstat.stat = 'no_internet'
	elseif hcontent:find("(%d+)%.(%d+)%.(%d+)%.(%d+)") then
		nstat.stat = 'internet'
	else
		nstat.stat = 'no_login'
	end
	http.prepare_content("application/json")
	http.write_json(nstat)
	http.close()
end

function get_dbgtar()

	local tar_dir = "/tmp/scutclient-log"
	local tar_files = {
		"/etc/config/wireless",
		"/etc/config/network",
		"/etc/config/system",
		"/etc/config/scutclient",
		"/etc/openwrt_release",
		"/etc/crontabs/root",
		"/etc/config/dhcp",
		"/tmp/dhcp.leases",
		"/etc/rc.local",
	}

	fs.mkdirr(tar_dir)
	table.foreach(tar_files, function(i, v)
			luci.sys.call("cp " .. v .. " " .. tar_dir)
	end)

	if fs.access(log_file_backup) then
		luci.sys.call("cat " .. log_file_backup .. " >> " .. tar_dir .. "/scutclient.log")
	end
	if fs.access(log_file) then
		luci.sys.call("cat " .. log_file .. " >> " .. tar_dir .. "/scutclient.log")
	end
	http.prepare_content("application/octet-stream")
	http.write(sys.exec("tar -C " .. tar_dir .. " -cf - ."))
	luci.sys.call("rm -rf " .. tar_dir)
	http.close()
end
