#!/bin/bash
rm bin/Measurements.swf -f
/usr/local/flex-3.2.0/bin/mxmlc -load-config release-config-3.2.0.xml --services src/services-config.xml src/Measurements.mxml -output bin/Measurements.swf
