uci delete dhcp.wan6
uci set dhcp.lan.ra='hybrid'
uci set dhcp.lan.dhcpv6='hybrid'
uci set dhcp.lan.ndp='hybrid'
uci delete dhcp.lan.ra_flags='none'
uci commit