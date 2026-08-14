# mysql_extensions

MySQL compatibility layer for the openHalo × Babelfish fusion kernel (three-protocol parallel: PostgreSQL + MySQL + TDS on one postmaster). This repository mirrors the shape of babelfish_extensions: standalone PGXS extensions built against the fusion kernel's installed pg_config.

## 边界声明(内核 ↔ 扩展)

| 层 | 内容 | 落点 |
|---|---|---|
| 内核 | vtable 注册表(CompatibilityRoutine: parser/adtext/protocol/listen_init)、parsereng/adtext 分派器、**执行器 fork**(mys_execMain/mys_execProcnode/mys_executor/mys_execPartition/mys_nodeModifyTable)、**命令 fork**(commands/mysql)、共享会话状态(adapter/mysql/systemVar.c)、adt 钩子、方言头文件(src/include) | postgresql_modified_for_babelfish(内核) |
| 解析模块 | mysql_parser.so: mys_gram.y/mys_scan.l/mys_parser.c/mys_expr_transform.c/mys_gram_globals.c/mys_keywords.c/mys_namespace.c/mys_parse_utilcmd.c + bison/flex/kwlist 生成 | 本仓库 contrib/mysql_parser |
| 类型/SQL 函数模块 | mysm.so: mys_adtext.c + 20 个 SQL 函数/类型源文件 | 本仓库 contrib/mysm |
| 协议模块 | aux_mysql.so: 协议帧/认证/监听/DDL 分派 | 本仓库 contrib/aux_mysql |

**执行器/命令 fork 必须留在内核**:MySQL 语义(用户变量、REPLACE INTO/ON DUPLICATE KEY、除法精度、LAST_INSERT_ID/AUTO_INCREMENT、DDL 语义)织进执行器循环与命令实现内部,SPI 位于执行器之上无法表达;迁出等于把内核内部结构当扩展 ABI 导出。这不是"没拆干净",是架构边界。详见内核 docs/MYSQL_PLUGIN_BOUNDARY.md。

## 构建

```sh
./build-all.sh          # 需先构建并安装融合内核(babelfish_extensions/build-all.sh)
# 可选: KERNEL_DIR=... PREFIX=... 覆盖默认路径
```

前置工具: make, cc, pkg-config, flex, bison, perl。mysql_parser 的 gen_keywordlist.pl 从内核源码树读取(PG_SRC=KERNEL_DIR)。

## 测试

模块的 TAP 测试随 install-first 基线运行(见内核 run-baseline.sh):内核构建安装后,先 ./build-all.sh,再对 inst/ 跑 prove:

```sh
cd contrib/aux_mysql/t && prove -v 005_mysql_compat.pl 006_pg_dump_restore.pl 007_mysql_parallel.pl
```

## 历史

本仓库由 postgresql_modified_for_babelfish 的 contrib/mysql_parser、contrib/mysm、contrib/aux_mysql 三个目录经 git filter-repo 切分而来,携带完整历史(openHalo 导入 → 全部融合提交)。