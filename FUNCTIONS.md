
# BashMatic


## Table of Contents

* [Table of Contents](#table-of-contents)
* [List of Bashmatic Modules](#list-of-bashmatic-modules)
* [List of Bashmatic Functions](#list-of-bashmatic-functions)
  * [Module `7z`](#module-7z)
    * [`7z.a`](#7za)
    * [`7z.install`](#7zinstall)
    * [`7z.unzip`](#7zunzip)
    * [`7z.x`](#7zx)
    * [`7z.zip`](#7zzip)
  * [Module `array`](#module-array)
    * [`array.from.stdin`](#arrayfromstdin)
    * [`array.has-element`](#arrayhas-element)
    * [`array.includes`](#arrayincludes)
    * [`array.includes-or-complain`](#arrayincludes-or-complain)
    * [`array.includes-or-exit`](#arrayincludes-or-exit)
    * [`array.join`](#arrayjoin)
    * [`array.to.bullet-list`](#arraytobullet-list)
    * [`array.to.csv`](#arraytocsv)
    * [`array.to.piped-list`](#arraytopiped-list)
  * [Module `audio`](#module-audio)
    * [`audio.wav-to-mp3`](#audiowav-to-mp3)
    * [`audio.wave-file-frequency`](#audiowave-file-frequency)
  * [Module `aws`](#module-aws)
    * [`aws.ec2`](#awsec2)
    * [`aws.rds.hostname`](#awsrdshostname)
    * [`aws.s3.upload`](#awss3upload)
  * [Module `bashmatic`](#module-bashmatic)
    * [`bashmatic.bash.exit-unless-version-four-or-later`](#bashmaticbashexit-unless-version-four-or-later)
    * [`bashmatic.bash.version`](#bashmaticbashversion)
    * [`bashmatic.bash.version-four-or-later`](#bashmaticbashversion-four-or-later)
    * [`bashmatic.cache.add-file`](#bashmaticcacheadd-file)
    * [`bashmatic.cache.has-file`](#bashmaticcachehas-file)
    * [`bashmatic.cache.list`](#bashmaticcachelist)
    * [`bashmatic.functions`](#bashmaticfunctions)
    * [`bashmatic.functions-from`](#bashmaticfunctions-from)
    * [`bashmatic.functions.output`](#bashmaticfunctionsoutput)
    * [`bashmatic.functions.runtime`](#bashmaticfunctionsruntime)
    * [`bashmatic.load-at-login`](#bashmaticload-at-login)
    * [`bashmatic.reload`](#bashmaticreload)
    * [`bashmatic.setup`](#bashmaticsetup)
    * [`bashmatic.source`](#bashmaticsource)
    * [`bashmatic.source-dir`](#bashmaticsource-dir)
    * [`bashmatic.version`](#bashmaticversion)
  * [Module `brew`](#module-brew)
    * [`brew.cache-reset`](#brewcache-reset)
    * [`brew.cache-reset.delayed`](#brewcache-resetdelayed)
    * [`brew.cask.is-installed`](#brewcaskis-installed)
    * [`brew.cask.list`](#brewcasklist)
    * [`brew.cask.tap`](#brewcasktap)
    * [`brew.install`](#brewinstall)
    * [`brew.install.cask`](#brewinstallcask)
    * [`brew.install.package`](#brewinstallpackage)
    * [`brew.install.packages`](#brewinstallpackages)
    * [`brew.package.is-installed`](#brewpackageis-installed)
    * [`brew.package.list`](#brewpackagelist)
    * [`brew.reinstall.package`](#brewreinstallpackage)
    * [`brew.reinstall.packages`](#brewreinstallpackages)
    * [`brew.relink`](#brewrelink)
    * [`brew.setup`](#brewsetup)
    * [`brew.uninstall.package`](#brewuninstallpackage)
    * [`brew.uninstall.packages`](#brewuninstallpackages)
    * [`brew.upgrade`](#brewupgrade)
    * [`cache-or-command`](#cache-or-command)
  * [Module `caller`](#module-caller)
    * [`caller.stack`](#callerstack)
    * [`stack.frame`](#stackframe)
  * [Module `color`](#module-color)
    * [`ansi`](#ansi)
    * [`bold`](#bold)
    * [`color.disable`](#colordisable)
    * [`color.enable`](#colorenable)
    * [`error-text`](#error-text)
    * [`italic`](#italic)
    * [`red`](#red)
    * [`reset-color`](#reset-color)
    * [`strikethrough`](#strikethrough)
    * [`txt-err`](#txt-err)
    * [`txt-info`](#txt-info)
    * [`txt-warn`](#txt-warn)
    * [`underline`](#underline)
  * [Module `db`](#module-db)
    * [`db.datetime`](#dbdatetime)
    * [`db.dump`](#dbdump)
    * [`db.num-procs`](#dbnum-procs)
    * [`db.psql-args`](#dbpsql-args)
    * [`db.psql.args.`](#dbpsqlargs)
    * [`db.psql.args.default`](#dbpsqlargsdefault)
    * [`db.psql.args.maint`](#dbpsqlargsmaint)
    * [`db.rails.schema.checksum`](#dbrailsschemachecksum)
    * [`db.rails.schema.file`](#dbrailsschemafile)
    * [`db.restore`](#dbrestore)
    * [`db.top`](#dbtop)
    * [`db.wait-until-db-online`](#dbwait-until-db-online)
    * [`psql.db-settings`](#psqldb-settings)
  * [Module `deploy`](#module-deploy)
    * [`deploy.slack`](#deployslack)
    * [`deploy.slack-ding`](#deployslack-ding)
    * [`deploy.validate-vpn`](#deployvalidate-vpn)
  * [Module `dir`](#module-dir)
    * [`dir.count-slashes`](#dircount-slashes)
    * [`dir.expand-dir`](#direxpand-dir)
    * [`dir.is-a-dir`](#diris-a-dir)
  * [Module `docker`](#module-docker)
    * [`docker.abort-if-down`](#dockerabort-if-down)
    * [`docker.actions.build`](#dockeractionsbuild)
    * [`docker.actions.clean`](#dockeractionsclean)
    * [`docker.actions.pull`](#dockeractionspull)
    * [`docker.actions.push`](#dockeractionspush)
    * [`docker.actions.setup`](#dockeractionssetup)
    * [`docker.actions.start`](#dockeractionsstart)
    * [`docker.actions.stop`](#dockeractionsstop)
    * [`docker.actions.tag`](#dockeractionstag)
    * [`docker.actions.up`](#dockeractionsup)
    * [`docker.actions.update`](#dockeractionsupdate)
    * [`docker.build.container`](#dockerbuildcontainer)
    * [`docker.containers.clean`](#dockercontainersclean)
    * [`docker.image.inspect`](#dockerimageinspect)
    * [`docker.image.rm`](#dockerimagerm)
    * [`docker.images-named`](#dockerimages-named)
    * [`docker.images.clean`](#dockerimagesclean)
    * [`docker.images.inspect`](#dockerimagesinspect)
    * [`docker.last-version`](#dockerlast-version)
    * [`docker.next-version`](#dockernext-version)
    * [`docker.set-repo`](#dockerset-repo)
  * [Module `file`](#module-file)
    * [`file.exists-and-newer-than`](#fileexists-and-newer-than)
    * [`file.extension.replace`](#fileextreplace)
    * [`file.extension`](#fileextension)
    * [`file.gsub`](#filegsub)
    * [`file.install-with-backup`](#fileinstall-with-backup)
    * [`file.last-modified-date`](#filelast-modified-date)
    * [`file.last-modified-year`](#filelast-modified-year)
    * [`file.list.filter-existing`](#filelistfilter-existing)
    * [`file.list.filter-non-empty`](#filelistfilter-non-empty)
    * [`file.size`](#filesize)
    * [`file.size.mb`](#filesizemb)
    * [`file.source-if-exists`](#filesource-if-exists)
    * [`file.stat`](#filestat)
    * [`file.strip.extension`](#filestripextension)
    * [`files.find`](#filesfind)
    * [`files.map`](#filesmap)
    * [`files.map.shell-scripts`](#filesmapshell-scripts)
  * [Module `ftrace`](#module-ftrace)
    * [`ftrace-in`](#ftrace-in)
    * [`ftrace-off`](#ftrace-off)
    * [`ftrace-on`](#ftrace-on)
    * [`ftrace-out`](#ftrace-out)
  * [Module `gem`](#module-gem)
    * [`g-i`](#g-i)
    * [`g-u`](#g-u)
    * [`gem.cache-installed`](#gemcache-installed)
    * [`gem.cache-refresh`](#gemcache-refresh)
    * [`gem.clear-cache`](#gemclear-cache)
    * [`gem.configure-cache`](#gemconfigure-cache)
    * [`gem.ensure-gem-version`](#gemensure-gem-version)
    * [`gem.gemfile.version`](#gemgemfileversion)
    * [`gem.global.latest-version`](#gemgloballatest-version)
    * [`gem.global.versions`](#gemglobalversions)
    * [`gem.install`](#geminstall)
    * [`gem.is-installed`](#gemis-installed)
    * [`gem.uninstall`](#gemuninstall)
    * [`gem.version`](#gemversion)
  * [Module `git`](#module-git)
    * [`bashmatic.auto-update`](#bashmaticauto-update)
    * [`git.configure-auto-updates`](#gitconfigure-auto-updates)
    * [`git.last-update-at`](#gitlast-update-at)
    * [`git.local-vs-remote`](#gitlocal-vs-remote)
    * [`git.quiet`](#gitquiet)
    * [`git.remotes`](#gitremotes)
    * [`git.repo-is-clean`](#gitrepo-is-clean)
    * [`git.save-last-update-at`](#gitsave-last-update-at)
    * [`git.seconds-since-last-pull`](#gitseconds-since-last-pull)
    * [`git.sync`](#gitsync)
    * [`git.sync-remote`](#gitsync-remote)
    * [`git.update-repo-if-needed`](#gitupdate-repo-if-needed)
  * [Module `github`](#module-github)
    * [`github.clone`](#githubclone)
    * [`github.org`](#githuborg)
    * [`github.setup`](#githubsetup)
    * [`github.validate`](#githubvalidate)
  * [Module `jemalloc`](#module-jemalloc)
    * [`jm.check`](#jmcheck)
    * [`jm.jemalloc.detect-loud`](#jmjemallocdetect-loud)
    * [`jm.jemalloc.detect-quiet`](#jmjemallocdetect-quiet)
    * [`jm.jemalloc.stats`](#jmjemallocstats)
    * [`jm.ruby.detect`](#jmrubydetect)
    * [`jm.ruby.report`](#jmrubyreport)
    * [`jm.usage`](#jmusage)
  * [Module `json`](#module-json)
    * [`json.begin-array`](#jsonbegin-array)
    * [`json.begin-hash`](#jsonbegin-hash)
    * [`json.begin-key`](#jsonbegin-key)
    * [`json.end-array`](#jsonend-array)
    * [`json.end-hash`](#jsonend-hash)
    * [`json.file-to-array`](#jsonfile-to-array)
  * [Module `net`](#module-net)
    * [`net.fast-scan`](#netfast-scan)
    * [`net.local-subnet`](#netlocal-subnet)
  * [Module `osx`](#module-osx)
    * [`afp.servers`](#afpservers)
    * [`bashmatic-set-fqdn`](#bashmatic-set-fqdn)
    * [`bashmatic-term`](#bashmatic-term)
    * [`bashmatic-term-program`](#bashmatic-term-program)
    * [`change-underscan`](#change-underscan)
    * [`cookie-dump`](#cookie-dump)
    * [`http.servers`](#httpservers)
    * [`https.servers`](#httpsservers)
    * [`osx.cookie-dump`](#osxcookie-dump)
    * [`osx.env-print`](#osxenv-print)
    * [`osx.local-servers`](#osxlocal-servers)
    * [`osx.ramdisk.mount`](#osxramdiskmount)
    * [`osx.ramdisk.unmount`](#osxramdiskunmount)
    * [`osx.scutil-print`](#osxscutil-print)
    * [`osx.set-fqdn`](#osxset-fqdn)
    * [`ssh.servers`](#sshservers)
  * [Module `output`](#module-output)
    * [`abort`](#abort)
    * [`ascii-clean`](#ascii-clean)
    * [`ask`](#ask)
    * [`box.blue-in-green`](#boxblue-in-green)
    * [`box.blue-in-yellow`](#boxblue-in-yellow)
    * [`box.green-in-cyan`](#boxgreen-in-cyan)
    * [`box.green-in-green`](#boxgreen-in-green)
    * [`box.green-in-magenta`](#boxgreen-in-magenta)
    * [`box.green-in-yellow`](#boxgreen-in-yellow)
    * [`box.magenta-in-blue`](#boxmagenta-in-blue)
    * [`box.magenta-in-green`](#boxmagenta-in-green)
    * [`box.red-in-magenta`](#boxred-in-magenta)
    * [`box.red-in-red`](#boxred-in-red)
    * [`box.red-in-yellow`](#boxred-in-yellow)
    * [`box.yellow-in-blue`](#boxyellow-in-blue)
    * [`box.yellow-in-red`](#boxyellow-in-red)
    * [`box.yellow-in-yellow`](#boxyellow-in-yellow)
    * [`br`](#br)
    * [`center`](#center)
    * [`columnize`](#columnize)
    * [`command-spacer`](#command-spacer)
    * [`cursor.at.x`](#cursoratx)
    * [`cursor.at.y`](#cursoraty)
    * [`cursor.down`](#cursordown)
    * [`cursor.left`](#cursorleft)
    * [`cursor.rewind`](#cursorrewind)
    * [`cursor.right`](#cursorright)
    * [`cursor.up`](#cursorup)
    * [`debug`](#debug)
    * [`duration`](#duration)
    * [`err`](#err)
    * [`error`](#error)
    * [`error:`](#error-1)
    * [`h.black`](#hblack)
    * [`h.blue`](#hblue)
    * [`h.green`](#hgreen)
    * [`h.red`](#hred)
    * [`h.yellow`](#hyellow)
    * [`h1`](#h1)
    * [`h1.blue`](#h1blue)
    * [`h1.green`](#h1green)
    * [`h1.purple`](#h1purple)
    * [`h1.red`](#h1red)
    * [`h1.yellow`](#h1yellow)
    * [`h2`](#h2)
    * [`h2.green`](#h2green)
    * [`h3`](#h3)
    * [`hdr`](#hdr)
    * [`hl.blue`](#hlblue)
    * [`hl.desc`](#hldesc)
    * [`hl.green`](#hlgreen)
    * [`hl.orange`](#hlorange)
    * [`hl.subtle`](#hlsubtle)
    * [`hl.white-on-orange`](#hlwhite-on-orange)
    * [`hl.white-on-salmon`](#hlwhite-on-salmon)
    * [`hl.yellow`](#hlyellow)
    * [`hl.yellow-on-gray`](#hlyellow-on-gray)
    * [`hr`](#hr)
    * [`hr.colored`](#hrcolored)
    * [`inf`](#inf)
    * [`info`](#info)
    * [`info:`](#info-1)
    * [`left`](#left)
    * [`left-prefix`](#left-prefix)
    * [`not-ok`](#not-ok)
    * [`not-ok:`](#not-ok-1)
    * [`ok`](#ok)
    * [`ok:`](#ok-1)
    * [`okay`](#okay)
    * [`output.color.off`](#outputcoloroff)
    * [`output.color.on`](#outputcoloron)
    * [`output.is-pipe`](#outputis-pipe)
    * [`output.is-redirect`](#outputis-redirect)
    * [`output.is-ssh`](#outputis-ssh)
    * [`output.is-terminal`](#outputis-terminal)
    * [`output.is-tty`](#outputis-tty)
    * [`puts`](#puts)
    * [`reset-color`](#reset-color-1)
    * [`reset-color:`](#reset-color-2)
    * [`screen-width`](#screen-width)
    * [`screen.height`](#screenheight)
    * [`screen.width`](#screenwidth)
    * [`shutdown`](#shutdown)
    * [`stderr`](#stderr)
    * [`stdout`](#stdout)
    * [`success`](#success)
    * [`test-group`](#test-group)
    * [`ui.closer.kind-of-ok`](#uicloserkind-of-ok)
    * [`ui.closer.kind-of-ok:`](#uicloserkind-of-ok-1)
    * [`ui.closer.not-ok`](#uiclosernot-ok)
    * [`ui.closer.not-ok:`](#uiclosernot-ok-1)
    * [`ui.closer.ok`](#uicloserok)
    * [`ui.closer.ok:`](#uicloserok-1)
    * [`warn`](#warn)
    * [`warning`](#warning)
    * [`warning:`](#warning-1)
  * [Module `pids`](#module-pids)
    * [`pall`](#pall)
    * [`pid.alive`](#pidalive)
    * [`pid.sig`](#pidsig)
    * [`pid.stop`](#pidstop)
    * [`pids-with-args`](#pids-with-args)
    * [`pids.all`](#pidsall)
    * [`pids.for-each`](#pidsfor-each)
    * [`pids.matching`](#pidsmatching)
    * [`pids.matching.regexp`](#pidsmatchingregexp)
    * [`pids.normalize.search-string`](#pidsnormalizesearch-string)
    * [`pids.stop`](#pidsstop)
    * [`pstop`](#pstop)
    * [`sig.is-valid`](#sigis-valid)
    * [`sig.list`](#siglist)
  * [Module `progress-bar`](#module-progress-bar)
    * [`progress.bar.auto-run`](#progressbarauto-run)
    * [`progress.bar.config`](#progressbarconfig)
    * [`progress.bar.configure.color-green`](#progressbarconfigurecolor-green)
    * [`progress.bar.configure.color-red`](#progressbarconfigurecolor-red)
    * [`progress.bar.configure.color-yellow`](#progressbarconfigurecolor-yellow)
    * [`progress.bar.configure.symbol-arrow`](#progressbarconfiguresymbol-arrow)
    * [`progress.bar.configure.symbol-bar`](#progressbarconfiguresymbol-bar)
    * [`progress.bar.configure.symbol-block`](#progressbarconfiguresymbol-block)
    * [`progress.bar.configure.symbol-square`](#progressbarconfiguresymbol-square)
    * [`progress.bar.launch-and-wait`](#progressbarlaunch-and-wait)
  * [Module `repositories`](#module-repositories)
    * [`repo.rebase`](#reporebase)
    * [`repo.stash-and-rebase`](#repostash-and-rebase)
    * [`repo.update`](#repoupdate)
    * [`repos.catch-interrupt`](#reposcatch-interrupt)
    * [`repos.init-interrupt`](#reposinit-interrupt)
    * [`repos.recursive-update`](#reposrecursive-update)
    * [`repos.update`](#reposupdate)
    * [`repos.was-interrupted`](#reposwas-interrupted)
  * [Module `ruby`](#module-ruby)
    * [`bundle.gems-with-c-extensions`](#bundlegems-with-c-extensions)
    * [`interrupted`](#interrupted)
    * [`ruby.bundler-version`](#rubybundler-version)
    * [`ruby.compiled-with`](#rubycompiled-with)
    * [`ruby.default-gems`](#rubydefault-gems)
    * [`ruby.full-version`](#rubyfull-version)
    * [`ruby.gemfile-lock-version`](#rubygemfile-lock-version)
    * [`ruby.gems`](#rubygems)
    * [`ruby.gems.install`](#rubygemsinstall)
    * [`ruby.gems.uninstall`](#rubygemsuninstall)
    * [`ruby.init`](#rubyinit)
    * [`ruby.install`](#rubyinstall)
    * [`ruby.install-ruby`](#rubyinstall-ruby)
    * [`ruby.install-ruby-with-deps`](#rubyinstall-ruby-with-deps)
    * [`ruby.install-upgrade-bundler`](#rubyinstall-upgrade-bundler)
    * [`ruby.installed-gems`](#rubyinstalled-gems)
    * [`ruby.kigs-gems`](#rubykigs-gems)
    * [`ruby.linked-libs`](#rubylinked-libs)
    * [`ruby.numeric-version`](#rubynumeric-version)
    * [`ruby.rbenv`](#rubyrbenv)
    * [`ruby.rubygems-update`](#rubyrubygems-update)
    * [`ruby.stop`](#rubystop)
    * [`ruby.top-versions`](#rubytop-versions)
    * [`ruby.top-versions-as-yaml`](#rubytop-versions-as-yaml)
    * [`ruby.validate-version`](#rubyvalidate-version)
  * [Module `run`](#module-run)
    * [`run`](#run)
    * [`run.ui.ask`](#runuiask)
    * [`run.ui.ask-user-value`](#runuiask-user-value)
    * [`run.ui.get-user-value`](#runuiget-user-value)
    * [`run.ui.press-any-key`](#runuipress-any-key)
    * [`run.ui.retry-command`](#runuiretry-command)
  * [Module `runtime-config`](#module-runtime-config)
    * [`run.inspect`](#runinspect)
    * [`run.set-all`](#runset-all)
    * [`run.set-all.list`](#runset-alllist)
    * [`run.set-next`](#runset-next)
    * [`run.set-next.list`](#runset-nextlist)
  * [Module `runtime`](#module-runtime)
    * [`run`](#run-1)
    * [`run.config.detail-is-enabled`](#runconfigdetail-is-enabled)
    * [`run.config.verbose-is-enabled`](#runconfigverbose-is-enabled)
    * [`run.inspect`](#runinspect-1)
    * [`run.inspect-variable`](#runinspect-variable)
    * [`run.inspect-variables`](#runinspect-variables)
    * [`run.inspect-variables-that-are`](#runinspect-variables-that-are)
    * [`run.inspect.set-skip-false-or-blank`](#runinspectset-skip-false-or-blank)
    * [`run.on-error.ask-is-enabled`](#runon-errorask-is-enabled)
    * [`run.print-command`](#runprint-command)
    * [`run.print-variable`](#runprint-variable)
    * [`run.print-variables`](#runprint-variables)
    * [`run.ui.press-any-key`](#runuipress-any-key-1)
    * [`run.variables-ending-with`](#runvariables-ending-with)
    * [`run.variables-starting-with`](#runvariables-starting-with)
    * [`run.with.minimum-duration`](#runwithminimum-duration)
    * [`run.with.ruby-bundle`](#runwithruby-bundle)
    * [`run.with.ruby-bundle-and-output`](#runwithruby-bundle-and-output)
  * [Module `set`](#module-set)
    * [`set-e-restore`](#set-e-restore)
    * [`set-e-save`](#set-e-save)
    * [`set-e-status`](#set-e-status)
  * [Module `settings`](#module-settings)
  * [Module `shell-set`](#module-shell-set)
    * [`save-restore-x`](#save-restore-x)
    * [`save-set-x`](#save-set-x)
    * [`shell-set.init-stack`](#shell-setinit-stack)
    * [`shell-set.is-set`](#shell-setis-set)
    * [`shell-set.pop-stack`](#shell-setpop-stack)
    * [`shell-set.push-stack`](#shell-setpush-stack)
    * [`shell-set.show-stack`](#shell-setshow-stack)
  * [Module `ssh`](#module-ssh)
    * [`ssh.load-keys`](#sshload-keys)
  * [Module `subshell`](#module-subshell)
    * [`bashmatic.detect-subshell`](#bashmaticdetect-subshell)
    * [`bashmatic.subshell-init`](#bashmaticsubshell-init)
    * [`bashmatic.validate-sourced-in`](#bashmaticvalidate-sourced-in)
    * [`bashmatic.validate-subshell`](#bashmaticvalidate-subshell)
  * [Module `sym`](#module-sym)
    * [`decrypt.secrets`](#decryptsecrets)
    * [`dev.crypt.chef`](#devcryptchef)
    * [`dev.decrypt.file`](#devdecryptfile)
    * [`dev.decrypt.str`](#devdecryptstr)
    * [`dev.edit.file`](#deveditfile)
    * [`dev.encrypt.file`](#devencryptfile)
    * [`dev.encrypt.str`](#devencryptstr)
    * [`dev.sym`](#devsym)
    * [`sym.dev.configure`](#symdevconfigure)
    * [`sym.dev.files`](#symdevfiles)
    * [`sym.dev.have-key`](#symdevhave-key)
    * [`sym.dev.import`](#symdevimport)
    * [`sym.dev.install-shell-helpers`](#symdevinstall-shell-helpers)
    * [`sym.install.symit`](#syminstallsymit)
  * [Module `time`](#module-time)
    * [`epoch`](#epoch)
    * [`millis`](#millis)
    * [`time.date-from-epoch`](#timedate-from-epoch)
    * [`time.duration.humanize`](#timedurationhumanize)
    * [`time.duration.millis-to-secs`](#timedurationmillis-to-secs)
    * [`time.epoch-to-iso`](#timeepoch-to-iso)
    * [`time.epoch-to-local`](#timeepoch-to-local)
    * [`time.epoch.minutes-ago`](#timeepochminutes-ago)
    * [`today`](#today)
  * [Module `trap`](#module-trap)
    * [`trap-setup`](#trap-setup)
    * [`trap-was-fired`](#trap-was-fired)
    * [`trapped`](#trapped)
  * [Module `url`](#module-url)
    * [`url.downloader`](#urldownloader)
    * [`url.http-code`](#urlhttp-code)
    * [`url.is-valid`](#urlis-valid)
    * [`url.shorten`](#urlshorten)
    * [`url.valid-status`](#urlvalid-status)
  * [Module `user`](#module-user)
    * [`user`](#user)
    * [`user.finger.name`](#userfingername)
    * [`user.first`](#userfirst)
    * [`user.gitconfig.email`](#usergitconfigemail)
    * [`user.gitconfig.name`](#usergitconfigname)
    * [`user.host`](#userhost)
    * [`user.my.ip`](#usermyip)
    * [`user.my.reverse-ip`](#usermyreverse-ip)
    * [`user.username`](#userusername)
  * [Module `util`](#module-util)
    * [`is-func`](#is-func)
    * [`pause`](#pause)
    * [`pause.long`](#pauselong)
    * [`pause.medium`](#pausemedium)
    * [`pause.short`](#pauseshort)
    * [`sedx`](#sedx)
    * [`util.append-to-init-files`](#utilappend-to-init-files)
    * [`util.arch`](#utilarch)
    * [`util.call-if-function`](#utilcall-if-function)
    * [`util.checksum.files`](#utilchecksumfiles)
    * [`util.checksum.stdin`](#utilchecksumstdin)
    * [`util.functions-matching`](#utilfunctions-matching)
    * [`util.generate-password`](#utilgenerate-password)
    * [`util.i-to-ver`](#utili-to-ver)
    * [`util.install-direnv`](#utilinstall-direnv)
    * [`util.is-a-function`](#utilis-a-function)
    * [`util.is-numeric`](#utilis-numeric)
    * [`util.is-variable-defined`](#utilis-variable-defined)
    * [`util.lines-in-folder`](#utillines-in-folder)
    * [`util.random-number`](#utilrandom-number)
    * [`util.remove-from-init-files`](#utilremove-from-init-files)
    * [`util.shell-init-files`](#utilshell-init-files)
    * [`util.shell-name`](#utilshell-name)
    * [`util.ver-to-i`](#utilver-to-i)
    * [`util.whats-installed`](#utilwhats-installed)
    * [`watch.command`](#watchcommand)
    * [`watch.ls-al`](#watchls-al)
    * [`watch.set-refresh`](#watchset-refresh)
  * [Module `vim`](#module-vim)
    * [`gvim.off`](#gvimoff)
    * [`gvim.on`](#gvimon)
    * [`vim.gvim-off`](#vimgvim-off)
    * [`vim.gvim-on`](#vimgvim-on)
    * [`vim.setup`](#vimsetup)
  * [Module `yaml`](#module-yaml)
    * [`yaml-diff`](#yaml-diff)
    * [`yaml-dump`](#yaml-dump)
    * [`yaml.diff`](#yamldiff)
    * [`yaml.dump`](#yamldump)
    * [`yaml.expand-aliases`](#yamlexpand-aliases)
* [Copyright](#copyright)
## List of Bashmatic Modules

* [7z](#module-7z)
* [array](#module-array)
* [audio](#module-audio)
* [aws](#module-aws)
* [bashmatic](#module-bashmatic)
* [brew](#module-brew)
* [caller](#module-caller)
* [color](#module-color)
* [db](#module-db)
* [deploy](#module-deploy)
* [dir](#module-dir)
* [docker](#module-docker)
* [file](#module-file)
* [ftrace](#module-ftrace)
* [gem](#module-gem)
* [git](#module-git)
* [github](#module-github)
* [jemalloc](#module-jemalloc)
* [json](#module-json)
* [net](#module-net)
* [osx](#module-osx)
* [output](#module-output)
* [pids](#module-pids)
* [progress-bar](#module-progress-bar)
* [repositories](#module-repositories)
* [ruby](#module-ruby)
* [run](#module-run)
* [runtime-config](#module-runtime-config)
* [runtime](#module-runtime)
* [set](#module-set)
* [settings](#module-settings)
* [shell-set](#module-shell-set)
* [ssh](#module-ssh)
* [subshell](#module-subshell)
* [sym](#module-sym)
* [time](#module-time)
* [trap](#module-trap)
* [url](#module-url)
* [user](#module-user)
* [util](#module-util)
* [vim](#module-vim)
* [yaml](#module-yaml)

## List of Bashmatic Functions



### Module `7z`

#### `7z.a`

```bash
7z.a ()
{
    7z.zip "$@"
}

```

#### `7z.install`

```bash
7z.install ()
{
    [[ -n $(which 7z) ]] || run "brew install p7zip";
    [[ -n $(which 7z) ]] || {
        error "7z is not found after installation";
        return 1
    };
    return 0
}

```

#### `7z.unzip`

```bash
7z.unzip ()
{
    7z.install;
    local archive="$1";
    [[ -f ${archive} ]] || archive="${archive}.tar.7z";
    [[ -f ${archive} ]] || {
        error "Neither $1 nor ${archive} were found.";
        return 1
    };
    info "Unpacking archive ${txtylw}${archive}$(txt-info), total of $(file.size ${archive}) bytes.";
    run.set-next show-output-on;
    run "7za x -so ${archive} | tar xfv -"
}

```

#### `7z.x`

```bash
7z.x ()
{
    7z.unzip "$@"
}

```

#### `7z.zip`

```bash
7z.zip ()
{
    local archive="$1";
    7z.install;
    [[ -f ${archive} || -d ${archive} ]] && archive="$(basename ${archive} | sedx 's/\./-/g').tar.7z";
    [[ -f ${archive} ]] && {
        run.set-next on-decline-return;
        run.ui.ask "File ${archive} already exists. Press Y to remove it and continue." || return 1;
        run "rm -f ${archive}"
    };
    run "tar cf - $* | 7za a -si ${archive}"
}

```


---


### Module `array`

#### `array.from.stdin`

```bash
array.from.stdin ()
{
    local array_name=$1;
    shift;
    local script="while IFS='' read -r line; do ${array_name}+=(\"\$line\"); done < <($*)";
    eval "${script}"
}

```

#### `array.has-element`

```bash
array.has-element ()
{
    local search="$1";
    shift;
    local r="false";
    local e;
    [[ "$*" =~ ${search} ]] || {
        echo -n $r;
        return 1
    };
    for e in "${@}";
    do
        [[ "$e" == "${search}" ]] && r="true";
    done;
    echo -n $r;
    [[ $r == "false" ]] && return 1;
    return 0
}

```

#### `array.includes`

```bash
array.includes ()
{
    local search="$1";
    shift;
    [[ "$*" =~ ${search} ]] || return 1;
    for e in "${@}";
    do
        [[ "$e" == "${search}" ]] && {
            return 0
        };
    done;
    return 1
}

```

#### `array.includes-or-complain`

```bash
array.includes-or-complain ()
{
    array.includes "$@" || {
        element="$1";
        shift;
        local -a output=();
        while true; do
            [[ -z "$1" ]] && break;
            if [[ "$1" =~ " " ]]; then
                output=("${output[@]}" "$1");
            else
                output=("$1");
            fi;
            shift;
        done;
        if [[ ${#output[@]} -gt 10 ]]; then
            error "Value ${element} must be one of the supplied values.";
        else
            error "Value ${element} must be one of the supplied values:" "${output[@:0:10]}";
        fi;
        echo;
        return 0
    };
    return 1
}

```

#### `array.includes-or-exit`

```bash
array.includes-or-exit ()
{
    array.includes-or-complain "$@" || exit 1
}

```

#### `array.join`

```bash
array.join ()
{
    local sep="$1";
    shift;
    local lines="$1";
    if [[ ${lines} == true || ${lines} == false ]]; then
        shift;
    else
        lines=false;
    fi;
    local elem;
    local len="$#";
    local last_index=$(( len - 1 ));
    local index=0;
    for elem in "$@";
    do
        if ${lines}; then
            printf "${sep}%s\n" "${elem}";
        else
            printf "%s" "${elem}";
            [[ ${index} -lt ${last_index} ]] && printf '%s' "${sep}";
        fi;
        index=$(( index + 1 ));
    done
}

```

#### `array.to.bullet-list`

```bash
array.to.bullet-list ()
{
    array.join ' • ' true "$@"
}

```

#### `array.to.csv`

```bash
array.to.csv ()
{
    array.join ', ' false "$@"
}

```

#### `array.to.piped-list`

```bash
array.to.piped-list ()
{
    array.join ' | ' false "$@"
}

```


---


### Module `audio`

#### `audio.wav-to-mp3`

```bash
audio.wav-to-mp3 ()
{
    local file="$1";
    shift;
    [[ -z "${file}" ]] && {
        h2 "USAGE: wav2mp3 <file.wav>" "NOTE: wave file sampling rate will be auto-detected.";
        return
    };
    [[ -n "$(which lame)" ]] || brew.package.install lame;
    nfile=$(echo "${file}" | sed -E 's/\.wav$/\.mp3/ig');
    khz=$(audio.wave-file-frequency "${file}");
    info "${bldgrn}Source: ${bldylw}$(basename "${file}")";
    info "${bldpur}Output: ${bldylw}${nfile}$(txt-info) | (sampling rate: ${bldgrn}${khz:-'Unknown'}kHz)";
    [[ -n ${khz} ]] && khz=" -s ${khz} ";
    run.set-next show-output-on;
    hr;
    run "lame --disptime 1 -m s -r -q 0 -b 320 ${khz} --cbr $* ${file} ${nfile}";
    hr
}

```

#### `audio.wave-file-frequency`

```bash
audio.wave-file-frequency ()
{
    local file="$1";
    [[ -z $(which mdls) ]] && return 1;
    local frequency=$(mdls ${file} | grep kMDItemAudioSampleRate | sed 's/.*= //g');
    local kHz=$((${frequency} / 1000));
    printf ${kHz}
}

```


---


### Module `aws`

#### `aws.ec2`

```bash
aws.ec2 ()
{
    local cmd="$1";
    local command="$cmd";
    case $command in
        list | show | ls)
            __utf_table "$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].{name: Name, instance_id: InstanceId, ip_address: PrivateIpAddress, state: State.Name}' --output table 2>/dev/null)";
            return $?
        ;;
        *)
            error "Invalid Command: ${cmd}";
            return 1
        ;;
    esac
}

```

#### `aws.rds.hostname`

```bash
aws.rds.hostname ()
{
    local name=${1};
    [[ -z $(which jq) ]] && out=$(brew.install.package jq 2>/dev/null 1>/dev/null);
    [[ -z $(which aws) ]] && out=$(brew.install.package awscli 2>/dev/null 1>/dev/null);
    [[ -n ${name} ]] && aws rds describe-db-instances | jq '.[][].Endpoint.Address' | sedx 's/"//g' | egrep "^${name}\.";
    [[ -z ${name} ]] && aws rds describe-db-instances | jq '.[][].Endpoint.Address' | sedx 's/"//g'
}

```

#### `aws.s3.upload`

```bash
aws.s3.upload ()
{
    local pathname="$1";
    shift;
    local skip_file_modification="$1";
    [[ -n ${skip_file_modification} ]] && skip_file_modification=true;
    [[ -z ${skip_file_modification} ]] && skip_file_modification=false;
    if [[ -z "${LibAws__DefaultUploadBucket}" || -z "${LibAws__DefaultUploadFolder}" ]]; then
        error "Required AWS S3 configuration is not defined." "Please set variables: ${bldylw}LibAws__DefaultUploadFolder" "and ${bldylw}LibAws__DefaultUploadBucket" "before using this function.";
        return 1;
    fi;
    if [[ ! -f "${pathname}" ]]; then
        error "Local file was not found: ${bldylw}${pathname}";
        return 1;
    fi;
    local file=$(basename "${pathname}");
    local remote_file="${file}";
    local year=$(file.last-modified-year "${pathname}");
    local date=$(file.last-modified-date "${pathname}");
    [[ -z ${year} ]] && year=$(date +'%Y');
    [[ -z ${date} ]] && date=$(today);
    ${skip_file_modification} || {
        [[ "${remote_file}" =~ "${date}" ]] && remote_file=$(echo "${remote_file}" | sedx "s/[_\.-]?${date}[_\.-]//g");
        [[ "${remote_file}" =~ "${date}" ]] || remote_file="${date}.${remote_file}"
    };
    remote_file=$(echo "${remote_file}" | sed -E 's/ /-/g;s/--+/-/g' | tr '[A-Z]' '[a-z]');
    local remote="s3://${LibAws__DefaultUploadBucket}/${LibAws__DefaultUploadFolder}/${year}/${remote_file}";
    run "aws s3 cp \"${pathname}\" \"${remote}\"";
    if [[ ${LibRun__LastExitCode} -eq 0 ]]; then
        local remoteUrl="https://s3-${LibAws__DefaultRegion}.amazonaws.com/${LibAws__DefaultUploadBucket}/${LibAws__DefaultUploadFolder}/${year}/${remote_file}";
        [[ -n "${LibAws__ObjectUrlFile}" ]] && echo ${remoteUrl} > "${LibAws__ObjectUrlFile}";
        echo;
        info "NOTE: You should now be able to access your resource at the following URL:";
        hr;
        info "${bldylw}${remoteUrl}";
        hr;
    else
        error "AWS S3 upload failed with code ${LibRun__LastExitCode}";
    fi;
    return ${LibRun__LastExitCode}
}

```


---


### Module `bashmatic`

#### `bashmatic.bash.exit-unless-version-four-or-later`

```bash
bashmatic.bash.exit-unless-version-four-or-later ()
{
    bashmatic.bash.version-four-or-later || {
        error "Sorry, this functionality requires BASH version 4 or later.";
        exit 1 > /dev/null
    }
}

```

#### `bashmatic.bash.version`

```bash
bashmatic.bash.version ()
{
    echo "${BASH_VERSION}" | cut -d '.' -f 1
}

```

#### `bashmatic.bash.version-four-or-later`

```bash
bashmatic.bash.version-four-or-later ()
{
    [[ $(bashmatic.bash.version) -gt 3 ]]
}

```

#### `bashmatic.cache.add-file`

```bash
bashmatic.cache.add-file ()
{
    bashmatic.bash.version-four-or-later || return 1;
    [[ -n "${1}" ]] && BashMatic__LoadCache[${1}]=true
}

```

#### `bashmatic.cache.has-file`

```bash
bashmatic.cache.has-file ()
{
    local file="$1";
    bashmatic.bash.version-four-or-later || return 1;
    test -z "$file" && return 1;
    if [[ -n "$1" && -n "${BashMatic__LoadCache["${file}"]}" ]]; then
        return 0;
    else
        return 1;
    fi
}

```

#### `bashmatic.cache.list`

```bash
bashmatic.cache.list ()
{
    bashmatic.bash.version-four-or-later || return 1;
    for f in "${!BashMatic__LoadCache[@]}";
    do
        echo $f;
    done
}

```

#### `bashmatic.functions`

```bash
bashmatic.functions ()
{
    bashmatic.functions-from '*.sh' "$@"
}

```

#### `bashmatic.functions-from`

```bash
bashmatic.functions-from ()
{
    local pattern="${1}";
    [[ -n ${pattern} ]] && shift;
    [[ -z ${pattern} ]] && pattern="*.sh";
    cd "${BASHMATIC_HOME}" > /dev/null || return 1;
    export SCREEN_WIDTH=$(screen-width);
    if [[ ! ${pattern} =~ "*" && ! ${pattern} =~ ".sh" ]]; then
        pattern="${pattern}.sh";
    fi;
    egrep -e '^[_a-zA-Z0-9]+.*\(\)' lib/${pattern} | sed -e 's/^lib\/.*\.sh://g' | sed -e 's/^function //g' | sed -e 's/\(\) *{.*$//g' | tr -d '()' | sed -e '/^ *$/d' | grep -v '^_' | sort | uniq | columnize "$@";
    cd - > /dev/null || return 1
}

```

#### `bashmatic.functions.output`

```bash
bashmatic.functions.output ()
{
    bashmatic.functions-from 'output.sh' "$@"
}

```

#### `bashmatic.functions.runtime`

```bash
bashmatic.functions.runtime ()
{
    bashmatic.functions-from 'run*.sh' "$@"
}

```

#### `bashmatic.load-at-login`

```bash
bashmatic.load-at-login ()
{
    local init_file="${1}";
    local -a init_files=(~/.bashrc ~/.bash_profile ~/.profile);
    [[ -n "${init_file}" && -f "${init_file}" ]] && init_files=("${init_file}");
    for file in "${init_files[@]}";
    do
        if [[ -f "${file}" ]]; then
            grep -q bashmatic "${file}" && {
                success "BashMatic is already loaded from ${bldblu}${file}";
                return 0
            };
            grep -q bashmatic "${file}" || {
                h2 "Adding BashMatic auto-loader to ${bldgrn}${file}...";
                echo "source ${BASHMATIC_HOME}/init.sh" >> "${file}"
            };
            source "${file}";
            break;
        fi;
    done
}

```

#### `bashmatic.reload`

```bash
bashmatic.reload ()
{
    source "${BASHMATIC_INIT}"
}

```

#### `bashmatic.setup`

```bash
bashmatic.setup ()
{
    [[ -z ${BashMatic__Downloader} && -n $(command -v curl) ]] && export BashMatic__Downloader="curl -fsSL --connect-timeout 5 ";
    [[ -z ${BashMatic__Downloader} && -n $(command -v wget) ]] && export BashMatic__Downloader="wget -q -O --connect-timeout=5 - ";
    if [[ ! -d "${BASHMATIC_LIBDIR}" ]]; then
        printf "\e[1;31mUnable to establish BashMatic's library source folder.\e[0m\n";
        return 1;
    fi;
    bashmatic.source util.sh git.sh file.sh color.sh;
    bashmatic.source-dir "${BASHMATIC_LIBDIR}";
    bashmatic.auto-update
}

```

#### `bashmatic.source`

```bash
bashmatic.source ()
{
    local path="${BASHMATIC_LIBDIR}";
    for file in "${@}";
    do
        [[ "${file}" =~ "/" ]] || file="${path}/${file}";
        [[ -s "${file}" ]] || {
            echo "Can't source file ${file} — fils is invalid.";
            return 1
        };
        if ! bashmatic.cache.has-file "${file}"; then
            [[ -n ${DEBUG} ]] && printf "${txtcyn}[source] ${bldylw}${file}${clr}...\n" 1>&2;
            set +e;
            source "${file}";
            bashmatic.cache.add-file "${file}";
        else
            [[ -n ${DEBUG} ]] && printf "${txtgrn}[cached] ${bldblu}${file}${clr} \n" 1>&2;
        fi;
    done;
    return 0
}

```

#### `bashmatic.source-dir`

```bash
bashmatic.source-dir ()
{
    local folder="${1}";
    local loaded=false;
    local file;
    unset files;
    declare -a files;
    eval "$(files.map.shell-scripts "${folder}" files)";
    if [[ ${#files[@]} -eq 0 ]]; then
        .err "No files were returned from files.map in " "\n  ${bldylw}${folder}";
        return 1;
    fi;
    for file in "${files[@]}";
    do
        bashmatic.source "${file}" && loaded=true;
    done;
    unset files;
    ${loaded} || {
        .err "Unable to find BashMatic library folder with files:" "${BASHMATIC_LIBDIR}";
        return 1
    };
    if [[ ${LoadedShown} -eq 0 ]]; then
        hr;
        success "BashMatic was loaded! Happy Bashing :) ";
        hr;
        export LoadedShown=1;
    fi
}

```

#### `bashmatic.version`

```bash
bashmatic.version ()
{
    cat $(dirname "${BASHMATIC_INIT}")/.version
}

```


---


### Module `brew`

#### `brew.cache-reset`

```bash
brew.cache-reset ()
{
    rm -f ${LibBrew__PackageCacheList} ${LibBrew__CaskCacheList}
}

```

#### `brew.cache-reset.delayed`

```bash
brew.cache-reset.delayed ()
{
    ((${BASH_IN_SUBSHELL})) || brew.cache-reset;
    ((${BASH_IN_SUBSHELL})) && trap "rm -f ${LibBrew__PackageCacheList} ${LibBrew__CaskCacheList}" EXIT
}

```

#### `brew.cask.is-installed`

```bash
brew.cask.is-installed ()
{
    local cask="${1}";
    local -a installed_casks=($(brew.cask.list));
    array.has-element $(basename "${cask}") "${installed_casks[@]}"
}

```

#### `brew.cask.list`

```bash
brew.cask.list ()
{
    cache-or-command "${LibBrew__CaskCacheList}" 30 "brew cask ls -1"
}

```

#### `brew.cask.tap`

```bash
brew.cask.tap ()
{
    run "brew tap homebrew/cask-cask"
}

```

#### `brew.install`

```bash
brew.install ()
{
    declare -a brew_packages=$@;
    local brew=$(which brew 2>/dev/null);
    if [[ -z "${brew}" ]]; then
        info "Installing Homebrew, please wait...";
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";
    else
        info "Homebrew is already installed.";
        info "Detected Homebrew Version: ${bldylw}$(brew --version 2>/dev/null | head -1)";
    fi
}

```

#### `brew.install.cask`

```bash
brew.install.cask ()
{
    local cask=$1;
    local force=;
    local verbose=;
    [[ -n ${opts_force} ]] && force="--force";
    [[ -n ${opts_verbose} ]] && verbose="--verbose";
    inf "verifying brew cask ${bldylw}${cask}";
    if [[ -n $(ls -al /Applications/*.app | grep -i ${cask}) && -z ${opts_force} ]]; then
        ui.closer.ok:;
    else
        if [[ $(brew.cask.is-installed ${cask}) == "true" ]]; then
            ui.closer.ok:;
            return 0;
        else
            ui.closer.kind-of-ok:;
            run "brew cask install ${cask} ${force} ${verbose}";
        fi;
    fi;
    brew.cache-reset.delayed
}

```

#### `brew.install.package`

```bash
brew.install.package ()
{
    local package=$1;
    local force=;
    local verbose=;
    [[ -n ${opts_force} ]] && force="--force";
    [[ -n ${opts_verbose} ]] && verbose="--verbose";
    inf "checking if package ${bldylw}${package}$(txt-info) is already installed...";
    if [[ $(brew.package.is-installed ${package}) == "true" ]]; then
        ui.closer.ok:;
    else
        printf "${bldred}not found.${clr}\n";
        run "brew install ${package} ${force} ${verbose}";
        if [[ ${LibRun__LastExitCode} != 0 ]]; then
            info "NOTE: ${bldred}${package}$(txt-info) failed to install, attempting to reinstall...";
            brew.reinstall.package "${package}";
        fi;
        brew.cache-reset.delayed;
    fi
}

```

#### `brew.install.packages`

```bash
brew.install.packages ()
{
    local force=;
    [[ -n ${opts_force} ]] && force="--force";
    for package in $@;
    do
        brew.install.package ${package};
    done
}

```

#### `brew.package.is-installed`

```bash
brew.package.is-installed ()
{
    local package="${1}";
    local -a installed_packages=($(brew.package.list));
    array.has-element $(basename "${package}") "${installed_packages[@]}"
}

```

#### `brew.package.list`

```bash
brew.package.list ()
{
    cache-or-command "${LibBrew__PackageCacheList}" 30 "brew ls -1"
}

```

#### `brew.reinstall.package`

```bash
brew.reinstall.package ()
{
    local package="${1}";
    local force=;
    local verbose=;
    [[ -n ${opts_force} ]] && force="--force";
    [[ -n ${opts_verbose} ]] && verbose="--verbose";
    run "brew unlink ${package} ${force} ${verbose}; true";
    run "brew uninstall ${package}  ${force} ${verbose}; true";
    run "brew install ${package} ${force} ${verbose}";
    run "brew link ${package} --overwrite ${force} ${verbose}";
    brew.cache-reset.delayed
}

```

#### `brew.reinstall.packages`

```bash
brew.reinstall.packages ()
{
    local force=;
    [[ -n ${opts_force} ]] && force="--force";
    for package in $@;
    do
        brew.uninstall.package ${package};
        brew.install.package ${package};
    done
}

```

#### `brew.relink`

```bash
brew.relink ()
{
    local package=${1};
    local verbose=;
    [[ -n ${opts_verbose} ]] && verbose="--verbose";
    run "brew link ${verbose} ${package} --overwrite"
}

```

#### `brew.setup`

```bash
brew.setup ()
{
    brew.upgrade
}

```

#### `brew.uninstall.package`

```bash
brew.uninstall.package ()
{
    local package=$1;
    local force=;
    local verbose=;
    [[ -n ${opts_force} ]] && force="--force";
    [[ -n ${opts_verbose} ]] && verbose="--verbose";
    export LibRun__AbortOnError=${False};
    run "brew unlink ${package} ${force} ${verbose}";
    export LibRun__AbortOnError=${False};
    run "brew uninstall ${package} ${force} ${verbose}";
    brew.cache-reset.delayed
}

```

#### `brew.uninstall.packages`

```bash
brew.uninstall.packages ()
{
    local force=;
    [[ -n ${opts_force} ]] && force="--force";
    for package in $@;
    do
        brew.uninstall.package ${package};
    done
}

```

#### `brew.upgrade`

```bash
brew.upgrade ()
{
    brew.install;
    if [[ -z "$(which brew)" ]]; then
        warn "brew is not installed....";
        return 1;
    fi;
    run "brew update --force";
    run "brew upgrade";
    run "brew cleanup -s"
}

```

#### `cache-or-command`

```bash
cache-or-command ()
{
    local file="$1";
    shift;
    local stale_minutes="$1";
    shift;
    local command="$*";
    file.exists-and-newer-than "${file}" ${stale_minutes} && {
        cat "${file}";
        return 0
    };
    cp /dev/null ${file} > /dev/null;
    eval "${command}" | tee -a "${file}"
}

```


---


### Module `caller`

#### `caller.stack`

```bash
caller.stack ()
{
    local index=${1:-"-1"};
    while true; do
        index=$((index + 1));
        caller ${index} 2>&1 > /dev/null || break;
        local -a frame=($(caller ${index} | tr ' ' '\n'));
        printf "%3d [ %-40.40s ]: %s\n" ${index} "${frame[2]}:${frame[0]}" "${frame[1]}";
    done
}

```

#### `stack.frame`

```bash
stack.frame ()
{
    caller.stack 0
}

```


---


### Module `color`

#### `ansi`

```bash
ansi ()
{
    echo -e "\e[${1}m${*:2}\e[0m"
}

```

#### `bold`

```bash
bold ()
{
    ansi 1 "$@"
}

```

#### `color.disable`

```bash
color.disable ()
{
    export clr='\e[0m';
    unset txtblk;
    unset txtred;
    unset txtgrn;
    unset txtylw;
    unset txtblu;
    unset txtpur;
    unset txtcyn;
    unset txtwht;
    unset bldblk;
    unset bldred;
    unset bldgrn;
    unset bldylw;
    unset bldblu;
    unset bldpur;
    unset bldcyn;
    unset bldwht;
    unset unkblk;
    unset undred;
    unset undgrn;
    unset undylw;
    unset undblu;
    unset undpur;
    unset undcyn;
    unset undwht;
    unset bakblk;
    unset bakred;
    unset bakgrn;
    unset bakylw;
    unset bakblu;
    unset bakpur;
    unset bakcyn;
    unset bakwht;
    unset txtrst;
    unset italic;
    unset bold;
    unset strikethrough;
    unset underlined;
    unset white_on_orange;
    unset white_on_yellow;
    unset white_on_red;
    unset white_on_pink;
    unset white_on_salmon;
    unset yellow_on_gray;
    export AppColorsLoaded=1
}

```

#### `color.enable`

```bash
color.enable ()
{
    if [[ -z "${AppColorsLoaded}" ]]; then
        export txtblk='\e[0;30m';
        export txtred='\e[0;31m';
        export txtgrn='\e[0;32m';
        export txtylw='\e[0;33m';
        export txtblu='\e[0;34m';
        export txtpur='\e[0;35m';
        export txtcyn='\e[0;36m';
        export txtwht='\e[0;37m';
        export bldblk='\e[1;30m';
        export bldred='\e[1;31m';
        export bldgrn='\e[1;32m';
        export bldylw='\e[1;33m';
        export bldblu='\e[1;34m';
        export bldpur='\e[1;35m';
        export bldcyn='\e[1;36m';
        export bldwht='\e[1;37m';
        export unkblk='\e[4;30m';
        export undred='\e[4;31m';
        export undgrn='\e[4;32m';
        export undylw='\e[4;33m';
        export undblu='\e[4;34m';
        export undpur='\e[4;35m';
        export undcyn='\e[4;36m';
        export undwht='\e[4;37m';
        export bakblk='\e[40m';
        export bakred='\e[41m';
        export bakgrn='\e[42m';
        export bakylw='\e[43m';
        export bakblu='\e[44m';
        export bakpur='\e[45m';
        export bakcyn='\e[46m';
        export bakwht='\e[47m';
        export txtrst='\e[0m';
        export rst='\e[0m';
        export clr='\e[0m';
        export bold='\e[1m';
        export italic='\e[3m';
        export underlined='\e[4m';
        export strikethrough='\e[9m';
        export white_on_orange="\e[48;5;208m";
        export white_on_yellow="\e[48;5;214m";
        export white_on_red="\e[48;5;9m";
        export white_on_pink="\e[48;5;199m";
        export white_on_salmon="\e[48;5;196m";
        export yellow_on_gray="\e[38;5;220m\e[48;5;242m";
        export AppColorsLoaded=1;
    else
        [[ -n ${DEBUG} ]] && echo "colors already loaded...";
    fi
}

```

#### `error-text`

```bash
error-text ()
{
    printf "${txtred}"
}

```

#### `italic`

```bash
italic ()
{
    ansi 3 "$@"
}

```

#### `red`

```bash
red ()
{
    ansi 31 "$@"
}

```

#### `reset-color`

```bash
reset-color ()
{
    printf "${clr}\n"
}

```

#### `strikethrough`

```bash
strikethrough ()
{
    ansi 9 "$@"
}

```

#### `txt-err`

```bash
txt-err ()
{
    printf "${clr}${bldylw}${bakred}"
}

```

#### `txt-info`

```bash
txt-info ()
{
    printf "${clr}${txtblu}"
}

```

#### `txt-warn`

```bash
txt-warn ()
{
    printf "${clr}${bldylw}"
}

```

#### `underline`

```bash
underline ()
{
    ansi 4 "$@"
}

```


---


### Module `db`

#### `db.datetime`

```bash
db.datetime ()
{
    date '+%Y%m%d-%H%M%S'
}

```

#### `db.dump`

```bash
db.dump ()
{
    local dbname=${1};
    shift;
    local psql_args="$*";
    [[ -z "${psql_args}" ]] && psql_args="-U postgres -h localhost";
    local filename=$(.db.backup-filename ${dbname});
    [[ $? != 0 ]] && return;
    [[ ${LibRun__Verbose} -eq ${True} ]] && {
        info "dumping from: ${bldylw}${dbname}";
        info "saving to...: ${bldylw}${filename}"
    };
    cmd="pg_dump -Fc -Z5 ${psql_args} -f ${filename} ${dbname}";
    run "${cmd}";
    code=${LibRun__LastExitCode};
    if [[ ${code} != 0 ]]; then
        ui.closer.not-ok:;
        error "pg_dump exited with code ${code}";
        return ${code};
    else
        ui.closer.ok:;
        return 0;
    fi
}

```

#### `db.num-procs`

```bash
db.num-procs ()
{
    ps -ef | grep [p]ostgres | wc -l | awk '{print $1}'
}

```

#### `db.psql-args`

```bash
db.psql-args ()
{
    db.psql.args. "$@"
}

```

#### `db.psql.args.`

```bash
db.psql.args. ()
{
    printf -- "-U ${AppPostgresUsername} -h ${AppPostgresHostname} $*"
}

```

#### `db.psql.args.default`

```bash
db.psql.args.default ()
{
    printf -- "-U postgres -h localhost $*"
}

```

#### `db.psql.args.maint`

```bash
db.psql.args.maint ()
{
    printf -- "-U postgres -h localhost --maintenance-db=postgres $*"
}

```

#### `db.rails.schema.checksum`

```bash
db.rails.schema.checksum ()
{
    if [[ -d db/migrate ]]; then
        find db/migrate -type f -ls | awk '{printf("%10d-%s\n",$7,$11)}' | sort | shasum | awk '{print $1}';
    else
        local schema=$(db.rails.schema.file);
        [[ -s ${schema} ]] || error "can not find Rails schema in either ${RAILS_SCHEMA_RB} or ${RAILS_SCHEMA_SQL}";
        [[ -s ${schema} ]] && util.checksum.files "${schema}";
    fi
}

```

#### `db.rails.schema.file`

```bash
db.rails.schema.file ()
{
    if [[ -f "${RAILS_SCHEMA_RB}" && -f "${RAILS_SCHEMA_SQL}" ]]; then
        if [[ "${RAILS_SCHEMA_RB}" -nt "${RAILS_SCHEMA_SQL}" ]]; then
            printf "${RAILS_SCHEMA_RB}";
        else
            printf "${RAILS_SCHEMA_SQL}";
        fi;
    else
        if [[ -f "${RAILS_SCHEMA_RB}" ]]; then
            printf "${RAILS_SCHEMA_RB}";
        else
            if [[ -f "${RAILS_SCHEMA_SQL}" ]]; then
                printf "${RAILS_SCHEMA_SQL}";
            fi;
        fi;
    fi
}

```

#### `db.restore`

```bash
db.restore ()
{
    local dbname="$1";
    shift;
    local filename="$1";
    [[ -n ${filename} ]] && shift;
    [[ -z ${filename} ]] && filename=$(.db.backup-filename ${dbname});
    [[ dbname =~ 'production' ]] && {
        error 'This script is not meant for production';
        return 1
    };
    [[ -s ${filename} ]] || {
        error "can't find valid backup file in ${bldylw}${filename}";
        return 2
    };
    psql_args=$(db.psql.args.default);
    maint_args=$(db.psql.args.maint);
    run "dropdb ${maint_args} ${dbname} 2>/dev/null; true";
    export LibRun__AbortOnError=${True};
    run "createdb ${maint_args} ${dbname} ${psql_args}";
    [[ ${LibRun__Verbose} -eq ${True} ]] && {
        info "restoring from..: ${bldylw}${filename}";
        info "restoring to....: ${bldylw}${dbname}"
    };
    run "pg_restore -Fc -j 8 ${psql_args} -d ${dbname} ${filename}";
    code=${LibRun__LastExitCode};
    if [[ ${code} != 0 ]]; then
        warning "pg_restore completed with exit code ${code}";
        return ${code};
    fi;
    return ${LibRun__LastExitCode}
}

```

#### `db.top`

```bash
db.top ()
{
    local dbnames=$@;
    h1 "Please wait while we resolve DB names using AWSCLI...";
    local db;
    local dbtype;
    local width_min=90;
    local height_min=50;
    local width=$(.output.screen-width);
    local height=$(.output.screen-height);
    if [[ ${width} -lt ${width_min} || ${height} -lt ${height_min} ]]; then
        error "Your screen is too small for db.top.";
        info "Minimum required screen dimensions are ${width_min} columns, ${height_min} rows.";
        info "Your screen is ${bldred}${width}x${height}.";
        return;
    fi;
    declare -A connections=();
    declare -a connection_names=();
    local i=0;
    for dbname in $dbnames;
    do
        declare -a results=($(.db.by_shortname $dbname));
        if [[ -n ${#results[@]} ]]; then
            dbtype="${results[0]}";
            i=$(($i + 1));
            db="${results[@]:1}";
            if [[ -n ${dbtype} ]]; then
                [[ ${dbtype} == "master" ]] && dbname="master";
                [[ ${dbtype} == "replica" ]] && dbname="replica-${dbname}";
                connections[${dbname}]="${db}";
                connection_names[$i]=${dbname};
            fi;
        fi;
    done;
    if [[ ${#connections[@]} == 0 ]]; then
        error "usage: $0 db1, db2, ... ";
        info "eg: db.top m r2 ";
        ((${BASH_IN_SUBSHELL})) && exit 1 || return 1;
    fi;
    trap "clear" TERM;
    trap "clear" EXIT;
    local clear=0;
    local interval=${DB_TOP_REFRESH_RATE:-0.5};
    local num_dbs=${#connection_names[@]};
    local tof="$(mktemp -d "${TMPDIR:-/tmp/}.XXXXXXXXXXXX")/.db.top.$$";
    cp /dev/null ${tof};
    while true; do
        local index=0;
        cursor.at.y 0;
        local screen_height=$(screen.height);
        for __dbtype in "${connection_names[@]}";
        do
            index=$((${index} + 1));
            local percent_total_height=0;
            if [[ ${num_dbs} -eq 2 ]]; then
                [[ ${index} -eq 2 ]] && percent_total_height=66;
            else
                if [[ ${num_dbs} -eq 3 ]]; then
                    [[ ${index} -eq 2 ]] && percent_total_height=50;
                    [[ ${index} -eq 3 ]] && percent_total_height=80;
                else
                    if [[ ${num_dbs} -eq 4 ]]; then
                        [[ ${index} -eq 2 ]] && percent_total_height=40;
                        [[ ${index} -eq 3 ]] && percent_total_height=60;
                        [[ ${index} -eq 4 ]] && percent_total_height=80;
                    fi;
                fi;
            fi;
            local vertical_shift=$((${percent_total_height} * ${screen_height} / 100));
            cursor.at.y ${vertical_shift} >> ${tof};
            [[ -n ${DEBUG} ]] && h.blue "screen_height = ${screen_height} | percent_total_height = ${percent_total_height} | vertical_shift = ${vertical_shift}" >> ${tof};
            hr.colored ${bldpur} >> ${tof};
            .db.top.page "${tof}" "${__dbtype}" "${connections[${__dbtype}]}";
        done;
        clear;
        h.yellow " «   DB-TOP V0.1.2 © 2016-2020 Konstantin Gredeskoul, All rights reserved. MIT License.";
        cat ${tof};
        cursor.at.y $(($(.output.screen-height) + 1));
        printf "${bldwht}Press Ctrl-C to quit.${clr}";
        cp /dev/null ${tof};
        sleep ${interval};
    done
}

```

#### `db.wait-until-db-online`

```bash
db.wait-until-db-online ()
{
    local db=${1};
    inf 'waiting for the database to come up...';
    while true; do
        out=$(psql -c "select count(*) from accounts" $(db.psql.args. ${db}) 2>&1);
        code=$?;
        [[ ${code} == 0 ]] && break;
        [[ ${code} == 1 ]] && break;
        sleep 1;
        [[ ${out} =~ 'does not exist' ]] && break;
    done;
    ui.closer.ok:;
    return 0
}

```

#### `psql.db-settings`

```bash
psql.db-settings ()
{
    psql $* -X -q -c 'show all' | sort | awk '{ printf("%s=%s\n", $1, $3) }' | sed -E 's/[()\-]//g;/name=setting/d;/^[-+=]*$/d;/^[0-9]*=$/d'
}

```


---


### Module `deploy`

#### `deploy.slack`

```bash
deploy.slack ()
{
    local original_text="$*";
    [[ -z ${LibDeploy__SlackHookUrl} ]] && return 1;
    local text=$(echo "${original_text}" | sed -E 's/"/\"/g' | sed -E "s/'/\'/g");
    local json="{\"text\": \"$text\"}";
    local slack_url="${LibDeploy__SlackHookUrl}";
    [[ ${LibRun__DryRun} -eq ${False} ]] && {
        if ${LibDeploy__NoSlack}; then
            hl.green "${original_text}";
        else
            curl -s -d "payload=$json" "${slack_url}" > /dev/null;
            if [[ $? -eq 0 ]]; then
                info: "sent to Slack: [${text}]";
            else
                warning: "error sending to Slack, is your SLACK_URL set?";
            fi;
        fi
    };
    [[ ${LibRun__DryRun} -eq ${True} ]] && run "send to slack [${text}]"
}

```

#### `deploy.slack-ding`

```bash
deploy.slack-ding ()
{
    deploy.slack "<!here> $@"
}

```

#### `deploy.validate-vpn`

```bash
deploy.validate-vpn ()
{
    .deploy.check-vpn "$@" || .deploy.vpn-error "$@"
}

```


---


### Module `dir`

#### `dir.count-slashes`

```bash
dir.count-slashes ()
{
    local dir="${1}";
    echo "${dir}" | sed 's/[^/]//g' | tr -d '\n' | wc -c | tr -d ' '
}

```

#### `dir.expand-dir`

```bash
dir.expand-dir ()
{
    local dir="${1}";
    if [[ "${dir:0:1}" != "/" && "${dir:0:1}" != "~" ]]; then
        dir="$(pwd)/${dir}";
    else
        if [[ "${dir:0:1}" == "~" ]]; then
            dir="${HOME}/${dir:1:1000}";
        fi;
    fi;
    printf "${dir}"
}

```

#### `dir.is-a-dir`

```bash
dir.is-a-dir ()
{
    local dir="${1}";
    [[ -d "${dir}" ]]
}

```


---


### Module `docker`

#### `docker.abort-if-down`

```bash
docker.abort-if-down ()
{
    local should_exit="${1:-true}";
    inf 'Checking if Docker is running...';
    docker ps 2> /dev/null > /dev/null;
    code=$?;
    if [[ ${code} == 0 ]]; then
        ui.closer.ok:;
    else
        ui.closer.not-ok:;
        error "docker ps returned ${code}, is Docker running?";
        [[ "${should_exit}" == "true" ]] && exit 127;
        return 127;
    fi
}

```

#### `docker.actions.build`

```bash
docker.actions.build ()
{
    docker.build.container "$@"
}

```

#### `docker.actions.clean`

```bash
docker.actions.clean ()
{
    .docker.exec "docker-compose rm"
}

```

#### `docker.actions.pull`

```bash
docker.actions.pull ()
{
    local tag=${1:-'latest'};
    .docker.check-repo "${2}" || return 1;
    .docker.exec "docker pull ${AppDockerRepo}:${tag}"
}

```

#### `docker.actions.push`

```bash
docker.actions.push ()
{
    local tag=${1:-$(.docker.next-version)};
    .docker.check-repo "${2}" || return 1;
    docker.actions.tag latest;
    [[ -n ${tag} ]] && docker.actions.tag "${tag}";
    .docker.check-repo || return 1;
    .docker.exec docker push "${AppDockerRepo}:${tag}";
    [[ ${tag} != 'latest' ]] && .docker.exec docker push "${AppDockerRepo}:latest"
}

```

#### `docker.actions.setup`

```bash
docker.actions.setup ()
{
    setup.docker;
    docker.pull;
    docker.build
}

```

#### `docker.actions.start`

```bash
docker.actions.start ()
{
    .docker.exec "docker-compose start"
}

```

#### `docker.actions.stop`

```bash
docker.actions.stop ()
{
    .docker.exec "docker-compose stop"
}

```

#### `docker.actions.tag`

```bash
docker.actions.tag ()
{
    local tag=${1};
    [[ -z ${tag} ]] && return 1;
    .docker.check-repo "${2}" || return 1;
    .docker.exec docker tag "${AppDockerRepo}" "${AppDockerRepo}:${tag}"
}

```

#### `docker.actions.up`

```bash
docker.actions.up ()
{
    .docker.exec "docker-compose up"
}

```

#### `docker.actions.update`

```bash
docker.actions.update ()
{
    docker.build;
    docker.push
}

```

#### `docker.build.container`

```bash
docker.build.container ()
{
    .docker.check-repo "${1}" || return 1;
    local tag=${AppDockerRepo};
    .docker.exec "docker build -m 3G -c 4 --pull -t ${tag} . $*"
}

```

#### `docker.containers.clean`

```bash
docker.containers.clean ()
{
    local -a args=("$@");
    run "docker rm $(docker ps -q -a) ${args[*]}"
}

```

#### `docker.image.inspect`

```bash
docker.image.inspect ()
{
    run.set-next show-output-on;
    local jq=" | jq";
    [[ -z $(command -v jq) ]] && jq=;
    run "docker image inspect ${*} $jq"
}

```

#### `docker.image.rm`

```bash
docker.image.rm ()
{
    run "docker image rm ${*}"
}

```

#### `docker.images-named`

```bash
docker.images-named ()
{
    local name="${1}";
    local func="${2}";
    docker.abort-if-down false || return 127;
    hl.subtle "Processing Docker images matching ${name} with function ${func}...";
    local images="$(docker images | grep "^${name}" | sed 's/  */ /g' | cut -d ' ' -f 3 | tr '\n' ' ')";
    ${func} ${images}
}

```

#### `docker.images.clean`

```bash
docker.images.clean ()
{
    local name=${1:-"<none>"};
    docker.images-named "${name}" "docker.image.rm"
}

```

#### `docker.images.inspect`

```bash
docker.images.inspect ()
{
    local name=${1:-"<none>"};
    docker.images-named "${name}" "docker.image.inspect"
}

```

#### `docker.last-version`

```bash
docker.last-version ()
{
    .docker.check-repo "${1}" || return 1;
    [[ -z ${AppDockerRepo} ]] && {
        error "usage: docker.last-version organization/reponame:version";
        return 1
    };
    .docker.last-version "$@"
}

```

#### `docker.next-version`

```bash
docker.next-version ()
{
    .docker.check-repo "${1}" || return 1;
    [[ -z ${AppDockerRepo} ]] && {
        error "usage: docker.next-version [ organization/repo-name:version ]";
        return 1
    };
    .docker.next-version "$@"
}

```

#### `docker.set-repo`

```bash
docker.set-repo ()
{
    [[ -n "$1" ]] && export AppDockerRepo="$1"
}

```


---


### Module `file`

#### `file.exists-and-newer-than`

```bash
file.exists-and-newer-than ()
{
    local file="${1}";
    shift;
    local minutes="${1}";
    shift;
    if [[ -n "$(find ${file} -mmin -${minutes} -print 2>/dev/null)" ]]; then
        return 0;
    else
        return 1;
    fi
}

```

#### `file.extension.replace`

```bash
file.extension.replace ()
{
    local ext="$1";
    shift;
    [[ "${ext:0:1}" != "." ]] && ext=".${ext}";
    local first=true;
    for file in "$@";
    do
        ${first} || printf " ";
        printf "%s${ext}" "$(file.strip.extension "${file}")";
        first=false;
    done
}

```

#### `file.extension`

```bash
file.extension ()
{
    local filename="$1";
    printf "${filename##*.}"
}

```

#### `file.gsub`

```bash
file.gsub ()
{
    local file="$1";
    shift;
    local find="$1";
    shift;
    local replace="$1";
    shift;
    local runtime_options="$*";
    [[ ! -s "${file}" || -z "${find}" || -z "${replace}" ]] && {
        error "Invalid usage of file.sub — " "USAGE: file.gsub <file>    <find-regex>        <replace-regex>" "EG:    file.gsub ~/.bashrc '^export EDITOR=vi' 'export EDITOR=gvim'";
        return 1
    };
    egrep -q "${find}" "${file}" || return 0;
    [[ -z "${runtime_options}" ]] || run.set-next ${runtime_options};
    run "sed -i'' -E -e 's/${find}/${replace}/g' \"${file}\""
}

```

#### `file.install-with-backup`

```bash
file.install-with-backup ()
{
    local source=$1;
    local dest=$2;
    if [[ ! -f ${source} ]]; then
        error "file ${source} can not be found";
        return -1;
    fi;
    if [[ -f "${dest}" ]]; then
        if [[ -z $(diff ${dest} ${source} 2>/dev/null) ]]; then
            info: "${dest} is up to date";
            return 0;
        else
            ((${LibFile__ForceOverwrite})) || {
                info "file ${dest} already exists, skipping (use -f to overwrite)";
                return 0
            };
            inf "making a backup of ${dest} (${dest}.bak)";
            cp "${dest}" "${dest}.bak" > /dev/null;
            ui.closer.ok:;
        fi;
    fi;
    run "mkdir -p $(dirname ${dest}) && cp ${source} ${dest}"
}

```

#### `file.last-modified-date`

```bash
file.last-modified-date ()
{
    stat -f "%Sm" -t "%Y-%m-%d" "$1"
}

```

#### `file.last-modified-year`

```bash
file.last-modified-year ()
{
    stat -f "%Sm" -t "%Y" "$1"
}

```

#### `file.list.filter-existing`

```bash
file.list.filter-existing ()
{
    for file in $@;
    do
        [[ -f ${file} ]] && echo "${file}";
    done
}

```

#### `file.list.filter-non-empty`

```bash
file.list.filter-non-empty ()
{
    for file in $@;
    do
        [[ -s ${file} ]] && echo "${file}";
    done
}

```

#### `file.size`

```bash
file.size ()
{
    AppCurrentOS=${AppCurrentOS:-$(uname -s)};
    if [[ "Linux" == ${AppCurrentOS} ]]; then
        stat -c %s "$1";
    else
        file.stat "$1" st_size;
    fi
}

```

#### `file.size.mb`

```bash
file.size.mb ()
{
    local file="$1";
    shift;
    local s=$(file.size ${file});
    local mb=$(echo $(($s / 10000)) | sedx 's/([0-9][0-9])$/.\1/g');
    printf "%.2f MB" ${mb}
}

```

#### `file.source-if-exists`

```bash
file.source-if-exists ()
{
    local file;
    for file in "$@";
    do
        [[ -f "${file}" ]] && source "${file}";
    done
}

```

#### `file.stat`

```bash
file.stat ()
{
    local file="$1";
    local field="$2";
    [[ -f ${file} ]] || {
        error "file ${file} is not found. Usage: file.stat <filename> <stat-field-name>";
        info "eg: ${bldylw}file.stat README.md st_size";
        return 1
    };
    [[ -n ${field} ]] || {
        error "Second argument field is required.";
        info "eg: ${bldylw}file.stat README.md st_size";
        return 2
    };
    eval $(stat -s ${file} | tr ' ' '\n' | sed 's/^/local /g');
    echo ${!field}
}

```

#### `file.strip.extension`

```bash
file.strip.extension ()
{
    local filename="$1";
    printf "${filename%.*}"
}

```

#### `files.find`

```bash
files.find ()
{
    local folder="$1";
    local pattern="${2}";
    [[ -z ${folder} || -z ${pattern} ]] && {
        echo "usage: files.find <folder> <pattern>" 1>&2;
        return 1
    };
    find "$1" -name "${pattern}"
}

```

#### `files.map`

```bash
files.map ()
{
    local folder="${1}";
    local pattern="${2}";
    local array="${3}";
    local -a files;
    if bashmatic.bash.version-four-or-later; then
        mapfile -t files < <(files.find "${folder}" "${pattern}");
    else
        files=();
        while IFS='' read -r line; do
            files+=("$line");
        done < <(files.find "${folder}" "${pattern}");
    fi;
    if [[ -n ${array} ]]; then
        printf "%s" "unset ${array}; declare -a ${array}; ${array}=(${files[*]}); export ${array}";
    else
        printf "%s" "${files[*]}";
    fi
}

```

#### `files.map.shell-scripts`

```bash
files.map.shell-scripts ()
{
    files.map "$1" '*.sh' "$2"
}

```


---


### Module `ftrace`

#### `ftrace-in`

```bash
ftrace-in ()
{
    local func=$1;
    shift;
    local args="$*";
    [[ -z ${TraceON} ]] && return;
    export __LibTrace__StackLevel=$(( ${__LibTrace__StackLevel} + 1 ));
    printf "    %*s ${bldylw}%s${bldblu}(%s)${clr}\n" ${__LibTrace__StackLevel} ' ' ${func} "${args}" 1>&2
}

```

#### `ftrace-off`

```bash
ftrace-off ()
{
    unset TraceON
}

```

#### `ftrace-on`

```bash
ftrace-on ()
{
    export TraceON=true
}

```

#### `ftrace-out`

```bash
ftrace-out ()
{
    local func=$1;
    shift;
    local code=$1;
    shift;
    local msg="$*";
    [[ -z ${TraceON} ]] && return;
    local color="${bldgrn}";
    [[ ${code} -ne 0 ]] && color="${bldred}";
    printf "    %*s ${bldylw}%s() ${color} ➜  %d %s\n\n" ${__LibTrace__StackLevel} ' ' ${func} ${code} "${msg}" 1>&2;
    export __LibTrace__StackLevel=$(( ${__LibTrace__StackLevel} - 1 ))
}

```


---


### Module `gem`

#### `g-i`

```bash
g-i ()
{
    gem.install "$@"
}

```

#### `g-u`

```bash
g-u ()
{
    gem.uninstall "$@"
}

```

#### `gem.cache-installed`

```bash
gem.cache-installed ()
{
    gem.configure-cache;
    if [[ ! -s "${LibGem__GemListCache}" || -z $(find "${LibGem__GemListCache}" -mmin -30 2>/dev/null) ]]; then
        run "gem list > ${LibGem__GemListCache}";
    fi
}

```

#### `gem.cache-refresh`

```bash
gem.cache-refresh ()
{
    gem.configure-cache;
    gem.clear-cache;
    gem.cache-installed
}

```

#### `gem.clear-cache`

```bash
gem.clear-cache ()
{
    rm -f ${LibGem__GemListCache}
}

```

#### `gem.configure-cache`

```bash
gem.configure-cache ()
{
    export LibGem__GemListCacheBase=/tmp/.bashmatic/.gem/gem.list;
    export LibGem__GemListCache=;
    export LibGem__GemInstallFlags=" -N --force --quiet ";
    local ruby_version=$(ruby.numeric-version);
    export LibGem__GemListCache="${LibGem__GemListCacheBase}.${ruby_version}";
    local dir=$(dirname ${LibGem__GemListCache});
    [[ -d ${dir} ]] || run "mkdir -p ${dir}"
}

```

#### `gem.ensure-gem-version`

```bash
gem.ensure-gem-version ()
{
    local gem=$1;
    local gem_version=$2;
    [[ -z ${gem} || -z ${gem_version} ]] && return;
    gem.cache-installed;
    if [[ -z $(cat ${LibGem__GemListCache} | grep "${gem} (${gem_version})") ]]; then
        gem.uninstall ${gem};
        gem.install ${gem} ${gem_version};
    else
        info "gem ${gem} version ${gem_version} is already installed.";
    fi
}

```

#### `gem.gemfile.version`

```bash
gem.gemfile.version ()
{
    local gem=$1;
    [[ -z ${gem} ]] && return;
    if [[ -f Gemfile.lock ]]; then
        egrep "^    ${gem} \([0-9]+\.[0-9]+\.[0-9]\)" Gemfile.lock | awk '{print $2}' | sed 's/[()]//g';
    fi
}

```

#### `gem.global.latest-version`

```bash
gem.global.latest-version ()
{
    local gem=$1;
    [[ -z ${gem} ]] && return;
    declare -a versions=($(gem.global.versions ${gem}));
    local max=0;
    local max_version=;
    for v in ${versions[@]};
    do
        vi=$(util.ver-to-i ${v});
        if [[ ${vi} -gt ${max} ]]; then
            max=${vi};
            max_version=${v};
        fi;
    done;
    printf "%s" "${max_version}"
}

```

#### `gem.global.versions`

```bash
gem.global.versions ()
{
    local gem=$1;
    [[ -z ${gem} ]] && return;
    gem.cache-installed;
    cat ${LibGem__GemListCache} | egrep "^${gem} " | sedx "s/^${gem} //g;s/[(),]//g"
}

```

#### `gem.install`

```bash
gem.install ()
{
    .gem.verify-name "$@" || return 1;
    local gem_name=$1;
    local gem_version=$2;
    local gem_version_flags=;
    local gem_version_name=;
    gem_version=${gem_version:-$(gem.version ${gem_name})};
    if [[ -z ${gem_version} ]]; then
        gem_version_name=latest;
        gem_version_flags=;
    else
        gem_version_name="${gem_version}";
        gem_version_flags="--version ${gem_version}";
    fi;
    if [[ -z $(gem.is-installed ${gem_name} ${gem_version}) ]]; then
        info "installing ${bldylw}${gem_name} ${bldgrn}(${gem_version_name})${txtblu}...";
        run "gem install ${gem_name} ${gem_version_flags} ${LibGem__GemInstallFlags}";
        if [[ ${LibRun__LastExitCode} -eq 0 ]]; then
            rbenv rehash > /dev/null 2> /dev/null;
            gem.cache-refresh;
        else
            error "Unable to install gem ${bldylw}${gem_name}";
        fi;
        return ${LibRun__LastExitCode};
    else
        info: "gem ${bldylw}${gem_name} (${bldgrn}${gem_version_name}${bldylw})${txtblu} is already installed";
    fi
}

```

#### `gem.is-installed`

```bash
gem.is-installed ()
{
    local gem=$1;
    local version=$2;
    gem.cache-installed;
    if [[ -z ${version} ]]; then
        egrep "^${gem} \(" "${LibGem__GemListCache}";
    else
        egrep "^${gem} \(" "${LibGem__GemListCache}" | grep "${version}";
    fi
}

```

#### `gem.uninstall`

```bash
gem.uninstall ()
{
    .gem.verify-name "$@" || return 1;
    local gem_name=$1;
    local gem_version=$2;
    if [[ -z $(gem.is-installed ${gem_name} ${gem_version}) ]]; then
        info "gem ${bldylw}${gem_name}${txtblu} is not installed";
        return;
    fi;
    local gem_flags="-x -I --force";
    if [[ -z ${gem_version} ]]; then
        gem_flags="${gem_flags} -a";
    else
        gem_flags="${gem_flags} --version ${gem_version}";
    fi;
    run "gem uninstall ${gem_name} ${gem_flags}";
    gem.cache-refresh
}

```

#### `gem.version`

```bash
gem.version ()
{
    local gem=$1;
    local default=$2;
    [[ -z ${gem} ]] && return;
    local version;
    [[ -f Gemfile.lock ]] && version=$(gem.gemfile.version ${gem});
    [[ -z ${version} ]] && version=$(gem.global.latest-version ${gem});
    [[ -z ${version} && -n ${default} ]] && version=${default};
    printf "%s" "${version}"
}

```


---


### Module `git`

#### `bashmatic.auto-update`

```bash
bashmatic.auto-update ()
{
    [[ ${Bashmatic__Test} -eq 1 ]] && return 0;
    git.configure-auto-updates;
    git.repo-is-clean || {
        h1 "${BASHMATIC_HOME} has locally modified changes." "Will wait with auto-update until it's sync'd up.";
        return 1
    };
    git.sync
}

```

#### `git.configure-auto-updates`

```bash
git.configure-auto-updates ()
{
    export LibGit__StaleAfterThisManyHours="${LibGit__StaleAfterThisManyHours:-"1"}";
    export LibGit__LastUpdateTimestampFile="/tmp/.bashmatic/.config/$(echo ${USER} | util.checksum.stdin)";
    mkdir -p $(dirname ${LibGit__LastUpdateTimestampFile})
}

```

#### `git.last-update-at`

```bash
git.last-update-at ()
{
    git.configure-auto-updates;
    local file="${1:-"${LibGit__LastUpdateTimestampFile}"}";
    local last_update=0;
    [[ -f ${file} ]] && last_update="$(cat $file | tr -d '\n')";
    printf "%d" ${last_update}
}

```

#### `git.local-vs-remote`

```bash
git.local-vs-remote ()
{
    local upstream=${1:-'@{u}'};
    local local_repo=$(git rev-parse @);
    local remote_repo=$(git rev-parse "$upstream");
    local base=$(git merge-base @ "$upstream");
    if [[ -n ${DEBUG} ]]; then
        printf "
      pwd         = $(pwd)
      remote      = $(git.remotes)
      base        = ${base}
      upstream    = ${upstream}
      local_repo  = ${local_repo}
      remote_repo = ${remote_repo}
    ";
    fi;
    local result=;
    if [[ "${local_repo}" == "${remote_repo}" ]]; then
        result="ok";
    else
        if [[ "${local_repo}" == "${base}" ]]; then
            result="behind";
        else
            if [[ "${remote_repo}" == "${base}" ]]; then
                result="ahead";
            else
                result="diverged";
            fi;
        fi;
    fi;
    printf '%s' ${result};
    [[ ${result} == "ok" ]] && return 0;
    return 1
}

```

#### `git.quiet`

```bash
git.quiet ()
{
    [[ -n ${LibGit__QuietUpdate} ]]
}

```

#### `git.remotes`

```bash
git.remotes ()
{
    git remote -v | awk '{print $2}' | uniq
}

```

#### `git.repo-is-clean`

```bash
git.repo-is-clean ()
{
    local repo="${1:-${BASHMATIC_HOME}}";
    cd "${repo}" > /dev/null;
    if [[ -z $(git status -s) ]]; then
        cd - > /dev/null;
        return 0;
    else
        cd - > /dev/null;
        return 1;
    fi
}

```

#### `git.save-last-update-at`

```bash
git.save-last-update-at ()
{
    echo $(epoch) > ${LibGit__LastUpdateTimestampFile}
}

```

#### `git.seconds-since-last-pull`

```bash
git.seconds-since-last-pull ()
{
    local last_update="$1";
    local now=$(epoch);
    printf $((now - last_update))
}

```

#### `git.sync`

```bash
git.sync ()
{
    local dir="$(pwd)";
    cd "${BASHMATIC_HOME}" > /dev/null;
    git.repo-is-clean || {
        warning "${bldylw}${BASHMATIC_HOME} has locally modified files." "Please commit or stash them to allow auto-upgrade to function as designed." 1>&2;
        cd "${dir}" > /dev/null;
        return 1
    };
    git.update-repo-if-needed;
    cd "${dir}" > /dev/null;
    return 0
}

```

#### `git.sync-remote`

```bash
git.sync-remote ()
{
    if git.quiet; then
        ( git remote update && git fetch ) 2>&1 > /dev/null;
    else
        run "git remote update && git fetch";
    fi;
    local status=$(git.local-vs-remote);
    if [[ ${status} == "behind" ]]; then
        git.quiet || run "git pull --rebase";
        git.quiet && git pull --rebase 2>&1 > /dev/null;
    else
        if [[ ${status} != "ahead" ]]; then
            git.save-last-update-at;
        else
            if [[ ${status} != "ok" ]]; then
                error "Report $(pwd) is ${status} compared to the remote." "Please fix manually to continue.";
                return 1;
            fi;
        fi;
    fi;
    git.save-last-update-at;
    return 0
}

```

#### `git.update-repo-if-needed`

```bash
git.update-repo-if-needed ()
{
    local last_update_at=$(git.last-update-at);
    local second_since_update=$(git.seconds-since-last-pull ${last_update_at});
    local update_period_seconds=$((LibGit__StaleAfterThisManyHours * 60 * 60));
    if [[ ${second_since_update} -gt ${update_period_seconds} ]]; then
        git.sync-remote;
    else
        if [[ -n ${DEBUG} ]]; then
            git.quiet || info "${BASHMATIC_HOME} will update in $((update_period_seconds - second_since_update)) seconds...";
        fi;
    fi
}

```


---


### Module `github`

#### `github.clone`

```bash
github.clone ()
{
    test -n "$1" && github.validate && run "git clone git@github.com:$(github.org)/$1"
}

```

#### `github.org`

```bash
github.org ()
{
    local namespace="$1";
    if [[ -z ${namespace} ]]; then
        git config --global --get user.github;
    else
        git config --global --unset user.github;
        git config --global --add user.github "${namespace}";
    fi
}

```

#### `github.setup`

```bash
github.setup ()
{
    local namespace="$(github.org)";
    if [[ -z "${namespace}" ]]; then
        unset GITHUB_ORG;
        run.ui.ask-user-value GITHUB_ORG "Please enter the name of your Github Organization:" || return 1;
        github.org "${GITHUB_ORG}";
        echo;
        h2 "Your github organization was saved in your ~/.gitconfig file." "To change it in the future, run: ${bldylw}github.org ${blgrn}new-organization";
        echo;
    fi;
    github.org > /dev/null
}

```

#### `github.validate`

```bash
github.validate ()
{
    inf "Validating Github Configuration...";
    if github.org > /dev/null; then
        ok:;
        return 0;
    else
        not-ok:;
        github.setup;
        return $?;
    fi
}

```


---


### Module `jemalloc`

#### `jm.check`

```bash
jm.check ()
{
    local JM_Quiet=false;
    local JM_Ruby=false;
    local JM_Stats=false;
    while :; do
        case $1 in
            -q | --quiet)
                shift;
                export JM_Quiet=true
            ;;
            -r | --ruby)
                shift;
                export JM_Ruby=true
            ;;
            -s | --stats)
                shift;
                export JM_Stats=true;
                exit $?
            ;;
            -h | -\? | --help)
                shift;
                jm.usage;
                exit 0
            ;;
            --)
                shift;
                break
            ;;
            *)
                break
            ;;
        esac;
    done;
    ${JM_Ruby} && {
        jm.ruby.report;
        exit 0
    };
    ${JM_Quiet} && {
        jm.jemalloc.detect-quiet;
        code=$?;
        exit ${code}
    };
    ${JM_Stats} && {
        jm.jemalloc.stats;
        exit 0
    };
    jm.jemalloc.detect-loud
}

```

#### `jm.jemalloc.detect-loud`

```bash
jm.jemalloc.detect-loud ()
{
    jm.jemalloc.detect-quiet;
    local code=$?;
    local local_ruby=$(jm.ruby.detect);
    printf "${ColorBlue}Checking if ruby ${ColorYellow}${local_ruby}${ColorBlue} is linked with jemalloc... \n\n ";
    if [[ ${code} -eq 0 ]]; then
        printf " ✅ ${ColorGreen} — jemalloc was detected.\n";
    else
        printf " 🚫 ${ColorRed} — jemalloc was not detected.\n";
    fi;
    printf "${ColorReset}\n";
    return ${code}
}

```

#### `jm.jemalloc.detect-quiet`

```bash
jm.jemalloc.detect-quiet ()
{
    MALLOC_CONF=stats_print:true ruby -e "exit" 2>&1 | grep -q "jemalloc statistics";
    return $?
}

```

#### `jm.jemalloc.stats`

```bash
jm.jemalloc.stats ()
{
    jm.jemalloc.detect-quiet || {
        printf "No Jemalloc was found for the curent ruby $(jm.ruby.detect)\n";
        return 1
    };
    MALLOC_CONF=stats_print:true ruby -e "exit" 2>&1 | less -S
}

```

#### `jm.ruby.detect`

```bash
jm.ruby.detect ()
{
    local ruby_loc;
    if [[ -n $(which rbenv) ]]; then
        ruby_loc=$(rbenv versions | grep '*' | awk '{print $2}');
        [[ -n ${ruby_loc} ]] && ruby_loc="(rbenv) ${ruby_loc}";
    else
        ruby_loc="$(which ruby) $(ruby -e 'puts "#{RUBY_VERSION} (#{RUBY_PLATFORM})"')";
    fi;
    printf "%s" "${ruby_loc}"
}

```

#### `jm.ruby.report`

```bash
jm.ruby.report ()
{
    printf "Ruby version being tested:\n  →  ${ColorBlue}$(which ruby) ${ColorYellow}$(jm.ruby.detect)${ColorReset}\n"
}

```

#### `jm.usage`

```bash
jm.usage ()
{
    printf "
${ColorBlue}USAGE:${ColorReset}
  $(basename $0) [ -q/--quiet ]
                 [ -r/--ruby  ]
                 [ -s/--stats ]
                 [ -h/--help  ]

${ColorBlue}DESCRIPTION:${ColorReset}
  Determines whether the currently defined in the PATH ruby
  interpreter is linked with libjemalloc memory allocator.

${ColorBlue}OPTIONS${ColorReset}
  -q/--quiet        Do not print output, exit with 1 if no jemalloc
  -r/--ruby         Print which ruby is currently in the PATH
  -s/--stats        Print the jemalloc stats
  -h/--help         This page.
%s
" "";
    exit 0
}

```


---


### Module `json`

#### `json.begin-array`

```bash
json.begin-array ()
{
    [[ -n "$1" ]] && json.begin-key "$1";
    echo " ["
}

```

#### `json.begin-hash`

```bash
json.begin-hash ()
{
    [[ -n "$1" ]] && json.begin-key "$1";
    echo "{"
}

```

#### `json.begin-key`

```bash
json.begin-key ()
{
    if [[ -n "$1" ]]; then
        printf "\"${1}\": ";
    fi
}

```

#### `json.end-array`

```bash
json.end-array ()
{
    printf "]";
    [[ "$1" == "true" ]] && printf ",";
    echo
}

```

#### `json.end-hash`

```bash
json.end-hash ()
{
    printf "}";
    [[ "$1" == "true" ]] && printf ",";
    echo
}

```

#### `json.file-to-array`

```bash
json.file-to-array ()
{
    json.begin-array "$1";
    cat $2 | tr -d '\r' | tr -d '\015' | sed 's/^/"/g;s/$/",/g' | tail -r | awk -F, '{if (FNR!=1) print; else print $1} ' | tail -r;
    json.end-array $3
}

```


---


### Module `net`

#### `net.fast-scan`

```bash
net.fast-scan ()
{
    local subnet="${1:-"$(...net.local-subnet)"}";
    local out=$(mktemp);
    run.set-next show-output-on;
    local colored=/tmp/colored.$$;
    run "sudo nmap --min-parallelism 15 -O --host-timeout 5 -F ${subnet} > ${out}";
    run "echo 'printf \"' > ${colored}";
    cat ${out} | sed -E "s/Nmap scan report for (.*)$/\n\${bldylw}Nmap scan report for \1\${clr}\n/g" >> ${colored};
    run "echo '\"' >> ${colored}";
    bash ${colored}
}

```

#### `net.local-subnet`

```bash
net.local-subnet ()
{
    local subnet="$(ifconfig -a |
    grep 'inet ' |
    egrep -v 'inet 169|inet 127' |
    awk '{print $2}' |
    cut -d '.' -f 1,2,3 |
    sort |
    uniq |
    head -1).0/24";
    printf '%s' ${subnet}
}

```


---


### Module `osx`

#### `afp.servers`

```bash
afp.servers ()
{
    osx.local-servers afp
}

```

#### `bashmatic-set-fqdn`

```bash
bashmatic-set-fqdn ()
{
    osx.set-fqdn "$@"
}

```

#### `bashmatic-term`

```bash
bashmatic-term ()
{
    open $(bashmatic-term-program)
}

```

#### `bashmatic-term-program`

```bash
bashmatic-term-program ()
{
    if [[ -d /Applications/iTerm.app ]]; then
        printf '%s' /Applications/iTerm.app;
    else
        if [[ -d /Applications/Utilities/Terminal.app ]]; then
            printf '%s' /Applications/Utilities/Terminal.app;
        else
            printf '%s' "echo 'No TERMINAL application found'";
        fi;
    fi
}

```

#### `change-underscan`

```bash
change-underscan ()
{
    set +e;
    local amount_percentage="$1";
    if [[ -z "${amount_percentage}" ]]; then
        printf "%s\n\n" "USAGE: change-underscan percent";
        printf "%s\n" "   eg: change-underscan   5  # underscan by 5%";
        printf "%s\n" "   eg: change-underscan -10  # overscan by 10%";
        return -1;
    fi;
    local file="/var/db/.com.apple.iokit.graphics";
    local backup="/var/db/.com.apple.iokit.graphics.bak.$(date '+%F.%X')";
    local new_value=$(ruby -e "puts (10000.0 + 10000.0 * ${amount_percentage}.to_f / 100.0).to_i");
    h1 'This utility allows you to change underscan/overscan' 'on monitors that do not offer that option via GUI.';
    run.ui.ask "Continue?";
    info "Great! First we need to identify your monitor.";
    hl.yellow "Please make sure that the external monitor is plugged in.";
    run.ui.ask "Is it plugged in?";
    info "Making a backup of your current graphics settings...";
    inf "Please enter your password, if asked: ";
    set -e;
    bash -c 'set -e; sudo ls -1 > /dev/null; set +e';
    ok;
    run "sudo rm -f \"${backup}\"";
    export LibRun__AbortOnError=${True};
    run "sudo cp -v \"${file}\" \"${backup}\"";
    h2 "Now: please change the resolution ${bldylw}on the problem monitor." "NOTE: it's ${italic}not important what resolution you choose," "as long as it's different than what you had previously..." "Finally: exit Display Preferences once you changed resolution.";
    run "open /System/Library/PreferencePanes/Displays.prefPane";
    run.ui.ask "Have you changed the resolution and exited Display Prefs? ";
    local line=$(sudo diff "${file}" "${backup}" 2>/dev/null | head -1 | /usr/bin/env ruby -ne 'puts $_.to_i');
    [[ -n $DEBUG ]] && info "diff line is at ${line}";
    value=;
    if [[ "${line}" -gt 0 ]]; then
        line_pscn_key=$(($line - 4));
        line_pscn_value=$(($line - 3));
        ( awk "NR==${line_pscn_key}{print;exit}" "${file}" | grep -q pscn ) && {
            value=$(awk "NR==${line_pscn_value}{print;exit}" "${file}" | awk 'BEGIN{FS="[<>]"}{print $3}');
            [[ -n $DEBUG ]] && info "current value is ${value}"
        };
    else
        error "It does not appear that anything changed, sorry.";
        return -1;
    fi;
    h2 "Now, please unplug the problem monitor temporarily...";
    run.ui.ask "...and press Enter to continue ";
    if [[ -n ${value} && ${value} -ne ${new_value} ]]; then
        export LibRun__AbortOnError=${True};
        run "sudo sed -i.backup \"${line_pscn_value}s/${value}/${new_value}/g\" \"${file}\"";
        echo;
        h2 "Congratulations!" "Your display underscan value has been changed.";
        info "Previous Value — ${bldpur}${value}";
        info "New value:     — ${bldgrn}${new_value}";
        hr;
        info "${bldylw}IMPORTANT!";
        info "You must restart your computer for the settings to take affect.";
        echo;
        run.ui.ask "Should I reboot your computer now? ";
        info "Very well, rebooting!";
        run "sudo reboot";
    else
        warning "Unable to find the display scan value to change. ";
        info "Could it be that you haven't restarted since your last run?";
        echo;
        info "Feel free to edit file directly, using:";
        info "eg: ${bldylw}vim ${file} +${line_pscn_value}";
    fi
}

```

#### `cookie-dump`

```bash
cookie-dump ()
{
    osx.cookie-dump "$@"
}

```

#### `http.servers`

```bash
http.servers ()
{
    osx.local-servers http
}

```

#### `https.servers`

```bash
https.servers ()
{
    osx.local-servers https
}

```

#### `osx.cookie-dump`

```bash
osx.cookie-dump ()
{
    local file="$1";
    local tmp;
    if [[ ! -s ${file} ]]; then
        tmp=$(mktemp);
        file=${tmp};
        pbpaste > ${file};
        local size=$(file.size ${file});
        if [[ ${size} -lt 4 ]]; then
            error "Pasted data is too small to be a valid cookie?";
            info "Here is what we got in your clipboard:\n\n$(cat ${file})\n";
            return 1;
        fi;
    fi;
    if [[ -s ${file} ]]; then
        cat "${file}" | tr '; ' '\n' | sed '/^$/d' | awk 'BEGIN{FS="="}{printf( "%10d = %s\n", length($2), $1) }' | sort -n;
    else
        info "File ${file} does not exist or is empty. ";
        info "Copy the value of the ${bldylw}Set-Cookie:${txtblu} header into the clipboard,";
        info "and rerun this function.";
    fi;
    [[ -z ${tmp} ]] || rm -f ${tmp}
}

```

#### `osx.env-print`

```bash
osx.env-print ()
{
    local var="$1";
    printf "${bldylw}%20s: ${bldgrn}%s\n" ${var} ${!var}
}

```

#### `osx.local-servers`

```bash
osx.local-servers ()
{
    local protocol="${1:-"ssh"}";
    run.set-next show-output-on;
    run "timeout 20 dns-sd -B _${protocol}._tcp ."
}

```

#### `osx.ramdisk.mount`

```bash
osx.ramdisk.mount ()
{
    [[ $(uname -s) != "Darwin" ]] && {
        error "This function only works on OSX";
        return 1
    };
    if [[ -z $(df -h | grep ramdisk) ]]; then
        diskutil erasevolume HFS+ 'ramdisk' $(hdiutil attach -nomount ram://8192);
    fi
}

```

#### `osx.ramdisk.unmount`

```bash
osx.ramdisk.unmount ()
{
    [[ $(uname -s) != "Darwin" ]] && {
        error "This function only works on OSX";
        return 1
    };
    if [[ -n $(df -h | grep ramdisk) ]]; then
        umount /Volumes/ramdisk;
    fi
}

```

#### `osx.scutil-print`

```bash
osx.scutil-print ()
{
    local var="$1";
    printf "${bldylw}%20s: ${bldgrn}%s\n" ${var} $(sudo scutil --get ${var} | tr -d '\n')
}

```

#### `osx.set-fqdn`

```bash
osx.set-fqdn ()
{
    local fqdn="$1";
    local domain=$(echo ${fqdn} | sed -E 's/^[^.]*\.//g');
    local host=$(echo ${fqdn} | sed -E 's/\..*//g');
    h1 "Current HostName: ${bldylw}${HOSTNAME}";
    echo;
    info "• You provided the following FQDN : ${bldylw}${fqdn}";
    echo;
    info "• Hostname will be set to: ${bldgrn}${host}";
    info "• Domain will also change: ${bldgrn}${domain}";
    echo;
    run.ui.ask "Does that look correct to you?";
    echo;
    inf "Now, please provide your SUDO password, if asked: ";
    sudo printf '' || {
        ui.closer.not-ok:;
        exit 1
    };
    ui.closer.ok:;
    run "sudo scutil --set HostName ${fqdn}";
    run "sudo scutil --set LocalHostName ${host}.local 2>/dev/null|| true";
    run "sudo scutil --set ComputerName ${host}";
    run "dscacheutil -flushcache";
    echo;
    h2 "Result of the changes:";
    osx.scutil-print HostName;
    osx.scutil-print LocalHostName;
    osx.scutil-print ComputerName;
    osx.env-print HOSTNAME;
    echo;
    hr
}

```

#### `ssh.servers`

```bash
ssh.servers ()
{
    osx.local-servers ssh
}

```


---


### Module `output`

#### `abort`

```bash
abort ()
{
    printf -- "${LibOutput__LeftPrefix}${txtblk}${bakred}  « ABORT »  ${clr} ${bldwht} ✔  ${bldgrn}$*${clr}" 1>&2;
    echo
}

```

#### `ascii-clean`

```bash
ascii-clean ()
{
    .output.clean "$@"
}

```

#### `ask`

```bash
ask ()
{
    printf -- "%s${txtylw}$*${clr}\n" "${LibOutput__LeftPrefix}";
    printf -- "%s${txtylw}❯ ${bldwht}" "${LibOutput__LeftPrefix}"
}

```

#### `box.blue-in-green`

```bash
box.blue-in-green ()
{
    .output.box "${bldblu}" "${bldgrn}" "$@"
}

```

#### `box.blue-in-yellow`

```bash
box.blue-in-yellow ()
{
    .output.box "${bldylw}" "${bldblu}" "$@"
}

```

#### `box.green-in-cyan`

```bash
box.green-in-cyan ()
{
    .output.box "${bldgrn}" "${bldcyn}" "$@"
}

```

#### `box.green-in-green`

```bash
box.green-in-green ()
{
    .output.box "${bldgrn}" "${bldgrn}" "$@"
}

```

#### `box.green-in-magenta`

```bash
box.green-in-magenta ()
{
    .output.box "${bldgrn}" "${bldpur}" "$@"
}

```

#### `box.green-in-yellow`

```bash
box.green-in-yellow ()
{
    .output.box "${bldgrn}" "${bldylw}" "$@"
}

```

#### `box.magenta-in-blue`

```bash
box.magenta-in-blue ()
{
    .output.box "${bldblu}" "${bldpur}" "$@"
}

```

#### `box.magenta-in-green`

```bash
box.magenta-in-green ()
{
    .output.box "${bldpur}" "${bldgrn}" "$@"
}

```

#### `box.red-in-magenta`

```bash
box.red-in-magenta ()
{
    .output.box "${bldred}" "${bldpur}" "$@"
}

```

#### `box.red-in-red`

```bash
box.red-in-red ()
{
    .output.box "${bldred}" "${txtred}" "$@"
}

```

#### `box.red-in-yellow`

```bash
box.red-in-yellow ()
{
    .output.box "${bldred}" "${bldylw}" "$@"
}

```

#### `box.yellow-in-blue`

```bash
box.yellow-in-blue ()
{
    .output.box "${bldylw}" "${bldblu}" "$@"
}

```

#### `box.yellow-in-red`

```bash
box.yellow-in-red ()
{
    .output.box "${bldred}" "${bldylw}" "$@"
}

```

#### `box.yellow-in-yellow`

```bash
box.yellow-in-yellow ()
{
    .output.box "${bldylw}" "${txtylw}" "$@"
}

```

#### `br`

```bash
br ()
{
    echo
}

```

#### `center`

```bash
center ()
{
    .output.center "$@"
}

```

#### `columnize`

```bash
columnize ()
{
    local columns="${1:-2}";
    local sw=${SCREEN_WIDTH:-120};
    [[ -z ${sw} ]] && sw=$(screen-width);
    pr -l 10000 -${columns} -e4 -w ${sw} | expand -8 | sed -E '/^ *$/d' | grep -v 'Page '
}

```

#### `command-spacer`

```bash
command-spacer ()
{
    local color="${txtgrn}";
    [[ ${LibRun__LastExitCode} -ne 0 ]] && color="${txtred}";
    [[ -z ${LibRun__AssignedWidth} || -z ${LibRun__CommandLength} ]] && return;
    printf "%s${color}" "";
    local __width=$((LibRun__AssignedWidth - LibRun__CommandLength - 10));
    [[ ${__width} -gt 0 ]] && .output.replicate-to "▪" "${__width}"
}

```

#### `cursor.at.x`

```bash
cursor.at.x ()
{
    .output.cursor-move-to-x "$@"
}

```

#### `cursor.at.y`

```bash
cursor.at.y ()
{
    .output.cursor-move-to-y "$@"
}

```

#### `cursor.down`

```bash
cursor.down ()
{
    .output.cursor-down-by "$@"
}

```

#### `cursor.left`

```bash
cursor.left ()
{
    .output.cursor-left-by "$@"
}

```

#### `cursor.rewind`

```bash
cursor.rewind ()
{
    local x=${1:-0};
    .output.cursor-move-to-x ${x}
}

```

#### `cursor.right`

```bash
cursor.right ()
{
    .output.cursor-right-by "$@"
}

```

#### `cursor.up`

```bash
cursor.up ()
{
    .output.cursor-up-by "$@"
}

```

#### `debug`

```bash
debug ()
{
    [[ -z ${DEBUG} ]] && return;
    printf -- "${LibOutput__LeftPrefix}${txtblk}${bakwht}[ debug ] $*  ${clr}\n"
}

```

#### `duration`

```bash
duration ()
{
    local millis="$1";
    local exit_code="$2";
    [[ -n $(which bc) ]] || return;
    if [[ -n ${millis} && ${millis} -ge 0 ]]; then
        local pattern;
        pattern=" %6.6s ms ";
        pattern="${txtblu}〔${pattern}〕";
        printf "${txtblu}${pattern}" "${millis}";
    fi;
    if [[ -n ${exit_code} ]]; then
        [[ ${exit_code} -eq 0 ]] && printf " ${txtblk}${bakgrn} %3d ${clr}" ${exit_code};
        [[ ${exit_code} -gt 0 ]] && printf " ${bldwht}${bakred} %3d ${clr}" ${exit_code};
    fi
}

```

#### `err`

```bash
err ()
{
    printf -- "${LibOutput__LeftPrefix}${bldylw}${bakred}  « ERROR! »  ${clr} ${bldred}$*${clr}" 1>&2
}

```

#### `error`

```bash
error ()
{
    header=$(printf -- "${txtblk}${bakred} « ERROR » ${clr}");
    box.red-in-red "${header} ${bldylw}$@" 1>&2
}

```

#### `error:`

```bash
error: ()
{
    err $*;
    ui.closer.not-ok:
}

```

#### `h.black`

```bash
h.black ()
{
    center "${bldylw}${bakblk}" "$@"
}

```

#### `h.blue`

```bash
h.blue ()
{
    center "${txtblk}${bakblu}" "$@"
}

```

#### `h.green`

```bash
h.green ()
{
    center "${txtblk}${bakgrn}" "$@"
}

```

#### `h.red`

```bash
h.red ()
{
    center "${txtblk}${bakred}" "$@"
}

```

#### `h.yellow`

```bash
h.yellow ()
{
    center "${txtblk}${bakylw}" "$@"
}

```

#### `h1`

```bash
h1 ()
{
    box.blue-in-yellow "$@"
}

```

#### `h1.blue`

```bash
h1.blue ()
{
    box.magenta-in-blue "$@"
}

```

#### `h1.green`

```bash
h1.green ()
{
    box.green-in-magenta "$@"
}

```

#### `h1.purple`

```bash
h1.purple ()
{
    box.magenta-in-green "$@"
}

```

#### `h1.red`

```bash
h1.red ()
{
    box.red-in-red "$@"
}

```

#### `h1.yellow`

```bash
h1.yellow ()
{
    box.yellow-in-red "$@"
}

```

#### `h2`

```bash
h2 ()
{
    box.blue-in-green "$@"
}

```

#### `h2.green`

```bash
h2.green ()
{
    box.green-in-cyan "$@"
}

```

#### `h3`

```bash
h3 ()
{
    hl.subtle "$@"
}

```

#### `hdr`

```bash
hdr ()
{
    h1 "$@"
}

```

#### `hl.blue`

```bash
hl.blue ()
{
    left "${bldwht}${bakpur}" "$@"
}

```

#### `hl.desc`

```bash
hl.desc ()
{
    left "${bakylw}${txtblk}${bakylw}" "$@"
}

```

#### `hl.green`

```bash
hl.green ()
{
    left "${txtblk}${bakgrn}" "$@"
}

```

#### `hl.orange`

```bash
hl.orange ()
{
    left "${white_on_orange}" "$@"
}

```

#### `hl.subtle`

```bash
hl.subtle ()
{
    left "${bldwht}${bakblk}${underlined}" "$@"
}

```

#### `hl.white-on-orange`

```bash
hl.white-on-orange ()
{
    left "${white_on_orange}" "$@"
}

```

#### `hl.white-on-salmon`

```bash
hl.white-on-salmon ()
{
    left "${white_on_salmon}" "$@"
}

```

#### `hl.yellow`

```bash
hl.yellow ()
{
    left "${bakylw}${txtblk}" "$@"
}

```

#### `hl.yellow-on-gray`

```bash
hl.yellow-on-gray ()
{
    left "${yellow_on_gray}" "$@s"
}

```

#### `hr`

```bash
hr ()
{
    [[ -z "$*" ]] || printf $*;
    .output.hr
}

```

#### `hr.colored`

```bash
hr.colored ()
{
    local color="$*";
    [[ -z ${color} ]] && color="${bldred}";
    .output.hr "$(screen-width)" "—" "${*}"
}

```

#### `inf`

```bash
inf ()
{
    printf -- "${LibOutput__LeftPrefix}${txtblu}${clr}${txtblu}$*${clr}"
}

```

#### `info`

```bash
info ()
{
    inf $@;
    echo
}

```

#### `info:`

```bash
info: ()
{
    inf $*;
    ui.closer.ok:
}

```

#### `left`

```bash
left ()
{
    .output.left-justify "$@"
}

```

#### `left-prefix`

```bash
left-prefix ()
{
    [[ -z ${LibOutput__LeftPrefix} ]] && {
        export LibOutput__LeftPrefix=$(.output.replicate-to " " "${LibOutput__LeftPrefixLen}")
    };
    printf "${LibOutput__LeftPrefix}"
}

```

#### `not-ok`

```bash
not-ok ()
{
    ui.closer.not-ok "$@"
}

```

#### `not-ok:`

```bash
not-ok: ()
{
    ui.closer.not-ok: "$@"
}

```

#### `ok`

```bash
ok ()
{
    ui.closer.ok "$@"
}

```

#### `ok:`

```bash
ok: ()
{
    ui.closer.ok: "$@"
}

```

#### `okay`

```bash
okay ()
{
    printf -- " ${bldgrn} ✓ ALL OK 👍  $*${clr}" 1>&2;
    echo
}

```

#### `output.color.off`

```bash
output.color.off ()
{
    reset-color: 1>&2;
    reset-color: 1>&1
}

```

#### `output.color.on`

```bash
output.color.on ()
{
    printf "${bldred}" 1>&2;
    printf "${bldblu}" 1>&1
}

```

#### `output.is-pipe`

```bash
output.is-pipe ()
{
    [[ -p /dev/stdout ]]
}

```

#### `output.is-redirect`

```bash
output.is-redirect ()
{
    [[ ! -t 1 && ! -p /dev/stdout ]]
}

```

#### `output.is-ssh`

```bash
output.is-ssh ()
{
    [[ -n "${SSH_CLIENT}" || -n "${SSH_CONNECTION}" ]]
}

```

#### `output.is-terminal`

```bash
output.is-terminal ()
{
    output.is-tty || output.is-redirect || output.is-pipe || output.is-ssh
}

```

#### `output.is-tty`

```bash
output.is-tty ()
{
    [[ -t 1 ]]
}

```

#### `puts`

```bash
puts ()
{
    printf "  ⇨ ${txtwht}$*${clr}"
}

```

#### `reset-color`

```bash
reset-color ()
{
    printf "${clr}\n"
}

```

#### `reset-color:`

```bash
reset-color: ()
{
    printf "${clr}"
}

```

#### `screen-width`

```bash
screen-width ()
{
    .output.screen-width
}

```

#### `screen.height`

```bash
screen.height ()
{
    .output.screen-height
}

```

#### `screen.width`

```bash
screen.width ()
{
    .output.screen-width
}

```

#### `shutdown`

```bash
shutdown ()
{
    local message=${1:-"Shutting down..."};
    echo;
    box.red-in-red "${message}";
    echo;
    exit 1
}

```

#### `stderr`

```bash
stderr ()
{
    local file=$1;
    hl.subtle STDERR;
    printf "${txtred}";
    [[ -s ${file} ]] && cat ${file};
    reset-color
}

```

#### `stdout`

```bash
stdout ()
{
    local file=$1;
    hl.subtle STDOUT;
    printf "${clr}";
    [[ -s ${file} ]] && cat ${file};
    reset-color
}

```

#### `success`

```bash
success ()
{
    echo;
    printf -- "${LibOutput__LeftPrefix}${txtblk}${bakgrn}  « SUCCESS »  ${clr} ${bldwht} ✔  ${bldgrn}$*${clr}" 1>&2;
    echo;
    echo
}

```

#### `test-group`

```bash
test-group ()
{
    [[ -z ${white_on_salmon} ]] && hr;
    hl.white-on-salmon "$@"
}

```

#### `ui.closer.kind-of-ok`

```bash
ui.closer.kind-of-ok ()
{
    .output.cursor-left-by 1000;
    printf " ${bakylw}${bldwht} ❖ ${clr} "
}

```

#### `ui.closer.kind-of-ok:`

```bash
ui.closer.kind-of-ok: ()
{
    ui.closer.kind-of-ok $@;
    echo
}

```

#### `ui.closer.not-ok`

```bash
ui.closer.not-ok ()
{
    .output.cursor-left-by 1000;
    printf " ${bakred}${bldwht} ✘ ${clr} "
}

```

#### `ui.closer.not-ok:`

```bash
ui.closer.not-ok: ()
{
    ui.closer.not-ok $@;
    echo
}

```

#### `ui.closer.ok`

```bash
ui.closer.ok ()
{
    .output.cursor-left-by 1000;
    printf " ${txtblk}${bakgrn} ✔︎ ${clr} "
}

```

#### `ui.closer.ok:`

```bash
ui.closer.ok: ()
{
    ui.closer.ok "$@";
    echo
}

```

#### `warn`

```bash
warn ()
{
    printf -- "${LibOutput__LeftPrefix}${bldwht}${bakylw} « WARNING! » ${clr} ${bldylw}$*${clr}" 1>&2
}

```

#### `warning`

```bash
warning ()
{
    header=$(printf -- "${txtblk}${bakylw} « WARNING » ${clr}");
    box.yellow-in-yellow "${header} ${bldylw}$*" 1>&2
}

```

#### `warning:`

```bash
warning: ()
{
    warn $*;
    ui.closer.kind-of-ok:
}

```


---


### Module `pids`

#### `pall`

```bash
pall ()
{
    pids.all "$@"
}

```

#### `pid.alive`

```bash
pid.alive ()
{
    local pid="$1";
    util.is-numeric || {
        error "First argument to pid.alive must be numeric.";
        return 1
    };
    [[ -n "${pid}" && -n $(ps -p "${pid}" | grep -v TTY) ]]
}

```

#### `pid.sig`

```bash
pid.sig ()
{
    local pid="${1}";
    shift;
    local signal="${1}";
    shift;
    [[ -z "${pid}" || -z "${signal}" ]] && {
        printf "
USAGE:
  pid.sig pid signal
";
        return 1
    };
    util.is-numeric ${pid} || {
        error "First argument to pid.sig must be numeric.";
        return 1
    };
    util.is-numeric ${signal} || sig.is-valid ${signal} || {
        error "First argument to pid.sig must be numeric.";
        return 1
    };
    if pid.alive ${pid}; then
        info "sending ${bldred}${signal}$(txt-info) to ${bldylw}${pid}...";
        /bin/kill -s ${signal} ${pid} 2>&1 | cat > /dev/null;
    else
        warning "pid ${pid} was dead by the time we tried sending ${sig} to it.";
        return 1;
    fi
}

```

#### `pid.stop`

```bash
pid.stop ()
{
    local pid=${1};
    shift;
    local delay=${1:-"0.3"};
    shift;
    if [[ -z ${pid} ]]; then
        printf "
DESCRIPTION:
  If the given PID is active, first sends kill -TERM, waits a bit,
  then sends kill -9.

USAGE:
  ${bldgrn}pid.stop pid${clr}

EXAMPLES:
  # stop all sidekiqs, waiting half a sec in between
  ${bldgrn}pid.stop sidekiq 0.5${clr}
";
        return 1;
    fi;
    pid.alive "${pid}" && ( pid.sig "${pid}" "TERM" || true ) && sleep ${delay};
    pid.alive "${pid}" && pid.sig "${pid}" "KILL"
}

```

#### `pids-with-args`

```bash
pids-with-args ()
{
    local -a permitted=("%cpu" "%mem" acflag acflg args blocked caught comm command cpu cputime etime f flags gid group ignored inblk inblock jobc ktrace ktracep lim login logname lstart majflt minflt msgrcv msgsnd ni nice nivcsw nsignals nsigs nswap nvcsw nwchan oublk oublock p_ru paddr pagein pcpu pending pgid pid pmem ppid pri pstime putime re rgid rgroup rss ruid ruser sess sig sigmask sl start stat state stime svgid svuid tdev time tpgid tsess tsiz tt tty ucomm uid upr user usrpri utime vsize vsz wchan wq wqb wql wqr xstat);
    local -a additional=();
    local -a matching=();
    for arg in $@;
    do
        array.includes "${arg}" "${permitted[@]}" && additional=(${additional[@]} $arg) && continue;
        matching=("${matching[@]}" "${arg}");
    done;
    local columns="pid,ppid,user,%cpu,%mem,command";
    if [[ ${#additional[@]} -gt 0 ]]; then
        columns="${columns},$(array.join ',' "${additional[@]}")";
    fi;
    pids.matching.regexp "${matching[*]}" | xargs /bin/ps -www -o"${columns}" -p
}

```

#### `pids.all`

```bash
pids.all ()
{
    if [[ -z "${1}" ]]; then
        printf "
DESCRIPTION:
  prints processes matching a given pattern

USAGE:
  ${bldgrn}pids.all pattern${clr}

EXAMPLES:
  ${bldgrn}pids.all puma${clr}
";
        return 0;
    fi;
    local pattern="$(pids.normalize.search-string "$1")";
    shift;
    ps -ef | egrep "${pattern}" | egrep -v grep
}

```

#### `pids.for-each`

```bash
pids.for-each ()
{
    if [[ -z "${1}" || -z "${2}" ]]; then
        printf "
DESCRIPTION:
  loops over matching PIDs and calls a named BASH function

USAGE:
  ${bldgrn}pids.for-each pattern function${clr}

EXAMPLES:
  ${bldgrn}pids.for-each puma echo
  function hup() { kill -HUP \$1; }; pids.for-each sidekiq hup${clr}
";
        return 0;
    fi;
    local pattern="$(pids.normalize.search-string "$1")";
    shift;
    local func=${1:-"echo"};
    if [[ -z $(which ${func}) && -z $(type ${func} 2>/dev/null) ]]; then
        errror "Function ${func} does not exist.";
        return 1;
    fi;
    while true; do
        local -a pids=($(pids.matching "${pattern}"));
        [[ ${#pids[@]} == 0 ]] && break;
        eval "${func} ${pids[0]}";
        sleep 0.1;
    done
}

```

#### `pids.matching`

```bash
pids.matching ()
{
    local pattern="${1}";
    if [[ -z "${pattern}" ]]; then
        printf "
DESCRIPTION:
  Finds process IDs matching a given string.

USAGE:
  ${bldgrn}pids.matching string${clr}

EXAMPLES:
  ${bldgrn}pids.matching sidekiq${clr}
";
        return 0;
    fi;
    pattern="$(pids.normalize.search-string ${pattern})";
    pids.matching.regexp "${pattern}"
}

```

#### `pids.matching.regexp`

```bash
pids.matching.regexp ()
{
    local pattern="${1}";
    if [[ -z "${pattern}" ]]; then
        printf "
DESCRIPTION:
  Finds process IDs matching a given regexp.

USAGE:
  ${bldgrn}pids.matching regular-expression${clr}

EXAMPLES:
  ${bldgrn}pids.matching '[s]idekiq\s+' ${clr}
";
        return 0;
    fi;
    ps -ef | egrep "${pattern}" | egrep -v grep | awk '{print $2}' | sort -n
}

```

#### `pids.normalize.search-string`

```bash
pids.normalize.search-string ()
{
    local pattern="$*";
    [[ "${pattern:0:1}" == '[' ]] || pattern="[${pattern:0:1}]${pattern:1}";
    printf "${pattern}"
}

```

#### `pids.stop`

```bash
pids.stop ()
{
    if [[ -z "${1}" ]]; then
        printf "
DESCRIPTION:
  finds and stops IDs matching a given pattern

USAGE:
  ${bldgrn}pids.stop <pattern>${clr}

EXAMPLES:
  ${bldgrn}pids.stop puma${clr}
";
        return 0;
    fi;
    pids.for-each "${1}" "pid.stop"
}

```

#### `pstop`

```bash
pstop ()
{
    pids.stop "$@"
}

```

#### `sig.is-valid`

```bash
sig.is-valid ()
{
    [[ -n $(kill -l ${1} 2>/dev/null) ]]
}

```

#### `sig.list`

```bash
sig.list ()
{
    /bin/kill -l | sed -E 's/([ 0-9][0-9]\) SIG)//g; s/\s+/\n/g' | tr 'a-z' 'A-Z' | sort
}

```


---


### Module `progress-bar`

#### `progress.bar.auto-run`

```bash
progress.bar.auto-run ()
{
    .progress.reset;
    .progress.bar "$@";
    code=$?;
    if [[ ${code} -ne 0 ]]; then
        .progress.reset;
        return 1;
    fi;
    return 0
}

```

#### `progress.bar.config`

```bash
progress.bar.config ()
{
    while true; do
        local setting="$1";
        shift;
        [[ -z ${setting} ]] && break;
        local key=${setting/=*/};
        local value=${setting/*=/};
        eval "export LibProgress__${key}=\"${value}\"";
    done
}

```

#### `progress.bar.configure.color-green`

```bash
progress.bar.configure.color-green ()
{
    progress.bar.config BarColor=${bldgrn}
}

```

#### `progress.bar.configure.color-red`

```bash
progress.bar.configure.color-red ()
{
    progress.bar.config BarColor=${bldred}
}

```

#### `progress.bar.configure.color-yellow`

```bash
progress.bar.configure.color-yellow ()
{
    progress.bar.config BarColor=${bldylw}
}

```

#### `progress.bar.configure.symbol-arrow`

```bash
progress.bar.configure.symbol-arrow ()
{
    progress.bar.config BarChar="❯"
}

```

#### `progress.bar.configure.symbol-bar`

```bash
progress.bar.configure.symbol-bar ()
{
    progress.bar.config BarChar="█"
}

```

#### `progress.bar.configure.symbol-block`

```bash
progress.bar.configure.symbol-block ()
{
    progress.bar.config BarChar="${LibProgress__BarChar__Default}"
}

```

#### `progress.bar.configure.symbol-square`

```bash
progress.bar.configure.symbol-square ()
{
    progress.bar.config BarChar="◼︎"
}

```

#### `progress.bar.launch-and-wait`

```bash
progress.bar.launch-and-wait ()
{
    local command="$*";
    run.print-command "${command}\n";
    ${command} > /dev/null 2>&1 & local pid=$!;
    info "Waiting for background process to finish; PID=${bldylw}${pid}";
    set -e;
    while .progress.bar.check-pid-alive $pid; do
        progress.bar.auto-run 0.5 10;
    done;
    set +e;
    return 0
}

```


---


### Module `repositories`

#### `repo.rebase`

```bash
repo.rebase ()
{
    run "git pull origin master --rebase"
}

```

#### `repo.stash-and-rebase`

```bash
repo.stash-and-rebase ()
{
    run "git stash >/dev/null";
    run "git reset --hard";
    repo.rebase
}

```

#### `repo.update`

```bash
repo.update ()
{
    local folder="$1";
    h2 "Entering repo ► ${bldgren}${folder}";
    [[ -d "${folder}" ]] || return 1;
    [[ -d "${folder}/.git" ]] || return 1;
    [[ "$(pwd)" != "${folder}" ]] && {
        cd "${folder}" || return 2
    };
    if [[ -z "$(git status -s)" ]]; then
        repo.rebase;
    else
        repo.stash-and-rebase;
    fi
}

```

#### `repos.catch-interrupt`

```bash
repos.catch-interrupt ()
{
    export LibRepo__Interrupted=true
}

```

#### `repos.init-interrupt`

```bash
repos.init-interrupt ()
{
    export LibRepo__Interrupted=false;
    trap 'repos.catch-interrupt' SIGINT
}

```

#### `repos.recursive-update`

```bash
repos.recursive-update ()
{
    local repo="${1}";
    run.set-all show-output-off;
    if [[ ${LibRepo__Interrupted} == true ]]; then
        warn "Detected SINGINT, exiting...";
        return 2;
    fi;
    if [[ -n "$repo" ]]; then
        repo.update "$repo";
    else
        for dir in $(find . -type d -name '.git');
        do
            local subdir=$(dirname "$dir");
            [[ -n "${DEBUG}" ]] && info "checking out sub-folder ${bldcyn}${subdir}...";
            repos.recursive-update "${subdir}";
            if [[ $? -eq 2 ]]; then
                error "folder ${bldylw}${subdir}${bldred} return error!";
                return 2;
            fi;
        done;
    fi;
    if [[ -n ${repo} ]]; then
        info "returning to the root dir ${bldylw}${root_folder}...";
        cd "${root_folder}" > /dev/null || return 2;
    fi
}

```

#### `repos.update`

```bash
repos.update ()
{
    export root_folder="$(pwd)";
    bash -c "
    [[ -d ~/.bashmatic ]] || {
      echo 'Can not find bashmatic installation sorry'
      return
    }
    source ~/.bashmatic/init.sh
    repos.init-interrupt
    repos.recursive-update '$*'
  "
}

```

#### `repos.was-interrupted`

```bash
repos.was-interrupted ()
{
    [[ ${LibRepo__Interrupted} == true ]]
}

```


---


### Module `ruby`

#### `bundle.gems-with-c-extensions`

```bash
bundle.gems-with-c-extensions ()
{
    run.set-next show-output-on;
    run "bundle show --paths | ruby -e \"STDIN.each_line {|dep| puts dep.split('/').last if File.directory?(File.join(dep.chomp, 'ext')) }\""
}

```

#### `interrupted`

```bash
interrupted ()
{
    export BashMatic__Interrupted=true
}

```

#### `ruby.bundler-version`

```bash
ruby.bundler-version ()
{
    if [[ ! -f Gemfile.lock ]]; then
        error "Can not find Gemfile.lock";
        return 1;
    fi;
    tail -1 Gemfile.lock | sedx 's/ //g'
}

```

#### `ruby.compiled-with`

```bash
ruby.compiled-with ()
{
    if [[ -z "$*" ]]; then
        error "usage: ruby.compiled-with <library>";
        return 1;
    fi;
    ruby -r rbconfig -e "puts RbConfig.CONFIG['LIBS']" | grep -q "$*"
}

```

#### `ruby.default-gems`

```bash
ruby.default-gems ()
{
    declare -a DEFAULT_RUBY_GEMS=(rubocop relaxed-rubocop rubocop-performance warp-dir colored2 sym pg pry pry-doc pry-byebug rspec rspec-its awesome_print activesupport pivotal_git_scripts git-smart travis awscli irbtools);
    export DEFAULT_RUBY_GEMS;
    printf "${DEFAULT_RUBY_GEMS[*]}"
}

```

#### `ruby.full-version`

```bash
ruby.full-version ()
{
    /usr/bin/env ruby --version
}

```

#### `ruby.gemfile-lock-version`

```bash
ruby.gemfile-lock-version ()
{
    local gem=${1};
    if [[ ! -f Gemfile.lock ]]; then
        error "Can not find Gemfile.lock";
        return 1;
    fi;
    egrep " ${gem} \([0-9]" Gemfile.lock | sed -e 's/[\(\)]//g' | awk '{print $2}'
}

```

#### `ruby.gems`

```bash
ruby.gems ()
{
    ruby.gems.install "$@"
}

```

#### `ruby.gems.install`

```bash
ruby.gems.install ()
{
    local -a gems=($@);
    gem.clear-cache;
    [[ ${#gems[@]} -eq 0 ]] && gems=($(ruby.default-gems));
    local -a existing=($(ruby.installed-gems));
    [[ ${#gems[@]} -eq 0 ]] && {
        error 'Unable to determine what gems to install. ' "Argument is empty, so is ${DEFAULT_RUBY_GEMS[@]}" "USAGE: ${bldgrn}ruby.gems ${bldred} rails rubocop puma pry";
        return 1
    };
    h2 "There are a total of ${#existing[@]} of globally installed Gems." "Total of ${#gems[@]} need to be installed unless they already exist. " "${bldylw}Checking for gems that still missing...";
    local -a gems_to_be_installed=();
    for gem in "${gems[@]}";
    do
        local gem_info=;
        if [[ $(array.has-element "${gem}" "${existing[@]}") == "true" ]]; then
            gem_info="${bldgrn} ✔  ${gem}${clr}\n";
        else
            gem_info="${bldred} x  ${gem}${clr}\n";
            gems_to_be_installed=(${gems_to_be_installed[@]} ${gem});
        fi;
        printf "   ${gem_info}";
    done;
    hl.subtle "It appears that only ${#gems_to_be_installed[@]} gems are left to install...";
    local -a gems_installed=();
    for gem in ${gems_to_be_installed[@]};
    do
        run "gem install -q --force --no-document $gem";
        if [[ ${LibRun__LastExitCode} -ne 0 ]]; then
            error "Gem ${gem} refuses to install." "Perhaps try installing it manually?" "${bldgrn}Action: Skip and Continuing...";
            break;
        else
            gem_installed=(${gem_installed[@]} ${gem});
            continue;
        fi;
    done;
    hr;
    echo;
    gem.clear-cache;
    success "Total of ${#gem_installed[@]} gems were successfully installed.";
    echo
}

```

#### `ruby.gems.uninstall`

```bash
ruby.gems.uninstall ()
{
    local -a gems=($@);
    gem.clear-cache;
    [[ ${#gems[@]} -eq 0 ]] && declare -a gems=($(ruby.default-gems));
    local -a existing=($(ruby.installed-gems));
    [[ ${#gems[@]} -eq 0 ]] && {
        error "Unable to determine what gems to remove. Argument is empty, so is ${DEFAULT_RUBY_GEMS[@]}" "USAGE: ${bldgrn}ruby.gems.uninstall ${bldred} rails rubocop puma pry";
        return 1
    };
    h1.blue "There are a total of ${#existing[@]} of gems installed in a global namespace." "Total of ${#gems[@]} need to be removed.";
    local deleted=0;
    for gem in ${gems[@]};
    do
        local gem_info=;
        if [[ $(array.has-element "${gem}" "${existing[@]}") == "true" ]]; then
            run "gem uninstall -a -x -I -D --force ${gem}";
            deleted=$(($deleted + 1));
        else
            gem_info="${bldred} x [not found] ${bldylw}${gem}${clr}\n";
        fi;
        printf "   ${gem_info}";
    done;
    gem.clear-cache;
    echo;
    success "Total of ${deleted} gems were successfully obliterated.";
    echo
}

```

#### `ruby.init`

```bash
ruby.init ()
{
    h1 "Installing Critical Gems for Your Glove, Thanos...";
    ruby.rubygems-update;
    ruby.install-upgrade-bundler;
    ruby.gems.install;
    ruby.kigs-gems
}

```

#### `ruby.install`

```bash
ruby.install ()
{
    ruby.install-ruby "$@"
}

```

#### `ruby.install-ruby`

```bash
ruby.install-ruby ()
{
    local version="$1";
    local version_source="provided as an argument";
    if [[ -z ${version} && -f .ruby-version ]]; then
        version="$(cat .ruby-version | tr -d '\n')";
        version_source="auto-detected from .ruby-version file";
    fi;
    [[ -z ${version} ]] && {
        error "usage: ${BASH_SOURCE[*]} ruby-version" "Alternatively, create .ruby-version file";
        return 1
    };
    hl.subtle "Installing Ruby Version ${version} ${version_source}.";
    ruby.validate-version "${version}" || return 1;
    brew.install.packages rbenv ruby-build jemalloc;
    eval "$(rbenv init -)";
    run "RUBY_CONFIGURE_OPTS=--with-jemalloc rbenv install -s ${version}";
    return "${LibRun__LastExitCode:-"0"}"
}

```

#### `ruby.install-ruby-with-deps`

```bash
ruby.install-ruby-with-deps ()
{
    local version="$1";
    declare -a packages=(cask bash bash-completion git go haproxy htop jemalloc libxslt jq libiconv libzip netcat nginx openssl pcre pstree p7zip rbenv redis ruby_build tree vim watch wget zlib);
    run.set-next show-output-on;
    run "brew install --display-times ${packages[*]}"
}

```

#### `ruby.install-upgrade-bundler`

```bash
ruby.install-upgrade-bundler ()
{
    gem.install bundler;
    run "bundle --update bundler || true"
}

```

#### `ruby.installed-gems`

```bash
ruby.installed-gems ()
{
    gem list | cut -d ' ' -f 1 | uniq
}

```

#### `ruby.kigs-gems`

```bash
ruby.kigs-gems ()
{
    if [[ -z $(type wd 2>/dev/null) ]]; then
        wd install --dotfile ~/.bashrc > /dev/null;
        [[ -f ~/.bash_wd ]] && source ~/.bash_wd;
    fi;
    sym -B ~/.bashrc;
    for file in .sym.completion.bash .sym.symit.bash;
    do
        [[ -f ${file} ]] && next;
        sym -B ~/.bashrc;
        break;
    done
}

```

#### `ruby.linked-libs`

```bash
ruby.linked-libs ()
{
    ruby -r rbconfig -e "puts RbConfig.CONFIG['LIBS']"
}

```

#### `ruby.numeric-version`

```bash
ruby.numeric-version ()
{
    /usr/bin/env ruby --version | sed 's/^ruby //g; s/ (.*//g'
}

```

#### `ruby.rbenv`

```bash
ruby.rbenv ()
{
    if [[ -n "$*" ]]; then
        rbenv $*;
    else
        eval "$(rbenv init -)";
    fi;
    run "rbenv rehash"
}

```

#### `ruby.rubygems-update`

```bash
ruby.rubygems-update ()
{
    info "This might take a little white, darling. Smoke a spliff, would you?";
    run "gem update --system"
}

```

#### `ruby.stop`

```bash
ruby.stop ()
{
    local regex='/[r]uby| [p]uma| [i]rb| [r]ails | [b]undle| [u]nicorn| [r]ake';
    local procs=$(ps -ef | egrep "${regex}" | egrep -v grep | awk '{print $2}' | sort | uniq | wc -l);
    [[ ${procs} -eq 0 ]] && {
        info: "No ruby processes were found.";
        return 0
    };
    local -a pids=$(ps -ef | egrep "${regex}" | egrep -v grep | awk '{print $2}' | sort | uniq | tr '\n' ' -p ');
    h2 "Detected ${#pids[@]} Ruby Processes..., here is the tree:";
    printf "${txtcyn}";
    pstree ${pids[*]};
    printf "${clr}";
    hr;
    printf "To abort, press Ctrl-C. To kill them all press any key..";
    run.ui.press-any-key;
    ps -ef | egrep "${regex}" | egrep -v grep | awk '{print $2}' | sort | uniq | xargs kill -9
}

```

#### `ruby.top-versions`

```bash
ruby.top-versions ()
{
    local platform="${1:-"2\."}";
    rbenv install --list | egrep "^${platform}" | ruby -e '
      last_v = nil;
      last_m = nil;
      ARGF.each do |line|
        v = line.split(".")[0..1].join(".")
        if last_v != v
          puts last_m if last_m
          last_v = v;
        end;
        last_m = line
      end
      puts last_m if last_m'
}

```

#### `ruby.top-versions-as-yaml`

```bash
ruby.top-versions-as-yaml ()
{
    ruby.top-versions | sed 's/^/ - /g'
}

```

#### `ruby.validate-version`

```bash
ruby.validate-version ()
{
    local version="$1";
    local -a ruby_versions=();
    run "brew upgrade ruby-build || true";
    [[ -d ~/.rbenv/plugins/ruby-build ]] && {
        run "cd ~/.rbenv/plugins/ruby-build && git reset --hard && git pull --rebase"
    };
    array.from.stdin ruby_versions 'rbenv install --list | sed -E "s/\s+//g"';
    array.includes "${version}" "${ruby_versions[@]}" || {
        error "Ruby Version provided was found by rbenv: ${bldylw}${version}";
        return 1
    };
    return 0
}

```


---


### Module `run`

#### `run`

```bash
run ()
{
    .run "$@";
    return ${LibRun__LastExitCode}
}

```

#### `run.ui.ask`

```bash
run.ui.ask ()
{
    local question=$*;
    local func="${LibRun__AskDeclineFunction}";
    export LibRun__AskDeclineFunction="${LibRun__AskDeclineFunction__Default}";
    echo;
    inf "${bldcyn}${question}${clr} [Y/n] ${bldylw}";
    read a 2> /dev/null;
    code=$?;
    if [[ ${code} != 0 ]]; then
        error "Unable to read from STDIN.";
        eval "${func} 12";
    fi;
    echo;
    if [[ ${a} == 'y' || ${a} == 'Y' || ${a} == '' ]]; then
        info "${bldblu}Roger that.";
        info "Let's just hope it won't go nuclear on us :) 💥";
        hr;
        echo;
    else
        info "${bldred}(Great idea!) Abort! Abandon ship!  🛳   ";
        hr;
        echo;
        eval "${func} 1";
    fi
}

```

#### `run.ui.ask-user-value`

```bash
run.ui.ask-user-value ()
{
    local variable="$1";
    shift;
    local text="$*";
    local user_input;
    trap 'echo; echo Aborting at user request... ; echo; abort; return' int;
    ask "${text}";
    read user_input;
    if [[ -z "${user_input}" ]]; then
        error "Sorry, I didn't get that. Please try again or press Ctrl-C to abort.";
        return 1;
    else
        eval "export ${variable}=\"${user_input}\"";
        return 0;
    fi
}

```

#### `run.ui.get-user-value`

```bash
run.ui.get-user-value ()
{
    run.ui.retry-command run.ui.ask-user-value "${@}"
}

```

#### `run.ui.press-any-key`

```bash
run.ui.press-any-key ()
{
    local prompt="$*";
    [[ -z ${prompt} ]] && prompt="Press any key to continue...";
    br;
    printf "    ${txtgrn}${italic}${prompt} ${clr}  ";
    read -r -s -n1 key;
    cursor.rewind;
    printf "                                                           ";
    cursor.up 2;
    cursor.rewind;
    echo
}

```

#### `run.ui.retry-command`

```bash
run.ui.retry-command ()
{
    local command="$*";
    local retries=5;
    n=0;
    until [ $n -ge ${retries} ]; do
        [[ ${n} -gt 0 ]] && info "Retry number ${n}...";
        command && break;
        n=$(($n + 1));
        sleep 1;
    done
}

```


---


### Module `runtime-config`

#### `run.inspect`

```bash
run.inspect ()
{
    if [[ ${#@} -eq 0 || $(array.has-element "config" "$@") == "true" ]]; then
        run.inspect-variables-that-are starting-with LibRun;
    fi;
    if [[ ${#@} -eq 0 || $(array.has-element "totals" "$@") == "true" ]]; then
        hl.subtle "TOTALS";
        info "${bldgrn}${commands_completed} commands completed successfully";
        [[ ${commands_failed} -gt 0 ]] && info "${bldred}${commands_failed} commands failed";
        [[ ${commands_ignored} -gt 0 ]] && info "${bldylw}${commands_ignored} commands failed, but were ignored.";
        echo;
    fi;
    if [[ ${#@} -eq 0 || $(array.has-element "current" "$@") == "true" ]]; then
        run.inspect-variables-that-are ending-with __LastExitCode;
    fi;
    reset-color
}

```

#### `run.set-all`

```bash
run.set-all ()
{
    ____run.configure all "$@"
}

```

#### `run.set-all.list`

```bash
run.set-all.list ()
{
    set | egrep '^____run.set.all' | awk 'BEGIN{FS="."}{print $4}' | sedx 's/[() ]//g'
}

```

#### `run.set-next`

```bash
run.set-next ()
{
    ____run.configure next "$@"
}

```

#### `run.set-next.list`

```bash
run.set-next.list ()
{
    set | egrep '^____run.set.next' | awk 'BEGIN{FS="."}{print $4}' | sedx 's/[() ]//g'
}

```


---


### Module `runtime`

#### `run`

```bash
run ()
{
    .run "$@";
    return ${LibRun__LastExitCode}
}

```

#### `run.config.detail-is-enabled`

```bash
run.config.detail-is-enabled ()
{
    [[ ${LibRun__Detail} -eq ${True} ]]
}

```

#### `run.config.verbose-is-enabled`

```bash
run.config.verbose-is-enabled ()
{
    [[ ${LibRun__Verbose} -eq ${True} ]]
}

```

#### `run.inspect`

```bash
run.inspect ()
{
    if [[ ${#@} -eq 0 || $(array.has-element "config" "$@") == "true" ]]; then
        run.inspect-variables-that-are starting-with LibRun;
    fi;
    if [[ ${#@} -eq 0 || $(array.has-element "totals" "$@") == "true" ]]; then
        hl.subtle "TOTALS";
        info "${bldgrn}${commands_completed} commands completed successfully";
        [[ ${commands_failed} -gt 0 ]] && info "${bldred}${commands_failed} commands failed";
        [[ ${commands_ignored} -gt 0 ]] && info "${bldylw}${commands_ignored} commands failed, but were ignored.";
        echo;
    fi;
    if [[ ${#@} -eq 0 || $(array.has-element "current" "$@") == "true" ]]; then
        run.inspect-variables-that-are ending-with __LastExitCode;
    fi;
    reset-color
}

```

#### `run.inspect-variable`

```bash
run.inspect-variable ()
{
    local var_name=${1};
    local var_value=${!var_name};
    local value="";
    local print_value=;
    local max_len=120;
    local avail_len=$(($(screen.width) - 45));
    local lcase_var_name="$(echo ${var_name} | tr 'A-Z' 'a-z')";
    local print_value=1;
    local color="${bldblu}";
    local value_off=" ✘   ";
    local value_check="✔︎";
    if [[ -n "${var_value}" ]]; then
        if [[ ${lcase_var_name} =~ 'exit' ]]; then
            if [[ ${var_value} -eq 0 ]]; then
                value=${value_check};
                color="${bldgrn}";
            else
                print_value=1;
                value=${var_value};
                color="${bldred}";
            fi;
        else
            if [[ "${var_value}" == "${True}" ]]; then
                value="${value_check}";
                color="${bldgrn}";
            else
                if [[ "${var_value}" == "${False}" ]]; then
                    value="${value_off}";
                    color="${bldred}";
                fi;
            fi;
        fi;
    else
        value="${value_off}";
        color="${bldred}";
    fi;
    if [[ ${LibRun__Inspect__SkipFalseOrBlank} -eq ${True} && "${value}" == "${value_off}" ]]; then
        return 0;
    fi;
    printf "    ${bldylw}%-35s ${txtblk}${color} " ${var_name};
    [[ ${avail_len} -gt ${max_len} ]] && avail_len=${max_len};
    if [[ "${print_value}" -eq 1 ]]; then
        if [[ -n "${value}" ]]; then
            printf "%*.*s" ${avail_len} ${avail_len} "${value}";
        else
            if $(util.is-numeric "${var_value}"); then
                avail_len=$((${avail_len} - 5));
                if [[ "${var_value}" =~ '.' ]]; then
                    printf "%*.2f" ${avail_len} "${var_value}";
                else
                    printf "%*d" ${avail_len} "${var_value}";
                fi;
            else
                avail_len=$((${avail_len} - 5));
                printf "%*.*s" ${avail_len} ${avail_len} "${var_value}";
            fi;
        fi;
    else
        printf "%*.*s" ${avail_len} ${avail_len} "${value}";
    fi;
    echo
}

```

#### `run.inspect-variables`

```bash
run.inspect-variables ()
{
    local title=${1};
    shift;
    hl.subtle "${title}";
    for var in $@;
    do
        run.inspect-variable "${var}";
    done
}

```

#### `run.inspect-variables-that-are`

```bash
run.inspect-variables-that-are ()
{
    local pattern_type="${1}";
    local pattern="${2}";
    run.inspect-variables "VARIABLES $(echo ${pattern_type} | tr 'a-z' 'A-Z') ${pattern}" "$(run.variables-${pattern_type} ${pattern} | tr '\n' ' ')"
}

```

#### `run.inspect.set-skip-false-or-blank`

```bash
run.inspect.set-skip-false-or-blank ()
{
    local value="${1}";
    [[ -n "${value}" ]] && export LibRun__Inspect__SkipFalseOrBlank=${value};
    [[ -z "${value}" ]] && export LibRun__Inspect__SkipFalseOrBlank=${True}
}

```

#### `run.on-error.ask-is-enabled`

```bash
run.on-error.ask-is-enabled ()
{
    [[ ${LibRun__AskOnError} -eq ${True} ]]
}

```

#### `run.print-command`

```bash
run.print-command ()
{
    local command="$1";
    local max_width=100;
    local w;
    w=$(($(.output.screen-width) - 10));
    [[ ${w} -gt ${max_width} ]] && w=${max_width};
    export LibRun__AssignedWidth=${w};
    local prefix="${LibOutput__LeftPrefix}${clr}";
    local ascii_cmd;
    local command_prompt="${prefix}❯ ";
    local command_width=$((w - 30));
    ascii_cmd="$(printf "${command_prompt}%-.${command_width}s " "${command:0:${command_width}}")";
    export LibRun__CommandLength=${#ascii_cmd};
    [[ ${LibRun__ShowCommandOutput} -eq ${True} ]] && {
        export LibRun__AssignedWidth=$((w - 3));
        export LibRun__CommandLength=1;
        printf "${prefix}${txtblk}# Command below will be shown with its output:${clr}\n"
    };
    if [[ "${LibRun__ShowCommand}" -eq ${False} ]]; then
        printf "${prefix}❯ ${bldylw}%-.${command_width}s " "$(.output.replicate-to "*" 40)";
    else
        printf "${prefix}❯ ${bldylw}%-.${command_width}s " "${command:0:${command_width}}";
    fi
}

```

#### `run.print-variable`

```bash
run.print-variable ()
{
    run.inspect-variable $1
}

```

#### `run.print-variables`

```bash
run.print-variables ()
{
    local title=${1};
    shift;
    hl.yellow "${title}";
    for var in $@;
    do
        run.print-variable "${var}";
    done
}

```

#### `run.ui.press-any-key`

```bash
run.ui.press-any-key ()
{
    local prompt="$*";
    [[ -z ${prompt} ]] && prompt="Press any key to continue...";
    br;
    printf "    ${txtgrn}${italic}${prompt} ${clr}  ";
    read -r -s -n1 key;
    cursor.rewind;
    printf "                                                           ";
    cursor.up 2;
    cursor.rewind;
    echo
}

```

#### `run.variables-ending-with`

```bash
run.variables-ending-with ()
{
    local suffix="${1}";
    env | egrep ".*${suffix}=.*\$" | grep '=' | sedx 's/=.*//g' | sort
}

```

#### `run.variables-starting-with`

```bash
run.variables-starting-with ()
{
    local prefix="${1}";
    env | egrep "^${prefix}" | grep '=' | sedx 's/=.*//g' | sort
}

```

#### `run.with.minimum-duration`

```bash
run.with.minimum-duration ()
{
    local min_duration=$1;
    shift;
    local command="$*";
    local started=$(millis);
    info "starting a command with the minimum duration of ${bldylw}${min_duration} seconds";
    run "${command}";
    local result=$?;
    local duration=$((($(millis) - ${started}) / 1000));
    if [[ ${result} -eq 0 && ${duration} -lt ${min_duration} ]]; then
        local cmd="$(echo ${command} | sedx 's/\"//g')";
        error "An operation finished too quickly. The threshold was set to ${bldylw}${min_duration} sec." "The command took ${bldylw}${duration}${txtred} secs." "${bldylw}${cmd}${txtred}";
        ((${BASH_IN_SUBSHELL})) && exit 1 || return 1;
    else
        if [[ ${duration} -gt ${min_duration} ]]; then
            info "minimum duration operation ran in ${duration} seconds.";
        fi;
    fi;
    return ${result}
}

```

#### `run.with.ruby-bundle`

```bash
run.with.ruby-bundle ()
{
    .run.bundle.exec "$@"
}

```

#### `run.with.ruby-bundle-and-output`

```bash
run.with.ruby-bundle-and-output ()
{
    .run.bundle.exec.with-output "$@"
}

```


---


### Module `set`

#### `set-e-restore`

```bash
set-e-restore ()
{
    [[ -f ${__bash_set_errexit_status} ]] && {
        error "You must first save it with the function:s ${bldgrn}set-e-save";
        return 1
    };
    local status=$(cat ${__bash_set_errexit_status} | tr -d '\n');
    if [[ ${status} != 'on' && ${status} != 'off' ]]; then
        error "Invalid data in the set -e tempfile:" "$(cat ${__bash_set_errexit_status})";
        return 1;
    fi;
    set -o errexit ${status};
    rm -f ${__bash_set_errexit_status} 2> /dev/null
}

```

#### `set-e-save`

```bash
set-e-save ()
{
    export __bash_set_errexit_status=$(mktemp -t 'errexit');
    rm -f ${__bash_set_errexit_status} 2> /dev/null;
    set-e-status > ${__bash_set_errexit_status}
}

```

#### `set-e-status`

```bash
set-e-status ()
{
    set -o | grep errexit | awk '{print $2}'
}

```


---


### Module `settings`


---


### Module `shell-set`

#### `save-restore-x`

```bash
save-restore-x ()
{
    shell-set.pop-stack x
}

```

#### `save-set-x`

```bash
save-set-x ()
{
    shell-set.push-stack x
}

```

#### `shell-set.init-stack`

```bash
shell-set.init-stack ()
{
    unset SetOptsStack;
    declare -a SetOptsStack=();
    export SetOptsStack
}

```

#### `shell-set.is-set`

```bash
shell-set.is-set ()
{
    local v="$1";
    local is_set=${-//[^${v}]/};
    if [[ -n ${is_set} ]]; then
        return 0;
    else
        return 1;
    fi
}

```

#### `shell-set.pop-stack`

```bash
shell-set.pop-stack ()
{
    local value="$1";
    local len=${#SetOptsStack[@]};
    local last_index=$((len - 1));
    local last=${SetOptsStack[${last_index}]};
    if [[ ${last} != "-${value}" && ${last} != "+${value}" ]]; then
        error "Can not restore ${value}, not the last element in ${SetOptsStack[*]} stack.";
        return 1;
    fi;
    local pop=(${last});
    export SetOptsStack=("${SetOptsStack[@]/$pop/}");
    [[ -n ${DEBUG} ]] && shell-set-show;
    eval "set ${last}"
}

```

#### `shell-set.push-stack`

```bash
shell-set.push-stack ()
{
    local value="$1";
    local is_set=${-//[^${value}]/};
    shell-set.is-set ${value} && export SetOptsStack=(${SetOptsStack[@]} "-${value}");
    shell-set.is-set ${value} || export SetOptsStack=(${SetOptsStack[@]} "+${value}");
    [[ -n ${DEBUG} ]] && shell-set-show
}

```

#### `shell-set.show-stack`

```bash
shell-set.show-stack ()
{
    info "Current Shell Set Stack: ${bldylw}[${SetOptsStack[*]}]"
}

```


---


### Module `ssh`

#### `ssh.load-keys`

```bash
ssh.load-keys ()
{
    local pattern="$1";
    find ${HOME}/.ssh -type f -name "id_*${pattern}*" -and -not -name '*.pub' -print -exec ssh-add {} \;
}

```


---


### Module `subshell`

#### `bashmatic.detect-subshell`

```bash
bashmatic.detect-subshell ()
{
    bashmatic.subshell-init;
    [[ -n ${BASH_SUBSHELL_DETECTED} && -n ${BASH_IN_SUBSHELL} ]] && return ${BASH_IN_SUBSHELL};
    unset BASH_IN_SUBSHELL;
    export BASH_SUBSHELL_DETECTED=true;
    local len="${#BASH_SOURCE[@]}";
    local last_index=$((len - 1));
    [[ -n ${DEBUG} ]] && {
        echo "BASH_SOURCE[*] = ${BASH_SOURCE[*]}" 1>&2;
        echo "BASH_SOURCE[${last_index}] = ${BASH_SOURCE[${last_index}]}" 1>&2;
        echo "\$0            = $0" 1>&2
    };
    if [[ -n ${ZSH_EVAL_CONEXT} && ${ZSH_EVAL_CONTEXT} =~ :file$ ]] || [[ -n ${BASH_VERSION} && "$0" != "${BASH_SOURCE[${last_index}]}" ]]; then
        export BASH_IN_SUBSHELL=0;
    else
        export BASH_IN_SUBSHELL=1;
    fi;
    return ${BASH_IN_SUBSHELL}
}

```

#### `bashmatic.subshell-init`

```bash
bashmatic.subshell-init ()
{
    export BASH_SUBSHELL_DETECTED=
}

```

#### `bashmatic.validate-sourced-in`

```bash
bashmatic.validate-sourced-in ()
{
    bashmatic.detect-subshell;
    [[ ${BASH_IN_SUBSHELL} -eq 0 ]] || {
        echo "This script to be sourced in, not run in a subshell." 1>&2;
        return 1
    };
    return 0
}

```

#### `bashmatic.validate-subshell`

```bash
bashmatic.validate-subshell ()
{
    bashmatic.detect-subshell;
    [[ ${BASH_IN_SUBSHELL} -eq 1 ]] || {
        echo "This script to be run, not sourced-in" 1>&2;
        return 1
    };
    return 0
}

```


---


### Module `sym`

#### `decrypt.secrets`

```bash
decrypt.secrets ()
{
    ./bin/decrypt;
    local code=$?;
    [[ ${code} != 0 ]] && {
        error "bin/decrypt returned non-zero exit status ${code}";
        echo;
        exit ${code}
    }
}

```

#### `dev.crypt.chef`

```bash
dev.crypt.chef ()
{
    sym -ck APP_CHEF_SYM_KEY $*
}

```

#### `dev.decrypt.file`

```bash
dev.decrypt.file ()
{
    [[ -f ${1} ]] || {
        error 'usage: dev.decrypt.file <filename.enc>';
        return
    };
    sym -ck APP_SYM_KEY -n "${1}"
}

```

#### `dev.decrypt.str`

```bash
dev.decrypt.str ()
{
    [[ -z ${1} ]] && {
        error 'usage: dev.decrypt.str "string to decrypt"';
        return
    };
    sym -ck APP_SYM_KEY -d -s "$*"
}

```

#### `dev.edit.file`

```bash
dev.edit.file ()
{
    [[ -f ${1} ]] || {
        error 'usage: dev.edit.file <filename>';
        return
    };
    sym -ck APP_SYM_KEY -t "${1}"
}

```

#### `dev.encrypt.file`

```bash
dev.encrypt.file ()
{
    [[ -f ${1} ]] || {
        error 'usage: dev.encrypt.file <filename>';
        return
    };
    sym -ck APP_SYM_KEY -e -f "${1}" -o "${1}.enc"
}

```

#### `dev.encrypt.str`

```bash
dev.encrypt.str ()
{
    [[ -z "${1}" ]] && {
        error 'usage: dev.encrypt.str "string to encrypt"';
        return
    };
    sym -ck APP_SYM_KEY -e -s "$*"
}

```

#### `dev.sym`

```bash
dev.sym ()
{
    sym -cqk APP_SYM_KEY $*
}

```

#### `sym.dev.configure`

```bash
sym.dev.configure ()
{
    export SYMIT__KEY="APP_SYM_KEY"
}

```

#### `sym.dev.files`

```bash
sym.dev.files ()
{
    find . -name '*.enc' -type f
}

```

#### `sym.dev.have-key`

```bash
sym.dev.have-key ()
{
    sym.dev.configure;
    if [[ -z ${CI} ]]; then
        [[ -z "$(keychain ${SYMIT__KEY} find 2>/dev/null)" ]] || printf "yes";
    else
        [[ -n "${APP_SYM_KEY}" ]] && print "yes";
    fi
}

```

#### `sym.dev.import`

```bash
sym.dev.import ()
{
    local skip_instructions=${1:-0};
    if [[ ${AppCurrentOS} != 'Darwin' ]]; then
        error 'This is only meant to run on Mac OS-X';
        return;
    fi;
    sym.dev.configure;
    sym.install.symit;
    [[ -f ~/.sym.symit.bash ]] && source ~/.sym.symit.bash;
    h2 'Encryption Key Import';
    info "Checking for the existence of the current key...";
    if [[ -n "$(sym.dev.have-key)" ]]; then
        info: "Key ${SYMIT_KEY} is already in you your OS-X Key Chain.";
        run.ui.ask "Would you like to re-import it?";
        [[ $? != 0 ]] && return;
    fi;
    if [[ ${skip_instructions} == ${false} ]]; then
        hr;
        echo;
        info "1. Please open 1Password App and search for 'Encryption Key'";
        echo;
        info "2. Once you find the entry, it will contain two items: encryption key";
        info "      and password. Start by copying the key to the clipboard.";
        echo;
        info "3. You will need to paste the key first, and then copy/paste";
        info "      the key password (also in 1Password)";
        echo;
        info "4. As a final setup, you will be asked to create a new password.";
        info "      It must be at least 7 characters long, and will be used to encrypt";
        info "      the key locally on your machine.";
        echo;
        echo;
        run.ui.ask "Ready?";
        [[ $? != 0 ]] && return;
    fi;
    echo;
    hr;
    sym -iqpx APP_SYM_KEY;
    code=$?;
    [[ ${code} != 0 ]] && {
        error "Sym exited with error code ${code}";
        return ${code}
    };
    hr;
    echo;
    info "Key import was successful, great job! ${bldylw}☺ ";
    info "You can test that it works by encrypting, and decrypting a string,";
    echo;
    info "\$ ${bldylw}source bin/bash";
    info "\$ ${bldylw}dev.encrypt.str hello";
    info "\$ ${bldylw}dev.decrypt.str \$(dev.encrypt.str hello )";
    echo;
    info "Or a file:";
    info "\$ ${bldylw}dev.decrypt.file config/application.dev.yml.enc";
    echo;
    info "You can edit the file as if it wasn't encrypted:";
    info "\$ ${bldylw}dev.edit.file config/application.dev.yml.enc";
    echo
}

```

#### `sym.dev.install-shell-helpers`

```bash
sym.dev.install-shell-helpers ()
{
    local found=;
    declare -a init_files=($(util.shell-init-files));
    for file in ${init_files[@]};
    do
        f=${HOME}/${file};
        [[ ! -f "${f}" ]] && continue;
        [[ -n $(grep sym.symit ${f}) ]] && {
            found=${f};
            break
        };
    done;
    if [[ -z ${found} ]]; then
        for file in ${init_files[@]};
        do
            f="${HOME}/${file}";
            if [[ -f "${f}" ]]; then
                run "sym -B ${f} 1>/dev/null";
                return $?;
            fi;
        done;
    else
        run "sym -B ${found} 1>/dev/null";
    fi
}

```

#### `sym.install.symit`

```bash
sym.install.symit ()
{
    if [[ ! -f config.ru ]]; then
        error "Please run this command from the RAILS_ROOT folder";
        return 1;
    fi;
    [[ -n "$(which sym 2>/dev/null)" && -f ~/.sym.symit.bash ]] && return;
    local symit_source="/tmp/sym.symit.bash.$$";
    trap "rm -f ${symit__source}; " EXIT;
    local symit_url="https://raw.githubusercontent.com/kigster/sym/master/bin/sym.symit.bash";
    local cmd="curl -fsSL ${symit_url} -o ${symit_source}";
    export LibRun__AbortOnError=${True};
    run "${cmd}";
    if [[ ! -f ${symit_source} ]]; then
        err "unable to find downloaded file ${symit_source}";
        return 1;
    fi;
    source ${symit_source};
    rm -f ${symit_source};
    run "symit install";
    sym.dev.install-shell-helpers
}

```


---


### Module `time`

#### `epoch`

```bash
epoch ()
{
    date +%s
}

```

#### `millis`

```bash
millis ()
{
    .run.millis
}

```

#### `time.date-from-epoch`

```bash
time.date-from-epoch ()
{
    local epoch_ts="$1";
    if [[ "${AppCurrentOS}" == "Darwin" ]]; then
        printf "date -r ${epoch_ts}";
    else
        printf "date --date='@${epoch_ts}'";
    fi
}

```

#### `time.duration.humanize`

```bash
time.duration.humanize ()
{
    local seconds=${1};
    local hours=$((${seconds} / 3600));
    local remainder=$((${seconds} - ${hours} * 3600));
    local mins=$((${remainder} / 60));
    local secs=$((${seconds} - ${hours} * 3600 - ${mins} * 60));
    local prefixed=0;
    [[ ${hours} -gt 0 ]] && {
        printf "%02dh:" ${hours};
        prefixed=1
    };
    [[ ${mins} -gt 0 || ${prefixed} == 1 ]] && {
        printf "%02dm:" ${mins};
        prefixed=1
    };
    {
        printf "%02ds" ${secs}
    }
}

```

#### `time.duration.millis-to-secs`

```bash
time.duration.millis-to-secs ()
{
    local duration="$1";
    local format="${2:-"%d.%d"}";
    local seconds=$((duration / 1000));
    local leftover=$((duration - 1000 * seconds));
    printf "${format}" ${seconds} ${leftover}
}

```

#### `time.epoch-to-iso`

```bash
time.epoch-to-iso ()
{
    local epoch_ts=$1;
    eval "$(time.date-from-epoch ${epoch_ts}) -u \"+%Y-%m-%dT%H:%M:%S%z\"" | sed 's/0000/00:00/g'
}

```

#### `time.epoch-to-local`

```bash
time.epoch-to-local ()
{
    local epoch_ts=$1;
    [[ -z ${epoch_ts} ]] && epoch_ts=$(epoch);
    eval "$(time.date-from-epoch ${epoch_ts}) \"+%m/%d/%Y, %r\""
}

```

#### `time.epoch.minutes-ago`

```bash
time.epoch.minutes-ago ()
{
    local mins=${1};
    [[ -z ${mins} ]] && mins=1;
    local seconds=$((${mins} * 60));
    local epoch=$(epoch);
    echo $((${epoch} - ${seconds}))
}

```

#### `today`

```bash
today ()
{
    date +'%Y-%m-%d'
}

```


---


### Module `trap`

#### `trap-setup`

```bash
trap-setup ()
{
    .trap-remove;
    local signal="${1:-"SIGINT"}";
    trap '.trap-catch' "${signal}";
    export __int_signal__="${signal}"
}

```

#### `trap-was-fired`

```bash
trap-was-fired ()
{
    if [[ -f ${__int_marker__} ]]; then
        rm -f "${__int_marker__}";
        return 0;
    fi;
    return 1
}

```

#### `trapped`

```bash
trapped ()
{
    if [[ ${__int_flag__} -eq 1 ]]; then
        unset __int__flag__;
        return 0;
    fi;
    return 1
}

```


---


### Module `url`

#### `url.downloader`

```bash
url.downloader ()
{
    local downloader=;
    if [[ -z "${LibUrl__Downloader}" ]]; then
        [[ -z "${downloader}" && -n $(which curl) ]] && downloader="$(which curl) ${LibUrl__CurlDownloaderFlags}";
        [[ -z "${downloader}" && -n $(which wget) ]] && downloader="$(which wget) ${LibUrl__WgetDownloaderFlags}";
        [[ -z "${downloader}" ]] && {
            error "Neither Curl nor WGet appear in the \$PATH... HALP?";
            return 1
        };
        export LibUrl__Downloader="${downloader}";
    fi;
    printf "${LibUrl__Downloader}"
}

```

#### `url.http-code`

```bash
url.http-code ()
{
    local url="$1";
    local quiet="${2:-false}";
    [[ -z $(which wget) ]] && {
        echo 1>&2;
        err "This function currently only supports ${bldylw}wget.\n" 1>&2;
        echo 1>&2;
        return 100
    };
    url.is-valid "$url" || {
        echo 1>&2;
        err "The URL provided is not a valid URL: ${bldylw}${url}\n" 1>&2;
        echo 1>&2;
        return 101
    };
    local result=$(wget -v --spider "${url}" 2>&1 | egrep "response" | awk '{print $6}' | tr -d ' ' | tail -1);
    export LibUrl__LastHttpCode="${result}";
    if [[ ${quiet} == true ]]; then
        if [[ ${result} -gt 199 && ${result} -lt 210 ]]; then
            return 0;
        else
            return 1;
        fi;
    else
        [[ -n "${result}" ]] && printf ${result} || printf "404";
    fi
}

```

#### `url.is-valid`

```bash
url.is-valid ()
{
    local url="$1";
    if [[ $(url.valid-status "$url") = "ok" ]]; then
        return 0;
    else
        return 1;
    fi
}

```

#### `url.shorten`

```bash
url.shorten ()
{
    local longUrl="$1";
    if [[ -z "${BITLY_LOGIN}" || -z "${BITLY_API_KEY}" ]]; then
        printf "${longUrl}";
    else
        export BITLY_LOGIN=$(printf '%s' "${BITLY_LOGIN}" | tr -d '\r' | tr -d '\n');
        export BITLY_API_KEY=$(printf '%s' "${BITLY_API_KEY}" | tr -d '\r' | tr -d '\n');
        if [[ -n $(which ruby) ]]; then
            longUrl=$(ruby -e "require 'uri'; str = '${longUrl}'.force_encoding('ASCII-8BIT'); puts URI.encode(str)");
        fi;
        bitlyUrl="http://api.bit.ly/v3/shorten?login=${BITLY_LOGIN}&apiKey=${BITLY_API_KEY}&format=txt&longURL=${longUrl}";
        $(url.downloader) "${bitlyUrl}" | tr -d '\n' | tr -d ' ';
    fi
}

```

#### `url.valid-status`

```bash
url.valid-status ()
{
    local url="$1";
    echo "${url}" | ruby -ne '
    require "uri"
    u = URI.parse("#{$_}".chomp)
    if u && u.host && u.host&.include?(".") && u&.scheme =~ /^http/
      print "ok"
    else
      print "invalid"
    end'
}

```


---


### Module `user`

#### `user`

```bash
user ()
{
    local user;
    user=$(user.finger.name);
    [[ -z "${user}" ]] && user="$(user.gitconfig.name)";
    [[ -z "${user}" ]] && user="$(user.gitconfig.email)";
    [[ -z "${user}" ]] && user="$(user.username)";
    echo "${user}"
}

```

#### `user.finger.name`

```bash
user.finger.name ()
{
    [[ -n $(which finge) ]] && finger ${USER} | head -1 | sedx 's/.*Name: //g'
}

```

#### `user.first`

```bash
user.first ()
{
    user | tr '\n' ' ' | ruby -ne 'puts $_.split(/ /).first.capitalize'
}

```

#### `user.gitconfig.email`

```bash
user.gitconfig.email ()
{
    if [[ -s ${HOME}/.gitconfig ]]; then
        grep email ${HOME}/.gitconfig | sedx 's/.*=\s?//g';
    fi
}

```

#### `user.gitconfig.name`

```bash
user.gitconfig.name ()
{
    if [[ -s ${HOME}/.gitconfig ]]; then
        grep name ${HOME}/.gitconfig | sedx 's/.*=\s?//g';
    fi
}

```

#### `user.host`

```bash
user.host ()
{
    local host=;
    host=$(user.my.reverse-ip);
    [[ -z ${host} ]] && host=$(user.my.ip);
    printf "${host}"
}

```

#### `user.my.ip`

```bash
user.my.ip ()
{
    dig +short myip.opendns.com @resolver1.opendns.com
}

```

#### `user.my.reverse-ip`

```bash
user.my.reverse-ip ()
{
    nslookup $(user.my.ip) | grep 'name =' | sedx 's/.*name = //g'
}

```

#### `user.username`

```bash
user.username ()
{
    echo ${USER:-$(whoami)}
}

```


---


### Module `util`

#### `is-func`

```bash
is-func ()
{
    util.is-a-function "$@"
}

```

#### `pause`

```bash
pause ()
{
    sleep "${1:-1}"
}

```

#### `pause.long`

```bash
pause.long ()
{
    sleep "${1:-10}"
}

```

#### `pause.medium`

```bash
pause.medium ()
{
    sleep "${1:-0.3}"
}

```

#### `pause.short`

```bash
pause.short ()
{
    sleep "${1:-0.1}"
}

```

#### `sedx`

```bash
sedx ()
{
    local current=$(which sed);
    local latest=${LibSed__latestVersion:-'/usr/local/bin/gsed'};
    local os=$(uname -s);
    if [[ ! -x "${latest}" ]]; then
        if [[ "${os}" == "Darwin" ]]; then
            [[ -n $(which brew) ]] || return 1;
            brew install gnu-sed > /dev/null 2>&1;
            [[ -x "${latest}" ]] || latest="${current}";
        else
            if [[ "${os}" == "Linux" ]]; then
                latest="${current}";
            fi;
        fi;
    fi;
    latest=${latest:-${current}};
    ${latest} -E "$@"
}

```

#### `util.append-to-init-files`

```bash
util.append-to-init-files ()
{
    local string="$1";
    local search="${2:-$1}";
    is_installed=;
    declare -a shell_files=($(util.shell-init-files));
    for init_file in ${shell_files[@]};
    do
        file=${HOME}/${init_file};
        [[ -f ${file} && -n $(grep "${search}" ${file}) ]] && {
            is_installed=${file};
            break
        };
    done;
    if [[ -z "${is_installed}" ]]; then
        for init_file in ${shell_files[@]};
        do
            file=${HOME}/${init_file};
            [[ -f ${file} ]] && {
                echo "${string}" >> ${file};
                is_installed="${file}";
                break
            };
        done;
    fi;
    printf "${is_installed}"
}

```

#### `util.arch`

```bash
util.arch ()
{
    echo -n "${AppCurrentOS}-$(uname -m)-$(uname -p)" | tr 'A-Z' 'a-z'
}

```

#### `util.call-if-function`

```bash
util.call-if-function ()
{
    local func="$1";
    shift;
    util.is-a-function "${func}" && {
        ${func} "$@"
    }
}

```

#### `util.checksum.files`

```bash
util.checksum.files ()
{
    cat $* | shasum | awk '{print $1}'
}

```

#### `util.checksum.stdin`

```bash
util.checksum.stdin ()
{
    shasum | awk '{print $1}'
}

```

#### `util.functions-matching`

```bash
util.functions-matching ()
{
    local prefix=${1};
    local extra_command=${2:-"cat"};
    set | egrep "^${prefix}" | sed -E 's/.*.//g; s/[\(\)]//g;' | ${extra_command} | tr '\n ' ' '
}

```

#### `util.generate-password`

```bash
util.generate-password ()
{
    local len=${1:-32};
    local val=$(($(date '+%s') - 100000 * $RANDOM));
    [[ ${val:0:1} == "-" ]] && val=${val/-//};
    printf "$(echo ${val} | shasum -a 512 | awk '{print $1}' | base64 | head -c ${len})"
}

```

#### `util.i-to-ver`

```bash
util.i-to-ver ()
{
    version=${1};
    /usr/bin/env ruby -e "ver='${version}'; printf %Q{%d.%d.%d}, ver[1..2].to_i, ver[3..5].to_i, ver[6..8].to_i"
}

```

#### `util.install-direnv`

```bash
util.install-direnv ()
{
    [[ -n $(which direnv) ]] || brew.install.package direnv;
    local init_file=;
    local init_file=$(util.append-to-init-files 'eval "$(direnv hook bash)"; export DIRENV_LOG_FORMAT=' 'direnv hook');
    if [[ -f ${init_file} ]]; then
        info: "direnv init has been appended to ${bldylw}${init_file}...";
    else
        error: "direnv init could not be appended";
    fi;
    eval "$(direnv hook bash)"
}

```

#### `util.is-a-function`

```bash
util.is-a-function ()
{
    type "$1" 2> /dev/null | head -1 | grep -q 'is a function'
}

```

#### `util.is-numeric`

```bash
util.is-numeric ()
{
    [[ -z $(echo ${1} | sed -E 's/^[0-9]+$//g') ]]
}

```

#### `util.is-variable-defined`

```bash
util.is-variable-defined ()
{
    local var_name="$1";
    [[ -n ${!var_name+x} ]]
}

```

#### `util.lines-in-folder`

```bash
util.lines-in-folder ()
{
    local folder=${1:-'.'};
    find ${folder} -type f -exec wc -l {} \; | awk 'BEGIN{a=0}{a+=$1}END{print a}'
}

```

#### `util.random-number`

```bash
util.random-number ()
{
    local limit="${1:-"1000000"}";
    printf $(((RANDOM % ${limit})))
}

```

#### `util.remove-from-init-files`

```bash
util.remove-from-init-files ()
{
    local search="${1}";
    local backup_extension="${2}";
    [[ -z ${backup_extension} ]] && backup_extension="$(epoch).backup";
    [[ -z ${search} ]] && return;
    declare -a shell_files=($(util.shell-init-files));
    local temp_holder=$(mktemp);
    for init_file in ${shell_files[@]};
    do
        run.config.detail-is-enabled && inf "verifying file ${init_file}...";
        file=${HOME}/${init_file};
        if [[ -f ${file} && -n $(grep "${search}" ${file}) ]]; then
            run.config.detail-is-enabled && ui.closer.ok:;
            local matches=$(grep -c "${search}" ${file});
            run.config.detail-is-enabled && info "file ${init_file} matches with ${bldylw}${matches} matches";
            run "grep -v \"${search}\" ${file} > ${temp_holder}";
            if [[ -n "${backup_extension}" ]]; then
                local backup="${file}.${backup_extension}";
                run.config.detail-is-enabled && info "backup file will created in ${bldylw}${backup}";
                [[ -n "${do_backup_changes}" ]] && "mv ${file} ${backup}";
            fi;
            run "cp -v ${temp_holder} ${file}";
        else
            run.config.detail-is-enabled && ui.closer.not-ok:;
        fi;
    done;
    return ${LibRun__LastExitCode}
}

```

#### `util.shell-init-files`

```bash
util.shell-init-files ()
{
    shell_name=$(util.shell-name);
    if [[ ${shell_name} == "bash" ]]; then
        echo ".bash_${USER} .bash_profile .bashrc .profile";
    else
        if [[ ${shell_name} == "zsh" ]]; then
            echo ".zsh_${USER} .zshrc .profile";
        fi;
    fi
}

```

#### `util.shell-name`

```bash
util.shell-name ()
{
    echo $(basename $(printf $SHELL))
}

```

#### `util.ver-to-i`

```bash
util.ver-to-i ()
{
    version=${1};
    echo ${version} | awk 'BEGIN{FS="."}{ printf "1%02d%03.3d%03.3d", $1, $2, $3}'
}

```

#### `util.whats-installed`

```bash
util.whats-installed ()
{
    declare -a hb_aliases=($(alias | grep -E 'hb\..*=' | sedx 's/alias//g; s/=.*$//g'));
    h2 "Installed app aliases:" ' ' "${hb_aliases[@]}";
    h2 "Installed DB Functions:";
    info "hb.db  [ ms | r1 | r2 | c ]";
    info "hb.ssh <server-name-substring>, eg hb.ssh web"
}

```

#### `watch.command`

```bash
watch.command ()
{
    [[ -z "$1" ]] && return 1;
    trap "return 1" SIGINT;
    while true; do
        clear;
        hr.colored "${txtblu}";
        printf " ❯ Command: ${bldgrn}$*${clr}  •  ${txtblu}$(date)${clr}  •  Refresh: ${bldcyn}${LibUtil__WatchRefreshSeconds}${clr}\n";
        hr.colored "${txtblu}";
        eval "$*";
        hr.colored "${txtblu}";
        printf "To change refresh rate run ${bldylw}watch.set-refresh <seconds>${clr}\n\n\n";
        sleep "${LibUtil__WatchRefreshSeconds}";
    done
}

```

#### `watch.ls-al`

```bash
watch.ls-al ()
{
    while true; do
        ls -al;
        sleep ${LibUtil__WatchRefreshSeconds};
        clear;
    done
}

```

#### `watch.set-refresh`

```bash
watch.set-refresh ()
{
    export LibUtil__WatchRefreshSeconds="${1:-"0.5"}"
}

```


---


### Module `vim`

#### `gvim.off`

```bash
gvim.off ()
{
    vim.gvim-off
}

```

#### `gvim.on`

```bash
gvim.on ()
{
    vim.gvim-on
}

```

#### `vim.gvim-off`

```bash
vim.gvim-off ()
{
    vim.setup;
    [[ "${EDITOR}" == "vim" ]] && return 0;
    local regex_from='^export EDITOR=.*$';
    local regex_to='export EDITOR=vim';
    file.gsub "${LibVim__initFile}" "${regex_from}" "${regex_to}";
    file.gsub "${LibVim__initFile}" '^gvim.on$' 'gvim.off';
    egrep -q "${regex_from}" ${LibVim__initFile} || echo "${regex_to}" >> ${LibVim__initFile};
    egrep -q "^gvim\.o" ${LibVim__initFile} || echo "gvim.off" >> ${LibVim__initFile};
    eval "
    [[ -n '${DEBUG}' ]] && set -x
    export EDITOR=${LibVim__editorGvimOff}
    unalias ${LibVim__editorVi} 2>/dev/null
    unalias ${LibVim__editorGvimOff} 2>/dev/null
  "
}

```

#### `vim.gvim-on`

```bash
vim.gvim-on ()
{
    vim.setup;
    [[ "${EDITOR}" == "gvim" ]] && return 0;
    local regex_from='^export EDITOR=.*$';
    local regex_to='export EDITOR=gvim';
    file.gsub "${LibVim__initFile}" "${regex_from}" "${regex_to}";
    file.gsub "${LibVim__initFile}" '^gvim.off$' 'gvim.on';
    egrep -q "${regex_from}" ${LibVim__initFile} || echo "${regex_to}" >> ${LibVim__initFile};
    egrep -q "^gvim\.o.*" ${LibVim__initFile} || echo "gvim.on" >> ${LibVim__initFile};
    eval "
    [[ -n '${DEBUG}' ]] && set -x
    export EDITOR=${LibVim__editorGvimOn}
    alias ${LibVim__editorVi}=${LibVim__editorGvimOn}
    alias ${LibVim__editorGvimOff}=${LibVim__editorGvimOn}
  "
}

```

#### `vim.setup`

```bash
vim.setup ()
{
    export LibVim__initFile="${HOME}/.bash_profile";
    export LibVim__editorVi="vi";
    export LibVim__editorGvimOn="gvim";
    export LibVim__editorGvimOff="vim"
}

```


---


### Module `yaml`

#### `yaml-diff`

```bash
yaml-diff ()
{
    yaml.diff "$@"
}

```

#### `yaml-dump`

```bash
yaml-dump ()
{
    yaml.dump "$@"
}

```

#### `yaml.diff`

```bash
yaml.diff ()
{
    local f1="$1";
    shift;
    local f2="$1";
    shift;
    [[ -f "$f1" && -f "$f2" ]] || {
        h2 "USAGE: ${bldylw}yaml-diff file1.yml file2.yml [ ydiff-options ]";
        return 1
    };
    [[ -n $(which ${BashMatic__DiffTool}) ]] || brew.package.install ${BashMatic__DiffTool};
    local t1="/tmp/${RANDOM}.$(basename ${f1}).$$.yml";
    local t2="/tmp/${RANDOM}.$(basename ${f2}).$$.yml";
    yaml.expand-aliases "$f1" > "$t1";
    yaml.expand-aliases "$f2" > "$t2";
    run.set-next show-output-on;
    hr;
    run "ydiff $* ${t1} ${t2}";
    hr;
    run "rm -rf ${t1} ${t2}"
}

```

#### `yaml.dump`

```bash
yaml.dump ()
{
    local f1="$1";
    shift;
    [[ -f "$f1" ]] || {
        h2 "USAGE: ${bldylw}yaml-dump file.yml";
        return 1
    };
    [[ -n $(which ${BashMatic__DiffTool}) ]] || brew.package.install ${BashMatic__DiffTool};
    local t1="/tmp/${RANDOM}.$(basename ${f1}).$$.yml";
    yaml.expand-aliases "$f1" > "$t1";
    vim "$t1";
    run "rm -rf ${t1}"
}

```

#### `yaml.expand-aliases`

```bash
yaml.expand-aliases ()
{
    ruby -e "require 'yaml'; require 'json'; puts YAML.dump(JSON.parse(JSON.pretty_generate(YAML.load(File.read('${1}')))))"
}

```


---



## Copyright



© 2020 Konstantin Gredeskoul, All rights reserved, MIT License.