# Rclone Magisk Module

This Magisk module integrates Rclone with FUSE support into Android, allowing you to manage remote storage mounts seamlessly. It includes scripts for managing Rclone services and automating tasks during boot and runtime.

## Features

- **FUSE Integration**: Mount remote storage as local directories using Rclone with FUSE.
- **Automated Boot Mounts**: Automatically mount configured remotes during system boot.
- **Web GUI Management**: Start and manage the Rclone Web GUI.
- **Customizable Configuration**: Easily configure Rclone options via environment variables.

* 点击action 启动web server 网页配置
* 开机自动挂载所有配置
* 配置文件夹
    * /data/adb/modules/rclone/conf/rclone.conf 配置文件 (可使用rclone-config 配置)
    * /data/adb/modules/rclone/conf/env 自定义参数和Flag
    * /data/adb/modules/rclone/conf/htpasswd web账号密码

## Scripts

### `action` button

This script is used to manage the Rclone Web GUI.


### `rclone-web`

Starts the Rclone Web GUI with predefined options.

#### Usage:
```bash
rclone-web --rc-addres=:8080
```

### `rclone-kill-all`

Unmounts all Rclone mount points and kills all Rclone-related processes.

#### Usage:
```bash
rclone-kill-all
```

### `rclone-config`

Opens the Rclone configuration interface.

#### Usage:
```bash
rclone-config
```

## Contributing

Contributions are welcome! Please ensure that your changes are well-documented and tested.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.