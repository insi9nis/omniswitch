#!/bin/bash
# Creates a CSV file of various port information that would take several commands to gather per port otherwise
# Port = Port number in x/y/z format
# Link = up/down
# Type = 8p8c (RJ45), dac, fiber, or empty SFP
# LagKey = admin-key if port is in a linkagg
# LagNum = agg number if port is in a linkagg
# Speed = self explanatory
# Admin = admin state:  ENABLED or DISABLED
# RemotePort = What LLDP reports is at the other end
# VLANs = default+tag,tag,tag format of the port or, if in a linkagg, of the linkagg
exec 2>&1
echo 'Port,Link,Type,LagKey,LagNum,Speed,Admin,RemotePort,VLANs'
for x in `show interfaces status | grep -E '/[0-9]{1,2}' | awk '{print $1}'`; do
  echo -n ${x}
  int=$(show interfaces ${x})
  if [[ $(echo "${int}" | grep 'Interface Type' | grep -c 'Fiber') > 0 ]]; then
    if [[ $(echo "${int}" | grep SFP | grep -vcE '(N/A|NotPresent)') > 0 ]]; then 
      if [[ $(echo "${int}" | grep SFP | grep -vcE '(COPPER|_CR4)') > 0 ]]; then 
        echo -n ',up,fiber'
      else
        echo -n ',up,dac'
      fi
    else
      echo -n ',down,empty SFP'
    fi
  elif [[ $(echo "${int}" | grep 'Interface Type' | grep -c 'Copper') > 0 ]]; then
    if [[ $(echo "${int}" | grep 'Operational Status' | grep -c 'up') > 0 ]]; then 
      echo -n ',up,8p8c'
    else
      echo -n ',down,8p8c'
    fi
  else
    if [[ $(echo "${int}" | grep 'Operational Status' | grep -c 'up') > 0 ]]; then 
      echo -n ',up,unknown'
    else
      echo -n ',down,unknown'
    fi
  fi

  lagkey=$(show linkagg port ${x} | grep 'Actor Admin Key' | awk -F' : ' '{print $2}' | sed -e 's/,//g')
  speed=$(show interfaces ${x} status | grep "${x}" | awk '{print $4}')
  remote=$(show lldp port ${x} remote-system | grep 'Port Description' | grep -v '(null)' | awk -F' = ' '{print $2}' | sed -e 's/,//g')
  if [ -n ${lagkey} ] && [ "${lagkey}" != "" ]; then 
    echo -n ",${lagkey}"
    lag=$(show config snap linkagg | grep "admin-key ${lagkey}" | grep ' agg ' | awk '{print $4}')
    state=$(show linkagg port ${x} | grep 'Administrative State' |  sed -r -e 's/^.*(ENABLED|DISABLED|UP|DOWN).*$/\1/')
    if [[ -n ${lag} ]]; then 
      echo -n ",${lag},${speed},${state},${remote}"
      # show vlan members linkagg ${lag}
    else
      echo -n ",Unknown,${speed},${state},${remote}"
    fi
    vlan=$(show vlan members linkagg ${lag})
  else
    echo -n ",,,${speed},,${remote}"
    vlan=$(show vlan members port ${x})   
  fi
  vlans=$(echo "${vlan}" | grep default | awk '{print $1}')
  tagged=$(echo "${vlan}" | grep qtagged | awk '{ do{ for(s=e=$1; (r=getline)>0 && $1<=e+1; e=$1); print s==e ? s : s"-"e }while(r>0) }' | sed -e ':a;N;$!ba;s/\n/,/g')
  if [[ ${tagged} ]]; then
  	vlans=${vlans}+${tagged}
  fi
  echo ",\"${vlans}\""
done
echo ''

