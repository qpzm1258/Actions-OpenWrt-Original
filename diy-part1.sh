#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# Uncomment a feed source
# sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default
sed -i "/helloworld/d" "feeds.conf.default"
# Add a feed source
echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default

# 更新并安装源
./scripts/feeds clean
./scripts/feeds update -a && ./scripts/feeds install -a

# 添加openclash
cd ..
git clone https://github.com/vernesong/OpenClash
mv ./OpenClash/luci-app-openclash ./openwrt/package/luci-app-openclash
rm -rf OpenClash
cd openwrt

# 替换更新默认argon主题
rm -rf feeds/luci/themes/luci-theme-argon && git clone https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config

# 替换更新passwall和ssrplus+
# rm -rf package/openwrt-packages/luci-app-passwall && svn co https://github.com/xiaorouji/openwrt-package/trunk/lienol/luci-app-passwall package/openwrt-packages/luci-app-passwall
# rm -rf package/openwrt-packages/luci-app-ssr-plus && svn co https://github.com/fw876/helloworld package/openwrt-packages/helloworld

# 添加passwall依赖库
# git clone https://github.com/kenzok8/small package/small
# svn co https://github.com/xiaorouji/openwrt-package/trunk/package package/small

# 替换更新haproxy默认版本
# rm -rf feeds/packages/net/haproxy && svn co https://github.com/lienol/openwrt-packages/trunk/net/haproxy feeds/packages/net/haproxy

# 自定义定制选项
sed -i 's#192.168.1.1#192.168.3.105#g' package/base-files/files/bin/config_generate #定制默认IP
sed -i 's@.*CYXluq4wUazHjmCDBCqXF*@#&@g' package/lean/default-settings/files/zzz-default-settings #取消系统默认密码
sed -i 's#0 6#0 2#g' package/lean/luci-app-adbyby-plus/root/etc/init.d/adbyby #修改adbyby自动更新时间到凌晨2点
sed -i 's#url-test#fallback#g' package/luci-app-openclash/root/usr/share/openclash/yml_proxys_set.sh #修改openclash自动生成配置中的urltest为fallback
# sed -i 's#option commit_interval 24h#option commit_interval 10m#g' feeds/packages/net/nlbwmon/files/nlbwmon.config #修改流量统计写入为10分钟
# sed -i 's#option database_directory /var/lib/nlbwmon#option database_directory /etc/config/nlbwmon_data#g' feeds/packages/net/nlbwmon/files/nlbwmon.config #修改流量统计数据存放默认位置
# sed -i 's@background-color: #e5effd@background-color: #f8fbfe@g' package/luci-theme-edge/htdocs/luci-static/edge/cascade.css #luci-theme-edge主题颜色微调
# sed -i 's#rgba(223, 56, 18, 0.04)#rgba(223, 56, 18, 0.02)#g' package/luci-theme-edge/htdocs/luci-static/edge/cascade.css #luci-theme-edge主题颜色微调

#创建自定义配置文件 - OpenWrt-x86-64

rm -f ./.config*
touch ./.config

#
# ========================固件定制部分========================
# 

# 
# 如果不对本区块做出任何编辑, 则生成默认配置固件. 
# 

# 以下为定制化固件选项和说明:
#

#
# 有些插件/选项是默认开启的, 如果想要关闭, 请参照以下示例进行编写:
# 
#          =========================================
#         |  # 取消编译VMware镜像:                   |
#         |  cat >> .config <<EOF                   |
#         |  # CONFIG_VMDK_IMAGES is not set        |
#         |  EOF                                    |
#          =========================================
#

# 
# 以下是一些提前准备好的一些插件选项.
# 直接取消注释相应代码块即可应用. 不要取消注释代码块上的汉字说明.
# 如果不需要代码块里的某一项配置, 只需要删除相应行.
#
# 如果需要其他插件, 请按照示例自行添加.
# 注意, 只需添加依赖链顶端的包. 如果你需要插件 A, 同时 A 依赖 B, 即只需要添加 A.
# 
# 无论你想要对固件进行怎样的定制, 都需要且只需要修改 EOF 回环内的内容.
# 

# 编译x64固件:
cat >> .config <<EOF
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_x86_64_Generic=y
EOF

# 设置固件大小:
cat >> .config <<EOF
CONFIG_TARGET_KERNEL_PARTSIZE=16
CONFIG_TARGET_ROOTFS_PARTSIZE=160
EOF

# 固件压缩:
cat >> .config <<EOF
CONFIG_TARGET_IMAGES_GZIP=y
EOF

# 编译UEFI固件:
cat >> .config <<EOF
CONFIG_EFI_IMAGES=y
EOF

# IPv6支持:
cat >> .config <<EOF
CONFIG_PACKAGE_dnsmasq_full_dhcpv6=y
CONFIG_PACKAGE_ipv6helper=y
EOF

# 编译VMware镜像以及镜像填充	
cat >> .config <<EOF	
# CONFIG_VMDK_IMAGES is not set
# CONFIG_TARGET_IMAGES_PAD is not set
EOF

# 编译打印机支持
cat >> .config <<EOF	
CONFIG_PACKAGE_p910nd=y
CONFIG_PACKAGE_kmod-lp=y
CONFIG_PACKAGE_kmod-usb-printer=y
CONFIG_PACKAGE_luci-app-p910nd=y
CONFIG_PACKAGE_luci-i18n-p910nd-zh-cn=y
EOF

# 多文件系统支持:
# cat >> .config <<EOF
# CONFIG_PACKAGE_kmod-fs-nfs=y
# CONFIG_PACKAGE_kmod-fs-nfs-common=y
# CONFIG_PACKAGE_kmod-fs-nfs-v3=y
# CONFIG_PACKAGE_kmod-fs-nfs-v4=y
# CONFIG_PACKAGE_kmod-fs-ntfs=y
# CONFIG_PACKAGE_kmod-fs-squashfs=y
# EOF

# USB3.0支持:
cat >> .config <<EOF
CONFIG_PACKAGE_kmod-usb-ohci=y
CONFIG_PACKAGE_kmod-usb-ohci-pci=y
CONFIG_PACKAGE_kmod-usb2=y
CONFIG_PACKAGE_kmod-usb2-pci=y
CONFIG_PACKAGE_kmod-usb3=y
EOF

# 第三方插件选择:
cat >> .config <<EOF
# CONFIG_PACKAGE_luci-app-oaf=y #应用过滤
CONFIG_PACKAGE_luci-app-openclash=y #OpenClash
#CONFIG_PACKAGE_luci-app-jd-dailybonus=y #京东签到
CONFIG_PACKAGE_luci-app-serverchan=y #微信推送
# CONFIG_PACKAGE_luci-app-eqos is not set #IP限速
# CONFIG_PACKAGE_luci-app-smartdns is not set #smartdns服务器
# CONFIG_PACKAGE_luci-app-adguardhome is not set #ADguardhome
EOF

# ShadowsocksR插件:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-ssr-plus=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Trojan=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Xray=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_ShadowsocksR_Server=y
EOF

# Passwall插件:
# cat >> .config <<EOF
# CONFIG_PACKAGE_luci-app-passwall=y
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ipt2socks=y
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks=y
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR=y
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ChinaDNS_NG=y
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_V2ray=y
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_v2ray-plugin=y
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_simple-obfs=y
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan_Plus=y
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan_GO=y
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Brook=y
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_kcptun=y
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_haproxy=y
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_dns2socks=y
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_pdnsd=y
# CONFIG_PACKAGE_https-dns-proxy=y
# CONFIG_PACKAGE_kcptun-client=y
# CONFIG_PACKAGE_chinadns-ng=y
# CONFIG_PACKAGE_haproxy=y
# CONFIG_PACKAGE_v2ray=y
# CONFIG_PACKAGE_v2ray-plugin=y
# CONFIG_PACKAGE_simple-obfs=y
# CONFIG_PACKAGE_trojan-plus=y
# CONFIG_PACKAGE_trojan-go=y
# CONFIG_PACKAGE_brook=y
# CONFIG_PACKAGE_ssocks=y
# CONFIG_PACKAGE_naiveproxy=y
# CONFIG_PACKAGE_ipt2socks=y
# CONFIG_PACKAGE_shadowsocks-libev-config=y
# CONFIG_PACKAGE_shadowsocks-libev-ss-local=y
# CONFIG_PACKAGE_shadowsocks-libev-ss-redir=y
# CONFIG_PACKAGE_shadowsocksr-libev-alt=y
# CONFIG_PACKAGE_shadowsocksr-libev-ssr-local=y
# CONFIG_PACKAGE_pdnsd-alt=y
# CONFIG_PACKAGE_dns2socks=y
# EOF

# 多拨
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-syncdial=y
CONFIG_PACKAGE_luci-app-macvlan=y
CONFIG_PACKAGE_luci-app-mwan3=y
EOF

# 常用LuCI插件:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-adbyby-plus=y #adbyby去广告
# CONFIG_PACKAGE_luci-app-webadmin is not set #Web管理页面设置
CONFIG_DEFAULT_luci-app-vlmcsd=y #KMS激活服务器
CONFIG_PACKAGE_luci-app-filetransfer=y #系统-文件传输
CONFIG_PACKAGE_luci-app-autoreboot=y #定时重启
CONFIG_PACKAGE_luci-app-upnp=y #通用即插即用UPnP(端口自动转发)
# CONFIG_PACKAGE_luci-app-accesscontrol is not set #上网时间控制
# CONFIG_PACKAGE_luci-app-wol is not set #网络唤醒
CONFIG_PACKAGE_luci-app-frpc=y #Frp内网穿透
CONFIG_PACKAGE_luci-app-frps=y
CONFIG_PACKAGE_luci-app-udpxy=y
CONFIG_PACKAGE_luci-app-nlbwmon=y #宽带流量监控
CONFIG_PACKAGE_luci-app-wrtbwmon=y #实时流量监测
CONFIG_PACKAGE_luci-app-ttyd=y
CONFIG_PACKAGE_luci-i18n-ttyd-zh-cn=y
CONFIG_PACKAGE_kmod-usb-printer=y
# CONFIG_PACKAGE_luci-app-zerotier is not set #zerotier内网穿透
# CONFIG_PACKAGE_luci-app-sfe is not set #高通开源的 Shortcut FE 转发加速引擎
# CONFIG_PACKAGE_luci-app-flowoffload is not set #开源 Linux Flow Offload 驱动
# CONFIG_PACKAGE_luci-app-haproxy-tcp is not set #Haproxy负载均衡
# CONFIG_PACKAGE_luci-app-diskman is not set #磁盘管理磁盘信息
# CONFIG_PACKAGE_luci-app-transmission is not set #TR离线下载
# CONFIG_PACKAGE_luci-app-qbittorrent is not set #QB离线下载
# CONFIG_PACKAGE_luci-app-amule is not set #电驴离线下载
# CONFIG_PACKAGE_luci-app-xlnetacc is not set #迅雷快鸟
# CONFIG_PACKAGE_luci-app-hd-idle is not set #磁盘休眠
#CONFIG_PACKAGE_luci-app-unblockmusic=y #解锁网易云灰色歌曲
#CONFIG_UnblockNeteaseMusic_Go=y
#CONFIG_UnblockNeteaseMusic_NodeJS=y
#CONFIG_PACKAGE_luci-i18n-unblockmusic-zh-cn=y
# CONFIG_PACKAGE_luci-app-airplay2 is not set #Apple AirPlay2音频接收服务器
# CONFIG_PACKAGE_luci-app-music-remote-center is not set #PCHiFi数字转盘遥控
# CONFIG_PACKAGE_luci-app-usb-printer is not set #USB打印机
# CONFIG_PACKAGE_luci-app-sqm is not set #SQM智能队列管理
# 
# DDNS插件
#
CONFIG_PACKAGE_luci-app-ddns=y #DDNS服务
CONFIG_PACKAGE_ddns-scripts=y
CONFIG_PACKAGE_ddns-scripts_aliyun=y
CONFIG_PACKAGE_ddns-scripts_cloudflare.com-v4=y
CONFIG_PACKAGE_ddns-scripts_dnspod=y
#
# VPN相关插件(禁用):
#
# CONFIG_PACKAGE_luci-app-v2ray-server is not set #V2ray服务器
# CONFIG_PACKAGE_luci-app-pptp-server is not set #PPTP VPN 服务器
# CONFIG_PACKAGE_luci-app-ipsec-vpnd is not set #ipsec VPN服务
# CONFIG_PACKAGE_luci-app-openvpn-server is not set #openvpn服务
CONFIG_PACKAGE_luci-app-softethervpn=y #SoftEtherVPN服务器
#
# 文件共享相关(禁用):
#
# CONFIG_PACKAGE_luci-app-minidlna is not set #miniDLNA服务
# CONFIG_PACKAGE_luci-app-vsftpd is not set #FTP 服务器
# CONFIG_PACKAGE_luci-app-samba is not set #网络共享
# CONFIG_PACKAGE_autosamba is not set #网络共享
# CONFIG_PACKAGE_samba36-server is not set #网络共享
EOF

# LuCI主题:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-app-argon-config=y
CONFIG_PACKAGE_luci-theme-material=y
# CONFIG_PACKAGE_luci-theme-netgear is not set
# CONFIG_PACKAGE_luci-theme-edge is not set
EOF

# 常用软件包:
cat >> .config <<EOF
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_htop=y
CONFIG_PACKAGE_nano=y
# CONFIG_PACKAGE_screen=y
# CONFIG_PACKAGE_tree=y
# CONFIG_PACKAGE_vim-fuller=y
CONFIG_PACKAGE_wget=y
CONFIG_PACKAGE_bash=y
CONFIG_PACKAGE_kmod-tun=y
CONFIG_PACKAGE_libcap=y
CONFIG_PACKAGE_libcap-bin=y
# CONFIG_PACKAGE_ip6tables-mod-nat=y
CONFIG_PACKAGE_qemu-ga=y
CONFIG_PACKAGE_iptables-mod-extra=y
CONFIG_PACKAGE_ttyd=y
EOF

# 其他软件包:
cat >> .config <<EOF
CONFIG_HAS_FPU=y
EOF


# 
# ========================固件定制部分结束========================
# 


sed -i 's/^[ \t]*//g' ./.config

# 配置文件创建完成
