# Makefile - build epm-deb-pkg

# Run this first to check for dependencies and to setup meta-date for packaging
# make first

# If missing packages, then as root run this:
#	make deps

# Get the source from github (build target will use this if epm/ not found)
#	make prepare-from-git
# Or get the source from a tar file (call manually before build target)
#	make prepare

# Build/package
#	make build
#	make test-package
# 	make test-release
#	make package
# 	make release
# 	make package-src

# --------------------
include ver.mak

# --------------------
# Source version
mVer=5.0.0
mNewVer=5.0.2

mArchiveHost = moria.whyayh.com
mArchiveDir = /rel/archive/software/ThirdParty/epm
mLocalArchive = rsync -Plptz $(mArchiveHost):$(mArchiveDir)/epm-v$(mVer).tgz .
mRemoteArchive = wget https://github.com/jimjag/epm/archive/refs/tags/v$(mVer).tar.gz
mArchiveMethod = $(mRemoteArchive)

mGitHub = git clone git@github.com:jimjag/epm.git

mDepPkgList = \
	epm-helper \
	libfltk1.3-dev \
	libpng-dev \
	libjpeg-dev \
	libxrender-dev \
	libxcursor-dev \
	libxfixes-dev \
	libxext-dev \
	libxft-dev \
	libxft2 \
	libxinerama-dev

mDirs = pkg tmp

# --------------------

.PHONY : first build package release test-package test-release tag \
         prepare prepare-from-git clean dist-clean package-src

first : ver.mak ver.epm
	@which mkver.pl
	@which patch-epm-list
	@which perl
	@tErr=0; for pkg in $(mDepPkgList); do \
	    dpkg -l | grep -q $$pkg; \
	    if [ $$? -ne 0 ]; then \
	        echo "Missing package: $$pkg"; \
	        tErr=1; \
	    fi; \
	done; \
	if [ $$tErr -ne 0 ]; then exit 1; fi

get-deps :
	if [ "$$(whoami)" != "root" ]; then exit 1; fi
	apt-get install $(mDepPkgList)

build : ver.env epm/config.h
	# Note: first check diff with custom/
	rsync -CPr custom/* epm
	. ./ver.env; sed -i 's/v$(mVer)/v$(ProdVer)/' epm/config.h
	cd epm; make
	egrep -v '%product|%subpackage|%copyright|%vendor|%license|%readme|%description|%version|%packager|GUIS=|README|COPYING|LICENSE' epm/epm.list >epm.list

test-package : TBD
	-rm -f pkg ver.epm >/dev/null 2>&1
	mkdir pkg
	export RELEASE=0; mkver.pl -d ver.sh -e epm
	cd epm; ./epm -v -f native -m $(ProdOS)-$(ProdArch) --output-dir ../pkg epm ../ver.epm

test-release : ver.mak
	rsync -zP pkg/* $(ProdRelServer):$(ProdDevDir)/$(ProdOS)

package : ver.mak
	-rm -rf pkg ver.epm >/dev/null 2>&1
	mkdir pkg
	export RELEASE=1; mkver.pl -d ver.sh -e epm
	cd epm; ./epm -v -f native -m $(ProdOS)-$(ProdArch) --output-dir ../pkg epm ../ver.epm

release : ver.env ver.mak
	+. ./ver.env; echo "ssh $$ProdRelServer mkdir -p $$ProdRelDir"
	-. ./ver.env; ssh $$ProdRelServer mkdir -p $$ProdRelDir
	. ./ver.env; ssh $$ProdRelServer test -d $$ProdRelDir
	. ./ver.env; rsync -zP pkg/$${ProdName}-* $$ProdRelServer:$$ProdRelDir
	make tag

tag : ver.env ver.mak
	git commit -am Updated
	. ./ver.env; git tag -f -a -m "Released to: $$ProdRelServer:$$ProdRelDir" $(ProdTag)-$(ProdBuild)
	date -u +'%F %R UTC' >>VERSION
	. ./ver.env; echo $(ProdTag)-$(ProdBuild) >>VERSION

prepare : ver.mak tmp tmp/epm-v$(mVer).tgz
	-rm -rf epm
	tar -xzf tmp/epm-v$(mVer).tgz
	-cd epm; ./configure --quiet --prefix=/usr/local

prepare-from-git epm/config.h : ver.mak ~/ver/github/epm
	cd ~/ver/github/epm; git co trunk
	cd ~/ver/github/epm; git pull origin trunk
	cd ~/ver/github/epm; git fetch --all --tags
	cd ~/ver/github/epm; git co v$(mVer)
	-rm -rf epm
	mkdir epm
	rsync -aP ~/ver/github/epm/* epm/
	-cd epm; ./configure --quiet --prefix=/usr/local

clean :
	-find * -name '*~' -exec rm {} \;
	-rm ver.epm ver.env epm.list
	#-cd epm; make clean; make distclean

dist-clean : clean
	-rm ver.mak
	-rm -rf epm pkg tmp
	-rm *.env config.cache

package-src : distclean ver.env
	cd ..; tar -cz --exclude CVS -f $(ProdName)-$(ProdVer)-src.tar.gz $(ProdName)
	cd ..; scp $(ProdName)-$(ProdVer)-src.tar.gz $(ProdRelServer):$(ProdRelDir)
	cd ..; rm $(ProdName)-$(ProdVer)-src.tar.gz

# -----------------------
# Working targets

ver.mak ver.env ver.epm : ver.sh /usr/local/bin/mkver.pl
	mkver.pl -d ver.sh -e 'mak env epm'

$(mDirs) :
	mkdir -p $@

tmp/epm-v$(mVer).tgz : 
	$(mArchiveMethod)
	mv -f *.tgz tmp

~/ver/github/epm :
	-cd ~; mkdir -p ver/github
	cd ~/ver/github; git clone git@github.com:jimjag/epm.git
	cd ~/ver/github/epm; git fetch --all --tags

#/usr/local/bin/mkver.pl /usr/local/bin/patch-epm-list :
#	apt-get install epm-helper.deb
