# startuptime.vim

![startuptime](https://cloud.githubusercontent.com/assets/111942/23541408/35607a3e-ffb5-11e6-9bf8-1e59b8ae06ef.png)

Everybody knows that 1ms could mean the difference between life and death in
Vim.  This plugin breaks down the output of `--startuptime` so you can zero in
on the scripts that are stealing dozens of your milliseconds each time Vim is
started.  You won't even need to leave the comfort of Vim.


# Usage

Use the command `:StartupTime` to get an averaged startup profile.  By default,
it collects 10 samples.

It accepts multiple arguments.  If a number is found, it is used as the sample
count.  If a filename is found, it will be used with the `-u` argument while
profiling.

Example collecting 100 samples and using `~/foo.vim` as the vimrc script:

```vim
:StartupTime ~/foo.vim 100
```

If `--` is found in the command arguments, everything after it will be used
verbatim in the program execution.

Example collecting 100 samples with manual arguments:

```vim
:StartupTime 100 -- -u ~/foo.vim -i NONE -- ~/foo.vim
```

Note that the first `--` is dropped.

To upload the results, you can use a plugin like
[gist-vim](https://github.com/mattn/gist-vim).


# Details

You have been able to profile Vim's startup by using the `--startuptime`
argument since v7.2.  However, the results are written to a file and it reports
timing per loaded script.  The output method and results aren't very useful to
a layman that just wants to know what plugins are affecting Vim's startup
speed.

This plugin takes multiple samples (10 by default) of the `--startuptime`
output and displays the average times broken down by ***source***.  A source
could be your `[vimrc]` scripts, Vim's built-in `[runtime]` scripts, or
plugins.  Vim doesn't actually have a formal plugin system.  As a result, a
"plugin" is simply a path found in `runtimepath` that *looks like* a plugin.
If the source can't be determined, it display as `[unknown]`.

The results shows the total average startup time and the 10 slowest "plugins".
Below it are the load times, separated by startup phases and sorted by load
time.  Under each phase, load times are broken down by "plugin".  Under each
"plugin" are the load times for individual scripts.  These are folded by
default and can be opened with `zo` if you want more detail.
