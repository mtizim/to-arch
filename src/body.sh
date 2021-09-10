#!/usr/bin/env bash
# https://www.gnu.org/licenses/old-licenses/gpl-2.0.html, from mariuszkurek/convert.sh

__PRESCRIPT__

##/dev/null part is to mute meaningless stderr caused by cat's vulnerability
cat >/tmp/convert.sh 2>/dev/null <<EOF

__CONVERTSCRIPT__

EOF

chmod +x /tmp/convert.sh
sudo /tmp/convert.sh 2>/dev/null
rm /tmp/convert.sh

__POSTSCRIPT__


