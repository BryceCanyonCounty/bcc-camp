# bcc-camp

> Create your own camp in RedM!

## Features
- Creates a command in your RedM Server to Set a tent with a bedroll!
- Creates a menu which you can use to decorate your camp with multiple different props!
- Creates a storage system for your camp to store your items in!
- Optional fast travel system in camps!
- Easy translations via a language locale files!
- Everything is easy to configure to your liking via the config.lua file!
- Versioner to keep upto date on updates!
- Discord Notifications
- Configuration option to select the notification type from ox or vorp
- Configuration option to enable disable discord logs and grafana logs.

## How it works
- To set your tent up initally just type in chat the command you set in the config.lua file.
- After that you can walk up to your tent and press G on your keyboard to open the camp menu!
- To open storage walk up to your chest and press G!

## Dependencies
- [vorp_core](https://github.com/VORPCORE/vorp-core-lua)
- [vorp_inventory](https://github.com/VORPCORE/vorp_inventory-lua)
- [vorp_character](https://github.com/VORPCORE/vorp_character-lua)
- [bcc-utils](https://github.com/BryceCanyonCounty/bcc-utils)
- [feather-menu](https://github.com/FeatherFramework/feather-menu/releases)

## Optional Dependency if You use ox notificaiton or grafana logs
 - [ox_lib](https://github.com/overextended/ox_lib)

## Installation
- Make sure dependencies are installed/updated and ensured before this script
- Add `bcc-camp` folder to your resources folder
- Add `ensure bcc-camp` to your `resources.cfg`
- Restart server

## Credits
- This script is inspired by this script https://github.com/bcortezf/bc_camping
