# Input file for: mkver.pl.  All variables must have
# "export " at the beginning.  No spaces around the
# "=".  And all values enclosed with double quotes.
# Variables may include other variables in their
# values.

export ProdName="epm"
# One word [-_.a-zA-Z0-9]

export ProdVer="5.0.1"
# [0-9]*.[0-9]*{.[0-9]*}{.[0-9]*}

export ProdBuild="4"
# [0-9]*

export ProdSummary="ESP Package Manager"
# All on one line (< 80 char)

export ProdDesc="EPM is a universal software packaging tool for UNIX type ssystime.  Patched to allow hyphens in product names."
# All on one line

export ProdVendor="whyayh.com"

export ProdPackager="TurtleEngr"
export ProdSupport="https://jimjag.github.io/epm/"
export ProdCopyright="2020"

export ProdDate=""
# 20[012][0-9]-[01][0-9]-[0123][0-9]

export ProdLicense="epm/LICENSE"
# Required

export ProdReadMe="epm/README.md"
# Required

# Third Party (if any)
export ProdTPVendor="Michael R Sweet, Jim Jagielski"
export ProdTPVer="5.0.0"
#export ProdTPCopyright="1999-2010 by Easy Software Products"
export ProdTPCopyright="2020 by Jim Jagielski, All Rights Reserved."

# Set this to latest version of mkver.pl
export MkVer="2.2"

export ProdRelServer="moria.whyayh.com"
export ProdRelRoot="/rel"
export ProdRelCategory="software/ThirdParty/$ProdName"
# Generated: ProdRelDir=ProdRelRoot . /released|development/ . ProdRelCategory

# Generated: ProdTag=ProdVer-ProdBuild
# "." converted to "-"

# Output file control variables.
# The *File vars can include dir. names
# The *Header and *Footer defaults are more complete
# than what is shown here.

export envFile="ver.env"
export envHeader=""
export envFooter=""

export epmFile="ver.epm"
export epmHeader=""
export epmFooter="%include ../epm.include"
