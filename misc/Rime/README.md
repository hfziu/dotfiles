# Rime Custom Configurations

I'm using [rime-ice](https://github.com/iDvel/rime-ice) with custom configurations that reflect my personal preferences. These configurations are tested with Squirrel 1.1.2 (as of Feb 2026) on macOS.

To reset Rime to factory defaults, clear the `~/Library/Rime` directory and re-deploy. Then use [plum](https://github.com/rime/plum) to install additional schemas and packages, followed by applying the custom configurations from this directory.

```bash
# cd <some working directory you like>
git clone https://github.com/rime/plum.git
cd plum

# I use rime-ice and cantonese (jyutping)
bash rime-install iDvel/rime-ice:others/recipes/full
bash rime-install cantonese
```

Then

```bash
# cd <this repo>/misc/Rime
./restore.sh
```

Finally re-deploy Rime to apply the changes.

## Updates

These configurations were last tested in February 2026. You can update all files (including configurations and dictionaries) from `rime-ice` using:

```bash
bash rime-install iDvel/rime-ice:others/recipes/full
```

This command will **not** override the custom configurations installed from this directory. That said, it is possible that some of the custom configurations may become incompatible when `rime-ice` or Rime/Squirrel itself has major changes in the future.
