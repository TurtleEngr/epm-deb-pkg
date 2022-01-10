# Makefile - build epm

# Build Dependencies
#	make deps
# Get source
#	make prepare
#		or
#	make prepare-from-git

# Build/package
#	make build
#	make package
# 	make release-dev
# 	make release
# 	make package-src

include ver.mak

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
	libfltk1.3-dev \
	libpng-dev \
	libjpeg-dev \
	libxrender-dev \
	libxcursor-dev \
	libxfixes-dev \
	libxext-dev \
	libxft2-dev \
	libxinerama-dev

mDirs = pkg tmp

# --------------------
.PHONY : build package releas-dev release tag prepare prepare-from-git \
         clean dist-clean package-src

build : ver.env
	# Note: firs check diff with custom/
	rsync -CPr custom/* epm
	sed -i 's/v$(mVer)/v$(ProdVer)/' epm/config.h
	cd epm; make
	egrep -v '%product|%subpackage|%copyright|%vendor|%license|%readme|%description|%version|%packager|GUIS=|README|COPYING|LICENSE' epm/epm.list >epm.list

package : ver.epm ver.mak pkg
	-rm -f pkg/* 2>/dev/null
	cd epm; ./epm -v -f native -m $(ProdOS)-$(ProdArch) --output-dir ../pkg epm ../ver.epm

release-dev : ver.mak
	rsync -zP pkg/* $(ProdRelServer):$(ProdDevDir)/$(ProdOS)

release : ver.mak tag
	-ssh $(ProdRelServer) mkdir $(ProdRelDir)/$(ProdOS)
	rsync -zP pkg/* $(ProdRelServer):$(ProdRelDir)/$(ProdOS)

tag : ver.mak
	cvs commit -m Updated
	cvs tag -cRF $(ProdTag)
	date >>VERSION
	echo $(ProdTag) >>VERSION

deps : /usr/local/bin/mkver.pl ver.mak
	if [ "$$(whoami)" != "root" ]; then exit 1; fi
	apt-get install $(mDepPkgList)

prepare : ver.mak tmp tmp/epm-v$(mVer).tgz
	-rm -rf epm
	tar -xzf tmp/epm-v$(mVer).tgz
	-cd epm; ./configure --quiet --prefix=/usr/local

prepare-from-git : ver.mak ~/ver/github/epm
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
	-cd epm; make clean; make distclean

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
	export RELEASE=0; mkver.pl -d ver.sh -e 'mak env epm'

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
#	apt-get install epm-helpers.deb
