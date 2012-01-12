#!/bin/bash
rm bin/PlanEditor.swf -f
/usr/local/flex-3.2.0/bin/mxmlc -load-config release-config-3.2.0.xml --services src/services-config.xml src/PlanEditor.mxml -output bin/PlanEditor.swf
