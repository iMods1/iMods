#!/bin/bash
target=$PWD/$PROJECT_NAME/Package/DEBIAN/postinst
rm $target
cp $PWD/Scripts/postinst.template $target
perl -p -i -e "s,<ProjectName>,$PROJECT_NAME,g" $target
chmod 0555 $target
