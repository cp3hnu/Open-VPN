# VPN

# 这个工程的目的是为了快速地配置、打开、关闭VPN，使用iOS 8新引入的NetworkExtension库

## Screenshot

![](Demo.gif)

## Features

1. 界面简洁
2. 支持IPSec
3. 支持按需打开VPN
4. 支持Today Widget

## Build

为了编译工程，您需要修改bundle_id以及VPN和VPN Widget的Capabilities

+ Personal VPN
+ Keychain Sharing
+ App Groups

## 3rd Party Library

* [UICKeyChainStore](https://github.com/kishikawakatsumi/UICKeyChainStore)

## Version

##### V1.1

解决iOS 9的问题：

1. 第一次连接VPN时，提示安装VPN到设备，startVPNTunnel会调用失败，但是没有NEVPNStatusDidChangeNotification通知消息；
2. 第一次saveToPreferences安装VPN到设备之后回到App，需要再调用loadFromPreferences，加载VPN设置

## Requirements

iOS 8.0+

