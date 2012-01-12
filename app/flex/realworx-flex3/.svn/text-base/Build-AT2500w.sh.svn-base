#!/bin/bash
rm bin/at2500w.swf -f
export BUILD=`svn info | awk '/Revision/ {print $2}'`
echo "Build #: ${BUILD} , Build Date: `date`"
/usr/local/flex-3.2.0/bin/mxmlc -define+=CONFIG::version_string,"'Build #: ${BUILD} , Build Date: `date`'" -load-config release-config-3.2.0.xml --services src/services-config.xml src/at2500w.mxml -output bin/at2500w.swf
