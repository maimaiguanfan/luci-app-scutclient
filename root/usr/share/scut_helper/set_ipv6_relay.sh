uci set dhcp.wan6=dhcp
uci set dhcp.wan6.interface='wan6'
uci set dhcp.wan6.ignore='1'
uci set dhcp.wan6.master='1'
uci set dhcp.wan6.ra='relay'
uci set dhcp.wan6.ra_flags='none'
uci set dhcp.wan6.dhcpv6='relay'
uci set dhcp.wan6.ndp='relay'

uci set dhcp.lan.ra='relay'
uci set dhcp.lan.ra_flags='none'
uci set dhcp.lan.dhcpv6='relay'
uci set dhcp.lan.ndp='relay'


uci commit