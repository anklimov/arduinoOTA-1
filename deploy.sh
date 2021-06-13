#!/bin/bash -xe
GIT_REV=`git log --pretty=format:'%h' -n 1`
BUILD_DATE=`date +%Y-%m-%d:%H:%M:%S`
COMPILEINFO=`echo +$GIT_REV+$BUILD_DATE | tr -d '"'`

VERSION=`cat main.go| grep "const AppVersion" |cut -f4 -d " " | tr -d '"'`

#Remember to set GOROOT accordingly with your installation

export GOPATH=$PWD
export CGO_ENABLED=false

rm -rf distrib/

declare -a target_folders=("linux amd64" "linux 386" "linux arm" "darwin amd64" "windows 386" "linux arm64")

mkdir distrib

for folder in "${target_folders[@]}"
do 
   read -r field1 field2 <<< $folder
   folder=${folder/ /_}
   mkdir -p distrib/$folder/bin/
   GOOS=${field1} GOARCH=${field2} go build -o distrib/$folder/bin/arduinoOTA -ldflags "-X main.compileInfo=$COMPILEINFO" main.go

done

#Fix windows binary extension
mv distrib/windows_386/bin/arduinoOTA distrib/windows_386/bin/arduinoOTA.exe

cd distrib

for folder in "${target_folders[@]}"
do
   folder=${folder/ /_}
   mv $folder arduinoOTA
   if [[ $folder == "windows_386" ]]; then
	zip -r arduinoOTA-$VERSION-$folder.zip arduinoOTA/
   else
	tar cjf arduinoOTA-$VERSION-$folder.tar.bz2 arduinoOTA/
   fi
   rm -rf arduinoOTA
done

echo =======
ls -la arduinoOTA*
echo =======
sha256sum arduinoOTA*
echo =======
shasum arduinoOTA*

