# 076 coreutils
小さくて、Zigで作ったcoreutilsです。

## インストールする方法
**注意：インストールすると、元のcoreutils（GNU、FreeBSD、OpenBSD等）を交換されますので、`/usr/bin`フォルダのバックアップを創作するのは絶対に忘れないで下さい！！**

### 従属ソフト

* Zig 0.11.0-dev.3277+a0652fb93以上
* 良いOS (GNU/Linux、OpenBSD、又はFreeBSD)

## デバッグ

```sh
zig build -Doptimize=Debug
```

## リリース（小さい）

```sh
zig build -Doptimize=ReleaseSmall
```

## リリース（安全）

```sh
zig build -Doptimize=ReleaseSafe
```

## リリース（速い）

```sh
zig build -Doptimize=ReleaseFast
```
